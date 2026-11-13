extends CanvasLayer
## Il menu di pausa. È un autoload chiamato "Pause": con Esc si apre in qualsiasi livello.
## Mette in pausa tutto il gioco (get_tree().paused), tranne sé stesso.

@onready var blur: ColorRect = $Blur
@onready var panel: Control = $Panel
@onready var hint: Control = $Hint
@onready var options: Control = $OptionsMenu
@onready var resume_button: MenuItem = %Resume
@onready var save_button: MenuItem = %Save
@onready var options_button: MenuItem = %Options
@onready var title_button: MenuItem = %ToTitle
@onready var quit_button: MenuItem = %Quit

var is_open := false
var _tween: Tween


func _ready() -> void:
	# Deve funzionare anche quando il resto del gioco è in pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_button.pressed.connect(close)
	save_button.pressed.connect(_save)
	options_button.pressed.connect(_open_options)
	title_button.pressed.connect(_back_to_title)
	quit_button.pressed.connect(get_tree().quit)
	options.closed.connect(_on_options_closed)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	if is_open:
		if options.visible:
			return   # Esc nelle opzioni lo gestiscono le opzioni: tornano qui
		get_viewport().set_input_as_handled()
		close()
	elif Game.can_open_menu():
		get_viewport().set_input_as_handled()
		open()


func open() -> void:
	is_open = true
	get_tree().paused = true
	visible = true
	panel.visible = true
	hint.visible = true
	options.hide()
	Sfx.play(Sfx.CONFIRM)

	panel.pivot_offset = panel.size / 2.0
	panel.scale = Vector2(0.92, 0.92)
	_animate(1.0, 0.22)
	resume_button.focus_silently()


func close() -> void:
	Sfx.play(Sfx.BACK)
	await _animate(0.0, 0.15)
	visible = false
	is_open = false
	get_tree().paused = false


## Porta l'effetto (sfocatura, pannello) a "target": 1 = aperto, 0 = chiuso.
func _animate(target: float, duration: float) -> void:
	if _tween:
		_tween.kill()
	var start: float = blur.material.get_shader_parameter("amount")
	_tween = create_tween().set_parallel()
	_tween.tween_method(_set_blur, start, target, duration)
	_tween.tween_property(panel, "modulate:a", target, duration)
	_tween.tween_property(hint, "modulate:a", target, duration)
	_tween.tween_property(panel, "scale", Vector2.ONE if target > 0.5 else Vector2(0.92, 0.92), duration) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await _tween.finished


func _set_blur(value: float) -> void:
	blur.material.set_shader_parameter("amount", value)


func _save() -> void:
	if SaveSystem.save_game():
		Sfx.play(Sfx.SAVE)
		Hud.show_message("Partita salvata")
	else:
		Hud.show_message("Non è stato possibile salvare")


func _open_options() -> void:
	panel.visible = false
	hint.visible = false
	options.open()


func _on_options_closed() -> void:
	panel.visible = true
	hint.visible = true
	options_button.focus_silently()


func _back_to_title() -> void:
	# Il menu resta visibile mentre lo schermo diventa nero, poi sparisce.
	Game.change_scene(Game.TITLE_SCENE, "", "", false)
	await get_tree().create_timer(Fade.duration, true, false, true).timeout
	visible = false
	is_open = false
