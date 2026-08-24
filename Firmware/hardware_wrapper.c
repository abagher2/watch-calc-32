#include "hardware_wrapper.h"
#include "pico/stdlib.h"
#include "hardware/spi.h"
#include "hardware/gpio.h"
#include "hardware/watchdog.h"
#include <string.h>
#include <stdio.h>

#define SPI_PORT spi1
#define PIN_SCK  10
#define PIN_MOSI 11
#define PIN_CS   18
#define PIN_DC   19
#define PIN_RST  20
#define PIN_BUSY 21

// Keypad pins remapped to avoid conflict with SPI E-Ink pins
const uint8_t col_pins[] = {0, 1, 4, 2, 3, 9};
const uint8_t row_pins[] = {8, 7, 6, 5, 16, 14, 15, 12};

struct EmuDisplay {
    uint32_t magic[4];
    uint8_t buffer[1024];
};

volatile struct EmuDisplay emu_display = {
    .magic = {0x11223344, 0x55667788, 0x99AABBCC, 0xDDEEFF00},
    .buffer = {0}
};

static inline void eink_send_cmd(uint8_t cmd) {
#ifndef EMULATOR
    gpio_put(PIN_DC, 0);
    gpio_put(PIN_CS, 0);
    spi_write_blocking(SPI_PORT, &cmd, 1);
    gpio_put(PIN_CS, 1);
#endif
}

static inline void eink_send_data(uint8_t data) {
#ifndef EMULATOR
    gpio_put(PIN_DC, 1);
    gpio_put(PIN_CS, 0);
    spi_write_blocking(SPI_PORT, &data, 1);
    gpio_put(PIN_CS, 1);
#endif
}

static void eink_wait_busy(void) {
#ifndef EMULATOR
    while(gpio_get(PIN_BUSY) == 1) {
        sleep_ms(10);
    }
#endif
}

void hw_init(void) {
    stdio_init_all();
#ifndef EMULATOR
    watchdog_enable(2000, 1);
#endif
    printf("C Booted! Magic check: %lx\n", emu_display.magic[0]);
    void* ptr = malloc(32);
    printf("Malloc: %p\n", ptr);
    free(ptr);

#ifndef EMULATOR
    // SPI Init
    spi_init(SPI_PORT, 4000 * 1000); // 4 MHz
    gpio_set_function(PIN_SCK, GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);

    gpio_init(PIN_CS);
    gpio_set_dir(PIN_CS, GPIO_OUT);
    gpio_put(PIN_CS, 1);

    gpio_init(PIN_DC);
    gpio_set_dir(PIN_DC, GPIO_OUT);
    gpio_put(PIN_DC, 0);

    gpio_init(PIN_RST);
    gpio_set_dir(PIN_RST, GPIO_OUT);
    gpio_put(PIN_RST, 1);

    gpio_init(PIN_BUSY);
    gpio_set_dir(PIN_BUSY, GPIO_IN);
    
    // SSD1680 Init Sequence
    gpio_put(PIN_RST, 1);
    sleep_ms(20);
    gpio_put(PIN_RST, 0);
    sleep_ms(2);
    gpio_put(PIN_RST, 1);
    sleep_ms(20);
    eink_wait_busy();

    eink_send_cmd(0x12); // SWRESET
    eink_wait_busy();

    eink_send_cmd(0x01); // Driver output control
    eink_send_data(0xF9);
    eink_send_data(0x00);
    eink_send_data(0x00);

    eink_send_cmd(0x11); // Data entry mode
    eink_send_data(0x03);

    eink_send_cmd(0x44); // set Ram-X address start/end position
    eink_send_data(0x00);
    eink_send_data(0x0F);

    eink_send_cmd(0x45); // set Ram-Y address start/end position
    eink_send_data(0x00);
    eink_send_data(0x00);
    eink_send_data(0xF9);
    eink_send_data(0x00);

    eink_send_cmd(0x3C); // BorderWavefrom
    eink_send_data(0x05); 
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

static uint8_t hw_prev_eink[4000] = {0};

void display_send_buffer(const uint8_t* buffer) {
    watchdog_update();
#ifndef EMULATOR
    // Reset RAM addresses
    eink_send_cmd(0x4E); eink_send_data(0x00);
    eink_send_cmd(0x4F); eink_send_data(0x00); eink_send_data(0x00);

    // Write Previous RAM
    eink_send_cmd(0x26);
    for (int i = 0; i < 4000; i++) {
        eink_send_data(hw_prev_eink[i]);
    }

    // Reset RAM addresses again
    eink_send_cmd(0x4E); eink_send_data(0x00);
    eink_send_cmd(0x4F); eink_send_data(0x00); eink_send_data(0x00);

    eink_send_cmd(0x24); // Write New RAM
    for (int ey = 0; ey < 250; ey++) {
        for (int ex_byte = 0; ex_byte < 16; ex_byte++) {
            uint8_t out_byte = 0;
            for (int bit = 0; bit < 8; bit++) {
                int ex = ex_byte * 8 + bit;
                if (ex >= 122) continue; // Out of bounds for 122px

                // Map 250x122 (portrait) back to 128x64 (landscape) scaled 2x.
                int oled_x = ey / 2;
                int oled_y = ex / 2;
                
                int page = oled_y / 8;
                int oled_bit = oled_y % 8;
                int index = page * 128 + oled_x;
                
                uint8_t pixel = (buffer[index] & (1 << oled_bit)) ? 1 : 0;
                
                // SSD1680: 1=white, 0=black. 
                // The OLED logic sets pixel=1 for text. E-Ink wants text black.
                if (pixel == 0) {
                    out_byte |= (1 << (7 - bit)); // Set white bit for background
                }
            }
            eink_send_data(out_byte);
            hw_prev_eink[ey * 16 + ex_byte] = out_byte;
        }
    }
    
    // Trigger display partial update (using 0x04 or 0x0C for SSD1680 partial refresh)
    eink_send_cmd(0x22);
    eink_send_data(0x04); // Partial update sequence
    eink_send_cmd(0x20); // Activate update
    eink_wait_busy();
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
    watchdog_update();
    return getchar_timeout_us(0);
}

uint64_t hw_time_us(void) {
    return time_us_64();
}

void format_double_c(double val, uint8_t* buffer, int max_len, int mode, int places) {
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
        for (int p = 14; p >= 0; p--) {
            int needed = snprintf(NULL, 0, "%.*G", p, val);
            if (needed <= max_chars) {
                snprintf((char*)buffer, max_len, "%.*G", p, val);
                break;
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
    eink_send_cmd(0x10); // Deep Sleep mode
    eink_send_data(0x01);
#endif
}

void hw_display_wake_c(void) {
#ifndef EMULATOR
    // Wake from deep sleep requires hardware reset
    gpio_put(PIN_RST, 1);
    sleep_ms(20);
    gpio_put(PIN_RST, 0);
    sleep_ms(2);
    gpio_put(PIN_RST, 1);
    sleep_ms(20);
    eink_wait_busy();

    eink_send_cmd(0x12); // SWRESET
    eink_wait_busy();
    
    // Re-initialize registers
    eink_send_cmd(0x01); // Driver output control
    eink_send_data(0xF9);
    eink_send_data(0x00);
    eink_send_data(0x00);

    eink_send_cmd(0x11); // Data entry mode
    eink_send_data(0x03);

    eink_send_cmd(0x44); // set Ram-X address start/end position
    eink_send_data(0x00);
    eink_send_data(0x0F);

    eink_send_cmd(0x45); // set Ram-Y address start/end position
    eink_send_data(0x00);
    eink_send_data(0x00);
    eink_send_data(0xF9);
    eink_send_data(0x00);

    eink_send_cmd(0x3C); // BorderWavefrom
    eink_send_data(0x05);
#endif
}
