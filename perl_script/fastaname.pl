use Getopt::Std;
getopt("f");

open FILE,$opt_f;
while(<FILE>){
if ($_=~/>/){
if ($_=~/>(\S+)(.*)/){
chomp $1;
chomp $2;
print "$1\t$2\n";
}
}
}
close FILE;