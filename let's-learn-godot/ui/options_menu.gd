extends Control
## Il pannello delle opzioni, usato sia dalla schermata iniziale sia dal menu di pausa.
## Le opzioni vere stanno in Settings, che le salva su file.
##
## Lingua e velocità del testo sono "selettori": un pulsante che mostra il valore.
## Invio (o un clic) passa al valore dopo, le frecce sinistra/destra scorrono.

## Emesso quando il giocatore torna indietro.
signal closed

@onready var panel: Control = $Panel
@onready var volume_slider: HSlider = %VolumeSlider
@onready var volume_value: Label = %VolumeValue
@onready var fullscreen_box: CheckBox = %Fullscreen
@onready var language_button: Button = %Language
@onready var text_speed_button: Button = %TextSpeed
@onready var shake_box: CheckBox = %Shake
@onready var flashes_box: CheckBox = %Flashes
@onready var back_button: MenuItem = %Back


func _ready() -> void:
	hide()
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_box.toggled.connect(_on_fullscreen_toggled)
	shake_box.toggled.connect(_on_shake_toggled)
	flashes_box.toggled.connect(_on_flashes_toggled)
	language_button.pressed.connect(_cycle_language.bind(1))
	text_speed_button.pressed.connect(_cycle_text_speed.bind(1))
	language_button.gui_input.connect(_on_selector_input.bind(_cycle_language))
	text_speed_button.gui_input.connect(_on_selector_input.bind(_cycle_text_speed))
	for control: Control in [volume_slider, fullscreen_box, language_button, text_speed_button, shake_box, flashes_box]:
		control.focus_entered.connect(Sfx.play.bind(Sfx.MOVE))
		control.mouse_entered.connect(control.grab_focus)
	back_button.pressed.connect(close)
	# Sul web lo schermo intero lo decide il browser (il suo pulsante): l'opzione non serve.
	fullscreen_box.visible = not OS.has_feature("web")


func open() -> void:
	# Mostra i valori attuali senza far partire i segnali (non è un cambiamento).
	volume_slider.set_value_no_signal(Settings.volume * 100.0)
	fullscreen_box.set_pressed_no_signal(Settings.fullscreen)
	shake_box.set_pressed_no_signal(Settings.screen_shake)
	flashes_box.set_pressed_no_signal(Settings.reduce_flashes)
	_update_volume_label()
	_update_selectors()
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


## Frecce sinistra/destra su un selettore: valore prima o dopo.
func _on_selector_input(event: InputEvent, cycle: Callable) -> void:
	if event.is_action_pressed("ui_left") or event.is_action_pressed("move_left"):
		cycle.call(-1)
		accept_event()
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("move_right"):
		cycle.call(1)
		accept_event()


func _cycle_language(step: int) -> void:
	var codes := Settings.LANGUAGES.keys()
	var i := codes.find(Settings.language)
	Settings.set_language(codes[posmod(i + step, codes.size())])
	Sfx.play(Sfx.CONFIRM)
	_update_selectors()


func _cycle_text_speed(step: int) -> void:
	Settings.set_text_speed(posmod(Settings.text_speed + step, Settings.TEXT_SPEEDS.size()))
	Sfx.play(Sfx.CONFIRM)
	_update_selectors()


## Il testo dei selettori: "< valore >". Il nome della lingua non si traduce
## (auto_translate_mode spento nella scena), la velocità sì.
func _update_selectors() -> void:
	language_button.text = "< %s >" % Settings.LANGUAGES[Settings.language]
	text_speed_button.text = "< %s >" % tr(Settings.TEXT_SPEED_NAMES[Settings.text_speed])


func _on_volume_changed(value: float) -> void:
	Settings.set_volume(value / 100.0)
	_update_volume_label()
	Sfx.play(Sfx.MOVE)   # si sente subito quanto è forte


func _on_fullscreen_toggled(on: bool) -> void:
	Settings.set_fullscreen(on)
	Sfx.play(Sfx.CONFIRM)


func _on_shake_toggled(on: bool) -> void:
	Settings.set_screen_shake(on)
	Sfx.play(Sfx.CONFIRM)


func _on_flashes_toggled(on: bool) -> void:
	Settings.set_reduce_flashes(on)
	Sfx.play(Sfx.CONFIRM)


func _update_volume_label() -> void:
	volume_value.text = "%d%%" % roundi(volume_slider.value)
