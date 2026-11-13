// Ombre delle nuvole: macchie scure e morbide che scorrono sul mondo, spinte dal vento.
// Va su un ColorRect grande quanto la mappa, disegnato sopra il mondo.
shader_type canvas_item;

// Colore dell'ombra (un blu scuro sembra più naturale del nero).
uniform vec4 shadow_color : source_color = vec4(0.12, 0.14, 0.3, 1.0);
// Quanto sono scure.
uniform float strength : hint_range(0.0, 1.0) = 0.2;
// Grandezza delle nuvole: più piccolo = nuvole più grandi.
uniform float cloud_scale = 0.0045;
// Quanto cielo è coperto (più alto = meno nuvole).
uniform float coverage : hint_range(0.0, 1.0) = 0.55;
// Vento, in pixel al secondo.
uniform vec2 wind = vec2(9.0, 4.0);
// Grandezza dei "pixel" delle ombre, per restare in stile pixel art.
uniform float pixel = 2.0;

// La posizione nel mondo di ogni punto: così le ombre stanno ferme sul terreno
// quando la camera si muove, e non "attaccate" allo schermo.
varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Rumore morbido in due dimensioni.
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// "fbm": tanti rumori sovrapposti, ognuno più fine e più debole. Dà bordi da nuvola.
float fbm(vec2 p) {
	float value = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 4; i++) {
		value += noise(p) * amp;
		p *= 2.0;
		amp *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 p = floor(world_pos / pixel) * pixel;   // a blocchetti, come i pixel della mappa
	p -= wind * TIME;
	float n = fbm(p * cloud_scale);
	float shadow = smoothstep(coverage, coverage + 0.12, n);
	COLOR = vec4(shadow_color.rgb, shadow * strength);
}
