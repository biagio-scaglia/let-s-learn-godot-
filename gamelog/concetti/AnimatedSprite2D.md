---
tags:
  - concetto
  - nodo
---

# AnimatedSprite2D

← [[godot-basi|Basi di Godot]]

Un [[Nodo]] che **riproduce le animazioni** di uno [[SpriteFrames]].

| Proprietà / funzione | Cosa fa |
|---|---|
| `sprite_frames` | Lo SpriteFrames da usare |
| `play("walk_down")` | Avvia un'animazione. Se è già in corso non riparte da capo, quindi si può chiamare a ogni frame |
| `speed_scale` | Moltiplica la velocità: la corsa di Subaru usa 1,8 |
| `offset` | Sposta il disegno rispetto alla posizione del nodo |
| `flip_h` | Specchia in orizzontale |
| `autoplay` | L'animazione che parte da sola |
| `texture_filter` | Il [[Filtro Nearest]] per questo nodo |

## Nel progetto

In [[Subaru]] `offset = (0, -29)`: l'immagine è alzata di mezza cella, così **l'origine del nodo è ai piedi**. È fondamentale per lo [[Y-sort]].

## Agire a un frame preciso

Il segnale `frame_changed` arriva a ogni cambio di frame. Nel [[Combattimento]] il danno arriva quando il pugno è teso, non a fine animazione:

```gdscript
func _until_frame(index: int) -> void:
	while hero.is_playing() and hero.frame < index:
		await hero.frame_changed
```

E l'**hit stop**: `speed_scale = 0` ferma l'animazione per un istante quando il colpo va a segno, poi `speed_scale = 1`. Dà peso al colpo.

## Vedi anche

- [[SpriteFrames]] · [[CharacterBody2D]]
