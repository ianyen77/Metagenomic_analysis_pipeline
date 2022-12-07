library(openxlsx)
library(tidyverse)
library(ggplot2)
#編輯diamond輸出的格式，轉換成跟stucturelist可以merge的樣子(當然也可以把structurelist轉換)
all_orf_mge_mapped<-read.xlsx(xlsxFile = "~/allorf_MGE_diamond_hit.xlsx",rowNames =F,colNames = F,sheet=1)
colnames(all_orf_mge_mapped)<-c("qseqid", "gene", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")
all_orf_mge_mapped_stinge_edit<-all_orf_mge_mapped%>%
  separate(gene,into = c("x1","x2","x3","x4","x5","x6"),sep = "_")%>%
  unite(gene,x1,x2,x3,sep="_")
all_orf_mge_mapped_stinge_edit$x4<-NULL
all_orf_mge_mapped_stinge_edit$x5<-NULL
all_orf_mge_mapped_stinge_edit$x6<-NULL
#開始merge，把mapped到的基因跟基因名字合在一起
mgelist<-read.xlsx("~/MGE database list.xlsx",rowNames = F,colNames = F,sheet=1)
colnames(mgelist)<-c("gene","type","subtype")
all_orf_mge_mapped_reannonate<-merge(all_orf_mge_mapped_stinge_edit,mgelist,by="gene",all.x = T)
#定量
