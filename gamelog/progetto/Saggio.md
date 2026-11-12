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
Npc (StaticBody2D)              + npc.gd: aspetto e comportamento
├── Shadow (Sprite2D)           ← ombra ai piedi
├── Sprite2D                    ← il mago, tile 84 di Tiny Dungeon, x3
├── CollisionShape2D            ← non lo si attraversa
└── Interactable (istanza)      ← "avvicinati e premi E", con la nuvoletta
```

| Comportamento | Concetto |
|---|---|
| Non lo si attraversa | [[StaticBody2D]], [[Collisioni]] |
| Si accorge di [[Subaru]] vicino, apre il dialogo | [[Interactable]] |
| Respira | [[Tween]] |
| Si gira verso Subaru | [[Sprite2D]] (`flip_h`) |
| Nome e frasi modificabili | [[Export e Inspector]] (`@export_multiline`) |
| Si ricorda di averti già parlato | `repeat_lines` di [[Interactable]] |

## Cosa dice

| Quando | Frasi |
|---|---|
| La prima volta | Benvenuto, si presenta, consiglia di correre con Shift |
| Dalla seconda volta | "Ancora qui?…", ti manda a leggere il [[Cartello]] e a salutare sua nipote [[Lina]] |

## Riutilizzabile

`characters/npc/npc.tscn` è generica: per un nuovo personaggio si fa una nuova [[Istanza]] e si cambiano `npc_name`, `lines`, `repeat_lines` e l'immagine. La parte "interazione" sta nel componente [[Interactable]], vedi [[Composizione]].

## Da sapere

Lo sprite è ingrandito ×3 per avere un'altezza simile a Subaru: i suoi "pixel" sono più grossi di quelli di Subaru (×1) e degli alberi (×2). Si nota poco, ma è una cosa da sistemare quando avremo uno stile grafico unico.

Asset: [[Tiny Dungeon]] · Storia: [[2026-11-12-primo-dialogo]], [[2026-11-12-interazioni-e-rifiniture]]
