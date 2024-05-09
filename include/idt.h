#ifndef __IDT_H__
#define __IDT_H__

#include <types.h>

void idt_init();
void idt_set_gate(uint8_t num, unsigned long base, uint16_t sel, uint8_t flags);

#endif /* __IDT_H__ */
