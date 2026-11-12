---
tags:
  - concetto
  - grafica
aliases:
  - Sprite sheet
  - Foglio di sprite
---

# Spritesheet

← [[godot-basi|Basi di Godot]]

Un'unica immagine con **tanti frame disposti a griglia**. È più leggera e ordinata di tante immagini separate.

- Per usarla, Godot ritaglia ogni frame con un'[[AtlasTexture]] e li mette in fila in uno [[SpriteFrames]].
- Funziona bene se **tutte le celle hanno la stessa dimensione** e il personaggio è allineato sempre nello stesso punto: altrimenti "salta" durante l'animazione.
- Anche un tileset come [[Tiny Town]] è, in pratica, una spritesheet di tile.

## Nel progetto

La spritesheet di [[Subaru]] ha 6 colonne × 4 righe, celle da 42×58 px:

![[subaru_sheet_4x.png|400]]

Come l'abbiamo ottenuta dall'originale: [[2026-11-12-subaru]].

## Vedi anche

- [[Pixel art]] · [[SpriteFrames]] · [[AtlasTexture]]
