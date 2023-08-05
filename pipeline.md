# A metagenomic survey of antibiotic resistome along a drinking water distribution system
Complete Metagenomic analysis pipeline for ARGs survey in drinking water

## Table of Contents
1. [Environment Setup](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#environment-setup)    
   - [Anaconda & Bioconda Installation](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#anaconda-installation)
2. [Reads Quality Control](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#reads-quality-control)
3. [Reads Based analysis](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#reads-based-analysis)
   - [Taxanomic Profile](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#taxanomic-profile)
   - [ARGs/MGEs/BRGs Profile](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#argsmgesbrgs-profile)
   - [Functional Profile](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#functional-profile)
4. [Assembly Based analysis]()
   - [Reads Assembly / Contigs QC/ ORFs prediction](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#reads-assembly--contigs-qc-orfs-prediction)
   - [Contigs ARG gene predction(ARC)](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#contigs-arg-gene-predctionarc)
   - [Taxanomic assignment of Contigs](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#taxanomic-assignment-of-arcs)
   - [ORF/Contigs coverage caculation](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#orf-coverage-contig-coverage-caculation)
   - [Metacompare](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#metacompare)
   - [Plasflow]()
5. [Binning Based analysis](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#binning-based-analysis)
   - [Reads normaliztion](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#reads-normalization)
   - [Co-assembly](https://github.com/ianyen77/Metagenomic_analysis_pipeline/blob/main/pipeline.md#co-assembly)
   - [Binning/Bin_refinement/Gene prediction]()
   - [Bin classification]()
   - [MetaCHIP]()
6. [Others]()
   - [SourceTracker2]()
   - [Assement of Bacterial community assembly(NST)]()

# Environment Setup
## [Anaconda installation](https://www.anaconda.com/download/)
```
#Enter Linux Terminal
$ sudo apt-get update
$ cd /tmp
$ apt-get install wget

#Download anaconda
$ wget https://repo.anaconda.com/archive/Anaconda3-2023.03-1-Linux-x86_64.sh

#Check the intergrity of the download packages
$ sha256sum Anaconda3-2023.03-1-Linux-x86_64.sh

# Install
$ bash Anaconda3-2023.03-1-Linux-x86_64.sh
$ source ~/.bashrc
$ conda info
$ cd
```
## [Bioconda Installation](https://bioconda.github.io/)
```
$ conda config --add channels defaults
$ conda config --add channels bioconda
$ conda config --add channels conda-forge
$ conda config --set channel_priority strict
# View channel
$ conda config --show channels
```


# Reads Quality Control
### [Fastp](https://github.com/OpenGene/fastp#install-with-bioconda)
Tirmming low quality reads

**Install**  
```
#note:fastp version in bioconda may be not the latest
$ conda install -c bioconda fastp 
```
**Usage**
```
$ conda activate
$ fastp -i reads_1.fq -I reads_2.fq -o reads_trimmed_1.fq -O reads_trimmed_2.fq
```

### [FastQC](https://github.com/OpenGene/fastp#install-with-bioconda)

**Install**  
```
$ conda install -c bioconda fastqc
```
**Usage**
```
$ conda activate
$ fastqc
```

# Reads Based analysis
## Taxanomic Profile  
I highly recommend do not use Kraken individually, combining Kraken output with Bracken for more accurate abundance estimation

### [Kraken2](https://github.com/DerrickWood/kraken2/wiki/Manual)
Short reads taxanomic assigment(k-mer algorithm)  

**Install**
```
#create environment 
$ conda create --name kraken2
$ conda activate kraken2

# Install
$ conda install kraken2

# Version
kraken2 –version
$ conda update kraken2 -c bioconda
```  

**Kraken2 DB configuration**
```
$ mkdir -p ~/DB/kraken2
$ cd  ~/DB/kraken2

#Download NCBI taxonomic information
$ kraken2-build --download-taxonomy --threads 16 --db ~/DB/kraken2 --use-ftp
``` 
#### Debug (**This bug was fixed by using --use-ftp**)
1. https://qiita-com.translate.goog/kohei-108/items/ce5fdf10c11d1e7ca15b?_x_tr_sl=ja&_x_tr_tl=zh-TW&_x_tr_hl=zh-TW&_x_tr_pto=sc
2.  https://github.com/DerrickWood/kraken2/issues/518  
Change "rsync_from_ncbi.pl" (in conda directory) Line 46:  
```
if (! ($full_path =~ s#^ftp://${qm_server}${qm_server_path}/##))  to 
if (! ($full_path =~ s#^https://${qm_server}${qm_server_path}/##))
``` 
#### Download partial library
```
$ kraken2-build --download-library bacteria --threads 16 --db ~/DB/kraken2 --use-ftp
```
#### Create DB from library
```
$ cd ~/DB/kraken2
$ kraken2-build --build --threads 16 --db ~/DB/kraken2
```
#### Alternative DB confguration  
[Prebuilt DB](https://benlangmead.github.io/aws-indexes/k2)   


A Kraken 2 database is a directory containing at least 3 files:   

hash.k2d: Contains the minimizer to taxon mappings   
opts.k2d: Contains information about the options used to build the database   
taxo.k2d: Contains taxonomy information used to build the database

Other files may also be present, remove after successful build of the database  

**Useage**
```
#I highly recommend do not use this script, use kraken2+bracken
perl -w kraken2_bracken.pl
```

### [Bracken](https://github.com/jenniferlu717/Bracken)
#### Installation
```
$ conda activate kraken2 
$ conda install -c bioconda bracken

# Test 
$ bracken -h   
```   
#### Build bracken library
```
$ conda activate kraken2
$ bracken-build -d ~/db/kraken_db -t 16 -k 35 -l 150
```

#### Usage  Kraken2 +bracken

```
$ perl -w kraken2_bracken.pl
#you can see how many arguments you need to give to this script, and what it should be

$ perl -w kraken2_bracken.pl -i .........

#After running the script, you should put all out into the same directory, for example, Class, and do the same things for  phyla, order, and so on and so for

$ cd ~/the/directory/of/bracken_out
$ mkdir ./C_out
$ mv *.C.bracken ./C_out/

#into R 
use krkaen2_bracken_combine.R 
#handle all the file bracken created,and combine all output together
```

## ARGs/MGEs/BRGs Profile
### [ARGs-OAPv2.2](https://github.com/xiaole99/ARGs_OAP_v2_manual)
1. This version is the version that I use in my thesis(ARGs profile,ARC blast)
2. This version of DB(SARG v2.2) didn't have ARGs mechanisms
3. Substitute ARG DB to MGE/BMG(MGEs or BacMet) can do the exact same quantification of ARGOAP do
   
#### Installation
```
$ mkdir -p ~/ARG_OAP/ARG_OAPv2.2
$ cd ~/ARG_OAP/ARG_OAPv2.2
$ wget https://smile.hku.hk/SARGs/static/images/Ublastx_stageone2.2.tar.gz
$ tar zxvf Ublastx_stageone2.2.tar.gz

#download usearch manually and put into bin directory
$ cd ~/ARG_OAP/ARG_OAPv2.2/Ublastx_stageone/bin
$ wget https://www.drive5.com/downloads/usearch11.0.667_i86linux32.gz
$ gzip -d usearch11.0.667_i86linux32.gz
#rename usearch & make it excutable
$ mv usearch11.0.667_i86linux32 usearch
#chmod 777 usearch
``` 
Check the DB directory has all the required database
If not
```
$ cd ~/ARG_OAP/ARG_OAPv2.2/Ublastx_stageone/DB
$ usearch -makeudb_usearch gg85.fasta -output gg85.udb
$ usearch -makeudb_usearch SARG.2.2.fasta -output SARG.2.2.udb
```
#### ARGs analysis
1. create meta-data.txt in ARG-OAP directory manually
  
Example
|SampleID|Name|Category|LibrarySize|
|--|----|----|-|
|1|T1-W-1|Raw|150|
|2|T2-W-2|Finished|150|  
2. Stageone
```
#stageone 
$ mkdir -p ~/ARG_OAPout/SARG_v2.2_out
$ perl -w ~/ARG_OAP/ARG_OAPv2.2/Ublastx_stageone/argoap_pipeline_stageone_version2.pl -i /media/sf_sf/cleanread_new/ -m ~/ARG_OAP/ARG_OAPv2.2/Ublastx_stageone/meta-data.txt  -o ~/ARG_OAPout/SARG_v2.2_out/stageone -n 16 -f fq -s
```
3. Stagetwo
```
$ perl -w ~/ARG_OAP/ARG_OAPv2.2/Ublastx_stageone/argoap_pipeline_stagetwo_version2.pl -i ~/ARG_OAPout/SARG_v2.2_out/stageone/extracted.fa -m ~/ARG_OAP/ARG_OAPv2.2/Ublastx_stageone/stageone/meta_data_online.txt -o ~/ARG_OAP/ARG_OAPv2.2/Ublastx_stageone/stagetwo -n 16
```
#### MGEs(Mobile Genetic Elements) analysis
0. Download MGEs_DB and convert NT sequence to AA sequence   
[Database](https://github.com/KatariinaParnanen/MobileGeneticElementDatabase)
```
$ mkdir ~/MGE_BMG_aod
$ cd ~/MGE_BMG_aod
$ cp -R ~/ARG_OAP/ARG_OAPv2.2/Ublastx_stageone ~/MGE_BMG_aod
```
1. create MGEs DB for ARGOAP pipeline and blastx
```
$ cd ~/MGE_BMG_aod/Ublastx_stageone/bin
$ usearch -makeudb_usearch MGE_2018_amino_sl.fasta -output ../DB/MGE_2018.udb
$ conda activate
$ cd ~/MGE_BMG_aod/Ublastx_stageone/DB
$ makeblastdb -in MGE_2018_amino_sl.fasta -dbtype prot
```

2. adjust stageone.pl in MGE_BMG_aod/ and run stageone.pl   
adjust stageone.pl line 46 to costom DB 
```
my $ARDB_PATH ||= "$ublastxdir/DB/MGE_2018.udb"; 
```
same stageone procress
```
$ mkdir ~/ARG_OAPout/MGE_2018_out
$ perl -w  ~/MGE_BMG_aod/Ublastx_stageone/argoap_pipeline_stageone_version2.pl -i /media/sf_sf/cleanread_new/ -m  ~/MGE_BMG_aod/Ublastx_stageone/meta-data.txt  -o ~/ARG_OAPout/MGE_2018_out/stageone -n 16 -f fq -s
```
3. Using Blastx to blast extracted sequence with MGEs DB
```
$ conda activate
$ cd ~/ARG_OAPout/MGE_2018_out/stageone
$ blastx -query extracted.fa -out MGEblastout.txt -db ~/~/MGE_BMG_aod/Ublastx_stageone/DB/MGE_2018_amino_sl.fasta -outfmt 6 -num_threads 14 -max_target_seqs 1
```   

4. into R and reannontate blastouput  
using "mge_ARGoapquantification.R"

whatever DB you want to analyze, just use this method and you can get the same quantification method as ARGs-OAP

### [ARGs-OAPv3.2](https://github.com/xinehc/args_oap)  
Basically, the new version of ARGs-OAP is easier to use and more flexible. Now We Don't need to construct our pipeline for other DB, there is a protocol to use ARGs-OAP v3.2 pipeline to analyze other DB. [ARGs-OAPv3.2 manual](https://github.com/xinehc/args_oap)  
You should notic the quantification method of ARGs-OAPv3.0 is different to ARGs-OAP v2.2 in 2 asepect.
1. They remove the **regulator gene(eg.cpxR)** in short reads quantification pipeline(aka. ARGs-OAP piplne), but they still kept it in full database.    

   *That means now we need to use 2 different DB(SARG v3.2.1-S and SARG v3.2.1-F). 1 is for the short reads analysis pipeline (SARG v3.2.1-S) the other is for your Assembly Based analysis usage (SARG v3.2.1-F)*

2. There has a multiple group system in the quantification equation.  
Check out the paper.    
[Yin, X., Zheng, X., Li, L., Zhang, A. N., Jiang, X. T., & Zhang, T. (2022). ARGs-OAP v3. 0: Antibiotic-resistance gene database curation and analysis pipeline optimization. Engineering.](https://www.sciencedirect.com/science/article/pii/S2095809922008062) 
#### Installation
```
$ conda create -n args_oap -c bioconda -c conda-forge args_oap
$ conda activate args_oap
```
#### ARGs analysis
```
# Stage one
$ args_oap stage_one -i /media/sf_sf/cleanread_new/ -o ~/args_oap_v3_out/ARG/stage_one_output -f fq -t 18


# Stage two (BLASTX: id>80% , E-value<1e-7,Query Coverage>75%, aa length>25)
$ args_oap stage_two -i ~/args_oap_v3_out/ARG/stage_one_output -o ~/args_oap_v3_out/ARG/stage_two_output -t 18
```

#### MGEs (Mobile Genetic Elements) analysis
 this part is from our 先輩 睿紘's pipeline [Github](https://github.com/yenjh3910/bioinformatic_pipeline#readme)  
(shout out to 睿紘, thanks for you teaching me everything)  

Database: https://github.com/KatariinaParnanen/MobileGeneticElementDatabase
1. Covert nucleotide acid to amino acid under fasta format
2. Create MGE_structure.txt manually or use curated structure already made
Curated MGE database can be found [here](https://github.com/yenjh3910/airborne_arg_uwtp/blob/master/MGE/MGE_structure/MGE_curated_structure.txt)
```
$ mkdir ~/args_oap/MGE
$ cd ~/args_oap/MGE

### Amino acid
# (Optional)
$ echo '>level1' | cat - MGEs_database_aa.fasta | grep '^>' | cut -d ' ' -f 1 | cut -c2- > MGE_AA_structure.txt

# The database should be indexed manually (protein or nucleotide, in fasta)
$ args_oap make_db -i MGEs_database_aa.fasta

# Stage one
$ args_oap stage_one -i ~/clean_read -o ~/args_oap/MGE/AA_stage_one_output -f fastq -t 16 --database ~/args_oap/MGE/MGEs_database_aa.fasta

# Stage two
$ args_oap stage_two -i ~/args_oap/MGE/AA_stage_one_output -o ~/args_oap/MGE/AA_stage_two_output -t 16 --database ~/args_oap/MGE/MGEs_database_aa.fasta --structure1 ~/args_oap/MGE/MGE_curated_structure.txt

### DNA blast
# The database should be indexed manually (protein or nucleotide, in fasta)
$ args_oap make_db -i MGEs_database_dna.fasta

# Stage one
$ args_oap stage_one -i ~/clean_read -o ~/args_oap/MGE/DNA_stage_one_output -f fastq -t 16 --database ~/args_oap/MGE/MGEs_database_dna.fasta

# Stage two
$ args_oap stage_two -i ~/args_oap/MGE/DNA_stage_one_output -o ~/args_oap/MGE/DNA_stage_two_output -t 16 --database ~/args_oap/MGE/MGEs_database_dna.fasta --structure1 ~/args_oap/MGE/MGE_curated_structure.txt
```
### MRGs (Metal Resistance Genes) analysis
Database: http://bacmet.biomedicine.gu.se/  
Curated metal structure file can be found [here](https://github.com/yenjh3910/airborne_arg_uwtp/blob/master/BacMet/BacMet_structure/metal_only_structure.txt)
```
# The database should be indexed manually (protein or nucleotide, in fasta)
$ args_oap make_db -i BacMet_exp_metal.fasta

# Stage one
$ args_oap stage_one -i ~/clean_read -o ~/args_oap/BacMet/stage_one_output -f fastq -t 16 --database ~/args_oap/BacMet/BacMet_exp_metal.fasta

# Stage two
$ args_oap stage_two -i ~/args_oap/BacMet/stage_one_output -o ~/args_oap/BacMet/stage_two_output -t 16 --database ~/args_oap/BacMet/BacMet_exp_metal.fasta --structure1 ~/args_oap/BacMet/metal_only_structure.txt

# Since default parameter in stage two is too strict for MGE, following parameters (--e 1e-5 --id 70) were used: 
$ args_oap stage_two -i ~/args_oap/BacMet/stage_one_output -o ~/args_oap/BacMet/stage_two_output_evalue-5_id70 --e 1e-5 --id 70 -t 16 --database ~/args_oap/BacMet/BacMet_exp_metal.fasta --structure1 ~/ar
gs_oap/BacMet/metal_only_structure.txt
```


# 以下未寫
## Functional Profile
### [HUMAnN 3.0](https://github.com/biobakery/humann/tree/8d69f3c84ca7bfd7519ced7fcf94b8356c915090)
#### Installation
```
# Create environment
$ conda create --name humann3
$ conda activate humann3

# Add channel
$ conda config --add channels defaults
$ conda config --add channels bioconda
$ conda config --add channels conda-forge
$ conda config --add channels biobakery

# Install
$ conda install -c conda-forge -c bioconda -c biobakery metaphlan=4.0.3
$ conda install -c biobakery humann

# Test
$ cd ~/clean_read
$ metaphlan <sample_1.fastq.gz,sample_2.fastq.gz> --bowtie2out sample_metaphlan.bowtie2.bz2 --input_type fastq --nproc 16 > sample_metaphlan.txt
$ humann_test
```
#### Download database
```
$ humann_databases --download chocophlan full ~/db/humann3_db --update-config yes # ChocoPhlAn database
$ humann_databases --download uniref uniref90_diamond ~/db/humann3_db --update-config yes # Translated search databases
$ humann_databases --download utility_mapping full  ~/db/humann3_db --update-config yes # HUMAnN 3.0 utility mapping files
```
#### Update path
```
$ humann_config --update database_folders nucleotide ~/db/humann3_db/chocophlan
$ humann_config --update database_folders protein ~/db/humann3_db/uniref
$ humann_config --update database_folders utility_mapping ~/db/humann3_db/utility_mapping
```
#### [Bug when running humann3](https://forum.biobakery.org/t/metaphlan-v4-0-2-and-huma-3-6-metaphlan-taxonomic-profile-provided-was-not-generated-with-the-expected-database/4296/22): 
```
config.metaphlan_v3_db_version+" or "+metaphlan_v4_db_version+" . Please update your version of MetaPhlAn to at least v3.0."
NameError: name 'metaphlan_v4_db_version' is not defined

# Solve:
## Install the database in a folder outside the Conda environment with a specific version.
$ metaphlan --install --index mpa_vJan21_CHOCOPhlAnSGB_202103 --bowtie2db db/humann3_db/metaphlan_database_humann_compatible
```
#### Usage
```
# Run
$ ~/shell_script/humann3.sh

# Post processing
$ ~/shell_script/humann3_post_processing.sh
```
# 以上未寫
# Assembly Based analysis
## Reads Assembly / Contigs QC/ ORFs prediction

### Reads Assembly ([Megahit](https://github.com/voutcn/megahit))
**Installation**
```
$ conda activate
$ conda install -c bioconda megahit
#Test 
$ megahit
```
**Usage**
indivisual assembly or co-assembly is up to you
```
$ conda activate
$ megahit -t 16 -m 0.95 -1 <file_1.fq> -2 <file_2.fq> --min-contig-len 500 -o <file.final.contigs>
```
### Contigs QC ([Quast](https://github.com/ablab/quast))
Installation
```
$ conda create -n quast
$ conda activate quast
$ conda install -c bioconda quast
```
Usage
```
$ conda activate quast
$ perl -w quast.pl
```
### ORFs prediction ([Prodigal]((https://github.com/hyattpd/Prodigal)))
**Installation**
```
$ conda activate
$ conda install -c bioconda prodigal
$ prodigal 
```

**Usage**
```
#Single use
$ prodigal -i <final_contigs> -o <prodigal_out> -a <prodigal_out.protein> -d <prodigal_out.nucl> -p meta

#combine script(assembly and gene prediction)
$ perl -w megahit_prodigal.pl
```
**Some papers use CD-HIT after ORFs prediction to remove redundant ORFs, but some papers don't do this , so you may need CD-HIT**

## Contigs ARG gene predction(ARC)
### [Diamond](https://github.com/bbuchfink/diamond)
sequence Blast   

Installation & makeDB
```
$ conda activate
$ conda install -c conda-forge diamond
#You should very notice the version you installed of diamond

# Make database(for blastx, make .dmnd from aa sequence)
$ conda activate
$ cd /media/sf_sf/DB/Diamond/DB
$ diamond makedb --in SARG2.2_DB.fasta --db SARG2.2_DB.dmnd
$ diamond makedb --in MGEs_database_aa.fasta --db MGE.dmnd
$ diamond makedb --in bacmet_experiment.fasta --db bacmet_experiment.dmnd
$ diamond makedb --in VFDB_coredataset.fasta --db VFDB_coredataset.dmnd
```
Basic Usage
```
#id=70,e=-10,query cover=70
diamond blastx -d /media/sf_sf/DB/Diamond/DB/SARG2.2_DB.dmnd -q <orf.nucl> -p 16 --id 70 -p 16 -e 1e-10 -f 6 -k 1 --query-cover 70 -o <blastout.txt>
```
Combine Usage  
1. Annonation of ARG like-ORF(all contig)   
2. Extract ARC fasta(Seqkit)
3. Predict ARC ORF (ARC)
4. Reblast ARC ORFs with SARG
5. Blast ARC ORFs to nr(for taxanomic Asseignment of ARCs)
```
#make sure you have installed all dependencies in conda base env (seqkit,prodigal,diamond)
$ conda activate
$ perl -w ARGprediction_ARCextract.pl
```
6. blast ARC with MGEs/VF/BMG DB to find co-occurance
```
$ conda activate
$ perl -w MGE_VF_blast.pl

# Enter R 
# UseR to reannonate gene name
like MGE_diamond_hitted_reannonate.R
```


## Taxanomic Assignment of ARCs
This section have 2 methods   
**A**. NR+MEGAN  
**B**. kraken2   

*NR+MEGAN is a more traditional approach, but this method will have lots of contigs that can't be classified.Kraken2 is a k-mer based method, most contigs can be classified through this method.
### NR+MEGAN
1. blast the ORFs of all ARCs with NR_DB
   This was Done in 
2. Use MEGAN to classified NR blast output
```
#import DAA file and Meganize
1.click File-Meganize.DAA file
2.Files:choose DAA File, tick long reads
3.Taxonomy:Load MeganMap DB mapping file
4.LCA parameter: LCA Algorithm: longreads
Read Alignment mode: read count
Percent to cover: 51
5.Apply

#turn output to txt
1. select all node of output
2. (right click) slect inspect
#you will see the format for example 
NCBI [1]
cellular organisms [0]
Bacteria [29]
Acidobacteria [0]

3. open all inspect
#for example you will get this
Acidobacteria [0]
unclassified Acidobacteria [1]
k141_517147_2 [length=151, matches=25]

4. Files: Exported selected Text
5. save output
```
#### Usage
after your save the MEGAN output, use custom scripts doing voting method
```
$ perl -w MEGAN_out_procress.pl
```
### kakrn2
This method is quite simple, just give kraken2 your ARC sequence fasta file
```
$ conda activate
$ kraken2 --db /media/sf_sf/DB/kraken2/DB/bacteria_DB/ ~/location_co_assembly/SARG3.2/blastx_sm70_cover70_e10/ARC/T5-WARC.fa --threads 18 --use-names --output T5-WARC_kraken2.txt --report T5-WARC_kraken2.report
```
or use a perl script to do it all
```
# I have't written this script sorry 
#but this is a simple loop script
```
use an R script to combine all output and link the output taxonomic assignment with higher taxonomic level
```
ARC_kraken2_classification_combine_taxa.R
```


## ORF coverage /contig coverage caculation
#### ORF Coverage caculation 
1.  Extract ARC-like ORFs list(custom perl script)
2.  Extract ARC-like ORFs sequence(seqkit)
3.  Mappinng reads to ARC-like ORFs sequence to caculate coverage(Botwie& BBmap)
4.  Caclute ORF coverager per GB    
   
**if you do it manually, this will be a quite complicated procedure. but there has an all-in-one script.**
```
#make sure you install all dependecies in conda base env(Bowtie2, BBmap, seqkit)
#Bowtie2 and seqkit can through Bioconda to get it 
#Personally I got BBmap from here(https://sourceforge.net/projects/bbmap/) and just unzip 
$ conda activate
$ perl -w ARG-ORF_coverage_SARG3.2.pl
```
#### Contigs Coverage caculation  
I personally thought the contigs coverage calculation is the same as the ORFs coverage calculation
1.  Extract ARC list(custom perl script)
2.  Extract ARC sequence(seqkit)
3.  Mappinng reads to ARC sequence to caculate coverage(Botwie& BBmap)
4.  Caclute ORF coverager per GB    
   
**if you do it manually, this will be a quite complicated procedure. but there has an all-in-one script.**
```
$ conda activate
#This script needs to be renewed for adapting the kraken2 classification of ARCs
$ perl -w ARC-coverage_SARG3.2.pl
```
I personally recommand you doing Assembly-Based analysis in this order.
1. Get ARG-lik ORFs and ARCs.
2. Calculate the Coverage of ARC-like ORFs and ARCs.Meanwhile, connect the ARG gene name with ARG subtype names.
3. Connect the ARCs taxonomic assigment with 2. output df.    
if you want to reproduce my plots, you should have a data frame like this
## Metacompare
Risk assement of ARGs
### Installation
```
# Installation
$ sudo apt-get update
$ sudo apt-get install python3-biopython
$ sudo apt-get install python3-pandas
$ git clone https://github.com/minoh0201/MetaCompare
$ cd MetaCompare
$ mkdir BlastDB
$ cd BlastDB
$ wget http://bench.cs.vt.edu/ftp/data/metacomp/BlastDB.tar.gz
$ tar -zxvf BlastDB.tar.gz
$ cd ../
$ ./metacmp.py
```
### Usage
```
$ perl -w metacompare.pl
```
## Plasflow
# Binning Based analysis
## Reads normalization
Because of the PC limitation, we need to normalize our reads first to reduce the computer loading
```
#same, make sure you have installed BBmap before you use this script
$ perl -w bbnorm.pl
```
## Co-Assembly
Pooling all sample reads  together to co-assembly
```
#Co-assembly
$ conda activate
$ megahit -t 16 -m 0.95 -1 nT1-W-1_1.fq,nT1-W-2_1.fq,nT1-W-3_1.fq,nT2-W-1_1.fq,nT2-W-2_1.fq,nT2-W-3_1.fq,nT3-W-1_1.fq,nT3-W-2_1.fq,nT3-W-3_1.fq,nT4-W-1_1.fq,nT4-W-2_1.fq,nT4-W-3_1.fq,nT5-W-1_1.fq,nT5-W-2_1.fq,nT5-W-3_1.fq -2 nT1-W-1_2.fq,nT1-W-2_2.fq,nT1-W-3_2.fq,nT2-W-1_2.fq,nT2-W-2_2.fq,nT2-W-3_2.fq,nT3-W-1_2.fq,nT3-W-2_2.fq,nT3-W-3_2.fq,nT4-W-1_2.fq,nT4-W-2_2.fq,nT4-W-3_2.fq,nT5-W-1_2.fq,nT5-W-2_2.fq,nT5-W-3_2.fq --min-contig-len 500 -o $output_directory

#Assembly quality assement
$ conda activate
#Enter quast directory
$ ./quast.py ~/all_sample_co_assembly/final.contigs.fa -o ~/all_sample_co_assembly/al1_sample_coassembly_contig/quast
```

## Binning/Bin_refinement/Genepredictions

In Binning process we use [MetaWRAP](https://github.com/bxlab/metaWRAP), but there have some problems that will cause env conflict, so we need to add another user(add an independent user to install Metawrap)

### MetaWRAP Installation
```
#add user called metawrap
$ sudo adduser --home /home/metrawrap metawrap
#adding user to let new user using the D:/ file
$ sudo usermod --append --groups vboxsf metawrap

#Install conda 
metawrap@....$ wget https://repo.anaconda.com/archive/Anaconda3-2023.03-1-Linux-x86_64.sh
#Check the intergrity of the download packages
metawrap@....$ sha256sum Anaconda3-2023.03-1-Linux-x86_64.sh

metawrap@....$ bash Anaconda3-2023.03-1-Linux-x86_64.sh
metawrap@....$ source ~/.bashrc
metawrap@....$ conda info

#Adding channels 
metawrap@....$ conda config --add channels bioconda
metawrap@....$ conda config --add channels conda-forge
metawrap@....$ conda config -- show channels

#Install Mambaforge
#That's the reason why i reconmand you don't install in same user, because mamba will take your original conda command

#Download mambaforge
metawrap@....$ wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh

#Install mambaforge
metawrap@....$ bash Mambaforge-Linux-x86_64.sh

close terminal and open a new terminal

#Install Metawrap
metawrap@....$ mamba create -y --name metawrap-env --channel ursky metawrap-mg=1.3.2
metawrap@....$ conda install -y blas=2.5=mkl

```
#### Metawrap DB configuration
```
#CheckM DB------------------------------------

metawrap@....$ mkdir /media/sf_sf/DB/Metawrap/CheckM_DB
# Now manually download the database:
metawrap@....$ cd /media/sf_sf/DB/Metawrap/CheckM_DB
metawrap@....$ wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
metawrap@....$ tar -xvf *.tar.gz
metawrap@....$ rm *.gz
metawrap@....$ cd

# Tell CheckM where to find this data before 
metawrap@....$ checkm data setRoot 
# On newer versions of CheckM, you would run:
metawrap@....$ checkm data setRoot /media/sf_sf/DB/Metawrap/CheckM_DB

#NCBI_nt&NCBI_tax if for metawrap blobgyplot
#NCBI_nt--------------------------
metawrap@....$ mkdir /media/sf_sf/DB/Metawrap/NCBI_nt
metawrap@....$ cd /media/sf_sf/DB/Metawrap/NCBI_nt
wget "ftp://ftp.ncbi.nlm.nih.gov/blast/db/nt.*.tar.gz"
for a in nt.*.tar.gz; do tar xzf $a; done

#edit config-metawrap file
metawrap@....$ which config-metawrap
metawrap@....$ vim /home/metawrap/mambaforge/envs/metawrap-env/bin/config-metawrap
#enter config-metawrap file and chage BLASTDB
BLASTDB=/media/sf_sf/DB/Metawrap/NCBI_nt

#NCBI_tax----------------------------
metawrap@....$ mkdir /media/sf_sf/DB/Metawrap/NCBI_tax
metawrap@....$ cd /media/sf_sf/DB/Metawrap/NCBI_tax
metawrap@....$ wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
metawrap@....$ tar -xzvf taxdump.tar.gz.
#this gz file is always a hava some problem to unzip,you can download file manual in http
https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz

#edit config-metawrap file
metawrap@....$ vim /home/metawrap/mambaforge/envs/metawrap-env/bin/config-metawrap
#enter config-metawrap file and chage TAXDUMP
TAXDUMP=/media/sf_sf/DB/Metawrap/NCBI_tax
```
#### Usage
```
# Binning with three different algorithms------------------
metawrap@....$ conda activate metawrap-env
metawrap@....$ metawrap binning -o metawrap_out/intinal_binn -t 16 -a ~/all_sample_co_assembly/final.contigs.fa --metabat2 --maxbin2 --concoct /media/sf_sf/cleanread_new/*.fastq

# Bin refinement---------------------------
#(remove redundant bins and keep bin which has completeness>50%, contamination<10%)
metawrap@....$ conda activate metawrap-env
metawrap@....$ metawrap bin_refinement -o ~/metawrap_run/bin_refinement -t 16 -A ~/metawrap_out/intinal_binning/metabat2_bins -B ~/metawrap_out/intinal_binning/maxbin2_bins -C ~/metawrap_out/intinal_binning/concoct_bins -c 50 -x 10 -m 96

# caculate coverage of each high Q bin in each sample----------------------------
metawrap@....$ conda activate metawrap-env
metawrap@....$  metawrap quant_bins -b ~/metawrap_out/bin_refinement/metawrap_50_10_bins -o ~/metawrap_out/bin_quant -a ~/all_sample_co_assembly/final.contigs.fa /media/sf_sf/cleanread_new/*.fastq -t 16

#Gene prediction-----------------------------------------
(This step needs to be done in the original user, make sure the original user(tungs-lab) has permission to read and write the metawrap output file(especially bins file). if don't, you can try to copy the bin file to the original user directory )

#reopen a terminal, and you will back to tungs-lab
$ conda activate

$perl -w bin_prodigal_ARGblast_SARG3.2.pl -i ~/all_sample_co_assembly/metawrap_out/bin_refinement/metawrap_50_10_bins/ -p ~/all_sample_co_assembly/SARG3.2/bin_50_10_prodigal/ -o ~/all_sample_co_assembly/SARG3.2/bin_50_10_ARGblast/ -m ~/all_sample_co_assembly/SARG3.2/bin_50_10_MGEblast/ -v ~/all_sample_co_assembly/SARG3.2/bin_50_10_VFblast/ -b ~/all_sample_co_assembly/SARG3.2/bin_50_10_bacmetblast/ ~/all_sample_co_assembly/metawrap_out/bin_refinement/metawrap_50_10_bins/*.fa
```
## Bin classification([GTDB-tk](https://ecogenomics.github.io/GTDBTk/installing/bioconda.html))

**Installation**
```
#Install 
$ conda create -n gtdbtk-2.2.4 -c conda-forge -c bioconda gtdbtk=2.2.4
#config database
#1.automatically
$ download-db.sh
#2.manual
#Download GTDB-tk refernce DB(https://ecogenomics.github.io/GTDBTk/installing/index.html)
# config DB manually
$ conda env config vars set GTDBTK_DATA_PATH="/home/tungs-lab/anaconda3/envs/gtdbtk-2.2.4/share/gtdbtk-2.2.4/db"
```
**Usage**
```
gtdbtk classify_wf --genome_dir ~/all_sample_co_assembly/metawrap_out/bin_refinement/metawrap_50_10_bins -x fa --out_dir ~/all_sample_co_assembly/bins_gtdbtk --cpus 16 --skip-ani
```
### MetaCHIP










