---
tags:
  - concetto
aliases:
  - extends
  - Classe base
---

# Ereditarietà

← [[godot-basi|Basi di Godot]]

Uno script può **estendere** un altro script: prende tutte le sue variabili e funzioni, e ne aggiunge di sue. Lo script "di partenza" si chiama classe base.

## Come si usa

Lo usiamo da sempre senza saperlo: `extends CharacterBody2D` vuol dire "sono un CharacterBody2D, più quello che scrivo qui". Ma si può estendere anche **un proprio script**, se ha un `class_name` (vedi [[Classi globali]]):

```gdscript
# cutscene.gd
class_name Cutscene
extends CanvasLayer

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
```

```gdscript
# castle_opening.gd
extends Cutscene     # ha già _wait(), _say(), _show_place_card()...

func _play() -> void:
	await _wait(0.5)
```

- Le variabili `@onready` della base funzionano anche nella figlia, se la scena ha quei nodi.
- Se la figlia scrive una funzione con lo stesso nome, **sostituisce** quella della base. Per chiamare comunque quella della base: `super()`.
- Una classe ne estende **una sola**. Per mettere insieme tanti pezzi diversi, meglio la [[Composizione]] (nodi figli).

> [!tip] Quando conviene
> Quando due script copiano le stesse funzioni. Qui le due cutscene avevano entrambe le bande nere, il nome del luogo e le attese: ora stanno in un posto solo, e una terza cutscene le avrà gratis.

## Nel progetto

- `Cutscene` (`cutscenes/cutscene.gd`) è la base di [[Intro]] e della cutscene della [[Rocca d'Argento]].

## Vedi anche

- [[Classi globali]] · [[Composizione]] · [[Cutscene]] · [[GDScript]] · [[2026-11-18-castello]]
