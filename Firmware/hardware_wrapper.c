#include "hardware_wrapper.h"
#include "pico/stdlib.h"
#include "hardware/spi.h"
#include "hardware/gpio.h"
#include "hardware/watchdog.h"
#include <string.h>
#include <stdio.h>

#define SPI_PORT spi0
#define PIN_CS   17
#define PIN_SCK  18
#define PIN_MOSI 19
#define PIN_DC   21
#define PIN_RST  20

// Keypad pins remapped
const uint8_t col_pins[] = {0, 1, 4, 2, 3, 9};
const uint8_t row_pins[] = {8, 7, 6, 5, 16, 14, 15, 12};

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

    gpio_init(PIN_RST);
    gpio_set_dir(PIN_RST, GPIO_OUT);
    gpio_put(PIN_RST, 1);

    // ST7567 Reset
    gpio_put(PIN_RST, 0);
    sleep_ms(50);
    gpio_put(PIN_RST, 1);
    sleep_ms(50);

    // ST7567 Init Sequence
    gpio_put(PIN_CS, 0);
    gpio_put(PIN_DC, 0); // Command mode
    uint8_t init_cmds[] = {
        0xE2, // Soft reset
        0xA0, // CLEAR_ADC (s1-s132)
        0xC8, // SET_SHL (c1-c65)
        0xA2, // CLEAR_BIAS (1/9)
        0x2F, // Power Control (0x28 | 0x07)
        0x25, // Regulator resistor select (0x20 | 0x05)
        0x81, 0x1F, // Contrast
        0x40, // Start line
        0xAF,  // Display ON
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

void format_double_c(double val, uint8_t* buffer, int max_len, int mode, int places) {
    if (val < 0.0) {
        *buffer = '-';
        buffer++;
        max_len--;
        union { double d; uint64_t i; } u;
        u.d = val;
        u.i &= 0x7FFFFFFFFFFFFFFFULL;
        val = u.d;
    }
    
    if (mode == 1) { // FIX
        snprintf((char*)buffer, max_len, "%.*f", places, val);
    } else if (mode == 2) { // SCI
        snprintf((char*)buffer, max_len, "%.*E", places, val);
        char* e_ptr = strchr((char*)buffer, 'E');
        if (e_ptr) {
            char sign = e_ptr[1];
            char* digits = e_ptr + 2;
            while (*digits == '0' && *(digits + 1) != '\0') digits++;
            if (sign == '+') {
                memmove(e_ptr + 1, digits, strlen(digits) + 1);
            } else {
                memmove(e_ptr + 2, digits, strlen(digits) + 1);
            }
        }
    } else if (mode == 3) { // ENG
        snprintf((char*)buffer, max_len, "%.*G", places, val);
    } else { // ALL
        int max_chars = max_len - 1;
        // Pico SDK's %G drops precision and defaults to 6 decimal places for scientific.
        // For large integers, just format as integer to keep precision!
        double abs_val = val < 0 ? -val : val;
        if (abs_val >= 1.0 && abs_val < 1e11 && (abs_val - (int64_t)abs_val) < 1e-9) {
            snprintf((char*)buffer, max_len, "%lld", (long long)val);
        } else {
            for (int p = 11; p >= 0; p--) {
                int needed = snprintf(NULL, 0, "%.*G", p, val);
                if (needed <= max_chars) {
                    snprintf((char*)buffer, max_len, "%.*G", p, val);
                    break;
                }
            }
        }
    }
    
    // Post-process to fix pico_printf bugs
    // 1. Convert 'e' to 'E'
    char* e_ptr = strchr((char*)buffer, 'e');
    if (e_ptr) {
        *e_ptr = 'E';
    } else {
        e_ptr = strchr((char*)buffer, 'E');
    }

    // 2. Remove trailing zeros in the fractional part for ALL mode (mode 0)
    if (mode == 0) {
        char* dot = strchr((char*)buffer, '.');
        if (dot) {
            char* end_of_frac = e_ptr ? e_ptr : ((char*)buffer + strlen((char*)buffer));
            char* p = end_of_frac - 1;
            while (p > dot && *p == '0') {
                p--;
            }
            if (p == dot) { // Remove the dot too if no fractional digits remain
                p--;
            }
            // Move the rest of the string (e.g. exponent) over
            if (e_ptr) {
                memmove(p + 1, e_ptr, strlen(e_ptr) + 1);
            } else {
                *(p + 1) = '\0';
            }
        }
    }

    // 3. For SCI mode (mode 2) and ALL mode (mode 0), strip + and leading zeros in exponent
    if (mode == 2 || mode == 0) {
        e_ptr = strchr((char*)buffer, 'E');
        if (e_ptr) {
            char sign = e_ptr[1];
            char* digits = e_ptr + 2;
            while (*digits == '0' && *(digits + 1) != '\0') digits++;
            if (sign == '+') {
                memmove(e_ptr + 1, digits, strlen(digits) + 1);
            } else {
                memmove(e_ptr + 2, digits, strlen(digits) + 1);
            }
        }
    }
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
