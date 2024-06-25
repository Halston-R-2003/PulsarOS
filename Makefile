default: PulsarOS.img

KERNEL_SRC=$(wildcard src/kernel/*.asm)
KERNEL_UTILS_SRC=$(wildcard src/utils/*.asm)

pulsar-boot.bin: src/boot/pulsar-boot.asm
	nasm -w+all -fbin -o pulsar-boot.bin src/boot/pulsar-boot.asm

kernel.bin: $(KERNEL_SRC) $(KERNEL_UTILS_SRC)
	nasm -w+all -fbin -o kernel.bin src/kernel/kernel.asm

PulsarOS.img: pulsar-boot.bin kernel.bin
	cat pulsar-boot.bin > PulsarOS.bin
	cat kernel.bin >> PulsarOS.bin
	dd status=noxfer conv=notrunc if=PulsarOS.bin of=PulsarOS.img

start: PulsarOS.img
	qemu-system-x86_64 -enable-kvm -cpu host -fda PulsarOS.img

clean:
	rm -f *.bin
	rm -f PulsarOS.img
