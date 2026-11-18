extends Node2D
## La schermata iniziale: il villaggio vero sullo sfondo, una camera che scorre piano,
## il titolo che scende con un riflesso di luce, e "Premi Invio". Premuto Invio,
## il menu si apre in una finestra e le voci compaiono una alla volta.
##
## La Galleria è nel menu fin dall'inizio, ma chiusa col lucchetto finché la storia
## non è finita (Progress). Se nessuno tocca niente per IDLE_SECONDS, riparte il filmato.

## La camera va avanti e indietro tra questi due punti del villaggio.
const PAN_FROM := Vector2(430, 300)
const PAN_TO := Vector2(880, 430)
const PAN_SECONDS := 16.0
## Dopo quanti secondi senza toccare niente riparte il filmato iniziale.
const IDLE_SECONDS := 45.0
const LOCK := preload("res://assets/ui/lock.png")

@onready var camera: Camera2D = $Camera2D
@onready var title: Label = %Title
@onready var glow: TextureRect = %Glow
@onready var subtitle: Label = %Subtitle
@onready var ornament: Control = %Ornament
@onready var press_start: Label = %PressStart
@onready var menu_panel: Control = %MenuPanel
@onready var menu: Control = %Menu
@onready var footer: Control = %Footer
@onready var version: Control = %Version
@onready var credit: Control = %Credit
@onready var options: Control = %OptionsMenu
@onready var continue_button: MenuItem = %Continue
@onready var new_game_button: MenuItem = %NewGame
@onready var gallery_button: MenuItem = %Gallery
@onready var save_info: Label = %SaveInfo
@onready var options_button: MenuItem = %Options
@onready var quit_button: MenuItem = %Quit
@onready var hands: ShadowHands = %ShadowHands

## In che momento siamo: "intro" (le scritte entrano), "press" (aspetta Invio), "menu".
var _state := "intro"
## Secondi passati senza che nessuno tocchi niente.
var _idle := 0.0
var _press_tween: Tween


func _ready() -> void:
	_add_village_background()
	camera.position = PAN_FROM
	camera.make_current()
	_pan_camera()

	# "Continua" c'è solo se esiste un salvataggio; sotto, luogo e data.
	var info := SaveSystem.save_info()
	continue_button.visible = not info.is_empty()
	save_info.visible = not info.is_empty()
	if not info.is_empty():
		save_info.text = "%s\n%s" % [info.luogo, _pretty_date(info.data)]
	_setup_gallery_button()
	continue_button.pressed.connect(_on_continue)
	new_game_button.pressed.connect(_on_new_game)
	gallery_button.pressed.connect(_on_gallery)
	options_button.pressed.connect(_on_options)
	quit_button.pressed.connect(Farewell.leave)
	options.closed.connect(_on_options_closed)
	# Qualcuno nel buio afferra la voce che scegli.
	hands.watch(menu.get_children())
	hands.set_active(false)   # finché il menu è chiuso, le mani aspettano
	_pulse_glow()
	_intro()


## Lo sfondo è il villaggio vero (con il Saggio che respira ed Emilia in piazza),
## ma senza Subaru: lo togliamo prima di aggiungerlo alla scena.
func _add_village_background() -> void:
	var village: Node = load(Game.FIRST_LEVEL).instantiate()
	# Cerchiamo Subaru per gruppo, non per percorso: se un giorno lo spostiamo
	# in un altro nodo della mappa, funziona lo stesso.
	for node in village.find_children("*", "CharacterBody2D"):
		if node.is_in_group("player"):
			node.get_parent().remove_child(node)
			node.free()
	add_child(village)
	move_child(village, 0)


func _pan_camera() -> void:
	var t := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_loops()
	t.tween_property(camera, "position", PAN_TO, PAN_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(camera, "position", PAN_FROM, PAN_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Il bagliore dietro al titolo respira piano.
func _pulse_glow() -> void:
	var t := create_tween().set_loops()
	t.tween_property(glow, "modulate:a", 0.55, 2.2).set_trans(Tween.TRANS_SINE)
	t.tween_property(glow, "modulate:a", 1.0, 2.2).set_trans(Tween.TRANS_SINE)


## La Galleria: col lucchetto finché la storia non è finita, con "Nuova!" la prima volta.
func _setup_gallery_button() -> void:
	if not Progress.gallery_unlocked():
		gallery_button.icon = LOCK
		gallery_button.modulate = Color(1, 1, 1, 0.55)
		return
	if not Progress.gallery_seen:
		var badge := Label.new()
		badge.text = "Nuova!"
		badge.theme_type_variation = &"SubtitleLabel"
		badge.position = Vector2(gallery_button.get_minimum_size().x + 6, 6)
		gallery_button.add_child(badge)
		# Saltella per farsi notare.
		var t := badge.create_tween().set_loops()
		t.tween_property(badge, "position:y", 2.0, 0.4).set_trans(Tween.TRANS_SINE)
		t.tween_property(badge, "position:y", 6.0, 0.4).set_trans(Tween.TRANS_SINE)


# ---------- Entrata: titolo, poi "Premi Invio" ----------

func _intro() -> void:
	var title_y := title.position.y
	title.position.y = title_y - 28
	for node in [title, glow, subtitle, ornament, footer, version, credit, press_start]:
		node.modulate.a = 0.0
	menu_panel.visible = false
	ornament.scale = Vector2(0.0, 1.0)
	ornament.pivot_offset = Vector2.ZERO   # il suo centro è già l'origine

	var t := create_tween()
	t.tween_interval(0.35)
	t.tween_property(title, "modulate:a", 1.0, 0.5)
	t.parallel().tween_property(title, "position:y", title_y, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(glow, "modulate:a", 1.0, 1.2)
	# L'ornamento si allarga dal centro, poi compare il sottotitolo.
	t.tween_property(ornament, "modulate:a", 1.0, 0.2)
	t.parallel().tween_property(ornament, "scale:x", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(subtitle, "modulate:a", 1.0, 0.4)
	t.tween_property(footer, "modulate:a", 1.0, 0.3)
	t.parallel().tween_property(version, "modulate:a", 1.0, 0.3)
	t.parallel().tween_property(credit, "modulate:a", 1.0, 0.3)
	t.tween_callback(_float_title.bind(title_y))
	t.tween_callback(_wait_for_press)


## Il titolo "galleggia" piano su e giù.
func _float_title(base_y: float) -> void:
	var t := create_tween().set_loops()
	t.tween_property(title, "position:y", base_y - 3.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(title, "position:y", base_y, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## "Premi Invio" lampeggia finché non si preme qualcosa.
func _wait_for_press() -> void:
	_state = "press"
	_press_tween = create_tween().set_loops()
	_press_tween.tween_property(press_start, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)
	_press_tween.tween_property(press_start, "modulate:a", 0.25, 0.7).set_trans(Tween.TRANS_SINE)


func _process(delta: float) -> void:
	if options.visible or _state == "leaving":
		return
	_idle += delta
	if _idle >= IDLE_SECONDS:
		_state = "leaving"
		Game.change_scene(Game.OPENING_MOVIE, "", "", false)


func _input(event: InputEvent) -> void:
	# Qualsiasi cosa tocchi il giocatore, il filmato non riparte.
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		_idle = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if _state != "press":
		return
	var key: bool = event is InputEventKey and event.pressed and not event.echo
	var click: bool = event is InputEventMouseButton and event.pressed
	if key or click:
		get_viewport().set_input_as_handled()
		_open_menu()


## Si apre la finestra del menu: si allarga un poco e le voci entrano una alla volta.
func _open_menu() -> void:
	_state = "menu"
	Sfx.play(Sfx.CONFIRM)
	_press_tween.kill()
	var items := menu.get_children().filter(func(n): return n.visible)
	for item in items:
		item.modulate.a = 0.0
	menu_panel.visible = true
	menu_panel.modulate.a = 0.0
	menu_panel.pivot_offset = menu_panel.size / 2.0
	menu_panel.scale = Vector2(0.9, 0.9)
	var t := create_tween()
	t.tween_property(press_start, "modulate:a", 0.0, 0.15)
	t.tween_property(menu_panel, "modulate:a", 1.0, 0.2)
	t.parallel().tween_property(menu_panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for item in items:
		# La Galleria chiusa resta più trasparente.
		t.tween_property(item, "modulate:a", 0.55 if item == gallery_button and not Progress.gallery_unlocked() else 1.0, 0.12)
	t.tween_callback((continue_button if continue_button.visible else new_game_button).focus_silently)
	t.tween_callback(hands.set_active.bind(true))


# ---------- Le voci del menu ----------

func _disable_menu() -> void:
	# Niente doppi clic: il menu non risponde più.
	for item in menu.get_children():
		item.disabled = true
	_state = "leaving"


func _on_continue() -> void:
	_disable_menu()
	await hands.seize(continue_button)
	SaveSystem.continue_game()


func _on_new_game() -> void:
	_disable_menu()
	await hands.seize(new_game_button)
	Game.new_game()


func _on_gallery() -> void:
	if not Progress.gallery_unlocked():
		# Chiusa: un "no" con la testa e un suggerimento.
		Sfx.play(Sfx.BACK)
		var x := gallery_button.position.x
		var t := create_tween()
		for dx in [5.0, -4.0, 3.0, 0.0]:
			t.tween_property(gallery_button, "position:x", x + dx, 0.05)
		Hud.show_message("Finisci la storia per aprire la Galleria", LOCK)
		return
	_disable_menu()
	await hands.seize(gallery_button)
	Game.open_gallery()


## "2026-11-13 10:42:05" → "13/11/2026 10:42"
func _pretty_date(date: String) -> String:
	var parts := date.split(" ")
	if parts.size() < 2:
		return date
	var d := parts[0].split("-")
	return "%s/%s/%s %s" % [d[2], d[1], d[0], parts[1].left(5)]


func _on_options() -> void:
	hands.set_active(false)
	_show_title_texts(false)
	options.open()


func _on_options_closed() -> void:
	_show_title_texts(true)
	hands.set_active(true)
	options_button.focus_silently()
	_idle = 0.0


## Nasconde (o mostra) titolo, menu e scritte, per lasciare spazio alle opzioni.
func _show_title_texts(on: bool) -> void:
	menu_panel.visible = on
	var t := create_tween().set_parallel()
	for node in [title, glow, subtitle, ornament, footer, version, credit]:
		t.tween_property(node, "modulate:a", 1.0 if on else 0.0, 0.15)
