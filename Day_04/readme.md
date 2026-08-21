# 📅 Day_04: DDL (Data Definition Language) & SQL-Datentypen

## ℹ️ Kurs-Informationen

* **Datum:** Donnerstag, 06.08.2026
* **Arbeitszeit:** 08:15 - 16:00 Uhr
* **Dozent:** Tom S.
* **Autor:** Tobias Boyke

---

## 🎯 Lernziele des Tages

- [x] **DDL-Befehle (Data Definition Language):** Datenbanken, Schemata und Tabellen eigenständig anlegen (`CREATE`), modifizieren (`ALTER`) und löschen (`DROP`).
- [x] **SQL Server Datentypen:** Numerische Typen (`INT`, `TINYINT`, `DECIMAL`), String-Typen (`CHAR`, `VARCHAR`, `NVARCHAR`) und Datums-Typen (`DATE`, `DATETIME2`) optimal wählen.
- [x] **Integritätsbedingungen (Constraints):** `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, `CHECK` und `DEFAULT` direkt im Schema implementieren.
- [x] **Übungsprojekte:** Umsetzung der Projekte *ERM Tab Skript Projekte* und *Tarife Teil 1*.

---

## 📖 Theorie & Konzepte

### 1. DDL – Data Definition Language

DDL-Befehle verwalten die Metadatenstrukturen im RDBMS:

* **`CREATE`:** Erstellt Datenbankobjekte (`CREATE DATABASE`, `CREATE SCHEMA`, `CREATE TABLE`).
* **`ALTER`:** Ändert Strukturen (`ALTER TABLE ... ADD ...`, `ALTER TABLE ... DROP COLUMN ...`).
* **`DROP`:** Löscht Objekte unwiderruflich (`DROP TABLE`, `DROP DATABASE`).

---

### 2. SQL Server Datentypen im Vergleich

| Datentyp | Speicherbedarf | Wertebereich / Zweck | Besonderheit |
| :--- | :--- | :--- | :--- |
| `INT` | 4 Bytes | -2.147.483.648 bis +2.147.483.647 | Standard-Ganzzahl |
| `TINYINT` | 1 Byte | 0 bis 255 | Ideal für Status, Alter, Noten |
| `DECIMAL(p,s)` | Variabel (5–17 B) | Exakte Festkommazahl mit `p` Stellen und `s` Nachkommastellen | **Zwingend für Währungen/Finanzen** |
| `CHAR(n)` | `n` Bytes | Feste Länge, füllt mit Leerzeichen auf | Perfekt für Codes (z. B. `CHAR(2)` für Länder) |
| `VARCHAR(n)` | Tatsächliche Länge + 2B | Variable Länge ohne Unicode | Speicherplatzsparend für ASCII-Texte |
| `NVARCHAR(n)` | $2 \times \text{Länge} + 2\text{B}$ | Variable Länge mit Unicode (UTF-16) | **Für internationale Zeichen & Umlaute** |
| `DATE` | 3 Bytes | `YYYY-MM-DD` (0001-01-01 bis 9999-12-31) | Nur Kalenderdatum ohne Zeit |
| `DATETIME2` | 6–8 Bytes | Datum und hochpräzise Uhrzeit | Moderner Nachfolger des alten `DATETIME` |

---

### 3. Constraints (Integritätsbedingungen)

* **`PRIMARY KEY`:** Eindeutige Identifikation jeder Zeile (impliziert `NOT NULL` und `UNIQUE`).
* **`FOREIGN KEY`:** Gewährleistet referenzielle Integrität zu einer Eltern-Tabelle.
* **`CHECK`:** Validiert Datenwerte vor dem Speichern (z. B. `CHECK (gehalt > 0)`).
* **`DEFAULT`:** Setzt Vorgabewerte bei unvollständigen `INSERT`-Anweisungen.

---

## 📂 Begleitmaterialien & Dokumente

Im Ordner `assets/` stehen die Vorlesungsfolien und Übungsprojekte bereit:
* 📄 **[SQL 01 - Grundlagen.pdf](./assets/SQL%2001%20-%20Grundlagen.pdf):** Einführung in SQL und relationale Syntax.
* 📄 **[SQL 02 - DDL Teil 1.pdf](./assets/SQL%2002%20-%20DDL%20Teil%201.pdf):** DDL-Syntaxhandbuch für Tabellen und Constraints.
* 📄 **[SQL 99 - Datentypen.pdf](./assets/SQL%2099%20-%20Datentypen.pdf):** Detaillierte Übersicht aller SQL Server Datentypen.
* 📄 **[Aufgabe ERM Tab Skript Projekte.pdf](./assets/Aufgabe%20ERM%20Tab%20Skript%20Projekte.pdf):** Modellerstellung und DDL-Skriptierung.
* 📄 **[Aufgabe Tarife - Teil 1.pdf](./assets/Aufgabe%20Tarife%20-%20Teil%201.pdf):** DDL-Szenario zur Tarifverwaltung.

---

## 💻 Praktische Übungen

Die lauffähigen SQL-Skripte befinden sich in `src/`:
* 👉 **[ddl_demo.sql](./src/ddl_demo.sql):** Vollständiges Skript zum Anlegen relationaler Tabellen inklusive Schemata und Integritätsregeln.

---

## 🎓 IHK-Prüfungsrelevanz: DDL

### Frage 1: Warum muss für Geldbeträge `DECIMAL` statt `FLOAT` verwendet werden? (3 Punkte)
> **IHK-Musterantwort:**
> `DECIMAL` ist ein Festkommadatentyp mit exakter numerischer Genauigkeit. `FLOAT` ist ein Gleitkommadatentyp, der Zahlen binär approximiert und zu unkalkulierbaren Rundungsfehlern bei kaufmännischen Berechnungen führen kann.

### Frage 2: Wie lautet der SQL-Befehl zum Hinzufügen einer Spalte `Geburtsdatum` zur Tabelle `Kunde`? (3 Punkte)
```sql
ALTER TABLE Kunde
ADD Geburtsdatum DATE;
```

---

## 💡 Wichtige Notizen
> [!WARNING]
> **Löschreihenfolge beachten:**
> Tabellen, auf die Fremdschlüssel verweisen, können erst gelöscht werden, nachdem die verweisenden Kind-Tabellen gelöscht oder die Fremdschlüssel entfernt wurden.