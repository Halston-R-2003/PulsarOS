;; String Constants
cpuinfo_cmd_str:
	db "cpuinfo",0
reboot_cmd_str:
	db "reboot",0
clear_cmd_str:
	db "clear",0
help_cmd_str:
	db "help",0

STRING cpuinfo_vendor_id, "Vendor ID: "
STRING cpuinfo_stepping, "Stepping: "
STRING cpuinfo_model, "Model: "
STRING cpuinfo_family, "Family: "
STRING cpuinfo_features, "Features: "
STRING cpuinfo_cpu_brand, "CPU Brand: "
STRING cpuinfo_max_frequency, "Max Frequency: "
STRING cpuinfo_current_frequency, "Current Frequency: "
STRING cpuinfo_mmx, "MMX "
STRING cpuinfo_sse, "SSE "
STRING cpuinfo_sse2, "SSE2 "
STRING cpuinfo_sse3, "SSE3 "
STRING cpuinfo_sse4_1, "SSE4_1 "
STRING cpuinfo_sse4_2, "SSE4_2 "
STRING cpuinfo_ht, "HT "

STRING available_cmds, "Available Commands: "
STRING tab, "  "

;; Command Table
cmd_table:
	dq 4 ; # of commands

	dq cpuinfo_cmd_str
	dq cpuinfo_cmd

	dq reboot_cmd_str
	dq reboot_cmd

	dq clear_cmd_str
	dq clear_cmd

	dq help_cmd_str
	dq help_cmd

;; Command Functions
cpuinfo_cmd:
	push rbp
	mov rbp, rsp
	sub rsp, 20

	push rax
	push rbx
	push rcx
	push rdx
	push r10

	mov r8, cpuinfo_vendor_id
	mov r9, cpuinfo_vendor_id_len
	call print_norm

	xor eax, eax
	cpuid

	mov [rsp+0], ebx
	mov [rsp+4], edx
	mov [rsp+8], ecx

	call set_current_pos
	mov rbx, rsp
	mov dl, STYLE(BG_BLACK, FG_WHITE)
	call puts
	call goto_next_line

	mov r8, cpuinfo_cpu_brand
	mov r9, cpuinfo_cpu_brand_len
	call print_norm

	xor r10, r10

	.next:
		mov rax, 0x80000002
		add rax, r10
		cpuid

		mov [rsp+0], eax
		mov [rsp+4], ebx
		mov [rsp+8], ecx
		mov [rsp+12], edx

		mov r8, rsp
		mov r9, 16
		call print_norm

		inc r10
		cmp r10, 3
		jne .next

	call goto_next_line
	mov r8, cpuinfo_stepping
	mov r9, cpuinfo_stepping_len
	call print_norm

	mov eax, 1
	cpuid

	mov r15, rax

	mov r8, r15
	and r8, 0xF

	call set_current_pos
	mov dl, STYLE(BG_BLACK, FG_WHITE)
	call puts

	call goto_next_line
	mov r8, cpuinfo_model
	mov r9, cpuinfo_model_len
	call print_norm

	;; Model ID
	mov r14, r15
	and r14, 0xF0
	shr r14, 4

	;; Family ID
	mov r13, r15
	and r13, 0xF00
	shr r13, 8

	;; Extended Model ID
	mov r12, r15
	and r12, 0xF0000
	shr r12, 12

	;; Extended Family ID
	mov r11, r15
	and r11, 0xFF00000
	shr r11, 16

	mov r8, r14
	mov r8, r12

	call set_current_pos
	mov dl, STYLE(BG_BLACK, FG_WHITE)
	call putint

	call goto_next_line
	mov r8, cpuinfo_family
	mov r9, cpuinfo_family_len
	call print_norm

	mov r8, r13
	add r8, r11
	call set_current_pos
	mov dl, STYLE(BG_BLACK, FG_WHITE)
	call putint

	call goto_next_line
	mov r8, cpuinfo_features
	mov r9, cpuinfo_features_len
	call print_norm

	mov eax, 1
	cpuid

	.mmx:
		mov r15, rdx
		and r15, 1<<23
		cmp r15, 0
		je .sse

		mov r8, cpuinfo_mmx
		mov r9, cpuinfo_mmx_len
		call print_norm
	
	.sse:
		mov r15, rdx
		and r15, 1<<25
		cmp r15, 0
		je .sse2

		mov r8, cpuinfo_sse
		mov r9, cpuinfo_sse_len
		call print_norm
	
	.sse2:
		mov r15, rdx
		and r15, 1<<26
		cmp r15, 0
		je .ht

		mov r8, cpuinfo_sse2
		mov r9, cpuinfo_sse2_len
		call print_norm
	
	.ht:
		mov r15, rdx
		and r15, 1<<28
		cmp r15, 0
		je .sse3

		mov r8, cpuinfo_ht
		mov r9, cpuinfo_ht_len
		call print_norm
	
	.sse3:
		mov r15, rcx
		and r15, 1<<9
		cmp r15, 0
		je .sse4_1

		mov r8, cpuinfo_sse3
		mov r9, cpuinfo_sse3_len
		call print_norm
	
	.sse4_1:
		mov r15, rcx
		and r15, 1<<19
		cmp r15, 0
		je .sse4_2

		mov r8, cpuinfo_sse4_1
		mov r9, cpuinfo_sse4_1_len
		call print_norm

	.sse4_2:
		mov r15, rcx
		and r15, 1<<20
		cmp r15, 0
		je .freq

		mov r8, cpuinfo_sse4_2
		mov r9, cpuinfo_sse4_2_len
		call print_norm
	
	.freq:
		call goto_next_line

		mov r8, cpuinfo_max_frequency
		mov r9, cpuinfo_max_frequency_len
		call print_norm

		mov eax, 0x80000004
		cpuid

		mov [rsp+0], eax
		mov [rsp+4], ebx
		mov [rsp+8], ecx
		mov [rsp+12], edx

		mov rax, rsp

		.next_char:
			mov bl, [rax]
			inc rax
			cmp bl, 0
			jne .next_char

		xor rbx, rbx
		xor rcx, rcx

		mov cl, [rax-5]
		sub rcx, 48
		imul rcx, 10
		add rbx, rcx

		mov cl, [rax-6]
		sub rcx, 48
		imul rcx, 100
		add rbx, rcx

		movzx rcx, byte [rax-8]
		sub rcx, 48
		imul rcx, 1000
		add rbx, rcx

		call set_current_pos
		mov r8, rbx
		mov dl, STYLE(BG_BLACK, FG_WHITE)
		call putint

		call goto_next_line

		mov r8, cpuinfo_current_frequency
		mov r9, cpuinfo_current_frequency_len
		call print_norm

		xor rax, rax
		mov ax, cs
		and ax, 0b11

		cmp ax, 0
		jne .last

		mov ecx, 0xE7
	
	.last:
		pop r10
		pop rdx
		pop rcx
		pop rbx
		pop rax

		sub rsp, 20
		leave
	
	ret

reboot_cmd:
	in al, 0x64
	or al, 0xFE
	out 0x64, al
	mov al, 0xFE
	out 0x64, al

	ret

clear_cmd:
	call set_current_pos
	mov rbx, os_title_head
	mov dl, STYLE(BG_BLUE, FG_CYAN)
	call puts

	mov rdi, TRAM+0x14*8
	mov rcx, 0x14*24
	mov rax, 0x0F000F000F000F00
	rep stosq

	mov qword [current_row], 0
	mov qword [current_col], 0

	ret

help_cmd:
	push r8
	push r9
	push r10
	push r11
	push r12

	mov r8, available_cmds
	mov r9, available_cmds_len
	call print_norm

	mov r12, [cmd_table]
	xor r11, r11

	.loop:
		cmp r11, r12
		je .end

		mov r10, r11
		shl r10, 4

		call goto_next_line

		mov r8, tab
		mov r9, tab_len
		call print_norm

		mov r8, [r10+cmd_table+8]
		mov r9, 1
		call print_norm

		inc r11
		jmp .loop
	
	.end:
		pop r12
		pop r11
		pop r10
		pop r9
		pop r8

		ret
