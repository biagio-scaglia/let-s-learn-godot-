class_name BattleTurnBar
extends PanelContainer
## La barra in alto a sinistra del combattimento: chi agisce ora (più grande, bordo
## dorato) e i prossimi cinque turni. Un turno che il nemico salterà è grigio.
## Non decide niente: battle.gd le dice di chi è il turno e lei disegna.

const HERO := "hero"
const ENEMY := "enemy"
## Quanti turni si vedono.
const SHOWN := 6

## Il ritratto di Subaru.
@export var hero_portrait: Texture2D

@onready var row: HBoxContainer = %TurnIcons


## Ridisegna la barra. "first" è chi agisce ora (HERO o ENEMY), "enemy_skips"
## quanti turni il nemico salterà, "enemy_face" la sua faccia.
func refresh(first: String, enemy_skips: int, enemy_face: Texture2D) -> void:
	for child in row.get_children():
		child.queue_free()
	var who := first
	var skips := enemy_skips
	for i in SHOWN:
		var skipped := who == ENEMY and skips > 0
		if skipped:
			skips -= 1
		# Un trattino separa un giro (Subaru + nemico) dal successivo.
		if i > 0 and who == HERO:
			var line := ColorRect.new()
			line.custom_minimum_size = Vector2(1, 14)
			line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			line.color = Color(0.92, 0.84, 0.62, 0.5)
			row.add_child(line)
		row.add_child(_icon(hero_portrait if who == HERO else enemy_face, who == HERO, i == 0, skipped))
		who = ENEMY if who == HERO else HERO


## Una casella: blu per Subaru, rossa per il nemico.
func _icon(face_texture: Texture2D, is_hero: bool, current: bool, skipped: bool) -> Control:
	var frame := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.2, 0.9) if is_hero else Color(0.2, 0.06, 0.08, 0.9)
	style.set_border_width_all(1)
	style.border_color = Color(1, 0.85, 0.45) if current else Color(0.6, 0.62, 0.72, 0.8)
	style.anti_aliasing = false
	frame.add_theme_stylebox_override("panel", style)
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var face := TextureRect.new()
	face.texture = face_texture
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	face.custom_minimum_size = Vector2(20, 20) if current else Vector2(14, 14)
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(face)
	if skipped:
		frame.modulate = Color(0.45, 0.45, 0.55, 0.8)
	return frame
