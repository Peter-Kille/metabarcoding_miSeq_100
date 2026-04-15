#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=100
#SBATCH --time=10:00:00

echo "Some Usable Environment Variables:"
echo "================================="
echo "hostname=$(hostname)"
echo "\$SLURM_JOB_ID=${SLURM_JOB_ID}"
echo "\$SLURM_NTASKS=${SLURM_NTASKS}"
echo "\$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}"
echo "\$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}"
echo "\$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}"
echo "\$SLURM_MEM_PER_CPU=${SLURM_MEM_PER_CPU}"

# read in sample and read names and move and rename samples into workdir
touch ${sourcedir}/working_manifest.csv

printf "sample-id\tabsolute-filepath\n" >> ${sourcedir}/working_manifest.tsv

tail -n +2 ${sourcedir}/"${manifest}" | while IFS=$',' read -r sample file; do

printf "${sample}\t${cutdir}/${file}_merge_cut.fastq.gz\n" >> ${sourcedir}/working_manifest.tsv

cp ${sourcedir}/${file}_R1.fastq.gz ${rawdir}/${file}_1.fastq.gz
cp ${sourcedir}/${file}_R2.fastq.gz ${rawdir}/${file}_2.fastq.gz

done
