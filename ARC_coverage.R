#This is a R script for caculate contig coverage 
#This script can be intgrated in perl script(Suggest)
library(openxlsx)
library(tidyverse)
#把處理過的ARCmegan.xlsx檔案讀取
dianomd_annotate_orf<-read.xlsx("~/test_megan/SRR6986807ARC_classfication.xlsx",rowNames=F,colNames=T,sheet=1)
bowtie2_bbmap_mapped_coverage<-read.table("~/ff.txt",header=T,sep="\t")
colnames(bowtie2_bbmap_mapped_coverage)[colnames(bowtie2_bbmap_mapped_coverage) == 'ID'] <- 'contig'
colnames(bowtie2_bbmap_mapped_coverage)[colnames(bowtie2_bbmap_mapped_coverage) == 'Length'] <- 'Contig_length'
coverage_dianomd_list<-merge(dianomd_annotate_orf,bowtie2_bbmap_mapped_coverage,by="contig",all.x=T)
coverage_dianomd_list<-coverage_dianomd_list%>%
  filter(!is.na(gene))
#setting parameter for caculate coverage, 1.readlength=illumina reads length 2.size=datasetsize
readslength<-150
size<-3.2
#計算coverage
ARC_list_all<-coverage_dianomd_list%>%
  mutate(contig_coverage=(Avg_fold*readslength/(Contig_length*size)))
ARC_list_select<-ARC_list_all%>%
  select(contig,qseqid,type,subtype,contig_taxon,megan_vote_percent,contig_coverage)
write.xlsx(ARC_list_all,)
write.xlsx(ARC_list_select,)