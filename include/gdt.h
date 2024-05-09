#ifndef __GDT_H__
#define __GDT_H__

#include <types.h>

extern void gdt_init();
extern void gdt_set_gate(int32_t num, unsigned long base, unsigned long limit, uint8_t access, uint8_t gran);

#endif /* __GDT_H__ */
