extends Node2D
## Il filmato iniziale, prima del titolo. Quattro "inquadrature" fatte con le scene
## vere del gioco (il castello, il villaggio, il bosco) senza Subaru, con una camera
## che scorre, le bande nere e una voce narrante scritta. Poi l'occhio, e il titolo.
##
## I tempi seguono la musica (prologue_theme.wav): notte 0-7 s, villaggio 7-17.5,
## bosco 17.5-29, il colpo a 29.5. Ogni passo aspetta il suo secondo con _at().
## Qualsiasi tasto lo salta. Il titolo lo rilancia se nessuno tocca niente per un po'.

const CASTLE := "res://world/castle.tscn"
const FOREST := "res://world/forest.tscn"
## Il colore che "spegne" il mondo quando la storia si fa scura.
const SHADOW := Color(0.08, 0.02, 0.14)

@onready var stage: Node2D = $Stage
@onready var camera: Camera2D = $Camera2D
@onready var shade: ColorRect = %Shade
@onready var black: ColorRect = %Black
@onready var flash: ColorRect = %Flash
@onready var presents: Label = %Presents
@onready var narration: Label = %Narration
@onready var skip_hint: Label = %SkipHint
@onready var eye_holder: Node2D = %EyeHolder
@onready var music: AudioStreamPlayer = %Music

## Da quanti secondi va il filmato. È il tempo del gioco (sommato in _process), non
## quello dell'orologio: così resta a tempo con la musica anche se il gioco rallenta,
## o se lo si registra in un video con il Movie Maker di Godot.
var _clock := 0.0
## True quando il filmato è finito o è stato saltato: chi aspetta smette.
var _done := false
var _camera_tween: Tween
## Sul web: true finché si aspetta il primo clic (vedi _ready).
var _waiting_start := false
var _start_label: Label

## Sul web basta chiedere il clic una volta: poi l'audio resta sbloccato.
static var _audio_unlocked := false

## I tasti che non saltano il filmato: volume e multimedia (li premi per sentire meglio,
## non per saltare), modificatori e simili.
const IGNORED_KEYS := [
	KEY_VOLUMEUP, KEY_VOLUMEDOWN, KEY_VOLUMEMUTE,
	KEY_MEDIAPLAY, KEY_MEDIASTOP, KEY_MEDIAPREVIOUS, KEY_MEDIANEXT, KEY_MEDIARECORD,
	KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_META, KEY_CAPSLOCK, KEY_NUMLOCK, KEY_SCROLLLOCK,
	KEY_PRINT, KEY_UNKNOWN,
]


func _ready() -> void:
	camera.make_current()
	black.color.a = 1.0
	shade.color = Color(SHADOW, 0.0)
	flash.color.a = 0.0
	flash.self_modulate.a = Settings.flash_amount()   # accessibilità: lampi attenuati
	for label in [presents, narration]:
		label.modulate.a = 0.0
	skip_hint.modulate.a = 0.0
	# Nel browser l'audio parte solo dopo un clic o un tasto sulla pagina: se il
	# filmato partisse subito, la musica resterebbe muta. Allora prima si chiede.
	if OS.has_feature("web") and not _audio_unlocked:
		_ask_to_start()
		return
	_start()


func _start() -> void:
	create_tween().tween_property(skip_hint, "modulate:a", 1.0, 1.0).set_delay(1.0)
	_play()


func _ask_to_start() -> void:
	_waiting_start = true
	_start_label = Label.new()
	_start_label.text = "Clicca o premi un tasto per iniziare"
	_start_label.theme_type_variation = &"SubtitleLabel"
	_start_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_start_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_start_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	narration.get_parent().add_child(_start_label)
	var t := create_tween().set_loops()
	t.tween_property(_start_label, "modulate:a", 0.35, 0.8).set_trans(Tween.TRANS_SINE)
	t.tween_property(_start_label, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)


## Un tasto "vero" o un clic: salta il filmato (o, sul web, lo fa partire).
func _unhandled_input(event: InputEvent) -> void:
	if _done or not is_skip_input(event):
		return
	get_viewport().set_input_as_handled()
	if _waiting_start:
		_waiting_start = false
		_audio_unlocked = true
		_start_label.queue_free()
		_start()
	else:
		_finish()


## True per un tasto premuto (non volume, multimedia o modificatori), un clic o un
## pulsante del joypad. Static: la usano anche i test.
static func is_skip_input(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.pressed and not event.echo and event.keycode not in IGNORED_KEYS
	if event is InputEventMouseButton:
		# La rotella non conta: si muove anche senza volerlo.
		return event.pressed and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]
	if event is InputEventJoypadButton:
		return event.pressed
	return false


func _play() -> void:
	_clock = 0.0
	music.play()

	# 0. Nero: chi presenta.
	_show_text(presents, 0.4, 2.2)

	# 1. La Rocca d'Argento, di notte: la camera scende verso il ponte.
	if not await _at(3.0): return
	shade.color = Color(0.04, 0.05, 0.2, 0.4)   # è notte: tutto un po' blu
	_backdrop(CASTLE, Vector2(384, 150), Vector2(384, 330), 4.5)
	_cut_in(0.8)
	_say("Una notte, due viaggiatori lasciarono la Rocca d'Argento.", 3.6, 3.0)

	# 2. Erbalta, di giorno. Poi la luce si spegne piano.
	if not await _at(7.0): return
	await _cut_out(0.4)
	if _done: return
	shade.color = Color(SHADOW, 0.0)   # di giorno: nessuna ombra (per ora)
	_backdrop(Game.FIRST_LEVEL, Vector2(430, 300), Vector2(800, 420), 11.0)
	_cut_in(0.6)
	_say("Andavano a Erbalta: un villaggio tranquillo, dove nessuno invecchia.", 7.8, 3.8)
	_say("...e da cui nessuno se n'è mai andato.", 12.4, 4.2)
	_darken(0.45, 12.4, 4.5)

	# 3. Il bosco a nord: la camera sale tra gli alberi, il buio cresce.
	if not await _at(17.5): return
	await _cut_out(0.4)
	if _done: return
	shade.color.a = 0.15
	_backdrop(FOREST, Vector2(640, 920), Vector2(640, 380), 12.0)
	_cut_in(0.6)
	_say("Nel bosco a nord, qualcosa non chiude mai gli occhi.", 18.6, 4.2)
	_say("E guarda.", 24.2, 4.0)
	_darken(0.7, 20.0, 9.0)

	# 4. Il colpo: lampo bianco, poi nel buio si apre l'occhio.
	if not await _at(29.4): return
	flash.color.a = 1.0
	create_tween().tween_property(flash, "color:a", 0.0, 0.6)
	black.color.a = 1.0
	_clear_stage()
	# L'occhio è grande il doppio: lo ingrandisce il suo contenitore (EyeHolder ha
	# scala 2), perché l'occhio usa la sua scala per aprirsi e sbattere le palpebre.
	var eye := WatchingEye.new()
	eye_holder.add_child(eye)
	if not await _at(29.7): return
	eye.open(0.5)
	if not await _at(32.0): return
	create_tween().tween_property(eye, "scale:y", 0.0, 0.25).set_trans(Tween.TRANS_SINE)

	# 5. L'ultima riga del libro nero. Poi il titolo.
	_say("\"Questa volta, portala via di qui.\"", 32.8, 3.4)
	if not await _at(36.6): return
	_finish()


# ---------- Il tempo ----------

func _process(delta: float) -> void:
	_clock += delta


func _elapsed() -> float:
	return _clock


## Aspetta il secondo "seconds" del filmato. Restituisce false se nel frattempo è
## stato saltato: chi chiama deve smettere (return).
func _at(seconds: float) -> bool:
	var left := seconds - _elapsed()
	if left > 0.0:
		await get_tree().create_timer(left).timeout
	return not _done and is_inside_tree()


# ---------- Le inquadrature ----------

## Mette sul palco una scena del gioco (senza Subaru, senza la sua musica, senza
## camere sue) e fa scorrere la camera da "from" a "to" in "seconds" secondi.
func _backdrop(path: String, from: Vector2, to: Vector2, seconds: float) -> void:
	_clear_stage()
	var scene: Node = load(path).instantiate()
	for node in scene.find_children("*", "CharacterBody2D"):
		if node.is_in_group("player"):
			node.get_parent().remove_child(node)
			node.free()
	for node in scene.find_children("*", "AudioStreamPlayer"):
		if node.name == "Music":   # la musica è quella del filmato
			node.get_parent().remove_child(node)
			node.free()
	for node in scene.find_children("*", "Camera2D"):
		node.enabled = false
	stage.add_child(scene)
	camera.make_current()
	camera.position = from
	camera.reset_physics_interpolation()
	if _camera_tween:
		_camera_tween.kill()
	_camera_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_camera_tween.tween_property(camera, "position", to, seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _clear_stage() -> void:
	for child in stage.get_children():
		child.queue_free()


## Stacco: dal nero all'immagine, e dall'immagine al nero.
func _cut_in(seconds: float) -> void:
	create_tween().tween_property(black, "color:a", 0.0, seconds)


func _cut_out(seconds: float) -> void:
	var t := create_tween()
	t.tween_property(black, "color:a", 1.0, seconds)
	await t.finished


## Il mondo si scurisce fino ad "amount", cominciando al secondo "at".
func _darken(amount: float, at: float, seconds: float) -> void:
	var t := create_tween()
	t.tween_interval(maxf(at - _elapsed(), 0.0))
	t.tween_property(shade, "color:a", amount, seconds).set_trans(Tween.TRANS_SINE)


# ---------- Le scritte ----------

## Una riga della voce narrante: compare al secondo "at" e resta "seconds" secondi.
func _say(text: String, at: float, seconds: float) -> void:
	if not await _at(at):
		return
	narration.text = text
	_show_text(narration, 0.0, seconds)


## Fa comparire una scritta (salendo un poco), la tiene e la fa sparire.
func _show_text(label: Label, delay: float, seconds: float) -> void:
	var y := label.position.y
	var t := create_tween()
	t.tween_interval(delay)
	t.tween_callback(func(): label.position.y = y + 6.0)
	t.tween_property(label, "modulate:a", 1.0, 0.6)
	t.parallel().tween_property(label, "position:y", y, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_interval(maxf(seconds - 1.2, 0.2))
	t.tween_property(label, "modulate:a", 0.0, 0.6)


# ---------- Fine ----------

## Il filmato è finito (o saltato): al titolo.
func _finish() -> void:
	if _done:
		return
	_done = true
	create_tween().tween_property(music, "volume_db", -40.0, Fade.duration)
	Game.change_scene(Game.TITLE_SCENE, "", "", false)
