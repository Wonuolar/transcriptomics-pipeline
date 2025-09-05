# Transcriptomics Pipeline (RNA-seq Workflow for *M. tuberculosis*)

**Automated end-to-end RNA-seq pipeline for identifying differentially expressed genes in *Mycobacterium tuberculosis* transcriptomes using Linux-based tools and R/Bioconductor.**

---

## 🔬 Project Overview

This project aims to automate the processing and analysis of 21,000+ RNA-seq datasets from NCBI-SRA to study *M. tuberculosis* transcriptional responses linked to virulence, drug resistance, and metabolic adaptation.

The analysis involves a scalable, reproducible workflow integrating preprocessing, alignment, quantification, differential expression, and exploratory data analysis.

> ⚠️ **Disclaimer:** This repository includes only the computational pipeline and workflow components. **No raw data, processed data, or results are shared**, as this project is part of an ongoing publication under the supervision of Dr. Brittany Ross (Georgia State University).

---

## 🛠️ Tools & Technologies

- **Preprocessing:** FastQC, Cutadapt  
- **Alignment:** Bowtie2 (to H37Rv reference genome)  
- **Quantification:** featureCounts  
- **Differential Expression:** DESeq2, edgeR (R/Bioconductor)  
- **Visualization:** PCA, Heatmaps (R)  
- **Machine Learning:** Unsupervised clustering (PCA)  
- **Automation:** Bash scripting, Snakemake (planned), Docker (planned)  
- **Platform:** Linux, ARTIC cloud environment  

---

## ⚙️ Pipeline Workflow

1. Download FASTQ files using SRA Toolkit  
2. Trim adapters and perform quality control (Cutadapt + MultiQC)  
3. Align reads to H37Rv reference genome and filter out host/decoy contamination  
4. Convert SAM to BAM and sort using Samtools  
5. Generate gene counts using `featureCounts`  
6. Perform differential expression analysis in R with DESeq2  
7. Visualize PCA and clustered heatmaps  

---

transcriptomics-pipeline/
├── README.md
├── LICENSE
├── .gitignore
│
├── pipeline/
│ ├── 00_env_setup.txt
│ ├── 01_trim_and_qc.sh
│ ├── 02_bowtie_mapping.sh
│ ├── 03_samtools_sort.sh
│ ├── 04_featurecounts.sh
│ └── job_slurm_header.sh
│
├── workflow/
│ ├── workflow_diagram.png
│ └── workflow_summary.md
│
├── results/
│ └── placeholder.txt
│
└── logs/
└── README_logs.md


> 🧠 All scripts are modular and designed for HPC environments using SLURM. Raw data and analysis results are excluded in compliance with project confidentiality and future publication plans.

## 👩🏽‍💻 Author

**Omowonuola Faith Olarinde**  
M.S. Biology Candidate, Georgia State University  
📫 wonuolafaith@gmail.com


## 📁 Repository Structure
#!/bin/bash
# Title: Bowtie2 Mapping and Host/Decoy Decontamination Pipeline
# Produced by: Dr. Brittany Ross & Faith Olarinde
# Maintainer: Omowonuola Faith Olarinde
# Note: This script is part of a transcriptomic analysis project for publication.
#       It has been adapted for reproducibility and SLURM execution.

# TB RNA-seq Processing Pipeline

A reproducible **RNA-seq preprocessing and analysis pipeline** for *Mycobacterium tuberculosis* (H37Rv).  
The pipeline trims adapters, removes host/decoy contamination, maps reads to the Mtb genome, and generates read count tables for downstream differential expression analysis.

---

## Features
- **Adapter trimming** with [Cutadapt](https://cutadapt.readthedocs.io/)
- **Host read removal** (human + mouse) with [Bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/)
- **Decoy bacterial read removal** with Bowtie2
- **Mtb H37Rv alignment** with Bowtie2
- **SAM → BAM conversion and sorting** with [Samtools](http://www.htslib.org/)
- **Gene-level quantification** with [featureCounts](http://subread.sourceforge.net/)
- **Quality reports** aggregated with [MultiQC](https://multiqc.info/)

---

## Requirements
- Conda environment with:
  - `cutadapt`
  - `bowtie2`
  - `samtools`
  - `subread` (for featureCounts)
  - `multiqc`

You can create an environment with:

```bash
conda create -n tb_rnaseq cutadapt bowtie2 samtools subread multiqc -c bioconda -c conda-forge



