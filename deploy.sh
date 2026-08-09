#!/bin/bash

# Source config script
source config/arguments
source config/folders
source config/programs

# Step 1: Rename and count file

sbatch -d singleton --error="${log}/1-preprocess_%J.err" --output="${log}/1-preprocess_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/1-preprocess.sh"

samples=$( tail -n +2 ${sourcedir}/${manifest} | cut -f1,1 )

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

#Step 2: QC - fastqc, fastp, fastqc
# -- Run FastQC on raw data to assess data quality before trimming.

sbatch -d singleton --error="${log}/2A-rawqc_%J.err" --output="${log}/2A-rawqc_%J.out" --array="0-${sample_number}%20" --job-name=${NAME} --partition=${PART} "${moduledir}/2A-fastqc_array.sh"

sbatch -d singleton --error="${log}/2B-fastp_%J.err" --output="${log}/2B-fastp_%J.out" --"array=0-${sample_number}%20" --job-name=${NAME} --partition=${PART} "${moduledir}/2B-fastp_array.sh"  

sbatch -d singleton --error="${log}/2C-trimqc_%J.err" --output="${log}/2C-trimqc_%J.out" --array="0-${sample_number}%20" --job-name=${NAME} --partition=${PART} "${moduledir}/2C-fastqc-trim.sh"

sbatch -d singleton --error="${log}/2D-rc_%J.err" --output="${log}/2D-rc_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/2D-rc-primer.sh"

sbatch -d singleton --error="${log}/2E-cut_%J.err" --output="${log}/2E-cut_%J.out" --array="0-${sample_number}%20" --job-name=${NAME} --partition=${PART} "${moduledir}/2E-cutadapt.sh"

# Step 3: Qiime2 - import, QC
# Input into qiime and run QC.

sbatch -d singleton --error="${log}/3A_q2input_%J.err" --output="${log}/3A_q2input_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/3A-qiime2-import.sh"

sbatch -d singleton --error="${log}/3B_q2dada2_%J.err" --output="${log}/3B_q2dada2_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/3B-qiime2-dada2.sh"

sbatch -d singleton --error="${log}/3C_q2sum_%J.err" --output="${log}/3C_q2sum_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/3C-qiime2-summary.sh"

# Step 4: Qiime2 - Taxanomic Classification

sbatch -d singleton --error="${log}/4A_q2tax_%J.err" --output="${log}/4A_q2tax_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/4A-qiime3-tax-annot.sh"

sbatch -d singleton --error="${log}/4B_q2tax_%J.err" --output="${log}/4B_q2tax_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/4B-qiim2-tax-vis.sh"

# Step 5: Qiime2 - trees and metrics
# Input into qiime - generates trees and metrics

sbatch -d singleton --error="${log}/5A_q2metric_%J.err" --output="${log}/5A_q2metric_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/5A-qiim2-metrics.sh"

sbatch -d singleton --error="${log}/5B_q2alpha_%J.err" --output="${log}/5B_q2alpha_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/5B-qiime-alpha.sh"

# Step 6: Qiime2 - trees and metrics

sbatch -d singleton --error="${log}/6_export_%J.err" --output="${log}/6_export_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/6-qiime2-export.sh"

# Step X: MultiQC report
# -- Generate a MultiQC report to summarize the results of all previous steps.

sbatch -d singleton --error="${log}/multiqc_%J.err" --output="${log}/multiqc_%J.out" --job-name=${NAME} --partition=${PART} "${moduledir}/X-multiqc.sh"
