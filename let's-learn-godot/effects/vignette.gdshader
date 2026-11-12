// Vignettatura: scurisce leggermente i bordi dello schermo.
shader_type canvas_item;

// Quanto scuri diventano gli angoli (0 = niente, 1 = neri).
uniform float strength : hint_range(0.0, 1.0) = 0.4;
// Da che distanza dal centro inizia a scurire (1 = gli angoli).
uniform float radius : hint_range(0.0, 1.5) = 1.05;
// Quanto è graduale il passaggio.
uniform float softness : hint_range(0.01, 1.5) = 0.65;

void fragment() {
	// Distanza dal centro: 0 al centro, circa 1 negli angoli.
	float d = length(UV - vec2(0.5)) * 1.414;
	float v = smoothstep(radius - softness, radius, d);
	COLOR = vec4(0.0, 0.0, 0.0, v * strength);
}
