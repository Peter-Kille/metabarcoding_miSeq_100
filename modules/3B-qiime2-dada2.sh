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

qiime dada2 denoise-paired \
  --i-demultiplexed-seqs "${q2_input}/${NAME}_demux.qza" \
  --p-trim-left-f 20 \
  --p-trunc-len-f 250 \
  --p-trim-left-r 20 \
  --p-trunc-len-r 250 \
  --p-n-threads ${SLURM_CPUS_PER_TASK} \
  --p-min-overlap 8 \
  --o-representative-sequences "${q2_dada2}/${NAME}_asv-seqs.qza" \
  --o-table "${q2_dada2}/${NAME}_asv-table.qza" \
  --o-denoising-stats "${q2_dada2}/${NAME}_stats.qza"

qiime metadata tabulate \
  --m-input-file "${q2_dada2}/${NAME}_stats.qza" \
  --o-visualization "${q2_dada2}/${NAME}_stats.qzv"
