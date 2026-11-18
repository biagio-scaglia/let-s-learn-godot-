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
