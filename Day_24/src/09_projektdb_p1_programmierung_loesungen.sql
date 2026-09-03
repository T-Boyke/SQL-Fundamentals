-- ============================================================================
-- SQL-Fundamentals: Day 24 - T-SQL Prozedurale Programmierung
-- Datei: 09_projektdb_p1_programmierung_loesungen.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 03.09.2026
-- Kursunterlagen: assets/ProjektDB P1 - Programmierung 1 - Aufgaben.sql
--                 assets/20260903-1.sql
-- Fokus: Musterlösung Aufgaben P1.1 & P1.2 (sp_FilterMitarbeiter1) + Vorlesungs-Features
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- TEIL 1: VORLESUNGSEXPERIMENTE (Tom S. - 20260903-1.sql)
-- ----------------------------------------------------------------------------
-- Kern-Erkenntnisse aus dem Vorlesungsskript:
-- 1. Variablenzuweisung via skalarem Subquery:
--    SET @anzahlP1 = (SELECT COUNT(*) FROM Arbeit WHERE pro_id = 1);
-- 2. Der fundamentale Scope-Unterschied (Batch vs. Block):
--    Variablen besitzen in T-SQL KEINEN Block-Scope! Eine Variable, die innerhalb
--    eines 'BEGIN...END'-Blocks deklariert wird, ist im GESAMTEN BATCH sichtbar!
-- 3. Schleifen & DML:
--    WHILE-Schleife mit dynamischer Budget-Erhöhung und Notbremse via BREAK.
-- 4. Optionale Parameter mit Default NULL:
--    WHERE m.id = @mit_id OR @mit_id IS NULL;
-- ============================================================================

PRINT '======================================================================';
PRINT '>>> TEIL 1: Demonstration Vorlesungsskript 20260903-1.sql';
PRINT '======================================================================';

-- 1.1 Zählung der Mitarbeiter im Projekt 1 & Ausgabe
DECLARE @anzahlP1 INT;
SET @anzahlP1 = (SELECT COUNT(*) FROM dbo.Arbeit WHERE pro_id = 1);

SELECT @anzahlP1 AS [Anzahl Mitarbeiter in Projekt 1];
PRINT 'Anzahl Mitarbeiter in Projekt 1: ' + CONVERT(VARCHAR(10), @anzahlP1);

-- 1.2 Verzweigung & Demonstration: Scope ist der Batch, NICHT der Block!
IF @anzahlP1 < 3
BEGIN
    PRINT 'Mitarbeiter-Anzahl ist kleiner 3';
END
ELSE
BEGIN
    PRINT 'Liste der Mitarbeiter im Projekt 1:';
    SELECT a.mit_id, m.nachname, m.vorname
    FROM dbo.Arbeit AS a
    INNER JOIN dbo.Mitarbeiter AS m ON m.id = a.mit_id
    WHERE a.pro_id = 1;

    -- DEKLARATION INNERHALB DES BLOCKS:
    DECLARE @testScopeDemo INT = 42; -- In C#/Java wäre @testScopeDemo außerhalb tot!
END;

-- In T-SQL ist @testScopeDemo hier weiterhin voll gültig und lesbar:
PRINT CONCAT('>>> Scope-Beweis: @testScopeDemo = ', @testScopeDemo, ' (Lebt im gesamten Batch!)');
GO


-- ----------------------------------------------------------------------------
-- 1.3 Vorlesungs-Schleife: Iterative Mittel-Erhöhung mit BREAK
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 1.3 Iterative Projektmittel-Anpassung mit BREAK';
PRINT '======================================================================';

-- Wir demonstrieren die Schleifenlogik sicher innerhalb einer Transaktion mit ROLLBACK,
-- um die Original-Budgetwerte der ProjektDB nicht dauerhaft zu verändern:
BEGIN TRANSACTION;

WHILE (SELECT SUM(mittel) FROM dbo.Projekt) < 1000000.00
BEGIN
    UPDATE dbo.Projekt
    SET mittel = mittel * 1.10;
    PRINT '  -> Projekt-Mittel wurden um 10% erhöht.';

    IF (SELECT MAX(mittel) FROM dbo.Projekt) > 250000.00
    BEGIN
        PRINT '  -> [BREAK] Das maximale Mittel eines Projekts (> 250.000 EUR) wurde überschritten.';
        BREAK;
    END;
END;

-- Transaktion zurücksetzen, um SoT-Datenbestand zu schonen
ROLLBACK TRANSACTION;
PRINT '>>> Transaktion mit ROLLBACK beendet (Datenbestand unverändert).';
GO


-- ----------------------------------------------------------------------------
-- 1.4 Vorlesungs-Prozeduren: usp_AlleProjekte & usp_MitarbeiterProjekte
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 1.4 Vorlesungs-Prozeduren kompilieren & ausführen';
PRINT '======================================================================';

CREATE OR ALTER PROCEDURE dbo.usp_AlleProjekte
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id, kuerzel, bezeichnung, mittel, kunde_id
    FROM dbo.Projekt;
END;
GO

EXEC dbo.usp_AlleProjekte;
GO

CREATE OR ALTER PROCEDURE dbo.usp_MitarbeiterProjekte
    @mit_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT m.id AS Personalnummer,
           m.vorname AS Vorname,
           m.nachname AS Nachname,
           p.kuerzel AS ProjektKuerzel,
           p.bezeichnung AS ProjektName
    FROM dbo.Mitarbeiter AS m
    INNER JOIN dbo.Arbeit AS a ON a.mit_id = m.id
    INNER JOIN dbo.Projekt AS p ON p.id = a.pro_id
    WHERE m.id = @mit_id OR @mit_id IS NULL
    ORDER BY m.id;
END;
GO

-- Aufruf mit spezifischer ID:
EXEC dbo.usp_MitarbeiterProjekte @mit_id = 25348;

-- Aufruf ohne Parameter (zeigt alle durch OR @mit_id IS NULL):
EXEC dbo.usp_MitarbeiterProjekte;
GO


-- ============================================================================
-- TEIL 2: MUSTERLÖSUNGEN AUFGABEN P1 (ProjektDB P1 - Aufgaben.sql)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Aufgabe P1.1: sp_FilterMitarbeiter1
-- ----------------------------------------------------------------------------
-- Aufgabenstellung:
-- Erstellen Sie eine gespeicherte Prozedur "sp_FilterMitarbeiter1",
-- die eine Liste der Mitarbeiter ausgibt, die in einer bestimmten
-- Abteilung arbeiten. Die Prozedur soll den Parameter @Abteilung
-- für die Bezeichnung der Abteilung entgegennehmen.
--
-- Beispiel: EXEC sp_FilterMitarbeiter1 'Einkauf'
--
-- id     vorname  nachname  abt_id  bezeichnung
-- -----  -------  --------  ------  -----------
-- 9912   Klaus    Wolf      a4      Einkauf
-- 12121  Ursula   Richter   a4      Einkauf
-- 20204  Dirk     Fuchs     a4      Einkauf
-- 22222  Anke     Vogel     a4      Einkauf
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> AUFGABE P1.1: Erstelle dbo.sp_FilterMitarbeiter1 (Basisversion)';
PRINT '======================================================================';

CREATE OR ALTER PROCEDURE dbo.sp_FilterMitarbeiter1
    @Abteilung NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT m.id,
           m.vorname,
           m.nachname,
           m.abt_id,
           a.bezeichnung
    FROM dbo.Mitarbeiter AS m
    INNER JOIN dbo.Abteilung AS a ON m.abt_id = a.id
    WHERE a.bezeichnung = @Abteilung
    ORDER BY m.id;
END;
GO

-- Testlauf P1.1:
PRINT '--- Testlauf P1.1: Mitarbeiter der Abteilung Einkauf ---';
EXEC dbo.sp_FilterMitarbeiter1 @Abteilung = 'Einkauf';
GO


-- ----------------------------------------------------------------------------
-- Aufgabe P1.2: sp_FilterMitarbeiter1 mit Fehlerbehandlung
-- ----------------------------------------------------------------------------
-- Aufgabenstellung:
-- Verändern Sie die Prozedur aus Aufgabe P1.1:
-- Wenn keine Mitarbeiter zur angeforderten Abteilung gefunden
-- werden, soll der Text 'Abteilung ungültig: <Bezeichnung>'
-- angezeigt werden. Entweder im Meldungs-Fenster oder im Grid.
--
-- Beispiel: EXEC sp_FilterMitarbeiter1 'Produktion'
--
-- Fehlermeldung
-- ------------------------------
-- Abteilung ungültig: Produktion
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> AUFGABE P1.2: Aktualisiere dbo.sp_FilterMitarbeiter1 (mit Validierung)';
PRINT '======================================================================';

CREATE OR ALTER PROCEDURE dbo.sp_FilterMitarbeiter1
    @Abteilung NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Prüfung 1: Existiert die Abteilung bzw. gibt es Mitarbeiter darin?
    -- Wir prüfen mittels IF NOT EXISTS, ob Datensätze zurückgeliefert würden
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Mitarbeiter AS m
        INNER JOIN dbo.Abteilung AS a ON m.abt_id = a.id
        WHERE a.bezeichnung = @Abteilung
    )
    BEGIN
        -- Ausgabe als Fehlermeldung im Grid (wie in der Aufgabenstellung gefordert)
        SELECT CONCAT('Abteilung ungültig: ', ISNULL(@Abteilung, '[NULL]')) AS Fehlermeldung;

        -- Zusätzliche Statusmeldung im Meldungsfenster
        PRINT CONCAT('Abteilung ungültig: ', ISNULL(@Abteilung, '[NULL]'));
        RETURN;
    END;

    -- Reguläre Ergebnisausgabe, wenn Datensätze gefunden wurden:
    SELECT m.id,
           m.vorname,
           m.nachname,
           m.abt_id,
           a.bezeichnung
    FROM dbo.Mitarbeiter AS m
    INNER JOIN dbo.Abteilung AS a ON m.abt_id = a.id
    WHERE a.bezeichnung = @Abteilung
    ORDER BY m.id;
END;
GO


-- ----------------------------------------------------------------------------
-- Test-Suite für Aufgabe P1.2
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> TEST-SUITE AUFGABE P1.2';
PRINT '======================================================================';

-- Testfall A: Gültige Abteilung mit Mitarbeitern (z. B. 'Einkauf')
PRINT '--- Testfall A: Gültige Abteilung (Einkauf) ---';
EXEC dbo.sp_FilterMitarbeiter1 @Abteilung = 'Einkauf';

-- Testfall B: Ungültige Abteilung ohne Mitarbeiter (z. B. 'Produktion' - Aufgabenbeispiel)
PRINT '--- Testfall B: Ungültige Abteilung (Produktion) ---';
EXEC dbo.sp_FilterMitarbeiter1 @Abteilung = 'Produktion';

-- Testfall C: Beliebige Fantasie-Abteilung (z. B. 'Raumfahrt')
PRINT '--- Testfall C: Fantasie-Abteilung (Raumfahrt) ---';
EXEC dbo.sp_FilterMitarbeiter1 @Abteilung = 'Raumfahrt';
GO


-- ============================================================================
-- TEIL 3: SCHLAUE FRAGEN AN MEINEN DOZENTEN (Tom S.)
-- ============================================================================
-- Diese Fragen demonstrieren tiefes Verständnis für SQL Server Internals,
-- Architektur-Entscheidungen und Enterprise Best Practices rund um die
-- heutigen Themen (Variablen, Ablaufsteuerung, Prozeduren & Funktionen).
-- ============================================================================

/*
-------------------------------------------------------------------------------
Frage 1 (Namenskonvention & Performance-Falle bei 'sp_'):
-------------------------------------------------------------------------------
"In Aufgabe P1.1 lautet der Name der Prozedur 'sp_FilterMitarbeiter1'.
In Produktionsumgebungen und Microsoft-Guidelines wird dringend davor gewarnt,
eigene Prozeduren mit dem Präfix 'sp_' zu benennen, da der SQL Server sonst
immer zuerst in der Systemdatenbank 'master' nachsieht und einen Performance-
Verlust (Cache Miss) erleidet. War das 'sp_' in der Aufgabenstellung historisch
bedingt oder als gezielte Diskussionsgrundlage für Namenskonventionen gedacht?"

-------------------------------------------------------------------------------
Frage 2 (Fehlerbehandlung: Resultset vs. echte Exception via THROW):
-------------------------------------------------------------------------------
"In Aufgabe P1.2 geben wir bei ungültiger Abteilung einen Datensatz mit der
Spalte 'Fehlermeldung' im Resultset (Grid) zurück. In einer echten Enterprise-
Applikation (z. B. C# Backend mit Entity Framework oder Dapper) erwartet die
aufrufende Schicht bei einem Validierungsfehler aber typischerweise keinen
regulären Data-Reader, sondern eine echte SqlException (z. B. via THROW 50001,
'Abteilung ungültig', 1;).
Wann empfiehlt Tom S. in der Praxis Resultset-Fehler und wann echte THROW-Exceptions?"

-------------------------------------------------------------------------------
Frage 3 (Query Optimization & Parameter Sniffing in IF...ELSE Verzweigungen):
-------------------------------------------------------------------------------
"Wenn eine Stored Procedure wie in unserer Such-Kaskade eine IF...ELSE IF
Verzweigung enthält: Kompiliert der Query Optimizer beim Erstaufruf sofort die
Ausführungspläne für ALLE Zweige auf Basis des ersten Parameters (Parameter Sniffing),
oder werden die Zweige erst zur Laufzeit kompiliert, wenn sie tatsächlich betreten
werden (Deferred Compilation / Statement-Level Recompilation)?"

-------------------------------------------------------------------------------
Frage 4 (Batch-Scope vs. Block-Scope – Warum weicht T-SQL von ANSI ab?):
-------------------------------------------------------------------------------
"Wir haben heute gelernt: 'Scope ist der Batch, nicht der Block' – eine Variable,
die in einem IF...BEGIN...END deklariert wird, überlebt das END und existiert bis
zum 'GO'. Warum hat Microsoft in T-SQL diesen Weg gewählt, anstatt wie in fast
allen modernen Programmiersprachen (C#, Java, Python) einen echten Block-Scope
einzuführen? Ist das reine Abwärtskompatibilität zu Sybase SQL Server?"

-------------------------------------------------------------------------------
Frage 5 (Scalar UDF Inlining vs. Inline TVF):
-------------------------------------------------------------------------------
"Skalare Funktionen galten lange als Performance-Killer (RBAR / zeilenweiser
Kontextwechsel). Seit SQL Server 2019 gibt es das Feature 'Scalar UDF Inlining'.
Reicht dieses Feature in modernen Produktivumgebungen aus, oder gilt nach wie vor
die Daumenregel: 'Im Zweifel IMMER eine Inline-Tabellenwertfunktion (iTVF)
mit CROSS APPLY bevorzugen'?"
*/

