---
tags:
  - progetto
  - strumento
aliases:
  - genera_effetti.py
---

# Generatore degli effetti

← [[Gamelog]] · [[Strumenti archiviati]]

> [!note] Script rimosso
> Lo script è stato tolto dal repository durante la [[2026-11-12-pulizia|pulizia]]: resta nella cronologia di git. Questa nota spiega come funzionava. Vedi [[Strumenti archiviati]].

Lo script Python `tools/genera_effetti.py` **disegna dal codice** le piccole immagini e i suoni degli [[Effetti visivi]], in `assets/effects/`.

```
python tools/genera_effetti.py
```

| File | Cosa |
|---|---|
| `shadow_character.png` | Ovale 22×7 per le ombre dei personaggi |
| `shadow_tree.png` | Tile 16×16 con l'ombra di un albero, usato dal [[TileSet]] |
| `interact_icon.png` | La nuvoletta "..." sopra il [[Saggio]] |
| `next_arrow.png` | La freccia della [[Finestra di dialogo]] |
| `door.wav` | Il "tonf" della [[Porta]]: frequenza che scende più un po' di legno |
| `step.wav` | Il passo di [[Subaru]]: rumore filtrato di 60 ms, vedi [[Audio]] |
| `blip.wav` | Il suono delle lettere: un'onda quadra di 45 ms che si spegne, vedi [[Audio]] |

Essendo fatti da noi, **non c'è nessuna licenza** da rispettare, e si possono cambiare (colori, misure) e rigenerare.

## Vedi anche

- [[Generatore della mappa]]
