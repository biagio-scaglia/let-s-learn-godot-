---
tags:
  - progetto
  - mappa
aliases:
  - library.tscn
  - Archivista
  - Tileset della biblioteca
---

# Biblioteca

← [[Gamelog]]

La seconda scena **interna**: la casa di pietra col tetto grigio a nord-est del villaggio. File: `world/library.tscn`. Costruita il [[2026-11-17-biblioteca|17 novembre]] con un tileset disegnato apposta.

![[biblioteca_interno.png|500]]

## Fuori

Nella [[Mappa principale]] l'edificio è fatto di tile di [[Tiny Town]] che prima non usavamo: tetto grigio (righe 4-5, colonne 0-3) e muro di pietra (colonne 4 e 7 delle righe 6-7). Il sentiero davanti è una copia di quello della [[Casa di Lina]]. La porta è il nodo `LibraryDoor`, il punto d'arrivo è `Spawns/LibraryDoor`.

![[biblioteca_esterno.png|500]]

## Dentro

```
Library (Node2D)                  + level.gd
├── Floor, Carpet, Walls (TileMapLayer)
├── Darkness (CanvasModulate)      ← notte, un po' viola
├── Moonlight
│   ├── Shaft1..4 (Polygon2D)      ← i raggi dalle finestre
│   ├── Dust1..4 (CPUParticles2D)  ← polvere nei raggi
│   └── Glow1..4 (PointLight2D)    ← luce fredda sul pavimento
├── Flames (8 × PointLight2D)      ← applique, candelabri, candele, con flicker.gd
├── BlackBookGlow, BlackBookEmbers ← il libro nero: luce viola e scintille
├── World (Y-sort)
│   ├── Objects (TileMapLayer)     ← librerie, scrivania, sedie, leggio…
│   ├── Archivista (NPC)
│   ├── 9 × Interactable           ← scaffali, libro nero, mappamondo, mappa, finestra, scrivania
│   ├── Exit (Porta)
│   └── Subaru + Camera2D con limiti
├── Spawns/Entrance
└── Effects/Vignette
```

## Il tileset

`assets/library/library_tiles.png`, 8×7 tile da 16×16, nello stile di [[Tiny Dungeon]].

![[biblioteca_tileset_6x.png]]

| Riga | Cosa |
|---|---|
| 0 | Pavimento di legno (2), pietra (2), cima del muro, mattoni, mattoni + boiserie, finestra |
| 1-2 | Librerie alte 2 tile: singola, singola mezza vuota, inizio, centro, fine. Colonne 5-7: tappeto 3×3 |
| 3 | Stendardo, mappa, applique, scrivania (2 tile) |
| 4 | Sedia, pila di libri, libro aperto, leggio, mappamondo, candelabro, cesto di pergamene, pianta |
| 5 | Fogli, clessidra, tavolino, sgabello, cassa di libri, pergamena, candele |
| 6 | Muro visto dall'alto: pieno, lato sinistro, lato destro, fondo |

Collisioni e Y-sort sono in `world/library_tileset.tres`: muri pieni, base delle librerie, mobili con una collisione piccola ai piedi. Sedie, fogli, libri per terra e tappeto si attraversano.

## I dialoghi

| Cosa | Dove | Di cosa parla |
|---|---|---|
| Archivista | Vicino alla scrivania | Si presenta; avverte di non toccare il libro nero |
| Libro nero | Leggio in alto | Una frase scritta con la tua calligrafia |
| Scaffali | I quattro blocchi | Storia di Erbalta, zuppe di funghi, bestiario, poesie |
| Mappamondo, mappa, finestra, scrivania | — | Piccoli dettagli strani |

## Vedi anche

- [[2026-11-17-biblioteca]] · [[Casa di Lina]] · [[Luci 2D]] · [[TileSet]] · [[Pixel art]]
