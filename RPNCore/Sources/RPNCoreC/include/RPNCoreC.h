#ifndef RPNCOREC_H
#define RPNCOREC_H

#include <stdint.h>

void format_double_c(double val, uint8_t* buffer, int max_len, int mode, int places, int use_comma);
int format_input_buffer_c(const uint8_t* in_buf, int in_len, const uint8_t* exp_buf, int exp_len, uint8_t* out_buf, int max_out_len, int use_comma);

#endif
