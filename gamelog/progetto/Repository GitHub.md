---
tags:
  - progetto
  - git
aliases:
  - GitHub
  - Git
---

# Repository GitHub

← [[Gamelog]]

[github.com/biagio-scaglia/let-s-learn-godot-](https://github.com/biagio-scaglia/let-s-learn-godot-)

## Regole

- **Commit piccoli e tanti**, con messaggi **in italiano** che dicono cosa cambia (es. "Subaru ora può correre tenendo premuto Shift").
- Spostare i file con `git mv`, così la cronologia li segue.

## Cosa resta fuori (`.gitignore`)

- `.godot/`: la cache di Godot, vedi [[File import e uid]].
- Lo stato dell'interfaccia di Obsidian (`workspace.json`), vedi [[Vault Obsidian]].
- File di sistema (`Thumbs.db`, `desktop.ini`…).

## Struttura

| Cartella | Contenuto |
|---|---|
| `let's-learn-godot/` | Il progetto Godot |
| `tools/` | [[Generatore della mappa]], [[Generatore della casa]], [[Generatore degli effetti]], [[Test automatico]], [[Test del dialogo]], [[Test di casa]], [[Convertitore di charset]], [[Generatore di Subaru]] |
| `gamelog/` | Questo [[Vault Obsidian]] |
