################################################################################
#                              ProAI-ELISA                                     #
#                         v0.1.0 - Core Pipeline                              #
#                                                                              #
#                          ProAI.science                                       #
#              AI-Assisted Scientific Tools for Everyone                       #
#                                                                              #
# Description: Automated ELISA analysis with 4PL curve fitting,               #
#              quality control, and publication-ready outputs                  #
#                                                                              #
# Version: 0.1.0 (Base - Single Standard Curve)                               #
# Author: Geoff (ProAI.science) [+ Claude (Anthropic)]                        #
# Date: December 2024                                                          #
# License: MIT                                                                 #
# Repository: github.com/ProAI-Science/ProAI-ELISA                             #
#                                                                              #
# Future versions will add:                                                    #
#       - v0.2.0: Prism export functionality                                   #
#       - v1.0.0: Normalization features                                       #
################################################################################

################################################################################
#                              HOW TO USE THIS SCRIPT                          #
################################################################################
#
# FOR NON-CODERS (Easy Method):
# 1. Open this script in RStudio
# 2. Click "Source" button at top-right, OR press Ctrl+Shift+S (Cmd+Shift+S on Mac)
# 3. A file picker window will appear - click on your Excel file
# 4. Wait for the analysis to complete (watch the Console for progress)
# 5. Find your results in the same folder as your Excel file!
#
# FOR ADVANCED USERS:
# - Set file_path directly on line 79 to skip the file picker
# - Useful for batch processing or automation
#
# REQUIREMENTS:
# - RStudio installed
# - Excel file with 7 tabs: Absorbance, Sample_Map, Dilution_Factors,
#   Standards, Sample_Type, Sample_Curve_Assignment, Experiment_Info
# - See documentation at github.com/ProAI-Science/ProAI-ELISA
#
################################################################################

# Load required libraries
library(readxl)    # For reading Excel files
library(dplyr)     # For data manipulation
library(tidyr)     # For data reshaping
library(ggplot2)   # For plotting
library(drc)       # For dose-response curves (4PL fitting)

# Fix namespace conflicts (prevents select() errors)
select <- dplyr::select
filter <- dplyr::filter

# Install drc if not already installed
if (!require("drc", quietly = TRUE)) {
  install.packages("drc")
  library(drc)
}

# Set up colorblind-friendly palette
cb_palette <- c("#0173B2", "#DE8F05", "#029E73", "#CC78BC", "#ECE133", 
                "#56B4E9", "#CA9161", "#FBAFE4", "#949494", "#ADE8F4")

# ========== FILE SELECTION ==========
# 
# METHOD 1 (Easiest): Leave file_path as NULL and a file picker will appear
# METHOD 2 (Advanced): Enter the full path to your file below
# Example: file_path <- "C:/Users/YourName/Documents/ELISA_Data.xlsx"
#

file_path <- NULL  # Leave as NULL for interactive file picker

# ===========================================================================
# AUTOMATIC FILE SELECTION & SETUP
# ===========================================================================

if (is.null(file_path) || file_path == "") {
  cat("\n")
  cat("================================================================================\n")
  cat("                          ProAI-ELISA File Selection                            \n")
  cat("                              ProAI.science                                     \n")
  cat("================================================================================\n\n")
  cat("📂 Please select your ELISA Excel file in the dialog box...\n\n")
  
  # Open file picker
  file_path <- file.choose()
  
  cat("✓ File selected:", basename(file_path), "\n")
  cat("✓ Location:", dirname(file_path), "\n\n")
  
  # Set working directory to file location (outputs will save here)
  setwd(dirname(file_path))
  cat("✓ Output files will be saved to:", getwd(), "\n\n")
  
  cat("Starting analysis...\n")
  Sys.sleep(1)  # Brief pause for readability
}

# ========== 1. READ DATA & EXPERIMENT INFO ==========
cat("\n")
cat("================================================================================\n")
cat("#                              ProAI-ELISA                                     #\n")
cat("#                         v0.1.0 - Core Analysis                              #\n")
cat("#                           ProAI.science                                      #\n")
cat("================================================================================\n\n")

# Read Experiment Info (REQUIRED)
tryCatch({
  experiment_info <- read_excel(file_path, sheet = "Experiment_Info")
  experiment_id <- experiment_info$Value[experiment_info$Field == "Experiment_ID"]
  
  if (is.na(experiment_id) || length(experiment_id) == 0 || experiment_id == "") {
    stop("ERROR: Experiment_ID is missing or empty!")
  }
  
  cat("📋 Experiment ID:", experiment_id, "\n")
  cat("================================================================================\n\n")
  
}, error = function(e) {
  stop("\n❌ ERROR: Could not read Experiment_Info tab!\n\n",
       "Your Excel file must have 'Experiment_Info' tab with:\n",
       "  Field            Value\n",
       "  Experiment_ID    [Your_ID_Here]\n\n")
})

# Read all data tabs
absorbance_data <- read_excel(file_path, sheet = "Absorbance")
sample_map <- read_excel(file_path, sheet = "Sample_Map")
dilution_factors <- read_excel(file_path, sheet = "Dilution_Factors")
standards_info <- read_excel(file_path, sheet = "Standards")
sample_type <- read_excel(file_path, sheet = "Sample_Type")
curve_assignments <- read_excel(file_path, sheet = "Sample_Curve_Assignment")

cat("✓ Data loaded successfully\n\n")

# ========== 2. PREPARE DATA ==========
cat("Preparing data...\n")

# Reshape to long format
abs_long <- absorbance_data %>%
  pivot_longer(cols = -Row, names_to = "Column", values_to = "Absorbance") %>%
  mutate(Well = paste0(Row, Column))

sample_long <- sample_map %>%
  pivot_longer(cols = -Row, names_to = "Column", values_to = "Sample_ID") %>%
  mutate(Well = paste0(Row, Column))

dilution_long <- dilution_factors %>%
  pivot_longer(cols = -Row, names_to = "Column", values_to = "Dilution") %>%
  mutate(Well = paste0(Row, Column))

type_long <- sample_type %>%
  pivot_longer(cols = -Row, names_to = "Column", values_to = "Type") %>%
  mutate(Well = paste0(Row, Column))

# Combine all data
combined_data <- abs_long %>%
  left_join(sample_long, by = "Well") %>%
  left_join(dilution_long, by = "Well") %>%
  left_join(type_long, by = "Well") %>%
  filter(Type != "Empty")

cat("✓ Data reshaped and combined\n\n")

# ========== 3. PROCESS STANDARDS ==========
cat("Processing standard curves...\n")

# Get standards data (with namespace fix)
standards_data <- combined_data %>%
  filter(Type == "Standard") %>%
  left_join(standards_info %>% select(Well, Curve, Concentration, Unit), by = "Well")

# Export individual standard wells (for Prism)
standards_individual <- standards_data %>%
  select(Well, Concentration, Curve, Unit, Absorbance) %>%
  arrange(Curve, Concentration, Well)

write.csv(standards_individual, 
          paste0(experiment_id, "_Standard_Curves_Individual.csv"), 
          row.names = FALSE)

# Calculate averaged standards
standards_avg <- standards_data %>%
  group_by(Concentration, Curve, Unit) %>%
  summarise(
    Absorbance_Mean = mean(Absorbance, na.rm = TRUE),
    Absorbance_SD = sd(Absorbance, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

write.csv(standards_avg, 
          paste0(experiment_id, "_Standard_Curves_Averaged.csv"), 
          row.names = FALSE)

cat("✓ Standard curve data exported\n\n")

# ========== 4. FIT MULTIPLE CURVE TYPES ==========
cat("================================================================================\n")
cat("FITTING STANDARD CURVES - MULTIPLE METHODS\n")
cat("================================================================================\n\n")

# Function to fit all curve types
fit_all_curves <- function(data, curve_name) {
  
  cat("--- ", curve_name, " ---\n", sep = "")
  
  data_no_zero <- data %>% filter(Concentration > 0)
  
  fits <- list()
  r_squared <- list()
  
  # 4PL (PRIMARY)
  tryCatch({
    fit_4pl <- drm(Absorbance_Mean ~ Concentration, 
                   data = data,
                   fct = LL.4(names = c("Slope", "Lower", "Upper", "EC50")))
    fits[["4PL"]] <- fit_4pl
    
    pred_4pl <- predict(fit_4pl)
    ss_res <- sum((data$Absorbance_Mean - pred_4pl)^2)
    ss_tot <- sum((data$Absorbance_Mean - mean(data$Absorbance_Mean))^2)
    r_squared[["4PL"]] <- 1 - (ss_res / ss_tot)
    
    cat(sprintf("✓ 4PL (PRIMARY): R² = %.4f\n", r_squared[["4PL"]]))
    
    params <- coef(fit_4pl)
    cat(sprintf("  Parameters: Slope=%.3f, Lower=%.3f, Upper=%.3f, EC50=%.3f\n",
                params[1], params[2], params[3], params[4]))
    
  }, error = function(e) {
    cat("✗ 4PL fitting failed\n")
    fits[["4PL"]] <- NULL
    r_squared[["4PL"]] <- NA
  })
  
  # Linear
  tryCatch({
    fit_linear <- lm(Absorbance_Mean ~ Concentration, data = data)
    fits[["Linear"]] <- fit_linear
    r_squared[["Linear"]] <- summary(fit_linear)$r.squared
    cat(sprintf("✓ Linear: R² = %.4f\n", r_squared[["Linear"]]))
  }, error = function(e) {
    fits[["Linear"]] <- NULL
    r_squared[["Linear"]] <- NA
  })
  
  # Semi-log
  tryCatch({
    fit_semilog <- lm(Absorbance_Mean ~ log10(Concentration), data = data_no_zero)
    fits[["Semi-log"]] <- fit_semilog
    r_squared[["Semi-log"]] <- summary(fit_semilog)$r.squared
    cat(sprintf("✓ Semi-log: R² = %.4f\n", r_squared[["Semi-log"]]))
  }, error = function(e) {
    fits[["Semi-log"]] <- NULL
    r_squared[["Semi-log"]] <- NA
  })
  
  # Log-log
  tryCatch({
    fit_loglog <- lm(log10(Absorbance_Mean) ~ log10(Concentration), data = data_no_zero)
    fits[["Log-log"]] <- fit_loglog
    r_squared[["Log-log"]] <- summary(fit_loglog)$r.squared
    cat(sprintf("✓ Log-log: R² = %.4f\n", r_squared[["Log-log"]]))
  }, error = function(e) {
    fits[["Log-log"]] <- NULL
    r_squared[["Log-log"]] <- NA
  })
  
  # Rank methods
  r_sq_df <- data.frame(
    Method = names(r_squared),
    R_squared = unlist(r_squared)
  ) %>% arrange(desc(R_squared))
  
  cat("\n📊 Curve Fit Ranking:\n")
  print(r_sq_df, row.names = FALSE)
  cat("\n")
  
  return(list(fits = fits, r_squared = r_squared, ranking = r_sq_df))
}

# Fit both curves
curve1_data <- standards_avg %>% filter(Curve == "Curve1")
curve2_data <- standards_avg %>% filter(Curve == "Curve2")

curve1_fits <- fit_all_curves(curve1_data, "CURVE 1")

# Only fit Curve2 if it exists
if (nrow(curve2_data) > 0) {
  curve2_fits <- fit_all_curves(curve2_data, "CURVE 2")
} else {
  curve2_fits <- NULL
  cat("--- CURVE 2 ---\n")
  cat("⚠ No Curve2 data found (single-curve ELISA)\n\n")
}

# Export curve comparison
if (!is.null(curve2_fits)) {
  curve_comparison <- rbind(
    curve1_fits$ranking %>% mutate(Curve = "Curve1", Experiment_ID = experiment_id),
    curve2_fits$ranking %>% mutate(Curve = "Curve2", Experiment_ID = experiment_id)
  )
} else {
  curve_comparison <- curve1_fits$ranking %>% 
    mutate(Curve = "Curve1", Experiment_ID = experiment_id)
}

write.csv(curve_comparison, 
          paste0(experiment_id, "_Curve_Fitting_Comparison.csv"), 
          row.names = FALSE)

# ========== 5. PLOT STANDARD CURVES ==========
cat("Generating standard curve plots...\n")

plot_curve_comparison <- function(data, fits_list, r_sq_list, title_text, x_label, filename) {
  
  conc_range <- seq(min(data$Concentration), max(data$Concentration), length.out = 100)
  
  p <- ggplot(data, aes(x = Concentration, y = Absorbance_Mean)) +
    geom_point(size = 3, color = "black") +
    geom_errorbar(aes(ymin = Absorbance_Mean - Absorbance_SD,
                      ymax = Absorbance_Mean + Absorbance_SD),
                  width = max(data$Concentration) * 0.02) +
    labs(title = title_text,
         x = x_label,
         y = "Absorbance (450 nm)") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
          legend.position = "right",
          panel.grid.minor = element_blank())
  
  # Add fitted curves
  if (!is.null(fits_list[["4PL"]])) {
    pred_4pl <- predict(fits_list[["4PL"]], newdata = data.frame(Concentration = conc_range))
    p <- p + geom_line(data = data.frame(x = conc_range, y = pred_4pl),
                       aes(x = x, y = y, color = "4PL"), linewidth = 1.2)
  }
  
  if (!is.null(fits_list[["Linear"]])) {
    pred_linear <- predict(fits_list[["Linear"]], newdata = data.frame(Concentration = conc_range))
    p <- p + geom_line(data = data.frame(x = conc_range, y = pred_linear),
                       aes(x = x, y = y, color = "Linear"), linewidth = 0.8, linetype = "dashed")
  }
  
  if (!is.null(fits_list[["Semi-log"]])) {
    conc_range_no_zero <- conc_range[conc_range > 0]
    pred_semilog <- predict(fits_list[["Semi-log"]], 
                           newdata = data.frame(Concentration = conc_range_no_zero))
    p <- p + geom_line(data = data.frame(x = conc_range_no_zero, y = pred_semilog),
                       aes(x = x, y = y, color = "Semi-log"), linewidth = 0.8, linetype = "dotted")
  }
  
  if (!is.null(fits_list[["Log-log"]])) {
    conc_range_no_zero <- conc_range[conc_range > 0]
    pred_loglog <- 10^predict(fits_list[["Log-log"]], 
                              newdata = data.frame(Concentration = conc_range_no_zero))
    p <- p + geom_line(data = data.frame(x = conc_range_no_zero, y = pred_loglog),
                       aes(x = x, y = y, color = "Log-log"), linewidth = 0.8, linetype = "twodash")
  }
  
  # Create legend labels with R²
  legend_labels <- c(
    "4PL" = sprintf("4PL (PRIMARY, R²=%.4f)", r_sq_list[["4PL"]]),
    "Linear" = sprintf("Linear (R²=%.3f)", r_sq_list[["Linear"]]),
    "Semi-log" = sprintf("Semi-log (R²=%.3f)", r_sq_list[["Semi-log"]]),
    "Log-log" = sprintf("Log-log (R²=%.3f)", r_sq_list[["Log-log"]])
  )
  
  p <- p + scale_color_manual(
    name = "Curve Fit Method",
    values = c("4PL" = "#E41A1C", "Linear" = "#377EB8", 
               "Semi-log" = "#4DAF4A", "Log-log" = "#984EA3"),
    labels = legend_labels
  )
  
  ggsave(filename, p, width = 10, height = 6)
  return(p)
}

# Generate plots
p1 <- plot_curve_comparison(
  curve1_data, curve1_fits$fits, curve1_fits$r_squared,
  paste0("Standard Curve 1 (", unique(curve1_data$Unit), ")"),
  paste0("Concentration (", unique(curve1_data$Unit), ")"),
  paste0(experiment_id, "_Standard_Curve_1.pdf")
)

print(p1)

if (!is.null(curve2_fits) && nrow(curve2_data) > 0) {
  p2 <- plot_curve_comparison(
    curve2_data, curve2_fits$fits, curve2_fits$r_squared,
    paste0("Standard Curve 2 (", unique(curve2_data$Unit), ")"),
    paste0("Concentration (", unique(curve2_data$Unit), ")"),
    paste0(experiment_id, "_Standard_Curve_2.pdf")
  )
  print(p2)
}

cat("✓ Standard curve plots saved\n\n")

# ========== 6. CALCULATE SAMPLE CONCENTRATIONS ==========
cat("================================================================================\n")
cat("CALCULATING SAMPLE CONCENTRATIONS (4PL Method)\n")
cat("================================================================================\n\n")

# Get samples and add curve assignments
samples_data <- combined_data %>%
  filter(Type == "Sample") %>%
  left_join(curve_assignments, by = "Sample_ID")

# 4PL calculation function
calc_concentration_4pl <- function(absorbance, curve_name) {
  
  if (curve_name == "Curve1") {
    fit <- curve1_fits$fits[["4PL"]]
  } else if (curve_name == "Curve2") {
    if (!is.null(curve2_fits)) {
      fit <- curve2_fits$fits[["4PL"]]
    } else {
      return(NA)
    }
  } else {
    return(NA)
  }
  
  if (is.null(fit)) return(NA)
  
  params <- coef(fit)
  slope <- params[1]
  lower <- params[2]
  upper <- params[3]
  ec50 <- params[4]
  
  if (absorbance < lower || absorbance > upper) {
    return(NA)
  }
  
  tryCatch({
    conc <- ec50 * (((upper - lower) / (absorbance - lower)) - 1)^(1/slope)
    return(conc)
  }, error = function(e) {
    return(NA)
  })
}

# Vectorized wrapper
calc_conc_vectorized <- function(abs_values, curve_names) {
  result <- numeric(length(abs_values))
  for (i in seq_along(abs_values)) {
    result[i] <- calc_concentration_4pl(abs_values[i], curve_names[i])
  }
  return(result)
}

# Calculate concentrations
samples_data <- samples_data %>%
  filter(!is.na(Curve)) %>%
  mutate(Calculated_Conc = calc_conc_vectorized(Absorbance, Curve))

cat("✓ Concentrations calculated\n\n")

# ========== 7. EXPORT INDIVIDUAL WELL DATA ==========

# Wide format (for Prism)
samples_wide <- samples_data %>%
  group_by(Sample_ID) %>%
  mutate(Replicate_Num = row_number()) %>%
  ungroup() %>%
  select(Sample_ID, Replicate_Num, Absorbance, Calculated_Conc, Dilution, Curve) %>%
  pivot_wider(
    names_from = Replicate_Num,
    values_from = c(Absorbance, Calculated_Conc),
    names_glue = "{.value}_{Replicate_Num}"
  )

write.csv(samples_wide, 
          paste0(experiment_id, "_Sample_Wells_Individual_Wide.csv"), 
          row.names = FALSE)

# Long format
samples_long <- samples_data %>%
  select(Sample_ID, Well, Absorbance, Calculated_Conc, Dilution, Curve) %>%
  arrange(Curve, Sample_ID, Well)

write.csv(samples_long, 
          paste0(experiment_id, "_Sample_Wells_Individual_Long.csv"), 
          row.names = FALSE)

cat("✓ Individual well data exported (Wide & Long formats)\n\n")

# ========== 8. AVERAGE TECHNICAL REPLICATES & APPLY DILUTION ==========
cat("Averaging technical replicates and applying dilution factors...\n")

# Get unit for each curve
curve1_unit <- unique(curve1_data$Unit)
curve2_unit <- if (!is.null(curve2_fits) && nrow(curve2_data) > 0) unique(curve2_data$Unit) else NA

sample_results <- samples_data %>%
  group_by(Sample_ID, Curve, Dilution) %>%
  summarise(
    Absorbance_Mean = mean(Absorbance, na.rm = TRUE),
    Absorbance_SD = sd(Absorbance, na.rm = TRUE),
    Calculated_Conc_Mean = mean(Calculated_Conc, na.rm = TRUE),
    Calculated_Conc_SD = sd(Calculated_Conc, na.rm = TRUE),
    n_replicates = n(),
    .groups = "drop"
  ) %>%
  mutate(
    Final_Concentration = Calculated_Conc_Mean * Dilution,
    Final_Conc_SD = Calculated_Conc_SD * Dilution,
    Unit = ifelse(Curve == "Curve1", curve1_unit, curve2_unit),
    Experiment_ID = experiment_id
  )

write.csv(sample_results, 
          paste0(experiment_id, "_Sample_Results_Averaged.csv"), 
          row.names = FALSE)

cat("✓ Averaged results exported\n\n")

# ========== 9. GENERATE SAMPLE CONCENTRATION PLOTS ==========
cat("Generating sample concentration plots...\n")

# Function to parse treatment group from Sample_ID
parse_treatment_group <- function(sample_ids) {
  # Extract everything before the last underscore (assumes format: Treatment_Timepoint_Rep)
  # Example: AMT101_10ugmL_t0_01 -> AMT101_10ugmL
  sapply(strsplit(sample_ids, "_"), function(x) {
    if (length(x) > 1) {
      paste(x[1:(length(x)-1)], collapse = "_")
    } else {
      x[1]
    }
  })
}

# Plot function for each curve
plot_sample_concentrations <- function(data, curve_name, curve_unit, filename) {
  
  # Add treatment grouping
  data <- data %>%
    mutate(Treatment_Group = parse_treatment_group(Sample_ID))
  
  # Get unique treatment groups and assign color families
  treatment_groups <- unique(data$Treatment_Group)
  n_groups <- length(treatment_groups)
  
  # Assign base colors from colorblind palette
  base_colors <- cb_palette[1:min(n_groups, length(cb_palette))]
  
  # Create color mapping with gradients within groups
  color_map <- c()
  for (i in seq_along(treatment_groups)) {
    group_samples <- data %>% 
      filter(Treatment_Group == treatment_groups[i]) %>%
      pull(Sample_ID) %>%
      unique()
    
    n_samples <- length(group_samples)
    if (n_samples == 1) {
      color_map[group_samples] <- base_colors[i]
    } else {
      # Create gradient
      group_colors <- colorRampPalette(c(base_colors[i], "#FFFFFF"))(n_samples + 1)[1:n_samples]
      names(group_colors) <- group_samples
      color_map <- c(color_map, group_colors)
    }
  }
  
  # Prepare plot data
  plot_data_avg <- data %>%
    group_by(Sample_ID, Treatment_Group) %>%
    summarise(
      Mean_Conc = mean(Final_Concentration, na.rm = TRUE),
      SD_Conc = sd(Final_Concentration, na.rm = TRUE),
      .groups = "drop"
    )
  
  plot_data_points <- data %>%
    select(Sample_ID, Final_Concentration, Treatment_Group)
  
  # Create plot
  p <- ggplot() +
    # Error bars
    geom_errorbar(data = plot_data_avg,
                  aes(x = Sample_ID, 
                      ymin = Mean_Conc - SD_Conc,
                      ymax = Mean_Conc + SD_Conc),
                  width = 0.3, linewidth = 0.5) +
    # Bars (unfilled)
    geom_bar(data = plot_data_avg,
             aes(x = Sample_ID, y = Mean_Conc, fill = Sample_ID),
             stat = "identity", color = "black", alpha = 0.7, linewidth = 0.3) +
    # Individual points
    geom_point(data = plot_data_points,
               aes(x = Sample_ID, y = Final_Concentration),
               size = 2, alpha = 0.8) +
    scale_fill_manual(values = color_map) +
    labs(
      title = paste0("Sample Concentrations - ", curve_name),
      x = "Sample ID",
      y = paste0("Concentration (", curve_unit, ")")
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
      axis.text.x = element_text(angle = 45, hjust = 1, size = 9),
      legend.position = "none",
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank()
    )
  
  ggsave(filename, p, width = 12, height = 6)
  return(p)
}

# Generate plots for each curve
curve1_samples <- sample_results %>% filter(Curve == "Curve1")
curve2_samples <- sample_results %>% filter(Curve == "Curve2")

if (nrow(curve1_samples) > 0) {
  # Need individual well data for plotting points
  curve1_individual <- samples_data %>% 
    filter(Curve == "Curve1") %>%
    mutate(Final_Concentration = Calculated_Conc * Dilution)
  
  p_samples1 <- plot_sample_concentrations(
    curve1_individual,
    "Curve 1",
    curve1_unit,
    paste0(experiment_id, "_Sample_Concentrations_Curve1.pdf")
  )
  print(p_samples1)
}

if (!is.null(curve2_fits) && nrow(curve2_samples) > 0) {
  curve2_individual <- samples_data %>% 
    filter(Curve == "Curve2") %>%
    mutate(Final_Concentration = Calculated_Conc * Dilution)
  
  p_samples2 <- plot_sample_concentrations(
    curve2_individual,
    "Curve 2",
    curve2_unit,
    paste0(experiment_id, "_Sample_Concentrations_Curve2.pdf")
  )
  print(p_samples2)
}

cat("✓ Sample concentration plots saved\n\n")

# ========== 10. FINAL SUMMARY ==========
cat("================================================================================\n")
cat("✓ ANALYSIS COMPLETE!\n")
cat("================================================================================\n\n")

cat("📁 Files Created:\n")
cat("---Standard Curves---\n")
cat(sprintf("  • %s_Standard_Curves_Individual.csv\n", experiment_id))
cat(sprintf("  • %s_Standard_Curves_Averaged.csv\n", experiment_id))
cat(sprintf("  • %s_Curve_Fitting_Comparison.csv\n", experiment_id))
cat(sprintf("  • %s_Standard_Curve_1.pdf\n", experiment_id))
if (!is.null(curve2_fits) && nrow(curve2_data) > 0) {
  cat(sprintf("  • %s_Standard_Curve_2.pdf\n", experiment_id))
}
cat("\n---Samples---\n")
cat(sprintf("  • %s_Sample_Wells_Individual_Wide.csv (Prism format)\n", experiment_id))
cat(sprintf("  • %s_Sample_Wells_Individual_Long.csv\n", experiment_id))
cat(sprintf("  • %s_Sample_Results_Averaged.csv\n", experiment_id))
if (nrow(curve1_samples) > 0) {
  cat(sprintf("  • %s_Sample_Concentrations_Curve1.pdf\n", experiment_id))
}
if (!is.null(curve2_fits) && nrow(curve2_samples) > 0) {
  cat(sprintf("  • %s_Sample_Concentrations_Curve2.pdf\n", experiment_id))
}

cat("\n💡 Analysis Method:\n")
cat("  • Primary curve fitting: 4-Parameter Logistic (4PL)\n")
cat(sprintf("  • Curve 1 R²: %.4f\n", curve1_fits$r_squared[["4PL"]]))
if (!is.null(curve2_fits)) {
  cat(sprintf("  • Curve 2 R²: %.4f\n", curve2_fits$r_squared[["4PL"]]))
}

cat("\n🔬 Experiment:", experiment_id, "\n")
cat("\n================================================================================\n")
cat("                     Analysis powered by ProAI-ELISA                            \n")
cat("                            ProAI.science                                       \n")
cat("              AI-Assisted Scientific Tools for Everyone                         \n")
cat("                 github.com/ProAI-Science/ProAI-ELISA                           \n")
cat("================================================================================\n\n")
