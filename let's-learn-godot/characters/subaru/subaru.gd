extends CharacterBody2D

## Velocità in pixel al secondo.
@export var walk_speed := 80.0
@export var run_speed := 150.0
## Quanto più veloce va l'animazione quando corre.
@export var run_anim_scale := 1.8

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dust: CPUParticles2D = $Dust
@onready var steps: AudioStreamPlayer2D = $Steps
var facing := "down"
## Quanti passi ha fatto (utile nei test).
var step_count := 0


func _ready() -> void:
	sprite.frame_changed.connect(_on_frame_changed)


## I frame 0 e 2 della camminata sono quelli con il piede a terra: lì suona il passo.
func _on_frame_changed() -> void:
	if sprite.animation.begins_with("walk_") and sprite.frame in [0, 2]:
		steps.pitch_scale = randf_range(0.85, 1.15)
		steps.play()
		step_count += 1


func _physics_process(_delta: float) -> void:
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
		facing = _direction_name(input)
		sprite.play("walk_" + facing)
		sprite.speed_scale = run_anim_scale if running else 1.0
	else:
		_play_idle()


## Gira Subaru verso un punto (per esempio chi gli sta parlando).
func look_at_point(point: Vector2) -> void:
	face(_direction_name(point - global_position))


## Gira Subaru in una direzione: "down", "up", "left" o "right".
func face(direction: String) -> void:
	facing = direction
	_play_idle()


func _play_idle() -> void:
	sprite.play("idle_" + facing)
	sprite.speed_scale = 1.0


func _direction_name(dir: Vector2) -> String:
	# Prende l'asse dominante, così le diagonali scelgono una direzione sensata.
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	return "down" if dir.y > 0 else "up"
