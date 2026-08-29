#include "include/RPNCoreC.h"
#include <stdio.h>
#include <string.h>

void format_double_c(double val, uint8_t* buffer, int max_len, int mode, int places, int use_comma) {
    int is_negative = 0;
    if (val < 0.0) {
        is_negative = 1;
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
    } else if (mode == 4) { // SIG
        snprintf((char*)buffer, max_len, "%.*E", places > 0 ? places - 1 : 0, val);
        char* e_ptr = strchr((char*)buffer, 'E');
        if (e_ptr) {
            char sign = e_ptr[1];
            char* digits = e_ptr + 2;
            while (*digits == '0' && *(digits + 1) != ' ') digits++;
            if (sign == '+') {
                memmove(e_ptr + 1, digits, strlen(digits) + 1);
            } else {
                memmove(e_ptr + 2, digits, strlen(digits) + 1);
            }
        }
    } else { // ALL
        int max_chars = max_len - 1;
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
    
    char* e_ptr = strchr((char*)buffer, 'e');
    if (e_ptr) {
        *e_ptr = 'E';
    } else {
        e_ptr = strchr((char*)buffer, 'E');
    }

    if (use_comma) {
        char* d = strchr((char*)buffer, '.');
        if (d) *d = ',';
    }
    
    if (mode == 0) {
        char* dot = strchr((char*)buffer, use_comma ? ',' : '.');
        if (dot) {
            char* end_of_frac = e_ptr ? e_ptr : ((char*)buffer + strlen((char*)buffer));
            char* p = end_of_frac - 1;
            while (p > dot && *p == '0') {
                p--;
            }
            if (p == dot) {
                p--;
            }
            if (e_ptr) {
                memmove(p + 1, e_ptr, strlen(e_ptr) + 1);
            } else {
                *(p + 1) = '\0';
            }
        }
    }

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

    if (mode == 0 || mode == 1) {
        char dec_char = use_comma ? ',' : '.';
        char* dp = strchr((char*)buffer, dec_char);
        if (!dp) dp = (char*)buffer + strlen((char*)buffer);
        
        char* start = (char*)buffer;
        if (*start == '-') start++;
        
        int digits = dp - start;
        if (digits > 3) {
            int commas = (digits - 1) / 3;
            int len = strlen((char*)buffer);
            memmove(dp + commas, dp, len - (dp - (char*)buffer) + 1);
            char* write_ptr = dp + commas - 1;
            char* read_ptr = dp - 1;
            int count = 0;
            while (read_ptr >= start) {
                *write_ptr-- = *read_ptr--;
                count++;
                if (count == 3 && read_ptr >= start) {
                    *write_ptr-- = use_comma ? '.' : ',';
                    count = 0;
                }
            }
        }
    }
}

int format_input_buffer_c(const uint8_t* in_buf, int in_len, const uint8_t* exp_buf, int exp_len, uint8_t* out_buf, int max_out_len, int use_comma) {
    if (in_len == 0 && exp_len == 0) return 0;
    
    char dec_char = use_comma ? ',' : '.';
    char group_char = use_comma ? '.' : ',';
    
    // Find decimal point in input buffer
    int dp_idx = in_len;
    for (int i = 0; i < in_len; i++) {
        if (in_buf[i] == '.' || in_buf[i] == ',') {
            dp_idx = i;
            break;
        }
    }
    
    int start_idx = 0;
    if (in_len > 0 && in_buf[0] == '-') {
        start_idx = 1;
    }
    
    int int_digits = dp_idx - start_idx;
    int commas = (int_digits > 3) ? (int_digits - 1) / 3 : 0;
    
    int total_len = in_len + commas;
    if (exp_len > 0) {
        total_len += 1 + exp_len; // 'E' + exponent
    }
    
    if (total_len >= max_out_len) return 0; // Buffer too small
    
    int out_idx = 0;
    if (start_idx == 1) {
        out_buf[out_idx++] = '-';
    }
    
    int count = 0;
    for (int i = start_idx; i < dp_idx; i++) {
        out_buf[out_idx++] = in_buf[i];
        count++;
        int remaining = int_digits - count;
        if (remaining > 0 && remaining % 3 == 0) {
            out_buf[out_idx++] = group_char;
        }
    }
    
    if (dp_idx < in_len) {
        out_buf[out_idx++] = dec_char;
        for (int i = dp_idx + 1; i < in_len; i++) {
            out_buf[out_idx++] = in_buf[i];
        }
    }
    
    if (exp_len > 0) {
        out_buf[out_idx++] = 'E';
        for (int i = 0; i < exp_len; i++) {
            out_buf[out_idx++] = exp_buf[i];
        }
    }
    
    out_buf[out_idx] = '\0';
    return out_idx;
}
