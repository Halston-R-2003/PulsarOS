#ifndef __ISRS_H__
#define __ISRS_H__

#include <types.h>

struct regs
{
	uint32_t gs, fs, es, ds;
	uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax;
	uint32_t int_no, err_code;
	uint32_t eip, cs, eflags, useresp, ss;
};

extern void isrs_init();

#endif /* __ISRS_H__ */
