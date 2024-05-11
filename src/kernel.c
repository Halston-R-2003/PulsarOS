#include <sys.h>
#include <vga.h>
#include <gdt.h>
#include <idt.h>
#include <isrs.h>
#include <irq.h>

int32_t kernel_main(void)
{
	// Initialization
	vga_init();
	gdt_init();
	idt_init();
	isrs_init();
	irq_init();

	// Display OS Name & Version as well as Test VGA Colors
	vga_set_text_color(0xB, 0x1);
	vga_puts("PulsarOS v0.0.0.0008\n");

	for (int32_t i = 0; i < 16; ++i)
	{
		vga_set_text_color(i, i);
		vga_puts(' ');
	}
	vga_puts("\n");

	for (;;);
	return 0;
}
