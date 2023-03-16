use Getopt::Std;
getopt("i");

open FILE,$opt_i;
while(<FILE>){
if (/(k141_.*)(_.*)/){
    $seq=$1;
    print "$seq\t$name\n";}
else{
if(/(.*)(\s\W\d*\W)/){
    $name=$1;}
}
}
close FILE;
