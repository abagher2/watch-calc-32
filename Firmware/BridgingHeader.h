#pragma once

#ifndef EMULATOR
#include "pico/stdlib.h"
#else
#include <stdint.h>
#include <stdbool.h>
#endif
#include "hardware_wrapper.h"
#include <math.h>

int get_uart_char_c();
void putchar_c(int ch);
void putchar_direct_c(int ch);
uint64_t hw_time_us(void);
