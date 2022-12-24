#!/usr/bin/perl -w
#Author:IAN
#DATE:2022/12/22
#this is a script for assembly and ORF prediction
#input=clean reads output=contig&orf predictions
#-------------------------------------------------------

use Getopt::Std;
getopt("icp");

unless (@ARGV && $opt_c && $opt_i && $opt_p) {
    print "-c output contig directory(abs_path)\n";
    print "-p output prodigal directory(abs_path)\n";
    print "-i iutput clean sequence directory(abs_path)\n";
    print "-ARGV are input clean*_1.fastq file(abs_path)\n";
    die();}
    
unless(-e $opt_i){print "input file does not exist!\n\n";die();}
mkdir $opt_c;
mkdir $opt_p;
if ($opt_c=~ /(\S+)(\/)/){
	$mvdirectory=$1;}
for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(_1.fq)/){
	$filename=$2;
	}
	$file1=$opt_i.$filename."_1.fq";
	$file2=$opt_i.$filename."_2.fq";
	$megahitout=$opt_c.$filename."_contig";
	$megahitcontig=$filename."final.contigs";
	$prodigalout=$opt_p.$filename.".prodigalout";
	$prodigalout_p=$opt_p.$filename.".protein";
	$prodigalout_nucl=$opt_p.$filename.".nucl";
	
	system("megahit -t 18 -m 0.95 -1 $file1 -2 $file2 --min-contig-len 500 -o $megahitout");
	system("mv $megahitout/final.contigs.fa $megahitout/$megahitcontig");
	system("mv $megahitout/$megahitcontig $mvdirectory");
	system("rm -r $megahitout/");
	system("prodigal -i $mvdirectory/$megahitcontig -o $prodigalout -a $prodigalout_p -d $prodigalout_nucl -c -p meta");

	}
