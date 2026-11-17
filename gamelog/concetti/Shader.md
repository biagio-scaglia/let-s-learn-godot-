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

### Nebbia e riavvolgimento

Per il [[Ritorno dalla Morte]]:

- `effects/miasma.gdshader`: nebbia di [[Rumore]] che avanza dai bordi. Usa `FRAGCOORD` (la posizione in pixel sullo schermo) arrotondata a blocchi di 3 pixel, per restare pixel art.
- `effects/rewind.gdshader`: legge lo schermo (`hint_screen_texture`) da un punto **ruotato** attorno al centro, di più al centro che ai bordi: il vortice. Legge rosso, verde e blu da punti un po' diversi (separazione dei colori) e alla fine mescola con il negativo (`1.0 - col`).

> [!warning] Parametri non salvati
> `material.get_shader_parameter("x")` restituisce `null` se nel materiale `x` non è mai stato cambiato: il valore predefinito sta solo nello shader. Se il codice deve leggerlo, scrivilo nel materiale.

### Transizione d'ingresso nel combattimento

`effects/battle_transition.gdshader`, su un `ColorRect` sopra tutto il [[Combattimento]]. Un parametro `progress` (da 0 a 1) lo anima un [[Tween]] con `tween_method()`.

![[transizione_battaglia.png|400]]

- **Le bande:** `floor((uv.y + uv.x * 0.35) * bande)` dà a ogni pixel il numero della sua banda, inclinata. Le bande pari entrano da sinistra, le dispari da destra; ognuna parte un po' dopo (`mod(riga, 3.0) * 0.12`), così fanno "a scaletta".
- **Fase 1** (`swirl = 1`): fuori dalle bande si vede lo schermo (la mappa), **ruotato** di più al centro come nel riavvolgimento, e sgranato: `floor(p / cella) * cella` legge un solo colore per quadretto, e il quadretto cresce da 1 a 14 pixel.
- **Fase 2** (`swirl = 0`): fuori dalle bande è trasparente; `progress` torna da 1 a 0 e le bande si ritirano, scoprendo la battaglia che intanto entra.

Lo stesso shader fa due cose diverse a seconda di un parametro: niente nodi in più.

Dal [[2026-11-17-vfx|17 novembre]] ha anche:

- **Un filo di luce** in punta a ogni banda: `reach - from_left` è quanto manca alla punta; `1.0 - smoothstep(0.0, edge_width, ...)` vale 1 proprio lì e scende a 0 poco dopo.
- **Aberrazione cromatica** nel vortice: il rosso si legge un po' spostato verso fuori, il blu verso dentro, il verde al suo posto. I bordi delle cose si sdoppiano in rosso e blu, come una lente che "vibra".

### Lampo bianco sullo sprite

`effects/hit_flash.gdshader`. `modulate` **moltiplica** i colori: rende più scuro o colorato, ma non bianco. Questo shader **mescola** il colore dello sprite con un colore pieno:

```glsl
vec4 c = texture(TEXTURE, UV) * COLOR;   // COLOR = il modulate
c.rgb = mix(c.rgb, flash_color.rgb, amount);
```

Con `amount = 1` resta solo la **sagoma** dello sprite, tutta bianca. Nel [[Combattimento]] `amount` va da 1 a 0 in 0,14 s a ogni colpo, e in 0,35 s quando i due entrano in scena.

### Onda d'urto

`effects/shockwave.gdshader`, su un `ColorRect` grande quanto lo schermo. Per ogni pixel calcola la distanza dal `center`; vicino al raggio attuale (`progress * max_radius`) **sposta** il punto da cui legge lo schermo, verso fuori. Così l'immagine si piega lungo un anello che si allarga.

- Le proporzioni: lo schermo è più largo che alto, quindi in coordinate da 0 a 1 un cerchio verrebbe ovale. Si moltiplica la x per larghezza/altezza prima di misurare.
- Il centro arriva da GDScript: la posizione nello `Stage` → `get_global_transform_with_canvas()` → pixel dello schermo → diviso per la grandezza della finestra.
- Serve un [[BackBufferCopy]] prima del `ColorRect`, se no legge una "foto" vecchia dello schermo.

## Vedi anche

- [[CanvasLayer]] · [[CanvasModulate]] · [[Rumore]] · [[BackBufferCopy]]
