#!/usr/bin/perl -w
#Author:IAN;
#DATE:2022/12/16
#This script must be run in conda base environment,make sure you already opened  the conda environment

use Getopt::Std;
getopt("io");

unless (@ARGV && $opt_o && $opt_i) {
    print "-o output directory(abs_path)\n";
    print "-i iutput  file directory(abs_path)\n";
    print "-ARGV are input _1.fastq file(abs_path)\n";
    die();
}
unless(-e $opt_i){print "input file does not exist!\n\n";die();}
mkdir "$opt_o";

for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(_1.fq)/){
	$filename=$2;
	}
	
	$filename1=$opt_i.$filename."_1.fq";
	$filename2=$opt_i.$filename."_2.fq";
	$output1=$opt_o."clean_".$filename."_1.fq";
	$output2=$opt_o."clean_".$filename."_2.fq";
	$outputj=$opt_o.$filename.".json";
	$outputh=$opt_o.$filename.".html";
	system("fastp -i $filename1 -I $filename2 -o $output1 -O $output2 -w 16 -j $outputj -h $outputh");
	}
