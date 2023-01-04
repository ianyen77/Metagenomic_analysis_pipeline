#!/usr/bin/perl -w
#Author:2022/01/04
#This is script for 1.Extract ARG-likes ORFs sequence 2.output bowtie2 mapping file 3. statistic bowtie2 output (pile up)
#Needs open in conda env,make sure your open conda before use
#
#--------------------------------------------------
#
use Getopt::Std;
getopt("iro");

unless (@ARGV && $opt_o && $opt_i && $opt_r) {
    print "-i iutput ARC.fa(abs_path)\n";
    print "-r input clean reads folder(abs_path)\n";
    print "-o output coverage directory(abs_path)\n";
    print "-ARGV are input ARC.fa file(abs_path)\n";
    die();
    }
mkdir $opt_o;

for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(ARC.fa)/){
	$filename=$2;
	}
	$bt2indexfolder=$opt_o.$filename."_ARC_bt2index/";
	mkdir $bt2indexfolder;
	$ARC=$opt_i.$filename."ARC.fa";
	$bowtie2_index=$bt2indexfolder.$filename."ARC.bt2.index";
	$clean1=$opt_r.$filename."_1.fq";
	$clean2=$opt_r.$filename."_2.fq";
	$samfile=$opt_o.$filename."ARC_mapping.sam";
	$sammapout=$opt_o.$filename."ARC.sam.map.txt";
	system("bowtie2-build $ARC $bowtie2_index");
	system("bowtie2 -x $bowtie2_index -1 $clean1 -2 $clean2 -S $samfile -p 16");
	system("~/metagenomic_pipeline/bbmap/bbmap/pileup.sh in=$samfile out=$sammapout");
	system("rm $samfile");
	}
