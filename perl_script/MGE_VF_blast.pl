#!/usr/bin/perl -w
#Author:2023/03/04
#This is script for 1.blast ARC_orf with MGE_DB 2.blast ARC_ORF with VF_DB
#----------------------------------
#
use Getopt::Std;
getopt("imvb");

unless (@ARGV && $opt_m && $opt_i && $opt_v &&$opt_b ){
    print "-i iutput ARC_ORF directory(abs_path)\n";
    print "-m output MGE diamond blast directory(abs_path)\n";
    print "-v output VF diamond blast directory(abs_path)\n";
    print "-ARGV are input orf.nucl file(abs_path)\n";
    print "-b output BacMet diamond blast directoury(abs_path)\n";
    die();
    }
mkdir $opt_b;
mkdir $opt_m;
mkdir $opt_v;
for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(.nucl)/){
	$filename=$2;
	}
	$orf=$opt_i.$filename.".nucl";
	$MGE_diamond=$opt_m.$filename."MGEs.dmnd";
	$VF_diamond=$opt_v.$filename."VF.dmnd";
	$bac_diamond=$opt_b.$filename."BacMet.dmnd";
	system("diamond blastx -d /media/sf_sf/DB/Diamond/DB/MGEs_2018nature_commu.dmnd -q $orf -p 16 --id 70 -p 16 -e 1e-10 -f 6 -k 1 --query-cover 70 -o $MGE_diamond");
	system("diamond blastx -d /media/sf_sf/DB/Diamond/DB/VFDB_coredataset.dmnd -q $orf -p 16 --id 70 -p 16 -e 1e-10 -f 6 -k 1 --query-cover 70 -o $VF_diamond");
	system("diamond blastx -d /media/sf_sf/DB/Diamond/DB/bacmet_experiment.dmnd -q $orf -p 16 --id 70 -p 16 -e 1e-10 -f 6 -k 1 --query-cover 70 -o $bac_diamond");
	}
