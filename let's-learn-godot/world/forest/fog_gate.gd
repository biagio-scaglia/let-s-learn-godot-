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
