[ORG 0x00]
[BITS 16]

SECTION .text

jmp 0x07C0:START

;;;;;;;;;;;;;;;;;;;;;;;;;
; Setting OS environment
;;;;;;;;;;;;;;;;;;;;;;;;;
TOTALSECTORCOUNT: dw 1 ; size of MINT64 OS image except bootloader

;;;;;;;;;;;;;;;;;;;;;;;;;
; Code Area
;;;;;;;;;;;;;;;;;;;;;;;;;
START:
    mov ax, 0x07C0
    mov ds, ax
    mov ax, 0xB800
    mov es, ax

    ;set stack environment
    mov ax, 0x0000
    mov ss, ax
    mov sp, 0xFFFE
    mov bp, 0xFFFE

    mov si, 0

.SCREENCLEARLOOP:
    mov byte [ es: si ], 0
    mov byte [ es: si + 1 ], 0x0A

    add si, 2

    cmp si, 80 * 25 * 2
    jl .SCREENCLEARLOOP

;print MESSAGE1
push MESSAGE1
push 0
push 0
call PRINTMESSAGE

;print MESSAGE2
push MESSAGE2
push 1
push 0
call PRINTMESSAGE

;print time 
.PRINT_TIME:
    mov ax, 0
    mov di, 172
.GETTIME:                    ;get time from BIOS interrupt
    mov ah, 02h
    int 1Ah
.BCDTOASCII_HOUR:
    mov ah, ch
	call BCDTOASCII
.PRINT_HOUR:
    mov byte[es:di], ah
    mov byte[es:di+2], al
.BCDTOASCII_MIN:
    mov ah, cl
	call BCDTOASCII
.PRINT_MIN:
    mov byte[es:di+4], ':'
    mov byte[es:di+6], ah
    mov byte[es:di+8], al
.BCDTOASCII_SEC:
    mov ah, dh
	call BCDTOASCII
.PRINT_SEC:
    mov byte[es:di+10], ':'
    mov byte[es:di+12], ah
    mov byte[es:di+14], al

;print image loading message
push IMAGELOADINGMESSAGE
push 2
push 0
call PRINTMESSAGE

; Loading OS Image
RESETDISK:
    mov ax, 0  ;service number 0 (Reset)
    mov dl, 0  ;drive number 0 (Floppy) 
    int 0x13   ;disk i/o interrupt
    jc HANDLEDISKERROR

    mov si, 0x1000 ;memory address to copy OS image
    mov es, si
	mov fs, si
    mov bx, 0x0000

    mov di, word[TOTALSECTORCOUNT]
READDATA:
    cmp di, 0
    je READEND
    sub di, 0x1

    mov ah, 0x02
    mov al, 0x1
    mov ch, byte[TRACKNUMBER]
    mov cl, byte[SECTORNUMBER]
    mov dh, byte[HEADNUMBER]
    mov dl, 0x00
    int 0x13
    jc HANDLEDISKERROR

   mov dx, si ; temporarily save si to restore later
;;;;
.GET_HASH:
;    mov ax, es
;    mov cx, fs
;    cmp ax, cx
;    jne .NOT_FIRST_READ
;.FIRST_READ:
    mov si, 0x0C
	mov ax, [fs:8]
	mov bx, [fs:0x0A]
	mov [ds:0], ax
	mov [ds:2], bx
;	jmp .HASH_LOOP
;.NOT_FIRST_READ:
;    mov si, 0
;	mov ax, [ds:0]
;	mov bx, [ds:2]
.HASH_LOOP:
    mov cx, [es:si]
    xor ax, cx

    mov cx, [es:si+2]
    xor bx, cx

    add si, 0x04
    cmp si, 0x204
    jne .HASH_LOOP
	
	mov [ds:0], ax
	mov [ds:2], bx
;;;;;
    mov si, dx ; restore si

    add si, 0x0020
    mov es, si

    mov al, byte[SECTORNUMBER]
    add al, 0x01
    mov byte[SECTORNUMBER], al
    cmp al, 19

    jl READDATA

    xor byte[HEADNUMBER], 0x01
    mov byte[SECTORNUMBER], 0x01

    cmp byte[HEADNUMBER], 0x00
    jne READDATA

    add byte[TRACKNUMBER], 0x01
    jmp READDATA
READEND:

;print loading complete message
push LOADINGCOMPLETEMESSAGE
push 2
push 19
call PRINTMESSAGE

.SECURE_BOOT:
    push IMAGE_CHECKING_MESSAGE
	push 3
	push 0
	call PRINTMESSAGE

    mov si, 0
	mov cx, [fs:si]
	mov dx, [fs:si+2]
	mov ax, [ds:si]
	mov bx, [ds:si+2]
.COMPARE_LOWER_HASH:
	xor cx, ax
.COMPARE_UPPER_HASH:
	xor dx, bx

jmp 0x1000:0x04


;;;;;;;;;;;;;;;;;;;;;;;;;
; Function code Area
;;;;;;;;;;;;;;;;;;;;;;;;;
; Function - Handling disk error
; Parameter - none
HANDLEDISKERROR:
    push DISKERRORMESSAGE ; message to print
    push 3  ; Y axis
    push 20 ; X axis
    call PRINTMESSAGE

    jmp $

; Function - Print message
; Parameter - X axis, Y axis, message
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

BCDTOASCII:
    and ax, 0xf00f
	shr ah, 0x04
	or ax, 0x3030
	ret 

;;;;;;;;;;;;;;;;;;;;;;;;;
; Data Area
;;;;;;;;;;;;;;;;;;;;;;;;;
;messages
MESSAGE1:   db 'BootLoader Start', 0
MESSAGE2:   db 'Time: ', 0
IMAGELOADINGMESSAGE:   db 'OS Image Loading...', 0
;IMAGE_CHECKING_MESSAGE: db 'img Check', 0
LOADINGCOMPLETEMESSAGE: db 'Complete', 0
DISKERRORMESSAGE: db 'DiskErr', 0
IMAGE_CHECKING_MESSAGE: db 'OS Image Checking...', 0

;values
SECTORNUMBER: db 0x02
HEADNUMBER: db 0x00
TRACKNUMBER: db 0x00

;rest
times 510 - ( $ - $$ )    db    0x00

db 0x55
db 0xAA
