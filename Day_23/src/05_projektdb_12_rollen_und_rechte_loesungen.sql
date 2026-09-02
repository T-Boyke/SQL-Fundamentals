-- ============================================================================
-- SQL-Fundamentals: Day 23 - DCL & SQL Server Sicherheit
-- Datei: 05_projektdb_12_rollen_und_rechte_loesungen.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 02.09.2026
-- Fokus: Vollständige Musterlösung für "ProjektDB 12 - Rollen und Rechte"
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

-- ============================================================================
-- AUFGABENSTELLUNG: ProjektDB 12 - Rollen und Rechte
-- ----------------------------------------------------------------------------
-- Aufgabe 12.1: Drei neue User anlegen: Alice, Bob, Charlie.
-- Aufgabe 12.2: Zwei benutzerdefinierte Rollen anlegen: DataReader, DataEditor.
-- Aufgabe 12.3: User den Rollen zuweisen:
--               - Alice   -> DataReader
--               - Bob     -> DataEditor
--               - Charlie -> DataReader UND DataEditor
-- Aufgabe 12.4: Rechtevergabe:
--               - DataReader: darf Mitarbeiter und Gehalt LESEN (SELECT).
--               - DataEditor: darf Mitarbeiter und Gehalt LESEN, EINFÜGEN und ÄNDERN (SELECT, INSERT, UPDATE).
--               - Keine DELETE-Rechte für diese Rollen.
--               - Alice soll AUSDRÜCKLICH KEINEN Zugriff auf Gehalt bekommen (DENY).
-- ============================================================================

USE ProjektDB;
GO

-- ----------------------------------------------------------------------------
-- 0. Idempotente Bereinigung von Altbeständen
-- ----------------------------------------------------------------------------
PRINT '>>> 0. Vorbereitung & Bereinigung...';

-- Rollenmitglieder entfernen und Rollen löschen
IF DATABASE_PRINCIPAL_ID('DataReader') IS NOT NULL
BEGIN
    IF DATABASE_PRINCIPAL_ID('Alice') IS NOT NULL ALTER ROLE DataReader DROP MEMBER Alice;
    IF DATABASE_PRINCIPAL_ID('Charlie') IS NOT NULL ALTER ROLE DataReader DROP MEMBER Charlie;
    DROP ROLE DataReader;
    PRINT '    -> Alte Rolle DataReader entfernt.';
END;

IF DATABASE_PRINCIPAL_ID('DataEditor') IS NOT NULL
BEGIN
    IF DATABASE_PRINCIPAL_ID('Bob') IS NOT NULL ALTER ROLE DataEditor DROP MEMBER Bob;
    IF DATABASE_PRINCIPAL_ID('Charlie') IS NOT NULL ALTER ROLE DataEditor DROP MEMBER Charlie;
    DROP ROLE DataEditor;
    PRINT '    -> Alte Rolle DataEditor entfernt.';
END;

-- Test-User entfernen
IF DATABASE_PRINCIPAL_ID('Alice') IS NOT NULL DROP USER Alice;
IF DATABASE_PRINCIPAL_ID('Bob') IS NOT NULL DROP USER Bob;
IF DATABASE_PRINCIPAL_ID('Charlie') IS NOT NULL DROP USER Charlie;
PRINT '    -> Alte User (Alice, Bob, Charlie) entfernt.';
GO


-- ============================================================================
-- AUFGABE 12.1: Drei neue User in der ProjektDB anlegen
-- ============================================================================
PRINT '>>> AUFGABE 12.1: User Alice, Bob und Charlie anlegen...';

-- Hinweis: WITHOUT LOGIN eignet sich ideal für DB-interne Berechtigungstests
CREATE USER Alice WITHOUT LOGIN;
CREATE USER Bob WITHOUT LOGIN;
CREATE USER Charlie WITHOUT LOGIN;
GO

PRINT '    -> User Alice, Bob und Charlie erfolgreich in ProjektDB erstellt.';
GO


-- ============================================================================
-- AUFGABE 12.2: Zwei neue Rollen in der Datenbank anlegen
-- ============================================================================
PRINT '>>> AUFGABE 12.2: Rollen DataReader und DataEditor anlegen...';

CREATE ROLE DataReader;
CREATE ROLE DataEditor;
GO

PRINT '    -> Rollen DataReader und DataEditor erfolgreich angelegt.';
GO


-- ============================================================================
-- AUFGABE 12.3: User den Rollen zuordnen
-- ============================================================================
PRINT '>>> AUFGABE 12.3: Rollenzuweisungen vornehmen...';

-- Alice gehört zu DataReader
ALTER ROLE DataReader ADD MEMBER Alice;

-- Bob gehört zu DataEditor
ALTER ROLE DataEditor ADD MEMBER Bob;

-- Charlie gehört zu BEIDEN Rollen
ALTER ROLE DataReader ADD MEMBER Charlie;
ALTER ROLE DataEditor ADD MEMBER Charlie;
GO

PRINT '    -> Alice -> DataReader';
PRINT '    -> Bob -> DataEditor';
PRINT '    -> Charlie -> DataReader & DataEditor';
GO


-- ============================================================================
-- AUFGABE 12.4: Rechte an Rollen und User vergeben
-- ============================================================================
PRINT '>>> AUFGABE 12.4: DCL Berechtigungen (GRANT / DENY) konfigurieren...';

-- 1. DataReader darf Mitarbeiter und Gehalt lesen (SELECT)
GRANT SELECT ON dbo.Mitarbeiter TO DataReader;
GRANT SELECT ON dbo.Gehalt TO DataReader;

-- 2. DataEditor darf Mitarbeiter und Gehalt lesen, einfügen und ändern (SELECT, INSERT, UPDATE)
GRANT SELECT, INSERT, UPDATE ON dbo.Mitarbeiter TO DataEditor;
GRANT SELECT, INSERT, UPDATE ON dbo.Gehalt TO DataEditor;

-- 3. Niemand darf über diese Rollen Datensätze löschen (DELETE)
-- -> Durch das Fehlen von GRANT DELETE haben die Rollen per Default kein Löschrecht.
--    Optional kann zur Härtung ein explizites DENY DELETE vergeben werden:
-- DENY DELETE ON dbo.Mitarbeiter TO DataReader, DataEditor;
-- DENY DELETE ON dbo.Gehalt TO DataReader, DataEditor;

-- 4. Alice soll AUSDRÜCKLICH keinen Zugriff auf Gehalt bekommen
-- -> WICHTIG: Hier MUSS zwingend DENY verwendet werden, da REVOKE das Recht aus
--    der Rolle DataReader nicht blockieren würde ("DENY schlägt immer GRANT!"):
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Gehalt TO Alice;
GO

PRINT '    -> Rechtevergabe erfolgreich abgeschlossen.';
GO


-- ============================================================================
-- 5. VERIFIKATION & PRAKTISCHE TESTSUITE (Simulation via EXECUTE AS)
-- ============================================================================
PRINT '==========================================================';
PRINT '>>> 5. Testsuite zur Überprüfung aller Anforderungen...';
PRINT '==========================================================';

-- ----------------------------------------------------------------------------
-- TEST 5.1: ALICE (Mitglied in DataReader, explizites DENY auf Gehalt)
-- ----------------------------------------------------------------------------
PRINT '--- Test 5.1: Benutzer Alice ---';
-- noqa: disable=PRS
EXECUTE AS USER = 'Alice';
GO

PRINT '    [Alice] 1. Mitarbeiter lesen (Erwartet: ERFOLG):';
SELECT TOP (2) id, vorname, nachname, ort FROM dbo.Mitarbeiter;

PRINT '    [Alice] 2. Gehalt lesen (Erwartet: BLOCKIERT durch DENY):';
BEGIN TRY
    SELECT TOP (2) mit_id, gehalt FROM dbo.Gehalt;
    PRINT '    [FEHLER] Alice durfte kein Gehalt lesen!';
END TRY
BEGIN CATCH
    PRINT '    [OK - BLOCKIERT] Zugriff verweigert! Fehler: ' + ERROR_MESSAGE();
END CATCH;

PRINT '    [Alice] 3. Mitarbeiter ändern (Erwartet: BLOCKIERT wg. fehlendem UPDATE):';
BEGIN TRY
    UPDATE dbo.Mitarbeiter SET ort = 'Test' WHERE id = 1;
    PRINT '    [FEHLER] Alice durfte kein UPDATE ausführen!';
END TRY
BEGIN CATCH
    PRINT '    [OK - BLOCKIERT] Zugriff verweigert! Fehler: ' + ERROR_MESSAGE();
END CATCH;
GO
REVERT;
GO
-- noqa: enable=PRS


-- ----------------------------------------------------------------------------
-- TEST 5.2: BOB (Mitglied in DataEditor)
-- ----------------------------------------------------------------------------
PRINT '--- Test 5.2: Benutzer Bob ---';
-- noqa: disable=PRS
EXECUTE AS USER = 'Bob';
GO

PRINT '    [Bob] 1. Mitarbeiter lesen (Erwartet: ERFOLG):';
SELECT TOP (2) id, vorname, nachname, ort FROM dbo.Mitarbeiter;

PRINT '    [Bob] 2. Gehalt lesen (Erwartet: ERFOLG):';
SELECT TOP (2) mit_id, gehalt FROM dbo.Gehalt;

PRINT '    [Bob] 3. Mitarbeiter löschen (Erwartet: BLOCKIERT wg. fehlendem DELETE):';
BEGIN TRY
    DELETE FROM dbo.Mitarbeiter WHERE id = 99999;
    PRINT '    [FEHLER] Bob durfte kein DELETE ausführen!';
END TRY
BEGIN CATCH
    PRINT '    [OK - BLOCKIERT] Zugriff verweigert! Fehler: ' + ERROR_MESSAGE();
END CATCH;
GO
REVERT;
GO
-- noqa: enable=PRS


-- ----------------------------------------------------------------------------
-- TEST 5.3: CHARLIE (Mitglied in DataReader UND DataEditor)
-- ----------------------------------------------------------------------------
PRINT '--- Test 5.3: Benutzer Charlie ---';
-- noqa: disable=PRS
EXECUTE AS USER = 'Charlie';
GO

PRINT '    [Charlie] 1. Mitarbeiter & Gehalt lesen (Erwartet: ERFOLG):';
SELECT TOP (2) m.vorname, m.nachname, g.gehalt
FROM dbo.Mitarbeiter AS m
INNER JOIN dbo.Gehalt AS g ON m.id = g.mit_id;

PRINT '    [Charlie] 2. Gehalt löschen (Erwartet: BLOCKIERT wg. fehlendem DELETE):';
BEGIN TRY
    DELETE FROM dbo.Gehalt WHERE mit_id = 99999;
    PRINT '    [FEHLER] Charlie durfte kein DELETE ausführen!';
END TRY
BEGIN CATCH
    PRINT '    [OK - BLOCKIERT] Zugriff verweigert! Fehler: ' + ERROR_MESSAGE();
END CATCH;
GO
REVERT;
GO
-- noqa: enable=PRS

PRINT '==========================================================';
PRINT '>>> Alle Prüfungen für Aufgabe 12 erfolgreich bestanden!';
PRINT '==========================================================';
GO
