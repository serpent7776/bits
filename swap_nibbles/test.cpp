#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <inttypes.h>

#include "swap.hpp"

int fail(uint64_t x, uint8_t l, uint8_t h, uint64_t expected, uint64_t actual, size_t line)
{
	fprintf(stderr, "mismatch at line %" PRIu64 " for swap_nibbles(%" PRIu64 ", %" PRIu8 ", %" PRIu8 "): expected %" PRIu64 ", actual %" PRIu64 "\n", line, x, l, h, expected, actual);
	return 1;
}

int test_swap(uint64_t x, uint8_t l, uint8_t h, uint64_t expected, size_t line)
{
	const uint64_t actual = swap_nibbles(x, l, h);
	if (actual != expected) return fail(x, l, h, expected, actual, line);
	return 0;
}

#define TEST(x, l, h, expected) \
	test_swap(x, l, h, expected, __LINE__)

int main()
{
	int r = 0;
	r |= TEST(0, 0, 0,  0);
	r |= TEST(0xFF, 0, 1,  0xFF);
	r |= TEST(0b1111'0000, 0, 1,  0b0000'1111);
	r |= TEST(0b1010'1010, 1, 0,  0b1010'1010);
	r |= TEST(0b1010'1010, 1, 0,  0b1010'1010);
	r |= TEST(0b0000'0010, 1, 0,  0b0010'0000);
	r |= TEST(0b0000'0010'0011'1100, 1, 0,  0b0000'0010'1100'0011);
	r |= TEST(0b0000'0010'0011'1100, 3, 1,  0b0011'0010'0000'1100);
	r |= TEST(0b0000'0010'0011'1100, 1, 1,  0b0000'0010'0011'1100);
	r |= TEST(0b0000'0010'0011'1100, 1, 1,  0b0000'0010'0011'1100);
	r |= TEST(0b1110'1010'0000'1100'0001'1010'0101'1001, 7, 0,  0b1001'1010'0000'1100'0001'1010'0101'1110);
	r |= TEST(0b1110'1010'0000'1100'0001'1010'0101'1001, 4, 3,  0b1110'1010'0000'0001'1100'1010'0101'1001);
	r |= TEST(0b1110'1001'0110'1001'0011'1110'1100'1111'1100'1111'1001'1010'0011'0000'0101'1011, 12, 1,  0b1110'1001'0110'0101'0011'1110'1100'1111'1100'1111'1001'1010'0011'0000'1001'1011);
	r |= TEST(0b1110'1001'0110'1001'0011'1110'1100'1111'1100'1111'1001'1010'0011'0000'0101'1011, 15, 14,  0b1001'1110'0110'1001'0011'1110'1100'1111'1100'1111'1001'1010'0011'0000'0101'1011);
	return r;
}
