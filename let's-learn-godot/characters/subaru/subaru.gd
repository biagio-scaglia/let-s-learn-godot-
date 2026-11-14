extends CharacterBody2D

## Velocità in pixel al secondo.
@export var walk_speed := 80.0
@export var run_speed := 150.0
## Quanto più veloce va l'animazione quando corre.
@export var run_anim_scale := 1.8

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dust: CPUParticles2D = $Dust
@onready var steps: AudioStreamPlayer2D = $Steps
var facing := Facing.DOWN
## Quanti passi ha fatto (utile nei test).
var step_count := 0
## True quando lo muove uno script (cutscene, morte): i tasti non contano.
var _scripted := false


func _ready() -> void:
	sprite.frame_changed.connect(_on_frame_changed)


## I frame 0 e 2 della camminata sono quelli con il piede a terra: lì suona il passo.
func _on_frame_changed() -> void:
	if sprite.animation.begins_with("walk_") and sprite.frame in [0, 2]:
		steps.pitch_scale = randf_range(0.85, 1.15)
		steps.play()
		step_count += 1


func _physics_process(_delta: float) -> void:
	if _scripted:
		return   # lo muove walk_to(), non i tasti
	# Durante un dialogo o un cambio di scena Subaru resta fermo.
	if not Game.player_can_move():
		velocity = Vector2.ZERO
		dust.emitting = false
		_play_idle()
		return

	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var running := Input.is_action_pressed("run")

	velocity = input * (run_speed if running else walk_speed)
	move_and_slide()

	var moving := input != Vector2.ZERO
	# Nuvolette di polvere ai piedi solo quando corre.
	dust.emitting = moving and running

	if moving:
		facing = Facing.from_vector(input)
		sprite.play("walk_" + facing)
		sprite.speed_scale = run_anim_scale if running else 1.0
	else:
		_play_idle()


## Fa camminare Subaru da solo fino a "point", in linea retta (per le cutscene).
## Si può aspettare: await subaru.walk_to(...). Attraversa i muri: serve solo per le scene scritte.
func walk_to(point: Vector2, speed := walk_speed) -> void:
	_scripted = true
	facing = Facing.from_vector(point - global_position)
	sprite.play("walk_" + facing)
	sprite.speed_scale = 1.0
	var t := create_tween()
	t.tween_property(self, "global_position", point, global_position.distance_to(point) / speed)
	await t.finished
	_scripted = false
	_play_idle()


## Subaru crolla a terra: cade di lato e si scurisce. Per il Ritorno dalla Morte.
## Si rialza da solo quando la scena viene ricaricata.
func collapse() -> void:
	_scripted = true
	velocity = Vector2.ZERO
	dust.emitting = false
	_play_idle()
	sprite.stop()
	var side := -1.0 if facing == Facing.LEFT else 1.0
	var t := create_tween().set_parallel()
	# Lo sprite ruota attorno ai piedi (la sua origine), quindi "cade" di lato.
	t.tween_property(sprite, "rotation", side * PI / 2.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(sprite, "modulate", Color(0.45, 0.35, 0.55), 0.8)
	await t.finished


## Gira Subaru verso un punto (per esempio chi gli sta parlando).
func look_at_point(point: Vector2) -> void:
	face(Facing.from_vector(point - global_position))


## Gira Subaru in una direzione: Facing.DOWN, UP, LEFT o RIGHT.
func face(direction: String) -> void:
	facing = direction
	_play_idle()


func _play_idle() -> void:
	sprite.play("idle_" + facing)
	sprite.speed_scale = 1.0

