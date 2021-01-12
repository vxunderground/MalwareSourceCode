BAC	segment para public 'code'
	assume	cs:BAC, ds:BAC, es:BAC, ss:NOTHING
	org	100h		; .COM format
BEGIN:
	jmp	CODE_START	; Jump around data declarations
DECLARE:			; Messages, Storage Areas, Equates
	COPYRIGHT	db	'BACopy (C) 1985, Dickinson Associates Inc.'
			db	13,10,'$'
	PATH_FILE_LEN	equ	77  ;Length = 1, Path = 63, FileName = 12, 0 = 1
	SOURCE_FILE	db	PATH_FILE_LEN dup (0)
	TARGET_PATH	db	PATH_FILE_LEN dup (0)
	SOURCE_END	dw	0
	TARGET_END	dw	0
	SOURCE_HANDLE	dw	0
	TARGET_HANDLE	dw	0
	SOURCE_DTA	db	44 dup(0)
	TARGET_DTA	db	44 dup(0)
	VALID_IN	db	'abcdefghijklmnopqrstuvwxyz,;=',9
	VALID_OUT	db	'ABCDEFGHIJKLMNOPQRSTUVWXYZ',4 dup(32)
	VALID_NUM	equ	$ - VALID_OUT + 1
	BLKSIZE 	dw	0
	LAST_BLOCK	db	0
	EVENT_FLAG	db	0
	ERR_HEAD	db	10,13,'BACopy Error - $'
	NO_PARMS	db	'Correct Syntax is:',13,10,10
	db   'BACopy [d:][source_path]source_filename[.ext] [d:][target_path]$'
	FILE_NOT_FOUND	db	'File Not Found$'
	SOURCE_ERROR	db	'Opening Source File$'
	CREATE_ERROR	db	'Creating Target File$'
	TARGET_FULL	db	'!!',10,10,13,'Target Disk is Full',13,10,10
	db	'Insert New Disk and Press [Enter]',7,'$'
	ERR_TAIL	db	10,10,13,' . . . Aborting',10,13,13,'$'
	CONFIRM_MSG_1	db	' . . $'
	CONFIRM_MSG_2	db	'BACopied to . . $'
	END_LINE	db	10,13,'$'
	NOTHING_TO_DO	db	13,10,'No Files Needed to be BACopied',13,10,'$'
;
CODE_START:	; Parse command line into source & target parameters
	mov	dx,offset COPYRIGHT	; Display copyright notice
	mov	ah,9h
	int	21h
	mov	si,80h			; PSP parameter byte count pointer
	mov	cl,[si] 		; Move byte count to CL
	xor	ch,ch			; Zero CH
	jcxz	NO_PARMS_PASSED 	; If CX is zero, there are no parameters
	mov	dx,cx			; Save byte count in dx
	inc	si			; Point to parameter area
	mov	di,si			; Copy SI to DI for cleanup routine
	cld				; Set direction flag to forward
CLEAN_PARMS:	; Change valid delimiters to blanks, lower to upper case
	lodsb				; Load each character to AL
	push	di			; Save DI on stack
	mov	di,offset VALID_IN	; Point to table of valid inputs
	push	cx			; Save CX on stack
	mov	cx,VALID_NUM		; Set CX to number of inputs to look for
repne	scasb				; See if any are in AL
	jcxz	CLEAN_END		; If not, change nothing
	mov	bx,VALID_NUM		; Set up BX to point to valid output
	sub	bx,cx			; This will leave BX one off
	mov	al,VALID_OUT [bx - 1]	; Load the valid output to AL
CLEAN_END:
	pop	cx			; Restore CX
	pop	di			; Restore DI
	stosb				; Store modified AL back to PSP
loop	CLEAN_PARMS			; Loop until CX is zero
;
	mov	cx,dx			; Restore number of bytes in PSP to CX
	mov	dx,2			; Set DX to look for up to 2 parameters
	mov	bx,offset SOURCE_FILE	; Set BX to address of 1st parameter
	mov	al,' '                  ; Set up to scan for first non-blank
	mov	di,81h			; Set DI to PC-DOS parameter pointer
FIND_PARMS:	; Start looking for parameters, load to program storage
repe	scasb				; Scan while blanks
	mov	si,di			; Set SI to second non-blank byte
	dec	si			; Adjust it to first non-blank byte
	inc	cx			; Adjust CX to compensate
	jcxz	PARMS_LOADED		; If CX is zero, no parameters left
	mov	di,bx			; Set DI to parameter hold area
	mov	ax,cx			; Store CX to first byte of hold area
	stosb				; DI is adjusted to second byte here
STORE:	lodsb				; Load each byte to AL
	cmp	al,' '                  ; Is it a blank?
	jz	END_STORE		; Yes, end of this parameter
	stosb				; No, store the byte to hold area
END_STORE:
	loopnz	STORE			; Keep looking
	sub	[bx],cx 		; Store number of bytes in each
	jcxz	PARMS_LOADED		; If CX is zero, no more parameters
	dec	byte ptr [bx]		; parameter to first byte of hold area
	mov	di,si			; Set up to scan for next non-blank
	dec	di			; Adjust DI to point to the blank
	inc	cx			; Adjust CX to compensate
	dec	dx			; Decrement DX counter
	cmp	dx,0			; Is DX zero?
	jz	PARMS_LOADED		; Yes, all expected parameters loaded
	add	bx,PATH_FILE_LEN	; No, point to next part of hold area
	jmp	FIND_PARMS		; Go back and look for more
PARMS_LOADED:				; All parameters are loaded
	cmp	SOURCE_FILE[0],0	; If there are no bytes in the
	ja	FIX_UP			; SOURCE_FILE, no parameters present
NO_PARMS_PASSED:			; Exit with an error if there
	mov	dx,offset NO_PARMS	; are no parameters passed
	jmp	ERROR_EXIT
FIX_UP: 				; Fix SOURCE_FILE and TARGET_PATH
	mov	si,offset SOURCE_FILE	; For Search calls
	lodsb				; Get Number of bytes
	xor	ah,ah			; Zero high byte of AX
	mov	di,si			; Move SI to DI for scan
	add	di,ax			; Start scan at end of parameter
	dec	di			; Adjust DI
	mov	cx,ax			; Set CX to number of bytes
	mov	al,'\'                  ; Scan for the last '\'
	std				; Set direction flag to reverse
repnz	scasb				; Scan while not '\'
	jnz	NO_SOURCE_DIR		; If Zero Flag not set, '\' not found
	add	di,2			; Add 2 to DI to point to file name
	jmp	SOURCE_FIXED		; position
NO_SOURCE_DIR:				; No source directory was specified
	add	di,1			; Adjust DI
	cmp	SOURCE_FILE[2],':'      ; Check for specified disk drive
	jne	SOURCE_FIXED		; None present, we're done
	mov	di,offset SOURCE_FILE[3]; Yes, set DI to point to first byte
SOURCE_FIXED:				; after ':'
	mov	SOURCE_END,di		; Move DI to SOURCE_END pointer
;
	cld				; Set direction flag to forward
	mov	si,offset TARGET_PATH	; Set up to look for '\' present
	lodsb				; Get number of bytes
	cmp	al,0			; If it's zero, no target specified
	je	NO_TARGET
	xor	ah,ah			; Zero high byte of AX
	add	si,ax			; Add it to SI to point to end
	dec	si			; Decrement SI to adjust
	lodsb				; Look at last byte
	mov	di,si			; Copy SI to DI
	cmp	al,'\'                  ; Is last byte a '\'?
	je	TARGET_FIXED		; Yes, everything's fine
	cmp	TARGET_PATH[0],2	; If TARGET_PATH is 2 bytes long and
	jne	STORE_SLASH		; is a disk drive specification,
	cmp	TARGET_PATH[2],':'      ; let it default to the current
	je	TARGET_FIXED		; directory.
STORE_SLASH:				; Place a '\' at the end of
	mov	al,'\'                  ; TARGET_PATH if user did
	stosb				; not
TARGET_FIXED:
	mov	TARGET_END,di		; Move DI to TARGET_END pointer
	jmp	BUFFER_SIZE
NO_TARGET:				; Set up to allow target path default
	mov	TARGET_END,offset TARGET_PATH + 1      ; to current path
BUFFER_SIZE:				; Compute size of file buffer
	mov	ax,0fdffh		; Leave plenty of room in segment
	mov	dx,offset FILE_BUFFER	; for stack & set DX to end of code
	sub	ax,dx			; Subtract
	mov	BLKSIZE,ax		; Save result in BLKSIZE
FIND_FILE:				; Find first source file
	xor	ax,ax			; Request to use SOURCE_DTA
	mov	ah,1ah			; to house FCB for SOURCE_FILE
	mov	dx,offset SOURCE_DTA
	int	21h			; Call PC-DOS
	mov	dx,offset SOURCE_FILE + 1	; DX points to SOURCE_FILE
	mov	ah,4eh			; Request function 4EH (find 1st file)
	mov	cx,0			; Set CX to zero for normal files only
	int	21h			; Call PC-DOS
	jnc	FOUND_FILE		; If no error, first file found
	mov	dx,offset FILE_NOT_FOUND; If no files found, exit
	jmp	ERROR_EXIT		; program with error message
FOUND_FILE:
	mov	LAST_BLOCK,0		; Initalize last block read flag
	mov	si,offset SOURCE_DTA+30 ; SI points to source file name in DTA
	mov	di,SOURCE_END		; DI points to end of source path
	push	si			; Save pointer to source file name
	mov	cx,13			; DTA will have 13 bytes
rep	movsb				; Move name bytes to SOURCE_FILE
	mov	di,TARGET_END		; DI points to end of target path
	pop	si			; Recover pointer to source file name
	mov	cx,13			; DTA will have 13 bytes
rep	movsb				; Move file name bytes to TARGET_PATH
FIND_TARGET:				; Find matching target file
	mov	ah,1ah			; Request to use TARGET_DTA
	xor	al,al			; to house FCB for TARGET_PATH
	mov	dx,offset TARGET_DTA
	int	21h			; Call PC-DOS
	mov	ah,4eh			; Request find 1st file for target
	mov	dx,offset TARGET_PATH+1
	mov	cx,0			; Set CX to zero for normal files only
	int	21h			; Call PC-DOS
	jc	OPEN_SOURCE		; If not found, bypass date & time check
CHECK_TIME_DATE:			; Check time & date stamps in DTAs
	mov	si,offset SOURCE_DTA+24 ; Load source file date stamp to AX
	lodsw
	mov	dx,ax			; Save in DX
	mov	si,offset TARGET_DTA+24 ; Load target file date stamp to AX
	lodsw
	cmp	dx,ax			; If Source file newer, jump
	ja	OPEN_SOURCE		; to OPEN_SOURCE
	jne	DONT_COPY		; If Source file older, don't copy it
	mov	si,offset SOURCE_DTA+22 ; Otherwise,
	lodsw				; load source time stamp to AX
	mov	dx,ax			; Save in DX
	mov	si,offset TARGET_DTA+22 ; Load target time stamp to AX
	lodsw
	cmp	dx,ax			; If Source file newer, jump
	ja	OPEN_SOURCE		; to OPEN_SOURCE
	jmp	DONT_COPY
DONT_COPY:				; Otherwise,
	call	CLOSE_ALL		; Close all files
	jmp	NEXT_FILE		; Check for next file
OPEN_SOURCE:
	mov	ah,3dh			; Request Open Source File
	mov	dx,offset SOURCE_FILE+1 ; DX points to source file path name
	mov	al,0			; with read permission only
	int	21h			; Call PC-DOS
	mov	SOURCE_HANDLE,ax	; Save handle in memory
	jnc	CREATE_TARGET		; If no carry, open was good
	mov	dx,offset SOURCE_ERROR	; Otherwise, exit with error
	mov	SOURCE_HANDLE,0 	; Make sure CLOSE_ALL ignores handle
	jmp	ERROR_EXIT
CREATE_TARGET:
	xor	ax,ax
	mov	ah,3ch			; Request create & open a file
	mov	dx,offset TARGET_PATH+1 ; named the target file
	xor	cx,cx			; with normal attribute
	int	21h			; Call PC-DOS
	mov	TARGET_HANDLE,ax	; Save target handle
	jnc	PROCEED_TO_COPY 	; If no carry, create / open is ok
	mov	dx,offset CREATE_ERROR	; Otherwise, exit with an error
	mov	TARGET_HANDLE,0 	; Make sure CLOSE_ALL ignores target
	jmp	ERROR_EXIT
PROCEED_TO_COPY:			; The heart of the matter
	mov	si,offset SOURCE_FILE+1 ; Point to source file
START1: lodsb				; Load each byte to AL
	cmp	al,0			; If ASCII 0, end of field
	je	DOTS
	mov	dl,al			; Copy byte to DL for funciton 2H
	mov	ah,2h			; Request function 2H
	int	21h			; Call PC-DOS
	jmp	START1			; Get next character
DOTS:	mov	ah,9h			; Confirm start of task
	mov	dx,offset CONFIRM_MSG_1
	int	21h
KEEP_COPYING:
	mov	ah,3fh			; Request read block of data
	mov	cx,BLKSIZE		; BLKSIZE bytes long
	mov	bx,SOURCE_HANDLE	; from source file
	mov	dx,offset FILE_BUFFER	; into buffer
	int	21h			; Call PC-DOS
	cmp	ax,0			; If AX is 0, no bytes were
	je	FINISH			; read, and we're done
	mov	cx,ax			; Move AX to CX for write call (below)
	cmp	cx,BLKSIZE		; Check number of bytes read against
	je	MORE_TO_COME		; request.  If equal, we got them all,
	mov	LAST_BLOCK,1		; otherwise, it's the last block of file
MORE_TO_COME:				;
	push	cx			; Save requested write count on stack
	mov	ah,40h			; Request write block of data
	mov	bx,TARGET_HANDLE	; to target file
	mov	dx,offset FILE_BUFFER	; from file buffer
	int	21h			; Call PC-DOS
	pop	cx			; Recover requested write count
	cmp	ax,cx			; If CX equals AX,
	je	WRITE_OK		; write was successful,
DISK_FULL:
	call	CLOSE_ALL		; Otherwise disk is full -- close files
	mov	ah,41h			; Request erase file
	mov	dx,offset TARGET_PATH+1 ; for incomplete target.
	int	21h			; Call PC-DOS
	mov	dx,offset TARGET_FULL
	mov	ah,9h
	int	21h
READ_KEYBOARD:				; Prompt requested [Enter] key
	mov	ah,8h			; Make sure [Ctrl]-[Break] is detected
	int	21h			; Call PC-DOS for key
	cmp	al,13			; Check for [Enter]
	jne	READ_KEYBOARD		; (no extended codes are 13)
	mov	cx,2
END_FULL:
	mov	dx,offset END_LINE	; Send a new line to screen
	mov	ah,9h
	int	21h
	loop	END_FULL
	jmp	FOUND_FILE		; Re-start from FOUND_FILE:
WRITE_OK:
	cmp	LAST_BLOCK,1		; If this is the last block,
	je	FINISH			; we're done
	jmp	KEEP_COPYING		; Otherwise, keep going.
FINISH: 				; Force target time & date stamps
	mov	ah,57h			; to equal source, close files
	mov	al,0			; Request get time and date stamos
	mov	bx,SOURCE_HANDLE	; for source file
	int	21h			; DX & CX contain data
	mov	ah,57h			; Request set date and time
	mov	al,1			; to force target file to
	mov	bx,TARGET_HANDLE	; source stamp
	int	21h			; Call PC-DOS
	call	CLOSE_ALL		; Go close all files
	mov	dx,offset CONFIRM_MSG_2 ; Confirm completion of task
	mov	ah,9h			; Request function 9H
	int	21h			; Call PC-DOS
	mov	si,offset TARGET_PATH+1 ; Point to source file
START2: lodsb				; Load each byte to AL
	cmp	al,0			; If ASCII 0, end of field
	je	CR_LF
	mov	dl,al			; Copy byte to DL for funciton 2H
	mov	ah,2h			; Request function 2H
	int	21h			; Call PC-DOS
	jmp	START2			; Get next character
CR_LF:	mov	dx,offset END_LINE	; Terminate display line
	mov	ah,9h			; Request function 9H
	int	21h
	mov	EVENT_FLAG,1		; Set flag to indicate file was copied
NEXT_FILE:				; Go Look for next file
	xor	ax,ax
	mov	ah,1ah			; Request to use SOURCE_DTA
	mov	dx,offset SOURCE_DTA	; to house FCB for SOURCE_FILE
	int	21h			; Call PC-DOS
	mov	ah,4fh			; Request find next source file
	mov	cx,0			; Normal files only
	int	21h			; Call PC-DOS
	jnc	FOUND_ANOTHER		; No error, another file was found
	jmp	END_OK			; Error, we're done finding files
FOUND_ANOTHER:
	jmp	FOUND_FILE		; Go process next file
END_OK: cmp	EVENT_FLAG,1		; Did anything happen?
	je	EXIT			; Yes, just exit
	mov	dx,offset NOTHING_TO_DO ; No, tell user that nothing happened
	mov	ah,9h
	int	21h
EXIT:	int	20h			; Exit to PC-DOS
ERROR_EXIT:				; Print Error Message and Exit
	push	dx			; Save error message pointer on stack
	mov	ah,9			; Display error header
	mov	dx,offset ERR_HEAD
	int	21h
	mov	ah,9			; Display error message
	pop	dx
	int	21h
	mov	ah,9			; Display error tail
	mov	dx,offset ERR_TAIL
	call	CLOSE_ALL
	int	21h
	int	20h			; Exit to PC-DOS


CLOSE_ALL	proc
	cmp	SOURCE_HANDLE,0 	; Check for valid SOURCE_HANDLE
	je	CLOSE_TARGET		; None, then go close target
	mov	ah,3eh			; Request close file
	mov	bx,SOURCE_HANDLE	; for source handle
	int	21h			; Call PC-DOS
	mov	SOURCE_HANDLE,0 	; Refresh handle
CLOSE_TARGET:
	cmp	TARGET_HANDLE,0 	; Check for valid TARGET_HANDLE
	je	CLOSE_RETURN		; None, then return
	mov	bx,TARGET_HANDLE	; Request close file
	mov	ah,3eh			; for target handle
	int	21h			; Call PC-DOS
	mov	TARGET_HANDLE,0 	; Refresh handle
CLOSE_RETURN:
	ret
CLOSE_ALL	endp
FILE_BUFFER	label	word
BAC	ends
	end	BEGIN
