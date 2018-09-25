[ORG 0x00]
[BITS 16]

SECTION .text

jmp 0x1001:START

SECTORCOUNT: dw 0x0000

START:
    mov ax, cs
	mov ds, ax
	mov ax, 0xB800
	mov es, ax

	push IMAGE_CHECKING_MESSAGE
	push 3
	push 0
	call PRINTMESSAGE

;	mov cx, 1 ;;; for test. occuring error
.INSPECT_LOWER_HASH:
    cmp cx, 0
	jne .IMAGE_CHECK_FAIL
.INSPECT_UPPER_HASH: 
    cmp dx, 0
	je .IMAGE_CHECK_OK
.IMAGE_CHECK_FAIL:
    push CHECKING_FAIL_MESSAGE
	push 3
	push 20
	call PRINTMESSAGE

    push LOADED_HASH_MESSAGE
	push 4
	push 0
	call PRINTMESSAGE

.PRINT_HASH_LOADED:
    mov si, 0
    mov ax, 0x1000
    mov fs, ax
.GET_CHAR_1:
	mov ax, [fs:si]
	shr ax, 12
	mov bh, al
	cmp bh, 9
	ja .alpha_1
	add bh, 0x30
	jmp .GET_CHAR_2
.alpha_1:
    add bh, 0x37

.GET_CHAR_2:
	mov ax, [fs:si]
	shl ax, 4
	shr ax, 12
	mov bl, al
	cmp bl, 9
	ja .alpha_2
	add bl, 0x30
	jmp .GET_CHAR_3
.alpha_2:
    add bl, 0x37

.GET_CHAR_3:
	mov ax, [fs:si]
	shl ax, 8
	shr ax, 12
	mov ch, al
	cmp ch, 9
	ja .alpha_3
	add ch, 0x30
	jmp .GET_CHAR_4
.alpha_3:
    add ch, 0x37

.GET_CHAR_4:
	mov ax, [fs:si]
	shl ax, 12
	shr ax, 12
	mov cl, al
	cmp cl, 9
	ja .alpha_4
	add cl, 0x30
	jmp .PRINT_HASH1
.alpha_4:
    add cl, 0x37

.PRINT_HASH1:
	mov byte[es:si+(160*4)+38], ch
	mov byte[es:si+(160*4)+40], cl
	mov byte[es:si+(160*4)+42], bh
	mov byte[es:si+(160*4)+44], bl
	
	mov ax, 0
	mov cx, 0
	mov bx, 0

.GET_CHAR_5:
    mov ax, [fs:si+2]
	shr ax, 12
	mov bh, al
	cmp bh, 9
	ja .alpha_5
	add bh, 0x30
	jmp .GET_CHAR_6
.alpha_5:
    add bh, 0x37

.GET_CHAR_6:
    mov ax, [fs:si+2]
	shl ax, 4
	shr ax, 12
	mov bl, al
	cmp bl, 9
	ja .alpha_6
	add bl, 0x30
	jmp .GET_CHAR_7
.alpha_6:
    add bl, 0x37

.GET_CHAR_7:
    mov ax, [fs:si+2]
	shl ax, 8
	shr ax, 12
	mov ch, al
	cmp ch, 9
	ja .alpha_7
	add ch, 0x30
	jmp .GET_CHAR_8
.alpha_7:
    add ch, 0x37

.GET_CHAR_8:
    mov ax, [fs:si+2]
	shl ax, 12
	shr ax, 12
	mov cl, al
	cmp cl, 9
	ja .alpha_8
	add cl, 0x30
	jmp .PRINT_HASH2
.alpha_8:
    add cl, 0x37

.PRINT_HASH2:
	mov byte[es:si+(160*4)+46], ch
	mov byte[es:si+(160*4)+48], cl
	mov byte[es:si+(160*4)+50], bh
	mov byte[es:si+(160*4)+52], bl

;;;;;;;;;;;;;;
    
	push CACULATED_HASH_MESSAGE 
	push 5
	push 0
	call PRINTMESSAGE

.PRINT_HASH_CACULATED:
    mov si, 0
    mov ax, 0x1000
    mov fs, ax
.GET_CHAR_9:
	mov ax, [fs:si+4]
	shr ax, 12
	mov bh, al
	cmp bh, 9
	ja .alpha_9
	add bh, 0x30
	jmp .GET_CHAR_10
.alpha_9:
    add bh, 0x37

.GET_CHAR_10:
	mov ax, [fs:si+4]
	shl ax, 4
	shr ax, 12
	mov bl, al
	cmp bl, 9
	ja .alpha_10
	add bl, 0x30
	jmp .GET_CHAR_11
.alpha_10:
    add bl, 0x37

.GET_CHAR_11:
	mov ax, [fs:si+4]
	shl ax, 8
	shr ax, 12
	mov ch, al
	cmp ch, 9
	ja .alpha_11
	add ch, 0x30
	jmp .GET_CHAR_12
.alpha_11:
    add ch, 0x37

.GET_CHAR_12:
	mov ax, [fs:si+4]
	shl ax, 12
	shr ax, 12
	mov cl, al
	cmp cl, 9
	ja .alpha_12
	add cl, 0x30
	jmp .PRINT_HASH3
.alpha_12:
    add cl, 0x37

.PRINT_HASH3:
	mov byte[es:si+(160*5)+46], ch
	mov byte[es:si+(160*5)+48], cl
	mov byte[es:si+(160*5)+50], bh
	mov byte[es:si+(160*5)+52], bl
	
	mov ax, 0
	mov cx, 0
	mov bx, 0

.GET_CHAR_13:
    mov ax, [fs:si+6]
	shr ax, 12
	mov bh, al
	cmp bh, 9
	ja .alpha_13
	add bh, 0x30
	jmp .GET_CHAR_14
.alpha_13:
    add bh, 0x37

.GET_CHAR_14:
    mov ax, [fs:si+6]
	shl ax, 4
	shr ax, 12
	mov bl, al
	cmp bl, 9
	ja .alpha_14
	add bl, 0x30
	jmp .GET_CHAR_15
.alpha_14:
    add bl, 0x37

.GET_CHAR_15:
    mov ax, [fs:si+6]
	shl ax, 8
	shr ax, 12
	mov ch, al
	cmp ch, 9
	ja .alpha_15
	add ch, 0x30
	jmp .GET_CHAR_16
.alpha_15:
    add ch, 0x37

.GET_CHAR_16:
    mov ax, [fs:si+6]
	shl ax, 12
	shr ax, 12
	mov cl, al
	cmp cl, 9
	ja .alpha_16
	add cl, 0x30
	jmp .PRINT_HASH4
.alpha_16:
    add cl, 0x37

.PRINT_HASH4:
	mov byte[es:si+(160*5)+54], ch
	mov byte[es:si+(160*5)+56], cl
	mov byte[es:si+(160*5)+58], bh
	mov byte[es:si+(160*5)+60], bl

    jmp $

		
.IMAGE_CHECK_OK:
    push CHECKING_COMPLETE_MESSAGE
	push 3
	push 20
	call PRINTMESSAGE

	push PROTECTED_MODE_MESSAGE
	push 4
	push 0
	call PRINTMESSAGE

	push KERNEL_START_MESSAGE
	push 5
	push 0
	call PRINTMESSAGE
	
	jmp $

;;;;;;;;;;;;;;;;;;;;;;;;;
; Function code Area
;;;;;;;;;;;;;;;;;;;;;;;;;
PRINTMESSAGE:
    push bp
    mov bp, sp

    push es
    push si
    push di
    push ax
    push cx

    mov ax, 0xB800
    mov es, ax

    ; get line address using Y axis param
    mov ax, word[bp+6]
    mov si, 160
    mul si
    mov di, ax

    ;get line address using X axis param
    mov ax, word[bp+4]
    mov si, 2
    mul si
    add di, ax

    ;get message address using message param
    mov si, word[bp+8]

.MESSAGELOOP:
    mov cl, byte[si]

    cmp cl, 0
    je .MESSAGEEND

    mov byte[es:di], cl

    add si, 1
    add di, 2

    jmp .MESSAGELOOP

.MESSAGEEND:
    pop cx
	pop ax
	pop di
	pop si
	pop es
	pop bp
	ret 6



;;;;;;;;;;;;;;;;;;;;;;;;;
; Data Area
;;;;;;;;;;;;;;;;;;;;;;;;;
;messages
IMAGE_CHECKING_MESSAGE: db 'OS Image Checking...', 0
CHECKING_COMPLETE_MESSAGE: db 'Okay~!!', 0
CHECKING_FAIL_MESSAGE: db 'Fail~!!', 0
PROTECTED_MODE_MESSAGE: db 'Switch To Protected Mode Success~!!', 0
KERNEL_START_MESSAGE: db 'C Language Kernel Started~!!', 0
LOADED_HASH_MESSAGE: db 'Loaded Hash Value: ', 0
CACULATED_HASH_MESSAGE: db 'Calculated Hash Value: ',0
