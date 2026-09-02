-- ============================================================================
-- SQL-Fundamentals: Day 23 - DCL & SQL Server Sicherheit
-- Datei: 01_authentifizierung_logins_und_users.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 02.09.2026
-- Fokus: Authentifizierung (Server-Ebene) vs. Autorisierung (DB-Ebene)
-- Datenbank: master & ProjektDB (Single Source of Truth)
-- ============================================================================

-- ============================================================================
-- THEORIE: Das 2-stufige Sicherheitsmodell von Microsoft SQL Server
-- ----------------------------------------------------------------------------
-- Der Zugriff auf einen Microsoft SQL Server ist hierarchisch in zwei Ebenen
-- unterteilt:
--
-- 1. STUFE 1: SERVER-EBENE (Authentifizierung - "Wer bist du?")
--    - Ein LOGIN gewährt Zugriff auf die SQL Server Instanz.
--    - Zwei Authentifizierungsmodi:
--      a) Windows-Authentifizierung (Integrierte Sicherheit, Kerberos/NTLM).
--         -> CREATE LOGIN [DOMAIN\User] FROM WINDOWS;
--      b) SQL Server-Authentifizierung (Benutzername & Kennwort in SQL Server).
--         -> CREATE LOGIN [LoginName] WITH PASSWORD = '...';
--    - Server-Rollen: sysadmin, serveradmin, securityadmin, dbcreator etc.
--
-- 2. STUFE 2: DATENBANK-EBENE (Autorisierung - "Was darfst du tun?")
--    - Ein USER in einer spezifischen Datenbank repräsentiert das Login.
--    - Ohne DB-User hat ein Login KEINEN Zugriff auf Datenbankinhalte
--      (Ausnahme: sysadmin / Server-Admin oder wenn 'guest'-User aktiv ist).
--    - Syntax: CREATE USER [UserA] FOR LOGIN [LoginA];
--    - Feste DB-Rollen: db_owner, db_datareader, db_datawriter, db_denydatawriter etc.
-- ============================================================================

USE ProjektDB;
GO

-- ----------------------------------------------------------------------------
-- 1. Idempotentes Aufräumen von Altbeständen (Saubere Testumgebung)
-- ----------------------------------------------------------------------------
PRINT '>>> 1. Vorbereitung: Entfernen bestehender Test-Objekte...';

-- noqa: disable=PRS
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'UserA')
BEGIN
    DROP USER UserA;
    PRINT '    -> UserA in ProjektDB gelöscht.';
END;
GO
-- noqa: enable=PRS

USE master;
GO

-- noqa: disable=PRS
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'LoginA')
BEGIN
    DROP LOGIN LoginA;
    PRINT '    -> LoginA auf Server-Ebene gelöscht.';
END;
GO
-- noqa: enable=PRS


-- ----------------------------------------------------------------------------
-- 2. Erstellung eines Server-Logins (SQL Server-Authentifizierung)
-- ----------------------------------------------------------------------------
PRINT '>>> 2. Server-Login erstellen (LoginA)...';

-- WICHTIG: In Produktivumgebungen CHECK_POLICY = ON und CHECK_EXPIRATION = ON!
CREATE LOGIN LoginA
WITH PASSWORD = 'LoginA_SecureP@ssw0rd!2026',
     DEFAULT_DATABASE = ProjektDB,
     CHECK_POLICY = OFF,
     CHECK_EXPIRATION = OFF;
GO

PRINT '    -> LoginA erfolgreich auf Instanzebene angelegt.';
GO


-- ----------------------------------------------------------------------------
-- 3. Überprüfung des Server-Logins in Systemkatalogen
-- ----------------------------------------------------------------------------
PRINT '>>> 3. Server-Logins in sys.server_principals & sys.sql_logins prüfen...';

SELECT name AS LoginName,
       principal_id AS PrincipalID,
       type_desc AS LoginType,
       is_disabled AS IsDisabled,
       default_database_name AS DefaultDB,
       create_date AS CreateDate
FROM sys.server_principals
WHERE name IN ('LoginA', 'sa')
ORDER BY name;
GO


-- ----------------------------------------------------------------------------
-- 4. Wechsel in die ProjektDB und Erstellung des Datenbank-Benutzers (UserA)
-- ----------------------------------------------------------------------------
USE ProjektDB;
GO

PRINT '>>> 4. Datenbank-Benutzer UserA für LoginA in ProjektDB erstellen...';

CREATE USER UserA
FOR LOGIN LoginA
WITH DEFAULT_SCHEMA = dbo;
GO

PRINT '    -> UserA erfolgreich der ProjektDB zugeordnet (Schema: dbo).';
GO


-- ----------------------------------------------------------------------------
-- 5. Überprüfung des Datenbank-Benutzers in sys.database_principals
-- ----------------------------------------------------------------------------
PRINT '>>> 5. DB-User in ProjektDB katalogisieren...';

SELECT name AS DBUserName,
       principal_id AS DBPrincipalID,
       type_desc AS UserType,
       default_schema_name AS DefaultSchema,
       create_date AS CreateDate,
       SUSER_SNAME(sid) AS MappedServerLogin
FROM sys.database_principals
WHERE name IN ('UserA', 'dbo', 'guest')
ORDER BY name;
GO


-- ----------------------------------------------------------------------------
-- 6. Kontextwechsel & Verbindungstest mit EXECUTE AS
-- ----------------------------------------------------------------------------
PRINT '>>> 6. Verbindungstest unter dem Kontext von UserA...';

-- noqa: disable=PRS
-- Kontext als UserA einnehmen (Simulation)
EXECUTE AS USER = 'UserA';
GO

-- Aktuellen Kontext ermitteln
SELECT SUSER_NAME() AS AktuellerServerLogin,
       USER_NAME() AS AktuellerDBUser,
       ORIGINAL_LOGIN() AS UrspruenglicherAdminLogin;
GO

-- Versuch, ohne vergebene Rechte Daten abzufragen (MUSS fehlschlagen / Fehler provozieren)
BEGIN TRY
    SELECT TOP (5) id, vorname, nachname 
    FROM dbo.Mitarbeiter;
    PRINT '    [INFO] Abfrage erfolgreich!';
END TRY
BEGIN CATCH
    PRINT '    [ERWARTETER FEHLER] Zugriff verweigert! Fehler: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Kontext zurücksetzen zum Administrator
REVERT;
GO
-- noqa: enable=PRS

PRINT '>>> Kontext erfolgreich zurückgesetzt (REVERT).';
SELECT SUSER_NAME() AS AktiverLogin, USER_NAME() AS AktiverUser;
GO
