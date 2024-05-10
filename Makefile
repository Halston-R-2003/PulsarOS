.PHONY: all clean install run

all: kernel

install: kernel
	mkdir -p isodir/boot/grub
	cp PulsarOS.bin isodir/boot/PulsarOS.bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o PulsarOS.iso isodir

run: kernel
	qemu-system-x86_64 -cdrom PulsarOS.iso

kernel: bootstrap.o link.ld kernel.o sys.o vga.o gdt.o idt.o isrs.o
	i686-elf-gcc -T link.ld -o PulsarOS.bin -ffreestanding -O2 -nostdlib bootstrap.o kernel.o sys.o vga.o gdt.o idt.o isrs.o -lgcc

%.o: src/%.c
	i686-elf-gcc -c $< -o $@ -std=gnu99 -ffreestanding -O2 -Wall -Wextra -I./include

bootstrap.o: src/bootstrap.asm
	nasm -f elf32 src/bootstrap.asm -o bootstrap.o

clean:
	rm -f *.o PulsarOS.bin PulsarOS.iso
	rm -rf isodir
