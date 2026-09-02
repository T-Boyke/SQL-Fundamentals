-- ============================================================================
-- SQL-Fundamentals: Day 23 - DCL & SQL Server Sicherheit
-- Datei: 04_sicherheitsaudit_metadaten_und_troubleshooting.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 02.09.2026
-- Fokus: Sicherheitsaudit, Systemkataloge, Effektive Rechte & Orphaned Users
-- Datenbank: master & ProjektDB (Single Source of Truth)
-- ============================================================================

-- ============================================================================
-- THEORIE: Sicherheits-Metadaten & Troubleshooting in SQL Server
-- ----------------------------------------------------------------------------
-- 1. SYSTEMKATALOG-VIEWS FÜR SECURITY AUDITING:
--    - sys.server_principals:   Alle Server-Logins, Server-Rollen und Zertifikate.
--    - sys.database_principals: Alle DB-Benutzer, DB-Rollen und Anwendungsrollen.
--    - sys.database_role_members: M:N Zuordnung von Benutzern zu Rollen.
--    - sys.database_permissions: Vergebene, entzogene und verweigerte Rechte.
--
-- 2. FUNKTIONEN ZUR RECHTEPRÜFUNG:
--    - HAS_PERMS_BY_NAME(): Prüft, ob der aktuelle Kontext ein bestimmtes Recht besitzt.
--    - fn_my_permissions(): Liefert eine Tabelle aller effektiven Rechte auf ein Objekt.
--
-- 3. ORPHANED USERS (Verwaiste Benutzer):
--    - Entstehen typischerweise nach einem RESTORE oder ATTACH einer Datenbank
--      auf einem neuen Server.
--    - Der DB-User verweist auf eine SID, die auf der neuen Instanz nicht existiert.
--    - Reparatur: ALTER USER <UserName> WITH LOGIN = <LoginName>;
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- 1. Rollenmitgliedschaften auditieren (Wer ist in welcher Rolle?)
-- ============================================================================
PRINT '>>> 1. Übersicht aller Rollen und ihrer Mitglieder in ProjektDB...';

SELECT r.name AS RoleName,
       r.type_desc AS RoleType,
       m.name AS MemberName,
       m.type_desc AS MemberType,
       m.create_date AS MemberCreateDate
FROM sys.database_role_members AS rm
INNER JOIN sys.database_principals AS r 
    ON rm.role_principal_id = r.principal_id
INNER JOIN sys.database_principals AS m 
    ON rm.member_principal_id = m.principal_id
WHERE r.name IN ('ProjektRO', 'ProjektRW', 'ProjektHR', 'db_datareader', 'db_datawriter', 'db_owner')
ORDER BY r.name, m.name;
GO


-- ============================================================================
-- 2. Explizite Berechtigungen im Detail auditieren (sys.database_permissions)
-- ============================================================================
PRINT '>>> 2. Detaillierte Berechtigungsmatrix (GRANT / DENY auf Objekte & Schemata)...';

SELECT pr.name AS PrincipalName,
       pr.type_desc AS PrincipalType,
       pe.class_desc AS SecurableClass,
       CASE pe.class
           WHEN 0 THEN DB_NAME()
           WHEN 1 THEN OBJECT_SCHEMA_NAME(pe.major_id) + '.' + OBJECT_NAME(pe.major_id)
                       + ISNULL(' (' + COL_NAME(pe.major_id, pe.minor_id) + ')', '')
           WHEN 3 THEN SCHEMA_NAME(pe.major_id)
           ELSE 'Anderes Objekt'
       END AS SecurableName,
       pe.permission_name AS PermissionName,
       pe.state_desc AS PermissionState
FROM sys.database_permissions AS pe
INNER JOIN sys.database_principals AS pr 
    ON pe.grantee_principal_id = pr.principal_id
WHERE pr.name IN ('UserA', 'User_ReadOnly', 'User_DataEntry', 'User_HR', 'ProjektRO', 'ProjektRW', 'ProjektHR')
ORDER BY pr.name, pe.class_desc, SecurableName;
GO


-- ============================================================================
-- 3. Effektive Berechtigungen abfragen mit sys.fn_my_permissions()
-- ============================================================================
PRINT '>>> 3. Effektive Rechte für User_ReadOnly auf SCHEMA::dbo prüfen...';

-- noqa: disable=PRS
EXECUTE AS USER = 'User_ReadOnly';
GO

-- Gibt alle effektiven Rechte auf das Schema dbo zurück
SELECT entity_name, subentity_name, permission_name
FROM sys.fn_my_permissions('dbo', 'SCHEMA')
ORDER BY permission_name;

-- Prüfen, ob SELECT auf Gehalt erlaubt ist (0 = Nein, 1 = Ja)
SELECT HAS_PERMS_BY_NAME('dbo.Mitarbeiter', 'OBJECT', 'SELECT') AS KannMitarbeiterLesen,
       HAS_PERMS_BY_NAME('dbo.Gehalt', 'OBJECT', 'SELECT') AS KannGehaltLesen,
       HAS_PERMS_BY_NAME('dbo.Kunde', 'OBJECT', 'INSERT') AS KannKundeEinfuegen;
GO

REVERT;
GO
-- noqa: enable=PRS


-- ============================================================================
-- 4. Orphaned Users (Verwaiste Benutzer) aufspüren & reparieren
-- ============================================================================
PRINT '>>> 4. Verwaiste Benutzer ohne gültigen Server-Login identifizieren...';

SELECT dp.name AS OrphanedDBUser,
       dp.type_desc AS UserType,
       dp.sid AS DBSid
FROM sys.database_principals AS dp
LEFT OUTER JOIN sys.server_principals AS sp 
    ON dp.sid = sp.sid
WHERE dp.type IN ('S', 'U') -- SQL User oder Windows User
  AND dp.authentication_type <> 0 -- Kein Schema/Rolle
  AND dp.name NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA', 'sys')
  AND sp.sid IS NULL;
GO

-- Reparaturanweisung für verwaiste Benutzer (Beispiel):
-- ALTER USER [UserA] WITH LOGIN = [LoginA];
-- GO


-- ============================================================================
-- 5. Zentrales Bereinigungs-Skript (Teardown aller Testobjekte)
-- ============================================================================
PRINT '>>> 5. Bereinigung aller für Day 23 angelegten Test-Sicherheitsobjekte...';

USE ProjektDB;
GO

-- 5.1 Test-Sicht entfernen
IF OBJECT_ID('dbo.v_AbteilungGehaltsstatistik', 'V') IS NOT NULL
    DROP VIEW dbo.v_AbteilungGehaltsstatistik;

-- 5.2 Test-Rollen und Zuweisungen entfernen
DECLARE @roles TABLE (RoleName SYSNAME);
INSERT INTO @roles VALUES ('ProjektRO'), ('ProjektRW'), ('ProjektHR');

DECLARE @rName SYSNAME;
DECLARE role_cursor CURSOR FOR SELECT RoleName FROM @roles;
OPEN role_cursor;
FETCH NEXT FROM role_cursor INTO @rName;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF DATABASE_PRINCIPAL_ID(@rName) IS NOT NULL
    BEGIN
        -- Mitglieder entfernen
        DECLARE @mName SYSNAME;
        DECLARE mem_cursor CURSOR FOR 
            SELECT m.name 
            FROM sys.database_role_members AS rm
            INNER JOIN sys.database_principals AS m 
                ON rm.member_principal_id = m.principal_id
            WHERE rm.role_principal_id = DATABASE_PRINCIPAL_ID(@rName);
        
        OPEN mem_cursor;
        FETCH NEXT FROM mem_cursor INTO @mName;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC('ALTER ROLE [' + @rName + '] DROP MEMBER [' + @mName + '];');
            FETCH NEXT FROM mem_cursor INTO @mName;
        END;
        CLOSE mem_cursor;
        DEALLOCATE mem_cursor;

        EXEC('DROP ROLE [' + @rName + '];');
        PRINT '    -> Rolle ' + @rName + ' gelöscht.';
    END;
    FETCH NEXT FROM role_cursor INTO @rName;
END;
CLOSE role_cursor;
DEALLOCATE role_cursor;

-- 5.3 Test-Benutzer in ProjektDB entfernen
DECLARE @users TABLE (UserName SYSNAME);
INSERT INTO @users VALUES ('UserA'), ('User_ReadOnly'), ('User_DataEntry'), ('User_HR');

DECLARE @uName SYSNAME;
DECLARE user_cursor CURSOR FOR SELECT UserName FROM @users;
OPEN user_cursor;
FETCH NEXT FROM user_cursor INTO @uName;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF DATABASE_PRINCIPAL_ID(@uName) IS NOT NULL
    BEGIN
        EXEC('DROP USER [' + @uName + '];');
        PRINT '    -> DB-User ' + @uName + ' gelöscht.';
    END;
    FETCH NEXT FROM user_cursor INTO @uName;
END;
CLOSE user_cursor;
DEALLOCATE user_cursor;
GO

-- 5.4 Test-Logins auf Server-Ebene entfernen
USE master;
GO

DECLARE @logins TABLE (LoginName SYSNAME);
INSERT INTO @logins VALUES ('LoginA'), ('Login_ReadOnly'), ('Login_DataEntry'), ('Login_HR');

DECLARE @lName SYSNAME;
DECLARE login_cursor CURSOR FOR SELECT LoginName FROM @logins;
OPEN login_cursor;
FETCH NEXT FROM login_cursor INTO @lName;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @lName)
    BEGIN
        EXEC('DROP LOGIN [' + @lName + '];');
        PRINT '    -> Server-Login ' + @lName + ' gelöscht.';
    END;
    FETCH NEXT FROM login_cursor INTO @lName;
END;
CLOSE login_cursor;
DEALLOCATE login_cursor;
GO

PRINT '>>> Bereinigung erfolgreich abgeschlossen. Testumgebung ist sauber.';
GO
