extends Node2D
## La radura in cima al Bosco Senza Tempo, dove dorme Colui che guarda (atto 3, pezzo 3).
##
## Entrando nella radura (Trigger) l'occhio si sveglia: la camera sale verso di lui, un
## ruggito, tutti gli occhi del bosco si spalancano, due parole... e la battaglia.
## - Vinta: l'occhio si crepa e svanisce, gli occhi dei rovi si chiudono, la nebbia si
##   dirada, la luce si scalda. Ricordo guardiano_sconfitto.
## - Persa: si muore (Ritorno dalla Morte), ma Subaru ricorda lo Sguardo e il suo punto
##   debole (Game.remember): al tentativo dopo lo sa già.

const BOSS := preload("res://enemies/colui_che_guarda.tres")
## Subaru l'ha già visto svegliarsi (dopo una morte la scena è più corta).
const MEMORY_SEEN := "guardiano_visto"

@export var dawn: CanvasModulate
@export var fog: CanvasItem
@export var rays: ColorRect

@onready var eye: Sprite2D = $Eye
@onready var glow: PointLight2D = $Glow
@onready var aura: CPUParticles2D = $Aura
@onready var trigger: Area2D = $Trigger

var _started := false
var _breath: Tween


func _ready() -> void:
	if Game.has_flag(FlagKeys.BOSS_DEFEATED):
		queue_free()   # già sconfitto: la radura è libera
		return
	eye.hframes = 5
	eye.frame = EnemyData.Pose.HURT   # socchiuso: dorme
	glow.energy = 0.4
	trigger.body_entered.connect(_on_body_entered)
	# Fluttua piano su e giù, anche da addormentato.
	var bob := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_loops()
	bob.tween_property(eye, "position:y", eye.position.y - 6.0, 1.6).set_trans(Tween.TRANS_SINE)
	bob.tween_property(eye, "position:y", eye.position.y, 1.6).set_trans(Tween.TRANS_SINE)
