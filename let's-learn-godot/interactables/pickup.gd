extends Node2D
## Un oggetto per terra: fluttua, luccica e si raccoglie con "interact".
## Una volta raccolto non ricompare più (lo ricorda Game.flags, anche nei salvataggi).

## L'id dell'oggetto (vedi Inventory.ITEMS).
@export var item_id := "chiave"
## Quanti se ne raccolgono.
@export var amount := 1

@onready var icon: Sprite2D = $Icon
@onready var shadow: Sprite2D = $Shadow
@onready var sparkles: CPUParticles2D = $Sparkles
@onready var interactable: Interactable = $Interactable


func _ready() -> void:
	if Game.has_flag(FlagKeys.picked(self)):
		queue_free()   # già raccolto
		return
	icon.texture = Inventory.item(item_id).icon
	interactable.interacted.connect(_pick_up)

	# Fluttua su e giù, e l'ombra si stringe quando l'oggetto è più in alto.
	var t := create_tween().set_loops()
	t.tween_property(icon, "position:y", icon.position.y - 4.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(shadow, "scale", shadow.scale * 0.8, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(icon, "position:y", icon.position.y, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(shadow, "scale", shadow.scale, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _pick_up() -> void:
	Game.set_flag(FlagKeys.picked(self))
	Sfx.play(Sfx.PICKUP)
	Inventory.add(item_id, amount)
	interactable.queue_free()   # niente più nuvoletta né interazioni
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("cheer"):
		player.cheer()   # non lo aspettiamo: l'oggetto sale mentre lui esulta

	# L'oggetto sale, si ingrandisce e svanisce; una pioggia di scintille.
	sparkles.amount = 16
	sparkles.explosiveness = 1.0
	sparkles.restart()
	var t := create_tween().set_parallel()
	t.tween_property(icon, "position:y", icon.position.y - 24.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(icon, "scale", icon.scale * 1.5, 0.4)
	t.tween_property(icon, "modulate:a", 0.0, 0.4)
	t.tween_property(shadow, "modulate:a", 0.0, 0.3)
	await t.finished
	await get_tree().create_timer(0.6).timeout
	queue_free()
