---
tags:
  - concetto
  - grafica
aliases:
  - Viewport
  - Risoluzione
  - Stretch
---

# Viewport e stretch

← [[godot-basi|Basi di Godot]]

- Il **viewport** è la "tela" del gioco, con la sua risoluzione *interna*: posizioni e dimensioni si ragionano lì.
- La **finestra** può essere più grande: lo **stretch** ingrandisce il viewport per riempirla.

| Impostazione (*Impostazioni progetto → Display → Window*) | Valore |
|---|---|
| Size → Viewport Width / Height | 640 × 360 |
| Size → Window Width / Height Override | 1280 × 720 |
| Stretch → Mode | `canvas_items` |
| Stretch → Aspect | `expand` |
| Stretch → Scale Mode | `integer` |

Con **Scale Mode = integer** il gioco si ingrandisce solo di numeri interi (×2, ×3…) anche se la finestra viene ridimensionata: niente pixel deformati.

In più, *Rendering → 2D → Snap → Snap 2D Transforms to Pixel* arrotonda le posizioni al pixel, così la camera che si muove piano non fa tremolare i personaggi.

Con 640×360 ingrandito a 1280×720, ogni pixel diventa 2×2: perfetto per la [[Pixel art]] insieme al [[Filtro Nearest]].

> [!tip] Impostazioni avanzate
> Alcune voci si vedono solo attivando *Impostazioni avanzate* in alto a destra nella finestra delle impostazioni.

## Vedi anche

- [[Pixel art]] · [[Camera2D]]
