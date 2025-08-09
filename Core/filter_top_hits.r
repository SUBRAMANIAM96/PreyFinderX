#!/usr/bin/env Rscript

library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1) {
  stop("Usage: Rscript filter_top_hits.R <tag>")
}

tag <- args[1]

# Set paths
blast_dir <- file.path("Results", tag, "blast")
file_path <- file.path(blast_dir, "blast_results_all.txt")

if (!file.exists(file_path)) {
  stop(paste("File not found:", file_path))
}

# Read the data
df <- read.delim(file_path, header = TRUE, stringsAsFactors = FALSE)

df$Accession <- df[[2]]
df$PercentIdentity <- as.numeric(df[[3]])
df <- df %>% filter(!is.na(Accession) & !is.na(PercentIdentity))

df_clean <- df %>%
  group_by(Accession) %>%
  slice_max(order_by = PercentIdentity, n = 1, with_ties = FALSE) %>%
  ungroup()

output_df <- df_clean %>% select(OTU = 1, Accession, PercentIdentity)

output_file <- file.path(blast_dir, paste0("cleaned_blast_results_", tag, ".txt"))
write.table(output_df, file = output_file, sep = "\t", quote = FALSE, row.names = FALSE)

cat(paste("Processed and saved cleaned file:", output_file, "\n"))
