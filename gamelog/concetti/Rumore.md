---
tags:
  - concetto
  - grafica
aliases:
  - Noise
  - fbm
  - Rumore procedurale
---

# Rumore

← [[godot-basi|Basi di Godot]]

Il **rumore** (*noise*) è il modo in cui gli [[Shader]] disegnano cose "naturali" (nuvole, fumo, acqua, fasci di luce) **senza nessuna immagine**: solo matematica.

## Dal caso al morbido

1. **Un numero a caso per ogni punto della griglia.** Il trucco classico: `fract(sin(n) * 43758.5453)`. Non è davvero casuale: lo stesso `n` dà sempre lo stesso numero, ed è proprio quello che serve.
2. **Collegare i punti con curve dolci.** Tra un punto e l'altro si mescolano i due valori con `mix()`, usando la curva `f * f * (3 - 2f)`: così non si vedono gli spigoli. Questo è il **value noise**.
3. **Sovrapporre più rumori (fbm).** Un rumore grande e forte, più uno piccolo e debole, più uno ancora più piccolo… Ogni "strato" (*ottava*) ha il doppio di dettaglio e metà forza. I bordi diventano frastagliati, come quelli di una nuvola.

```glsl
float fbm(vec2 p) {
	float value = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 4; i++) {
		value += noise(p) * amp;   // aggiungi uno strato
		p *= 2.0;                  // più fine
		amp *= 0.5;                // più debole
	}
	return value;
}
```

4. **Tagliare con `smoothstep`.** Il rumore va da 0 a 1 ovunque; con `smoothstep(0.55, 0.67, n)` resta solo la parte "alta": macchie separate con bordi morbidi.

## Domain warping: rumore che deforma il rumore

Per avere qualcosa che si **arriccia** come fumo, si usa il rumore per *spostare* il punto in cui si legge altro rumore:

```glsl
vec2 warp = vec2(fbm(p + vec2(t, -t)), fbm(p + vec2(-t, t) + 5.2));
float fog = fbm(p + warp * 1.8);
```

Le forme si stirano e si attorcigliano, e cambiano piano perché `warp` cambia con il tempo. È la nebbia del [[Ritorno dalla Morte]].

## Farlo muovere

Basta spostare il punto in cui si legge il rumore con il tempo: `p -= wind * TIME`. Le nuvole scivolano senza che nessun nodo si muova.

## Nel progetto

| Dove | Rumore |
|---|---|
| Ombre delle nuvole (`effects/cloud_shadows.gdshader`) | Rumore 2D con fbm, spinto dal vento |
| Nebbia del Ritorno dalla Morte (`effects/miasma.gdshader`) | fbm con *domain warping*, che avanza dai bordi verso il centro |
| Raggi di sole (`effects/sun_rays.gdshader`) | Rumore 1D sull'**angolo**: ogni direzione ha la sua luminosità, e così nascono i fasci |

Vedi [[Effetti visivi]].

> [!tip] In alternativa
> Godot ha anche una risorsa **`NoiseTexture2D`** (con `FastNoiseLite`) che genera un'immagine di rumore da passare allo shader come `uniform sampler2D`. Comoda e regolabile dall'Inspector; scriverlo a mano serve a capire come funziona.

## Vedi anche

- [[Shader]] · [[Effetti visivi]]
