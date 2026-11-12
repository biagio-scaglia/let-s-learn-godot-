---
tags:
  - concetto
  - nodo
  - grafica
aliases:
  - Sprite
---

# Sprite2D

← [[godot-basi|Basi di Godot]]

Il [[Nodo]] più semplice per **mostrare un'immagine** ferma. Per le animazioni c'è [[AnimatedSprite2D]].

| Proprietà | Cosa fa |
|---|---|
| `texture` | L'immagine (anche un'[[AtlasTexture]], cioè un ritaglio) |
| `centered`, `offset` | Dove sta l'immagine rispetto all'origine del nodo |
| `scale` | Ingrandisce |
| `flip_h` | Specchia |

## Nel progetto

- Il [[Saggio]]: una `AtlasTexture` del tile 84 di [[Tiny Dungeon]], ingrandita ×3, con `offset = (0, -8)` così l'origine è ai piedi.
- [[Emilia]]: un [[Charset]] diviso con `hframes = 4` e `vframes = 4`; `frame` sceglie la direzione.
- Le **ombre** di Subaru e del Saggio e la **nuvoletta** sopra il Saggio. Vedi [[Effetti visivi]].

## Vedi anche

- [[AnimatedSprite2D]] · [[Y-sort]]
