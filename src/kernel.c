#include <sys.h>
#include <vga.h>
#include <gdt.h>
#include <idt.h>
#include <isrs.h>
#include <irq.h>
#include <timer.h>

int32_t kernel_main(void)
{
	// Initialization
	vga_init();
	gdt_init();
	idt_init();
	isrs_init();
	irq_init();
	__asm__ __volatile__ ("sti");
	timer_init();

	// Display OS Name & Version as well as Test VGA Colors
	vga_set_text_color(0xB, 0x1);
	vga_puts("PulsarOS v0.0.0.0009\n");

	for (int32_t i = 0; i < 16; ++i)
	{
		vga_set_text_color(i, i);
		vga_puts(' ');
	}
	vga_puts("\n");

	vga_set_text_color(0xF, 0x0);

	for (;;);
	return 0;
}
