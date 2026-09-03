-- ============================================================================
-- SQL-Fundamentals: Day 24 - T-SQL Variablen & Kontrollstrukturen
-- Datei: 03_kontrollstrukturen_if_else_begin_end.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 03.09.2026
-- Fokus: Ablaufsteuerung (Control-of-Flow), IF...ELSE, BEGIN...END, EXISTS & Logik
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- THEORIE: Verzweigungen & Kontrollstrukturen in T-SQL
-- ----------------------------------------------------------------------------
-- 1. IF...ELSE Syntax:
--    IF <boolesche_bedingung>
--    BEGIN
--        -- Anweisung 1;
--        -- Anweisung 2;
--    END
--    ELSE
--    BEGIN
--        -- Alternative Anweisungen;
--    END
--
-- 2. WARUM BEGIN...END UNVERZICHTBAR IST:
--    - Ohne BEGIN...END führt SQL Server im IF- oder ELSE-Zweig NUR DIE ALLERERSTE
--      nachfolgende Anweisung bedingt aus!
--    - Jede zweite Anweisung wird IMMER ausgeführt, unabhängig davon, ob die
--      Bedingung wahr oder falsch war!
--    - Best Practice: IMMER BEGIN...END setzen – auch bei Einzeilern!
--
-- 3. Mehrfachverzweigung (ELSE IF):
--    - Ermöglicht kaskadierende Fallunterscheidungen ohne tiefe Verschachtelung.
--
-- 4. Dreiwertige Logik bei Bedingungen:
--    - Eine Bedingung in T-SQL kann TRUE, FALSE oder UNKNOWN (bei NULL) sein.
--    - Nur wenn das Ergebnis strikt TRUE ist, wird der IF-Zweig betreten.
--    - Ein UNKNOWN (z. B. bei @x = NULL) springt immer in den ELSE-Zweig!
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. Grundlegende IF...ELSE Verzweigung mit Variablen
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 1. Grundlegende IF...ELSE Verzweigung';
PRINT '======================================================================';

DECLARE @testGehalt DECIMAL(10, 2) = 4500.00;
DECLARE @schwellenwert DECIMAL(10, 2) = 4000.00;

IF @testGehalt >= @schwellenwert
BEGIN
    PRINT 'Status: Gehalt liegt über oder gleich dem Schwellenwert.';
    PRINT '  Aktueller Wert: ' + CAST(@testGehalt AS NVARCHAR(20)) + ' EUR';
    PRINT '  Schwelle:       ' + CAST(@schwellenwert AS NVARCHAR(20)) + ' EUR';
END
ELSE
BEGIN
    PRINT 'Status: Gehalt liegt unter dem Schwellenwert.';
    PRINT '  Differenz: ' + CAST((@schwellenwert - @testGehalt) AS NVARCHAR(20)) + ' EUR';
END;
GO


-- ----------------------------------------------------------------------------
-- 2. Gefahrenzone: IF OHNE BEGIN...END (Die klassische Entwicklerfalle)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 2. Demonstration: Warum BEGIN...END zwingend notwendig ist';
PRINT '======================================================================';

DECLARE @istAdmin BIT = 0; -- Benutzer ist KEIN Admin!

PRINT '--- FALSCHE Variante (OHNE BEGIN...END): ---';
IF @istAdmin = 1
    PRINT '  [Admin-Block] Willkommen, Administrator!';
    PRINT '  [KRITISCHER FEHLER] Ich werde IMMER ausgeführt, auch für Nicht-Admins!';

PRINT '--- KORREKTE Variante (MIT BEGIN...END): ---';
IF @istAdmin = 1
BEGIN
    PRINT '  [Admin-Block] Willkommen, Administrator!';
    PRINT '  [Admin-Block] Voller Zugriff gewährt.';
END
ELSE
BEGIN
    PRINT '  [Standard-Block] Zugriff verweigert: Sie besitzen keine Administratorrechte.';
END;
GO


-- ----------------------------------------------------------------------------
-- 3. Mehrfachverzweigung mit ELSE IF (Stufenlogik / Klassifizierung)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 3. Mehrfachverzweigung mit ELSE IF (Projekt-Budget-Rating)';
PRINT '======================================================================';

DECLARE @pro_id INT = 1; -- Apollo-Projekt
DECLARE @budget DECIMAL(12, 2);
DECLARE @projektName NVARCHAR(50);
DECLARE @kategorie NVARCHAR(30);

-- Budget und Projektname aus ProjektDB abrufen
SELECT @projektName = bezeichnung,
       @budget = mittel
FROM dbo.Projekt
WHERE id = @pro_id;

-- Klassifizierung über ELSE IF Kaskade
IF @budget >= 100000.00
BEGIN
    SET @kategorie = 'Platin-Projekt (Strategisch)';
    PRINT '>>> Einstufung: ' + @kategorie;
    PRINT '    Projekt: ' + @projektName + ' (Budget: ' + CAST(@budget AS NVARCHAR(20)) + ' EUR)';
    PRINT '    Maßnahme: Monatliches Lenkungskreis-Reporting erforderlich.';
END
ELSE IF @budget >= 50000.00
BEGIN
    SET @kategorie = 'Gold-Projekt (Standard)';
    PRINT '>>> Einstufung: ' + @kategorie;
    PRINT '    Projekt: ' + @projektName + ' (Budget: ' + CAST(@budget AS NVARCHAR(20)) + ' EUR)';
    PRINT '    Maßnahme: Regelmäßiges Sprint-Controlling.';
END
ELSE
BEGIN
    SET @kategorie = 'Silber-Projekt (Kompakt)';
    PRINT '>>> Einstufung: ' + @kategorie;
    PRINT '    Projekt: ' + @projektName + ' (Budget: ' + CAST(@budget AS NVARCHAR(20)) + ' EUR)';
    PRINT '    Maßnahme: Schlankes Controlling ohne Sonderauflagen.';
END;
GO


-- ----------------------------------------------------------------------------
-- 4. Verschachtelte Bedingungen (Nested IF)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 4. Verschachtelte Bedingungen (Nested IF)';
PRINT '======================================================================';

DECLARE @mitarbeiterId INT = 25348;
DECLARE @mitarbeiterVorhanden BIT = 0;
DECLARE @hatGehalt BIT = 0;
DECLARE @aktuellesGehalt DECIMAL(10, 2);

-- Stufe 1: Prüfen, ob Mitarbeiter in der Datenbank existiert
IF EXISTS (SELECT 1 FROM dbo.Mitarbeiter WHERE id = @mitarbeiterId)
BEGIN
    SET @mitarbeiterVorhanden = 1;
    PRINT '1. Stufe: Mitarbeiter mit ID ' + CAST(@mitarbeiterId AS NVARCHAR(10)) + ' existiert.';

    -- Stufe 2: Verschachtelte Prüfung auf Gehaltseintrag
    IF EXISTS (SELECT 1 FROM dbo.Gehalt WHERE mit_id = @mitarbeiterId)
    BEGIN
        SET @hatGehalt = 1;
        SELECT @aktuellesGehalt = gehalt FROM dbo.Gehalt WHERE mit_id = @mitarbeiterId;
        PRINT '  2. Stufe: Gehaltseintrag gefunden: ' + CAST(@aktuellesGehalt AS NVARCHAR(20)) + ' EUR';

        -- Stufe 3: Verschachtelte Plausibilitätsprüfung
        IF @aktuellesGehalt <= 0
        BEGIN
            PRINT '    [WARNUNG] Gehalt ist 0 oder negativ! Bitte korrigieren!';
        END
        ELSE
        BEGIN
            PRINT '    3. Stufe: Gehaltsbetrag ist plausibel und gültig.';
        END;
    END
    ELSE
    BEGIN
        PRINT '  [HINWEIS] Mitarbeiter besitzt noch keinen Gehaltsdatensatz!';
    END;
END
ELSE
BEGIN
    PRINT 'Fehler: Mitarbeiter existiert nicht in der ProjektDB.';
END;
GO


-- ----------------------------------------------------------------------------
-- 5. Komplexe Bedingungen (AND, OR, NOT & Klammerung)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 5. Komplexe logische Verknüpfungen';
PRINT '======================================================================';

DECLARE @abtId INT = 1;
DECLARE @mitarbeiterOrt NVARCHAR(50) = 'München';
DECLARE @trefferAnzahl INT;

SELECT @trefferAnzahl = COUNT(*)
FROM dbo.Mitarbeiter
WHERE abt_id = @abtId AND ort = @mitarbeiterOrt;

-- Prüfung mit mehreren Kriterien
IF (@trefferAnzahl > 0 AND @mitarbeiterOrt = 'München') OR (@abtId = 1 AND @trefferAnzahl >= 3)
BEGIN
    PRINT 'Kriterium erfüllt: ' + CAST(@trefferAnzahl AS NVARCHAR(10)) + 
          ' Mitarbeiter in Abteilung ' + CAST(@abtId AS NVARCHAR(10)) + 
          ' am Standort ' + @mitarbeiterOrt + ' gefunden.';
END
ELSE
BEGIN
    PRINT 'Keine Übereinstimmung für die geforderte Kombination.';
END;
GO


-- ----------------------------------------------------------------------------
-- 6. Bedingte Logik mit IF EXISTS (...) & IF NOT EXISTS (...)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 6. Bedingte Prüfung mit IF EXISTS / IF NOT EXISTS';
PRINT '======================================================================';

-- Prüfung, ob Kunden ohne Projekte existieren
IF EXISTS (
    SELECT 1 
    FROM dbo.Kunde AS k
    LEFT JOIN dbo.Projekt AS p ON k.id = p.kunde_id
    WHERE p.id IS NULL
)
BEGIN
    PRINT '>>> Analyse: Es existieren Kunden ohne aktive Projektzuordnung!';
END
ELSE
BEGIN
    PRINT '>>> Analyse: Alle Kunden besitzen mindestens ein zugeordnetes Projekt.';
END;

-- Prüfung auf Abteilungskürzel vor Neuanlage (Idempotenz)
DECLARE @gesuchtesKuerzel NVARCHAR(5) = 'IT';

IF NOT EXISTS (SELECT 1 FROM dbo.Abteilung WHERE kuerzel = @gesuchtesKuerzel)
BEGIN
    PRINT 'Freigabe: Das Abteilungskürzel "' + @gesuchtesKuerzel + '" ist noch frei und kann angelegt werden.';
END
ELSE
BEGIN
    PRINT 'Gesperrt: Das Abteilungskürzel "' + @gesuchtesKuerzel + '" ist bereits vergeben!';
END;
GO
