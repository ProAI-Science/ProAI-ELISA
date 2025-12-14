# ProAI-ELISA

**AI-Assisted ELISA Analysis Tool with GraphPad Prism Export**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-4.0+-blue.svg)](https://www.r-project.org/)
[![Status](https://img.shields.io/badge/Status-Beta-orange.svg)]()

---

## 🎯 What is ProAI-ELISA?

ProAI-ELISA is an open-source R-based toolkit that automates ELISA (Enzyme-Linked Immunosorbent Assay) data analysis and seamlessly exports results to GraphPad Prism format. Built with AI assistance as part of the [ProAI.science](https://proai.science) initiative, this tool bridges wet-lab biology and computational analysis.

### ✨ Key Features

- **📊 Automated ELISA Analysis**
  - 4-parameter logistic (4PL) curve fitting
  - Multiple curve comparison (4PL, Linear, Semi-log, Log-log)
  - Automatic concentration calculation with dilution correction
  - Technical replicate averaging with statistics
  - Handles singlets, duplicates, and triplicates

- **🔄 GraphPad Prism Export**
  - One-click export to Prism-ready CSV format
  - Automatic data transposition for Column tables
  - Handles duplicate samples at different dilutions
  - Preserves all replicate information

- **📈 Publication-Ready Outputs**
  - High-quality standard curve plots
  - Sample concentration bar charts with error bars
  - Comprehensive CSV data exports
  - Professional formatting

---

## 🚀 Quick Start

### Prerequisites

- R (version 4.0 or higher)
- Required R packages: `dplyr`, `tidyr`, `ggplot2`, `readxl`, `minpack.lm`
- GraphPad Prism (for visualization)

### Installation

1. **Clone or download this repository:**
```bash
git clone https://github.com/ProAI-Science/ProAI-ELISA.git
```

2. **Install required R packages:**
```r
install.packages(c("dplyr", "tidyr", "ggplot2", "readxl", "minpack.lm"))
```

3. **You're ready to go!** 🎉

See [docs/INSTALLATION.md](docs/INSTALLATION.md) for detailed installation instructions.

---

## 📖 Usage

### Basic Workflow

1. **Prepare your ELISA data** in Excel format (see [examples/](examples/) for template)
2. **Run ProAI-ELISA analysis:**
   ```r
   source("ProAI-ELISA_v0.1.0.R")
   ```
3. **Export to Prism format:**
   ```r
   source("ProAI-ELISA_Prism_Export_v0.3.0.R")
   ```
4. **Import into GraphPad Prism** and create publication-ready figures!

See [docs/USAGE.md](docs/USAGE.md) for detailed usage instructions and [docs/PRISM_IMPORT_GUIDE.md](docs/PRISM_IMPORT_GUIDE.md) for Prism import steps.

---

## 📁 Repository Structure

```
ProAI-ELISA/
├── README.md                          # This file
├── LICENSE                            # MIT License
├── ProAI-ELISA_v0.1.0.R              # Main ELISA analysis script
├── ProAI-ELISA_Prism_Export_v0.3.0.R # Prism export tool
├── examples/
│   └── Synthetic_ELISA_Standard_Format.xlsx  # Example dataset
└── docs/
    ├── INSTALLATION.md                # Installation guide
    ├── USAGE.md                       # Usage guide
    └── PRISM_IMPORT_GUIDE.md          # Prism import instructions
```

---

## 🧪 Example Data

The `examples/` folder contains a synthetic ELISA dataset that demonstrates:
- Standard curve (1000 → 0 pg/mL, 1:2 serial dilution)
- 33 unique samples with mixed replicates
- Different dilution factors (1:2, 1:5, 1:10, 1:20)
- Edge cases (same sample at different dilutions)

**This dataset contains 100% synthetic data - no proprietary information!**

---

## 🎓 How It Works

### ProAI-ELISA Analysis Pipeline

1. **Data Import:** Reads Excel files with plate layout
2. **Standard Curve Fitting:** 4PL regression with R² reporting
3. **Concentration Calculation:** Back-calculates sample concentrations
4. **Dilution Correction:** Automatically applies dilution factors
5. **Replicate Averaging:** Calculates mean ± SD for technical replicates
6. **Visualization:** Generates publication-quality plots

### Prism Export Pipeline

1. **Format Detection:** Identifies experiment ID and file structure
2. **Data Transposition:** Converts to Prism Column table format
3. **Duplicate Handling:** Appends dilution factors to duplicate sample IDs
4. **CSV Generation:** Creates three Prism-ready files:
   - Standards (for curve fitting)
   - Samples Averaged (for bar charts)
   - Samples Individual (for replicate analysis)

---

## 📊 Output Files

### From ProAI-ELISA Analysis:

- `[ExpID]_Standard_Curve_1.pdf` - Standard curve plot
- `[ExpID]_Sample_Concentrations_Curve1.pdf` - Sample concentration bar chart
- `[ExpID]_Standard_Curves_Averaged.csv` - Averaged standard data
- `[ExpID]_Sample_Results_Averaged.csv` - Final sample concentrations
- `[ExpID]_Sample_Wells_Individual_Wide.csv` - Individual replicate values
- And more...

### From Prism Export:

- `[ExpID]_Prism_Standards.csv` - For standard curve plotting in Prism
- `[ExpID]_Prism_Samples_Averaged.csv` - For bar charts (Mean ± SD)
- `[ExpID]_Prism_Samples_Individual.csv` - For replicate analysis

---

## 🤝 Contributing

Contributions are welcome! This is an open-source project built to help the scientific community.

**Ways to contribute:**
- Report bugs or suggest features via [Issues](https://github.com/ProAI-Science/ProAI-ELISA/issues)
- Submit pull requests with improvements
- Share your use cases and feedback

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**TL;DR:** You can use, modify, and distribute this software freely, even for commercial purposes. Just keep the license notice!

---

## 🙏 Acknowledgments

- **Built with AI assistance** from Claude (Anthropic) as part of the ProAI.science initiative
- **Developed by:** Geoff ([@geoffpro](https://github.com/geoffpro))
- **Platform:** [ProAI.science](https://proai.science) - AI-Assisted Scientific Tools for Everyone

---

## 📬 Contact

- **GitHub:** [@ProAI-Science](https://github.com/ProAI-Science)
- **Website:** [ProAI.science](https://proai.science)
- **Issues:** [Report a bug or request a feature](https://github.com/ProAI-Science/ProAI-ELISA/issues)

---

## ⭐ Star This Repository!

If ProAI-ELISA helps your research, please consider starring this repository! It helps others discover the tool.

---

**Happy analyzing!** 🧬📊✨
