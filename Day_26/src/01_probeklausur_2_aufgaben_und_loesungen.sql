-- ============================================================================
-- SQL-Fundamentals: Day 26 - Intensiv-Repetitorium & Klausurvorbereitung II
-- Datei: 01_probeklausur_2_aufgaben_und_loesungen.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 07.09.2026
-- Fokus: Generalprobe / Probeklausur II für die Abschlussklausur (Tag 27)
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- 📝 PROBEKLAUSUR II: 6 AUFGABENKOMPLEXE ZUR GENERALPROBE
-- ============================================================================


-- ----------------------------------------------------------------------------
-- AUFGABE 1: Multi-Table JOIN, Aggregation & HAVING
-- ----------------------------------------------------------------------------
-- Aufgabenstellung:
-- Ermitteln Sie für jede Abteilung den Abteilungsnamen (bezeichnung), den Standort (ort),
-- die Anzahl der beschäftigten Mitarbeiter sowie das Durchschnittsgehalt.
-- Es sollen nur Abteilungen ausgegeben werden, die mindestens 2 Mitarbeiter
-- beschäftigen und deren Durchschnittsgehalt über 3.000 EUR liegt.
-- Sortieren Sie das Ergebnis absteigend nach dem Durchschnittsgehalt.
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> AUFGABE 1: Multi-Table JOIN & HAVING';
PRINT '======================================================================';

SELECT a.bezeichnung AS Abteilung,
       a.ort AS Standort,
       COUNT(m.id) AS AnzahlMitarbeiter,
       ROUND(AVG(g.gehalt), 2) AS Durchschnittsgehalt
FROM dbo.Abteilung AS a
INNER JOIN dbo.Mitarbeiter AS m ON a.id = m.abt_id
INNER JOIN dbo.Gehalt AS g ON m.id = g.mit_id
GROUP BY a.id, a.bezeichnung, a.ort
HAVING COUNT(m.id) >= 2 
   AND AVG(g.gehalt) > 3000.00
ORDER BY Durchschnittsgehalt DESC;
GO


-- ----------------------------------------------------------------------------
-- AUFGABE 2: Unterabfrage (Subquery) mit NOT EXISTS / NOT IN
-- ----------------------------------------------------------------------------
-- Aufgabenstellung:
-- Finden Sie alle Kunden (ID, Firma, Ort), für die aktuell KEIN Projekt
-- in der Datenbank hinterlegt ist.
-- Formulieren Sie die Lösung einmal mit NOT EXISTS und einmal mit Anti-Join.
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> AUFGABE 2: Kunden ohne Projekte (Anti-Pattern)';
PRINT '======================================================================';

-- Variante A: Mit NOT EXISTS (Best Practice für Performance & NULL-Sicherheit)
SELECT k.id, k.firma, k.ort
FROM dbo.Kunde AS k
WHERE NOT EXISTS (
    SELECT 1 
    FROM dbo.Projekt AS p 
    WHERE p.kunde_id = k.id
);

-- Variante B: Mit LEFT JOIN und IS NULL (Anti-Join)
SELECT k.id, k.firma, k.ort
FROM dbo.Kunde AS k
LEFT JOIN dbo.Projekt AS p ON k.id = p.kunde_id
WHERE p.id IS NULL;
GO


-- ----------------------------------------------------------------------------
-- AUFGABE 3: Mengenoperatoren (UNION ALL mit Herkunfts-Klassifizierung)
-- ----------------------------------------------------------------------------
-- Aufgabenstellung:
-- Erstellen Sie eine Gesamtkontaktliste aller Standorte aus Kunden und Abteilungen.
-- Spalten: Name (Firma bzw. Abteilungsname), Stadt (Ort), Typ ('Kunde' bzw. 'Abteilung').
-- Sortieren Sie alphabetisch nach der Stadt.
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> AUFGABE 3: Mengenoperatoren (UNION ALL)';
PRINT '======================================================================';

SELECT firma AS Name,
       ort AS Stadt,
       'Kunde' AS KontaktTyp
FROM dbo.Kunde

UNION ALL

SELECT bezeichnung AS Name,
       ort AS Stadt,
       'Abteilung' AS KontaktTyp
FROM dbo.Abteilung
ORDER BY Stadt ASC, Name ASC;
GO


-- ----------------------------------------------------------------------------
-- AUFGABE 4: T-SQL CASE-Ausdruck zur Gehaltseinstufung
-- ----------------------------------------------------------------------------
-- Aufgabenstellung:
-- Geben Sie für alle Mitarbeiter den vollständigen Namen (Vor- und Nachname),
-- das Gehalt und eine Gehaltskategorie aus:
--   - Gehalt >= 4.500 EUR ➔ 'Top-Verdiener'
--   - Gehalt >= 3.000 EUR ➔ 'Standard-Vergütung'
--   - darunter             ➔ 'Basis-Vergütung'
-- Berücksichtigen Sie auch Mitarbeiter, die eventuell keinen Gehaltseintrag haben
-- mit dem Text 'Kein Gehalt hinterlegt'.
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> AUFGABE 4: Komplexe CASE-Klassifizierung';
PRINT '======================================================================';

SELECT CONCAT(m.vorname, ' ', m.nachname) AS MitarbeiterName,
       g.gehalt AS Monatsgehalt,
       CASE 
           WHEN g.gehalt IS NULL THEN 'Kein Gehalt hinterlegt'
           WHEN g.gehalt >= 4500.00 THEN 'Top-Verdiener'
           WHEN g.gehalt >= 3000.00 THEN 'Standard-Vergütung'
           ELSE 'Basis-Vergütung'
       END AS Gehaltskategorie
FROM dbo.Mitarbeiter AS m
LEFT JOIN dbo.Gehalt AS g ON m.id = g.mit_id
ORDER BY g.gehalt DESC;
GO


-- ----------------------------------------------------------------------------
-- AUFGABE 5: Stored Procedure mit Validierung & Fehlerbehandlung
-- ----------------------------------------------------------------------------
-- Aufgabenstellung:
-- Erstellen Sie eine gespeicherte Prozedur "usp_MitarbeiterDetails",
-- die für eine übergebene Mitarbeiter-ID (@mit_id) folgende Daten ausgibt:
-- Vorname, Nachname, Wohnort, Abteilungsbezeichnung und Gehalt.
-- Falls die ID nicht existiert, soll die Meldung 'Mitarbeiter <ID> nicht gefunden!'
-- ausgegeben werden.
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> AUFGABE 5: Stored Procedure mit Validierung';
PRINT '======================================================================';

CREATE OR ALTER PROCEDURE dbo.usp_MitarbeiterDetails
    @mit_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validierung mit IF NOT EXISTS
    IF NOT EXISTS (SELECT 1 FROM dbo.Mitarbeiter WHERE id = @mit_id)
    BEGIN
        SELECT CONCAT('Mitarbeiter ', @mit_id, ' nicht gefunden!') AS Fehlermeldung;
        PRINT CONCAT('Hinweis: Mitarbeiter ', @mit_id, ' existiert nicht.');
        RETURN 1;
    END;

    -- Ausgabe der Details
    SELECT m.id AS Personalnummer,
           m.vorname AS Vorname,
           m.nachname AS Nachname,
           m.ort AS Wohnort,
           a.bezeichnung AS Abteilung,
           g.gehalt AS Monatsgehalt
    FROM dbo.Mitarbeiter AS m
    LEFT JOIN dbo.Abteilung AS a ON m.abt_id = a.id
    LEFT JOIN dbo.Gehalt AS g ON m.id = g.mit_id
    WHERE m.id = @mit_id;

    RETURN 0;
END;
GO

-- Testläufe:
PRINT '--- Test 1: Gültige ID (25348) ---';
EXEC dbo.usp_MitarbeiterDetails @mit_id = 25348;

PRINT '--- Test 2: Ungültige ID (-999) ---';
EXEC dbo.usp_MitarbeiterDetails @mit_id = -999;
GO


-- ----------------------------------------------------------------------------
-- AUFGABE 6: Skalare benutzerdefinierte Funktion (UDF)
-- ----------------------------------------------------------------------------
-- Aufgabenstellung:
-- Erstellen Sie eine skalare Funktion "udf_BerechneJahresgehalt",
-- die das Monatsgehalt und einen optionalen Weihnachtsgeld-Faktor
-- (Default: 1.0 für volles 13. Monatsgehalt) entgegennimmt und das
-- Jahresbruttogehalt berechnet.
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> AUFGABE 6: Skalare Funktion (UDF)';
PRINT '======================================================================';

CREATE OR ALTER FUNCTION dbo.udf_BerechneJahresgehalt (
    @monatsgehalt DECIMAL(10, 2),
    @weihnachtsgeldFaktor DECIMAL(3, 2) = 1.00
)
RETURNS DECIMAL(12, 2)
AS
BEGIN
    IF @monatsgehalt IS NULL OR @monatsgehalt <= 0
        RETURN 0.00;

    -- 12 reguläre Monate + optionales Weihnachtsgeld
    DECLARE @jahresGehalt DECIMAL(12, 2);
    SET @jahresGehalt = (@monatsgehalt * 12.00) + (@monatsgehalt * @weihnachtsgeldFaktor);

    RETURN @jahresGehalt;
END;
GO

-- Testabfrage mit Funktionsaufruf direkt im SELECT:
SELECT m.id,
       m.nachname,
       g.gehalt AS Monatsgehalt,
       dbo.udf_BerechneJahresgehalt(g.gehalt, DEFAULT) AS Jahresgehalt_13Monate,
       dbo.udf_BerechneJahresgehalt(g.gehalt, 0.50) AS Jahresgehalt_12Komma5Monate
FROM dbo.Mitarbeiter AS m
INNER JOIN dbo.Gehalt AS g ON m.id = g.mit_id;
GO
