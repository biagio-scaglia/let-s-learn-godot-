shader_type canvas_item;
// Un riflesso di luce che attraversa una scritta in diagonale, ogni "period" secondi.
// Si accende solo sulle parti chiare delle lettere: il bordo scuro resta com'è.
//
// VERTEX nel vertex() è la posizione in pixel dentro il nodo (un Label largo 600):
// la passiamo al fragment() con una "varying", così sappiamo dove siamo nella scritta.

uniform float period = 5.0;        // ogni quanti secondi passa il riflesso
uniform float sweep = 1.1;         // quanto ci mette ad attraversare la scritta
uniform float width = 26.0;        // larghezza della striscia di luce, in pixel
uniform float strength = 0.6;      // quanto schiarisce
uniform float from_x = -60.0;      // da dove parte...
uniform float to_x = 660.0;        // ...e dove arriva
uniform vec3 shine_color : source_color = vec3(1.0, 0.95, 0.75);

varying vec2 local;

void vertex() {
	local = VERTEX;
}

void fragment() {
	// In un canvas_item COLOR arriva già come "colore della texture x colore del nodo".
	vec4 c = COLOR;
	float t = clamp(mod(TIME, period) / sweep, 0.0, 1.0);
	float center = mix(from_x, to_x, t);
	// La diagonale: più in basso, più a sinistra.
	float x = local.x - local.y * 0.5;
	float band = 1.0 - smoothstep(0.0, width, abs(x - center));
	// Solo il riempimento chiaro delle lettere, non il contorno.
	float bright = step(0.55, dot(c.rgb, vec3(0.333)));
	c.rgb = mix(c.rgb, shine_color, band * strength * bright * step(t, 0.999));
	COLOR = c;
}
