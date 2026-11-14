extends CanvasLayer
## Il Ritorno dalla Morte. È un autoload chiamato "ReturnByDeath".
##
## die(): Subaru crolla, una nebbia nera e viola copre tutto, compare il game over.
## "Ritorna": lo schermo si avvita e Subaru si risveglia al punto di ritorno
## (Game.checkpoint). Il mondo torna com'era, ma lui si ricorda: Game.deaths resta.

## Cosa dice Subaru dopo il ritorno, a seconda di quante volte è morto (l'ultima si ripete).
const RETURN_LINES := [
	["...Eh?", "Ero... morto. Quell'oscurità mi ha preso.", "E invece sono qui, come se non fosse successo niente."],
	["Di nuovo qui...", "Allora non era un sogno. Quando muoio, torno indietro."],
	["Ancora...", "Non posso uscire da questo villaggio. Non ancora."],
]

@onready var darkness: ColorRect = $Darkness
@onready var fog: ColorRect = $Fog
@onready var miasma: CPUParticles2D = $Miasma
@onready var vortex: Sprite2D = $Vortex
@onready var panel: Control = $Panel
@onready var title: Label = %Title
@onready var count: Label = %Count
@onready var return_button: MenuItem = %Return
@onready var title_button: MenuItem = %ToTitle
@onready var rewind_fx: ColorRect = $RewindFx
@onready var impact: AudioStreamPlayer = $Impact
@onready var drone: AudioStreamPlayer = $Drone
@onready var rewind_sound: AudioStreamPlayer = $Rewind
@onready var glitch: AudioStreamPlayer = $Glitch

## True dal momento della morte fino al risveglio.
var is_active := false


func _ready() -> void:
	(drone.stream as AudioStreamOggVorbis).loop = true
	return_button.pressed.connect(_on_return)
	title_button.pressed.connect(_on_title)
	_reset()


## Rimette tutto invisibile, pronto per la prossima volta.
func _reset() -> void:
	darkness.modulate.a = 0.0
	_set_fog(0.0)
	# Nascosti, non solo trasparenti: un nodo invisibile non costa niente, mentre uno
	# trasparente fa girare lo stesso il suo shader su tutto lo schermo, a ogni frame.
	darkness.visible = false
	fog.visible = false
	miasma.emitting = false
	vortex.visible = false
	panel.visible = false
	rewind_fx.visible = false
	_set_rewind(0.0)
	drone.stop()
	for item in [return_button, title_button]:
		item.disabled = false


## Subaru muore. Chiamata dai confini del villaggio, ma va bene per qualsiasi morte.
func die() -> void:
	if is_active:
		return
	is_active = true
	Game.in_cutscene = true
	Game.deaths += 1
	var center := get_viewport().get_visible_rect().size / 2.0
	miasma.position = center
	vortex.position = center

	# 1. Il colpo: un tonfo basso, la camera trema, Subaru crolla.
	impact.play()
	var player := get_tree().get_first_node_in_group("player")
	if player:
		_shake(player.get_node_or_null("Camera2D"))
		if player.has_method("collapse"):
			player.collapse()

	# 2. La nebbia sale e il buio si chiude.
	darkness.visible = true
	fog.visible = true
	miasma.emitting = true
	drone.volume_db = -40.0
	drone.play()
	var t := create_tween().set_parallel()
	t.tween_property(darkness, "modulate:a", 0.55, 1.8).set_delay(0.3).set_trans(Tween.TRANS_SINE)
	# La nebbia striscia dai bordi verso il centro (shader miasma.gdshader).
	t.tween_method(_set_fog, 0.0, 0.8, 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(drone, "volume_db", -9.0, 1.5)
	await t.finished

	# 3. Il game over.
	_show_panel()


func _shake(camera: Camera2D) -> void:
	if camera == null:
		return
	var t := create_tween()
	for i in 8:
		var strength := 6.0 * (1.0 - i / 8.0)
		t.tween_property(camera, "offset", Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength, 0.04)
	t.tween_property(camera, "offset", Vector2.ZERO, 0.05)


func _show_panel() -> void:
	count.text = "Morte n. %d" % Game.deaths
	panel.visible = true
	panel.modulate.a = 0.0
	var title_y := title.position.y
	title.position.y = title_y - 10.0
	title.visible_ratio = 0.0
	var t := create_tween()
	t.tween_property(panel, "modulate:a", 1.0, 0.6)
	# Le lettere compaiono una alla volta, mentre il titolo scende.
	t.parallel().tween_property(title, "visible_ratio", 1.0, 0.9)
	t.parallel().tween_property(title, "position:y", title_y, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_callback(return_button.focus_silently)


## "Ritorna": il riavvolgimento, poi il risveglio al punto di ritorno.
func _on_return() -> void:
	for item in [return_button, title_button]:
		item.disabled = true
	rewind_sound.play()
	glitch.play()
	panel.visible = false
	vortex.visible = true
	vortex.scale = Vector2.ZERO
	vortex.modulate = Color(0.75, 0.45, 1.0, 0.0)
	rewind_fx.visible = true

	var t := create_tween().set_parallel()
	t.tween_method(_set_rewind, 0.0, 1.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_property(vortex, "scale", Vector2(6, 6), 1.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(vortex, "rotation", -TAU * 2.0, 1.4)
	t.tween_property(vortex, "modulate:a", 0.9, 0.6)
	t.tween_property(drone, "volume_db", -40.0, 1.2)
	await t.finished

	# Game.return_to_checkpoint fa la dissolvenza al nero: quando lo schermo è nero
	# togliamo i nostri effetti, così al risveglio non si vedono.
	_cleanup_when_black()
	await Game.return_to_checkpoint()

	is_active = false
	# Subaru si ricorda di essere morto.
	var lines: Array = RETURN_LINES[mini(Game.deaths, RETURN_LINES.size()) - 1]
	Game.in_cutscene = true
	await get_tree().create_timer(0.4).timeout
	Dialogue.start("Subaru", PackedStringArray(lines))
	await Dialogue.finished
	Game.in_cutscene = false


func _cleanup_when_black() -> void:
	await get_tree().create_timer(Fade.duration).timeout
	_reset()


## "Torna al titolo".
func _on_title() -> void:
	for item in [return_button, title_button]:
		item.disabled = true
	Game.change_scene(Game.TITLE_SCENE, "", "", false)
	await get_tree().create_timer(Fade.duration).timeout
	is_active = false
	_reset()


func _set_fog(value: float) -> void:
	(fog.material as ShaderMaterial).set_shader_parameter("amount", value)


func _set_rewind(value: float) -> void:
	(rewind_fx.material as ShaderMaterial).set_shader_parameter("amount", value)
