#!/bin/bash

# -------------------------
# Batch Processing Pipeline for TB RNA-seq Data
# Author: Your Name
# Updated: 09/03/2025
#
# Description:
#   RNA-seq single-end pipeline for Mycobacterium tuberculosis:
#     1. Adapter trimming (Cutadapt)
#     2. Host (human/mouse) read removal (Bowtie2)
#     3. Decoy bacterial read removal (Bowtie2)
#     4. Mapping to Mtb H37Rv reference genome (Bowtie2)
#     5. SAM → sorted BAM conversion (Samtools)
#     6. Gene-level read counting (featureCounts)
#     7. MultiQC reports for QC summary
#
# Requirements:
#   conda env with: cutadapt, bowtie2, samtools, subread (featureCounts), multiqc
#
# Example SLURM submission:
#   sbatch --cpus-per-task=8 --mem=32G run_tb_pipeline.sh
#
# Inputs:
#   *.fastq.gz files in current directory
# Outputs:
#   *_MtbH37Rv_sorted.bam, featureCounts.txt, MultiQC reports
# -------------------------

# ---- CONFIG ----
THREADS=8                          # cores for bowtie2/samtools/featureCounts
REF_DIR=$HOME/TB_main/ref_genome   # path to reference genome folder
GFF_FILE=${REF_DIR}/GCF_000195955.2_ASM19595v2_genomic.gff
PER_SAMPLE=false                   # set to true to output per-sample count tables

echo "Starting batch processing pipeline..."

# ---- Conda environment ----
echo "Activating Conda environment..."
source ~/.bashrc
conda activate /userapp/condaenv/mapping

# ---- Step 1: Trimming ----
echo "Trimming adapters with Cutadapt..."
for file in *.fastq.gz
  do
    base=$(basename "$file" .fastq.gz)
    echo "  Trimming $base..."
    cutadapt --cores $THREADS -m 22 -o ${base}.22bptrim.fastq.gz "$file" > ${base}_cutadapt.log
  done

# ---- Step 2: Mapping ----
for file in *.22bptrim.fastq.gz
  do
    base=$(basename "$file" .22bptrim.fastq.gz)

    echo "  Mapping $base to Mouse/Human genome..."
    bowtie2 --end-to-end -p $THREADS -x ${REF_DIR}/MouseHuman -q -U "$file" \
        --un ${base}_nohuman.fastq 2> ${base}_toHuman.log

    echo "  Mapping $base to Decoy bacterial genome..."
    bowtie2 --end-to-end --very-sensitive -p $THREADS -x ${REF_DIR}/decoy_EA -q -U ${base}_nohuman.fastq \
        --un ${base}_nohuman_nodecoy.fastq 2> ${base}_toDecoy.log

    echo "  Mapping $base to Mtb H37Rv genome..."
    bowtie2 --end-to-end --very-sensitive -p $THREADS -x ${REF_DIR}/MtbH37Rv -q -U ${base}_nohuman_nodecoy.fastq \
        -S ${base}_MtbH37Rv.sam 2> ${base}_toMtb.log
  done

# ---- Step 3: Convert SAM → sorted BAM ----
echo "Converting SAM to sorted BAM..."
for sam in *_MtbH37Rv.sam
  do
    base=$(basename "$sam" _MtbH37Rv.sam)
    echo "  Sorting $base..."
    samtools view -@ $THREADS -bS "$sam" | samtools sort -@ $THREADS -o ${base}_MtbH37Rv_sorted.bam -
  done

# ---- Step 4: Count reads ----
if [ ! -f "$GFF_FILE" ] && [ -f "${GFF_FILE}.gz" ]; then
    echo "Unzipping GFF annotation..."
    gunzip -k "${GFF_FILE}.gz"
fi

echo "Counting reads with featureCounts..."
featureCounts \
    -T $THREADS \
    -a "${GFF_FILE}" \
    -g locus_tag \
    -t gene \
    -o featureCounts.txt ./*_MtbH37Rv_sorted.bam

if [ "$PER_SAMPLE" = true ]; then
  echo "Generating per-sample featureCounts tables..."
  for b in *_MtbH37Rv_sorted.bam
    do
      base=$(basename "$b" _MtbH37Rv_sorted.bam)
      featureCounts \
        -T $THREADS \
        -a "${GFF_FILE}" \
        -g locus_tag \
        -t gene \
        -o FEATURECOUNTS_${base}.txt "$b"
    done
fi

echo "Summarizing featureCounts outputs..."
./count_features.sh

# ---- Step 5: Cleanup ----
rm *_nohuman.fastq *_nohuman_nodecoy.fastq *.sam
echo "Intermediate files deleted."

# ---- Step 6: MultiQC ----
conda activate /userapp/condaenv/Ross_multiqc

echo "Generating MultiQC report for trimming..."
mkdir -p multiqc_reports/cutadapt
multiqc *_cutadapt.log -o multiqc_reports/cutadapt

echo "Generating MultiQC reports for mapping logs..."
mkdir -p multiqc_reports/toHuman
multiqc *_toHuman.log -o multiqc_reports/toHuman

mkdir -p multiqc_reports/toDecoy
multiqc *_toDecoy.log -o multiqc_reports/toDecoy

mkdir -p multiqc_reports/toMtb
multiqc *_toMtb.log -o multiqc_reports/toMtb

echo "Pipeline completed successfully."
