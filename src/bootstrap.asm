extern kernel_main

section .bss
align 4096

pml4t:
	resb 4096

pdpt:
	resb 4096

pdt:
	resb 4096

stack_bottom:
	resb 128
stack_top:

section .rodata

PRESENT equ 1<<7
NOT_SYS equ 1<<4
EXEC equ 1<<3
DC equ 1<<2
RW equ 1<<1
ACCESSED equ 1<<0

GRAN_4K equ 1<<7
SZ_32 equ 1<<6
LONG_MODE equ 1<<5

GDT:
	.Null: equ $-GDT
		dq 0
	.Code: equ $-GDT
		dd 0xFFFF
		db 0
		db PRESENT | NOT_SYS | EXEC | RW
		db GRAN_4K | LONG_MODE | 0xF
		db 0
	.Data: equ $-GDT
		dd 0xFFFF
		db 0
		db PRESENT | NOT_SYS | RW
		db GRAN_4K | SZ_32 | 0xF
		db 0
	.TSS: equ $-GDT
		dd 0x00000068
		dd 0x00CF8900
	.Pointer:
		dw $-GDT-1
		dq GDT

global _start

section .text
[BITS 32]

check_multiboot:
	cmp eax, 0x36D76289
	jne no_multiboot
	ret
no_multiboot:
	mov al, "0"
	jmp error

check_cpuid:
	pushfd
	pop eax
	
	mov ecx, eax
	xor eax, 1<<21

	push eax
	popfd

	pushfd
	pop eax

	push ecx
	popfd

	xor eax, ecx
	jz NoCPUID
	ret
NoCPUID:
	mov al, "1"
	jmp error

check_longmode:
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb no_longmode

	mov eax, 0x80000001
	cpuid
	test edx, 1<<29
	jz no_longmode
	ret
no_longmode:
	mov al, "2"
	jmp error

_start:
	mov esp, stack_top
	call check_multiboot

	call check_cpuid

	call check_longmode

pagetable_setup:
	mov eax, pdpt
	or eax, 0b11
	mov [pml4t], eax

	mov eax, pdt
	or eax, 0b11
	mov [pdpt], eax

	xor ecx, ecx

direct_map_pdte:
	mov eax, 0x200000
	mul ecx
	or eax, 0b10000011
	mov [pdt+ecx*8], eax
	inc ecx
	cmp ecx, 512
	jne direct_map_pdte

	mov eax, pml4t
	mov cr3, eax

enable_pae_bit:
	mov eax, cr4
	or eax, 1<<5
	mov cr4, eax

set_efer_msr:
	mov ecx, 0xC0000080
	rdmsr
	or eax, 1<<8
	wrmsr

enable_paging:
	mov eax, cr0
	or eax, 1<<31
	mov cr0, eax

load_gdt:
	lgdt [GDT.Pointer]
	jmp GDT.Code:enter_longmode_success
	jmp error

[BITS 64]
enter_longmode_success:
	cli
	mov ax, GDT.Data
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov rax, 0x2F592F412F4B2F4F
	mov qword [0xB8000], rax
	call kernel_main

[BITS 32]
error:
	mov dword [0xB8000], 0x4F524F45
	mov dword [0xB8004], 0x4F3A4F52
	mov dword [0xB8008], 0x4F204F20
	mov byte [0xB800A], al
	cli
	jmp $
