#This is a script for extract gene name form vfdb fasta file

use Getopt::Std;

getopt("f");
open FILE,$opt_f;
while(<FILE>){
if ($_=~/>/){
if ($_=~/>(\S+)\s(\S+)\s(.*)\s(\[.*\])\s(\[.*\])/){
#VFG001383(gb|NP_214989) (hbhA) iron-regulated heparin binding hemagglutinin hbhA (adhesin) [HbhA (VF0313) - Adherence (VFC0001)] [Mycobacterium tuberculosis H37Rv]

chomp $1;
chomp $2;
chomp $3;
chomp $4;
chomp $5;


print "$1\t$2\t$3\t$4\t$5\t$6\n";

}

}

}

close FILE;
