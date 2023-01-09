#!/usr/bin/perl -w
use Getopt::Std;
getopt("fr");
$file1=0;
open FILE,$opt_f;
while(<FILE>){
if (/>/){
next();}
else{
chomp;
$length=length $_;
$file1+=$length;
}
}
close FILE;

open SEQ,$opt_r;
$file2=0;
while(<SEQ>){
if (/>/){
next();}
else{
chomp;
$length=length $_;
$file2+=$length;
}
}
close SEQ;

$datasetsize=$file1+$file2;

print "$datasetsize\n";














