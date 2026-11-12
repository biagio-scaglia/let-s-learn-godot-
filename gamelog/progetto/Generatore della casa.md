---
tags:
  - progetto
  - strumento
aliases:
  - genera_casa.py
---

# Generatore della casa

← [[Gamelog]] · [[Strumenti archiviati]]

> [!note] Script rimosso
> Lo script è stato tolto dal repository durante la [[2026-11-12-pulizia|pulizia]]: resta nella cronologia di git. Questa nota spiega come funzionava. Vedi [[Strumenti archiviati]].

Lo script Python `tools/genera_casa.py` crea l'interno della [[Casa di Lina]]: il suo [[TileSet]] (`world/house_tileset.tres`, da [[Tiny Dungeon]]) e la scena (`world/house.tscn`).

```
python tools/genera_casa.py
```

## Tile usati

| Tile | Cosa |
|---|---|
| 0 | Pavimento |
| 40, 28, 29 | Muro di mattoni, finestra, torcia |
| 18 | Muri laterali (i tile 6 e 30 hanno lo sfondo marrone e stonavano negli angoli) |
| 36–39 | Muro basso, con il varco d'uscita |
| 63, 75, 72, 73, 89, 82 | Libreria, tavolo, sgabello, baule, barile |

I mobili hanno collisione nella parte bassa e *Y Sort Origin* alla base, come gli alberi del villaggio.

> [!warning] Sovrascrive la casa
> Come il [[Generatore della mappa]]: le modifiche fatte a mano in `house.tscn` vanno perse.
