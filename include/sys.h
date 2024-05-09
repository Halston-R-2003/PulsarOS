#ifndef __SYS_H__
#define __SYS_H__

#include <types.h>

/* Kernel System */
extern uint8_t* memcpy(uint8_t* dst, const uint8_t* src, int32_t cnt);
extern uint8_t* memset(uint8_t* dst, uint8_t val, int32_t cnt);
extern uint16_t* memsetw(uint16_t* dst, uint16_t val, int32_t cnt);
extern int32_t strlen(const int8_t* str);
extern uint8_t inb(uint16_t port);
extern void outb(uint16_t port, uint8_t data);

#endif /* __SYS_H__ */
