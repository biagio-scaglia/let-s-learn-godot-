class_name ThicketEyes
extends Sprite2D
## Due occhi nel buio dei rovi. Si aprono piano, sbattono le palpebre ogni tanto,
## e quando Subaru si avvicina troppo si chiudono di colpo: come se non ci fossero mai stati.
## Lo sprite ha 3 celle: aperti, socchiusi, chiusi.

enum Lids { OPEN, HALF, SHUT }

## Sotto questa distanza dal giocatore gli occhi si chiudono.
@export var shy_distance := 90.0

var _player: Node2D
var _shut := true
var _busy := false


func _ready() -> void:
	hframes = 3
	frame = Lids.SHUT
	modulate.a = 0.0
	_player = get_tree().get_first_node_in_group("player") as Node2D
	# Ognuno si apre per conto suo, non tutti insieme.
	get_tree().create_timer(randf_range(0.5, 4.0)).timeout.connect(_open)


func _process(_delta: float) -> void:
	if _player == null or _shut or _busy:
		return
	if global_position.distance_to(_player.global_position) < shy_distance:
		_close_fast()
