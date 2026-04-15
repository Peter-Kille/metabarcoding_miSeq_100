#!/bin/bash
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=8      #   
#SBATCH --mem-per-cpu=4000     # in megabytes, unless unit explicitly stated

echo "Some Usable Environment Variables:"
echo "================================="
echo "hostname=$(hostname)"
echo "\$SLURM_JOB_ID=${SLURM_JOB_ID}"
echo "\$SLURM_NTASKS=${SLURM_NTASKS}"
echo "\$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}"
echo "\$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}"
echo "\$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}"
echo "\$SLURM_MEM_PER_CPU=${SLURM_MEM_PER_CPU}"

# Write jobscript to output file (good for reproducibility)
cat $0

module load ${cutadapt_module}

sample_array=($samples)
base=${sample_array[$SLURM_ARRAY_TASK_ID]}

cutadapt --cores ${SLURM_CPUS_PER_TASK} \
	-g ^GTGCCAGCMGCCGCGGTAA \
	-a GGACTACHVGGGTWTCTAAT$ \
	-e 0.1 \
	-q 30 \
	--minimum-length 240 \
	--maximum-length 300 \
	--discard-untrimmed \
	-o "${cutdir}/${base}_merge_cut.fastq.gz" \
	"${trimdir}/${base}_merge.fastq.gz"
