# rk.rstatix: Modern & Robust Statistics for RKWard

![Version](https://img.shields.io/badge/Version-0.0.1-blue.svg)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.rstatix/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.rstatix/actions/workflows/lintr.yml)
![AI Gemini](https://img.shields.io/badge/AI-Gemini-4285F4?logo=googlegemini&logoColor=white)

**A Modern RKWard GUI Plugin for Robust Statistical Tests using the `rstatix` Package**

`rk.rstatix` brings the power of "Tidy" statistics to the RKWard graphical interface. By leveraging the popular [`rstatix`](https://rpkgs.datanovia.com/rstatix/) package, this plugin bypasses the messy text outputs of base R, providing researchers with clean, pipe-friendly, and publication-ready HTML tables. It focuses on filling critical methodological gaps in standard statistical software, such as handling unequal variances, adjusting for covariates, and diagnosing extreme outliers.

---

## 🌟 Key Features

* **"Tidy" Results:** All statistical tests automatically return `tibble` data frames, which RKWard renders into beautiful, Excel-ready HTML tables.
* **Robust Methodologies:** Easily perform tests that do not assume equal variances (heteroscedasticity), which is the reality of most experimental data.
* **"Auto-Focus" Magic UI:** The user interface features smart variable selectors. When you select a dataset, the available variables list instantly filters to show *only* the columns within that specific dataframe.
* **Safe R Code Generation:** Uses isolated Javascript parsing to protect column names with special characters and avoid namespace collisions.
* **Multilingual:** Fully translated into English, Spanish, French, German, and Portuguese (Brazil).

---

## What's New in Version 0.0.1

**🚀 Initial Release: The Psychology & Social Sciences Toolkit**

This first release introduces three highly-requested analytical modules that are traditionally tedious to code by hand:
*   **Welch ANOVA & Games-Howell:** The gold standard for one-way comparisons when Levene's test fails. Includes automatic Eta-Squared ($\eta^2$) effect size calculation and dynamic list-saving capabilities.
*   **ANCOVA (Analysis of Covariance):** Control for one or multiple continuous confounding variables. Automatically calculates and compares Estimated Marginal Means (EMMeans) with Bonferroni adjustments.
*   **Outlier Diagnostics:** Quickly identify mild ($1.5 \times IQR$) or extreme ($3 \times IQR$) univariate outliers grouped by experimental conditions, helping you clean your data before parametric testing.

---

## ⚙️ Prerequisites

You must have [RKWard](https://rkward.kde.org/) installed along with the following R packages. The plugin will automatically load them when required:

```R
install.packages(c("rstatix", "dplyr"))
```

---

## 🚀 Installation

You can install this plugin directly from GitHub using `remotes` inside your RKWard console:

```R
# Install the plugin
library("remotes")
install_github("AlfCano/rk.rstatix")
```

Once installed, restart RKWard, navigate to **Settings -> Configure RKWard -> Plugins**, and ensure `rk.rstatix` is activated.

---

## 🛠️ Usage Workflow

This plugin adds three new powerful tools to your RKWard menus:

### 1. Robust ANOVA (Welch & Games-Howell)
*Located under: **Analysis ➔ Means***
*   **The Problem:** Standard Fisher ANOVA assumes equal variances across groups. If violated, Type I error rates inflate.
*   **The Solution:** Select your Dependent Variable and Grouping Factor. The plugin calculates a Welch ANOVA.
*   **Options:** Automatically append the $\eta^2$ effect size and compute the Games-Howell post-hoc test. Save all generated tables directly into a single organized List object in your R workspace.

### 2. ANCOVA (Analysis of Covariance)
*Located under: **Analysis ➔ Psychology / Social Science ➔ Frequentist***
*   **The Problem:** You need to evaluate the effect of a categorical treatment while controlling for pre-existing continuous covariates (e.g., age, baseline anxiety).
*   **The Solution:** Input your DV, Grouping Factor, and select one or more Covariates.
*   **Options:** Extract Estimated Marginal Means (EMMeans) adjusted for the covariates, and perform Bonferroni-corrected pairwise comparisons.

### 3. Identify Outliers
*Located under: **Analysis ➔ Psychology / Social Science ➔ Frequentist***
*   **The Problem:** Reviewers often demand proof that your data doesn't contain extreme outliers before running parametric tests.
*   **The Solution:** Select a numeric variable and an optional grouping factor. The plugin will output a table containing *only* the anomalous participants.
*   **Options:** Toggle between identifying all outliers (beyond $1.5 \times IQR$) or strictly EXTREME outliers (beyond $3 \times IQR$).

---

## 🌍 Internationalization (i18n)

The graphical interface automatically adapts to your RKWard language settings. Currently supported languages:
* 🇺🇸 English (Default)
* 🇪🇸 Spanish (Español)
* 🇫🇷 French (Français)
* 🇩🇪 German (Deutsch)
* 🇧🇷 Portuguese (Português do Brasil)

---

## 📝 License and Author

**Author:** Alfonso Cano ([@AlfCano](https://github.com/AlfCano))  
**Email:** alfonso.cano@correo.buap.mx  
*   **Assisted by:** Gemini, a large language model from Google.
*   **License:** GPL (>= 3)

This project is licensed under the **GPL (>= 3)** License.
