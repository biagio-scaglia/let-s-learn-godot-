---
tags:
  - concetto
  - codice
aliases:
  - _physics_process
  - _ready
  - _process
---

# Ciclo di gioco

← [[godot-basi|Basi di Godot]]

Un gioco ripete continuamente gli stessi passi: legge i tasti, aggiorna le posizioni, ridisegna lo schermo. In [[GDScript]] ci si "aggancia" a questo ciclo con delle funzioni che Godot chiama da solo:

| Funzione | Quando viene chiamata | Per cosa usarla |
|---|---|---|
| `_ready()` | Una volta, quando il nodo entra in scena | Preparare le cose |
| `_process(delta)` | A ogni frame disegnato | Grafica, interfaccia |
| `_physics_process(delta)` | A ogni passo della fisica (60 volte al secondo) | Movimento e [[Collisioni]] |

- **`delta`** è il tempo passato dall'ultima chiamata, in secondi. Serve per muoversi alla stessa velocità anche se il computer va più lento.
- Con [[CharacterBody2D]] non serve moltiplicare per `delta`: `move_and_slide()` lo fa già.

## Nel progetto

[[Subaru]] fa tutto in `_physics_process`: legge l'[[Input Map]], calcola la velocità, si muove e sceglie l'animazione.

## Vedi anche

- [[GDScript]] · [[CharacterBody2D]]
