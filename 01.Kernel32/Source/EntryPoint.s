[ORG 0x4]
[BITS 16]

SECTION .text

START:
    mov ax, 0x1000
    mov ds, ax
	mov ax, 0xB800
    mov es, ax

;	mov cx, 1 ;;; for test	
.INSPECT_LOWER_HASH:
    cmp cx, 0
	jne .IMAGE_CHECK_FAIL
.INSPECT_UPPER_HASH: 
    cmp dx, 0
	je .IMAGE_CHECK_OK
.IMAGE_CHECK_FAIL:
    push (CHECKING_FAIL_MESSAGE - $$ + 0x10004)
	push 3
	push 20
	call PRINTMESSAGE16

    push (LOADED_HASH_MESSAGE - $$ + 0x10004)
	push 4
	push 0
	call PRINTMESSAGE16

.PRINT_HASH:
    mov si, 0
    mov ax, 0x1000
    mov fs, ax

	mov dx, 0
	call GET_HASH_CHAR
.PRINT_HASH1:
	mov byte[es:si+(160*4)+14], ch
	mov byte[es:si+(160*4)+16], cl
	mov byte[es:si+(160*4)+18], bh
	mov byte[es:si+(160*4)+20], bl

    mov dx, 2
    call GET_HASH_CHAR
.PRINT_HASH2:
	mov byte[es:si+(160*4)+22], ch
	mov byte[es:si+(160*4)+24], cl
	mov byte[es:si+(160*4)+26], bh
	mov byte[es:si+(160*4)+28], bl

	push (CACULATED_HASH_MESSAGE - $$ + 0x10004)
	push 5
	push 0
	call PRINTMESSAGE16
    

.PRINT_HASH_CACULATED:
    mov si, 0
    mov ax, 0x07C0
    mov fs, ax

	mov dx, 0
	call GET_HASH_CHAR
.PRINT_HASH3:
	mov byte[es:si+(160*5)+14], ch
	mov byte[es:si+(160*5)+16], cl
	mov byte[es:si+(160*5)+18], bh
	mov byte[es:si+(160*5)+20], bl
	
    mov dx, 2
	call GET_HASH_CHAR
.PRINT_HASH4:
	mov byte[es:si+(160*5)+22], ch
	mov byte[es:si+(160*5)+24], cl
	mov byte[es:si+(160*5)+26], bh
    mov byte[es:si+(160*5)+28], bl


    jmp $


.IMAGE_CHECK_OK:
    push (CHECKING_COMPLETE_MESSAGE - $$ + 0x10004)
	push 3
	push 20
	call PRINTMESSAGE16

   cli
   lgdt [ GDTR -4 ]

   mov eax, 0x4000003B
   mov cr0, eax
;jmp $   
   jmp dword 0x08:(PROTECTEDMODE - $$ + 0x10004)

;;;;;;;;;;;;;;;;;;;;;;
; 16bit fucntion area
;;;;;;;;;;;;;;;;;;;;;;
PRINTMESSAGE16:
    push bp
    mov bp, sp
    push si

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
	pop si
	pop bp
	ret 6

GET_HASH_CHAR: 
   mov di, dx  
.GET_CHAR_1:
	mov ax, [fs:di]
	shr ax, 12
	mov bh, al
	cmp bh, 9
	ja .alpha_1
	add bh, 0x30
	jmp .GET_CHAR_2
.alpha_1:
    add bh, 0x37

.GET_CHAR_2:
	mov ax, [fs:di]
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
	mov ax, [fs:di]
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
	mov ax, [fs:di]
	shl ax, 12
	shr ax, 12
	mov cl, al
	cmp cl, 9
	ja .alpha_4
	add cl, 0x30
	jmp .ftn_end
.alpha_4:
    add cl, 0x37
.ftn_end:
	ret 

CHECKING_COMPLETE_MESSAGE: db 'Ok', 0
CHECKING_FAIL_MESSAGE: db 'Fail', 0
LOADED_HASH_MESSAGE: db 'LHash:', 0
CACULATED_HASH_MESSAGE: db 'CHash:',0

[BITS 32]
PROTECTEDMODE:
   mov ax, 0x10
   mov ds, ax
;jmp $
   mov ss, ax
   mov esp, 0xfffe
   mov ebp, 0xfffe

   push (SWITCHSUCCESSMESSAGE - $$ + 0x10004)
   push 4
   push 0
   call PRINTMESSAGE32

   jmp $

PRINTMESSAGE32:
   push ebp
   mov ebp, esp

   mov eax, dword[ebp+12]
   mov esi, 160
   mul esi
   mov edi, eax

   mov eax, dword[ebp+8]
   mov esi, 2
   mul esi
   add edi, eax

   mov esi, dword[ebp+16]

.MESSAGELOOP:
   mov cl, byte[esi]

   cmp cl, 0
   je .MESSAGEEND

   mov byte[edi+0xb8000], cl

   add esi, 1
   add edi, 2

   jmp .MESSAGELOOP

.MESSAGEEND:
   pop ebp
   ret 12

align 8, db 0


dw 0x0000
GDTR:
   dw GDTEND -GDT -1
   dd (GDT - $$ + 0x10004)
GDT:
   NULLDescriptor:
      dw 0x0000
      dw 0x0000
      db 0x00
      db 0x00
      db 0x00
      db 0x00
   CODEDESCRIPTOR:
      dw 0xFFFF
	  dw 0x0000
	  db 0x00
	  db 0x9A
	  db 0xCF
	  db 0x00
   DATADESCRIPTOR:
      dw 0xFFFF
	  dw 0x0000
	  db 0x00
	  db 0x92
	  db 0xCF
	  db 0x00
GDTEND:


SWITCHSUCCESSMESSAGE: db 'ProtectMode',0

times 508 - ($- $$) db 0x00 
