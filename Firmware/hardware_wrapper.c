#include "hardware_wrapper.h"
#include "pico/stdlib.h"
#include "hardware/i2c.h"
#include "hardware/gpio.h"
#include "hardware/watchdog.h"
#include <string.h>
#include <stdio.h>

#define I2C_PORT i2c1
#define I2C_SDA 2
#define I2C_SCL 3
#define DISPLAY_ADDR 0x3C

const uint8_t col_pins[] = {0, 1, 4, 21, 20, 19};
const uint8_t row_pins[] = {8, 7, 6, 5, 16, 14, 15, 18};

struct EmuDisplay {
    uint32_t magic[4];
    uint8_t buffer[1024];
};

volatile struct EmuDisplay emu_display = {
    .magic = {0x11223344, 0x55667788, 0x99AABBCC, 0xDDEEFF00},
    .buffer = {0}
};
void hw_init(void) {
    stdio_init_all();
    watchdog_enable(2000, 1);
    printf("C Booted! Magic check: %lx\n", emu_display.magic[0]);
    void* ptr = malloc(32);
    printf("Malloc: %p\n", ptr);
    free(ptr);
#ifndef EMULATOR
    // I2C init
    i2c_init(I2C_PORT, 400 * 1000);
    gpio_set_function(I2C_SDA, GPIO_FUNC_I2C);
    gpio_set_function(I2C_SCL, GPIO_FUNC_I2C);
    gpio_pull_up(I2C_SDA);
    gpio_pull_up(I2C_SCL);
#endif

    // SSD1306 Init sequence
    uint8_t cmds[] = {
        0x00, // Command stream
        0xAE, // Display OFF
        0x20, 0x00, // Memory addressing mode = Horizontal
        0x21, 0, 127, // Column address
        0x22, 0, 7, // Page address
        0x40, // Start line 0
        0xA1, // Segment remap
        0xA8, 63, // MUX ratio
        0xC8, // COM scan direction
        0xD3, 0x00, // Display offset
        0xDA, 0x12, // COM pins config
        0xD5, 0x80, // Display clock divide
        0xD9, 0xF1, // Precharge
        0xDB, 0x30, // VCOM deselect
        0x81, 0xFF, // Contrast
        0xA4, // Entire display ON (resume)
        0xA6, // Normal display
        0xAF  // Display ON
    };
#ifndef EMULATOR
    i2c_write_blocking(I2C_PORT, DISPLAY_ADDR, cmds, sizeof(cmds), false);
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
    uint8_t payload[1025];
    payload[0] = 0x40; // Data control byte
    for (int i = 0; i < 1024; i++) {
        payload[i + 1] = buffer[i];
    }
#ifndef EMULATOR
    i2c_write_blocking(I2C_PORT, DISPLAY_ADDR, payload, 1025, false);
#else
    for (int i = 0; i < 1024; i++) {
        emu_display.buffer[i] = buffer[i];
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
    return getchar_timeout_us(0);
}

uint64_t hw_time_us(void) {
    return time_us_64();
}

void format_double_c(double val, uint8_t* buffer, int max_len, int mode, int places) {
    if (mode == 1) { // FIX
        snprintf((char*)buffer, max_len, "%.*f", places, val);
    } else if (mode == 2) { // SCI
        snprintf((char*)buffer, max_len, "%.*e", places, val);
    } else if (mode == 3) { // ENG
        // C doesn't have a direct format specifier for ENG, so we fallback to 'g' with the given places
        snprintf((char*)buffer, max_len, "%.*g", places, val);
    } else { // ALL
        snprintf((char*)buffer, max_len, "%.14g", val);
    }
}
