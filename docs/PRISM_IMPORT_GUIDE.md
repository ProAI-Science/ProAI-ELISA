# GraphPad Prism Import Guide

## Overview

ProAI-ELISA generates three Prism-ready CSV files that can be imported directly into GraphPad Prism for publication-quality figures. This guide walks you through the import process step-by-step.

---

## Before You Start

Make sure you've run both:
1. ✅ **ProAI-ELISA_v0.1.0.R** (analysis)
2. ✅ **ProAI-ELISA_Prism_Export_v0.3.0.R** (Prism export)

You should have three files:
- `[ExpID]_Prism_Standards.csv`
- `[ExpID]_Prism_Samples_Averaged.csv`
- `[ExpID]_Prism_Samples_Individual.csv`

---

## File 1: Standards (For Standard Curves)

### Step 1: Create New XY Table in Prism

1. Open GraphPad Prism
2. Click **"New"**
3. Choose **"XY"** table type
4. Click **"Create"**

### Step 2: Import Standards CSV

1. Go to **File → Import → CSV**
2. Select `[ExpID]_Prism_Standards.csv`
3. In the import dialog:
   - **Source tab:**
     - ✅ "Commas" → **"To separate adjacent columns"**
   - **Placement tab:**
     - ✅ "Column titles:" → **"Use values in row 1"**
     - ✅ "Maintain row and column arrangement"
   - Click **"Import"**

### Step 3: Create Standard Curve Graph

1. Click **"Analyze"**
2. Choose **XY Analysis → Nonlinear regression**
3. Select **"4PL"** or **"log(agonist) vs. response"**
4. Click **"OK"**
5. Prism will fit your standard curve!

**Result:** You'll have a publication-ready standard curve with R² value.

---

## File 2: Samples (Averaged) - For Bar Charts

### Step 1: Create Column Table (Paired/Repeated Measures)

1. Open GraphPad Prism (or create new project)
2. Click **"New"**
3. Choose **"Column"** table type
4. Select **"Enter paired or repeated measures data - each subject on a separate row"**
5. Click **"Create"**

### Step 2: Import Averaged Samples CSV

1. Go to **File → Import → CSV**
2. Select `[ExpID]_Prism_Samples_Averaged.csv`
3. In the import dialog:
   - **Source tab:**
     - ✅ "Commas" → **"To separate adjacent columns"**
   - **Placement tab:**
     - ✅ "Column titles:" → **"Use values in row 1"**
     - ✅ "Row and Column Arrangement:" → **"Maintain row and column arrangement"**
     - ✅ "Empty rows:" → **"Skip over that row"**
   - Click **"Import"**

### Step 3: Create Bar Chart

1. Click **"Graphs"** tab
2. The bar chart should automatically appear!
3. Customize as needed:
   - Right-click graph → **Format Graph**
   - Change colors, add error bars, adjust labels

**Result:** Bar chart showing Mean ± SD for each sample.

---

## File 3: Samples (Individual) - For Replicate Analysis

### Step 1: Create Column Table (Paired/Repeated Measures)

1. Open GraphPad Prism (or create new project)
2. Click **"New"**
3. Choose **"Column"** table type
4. Select **"Enter paired or repeated measures data - each subject on a separate row"**
5. Click **"Create"**

### Step 2: Import Individual Samples CSV

1. Go to **File → Import → CSV**
2. Select `[ExpID]_Prism_Samples_Individual.csv`
3. In the import dialog:
   - **Source tab:**
     - ✅ "Commas" → **"To separate adjacent columns"**
   - **Placement tab:**
     - ✅ "Column titles:" → **"Use values in row 1"**
     - ✅ "Row and Column Arrangement:" → **"Maintain row and column arrangement"**
     - ✅ "Empty rows:" → **"Skip over that row"**
   - Click **"Import"**

### Step 3: Analyze & Graph

**For bar charts with individual points:**
1. Click **"Graphs"** tab
2. Choose **"Column"** graph type
3. Format graph:
   - Right-click → **Format Graph**
   - **Show individual values:** → Select **"All individual values"**
   - This will show bars with individual data points overlaid

**For statistical analysis:**
1. Click **"Analyze"**
2. Choose appropriate test:
   - **One-way ANOVA** (comparing multiple groups)
   - **t-test** (comparing two groups)
   - **Repeated measures ANOVA** (paired samples)
3. Prism will calculate statistics and create graphs!

**Result:** Publication-ready graphs with individual replicate data points and statistics.

---

## Import Settings Quick Reference

### Critical Settings for All Imports

**Source Tab:**
- ✅ **Commas:** "To separate adjacent columns" (NOT "To delineate thousands")

**Placement Tab:**
- ✅ **Column titles:** "Use values in row 1"
- ✅ **Row and Column Arrangement:** "Maintain row and column arrangement of the data source"
- ✅ **Empty rows:** "Skip over that row"

---

## Troubleshooting

### "Data importing into one column"

**Problem:** All data appears in Column A

**Solution:** 
- Go back to import dialog
- **Source tab:** Change "Commas" to **"To separate adjacent columns"**
- Re-import

### "Sample names appearing as numbers"

**Problem:** Sample IDs like "CMPD_A_01" become "2.000000"

**Solution:**
- Make sure you selected **"Column"** table type (not XY)
- Make sure you chose **"paired or repeated measures"** option
- Check **Placement tab:** "Use values in row 1" for column titles

### "Empty rows in my data table"

**Solution:**
- In import dialog, **Placement tab**
- **Empty rows:** Select **"Skip over that row"**
- Re-import

### "Graph not appearing automatically"

**Solution:**
- Click the **"Graphs"** tab manually
- If still no graph, try:
  - **New → Graph** 
  - Choose appropriate graph type
  - Select your data table

---

## Creating Publication-Ready Figures

### Standard Curve

1. **Import standards** (File 1)
2. **Fit 4PL curve** (Analyze → Nonlinear regression)
3. **Format graph:**
   - Double-click graph → Format
   - Add axis labels: "Concentration (pg/mL)", "Absorbance (450 nm)"
   - Add R² value to graph (it's in the analysis results)
   - Adjust colors and symbols for visibility

### Sample Concentration Bar Chart

1. **Import averaged samples** (File 2)
2. **Format graph:**
   - Change bar colors
   - Add error bars (should be automatic)
   - Rotate X-axis labels if needed
   - Add Y-axis label: "Concentration (pg/mL)"

### Sample Scatter Plot with Statistics

1. **Import individual samples** (File 3)
2. **Run statistics** (Analyze → appropriate test)
3. **Format graph:**
   - Show individual points
   - Add mean bars
   - Add significance stars (from analysis)

---

## Pro Tips

### Customization
- **Colors:** Double-click graph → Format → Colors & Symbols
- **Fonts:** Format → Text & Fonts
- **Axis ranges:** Format → Axes → Axis Range
- **Legend:** Format → Legend

### Saving Prism Files
- Save your Prism project: **File → Save As**
- Export graphs: **File → Export → Export Graph**
- Choose format: PDF, TIFF, PNG (journals usually want TIFF or PDF)

### Batch Analysis
If you have multiple experiments:
1. Import all datasets into one Prism file (separate tables)
2. Create a family of graphs
3. Apply consistent formatting across all graphs
4. Export all at once

---

## Example Workflow

Here's a typical start-to-finish workflow:

1. **Run ELISA** → Generate Excel file
2. **ProAI-ELISA analysis** → Get concentrations
3. **Prism export** → Generate 3 CSV files
4. **Import Standards** → Create standard curve
5. **Import Individual Samples** → Create bar chart with points
6. **Run statistics** → ANOVA or t-test
7. **Format graphs** → Publication quality
8. **Export** → TIFF files for manuscript

**Total time:** ~10 minutes after you've run the ELISA! 🚀

---

## Need Help?

- **Prism Help:** [GraphPad Support](https://www.graphpad.com/support/)
- **ProAI-ELISA Issues:** [GitHub Issues](https://github.com/ProAI-Science/ProAI-ELISA/issues)
- **Community:** Ask questions in the Issues section!

**Happy graphing!** 📊✨
