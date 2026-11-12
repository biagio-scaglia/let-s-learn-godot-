---
tags:
  - concetto
  - codice
aliases:
  - class_name
---

# Classi globali

← [[godot-basi|Basi di Godot]]

Scrivendo **`class_name`** in cima a uno script, gli si dà un nome valido in tutto il progetto:

```gdscript
class_name Interactable
extends Area2D
```

Da quel momento:

- si può usare come **tipo**: `@onready var interactable: Interactable = $Interactable`, e l'editor suggerisce le sue variabili e funzioni;
- compare nella finestra *Aggiungi nodo*, come se fosse un tipo di Godot;
- si può controllare: `if nodo is Interactable:`.

## Una trappola che abbiamo incontrato

Negli script lanciati con `-s` (vedi [[Godot da riga di comando]]) gli [[Autoload]] non esistono ancora quando lo script viene compilato. Il [[Test del dialogo]] dichiarava una variabile di tipo `Interactable`; per compilarla Godot doveva compilare anche `interactable.gd`, che usa `Dialogue`, e falliva. Soluzione: nel test la variabile è di tipo `Area2D`. Nel gioco normale il problema non c'è.

## Nel progetto

- [[Interactable]] (`interactables/interactable.gd`)

## Vedi anche

- [[GDScript]] · [[Composizione]]
