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

qiime diversity alpha-group-significance \
  --i-alpha-diversity "${q2_metric}/core-metrics-results/faith_pd_vector.qza" \
  --m-metadata-file "${sourcedir}/${smetadata}" \
  --o-visualization "${q2_metric}/core-metrics-results/faith-pd-group-significance.qzv"

qiime diversity alpha-group-significance \
  --i-alpha-diversity "${q2_metric}/core-metrics-results/evenness_vector.qza" \
  --m-metadata-file "${sourcedir}/${smetadata}" \
  --o-visualization "${q2_metric}/core-metrics-results/evenness-group-significance.qzv"

qiime diversity alpha-rarefaction \
  --i-table "${q2_dada2}/${NAME}_asv-table.qza" \
  --i-phylogeny "${q2_metric}/${NAME}_rooted-tree.qza" \
  --p-max-depth 4000 \
  --m-metadata-file "${sourcedir}/${smetadata}" \
  --o-visualization "${q2_metric}/${NAME}_4000_alpha-rarefaction.qzv"


qiime diversity alpha-rarefaction \
  --i-table "${q2_dada2}/${NAME}_asv-table.qza" \
  --i-phylogeny "${q2_metric}/${NAME}_rooted-tree.qza" \
  --p-max-depth 20000 \
  --m-metadata-file "${sourcedir}/${smetadata}" \
  --o-visualization "${q2_metric}/${NAME}_20000_alpha-rarefaction.qzv"

