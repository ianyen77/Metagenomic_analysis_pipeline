#!/usr/bin/perl -W
#This is the script for extract ARC contig name list from  diamondblasted output (blast6format)
#Author:IAN
#DATE:2022/01/04

use Getopt::Std;
getopt("f");

unless ($opt_f) {
    print "-f input .dmnd file\n";
    die();
}

open FILE,$opt_f;
while (<FILE>) {
    if (/(\S+)(\t)/){
    chomp $1;
        print "$1\n";
    }
}
close FILE;
