---
tags:
  - concetto
  - codice
aliases:
  - await
  - Coroutine
---

# Await

← [[godot-basi|Basi di Godot]]

**`await`** mette in pausa una funzione finché qualcosa non è finito, **senza bloccare il gioco**: tutto il resto continua a muoversi e disegnarsi.

```gdscript
await Fade.fade_out()                      # aspetta che lo schermo sia nero
get_tree().change_scene_to_file(path)
await get_tree().process_frame             # aspetta il frame successivo
await create_timer(0.5).timeout            # aspetta mezzo secondo
await tween.finished                       # aspetta la fine di un Tween
await get_tree().scene_changed             # aspetta che la nuova scena sia pronta
```

Si può aspettare:

- un **[[Segnali|segnale]]** (`tween.finished`, `timer.timeout`, `get_tree().process_frame`…);
- un'altra funzione che a sua volta usa `await` (come `Fade.fade_out()`).

## Nel progetto

| Dove | Cosa aspetta |
|---|---|
| [[Game]] `change_scene()` | La dissolvenza, poi due frame perché la nuova scena sia pronta |
| [[Dissolvenza]] | La fine del [[Tween]] |
| [[Finestra di dialogo]] `_close()` | La fine dell'animazione di chiusura |
| [[Intro]] | Subaru che arriva in piazza, le pause, il dialogo: una [[Cutscene]] |
| Tutti i test | Timer e frame, per dare tempo al gioco |

## Aspettare un valore

`await` restituisce quello che porta il segnale. `Battle.start()` finisce con `return await finished`, e `finished` porta il risultato: così chi chiama scrive

```gdscript
var result: String = await Battle.start(data)
```

e riceve `"win"`, `"lose"` o `"fled"` quando il combattimento è davvero finito. Vedi [[Combattimento]].

## Vedi anche

- [[Segnali]] · [[Tween]] · [[Cambio di scena]]
