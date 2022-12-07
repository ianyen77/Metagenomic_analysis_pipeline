library(openxlsx)
library(tidyverse)
#因為他沒有給我sturcture list 所以我們要從fasta直接抽取比對的名字出來
vfdb_datafasta<-read.xlsx(xlsxFile = "~/VFDB_database fasta.xlsx",rowNames =F,colNames = F,sheet=1)
strucrelist<-as.data.frame(vfdb_datafasta[grep(pattern = ">",x = vfdb_datafasta$X1),])
colnames(strucrelist)<-c("fake_name")
write.xlsx(strucrelist,file="~/VFDB_databasestructurelist.xlsx",colNames=F,rowNames=F,sheet=1)
strucrelist_annotate<-strucrelist%>%
  separate(,col = fake_name,sep=" ",into=c("gene","name"),extra="merge")%>%
  separate(,col = gene,into = c("f","gene"),sep = ">",extra = "merge")
strucrelist_annotate<-strucrelist_annotate[,-1]
Diamond_allorf_VF_hit<-read.xlsx(xlsxFile = "~/allorf_VF_diamond_hit.xlsx",sheet=1,colNames = F,sep="_")
colnames(Diamond_allorf_VF_hit)<-c("qseqid", "gene", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")
Diamond_allorf_hit_annoate<-merge(Diamond_allorf_VF_hit,strucrelist_annotate,all.x = T)
write.xlsx(Diamond_allorf_hit_annoate,"~/Diamond_allorf_hit_annoate.xlsx",colnames=T)
