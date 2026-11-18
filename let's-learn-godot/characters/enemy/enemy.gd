extends StaticBody2D
## Un nemico sulla mappa. Avvicinati e premi E: comincia il combattimento (Battle).
## Chi è, e quanto è forte, lo dice la risorsa "data" (un file .tres in enemies/).
## Una volta sconfitto non ricompare più (lo ricorda Game.flags, anche nei salvataggi).

@export var data: EnemyData

## Quanto è alto un nemico sulla mappa, in pixel, qualunque sia la grandezza dello sprite.
const MAP_HEIGHT := 32.0

## Quanto può allontanarsi dal punto dove è nato, quando gironzola (0 = sta fermo).
@export var wander_radius := 48.0
## Velocità quando gironzola, in pixel al secondo: lenta, non insegue nessuno.
@export var wander_speed := 26.0

## Il punto dove è nato: gironzola sempre lì attorno.
var _home := Vector2.ZERO
var _wander_tween: Tween

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
	_home = global_position
	if wander_radius > 0.0:
		_wander_later()

	# Respira: le due pose di riposo si alternano (solo se il foglio le ha).
	if data.animated():
		var breathe := create_tween().set_loops()
		breathe.tween_callback(func(): sprite.frame = EnemyData.Pose.IDLE)
		breathe.tween_interval(0.45)
		breathe.tween_callback(func(): sprite.frame = EnemyData.Pose.IDLE_2)
		breathe.tween_interval(0.45)

	# Saltella sul posto: sale schiacciandosi un poco, e ricade.
	var base := sprite.scale
	var hop := create_tween().set_loops()
	hop.tween_property(sprite, "position:y", -5.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hop.parallel().tween_property(sprite, "scale", base * Vector2(0.94, 1.08), 0.35)
	hop.tween_property(sprite, "position:y", 0.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	hop.parallel().tween_property(sprite, "scale", base, 0.35)


## Ogni tanto fa qualche passo attorno a casa. Prima controlla di non sbattere contro
## qualcosa (un albero, un rovo, Subaru) con test_move: se sbatterebbe, resta dov'è.
func _wander_later() -> void:
	get_tree().create_timer(randf_range(2.5, 5.5)).timeout.connect(_wander)


func _wander() -> void:
	if not is_inside_tree() or Game.has_flag(FlagKeys.defeated(self)):
		return
	# Fermo durante dialoghi, cutscene e battaglie, e quando Subaru gli sta parlando vicino.
	if Game.player_can_move() and interactable.player == null:
		step_towards(_home + Vector2.from_angle(randf() * TAU) * randf_range(12.0, wander_radius))
	_wander_later()


## Un passo verso "target", se la strada è libera. Restituisce true se si è mosso.
func step_towards(target: Vector2) -> bool:
	var motion := target - global_position
	if motion.length() < 4.0 or test_move(global_transform, motion):
		return false
	sprite.flip_h = motion.x < 0.0   # guarda dove va
	if _wander_tween:
		_wander_tween.kill()
	_wander_tween = create_tween()
	_wander_tween.tween_property(self, "global_position", target, motion.length() / wander_speed) 		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return true


func _fight() -> void:
	var result: String = await Battle.start(data)
	if result != Battle.WIN:
		return   # fuggito: il nemico resta lì. Sconfitto: ci pensa il Ritorno dalla Morte
	Game.set_flag(FlagKeys.defeated(self))
	if data.drop != "":
		Inventory.add(data.drop)   # l'avviso "Hai trovato…" compare da solo
	interactable.queue_free()   # niente più nuvoletta né interazioni
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.5)
	await t.finished
	queue_free()
