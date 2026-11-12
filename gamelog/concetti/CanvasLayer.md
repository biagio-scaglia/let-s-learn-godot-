---
tags:
  - concetto
  - nodo
aliases:
  - Livello del canvas
---

# CanvasLayer

← [[godot-basi|Basi di Godot]]

Un [[Nodo]] che disegna i suoi figli **su un livello separato**, fermo rispetto allo schermo: la [[Camera2D]] non lo sposta. È quello che serve per interfaccia ed effetti a schermo intero.

- `layer` decide l'ordine: numero più alto = più in alto. Il mondo di gioco è il livello 0.
- I nodi di [[Interfaccia (Control)|interfaccia]] dentro un CanvasLayer si posizionano rispetto allo schermo, con le ancore.

## Nel progetto

| Layer | Cosa |
|---|---|
| 0 | Il mondo ([[Mappa principale]]) |
| 5 | `Effects`: la vignettatura ([[Shader]]) |
| 10 | La [[Finestra di dialogo]], sopra a tutto |

## Vedi anche

- [[Interfaccia (Control)]] · [[Shader]] · [[CanvasModulate]]
