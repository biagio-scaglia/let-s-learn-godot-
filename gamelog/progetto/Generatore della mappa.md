---
tags:
  - progetto
  - strumento
aliases:
  - genera_mappa.py
  - genera_mappa
---

# Generatore della mappa

← [[Gamelog]] · [[Strumenti archiviati]]

> [!note] Script rimosso
> Lo script è stato tolto dal repository durante la [[2026-11-12-pulizia|pulizia]]: resta nella cronologia di git. Questa nota spiega come funzionava. Vedi [[Strumenti archiviati]].

Lo script Python `tools/genera_mappa.py` crea il [[TileSet]] (`world/tileset.tres`) e la [[Mappa principale]] (`world/main.tscn`).

```
python tools/genera_mappa.py
```

## Cosa fa

1. Scrive il TileSet: quali tile di [[Tiny Town]] usare, le loro [[Collisioni]] e lo *Y Sort Origin*.
2. Mette l'erba ovunque, con qualche variante.
3. Disegna sentieri e piazza, e sceglie il bordo giusto di ogni cella guardando le vicine.
4. Mette staccionata e cartello, poi due file di alberi alti sul bordo.
5. Sparge alberi e decorazioni lontano dal sentiero.
6. Controlla che ogni chioma abbia il suo tronco.
7. Scrive la [[Scena]], con i dati dei [[TileMapLayer]] e i muri del [[StaticBody2D]] `Bounds`.

Usa sempre lo stesso "seme" casuale: rilanciato, produce **esattamente la stessa mappa**.

> [!warning] Sovrascrive la mappa
> Le modifiche fatte a mano in `main.tscn` vanno perse. Se Godot ha la scena aperta, quando chiede di ricaricarla scegli **Ricarica**, vedi [[Editor di Godot]].

## Vedi anche

- [[Test automatico]] · [[2026-11-12-mappa-e-corsa]]
