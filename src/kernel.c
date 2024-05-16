#include <sys.h>
#include <vga.h>
#include <gdt.h>
#include <idt.h>
#include <isrs.h>
#include <irq.h>
#include <timer.h>
#include <keyboard.h>
#include <kprintf.h>

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
	keyboard_init();

	// Display OS Name & Version as well as Test VGA Colors
	vga_set_text_color(0xB, 0x1);
	vga_puts("PulsarOS v0.0.0.0012\n");

	for (int32_t i = 0; i < 16; ++i)
	{
		vga_set_text_color(i, i);
		vga_puts(' ');
	}
	vga_puts("\n");

	vga_set_text_color(0xF, 0x0);

	kprintf("Testing kprintf...\n");

	int8_t* test_str = "QWERTY";
	kprintf("%s\n", test_str);

	int32_t test_num = 5000;
	kprintf("%d\n", test_num);

	int32_t test_hex = 0xB00755AA;
	kprintf("%x\n", test_hex);

	for (;;);
	return 0;
}
