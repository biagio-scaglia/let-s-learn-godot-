---
tags:
  - progetto
  - ui
aliases:
  - Fade
  - Transizione
---

# Dissolvenza

← [[Gamelog]]

Un [[Autoload]] chiamato **`Fade`** (`ui/fade.tscn`): un rettangolo nero sopra a tutto ([[CanvasLayer]] 20) che compare e scompare con un [[Tween]].

- All'avvio il gioco **compare dal nero** in 0,4 secondi.
- È pronto per il **cambio di scena** (il prossimo passo dell'RPG):

```gdscript
await Fade.fade_out()
get_tree().change_scene_to_file("res://world/casa.tscn")
await Fade.fade_in()
```

`await` aspetta che la funzione finisca prima di andare avanti: così la scena cambia solo quando lo schermo è già nero.

Funziona anche in [[Pausa]], così "Torna al titolo" dal [[Menu di pausa]] può sfumare al nero.

Fa parte degli [[Effetti visivi]].
