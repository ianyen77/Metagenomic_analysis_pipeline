#!/usr/bin/perl -w
use Getopt::Std;
getopt("io");
mkdir $opt_o;
for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(-1_1.fq)/){
	$filename=$2;
	$f1=$opt_i.$filename."-1_1.fq";
	$f2=$opt_i.$filename."-2_1.fq";
	$f3=$opt_i.$filename."-3_1.fq";
	$f4=$opt_i.$filename."-1_2.fq";
	$f5=$opt_i.$filename."-2_2.fq";
	$f6=$opt_i.$filename."-3_2.fq";
	$f_1=$opt_o.$filename."_1.fq";
	$f_2=$opt_o.$filename."_2.fq";
	system("cat $f1 $f2 $f3 >$f_1");
	system("cat $f4 $f5 $f6 >$f_2");
}
}
