# 📅 Day_02: ERM-Besonderheiten & Das Relationale Tabellenmodell

## ℹ️ Kurs-Informationen
*   **Datum:** Dienstag, 04.08.2026
*   **Arbeitszeit:** 08:15 - 16:00 Uhr
*   **Dozent:** Tom S.
*   **Autor:** Tobias Boyke

---

## 🎯 Lernziele des Tages
*   Komplexe ERM-Strukturen (rekursive und ternäre Beziehungen) verstehen.
*   Die Transformationsregeln vom ERM zum physischen Tabellenmodell beherrschen.
*   Schlüsselkonzepte (Primärschlüssel, Fremdschlüssel, zusammengesetzte Schlüssel) richtig anwenden.

---

## 📖 Theorie & Konzepte

### 1. Besonderheiten im ERM (Chen-Notation)
*   **Mehrere Beziehungen:** Zwischen denselben zwei Entitäten können verschiedene Beziehungen bestehen (z. B. `Mitarbeiter` *leitet* `Abteilung` vs. `Mitarbeiter` *arbeitet_in* `Abteilung`).
*   **Rekursive Beziehungen (Selbstbeziehung):** Eine Entität steht mit sich selbst in Beziehung (z. B. `Mitarbeiter` *ist Vorgesetzter von* `Mitarbeiter`).
*   **Ternäre Beziehungen (Mehrstellige Beziehungen):** Verknüpfen drei Entitäten gleichzeitig (z. B. `Lieferant` *liefert* `Teil` *an* `Projekt`). Kann nicht einfach in binäre Beziehungen zerlegt werden.

---

### 2. Vom ERM zum Tabellenmodell (Relational Mapping)
Die logische ERM-Struktur muss in konkrete Tabellendefinitionen überführt werden. Dafür gelten feste Regeln:

#### Regel 1: Entitäten werden zu Tabellen
Jede Entität wird zu einer eigenständigen Tabelle. Die Attribute werden zu Spalten. Der Primärschlüssel identifiziert jede Zeile eindeutig.

#### Regel 2: 1:N-Beziehung abbilden
Der Primärschlüssel (PK) der **1-Seite** wird als Fremdschlüssel (FK) in die Tabelle der **N-Seite** aufgenommen.
*   *Beispiel:* `Kunde (1) -> bestellt -> Bestellung (N)`
    *   Tabelle `Bestellung` erhält eine Spalte `KundenID (FK)` verweisend auf `Kunde(KundenID)`.

#### Regel 3: M:N-Beziehung abbilden (Koppeltabelle)
Eine M:N-Beziehung kann relational nicht direkt gespeichert werden. Es wird eine neue **Koppeltabelle (Relationstabelle)** erzeugt.
*   *Struktur der Koppeltabelle:* Besteht mindestens aus den Primärschlüsseln der beteiligten Tabellen.
*   *Schlüssel:* Beide Spalten bilden zusammen einen **zusammengesetzten Primärschlüssel** und verweisen einzeln als **Fremdschlüssel** auf ihre Ursprungstabellen.
*   *Beispiel:* `Mitarbeiter (M) -> arbeitet_an -> Projekt (N)`
    *   Koppeltabelle `MitarbeiterProjekt` mit Spalten `MitarbeiterID (PK, FK)` und `ProjektID (PK, FK)`.

#### Regel 4: 1:1-Beziehung abbilden
Hier wird der Primärschlüssel einer Seite als Fremdschlüssel auf der anderen Seite eingetragen und mit einem **UNIQUE**-Constraint versehen (damit er nur einmal vorkommen kann). Alternativ können beide Entitäten zu einer Tabelle verschmolzen werden.

#### Regel 5: Rekursive Beziehung (Selbstbeziehung) abbilden
Es wird eine Fremdschlüsselspalte in derselben Tabelle angelegt, die auf den eigenen Primärschlüssel verweist.
*   *Beispiel:* `Mitarbeiter` erhält Spalte `VorgesetzterID (FK)` verweisend auf `Mitarbeiter(MitarbeiterID)`.

---

### 🎓 IHK-Prüfungsrelevanz: Mapping-Regeln

#### Frage 1: Warum kann eine M:N-Beziehung nicht direkt in einer relationalen Tabelle abgebildet werden, und wie wird dieses Problem gelöst? (4 Punkte)
> **IHK-Musterantwort:**
> Eine relationale Spalte darf pro Zelle nur einen atomaren Wert enthalten (1. Normalform). Bei einer M:N-Beziehung müsste man Listen in einer Zelle speichern oder redundante Zeilen anlegen. 
> Die Lösung ist eine zusätzliche Koppeltabelle (Zwischentabelle), die die Primärschlüssel beider Entitäten als Fremdschlüssel aufnimmt und diese gemeinsam als zusammengesetzten Primärschlüssel nutzt.

#### Frage 2: Wie bilden Sie eine rekursive Vorgesetzten-Beziehung in einer Tabelle ab? (4 Punkte)
> **Sachverhalt:** Gegeben ist die Tabelle `Mitarbeiter` mit den Spalten `MitarbeiterID (PK)`, `Vorname`, `Nachname`.
> **IHK-Musterantwort:**
> Es wird eine zusätzliche Fremdschlüsselspalte (z. B. `VorgesetzterID`) eingeführt, die auf den Primärschlüssel `MitarbeiterID` derselben Tabelle verweist.
> *   Schema: `Mitarbeiter (MitarbeiterID [PK], Vorname, Nachname, VorgesetzterID [FK])`

---

## 💡 Wichtige Notizen
> [!IMPORTANT]
> **Referenzielle Integrität:** Fremdschlüssel garantieren, dass keine verwaisten Einträge entstehen können. Ein Eintrag mit einer `KundenID` in der Tabelle `Bestellung` darf nur eingefügt werden, wenn diese `KundenID` in der Tabelle `Kunde` auch physisch existiert!