#!/usr/bin/perl -w
#Author:2022/01/04
#This is script for 1.Extract ARG-likes ORFs sequence 2.output bowtie2 mapping file 3. statistic bowtie2 output (pile up)
#Needs open in conda env,make sure your open conda before use
#
#--------------------------------------------------
#
use Getopt::Std;
getopt("biro");

unless (@ARGV && $opt_o && $opt_i && $opt_r && $opt_b) {
    print "-b bin folder of perl script\n";
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
	$script=$opt_b."contig_length.pl";
	$contiglen=$opt_o.$filename.".contiglen.txt";
	system("bowtie2-build $ARC $bowtie2_index");
	system("bowtie2 -x $bowtie2_index -1 $clean1 -2 $clean2 -S $samfile -p 16");
	system("~/metagenomic_pipeline/bbmap/bbmap/pileup.sh in=$samfile out=$sammapout");
	system("rm $samfile");
	system("perl-w $script -f $ARC > $contiglen");
$ARC_class_xlsx="/home/tungs-lab/test_megan_out/".$filename."ARC_classfication.xlsx";

#寫一個暫用的RScript
#我們還需要寫一個可以調用檔案大小的perl function
$rscript = "/home/tungs-lab/temp.R";
open(R,">",$rscript);
$trs = <<RS;
library(openxlsx)
library(tidyverse)
#把處理過得megan.xlsx檔案讀取
dianomd_annotate_orf<-read.xlsx("",rowNames=F,colNames=T,sheet=1)
bowtie2_bbmap_mapped_coverage<-read.table("$sammapout",header=T,sep="\\t")
colnames(bowtie2_bbmap_mapped_coverage)[colnames(bowtie2_bbmap_mapped_coverage) == 'ID'] <- 'contig'
coverage_dianomd_list<-merge(dianomd_annotate_orf,bowtie2_bbmap_mapped_coverage,by="contig",all.x= T)
coverage_dianomd_list<-coverage_dianomd_list%>%
  filter(!is.na(gene))
#我們需要contig的length才能夠算coverage
contig_length<-read.table("$contiglen",header=T,sep="\\t")
colnames(contig_length)<-c("contig","length")
coverage_dianomd_list<-merge(coverage_dianomd_list,contig_length,all.x=T)
readlength<-150
gb<-
list<-coverage_dianomd_list%>%
  mutate(contig_coverage=(Avg_fold*150/(len*5.6)))%>%
  select(contig,qseqid,type,subtype,contig_taxon,percent,contig_coverage)

RS
print R $trs;
close R;
system("Rscript $rscript");
system("rm $rscript");
	}
