---
tags:
  - progetto
  - mappa
aliases:
  - main.tscn
  - Mappa
---

# Mappa principale

← [[Gamelog]]

La [[Scena]] principale del gioco (`world/main.tscn`): un prato 40×24 tile con un incrocio di sentieri, una piazza, alberi, una staccionata e un cartello. Tile da [[Tiny Town]].

![[mappa_subaru_fermo.png|500]]

## Struttura

```
Main (Node2D)
├── Ground (TileMapLayer)              ← erba e sentiero
├── Shadows (TileMapLayer)             ← ombre sotto gli alberi
├── Tint (CanvasModulate)              ← luce calda
├── World (Node2D, Y-sort)
│   ├── Objects (TileMapLayer, Y-sort) ← alberi, staccionata, cartello, funghi
│   ├── Bounds (StaticBody2D)          ← 4 muri invisibili ai bordi
│   ├── Npc (istanza)                  ← il Saggio
│   ├── Emilia (istanza di npc.tscn)   ← con il suo charset
│   ├── Sign (Interactable)            ← il cartello leggibile
│   ├── HouseDoor (Porta)              ← entra nella casa di Lina
│   └── Subaru (istanza)
│       └── Camera2D
│           └── Pollen (CPUParticles2D)
├── Spawns/HouseDoor (Marker2D)      ← dove ricompari uscendo di casa
└── Effects (CanvasLayer 5)
    └── Vignette (ColorRect + shader)
```

| Pezzo | Concetto |
|---|---|
| `Ground`, `Shadows`, `Objects` | [[TileMapLayer]], [[TileSet]] |
| `Npc` | [[Saggio]] |
| `Sign` | [[Cartello]], [[Interactable]] |
| La casa col tetto rosso, `HouseDoor`, `Spawns` | [[Casa di Lina]], [[Porta]], [[Cambio di scena]] |
| `Tint`, `Pollen`, `Vignette` | [[Effetti visivi]]: [[CanvasModulate]], [[Particelle]], [[Shader]], [[CanvasLayer]] |
| Ordine di disegno | [[Y-sort]] |
| `Bounds` | [[StaticBody2D]], [[Collisioni]] |
| [[Subaru]] dentro la mappa | [[Istanza]] |
| Inquadratura | [[Camera2D]] |
| Risoluzione e nitidezza | [[Viewport e stretch]], [[Filtro Nearest]] |

## Come è stata creata

Con il [[Generatore della mappa]], uno script Python. D'ora in poi conviene modificarla a mano nell'editor: [[2026-11-12-mappa-e-corsa#Come farlo a mano nell'editor]].

Verificata con il [[Test automatico]].
