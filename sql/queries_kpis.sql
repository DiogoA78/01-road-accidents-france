-- ============================================================================
-- KPIs — Accidentologie routière en France
-- ============================================================================
-- Ces requêtes s'exécutent sur la base SQLite générée par le notebook.
-- Table principale : accidents (résultat de la jointure des 4 fichiers sources)
-- ============================================================================


-- ──────────────────────────────────────────────────────────────────────────────
-- 1. ÉVOLUTION ANNUELLE
-- ──────────────────────────────────────────────────────────────────────────────

-- 1.1 Nombre d'accidents, tués et blessés par an
SELECT
    an                                  AS annee,
    COUNT(DISTINCT Num_Acc)             AS nb_accidents,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues,
    SUM(CASE WHEN grav = 3 THEN 1 ELSE 0 END) AS nb_hospitalises,
    SUM(CASE WHEN grav = 4 THEN 1 ELSE 0 END) AS nb_blesses_legers,
    SUM(CASE WHEN grav = 1 THEN 1 ELSE 0 END) AS nb_indemnes,
    ROUND(
        100.0 * SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                   AS taux_letalite_pct
FROM accidents
GROUP BY an
ORDER BY an;


-- 1.2 Évolution mensuelle (saisonnalité)
SELECT
    mois,
    COUNT(DISTINCT Num_Acc)             AS nb_accidents,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues
FROM accidents
GROUP BY mois
ORDER BY mois;


-- ──────────────────────────────────────────────────────────────────────────────
-- 2. ANALYSE GÉOGRAPHIQUE
-- ──────────────────────────────────────────────────────────────────────────────

-- 2.1 Top 20 départements par nombre de tués (total 2009–2023)
SELECT
    dep                                 AS departement,
    COUNT(DISTINCT Num_Acc)             AS nb_accidents,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues,
    ROUND(
        100.0 * SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                   AS taux_letalite_pct
FROM accidents
GROUP BY dep
ORDER BY nb_tues DESC
LIMIT 20;


-- 2.2 Comparaison milieu urbain vs. hors agglomération
SELECT
    CASE
        WHEN agg = 1 THEN 'Hors agglomération'
        WHEN agg = 2 THEN 'En agglomération'
        ELSE 'Inconnu'
    END                                 AS milieu,
    COUNT(DISTINCT Num_Acc)             AS nb_accidents,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues,
    ROUND(
        100.0 * SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                   AS taux_letalite_pct
FROM accidents
GROUP BY milieu
ORDER BY nb_tues DESC;


-- ──────────────────────────────────────────────────────────────────────────────
-- 3. FACTEURS DE RISQUE
-- ──────────────────────────────────────────────────────────────────────────────

-- 3.1 Gravité par conditions de luminosité
SELECT
    CASE lum
        WHEN 1 THEN 'Plein jour'
        WHEN 2 THEN 'Crépuscule / Aube'
        WHEN 3 THEN 'Nuit sans éclairage'
        WHEN 4 THEN 'Nuit avec éclairage non allumé'
        WHEN 5 THEN 'Nuit avec éclairage allumé'
        ELSE 'Inconnu'
    END                                 AS luminosite,
    COUNT(DISTINCT Num_Acc)             AS nb_accidents,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues,
    ROUND(
        100.0 * SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                   AS taux_letalite_pct
FROM accidents
GROUP BY luminosite
ORDER BY taux_letalite_pct DESC;


-- 3.2 Gravité par conditions atmosphériques
SELECT
    CASE atm
        WHEN 1 THEN 'Normale'
        WHEN 2 THEN 'Pluie légère'
        WHEN 3 THEN 'Pluie forte'
        WHEN 4 THEN 'Neige / Grêle'
        WHEN 5 THEN 'Brouillard / Fumée'
        WHEN 6 THEN 'Vent fort / Tempête'
        WHEN 7 THEN 'Temps éblouissant'
        WHEN 8 THEN 'Temps couvert'
        WHEN 9 THEN 'Autre'
        ELSE 'Non renseigné'
    END                                 AS conditions_meteo,
    COUNT(DISTINCT Num_Acc)             AS nb_accidents,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues,
    ROUND(
        100.0 * SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                   AS taux_letalite_pct
FROM accidents
GROUP BY conditions_meteo
ORDER BY taux_letalite_pct DESC;


-- 3.3 Accidents par créneau horaire
SELECT
    hrmn_heure                          AS heure,
    COUNT(DISTINCT Num_Acc)             AS nb_accidents,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues,
    ROUND(
        100.0 * SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                   AS taux_letalite_pct
FROM accidents
WHERE hrmn_heure BETWEEN 0 AND 23
GROUP BY heure
ORDER BY heure;


-- 3.4 Gravité par type de collision
SELECT
    CASE col
        WHEN 1 THEN 'Deux véhicules — frontale'
        WHEN 2 THEN 'Deux véhicules — par l''arrière'
        WHEN 3 THEN 'Deux véhicules — par le côté'
        WHEN 4 THEN 'Trois véhicules et plus — en chaîne'
        WHEN 5 THEN 'Trois véhicules et plus — collisions multiples'
        WHEN 6 THEN 'Autre collision'
        WHEN 7 THEN 'Sans collision'
        ELSE 'Non renseigné'
    END                                 AS type_collision,
    COUNT(DISTINCT Num_Acc)             AS nb_accidents,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues,
    ROUND(
        100.0 * SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                   AS taux_letalite_pct
FROM accidents
GROUP BY type_collision
ORDER BY taux_letalite_pct DESC;


-- ──────────────────────────────────────────────────────────────────────────────
-- 4. PROFILS DES USAGERS
-- ──────────────────────────────────────────────────────────────────────────────

-- 4.1 Gravité par catégorie d'usager
SELECT
    CASE catu
        WHEN 1 THEN 'Conducteur'
        WHEN 2 THEN 'Passager'
        WHEN 3 THEN 'Piéton'
        ELSE 'Autre'
    END                                 AS categorie_usager,
    COUNT(*)                            AS nb_usagers,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues,
    ROUND(
        100.0 * SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                   AS taux_letalite_pct
FROM accidents
GROUP BY categorie_usager
ORDER BY taux_letalite_pct DESC;


-- 4.2 Gravité par tranche d'âge
SELECT
    CASE
        WHEN age BETWEEN 0 AND 17  THEN '0-17 (Mineurs)'
        WHEN age BETWEEN 18 AND 24 THEN '18-24 (Jeunes)'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        WHEN age BETWEEN 65 AND 74 THEN '65-74 (Seniors)'
        WHEN age >= 75             THEN '75+ (Seniors)'
        ELSE 'Inconnu'
    END                                 AS tranche_age,
    COUNT(*)                            AS nb_usagers,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues,
    ROUND(
        100.0 * SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                   AS taux_letalite_pct
FROM accidents
WHERE age IS NOT NULL AND age > 0
GROUP BY tranche_age
ORDER BY taux_letalite_pct DESC;


-- 4.3 Gravité par sexe
SELECT
    CASE sexe
        WHEN 1 THEN 'Homme'
        WHEN 2 THEN 'Femme'
        ELSE 'Non renseigné'
    END                                 AS sexe_usager,
    COUNT(*)                            AS nb_usagers,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues,
    ROUND(
        100.0 * SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                   AS taux_letalite_pct
FROM accidents
GROUP BY sexe_usager
ORDER BY taux_letalite_pct DESC;


-- ──────────────────────────────────────────────────────────────────────────────
-- 5. INFRASTRUCTURE
-- ──────────────────────────────────────────────────────────────────────────────

-- 5.1 Gravité par catégorie de route
SELECT
    CASE catr
        WHEN 1 THEN 'Autoroute'
        WHEN 2 THEN 'Route nationale'
        WHEN 3 THEN 'Route départementale'
        WHEN 4 THEN 'Voie communale'
        WHEN 5 THEN 'Hors réseau public'
        WHEN 6 THEN 'Parc de stationnement'
        WHEN 9 THEN 'Autre'
        ELSE 'Non renseigné'
    END                                 AS categorie_route,
    COUNT(DISTINCT Num_Acc)             AS nb_accidents,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues,
    ROUND(
        100.0 * SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                   AS taux_letalite_pct
FROM accidents
GROUP BY categorie_route
ORDER BY taux_letalite_pct DESC;


-- 5.2 Gravité par état de la surface
SELECT
    CASE surf
        WHEN 1 THEN 'Normale'
        WHEN 2 THEN 'Mouillée'
        WHEN 3 THEN 'Flaques'
        WHEN 4 THEN 'Inondée'
        WHEN 5 THEN 'Enneigée'
        WHEN 6 THEN 'Boue'
        WHEN 7 THEN 'Verglacée'
        WHEN 8 THEN 'Corps gras — Huile'
        WHEN 9 THEN 'Autre'
        ELSE 'Non renseigné'
    END                                 AS etat_surface,
    COUNT(DISTINCT Num_Acc)             AS nb_accidents,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues,
    ROUND(
        100.0 * SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                   AS taux_letalite_pct
FROM accidents
GROUP BY etat_surface
ORDER BY taux_letalite_pct DESC;


-- ──────────────────────────────────────────────────────────────────────────────
-- 6. KPIs SYNTHÉTIQUES POUR LE DASHBOARD
-- ──────────────────────────────────────────────────────────────────────────────

-- 6.1 KPIs globaux sur la période complète
SELECT
    COUNT(DISTINCT Num_Acc) AS total_accidents,
    SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS total_tues,
    SUM(CASE WHEN grav = 3 THEN 1 ELSE 0 END) AS total_hospitalises,
    SUM(CASE WHEN grav IN (3, 4) THEN 1 ELSE 0 END) AS total_blesses,
    COUNT(DISTINCT an) AS nb_annees,
    ROUND(
        1.0 * SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(DISTINCT an), 0), 0
    ) AS moyenne_tues_par_an
FROM accidents;


-- 6.2 Variation année N vs. N-1 (dernière année disponible)
WITH yearly AS (
    SELECT
        an,
        COUNT(DISTINCT Num_Acc) AS nb_accidents,
        SUM(CASE WHEN grav = 2 THEN 1 ELSE 0 END) AS nb_tues
    FROM accidents
    GROUP BY an
)
SELECT
    y2.an                               AS annee,
    y2.nb_accidents,
    y1.nb_accidents                     AS nb_accidents_n_1,
    ROUND(
        100.0 * (y2.nb_accidents - y1.nb_accidents)
        / NULLIF(y1.nb_accidents, 0), 1
    )                                   AS variation_accidents_pct,
    y2.nb_tues,
    y1.nb_tues                          AS nb_tues_n_1,
    ROUND(
        100.0 * (y2.nb_tues - y1.nb_tues)
        / NULLIF(y1.nb_tues, 0), 1
    )                                   AS variation_tues_pct
FROM yearly y2
JOIN yearly y1 ON y2.an = y1.an + 1
ORDER BY y2.an;
