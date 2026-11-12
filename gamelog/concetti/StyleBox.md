---
tags:
  - concetto
  - ui
aliases:
  - StyleBoxFlat
---

# StyleBox

← [[godot-basi|Basi di Godot]]

Una [[Risorsa]] che descrive **come si disegna lo sfondo** di un nodo di [[Interfaccia (Control)|interfaccia]]. La più usata è **`StyleBoxFlat`**:

| Proprietà | Cosa fa |
|---|---|
| `bg_color` | Colore di sfondo (anche semitrasparente) |
| `border_width_*`, `border_color` | Il bordo |
| `corner_radius_*` | Angoli arrotondati |
| `content_margin_*` | Spazio interno (per i container) |
| `anti_aliasing` | Bordi sfumati: **spento** per la [[Pixel art]] |

Si assegna nell'Inspector in *Theme Overrides → Styles*.

## Nel progetto

La [[Finestra di dialogo]] ha due StyleBoxFlat: riquadro scuro con bordo color crema, e etichetta del nome color crema con bordo scuro.

## Vedi anche

- [[Interfaccia (Control)]] · [[Font]]
