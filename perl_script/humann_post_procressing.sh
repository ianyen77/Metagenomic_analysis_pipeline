#!/bin/bash
##Author: yenjh3910
#This shell script is from yen,for humann post porcressing

# Join the output files
mkdir ~/humann3/sample_join
humann_join_tables --input ~/humann3 --output ~/humann3/sample_join/genefamilies.tsv --file_name genefamilies
humann_join_tables --input ~/humann3 --output ~/humann3/sample_join/pathabundance.tsv --file_name pathabundance
humann_join_tables --input ~/humann3 --output ~/humann3/sample_join/pathcoverage.tsv --file_name pathcoverage

# gene family
## uniref90
mkdir ~/humann3/uniref90
humann_rename_table --input ~/humann3/sample_join/genefamilies.tsv --names uniref90 --output ~/humann3/uniref90/genefamilies_rename_uniref90.tsv
humann_renorm_table --input ~/humann3/uniref90/genefamilies_rename_uniref90.tsv --output ~/humann3/uniref90/genefamilies_rename_uniref90_cpm.tsv  --units cpm
humann_renorm_table --input ~/humann3/uniref90/genefamilies_rename_uniref90.tsv --output ~/humann3/uniref90/genefamilies_rename_uniref90_relab.tsv  --units relab

## Regroup to pfam
mkdir ~/humann3/pfam
humann_regroup_table -i ~/humann3/sample_join/genefamilies.tsv -g uniref90_pfam -o ~/humann3/pfam/genefamilies_regroup_pfam.tsv
humann_rename_table --input ~/humann3/pfam/genefamilies_regroup_pfam.tsv  --names pfam --output ~/humann3/pfam/genefamilies_rename_pfam.tsv
humann_renorm_table --input ~/humann3/pfam/genefamilies_rename_pfam.tsv --output ~/humann3/pfam/genefamilies_rename_pfam_cpm.tsv  --units cpm -s n
rm ~/humann3/pfam/genefamilies_regroup_pfam.tsv

## Regroup to GO
mkdir ~/humann3/GO
humann_regroup_table -i ~/humann3/sample_join/genefamilies.tsv -g uniref90_go -o ~/humann3/GO/genefamilies_regroup_go.tsv
humann_rename_table --input ~/humann3/GO/genefamilies_regroup_go.tsv  --names go --output ~/humann3/GO/genefamilies_rename_go.tsv
humann_renorm_table --input ~/humann3/GO/genefamilies_rename_go.tsv --output ~/humann3/GO/genefamilies_rename_go_cpm.tsv  --units cpm -s n
rm  ~/humann3/GO/genefamilies_regroup_go.tsv

## Regroup to KEGG
mkdir ~/humann3/KEGG
humann_regroup_table -i ~/humann3/sample_join/genefamilies.tsv -g uniref90_ko -o ~/humann3/KEGG/genefamilies_regroup_ko.tsv
humann_rename_table --input ~/humann3/KEGG/genefamilies_regroup_ko.tsv  --names kegg-orthology --output ~/humann3/KEGG/genefamilies_rename_kegg-orthology.tsv
humann_renorm_table --input ~/humann3/KEGG/genefamilies_rename_kegg-orthology.tsv --output ~/humann3/KEGG/genefamilies_rename_kegg-orthology_cpm.tsv  --units cpm -s n
rm ~/humann3/KEGG/genefamilies_regroup_ko.tsv

# path abundance
mkdir ~/humann3/path_abundance
humann_renorm_table --input ~/humann3/sample_join/pathabundance.tsv --output ~/humann3/path_abundance/pathabundance_cpm.tsv  --units cpm
humann_renorm_table --input ~/humann3/sample_join/pathabundance.tsv --output ~/humann3/path_abundance/pathabundance_relab.tsv  --units relab
