use Getopt::Std;
getopt("f");

$count=0;
open FILE,$opt_f;
while(<FILE>){
chomp;
if($_=~/>/){
$count++;}
}
close FILE;
print "$count\n";

