---
tags:
  - concetto
aliases:
  - Nodi
  - Node
---

# Nodo

← [[godot-basi|Basi di Godot]]

Il **mattone base** di Godot. Ogni nodo ha un *tipo* che decide cosa sa fare: disegnare un'immagine, gestire una collisione, seguire il personaggio con l'inquadratura…

- I nodi si organizzano ad **albero**: un padre con i suoi figli. I figli si muovono insieme al padre, perché la loro posizione è relativa a lui.
- Si aggiungono con il **+** nel pannello *Scena*, in alto a sinistra.
- Un albero di nodi salvato su file è una [[Scena]].
- I dati che un nodo usa (immagini, animazioni, forme) sono di solito [[Risorsa|risorse]].

## Tipi di nodo usati finora

| Tipo | A cosa serve | Dove |
|---|---|---|
| `Node2D` | Contenitore con una posizione in 2D | `Main`, `World` in [[Mappa principale]] |
| [[AnimatedSprite2D]] | Mostra un'animazione | Dentro [[Subaru]] |
| [[CharacterBody2D]] | Corpo che si muove con il codice | [[Subaru]] |
| [[StaticBody2D]] | Corpo fermo che blocca | I muri invisibili `Bounds` |
| [[Collisioni\|CollisionShape2D]] | La forma per gli urti | Piedi di Subaru, muri |
| [[TileMapLayer]] | Griglia di tile | `Ground`, `Objects` |
| [[Camera2D]] | L'inquadratura | Segue Subaru |

## Vedi anche

- [[Scena]] · [[Istanza]] · [[Risorsa]]
