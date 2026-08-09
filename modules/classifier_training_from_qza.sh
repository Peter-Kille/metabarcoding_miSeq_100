#!/bin/bash
#SBATCH --partition=epyc       # the requested queue
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=16      #   
#SBATCH --mem-per-cpu=2000     # in megabytes, unless unit explicitly stated
#SBATCH --error=%J.err         # redirect stderr to this file
#SBATCH --output=%J.out        # redirect stdout to this file
##SBATCH --mail-user=[insert email address]@Cardiff.ac.uk  # email address used for event notification
##SBATCH --mail-type=end                                   # email on job end
##SBATCH --mail-type=fail                                  # email on job failure

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

module load QIIME2/2026.4-rachis-conda

workdir=$(pwd)

classifierseqs="silva-138-99-seqs-515-806.qza"
classifiertax="silva-138-99-tax-515-806.qza"

classifier="16S"

qiime feature-classifier extract-reads \
  --i-sequences ${workdir}/${classifierseqs} \
  --p-f-primer GTGCCAGCMGCCGCGGTAA \
  --p-r-primer GGACTACHVGGGTWTCTAAT \
  --p-trunc-len 120 \
  --p-min-length 100 \
  --p-max-length 500 \
  --p-n-jobs ${SLURM_CPUS_PER_TASK} \
  --o-reads ${workdir}/${classifier}-ref-seqs.qza

qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads ${workdir}/${classifier}-ref-seqs.qza \
  --i-reference-taxonomy ${workdir}/${classifiertax} \
  --o-classifier ${workdir}/${classifier}-classifier.qza

