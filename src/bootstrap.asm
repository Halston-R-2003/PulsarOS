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

;; IDT
global idt_load
extern idtp

idt_load:
	lidt [idtp]
	ret

;; ISRs
global _isr0
global _isr1
global _isr2
global _isr3
global _isr4
global _isr5
global _isr6
global _isr7
global _isr8
global _isr9
global _isr10
global _isr11
global _isr12
global _isr13
global _isr14
global _isr15
global _isr16
global _isr17
global _isr18
global _isr19
global _isr20
global _isr21
global _isr22
global _isr23
global _isr24
global _isr25
global _isr26
global _isr27
global _isr28
global _isr29
global _isr30
global _isr31

;; Divide By Zero
_isr0:
	cli
	push byte 0
	push byte 0
	jmp isr_common_stub

;; Debug
_isr1:
	cli
	push byte 0
	push byte 1
	jmp isr_common_stub

;; Non-Maskable Interrupt
_isr2:
	cli
	push byte 0
	push byte 2
	jmp isr_common_stub

;; INT 3
_isr3:
	cli
	push byte 0
	push byte 3
	jmp isr_common_stub

;; INTO
_isr4:
	cli
	push byte 0
	push byte 4
	jmp isr_common_stub

;; Out of Bounds
_isr5:
	cli
	push byte 0
	push byte 5
	jmp isr_common_stub

;; Invalid Opcode
_isr6:
	cli
	push byte 0
	push byte 6
	jmp isr_common_stub

;; Coprocessor Not Available
_isr7:
	cli
	push byte 0
	push byte 7
	jmp isr_common_stub

;; Double Fault (Error Code)
_isr8:
	cli
	push byte 8
	jmp isr_common_stub

;; Coprocessor Segment Overrun
_isr9:
	cli
	push byte 0
	push byte 9
	jmp isr_common_stub

;; Bad TSS (Error Code)
_isr10:
	cli
	push byte 10
	jmp isr_common_stub

;; Segment Not Present (Error Code)
_isr11:
	cli
	push byte 11
	jmp isr_common_stub

;; Stack Fault (Error Code)
_isr12:
	cli
	push byte 12
	jmp isr_common_stub

;; General Protection Fault (Error Code)
_isr13:
	cli
	push byte 13
	jmp isr_common_stub

;; Page Fault (Error Code)
_isr14:
	cli
	push byte 14
	jmp isr_common_stub

;; Reserved
_isr15:
	cli
	push byte 0
	push byte 15
	jmp isr_common_stub

;; Floating Point
_isr16:
	cli
	push byte 0
	push byte 16
	jmp isr_common_stub

;; Alignment Check
_isr17:
	cli
	push byte 0
	push byte 17
	jmp isr_common_stub

;; Machine Check
_isr18:
	cli
	push byte 0
	push byte 18
	jmp isr_common_stub

;; Reserved
_isr19:
	cli
	push byte 0
	push byte 19
	jmp isr_common_stub

;; Reserved
_isr20:
	cli
	push byte 0
	push byte 20
	jmp isr_common_stub

;; Reserved
_isr21:
	cli
	push byte 0
	push byte 21
	jmp isr_common_stub

;; Reserved
_isr22:
	cli
	push byte 0
	push byte 22
	jmp isr_common_stub

;; Reserved
_isr23:
	cli
	push byte 0
	push byte 23
	jmp isr_common_stub

;; Reserved
_isr24:
	cli
	push byte 0
	push byte 24
	jmp isr_common_stub

;; Reserved
_isr25:
	cli
	push byte 0
	push byte 25
	jmp isr_common_stub

;; Reserved
_isr26:
	cli
	push byte 0
	push byte 26
	jmp isr_common_stub

;; Reserved
_isr27:
	cli
	push byte 0
	push byte 27
	jmp isr_common_stub

;; Reserved
_isr28:
	cli
	push byte 0
	push byte 28
	jmp isr_common_stub

;; Reserved
_isr29:
	cli
	push byte 0
	push byte 29
	jmp isr_common_stub

;; Reserved
_isr30:
	cli
	push byte 0
	push byte 30
	jmp isr_common_stub

;; Reserved
_isr31:
	cli
	push byte 0
	push byte 31
	jmp isr_common_stub

extern isr_handle_fault

isr_common_stub:
	pusha
	push ds
	push es
	push fs
	push gs
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov eax, esp
	push eax
	mov eax, isr_handle_fault
	call eax
	pop eax
	pop gs
	pop fs
	pop es
	pop ds
	popa
	add esp, 8
	iret

section .bss
	resb 8192	; 8MB Memory Reserved
_system_stack:
;; THIS LINE INTENTIONALLY LEFT BLANK
