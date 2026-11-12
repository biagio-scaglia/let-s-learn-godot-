---
tags:
  - concetto
  - risorsa
---

# SpriteFrames

← [[godot-basi|Basi di Godot]]

Una [[Risorsa]] che contiene **un elenco di animazioni**. Per ognuna ci sono:

- il nome (es. `walk_down`);
- la velocità in fotogrammi al secondo (fps);
- se ripartire da capo alla fine (*loop*);
- la lista dei frame, di solito [[AtlasTexture]] ritagliate da una [[Spritesheet]].

Si apre con un doppio clic: compare il pannello **SpriteFrames** in basso, dove si aggiungono animazioni e frame.

## Nel progetto

`subaru_frames.tres` ha 8 animazioni per [[Subaru]]: `idle_` e `walk_` per `down`, `left`, `right`, `up`. Idle a 2 fps, camminata a 8 fps.

Viene usata da un [[AnimatedSprite2D]].

## Vedi anche

- [[AtlasTexture]] · [[AnimatedSprite2D]]
