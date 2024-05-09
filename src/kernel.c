#include <sys.h>
#include <vga.h>

int32_t kernel_main(void)
{
	vga_init();
	vga_set_text_color(0xA, 0x0);
	vga_puts("VGA Initialized!\n");
	vga_set_text_color(0xB, 0x1);
	vga_puts("PulsarOS v0.0.0.0002\n");
	vga_set_text_color(0xF, 0x0);

	for (;;);
	return 0;
}
