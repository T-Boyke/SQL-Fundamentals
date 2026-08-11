# 🎓 Day_10: Erste Leistungsüberprüfung (Klausur I)

## ℹ️ Kurs-Informationen
*   **Datum:** Freitag, 14.08.2026
*   **Arbeitszeit:** 08:15 - 16:00 Uhr
*   **Dozent:** Tom S.
*   **Autor:** Tobias Boyke

---

## 🎯 Tagesziel & Ablauf
Heute findet die **erste Klausur** des SQL-Moduls statt. 
*   **Ablauf:**
    1.  **08:15 - 09:00 Uhr:** Letzte Fragen & Warm-up.
    2.  **Ab ca. 09:15 Uhr:** Start der Leistungsüberprüfung.
    3.  **Nachmittag:** Besprechung der Ergebnisse, Feedback und Ausblick auf Woche 3.

---

## 📚 Klausurrelevante Themen (Woche 1 & 2)

Zur Wiederholung und Selbstkontrolle sind hier alle Kernkompetenzen aufgeführt, die in den ersten 10 Tagen erarbeitet wurden:

### 🌐 1. Relationales Datenmodell & Grundlagen
*   **Konzepte:** Tabellen, Attribute, Datentypen.
*   **Integrität:** Primärschlüssel (`PRIMARY KEY`), Fremdschlüssel (`FOREIGN KEY`), Nullwerte (`NULL` vs. `NOT NULL`).
*   **Kardinallitäten:** 1:1, 1:n, n:m Beziehungen (und deren Auflösung über Zwischentabellen).

### 🔍 2. DQL (Data Query Language - Abfragen)
*   **Grundstruktur:** `SELECT ... FROM ... WHERE ... ORDER BY ...`
*   **Operatoren:** `LIKE` (Wildcards `%`, `_`), `BETWEEN`, `IN`, `AND`, `OR`, `NOT`, `IS NULL`.
*   **Aggregationen:** `SUM()`, `AVG()`, `COUNT()`, `MIN()`, `MAX()`.
*   **Gruppierung:** `GROUP BY` zur Aggregat-Bildung und `HAVING` zur Filterung aggregierter Werte (wichtig: Unterschied zu `WHERE`!).
*   **Joins:** 
    *   `INNER JOIN` (nur Schnittmengen).
    *   `LEFT JOIN` / `RIGHT JOIN` (inklusive verwaister Datensätze der linken/rechten Tabelle).
    *   `FULL OUTER JOIN` (Vereinigung aller Zeilen).
*   **Unterabfragen (Subqueries):** Unkorrelierte vs. korrelierte Subqueries, Verwendung von `IN`, `EXISTS`.

### ✏️ 3. DML & DDL (Datenmanipulation & Definition)
*   **DML:** `INSERT INTO ... VALUES`, `UPDATE ... SET ... WHERE`, `DELETE FROM ... WHERE` (Achtung vor dem Löschen ohne `WHERE`!).
*   **DDL:** `CREATE TABLE`, `ALTER TABLE` (Spalten hinzufügen/ändern), `DROP TABLE`.

### ⚡ 4. SQL Server Indizes (Day_07)
*   **Clustered Index:** Sortiert Daten physisch auf der Festplatte. Max. 1 pro Tabelle. Blattknoten enthalten die Datenzeilen.
*   **Non-Clustered Index:** Separate Suchstruktur. Blattknoten enthalten Suchschlüssel und Datenzeiger.
*   **Ausführungspläne:** Erkennen von *Index Seek* (optimal) vs. *Index Scan* (teilweise ineffizient) vs. *Table Scan* (schlecht).
*   **Lookup-Vermeidung:** Funktionsweise eines abdeckenden Index (*Covering Index* mit `INCLUDE`).

### 🔒 5. Transaktionen & ACID (Day_07)
*   **ACID-Eigenschaften:** Atomarität, Konsistenz, Isolation, Dauerhaftigkeit.
*   **Syntax:** `BEGIN TRAN`, `COMMIT TRAN`, `ROLLBACK TRAN`.
*   **Anomalien:** Dirty Read, Non-Repeatable Read, Phantom Read.
*   **Isolationsstufen:** `READ UNCOMMITTED`, `READ COMMITTED`, `REPEATABLE READ`, `SERIALIZABLE`.

---

## 💡 Tipps für die Klausur
1.  **SQL-Schlüsselwörter groß schreiben:** Erhöht die Lesbarkeit enorm (z.B. `SELECT`, `FROM`, `WHERE`).
2.  **Klammerung bei komplexen WHERE-Bedingungen:** Lieber einmal mehr klammern bei `AND`/`OR`-Kombinationen, um logische Fehler zu vermeiden.
3.  **Fehlermeldungen genau lesen:** SQL Server gibt oft präzise Hinweise auf Syntaxfehler (z. B. fehlendes Komma oder falsche Tabellennamen).
4.  **Ausführungspläne nutzen:** Wenn Performance bewertet wird, vor Abgabe prüfen, ob Indizes wie erwartet greifen.

---

## 📝 Persönliche Notizen zur Klausur
*Hier können nach der Klausur Fragen, knifflige Aufgaben und Lösungen notiert werden.*