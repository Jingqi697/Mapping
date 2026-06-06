#!/usr/bin/env bash
#SBATCH -J runDEST
#SBATCH -c 11
#SBATCH -N 1
#SBATCH -t 72:00:00
#SBATCH --mem=90G
#SBATCH -p standard
#SBATCH --account=berglandlab
#SBATCH --array=1-268
#SBATCH -o /scratch/cqh6wn/Isofemale/Global/mapping/logs/dest.%A_%a.out
#SBATCH -e /scratch/cqh6wn/Isofemale/Global/mapping/logs/dest.%A_%a.err

module load apptainer

META="/scratch/cqh6wn/Isofemale/Global/fasta/isofemale_metadata.cleaned.csv"
FASTQ="/scratch/cqh6wn/Isofemale/Global/fasta/fastq_files"
OUT="/scratch/cqh6wn/Isofemale/Global/mapping/results"
CONTAINER="/standard/BerglandTeach/dest_freeze2.6.1_latest.sif"

mkdir -p "${OUT}"

# Skip header and get the corresponding sample
line=$(tail -n +2 "${META}" | sed -n "${SLURM_ARRAY_TASK_ID}p")

if [[ -z "${line}" ]]; then
    echo "No sample for task ${SLURM_ARRAY_TASK_ID}"
    exit 0
fi

sample=$(echo "${line}" | cut -d',' -f1)
srr=$(echo "${line}" | cut -d',' -f2)

echo "Task: ${SLURM_ARRAY_TASK_ID}"
echo "Sample: ${sample}"
echo "SRR: ${srr}"

R1="${FASTQ}/${srr}_1.fastq.gz"
R2="${FASTQ}/${srr}_2.fastq.gz"

# Skip samples that were never downloaded
if [[ ! -f "${R1}" || ! -f "${R2}" ]]; then
    echo "FASTQ missing for ${srr}; skipping"
    exit 0
fi

apptainer run \
    "${CONTAINER}" \
    "${R1}" \
    "${R2}" \
    "${sample}" \
    "${OUT}" \
    --cores "${SLURM_CPUS_PER_TASK}" \
    --num-flies 1 \
    --min-cov 4 \
    --max-cov 0.95 \
    --base-quality-threshold 25 \
    --do_poolsnp

echo "Finished ${sample}"
