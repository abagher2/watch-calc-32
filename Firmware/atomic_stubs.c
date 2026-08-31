#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include "pico/sync.h"
#include "pico/stdlib.h"

// RP2040 Pico SDK already defines these via pico_atomic.c. We only need them for RP2350.
#if !defined(PICO_RP2040)

uint32_t __atomic_load_4(volatile void *ptr, int memorder) {
    uint32_t status = save_and_disable_interrupts();
    uint32_t val = *(volatile uint32_t *)ptr;
    restore_interrupts(status);
    return val;
}

void __atomic_store_4(volatile void *ptr, uint32_t val, int memorder) {
    uint32_t status = save_and_disable_interrupts();
    *(volatile uint32_t *)ptr = val;
    restore_interrupts(status);
}

bool __atomic_compare_exchange_4(volatile void *ptr, void *expected, uint32_t desired, bool weak, int success_memorder, int failure_memorder) {
    uint32_t status = save_and_disable_interrupts();
    uint32_t *exp_ptr = (uint32_t *)expected;
    uint32_t current = *(volatile uint32_t *)ptr;
    bool success = false;
    
    if (current == *exp_ptr) {
        *(volatile uint32_t *)ptr = desired;
        success = true;
    } else {
        *exp_ptr = current;
    }
    
    restore_interrupts(status);
    return success;
}

uint32_t __atomic_fetch_add_4(volatile void *ptr, uint32_t val, int memorder) {
    uint32_t status = save_and_disable_interrupts();
    uint32_t current = *(volatile uint32_t *)ptr;
    *(volatile uint32_t *)ptr = current + val;
    restore_interrupts(status);
    return current;
}

uint32_t __atomic_fetch_sub_4(volatile void *ptr, uint32_t val, int memorder) {
    uint32_t status = save_and_disable_interrupts();
    uint32_t current = *(volatile uint32_t *)ptr;
    *(volatile uint32_t *)ptr = current - val;
    restore_interrupts(status);
    return current;
}

#endif // !defined(PICO_RP2040)

int getentropy(void *buffer, size_t length) {
    uint8_t *buf = (uint8_t *)buffer;
    for (size_t i = 0; i < length; i++) buf[i] = 0xAA; 
    return 0;
}

uint32_t _swift_stdlib_getGraphemeBreakProperty(uint32_t c) { return 0; }
uint32_t _swift_stdlib_isLinkingConsonant(uint32_t c) { return 0; }
uint64_t _swift_stdlib_getNormData(uint32_t c) { return 0; }
uint32_t _swift_stdlib_getComposition(uint32_t l, uint32_t r) { return 0; }
void* _swift_stdlib_getSpecialMapping(void* c) { return 0; }
void* _swift_stdlib_getMapping(void* c) { return 0; }
void* _swift_stdlib_getDecompositionEntry(void* c) { return 0; }
void* _swift_stdlib_nfd_decompositions(void* c) { return 0; }

int posix_memalign(void **memptr, size_t alignment, size_t size) {
    extern void* memalign(size_t, size_t);
    void *ptr = memalign(alignment, size);
    if (!ptr) return 12; // ENOMEM
    *memptr = ptr;
    return 0;
}

#include <stdio.h>
void putchar_c(int ch) {
    putchar(ch);
    if (ch == '\n' || ch == 10) fflush(stdout);
}
