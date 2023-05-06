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
$krakenout=$opt_o."kraken2out/";
$brackenout=$opt_o."bracken2out/";
mkdir $krakenout;
mkdir $brackenout;
for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(_1.fq)/){
	$filename=$2;
	}
	$file1=$opt_i.$filename."_1.fq";
	$file2=$opt_i.$filename."_2.fq";
	$kraken2report=$krakenout.$filename."_kraken2.report";
	#如果想要kraken2的output可以把它打開$krake2output=$foldername.$filename."_kraken2.output";
	$bracken_o_D=$brackenout.$filename.".D.bracken";
	$bracken_o_P=$brackenout.$filename.".P.bracken";
	$bracken_o_C=$brackenout.$filename.".C.bracken";
	$bracken_o_O=$brackenout.$filename.".O.bracken";
	$bracken_o_F=$brackenout.$filename.".F.bracken";
	$bracken_o_G=$brackenout.$filename.".G.bracken";
	$bracken_o_S=$brackenout.$filename.".S.bracken";
	$bracken_w_D=$brackenout.$filename.".D.bracken.report";
	$bracken_w_P=$brackenout.$filename.".P.bracken.report";
	$bracken_w_C=$brackenout.$filename.".C.bracken.report";
	$bracken_w_O=$brackenout.$filename.".O.bracken.report";
	$bracken_w_F=$brackenout.$filename.".F.bracken.report";
	$bracken_w_G=$brackenout.$filename.".G.bracken.report";
	$bracken_w_S=$brackenout.$filename.".S.bracken.report";
	
	system("kraken2 --db /media/sf_sf/DB/kraken2/DB/bacteria_DB --confidence 0.1 --threads 18 --report $kraken2report --paired $file1 $file2");
	system("bracken -d /media/sf_sf/DB/kraken2/DB/bacteria_DB -i $kraken2report -o $bracken_o_D -w $bracken_w_D -r 150 -l D");
	system("bracken -d /media/sf_sf/DB/kraken2/DB/bacteria_DB -i $kraken2report -o $bracken_o_P -w $bracken_w_P -r 150 -l P");
	system("bracken -d /media/sf_sf/DB/kraken2/DB/bacteria_DB -i $kraken2report -o $bracken_o_C -w $bracken_w_C -r 150 -l C");
	system("bracken -d /media/sf_sf/DB/kraken2/DB/bacteria_DB -i $kraken2report -o $bracken_o_O -w $bracken_w_O -r 150 -l O");
	system("bracken -d /media/sf_sf/DB/kraken2/DB/bacteria_DB -i $kraken2report -o $bracken_o_F -w $bracken_w_F -r 150 -l F");
	system("bracken -d /media/sf_sf/DB/kraken2/DB/bacteria_DB -i $kraken2report -o $bracken_o_G -w $bracken_w_G -r 150 -l G");
	system("bracken -d /media/sf_sf/DB/kraken2/DB/bacteria_DB -i $kraken2report -o $bracken_o_S -w $bracken_w_S -r 150 -l S");
	}
