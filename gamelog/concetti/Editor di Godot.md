---
tags:
  - concetto
  - editor
aliases:
  - Editor
  - Avviare il gioco
---

# Editor di Godot

← [[godot-basi|Basi di Godot]]

## Avviare il gioco

| Tasto | Cosa fa |
|---|---|
| **F5** o **▶** in alto a destra | Avvia la scena principale, la [[Mappa principale]] |
| **F6** | Avvia la [[Scena]] aperta in quel momento |
| **F8** o **⏹** | Ferma il gioco |

## Le aree di lavoro

Le schede in alto al centro:

- **2D**: per vedere e modificare le scene 2D, e dipingere i [[TileMapLayer]].
- **3D**: lo stesso per il 3D.
- **Script**: l'editor di [[GDScript]].
- **Gioco**: mostra il gioco *solo mentre è in esecuzione*. Da ferma dice "Premi riproduci per avviare il gioco".
- **Asset Store**: asset e plugin da scaricare.

## I pannelli

- **Scena** (alto a sinistra): l'albero dei [[Nodo|nodi]].
- **FileSystem** (basso a sinistra): i file del progetto, vedi [[Percorsi res]].
- **Ispettore** (destra): le proprietà del nodo selezionato, vedi [[Export e Inspector]].
- **Pannelli in basso**: Output, Debugger, [[SpriteFrames]], [[TileSet]], TileMap…

> [!warning] File modificati fuori dall'editor
> Se un file della scena aperta cambia sul disco (per esempio rigenerando la mappa con il [[Generatore della mappa]]), Godot chiede se ricaricarla: scegli **Ricarica**, altrimenti salvando sovrascrivi le modifiche.

## Vedi anche

- [[Godot da riga di comando]]
