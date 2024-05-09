#include <sys.h>

uint8_t* memcpy(uint8_t* dst, const uint8_t* src, int32_t cnt)
{
	int32_t i = 0;

	for (; i < cnt; ++i)
		dst[i] = src[i];

	return dst;
}

uint8_t* memset(uint8_t* dst, uint8_t val, int32_t cnt)
{
	int32_t i = 0;

	for (; i < cnt; ++i)
		dst[i] = val;

	return dst;
}

uint16_t* memsetw(uint16_t* dst, uint16_t val, int32_t cnt)
{
	int32_t i = 0;

	for (; i < cnt; ++i)
		dst[i] = val;

	return dst;
}

int32_t strlen(const int8_t* str)
{
	int32_t i = 0;

	while (str[i] != (int8_t)0)
		++i;

	return i;
}

uint8_t inb(uint16_t port)
{
	uint8_t ret;
	__asm__ __volatile__ ("inb %1, %0" : "=a" (ret) : "dN" (port));
	return ret;
}

void outb(uint16_t port, uint8_t data)
{
	__asm__ __volatile__ ("outb %1, %0" : : "dN" (port), "a" (data));
}
