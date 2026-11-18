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
## Spalancati da Colui che guarda: non si chiudono più se ti avvicini.
var _staring := false
## Chiusi per sempre (Colui che guarda è stato sconfitto).
var _done := false


func _ready() -> void:
	add_to_group("thicket_eyes")
	if Game.has_flag(FlagKeys.BOSS_DEFEATED):
		queue_free()   # il bosco è libero: niente più occhi
		return
	hframes = 3
	frame = Lids.SHUT
	modulate.a = 0.0
	_player = get_tree().get_first_node_in_group("player") as Node2D
	# Ognuno si apre per conto suo, non tutti insieme.
	get_tree().create_timer(randf_range(0.5, 4.0)).timeout.connect(_open)


func _process(_delta: float) -> void:
	if _player == null or _shut or _busy or _staring:
		return
	if global_position.distance_to(_player.global_position) < shy_distance:
		_close_fast()


func _open() -> void:
	if not is_inside_tree() or _done:
		return
	if _player and global_position.distance_to(_player.global_position) < shy_distance * 1.4:
		get_tree().create_timer(1.5).timeout.connect(_open)   # c'è qualcuno: aspettano
		return
	_shut = false
	_busy = true
	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.6)
	t.tween_callback(func(): frame = Lids.HALF)
	t.tween_interval(0.25)
	t.tween_callback(func(): frame = Lids.OPEN)
	t.tween_callback(func(): _busy = false)
	t.tween_callback(_blink_later)


func _blink_later() -> void:
	get_tree().create_timer(randf_range(2.0, 5.0)).timeout.connect(_blink)


func _blink() -> void:
	if _shut or _busy or _staring or not is_inside_tree():
		return
	var t := create_tween()
	t.tween_callback(func(): frame = Lids.HALF)
	t.tween_interval(0.05)
	t.tween_callback(func(): frame = Lids.SHUT)
	t.tween_interval(0.09)
	t.tween_callback(func(): frame = Lids.HALF)
	t.tween_interval(0.05)
	t.tween_callback(func(): frame = Lids.OPEN)
	t.tween_callback(_blink_later)


## Ti hanno visto avvicinarti: si chiudono, svaniscono, e si riapriranno più tardi.
func _close_fast() -> void:
	_shut = true
	_busy = true
	var t := create_tween()
	t.tween_callback(func(): frame = Lids.SHUT)
	t.tween_property(self, "modulate:a", 0.0, 0.25)
	t.tween_callback(func(): _busy = false)
	get_tree().create_timer(randf_range(4.0, 8.0)).timeout.connect(_open)
