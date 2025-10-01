#!/bin/bash -l

# Script to set up Nextflow and a conda environment for running the WGS and MitoEdit Nextflow pipelines on
# Virtual Machine instances

# Download Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-py310_25.7.0-2-Linux-x86_64.sh
# Install Miniconda with bash set to auto accept/yes
bash Miniconda3-py310_25.7.0-2-Linux-x86_64.sh -b -p $HOME/miniconda3

# Cleanup/remove installer
rm -rf Miniconda3-py310_25.7.0-2-Linux-x86_64.sh

# Add channels
conda config --add channels bioconda
conda config --add channels conda-forge

# Accept the Anaconda Terms of Service for channels
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Install mamba and update conda environment
conda install mamba -n base -y
mamba update --all -n base -y

# Make 'bin' directory in home for storing some tools
mkdir -p $HOME/bin

# Download Java 21 and Nextflow for running Nextflow pipelines
wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.8%2B9/OpenJDK21U-jre_x64_linux_hotspot_21.0.8_9.tar.gz
tar -xvf OpenJDK21U-jre_x64_linux_hotspot_21.0.8_9.tar.gz
mv jdk-21.0.8+9-jre/ bin/
rm -rf OpenJDK21U-jre_x64_linux_hotspot_21.0.8_9.tar.gz

# Set JAVA_HOME and PATH for Java 21
export JAVA_HOME=${HOME}/bin/jdk-21.0.8+9-jre
export PATH="$JAVA_HOME/bin:$PATH"

# Now get Nextflow
wget -qO- https://github.com/nextflow-io/nextflow/releases/download/v25.04.7/nextflow | bash
mv nextflow ${HOME}/bin/
chmod +x ${HOME}/bin/nextflow

# Now put bin on PATH
export PATH="${HOME}/bin:$PATH"

# # Install nextflow and python 3.10 in base environment
# mamba install -n base -y python=3.10 nextflow

# Create environment with dependencies for WGS pipeline
# samtools/1.12, bwa/0.7.17, annovar/20200607, python/3.11.0, bambino-1.0.jar
mamba create -n wgs -y python=3.10 samtools=1.12 bwa=0.7.17

# Get and 'install' annovar for WGS
wget http://www.openbioinformatics.org/annovar/download/0wgxR2rIVP/annovar.latest.tar.gz
tar -xvf annovar.latest.tar.gz annovar
mv annovar ${HOME}/bin/
rm -rf annovar.latest.tar.gz

# Get and 'install' bambino for WGS
wget http://ftp.stjude.org/pub/software/conserting/bambino-1.0.jar # Might want to change this to stable site
mv bambino-1.0.jar ${HOME}/bin/

# # Alternatively can be obtained from github in 'bambino_jars.tar' tar archive
# git clone https://github.com/NCIP/cgr-bambino.git

# Install mitoedit in its own conda environment
mamba create -n mte python=3.10 pip biopython -y
conda deactivate && conda activate mte
# mkdir -p mte && cd mte
# git clone https://github.com/xz-stjude/mitoedit.git
# cd mitoedit
# pip install .
# cd ${HOME}
pip install mitoedit
conda deactivate && conda activate base

# # Get mitochondrial reference
# mamba install -n base -y entrez-direct
# esearch -db nucleotide -query "NC_012920.1" | efetch -format fasta > NC_012920.1.fasta

# Create empty file for bystander input
touch NOFILE

## Example input file for testing mitoedit pipeline
ln -s /home/dlevings/Mito_WGS_MTE_Nextflow/Run_Result/VM_Run_MT_VariantCall_HG008_Downsample_Tests/Annotate_MTDB_Parse_FinalizeTable/all.maf.fisher_annotated_gMafOrtMaf_greaterThanOrEqual0.03_withNewGroups_allColumns.txt HG008_WGS_output.txt

# Supply test input parameters and run mitoedit Nextflow pipeline
INPUT_MTE_SEQ="NC_012920.1.txt"
INPUT_TAB="/home/dlevings/mte/HG008_WGS_output.txt"
# INPUT_TAB="HG008_WGS_output.txt"
# INPUT_TAB="test_WGS_output.txt"
OUTPUT_MTE_PRE="HG008_test_output"
# BYSTANDER_INPUT=NO_FILE

# Run Nextflow mitoedit pipeline - don't include bystander edits file for now
nextflow run mitoedit.nf --mtdna_seq_path ${INPUT_MTE_SEQ} \
    --input_tab ${INPUT_TAB} --output_prefix ${OUTPUT_MTE_PRE} # --bystander_file ${BYSTANDER_INPUT}

# Create conda environment from file
