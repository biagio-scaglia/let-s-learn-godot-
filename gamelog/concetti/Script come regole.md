---
tags:
  - concetto
aliases:
  - BattleBehavior
  - Strategia
---

# Script come regole

← [[godot-basi|Basi di Godot]]

Uno script si può mettere **dentro una risorsa**, come un'immagine o un suono, e poi creare un oggetto da lui quando serve. È il modo più semplice per dire "questo nemico ha regole sue" senza riempire di `if` il codice che lo usa.

## Come si usa

```gdscript
# enemy_data.gd (la risorsa)
@export var behavior: Script     # nell'Inspector: si trascina dentro un file .gd

# battle.gd (chi la usa)
behavior = data.behavior.new() if data.behavior else null
...
if behavior:
	var handled: bool = await behavior.take_turn()
```

Lo script del comportamento estende una **classe base** che fa "la cosa normale" in ogni momento ([[Ereditarietà]]):

```gdscript
class_name BattleBehavior
extends RefCounted

func take_turn() -> bool:
	return false        # niente di speciale: attacco normale
```

Un boss riscrive solo quello che gli serve. `RefCounted` vuol dire che non è un nodo: non sta nell'albero della scena, e sparisce da solo quando nessuno lo usa più.

> [!tip] Perché così
> Senza, `battle.gd` avrebbe un `if enemy.name == "Colui che guarda"` in dieci punti, e un secondo boss raddoppierebbe il caos. Così la battaglia chiede soltanto "hai qualcosa da fare adesso?", e ogni boss risponde nel suo file. Gli informatici lo chiamano *pattern Strategy*.

## Nel progetto

- `BattleBehavior` (`enemies/battle_behavior.gd`): `after_intro`, `take_turn`, `modify_damage`, `on_hit`, `held_pose`, `can_flee`, `ultimate_ready`.
- `WatcherBehavior`: [[Colui che guarda]].

## Vedi anche

- [[Risorse personalizzate]] · [[Ereditarietà]] · [[Classi globali]] · [[2026-11-18-colui-che-guarda]]
