extends StaticBody2D
## Un personaggio con cui parlare. La parte "avvicinati e premi E" la fa il
## figlio Interactable: qui ci sono solo l'aspetto e il comportamento.
##
## L'aspetto si sceglie in due modi:
## - "charset": un foglio in formato RPG Maker (4 colonne x 4 righe: giù, sinistra,
##   destra, su). Il personaggio si gira verso il giocatore in 4 direzioni.
## - altrimenti "sprite_tile": un personaggio di Tiny Dungeon, che si specchia soltanto.

## Il nome che compare nella finestra di dialogo.
@export var npc_name := "???"
## Le frasi della prima volta, una per pagina.
@export_multiline var lines: PackedStringArray = []
## Le frasi dalla seconda volta in poi. Se vuoto, ripete "lines".
@export_multiline var repeat_lines: PackedStringArray = []
## Foglio del personaggio in formato RPG Maker (opzionale).
@export var charset: Texture2D
## Se non c'è un charset: quale personaggio di Tiny Dungeon disegnare (84 il mago, 99 la ragazza…).
@export var sprite_tile := 84

## Riga del charset per ogni direzione.
const CHARSET_ROWS := {Facing.DOWN: 0, Facing.LEFT: 1, Facing.RIGHT: 2, Facing.UP: 3}

@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Sprite2D = $Shadow
@onready var interactable: Interactable = $Interactable

var facing := Facing.DOWN
## True mentre una cutscene lo fa camminare: non si gira verso il giocatore da solo.
var _scripted := false
## Il Tween della camminata dei piedi (i frame del charset), per fermarlo all'arrivo.
var _walk_anim: Tween


func _ready() -> void:
	if charset:
		_use_charset()
	else:
		_use_dungeon_tile()

	interactable.speaker = npc_name
	interactable.lines = lines
	interactable.repeat_lines = repeat_lines

	# Respiro: lo sprite si schiaccia appena e torna, all'infinito.
	# Si deforma dai piedi perché l'origine dello sprite è in basso.
	var base := sprite.scale
	var breathe := create_tween().set_loops()
	breathe.tween_property(sprite, "scale", base * Vector2(1.03, 0.96), 0.9) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	breathe.tween_property(sprite, "scale", base, 0.9) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _use_charset() -> void:
	sprite.texture = charset
	sprite.hframes = 4
	sprite.vframes = 4
	sprite.scale = Vector2.ONE                     # stessa scala di pixel di Subaru
	sprite.offset = Vector2(0, -charset.get_height() / 8.0)   # mezza cella in su: i piedi sull'origine
	shadow.scale = Vector2.ONE
	_show_facing()


func _use_dungeon_tile() -> void:
	# Ritaglia il personaggio scelto. Creiamo un'AtlasTexture nuova: se cambiassimo
	# quella della scena, cambierebbe per tutti i PNG.
	var tex := AtlasTexture.new()
	tex.atlas = (sprite.texture as AtlasTexture).atlas
	tex.region = Rect2((sprite_tile % 12) * 16, floori(sprite_tile / 12.0) * 16, 16, 16)
	sprite.texture = tex


func _process(_delta: float) -> void:
	var player := interactable.player
	# In una cutscene decide la regia dove guardare.
	if player == null or _scripted or Game.in_cutscene:
		return
	var to_player := player.global_position - global_position
	if charset:
		# Si gira verso il giocatore in 4 direzioni.
		var dir := Facing.from_vector(to_player)
		if dir != facing:
			facing = dir
			_show_facing()
	else:
		sprite.flip_h = to_player.x < 0


func _show_facing() -> void:
	# Colonna 0: in piedi, fermo.
	sprite.frame = CHARSET_ROWS[facing] * 4


# ---------- Comandi per le cutscene (solo con un charset) ----------

## Si gira in una direzione (una costante di Facing).
func face(direction: String) -> void:
	facing = direction
	if charset:
		_show_facing()


## Cammina fino a "point" (coordinate globali) e si ferma. Si può aspettare con await,
## come Subaru.walk_to(). Le 4 colonne della riga del charset sono i passi.
func walk_to(point: Vector2, speed := 70.0) -> void:
	_scripted = true
	face(Facing.from_vector(point - global_position))
	if charset:
		var row: int = CHARSET_ROWS[facing] * 4
		if _walk_anim:
			_walk_anim.kill()
		# Un Tween che non finisce mai: cambia frame ogni 0.15 secondi.
		_walk_anim = create_tween().set_loops()
		for column in [1, 2, 3, 0]:
			_walk_anim.tween_callback(func(): sprite.frame = row + column)
			_walk_anim.tween_interval(0.15)
	var t := create_tween()
	t.tween_property(self, "global_position", point, global_position.distance_to(point) / speed)
	await t.finished
	if _walk_anim:
		_walk_anim.kill()
		_walk_anim = null
	_scripted = false
	face(facing)


# ---------- Comandi per chi la fa camminare frame per frame (Follower) ----------

## Quanto tempo ha camminato senza fermarsi: decide quale passo mostrare.
var _step_time := 0.0


## Un pezzetto di camminata verso "direction": avanza l'animazione dei passi.
## Diversa da walk_to(): qui la posizione la cambia chi chiama, a ogni frame.
func step(direction: String, delta: float) -> void:
	_scripted = true
	facing = direction
	_step_time += delta
	if charset:
		var column: int = [1, 2, 3, 0][int(_step_time / 0.15) % 4]
		sprite.frame = CHARSET_ROWS[facing] * 4 + column


## Si ferma: torna in piedi e, se il giocatore è vicino, può di nuovo girarsi verso di lui.
func stand() -> void:
	if not _scripted:
		return
	_scripted = false
	_step_time = 0.0
	face(facing)
