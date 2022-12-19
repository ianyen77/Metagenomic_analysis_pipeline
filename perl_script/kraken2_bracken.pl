#!/usr/bin/perl -w
#Author:ian
#Date:2022/12/19
#This script needs to open in bracken env,make sure you open bracken env in conda
#make sure your create a output folder
#input

use Getopt::Std;
getopt("io");

unless (@ARGV && $opt_o && $opt_i) {
    print "-o output directory(abs_path)\n";
    print "-i iutput clean sequence directory(abs_path)\n";
    print "-ARGV are input clean*_1.fastq file(abs_path)\n";
    die();
}
unless(-e $opt_i){print "input file does not exist!\n\n";die();}
mkdir $opt_o;
for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/clean_)(\S+)(_1.fq)/){
	$filename=$2;
	}
	$foldername=$opt_o.$filename."/";
	mkdir $foldername;
	$file1=$opt_i."clean_".$filename."_1.fq";
	$file2=$opt_i."clean_".$filename."_2.fq";
	$kraken2report=$foldername.$filename."_kraken2.report";
	#如果想要kraken2的output可以把它打開$krake2output=$foldername.$filename."_kraken2.output";
	$bracken_o_D=$foldername.$filename.".D.bracken";
	$bracken_o_P=$foldername.$filename.".P.bracken";
	$bracken_o_C=$foldername.$filename.".C.bracken";
	$bracken_o_O=$foldername.$filename.".O.bracken";
	$bracken_o_F=$foldername.$filename.".F.bracken";
	$bracken_o_G=$foldername.$filename.".G.bracken";
	$bracken_o_S=$foldername.$filename.".S.bracken";
	$bracken_w_D=$foldername.$filename.".D.bracken.report";
	$bracken_w_P=$foldername.$filename.".P.bracken.report";
	$bracken_w_C=$foldername.$filename.".C.bracken.report";
	$bracken_w_O=$foldername.$filename.".O.bracken.report";
	$bracken_w_F=$foldername.$filename.".F.bracken.report";
	$bracken_w_G=$foldername.$filename.".G.bracken.report";
	$bracken_w_S=$foldername.$filename.".S.bracken.report";
	
	system("kraken2 --db ~/kraken2/DB --threads 20 --report $kraken2report --paired $file1 $file2");
	system("bracken -d ~/kraken2/DB -i $kraken2report -o $bracken_o_D -w $bracken_w_D -r 150 -l D");
	system("bracken -d ~/kraken2/DB -i $kraken2report -o $bracken_o_P -w $bracken_w_P -r 150 -l P");
	system("bracken -d ~/kraken2/DB -i $kraken2report -o $bracken_o_C -w $bracken_w_C -r 150 -l C");
	system("bracken -d ~/kraken2/DB -i $kraken2report -o $bracken_o_O -w $bracken_w_O -r 150 -l O");
	system("bracken -d ~/kraken2/DB -i $kraken2report -o $bracken_o_F -w $bracken_w_F -r 150 -l F");
	system("bracken -d ~/kraken2/DB -i $kraken2report -o $bracken_o_G -w $bracken_w_G -r 150 -l G");
	system("bracken -d ~/kraken2/DB -i $kraken2report -o $bracken_o_S -w $bracken_w_S -r 150 -l S");
	}
