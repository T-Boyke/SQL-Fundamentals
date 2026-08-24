-- ============================================================================
-- 📅 Day_16: ProjektDB 08 - OUTER JOIN 1 - Lösungen
-- Datenbank: ProjektDB (MS SQL Server)
-- Autor: Tobias Boyke
-- Dozent: Tom S.
-- Datum: 24.08.2026
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- Aufgabe 8.1
-- Zeigen Sie die Id, Firma und die Stadt aller Kunden
-- an. Zeigen Sie dazu außerdem den Namen der Abteilungen 
-- an, die am Ort des Kunden ihren Sitz haben (bilden Sie 
-- den Join über den Ort).
--
-- Erwartetes Ergebnis:
-- id  firma                    ort          bezeichnung
-- 1   Im- und Export AG        München      Beratung
-- 1   Im- und Export AG        München      Diagnose
-- 1   Im- und Export AG        München      Einkauf
-- 2   Technische Produkte oHG  Ulm          Verkauf
-- 3   Frankreich-Reisen GmbH   Saarlouis    NULL
-- 4   Getränke Schneider       Heidenheim   NULL
-- 5   Finanzamt Ulm            Fürth        NULL
-- 6   100% Sonderzeichen AG    Baden_Baden  NULL
-- ============================================================================

SELECT k.id, k.firma, k.ort, a.bezeichnung
FROM Kunde AS k
LEFT JOIN Abteilung AS a ON k.ort = a.ort;
GO

-- ============================================================================
-- Aufgabe 8.2
-- Ändern Sie die Abfrage aus Aufgabe 8.1, so dass alle
-- Abteilungen angezeigt werden, und dazu die passenden
-- Kunden im selben Ort.
--
-- Erwartetes Ergebnis:
-- id    firma                    ort      bezeichnung
-- 1     Im- und Export AG        München  Beratung
-- 1     Im- und Export AG        München  Diagnose
-- NULL  NULL                     NULL     Freigabe
-- 1     Im- und Export AG        München  Einkauf
-- 2     Technische Produkte oHG  Ulm      Verkauf
-- ============================================================================

-- Variante mit RIGHT JOIN:
SELECT k.id, k.firma, k.ort, a.bezeichnung
FROM Kunde AS k
RIGHT JOIN Abteilung AS a ON k.ort = a.ort;
GO

-- Variante mit LEFT JOIN (Tabellenreihenfolge vertauscht):
-- SELECT k.id, k.firma, k.ort, a.bezeichnung
-- FROM Abteilung AS a
-- LEFT JOIN Kunde AS k ON a.ort = k.ort;
-- GO

-- ============================================================================
-- Aufgabe 8.3
-- Überarbeiten Sie die Abfrage aus der Aufgabe 8.1.
-- Statt NULL soll in der Spalte für die Abteilung der
-- Text '- k. A. -' angezeigt werden.
--
-- Erwartetes Ergebnis:
-- id  firma                    ort          bezeichnung
-- 1   Im- und Export AG        München      Beratung
-- 1   Im- und Export AG        München      Diagnose
-- 1   Im- und Export AG        München      Einkauf
-- 2   Technische Produkte oHG  Ulm          Verkauf
-- 3   Frankreich-Reisen GmbH   Saarlouis    - k. A. -
-- 4   Getränke Schneider       Heidenheim   - k. A. -
-- 5   Finanzamt Ulm            Fürth        - k. A. -
-- 6   100% Sonderzeichen AG    Baden_Baden  - k. A. -
-- ============================================================================

SELECT k.id, k.firma, k.ort,
       ISNULL(a.bezeichnung, '- k. A. -') AS bezeichnung
FROM Kunde AS k
LEFT JOIN Abteilung AS a ON k.ort = a.ort;
GO

-- ============================================================================
-- Aufgabe 8.4
-- Geben Sie eine Liste aller Kunden aus. Geben Sie zu den
-- Kunden auch das Projekt aus, sofern vorhanden.
--
-- Erwartetes Ergebnis:
-- firma                    ort          bezeichnung
-- Im- und Export AG        München      Merkur
-- Technische Produkte oHG  Ulm          Ariane
-- Frankreich-Reisen GmbH   Saarlouis    Apollo
-- Getränke Schneider       Heidenheim   Pluto
-- Finanzamt Ulm            Fürth        Gemini
-- 100% Sonderzeichen AG    Baden_Baden  NULL
-- ============================================================================

SELECT k.firma, k.ort, p.bezeichnung
FROM Kunde AS k
LEFT JOIN Projekt AS p ON k.id = p.kunde_id;
GO

-- ============================================================================
-- Aufgabe 8.5
-- Geben Sie jetzt nur die Kunden aus, zu denen es kein
-- Projekt gibt.
--
-- Erwartetes Ergebnis:
-- firma                  ort          bezeichnung
-- 100% Sonderzeichen AG  Baden_Baden  NULL
-- ============================================================================

SELECT k.firma, k.ort, p.bezeichnung
FROM Kunde AS k
LEFT JOIN Projekt AS p ON k.id = p.kunde_id
WHERE p.id IS NULL;
GO

-- ============================================================================
-- Aufgabe 8.6
-- Geben Sie eine Liste der Kunden mit Firma und Stadt aus.
-- Geben Sie dazu die Nachnamen der Mitarbeiter aus, die
-- im selben Ort wohnen.
--
-- Erwartetes Ergebnis:
-- firma                   ort         nachname
-- Im- und Export AG       München     Richter
-- Im- und Export AG       München     Vogel
-- Im- und Export AG       München     Schubert
-- Im- und Export AG       München     Keller
-- Frankreich-Reisen GmbH  Saarlouis   NULL
-- Getränke Schneider      Heidenheim  Wolf
-- ...
-- (10 Zeilen)
-- ============================================================================

SELECT k.firma, k.ort, m.nachname
FROM Kunde AS k
LEFT JOIN Mitarbeiter AS m ON k.ort = m.ort;
GO

-- ============================================================================
-- Aufgabe 8.7
-- Geben Sie wieder die Liste der Kunden aus. Geben Sie
-- diesmal dazu die Anzahl Mitarbeiter aus, die am selben
-- Ort wohnen.
--
-- Erwartetes Ergebnis:
-- firma                    ort          mitarbeiter
-- 100% Sonderzeichen AG    Baden_Baden  0
-- Finanzamt Ulm            Fürth        1
-- Getränke Schneider       Heidenheim   1
-- Im- und Export AG        München      4
-- Frankreich-Reisen GmbH   Saarlouis    0
-- Technische Produkte oHG  Ulm          2
-- ============================================================================

SELECT k.firma, k.ort,
       COUNT(m.id) AS mitarbeiter
FROM Kunde AS k
LEFT JOIN Mitarbeiter AS m ON k.ort = m.ort
GROUP BY k.firma, k.ort;
GO

-- ============================================================================
-- Aufgabe 8.8
-- Ergänzen Sie die Abfrage aus Aufgabe 8.7 und geben 
-- Sie zusätzlich noch die Anzahl Abteilungen aus, die
-- es am Ort des Kunden gibt.
--
-- Erwartetes Ergebnis:
-- firma                    stadt        mitarbeiter  abteilungen
-- 100% Sonderzeichen AG    Baden_Baden  0            0
-- Finanzamt Ulm            Fürth        1            0
-- Getränke Schneider       Heidenheim   1            0
-- Im- und Export AG        München      4            3
-- Frankreich-Reisen GmbH   Saarlouis    0            0
-- Technische Produkte oHG  Ulm          2            1
-- ============================================================================

-- Variante 1 (⭐ Standard mit DISTINCT zur Vermeidung des Kreuzprodukts):
SELECT k.firma,
       k.ort AS stadt,
       COUNT(DISTINCT m.id) AS mitarbeiter,
       COUNT(DISTINCT a.id) AS abteilungen
FROM Kunde AS k
LEFT JOIN Mitarbeiter AS m ON k.ort = m.ort
LEFT JOIN Abteilung AS a ON k.ort = a.ort
GROUP BY k.firma, k.ort;
GO

-- Variante 2 (Mit korrelierten Unterabfragen):
-- SELECT k.firma,
--        k.ort AS stadt,
--        (SELECT COUNT(*) FROM Mitarbeiter WHERE ort = k.ort) AS mitarbeiter,
--        (SELECT COUNT(*) FROM Abteilung WHERE ort = k.ort) AS abteilungen
-- FROM Kunde AS k;
-- GO
