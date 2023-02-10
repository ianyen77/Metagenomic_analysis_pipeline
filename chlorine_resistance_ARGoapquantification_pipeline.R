#利用ARGOAP 用手動腳本計算16s normalized豐度的腳本
#1.需要先將DB(usearch)換成想要比對的DB(usearch.udb)(stageone)
#2.運行STAGEONE
#3.makeblastdb
#4.blastx
library("openxlsx")
library("tidyverse")
#這邊是針對evalue, idendity,aa length 做一些篩選,根據你要的條件調整過
evaluematch<-1e-7
identitymatch<-80
aa_length<-25
#接下來我們將blastx過的output 讀進來
SARG_blastx_hit<-read.xlsx(xlsxFile = "C:/Users/USER/Desktop/clresistblast.xlsx",sheet=1,colNames = F)
colnames(SARG_blastx_hit)<-c("qseqid", "gene", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")
#根據先前設定的篩選掉不符合的blast
SARG_blastx_filter<-SARG_blastx_hit%>%
  filter(evalue<=evaluematch)%>%
  filter(pident>=identitymatch)%>%
  filter(length>=aa_length)

#接著我們將ARGDATAbase 的AA長度讀進來，可以用perl腳本取得
SARGgenelength<-read.xlsx(xlsxFile = "C:/Users/USER/Desktop/clresistblast.xlsx",sheet=3,colNames = F)
colnames(SARGgenelength)<-c("gene","aalength")
SARG_blastx_filter<-merge(SARG_blastx_filter,SARGgenelength,all.x=T,by="gene")

#這個數字是來自metadata online.txt的16s數量
metadata16s<-read.xlsx(xlsxFile = "C:/Users/USER/Desktop/clresistblast.xlsx",sheet=2,colNames = T)
SARG_blastx_filter<-separate(SARG_blastx_filter,qseqid,into=c("Name","seqnum"),sep = "_",remove = F)
SARG_blastx_filter$seqnum<-NULL
SARG_annoate_blastx<-merge(SARG_blastx_filter,metadata16s,by="Name",all.x = T)
#這個數字是來自metadata online.txt的16s數量
gene_name<-read.xlsx(xlsxFile = "C:/Users/USER/Desktop/clresistblast.xlsx",sheet=4,colNames = F)
colnames(gene_name)<-c("gene","gene_name")
SARG_annoate_blastx<-merge(SARG_annoate_blastx,gene_name,by="gene",all.x=T)
#這個計算是將blast到的長度/reference AA的長度*16S數量，再加總
SARG_annoate_blastx<-SARG_annoate_blastx%>%
  mutate("blastlength/referencelength"=length/(aalength*`#of16Sreads`))
subtype_16snormalize<-SARG_annoate_blastx%>%
  group_by(Name)%>%
  summarise(subtype_sum=sum(`blastlength/referencelength`,na.rm = T))
subtype_16snormalize<-merge(subtype_16snormalize,gene_name,by="gene",all.x = T)
write.xlsx(subtype_16snormalize,file ="C:/Users/USER/Desktop/ff.xlsx")
