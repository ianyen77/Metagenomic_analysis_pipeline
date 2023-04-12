#!/usr/bin/perl -w
#Author:ian
#Date:2022/12/19
#This script needs to open in bracken env,make sure you open bracken env in conda
#input clean reads,output kraken_mpa format style report
#-----------------------------------------------------------

use Getopt::Std;
getopt("io");

unless (@ARGV && $opt_o && $opt_i) {
    print "-o output directory(abs_path)\n";
    print "-i iutput clean sequence directory(abs_path)\n";
    print "-ARGV are input clean *_1.fastq file(abs_path)\n";
    die();
}
unless(-e $opt_i){print "input file does not exist!\n\n";die();}
mkdir $opt_o;
for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(_1.fq)/){
	$filename=$2;
	}
	$file1=$opt_i.$filename."_1.fq";
	$file2=$opt_i.$filename."_2.fq";
	$kraken2report=$opt_o.$filename."_kraken2.report";
	$kraken2_mpa_report=$opt_o.$filename."_mpa.txt";
	$kraken2_mpa_report_wildcard=$opt_o."*_mpa.txt";
	$kraken2_mpa_report_combine=$opt_o."combined_mpa.txt";
	system("kraken2 --db /medua/sf_sf/DB/kraken2/DB --threads 18 --confidence 0.1 --report $kraken2report --paired $file1 $file2");
	system("~/KrakenTools-1.2/kreport2mpa.py -r $kraken2report  -o $kraken2_mpa_report");
	}
	system("~/KrakenTools-1.2/combine_mpa.py -i $kraken2_mpa_report_wildcard -o $kraken2_mpa_report_combine");
