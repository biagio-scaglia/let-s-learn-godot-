---
tags:
  - concetto
  - nodo
  - grafica
aliases:
  - linea
---

# Line2D

← [[godot-basi|Basi di Godot]]

Un nodo che disegna una **linea spezzata**: si passa una lista di punti (`points`) e lui li unisce, con lo spessore e il colore che vuoi.

## Come si usa

```gdscript
var line := Line2D.new()
line.width = 10.0
line.default_color = Color.BLACK
line.points = PackedVector2Array([Vector2(0, 0), Vector2(50, 20), Vector2(100, 0)])
add_child(line)
```

- **`width_curve`**: una `Curve` che cambia lo spessore lungo la linea (da 0 = inizio a 1 = fine). Più grossa alla spalla, più sottile al polso.
- **`joint_mode = ROUND`**: gli angoli tra un pezzo e l'altro sono arrotondati, senza punte.
- **`antialiased = false`**: bordi netti, per la [[Pixel art]].
- I punti si possono **cambiare a ogni frame** in `_process()`: la linea si muove.

## Nel progetto

Le **braccia d'ombra** della [[Schermata iniziale]] (`ui/shadow_hand.gd`). Ogni braccio sono due `Line2D` una sopra l'altra: una più larga e viola (il bordo), una più stretta e quasi nera. I 15 punti vanno dalla spalla (fuori dallo schermo) alla mano, e a ognuno si somma un'onda:

```gdscript
var wave := sin(t * PI * 2.2 - _time * 3.0 + _phase) * sway * sin(t * PI)
```

`- _time * 3.0` fa **scorrere** l'onda lungo il braccio; `sin(t * PI)` vale 0 alle due estremità, così il braccio resta attaccato alla spalla e alla mano. Vedi [[2026-11-17-mani-d-ombra]].

## Vedi anche

- [[Tween]] · [[Shader]] · [[Effetti visivi]]
