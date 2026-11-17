// La transizione d'ingresso nel combattimento.
// Fase 1 (swirl = 1): la mappa gira su se stessa, si sgrana in quadrettoni e intanto
// delle bande nere inclinate entrano dai lati, alternate, finché coprono tutto.
// Fase 2 (swirl = 0): restano solo le bande, che si ritirano e scoprono la battaglia.
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// 0 = niente, 1 = tutto coperto. Lo anima battle.gd con un Tween.
uniform float progress : hint_range(0.0, 1.0) = 0.0;
// 1 = si vede la mappa che gira; 0 = fuori dalle bande è trasparente.
uniform float swirl : hint_range(0.0, 1.0) = 1.0;
// Quante bande.
uniform float bands = 9.0;
uniform vec4 band_color : source_color = vec4(0.01, 0.01, 0.04, 1.0);
// Il filo di luce in punta a ogni banda, e quanto è spesso.
uniform vec4 edge_color : source_color = vec4(1.0, 0.45, 0.25, 1.0);
uniform float edge_width = 0.025;
// Quanto si separano rosso e blu nel vortice (aberrazione cromatica).
uniform float split = 0.012;

void fragment() {
	vec2 uv = SCREEN_UV;

	// Le bande: inclinate (y + x * 0.35), una entra da sinistra e la successiva da destra.
	float row = floor((uv.y + uv.x * 0.35) * bands);
	float from_left = mod(row, 2.0) < 1.0 ? uv.x : 1.0 - uv.x;
	// Ogni banda parte un po' dopo la precedente: fa "a scaletta".
	float reach = progress * 1.6 - mod(row, 3.0) * 0.12;
	bool covered = from_left < reach;

	if (covered) {
		COLOR = band_color;
		// Vicino alla punta della banda: una linea luminosa, come una lama.
		float edge = 1.0 - smoothstep(0.0, edge_width, reach - from_left);
		COLOR.rgb = mix(COLOR.rgb, edge_color.rgb, edge * edge_color.a);
	} else if (swirl > 0.5) {
		// Il vortice: più forte al centro, cresce con progress.
		vec2 d = uv - 0.5;
		float angle = progress * progress * 5.0 * max(0.0, 1.0 - length(d) * 1.3);
		float s = sin(angle);
		float c = cos(angle);
		d = vec2(d.x * c - d.y * s, d.x * s + d.y * c) * (1.0 - 0.35 * progress);
		vec2 p = 0.5 + d;
		// I quadrettoni: da 1 a 14 pixel dello schermo.
		vec2 cell = SCREEN_PIXEL_SIZE * mix(1.0, 14.0, progress);
		p = (floor(p / cell) + 0.5) * cell;
		// Rosso e blu presi un po' spostati, verso fuori e verso dentro: l'immagine "vibra".
		vec2 shift = normalize(d + 0.0001) * split * progress;
		vec3 col;
		col.r = texture(screen_texture, p + shift).r;
		col.g = texture(screen_texture, p).g;
		col.b = texture(screen_texture, p - shift).b;
		// Si sbianca un po' all'inizio (il "lampo") e poi si scurisce.
		col = mix(col, vec3(1.0), 0.35 * sin(progress * 3.14159));
		col *= 1.0 - 0.5 * progress;
		COLOR = vec4(col, 1.0);
	} else {
		COLOR = vec4(0.0);
	}
}
