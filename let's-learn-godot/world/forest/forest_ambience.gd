extends Node
## I suoni sparsi del bosco: ogni tanto un corvo lontano o un ramo che scricchiola,
## da un punto a caso attorno al giocatore. Con AudioStreamPlayer2D si sentono dal lato giusto.

@export var sounds: Array[AudioStream] = []
## Ogni quanti secondi (più o meno) arriva un suono.
@export var min_wait := 5.0
@export var max_wait := 12.0
## Quanto lontano dal giocatore possono nascere.
@export var radius := 260.0

var _player: Node2D


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null or sounds.is_empty():
		return
	_wait_next()


func _wait_next() -> void:
	get_tree().create_timer(randf_range(min_wait, max_wait)).timeout.connect(_play_one)


func _play_one() -> void:
	if not is_inside_tree():
		return
	var p := AudioStreamPlayer2D.new()
	p.stream = sounds.pick_random()
	p.pitch_scale = randf_range(0.85, 1.1)
	p.volume_db = randf_range(-12.0, -6.0)
	p.max_distance = radius * 2.5
	add_child(p)
	p.global_position = _player.global_position + Vector2.from_angle(randf() * TAU) * randf_range(radius * 0.5, radius)
	p.finished.connect(p.queue_free)
	p.play()
	_wait_next()
