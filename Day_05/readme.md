# 📅 Day_05: DML (Data Manipulation Language) & Datenmanipulation

## ℹ️ Kurs-Informationen
*   **Datum:** Freitag, 07.08.2026
*   **Arbeitszeit:** 08:15 - 16:00 Uhr
*   **Dozent:** Tom S.
*   **Autor:** Tobias Boyke

---

## 🎯 Lernziele des Tages
*   Daten in relationale Tabellen einfügen (`INSERT`), ändern (`UPDATE`) und löschen (`DELETE`) können.
*   Den Unterschied zwischen `DELETE` und `TRUNCATE TABLE` im Detail kennen und begründen können.
*   Datenabfragen zur Kontrolle der manipulierten Zeilen durchführen.

---

## 📖 Theorie & Konzepte

### 1. DML – Data Manipulation Language
DML umfasst Befehle zur Arbeit *mit* den Daten, die sich in den Tabellenstrukturen befinden. DML-Befehle lesen und manipulieren Datensätze:

*   **`INSERT`:** Fügt neue Zeilen (Tupel) in eine Tabelle ein.
*   **`UPDATE`:** Ändert Werte in bestehenden Zeilen einer Tabelle.
*   **`DELETE`:** Löscht Zeilen aus einer Tabelle.
*   **`SELECT`:** Ruft Daten ab (oft auch der DQL - Data Query Language zugeordnet).

---

### 2. DML Befehlssyntax & Best Practices

#### INSERT INTO (Daten einfügen)
Es ist bewährte Praxis, Spaltennamen beim Einfügen explizit anzugeben, um Fehler bei späteren Schemaänderungen zu verhindern.
```sql
-- Sicherer Einfügevorgang mit expliziter Spaltenliste
INSERT INTO Schule.Schueler (Name, [Alter], Email)
VALUES ('Tobias Boyke', 25, 'tobias@example.com');
```

#### UPDATE (Daten ändern)
> [!CAUTION]
> **Vorsicht bei `UPDATE` ohne `WHERE`-Klausel!**  
> Vergisst man die `WHERE`-Klausel bei einem `UPDATE`, ändert SQL Server die Werte in **allen** Zeilen der gesamten Tabelle unwiderruflich!

```sql
-- Aktualisiert nur das Alter des spezifischen Schülers
UPDATE Schule.Schueler
SET [Alter] = 26
WHERE SchuelerID = 1;
```

---

### 3. Gegenüberstellung: `DELETE` vs. `TRUNCATE TABLE`
Beide Befehle entfernen Daten aus einer Tabelle, unterscheiden sich jedoch grundlegend in Arbeitsweise und Performance:

| Kriterium | `DELETE` | `TRUNCATE TABLE` |
| :--- | :--- | :--- |
| **Befehlsart** | DML (Data Manipulation Language) | DDL (Data Definition Language) |
| **Selektivität** | Zeilenweise Löschung über `WHERE` möglich. | Löscht immer **alle** Zeilen der gesamten Tabelle. |
| **Protokollierung** | Jede gelöschte Zeile wird einzeln im Transaction Log protokolliert (langsam bei großen Datenmengen). | Protokolliert nur die Freigabe der Datenseiten (Extents) (extrem schnell). |
| **Triggers** | Aktiviert `DELETE`-Trigger. | Ignoriert und umgeht Trigger vollständig. |
| **Identitätsspalte** | Setzt den Auto-Inkrement (`IDENTITY`)-Zähler **nicht** zurück. | Setzt den `IDENTITY`-Zähler wieder auf den Startwert zurück. |
| **Einschränkung** | Kann ausgeführt werden, wenn Fremdschlüssel verweisen (solange diese Zeilen nicht referenziert werden). | Schlägt fehl, wenn Fremdschlüssel (`FOREIGN KEY`) von anderen Tabellen auf die Tabelle verweisen. |

---

## 💻 Praktische Übungen
Die SQL-Skripte im Ordner `src/` enthalten praktische Beispiele zur Demonstration:
1.  **[dml_demo.sql](./src/dml_demo.sql):** Befüllt die in Day_04 angelegten Tabellen, führt Aktualisierungen und Löscharbeiten aus und demonstriert die Verhaltensunterschiede der Befehle.

---

### 🎓 IHK-Prüfungsrelevanz: DML

#### Frage 1: Nennen Sie zwei wesentliche Unterschiede zwischen den SQL-Befehlen `DELETE` und `TRUNCATE TABLE` (4 Punkte)
> **IHK-Musterantwort:**
> 1. **Selektivität:** `DELETE` erlaubt das gezielte Löschen bestimmter Zeilen mittels einer `WHERE`-Klausel, während `TRUNCATE TABLE` immer alle Zeilen der Tabelle unwiderruflich löscht.
> 2. **Auto-Inkrement:** `TRUNCATE TABLE` setzt den Identitätszähler (`IDENTITY`) einer Tabelle auf den Startwert zurück, während `DELETE` den Zählerstand beibehält.

#### Frage 2: Ein Datenbankadministrator möchte eine Tabelle mit 10 Millionen Zeilen leeren. Welchen Befehl sollte er wählen? (3 Punkte)
> **Sachverhalt:** Die Tabelle hat keine Fremdschlüsselverbindungen oder Trigger.
> **IHK-Musterantwort:**
> Er sollte `TRUNCATE TABLE` wählen. Da dieser Befehl die Datenfreigabe auf Seitenebene (und nicht zeilenweise) im Transaction Log aufzeichnet, verbraucht er deutlich weniger Systemressourcen und läuft um ein Vielfaches schneller als ein `DELETE`-Befehl.

---

## 💡 Wichtige Notizen
> [!TIP]
> **Transaktionsschutz bei DML:**
> Da DML-Operationen (`INSERT`, `UPDATE`, `DELETE`) die Daten direkt verändern, sollten sie bei komplexen Logiken immer in Transaktionsblöcken (`BEGIN TRAN ... COMMIT / ROLLBACK`) gekapselt werden, um Datenverlust bei Fehlern zu vermeiden.