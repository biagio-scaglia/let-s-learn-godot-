---
tags:
  - concetto
  - grafica
aliases:
  - Y sort
  - Ordinamento
---

# Y-sort

← [[godot-basi|Basi di Godot]]

Normalmente Godot disegna i [[Nodo|nodi]] nell'ordine dell'albero: chi viene dopo sta sopra. Con **Y Sort Enabled** su un nodo, i suoi figli vengono invece disegnati **in base alla y**: chi ha i piedi più in basso sullo schermo sta davanti.

È il trucco che fa sembrare "in profondità" un gioco visto dall'alto.

## Cosa serve

1. *Y Sort Enabled* sul nodo padre **e** sui [[TileMapLayer]] che ne fanno parte.
2. L'origine di ogni oggetto ai **piedi**: per [[Subaru]] con `offset` in [[AnimatedSprite2D]], per i tile con *Y Sort Origin* nel [[TileSet]].

## Nel progetto

![[mappa_dietro_albero.png|400]]

*Subaru dietro un albero: l'albero ha la base più in basso, quindi è disegnato davanti.*

Nella [[Mappa principale]] il nodo `World` ha lo Y-sort e contiene `Objects` e Subaru. Il terreno (`Ground`) sta fuori, sempre sotto a tutto.

## Vedi anche

- [[Collisioni]] · [[TileSet]]
