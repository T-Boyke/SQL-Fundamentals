-- ============================================================================
-- SQL-Fundamentals: Day 24 - T-SQL Prozedurale Programmierung
-- Datei: 10_projektdb_p1_programmierung_2_loesungen.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 03.09.2026
-- Kursunterlagen: assets/ProjektDB P1 - Programmierung 2 - Aufgaben.sql
-- Fokus: Musterlösung Aufgaben P1.3 (sp_FilterMitarbeiter2) & P1.4 (Neues Projekt anlegen)
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- AUFGABE P1.3: sp_FilterMitarbeiter2 (Gehalts-Range Filterung)
-- ----------------------------------------------------------------------------
-- Aufgabenstellung:
-- Erstellen Sie eine gespeicherte Prozedur "sp_FilterMitarbeiter2",
-- die eine Liste der Mitarbeiter ausgibt, die in einer bestimmten
-- Gehalts-Range liegen. Die Prozedur soll die beiden Parameter
-- @MinGehalt und @MaxGehalt entgegennehmen. Wenn es keine passenden
-- Mitarbeiter gibt, soll eine entsprechende Meldung ausgegeben werden.
-- ============================================================================

PRINT '======================================================================';
PRINT '>>> AUFGABE P1.3: Erstelle dbo.sp_FilterMitarbeiter2';
PRINT '======================================================================';

CREATE OR ALTER PROCEDURE dbo.sp_FilterMitarbeiter2
    @MinGehalt DECIMAL(10, 2),
    @MaxGehalt DECIMAL(10, 2)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Plausibilitätsprüfung: Wurden gültige Grenzen übergeben?
    IF @MinGehalt IS NULL OR @MaxGehalt IS NULL
    BEGIN
        SELECT 'Fehler: Sowohl MinGehalt als auch MaxGehalt müssen angegeben werden.' AS Fehlermeldung;
        PRINT '[FEHLER] Parameter @MinGehalt und @MaxGehalt dürfen nicht NULL sein.';
        RETURN -1;
    END;

    -- 2. Plausibilitätsprüfung: Min darf nicht größer als Max sein
    IF @MinGehalt > @MaxGehalt
    BEGIN
        SELECT CONCAT('Fehler: MinGehalt (', FORMAT(@MinGehalt, 'N2', 'de-DE'), 
                      ' EUR) darf nicht größer als MaxGehalt (', FORMAT(@MaxGehalt, 'N2', 'de-DE'), 
                      ' EUR) sein.') AS Fehlermeldung;
        PRINT '[FEHLER] Unlogische Gehaltsgrenzen: MinGehalt > MaxGehalt.';
        RETURN -2;
    END;

    -- 3. Prüfung: Gibt es Mitarbeiter im angegebenen Gehaltskorridor?
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Mitarbeiter AS m
        INNER JOIN dbo.Gehalt AS g ON m.id = g.mit_id
        WHERE g.gehalt BETWEEN @MinGehalt AND @MaxGehalt
    )
    BEGIN
        -- Geforderte Rückmeldung, wenn keine passenden Mitarbeiter existieren:
        SELECT CONCAT('Keine Mitarbeiter im Gehaltsbereich von ', 
                      FORMAT(@MinGehalt, 'N2', 'de-DE'), ' EUR bis ', 
                      FORMAT(@MaxGehalt, 'N2', 'de-DE'), ' EUR gefunden.') AS Meldung;

        PRINT CONCAT('Hinweis: Keine Treffer im Bereich ', FORMAT(@MinGehalt, 'N2', 'de-DE'), 
                     ' EUR bis ', FORMAT(@MaxGehalt, 'N2', 'de-DE'), ' EUR.');
        RETURN 0;
    END;

    -- 4. Reguläre Ausgabe der Mitarbeiterliste
    SELECT m.id AS Personalnummer,
           m.vorname AS Vorname,
           m.nachname AS Nachname,
           a.bezeichnung AS Abteilung,
           g.gehalt AS Monatsgehalt
    FROM dbo.Mitarbeiter AS m
    INNER JOIN dbo.Gehalt AS g ON m.id = g.mit_id
    LEFT JOIN dbo.Abteilung AS a ON m.abt_id = a.id
    WHERE g.gehalt BETWEEN @MinGehalt AND @MaxGehalt
    ORDER BY g.gehalt DESC, m.nachname ASC;
END;
GO

PRINT '>>> Prozedur dbo.sp_FilterMitarbeiter2 erfolgreich erstellt.';
GO


-- ----------------------------------------------------------------------------
-- Test-Suite für Aufgabe P1.3
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> TEST-SUITE AUFGABE P1.3';
PRINT '======================================================================';

-- Testfall A: Regulärer Bereich mit Treffern (2.000 bis 3.500 EUR)
PRINT '--- Testfall A: Treffer zwischen 2.000 und 3.500 EUR ---';
EXEC dbo.sp_FilterMitarbeiter2 @MinGehalt = 2000.00, @MaxGehalt = 3500.00;

-- Testfall B: Spitzengehälter (z. B. 4.000 bis 6.000 EUR)
PRINT '--- Testfall B: Gehälter zwischen 4.000 und 6.000 EUR ---';
EXEC dbo.sp_FilterMitarbeiter2 @MinGehalt = 4000.00, @MaxGehalt = 6000.00;

-- Testfall C: Gehaltskorridor ohne Treffer (z. B. 90.000 bis 100.000 EUR)
PRINT '--- Testfall C: Keine Treffer (90.000 bis 100.000 EUR) ---';
EXEC dbo.sp_FilterMitarbeiter2 @MinGehalt = 90000.00, @MaxGehalt = 100000.00;

-- Testfall D: Fehlerfall: MinGehalt > MaxGehalt
PRINT '--- Testfall D: Fehlerprüfung MinGehalt > MaxGehalt ---';
EXEC dbo.sp_FilterMitarbeiter2 @MinGehalt = 5000.00, @MaxGehalt = 2000.00;
GO


-- ============================================================================
-- AUFGABE P1.4: sp_NeuesProjektAnlegen (Konfliktfreie Projektanlage)
-- ----------------------------------------------------------------------------
-- Aufgabenstellung:
-- Erstellen Sie eine Prozedur, die ein neues Projekt anlegt. Der
-- Prozedur sollen die Werte für die Bezeichnung und die Mittel 
-- übergeben werden. Das Projekt darf nur angelegt werden, wenn es 
-- keinen Konflikt bei der Bezeichnung gibt.
--
-- Schema ProjektDB.dbo.Projekt:
-- id       INT IDENTITY PK
-- kuerzel  NCHAR(2) NOT NULL
-- bezeichnung NVARCHAR(30) NOT NULL
-- mittel   MONEY NULL
-- kunde_id INT NULL FK -> Kunde(id)
-- ============================================================================

PRINT '======================================================================';
PRINT '>>> AUFGABE P1.4: Erstelle dbo.sp_NeuesProjektAnlegen';
PRINT '======================================================================';

CREATE OR ALTER PROCEDURE dbo.sp_NeuesProjektAnlegen
    @Bezeichnung NVARCHAR(30),
    @Mittel DECIMAL(12, 2),
    @Kuerzel NCHAR(2) = NULL, -- Optional: Wird bei NULL automatisch abgeleitet
    @KundeId INT = NULL        -- Optional: Auftraggeber-ID
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validierung: Bezeichnung darf nicht leer sein
    IF @Bezeichnung IS NULL OR LTRIM(RTRIM(@Bezeichnung)) = ''
    BEGIN
        SELECT 'Fehler: Die Projektbezeichnung darf nicht leer sein.' AS Statusmeldung;
        PRINT '[ABBRUCH] Fehlende Projektbezeichnung.';
        RETURN -1;
    END;

    -- 2. Validierung: Mittel dürfen nicht negativ sein
    IF @Mittel IS NOT NULL AND @Mittel < 0.00
    BEGIN
        SELECT 'Fehler: Das Projektbudget darf nicht negativ sein.' AS Statusmeldung;
        PRINT '[ABBRUCH] Negatives Projektbudget.';
        RETURN -2;
    END;

    -- 3. KONFLIKTPRÜFUNG: Gibt es bereits ein Projekt mit dieser Bezeichnung?
    IF EXISTS (
        SELECT 1 
        FROM dbo.Projekt 
        WHERE LOWER(bezeichnung) = LOWER(LTRIM(RTRIM(@Bezeichnung)))
    )
    BEGIN
        -- Konflikt erkannt -> Anlage verweigern!
        SELECT CONCAT('Konflikt: Ein Projekt mit der Bezeichnung "', @Bezeichnung, '" existiert bereits!') AS Statusmeldung;
        PRINT CONCAT('[KONFLIKT] Projektanlage verweigert: Bezeichnung "', @Bezeichnung, '" bereits vergeben.');
        RETURN 1; -- Returncode 1 signalisiert Konflikt
    END;

    -- 4. Automatisches Kürzel generieren, falls keines übergeben wurde
    -- Nimmt die ersten 2 Buchstaben der Bezeichnung in Großbuchstaben
    IF @Kuerzel IS NULL OR LTRIM(RTRIM(@Kuerzel)) = ''
    BEGIN
        SET @Kuerzel = UPPER(SUBSTRING(@Bezeichnung, 1, 2));
    END;

    -- 5. Optional: Validierung der Kunden-ID (falls übergeben)
    IF @KundeId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Kunde WHERE id = @KundeId)
    BEGIN
        SELECT CONCAT('Fehler: Der angegebene Kunde mit ID ', @KundeId, ' existiert nicht.') AS Statusmeldung;
        PRINT '[ABBRUCH] Ungültige Kunden-ID.';
        RETURN -3;
    END;

    -- 6. Transaktionsgesichertes Einfügen
    BEGIN TRY
        INSERT INTO dbo.Projekt (kuerzel, bezeichnung, mittel, kunde_id)
        VALUES (@Kuerzel, @Bezeichnung, @Mittel, @KundeId);

        DECLARE @neueProjektId INT = SCOPE_IDENTITY();

        -- Erfolgsmeldung im Resultset und im Log
        SELECT CONCAT('Erfolg: Projekt "', @Bezeichnung, '" (ID: ', @neueProjektId, 
                      ', Kürzel: ', @Kuerzel, ', Budget: ', FORMAT(@Mittel, 'N2', 'de-DE'), 
                      ' EUR) erfolgreich angelegt.') AS Statusmeldung,
               @neueProjektId AS GenerierteProjektID;

        PRINT CONCAT('>>> [ERFOLG] Projekt "', @Bezeichnung, '" mit ID ', @neueProjektId, ' angelegt.');
        RETURN 0; -- 0 = Erfolg
    END TRY
    BEGIN CATCH
        SELECT CONCAT('Datenbankfehler: ', ERROR_MESSAGE()) AS Statusmeldung;
        PRINT CONCAT('[SYSTEMFEHLER] ', ERROR_MESSAGE());
        RETURN -99;
    END CATCH;
END;
GO

PRINT '>>> Prozedur dbo.sp_NeuesProjektAnlegen erfolgreich erstellt.';
GO


-- ----------------------------------------------------------------------------
-- Test-Suite für Aufgabe P1.4
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> TEST-SUITE AUFGABE P1.4';
PRINT '======================================================================';

-- Testfall A: Konflikttest mit bestehendem Projekt (z. B. 'Apollo')
PRINT '--- Testfall A: Konfliktversuch mit existierendem Projekt "Apollo" ---';
EXEC dbo.sp_NeuesProjektAnlegen 
    @Bezeichnung = 'Apollo', 
    @Mittel = 150000.00;

-- Testfall B: Sichere Testanlage eines neuen Projekts innerhalb einer Transaktion
PRINT '--- Testfall B: Anlage eines neuen Projekts "Merkur" (mit ROLLBACK) ---';
BEGIN TRANSACTION;

-- 1. Versuch: Projekt anlegen (muss gelingen)
EXEC dbo.sp_NeuesProjektAnlegen 
    @Bezeichnung = 'Merkur', 
    @Mittel = 85000.00,
    @Kuerzel = 'ME';

-- 2. Versuch: Gleiches Projekt sofort nochmals anlegen (muss Konflikt melden!)
PRINT '--- Sofortiger Zweitversuch mit "Merkur" (Konflikterkennung prüfen) ---';
EXEC dbo.sp_NeuesProjektAnlegen 
    @Bezeichnung = 'Merkur', 
    @Mittel = 85000.00;

-- Datenbestand der ProjektDB schonen
ROLLBACK TRANSACTION;
PRINT '>>> Test-Transaktion zurückgerollt (ProjektDB bleibt sauber).';
GO


-- ============================================================================
-- TEIL 3: SCHLAUE FRAGEN AN MEINEN DOZENTEN (Tom S.) – RUNDE 2
-- ============================================================================
-- Tiefgehende Architekturfragen zu Aufgaben P1.3 & P1.4:
-- ============================================================================

/*
-------------------------------------------------------------------------------
Frage 1 (Concurrency & Race Conditions bei 'IF NOT EXISTS' vor INSERT):
-------------------------------------------------------------------------------
"In Aufgabe P1.4 prüfen wir mit 'IF NOT EXISTS (SELECT 1 FROM Projekt WHERE bezeichnung = @Bezeichnung)',
ob das Projekt bereits existiert, bevor wir den INSERT ausführen.
Was passiert in einem hochparallelen System, wenn ZWEI Benutzer EXAKT gleichzeitig
die Prozedur mit derselben Bezeichnung aufrufen? Beide Durchläufe sehen 'NOT EXISTS'
und versuchen gleichzeitig das INSERT!
Sollte man sich in der Praxis auf die 'IF NOT EXISTS'-Prüfung verlassen, oder
gehört zwingend ein UNIQUE Constraint auf die Spalte 'bezeichnung', den man
in der Prozedur per BEGIN TRY ... BEGIN CATCH abfängt?"

-------------------------------------------------------------------------------
Frage 2 (Index-Strategie für Gehalts-Range Abfragen mit BETWEEN):
-------------------------------------------------------------------------------
"In Aufgabe P1.3 filtern wir Mitarbeiter nach einem Gehaltskorridor (BETWEEN @Min AND @Max).
In der ProjektDB ist die Tabelle 'Gehalt' über 'mit_id' als Primary Key geclustert.
Welche Art von Index (z. B. Non-Clustered Index auf gehalt mit INCLUDE(mit_id))
müsste der DBA anlegen, damit diese Prozedur bei Millionen Datensätzen einen
schnellen Index Seek statt eines teuren Clustered Index Scans durchführt?"

-------------------------------------------------------------------------------
Frage 3 (Transaktions-Isolation & Phantom Reads bei Gehaltserhöhungen):
-------------------------------------------------------------------------------
"Wenn während der Ausführung von 'sp_FilterMitarbeiter2' zeitgleich eine andere
Prozedur Gehälter aktualisiert oder neue Mitarbeiter anlegt: Welche Isolation
Level (READ COMMITTED vs. REPEATABLE READ / SNAPSHOT) ist für Auswertungs-
Prozeduren in der Praxis der beste Kompromiss aus Konsistenz und Blockadefreiheit?"
*/
