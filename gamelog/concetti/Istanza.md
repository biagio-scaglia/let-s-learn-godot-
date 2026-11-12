---
tags:
  - concetto
aliases:
  - Istanze
  - Instance
---

# Istanza

← [[godot-basi|Basi di Godot]]

Una **copia di una [[Scena]] dentro un'altra scena**. Si crea trascinando il file `.tscn` nell'albero, oppure con l'icona a forma di catena nel pannello *Scena*.

- Se modifichi la scena originale, cambiano tutte le sue istanze.
- Nell'istanza puoi cambiare solo alcune proprietà (per esempio la posizione) senza toccare l'originale.
- Puoi aggiungere nodi figli a un'istanza: restano solo in quella scena.

## Nel progetto

- [[Subaru]] è un'istanza di `subaru.tscn` dentro la [[Mappa principale]].
- La [[Camera2D]] è stata aggiunta come figlia dell'istanza di Subaru **nella mappa**, non in `subaru.tscn`: così la camera e i suoi limiti appartengono alla mappa.

## Vedi anche

- [[Scena]] · [[Nodo]]
