default: PulsarOS.img

pulsar-boot.bin: src/boot/pulsar-boot.asm
	nasm -fbin -o pulsar-boot.bin src/boot/pulsar-boot.asm

kernel.bin:
	nasm -fbin -o kernel.bin src/kernel/kernel.asm

PulsarOS.img: pulsar-boot.bin kernel.bin
	cat pulsar-boot.bin > PulsarOS.bin
	cat kernel.bin >> PulsarOS.bin
	dd status=noxfer conv=notrunc if=PulsarOS.bin of=PulsarOS.img

start: PulsarOS.img
	qemu-system-i386 -fda PulsarOS.img

clean:
	rm -f *.bin
	rm -f PulsarOS.img
