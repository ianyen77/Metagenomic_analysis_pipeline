#!/usr/bin/perl -W
#This is the script for extracted ARC(contig contain at lest 1 arg) from diamondextract list
#Author:IAN
#DATE:2022/11/28
#This script need to run in conda env, you needs to open conda env first
use Getopt::Std;
getopt("boi");

unless (@ARGV && $opt_b && $opt_o && $opt_i) {
    print "-b bin Directory(abs_path ie ~/perlscript/)\n";
    print "-o output directory(abs_path)\n";
    print "-i iutput contig file directory(abs_path)\n";
    print "-ARGV are input .dmnd file(abs_path)\n";
    die();
}

$script=$opt_b."diamond_blasted_seqlist_extract.pl";
mkdir "$opt_o";

for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(SARG.dmnd)/){
	$filename=$2;
	}
	$listopt=$opt_o.$filename."_ARC_list.txt";
	system("perl -w $script -f $ARGV[$x] > $listopt");
	
	#must notice name of contig file
	$contig=$opt_i.$filename.".contig.fa";
	$extractseq=$opt_o.$filename.".ARC.fa";
	
	system("seqkit grep -f $listopt $contig -o $extractseq");
	}
