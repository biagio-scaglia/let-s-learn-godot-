---
tags:
  - concetto
  - nodo
  - fisica
---

# StaticBody2D

← [[godot-basi|Basi di Godot]]

Un [[Nodo]] di fisica che **non si muove**: muri, pavimenti, ostacoli. Gli altri corpi ci sbattono contro.

- Come gli altri corpi, ha bisogno di figli [[Collisioni|CollisionShape2D]] che ne definiscono la forma.
- Un solo StaticBody2D può avere tante forme: ognuna è un `CollisionShape2D` figlio.

## Nel progetto

Nella [[Mappa principale]] il nodo `Bounds` è uno StaticBody2D con **4 muri invisibili** (`Top`, `Bottom`, `Left`, `Right`), messi sopra le file di alberi del bordo. Senza, [[Subaru]] potrebbe infilarsi tra i tronchi e uscire dalla mappa.

Anche i tile con collisione del [[TileSet]] si comportano come corpi statici.

## Vedi anche

- [[CharacterBody2D]] · [[Collisioni]]
