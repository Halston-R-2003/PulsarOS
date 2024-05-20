.PHONY: all clean install run

all: kernel

install: kernel
	mkdir -p isodir/boot/grub
	cp PulsarOS.bin isodir/boot/PulsarOS.bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o PulsarOS.iso isodir

run: kernel
	qemu-system-x86_64 -cdrom PulsarOS.iso

kernel: bootstrap.o multiboot.o link.ld kernel.o
	x86_64-elf-gcc -T link.ld -o PulsarOS.bin -shared -ffreestanding -O2 -nostdlib bootstrap.o multiboot.o kernel.o -lgcc -n

%.o: src/%.c
	x86_64-elf-gcc -c $< -o $@ -std=gnu99 -ffreestanding -O2 -Wall -Wextra -I./include

%.o: src/%.asm
	nasm -f elf64 $< -o $@

clean:
	rm -f *.o PulsarOS.bin PulsarOS.iso
	rm -rf isodir
