#include "hardware_wrapper.h"
#include "pico/stdlib.h"
#include "hardware/spi.h"
#include "hardware/watchdog.h"
#include "hardware/sync.h"
#include "hardware/gpio.h"
#include "hardware/watchdog.h"
#include <string.h>
#include <stdio.h>

#define SPI_PORT spi0
#define PIN_CS   1
#define PIN_SCK  2
#define PIN_MOSI 3
#define PIN_DC   4

// Keypad pins remapped for 14 available GPIOs
const uint8_t col_pins[] = {14, 16, 10, 5, 6, 7};
const uint8_t row_pins[] = {21, 20, 19, 18, 15, 0, 8, 9};

struct EmuDisplay {
    uint32_t magic[4];
    uint8_t buffer[1188];
};

volatile struct EmuDisplay emu_display = {
    .magic = {0x11223344, 0x55667788, 0x99AABBCC, 0xDDEEFF00},
    .buffer = {0}
};

#ifndef EMULATOR

#endif



void hw_init(void) {
    stdio_init_all();
    void test_sub(); test_sub();
#ifndef EMULATOR
    watchdog_enable(2000, 1);
#endif
    printf("C Booted! Magic check: %lx\n", emu_display.magic[0]);
    void* ptr = malloc(32);
    free(ptr);

#ifndef EMULATOR
    // SPI Init (Sharp Memory LCD can run up to 2MHz, but let's be safe with 1MHz)
    spi_init(SPI_PORT, 8000 * 1000); // ST7567 can run at 8MHz
    
    spi_set_format(SPI_PORT, 8, SPI_CPOL_0, SPI_CPHA_0, SPI_MSB_FIRST);

    gpio_set_function(PIN_SCK, GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);

    gpio_init(PIN_CS);
    gpio_set_dir(PIN_CS, GPIO_OUT);
    gpio_put(PIN_CS, 1); // CS active LOW

    gpio_init(PIN_DC);
    gpio_set_dir(PIN_DC, GPIO_OUT);
    gpio_put(PIN_DC, 0);

    // LCD Reset is tied to MCU Hardware Reset, no software toggle needed
    sleep_ms(100);

    // ERC13265-1 (SPLC502) Init Sequence
    gpio_put(PIN_CS, 0);
    gpio_put(PIN_DC, 0); // Command mode
    uint8_t init_cmds[] = {
        0xE2, // Soft reset
        0xA0, // CLEAR_ADC (s1-s132)
        0xC8, // SET_SHL (c1-c65)
        0xA2, // CLEAR_BIAS (1/9)
        0x2F, // Power Control (0x28 | 0x07)
        0x25, // Regulator resistor select (0x20 | 0x05)
        0x81, 24, // Contrast level (24 per ERC13265-1 driver)
        0x40, // Start line
        0xAF, // Display ON
        0xDC
    };
    spi_write_blocking(SPI_PORT, init_cmds, sizeof(init_cmds));
    gpio_put(PIN_CS, 1);
#endif

    // Matrix init
    for (int i=0; i<6; i++) {
        gpio_init(col_pins[i]);
        gpio_set_dir(col_pins[i], GPIO_IN);
        gpio_pull_down(col_pins[i]);
    }
    for (int i=0; i<8; i++) {
        gpio_init(row_pins[i]);
        gpio_set_dir(row_pins[i], GPIO_OUT);
        gpio_put(row_pins[i], 0);
    }
}

void display_send_buffer(const uint8_t* buffer) {
    watchdog_update();
#ifndef EMULATOR
    gpio_put(PIN_CS, 0);
    
    for (int p = 0; p < 9; p++) {
        gpio_put(PIN_DC, 0); // Command
        uint8_t page_cmd[] = { (uint8_t)(0xB0 | p), 0x10, 0x00 };
        spi_write_blocking(SPI_PORT, page_cmd, 3);
        
        gpio_put(PIN_DC, 1); // Data
        spi_write_blocking(SPI_PORT, buffer + (p * 132), 132);
    }
    
    gpio_put(PIN_CS, 1);
#else
    int nonZero = 0;
    for (int i = 0; i < 1188; i++) {
        emu_display.buffer[i] = buffer[i];
        if (buffer[i] != 0) nonZero++;
    }
#endif
}



static bool blue_shift_active = false;
volatile bool oom_fault_occurred = false;

void isr_hardfault(void) {
    oom_fault_occurred = true;
    while(1) {
        uint64_t state = matrix_scan();
        bool c_pressed = (state & (1ULL << 42)) != 0;
        bool blue_pressed = (state & (1ULL << 40)) != 0;
        if (c_pressed && blue_pressed) {
            system_sleep();
        } else if (c_pressed) {
            watchdog_reboot(0, 0, 0);
        }
    }
}

void system_sleep(void);

void abort(void) {
    oom_fault_occurred = true;
    while(1) {
        uint64_t state = matrix_scan();
        bool c_pressed = (state & (1ULL << 42)) != 0;
        bool blue_pressed = (state & (1ULL << 40)) != 0;
        if (c_pressed && blue_pressed) {
            system_sleep();
        } else if (c_pressed) {
            watchdog_reboot(0, 0, 0);
        }
    }
}

static struct repeating_timer hw_scan_timer;

void system_sleep(void) {
    // Turn off display
    gpio_put(PIN_CS, 0);
    gpio_put(PIN_DC, 0);
    uint8_t disp_off = 0xAE;
    spi_write_blocking(SPI_PORT, &disp_off, 1);
    gpio_put(PIN_CS, 1);
    
    // Set all rows LOW except Row 7 (which has the C / ON key)
    for (int i=0; i<8; i++) {
        gpio_put(row_pins[i], i == 7 ? 1 : 0);
    }
    
    // Wait for C key (Col 0) to be released first
    while(gpio_get(col_pins[0])) {
        sleep_ms(10);
    }
    
    // Wait for C key to be pressed
    while(!gpio_get(col_pins[0])) {
        __wfi(); // Wait for interrupt
    }
    
    // Reboot!
    watchdog_enable(1, 1);
    while(1);
}

uint64_t matrix_scan(void);

bool hw_scan_timer_callback(struct repeating_timer *t) {
    uint64_t state = matrix_scan();
    bool blue_pressed = (state & (1ULL << 36)) != 0;
    bool c_pressed = (state & (1ULL << 42)) != 0;
    
    if (blue_pressed) {
        blue_shift_active = true;
    } else if (state != 0 && !c_pressed) {
        blue_shift_active = false;
    }
    
    if (c_pressed && blue_shift_active) {
        system_sleep();
    }
    if (oom_fault_occurred && c_pressed) {
        watchdog_reboot(0, 0, 0);
    }
    return true;
}

uint64_t matrix_scan(void) {
    uint64_t state = 0;
    for (int r = 0; r < 8; r++) {
        gpio_put(row_pins[r], 1);
        sleep_us(10); // Settle
        for (int c = 0; c < 6; c++) {
            if (gpio_get(col_pins[c])) {
                state |= (1ULL << ((r * 6) + c));
            }
        }
        gpio_put(row_pins[r], 0);
    }
    return state;
}

void sleep_ms_c(uint32_t ms) {
    sleep_ms(ms);
}

int get_uart_char_c(void) {
    watchdog_update();
    return getchar_timeout_us(0);
}

uint64_t hw_time_us(void) {
    return time_us_64();
}

void hw_display_sleep_c(void) {
#ifndef EMULATOR
    // Clear display to white/black before sleep if desired, but Sharp Memory LCD is static
#endif
}

void hw_display_wake_c(void) {
#ifndef EMULATOR
    // No hardware reset needed for Sharp Memory LCD
#endif
}

double swift_math_floor(double x) {
    return floor(x);
}

double swift_math_abs(double x) {
    return fabs(x);
}
