# This is a simple tcp server that listens on port 21
# unless another is specified.  
# The possible uses of this are;
#  Ftp has no encryption for passwords and they are
#  sent in plain text under the right conditions.
#  Most ftp programs have a text file called <program-name>.ini
#  which will store the info like site-name, user-name, encrypted
#  password and account-name.  Instead of trying to decrypt the 
#  password for each different application (ws_ftp etc)
#  do this.  
#    Edit the <program-name>.ini 
#    Wherever there is a site-name change it to 127.0.0.1
#    Start your this perl scipt
#    Open your ftp program and click connect

# Most of this coding was already in the /perl/eg/ folder
# you can find the orginal version there .. 

print "===========================\n";
print " Manicx local FTP spoofer\n";
print " www.infowar.co.uk/manicx/\n";
print "===========================\n";

($port) = @ARGV;
$port = 21 unless $port;    # Are port is 21 unless specified

$AF_INET = 2;
$SOCK_STREAM = 1;

$sockaddr = 'S n a4 x8';

($name, $aliases, $proto) = getprotobyname('tcp');
if ($port !~ /^\d+$/) { ($name, $aliases, $port) = getservbyport($port, 'tcp');}

print "Port = $port\n";

$this = pack($sockaddr, $AF_INET, $port, "\0\0\0\0");

select(NS); $| = 1; select(stdout);

socket(S, $AF_INET, $SOCK_STREAM, $proto) || die "socket: $!";
bind(S,$this) || die "bind: $!";
listen(S,5) || die "connect: $!";

select(S); $| = 1; select(stdout);

print "Listening for connection..\n";

($addr = accept(NS,S)) || die $!;

print "Accept ok\n";

($af,$port,$inetaddr) = unpack($sockaddr,$addr);
@inetaddr = unpack('C4',$inetaddr);

print NS "220\n"; # We are ok for login (send username)
$user = <NS>;
print $user;

print NS "331\n"; # user ok send password
$pass = <NS>;
print $pass;

print NS "331\n"; # password ok send account
$acco = <NS>;
print $acco;

print NS "200\n"; # account ok send what you want.

$resp = <NS>;
print $resp;

print NS "451\n"; # bye bye baby