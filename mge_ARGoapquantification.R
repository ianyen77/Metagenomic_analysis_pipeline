#利用ARGOAP 用手動腳本計算16s normalized豐度的腳本
#1.需要先將DB(usearch)換成想要比對的DB(usearch.udb)(stageone)
#2.運行STAGEONE
#3.makeblastdb
#4.blastx
library("openxlsx")
library("tidyverse")
library("car")
library("FSA")
library("mdthemes")
library(ggpubr)
library("ggpmisc")
library(RColorBrewer)
#這邊是針對evalue, idendity,aa length 做一些篩選,根據你要的條件調整過
evaluematch<-1e-7
identitymatch<-80
aa_length<-25
#接下來我們將blastx過的output 讀進來
SARG_blastx_hit<-read.xlsx(xlsxFile = "C:/Users/USER/Desktop/lab/實驗/Metagenomic in DWDS/DATA/newDATA/MGE/MGEblastout_ARGOAP.xlsx",sheet=1,colNames = F)
colnames(SARG_blastx_hit)<-c("qseqid", "gene", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")
#根據先前設定的篩選掉不符合的blast
SARG_blastx_filter<-SARG_blastx_hit%>%
  filter(evalue<=evaluematch)%>%
  filter(pident>=identitymatch)%>%
  filter(length>=aa_length)

#接著我們將ARGDATAbase 的AA長度讀進來，可以用perl腳本取得
SARGgenelength<-read.xlsx(xlsxFile = "C:/Users/USER/Desktop/lab/實驗/Metagenomic in DWDS/DATA/newDATA/MGE/MGEblastout_ARGOAP.xlsx",sheet=2,colNames = F)
colnames(SARGgenelength)<-c("gene","aalength")
SARG_blastx_filter<-merge(SARG_blastx_filter,SARGgenelength,all.x=T,by="gene")

#這個數字是來自metadata online.txt的16s數量
metadata16s<-read.xlsx(xlsxFile = "C:/Users/USER/Desktop/lab/實驗/Metagenomic in DWDS/DATA/newDATA/MGE/MGEblastout_ARGOAP.xlsx",sheet=3,colNames = T)
SARG_blastx_filter<-separate(SARG_blastx_filter,qseqid,into=c("Name","seqnum"),sep = "_",remove = F)
SARG_blastx_filter$seqnum<-NULL
SARG_annoate_blastx<-merge(SARG_blastx_filter,metadata16s,by="Name",all.x = T)
#合併基因的名字
gene_name<-read.xlsx(xlsxFile = "C:/Users/USER/Desktop/lab/實驗/Metagenomic in DWDS/DATA/newDATA/MGE/MGE namefile.xlsx",sheet=1,colNames = F)
colnames(gene_name)<-c("gene","type","subtype")
gene_name$gene<- paste(gene_name$gene,"1", sep="_")
SARG_annoate_blastx<-merge(SARG_annoate_blastx,gene_name,by="gene",all.x=T)
SARG_annoate_blastx$SampleID<-NULL
write.xlsx(SARG_annoate_blastx,"C:/Users/USER/Desktop/MGE_blast_out.xlsx")
SARG_annoate_blastx<-read.xlsx("C:/Users/USER/Desktop/MGE_blast_out.xlsx",sheet=1)
#這個計算是將blast到的長度/reference AA的長度*16S數量，再加總
SARG_annoate_blastx<-SARG_annoate_blastx%>%
  mutate("blastlength/referencelength"=length/(aalength*`#of16Sreads`))
subtype_16snormalize<-SARG_annoate_blastx%>%
  group_by(Name,type,subtype)%>%
  summarise(subtype_sum=sum(`blastlength/referencelength`,na.rm = T))%>%
  unite("subtype",type,subtype,sep = "__" )%>%
  spread(key = subtype,value = subtype_sum)
subtype_16snormalize[is.na(subtype_16snormalize)]<-0
write.xlsx(subtype_16snormalize,"C:/Users/USER/Desktop/MGEblastoutform.xlsx")

#分析MGE跟ARG的相關性
arg<-read.xlsx("C:/Users/USER/Desktop/lab/實驗/Metagenomic in DWDS/DATA/newDATA/ARG/ARGoap_out.xlsx",sheet=2,rowNames=T,colNames =T)
arg<-as.data.frame(t(arg))
arg$sum<-apply(arg,1,sum)
arg$location<-c("Raw","Raw","Raw","Finished","Finished","Finished","Upstream","Upstream","Upstream","Midstream","Midstream","Midstream","Downstream","Downstream","Downstream")
arg$location<-factor(arg$location,levels = c("Raw","Finished","Upstream","Midstream","Downstream"))
subtype_16snormalize$sum<-apply(subtype_16snormalize[,2:19],1,sum)
MGE_ARG<-as.data.frame(cbind(as.data.frame(cbind(subtype_16snormalize$sum,arg$sum)),arg$location))
colnames(MGE_ARG)[1]<-"MGE_sum"
colnames(MGE_ARG)[2]<-"arg_sum"
colnames(MGE_ARG)[3]<-"location"
#先畫MGE跟ARG豐度的scatter plot
ggplot(MGE_ARG,aes(x=MGE_sum,y=arg_sum))+
  geom_point(color="#80B1D3",size=3,alpha=0.7)+geom_smooth(method =lm,color="#80B1D3",alpha=0.3) +theme_bw()+labs(x="Total MGEs abundance against 16S",y="Total ARGs abundance against 16S")+
  theme(axis.title = element_text(size=13),axis.text =element_text(size=12.5)  ,legend.title= element_text(size=12),legend.text = element_text(size=12))
##ggscatter---------------------
ggscatter(MGE_ARG,x="MGE_sum",y="arg_sum", add = "reg.line", conf.int = TRUE,  color=  "#80B1D3",alpha=0.7,size=3,
          add.params = list(fill = "lightgray"))+stat_cor(method = "pearson", label.x =0.19, label.y = 0.18)+theme_bw()+labs(x="Total MGEs abundance against 16S",y="Total ARGs abundance against 16S")+
  theme(axis.title = element_text(size=13),axis.text =element_text(size=12.5)  ,legend.title= element_text(size=12),legend.text = element_text(size=12))
#畫一張MGE豐度圖
MGE_plotdata<-MGE_ARG%>%
  group_by(location)%>%
  summarise(type_mean=mean(MGE_sum),type_sd=sd(MGE_sum))
MGE_plotdata$location<-factor(MGE_plotdata$location,levels=c("Raw","Finished","Upstream","Midstream","Downstream"))
ggplot(MGE_plotdata)+geom_bar(aes(x=location, y=type_mean), stat="identity",fill="#8DD3C7",alpha=0.7,width=0.8)+geom_errorbar(aes(x=location,ymin=type_mean-type_sd, ymax=type_mean+type_sd), width=.2,position=position_dodge(.9))+
  theme_bw()+ labs(x="Location",y="Total MGEs abundance normalization against 16S")+theme(axis.title = element_text(size=13),axis.text =element_text(size=12.5)  ,legend.title= element_text(size=12),legend.text = element_text(size=12))
display.brewer.pal(n=12,name="Set3")
brewer.pal(n=12,name="Set3")
color<-c("#8DD3C7","#FFFFB3","#BEBADA","#FB8072","#80B1D3")


#分析顯著差異
varaible_and_group<-subtype_sum~location#想測試的變數跟組別
#我們必須先檢查數據是不是常態分布及變異數的同質性，才能決定我們要用的檢定方法。

{#檢查數據是否是常態分布的,利用shapiro.test來檢驗數據是不是常態的，如果p>0.05那麼數據就是常態的
  Data.levels<-split(MGE_ARG, MGE_ARG$location)
  for(i in seq(length(Data.levels))) {
    group.n<-length(Data.levels[[i]]$location)
    group.name <-Data.levels[[i]]$location[1]
    cat(paste("Group: ", group.name, sep=''), sep="", append=TRUE)
    if (group.n < 50) {
      shapiro.result<- shapiro.test(Data.levels[[i]]$subtype_sum)
      cat(", Shapiro-Wilk normality test W = ", shapiro.result$statistic, " p-value = ", shapiro.result$p.value, "\n" , sep="")
    } else {
      ks.result<-ks.test(Data.levels[[i]]$subtype_sum, pnorm, mean(Data.levels[[i]]$subtype_sum), sd(Data.levels[[i]]$subtype_sum))
      cat(", Kolmogorov-Smirnov normality test D = ", ks.result$statistic, " p-value = ", ks.result$p.value, "\n" , sep="", append=TRUE)
    }
  }
  #檢查數據變異數的同質性，，如果levenes test 的結果p>0.05，那我們可以認為以這幾個組別間的變異數沒有明顯差異，他們是同質的P
  homo<-leveneTest(varaible_and_group,data = MGE_ARG)
  if (homo$`Pr(>F)`[1]>0.05){
    print("data is homo")
  }else{print ("data is nonhomo")}
  #如果不同質可以用ftest來看是誰不同質
  #res.ftest <- var.test(Data.levels[[1]]$bacitracin,Data.levels[[4]]$bacitracin,data = data)
  #res.ftest
}
#我們必須手動去看是否是常態及同質的，如果兩者皆符合，那我們可以使用t-test
pairwise.t.test(MGE_ARG$subtype_sum,MGE_ARG$location,p.adjust.method = "BH")
?pairwise.t.test
#如果兩者中有一不符合，那我們得使用wilcoxon rank sum test
pairwise.wilcox.test(data$bacitracin,data$location,p.adjust.method = "BH")
wilcox.test(Data.levels[[5]]$bacitracin,Data.levels[[4]]$bacitracin,p.adjust.method = "BH")

