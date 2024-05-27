[BITS 16]
[ORG 0x1000]

jmp _start_rm

%include "src/utils/rm.asm"

%define FG_BLACK 0x0
%define FG_BLUE 0x1
%define FG_GREEN 0x2
%define FG_CYAN 0x3
%define FG_RED 0x4
%define FG_PINK 0x5
%define FG_ORANGE 0x6
%define FG_WHITE 0x7

%define BG_BLACK 0x0
%define BG_BLUE 0x1
%define BG_GREEN 0x2
%define BG_CYAN 0x3
%define BG_RED 0x4
%define BG_PINK 0x5
%define BG_ORANGE 0x6
%define BG_WHITE 0x7

%define STYLE(fg,bg) ((fg<<4)+bg)

%macro PRINT_B 3
	mov rdi, TRAM
	mov rbx, %1
	mov dl, STYLE(%2,%3)
	call puts
%endmacro

%macro PRINT_P 3
	mov rbx, %1
	mov dl, STYLE(%2,%3)
	call puts
%endmacro

_start_rm:
	;; Set Data Segment
	xor ax, ax
	mov ds, ax

	mov si, kernel_head_top
	call puts_rm

	mov si, kernel_head_mid
	call puts_rm

	mov si, kernel_head_bot
	call puts_rm

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

_start_lm:
	call clear_screen

	mov qword [current_row], 1
	call set_current_pos

	PRINT_P cmd_line, BG_BLACK, FG_WHITE
	mov qword [current_col], 2

	.start_user_input:
		call get_key
		
		;; User pressed ENTER key
		cmp al, 28
		je .cmd_entered

		call key_to_ascii

		;; Store Entered Char
		mov r8, [current_input_len]
		mov byte [current_input_str + r8], al
		inc r8
		mov [current_input_len], r8

		call set_current_pos
		stosb

		;; Go To Next Column
		mov r13, [current_col]
		inc r13
		mov [current_col], r13

		jmp .start_user_input
	
	.cmd_entered:
		;; Go to next line
		mov rax, [current_row]
		inc rax
		mov [current_row], rax

		mov qword [current_col], 0

		;; Zero-terminate input string
		mov r8, [current_input_len]
		mov byte [current_input_str+r8], 0

		mov r8, [cmd_table]
		xor r9, r9

		.start:
			cmp r9, r8
			je .cmd_not_found

			mov rsi, current_input_str
			mov r10, r9
			shl r10, 4
			mov rdi, [r10+cmd_table+8]

		.next_char:
			mov al, [rsi]
			mov bl, [rdi]

			cmp al, 0
			jne .compare

			cmp bl, 0
			jne .compare

			mov r10, r9
			inc r10
			shl r10, 4

			call [cmd_table+r10]

			jmp .end

		.compare:
			cmp al, 0
			je .next_cmd

			cmp bl, 0
			je .next_cmd

			cmp al, bl
			jne .next_cmd

			inc rsi
			inc rdi

			jmp .next_char

		.next_cmd:
			inc r9
			jmp .start

		.cmd_not_found:
			call set_current_pos
			PRINT_P cmd_not_found_str, BG_BLACK, FG_RED

		.end:
			mov qword [current_input_len], 0

			;; Go to next line
			mov rax, [current_row]
			inc rax
			mov [current_row], rax

			mov qword [current_col], 0

			;; Diplay command line
			call set_current_pos
			PRINT_P cmd_line, BG_BLACK, FG_WHITE

			mov qword [current_col], 2

			jmp .start_user_input

;; Functions

;; Set RDI to current position based on current row and column
set_current_pos:
	push rax
	push rbx

	;; Line offset
	mov rax, [current_row]
	mov rbx, 0x14*8
	mul rbx

	;; Column offset
	mov rbx, [current_col]
	shl rbx, 1

	lea rdi, [rax+rbx+TRAM]

	pop rbx
	pop rax

	ret

key_to_ascii:
	and eax, 0xFF

	mov al, [eax+qwerty]

	ret

get_key:
	mov al, 0xD2
	out 0x64, al

	mov al, 0x80
	out 0x60, al

	.key_up:
		in al, 0x60
		and al, 0b10000000
		jnz .key_up
	
	in al, 0x60

	ret

clear_screen:
	PRINT_B os_title_head, BG_BLUE, FG_CYAN

	mov rdi, TRAM+0x14*8

	mov rcx, 0x14*24
	mov rax, 0x0F000F000F000F00
	rep stosq

	ret

puts:
	push rax

	.loop:
		mov al, [rbx]
		cmp al, 0
		je .done
		stosb
		mov al, dl
		stosb
		inc rbx
		jmp .loop
	
	.done:
		pop rax
		ret

osinfo_cmd:
	call set_current_pos
	PRINT_P osinfo_cmd_str, BG_BLACK, FG_GREEN
	ret

reboot_cmd:
	in al, 0x64
	or al, 0xFE
	out 0x64, al
	mov al, 0xFE
	out 0x64, al

	ret

clear_cmd:
	call clear_screen

	mov rax, [current_row]
	xor rax, rax
	mov [current_row], rax

	mov qword [current_col], 2

	call set_current_pos

	ret

;; Data
current_row:
	dq 0
current_col:
	dq 0

current_input_len:
	dq 0
current_input_str:
	times 32 db 0

;; Command Table
cmd_table:
	dq 3 ; # of commands

	dq osinfo_cmd_str
	dq osinfo_cmd

	dq reboot_cmd_str
	dq reboot_cmd

	dq clear_cmd_str
	dq clear_cmd

kernel_head_top:
	db "********************************************************************************",0
kernel_head_mid:
	db "*                             PulsarOS v0.0.0.0020                             *",0
kernel_head_bot:
	db "********************************************************************************",0

os_title_head:
	db "                              PulsarOS v0.0.0.0020                              ",0
cmd_line:
	db "> ",0

osinfo_cmd_str:
	db "osinfo",0
reboot_cmd_str:
	db "reboot",0
clear_cmd_str:
	db "clear",0

cmd_not_found_str:
	db "Command not found!",0

TRAM equ 0xB8000
VRAM equ 0xA0000

;; QWERTY Table
qwerty:
	db "0",0xF,"1234567890-=",0xF,0xF
	db "qwertyuiop"
	db "[]",0xD,0x11
	db "asdfghjkl;'"
	db "`","\\"
	db "zxcvbnm,./"
	db 0xF,"*",0x12,0x20,0xF,0xF

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
times 1536-($-$$) db 0
