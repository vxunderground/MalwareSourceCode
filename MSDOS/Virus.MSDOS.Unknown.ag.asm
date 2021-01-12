.286c
.model small
.code
        org     100h
start:

jmp	install

old_si  dw      0
old_bx 	dw	0
old_cx	dw	0
old_dx	dw	0
es_main	dw	0
num_ff	dw	0
last_pag dw	0
viroff	dw	0
count	db	0
scan_seg dw     0
mes db 'Found !','$'
filnm   db      15 dup(0)
buffer  db      'NCMAIN.EXE',0h,0h,0h,0h,0h
	db	'QA.COM',
        db      64 dup (0)

include datagame.inc


int_21h_entry:

        pushf					; Push flags
	sti					; Enable interrupts
	cmp	ah,4Bh				;
        jne     loc_24                          ; Jump if equal
	cmp	al,0
        je      loc_25

loc_24:
	popf					; Pop flags
	db	0EAh
old_21h_off  dw	 ?
old_21h_seg  dw  ?


loc_25:
	mov	cs:old_bx,bx
	push	ax
	push	cx
	push	di
	push	es
        push    ds
        push    si
	push	dx

        mov     si,dx
loc_205:
	inc	si
	cmp byte ptr ds:[si],0
	jne	loc_205
	mov	bh,0
loc_206:
	inc	bh
	dec	si
	cmp byte ptr ds:[si],'\'
	jne	loc_206
	inc	si
	dec	bh
	push	cs
	pop	es
	xor	cx,cx
	mov	bl,-1
loc_94:
        inc     bl
        lea     di,cs:buffer
        mov     ax,15
        mul     bl
        add     di,ax
        push    si
        mov     cl,bh
        rep     cmpsb
        pop     si
        je      loc_57
        cmp     bl,4
        jne     loc_94
        jmp short loc_95

loc_57:
        mov     byte ptr cs:count,0
        jmp     loc_fin

loc_95:
	mov	cl,bh
        lea     di,cs:filnm
        repne movsb
        sub     si,3
        cmp word ptr ds:[si],'XE'
	jne	loc_47
	lea	ax,cs:only_exe
	mov  byte ptr bl,cs:only_exe_count
        jmp short loc_files

loc_47:
        cmp  word ptr ds:[si],'OC'
	je     loc_79
	lea	ax,cs:ov_pi
	mov    byte ptr bl,cs:ov_pi_count
        jmp short loc_files

loc_79:
	lea	ax,cs:com_exe
	mov  byte ptr bl,cs:com_exe_count

loc_files:

	mov	cs:viroff,ax
        mov     byte ptr cs:count,bl

        mov     ah,3dh
	xor	al,al
	int 	21h      ; file is open for reading
	jc	loc_fin

        mov     bx,ax
	mov	ah,42h
	xor	cx,cx
	mov	dx,cx
	mov	al,2
	int	21h	; seek to the end

       	mov	cs:num_ff,dx	  ; save number of 64k
	mov	cs:last_pag,ax    ; save length of last page

	mov	ah,3eh
	int	21h     ; close the file

loc_fin:
	pop	dx
        pop     si
        pop     ds
	pop	es
	pop	di
	pop	cx
	pop	ax
loc_en:
	mov	bx,cs:old_bx
	jmp	loc_24

message:
        mov     dx,si
        mov     ah,09h
        int    21h
        lea     dx,mes
        mov     ah,09h
        int    21h
	ret

int_4b_scan:

        mov     old_bx,bx
	mov	old_dx,dx
	push	cs
	pop	ds
	add     dx,10h            ; dx = Start seg

	call	scanvir
	jc	loc_vir

        mov     ax,old_bx
	mov	dx,old_dx
        mov     ds,dx
        mov     es,dx
	retf

loc_vir:
;	call	message
        pop     dx
        pop     ds
	mov	dx,old_dx
        push    dx
        xor     dx,dx
        push    dx
        retf


scanvir:
	; dx = segment for scan	 (offset = 0)
	; cs:viroff = offset of virtable
	; ds = segment of virtable
	; cs:count = number of viruses
	; cs:num_ff = number of 64k
	; cs:last_pag = number of bytes in last page
	; return bit c if virus is founded
	; ds:si points to the viruses name
	; bp,es,di,bx,ax,dx мусор

        mov     cs:es_main,dx     ; es_main = Start_seg

	mov	bp,cs:viroff      ; bp - pointer to virus table
	mov     bh,0

loc_5:
	cmp     byte ptr cs:count,bh
	jne	loc_61
	ret
loc_61:
	inc	bh
	mov	di,cs:es_main     ;
	mov	es,di             ;
	xor 	di,di             ;
	mov	dx,cs:num_ff      ;
	mov	si,cs:[bp]        ; si points to this viruses pattern
	lodsb
	mov	bl,al             ; bl - counter of characters in virus pattern
	sub	bl,1
	lodsb  			  ; al - first char of pattern
	jmp	loc_12            ; go to search

loc_9:
	cmp	dx,-1             ; virus is ended ?
	jne	loc_15            ; no
	add	bp,2              ; bp points to the next virus
        jmp	loc_5

loc_15:

	xor	di,di		  ; di points to the beginning of the next segment
	mov 	cx,es             ;
	add	cx,1000h          ;
	mov	es,cx             ; es points to the next segment

loc_12:
	cmp	dx,0              ; we'll work with last page ?
	je	loc_2             ; yes
	mov	cx,0ffffh         ; cx = maximum counter
	jmp	loc_10
loc_2:
	mov 	cx,cs:last_pag    ;

loc_10:

	repne	scasb             ; search for first char
	je	loc_13            ; found
	dec	dx                ; decrement of the counter of 64k
	jmp	loc_9             ; go to the preparing for the search in next segment

loc_13:
	mov	cs:old_cx,cx      ;
	mov	cs:old_si,si
	push	di
	push	es
	cmp	di,0fff0h
	jbe	loc_7
	mov	cx,es
	inc	cx
	mov	es,cx
	sub	di,10h

loc_7:
	xor	cx,cx
	mov	cl,bl
	repz	cmpsb
	jne	loc_11
	pop	es
	pop	di
	jmp	loc_89  ; found !

loc_11:
	mov	si,cs:old_si
	pop	es
	pop	di
	mov	cx,cs:old_cx
	jmp	loc_10

loc_er:


loc_89:
	stc
	ret


pattern:
	db	08eh
	db	0c2h
	db	08eh
	db	0dah
	db	08bh
	db	0c3h
	db	0cbh


install:
	int	5

	cli		; set new stack
	mov	ax,cs
	mov	ss,ax
	mov	bx,offset n
	add	bx,50h
	mov	sp,bx
	sti

        xor     ax,ax
        push    ax
        pop     ds ; ds=0
	cli

        mov     di,ds:[21h*4]
        mov     ax,ds:[21h*4+2]
        mov     cs:old_21h_off,di
        mov     cs:old_21h_seg,ax

        mov     di,ds:[31h*4]
        mov     ax,ds:[31h*4+2]
	push	ax
	pop	es


        mov     ds:[21h*4],offset int_21h_entry
        mov     ds:[21h*4+2],cs

	sti

                                 ; find 'MZ'
	mov	cx,-1
	cld
	mov	byte ptr al,4dh
loc_lo:
	repne	scasb
	jne	loc_err
	cmp	byte ptr es:[di],5ah
	jne	loc_lo

loc_loop:
                                 ; 'MZ' found

	push	cs
	pop	ds
	lea     si,cs:pattern
	inc	si


	mov	byte ptr al,cs:[si-1]
	inc	si
loc_loop1:
	dec	si
	repne	scasb
	jne	loc_err
	push    cx
	mov	cx,6
	rep	cmpsb
	pop	cx
	jnz	loc_loop1

suc_end:

	mov	byte ptr es:[di-5],0eah
	mov	es:[di-4],offset int_4b_scan
	mov	es:[di-2],cs

loc_err:

	mov	dx,offset install
	int	27h

n:
	dw	50 dup (0)
	end 	start