#!/bin/bash
mkdir ~/kraken2_bracken
for i in $(<~/clean_read_list)
do
	# bracken
	bracken -d /media/sf_sf/DB/kraken2/DB -i ~/kraken2_mpa/${i}_kraken2.report -o ~/kraken2_bracken/${i}.D.bracken -w ~/kraken2_bracken/${i}.D.bracken.report -r 150 -l D
	bracken -d /media/sf_sf/DB/kraken2/DB -i ~/kraken2_mpa/${i}_kraken2.report -o ~/kraken2_bracken/${i}.P.bracken -w ~/kraken2_bracken/${i}.P.bracken.report -r 150 -l P
	bracken -d /media/sf_sf/DB/kraken2/DB -i ~/kraken2_mpa/${i}_kraken2.report -o ~/kraken2_bracken/${i}.C.bracken -w ~/kraken2_bracken/${i}.C.bracken.report -r 150 -l C
	bracken -d /media/sf_sf/DB/kraken2/DB -i ~/kraken2_mpa/${i}_kraken2.report -o ~/kraken2_bracken/${i}.O.bracken -w ~/kraken2_bracken/${i}.O.bracken.report -r 150 -l O
	bracken -d /media/sf_sf/DB/kraken2/DB -i ~/kraken2_mpa/${i}_kraken2.report -o ~/kraken2_bracken/${i}.F.bracken -w ~/kraken2_bracken/${i}.F.bracken.report -r 150 -l F
	bracken -d /media/sf_sf/DB/kraken2/DB -i ~/kraken2_mpa/${i}_kraken2.report -o ~/kraken2_bracken/${i}.G.bracken -w ~/kraken2_bracken/${i}.G.bracken.report -r 150 -l G
	bracken -d /media/sf_sf/DB/kraken2/DB -i ~/kraken2_mpa/${i}_kraken2.report -o ~/kraken2_bracken/${i}.S.bracken -w ~/kraken2_bracken/${i}.S.bracken.report -r 150 -l S

done
