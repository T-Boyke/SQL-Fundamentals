# 📅 Day_05: DML (Data Manipulation Language) & Datenmanipulation

## ℹ️ Kurs-Informationen

* **Datum:** Freitag, 07.08.2026
* **Arbeitszeit:** 08:15 - 16:00 Uhr
* **Dozent:** Tom S.
* **Autor:** Tobias Boyke

---

## 🎯 Lernziele des Tages

- [x] **DML-Operationen (Data Manipulation Language):** Daten in relationale Tabellen einfügen (`INSERT`), aktualisieren (`UPDATE`) und entfernen (`DELETE`).
- [x] **Vergleich `DELETE` vs. `TRUNCATE TABLE`:** Technische Unterschiede, Transaction Log Verhalten, Triggereinfluss und Identitätsrücksetzung im Detail verstehen.
- [x] **Datenkonsistenz & Integrität bei Manipulationen:** Umgang mit Fremdschlüssel-Einschränkungen und Prüfbedingungen.
- [x] **Übungsprojekt tarifDB:** Vollständiges DDL & DML Refactoring der Tarifdatenbank.

---

## 📖 Theorie & Konzepte

### 1. DML – Data Manipulation Language

* **`INSERT INTO`:** Fügt neue Datensätze ein (immer mit expliziter Spaltenliste arbeiten).
* **`UPDATE`:** Ändert Daten in bestehenden Zeilen (immer mit gezielter `WHERE`-Einschränkung!).
* **`DELETE`:** Löscht Zeilen zeilenweise aus einer Tabelle.

---

### 2. Gegenüberstellung: `DELETE` vs. `TRUNCATE TABLE`

| Kriterium | `DELETE` | `TRUNCATE TABLE` |
| :--- | :--- | :--- |
| **Kategorie** | DML | DDL |
| **Zeilenfilterung** | Mittels `WHERE` gezielt zeilenweise filterbar | Löscht ausnahmslos **alle** Zeilen |
| **Protokollierung** | Zeilenweise im Transaction Log (langsam bei Massendaten) | Gibt nur die Seitenzuweisungen (Extents) frei (extrem schnell) |
| **Triggers** | Feuert `DELETE`-Trigger | Umgeht Trigger vollständig |
| **IDENTITY-Zähler** | Bleibt auf aktuellem Stand | Wird auf Seed-Startwert zurückgesetzt |
| **Fremdschlüssel** | Funktioniert, sofern keine Kind-Datensätze verweisen | Schlägt fehl, wenn Fremdschlüssel auf die Tabelle verweisen |

---

## 📂 Begleitmaterialien & Dokumente

Im Ordner `assets/` stehen die Vorlesungsunterlagen und Übungsdateien bereit:
* 📄 **[SQL 03 - DML Teil 1.pdf](./assets/SQL%2003%20-%20DML%20Teil%201.pdf):** Vorlesungsskript zu DML-Befehlen und Syntaxregeln.
* 📄 **[Aufgabe tarifDB - DDL&DML.sql](./assets/Aufgabe%20tarifDB%20-%20DDL&DML.sql):** Vollständiges DDL/DML-Szenario der Tarifdatenbank.

---

## 💻 Praktische Übungen

Die lauffähigen SQL-Skripte befinden sich in `src/`:
* 👉 **[dml_demo.sql](./src/dml_demo.sql):** Praktische Demonstrationen für `INSERT`, `UPDATE`, `DELETE` und `TRUNCATE`.

---

## 🎓 IHK-Prüfungsrelevanz: DML

### Frage 1: Nennen Sie zwei Unterschiede zwischen `DELETE` und `TRUNCATE TABLE` (4 Punkte)
> **IHK-Musterantwort:**
> 1. `DELETE` erlaubt das gezielte Löschen bestimmter Zeilen mittels einer `WHERE`-Klausel, während `TRUNCATE TABLE` immer alle Zeilen der Tabelle leert.
> 2. `TRUNCATE TABLE` setzt die automatische Zählung (`IDENTITY`) zurück, während `DELETE` den aktuellen Zählerstand beibehält.

### Frage 2: Ein Entwickler möchte ein Datenfeld leeren, nicht jedoch den Datensatz löschen. Welche Anweisung ist korrekt? (3 Punkte)
```sql
UPDATE Mitarbeiter
SET telefon = NULL
WHERE id = 10102;
```

---

## 💡 Wichtige Notizen
> [!CAUTION]
> **Vorsicht vor UPDATE und DELETE ohne WHERE!**
> Beide Anweisungen wirken ohne `WHERE`-Bedingung auf **jeden einzelnen Datensatz** der gesamten Tabelle!