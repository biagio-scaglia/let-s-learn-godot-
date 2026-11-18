shader_type canvas_item;
// L'acqua del fossato: riflessi chiari che scorrono piano e una luce che "respira".
// Va sul TileMapLayer che contiene SOLO le piastrelle d'acqua.
//
// Non spostiamo le UV (pescheremmo pixel dalle piastrelle vicine nell'atlante):
// cambiamo solo il colore, in base alla posizione nel mondo.

// Grandezza dei "pixel" dell'effetto, in pixel del mondo (la mappa è scalata x2).
uniform float pixel_size = 2.0;
// Colore aggiunto sulle creste delle onde.
uniform vec3 shine_color : source_color = vec3(0.55, 0.75, 0.95);
// Quanto si vedono i riflessi (0 = niente).
uniform float shine = 0.45;
uniform float speed = 1.0;

varying vec2 world_pos;

void vertex() {
	// La posizione nel mondo di ogni vertice: gli effetti continuano da una piastrella all'altra.
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	// Arrotondiamo la posizione: l'effetto resta a quadretti, come la pixel art.
	vec2 p = floor(world_pos / pixel_size) * pixel_size;
	float t = TIME * speed;
	// Due onde che si incrociano: dove sono alte entrambe c'è un riflesso.
	float w = sin(p.x * 0.09 + t * 1.3 + sin(p.y * 0.2) * 1.5) * sin(p.y * 0.23 - t * 0.9);
	float crest = step(0.72, w);
	// Una luce che va e viene, lentissima, lungo il fossato.
	float breathe = 0.93 + 0.07 * sin(t * 0.7 + p.x * 0.015);
	c.rgb = c.rgb * breathe + shine_color * crest * shine;
	COLOR = c * COLOR;
}
