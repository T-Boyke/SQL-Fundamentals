# 🤝 Beitragsrichtlinien (Contributing)

Willkommen im **SQL-Fundamentals** Repository! Dieses Projekt dient als zentrale Wissensdatenbank für unseren SQL-Kurs. Wenn du Fehler korrigieren, Übungen hinzufügen oder Erklärungen verbessern möchtest, bist du hier genau richtig.

Bitte befolge diese Richtlinien, um einen reibungslosen Ablauf zu gewährleisten.

---

## 🛠️ Wie kann ich beitragen?

### 1. Issues erstellen
Wenn du einen Fehler findest oder einen Verbesserungsvorschlag hast, erstelle bitte ein **Issue**:
*   Nutze das passende Template (Bug Report oder Feature Request).
*   Beschreibe das Problem oder die Idee möglichst präzise.
*   Gib bei Fehlern in SQL-Skripten die genaue Fehlermeldung und den Tag an (z. B. `Day_07`).

### 2. Pull Requests (PRs) einreichen
Wenn du den Fehler selbst beheben möchtest:
1.  **Repository forken** oder direkt auf einem neuen Branch arbeiten (z. B. `feature/neue-uebung` oder `bugfix/day-07-syntax`).
2.  Nimm deine Änderungen vor.
3.  **Wichtig:** Teste deine SQL-Skripte lokal auf einem Microsoft SQL Server, bevor du den PR erstellst.
4.  Stelle sicher, dass alle Markdown-Dateien sauber formatiert sind (unser CI-Linter überprüft das automatisch).
5.  Erstelle einen Pull Request und fülle das PR-Template vollständig aus.

---

## 📐 Styleguide für Dokumente und Code

### Markdown (`.md`)
*   Verwende klare Überschriften-Hierarchien (`#`, `##`, `###`).
*   Nutze Admonitions für wichtige Hinweise:
    ```markdown
    > [!NOTE]
    > Wichtiger Hintergrund zu SQL Server.
    ```
*   Verlinke SQL-Dateien immer relativ (z. B. `[Skript](./src/abfrage.sql)`).

### SQL-Skripte (`.sql`)
*   Schreibe SQL-Schlüsselwörter stets in **GROSSBUCHSTABEN** (`SELECT`, `FROM`, `WHERE`, `JOIN`, `CREATE INDEX`).
*   Verwende sprechende Bezeichner für Tabellen und Spalten in CamelCase oder snake_case, je nach Kurs-Vorgabe.
*   Kommentiere komplexe Logiken oder die Absicht hinter bestimmten Abfragen.
*   Achte darauf, dass deine Skripte einheitliche Einrückungen haben (4 Leerzeichen).

---

Vielen Dank für deine Unterstützung!  
**Tobias Boyke** & Dozent **Tom S.**
