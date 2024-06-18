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

;; Functions

;; Set RDI to current position based on current row and column
set_current_pos:
	push rax
	push rbx
	push rdx

	;; Line offset
	mov rax, [current_row]
	mov rbx, 0x14*8
	mul rbx

	;; Column offset
	mov rbx, [current_col]
	shl rbx, 1

	lea rdi, [rax+rbx+TRAM]

	pop rdx
	pop rbx
	pop rax

	ret

goto_next_line:
	push rax

	;; Go to next line
	mov rax, [current_row]
	inc rax
	mov [current_row], rax

	;; Start at first column
	mov qword [current_col], 0

	pop rax

	ret

print_norm:
	push rax
	push rbx
	push rdx
	push rdi

	call set_current_pos
	mov rbx, r8
	mov dl, STYLE(BG_BLACK, FG_WHITE)
	call puts

	mov rax, [current_col]
	add rax, r9
	mov [current_col], rax

	pop rdi
	pop rdx
	pop rbx
	pop rax

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

putint:
	push rax
	push rbx
	push rdx
	push r10
	push rsi

	mov rax, r8
	mov r10, rdx

	xor rsi, rsi

	.loop:
		xor rdx, rdx
		mov rbx, 10
		div rbx
		add rdx, 48

		push rdx
		inc rsi

		cmp rax, 0
		jne .loop
	
	.next:
		cmp rsi, 0
		je .exit
		dec rsi

		pop rax
		stosb

		mov rdx, r10
		mov al, dl
		stosb

		jmp .next
	
	.exit:
		pop rsi
		pop r10
		pop rdx
		pop rbx
		pop rax

		ret

;; Data
current_row:
	dq 0
current_col:
	dq 0

TRAM equ 0xB8000
VRAM equ 0xA0000
