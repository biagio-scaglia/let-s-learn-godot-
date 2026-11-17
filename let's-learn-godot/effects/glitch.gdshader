// Glitch: un'immagine che "non si regge": strisce che scattano di lato, rosso e blu
// che si separano, righe da vecchio schermo e uno sfarfallio. Va su una TextureRect
// che mostra un SubViewport (così si "rompe" tutto insieme, figura e testo).
shader_type canvas_item;

// 0 = quasi pulita, 1 = a pezzi. La anima farewell.gd.
uniform float intensity : hint_range(0.0, 1.0) = 0.2;
// Di quanti pixel si separano rosso e blu, a intensità piena.
uniform float split_pixels = 3.0;
// Quante volte al secondo cambia il "disegno" del glitch: a scatti, non fluido.
uniform float steps_per_second = 12.0;

float hash(float n) {
	return fract(sin(n * 12.9898) * 43758.5453);
}

void fragment() {
	float t = floor(TIME * steps_per_second);
	vec2 px = TEXTURE_PIXEL_SIZE;
	vec2 uv = UV;
	// Strisce alte 3 pixel: alcune, a caso, scattano di lato.
	float band = floor(uv.y / px.y / 3.0);
	if (hash(band * 1.7 + t) < intensity * 0.45) {
		uv.x += (hash(band + t * 7.3) - 0.5) * 0.3 * intensity;
	}
	// Ogni tanto un colpo più forte: la separazione dei colori raddoppia.
	float kick = 1.0 + 2.0 * step(0.85, hash(t * 3.1));
	vec2 shift = vec2(split_pixels * px.x * intensity * kick, 0.0);
	vec4 mid = texture(TEXTURE, uv);
	vec4 left = texture(TEXTURE, uv + shift);
	vec4 right = texture(TEXTURE, uv - shift);
	vec3 color = vec3(left.r, mid.g, right.b);
	float alpha = max(mid.a, max(left.a, right.a));
	// Righe scure a una riga sì e una no, e uno sfarfallio.
	color *= 0.82 + 0.18 * step(0.5, fract(UV.y / px.y * 0.5));
	color *= 1.0 - intensity * 0.35 * hash(t * 5.7);
	COLOR = vec4(color, alpha) * COLOR;
}
