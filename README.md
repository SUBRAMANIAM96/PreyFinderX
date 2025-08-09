## 🌟 Overview
PreyFinderX is a fully automated, end-to-end bioinformatics pipeline that takes raw sequencing reads and transforms them into clean, ready-to-use taxonomic identifications without the need for manual processing or complicated intermediate steps. Built specifically for dietary analysis and ecological research, it is optimized to handle both 16S rRNA for bacterial and microbiome profiling, and 12S rRNA for vertebrate metabarcoding, making it ideal for studies ranging from gut microbiome assessments to predator–prey investigations.

With PreyFinderX, you bring just three things:
   1. Paired-end FASTQ files
   2. Forward & reverse primers
   3. Sample tags/barcodes
From there, the pipeline takes care of everything like demultiplexing, trimming, quality control, OTU clustering, BLAST annotation, and taxonomic assignment, producing a neatly organized taxonomy table that is immediately ready for ecological interpretation, dietary composition summaries, or statistical analysis.

## 🥗 Built for Dietary Studies
Whether you’re identifying fish in a seal’s diet, tracking insect prey in bat guano, or profiling a gut microbiome, PreyFinderX delivers:
  1.  High-confidence OTU assignments for reliable diet composition results
  2.  Fully reproducible outputs for publication-ready analysis
  3.  Organized results by sample for easy downstream processing

## Why PreyFinderX Stands Out
✅ True one-command automation — no juggling 10 different tools
✅ Dual capability — 16S & 12S metabarcoding in one pipeline
✅ Primer-aware processing — maximizes sequence recovery & accuracy
✅ Direct NCBI integration — always works with up-to-date databases
✅ Reproducible structure — consistent output folders for every run

## ⚙️ Workflow Overview
The pipeline is built around two scripts:
🎛️ run_pipeline.sh — Your control panel
📝 Enter your primer pair, tag sequences, and analysis parameters.
▶️ This calls the main engine to start the run.
🧠 monotrim.sh — The core processor
Does all the heavy lifting:
Step	Description	Icon
1️⃣ Demultiplex & trim	Uses your tags & primers to split and clean reads	✂️
2️⃣ Quality filter	Removes low-quality reads	🧹
3️⃣ Merge pairs	Joins forward & reverse reads into full amplicons	🔗
4️⃣ Length filter	Discards off-target or short fragments	📏
5️⃣ Dereplicate	Collapses identical reads for faster clustering	📦
6️⃣ Remove chimeras	Filters out PCR artifacts	🧪
7️⃣ Cluster OTUs	Groups similar sequences into taxonomic units	🧬
8️⃣ Select centroids	Picks representative sequences for BLAST	🎯
9️⃣ BLAST search	Matches sequences against the NCBI nt database	🌐
🔟 Top-hit filtering	Keeps only the best match per OTU	🏆
1️⃣1️⃣ Taxonomy assignment	Converts BLAST hits into species names	📖

## 📂 File & Folder Structure
After running the pipeline, your results will be organized as follows:
PreyFinderX/
├── core/                     # Core scripts for each step
│   ├── Monotrim.sh            # Pre-BLAST processing
│   ├── blast_remote.sh        # BLAST OTU centroids
│   ├── filter_top_hits.R      # Filter BLAST top hits
│   ├── convert_taxonomy.py    # Convert to taxonomy
│   └── ...
├── Results/
│   ├── <sample_tag>/
│   │   ├── demux_<tag>_F.fastq
│   │   ├── demux_<tag>_R.fastq
│   │   ├── trimmed_<tag>_F.fastq
│   │   ├── trimmed_<tag>_R.fastq
│   │   ├── merged_<tag>.fastq
│   │   ├── filtered_<tag>.fastq
│   │   ├── filtered_<tag>.fasta
│   │   ├── dereplicated_<tag>.fasta
│   │   ├── nonchim_<tag>.fasta
│   │   ├── otu_centroids_<tag>.fasta
│   │   ├── otu_map_<tag>.uc
│   │   ├── blast/
│   │   │   ├── blast_results_all.txt
│   │   │   ├── cleaned_blast_results_<tag>.txt
│   │   │   ├── taxonomy_results_<tag>.txt
│   │   └── ...
└── README.md

## 🧪 Testing the Pipeline
Why use the test folder?
  1. Quick validation: Confirm your setup is correct and all dependencies work
  2. Learning: See example data formatted exactly as needed
  3. Troubleshooting: Isolate issues by comparing your results with expected outputs

How to run the test?
From the root directory, simply run:
./testrun_pipeline.sh

## ⚙️ Requirements
   1. seqkit — FASTA/FASTQ manipulation
   2. Cutadapt — Primer and adapter trimming
   3. vsearch — OTU clustering, chimera detection, dereplication
   4. R + dplyr — BLAST hit filtering
   5. Python 3 + Biopython — Taxonomy fetching
   6. Internet access — for NCBI BLAST & taxonomy retrieval

## 📥 Clone the repository
git clone https://github.com/SUBRAMANIAM96/PreyFinderX.git
cd PreyFinderX

## 🔑 Make scripts executable
chmod +x scripts/*.sh

## 🔑 To edit the script 
nano metatrimx/run_pipeline.sh

## 🚀 Run the pipeline
./run_pipeline.sh config/primers_tags.txt data/raw/ results/

## 👥 Contributors
Subramaniam Vijayakumar
📧 Email: subramanyamvkumar@gmail.com
🔗 GitHub: SUBRAMANIAM96



