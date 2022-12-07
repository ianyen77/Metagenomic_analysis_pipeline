#!/usr/bin/perl -W
#This is the script for extract sequence name list from  diamondblasted output (blast6format)
#Author:IAN
#DATE:2022/11/28

use Getopt::Std;
getopt("f");

unless ($opt_f) {
    print "-f input .dmnd file\n";
    die();
}

open FILE,$opt_f;
$count=0;
while (<FILE>) {
    if (/(\S+)(_.*)\t/){
        print "$1\n";
    }
}
close FILE;
