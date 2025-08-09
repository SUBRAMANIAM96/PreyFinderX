#!/bin/bash

# === USER SETTINGS ===
EMAIL="subramanyamvkumar@gmail.com"
API_KEY="69a683170ef86eca94f873cdf18c94ffbd09"
SLEEP_TIME=30         # Time delay between BLASTs
OTUS_PER_BATCH=8      # OTUs per batch for BLAST

# === INPUT FASTA FROM CORE SCRIPT ===
FASTA_FILE="$1"
tag="$2"
prefix="$3"  # not used in this script directly
OUTPUT_DIR="Results/${tag}/blast"
OUTPUT_FILE="${OUTPUT_DIR}/blast_results_all.txt"

# === CREATE OUTPUT DIRECTORY ===
mkdir -p "$OUTPUT_DIR"

# === CHECK INPUT FILE EXISTS ===
if [[ ! -f "$FASTA_FILE" ]]; then
    echo "Error: OTU FASTA file '$FASTA_FILE' not found."
    exit 1
fi

# === CHECK IF SEQKIT IS INSTALLED ===
if ! command -v seqkit &> /dev/null; then
    echo "Error: seqkit not found. Please install seqkit."
    exit 1
fi

# === SET NCBI ENVIRONMENT VARIABLES ===
export ENTREZ_EMAIL="$EMAIL"
export NCBI_API_KEY="$API_KEY"

# === SPLIT INPUT FASTA INTO OTU BATCHES ===
echo "[BLAST] Splitting OTUs in $FASTA_FILE ..."
seqkit split -s "$OTUS_PER_BATCH" "$FASTA_FILE" -O "$OUTPUT_DIR" -o "otu_${tag}.part_"

# === RUN REMOTE BLAST ===
> "$OUTPUT_FILE"

for file in "$OUTPUT_DIR"/otu_centroids_${tag}.part_*.fasta; do
    echo "[BLAST] Blasting $file ..."

    blastn \
        -query "$file" \
        -db nt \
        -remote \
        -outfmt "6 qseqid sseqid pident" \
        -perc_identity 98 \
        -evalue 1e-5 \
        -max_target_seqs 1 >> "$OUTPUT_FILE"

    if [[ $? -ne 0 ]]; then
        echo "Warning: BLAST failed on $file"
    fi

    echo "[BLAST] Sleeping $SLEEP_TIME seconds to respect NCBI limits..."
    sleep "$SLEEP_TIME"
done

echo "[BLAST] Completed. Results saved to $OUTPUT_FILE"
exit 0
