# 📅 Day_04: DDL (Data Definition Language) & SQL-Datentypen

## ℹ️ Kurs-Informationen
*   **Datum:** Donnerstag, 06.08.2026
*   **Arbeitszeit:** 08:15 - 16:00 Uhr
*   **Dozent:** Tom S.
*   **Autor:** Tobias Boyke

---

## 🎯 Lernziele des Tages
*   Datenbanken, Schemata und Tabellen eigenständig anlegen, ändern und löschen können.
*   Die wichtigsten SQL Server Datentypen kennen und passend auswählen.
*   Einschränkungen (Constraints) wie `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `CHECK` und `DEFAULT` sicher implementieren.

---

## 📖 Theorie & Konzepte

### 1. DDL – Data Definition Language
DDL umfasst Befehle zur Definition und Strukturierung des Datenbankschemas. DDL-Operationen arbeiten auf der Metadatenebene und verändern nicht den Inhalt (Daten) der Tabellen:

*   **`CREATE`:** Erstellt neue Datenbankobjekte (z. B. `CREATE DATABASE`, `CREATE SCHEMA`, `CREATE TABLE`).
*   **`ALTER`:** Ändert die Struktur bestehender Objekte (z. B. Spalte hinzufügen mit `ALTER TABLE ... ADD ...`).
*   **`DROP`:** Löscht Objekte unwiderruflich (z. B. `DROP TABLE`).

---

### 2. SQL Server Datentypen (Auswahl)
Die Wahl des richtigen Datentyps ist entscheidend für Speicherplatz und Performance:

#### Numerische Datentypen
*   **`INT`:** Ganzzahlen von -2 Mrd. bis +2 Mrd. (4 Bytes).
*   **`TINYINT`:** Ganzzahlen von 0 bis 255 (1 Byte). Perfekt für Alter, Status oder Noten.
*   **`DECIMAL(p,s)` / `NUMERIC`:** Festkommazahlen mit exakter Präzision `p` (Gesamtstellen) und Skalierung `s` (Nachkommastellen). Zwingend für Geldbeträge (z. B. `DECIMAL(10,2)`).

#### Zeichenketten (Strings)
*   **`CHAR(n)`:** Feste Länge. Füllt nicht genutzte Zeichen mit Leerzeichen auf. Gut für Fixcodes (z. B. Länderkürzel `CHAR(2)`).
*   **`VARCHAR(n)`:** Variable Länge. Verbraucht nur so viel Speicher wie Text eingegeben wurde.
*   **`NVARCHAR(n)`:** Variable Länge mit Unicode-Unterstützung (speichert internationale Zeichen wie Umlaute, asiatische Schriftzeichen). Verdoppelt den Speicherbedarf pro Zeichen!
*   **`MAX`:** Zusatz für `VARCHAR`/`NVARCHAR` für unbegrenzten Text (bis zu 2 GB).

#### Datum & Zeit
*   **`DATE`:** Nur das Datum (YYYY-MM-DD).
*   **`DATETIME2`:** Datum und Uhrzeit mit hoher Präzision. Nachfolger des alten `DATETIME`.

---

### 3. Constraints (Integritätsbedingungen)
Constraints sichern die Datenqualität direkt in der Datenbank:
*   **`NOT NULL`:** Verhindert, dass leere Werte in die Spalte eingetragen werden.
*   **`UNIQUE`:** Garantiert, dass jeder Wert in dieser Spalte nur einmal in der Tabelle vorkommt.
*   **`PRIMARY KEY`:** Identifiziert jede Zeile eindeutig (impliziert `NOT NULL` und `UNIQUE`).
*   **`FOREIGN KEY`:** Sichert die referenzielle Integrität zu einer anderen Tabelle.
*   **`CHECK`:** Validiert Werte vor dem Speichern anhand eines logischen Ausdrucks (z. B. `CHECK (Gehalt > 0)`).
*   **`DEFAULT`:** Setzt einen Standardwert, falls beim Einfügen kein Wert angegeben wurde.

---

## 💻 Praktische Übungen
Die SQL-Skripte im Ordner `src/` enthalten praktische Beispiele zur Demonstration:
1.  **[ddl_demo.sql](./src/ddl_demo.sql):** Vollständiges Skript zum Erstellen einer Übungsdatenbank, inklusive Schemata, Tabellen mit Constraints und Validierungen.

---

### 🎓 IHK-Prüfungsrelevanz: DDL

#### Frage 1: Welchen Datentyp wählen Sie für Spalten, die Geldbeträge speichern (z. B. Preise oder Salden), und warum? (3 Punkte)
> **IHK-Musterantwort:**
> Es sollte der Datentyp `DECIMAL` (oder `NUMERIC`) gewählt werden, da es sich um einen Festkommadatentyp handelt. Dieser speichert Zahlen mit exakter mathematischer Präzision ohne Rundungsfehler, im Gegensatz zu Fließkommadatentypen wie `FLOAT` oder `REAL`.

#### Frage 2: Schreiben Sie den SQL-Befehl, um eine bestehende Tabelle `Kunden` um das Feld `Geburtsdatum` (nur Datum) zu erweitern (3 Punkte)
> **IHK-Musterantwort:**
> ```sql
> ALTER TABLE Kunden
> ADD Geburtsdatum DATE;
> ```

---

## 💡 Wichtige Notizen
> [!WARNING]
> **Reihenfolge beim Löschen beachten!**
> Wenn Tabellen über Fremdschlüssel (`FOREIGN KEY`) verknüpft sind, können die referenzierten Tabellen (die "Eltern"-Tabellen) nicht gelöscht werden, solange die verweisenden Tabellen (die "Kind"-Tabellen) noch existieren. SQL Server blockiert dies mit einer Fehlermeldung. Man muss Kind-Tabellen immer vor Eltern-Tabellen löschen!