#!/usr/bin/perl -w
#this script is for contigs qc
#quast needs to open in conda make sure you activate conda
#working directory needs to in quast
use Getopt::Std;
getopt("io");

unless (@ARGV && $opt_o && $opt_i) {
    print "-o output directory(abs_path)\n";
    print "-i iutput contigs directory(abs_path)\n";
    print "-ARGV are input contigs file(abs_path)\n";
    die();
}
unless(-e $opt_i){print "input file does not exist!\n\n";die();}
chomp $opt_i;
chomp $opt_o;
mkdir $opt_o;
for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(final.contigs)/){
	$filename=$2;
	}
	$megahitcontig=$opt_i.$filename."final.contigs";
	$quastreport=$opt_o.$filename."quastreprot";
	system("/home/tungs-lab/metagenomic_pipeline/Quast/quast-5.2.0/quast.py $megahitcontig -o $quastreport");
	}
	

