---
tags:
  - concetto
aliases:
  - UI da codice
  - StyleBoxFlat da codice
---

# Interfaccia da codice

← [[godot-basi]]

Di solito l'interfaccia si costruisce nell'editor, in una [[Scena]]. Ma si può anche crearla in GDScript: `new()`, si impostano le proprietà, `add_child()`. Conviene quando la forma dipende dai dati.

Nel progetto:

- **I titoli di coda** ([[Titoli di coda]]): una lista di righe `[stile, testo]` diventa Label.
- **Il libro della Galleria** ([[Galleria]], `book_reader.gd`): copertina, pagine, ritratto, scritte, tutto in `_build()`.

```gdscript
func _panel(rect: Rect2, fill: Color, border: Color, border_width: int) -> Panel:
	var panel := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(3)
	panel.add_theme_stylebox_override("panel", style)
	panel.position = rect.position
	panel.size = rect.size
	return panel
```

## Cose da sapere

- `add_theme_color_override("font_color", ...)`, `add_theme_font_size_override(...)`, `add_theme_constant_override("outline_size", ...)`: cambiano **solo** quel nodo, il [[Theme]] resta com'è.
- `theme_type_variation = &"HintLabel"`: usa uno stile del Theme già pronto.
- **Le misure arrivano dopo.** Un Label appena creato non sa ancora quanto è alto: i [[Interfaccia (Control)|container]] lo calcolano al frame dopo. Nei titoli di coda: `await get_tree().process_frame`, poi `list.size.y`.
- `TextureRect` con `stretch_mode = STRETCH_KEEP_ASPECT_CENTERED` ed `expand_mode = EXPAND_IGNORE_SIZE`: un ritratto piccolo ingrandito senza deformarlo (con il [[Filtro Nearest]] resta pixel art).

## Vedi anche

- [[StyleBox]] · [[Theme]] · [[Disegnare con _draw]]
