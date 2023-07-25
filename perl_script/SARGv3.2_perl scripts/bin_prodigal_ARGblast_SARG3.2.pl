#!/usr/bin/perl -w
#Author:IAN
#DATE:2022/12/22
#this is a script for assembly and ORF prediction
#input=clean reads output=contig&orf predictions
#-------------------------------------------------------

use Getopt::Std;
getopt("ipomvb");

unless (@ARGV && $opt_i && $opt_p && $opt_o && $opt_m && $opt_v &&$opt_b) {
    print "-i iutput bin_contig.fa directory(abs_path)\n";
    print "-p output prodigal directory(abs_path)\n";
    print "-ARGV are input iutput bin_contig.fa file(abs_path)\n";
    print "-o output SARG diamond blast directory(abs_path)\n";
    print "-m output MGE diamond blast directory(abs_path)\n";
    print "-v output VF diamond blast directory(abs_path)\n";
    print "-b output BacMet diamond blast directoury(abs_path)\n";
    die();}
    
unless(-e $opt_i){print "input file does not exist!\n\n";die();}
mkdir $opt_p;
mkdir $opt_o;
mkdir $opt_m;
mkdir $opt_v;
mkdir $opt_b;
chomp $opt_i;

for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(.fa)/){
	$filename=$2;
	}
	$bin=$opt_i.$filename.".fa";
	chomp $bin;
	$prodigalout=$opt_p.$filename.".prodigalout";
	$prodigalout_p=$opt_p.$filename.".protein";
	$prodigalout_nucl=$opt_p.$filename.".nucl";
	$diamondout=$opt_o.$filename.".SARG.dmnd";
	$MGE_diamond=$opt_m.$filename.".MGEs.dmnd";
	$VF_diamond=$opt_v.$filename.".VF.dmnd";
	$bac_diamond=$opt_b.$filename.".BacMet.dmnd";
	system("prodigal -i $bin -o $prodigalout -a $prodigalout_p -d $prodigalout_nucl -p meta");
	system("diamond blastx -d /media/sf_sf/DB/Diamond/DB/SARG_v3.2_20220917_Full_database.dmnd -q $prodigalout_nucl -p 16 --id 70 -p 16 -e 1e-10 -f 6 -k 1 --query-cover 70 -o $diamondout");
	system("diamond blastx -d /media/sf_sf/DB/Diamond/DB/MGEs_2018nature_commu.dmnd -q $prodigalout_nucl -p 16 --id 70 -p 16 -e 1e-10 -f 6 -k 1 --query-cover 70 -o $MGE_diamond");
	system("diamond blastx -d /media/sf_sf/DB/Diamond/DB/VFDB_coredataset.dmnd -q $prodigalout_nucl -p 16 --id 70 -p 16 -e 1e-10 -f 6 -k 1 --query-cover 70 -o $VF_diamond");
	system("diamond blastx -d /media/sf_sf/DB/Diamond/DB/bacmet_experiment.dmnd -q $prodigalout_nucl -p 16 --id 70 -p 16 -e 1e-10 -f 6 -k 1 --query-cover 70 -o $bac_diamond");

	}
