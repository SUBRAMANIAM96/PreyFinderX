#!/bin/bash

# === USER CONFIGURATION ===
file_path="/path/to/your/data"
forward_read="${file_path}/forward read .fastq"
reverse_read="${file_path}/reverse read .fastq"

quality_cutoff=20
min_length=50

# Define primers and tags
declare -A forward_primers
declare -A reverse_primers
declare -A sample_tags

# Sample: wolfdiet_13a_F730603
forward_primers["SampleA"]="TTAGATACCCCACTATGC"
reverse_primers["SampleA"]="TAGAACAGGCTCCTCTAG"
sample_tags["SampleA"]="aattaac"

# === TOOL CHECK ===
for tool in cutadapt bash Rscript python3 vsearch seqtk blastn; do
    if ! command -v $tool &> /dev/null; then
        echo " Error: $tool not installed or not in PATH"
        exit 1
    fi
done

# === FASTQ INPUT CHECK ===
if [[ ! -f "$forward_read" || ! -f "$reverse_read" ]]; then
    echo " FASTQ files not found!"
    [[ ! -f "$forward_read" ]] && echo "Missing: $forward_read"
    [[ ! -f "$reverse_read" ]] && echo "Missing: $reverse_read"
    exit 1
fi

# === CORE SCRIPT LOCATION CHECK ===
script_dir="$(dirname "$0")"
core_script="{File_path}/PreyFinderX/core/Monotrim.sh"

if [[ ! -f "$core_script" ]]; then
    echo " Error: Core processing script not found at $core_script"
    echo "Please ensure the 'core/core.sh' script exists in the MonoTrim folder."
    exit 1
fi

# === BEGIN PIPELINE PER SAMPLE ===
for sample in "${!forward_primers[@]}"; do
    fwd_primer="${forward_primers[$sample]}"
    rev_primer="${reverse_primers[$sample]}"
    tag="${sample_tags[$sample]}"

    echo -e "\ Processing sample: $sample"

    bash "$core_script" \
        "$file_path" \
        "$forward_read" \
        "$reverse_read" \
        "$fwd_primer" \
        "$rev_primer" \
        "$tag" \
        "$quality_cutoff" \
        "$min_length"

    if [[ $? -eq 0 ]]; then
        echo " Finished sample: $sample"
    else
        echo " Error processing sample: $sample"
    fi
done

echo -e " PreyFinderX processed. Check the 'results' folder."