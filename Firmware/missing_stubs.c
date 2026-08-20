#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

#include <stdio.h>
int posix_memalign(void **memptr, size_t alignment, size_t size) {
    *memptr = malloc(size);
    return 0;
}



void putchar_c(int ch) {
    putchar(ch);
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
