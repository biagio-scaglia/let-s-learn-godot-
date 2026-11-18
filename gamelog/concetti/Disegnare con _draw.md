---
tags:
  - concetto
aliases:
  - _draw
  - draw_rect
---

# Disegnare con _draw

← [[godot-basi]]

Ogni `CanvasItem` (Node2D, Control…) può disegnarsi da solo, senza immagini: basta scrivere la funzione `_draw()` e usare i comandi `draw_*`.

```gdscript
func _draw() -> void:
	draw_rect(Rect2(-19, -7, 38, 12), Color(0.12, 0.08, 0.16))  # il bordo scuro
	draw_rect(Rect2(-18, -6, 36, 10), Color(0.62, 0.6, 0.7))    # la pietra
	draw_rect(Rect2(-18, -6, 36, 3), Color(0.78, 0.76, 0.86))   # la luce sopra
```

È il piedistallo delle vetrine della [[Galleria]] (`exhibit.gd`): tre rettangoli, uno sopra l'altro.

- `_draw()` **non** viene chiamata a ogni frame: Godot la chiama una volta e si ricorda il disegno. Se qualcosa cambia, si chiede di ridisegnare con `queue_redraw()`.
- Le coordinate sono quelle del nodo: (0, 0) è la sua posizione.
- I figli si disegnano **sopra** quello che disegna il genitore: per questo la statua sta sopra il piedistallo.
- Ci sono anche `draw_circle`, `draw_line`, `draw_polygon`, `draw_texture`, `draw_string`…

Quando conviene? Per forme semplici e cose che cambiano con i dati (una barra, un grafico, un piedistallo largo quanto serve). Per disegni veri meglio uno [[Sprite2D]].

## Vedi anche

- [[Interfaccia da codice]] · [[Nodo]]
