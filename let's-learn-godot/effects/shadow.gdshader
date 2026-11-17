// Ombra viva: lo sprite ondeggia di un pixel come fumo, e può "sciogliersi"
// pixel per pixel, con un bordo viola acceso dove si sta disfacendo.
// Lo usano le mani d'ombra della schermata iniziale.
shader_type canvas_item;

// 0 = intera, 1 = sparita del tutto.
uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
// Di quanti pixel ondeggia (0 = ferma).
uniform float wobble_pixels = 1.0;
uniform float wobble_speed = 5.0;
uniform vec4 edge_color : source_color = vec4(0.75, 0.4, 1.0, 1.0);

// Un numero "a caso" ma sempre uguale per lo stesso pixel.
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	// In quale pixel della texture siamo: così l'effetto resta "a quadretti".
	vec2 px = floor(UV / TEXTURE_PIXEL_SIZE);
	vec2 uv = UV;
	// Ogni colonna sale o scende di un pixel, con un'onda che scorre.
	uv.y += round(sin(px.x * 0.45 + TIME * wobble_speed)) * wobble_pixels * TEXTURE_PIXEL_SIZE.y;
	vec4 c = texture(TEXTURE, uv) * COLOR;

	float n = hash(px);
	if (n < dissolve) {
		c.a = 0.0;
	} else if (n < dissolve + 0.15 && dissolve > 0.0) {
		c.rgb = mix(c.rgb, edge_color.rgb, 0.85);
	}
	COLOR = c;
}
