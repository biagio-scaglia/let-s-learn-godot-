---
tags:
  - concetto
aliases:
  - Group
  - Gruppo
---

# Gruppi

← [[godot-basi|Basi di Godot]]

Un'**etichetta** che si dà a un [[Nodo]]. Serve per riconoscerlo o trovarlo senza sapere dov'è nell'albero.

- Si aggiunge dal pannello **Gruppi** (accanto all'Inspector) o nel codice con `add_to_group("player")`.
- `nodo.is_in_group("player")` dice se ha l'etichetta.
- `get_tree().get_nodes_in_group("nemici")` li trova tutti.

## Nel progetto

[[Subaru]] è nel gruppo **`player`**. L'[[Area2D]] del [[Saggio]] lo usa per capire che è entrato il giocatore e non, per esempio, un albero.

## Vedi anche

- [[Area2D]] · [[Nodo]]
