#include <sys.h>
#include <gdt.h>

struct gdt_entry
{
	uint16_t limit_low;
	uint16_t base_low;
	uint8_t base_middle;
	uint8_t access;
	uint8_t granularity;
	uint8_t base_high;
} __attribute__((packed));

struct gdt_ptr
{
	uint16_t limit;
	uint32_t base;
} __attribute__((packed));

struct gdt_entry gdt[3];
struct gdt_ptr gdtp;

extern void gdt_load();

void gdt_set_gate(int32_t num, unsigned long base, unsigned long limit, uint8_t access, uint8_t gran)
{
	/* GDT Base Address */
	gdt[num].base_low = (base & 0xFFFF);
	gdt[num].base_middle = (base >> 16) & 0xFF;
	gdt[num].base_high = (base >> 24) & 0xFF;

	/* GDT Limits */
	gdt[num].limit_low = (limit & 0xFFFF);
	gdt[num].granularity = (limit >> 16) & 0x0F;

	/* GDT Granularity */
	gdt[num].granularity |= (gran & 0xF0);

	/* GDT Access Flags */
	gdt[num].access = access;

}

void gdt_init()
{
	/* GDT Pointer and Limits */
	gdtp.limit = (sizeof(struct gdt_entry) * 3) - 1;
	gdtp.base = &gdt;

	/* GDT NULL */
	gdt_set_gate(0, 0, 0, 0, 0);

	/* GDT Code Segment */
	gdt_set_gate(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);

	/* GDT Data Segment */
	gdt_set_gate(2, 0, 0xFFFFFFFF, 0x92, 0xCF);

	/* Load the GDT! */
	gdt_load();
}
