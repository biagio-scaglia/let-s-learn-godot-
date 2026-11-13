---
tags:
  - concetto
  - codice
aliases:
  - export
  - Inspector
  - Ispettore
---

# Export e Inspector

← [[godot-basi|Basi di Godot]]

L'**Inspector** (*Ispettore*, il pannello a destra) mostra le proprietà del [[Nodo]] selezionato e permette di cambiarle senza codice.

Con **`@export`** davanti a una variabile di [[GDScript]], la variabile compare nell'Inspector:

```gdscript
@export var walk_speed := 80.0
@export var run_speed := 150.0
@export var run_anim_scale := 1.8
```

- Il valore scritto nel codice è quello di partenza; quello impostato nell'Inspector lo sostituisce per quel nodo.
- Le righe con `##` sopra una variabile diventano la descrizione che appare passandoci sopra con il mouse.

## Esportare un nodo

Una variabile `@export` può anche essere un **nodo** della scena:

```gdscript
@export var lina: Interactable
```

Nell'Inspector compare un campo in cui trascinare il nodo. È il modo pulito per collegare uno script ad altri nodi senza scrivere percorsi nel codice. Lo usa la [[Missione della chiave]].

## Nel progetto

Seleziona [[Subaru]] nella [[Mappa principale]] e prova a cambiare `run_speed` mentre impari: non serve toccare lo script.

## Vedi anche

- [[GDScript]] · [[Editor di Godot]]
