# 📊 Données — Accidents corporels de la circulation routière

## Source

- **Éditeur :** Ministère de l'Intérieur / ONISR
- **Licence :** Licence Ouverte / Open Licence
- **URL :** [data.gouv.fr](https://www.data.gouv.fr/fr/datasets/bases-de-donnees-annuelles-des-accidents-corporels-de-la-circulation-routiere/)

## Téléchargement automatique

```bash
python data/download_data.py
```

Le script télécharge les 4 fichiers pour chaque année (2009–2023) :

| Fichier | Description | Clé de jointure |
|---------|-------------|-----------------|
| `caracteristiques-YYYY.csv` | Date, heure, luminosité, météo, localisation | `Num_Acc` |
| `lieux-YYYY.csv` | Type de route, profil, tracé, état de surface | `Num_Acc` |
| `vehicules-YYYY.csv` | Catégorie de véhicule, manœuvre, obstacle | `Num_Acc`, `id_vehicule` |
| `usagers-YYYY.csv` | Gravité, sexe, âge, catégorie d'usager, équipement | `Num_Acc`, `id_vehicule` |

## Téléchargement manuel

Si le script échoue :

1. Aller sur [la page du dataset](https://www.data.gouv.fr/fr/datasets/bases-de-donnees-annuelles-des-accidents-corporels-de-la-circulation-routiere/)
2. Télécharger les fichiers CSV pour chaque année souhaitée
3. Les placer dans `data/raw/` en conservant les noms originaux

## Structure attendue après téléchargement

```
data/
├── raw/                          ← Gitignored
│   ├── caracteristiques-2009.csv
│   ├── lieux-2009.csv
│   ├── vehicules-2009.csv
│   ├── usagers-2009.csv
│   ├── ...
│   ├── caracteristiques-2023.csv
│   ├── lieux-2023.csv
│   ├── vehicules-2023.csv
│   └── usagers-2023.csv
├── processed/                    ← Gitignored — généré par le notebook
│   └── accidents_consolidated.parquet
└── sample/                       ← Versionné (< 1 Mo)
    └── sample_500.csv
```

## Volume approximatif

- ~60 000–75 000 accidents par an
- ~1 000 000 d'accidents sur 15 ans
- ~4 Go de données brutes au total
