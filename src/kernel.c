#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

void kernel_main(void)
{
	*((int*)0xB8000) = 0x0F340F36;
	*((int*)0xB8004) = 0x0F200F20;
	while (1);
}
