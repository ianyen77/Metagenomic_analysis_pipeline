#!/usr/bin/perl -w
#Author:IAN
#This script needs magan output, make sure you have do megan manually
#-------------------------------
use Getopt::Std;
getopt("boi");

unless (@ARGV && $opt_b && $opt_o && $opt_i) {
    print "-b bin Directory(abs_path ie ~/perlscript/)\n";
    print "-o output directory(abs_path)\n";
    print "-i intput MEGAN file directory(abs_path)\n";
    print "-f input ARC-ORF file directory(abs_path)\n";
    print "-ARGV are input . file(abs_path)\n";
    die();
}

$script1=$opt_b."contigs_orfnumber_count.pl";
$script2=$opt_b."MEGAN_inspector_procress.pl";
mkdir $opt_o;

for ($x=0; $x<@ARGV; $x++){
	#下面這行最後一個括號要改掉
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(.nrblast-inspector.txt)/){
	$filename=$2;
	}
	$listopt=$opt_o.$filename."ARC-orfnumber.txt";
	$ARC_ORF_protein=$opt_f.$filename."protien";
	$meganopt=$opt_o.$filename."megan_adjust.txt";
	$meganopttxt=$opt_i.$filename.".nrblast-inspector.txt";
	system("perl -w $script1 -i $ARC_ORF_protein > $listopt");
	system("perl -w $script2 -i $meganopttxt > $meganopt");
#下面這兩個變數在真的使用的時候要改成真的路徑
$reblastSARG="/home/tungs-lab/ARC/ARC_ORF/ARC_ORF_SARGreblast/".$filename."reblast_SARG.dmnd";
$blastSARG="";
$contig_SARG_Class=.$filename."ARC_classfication.xlsx";
#寫一個暫用的RScript
$rscript = "/home/tungs-lab/temp.R";
open(R,">",$rscript);
$trs = <<RS;
library(tidyverse)
library(openxlsx)
#This script is for perl script,a記得要先將特殊符號轉義過 
#先讀取diamond 的output 並且合併基因與抗藥性基因名稱(這邊我們使用重新註釋過的ARC-ORF再次進行blast的結果)
SARG_adjust_list<-read.xlsx(xlsxFile = "~/metagenomic_pipeline/ARG-OAP/Ublastx_stageone2.2/Ublastx_stageone/DB/SARG_Struturelist_adjust.xlsx")
Diamond_SARG_hit<-read.table("$reblastSARG",header=F,sep="\\t")
colnames(Diamond_SARG_hit)<-c("qseqid", "gene", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")
Diamond_SARG_hit_annoate<-merge(Diamond_SARG_hit,SARG_adjust_list,all.x = T)
Diamond_SARG_hit_annoate<-separate(Diamond_SARG_hit_annoate,Categories_in_database,into=c("type","subtype"),sep="__")
#處理MEGAN的output並且將contig分類
MEGANout<-read.table(file = "$meganopt", header = FALSE, sep="\\t")
MEGANstatistic<-MEGANout%>%
  group_by(V1,V2)%>%
  summarise(count=n())
orfcount<-read.table(file ="$listopt", header = FALSE, sep="\\t")
colnames(orfcount)<-c("V1","contig_countorf")
MEGAN_orfcount<-merge(MEGANstatistic,orfcount)
contig_taxonomy<-MEGAN_orfcount%>%
  mutate(percent=count/contig_countorf)%>%
  filter(percent>0.5)%>%
  filter(V2!="Not assigned")
colnames(contig_taxonomy)<-c("contig","contig_taxon","megancontig","contig_orf_num","percent")
#合併meganout跟原先的blastoutput
ARC_blast<-separate(Diamond_SARG_hit_annoate,qseqid,sep="_",into=c("x1","x2","x3"),remove=F)
ARC_blast<-unite(ARC_blast,"contig",x1,x2,sep="_")
ARC_blast\$x3<-NULL
ARC<-merge(ARC_blast,contig_taxonomy,by="contig",all.x=T)
write.xlsx(ARC,file="~/ARC/ARC_ORF/ARC_classfication_megan.xlsx")

RS
print R $trs;
close R;
system("Rscript $rscript")
system("rm $rscript")
}
