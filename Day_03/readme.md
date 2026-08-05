# 📅 Day_03: Normalisierung & Datenbankanomalien (1NF, 2NF, 3NF)

## ℹ️ Kurs-Informationen
*   **Datum:** Mittwoch, 05.08.2026
*   **Arbeitszeit:** 08:15 - 16:00 Uhr
*   **Dozent:** Tom S.
*   **Autor:** Tobias Boyke

---

## 🎯 Lernziele des Tages
*   Datenbank-Anomalien (Einfüge-, Änderungs- und Lösch-Anomalien) erkennen und erklären können.
*   Die Kriterien der 1., 2. und 3. Normalform (NF) beherrschen.
*   Eine unnormalisierte Tabelle schrittweise in die 3. Normalform überführen können.

---

## 📖 Theorie & Konzepte

### 1. Warum Normalisierung? (Datenanomalien)
Unter **Normalisierung** versteht man die Aufteilung von Tabellen zur Reduzierung von Redundanzen (doppelten Daten). Unnormalisierte Tabellen führen zu schwerwiegenden Fehlern bei Datenmanipulationen:

*   **Redundanz:** Gleiche Daten werden mehrfach gespeichert (z. B. die Adresse eines Kunden bei jeder Bestellung). Verbraucht Speicher und verlangsamt Abfragen.
*   **Einfüge-Anomalie (Insert Anomaly):** Daten können nicht eingefügt werden, weil andere Daten fehlen. Z. B. kann kein neuer Kurs eingepflegt werden, solange sich kein Schüler dafür angemeldet hat (wenn SchülerID und KursID gemeinsam der Primärschlüssel sind).
*   **Änderungs-Anomalie (Update Anomaly):** Wird eine Information (z. B. der Name eines Kunden) geändert, muss dies an mehreren Stellen gleichzeitig geschehen. Wird eine Zeile vergessen, ist der Datenbestand inkonsistent.
*   **Lösch-Anomalie (Delete Anomaly):** Beim Löschen eines Datensatzes gehen ungewollt andere wichtige Informationen verloren. Z. B. wird der letzte Schüler eines Kurses gelöscht und dadurch geht auch die Information verloren, dass der Kurs existiert und wer ihn leitet.

---

### 2. Die drei Normalformen (1NF, 2NF, 3NF)

#### 1. Normalform (1NF)
> Eine Tabelle befindet sich in der 1. Normalform, wenn alle Attribute **atomare** (unteilbare) Werte aufweisen und die Tabelle einen **Primärschlüssel** besitzt. Keine Wiederholungsgruppen oder Listen in einer Zelle.

#### 2. Normalform (2NF)
> Eine Tabelle befindet sich in der 2. Normalform, wenn sie in der **1. Normalform** ist und jedes Nicht-Schlüsselfeld vom **gesamten** Primärschlüssel voll funktional abhängig ist.
*   *Relevanz:* Betrifft nur Tabellen mit zusammengesetzten Primärschlüsseln. Attribute, die nur von einem *Teil* des Schlüssels abhängen, müssen in eine eigene Tabelle ausgelagert werden.

#### 3. Normalform (3NF)
> Eine Tabelle befindet sich in der 3. Normalform, wenn sie in der **2. Normalform** ist und **keine transitiven Abhängigkeiten** vorliegen. Nicht-Schlüsselfelder dürfen nicht von anderen Nicht-Schlüsselfeldern abhängen.

---

### 3. Schritt-für-Schritt-Beispiel zur Normalisierung

#### Ausgangszustand: Unnormalisierte Tabelle (UNF)

| **<u>SchülerID</u>** | **SchülerName** | **ProjektID** | **ProjektName** | **ProjektLeiter** | **Note** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 100 | Tobias, Max | P01 | SQL, Java | Tom S., Herr M. | 1, 2 |

#### Schritt 1: Überführung in die 1. Normalform (Atomisierung)
*Listen werden aufgelöst, jede Zelle enthält nur einen Wert. Primärschlüssel wird zusammengesetzt: `(SchülerID, ProjektID)`.*

##### Tabelle: SchülerProjekte_1NF

| **<u>SchülerID</u>** | **<u>ProjektID</u>** | **SchülerName** | **ProjektName** | **ProjektLeiter** | **Note** |
| :--- | :---: | :--- | :--- | :--- | :---: |
| 100 | P01 | Tobias | SQL | Tom S. | 1 |
| 100 | P02 | Max | Java | Herr M. | 2 |

#### Schritt 2: Überführung in die 2. Normalform (Teilabhängigkeiten eliminieren)
*Die Note hängt vom gesamten Schlüssel ab (Wer hat in welchem Projekt welche Note?). Aber:*
*   *`SchülerName` hängt nur von `SchülerID` ab.*
*   *`ProjektName` und `ProjektLeiter` hängen nur von `ProjektID` ab.*
*   *Lösung:* Aufteilung in drei Tabellen.

*   **Tabelle A: Schüler (SchülerID [PK], SchülerName)**
*   **Tabelle B: Projekte (ProjektID [PK], ProjektName, ProjektLeiter)**
*   **Tabelle C: SchülerProjektNoten (SchülerID [PK, FK], ProjektID [PK, FK], Note)**

#### Schritt 3: Überführung in die 3. Normalform (Transitive Abhängigkeiten eliminieren)
*In der Tabelle `Projekte` hängt `ProjektLeiter` transitiv vom `ProjektName` ab (bzw. ist eine eigene Entität mit eigenen Attributen). Wir lagern den Projektleiter aus.*

*   **Tabelle: Schüler** (SchülerID [PK], SchülerName)
*   **Tabelle: ProjektLeiter** (LeiterID [PK], Name)
*   **Tabelle: Projekte** (ProjektID [PK], ProjektName, LeiterID [FK])
*   **Tabelle: SchülerProjektNoten** (SchülerID [PK, FK], ProjektID [PK, FK], Note)

---

### 🎓 IHK-Prüfungsrelevanz: Normalisierung

#### Frage 1: Erklären Sie den Begriff "Änderungsanomalie" anhand eines Beispiels (3 Punkte)
> **IHK-Musterantwort:**
> Eine Änderungsanomalie tritt auf, wenn redundante Daten in einer Tabelle nicht an allen Stellen gleichzeitig aktualisiert werden. Zieht z. B. ein Kunde um und seine Adresse wird bei einer Bestellung aktualisiert, bei einer älteren Bestellung jedoch nicht, entstehen widersprüchliche (inkonsistente) Daten im System.

#### Frage 2: Nennen Sie die Bedingung, damit sich eine Tabelle in der 2. Normalform befindet (3 Punkte)
> **IHK-Musterantwort:**
> Die Tabelle muss sich bereits in der 1. Normalform befinden (atomare Attribute, Primärschlüssel existiert). Zudem muss jedes Nicht-Schlüsselfeld vom gesamten Primärschlüssel voll funktional abhängig sein (keine Teilabhängigkeiten bei zusammengesetzten Schlüsseln).

---

## 💡 Wichtige Notizen
> [!TIP]
> **Praxisnähe:** In produktiven Systemen wird fast immer bis zur 3. Normalform normalisiert. Höhere Normalformen (z. B. BCNF, 4NF, 5NF) spielen in der Praxis eine untergeordnete Rolle. Gelegentlich wird aus Performance-Gründen (z. B. in Data Warehouses) gezielt *denormalisiert*, um teure `JOIN`-Operationen einzusparen.