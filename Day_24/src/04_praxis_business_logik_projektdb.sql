-- ============================================================================
-- SQL-Fundamentals: Day 24 - T-SQL Variablen & Kontrollstrukturen
-- Datei: 04_praxis_business_logik_projektdb.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 03.09.2026
-- Fokus: Praxis-Workshop – Prozedurale Business-Logik auf der ProjektDB
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- PRAXIS-WORKSHOP: 5 Reale Unternehmensszenarien
-- ----------------------------------------------------------------------------
-- Dieses Skript vereint alle gelernten Kernkonzepte:
-- 1. Variablen deklarieren (DECLARE) und initialisieren.
-- 2. Daten dynamisch aus Abfragen zuweisen (SELECT @var = col).
-- 3. Komplexe Kontrollstrukturen (IF...ELSE, BEGIN...END, ELSE IF, EXISTS).
-- 4. Dynamische, formatierte Konsolenberichte via PRINT.
-- ============================================================================


-- ============================================================================
-- SZENARIO 1: Projekt-Budget-Auditor & Ampelbewertung
-- ----------------------------------------------------------------------------
-- Aufgabe:
-- Ermittle für ein bestimmtes Projekt (Kürzel) das Budget, die Projektbezeichnung,
-- den Kunden sowie den prozentualen Anteil am gesamten Projektvolumen der Firma.
-- Verzweige nach Budgethöhe und gib einen formatierten Prüfbericht aus.
-- ============================================================================
PRINT '======================================================================';
PRINT '>>> SZENARIO 1: Projekt-Budget-Auditor';
PRINT '======================================================================';

DECLARE @suchKuerzel NVARCHAR(10) = 'AP'; -- Apollo-Projekt
DECLARE @pro_bezeichnung NVARCHAR(50);
DECLARE @pro_budget DECIMAL(12, 2);
DECLARE @kunde_name NVARCHAR(100);
DECLARE @gesamtVolumen DECIMAL(14, 2);
DECLARE @anteilProzent DECIMAL(5, 2);
DECLARE @ampelStatus NVARCHAR(20);

-- 1. Gesamtvolumen aller Projekte ermitteln
SELECT @gesamtVolumen = SUM(mittel) FROM dbo.Projekt;

-- 2. Projektdaten und Kundennamen per JOIN in Variablen zuweisen
SELECT @pro_bezeichnung = p.bezeichnung,
       @pro_budget = p.mittel,
       @kunde_name = k.firma
FROM dbo.Projekt AS p
INNER JOIN dbo.Kunde AS k ON p.kunde_id = k.id
WHERE p.kuerzel = @suchKuerzel;

-- 3. Verzweigung: Existiert das Projekt?
IF @pro_bezeichnung IS NULL
BEGIN
    PRINT '[FEHLER] Kein Projekt mit dem Kürzel "' + @suchKuerzel + '" gefunden!';
END
ELSE
BEGIN
    -- Anteil berechnen
    SET @anteilProzent = (@pro_budget / @gesamtVolumen) * 100.00;

    -- Ampelbewertung via ELSE IF Kaskade
    IF @pro_budget >= 100000.00
    BEGIN
        SET @ampelStatus = '🔴 HOCH (Flaggschiff)';
    END
    ELSE IF @pro_budget >= 50000.00
    BEGIN
        SET @ampelStatus = '🟡 MITTEL (Standard)';
    END
    ELSE
    BEGIN
        SET @ampelStatus = '🟢 NIEDRIG (Kompakt)';
    END;

    -- Formatierter Bericht per PRINT
    PRINT '------------------------------------------------------------------';
    PRINT '                 PROJEKT-AUDIT-BERICHT                            ';
    PRINT '------------------------------------------------------------------';
    PRINT CONCAT('Projekt:         ', @pro_bezeichnung, ' (', @suchKuerzel, ')');
    PRINT CONCAT('Auftraggeber:    ', @kunde_name);
    PRINT CONCAT('Projektbudget:   ', FORMAT(@pro_budget, 'N2', 'de-DE'), ' EUR');
    PRINT CONCAT('Firmen-Anteil:   ', CAST(@anteilProzent AS NVARCHAR(10)), ' % des Gesamtvolumens');
    PRINT CONCAT('Risiko-Einstufung: ', @ampelStatus);
    PRINT '------------------------------------------------------------------';
END;
GO


-- ============================================================================
-- SZENARIO 2: Mitarbeiter-Gehaltsbenchmark & Ungleichheits-Detektor
-- ----------------------------------------------------------------------------
-- Aufgabe:
-- Vergleiche das Gehalt eines Mitarbeiters mit dem Durchschnitt seiner Abteilung.
-- Liegt er mehr als 15% über dem Schnitt -> "Überdurchschnittlich",
-- liegt er im Korridor (±15%) -> "Marktgerecht",
-- liegt er mehr als 15% unter dem Schnitt -> "Anpassungsbedarf".
-- ============================================================================
PRINT '======================================================================';
PRINT '>>> SZENARIO 2: Mitarbeiter-Gehaltsbenchmark & HR-Check';
PRINT '======================================================================';

DECLARE @mit_id INT = 25348;
DECLARE @mit_vorname NVARCHAR(50);
DECLARE @mit_nachname NVARCHAR(50);
DECLARE @mit_abt_id INT;
DECLARE @mit_abt_name NVARCHAR(50);
DECLARE @mit_gehalt DECIMAL(10, 2);
DECLARE @abt_durchschnitt DECIMAL(10, 2);
DECLARE @differenz DECIMAL(10, 2);
DECLARE @differenzProzent DECIMAL(6, 2);

-- Mitarbeiter- und Abteilungsdaten abrufen
SELECT @mit_vorname = m.vorname,
       @mit_nachname = m.nachname,
       @mit_abt_id = m.abt_id,
       @mit_abt_name = a.bezeichnung,
       @mit_gehalt = g.gehalt
FROM dbo.Mitarbeiter AS m
INNER JOIN dbo.Abteilung AS a ON m.abt_id = a.id
INNER JOIN dbo.Gehalt AS g ON m.id = g.mit_id
WHERE m.id = @mit_id;

-- Abteilungsdurchschnitt berechnen
SELECT @abt_durchschnitt = AVG(g.gehalt)
FROM dbo.Mitarbeiter AS m
INNER JOIN dbo.Gehalt AS g ON m.id = g.mit_id
WHERE m.abt_id = @mit_abt_id;

IF @mit_vorname IS NOT NULL AND @mit_gehalt IS NOT NULL
BEGIN
    SET @differenz = @mit_gehalt - @abt_durchschnitt;
    SET @differenzProzent = (@differenz / @abt_durchschnitt) * 100.00;

    PRINT '------------------------------------------------------------------';
    PRINT '                 HR GEHALTSBENCHMARK-ANALYSE                      ';
    PRINT '------------------------------------------------------------------';
    PRINT CONCAT('Mitarbeiter:         ', @mit_vorname, ' ', @mit_nachname, ' (ID: ', @mit_id, ')');
    PRINT CONCAT('Abteilung:           ', @mit_abt_name, ' (Abt-ID: ', @mit_abt_id, ')');
    PRINT CONCAT('Aktuelles Gehalt:    ', FORMAT(@mit_gehalt, 'N2', 'de-DE'), ' EUR');
    PRINT CONCAT('Abteilungs-Schnitt:  ', FORMAT(@abt_durchschnitt, 'N2', 'de-DE'), ' EUR');
    PRINT CONCAT('Abweichung absolut:  ', FORMAT(@differenz, 'N2', 'de-DE'), ' EUR');
    PRINT CONCAT('Abweichung relativ:  ', CAST(@differenzProzent AS NVARCHAR(10)), ' %');
    PRINT '------------------------------------------------------------------';

    IF @differenzProzent > 15.00
    BEGIN
        PRINT '>>> HR-Befund: Spitzenverdiener (Überdurchschnittlich vergütet).';
        PRINT '    Empfehlung: Keine Gehaltserhöhung in aktueller Periode.';
    END
    ELSE IF @differenzProzent >= -15.00
    BEGIN
        PRINT '>>> HR-Befund: Marktgerechte Vergütung innerhalb der Bandbreite.';
        PRINT '    Empfehlung: Standardmäßige Inflationsanpassung ausreichend.';
    END
    ELSE
    BEGIN
        PRINT '>>> HR-Befund: Unterdurchschnittlich vergütet (Abweichung > -15%).';
        PRINT '    Empfehlung: DRINGEND Überprüfung auf Gehaltsanpassung erforderlich!';
    END;
END
ELSE
BEGIN
    PRINT '[WARNUNG] Mitarbeiter oder Gehaltseintrag nicht gefunden!';
END;
GO


-- ============================================================================
-- SZENARIO 3: Workload & Ressourcen-Monitor (Mitarbeiter-Auslastung)
-- ----------------------------------------------------------------------------
-- Aufgabe:
-- Prüfe anhand der Tabelle 'Arbeit', wie vielen Projekten ein Mitarbeiter
-- zugeordnet ist und ob er Leitungsverantwortung trägt.
-- ============================================================================
PRINT '======================================================================';
PRINT '>>> SZENARIO 3: Workload & Ressourcen-Auslastung in Arbeit';
PRINT '======================================================================';

DECLARE @pruefMitarbeiterId INT = 28559;
DECLARE @anzahlProjekte INT = 0;
DECLARE @hatLeitungsfunktion BIT = 0;
DECLARE @mitName NVARCHAR(100);

-- Namen ermitteln
SELECT @mitName = CONCAT(vorname, ' ', nachname)
FROM dbo.Mitarbeiter
WHERE id = @pruefMitarbeiterId;

-- Anzahl Projektzuweisungen und Leitungsfunktion zählen
SELECT @anzahlProjekte = COUNT(*),
       @hatLeitungsfunktion = MAX(CASE WHEN aufgabe LIKE '%leiter%' OR aufgabe LIKE '%Leiter%' THEN 1 ELSE 0 END)
FROM dbo.Arbeit
WHERE mit_id = @pruefMitarbeiterId;

PRINT CONCAT('Ressourcen-Prüfung für: ', @mitName, ' (ID: ', @pruefMitarbeiterId, ')');
PRINT CONCAT('Aktive Projekt-Einsätze: ', @anzahlProjekte);

IF @hatLeitungsfunktion = 1
BEGIN
    PRINT '⭐ Funktion: Mitarbeiter ist als PROJEKTLEITER eingesetzt!';
END
ELSE
BEGIN
    PRINT 'ℹ️ Funktion: Fachexperte / Teammitglied.';
END;

-- Verzweigung nach Auslastungsstufe
IF @anzahlProjekte = 0
BEGIN
    PRINT '⚠️ STATUS: Inaktiv / Nicht ausgelastet! Mitarbeiter hat aktuell kein Projekt.';
END
ELSE IF @anzahlProjekte BETWEEN 1 AND 2
BEGIN
    PRINT '✅ STATUS: Optimale Auslastung (Fokus auf Kernprojekten).';
END
ELSE
BEGIN
    PRINT '🔥 STATUS: Überlastungsgefahr! Mehr als 2 parallele Projekte (Multitasking-Risiko).';
END;
GO


-- ============================================================================
-- SZENARIO 4: Dynamische Vertriebsprovision & Bonusberechnung
-- ----------------------------------------------------------------------------
-- Aufgabe:
-- Berechne aus der Tabelle 'Umsatz' das Gesamtumsatzvolumen eines Mitarbeiters.
-- Wende eine gestaffelte Bonusregel an:
--   - Umsatz >= 100.000 € -> 12% Bonus
--   - Umsatz >= 50.000 €  -> 8% Bonus
--   - Umsatz >= 20.000 €  -> 4% Bonus
--   - darunter            -> Kein Bonus
-- ============================================================================
PRINT '======================================================================';
PRINT '>>> SZENARIO 4: Umsatzanalyse & Gestaffelte Bonusberechnung';
PRINT '======================================================================';

DECLARE @vertriebsId INT = 25348;
DECLARE @vertriebsName NVARCHAR(100);
DECLARE @summeUmsatz DECIMAL(12, 2) = 0.00;
DECLARE @bonusSatz DECIMAL(5, 2) = 0.00;
DECLARE @bonusBetrag DECIMAL(12, 2) = 0.00;

-- Name und Umsatzsumme ermitteln
SELECT @vertriebsName = CONCAT(vorname, ' ', nachname)
FROM dbo.Mitarbeiter
WHERE id = @vertriebsId;

SELECT @summeUmsatz = ISNULL(SUM(umsatz), 0.00)
FROM dbo.Umsatz
WHERE mit_id = @vertriebsId;

PRINT CONCAT('Vertriebsmitarbeiter: ', @vertriebsName, ' (ID: ', @vertriebsId, ')');
PRINT CONCAT('Erzielter Gesamtumsatz: ', FORMAT(@summeUmsatz, 'N2', 'de-DE'), ' EUR');

-- Gestaffelte Bonus-Kaskade
IF @summeUmsatz >= 100000.00
BEGIN
    SET @bonusSatz = 12.00;
END
ELSE IF @summeUmsatz >= 50000.00
BEGIN
    SET @bonusSatz = 8.00;
END
ELSE IF @summeUmsatz >= 20000.00
BEGIN
    SET @bonusSatz = 4.00;
END
ELSE
BEGIN
    SET @bonusSatz = 0.00;
END;

IF @bonusSatz > 0.00
BEGIN
    SET @bonusBetrag = @summeUmsatz * (@bonusSatz / 100.00);
    PRINT CONCAT('🎉 Glückwunsch! Bonusstufe erreicht: ', @bonusSatz, ' %');
    PRINT CONCAT('💰 Auszuzahlender Bonusbetrag:     ', FORMAT(@bonusBetrag, 'N2', 'de-DE'), ' EUR');
END
ELSE
BEGIN
    PRINT 'ℹ️ Mindestumsatz für Bonusausschüttung (20.000 EUR) wurde nicht erreicht.';
END;
GO


-- ============================================================================
-- SZENARIO 5: Idempotenter DML-Guard (Sichere Datenvalidierung)
-- ----------------------------------------------------------------------------
-- Aufgabe:
-- Validiere Eingabewerte vor einer Datenbankoperation:
-- 1. Prüfe, ob die angegebene Kunden-ID überhaupt existiert (Fremdschlüssel-Schutz).
-- 2. Prüfe, ob das Projekt-Kürzel bereits vergeben ist (Unique-Schutz).
-- 3. Nur wenn alle Vorprüfungen bestanden sind, wird die Anlage simuliert.
-- ============================================================================
PRINT '======================================================================';
PRINT '>>> SZENARIO 5: Idempotente Vorprüfungen vor DML-Operation';
PRINT '======================================================================';

DECLARE @neuKuerzel NVARCHAR(10) = 'AI';
DECLARE @neuBezeichnung NVARCHAR(50) = 'Künstliche Intelligenz Platform';
DECLARE @neuBudget DECIMAL(12, 2) = 125000.00;
DECLARE @neuKundeId INT = 1;

PRINT 'Validierung für Neuanlage: Projekt [' + @neuKuerzel + '] "' + @neuBezeichnung + '"...';

-- Vorprüfung 1: Existiert der Kunde?
IF NOT EXISTS (SELECT 1 FROM dbo.Kunde WHERE id = @neuKundeId)
BEGIN
    PRINT '[ABBRUCH] Fehler: Der angegebene Kunde mit ID ' + CAST(@neuKundeId AS NVARCHAR(10)) + ' existiert nicht!';
END
-- Vorprüfung 2: Ist das Kürzel schon vergeben?
ELSE IF EXISTS (SELECT 1 FROM dbo.Projekt WHERE kuerzel = @neuKuerzel)
BEGIN
    PRINT '[ABBRUCH] Fehler: Ein Projekt mit dem Kürzel "' + @neuKuerzel + '" existiert bereits!';
END
-- Vorprüfung 3: Ist das Budget positiv?
ELSE IF @neuBudget <= 0.00
BEGIN
    PRINT '[ABBRUCH] Fehler: Das Projektbudget muss größer als 0 sein!';
END
ELSE
BEGIN
    PRINT '>>> VALIDIERUNG ERFOLGREICH: Alle Integritäts- und Business-Regeln erfüllt.';
    PRINT '    -> Kunde verifiziert: OK';
    PRINT '    -> Kürzel eindeutig: OK';
    PRINT '    -> Budget plausibel: OK (' + FORMAT(@neuBudget, 'N2', 'de-DE') + ' EUR)';
    PRINT '    -> INSERT in dbo.Projekt kann sicher ausgeführt werden.';
END;
GO
