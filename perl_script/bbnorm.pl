#!/usr/bin/perl -w
#Author:IAN
#DATE:2022/12/22
#this is a script for clean reads depth normalize
#input=clean reads output=normalized clean reads
#-------------------------------------------------------

use Getopt::Std;
getopt("io");

unless (@ARGV && $opt_o && $opt_i ) {
    print "-o output nromalize clean reads directory(abs_path)\n";;
    print "-i iutput clean sequence directory(abs_path)\n";
    print "-ARGV are input clean*_1.fastq file(abs_path)\n";
    die();}
    
unless(-e $opt_i){print "input file does not exist!\n\n";die();}
mkdir $opt_o;
for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(_1.fq)/){
	$filename=$2;
	}
	$file1=$opt_i.$filename."_1.fq";
	$file2=$opt_i.$filename."_2.fq";
	$nf_1=$opt_o."n".$filename."_1.fq";
	$nf_2=$opt_o."n".$filename."_2.fq";
	system("/home/tungs-lab/metagenomic_pipeline/bbmap/bbmap/bbnorm.sh in1=$file1 in2=$file2 out1=$nf_1 out2=$nf_2");
	}
