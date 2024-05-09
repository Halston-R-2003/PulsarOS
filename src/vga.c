#include <sys.h>
#include <vga.h>

uint16_t* vga_mem_ptr;
int32_t vga_attribute = 0x0F;
int32_t vga_cursor_x = 0;
int32_t vga_cursor_y = 0;

void vga_scroll()
{
	unsigned blank, tmp;
	blank = 0x20 | (vga_attribute << 8);

	if (vga_cursor_y >= 25)
	{
		tmp = vga_cursor_y - 25 + 1;

		memcpy(vga_mem_ptr, vga_mem_ptr + tmp * 80, (25 - tmp) * 80 * 2);
		memsetw(vga_mem_ptr + (25 - tmp) * 80, blank, 80);

		vga_cursor_y = 25 - 1;
	}
}

void vga_move_cursor()
{
	unsigned tmp;
	tmp = vga_cursor_y * 80 + vga_cursor_x;

	outb(0x3D4, 14);
	outb(0x3D5, tmp >> 8);
	outb(0x3D4, 15);
	outb(0x3D5, tmp);
}

void vga_clear()
{
	unsigned blank;
	int32_t i;
	blank = 0x20 | (vga_attribute << 8);

	for (i = 0; i < 25; ++i)
		memsetw(vga_mem_ptr + i * 80, blank, 80);

	vga_cursor_x = 0;
	vga_cursor_y = 0;

	vga_move_cursor();
}

void vga_putc(uint8_t c)
{
	uint16_t* where;
	unsigned att = vga_attribute << 8;

	if (c == 0x08)
	{
		/* BACKSPACE */
		if (vga_cursor_x != 0) vga_cursor_x--;
	}
	else if (c == 0x09)
	{
		/* TAB */
		vga_cursor_x = (vga_cursor_x + 8) & ~(8 - 1);
	}
	else if (c == '\r')
	{
		/* CARRIAGE RETURN */
		vga_cursor_x = 0;
	}
	else if (c == '\n')
	{
		/* NEW LINE */
		vga_cursor_x = 0;
		vga_cursor_y++;
	}
	else if (c >= ' ')
	{
		where = vga_mem_ptr + (vga_cursor_y * 80 + vga_cursor_x);
		*where = c | att;
		vga_cursor_x++;
	}

	if (vga_cursor_x >= 80)
	{
		vga_cursor_x = 0;
		vga_cursor_y++;
	}

	vga_scroll();
	vga_move_cursor();
}

void vga_puts(uint8_t* str)
{
	int32_t i;
	int32_t len = strlen(str);

	for (i = 0; i < len; ++i)
		vga_putc(str[i]);
}

void vga_set_text_color(uint8_t fg, uint8_t bg)
{
	vga_attribute = (bg << 4) | (fg & 0x0F);
}

void vga_init()
{
	vga_mem_ptr = (uint16_t*)0xB8000;
	vga_clear();
}
