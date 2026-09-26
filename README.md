🇫🇷 [Version française](README_FR.md)

# 🚗 Road Accidents in France — Analysis & Dashboard

> Exploring 15 years of injury accidents to identify risk factors and key trends.

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-2.0+-150458?logo=pandas&logoColor=white)
![Looker Studio](https://img.shields.io/badge/Looker%20Studio-Dashboard-4285F4?logo=google&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📋 Context

Every year in France, tens of thousands of injury accidents are recorded by law enforcement. This data, published as open data on [data.gouv.fr](https://www.data.gouv.fr/fr/datasets/bases-de-donnees-annuelles-des-accidents-corporels-de-la-circulation-routiere/), represents an underexploited wealth of information.

This project transforms raw data — spread across 4 annual files with heterogeneous variables — into **actionable insights** on risk factors: temporal, geographic, and user profiles.

## 🎯 Objectives

- Clean and consolidate 15 years of accident data (2009–2023)
- Identify major risk factors (temporal, weather, infrastructure)
- Highlight geographic disparities (departments, municipalities)
- Build an interactive Looker Studio dashboard for data exploration

## 🔧 Tech Stack

| Tool | Usage |
|------|-------|
| **Python 3.10+** | Main language |
| **Pandas** | Data manipulation and cleaning |
| **Plotly / Seaborn** | Exploratory visualizations |
| **SQLite + SQL** | Structured KPI querying |
| **Looker Studio** | Final interactive dashboard |

## 📁 Project Structure

```
01-road-accidents-france/
├── README.md                          ← This file
├── README_FR.md                       ← French version
├── requirements.txt                   ← Python dependencies
├── .gitignore                         ← Files excluded from versioning
├── LICENSE                            ← MIT License
├── data/
│   ├── README.md                      ← Download instructions
│   ├── download_data.py               ← Automatic download script
│   ├── raw/                           ← Raw data (gitignored)
│   ├── processed/                     ← Cleaned data (gitignored)
│   └── sample/                        ← Sample for testing
├── notebooks/
│   └── 01_nettoyage_exploration.ipynb  ← Main notebook
├── sql/
│   └── queries_kpis.sql               ← SQL queries for KPIs
├── assets/                            ← Dashboard screenshots
└── scripts/
    └── security_check.sh              ← Pre-push verification
```

## 🚀 Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/DiogoA78/01-road-accidents-france.git
cd 01-road-accidents-france
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Download the data

```bash
python data/download_data.py
```

> Data is downloaded from [data.gouv.fr](https://www.data.gouv.fr/fr/datasets/bases-de-donnees-annuelles-des-accidents-corporels-de-la-circulation-routiere/).
> See [`data/README.md`](data/README.md) for manual download.

### 4. Launch the notebook

```bash
jupyter notebook notebooks/01_nettoyage_exploration.ipynb
```

## 📊 Results Overview

> *Dashboard screenshots and key visuals will be added here after completion.*

### 📊 Interactive Dashboard

> [🔗 View the dashboard on Looker Studio](https://datastudio.google.com/reporting/8be64b29-5b0f-4505-a12e-3650e3cf43af)

The dashboard allows data exploration through 4 pages:
- **Overview** — KPIs, yearly trends, map of France
- **Temporal Analysis** — by hour, month, day of the week
- **Risk Factors** — lighting, weather, road type, surface
- **User Profiles** — age, gender, category

Available filters: year, department, severity.

### Key KPIs

| Metric | Value |
|--------|-------|
| Accidents analyzed | ~1M over 15 years |
| Period covered | 2009 – 2023 |
| Variables used | 40+ |

## 📝 Methodology

1. **Collection & Cleaning** — Aggregation of 4 annual files (characteristics, locations, vehicles, users). Recoding of categorical variables, handling missing values, joins.
2. **Exploratory Analysis** — Temporal distributions, bivariate analyses (severity × weather, road type, lighting), mapping of accident-prone areas.
3. **SQL Querying** — Structured KPIs: mortality trends, severity rate by department, at-risk profiles.
4. **Looker Studio Dashboard** — Interactive dashboard with dynamic filters and key visuals.

## 📄 Data Source

- **Database of road traffic injury accidents**
- Publisher: French Ministry of the Interior
- License: Open Licence
- URL: [data.gouv.fr](https://www.data.gouv.fr/fr/datasets/bases-de-donnees-annuelles-des-accidents-corporels-de-la-circulation-routiere/)

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
