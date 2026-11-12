---
tags:
  - concetto
aliases:
  - change_scene_to_file
  - Marker2D
  - Spawn
---

# Cambio di scena

← [[godot-basi|Basi di Godot]]

Per passare da una [[Scena]] all'altra (dal villaggio alla casa):

```gdscript
get_tree().change_scene_to_file("res://world/house.tscn")
```

Godot **distrugge** la scena attuale, con tutti i suoi nodi e le loro variabili, e carica la nuova. Il cambio avviene alla fine del frame, non subito.

## I tre problemi da risolvere

| Problema | Soluzione nel progetto |
|---|---|
| Lo stacco è brusco | [[Dissolvenza]] al nero prima e dopo |
| Le variabili si perdono (con chi hai parlato…) | Salvarle in un [[Autoload]]: [[Game]] |
| Dove compare il giocatore? | Dei **Marker2D** nella scena di arrivo |

## Marker2D come punti d'arrivo

Un `Marker2D` è un nodo che segna solo una posizione (nell'editor si vede come una croce). Ogni livello ha un nodo `Spawns` con i suoi punti d'arrivo:

| Scena | Marker | Dove |
|---|---|---|
| [[Mappa principale]] | `Spawns/HouseDoor` | Davanti alla porta di casa |
| [[Casa di Lina]] | `Spawns/Entrance` | Appena dentro la porta |

Chi cambia scena (una [[Porta]]) dice a [[Game]] il nome del marker; lo script `level.gd` della nuova scena, nel suo `_ready`, ci sposta il giocatore.

## Vedi anche

- [[Porta]] · [[Game]] · [[Await]] · [[Dissolvenza]]
