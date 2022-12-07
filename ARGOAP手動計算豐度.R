#將ARGOAP blastoutput 用手動腳本計算16s normalized豐度的腳本
library("openxlsx")
library("tidyverse")
library("ggplot2")
#這邊是針對evalue, idendity,aa length 做一些篩選,根據你要的條件調整過
evaluematch<-1e-7
identitymatch<-80
aa_length<-25
#修改SARGstructurelist至可以跟blast6out formate合併之格式
x1<-read.xlsx(xlsxFile = "~/SARG_DATABASE.xlsx",sheet=1,colNames = T,sep="_")
x1$Corresponding_ids<-gsub(pattern='\\[',replacement="",x1$Corresponding_ids)
x1$Corresponding_ids<-gsub(pattern='\\]',replacement="",x1$Corresponding_ids)
x1$Corresponding_ids<-gsub(pattern="\\'",replacement="",x1$Corresponding_ids)
x1$Corresponding_ids<-gsub(pattern=" ",replacement="",x1$Corresponding_ids)
c<-separate(x1,Corresponding_ids,into = paste0("COL1_", 1:1000),sep=",")
SARG_DB_adjust<-c%>%
  gather(paste0("COL1_", 1:1000),key="fakename",value="gene",na.rm=T)
SARG_DB_adjust$fakename<-NULL
#接下來我們將blastx過的output 讀進來
SARG_blastx_hit<-read.xlsx(xlsxFile = "C:/Users/TUNG'S LAB/Desktop/test1.xlsx",sheet=2,colNames = F)
colnames(SARG_blastx_hit)<-c("qseqid", "gene", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")
#根據先前設定的篩選掉不符合的blast
SARG_blastx_filter<-SARG_blastx_hit%>%
  filter(evalue<=evaluematch)%>%
  filter(pident>=identitymatch)%>%
  filter(length>=aa_length)

#接著我們將ARGDATAbase 的AA長度讀進來，可以用perl腳本取得
SARGgenelength<-read.xlsx(xlsxFile = "C:/Users/TUNG'S LAB/Desktop/test1.xlsx",sheet=3,colNames = T)
SARG_blastx_filter<-merge(SARG_blastx_filter,SARGgenelength,all.x=T)

#這個數字是來自metadata online.txt的16s數量
metadata16s<-1367.67039106145
SARG_annoate_blastx<-merge(SARG_blastx_filter,SARG_DB_adjust,all.x = T)
SARG_annoate_blastx<-separate(SARG_annoate_blastx,Categories_in_database,into=c("type","subtype"),sep="__")
#這個計算是將blast到的長度/reference AA的長度*16S數量，再加總
SARG_annoate_blastx<-SARG_annoate_blastx%>%
  mutate("blastlength/referencelength"=length/(SARGgenelength*metadata16s))
subtype_16snormalize<-SARG_annoate_blastx%>%
  group_by(subtype)%>%
  summarise(subtype_sum=sum(`blastlength/referencelength`,na.rm = T))
write.xlsx(subtype_16snormalize,file ="ff.xlsx")
