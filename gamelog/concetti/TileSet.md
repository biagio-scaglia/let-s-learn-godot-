---
tags:
  - concetto
  - risorsa
  - mappa
aliases:
  - Tileset
---

# TileSet

← [[godot-basi|Basi di Godot]]

Una [[Risorsa]] che descrive **quali tile esistono e che proprietà hanno**. Si disegna con un [[TileMapLayer]].

- **Sorgente atlas:** l'immagine da cui ritagliare i tile, con la loro dimensione (per [[Tiny Town]] 16×16).
- **Physics Layer:** per dare [[Collisioni]] ai tile.
- **Y Sort Origin:** il punto "dei piedi" del tile per lo [[Y-sort]].
- Si modifica nel pannello **TileSet** in basso, scheda *Dipingi* per le proprietà.

## Oggetti alti più tile

Alcuni disegni occupano più tile. In [[Tiny Town]] molti alberi sono **chioma + tronco**, uno sopra l'altro:

![[alberi_due_tile.png|250]]

Vanno piazzati sempre in coppia. Collisione solo sul tronco, e Y-sort origin della chioma spostato alla base del tronco (16 + 6 = 22 px). Come l'abbiamo scoperto: [[2026-11-12-mappa-e-corsa#Problemi incontrati]].

## Più sorgenti

Un TileSet può prendere tile da **più immagini**: ognuna è una *sorgente* con un numero. Il nostro ne ha due:

| Sorgente | Immagine | Cosa |
|---|---|---|
| 0 | `tilemap_packed.png` di [[Tiny Town]] | Erba, sentieri, alberi… |
| 1 | `shadow_tree.png` | L'ombra degli alberi, fatta dal [[Generatore degli effetti]] |

## Nel progetto

`world/tileset.tres`, usato dai tre livelli della [[Mappa principale]]: `Ground`, `Shadows` e `Objects`.

## Vedi anche

- [[TileMapLayer]] · [[Tiny Town]] · [[AtlasTexture]]
