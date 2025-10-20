# 🏍️ Motorcycle Parts Sales Analysis

## Project Overview
This project explores sales data for motorcycle parts to uncover insights into performance across different **client types** and **warehouse locations**. The dataset contains detailed transaction records, including order dates, product types, quantities, and more.
The analysis was performed using **SQL** and **R**, using an in-memory SQLite database for fast querying and R's powerful visualization and reporting tools.

The final report is available online at:
- https://mu-05.github.io/posts/2025-09-15-motorcycle-parts-sales/

## Data Source
The dataset used in this project was downloaded on 2025-09-16 from a DataCamp lesson titled [Analyzing Motorcycle Part Sales](https://app.datacamp.com/learn/projects/1574).

## Objectives
- Analyze sales performance by **region** and **warehouse**
- Identify which **client types** generate the most revenue
- Provide **data-driven recommendations** for improving sales strategy

## Tools & Technologies
- SQLite – for querying structured sales data
- R:
  - DBI – used to build and manage an in-memory SQLite database
  - dplyr – for efficient data wrangling and transformation
  - ggplot2 – for creating insightful visualizations
- Quarto – to generate a clean, shareable HTML report

## Repository Structure
```plaintext
motorcycle-parts-sales/
│
├── data/
│   └── sales.csv                           # Raw sales dataset
│
├── scripts/
│   └── 01_load_packages.R                  # Load required packaged
│   └── 02_load_data.R                      # Import data from CSV
│   └── 03_validate_data.R                  # Basic validation checks
│   └── 04_clean_data.R                     # Transform order date column
│   └── 05_setup_database.R                 # SQLite database setup
│   └── 06a_exploratory_net_revenue.R       # Net revenue analysis
│   └── 06b_exploratory_revenue_growth.R    # Revenue Growth analysis
│   └── 07_close_database.R                 # Close SQLite connection
│
├── reports/
│   └── sales-analysis.qmd                  # Quarto report file
│   └── sales-analysis.html                 # Rendered HTML report
│   └── sales-analysis_files/               # Supporting files for report output
│
├── README.md                               # Project overview
├── .gitignore                              # Files to ignore in Git
└── motorcycle-parts-sales.Rproj            # RStudio project file
```

## How to use ?
If you’d like to explore the project in more detail or run it locally, follow these steps:
1. **Download** a ZIP copy of the repository by clicking the green "**Code**" button at the top right and selecting "**Download ZIP**".
2. **Extract** the ZIP file on your computer.
3. **Open** the `motorcycle-parts-sales.Rproj` file (make sure you have **R** and **RStudio** installed).
4. **Explore** the files in the `scripts/` folder to understand the exploratory data analysis workflow.
5. **Open** the `sales-analysis.qmd` file (in the `reports/` folder) to see how the final report was built using Quarto.

## Note: Installing Required Packages
To run the scripts or render the Quarto report, make sure the following R packages are installed:
```r
install.packages(c("DBI", "RSQLite", "tidyverse", "scales"))
```
