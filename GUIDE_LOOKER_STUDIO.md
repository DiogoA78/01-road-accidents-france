# 📊 Guide de construction — Dashboard Looker Studio
## Accidentologie routière en France (2009–2023)

> Looker Studio (ex-Google Data Studio) : gratuit, web, partageable par lien.
> URL : https://lookerstudio.google.com

---

## Colonnes disponibles dans le CSV

Le fichier `accidents_detail.csv` est au **grain accident** (1 ligne = 1 accident).

| Colonne | Type | Description |
|---------|------|-------------|
| `num_acc` | Texte | Identifiant unique de l'accident |
| `Annee` | Nombre | Année de l'accident |
| `Mois` | Nombre | Mois (1-12) |
| `Jour` | Nombre | Jour du mois |
| `Heure` | Nombre | Heure (0-23) |
| `Jour_Semaine` | Texte | Nom du jour (Monday, Tuesday, etc.) |
| `Departement` | Texte | Code département (01, 02, ... 95, 971, etc.) |
| `Luminosite` | Texte | Condition de luminosité (label) |
| `Meteo` | Texte | Conditions météo (label) |
| `Agglomeration` | Nombre | 1 = Hors agglo, 2 = En agglo |
| `Type_Route` | Texte | Catégorie de route (label) |
| `Etat_Surface` | Texte | État de la surface (label) |
| `Type_Collision` | Nombre | Code type de collision |
| `Latitude` | Nombre | Latitude GPS |
| `Longitude` | Nombre | Longitude GPS |
| `Nb_Usagers` | Nombre | Nombre total d'usagers impliqués |
| `Nb_Tues` | Nombre | Nombre de tués dans l'accident |
| `Nb_Hospitalises` | Nombre | Nombre d'hospitalisés |
| `Nb_Blesses_Legers` | Nombre | Nombre de blessés légers |
| `Nb_Indemnes` | Nombre | Nombre d'indemnes |
| `Gravite_Max` | Nombre | Pire gravité (2=Mortel, 3=Hospitalisé, 4=Léger, 1=Indemne) |
| `Gravite_Label` | Texte | Label de la pire gravité |
| `Collision_Label` | Texte | Label du type de collision |
| `Milieu` | Texte | "Hors agglomération" / "En agglomération" |
| `Est_Mortel` | Nombre | 1 si au moins un tué, 0 sinon |

---

## 1. Importer dans Google Sheets

1. Ouvrir **Google Drive** → Nouveau → **Google Sheets**
2. Fichier → **Importer** → Upload → sélectionner `accidents_detail.csv`
3. Renommer la feuille : "Accidents"

### Vérifications dans Google Sheets

| Colonne | Format attendu | Action |
|---------|---------------|--------|
| `Annee`, `Mois`, `Jour`, `Heure` | Nombre | Vérifier |
| `Departement` | **Texte brut** | Forcer (sinon "01" → 1) |
| `Nb_Tues`, `Nb_Hospitalises`, etc. | Nombre | Vérifier |
| `Est_Mortel` | Nombre | Vérifier |
| `Latitude`, `Longitude` | Nombre | Vérifier |
| Colonnes texte (labels) | Texte | OK par défaut |

---

## 2. Créer le rapport Looker Studio

1. Aller sur **https://lookerstudio.google.com**
2. **Créer → Rapport**
3. **Ajouter des données → Google Sheets**
4. Sélectionner le fichier → feuille "Accidents"
5. Cliquer **Ajouter**

### 2.1 Vérifier les types dans la source

**Ressource → Gérer les sources de données → Modifier** :

| Champ | Type à définir |
|-------|---------------|
| `num_acc` | Texte |
| `Annee`, `Mois`, `Jour`, `Heure` | Nombre |
| `Departement` | Texte (pas Géo) |
| `Latitude` | Nombre (ou Latitude si dispo) |
| `Longitude` | Nombre (ou Longitude si dispo) |
| `Nb_Tues`, `Nb_Hospitalises`, `Nb_Blesses_Legers`, `Nb_Indemnes`, `Nb_Usagers` | Nombre |
| `Gravite_Max`, `Type_Collision`, `Agglomeration` | Nombre |
| `Est_Mortel` | Nombre |
| Toutes les colonnes `_Label`, `Milieu`, `Luminosite`, `Meteo`, etc. | Texte |

---

## 3. Champs calculés à créer

**Ressource → Gérer les sources de données → Modifier → Ajouter un champ**

### Champs de dimensions

```
Nom : Mois_Nom
Formule :
CASE
  WHEN Mois = 1 THEN "Janvier"
  WHEN Mois = 2 THEN "Février"
  WHEN Mois = 3 THEN "Mars"
  WHEN Mois = 4 THEN "Avril"
  WHEN Mois = 5 THEN "Mai"
  WHEN Mois = 6 THEN "Juin"
  WHEN Mois = 7 THEN "Juillet"
  WHEN Mois = 8 THEN "Août"
  WHEN Mois = 9 THEN "Septembre"
  WHEN Mois = 10 THEN "Octobre"
  WHEN Mois = 11 THEN "Novembre"
  WHEN Mois = 12 THEN "Décembre"
END
```

```
Nom : Jour_Ordre
Formule :
CASE
  WHEN Jour_Semaine = "Monday" THEN 1
  WHEN Jour_Semaine = "Tuesday" THEN 2
  WHEN Jour_Semaine = "Wednesday" THEN 3
  WHEN Jour_Semaine = "Thursday" THEN 4
  WHEN Jour_Semaine = "Friday" THEN 5
  WHEN Jour_Semaine = "Saturday" THEN 6
  WHEN Jour_Semaine = "Sunday" THEN 7
  ELSE 8
END
```

```
Nom : Jour_FR
Formule :
CASE
  WHEN Jour_Semaine = "Monday" THEN "Lundi"
  WHEN Jour_Semaine = "Tuesday" THEN "Mardi"
  WHEN Jour_Semaine = "Wednesday" THEN "Mercredi"
  WHEN Jour_Semaine = "Thursday" THEN "Jeudi"
  WHEN Jour_Semaine = "Friday" THEN "Vendredi"
  WHEN Jour_Semaine = "Saturday" THEN "Samedi"
  WHEN Jour_Semaine = "Sunday" THEN "Dimanche"
  ELSE "Inconnu"
END
```

```
Nom : Creneau_Horaire
Formule :
CASE
  WHEN Heure >= 0 AND Heure < 6 THEN "Nuit (0h-6h)"
  WHEN Heure >= 6 AND Heure < 10 THEN "Matin (6h-10h)"
  WHEN Heure >= 10 AND Heure < 14 THEN "Journée (10h-14h)"
  WHEN Heure >= 14 AND Heure < 18 THEN "Après-midi (14h-18h)"
  WHEN Heure >= 18 AND Heure < 22 THEN "Soirée (18h-22h)"
  ELSE "Nuit (22h-0h)"
END
```

### Métriques calculées

```
Nom : Total_Accidents
Formule : COUNT(num_acc)
```

```
Nom : Total_Tues
Formule : SUM(Nb_Tues)
```

```
Nom : Total_Blesses
Formule : SUM(Nb_Hospitalises) + SUM(Nb_Blesses_Legers)
```

```
Nom : Total_Usagers
Formule : SUM(Nb_Usagers)
```

```
Nom : Taux_Letalite
Formule : SUM(Nb_Tues) / SUM(Nb_Usagers)
Type : Pourcentage (2 décimales)
```

```
Nom : Pct_Accidents_Mortels
Formule : SUM(Est_Mortel) / COUNT(num_acc)
Type : Pourcentage (2 décimales)
```

```
Nom : Moy_Usagers_Par_Accident
Formule : SUM(Nb_Usagers) / COUNT(num_acc)
Type : Nombre (1 décimale)
```

---

## 4. Palette de couleurs

**Thème → Personnaliser** :

| Usage | Hex |
|-------|-----|
| Accent principal (titres, barres) | `#1B3A5C` |
| Accent secondaire | `#3B7DD8` |
| Alerte / Tués | `#D64045` |
| Blessés | `#E8913A` |
| Indemnes / OK | `#5BA858` |
| Fond de page | `#F5F6FA` |
| Texte | `#2D3436` |

---

## 5. Page 1 — Vue d'ensemble

### Layout

```
┌─────────────────────────────────────────────────────┐
│  🚗 ACCIDENTOLOGIE ROUTIÈRE EN FRANCE               │
├───────────┬───────────┬───────────┬─────────────────┤
│ ACCIDENTS │   TUÉS    │  BLESSÉS  │ % ACC. MORTELS  │
│  COUNT()  │ SUM(Nb_T) │ SUM(Hosp  │ Pct_Acc_Mortels │
│           │           │ +Bl_Leg)  │                 │
├───────────┴───────────┴───────────┴─────────────────┤
│                                                     │
│  [Graphique combiné : Évolution annuelle]            │
│  Dim = Annee                                         │
│  Barres = COUNT(num_acc)  |  Ligne = SUM(Nb_Tues)   │
│                                                     │
├────────────────────────┬────────────────────────────┤
│  [Carte Google Maps]   │ [Barres H : Top 10 dép.]   │
│  Position = Lat, Long  │ Dim = Departement           │
│  Taille = COUNT()      │ Métrique = SUM(Nb_Tues)     │
│  Couleur = Est_Mortel  │ Nb barres = 10              │
├────────────────────────┴────────────────────────────┤
│ [Filtre] Annee ▼  [Filtre] Departement ▼            │
│ [Filtre] Gravite_Label ▼  [Filtre] Milieu ▼         │
└─────────────────────────────────────────────────────┘
```

### Détail des visuels

**4 Fiches de score** (Insérer → Fiche de score)

| Fiche | Métrique | Couleur texte |
|-------|----------|---------------|
| Accidents | `COUNT(num_acc)` | `#1B3A5C` |
| Tués | `SUM(Nb_Tues)` | `#D64045` |
| Blessés | `SUM(Nb_Hospitalises)` + `SUM(Nb_Blesses_Legers)` | `#E8913A` |
| % Acc. mortels | `Pct_Accidents_Mortels` | `#1B3A5C` |

**Graphique combiné — Évolution annuelle**
- Insérer → **Graphique combiné**
- Dimension : `Annee`
- Métrique barres : `COUNT(num_acc)` → couleur `#3B7DD8`
- Métrique ligne : `SUM(Nb_Tues)` → couleur `#D64045` → **axe droit**
- Tri : `Annee` croissant
- Titre : "Évolution annuelle des accidents et décès"

**Carte Google Maps**
- Insérer → **Carte Google Maps**
- Champ de position : `Latitude`, `Longitude`
- Taille des bulles : `COUNT(num_acc)`
- Couleur : `SUM(Est_Mortel)` (dégradé)
- Titre : "Répartition géographique"

**Top 10 départements**
- Insérer → **Barres horizontales**
- Dimension : `Departement`
- Métrique : `SUM(Nb_Tues)`
- Tri : `SUM(Nb_Tues)` décroissant
- Style → Nombre de barres : **10**
- Couleur : `#D64045`
- Titre : "Top 10 départements — nombre de tués"

**Filtres** (Insérer → Contrôle par liste déroulante)
- Filtre 1 : `Annee`
- Filtre 2 : `Departement`
- Filtre 3 : `Gravite_Label`
- Filtre 4 : `Milieu`

---

## 6. Page 2 — Analyse temporelle

### Layout

```
┌─────────────────────────────────────────────────────┐
│  ⏰ ANALYSE TEMPORELLE                               │
├─────────────────────────────────────────────────────┤
│  [Graphique combiné : par heure]                     │
│  Dim = Heure | Barres = COUNT() | Ligne = Taux_Let  │
├────────────────────────┬────────────────────────────┤
│  [Barres : par mois]   │ [Barres : par jour semaine]│
│  Dim = Mois            │ Dim = Jour_FR              │
│  Métrique = COUNT()    │ Tri = Jour_Ordre           │
├────────────────────────┴────────────────────────────┤
│  [Pivot Table : Heatmap Heure × Jour]                │
│  Lignes = Jour_FR | Colonnes = Heure | Val = COUNT() │
└─────────────────────────────────────────────────────┘
```

### Détail

**Accidents par créneau horaire**
- Insérer → **Graphique combiné**
- Dimension : `Heure`
- Métrique barres : `COUNT(num_acc)` → `#3B7DD8`
- Métrique ligne (axe droit) : `Taux_Letalite` → `#D64045`
- Tri : `Heure` croissant
- Titre : "Accidents et létalité par créneau horaire"

**Distribution mensuelle**
- Insérer → **Barres verticales**
- Dimension : `Mois`
- Métrique : `COUNT(num_acc)`
- Tri : `Mois` croissant
- Titre : "Saisonnalité des accidents"
- Note : garder `Mois` en nombre (1-12) pour un tri correct

**Distribution par jour de la semaine**
- Insérer → **Barres verticales**
- Dimension : `Jour_FR` (champ calculé)
- Métrique : `COUNT(num_acc)`
- Tri : `Jour_Ordre` croissant (champ calculé)
- Titre : "Accidents par jour de la semaine"

**Heatmap Heure × Jour** (optionnel)
- Insérer → **Tableau croisé dynamique**
- Lignes : `Jour_FR` (trié par `Jour_Ordre`)
- Colonnes : `Heure`
- Métrique : `COUNT(num_acc)`
- Style → **Heatmap activée** (blanc → `#1B3A5C`)
- Titre : "Heatmap — Heure × Jour de la semaine"

---

## 7. Page 3 — Facteurs de risque

### Layout

```
┌─────────────────────────────────────────────────────┐
│  ⚠️ FACTEURS DE RISQUE                               │
├────────────────────────┬────────────────────────────┤
│  [Barres H :           │  [Barres H :               │
│   Luminosite]          │   Meteo]                   │
│  Métrique =            │  Métrique =                │
│  Taux_Letalite         │  Taux_Letalite             │
├────────────────────────┼────────────────────────────┤
│  [Barres H :           │  [Barres H :               │
│   Type_Route]          │   Etat_Surface]            │
│  Métrique =            │  Métrique =                │
│  Taux_Letalite         │  Taux_Letalite             │
├────────────────────────┴────────────────────────────┤
│  [Donut : Collision_Label]                           │
│  Métrique = COUNT(num_acc)                           │
└─────────────────────────────────────────────────────┘
```

### Détail

**4 graphiques barres horizontales** — même pattern :

- Insérer → **Barres horizontales**
- Métrique : `Taux_Letalite` (champ calculé)
- Tri : décroissant par métrique
- Couleur : `#D64045`
- Étiquettes de données : **activées**, format pourcentage
- Info-bulle : ajouter `COUNT(num_acc)` et `SUM(Nb_Tues)`

| # | Dimension | Titre |
|---|-----------|-------|
| 1 | `Luminosite` | "Létalité par luminosité" |
| 2 | `Meteo` | "Létalité par conditions météo" |
| 3 | `Type_Route` | "Létalité par catégorie de route" |
| 4 | `Etat_Surface` | "Létalité par état de surface" |

**Donut — Type de collision**
- Insérer → **Graphique en anneau**
- Dimension : `Collision_Label`
- Métrique : `COUNT(num_acc)`
- Titre : "Répartition par type de collision"

---

## 8. Page 4 — Milieu & collisions

> Les données étant au grain accident (pas usager), cette page
> analyse les dimensions restantes : milieu, collisions, gravité.

### Layout

```
┌─────────────────────────────────────────────────────┐
│  🏙️ MILIEU & COLLISIONS                              │
├────────────────────────┬────────────────────────────┤
│ [Fiche] Agglo          │ [Fiche] Hors agglo         │
│ COUNT + SUM(Nb_Tues)   │ COUNT + SUM(Nb_Tues)       │
│ + Taux_Letalite        │ + Taux_Letalite            │
├────────────────────────┴────────────────────────────┤
│  [Barres empilées : Gravite_Label par Milieu]        │
│  Dim = Milieu | Répartition = Gravite_Label          │
│  Métrique = COUNT(num_acc)                           │
├────────────────────────┬────────────────────────────┤
│  [Barres : Collision   │  [Tableau : Collision ×     │
│   × Létalité]          │   Milieu — détail]          │
│  Dim = Collision_Label │  Lignes = Collision_Label   │
│  Métr = Taux_Letalite  │  Colonnes = COUNT, Tués,    │
│                        │  Taux_Let                   │
├────────────────────────┴────────────────────────────┤
│  [Barres groupées : Taux létalité par route × milieu]│
│  Dim = Type_Route | Répartition = Milieu             │
│  Métrique = Taux_Letalite                            │
└─────────────────────────────────────────────────────┘
```

### Détail

**2 Fiches de score comparatives**
- Fiche "En agglomération" :
  - Métrique : `COUNT(num_acc)` + `SUM(Nb_Tues)` + `Taux_Letalite`
  - Filtre de graphique : `Milieu` = "En agglomération"
- Fiche "Hors agglomération" :
  - Même chose, filtre = "Hors agglomération"

**Barres empilées — Gravité par milieu**
- Insérer → **Barres empilées**
- Dimension : `Milieu`
- Dimension de répartition : `Gravite_Label`
- Métrique : `COUNT(num_acc)`
- Couleurs : Mortel `#D64045`, Hospitalisé `#E8913A`, Blessé léger `#F0C75E`, Indemne `#5BA858`
- Titre : "Répartition de la gravité par milieu"

**Létalité par type de collision**
- Insérer → **Barres horizontales**
- Dimension : `Collision_Label`
- Métrique : `Taux_Letalite`
- Tri : décroissant
- Couleur : `#D64045`
- Titre : "Taux de létalité par type de collision"

**Tableau croisé — Collisions en détail**
- Insérer → **Tableau**
- Dimension : `Collision_Label`
- Métriques : `COUNT(num_acc)`, `SUM(Nb_Tues)`, `Taux_Letalite`
- Titre : "Détail par type de collision"
- Style : heatmap sur la colonne Taux_Letalite

**Létalité par route × milieu**
- Insérer → **Barres groupées**
- Dimension : `Type_Route`
- Dimension de répartition : `Milieu`
- Métrique : `Taux_Letalite`
- Couleurs : Agglo `#3B7DD8`, Hors agglo `#D64045`
- Titre : "Létalité par catégorie de route et milieu"

---

## 9. Touches finales

### 9.1 Thème
- **Thème → Personnaliser** : appliquer la palette
- Police : **Roboto** partout
- Fond de page : `#F5F6FA`
- Bande de titre en haut : rectangle `#1B3A5C`, texte blanc

### 9.2 Filtres globaux
Vérifier que les 4 filtres de la Page 1 s'appliquent bien à **toutes les pages** :
- Clic droit sur le filtre → **Portée du filtre → Rapport** (pas juste la page)

### 9.3 Partage pour le portfolio
1. Bouton **Partager** → "Obtenir le lien"
2. Choisir **"Toute personne disposant du lien peut consulter"**
3. Copier le lien → URL pour le portfolio
4. Le visiteur peut interagir avec les filtres

### 9.4 Captures d'écran
Sauvegarder dans `assets/` :
- `dashboard_page1_overview.png`
- `dashboard_page2_temporel.png`
- `dashboard_page3_risques.png`
- `dashboard_page4_milieu.png`

---

## 10. Checklist finale

```
□ 4 pages créées avec titres cohérents
□ 4 fiches de score sur la page d'accueil
□ Filtres (Annee, Departement, Gravite_Label, Milieu) fonctionnels
□ Filtres en portée "Rapport" (pas juste la page)
□ Palette de couleurs cohérente sur tous les visuels
□ Tri correct (Heure 0-23, Mois 1-12, Jour_FR lun→dim)
□ Pas de visuel vide ou en erreur
□ Lien de partage public généré
□ Captures d'écran dans assets/
□ Lien ajouté au README du repo
```
