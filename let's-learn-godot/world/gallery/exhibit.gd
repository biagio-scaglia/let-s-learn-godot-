class_name Exhibit
extends Node2D
## Una "vetrina" della Galleria: un piedistallo, sopra un personaggio o un mostro,
## e accanto un leggio con il suo libro. Avvicinati al leggio e premi E per leggerlo.
##
## Si costruisce tutta da codice a partire da "book_id" (lo stesso id di GalleryBooks
## e di Portraits): nella scena basta un Node2D con questo script e l'id giusto.
## - "subaru": una statua (lui è il giocatore, non può stare anche qui!)
## - gli altri personaggi: il PNG vero (npc.tscn), che respira e si gira verso di te
## - i mostri: lo sprite del nemico, che respira con le sue due pose di riposo

## Emesso quando il giocatore apre il libro del leggio.
signal book_opened(book_id: String)

const NPC_SCENE := preload("res://characters/npc/npc.tscn")
const INTERACTABLE := preload("res://interactables/interactable.tscn")
const LIBRARY_TILES := preload("res://assets/library/library_tiles.png")
const SHADOW := preload("res://assets/effects/shadow_character.png")
## Il leggio col libro: casella (3, 4) del tileset della biblioteca.
const LECTERN_REGION := Rect2(48, 64, 16, 16)
## Cosa dicono i personaggi della Galleria: [prima volta, dalla seconda in poi].
const QUIPS := {
	"emilia": [
		["Una galleria tutta per noi? ...Quella statua di Subaru è un po' troppo eroica, non trovi?"],
		["Leggi pure il libro qui accanto. Ma non credere a tutto quello che c'è scritto su di me!"],
	],
	"saggio": [
		["Anche qui ci sono degli alberi? No? Peccato. Li avrei guardati crescere."],
		["Il libro dice che non mi ricordo le cose? Mah. Non me lo ricordo."],
	],
	"lina": [
		["Che bello! È come il baule della nonna, ma enorme!"],
		["Il mio libro dice che perdo sempre le chiavi. ...A proposito, hai visto la mia chiave?"],
	],
	"archivista": [
		["Shh. Una biblioteca di ricordi: il posto più bello del mondo."],
		["Questi libri si sono scritti da soli. Io li ho solo messi in ordine."],
	],
}

## Quale libro (e quale figura): "subaru", "emilia", "melma", "colui_che_guarda"...
@export var book_id := ""
## Quanto è grande la figura (un boss: 2).
@export var figure_scale := 1.0

## Mezza larghezza del piedistallo, in pixel.
var _half := 18.0


func _ready() -> void:
	y_sort_enabled = true
	_half = 14.0 + 8.0 * figure_scale
	queue_redraw()
	_add_figure()
	_add_lectern()
	_add_body()


## Il piedistallo: due rettangoli di pietra disegnati con _draw() (niente immagini).
func _draw() -> void:
	var outline := Color(0.12, 0.08, 0.16)
	var stone := Color(0.62, 0.6, 0.7)
	var top := Color(0.78, 0.76, 0.86)
	draw_rect(Rect2(-_half - 1, -7, _half * 2 + 2, 12), outline)
	draw_rect(Rect2(-_half, -6, _half * 2, 10), stone)
	draw_rect(Rect2(-_half, -6, _half * 2, 3), top)


func _add_figure() -> void:
	var book := GalleryBooks.entry(book_id)
	if book_id == "subaru":
		_add_statue(book)
	elif QUIPS.has(book_id):
		_add_npc(book)
	else:
		_add_monster()


## Subaru di pietra: il suo primo frame, grigio-azzurro, con una targa da leggere.
func _add_statue(book: Dictionary) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = Portraits.of("subaru")
	sprite.offset = Vector2(0, -24)
	sprite.position.y = -6
	sprite.modulate = Color(0.62, 0.66, 0.8)   # pietra azzurrina
	add_child(sprite)
	var plate := INTERACTABLE.instantiate() as Interactable
	plate.speaker = "Statua"
	plate.lines = [
		"Una statua di Subaru, in posa eroica. Sulla base: \"%s\"." % book.get("role", ""),
		"...Mi somiglia un sacco. Bel lavoro, chiunque sia stato.",
	]
	plate.repeat_lines = ["Lo sguardo di pietra fissa l'orizzonte. Quello vero non lo fa mai."]
	plate.prompt_height = 60.0
	add_child(plate)


## Un personaggio vivo: il PNG del gioco, con due battute sue.
func _add_npc(book: Dictionary) -> void:
	var npc := NPC_SCENE.instantiate()
	npc.npc_name = book.get("name", book_id)
	if book_id == "emilia":
		npc.charset = Portraits.EMILIA_CHARSET
	else:
		npc.sprite_tile = Portraits.DUNGEON_TILES[book_id]
	npc.lines = PackedStringArray(QUIPS[book_id][0])
	npc.repeat_lines = PackedStringArray(QUIPS[book_id][1])
	npc.position.y = -6
	add_child(npc)


## Un mostro: lo sprite del suo foglio, che alterna le due pose di riposo.
func _add_monster() -> void:
	var data := Portraits.enemy_data(book_id)
	if data == null:
		return
	var shadow := Sprite2D.new()
	shadow.texture = SHADOW
	shadow.position.y = -6
	shadow.scale = Vector2.ONE * figure_scale
	add_child(shadow)
	var sprite := Sprite2D.new()
	sprite.texture = data.texture
	sprite.hframes = maxi(data.frames, 1)
	sprite.scale = Vector2.ONE * figure_scale
	sprite.offset = Vector2(0, -data.cell_size() / 2.0)   # i piedi sul piedistallo
	sprite.position.y = -6
	add_child(sprite)
	if data.animated():
		var t := create_tween().set_loops()
		t.tween_callback(func(): sprite.frame = EnemyData.Pose.IDLE)
		t.tween_interval(0.5)
		t.tween_callback(func(): sprite.frame = EnemyData.Pose.IDLE_2)
		t.tween_interval(0.5)


## Il leggio a destra del piedistallo, con il libro da leggere.
func _add_lectern() -> void:
	var lectern := Sprite2D.new()
	var tex := AtlasTexture.new()
	tex.atlas = LIBRARY_TILES
	tex.region = LECTERN_REGION
	lectern.texture = tex
	lectern.scale = Vector2(2, 2)          # come le tile della biblioteca
	lectern.offset = Vector2(0, -8)        # la base del leggio sull'origine
	lectern.position = Vector2(_half + 16, 4)
	add_child(lectern)
	var book := INTERACTABLE.instantiate() as Interactable
	book.speaker = "Libro"
	book.prompt_height = 40.0
	book.position = lectern.position
	add_child(book)
	# Nessuna frase: al segnale ci pensa il lettore di libri (BookReader).
	book.interacted.connect(func(): book_opened.emit(book_id))


## Il piedistallo e il leggio non si attraversano.
func _add_body() -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(_half * 2 + 36, 12)
	shape.shape = rect
	shape.position = Vector2(18, -1)
	body.add_child(shape)
	add_child(body)
