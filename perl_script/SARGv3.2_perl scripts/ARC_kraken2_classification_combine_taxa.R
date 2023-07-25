library(openxlsx)
library(tidyverse)
library(purrr)
file_path <- "~/location_co_assembly/SARG3.2/blastx_sm70_cover70_e10/ARC/ARC_classified/ARC_krkaen2_classified/ARC_classification_confidence0"
file_list <- list.files(path = file_path, pattern = ".txt", full.names = TRUE)
file_list2 <- list.files(path = file_path, pattern = ".report", full.names = TRUE)
df<-data.frame()
###以下這個有問題，會多此一舉
df <- NULL  # 先定義一個空的資料框
for (i in seq_along(file_list)) {
  if (i == 1) {
    # 讀取第一個檔案的全部內容，包括第一列
    x <- read.table(file_list[[i]], sep="\t")
    colnames(x)<-c("classified","contig","taxon","contig_length","label")
    x<-x %>% 
      select(-label)
    x$sample<-str_replace(file_list[[i]],".*/","") %>% 
      str_replace(.,"-.*","")
    x$taxon<-str_replace_all(x$taxon,"\\W\\(.*","")
    #取得分類的階層
    c<-read.table(file_list2[[i]],sep = "\t")
    c$taxon<-c$V1
    c$V1<-gsub(".*\\|","",c$V1)
    c$V1<-gsub(".__","",c$V1)
    c<-c %>% 
      separate(taxon,into = c("x","d","p","c","o","f","g","s"),sep = "__",extra="warn") %>% 
      select(-x,-V2)
    c$d<-gsub("\\|.","",c$d)
    c$p<-gsub("\\|.","",c$p)
    c$c<-gsub("\\|.","",c$c)
    c$o<-gsub("\\|.","",c$o)
    c$f<-gsub("\\|.","",c$f)
    c$g<-gsub("\\|.","",c$g)
    colnames(c)[1]<-"taxon"
    x<-merge(x,c,by = "taxon",all.x = T)
    
  } else {
    # 讀取後續檔案，跳過第一列
    x <- read.table(file_list[[i]], sep="\t")
    colnames(x)<-c("classified","contig","taxon","contig_length","label")
    x<-x %>% 
      select(-label)# 將欄位名稱修改為前一個資料框的欄位名稱
    x$sample<-str_replace(file_list[[i]],".*/","") %>% 
      str_replace(.,"-.*","")
    x$taxon<-str_replace_all(x$taxon,"\\W\\(.*","")
    #取得分類的階層
    c<-read.table(file_list2[[i]],sep = "\t")
    c$taxon<-c$V1
    c$V1<-gsub(".*\\|","",c$V1)
    c$V1<-gsub(".__","",c$V1)
    c<-c %>% 
      separate(taxon,into = c("x","d","p","c","o","f","g","s"),sep = "__",extra="warn") %>% 
      select(-x,-V2)
    c$d<-gsub("\\|.","",c$d)
    c$p<-gsub("\\|.","",c$p)
    c$c<-gsub("\\|.","",c$c)
    c$o<-gsub("\\|.","",c$o)
    c$f<-gsub("\\|.","",c$f)
    c$g<-gsub("\\|.","",c$g)
    colnames(c)[1]<-"taxon"
    x<-merge(x,c,by = "taxon",all.x = T)
  }
  df <- rbind(df, x)  # 將讀取到的資料框合併至 df 中
}
write.xlsx(df, "~/location_co_assembly/SARG3.2/blastx_sm70_cover70_e10/ARC/ARC_classified/ARC_krkaen2_classified/ARC_classification_confidence0/combine.xlsx")

#----------------------以下部份已經整合進去code中
#修剪taxa名稱
x$taxon<-str_replace_all(x$taxon,"\\W\\(.*","")
#取得分類的階層
c<-read.table("~/location_co_assembly/SARG3.2/blastx_sm70_cover70_e10/ARC/ARC_classified/ARC_krkaen2_classified/ARC_classification_confidence0/T5-WARC_kraken2.report",sep = "\t")
c$taxon<-c$V1
c$V1<-gsub(".*\\|","",c$V1)
c$V1<-gsub(".__","",c$V1)
c<-c %>% 
  separate(taxon,into = c("x","d","p","c","o","f","g","s"),sep = "__",extra="warn") %>% 
  select(-x,-V2)
c$d<-gsub("\\|.","",c$d)
c$p<-gsub("\\|.","",c$p)
c$c<-gsub("\\|.","",c$c)
c$o<-gsub("\\|.","",c$o)
c$f<-gsub("\\|.","",c$f)
c$g<-gsub("\\|.","",c$g)
colnames(c)[1]<-"taxon"
final<-merge(x,c,by = "taxon",all.x = T)
