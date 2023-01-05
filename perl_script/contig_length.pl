#!/usr/bin/perl -w
#This is script for megahit out contig fa file 
use Getopt::Std;
getopt("f");
$count=0;
open FILE,$opt_f;
while(<FILE>){
chomp;
if($_=~/>/){
if($_=~/>(.*)\s(.*)\s(.*)\s(.*)=(\d*)/){
$name=$1;
$len=$5;
chomp $name;
chomp $len;
print"$name\t$len\n";}
}
}
close FILE;
