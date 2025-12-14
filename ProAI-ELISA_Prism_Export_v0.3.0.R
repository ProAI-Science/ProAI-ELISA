################################################################################
#                         ProAI-ELISA Prism Export                             #
#                              v0.3.0                                          #
#                                                                              #
#                          ProAI.science                                       #
#              AI-Assisted Scientific Tools for Everyone                       #
#                                                                              #
# Description: Converts ProAI-ELISA CSV outputs to GraphPad Prism format      #
#              with automatic transposition for Column tables                  #
#                                                                              #
# Version: 0.3.0 (Transposed Format)                                          #
# Author: Geoff (ProAI.science) [+ Claude (Anthropic)]                        #
# Date: December 2024                                                          #
# License: MIT                                                                 #
# Repository: github.com/ProAI-Science/ProAI-ELISA                             #
#                                                                              #
# Input: ProAI-ELISA output CSV files                                          #
# Output: Prism-formatted CSV files ready for Column table import              #
################################################################################

################################################################################
#                              HOW TO USE THIS SCRIPT                          #
################################################################################
#
# STEP 1: RUN THIS SCRIPT
# -------------------------
# 1. Open this script in RStudio
# 2. Click "Source" button or press Ctrl+Shift+S (Cmd+Shift+S on Mac)
# 3. Select ANY file from your ProAI-ELISA output folder
# 4. Prism-ready files will be created!
#
# STEP 2: IMPORT INTO PRISM
# -------------------------
# 1. Open GraphPad Prism
# 2. Create New Project → Choose "Column" table
# 3. File → Import → Select the Prism CSV file
# 4. Import dialog settings:
#    - Source tab: "Commas" → "To separate adjacent columns"
#    - Placement tab: Adjust "Column titles" as needed
#    - Click Import!
#
# REQUIREMENTS:
# - ProAI-ELISA output files in a folder
#
# OUTPUT FILES:
# - [ExpID]_Prism_Standards.csv (for standard curve plotting)
# - [ExpID]_Prism_Samples_Averaged.csv (averaged concentrations)
# - [ExpID]_Prism_Samples_Individual.csv (individual replicates)
#
################################################################################

# Load required libraries (only packages already used by ProAI-ELISA)
library(dplyr)
library(tidyr)

# Fix namespace conflicts
select <- dplyr::select
filter <- dplyr::filter

# ========== FOLDER SELECTION ==========
output_folder <- NULL  # Leave as NULL for file picker

if (is.null(output_folder) || output_folder == "") {
  cat("\n")
  cat("================================================================================\n")
  cat("                    ProAI-ELISA → Prism Export Tool                            \n")
  cat("                              ProAI.science                                     \n")
  cat("                              v0.3.0                                            \n")
  cat("================================================================================\n\n")
  cat("📂 Please select ANY file from your ProAI-ELISA output folder...\n\n")
  
  # Open folder picker (select any file, we'll use its directory)
  temp_file <- file.choose()
  output_folder <- dirname(temp_file)
  
  cat("✓ Folder selected:", output_folder, "\n\n")
  setwd(output_folder)
}

# ========== DETECT INPUT FILES ==========
cat("Searching for ProAI-ELISA output files...\n")

# Find files in folder
files <- list.files(output_folder, pattern = "\\.csv$", full.names = FALSE)

# Detect experiment ID from file names
standard_files <- files[grepl("_Standard_Curves_Averaged.csv$", files)]
sample_files <- files[grepl("_Sample_Results_Averaged.csv$", files)]

exp_ids_std <- gsub("_Standard_Curves_Averaged.csv$", "", standard_files)
exp_ids_samp <- gsub("_Sample_Results_Averaged.csv$", "", sample_files)
exp_ids <- unique(c(exp_ids_std, exp_ids_samp))

if (length(exp_ids) == 0) {
  stop("\n❌ ERROR: No ProAI-ELISA output files found!\n\n",
       "Make sure the folder contains:\n",
       "  • [ExpID]_Standard_Curves_Averaged.csv\n",
       "  • [ExpID]_Sample_Results_Averaged.csv\n\n")
}

if (length(exp_ids) > 1) {
  cat("⚠ Multiple experiment IDs detected:", paste(exp_ids, collapse = ", "), "\n")
  cat("  Using first experiment:", exp_ids[1], "\n\n")
}

experiment_id <- exp_ids[1]

cat("✓ Experiment ID detected:", experiment_id, "\n\n")

# ========== READ INPUT FILES ==========
cat("================================================================================\n")
cat("LOADING ProAI-ELISA OUTPUT FILES\n")
cat("================================================================================\n\n")

# File paths
standards_file <- paste0(experiment_id, "_Standard_Curves_Averaged.csv")
samples_avg_file <- paste0(experiment_id, "_Sample_Results_Averaged.csv")
samples_wide_file <- paste0(experiment_id, "_Sample_Wells_Individual_Wide.csv")

# Read files using base R
if (!file.exists(standards_file)) {
  stop("❌ ERROR: Cannot find ", standards_file)
}
if (!file.exists(samples_avg_file)) {
  stop("❌ ERROR: Cannot find ", samples_avg_file)
}
if (!file.exists(samples_wide_file)) {
  stop("❌ ERROR: Cannot find ", samples_wide_file)
}

standards_data <- read.csv(standards_file, stringsAsFactors = FALSE)
samples_averaged <- read.csv(samples_avg_file, stringsAsFactors = FALSE)
samples_individual <- read.csv(samples_wide_file, stringsAsFactors = FALSE)

cat("✓", standards_file, "\n")
cat("✓", samples_avg_file, "\n")
cat("✓", samples_wide_file, "\n\n")

# ========== EXPORT 1: PRISM STANDARDS (XY FORMAT) ==========
cat("Creating Prism-formatted standard curve file...\n")

# Standards use XY format (not transposed)
standards_individual_file <- paste0(experiment_id, "_Standard_Curves_Individual.csv")

if (file.exists(standards_individual_file)) {
  standards_ind <- read.csv(standards_individual_file, stringsAsFactors = FALSE)
  
  # Create Prism XY format
  prism_standards <- standards_ind %>%
    select(Concentration, Absorbance) %>%
    group_by(Concentration) %>%
    mutate(Replicate = paste0("Standard_Rep_", row_number())) %>%
    ungroup() %>%
    pivot_wider(
      names_from = Replicate,
      values_from = Absorbance
    ) %>%
    arrange(Concentration)
  
  names(prism_standards)[1] <- "Concentration (pg/mL)"
  
} else {
  # Fallback: use averaged data
  prism_standards <- standards_data %>%
    select(Concentration, Absorbance_Mean, Absorbance_SD) %>%
    rename(
      `Concentration (pg/mL)` = Concentration,
      `Absorbance (Mean)` = Absorbance_Mean,
      `Absorbance (SD)` = Absorbance_SD
    ) %>%
    arrange(Concentration)
}

prism_standards_file <- paste0(experiment_id, "_Prism_Standards.csv")
write.csv(prism_standards, prism_standards_file, row.names = FALSE)

cat("✓", prism_standards_file, "\n\n")

# ========== EXPORT 2: PRISM SAMPLES AVERAGED (TRANSPOSED) ==========
cat("Creating Prism-formatted averaged samples file (transposed)...\n")

# Prepare data with duplicate handling
prism_samples_avg_prep <- samples_averaged %>%
  select(Sample_ID, Dilution, Final_Concentration, Final_Conc_SD) %>%
  arrange(Sample_ID, Dilution)

# Handle duplicate sample IDs
sample_ids <- prism_samples_avg_prep$Sample_ID
dilutions <- prism_samples_avg_prep$Dilution

if (any(duplicated(sample_ids))) {
  dup_samples <- unique(sample_ids[duplicated(sample_ids)])
  
  for (dup in dup_samples) {
    dup_indices <- which(sample_ids == dup)
    sample_ids[dup_indices] <- paste0(sample_ids[dup_indices], "_", dilutions[dup_indices], "x")
  }
  
  cat("⚠ Found duplicate sample IDs (same sample at different dilutions)\n")
  cat("  Appended dilution factors to make unique names\n\n")
}

prism_samples_avg_prep$Sample_ID <- sample_ids

# Create non-transposed format first
prism_avg_data <- data.frame(
  Sample_ID = prism_samples_avg_prep$Sample_ID,
  Mean = prism_samples_avg_prep$Final_Concentration,
  SD = prism_samples_avg_prep$Final_Conc_SD,
  stringsAsFactors = FALSE
)

# Transpose for Prism Column format
# Each sample becomes a column, Mean/SD become rows
prism_avg_transposed <- data.frame(
  Statistic = c("Mean", "SD"),
  stringsAsFactors = FALSE
)

# Add each sample as a column
for (i in 1:nrow(prism_avg_data)) {
  sample_name <- prism_avg_data$Sample_ID[i]
  prism_avg_transposed[[sample_name]] <- c(
    prism_avg_data$Mean[i],
    prism_avg_data$SD[i]
  )
}

prism_samples_avg_file <- paste0(experiment_id, "_Prism_Samples_Averaged.csv")
write.csv(prism_avg_transposed, prism_samples_avg_file, row.names = FALSE)

cat("✓", prism_samples_avg_file, "\n\n")

# ========== EXPORT 3: PRISM SAMPLES INDIVIDUAL (TRANSPOSED) ==========
cat("Creating Prism-formatted individual replicates file (transposed)...\n")

# Get concentration columns
conc_cols <- grep("^Calculated_Conc_", names(samples_individual), value = TRUE)
n_reps <- length(conc_cols)

# Build matrix with dilution correction
prism_samples_ind_prep <- samples_individual %>%
  select(Sample_ID, Dilution, all_of(conc_cols)) %>%
  mutate(across(all_of(conc_cols), ~ . * Dilution)) %>%
  arrange(Sample_ID, Dilution)

# Handle duplicates
sample_ids_ind <- prism_samples_ind_prep$Sample_ID
dilutions_ind <- prism_samples_ind_prep$Dilution

if (any(duplicated(sample_ids_ind))) {
  dup_samples_ind <- unique(sample_ids_ind[duplicated(sample_ids_ind)])
  
  for (dup in dup_samples_ind) {
    dup_indices <- which(sample_ids_ind == dup)
    sample_ids_ind[dup_indices] <- paste0(sample_ids_ind[dup_indices], "_", dilutions_ind[dup_indices], "x")
  }
}

prism_samples_ind_prep$Sample_ID <- sample_ids_ind

# Create wide format (before transpose)
prism_ind_data <- prism_samples_ind_prep %>%
  select(-Dilution)

colnames(prism_ind_data) <- c("Sample_ID", paste0("Replicate_", 1:n_reps))

# Transpose: Samples become columns, Replicates become rows
prism_ind_transposed <- data.frame(
  Replicate = paste0("Replicate_", 1:n_reps),
  stringsAsFactors = FALSE
)

# Add each sample as a column
for (i in 1:nrow(prism_ind_data)) {
  sample_name <- prism_ind_data$Sample_ID[i]
  prism_ind_transposed[[sample_name]] <- as.numeric(prism_ind_data[i, 2:(n_reps+1)])
}

prism_samples_ind_file <- paste0(experiment_id, "_Prism_Samples_Individual.csv")
write.csv(prism_ind_transposed, prism_samples_ind_file, row.names = FALSE)

cat("✓", prism_samples_ind_file, "\n\n")

# ========== FINAL SUMMARY ==========
cat("================================================================================\n")
cat("✓ PRISM EXPORT COMPLETE!\n")
cat("================================================================================\n\n")

cat("📁 Prism-Ready Files Created:\n\n")

cat("---For Standard Curve Plotting---\n")
cat(sprintf("  • %s\n", prism_standards_file))
cat("    └─ Import into Prism as XY table\n")
cat("    └─ X = Concentration, Y = Standard absorbance\n\n")

cat("---For Sample Bar Charts (Averaged)---\n")
cat(sprintf("  • %s\n", prism_samples_avg_file))
cat("    └─ Import into Prism as Column table\n")
cat("    └─ Format: Transposed (samples as columns)\n")
cat("    └─ Shows mean and SD for each sample\n\n")

cat("---For Sample Analysis (Individual Replicates)---\n")
cat(sprintf("  • %s\n", prism_samples_ind_file))
cat("    └─ Import into Prism as Column table\n")
cat("    └─ Format: Transposed (samples as columns)\n")
cat("    └─ Individual replicate values\n")
cat("    └─ Prism can calculate statistics automatically\n\n")

cat("💡 Prism Import Instructions:\n")
cat("  1. Open GraphPad Prism\n")
cat("  2. Create new project → Choose 'Column' table format\n")
cat("  3. File → Import → Select CSV file\n")
cat("  4. In import dialog:\n")
cat("     - Source tab: 'Commas' → 'To separate adjacent columns'\n")
cat("     - Placement tab: Adjust settings as needed\n")
cat("     - Click Import\n")
cat("  5. Your data should import with samples as columns!\n\n")

cat("📝 Note: Files are in TRANSPOSED format (samples = columns, replicates = rows)\n")
cat("    This is the standard Prism Column table format.\n\n")

cat("================================================================================\n")
cat("                    Export powered by ProAI-ELISA                               \n")
cat("                            ProAI.science                                       \n")
cat("              AI-Assisted Scientific Tools for Everyone                         \n")
cat("                 github.com/ProAI-Science/ProAI-ELISA                           \n")
cat("================================================================================\n\n")
