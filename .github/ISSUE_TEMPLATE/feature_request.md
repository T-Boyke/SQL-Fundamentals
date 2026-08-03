name: "💡 Feature Request"
about: Schlage eine Erweiterung, neue Übungen oder Themen vor.
title: "[FEATURE] "
labels: enhancement
assignees: T-Boyke

body:
  - type: markdown
    attributes:
      value: |
        Hast du eine Idee für eine neue Übung, ein Cheat Sheet oder ein zusätzliches Thema? Lass es uns wissen!
  - type: textarea
    id: feature-description
    attributes:
      label: Beschreibung des Features
      description: Was genau soll hinzugefügt oder geändert werden?
      placeholder: Ich würde gerne ein Thema zu ... hinzufügen.
    validations:
      required: true
  - type: textarea
    id: use-case
    attributes:
      label: Nutzen
      description: Warum ist dieses Feature nützlich für das Verständnis von SQL Server?
    validations:
      required: true
  - type: textarea
    id: additional-context
    attributes:
      label: Zusätzlicher Kontext
      description: Links, Screenshots oder Referenzen.
