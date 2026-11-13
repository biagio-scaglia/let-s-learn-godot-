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
- [[Autoload]]: una scena sempre presente, raggiungibile da tutti
- [[Gruppi]]: etichette per riconoscere i nodi
- [[Composizione]]: piccoli pezzi riutilizzabili messi insieme
- [[Cambio di scena]]: passare da una scena all'altra, punti d'arrivo
- [[Pausa]]: fermare il gioco, e chi continua a funzionare

## Codice

- [[GDScript]]: il linguaggio, simile a Python
- [[Dizionari]]: chiavi e valori
- [[Risorse personalizzate]]: i propri tipi di dati, come Item
- [[Salvare la partita]]: cosa salvare e come ricaricarlo
- [[Ciclo di gioco]]: `_ready`, `_process`, `_physics_process`
- [[Export e Inspector]]: variabili modificabili senza codice
- [[Segnali]]: avvisi tra nodi
- [[Classi globali]]: `class_name`, uno script diventa un tipo
- [[Tween]]: animare una proprietà dal codice
- [[Await]]: aspettare senza bloccare il gioco
- [[ConfigFile]]: salvare le impostazioni su file
- [[Input Map]]: azioni e tasti
- [[Eventi di input]]: `_unhandled_input` e tasti "usati"

## Grafica e animazione

- [[Pixel art]]: cosa serve perché sia nitida
- [[Spritesheet]]: tanti frame in un'immagine
- [[Charset]]: il formato RPG Maker per i personaggi
- [[AtlasTexture]]: un ritaglio di un'immagine
- [[SpriteFrames]]: l'elenco delle animazioni
- [[Sprite2D]]: un'immagine ferma
- [[AnimatedSprite2D]]: il nodo che le riproduce
- [[Filtro Nearest]]: pixel nitidi
- [[Viewport e stretch]]: risoluzione interna e finestra
- [[Y-sort]]: chi sta davanti e chi dietro

## Effetti

- [[Particelle]]: polvere, pollini, scintille
- [[Shader]]: programmi per ogni pixel
- [[CanvasModulate]]: una tinta su tutto il mondo
- [[Luci 2D]]: luci, buio e fiamme che tremolano
- [[CanvasLayer]]: livelli fermi rispetto allo schermo
- [[Audio]]: riprodurre suoni

## Interfaccia

- [[Interfaccia (Control)]]: Panel, Label, ancore
- [[StyleBox]]: sfondi e bordi
- [[Font]]: caratteri, anche pixel
- [[Theme]]: l'aspetto di tutti i menu in un posto solo
- [[Menu e focus]]: menu usabili con tastiera e mouse

## Fisica e movimento

- [[CharacterBody2D]]: il corpo dei personaggi
- [[StaticBody2D]]: corpi fermi, muri
- [[Area2D]]: zone che si accorgono di chi entra
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
| [[Autoload]] | Una scena caricata all'avvio e sempre disponibile |
| [[Segnali\|Segnale]] | Un avviso che un nodo manda quando succede qualcosa |
| [[Tween]] | Un'animazione di una proprietà, fatta dal codice |
| PNG | Personaggio non giocante, come il [[Saggio]] |
