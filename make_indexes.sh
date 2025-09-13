#!/bin/bash
# Build Bowtie2 indexes ONE TIME for the pipeline.
# This script matches run_tb_pipeline.sh (same REF_DIR and index names).

REF_DIR="$HOME/TB_main/ref_genome"
mkdir -p "$REF_DIR"

echo "[INFO] Expected files in $REF_DIR:"
echo "  - GCF_000195955.2_ASM19595v2_genomic.fna        (Mtb FASTA)"
echo "  - GCF_000195955.2_ASM19595v2_genomic.gff (.gz)  (Mtb GFF; optional unzip)"
echo "  - human.fna                                      (Human FASTA)"
echo "  - mouse.fna                                      (Mouse FASTA)"
echo "  - decoy_EA.fna                                   (Decoy FASTA)"

# 1) Mtb H37Rv index
bowtie2-build "$REF_DIR/GCF_000195955.2_ASM19595v2_genomic.fna" "$REF_DIR/MtbH37Rv"

# 2) Host (Human+Mouse) index
cat "$REF_DIR/human.fna" "$REF_DIR/mouse.fna" > "$REF_DIR/humanmouse.fna"
bowtie2-build "$REF_DIR/humanmouse.fna" "$REF_DIR/MouseHuman"

# 3) Decoy bacterial index
bowtie2-build "$REF_DIR/decoy_EA.fna" "$REF_DIR/decoy_EA"

# unzip GFF if only .gz exists (pipeline can also handle this)
if [ ! -f "$REF_DIR/GCF_000195955.2_ASM19595v2_genomic.gff" ] && [ -f "$REF_DIR/GCF_000195955.2_ASM19595v2_genomic.gff.gz" ]; then
  gunzip -k "$REF_DIR/GCF_000195955.2_ASM19595v2_genomic.gff.gz"
fi

echo "[DONE] Index build complete."
echo "You should now see:"
echo "  $REF_DIR/MouseHuman.*bt2*"
echo "  $REF_DIR/decoy_EA.*bt2*"
echo "  $REF_DIR/MtbH37Rv.*bt2*"

