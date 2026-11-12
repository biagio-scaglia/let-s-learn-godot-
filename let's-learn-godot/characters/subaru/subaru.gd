extends CharacterBody2D

## Velocità in pixel al secondo.
@export var walk_speed := 80.0
@export var run_speed := 150.0
## Quanto più veloce va l'animazione quando corre.
@export var run_anim_scale := 1.8

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var facing := "down"


func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var running := Input.is_action_pressed("run")

	velocity = input * (run_speed if running else walk_speed)
	move_and_slide()

	if input != Vector2.ZERO:
		# Prefer the dominant axis so diagonals pick a sensible facing.
		if abs(input.x) > abs(input.y):
			facing = "right" if input.x > 0 else "left"
		else:
			facing = "down" if input.y > 0 else "up"
		sprite.play("walk_" + facing)
		sprite.speed_scale = run_anim_scale if running else 1.0
	else:
		sprite.play("idle_" + facing)
		sprite.speed_scale = 1.0
