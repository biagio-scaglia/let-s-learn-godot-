extends Node2D
## La schermata iniziale: il villaggio vero sullo sfondo, una camera che scorre piano,
## il titolo che scende e il menu che compare voce per voce.

## La camera va avanti e indietro tra questi due punti del villaggio.
const PAN_FROM := Vector2(430, 300)
const PAN_TO := Vector2(880, 430)
const PAN_SECONDS := 16.0

@onready var camera: Camera2D = $Camera2D
@onready var title: Label = %Title
@onready var subtitle: Label = %Subtitle
@onready var menu: Control = %Menu
@onready var footer: Control = %Footer
@onready var version: Control = %Version
@onready var options: Control = %OptionsMenu
@onready var new_game_button: MenuItem = %NewGame
@onready var options_button: MenuItem = %Options
@onready var quit_button: MenuItem = %Quit


func _ready() -> void:
	_add_village_background()
	camera.position = PAN_FROM
	camera.make_current()
	_pan_camera()

	new_game_button.pressed.connect(_on_new_game)
	options_button.pressed.connect(_on_options)
	quit_button.pressed.connect(get_tree().quit)
	options.closed.connect(_on_options_closed)
	_intro()


## Lo sfondo è il villaggio vero (con il Saggio che respira ed Emilia in piazza),
## ma senza Subaru: lo togliamo prima di aggiungerlo alla scena.
func _add_village_background() -> void:
	var village: Node = load(Game.FIRST_LEVEL).instantiate()
	var player := village.get_node("World/Subaru")
	player.get_parent().remove_child(player)
	player.free()
	add_child(village)
	move_child(village, 0)


func _pan_camera() -> void:
	var t := create_tween().set_loops()
	t.tween_property(camera, "position", PAN_TO, PAN_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(camera, "position", PAN_FROM, PAN_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Entrata: il titolo scende dall'alto, poi sottotitolo e voci del menu una alla volta.
func _intro() -> void:
	var title_y := title.position.y
	title.position.y = title_y - 28
	for node in [title, subtitle, footer, version]:
		node.modulate.a = 0.0
	var items := menu.get_children()
	for item in items:
		item.modulate.a = 0.0

	var t := create_tween()
	t.tween_interval(0.35)
	t.tween_property(title, "modulate:a", 1.0, 0.5)
	t.parallel().tween_property(title, "position:y", title_y, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(subtitle, "modulate:a", 1.0, 0.4)
	for item in items:
		t.tween_property(item, "modulate:a", 1.0, 0.18)
	t.tween_property(footer, "modulate:a", 1.0, 0.3)
	t.parallel().tween_property(version, "modulate:a", 1.0, 0.3)
	t.tween_callback(new_game_button.focus_silently)
	t.tween_callback(_float_title.bind(title_y))


## Il titolo "galleggia" piano su e giù.
func _float_title(base_y: float) -> void:
	var t := create_tween().set_loops()
	t.tween_property(title, "position:y", base_y - 3.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(title, "position:y", base_y, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_new_game() -> void:
	# Niente doppi clic: il menu non risponde più.
	for item in menu.get_children():
		item.disabled = true
	Game.new_game()


func _on_options() -> void:
	_show_title_texts(false)
	options.open()


func _on_options_closed() -> void:
	_show_title_texts(true)
	options_button.focus_silently()


## Nasconde (o mostra) titolo, menu e scritte, per lasciare spazio alle opzioni.
func _show_title_texts(on: bool) -> void:
	menu.visible = on
	var t := create_tween().set_parallel()
	for node in [title, subtitle, footer, version]:
		t.tween_property(node, "modulate:a", 1.0 if on else 0.0, 0.15)
