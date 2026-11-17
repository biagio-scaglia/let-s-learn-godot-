---
tags:
  - concetto
  - nodo
  - grafica
aliases:
  - screen texture
  - hint_screen_texture
---

# BackBufferCopy

← [[godot-basi|Basi di Godot]]

Un nodo che **fotografa lo schermo** in quel punto del disegno, così che gli [[Shader]] successivi possano leggere quello che c'è già.

## Come funziona lo "screen texture"

Uno shader può leggere lo schermo con:

```glsl
uniform sampler2D screen : hint_screen_texture;
```

Ma Godot **non** fa una copia nuova per ogni shader: la fa **una volta**, al primo shader che la chiede in quel frame. Chi la usa dopo legge la **stessa** foto, anche se nel frattempo è stato disegnato altro.

Mettere un `BackBufferCopy` (con *Copy Mode* `Viewport`) **prima** di uno shader obbliga Godot a rifare la foto in quel punto.

## Nel progetto

Nel [[Combattimento]] lo sfondo sfocato (`pause_blur`) legge lo schermo per primo, quando c'è ancora solo la mappa. L'**onda d'urto** viene disegnata dopo, sopra la battaglia: senza un `BackBufferCopy` leggeva la foto della mappa e la disegnava sopra tutto. Il nodo lo crea `setup()` in `battle_vfx.gd`. Vedi [[Shader#Onda d'urto]] e la voce [[2026-11-17-vfx]].

## Vedi anche

- [[Shader]] · [[CanvasLayer]] · [[Effetti visivi]]
