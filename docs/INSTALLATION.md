# Installation Guide

## System Requirements

### Minimum Requirements
- **Operating System:** Windows, macOS, or Linux
- **R Version:** 4.0 or higher
- **RAM:** 4 GB minimum (8 GB recommended)
- **Disk Space:** 100 MB for software + space for your data

### Software Requirements
- **R** (Required)
- **RStudio** (Recommended but optional)
- **GraphPad Prism** (For visualization, optional)

---

## Step 1: Install R

### Windows
1. Go to [https://cran.r-project.org/](https://cran.r-project.org/)
2. Click "Download R for Windows"
3. Click "base"
4. Download and run the installer
5. Follow the installation wizard (default settings are fine)

### macOS
1. Go to [https://cran.r-project.org/](https://cran.r-project.org/)
2. Click "Download R for macOS"
3. Download the appropriate `.pkg` file for your Mac (Intel or Apple Silicon)
4. Run the installer
5. Follow the installation wizard

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install r-base
```

**Verify installation:**
Open a terminal/command prompt and type:
```bash
R --version
```

---

## Step 2: Install RStudio (Recommended)

RStudio makes working with R much easier!

1. Go to [https://posit.co/download/rstudio-desktop/](https://posit.co/download/rstudio-desktop/)
2. Download the free RStudio Desktop version for your operating system
3. Install RStudio
4. Launch RStudio

---

## Step 3: Install Required R Packages

Open R or RStudio and run these commands:

```r
# Install required packages
install.packages(c(
  "dplyr",      # Data manipulation
  "tidyr",      # Data tidying
  "ggplot2",    # Plotting
  "readxl",     # Reading Excel files
  "minpack.lm"  # Nonlinear curve fitting
))
```

**This will take a few minutes.** R will download and install each package.

**Verify installation:**
```r
# Load packages to verify they installed correctly
library(dplyr)
library(tidyr)
library(ggplot2)
library(readxl)
library(minpack.lm)
```

If no errors appear, you're good to go! ✅

---

## Step 4: Download ProAI-ELISA

### Option A: Download ZIP (Easiest for beginners)

1. Go to [https://github.com/ProAI-Science/ProAI-ELISA](https://github.com/ProAI-Science/ProAI-ELISA)
2. Click the green **"Code"** button
3. Click **"Download ZIP"**
4. Extract the ZIP file to a folder on your computer

### Option B: Clone with Git

If you have Git installed:
```bash
git clone https://github.com/ProAI-Science/ProAI-ELISA.git
cd ProAI-ELISA
```

---

## Step 5: Test the Installation

1. **Open RStudio**
2. **Set your working directory** to the ProAI-ELISA folder:
   - In RStudio: Session → Set Working Directory → Choose Directory
   - Or use: `setwd("path/to/ProAI-ELISA")`

3. **Run the example:**
   ```r
   # Open the main script
   file.edit("ProAI-ELISA_v0.1.0.R")
   
   # Click "Source" to run the entire script
   # Or press Ctrl+Shift+S (Windows/Linux) or Cmd+Shift+S (Mac)
   ```

4. **Select the example file** when prompted:
   - Navigate to `examples/Synthetic_ELISA_Standard_Format.xlsx`
   - Click "Open"

5. **Check the output!**
   - You should see plots appear
   - CSV files and PDF plots will be created in your working directory

**If everything works, you're ready to analyze real data!** 🎉

---

## Step 6: Install GraphPad Prism (Optional)

For final visualization and publication-ready figures:

1. Go to [https://www.graphpad.com/](https://www.graphpad.com/)
2. Download GraphPad Prism (free trial or purchase)
3. Install and activate

**Note:** Prism is optional. ProAI-ELISA generates high-quality plots on its own. Prism is just for users who prefer that workflow.

---

## Troubleshooting

### "Package not found" error
Make sure you're connected to the internet and try again:
```r
install.packages("package_name")
```

### "Permission denied" error on Linux/Mac
You may need to install packages with sudo:
```bash
sudo R
# Then run install.packages() commands
```

### RStudio won't open scripts
Make sure you've set the correct working directory to the ProAI-ELISA folder.

### Excel file won't load
Make sure the `readxl` package is installed and loaded:
```r
library(readxl)
```

### Still having issues?
- Check the [GitHub Issues](https://github.com/ProAI-Science/ProAI-ELISA/issues) page
- Submit a new issue with your error message
- We're here to help!

---

## Next Steps

Now that you're set up:
1. Read the [USAGE.md](USAGE.md) guide to learn how to prepare your data
2. Try the example dataset in `examples/`
3. Analyze your own ELISA data!

**Happy analyzing!** 🧬📊
