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

`subaru_frames.tres` ha 12 animazioni per [[Subaru]]:

- `idle_` e `walk_` per `down`, `left`, `right`, `up`. Idle a 2 fps, camminata a 8 fps. Si ripetono (*loop*).
- `cheer`, `collapse`, `lying`, `wake_up`: le [[Subaru#Le azioni|azioni]]. **Non** si ripetono.

## Animazioni che finiscono

Con il *loop* spento l'animazione si ferma sull'ultimo frame e l'[[AnimatedSprite2D]] emette il [[Segnali|segnale]] `animation_finished`. Lo si può aspettare ([[Await]]):

```gdscript
sprite.play("cheer")
await sprite.animation_finished   # con il loop acceso non arriverebbe mai
_play_idle()
```

## Frame che durano di più

Ogni frame ha una sua durata (di solito 1). Nell'esultanza il segno di vittoria ha durata 4: resta sullo schermo quanto quattro frame normali, senza doverlo ripetere quattro volte.

## Più immagini, una risorsa

Le animazioni di uno SpriteFrames non devono venire tutte dalla stessa immagine: camminata e idle pescano da `subaru_sheet.png` (celle 32×48), le azioni da `subaru_actions.png` (celle 64×48). Ogni frame è un'[[AtlasTexture]] che sa da sola da quale immagine ritagliare.

## Specchiare invece di ridisegnare

Le azioni sono disegnate solo verso destra. Per la sinistra basta `sprite.flip_h = true` sull'[[AnimatedSprite2D]]: lo stesso frame, specchiato. Va rimesso a `false` quando si torna a un'animazione che ha già i suoi frame per ogni direzione.

Viene usata da un [[AnimatedSprite2D]].

## Vedi anche

- [[AtlasTexture]] · [[AnimatedSprite2D]]
