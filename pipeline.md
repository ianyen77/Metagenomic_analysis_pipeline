# A metagenomic survey of antibiotic resistome along a drinking water distribution system
Complete Metagenomic analysis piepline for ARGs survey

## Table of Contents
1. [Anaconda & Bioconda Installation]()
2. [Reads Quality Control]()
3. [ARGs Profile]()
4. [Taxanomic Profile]()
5. []()
6. []()
   

## Anaconda & Bioconda Installation
### [Anaconda installation](https://www.anaconda.com/download/)
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
### [Bioconda Installation](https://bioconda.github.io/)
```
$ conda config --add channels defaults
$ conda config --add channels bioconda
$ conda config --add channels conda-forge
$ conda config --set channel_priority strict
# View channel
$ conda config --show channels
```


## Reads Quality Control
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


## Taxanomic Profile
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
$ kraken2-build --download-taxonomy --threads 16 --db ~/DB/kraken2
``` 
#### Debug 
1. https://qiita-com.translate.goog/kohei-108/items/ce5fdf10c11d1e7ca15b?_x_tr_sl=ja&_x_tr_tl=zh-TW&_x_tr_hl=zh-TW&_x_tr_pto=sc
2.  https://github.com/DerrickWood/kraken2/issues/518  
Change "rsync_from_ncbi.pl" (in conda directory) Line 46:  
```
if (! ($full_path =~ s#^ftp://${qm_server}${qm_server_path}/##))  to 
if (! ($full_path =~ s#^https://${qm_server}${qm_server_path}/##))
``` 
#### Download partial library
```
$ kraken2-build --download-library bacteria --threads 16 --db ~/DB/kraken2
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

**Usage**

# unwrite

### [Bracken](https://github.com/jenniferlu717/Bracken)
#### Installation
```
# Install prerequisite
$ sudo apt-get install build-essential

# Install Bracken
$ git clone https://github.com/jenniferlu717/Bracken.git
$ cd Bracken
$ bash install_bracken.sh
$ cd src/ && make

# Add dictionary to path
$ nano ~/.bashrc
# Add to last row
$ export PATH="~/Bracken:$PATH"
$ export PATH="~/Bracken/src:$PATH"
# Load the new $PATH
$ source ~/.bashrc

# Test 
$ bracken -h   
```   
#### Build bracken library
```
$ bracken-build -d ~/db/kraken_db -t 16 -k 35 -l 150
```


#### Usage 
 ```
$ ~/shell_script/kraken2.sh
 ```
 # 以上未寫
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
$ usearch -makeudb_ublast gg85.fasta -output gg85.udb
$ usearch -makeudb_ublast SARG.2.2.fasta -output SARG.2.2.udb
```
#### ARGs analysis
1. create meta-data.txt   

|SampleID|Name|Category|LibrarySize|
|--|----|----|-|
|1|T1-W-1|Raw|150|
|2|T2-W-2|Finished|150|
2. perl script
```
```
#以下未寫

### [ARGs-OAPv3.0](https://github.com/xinehc/args_oap)
#### Installation
```
$ conda create -n args_oap
$ conda activate args_oap
$ conda config --set channel_priority flexible
$ conda install -c bioconda -c conda-forge args_oap
```
#### ARGs analysis
```
# Stage one
$ args_oap stage_one -i ~/clean_read -o ~/args_oap/ARG/stage_one_output -f fastq -t 16

# Stage two (e_value: 1e-7, identity: 80, aa_length,25)
$ args_oap stage_two -i ~/args_oap/ARG/stage_one_output -o ~/args_oap/ARG/stage_two_output -t 16
```
#### MGEs (Mobile Genetic Elements) analysis
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
## Taxanomic Assignment of Assembly Contigs
Use kraken2 to assign the toxanomy to individual assmebly contigs  
#### Usage
```
$ conda activate kraken2
$ ~/shell_script/kraken2_contigs.sh
```
## Gene Alignment to Assembly Contigs
### [Prodigal](https://github.com/hyattpd/Prodigal) & [CD-HIT](https://github.com/weizhongli/cdhit)
Gene prediction & (reductant sequence remove)
```
# Create environment
$ conda create -n prodigal
$ conda activate prodigal

# Installation
$ conda install -c bioconda prodigal
$ conda install -c bioconda cd-hit

# ORF perdiction
$ ~/shell_script/prodigal_contigs.sh

# Remove reductant sequence (Omit in the newest pipeline)
$ ~/shell_script/cdhit_orf.sh
```
### [Diamond](https://github.com/bbuchfink/diamond)
BLAST sequence
```
# Create environment
$ conda create -n diamond
$ conda activate diamond

# Installation
$ conda install -c bioconda diamond

# Make database
$ diamond makedb --in ~/db/args_oap_db/sarg.fasta --db ~/db/args_oap_db/SARG.dmnd
$ diamond makedb --in ~/db/MGE_db/MGEs_database_aa.fasta --db ~/db/MGE_db/MGE.dmnd
$ diamond makedb --in ~/db/BacMet_db/BacMet_exp_metal.fasta --db ~/db/BacMet_db/BacMet.dmnd
$ diamond makedb --in ~/db/vfdb/VFDB_setB_pro.fa --db ~/db/vfdb/VFDB.dmnd

# Run
$ ~/shell_script/diamond_contigs.sh


# R script
$ cd ./contigs

## Merge blast contigs with kraken2 taxonomy
$ Rscript contigs_kraken2.R

## QC & merge blast contigs with database
$ Rscript contigs_ARG_diamond.R
$ Rscript contigs_MGE_diamond.R
$ Rscript contigs_VF_diamond.R

## Extract contigs as mapping reference for coverage calculation
$ Rscript extract_SARG_contigs.R
$ Rscript extract_MGE_contigs.R
$ Rscript extract_VF_contigs.R
```
## Calculate coverage of aligning contigs
### [Bowtie2](https://github.com/BenLangmead/bowtie2) & [BBMap](https://github.com/BioInfoTools/BBMap)
```
# Enter environment
$ conda activate diamond

# Installation
$ conda install -c bioconda bowtie2
$ conda install -c bioconda bbmap

# Build bowtie2 index
$ ~/shell_script/bowtie2_build_contigs.sh

# Bowtie2 mapping & coverage calculation
$  ~/shell_script/coverage_contigs.sh
```
## Binning
### [metaWRAP](https://github.com/bxlab/metaWRAP)
```
# Installation & environment creation

## Install mamba
$ conda install -y mamba
## Download or clone this ripository
$ git clone https://github.com/bxlab/metaWRAP.git

## Configure
$ mkdir ~/db/checkm_db
$ cd ~/db/checkm_db
$ wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
$ tar -xvf *.tar.gz
$ rm *.gz

## Make metaWRAP executable
$ vi ~/.bashrc
$ export PATH="~/metaWRAP/bin/:$PATH" # Add to last row

## Make a new conda environment
$ conda create -y -n metawrap-env python=2.7
$ conda activate metawrap-env

## Install all metaWRAP dependancies
$ conda config --add channels defaults
$ conda config --add channels conda-forge
$ conda config --add channels bioconda
$ conda config --add channels ursky
$ mamba install --only-deps -c ursky metawrap-mg

## Configure checkm
$ conda install -c bioconda checkm-genome
$ checkm data setRoot ~db/checkm_db # Tell CheckM where to find this data
```