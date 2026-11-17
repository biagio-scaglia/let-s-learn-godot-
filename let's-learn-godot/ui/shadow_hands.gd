class_name ShadowHands
extends Control
## Qualcuno, nel buio, ti guarda mentre scegli. Per la schermata iniziale.
##
## - Quando una voce del menu viene selezionata, una mano d'ombra esce dal bordo,
##   la afferra e la tira un po' verso di sé. Cambiando voce la lascia e se ne va.
## - Ogni tanto, da soli: due occhi viola si aprono nel buio, oppure una mano si
##   affaccia e tasta l'aria vicino al menu. A volte, un sussurro.
## - seize(): quando confermi, la mano stringe, ne arrivano altre e trascinano via la voce.
##
## Va messo sopra il menu (dopo, nell'albero) e grande quanto lo schermo.

## Gli eventi "da soli" (occhi, mani, sussurri). I test li spengono.
@export var idle_events := true
## Ogni quanto, in secondi, può succedere qualcosa da solo.
@export var idle_min := 5.0
@export var idle_max := 10.0

const EYES := preload("res://assets/effects/watching_eyes.png")
const EYES_CELL := Vector2(32, 10)
const HEARTBEAT := preload("res://assets/heartbeat_bart/heartbeat_slow.wav")
const WHOOSH := preload("res://assets/effects/swing.wav")
const WHISPERS := ["Ti amo.", "Ti amo... ti amo...", "Non andartene.", "Ti sto guardando."]

## La voce del menu tenuta in questo momento, e la mano che la tiene.
var held: Control
var hand: ShadowHand
## Mentre trascina via una voce non fa nient'altro.
var seizing := false
## Le mani si muovono a caso, ma non usano i dadi di nessun altro.
var rng := RandomNumberGenerator.new()

## La posizione "a riposo" di ogni voce (prima di essere tirata).
var _rest_x := {}
## Il tremito della voce tenuta: va fermato quando la si lascia, se no la
## voce finirebbe di tremare DOPO essere tornata a posto, e resterebbe spostata.
var _pull: Tween
var _whoosh: AudioStreamPlayer
var _heartbeat: AudioStreamPlayer
var _dark: ColorRect


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	rng.randomize()
	_whoosh = _make_player(WHOOSH, -14.0, 0.55)
	_heartbeat = _make_player(HEARTBEAT, -10.0, 1.0)
	_dark = ColorRect.new()
	_dark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dark.color = Color(0.03, 0.0, 0.05, 0.0)
	add_child(_dark)
	_idle_loop()


## Da qui in poi le mani seguono queste voci di menu.
func watch(items: Array) -> void:
	for item: Control in items:
		item.focus_entered.connect(_on_item_focused.bind(item))


## Spegne (o riaccende) le mani: per esempio mentre sono aperte le opzioni.
func set_active(on: bool) -> void:
	visible = on
	if not on:
		release()


## Lascia la voce tenuta, se c'è.
func release() -> void:
	if _pull:
		_pull.kill()
	if held:
		var item := held
		create_tween().tween_property(item, "position:x", _rest_x[item], 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if hand:
		hand.retract()
	held = null
	hand = null


## La scelta è fatta: la mano stringe, ne arrivano altre, lo schermo si fa scuro e la
## voce viene trascinata via. Si aspetta (circa un secondo), poi tocca a chi cambia scena.
func seize(item: Control) -> void:
	seizing = true
	visible = true
	if held != item or hand == null:
		await _grab(item)
	var main := hand
	Sfx.play(Sfx.SHAMAC)
	_heartbeat.play()
	var target := _anchor(item) + Vector2(20, 0)
	# Altre quattro mani, dagli angoli.
	var corners := [Vector2(-40, -40), Vector2(-40, size.y + 40), Vector2(size.x + 40, -40), Vector2(size.x + 40, size.y + 40)]
	for corner: Vector2 in corners:
		var extra := _spawn(corner)
		var spot := target + Vector2(rng.randf_range(-10, 60), rng.randf_range(-14, 14))
		extra.reach(spot, rng.randf_range(0.25, 0.4))
		get_tree().create_timer(0.4).timeout.connect(extra.grip)
	var dark := create_tween()
	dark.tween_property(_dark, "color:a", 0.75, 0.6)
	_show_eyes(Vector2(size.x / 2.0, 26.0), 4.0, 0.25, 1.2)   # sopra il titolo
	await get_tree().create_timer(0.45).timeout
	# Via: la mano torna nel buio, e la voce con lei.
	if _pull:
		_pull.kill()   # niente tremito mentre la trascina
	if main and is_instance_valid(main):
		var drag := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		drag.tween_property(main, "tip", main.origin, 0.4)
		drag.tween_property(item, "position:x", item.position.x - (target.x - main.origin.x) - 40.0, 0.4)
		drag.tween_property(item, "modulate:a", 0.0, 0.4)
		await drag.finished


# ---------- Afferrare le voci ----------

func _on_item_focused(item: Control) -> void:
	if seizing or not visible:
		return
	if held == item:
		return
	release()
	_grab(item)


## Una mano esce dal bordo sinistro, arriva alla voce, la stringe e la tira.
func _grab(item: Control) -> void:
	if not _rest_x.has(item):
		_rest_x[item] = item.position.x
	var target := _anchor(item)
	var from := Vector2(-30, target.y + rng.randf_range(-80, 80))
	var mine := _spawn(from)
	hand = mine
	held = item
	_whoosh.pitch_scale = rng.randf_range(0.5, 0.62)
	_whoosh.play()
	await mine.reach(target, 0.28)
	# Nel frattempo si è passati a un'altra voce? Allora questa mano se ne sta già andando.
	if hand != mine:
		return
	mine.grip()
	# Un tremito, poi la voce resta tirata qualche pixel verso la mano.
	var rest: float = _rest_x[item]
	_pull = create_tween()
	for i in 5:
		_pull.tween_property(item, "position:x", rest - 3.0 + rng.randf_range(-2.0, 2.0), 0.04)
	_pull.tween_property(item, "position:x", rest - 5.0, 0.08)


## Il punto dove mettere il polso per afferrare la voce: le dita finiscono sul suo bordo.
func _anchor(item: Control) -> Vector2:
	var rect := item.get_global_rect()
	return Vector2(rect.position.x - 46.0, rect.get_center().y) - global_position


func _spawn(from: Vector2) -> ShadowHand:
	var h := ShadowHand.new()
	add_child(h)
	move_child(h, _dark.get_index())   # sotto il velo scuro, così il buio le inghiotte
	h.setup(from, from)
	return h


# ---------- Quello che succede da solo ----------

func _idle_loop() -> void:
	while is_inside_tree():
		await get_tree().create_timer(rng.randf_range(idle_min, idle_max)).timeout
		if not is_inside_tree():
			return
		if seizing or not visible or not idle_events:
			continue
		var roll := rng.randf()
		if roll < 0.45:
			_watch_from_dark()
		elif roll < 0.8:
			_creep()
		else:
			_watch_from_dark(true)


## Due occhi si aprono in un angolo buio, battono le palpebre, si richiudono.
func _watch_from_dark(whisper := false) -> void:
	var left := rng.randf() < 0.5
	var pos := Vector2(rng.randf_range(40, 130) if left else rng.randf_range(size.x - 130, size.x - 40),
		rng.randf_range(50, size.y - 70))
	_heartbeat.play()
	_show_eyes(pos, 2.0, 1.2, 2.4)
	if whisper:
		_whisper(pos + Vector2(0, 22))


## Gli occhi: si aprono piano, restano "seconds", sbattono le palpebre e si chiudono.
func _show_eyes(pos: Vector2, scale_by: float, fade_in: float, seconds: float) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = EYES
	var eyes := Sprite2D.new()
	eyes.texture = atlas
	eyes.position = pos
	eyes.scale = Vector2(scale_by, scale_by)
	eyes.modulate.a = 0.0
	# Dietro agli occhi, una macchia di buio: sembrano guardare da dentro l'ombra.
	var blot := Sprite2D.new()
	blot.texture = _dark_blot()
	blot.scale = Vector2(1.2, 0.6)
	blot.show_behind_parent = true
	eyes.add_child(blot)
	add_child(eyes)
	var pose := func(i: int) -> void: atlas.region = Rect2(Vector2(i * EYES_CELL.x, 0), EYES_CELL)
	var t := create_tween()
	t.tween_callback(pose.bind(2))   # chiusi
	t.tween_property(eyes, "modulate:a", 0.9, fade_in)
	t.tween_callback(pose.bind(1))
	t.tween_interval(0.12)
	t.tween_callback(pose.bind(0))   # aperti
	t.tween_interval(seconds * 0.5)
	for p in [1, 2, 1, 0]:          # un battito di ciglia
		t.tween_callback(pose.bind(p))
		t.tween_interval(0.06)
	t.tween_interval(seconds * 0.5)
	t.tween_callback(pose.bind(1))
	t.tween_property(eyes, "modulate:a", 0.0, 0.5)
	t.tween_callback(eyes.queue_free)


## Una frase appena visibile, che compare lettera per lettera e svanisce.
func _whisper(pos: Vector2) -> void:
	var label := Label.new()
	label.text = WHISPERS[rng.randi() % WHISPERS.size()]
	label.add_theme_color_override("font_color", Color(0.78, 0.55, 1.0))
	label.add_theme_font_size_override("font_size", 16)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	label.position = pos - Vector2(label.get_minimum_size().x / 2.0, 0)
	label.position.x = clampf(label.position.x, 8.0, size.x - label.get_minimum_size().x - 8.0)
	label.visible_ratio = 0.0
	label.modulate.a = 0.45
	var t := create_tween()
	t.tween_interval(0.6)
	t.tween_property(label, "visible_ratio", 1.0, 1.2)
	t.tween_interval(1.0)
	t.tween_property(label, "modulate:a", 0.0, 0.8)
	t.tween_callback(label.queue_free)


## Una mano si affaccia dal basso o dal lato, tasta l'aria vicino al menu e se ne va.
func _creep() -> void:
	var from_bottom := rng.randf() < 0.5
	var from := Vector2(rng.randf_range(size.x * 0.25, size.x * 0.75), size.y + 30) if from_bottom \
		else Vector2(size.x + 30, rng.randf_range(size.y * 0.4, size.y * 0.85))
	var to := from + (Vector2(rng.randf_range(-40, 40), -rng.randf_range(60, 100)) if from_bottom \
		else Vector2(-rng.randf_range(70, 120), rng.randf_range(-30, 30)))
	var h := _spawn(from)
	h.sway = 9.0
	await h.reach(to, 1.1)
	if not is_instance_valid(h):
		return
	# Apre e chiude le dita, piano, come se cercasse qualcosa.
	for i in 3:
		h.set_pose(ShadowHand.Pose.OPEN)
		await get_tree().create_timer(0.25).timeout
		if not is_instance_valid(h):
			return
		h.set_pose(ShadowHand.Pose.CLAWS)
		await get_tree().create_timer(0.25).timeout
		if not is_instance_valid(h):
			return
	h.retract(0.8)


## Un cerchio sfumato, scuro al centro e trasparente ai bordi.
func _dark_blot() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.02, 0.0, 0.04, 0.85))
	gradient.set_color(1, Color(0.02, 0.0, 0.04, 0.0))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 64
	tex.height = 64
	return tex


func _make_player(stream: AudioStream, volume: float, pitch: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume
	player.pitch_scale = pitch
	add_child(player)
	return player
