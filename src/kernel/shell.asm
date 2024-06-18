%include "src/utils/macro.asm"
%include "src/utils/utils.asm"
%include "src/utils/keyboard.asm"
%include "src/utils/console.asm"
%include "src/utils/cmd.asm"

_start_shell:
	call clear_cmd

	call goto_next_line

	mov r8, cmd_line
	mov r9, cmd_line_len
	call print_norm

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
		call goto_next_line

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

			mov rbx, cmd_not_found_str
			mov dl, STYLE(BG_BLACK, FG_RED)
			call puts

		.end:
			mov qword [current_input_len], 0

			call goto_next_line

			;; Display command line
			mov r8, cmd_line
			mov r9, cmd_line_len
			call print_norm

			jmp .start_user_input

current_input_len:
	dq 0
current_input_str:
	times 32 db 0

os_title_head:
	db "                              PulsarOS v0.0.0.0023                              ",0

STRING cmd_line, "> "
STRING cmd_not_found_str, "Command not found!"
