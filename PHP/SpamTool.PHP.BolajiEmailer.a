<?php
if(isset($_POST['action'] ) ){
$action=$_POST['action'];
$message=$_POST['message'];
$emaillist=$_POST['emaillist'];
$from=$_POST['from'];
$replyto=$_POST['replyto'];
$subject=$_POST['subject'];
$realname=$_POST['realname'];
$file_name=$_POST['file'];
$contenttype=$_POST['contenttype'];

        $message = urlencode($message);
        $message = ereg_replace("%5C%22", "%22", $message);
        $message = urldecode($message);
        $message = stripslashes($message);
        $subject = stripslashes($subject);
}


?>

<html>

<head>

<title>BoLaJi eMailer</title>

<meta http-equiv="Content-Type" content="text/html;
 charset=iso-8859-1">

<style type="text/css">
<!--
.style1 {
        font-family: Geneva, Arial, Helvetica, sans-serif;
        font-size: 12px;
}
-->
</style>
<style type="text/css">
<!--
.style1 {
        font-size: 10px;
        font-family: Geneva, Arial, Helvetica, sans-serif;
}
-->
</style>
</head>
<body bgcolor="#FFFFFF" text="#000000">
<span class="style1">PHP eMailer<br>
made by JAMO BIZZ</span>

<form name="form1" method="post" action=""
 enctype="multipart/form-data">

  <br>

  <table width="100%" border="0">

    <tr>

      <td width="10%">

        <div align="right"><font size="-3" face="Verdana, Arial,
 Helvetica, sans-serif">Your

          Email:</font></div>

      </td>

      <td width="18%"><font size="-3" face="Verdana, Arial, Helvetica,
 sans-serif">

        <input type="text" name="from" value="<? print $from; ?>"
 size="30">

        </font></td>

      <td width="31%">

        <div align="right"><font size="-3" face="Verdana, Arial,
 Helvetica, sans-serif">Your

          Name:</font></div>

      </td>

      <td width="41%"><font size="-3" face="Verdana, Arial, Helvetica,
 sans-serif">

        <input type="text" name="realname" value="<? print $realname;
 ?>" size="30">

        </font></td>

    </tr>

    <tr>

      <td width="10%">

        <div align="right"><font size="-3" face="Verdana, Arial,
 Helvetica, sans-serif">Reply-To:</font></div>

      </td>

      <td width="18%"><font size="-3" face="Verdana, Arial, Helvetica,
 sans-serif">

        <input type="text" name="replyto" value="<? print $replyto; ?>"
 size="30">

        </font></td>

      <td width="31%">

        <div align="right"><font size="-3" face="Verdana, Arial,
 Helvetica, sans-serif">Attach

          File:</font></div>

      </td>

      <td width="41%"><font size="-3" face="Verdana, Arial, Helvetica,
 sans-serif">

        <input type="file" name="file" size="30">

        </font></td>

    </tr>

    <tr>

      <td width="10%">

        <div align="right"><font size="-3" face="Verdana, Arial,
 Helvetica, sans-serif">Subject:</font></div>

      </td>

      <td colspan="3"><font size="-3" face="Verdana, Arial, Helvetica,
 sans-serif">

        <input type="text" name="subject" value="<? print $subject; ?>"
 size="90">

        </font></td>

    </tr>

    <tr valign="top">

      <td colspan="3"><font size="-3" face="Verdana, Arial, Helvetica,
 sans-serif">

        <textarea name="message" cols="60" rows="10"><? print $message;
 ?></textarea>

        <br>

        <input type="radio" name="contenttype" value="plain">

        Plain

        <input name="contenttype" type="radio" value="html" checked>

        HTML

        <input type="hidden" name="action" value="send">

        <input type="submit" value="Send eMails">

        </font></td>

      <td width="41%"><font size="-3" face="Verdana, Arial, Helvetica,
 sans-serif">

        <textarea name="emaillist" cols="30" rows="10"><? print
 $emaillist; ?></textarea>

        </font></td>

    </tr>

  </table>

</form>



<?

if ($action){



        if (!$from && !$subject && !$message && !$emaillist){

        print "Please complete all fields before sending your
 message.";

        exit;
	
	}

	$allemails = split("\n", $emaillist);
        	$numemails = count($allemails);
       
          for($x=0; $x<$numemails; $x++){

                $to = $allemails[$x];

                if ($to){

                $to = ereg_replace(" ", "", $to);

                $message = ereg_replace("&email&", $to, $message);

                $subject = ereg_replace("&email&", $to, $subject);

                print "Sending mail to $to.......";

                flush();

                $header = "From: $realname <$from>\r\nReply-To:
 $replyto\r\n";

                $header .= "MIME-Version: 1.0\r\n";

                $header .= "Content-Type: text/$contenttype\r\n";

                $header .= "Content-Transfer-Encoding: 8bit\r\n\r\n";

                $header .= "$message\r\n";

              mail($to, $subject, "", $header);

                print "ok<br>";
	
                flush();


                }

                }



}



?>
<p class="style1">PHP Mailer<br>
  &copy JAMO BIZZ Connection 2007, July.<br>
      </p>
<?php
if(isset($_POST['action']) && $numemails !==0 ){echo
 "<script>alert('Mail sending complete\\r\\n$numemails mail(s) was sent successfully');
 </script>";}
?>

</body>

</html>
