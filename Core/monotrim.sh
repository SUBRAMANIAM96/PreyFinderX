#!/bin/bash

# Check for correct number of arguments
if [[ $# -ne 8 ]]; then
    echo "Usage: $0 <file_path> <forward_read> <reverse_read> <forward_primer> <reverse_primer> <sample_tag> <quality_cutoff> <min_length>"
    exit 1
fi

# Assign input parameters
file_path="$1"
forward_read="$2"
reverse_read="$3"
fwd="$4"
rev="$5"
tag="$6"
quality="$7"
min_len="$8"

# Define results directory for this sample
results_dir="Results/${tag}"
mkdir -p "$results_dir"

# Output paths 
demux_R1="${results_dir}/demux_${tag}_F.fastq"
demux_R2="${results_dir}/demux_${tag}_R.fastq"
trimmed_R1="${results_dir}/trimmed_${tag}_F.fastq"
trimmed_R2="${results_dir}/trimmed_${tag}_R.fastq"
clean_R1="${results_dir}/no_adapters_${tag}_F.fastq"
clean_R2="${results_dir}/no_adapters_${tag}_R.fastq"
merged="${results_dir}/merged_${tag}.fastq"
filtered="${results_dir}/filtered_${tag}.fastq"
fasta="${results_dir}/filtered_${tag}.fasta"
derep="${results_dir}/dereplicated_${tag}.fasta"
nonchim="${results_dir}/nonchim_${tag}.fasta"
centroids="${results_dir}/otu_centroids_${tag}.fasta"
otu_map="${results_dir}/otu_map_${tag}.uc"

# Define BLAST output directory
OUTPUT_DIR="Results/${tag}/blast"
mkdir -p "$OUTPUT_DIR"

# Check required tools
for tool in cutadapt vsearch seqtk; do
    if ! command -v $tool &> /dev/null; then
        echo "Error: $tool not found in PATH"
        exit 1
    fi
done

# Step 1: Demultiplexing
echo "[1] Demultiplexing by tag: $tag"
cutadapt -j 12 -g "^${tag}" -G "^${tag}" --action=trim \
    -o "$demux_R1" -p "$demux_R2" \
    "$forward_read" "$reverse_read"

# Step 2: Primer trimming (single set)
echo "[2] Primer trimming"
cutadapt -j 12 -q "$quality" --minimum-length "$min_len" \
    --pair-filter=any \
    -g "$fwd" -G "$rev" \
    -o "$trimmed_R1" -p "$trimmed_R2" \
    "$demux_R1" "$demux_R2"

# Step 3: Adapter removal
echo "[3] Adapter removal"
cutadapt -j 12 -a AGATCGGAAGAGC -A AGATCGGAAGAGC \
    -o "$clean_R1" -p "$clean_R2" \
    "$trimmed_R1" "$trimmed_R2"

# Step 4: Merging
echo "[4] Merging paired-end reads"
vsearch --fastq_mergepairs "$clean_R1" \
    --reverse "$clean_R2" \
    --fastqout "$merged" \
    --fastq_minovlen 20 --fastq_maxdiffs 5 \
    --fastq_qmax 66 \
    --relabel all --threads 4

# Step 5: Quality filtering
echo "[5] Quality filtering"
vsearch --fastq_filter "$merged" \
    --fastqout "$filtered" \
    --fastq_minlen 150 --fastq_maxee 1.0 \
    --fastq_qmax 66 \
    --threads 4

# Step 6: Convert to FASTA
echo "[6] Converting to FASTA"
seqtk seq -A "$filtered" > "$fasta"

# Step 7: Dereplication
echo "[7] Dereplication"
vsearch --derep_fulllength "$fasta" --output "$derep" --sizeout --threads 4

# Step 8: Chimera removal
echo "[8] Chimera removal"
vsearch --uchime_denovo "$derep" --nonchimeras "$nonchim" --threads 4

# Step 9: OTU clustering
echo "[9] Clustering OTUs"
vsearch --cluster_fast "$nonchim" --id 0.97 \
    --centroids "$centroids" --uc "$otu_map" --relabel OTU_

# Step 10: BLAST against NCBI (online)
bash core/blast_ncbi.sh "$centroids" "$tag" "otu_centroids_${tag}"

# Step 11: Filter top hits with R
Rscript core/filter_top_hits.R "$tag"

# Step 12: Taxonomy conversion
echo "[12] Converting accession to taxonomy"
python3 core/convert_taxonomy.py "Results/${tag}" "${tag}"

echo -e "\n[✔] Analysis complete for: $tag"
exit 0
