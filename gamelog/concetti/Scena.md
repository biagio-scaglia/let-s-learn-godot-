---
tags:
  - concetto
aliases:
  - Scene
  - tscn
---

# Scena

← [[godot-basi|Basi di Godot]]

Un albero di [[Nodo|nodi]] salvato in un file **`.tscn`**. È il modo in cui Godot organizza tutto: un personaggio è una scena, una mappa è una scena, un menu è una scena.

- Una scena si può usare dentro un'altra quante volte si vuole: ogni copia è un'[[Istanza]].
- La **scena principale** è quella che parte con F5. Si sceglie in *Impostazioni progetto → Application → Run → Main Scene*. La nostra è la [[Mappa principale]].
- **F6** avvia solo la scena aperta in quel momento: comodo per provare un pezzo alla volta.
- Il file `.tscn` è testo: si può leggere, e anche generare con uno script (vedi [[Generatore della mappa]]).

## Nel progetto

- `characters/subaru/subaru.tscn` → [[Subaru]]
- `world/main.tscn` → [[Mappa principale]]

## Vedi anche

- [[Nodo]] · [[Istanza]] · [[Editor di Godot]]
