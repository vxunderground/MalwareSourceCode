# anonymail - fuck, i was bored like shit. napalmed.
$script_url = "/am.cgi";
$sendmail = "/usr/sbin/sendmail";
@referers = ("");
$admin = "napalmed@fuck.au";
@friends = ("");
$good_refer = 0;
if($ENV{REQUEST_METHOD} eq 'GET')
{
&print_form;
}
elsif($ENV{REQUEST_METHOD} eq 'POST')
{
        foreach $referer(@referers)
        {
        if($ENV{HTTP_REFERER} =~ /$referer/i) { $good_refer = 1; }
        }
        if($good_refer != 1) { &error; }
&parse_form;
&send_mail;
}
else
{
&error;
}
sub print_form
{
print "Content-type: text/html\n\n";
print "<HTML><HEAD><TITLE>jhve elohim meth :: god is dead</TITLE></HEAD>\n";
print "<BODY><B> ANONYMOUS MAIL. FUCK YOU </B><BR>\n";
print "
<CENTER>
<FORM ACTION=\"$script_url\" METHOD=\"POST\" NAME=\"mail_form\">
<TABLE BORDER=5><TH COLSPAN=2>BITCH</TH>
<tr><td>Send To:</td><td><INPUT TYPE=\"text\" NAME=\"to\" SIZE=30></td></tr>
<tr><td>From Address:</td><td><INPUT TYPE=\"text\" NAME=\"from_addy\" SIZE=30></td></tr>
<tr><td>From Name:</td><td><INPUT TYPE=\"text\" NAME=\"from_name\" SIZE=30></td></tr>
<tr><td>Subject:</td><td><INPUT TYPE=\"text\" NAME=\"subject\" SIZE=30></td></tr>
<tr><td colspan=2>Body:<br><TEXTAREA NAME=\"body\" WRAP=VIRTUAL ROWS=3 COLS=35></TEXTAREA></td></tr>
<tr><td colspan=2 align=center><INPUT TYPE=\"submit\" VALUE=\" Send Mail \">
<INPUT TYPE=\"reset\" VALUE=\" Clear \"></TD></TR></TABLE></FORM></CENTER>\n";
print "<BR><HR><BR></BODY></HTML>\n";
exit;
}
sub send_mail
{
open (MAIL, "|$sendmail -t") || &error;
print MAIL "From: $input{'from_name'} \<$input{'from_addy'}\>\n";
print MAIL "Reply-To: $input{'from_addy'}\n";
print MAIL "X-Mailer: anonmail.bitch\n";
print MAIL "To: $input{'to'}\n";
print MAIL "Subject: $input{'subject'}\n";
print MAIL "Content-Type: text/plain; charset=us-ascii\n";
print MAIL "Content-Transfer-Encoding: 7bit\n\n";

print MAIL "$input{'body'}";
close (MAIL);

print "Content-type: text/html\n\n";
print "Below is what you sent to $input{to}\n<pre>\n";
print "From: $input{'from_name'} \<$input{'from_addy'}\>\n";
print "Reply-To: $input{'from_addy'}\n";
print "To: $input{'to'}\n";
print "Subject: $input{'subject'}\n\n";
print "$input{'body'}";
exit;

}

sub parse_form {

   read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
   if (length($buffer) < 5) {
         $buffer = $ENV{QUERY_STRING};
    }
   @pairs = split(/&/, $buffer);
   foreach $pair (@pairs) {
      ($name, $value) = split(/=/, $pair);

        $value =~ tr/+/ /;
        $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        $value =~ s/<!--(.|\n)*-->//g;
        $input{$name} = $value;
   }
        if($input{'to'} =~ /microsoft.com/i) { &error; }

        foreach $friend(@friends)
        {
        if($input{'to'} =~ /$friend/i) { &error; }
        }
}




sub error
{
print "Content-type: text/html\n\n";
print "<BR>An error occured while processing the script.\n";
exit;
}
