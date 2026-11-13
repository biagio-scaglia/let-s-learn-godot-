extends Control
## Il pannello delle opzioni, usato sia dalla schermata iniziale sia dal menu di pausa.
## Le opzioni vere stanno in Settings, che le salva su file.

## Emesso quando il giocatore torna indietro.
signal closed

@onready var panel: Control = $Panel
@onready var volume_slider: HSlider = %VolumeSlider
@onready var volume_value: Label = %VolumeValue
@onready var fullscreen_box: CheckBox = %Fullscreen
@onready var back_button: MenuItem = %Back


func _ready() -> void:
	hide()
	volume_slider.value_changed.connect(_on_volume_changed)
	volume_slider.focus_entered.connect(Sfx.play.bind(Sfx.MOVE))
	fullscreen_box.toggled.connect(_on_fullscreen_toggled)
	fullscreen_box.focus_entered.connect(Sfx.play.bind(Sfx.MOVE))
	fullscreen_box.mouse_entered.connect(fullscreen_box.grab_focus)
	volume_slider.mouse_entered.connect(volume_slider.grab_focus)
	back_button.pressed.connect(close)


func open() -> void:
	# Mostra i valori attuali senza far partire i segnali (non è un cambiamento).
	volume_slider.set_value_no_signal(Settings.volume * 100.0)
	fullscreen_box.set_pressed_no_signal(Settings.fullscreen)
	_update_volume_label()
	show()
	panel.pivot_offset = panel.size / 2.0
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.94, 0.94)
	var t := create_tween().set_parallel()
	t.tween_property(panel, "modulate:a", 1.0, 0.15)
	t.tween_property(panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	volume_slider.grab_focus.call_deferred()


func close() -> void:
	Sfx.play(Sfx.BACK)
	hide()
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause")):
		get_viewport().set_input_as_handled()
		close()


func _on_volume_changed(value: float) -> void:
	Settings.set_volume(value / 100.0)
	_update_volume_label()
	Sfx.play(Sfx.MOVE)   # si sente subito quanto è forte


func _on_fullscreen_toggled(on: bool) -> void:
	Settings.set_fullscreen(on)
	Sfx.play(Sfx.CONFIRM)


func _update_volume_label() -> void:
	volume_value.text = "%d%%" % roundi(volume_slider.value)
