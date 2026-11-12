---
tags:
  - concetto
  - codice
aliases:
  - Script
  - gd
---

# GDScript

← [[godot-basi|Basi di Godot]]

Il **linguaggio di scripting** di Godot, molto simile a Python. Uno script si attacca a un [[Nodo]] e ne aggiunge il comportamento.

## Le basi viste finora

```gdscript
extends CharacterBody2D              # lo script "è" un CharacterBody2D

@export var walk_speed := 80.0       # variabile modificabile dall'Inspector
@onready var sprite = $AnimatedSprite2D   # prende il nodo figlio quando la scena è pronta

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
```

- **`extends`**: il tipo di nodo a cui si attacca lo script.
- **`var x := 5`**: variabile. Con `:=` il tipo si deduce dal valore.
- **`func`**: una funzione. Quelle che iniziano con `_` sono chiamate da Godot da solo, vedi [[Ciclo di gioco]].
- **`$Nome`**: scorciatoia per trovare un nodo figlio per nome.
- **`a if condizione else b`**: il "se" in una riga.
- **L'indentazione conta**, come in Python. Godot usa le tabulazioni.
- **`@export`**: vedi [[Export e Inspector]].

## Nel progetto

- `characters/subaru/subaru.gd` → movimento e corsa di [[Subaru]]
- `tools/test_corsa.gd` → [[Test automatico]] (rimosso, vedi [[Strumenti archiviati]])

## Vedi anche

- [[Ciclo di gioco]] · [[Export e Inspector]] · [[Input Map]]
