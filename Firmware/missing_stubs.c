#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

#include <stdio.h>
int posix_memalign(void **memptr, size_t alignment, size_t size) {
    *memptr = malloc(size);
    if (*memptr == NULL) {
        printf("posix_memalign OOM: size=%zu align=%zu\n", size, alignment);
    }
    return 0;
}



void putchar_c(int ch) {
    putchar(ch);
    if (ch == '\n' || ch == 10) {
        fflush(stdout);
    }
}

int getentropy(void *buffer, size_t length) {
    return 0;
}

void* _swift_stdlib_getNormData() { return NULL; }
void* _swift_stdlib_getGraphemeBreakProperty() { return NULL; }
int _swift_stdlib_isLinkingConsonant() { return 0; }
void* _swift_stdlib_getBinaryProperties() { return NULL; }

void* _swift_stdlib_getSpecialMapping() { return NULL; }
void* _swift_stdlib_getMapping() { return NULL; }
void* _swift_stdlib_getComposition() { return NULL; }
void* _swift_stdlib_getDecompositionEntry() { return NULL; }
void* _swift_stdlib_getNumericType() { return NULL; }
const uint32_t _swift_stdlib_nfd_decompositions[1] = {0};

// Atomic stubs for ARM Cortex M0+ (no hardware atomics)
// Safe for single-core operation
__attribute__((weak)) uint32_t __atomic_load_4(volatile void *mem, int model) {
    return *(volatile uint32_t *)mem;
}
__attribute__((weak)) void __atomic_store_4(volatile void *mem, uint32_t val, int model) {
    *(volatile uint32_t *)mem = val;
}
__attribute__((weak)) uint32_t __atomic_fetch_add_4(volatile void *mem, uint32_t val, int model) {
    uint32_t old = *(volatile uint32_t *)mem;
    *(volatile uint32_t *)mem = old + val;
    return old;
}
__attribute__((weak)) uint32_t __atomic_fetch_sub_4(volatile void *mem, uint32_t val, int model) {
    uint32_t old = *(volatile uint32_t *)mem;
    *(volatile uint32_t *)mem = old - val;
    return old;
}
__attribute__((weak)) int __atomic_compare_exchange_4(volatile void *mem, void *expected, uint32_t desired, int weak, int success, int failure) {
    uint32_t old = *(volatile uint32_t *)mem;
    uint32_t exp = *(uint32_t *)expected;
    if (old == exp) {
        *(volatile uint32_t *)mem = desired;
        return 1;
    } else {
        *(uint32_t *)expected = old;
        return 0;
    }
}

#include <math.h>

double c_abs(double x) {
    return fabs(x);
}

double c_floor(double x) {
    return floor(x);
}
