# Heart Disease Risk Prediction & Patient Clustering (R)

## Business Problem
Cardiovascular disease is a leading cause of mortality, making early risk identification critical for healthcare providers and insurers to prioritize screenings and allocate clinical resources effectively[cite: 4]. 

Using clinical and demographic records from **1,025 patients** (deduplicated to **302 unique patient profiles** across four clinical sites), this project evaluates supervised classification models and unsupervised clustering in **R** to identify key physiological predictors of heart disease[cite: 4].

## Methodology & Key Findings
* **Data Cleaning & Deduplication:** Identified and removed 723 exact duplicate records (70.5% of the raw file) to prevent data leakage between training and test splits, and properly factored 8 categorical clinical indicators (`cp`, `thal`, `ca`, `slope`, etc.)[cite: 4].
* **Exploratory Data Analysis (`ggplot2` / `corrplot`):** Discovered that **maximum heart rate achieved (`thalach`)** and **chest pain type (`cp`)** provided far stronger separation between diagnosed and healthy patients than traditional standalone indicators like age or cholesterol[cite: 4].
* **Supervised Classification (75/25 Train-Test Split):** Benchmarked a C5.0 Decision Tree against a Naive Bayes classifier across all 13 clinical predictors[cite: 4]:

| Evaluation Metric | Decision Tree (C5.0) | Naive Bayes |
| :--- | :---: | :---: |
| **Accuracy** | 76.3%[cite: 4] | **85.5%**[cite: 4] |
| **Sensitivity (Recall / TPR)** | 86.8%[cite: 4] | **97.4%**[cite: 4] |
| **Specificity (TNR)** | 65.8%[cite: 4] | **73.7%**[cite: 4] |
| **Precision** | 71.7%[cite: 4] | **78.7%**[cite: 4] |
| **F1 Score** | 78.6%[cite: 4] | **87.1%**[cite: 4] |

* **Unsupervised Segmentation (K-Means Clustering):** Standardized continuous clinical variables and applied the elbow method ($k = 3$)[cite: 4]. Cluster 3 (younger patients with the highest maximum heart rates) exhibited a **76% heart disease prevalence**, independently confirming the predictive findings[cite: 4].

## Visual Highlights
![Correlation Matrix](images/correlation_matrix.png)
![Chest Pain Type by Heart Disease Status](images/chest_pain_by_status.png)

## Repository Contents
* `heart_disease_classification.R` — Complete R script for preprocessing, deduplication, `ggplot2` visualizations, C5.0 Decision Tree, Naive Bayes, and K-Means clustering[cite: 34].
* `Heart_Disease_Data_Mining_Report.pdf` — Full technical report with statistical summaries, clinical interpretations, and limitations[cite: 4].
* `data/heart.csv` — Source clinical dataset[cite: 4, 34].
