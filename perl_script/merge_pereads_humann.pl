#!/usr/bin/perl -w
#This is a script for humann 1. merge pe reads 2. humann
#make sure you opne mpa env in  conda 
use Getopt::Std;

getopt("ioh");

unless (@ARGV && $opt_o && $opt_i) {
    print "-o output directory(abs_path)\n";
    print "-i iutput clean sequence directory(abs_path)\n";
    print "-ARGV are input clean*_1.fastq file(abs_path)\n";
    print "-h humann output dirctory(abs_path)\n";
    die();
}
unless(-e $opt_i){print "input file does not exist!\n\n";die();}
chomp $opt_i;
chomp $opt_o;
mkdir $opt_o;
mkdir $opt_h;
for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(_1.fq)/){
	$filename=$2;
	}
	$file1=$opt_i.$filename."_1.fq";
	$file2=$opt_i.$filename."_2.fq";
	$mergefile=$opt_o."merge_".$filename.".fq";
	system("cat $file1 $file2 > $mergefile");
	system("humann -i $mergefile  -o $opt_h --threads 16 --input-format fastq");
	}
	
