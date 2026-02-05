#!/usr/bin/env bash
#SBATCH -J runDEST
#SBATCH -c 11
#SBATCH -N 1
#SBATCH -t 72:00:00
#SBATCH --mem 90G
#SBATCH -p standard
#SBATCH --account=berglandlab
#SBATCH -o /scratch/cqh6wn/Iso_new/mapping/logs/dest.%A_%a.out
#SBATCH -e /scratch/cqh6wn/Iso_new/mapping/logs/dest.%A_%a.err

module load apptainer

META="/scratch/cqh6wn/Iso_new/fasta/isofemale_metadata.cleaned.csv"
FASTQ="/scratch/cqh6wn/Iso_new/fasta/fastq_files"
OUT="/scratch/cqh6wn/Iso_new/mapping/results"
CONTAINER="/scratch/cqh6wn/containers/DEST.sif"


# Skip header
line=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" ${META})

sample=$(echo "${line}" | cut -d',' -f1)
srr=$(echo "${line}" | cut -d',' -f2)

echo "Sample: ${sample}"
echo "SRR: ${srr}"

R1="${FASTQ}/${srr}_1.fastq.gz"
R2="${FASTQ}/${srr}_2.fastq.gz"

# Safety check
if [[ ! -f "${R1}" || ! -f "${R2}" ]]; then
    echo "Missing FASTQ pair for ${srr}"
    exit 1
fi

singularity run \
    ${CONTAINER} \
    ${R1} \
    ${R2} \
    ${sample} \
    ${OUT} \
    --cores ${SLURM_CPUS_PER_TASK} \
    --num-flies 1 \
    --min-cov 4 \
    --max-cov 0.95 \
    --base-quality-threshold 25 \
    --do_poolsnp

echo "Finished ${sample}"
