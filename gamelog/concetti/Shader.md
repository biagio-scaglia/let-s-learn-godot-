---
tags:
  - concetto
  - grafica
aliases:
  - gdshader
  - ShaderMaterial
---

# Shader

← [[godot-basi|Basi di Godot]]

Un piccolo programma che la scheda video esegue **per ogni pixel**, per deciderne il colore. Serve per effetti che con i nodi normali sarebbero impossibili o lenti.

- Si scrive in un file **`.gdshader`**, in un linguaggio simile al C.
- Si applica a un nodo con un **`ShaderMaterial`** (proprietà *Material* nell'Inspector).
- Le variabili `uniform` compaiono nell'Inspector e si regolano senza toccare il codice.

```glsl
shader_type canvas_item;
uniform float strength : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	float d = length(UV - vec2(0.5)) * 1.414;   // 0 al centro, 1 negli angoli
	COLOR = vec4(0.0, 0.0, 0.0, smoothstep(0.4, 1.05, d) * strength);
}
```

- **`UV`**: la posizione nel rettangolo, da (0,0) a (1,1).
- **`COLOR`**: il colore che esce.
- **`smoothstep(a, b, x)`**: passa dolcemente da 0 a 1 mentre x va da a a b.

## Nel progetto

`effects/vignette.gdshader`: la **vignettatura**, che scurisce un po' gli angoli dello schermo. È su un `ColorRect` dentro un [[CanvasLayer]], così copre tutto lo schermo. Vedi [[Effetti visivi]].

## Vedi anche

- [[CanvasLayer]] · [[CanvasModulate]]
