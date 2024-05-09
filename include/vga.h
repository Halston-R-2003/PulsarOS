#ifndef __VGA_H__
#define __VGA_H__

#include <types.h>

/* VGA Driver */
extern void vga_clear();
extern void vga_putc(uint8_t c);
extern void vga_puts(uint8_t* str);
extern void vga_set_text_color(uint8_t fg, uint8_t bg);
extern void vga_init();

#endif /* __VGA_H__ */
