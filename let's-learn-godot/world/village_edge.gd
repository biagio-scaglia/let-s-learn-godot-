extends Node
## I confini del villaggio. Più Subaru si avvicina al bordo della mappa, più forte
## batte il cuore e più lo schermo si chiude. Se prova a uscire... muore.
## Vedi ReturnByDeath.

## La parte di mappa dove si può camminare (dentro i muri invisibili di Bounds).
@export var walkable := Rect2(64, 64, 1152, 640)
## Da che distanza dal bordo si comincia a sentire il cuore.
@export var warn_distance := 120.0
## A che distanza dal bordo si muore.
@export var death_distance := 12.0
## La vignettatura da stringere quando si è in pericolo.
@export var vignette: ColorRect

@onready var heartbeat_slow: AudioStreamPlayer = $HeartbeatSlow
@onready var heartbeat_fast: AudioStreamPlayer = $HeartbeatFast

## Da 0 (al sicuro) a 1 (sul bordo).
var danger := 0.0
var _vignette_strength := 0.4
var _vignette_material: ShaderMaterial
## Il giocatore, cercato una volta sola (non a ogni frame).
var _player: Node2D


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null:
		# Il villaggio fa da sfondo al titolo: niente Subaru, niente da controllare.
		set_process(false)
		return
	if vignette:
		_vignette_material = vignette.material as ShaderMaterial
		_vignette_strength = _vignette_material.get_shader_parameter("strength")
	# Il battito ricomincia da solo finché c'è pericolo.
	heartbeat_slow.finished.connect(_beat)
	heartbeat_fast.finished.connect(_beat)


func _process(delta: float) -> void:
	var target := 0.0
	if Game.player_can_move():
		var p := _player.global_position
		var distance := minf(minf(p.x - walkable.position.x, walkable.end.x - p.x),
				minf(p.y - walkable.position.y, walkable.end.y - p.y))
		if distance <= death_distance:
			ReturnByDeath.die()
		target = clampf(1.0 - (distance - death_distance) / (warn_distance - death_distance), 0.0, 1.0)
	if target == danger:
		return   # niente è cambiato (quasi sempre: Subaru è lontano dai bordi)
	# Il pericolo sale e scende piano, così non ci sono scatti.
	danger = move_toward(danger, target, delta * 1.5)

	var was_beating := heartbeat_slow.playing or heartbeat_fast.playing
	heartbeat_slow.volume_db = linear_to_db(maxf(danger, 0.001)) - 2.0
	heartbeat_fast.volume_db = linear_to_db(maxf(danger, 0.001))
	if danger > 0.05 and not was_beating:
		_beat()
	if _vignette_material:
		_vignette_material.set_shader_parameter("strength", _vignette_strength + danger * 0.5)


## Un battito: lento da lontano, veloce vicino al bordo.
func _beat() -> void:
	if danger <= 0.05:
		return
	if danger > 0.6:
		heartbeat_fast.play()
	else:
		heartbeat_slow.play()
