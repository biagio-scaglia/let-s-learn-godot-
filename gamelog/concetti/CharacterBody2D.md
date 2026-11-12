---
tags:
  - concetto
  - nodo
  - fisica
---

# CharacterBody2D

← [[godot-basi|Basi di Godot]]

Il [[Nodo]] fatto per i **personaggi mossi dal codice**. Si scontra con gli altri corpi grazie alle [[Collisioni]].

```gdscript
velocity = input * (run_speed if running else walk_speed)
move_and_slide()
```

- **`velocity`**: la velocità, in pixel al secondo.
- **`move_and_slide()`**: muove il corpo e, se urta, lo fa **scivolare** lungo l'ostacolo invece di bloccarlo di colpo.
- **`motion_mode = Floating`**: per i giochi visti dall'alto, senza gravità né pavimento. Il modo *Grounded* serve invece per i platform.
- Ha bisogno di almeno un figlio [[Collisioni|CollisionShape2D]].

## Nel progetto

[[Subaru]] è un CharacterBody2D con collisione solo sui piedi (16×8 px).

## Vedi anche

- [[StaticBody2D]] · [[Collisioni]] · [[Ciclo di gioco]] · [[Input Map]]
