// Onda d'urto: un anello che si allarga e "piega" l'immagine che c'è sotto, come
// l'aria spostata da un colpo fortissimo. Va su un ColorRect grande quanto lo schermo.
shader_type canvas_item;

// Quello che è già stato disegnato sullo schermo (lo deformiamo).
uniform sampler2D screen : hint_screen_texture, filter_nearest;
// Il centro dell'onda, in coordinate dello schermo da 0 a 1.
uniform vec2 center = vec2(0.5);
// Quanto si è allargata (0 = appena partita, 1 = finita).
uniform float progress : hint_range(0.0, 1.0) = 0.0;
// Il raggio finale, in frazioni dell'altezza dello schermo.
uniform float max_radius = 0.35;
// Quanto è spesso l'anello e quanto sposta i pixel.
uniform float thickness = 0.06;
uniform float strength = 0.025;

void fragment() {
	// Correggiamo le proporzioni: lo schermo è più largo che alto, l'anello deve essere tondo.
	vec2 ratio = vec2(SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, 1.0);
	vec2 offset = (SCREEN_UV - center) * ratio;
	float dist = length(offset);
	float radius = progress * max_radius;
	// 1 sul bordo dell'anello, 0 lontano. Svanisce mentre si allarga.
	float ring = 1.0 - smoothstep(0.0, thickness, abs(dist - radius));
	float fade = 1.0 - progress;
	vec2 push = normalize(offset + 0.0001) * ring * strength * fade;
	COLOR = texture(screen, SCREEN_UV - push / ratio);
	// Un filo di luce sull'anello.
	COLOR.rgb += vec3(1.0, 0.9, 0.7) * ring * fade * 0.25;
}
