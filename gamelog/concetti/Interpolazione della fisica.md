---
tags:
  - concetto
aliases:
  - Physics interpolation
  - reset_physics_interpolation
---

# Interpolazione della fisica

← [[godot-basi|Basi di Godot]]

La fisica di Godot fa **60 passi al secondo** (`_physics_process`), ma lo schermo può disegnare 120 o 144 immagini al secondo. Senza niente in mezzo, tra un passo di fisica e l'altro Subaru resta fermo per una o due immagini, poi salta avanti: su uno schermo veloce si vede uno **scatto**, soprattutto con la camera che lo segue e i pixel "agganciati" alla griglia.

L'**interpolazione della fisica** disegna ogni oggetto in una posizione *intermedia* tra il passo di fisica precedente e quello attuale, a ogni immagine. Il movimento sembra continuo a qualsiasi frequenza dello schermo.

## Come si usa

1. **L'opzione**: *Project Settings → Physics → Common → Physics Interpolation*, cioè `physics/common/physics_interpolation=true` in `project.godot`.
2. **Tutto ciò che si muove nel mondo, durante la fisica.** Il movimento con i tasti sta già in `_physics_process`. I [[Tween]] che spostano cose devono girare al ritmo della fisica:
   ```gdscript
   var t := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
   ```
3. **I teletrasporti si "azzerano"**: dopo aver spostato di colpo un nodo, `nodo.reset_physics_interpolation()`. Altrimenti per un'immagine lo si vede scivolare dal punto vecchio a quello nuovo.
4. **L'interfaccia si esclude**: menu, dialoghi, battaglia sono disegnati sullo schermo e si animano a ogni immagine. Su di loro `physics_interpolation_mode = OFF` (vale anche per i figli).
5. **La Camera2D** deve aggiornarsi durante la fisica (`process_callback = Physics`). Se non lo è, Godot la forza da solo e stampa un avviso.

> [!tip] Come provarlo
> La documentazione consiglia di abbassare per prova la fisica a **10 passi al secondo**: gli errori (cose mosse fuori dalla fisica, teletrasporti senza reset) diventano evidentissimi.

## Nel progetto

Attivata il [[2026-11-18-interpolazione|18 novembre]], su consiglio di un giocatore. Tween al ritmo della fisica: camminate scriptate di [[Subaru]] e dei PNG, respiro dei PNG, nemici che saltellano e gironzolano, nuvolette, oggetti per terra, lo sguardo degli occhi di pietra, le panoramiche delle cutscene e del titolo. Reset: arrivo in una scena (`level.gd`), inizio delle cutscene, il lampo dell'occhio di pietra, Emilia che si rimette dietro (`Follower.snap_behind()`). Esclusi: gli autoload d'interfaccia (`Game.SCREEN_AUTOLOADS`), le cutscene, l'interfaccia del titolo.

## Vedi anche

- [[Ciclo di gioco]] · [[Tween]] · [[Camera2D]] · [[Pixel art]]
