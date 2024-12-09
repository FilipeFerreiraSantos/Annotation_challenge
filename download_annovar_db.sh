#!/usr/bin/env bash

# Download dbSNP database version 150 (most up to date so far)
perl annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar avsnp150 annovar/humandb/ 2> logs/annotate_variation.avsnp150.log

# If needed, in case the Git Large File Storage (LFS) somehow fails to upload the databases from RefSeq and ABraOM, uncomment the following 2 lines of code
## These files are discriminated in ".gitattributes"
#perl annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar refGene annovar/humandb/ 2> logs/annotate_variation.refGene.log
#perl annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar abraom annovar/humandb/ 2> logs/annotate_variation.abraom.log

# If you want, you could download extra databases to get allele frequencies such as gnomAD
## PS: since it is too big (30GB), I decided to not include it in the final results
#perl annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar gnomad211_genome annovar/humandb/ 2> logs/annotate_variation.gnomad211_genome.log
