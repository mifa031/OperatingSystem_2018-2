[ORG 0x00]
[BITS 16]

SECTION .text

jmp 0x07C0:START

START:
    mov ax, 0x07C0
    mov ds, ax
    mov ax, 0xB800
    mov es, ax

    mov si, 0

.SCREENCLEARLOOP:
    mov byte [ es: si ], 0
    mov byte [ es: si + 1 ], 0x0A

    add si, 2
    cmp si, 80 * 25 * 2

    jl .SCREENCLEARLOOP

    mov si, 0
    mov di, 0 


.MESSAGE1LOOP:                ;print message1
    mov cl, byte[si+MESSAGE1]

    cmp cl, 0                 ;if message1 end, print message2
    je .MESSAGE2LOOP

    mov byte[es:di], cl
    
    add si, 1
    add di, 2
    
    jmp .MESSAGE1LOOP


.MESSAGE2LOOP:                ;init index to print message2
    mov si, 0
    mov di, 160
.MESSAGE2LOOPI:               ;print meesage2
    mov cl, byte[si+MESSAGE2]

    cmp cl, 0
    je .MESSAGE3LOOP          ;if message2 end, print message3

    mov byte[es:di], cl

    add si, 1
    add di, 2

    jmp .MESSAGE2LOOPI


.MESSAGE3LOOP:
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
    mov byte[es:di+1], 0x0A
    mov byte[es:di+2], ah
    mov byte[es:di+3], 0x0A
.BCDTOASCII_MIN:
    mov al, cl
    mov ah, al
    and ax, 0xf00f
    shr ah, 0x04
    or ax, 0x3030
    xchg al, ah
.PRINT_MIN:
    mov byte[es:di+4], ':'
    mov byte[es:di+5], 0x0A
    mov byte[es:di+6], al
    mov byte[es:di+7], 0x0A
    mov byte[es:di+8], ah
    mov byte[es:di+9], 0x0A
.BCDTOASCII_SEC:
    mov al, dh
    mov ah, al
    and ax, 0xf00f
    shr ah, 0x04
    or ax, 0x3030
    xchg al, ah
.PRINT_SEC:
    mov byte[es:di+10], ':'
    mov byte[es:di+11], 0x0A
    mov byte[es:di+12], al
    mov byte[es:di+13], 0x0A
    mov byte[es:di+14], ah
    mov byte[es:di+15], 0x0A

    mov si, 0
    mov di, 320
.MESSAGE3LOOPI:                ;print message3
    mov cl, byte[si+MESSAGE3]

    cmp cl, 0
    je .MESSAGEEND

    mov byte[es:di], cl

    add si, 1
    add di, 2

    jmp .MESSAGE3LOOPI


.MESSAGEEND:
    jmp $


MESSAGE1:   db 'MINT64 OS Boot Loader Start~!!', 0
MESSAGE2:   db 'Current Time: ', 0
MESSAGE3:   db 'OS Image Loading...Complete~!!', 0

times 510 - ( $ - $$ )    db    0x00

db 0x55
db 0xAA