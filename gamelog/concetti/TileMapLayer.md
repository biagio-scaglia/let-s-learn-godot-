---
tags:
  - concetto
  - nodo
  - mappa
aliases:
  - TileMap
---

# TileMapLayer

← [[godot-basi|Basi di Godot]]

Un [[Nodo]] che è una **griglia in cui si dipingono i tile** di un [[TileSet]].

- Si dipinge dal pannello **TileMap** in basso, con il nodo selezionato: pennello, linea, rettangolo, secchiello, gomma.
- Si possono sovrapporre **più livelli**: uno per il terreno, uno per gli oggetti…
- Le celle dipinte sono salvate nella proprietà `tile_map_data` (dati binari dentro la [[Scena]]).
- Con *Y Sort Enabled* i suoi tile si ordinano con gli altri nodi, vedi [[Y-sort]].

## Nel progetto

La [[Mappa principale]] ha due livelli, ingranditi ×2 (`scale = (2, 2)`):

| Livello | Contenuto | Collisioni |
|---|---|---|
| `Ground` | Erba e sentiero | No |
| `Objects` | Alberi, staccionata, cartello, funghi | Sì (dal TileSet) |

Funghi e germogli hanno lo sfondo trasparente: nel livello `Ground` mostravano il vuoto sotto, per questo stanno in `Objects`.

## Vedi anche

- [[TileSet]] · [[Generatore della mappa]]
