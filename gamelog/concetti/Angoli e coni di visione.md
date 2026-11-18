---
tags:
  - concetto
aliases:
  - angle_difference
  - Cono di visione
---

# Angoli e coni di visione

← [[godot-basi|Basi di Godot]]

Per sapere se qualcosa "vede" un punto servono due domande: è **abbastanza vicino**? È **nella direzione in cui guarda**?

## Come si usa

```gdscript
var to_point := point - eye_position          # il vettore dall'occhio al punto
if to_point.length() > sight:                  # troppo lontano
	return false
var off := absf(angle_difference(look_angle, to_point.angle()))
return off < deg_to_rad(cone / 2.0)            # dentro metà dell'apertura
```

- `vettore.angle()`: la direzione di un vettore, in radianti (0 = destra, `PI/2` = giù).
- `angle_difference(a, b)`: di quanto bisogna girare da `a` a `b`, **sempre tra −π e π**. Non si possono sottrarre gli angoli e basta: tra 350° e 10° la differenza vera è 20°, non 340°.
- `deg_to_rad()` / `rad_to_deg()`: da gradi a radianti e ritorno. Le proprietà `rotation_degrees` lavorano in gradi, i calcoli in radianti.
- `Vector2.from_angle(a)`: il vettore lungo 1 che punta nella direzione `a`. Comodo per disegnare un ventaglio di punti (il cono) o per scegliere una direzione a caso: `Vector2.from_angle(randf() * TAU)`.

> [!tip] Il cono si vede
> Il cono è un `Polygon2D` figlio del nodo che ruota: un ventaglio di punti con i colori dei vertici (`vertex_colors`) che sfumano verso la trasparenza. Così il giocatore *vede* dove guarda l'occhio, ed è un enigma giusto.

## Nel progetto

- Gli occhi di pietra del [[Bosco Senza Tempo]] (`stone_eye.gd`): `sees(point)`.
- I nemici che gironzolano: una direzione a caso con `Vector2.from_angle` ([[Nemici#Gironzolano]]).

## Vedi anche

- [[Tween]] · [[Collisioni]] · [[2026-11-18-occhi-e-gelo]]
