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
const CHARSET_ROWS := {"down": 0, "left": 1, "right": 2, "up": 3}

@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Sprite2D = $Shadow
@onready var interactable: Interactable = $Interactable

var facing := "down"


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
	if player == null:
		return
	var to_player := player.global_position - global_position
	if charset:
		# Si gira verso il giocatore in 4 direzioni.
		var dir := ""
		if abs(to_player.x) > abs(to_player.y):
			dir = "right" if to_player.x > 0 else "left"
		else:
			dir = "down" if to_player.y > 0 else "up"
		if dir != facing:
			facing = dir
			_show_facing()
	else:
		sprite.flip_h = to_player.x < 0


func _show_facing() -> void:
	# Colonna 0: in piedi, fermo.
	sprite.frame = CHARSET_ROWS[facing] * 4
