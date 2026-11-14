// Il "riavvolgimento" del Ritorno dalla Morte: lo schermo si avvita verso il centro,
// i colori si separano (rosso e blu scivolano ai lati) e tutto vira al viola, fino al negativo.
shader_type canvas_item;

// L'immagine già disegnata sotto questo nodo (il gioco, la nebbia…).
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

// 0 = schermo normale, 1 = effetto pieno. Lo anima ReturnByDeath.
uniform float amount : hint_range(0.0, 1.0) = 0.0;
// Quanto gira il vortice al centro, in radianti, con amount = 1.
uniform float swirl = 7.0;
// Quanto si separano i colori.
uniform float split = 0.014;
uniform vec4 tint : source_color = vec4(0.75, 0.6, 1.0, 1.0);

void fragment() {
	// Lavoriamo in coordinate "quadrate", sennò il vortice diventa un'ellisse.
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 d = SCREEN_UV - vec2(0.5);
	d.x *= aspect;

	// Gira di più al centro e niente ai bordi.
	float angle = swirl * amount * (1.0 - smoothstep(0.0, 0.9, length(d)));
	float s = sin(angle);
	float c = cos(angle);
	d = vec2(c * d.x - s * d.y, s * d.x + c * d.y);
	d.x /= aspect;
	vec2 uv = vec2(0.5) + d;

	// Tre letture spostate: una per colore.
	float off = split * amount;
	vec3 col = vec3(
		texture(screen_texture, uv + vec2(off, 0.0)).r,
		texture(screen_texture, uv).g,
		texture(screen_texture, uv - vec2(off, 0.0)).b);

	// Verso il grigio-viola, e nell'ultimo tratto verso il negativo.
	float grey = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, vec3(grey) * tint.rgb, amount);
	col = mix(col, vec3(1.0) - col, smoothstep(0.65, 1.0, amount) * 0.7);
	COLOR = vec4(col, 1.0);
}
