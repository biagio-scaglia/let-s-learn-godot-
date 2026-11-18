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
	_npc = get_parent() as Node2D
	# Mentre segue non deve fare da muro: il giocatore a volte torna indietro.
	if _npc is CollisionObject2D:
		_npc.collision_layer = 0
	_player = get_tree().get_first_node_in_group("player") as Node2D
	# Dopo tutti i _ready (il livello ha già messo il giocatore al suo posto, e una
	# cutscene avrebbe già detto di sé): se non c'è una regia, si mette dietro di lui.
	_snap_if_free.call_deferred()


func _snap_if_free() -> void:
	if not Game.in_cutscene:
		snap_behind()
