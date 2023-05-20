#include <stdint.h>

inline uint64_t swap_nibbles(uint64_t x, uint8_t l, uint8_t h)
{
    const uint64_t mask = 0x0f;
    const uint64_t lsize = l * 4;
    const uint64_t hsize = h * 4;
    const uint64_t lmask = mask << lsize;
    const uint64_t hmask = mask << hsize;
    const uint64_t lval = (x & lmask) >> lsize;
    const uint64_t hval = (x & hmask) >> hsize;
    x = (x & ~lmask) | (hval << lsize);
    x = (x & ~hmask) | (lval << hsize);
    return x;
}
