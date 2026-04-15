#!/bin/bash

# Source config script
source arguments_param
source config.parameters

# Step 1: Rename and count file
# -- Copy raw data files from sourcedir to rawdir.
# CORE PARAMETERS: sourcedir, rawdir
# INPUT: manifest
# WORK: rawdir
# OUTPUT: 
# PROCESS - File transfer
sbatch -d singleton --error="${log}/1-preprocess_%J.err" --output="${log}/1-preprocess_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/1-preprocess.sh"

samples=$( tail -n +2 ${sourcedir}/${manifest} | cut -f1 )

export samples
export sample_array=($samples)
sample_number=${#sample_array[@]}
sample_number=$(($sample_number - 1))

echo $samples
echo $sample_number

# Check for zero files
if [[ "$sample_number" -eq 0 ]]; then
    echo "Error: No files found in ${manifest}"
    exit 1
fi

# Step 2: QC - fastqc, fastp, fastqc
# -- Run FastQC on raw data to assess data quality before trimming.
# CORE PARAMETERS: modules, rawdir, qcdir, log
# INPUT: rawdir
# WORK: qcdir
# OUTPUT: null
#sbatch -d singleton --error="${log}/2A-rawqc_%J.err" --output="${log}/2A-rawqc_%J.out" --array="0-${sample_number}%20" --job-name=${NAME} --partition=${PART} "${moduledir}/2A-fastqc_array.sh"

#sbatch -d singleton --error="${log}/2B-fastp_%J.err" --output="${log}/2B-fastp_%J.out" --"array=0-${sample_number}%20" --job-name=${NAME} --partition=${PART} "${moduledir}/2B-fastp_array.sh"  

#sbatch -d singleton --error="${log}/2C-trimqc_%J.err" --output="${log}/2C-trimqc_%J.out" --array="0-${sample_number}%20" --job-name=${NAME} --partition=${PART} "${moduledir}/2C-fastqc-trim.sh"

# Step 3: Qiime2 - import, QC
# Input into qiime and run QC.
# CORE PARAMETERS: modules, sourcedir, manifest
# INPUT: sourcedir
# WORK: q2_input, q2_dada2
# OUTPUT: null
sbatch -d singleton --error="${log}/3A_q2input_%J.err" --output="${log}/3A_q2input_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/3A-qiime2-import.sh"

sbatch -d singleton --error="${log}/3B_q2dada2_%J.err" --output="${log}/3B_q2dada2_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/3B-qiime2-dada2.sh"

sbatch -d singleton --error="${log}/3C_q2sum_%J.err" --output="${log}/3C_q2sum_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/3C-qiime2-summary.sh"

# Step 4: Qiime2 - Taxanomic Classification
# Input into qiime and run QC.
# CORE PARAMETERS: modules, sourcedir, smetadata, 
# INPUT: sourcedir, smetadata, asv-seqs.qza, classifier
# WORK: q2_dada2, q2_tax
# OUTPUT: null
sbatch -d singleton --error="${log}/4A_q2tax_%J.err" --output="${log}/4A_q2tax_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/4A-qiime3-tax-annot.sh"

sbatch -d singleton --error="${log}/4B_q2tax_%J.err" --output="${log}/4B_q2tax_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/4B-qiim2-tax-vis.sh"

# Step 5: Qiime2 - trees and metrics
# Input into qiime - generates trees and metrics
# CORE PARAMETERS: modules, sourcedir, smetadata, asv-seqs.qza
# INPUT: sourcedir, smetadata, 
# WORK: q2_input, q2_metric, q2_tax
# OUTPUT: null
sbatch -d singleton --error="${log}/5A_q2metric_%J.err" --output="${log}/5A_q2metric_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/5A-qiim2-metrics.sh"

sbatch -d singleton --error="${log}/5B_q2alpha_%J.err" --output="${log}/5B_q2alpha_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/5B-qiime-alpha.sh"

# Step X: MultiQC report
# -- Generate a MultiQC report to summarize the results of all previous steps.
# CORE PARAMETERS: modules, workdir, multiqc
# INPUT: workdir
# WORK: multiqc
# OUTPUT: multiqc
# PROCESS - multiqc
# sbatch -d singleton --error="${log}/multiqc_%J.err" --output="${log}/multiqc_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/X-multiqc.sh"
