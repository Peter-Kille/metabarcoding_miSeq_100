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

module load qiime2/2024.10-conda

workdir=$(pwd)
sequences="MIDORI2_LONGEST_NUC_GB265_CO1_QIIME.fasta"
taxonomy="MIDORI2_LONGEST_NUC_GB265_CO1_QIIME.taxon"
classifier="COI"


qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path ${workdir}/${sequences} \
  --output-path ${workdir}/${classifier}-seqs.qza

qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path ${workdir}/${taxonomy} \
  --output-path ${workdir}/${classifier}-taxonomy.qza

qiime feature-classifier extract-reads \
  --i-sequences ${workdir}/${classifier}-seqs.qza \
  --p-f-primer CCHGAYATRGCHTTYCCHCG \
  --p-r-primer TCDGGRTGNCCRAARAAYCA \
  --p-trunc-len 120 \
  --p-min-length 100 \
  --p-max-length 500 \
  --p-n-jobs ${SLURM_CPUS_PER_TASK} \
  --o-reads ${workdir}/${classifier}-ref-seqs.qza

qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads ${workdir}/${classifier}-ref-seqs.qza \
  --i-reference-taxonomy ${workdir}/${classifier}-taxonomy.qza \
  --o-classifier ${workdir}/${classifier}-classifier.qza


