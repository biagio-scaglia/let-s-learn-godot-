// Sfoca e scurisce quello che c'è dietro (il gioco in pausa).
shader_type canvas_item;

// L'immagine dello schermo disegnata finora. "mipmap" = versioni sempre più piccole
// e sfocate dell'immagine: leggerne una più piccola è un modo economico di sfocare.
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// 0 = nessun effetto, 1 = effetto pieno (lo anima il menu di pausa).
uniform float amount : hint_range(0.0, 1.0) = 1.0;
uniform float max_blur : hint_range(0.0, 6.0) = 2.5;
uniform vec4 tint : source_color = vec4(0.06, 0.03, 0.1, 0.55);

void fragment() {
	vec3 c = textureLod(screen_texture, SCREEN_UV, max_blur * amount).rgb;
	COLOR = vec4(mix(c, tint.rgb, tint.a * amount), 1.0);
}
