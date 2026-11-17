// Mostra uno sprite solo DENTRO la forma di un'altra immagine. Serve all'iride
// dell'occhio grande: si muove, ma si vede solo dentro la mandorla dell'occhio.
shader_type canvas_item;

// L'immagine con la forma (dove non è trasparente, l'iride si vede).
uniform sampler2D shape : filter_nearest;
// Quanto è grande la forma, in pixel.
uniform vec2 shape_size = vec2(64.0, 28.0);
// Dove cade l'angolo in alto a sinistra di questo sprite, dentro la forma, in pixel.
// Lo aggiorna watching_eye.gd mentre l'iride si muove.
uniform vec2 offset = vec2(20.0, 2.0);

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	// Lo stesso punto, nelle coordinate della forma (da 0 a 1).
	vec2 p = (offset + UV / TEXTURE_PIXEL_SIZE) / shape_size;
	float inside = 0.0;
	if (p.x >= 0.0 && p.x <= 1.0 && p.y >= 0.0 && p.y <= 1.0) {
		inside = texture(shape, p).a;
	}
	COLOR = vec4(c.rgb, c.a * inside);
}
