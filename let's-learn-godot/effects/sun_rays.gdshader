// Raggi di sole: fasci di luce che scendono da un punto fuori dallo schermo, in alto a sinistra.
// Va su un ColorRect grande quanto lo schermo, dentro un CanvasLayer.
shader_type canvas_item;
// "blend_add": il colore si SOMMA a quello che c'è sotto, quindi può solo schiarire. Come la luce.
render_mode blend_add;

// Colore della luce.
uniform vec4 ray_color : source_color = vec4(1.0, 0.86, 0.55, 1.0);
// Quanto sono forti i raggi (0 = spenti). La cutscene d'apertura lo anima.
uniform float intensity : hint_range(0.0, 2.0) = 0.3;
// Da dove viene la luce, in coordinate dello schermo (0,0 = angolo in alto a sinistra).
uniform vec2 origin = vec2(-0.15, -0.35);
// Quanti fasci ci sono, e quanto velocemente cambiano.
uniform float ray_count = 14.0;
uniform float speed = 0.12;
// I raggi si spengono man mano che si allontanano dal sole.
uniform float reach = 1.5;

// Un numero "a caso" ma sempre uguale per lo stesso n.
float hash(float n) {
	return fract(sin(n) * 43758.5453);
}

// Rumore morbido in una dimensione: valori a caso collegati da curve dolci.
float noise(float x) {
	float i = floor(x);
	float f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(hash(i), hash(i + 1.0), f);
}

void fragment() {
	// Correggiamo la forma dello schermo (è più largo che alto), sennò i raggi si stirano.
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 p = (UV - origin) * vec2(aspect, 1.0);
	float angle = atan(p.y, p.x);
	float dist = length(p);

	// Ogni direzione (angolo) ha la sua luminosità: due rumori che scorrono in versi opposti.
	float t = TIME * speed;
	float rays = noise(angle * ray_count + t) * noise(angle * ray_count * 1.7 - t * 1.3);
	rays = smoothstep(0.12, 0.85, rays);

	// Più deboli lontano dal sole, e un alone vicino a lui.
	float fade = 1.0 - smoothstep(0.1, reach, dist);
	float glow = (1.0 - smoothstep(0.0, 0.8, dist)) * 0.35;

	COLOR = vec4(ray_color.rgb, (rays * fade + glow) * intensity);
}
