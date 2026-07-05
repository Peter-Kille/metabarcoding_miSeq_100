#!/bin/bash
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=32      #
#SBATCH --mem=128000     # in megabytes, unless unit explicitly stated

echo "Some Usable Environment Variables:"
echo "================================="
echo "hostname=$(hostname)"
echo \$SLURM_JOB_ID=${SLURM_JOB_ID}
echo \$SLURM_NTASKS=${SLURM_NTASKS}
echo \$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}
echo \$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
echo \$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}
echo \$SLURM_MEM_PER_CPU=${SLURM_MEM_PER_CPU}

# Write jobscript to output file (good for reproducibility)
cat $0

# Load some modules
module load ${q2_module}

qiime dada2 denoise-single \
        --i-demultiplexed-seqs "${q2_input}/${NAME}_demux.qza" \
        --p-trunc-len 0 \
        --p-n-threads ${SLURM_CPUS_PER_TASK} \
        --o-representative-sequences "${q2_dada2}/${NAME}_asv-seqs.qza" \
        --o-table "${q2_dada2}/${NAME}_asv-table.qza" \
        --o-denoising-stats "${q2_dada2}/${NAME}_stats.qza"

qiime metadata tabulate \
        --m-input-file "${q2_dada2}/${NAME}_stats.qza" \
        --o-visualization "${q2_dada2}/${NAME}_stats.qzv"

# comment ASV_feature-table output uses sample nsmes as column headers - to swap these for those given in metadata file see R script in scripts folder

qiime tools export \
	--input-path "${q2_dada2}/${NAME}_asv-table.qza" \
	--output-path "${q2_dada2}"

mv "${q2_dada2}/feature-table.biom" "${q2_dada2}/${NAME}_feature-table.biom"

biom convert -i "${q2_dada2}/${NAME}_feature-table.biom" \
	-o "${q2_dada2}/${NAME}_feature-table.tsv" \
	--to-tsv
