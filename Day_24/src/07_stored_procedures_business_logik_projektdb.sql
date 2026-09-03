-- ============================================================================
-- SQL-Fundamentals: Day 24 - T-SQL Prozedurale Programmierung
-- Datei: 07_stored_procedures_business_logik_projektdb.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 03.09.2026
-- Fokus: Vollständige Unternehmens-Prozeduren auf der ProjektDB (SoT)
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- GESCHÄFTSLOGIK-PROZEDUREN AUF DER PROJEKTDB
-- ----------------------------------------------------------------------------
-- In diesem Skript werden fortgeschrittene Stored Procedures für reale
-- Geschäftsprozesse implementiert:
-- 1. usp_MitarbeiterProjektZuweisen (Validierte DML-Operation mit Referenzprüfung)
-- 2. usp_GehaltsanpassungAbteilung  (Transaktionsgesicherte Gehaltserhöhung mit Grenzen)
-- 3. usp_IterativerProjektStatusAudit (Stored Procedure mit interner WHILE-Schleife)
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. Prozedur: usp_MitarbeiterProjektZuweisen (Validierte Projektzuweisung)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 1. Erstelle dbo.usp_MitarbeiterProjektZuweisen...';
PRINT '======================================================================';

CREATE OR ALTER PROCEDURE dbo.usp_MitarbeiterProjektZuweisen
    @mit_id INT,
    @pro_id INT,
    @aufgabe NVARCHAR(50) = 'Mitarbeiter',
    @einst_dat DATE = NULL,
    @statusMeldung NVARCHAR(250) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Default für Eintrittsdatum: Heutiges Datum
    IF @einst_dat IS NULL
        SET @einst_dat = CAST(GETDATE() AS DATE);

    -- 1. Integritätsprüfung: Existiert der Mitarbeiter?
    IF NOT EXISTS (SELECT 1 FROM dbo.Mitarbeiter WHERE id = @mit_id)
    BEGIN
        SET @statusMeldung = CONCAT('[ABBRUCH] Mitarbeiter mit ID ', @mit_id, ' existiert nicht.');
        RETURN 1; -- Fehlercode 1
    END;

    -- 2. Integritätsprüfung: Existiert das Projekt?
    IF NOT EXISTS (SELECT 1 FROM dbo.Projekt WHERE id = @pro_id)
    BEGIN
        SET @statusMeldung = CONCAT('[ABBRUCH] Projekt mit ID ', @pro_id, ' existiert nicht.');
        RETURN 2; -- Fehlercode 2
    END;

    -- 3. Integritätsprüfung: Ist der Mitarbeiter bereits im Projekt aktiv?
    IF EXISTS (SELECT 1 FROM dbo.Arbeit WHERE mit_id = @mit_id AND pro_id = @pro_id)
    BEGIN
        SET @statusMeldung = CONCAT('[HINWEIS] Mitarbeiter ', @mit_id, ' ist bereits dem Projekt ', @pro_id, ' zugeordnet.');
        RETURN 3; -- Hinweis / Kein Duplikat
    END;

    -- 4. Sicheres Einfügen der Zuweisung
    BEGIN TRY
        INSERT INTO dbo.Arbeit (mit_id, pro_id, aufgabe, einst_dat)
        VALUES (@mit_id, @pro_id, @aufgabe, @einst_dat);

        SET @statusMeldung = CONCAT('[ERFOLG] Mitarbeiter ', @mit_id, ' erfolgreich als "', @aufgabe, '" in Projekt ', @pro_id, ' eingebucht.');
        RETURN 0; -- Erfolg
    END TRY
    BEGIN CATCH
        SET @statusMeldung = CONCAT('[SYSTEMFEHLER] ', ERROR_MESSAGE());
        RETURN 99;
    END CATCH;
END;
GO

PRINT '>>> Prozedur dbo.usp_MitarbeiterProjektZuweisen erfolgreich kompiliert.';
GO


-- ----------------------------------------------------------------------------
-- 2. Prozedur: usp_GehaltsanpassungAbteilung (Transaktionsgesichert)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 2. Erstelle dbo.usp_GehaltsanpassungAbteilung...';
PRINT '======================================================================';

CREATE OR ALTER PROCEDURE dbo.usp_GehaltsanpassungAbteilung
    @abteilungsKuerzel NVARCHAR(10),
    @prozentErhoehung DECIMAL(5, 2), -- z. B. 3.50 für 3.5%
    @anzahlBetroffen INT OUTPUT,
    @neueGehaltssumme DECIMAL(14, 2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @anzahlBetroffen = 0;
    SET @neueGehaltssumme = 0.00;

    -- 1. Validierung des Erhöhungssatzes (Plausibilität: zwischen 0.1% und 20%)
    IF @prozentErhoehung <= 0.00 OR @prozentErhoehung > 20.00
    BEGIN
        PRINT '[ABBRUCH] Unzulässiger Erhöhungssatz! Werte müssen zwischen 0.1% und 20.0% liegen.';
        RETURN -1;
    END;

    -- 2. Validierung: Existiert die Abteilung?
    DECLARE @abtId INT;
    SELECT @abtId = id FROM dbo.Abteilung WHERE kuerzel = @abteilungsKuerzel;

    IF @abtId IS NULL
    BEGIN
        PRINT CONCAT('[ABBRUCH] Abteilung mit Kürzel "', @abteilungsKuerzel, '" nicht gefunden.');
        RETURN -2;
    END;

    -- 3. Transaktionsgesicherte Anpassung
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Gehälter für alle Mitarbeiter der Abteilung erhöhen
        UPDATE g
        SET g.gehalt = ROUND(g.gehalt * (1.00 + (@prozentErhoehung / 100.00)), 2)
        FROM dbo.Gehalt AS g
        INNER JOIN dbo.Mitarbeiter AS m ON g.mit_id = m.id
        WHERE m.abt_id = @abtId;

        SET @anzahlBetroffen = @@ROWCOUNT;

        -- Neue Gehaltssumme ermitteln
        SELECT @neueGehaltssumme = SUM(g.gehalt)
        FROM dbo.Gehalt AS g
        INNER JOIN dbo.Mitarbeiter AS m ON g.mit_id = m.id
        WHERE m.abt_id = @abtId;

        COMMIT TRANSACTION;
        PRINT CONCAT('>>> [TRANSAKTION ERFOLGREICH] ', @anzahlBetroffen, ' Gehälter in Abteilung ', @abteilungsKuerzel, ' angepasst.');
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT CONCAT('[TRANSAKTION ROLLBACK] Fehler: ', ERROR_MESSAGE());
        RETURN -99;
    END CATCH;
END;
GO

PRINT '>>> Prozedur dbo.usp_GehaltsanpassungAbteilung erfolgreich kompiliert.';
GO


-- ----------------------------------------------------------------------------
-- 3. Prozedur: usp_IterativerProjektStatusAudit (WHILE-Schleife in Prozedur)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 3. Erstelle dbo.usp_IterativerProjektStatusAudit...';
PRINT '======================================================================';

CREATE OR ALTER PROCEDURE dbo.usp_IterativerProjektStatusAudit
    @mindestBudget DECIMAL(12, 2) = 50000.00
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '==================================================================';
    PRINT CONCAT('   PROJEKT-AUDIT: Alle Projekte mit Budget >= ', FORMAT(@mindestBudget, 'N2', 'de-DE'), ' EUR');
    PRINT '==================================================================';

    -- Temporäre Arbeitstabelle
    IF OBJECT_ID('tempdb..#AuditList') IS NOT NULL
        DROP TABLE #AuditList;

    CREATE TABLE #AuditList (
        lfdNr INT IDENTITY(1, 1) PRIMARY KEY,
        proId INT,
        kuerzel NVARCHAR(10),
        name NVARCHAR(50),
        budget DECIMAL(12, 2),
        kundeName NVARCHAR(100)
    );

    INSERT INTO #AuditList (proId, kuerzel, name, budget, kundeName)
    SELECT p.id, p.kuerzel, p.bezeichnung, p.mittel, k.firma
    FROM dbo.Projekt AS p
    INNER JOIN dbo.Kunde AS k ON p.kunde_id = k.id
    WHERE p.mittel >= @mindestBudget
    ORDER BY p.mittel DESC;

    DECLARE @curIndex INT = 1;
    DECLARE @maxIndex INT;
    DECLARE @pId INT, @pKuerzel NVARCHAR(10), @pName NVARCHAR(50), @pBudget DECIMAL(12, 2), @kFirma NVARCHAR(100);
    DECLARE @teamGroesse INT;

    SELECT @maxIndex = COUNT(*) FROM #AuditList;

    IF @maxIndex = 0
    BEGIN
        PRINT 'Keine Projekte entsprechen dem geforderten Mindestbudget.';
        RETURN 0;
    END;

    -- Iterative Prüfung mit WHILE
    WHILE @curIndex <= @maxIndex
    BEGIN
        SELECT @pId = proId,
               @pKuerzel = kuerzel,
               @pName = name,
               @pBudget = budget,
               @kFirma = kundeName
        FROM #AuditList
        WHERE lfdNr = @curIndex;

        -- Teamgröße aus der Tabelle Arbeit ermitteln
        SELECT @teamGroesse = COUNT(*)
        FROM dbo.Arbeit
        WHERE pro_id = @pId;

        PRINT CONCAT('[#', @curIndex, '] Projekt: ', @pKuerzel, ' - "', @pName, '"');
        PRINT CONCAT('     Auftraggeber: ', @kFirma);
        PRINT CONCAT('     Budget:       ', FORMAT(@pBudget, 'N2', 'de-DE'), ' EUR');
        PRINT CONCAT('     Teamstärke:   ', @teamGroesse, ' zugewiesene Mitarbeiter');

        -- Audit-Bewertung
        IF @teamGroesse = 0
            PRINT '     ⚠️ WARNUNG: Projekt hat noch kein Team!';
        ELSE IF @teamGroesse >= 3
            PRINT '     ✅ STATUS: Stark besetztes Kernprojekt.';
        ELSE
            PRINT '     ℹ️ STATUS: Minimalbesetzung.';

        PRINT '------------------------------------------------------------------';

        SET @curIndex = @curIndex + 1;
    END;

    DROP TABLE #AuditList;
    RETURN 0;
END;
GO


-- ----------------------------------------------------------------------------
-- 4. Test-Suiten & Aufrufe der Business-Logik-Prozeduren
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 4. Test-Suite: Prozeduraufrufe mit Parametern & Rückgabewerten';
PRINT '======================================================================';

-- Test 1: Projektzuweisung testen
DECLARE @meldung NVARCHAR(250);
DECLARE @rc INT;

EXEC @rc = dbo.usp_MitarbeiterProjektZuweisen
    @mit_id = 25348,
    @pro_id = 1,
    @aufgabe = 'Chefarchitekt',
    @statusMeldung = @meldung OUTPUT;

PRINT CONCAT('Ergebnis Zuweisung (Returncode ', @rc, '): ', @meldung);

-- Test 2: Ungültige Projektzuweisung (Mitarbeiter -999 existiert nicht)
EXEC @rc = dbo.usp_MitarbeiterProjektZuweisen
    @mit_id = -999,
    @pro_id = 1,
    @aufgabe = 'Tester',
    @statusMeldung = @meldung OUTPUT;

PRINT CONCAT('Ergebnis Fehlerprüfung (Returncode ', @rc, '): ', @meldung);

-- Test 3: Iterativer Status-Audit aufrufen
EXEC dbo.usp_IterativerProjektStatusAudit @mindestBudget = 60000.00;
GO
