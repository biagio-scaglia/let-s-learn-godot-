extends CharacterBody2D

@export var speed := 70.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var facing := "down"


func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input * speed
	move_and_slide()

	if input != Vector2.ZERO:
		# Prefer the dominant axis so diagonals pick a sensible facing.
		if abs(input.x) > abs(input.y):
			facing = "right" if input.x > 0 else "left"
		else:
			facing = "down" if input.y > 0 else "up"
		sprite.play("walk_" + facing)
	else:
		sprite.play("idle_" + facing)
