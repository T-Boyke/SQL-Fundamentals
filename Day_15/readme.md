# 📅 Day_15: Tabellenverknüpfungen (JOINS in DQL)

## ℹ️ Kurs-Informationen

* **Datum:** Freitag, 21.08.2026
* **Arbeitszeit:** 08:15 - 16:00 Uhr
* **Dozent:** Tom S.
* **Autor:** Tobias Boyke

---

## 🎯 Lernziele des Tages

- [x] **Das Join-Prinzip verstehen:** Verknüpfen relationaler Tabellen über Primär- und Fremdschlüsselbeziehungen zur Vermeidung von Redundanz bei Abfragen.
- [x] **CROSS JOIN (Kartesisches Produkt / Kreuzprodukt):** Kombination aller Zeilen beider Tabellen ($n \times m$) und Abgrenzung zwischen SQL-89 (Komma-Trennung) und SQL-92 Syntax.
- [x] **INNER JOIN (Gleichheitsverbund / Schnittmenge):** Zusammenführen übereinstimmender Datensätze mit der `ON`-Klausel über 2, 3 oder mehr Tabellen (Multi-Table Joins).
- [x] **OUTER JOINS (LEFT, RIGHT, FULL OUTER JOIN):**
  - Beibehalten nicht-übereinstimmender Zeilen mit automatischer `NULL`-Auffüllung.
  - **Anti-Joins:** Gezieltes Identifizieren verwaister Datensätze (`WHERE spalte IS NULL`).
- [x] **SELF JOIN (Selbstreferenzielle Verknüpfung):** Abbilden hierarchischer Beziehungen (z. B. Mitarbeiter ➔ Vorgesetzter via `chef_id`) innerhalb derselben Tabelle.
- [x] **Join-Logik vs. Zeilenfilter (`ON` vs. `WHERE`):** Verstehen, wie sich Filterkriterien im `ON` und im `WHERE` bei Outer Joins fundamental unterscheiden.
- [x] **Profi-Aggregationen mit Joins:** Gruppierung verknüpfter Tabellen und String-Kompression mittels `STRING_AGG()`.

---

## 📖 Theorie & Konzepte: Der große JOIN-Spickzettel

```mermaid
flowchart TD
    subgraph J1["1. CROSS JOIN"]
        A1["Tabelle A (n Zeilen)"] -->|Jede Zeile kombiniert mit jeder| A2["Tabelle B (m Zeilen)"]
        A2 --> A3["Ergebnis: n * m Zeilen (Kartesisches Produkt)"]
    end

    subgraph J2["2. INNER JOIN"]
        B1["Tabelle A"] & B2["Tabelle B"] -->|Nur Schnittmenge (ON A.key = B.key)| B3["Ergebnis: Nur gemeinsame Datensätze"]
    end

    subgraph J3["3. OUTER JOINS"]
        C1["LEFT JOIN: Alle Zeilen von A + Treffer aus B"]
        C2["RIGHT JOIN: Alle Zeilen von B + Treffer aus A"]
        C3["FULL OUTER JOIN: Alle Zeilen aus A und B (inkl. NULLs)"]
    end
```

---

### 1. Die Evolution der Join-Syntax: SQL-89 vs. SQL-92

In SQL existieren zwei syntaktische Schreibweisen für Tabellenverknüpfungen:

| Kriterium | SQL-89 (Veraltet / Implizit) | SQL-92 (ANSI-Standard / Explizit) |
| :--- | :--- | :--- |
| **Schreibweise** | Tabellen im `FROM` mit Komma getrennt, Verknüpfung im `WHERE` | Explizites Schlüsselwort `[INNER/LEFT/CROSS] JOIN` mit `ON`-Klausel |
| **Beispiel** | `SELECT * FROM Mitarbeiter m, Abteilung a WHERE m.abt_id = a.id;` | `SELECT * FROM Mitarbeiter m INNER JOIN Abteilung a ON m.abt_id = a.id;` |
| **Fehleranfälligkeit** | **Extrem hoch!** Wird das `WHERE` vergessen, entsteht unbemerkt ein gigantisches Kartesisches Produkt. | **Sicher!** Der SQL-Parser verlangt zwingend die `ON`-Bedingung. |
| **Trennung der Logik** | Vermischt Verknüpfungslogik und Datenfilterung im selben `WHERE`-Block. | Saubere Trennung: `ON` verbindet Tabellen, `WHERE` filtert Zeilen. |
| **Outer Joins** | Nicht standardisiert (proprietäre Zeichen wie `*=`, `=*` oder `(+)`). | Standardisiert über `LEFT OUTER JOIN`, `RIGHT OUTER JOIN`, `FULL OUTER JOIN`. |

> [!IMPORTANT]
> **Industriestandard:**
> Im professionellen Datenbankumfeld und in IHK-Prüfungen ist die **SQL-92 Syntax mit expliziten JOINs und ON-Klauseln** verbindlicher Standard!

---

### 2. Die JOIN-Typen im Detail

#### A. CROSS JOIN (Kartesisches Produkt / Kreuzprodukt / "Orgien-JOIN")
Kombiniert jede einzelne Zeile der linken Tabelle mit jeder Zeile der rechten Tabelle.

* **Zeilenanzahl:** $\text{Zeilen}(A) \times \text{Zeilen}(B)$ (z. B. $15 \text{ Mitarbeiter} \times 5 \text{ Abteilungen} = 75 \text{ Zeilen}$).
* **Syntax:**
  ```sql
  SELECT m.nachname, a.bezeichnung
  FROM Mitarbeiter AS m
  CROSS JOIN Abteilung AS a;
  ```
* **Praxisnutzen:** Erzeugen von Planungsmatrizen, Kalendertabellen, Schichtplänen oder Dimensionskombinationen.

---

#### B. INNER JOIN (Gleichheitsverbund / Schnittmenge)
Gibt nur die Zeilen zurück, bei denen der Verknüpfungsschlüssel in **beiden** Tabellen übereinstimmt:

```sql
SELECT m.nachname, a.bezeichnung AS abteilung
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id = a.id;
```

---

#### C. LEFT OUTER JOIN & RIGHT OUTER JOIN
Behält alle Zeilen der Quelltabelle (links bzw. rechts), selbst wenn in der verknüpften Zieltabelle **kein Partnerdatensatz** existiert (die fehlenden Werte werden mit `NULL` aufgefüllt):

* **LEFT JOIN:** Behält alle Mitarbeiter (auch ohne Abteilung).
* **RIGHT JOIN:** Behält alle Abteilungen (auch ohne Mitarbeiter).

```sql
-- Alle Mitarbeiter anzeigen (auch wenn keine Abteilung zugeordnet ist):
SELECT m.nachname, a.bezeichnung AS abteilung
FROM Mitarbeiter AS m
LEFT OUTER JOIN Abteilung AS a ON m.abt_id = a.id;
```

---

#### D. Anti-Join: Verwaiste Datensätze finden
Kombiniert man einen `LEFT JOIN` mit einer `WHERE ... IS NULL`-Prüfung auf den Primärschlüssel der rechten Tabelle, erhält man exakt die Datensätze, die **keine Beziehung** besitzen:

```sql
-- Finde alle Abteilungen, in denen KEIN Mitarbeiter arbeitet:
SELECT a.id, a.bezeichnung
FROM Abteilung AS a
LEFT JOIN Mitarbeiter AS m ON a.id = m.abt_id
WHERE m.id IS NULL;
```

---

#### E. SELF JOIN (Selbstreferenz / Rekursive Verknüpfung)
Verknüpft eine Tabelle mit sich selbst über zwei verschiedene Aliase. Typischer Anwendungsfall: Mitarbeiter und ihr Vorgesetzter (`chef_id` ➔ `id`).

```sql
SELECT m.nachname AS mitarbeiter,
       ISNULL(c.nachname, '-> Geschäftsführung') AS vorgesetzter
FROM Mitarbeiter AS m
LEFT JOIN Mitarbeiter AS c ON m.chef_id = c.id;
```

---

### 3. Der kritische Unterschied: `ON` vs. `WHERE` bei Outer Joins

> [!CAUTION]
> **Häufige Fehlerquelle bei LEFT JOINS:**
> * Kriterien im **`ON`** steuern, welche Zeilen der rechten Tabelle verknüpft werden. Die linke Tabelle bleibt **vollständig erhalten**!
> * Kriterien im **`WHERE`** filtern das Gesamtergebnis **nach** dem Join. Ein Filter wie `WHERE a.ort = 'Ulm'` filtert alle Zeilen mit `NULL` heraus und macht den `LEFT JOIN` unbemerkt zu einem gewöhnlichen `INNER JOIN`!

---

## 🎓 IHK-Prüfungsrelevanz: Joins

### 📝 Typische Prüfungsfragen & Antworten

#### Frage 1: Erklären Sie den Unterschied zwischen einem INNER JOIN und einem LEFT OUTER JOIN. (4 Punkte)
> **IHK-Musterantwort:**
> * Ein `INNER JOIN` gibt nur die Datensätze zurück, bei denen in beiden Tabellen übereinstimmende Schlüsselwerte vorhanden sind (Schnittmenge). Datensätze ohne Partner in der anderen Tabelle werden verworfen.
> * Ein `LEFT OUTER JOIN` gibt **alle** Datensätze der linken Tabelle zurück. Existiert für einen Datensatz kein passender Partner in der rechten Tabelle, werden die Spalten der rechten Tabelle mit `NULL` aufgefüllt.

#### Frage 2: Was versteht man unter einem Kartesischen Produkt in SQL und wie entsteht es versehentlich? (4 Punkte)
> **IHK-Musterantwort:**
> Ein Kartesisches Produkt entsteht, wenn zwei Tabellen ohne Verknüpfungsbedingung miteinander verknüpft werden. Dabei wird jede Zeile der ersten Tabelle mit jeder Zeile der zweiten Tabelle kombiniert ($n \times m$ Ergebniszeilen). In veralteter SQL-89-Syntax entsteht dies versehentlich, wenn die `WHERE`-Klausel vergessen wird (`SELECT * FROM A, B;`).

---

## 💻 Praktische Übungen: Aufgaben & Lösungen (ProjektDB)

Die lauffähigen SQL-Skripte befinden sich in:  
👉 **[joins_grundlagen_und_praxis.sql](./src/joins_grundlagen_und_praxis.sql)**

---

### 📂 Übung 1: Mitarbeiter, Abteilung und Gehalt
* **Aufgabenstellung:** Nennen Sie Vorname, Nachname, Abteilungsbezeichnung und Monatsgehalt aller Mitarbeiter, sortiert nach Abteilung.
```sql
SELECT m.vorname,
       m.nachname,
       a.bezeichnung AS abteilung,
       g.gehalt
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id = a.id
INNER JOIN Gehalt AS g ON m.id = g.mit_id
ORDER BY a.bezeichnung ASC, m.nachname ASC;
```

---

### 📂 Übung 2: Gesamtumsatz pro Abteilung
* **Aufgabenstellung:** Berechnen Sie die Summe aller Umsätze je Abteilung und geben Sie Abteilungsname und Gesamtumsatz absteigend sortiert aus.
```sql
SELECT a.bezeichnung AS abteilung,
       SUM(u.umsatz) AS gesamtumsatz
FROM Abteilung AS a
INNER JOIN Mitarbeiter AS m ON a.id = m.abt_id
INNER JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY a.bezeichnung
ORDER BY gesamtumsatz DESC;
```

---

### 📂 Übung 3: Projektleiter mit Budget und Kundenfirma (4-Table Join)
* **Aufgabenstellung:** Ermitteln Sie alle Projektleiter mit Projektnamen, Projektbudget und dem beauftragenden Kunden.
```sql
SELECT CONCAT(m.vorname, ' ', m.nachname) AS projektleiter,
       p.bezeichnung AS projekt,
       p.mittel AS budget,
       k.firma AS kunde
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS arb ON m.id = arb.mit_id
INNER JOIN Projekt AS p ON arb.pro_id = p.id
INNER JOIN Kunde AS k ON p.kunde_id = k.id
WHERE arb.aufgabe = 'Projektleiter';
```

---

### 📂 Übung 4: Aufgaben pro Mitarbeiter mit STRING_AGG
* **Aufgabenstellung:** Geben Sie für jeden Mitarbeiter alle zugewiesenen Projektaufgaben als kommagetrennte Liste aus.
```sql
SELECT m.id,
       m.vorname,
       m.nachname,
       STRING_AGG(ISNULL(arb.aufgabe, 'Keine Aufgabe'), ', ') AS aufgaben
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS arb ON m.id = arb.mit_id
GROUP BY m.id, m.vorname, m.nachname;
```

---

### 📂 Übung 5: Gehaltsvergleich Mitarbeiter vs. Chef (Self Join)
* **Aufgabenstellung:** Finden Sie alle Mitarbeiter, die ein höheres Gehalt beziehen als ihr direkter Vorgesetzter.
```sql
SELECT m.nachname AS mitarbeiter,
       gm.gehalt AS gehalt_mitarbeiter,
       c.nachname AS vorgesetzter,
       gc.gehalt AS gehalt_chef
FROM Mitarbeiter AS m
INNER JOIN Gehalt AS gm ON m.id = gm.mit_id
INNER JOIN Mitarbeiter AS c ON m.chef_id = c.id
INNER JOIN Gehalt AS gc ON c.id = gc.mit_id
WHERE gm.gehalt > gc.gehalt;
```

---

## 💡 Wichtige Notizen & Performance-Tipps

> [!TIP]
> **Indizes auf Fremdschlüsseln:**
> Tabellenverknüpfungen über `JOIN ... ON Fremdschlüssel = Primärschlüssel` profitieren massiv von Non-Clustered Indizes auf den Fremdschlüsselspalten (z. B. auf `Mitarbeiter.abt_id` oder `Arbeit.pro_id`), da das DBMS dadurch schnelle *Index Seeks* statt teurer *Scans* durchführen kann.

> [!NOTE]
> **Join-Operatoren des SQL Servers:**
> Der SQL Server Query Optimizer wählt je nach Datenmenge und Indizierung automatisch den besten physischen Operator:
> 1. **Nested Loops:** Optimal für kleine Datenmengen mit Index Seek.
> 2. **Merge Join:** Extrem schnell, wenn beide Tabellen bereits nach dem Join-Schlüssel sortiert vorliegen (z. B. über Clustered Index).
> 3. **Hash Match:** Für große, unsortierte Mengen ohne passende Indizes.