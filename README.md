# 🚗 Accidentologie routière en France — Analyse & Dashboard

> Explorer 15 ans d'accidents corporels pour identifier les facteurs de risque et les tendances clés.

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-2.0+-150458?logo=pandas&logoColor=white)
![Looker Studio](https://img.shields.io/badge/Looker%20Studio-Dashboard-4285F4?logo=google&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📋 Contexte

Chaque année en France, des dizaines de milliers d'accidents corporels sont enregistrés par les forces de l'ordre. Ces données, publiées en open data sur [data.gouv.fr](https://www.data.gouv.fr/fr/datasets/bases-de-donnees-annuelles-des-accidents-corporels-de-la-circulation-routiere/), constituent une mine d'information encore sous-exploitée.

Ce projet transforme ces données brutes — réparties sur 4 fichiers annuels avec des variables hétérogènes — en **insights actionnables** sur les facteurs de risque : temporels, géographiques, profils usagers.

## 🎯 Objectifs

- Nettoyer et consolider 15 ans de données accidentologiques (2009–2023)
- Identifier les facteurs de risque majeurs (temporels, météo, infrastructure)
- Mettre en évidence les disparités géographiques (départements, communes)
- Construire un dashboard Looker Studio interactif pour l'exploration des données

## 🔧 Stack technique

| Outil | Usage |
|-------|-------|
| **Python 3.10+** | Langage principal |
| **Pandas** | Manipulation et nettoyage des données |
| **Plotly / Seaborn** | Visualisations exploratoires |
| **SQLite + SQL** | Requêtage structuré des KPIs |
| **Looker Studio** | Dashboard interactif final |

## 📁 Structure du projet

```
01-road-accidents-france/
├── README.md                          ← Ce fichier
├── requirements.txt                   ← Dépendances Python
├── .gitignore                         ← Fichiers exclus du versioning
├── LICENSE                            ← Licence MIT
├── data/
│   ├── README.md                      ← Instructions de téléchargement
│   ├── download_data.py               ← Script de téléchargement automatique
│   ├── raw/                           ← Données brutes (gitignored)
│   ├── processed/                     ← Données nettoyées (gitignored)
│   └── sample/                        ← Échantillon pour tests
├── notebooks/
│   └── 01_nettoyage_exploration.ipynb  ← Notebook principal
├── sql/
│   └── queries_kpis.sql               ← Requêtes SQL pour les KPIs
├── assets/                            ← Captures d'écran du dashboard
└── scripts/
    └── security_check.sh              ← Vérification pré-push
```

## 🚀 Démarrage rapide

### 1. Cloner le repo

```bash
git clone https://github.com/DiogoA78/01-road-accidents-france.git
cd 01-road-accidents-france
```

### 2. Installer les dépendances

```bash
pip install -r requirements.txt
```

### 3. Télécharger les données

```bash
python data/download_data.py
```

> Les données sont téléchargées depuis [data.gouv.fr](https://www.data.gouv.fr/fr/datasets/bases-de-donnees-annuelles-des-accidents-corporels-de-la-circulation-routiere/).
> Voir [`data/README.md`](data/README.md) pour le téléchargement manuel.

### 4. Lancer le notebook

```bash
jupyter notebook notebooks/01_nettoyage_exploration.ipynb
```

## 📊 Aperçu des résultats

> *Les captures d'écran du dashboard et des visuels clés seront ajoutées ici après réalisation.*

### 📊 Dashboard interactif

> [🔗 Voir le dashboard sur Looker Studio]([URL_DU_DASHBOARD](https://datastudio.google.com/reporting/8be64b29-5b0f-4505-a12e-3650e3cf43af))

Le dashboard permet d'explorer les données via 4 pages :
- **Vue d'ensemble** — KPIs, évolution annuelle, carte de France
- **Analyse temporelle** — par heure, mois, jour de la semaine
- **Facteurs de risque** — luminosité, météo, route, surface
- **Profils usagers** — âge, sexe, catégorie

Filtres disponibles : année, département, gravité.

### KPIs clés

| Métrique | Valeur |
|----------|--------|
| Accidents analysés | ~1M sur 15 ans |
| Période couverte | 2009 – 2023 |
| Variables exploitées | 40+ |

## 📝 Méthodologie

1. **Collecte & nettoyage** — Agrégation des 4 fichiers annuels (caractéristiques, lieux, véhicules, usagers). Recodage des variables catégorielles, gestion des valeurs manquantes, jointures.
2. **Analyse exploratoire** — Distributions temporelles, analyses bivariées (gravité × météo, type de route, luminosité), cartographie des zones accidentogènes.
3. **Requêtage SQL** — KPIs structurés : évolution de la mortalité, taux de gravité par département, profils à risque.
4. **Dashboard Looker Studio** — Tableau de bord interactif avec filtres dynamiques et visuels clés.

## 📄 Source des données

- **Base des accidents corporels de la circulation routière**
- Éditeur : Ministère de l'Intérieur
- Licence : Licence Ouverte / Open Licence
- URL : [data.gouv.fr](https://www.data.gouv.fr/fr/datasets/bases-de-donnees-annuelles-des-accidents-corporels-de-la-circulation-routiere/)

## 📜 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
