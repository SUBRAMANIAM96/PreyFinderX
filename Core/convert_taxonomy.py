#!/usr/bin/env python3

from Bio import Entrez
import time
import re
from datetime import datetime
import os
import sys

# Set your email for NCBI Entrez API (mandatory)
Entrez.email = "subramanyamvkumar@gmail.com"

# Parse input arguments
if len(sys.argv) != 3:
    print("Usage: python3 convert_taxonomy.py <blast_output_dir> <tag>")
    sys.exit(1)

base_dir = sys.argv[1]  # This will be something like: results
tag = sys.argv[2]       # This will be the tag sequence like: aattaac

# Input file path
input_file_path = os.path.join(base_dir, "blast", f"cleaned_blast_results_{tag}.txt")

# Output directory inside results/<tag>/taxonomy
output_dir = os.path.join(base_dir, "blast")
os.makedirs(output_dir, exist_ok=True)

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_file_path = os.path.join(output_dir, f"taxonomy_results_{tag}.txt")

def extract_accession(acc_string):
    match = re.search(r"gi\|\d+\|[A-Za-z]+(?:\|([A-Za-z0-9_.]+))", acc_string)
    return match.group(1) if match else None

def fetch_taxonomy(acc_number):
    try:
        print(f"Fetching taxonomy for accession: {acc_number}")
        with Entrez.efetch(db="nucleotide", id=acc_number, rettype="gb", retmode="xml") as handle:
            record = Entrez.read(handle)
        return record[0].get("GBSeq_organism", "No taxonomy data found")
    except Exception as e:
        return f"Error: {e}"

def process_blast_output(file_path):
    processed_lines = set()

    with open(file_path, "r", encoding="utf-8") as infile:
        lines = infile.readlines()

    with open(output_file_path, "w", encoding="utf-8") as outfile:
        for line in lines:
            columns = line.strip().split("\t")  
            if len(columns) >= 3:
                otu_id = columns[0].strip()
                acc_string = columns[1].strip()
                identity = columns[2].strip()

                acc_number = extract_accession(acc_string)
                if acc_number:
                    taxonomy = fetch_taxonomy(acc_number)
                    columns[1] = taxonomy
                    new_line = "\t".join(columns)
                    if new_line not in processed_lines:
                        outfile.write(new_line + "\n")
                        processed_lines.add(new_line)
                    time.sleep(5)

    print(f"✅ Taxonomy output saved to: {output_file_path}")

# Run
if os.path.isfile(input_file_path):
    process_blast_output(input_file_path)
else:
    print(f"❌ Input file not found: {input_file_path}")
