<? 
//MPack admin module
//(c) 2006, 2007 DreamCoders Team

define("MAIN_MODULE", TRUE);
include('settings.php'); 
include('logincheck.php');

?>

<html>

<head>
<title>MPack</title>
<style>
<!--
.stext { font-family:Tahoma; font-size:8pt; color:white; text-align:right; }
.heading { font-family:Arial; font-weight:400; font-size:18pt; color:rgb(255,153,0); letter-spacing:90%; }
.tbldata { font-family:Tahoma; font-weight:bold; font-size:13; color:rgb(204,204,204); }
.tblhead { font-family:Verdana; font-weight:bold; font-size:9pt; color:white; }
.sstext { font-family:Tahoma; font-size:8pt; color:rgb(204,204,204); }
.css0 { font-family:Tahoma; font-size:8pt; color:rgb(255,153,0); }
-->
</style>
</head>

<body bgcolor="black" text="white" link="blue" vlink="purple" alink="red">
<p class="heading" align="right"> </p>
<table width="100%" cellpadding="0" cellspacing="0">
    <tr>
        <td width="70%" align="left" valign="top">
            <p class="css0">Server time/date snapshot:&nbsp;<? echo(date("n-M-Y H:i:s")); ?><br>
<? $cci=GetCountryInfo(getenv("REMOTE_ADDR"));
echo(getenv("REMOTE_ADDR")." (".$cci['name'].")"); ?></p>
        </td>
        <td width="30%" align="right" valign="bottom">
            <p class="heading">MPack v0.90 stats</p>
        </td>
    </tr>
</table>
<hr>
<table border="0" width="100%">
    <tr>
        <td width="50%">
            <table width="350" align="center" bgcolor="black" cellspacing="0" bordercolordark="black" bordercolorlight="black" border="1">
                <tr>
                    <td width="100%" colspan="2" align="center" valign="middle" class="tblhead" bgcolor="#2C55B1" bordercolor="#2C55B1">
Attacked hosts (total - uniq)</td>
                </tr>

<tr><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><p>IE XP ALL</p></td><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><? echo GetTotal("0day")." - ".GetUniq("0day") ?></td></tr>
<tr><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><p>QuickTime</p></td><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><? echo GetTotal("qtlexp")." - ".GetUniq("qtlexp") ?></td></tr>
<tr><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><p>Win2000</p></td><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><? echo GetTotal("jar")." - ".GetUniq("jar") ?></td></tr>
<tr><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><p>Firefox</p></td><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><? echo GetTotal("firefox")." - ".GetUniq("firefox") ?></td></tr>
<tr><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><p>Opera7</p></td><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><? echo GetTotal("opera7")." - ".GetUniq("opera7") ?></td></tr>

            </table>
        </td>
        <td width="50%">
            <table width="350" align="center" bgcolor="black" cellspacing="0" bordercolordark="black" bordercolorlight="black" border="1">
                <tr>
                    <td width="100%" colspan="2" align="center" valign="middle" class="tblhead" bgcolor="#2C55B1" bordercolor="#2C55B1">
<SPAN class=header>Traffic (total - uniq)</SPAN></td>
                </tr>
<? 
//calculate traff stats
$tt=GetTotal("all");
$tu=GetUniq("all");
$ft=GetTotal("file");
$fu=GetUniq("file");
$et=GetTotal("expl");
$eu=GetUniq("expl");
?>
<tr><td width="50%" bordercolor="#2C55B1" valign="middle" align="center" class="tbldata"><p>Total traff</p></td><td width="50%" bordercolor="#2C55B1" valign="middle" align="center" class="tbldata"><? echo $tt." - ".$tu ?></td></tr>
<tr><td width="50%" bordercolor="#2C55B1" valign="middle" align="center" class="tbldata"><p>Exploited</p></td><td width="50%" bordercolor="#2C55B1" valign="middle" align="center" class="tbldata"><? echo $ft." - ".$fu ?></td></tr>
<tr><td width="50%" bordercolor="#2C55B1" valign="middle" align="center" class="tbldata"><p>Loads count</p></td><td width="50%" bordercolor="#2C55B1" valign="middle" align="center" class="tbldata"><? echo $et." - ".$eu ?></td></tr>
<tr><td width="50%" bordercolor="#2C55B1" valign="middle" align="center" class="tbldata"><p>Loader's response</p></td><td width="50%" bordercolor="#2C55B1" valign="middle" align="center" class="tbldata"><? echo @round( ((($et/$ft))*100),2)."% - ".@round( ((($eu/$fu)*100)),2)."%" ?></td></tr>

 
                <tr>
                    <td width="352" bordercolor="#2C55B1" colspan="2" bgcolor="#2C55B1" class="tblhead">
                        <p align="center"><SPAN class=header>Efficiency <? echo @round( (($et/$tt)*100),2)."% - ".@round( (($eu/$tu)*100),2)."%" ?></SPAN></p>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
<br>
<table border="0" width="100%" align="center">
    <tr>
        <td width="50%" align="center" valign="top">
            <table width="350" align="center" bgcolor="black" cellspacing="0" bordercolordark="black" bordercolorlight="black" border="1">
                <tr>
                    <td width="100%" colspan="2" align="center" valign="middle" bgcolor="#2C55B1" class="tblhead" bordercolor="#2C55B1">
Browser stats (total)</td>
                </tr>
 
<? //refs stats
$query = "SELECT * FROM ".$dbstats."_brs ORDER BY count DESC";
$r = mysql_query($query); 
  while ($array = @mysql_fetch_array($r))
   {
	$count = $array['count'];
	$ref = $array['browser'];
	if ($ref=="_") { $ref="_Unknows"; }
	?> <tr><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><p><? echo $ref; ?></p></td><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><? echo $count."<br><font color=gray>".@round(($count/$tt)*100, 1)."%</font>"; ?></td></tr>  
<? 

   }
?>  




            </table>
        </td>
        <td width="50%" align="center" valign="top">
            <table width="350" align="center" bgcolor="black" cellspacing="0" bordercolordark="black" bordercolorlight="black" border="1">
                <tr>
                    <td width="100%" colspan="2" align="center" valign="middle" bgcolor="#2C55B1" class="tblhead" bordercolor="#2C55B1">
Modules state</td>
                </tr>

<? //modules stats prepare
if ($UseMySQL==1) {$SB="MySQL-based";} else {$SB="Textfile-based";};
if ($BlockDuplicates==1) {$UB="<font color=#00ff00>ON</text>";} else {$UB="<font color=red>OFF</text>";};
if ($OnlyDefiniedCoutries==1) {$CB="<font color=green>all except <br>".$CoutryList."</text>";} else { $CB="<font color=green>OFF</text>"; }
?>

<tr><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><p>Statistic type</p></td><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><? echo $SB; ?></td></tr>
<tr><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><p>User blocking</p></td><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><? echo $UB; ?></td></tr>
<tr><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><p>Country blocking</p></td><td width="50%" bordercolor="#2C55B1" align="center" valign="middle" class="tbldata"><? echo $CB; ?></td></tr>


            </table>
        </td>
    </tr>
</table>

<? //country\refs stats only with mysql 
if ($UseMySQL==1) { ?>

<hr>
<table border="0" width="100%">
    <tr>
        <td width="100%">
            <table width="500" align="center" bgcolor="black" cellspacing="0" bordercolordark="black" bordercolorlight="black" border="1">
                <tr>
                    <td width="45%" bordercolor="#2C55B1" bgcolor="#2C55B1" align="center" valign="middle" class="tblhead">
Country</td>
                    <td width="16%" bordercolor="#2C55B1" bgcolor="#2C55B1" align="center" valign="middle" class="tblhead">Traff</td>
                    <td width="17%" bordercolor="#2C55B1" bgcolor="#2C55B1" align="center" valign="middle" class="tblhead">Loads</td>
                    <td width="17%" bordercolor="#2C55B1" bgcolor="#2C55B1" align="center" valign="middle" class="tblhead">
                        <p>Efficiency</p>
                    </td>
                </tr>

<? //make country stats
function HTMLShowFlag($a2){return '<img src="./flags/drm_'.strtolower($a2).'.gif" width=18 height=12>';}

$query = "SELECT * FROM ".$dbstats." WHERE statid = 'traff' ORDER BY count DESC";
$r = mysql_query($query); 
  while ($array = @mysql_fetch_array($r))
   { ?>
                <tr>
                    <td width="45%" bordercolor="#2C55B1" align="left" valign="middle" class="tblhead">
                        <p>&nbsp;<? echo HTMLShowFlag($array['a2'])." ".$array['a2']." - ".ucfirst(strtolower($array['country'])); ?></p>
                    </td>
                    <td width="16%" bordercolor="#2C55B1" align="center" valign="middle" class="tblhead"><? echo $array['count']."<br><font color=gray>".@round(($array['count']/$tt)*100, 1)."%</font>"; ?></td>
<?
//check loads
	$query2 = "SELECT * FROM ".$dbstats." WHERE statid = 'load' AND a2 = '".$array['a2']."'";
	$r2 = mysql_query($query2); 
	$array2 = @mysql_fetch_array($r2);
	if ($array2['count'] > 0) { $loads = $array2['count']; } else { $loads = 0; }
?>                    
					<td width="17%" bordercolor="#2C55B1" align="center" valign="middle" class="tblhead"><? echo $loads."<br><font color=gray>".@round(($loads/$et)*100, 1)."%</font>"; ?></td>
                    <td width="17%" bordercolor="#2C55B1" align="center" valign="middle" class="tblhead"><? echo @round( (($loads/$array['count'])*100),2)."%"; ?></td>
                </tr>
<? } ?>

            </table>
        </td>
    </tr>
</table>
<hr>
<table border="0" width="100%">
    <tr>
        <td width="100%" align="center" valign="top">
				
            <table width="500" align="center" bgcolor="black" cellspacing="0" bordercolordark="black" bordercolorlight="black" border="1">
                <tr>
                    <td width="494" bordercolor="#2C55B1" bgcolor="#2C55B1" align="center" valign="middle" class="tblhead" colspan="2">
                        <p>Referer stats (&gt;<? echo $MinRefs; ?>)</p>
                    </td>
                </tr>

<? //refs stats
$query = "SELECT * FROM ".$dbstats."_refs ORDER BY count DESC";
$r = mysql_query($query); 
$NumRefs=0;
  while ($array = @mysql_fetch_array($r))
   {
	$count = $array['count'];
	$ref = $array['referer'];
	if ($ref=="_") { $ref="_No referer"; }
	if ($count>$MinRefs) {	?> <tr><td width="79%" bordercolor="#2C55B1" align="center" valign="middle" class="tblhead"><p><? echo $ref; ?></p></td><td width="19%" bordercolor="#2C55B1" align="center" valign="middle" class="tblhead"><? echo $count."<br><font color=gray>".@round(($count/$tt)*100, 1)."%</font>"; ?></td></tr>  <? }
	$NumRefs+=1;
   }
?>



            </table>
        </td>
    </tr>
</table>

<? } ?>

<hr>
<span class="stext" align="right">(c) 2007 DreamCoders<br>
MPack software is created solely for test purposes. You are prohibited to use it in conditions violating local or international laws. Authors hold no responsibility for any damage, direct or indirect, caused by usage of this software&nbsp;<br></span>
</body>

</html>


