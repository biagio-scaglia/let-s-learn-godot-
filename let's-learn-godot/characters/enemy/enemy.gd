extends StaticBody2D
## Un nemico sulla mappa. Avvicinati e premi E: comincia il combattimento (Battle).
## Chi è, e quanto è forte, lo dice la risorsa "data" (un file .tres in enemies/).
## Una volta sconfitto non ricompare più (lo ricorda Game.flags, anche nei salvataggi).

@export var data: EnemyData

## Quanto è alto un nemico sulla mappa, in pixel, qualunque sia la grandezza dello sprite.
const MAP_HEIGHT := 32.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable: Interactable = $Interactable


func _ready() -> void:
	if Game.has_flag(FlagKeys.defeated(self)):
		queue_free()   # già sconfitto
		return
	sprite.texture = data.texture
	# Uno sprite da 16 px va ingrandito x2, uno da 32 px resta x1 (come Subaru ed Emilia).
	sprite.hframes = maxi(1, data.frames)
	var height := data.cell_size()
	sprite.scale = Vector2.ONE * (MAP_HEIGHT / height)
	sprite.offset = Vector2(0, -height / 2.0)
	interactable.interacted.connect(_fight)

	# Saltella sul posto: sale schiacciandosi un poco, e ricade.
	var base := sprite.scale
	var hop := create_tween().set_loops()
	hop.tween_property(sprite, "position:y", -5.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hop.parallel().tween_property(sprite, "scale", base * Vector2(0.94, 1.08), 0.35)
	hop.tween_property(sprite, "position:y", 0.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	hop.parallel().tween_property(sprite, "scale", base, 0.35)


func _fight() -> void:
	var result: String = await Battle.start(data)
	if result != Battle.WIN:
		return   # fuggito: il nemico resta lì. Sconfitto: ci pensa il Ritorno dalla Morte
	Game.set_flag(FlagKeys.defeated(self))
	interactable.queue_free()   # niente più nuvoletta né interazioni
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.5)
	await t.finished
	queue_free()
