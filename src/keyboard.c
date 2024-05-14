#include <sys.h>
#include <vga.h>
#include <irq.h>
#include <keyboard.h>

struct keyboard_states
{
	uint32_t shift : 1;
	uint32_t alt : 1;
	uint32_t ctrl : 1;
} keyboard_state;

typedef void (*keyboard_handler_t)(int32_t scancode);

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

int8_t keyboard_us_l2[128] = 
{
	0,27,
	'!','@','#','$','%','^','&','*','(',')',
	'_','+','\b',
	'\t',
	'Q','W','E','R','T','Y','U','I','O','P','{','}','\n',
	0,
	'A','S','D','F','G','H','J','K','L',':','"','~',
	0,
	'|','Z','X','C','V','B','N','M','<','>','?',
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

void norm(int32_t scancode)
{
	if (scancode & 0x80)
		return;

	if (!keyboard_us[scancode])
		return;

	if (keyboard_state.shift)
		vga_putc(keyboard_us_l2[scancode]);
	else if (keyboard_state.ctrl)
	{
		vga_putc('^');
		vga_putc(keyboard_us_l2[scancode]);
	}
	else
		vga_putc(keyboard_us[scancode]);
}

void shft(int32_t scancode)
{
	keyboard_state.shift ^= 1;
}

void altk(int32_t scancode)
{
	keyboard_state.alt ^= 1;
}

void ctlk(int32_t scancode)
{
	keyboard_state.ctrl ^= 1;
}

void func(int32_t scancode)
{

}

keyboard_handler_t key_method[] =
{
	NULL,NULL,norm,norm,norm,norm,norm,norm,
	norm,norm,norm,norm,norm,norm,norm,norm,
	norm,norm,norm,norm,norm,norm,norm,norm,
	norm,norm,norm,norm,norm,ctlk,norm,norm,
	norm,norm,norm,norm,norm,norm,norm,norm,
	norm,norm,shft,norm,norm,norm,norm,norm,
	norm,norm,norm,norm,norm,norm,shft,norm,
	altk,norm,NULL,func,func,func,func,func,
	func,func,func,func,func,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,func,
	func,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
};

void keyboard_handler(struct regs* r)
{
	uint8_t scancode;
	scancode = inb(0x60);

	keyboard_handler_t handler;
	handler = key_method[(int32_t)scancode & 0x7F];

	if (handler)
		handler(scancode);
}

void keyboard_init()
{
	irq_install_handler(1, keyboard_handler);
}

void keyboard_wait()
{
	while (inb(0x64) & 2);
}
