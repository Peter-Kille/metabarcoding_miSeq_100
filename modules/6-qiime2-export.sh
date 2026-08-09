#!/bin/bash
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=8      #
#SBATCH --mem=11111111111111116000     # in megabytes, unless unit explicitly stated

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

### Export dada2 outputs ###########

qiime tools export \
        --input-path "${q2_dada2}/${NAME}_asv-seqs.qza" \
        --output-path "${q2_extracted}"

mv "${q2_extracted}/dna-sequences.fasta" "${q2_extracted}/${NAME}_asv-sequences.fasta" 

# Export feature table
qiime tools export \
        --input-path "${q2_dada2}/${NAME}_asv-table.qza" \
        --output-path "${q2_extracted}"

mv "${q2_extracted}/feature-table.biom" "${q2_extracted}/${NAME}_feature-table.biom"

biom convert \
        -i "${q2_extracted}/${NAME}_feature-table.biom" \
        -o "${q2_extracted}/${NAME}_feature-table.tsv" --to-tsv

#### Export Taxonomic assignemnts

# Export taxonomy
qiime tools export \
        --input-path "${q2_tax}/${NAME}-taxonomy.qza" \
        --output-path "${q2_extracted}"

mv "${q2_extracted}/taxonomy.tsv" "${q2_extracted}/${NAME}_taxonomy.tsv" 

##### Export Phylogenetic trees

# Export rooted tree and alignments
qiime tools export \
        --input-path "${q2_metric}/${NAME}_rooted-tree.qza" \
        --output-path "${q2_extracted}"

mv "${q2_extracted}/tree.nwk" "${q2_extracted}/${NAME}_rooted-tree.nwk"

# Export the represented sequences
qiime tools export \
  --input-path "${q2_metric}/${NAME}_masked-aligned-rep-seqs.qza" \
  --output-path "${q2_extracted}"

mv "${q2_extracted}/aligned-dna-sequences.fasta" "${q2_extracted}/${NAME}_aligned-dna-sequences.fasta"
