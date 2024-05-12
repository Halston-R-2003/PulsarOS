#include <sys.h>
#include <vga.h>
#include <irq.h>

void timer_phase(int32_t hz)
{
	int32_t div = 1193180 / hz;

	outb(0x43, 0x36);
	outb(0x40, div & 0xFF);
	outb(0x40, div >> 8);
}

int32_t timer_ticks = 0;
unsigned long ticker = 0;

void timer_handler(struct regs* r)
{
	++timer_ticks;

	if (timer_ticks % 18 == 0)
	{
		ticker++;
		vga_puts("Tick...");
		
		if (ticker % 4 == 0)
			vga_putc('|');
		else if (ticker % 4 == 1)
			vga_putc('/');
		else if (ticker % 4 == 2)
			vga_putc('-');
		else if (ticker % 4 == 3)
			vga_putc('\\');

		vga_putc('\n');
	}
}

void timer_init()
{
	irq_install_handler(0, timer_handler);
}

void timer_wait(int32_t ticks)
{
	unsigned long eticks;
	eticks = timer_ticks + ticks;

	while (timer_ticks < eticks);
}
