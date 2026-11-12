---
tags:
  - concetto
  - nodo
  - grafica
aliases:
  - Tinta
---

# CanvasModulate

← [[godot-basi|Basi di Godot]]

Un [[Nodo]] che **moltiplica il colore** di tutto il mondo 2D del suo livello per un colore scelto. Bianco = nessun cambiamento.

- Leggermente arancione → luce calda di pomeriggio.
- Blu scuro → notte (e insieme alle luci 2D, lampioni e torce).
- Non tocca i [[CanvasLayer]] con un numero diverso: l'interfaccia resta con i colori veri.

## Nel progetto

Nella [[Mappa principale]] il nodo `Tint` ha `Color(1, 0.97, 0.92)`: una tinta calda appena percettibile. Vedi [[Effetti visivi]].

## Vedi anche

- [[Shader]] · [[CanvasLayer]]
