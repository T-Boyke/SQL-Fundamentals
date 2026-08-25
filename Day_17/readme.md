# 📅 Day_17: Fortgeschrittene OUTER JOINs, Aggregationen & Nullwert-Handling

## ℹ️ Kurs-Informationen

* **Datum:** Dienstag, 25.08.2026
* **Arbeitszeit:** 08:15 - 16:00 Uhr
* **Dozent:** Tom S.
* **Autor:** Tobias Boyke

---

## 🎯 Lernziele des Tages

- [x] **OUTER JOINs mit Aggregationen beherrschen:** Das Zusammenspiel von `LEFT JOIN` mit Aggregatfunktionen (`SUM`, `COUNT`, `MIN`, `MAX`, `AVG`) verstehen und fehlerfrei einsetzen.
- [x] **Nullwert-Substitution meistern:** Fehlende Werte (`NULL`) aus unvollständigen Beziehungen via `ISNULL()`, `COALESCE()` und `CASE WHEN` kontrolliert in Standardwerte (`0.00`, `'- k. A. -'`) umwandeln.
- [x] **Die Dreiwertige Logik (3VL) im `HAVING` beherrschen:** Erkennen, warum `NULL < 100000` in SQL `UNKNOWN` ergibt, und Aggregatfilter im `HAVING` gegen Datenverlust absichern.
- [x] **Anti-Joins für Geschäftsberichte einsetzen:** Verwaiste Entitäten (z. B. Mitarbeiter ohne jegliche Umsätze) via `LEFT JOIN ... WHERE B.id IS NULL` isolieren.
- [x] **Multi-Table OUTER JOINs mit Rollenfiltern strukturieren:** Präzise Steuerung von Bedingungen in der `ON`-Klausel (z. B. `AND arb.aufgabe = 'Projektleiter'`), um alle Basisdatensätze zu erhalten.
- [x] **Filterplatzierung verinnerlichen:** Filter auf die *linke Basistabelle* (`WHERE m.abt_id = 2`) sauber von Verknüpfungsfiltern auf die *rechte Tabelle* (`ON`) abgrenzen.
- [x] **Single Source of Truth (SoT):** Konsequente Einhaltung des relationalen `ProjektDB`-Schemas.

---

## 🗺️ Der relationale Kompass: Wie hängen die Tabellen zusammen?

Am heutigen Tag stehen insbesondere die Beziehungen zwischen **Mitarbeiter**, **Umsatz**, **Arbeit** und **Projekt** im Mittelpunkt:

```mermaid
erDiagram
    ABTEILUNG ||--o{ MITARBEITER : "beschaeftigt (abt_id)"
    MITARBEITER ||--o{ UMSATZ : "erzielt (mit_id)"
    MITARBEITER ||--o{ ARBEIT : "arbeitet_in (mit_id)"
    PROJEKT ||--o{ ARBEIT : "beinhaltet (pro_id)"

    MITARBEITER {
        int id PK "Personalnummer"
        string vorname "Vorname"
        string nachname "Nachname"
        int abt_id FK "Abteilung"
        string ort "Wohnort"
        int chef_id FK "Vorgesetzter"
    }

    UMSATZ {
        int id PK "Umsatz-ID"
        int mit_id FK "Mitarbeiter-ID"
        date datum "Umsatzdatum"
        decimal umsatz "Umsatzbetrag in EUR"
    }

    ARBEIT {
        int mit_id PK, FK "Mitarbeiter-ID"
        int pro_id PK, FK "Projekt-ID"
        string aufgabe "Rolle (z. B. Projektleiter)"
        date einst_dat "Eintrittsdatum"
    }

    PROJEKT {
        int id PK "Projekt-ID"
        string kuerzel "Kuerzel"
        string bezeichnung "Projektname"
        decimal mittel "Projektbudget"
        int kunde_id FK "Kunde"
    }
```

---

## 📖 Theorie & Kernkonzepte im Detail

### 1. Die 1:n Multiplikation beim `LEFT JOIN`

Wird eine Basistabelle (`Mitarbeiter`, 15 Datensätze) per `LEFT JOIN` mit einer Detailtabelle (`Umsatz`) verknüpft, entstehen zwei Effekte:

1. **Mitarbeiter mit Umsätzen (z. B. Petra Huber):** Für jeden einzelnen Umsatzbeleg wird eine neue Ergebniszeile generiert (Zeilenvervielfachung).
2. **Mitarbeiter ohne Umsätze (z. B. Rainer Meier):** Der Mitarbeiter bleibt mit genau **1 Ergebniszeile** erhalten, wobei alle Spalten aus `Umsatz` mit `NULL` befüllt werden.

```mermaid
flowchart TD
    subgraph Input["1. Ausgangstabellen"]
        M["15 Mitarbeiter"]
        U["Umsatzbelege"]
    end

    subgraph Join["2. LEFT JOIN Mitarbeiter -> Umsatz"]
        M -->|"LEFT JOIN on m.id = u.mit_id"| RES["36 Gesamtzeilen"]
    end

    subgraph Output["3. Differenzierte Ausgabe"]
        RES --> M_WITH["4 Mitarbeiter mit Umsätzen (insg. 25 Umsatzzeilen)"]
        RES --> M_WITHOUT["11 Mitarbeiter ohne Umsätze (je 1 Zeile mit NULL)"]
    end
```

---

### 2. 🚨 Die `SUM(NULL)`- und `COUNT(*)`-Falle bei Outer Joins

Werden Daten nach einem `LEFT JOIN` aggregiert, verhalten sich SQL-Aggregatfunktionen fundamental unterschiedlich bei `NULL`-Werten:

```mermaid
flowchart TD
    LJ["LEFT JOIN liefert Zeilen mit NULL fuer fehlende Umsaetze"] --> Q{"Welche Aggregation wird gewaehlt?"}
    
    Q -->|"COUNT(*)"| C1["❌ FALSCH: Zaehlt die physische Zeile (Ergebnis: 1)"]
    Q -->|"COUNT(u.id)"| C2["✅ RICHTIG: Ignoriert NULL-Werte (Ergebnis: 0)"]
    Q -->|"SUM(u.umsatz)"| S1["⚠️ ACHTUNG: Liefert NULL statt 0.00!"]
    
    S1 -->|"Nachbehandlung"| S2["✅ ISNULL(SUM(u.umsatz), 0.00) liefert saubere 0.00"]
```

| Aggregatfunktion | Verhalten bei `NULL`-Einträgen | Ergebnis bei Mitarbeitern ohne Umsatz | Korrekter Best-Practice-Code |
| :--- | :--- | :---: | :--- |
| **`COUNT(*)`** | Zählt alle Zeilen (ignoriert `NULL` nicht) | **`1`** (❌ Falsch!) | `COUNT(u.id)` $\rightarrow$ liefert **`0`** |
| **`COUNT(u.id)`** | Zählt nur Werte $\neq \text{NULL}$ | **`0`** (✅ Richtig) | `COUNT(u.id)` |
| **`SUM(u.umsatz)`** | Ignoriert `NULL`, liefert bei nur `NULL` jedoch `NULL` | **`NULL`** (⚠️ Unschön) | **`ISNULL(SUM(u.umsatz), 0.00)`** |
| **`MIN(u.datum)`** | Sucht kleinstes Datum $\neq \text{NULL}$ | **`NULL`** (✅ Erwünscht) | `MIN(u.datum)` |
| **`MAX(u.datum)`** | Sucht größtes Datum $\neq \text{NULL}$ | **`NULL`** (✅ Erwünscht) | `MAX(u.datum)` |

---

### 3. 🧠 Die Dreiwertige Logik (3VL) in der `HAVING`-Klausel

Dies ist eine der gefährlichsten Fehlerquellen in SQL-Abfragen:

> **Szenario:** Wir gruppieren Mitarbeiter und suchen alle Personen mit $\text{Gesamtumsatz} < 100.000\text{ €}$.  
> Mitarbeiter ohne Umsätze haben als Aggregatergebnis `SUM(u.umsatz) = NULL`.

```sql
-- ❌ LOGIKFEHLER:
HAVING SUM(u.umsatz) < 100000
```

#### Warum liefert dies nur 2 statt 13 Zeilen?
1. In SQL führt jeder Vergleich mit `NULL` zu **`UNKNOWN`** (weder `TRUE` noch `FALSE`).
2. Die Auswertung `NULL < 100000` ergibt `UNKNOWN`.
3. Sowohl `WHERE` als auch `HAVING` filtern alle Zeilen heraus, deren Bedingung **nicht explizit `TRUE`** ist.
4. Folglich fliegen alle 11 Mitarbeiter mit 0 Umsätzen unbemerkt aus dem Ergebnis!

```mermaid
flowchart LR
    subgraph Eval["Auswertung: HAVING SUM(u.umsatz) < 100000"]
        direction TB
        E1["Kaufmann (100.000 €): 100.000 < 100.000 -> FALSE (Weggefiltert)"]
        E2["Huber (18.000 €): 18.000 < 100.000 -> TRUE (Im Ergebnis)"]
        E3["Schäfer (0 Umsätze): NULL < 100.000 -> UNKNOWN (Weggefiltert!)"]
    end

    subgraph Solution["✅ Loesung: ISNULL(SUM(u.umsatz), 0) < 100000"]
        direction TB
        S1["Schäfer: ISNULL(NULL, 0) = 0 -> 0 < 100.000 -> TRUE (Bleibt erhalten!)"]
    end
```

---

### 4. 🔗 Multi-Table OUTER JOIN mit Rollenbedingungen (`ON` vs. `WHERE`)

Sollen alle Mitarbeiter mit ihrem geleiteten Projekt aufgeführt werden (Aufgabe 8.15), benötigen wir zwei Joins:
1. `Mitarbeiter` $\rightarrow$ `Arbeit` (Einsätze filtern auf Rolle *'Projektleiter'*)
2. `Arbeit` $\rightarrow$ `Projekt` (Projektnamen holen)

```mermaid
flowchart TD
    M["Alle 15 Mitarbeiter"] -->|"LEFT JOIN Arbeit ON m.id = arb.mit_id AND arb.aufgabe = 'Projektleiter'"| ARB["Nur Projektleiter-Einsaetze verknuepfen (andere erhalten NULL)"]
    ARB -->|"LEFT JOIN Projekt ON arb.pro_id = p.id"| PRJ["Projektdaten anhaengen"]
    PRJ --> OUT["15 Zeilen Ergebnis: Projektleiter mit Projektname, alle anderen mit NULL / '- k. A. -'"]
```

> [!WARNING]
> **🚨 Warum darf `arb.aufgabe = 'Projektleiter'` NICHT ins `WHERE`?**
> * Steht die Bedingung im `WHERE`, wird sie **nach** dem Join auf das Gesamtergebnis angewendet.
> * Für jeden Nicht-Projektleiter ist `arb.aufgabe` jedoch `NULL`.
> * Da `NULL = 'Projektleiter'` `UNKNOWN` ergibt, werden alle normalen Mitarbeiter eliminiert. Der `LEFT JOIN` verkommt zu einem `INNER JOIN` mit nur 3 Datensätzen!

---

### 5. 🛠️ Nullwert-Funktionen im Vergleich

| Funktion | Standard | Argumente | Verhalten | Typ-Bindung |
| :--- | :---: | :---: | :--- | :--- |
| **`ISNULL(check_expr, repl_expr)`** | T-SQL (MS SQL) | Genau 2 | Gibt `repl_expr` zurück, wenn `check_expr IS NULL`. | Bindet fest an den Datentyp des 1. Arguments. |
| **`COALESCE(e1, e2, ..., eN)`** | ANSI-SQL (Portabel) | $\ge 2$ | Liefert den **ersten Nicht-NULL-Wert** in der Kette. | Wählt den Datentyp mit der höchsten Precedence. |
| **`CASE WHEN ... THEN ... ELSE`** | ANSI-SQL | Beliebig | Volle Kontrollstruktur mit komplexen Bedingungen. | Explizit und hochgradig flexibel. |

---

## 💻 Praktische Übungen: ProjektDB 08 (OUTER JOIN 2)

* **Aufgaben-Skript:** [`assets/ProjektDB 08 - OUTER JOIN 2 - Aufgaben.sql`](./assets/ProjektDB%2008%20-%20OUTER%20JOIN%202%20-%20Aufgaben.sql)
* **Lösungs-Skript:** [`assets/ProjektDB 08 - OUTER JOIN 2 - Lösungen.sql`](./assets/ProjektDB%2008%20-%20OUTER%20JOIN%202%20-%20Lösungen.sql)
* **Praxis-Skripte:** [`src/01_outer_joins_aggregationen_praxis.sql`](./src/01_outer_joins_aggregationen_praxis.sql)

---

### 📂 Aufgabe 8.9: Mitarbeiter und Einzelumsätze (inkl. 0-Ersatz)

* **Aufgabenstellung:** Zeigen Sie alle Mitarbeiter mit Id und Nachname an und geben Sie dazu die vom Mitarbeiter getätigten Umsätze aus. Hat der Mitarbeiter noch keine Umsätze getätigt, soll in der Spalte Umsatz 0 angezeigt werden.
* **Join-Pfad:** `Mitarbeiter (m)` $\rightarrow$ `Umsatz (u)` über `m.id = u.mit_id`
* **Erwartete Ausgabe (Auszug - 36 Zeilen):**
  ```text
  id     nachname  umsatz
  2581   Kaufmann  100000,00
  5765   Schäfer   0,00
  9031   Meier     0,00
  9912   Wolf      0,00
  10102  Huber     500,00
  10102  Huber     500,00
  ...
  (36 Zeilen)
  ```

```sql
SELECT m.id,
       m.nachname,
       ISNULL(u.umsatz, 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id;
```

> [!NOTE]
> **💡 Detail-Erklärung:**
> * Durch den `LEFT JOIN` bleiben alle 15 Mitarbeiter erhalten.
> * Mitarbeiter mit mehreren Belegen (z. B. Petra Huber mit 11 Buchungen) erzeugen entsprechend viele Zeilen.
> * Mitarbeiter ohne Buchungen erhalten durch `ISNULL(u.umsatz, 0.00)` den Betrag `0,00` statt `NULL`.

---

### 📂 Aufgabe 8.10: Mitarbeiter ohne Umsätze (Anti-Join)

* **Aufgabenstellung:** Überarbeiten Sie die Abfrage aus Aufgabe 8.9. Zeigen Sie diesmal nur die Mitarbeiter an, die noch keine Umsätze getätigt haben.
* **Join-Pfad:** `Mitarbeiter (m)` $\rightarrow$ `Umsatz (u)` mit Filter `WHERE u.id IS NULL`
* **Erwartete Ausgabe (11 Zeilen):**
  ```text
  id     nachname  umsatz
  5765   Schäfer   0,00
  9031   Meier     0,00
  9912   Wolf      0,00
  12121  Richter   0,00
  18316  Müller    0,00
  20204  Fuchs     0,00
  ...
  (11 Zeilen)
  ```

```sql
SELECT m.id,
       m.nachname,
       ISNULL(u.umsatz, 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
WHERE u.id IS NULL;
```

> [!TIP]
> **Anti-Join Best Practice:**
> Bei einem Anti-Join filtert man im `WHERE` stets auf den **Primärschlüssel der rechten Tabelle** (`WHERE u.id IS NULL`). Da ein PK niemals originär `NULL` sein darf, ist garantiert, dass das `NULL` ausschließlich durch das Fehlen einer Verknüpfung im `LEFT JOIN` erzeugt wurde.

---

### 📂 Aufgabe 8.11: Gesamtumsatz pro Mitarbeiter (Gruppierung & `SUM`)

* **Aufgabenstellung:** Überarbeiten Sie die Abfrage aus Aufgabe 8.9. Gruppieren Sie über die Mitarbeiter und geben Sie statt der einzelnen Umsätze die Summe der Umsätze für jeden Mitarbeiter aus. Fehlende Umsätze sollen weiterhin mit 0 angezeigt werden.
* **Join-Pfad:** `Mitarbeiter (m)` $\rightarrow$ `Umsatz (u)` gruppiert nach `m.id, m.nachname`
* **Erwartete Ausgabe (15 Zeilen):**
  ```text
  id     nachname  umsatz
  2581   Kaufmann  100000,00
  5765   Schäfer   0,00
  9031   Meier     0,00
  9912   Wolf      0,00
  10102  Huber     18000,00
  12121  Richter   0,00
  ...
  (15 Zeilen)
  ```

```sql
SELECT m.id,
       m.nachname,
       ISNULL(SUM(u.umsatz), 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY m.id, m.nachname;
```

> [!IMPORTANT]
> **Warum `ISNULL(SUM(...))` statt `SUM(ISNULL(...))`?**
> * Beide Varianten liefern das korrekte Ergebnis `0.00`.
> * **Performance-Unterschied:** `ISNULL(SUM(u.umsatz), 0.00)` führt `ISNULL` genau **einmal pro Mitarbeiter** (15 Aufrufe) aus. `SUM(ISNULL(u.umsatz, 0.00))` muss `ISNULL` für **jede einzelne Zeile vor der Summierung** aufrufen (36 Aufrufe).

---

### 📂 Aufgabe 8.12: Mitarbeiter mit Umsatz < 100.000 € (3VL im `HAVING`)

* **Aufgabenstellung:** Überarbeiten Sie die Abfrage aus Aufgabe 8.11. Zeigen Sie nur die Mitarbeiter an, die weniger als 100.000 Umsatz erreicht haben.
* **Erwartete Ausgabe (13 Zeilen):**
  ```text
  id     nachname  umsatz
  5765   Schäfer   0,00
  9031   Meier     0,00
  9912   Wolf      0,00
  10102  Huber     18000,00
  12121  Richter   0,00
  17000  Krüger    20000,00
  ...
  (13 Zeilen)
  ```

#### 🔹 Variante 1: Mit `ISNULL` im `HAVING` (⭐ Best Practice)
```sql
SELECT m.id,
       m.nachname,
       ISNULL(SUM(u.umsatz), 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY m.id, m.nachname
HAVING ISNULL(SUM(u.umsatz), 0.00) < 100000;
```

#### 🔄 Variante 2: Mit expliziter `OR IS NULL`-Bedingung
```sql
SELECT m.id,
       m.nachname,
       ISNULL(SUM(u.umsatz), 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY m.id, m.nachname
HAVING SUM(u.umsatz) < 100000 
    OR SUM(u.umsatz) IS NULL;
```

> [!CAUTION]
> **Die 2 vs. 13 Zeilen-Falle:**
> Wer nur `HAVING SUM(u.umsatz) < 100000` schreibt, verliert alle 11 Mitarbeiter ohne Umsätze, weil `NULL < 100000` zu `UNKNOWN` evaluiert. Im Ergebnis verbleiben dann fälschlicherweise nur Huber (18.000 €) und Krüger (20.000 €).

---

### 📂 Aufgabe 8.13: Mitarbeiter der Abteilung 2 und deren Umsätze

* **Aufgabenstellung:** Zeigen Sie alle Mitarbeiter der Abteilung 2 mit Id und Nachname an und geben Sie dazu die vom Mitarbeiter getätigten Umsätze aus. Hat der Mitarbeiter noch keine Umsätze getätigt, soll in der Spalte Umsatz eine 0 angezeigt werden.
* **Erwartete Ausgabe:**
  ```text
  id     nachname  umsatz
  2581   Kaufmann  100000,00
  9031   Meier     0,00
  29346  Probst    0,00
  ```

```sql
SELECT m.id,
       m.nachname,
       ISNULL(u.umsatz, 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
WHERE m.abt_id = 2;
```

> [!NOTE]
> **Warum gehört `m.abt_id = 2` ins `WHERE`?**
> `m.abt_id` ist eine Spalte der **linken Tabelle** (`Mitarbeiter`). Wir wollen das Ausgangs-Set der Mitarbeiter strikt auf Abteilung 2 einschränken. Filter auf die linke Tabelle gehören immer in die `WHERE`-Klausel.

---

### 📂 Aufgabe 8.14: Erster und letzter Umsatz pro Mitarbeiter

* **Aufgabenstellung:** Zeigen Sie alle Mitarbeiter mit Id und Nachname an und geben Sie dazu aus, an welchem Tag der Mitarbeiter zum ersten Mal einen Umsatz erzielt hat und wann er zum letzten Mal einen Umsatz erzielt hat.
* **Erwartete Ausgabe (Auszug - 15 Zeilen):**
  ```text
  id     nachname  erster      letzter
  2581   Kaufmann  2019-05-01  2019-05-01
  5765   Schäfer   NULL        NULL
  9031   Meier     NULL        NULL
  9912   Wolf      NULL        NULL
  10102  Huber     2018-10-01  2019-01-01
  12121  Richter   NULL        NULL
  ...
  (15 Zeilen)
  ```

```sql
SELECT m.id,
       m.nachname,
       MIN(u.datum) AS erster,
       MAX(u.datum) AS letzter
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY m.id, m.nachname;
```

> [!TIP]
> **Datums-Aggregation & NULL:**
> `MIN()` und `MAX()` ignorieren `NULL`-Werte. Wenn für einen Mitarbeiter keine Umsätze vorliegen, liefern beide Funktionen automatisch `NULL`. Hier ist kein `ISNULL` erforderlich, da `NULL` fachlich korrekt ausdrückt, dass bisher kein Umsatzdatum existiert.

---

### 📂 Aufgabe 8.15: Mitarbeiter und deren Projektleiter-Projekte

* **Aufgabenstellung:** Listen Sie alle Mitarbeiter mit `id` und `nachname` auf. Zusätzlich soll das Projekt genannt werden, in dem der Mitarbeiter Projektleiter ist. Sollte es kein passendes Projekt geben, soll `'- k. A. -'` statt des Projektnamens angezeigt werden.
* **Join-Pfad:** `Mitarbeiter (m)` $\rightarrow$ `Arbeit (arb)` mit Bedingung `arb.aufgabe = 'Projektleiter'` $\rightarrow$ `Projekt (p)`
* **Erwartete Ausgabe (15 Zeilen):**
  ```text
  id     nachname  projekt
  2581   Kaufmann  Merkur
  5765   Schäfer   Pluto
  9031   Meier     - k. A. -
  9912   Wolf      - k. A. -
  10102  Huber     Apollo
  12121  Richter   - k. A. -
  ...
  (15 Zeilen)
  ```

```sql
SELECT m.id,
       m.nachname,
       ISNULL(p.bezeichnung, '- k. A. -') AS projekt
FROM Mitarbeiter AS m
LEFT JOIN Arbeit AS arb ON m.id = arb.mit_id 
                       AND arb.aufgabe = 'Projektleiter'
LEFT JOIN Projekt AS p ON arb.pro_id = p.id;
```

> [!WARNING]
> **🚨 Die Königsdisziplin: Filterung in der `ON`-Klausel beim Ketten-Join:**
> 1. `AND arb.aufgabe = 'Projektleiter'` in der ersten `ON`-Klausel stellt sicher, dass **nur** Einsätze als Projektleiter gejoint werden. Sachbearbeiter-Einsätze werden ignoriert und führen zu `NULL`.
> 2. Der zweite Join `LEFT JOIN Projekt` knüpft an die `pro_id` an. War der erste Join `NULL`, bleibt auch das Projekt `NULL`.
> 3. `ISNULL(p.bezeichnung, '- k. A. -')` fängt alle `NULL`-Ergebnisse sauber ab.
> 4. Würde `arb.aufgabe = 'Projektleiter'` im `WHERE` stehen, würden alle Nicht-Projektleiter sofort gelöscht und es blieben nur 3 Zeilen übrig!

---

## 🧭 Zusammenfassung & Best-Practice-Leitfaden

```mermaid
flowchart TD
    subgraph Checkliste["Checkliste für OUTER JOIN Abfragen"]
        C1["1. Sollen alle Zeilen der Basis-Tabelle erhalten bleiben? -> LEFT JOIN"]
        C2["2. Filter auf Zusatz-Tabelle einschränken? -> Bedingung in die ON-Klausel!"]
        C3["3. Filter auf Basis-Tabelle einschränken? -> Bedingung in die WHERE-Klausel!"]
        C4["4. Zählen bei LEFT JOIN? -> COUNT(spalte), NIEMALS COUNT(*)"]
        C5["5. Filtern nach Aggregaten im HAVING? -> ISNULL(SUM(...), 0) gegen 3VL!"]
    end
```

### 📋 Schnellübersicht der Tagesbefehle

| Anforderung | SQL-Muster |
| :--- | :--- |
| **Nullwert ersetzen (T-SQL)** | `ISNULL(spalte, ersatzwert)` |
| **Nullwert ersetzen (ANSI-SQL)** | `COALESCE(spalte1, spalte2, ersatzwert)` |
| **Anti-Join (Verwaiste Datensätze)** | `FROM A LEFT JOIN B ON A.id = B.a_id WHERE B.id IS NULL` |
| **Sichere Aggregation bei Outer Join** | `ISNULL(SUM(b.betrag), 0.00)` |
| **Sicheres HAVING bei Outer Join** | `HAVING ISNULL(SUM(b.betrag), 0.00) < 1000` |
| **Bedingter Multi-Table Left Join** | `FROM M LEFT JOIN A ON M.id = A.m_id AND A.typ = 'Chef' LEFT JOIN P ON A.p_id = P.id` |