library("openxlsx")
library("tidyverse")
#把原先reblast的結果輸入
dianomd_annotate_orf<-read.xlsx("C:/Users/USER/Desktop/SRR6986807ARC_classfication.xlsx",rowNames=F,colNames=T,sheet=1)
bowtie2_bbmap_mapped_coverage<-read.table("C://Users/USER/Desktop/SRR6986807ARC.sam.map.txt",header=T,sep="\t")
colnames(bowtie2_bbmap_mapped_coverage)[colnames(bowtie2_bbmap_mapped_coverage) == 'ID'] <- 'contig'
coverage_dianomd_list<-merge(dianomd_annotate_orf,bowtie2_bbmap_mapped_coverage,by="contig",all = T)
coverage_dianomd_list<-coverage_dianomd_list%>%
  filter(!is.na(gene))
#我們需要contig的length才能夠算coverage
contig_length<-read.xlsx("C:/Users/USER/Desktop/contig_len.xlsx",rowNames = F,colNames = T,sheet=1)
coverage_dianomd_list<-merge(coverage_dianomd_list,contig_length,all.x=T)
readlength<-150
gb<-5.6
list<-coverage_dianomd_list%>%
  mutate(contig_coverage=(Avg_fold*150/(len*5.6)))%>%
  select(contig,qseqid,type,subtype,contig_taxon,percent,contig_coverage)



