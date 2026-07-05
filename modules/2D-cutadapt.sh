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
module load ${seqtk_module}

if [ -f "${cutdir}/rp.fasta" ] ; then
    rm "${cutdir}/rp.fasta"
fi

touch "${cutdir}/rp.fasta"

if [ -f "${cutdir}/rcrp.fasta" ] ; then
    rm "${cutdir}/rcrp.fasta"
fi

printf ">reverse_primer\n" > "${cutdir}/rp.fasta"
printf "${rp}" >> "${cutdir}/rp.fasta"

seqtk seq -r "${cutdir}/rp.fasta" > "${cutdir}/rcrp.fasta"

sed -i 's/reverse_primer/reverse_complement_rp/g' "${cutdir}/rcrp.fasta"

rcrp=$(grep -A1 ">" "${cutdir}/rcrp.fasta" | grep -v ">")

sample_array=($samples)
base=${sample_array[$SLURM_ARRAY_TASK_ID]}

cutadapt --cores ${SLURM_CPUS_PER_TASK} \
	-g ^"${fp}" \
	-a "${rcrp}"$ \
	-e 0.1 \
	-q 30 \
	--minimum-length 240 \
	--maximum-length 300 \
	--discard-untrimmed \
	-o "${cutdir}/${base}_merge_cut.fastq.gz" \
	"${trimdir}/${base}_merge.fastq.gz"
