#!/usr/bin/perl -w
#Author:2022/01/04
#This is script for 1.Extract ARG-likes ORFs sequence 2.output bowtie2 mapping file 3. statistic bowtie2 output (pile up)
#Needs open in conda env,make sure your open conda before use
#
#--------------------------------------------------
#
use Getopt::Std;
getopt("birom");

unless (@ARGV && $opt_o && $opt_i && $opt_r && $opt_b && $opt_m) {
    print "-b bin folder of perl script\n";
    print "-i iutput ARC.fa(abs_path)\n";
    print "-r input clean reads folder(abs_path)\n";
    print "-o output coverage directory(abs_path)\n";
    print "-m meganout directory(ARC.xlsx)(abs_path)\n";
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
	$clean1_fa=$opt_r.$filename."_1.fa";
	$clean2_fa=$opt_r.$filename."_2.fa";
	$samfile=$opt_o.$filename."ARC_mapping.sam";
	$sammapout=$opt_o.$filename."ARC.sam.map.txt";
	$script=$opt_b."contig_length.pl";
	$contiglen=$opt_o.$filename.".contiglen.txt";
	system("bowtie2-build $ARC $bowtie2_index");
	system("bowtie2 -x $bowtie2_index -1 $clean1 -2 $clean2 -S $samfile -p 16");
	system("~/metagenomic_pipeline/bbmap/bbmap/pileup.sh in=$samfile out=$sammapout");
	system("rm $samfile");
	system("perl-w $script -f $ARC > $contiglen");
	
#因為bbmap寫出的檔案colnames輸出的問題,R沒辦法讀取到他的columnname,因此我們重新把colname寫過,在寫入一個檔案
$adjustfolder=$opt_o."adjust_mapout/";
chomp $adjustfolder;
mkdir $adjustfolder;
$adjust_samopt=$adjustfolder.$filename."adjustcol_ARC.sam.map.txt";
open FILE,$sammapout;
open (ADJUST,">",$adjust_samopt);
while(<FILE>){
 if(/#/){
	chomp;
	@column= split /\t/;
	@column[0]="ID";
	$name="@column[0]\t@column[1]\t@column[2]\t@column[3]\t@column[4]\t@column[5]\t@column[6]\t@column[7]\t@column[8]\t@column[9]\t@column[10]\n";
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
open SEQF,$clean1;
while(<SEQF>){
if (/>/){
next();}
else{
chomp;
$length1=length $_;
$file1+=$length1;
}
}
close SEQF;
open SEQR,$clean2;
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

$size=($size1+$size2)/1000000000;
chomp $size;

#寫一個暫用的RScript來計算ARC coverage
#指定要用的檔案
$ARC_class_xlsx=$opt_m.$filename."ARC_classfication.xlsx";
$ARC_cov_listall=$opt_o.$filename."ARC_class_cov_all.xlsx";
$ARC_cov_listsel=$opt_o.$filename."ARC_class_cov_select.xlsx";
$rscript = "/home/tungs-lab/temp.R";
open(R,">",$rscript);
$trs = <<RS;
#This is a R script for caculate contig coverage 
#This script can be intgrated in perl script(Suggest)
library(openxlsx)
library(tidyverse)
#把處理過的ARCmegan.xlsx檔案讀取
dianomd_annotate_orf<-read.xlsx(xlsxFile="$ARC_class_xlsx",rowNames=F,colNames=T,sheet=1)
bowtie2_bbmap_mapped_coverage<-read.table(file="$adjust_samopt",header=T,sep="\\t")
colnames(bowtie2_bbmap_mapped_coverage)[colnames(bowtie2_bbmap_mapped_coverage) == 'ID'] <- 'contig'
colnames(bowtie2_bbmap_mapped_coverage)[colnames(bowtie2_bbmap_mapped_coverage) == 'Length'] <- 'Contig_length'
coverage_dianomd_list<-merge(dianomd_annotate_orf,bowtie2_bbmap_mapped_coverage,by="contig",all.x=T)
coverage_dianomd_list<-coverage_dianomd_list%>%
  filter(!is.na(gene))
#setting parameter for caculate coverage, 1.readlength=illumina reads length 2.size=datasetsize
readslength<-150
size<-$size
#計算coverage
ARC_list_all<-coverage_dianomd_list%>%
  mutate(contig_coverage=(Avg_fold*readslength/(Contig_length*size)))
ARC_list_select<-ARC_list_all%>%
  select(contig,qseqid,type,subtype,contig_taxon,megan_vote_percent,contig_coverage)
write.xlsx(ARC_list_all,file="$ARC_cov_listall")
write.xlsx(ARC_list_select,file="$ARC_cov_listsel")

RS
print R $trs;
close R;
system("Rscript $rscript");
system("rm $rscript");
	}
