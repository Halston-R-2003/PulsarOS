#include <sys.h>
#include <idt.h>

struct idt_entry
{
	uint16_t base_low;
	uint16_t sel;
	uint8_t zero;
	uint8_t flags;
	uint16_t base_high;
} __attribute__((packed));

struct idt_ptr
{
	uint16_t limit;
	uint32_t base;
} __attribute__((packed));

struct idt_entry idt[256];
struct idt_ptr idtp;

extern void idt_load();

void idt_set_gate(uint8_t num, unsigned long base, uint16_t sel, uint8_t flags)
{
	idt[num].base_low = (base & 0xFFFF);
	idt[num].base_high = (base >> 16) & 0xFFFF;
	idt[num].sel = sel;
	idt[num].zero = 0;
	idt[num].flags = flags;
}

void idt_init()
{
	idtp.limit = (sizeof(struct idt_entry) * 256) - 1;
	idtp.base = &idt;
	memset(&idt, 0, sizeof(struct idt_entry) * 256);

	idt_load();
}
