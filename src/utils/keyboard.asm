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

;; QWERTY Table
qwerty:
	db "0",0xF,"1234567890-=",0xF,0xF
	db "qwertyuiop"
	db "[]",0xD,0x11
	db "asdfghjkl;'"
	db "`","\\"
	db "zxcvbnm,./"
	db 0xF,"*",0x12,0x20,0xF,0xF
