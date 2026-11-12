---
tags:
  - concetto
aliases:
  - res://
  - user://
  - Percorsi
---

# Percorsi res://

← [[godot-basi|Basi di Godot]]

- **`res://`** è la cartella principale del progetto, quella che contiene `project.godot`. Per noi è `let's-learn-godot/`.
- `res://characters/subaru/subaru_sheet.png` = "il file `subaru_sheet.png` nella cartella `characters/subaru` del progetto".
- **`user://`** è una cartella dell'utente dove il gioco può scrivere (salvataggi, impostazioni). Il [[Test automatico]] ci salva gli screenshot se non gli si dà un'altra cartella.

> [!warning] Spostare i file
> Sposta e rinomina i file **dall'editor di Godot** (pannello *FileSystem*): così i riferimenti si aggiornano da soli. Da Esplora file no.

Quando abbiamo spostato [[Subaru]] dentro il progetto, i percorsi sono passati da `res://subaru/...` a `res://characters/subaru/...`: [[2026-11-12-mappa-e-corsa]].

## Vedi anche

- [[File import e uid]] · [[Risorsa]]
