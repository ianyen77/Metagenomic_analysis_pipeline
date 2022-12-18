# Metagenomic tools Basic installation&usage 

## Reads Download/QC/Trimming

### SRAtool
從NCBI下載reads

**Install**  
請先在Linux 上安裝conda並安裝bioconda  
```
$ conda install -c bioconda sra-tools
```  

**Usage**  
```
conda activate

#下載序列
(base)$ prefetch {SRR的號碼}  

#從下載的sra檔案中提取fastq檔，特別注意新版的指令是 (base)$fasterq-dump
(base)$ fastq-dump {SRR的號碼} 
``` 
fastq檔會出現在sra的資料夾中

### FastQC
檢查序列質量

**Install**  
請先在Linux 上安裝conda並安裝bioconda  
```
$conda install -c bioconda fastqc
```  

**Usage**  
```
conda activate
(base)$ fastqc
```

### fastp
修剪序列，將低質量序列去除  
https://github.com/OpenGene/fastp#install-with-bioconda

**Install**   
請先在Linux 上安裝conda並安裝bioconda  
```
# note: the fastp version in bioconda may be not the latest
conda install -c bioconda fastp
```  

**Usage**  
```
conda activate
(base)$ fastp -i {你的序列1.fq} -I {你的序列2.fq} -o {修剪完的序列1.fq} -O{修剪完的序列2.fq}
```
基本參數設定

## Taxanomic Profile
### Kraken
short reads taxanomic assigment(k-mer algorithm)  
https://github.com/DerrickWood/kraken2/wiki/Manual#installation  
**Install**  
```
$ conda install kraken2
#檢查版本
kraken2 –version
#安裝更新
$ conda update kraken2 -c bioconda
#安裝資料庫
#先設置存放位置(設定環境變數)
$DBNAME={~/db/kraken2/database(你要把資料庫建在哪裡)}
$mkdir -p DBNAME
#測試設定之環境變數是否成功
$cd $DBNAME
# 下載物種註釋資料庫
kraken2-build --download-taxonomy --threads{你要使用之線程數} --db $DBNAME
```
**Usage**   

### Metaphlan
short reads taxanomic assigment
https://github.com/biobakery/MetaPhlAn
**Install** 
https://github.com/biobakery/MetaPhlAn 
**Usage**  

## ARG Profile   
### ARGS-OAP   
short reads ARG mapping to SARG2.2 DB  
https://github.com/xiaole99/ARGs_OAP_v2_manual   
**Install**  
去https://smile.hku.hk/SARG 點開ARGs-OAP後直接下載2.2版本  
```
~$ mkdir ARGs-OAP
#接著把下載好的檔案在 ARGs-OAP解壓
#因為他們把bin裡面的usearch刪掉了，所以我們需要自己去usearch 下載32，並把他命名為usearch 並把她拉進bin裡  
cd ../bin
bin$ chmod 755 usearch
```
**Usage**  
```
./argoap_pipeline_stageone_version2 -i {放有輸入 reads 的資料夾，其需要是.fq} -o {輸出資料夾} -m {meta-data文件} -n {線程數}
```

## Assembly
### Megahit
組裝reads  
https://github.com/voutcn/megahit  
**Install**  
```
conda install -c bioconda megahit
```   
**Usage**  
```
conda activate
(base)$ megahit -1 {乾淨的pe序列1.fq} -2 {乾淨的pe序列2.fq} -o {輸出的檔名} 
```   
＃有些參數需要在寫  

### Quast
評估你組裝contigs的質量  
https://github.com/ablab/quast  

**Install**  
從他們的官網下載http://quast.sourceforge.net/ 並在你想要的資料夾中解壓縮  
```
tar -xf {下載檔案}
```

**Usage**  
```
cd {安裝的資料夾}

＃因為他要在python的環境下運行 我們的python裝在conda的環境中 所以要把conda打開
conda activate
(base)/{安裝的資料夾}$ ./quast.py {所要評估contigs的所在位置} -o {輸出資料位置}
```


### Prodigal
prokaryotic open reading fram prediction  
https://github.com/hyattpd/prodigal/wiki/understanding-the-prodigal-output#gene-coordinates    
**Install**    
```
$conda install -c bioconda prodigal
```  
**Usage**   
```
conda activate
$prodigal -i {準備預測的contig} -f 輸出的格式 -p meta(此參數在調整你要選擇在那一種模式下跑 meta就是metagenomic) -o {你要輸出的資料夾位置} -d {輸出基因的核酸文件} -a {輸出基因的蛋白質序列} -s {輸出預測的分數文件}
```
### Diamond  
faster BlastX and BlastP   
https://github.com/bbuchfink/diamond/wiki/3.-Command-line-options     

**Install**    
```
conda install -c bioconda diamond
conda update diamond
```  
**Usage**  
```
conda activate
#fist step make DB you want to alignment
diamond makedb --in{要參考的data base(.fa)} --db {見好的database名字}

#Blast
diamond blastx --db {database} --query {要比對的orf} --out{輸出的位置}  --id{idendity%} --p{線程} -e {e值} --query-cover{query coverage%} --k {最多可以回報幾個target，設定1就好}
```

### Bowtie2
mappinng reads to contigs then use sam tools to caculate contigs coverage   
http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#getting-started-with-bowtie-2-lambda-phage-example  
**Install**    
```
conda install -c bioconda bowtie2
```  
**Usage**   
```
#先建立refernce genome的index
conda activate
bowtie2-build {要做為參考contig的fasta檔} {製作的index要存放的位置及檔名（會有五六個文件同時被生成)}
bowtie2 -x {index的檔名（不要加上.x.bt2)} -1 {要mapping的pe序列1.fq} -2{要mapping的序列2.fq} -S {輸出的SAM檔}
```

### SAMtools
tidy up your SAM file
   
**Install**    
```
$conda create -n samtools
$conda install  -c conda-forge -c bioconda samtools
$conda update samtools
```  
**Usage**  
```
conda activate samtools
$samtools ........
＃samtool 的用法很多 可以參考下列 如果有不知道的參數 samtools --help{conmand}
＃https://zhuanlan.zhihu.com/p/89896205
```
 
### BBmap
caculate orf/contig coverage 
   
**Install**    
```
#安裝java
$ sudo apt update
$ java -version
$ sudo apt install default-jre
$ sudo apt install default-jdk
$ java -version
$ javac -version
#先去下載 bbmap https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/installation-guide/\
$ cd (installation parent folder)
$ tar -xvzf BBMap_(version).tar.gz
$$ (installation directory)/stats.sh in=(installation directory)/resources/phix174_ill.ref.fa.gz
```  
**Usage**    
```
$ cd (bbmap installation directory)
$ ./pileup.sh in=(bowtie2_mapped_ORF.sam) out=(ARG-ORF.sam.map.txt)
```


### Plasfow
predict contig location   
https://github.com/smaegol/PlasFlow
   
**Install**    
```
$ conda create --name plasflow python=3.5
$ conda activate plasflow
$ conda install -c jjhelmus tensorflow=0.10.0rc0
$ conda install plasflow -c smaegol
#因為filter_sequences_by_length.pl需要用到bioperl中的module，所以需要先下載
$ sudo apt-get install bioperl bioperl-run
$ conda deactivate
```  
**Usage**    
```
$ conda acitvate plasflow
#因為plasflow 對於1000bp 以下的contig預測的準確性會降低很多，所以她有提供一個perl script來讓你filter contig 長度
#先去https://github.com/smaegol/PlasFlow將filter_sequences_by_length.pl此腳本用vim存成一個perl script
(plasflow)$ perl -w filter_sequences_by_length.pl -input {contig.fa} -output{filtered_contig.fa} -thresh {length_youwantto_filter}
#進行預測
(plasflow)$ PlasFlow.py --input {contig.fa} --output {outputfile.tsv} --threshold {0-1,default 0.7}
(plasflow)$ conda deactivate
```
