class_name FogGate
extends StaticBody2D
## La nebbia viola che sbarra la radura del Bosco Senza Tempo. Dentro brillano tre
## occhi, uno per ogni occhio di pietra (EyeOvest, EyeEst, EyeSud). Quando un occhio
## di pietra si chiude, si chiude anche il suo bagliore; con tutti e tre chiusi la
## nebbia si dissolve e la strada è libera.

@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var mist: CPUParticles2D = $Mist
@onready var glow: PointLight2D = $Glow
@onready var interactable: Interactable = $Interactable


func _ready() -> void:
	for id in FlagKeys.STONE_EYES:
		var eye := _eye(id)
		eye.hframes = 3
		if Game.has_flag(FlagKeys.eye_closed(id)):
			eye.visible = false
	if FlagKeys.eyes_closed_count() == FlagKeys.STONE_EYES.size():
		queue_free()   # già aperta in un'altra visita
		return
	_update_lines()
	# Guardandola, Subaru scopre dei tre bagliori: l'obiettivo diventa "chiudi gli occhi".
	interactable.interacted.connect(func(): Game.set_flag(FlagKeys.FOG_SEEN))


func _eye(id: String) -> Sprite2D:
	return get_node("Eye" + id.capitalize()) as Sprite2D


## Dove sta il bagliore di un occhio (lì arriva il raggio dell'occhio di pietra).
func eye_position(id: String) -> Vector2:
	return _eye(id).global_position


## Il bagliore si chiude: palpebra, un lampo, poi svanisce.
func close_eye(id: String) -> void:
	var eye := _eye(id)
	var t := create_tween()
	t.tween_callback(func(): eye.frame = 1)
	t.tween_interval(0.15)
	t.tween_callback(func(): eye.frame = 2)
	t.tween_property(eye, "modulate", Color(2, 2, 2, 1), 0.08)
	t.tween_property(eye, "modulate:a", 0.0, 0.4)
	t.tween_callback(eye.hide)
	create_tween().tween_property(glow, "energy", glow.energy * 0.7, 0.6)
	_update_lines()


## Tutti chiusi: la nebbia si apre. Si può aspettare con await.
func dissolve() -> void:
	Sfx.play(Sfx.FOG_DISSOLVE)
	shape.set_deferred("disabled", true)
	interactable.queue_free()
	mist.explosiveness = 0.8
	mist.initial_velocity_max = 90.0
	mist.spread = 180.0
	var t := create_tween()
	t.tween_property(glow, "energy", 2.5, 0.4)
	t.tween_property(glow, "energy", 0.0, 2.0)
	t.parallel().tween_property(mist, "modulate:a", 0.0, 2.0)
	await t.finished
	queue_free()


func _update_lines() -> void:
	var left := FlagKeys.STONE_EYES.size() - FlagKeys.eyes_closed_count()
	if left == FlagKeys.STONE_EYES.size():
		return   # le frasi della scena: la prima volta che la vedi
	var glows := "brilla un ultimo bagliore" if left == 1 else "brillano ancora %d bagliori" % left
	interactable.lines = ["La nebbia viola è ancora qui. Dentro, %s." % glows]
	interactable.repeat_lines = []
