---
tags:
  - concetto
  - nodo
  - fisica
aliases:
  - Area
---

# Area2D

← [[godot-basi|Basi di Godot]]

Un [[Nodo]] che **non blocca niente**, ma si accorge di chi ci entra e di chi esce. Come gli altri nodi di fisica, la forma gliela dà un figlio `CollisionShape2D`, vedi [[Collisioni]].

- Segnali `body_entered(body)` e `body_exited(body)` per i corpi ([[CharacterBody2D]], [[StaticBody2D]], tile…).
- Segnali `area_entered` / `area_exited` per altre aree.
- Usi tipici: zona per parlare, trappole, raccogliere oggetti, porte.

> [!tip] Filtrare chi entra
> Anche i tile con collisione sono "corpi" e fanno scattare `body_entered`. Per reagire solo al giocatore si controlla un [[Gruppi|gruppo]]: `body.is_in_group("player")`.

## Nel progetto

Il [[Saggio]] ha un'area circolare (raggio 30 px): quando [[Subaru]] ci entra compare la nuvoletta e si può parlare.

## Vedi anche

- [[Segnali]] · [[Gruppi]] · [[Collisioni]]
