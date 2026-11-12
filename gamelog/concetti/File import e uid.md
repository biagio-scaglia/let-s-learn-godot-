---
tags:
  - concetto
  - git
aliases:
  - .import
  - .uid
  - .godot
---

# File import e uid

← [[godot-basi|Basi di Godot]]

Godot crea da solo alcuni file accanto ai tuoi:

| File | Cos'è | Va su git? |
|---|---|---|
| `.godot/` | Cache dell'editor e delle importazioni | **No**, si ricrea da sola |
| `*.import` | Come importare un asset (es. un `.png`) | Sì |
| `*.uid` | Identificativo unico di uno script, così i riferimenti restano validi anche se il file si sposta | Sì |

- **Importare** vuol dire trasformare un file (immagine, suono) nel formato che Godot usa davvero. Succede da solo quando metti un file nel progetto.
- Un file vuoto chiamato **`.gdignore`** in una cartella dice a Godot di ignorarla. Il vault ne aveva uno, poi tolto perché sta fuori dal progetto Godot e Godot non lo vede comunque.

## Nel progetto

Le regole sono nel `.gitignore`, vedi [[Repository GitHub]].

## Vedi anche

- [[Percorsi res]] · [[Godot da riga di comando]]
