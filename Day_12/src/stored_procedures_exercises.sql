-- ============================================================================
-- 📅 Day_12: Stored Procedures & Parameter (Übungen & Musterlösungen)
-- Datenbank: ProjektDB (MS SQL Server)
-- Autor: Tobias Boyke
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- Aufgabe 1: Einfache Stored Procedure zur Abteilungssuche
--
-- Beschreibung:
-- Erstellen Sie eine Stored Procedure namens `dbo.usp_GetMitarbeiterByAbteilung`.
-- Die Prozedur soll den Namen einer Abteilung als Parameter (`@AbtName`) erhalten 
-- und alle Mitarbeiter (ID, Vorname, Nachname, Gehalt) dieser Abteilung ausgeben.
--
-- Anforderungen:
-- 1. Nutzen Sie SET NOCOUNT ON.
-- 2. Wenn die Abteilung nicht existiert, soll ein Fehler ausgelöst werden.
-- 3. Geben Sie 0 bei Erfolg und 1 bei Fehler (z. B. Abteilung existiert nicht) zurück.
-- ============================================================================

-- Falls bereits vorhanden, löschen
IF OBJECT_ID('dbo.usp_GetMitarbeiterByAbteilung', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetMitarbeiterByAbteilung;
GO

CREATE PROCEDURE dbo.usp_GetMitarbeiterByAbteilung
    @AbtName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Prüfen, ob die Abteilung existiert
    IF NOT EXISTS (SELECT 1 FROM dbo.Abteilung WHERE AbteilungsName = @AbtName)
    BEGIN
        -- Fehler ausgeben
        RAISERROR('Abteilung "%s" existiert nicht in der Datenbank.', 16, 1, @AbtName);
        RETURN 1; -- Fehlercode zurückgeben
    END

    -- Mitarbeiter der Abteilung selektieren
    SELECT 
        m.MitarbeiterID, 
        m.Vorname, 
        m.Nachname, 
        m.Gehalt,
        a.AbteilungsName
    FROM dbo.Mitarbeiter AS m
    INNER JOIN dbo.Abteilung AS a ON m.AbteilungID = a.AbteilungID
    WHERE a.AbteilungsName = @AbtName;

    RETURN 0; -- Erfolgscode zurückgeben
END;
GO

-- 🧪 TEST FÜR AUFGABE 1:
-- A) Erfolgreicher Test (IT-Entwicklung)
DECLARE @ReturnVal1 INT;
EXEC @ReturnVal1 = dbo.usp_GetMitarbeiterByAbteilung @AbtName = 'IT-Entwicklung';
PRINT 'Rückgabewert: ' + CAST(@ReturnVal1 AS VARCHAR(10));
GO

-- B) Fehler-Test (Existiert nicht)
DECLARE @ReturnVal2 INT;
EXEC @ReturnVal2 = dbo.usp_GetMitarbeiterByAbteilung @AbtName = 'Kreativabteilung';
PRINT 'Rückgabewert: ' + CAST(@ReturnVal2 AS VARCHAR(10));
GO


-- ============================================================================
-- Aufgabe 2: Stored Procedure zum sicheren Einfügen von Mitarbeitern (DML)
--
-- Beschreibung:
-- Erstellen Sie eine Stored Procedure `dbo.usp_InsertMitarbeiter`, die einen neuen
-- Mitarbeiter in die Tabelle einträgt.
--
-- Parameter:
-- - @Vorname NVARCHAR(50)
-- - @Nachname NVARCHAR(50)
-- - @Email VARCHAR(100)
-- - @Gehalt DECIMAL(10,2)
-- - @AbteilungName NVARCHAR(50)
-- - @NeuerMitarbeiterID INT OUTPUT (Soll die generierte ID zurückgeben)
--
-- Anforderungen:
-- 1. Ermitteln Sie die AbteilungID über den Abteilungsnamen. Wenn die Abteilung
--    nicht existiert, weisen Sie NULL zu.
-- 2. Verwenden Sie ein robustes Exception-Handling (TRY...CATCH).
-- 3. Prüfen Sie vor dem Insert, ob die E-Mail-Adresse bereits vergeben ist. Falls ja,
--    lösen Sie einen Fehler via THROW aus.
-- ============================================================================

IF OBJECT_ID('dbo.usp_InsertMitarbeiter', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_InsertMitarbeiter;
GO

CREATE PROCEDURE dbo.usp_InsertMitarbeiter
    @Vorname NVARCHAR(50),
    @Nachname NVARCHAR(50),
    @Email VARCHAR(100),
    @Gehalt DECIMAL(10,2),
    @AbteilungName NVARCHAR(50),
    @NeuerMitarbeiterID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validierung: E-Mail-Duplikat prüfen
        IF EXISTS (SELECT 1 FROM dbo.Mitarbeiter WHERE Email = @Email)
        BEGIN
            THROW 50005, 'Registrierung fehlgeschlagen: Die angegebene E-Mail-Adresse ist bereits registriert.', 1;
        END

        -- Validierung: Gehalt darf nicht negativ sein
        IF @Gehalt < 0
        BEGIN
            THROW 50006, 'Einfügen fehlgeschlagen: Das Gehalt darf nicht negativ sein.', 1;
        END

        -- AbteilungID ermitteln
        DECLARE @AbtID INT;
        SELECT @AbtID = AbteilungID 
        FROM dbo.Abteilung 
        WHERE AbteilungsName = @AbteilungName;

        -- Einfügen des neuen Datensatzes
        INSERT INTO dbo.Mitarbeiter (Vorname, Nachname, Email, Gehalt, AbteilungID)
        VALUES (@Vorname, @Nachname, @Email, @Gehalt, @AbtID);

        -- Generierte IDENTITY-ID in den OUTPUT-Parameter schreiben
        SET @NeuerMitarbeiterID = SCOPE_IDENTITY();

        RETURN 0; -- Erfolg
    END TRY
    BEGIN CATCH
        -- Fehler an den Aufrufer weiterleiten
        DECLARE @Msg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @Severity INT = ERROR_SEVERITY();
        DECLARE @State INT = ERROR_STATE();

        RAISERROR(@Msg, @Severity, @State);
        RETURN -1; -- Fehler
    END CATCH
END;
GO

-- 🧪 TEST FÜR AUFGABE 2:
-- A) Erfolgreicher Test
DECLARE @MitarbeiterID INT;
DECLARE @Status INT;

EXEC @Status = dbo.usp_InsertMitarbeiter
    @Vorname = 'Erika',
    @Nachname = 'Mustermann',
    @Email = 'erika.mustermann@firma.de',
    @Gehalt = 4500.00,
    @AbteilungName = 'Personalwesen',
    @NeuerMitarbeiterID = @MitarbeiterID OUTPUT;

PRINT 'Ergebnis-Status: ' + CAST(@Status AS VARCHAR(10));
PRINT 'Generierte ID: ' + CAST(@MitarbeiterID AS VARCHAR(10));

-- Kontroll-Abfrage
SELECT * FROM dbo.Mitarbeiter WHERE MitarbeiterID = @MitarbeiterID;
GO

-- B) Duplikat-Test (Email bereits vorhanden)
DECLARE @MitarbeiterID INT;
DECLARE @Status INT;

EXEC @Status = dbo.usp_InsertMitarbeiter
    @Vorname = 'Max',
    @Nachname = 'Mustermann2',
    @Email = 'erika.mustermann@firma.de', -- Gleiche Email
    @Gehalt = 3800.00,
    @AbteilungName = 'Personalwesen',
    @NeuerMitarbeiterID = @MitarbeiterID OUTPUT;
GO


-- ============================================================================
-- Aufgabe 3: Stored Procedure zur Gehaltsstatistik (OUTPUT-Parameter)
--
-- Beschreibung:
-- Erstellen Sie eine Stored Procedure `dbo.usp_GetGehaltStats`.
-- Die Prozedur soll über Output-Parameter statistische Daten zurückliefern.
--
-- Parameter:
-- - @AvgGehalt DECIMAL(10,2) OUTPUT
-- - @MinGehalt DECIMAL(10,2) OUTPUT
-- - @MaxGehalt DECIMAL(10,2) OUTPUT
-- - @TotalGehaltSum DECIMAL(12,2) OUTPUT
-- ============================================================================

IF OBJECT_ID('dbo.usp_GetGehaltStats', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetGehaltStats;
GO

CREATE PROCEDURE dbo.usp_GetGehaltStats
    @AvgGehalt DECIMAL(10,2) OUTPUT,
    @MinGehalt DECIMAL(10,2) OUTPUT,
    @MaxGehalt DECIMAL(10,2) OUTPUT,
    @TotalGehaltSum DECIMAL(12,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        @AvgGehalt = AVG(Gehalt),
        @MinGehalt = MIN(Gehalt),
        @MaxGehalt = MAX(Gehalt),
        @TotalGehaltSum = SUM(Gehalt)
    FROM dbo.Mitarbeiter;
END;
GO

-- 🧪 TEST FÜR AUFGABE 3:
DECLARE @Avg DECIMAL(10,2);
DECLARE @Min DECIMAL(10,2);
DECLARE @Max DECIMAL(10,2);
DECLARE @Sum DECIMAL(12,2);

EXEC dbo.usp_GetGehaltStats
    @AvgGehalt = @Avg OUTPUT,
    @MinGehalt = @Min OUTPUT,
    @MaxGehalt = @Max OUTPUT,
    @TotalGehaltSum = @Sum OUTPUT;

SELECT 
    @Avg AS Durchschnittsgehalt,
    @Min AS Minimalgehalt,
    @Max AS Maximalgehalt,
    @Sum AS GesamteGehaltskosten;
GO


-- ============================================================================
-- Aufgabe 4: Transaktionssichere Gehaltserhöhung
--
-- Beschreibung:
-- Schreiben Sie eine transaktionssichere Stored Procedure
-- `dbo.usp_GiveSalaryIncrease`, die das Gehalt eines Mitarbeiters prozentual erhöht.
--
-- Parameter:
-- - @MitarbeiterID INT
-- - @IncreasePercent DECIMAL(5,2) (z. B. 10.00 für 10% Erhöhung)
--
-- Anforderungen:
-- 1. Überprüfen Sie, ob der Mitarbeiter existiert. Falls nicht, werfen Sie einen Fehler.
-- 2. Führen Sie die Gehaltserhöhung in einer expliziten Transaktion aus.
-- 3. Geschäftsregel: Das neue Gehalt darf den Wert von 15.000,00 € nicht überschreiten.
--    Falls das neue Gehalt diesen Grenzwert überschreitet, muss die Transaktion
--    abgebrochen (Rollback) und eine Fehlermeldung ausgegeben werden.
-- ============================================================================

IF OBJECT_ID('dbo.usp_GiveSalaryIncrease', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GiveSalaryIncrease;
GO

CREATE PROCEDURE dbo.usp_GiveSalaryIncrease
    @MitarbeiterID INT,
    @IncreasePercent DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Prüfen, ob Mitarbeiter existiert
        IF NOT EXISTS (SELECT 1 FROM dbo.Mitarbeiter WHERE MitarbeiterID = @MitarbeiterID)
        BEGIN
            THROW 50007, 'Erhöhung abgelehnt: Mitarbeiter existiert nicht.', 1;
        END

        -- 2. Aktuelles Gehalt ermitteln
        DECLARE @CurrentSalary DECIMAL(10,2);
        SELECT @CurrentSalary = Gehalt 
        FROM dbo.Mitarbeiter 
        WHERE MitarbeiterID = @MitarbeiterID;

        -- 3. Neues Gehalt berechnen
        DECLARE @NewSalary DECIMAL(10,2);
        SET @NewSalary = @CurrentSalary * (1.00 + (@IncreasePercent / 100.00));

        -- 4. Validierung des Höchstgehalts
        IF @NewSalary > 15000.00
        BEGIN
            DECLARE @ErrStr NVARCHAR(100);
            SET @ErrStr = 'Erhöhung verboten: Das neue Gehalt (' + CAST(@NewSalary AS NVARCHAR(15)) + ' €) überschreitet das Maximum von 15.000,00 €.';
            THROW 50008, @ErrStr, 1;
        END

        -- 5. Gehalt updaten
        UPDATE dbo.Mitarbeiter
        SET Gehalt = @NewSalary
        WHERE MitarbeiterID = @MitarbeiterID;

        -- Transaktion erfolgreich abschließen
        COMMIT TRANSACTION;
        PRINT 'Gehaltserhöhung erfolgreich durchgeführt.';
        RETURN 0;
    END TRY
    BEGIN CATCH
        -- Bei Fehlern Transaktion zurückrollen, falls aktiv
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Fehler werfen
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrState INT = ERROR_STATE();

        RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
        RETURN -1;
    END CATCH
END;
GO

-- 🧪 TEST FÜR AUFGABE 4:
-- Vorbereitung: Gehalt eines existierenden Mitarbeiters prüfen
-- Wir nehmen an, wir testen mit der vorhin eingefügten 'Erika Mustermann' (ID: 1002 oder ähnlich)
-- Um unabhängig von IDs zu sein, lesen wir eine ID dynamisch aus:
DECLARE @TestID INT;
SELECT TOP 1 @TestID = MitarbeiterID FROM dbo.Mitarbeiter WHERE Nachname = 'Mustermann';

-- A) Erfolgreicher Test (5% Erhöhung)
EXEC dbo.usp_GiveSalaryIncrease @MitarbeiterID = @TestID, @IncreasePercent = 5.00;

-- Kontrolle
SELECT Gehalt FROM dbo.Mitarbeiter WHERE MitarbeiterID = @TestID;

-- B) Fehler-Test (Sehr hohe Erhöhung, die das Limit sprengt)
EXEC dbo.usp_GiveSalaryIncrease @MitarbeiterID = @TestID, @IncreasePercent = 300.00;
GO
