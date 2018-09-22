[ORG 0x00]
[BITS 16]

SECTION .text

jmp 0x07C0:START

;;;;;;;;;;;;;;;;;;;;;;;;;
; Setting OS environment
;;;;;;;;;;;;;;;;;;;;;;;;;
TOTALSECTORCOUNT: dw 1024 ; size of MINT64 OS image except bootloader

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
add sp, 6

;print MESSAGE2
push MESSAGE2
push 1
push 0
call PRINTMESSAGE
add sp, 6

;print time 
.PRINT_TIME:
    mov ax, 0
    mov di, 188
.GETTIME:                    ;get time from BIOS interrupt
    mov ah, 02h
    int 1Ah
.BCDTOASCII_HOUR:
    mov al, ch
    mov ah, al
    and ax, 0xf00f
    shr ah, 0x04
    or ax, 0x3030
    xchg al, ah
.PRINT_HOUR:
    mov byte[es:di], al
    mov byte[es:di+2], ah
.BCDTOASCII_MIN:
    mov al, cl
    mov ah, al
    and ax, 0xf00f
    shr ah, 0x04
    or ax, 0x3030
    xchg al, ah
.PRINT_MIN:
    mov byte[es:di+4], ':'
    mov byte[es:di+6], al
    mov byte[es:di+8], ah
.BCDTOASCII_SEC:
    mov al, dh
    mov ah, al
    and ax, 0xf00f
    shr ah, 0x04
    or ax, 0x3030
    xchg al, ah
.PRINT_SEC:
    mov byte[es:di+10], ':'
    mov byte[es:di+12], al
    mov byte[es:di+14], ah

;print image loading message
push IMAGELOADINGMESSAGE
push 2
push 0
call PRINTMESSAGE
add sp, 6

; Loading OS Image
RESETDISK:
    mov ax, 0  ;service number 0 (Reset)
    mov dl, 0  ;drive number 0 (Floppy) 
    int 0x13   ;disk i/o interrupt
    jc HANDLEDISKERROR

    mov si, 0x1000 ;memory address to copy OS image
    mov es, si
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
add sp, 6

jmp 0x1000:0x0000


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
    push dx

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
    pop dx
    pop cx
    pop ax
    pop di
    pop si
    pop es
    pop bp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;
; Data Area
;;;;;;;;;;;;;;;;;;;;;;;;;
;messages
MESSAGE1:   db 'MINT64 OS Boot Loader Start~!!', 0
MESSAGE2:   db 'Current Time: ', 0
IMAGELOADINGMESSAGE:   db 'OS Image Loading...', 0
LOADINGCOMPLETEMESSAGE: db 'Complete~!!', 0
DISKERRORMESSAGE: db 'Disk Error~!!', 0

;values
SECTORNUMBER: db 0x02
HEADNUMBER: db 0x00
TRACKNUMBER: db 0x00

;rest
times 510 - ( $ - $$ )    db    0x00

db 0x55
db 0xAA