library("openxlsx")
library("tidyverse")
library("ggplot2")
#修改SARGstructurelist至可以跟diamond output合併之格式
x1<-read.xlsx(xlsxFile = "~/SARG_DATABASE.xlsx",sheet=1,colNames = T,sep="_")
x1$Corresponding_ids<-gsub(pattern='\\[',replacement="",x1$Corresponding_ids)
x1$Corresponding_ids<-gsub(pattern='\\]',replacement="",x1$Corresponding_ids)
x1$Corresponding_ids<-gsub(pattern="\\'",replacement="",x1$Corresponding_ids)
x1$Corresponding_ids<-gsub(pattern=" ",replacement="",x1$Corresponding_ids)
c<-separate(x1,Corresponding_ids,into = paste0("COL1_", 1:1000),sep=",")
SARG_DB_adjust<-c%>%
  gather(paste0("COL1_", 1:1000),key="fakename",value="gene",na.rm=T)
SARG_DB_adjust$fakename<-NULL
Diamond_SARG_hit<-read.xlsx(xlsxFile = "~/Diamond_SARG_blastxoutput.xlsx",sheet=1,colNames = F,sep="_")
colnames(Diamond_SARG_hit)<-c("qseqid", "gene", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")
#合併diamondoutput跟SARG基因名字
Diamond_SARG_hit_annoate<-merge(Diamond_SARG_hit,SARG_DB_adjust,all.x = T)
Diamond_SARG_hit_annoate<-separate(Diamond_SARG_hit_annoate,Categories_in_database,into=c("type","subtype"),sep="__")
write.xlsx(Diamond_SARG_hit_annoate,"~/sequencename_ORF_SARG_blastx_reannonate",colnames=T)
#定量，定量前確定要跑過bowtie2及bbmap，取得ORF的mapped read數量文件
dianomd_annotate_orf<-Diamond_SARG_hit_annoate
bowtie2_bbmap_mapped_coverage<-read.xlsx(xlsxFile ="~/ARG-ORF_bbmapoutput.xlsx",colNames = T)
colnames(dianomd_annotate_orf)[colnames(dianomd_annotate_orf) == 'qseqid'] <- '#ID'
coverage_dianomd_list<-merge(dianomd_annotate_orf,bowtie2_bbmap_mapped_coverage,by="#ID",all = T)
#根據定序結果更改此兩變數
reads_datasets_size<-5.1
illumina_reads_length<-150
#定量orf_coverage
coverage_dianomd_list<-coverage_dianomd_list%>%
  mutate(coverage_adjust=((Avg_fold*illumina_reads_length)/(reads_datasets_size*Length)))
coverage_dianomd_type_stastis<-coverage_dianomd_list%>%
  group_by(type)%>%
  summarise(type_sum=sum(coverage_adjust,na.rm = T))
coverage_dianomd_subtype_stastis<-coverage_dianomd_list%>%
  group_by(type,subtype)%>%
  summarise(subtype_sum=sum(coverage_adjust,na.rm = T))
write.xlsx(coverage_dianomd_type_stastis,"~/R/coverage_dianomd_stastic_type.xlsx",colNames=T,rowNames=F,sheet=1)
write.xlsx(coverage_dianomd_subtype_stastis,"~/R/coverage_stastic_subtype.xlsx",colNames=T,rowNames=F,sheet=1)
write.xlsx(]coverage_dianomd_list,"~/R/coverage_dianomd.xlsx",colNames=T,rowNames=F,sheet=1)
#畫圖
coverage_dianomd_type_stastis$type[coverage_dianomd_type_stastis$type=="macrolide-lincosamide-streptogramin"]<-"MLS"
coverage_dianomd_type_stastis%>%
  ggplot()+
  geom_bar(aes(x=reorder(type,-type_sum),y=type_sum,fill=type),stat="identity")+
  geom_text(aes(x=type,y=type_sum,label=round(type_sum,1)),size=3,vjust=-0.3)+
  labs(x = 'Type',
       y = 'Coverage (×/GB)',
       title = 'ARG Type Coverage')
