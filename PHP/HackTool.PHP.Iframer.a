<?
	function get_rnd_var() {return 'v'.uniqid('');}
	function get_value($v, &$codebuf) 
	{
		$var1 = get_rnd_var();
		$var2 = get_rnd_var();
		
		$vars = array(
			"$v",
			$var1,
			$var1.'()',
			$var1.'()',
		); 
		$bufs = array(
			"",
			"var $var1=$v;",
			"function $var1 () {return $v;}",
			"function $var1 () {var $var2=$v; return $var2;}",
		);
		$item = rand(0, count($vars)-1);
		$codebuf .= $bufs[$item];
		return $vars[$item];
	}
	
	function encode_scuko ($q)
	{
		$r='';
		for($i=0;$i<strlen($q);$i++)
		{
			$hex=dechex(ord($q[$i]));
			if (strlen($hex)==1) $hex = '0'.$hex;
			$r .= $hex;
		}
		$r=strtoupper($r);
		
		$hex2dec=get_rnd_var();
		$hex=get_rnd_var();
		$codebuf1 = '';
		$value16 = get_value(16, $codebuf1);
		$c="function $hex2dec($hex){ $codebuf1 return(parseInt($hex,$value16));}";
		
		$deco=get_rnd_var();
		$t=get_rnd_var();
		$s=get_rnd_var();
		$i=get_rnd_var();
		$codebuf2 = '';
		$value2 = get_value(2, $codebuf2);
		$c.="function $deco($t){ $codebuf2 var $s='';for($i=0; $i<$t.length; $i+=$value2){ $s+=(String.fromCharCode($hex2dec($t.substr($i, $value2))));}return $s;}";
		$r="document.write($deco('$r'));";
		return "<script>$c $r</script>";
	}
?>