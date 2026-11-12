---
tags:
  - progetto
  - personaggio
aliases:
  - PNG
  - NPC
  - Il Saggio
---

# Saggio

← [[Gamelog]]

Il primo **personaggio con cui parlare**: un vecchio mago nella piazza della [[Mappa principale]].

![[saggio.png|300]]

## Com'è fatto

```
Npc (StaticBody2D)          + npc.gd
├── Shadow (Sprite2D)       ← ombra ai piedi
├── Sprite2D                ← il mago, tile 84 di Tiny Dungeon, x3
├── CollisionShape2D        ← non lo si attraversa
├── InteractArea (Area2D)   ← "sei abbastanza vicino per parlare"
└── Prompt (Sprite2D)       ← la nuvoletta "..."
```

| Comportamento | Concetto |
|---|---|
| Non lo si attraversa | [[StaticBody2D]], [[Collisioni]] |
| Si accorge di [[Subaru]] vicino | [[Area2D]], [[Segnali]], [[Gruppi]] |
| Respira, la nuvoletta saltella | [[Tween]] |
| Si gira verso Subaru | [[Sprite2D]] (`flip_h`) |
| Premi E e parla | [[Eventi di input]], [[Autoload]], [[Finestra di dialogo]] |
| Nome e frasi modificabili | [[Export e Inspector]] (`@export_multiline`) |

## Riutilizzabile

`characters/npc/npc.tscn` è generica: per un nuovo personaggio si fa una nuova [[Istanza]] e si cambiano `npc_name`, `lines` e l'immagine.

## Da sapere

Lo sprite è ingrandito ×3 per avere un'altezza simile a Subaru: i suoi "pixel" sono più grossi di quelli di Subaru (×1) e degli alberi (×2). Si nota poco, ma è una cosa da sistemare quando avremo uno stile grafico unico.

Asset: [[Tiny Dungeon]] · Storia: [[2026-11-12-primo-dialogo]]
