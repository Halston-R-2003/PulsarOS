#include <sys.h>
#include <vga.h>
#include <irq.h>
#include <keyboard.h>

int8_t keyboard_us[128] =
{
	0, 27,
	'1','2','3','4','5','6','7','8','9','0','-','=','\b',
	'\t',
	'q','w','e','r','t','y','u','i','o','p','[',']','\n',
	0,
	'a','s','d','f','g','h','j','k','l',';','\'','`',
	0,
	'\\','z','x','c','v','b','n','m',',','.','/',
	0,
	'*',
	0,
	' ',
	0,
	0,
	0,0,0,0,0,0,0,0,
	0,
	0,
	0,
	0,
	0,
	0,
	'-',
	0,
	0,
	0,
	'+',
	0,
	0,
	0,
	0,
	0,
	0,0,0,
	0,
	0,
	0,
};

void keyboard_handler(struct regs* r)
{
	uint8_t scancode;
	scancode = inb(0x60);
	
	if (scancode & 0x80)
	{

	}
	else
		vga_putc(keyboard_us[scancode]);
}

void keyboard_init()
{
	irq_install_handler(1, keyboard_handler);
}

void keyboard_wait()
{
	while (inb(0x64) & 2);
}
