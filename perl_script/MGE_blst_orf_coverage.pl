#!/usr/bin/perl -w
#Author:Ian
#DATE:2023/04/16
#This is script for 0. prediction MGE like orf 1.Extract MGE-likes ORFs fasta 2.output bowtie2 mapping file 3. statistic bowtie2 output (pile up) 4. use R to stastic coverage
#Needs open in conda env,make sure your open conda before use(perl can't do that,so make sure you use activate base env before use this scripts)
#--------------------------------------------------
#
use Getopt::Std;
getopt("bforp");

unless (@ARGV && $opt_b && $opt_o && $opt_f && $opt_r &&$opt_p) {
    print "-b bin Directory(abs_path ie ~/perlscript/)\n";
    print "-f input ORF directory(abs_path)\n";
    print "-r input clean reads(loction_merge) folder(abs_path)\n";
    print "-o output coverage directory(abs_path)\n";
    print "-p MGE-like_ORF output .fa file (abs_path)\n";
    die();
    }
    
$script1=$opt_b."diamond_blast_ORFlist_extract.pl";
mkdir $opt_o;
mkdir $opt_p;

for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(.nucl)/){
	$filename=$2;
	}
	$ARGORFlist=$opt_o.$filename.".MGE_ORFlist.txt";
	$diamondout=$opt_o.$filename."MGE.dmnd";
	$ORF=$opt_f.$filename.".nucl";
	$extractseq=$opt_p.$filename.".MGE-like_ORF.fa";
	$bowtie2_index=$opt_o.$filename.".MGE_like_ORF.bt2.index";
	$clean1=$opt_r.$filename."_1.fq";
	$clean2=$opt_r.$filename."_2.fq";
	$clean1_fa=$opt_r.$filename."_1.fa";
	$clean2_fa=$opt_r.$filename."_2.fa";
	$samfile=$opt_o.$filename."MGE_like_ORFmapping.sam";
	$sammapout=$opt_o.$filename."MGE_like_ORF.sam.map.txt";
	system("diamond blastx -d /media/sf_sf/DB/Diamond/DB/MGEs_2018nature_commu.dmnd -q $ORF -p 16 --id 70 -p 16 -e 1e-10 -f 6 -k 1 --query-cover 70 -o $diamondout");
	system("perl -w $script1 -f $diamondout > $ARGORFlist");
	system("seqkit grep -f $ARGORFlist $ORF -o $extractseq");
	system("bowtie2-build $extractseq $bowtie2_index");
	system("bowtie2 -x $bowtie2_index -1 $clean1 -2 $clean2 -S $samfile -p 16");
	system("~/metagenomic_pipeline/bbmap/bbmap/pileup.sh in=$samfile out=$sammapout");
	system("rm $samfile");
	
	if (-e $clean1_fa) {
   	 print "File $clean1_fa exists, skipping code\n";
	}
	else {
    	system("seqkit fq2fa $clean1 -o $clean1_fa -j 16 -w 0");
	}
	if (-e $clean2_fa) {
   	 print "File $clean2_fa exists, skipping code\n";
	}
	else {
    	system("seqkit fq2fa $clean2 -o $clean2_fa -j 16 -w 0");
	}
	
	
#因為bbmap寫出的檔案colnames輸出的問題,R沒辦法讀取到他的columnname,因此我們重新把colname寫過,在寫入一個檔案
$adjustfolder=$opt_o."adjust_bbmapout/";
$coverageout=$opt_o."MGE_lik_orf_coverage/";
chomp $coverageout;
mkdir $coverageout;
chomp $adjustfolder;
mkdir $adjustfolder;
$adjust_samopt=$adjustfolder.$filename."adjust_ARG_like_ORF.sam.map.txt";
open FILE,$sammapout;
open (ADJUST,">",$adjust_samopt);
while(<FILE>){
 if(/#/){
	chomp;
	@column= split /\t/;
	@column[0]="ID";
	$name="$column[0]\t$column[1]\t$column[2]\t$column[3]\t$column[4]\t$column[5]\t$column[6]\t$column[7]\t$column[8]\t$column[9]\t$column[10]\n";
	print ADJUST $name;
	}
else {
chomp;
print ADJUST "$_\n";
}
}
close ADJUST;
close FILE;

#取得data set size(for coverage caculation)
$size1=0;
open SEQF,$clean1_fa;
while(<SEQF>){
if (/>/){
next();}
else{
chomp;
$length1=length $_;
$size1+=$length1;
}
}
close SEQF;
open SEQR,$clean2_fa;
$size2=0;
while(<SEQR>){
if (/>/){
next();}
else{
chomp;
$length2=length $_;
$size2+=$length2;
}
}
close SEQR;
$size=($size1+$size2)/1000000000;
chomp $size;
print "$filename dataset= $size GB\n";

#寫一個暫用的RScript來計算ARC coverage
#指定要用的檔案
$ARC_cov_listall=$coverageout.$filename."MGE_like_orf_cov_all.xlsx";
$ARC_cov_listsel=$coverageout.$filename."MGE_like_orf_cov_select.xlsx";
$SARG_adjust_DB_xlsx="~/metagenomic_pipeline/ARG-OAP/Ublastx_stageone2.2/Ublastx_stageone/DB/SARG_Struturelist_adjust.xlsx";
$rscript = "/home/tungs-lab/temp.R";
open(R,">",$rscript);
$trs = <<RS;
#This is a R script for caculate ARG_like_orf coverage 
#This script can be intgrated in perl script(Suggest)
library(openxlsx)
library(tidyverse)
#先讀取diamond 的output 並且合併基因與抗藥性基因名稱(這邊我們使用重新註釋過的ARC-ORF再次進行blast的結果)
#SARG_adjust_list<-read.xlsx(xlsxFile ="$SARG_adjust_DB_xlsx")
Diamond_SARG_hit<-read.table(file="$diamondout",header=F,sep="\\t")
colnames(Diamond_SARG_hit)<-c("orf_qseqid", "gene", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")
Diamond_SARG_hit_annoate<-Diamond_SARG_hit
#Diamond_SARG_hit_annoate<-merge(Diamond_SARG_hit,SARG_adjust_list,all.x = T)
#Diamond_SARG_hit_annoate<-separate(Diamond_SARG_hit_annoate,Categories_in_database,into=c("type","subtype"),sep="__")
#bbmapadjust檔案讀取
bowtie2_bbmap_mapped_coverage<-read.table(file="$adjust_samopt",header=T,sep="\\t")
colnames(bowtie2_bbmap_mapped_coverage)[colnames(bowtie2_bbmap_mapped_coverage) == 'ID'] <- 'orf_qseqid'
colnames(bowtie2_bbmap_mapped_coverage)[colnames(bowtie2_bbmap_mapped_coverage) == 'Length'] <- 'orf_length'
coverage_dianomd_list<-merge(Diamond_SARG_hit_annoate,bowtie2_bbmap_mapped_coverage,by="orf_qseqid",all.x=T)
coverage_dianomd_list<-coverage_dianomd_list%>%
  filter(!is.na(gene))
#setting parameter for caculate coverage, 1.readlength=illumina reads length 2.size=datasetsize
readslength<-150
size<-$size
#計算coverage
ARC_list_all<-coverage_dianomd_list%>%
  mutate(orf_coverage=(Avg_fold/size))
#ARC_list_select<-ARC_list_all%>%
  #select(orf_qseqid,type,subtype,orf_coverage)
write.xlsx(ARC_list_all,file="$ARC_cov_listall")
#write.xlsx(ARC_list_select,file="$ARC_cov_listsel")

RS
print R $trs;
close R;
system("Rscript $rscript");
system("rm $rscript");
	}
