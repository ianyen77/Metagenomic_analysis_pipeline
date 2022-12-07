#需先準備好 1.contig(核酸序列) 2.Diamond比對特定資料庫的output文件(BLAST tabular format)   

1.create a ID_list.txt (因為我們要的是ARC，所以我們留下contig的名字就好) 
```
#format
k141_111843
k141_186432
k141_167714
k141_149241
.....
.....
.....
```   
2.利用seqkit從所有的contig中抽出比對到有ARG的contig
```
conda install -c bioconda seqkit
conda activate
(base)$ seqkit grep -f {ID_list.txt} {contig預測的ORF.fa(nucleic acid)} -o{outputfile.fa}
```

#上述這兩件事情可以透過https://github.com/ianyen77/Metagenomic-analysis-pipeline/blob/main/perl_script/extract_seqfrom_blast6format.pl 這個腳本來完成
