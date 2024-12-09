# DASA challenge
## Basic bioinformatics pipeline to annotate a VCF v4.1 file with Python3 and BASH (shell scripts) using Snakemake

STEPS:
1) After running the "git clone" command, use the Dockerfile to build and run the image
2) Once inside the container, make sure you are in the CONDA environment to run Snakemake
3) Run the command "bash download_annovar_db.sh" to download other extra required files (dbSNP database) to properly execute the analyses
4) Run the Snakefile to execute the pipeline
5) Run "python flaskApp.py" to execute the API
