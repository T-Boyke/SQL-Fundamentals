-- ============================================================================
-- 📅 Day_15: JOINS & Tabellenverknüpfungen (DQL Masterclass)
-- Datenbank: ProjektDB (MS SQL Server)
-- Autor: Tobias Boyke
-- Dozent: Tom S.
-- Datum: 21.08.2026
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- 📝 TEIL 1: CROSS JOIN (Kartesisches Produkt / Kreuzprodukt / "Orgien-JOIN")
-- ============================================================================
-- Kombiniert jede Zeile der Tabelle A mit jeder Zeile der Tabelle B.
-- Zeilenanzahl = Zeilen(A) * Zeilen(B)  (z. B. 15 Mitarbeiter * 5 Abteilungen = 75 Zeilen)

-- 1.1 SQL-89 Syntax (Impliziter Join über Komma-Trennung ohne WHERE)
SELECT m.nachname, a.bezeichnung
FROM Mitarbeiter AS m, Abteilung AS a;

-- 1.2 SQL-92 Syntax (Expliziter CROSS JOIN - Empfohlener Standard)
SELECT m.nachname, a.bezeichnung
FROM Mitarbeiter AS m
CROSS JOIN Abteilung AS a;

-- 1.3 Praktischer Anwendungsfall: Erzeugung aller möglichen Kombinationen
-- z. B. Matrix aller Kunden mit allen Projekten zur Vertriebsplanung:
SELECT k.firma, p.bezeichnung AS projekt
FROM Kunde AS k
CROSS JOIN Projekt AS p;

GO

-- ============================================================================
-- 📝 TEIL 2: INNER JOIN (Gleichheitsverbund / Schnittmenge)
-- ============================================================================
-- Gibt nur Datensätze zurück, die in BEIDEN Tabellen die Join-Bedingung erfüllen.

-- 2.1 Vergleich: SQL-89 vs. SQL-92 Syntax
-- Veraltete SQL-89 Syntax (Verknüpfung im WHERE):
SELECT m.vorname, m.nachname, a.bezeichnung
FROM Mitarbeiter AS m, Abteilung AS a
WHERE m.abt_id = a.id;

-- Moderne SQL-92 Syntax (Klare Trennung: Verknüpfung im ON, Filter im WHERE):
SELECT m.vorname, m.nachname, a.bezeichnung
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id = a.id;

-- 2.2 Multi-Table INNER JOIN über 4 Tabellen:
-- Mitarbeiter -> Abteilung -> Gehalt -> Umsatz
SELECT m.id,
       m.nachname,
       m.vorname,
       a.bezeichnung AS abteilung,
       g.gehalt,
       u.datum AS umsatz_datum,
       u.umsatz
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id = a.id
INNER JOIN Gehalt AS g ON m.id = g.mit_id
INNER JOIN Umsatz AS u ON m.id = u.mit_id;

-- 2.3 Aggregationen mit JOIN & STRING_AGG:
-- Zeige jeden Mitarbeiter und alle seine Aufgaben als kommagetrennte Liste
SELECT m.id,
       m.vorname,
       m.nachname,
       STRING_AGG(a.aufgabe, ', ') AS aufgaben
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS a ON m.id = a.mit_id
GROUP BY m.id, m.vorname, m.nachname;

-- 2.4 Multi-Table Join: Wer arbeitet in welchem Projekt für welchen Kunden?
SELECT m.nachname AS mitarbeiter,
       p.bezeichnung AS projekt,
       k.firma AS kunde,
       arb.aufgabe
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS arb ON m.id = arb.mit_id
INNER JOIN Projekt AS p ON arb.pro_id = p.id
INNER JOIN Kunde AS k ON p.kunde_id = k.id;

GO

-- ============================================================================
-- 📝 TEIL 3: OUTER JOINS (LEFT, RIGHT, FULL OUTER JOIN)
-- ============================================================================

-- 3.1 LEFT OUTER JOIN: Alle Zeilen der linken Tabelle behalten
-- Zeige ALLE Mitarbeiter, auch wenn sie keiner Abteilung zugeordnet sind (abt_id IS NULL)
SELECT m.id, m.vorname, m.nachname, a.bezeichnung AS abteilung
FROM Mitarbeiter AS m
LEFT OUTER JOIN Abteilung AS a ON m.abt_id = a.id;

-- 3.2 RIGHT OUTER JOIN: Alle Zeilen der rechten Tabelle behalten
-- Zeige ALLE Abteilungen, auch wenn ihnen aktuell kein Mitarbeiter zugeordnet ist
SELECT a.id, a.bezeichnung, m.nachname AS mitarbeiter
FROM Mitarbeiter AS m
RIGHT OUTER JOIN Abteilung AS a ON m.abt_id = a.id; -- noqa: CV08

-- 3.3 FULL OUTER JOIN: Alle Zeilen beider Tabellen (Vollständige Vereinigung)
SELECT m.nachname, a.bezeichnung
FROM Mitarbeiter AS m
FULL OUTER JOIN Abteilung AS a ON m.abt_id = a.id;

-- 3.4 Anti-Join (Verwaiste Datensätze / Mengen-Ausschluss):
-- Finde Abteilungen, in denen KEIN einziger Mitarbeiter arbeitet:
SELECT a.id, a.bezeichnung, a.ort
FROM Abteilung AS a
LEFT JOIN Mitarbeiter AS m ON a.id = m.abt_id
WHERE m.id IS NULL;

-- Finde Kunden, die noch KEIN Projekt beauftragt haben:
SELECT k.id, k.firma, k.ort
FROM Kunde AS k
LEFT JOIN Projekt AS p ON k.id = p.kunde_id
WHERE p.id IS NULL;

GO

-- ============================================================================
-- 📝 TEIL 4: SELF JOIN (Selbstbeziehung / Rekursive Hierarchie)
-- ============================================================================

-- 4.1 Mitarbeiter und ihr jeweiliger Vorgesetzter (INNER JOIN)
-- Mitarbeiter ohne Vorgesetzten (Geschäftsführung mit chef_id IS NULL) fallen hier heraus:
SELECT m.id AS mit_id,
       CONCAT(m.vorname, ' ', m.nachname) AS mitarbeiter,
       m.chef_id,
       CONCAT(c.vorname, ' ', c.nachname) AS vorgesetzter
FROM Mitarbeiter AS m
INNER JOIN Mitarbeiter AS c ON m.chef_id = c.id;

-- 4.2 Vollständige Mitarbeiterliste inkl. Chefetage mit LEFT JOIN
SELECT m.id AS mit_id,
       CONCAT(m.vorname, ' ', m.nachname) AS mitarbeiter,
       ISNULL(CONCAT(c.vorname, ' ', c.nachname), '-> Geschäftsführung (Oberste Ebene)') AS vorgesetzter
FROM Mitarbeiter AS m
LEFT JOIN Mitarbeiter AS c ON m.chef_id = c.id;

GO

-- ============================================================================
-- 📂 TEIL 5: AUFGABENREIHE PROJEKTDB 06 - INNER JOIN 1 (Aufgaben 6.1 – 6.8)
-- ============================================================================

-- Aufgabe 6.1:
-- Schreiben Sie eine Abfrage, die alle Mitarbeiter aus der Abteilung 4 ausgibt.
-- Geben Sie die Felder vorname, nachname und Abteilungsname aus.
SELECT m.vorname,
       m.nachname,
       a.bezeichnung
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id = a.id
WHERE a.id = 4;

-- Aufgabe 6.2:
-- Schreiben Sie eine Abfrage, die alle Projekte mit den zugehörigen Projektleitern ausgibt.
-- Geben Sie alle Daten aus der Projekt-Tabelle und zusätzlich Id und Einstell-Datum 
-- aus der Arbeit-Tabelle aus. Sortieren Sie das Ergebnis nach der Projekt-ID.
SELECT p.id,
       p.kuerzel,
       p.bezeichnung,
       p.mittel,
       p.kunde_id,
       a.mit_id,
       a.einst_dat
FROM Projekt AS p
INNER JOIN Arbeit AS a ON p.id = a.pro_id
WHERE a.aufgabe = 'Projektleiter'
ORDER BY p.id ASC;

-- Aufgabe 6.3:
-- Verändern Sie die Abfrage aus Aufgabe 6.2, indem Sie statt der Mitarbeiter-Id 
-- den Nachnamen des Mitarbeiters in das Ergebnis einbauen.
SELECT p.id,
       p.kuerzel,
       p.bezeichnung,
       p.mittel,
       p.kunde_id,
       m.nachname,
       a.einst_dat
FROM Projekt AS p
INNER JOIN Arbeit AS a ON p.id = a.pro_id
INNER JOIN Mitarbeiter AS m ON a.mit_id = m.id
WHERE a.aufgabe = 'Projektleiter'
ORDER BY p.id ASC;

-- Aufgabe 6.4:
-- Erweitern Sie die Abfrage aus Aufgabe 6.3, indem Sie zusätzlich die Bezeichnung 
-- der Abteilung in das Ergebnis einbauen.
SELECT p.id,
       p.kuerzel,
       p.bezeichnung AS pro_bezeichnung,
       p.mittel,
       p.kunde_id,
       m.nachname,
       a.einst_dat,
       abt.bezeichnung AS abt_bezeichnung
FROM Projekt AS p
INNER JOIN Arbeit AS a ON p.id = a.pro_id
INNER JOIN Mitarbeiter AS m ON a.mit_id = m.id
INNER JOIN Abteilung AS abt ON m.abt_id = abt.id
WHERE a.aufgabe = 'Projektleiter'
ORDER BY p.id ASC;

-- Aufgabe 6.5:
-- Erstellen Sie eine Abfrage, die die Mitarbeiter mit allen zusätzlichen Informationen 
-- zu Abteilung, Gehalt, Arbeit und Projekt ausgibt. Geben Sie dabei keine Spalten doppelt aus.
SELECT m.id,
       m.nachname,
       m.vorname,
       m.abt_id,
       m.ort,
       m.chef_id,
       abt.kuerzel,
       abt.bezeichnung AS abt_bezeichnung,
       abt.ort AS abt_ort,
       g.gehalt,
       arb.aufgabe,
       arb.einst_dat,
       p.id AS pro_id,
       p.bezeichnung AS pro_bezeichnung,
       p.kunde_id
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS abt ON m.abt_id = abt.id
INNER JOIN Gehalt AS g ON m.id = g.mit_id
INNER JOIN Arbeit AS arb ON m.id = arb.mit_id
INNER JOIN Projekt AS p ON arb.pro_id = p.id;

-- Aufgabe 6.6:
-- Geben Sie für die Projekte die mit "A" beginnen die geforderten Informationen aus. 
-- Sortieren Sie die Ausgabe nach dem Projektnamen aufsteigend und der Mitarbeiter-Id absteigend.
SELECT p.bezeichnung,
       k.firma,
       arb.mit_id,
       arb.aufgabe
FROM Projekt AS p
INNER JOIN Kunde AS k ON p.kunde_id = k.id
INNER JOIN Arbeit AS arb ON p.id = arb.pro_id
WHERE p.bezeichnung LIKE 'A%'
ORDER BY p.bezeichnung ASC, arb.mit_id DESC;

-- Aufgabe 6.7:
-- Finden Sie Namen und Vornamen aller Mitarbeiter, die im Projekt Merkur arbeiten.
SELECT m.nachname,
       m.vorname
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS arb ON m.id = arb.mit_id
INNER JOIN Projekt AS p ON arb.pro_id = p.id
WHERE p.bezeichnung = 'Merkur';

-- Aufgabe 6.8:
-- Nennen Sie Namen und Vornamen aller Projektleiter, deren Abteilung den Standort München hat.
SELECT m.nachname,
       m.vorname
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS arb ON m.id = arb.mit_id
INNER JOIN Abteilung AS abt ON m.abt_id = abt.id
WHERE arb.aufgabe = 'Projektleiter' 
  AND abt.ort = 'München';

GO

-- ============================================================================
-- 📂 TEIL 6: WEITERE KOMPLEXE PRAXISAUFGABEN AUF DER PROJEKTDB
-- ============================================================================

-- Praxis 1: 
-- Berechnen Sie den Gesamtumsatz pro Abteilung. Geben Sie Abteilungsbezeichnung 
-- und die Summe absteigend sortiert aus.
SELECT a.bezeichnung AS abteilung,
       SUM(u.umsatz) AS gesamtumsatz
FROM Abteilung AS a
INNER JOIN Mitarbeiter AS m ON a.id = m.abt_id
INNER JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY a.bezeichnung
ORDER BY gesamtumsatz DESC;

-- Praxis 2:
-- Identifizieren Sie alle Mitarbeiter, deren Gehalt höher ist als das Gehalt ihres Chefs.
SELECT m.nachname AS mitarbeiter,
       gm.gehalt AS gehalt_mitarbeiter,
       c.nachname AS vorgesetzter,
       gc.gehalt AS gehalt_chef
FROM Mitarbeiter AS m
INNER JOIN Gehalt AS gm ON m.id = gm.mit_id
INNER JOIN Mitarbeiter AS c ON m.chef_id = c.id
INNER JOIN Gehalt AS gc ON c.id = gc.mit_id
WHERE gm.gehalt > gc.gehalt;

GO

