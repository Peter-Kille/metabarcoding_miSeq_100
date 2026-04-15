#!/bin/bash
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=16      #
#SBATCH --mem=64000     # in megabytes, unless unit explicitly stated

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

qiime feature-table summarize-plus \
  --i-table "${q2_dada2}/${NAME}_asv-table.qza" \
  --m-metadata-file "${sourcedir}/${smetadata}" \
  --o-summary "${q2_summary}/${NAME}_asv-table.qzv" \
  --o-sample-frequencies "${q2_summary}/${NAME}_sample-frequencies.qza" \
  --o-feature-frequencies "${q2_summary}/${NAME}_asv-frequencies.qza"
