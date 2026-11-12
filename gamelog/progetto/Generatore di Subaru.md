---
tags:
  - progetto
  - strumento
aliases:
  - genera_subaru.py
---

# Generatore di Subaru

← [[Gamelog]] · [[Strumenti archiviati]]

> [!note] Script rimosso
> Lo script è stato tolto dal repository durante la [[2026-11-12-pulizia|pulizia]]: resta nella cronologia di git. Questa nota spiega come funzionava. Vedi [[Strumenti archiviati]].

Lo script `tools/genera_subaru.py` prepara [[Subaru]] per Godot partendo dal suo [[Charset]] (`characters/subaru/subaru_charset.png`).

```
python tools/genera_subaru.py
```

## Cosa scrive

| File | Contenuto |
|---|---|
| `subaru_sheet.png` | 6 colonne × 4 righe, celle 32×48 |
| `subaru_frames.tres` | Le 8 animazioni `idle_*` e `walk_*` per l'[[AnimatedSprite2D]] |

## Le colonne

| Colonna | Cosa | Da dove |
|---|---|---|
| 0 | Idle | Colonna 0 del charset |
| 1 | Idle, "respiro" | Colonna 0 con il busto abbassato di 1 px |
| 2–5 | Camminata | Colonne 1, 2, 3, 0 del charset |

L'ordine della camminata è scelto apposta: i frame con il piede avanti finiscono in posizione 0 e 2, che sono quelli in cui `subaru.gd` fa suonare i passi (vedi [[Audio]]).

## Vedi anche

- [[Convertitore di charset]] · [[SpriteFrames]]
