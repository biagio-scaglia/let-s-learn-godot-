---
tags:
  - progetto
  - mappa
aliases:
  - house.tscn
  - Casa
  - Interno
---

# Casa di Lina

← [[Gamelog]]

La prima scena **interna**: la casa col tetto rosso a nord-ovest del villaggio. File: `world/house.tscn`, generata dal [[Generatore della casa]] (script poi rimosso: ora si modifica a mano nell'editor).

![[casa_interno.png|500]]

## Fuori

Nella [[Mappa principale]] la casa è fatta di tile di [[Tiny Town]] (tetto 52–55 e 64–67, muro 72, 84, 87, 75). Un vialetto la collega al sentiero, con un varco nella staccionata. Il tetto si ordina con la base del muro, vedi [[Y-sort]].

![[casa_esterno.png|500]]

## Dentro

```
House (Node2D)                  + level.gd
├── Floor, Walls (TileMapLayer)  ← pavimento e muri di Tiny Dungeon
├── Darkness (CanvasModulate)    ← la stanza è più buia
├── TorchLight (PointLight2D)    ← luce calda che tremola
├── WindowLight (PointLight2D)   ← luce fredda dalla finestra
├── World (Y-sort)
│   ├── Objects (TileMapLayer)   ← libreria, tavolo, sgabelli, baule, barili
│   ├── Bounds (StaticBody2D)    ← i muri
│   ├── Lina (PNG)
│   ├── Chest, Bookshelf (Interactable)
│   ├── Exit (Porta)
│   └── Subaru
├── Camera2D                     ← ferma al centro della stanza
├── Spawns/Entrance (Marker2D)
└── Effects/Vignette
```

| Pezzo | Concetto |
|---|---|
| Luci e buio | [[Luci 2D]], [[CanvasModulate]] |
| [[Lina]], baule, libreria | [[Interactable]] |
| Entrare e uscire | [[Porta]], [[Cambio di scena]], [[Game]] |
| Camera ferma | [[Camera2D]] non figlia di Subaru: la stanza è più piccola dello schermo |

La stanza (384×288 px) è più piccola dello schermo (640×360): intorno si vede il colore di sfondo, impostato scuro in *Rendering → Environment → Default Clear Color*.

## Cosa si può esaminare

| Cosa | Prima volta | Dopo |
|---|---|---|
| Baule | "È chiuso a chiave." | "Ancora chiuso. Da qualche parte ci sarà una chiave..." |
| Libreria | Un libro: "Godot per principianti, volume 1" | Il volume 2 non c'è ancora |

Il baule è al centro della [[Missione della chiave]]: con la chiave si apre e si disegna aperto (tile 91).
