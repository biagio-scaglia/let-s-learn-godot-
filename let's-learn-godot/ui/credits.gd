extends Control
## I titoli di coda. Il cielo passa dalla notte all'alba, Subaru ed Emilia camminano
## in basso lungo la strada, i nomi scorrono verso l'alto al ritmo della musica.
## Alla fine resta "Un gioco di Biagio Scaglia"; con Invio si torna al titolo.
##
## I titoli non sono scritti nella scena: li costruisce _build_list() a partire da
## CREDITS (e dal cast di GalleryBooks), così aggiungere un nome è una riga sola.

## Ogni riga: [stile, testo]. Stili: "title", "by", "header", "name", "small", "gap",
## "cast" (i personaggi, col ritratto), "monsters" (i mostri, col ritratto).
const CREDITS := [
	["title", "Erbalta"],
	["by", "Un gioco di Biagio Scaglia"],
	["gap", ""],
	["header", "Ideato, scritto e diretto da"],
	["name", "Biagio Scaglia"],
	["header", "Programmazione"],
	["name", "Biagio Scaglia"],
	["header", "Storia e dialoghi"],
	["name", "Biagio Scaglia"],
	["header", "Musiche originali"],
	["name", "Biagio Scaglia"],
	["small", "\"Un giorno nuovo\" - il tema di questi titoli"],
	["gap", ""],
	["header", "Personaggi"],
	["cast", ""],
	["gap", ""],
	["header", "Mostri"],
	["monsters", ""],
	["gap", ""],
	["header", "Grafica"],
	["name", "Tiny Town, Tiny Dungeon, Particle Pack"],
	["small", "Kenney (CC0)"],
	["name", "Biblioteca, castello, bosco, nemici, effetti"],
	["small", "Biagio Scaglia"],
	["header", "Suoni"],
	["name", "Sci-fi Sounds, Interface Sounds"],
	["small", "Kenney (CC0)"],
	["name", "Heartbeat sounds"],
	["small", "bart (CC0)"],
	["header", "Carattere"],
	["name", "KenPixel High Square"],
	["small", "Kenney (CC0)"],
	["header", "Fatto con"],
	["name", "Godot Engine 4.7"],
	["small", "gdUnit4 - Dialogue Manager - Phantom Camera - Beehave"],
	["gap", ""],
	["header", "Subaru ed Emilia"],
	["small", "da Re:Zero - Starting Life in Another World"],
	["small", "(c) Tappei Nagatsuki, Kadokawa"],
	["small", "Usati per imparare, in un progetto personale e non commerciale."],
	["gap", ""],
	["header", "Grazie per aver giocato!"],
]

## Quanto prima della fine della musica devono finire di scorrere i nomi
## (il tempo per il cartello finale).
const FINAL_HOLD := 16.0
## Tenendo premuto Invio (o E) i titoli vanno più veloci.
const FAST_FORWARD := 5.0
## Il cielo: notte, alba, mattina.
const SKY := [Color(0.06, 0.04, 0.12), Color(0.55, 0.28, 0.32), Color(0.98, 0.7, 0.5), Color(0.55, 0.72, 0.9)]
## Larghezza della colonna dei titoli.
const COLUMN := 420.0

@onready var sky: ColorRect = %Sky
@onready var stars: CPUParticles2D = %Stars
@onready var scroller: Control = %Scroller
@onready var list: VBoxContainer = %List
@onready var road: Node2D = %Road
@onready var subaru: AnimatedSprite2D = %Subaru
@onready var emilia: Sprite2D = %Emilia
@onready var trees: Node2D = %Trees
@onready var final_card: Control = %FinalCard
@onready var unlocked: Label = %Unlocked
@onready var press: Label = %Press
@onready var hint: Label = %Hint
@onready var music: AudioStreamPlayer = %Music

## Pixel al secondo dello scorrimento (calcolato dalla durata della musica).
var _speed := 20.0
## Quanto tempo è passato "nella storia dei titoli" (va più veloce se si tiene premuto).
var _time := 0.0
var _total := 100.0
var _finished := false
var _can_leave := false
## La Galleria si è appena sbloccata? (Lo dice Progress prima che la tocchiamo.)
var _new_gallery := false


func _ready() -> void:
	_new_gallery = not Progress.gallery_seen
	Progress.finish_story()
	_build_list()
	final_card.modulate.a = 0.0
	press.modulate.a = 0.0
	unlocked.visible = _new_gallery
	_plant_trees()
	_walk_emilia()
	music.play()
	# La lista parte sotto lo schermo e deve uscire tutta in alto prima della fine.
	await get_tree().process_frame   # le misure dei Label sono pronte solo dopo un frame
	_total = music.stream.get_length()
	var distance := scroller.size.y + list.size.y
	_speed = distance / maxf(_total - FINAL_HOLD, 10.0)
	list.position.y = scroller.size.y


func _process(delta: float) -> void:
	var fast := Input.is_action_pressed("interact") or Input.is_action_pressed("ui_accept")
	var step := delta * (FAST_FORWARD if fast and not _finished else 1.0)
	_time += step   # la musica invece non accelera: cambia solo il ritmo dei nomi
	_update_sky()
	_scroll_trees(step)
	if _finished:
		return
	list.position.y -= _speed * step
	if list.position.y + list.size.y < 0.0:
		_show_final_card()


## Il colore del cielo segue il tempo: dalla notte (inizio) alla mattina (fine).
func _update_sky() -> void:
	var k := clampf(_time / maxf(_total - FINAL_HOLD, 1.0), 0.0, 1.0) * (SKY.size() - 1)
	var i := mini(int(k), SKY.size() - 2)
	sky.color = (SKY[i] as Color).lerp(SKY[i + 1], k - i)
	# Le stelle si spengono quando arriva il giorno.
	stars.modulate.a = clampf(1.0 - k, 0.0, 1.0)


# ---------- I nomi ----------

func _build_list() -> void:
	for row in CREDITS:
		match row[0]:
			"gap":
				var gap := Control.new()
				gap.custom_minimum_size.y = 36
				list.add_child(gap)
			"cast":
				for book in GalleryBooks.CHARACTERS:
					list.add_child(_portrait_row(book.id, tr(book.name), tr(book.role)))
			"monsters":
				for book in GalleryBooks.MONSTERS:
					var data := Portraits.enemy_data(book.id)
					list.add_child(_portrait_row(book.id, tr(data.name) if data else book.id, tr(book.role)))
			_:
				list.add_child(_label(row[0], row[1]))


func _label(style: String, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = COLUMN
	match style:
		"title":
			label.theme_type_variation = &"TitleLabel"
		"by":
			label.theme_type_variation = &"SubtitleLabel"
		"header":
			label.theme_type_variation = &"SubtitleLabel"
			# Un po' di spazio sopra ogni sezione.
			label.custom_minimum_size.y = 34
			label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		"small":
			label.theme_type_variation = &"HintLabel"
		_:
			_outline(label)
	return label


## Un bordo scuro attorno alle lettere: quando il cielo diventa chiaro si leggono lo stesso.
func _outline(label: Label) -> void:
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.12))
	label.add_theme_constant_override("outline_size", 5)


## Una riga del cast: il ritratto (ingrandito, pixel netti) e accanto nome e ruolo.
func _portrait_row(id: String, title: String, role: String) -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	var pic := TextureRect.new()
	pic.texture = Portraits.of(id)
	pic.custom_minimum_size = Vector2(40, 40)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(pic)
	var text := VBoxContainer.new()
	text.alignment = BoxContainer.ALIGNMENT_CENTER
	text.add_theme_constant_override("separation", 0)
	text.custom_minimum_size.x = 220
	var name_label := Label.new()
	name_label.text = title
	_outline(name_label)
	text.add_child(name_label)
	var role_label := Label.new()
	role_label.text = role
	role_label.theme_type_variation = &"HintLabel"
	text.add_child(role_label)
	row.add_child(text)
	return row


# ---------- La strada in basso ----------

## Gli alberi lungo la strada (da Tiny Town): quelli piccoli stanno dietro, quelli
## grandi (scala 2) davanti, e scorrono più veloci: sembra che ci sia profondità.
func _plant_trees() -> void:
	var town := preload("res://assets/kenney_tiny_town/tilemap_packed.png")
	var regions := [Rect2(64, 0, 16, 32), Rect2(48, 0, 16, 32), Rect2(80, 0, 16, 16), Rect2(64, 32, 16, 16)]
	var rng := RandomNumberGenerator.new()
	rng.seed = 7   # sempre gli stessi alberi
	for i in 14:
		var tree := Sprite2D.new()
		var tex := AtlasTexture.new()
		tex.atlas = town
		tex.region = regions[rng.randi() % regions.size()]
		tree.texture = tex
		tree.centered = false
		tree.offset = Vector2(-8, -tex.region.size.y)   # i piedi dell'albero sull'origine
		var front := i % 3 == 0
		tree.scale = Vector2.ONE * (2.0 if front else 1.0)
		tree.position = Vector2(rng.randf_range(0, 680), 360.0 if front else 322.0)
		if not front:
			tree.modulate = Color(0.75, 0.75, 0.85)   # lontani: un po' sbiaditi
		trees.add_child(tree)
	# Quelli davanti si disegnano sopra Subaru ed Emilia.
	for tree in trees.get_children():
		if tree.scale.x > 1.0:
			tree.z_index = 1


## Emilia non ha un'animazione pronta come Subaru: il suo charset ha 4 passi per
## riga, e la riga 2 è "verso destra". Un Tween che non finisce mai cambia il frame.
func _walk_emilia() -> void:
	var t := create_tween().set_loops()
	for column in [1, 2, 3, 0]:
		t.tween_callback(func(): emilia.frame = 2 * 4 + column)
		t.tween_interval(0.15)


## Gli alberi scorrono verso sinistra: sono loro a muoversi, Subaru ed Emilia
## camminano sul posto (come in un tapis roulant). Chi esce a sinistra rientra a destra.
func _scroll_trees(step: float) -> void:
	var width := size.x
	for tree: Node2D in trees.get_children():
		tree.position.x -= 24.0 * step * (tree.scale.x)
		if tree.position.x < -24.0:
			tree.position.x += width + 48.0


# ---------- Il cartello finale ----------

func _show_final_card() -> void:
	_finished = true
	hint.hide()
	var t := create_tween()
	t.tween_property(final_card, "modulate:a", 1.0, 2.0)
	t.tween_interval(3.0)
	t.tween_property(press, "modulate:a", 1.0, 0.8)
	t.tween_callback(func(): _can_leave = true)
	# "Premi Invio" lampeggia piano.
	t.tween_callback(_blink_press)


func _blink_press() -> void:
	var t := create_tween().set_loops()
	t.tween_property(press, "modulate:a", 0.35, 0.9).set_trans(Tween.TRANS_SINE)
	t.tween_property(press, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if not _can_leave:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") \
			or event.is_action_pressed("pause"):
		_can_leave = false
		Sfx.play(Sfx.CONFIRM)
		create_tween().tween_property(music, "volume_db", -40.0, Fade.duration)
		Game.change_scene(Game.TITLE_SCENE, "", "", false)
