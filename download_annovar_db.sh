#!/usr/bin/env bash

# Download dbSNP database version 150 (most up to date so far)
perl annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar avsnp150 annovar/humandb/ 2> logs/annotate_variation.avsnp150.log

# If you want, you could download extra databases to get allele frequencies such as gnomAD
## PS: since it is too big (30GB), I decided to not include it in the final results
#perl annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar gnomad211_genome annovar/humandb/ 2> logs/annotate_variation.gnomad211_genome.log
