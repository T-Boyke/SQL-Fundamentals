-- ============================================================================
-- SQL-Fundamentals: Day 23 - DCL & SQL Server Sicherheit
-- Datei: 03_rollenbasierte_sicherheit_rbac_projektdb.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 02.09.2026
-- Fokus: Role-Based Access Control (RBAC), Custom DB Roles & Ownership Chaining
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

-- ============================================================================
-- THEORIE: Role-Based Access Control (RBAC) in Datenbanken
-- ----------------------------------------------------------------------------
-- Das Prinzip von RBAC:
-- 1. Niemals individuelle Berechtigungen direkt an einzelne Benutzer vergeben!
--    (Anti-Pattern: Führt bei Mitarbeiterwechseln zu "Permission Rot" & Chaos).
-- 2. Stattdessen:
--    - Erstelle datenbank-spezifische Rollen für fachliche Aufgabenbereiche.
--    - Weise Berechtigungen ausschließlich den Rollen zu.
--    - Füge Benutzer als Mitglieder den entsprechenden Rollen hinzu.
--
-- Rollenarchitektur für ProjektDB:
-- ┌───────────────────┬────────────────────────────────────────────────────────┐
-- │ Rolle             │ Berechtigungen & Zweck                                 │
-- ├───────────────────┼────────────────────────────────────────────────────────┤
-- │ ProjektRO         │ SELECT auf SCHEMA::dbo (Nur lesender Zugriff)          │
-- │ ProjektRW         │ SELECT, INSERT, UPDATE, DELETE auf SCHEMA::dbo         │
-- │ MitarbeiterCRUD   │ SELECT, INSERT, UPDATE auf Mitarbeiter (DENY DELETE)   │
-- │ ProjektHR         │ Vollzugriff auf Gehalt, Mitarbeiter, Arbeit            │
-- └───────────────────┴────────────────────────────────────────────────────────┘
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- 1. Bereinigung und Vorbereitung der Testbenutzer und Rollen
-- ============================================================================
PRINT '>>> 1. Vorbereitung der Testumgebung...';

-- Benutzer aus Rollen entfernen und Rollen löschen falls vorhanden
IF DATABASE_PRINCIPAL_ID('ProjektRO') IS NOT NULL
BEGIN
    IF DATABASE_PRINCIPAL_ID('User_ReadOnly') IS NOT NULL
        ALTER ROLE ProjektRO DROP MEMBER User_ReadOnly;
    IF DATABASE_PRINCIPAL_ID('UserA') IS NOT NULL
        ALTER ROLE ProjektRO DROP MEMBER UserA;
    DROP ROLE ProjektRO;
    PRINT '    -> Alte Rolle ProjektRO entfernt.';
END;

IF DATABASE_PRINCIPAL_ID('ProjektRW') IS NOT NULL
BEGIN
    IF DATABASE_PRINCIPAL_ID('User_DataEntry') IS NOT NULL
        ALTER ROLE ProjektRW DROP MEMBER User_DataEntry;
    DROP ROLE ProjektRW;
    PRINT '    -> Alte Rolle ProjektRW entfernt.';
END;

IF DATABASE_PRINCIPAL_ID('MitarbeiterCRUD') IS NOT NULL
BEGIN
    IF DATABASE_PRINCIPAL_ID('User_DataEntry') IS NOT NULL
        ALTER ROLE MitarbeiterCRUD DROP MEMBER User_DataEntry;
    DROP ROLE MitarbeiterCRUD;
    PRINT '    -> Alte Rolle MitarbeiterCRUD entfernt.';
END;

IF DATABASE_PRINCIPAL_ID('ProjektHR') IS NOT NULL
BEGIN
    IF DATABASE_PRINCIPAL_ID('User_HR') IS NOT NULL
        ALTER ROLE ProjektHR DROP MEMBER User_HR;
    DROP ROLE ProjektHR;
    PRINT '    -> Alte Rolle ProjektHR entfernt.';
END;

-- Benutzer anlegen falls nicht vorhanden
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Login_ReadOnly')
    CREATE LOGIN Login_ReadOnly WITH PASSWORD = 'ReadOnly_P@ssw0rd!2026', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'User_ReadOnly')
    CREATE USER User_ReadOnly FOR LOGIN Login_ReadOnly WITH DEFAULT_SCHEMA = dbo;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Login_DataEntry')
    CREATE LOGIN Login_DataEntry WITH PASSWORD = 'DataEntry_P@ssw0rd!2026', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'User_DataEntry')
    CREATE USER User_DataEntry FOR LOGIN Login_DataEntry WITH DEFAULT_SCHEMA = dbo;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Login_HR')
    CREATE LOGIN Login_HR WITH PASSWORD = 'HR_SecureP@ssw0rd!2026', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'User_HR')
    CREATE USER User_HR FOR LOGIN Login_HR WITH DEFAULT_SCHEMA = dbo;
GO


-- ============================================================================
-- 2. Erstellung benutzerdefinierter Datenbankrollen (Custom Roles)
-- ============================================================================
PRINT '>>> 2. Erstellung der Fachrollen (ProjektRO, ProjektRW, MitarbeiterCRUD, ProjektHR)...';

-- 2.1 Read-Only Rolle (ProjektRO)
CREATE ROLE ProjektRO;
GRANT SELECT ON SCHEMA::dbo TO ProjektRO;
-- Sensible Gehaltsdaten für normale Leser standardmäßig sperren
DENY SELECT ON dbo.Gehalt TO ProjektRO;
PRINT '    -> Rolle ProjektRO erstellt (SELECT dbo, DENY Gehalt).';

-- 2.2 Read-Write Rolle (ProjektRW)
CREATE ROLE ProjektRW;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO ProjektRW;
-- Auch Dateneingeber haben keinen direkten Zugriff auf Gehälter
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Gehalt TO ProjektRW;
PRINT '    -> Rolle ProjektRW erstellt (DML auf dbo, DENY Gehalt).';

-- 2.3 MitarbeiterCRUD Rolle (Vorlesungsbeispiel Slide 12 & 13)
CREATE ROLE MitarbeiterCRUD;
GRANT SELECT, INSERT, UPDATE ON dbo.Mitarbeiter TO MitarbeiterCRUD;
DENY DELETE ON dbo.Mitarbeiter TO MitarbeiterCRUD;
PRINT '    -> Rolle MitarbeiterCRUD erstellt (SELECT, INSERT, UPDATE - DENY DELETE).';

-- 2.4 HR Spezialrolle (ProjektHR)
CREATE ROLE ProjektHR;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Mitarbeiter TO ProjektHR;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Gehalt TO ProjektHR;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Arbeit TO ProjektHR;
PRINT '    -> Rolle ProjektHR erstellt (Voller Zugriff auf Mitarbeiter & Gehalt).';
GO


-- ============================================================================
-- 3. Zuweisung von Benutzern zu Rollen (Role Membership)
-- ============================================================================
PRINT '>>> 3. Benutzer den Rollen zuweisen (ALTER ROLE ... ADD MEMBER)...';

ALTER ROLE ProjektRO ADD MEMBER User_ReadOnly;
ALTER ROLE ProjektRW ADD MEMBER User_DataEntry;
ALTER ROLE MitarbeiterCRUD ADD MEMBER User_DataEntry;
ALTER ROLE ProjektHR ADD MEMBER User_HR;
GO


-- ============================================================================
-- 4. Kapselung über Sichten (Views) & Ownership Chaining
-- ============================================================================
PRINT '>>> 4. Gesicherte Aggregat-Sicht mit Ownership Chaining anlegen...';

-- Sicht für aggregierte Gehaltsstatistiken (keine Einzeleinsicht in Gehälter)
CREATE OR ALTER VIEW dbo.v_AbteilungGehaltsstatistik
AS
SELECT a.id AS AbteilungID,
       a.kuerzel,
       a.bezeichnung AS Abteilungsname,
       COUNT(m.id) AS AnzahlMitarbeiter,
       AVG(g.gehalt) AS Durchschnittsgehalt,
       MIN(g.gehalt) AS Mindestgehalt,
       MAX(g.gehalt) AS Maximalgehalt
FROM dbo.Abteilung AS a
LEFT JOIN dbo.Mitarbeiter AS m ON a.id = m.abt_id
LEFT JOIN dbo.Gehalt AS g ON m.id = g.mit_id
GROUP BY a.id, a.kuerzel, a.bezeichnung;
GO

-- Der Read-Only Rolle expliziten Zugriff auf die Sicht erlauben
GRANT SELECT ON dbo.v_AbteilungGehaltsstatistik TO ProjektRO;
PRINT '    -> Sicht v_AbteilungGehaltsstatistik für ProjektRO freigegeben.';
GO


-- ============================================================================
-- 5. Praktische Testläufe für alle Rollen mit EXECUTE AS
-- ============================================================================
PRINT '>>> 5. Testläufe der Rollen...';

-- ----------------------------------------------------------------------------
-- TEST 5.1: User_ReadOnly (Mitglied von ProjektRO)
-- ----------------------------------------------------------------------------
PRINT '--- Test 5.1: User_ReadOnly ---';
-- noqa: disable=PRS
EXECUTE AS USER = 'User_ReadOnly';
GO

PRINT '    [User_ReadOnly] 1. Abfrage Mitarbeiter (Erwartet: OK):';
SELECT TOP (3) id, vorname, nachname, ort FROM dbo.Mitarbeiter;

PRINT '    [User_ReadOnly] 2. Direkte Abfrage Gehalt (Erwartet: FEHLER wg. DENY):';
BEGIN TRY
    SELECT TOP (3) mit_id, gehalt FROM dbo.Gehalt;
    PRINT '    [FEHLER] Gehalt durfte nicht lesbar sein!';
END TRY
BEGIN CATCH
    PRINT '    [OK - BLOCKIERT] ' + ERROR_MESSAGE();
END CATCH;

PRINT '    [User_ReadOnly] 3. Abfrage der Statistik-Sicht via Ownership Chaining (Erwartet: OK):';
SELECT * FROM dbo.v_AbteilungGehaltsstatistik;

PRINT '    [User_ReadOnly] 4. INSERT-Versuch (Erwartet: FEHLER wg. fehlendem WRITE-Recht):';
BEGIN TRY
    INSERT INTO dbo.Kunde (id, firma, ort) VALUES (9999, 'Hacker Corp', 'Berlin');
    PRINT '    [FEHLER] INSERT durfte nicht gelingen!';
END TRY
BEGIN CATCH
    PRINT '    [OK - BLOCKIERT] ' + ERROR_MESSAGE();
END CATCH;
GO
REVERT;
GO
-- noqa: enable=PRS

-- ----------------------------------------------------------------------------
-- TEST 5.2: User_DataEntry (Mitglied von ProjektRW & MitarbeiterCRUD)
-- ----------------------------------------------------------------------------
PRINT '--- Test 5.2: User_DataEntry ---';
-- noqa: disable=PRS
EXECUTE AS USER = 'User_DataEntry';
GO

PRINT '    [User_DataEntry] 1. Kunde einfügen und aktualisieren (Erwartet: OK):';
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM dbo.Kunde WHERE id = 999)
        INSERT INTO dbo.Kunde (id, firma, ort) VALUES (999, 'Testfirma GmbH', 'Hamburg');

    UPDATE dbo.Kunde SET ort = 'Bremen' WHERE id = 999;
    SELECT * FROM dbo.Kunde WHERE id = 999;
    PRINT '    [OK] DML erfolgreich ausgeführt.';
END TRY
BEGIN CATCH
    PRINT '    [FEHLER] ' + ERROR_MESSAGE();
END CATCH;

PRINT '    [User_DataEntry] 2. DELETE auf Mitarbeiter (Erwartet: BLOCKIERT durch MitarbeiterCRUD DENY):';
BEGIN TRY
    DELETE FROM dbo.Mitarbeiter WHERE id = 99999;
    PRINT '    [FEHLER] DELETE durfte nicht gelingen!';
END TRY
BEGIN CATCH
    PRINT '    [OK - BLOCKIERT] ' + ERROR_MESSAGE();
END CATCH;
GO
REVERT;
GO
-- noqa: enable=PRS

-- Bereinigung Testkunde durch Admin
DELETE FROM dbo.Kunde WHERE id = 999;
GO

-- ----------------------------------------------------------------------------
-- TEST 5.3: User_HR (Mitglied von ProjektHR)
-- ----------------------------------------------------------------------------
PRINT '--- Test 5.3: User_HR ---';
-- noqa: disable=PRS
EXECUTE AS USER = 'User_HR';
GO

PRINT '    [User_HR] 1. Mitarbeiter inklusive Gehalt abfragen (Erwartet: OK):';
SELECT TOP (3) m.id, m.vorname, m.nachname, g.gehalt
FROM dbo.Mitarbeiter AS m
JOIN dbo.Gehalt AS g ON m.id = g.mit_id;

PRINT '    [User_HR] 2. Zugriff auf Kunden / Umsätze (Erwartet: FEHLER wg. Principle of Least Privilege):';
BEGIN TRY
    SELECT TOP (3) * FROM dbo.Umsatz;
    PRINT '    [FEHLER] HR-Rolle sollte keinen Zugriff auf Umsätze haben!';
END TRY
BEGIN CATCH
    PRINT '    [OK - BLOCKIERT] ' + ERROR_MESSAGE();
END CATCH;
GO
REVERT;
GO
-- noqa: enable=PRS

PRINT '>>> Alle RBAC-Tests erfolgreich abgeschlossen!';
GO
