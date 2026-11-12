---
tags:
  - concetto
  - grafica
aliases:
  - Nearest
  - Texture filter
---

# Filtro Nearest

← [[godot-basi|Basi di Godot]]

Quando Godot ingrandisce un'immagine, di default la **sfuma** (filtro *Linear*). Per la [[Pixel art]] serve invece **Nearest**: ogni pixel diventa un quadrato pieno e nitido.

- Per tutto il progetto: *Impostazioni progetto → Rendering → Textures → Canvas Textures → Default Texture Filter = Nearest*.
- Per un solo nodo: la proprietà `texture_filter` (es. in [[AnimatedSprite2D]]).

## Nel progetto

È impostato su tutto il progetto, e anche sullo sprite di [[Subaru]].

## Vedi anche

- [[Pixel art]] · [[Viewport e stretch]]
