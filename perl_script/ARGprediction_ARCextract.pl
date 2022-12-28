#!/usr/bin/perl -w
#Author:2022/12/26
#This is script for 1.annonation ARG like-ORF(all contig) and 2.Extract ARC fasta and 3.predict ARC ORF
#Needs open in conda env,make sure your open conda before use
#----------------------------------
#
use Getopt::Std;
getopt("bicoa");

unless (@ARGV && $opt_b && $opt_o && $opt_i && $opt_a && $opt_c) {
    print "-b bin Directory(abs_path ie ~/perlscript/)\n";
    print "-i iutput ORF directory(abs_path)\n";
    print "-c input Contig directory(abs_path)\n";
    print "-o output diamond directory(abs_path)\n";
    print "-a output ARC directory(abs_path)\n";
    print "-ARGV are input orf.nucl file(abs_path)\n";
    die();
    }
    
$script1=$opt_b."diamond_blasted_seqlist_extract.pl";
mkdir $opt_o;
mkdir $opt_a;
$ARCorffolder=$opt_a."ARC_ORF/";
mkdir $ARCorffolder;
$ARCorfnrblast=$ARCorffolder."ARC_ORF_NRblast/";
mkdir $ARCorfnrblast
for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(.nucl)/){
	$filename=$2;
	}
	
	$orf=$opt_i.$filename.".nucl";
	$diamondout=$opt_o.$filename."SARG.dmnd";
	$ARClistopt=$opt_o.$filename."ARC_list.txt";
	$contig=$opt_c.$filename."final.contigs";
	$extractseq=$opt_a.$filename."ARC.fa";
	$prodigalout=$ARCorffolder.$filename.".prodigalout";
	$prodigalout_p=$ARCorffolder.$filename.".protein";
	$prodigalout_nucl=$ARCorffolder.$filename.".nucl";
	$diamondoutnr=$ARCorfnrblast.$filename".nrblast.daa";
	#diamond blastx的參數要在修正及跟老師討論
	system("diamond blastx -d ~/DB/Diamond/DB/SARG2.2_DB.dmnd -q $orf --id 50 -p 16 -e 1e-5 -f 6 -k 1 --query-cover 50 -o $diamondout");
	system("perl -w $script1 -f $diamondout > $ARClistopt");
	system("seqkit grep -f $ARClistopt $contig -o $extractseq");
	system("prodigal -i $extractseq -o $prodigalout -a $prodigalout_p -d $prodigalout_nucl -c -p meta");
	system("diamond blastp -d ~/DB/Diamond/DB/nr.dmnd -q $prodigalout_p -p 18 -b 16 -e 1e-5 -f 100 -o $diamondoutnr");
	}
