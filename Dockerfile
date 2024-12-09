# Uses Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Sets non-interactive mode to prevent prompts during installation
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

# Updates and installs system dependencies
RUN apt-get update && apt-get install -y \
    apt-utils \
    ca-certificates \
    iputils-ping \
    perl \
    libperl-dev \
    python3 \
    python3-pip \
    python3-venv \
    wget \
    curl \
    unzip \
    tar \
    bzip2 \
    build-essential \
    libffi-dev \
    libssl-dev \
    nano \
    vim \
    gcc \
    make \
    && apt-get clean

# Installs Python 3 libraries for Flask, Pandas, Gunicorn, and JSON
## PS: LIB 'json' already comes installed
RUN pip3 install flask pandas gunicorn snakemake

# Installs Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh

# Adds Conda to PATH
ENV PATH="/opt/conda/bin:$PATH"

# Creates a Conda environment for Snakemake
## PS: inside the Docker image, run 'conda init'; source again the .bashrc, and finally run 'conda activate snakemake_env'
RUN conda create -y -n snakemake_env -c conda-forge -c bioconda snakemake

# Sets Conda ENV as default
SHELL ["conda", "run", "-n", "snakemake_env", "/bin/bash", "-c"]

# Installs Python libraries for Flask, Pandas, Gunicorn, and JSON in the CONDA ENV
## PS: again, the LIB 'json' already comes installed
RUN pip install flask pandas gunicorn

# Sets working directory in the container
WORKDIR /app

# Copies all files and directories from the current working directory to the container
## PS: Except files discriminated in the .dockerignore file --> avoid adding to the Docker image the big dbSNP and gnomAD database files (download them later in Snakefile rule)
COPY . /app

# Set environment variable to include ANNOVAR in the PATH
ENV PATH="/annovar:$PATH"

# Exposes port 5000 for the Flask API
EXPOSE 5000

# Sets default command to run the Flask API using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
