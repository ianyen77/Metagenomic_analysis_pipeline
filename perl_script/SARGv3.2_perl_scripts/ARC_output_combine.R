library(openxlsx)
library(tidyverse)
library(purrr)
#ARC coverage(based on Species and contig_coverag)--------------------------------
# 設定檔案路徑及檔案格式
file_path <- "~/location_co_assembly/SARG3.2/blastx_sm70_cover70_e10/ARC/ARC_coverage"
# 取得檔案清單
file_list <- list.files(path = file_path, pattern = ".xlsx", full.names = TRUE)
df<-data.frame()
###以下這個有問題，會多此一舉
df <- NULL  # 先定義一個空的資料框
for (i in seq_along(file_list)) {
  if (i == 1) {
    # 讀取第一個檔案的全部內容，包括第一列
    x <- read.xlsx(file_list[[i]], startRow = 1)
    colnames(x) <- colnames(x)  # 將欄位名稱修改為原始值
    x$sample<-str_replace(file_list[[i]],".*/","") %>% 
      str_replace(.,"-.*","")
  } else {
    # 讀取後續檔案，跳過第一列
    x <- read.xlsx(file_list[[i]], startRow = 1,colNames = T)  # 將欄位名稱修改為前一個資料框的欄位名稱
    x$sample<-str_replace(file_list[[i]],".*/","") %>% 
      str_replace(.,"-.*","")
  }
  df <- rbind(df, x)  # 將讀取到的資料框合併至 df 中
}
df1<-df
write.xlsx(df, "~/location_co_assembly/SARG3.2/blastx_sm70_cover70_e10/ARC/ARC_coverage/combine.xlsx")


#combine phyla into last df------------------------------------------------------------------------------------------
file_path <- "~/location_co_assembly/SARG3.2/blastx_sm70_cover70_e10/MEGAN/Phyla/ARC_host"

# 取得檔案清單
file_list <- list.files(path = file_path, pattern = ".xlsx", full.names = TRUE)
df<-data.frame()
###以下這個有問題，會多此一舉
df <- NULL  # 先定義一個空的資料框
for (i in seq_along(file_list)) {
  if (i == 1) {
    # 讀取第一個檔案的全部內容，包括第一列
    x <- read.xlsx(file_list[[i]], startRow = 1)
    colnames(x) <- colnames(x)  # 將欄位名稱修改為原始值
  } else {
    # 讀取後續檔案，跳過第一列
    x <- read.xlsx(file_list[[i]], startRow = 2,colNames = F)
    colnames(x) <- colnames(df)  # 將欄位名稱修改為前一個資料框的欄位名稱
  }
  df <- rbind(df, x)  # 將讀取到的資料框合併至 df 中
}
df<-df %>% 
  select(qseqid,contig_taxon)

df2<-merge(df1,df,by="qseqid")

#combine orf coverage into last df
file_path <- "~/location_co_assembly/SARG3.2/blastx_sm70_cover70_e10/ARC/ARC_ORF/ARC_ORF_SARGreblast/ARG_like_orf_coverage/ARG_lik_orf_coverage"

# 取得檔案清單
file_list <- list.files(path = file_path, pattern = ".xlsx", full.names = TRUE)
df<-data.frame()
###以下這個有問題，會多此一舉
df <- NULL  # 先定義一個空的資料框
for (i in seq_along(file_list)) {
  if (i == 1) {
    # 讀取第一個檔案的全部內容，包括第一列
    x <- read.xlsx(file_list[[i]], startRow = 1)
    colnames(x) <- colnames(x)  # 將欄位名稱修改為原始值
  } else {
    # 讀取後續檔案，跳過第一列
    x <- read.xlsx(file_list[[i]], startRow = 2,colNames = F)
    colnames(x) <- colnames(df)  # 將欄位名稱修改為前一個資料框的欄位名稱
  }
  df <- rbind(df, x)  # 將讀取到的資料框合併至 df 中
}
df<-df %>% 
  select(orf_qseqid,orf_coverage)
colnames(df)[1]<-"qseqid"

df3<-merge(df2,df,by="qseqid")
write.xlsx(df3,"/media/sf_sf/SARGv3.2_ARC_analysis.xlsx")

