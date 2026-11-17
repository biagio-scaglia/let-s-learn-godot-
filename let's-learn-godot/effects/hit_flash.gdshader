// Lampo di colpo: tinge lo sprite di un colore pieno (bianco), tenendo la sua forma.
// Si anima "amount" da 1 a 0 per un lampo breve quando qualcuno viene colpito.
shader_type canvas_item;

// 0 = sprite normale, 1 = tutto del colore del lampo.
uniform float amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0);

void fragment() {
	// COLOR qui contiene il "modulate"; il colore vero sta nella texture.
	vec4 c = texture(TEXTURE, UV) * COLOR;
	c.rgb = mix(c.rgb, flash_color.rgb, amount);
	COLOR = c;
}
