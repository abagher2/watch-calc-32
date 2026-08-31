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
        char temp_buf[32];
        int needed = snprintf(temp_buf, sizeof(temp_buf), "%.*f", places, val);
        int commas = 0;
        char* dp = strchr(temp_buf, '.');
        if (!dp) dp = temp_buf + needed;
        char* start = temp_buf;
        if (*start == '-') start++;
        int digits = dp - start;
        if (digits > 3) commas = (digits - 1) / 3;
        
        if (needed + commas <= max_len - 1) {
            snprintf((char*)buffer, max_len, "%.*f", places, val);
        } else {
            // Fallback to SCI mode if it doesn't fit, but KEEP the number of places!
            mode = 2; 
        }
    }
    
    if (mode == 2 || mode == 3 || mode == 4) {
        int max_chars = max_len - 1;
        int original_places = places;
        
        for (int p = original_places; p >= 0; p--) {
            char temp_buf[64];
            if (mode == 2) {
                snprintf(temp_buf, sizeof(temp_buf), "%.*E", p, val);
            } else if (mode == 3) {
                snprintf(temp_buf, sizeof(temp_buf), "%.*G", p, val);
            } else { // mode == 4
                snprintf(temp_buf, sizeof(temp_buf), "%.*E", p > 0 ? p - 1 : 0, val);
            }
            
            // Clean up exponent in temp_buf
            char* e_ptr = strchr(temp_buf, 'E');
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
            
            if (strlen(temp_buf) <= max_chars) {
                strcpy((char*)buffer, temp_buf);
                break;
            }
        }
    } else if (mode == 0) { // ALL
        int max_chars = max_len - 1;
        double abs_val = val < 0 ? -val : val;
        
        if (abs_val >= 1.0 && abs_val < 1e11 && (abs_val - (int64_t)abs_val) < 1e-9) {
            char temp_buf[32];
            int len = snprintf(temp_buf, sizeof(temp_buf), "%lld", (long long)val);
            int commas = (len > 3 && temp_buf[0] != '-') ? (len - 1) / 3 : ((len > 4 && temp_buf[0] == '-') ? (len - 2) / 3 : 0);
            if (len + commas <= max_chars) {
                snprintf((char*)buffer, max_len, "%lld", (long long)val);
            } else {
                snprintf((char*)buffer, max_len, "%.*E", 11, val);
            }
        } else {
            for (int p = 11; p >= 0; p--) {
                char temp_buf[32];
                int needed = snprintf(temp_buf, sizeof(temp_buf), "%.*G", p, val);
                
                // Calculate commas that will be added to integer part
                int commas = 0;
                char* e_ptr = strchr(temp_buf, 'E');
                if (!e_ptr) e_ptr = strchr(temp_buf, 'e');
                if (!e_ptr) { // Only add commas if not scientific notation
                    char* dp = strchr(temp_buf, '.');
                    if (!dp) dp = temp_buf + needed;
                    char* start = temp_buf;
                    if (*start == '-') start++;
                    int digits = dp - start;
                    if (digits > 3) commas = (digits - 1) / 3;
                }
                
                if (needed + commas <= max_chars) {
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
        char* orig_dp = strchr((char*)buffer, '.');
        if (orig_dp) {
            *orig_dp = use_comma ? ',' : '.';
        }
        
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
    
    if (mode == 2 || mode == 3 || mode == 4) {
        char* orig_dp = strchr((char*)buffer, '.');
        if (orig_dp) {
            *orig_dp = use_comma ? ',' : '.';
        }
    }
}

int format_input_buffer_c(const uint8_t* in_buf, int in_len, const uint8_t* exp_buf, int exp_len, uint8_t* out_buf, int max_out_len, int use_comma) {
    if (in_len == 0 && exp_len == 0) return 0;
    
    char dec_char = use_comma ? ',' : '.';
    char group_char = use_comma ? '.' : ',';
    
    // Find first and second decimal points
    int dp1_idx = -1;
    int dp2_idx = -1;
    for (int i = 0; i < in_len; i++) {
        if (in_buf[i] == '.' || in_buf[i] == ',') {
            if (dp1_idx == -1) dp1_idx = i;
            else if (dp2_idx == -1) dp2_idx = i;
        }
    }
    
    if (dp2_idx != -1) {
        // Fraction mode formatting
        int out_idx = 0;
        
        // Handle negative sign
        int start_idx = 0;
        if (in_len > 0 && in_buf[0] == '-') {
            out_buf[out_idx++] = '-';
            start_idx = 1;
        }
        
        // If first decimal is at start_idx, Integer part is "0"
        if (dp1_idx == start_idx) {
            out_buf[out_idx++] = '0';
        } else {
            for (int i = start_idx; i < dp1_idx; i++) {
                out_buf[out_idx++] = in_buf[i];
            }
        }
        
        // Space between Integer and Numerator
        out_buf[out_idx++] = ' ';
        
        // Numerator
        for (int i = dp1_idx + 1; i < dp2_idx; i++) {
            out_buf[out_idx++] = in_buf[i];
        }
        
        // Slash between Numerator and Denominator
        out_buf[out_idx++] = '/';
        
        // Denominator
        for (int i = dp2_idx + 1; i < in_len; i++) {
            out_buf[out_idx++] = in_buf[i];
        }
        
        out_buf[out_idx] = '\0';
        return out_idx;
    }
    
    // Normal mode formatting
    int dp_idx = dp1_idx != -1 ? dp1_idx : in_len;
    
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
