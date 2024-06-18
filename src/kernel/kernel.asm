[BITS 16]
[ORG 0x1000]

jmp _start_rm

%include "src/utils/rm.asm"

_start_rm:
	;; Set Data Segment
	xor ax, ax
	mov ds, ax

	;; Disable Interrupts
	cli

	;; Load GDT
	lgdt [GDT64]

	;; Switch To Protected Mode
	mov eax, cr0
	or al, 0b1
	mov cr0, eax

	mov eax, cr0
	and eax, 0b01111111111111111111111111111111
	mov cr0, eax

	jmp (CODE_SEG-GDT64):_start_pm

[BITS 32]

_start_pm:
	;; Update Segments
	mov ax, DATA_SEG-GDT64
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	;; Activate PAE
	mov eax, cr4
	or eax, 0b100000
	mov cr4, eax

	;; Clean Pages
	mov edi, 0x70000
	mov ecx, 0x10000
	xor eax, eax
	rep stosd

	;; Update Pages
	mov dword [0x70000], 0x71000+7
	mov dword [0x71000], 0x72000+7
	mov dword [0x72000], 0x73000+7

	mov edi, 0x73000
	mov eax, 7
	mov ecx, 256

	.make_page_entries:
		stosd
		add edi, 4
		add eax, 0x1000
		loop .make_page_entries
	
	;; Update MSR
	mov ecx, 0xC0000080
	rdmsr
	or eax, 0b100000000
	wrmsr

	;; Copy PML4 Address Into CR3 Register
	mov eax, 0x70000
	mov cr3, eax

	;; Switch To Long Mode
	mov eax, cr0
	or eax, 0b10000000000000000000000000000000
	mov cr0, eax

	jmp (LONG_SEG-GDT64):_start_lm

[BITS 64]

%include "src/kernel/shell.asm"

_start_lm:
	call _start_shell

GDT64:
	NULL_SEG:
		dw GDT_LENGTH
		dw GDT64
		dd 0x0
	
	CODE_SEG:
		dw 0xFFFF
		db 0x0,0x0,0x0
		db 0b10011010
		db 0b11001111
		db 0x0
	
	DATA_SEG:
		dw 0xFFFF
		db 0x0,0x0,0x0
		db 0b10010010
		db 0b10001111
		db 0x0
	
	LONG_SEG:
		dw 0xFFFF
		db 0x0,0x0,0x0
		db 0b10011010
		db 0b10101111
		db 0x0

	GDT_LENGTH:

;; Fill Sector
times 2560-($-$$) db 0
