#include <stdio.h>
#include <stdint.h>

void test_sub() {
    volatile double a = 7.0;
    volatile double b = 9.0;
    double c = a - b;
    union { double d; uint64_t i; } u;
    u.d = c;
    printf("C TEST: 7.0 - 9.0 = %f (hex: %016llx)\n", c, u.i);
}

double c_sub(double a, double b) {
    return a - b;
}
