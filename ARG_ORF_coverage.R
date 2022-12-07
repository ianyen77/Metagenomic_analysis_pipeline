library("Hmisc")
library("openxlsx")
library("tidyverse")
library("ggplot2")
dianomd_annotate_orf<-read.xlsx("~/R/Diamond_SARG_annotate.xlsx",rowNames=F,colNames=T,sheet=1)
bowtie2_bbmap_mapped_coverage<-read.xlsx("~/R/ARG-ORF_coverage.xlsx",rowNames = F,colNames = T,sheet=1)
colnames(dianomd_annotate_orf)[colnames(dianomd_annotate_orf) == 'qseqid'] <- '#ID'
coverage_dianomd_list<-merge(dianomd_annotate_orf,bowtie2_bbmap_mapped_coverage,by="#ID",all = T)
coverage_dianomd_reannotae<-coverage_dianomd_list%>%
  separate(Categories_in_database,into=c("type","subtype"),sep="__")
coverage_dianomd_reannotae<-coverage_dianomd_reannotae[,c(-5:-14)]
coverage_dianomd_type_stastis<-coverage_dianomd_reannotae%>%
  group_by(type)%>%
  summarise(type_sum=sum(Avg_fold,na.rm = T))
coverage_dianomd_subtype_stastis<-coverage_dianomd_reannotae%>%
  group_by(type,subtype)%>%
  summarise(subtype_sum=sum(Avg_fold,na.rm = T))
write.xlsx(coverage_dianomd_type_stastis,"~/R/coverage_dianomd_stastic_type.xlsx",colNames=T,rowNames=F,sheet=1)
write.xlsx(coverage_dianomd_subtype_stastis,"~/R/coverage_stastic_subtype.xlsx",colNames=T,rowNames=F,sheet=1)
write.xlsx(coverage_dianomd_reannotae,"~/R/coverage_dianomd.xlsx",colNames=T,rowNames=F,sheet=1)
coverage_dianomd_type_stastis$type[coverage_dianomd_type_stastis$type=="macrolide-lincosamide-streptogramin"]<-"MLS"
coverage_dianomd_type_stastis%>%
  ggplot()+
  geom_bar(aes(x=reorder(type,-type_sum),y=type_sum,fill=type),stat="identity")+
  geom_text(aes(x=type,y=type_sum,label=round(type_sum,1)),size=3,vjust=-0.3)+
  labs(x = 'Type',
       y = 'Coverage (×/GB)',
       title = 'ARG Type Coverage')
