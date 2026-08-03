name: "🐛 Bug Report"
about: Melde einen Fehler in den SQL-Skripten oder Lernunterlagen.
title: "[BUG] "
labels: bug
assignees: T-Boyke

body:
  - type: markdown
    attributes:
      value: |
        Vielen Dank, dass du einen Fehler meldest! Bitte fülle die folgenden Informationen aus, damit wir das Problem schnell beheben können.
  - type: textarea
    id: description
    attributes:
      label: Beschreibung des Fehlers
      description: Eine klare und prägnante Beschreibung des Fehlers.
      placeholder: Was läuft schief?
    validations:
      required: true
  - type: textarea
    id: sql-script
    attributes:
      label: Betroffenes SQL-Skript oder Markdown-Datei
      description: Welches Skript oder welche Lerneinheit ist betroffen? (z. B. `Day_07/src/indices.sql`)
      placeholder: Day_XX/src/...
    validations:
      required: false
  - type: textarea
    id: error-msg
    attributes:
      label: Fehlermeldung (falls vorhanden)
      description: Bitte füge die Fehlermeldung vom SQL Server oder Linter hier ein.
      render: sql
  - type: textarea
    id: expected-behavior
    attributes:
      label: Erwartetes Verhalten
      description: Was sollte stattdessen passieren?
    validations:
      required: true
