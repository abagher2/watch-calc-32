#ifndef MISSING_STUBS_H
#define MISSING_STUBS_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

typedef unsigned int uint;

#define GPIO_OUT 1
#define GPIO_IN 0

#define spi0 0

void stdio_init_all(void);
void gpio_init(uint gpio);
void gpio_set_dir(uint gpio, bool out);
void gpio_pull_down(uint gpio);
void gpio_put(uint gpio, bool value);
bool gpio_get(uint gpio);
void watchdog_update(void);
void watchdog_reboot(uint32_t pc, uint32_t sp, uint32_t delay_ms);
void spi_write_blocking(int spi, const uint8_t *src, size_t len);
void wfi(void);
void watchdog_enable(uint32_t delay_ms, bool pause_on_debug);
void sleep_ms(uint32_t ms);
void sleep_us(uint64_t us);
int getchar_timeout_us(uint32_t timeout_us);
uint64_t time_us_64(void);

#endif
