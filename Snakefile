# Snakefile
## Make sure all the rules are sequential

# Loads 'config.yaml'
configfile: "config.yaml"

# Accesses PARameters
build_version = config["build_version"]  # Reference genome build
threads = config["threads"]  # Number of threads to use

# General rule
## Add final outputs to ensure the other rules are executed
rule all:
    input:
        "results/annotated.hg19_multianno.edited.txt"

# Converts VCF to ANNOVAR-compatible format
rule convert_to_annovar:
    input:
        vcf="data/NIST.vcf"
    output:
        avinput="data/input.annovar"
    params:
        annovar_dir="annovar",
        in_format="vcf4",
        log_dir="logs"
    shell:
        """
        perl {params.annovar_dir}/convert2annovar.pl --verbose -format {params.in_format} --outfile {output.avinput} {input.vcf} 2> {params.log_dir}/convert2annovar.log
        """

# Annotates file with ANNOVAR
rule annotate_with_annovar:
    input:
        avinput="data/input.annovar",
    output:
        "results/annotated.hg19_multianno.txt"
    params:
        annovar_dir="annovar",
        humandb="annovar/humandb",
        tmp_dir="myTMPdir",
        log_dir="logs",
        prefix="results/annotated"
    shell:
        """
        perl {params.annovar_dir}/table_annovar.pl {input.avinput} {params.humandb} --verbose --tempdir {params.tmp_dir} \
            --dot2underline --thread {threads} -buildver {build_version} -outfile {params.prefix} -remove \
            -protocol refGene,avsnp150,abraom -operation g,f,f \
            -nastring . -polish -otherinfo 2> {params.log_dir}/table_annovar.log
        """

# Changes the names of the last 3 columns kept from the input VCF
rule edit_output:
    input:
        avinput="results/annotated.hg19_multianno.txt"
    output:
        avoutput="results/annotated.hg19_multianno.edited.txt"
    shell:
        """
        sed 's/Otherinfo1/Zygosity/g' {input.avinput} | sed 's/Otherinfo2/QUAL/g' | sed 's/Otherinfo3/DP/g' > {output.avoutput}
        """
