-- ============================================================================
-- SQL-Fundamentals: Day 20 - T-SQL Funktionen & CASE-Ausdrücke
-- Datei: 03_funktionen_kompendium_vertiefung.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 28.08.2026
-- Single Source of Truth (SoT): ProjektDB
-- ============================================================================

USE ProjektDB;
GO

SET LANGUAGE german;
GO

-- ============================================================================
-- 1. LOGISCHE FUNKTIONEN & FALLUNTERSCHEIDUNGEN
-- ============================================================================

PRINT '--- 1. Logische Funktionen (IIF, ISNULL, COALESCE, CASE) ---';

-- 1.1 IIF (Ternärer Operator)
SELECT id,
       nachname,
       abt_id,
       IIF(abt_id = 4, 'Einkäufer', 'Anderer Bereich') AS abteilungs_status
FROM Mitarbeiter;

-- 1.2 ISNULL vs. COALESCE (NULL-Ersetzung & Typinferenz)
SELECT id,
       nachname,
       ISNULL(ort, 'Kein Wohnort erfasst') AS ort_isnull,
       COALESCE(ort, 'Standort unbekannt') AS ort_coalesce
FROM Mitarbeiter;

-- 1.3 Einfacher CASE (Simple CASE)
SELECT id,
       kuerzel,
       bezeichnung,
       CASE kuerzel
           WHEN 'BE' THEN 'Strategische Beratung'
           WHEN 'DI' THEN 'Technische Diagnose'
           WHEN 'FR' THEN 'Qualitätsfreigabe'
           WHEN 'EK' THEN 'Beschaffungsmanagement'
           WHEN 'VK' THEN 'Vertrieb & Distribution'
           ELSE 'Unbekannte Sparte'
       END AS funktions_cluster
FROM Abteilung;

-- 1.4 Komplexer / Durchsuchter CASE (Searched CASE mit dynamischen Bedingungen)
SELECT m.nachname,
       g.gehalt,
       CASE
           WHEN g.gehalt >= 5000.00 THEN 'Top-Verdiener'
           WHEN g.gehalt >= 3500.00 THEN 'Mittleres Gehaltsband'
           ELSE 'Einstiegsgehalt'
       END AS gehalts_segment
FROM Mitarbeiter AS m
INNER JOIN Gehalt AS g ON m.id = g.mit_id;
GO


-- ============================================================================
-- 2. DATUMS- & UHRZEIT-FUNKTIONEN
-- ============================================================================

PRINT '--- 2. Datums- und Uhrzeit-Funktionen ---';

-- 2.1 Zeitstempel: GETDATE (datetime) vs. SYSDATETIME (datetime2)
SELECT GETDATE()     AS aktueller_zeitstempel_datetime,
       SYSDATETIME() AS hochpraeziser_zeitstempel_datetime2;

-- 2.2 Basis-Extraktion: DAY, MONTH, YEAR
SELECT einst_dat,
       DAY(einst_dat)   AS eintritts_tag,
       MONTH(einst_dat) AS eintritts_monat,
       YEAR(einst_dat)  AS eintritts_jahr
FROM Arbeit;

-- 2.3 Erweiterte Extraktion: DATEPART & DATENAME
SELECT einst_dat,
       DATEPART(quarter, einst_dat)   AS quartal_nummer,
       DATEPART(dayofyear, einst_dat) AS tag_des_jahres,
       DATEPART(iso_week, einst_dat)  AS iso_kalenderwoche,
       DATENAME(weekday, einst_dat)   AS wochentag_text,
       DATENAME(month, einst_dat)     AS monats_name
FROM Arbeit;

-- 2.4 Datums-Arithmetik: DATEADD & DATEDIFF
SELECT einst_dat,
       DATEADD(month, 6, einst_dat)              AS probezeit_ende,
       DATEADD(year, 1, einst_dat)               AS jubiläum_jahr_1,
       DATEDIFF(day, einst_dat, GETDATE())       AS betriebszugehoerigkeit_tage,
       DATEDIFF(month, einst_dat, GETDATE())     AS betriebszugehoerigkeit_monate
FROM Arbeit;

-- 2.5 Datums-Konstruktion: DATEFROMPARTS, TIMEFROMPARTS, DATETIME2FROMPARTS
SELECT DATEFROMPARTS(2026, 8, 28)                   AS konstruiertes_datum,
       TIMEFROMPARTS(14, 30, 0, 0, 0)               AS konstruierte_uhrzeit,
       DATETIME2FROMPARTS(2026, 8, 28, 14, 30, 0, 0, 0) AS konstruiertes_datetime2;

-- 2.6 Monatsende: EOMONTH mit Offset
SELECT GETDATE()                             AS heute,
       EOMONTH(GETDATE())                    AS aktuelles_monatsende,
       EOMONTH(GETDATE(), 1)                 AS naechstes_monatsende,
       EOMONTH(GETDATE(), -1)                AS vorheriges_monatsende,
       EOMONTH('2024-02-15')                 AS schaltjahr_februar_ende;
GO


-- ============================================================================
-- 3. STRING- & TEXT-FUNKTIONEN
-- ============================================================================

PRINT '--- 3. String- und Text-Funktionen ---';

-- 3.1 Verkettung: CONCAT vs. CONCAT_WS
SELECT id,
       CONCAT(vorname, ' ', nachname)                  AS voller_name_concat,
       CONCAT_WS(' | ', id, vorname, nachname, ort)   AS datensatz_pipeline
FROM Mitarbeiter;

-- 3.2 Längenmessung: LEN vs. DATALENGTH
SELECT nachname,
       LEN(nachname)                 AS zeichenanzahl,
       DATALENGTH(nachname)          AS speicherbytes_nvarchar,
       LEN('SQL Server   ')          AS len_mit_spaces,       -- ignoriert trailing spaces (10)
       DATALENGTH('SQL Server   ')   AS datalength_mit_spaces -- zählt jedes Zeichen (13 Bytes bei VARCHAR)
FROM Mitarbeiter;

-- 3.3 Bereinigung & Fallumwandlung: TRIM, LTRIM, RTRIM, UPPER, LOWER
SELECT '   Vorlauf und Nachlauf   '                     AS rohdaten,
       LTRIM('   Vorlauf und Nachlauf   ')              AS links_bereinigt,
       RTRIM('   Vorlauf und Nachlauf   ')              AS rechts_bereinigt,
       TRIM('   Vorlauf und Nachlauf   ')               AS beidseitig_bereinigt,
       UPPER(nachname)                                  AS nachname_gross,
       LOWER(vorname)                                   AS vorname_klein
FROM Mitarbeiter;

-- 3.4 Substrings & Zerlegung: LEFT, RIGHT, SUBSTRING
SELECT vorname,
       LEFT(vorname, 3)        AS erste_3_zeichen,
       RIGHT(vorname, 2)       AS letzte_2_zeichen,
       SUBSTRING(vorname, 2, 4) AS zeichen_2_bis_5
FROM Mitarbeiter;

-- 3.5 Positionssuche & Mustererkennung: CHARINDEX vs. PATINDEX
SELECT firma,
       CHARINDEX('GmbH', firma)         AS pos_gmbh,
       PATINDEX('%[0-9]%', firma)       AS pos_erste_ziffer,
       PATINDEX('%[%]%', firma)         AS pos_prozentzeichen
FROM Kunde;

-- 3.6 String-Transformation & Validierung: REPLACE, REVERSE, SPACE, ISNUMERIC
SELECT bezeichnung,
       REPLACE(bezeichnung, 'a', '@')   AS repliziert_a,
       REVERSE(bezeichnung)             AS rueckwaerts,
       CONCAT('Start', SPACE(5), 'Ziel') AS mit_leerzeichen,
       ISNUMERIC('123.45')              AS ist_numerisch_float,
       ISNUMERIC('Text')                AS ist_numerisch_text
FROM Projekt;
GO


-- ============================================================================
-- 4. MATHEMATISCHE FUNKTIONEN
-- ============================================================================

PRINT '--- 4. Mathematische Funktionen (ABS, RAND, ROUND, POWER) ---';

-- 4.1 ABS: Absoluter Betrag
SELECT ABS(-42.50) AS abs_negativ,
       ABS(42.50)  AS abs_positiv;

-- 4.2 RAND: Pseudozufallszahlen (0 <= r < 1)
SELECT RAND()       AS nicht_deterministische_zufallszahl,
       RAND(42)     AS deterministische_zufallszahl_mit_seed;

-- 4.3 ROUND: Kaufmännisches Runden vs. Abschneiden (Truncation)
SELECT mittel,
       ROUND(mittel, -3)    AS gerundet_auf_tausender,
       ROUND(123.456, 2)    AS gerundet_2_dezimalen,
       ROUND(123.456, 2, 1) AS abgeschnitten_2_dezimalen -- 3. Parameter != 0 schneidet ab
FROM Projekt;

-- 4.4 POWER: Potenzen
SELECT POWER(2, 3)  AS zwei_hoch_drei,
       POWER(10, 4) AS zehn_hoch_vier;
GO


-- ============================================================================
-- 5. TYPKONVERTIERUNG & FORMATIERUNG
-- ============================================================================

PRINT '--- 5. Typkonvertierung & Formatierung (CAST, CONVERT, FORMAT) ---';

-- 5.1 CAST vs. TRY_CAST
SELECT CAST('2026-08-28' AS DATE)       AS valid_cast_date,
       CAST(123.45 AS INT)              AS valid_cast_int,
       TRY_CAST('KeinDatum' AS DATE)    AS safe_cast_null,       -- liefert NULL statt Fehler
       TRY_CAST('12345' AS INT)         AS safe_cast_number;

-- 5.2 CONVERT vs. TRY_CONVERT mit Datums-Styles
SELECT GETDATE()                                        AS raw_datetime,
       CONVERT(VARCHAR(10), GETDATE(), 104)             AS german_date_dd_mm_yyyy,    -- 104: TT.MM.JJJJ
       CONVERT(VARCHAR(19), GETDATE(), 120)             AS odbc_canonical_yyyy_mm_dd,  -- 120: JJJJ-MM-TT HH:MM:SS
       CONVERT(VARCHAR(8),  GETDATE(), 112)             AS iso_date_yyyymmdd,          -- 112: JJJJMMTT
       TRY_CONVERT(DATETIME, '31.02.2026', 104)        AS invalid_date_returns_null;

-- 5.3 FORMAT: Flexible .NET-Formatierung mit Kulturen
SELECT g.gehalt,
       FORMAT(g.gehalt, 'C', 'de-DE')                   AS gehalt_euro_deutsch,        -- z.B. 3.000,00 €
       FORMAT(g.gehalt, 'C', 'en-US')                   AS gehalt_usd_amerikanisch,    -- z.B. $3,000.00
       FORMAT(g.gehalt, '#,##0.00 EUR')                 AS gehalt_custom_maske,
       FORMAT(GETDATE(), 'dddd, dd. MMMM yyyy HH:mm', 'de-DE') AS langtext_datum_uhrzeit
FROM Gehalt AS g;
GO
