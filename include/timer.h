#ifndef __TIMER_H__
#define __TIMER_H__

#include <types.h>

extern void timer_init();
extern int32_t timer_ticks;
extern void timer_wait(int32_t ticks);

#endif /* __TIMER_H__ */
