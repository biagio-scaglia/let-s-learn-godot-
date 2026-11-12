---
tags:
  - concetto
  - fisica
aliases:
  - CollisionShape2D
  - Collisione
  - Physics layer
---

# Collisioni

← [[godot-basi|Basi di Godot]]

Le collisioni decidono **chi sbatte contro cosa**.

- Un corpo ([[CharacterBody2D]], [[StaticBody2D]]…) da solo non ha forma: gliela dà un figlio **`CollisionShape2D`** con una *shape* (rettangolo, cerchio, capsula…).
- I tile possono avere collisioni anche loro: si aggiunge un *Physics Layer* al [[TileSet]] e si disegna una forma sui tile.
- **Layer e mask:** ogni corpo sta su uno o più *layer* e "vede" i layer indicati nella sua *mask*. Per ora usiamo tutto sul layer 1.
- Nell'editor le forme sono azzurre. Per vederle anche mentre giochi: menu **Debug → Forme di collisione visibili**.

## Nel progetto

| Cosa | Forma | Perché |
|---|---|---|
| [[Subaru]] | Rettangolo 16×8 ai piedi | Vista dall'alto: urtano solo i piedi |
| Tronchi degli alberi | Rettangolo sulla base | La chioma si può "attraversare" passando dietro |
| Staccionata, cartello | Rettangolo basso | Come sopra |
| Bordi della mappa | 4 rettangoli grandi | Muri invisibili, vedi [[StaticBody2D]] |

## Vedi anche

- [[Y-sort]] (le collisioni basse funzionano insieme all'ordine di disegno)
