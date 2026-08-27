-- ============================================================================
-- 🎓 IHK Abschlussprüfung: 5. Handlungsschritt (25 Punkte)
-- Szenario: Arztpraxis Terminverwaltung, Abrechnung & Transaktionen (ZPA FI Ganz I Anw)
-- Prüfungsdokumente:
--   - Aufgabe: Day_18/assets/AP 2022 S GA1 HS5 SQL Arzttermine - Aufgabe.pdf
--   - Lösung:  Day_18/assets/AP 2022 S GA1 HS5 SQL Arzttermine - Lösung.pdf
-- Datei: Day_18/src/03_ihk_abschlusspruefung_arzttermine_loesung.sql
-- Autor: Tobias Boyke
-- Datum: 26.08.2026 / Update 27.08.2026
-- ============================================================================

-- ============================================================================
-- 📋 Schema-Definition (Aufbau der Test-Tabellen für Übung & Verifikation)
-- ============================================================================

-- Bereinigung alter Tabellen falls vorhanden
IF OBJECT_ID('Termin', 'U') IS NOT NULL DROP TABLE Termin;
IF OBJECT_ID('Patient', 'U') IS NOT NULL DROP TABLE Patient;
IF OBJECT_ID('Arzt', 'U') IS NOT NULL DROP TABLE Arzt;
IF OBJECT_ID('Krankenkasse', 'U') IS NOT NULL DROP TABLE Krankenkasse;
GO

-- 1. Tabelle Arzt
CREATE TABLE Arzt (
    A_Id INT PRIMARY KEY,
    A_Nachname VARCHAR(100) NOT NULL,
    A_Vorname VARCHAR(100) NOT NULL
);

-- 2. Tabelle Krankenkasse
CREATE TABLE Krankenkasse (
    KK_Id INT PRIMARY KEY,
    KK_Name VARCHAR(100) NOT NULL
);

-- 3. Tabelle Patient
CREATE TABLE Patient (
    Pat_Id INT PRIMARY KEY,
    Pat_Nachname VARCHAR(100) NOT NULL,
    Pat_Vorname VARCHAR(100) NOT NULL,
    Pat_GebDat DATE NOT NULL,
    Pat_Strasse VARCHAR(100) NULL,
    Pat_PLZ VARCHAR(10) NULL,
    Pat_Ort VARCHAR(100) NULL,
    Pat_KKId INT NOT NULL,
    CONSTRAINT FK_Patient_Krankenkasse FOREIGN KEY (Pat_KKId) 
        REFERENCES Krankenkasse(KK_Id)
);

-- 4. Tabelle Termin
CREATE TABLE Termin (
    T_Id INT PRIMARY KEY,
    T_Termin DATETIME NOT NULL,
    T_PatId INT NOT NULL,
    T_AId INT NOT NULL,
    T_Wahrgenommen VARCHAR(10) NOT NULL, -- 'Ja' oder 'Nein'
    CONSTRAINT FK_Termin_Patient FOREIGN KEY (T_PatId) 
        REFERENCES Patient(Pat_Id),
    CONSTRAINT FK_Termin_Arzt FOREIGN KEY (T_AId) 
        REFERENCES Arzt(A_Id)
);
GO

-- ============================================================================
-- 📥 Testdaten-Befüllung (Prüfungsdaten gemäß IHK-Aufgabenstellung)
-- ============================================================================

INSERT INTO Arzt (A_Id, A_Nachname, A_Vorname) VALUES
(1, 'Freudenstedt', 'Dr. med. Rudolf'),
(2, 'Nierens', 'Dr. med. Kirsten'),
(3, 'Leier', 'Dr. Patrick');

INSERT INTO Krankenkasse (KK_Id, KK_Name) VALUES
(1, 'TK'),
(2, 'AOK'),
(3, 'BKK'),
(4, 'Knappschaft');

INSERT INTO Patient (Pat_Id, Pat_Nachname, Pat_Vorname, Pat_GebDat, Pat_Strasse, Pat_PLZ, Pat_Ort, Pat_KKId) VALUES
(1, 'Müller', 'Manni', '1966-04-15', 'Forstweg 12', '44456', 'Musterhausen', 1),
(2, 'Peters', 'Peter', '1988-03-12', NULL, NULL, NULL, 1),
(3, 'Fransi', 'Melanie', '1999-01-13', NULL, NULL, NULL, 2),
(4, 'Kastor', 'Heinz', '1952-12-14', NULL, NULL, NULL, 1),
(5, 'Krenz', 'Christina', '1977-02-14', NULL, NULL, NULL, 2),
(6, 'Kreisla', 'Johann', '1999-01-13', NULL, NULL, NULL, 3),
(7, 'Freie', 'Ilse', '1955-05-02', NULL, NULL, NULL, 2),
(8, 'König', 'Ihnes', '2002-03-01', NULL, NULL, NULL, 1);

INSERT INTO Termin (T_Id, T_Termin, T_PatId, T_AId, T_Wahrgenommen) VALUES
(1, '2022-06-01 12:10:00', 1, 1, 'Ja'),
(2, '2022-06-01 12:20:00', 2, 1, 'Nein'),
(3, '2022-06-01 12:10:00', 3, 2, 'Ja'),
(4, '2022-06-01 12:40:00', 4, 1, 'Ja'),
(5, '2022-06-01 12:50:00', 6, 1, 'Ja'),
(6, '2022-06-01 13:10:00', 8, 1, 'Ja'),
(7, '2022-06-01 12:20:00', 7, 1, 'Ja');
GO

-- ============================================================================
-- 📝 Aufgabe a) DQL: Anzahl der Termine im Juni 2022 je hinterlegtem Arzt (4 Punkte)
--
-- Aufgabenstellung:
-- Erstellen Sie eine SQL-Abfrage, mit der Sie die Anzahl der Termine im Juni 2022
-- von jedem hinterlegten Arzt nach folgendem Ergebnisbeispiel erhalten:
--
-- Ergebnisbeispiel:
-- Arzt         | Termine
-- Freudenstedt | 6
-- Nierens      | 1
-- Leier        | 0
-- ...
--
-- ⚠️ IHK-Falle: Dr. Leier hat 0 Termine. Ein INNER JOIN würde Dr. Leier
-- eliminieren. Pflicht: LEFT JOIN mit Datumsfiltern in der ON-Klausel!
-- ============================================================================

-- Variante 1: Standard LEFT JOIN (Empfohlene IHK-Musterlösung)
SELECT a.A_Nachname AS Arzt,
       COUNT(t.T_Id) AS Termine
FROM Arzt AS a
LEFT JOIN Termin AS t ON a.A_Id = t.T_AId
                     AND MONTH(t.T_Termin) = 6
                     AND YEAR(t.T_Termin) = 2022
GROUP BY a.A_Id, a.A_Nachname;

-- Variante 2: Skalare Subquery im SELECT (Ebenfalls laut IHK-Korrekturbogen zulässig)
SELECT a.A_Nachname AS Arzt,
       (
           SELECT COUNT(*)
           FROM Termin AS t
           WHERE t.T_AId = a.A_Id
             AND MONTH(t.T_Termin) = 6
             AND YEAR(t.T_Termin) = 2022
       ) AS Termine
FROM Arzt AS a;
GO

-- ============================================================================
-- 📝 Aufgabe b) DQL: Patienten und zugehörige Krankenkasse (6 Punkte)
--
-- Aufgabenstellung:
-- Erstellen Sie eine SQL-Abfrage, mit der Sie die Patienten und deren zugehörige
-- Krankenkasse nach folgendem Ergebnisbeispiel erhalten:
-- (Sortierung nach KK_Name absteigend und Pat_GebDat aufsteigend)
--
-- Ergebnisbeispiel:
-- KK_Name | Pat_Id | Pat_Nachname | Pat_Vorname | Pat_GebDat | Pat_Strasse | Pat_PLZ | Pat_Ort | Pat_KKId
-- TK      | 4      | Kastor       | Heinz       | 1952-12-14 | NULL        | NULL    | NULL    | 1
-- TK      | 1      | Müller       | Manni       | 1966-04-15 | Forstweg 12 | 44456   | Muster..| 1
-- ...
-- ============================================================================

SELECT k.KK_Name,
       p.Pat_Id,
       p.Pat_Nachname,
       p.Pat_Vorname,
       p.Pat_GebDat,
       p.Pat_Strasse,
       p.Pat_PLZ,
       p.Pat_Ort,
       p.Pat_KKId
FROM Patient AS p
INNER JOIN Krankenkasse AS k ON p.Pat_KKId = k.KK_Id
ORDER BY k.KK_Name DESC, p.Pat_GebDat ASC;
GO

-- ============================================================================
-- 📝 Aufgabe c) DQL: Abrechnung der Termine im Juni 2022 für alle Krankenkassen (10 Punkte)
--
-- Aufgabenstellung:
-- Erstellen Sie eine SQL-Abfrage, mit der Sie für alle Krankenkassen eine
-- Abrechnung der Termine im Juni 2022 erhalten.
--
-- Bedingungen:
-- - Wahrgenommene Termine werden mit 22,50 EUR berechnet.
-- - Nicht wahrgenommene Termine bleiben unberücksichtigt.
-- - Sortierung soll nach Krankenkasse (KK_Name) aufsteigend vorgenommen werden.
-- - Alle Krankenkassen (inkl. Knappschaft mit 0 Terminen) müssen enthalten sein.
--
-- Ergebnisbeispiel:
-- Krankenkasse | Betrag
-- AOK          | 45
-- BKK          | 22.5
-- Knappschaft  | 0
-- TK           | 67.5
-- ============================================================================

SELECT k.KK_Name AS Krankenkasse,
       COUNT(t.T_Id) * 22.5 AS Betrag
FROM Krankenkasse AS k
LEFT JOIN Patient AS p ON k.KK_Id = p.Pat_KKId
LEFT JOIN Termin AS t ON p.Pat_Id = t.T_PatId
                     AND MONTH(t.T_Termin) = 6
                     AND YEAR(t.T_Termin) = 2022
                     AND t.T_Wahrgenommen = 'Ja'
GROUP BY k.KK_Id, k.KK_Name
ORDER BY k.KK_Name ASC;
GO

-- ============================================================================
-- 📝 Aufgabe d) Theorie: Begriff Transaktion (2 Punkte)
--
-- Aufgabenstellung:
-- Im Zusammenhang mit SQL-Statements werden häufig Transaktionen verwendet.
-- Erläutern Sie den Begriff Transaktion.
--
-- Musterantwort (IHK-Bewertung):
-- Eine Transaktion ist eine logische Arbeitseinheit (Logical Unit of Work),
-- die aus einer Folge von einem oder mehreren SQL-Befehlen (DML/DDL) besteht.
-- Sie folgt dem ACID-Prinzip und garantiert das "Alles-oder-Nichts-Prinzip":
-- Entweder werden alle Operationen vollständig und fehlerfrei ausgeführt,
-- oder bei einem Fehler wird die gesamte Transaktion rückgängig gemacht,
-- sodass die Datenbank stets in einem konsistenten Zustand verbleibt.
--
-- ACID-Eigenschaften im Überblick:
-- A (Atomicity / Atomarität): Unteilbarkeit der Operationen.
-- C (Consistency / Konsistenz): Wahrung aller Integritätsbedingungen.
-- I (Isolation / Isolation): Parallele Transaktionen stören sich nicht gegenseitig.
-- D (Durability / Dauerhaftigkeit): Bestätigte Daten überleben Systemabstürze.
-- ============================================================================

-- ============================================================================
-- 📝 Aufgabe e) Theorie & TCL: Befehlssyntax einer Transaktion (3 Punkte)
--
-- Aufgabenstellung:
-- Beschreiben Sie die Funktion für folgende Syntax im Bezug einer Transaktion:
-- - BEGIN TRANSACTION
-- - COMMIT
-- - ROLLBACK
--
-- Musterantworten (IHK-Bewertung):
-- 1. BEGIN TRANSACTION:
--    Startet die Transaktion / leitet eine neue logische Arbeitseinheit ein.
--    Alle nachfolgenden Modifikationen werden transaktionsgesichert ausgeführt.
--
-- 2. COMMIT (oder COMMIT TRANSACTION / COMMIT WORK):
--    Beendet die Transaktion erfolgreich und speichert alle vorgenommenen
--    Änderungen dauerhaft und unwiderruflich in der Datenbank ab.
--
-- 3. ROLLBACK (oder ROLLBACK TRANSACTION / ROLLBACK WORK):
--    Beendet die Transaktion im Fehlerfall und setzt alle seit dem
--    BEGIN TRANSACTION ausgeführten Änderungen auf den Ausgangsstand zurück.
-- ============================================================================

-- ============================================================================
-- 💡 Praxis-Demonstration: Transaktion mit strukturierter Fehlerbehandlung (T-SQL)
-- ============================================================================

BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Neuen Ersatztermin eintragen
    INSERT INTO Termin (T_Id, T_Termin, T_PatId, T_AId, T_Wahrgenommen)
    VALUES (8, '2022-06-15 09:00:00', 2, 1, 'Ja');

    -- 2. Alten nicht wahrgenommenen Termin archivieren / aktualisieren
    UPDATE Termin
    SET T_Wahrgenommen = 'Storniert'
    WHERE T_Id = 2;

    -- Wenn alle Anweisungen fehlerfrei durchliefen: Dauerhaft speichern!
    COMMIT TRANSACTION;
    PRINT 'Transaktion erfolgreich ausgefuehrt und bestaetigt (COMMIT).';
END TRY
BEGIN CATCH
    -- Bei Fehlern: Kompletten Rollback ausführen
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Fehler aufgetreten! Transaktion wurde rueckgaengig gemacht (ROLLBACK).';
    END;
    THROW;
END CATCH;
GO
