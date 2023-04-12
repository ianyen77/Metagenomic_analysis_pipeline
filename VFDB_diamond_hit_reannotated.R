library(openxlsx)
library(tidyverse)
#try to use for loop to handle all file out from vf blast
filename<-c("T1-W","T2-W","T3-W","T4-W","T5-W")
for (i in filename){
print(i)
x<-paste("C:/Users/USER/Desktop/lab/實驗/Metagenomic in DWDS/DATA/newDATA/ARC/location_co_assembly/blastx_sm70_cover70_e10/VF_blast/",i,"VF.dmnd",sep="")
print(x)
vfdb_gene_name<-read.xlsx(xlsxFile = "C:/Users/USER/Desktop/lab/實驗/Metagenomic in DWDS/DATA/newDATA/VF/VFDB/VFDB_gene_name.xlsx",rowNames =F,colNames = T,sheet=1)
VF_balst_out<-try(read.table(x),silent = T)
  if ('try-error' %in% class(VF_balst_out)) {
    next}
  else{
colnames(VF_balst_out)<-c("qseqid", "gene", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")
VF_blast_out_reannonate<-merge(VF_balst_out,vfdb_gene_name,all.x = T)
VF_blast_out_reannonate<-VF_blast_out_reannonate%>%
  separate(qseqid,sep="_",into=c("x1","x2","x3"),remove=F)
VF_blast_out_reannonate<-unite(VF_blast_out_reannonate,"contig",x1,x2,sep="_")
VF_blast_out_reannonate$x3<-NULL
y<-paste("C:/Users/USER/Desktop/",i,"_VFblast_reanno.xlsx",sep="")
print(y)
write.xlsx(VF_blast_out_reannonate,y,colnames=T)
}
}

