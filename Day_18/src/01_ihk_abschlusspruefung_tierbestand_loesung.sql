-- ============================================================================
-- 🎓 IHK Abschlussprüfung: 4. Handlungsschritt (25 Punkte)
-- Szenario: Datenbank der Tierbestandsverwaltung & Archivierung (ZPA FIA II)
-- Datei: Day_18/src/01_ihk_abschlusspruefung_tierbestand_loesung.sql
-- Autor: Tobias Boyke
-- Datum: 26.08.2026
-- ============================================================================

-- ============================================================================
-- 📋 Schema-Definition (Aufbau der Test-Tabellen für Übung & Verifikation)
-- ============================================================================

-- Bereinigung alter Tabellen falls vorhanden
IF OBJECT_ID('TierZusatzInfo', 'U') IS NOT NULL DROP TABLE TierZusatzInfo;
IF OBJECT_ID('Archiv_Tierbestand', 'U') IS NOT NULL DROP TABLE Archiv_Tierbestand;
IF OBJECT_ID('Tierbestand', 'U') IS NOT NULL DROP TABLE Tierbestand;
IF OBJECT_ID('Tierkategorie', 'U') IS NOT NULL DROP TABLE Tierkategorie;
GO

-- 1. Tabelle Tierkategorie
CREATE TABLE Tierkategorie (
    TK_ID INT PRIMARY KEY,
    TK_Kategorie VARCHAR(100) NOT NULL
);

-- 2. Tabelle Tierbestand
CREATE TABLE Tierbestand (
    TB_ID INT PRIMARY KEY,
    TB_TKID INT NOT NULL,
    TB_ChipNr VARCHAR(50) NOT NULL,
    TB_GebDat DATE NOT NULL,
    TB_SchlachtDat DATE NULL,
    CONSTRAINT FK_Tierbestand_Tierkategorie FOREIGN KEY (TB_TKID) 
        REFERENCES Tierkategorie(TK_ID)
);

-- 3. Tabelle TierZusatzInfo
CREATE TABLE TierZusatzInfo (
    TZI_ID INT PRIMARY KEY,
    TZI_TBID INT NOT NULL,
    TZI_ErfasstAm DATE NOT NULL,
    TZI_Gewicht DECIMAL(10, 2) NOT NULL,
    TZI_Bemerkung VARCHAR(255) NULL,
    CONSTRAINT FK_TierZusatzInfo_Tierbestand FOREIGN KEY (TZI_TBID) 
        REFERENCES Tierbestand(TB_ID)
);

-- 4. Tabelle Archiv_Tierbestand (Ziel-Tabelle für Aufgabe 4 c)
CREATE TABLE Archiv_Tierbestand (
    A_TBID INT PRIMARY KEY,
    A_Tierkategorie VARCHAR(100) NOT NULL,
    A_ChipNr VARCHAR(50) NOT NULL,
    A_GebDat DATE NOT NULL,
    A_SchlachtDat DATE NOT NULL,
    A_MaxGewicht DECIMAL(10, 2) NULL
);
GO

-- ============================================================================
-- 📥 Testdaten-Befüllung (Prüfungsdaten gemäß Aufgabenstellung)
-- ============================================================================

INSERT INTO Tierkategorie (TK_ID, TK_Kategorie) VALUES
(1, 'Kühe'),
(2, 'Schweine'),
(3, 'Hühner');

INSERT INTO Tierbestand (TB_ID, TB_TKID, TB_ChipNr, TB_GebDat, TB_SchlachtDat) VALUES
-- Lebende Tiere (TB_SchlachtDat IS NULL)
(1001, 2, 'S03-333-567', '2022-01-03', NULL),
(1002, 2, 'S03-343-566', '2022-01-05', NULL),
(1003, 1, 'K77-899988', '2021-08-12', NULL),
(1004, 2, 'S12-222-322', '2024-11-03', NULL),
-- Geschlachtete Tiere (TB_SchlachtDat IS NOT NULL - für Archivierung)
(505, 2, 'S02-333-322', '2020-04-01', '2023-04-01'),
(506, 2, 'S02-343-166', '2021-05-05', '2023-04-01'),
(508, 1, 'K55-899777', '2021-05-05', '2023-04-05');

INSERT INTO TierZusatzInfo (TZI_ID, TZI_TBID, TZI_ErfasstAm, TZI_Gewicht, TZI_Bemerkung) VALUES
-- Wiegedaten für lebende Tiere
(1, 1003, '2026-02-12', 334.00, 'ohne Befund'),
(2, 1001, '2026-02-12', 655.00, 'ohne Befund'),
(3, 1003, '2026-03-11', 342.00, 'schläfrig'),
(4, 1003, '2026-04-12', 344.00, 'ohne Befund'),
-- Wiegedaten für geschlachtete Tiere
(5, 505, '2022-01-10', 410.00, 'Erstmessung'),
(6, 505, '2023-03-20', 466.00, 'Schlachtgewicht'),
(7, 506, '2023-03-20', 578.00, 'Schlachtgewicht'),
(8, 508, '2023-04-01', 712.00, 'Schlachtgewicht');
GO

-- ============================================================================
-- 📝 Aufgabe 4.a) CRUD-Matrix & SQL-Kategorien (3 Punkte)
-- ============================================================================
/*
+-------------------+---------------------+--------------------+--------------------+--------------------+
| Grundlegende      | Bedeutung           | DDL Data           | DML Data           | DQL Data           |
| Datenoperationen  |                     | Definition Lang.   | Manipulation Lang. | Query Language     |
+-------------------+---------------------+--------------------+--------------------+--------------------+
| C (reate)         | Anlegen, Erstellen  | CREATE             | INSERT             | X                  |
| R (ead)           | Lesen               | X                  | X                  | SELECT             |
| U (pdate)         | Aktualisieren       | ALTER              | UPDATE             | X                  |
| D (elete)         | Löschen             | DROP (TRUNCATE)    | DELETE             | X                  |
+-------------------+---------------------+--------------------+--------------------+--------------------+
*/

-- ============================================================================
-- 📝 Aufgabe 4.b) DQL: Auflistung aller Tierkategorien der lebenden Tiere (8 Punkte)
-- 
-- Aufgabenstellung:
-- Auflistung aller Tier-Kategorien mit:
-- - Anzahl des Tierbestandes
-- - Gewicht des schwersten Tieres
-- - Alter des ältesten Tieres
-- - Durchschnittliches Alter
-- 
-- Ergebnistabelle:
-- TK_Kategorie | AnzahlTiere | SchwerstesTier | ÄltestesTier | DurchschnittAlter
-- Hühner       | 0           | NULL           | NULL         | NULL
-- Kühe         | 3           | 344            | 4            | 4
-- Schweine     | 3           | 655            | 1            | 2
-- ============================================================================

SELECT tk.TK_Kategorie,
       COUNT(DISTINCT tb.TB_ID) AS AnzahlTiere,
       MAX(tzi.TZI_Gewicht) AS SchwerstesTier,
       MAX(DATEDIFF(YEAR, tb.TB_GebDat, '2026-08-26')) AS ÄltestesTier,
       AVG(DATEDIFF(YEAR, tb.TB_GebDat, '2026-08-26')) AS DurchschnittAlter
FROM Tierkategorie AS tk
LEFT JOIN Tierbestand AS tb ON tk.TK_ID = tb.TB_TKID 
                            AND tb.TB_SchlachtDat IS NULL
LEFT JOIN TierZusatzInfo AS tzi ON tb.TB_ID = tzi.TZI_TBID
GROUP BY tk.TK_ID, tk.TK_Kategorie
ORDER BY tk.TK_Kategorie ASC;
GO

-- ============================================================================
-- 📝 Aufgabe 4.ca) DML: Archivierung der geschlachteten Tiere (10 Punkte)
-- 
-- Aufgabenstellung:
-- Alle Daten der geschlachteten Tiere, der Tierkategorie und dem höchsten
-- gewogenen Gewicht in die Tabelle Archiv_Tierbestand über einen Befehl archivieren.
-- ============================================================================

INSERT INTO Archiv_Tierbestand (A_TBID, A_Tierkategorie, A_ChipNr, A_GebDat, A_SchlachtDat, A_MaxGewicht)
SELECT tb.TB_ID,
       tk.TK_Kategorie,
       tb.TB_ChipNr,
       tb.TB_GebDat,
       tb.TB_SchlachtDat,
       MAX(tzi.TZI_Gewicht) AS A_MaxGewicht
FROM Tierbestand AS tb
INNER JOIN Tierkategorie AS tk ON tb.TB_TKID = tk.TK_ID
LEFT JOIN TierZusatzInfo AS tzi ON tb.TB_ID = tzi.TZI_TBID
WHERE tb.TB_SchlachtDat IS NOT NULL
GROUP BY tb.TB_ID, tk.TK_Kategorie, tb.TB_ChipNr, tb.TB_GebDat, tb.TB_SchlachtDat;
GO

-- Kontrolle des Archivierungs-Ergebnisses
SELECT * FROM Archiv_Tierbestand;
GO

-- ============================================================================
-- 📝 Aufgabe 4.cb) DML: Bereinigung der Quelldaten (4 Punkte)
-- 
-- Aufgabenstellung:
-- Danach sollen alle zugehörigen Daten der archivierten Datensätze aus
-- den Tabellen entfernt werden.
-- 
-- WICHTIG: Referentielle Integrität!
-- Zuerst Kind-Tabelle (TierZusatzInfo) löschen, dann Eltern-Tabelle (Tierbestand)!
-- ============================================================================

-- Schritt 1: Detail-Daten der archivierten Tiere löschen (Child Table)
DELETE FROM TierZusatzInfo
WHERE TZI_TBID IN (SELECT A_TBID FROM Archiv_Tierbestand);
GO

-- Schritt 2: Haupt-Datensätze der archivierten Tiere löschen (Parent Table)
DELETE FROM Tierbestand
WHERE TB_ID IN (SELECT A_TBID FROM Archiv_Tierbestand);
GO

-- Kontrolle: Nur noch lebende Tiere vorhanden
SELECT * FROM Tierbestand;
SELECT * FROM TierZusatzInfo;
GO
