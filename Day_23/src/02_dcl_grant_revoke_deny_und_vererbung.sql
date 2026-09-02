-- ============================================================================
-- SQL-Fundamentals: Day 23 - DCL & SQL Server Sicherheit
-- Datei: 02_dcl_grant_revoke_deny_und_vererbung.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 02.09.2026
-- Fokus: DCL-Befehle (GRANT, REVOKE, DENY), Vererbung & Spaltenrechte
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

-- ============================================================================
-- THEORIE: DCL (Data Control Language) & Die Berechtigungshierarchie
-- ----------------------------------------------------------------------------
-- 1. DIE DREI DCL-GRUNDBEFEHLE:
--    a) GRANT:   Erteilt ein Recht explizit (Zugriff erlaubt).
--    b) REVOKE:  Entzieht ein zuvor erteiltes/verweigertes Recht (Neutraler Status).
--    c) DENY:    Verbietet ein Recht explizit (Zugriff verweigert).
--
-- 2. DIE GOLDENE REGEL DER RECHTEAUFLÖSUNG:
--    - "DENY schlägt immer GRANT!"
--    - Wenn ein Benutzer oder eine seiner Rollen ein explizites DENY besitzt,
--      wird der Zugriff blockiert, selbst wenn an anderer Stelle ein GRANT vorliegt.
--
-- 3. BERECHTIGUNGSHIERARCHIE (Securables Tree):
--    Server-Ebene
--      └── Datenbank-Ebene (ProjektDB)
--            └── Schema-Ebene (dbo, hr, sales)
--                  └── Objekt-Ebene (Tabellen: Mitarbeiter, Gehalt; Views; Stored Procs)
--                        └── Spalten-Ebene (Mitarbeiter.nachname, Gehalt.gehalt)
--
--    * Vererbungsprinzip: Rechte auf übergeordneter Ebene (z.B. Schema::dbo)
--      vererben sich automatisch auf alle darunterliegenden Objekte!
-- ============================================================================

USE ProjektDB;
GO

-- Sicherstellen, dass UserA existiert
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'UserA')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'LoginA')
    BEGIN
        CREATE LOGIN LoginA WITH PASSWORD = 'LoginA_SecureP@ssw0rd!2026', CHECK_POLICY = OFF;
    END;
    CREATE USER UserA FOR LOGIN LoginA WITH DEFAULT_SCHEMA = dbo;
END;
GO


-- ============================================================================
-- TEIL 1: GRANT auf Schema-Ebene (Vererbung auf alle Tabellen)
-- ============================================================================
PRINT '--- TEIL 1: GRANT SELECT auf SCHEMA::dbo für UserA ---';

-- Schritt 1: Leserecht auf gesamtes dbo-Schema vergeben
GRANT SELECT ON SCHEMA::dbo TO UserA;
GO

-- noqa: disable=PRS
-- Testlauf unter UserA
EXECUTE AS USER = 'UserA';
GO

PRINT '>>> Test 1.1: SELECT auf Mitarbeiter (via Schema-Vererbung)...';
SELECT TOP (3) id, vorname, nachname, ort FROM dbo.Mitarbeiter;

PRINT '>>> Test 1.2: SELECT auf Gehalt (via Schema-Vererbung)...';
SELECT TOP (3) mit_id, gehalt FROM dbo.Gehalt;
GO

REVERT;
GO
-- noqa: enable=PRS


-- ============================================================================
-- TEIL 2: Explizites DENY auf Objektebene (Tabelle Gehalt schützen)
-- ============================================================================
PRINT '--- TEIL 2: DENY SELECT auf Tabelle dbo.Gehalt für UserA ---';

-- Schritt 2: Zugriff auf sensible Gehaltsdaten explizit verbieten
DENY SELECT ON dbo.Gehalt TO UserA;
GO

-- noqa: disable=PRS
-- Testlauf unter UserA
EXECUTE AS USER = 'UserA';
GO

PRINT '>>> Test 2.1: SELECT auf Mitarbeiter (sollte weiterhin funktionieren)...';
SELECT TOP (2) id, vorname, nachname FROM dbo.Mitarbeiter;

PRINT '>>> Test 2.2: SELECT auf Gehalt (sollte durch DENY blockiert werden)...';
BEGIN TRY
    SELECT TOP (2) mit_id, gehalt FROM dbo.Gehalt;
    PRINT '    [FEHLER] Gehaltsabfrage durfte nicht gelingen!';
END TRY
BEGIN CATCH
    PRINT '    [ERFOLGREICH BLOCKIERT] DENY greift! Fehler: ' + ERROR_MESSAGE();
END CATCH;
GO

REVERT;
GO
-- noqa: enable=PRS


-- ============================================================================
-- TEIL 3: REVOKE vs. DENY – Der fundamentale Unterschied
-- ============================================================================
PRINT '--- TEIL 3: REVOKE auf dbo.Gehalt ausführen ---';

-- REVOKE entfernt das explizite DENY (setzt den Status auf neutral zurück)
REVOKE SELECT ON dbo.Gehalt FROM UserA;
GO

-- noqa: disable=PRS
-- Testlauf unter UserA
EXECUTE AS USER = 'UserA';
GO

PRINT '>>> Test 3.1: SELECT auf Gehalt nach REVOKE (Schema-GRANT greift wieder!)...';
BEGIN TRY
    SELECT TOP (2) mit_id, gehalt FROM dbo.Gehalt;
    PRINT '    [INFO] Durch REVOKE ist das Tabellen-DENY weg -> Schema::dbo GRANT wirkt wieder!';
END TRY
BEGIN CATCH
    PRINT '    [FEHLER] ' + ERROR_MESSAGE();
END CATCH;
GO

REVERT;
GO
-- noqa: enable=PRS


-- ============================================================================
-- TEIL 4: Granulare Spaltenberechtigungen (Column-Level Permissions)
-- ============================================================================
PRINT '--- TEIL 4: Spalten-Rechte (Column-Level DENY) ---';

-- Szenario: Mitarbeiter-Stammdaten sind lesbar, aber Nachname oder sensible Spalten werden gesperrt
DENY SELECT ON dbo.Mitarbeiter(nachname) TO UserA;
GO

-- noqa: disable=PRS
-- Testlauf unter UserA
EXECUTE AS USER = 'UserA';
GO

PRINT '>>> Test 4.1: SELECT nur id, vorname, ort (ohne gesperrte Spalte nachname)...';
SELECT TOP (2) id, vorname, ort FROM dbo.Mitarbeiter;

PRINT '>>> Test 4.2: SELECT * oder SELECT nachname (muss fehlschlagen)...';
BEGIN TRY
    SELECT TOP (2) id, vorname, nachname FROM dbo.Mitarbeiter;
    PRINT '    [FEHLER] Spaltenabfrage durfte nicht gelingen!';
END TRY
BEGIN CATCH
    PRINT '    [ERFOLGREICH BLOCKIERT] Spalten-DENY greift! Fehler: ' + ERROR_MESSAGE();
END CATCH;
GO

REVERT;
GO
-- noqa: enable=PRS

-- Aufräumen der Spaltensperre
REVOKE SELECT ON dbo.Mitarbeiter(nachname) FROM UserA;
GO
PRINT '>>> Spalten-DENY auf Mitarbeiter(nachname) aufgehoben.';
GO
