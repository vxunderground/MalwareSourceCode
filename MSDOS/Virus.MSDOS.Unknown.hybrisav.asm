.model  tiny
.code
org     100h

start:

jmp short begin_code

copyright db "HYBRiS.1435 Remover. (c) 1995 The Unforgiven/Immortal Riot",0

begin_code:
push    dx                              ; Cool self-check..
push    ds
mov     ah,9
mov     dx,offset intro_msg
int     21h
pop     bx
pop     dx
cmp     bx,dx
jne     wrong
mov     ah,9
mov     dx,offset ok_msg
int     21h
jmp     short start_msg1

wrong:
mov     ah,9
mov     dx,offset wrong_msg
int     21h
int     20h

intro_msg       db 'Selfcheck $'
ok_msg          db 'OK',13,10,'$'
wrong_msg       db 'Failed',13,10,'$'


start_msg1:

mov     ah,9                    ;print starting msg...
mov     dx, offset begin
int     21h

mov     ah,0                    ;did they agree on the rules?
int     16h

cmp     ah,15h                  ;y/Y
je      ok_phile                ;yes, they did

mov     ah,9                    ;print blah..
mov     dx, offset not_yes
int     21h
int     20h
not_yes db "User Failure!",13,10,07,36


ok_phile:
mov     ah,4ah                  ;Do a virus installation check. . .
mov     bx,0ffffh
mov     cx,0d00dh
int     21h

cmp     ax,cx                   ;ax=cx=d00d= the virus is TSR. . .
jne     not_res

mov     ah,9
mov     dx, offset resident
int     21h
int     20h

not_res:
mov     ah,2fh                  ;Get DTA-area to es:bx
int     21h

mov     ah,4eh                  ;find first file matching ds:dx (com)
                                ;with any attribute
next:
mov     cx,7
mov     dx, offset f_com
int     21h

jc      no_com                  ;we have no more com-files

call    main                    ;got a com-file - search it

mov     ah,4fh                  ;get next com-file
jmp     short next

no_com:



terminate:                      ;no more files!

mov     ah,9
mov     dx, offset stat1
int     21h

; This nice statistics is made by Blonde. Greetings to him.

mov     dx, word ptr [count]
call    dec16out

mov     ah,9
mov     dx, offset stat2
int     21h

mov     dx, word ptr [inf]
call    dec16out

mov     ax,4cffh
int     21h

main:
inc     byte ptr [count]

push    ax
push    bx
push    cx
push    dx
push    di
push    si

push    es
push    es
pop     ds
push    cs
pop     es

mov     si,bx
add     si,1Eh                  ;bx = pointer to fname (1eh)
mov     di,offset fname_buf
mov     cx,0Fh                  ;cx=15

push    cx                      ;save cx = 15
push    di                      ;save di (fname)
rep     movsb                   ;rep until cx=0
pop     di                      ;restore di
pop     cx                      ;and set cx=15

xor     al,al                   ;zero out al
cld                             ;Clear direction
repne   scasb                   ;Scan es:[di] for al
push    di                      ;save di
mov     al,20h                  ;
rep     stosb                   ;Store al (fname) to es:[di]

mov     byte ptr es:[di],36     ;'$'

pop     di
pop     es

push    cs
pop     ds

;mov    ah,9                    ;print fname
;mov    dx,offset fname_buf
;int    21h


mov     cx,15                   ;with BIOS function due to this procedure
mov     si, offset fname_buf    ;can be used quite frequently. This is
lup:    lodsb                   ;faster
int     29h                     ;mov ah,0ch, int 10h
loop    lup

mov     ax,3d02h                ;prepare open in read/write access
mov     dx,bx                   ;bx into dx
add     dx,1eh                  ;bx = pointer to fname
push    es                      ;make es=ds
pop     ds
int     21h                     ;do it!
jnc     read_file

mov     ah,9                    ;uerm? we couldnt open the file
mov     dx, offset error_open   ;fucking write-protected.. or lame coding
int     21h                     ;not zoinking f_attribs??
jmp     no_inf

read_file:

mov     bx,ax                   ;place file handle in bx

mov     ah,3fh                  ;read first 4 bytes of the file
mov     cx,4                    ;to a buffer in memory
mov     dx, offset read_buf
int     21h

cmp     byte ptr ds:[read_buf+3],'@' ;4th byte = @?
jne     No_inf

cmp     byte ptr ds:[read_buf],0e9h  ;1st byte = jmp?
jne     no_inf

inc     byte ptr [inf]

mov     ah,9                         ;say that the file is infected
mov     dx, offset is_inf
int     21h

mov     ah,0                         ;wait keypress
int     16h

cmp     ah,15h                       ;y/Y ?
je      remove                       ; => they want to remove it..
jmp     no_inf

remove:
mov     ax,4202h
mov     cx,-1
mov     dx,-4
int     21h

mov     ah,3fh                          ;read those bytes to a buffer
mov     cx,4
mov     dx,offset read_buf
int     21h

mov     ax,4200h                         ;seek the beginning of file
xor     cx,cx
xor     dx,dx
int     21h

mov     ah,40h                          ;write the original bytes to
mov     dx,offset read_buf              ;the top of file
mov     cx,4
int     21h

mov     ax,4202h                        ;seek (filesize-vir_size)
mov     cx,-1
mov     dx,-1435
int     21h

mov     ah,40h                          ;truncate vir_size..
xor     cx,cx
int     21h


mov     ah,9                     ;Report that the file is clean. . .
mov     dx, offset _clean
int     21h
mov     byte ptr [clean_f],1

no_inf:

cmp     byte ptr [clean_f],1
je      skip
mov     ah,9                    ;say that the file is infected
mov     dx, offset is_cle
int     21h

skip:
mov     ah,9                    ;print linefeed instead of
mov     dx, offset linefeed     ;mov byte ptr es:[di-1],13
int     21h                     ;mov byte ptr es:[di],10
                                ;mov byte ptr es:[di+1],36 (see above)
                                ;this is simpler for reporting. . .

mov     ah,3eh                  ;close file
int     21h

pop     si                      ;restore registers in use
pop     si
pop     dx
pop     cx
pop     bx
pop     ax

ret                             ;and return to caller


dec16out:
push    ds                      ;This convertation is
push    di                      ;Blonde(tm)
push    dx
push    cx
push    ax
xor     cx,cx                   ;initialize the counter
lea     di, buf                 ;point to a buffer

dec16out1:
push    cx                      ;save the count
mov     ax,dx                   ;AX is the numerator
xor     dx,dx                   ;clear upper half
mov     cx,10                   ;divisor of 10
div     cx                      ;divide
xchg    ax,dx                   ;get quotient

add     al,30h                  ;increase to ASCII
mov     [di],al                 ;put in byte in ascii-format
inc     di                      ;point to next byte

pop     cx                      ;restore count
inc     cx                      ;count the digit
or      dx,dx                   ;done? (dx=0?)
jnz     dec16out1               ;if not zero, loop until dx = 0

dec16out2:
dec     di                      ;decreasment of di
mov     dl,[di]
mov     ah,2
int     21h                     ;write dl to screen output
loop    dec16out2

pop     ax                       ;restore registers
pop     cx
pop     dx
pop     di
pop     ds
ret                             ;and return


begin:

db "Remover for the HYBRIS virus: This program is free of charge for all users.",13,10
db 'DISCLAIMER: This software is provided "AS IS" without warranty of any kind,',13,10
db "either expressed or implied, including but not limited to the fitness for",13,10
db "any particular purpose. The entire risc as to its quality of performance",13,10
db "is assumed by the user. Agree with those rules [Y/N]",13,10,36

f_com          db       "*.COM",0           ;COM-spec
buf            dw       ?
read_buf       db       ?,?,?,?             ;4 buffers to read into
is_inf         db       "Is infected! Remove it? [Y/N]$ "
_clean         db       " File is now clean....$"
is_cle         db       "is clean...$"
error_open     db       " Error open file$ ";shouldnt happen. . .
resident       db       "Virus is already resident, aborting$"
fname_buf      db       65 dup (?)          ;fname = max 64, but ah well!
linefeed       db       0ah,0dh,'$'         ;linefeed+ end of print marker.
count          dw       0
inf            dw       0
clean_f        db       ?
host_clean     db       "Self-checking OK!",13,10,36
host_infected  db       "Program is infected and will not run$",13,10
stat1          db       13,10
               db       "Number of files scanned: $"
stat2          db       13,10
               db       "Number of files cleaned: $"

end start
================================================================================
