# 📅 Day_12: Sortierung (ORDER BY), Aggregatfunktionen & Gruppierung (GROUP BY / HAVING)

## ℹ️ Kurs-Informationen
*   **Datum:** Dienstag, 18.08.2026
*   **Arbeitszeit:** 08:15 - 16:00 Uhr
*   **Dozent:** Tom S.
*   **Autor:** Tobias Boyke

---

## 🎯 Lernziele des Tages
- [x] **Logische Ausführungsreihenfolge:** Verstehen, warum die Datenbank Abfragen nicht von oben nach unten abarbeitet, sondern in einer festen logischen Reihenfolge (`FROM` ➡️ `WHERE` ➡️ `GROUP BY` ➡️ `HAVING` ➡️ `SELECT` ➡️ `ORDER BY`).
- [x] **Sortieren (ORDER BY):** Beherrschen der Sortierung nach mehreren Spalten, nach Spaltenpositionen und gezieltes Handling von `NULL`-Werten.
- [x] **Ergebnisbegrenzung (TOP):** Selektion der obersten Datensätze mit `TOP (n)`, `TOP (n) PERCENT` und das Verhindern von unfairen Abschneidern bei Gleichständen mittels `WITH TIES`.
- [x] **Aggregatfunktionen:** Korrekte Anwendung von `SUM()`, `AVG()`, `MIN()`, `MAX()` und `COUNT()` und deren Verhalten bei `NULL`-Werten.
- [x] **Gruppierung (GROUP BY):** Einhalten der goldenen SQL-Regel für Spalten im `SELECT`-Bereich bei Aggregationen.
- [x] **Gruppenfilterung (HAVING):** Klare Abgrenzung zwischen `WHERE` (Filterung einzelner Zeilen vor der Aggregation) und `HAVING` (Filterung ganzer Gruppen nach der Aggregation).
- [x] **Profi-Aggregationen:** String-Verkettung innerhalb von Gruppen mittels `STRING_AGG()`.

---

## 📖 Theorie & Konzepte

### 1. Die logische Ausführungsreihenfolge einer SQL-Abfrage
Eine SQL-Abfrage wird im Hintergrund der Datenbank in einer fest definierten Reihenfolge abgearbeitet. Dies erklärt viele Syntaxregeln (z. B. warum Aliase aus dem `SELECT` nicht im `WHERE` oder `HAVING` genutzt werden dürfen, aber im `ORDER BY` erlaubt sind).

```mermaid
flowchart TD
    1["1. FROM (Quelltabelle & Joins wählen)"] --> 2["2. WHERE (Einzelne Zeilen vorab filtern)"]
    2 --> 3["3. GROUP BY (Zeilen zu Gruppen zusammenfassen)"]
    3 --> 4["4. HAVING (Fertige Gruppen filtern)"]
    4 --> 5["5. SELECT (Spaltenauswahl & Berechnungen)"]
    5 --> 6["6. ORDER BY (Ergebnismenge sortieren)"]
```

| Schritt | Klausel | Funktion | Alias verwendbar? |
| :--- | :--- | :--- | :--- |
| **1** | **FROM** | Woher kommen die Daten? (Tabellenauswahl) | Nein |
| **2** | **WHERE** | Welche Zeilen zählen? (Filterung vor Gruppierung) | Nein |
| **3** | **GROUP BY** | Wie wird zusammengefasst? (Gruppen bilden) | Nein |
| **4** | **HAVING** | Welche Gruppen fliegen raus? (Filterung nach Aggregation) | Nein |
| **5** | **SELECT** | Was wird angezeigt? (Berechnungen, Aliase vergeben) | **Hier definiert** |
| **6** | **ORDER BY** | Wie wird sortiert? (Der finale Schliff) | **Ja!** |

---

### 2. Daten sortieren mit ORDER BY
Mit `ORDER BY` wird die Ausgabe strukturiert. Standardmäßig sortiert SQL aufsteigend.

*   `ASC` (Ascending): Aufsteigend (A-Z, 1-10) - Standardwert, muss nicht angegeben werden.
*   `DESC` (Descending): Absteigend (Z-A, 10-1).
*   **Mehrfach-Sortierung:** Sortieren nach mehreren Spalten nacheinander (z. B. `ORDER BY nachname DESC, vorname ASC;`).
*   **Sortierung nach Spaltenposition:** Abkürzung im Code (z. B. `ORDER BY 3 DESC;` sortiert nach der 3. Spalte im `SELECT`-Bereich).

#### ⚠️ Sonderfall: NULL-Werte beim Sortieren
`NULL` bedeutet in SQL "unbekannt". Je nach RDBMS werden `NULL`-Werte unterschiedlich bewertet:
*   **MS SQL Server / MySQL:** `NULL` gilt als der kleinste Wert. Bei `ASC` steht er ganz oben, bei `DESC` ganz unten.
*   **PostgreSQL / Oracle:** `NULL` gilt als der größte Wert. Bei `ASC` steht er ganz unten, bei `DESC` ganz oben.

##### T-SQL-Trick zur Verbannung von NULL-Werten ans Ende
```sql
ORDER BY 
    CASE WHEN gehalt IS NULL THEN 1 ELSE 0 END ASC, 
    gehalt DESC;
```

---

### 3. Ergebnisbegrenzung mit TOP und WITH TIES
*   `TOP (n)`: Liefert die ersten `n` Datensätze zurück.
*   `TOP (n) PERCENT`: Liefert die obersten `n` Prozent der Datensätze zurück (z. B. `TOP (35.37) PERCENT`).
*   `WITH TIES`: Gibt bei einem Gleichstand im Sortierkriterium zusätzlich alle Datensätze aus, die denselben Wert wie der letzte reguläre Platz haben.

> [!IMPORTANT]
> `TOP` ohne `ORDER BY` ist in der Praxis gefährlich, da die Datenbank die Zeilen ohne Sortierung in zufälliger physikalischer Reihenfolge ausgibt. `WITH TIES` erfordert **zwingend** eine `ORDER BY`-Klausel!

---

### 4. Aggregatfunktionen & Die "Goldene Regel" der Gruppierung
Aggregatfunktionen fassen mehrere Zeilen zu einem einzelnen Wert zusammen. Die fünf Standard-Funktionen sind:
*   `COUNT()`: Zählt Datensätze. `COUNT(*)` zählt alle Zeilen inklusive `NULL`s, `COUNT(spalte)` ignoriert `NULL`-Einträge.
*   `SUM()`: Berechnet die Summe. Ignoriert `NULL`s.
*   `AVG()`: Berechnet den Durchschnitt. Ignoriert `NULL`s (wichtig: Zeilen mit `NULL` fließen auch nicht in den Nenner der Division ein!).
*   `MIN()` / `MAX()`: Ermitteln den kleinsten bzw. größten Wert. Ignoriert `NULL`s.

> [!CAUTION]
> **Die Goldene Regel der Gruppierung:**
> Jede Spalte im `SELECT`-Bereich, die **keine** Aggregatfunktion besitzt, **muss** zwingend in der `GROUP BY`-Klausel aufgeführt sein! Andernfalls verweigert der SQL-Parser die Ausführung mit einer Fehlermeldung.

---

### 5. Filterung: WHERE vs. HAVING
Der entscheidende Unterschied zwischen den beiden Filter-Klauseln liegt im Zeitpunkt ihrer Ausführung:

| Kriterium | WHERE-Klausel | HAVING-Klausel |
| :--- | :--- | :--- |
| **Arbeitsweise** | Filtert einzelne Datensätze (Zeilen). | Filtert aggregierte Gruppen von Zeilen. |
| **Ausführungszeitpunkt** | **Vor** der Gruppierung (`GROUP BY`). | **Nach** der Gruppierung (`GROUP BY`). |
| **Aggregatfunktionen** | Verboten (z. B. `WHERE SUM(umsatz) > 5000` wirft einen Fehler). | Erlaubt und primärer Einsatzzweck. |

---

### 6. STRING_AGG() zur Gruppen-Kompression
In MS SQL Server können Zeichenketten innerhalb einer Gruppe mit `STRING_AGG()` in eine kommagetrennte Liste umgewandelt werden, um alle Gruppendetails in einer einzigen Zeile anzuzeigen:
```sql
SELECT abt_id, STRING_AGG(CONCAT(vorname, ' ', nachname), ', ') AS mitarbeiter
FROM Mitarbeiter
GROUP BY abt_id;
```

---

## 🎓 IHK-Prüfungsrelevanz: Aggregation & Sortierung

### 📝 Typische Prüfungsfragen & Antworten

#### 1. Erklären Sie den Unterschied zwischen den Klauseln WHERE und HAVING in SQL. (4 Punkte)
> **IHK-Musterantwort:**
> * Die `WHERE`-Klausel wird vor der Gruppierung ausgeführt und filtert einzelne Datensätze der Tabelle. In ihr dürfen keine Aggregatfunktionen verwendet werden.
> * Die `HAVING`-Klausel wird nach der Gruppierung ausgeführt und filtert die aggregierten Gruppen. Sie wird typischerweise mit Aggregatfunktionen (z. B. `HAVING SUM(...) > 1000`) verwendet.

#### 2. Was besagt die "Goldene Regel" der GROUP BY-Klausel? Nennen Sie ein syntaktisch fehlerhaftes und ein korrektes SQL-Beispiel. (6 Punkte)
> **IHK-Musterantwort:**
> Die Regel besagt, dass alle Spalten, die in der `SELECT`-Klausel aufgeführt sind und nicht Teil einer Aggregatfunktion sind, zwingend in der `GROUP BY`-Klausel aufgeführt werden müssen.
> 
> *Fehlerhaftes Beispiel:*
> ```sql
> SELECT abt_id, ort, AVG(gehalt) FROM Mitarbeiter GROUP BY abt_id; -- Fehler: 'ort' fehlt im GROUP BY
> ```
> *Korrektes Beispiel:*
> ```sql
> SELECT abt_id, ort, AVG(gehalt) FROM Mitarbeiter GROUP BY abt_id, ort;
> ```

#### 3. Wie verhalten sich Aggregatfunktionen wie SUM() oder AVG() in SQL bei Datensätzen, die NULL-Werte enthalten? (4 Punkte)
> **IHK-Musterantwort:**
> Aggregatfunktionen ignorieren `NULL`-Werte bei der Berechnung standardmäßig. Bei `SUM()` werden nur die numerischen Werte addiert. Bei `AVG()` werden die `NULL`-Werte ignoriert und die Zeilen fließen auch nicht in den Divisor (die Anzahl der Zeilen) ein. Besteht eine Gruppe ausschließlich aus `NULL`-Werten, ist das Gesamtergebnis der Funktion ebenfalls `NULL` (Ausnahme: `COUNT()` gibt in diesem Fall `0` zurück).

---

## 💻 Praktische Übungen

Die Übungsaufgaben des heutigen Tages befinden sich im SQL-Skript:
👉 **[order_by_and_aggregations.sql](file:///c:/Users/Tobia/Desktop/cSharpRepo/SQL-Fundamentals/Day_12/src/order_by_and_aggregations.sql)**

Dieses Skript enthält:
1. Alle experimentellen Abfragen und Beispiele aus dem Unterricht.
2. Die vollständigen Übungen und Lösungen zu den Aufgaben:
   - **Aufgaben 3.1 - 3.7** (Kategorie: `ORDER BY`)
   - **Aufgaben 4.3 - 4.6** (Kategorie: `Aggregatfunktionen`)
   - **Aufgaben 4.7 - 4.11** (Kategorie: `Aggregatfunktionen mit Gruppierung`)

---

## 💡 Wichtige Notizen

> [!NOTE]
> *   Nutzen Sie `ISNULL(Spalte, Ersatzwert)` (oder das standardisierte `COALESCE(Spalte, Ersatzwert)`), um unschöne `NULL`-Werte in den Ausgabe-Aggregaten (z. B. Umsatzsummen) oder in den Gruppennamen zu vermeiden.
> *   Verwenden Sie im `WHERE` immer die Originalspalten für Filterungen (z. B. `WHERE nachname = 'Müller'`), da Berechnungen und Stringoperationen wie `CONCAT()` im `WHERE` den Einsatz von Indizes verhindern (Non-SARGable Queries) und zu Performance-Verlusten führen.