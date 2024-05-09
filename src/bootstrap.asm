[BITS 32]

global _start
_start:
	mov esp, _system_stack
	jmp _stublet

align 4
mboot:
	;; MULTIBOOT constants
	MULTIBOOT_PAGE_ALIGN equ 1<<0
	MULTIBOOT_MEM_INFO equ 1<<1
	MULTIBOOT_AOUT_KLUDGE equ 1<<16
	MULTIBOOT_MAGIC_NUM equ 0x1BADB002
	MULTIBOOT_HEADER_FLAGS equ MULTIBOOT_PAGE_ALIGN | MULTIBOOT_MEM_INFO | MULTIBOOT_AOUT_KLUDGE
	MULTIBOOT_CHECKSUM equ -(MULTIBOOT_MAGIC_NUM + MULTIBOOT_HEADER_FLAGS)

	extern code, bss, end

	;; GRUB MULTIBOOT Header & Boot Signature
	dd MULTIBOOT_MAGIC_NUM
	dd MULTIBOOT_HEADER_FLAGS
	dd MULTIBOOT_CHECKSUM

	;; To Be Filled In By LINK.LD script
	dd mboot
	dd code
	dd bss
	dd end
	dd _start

;; KERNEL ENTRY POINT
_stublet:
	extern kernel_main
	call kernel_main
	jmp $

;; GDT
global gdt_load
extern gdtp

gdt_load:
	lgdt [gdtp]
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	jmp 0x08:gdt_load_done
gdt_load_done:
	ret

;; TODO: ISRs

section .bss
	resb 8192	; 8MB Memory Reserved
_system_stack:
;; THIS LINE INTENTIONALLY LEFT BLANK
