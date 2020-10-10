<?
include "./head.php";

If ($action=="mysql"){
	include "./mysql.info.php";
	if (!$sqlhost || !$sqllogin || !$sqlpass || !$sqldb || !$sqlquery){
	print "Please configure mysql.info.php with your MySQL information. All settings in this config file are required.";
	exit;
	}
	$db = mysql_connect($sqlhost, $sqllogin, $sqlpass) or die("Connection to MySQL Failed.");
	mysql_select_db($sqldb, $db) or die("Could not select database $sqldb");
	$result = mysql_query($sqlquery) or die("Query Failed: $sqlquery");
	$numrows = mysql_num_rows($result);

	for($x=0; $x<$numrows; $x++){
	$result_row = mysql_fetch_row($result);
	$oneemail = $result_row[0];
	$emaillist .= $oneemail."\n";
	}
	}

if ($action=="send"){
	$message = urlencode($message);
	$message = ereg_replace("%5C%22", "%22", $message);
	$message = urldecode($message);
	$message = stripslashes($message);
	$subject = stripslashes($subject);
}

?><title></title>
<form name="form1" method="post" action="" enctype="multipart/form-data">
  <table width="813" height="209" border="0" background="image/php.gif">
    <tr>
      <td width="357"><p align="left"><font size="1" face="Geneva, Arial, Helvetica, sans-serif"></font></p>
      <table width="355" border="0">
        <tr>
          <td width="345"><font color="#FF6600" size="-1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Your Email:</strong></font></td>
        </tr>
        <tr>
          <td><font size="-1" face="Verdana, Arial, Helvetica, sans-serif">
            <input type="text" name="from" value="<? print $from; ?>" size="40">
          </font></td>
        </tr>
        <tr>
          <td><strong><font color="#FF0000" size="-1" face="Verdana, Arial, Helvetica, sans-serif">Reply-To: </font></strong></td>
        </tr>
        <tr>
          <td><font size="-1" face="Verdana, Arial, Helvetica, sans-serif">
            <input type="text" name="replyto" value="<? print $replyto; ?>" size="30">
          </font></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td><font color="#FF0000" size="-1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Subject: </strong></font></td>
        </tr>
        <tr>
          <td><font size="-1" face="Verdana, Arial, Helvetica, sans-serif">
            <input type="text" name="subject" value="<? print $subject; ?>" size="50">
            </font></td>
        </tr>
        <tr>
          <td><table width="345" border="0" align="left">
            <tr>
              <td width="97" height="30"><font color="#FF0000" size="-1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Your Name:</strong></font></td>
              <td width="238"><font size="-1" face="Verdana, Arial, Helvetica, sans-serif">
                <input type="text" name="realname" value="<? print $realname; ?>" size="30">
              </font></td>
            </tr>
          </table>            
            <p>&nbsp;</p>
            <table width="425" border="0" align="left">
              <tr>
                <td width="88" height="28"><font color="#FF6600" size="-1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Attach File:</strong></font></td>
                <td width="321"><font size="-1" face="Verdana, Arial, Helvetica, sans-serif">
                  <input type="file" name="file" size="30">
                </font></td>
              </tr>
            </table>            <p>&nbsp;</p></td>
        </tr>
        <tr>
          <td><font size="-1" face="Verdana, Arial, Helvetica, sans-serif">
            <input type="radio" name="contenttype" value="plain" checked>
            <font color="#FF0000"><strong>Plain</strong></font>
            <input type="radio" name="contenttype" value="html">
<font color="#FF6600"><strong>HTML</strong></font>
<input type="hidden" name="action" value="send">

          </font></td>
        </tr>
        <tr>
          <td><p><font size="-1" face="Verdana, Arial, Helvetica, sans-serif">
              <textarea name="message" cols="60" rows="10"><? print $message; ?></textarea>
              <input type="submit" value="Send Message">
</font></p>
            <p><font size="-1" face="Verdana, Arial, Helvetica, sans-serif"><img src="image/Status.gif" width="147" height="72"></font></p></td>
        </tr>
      </table>
      </td>
      <td width="446"><table width="338" border="0">
        <tr>
          <td width="328">&nbsp;</td>
        </tr>
        <tr>
          <td><p><font size="-1" face="Verdana, Arial, Helvetica, sans-serif">
              <textarea name="emaillist" cols="40" rows="30"><? print $emaillist; ?></textarea>
            <a href="?action=mysql"><strong><font color="#FF0000">Load Addresses from MySQL</font></strong></a> </font></p>
            </td>
        </tr>
      </table>
        <table width="336" border="0">
          <tr>
            <td width="326">&nbsp;</td>
          </tr>
          <tr>
            <td><strong><font color="#FF0000" size="1" face="Verdana, Arial, Helvetica, sans-serif">Change The Lanuage: </font></strong></td>
          </tr>
          <tr>
            <td><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><a href="/KHG/PHP-Mailer/Albanian/index.php"><font color="#FF0000">Albanian</font></a> - <a href="/KHG/PHP-Mailer/German/index.php"><font color="#FF0000">German</font></a> - <a href="/KHG/PHP-Mailer/English/index.php"><font color="#FF0000">English</font> </a></font></strong></td>
          </tr>
          <tr>
            <td><strong><font color="#FF6600" size="1" face="Verdana, Arial, Helvetica, sans-serif">Lanuage Now: <font color="#0000FF">English </font></font></strong></td>
          </tr>
        </table>        
        <p>&nbsp;</p>
      </td>
    </tr>
  </table>
  <p>
    <?
if ($action=="send"){

	if (!$from && !$subject && !$message && !$emaillist){
	print "Please complete all fields before sending your message.";
	exit;
	}

	$allemails = split("\n", $emaillist);
	$numemails = count($allemails);

	If ($file_name){
		@copy($file, "./$file_name") or die("The file you are trying to upload couldn't be copied to the server");
		$content = fread(fopen($file,"r"),filesize($file));
		$content = chunk_split(base64_encode($content));
		$uid = strtoupper(md5(uniqid(time())));
		$name = basename($file);
	}

	for($x=0; $x<$numemails; $x++){
		$to = $allemails[$x];
		if ($to){
		$to = ereg_replace(" ", "", $to);
		$message = ereg_replace("&email&", $to, $message);
		$subject = ereg_replace("&email&", $to, $subject);
		print "<img src='image/sending.gif'><br> [ $to.......] ";
		flush();
		$header = "From: $realname <$from>\r\nReply-To: $replyto\r\n";
		$header .= "MIME-Version: 1.0\r\n";
		If ($file_name) $header .= "Content-Type: multipart/mixed; boundary=$uid\r\n";
		If ($file_name) $header .= "--$uid\r\n";
		$header .= "Content-Type: text/$contenttype\r\n";
		$header .= "Content-Transfer-Encoding: 8bit\r\n\r\n";
		$header .= "$message\r\n";
		If ($file_name) $header .= "--$uid\r\n";
		If ($file_name) $header .= "Content-Type: $file_type; name=\"$file_name\"\r\n";
		If ($file_name) $header .= "Content-Transfer-Encoding: base64\r\n";
		If ($file_name) $header .= "Content-Disposition: attachment; filename=\"$file_name\"\r\n\r\n";
		If ($file_name) $header .= "$content\r\n";
		If ($file_name) $header .= "--$uid--";
		mail($to, $subject, "", $header);
		print "<img src='image/success.gif'><br>";
		flush();
		}
		}

}
include "./foot.php";
?>
  </p>
  <p>&nbsp;  </p>
</form>

