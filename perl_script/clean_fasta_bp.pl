#!/usr/bin/perl -w
#opt_r=input cleanread directory(abs.path)
use Getopt::Std;
getopt("r");
print "sample\treadsnumber\tbp\n";
for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(_1.fa)/){
	$filename=$2;
	chomp $filename;
	}
$clean1=$opt_r.$filename."_1.fa";
$clean2=$opt_r.$filename."_2.fa";
$file1=0;
$count1=0;
open FILE,$clean1;
while(<FILE>){
if (/>/){
$count1++;
next();}
else{
chomp;
$length=length $_;
$file1+=$length;
}
}
close FILE;

open SEQ,$clean2;
$file2=0;
$count2=0;
while(<SEQ>){
if (/>/){
$count2++;
next();}
else{
chomp;
$length=length $_;
$file2+=$length;
}
}
close SEQ;

$file_f=$filename."_1";
$file_r=$filename."_2";
print "$file_f\t$count1\t$file1\n$file_r\t$count2\t$file2\n";	
}













