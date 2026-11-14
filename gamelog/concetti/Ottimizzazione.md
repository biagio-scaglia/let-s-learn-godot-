---
tags:
  - concetto
  - codice
aliases:
  - Prestazioni
  - FPS
  - Performance
---

# Ottimizzazione

← [[godot-basi|Basi di Godot]]

Far andare il gioco più veloce **senza cambiare quello che fa**. Tre regole, in ordine.

## 1. Prima misura

Senza un numero non sai se hai migliorato qualcosa, né di quanto. Per misurare davvero bisogna togliere i limiti:

```gdscript
DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)   # niente blocco a 60
Engine.max_fps = 0
```

poi contare i fotogrammi per qualche secondo, **più volte** (la prima misura è sempre più bassa: il gioco si sta "scaldando"). Nell'editor c'è anche *Debugger → Monitor*.

## 2. Invisibile non è trasparente

Un nodo con `modulate.a = 0` (trasparente) viene **disegnato lo stesso**: se ha uno [[Shader]], lo shader gira per ogni pixel, a ogni frame, per poi non mostrare niente. Un nodo con `visible = false` non costa nulla.

Nel progetto la nebbia del [[Ritorno dalla Morte]] (15 calcoli di [[Rumore]] per pixel, a schermo intero) restava trasparente per tutto il gioco. Nasconderla quando non serve ha portato il villaggio **da circa 245 a circa 330-370 FPS**.

## 3. Non rifare a ogni frame quello che non cambia

`_process()` gira decine o centinaia di volte al secondo. Dentro, meglio evitare:

| Da evitare | Meglio |
|---|---|
| Cercare un nodo ogni volta (`get_first_node_in_group`) | Cercarlo una volta in `_ready()` e tenerlo in una variabile |
| Impostare un valore che non è cambiato | Uscire subito: `if target == danger: return` |
| Controllare "è cambiato qualcosa?" a ogni frame | Un [[Segnali\|segnale]] che avvisa quando cambia |
| `_process` acceso dove non serve | `set_process(false)` |

L'[[Obiettivo]] è un esempio della terza riga: non controlla i ricordi a ogni frame, ascolta `Game.state_changed`.

> [!warning] Non ottimizzare a caso
> Rendere il codice più complicato per guadagnare niente è un peggioramento. Si ottimizza quello che la misura dice essere lento, e si rimisura dopo.

## Vedi anche

- [[Shader]] · [[Segnali]] · [[Ciclo di gioco]] · [[2026-11-14-ottimizzazioni-e-obiettivo]]
