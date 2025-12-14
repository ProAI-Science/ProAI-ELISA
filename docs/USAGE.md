# Usage Guide

## Table of Contents
1. [Data Preparation](#data-preparation)
2. [Running ProAI-ELISA Analysis](#running-proai-elisa-analysis)
3. [Exporting to Prism](#exporting-to-prism)
4. [Understanding the Outputs](#understanding-the-outputs)
5. [Tips & Best Practices](#tips--best-practices)

---

## Data Preparation

### Required Excel Format

ProAI-ELISA expects your ELISA data in a specific Excel format. See `examples/Synthetic_ELISA_Standard_Format.xlsx` for a complete example.

### Excel File Structure

**Your Excel file needs these columns:**

| Column | Description | Example |
|--------|-------------|---------|
| `Well` | Well position (A1, A2, etc.) | A1 |
| `Sample_Type` | "Standard" or "Sample" | Standard |
| `Sample_ID` | Unique identifier | STD or CMPD_A_01 |
| `Concentration` | Known concentration (for standards only) | 1000 |
| `Absorbance` | Measured OD value | 2.234 |
| `Dilution` | Dilution factor (e.g., 2 for 1:2) | 2 |
| `Unit` | Concentration unit | pg/mL |
| `Experiment_ID` | Unique experiment name | TEST_001 |

### Example Rows

**Standards:**
```
Well  Sample_Type  Sample_ID  Concentration  Absorbance  Dilution  Unit    Experiment_ID
A1    Standard     STD        1000           2.234       1         pg/mL   SYNTH_TEST_001
A2    Standard     STD        1000           2.225       1         pg/mL   SYNTH_TEST_001
B1    Standard     STD        500            2.078       1         pg/mL   SYNTH_TEST_001
B2    Standard     STD        500            1.983       1         pg/mL   SYNTH_TEST_001
```

**Samples:**
```
Well  Sample_Type  Sample_ID   Concentration  Absorbance  Dilution  Unit    Experiment_ID
C1    Sample       CMPD_A_01   NA             1.808       2         pg/mL   SYNTH_TEST_001
C2    Sample       CMPD_A_01   NA             1.882       2         pg/mL   SYNTH_TEST_001
D1    Sample       CMPD_B_01   NA             2.098       5         pg/mL   SYNTH_TEST_001
```

### Key Points

✅ **Standards must have known concentrations**
✅ **Samples have `NA` for concentration** (will be calculated)
✅ **Each technical replicate is a separate row**
✅ **Dilution factor must be specified** (use 1 for undiluted)
✅ **All samples from one experiment share the same Experiment_ID**

---

## Running ProAI-ELISA Analysis

### Step 1: Open RStudio

1. Launch RStudio
2. Open the script: `ProAI-ELISA_v0.1.0.R`

### Step 2: Run the Script

**Method 1: Source the entire script**
- Click the **"Source"** button (top right of script pane)
- Or press `Ctrl+Shift+S` (Windows/Linux) or `Cmd+Shift+S` (Mac)

**Method 2: Run line by line**
- Place cursor on a line
- Press `Ctrl+Enter` (Windows/Linux) or `Cmd+Enter` (Mac)

### Step 3: Select Your Data File

A file picker dialog will appear:
1. Navigate to your Excel file
2. Click **"Open"**

### Step 4: Wait for Analysis

The script will:
- ✅ Read your data
- ✅ Fit standard curves (4PL regression)
- ✅ Calculate sample concentrations
- ✅ Average technical replicates
- ✅ Generate plots
- ✅ Export CSV files

**Progress updates will appear in the R console.**

### Step 5: Review Outputs

Check your working directory for:
- PDF plots (standard curves, sample concentrations)
- CSV files (detailed results)

---

## Exporting to Prism

### Step 1: Run ProAI-ELISA First

Make sure you've completed the analysis above and have the output CSV files.

### Step 2: Run the Prism Export Script

1. Open `ProAI-ELISA_Prism_Export_v0.3.0.R` in RStudio
2. Click **"Source"** or press `Ctrl+Shift+S`

### Step 3: Select Output Folder

A file picker will appear:
1. Navigate to the folder containing your ProAI-ELISA output files
2. Select **ANY file** in that folder (the script uses the folder, not the file)
3. Click **"Open"**

### Step 4: Export Complete!

The script will create three Prism-ready CSV files:
- `[ExpID]_Prism_Standards.csv`
- `[ExpID]_Prism_Samples_Averaged.csv`
- `[ExpID]_Prism_Samples_Individual.csv`

---

## Understanding the Outputs

### From ProAI-ELISA Analysis

#### PDF Plots

**`[ExpID]_Standard_Curve_1.pdf`**
- Standard curve with 4PL fit
- Shows R² value and curve comparison
- Black points = averaged standards with error bars
- Red line = 4PL fit (primary)
- Other lines = alternative fits (linear, log-log, semi-log)

**`[ExpID]_Sample_Concentrations_Curve1.pdf`**
- Bar chart of all sample concentrations
- Error bars show SD of technical replicates
- Black dots = individual replicate values
- Different colors = different sample groups

#### CSV Files

**`[ExpID]_Standard_Curves_Averaged.csv`**
```
Concentration, Curve, Unit, Absorbance_Mean, Absorbance_SD, n
1000, Curve1, pg/mL, 2.229, 0.076, 2
500, Curve1, pg/mL, 2.030, 0.048, 2
```

**`[ExpID]_Sample_Results_Averaged.csv`**
```
Sample_ID, Curve, Dilution, Calculated_Conc_Mean, Final_Concentration, Final_Conc_SD, n_replicates
CMPD_A_01, Curve1, 2, 328.58, 657.17, 71.16, 2
```
- `Calculated_Conc_Mean` = concentration from standard curve
- `Final_Concentration` = calculated concentration × dilution factor
- `Final_Conc_SD` = propagated error

**`[ExpID]_Sample_Wells_Individual_Wide.csv`**
- Individual replicate values
- One row per sample
- Columns: Sample_ID, Absorbance_1, Absorbance_2, etc.

### From Prism Export

**`[ExpID]_Prism_Standards.csv`**
- Format: XY table (for curve fitting in Prism)
- Column 1: Concentration
- Columns 2+: Standard replicates

**`[ExpID]_Prism_Samples_Averaged.csv`**
- Format: Transposed (samples as columns)
- Row 1: Sample names
- Row 2: Mean concentrations
- Row 3: SD values

**`[ExpID]_Prism_Samples_Individual.csv`**
- Format: Transposed (samples as columns)
- Row 1: Sample names
- Rows 2+: Individual replicate values

---

## Tips & Best Practices

### Data Quality

✅ **Run standards in duplicate or triplicate** for better curve fitting
✅ **Include a full standard curve** (at least 7-8 points covering your sample range)
✅ **Use consistent dilution factors** when possible
✅ **Check your plate layout** before running the assay

### Dilution Strategy

- **Start with 1:2 dilution** for unknown samples
- **Run multiple dilutions** for samples with unknown concentration ranges
- **Keep samples within the standard curve range** for best accuracy

### Technical Replicates

- **Duplicates are minimum**, triplicates are better
- **High variability (CV > 20%)?** Check pipetting technique or sample prep
- **Outliers?** ProAI-ELISA includes all replicates - you can manually remove outliers in Excel before analysis

### Experiment IDs

- Use **descriptive, unique IDs**: `EXP_001`, `IL22_DOSE_RESP_2024_12_15`
- **Avoid spaces** in Experiment_ID
- All samples from one plate should have the **same Experiment_ID**

### File Organization

Create a folder structure:
```
ELISA_Project/
├── raw_data/
│   ├── experiment_001.xlsx
│   ├── experiment_002.xlsx
├── analysis/
│   ├── experiment_001_outputs/
│   ├── experiment_002_outputs/
└── prism/
    ├── experiment_001_prism_files/
```

### Troubleshooting

**"Standard curve fit failed"**
- Check that you have at least 6 standard points
- Make sure concentration values are correct
- Verify absorbance values are reasonable (not all zeros)

**"No samples found"**
- Check `Sample_Type` column spelling ("Sample" not "sample")
- Make sure samples have `NA` in Concentration column

**"Duplicate row names error"** in Prism export
- This happens when the same sample ID appears at different dilutions
- ProAI-ELISA automatically handles this by appending dilution factors
- Example: `CMPD_A_01_2x` and `CMPD_A_01_10x`

**High CV% on replicates**
- Check pipetting technique
- Ensure proper mixing of samples
- Verify plate reader is functioning correctly

---

## Next Steps

1. **Import into Prism**: See [PRISM_IMPORT_GUIDE.md](PRISM_IMPORT_GUIDE.md)
2. **Customize plots**: Edit the R scripts to change colors, labels, etc.
3. **Batch processing**: Analyze multiple experiments by running the script multiple times

**Questions?** [Open an issue on GitHub!](https://github.com/ProAI-Science/ProAI-ELISA/issues)
