#ifndef __IRQ_H__
#define __IRQ_H__

#include <types.h>

extern void irq_init();
extern void irq_install_handler(int32_t irq, void* handler);
extern void irq_uninstall_handler(int32_t irq);

#endif /* __IRQ_H__ */
