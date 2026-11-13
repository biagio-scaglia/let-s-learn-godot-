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

Un secondo shader, `effects/pause_blur.gdshader`, **sfoca lo schermo** dietro al [[Menu di pausa]] e alla [[Schermata iniziale]]. Usa `hint_screen_texture`, cioè l'immagine già disegnata sotto, e ne legge una versione rimpicciolita (`textureLod`): più è piccola, più è sfocata.

### Raggi di sole e ombre delle nuvole

- `effects/sun_rays.gdshader`: fasci di luce dall'alto a sinistra. Ha **`render_mode blend_add`**: il suo colore si somma a quello sotto, come fa la luce.
- `effects/cloud_shadows.gdshader`: ombre che scorrono sul villaggio. Nel **`vertex()`** calcola la posizione nel mondo con `MODEL_MATRIX` e la passa al `fragment()` con una **`varying`**: così le ombre stanno attaccate al terreno e non allo schermo.

Entrambi usano il [[Rumore]] e `TIME` (i secondi da quando il gioco è partito) per muoversi.

> [!warning] Parametri non salvati
> `material.get_shader_parameter("x")` restituisce `null` se nel materiale `x` non è mai stato cambiato: il valore predefinito sta solo nello shader. Se il codice deve leggerlo, scrivilo nel materiale.

## Vedi anche

- [[CanvasLayer]] · [[CanvasModulate]] · [[Rumore]]
