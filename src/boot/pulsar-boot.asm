[BITS 16]

jmp _start_rm

%include "src/utils/rm.asm"

;; Boot Code
_start_rm:
	mov ah, 0x00
	mov al, 0x03
	int 0x10

	mov ax, 0x7C0
	add ax, 288
	mov ss, ax
	mov sp, 4096

	mov ax, 0x7C0
	mov ds, ax

	mov si, boot_head_top
	call puts_rm

	mov si, boot_head_mid
	call puts_rm

	mov si, boot_head_bot
	call puts_rm

	mov si, press_key_msg
	call puts_rm

	;; Enable A20 Gate
	in al, 0x92
	or al, 2
	out 0x92, al

	;; Wait for a key
	call wait_for_key

	mov si, load_kernel_msg
	call puts_rm

	BASE equ 0x100
	SECTORS equ 0x20

	;; Reset Disk
	xor ax, ax
	xor ah, ah
	mov dl, 0
	int 0x13

	jc disk_reset_failed

	mov ax, BASE
	mov es, ax
	xor bx, bx

	mov ah, 0x2
	mov al, SECTORS
	xor ch, ch
	mov cl, 2
	xor dh, dh
	mov dl, [boot_device]
	int 0x13

	jc disk_read_failed

	jmp dword BASE:0x0

disk_reset_failed:
	mov si, err_disk_reset_failed
	call puts_rm
	jmp err_end

disk_read_failed:
	mov si, err_disk_read_failed
	call puts_rm

err_end:
	mov si, err_kernel_load_failed
	call puts_rm

	jmp $

;; Data
boot_head_top:
	db "***********************",0
boot_head_mid:
	db "* PulsarOS Bootloader *",0
boot_head_bot:
	db "***********************",0

press_key_msg:
	db "Press any key to load the Kernel...",0
load_kernel_msg:
	db "Attempting to load Kernel...",0

err_disk_reset_failed:
	db "ERROR: Disk Reset Failed!",0
err_disk_read_failed:
	db "ERROR: Disk Read Failed!",0
err_kernel_load_failed:
	db "ERROR: Kernel Loading Failed!",0

boot_device:
	db 0

;; Bootloader Magic
times 510-($-$$) db 0
dw 0xAA55
