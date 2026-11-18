class_name Follower
extends Node
## Fa seguire il giocatore al PNG genitore (Emilia nel bosco), come nei vecchi RPG:
## il giocatore lascia una scia di "briciole" (le sue posizioni) e il PNG cammina
## sulla scia, sempre un po' indietro. Così gira gli angoli dove li ha girati lui,
## invece di tagliare attraverso i rovi.

## Quanto resta indietro, in pixel, misurati lungo la scia.
@export var distance := 34.0
## Ogni quanti pixel di cammino si lascia una briciola.
const CRUMB_STEP := 3.0
## Quante briciole tenere (le più vecchie si buttano).
const MAX_CRUMBS := 80

## Se segue o no (una cutscene può spegnerlo).
var active := true
var _trail: PackedVector2Array = []
## True dopo una pausa (cutscene, dialogo di regia): la scia va ricominciata da capo.
var _needs_seed := true
var _npc: Node2D
var _player: Node2D


func _ready() -> void:
	# Così chi sposta di colpo il giocatore (un occhio che lo respinge...) può
	# chiamare snap_behind() su tutti quelli che lo seguono.
	add_to_group("followers")
	_npc = get_parent() as Node2D
	# Mentre segue non deve fare da muro: il giocatore a volte torna indietro.
	if _npc is CollisionObject2D:
		_npc.collision_layer = 0
	_player = get_tree().get_first_node_in_group("player") as Node2D
	# Sempre accanto al giocatore: se c'è altro con cui interagire (un nemico, un
	# cartello), E va a quello, non a chi segue.
	var talk := _npc.get_node_or_null("Interactable") as Interactable
	if talk:
		talk.low_priority = true
	# Dopo tutti i _ready (il livello ha già messo il giocatore al suo posto, e una
	# cutscene avrebbe già detto di sé): se non c'è una regia, si mette dietro di lui.
	_snap_if_free.call_deferred()


func _snap_if_free() -> void:
	if not Game.in_cutscene:
		snap_behind()


## Mette il PNG subito dietro al giocatore (all'arrivo in una scena, dopo una morte…).
func snap_behind(offset := Vector2(-24, 14)) -> void:
	if _player == null:
		return
	_npc.global_position = _player.global_position + offset
	_seed()


## La scia ricomincia: un pezzo solo, da dove sta il PNG a dove sta il giocatore.
func _seed() -> void:
	_trail = [_npc.global_position, _player.global_position]
	_needs_seed = false


func _physics_process(delta: float) -> void:
	if _player == null or not active or Game.in_cutscene:
		_needs_seed = true
		return
	if _needs_seed:
		_seed()
	_drop_crumb()
	var target := _point_behind()
	var to_target := target - _npc.global_position
	if to_target.length() < 1.0:
		if _npc.has_method("stand"):
			_npc.stand()
		return
	# Più è lontano, più si affretta: così non resta indietro quando Subaru corre.
	var speed := maxf(70.0, to_target.length() * 5.0)
	_npc.global_position = _npc.global_position.move_toward(target, speed * delta)
	if _npc.has_method("step"):
		_npc.step(Facing.from_vector(to_target), delta)


func _drop_crumb() -> void:
	var here := _player.global_position
	if _trail.is_empty() or _trail[-1].distance_to(here) >= CRUMB_STEP:
		_trail.append(here)
		if _trail.size() > MAX_CRUMBS:
			_trail.remove_at(0)


## Il punto della scia che sta "distance" pixel dietro al giocatore.
func _point_behind() -> Vector2:
	if _trail.size() < 2:
		return _npc.global_position   # il giocatore non si è ancora mosso: resta dov'è
	var left := distance
	for i in range(_trail.size() - 1, 0, -1):
		var seg := _trail[i] - _trail[i - 1]
		if seg.length() >= left:
			return _trail[i] - seg.normalized() * left
		left -= seg.length()
	return _trail[0]
