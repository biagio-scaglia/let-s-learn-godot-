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


func _on_body_entered(body: Node2D) -> void:
	if _started or not body.is_in_group("player") or Game.in_cutscene:
		return
	_started = true
	_awaken(body)


func _awaken(player: Node2D) -> void:
	Game.in_cutscene = true
	var seen := Game.remembers(MEMORY_SEEN)
	Game.remember(MEMORY_SEEN)
	var camera := player.get_node_or_null("Camera2D") as Camera2D
	# La musica del bosco si spegne: c'è solo il silenzio, e il vento.
	for music in get_tree().get_nodes_in_group("level_music"):
		create_tween().tween_property(music, "volume_db", -40.0, 1.5)
	# La camera sale verso l'occhio.
	if camera:
		var look := (eye.global_position - player.global_position) * 0.55
		await create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS) \
			.tween_property(camera, "offset", look, 1.4).set_trans(Tween.TRANS_SINE).finished
	# Si sveglia: ruggito, terremoto, tutti gli occhi del bosco si spalancano.
	Sfx.play(Sfx.BOSS_ROAR)
	_shake(camera, 1.2)
	get_tree().call_group("thicket_eyes", "stare")
	eye.frame = EnemyData.Pose.WINDUP
	aura.emitting = true
	create_tween().tween_property(glow, "energy", 2.2, 0.5)
	await get_tree().create_timer(1.0).timeout
	_breathe()
	if seen:
		Dialogue.start("Colui che guarda", ["...Ancora tu."])
		await Dialogue.finished
		Dialogue.start("Subaru", ["Di nuovo qui. Ma stavolta ricordo il tuo sguardo."])
		await Dialogue.finished
	else:
		Dialogue.start("Colui che guarda", [
			"...Ancora tu.",
			"Ogni volta torni. Ogni volta muori. E ogni volta, resti.",
			"Erbalta dorme. Erbalta è al sicuro. Perché vuoi svegliarla?",
		])
		await Dialogue.finished
		Dialogue.start("Subaru", [
			"Al sicuro? È una gabbia. Gli alberi non crescono, il Saggio non ricorda, le stelle sono ferme.",
			"Questa volta no. Questa volta la porto via di qui.",
		])
		await Dialogue.finished
		Dialogue.start("Emilia", ["Subaru. Insieme."])
		await Dialogue.finished
	if camera:
		create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).tween_property(camera, "offset", Vector2.ZERO, 0.5)
	var result: String = await Battle.start(BOSS)
	if result == Battle.WIN:
		await _defeated(player)
	elif result == Battle.LOSE:
		# Il Ritorno dalla Morte riporta tutto indietro. Tutto, tranne quello che Subaru ha visto.
		Game.remember(WatcherBehavior.MEMORY_GAZE)
