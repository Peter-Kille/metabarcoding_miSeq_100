module load seqtk

cutdir=$(pwd)

rp="GTGCCAGCMGCCGCGGTAA"

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

echo ${rcrp}

