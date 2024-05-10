#include <sys.h>
#include <vga.h>
#include <gdt.h>
#include <idt.h>
#include <isrs.h>

int32_t kernel_main(void)
{
	vga_init();
	vga_set_text_color(0xA, 0x0);
	vga_puts("VGA Initialized!\n");

	gdt_init();
	vga_puts("GDT Initialized!\n");

	idt_init();
	vga_puts("IDT Initialized!\n");

	isrs_init();
	vga_puts("ISRs Initialized!\n");

	vga_clear();
	vga_set_text_color(0xB, 0x1);
	vga_puts("PulsarOS v0.0.0.0006\n");

	for (int32_t i = 0; i < 16; ++i)
	{
		vga_set_text_color(i, i);
		vga_puts(' ');
	}
	vga_puts("\n");

	for (;;);
	return 0;
}
