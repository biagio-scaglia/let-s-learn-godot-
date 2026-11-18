// La nebbia del bosco: banchi chiari e morbidi che scorrono lenti e si sfilacciano.
// Come cloud_shadows.gdshader, ma due strati che vanno in direzioni diverse e
// un colore chiaro al posto dell'ombra. Va su un ColorRect grande quanto la mappa.
shader_type canvas_item;

uniform vec4 fog_color : source_color = vec4(0.78, 0.74, 0.88, 1.0);
// Quanto è fitta (alfa massima).
uniform float density : hint_range(0.0, 1.0) = 0.35;
uniform float fog_scale = 0.006;
// Quanto cielo resta libero (più alto = meno nebbia).
uniform float coverage : hint_range(0.0, 1.0) = 0.42;
uniform vec2 wind_a = vec2(7.0, -2.0);
uniform vec2 wind_b = vec2(-4.0, 1.5);
uniform float pixel = 2.0;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += noise(p) * a;
		p *= 2.0;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 p = floor(world_pos / pixel) * pixel;
	// Due strati di nebbia che scorrono in direzioni diverse: dove si sommano è più fitta.
	float a = fbm((p - wind_a * TIME) * fog_scale);
	float b = fbm((p - wind_b * TIME) * fog_scale * 1.7 + 13.0);
	float n = a * 0.65 + b * 0.35;
	float fog = smoothstep(coverage, coverage + 0.25, n);
	// Bande "a gradini": la nebbia ha solo 4 livelli di trasparenza, come in pixel art.
	fog = floor(fog * 4.0) / 4.0;
	COLOR = vec4(fog_color.rgb, fog * density);
}
