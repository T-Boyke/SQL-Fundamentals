-- ============================================================================
-- SQL-Fundamentals: Day 21 - Fortgeschrittene T-SQL Techniken
-- Datei: 03_grouping_sets_cube_rollup.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 31.08.2026
-- Fokus: GROUPING SETS, CUBE, ROLLUP und GROUPING() Funktion
-- Datenbanken: WeitereBeispiele & ProjektDB (SoT)
-- ============================================================================

-- ============================================================================
-- THEORIE: Erweiterte Gruppierungen in T-SQL
-- ----------------------------------------------------------------------------
-- Standard-GROUP BY liefert Aggregationen auf genau einer Dimensionsebene.
-- Für Zwischensummen (Subtotals) und Gesamtsummen (Grand Totals) gibt es:
--
-- 1. GROUPING SETS ((dim1), (dim2), (dim1, dim2), ()):
--    - Ermöglicht die freie und präzise Definition von Aggregationsebenen.
--    - Ersetzt unperformante UNION ALL-Ketten durch einen einzigen Tabellenscan.
--
-- 2. ROLLUP (dim1, dim2, dim3):
--    - Erzeugt hierarchische Zwischensummen von links nach rechts:
--      (dim1, dim2, dim3) -> (dim1, dim2) -> (dim1) -> ()
--    - Anzahl der Sets: N + 1
--
-- 3. CUBE (dim1, dim2):
--    - Erzeugt die vollständige Potenzmenge aller Aggregationskombinationen.
--    - Anzahl der Sets: 2^N
--
-- 4. GROUPING(spalte):
--    - Gibt 1 zurück, wenn die Zeile ein aggregierter NULL-Platzhalter ist (Super-Aggregate).
--    - Gibt 0 zurück, wenn der Wert ein reeller Tabellenwert ist.
-- ============================================================================

USE master;
GO

USE WeitereBeispiele;
GO

-- ============================================================================
-- 1. Der traditionelle Weg: UNION ALL (Umständlich & teuer)
-- ============================================================================

PRINT '--- 1. Traditionelles Gruppieren mit UNION ALL (4 Scans) ---';
SELECT NULL AS socialnetwork, NULL AS country, COUNT(*) AS anzahl
FROM SocialNetwork
UNION ALL
SELECT socialnetwork, NULL AS country, COUNT(*) AS anzahl
FROM SocialNetwork
GROUP BY socialnetwork
UNION ALL
SELECT NULL AS socialnetwork, country, COUNT(*) AS anzahl
FROM SocialNetwork
GROUP BY country
UNION ALL
SELECT socialnetwork, country, COUNT(*) AS anzahl
FROM SocialNetwork
GROUP BY socialnetwork, country;
GO


-- ============================================================================
-- 2. Die moderne Lösung: GROUPING SETS
-- ============================================================================

PRINT '--- 2. GROUPING SETS (1 Scan, saubere Syntax) ---';
-- noqa: disable=PRS
SELECT socialnetwork, 
       country, 
       COUNT(*) AS anzahl
FROM SocialNetwork
GROUP BY 
    GROUPING SETS (
        (),
        socialnetwork,
        country,
        (socialnetwork, country)
    )
ORDER BY 
    GROUPING(socialnetwork) ASC,
    GROUPING(country) ASC;
-- noqa: enable=PRS
GO


-- ============================================================================
-- 3. CUBE: Vollständige multidimensionale Kombinationen (2^N)
-- ============================================================================

PRINT '--- 3. CUBE über 4 Dimensionen ---';
SELECT socialnetwork, 
       country, 
       firstname, 
       lastname, 
       COUNT(*) AS anzahl
FROM SocialNetwork
GROUP BY 
    CUBE (socialnetwork, country, firstname, lastname)
ORDER BY 
    socialnetwork ASC,
    country ASC,
    firstname ASC,
    lastname ASC;
GO


-- ============================================================================
-- 4. ROLLUP: Hierarchische Aggregation (Land -> Netzwerk -> Gesamtsumme)
-- ============================================================================

PRINT '--- 4. Hierarchisches ROLLUP mit lesbaren Labels ---';
SELECT 
    CASE WHEN GROUPING(country) = 1 THEN '>>> ALLE LÄNDER <<<' ELSE country END AS country,
    CASE WHEN GROUPING(socialnetwork) = 1 THEN '>>> ALLE NETZWERKE <<<' ELSE socialnetwork END AS socialnetwork,
    COUNT(*) AS anzahl_nutzer
FROM SocialNetwork
GROUP BY
    ROLLUP (country, socialnetwork)
ORDER BY 
    country ASC,
    socialnetwork ASC;
GO


-- ============================================================================
-- 5. ProjektDB SoT Transfer: Umsatz- und Abteilungsanalyse
-- ============================================================================

USE ProjektDB;
GO

PRINT '--- 5.1 ProjektDB: Umsatzstatistik mit ROLLUP (Abteilung -> Mitarbeiter) ---';
SELECT 
    CASE WHEN GROUPING(a.bezeichnung) = 1 THEN '** UNTERNEHMEN GESAMT **' ELSE a.bezeichnung END AS abteilung,
    CASE WHEN GROUPING(m.nachname) = 1 THEN '-- Abteilungs-Summe --' ELSE m.nachname END AS mitarbeiter,
    COUNT(u.id) AS anzahl_umsatzvorgaenge,
    FORMAT(SUM(u.umsatz), 'C', 'de-DE') AS summe_umsatz,
    FORMAT(AVG(u.umsatz), 'C', 'de-DE') AS avg_umsatz
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id = a.id
INNER JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY 
    ROLLUP (a.bezeichnung, m.nachname)
ORDER BY 
    abteilung ASC,
    mitarbeiter ASC;
GO

PRINT '--- 5.2 ProjektDB: Projektbudget-Analyse mit GROUPING SETS ---';
-- noqa: disable=PRS
SELECT 
    CASE WHEN GROUPING(k.firma) = 1 THEN '** Alle Kunden **' ELSE k.firma END AS kunde,
    CASE WHEN GROUPING(p.bezeichnung) = 1 THEN '** Alle Projekte **' ELSE p.bezeichnung END AS projekt,
    SUM(p.mittel) AS budget_summe
FROM Projekt AS p
INNER JOIN Kunde AS k ON p.kunde_id = k.id
GROUP BY 
    GROUPING SETS (
        (),
        k.firma,
        (k.firma, p.bezeichnung)
    )
ORDER BY 
    kunde ASC,
    projekt ASC;
-- noqa: enable=PRS
GO
