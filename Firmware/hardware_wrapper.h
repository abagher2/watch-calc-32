#pragma once
#include <stdint.h>
#include <stdbool.h>

void hw_init(void);
void display_send_buffer(const uint8_t* buffer);
uint64_t matrix_scan(void);
void sleep_ms_c(uint32_t ms);
int get_uart_char_c(void);
void format_double_c(double val, uint8_t* buffer, int max_len, int mode, int places);
