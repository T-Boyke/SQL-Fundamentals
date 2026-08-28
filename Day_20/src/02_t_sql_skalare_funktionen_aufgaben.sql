-- ============================================================================
-- SQL-Fundamentals: Day 20 - T-SQL Funktionen & CASE-Ausdrücke
-- Datei: 02_t_sql_skalare_funktionen_aufgaben.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 28.08.2026
-- Single Source of Truth (SoT): ProjektDB
-- ============================================================================

USE ProjektDB;
GO

SET LANGUAGE german;
GO

-- ============================================================================
-- Aufgabe 9.5: Mitarbeiter-Code-Generator
-- ----------------------------------------------------------------------------
-- Generieren Sie Codes für Ihre Mitarbeiter. Der Code soll bestehen aus:
--   - Erster Buchstabe Nachname
--   - Vierter Buchstabe Nachname (groß)
--   - Letzter Buchstabe Vorname (groß)
--   - Abteilungskürzel rückwärts (EK => KE)
--
-- Erwartete Spalten: nachname, vorname, kuerzel, code
-- Beispiel: Kaufmann Brigitte DI => KFEID
-- ============================================================================

PRINT '=== Aufgabe 9.5: Mitarbeiter-Code-Generator ===';

SELECT m.nachname,
       m.vorname,
       abt.kuerzel,
       CONCAT(
           LEFT(m.nachname, 1),
           UPPER(SUBSTRING(m.nachname, 4, 1)),
           UPPER(RIGHT(m.vorname, 1)),
           REVERSE(abt.kuerzel)
       ) AS code
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS abt ON m.abt_id = abt.id;
GO


-- ============================================================================
-- Aufgabe 9.6: Vor- und Nachname kombiniert (CONCAT & TRIM)
-- ----------------------------------------------------------------------------
-- Geben Sie den Vor- und Nachnamen der Mitarbeiter in einer Spalte aus. 
-- Nutzen Sie die Funktionen CONCAT() und ggf. TRIM().
--
-- Erwartetes Ergebnis: 15 Zeilen
-- ============================================================================

PRINT '=== Aufgabe 9.6: Vollständiger Name mit CONCAT() ===';

SELECT CONCAT(TRIM(vorname), ' ', TRIM(nachname)) AS name
FROM Mitarbeiter;
GO


-- ============================================================================
-- Aufgabe 9.7: Name und Wohnort mit NULL-Handling
-- ----------------------------------------------------------------------------
-- Geben Sie Vor- und Nachnamen gefolgt vom Wohnort in einer Spalte aus.
-- Wenn kein Wohnort vorhanden ist, soll der Text 'unbekannt' erscheinen.
--
-- Erwartetes Ergebnis: 15 Zeilen (z.B. 'Brigitte Kaufmann, unbekannt')
-- ============================================================================

PRINT '=== Aufgabe 9.7: Name & Ort mit COALESCE / ISNULL ===';

SELECT CONCAT(
           TRIM(vorname), ' ', 
           TRIM(nachname), ', ', 
           COALESCE(ort, 'unbekannt')
       ) AS mitarbeiter
FROM Mitarbeiter;
GO


-- ============================================================================
-- Aufgabe 9.8: Namenskürzel (LEFT & CONCAT)
-- ----------------------------------------------------------------------------
-- Geben Sie die Kurzform des Mitarbeiternamens in einer Spalte aus.
-- (z. B. 'B. Kaufmann', 'S. Schäfer')
--
-- Erwartetes Ergebnis: 15 Zeilen
-- ============================================================================

PRINT '=== Aufgabe 9.8: Namenskürzel (LEFT & CONCAT) ===';

SELECT CONCAT(LEFT(TRIM(vorname), 1), '. ', TRIM(nachname)) AS name
FROM Mitarbeiter;
GO


-- ============================================================================
-- Aufgabe 9.9: Sortierung nach Namenslänge & Alphabet (LEN)
-- ----------------------------------------------------------------------------
-- Geben Sie die Nachnamen der Mitarbeiter aus und sortieren Sie die 
-- Ausgabe nach der Länge der Namen aufsteigend. Bei gleicher Länge 
-- soll alphabetisch absteigend sortiert werden.
--
-- Erwartetes Ergebnis: 15 Zeilen
-- ============================================================================

PRINT '=== Aufgabe 9.9: Sortierung nach LEN() und Alphabet ===';

SELECT nachname
FROM Mitarbeiter
ORDER BY LEN(nachname) ASC, nachname DESC;
GO


-- ============================================================================
-- Aufgabe 9.10: Erster Vokal im Nachnamen (PATINDEX)
-- ----------------------------------------------------------------------------
-- Zeigen Sie die Namen aller Mitarbeiter an und geben Sie dazu die Position 
-- des ersten Vokals an. Nutzen Sie die Funktion PATINDEX().
--
-- Erwartete Spalten: nachname, erster_vokal (15 Zeilen)
-- ============================================================================

PRINT '=== Aufgabe 9.10: Erster Vokal mit PATINDEX() ===';

SELECT nachname,
       PATINDEX('%[aeiouäöü]%', LOWER(nachname)) AS erster_vokal
FROM Mitarbeiter;
GO


-- ============================================================================
-- Aufgabe 9.11: Bruttotage im Modul (DATEDIFF & GETDATE)
-- ----------------------------------------------------------------------------
-- Berechnen Sie die Anzahl der Tage (brutto), die Sie bereits in diesem 
-- Modul verbringen durften. Nutzen Sie DATEDIFF() und GETDATE().
-- ============================================================================

PRINT '=== Aufgabe 9.11: Moduldauer in Tagen mit DATEDIFF() ===';

-- Variante A: Kursbeginn 01.08.2024 (Referenz aus Aufgabenblatt)
SELECT DATEDIFF(day, '2024-08-01', GETDATE()) AS tage_in_modul_2024;

-- Variante B: Kursbeginn aktueller Zyklus (August 2026)
SELECT DATEDIFF(day, '2026-08-03', GETDATE()) AS tage_in_modul_2026;
GO


-- ============================================================================
-- Aufgabe 9.12: Volltext-Datumsformatierung (DATENAME, DATEPART, CONCAT)
-- ----------------------------------------------------------------------------
-- Schreiben Sie eine Abfrage, die das heutige Datum formatiert ausgibt.
-- Format: "Heute ist Freitag, der 28. August des Jahres 2026 in der 35. Kalenderwoche"
-- ============================================================================

PRINT '=== Aufgabe 9.12: Volltext-Datumsformatierung ===';

SELECT CONCAT(
           'Heute ist ', 
           DATENAME(dw, GETDATE()), 
           ', der ', 
           DATEPART(dd, GETDATE()), 
           '. ', 
           DATENAME(mm, GETDATE()), 
           ' des Jahres ', 
           DATEPART(yy, GETDATE()), 
           ' in der ', 
           DATEPART(wk, GETDATE()), 
           '. Kalenderwoche'
       ) AS datum_formatiert;
GO


-- ============================================================================
-- Aufgabe 9.13: Tag des Jahres (DATEPART)
-- ----------------------------------------------------------------------------
-- Der wievielte Tag des Jahres ist heute?
-- Erwartete Spalten: datum, tag_des_jahres
-- ============================================================================

PRINT '=== Aufgabe 9.13: Tag des Jahres (dayofyear) ===';

SELECT CAST(GETDATE() AS DATE) AS datum,
       DATEPART(dayofyear, GETDATE()) AS tag_des_jahres;
GO


-- ============================================================================
-- Aufgabe 9.14: Gehaltskategorisierung mit IIF()
-- ----------------------------------------------------------------------------
-- Kategorisieren Sie Ihre Mitarbeiter. 
-- - Gehalt unter 4000 => Kategorie A
-- - Sonst              => Kategorie B
-- Nutzen Sie IIF() statt CASE.
--
-- Erwartete Spalten: mit_id, gehalt, kategorie
-- ============================================================================

PRINT '=== Aufgabe 9.14: Gehalts-Klassifizierung mit IIF() ===';

SELECT g.mit_id,
       g.gehalt,
       IIF(g.gehalt < 4000.00, 'A', 'B') AS kategorie
FROM Gehalt AS g;
GO
