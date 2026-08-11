# 📅 Day_07: SQL Server Indizes & Transaktionen (Theorie & Erklärungen)

## ℹ️ Kurs-Informationen
*   **Datum:** Dienstag, 11.08.2026
*   **Arbeitszeit:** 08:15 - 16:00 Uhr
*   **Dozent:** Tom S.
*   **Autor:** Tobias Boyke

---

## 🎯 Lernziele des Tages
*   Verständnis des physischen Tabellenaufbaus (Heaps vs. Clustered Tables).
*   Unterscheidung zwischen **gruppierten (clustered)** und **ungruppierten (non-clustered)** Indizes.
*   Analyse von Ausführungsplänen: **Index Seek** vs. **Index Scan**.
*   Verständnis des **ACID-Prinzips** bei Transaktionen.
*   Beherrschung der **Transaktions-Isolationsstufen (Isolation Levels)** und deren Verhinderung von Nebenläufigkeitsanomalien.
*   Einblick in das Sperrverhalten (Locking) im SQL Server.

---

## 📖 Theorie & Konzepte

### 🔍 Teil 1: SQL Server Indizes

Ein Index im SQL Server ist eine On-Disk-Struktur, die mit einer Tabelle oder Sicht verknüpft ist und das Abrufen von Zeilen beschleunigt. Ohne Indizes muss der SQL Server die gesamte Tabelle scannen (**Table Scan**), um die gewünschten Daten zu finden.

#### 1. Der B-Tree (Balanced Tree)
SQL Server organisiert Indizes als **B-Bäume** (ausgeglichene Bäume). Ein B-Baum besteht aus:
*   **Root Node (Wurzelknoten):** Der Einstiegspunkt für Suchabfragen.
*   **Intermediate Nodes (Zwischenknoten):** Leiten die Suche auf die nächste Ebene weiter.
*   **Leaf Nodes (Blattknoten):** Die unterste Ebene, die entweder die tatsächlichen Datenzeilen (beim Clustered Index) oder Zeilenzeiger auf die Daten (beim Non-Clustered Index) enthält.

```
                  +-------------------+
                  |    Root Node      |
                  +---------+---------+
                            |
            +---------------+---------------+
            |                               |
  +---------v---------+           +---------v---------+
  | Intermediate Node |           | Intermediate Node |
  +----+---------+----+           +----+---------+----+
       |         |                     |         |
  +----v----+ +--v------+         +----v----+ +--v------+
  | Leaf 1  | | Leaf 2  |         | Leaf 3  | | Leaf 4  |
  +---------+ +---------+         +---------+ +---------+
```

---

#### 2. Gruppierter Index (Clustered Index)
*   **Physische Ordnung:** Ein gruppierter Index sortiert und speichert die Datenzeilen in der Tabelle physisch basierend auf dem Indexschlüssel.
*   **Einzigartigkeit:** Da die Daten selbst nur in einer Reihenfolge sortiert sein können, kann es **nur einen einzigen** gruppierten Index pro Tabelle geben.
*   **Blattknoten:** Die Blattknoten des gruppierten Index enthalten die **tatsächlichen Datenzeilen** der Tabelle.
*   **Heap:** Eine Tabelle ohne gruppierten Index wird als **Heap** bezeichnet. In einem Heap sind die Daten unsortiert (Einfügereihenfolge).
*   **Standardverhalten:** Wenn ein Primärschlüssel (`PRIMARY KEY`) erstellt wird, erzeugt SQL Server automatisch einen gruppierten Index auf dieser Spalte (sofern nicht explizit anders angegeben).

---

#### 3. Ungruppierter Index (Non-Clustered Index)
*   **Separate Struktur:** Ein ungruppierter Index ist völlig getrennt von den eigentlichen Datenzeilen organisiert. Er enthält die Indexschlüssel und einen Zeiger auf die Datenzeile.
*   **Blattknoten:** Die Blattknoten eines ungruppierten Index enthalten:
    *   Den **Clustered Index Key (Lokalisierungsschlüssel)**, falls die Tabelle einen gruppierten Index besitzt.
    *   Einen **RID (Row Identifier)** (bestehend aus File ID, Page ID und Slot Nummer), falls die Tabelle ein Heap ist.
*   **Vielzahl:** Es können bis zu 999 ungruppierte Indizes pro Tabelle angelegt werden.
*   **Covering Index (Abdeckender Index):** Wenn ein ungruppierter Index alle in der `SELECT`-Klausel angeforderten Spalten enthält (z. B. durch das Schlüsselwort `INCLUDE`), muss SQL Server nicht auf die eigentliche Tabelle zugreifen (vermeidet **Key Lookup** oder **RID Lookup**).

---

#### 4. Index Seek vs. Index Scan
Beim Lesen von Ausführungsplänen ist es wichtig, diese beiden Operationen zu unterscheiden:
*   **Index Seek:** Der SQL Server nutzt den B-Baum des Index, um direkt zu den spezifischen Zeilen zu springen, die den Suchkriterien entsprechen. Dies ist hocheffizient (O(log N)).
*   **Index Scan:** Der SQL Server liest den gesamten Index von Anfang bis Ende. Dies tritt auf, wenn keine einschränkende `WHERE`-Bedingung vorhanden ist oder die Bedingung SARGable (Search Argumentable) verletzt (z. B. durch Funktionen auf der indizierten Spalte). Es ist meist langsamer als ein Seek, aber immer noch schneller als ein Table Scan, da ein Index meist schmaler als die Tabelle ist.

---

### 💾 Teil 2: Transaktionen & ACID-Prinzip

Eine Transaktion ist eine logische Arbeitseinheit, die eine Reihe von Operationen (meist DML-Befehle wie `INSERT`, `UPDATE`, `DELETE`) zusammenfasst.

#### 1. Das ACID-Prinzip
Jede Transaktion im SQL Server muss die ACID-Eigenschaften erfüllen:
*   **A - Atomicity (Atomarität / Unteilbarkeit):** "Ganz oder gar nicht." Entweder werden alle Operationen der Transaktion erfolgreich ausgeführt, oder keine einzige (wird bei Fehler per `ROLLBACK` zurückgesetzt).
*   **C - Consistency (Konsistenz):** Eine Transaktion überführt die Datenbank von einem konsistenten Zustand in einen anderen konsistenten Zustand. Constraints (z. B. Foreign Keys) werden am Ende der Transaktion erzwungen.
*   **I - Isolation (Isolation):** Transaktionen, die gleichzeitig ausgeführt werden, dürfen sich gegenseitig nicht stören. Die Zwischenstände einer Transaktion sind für andere Transaktionen unsichtbar.
*   **D - Durability (Dauerhaftigkeit):** Sobald eine Transaktion mit `COMMIT` bestätigt wurde, sind die Änderungen dauerhaft in der Datenbank gespeichert (selbst bei einem anschließenden Stromausfall oder Servercrash dank des Transaction Logs).

---

#### 2. Nebenläufigkeitsanomalien (Concurrency Anomalies)
Wenn mehrere Benutzer gleichzeitig auf dieselben Daten zugreifen, können ohne ausreichende Isolation folgende Probleme auftreten:
1.  **Dirty Read (Schmutziges Lesen):** Transaktion A ändert eine Zeile. Transaktion B liest diese Zeile, bevor Transaktion A ein `COMMIT` oder `ROLLBACK` ausführt. Macht Transaktion A ein `ROLLBACK`, hat Transaktion B ungültige ("schmutzige") Daten gelesen.
2.  **Non-Repeatable Read (Nicht-wiederholbares Lesen):** Transaktion A liest eine Zeile. Transaktion B ändert oder löscht diese Zeile und committet. Transaktion A liest dieselbe Zeile erneut und erhält andere Werte (oder die Zeile ist weg).
3.  **Phantom Read (Phantom-Lesen):** Transaktion A liest eine Menge von Zeilen, die eine bestimmte Bedingung erfüllen. Transaktion B fügt eine neue Zeile ein, die diese Bedingung ebenfalls erfüllt, und committet. Transaktion A führt dieselbe Abfrage erneut aus und sieht plötzlich eine "Phantomzeile".
4.  **Lost Update (Verlorenes Update):** Zwei Transaktionen lesen dieselbe Zeile, berechnen einen neuen Wert und schreiben ihn zurück. Das Update der ersten Transaktion wird durch das Update der zweiten überschrieben.

---

#### 3. Transaktions-Isolationsstufen (Isolation Levels)
Die Isolationsstufe bestimmt, wie stark Transaktionen voneinander isoliert sind. SQL Server unterstützt folgende Stufen:

| Isolation Level | Dirty Read | Non-Repeatable Read | Phantom Read | Sperrmechanismus / Implementierung |
| :--- | :---: | :---: | :---: | :--- |
| **READ UNCOMMITTED** | ❌ (erlaubt) | ❌ (erlaubt) | ❌ (erlaubt) | Keine Lesesperren. Entspricht dem Tabellen-Hint `WITH (NOLOCK)`. |
| **READ COMMITTED** *(Default)* |  | ❌ (erlaubt) | ❌ (erlaubt) | Setzt kurzfristige Lesesperren, die nach dem Lesen der Zeile sofort freigegeben werden. |
| **REPEATABLE READ** |  |  | ❌ (erlaubt) | Hält Lesesperren auf den gelesenen Zeilen bis zum Ende der gesamten Transaktion. |
| **SERIALIZABLE** |  |  |  | Setzt Bereichssperren (Range Locks) auf Schlüsselbereiche, um das Einfügen neuer Zeilen zu blockieren. |
| **SNAPSHOT** |  |  |  | Verwendet Zeilenversionsverwaltung (Row Versioning) in `tempdb`. Leser blockieren keine Schreiber, Schreiber blockieren keine Leser. |

---

---

#### 4. Locking (Sperren) im SQL Server
SQL Server steuert den konkurrierenden Zugriff über Sperren (Locks):
*   **Shared Locks (S - Gemeinsame Sperren):** Werden für Leseoperationen (`SELECT`) verwendet. Mehrere Transaktionen können gleichzeitig ein S-Lock auf derselben Ressource halten.
*   **Exclusive Locks (X - Exklusive Sperren):** Werden für Schreiboperationen (`INSERT`, `UPDATE`, `DELETE`) verwendet. Verhindert jeglichen anderen Zugriff (weder Lesen noch Schreiben) auf die gesperrte Ressource.
*   **Intent Locks (I - Absichts-Sperren):** Zeigen an, dass eine Transaktion auf einer niedrigeren Ebene (z.B. Zeilenebene) eine Sperre hält. Verhindert, dass eine andere Transaktion eine grobe Sperre (z.B. Tabellensperre) anfordert, die mit den feineren Sperren kollidieren würde (z.B. Intent Exclusive `IX` oder Intent Shared `IS`).
*   **Deadlock:** Ein Deadlock tritt auf, wenn zwei Transaktionen gegenseitig Sperren halten, die die jeweils andere benötigt, um fortzufahren. SQL Server erkennt Deadlocks automatisch, beendet eine der beiden Transaktionen als "Deadlock Victim" und führt ein automatisches Rollback durch.

---

### 🛠️ Teil 3: TRY...CATCH & Die Rolle der tempdb in Transaktionen

In professionellen Datenbankanwendungen wird Transaktionssicherheit meist mit strukturierter Ausnahmebehandlung (`TRY...CATCH`) kombiniert und nutzt spezielle Speicher- und Protokollmechanismen in `tempdb`.

#### 1. Robustes Exception-Handling mit `XACT_STATE()`
Klassisches Fehler-Handling prüft oft nur `@@TRANCOUNT`. Bei schwerwiegenden Fehlern kann eine Transaktion jedoch in einen **uncommittbaren Zustand (doomed transaction)** übergehen. Jede Aktion außer einem Rollback führt dann zu Fehlern.

Die Funktion `XACT_STATE()` liefert verlässliche Auskunft über den Zustand:
*   **`1` (Active/Committable):** Die Transaktion ist aktiv und gesund. Sie kann committet oder zurückgerollt werden.
*   **`-1` (Active/Uncommittable):** Die Transaktion ist aktiv, aber beschädigt (doomed). Ein Commit ist unmöglich. Die einzige erlaubte Operation ist `ROLLBACK TRANSACTION`.
*   **`0` (No Transaction):** Es ist keine aktive Transaktion vorhanden. Ein Aufruf von `ROLLBACK` würde fehlschlagen.

> [!IMPORTANT]
> **Safe-Rollback Pattern im CATCH-Block:**
> ```sql
> BEGIN CATCH
>     IF (XACT_STATE()) = -1 OR (XACT_STATE()) = 1
>     BEGIN
>         ROLLBACK TRANSACTION;
>     END
>     -- Fehler protokollieren
> END CATCH
> ```

#### 2. Die Rolle von `tempdb` bei Transaktionen
Die Systemdatenbank `tempdb` ist das Arbeitstier des SQL Servers und spielt eine tragende Rolle bei Transaktionen:
*   **Temporäre Tabellen (`#` und `##`):** Wenn du temporäre Tabellen erstellst und innerhalb von Transaktionen manipulierst, werden alle Änderungen im Transaction Log von `tempdb` mitgeschrieben. Auch hier gelten ACID-Garantien (inkl. Rollbacks), die Daten werden jedoch physisch in `tempdb` gehalten und bei Sitzungsende automatisch verworfen.
*   **Der Version Store (Zeilenversionierung):**
    *   Bei optimistischen Isolationsstufen wie `SNAPSHOT` kopiert SQL Server die Datenzeile *vor* dem Update in den **Version Store** der `tempdb`.
    *   Leser greifen auf diese Versionen in `tempdb` zu, ohne Lesesperren auf der Haupttabelle zu setzen. Dadurch blockieren Schreiber keine Leser mehr.
    *   *Nachteil:* Erhöhte I/O-Last und starker Platzbedarf auf der `tempdb` Festplatte.

---

## 💻 Praktische Übungen

Die SQL-Skripte im Ordner `src/` enthalten praktische Beispiele zur Demonstration:
1.  **[index_demo.sql](./src/index_demo.sql):** Vergleich von Heaps mit indizierten Tabellen, Erstellung von Clustered & Non-Clustered Indizes, Demonstration von Index Seeks, Scans und Key Lookups.
2.  **[transaction_demo.sql](./src/transaction_demo.sql):** Aufbau von ACID-Transaktionen mit `BEGIN TRAN`, `COMMIT` und `ROLLBACK`.
3.  **[try_catch_tempdb.sql](./src/try_catch_tempdb.sql):** Robustes Transaktions-Error-Handling in der `tempdb` unter Verwendung von temporären Tabellen und `XACT_STATE()`.
4.  **[isolation_levels.sql](./src/isolation_levels.sql):** Demonstration von Dirty Reads, Non-Repeatable Reads und wie man diese durch Ändern des `TRANSACTION ISOLATION LEVEL` verhindert.

---

## 💡 Wichtige Notizen

> [!IMPORTANT]
> **Vorsicht bei Indizes auf schreibintensiven Tabellen:**  
> Jeder ungruppierte Index beschleunigt `SELECT`-Abfragen, verlangsamt jedoch `INSERT`-, `UPDATE`- und `DELETE`-Befehle, da SQL Server bei jeder Schreiboperation auch die Indexbäume anpassen und pflegen muss. Indizes müssen daher wohlüberlegt sein!

> [!WARNING]
> **Gefahr von `READ UNCOMMITTED` / `NOLOCK`:**  
> Obwohl `READ UNCOMMITTED` die Performance maximiert, da keine Sperren gesetzt werden und Leseoperationen niemals blockiert werden, kann dies zu schwerwiegenden Fehlentscheidungen in Geschäftslogiken führen, wenn unbestätigte (und später zurückgesetzte) Daten verarbeitet werden.