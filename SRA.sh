#!/usr/bin/env bash
#
#SBATCH -J download_sra
#SBATCH -c 6
#SBATCH -N 1
#SBATCH -t 12:00:00
#SBATCH --mem 20G
#SBATCH -o /scratch/cqh6wn/Iso_new/fasta/logs/sra.%A_%a.out
#SBATCH -e /scratch/cqh6wn/Iso_new/fasta/logs/sra.%A_%a.err
#SBATCH -p standard
#SBATCH --account=berglandlab
#SBATCH --array=1-365

module load sratoolkit/3.1.1

META="isofemale_metadata.cleaned.csv"
OUT="fastq_files"

mkdir -p ${OUT}

# get SRR (skip header)
srr=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" ${META} | cut -d',' -f2)

echo "Downloading ${srr}"

fasterq-dump ${srr} --outdir ${OUT}

gzip ${OUT}/${srr}*.fastq
