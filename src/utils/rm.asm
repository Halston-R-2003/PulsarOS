[BITS 16]

put_newln_rm:
	mov ah, 0x0E

	mov al, 0x0A
	int 0x10

	mov al, 0x0D
	int 0x10

	ret

puts_rm:
	mov ah, 0x0E

	.loop:
		lodsb
		cmp al, 0
		je .done
		int 0x10
		jmp .loop
	
	.done:
		call put_newln_rm
		ret

wait_for_key:
	mov al, 0xD2
	out 0x64, al

	mov al, 0x80
	out 0x60, al

	.key_up:
		in al, 0x60
		and al, 0b10000000
		jnz .key_up
	
	.key_dn:
		in al, 0x60
	
	ret
