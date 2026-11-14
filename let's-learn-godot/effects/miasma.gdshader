// La nebbia del Ritorno dalla Morte: banchi di foschia nera e viola che strisciano
// dai bordi dello schermo verso il centro, muovendosi piano come fumo.
shader_type canvas_item;

// 0 = niente nebbia, 1 = schermo coperto. Lo anima ReturnByDeath.
uniform float amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 dark_color : source_color = vec4(0.03, 0.0, 0.06, 1.0);
uniform vec4 glow_color : source_color = vec4(0.35, 0.08, 0.5, 1.0);
// Grandezza dei banchi di nebbia (più alto = banchi più piccoli).
uniform float scale = 3.0;
uniform float speed = 0.06;
// Grandezza dei "pixel" della nebbia, per restare in stile pixel art.
uniform float pixel = 3.0;

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
	for (int i = 0; i < 5; i++) {
		v += noise(p) * a;
		p = p * 2.0 + vec2(1.7, 9.2);
		a *= 0.5;
	}
	return v;
}

void fragment() {
	// A blocchetti di "pixel" pixel dello schermo.
	vec2 uv = floor(FRAGCOORD.xy / pixel) * pixel * SCREEN_PIXEL_SIZE;
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 p = uv * vec2(aspect, 1.0) * scale;
	float t = TIME * speed;

	// "Domain warping": il rumore sposta il rumore, e i banchi si arricciano come fumo.
	vec2 warp = vec2(fbm(p + vec2(t, -t)), fbm(p + vec2(-t * 1.3, t * 0.7) + 5.2));
	float fog = fbm(p + warp * 1.8 + vec2(0.0, t * 2.0));

	// Dai bordi verso il centro: la soglia scende man mano che amount sale.
	float edge = length((uv - 0.5) * vec2(aspect, 1.0));   // 0 al centro
	float reach = mix(-0.2, 1.8, amount);                  // dove arriva la nebbia
	float cover = smoothstep(reach + 0.35, reach - 0.15, 1.0 - edge + fog * 0.6);
	cover = max(cover, smoothstep(0.85, 1.0, amount) * 0.9);   // alla fine copre tutto

	vec3 col = mix(dark_color.rgb, glow_color.rgb, smoothstep(0.45, 0.8, fog));
	COLOR = vec4(col, clamp(cover, 0.0, 1.0) * clamp(amount * 1.5, 0.0, 1.0));
}
