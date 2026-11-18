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

Un formato molto diffuso per i personaggi è il [[Charset]] di RPG Maker, usato da [[Emilia]].

## Su uno Sprite2D

Non serve sempre un [[AnimatedSprite2D]]: uno `Sprite2D` con `hframes = 5` (colonne) e `vframes = 1` (righe) divide l'immagine in celle, e `frame = 2` mostra la terza. È quello che fanno i [[Nemici]] con le loro pose; le cambia il codice (un [[Tween]] per il respiro, il [[Combattimento]] per le altre). Le pose hanno un nome con un [[Enum]].

## Vedi anche

- [[Pixel art]] · [[SpriteFrames]] · [[AtlasTexture]]
