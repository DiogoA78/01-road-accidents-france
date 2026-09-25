"""
Téléchargement automatique des données d'accidents corporels.

Source : data.gouv.fr — Bases de données annuelles des accidents corporels
         de la circulation routière.

Usage :
    python data/download_data.py
    python data/download_data.py --years 2019 2020 2021 2022 2023
    python data/download_data.py --sample-only
"""

import argparse
import os
import sys
import time
from pathlib import Path

import requests
from tqdm import tqdm

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Répertoires
SCRIPT_DIR = Path(__file__).parent
RAW_DIR = SCRIPT_DIR / "raw"
SAMPLE_DIR = SCRIPT_DIR / "sample"

# Années disponibles (à ajuster si de nouvelles années sont publiées)
AVAILABLE_YEARS = list(range(2009, 2024))  # 2009–2023
DEFAULT_YEARS = AVAILABLE_YEARS

# Types de fichiers
FILE_TYPES = ["caracteristiques", "lieux", "vehicules", "usagers"]

# ID du dataset sur data.gouv.fr
DATASET_ID = "53698f4ca3a729239d2036df"

# ---------------------------------------------------------------------------
# Fonctions
# ---------------------------------------------------------------------------


def get_resource_urls() -> dict:
    """
    Récupère les URLs des ressources via l'API data.gouv.fr.

    Returns:
        dict: {filename: url} pour chaque fichier CSV trouvé.
    """
    api_url = f"https://www.data.gouv.fr/api/1/datasets/{DATASET_ID}/"

    print("  Récupération des URLs via l'API data.gouv.fr...")

    try:
        response = requests.get(api_url, timeout=30)
        response.raise_for_status()
    except requests.RequestException as e:
        print(f"  ⚠️  Impossible de contacter l'API : {e}")
        print("  → Utilise le téléchargement manuel (voir data/README.md)")
        sys.exit(1)

    data = response.json()
    resources = {}

    for resource in data.get("resources", []):
        title = (resource.get("title") or "").lower()
        url = resource.get("url") or ""
        fmt = (resource.get("format") or "").lower()

        # Filtrer les fichiers CSV pertinents
        if not url.endswith(".csv") and "csv" not in fmt:
            continue

        for file_type in FILE_TYPES:
            for year in AVAILABLE_YEARS:
                # Matching flexible : le titre ou l'URL contient le type et l'année
                if file_type in title and str(year) in title:
                    key = f"{file_type}-{year}.csv"
                    resources[key] = url
                elif file_type in url.lower() and str(year) in url:
                    key = f"{file_type}-{year}.csv"
                    resources[key] = url

    print(f"  → {len(resources)} fichiers trouvés sur l'API.\n")
    return resources


def download_file(url: str, filepath: Path, retries: int = 3) -> bool:
    """
    Télécharge un fichier avec barre de progression et retry.

    Args:
        url: URL du fichier à télécharger.
        filepath: Chemin de destination.
        retries: Nombre de tentatives en cas d'échec.

    Returns:
        True si le téléchargement a réussi, False sinon.
    """
    for attempt in range(1, retries + 1):
        try:
            response = requests.get(url, stream=True, timeout=60)
            response.raise_for_status()

            total_size = int(response.headers.get("content-length", 0))
            block_size = 8192

            with open(filepath, "wb") as f:
                with tqdm(
                    total=total_size,
                    unit="B",
                    unit_scale=True,
                    desc=f"    {filepath.name}",
                    leave=True,
                ) as pbar:
                    for chunk in response.iter_content(chunk_size=block_size):
                        f.write(chunk)
                        pbar.update(len(chunk))

            return True

        except requests.RequestException as e:
            if attempt < retries:
                print(f"    ⚠️  Tentative {attempt}/{retries} échouée : {e}")
                time.sleep(2 * attempt)  # Backoff
            else:
                print(f"    ❌ Échec après {retries} tentatives : {e}")
                return False

    return False


def download_years(years: list[int], resources: dict) -> dict:
    """
    Télécharge les données pour les années demandées.

    Args:
        years: Liste des années à télécharger.
        resources: Dictionnaire {filename: url}.

    Returns:
        dict avec le bilan : {succès, échecs, déjà_présents}.
    """
    RAW_DIR.mkdir(parents=True, exist_ok=True)

    stats = {"success": 0, "failed": 0, "skipped": 0}
    failed_files = []

    for year in sorted(years):
        print(f"\n📅 Année {year}")

        for file_type in FILE_TYPES:
            key = f"{file_type}-{year}.csv"
            filepath = RAW_DIR / key

            # Vérifier si déjà téléchargé
            if filepath.exists() and filepath.stat().st_size > 0:
                print(f"    ✓ {key} — déjà présent ({filepath.stat().st_size / 1e6:.1f} Mo)")
                stats["skipped"] += 1
                continue

            # Vérifier si l'URL existe
            url = resources.get(key)
            if not url:
                print(f"    ⚠️  {key} — URL non trouvée sur l'API")
                stats["failed"] += 1
                failed_files.append(key)
                continue

            # Télécharger
            if download_file(url, filepath):
                stats["success"] += 1
            else:
                stats["failed"] += 1
                failed_files.append(key)

    return stats, failed_files


def create_sample(n_rows: int = 500) -> None:
    """
    Crée un échantillon à partir des données téléchargées.
    Prend les n_rows premières lignes du fichier caractéristiques
    de l'année la plus récente disponible.
    """
    import pandas as pd

    SAMPLE_DIR.mkdir(parents=True, exist_ok=True)
    sample_path = SAMPLE_DIR / f"sample_{n_rows}.csv"

    if sample_path.exists():
        print(f"\n✓ Échantillon déjà présent : {sample_path.name}")
        return

    # Trouver l'année la plus récente disponible
    for year in sorted(AVAILABLE_YEARS, reverse=True):
        carac_file = RAW_DIR / f"caracteristiques-{year}.csv"
        if carac_file.exists():
            print(f"\n📝 Création de l'échantillon à partir de {year}...")

            # Lire avec gestion d'encodage
            for encoding in ["utf-8", "latin-1", "cp1252"]:
                try:
                    df = pd.read_csv(
                        carac_file,
                        sep=";",
                        encoding=encoding,
                        nrows=n_rows,
                        low_memory=False,
                    )
                    df.to_csv(sample_path, index=False, sep=";")
                    print(f"  ✓ Échantillon créé : {sample_path.name} ({len(df)} lignes)")
                    return
                except UnicodeDecodeError:
                    continue

            print("  ⚠️  Impossible de lire le fichier — échantillon non créé.")
            return

    print("\n⚠️  Aucune donnée trouvée pour créer l'échantillon.")


# ---------------------------------------------------------------------------
# Point d'entrée
# ---------------------------------------------------------------------------


def main():
    parser = argparse.ArgumentParser(
        description="Télécharger les données d'accidents corporels depuis data.gouv.fr"
    )
    parser.add_argument(
        "--years",
        type=int,
        nargs="+",
        default=DEFAULT_YEARS,
        help=f"Années à télécharger (défaut : {DEFAULT_YEARS[0]}-{DEFAULT_YEARS[-1]})",
    )
    parser.add_argument(
        "--sample-only",
        action="store_true",
        help="Créer uniquement l'échantillon (sans téléchargement)",
    )

    args = parser.parse_args()

    print("=" * 60)
    print("📥 Téléchargement des données d'accidents corporels")
    print("   Source : data.gouv.fr — Ministère de l'Intérieur")
    print("=" * 60)

    if args.sample_only:
        create_sample()
        return

    # Valider les années demandées
    invalid_years = [y for y in args.years if y not in AVAILABLE_YEARS]
    if invalid_years:
        print(f"\n⚠️  Années non disponibles : {invalid_years}")
        print(f"   Années disponibles : {AVAILABLE_YEARS[0]}-{AVAILABLE_YEARS[-1]}")
        args.years = [y for y in args.years if y in AVAILABLE_YEARS]

    # Récupérer les URLs
    resources = get_resource_urls()

    if not resources:
        print("\n❌ Aucune URL trouvée. Essaie le téléchargement manuel.")
        print("   Voir data/README.md pour les instructions.")
        sys.exit(1)

    # Télécharger
    stats, failed_files = download_years(args.years, resources)

    # Créer l'échantillon
    create_sample()

    # Bilan
    print("\n" + "=" * 60)
    print("📊 Bilan du téléchargement")
    print(f"   ✓ Téléchargés : {stats['success']}")
    print(f"   → Déjà présents : {stats['skipped']}")
    print(f"   ✗ Échoués : {stats['failed']}")

    if failed_files:
        print(f"\n   Fichiers manquants :")
        for f in failed_files:
            print(f"     - {f}")
        print("\n   → Télécharge-les manuellement depuis data.gouv.fr")

    print("=" * 60)


if __name__ == "__main__":
    main()
