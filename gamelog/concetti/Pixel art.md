---
tags:
  - concetto
  - grafica
aliases:
  - Pixel-art
---

# Pixel art

← [[godot-basi|Basi di Godot]]

Grafica disegnata **pixel per pixel**, con pochi colori e senza sfumature automatiche.

Per farla apparire bene in Godot servono due cose:

1. Il [[Filtro Nearest]], così i pixel ingranditi restano quadrati e nitidi.
2. Una risoluzione bassa ingrandita di un numero intero di volte (×2, ×3…), vedi [[Viewport e stretch]].

## Cose imparate

- Un'immagine che *sembra* pixel art può non esserlo: la spritesheet originale di [[Subaru]] era ingrandita in modo irregolare e aveva 69.000 colori. L'abbiamo riportata a 1x con 22 colori: [[2026-11-12-subaru]].
- Mescolare pixel di grandezze diverse si nota: i tile di [[Tiny Town]] sono ingranditi ×2, quindi i loro "pixel" sono il doppio di quelli di Subaru.

## Vedi anche

- [[Spritesheet]] · [[Filtro Nearest]] · [[Viewport e stretch]]
