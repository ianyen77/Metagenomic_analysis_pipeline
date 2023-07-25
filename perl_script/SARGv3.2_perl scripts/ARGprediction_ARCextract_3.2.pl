#!/usr/bin/perl -w
#Author:2022/12/26
#This is script for 1.annonation ARG like-ORF(all contig) and 2.Extract ARC fasta and 3.predict ARC ORF 4.blast ACCs to nr
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
while (1) {
    print "Check DB and blast parameter\n";
    print "diamond blastx -d /media/sf_sf/DB/Diamond/DB/v2.1.8_diamond_DB/1.SARG_v3.2_20220917_Full_database.dmnd  -p 16 --id 70 -p 16 -e 1e-10 -f 6 -k 1 --query-cover 70\n";
    print "If the command is right, type yes\n";
    $response = <STDIN>;
    chomp($response);

    # 檢查回答是否為"yes"
    if ($response eq "yes") {
        last;  # 如果回答是"yes"，跳出循環
    } else {
        print "Adjust your DB and parameter in script\n";
        die();
    }
}

$script1=$opt_b."diamond_blasted_contiglist_extract.pl";
mkdir $opt_o;
mkdir $opt_a;
$ARCorffolder=$opt_a."ARC_ORF/";
mkdir $ARCorffolder;
$ARCorfnrblast=$ARCorffolder."ARC_ORF_NRblast/";
mkdir $ARCorfnrblast;
$ARCorfrediamond=$ARCorffolder."ARC_ORF_SARGreblast/";
mkdir $ARCorfrediamond;
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
	$ARCorfrediamondout=$ARCorfrediamond.$filename."reblast_SARG.dmnd";
	$diamondoutnr=$ARCorfnrblast.$filename.".nrblast.daa";
	#NOTICE PARAMETERS
	system("diamond blastx -d /media/sf_sf/DB/Diamond/v2.1.8_diamond_DB/1.SARG_v3.2_20220917_Full_database.dmnd -q $orf -p 16 --id 70 -p 16 -e 1e-10 -f 6 -k 1 --query-cover 70 -o $diamondout");
	system("perl -w $script1 -f $diamondout > $ARClistopt");
	system("seqkit grep -f $ARClistopt $contig -o $extractseq");
	system("prodigal -i $extractseq -o $prodigalout -a $prodigalout_p -d $prodigalout_nucl -p meta");
	system("diamond blastx -d /media/sf_sf/DB/Diamond/v2.1.8_diamond_DB/1.SARG_v3.2_20220917_Full_database.dmnd -q $prodigalout_nucl -p 16 --id 70 -p 16 -e 1e-10 -f 6 -k 1 --query-cover 70 -o $ARCorfrediamondout");
	#system("diamond blastp -d /media/sf_sf/DB/Diamond/DB/nr.dmnd -q $prodigalout_p -p 16 -b 16 -e 1e-5 -f 100 -o $diamondoutnr");
	}
