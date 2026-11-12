---
tags:
  - godot
  - moc
aliases:
  - Basi di Godot
  - Concetti
---

# Basi di Godot

← [[Gamelog]]

Indice dei concetti di Godot incontrati finora. Ogni concetto ha la sua nota, con un esempio preso dal progetto. Si riferiscono a **Godot 4.7**.

## Fondamenta

- [[Nodo]]: il mattone base, ogni tipo sa fare una cosa
- [[Scena]]: un albero di nodi salvato in un file `.tscn`
- [[Istanza]]: una scena usata dentro un'altra
- [[Risorsa]]: un dato riutilizzabile (`.tres`)
- [[Editor di Godot]]: come avviare il gioco, aree di lavoro, pannelli

## Codice

- [[GDScript]]: il linguaggio, simile a Python
- [[Ciclo di gioco]]: `_ready`, `_process`, `_physics_process`
- [[Export e Inspector]]: variabili modificabili senza codice
- [[Input Map]]: azioni e tasti

## Grafica e animazione

- [[Pixel art]]: cosa serve perché sia nitida
- [[Spritesheet]]: tanti frame in un'immagine
- [[AtlasTexture]]: un ritaglio di un'immagine
- [[SpriteFrames]]: l'elenco delle animazioni
- [[AnimatedSprite2D]]: il nodo che le riproduce
- [[Filtro Nearest]]: pixel nitidi
- [[Viewport e stretch]]: risoluzione interna e finestra
- [[Y-sort]]: chi sta davanti e chi dietro

## Fisica e movimento

- [[CharacterBody2D]]: il corpo dei personaggi
- [[StaticBody2D]]: corpi fermi, muri
- [[Collisioni]]: forme, layer e mask

## Mappe

- [[TileSet]]: i tile disponibili e le loro proprietà
- [[TileMapLayer]]: la griglia in cui si dipingono
- [[Camera2D]]: l'inquadratura

## File e strumenti

- [[Percorsi res]]: `res://` e `user://`
- [[File import e uid]]: i file che Godot crea da solo
- [[Godot da riga di comando]]: opzioni da terminale e script `-s`

## Glossario veloce

| Termine | Significato |
|---|---|
| [[Nodo]] | Il mattone base, un oggetto con una funzione precisa |
| [[Scena]] (`.tscn`) | Un albero di nodi salvato, riutilizzabile |
| [[Risorsa]] (`.tres`) | Un dato riutilizzabile (animazioni, forme, materiali…) |
| [[Spritesheet]] | Un'immagine con tanti frame disposti a griglia |
| Inspector | Il pannello delle proprietà, vedi [[Export e Inspector]] |
| [[GDScript]] | Il linguaggio di scripting di Godot |
| Azione | Un nome collegato a dei tasti, vedi [[Input Map]] |
| Tile | Un quadratino dell'immagine del [[TileSet]] |
| [[Y-sort]] | Ordinamento di disegno in base alla y |
| Viewport | La "tela" del gioco, vedi [[Viewport e stretch]] |
